#include <amxmodx>
#include <easytime2>
#include <sqlx>
#include <engine>
#include <amxmisc>
#include <fun>
#include <regex>
#include <regex>
#include <cstrike> 
#include <bansys>
#include <sk_utils>
#include <regsystem>
#include <manager>

#pragma compress 1

#define TASK_OFFSET_SCAN 950000
#define TASK_OFFSET_SCANKILL 60000
#define TASK_OFFSET_HUD 980000
#define TASK_OFFSET_SCANADMIN 900000

new ChoosedJudge[][] = {
	"",
	"BANSYSSCAN_JUDGE_CLEAN",
	"BANSYSSCAN_JUDGE_CFG_MODEL_RED",
	"BANSYSSCAN_JUDGE_LEFT",
	"BANSYSSCAN_JUDGE_DENIED",
	"BANSYSSCAN_JUDGE_CHEATED_RED",
	"BANSYSSCAN_JUDGE_CHEATED_RED"
}
new runningsc_scans, g_screenfade;

enum _:sc_scansystem
{
	sc_PlayerName[33],
	sc_PlayerSteamId[33],
	ScannerSelectedPlayer,
	sc_scans,
	LastScanTime,
	LastGetScannerName[33],
	Lastsc_scansc_judget,
	is_lefted,
	is_plustime,
	is_finished,
	is_scanning,
	is_scannering,
	is_scanfinish,
	is_timeout,
	sc_scanstarttime,
	sc_scanstoptime,
	sc_byid,
	sc_judget
}
new g_Scan[33][sc_scansystem];

public plugin_init()
{
	register_plugin("BanSystem API ~ Scan System", "v4.0.1", "shedi")
	register_concmd("scanmenu","openPlayerScan")
	register_clcmd("say /scankesz", "scankesz")
	register_clcmd("say /scandone", "scankesz")
	register_clcmd("say", "Hook_Say")
	register_clcmd("say_team", "Hook_Say")
	g_screenfade = get_user_msgid("ScreenFade")

	register_dictionary("general.txt");
	register_dictionary("bansystem_scan.txt");
}

public plugin_natives()
{
	register_native("get_user_scan","native_get_user_scan",1)
	register_native("get_user_scannering","native_get_user_scannering",1)
	register_native("get_user_scanby","native_get_user_scanby",1)
	register_native("reset_user_scannering","native_set_user_scannering",1)
	register_native("get_user_scannerselected","native_get_user_scannerselected",1)
	register_native("set_user_scan_judget","native_set_user_scan_judget",1)
	register_native("push_scan","native_push_scan",1)
}

public native_push_scan(const index)
{
	Pushsc_scans(index);
}

public native_get_user_scan(const index)
{
	if(g_Scan[index][is_scanning])
		return 1;
	else
		return 0;
}

public native_get_user_scannering(const index)
{
	if(g_Scan[index][is_scannering])
		return 1;
	else
		return 0;
}

public native_get_user_scanby(const index)
{
if(g_Scan[index][is_scanning])
	return g_Scan[index][sc_byid];
else
	return -1;
}

public native_set_user_scan_judget(const index, jud)
{
	g_Scan[index][sc_judget] = jud;
}

public native_get_user_scannerselected(const index)
{
	if(g_Scan[index][is_scannering])
		return g_Scan[index][ScannerSelectedPlayer];
	else
		return -1;
}

public native_set_user_scannering(const index)
{
	ResetScan(index, g_Scan[index][sc_byid])
}
public openPlayerScan(id) {
	if(get_user_adminlvl(id) == 0)
	{
		sk_chat(id, "%L ** #3452", id, "GENERAL_INSUFFICIENT_PERMISSIONS_ERROR");
		return;
	}

	if(g_Scan[id][is_scannering])
	{
		sk_chat(id, "Már van egy scan kérésed folyamatban!")
		return;
	}

	new szMenu[121], players[32], pnum, iName[32], szTempid[10]
	get_players(players, pnum, "ch")
	
	formatex(szMenu, charsmax(szMenu), "\r[\wHerBoy\r] \yOnly Dust 2 \r» \r[ \wScan kérés \r]")
	new menu = menu_create(szMenu, "hPlayerChooserScan");
	
	for(new i; i<pnum; i++)
	{
		get_user_name(players[i], iName, charsmax(iName))
		num_to_str(players[i], szTempid, charsmax(szTempid))
		menu_additem(menu, iName, szTempid)
	}
	menu_display(id, menu, 0)
}

