// functions_web.axi - Primitive Telnet or Web server functions
//
// These are in an include file to keep the main source file small/tidy
//
// Adapted from https://proforums.harman.com/amx/discussion/2747/telnet-server
//
// These are defined globally:
//	dvServer
//	bServerOpen
//	nServerPort
//	sServerBuffer
//
// I tried AMXmobile from GitHub, but it was too complicated for me
// (e.g. I didn;t want a password login page, or runtime config),
// ans that server port didn't reliably stay around for me

DEFINE_FUNCTION fnReply(char s[])
{
    send_string dvServer,"s,$0D,$0A"	// CR LF
}

DEFINE_FUNCTION fnServerOpen()
{
    stack_var integer nMyResult

    if (bServerOpen)
    {	Debug('fnServerOpen() when server already open???!!!')   }

    nMyResult = type_cast(ip_server_open(dvServer.Port,nServerPort,IP_TCP) * -1)

    switch (nMyResult)
    {
	case 0:
	{
	    Debug('fnServerOpen() successful')
	    bServerOpen = True
	    set_length_string(sServerBuffer,0)
	}
	case 1:  Error('fnServerOpen() invalid server port')
	case 2:  Error('fnServerOpen() invalid value for Protocol')
	case 3:  Error('fnServerOpen() unable to open communication port')
	default: ErrorNumber('fnServerOpen() unknown result',nMyResult)
    }
}

DEFINE_FUNCTION fnServerClose()
{
    Debug('fnServerClose()')
    ip_server_close(dvServer.Port)
    bServerOpen = False
}


