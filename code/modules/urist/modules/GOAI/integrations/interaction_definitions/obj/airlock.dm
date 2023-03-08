/obj/machinery/door/airlock
	interaction_gen_enabled = TRUE

/obj/machinery/door/airlock/GenerateInteractions()
	return GenerateGenericInteractions(src, /datum/interactions_holder/airlock)


/datum/interactions_holder/airlock
	action_paths = list(
		/datum/interaction/AirlockOpen,
		/datum/interaction/AirlockHack,
		/datum/interaction/AirlockScrewPanel,
		/datum/interaction/AirlockPryOpen,
		/datum/interaction/AirlockAiInteract
		)

/datum/interaction/AirlockOpen
	action_path = /datum/goai/mob_commander/proc/HandleAirlockOpen
	base_cost = 5
	base_charges = 1
	action_types = list(ACT_OPEN, ACT_TRAVERSE)
	allowed_atom_types = ACT_TYPE_MOB
	allowed_user_types = ACT_TYPE_LIVING

/datum/interaction/AirlockHack
	action_path = /datum/goai/mob_commander/proc/HandleAirlockHack
	base_cost = 200
	base_charges = 1
	action_types = list(ACT_HACK, ACT_UNBOLT)
	allowed_atom_types = ACT_TYPE_MOB
	allowed_user_types = ACT_TYPE_HUMANOID

/datum/interaction/AirlockAiInteract
	action_path = /datum/goai/mob_commander/proc/HandleAirlockAI
	base_cost = 5
	base_charges = 1
	action_types = list(ACT_AI_INTERACT, ACT_UNBOLT)
	allowed_atom_types = ACT_TYPE_MOB
	allowed_user_types = ACT_TYPE_SILICON

/datum/interaction/AirlockScrewPanel
	action_path = /datum/goai/mob_commander/proc/HandleAirlockPanelScrew
	base_cost = 5
	base_charges = 1
	action_types = list(ACT_SCREW)
	allowed_atom_types = ACT_TYPE_MOB
	allowed_user_types = ACT_TYPE_HUMANOID

/datum/interaction/AirlockPryOpen
	action_path = /datum/goai/mob_commander/proc/HandleAirlockPryOpen
	base_cost = 15
	base_charges = 1
	action_types = list(ACT_PRY, ACT_TRAVERSE)
	allowed_atom_types = ACT_TYPE_MOB
	allowed_user_types = ACT_TYPE_HUMANOID