public hPlayerChooserScan(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED
	}

	new data[6], szName[64], access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
	new key = str_to_num(data);
	
	g_Scan[id][ScannerSelectedPlayer] = key;
	if(task_exists(TASK_OFFSET_SCANADMIN+id))
		remove_task(TASK_OFFSET_SCANADMIN+id);
	
	openPlayerScanInfos(id+TASK_OFFSET_SCANADMIN)
	return PLUGIN_HANDLED;
}

public openPlayerScanInfos(id)
{
	id = id-TASK_OFFSET_SCANADMIN;
	new Selected_ID = g_Scan[id][ScannerSelectedPlayer];
	if(Selected_ID == 0)
	{
		if(task_exists(TASK_OFFSET_SCAN+id))
			remove_task(TASK_OFFSET_SCAN+id);
		
		if(task_exists(TASK_OFFSET_SCANADMIN+id))
			remove_task(TASK_OFFSET_SCANADMIN+id);
		
		if(task_exists(TASK_OFFSET_HUD+id))
			remove_task(TASK_OFFSET_HUD+id);

		return PLUGIN_HANDLED;
	}

	new iras[121]
	format(iras, charsmax(iras), "\r[\wHerBoy\r] \yOnly Dust 2 \r» \rScan kérés");
	new menu = menu_create(iras, "openScan_h");
	
	menu_addtext2(menu, fmt("\wJátékos: \r%s", g_Scan[Selected_ID][sc_PlayerName], sk_get_accountid(Selected_ID)))
	
	if(g_Scan[Selected_ID][is_scanning] == 0)
	{
		if(g_Scan[Selected_ID][sc_scans] > 0)
		{
			new LastTime[32]
			format_time(LastTime, charsmax(LastTime), "%Y.%m.%d - %H:%M:%S", g_Scan[Selected_ID][LastScanTime])
			menu_addtext2(menu, fmt("\wEddigi scankérések: \r%i", g_Scan[Selected_ID][sc_scans]))
			menu_addtext2(menu, fmt("\wUtolsó scankérés: \r%s", LastTime))
			menu_addtext2(menu, fmt("\wUtolsó scant kérte: \r%s", g_Scan[Selected_ID][LastGetScannerName]))
			menu_addtext2(menu, fmt("\wUtolsó scankérés döntése: \r%L^n", id, ChoosedJudge[g_Scan[Selected_ID][Lastsc_scansc_judget]]))
			
			if(g_Scan[Selected_ID][is_lefted] > 0)
				menu_addtext2(menu, fmt("\rVigyázz eddig %ix lelépett.^n", g_Scan[Selected_ID][is_lefted]))
		}
		else menu_addtext2(menu, "\yNincs megjeleníthető infó az előző scannekről.^n^n")
		
		menu_additem(menu, "\rScant kérek tőle", "1")
	}
	else
	{
		if(get_systime() < g_Scan[Selected_ID][sc_scanstoptime])
		{
			new sStopTime[32]
			format_time(sStopTime, charsmax(sStopTime), "%Y.%m.%d - %H:%M:%S", g_Scan[Selected_ID][sc_scanstoptime])
			menu_addtext2(menu, "Még nem járt le az ideje!")
			menu_addtext2(menu, fmt("Lejár: %s", sStopTime))
		}
		else
		{
			if(g_Scan[Selected_ID][is_plustime] && g_Scan[Selected_ID][is_scanfinish] == 0)
				menu_addtext2(menu, "\yLejárt az extra 3 perc!^n")
			else if(g_Scan[Selected_ID][is_plustime] == 0 && g_Scan[Selected_ID][is_scanfinish] == 0)
				menu_addtext2(menu, "\yNem jött válasz! Lejárt az 5 perc!^n")
			
			if(!g_Scan[Selected_ID][is_finished] && g_Scan[Selected_ID][is_plustime] == 0 && g_Scan[Selected_ID][is_scanfinish] == 0)
				menu_additem(menu, "Adok még 3 percet!^n", "2")
			else if(g_Scan[Selected_ID][is_scanfinish])
				menu_addtext2(menu, "Kész a scan!^n")
			
			menu_additem(menu, "Kitiltás \rpiros scan \windokkal.", "3")
			menu_additem(menu, "Kitiltás \rScan megtagadás \windokkal.", "4")
			menu_additem(menu, "Tiszta, kék scan.", "5")
			menu_additem(menu, "Tiszta, de modell vagy cfg miatt piros.", "6")
		}
	}
	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}

