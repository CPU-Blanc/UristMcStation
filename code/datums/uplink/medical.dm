/**********
* Medical *
**********/
/datum/uplink_item/item/medical
	category = /datum/uplink_category/medical

/datum/uplink_item/item/medical/sinpockets
	name = "Box of Sin-Pockets"
	item_cost = 8
	path = /obj/item/weapon/storage/box/sinpockets

/datum/uplink_item/item/medical/surgery
	name = "Surgery kit"
	item_cost = 32  // Lowered for Solo/Duo Traitors.
	antag_costs = list(MODE_MERCENARY = 40)
	path = /obj/item/weapon/storage/firstaid/surgery

/datum/uplink_item/item/medical/combat
	name = "Combat medical kit"
	item_cost = 36 // Lowered, for traitors.
	antag_costs = list(MODE_MERCENARY = 48)
	path = /obj/item/weapon/storage/firstaid/combat
