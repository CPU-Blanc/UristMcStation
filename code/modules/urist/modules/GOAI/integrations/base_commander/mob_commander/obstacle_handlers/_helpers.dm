//These are for actions that only really need to be defined once and used in many different handlers, but might need extra checks done inside a handler. These should all be called within a handler with an existing tracker, and passed any required parameters

/**
 * Checks if `pawn` is next to `target`, if not, starts navigation to it. Returns `TRUE` on completed navigation, `FALSE` if navigation is still in progress
 */
/datum/goai/mob_commander/proc/NavigateNextTo(var/datum/ActionTracker/tracker, var/atom/pawn, var/atom/target)
	if(!tracker || !pawn || !target)
		return

	var/turf/target_turf = get_turf(target)

	if(ChebyshevDistance(get_turf(pawn), target_turf) >= 2)
		var/list/path_to_target = tracker.BBGet("PathToTarget", null)
		if(isnull(path_to_target) || !src.active_path)
			path_to_target = StartNavigateTo(target_turf, 1)
			tracker.BBSet("PathToTarget", path_to_target)
		return FALSE

	return TRUE

/**
 * Checks if the tracker has timed-out, taking walking distance and tick delay into account. Takes an optional `additional_delay` arguement to allow for custom time-out durations
 */
/datum/goai/mob_commander/proc/TimedOutWalkDist(var/datum/ActionTracker/tracker, var/atom/pawn, var/atom/target, var/additional_delay = 0)
	if(!tracker || !pawn || !target)
		return

	var/walk_dist = tracker.BBSetDefault("StartDist", (ManhattanDistance(get_turf(pawn), target) || 0)) || 0

	if(tracker.IsOlderThan(src.ai_tick_delay * (10 + walk_dist + additional_delay)))
		return TRUE

	return FALSE

/**
 * Checks if `obstacle` is present in the brain's waypoint obstruction memory. Drops it if it matches
 */
/datum/goai/mob_commander/proc/DropObstacleMemory(var/atom/obstacle)
	if(!obstacle || !src.brain)
		return

	if(resolve_weakref(src.brain.GetMemoryValue(MEM_OBSTRUCTION("WAYPOINT"), null)) == obstacle)
		src.brain.DropMemory(MEM_OBSTRUCTION("WAYPOINT"))

/**
 * Searches for a tool that passes `obj.[checkProcName]()` within `mob_pawn`'s contents, then uses it on `target`. If an obj that passes cannot be found and `toolState` is defined, that state key will be set to `FALSE`. Returns `TRUE` on success, `FALSE` on fail, `null` if `target` is null
 * This should always behind some sort of BB InProgress check, as some actions use do_after() and can last multiple ticks
 */
/datum/goai/mob_commander/proc/UseGenericTool(var/mob/living/mob_pawn, var/obj/target, var/checkProcName, var/toolState)
	if(!istype(mob_pawn) || !checkProcName)
		return FALSE

	if(!target)
		return

	//proper inventory check for tools here when we do that?
	var/obj/item/tool
	for(var/obj/item/I in mob_pawn.get_contents())
		if(!hascall(I, checkProcName))	//Something is very wrong. Log it.
			log_error("Invalid proc name provided during UseGenericTool: atom: [I] - proc name: [checkProcName]")
			continue

		if(call(I, checkProcName)())
			tool = I
			break


	if(!tool)
		if(toolState)
			src.brain.SetState(toolState, FALSE)
		return	FALSE

	target.attackby(tool, mob_pawn)

	return TRUE