public scankesz(id)
{
	if(g_Scan[id][is_timeout])
	{
		if(task_exists(TASK_OFFSET_SCANADMIN+g_Scan[id][sc_byid]))
			remove_task(TASK_OFFSET_SCANADMIN+g_Scan[id][sc_byid]); 
		
		return;
	}
	sk_chat(id, "%L", id, "BANSYSSCAN_COMMAND_USED");
	g_Scan[id][is_scanfinish] = 1;
	g_Scan[id][sc_scanstoptime] = 0;
	
	if(task_exists(TASK_OFFSET_SCANADMIN+g_Scan[id][sc_byid]))
		remove_task(TASK_OFFSET_SCANADMIN+g_Scan[id][sc_byid]);
	
	set_task(1.0, "openPlayerScanInfos", g_Scan[id][sc_byid]+TASK_OFFSET_SCANADMIN, _,_, "b")
}

public lejartscan(id)
{
	if(task_exists(TASK_OFFSET_SCANADMIN+id))
		remove_task(TASK_OFFSET_SCANADMIN+id);
	
	id = id-TASK_OFFSET_SCANADMIN;
	
	g_Scan[g_Scan[id][ScannerSelectedPlayer]][is_timeout] = 1;
	
	set_task(1.0, "openPlayerScanInfos", id+TASK_OFFSET_SCANADMIN, _,_, "b")
}

