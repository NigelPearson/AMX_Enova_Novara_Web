Summary:
This is a very simple coding example for an AMX Enova DVX-2155.
* Attaches a few 8 button keypads for selecting 5 inputs, volume, and mute.
* Implements a very primitive Web server, with a kind of REST API.
  This is for iPhone generation users, who are too lazy to press real buttons.
* No fancy AMX touch screens or wireless presentation gateways.

It should be fully functioning, and a reasonable basis for modification.


Contents:
* This file   - Readme.txt
* Source code - Enova_Novara_Web.apw,
  functions.axi, functions_log.axi, functions_web.axi, main.axs
* Screenshot of my Web interface in Safari - web_interface.jpg
* Everything I know about old AMX Enovas - enova_gossip.txt
* (mainly Netlinx) Programming resources - resources.txt


Why:
This was developed for the hall of my church, St Aidans at Hurstville Grove.

I wanted a system that was simple to use, turn it on and the main use function
is there and working. Essential functions permanently cabled and unchanged,
but expert users still able to plug in laptops, audio mixers, et c.

We got a quote for a magical system -
BlackMagic SDI video switch, BlackMagic HDMI<=>SDI converters,
Yamaha touch screen DSP mixer, and QSC Q-SYS to integrate -
but the cost, and needing computers or smart devices to control
(instead of simple wall-mounted switches) put me off.

One option was Australian Monitor Zone Mix 3 with wall plates for selecting
audio for each room/space/zone, but that didn't take care of video switching.
The idea of a wall plate for audio, and a remote control or something else
to select video, went against my simple to use mantra.

So after lots of Googling, I found some all-in-one devices -
Matrix Switches or Presentation Switches. New prices are quite ridiculous,
but eBay soon narrowed down secondhand value. For a few hundred dollars,
an AMX or Crestron device seemed low-risk, and online documentation was around.
I was just about to get a Crestron DMPS300-C, until I read on a forum that
only the later DMPS3 series supported Web browser configuration.
These later models were a lot more expensive, so I kept looking.

I should explain here that I am not an AV install professional.
I can do wiring, simple electronics, and system programming,
but no-one I know works for an AV install company,
which means that the REQUIRED PROPRIETRY programming tools are out of reach.

Long story short, the AMX Enovas can be configured from an old PC or Mac,
and if you are geeky, there is just enough info out there to program them,
and AMX Netlinx Studio is currently downloadable,


How To:
* Get a Windows PC. I used an old Win7 laptop.
* Install NetLinx Studio from https://www.amx.com/en/softwares
* Get it to talk to your Enova (networking, factory reset?)
* Configure Enova to not serve port 80
* Open Enova_Novara_Web.apw and edit System
 'Enova@ [10.0.0.1:1319]' so that it talks to your Enova
* Right click -> 'Build System' should compile cleanly
* Right click -> 'Quick Load System' add main.tkn with reboot, then Send
* Wait a minute or so and point a Web browser at your Enova


Bugs:
* The Web server isn't bulletproof. In particular, the nmap tool -
  which I was using to see when my Web Server was up - would hang it up.
  Diagnostics show:
 (14:26:02.133)::  fnServerOpen() successful
 (14:26:11.228)::  CIpSocketMan::threadTCPListen Error accepting connection
 (14:26:11.228)::  CIpSocketMan::threadTCPListen - accept error
 (14:26:11.228)::  CIpSocketMan::threadTCPListen - errno = 0
 (14:26:11.244)::  CIpEvent::OnError 0:0:1



Nigel Pearson, January 2021
