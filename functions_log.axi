// functions_log.axi - Simple logging functions
//
// These are in an include file to keep the main source file small/tidy
//
// Does simplest possible logging - output in NetLinx Studio's Diagnostics tab.
// Requires you to "Enable NetLinx Internal Diagnostics Messages"
// in the Diagnostics menu first.
//
// The function names are stolen from someone else. See:
// https://proforums.harman.com/amx/discussion/2747/telnet-server
// and blame them for not following good naming conventions :-)
// (can't remember where sCleanAscii() was stolen from)
//

DEFINE_FUNCTION CHAR[5096] sCleanAscii (CHAR sString[])
{
    STACK_VAR CHAR sTemp[5096] ;
    STACK_VAR INTEGER nCount ;
    
    FOR(nCount = 1; nCount <= LENGTH_STRING(sString); nCount ++)
    {
	SELECT
	{
	    ACTIVE(sString[nCount] < 32) : // low order ASCII
	    {
		sTemp = "sTemp, ',<', ITOA(sString[nCount]), '>'"
	    }	
	    ACTIVE(sString[nCount] > 126) : // high order ASCII
	    {
		sTemp = "sTemp, ',<', ITOA(sString[nCount]), '>'"
	    }	
	    ACTIVE(TRUE) : sTemp = "sTemp, sString[nCount]" ;
	}
    }
    
    RETURN sTemp ;
}


DEFINE_FUNCTION Debug(char s[])
{
    if (length_string(s) > 255)
    {   set_length_string(s,255)   }

    send_string 0, s
}

DEFINE_FUNCTION DebugHex(char s[], char d[])
{
    stack_var char hex[5096]

    hex = sCleanAscii(d)

    Debug("s,hex")
}

DEFINE_FUNCTION Error(char s[])
{
    if (length_string(s) > 255)
    {   set_length_string(s,255)   }

    send_string 0, "'ERROR: ',s"
}

DEFINE_FUNCTION ErrorNumber(char s[], integer n)
{
    if (length_string(s) > 250)
    {   set_length_string(s,250)   }

    send_string 0, "'ERROR: ',s,' - ',n"
}

