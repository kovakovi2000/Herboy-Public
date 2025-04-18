#include <amxmodx>
#include <amxmisc>
#include <reapi>
#include <sk_utils>

new const Plugin_sName[] = "CheatCrasher";
new const Plugin_sVersion[] = "1.8";
new const Plugin_sAuthor[] = "Kova";

// !!!! SETTINGS ARE LOCATED HERE !!!!
// Settings (value true - option enabled, value false - option disabled)
// 1) use an unsafe cheater crash method for Steam users (not recommended if GSCLIENT is running in Steam mode)
new const bool:UNSAFE_METHODS_FOR_STEAM = false;
// 2) hides kills (may slightly reduce protection)
new const bool:HIDE_NAMES_FROM_KILLFEED = true;
// 4) fast drop detection (not implemented in version 1.7!)
//new const bool:FAST_CRASH_DETECTION = false;

// Methods to crash cheats, in some cheats it does not check boundaries and causes a crash
// 1) sends a message about kills of non-existent players
new const bool:USE_METHOD_1 = true;
// 2) sends false team data for non-existent players
new const bool:USE_METHOD_2 = true;
// 3) attempts to crash protectors used in cheats, option is untested and may be unstable (not recommended!)
new const bool:USE_METHOD_3 = false;
// 4) attempts to crash ESP cheats, option is untested and may be unstable (not recommended!)
new const bool:USE_METHOD_4 = false;
// 5) sends false scoreboard parameters for non-existent players
new const bool:USE_METHOD_5 = true;
// 6) sends a non-existent sound (may increase player connection time by a few seconds, reliably crashes cheats "alternative 2020" and "2021")
new const bool:USE_METHOD_6 = true;

// !!!! END OF SETTINGS !!!!

new g_sUserIds[MAX_PLAYERS + 1][32];
new g_sUserNames[MAX_PLAYERS + 1][33];
new g_sUserIps[MAX_PLAYERS + 1][33];
new g_sUserAuths[MAX_PLAYERS + 1][65];
new bool:g_bUserWait[MAX_PLAYERS + 1] = {false,...};
new bool:g_bUserCrash[MAX_PLAYERS + 1] = {false,...};
new Float:g_fUserWait[MAX_PLAYERS + 1] = {0.0,...};
new g_iCrashOffset[MAX_PLAYERS + 1][7];
new g_sCrashSound[64];
new counter[33];

//
new const MAGIC_TASK_NUMBER_CRASH_OFFSET = 1000;
new const MAGIC_TASK_NUMBER_CHECK_OFFSET = 2000;

// Plugin initialization
public plugin_init()
{
// Register plugin, name version and author
	register_plugin(Plugin_sName, Plugin_sVersion, Plugin_sAuthor);
	// Register server cvar to find all servers with this great plugin
	//register_cvar("unreal_cheater_cry", Plugin_sVersion, FCVAR_SERVER | FCVAR_SPONLY);
	// Register regular movement and air movement packets
	RegisterHookChain(RG_PM_Move, "PM_Move", .post = false);
	register_concmd("excluded_method_2", "excluded_method_2", ADMIN_RCON);
}

new bool:g_ExcludeMETHOD2[MAX_PLAYERS + 1] = {false,...};
public excluded_method_2(id)
{
	if (id != 0)
		return PLUGIN_HANDLED;

	new sTarget[33];
	read_argv(1, sTarget, charsmax(sTarget));

	new tid = cmd_target(id, sTarget, 2);
	console_print(id, "Method 2 is excluded for player %d [%s]", tid, sTarget);

	g_ExcludeMETHOD2[tid] = true;

	return PLUGIN_HANDLED;
}

public plugin_precache()
{
	new tmpString[64];
	RandomString(tmpString, 20);
	formatex(g_sCrashSound, 64, "player/%s.wav", tmpString);
	precache_sound(g_sCrashSound);
}

// Player starts connecting to the server
public client_connectex(id, const name[], const ip[], reason[128])
{   
// When client connects, save their nickname and IP address
	copy(g_sUserNames[id],charsmax(g_sUserNames[]), name);
	copy(g_sUserIps[id],charsmax(g_sUserIps[]), ip);
	strip_port(g_sUserIps[id], charsmax(g_sUserIps[]));
	g_sUserAuths[id][0] = EOS;
	g_sUserIds[id][0] = EOS;
	
// When client connects, remove all tasks with player number
	if(task_exists(id))
		remove_task(id);

	if(task_exists(id + MAGIC_TASK_NUMBER_CRASH_OFFSET))
		remove_task(id + MAGIC_TASK_NUMBER_CRASH_OFFSET);

	if(task_exists(id + MAGIC_TASK_NUMBER_CHECK_OFFSET))
		remove_task(id + MAGIC_TASK_NUMBER_CHECK_OFFSET);
		
// Set the check flag to false
	g_bUserWait[id] = false;
	g_bUserCrash[id] = false;
	g_ExcludeMETHOD2[id] = false;
	
	return PLUGIN_CONTINUE;
}

