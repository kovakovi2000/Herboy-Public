enum {
    an_success = 0x01,
    an_hashDisMatch = 0x02,
    an_Overflow = 0x03,
    an_funcError = 0x04,
    an_NotOnline = 0x05,
    an_SQL_Unreachable = 0x06,
    an_SQL_ConnectLost = 0x07,
    an_SQL_SyntaxError = 0x08,

    gn_success = 0x10,
    gn_busy = 0x11,
    gn_NoCommand = 0x12,
    gn_UnknownType = 0x13
}

enum {
    cmd_Varibles = 0x11,
    cmd_CallExFunc = 0x22
}

enum {
    cb_ExFunc = 1,
}

stock callback_answer(callbackid, socket, answer)
{
    switch(callbackid)
    {
        case cb_ExFunc: {callfunc_begin("exfunc_callback", "EzSck.amxx"); }
    }
    callfunc_push_int(socket);
    callfunc_push_int(answer);
    callfunc_end();
}