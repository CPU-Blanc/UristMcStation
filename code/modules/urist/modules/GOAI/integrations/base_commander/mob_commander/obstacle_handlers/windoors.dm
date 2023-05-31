//Returns action_key if handled and adds the appropriate action
/datum/goai/mob_commander/proc/HandleWindoorObstruction(var/obj/machinery/door/window/WD, var/list/common_preconds = null, var/atom/pawn, var/list/handled_effects = null)
	if(!WD || !pawn || !istype(WD))
		return null

	if(!GOAI_CAN_TRAVERSE(WD, pawn))
		OBSTACLE_DEBUG_LOG("[pawn] cannot traverse [WD] [COORDS_TUPLE(WD)]. Aborting.")
		return null

	var/action_key = null

	var/list/_common_preconds = (isnull(common_preconds) ? list() : common_preconds)
	var/list/open_windoor_preconds = _common_preconds.Copy()

	var/list/_handled_effects = (isnull(handled_effects) ? list() : handled_effects)

	if(src.brain.GetMemoryValue(MEM_OBJ_NOACCESS(WD), null))
		var/datum/interaction/break_action = GOAI_GET_ACTION(WD, pawn, list(ACT_BREAK, ACT_TRAVERSE))
		if(!break_action)
			OBSTACLE_DEBUG_LOG("[pawn] has no break-traverse action for [WD]. Aborting.")
			return

		action_key = "[NEED_OBJ_BROKEN(WD)]"
		open_windoor_preconds[action_key] = -TRUE
		src.SetState(action_key, FALSE)	//Workaround

		var/list/effects = _handled_effects.Copy()
		effects[action_key] = TRUE

		var/list/action_args = list()
		action_args["target"] = weakref(WD)
		action_args["method"] = "brute"

		AddAction(
			name = action_key,
			preconds = open_windoor_preconds,
			effects = effects,
			handler = break_action.action_path,
			cost = break_action.base_cost + rand() + (pawn ? get_dist(WD, pawn) : 0),
			charges = break_action.base_charges,
			instant = FALSE,
			action_args = action_args
		)

	else
		var/datum/interaction/open_action = GOAI_GET_ACTION(WD, pawn, ACT_OPEN)
		if(!open_action)
			OBSTACLE_DEBUG_LOG("[pawn] has no open action for [WD]. Aborting.")
			return

		action_key = "[NEED_OBSTACLE_OPEN(WD)]"
		open_windoor_preconds[action_key] = -TRUE
		src.SetState(action_key, FALSE)	//Workaround

		var/list/effects = _handled_effects.Copy()
		effects[action_key] = TRUE

		var/list/action_args = list()
		action_args["obstruction"] = weakref(WD)

		AddAction(
			name = action_key,
			preconds = open_windoor_preconds,
			effects = effects,
			handler = open_action.action_path,
			cost = open_action.base_cost + DISTANCE_COST_ADJUSTMENT(pawn, WD),
			charges = open_action.base_charges,
			instant = FALSE,
			action_args = action_args
		)
	return action_key


/datum/goai/mob_commander/proc/HandleWindoorOpen(var/datum/ActionTracker/tracker, var/obj/machinery/door/window/WD)
	var/mob/mob_pawn = src.GetPawn()
	if (!mob_pawn || !istype(mob_pawn) || !src.brain)
		return

	if (!tracker)
		return

	WD = resolve_weakref(WD)

	if(isnull(WD))
		tracker.SetDone()
		DropObstacleMemory(WD)
		return
	else if(!istype(WD))
		tracker.SetFailed()
		return

	if(TimedOutWalkDist(tracker, mob_pawn, WD))
		DropObstacleMemory(WD)
		OBSTACLE_DEBUG_LOG("Tracker timed-out for [WD] [COORDS_TUPLE(WD)] open task")
		tracker.SetFailed()
		return

	if(!NavigateNextTo(tracker, mob_pawn, WD))
		return

	if(WD.density)
		WD.attack_hand(mob_pawn)
		if(!WD.allowed(mob_pawn))
			tracker.SetFailed()
			src.brain.SetMemory(MEM_OBJ_NOACCESS(WD), TRUE)
			DropObstacleMemory(WD)
			OBSTACLE_DEBUG_LOG("Open windoor task failed for [WD] [COORDS_TUPLE(WD)] - Access denied")
			return

	else
		var/turf/pawn_turf = get_turf(mob_pawn)
		var/turf/windoor_turf = get_turf(WD)
		var/turf/end_turf = WD.dir & get_dir(pawn_turf, windoor_turf) ? get_step(WD, WD.dir) : windoor_turf

		var/dist_to_target = ChebyshevDistance(pawn_turf, end_turf)
		if(dist_to_target < 1)
			if(tracker.IsRunning())
				DropObstacleMemory(WD)
				tracker.SetDone()
				WD.attack_hand(mob_pawn)	//Windoors don't auto-close. Let's be polite and close it after us
		else if(!tracker.BBGet("entering_door", FALSE))
			StartNavigateTo(end_turf, 0)
			tracker.BBSet("entering_door", TRUE)