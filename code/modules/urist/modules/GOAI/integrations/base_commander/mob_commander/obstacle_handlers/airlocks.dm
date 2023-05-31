//Returns action_key if handled and adds the appropriate actions
/datum/goai/mob_commander/proc/HandleAirlockObstruction(var/obj/machinery/door/airlock/A ,var/list/common_preconds = null, var/atom/pawn, var/list/handled_effects = null)
	if(!A || !pawn || !istype(A))
		return null

	if(!GOAI_CAN_TRAVERSE(A, pawn))
		OBSTACLE_DEBUG_LOG("[pawn] cannot traverse [A] [COORDS_TUPLE(A)]. Aborting.")
		return null

	var/action_key = null

	var/list/_common_preconds = (isnull(common_preconds) ? list() : common_preconds)
	var/list/open_door_preconds = _common_preconds.Copy()		//Any extra preconds are added here, and then passed back to the final appropriate open action
	var/list/base_preconds = _common_preconds.Copy()			//Preconditions that must be met for *all* future actions. ie, insulated gloves for shocked airlocks

	var/list/_handled_effects = (isnull(handled_effects) ? list() : handled_effects)

	var/needs_hack = FALSE

	//Get various airlock states from the brain's memories
	var/no_power = src.brain.GetMemoryValue(MEM_OBJ_NOPOWER(A), FALSE)
	var/is_bolted = src.brain.GetMemoryValue(MEM_OBJ_LOCKED(A), FALSE)
	var/panel_open = src.brain.GetMemoryValue(MEM_OBJ_PANELOPEN(A), FALSE)
	var/no_access = src.brain.GetMemoryValue(MEM_OBJ_NOACCESS(A), FALSE)

	//We're going to be doing multiple interaction checks here. It makes sense to grab the holder and use that, rather than constantly querying through the atom
	var/datum/interactions_holder/iholder = A.GetInteractionData(TRUE)
	if(!iholder)
		OBSTACLE_DEBUG_LOG("Could not find an interactions_holder for [A]")
		return null

	//*All* future interactions with this airlock will require gloves
	if(src.brain.GetMemoryValue(MEM_OBJ_SHOCKED(A), FALSE))
		base_preconds[STATE_HASINSULGLOVES] = TRUE
		open_door_preconds[STATE_HASINSULGLOVES] = TRUE


	//---- Prerequisite extra actions before attempting an open action ----//

	if(is_bolted)
		if(no_power)	//Bolted with no power. Just give up
			OBSTACLE_DEBUG_LOG("[A] is bolted with no power. Aborting")
			return null

		action_key = "[NEED_OBJ_UNLOCKED(A)]"

		var/list/extra_preconds = base_preconds.Copy()

		open_door_preconds[action_key] = TRUE	//Extra action key added to base open action

		extra_preconds[action_key] = FALSE

		var/datum/interaction/bolt_action = iholder.GetAction(pawn, list(ACT_AI_INTERACT, ACT_UNBOLT))
		//We have the ability to send an unbolt command to the airlock. No need to hack!
		if(bolt_action)
			OBSTACLE_DEBUG_LOG("[pawn] has ACT_AI_INTERACT. Queing AI unbolt command")
			var/list/effects = list()
			effects[action_key] = TRUE

			var/list/action_args = list()
			action_args["airlock"] = weakref(A)
			action_args["task"] = "bolt"
			action_args["active"] = FALSE

			AddAction(
				name = action_key,
				preconds = extra_preconds,
				effects = effects,
				handler = bolt_action.action_path,
				cost = bolt_action.base_cost,
				charges = bolt_action.base_charges,
				instant = FALSE,
				action_args = action_args
			)

		else
			var/datum/interaction/hack_action = iholder.GetAction(pawn, list(ACT_HACK, ACT_UNBOLT))
			if(!hack_action)
				OBSTACLE_DEBUG_LOG("[pawn] has no hack & unbolt action for [A]. Aborting.")
				return null

			//extra_preconds[STATE_HASMULTITOOL] = TRUE	//For debugging

			if(!panel_open)
				var/datum/interaction/screw_action = iholder.GetAction(pawn, ACT_SCREW)
				if(!screw_action)
					OBSTACLE_DEBUG_LOG("[pawn] has no screw action for [A]. Aborting.")
					return null

				var/panel_key = "[NEED_OBJ_SCREW(A)]"

				extra_preconds[panel_key] = TRUE

				AddAction(
					name = panel_key,
					preconds = list(
						"[panel_key]" = FALSE,
						//"[STATE_HASSCREWDRIVER]" = TRUE,	//Debug
						"[STATE_NEAR_ATOM(A)]" = TRUE
						),
					effects = list("[panel_key]" = TRUE),
					handler = screw_action.action_path,
					cost = screw_action.base_cost,
					charges = screw_action.base_charges,
					instant = FALSE,
					action_args = list("airlock" = weakref(A), "open" = TRUE)
				)

			OBSTACLE_DEBUG_LOG("[pawn] queued unbolt action(s) for [A]")

			var/list/effects = list()
			effects[action_key] = TRUE

			var/list/action_args = list()
			action_args["airlock"] = weakref(A)
			action_args["wires"] = list(AIRLOCK_WIRE_DOOR_BOLTS)
			action_args["cut"] = FALSE

			AddAction(
				name = action_key,
				preconds = extra_preconds,
				effects = effects,
				handler = hack_action.action_path,
				cost = hack_action.base_cost,
				charges = hack_action.base_charges,
				instant = FALSE,
				action_args = action_args
			)

			needs_hack = TRUE

	if(no_access && !no_power)
		var/datum/interaction/hack_action = iholder.GetAction(pawn, list(ACT_HACK, ACT_DEPOWER))
		if(!hack_action)
			OBSTACLE_DEBUG_LOG("[pawn] has no hack action for [A]. Aborting")
			return null

		if(!iholder.GetAction(pawn, list(ACT_PRY, ACT_TRAVERSE)))
			OBSTACLE_DEBUG_LOG("[pawn] has no pry action for [A] - It cannot hack. Aborting.")
			return null

		action_key = "[NEED_OBJ_DEPOWERED(A)]"

		var/list/extra_preconds = base_preconds.Copy()
		open_door_preconds[action_key] = TRUE	//Extra action key added to base open action

		extra_preconds[action_key] = FALSE

		var/list/effects = list()
		effects[action_key] = TRUE

		if(is_bolted)	//If it's bolted AND no access, we MUST unbolt the airlock first BEFORE cutting power
			extra_preconds["[NEED_OBJ_UNLOCKED(A)]"] = TRUE
		else if(!panel_open)	//else if, as if it's bolted, that action would already leave the panel open for us
			var/datum/interaction/screw_action = iholder.GetAction(pawn, ACT_SCREW)
			if(!screw_action)
				OBSTACLE_DEBUG_LOG("[pawn] has no screw action for [A]. Aborting.")
				return null

			var/panel_key = "[NEED_OBJ_SCREW(A)]"

			extra_preconds[panel_key] = TRUE

			AddAction(
				name = panel_key,
				preconds = list(
					"[panel_key]" = FALSE,
					//"[STATE_HASSCREWDRIVER]" = TRUE,	//Debug
					"[STATE_NEAR_ATOM(A)]" = TRUE
					),
				effects = list("[panel_key]" = TRUE),
				handler = screw_action.action_path,
				cost = screw_action.base_cost,
				charges = screw_action.base_charges,
				instant = FALSE,
				action_args = list("airlock" = weakref(A), "open" = TRUE)
			)

		var/list/action_args = list()

		action_args["airlock"] = weakref(A)
		action_args["wires"] = list(AIRLOCK_WIRE_MAIN_POWER1)
		action_args["cut"] = FALSE

		AddAction(
			name = action_key,
			preconds = extra_preconds,
			effects = effects,
			handler = hack_action.action_path,
			cost = hack_action.base_cost,
			charges = hack_action.base_charges,
			instant = FALSE,
			action_args = action_args
		)

		no_power = TRUE	//Now plan as if the airlock is unpowered
		needs_hack = TRUE

	if(panel_open && !no_power && !needs_hack)	//AttackHand/Bump doesn't not work if the panel is open. Close it first if we're not hacking the airlock and it has power
		var/datum/interaction/screw_action = iholder.GetAction(pawn, ACT_SCREW)
		if(!screw_action)
			OBSTACLE_DEBUG_LOG("[pawn] has no pry action for [A]. Aborting")
			return null

		action_key= "[NEED_OBJ_SCREW(A)]"

		var/list/extra_preconds = base_preconds.Copy()

		open_door_preconds[action_key] = TRUE

		extra_preconds[action_key] = FALSE
		//extra_preconds[STATE_HASSCREWDRIVER] = TRUE	//Debug

		var/list/effects = list()

		effects[action_key] = TRUE

		var/list/action_args = list()
		action_args["airlock"] = weakref(A)
		action_args["open"] = FALSE

		AddAction(
			name = action_key,
			preconds = extra_preconds,
			effects = effects,
			handler = screw_action.action_path,
			cost = screw_action.base_cost,
			charges = screw_action.base_charges,
			instant = FALSE,
			action_args = action_args
		)

	//---- Opening methods: Pick one ----//

	if(no_power)
		var/datum/interaction/pry_action = iholder.GetAction(pawn, list(ACT_PRY, ACT_TRAVERSE))
		if(!pry_action)
			OBSTACLE_DEBUG_LOG("[pawn] has no pry action for [A]. Aborting")
			return null

		action_key = "[NEED_OBJ_PRY(A)]"

		open_door_preconds[action_key] = FALSE
		//open_door_preconds[STATE_HASCROWBAR] = TRUE	//Debug

		var/list/effects = _handled_effects.Copy()
		effects[action_key] = TRUE

		var/list/action_args = list()
		action_args["airlock"] = weakref(A)
		action_args["open"] = TRUE

		AddAction(
			name = action_key,
			preconds = open_door_preconds,
			effects = effects,
			handler = pry_action.action_path,
			cost = pry_action.base_cost + DISTANCE_COST_ADJUSTMENT(pawn, A),
			charges = pry_action.base_charges,
			instant = FALSE,
			action_args = action_args
		)
	//Prying unpowered airlocks is an /alternative/ way of opening them, not a prerequisite step. We need an else here
	else
		if(no_access && !needs_hack)
			OBSTACLE_DEBUG_LOG("[A] could not be hacked by [pawn]. Aborting")
			return null

		var/datum/interaction/action = iholder.GetAction(pawn, ACT_OPEN)
		if(!action)
			OBSTACLE_DEBUG_LOG("[pawn] has no open action for [A]. Aborting")
			return null

		action_key = "[NEED_OBSTACLE_OPEN(A)]"
		open_door_preconds[action_key] = FALSE

		var/list/open_door_effects = _handled_effects.Copy()
		open_door_effects[action_key] = TRUE

		var/list/action_args = list()
		action_args["airlock"] = weakref(A)

		AddAction(
			name = action_key,
			preconds = open_door_preconds,
			effects = open_door_effects,
			handler = action.action_path,
			cost = action.base_cost + DISTANCE_COST_ADJUSTMENT(pawn, A),
			charges = action.base_charges,
			instant = FALSE,
			action_args = action_args
		)

	return action_key


