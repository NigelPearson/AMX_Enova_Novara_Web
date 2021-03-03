// functions.axi - Simple AMX Enova switching/volume/mute functions
//
// These are in an include file to keep the main source file small/tidy
//
// Uses a global - integer volume[3] - to store the volume,
// because I don't know how to get the real volume from the Enova.
//
// Netlinx studio diagnostics show these for front panel button volume changes:
//  2020-12-31 (09:18:33):: Level Value From [5002:1:1] - Level 1  Value= 26
//  2020-12-31 (09:18:35):: Level Value From [5002:1:1] - Level 8  Value= 31
//  2020-12-31 (09:18:36):: Level Value From [5002:1:1] - Level 1  Value= 25
//  2020-12-31 (09:18:37):: Level Value From [5002:1:1] - Level 1  Value= 24
//  2020-12-31 (09:18:37):: Level Value From [5002:1:1] - Level 1  Value= 23
//  2020-12-31 (09:18:37):: Level Value From [5002:1:1] - Level 1  Value= 22
//  2020-12-31 (09:18:37):: Level Value From [5002:1:1] - Level 1  Value= 21
//  2020-12-31 (09:18:38):: Level Value From [5002:1:1] - Level 1  Value= 20
// so I could possibly use events to get the real level?

DEFINE_FUNCTION integer fnGetVolume(DEV outputDev)
{
    return volume[outputDev.PORT]
}

DEFINE_FUNCTION fnSetVolume(DEV zone, INTEGER vol)
{
    send_command zone, "'AUDOUT_VOLUME-',itoa(vol)"
    volume[zone.PORT] = vol
}

// Given a percentage, set the bargraph on a Massio keypad

DEFINE_FUNCTION fnSetBargraph(DEV dv, integer percent)
{
    local_var integer level

    level = TYPE_CAST(percent * 2.55)	// (range = 0 - 255)
    send_level dv, 1, level
}

// Update bargraph from (our stored) volume

DEFINE_FUNCTION fnShowVolume(DEV dv, integer zone)
{
    fnSetBargraph(dv, volume[zone])
}


// Commands to mute video, or do a test pattern, don't seem to work:
//      send_command zone, "'VIDOUT_MUTE-ON'"
//      send_command zone, "'VIDEO_TESTPAT-X-Hatch'"
// Best I can do is dim it a lot.

DEFINE_FUNCTION fnMuteVideo(DEV zone)
{
    send_command zone, "'VIDOUT_BRIGHTNESS-0'"
}


// This silences audio, and disables video.

DEFINE_FUNCTION fnMute(DEV zone)
{
    fnSetVolume(zone,0)
    fnMuteVideo(zone)
}

// Undo a mute

DEFINE_FUNCTION fnUnMute(DEV zone)
{
    fnSetVolume(zone,INITIAL_VOLUME)
    send_command zone, "'VIDOUT_BRIGHTNESS-50'"
}

// RouteAtoB(3,1) connects input 3 to output 1.

DEFINE_FUNCTION fnRouteAtoB(integer source, dest)
{
//  send_command 5002,"'CI3O1'"    does nothing if the input is inactive,
//  				   so we switch audio & video seperately.
    send_command dvSwitch, "'AI',itoa(source),'o',itoa(dest)"
    send_command dvSwitch, "'VI',itoa(source),'o',itoa(dest)"
}


DEFINE_FUNCTION fnVolUp(DEV zone)
{
    local_var integer vol

    vol = TYPE_CAST( fnGetVolume(zone) * 1.1 )    // slight increase
    if (vol < 9)    {   vol = 16    }
    if (vol > 100)  {   vol = 100   }
    fnSetVolume(zone,vol)
}

DEFINE_FUNCTION fnVolDown(DEV zone)
{
    local_var integer vol

    vol = TYPE_CAST( fnGetVolume(zone) * 0.7 )    // large increase
    fnSetVolume(zone,vol)
}


// Helper functions for DEV array event handlers
DEFINE_FUNCTION fnZoneMute   (integer zone)   {   fnMute   (zones[zone])   }
DEFINE_FUNCTION fnZoneMuteVid(integer zone)   { fnMuteVideo(zones[zone])   }
DEFINE_FUNCTION fnZoneUnMute (integer zone)   {   fnUnMute (zones[zone])   }
DEFINE_FUNCTION fnZoneVolUp  (integer zone)   {   fnVolUp  (zones[zone])   }
DEFINE_FUNCTION fnZoneVolDown(integer zone)   {   fnVolDown(zones[zone])   }

