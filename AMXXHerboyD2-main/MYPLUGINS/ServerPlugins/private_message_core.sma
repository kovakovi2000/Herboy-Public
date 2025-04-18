#include <amxmodx>

#pragma semicolon 1

#define PLUGIN_NAME "Private Message: Core"
#define PLUGIN_VERSION "1.5"
#define PLUGIN_AUTHOR "Denzer"

enum _:CVARS
{
    TYPE,
    Float:COOLDOWN,
    MAX_RECEIVER
};

enum _:FORWARDS
{
    SENT,
    PLAYER_BLOCKED,
};

enum _:DATA
{
    TARGET,
    Float:DELAY,
    Array:RECEIVER
};

new g_Cvars[CVARS];
new g_hForwards[FORWARDS];
new g_ePlayerData[MAX_PLAYERS + 1][DATA];
new bool:g_bPlayerBlocked[MAX_PLAYERS + 1][MAX_PLAYERS + 1];
new bool:g_bChatBlocked;

public plugin_init()
{
    register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);

    new pCvar;
    pCvar = create_cvar("pm_type", "1", FCVAR_NONE, "1 - All can write messages each other, 2 - messages can write only: alive to alive, deat for dead, 3 - only to teammates", true, 1.0, true, 3.0);
    bind_pcvar_num(pCvar, g_Cvars[TYPE]);

    pCvar = create_cvar("pm_delay", "2.5", FCVAR_NONE, "Time between messages", true, 0.0, true, 10.0);
    bind_pcvar_float(pCvar, g_Cvars[COOLDOWN]);

    pCvar = create_cvar("pm_max_receiver", "3", FCVAR_NONE, "Maximum receivers (menu)", true, 0.0, true, 4.0);
    bind_pcvar_num(pCvar, g_Cvars[MAX_RECEIVER]);

    AutoExecConfig();

    g_hForwards[SENT] = CreateMultiForward("pm_message_sent", ET_STOP, FP_CELL, FP_CELL, FP_STRING);
    g_hForwards[PLAYER_BLOCKED] = CreateMultiForward("pm_player_blocked", ET_STOP, FP_CELL, FP_CELL, FP_CELL);

    register_saycmd("pm", "CmdMain");
    register_clcmd("pm", "CmdPm");

    register_clcmd("say", "CmdSay");
    register_clcmd("say_team", "CmdSay");

    for(new i = 1; i <= MaxClients; i++)
        g_ePlayerData[i][RECEIVER] = ArrayCreate();

    register_dictionary("private_message.txt");
}

public plugin_end()
{
    for(new i = 1; i <= MaxClients; i++)
        ArrayDestroy(g_ePlayerData[i][RECEIVER]);
}

public plugin_natives()
{
    register_native("pm_is_chat_blocked", "native_pm_is_chat_blocked");
    register_native("pm_is_player_blocked", "native_pm_is_player_blocked");
    register_native("pm_block_use", "native_pm_block_use");
    register_native("pm_send_message", "native_pm_send_message");
}

#define IsPlayerValid(%0) (1 <= %0 <= MaxClients)

public native_pm_is_chat_blocked(plugin, params)
{
    return bool:g_bChatBlocked;
}

public native_pm_is_player_blocked(plugin, params)
{
    enum { blocker = 1, blocked };

    new blocker_id = get_param(blocker), blocked_id = get_param(blocked);

    if(!IsPlayerValid(blocker_id))
        abort(AMX_ERR_NATIVE, "Player out of range (%d)", blocker_id);

    if(!IsPlayerValid(blocked_id))
        abort(AMX_ERR_NATIVE, "Player out of range (%d)", blocked_id);

    return bool:g_bPlayerBlocked[blocker_id][blocked_id];
}

public native_pm_block_use(plugin, params)
{
    enum { type = 1 };
    g_bChatBlocked = bool:get_param(type);
}

public native_pm_send_message(plugin, params)
{
    enum { sender = 1, recipient, array };

    new sender_id = get_param(sender), recipient_id = get_param(recipient);

    if(!IsPlayerValid(sender_id))
        abort(AMX_ERR_NATIVE, "Player out of range (%d)", sender_id);

    if(!IsPlayerValid(recipient_id))
        abort(AMX_ERR_NATIVE, "Player out of range (%d)", recipient_id);

    new message[140];
    get_string(array, message, charsmax(message));

    SendMessage(sender_id, recipient_id, message);
}

