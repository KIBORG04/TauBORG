/datum/quality
	var/desc

	var/restriction

/datum/quality/proc/restriction_check(mob/living/carbon/human/H)
	return TRUE

/datum/quality/proc/add_effect(mob/living/carbon/human/H)
	return

/datum/quality/test
	desc = "Write 'lol' in chat after quirks"

	restriction = "Dont be a dick"

/datum/quality/test/restriction_check(mob/living/carbon/human/H)
	to_chat(H, "I believe you are not a dick")
	return TRUE

/datum/quality/test/add_effect(mob/living/carbon/human/H)
	to_chat(H, "lol")



/datum/mood_event/true_keeper_failure
	description = "<span class='warning'>ВАРДЕН ВНЕ БРИГА!</span>"
	mood_change = -5

/datum/quality/true_keeper
	desc = "Ты не должен покидать бриг ЛЮБОЙ ЦЕНОЙ. Он ведь загнётся без твоего надзора!"

	restriction = "Варден"

/datum/quality/true_keeper/restriction_check(mob/living/carbon/human/H)
	return H.mind.assigned_role == "Warden"

/datum/quality/true_keeper/add_effect(mob/living/carbon/human/H)
	RegisterSignal(H, COMSIG_ENTER_AREA, .proc/on_enter)
	RegisterSignal(H, COMSIG_EXIT_AREA, .proc/on_exit)

/datum/quality/true_keeper/proc/on_enter(datum/source, area/A, atom/OldLoc)
	if(istype(A, /area/station/security))
		SEND_SIGNAL(source, COMSIG_CLEAR_MOOD_EVENT, "true_keeper_failure")

/datum/quality/true_keeper/proc/on_exit(datum/source, area/A, atom/NewLoc)
	if(istype(A, /area/station/security))
		SEND_SIGNAL(source, COMSIG_ADD_MOOD_EVENT, "true_keeper_failure", /datum/mood_event/true_keeper_failure)



/datum/mood_event/rts_failure
	description = "<span class='warning'>Капитан должен тонуть вместе с кораблём... Я должен вернуться на мостик</span>"
	mood_change = -5

/datum/quality/rts
	desc = "Ты не должен покидать мостик. Ты ведь мозг станции, а мозг должен быть в самом защищенном месте."

	restriction = "Капитан"

/datum/quality/rts/restriction_check(mob/living/carbon/human/H)
	return H.mind.assigned_role == "Captain"

/datum/quality/rts/add_effect(mob/living/carbon/human/H)
	RegisterSignal(H, COMSIG_ENTER_AREA, .proc/on_enter)
	RegisterSignal(H, COMSIG_EXIT_AREA, .proc/on_exit)

/datum/quality/rts/proc/on_enter(datum/source, area/A, atom/OldLoc)
	if(istype(A, /area/station/bridge))
		SEND_SIGNAL(source, COMSIG_CLEAR_MOOD_EVENT, "rts_failure")

/datum/quality/rts/proc/on_exit(datum/source, area/A, atom/NewLoc)
	if(istype(A, /area/station/bridge))
		SEND_SIGNAL(source, COMSIG_ADD_MOOD_EVENT, "rts_failure", /datum/mood_event/rts_failure)