public openScan_h(id, menu, item) {
	
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED
	}
	
	new data[9], szName[64]
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName, charsmax(szName), callback);
	new key = str_to_num(data);
	new scanid = g_Scan[id][ScannerSelectedPlayer]
	
	
	switch(key)
	{
		case 1: 
		{
			GoScan(id, scanid)
		}
		case 2:
		{
			g_Scan[scanid][is_plustime] = 1;
			g_Scan[scanid][is_timeout] = 0;
			g_Scan[scanid][sc_scanstoptime] = get_systime()+180
			
			if(task_exists(TASK_OFFSET_SCAN+id))
				remove_task(TASK_OFFSET_SCAN+id);
			
			if(task_exists(TASK_OFFSET_SCANADMIN+id))
				remove_task(TASK_OFFSET_SCANADMIN+id);
			
			set_task(10.0, "scanemlekezteto", id+TASK_OFFSET_SCAN)
			set_task(182.0, "lejartscan", id+TASK_OFFSET_SCANADMIN)
			
			sk_chat(scanid, "%L", scanid, "BANSYSSCAN_EXTRA_TIME")
			sk_chat_lang("%L", "BANSYSSCAN_EXTRA_TIME_PLAYER", g_Scan[scanid][sc_PlayerName])
		}
		case 3:
		{
			sk_chat_lang("%L", "BANSYSSCAN_BAN_RED_SCAN", g_Scan[scanid][sc_PlayerName])
			client_cmd(id, "amx_ban ^"%s^" 0 ^"%L^"", g_Scan[scanid][sc_PlayerSteamId], scanid, "BANSYSSCAN_JUDGE_CHEATED_RED")
			g_Scan[scanid][is_plustime] = 0;
			g_Scan[scanid][is_finished] = 1;
			g_Scan[scanid][sc_scanstoptime] = 0;
			g_Scan[scanid][is_scanning] = 0;
			g_Scan[scanid][sc_judget] = 6;
			g_Scan[scanid][is_timeout] = 0;
			g_Scan[id][is_scannering] = 0;
			Pushsc_scans(scanid);
			
			ResetScan(id, g_Scan[id][sc_byid])
			server_cmd("amx_cvar maxkor 60")
		}
		case 4:
		{
			sk_chat_lang("%L", "BANSYSSCAN_BAN_REFUSED", g_Scan[scanid][sc_PlayerName])
			client_cmd(id, "amx_ban ^"%s^" 0 ^"%L^"", g_Scan[scanid][sc_PlayerSteamId], scanid, "BANSYSSCAN_REFUSAL_NOTE")
			g_Scan[scanid][is_plustime] = 0;
			g_Scan[scanid][is_finished] = 1;
			g_Scan[scanid][sc_scanstoptime] = 0;
			g_Scan[scanid][is_scanning] = 0;
			g_Scan[scanid][sc_judget] = 5;
			g_Scan[scanid][is_timeout] = 0;
			g_Scan[id][is_scannering] = 0;
			Pushsc_scans(scanid);
			
			ResetScan(id, g_Scan[id][sc_byid])
			server_cmd("amx_cvar maxkor 60")
		}
		case 5:
		{
			sk_chat_lang("%L", "BANSYSSCAN_CLEAN_SCAN", g_Scan[scanid][sc_PlayerName])
			g_Scan[scanid][is_plustime] = 0;
			g_Scan[scanid][is_finished] = 1;
			g_Scan[scanid][sc_scanstoptime] = 0;
			g_Scan[scanid][is_scanning] = 0;
			g_Scan[scanid][sc_judget] = 1;
			g_Scan[scanid][is_timeout] = 0;
			g_Scan[id][is_scannering] = 0;
			Pushsc_scans(scanid);
			
			ResetScan(id, g_Scan[id][sc_byid])
			server_cmd("amx_cvar maxkor 60")
		}
		case 6:
		{
			sk_chat_lang("%L", "BANSYSSCAN_CLEAN_SCAN_WITH_ISSUE", g_Scan[scanid][sc_PlayerName])
			g_Scan[scanid][is_plustime] = 0;
			g_Scan[scanid][is_finished] = 1;
			g_Scan[scanid][sc_scanstoptime] = 0;
			g_Scan[scanid][is_scanning] = 0;
			g_Scan[scanid][sc_judget] = 2;
			g_Scan[scanid][is_timeout] = 0;
			g_Scan[id][is_scannering] = 0;
			Pushsc_scans(scanid);
			ResetScan(id, g_Scan[id][sc_byid])
			server_cmd("amx_cvar maxkor 60")
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

static FrameCall;
public server_frame()
{
	if(FrameCall < 300)
	{
		FrameCall++;
		return;
	}
	else
		FrameCall = 0;
	
	new p[32],n, id;
	get_players(p,n,"ch");
	for(new i=0;i<n;i++)
	{
		id = p[i];
		if(g_Scan[id][is_scanning] == 1)
		{
			if(g_Scan[id][is_scanfinish] == 0)
				client_print(id, print_center, fmt("%L", id, "BANSYSSCAN_SCAN_DONE_INSTRUCTIONS"));
			else
				client_print(id, print_center, fmt("%L", id, "BANSYSSCAN_WAIT_DECISION"));
			
			message_begin(MSG_ONE_UNRELIABLE, g_screenfade, {0,0,0}, id)
			write_short(1<<12)
			write_short(1<<12)
			write_short(0x0000)
			write_byte(0)
			write_byte(0)
			write_byte(0)
			write_byte(255)
			message_end()
		}
	}
}

new chlimit[33]
public GoScan(id, scanid)
{
	if(!is_user_connected(scanid))
	{
		sk_chat(id, "Ez a játékos már lelépett a szerverről!")
		return PLUGIN_HANDLED;
	}
	
	new sCurrTime[32]
	formatCurrentDateAndTime(sCurrTime, charsmax(sCurrTime))
	
	g_Scan[scanid][sc_scans]++;
	g_Scan[scanid][LastScanTime] = get_systime()
	copy(g_Scan[scanid][LastGetScannerName], 32, g_Scan[id][sc_PlayerName])
	
	
	sk_chat_lang("%L", "BANSYSSCAN_SCAN_REQUESTED", Admin_Permissions[get_user_adminlvl(id)][0], g_Scan[id][sc_PlayerName], g_Scan[scanid][sc_PlayerName])
	sk_chat(scanid, "%L", scanid, "BANSYSSCAN_REQUEST_LOGGED", sCurrTime)
	client_cmd(scanid, ";snapshot")
	
	if(task_exists(TASK_OFFSET_SCAN+scanid))
		remove_task(TASK_OFFSET_SCAN+scanid);
	
	if(task_exists(TASK_OFFSET_SCANADMIN+id))
		remove_task(TASK_OFFSET_SCANADMIN+id);
	
	if(task_exists(TASK_OFFSET_HUD+scanid))
		remove_task(TASK_OFFSET_HUD+scanid);
	
	set_task(10.0, "scanemlekezteto", scanid+TASK_OFFSET_SCAN)
	set_task(302.0, "lejartscan", id+TASK_OFFSET_SCANADMIN)
	set_task(1.0, "HudInformAndCheck", scanid+TASK_OFFSET_HUD, _,_, "b")
	
	sk_chat(id, "A scanmenü^4 5^1 perc múlva megjelenik magától!");
	sk_chat(id, "Ha lelép akkor ^3automatikus^1 kitiltást fog kapni!");
	sk_chat(scanid, "%L", scanid, "BANSYSSCAN_CHAT_ENABLED");
	sk_chat_lang("%L", "BANSYSSCAN_MAP_CHANGE_SUSPENDED");
	
	sk_chat(scanid, "%L ^4https://www.wargods.ro/wcd/download.php", scanid, "BANSYSSCAN_DOWNLOAD");
	g_Scan[scanid][is_finished] = 0;
	g_Scan[scanid][is_plustime] = 0;
	g_Scan[scanid][is_scanfinish] = 0;
	g_Scan[scanid][sc_scanstarttime] = get_systime()
	g_Scan[scanid][sc_scanstoptime] = get_systime()+300
	g_Scan[scanid][is_scanning] = 1;
	g_Scan[id][is_scannering] = 1;
	g_Scan[scanid][sc_byid] = id;
	//g_Scan[id][is_scanning] = 0;
	chlimit[scanid] = 0;
	runningsc_scans++;
	server_cmd("amx_cvar maxkor 999")

	if(task_exists(TASK_OFFSET_SCANKILL+scanid))
		remove_task(TASK_OFFSET_SCANKILL+scanid);

	set_task(1.0, "GoSpec", scanid+TASK_OFFSET_SCANKILL)

	return PLUGIN_HANDLED;
}

public HudInformAndCheck(id)
{
	id = id-TASK_OFFSET_HUD;
	
	if(g_Scan[id][is_finished] == 1)
		return;
	new temptime;
	
	if(is_user_alive(id))  
		user_silentkill(id)
	
	cs_set_user_team(id, CS_TEAM_SPECTATOR)
	
	temptime = g_Scan[id][sc_scanstoptime]-get_systime();
	
	new Lejarido[80], iLen, ExtraIdo[40];
	easy_time_length2(id, temptime, timeunit_seconds, Lejarido, charsmax(Lejarido));
	
	if(g_Scan[id][is_plustime])
		iLen += formatex(ExtraIdo[iLen], charsmax(ExtraIdo)-iLen, "%L", id, "BANSYSSCAN_EXTRA_TIME_GRANTED");
	
	if(g_Scan[id][is_scanfinish] == 0)
	{
		set_hudmessage(0, 255, 0, -1.0, 0.15, 0, 6.0, 0.9)
		show_hudmessage(id, "%L", id, "BANSYSSCAN_REQUEST_NOTICE", Lejarido, ExtraIdo);
	}
	else
	{
		set_hudmessage(0, 255, 0, -1.0, 0.15, 0, 6.0, 0.9)
		show_hudmessage(id, "%L", id, "BANSYSSCAN_WAIT_ADMIN_DECISION");
	}
}

public scanemlekezteto(id)
{
	id = id-TASK_OFFSET_SCAN;
	chlimit[id]++;
	sk_chat(id, "%L ^4https://www.wargods.ro/wcd/download.php", "BANSYSSCAN_DOWNLOAD")
	sk_chat(id, "%L", id, "BANSYSSCAN_SCAN_COMPLETE_INSTRUCTIONS");
	sk_chat(id, "%L", id, "BANSYSSCAN_PREMATURE_SCAN_WARNING");
	
	if(task_exists(TASK_OFFSET_SCAN+id))
		remove_task(TASK_OFFSET_SCAN+id);
	
	if(chlimit[id] > 3)
		set_task(10.0, "scanemlekezteto", id+TASK_OFFSET_SCAN)
}

public GoSpec(id)
{
	id = id-TASK_OFFSET_SCANKILL;

	if(is_user_alive(id))  
		user_silentkill(id)
	
	cs_set_user_team(id, CS_TEAM_SPECTATOR)

}

public LoadUsersc_scans(id)
{
	static Query[20048]
	new Data[1];
	Data[0] = id;
	
	formatex(Query, charsmax(Query), "SELECT * FROM `amx_scans` WHERE `player_id` LIKE ^"%s^" ORDER BY `id` DESC;", g_Scan[id][sc_PlayerSteamId])
	SQL_ThreadQuery(m_get_sql(), "QueryLoadScanData", Query, Data, 1); 
}

public QueryLoadScanData(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime) {
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) {
		log_amx("%s", Error);
		return PLUGIN_HANDLED;
	}
	else {
		new id = Data[0];
		new firstsc_scansc_judget;
		
		if(SQL_NumRows(Query) > 0) 
		{
			while(SQL_MoreResults(Query))
			{
				if(g_Scan[id][sc_scans] == 0)
				{
					SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "admin_name"), g_Scan[id][LastGetScannerName], 32);
					g_Scan[id][LastScanTime] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "time"));
					g_Scan[id][Lastsc_scansc_judget] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "judgetid"));
					firstsc_scansc_judget = g_Scan[id][Lastsc_scansc_judget];
				}
				g_Scan[id][Lastsc_scansc_judget] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "judgetid"));
				
				if(g_Scan[id][Lastsc_scansc_judget] == 3)
					g_Scan[id][is_lefted]++;
				
				g_Scan[id][Lastsc_scansc_judget] = firstsc_scansc_judget;
				
				g_Scan[id][sc_scans]++;
				SQL_NextRow(Query);
			}
		}
	}
	return PLUGIN_HANDLED;
}

