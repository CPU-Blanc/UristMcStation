/mob/living/exosuit/premade/cvrt //why working? because we don't want people to be able to hit things. //rip working
	name = "Combat Vehicle - Reconnaissance"
	desc = "A fast armoured vehicle designed to perform reconnaissance missions in combat situations."
	icon = 'icons/urist/vehicles/cvrt.dmi'
	icon_state = "cvrt"
	//initial_icon = "cvrt"
	health_max = 300
	bound_width = 64
	bound_height = 64
	wreckage_path = /obj/effect/decal/mecha_wreckage/cvrt
	var/obj/item/cell/cell
	pilots = 4

/mob/living/exosuit/premade/cvrt/Initialize()
	if(!legs)
		legs = new /obj/item/mech_component/propulsion/cvrt(src)
		legs.color = COLOR_GUNMETAL
	if(!head)
		head = new /obj/item/mech_component/sensors/combat(src)
		head.color = COLOR_GUNMETAL
	if(!body)
		body = new/obj/item/mech_component/chassis/cvrt(src)
		body.color = COLOR_GUNMETAL

	. = ..()

/mob/living/exosuit/premade/cvrt/spawn_mech_equipment()
	..()
	install_system(new /obj/item/mech_equipment/mounted_system/taser/laser/rapid(src), HARDPOINT_LEFT_HAND)
	//install_system(new /obj/item/mech_equipment/mounted_system/taser/ion(src), HARDPOINT_RIGHT_HAND)
	//install_system(new /obj/item/mech_equipment/flash(src), HARDPOINT_LEFT_SHOULDER)
	//install_system(new /obj/item/mech_equipment/light(src), HARDPOINT_RIGHT_SHOULDER)

/obj/item/mech_component/chassis/cvrt
	name = "CV-R systems"
	hide_pilot = TRUE
	has_hardpoints = list(
		HARDPOINT_BACK,
		HARDPOINT_LEFT_SHOULDER,
		HARDPOINT_RIGHT_SHOULDER,
		HARDPOINT_LEFT_HAND,
		HARDPOINT_RIGHT_HAND,
		HARDPOINT_HEAD
		)
	m_armour = /obj/item/robot_parts/robot_component/armour/exosuit
	cell = /obj/item/cell/infinite
	diagnostics = /obj/item/robot_parts/robot_component/diagnosis_unit
	air_supply = /obj/machinery/portable_atmospherics/canister/oxygen

/obj/item/mech_component/propulsion/cvrt
	name = "CV-R treads"
	mech_turn_sound = 'sound/machines/hiss.ogg'
	mech_step_sound = 'sound/machines/hiss.ogg'

//these three procs overriden to play different sounds
/*/mob/living/exosuit/cvrt/mechturn(direction)
	set_dir(direction)
	//playsound(src,'sound/machines/hiss.ogg',40,1)
	return 1

/mob/living/exosuit/cvrt/mechstep(direction)
	var/result = step(src,direction)
	if(result)
		playsound(src,'sound/machines/hiss.ogg',40,1)
	return result


/mob/living/exosuit/cvrt/mechsteprand()
	var/result = step_rand(src)
	if(result)
		playsound(src,'sound/machines/hiss.ogg',40,1)
	return result*/

/*/mob/living/exosuit/cvrt/basic/New() //we've got a gun and we take four passengers
	..()
	var/obj/item/mech_equipment/ME = new /obj/item/mech_equipment/weapon/ballistic/lmg
	ME.attach(src)
	ME = new /obj/item/mech_equipment/tool/passenger
	ME.attach(src)
	ME = new /obj/item/mech_equipment/tool/passenger
	ME.attach(src)
	ME = new /obj/item/mech_equipment/tool/passenger
	ME.attach(src)
	ME = new /obj/item/mech_equipment/tool/passenger
	ME.attach(src)*/

/obj/item/mech_equipment/mounted_system/taser/laser/rapid
	equipment_delay = 8
	name = "\improper CH-R \"Consecrator\" Burst laser"
	icon_state = "mecha_laser"
	holding_type = /obj/item/gun/energy/lasercannon/mounted/mech/cvrt

/obj/item/gun/energy/lasercannon/mounted/mech/cvrt
	name = "\improper CH-R \"Consecrator\" Burst laser"
	icon_state = "mecha_laser"
	use_external_power = TRUE
	burst = 3
	fire_sound = 'sound/weapons/Laser.ogg'

/mob/living/exosuit/premade/cvrt/upgraded
	name = "Upgraded Combat Vehicle"
	//deflect_chance = 20
	//damage_absorption = list("brute"=0.5,"fire"=1.1,"bullet"=0.65,"laser"=0.85,"energy"=0.9,"bomb"=0.8) //and move up to a durand

/obj/item/mech_component/chassis/cvrt
	name = "advanced CV-R systems"
	m_armour = /obj/item/robot_parts/robot_component/armour/exosuit/combat

/*/mob/living/exosuit/premade/cvrt/upgraded/New()
	..()
	var/obj/item/mech_equipment/ME = new /obj/item/mech_equipment/mounted_system/taser/laser/rapid
	ME.attach(src)
	ME = new /obj/item/mech_equipment/tool/passenger
	ME.attach(src)
	ME = new /obj/item/mech_equipment/tool/passenger
	ME.attach(src)
	ME = new /obj/item/mech_equipment/tool/passenger
	ME.attach(src)
	ME = new /obj/item/mech_equipment/tool/passenger
	ME.attach(src)*/

/obj/effect/decal/mecha_wreckage/cvrt
	name = "CVR wreckage"
	icon = 'icons/urist/vehicles/cvrt.dmi'
	bound_width = 64
	bound_height = 64
	icon_state = "cvrt-broken"

//ryclies

/mob/living/exosuit/premade/cvrt/ryclies
	icon_state = "rcvrt"
	//initial_icon = "rcvrt"
	wreckage_path = /obj/effect/decal/mecha_wreckage/rcvrt

/obj/effect/decal/mecha_wreckage/rcvrt
	name = "CVR wreckage"
	icon = 'icons/urist/vehicles/cvrt.dmi'
	bound_width = 64
	bound_height = 64
	icon_state = "rcvrt-broken"
