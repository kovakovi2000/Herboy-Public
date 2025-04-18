#include <amxmodx>
#include <amxmisc>

// Drop after ban
#define DROP_AFTER_BAN
// Detect HPP cheat with fake cvar for Steam users
//#define DETECT_STEAMONLY_UNSAFE_METHOD
// Log detections in chat
//#define SHOW_IN_CHAT
// Log users who cannot be checked
//#define SHOW_PROTECTOR_IN_LOG
// Disable multiple detections
#define ONCE_DETECT
// Detect query_cvar bypass 
#define QUERY_CVAR_BYPASS_DETECT

#if defined DETECT_STEAMONLY_UNSAFE_METHOD || defined DROP_AFTER_BAN || defined QUERY_CVAR_BYPASS_DETECT
#include <reapi>
#endif

// Enter ban command string. 
// Parameters [username] [ip] [steamid] [userid] [hackname]. For example, "amx_offban [steamid] 1000". 
// Warning: may produce false positives if the server lags during checks!
//#define BAN_CMD_DETECTED "amx_ban 1000 #[userid] ^"[hackname] HACK DETECTED^""

new const Plugin_sName[] = "Unreal Cheat Detector";
new const Plugin_sVersion[] = "1.6";
new const Plugin_sAuthor[] = "Karaulov";

// Default cvar host_limitlocal is not protected by cl_filterstuffcmd and can be modified,
// so if the cvar remains unchanged, it means a bypass is in place for detection, which this new version considers.
new g_sCvarName1[] = "host_limitlocal";
new g_sCheatName1[] = "HPP v6";
new g_bFiltered1 = false;

// Default cvar cl_righthand is protected by cl_filterstuffcmd
// Requires additional check for the presence of cl_filterstuffcmd protector
new g_sCvarName2[] = "cl_righthand";
new g_sCheatName2[] = "INTERIUM";
new g_bFiltered2 = true;

// Default cvar cl_lw is protected by cl_filterstuffcmd
// Requires additional check for the presence of cl_filterstuffcmd protector
// Can be used to detect multiple cheats
new g_sCvarName3[] = "cl_lw";
new g_sCheatName3[] = "GENERIC 1";
new g_bFiltered3 = true;

// Default cvar cl_lc is protected by cl_filterstuffcmd
// Requires additional check for the presence of cl_filterstuffcmd protector
// Can be used to detect multiple cheats
new g_sCvarName4[] = "cl_lc";
new g_sCheatName4[] = "GENERIC 2";
new g_bFiltered4 = true;

// Enter any cvar here that you consider safe to modify to avoid being banned by anti-cheats.
// It should restore itself after a restart and should not affect gameplay (as a precaution).
// This cvar should be protected by cl_filterstuffcmd
// THIS CVAR RESTORES ON THE NEXT FRAME :)
//new g_sTempServerCvar[] = "host_framerate"; false detect 'serverov' bad cs 16 build
new g_sTempServerCvar[] = "cl_dlmax";

new g_sUserIds[MAX_PLAYERS + 1][32];
new g_sUserNames[MAX_PLAYERS + 1][33];
new g_sUserIps[MAX_PLAYERS + 1][33];
new g_sUserAuths[MAX_PLAYERS + 1][64];
new g_sCheatNames[MAX_PLAYERS + 1][64];
new g_sCurrentCvarForCheck[MAX_PLAYERS + 1][64];
new g_sCvarName1Backup[MAX_PLAYERS + 1][64];
new g_sTempSVCvarBackup[MAX_PLAYERS + 1][64];

new g_bFiltered[MAX_PLAYERS + 1] = {true,...};
new g_bAnswered[MAX_PLAYERS + 1] = {false,...};

#if defined QUERY_CVAR_BYPASS_DETECT
new Float:g_fPlayerLastPing[MAX_PLAYERS + 1] = {0.0,...};
#endif

new rate_check_value = 99999;

public plugin_init()
{
	register_plugin(Plugin_sName, Plugin_sVersion, Plugin_sAuthor);
	//register_cvar("unreal_cheat_detect", Plugin_sVersion, FCVAR_SERVER | FCVAR_SPONLY);
	rate_check_value = random_num(10001, 99999);

#if defined QUERY_CVAR_BYPASS_DETECT
	RegisterHookChain(RG_PM_Move, "PM_Move_Post", .post = true);
#endif
}