public Pushsc_scans(id)
{
	new aid = g_Scan[id][sc_byid]
	static Query[3072];
	new Len;
	
	Len = formatex(Query[Len], charsmax(Query), "INSERT INTO `amx_scans` (`player_id`, `player_name`, `admin_id`, `admin_name`, `judgetid`, `time`) VALUES (");
	Len += formatex(Query[Len], charsmax(Query)-Len, "^"%s^", ", g_Scan[id][sc_PlayerSteamId]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "^"%s^", ", g_Scan[id][sc_PlayerName]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "^"%s^", ", g_Scan[aid][sc_PlayerSteamId]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "^"%s^", ", g_Scan[aid][sc_PlayerName]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "^"%i^", ", g_Scan[id][sc_judget]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "%i); ", get_systime());
	
	SQL_ThreadQuery(m_get_sql(), "QuerySQLScanInsert", Query);
}

public QuerySQLScanInsert(FailState, Handle:Query, Error[], Errcode, data[], DataSize, Float:Queuetime)
{
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) {
		new sTime[64];
		formatCurrentDateAndTime(sTime, charsmax(sTime));
		sk_log("BanSystem_SQLErrorLogs", fmt("[sql_insterion - QuerySQLScanInsert] (%s) Error: %s", sTime, Error))
		return PLUGIN_HANDLED;
	}
	return PLUGIN_HANDLED;
}

