PROGRAM_NAME='Enova_Novara_Web'

///////////////////////////////////////////////////////////////////////////////
// Config for St Aidan's church by Nigel Pearson, nigel.pearson.au@gmail.com
//
// v17, 5th Dec. 2020	: Single zone, all functions tested
// v18, 28th Dec. 2020	: Auto-repeat on volume up/down, helper functions and
//			  DEV array to prevent button event code duplication
// v19, 3rd Jan. 2021	: Added primitive web/telnet server
// v20, 4th Jan. 2021	: Log output/errors from send_command
// v21, 17th Jan. 2021	: Add a Massio keypad
///////////////////////////////////////////////////////////////////////////////


DEFINE_DEVICE

// We have an Enova DVX-2155HD switch at default device ID.

dvSwitch = 5002

// a Massio MKP-108 keypad
dvMassioOne = 32222:1:1

// and some Novara SP-08-AX-US-WH wall plate keypads

dvNovaraOne = 85:1:1
dvNovaraTwo = 86:1:1


// The Enova 2x55 inputs:

dvInput1 = 5002:1:0	// AV input 1, DVI
dvInput2 = 5002:2:0	// AV input 2, DVI
dvInput3 = 5002:3:0	// AV input 3, HDMI
dvInput4 = 5002:4:0	// AV input 4, HDMI
dvInput5 = 5002:5:0	// AV input 5, HDBaseT
dvInput6 = 5002:6:0	// AV input 6, HDBaseT
dvInput7 = 5002:7:0	// Input 7, audio only 
dvInput8 = 5002:8:0	// Input 8, audio only

// and outputs:

dvZoneOne   = 5002:1:0	// both HDMI and analogue audio
dvZoneTwo   = 5002:2:0	// ,,
dvZoneThree = 5002:3:0	// both HDBaseT and analogue audio


dvRelay = 5001:21:2	// for some dodgy debugging


dvServer = 0:3:0	// Web/Telnet server plumbing




DEFINE_CONSTANT

INITIAL_VOLUME = 25	// Percent
INIT_VOL255    = 64	// 25% of 0-255

// Overall button layout for my Novara keypads:

ZONE_OFF = 1    VOL_UP   = 2
ROUTE_1  = 3    VOL_DOWN = 4
ROUTE_2  = 5    ROUTE_3  = 6
ROUTE_4  = 7    ROUTE_5  = 8



DEFINE_TYPE

DEFINE_VARIABLE

integer volume[3]	// Lazy alternative to level_events for volume mgt.

volatile integer buttons[8] = {1, 2, 3, 4, 5, 6, 7, 8}
volatile DEV     keypads[2] = {dvNovaraOne, dvNovaraTwo} // Novaras only
volatile DEV     zones[3]   = {dvZoneOne,   dvZoneTwo,   dvZoneThree}


volatile DEV     allKeypads[3]    = {dvNovaraOne, dvNovaraTwo, dvMassioOne}
volatile integer videoButtons[6]  = {1, 2, 3, 4, 5, 6}
volatile integer volumeButtons[8] = {11, 12, 13}



// To get responses from any possible send_command,
// we need a data_event handler
// which covers all possible switch devs:
volatile DEV devs[9] = {dvMassioOne,
			dvInput1, dvInput2, dvInput3, dvInput4,
			dvInput5, dvInput6, dvInput7, dvInput8}


// Web/Telnet server stuff:

volatile integer bServerOpen	= False
volatile integer nServerPort	= 80	// CLASHES with WebControl

// Controller http:// is at 80 by default, so either disable it,
// configure it to be something other than 80 (280/8008/8080/8088),
// or MOVE THIS SERVER PORT away from 80


volatile char sServerBuffer[1024] = ''



DEFINE_LATCHING

DEFINE_MUTUALLY_EXCLUSIVE

#INCLUDE 'functions.axi'

#INCLUDE 'functions_log.axi'

#INCLUDE 'functions_web.axi'




DEFINE_START

fnSetVolume(dvZoneOne,  INITIAL_VOLUME)
fnSetVolume(dvZoneTwo,  INITIAL_VOLUME)
fnSetVolume(dvZoneThree,INITIAL_VOLUME)