DEFINE_FUNCTION fnHomePageReply()
{
    IP_ADDRESS_STRUCT IPInfo

    GET_IP_ADDRESS(0:1:0,IPInfo)

    fnReply('<HTML><HEAD>')
    fnReply('<TITLE>St Aidans Hall AV switching</TITLE>')
    fnReply('</HEAD><BODY>')

    fnReply('<CENTER><TABLE BORDER=2 CELLPADDING=8%>');
    fnReply('<TR BGCOLOR=#66a694><TH BGCOLOR=white ROWSPAN=2>')
    fnReply('    St Aidans<BR><BR>Hall AV<BR>switching</TH>')
    fnReply('    <TH>Kitcken<BR><FONT SIZE=-1>output1</FONT></TH>')
    fnReply('    <TH>Foyer<BR><FONT SIZE=-1>output2</FONT></TH>')
    fnReply('    <TH>Hall<BR><FONT SIZE=-1>output3</FONT></TH></TR>')

    fnReply('<TR>')
    fnReply("'  <TD><A HREF=',$22,'/1/mute',$22,'>Mute</A><BR>'")
    fnReply("'      <A HREF=',$22,'/1/unmute',$22,'>unmute</A></TD>'")
    fnReply("'  <TD><A HREF=',$22,'/2/mute',$22,'>Mute</A><BR>'")
    fnReply("'      <A HREF=',$22,'/2/unmute',$22,'>unmute</A></TD>'")
    fnReply("'  <TD><A HREF=',$22,'/3/mute',$22,'>Mute</A><BR>'")
    fnReply("'      <A HREF=',$22,'/3/unmute',$22,'>unmute</A></TD>'")
    fnReply('</TR>')

    fnReply('<TR><TD align=right><B>Mac/PC:</B><BR>')
    fnReply('         <FONT SIZE=-1>in cupboard</FONT></TD>')
    fnReply("'  <TD><A HREF=',$22,'/from1to1',$22,'>Switch</A></TD>'")
    fnReply("'  <TD><A HREF=',$22,'/from1to2',$22,'>Switch</A></TD>'")
    fnReply("'  <TD><A HREF=',$22,'/from1to3',$22,'>Switch</A></TD>'")
    fnReply('</TR>')

    fnReply('<TR><TD align=right><B>Input2:</B></TD>')
    fnReply("'  <TD><A HREF=',$22,'/from2to1',$22,'>Switch</A></TD>'")
    fnReply("'  <TD><A HREF=',$22,'/from2to2',$22,'>Switch</A></TD>'")
    fnReply("'  <TD><A HREF=',$22,'/from2to3',$22,'>Switch</A></TD>'")
    fnReply('</TR>')

    fnReply('<TR><TD align=right><B>Input3:</B><BR>')
    fnReply('        <FONT SIZE=-1>(HDMI1)</FONT></TD>')
    fnReply("'  <TD><A HREF=',$22,'/from3to1',$22,'>Switch</A></TD>'")
    fnReply("'  <TD><A HREF=',$22,'/from3to2',$22,'>Switch</A></TD>'")
    fnReply("'  <TD><A HREF=',$22,'/from3to3',$22,'>Switch</A></TD>'")
    fnReply('</TR>')

    fnReply('<TR><TD align=right><B>Input4:</B><BR>')
    fnReply('         <FONT SIZE=-1>(HDMI2)</FONT></TD>')
    fnReply("'  <TD><A HREF=',$22,'/from4to1',$22,'>Switch</A></TD>'")
    fnReply("'  <TD><A HREF=',$22,'/from4to2',$22,'>Switch</A></TD>'")
    fnReply("'  <TD><A HREF=',$22,'/from4to3',$22,'>Switch</A></TD>'")
    fnReply('</TR>')

    fnReply('<TR><TH align=right>Church<BR>Feed:</TH>')
    fnReply("'  <TD><A HREF=',$22,'/from5to1',$22,'>Switch</A></TD>'")
    fnReply("'  <TD><A HREF=',$22,'/from5to2',$22,'>Switch</A></TD>'")
    fnReply("'  <TD><A HREF=',$22,'/from5to3',$22,'>Switch</A></TD>'")
    fnReply('</TR>')

    fnReply('<TR><TH align=right>Input6:</TH>')
    fnReply("'  <TD><A HREF=',$22,'/from6to1',$22,'>Switch</A></TD>'")
    fnReply("'  <TD><A HREF=',$22,'/from6to2',$22,'>Switch</A></TD>'")
    fnReply("'  <TD><A HREF=',$22,'/from6to3',$22,'>Switch</A></TD>'")
    fnReply('</TR>')

    fnReply('<TR><TD align=right><B>AirPlay:</B><BR>')
    fnReply('         <FONT SIZE=-1>(audio)</FONT></TD>')
    fnReply("'  <TD><A HREF=',$22,'/from7to1',$22,'>Switch</A></TD>'")
    fnReply("'  <TD><A HREF=',$22,'/from7to2',$22,'>Switch</A></TD>'")
    fnReply("'  <TD><A HREF=',$22,'/from7to3',$22,'>Switch</A></TD>'")
    fnReply('</TR>')

    fnReply('<TR><TD align=right><B>Input8:</B><BR>')
    fnReply('         <FONT SIZE=-1>(audio)</FONT></TD>')
    fnReply("'  <TD><A HREF=',$22,'/from8to1',$22,'>Switch</A></TD>'")
    fnReply("'  <TD><A HREF=',$22,'/from8to2',$22,'>Switch</A></TD>'")
    fnReply("'  <TD><A HREF=',$22,'/from8to3',$22,'>Switch</A></TD>'")
    fnReply('</TR>')

    fnReply('<TR><TH align=right>Volume:</TH>')
    fnReply('  <TD>')
    fnReply("'    <A HREF=',$22,'/1/vol20',$22,'>20%</A>&nbsp;'")
    fnReply("'    <A HREF=',$22,'/1/vol40',$22,'>40%</A><BR>'")
    fnReply("'    <A HREF=',$22,'/1/vol60',$22,'>60%</A>&nbsp;'")
    fnReply("'    <A HREF=',$22,'/1/vol80',$22,'>80%</A><BR>&nbsp;&nbsp;'")
    fnReply("'    <A HREF=',$22,'/1/vol100',$22,'>100%</A></TD>'")
    fnReply('  <TD>')
    fnReply("'    <A HREF=',$22,'/2/vol20',$22,'>20%</A>&nbsp;'")
    fnReply("'    <A HREF=',$22,'/2/vol40',$22,'>40%</A><BR>'")
    fnReply("'    <A HREF=',$22,'/2/vol60',$22,'>60%</A>&nbsp;'")
    fnReply("'    <A HREF=',$22,'/2/vol80',$22,'>80%</A><BR>&nbsp;&nbsp;'")
    fnReply("'    <A HREF=',$22,'/2/vol100',$22,'>100%</A></TD>'")
    fnReply('  <TD>')
    fnReply("'    <A HREF=',$22,'/3/vol20',$22,'>20%</A>&nbsp;'")
    fnReply("'    <A HREF=',$22,'/3/vol40',$22,'>40%</A><BR>'")
    fnReply("'    <A HREF=',$22,'/3/vol60',$22,'>60%</A>&nbsp;'")
    fnReply("'    <A HREF=',$22,'/3/vol80',$22,'>80%</A><BR>&nbsp;&nbsp;'")
    fnReply("'    <A HREF=',$22,'/3/vol100',$22,'>100%</A></TD>'")
    fnReply('</TR>')

    fnReply('</TABLE><BR>')

    fnReply("'AMX Enova DVX-2155HD-SP at ',IPInfo.IPADDRESS,'<BR>'")
    fnReply("'<A HREF=',$22,'https://',IPInfo.IPADDRESS,$22")
    fnReply('>Full WebConfig</A><FONT SIZE=-1>')
    fnReply('(requires browser running Flash&#8482;)</FONT><BR>')
    fnReply('Coding & config by Nigel.Pearson.AU@gmail.com')
    fnReply('</CENTER></BODY></HTML>')
}