public ResetScan(id, scanid)
{
	runningsc_scans--;

	g_Scan[scanid][ScannerSelectedPlayer] = 0;
	g_Scan[scanid][sc_scans] = 0;
	g_Scan[scanid][is_lefted] = 0;
	g_Scan[scanid][is_plustime] = 0;
	g_Scan[scanid][is_finished] = 0;
	g_Scan[scanid][is_scanning] = 0;
	g_Scan[scanid][is_scannering] = 0;
	g_Scan[scanid][is_scanfinish] = 0;
	g_Scan[scanid][sc_scanstarttime] = 0;
	g_Scan[scanid][sc_scanstoptime] = 0;
	g_Scan[scanid][sc_judget] = 0;
	g_Scan[scanid][sc_byid] = 0;
	g_Scan[id][ScannerSelectedPlayer] = 0;
	g_Scan[id][sc_scans] = 0;
	g_Scan[id][is_lefted] = 0;
	g_Scan[id][is_plustime] = 0;
	g_Scan[id][is_finished] = 0;
	g_Scan[id][is_scanning] = 0;
	g_Scan[id][is_scannering] = 0;
	g_Scan[id][is_scanfinish] = 0;
	g_Scan[id][sc_scanstarttime] = 0;
	g_Scan[id][sc_scanstoptime] = 0;
	g_Scan[id][sc_byid] = 0;
	g_Scan[id][sc_judget] = 0;

	if(task_exists(TASK_OFFSET_SCAN+id))
		remove_task(TASK_OFFSET_SCAN+id);
	
	if(task_exists(TASK_OFFSET_SCANADMIN+id))
		remove_task(TASK_OFFSET_SCANADMIN+id);
	
	if(task_exists(TASK_OFFSET_HUD+id))
		remove_task(TASK_OFFSET_HUD+id);
	
	if(task_exists(TASK_OFFSET_SCAN+scanid))
		remove_task(TASK_OFFSET_SCAN+scanid);
	
	if(task_exists(TASK_OFFSET_SCANADMIN+scanid))
		remove_task(TASK_OFFSET_SCANADMIN+scanid);
	
	if(task_exists(TASK_OFFSET_HUD+scanid))
		remove_task(TASK_OFFSET_HUD+scanid);
}

public Hook_Say(id) {
	new Message[512];
	
	read_args(Message, charsmax(Message));
	remove_quotes(Message);

	

	if(g_Scan[id][is_scanning])
	{
		for(new i; i < 33; i++)
		{
			
			if(!is_user_connected(i) || get_user_adminlvl(i) == 0)
				continue;
				
			new ScanString[1024];
			formatex(ScanString[0], charsmax(ScanString), "^4[%L] ^1- ^3%s ^1-> ^3%s", i, "BANSYSSCAN_CHAT_PREFIX", g_Scan[id][sc_PlayerName], Message);

			if(cs_get_user_team(id) == CS_TEAM_CT)
				client_print_color(i, id, ScanString);
			else if(cs_get_user_team(id) == CS_TEAM_T)
				client_print_color(i, id, ScanString);
			else
				client_print_color(i, id, ScanString);
		}
		return PLUGIN_HANDLED;
	}
	return PLUGIN_CONTINUE;
}

public client_putinserver(id)
{
	get_user_name(id, g_Scan[id][sc_PlayerName], 33)
	get_user_authid(id, g_Scan[id][sc_PlayerSteamId], 33)

	LoadUsersc_scans(id)
}