#if defined QUERY_CVAR_BYPASS_DETECT
public PM_Move_Post(id)
{
	if (id < 1 || id > MAX_PLAYERS)
		return HC_CONTINUE;

	g_fPlayerLastPing[id] = get_gametime();
	return HC_CONTINUE;
}
#endif

public client_connectex(id, const name[], const ip[], reason[128])
{   
	remove_task(id);
	copy(g_sUserNames[id],charsmax(g_sUserNames[]), name);
	copy(g_sUserIps[id],charsmax(g_sUserIps[]), ip);
	strip_port(g_sUserIps[id], charsmax(g_sUserIps[]));
	g_sUserAuths[id][0] = EOS;
	g_sUserIds[id][0] = EOS;
}

public client_authorized(id, const authid[])
{
	copy(g_sUserAuths[id],charsmax(g_sUserAuths[]), authid);
}

public client_putinserver(id)
{
	formatex(g_sUserIds[id], charsmax(g_sUserIds[]), "%d", get_user_userid(id));
	if (is_user_bot(id) || is_user_hltv(id))
		return;

	g_bAnswered[id] = true;
	new Float:fTask2 = random_float(90.0, 500.0);

	set_task(10.0, "init_hack_cvar1_check", id);
	set_task(fTask2, "init_hack_cvar1_check", id);
	fTask2 += 20.0;

	set_task(30.0, "init_hack_cvar2_check", id);
	set_task(fTask2, "init_hack_cvar2_check", id);
	fTask2 += 20.0;

	set_task(50.0, "init_hack_cvar3_check", id);
	set_task(fTask2, "init_hack_cvar3_check", id);
	fTask2 += 20.0;
	
	set_task(70.0, "init_hack_cvar4_check", id);
	set_task(fTask2, "init_hack_cvar4_check", id);
}

public client_disconnected(client)
{
	remove_task(client);
}

public init_hack_cvar1_check(id)
{
	if (!is_user_connected(id))
		return;

	if (!g_bAnswered[id])
	{
		remove_task(id);
#if defined QUERY_CVAR_BYPASS_DETECT
		if (get_gametime() - g_fPlayerLastPing[id] < 0.2)
		{
			copy(g_sCheatNames[id],charsmax(g_sCheatNames[]),"CVAR BYPASS");
			set_task(0.01, "drop_client_delayed", id);
		}
#endif
		return;
	}
	g_bAnswered[id] = false;

	copy(g_sCurrentCvarForCheck[id],charsmax(g_sCurrentCvarForCheck[]),g_sCvarName1);
	copy(g_sCheatNames[id],charsmax(g_sCheatNames[]),g_sCheatName1);

	g_bFiltered[id] = g_bFiltered1;

	if (!is_user_connected(id))
		return;
	// Request the value of cvar g_sCurrentCvarForCheck
	query_client_cvar(id, g_sCurrentCvarForCheck[id], "check_detect_cvar_defaultvalue");
}

public init_hack_cvar2_check(id)
{
	if (!is_user_connected(id))
		return;

	if (!g_bAnswered[id])
	{
		remove_task(id);
#if defined QUERY_CVAR_BYPASS_DETECT
		if (get_gametime() - g_fPlayerLastPing[id] < 0.2)
		{
			copy(g_sCheatNames[id],charsmax(g_sCheatNames[]),"CVAR BYPASS");
			set_task(0.01, "drop_client_delayed", id);
		}
#endif
		return;
	}
	g_bAnswered[id] = false;

	copy(g_sCurrentCvarForCheck[id],charsmax(g_sCurrentCvarForCheck[]),g_sCvarName2);
	copy(g_sCheatNames[id],charsmax(g_sCheatNames[]),g_sCheatName2);

	g_bFiltered[id] = g_bFiltered2;

	query_client_cvar(id, g_sCurrentCvarForCheck[id], "check_detect_cvar_defaultvalue");
}

