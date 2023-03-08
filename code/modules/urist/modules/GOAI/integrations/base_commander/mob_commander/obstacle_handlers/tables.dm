/datum/goai/mob_commander/proc/HandleTableObstruction(var/obj/structure/table/table, var/list/common_preconds = null, var/atom/pawn, var/list/handled_effects = null)
	if(!table || !pawn || !istype(table))
		return null

	if(!GOAI_CAN_TRAVERSE(table, pawn))
		OBSTACLE_DEBUG_LOG("[pawn] cannot traverse [table] [COORDS_TUPLE(table)]. Aborting.")
		return null

	var/action_key = null

	var/list/_common_preconds = isnull(common_preconds) ? list() : common_preconds
	var/list/traverse_preconds = _common_preconds.Copy()

	var/list/_handled_effects = isnull(handled_effects) ? list() : handled_effects

	var/datum/interaction/climb_action = GOAI_GET_ACTION(table, pawn, ACT_CLIMB)

	if(!climb_action)
		OBSTACLE_DEBUG_LOG("[pawn] has no climb action for [table]. Aborting.")
		return null

	if(table.flipped)
		if(table.reinforced)
			return null

		var/datum/interaction/flip_action = GOAI_GET_ACTION(table, pawn, ACT_TABLE_FLIP)
		if(!flip_action)
			OBSTACLE_DEBUG_LOG("[pawn] has no table flip aciton. Aborting.")
			return null

		action_key = "[NEED_OBJ_FLIPPED(table)]"

		traverse_preconds[action_key] = TRUE

		var/list/preconds = _common_preconds.Copy()
		preconds[action_key] = FALSE

		var/list/effects = list()
		effects[action_key] = TRUE

		var/list/action_args = list()
		action_args["table"] = weakref(table)
		action_args["flip"] = FALSE

		AddAction(
			name = action_key,
			preconds = preconds,
			effects = effects,
			handler = flip_action.action_path,
			cost = flip_action.base_cost,
			charges = flip_action.base_charges,
			instant = FALSE,
			action_args = action_args
		)

	action_key = "[NEED_OBJ_CLIMB(table)]"

	traverse_preconds[action_key] = FALSE

	var/list/effects = _handled_effects.Copy()
	effects[action_key] = TRUE

	var/list/action_args = list()
	action_args["target"] = weakref(table)

	AddAction(
		name = action_key,
		preconds = traverse_preconds,
		effects = effects,
		handler = climb_action.action_path,
		cost = climb_action.base_cost + DISTANCE_COST_ADJUSTMENT(pawn, table),
		charges = climb_action.base_charges,
		instant = FALSE,
		action_args = action_args
	)

	return action_key

/datum/goai/mob_commander/proc/HandleTableFlip(var/datum/ActionTracker/tracker, var/obj/structure/table/table, var/flip = FALSE)
	var/mob/mob_pawn = src.GetPawn()
	if(!mob_pawn || !istype(mob_pawn))
		tracker.SetFailed()
		return

	table = resolve_weakref(table)

	if(isnull(table))
		tracker.SetDone()
		return

	if(table in src.brain.perceptions[SENSE_SIGHT_CURR])
		if(table.flipped == flip)
			tracker.SetDone()
			return

	if(TimedOutWalkDist(tracker, mob_pawn, table, 10 SECONDS))
		tracker.SetFailed()
		DropObstacleMemory(table)
		OBSTACLE_DEBUG_LOG("Tracker timed-out for [table] [COORDS_TUPLE(table)] flip task")
		return

	if(!NavigateNextTo(tracker, mob_pawn, table))
		return

	if(flip)
		if(!table.flip(get_cardinal_dir(mob_pawn, table)))
			tracker.SetFailed()
			OBSTACLE_DEBUG_LOG("Failed table flip proc for [table] [COORDS_TUPLE(table)]")
			DropObstacleMemory(table)
			return

		tracker.SetDone()
		mob_pawn.visible_message("<span class='warning'>[mob_pawn] flips \the [table]!</span>")

		if(table.atom_flags & ATOM_FLAG_CLIMBABLE)
			table.object_shaken()

	else
		if(!table.unflipping_check())
			tracker.SetFailed()
			OBSTACLE_DEBUG_LOG("Failed table unflipping check for [table] [COORDS_TUPLE(table)]")
			DropObstacleMemory(table)
			return
		table.unflip()
		tracker.SetDone()
		return