public client_putinserver(id)
{
    for(new i = 1; i <= MaxClients; i++)
    {
        g_bPlayerBlocked[id][i] = false;
        g_bPlayerBlocked[i][id] = false;
    }
    g_ePlayerData[id][TARGET] = 0;
    g_ePlayerData[id][DELAY] = 0.0;
}

public client_disconnected(id)
{
    new iPlayers[MAX_PLAYERS], iNum;
    get_players(iPlayers, iNum, "ch");
    for(new i; i < iNum; i++)
    {
        new iPlayer = iPlayers[i];
        if(id == iPlayer)
            continue;

        if(!g_ePlayerData[iPlayer][RECEIVER])
            continue;

        new found = ArrayFindValue(g_ePlayerData[iPlayer][RECEIVER], id);
        if(found != -1)
            ArrayDeleteItem(g_ePlayerData[iPlayer][RECEIVER], found);
    }
    ArrayClear(g_ePlayerData[id][RECEIVER]);
}

public SendMessage(iSender, iReceiver, message[])
{
    replace_wrong_simbols(message);

    if(!message[0])
        return;

    new ret;
    ExecuteForward(g_hForwards[SENT], ret, iSender, iReceiver, message);

    if(ret >= PLUGIN_HANDLED)
        return;

    if(g_bPlayerBlocked[iSender][iReceiver] || g_bPlayerBlocked[iReceiver][iSender])
    {
        client_print_color(iSender, print_team_default, "%l %l", "PM_PREFIX", "PM_PLAYER_BLOCKED");
        return;
    }

    if(g_ePlayerData[iSender][DELAY] > get_gametime())
    {
        client_print_color(iSender, print_team_default, "%l %l","PM_PREFIX", "PM_FLOOD");
        return;
    }

    g_ePlayerData[iSender][DELAY] = get_gametime() + g_Cvars[COOLDOWN];
    client_print_color(iSender, print_team_default, "%l", "PM_MESSAGE_TO", iReceiver, message);
    client_print_color(iReceiver, print_team_default, "%l", "PM_MESSAGE_FROM", iSender, message);

    new found = ArrayFindValue(g_ePlayerData[iSender][RECEIVER], iReceiver);

    if(found != -1)
        ArrayDeleteItem(g_ePlayerData[iSender][RECEIVER], found);

    ArrayPushCell(g_ePlayerData[iSender][RECEIVER], iReceiver);

    if(ArraySize(g_ePlayerData[iSender][RECEIVER]) > g_Cvars[MAX_RECEIVER])
        ArrayDeleteItem(g_ePlayerData[iSender][RECEIVER], 0);
}

public CmdPm(id)
{
    new iPlayer = g_ePlayerData[id][TARGET];
    if(!is_user_connected(iPlayer))
        return;

    new szArgs[140];
    read_args(szArgs, charsmax(szArgs));
    remove_quotes(szArgs);
    trim(szArgs);

    SendMessage(id, iPlayer, szArgs);
}

public CmdSay(id)
{
    if(g_bChatBlocked)
        return PLUGIN_CONTINUE;

    new szArgs[140], szName[32], szSaveArgs[140];
    read_argv(1, szArgs, charsmax(szArgs));
    remove_quotes(szArgs);
    trim(szArgs);
    copy(szSaveArgs, charsmax(szSaveArgs), szArgs);
    parse(szArgs,
        szArgs, charsmax(szArgs),
        szName, charsmax(szName));

    if(equal(szArgs, "/pm"))
    {
        if(!szName[0])
        {
            CmdMain(id);
            return PLUGIN_HANDLED;
        }

        new found_id = find_player("b", szName);
        if(found_id)
        {
            if(id == found_id || is_user_bot(found_id) || is_user_hltv(found_id))
                return PLUGIN_HANDLED;

            new szReplace[64];
            formatex(szReplace, charsmax(szReplace), "/pm %s ", szName);
            replace(szSaveArgs, sizeof(szSaveArgs), szReplace, "");

            SendMessage(id, found_id, szSaveArgs);
            return PLUGIN_HANDLED;
        }
        else
        {
            CmdMain(id);
            return PLUGIN_HANDLED;
        }
    }
    return PLUGIN_CONTINUE;
}

