//Items labled as 'trash' for the trash bag.
//TODO: Make this an item var or something...

//Added by Jack Rost
/obj/item/trash
	icon = 'icons/obj/trash.dmi'
	w_class = ITEM_SIZE_SMALL
	desc = "This is rubbish."
	var/age = 0

/obj/item/trash/New(var/newloc, var/_age)
	..(newloc)
	if(!isnull(_age))
		age = _age

/obj/item/trash/Initialize()
	SSpersistence.track_value(src, /datum/persistent/filth/trash)
	. = ..()

/obj/item/trash/Destroy()
	SSpersistence.forget_value(src, /datum/persistent/filth/trash)
	. = ..()

/obj/item/trash/raisins
	name = "\improper 4no raisins"
	icon_state = "4no_raisins"

/obj/item/trash/candy
	name = "candy"
	icon_state = "candy"

/obj/item/trash/candy/proteinbar
	name = "protein bar"
	icon_state = "proteinbar"

/obj/item/trash/cheesie
	name = "\improper Cheesie Honkers"
	icon_state = "cheesie_honkers"

/obj/item/trash/chips
	name = "chips"
	icon_state = "chips"

/obj/item/trash/popcorn
	name = "popcorn"
	icon_state = "popcorn"

/obj/item/trash/sosjerky
	name = "Scaredy's Private Reserve Beef Jerky"
	icon_state = "sosjerky"

/obj/item/trash/syndi_cakes
	name = "syndi cakes"
	icon_state = "syndi_cakes"

/obj/item/trash/waffles
	name = "waffles"
	icon_state = "waffles"

/obj/item/trash/plate
	name = "plate"
	icon_state = "plate"

/obj/item/trash/snack_bowl
	name = "snack bowl"
	icon_state	= "snack_bowl"

/obj/item/trash/pistachios
	name = "pistachios pack"
	icon_state = "pistachios_pack"

/obj/item/trash/semki
	name = "semki pack"
	icon_state = "semki_pack"

/obj/item/trash/caviar
	name = "caviar can"
	icon_state = "fisheggs_can"

/obj/item/trash/salo
	name = "salo pack"
	icon_state = "salo"

/obj/item/trash/croutons
	name = "suhariki pack"
	icon_state = "croutons"

/obj/item/trash/squid
	name = "calamari pack"
	icon_state = "squid"

/obj/item/trash/driedfish
	name = "vobla pack"
	icon_state = "driedfish"

/obj/item/trash/tray
	name = "tray"
	icon_state = "tray"

/obj/item/trash/candle
	name = "candle"
	icon = 'icons/obj/candle.dmi'
	icon_state = "candle4"

/obj/item/trash/liquidfood
	name = "\improper \"LiquidFood\" MRE"
	icon_state = "liquidfood"

/obj/item/trash/tastybread
	name = "bread tube"
	icon_state = "tastybread"

/obj/item/trash/onigiri
	name = "onigiri remains"
	icon = 'icons/urist/items/uristtrash.dmi'
	icon_state = "onigiri-trash"

/obj/item/trash/ramenbowl
	name = "empty ramen bowl"
	icon = 'icons/urist/items/uristtrash.dmi'
	icon_state = "ramen-trash"

/obj/item/trash/skewers
	name = "empty skewers"
	icon = 'icons/urist/items/uristtrash.dmi'
	icon_state = "yakidango-trash"

/obj/item/trash/surpriseonigiri
	name = "surprise pack"
	icon = 'icons/urist/items/uristtrash.dmi'
	icon_state = "surprise-o"

/obj/item/trash/attack(mob/M as mob, mob/living/user as mob)
	return

/obj/item/trash/usedplatter
	name = "dirty platter"
	icon_state = "usedplatter"