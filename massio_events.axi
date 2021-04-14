// massio_events.axi - event processing for Massio M*P-108
//
// These are in an include file to keep the main source file small/tidy
//
// Uses three globals;
//	dvMassioOne - which is just our single Massio.
//	videoButtons - the first 6 buttons (video selection only)
//	volumeButtons - the last 3 "buttons" (volume knob)
//
// Note that our Massio controls Zone/Output 3 on the Enova switch.
// If we ever add more Massio keypads, an array of devices,
// and lots of get_last(array), would be needed?


data_event[dvMassioOne]
{
    online:
    {						// Set brightness;
	send_command dvMassioOne,"'@BRT-20,11'"	// bargraph 2/3, keys 1/3

	// Volume starts at INITIAL_VOLUME %, so
	send_level dvMassioOne, 1, INIT_VOL255	// show on bargraph
	send_level dvMassioOne, 2, INIT_VOL255	// and store value
    }
}

// A simple one-to-one mapping of the inputs to the buttons:

button_event[dvMassioOne,videoButtons]
{
    push:
    {
	fnRouteAtoB(get_last(videoButtons),3)
	fnUnMute(dvZoneThree)	// sets volume to INITIAL_VOLUME
    }
    release:
    {
	send_level dvMassioOne, 1, INIT_VOL255	// show on bargraph
	send_level dvMassioOne, 2, INIT_VOL255	// and store value
    }
}

// Inputs 7 & 8 are audio-only, but for user feedback, also mute video:

button_event[dvMassioOne,7]
{
    push:	fnRouteAtoB(7,3)
    release:	fnMuteVideo(dvZoneThree)
}

button_event[dvMassioOne,8]
{
    push:	fnRouteAtoB(8,3)
    release:	fnMuteVideo(dvZoneThree)
}


// Mute. No need for an UnMute function -
// user can just turn the volume up!

button_event[dvMassioOne,11]
{
    push:
    {
	fnMute(dvZoneThree)
    }
    release:
    {
	send_level dvMassioOne, 1, 0	// UI feedback - blank the bargraph
	send_level dvMassioOne, 2, 0	// and zero the stored value
    }
}

// Channel 12 (up) and 13 (down).
// We now ignore these, and use level events from the dial

level_event[dvMassioOne,2]
{
    stack_var  integer dial
    stack_var  integer percent

    dial    = level.value
    percent = TYPE_CAST(dial / 2.55)
    
    fnSetVolume(dvZoneThree,percent)
    //volume[3] = percent;

    send_level dvMassioOne, 1, dial	// Update bargraph

    Debug("'Massio dial value: ', itoa(dial),
                '/255 (', itoa(percent), '%)'")
}



// Also handle any other events we get,
// to reduce CPU load in mainloop

button_event[dvMassioOne,12] { push:{} release:{} }
button_event[dvMassioOne,13] { push:{} release:{} }

channel_event[dvMassioOne,volumeButtons] { on:{} off:{} }

level_event[dvMassioOne,2] {}


// First 8 buttons already have channel_event handlers in main.




// If a Massio is plugged into live system, we get these mysterious messages:
//
// (07:41:55.083):: Device [32222:1] is Online
// (07:41:55.084):: Command To [32222:1:1]-[LEVON]
// (07:41:55.084):: Command To [32222:1:1]-[RXON]
// (07:41:55.150):: String Size [32222:1:1] 512 byte(s) Type: 8 bit