public CmdMain(id)
{
    if(!is_user_connected(id))
        return PLUGIN_HANDLED;

    if(!g_ePlayerData[id][RECEIVER])
        return PLUGIN_HANDLED;

    SetGlobalTransTarget(id);
    new menu = menu_create(fmt("%l", "PM_TITLE_MESSAGES"), "MainHandler");

    menu_additem(menu, fmt("%l", "PM_WRITE"));
    menu_additem(menu, fmt("%l", "PM_BLOCK"));

    new iSize = ArraySize(g_ePlayerData[id][RECEIVER]);
    menu_addtext2(menu, iSize ? fmt("%l", "PM_RECIPIENT") : fmt("%l","PM_RECIPIENT_NONE"));

    if(iSize)
    {
        new szPlayer[10];
        for(new i; i < iSize; i++)
        {
            new iPlayer = ArrayGetCell(g_ePlayerData[id][RECEIVER], i);
            if(!is_user_connected(iPlayer))
                continue;

            num_to_str(iPlayer, szPlayer, charsmax(szPlayer));
            menu_additem(menu, fmt("%n", iPlayer), szPlayer);
        }
    }

    menu_setprop(menu, MPROP_NEXTNAME, fmt("%l", "PM_NEXT"));
    menu_setprop(menu, MPROP_BACKNAME, fmt("%l", "PM_BACK"));
    menu_setprop(menu, MPROP_EXITNAME, fmt("%l", "PM_EXIT"));
    menu_setprop(menu, MPROP_NUMBER_COLOR, "\y");

    menu_display(id, menu, 0);
    return PLUGIN_HANDLED;
}

public MainHandler(id, menu, item)
{
    if(item == MENU_EXIT)
    {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }
    
    if(g_bChatBlocked)
    {
        client_print_color(id, print_team_default, "%l %l", "PM_PREFIX", "PM_BLOCKED");
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }

    new s_Data[6], s_Name[64], i_Access, i_Callback;
    menu_item_getinfo(menu, item, i_Access, s_Data, charsmax(s_Data), s_Name, charsmax(s_Name), i_Callback);
    menu_destroy(menu);
    new iPlayer = g_ePlayerData[id][TARGET] = str_to_num(s_Data);

    switch(item)
    {
        case 0:
            MenuSend(id);
        case 1:
            MenuBlock(id);
        default:
        {
            if(!ArraySize(g_ePlayerData[id][RECEIVER]))
                return PLUGIN_HANDLED;

            if(!is_user_connected(iPlayer))
                return PLUGIN_HANDLED;

            client_cmd(id, "messagemode ^"pm^"");
            CmdMain(id);
        }
    }
    return PLUGIN_HANDLED;
}

MenuSend(id, page = 0)
{
    if(!is_user_connected(id))
        return PLUGIN_HANDLED;

    SetGlobalTransTarget(id);
    new iPlayers[MAX_PLAYERS], iNum, szPlayer[10], iPlayer;
    get_players(iPlayers, iNum, "ch");

    new menu = menu_create(fmt("%l", "PM_TITLE_WRITE"), "SendHandler");

    for (new i; i < iNum; i++)
    {
        iPlayer = iPlayers[i];

        if(id == iPlayer)
            continue;

        num_to_str(iPlayer, szPlayer, charsmax(szPlayer));

        switch(g_Cvars[TYPE])
        {
            case 1: menu_additem(menu, fmt("%n", iPlayer), szPlayer);
            case 2:
            {
                if(is_user_alive(id) == is_user_alive(iPlayer))
                    menu_additem(menu, fmt("%n", iPlayer), szPlayer);
            }
            case 3:
            {
                if(get_user_team(id) == get_user_team(iPlayer))
                    menu_additem(menu, fmt("%n", iPlayer), szPlayer);
            }
        }
    }

    menu_setprop(menu, MPROP_NEXTNAME, fmt("%l", "PM_NEXT"));
    menu_setprop(menu, MPROP_BACKNAME, fmt("%l", "PM_BACK"));
    menu_setprop(menu, MPROP_EXITNAME, fmt("%l", "PM_EXIT"));
    menu_setprop(menu, MPROP_NUMBER_COLOR, "\y");

    menu_display(id, menu, page);
    return PLUGIN_CONTINUE;
}