Debug('Volumes set to INITIAL_VOLUME')



DEFINE_EVENT

#INCLUDE 'massio_events.axi'



// As per the Language Reference Guide, there are many events for each button.
// Not handling all of them falls thru to the MainLoop,
// which makes the PROGRAM do more CPU work.
//
// So, I also deal with release:. Not sure how to do hold[*]:?
//
// Most of these do everything in push:, but for some of them,
// I split actions between push: and release:, just for fun!



// ZONE_OFF. We can't actually power things down, so we just mute.
// This also does an "undo" (unMute) if you hold the button.

button_event[keypads,ZONE_OFF]
{
    push:    fnZoneMute(  get_last(keypads))
    hold[5]: fnZoneUnMute(get_last(keypads))	// .5 sec hold = unmute
    release: {}
}

button_event[keypads,VOL_UP]
{
    push:		fnZoneVolUp(get_last(keypads))
    hold[2,repeat]:	fnZoneVolUp(get_last(keypads))
    release:		{}
}

button_event[keypads,VOL_DOWN]
{
    push:		fnZoneVolDown(get_last(keypads))
    hold[3,repeat]:	fnZoneVolDown(get_last(keypads))
    release:		{}
}


//   Actual labels      | their meaning, |   and my currently   |
//   on my keypads,     |                |    wired inputs      |
// ---------------------+----------------+----------------------+
//   Off     VolumeUp   |  Mute    Vol+  |     n.a.      n.a.   |
//                      |                |                      |
// Church    VolumeDn   | Route1   Vol-  | 5(HDBaseT1)   n.a.   |
//                      |                |                      |
// AirPlay  PC-cupboard | Route2  Route3 | 7(audio 1)  1(DVI 1) |
//                      |                |                      |
//  HDMI1      HDMI2    | Route4  Route5 | 3(HDMI 1)   4(HDMI 2)|
// ---------------------+----------------+----------------------+

button_event[keypads,ROUTE_1]
{
    push:	fnRouteAtoB(5,get_last(keypads))
    release:	fnZoneUnMute( get_last(keypads))
}

button_event[keypads,ROUTE_2]
{		// Input 7 is audio-only, but for user feedback, also mute video
    push:	fnRouteAtoB(7,get_last(keypads))
    release:	fnZoneMuteVid(get_last(keypads))
}

button_event[keypads,ROUTE_3]
{
    push:	fnRouteAtoB(1,get_last(keypads))
    release:	fnZoneUnMute( get_last(keypads))
}

button_event[keypads,ROUTE_4]
{
    push:	fnRouteAtoB(3,get_last(keypads))
    release:	fnZoneUnMute( get_last(keypads))
}

button_event[keypads,ROUTE_5]
{
    push:	fnRouteAtoB(4,get_last(keypads))
    release:	fnZoneUnMute( get_last(keypads))
}


// Also handle the other events we get from button presses, to reduce CPU load

channel_event[allKeypads,buttons] { on:{} off:{} }



// Basic Telnet/Web server

data_event[dvServer]
{
    string:
    {
	sServerBuffer = "sServerBuffer,data.text"
	fnServerParseBuffer()
    }
    offline:
    {
	Debug('dvServer offline')		
	bServerOpen = False
    }
    online:	Debug('dvServer online')
    onerror:	ErrorNumber('dvServer onerror',type_cast(data.number))
}


// Get output/errors from send_commands being sent to switch device(s)

data_event[devs]
{
    string:  Debug("'STRING REPLY : ',data.text")
    command: Debug("'COMMAND REPLY: ',data.text")
}



DEFINE_PROGRAM

// Start up a basic Telnet/Web server.
// Here in Mainloop, it will also be restarted when closed or offline

if (not bServerOpen)	{   WAIT 5   fnServerOpen()   }


// Debug a keypad. Something like this would copy relay from button?
//push [dvNovaraOne,ZONE_OFF] to [dvRelay,1]


(*****************************************************************)
(*                       END OF PROGRAM                          *)
(*                                                               *)
(*         !!!  DO NOT PUT ANY CODE BELOW THIS COMMENT  !!!      *)
(*                                                               *)
(*****************************************************************)
