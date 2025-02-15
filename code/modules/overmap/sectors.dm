//===================================================================================
//Overmap object representing zlevel(s)
//===================================================================================
/obj/effect/overmap
	name = "map object"
	icon = 'icons/obj/overmap.dmi'
	icon_state = "object"
	var/list/map_z = list()

	var/list/initial_generic_waypoints //store landmark_tag of landmarks that should be added to the actual lists below on init.
	var/list/initial_restricted_waypoints //For use with non-automatic landmarks (automatic ones add themselves).

	var/list/generic_waypoints = list()    //waypoints that any shuttle can use
	var/list/restricted_waypoints = list() //waypoints for specific shuttles
	var/docking_codes

	var/start_x			//coordinates on the
	var/start_y			//overmap zlevel

	var/base = 0		//starting sector, counts as station_levels
	var/known = 1		//shows up on nav computers automatically
	var/in_space = 1	//can be accessed via lucky EVA

	var/has_distress_beacon

	var/hidden = FALSE //hidden for the purposes of tooltips. currently only used for the pirate station to avoid cheese

/obj/effect/overmap/Initialize()
	. = ..()
	if(!GLOB.using_map.use_overmap)
		return INITIALIZE_HINT_QDEL

	if(!GLOB.using_map.overmap_z)
		build_overmap()
	find_z_levels()     // This populates map_z and assigns z levels to the ship.
	register_z_levels() // This makes external calls to update global z level information.

	docking_codes = "[ascii2text(rand(65,90))][ascii2text(rand(65,90))][ascii2text(rand(65,90))][ascii2text(rand(65,90))]"

	start_x = start_x || rand(OVERMAP_EDGE, GLOB.using_map.overmap_size - OVERMAP_EDGE)
	start_y = start_y || rand(OVERMAP_EDGE, GLOB.using_map.overmap_size - OVERMAP_EDGE)

	forceMove(locate(start_x, start_y, GLOB.using_map.overmap_z))
	testing("Located sector \"[name]\" at [start_x],[start_y], containing Z [english_list(map_z)]")

	LAZYADD(SSshuttle.sectors_to_initialize, src) //Queued for further init. Will populate the waypoint lists; waypoints not spawned yet will be added in as they spawn.
	SSshuttle.clear_init_queue()

//This is called later in the init order by SSshuttle to populate sector objects. Importantly for subtypes, shuttles will be created by then.
/obj/effect/overmap/proc/populate_sector_objects()

/obj/effect/overmap/proc/get_areas()

/obj/effect/overmap/proc/find_z_levels()
	map_z = GetConnectedZlevels(z)

/obj/effect/overmap/proc/register_z_levels()
	for(var/zlevel in map_z)
		map_sectors["[zlevel]"] = src

	GLOB.using_map.player_levels |= map_z
	if(!in_space)
		GLOB.using_map.sealed_levels |= map_z
	if(base)
		GLOB.using_map.station_levels |= map_z
		GLOB.using_map.contact_levels |= map_z
		GLOB.using_map.map_levels |= map_z

//Helper for init.
/obj/effect/overmap/proc/check_ownership(obj/object)
	if((object.z in map_z) && !(get_area(object) in SSshuttle.shuttle_areas))
		return 1

//If shuttle_name is false, will add to generic waypoints; otherwise will add to restricted. Does not do checks.
/obj/effect/overmap/proc/add_landmark(obj/effect/shuttle_landmark/landmark, shuttle_name)
	landmark.sector_set(src, shuttle_name)
	if(shuttle_name)
		LAZYADD(restricted_waypoints[shuttle_name], landmark)
	else
		generic_waypoints += landmark

/obj/effect/overmap/proc/remove_landmark(obj/effect/shuttle_landmark/landmark, shuttle_name)
	if(shuttle_name)
		var/list/shuttles = restricted_waypoints[shuttle_name]
		LAZYREMOVE(shuttles, landmark)
	else
		generic_waypoints -= landmark

/obj/effect/overmap/proc/get_waypoints(var/shuttle_name)
	. = generic_waypoints.Copy()
	if(shuttle_name in restricted_waypoints)
		. += restricted_waypoints[shuttle_name]

/obj/effect/overmap/sector
	name = "generic sector"
	desc = "Sector with some stuff in it."
	icon_state = "sector"
	anchored = 1

// Because of the way these are spawned, they will potentially have their invisibility adjusted by the turfs they are mapped on
// prior to being moved to the overmap. This blocks that. Use set_invisibility to adjust invisibility as needed instead.
/obj/effect/overmap/sector/hide()

/obj/effect/overmap/sector/Initialize()
	. = ..()
	if(known)
		layer = ABOVE_LIGHTING_LAYER
		plane = EFFECTS_ABOVE_LIGHTING_PLANE
		for(var/obj/machinery/computer/ship/helm/H in SSmachines.machinery)
			H.get_known_sectors()

/obj/effect/overmap/sector/get_areas()
	return get_filtered_areas(list(/proc/area_belongs_to_zlevels = map_z))


/obj/effect/overmap/sector/MouseEntered(location, control, params)
	if(!hidden)
		openToolTip(user = usr, tip_src = src, params = params, title = name)
	..()

/obj/effect/overmap/sector/MouseDown()
	closeToolTip(usr) //No reason not to, really
	..()

/obj/effect/overmap/sector/MouseExited()
	closeToolTip(usr) //No reason not to, really
	..()

/proc/build_overmap()
	if(!GLOB.using_map.use_overmap)
		return 1

	testing("Building overmap...")
	world.maxz++
	GLOB.using_map.overmap_z = world.maxz
	var/list/turfs = list()
	for (var/square in block(locate(1,1,GLOB.using_map.overmap_z), locate(GLOB.using_map.overmap_size,GLOB.using_map.overmap_size,GLOB.using_map.overmap_z)))
		var/turf/T = square
		if(T.x == GLOB.using_map.overmap_size || T.y == GLOB.using_map.overmap_size)
			T = T.ChangeTurf(/turf/unsimulated/map/edge)
		else
			T = T.ChangeTurf(/turf/unsimulated/map/)
		turfs += T

	var/area/overmap/A = new
	A.contents.Add(turfs)

	GLOB.using_map.sealed_levels |= GLOB.using_map.overmap_z

	testing("Overmap build complete.")
	return 1
