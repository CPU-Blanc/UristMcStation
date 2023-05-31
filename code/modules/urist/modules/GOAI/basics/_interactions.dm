# ifdef INTERACTIONS_DEBUG_LOGGING
# define INTERACTIONS_DEBUG_LOG(x) to_world_log("\[INTERACTIONS\] [x]")
# else
# define INTERACTIONS_DEBUG_LOG(x)
# endif


GLOBAL_LIST_EMPTY(goai_interactions)
GLOBAL_LIST_EMPTY(goai_interaction_holders)

//Action defines
# define ACT_OPEN "ActionOpen"
# define ACT_HACK "ActionHack"
# define ACT_PRY "ActionPry"
# define ACT_SCREW "ActionScrew"
# define ACT_TRAVERSE "ActionTraverse"
# define ACT_UNBOLT "ActionUnbolt"
# define ACT_DEPOWER "ActionDepower"
# define ACT_AI_INTERACT "ActionAiInteract"
# define ACT_CLIMB "ActionClimb"
# define ACT_TABLE_FLIP "ActionFlipTable"
# define ACT_MAKE_COVER "ActionMakeCover"
# define ACT_BREAK "ActionBreak"

// Helper macros
# define GOAI_GET_ACTION(Atom, Pawn, Action_types) (istype(Atom, /atom)) ? (Atom.GetInteractionData(TRUE)?.GetAction(Pawn,Action_types)) : null
# define GOAI_GET_ACTION_LOWCOST(Atom, Pawn, Action_types) (istype(Atom, /atom)) ? (Atom.GetInteractionData(TRUE)?.GetActionLowestCost(Pawn,Action_types)) : null
# define GOAI_GET_ACTION_LIST(Atom, Pawn, Action_types) (istype(Atom, /atom)) ? (Atom.GetInteractionData(TRUE)?.GetActionsList(Pawn,Action_types)) : list()
# define GOAI_CAN_TRAVERSE(Atom, Pawn) !isnull(GOAI_GET_ACTION(Atom,Pawn, ACT_TRAVERSE))


//This bitwise way of handling things didn't turn out as expected because of a dumb oversight. Might refactor this whole flag check thing into a proc call and allow /datum/interaction's to overload it ie. /datum/interaction/proc/CheckAllowed(var/atom)

//****====Action bitwise filter====****//

//Allowed atom types
# define ACT_TYPE_MOB				0x01
# define ACT_TYPE_OBJ				0x02
# define ACT_TYPE_AREA				0x04
# define ACT_TYPE_TURF				0x08
# define ACT_TYPE_ATOM_MOVEABLE		0x10
# define ACT_TYPE_ATOM				0xFF

//Mobs
# define ACT_TYPE_HUMANOID			0x0001		//Humanoid is for 'sentient' /human types *only*. It does not cover all types of /human (eg /human/monkey)
//Free space
# define ACT_TYPE_HUMAN				0x000F

# define ACT_TYPE_CYBORG			0x0010
# define ACT_TYPE_AI				0x0020
# define ACT_TYPE_SILICON			0x00F0

# define ACT_TYPE_ANIMAL			0x0F00

# define ACT_TYPE_LIVING			0x0FFF


//Objects. Stub
# define ACT_TYPE_ITEM				0x1


/datum/interactions_holder
	var/list/action_paths = null
	var/list/available_actions = null
	var/global/list/cached_types = list()

/datum/interactions_holder/New()
	available_actions = list()

	for(var/path in action_paths)
		if(ispath(path))
			var/datum/interaction/I = GLOB.goai_interactions[path]
			if(!I)
				I = new path
				GLOB.goai_interactions[path] = I
			available_actions.Add(I)

/**
 * Returns a list of `/datum/interaction` that are available to the specified filter(s).
 * If no `calling_atom` is provided, returns all interactions matching the provided `action_types` if specified.
 * If `action_types` is provided, returns interactions that match all `action_types` that the allowed atom/user flags allow, if `calling_atom` was specified.
 * If neither parameters are specified, returns *all* interactions under this holder.
 */
