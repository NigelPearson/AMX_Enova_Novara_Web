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
	fnSetBargraph(dvMassioOne,INITIAL_VOLUME)
    }
}

// A simple one-to-one mapping of the inputs to the buttons:

button_event[dvMassioOne,videoButtons]
{
    push:	fnRouteAtoB(get_last(videoButtons),3)
    release:	{ fnUnMute(dvZoneThree); // Why does this act weird?
fnShowVolume(dvMassioOne,3) }
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


// Mute. Ideally, we would actually power things down.
// This also does an "undo" (unMute) if you hold the button.

button_event[dvMassioOne,11]
{
    push:	fnZoneMute(3)
    hold[5]:	fnZoneUnMute(3)		// .5 sec hold = unmute
    release:	fnShowVolume(dvMassioOne,3)
}

// Channel 12 (up) and 13 (down).
// fnVolUp() and fnVolDown() were designed for the keypad buttons,
// and only make small increments unless you hold the button in (via repeats).
// We basically re-implement those functions.

button_event[dvMassioOne,12]
{
    push:
    {
	volume[3] = volume[3] + 7;
    }
    hold[1]:
    {
	//volume[3] = volume[3] + 15;
	Debug("'Got HOLD on volume up'")
    }
    release:
    {
	if (volume[3] > 100)
	{   volume[3] = 100 }
	fnSetVolume(dvZoneThree,volume[3])
	fnShowVolume(dvMassioOne,3)
    }
}

button_event[dvMassioOne,13]
{
    push:
    {
	volume[3] = volume[3] - 10;
    }
    hold[1]:
    {
	//volume[3] = volume[3] - 15;
	Debug("'Got HOLD on volume down'")
    }
    release:
    {
	if (volume[3] < 0)
	{   volume[3] = 0 }
	fnSetVolume(dvZoneThree,volume[3])
	fnShowVolume(dvMassioOne,3)
    }
}

// Something like this would use Massio's internal level management:
//
//level_event[dvMassioOne,2]
//{
//    stack_var  integer dial
//    stack_var  integer percent
//
//    dial      = level.value
//    percent   = TYPE_CAST(dial / 2.55)
//    volume[3] = percent;
//    //fnShowVolume(dvMassioOne,3)
//    //Debug("'Massio dial value: ', itoa(dial),
//    //            '/255 (', itoa(percent), '%)'")
//}
//
// but there are mute/unmute issues. If dial value was at 255,
// and we mute, turning the dial up would do nothing -
// because level_event only triggers if the level changes.



// Also handle any other events we get,
// to reduce CPU load in mainloop

channel_event[dvMassioOne,volumeButtons] { on:{} off:{} }

level_event[dvMassioOne,2] {}


// First 8 buttons already have channel_event handlers in main.




// If a Massio is plugged into live system, we get these mysterious messages:
//
// (07:41:55.083):: Device [32222:1] is Online
// (07:41:55.084):: Command To [32222:1:1]-[LEVON]
// (07:41:55.084):: Command To [32222:1:1]-[RXON]
// (07:41:55.150):: String Size [32222:1:1] 512 byte(s) Type: 8 bit