public client_authorized(id, const authid[])
{
	copy(g_sUserAuths[id],charsmax(g_sUserAuths[]), authid);
}

// Player connected to server
public client_putinserver(id)
{
	if (is_user_hltv(id) || is_user_bot(id)) return;
	
// Set the check flag to false
	g_bUserWait[id] = false;
	g_bUserCrash[id] = false;
	formatex(g_sUserIds[id], charsmax(g_sUserIds[]), "%d", get_user_userid(id));
	
// When client connects, remove all tasks with player number
	if(task_exists(id))
		remove_task(id);
	if(task_exists(id + MAGIC_TASK_NUMBER_CRASH_OFFSET))
		remove_task(id + MAGIC_TASK_NUMBER_CRASH_OFFSET);

	if(task_exists(id + MAGIC_TASK_NUMBER_CHECK_OFFSET))	
		remove_task(id + MAGIC_TASK_NUMBER_CHECK_OFFSET);
		
// Start two crash attempts, immediately, and after a few minutes
// in case cheater enables cheats outside of gameplay
	//g_bUserCrash[id] = true;

	counter[id] = 0;
	set_task(random_float(120.0,300.0),"start_make_cheater_cry",id);
}

// Player disconnected from server
public client_disconnected(id, bool:drop, message[], maxlen)
{
	// When client disconnects, remove all tasks with player number
	if(task_exists(id))
		remove_task(id);

	if(task_exists(id + MAGIC_TASK_NUMBER_CRASH_OFFSET))
		remove_task(id + MAGIC_TASK_NUMBER_CRASH_OFFSET);

	if(task_exists(id + MAGIC_TASK_NUMBER_CHECK_OFFSET))
		remove_task(id + MAGIC_TASK_NUMBER_CHECK_OFFSET);

	if (drop && equal(message,"Timed out") && g_bUserWait[id])
	{
		//[TD: 88.2784042.3f] sv_timeout 90
		//[TD: 8.3079522.3f] sv_timeout 10
		//[TD: 58.3045042.3f] sv_timeout 60
		new Float:gametime = get_gametime();
		new Float:timeout = float(get_cvar_num("sv_timeout"));
		new Float:Estimated_timeout = gametime - g_fUserWait[id];
		new Float:diff = get_gametime() - g_fUserWait[id] - float(get_cvar_num("sv_timeout")) - 1.7;

		if (Estimated_timeout > timeout-5.0 && Estimated_timeout < timeout+5.0)
		{
			sk_log("cheat_crasher", fmt("Player [%s] | %s | %s | %.2fsec", g_sUserNames[id], g_sUserIps[id], g_sUserAuths[id], diff));
			
			callfunc_begin("amx_crash_ban","BanSystemv4.amxx");
			callfunc_push_str(g_sUserAuths[id]);
			callfunc_push_float(diff);
			callfunc_end();
		}
	}
 
	g_bUserWait[id] = false;
	g_bUserCrash[id] = false;
	g_ExcludeMETHOD2[id] = false;
}


// If player sends MOVE packet, they were not kicked. 
// Set the check flag to false
public PM_Move(const id)
{
	if ( id >= 1 && id <= MaxClients )
	{
		if (g_bUserWait[id] && get_gametime() - g_fUserWait[id] > 0.7)
		{
			g_bUserWait[id] = false;
		}
		if (g_bUserCrash[id])
		{                
			g_bUserCrash[id] = false;
			
			for(new i = 0; i < sizeof(g_iCrashOffset[]); i++)
			{
				g_iCrashOffset[id][i] = 33;
			}
			
			set_task(0.01,"do_crash",id + MAGIC_TASK_NUMBER_CRASH_OFFSET);
		}
	}
}

public do_crash(idx)
{
	new id = idx - MAGIC_TASK_NUMBER_CRASH_OFFSET;

	if (!make_cheater_cry_method1(id) &&
		!make_cheater_cry_method2(id) &&
		!make_cheater_cry_method3(id) &&
		!make_cheater_cry_method4(id) &&
		!make_cheater_cry_method6(id) &&
		!make_cheater_cry_method5(id))
	{
		if (is_user_connected(id))
		{
			new user_message[64];
			formatex(user_message,charsmax(user_message),"ModificationDetector:%.2f | %i DONE", get_gametime(), counter[id]);
			write_demo_info(id, user_message);
			client_cmd(id, "clear");
		}
		
		g_bUserWait[id] = true;
		g_fUserWait[id] = get_gametime();
		return;
	}

	g_bUserWait[id] = true;
	g_fUserWait[id] = get_gametime();
	set_task(0.01,"do_crash",id + MAGIC_TASK_NUMBER_CRASH_OFFSET);
}