/datum/interactions_holder/proc/GetActionsList(var/atom/calling_atom = null, var/list/action_types = null, var/break_on_first = FALSE)
	if(action_types && !islist(action_types))
		action_types = list(action_types)

	var/list/candidate_actions = list()

	var/datum/Tuple/data = GetUserFilter(calling_atom)
	var/atom_type = data?.left
	var/user_filter = data?.right

	# ifdef INTERACTIONS_DEBUG_LOGGING
	if(!isnull(calling_atom))
		INTERACTIONS_DEBUG_LOG("[src]: Atom [calling_atom] - atom_type: [atom_type] - user_filter: [user_filter]")
	# endif

	for(var/datum/interaction/I in available_actions)
		if(!action_types || AND_list_keys(action_types, I.action_types))
			if(!calling_atom)
				candidate_actions |= I
				INTERACTIONS_DEBUG_LOG("[src]: Passed check for [I] (No atom filter)")
				if(break_on_first)
					break
				continue

			if(!isnull(I.allowed_atom_types) && (I.allowed_atom_types & atom_type))
				if(isnull(I.allowed_user_types) || (I.allowed_user_types & user_filter))
					INTERACTIONS_DEBUG_LOG("[src]: Passed check for [I]")
					candidate_actions |= I
					if(break_on_first)
						break

	return candidate_actions

/**
 * Returns the first available `/datum/interaction` within this holder available for `calling_atom`
 */
/datum/interactions_holder/proc/GetAction(var/atom/calling_atom = null, var/list/action_types = null)
	var/list/actions = GetActionsList(calling_atom, action_types, TRUE)

	if(length(actions))
		return actions[1]
	else
		return null

/**
 * Returns the `/datum/interaction` with the lowest `base_cost` available within this holder for `calling_atom` with the specified `action_types`
 */
/datum/interactions_holder/proc/GetActionLowestCost(var/atom/calling_atom = null, var/list/action_types = null)
	var/list/actions = GetActionsList(calling_atom, action_types)

	var/datum/interaction/current_candidate = null

	for(var/datum/interaction/action in actions)
		if(!current_candidate)
			current_candidate = action
			continue

		if(action.base_cost < current_candidate.base_cost)
			current_candidate = action

	return current_candidate

/datum/interactions_holder/proc/GetUserFilter(var/atom/user)
	if(!user)
		return

	//assoc lists go brr
	var/datum/Tuple/data = cached_types[user.type]

	if(data)
		INTERACTIONS_DEBUG_LOG("[src]: Retrieved cached filter for type [user.type]")
		return data

	var/filter = 0
	var/atom_type = 0

	if(ismob(user))
		atom_type = ACT_TYPE_MOB

		if(isliving(user))
			if(ishuman(user))
				if(ishumanoid(user))
					filter |= ACT_TYPE_HUMANOID
				else
					filter |= ACT_TYPE_HUMAN

			else if(issilicon(user))
				if(isAI(user))
					filter |= ACT_TYPE_AI
				else
					filter |= ACT_TYPE_SILICON

			else if(isanimal(user))
				filter |= ACT_TYPE_ANIMAL

			else
				filter |= ACT_TYPE_LIVING

	else if(isobj(user))
		atom_type = ACT_TYPE_OBJ

	else if(isturf(user))
		atom_type = ACT_TYPE_TURF

	else if(isarea(user))
		atom_type = ACT_TYPE_AREA

	if(ismovable(user))
		atom_type |= ACT_TYPE_ATOM_MOVEABLE

	data = new(atom_type, filter)
	cached_types[user.type] = data
	return data

/datum/interaction
	var/action_path = null
	var/base_cost = 0
	var/base_charges = 1
	var/list/action_types = null
	var/allowed_atom_types = 0
	var/allowed_user_types = 0
	var/list/base_preconds = null
	var/list/base_effects = null

/atom/proc/GenerateInteractions()
	//by default
	return null

/atom/proc/GetInteractionData(var/generate_if_missing = FALSE, var/log_on_missing = FALSE)
	var/datum/interactions_holder/holder = src.interactions_holder

	if(!holder)
		if(src.interaction_gen_enabled)
			if(generate_if_missing)
				holder = GenerateInteractions()
				src.interactions_holder = holder

			if(log_on_missing)
				to_world_log("Failed to get interaction data for [src] - no interaction data!")

		//Climbable atoms are -everywhere- and would require SO many unique holders. This will ensure *all* climbable atoms have a climb interaction, either their own as defined above, or the generic one appended to their holder or in a newly generated one.
		if(src.atom_flags & ATOM_FLAG_CLIMBABLE)
			if(!holder)
				holder = GenerateGenericInteractions(src, /datum/interactions_holder/ClimbHolder)
				src.interactions_holder = holder
			else if(!holder.GetAction(null, ACT_CLIMB))
				var/datum/interaction/climb = GLOB.goai_interactions[/datum/interaction/GenericClimb]
				if(!climb)
					climb = new /datum/interaction/GenericClimb
					GLOB.goai_interactions[/datum/interaction/GenericClimb] = climb
				holder.available_actions.Add(climb)

	return holder