public SendHandler(id, menu, item)
{
    if(item == MENU_EXIT)
    {
        CmdMain(id);
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }

    new s_Data[6], s_Name[64], i_Access, i_Callback;
    menu_item_getinfo(menu, item, i_Access, s_Data, charsmax(s_Data), s_Name, charsmax(s_Name), i_Callback);
    menu_destroy(menu);

    new tempid = str_to_num(s_Data);
    g_ePlayerData[id][TARGET] = tempid;

    if(g_bChatBlocked)
    {
        client_print_color(id, print_team_default, "%l %l", "PM_PREFIX", "PM_BLOCKED");
        return PLUGIN_HANDLED;
    }

    client_cmd(id, "messagemode ^"pm^"");
    MenuSend(id, item / 7);
    return PLUGIN_HANDLED;
}

MenuBlock(id, page = 0)
{
    if(!is_user_connected(id))
        return PLUGIN_HANDLED;

    SetGlobalTransTarget(id);
    new iPlayers[MAX_PLAYERS], iNum, szPlayer[10], iPlayer;
    get_players(iPlayers, iNum, "ch");

    new menu = menu_create(fmt("%l", "PM_TITLE_BLOCK"), "BlockHandler");

    for(new i; i < iNum; i++)
    {
        iPlayer = iPlayers[i];

        if(id == iPlayer)
            continue;

        num_to_str(iPlayer, szPlayer, charsmax(szPlayer));

        if(g_bPlayerBlocked[id][iPlayer])
            menu_additem(menu, fmt("%n %l", iPlayer, "PM_MENU_BLOCKED"), szPlayer);
        else
            menu_additem(menu, fmt("%n", iPlayer), szPlayer);
    }

    menu_setprop(menu, MPROP_NEXTNAME, fmt("%l", "PM_NEXT"));
    menu_setprop(menu, MPROP_BACKNAME, fmt("%l", "PM_BACK"));
    menu_setprop(menu, MPROP_EXITNAME, fmt("%l", "PM_EXIT"));
    menu_setprop(menu, MPROP_NUMBER_COLOR, "\y");

    menu_display(id, menu, page);
    return PLUGIN_CONTINUE;
}

public BlockHandler(id, menu, item)
{
    if(item == MENU_EXIT)
    {
        CmdMain(id);
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }

    new s_Data[6], s_Name[64], i_Access, i_Callback;
    menu_item_getinfo(menu, item, i_Access, s_Data, charsmax(s_Data), s_Name, charsmax(s_Name), i_Callback);
    menu_destroy(menu);

    new tempid = str_to_num(s_Data);
    new iPlayer = tempid;
    
    new ret;
    ExecuteForward(g_hForwards[PLAYER_BLOCKED], ret, id, iPlayer, g_bPlayerBlocked[id][iPlayer]);

    if(ret >= PLUGIN_HANDLED)
        return PLUGIN_HANDLED;

    g_bPlayerBlocked[id][iPlayer] = !g_bPlayerBlocked[id][iPlayer];
    MenuBlock(id, item / 7);
    return PLUGIN_HANDLED;
}

// mx?!
stock register_saycmd(const szSayCmd[], szFunc[])
{
    new const szPrefix[][] = { "say /", "say_team /", "say .", "say_team ." };
    for(new i; i < sizeof(szPrefix); i++)
        register_clcmd(fmt("%s%s", szPrefix[i], szSayCmd), szFunc);
}

stock replace_wrong_simbols(string[])
{
    new len = 0;
    for(new i; string[i] != EOS; i++)
    {
        if(string[i] == '%' || string[i] == '#' || 0x01 <= string[i] <= 0x04)
            continue;
        string[len++] = string[i];
    }
    string[len] = EOS;
}