/datum/goai/mob_commander/proc/HandleAirlockOpen(var/datum/ActionTracker/tracker, var/obj/machinery/door/airlock/airlock)
	var/mob/mob_pawn = src.GetPawn()
	if (!mob_pawn || !istype(mob_pawn) || !src.brain)
		tracker.SetFailed()
		return

	if (!tracker)
		return

	airlock = resolve_weakref(airlock)

	if(isnull(airlock))
		tracker.SetDone()
		return

	if(TimedOutWalkDist(tracker, mob_pawn, airlock))
		DropObstacleMemory(airlock)
		OBSTACLE_DEBUG_LOG("Tracker timed-out for [airlock] [COORDS_TUPLE(airlock)] open task")
		tracker.SetFailed()
		return

	//If the mob can see the airlock, check if its bolt lights are on
	if(airlock in src.brain.perceptions?[SENSE_SIGHT_CURR])
		if(airlock.locked && airlock.lights)
			tracker.SetFailed()
			src.brain.SetMemory(MEM_OBJ_LOCKED(airlock), TRUE, 5 MINUTES)
			DropObstacleMemory(airlock)
			OBSTACLE_DEBUG_LOG("Airlock [airlock] [COORDS_TUPLE(airlock)] is bolted - Failing open task")
			return
		if(airlock.p_open)
			tracker.SetFailed()
			src.brain.SetMemory(MEM_OBJ_PANELOPEN(airlock), TRUE, 5 MINUTES)
			DropObstacleMemory(airlock)
			OBSTACLE_DEBUG_LOG("Panel is open for [airlock] [COORDS_TUPLE(airlock)] - Failing open task")
			return

	if(!NavigateNextTo(tracker, mob_pawn, airlock))
		return

	if(airlock.density)
		//The mob is next to the airlock. Poke it and see what it learns

		var/fail_text

		if(airlock.locked)
			//Airlock won't open (bolted/unpowered). Add it to the memory and fail the tracker.
			src.brain.SetMemory(MEM_OBJ_LOCKED(airlock), TRUE, 5 MINUTES)
			fail_text = "is bolted"

		if(airlock.p_open)
			//The panel is open, but somehow our pawn didn't see it. Normal attack_hand()'s wouldn't work here. Fail
			src.brain.SetMemory(MEM_OBJ_PANELOPEN(airlock), TRUE, 5 MINUTES)
			fail_text = "has its panel open"

		if (!airlock.arePowerSystemsOn())
			src.brain.SetMemory(MEM_OBJ_NOPOWER(airlock), TRUE, 5 MINUTES)
			fail_text = "has no power"

		if(!airlock.allowed(mob_pawn))
			//No access to the airlock. Add it memory and fail the tracker. Still poke it though for that sweet sweet denied buzz
			src.brain.SetMemory(MEM_OBJ_NOACCESS(airlock), TRUE, MEM_TIME_LONGTERM) //Come back to this and change the ttl if changing IDs/access becomes a thing
			fail_text = "is access restricted"

		//This is hacky, but we'll call this manually so that we get the return from machinery/shock(),
		//There's a cooldown so calling it twice (once implicitly via attack_hand) shouldn't be an issue

		if(airlock.isElectrified())
			if(airlock.shock(mob_pawn, 100))
				src.brain.SetMemory(MEM_OBJ_SHOCKED(airlock), TRUE, MEM_TIME_LONGTERM)
				tracker.SetFailed()
				DropObstacleMemory(airlock)
				OBSTACLE_DEBUG_LOG("[airlock] [COORDS_TUPLE(airlock)] is electrified - Failing open task")
				return

		airlock.attack_hand(mob_pawn)

		if(fail_text)
			tracker.SetFailed()
			DropObstacleMemory(airlock)
			OBSTACLE_DEBUG_LOG("[airlock] [COORDS_TUPLE(airlock)] [fail_text] - Failing open task")
			return


	else
		//The airlock is open; walk into its turf
		var/turf/airlock_turf = get_turf(airlock)
		var/dist_to_obs = ChebyshevDistance(get_turf(mob_pawn), airlock_turf)

		if(dist_to_obs < 1)
			if(tracker.IsRunning())
				DropObstacleMemory(airlock)
				tracker.SetDone()
		else
			if(!tracker.BBGet("entering_door", FALSE))
				StartNavigateTo(airlock_turf, 0)
				tracker.BBSet("entering_door", TRUE)


