#define CHARS_PER_LINE 6
#define FONT_SIZE "3"
#define FONT_COLOR "#09f"
#define FONT_STYLE "StatusDisplays"
#define SCROLL_SPEED 2
#define LINE_HEIGHT 0.75

// Status display
// (formerly Countdown timer display)

// Use to show shuttle ETA/ETD times
// Alert status
// And arbitrary messages set by comms computer

/obj/machinery/status_display
	icon = 'icons/obj/status_display.dmi'
	icon_state = "frame"
	name = "status display"
	anchored = TRUE
	density = FALSE
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	var/mode = 5	// 0 = Blank
					// 1 = Shuttle timer
					// 2 = Arbitrary message(s)
					// 3 = alert picture
					// 4 = Supply shuttle timer
					// 5 = default N picture

	var/picture_state	// icon_state of alert picture
	var/message1 = ""	// message line 1
	var/message2 = ""	// message line 2
	var/index1			// display index for scrolling messages or 0 if non-scrolling
	var/index2

	frequency = 1435		// radio frequency
	var/supply_display = 0		// true if a supply shuttle display

	var/friendc = 0      // track if Friend Computer mode

	maptext_height = 28
	maptext_width = 32
	maptext_y = 3

	// new display
	// register for radio system

/obj/machinery/status_display/atom_init()
	. = ..()
	status_display_list += src
	radio_controller.add_object(src, frequency)
	update()


/obj/machinery/status_display/Destroy()
	status_display_list -= src
	if(radio_controller)
		radio_controller.remove_object(src,frequency)
	return ..()

/obj/machinery/status_display/process()
	if(stat & NOPOWER)
		remove_display()
		return
	update()

/obj/machinery/status_display/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return
	set_picture("ai_bsod")
	..(severity)

// set what is displayed

/obj/machinery/status_display/proc/update()
	if(friendc && mode != 4)	//Makes all status displays except supply shuttle timer display the eye -- Urist
		set_picture("ai_friend")
		return

	if(mode == 3 && overlays.len)	//Why we must update diplay if picture is already set?
		return

	if(overlays.len && !friendc || mode == 4)
		cut_overlays()

	switch(mode)
		if(0)				//blank
			remove_display()
		if(1)				//emergency shuttle timer
			if(SSshuttle.online)
				var/line1
				var/line2 = get_shuttle_timer()
				if(SSshuttle.location == 1)
					line1 = "-ETD-"
				else
					line1 = "-ETA-"
				if(length_char(line2) > CHARS_PER_LINE)
					line2 = "Error!"
				update_display(line1, line2)
			else
				remove_display()
		if(2)				//custom messages
			var/line1
			var/line2

			if(!index1)
				line1 = message1
			else
				line1 = copytext_char(message1+" "+message1, index1, index1+CHARS_PER_LINE)
				var/message1_len = length(message1)
				index1 += SCROLL_SPEED
				if(index1 > message1_len)
					index1 -= message1_len

			if(!index2)
				line2 = message2
			else
				line2 = copytext_char(message2+" "+message2, index2, index2+CHARS_PER_LINE)
				var/message2_len = length_char(message2)
				index2 += SCROLL_SPEED
				if(index2 > message2_len)
					index2 -= message2_len
			update_display(line1, line2)
		if(4)				// supply shuttle timer
			var/line1 = "SUPPLY"
			var/line2
			if(SSshuttle.moving)
				line2 = get_SSshuttle_timer()
				if(length_char(line2) > CHARS_PER_LINE)
					line2 = "Error"
			else
				if(SSshuttle.at_station)
					line2 = "Docked"
				else
					line1 = ""
			update_display(line1, line2)
		if(5)				// default picture
			set_picture("default")

/obj/machinery/status_display/examine(mob/user)
	..()
	switch(mode)
		if(1,2,4)
			to_chat(user, "The display says:<br>&emsp;<xmp>[message1]</xmp><br>&emsp;<xmp>[message2]</xmp>")


/obj/machinery/status_display/proc/set_message(m1, m2)
	if(m1)
		index1 = (length_char(m1) > CHARS_PER_LINE)
		message1 = m1
	else
		message1 = ""
		index1 = 0

	if(m2)
		index2 = (length_char(m2) > CHARS_PER_LINE)
		message2 = m2
	else
		message2 = ""
		index2 = 0

/obj/machinery/status_display/proc/set_picture(state)
	picture_state = state
	remove_display()
	add_overlay(image('icons/obj/status_display.dmi', icon_state=picture_state))

