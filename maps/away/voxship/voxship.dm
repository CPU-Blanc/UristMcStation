#include "voxship_areas.dm"
#include "voxship_jobs.dm"

/datum/map_template/ruin/away_site/voxship
	name = "Vox Base"
	id = "awaysite_voxship"
	description = "Vox ship and base."
	suffixes = list("voxship/voxship-1.dmm")
	cost = 1
	shuttles_to_initialise = list(/datum/shuttle/autodock/overmap/vox_shuttle)

/obj/effect/overmap/sector/vox_base
	name = "large asteroid"
	desc = "Sensor array detects a large asteroid."
	color = "#cc5474"
	in_space = 1
	icon_state = "meteor4"
	known = 0
	initial_generic_waypoints = list(
		"nav_voxbase_1",
	)

/obj/effect/shuttle_landmark/nav_voxbase/nav1
	name = "Northest of Large Asteroid"
	landmark_tag = "nav_voxbase_1"

/datum/shuttle/autodock/overmap/vox_shuttle
	name = "Vox Shuttle"
	move_time = 10
	shuttle_area = list(/area/voxship/ship)
	dock_target = "vox_shuttle"
	current_location = "nav_hangar_vox"
	landmark_transition = "nav_transit_vox"
	range = 1
	fuel_consumption = 4
	ceiling_type = /turf/simulated/floor/shuttle_ceiling/
	defer_initialisation = TRUE

/obj/effect/shuttle_landmark/vox_base/hangar/vox_shuttle
	name = "Vox Ship Docked"
	landmark_tag = "nav_hangar_vox"

/obj/effect/shuttle_landmark/transit/vox_base/vox_shuttle
	name = "In transit"
	landmark_tag = "nav_transit_vox"

/obj/machinery/computer/shuttle_control/explore/vox_shuttle
	name = "shuttle control console"
	shuttle_tag = "Vox Shuttle"

/obj/effect/overmap/ship/landable/vox
	name = "Unknown Signature"
	shuttle = "Vox Shuttle"
	fore_dir = NORTH
	vessel_mass = 2000

/obj/effect/submap_landmark/joinable_submap/voxship
	archetype = /decl/submap_archetype/derelict/voxship

/obj/effect/submap_landmark/joinable_submap/voxship/New()
	var/datum/language/vox/pidgin = all_languages[LANGUAGE_VOX]
	name = "[pidgin.get_random_name()]-[pidgin.get_random_name()]"
	..()

/decl/submap_archetype/derelict/voxship
	descriptor = "Shoal forward base"
	map = "Vox Base"
	crew_jobs = list(
		/datum/job/submap/voxship_vox
	)
	whitelisted_species = list(SPECIES_VOX)
	blacklisted_species = null

/turf/simulated/floor/plating/vox
	initial_gas = list("nitrogen" = MOLES_N2STANDARD*1.25)

/turf/simulated/floor/reinforced/vox
	initial_gas = list("nitrogen" = MOLES_N2STANDARD*1.25)

/turf/simulated/floor/tiled/techmaint/vox
	initial_gas = list("nitrogen" = MOLES_N2STANDARD*1.25)

/obj/machinery/alarm/vox
	req_access = newlist()

/obj/machinery/alarm/vox/Initialize()
	.=..()
	TLV["oxygen"] =	list(-1, -1, 0.1, 0.1) // Partial pressure, kpa
	TLV["nitrogen"] = list(16, 19, 135, 140) // Partial pressure, kpa

/obj/machinery/power/smes/buildable/preset/voxship/ship/configure_and_install_coils()
	component_parts += new /obj/item/weapon/smes_coil/super_capacity(src)
	_input_maxed = TRUE
	_output_maxed = TRUE
	_input_on = TRUE
	_output_on = TRUE
	_fully_charged = TRUE