/datum/goai/mob_commander/proc/HandleAirlockHack(var/datum/ActionTracker/tracker, var/obj/machinery/door/airlock/airlock, var/list/wires, var/cut)
	log_debug("Hack Airlock task for [airlock] ([airlock.x],[airlock.y]) - Wires: [wires] - Cut: [cut]")
	//TODO: Refactor this once we work out how we're going to handle inventory management (Actual pain)
	var/mob/mob_pawn = src.GetPawn()
	if (!mob_pawn || !istype(mob_pawn) || !src.brain)
		tracker.SetFailed()
		return

	airlock = resolve_weakref(airlock)

	if(isnull(airlock))
		tracker.SetDone()
		return

	if(airlock in src.brain.perceptions?[SENSE_SIGHT_CURR])
		if(!airlock.p_open)
			tracker.SetFailed()
			DropObstacleMemory(airlock)
			return

	var/datum/wires/airlock_wires = airlock.wires

	//Each wire attempt has a 5 second cooldown. So *max* this should take is 5*wire count, with some wriggle room for fixing wires + movement
	if(TimedOutWalkDist(tracker, mob_pawn, airlock, (airlock_wires.wire_count * 5 SECONDS) + 10 SECONDS))
		OBSTACLE_DEBUG_LOG("Hack task for [airlock] timed out!")
		DropObstacleMemory(airlock)
		tracker.SetFailed()
		return

	//We can't hack the airlock until we're next to it. Keep walking pal
	if(!NavigateNextTo(tracker, mob_pawn, airlock))
		return

	//5 second cooldown between hacks
	var/last_action = tracker.BBGet("LastAction", null)
	if(last_action && (world.time < last_action + 5 SECONDS))
		return

	var/list/wire_queue = tracker.BBGet("WireQueue", list())
	var/list/to_find = tracker.BBGet("TargetWires", wires.Copy())
	var/list/tried_wires = tracker.BBGet("TriedWires", list())
	var/list/known_wires = src.brain.GetMemoryValue(MEM_AIRLOCK_WIRES, list())

	//Someone's been here before us. Let's fix up everything first to give us a blank slate
	if(!length(tried_wires) && airlock_wires.wires_status)
		OBSTACLE_DEBUG_LOG("[airlock] previously hacked. Fixing wires.")
		for(var/wire in airlock_wires.wires)
			if(airlock_wires.IsColourCut(wire))
				wire_queue[wire] = "mend"
		tracker.BBSet("WireQueue", wire_queue)
		return

	//Process queued actions from the last tick
	if(length(wire_queue))
		var/wire = wire_queue[1]
		var/action = wire_queue[wire]
		var/is_cut = airlock_wires.IsColourCut(wire)
		wire_queue -= wire
		switch(action)
			if("cut_wire")
				OBSTACLE_DEBUG_LOG("Cutting wire [wire] for [airlock]")	//Temp debug logging
				if(!is_cut)
					airlock_wires.CutWireColour(wire)
			if("cut_and_mend")
				OBSTACLE_DEBUG_LOG("Cutting wire [wire] for [airlock]")
				if(!is_cut)
					airlock_wires.CutWireColour(wire)
				wire_queue[wire] = "mend_wire"
			if("mend_wire")
				OBSTACLE_DEBUG_LOG("Mending wire [wire] for [airlock]")
				if(is_cut)
					airlock_wires.CutWireColour(wire)
			if("pulse_wire")
				OBSTACLE_DEBUG_LOG("Pulsing wire [wire] for [airlock]")
				airlock_wires.PulseColour(wire)

		tracker.BBSet("WireQueue", wire_queue)
		tracker.BBSet("LastAction", world.time)
		return

	//There's nothing in the wire queue and no known wires to cut. If we've got nothing left to find, we're done!
	else if(!length(to_find))
		OBSTACLE_DEBUG_LOG("No wires left in hack queue. Complete")	//Temp
		tracker.SetDone()
		return

	//We know what wire we want, queue it up
	else if(to_find[1] in known_wires)
		var/target_effect = to_find[1]
		var/target_wire = known_wires[target_effect]
		OBSTACLE_DEBUG_LOG("Wire [target_wire] has previously known effect [target_effect]")
		wire_queue[target_wire] = cut ? "cut_wire" : "pulse_wire"
		to_find -= target_effect
		tracker.BBSet("WireQueue", wire_queue)
		tracker.BBSet("TargetWires", to_find)
		return

	//We've got unknown wires to find, and we have no idea what we're doing! Pulse and see what happens!
	else
		var/list/unknown_wires = airlock_wires.wires - tried_wires
		var/picked_wire = pick(unknown_wires)
		var/result = airlock_wires.wires[picked_wire]
		OBSTACLE_DEBUG_LOG("Pick random wire [picked_wire] for [airlock]. Effect: [result]")

		airlock_wires.PulseColour(picked_wire)

		if(result & (AIRLOCK_WIRE_MAIN_POWER1|AIRLOCK_WIRE_MAIN_POWER2))	//Much like players, we don't care *which* main power wire we find. Either one works. If for some weird reason AIRLOCK_MAIN_POWER2 was specified in to_find, and POWER1 was found, it'll get picked up next tick
			known_wires[AIRLOCK_WIRE_MAIN_POWER1] = picked_wire
			known_wires[AIRLOCK_WIRE_MAIN_POWER2] = picked_wire
		else if(result & (AIRLOCK_WIRE_BACKUP_POWER1|AIRLOCK_WIRE_BACKUP_POWER2))	//Same with backup power
			known_wires[AIRLOCK_WIRE_BACKUP_POWER1] = picked_wire
			known_wires[AIRLOCK_WIRE_BACKUP_POWER2] = picked_wire
		else
			known_wires[result] = picked_wire

		src.brain.SetMemory(MEM_AIRLOCK_WIRES, known_wires)

		if(result in to_find)
			OBSTACLE_DEBUG_LOG("Wanted result for [airlock]")
			if(cut)
				wire_queue[picked_wire] = "cut_wire"
			to_find -= result
			tracker.BBSet("TargetWires", to_find)
		else
			OBSTACLE_DEBUG_LOG("Unwanted result for [airlock]")
			wire_queue[picked_wire] = "cut_and_mend"
			tried_wires.Add(picked_wire)
			tracker.BBSet("TriedWires", tried_wires)

		tracker.BBSet("LastAction", world.time)

