/obj/machinery/pipedispenser
	name = "Pipe Dispenser"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "pipe_d"
	density = TRUE
	anchored = TRUE
	use_power = NO_POWER_USE // i see no point in that, better implement battery feature.
	allowed_checks = ALLOWED_CHECK_TOPIC
	var/unwrenched = 0
	var/wait = 0
	required_skills = list(/datum/skill/atmospherics = SKILL_LEVEL_TRAINED)

/obj/machinery/pipedispenser/ui_interact(user)
	var/dat = {"
		<b>Regular pipes:</b><BR>
		<A href='byond://?src=\ref[src];make=0;dir=1'>Pipe</A><BR>
		<A href='byond://?src=\ref[src];make=1;dir=5'>Bent Pipe</A><BR>
		<A href='byond://?src=\ref[src];make=5;dir=1'>Manifold</A><BR>
		<A href='byond://?src=\ref[src];make=8;dir=1'>Manual Valve</A><BR>
		<A href='byond://?src=\ref[src];make=9;dir=1'>Digital Valve</A><BR>
		<A href='byond://?src=\ref[src];make=44;dir=1'>Automatic Shutoff Valve</A><BR>
		<A href='byond://?src=\ref[src];make=20;dir=1'>Pipe Cap</A><BR>
		<A href='byond://?src=\ref[src];make=19;dir=1'>4-Way Manifold</A><BR>
		<A href='byond://?src=\ref[src];make=18;dir=1'>Manual T-Valve</A><BR>
		<A href='byond://?src=\ref[src];make=43;dir=1'>Manual T-Valve - Mirrored</A><BR>
		<A href='byond://?src=\ref[src];make=52;dir=1'>Digital T-Valve</A><BR>
		<A href='byond://?src=\ref[src];make=53;dir=1'>Digital T-Valve - Mirrored</A><BR>
		<b>Supply pipes:</b><BR>
		<A href='byond://?src=\ref[src];make=29;dir=1'>Pipe</A><BR>
		<A href='byond://?src=\ref[src];make=30;dir=5'>Bent Pipe</A><BR>
		<A href='byond://?src=\ref[src];make=33;dir=1'>Manifold</A><BR>
		<A href='byond://?src=\ref[src];make=41;dir=1'>Pipe Cap</A><BR>
		<A href='byond://?src=\ref[src];make=35;dir=1'>4-Way Manifold</A><BR>
		<b>Scrubbers pipes:</b><BR>
		<A href='byond://?src=\ref[src];make=31;dir=1'>Pipe</A><BR>
		<A href='byond://?src=\ref[src];make=32;dir=5'>Bent Pipe</A><BR>
		<A href='byond://?src=\ref[src];make=34;dir=1'>Manifold</A><BR>
		<A href='byond://?src=\ref[src];make=42;dir=1'>Pipe Cap</A><BR>
		<A href='byond://?src=\ref[src];make=36;dir=1'>4-Way Manifold</A><BR>
		<b>Fuel pipes:</b><BR>
		<A href='byond://?src=\ref[src];make=45;dir=1'>Pipe</A><BR>
		<A href='byond://?src=\ref[src];make=46;dir=5'>Bent Pipe</A><BR>
		<A href='byond://?src=\ref[src];make=47;dir=1'>Manifold</A><BR>
		<A href='byond://?src=\ref[src];make=51;dir=1'>Pipe Cap</A><BR>
		<A href='byond://?src=\ref[src];make=48;dir=1'>4-Way Manifold</A><BR>
		<b>Devices:</b><BR>
		<A href='byond://?src=\ref[src];make=28;dir=1'>Universal pipe adapter</A><BR>
		<A href='byond://?src=\ref[src];make=4;dir=1'>Connector</A><BR>
		<A href='byond://?src=\ref[src];make=7;dir=1'>Unary Vent</A><BR>
		<A href='byond://?src=\ref[src];make=10;dir=1'>Gas Pump</A><BR>
		<A href='byond://?src=\ref[src];make=15;dir=1'>Pressure Regulator</A><BR>
		<A href='byond://?src=\ref[src];make=16;dir=1'>High Power Gas Pump</A><BR>
		<A href='byond://?src=\ref[src];make=11;dir=1'>Scrubber</A><BR>
		<A href='byond://?src=\ref[src];makemeter=1'>Meter</A><BR>
		<A href='byond://?src=\ref[src];make=13;dir=1'>Gas Filter</A><BR>
		<A href='byond://?src=\ref[src];make=23;dir=1'>Gas Filter - Mirrored</A><BR>
		<A href='byond://?src=\ref[src];make=14;dir=1'>Gas Mixer</A><BR>
		<A href='byond://?src=\ref[src];make=25;dir=1'>Gas Mixer - Mirrored</A><BR>
		<A href='byond://?src=\ref[src];make=24;dir=1'>Gas Mixer - T</A><BR>
		<A href='byond://?src=\ref[src];make=26;dir=1'>Omni Gas Mixer</A><BR>
		<A href='byond://?src=\ref[src];make=27;dir=1'>Omni Gas Filter</A><BR>
		<b>Heat exchange:</b><BR>
		<A href='byond://?src=\ref[src];make=2;dir=1'>Pipe</A><BR>
		<A href='byond://?src=\ref[src];make=3;dir=5'>Bent Pipe</A><BR>
		<A href='byond://?src=\ref[src];make=6;dir=1'>Junction</A><BR>
		<A href='byond://?src=\ref[src];make=17;dir=1'>Heat Exchanger</A><BR>

		"}
//What number the make points to is in the define # at the top of construction.dm in same folder

	var/datum/browser/popup = new(user, "pipedispenser", src.name)
	popup.set_content("<TT>[dat]</TT>")
	popup.open()

/obj/machinery/pipedispenser/is_operational()
	return TRUE

/obj/machinery/pipedispenser/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if(unwrenched)
		usr << browse(null, "window=pipedispenser")
		return FALSE
	if(href_list["make"])
		if(!wait)
			var/p_type = text2num(href_list["make"])
			var/p_dir = text2num(href_list["dir"])
			var/obj/item/pipe/P = new (loc, p_type, p_dir)
			P.update()
			P.add_fingerprint(usr)
			wait = 1
			spawn(10)
				wait = 0
	if(href_list["makemeter"])
		if(!wait)
			new /obj/item/pipe_meter(src.loc)
			wait = 1
			spawn(15)
				wait = 0

/obj/machinery/pipedispenser/attackby(obj/item/W, mob/user)
	add_fingerprint(usr)
	if (istype(W, /obj/item/pipe) || istype(W, /obj/item/pipe_meter))
		to_chat(usr, "<span class='notice'>You put \the [W] back into \the [src].</span>")
		qdel(W)
		return
	else if (iswrenching(W) && !user.is_busy(src))
		if (unwrenched == 0)
			to_chat(user, "<span class='notice'>You begin to unfasten \the [src] from the floor...</span>")
			if(W.use_tool(src, user, 40, volume = 50))
				user.visible_message( \
					"<span class='notice'>\The [user] unfastens \the [src].</span>", \
					"<span class='notice'>You have unfastened \the [src]. Now it can be pulled somewhere else.</span>", \
					"You hear ratchet.")
				src.anchored = FALSE
				src.stat |= MAINT
				src.unwrenched = 1
				if (usr.machine==src)
					usr << browse(null, "window=pipedispenser")
		else /*if (unwrenched==1)*/
			to_chat(user, "<span class='notice'>You begin to fasten \the [src] to the floor...</span>")
			if(W.use_tool(src, user, 20, volume = 50))
				user.visible_message( \
					"<span class='notice'>\The [user] fastens \the [src].</span>", \
					"<span class='notice'>You have fastened \the [src]. Now it can dispense pipes.</span>", \
					"You hear ratchet.")
				src.anchored = TRUE
				src.stat &= ~MAINT
				src.unwrenched = 0
				power_change()
	else
		return ..()

//Allow you to drag-drop disposal pipes into it
/obj/machinery/pipedispenser/MouseDrop_T(atom/movable/target, mob/user)
	if(user.incapacitated())
		return

	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You can not comprehend what to do with this.</span>")
		return

	if(!checkPipeType(target))
		return

	qdel(target)

/obj/machinery/pipedispenser/proc/checkPipeType(atom/movable/target)
	return istype(target, /obj/item/pipe) || istype(target, /obj/item/pipe_meter)

/obj/machinery/pipedispenser/disposal
	name = "Disposal Pipe Dispenser"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "pipe_d"
	density = TRUE
	anchored = TRUE
	use_power = NO_POWER_USE

/*
//Allow you to push disposal pipes into it (for those with density 1)
/obj/machinery/pipedispenser/disposal/Crossed(obj/structure/disposalconstruct/pipe as obj)
	if(istype(pipe) && !pipe.anchored)
		qdel(pipe)

Nah
*/

/obj/machinery/pipedispenser/disposal/checkPipeType(atom/movable/target)
	return istype(target, /obj/structure/disposalconstruct) && !target.anchored

/obj/machinery/pipedispenser/disposal/ui_interact(user)
	var/dat = {"<b>Disposal Pipes</b><br><br>
		<A href='byond://?src=\ref[src];dmake=0'>Pipe</A><BR>
		<A href='byond://?src=\ref[src];dmake=1'>Bent Pipe</A><BR>
		<A href='byond://?src=\ref[src];dmake=2'>Junction</A><BR>
		<A href='byond://?src=\ref[src];dmake=8'>Sorting Junction</A><BR>
		<A href='byond://?src=\ref[src];dmake=3'>Y-Junction</A><BR>
		<A href='byond://?src=\ref[src];dmake=4'>Trunk</A><BR>
		<A href='byond://?src=\ref[src];dmake=5'>Bin</A><BR>
		<A href='byond://?src=\ref[src];dmake=6'>Outlet</A><BR>
		<A href='byond://?src=\ref[src];dmake=7'>Chute</A><BR>
		"}

	var/datum/browser/popup = new(user, "pipedispenser", src.name)
	popup.set_content("<TT>[dat]</TT>")
	popup.open()

// 0=straight, 1=bent, 2=junction-j1, 3=junction-j2, 4=junction-y, 5=trunk


/obj/machinery/pipedispenser/disposal/Topic(href, href_list)
	. = ..()
	if(!.)
		return
	if(href_list["dmake"])
		if(unwrenched)
			usr << browse(null, "window=pipedispenser")
			return FALSE
		if(!wait)
			var/p_type = text2num(href_list["dmake"])
			var/obj/structure/disposalconstruct/C = new (src.loc)
			switch(p_type)
				if(0)
					C.ptype = 0
				if(1)
					C.ptype = 1
				if(2)
					C.ptype = 2
				if(3)
					C.ptype = 4
				if(4)
					C.ptype = 5
				if(5)
					C.ptype = 6
					C.density = TRUE
				if(6)
					C.ptype = 7
					C.density = TRUE
				if(7)
					C.ptype = 8
					C.density = TRUE
				if(8)
					C.ptype = 9
			C.add_fingerprint(usr)
			C.update()
			wait = 1
			spawn(15)
				wait = 0

// adding a pipe dispensers that spawn unhooked from the ground
/obj/machinery/pipedispenser/orderable
	anchored = FALSE
	unwrenched = 1

/obj/machinery/pipedispenser/disposal/orderable
	anchored = FALSE
	unwrenched = 1