public init_hack_cvar3_check(id)
{
	if (!is_user_connected(id))
		return;

	if (!g_bAnswered[id])
	{
		remove_task(id);
#if defined QUERY_CVAR_BYPASS_DETECT
		if (get_gametime() - g_fPlayerLastPing[id] < 0.2)
		{
			copy(g_sCheatNames[id],charsmax(g_sCheatNames[]),"CVAR BYPASS");
			set_task(0.01, "drop_client_delayed", id);
		}
#endif
		return;
	}
	g_bAnswered[id] = false;

	copy(g_sCurrentCvarForCheck[id],charsmax(g_sCurrentCvarForCheck[]),g_sCvarName3);
	copy(g_sCheatNames[id],charsmax(g_sCheatNames[]),g_sCheatName3);

	g_bFiltered[id] = g_bFiltered3;

	query_client_cvar(id, g_sCurrentCvarForCheck[id], "check_detect_cvar_defaultvalue");
}

public init_hack_cvar4_check(id)
{
	if (!is_user_connected(id))
		return;

	if (!g_bAnswered[id])
	{
		remove_task(id);
#if defined QUERY_CVAR_BYPASS_DETECT
		if (get_gametime() - g_fPlayerLastPing[id] < 0.2)
		{
			copy(g_sCheatNames[id],charsmax(g_sCheatNames[]),"CVAR BYPASS");
			set_task(0.01, "drop_client_delayed", id);
		}
#endif
		return;
	}
	g_bAnswered[id] = false;

	copy(g_sCurrentCvarForCheck[id],charsmax(g_sCurrentCvarForCheck[]),g_sCvarName4);
	copy(g_sCheatNames[id],charsmax(g_sCheatNames[]),g_sCheatName4);

	g_bFiltered[id] = g_bFiltered4;

	query_client_cvar(id, g_sCurrentCvarForCheck[id], "check_detect_cvar_defaultvalue");
}

public check_detect_cvar_defaultvalue(id, const cvar[], const value[])
{
	if (!is_user_connected(id))
		return;

	copy(g_sCvarName1Backup[id],charsmax(g_sCvarName1Backup[]),value);

	if(str_to_float(value) != 0.0)
	{
		WriteClientStuffText(id, "%s 0^n",g_sCurrentCvarForCheck[id]);
		WriteClientStuffText(id, "%s 0^n",g_sCurrentCvarForCheck[id]);
	}
	else 
	{
		WriteClientStuffText(id, "%s 1^n",g_sCurrentCvarForCheck[id]);
		WriteClientStuffText(id, "%s 1^n",g_sCurrentCvarForCheck[id]);
	}
	
	set_task(0.15,"check_detect_cvar_value_task",id);
}

public check_detect_cvar_value_task(id)
{
	if (!is_user_connected(id))
		return;

	query_client_cvar(id, g_sCurrentCvarForCheck[id], "check_detect_cvar_value2");
}

public check_detect_cvar_value2(id, const cvar[], const value[])
{
	if (!is_user_connected(id))
		return;
	
	// Reset default g_sCurrentCvarForCheck[id] value
	WriteClientStuffText(id, "%s %s^n",g_sCurrentCvarForCheck[id],g_sCvarName1Backup[id]);
	WriteClientStuffText(id, "%s %s^n",g_sCurrentCvarForCheck[id],g_sCvarName1Backup[id]);

	if (equal(g_sCvarName1Backup[id], value))
	{
		query_client_cvar(id, g_sTempServerCvar, "check_protector_default");
	}
	else 
	{
		g_bAnswered[id] = true;
	}
}

public check_protector_default(id, const cvar[], const value[])
{
	if (!is_user_connected(id))
		return;

	if (str_to_float(value) == float(rate_check_value))
		rate_check_value -= 1;

	copy(g_sTempSVCvarBackup[id],charsmax(g_sTempSVCvarBackup[]),value);

	WriteClientStuffText(id, "%s %d^n",g_sTempServerCvar,rate_check_value);
	WriteClientStuffText(id, "%s %d^n",g_sTempServerCvar,rate_check_value);
	
	RequestFrame("check_protector_task",id);
}

public check_protector_task(id)
{
	if (!is_user_connected(id))
		return;

	set_task(0.01,"check_protector_task2",id)
}

public check_protector_task2(id)
{
	if (!is_user_connected(id))
		return;

	query_client_cvar(id, g_sTempServerCvar, "check_protector2");
}