/datum/goai/mob_commander/proc/HandleAirlockAI()
	//todo
	return

/datum/goai/mob_commander/proc/HandleAirlockPanelScrew(var/datum/ActionTracker/tracker, var/obj/machinery/door/airlock/airlock, var/open)
	var/mob/living/mob_pawn = src.GetPawn()
	if(!istype(mob_pawn) || isnull(open) || !src.brain)
		tracker.SetFailed()
		return

	airlock = resolve_weakref(airlock)

	if(!istype(airlock))
		tracker.SetFailed()
		return

	if(TimedOutWalkDist(tracker, mob_pawn, airlock, 15 SECONDS))
		DropObstacleMemory(airlock)
		OBSTACLE_DEBUG_LOG("Tracker timed-out for [airlock] [COORDS_TUPLE(airlock)] panel screw task")
		return

	if(tracker.BBGet("InProgress", FALSE))
		return

	if(airlock in src.brain.perceptions?[SENSE_SIGHT_CURR] && airlock.p_open == open)
		tracker.SetDone()
		return

	if(!NavigateNextTo(tracker, mob_pawn, airlock))
		return

	tracker.BBSet("InProgress", TRUE)

	if(UseGenericTool(mob_pawn, airlock, "isscrewdriver", STATE_HASSCREWDRIVER))
		tracker.SetDone()
	else
		tracker.SetFailed()
		DropObstacleMemory(airlock)

