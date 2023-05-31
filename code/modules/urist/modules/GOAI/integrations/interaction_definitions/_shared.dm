/proc/GenerateGenericInteractions(var/atom/owner =  null, var/datum_path = null)
	if(!owner || !datum_path)
		return

	var/datum/interactions_holder/holder = GLOB.goai_interaction_holders[owner.type]

	if(!holder)
		if(ispath(datum_path))
			holder = new datum_path
			GLOB.goai_interaction_holders[owner.type] = holder

	return holder

/datum/interactions_holder/ClimbHolder
	action_paths = list(/datum/interaction/GenericClimb)


/datum/interaction/GenericClimb
	action_path = /datum/goai/mob_commander/proc/HandleGenericClimb
	base_cost = 15
	base_charges = 1
	action_types = list(ACT_CLIMB, ACT_TRAVERSE)
	allowed_atom_types = ACT_TYPE_MOB
	allowed_user_types = ACT_TYPE_HUMAN|ACT_TYPE_ANIMAL

/datum/interaction/GenericBreak
	action_path = /datum/goai/mob_commander/proc/HandleGenericBreak
	base_cost = 300
	base_charges = 1
	action_types = list(ACT_BREAK)
	allowed_atom_types = ACT_TYPE_MOB
	allowed_user_types = ACT_TYPE_HUMAN

/datum/interaction/GenericBreakTraversal
	action_path = /datum/goai/mob_commander/proc/HandleGenericBreak
	base_cost = 300
	base_charges = 1
	action_types = list(ACT_BREAK, ACT_TRAVERSE)
	allowed_atom_types = ACT_TYPE_MOB
	allowed_user_types = ACT_TYPE_HUMAN