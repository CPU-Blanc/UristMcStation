/datum/gear/accessory
	display_name = "black vest"
	path = /obj/item/clothing/accessory/toggleable/vest
	slot = slot_tie
	sort_category = "Accessories"

/datum/gear/accessory/suspenders
	display_name = "suspenders"
	path = /obj/item/clothing/accessory/suspenders

/datum/gear/accessory/wcoat
	display_name = "waistcoat"
	path = /obj/item/clothing/accessory/wcoat

/datum/gear/accessory/necklace
	display_name = "necklace"
	path = /obj/item/clothing/accessory/necklace
	flags = GEAR_HAS_COLOR_SELECTION

/datum/gear/accessory/armband
	display_name = "armband selection"
	path = /obj/item/clothing/accessory/armband

/datum/gear/accessory/armband/New()
	..()
	var/armbands = list()
	armbands["red armband"] = /obj/item/clothing/accessory/armband
	armbands["cargo armband"] = /obj/item/clothing/accessory/armband/cargo
	armbands["EMT armband"] = /obj/item/clothing/accessory/armband/medgreen
	armbands["medical armband"] = /obj/item/clothing/accessory/armband/med
	armbands["engineering armband"] = /obj/item/clothing/accessory/armband/engine
	armbands["hydroponics armband"] = /obj/item/clothing/accessory/armband/hydro
	armbands["science armband"] = /obj/item/clothing/accessory/armband/science
	gear_tweaks += new/datum/gear_tweak/path(armbands)

/datum/gear/accessory/wallet
	display_name = "wallet"
	path = /obj/item/weapon/storage/wallet
	flags = GEAR_HAS_COLOR_SELECTION

/datum/gear/accessory/wallet_poly
	display_name = "wallet, polychromic"
	path = /obj/item/weapon/storage/wallet/poly
	cost = 2

/datum/gear/accessory/holster
	display_name = "holster selection"
	path = /obj/item/clothing/accessory/holster
	allowed_roles = list(/datum/job/captain, /datum/job/hop, /datum/job/officer, /datum/job/warden, /datum/job/hos, /datum/job/detective, /datum/job/blueshield)

/datum/gear/accessory/holster/New()
	..()
	gear_tweaks += new/datum/gear_tweak/path(/obj/item/clothing/accessory/holster)

/datum/gear/accessory/tie
	display_name = "tie selection"
	path = /obj/item/clothing/accessory
	flags = GEAR_HAS_COLOR_SELECTION

/datum/gear/accessory/stethoscope
	display_name = "stethoscope (medical)"
	path = /obj/item/clothing/accessory/stethoscope
	allowed_roles = list(/datum/job/doctor,/datum/job/cmo)

/datum/gear/accessory/brown_vest
	display_name = "webbing, engineering"
	path = /obj/item/clothing/accessory/storage/brown_vest
	allowed_roles = list(/datum/job/engineer,/datum/job/chief_engineer)

/datum/gear/accessory/black_vest
	display_name = "webbing, security"
	path = /obj/item/clothing/accessory/storage/black_vest
	allowed_roles = list(/datum/job/officer,/datum/job/hos,/datum/job/warden)

/datum/gear/accessory/white_vest
	display_name = "webbing, medical"
	path = /obj/item/clothing/accessory/storage/white_vest
	allowed_roles = list(/datum/job/cmo,/datum/job/doctor)

/datum/gear/accessory/brown_drop_pouches
	display_name = "drop pouches, engineering"
	path = /obj/item/clothing/accessory/storage/drop_pouches/brown
	allowed_roles = list(/datum/job/engineer,/datum/job/chief_engineer)

/datum/gear/accessory/black_drop_pouches
	display_name = "drop pouches, security"
	path = /obj/item/clothing/accessory/storage/drop_pouches/black
	allowed_roles = list(/datum/job/officer,/datum/job/hos,/datum/job/warden)

/datum/gear/accessory/white_drop_pouches
	display_name = "drop pouches, medical"
	path =/obj/item/clothing/accessory/storage/drop_pouches/white
	allowed_roles = list(/datum/job/cmo,/datum/job/doctor)

/datum/gear/accessory/webbing
	display_name = "webbing, simple"
	path = /obj/item/clothing/accessory/storage/webbing
	cost = 2

/datum/gear/accessory/hawaii
	display_name = "hawaii shirt"
	path = /obj/item/clothing/accessory/toggleable/hawaii

/datum/gear/accessory/hawaii/New()
	..()
	var/list/shirts = list()
	shirts["blue hawaii shirt"] = /obj/item/clothing/accessory/toggleable/hawaii
	shirts["red hawaii shirt"] = /obj/item/clothing/accessory/toggleable/hawaii/red
	shirts["random colored hawaii shirt"] = /obj/item/clothing/accessory/toggleable/hawaii/random
	gear_tweaks += new/datum/gear_tweak/path(shirts)

/datum/gear/accessory/scarf
	display_name = "scarf"
	path = /obj/item/clothing/accessory/scarf
	flags = GEAR_HAS_COLOR_SELECTION

/datum/gear/accessory/locket
	display_name = "locket"
	path = /obj/item/clothing/accessory/locket

/datum/gear/accessory/ubac
	display_name = "ubac selection"
	path = /obj/item/clothing/accessory/ubac

/datum/gear/accessory/ubac/New()
	..()
	var/ubac = list()
	ubac["black ubac"] = /obj/item/clothing/accessory/ubac
	ubac["tan ubac"] = /obj/item/clothing/accessory/ubac/tan
	ubac["green ubac"] = /obj/item/clothing/accessory/ubac/green
	gear_tweaks += new/datum/gear_tweak/path(ubac)

/datum/gear/accessory/dashiki
	display_name = "dashiki selection"
	path = /obj/item/clothing/accessory/dashiki

/datum/gear/accessory/dashiki/New()
	..()
	var/dashiki = list()
	dashiki["black dashiki"] = /obj/item/clothing/accessory/dashiki
	dashiki["red dashiki"] = /obj/item/clothing/accessory/dashiki/red
	dashiki["blue dashiki"] = /obj/item/clothing/accessory/dashiki/blue
	gear_tweaks += new/datum/gear_tweak/path(dashiki)

/datum/gear/accessory/colourtop
	display_name = "colourable tops selection"
	path = /obj/item/clothing/accessory/sweater
	flags = GEAR_HAS_COLOR_SELECTION

/datum/gear/accessory/colourtop/New()
	..()
	var/colourtop = list()
	colourtop["turtleneck sweater"] = /obj/item/clothing/accessory/sweater
	colourtop["qipao"] = /obj/item/clothing/accessory/qipao
	colourtop["sherwani"] = /obj/item/clothing/accessory/sherwani
	gear_tweaks += new/datum/gear_tweak/path(colourtop)