// Crash function using 5 different methods that should cause crashes 
// if client modifications (cheat programs) are in use
public start_make_cheater_cry(id)
{
	if (is_user_connected(id))
	{
		if(!is_user_alive(id))
		{
			new user_message[64];
			formatex(user_message,charsmax(user_message),"ModificationDetector:%.2f | %i INIT", get_gametime(), ++counter[id]);
			write_demo_info(id, user_message);

			set_task(10.0,"delay_testing",id+MAGIC_TASK_NUMBER_CHECK_OFFSET);
		}
		else
		{
			set_task(5.0,"start_make_cheater_cry",id);
		}
	}
}

public delay_testing(id)
{
	id -= MAGIC_TASK_NUMBER_CHECK_OFFSET;
	if(!is_user_connected(id))
		return;
	
	set_task(random_float(600.0,1200.0),"start_make_cheater_cry",id);

	g_bUserCrash[id] = true;
}

public bool:make_cheater_cry_method1(id)
{
	if (!USE_METHOD_1)
	{
		return false;
	}

	if (!is_user_connected(id))
		return false;

	new user_message[64];
	formatex(user_message,charsmax(user_message),"ModificationDetector:%.2f | M1", get_gametime());
	write_demo_info(id, user_message);

	static deathMsg = 0;

	if ( deathMsg == 0 )
		deathMsg = get_user_msgid ( "DeathMsg" );

	new deathMax = 65;
	if (UNSAFE_METHODS_FOR_STEAM && is_user_steam(id))
	{	
		deathMax = 255;
	}

	if (g_iCrashOffset[id][1] >= deathMax)
	{
		return false;
	}

	for(new i = 0; i <= 5; i++)
	{
		if (g_iCrashOffset[id][1] >= 65)
		{
			if (deathMax == 255)
			{
				g_iCrashOffset[id][1] = 1000;
				message_begin( MSG_ONE, deathMsg, _,id );
				write_byte( HIDE_NAMES_FROM_KILLFEED ? 0 : id );
				write_byte( 255 );
				write_byte( 0  );
				write_string( "knife" );
				message_end();

				message_begin( MSG_ONE, deathMsg, _,id );
				write_byte( HIDE_NAMES_FROM_KILLFEED ? 0 : id );
				write_byte( 124 );
				write_byte( 0  );
				write_string( "knife" );
				message_end();

				message_begin( MSG_ONE, deathMsg, _,id );
				write_byte( HIDE_NAMES_FROM_KILLFEED ? 0 : id );
				write_byte( 125 );
				write_byte( 1 );
				write_string( "deagle" );
				message_end();
			}
			return false;
		}

		if (g_iCrashOffset[id][1] >= 33)
		{
			message_begin( MSG_ONE, deathMsg, _,id );
			write_byte( HIDE_NAMES_FROM_KILLFEED ? 0 : id );
			write_byte( g_iCrashOffset[id][1] );
			write_byte( 0  );
			write_string( "knife" );
			message_end();
			
			message_begin( MSG_ONE, deathMsg, _,id );
			write_byte( HIDE_NAMES_FROM_KILLFEED ? 0 : id );
			write_byte( g_iCrashOffset[id][1] );
			write_byte( 1 );
			write_string( "deagle" );
			message_end();

			message_begin( MSG_ONE, deathMsg, _,id );
			write_byte( HIDE_NAMES_FROM_KILLFEED ? 0 : id );
			write_byte( g_iCrashOffset[id][1] );
			write_byte( 1  );
			write_string( "knife" );
			message_end();

			message_begin( MSG_ONE, deathMsg, _,id );
			write_byte( HIDE_NAMES_FROM_KILLFEED ? 0 : id );
			write_byte( g_iCrashOffset[id][1] );
			write_byte( 0 );
			write_string( "deagle" );
			message_end();
		}

		g_iCrashOffset[id][1]++;
	}

	return true;
}

public bool:make_cheater_cry_method2(id)
{
	if (!USE_METHOD_2 || g_ExcludeMETHOD2[id])
	{
		return false;
	}

	if (!is_user_connected(id))
		return false;

	new user_message[64];
	formatex(user_message,charsmax(user_message),"ModificationDetector:%.2f | M2", get_gametime());
	write_demo_info(id, user_message);

	static teamInfo = 0;

	if ( teamInfo == 0 )
		teamInfo = get_user_msgid ( "TeamInfo" );

	if (g_iCrashOffset[id][2] >= 256)
			return false;

	for(new i = 0; i <= 12; i++)
	{
		if (g_iCrashOffset[id][2] >= 256)
			return false;
		
		if (g_iCrashOffset[id][2] >= 36)
		{
			message_begin( MSG_ONE, teamInfo, _,id );
			write_byte( g_iCrashOffset[id][2]  );
			write_string( "KILL_BAD_CHEATERS_KILL_KILL_KILL_KILL_KILL_KILL" );
			message_end();
		}
		g_iCrashOffset[id][2]++;
	}
	return true;
}

