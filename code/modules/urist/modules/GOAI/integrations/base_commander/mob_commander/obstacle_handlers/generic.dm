/datum/goai/mob_commander/proc/HandleGenericBreak(var/datum/ActionTracker/tracker, var/obj/target, var/method)
	var/mob/mob_pawn = src.GetPawn()
	if(!mob_pawn || !istype(mob_pawn))
		return

	if(!tracker)
		return

	target = resolve_weakref(target)

	if(TimedOutWalkDist(tracker, mob_pawn, target, (DEFAULT_ATTACK_COOLDOWN * 15)))
		tracker.SetFailed()
		DropObstacleMemory(target)
		OBSTACLE_DEBUG_LOG("Tracker timed-out for [target] [COORDS_TUPLE(target)] generic break task")
		return

	var/obj/machinery/M = target

	if(isnull(target))
		tracker.SetDone()
		return
	else if(istype(M) && M in src.brain.perceptions[SENSE_SIGHT_CURR] && (M.stat & BROKEN))
		tracker.SetDone()
		DropObstacleMemory(M)
		return

	//Cooldown check
	var/last_action = tracker.BBGet("LastAttack", null)
	if(last_action && (world.time < last_action + DEFAULT_ATTACK_COOLDOWN))
		return

	//See what's in the mob's hands
	var/obj/item/AH = mob_pawn.get_active_hand()
	var/obj/item/IH = mob_pawn.get_inactive_hand()
	var/obj/item/W = null

	//Select whatever actually is a weapon, and attack with that
	if(AH && !istool(AH) && !(AH.item_flags & ITEM_FLAG_NO_BLUDGEON))
		W = AH
	else if(IH && !istool(IH) && !(IH.item_flags & ITEM_FLAG_NO_BLUDGEON))
		W = IH
	else
		OBSTACLE_DEBUG_LOG("No available weapon for [target] [COORDS_TUPLE(target)] generic break task")
		tracker.SetFailed()
		DropObstacleMemory(target)

	target.attackby(W, mob_pawn)
	tracker.BBSet("LastAttack", world.time)

/datum/goai/mob_commander/proc/HandleGenericClimb(var/datum/ActionTracker/tracker, var/obj/target)
	var/mob/living/mob_pawn = src.GetPawn()
	if(!mob_pawn || !istype(mob_pawn))
		tracker.SetFailed()
		return

	target = resolve_weakref(target)

	if(isnull(target))
		tracker.SetDone()
		return
	else if(!istype(target))
		tracker.SetFailed()
		return

	if(TimedOutWalkDist(tracker, mob_pawn, target, (MOB_CLIMB_TIME_MEDIUM + 10)))
		tracker.SetFailed()
		DropObstacleMemory(target)
		OBSTACLE_DEBUG_LOG("Tracker timed-out for [target] [COORDS_TUPLE(target)] generic climb task")
		return

	if(!NavigateNextTo(tracker, mob_pawn, target))
		return

	if(tracker.BBGet("InProgress", FALSE))
		return

	tracker.BBSet("InProgress", TRUE)

	if(target.do_climb(mob_pawn))
		tracker.SetDone()
	else
		tracker.SetFailed()
		OBSTACLE_DEBUG_LOG("Failed do_climb proc for [target] [COORDS_TUPLE(target)]")