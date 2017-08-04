/datum/map/wyrm

	holodeck_programs = list(
		"battle arena"       = new/datum/holodeck_program(/area/holodeck/source_battle_arena, list('sound/music/THUNDERDOME.ogg')),
		"surgery sim"          = new/datum/holodeck_program(/area/holodeck/source_surgery, list()),
		"turnoff"          = new/datum/holodeck_program(/area/holodeck/source_plating, list())
	)

	holodeck_supported_programs = list(

		"WyrmMainPrograms" = list(
			"Battle Arena"       = "battle arena",
			"Surgery Simulation" = "surgery sim"
		)

	)