/datum/goai/mob_commander/proc/HandleAirlockPryOpen(var/datum/ActionTracker/tracker, var/obj/machinery/door/airlock/airlock, var/open)
	var/mob/living/mob_pawn = src.GetPawn()
	if(!istype(mob_pawn) || isnull(open) || !src.brain)
		tracker.SetFailed()
		return

	airlock = resolve_weakref(airlock)

	if(isnull(airlock))
		tracker.SetDone()
		return
	else if(!istype(airlock))
		tracker.SetFailed()
		return

	if(TimedOutWalkDist(tracker, mob_pawn, airlock, 15 SECONDS))
		DropObstacleMemory(airlock)
		OBSTACLE_DEBUG_LOG("Tracker timed-out for [airlock] [COORDS_TUPLE(airlock)] pry open task")
		return

	if(tracker.BBGet("InProgress", FALSE))
		return

	if(airlock in src.brain.perceptions?[SENSE_SIGHT_CURR] && airlock.density != open)
		tracker.SetDone()
		return

	if(!NavigateNextTo(tracker, mob_pawn, airlock))
		return

	tracker.BBSet("InProgress", TRUE)

	var/used_tool = UseGenericTool(mob_pawn, airlock, "iscrowbar", STATE_HASCROWBAR)

	if(used_tool || isnull(used_tool))
		tracker.SetDone()
	else
		tracker.SetFailed()
		DropObstacleMemory(airlock)