public bool:make_cheater_cry_method3(id)
{
	if (!USE_METHOD_3)
	{
		return false;
	}

	if (!is_user_connected(id))
		return false;
		
	new user_message[64];
	formatex(user_message,charsmax(user_message),"ModificationDetector:%.2f | M3", get_gametime());
	write_demo_info(id, user_message);

	message_begin( MSG_ONE, SVC_STUFFTEXT, _,id );
	write_string( "" );
	message_end();
	message_begin( MSG_ONE, SVC_STUFFTEXT, _,id );
	write_string( ";" );
	message_end();
	message_begin( MSG_ONE, SVC_STUFFTEXT, _,id );
	write_string( "^n" );
	message_end();

	return false;
}

public bool:make_cheater_cry_method4(id)
{
	if (!USE_METHOD_4)
	{
		return false;
	}

	if (!is_user_connected(id))
		return false;

	new user_message[64];
	formatex(user_message,charsmax(user_message),"ModificationDetector:%.2f | M4", get_gametime());
	write_demo_info(id, user_message);

	message_begin(MSG_ONE, SVC_SPAWNSTATICSOUND, .player = id);
	write_coord_f(random_float(-1000.0,1000.0));
	write_coord_f(random_float(-1000.0,1000.0));
	write_coord_f(random_float(-1000.0,1000.0));
	write_short(511);
	write_byte(255);
	write_byte(255);
	write_short(id == 1 ? 2 : 1); 
	write_byte(255);
	write_byte(0);
	message_end();
   
	message_begin(MSG_ONE, SVC_SPAWNSTATICSOUND, .player = id);
	write_coord_f(random_float(-1000.0,1000.0));
	write_coord_f(random_float(-1000.0,1000.0));
	write_coord_f(random_float(-1000.0,1000.0));
	// If pitch > 0, crash even for clients without cheats :)
	write_short(512);
	write_byte(255);
	write_byte(255);
	write_short(id == 1 ? 2 : 1); 
	write_byte(0);
	write_byte(0);
	message_end();
	return false;
}

public bool:make_cheater_cry_method5(id)
{
	if (!USE_METHOD_5)
	{
		return false;
	}

	if (!is_user_connected(id))
		return false;

	new user_message[64];
	formatex(user_message,charsmax(user_message),"ModificationDetector:%.2f | M5", get_gametime());
	write_demo_info(id, user_message);

	static scoreAttrib = 0;

	if ( scoreAttrib == 0 )
		scoreAttrib = get_user_msgid ( "ScoreAttrib" );

	if (g_iCrashOffset[id][5] >= 256)
			return false;

	for(new i = 0; i <= 12; i++)
	{
		if (g_iCrashOffset[id][5] >= 256)
			return false;
		
		if (g_iCrashOffset[id][5] >= 33)
		{
			message_begin( MSG_ONE, scoreAttrib, _,id );
			write_byte( g_iCrashOffset[id][5] );
			write_byte( 0 );
			message_end();

			message_begin( MSG_ONE, scoreAttrib, _,id );
			write_byte( g_iCrashOffset[id][5] );
			write_byte( 0xF );
			message_end();
		}

		g_iCrashOffset[id][5]++;
	}
	return true;
}

public bool:make_cheater_cry_method6(id)
{
	if (!USE_METHOD_6)
	{
		return false;
	}

	if (!is_user_connected(id))
		return false;

	new user_message[64];
	formatex(user_message,charsmax(user_message),"ModificationDetector:%.2f | M6", get_gametime());
	write_demo_info(id, user_message);

	rh_emit_sound2(id, id, random_num(0,100) > 50 ? CHAN_VOICE : CHAN_STREAM, g_sCrashSound, VOL_NORM, ATTN_NORM);
	return false;
}

new const g_CharSet[] = "abcdefghijklmnopqrstuvwxyz";

stock RandomString(dest[], length)
{
	new i, randIndex;
	new charsetLength = strlen(g_CharSet);

	for (i = 0; i < length; i++)
	{
		randIndex = random(charsetLength);
		dest[i] = g_CharSet[randIndex];
	}

	dest[length - 1] = EOS;  // Null-terminate the string
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

public write_demo_info(id, info[])
{
	if(is_user_connected(id))
	{
		message_begin(MSG_ONE, SVC_SENDEXTRAINFO, _, id);
		write_string(info);
		write_byte(0);
		message_end();
	}
}