// Not real REST URIs, because there is no POST et c.,
// but slightly neater than the alternative?
//
// Output is the first level, and command the second.
//	e.g.	http://10.0.0.1/zone1/mute
//		http://10.0.0.1/output3/unmute
//		http://10.0.0.1/2/vol100
//
// Note that a real REST URI would
//	POST /2/vol	with the new volume %, or
//	GET /2/vol	to read the volume for zone 2.

DEFINE_FUNCTION fnActOnRestURI(char uri[])
{
    stack_var char dest[1]
    stack_var char str[10]

    remove_string(uri, 'output', 1)	// remove superfluous nouns
    remove_string(uri, 'zone',   1)

    dest = left_string(uri,1)
    str  = right_string(uri, length_string(uri)-2)

    select
    {
	active (str == 'mute') :
	{
	    Debug("'fnActOnRestURI() calling fnMute(',dest,')'")
	    fnZoneMute(atoi(dest))
	}
	active (str == 'unmute') :
	{
	    Debug("'fnActOnRestURI() calling fnUnMute(',dest,')'")
	    fnZoneUnMute(atoi(dest))
	}
	active (find_string(str, 'vol', 1) ) :
	{
	    remove_string(str, 'volume', 1)	// remove superfluous nouns
	    remove_string(str, 'vol',    1)

	    Debug("'fnActOnRestURI() calling fnSetVolume(',dest,',',str,')'")
	    fnSetVolume(zones[atoi(dest)], atoi(str))
	}
	active (1) :
	{   Error('fnActOnRestURI() - Unrecognised URI')   }
    }
}

// These should really also be REST structure,
//	like POST /1/source  value 8
//	instead of GET /from8to1

DEFINE_FUNCTION fnRouteFromURI(char uri[])
{
    stack_var integer a
    stack_var integer b
    stack_var char    src[1]
    stack_var char    dest[1]

    src  = mid_string(uri,5,1)	// fromAtoB
    a    = atoi(src)
    dest = right_string(uri,1)
    b    = atoi(dest)

    Debug("'fnRouteFromURI() calling fnRouteAtoB(',src,',',dest,')'")
    fnRouteAtoB(a,b)
    //fnZoneUnMute(b)	???
}

DEFINE_FUNCTION fnHandleHTTP()
{
    stack_var integer i
    stack_var char    str[200]

    str = remove_string(sServerBuffer, "$0D,$0A", 1)	// Just keep first line
    set_length_string(str,length_string(str)-2)		// minus the CR LF

    i = find_string(str, ' http', 1)
    if (i)
    {	set_length_string(str,i-1)   }

    Debug("'fnHandleHTTP(',str,')'")


    if (str == 'favicon.ico')
    {	fnReply('HTTP/1.1 404 Not Found')   }


    if (find_string(str, 'mute', 3) or
	find_string(str, 'vol',  3) )
    {   fnActOnRestURI(str)   }


    if (find_string(str, 'from', 1) )
    {   fnRouteFromURI(str)   }


    // We should only return the home page for
    //	GET /	GET /index.htm	GET /index.html
    // but it is safest & easiest to just always do it.

    fnHomePageReply()


    // Many browsers don't close connection after doing their huge GET,
    // so this flushes and forces them to display our tiny page:
    fnServerClose()
}

// Handle string on incoming web request or telnet session

DEFINE_FUNCTION fnServerParseBuffer()
{
    stack_var char str[25]

    DebugHex('fnServerParseBuffer() processing...',sServerBuffer)
    sServerBuffer = lower_string(sServerBuffer)

    str = left_string(sServerBuffer, 5)
    sServerBuffer = mid_string(sServerBuffer,6,1019)

    // Typical HTTP request is 'GET / HTTP'...
    if (str == 'get /')
    {
	fnHandleHTTP()
	return
    }


    // Some random Telnet commands:

    if (str == 'hello')
    {	fnReply('Hello back at you!')   }


    if (str == 'stat' or str == 'statu')
    {	fnReply('Status? Um, all is well?')   }


    if (str == 'end' or str == 'quit')
    {
	fnReply('Bye!')
	fnServerClose()
    }

    remove_string(sServerBuffer, "$0D,$0A", 1)
}