public check_protector2(id, const cvar[], const value[])
{
	if (!is_user_connected(id))
		return;

	g_bAnswered[id] = true;
	
	// Reset default g_sCurrentCvarForCheck[id] value
	WriteClientStuffText(id, "%s %s^n",g_sTempServerCvar,g_sTempSVCvarBackup[id]);
	WriteClientStuffText(id, "%s %s^n",g_sTempServerCvar,g_sTempSVCvarBackup[id]);

	new username[33];
	get_user_name(id,username,charsmax(username));
	
	if(str_to_float(value) == float(rate_check_value))
	{
#if defined SHOW_IN_CHAT
		client_print_color(0, print_team_red, "^4[CHEAT DETECTOR]^3: User^1 %s^3 [^1%s^3] uses cheat ^1%s^3!",username, g_sUserAuths[id], g_sCheatNames[id]);
#endif
		log_to_file("unreal_cheat_detect.log", "[CHEAT DETECTOR]: User %s [%s] [%s] uses cheat %s!",username, g_sUserAuths[id], g_sUserIps[id], g_sCheatNames[id]);
#if defined ONCE_DETECT
		remove_task(id);
#endif
#if defined BAN_CMD_DETECTED
		static banstr[256];
		copy(banstr,charsmax(banstr), BAN_CMD_DETECTED);
		replace_all(banstr,charsmax(banstr),"[username]",g_sUserNames[id]);
		replace_all(banstr,charsmax(banstr),"[ip]",g_sUserIps[id]);
		replace_all(banstr,charsmax(banstr),"[userid]",g_sUserIds[id]);
		replace_all(banstr,charsmax(banstr),"[hackname]",g_sCheatNames[id]);
		if (replace_all(banstr,charsmax(banstr),"[steamid]",g_sUserAuths[id]) > 0 && g_sUserAuths[id][0] == EOS)
		{
			log_to_file("unreal_cheat_detect.log","[ERROR] Invalid ban string: %s",banstr);
		}
		else 
		{
			server_cmd("%s", banstr);
			log_to_file("unreal_cheat_detect.log",banstr);
		}
#endif
#if defined DROP_AFTER_BAN
		set_task(0.1, "drop_client_delayed", id);
#endif
	}
#if defined DETECT_STEAMONLY_UNSAFE_METHOD
	else if (!g_bFiltered[id])
	{
		if (is_user_steam(id))
		{
#if defined SHOW_IN_CHAT
			client_print_color(0, print_team_red, "^4[CHEAT DETECTOR]^3: User^1 %s^3 [^1%s^3] possibly uses cheat ^1%s^3!",username, g_sUserAuths[id], g_sCheatNames[id]);
#endif
			log_to_file("unreal_cheat_detect.log", "[CHEAT DETECTOR]: User %s [%s] [%s] possibly cheat %s!",username, g_sUserAuths[id], g_sUserIps[id], g_sCheatNames[id]);
#if defined ONCE_DETECT
			remove_task(id);
#endif
#if defined DROP_AFTER_BAN
			set_task(0.1, "drop_client_delayed", id);
#endif
		}
		else 
		{
#if defined SHOW_PROTECTOR_IN_LOG
			log_to_file("unreal_cheat_detect.log", "[CHEAT DETECTOR]: User %s cannot be checked because he uses Protector.",username);
#endif
			remove_task(id);
		}
	}
#endif
	else
	{
#if defined SHOW_PROTECTOR_IN_LOG
		log_to_file("unreal_cheat_detect.log", "[CHEAT DETECTOR]: User %s cannot be checked because he uses Protector.",username);
#endif
		remove_task(id);
	}
}
#if defined DROP_AFTER_BAN
public drop_client_delayed(id)
{
	if (is_user_connected(id))
	{
		static cheat[64];
		formatex(cheat, charsmax(cheat), "Cheat Detected:[%s]", g_sCheatNames[id]);
		rh_drop_client(id, cheat);
	}
}
#endif

stock WriteClientStuffText(const index, const message[], any:... )
{
	new buffer[256];
	new numArguments = numargs();
	
	if (numArguments == 2)
	{
		message_begin(MSG_ONE, SVC_STUFFTEXT, _, index);
		write_string(message);
		message_end();
	}
	else 
	{
		vformat(buffer, charsmax(buffer), message, 3);
		message_begin(MSG_ONE, SVC_STUFFTEXT, _, index);
		write_string(buffer);
		message_end();
	}
}

stock strip_port(address[], length)
{
	for (new i = length - 1; i >= 0; i--)
	{
		if (address[i] == ':')
		{
			address[i] = EOS;
			return;
		}
	}
}