/obj/machinery/status_display/proc/update_display(line1, line2)
	var/new_text = {"<div style="font-size:[FONT_SIZE];color:[FONT_COLOR];line-height:[LINE_HEIGHT];font-family:'[FONT_STYLE]';text-align:center;" valign="top">[line1]<br>[line2]</div>"}
	if(maptext != new_text)
		maptext = new_text

/obj/machinery/status_display/proc/get_shuttle_timer()
	var/timeleft = SSshuttle.timeleft()
	if(timeleft)
		return "[add_zero(num2text((timeleft / 60) % 60),2)]:[add_zero(num2text(timeleft % 60), 2)]"
	return ""

/obj/machinery/status_display/proc/get_SSshuttle_timer()
	if(SSshuttle.moving)
		var/timeleft = round((SSshuttle.eta_timeofday - REALTIMEOFDAY) / 10,1)
		if(timeleft < 0)
			return "Late"
		return "[add_zero(num2text((timeleft / 60) % 60),2)]:[add_zero(num2text(timeleft % 60), 2)]"
	return ""

/obj/machinery/status_display/proc/remove_display()
	if(overlays.len)
		cut_overlays()
	if(maptext)
		maptext = ""


/obj/machinery/status_display/receive_signal(datum/signal/signal)

	switch(signal.data["command"])
		if("blank")
			mode = 0

		if("shuttle")
			mode = 1

		if("message")
			mode = 2
			set_message(signal.data["msg1"], signal.data["msg2"])

		if("alert")
			mode = 3
			set_picture(signal.data["picture_state"])

		if("supply")
			if(supply_display)
				mode = 4

		if("default")
			mode = 5


	update()

/obj/machinery/status_display/deconstruct(disassembled)
	if(flags & NODECONSTRUCT)
		return ..()
	new /obj/item/stack/sheet/metal(loc, 2)
	new /obj/item/weapon/shard(loc)
	new /obj/item/weapon/shard(loc)
	// new /obj/item/wallframe/status_display(loc) // TODO add?
	..()


/obj/machinery/ai_status_display
	icon = 'icons/obj/status_display.dmi'
	icon_state = "frame"
	name = "AI display"
	anchored = TRUE
	density = FALSE

	var/mode = 0	// 0 = Blank
					// 1 = AI emoticon
					// 2 = Blue screen of death

	var/picture_state	// icon_state of ai picture

	var/emotion = "Neutral"

/obj/machinery/ai_status_display/atom_init()
	. = ..()
	ai_status_display_list += src

/obj/machinery/ai_status_display/Destroy()
	ai_status_display_list -= src
	return ..()

/obj/machinery/ai_status_display/process()
	if(stat & NOPOWER)
		cut_overlays()
		return

	update()

/obj/machinery/ai_status_display/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return
	set_picture("ai_bsod")
	..(severity)

/obj/machinery/ai_status_display/proc/update()

	if(mode==0) //Blank
		cut_overlays()
		return

	if(mode==1)	// AI emoticon
		switch(emotion)
			if("Very Happy")
				set_picture("ai_veryhappy")
			if("Happy")
				set_picture("ai_happy")
			if("Neutral")
				set_picture("ai_neutral")
			if("Unsure")
				set_picture("ai_unsure")
			if("Confused")
				set_picture("ai_confused")
			if("Sad")
				set_picture("ai_sad")
			if("BSOD")
				set_picture("ai_bsod")
			if("Blank")
				set_picture("ai_off")
			if("Problems?")
				set_picture("ai_trollface")
			if("Awesome")
				set_picture("ai_awesome")
			if("Dorfy")
				set_picture("ai_urist")
			if("Facepalm")
				set_picture("ai_facepalm")
			if("Friend Computer")
				set_picture("ai_friend")
			if("Beer mug")
				set_picture("ai_beer")
			if("Dwarf")
				set_picture("ai_dwarf")
			if("Fishtank")
				set_picture("ai_fishtank")
			if("Plump Helmet")
				set_picture("ai_plump")
			if("HAL")
				set_picture("ai_hal")
			if("Tribunal")
				set_picture("ai_tribunal")
			if("Tribunal Malfunctioning")
				set_picture("ai_tribunal_malf")

		return

	if(mode==2)	// BSOD
		set_picture("ai_bsod")
		return


/obj/machinery/ai_status_display/proc/set_picture(state)
	picture_state = state
	if(overlays.len)
		cut_overlays()
	add_overlay(image('icons/obj/status_display.dmi', icon_state=picture_state))

#undef CHARS_PER_LINE
#undef FONT_SIZE
#undef FONT_COLOR
#undef FONT_STYLE
#undef SCROLL_SPEED
#undef LINE_HEIGHT
