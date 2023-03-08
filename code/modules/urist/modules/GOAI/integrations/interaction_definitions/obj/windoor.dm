/obj/machinery/door/window
	interaction_gen_enabled = TRUE

/obj/machinery/door/window/GenerateInteractions()
	return GenerateGenericInteractions(src, /datum/interactions_holder/windoor)

/datum/interactions_holder/windoor
	action_paths = list(
		/datum/interaction/WindoorOpen,
		/datum/interaction/GenericBreakTraversal
	)

/datum/interaction/WindoorOpen
	action_path = /datum/goai/mob_commander/proc/HandleWindoorOpen
	base_cost = 10
	base_charges = 1
	action_types = list(ACT_OPEN, ACT_TRAVERSE)
	allowed_atom_types = ACT_TYPE_MOB
	allowed_user_types = ACT_TYPE_LIVING