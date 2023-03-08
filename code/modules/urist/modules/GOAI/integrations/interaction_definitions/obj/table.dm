/obj/structure/table
	interaction_gen_enabled = TRUE

/obj/structure/table/GenerateInteractions()
	return GenerateGenericInteractions(src, /datum/interactions_holder/table)

/datum/interactions_holder/table
	action_paths = list(
		/datum/interaction/GenericClimb,
		/datum/interaction/TableFlip
		)

/datum/interaction/TableFlip
	action_path = /datum/goai/mob_commander/proc/HandleTableFlip
	base_cost = 20
	base_charges = 1
	action_types = list(ACT_MAKE_COVER, ACT_TABLE_FLIP)
	allowed_atom_types = ACT_TYPE_MOB
	allowed_user_types = ACT_TYPE_LIVING