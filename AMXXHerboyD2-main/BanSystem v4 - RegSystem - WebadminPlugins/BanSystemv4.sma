#include <amxmodx>
#include <easytime2>
#include <sqlx>
#include <regex>
#include <engine>
#include <amxmisc>
#include <fun>
#include <regex>
#include <regex>
#include <cstrike> 
#include <bansys>
#include <sk_utils>
#include <regsystem>
#include <ezsck>
#include <scan>
#include <manager>
#include <next_client_api>

#pragma compress 1
// OPTIONS
#define TASK_OFFSET_MOTD 453000
#define TASK_OFFSET_CALLKICK 453100
#define TASK_OFFSET_FINALKICK 453200
#define TASK_OFFSET_SNAPSHOT1 453300
#define TASK_OFFSET_SNAPSHOT2 453400
#define TASK_OFFSET_SUCCESSVALIDATED 453500
#define TASK_OFFSET_PRINTADMINMENU 453600
#define TASK_OFFSET_PRINTMUTED 453700
#define TASK_OFFSET_BANELAPSE 500000
#define TASK_OFFSET_MUTEELAPSE 800000
#define OPTION_MAX_VALIDATION 4
#define OPTION_CHECK_WEBBANSTIME 60.0
#define OPTION_CHECK_WEBMUTESTIME 60.0
#define OPTION_ANTICHEAT_BANTIME 1440
#define OPTION_SUCCES_VALTIME 3.0 //Mennyi idő után hívja meg a sikeres validációt.
#define OPTION_MAX_PLAYERS 33

new const OPTION_BAN_TABLE[] = "amx_bans";
new const OPTION_MUTE_TABLE[] = "amx_mutes";
new const OPTION_REGSYSTEM_TABLE[] = "herboy_regsystem";
new const OPTION_WEBSITE_LINK[] = "http://37.221.212.11/ban_api/banv2.php";
new const CS_DOWNLOAD[] = "https://nextclient.ru/";
new const FB_LINK[] = "fb.com/groups/herboyonlyd2";
new const DC_LINK[] = "discord.gg/herboyd2";

new const PLUGIN[] = "[SK BanSystem]";
new const menuprefixwhmt[] = "\r[\wHerBoy\r]";
new const VERSION[] = "v4.0.134";
new const AUTHOR[] = "Kova & Shedi";
new Choosed[][] = {"Kirúgás", "Kitiltás", "Némítás", "Admin hozzáadása", "Offline Kitiltás", "Offline Némítás"};
new ChoosedMessMod[][] = {"Kirugas", "Kitiltas", "Nemitas"};
new ChoosedActionMod[][] = {"kick", "ban", "mute"};
///////////////FORWARDS///////////////
new fwd_succesvalidate;
//////////////////////////////////////
enum _:globalPlayer
{
	PlayerName[64],
	PlayerSteamId[32],
	PlayerIPAddress[32],
	SelectedBanPlayerIndex,
	validator,
	bool:is_validated,
	validator_pingdelay,
	uuid[37],
	UniqKey[40],
	is_gaged,
	//sort_adminarray,
	bool:checked
}
new glob_Player[33][globalPlayer];
enum _:gBanList
{
	BanID,
	BannedName[64],
	BannedPlayerId,
	BannedSteamId[33],
	BannedIP[33],
	BanTime,
	BanReason[256],
	BannedBy[64],
	BannedByPlayerId,
	BannedByIP[33],
	BannedBySteamId[33],
	BanLenght,
	BannedServer,
	BanActive,
	BannedByAdminPerm,
	NotShowOnMenu,
	is_modified,
	ModifiedBy[33],
	UnbannerName[33]
}
enum _:gMuteList
{
	MuteID,
	MutedSteamId[33],
	MutedIP[33],
	MutedPlayerId,
	MutedName[64],
	MuteTime,
	MuteReason[256],
	MutedBy[64],
	MutedByPlayerId,
	MutedBySteamId[33],
	MutedByIP[33],
	MuteLength,
	MuteType,
	MutedByAdminPerm,
	MuteActive,
	mis_modified,
	mModifiedBy[33],
	UnmuterName[33]
}
enum _:gLastOnPlayers
{
	LastOnlineTime,
	LastOnlineName[64],
	LastOnlineId,
	LastOnlineSteamId[33],
	LastOnlineIP[33],
	LastOnlineServer,
	LastOnlineAdminPerm
}
enum _:MenuReqs
{
	ChoosedActionType,
	ChoosedId,
	TempReason[256],
	TempTime,
	TempMuteType,
	a_choosed,
	a_choosed_aid,
	a_addchoosed,
	array_adminrow,
	ChoosedArray_Disconnected,
	change_banmutemode,
	is_offline
}
enum _:AdminSys
{
	AdminPerm,
	AdminName[33],
	AdminAddedBy[33],
	AdminAddSysTime,
	AdminUserId,
	AdminAddedUserId,
}
new MR[33][MenuReqs];
enum _:FoundProp
{
	f_PName[33],
	f_PIP[33],
	f_PSID[33],
	f_LOnLine
}
enum _:enumVersion
{
	bool:v_bGot,
	bool:v_bValidated,
	v_sFullString[64],
	v_sVersion[32],
	v_iProtocol,
	v_iBuild,
	Float:v_fStartTime
}
new cl_versions[33][enumVersion];
/*
- Tervek

amx_ban más admint ne tudjon kirakni
parancsok levédése
webadmin támogatás
amx_unban banid feloldás


*/
new Array:g_BanList;
new Array:g_MuteList;
new Array:g_LastOnPlayers;
new Array:g_Admins;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	register_message(get_user_msgid("MOTD"), "CheckCookies");
	//Client CMDS
	register_clcmd("d2", "d21");
	register_concmd("adminmenu", "show_adminpanel");

	register_clcmd("say", "Hook_Say");
	register_clcmd("say_team", "Hook_Say");
	//Client ConsoleCMD
	register_concmd("amx_unban", "cmd_unban");
	register_concmd("amx_unmute", "cmd_unmute");
	register_concmd("amx_kick", "cmd_kick");
	register_concmd("amx_ban", "cmd_ban");
	register_concmd("sk_log", "cmd_aclog");
	register_concmd("get_version", "CMD_GetVersion", ADMIN_BAN, "<target>");

	//AdminMenu CLCMDS
	register_clcmd("Kirugas_Indok", "clCmdReason");
	register_clcmd("Kitiltas_Indok", "clCmdReason");
	register_clcmd("Nemitas_Indok", "clCmdReason");
	register_clcmd("Kitiltas_Ido", "clCmdTime");
	register_clcmd("Nemitas_Ido", "clCmdTime");

	//Menu Handlers
	register_menucmd(register_menuid("ADMINMAIN"), 0xFFFF, "show_adminpanel_h"),
	register_menucmd(register_menuid("KITILTASKEZELES"), 0xFFFF, "show_kitiltaskezeles_h");
	register_menucmd(register_menuid("NEMITASKEZELES"), 0xFFFF, "show_nemitaskezeles_h");

	//forwards
	fwd_succesvalidate = CreateMultiForward("skbs_user_validated_success", ET_IGNORE, FP_CELL);

	//Array Creates
	g_BanList = ArrayCreate(gBanList);
	g_MuteList = ArrayCreate(gMuteList);
	g_LastOnPlayers = ArrayCreate(gLastOnPlayers);
	g_Admins = ArrayCreate(AdminSys);

	register_dictionary("bansystem.txt");
	register_dictionary("general.txt");
}

public CMD_GetVersion(id,level,cid)
{
	if (!cmd_access(id, level, cid, 2, true))
		return PLUGIN_HANDLED;

	new arg_target[32];
	read_argv(1, arg_target, charsmax(arg_target));

	new target = cmd_target(id, arg_target, (CMDTARGET_ALLOW_SELF | CMDTARGET_NO_BOTS));
	if(target == 0)
		return PLUGIN_HANDLED;

	console_print(id, "*************** BANSYS ***************");
	if(!cl_versions[target][v_bValidated])
	{
		console_print(id, "User is not validated or not online");
		console_print(id, "**************************************");
		return PLUGIN_HANDLED;
	}

	console_print(id, "Target Version is: %s", cl_versions[target][v_sVersion]);
	console_print(id, "Target Protocol is: %i", cl_versions[target][v_iProtocol]);
	console_print(id, "Target Build is: %i", cl_versions[target][v_iBuild]);
	if(cl_versions[target][v_iBuild] == 10185 || cl_versions[target][v_iBuild] == 10210)
		console_print(id, "Target can't run scan");
	else if(cl_versions[target][v_iBuild] == 9920)
		console_print(id, "Target will lack server IP in scan");
	else if(cl_versions[target][v_iBuild] == 8684)
		console_print(id, "Target using steam_legacy");
	else
		console_print(id, "Target using unknown client, should be able to scan");

	if(ncl_is_client_api_ready(target))
	{
		new eNclUsing:ncv = ncl_is_using_nextclient(target);
		if(ncv == NCL_NOT_USING)
			console_print(id, "NextClient: N/A");
		else if(ncv == NCL_DECLARE_USING)
			console_print(id, "NextClient: UnVerifed (Suspicious)");
		else if(ncv == NCL_USING_VERIFICATED)
			console_print(id, "NextClient: Verifed (Good)");
		if(ncv != NCL_NOT_USING)
			console_print(id, "!!!!NextClient can only run scan if cs.exe renamed to cstrike.exe!!!!");
	}
	else
	{
		console_print(id, "NextClient: N/A (API not ready for the user)");
	}
	
	console_print(id, "**************************************");
	return PLUGIN_HANDLED;
}
public cmd_aclog(aid)
{
	if(!(get_user_flags(aid) & ADMIN_KICK))
	{
		console_print(aid, "%L ** #2", aid, "GENERAL_INSUFFICIENT_PERMISSIONS_ERROR");
		return PLUGIN_HANDLED;
	}
	new hashco[120]
	read_argv(1, hashco, charsmax(hashco));

	sk_log("HASH_LOG", fmt("%s", hashco));
	return PLUGIN_HANDLED;
}
public plugin_natives()
{
	register_native("skbs_get_UniqueKey32","native_get_user_UniquieKey32",1);
	register_native("skbs_is_Validated","native_get_user_isvalidated",1);
}

public native_get_user_UniquieKey32(const index, ukey[], const len)
{
	param_convert(2);
	copy(ukey, len, glob_Player[index][UniqKey]);
}

public native_get_user_isvalidated(const index)
{
	if(glob_Player[index][is_validated])
		return 1;
	else
		return 0;
}

public cmd_kick(aid)
{
	if(!(get_user_flags(aid) & ADMIN_KICK))
	{
		console_print(aid, "%L ** #2", aid, "GENERAL_INSUFFICIENT_PERMISSIONS_ERROR");
		return PLUGIN_HANDLED;
	}

	if(read_argc() < 2)
	{
		console_print(aid, "** [HIBA #01] : A parancs nincs megfelelően kitöltve, kérlek nézd át, hogy nem-e hagytál ki valamit! [HIBA #01] **");
		console_print(aid, "** [Használati Útmutató] : Példa (amx_kick ^"STEAM_0:0:12345678 VAGY NÉV PL: shedi^" ^"Indok^") **");
		return PLUGIN_HANDLED;
	}
	new sTarget[33], b_Reason[256];
	read_argv(1, sTarget, charsmax(sTarget));
	read_argv(2, b_Reason, charsmax(b_Reason));

	new id = cmd_target(aid, sTarget, 2);
	if(!id) 
	{
		console_print(aid, "** [HIBA #07] : Nincs ilyen játékos, ellenőrizd le újra! [HIBA #07] **");
		return PLUGIN_HANDLED;
	}
	Action(id, "kick", b_Reason, aid, 0, 0);
	return PLUGIN_CONTINUE;
}

public cmd_ban(aid)
{
	if(!(get_user_flags(aid) & ADMIN_BAN))
	{
		console_print(aid, "%L ** #2", aid, "GENERAL_INSUFFICIENT_PERMISSIONS_ERROR");
		return PLUGIN_HANDLED;
	}

	if(read_argc() < 4)
	{
		console_print(aid, "** [HIBA #01] : A parancs nincs megfelelően kitöltve, kérlek nézd át, hogy nem-e hagytál ki valamit! [HIBA #01] **");
		console_print(aid, "** [Használati Útmutató] : Példa (amx_ban ^"STEAM_0:0:12345678 VAGY NÉV PL: shedi^" 1440 ^"Admin szídása^") **");
		return PLUGIN_HANDLED;
	}	
	new sTarget[33], Time[10], b_Reason[256];
	read_argv(1, sTarget, charsmax(sTarget));
	read_argv(2, Time, charsmax(Time));
	read_argv(3, b_Reason, charsmax(b_Reason));

	new id = cmd_target(aid, sTarget, 2);
	if(!id ) 
	{
		console_print(aid, "** [HIBA #07] : Nincs ilyen játékos, ellenőrizd le újra! [HIBA #07] **");
		return PLUGIN_HANDLED;
	}
	if(id == aid)
	{
		console_print(aid, "*** [HIBA #06] : Miért vagy retardált? [HIBA #06] ***");
		return PLUGIN_HANDLED;
	}
	Action(id, "ban", b_Reason, aid, str_to_num(Time), 0);
	return PLUGIN_CONTINUE;
}

public cmd_unban(aid)
{
	if(!(get_user_flags(aid) & ADMIN_BAN))
	{
		console_print(aid, "%L **#3", aid, "GENERAL_INSUFFICIENT_PERMISSIONS_ERROR");
		return PLUGIN_HANDLED;
	}

	if(read_argc() < 2)
	{
		console_print(aid, "** [HIBA #01] : A parancs nincs megfelelően kitöltve, kérlek nézd át, hogy nem-e hagytál ki valamit! [HIBA #01] **");
		console_print(aid, "** [Használati Útmutató] : Példa (amx_unban ^"STEAM_0:0:12345678) **");
		return PLUGIN_HANDLED;
	}	
	new sTarget[33], BanList[gBanList], found;
	new BanListSizeof = ArraySize(g_BanList);
	read_argv(1, sTarget, charsmax(sTarget));

	for(new i = 0; i < BanListSizeof;i++)
	{
		ArrayGetArray(g_BanList, i, BanList);
		if(equal(BanList[BannedSteamId], sTarget) || equal(BanList[BannedIP], sTarget))
		{
			if(BanList[BanActive] == 0)
			{
				if(get_user_adminlvl(aid) <= BanList[BannedByAdminPerm] || BanList[BannedByAdminPerm] == 0 || aid == 0)
				{
					found = 1;
					UnAction(aid, i, 1);
					console_print(aid, "* Játékos: %s(%s) feloldása sikeresen megtörtént!", BanList[BannedName], sTarget);
					break;
				}
				else
				{
					found = 1;
					console_print(aid, "** [HIBA #09] : Ezt az azonosítót egy nálad magasabb ranggal rendelkező személy tiltotta ki. [HIBA #09] **");
					break;
				}
				
			}
		}
		else found = 0;
	}
	if(found == 0)
		console_print(aid, "** Nincs ezzel az azonosítóval aktív ban a banlistán. **");
	
	return PLUGIN_CONTINUE;
}

public QueryAction(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime){
	if( FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED ){
		log_amx("%s", Error);
		return;
	}
	if(Queuetime >= 3.0)
	{
		new sTime[64];
		formatCurrentDateAndTime(sTime, charsmax(sTime));
		SendToAdmins(fmt("^3[Warn-Action] ^1(%s) ^4Query exceeded the acceptable QueueTime(5.0) : QT: %3.2f", sTime, Queuetime))
	}
}

public cmd_unmute(aid)
{
	if(!(get_user_flags(aid) & ADMIN_BAN))
	{
		console_print(aid, "%L **#4", aid, "GENERAL_INSUFFICIENT_PERMISSIONS_ERROR");
		return PLUGIN_HANDLED;
	}

	if(read_argc() < 2)
	{
		console_print(aid, "** [HIBA #01] : A parancs nincs megfelelően kitöltve, kérlek nézd át, hogy nem-e hagytál ki valamit! [HIBA #01] **");
		console_print(aid, "** [Használati Útmutató] : Példa (amx_unmute ^"STEAM_0:0:12345678) **");
		return PLUGIN_HANDLED;
	}	
	new sTarget[33], MuteList[gMuteList], found;
	new MuteListSizeof = ArraySize(g_MuteList);
	read_argv(1, sTarget, charsmax(sTarget));

	for(new i = 0; i < MuteListSizeof;i++)
	{
		ArrayGetArray(g_MuteList, i, MuteList);
		if(equal(MuteList[MutedSteamId], sTarget) || equal(MuteList[MutedIP], sTarget))
		{
			if(MuteList[MuteActive] == 0)
			{
				if(get_user_adminlvl(aid) < MuteList[MutedByAdminPerm] || MuteList[MutedByAdminPerm] == 0)
				{
					found = 1;
					UnAction(aid, i, 2);
					console_print(aid, "* Játékos: %s(%s) feloldása sikeresen megtörtént!", MuteList[MutedName], sTarget);
					break;
				}
				else
				{
					found = 1;
					console_print(aid, "** [HIBA #09] : Ezt az azonosítót egy nálad magasabb ranggal rendelkező személy némította le. [HIBA #09] **");
					break;
				}
				
			}
		}
		else found = 0;
	}
	if(found == 0)
		console_print(aid, "** Nincs ezzel az azonosítóval aktív némítás a némításlistán. **");
	return PLUGIN_CONTINUE;
}

public QuerySetData(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime){
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) {
		log_amx("%s", Error);
		return;
	}
	if(Queuetime >= 3.0)
	{
		new sTime[64];
		formatCurrentDateAndTime(sTime, charsmax(sTime));
		SendToAdmins(fmt("^3[Warn-BQuerySetData] ^1(%s) ^4Query exceeded the acceptable QueueTime(5.0) : QT: %3.2f", sTime, Queuetime))
	}
}

public d21(id)
{
	if(m_get_server_id() == 2)
		server_cmd("changelevel de_dust2");
	console_print(id, "This is not the Developer server!")
	return PLUGIN_CONTINUE;
}

public show_adminpanel(id)
{
	if(!(get_user_flags(id) & ADMIN_BAN))
	{
		console_print(id, "%L **#5", id, "GENERAL_INSUFFICIENT_PERMISSIONS_ERROR");
		return PLUGIN_HANDLED;
	} 
	new Menu[512], MenuKey
	add(Menu, 511, fmt("%s \yAdmin Panel^n^n", menuprefixwhmt));
	add(Menu, 511, fmt("\r1. \r[ \wJátékos \rkirúgás ]^n"));
	add(Menu, 511, fmt("\r2. \r[ \wJátékos \rkitiltás ]^n"));
	add(Menu, 511, fmt("\r3. \r[ \wJátékos \rnémítás ]^n"));
	add(Menu, 511, fmt("\r4. \r[ \wJátékos \rütögetés]^n"));
	add(Menu, 511, fmt("\r5. \r[ \wJátékos \ráthelyezés ]^n^n"));
	add(Menu, 511, fmt("\r6. \r[ \yKitiltott játékosok kezelése ]^n"));
	add(Menu, 511, fmt("\r7. \r[ \yNémított játékosok kezelése ]^n^n"));
	add(Menu, 511, fmt("\r8. \r[ \wScan menü \r]^n^n"));
	
	add(Menu, 511, fmt("\r0. \rKilépés^n"));
	
	MenuKey = (1<<0 | 1<<1 | 1<<2 | 1<<3 | 1<<4 | 1<<5 | 1<<6 | 1<<7 | 1<<8 | 1<<9);
	show_menu(id, MenuKey, Menu, -1, "ADMINMAIN");
	return PLUGIN_CONTINUE
}
public show_adminpanel_h(id, MenuKey)
{
	MenuKey++;
	switch(MenuKey)
	{
	case 1..3: 
	{
	MR[id][is_offline] = 0;
	openPlayerChoose(id, MenuKey-1)
	MR[id][ChoosedActionType] = MenuKey-1;
	}
	case 4: client_cmd(id, "amx_slapmenu")
	case 5: client_cmd(id, "amx_teammenu")
	//case 5: AdminCourseEdit(id, ai_id[id])
	//case 4: show_disconnectedplayers(id);
	case 6: show_bannedplayers(id)
	case 7: show_mutedplayers(id)
		case 8: client_cmd(id, "scanmenu")
	default:
	{
	show_menu(id, 0, "^n", 1);
	return
	}
}
}

public openAdminSystem(id)
{
	new iras[121];
	format(iras, charsmax(iras), "%s \yAdminok kezelése", menuprefixwhmt);
	new menu = menu_create(iras, "openAdminSystem_h");
	
	menu_additem(menu, "Új \yAdmin\r hozzáadása", "1", 0);
	menu_additem(menu, "Jelenlegi \yAdmin\r kezelése", "1", 0);

	menu_display(id, menu, 0);
}

public openAdminSystem_h(id, menu, item){
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return;
	}
	
	new data[9], szName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
	new key = str_to_num(data);
	
	switch(key)
	{
		case 1: openPlayerChoose(id, 4);
		//case 2: openAdmins(id);
	}
}

public openPlayerChoose(id, choosed_)
{
	if(!(get_user_flags(id) & ADMIN_BAN))
	{
		console_print(id, "%L **#6", id, "GENERAL_INSUFFICIENT_PERMISSIONS_ERROR");
		return PLUGIN_HANDLED;
	}

	if(choosed_ == 4)
		MR[id][a_addchoosed] = 1;

	new szMenu[256], players[32], pnum, szTempid[10];
	get_players(players, pnum, "ch");
	new menu = menu_create(fmt("%s \wJátékos \r%s", menuprefixwhmt, Choosed[choosed_]), "openP_Chooser");

	for(new i; i<pnum; i++)
	{
		new curr = players[i];
		new len;
		if(get_user_adminlvl(curr) == 0 || get_user_adminlvl(id) == 0)
			len += formatex(szMenu[len], charsmax(szMenu) - len, "%s", glob_Player[curr][PlayerName], get_user_adminlvl(id));
		else if(get_user_adminlvl(curr) >= get_user_adminlvl(id))
			len += formatex(szMenu[len], charsmax(szMenu) - len, "%s \y(\r%s\y)", glob_Player[curr][PlayerName], Admin_Permissions[get_user_adminlvl(curr)][0]);
		else
			len += formatex(szMenu[len], charsmax(szMenu) - len, "\d%s \y(\r%s\y)", glob_Player[curr][PlayerName], Admin_Permissions[get_user_adminlvl(curr)][0]);

		num_to_str(curr, szTempid, charsmax(szTempid));
		menu_additem(menu, szMenu, szTempid);
	}
	menu_display(id, menu, 0);

	return PLUGIN_CONTINUE;
}

public openP_Chooser(id, menu, item) {
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		MR[id][a_addchoosed] = 0;
		return PLUGIN_HANDLED;
	}

	new data[9], szName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName, charsmax(szName), callback);
	new key = str_to_num(data);

	MR[id][ChoosedId] = key;
	if(MR[id][a_addchoosed])
		openSetAdminMenu(id, key);
	else
		openActionMenu(id, "online");
	
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public openSetAdminMenu(id, sid)
{
	new iras[121], c_added[64];
	format(iras, charsmax(iras), "%s \r%s\d(#%i) \w|\y Jogkör adás", menuprefixwhmt, glob_Player[sid][PlayerName], sk_get_accountid(sid));
	new menu = menu_create(iras, "openSetAdminMenu_h");
	new MinuteString[80], AdminList[AdminSys];

	MR[id][array_adminrow] = SearchIsAdmin(sk_get_accountid(sid));
	easy_time_length(sid, sk_get_playtime(sid), timeunit_seconds, MinuteString, charsmax(MinuteString));

	if(MR[id][array_adminrow] != -1)
		ArrayGetArray(g_Admins, MR[id][array_adminrow], AdminList);

	format_time(c_added, charsmax(c_added), "%Y.%m.%d - %H:%M:%S", AdminList[AdminAddSysTime]);

	menu_addtext2(menu, fmt("Admin jogosultság: %s", get_user_adminlvl(sid) > 0 ? "\rIgen" : "\dNem"));
	menu_addtext2(menu, fmt("\wJátszott idő: \r%s", MinuteString));
	if(AdminList[AdminPerm] > 0)
	{
		menu_addtext2(menu, fmt("\wAdmint kapta: \r%s", c_added));
		menu_addtext2(menu, fmt("\wAdmint kapta tőle: \r%s\d(#%i)", AdminList[AdminAddedBy], AdminList[AdminAddedUserId]));
	}

	menu_addblank2(menu);
	if(MR[id][array_adminrow] == -1)
		menu_additem(menu, "Adni kívánt jog kiválasztása", "1");
	else 
		menu_additem(menu, fmt("Jogosultság \y[\r%s\y] \welvétele", Admin_Permissions[AdminList[AdminPerm]][0]), "2");

	menu_display(id, menu, 0);
}

public openSetAdminMenu_h(id, menu, item) {
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		MR[id][a_addchoosed] = 0;
		return PLUGIN_HANDLED;
	}

	new data[9], szName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName, charsmax(szName), callback);
	new key = str_to_num(data);

	switch(key)
	{
		case 1: openSelectPermission(id)
		case 2:{
			new AdminList[AdminSys];
			ArrayGetArray(g_Admins, MR[id][array_adminrow], AdminList);

			sk_chat_lang("%L", "BAN_ADMIN_PERMISSION_CHANGE", Admin_Permissions[get_user_adminlvl(id)][0], glob_Player[id][PlayerName], glob_Player[MR[id][ChoosedId]][PlayerName], Admin_Permissions[AdminList[AdminPerm]][0], Admin_Permissions[0][0]);
			AdminList[AdminPerm] = 0;
			//set_user_adminlvl(id, 0)
			ArraySetArray(g_Admins, MR[id][array_adminrow], AdminList);
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public openSelectPermission(id)
{
	new iras[121];
	format(iras, charsmax(iras), "%s \rJogkör kiválasztás", menuprefixwhmt);
	new menu = menu_create(iras, "openSelectPermission_h");

	if(get_user_adminlvl(id) == 1 || get_user_adminlvl(id) == 2)
	{
		menu_additem(menu, "Fejlesztő", "1");
		menu_additem(menu, "Tulajdonos", "2");
		menu_additem(menu, "FőAdmin", "3");
	}
	else
	{
		menu_additem(menu, "\dFejlesztő", "-1");
		menu_additem(menu, "\dTulajdonos", "-1");
		menu_additem(menu, "\dFőAdmin", "-1");
	}
	menu_additem(menu, "Admin", "4");
	menu_additem(menu, "Próbaidős Admin", "5");
	menu_additem(menu, "Veterán", "6");

	menu_display(id, menu, 0);
}

public openSelectPermission_h(id, menu, item) {
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		MR[id][a_addchoosed] = 0;
		return PLUGIN_HANDLED;
	}

	new data[9], szName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName, charsmax(szName), callback);
	new key = str_to_num(data);

	switch(key)
	{
		case -1: {
			sk_chat(id, "Ehhez az admin jogkör adásához nincs meg az elegendő jogosultságod! ^3(^4Fejlesztő, Tulajdonos^3)!");
			openSelectPermission(id);
		}
		case 1..6:{
			new AdminList[AdminSys];
			AdminList[AdminPerm] = key;
			AdminList[AdminName] = glob_Player[MR[id][ChoosedId]][PlayerName];
			AdminList[AdminAddedBy] = glob_Player[id][PlayerName];
			AdminList[AdminAddSysTime] = get_systime();
			AdminList[AdminUserId] = sk_get_accountid(MR[id][ChoosedId]);
			AdminList[AdminAddedUserId] = sk_get_accountid(id);
			sk_chat_lang("%L", "BAN_ADMIN_PERMISSION_CHANGE", Admin_Permissions[get_user_adminlvl(id)][0], glob_Player[id][PlayerName], glob_Player[MR[id][ChoosedId]][PlayerName], Admin_Permissions[0][0], Admin_Permissions[AdminList[AdminPerm]][0]);
			//sql_addrow

			MR[id][ChoosedId] = -1;
			MR[id][array_adminrow] = -1;
			MR[id][a_addchoosed] = -1;
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

stock SearchIsAdmin(a_userid)
{
	new AdminListSizeof = ArraySize(g_Admins);
	new AdminList[AdminSys], arrinfo = -1;

	if(AdminListSizeof == 0)
		client_print_color(0, print_team_default, "^4** [SYSTEM WARNING #01] ** : ^1Egyetlen egy admin sincs az adminlistába, a rendszer instabillá vállhat! ^4** [SYSTEM WARNING #01] **");

	for(new i = 0; i < AdminListSizeof;i++)
		{
			ArrayGetArray(g_Admins, i, AdminList);
			if(AdminList[AdminUserId] == a_userid)
			{
				if(AdminList[AdminPerm] > 0)
					arrinfo = i;
			}
	}
	return arrinfo;
}

public openActionMenu(id, const isOffline[])
{
	if(!(get_user_flags(id) & ADMIN_BAN))
	{
		console_print(id, "%L **#7", id, "GENERAL_INSUFFICIENT_PERMISSIONS_ERROR");
		return PLUGIN_HANDLED;
	}

	new cid = MR[id][ChoosedId];
	new c_Length[128], c_Elapse[64];
	new menu = menu_create(fmt("%s \yJátékos \r%s^n\rTölts ki mindent!", menuprefixwhmt, Choosed[MR[id][ChoosedActionType]]), "ActionMenu_h");

	if(MR[id][TempTime] == 0)
	{
		copy(c_Length, 64, "Örök");
		copy(c_Elapse, 64, "Soha");
	}
	else
	{
		easy_time_length(id, MR[id][TempTime], timeunit_minutes, c_Length, charsmax(c_Length));
		format_time(c_Elapse, charsmax(c_Elapse), "%Y.%m.%d - %H:%M:%S", get_systime() + (MR[id][TempTime]*60));
	}

	if(equal(isOffline, "offline"))
	{
		new TempPlayer[gLastOnPlayers];
		ArrayGetArray(g_LastOnPlayers, MR[id][ChoosedArray_Disconnected], TempPlayer);

		menu_addtext2(menu, fmt("Játékos: \y%s\d(#%i)^n", TempPlayer[LastOnlineName], TempPlayer[LastOnlineId]));
	}
	else
		menu_addtext2(menu, fmt("Játékos: \y%s\d(#%i)^n", glob_Player[cid][PlayerName], sk_get_accountid(cid)));
	if(strlen(MR[id][TempReason]) == 0)
		menu_addtext2(menu, "\wIndok: \dNincs megadva.");
	else if(strlen(MR[id][TempReason]) >= 12) 
		menu_additem(menu, fmt("\wIndok: \rMegtekintés"), "-2");
	else 
		menu_addtext2(menu, fmt("\wIndok: \r%s", MR[id][TempReason]));

	if(MR[id][ChoosedActionType] != 0)
	{
		if(MR[id][TempTime] == -1)
			menu_addtext2(menu, "\wHossza: \dNincs megadva.\w^nFeltehetőleg lejár: \dNincs idő megadva.^n");
		else 
			menu_addtext2(menu, fmt("\wHossza: \r%s\w^nFeltehetőleg lejár: \r%s^n", c_Length, c_Elapse));

		if(MR[id][ChoosedActionType] == 2)
			menu_additem(menu, MR[id][TempMuteType] == 3 ? "\wNémítás típusa: \dChat \w| \dVoice \w| \rMindkettő^n" : (MR[id][TempMuteType] == 1 ? "\wNémítás típusa: \rChat \w| \dVoice \w| \dMindkettő^n" : "\wNémítás típusa: \dChat \w| \rVoice \w| \dMindkettő^n"), "-3",0);
		//"

	}

	if(strlen(MR[id][TempReason]) > 0)
		menu_additem(menu, "Indok megváltozatása", "1");
	else
		menu_additem(menu, "Indok megadása", "1");

	if(MR[id][ChoosedActionType] != 0)
	{
		if(MR[id][TempTime] >= 0)
			menu_additem(menu, "Idő megváltozatása^n", "2");
		else 
			menu_additem(menu, "Idő megadása^n", "2");
	}


	if(((strlen(MR[id][TempReason]) > 0) && (MR[id][TempTime] >= 0)) ||  (strlen(MR[id][TempReason]) > 0) && MR[id][ChoosedActionType] == 0)
		menu_additem(menu, fmt("\y%s", Choosed[MR[id][ChoosedActionType]]), "3", 0);

	menu_display(id, menu, 0);

	return PLUGIN_CONTINUE;
}

public ActionMenu_h(id, menu, item){
	
	if( item == MENU_EXIT ) {
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	
	new data[9], szName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
	new key = str_to_num(data);

	switch(key)
	{
		case -2:
		{
			sk_chat(id, "Az indok: ^4%s", MR[id][TempReason]);
			openActionMenu(id, "online");
		}
		case -3:
		{
			if(MR[id][TempMuteType] == 3)
				MR[id][TempMuteType] = 1;
			else
				MR[id][TempMuteType]++;

			openActionMenu(id, "online");
		}
		case -1:
		{
			sk_chat(id, "Tölts ki minden mezőt!");
			openActionMenu(id, "online");
		}
		case 1: {
			sk_chat(id, "Írj be egy indokot!");
			client_cmd(id, fmt("messagemode %s_Indok", ChoosedMessMod[MR[id][ChoosedActionType]]));
		}
		case 2: client_cmd(id, fmt("messagemode %s_Ido", ChoosedMessMod[MR[id][ChoosedActionType]]));
		case 3: Action(MR[id][ChoosedId], ChoosedActionMod[MR[id][ChoosedActionType]], MR[id][TempReason], id, MR[id][TempTime], MR[id][TempMuteType]);
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public clCmdReason(id) {
	new Data[256];
	read_args(Data, charsmax(Data));
	remove_quotes(Data);
	if(!(RegexTester(id, Data, "^^[A-Za-z0-9öüóőúéáűíÖÜÓŐÚÉÁŰÍ <>=\/_.:!\?\*\[\]+,()\-]{1,256}+$", "A beírt szöveg csak magyar abc-t, számok és ^"<>=/_.!?*[]+,()-^"-ket tartalmazhatja!")))
	{
		openActionMenu(id, "online");
		return;
	}

	copy(MR[id][TempReason], 256, Data);
	openActionMenu(id, "online");
}

public clCmdTime(id) { 
	new Data[32];
	read_args(Data, charsmax(Data));
	remove_quotes(Data);

	if(!(RegexTester(id, Data, "^^[0-9]{1,16}+$", "A beírt szöveg csak, számokat tartalmazhat, és a hossza nem haladhatja meg a^3 16-ot!")))
	{
		openActionMenu(id, "online");
		return;
	}

	MR[id][TempTime] = str_to_num(Data);
	openActionMenu(id, "online");
} 

public show_bannedplayers(id)
{
	new iMenu[256], Num[6];
	new menu = menu_create(fmt("%s \rKitiltott Játékosok", menuprefixwhmt), "bannedplayers_h");
	new BanListSizeof = ArraySize(g_BanList);
	new sDateAndTime[40];
	new BanList[gBanList];
	new dislayed = 0;
	for(new i = BanListSizeof - 1; i >= 0;i--)
	{
		new len;
		ArrayGetArray(g_BanList, i, BanList);
		if(BanList[BanActive] > 0)
			continue;
		else if(BanList[BanActive] == 0)
		{
			if(equal(BanList[BannedBySteamId], glob_Player[id][PlayerSteamId]))
				len += formatex(iMenu[len], charsmax(iMenu) - len, "\y%s", BanList[BannedName]);
			else 
				len += formatex(iMenu[len], charsmax(iMenu) - len, "\w%s", BanList[BannedName]);
			
			format_time(sDateAndTime, charsmax(sDateAndTime), "%y-%m-%d - %H:%M", BanList[BanTime] + (BanList[BanLenght]*60));
			len += formatex(iMenu[len], charsmax(iMenu) - len, "\r | \d%s", BanList[BanLenght] == 0 ? "Örök" : sDateAndTime);
			
			if(equal(BanList[BannedBySteamId], "SERVER_ID"))
				len += formatex(iMenu[len], charsmax(iMenu) - len, "\r | \wANTI-CHEAT");
			else
			{
				if(equal(BanList[BannedBySteamId], glob_Player[id][PlayerSteamId]))
					len += formatex(iMenu[len], charsmax(iMenu) - len, "\r | \y%s", BanList[BannedBy]);
				else 
					len += formatex(iMenu[len], charsmax(iMenu) - len, "\r | \w%s", BanList[BannedBy]);
			}
		}
		num_to_str(i, Num, 5);
		menu_additem(menu, iMenu, Num);
		dislayed++;
		if(dislayed%6==0)
			menu_addblank2(menu);
	}
	menu_setprop(menu, MPROP_PERPAGE, 7);
	menu_setprop(menu, MPROP_PERPAGE, 7);
	menu_display(id, menu, 0);
}

public show_mutedplayers(id)
{
	new iMenu[256], Num[6];
	new menu = menu_create(fmt("%s \rNémított Játékosok", menuprefixwhmt), "mutedplayers_h");
	new MuteListSizeof = ArraySize(g_MuteList);
	new sDateAndTime[40];
	new MuteList[gMuteList];
	new dislayed = 0;
	for(new i = MuteListSizeof - 1; i >= 0;i--)
	{
		new len;
		ArrayGetArray(g_MuteList, i, MuteList);
		if(MuteList[MuteActive] > 0)
			continue;
		else if(MuteList[MuteActive] == 0)
		{
			if(equal(MuteList[MutedBySteamId], glob_Player[id][PlayerSteamId]))
				len += formatex(iMenu[len], charsmax(iMenu) - len, "\y%s", MuteList[MutedName]);
			else 
				len += formatex(iMenu[len], charsmax(iMenu) - len, "\w%s", MuteList[MutedName]);

			format_time(sDateAndTime, charsmax(sDateAndTime), "%y-%m-%d - %H:%M", MuteList[MuteTime] + (MuteList[MuteLength]*60));
			len += formatex(iMenu[len], charsmax(iMenu) - len, "\r | \d%s", MuteList[MuteLength] == 0 ? "Örök" : sDateAndTime);

			if(equal(MuteList[MutedBySteamId], "SERVER_ID"))
				len += formatex(iMenu[len], charsmax(iMenu) - len, "\r | \wANTI-SWEAR");
			else
			{
				if(equal(MuteList[MutedBySteamId], glob_Player[id][PlayerSteamId]))
					len += formatex(iMenu[len], charsmax(iMenu) - len, "\r | \y%s", MuteList[MutedBy]);
				else 
					len += formatex(iMenu[len], charsmax(iMenu) - len, "\r | \w%s", MuteList[MutedBy]);
			}
			
		}
		num_to_str(i, Num, 5);
		menu_additem(menu, iMenu, Num);
		dislayed++;
		if(dislayed%6==0)
			menu_addblank2(menu);
	}
	menu_setprop(menu, MPROP_PERPAGE, 7);
	menu_setprop(menu, MPROP_PERPAGE, 7);
	menu_display(id, menu, 0);
}

public mutedplayers_h(id, menu, item) {
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}

	new data[9], szName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName, charsmax(szName), callback);
	new key = str_to_num(data);

	openPlayerMute(id, key);
	
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public show_disconnectedplayers(id)
{
	new iMenu[256], Num[6];
	new menu = menu_create(fmt("%s Lelépett játékosok", menuprefixwhmt), "show_disc_h");
	menu_additem(menu, MR[id][change_banmutemode] == 0 ? "Tipus: \rKitiltás \y| \dNémítás":"Tipus: \dKitiltás \y| \rNémítás", "-1",0);
	//"
	new DisconnectedsSizeof = ArraySize(g_LastOnPlayers);
	new DiscPlay[gLastOnPlayers];
	new sDateAndTime[40];
	new dislayed = 0;

	if(DisconnectedsSizeof == 0)
	{
		sk_chat(id, "Jelenleg nincs egyetlen adat sem a lelépett játékos listájában.");
		return PLUGIN_HANDLED;
	}

	for(new i = DisconnectedsSizeof - 1; i >= 0;i--)
	{
		new len;
		ArrayGetArray(g_LastOnPlayers, i, DiscPlay);

		len += formatex(iMenu[len], charsmax(iMenu) - len, "\w%s", DiscPlay[LastOnlineName]);
		format_time(sDateAndTime, charsmax(sDateAndTime), "%Y-%m-%d - %H:%M:%S", DiscPlay[LastOnlineTime]);
		len += formatex(iMenu[len], charsmax(iMenu) - len, "\r | \d%s", sDateAndTime);
		num_to_str(i, Num, 5);
		menu_additem(menu, iMenu, Num);
		dislayed++;
		if(dislayed%6==0)
			menu_addblank2(menu);
	}

	menu_setprop(menu, MPROP_PERPAGE, 7);
	menu_setprop(menu, MPROP_PERPAGE, 7);
	menu_display(id, menu, 0);

	return PLUGIN_CONTINUE;
}

public show_disc_h(id, menu, item) {
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}

	new data[9], szName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName, charsmax(szName), callback);
	new key = str_to_num(data);

	if(key == -1)
	{
		if(MR[id][ChoosedActionType] == 2)
		MR[id][ChoosedActionType] = 1;
		else
		MR[id][ChoosedActionType]++;
	}
	else
	{
		MR[id][ChoosedArray_Disconnected] = key;
		openActionMenu(id, "offline");
		MR[id][is_offline] = 1;
	}
		
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public bannedplayers_h(id, menu, item) {
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}

	new data[9], szName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName, charsmax(szName), callback);
	new key = str_to_num(data);

	openPlayer(id, key);
	
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public openPlayerMute(id, m_Index)
{
	new Menu[512], MenuKey, MuteList[gMuteList], sVeg[40], sKezdet[40], sHossz[64];

	ArrayGetArray(g_MuteList, m_Index, MuteList);
	if(MuteList[MuteLength] != 0)
		easy_time_length(id, MuteList[MuteLength], timeunit_minutes, sHossz, charsmax(sHossz));

	format_time(sKezdet, charsmax(sKezdet), "%Y.%m.%d - %H:%M:%S", MuteList[MuteTime]);
	format_time(sVeg, charsmax(sVeg), "%Y.%m.%d - %H:%M:%S", MuteList[MuteTime] + (MuteList[MuteLength]*60));
	add(Menu, 511, fmt("%s \rNémítás Kezelés \d[#%i]^n^n", menuprefixwhmt, MuteList[MuteID]));
	add(Menu, 511, fmt("\wNév: \r%s\d(#%i)^n", MuteList[MutedName], MuteList[MutedPlayerId]));
	if(strlen(MuteList[MuteReason]) <= 12)
		add(Menu, 511, fmt("\wIndok: \r%s^n", MuteList[MuteReason]));

	add(Menu, 511, fmt("\wKezdete: \r%s^n", sKezdet));
	add(Menu, 511, fmt("\wHossza: \r%s^n", MuteList[MuteLength] == 0 ? "Örök" : sHossz));
	add(Menu, 511, fmt("\wVége: \r%s^n", MuteList[MuteLength] == 0 ? "Soha" : sVeg));
	add(Menu, 511, fmt("\wTípus: \r%s^n", MuteList[MuteType] == 3 ? "Chat/Hang" : (MuteList[MuteType] == 1 ? "Chat" : "Hang")));
	add(Menu, 511, fmt("\wAdmin: \r%s\d(#%i)^n^n", MuteList[MutedBy], MuteList[MutedByPlayerId]));
	if(get_user_adminlvl(id) <= MuteList[MutedByAdminPerm] || MuteList[MutedByAdminPerm] == 0)
		add(Menu, 511, fmt("\w[\r1\w] \yFeloldás^n"));
	else
		add(Menu, 511, fmt("\d[\d1\d] \dFeloldás^n"));

	if(strlen(MuteList[MuteReason]) > 12)
		add(Menu, 511, fmt("\w[\r2\w] \yIndok megtekintése^n"));

	add(Menu, 511, fmt("^n\w[\r8\w] \wVissza az előző menübe.^n"));
	add(Menu, 511, fmt("\w[\r0\w] \wKilépés a menüből.^n"));
	glob_Player[id][SelectedBanPlayerIndex] = m_Index;
	MenuKey = (1<<0 | 1<<1 | 1<<2 | 1<<3 | 1<<4 | 1<<5 | 1<<6 | 1<<7 | 1<<8 | 1<<9 );
	show_menu(id, MenuKey, Menu, -1, "NEMITASKEZELES");
	return PLUGIN_CONTINUE;
}

public show_nemitaskezeles_h(id, MenuKey)
{
	MenuKey++;
	new MuteList[gMuteList];
	ArrayGetArray(g_MuteList, glob_Player[id][SelectedBanPlayerIndex], MuteList);
	switch(MenuKey)
	{
		case 1: 
		{
			if(get_user_adminlvl(id) <= MuteList[MutedByAdminPerm] || MuteList[MutedByAdminPerm] == 0)
				UnAction(id, glob_Player[id][SelectedBanPlayerIndex], 2);
			else 
			{
				sk_chat(id, "Ezt a némítást nem tudod feloldani, mivel nálad nagyobb rangú admin osztotta ki!");
				openPlayer(id, glob_Player[id][SelectedBanPlayerIndex]);
			}
		}
		case 2: 
		{
			if(strlen(MuteList[MuteReason]) > 12)
				sk_chat(id, "Indok: ^4%s", MuteList[MuteReason]);
			openPlayerMute(id, glob_Player[id][SelectedBanPlayerIndex]);
		}
		case 3..7:
		{
			show_menu(id, 0, "^n", 1);
			openPlayerMute(id, glob_Player[id][SelectedBanPlayerIndex]);
		}
		case 8: show_mutedplayers(id);
		default:
		{
			show_menu(id, 0, "^n", 1);
		}
	}  
}

public openPlayer(id, Index)
{
	new Menu[512], MenuKey, BanList[gBanList], sVeg[40], sKezdet[40], sHossz[64];  

	ArrayGetArray(g_BanList, Index, BanList);
	if(BanList[MuteLength] != 0)
		easy_time_length(id, BanList[BanLenght], timeunit_minutes, sHossz, charsmax(sHossz));
	
	format_time(sKezdet, charsmax(sKezdet), "%Y.%m.%d - %H:%M:%S", BanList[BanTime]);
	format_time(sVeg, charsmax(sVeg), "%Y.%m.%d - %H:%M:%S", BanList[BanTime] + (BanList[BanLenght]*60));
	add(Menu, 511, fmt("%s \rKitiltás Kezelés \d[#%i]^n^n", menuprefixwhmt, BanList[BanID]));
	add(Menu, 511, fmt("\wNév: \r%s\d(#%i)^n", BanList[BannedName], BanList[BannedPlayerId]));
	if(strlen(BanList[BanReason]) <= 12)
		add(Menu, 511, fmt("\wIndok: \r%s^n", BanList[BanReason]));

	add(Menu, 511, fmt("\wKezdete: \r%s^n", sKezdet));
	add(Menu, 511, fmt("\wHossza: \r%s^n", BanList[BanLenght] == 0 ? "Örök" : sHossz));
	add(Menu, 511, fmt("\wVége: \r%s^n", BanList[BanLenght] == 0 ? "Soha" : sVeg));
	add(Menu, 511, fmt("\wAdmin: \r%s\d(#%i)^n^n", BanList[BannedBy], BanList[BannedByPlayerId]));

	if(get_user_adminlvl(id) <= BanList[BannedByAdminPerm] || BanList[BannedByAdminPerm] == 0)
		add(Menu, 511, fmt("\w[\r1\w] \yFeloldás^n"));
	else
		add(Menu, 511, fmt("\d[\d1\d] \dFeloldás^n"));
	if(strlen(BanList[BanReason]) > 12)
		add(Menu, 511, fmt("\w[\r2\w] \yIndok megtekintése^n"));

	add(Menu, 511, fmt("^n\w[\r8\w] \wVissza az előző menübe.^n"));
	add(Menu, 511, fmt("\w[\r0\w] \wKilépés a menüből.^n"));
	glob_Player[id][SelectedBanPlayerIndex] = Index;
	MenuKey = (1<<0 | 1<<1 | 1<<2 | 1<<3 | 1<<4 | 1<<5 | 1<<6 | 1<<7 | 1<<8 | 1<<9  | 1<<4 | 1<<5 | 1<<6 | 1<<7 | 1<<8 | 1<<9 );
	show_menu(id, MenuKey, Menu, -1, "KITILTASKEZELES");
	return PLUGIN_CONTINUE;
}

public show_kitiltaskezeles_h(id, MenuKey)
{
	MenuKey++;
	new BanList[gBanList];
	ArrayGetArray(g_BanList, glob_Player[id][SelectedBanPlayerIndex], BanList);
	switch(MenuKey)
	{
		case 1: 
		{
			if(get_user_adminlvl(id) <= BanList[BannedByAdminPerm] || BanList[BannedByAdminPerm] == 0)
				UnAction(id, glob_Player[id][SelectedBanPlayerIndex], 1);
			else
			{
				sk_chat(id, "Ezt a tiltást nem tudod feloldani, mivel nálad nagyobb rangú admin osztotta ki!");
				openPlayer(id, glob_Player[id][SelectedBanPlayerIndex]);
			}
		}
		case 2: 
		{
			if(strlen(BanList[BanReason]) > 12)
				sk_chat(id, "Indok: ^4%s", BanList[BanReason]);
			openPlayer(id, glob_Player[id][SelectedBanPlayerIndex]);
		}
		case 3..7:
		{
			show_menu(id, 0, "^n", 1);
			openPlayer(id, glob_Player[id][SelectedBanPlayerIndex]);
		}
		case 8: show_bannedplayers(id)
		default:
		{
			show_menu(id, 0, "^n", 1);
		}
	}  
}

public UnAction(id, uIndex, Typ)
{

	if(!(get_user_flags(id) & ADMIN_BAN))
	{
		console_print(id, "%L **#8", id, "GENERAL_INSUFFICIENT_PERMISSIONS_ERROR");
		return PLUGIN_HANDLED;
	}
	if(Typ == 1)
	{
		new BanList[gBanList];
		ArrayGetArray(g_BanList, uIndex, BanList);
		BanList[BanActive] = 2;
		if(id != 0)
			sk_chat_lang("%L", "BAN_ADMIN_UNBAN", glob_Player[id][PlayerName], BanList[BannedName], BanList[BannedBy]);
		else
			sk_chat_lang("%L", "BAN_DEFENDER_UNBAN", BanList[BannedName], BanList[BannedBy]);
		ArraySetArray(g_BanList, uIndex, BanList);

		static Query[3072];
		formatex(Query, charsmax(Query), "UPDATE `%s` SET `expired` = 2, `UName` = ^"%s^", `UID` = ^"%s^" WHERE `bid` = ^"%i^";", OPTION_BAN_TABLE, glob_Player[id][PlayerName], glob_Player[id][PlayerSteamId], BanList[BanID]);
		SQL_ThreadQuery(m_get_sql(), "QueryAction", Query, _, _);
	}
	else
	{
		new MuteList[gMuteList];
		ArrayGetArray(g_MuteList, uIndex, MuteList);
		MuteList[MuteActive] = 2;
		sk_chat_lang("%L", "BAN_ADMIN_UNMUTE", glob_Player[id][PlayerName], MuteList[MutedName], MuteList[MutedBy]);
		ArraySetArray(g_MuteList, uIndex, MuteList);

		new onlineid = cmd_target(0, MuteList[MutedSteamId], 2);
		CheckIsHaveAnotherGag(onlineid);

		static Query[3072];
		formatex(Query, charsmax(Query), "UPDATE `%s` SET `expired` = 2, `UName` = ^"%s^", `UID` = ^"%s^" WHERE `bid` = ^"%i^";", OPTION_MUTE_TABLE, glob_Player[id][PlayerName], glob_Player[id][PlayerSteamId], MuteList[MuteID]);
		SQL_ThreadQuery(m_get_sql(), "QueryAction", Query, _, _);
	}

	return PLUGIN_CONTINUE;
}

public CheckUnBans(c_arrid)
{
	c_arrid = c_arrid - TASK_OFFSET_BANELAPSE;

	new BanList[gBanList];    
	new ss_Time[64];

	ArrayGetArray(g_BanList, c_arrid, BanList);
	if(BanList[BanActive] == 0)
	{
		for(new idx = 1; idx < 33; idx++)
		{
			if(!is_user_connected(idx))
				continue;
			
			easy_time_length(idx, BanList[BanLenght], timeunit_minutes, ss_Time, charsmax(ss_Time));
			sk_chat(idx, "%L", idx, "BANSYS_BAN_EXPIRED", BanList[BannedName], ss_Time, BanList[BannedBy]);
		}
		BanList[BanActive] = 1;
		ArraySetArray(g_BanList, c_arrid, BanList);
		static Query[3072];
		formatex(Query, charsmax(Query), "UPDATE `%s` SET `expired` = 1 WHERE `bid` = ^"%i^";", OPTION_BAN_TABLE, BanList[BanID]);
		SQL_ThreadQuery(m_get_sql(), "QueryAction", Query, _, _);
	}
}

public CheckUnMutes(c_arrid)
{
	c_arrid = c_arrid - TASK_OFFSET_MUTEELAPSE;

	new MuteList[gMuteList];
	new ss_Time[64];

	ArrayGetArray(g_MuteList, c_arrid, MuteList);
	if(MuteList[MuteActive] == 0)
	{
		for(new idx = 1; idx < 33; idx++)
		{
			if(!is_user_connected(idx))
				continue;
			
			easy_time_length(idx, MuteList[MuteLength], timeunit_minutes, ss_Time, charsmax(ss_Time));
			sk_chat(idx, "%L", idx, "BANSYS_MUTE_EXPIRED", MuteList[MutedName], ss_Time, MuteList[MutedBy]);
		}
		
		MuteList[MuteActive] = 1;

		ArraySetArray(g_MuteList, c_arrid, MuteList);
		new id = cmd_target(id, MuteList[MutedSteamId],2);
		if(id != 0 && is_user_connected(id))
		CheckIsHaveAnotherGag(id);

		static Query[3072];
		formatex(Query, charsmax(Query), "UPDATE `%s` SET `expired` = 1 WHERE `bid` = ^"%i^";", OPTION_MUTE_TABLE, MuteList[MuteID]);
		SQL_ThreadQuery(m_get_sql(), "QueryAction", Query, _, _);
	}
}

public CheckIsHaveAnotherGag(id)
{
	new MuteListSizeof = ArraySize(g_MuteList);
	new MuteList[gMuteList];

	for(new i = 0; i < MuteListSizeof;i++)
	{
		ArrayGetArray(g_MuteList, i, MuteList);
		if(equal(MuteList[MutedSteamId], glob_Player[id][PlayerSteamId]) || equal(MuteList[MutedIP], glob_Player[id][PlayerIPAddress]))
		{
			if(MuteList[MuteActive] == 0)
			{
				sk_chat(id, "%L", id, "BANSYS_NEXT_MUTE_APPLIED");
				SendToShedi(fmt("id: %i | name: %s | Mivel van még 1 némítás blabla", id, glob_Player[id][PlayerName]));
				set_speak(id, SPEAK_NORMAL);

				if(MuteList[MuteType] > 1)
				set_speak(id, SPEAK_MUTED);

				glob_Player[id][is_gaged] = i;
				break;
			}
			else 
			{
				set_speak(id, SPEAK_NORMAL);
				glob_Player[id][is_gaged] = 0;
				SendToShedi(fmt("id: %i | name: %s | CHECKISHAVEGAG : %i", id, glob_Player[id][PlayerName], glob_Player[id][is_gaged]));
			}
		}
	}
}

public client_putinserver(id)
{
	if(is_user_bot(id))
		return;
	
	get_user_name(id, glob_Player[id][PlayerName], 33);
	get_user_ip(id, glob_Player[id][PlayerIPAddress], 32, 1);
	get_user_authid(id, glob_Player[id][PlayerSteamId], 32);

	glob_Player[id][checked] = false;
	glob_Player[id][is_validated] = false;
	glob_Player[id][validator] = -1;

	new bool:new_validator = true;
	do
	{
		new_validator = true;
		glob_Player[id][validator] = random(9999999);
		SendToShedi(fmt("id: %i, name: %s | get new validator: %i", id, glob_Player[id][PlayerName], glob_Player[id][validator]));
		for(new i; i < OPTION_MAX_PLAYERS; i++)
		{
			if(id != i && glob_Player[id][validator] == glob_Player[i][validator])
			{
				new_validator = false;
				i = OPTION_MAX_PLAYERS;
			}
		}
	} while(!new_validator)

	if(task_exists(TASK_OFFSET_MOTD+id))
		remove_task(TASK_OFFSET_MOTD+id);

	set_task(15.0, "CheckValidatorData", TASK_OFFSET_MOTD+id);
	set_speak(id, SPEAK_MUTED);
}

public version_result(id, const szCvar[], const szValue[])
{
	new au_name[33], au_steamid[33], au_ip[33];
	get_user_name(id, au_name, charsmax(au_name));
	get_user_ip(id, au_ip, charsmax(au_ip), 1);
	get_user_authid(id, au_steamid, charsmax(au_steamid));

	sk_log("VersionsLog", fmt("%s | %s | %s | %s", au_name, au_steamid, au_ip, szValue));
	cl_versions[id][v_bGot] = true;
	
	new fullversion[64];
	copy(fullversion, 63, szValue);

	new badchar = 0;
	badchar += replace_all(fullversion, 63, "^"", "");
	badchar += replace_all(fullversion, 63, "'", "");
	badchar += replace_all(fullversion, 63, "%", "");
	badchar += replace_all(fullversion, 63, "`", "");
	badchar += replace_all(fullversion, 63, "#", "");
	badchar += replace_all(fullversion, 63, "--", "");
	badchar += replace_all(fullversion, 63, ";", "");
	badchar += replace_all(fullversion, 63, "&", "");
	badchar += replace_all(fullversion, 63, "?", "");

	if(badchar > 0)
	{
		sk_log("BanSystem_VersonParsing", fmt("[badchar %i]: %s", badchar, szValue));
		return;
	}

	new part = 0, written = 0;
	new temp_Version[34];
	new temp_Protocol[5];
	new temp_Build[8];

	for(new i = 0; i < 63; i++)
	{
		if(fullversion[i] == EOS)
			continue;
		if(fullversion[i] == 44)
		{
			part++;
			written = 0;
			continue;
		}

		switch(part)
		{
			case 0: {
				temp_Version[written] = fullversion[i];
				written++;

				if(written > 32)
				{
					sk_log("BanSystem_VersonParsing", fmt("[temp_Version]: %s", fullversion));
					return;
				}
			}
			case 1: {
				temp_Protocol[written] = fullversion[i];
				written++;

				if(written > 3)
				{
					sk_log("BanSystem_VersonParsing", fmt("[temp_Protocol]: %s", fullversion));
					return;
				}
			}
			case 2: {
				temp_Build[written] = fullversion[i];
				written++;

				if(written > 6)
				{
					sk_log("BanSystem_VersonParsing", fmt("[temp_Build]: %s", fullversion));
					return;
				}
			}
			default: {
				{
					sk_log("BanSystem_VersonParsing", fmt("[unkown]: %s", fullversion));
					return;
				}
			}
		}
	}

	if(strlen(temp_Version) < 2 || strlen(temp_Build) < 2 || strlen(temp_Protocol) < 2)
	{
		sk_log("BanSystem_VersonParsing", fmt("[bad length]: %s", szValue));
		return;
	}
	
	copy(cl_versions[id][v_sVersion], 31, temp_Version);
	cl_versions[id][v_iBuild] = str_to_num(temp_Build);
	cl_versions[id][v_iProtocol] = str_to_num(temp_Protocol);
	copy(cl_versions[id][v_sFullString], 63, fullversion);

	cl_versions[id][v_bValidated] = true;
}

public CheckCookies(msgId, msgDes, id)
{
	if(glob_Player[id][checked] || is_user_bot(id))
		return PLUGIN_CONTINUE;
	
	if(!cl_versions[id][v_bGot])
		ClientValidationFailed(id, 5);

	if(!cl_versions[id][v_bValidated])
		ClientValidationFailed(id, 6);

	hash_string(fmt("AmxxBanSystemUUID__0191a782-3b7f-7107-806a-fbf98a2c65f8;%s;%s;%i;%i;%s", glob_Player[id][PlayerSteamId], glob_Player[id][PlayerIPAddress], glob_Player[id][validator], id, cl_versions[id][v_sFullString]), Hash_Md5, glob_Player[id][uuid], 33);

	show_motd(id, fmt("%s?h=%s&st=%s&i=%s&va=%i&se=%i&gi=%i&ve=%s", OPTION_WEBSITE_LINK, glob_Player[id][uuid], glob_Player[id][PlayerSteamId], glob_Player[id][PlayerIPAddress], glob_Player[id][validator], m_get_server_id(), id, cl_versions[id][v_sFullString]), fmt("SK - Protector %s", VERSION));
	log_to_file("BanSystem.txt", fmt("Status: 1 & Steam: %s & IPV: %s", glob_Player[id][PlayerSteamId], glob_Player[id][PlayerIPAddress]));
	glob_Player[id][checked] = true;

	return PLUGIN_HANDLED;
}

public amx_crash_ban(const TempSteamId[], Float:diff)
{
	new LastOnlinedNum = ArraySize(g_LastOnPlayers);
	
	for(new i = LastOnlinedNum-1; i >= 0;i--)
	{
		new LastOnlined[gLastOnPlayers];
		ArrayGetArray(g_LastOnPlayers, i, LastOnlined);
		if(equal(LastOnlined[LastOnlineSteamId], TempSteamId))
		{
			new sLejarat[64], sHossz[64];

			new BanList[gBanList]
			BanList[BanID] = -1;
			BanList[BannedPlayerId] = LastOnlined[LastOnlineId]
			copy(BanList[BannedSteamId], 32,LastOnlined[LastOnlineSteamId])
			copy(BanList[BannedIP], 32, LastOnlined[LastOnlineIP])
			copy(BanList[BannedName], 32, LastOnlined[LastOnlineName])
			BanList[BanTime] = get_systime()

			copy(BanList[BannedBySteamId], 32, "SERVER_ID");
			copy(BanList[BannedByIP], 32, "127.0.0.1");
			copy(BanList[BannedBy], 32, "ANTI-CHEAT");
			BanList[BannedByAdminPerm] = -1;

			BanList[BannedByPlayerId] = 0;
			BanList[BanLenght] = 10080;
			BanList[BanActive] = 0;

			copy(BanList[BanReason], 256, fmt("DETECT: C-%s%.2f-UNKNOWN", (diff >= 0 ? "P" : "N"), floatabs(diff)));
			new arrayid = ArrayPushArray(g_BanList, BanList);
			sql_addrow(arrayid, 2, 0, 0, "")

			sk_chat_lang("%L", "BANSYS_ADMIN_BAN_PLAYER", BanList[BannedBy], BanList[BannedName])
			for(new idx = 1; idx < 33; idx++)
			{
				if(!is_user_connected(idx))
					continue;
				
				easy_time_length(idx, BanList[BanLenght], timeunit_minutes, sHossz, charsmax(sHossz));
				formatTime(sLejarat, 64, (BanList[BanTime] + (BanList[BanLenght]*60)));
				sk_chat(idx, "%L", idx, "BANSYS_ADMIN_BAN_PLAYER", BanList[BannedBy], BanList[BannedName]);
				sk_chat(idx, "%L", idx, "BANSYS_REASON_LENGTH_EXPIRE", BanList[BanReason], sHossz, sLejarat);
			}
			break;
		}
	}
}

public client_disconnected(id)
{
	new LastOnlined[gLastOnPlayers];
	new SteamID[32], IP[32];
	get_user_authid(id, SteamID, 32);
	get_user_ip(id, IP, 32, 1);
	copy(LastOnlined[LastOnlineName], 32, glob_Player[id][PlayerName]);
	copy(LastOnlined[LastOnlineSteamId], 32, SteamID);
	copy(LastOnlined[LastOnlineIP], 32, IP);
	LastOnlined[LastOnlineId] = sk_get_accountid(id);
	LastOnlined[LastOnlineTime] = get_systime();
	LastOnlined[LastOnlineServer] = m_get_server_id();
	LastOnlined[LastOnlineAdminPerm] = get_user_adminlvl(id);
	ArrayPushArray(g_LastOnPlayers, LastOnlined);

	new scanid;
	if(get_user_scannering(id) && get_user_scan(get_user_scannerselected(id)) == 1)
	{
		scanid = get_user_scannerselected(id)
		sk_chat_lang("%L", "BANSYS_ADMIN_DISCONNECT_DURING_SCAN", glob_Player[id][PlayerName], glob_Player[scanid][PlayerName])
		
		reset_user_scannering(scanid)
	}
	if(get_user_scan(id))
	{
		scanid = get_user_scanby(id)
		sk_chat_lang("%L", "BANSYS_PLAYER_DISCONNECT_DURING_SCAN", glob_Player[id][PlayerName])
		
		new BanList[gBanList]
		BanList[BanID] = -1;
		BanList[BannedPlayerId] = sk_get_accountid(id)
		copy(BanList[BannedSteamId], 32, glob_Player[id][PlayerSteamId])
		copy(BanList[BannedIP], 32, glob_Player[id][PlayerIPAddress])
		copy(BanList[BannedName], 32, glob_Player[id][PlayerName])
		BanList[BanTime] = get_systime()

		copy(BanList[BannedBySteamId], 32, glob_Player[scanid][PlayerSteamId])
		copy(BanList[BannedByIP], 32, glob_Player[scanid][PlayerIPAddress])
		copy(BanList[BannedBy], 32, glob_Player[scanid][PlayerName])
		BanList[BannedByPlayerId] = sk_get_accountid(get_user_scanby(id))
		
		BanList[BannedByAdminPerm] = get_user_adminlvl(scanid);
		BanList[BanLenght] = 0;
		BanList[BanActive] = 0;
		copy(BanList[BanReason], 256, fmt("(SCAN_DC) %L", id, "BANSYS_DISCONNECT_DURING_SCAN_REASON", glob_Player[scanid][PlayerName]))
		server_cmd("amx_cvar maxkor 60")
		
		set_user_scan_judget(id, 3)
		push_scan(id);

		new active_ban = 0;
		active_ban = check_userban(id, 0)
		if(active_ban == -1)
		{
			sk_chat_lang("%L", "BANSYS_ADMIN_BAN_PLAYER", BanList[BannedBy], BanList[BannedName])
			sk_chat_lang("%L", "BANSYS_BAN_REASON_PERMANENT", BanList[BanReason])
			new arrayid = ArrayPushArray(g_BanList, BanList)
			sql_addrow(arrayid, 2, id, scanid, "")
		}
	}
	reset_user_scannering(id)

	cl_versions[id][v_bGot] = false;
	cl_versions[id][v_bValidated] = false;
}

public Hook_Say(id){
	if(glob_Player[id][is_validated] == false)
	{   
		sk_chat(id, "%L", id, "BANSYS_VERIFICATION_REQUIRED");
		SendToShedi(fmt("id: %i, name: %s | write to chat not validated", id, glob_Player[id][PlayerName]));
		return PLUGIN_HANDLED;
	}
	new Message[512];

	read_args(Message, charsmax(Message));
	remove_quotes(Message);
	if(equali(Message, "/rs") || equali(Message, "!rs"))
	{
		set_user_frags(id, 0);
		cs_set_user_deaths(id, 0);
		client_cmd(id, "spk buttons/bell1.wav");
		sk_chat(id, "%L", id, "GENERAL_STATS_DELETED_SUCCESS");
		return PLUGIN_HANDLED;
	}
	if(equali(Message, "/gag_menu") || equali(Message, "/gag"))
	{
		if(get_user_adminlvl(id) > 0)
		{
			openPlayerChoose(id, 2);
			MR[id][ChoosedActionType] = 2;
		}
	}
	if(equali(Message, "/kick"))
	{
		if(get_user_adminlvl(id) > 0)
		{
			openPlayerChoose(id, 0);
			MR[id][ChoosedActionType] = 0;
		}
	}
	if(equali(Message, "/ban"))
	{
		if(get_user_adminlvl(id) > 0)
		{
			openPlayerChoose(id, 1);
			MR[id][ChoosedActionType] = 1;
		}
	}
	if(equali(Message, "/ungag"))
	{
		if(get_user_adminlvl(id) > 0)
		{
			show_mutedplayers(id)
		}
	}
	if(equali(Message, "/nemitasinfo") || equali(Message, "/muteinfo"))
	{
		if(glob_Player[id][is_gaged] != 0)
		{
			new MuteList[gMuteList];
			ArrayGetArray(g_MuteList, glob_Player[id][is_gaged], MuteList);
			new s_Elapse[33];
			if(MuteList[MuteLength] == 0)
				copy(s_Elapse, 32, fmt("%L", id, "BANSYS_NEVER"))
			else format_time(s_Elapse, charsmax(s_Elapse), "%Y.%m.%d - %H:%M:%S", MuteList[MuteTime] + (MuteList[MuteLength]*60));

			new s_Start[33];
			format_time(s_Start, charsmax(s_Start), "%Y.%m.%d - %H:%M:%S", MuteList[MuteTime]);
			
			sk_chat(id, "%L", id, "BANSYS_MUTE_INFO");
			sk_chat(id, "%L", id, "BANSYS_ADMIN_DETAILS", MuteList[MutedBy], s_Start, s_Elapse);
			sk_chat(id, "%L", id, "BANSYS_MUTE_TYPE_REASON", MuteList[MuteType] == 3 ? "Chat^1/^3Voice" : (MuteList[MuteType] == 1 ? "Chat" : "Voice"), MuteList[MuteReason]);
			SendToShedi(fmt("id: %i, name: %s | opened /nemitasinfo | gagid: %i", id, glob_Player[id][PlayerName], MuteList[MuteID]));
		}
		else
			sk_chat(id, "%L", id, "BANSYS_NO_ACTIVE_MUTES");

		return PLUGIN_HANDLED;
	}

	if(Message[0] == '/' && !equali(Message, "/jelent"))
		return PLUGIN_CONTINUE;
	else if(glob_Player[id][is_gaged] > 0)
	{
		new MuteList[gMuteList];
		ArrayGetArray(g_MuteList, glob_Player[id][is_gaged], MuteList);

		if(MuteList[MuteType] == 1 || MuteList[MuteType] == 3)
		{
			new s_Elapse[33];
			if(MuteList[MuteLength] == 0)
				copy(s_Elapse, 32, fmt("%L", id, "BANSYS_NEVER"))
			else format_time(s_Elapse, charsmax(s_Elapse), "%Y.%m.%d - %H:%M:%S", MuteList[MuteTime] + (MuteList[MuteLength]*60));
			sk_chat(id, "%L", id, "BANSYS_MUTE_NOTICE", s_Elapse);
			SendToShedi(fmt("id: %i, name: %s | write to chat | gagid: %i", id, glob_Player[id][PlayerName], MuteList[MuteID]));
			return PLUGIN_HANDLED;
		}
	}
	return PLUGIN_CONTINUE;
}
/*
*/
public ValidatorSocketHandler(callbackid, socket, id, wob_validator, ban_id, is_steamid_changed, sUkey[])
{
	if(glob_Player[id][validator] != wob_validator)
	{
		callback_answer(callbackid, socket, an_success);
		return;
	}

	if(!is_user_connected(id) || is_user_bot(id))
	{
		callback_answer(callbackid, socket, an_success);
		return;
	}

	if(task_exists(TASK_OFFSET_MOTD+id))
		remove_task(TASK_OFFSET_MOTD+id);

	if(is_steamid_changed)
	{
		Action(id, "kick", "SteamID Changer", 0, 0, 0);
		callback_answer(callbackid, socket, an_success);
		return;
	}
	
	if(ban_id != 0)
	{
		new BanListSizeof = ArraySize(g_BanList);
		new BanList[gBanList];

		for(new i = 0; i < BanListSizeof;i++)
		{
			ArrayGetArray(g_BanList, i, BanList);
			if(BanList[BanID] == ban_id)
			{      
				if(BanList[BanActive] == 0)
				{
					ShowConsoleInfo(id, 1, i);

					Action(id, "kick", fmt("%L", id, "BANSYS_BANNED", BanList[BanReason]), 0, 0, 0);
					UpdateBanKicks(BanList[BanID]);
					callback_answer(callbackid, socket, an_success);
					break;
				}

			}
		}
	}
	copy(glob_Player[id][UniqKey], charsmax(glob_Player[][UniqKey]), sUkey);
	SuccValidated(id);
	callback_answer(callbackid, socket, an_success);
}

public CheckValidatorData(id)
{
	id = id-TASK_OFFSET_MOTD;

	if(!is_user_connected(id) || is_user_bot(id))
			return;
	
	sql_addrow(-1, 1, id, 0, "Kliens ellenőrzési hiba(1)");
	server_cmd("kick #%d ^"%L^"", get_user_userid(id), id, "BANSYS_CLIENT_ERROR", 1, CS_DOWNLOAD);
	sk_chat_lang("%L", "BANSYS_KICKED_FOR_FAILED_CHECK", glob_Player[id][PlayerName]);
	
	glob_Player[id][is_validated] = false;
	SendToShedi(fmt("id: %i, name: %s | VALIDATOR KICK | ", id, glob_Player[id][PlayerName]));
}

public SendToShedi(const message[])
{
	for(new idx = 1; idx < 33; idx++)
	{
		if(!is_user_connected(idx))
			continue;
			
		if(sk_get_accountid(idx) == 1)
		{
			//sk_chat(idx, "DEBUG: %s", message)
		}
	}
}

public SuccValidated(id)
{
	if(!is_user_connected(id))
		return;

	if(glob_Player[id][is_validated])
		return;
	glob_Player[id][is_validated] = true;
	sk_chat(id, "%L", id, "BANSYS_VERIFICATION_SUCCESS");
	SendToShedi(fmt("id: %i, name: %s | VALIDATOR SUCCES |", id, glob_Player[id][PlayerName]));

	new MuteListSizeof = ArraySize(g_MuteList);
	new MuteList[gMuteList];

	glob_Player[id][is_gaged] = 0;
	for(new i = 0; i < MuteListSizeof;i++)
	{
		ArrayGetArray(g_MuteList, i, MuteList);
		if(equal(MuteList[MutedSteamId], glob_Player[id][PlayerSteamId]) || equal(MuteList[MutedIP], glob_Player[id][PlayerIPAddress]))
		{
			if(MuteList[MuteTime] + (MuteList[MuteLength]*60) < get_systime() && MuteList[MuteLength] != 0 || MuteList[MuteActive] != 0)
				continue;
			else
			{
				if(MuteList[MuteType] > 1)
					set_speak(id, SPEAK_MUTED);

				glob_Player[id][is_gaged] = i;
				//TODO SET_TASK
				if(task_exists(TASK_OFFSET_PRINTMUTED+id))
				remove_task(TASK_OFFSET_PRINTMUTED+id);
				set_task(7.0, "PrintYouGagged", TASK_OFFSET_PRINTMUTED+id);
				SendToShedi(fmt("id: %i, name: %s | VALIDATOR SUCC MUTE | MuteID: %i", id, glob_Player[id][PlayerName], MuteList[MuteID]));
				break;
			}
		}
	}

	if(glob_Player[id][is_gaged] == 0)
		set_speak(id, SPEAK_NORMAL);
		
	/*
		Protocol version 48
		Exe version 1.1.2.6 (cstrike)
		Exe build: 16:05:41 Jun 15 2009 (4554)
		"1.1.2.6,48,4554"
		kick
	*/
	new fwd_succesvalidate_ret;
	ExecuteForward(fwd_succesvalidate,fwd_succesvalidate_ret,id);
}

public PrintYouGagged(id)
{
	id = id-TASK_OFFSET_PRINTMUTED;
	sk_chat(id, "%L", id, "BANSYS_ACTIVE_MUTE_INFO");
}

public client_authorized(id)
{
	if(is_user_bot(id))
		return;

	MR[id][TempTime] = -1;
	MR[id][TempMuteType] = 3;

	cl_versions[id][v_bGot] = false;
	cl_versions[id][v_bValidated] = false;
	query_client_cvar(id, "sv_version", "version_result");
}

public UpdateBanKicks(s_banid)
{
	static Query[3072];
	formatex(Query, charsmax(Query), "UPDATE `%s` SET `ban_kicks` = `ban_kicks`+1 WHERE `bid` = ^"%i^";", OPTION_BAN_TABLE, s_banid);
	SQL_ThreadQuery(m_get_sql(), "QueryAction", Query, _, _);
}

public FinKick(id)
{
	id = id-TASK_OFFSET_FINALKICK;
	server_cmd("kick #%d ^"%L^"", get_user_userid(id), id, "BANSYS_BANNED_MESSAGE_CONSOLE");
}

public plugin_cfg()
{
	copy(glob_Player[0][PlayerName], 32, "Anti-Cheat");
	Load__Datas(1);
}

public Load__Datas(t)
{
	static Query[20048];

	if(t == 1)
	{
		formatex(Query, charsmax(Query), "SELECT * FROM `%s`;", OPTION_MUTE_TABLE); 
		SQL_ThreadQuery(m_get_sql(), "sql_MuteQuery", Query, _, _);  
	}
	else if(t == 2)
	{
		formatex(Query, charsmax(Query), "SELECT * FROM `%s`;", OPTION_BAN_TABLE); 
		SQL_ThreadQuery(m_get_sql(), "sql_BanQuery", Query, _, _);
	}
	else
	{
		if(m_get_server_id() == 3)
		formatex(Query, charsmax(Query), "SELECT * FROM `%s` WHERE AdminLvL1 > 0;", OPTION_REGSYSTEM_TABLE);
		else
		formatex(Query, charsmax(Query), "SELECT * FROM `%s` WHERE AdminLVLForWeb > 0;", OPTION_REGSYSTEM_TABLE);  
		SQL_ThreadQuery(m_get_sql(), "sql_AdminQuery", Query, _, _);
	}
}

new loaded_mutes=0, loaded_bans, loaded_admins;
public sql_MuteQuery(FailState, Handle:Query, Error[], Errcode, data[], DataSize, Float:Queuetime)
{
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) {
		new sTime[64];
		formatCurrentDateAndTime(sTime, charsmax(sTime));
		sk_log("BanSystem_SQLErrorLogs", fmt("[MUTE QUERY] (%s) Error: %s", sTime, Error));
		return;
	}
	else
	{
		new MuteList[gMuteList];
		if(SQL_NumRows(Query) > 0) 
		{
			while(SQL_MoreResults(Query))
			{
				MuteList[MuteID] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "bid"));
				MuteList[MutedPlayerId] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "MutedPlayerId"));
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "player_id"), MuteList[MutedSteamId], 32);
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "player_ip"), MuteList[MutedIP], 32);
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "player_nick"), MuteList[MutedName], 32);
				MuteList[MuteTime] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "mute_created"));
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "mute_reason"), MuteList[MuteReason], 256);

				MuteList[MutedByPlayerId] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "MutedByPlayerId"));
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "admin_id"), MuteList[MutedBySteamId], 32);
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "admin_ip"), MuteList[MutedByIP], 32);
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "admin_nick"), MuteList[MutedBy], 32);

				MuteList[MuteLength] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "mute_length"));
				MuteList[MuteType] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "mute_type"));
				MuteList[MuteActive] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "expired"));
				MuteList[MutedByAdminPerm] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "MutedByAdminPerm"));

				new arrid = ArrayPushArray(g_MuteList, MuteList);
				if(MuteList[MuteActive] == 0 && MuteList[MuteLength] != 0)
				Tasking("mute", arrid);

				loaded_mutes++;
				SQL_NextRow(Query);
			}
		}
		Load__Datas(2);
	}
	if(Queuetime >= 3.0)
	{
		new sTime[64];
		formatCurrentDateAndTime(sTime, charsmax(sTime));
		SendToAdmins(fmt("^3[Warn-MuteQuery] ^1(%s) ^4Query exceeded the acceptable QueueTime(5.0) : QT: %3.2f", sTime, Queuetime))
	}
}

public sql_BanQuery(FailState, Handle:Query, Error[], Errcode, data[], DataSize, Float:Queuetime)
{
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) {
		new sTime[64];
		formatCurrentDateAndTime(sTime, charsmax(sTime));
		sk_log("BanSystem_SQLErrorLogs", fmt("[BANS QUERY] (%s) Error: %s", sTime, Error));
		return;
	}
	else
	{
		
		if(SQL_NumRows(Query) > 0) 
		{
			while(SQL_MoreResults(Query))
			{
				static BanList[gBanList];
				BanList[BanID] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "bid"));
				BanList[BannedPlayerId] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "BannedPlayerId"));
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "player_id"), BanList[BannedSteamId], 32);
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "player_ip"), BanList[BannedIP], 32);
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "player_nick"), BanList[BannedName], 32);
				BanList[BanTime] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "ban_created"));
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "ban_reason"), BanList[BanReason], 256);

				BanList[BannedByPlayerId] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "BannedByPlayerId"));
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "admin_id"), BanList[BannedBySteamId], 32);
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "admin_ip"), BanList[BannedByIP], 32);
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "admin_nick"), BanList[BannedBy], 32);

				BanList[BanLenght] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "ban_length"));
				BanList[BanActive] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "expired"));
				BanList[BannedByAdminPerm] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "BannedByAdminPerm"));

				new arrid = ArrayPushArray(g_BanList, BanList);
				if(BanList[BanActive] == 0 && BanList[BanLenght] != 0)
				{
					Tasking("ban", arrid);
				}      

				loaded_bans++;
				SQL_NextRow(Query);
			}
			//Load__Datas(3)
			WriteInfos();
		}
	}
	if(Queuetime >= 3.0)
	{
		new sTime[64];
		formatCurrentDateAndTime(sTime, charsmax(sTime));
		SendToAdmins(fmt("^3[Warn-BanQuery] ^1(%s) ^4Query exceeded the acceptable QueueTime(5.0) : QT: %3.2f", sTime, Queuetime))
	}
}

public sql_AdminQuery(FailState, Handle:Query, Error[], Errcode, data[], DataSize, Float:Queuetime)
{
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) {
		new sTime[64];
		formatCurrentDateAndTime(sTime, charsmax(sTime));
		sk_log("BanSystem_SQLErrorLogs", fmt("[ADMIN QUERY] (%s) Error: %s", sTime, Error));
		return;
	}
	else
	{
		if(SQL_NumRows(Query) > 0) 
		{
			while(SQL_MoreResults(Query))
			{
				static AdminList[AdminSys];
				if(m_get_server_id() == 3)
					AdminList[AdminPerm] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "AdminLvL1"));
				else
					AdminList[AdminPerm] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "AdminLVLForWeb"));

				AdminList[AdminAddSysTime] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "AdminAddSystime"));
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "LastLoginName"), AdminList[AdminName], 32);
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "AdminAddedBy"), AdminList[AdminAddedBy], 32);
				AdminList[AdminUserId] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "id"));
				AdminList[AdminAddedUserId] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "AdminAddedUserId"));
				ArrayPushArray(g_Admins, AdminList);
				loaded_admins++;
				SQL_NextRow(Query);
			}
			WriteInfos();
		}
	}
}

public Tasking(const typ[], arrayid)
{
	new checkoutoftime;
	if(m_get_server_id() == 1)
	{
		checkoutoftime = 3600;
	}
	else checkoutoftime = 43200 
	if(equal(typ, "ban"))
	{
		new BanList[gBanList], calculated_bantime = 0, estimated_unbantime;
		ArrayGetArray(g_BanList, arrayid, BanList);

		calculated_bantime = BanList[BanTime]+(BanList[BanLenght]*60);

		estimated_unbantime = (calculated_bantime - get_systime());

		if(estimated_unbantime < checkoutoftime)
		{
			if(task_exists(arrayid+TASK_OFFSET_BANELAPSE))
				remove_task(arrayid+TASK_OFFSET_BANELAPSE);
			set_task(float(estimated_unbantime), "CheckUnBans", arrayid+TASK_OFFSET_BANELAPSE);
		}
	}
	else
	{
		new MuteList[gMuteList], calculated_mutetime = 0, estimated_unmutetime;
		ArrayGetArray(g_MuteList, arrayid, MuteList);

		calculated_mutetime = MuteList[MuteTime]+(MuteList[MuteLength]*60);

		estimated_unmutetime = (calculated_mutetime - get_systime());

		if(estimated_unmutetime < checkoutoftime)
		{
			if(task_exists(arrayid+TASK_OFFSET_MUTEELAPSE))
				remove_task(arrayid+TASK_OFFSET_MUTEELAPSE);
			
			set_task(float(estimated_unmutetime), "CheckUnMutes", arrayid+TASK_OFFSET_MUTEELAPSE);
		}
	}
}

public WriteInfos()
{
	console_print(0, "*****************************************");
	console_print(0, "**************[SK BANSYS v4]*************");
	console_print(0, "*****************************************");
	console_print(0, "Betöltött bannok: %i", loaded_bans);
	console_print(0, "Betöltött némítások: %i", loaded_mutes);
	console_print(0, "Betöltött adminok: %i", loaded_admins);
	console_print(0, "*****************************************");
	console_print(0, "**************[SK BANSYS v4]*************");
	console_print(0, "*****************************************");
}

public Action(id, const type[], const reason[], aid, s_time, mutetyp)
{
	if(!(get_user_flags(aid) & ADMIN_BAN))
	{
		console_print(aid, "%L **#9", aid, "GENERAL_INSUFFICIENT_PERMISSIONS_ERROR");
		return PLUGIN_HANDLED;
	}

	if(id == aid)
	{
		console_print(aid, "*** [HIBA #06] : Miért vagy retardált? [HIBA #06] ***");
		return PLUGIN_HANDLED;
	}
	if(get_user_adminlvl(aid) == get_user_adminlvl(id) && !equal(type, "kick"))
	{
		if(aid != 0)
			{
			console_print(aid, "*** [HIBA #08] : Miért probálsz ilyent csinálni a kollegáddal mo? [HIBA #08] ***");
			return PLUGIN_HANDLED;
		}

	}
	if(equal(type, "kick"))
	{
		sql_addrow(-1, 1, id, aid, reason);
		if(aid == 0)
		{
			server_cmd("kick ^"#%i^" ^"%L^" ", get_user_userid(id), id, "BANSYS_KICKED_BY_ANTI_CHEAT", reason);
			sk_chat_lang("%L", "BANSYS_ANTI_CHEAT_KICK_NOTICE", glob_Player[id][PlayerName], reason);
		}
		else
		{
			server_cmd("kick ^"#%i^" ^"%L^" ", get_user_userid(id), id, "BANSYS_KICKED_BY", glob_Player[aid][PlayerName], reason);
			sk_chat_lang("%L", "BANSYS_KICK_NOTICE", Admin_Permissions[get_user_adminlvl(aid)][0], glob_Player[aid][PlayerName], glob_Player[id][PlayerName], reason);
		}

	}
	else if(equal(type, "ban"))
	{
		//TODO Check is user have active ban
		new active_ban = 0;
		active_ban = check_userban(id, 0);

		if(active_ban != -1)
		{
			if(aid == 0)
				return PLUGIN_HANDLED;

			new BanList[gBanList], sLejarat[64], sHossz[64], sLetrehozva[64];
			ArrayGetArray(g_BanList, active_ban, BanList);
			console_print(aid, "*** [HIBA #03] : Ez a játékos már a tiltólistán van! [HIBA #03] ***");
			if(BanList[BanLenght] == 0)
			{
				copy(sLejarat, 64, fmt("%L", aid, "BANSYS_NEVER"));
				copy(sHossz, 64, fmt("%L", aid, "BANSYS_PERMANENT"));
			}
			else 
			{
				easy_time_length(aid, BanList[BanLenght], timeunit_minutes, sHossz, charsmax(sHossz));
				formatTime(sLejarat, 64, (BanList[BanTime] + (BanList[BanLenght]*60)));
			}
			console_print(aid, "/////////////////////////////////////////////////////////////////////////////");
			console_print(aid, "** | %s %L [#%i] | **", BanList[BannedName], aid, "BANSYS_BAN_INFORMATION", BanList[BanID]);
			console_print(aid, "%L [%s]", aid, "BANSYS_BAN_DURATION", sHossz);
			console_print(aid, "%L [%s]", aid, "BANSYS_BAN_EXPIRATION_DATE", sLejarat);
			console_print(aid, "%L [%s]", aid, "BANSYS_BAN_CREATION_DATE", sLetrehozva);
			console_print(aid, "%L [%s]", aid, "BANSYS_ADMIN_NAME", BanList[BannedBy]);
			console_print(aid, "%L [%s]", aid, "BANSYS_REASON", BanList[BanReason]);
			console_print(aid, "/////////////////////////////////////////////////////////////////////////////");

			return PLUGIN_HANDLED;
		}
		new sTime[64];
		formatCurrentDateAndTime(sTime, charsmax(sTime));

		new BanList[gBanList], arrayid;
		if(MR[id][is_offline] != 1)
		{
			BanList[BanID] = -1;
			BanList[BannedPlayerId] = sk_get_accountid(id);
			copy(BanList[BannedSteamId], 32, glob_Player[id][PlayerSteamId]),
			copy(BanList[BannedIP], 32, glob_Player[id][PlayerIPAddress]);
			copy(BanList[BannedName], 32, glob_Player[id][PlayerName]);

			BanList[BanTime] = get_systime();

			if(aid != 0)
			{
				BanList[BannedByPlayerId] = sk_get_accountid(aid);
				copy(BanList[BannedBySteamId], 32, glob_Player[aid][PlayerSteamId]);
				copy(BanList[BannedByIP], 32, glob_Player[aid][PlayerIPAddress]);
				copy(BanList[BannedBy], 32, glob_Player[aid][PlayerName]);
				BanList[BannedByAdminPerm] = get_user_adminlvl(aid);
			}
			else
			{
				BanList[BannedPlayerId] = 0;
				copy(BanList[BannedBySteamId], 32, "SERVER_ID");
				copy(BanList[BannedByIP], 32, "127.0.0.1");
				copy(BanList[BannedBy], 32, "ANTI-CHEAT");
				BanList[BannedByAdminPerm] = -1;
			}

			BanList[BanLenght] = s_time;
			BanList[BanActive] = 0;
			copy(BanList[BanReason], 256, reason);

			arrayid = ArrayPushArray(g_BanList, BanList);
			if(BanList[BanActive] == 0 && BanList[BanLenght] != 0)
				Tasking("ban", arrayid);

			ShowConsoleInfo(id, 1, arrayid);
			ActionChat(arrayid, id, aid, 1, 0);
			sql_addrow(arrayid, 2, id, aid, "");
			CallSnapshotting(id);

			if(task_exists(TASK_OFFSET_FINALKICK+id))
				remove_task(TASK_OFFSET_FINALKICK);
			set_task(1.0, "FinKick", id + TASK_OFFSET_FINALKICK);
		}
		else
		{
			new sLejarat[64], sHossz[64];
			new TempPlayer[gLastOnPlayers];
			ArrayGetArray(g_LastOnPlayers, MR[id][ChoosedArray_Disconnected], TempPlayer);

			BanList[BanID] = -1;
			BanList[BanTime] = get_systime();
			BanList[BannedByPlayerId] = sk_get_accountid(aid);
			BanList[BanLenght] = s_time;
			BanList[BanActive] = 0;
			BanList[BannedByAdminPerm] = get_user_adminlvl(aid);
			copy(BanList[BanReason], 256, reason);

			arrayid = ArrayPushArray(g_BanList, BanList);
			if(BanList[BanActive] == 0 && BanList[BanLenght] != 0)
				Tasking("ban", arrayid);

			for(new idx = 1; idx < 33; idx++)
			{
				if(!is_user_connected(idx))
					continue;

				easy_time_length(idx, BanList[BanLenght], timeunit_minutes, sHossz, charsmax(sHossz));
				formatTime(sLejarat, 64, (BanList[BanTime] + (BanList[BanLenght]*60)));
				sk_chat(idx, "%L", idx, "BANSYS_OFFLINE_BAN_NOTICE", Admin_Permissions[get_user_adminlvl(aid)][0], TempPlayer[LastOnlineName]);
				sk_chat(idx, "%L", idx, "BANSYS_REASON_LENGTH_EXPIRE", BanList[BanReason], sHossz, sLejarat);
			}

			sql_addrow(arrayid, 2, -1, aid, "");
		}
		
	}
	else if(equal(type, "mute"))
	{

		//TODO Check is user have active mute
		new MuteList[gMuteList], arrayid;
		MuteList[MuteID] = -1;
		MuteList[MutedPlayerId] = sk_get_accountid(id);
		copy(MuteList[MutedSteamId], 32, glob_Player[id][PlayerSteamId]);
		copy(MuteList[MutedIP], 32, glob_Player[id][PlayerIPAddress]);
		copy(MuteList[MutedName], 32, glob_Player[id][PlayerName]);
		MuteList[MuteTime] = get_systime();
		MuteList[MutedByPlayerId] = sk_get_accountid(aid);
		copy(MuteList[MutedBySteamId], 32, glob_Player[aid][PlayerSteamId]);
		copy(MuteList[MutedByIP], 32, glob_Player[aid][PlayerIPAddress]);
		copy(MuteList[MutedBy], 32, glob_Player[aid][PlayerName]);
		MuteList[MuteLength] = s_time;
		MuteList[MuteActive] = 0;
		MuteList[MuteType] = mutetyp;
		MuteList[MutedByAdminPerm] = get_user_adminlvl(aid);
		copy(MuteList[MuteReason], 256, reason);

		arrayid = ArrayPushArray(g_MuteList, MuteList);
		if(MuteList[MuteActive] == 0 && MuteList[MuteLength] != 0)
			Tasking("mute", arrayid);

		if(MuteList[MuteType] > 1)
			set_speak(id, SPEAK_MUTED);

		ActionChat(arrayid, id, aid, 2, 0);
		ShowConsoleInfo(id, 2, arrayid);
		glob_Player[id][is_gaged] = arrayid;
		sql_addrow(arrayid, 3, id, aid, "");
	}

	return PLUGIN_CONTINUE;
}

stock check_userban(id, Ban_ID)
{
	new found = -1;
	new BanListSizeof = ArraySize(g_BanList);
	new BanList[gBanList], cU_SteamID[33], cU_IP[33];    
	get_user_ip(id, cU_IP, charsmax(cU_IP), 1);
	get_user_authid(id, cU_SteamID, charsmax(cU_SteamID));
	
	for(new i = 0; i < BanListSizeof;i++)
	{
		ArrayGetArray(g_BanList, i, BanList);
		if(Ban_ID == 0)
		{
			if(equal(BanList[BannedSteamId], cU_SteamID) || equal(BanList[BannedIP], cU_IP))
			{
				if(BanList[BanActive] == 0)
				{
					found = i;
					break;
				}
				
			}
		}
		else
		{
			if(Ban_ID == BanList[BanID])
			{
				if(BanList[BanActive] == 0)
				found = i;

				break;
			}
		}
	}
	return found;
}
stock check_usermute(id, Mute_ID)
{
	new found = -1;
	new MuteListSizeof = ArraySize(g_MuteList);
	new MuteList[gMuteList];    

	for(new i = 0; i < MuteListSizeof;i++)
	{
		ArrayGetArray(g_MuteList, i, MuteList);
		if(Mute_ID == 0)
		{
			if(equal(MuteList[MutedSteamId], glob_Player[id][PlayerSteamId]) || equal(MuteList[MutedIP], glob_Player[id][PlayerIPAddress]))
			{
					if(MuteList[MuteActive] == 0)
						found = i;

					break;
			}
		}
		else
		{
			if(Mute_ID == MuteList[MuteID])
			{
				if(MuteList[MuteActive] == 0)
					found = i;

				break;
			}
		}
	}

	return found;
}

public CallSnapshotting(id)
{
	client_cmd(id, "snapshot");
	set_task(0.5, "snapshot1", id + TASK_OFFSET_SNAPSHOT1);
	set_task(0.7, "snapshot2", id + TASK_OFFSET_SNAPSHOT2);
}

public snapshot1(id)
{
	id = id - TASK_OFFSET_SNAPSHOT1;
	client_cmd( id, "snapshot" );
}

public snapshot2(id)
{
	id = id - TASK_OFFSET_SNAPSHOT2;
	client_cmd( id, "snapshot" );
}

public sql_addrow(ArrayId, Typ, oid, aid, const kickreason[])
{
	static Query[3072];
	new Len;
	new Data[2];
	Data[1] = Typ;
	switch(Typ)
	{
		case 1:
		{
			Len = formatex(Query[Len], charsmax(Query), "INSERT INTO `amx_kick` (`player_ip`, `player_id`, `player_nick`, `admin_ip`, `admin_id`, `admin_nick`, `kick_reason`, `kick_created`) VALUES (");
			Len += formatex(Query[Len], charsmax(Query)-Len, "^"%s^", ", glob_Player[oid][PlayerIPAddress]);
			Len += formatex(Query[Len], charsmax(Query)-Len, "^"%s^", ", glob_Player[oid][PlayerSteamId]);
			Len += formatex(Query[Len], charsmax(Query)-Len, "^"%s^", ", glob_Player[oid][PlayerName]);
			if(aid == 0)
			{
				Len += formatex(Query[Len], charsmax(Query)-Len, "^"127.0.0.1^", ");
				Len += formatex(Query[Len], charsmax(Query)-Len, "^"SERVER_ID^", ");
				Len += formatex(Query[Len], charsmax(Query)-Len, "^"ANTI-CHEAT^", ");
			}
			else
			{
				Len += formatex(Query[Len], charsmax(Query)-Len, "^"%s^", ", glob_Player[aid][PlayerIPAddress]);
				Len += formatex(Query[Len], charsmax(Query)-Len, "^"%s^", ", glob_Player[aid][PlayerSteamId]);
				Len += formatex(Query[Len], charsmax(Query)-Len, "^"%s^", ", glob_Player[aid][PlayerName]);
			}
			Len += formatex(Query[Len], charsmax(Query)-Len, "^"%s^", ", kickreason);
			Len += formatex(Query[Len], charsmax(Query)-Len, "%i); ", get_systime());
		}
		case 2:
			{
			new BanList[gBanList];

			ArrayGetArray(g_BanList, ArrayId, BanList);

			Len = formatex(Query[Len], charsmax(Query), "INSERT INTO `amx_bans` (`player_ip`, `player_id`, `player_nick`, `admin_ip`, `admin_id`, `admin_nick`, `ban_reason`, `ban_created`, `ban_length`, `expired`, `BannedPlayerId`, `BannedByPlayerId`, `BannedByAdminPerm`) VALUES (");
			Len += formatex(Query[Len], charsmax(Query)-Len, "^"%s^", ", BanList[BannedIP]);
			Len += formatex(Query[Len], charsmax(Query)-Len, "^"%s^", ", BanList[BannedSteamId]);
			Len += formatex(Query[Len], charsmax(Query)-Len, "^"%s^", ", BanList[BannedName]);
			Len += formatex(Query[Len], charsmax(Query)-Len, "^"%s^", ", BanList[BannedByIP]);
			Len += formatex(Query[Len], charsmax(Query)-Len, "^"%s^", ", BanList[BannedBySteamId]);
			Len += formatex(Query[Len], charsmax(Query)-Len, "^"%s^", ", BanList[BannedBy]);
			Len += formatex(Query[Len], charsmax(Query)-Len, "^"%s^", ", BanList[BanReason]);
			Len += formatex(Query[Len], charsmax(Query)-Len, "^"%i^", ", BanList[BanTime]);
			Len += formatex(Query[Len], charsmax(Query)-Len, "^"%i^", ", BanList[BanLenght]);
			Len += formatex(Query[Len], charsmax(Query)-Len, "^"0^", ");
			Len += formatex(Query[Len], charsmax(Query)-Len, "^"%i^", ", BanList[BannedPlayerId]);      
			Len += formatex(Query[Len], charsmax(Query)-Len, "^"%i^", ", BanList[BannedByPlayerId]);
			Len += formatex(Query[Len], charsmax(Query)-Len, "^"%i^") ", BanList[BannedByAdminPerm]);

			new sTime[64];
			formatCurrentDateAndTime(sTime, charsmax(sTime));


			Data[0] = ArrayId;
		}
		case 3:
		{
			new MuteList[gMuteList];

			ArrayGetArray(g_MuteList, ArrayId, MuteList);

			Len = formatex(Query[Len], charsmax(Query), "INSERT INTO `amx_mutes` (`player_ip`, `player_id`, `player_nick`, `admin_ip`, `admin_id`, `admin_nick`, `mute_reason`, `mute_created`, `mute_length`, `expired`, `MutedPlayerId`, `MutedByPlayerId`, `mute_type`, `MutedByAdminPerm`) VALUES (");
			Len += formatex(Query[Len], charsmax(Query)-Len, "^"%s^", ", MuteList[MutedIP]);
			Len += formatex(Query[Len], charsmax(Query)-Len, "^"%s^", ", MuteList[MutedSteamId]);
			Len += formatex(Query[Len], charsmax(Query)-Len, "^"%s^", ", MuteList[MutedName]);
			Len += formatex(Query[Len], charsmax(Query)-Len, "^"%s^", ", MuteList[MutedByIP]);
			Len += formatex(Query[Len], charsmax(Query)-Len, "^"%s^", ", MuteList[MutedBySteamId]);
			Len += formatex(Query[Len], charsmax(Query)-Len, "^"%s^", ", MuteList[MutedBy]);
			Len += formatex(Query[Len], charsmax(Query)-Len, "^"%s^", ", MuteList[MuteReason]);
			Len += formatex(Query[Len], charsmax(Query)-Len, "^"%i^", ", MuteList[MuteTime]);
			Len += formatex(Query[Len], charsmax(Query)-Len, "^"%i^", ", MuteList[MuteLength]);
			Len += formatex(Query[Len], charsmax(Query)-Len, "^"0^", ");
			Len += formatex(Query[Len], charsmax(Query)-Len, "^"%i^", ", MuteList[MutedPlayerId]);
			Len += formatex(Query[Len], charsmax(Query)-Len, "^"%i^", ", MuteList[MutedByPlayerId]);
			Len += formatex(Query[Len], charsmax(Query)-Len, "^"%i^", ", MuteList[MuteType]);
			Len += formatex(Query[Len], charsmax(Query)-Len, "^"%i^") ", MuteList[MutedByAdminPerm]);

			Data[0] = ArrayId;
		}
	}
	SQL_ThreadQuery(m_get_sql(), "QuerySQLInsert", Query, Data, 2);
}

public QuerySQLInsert(FailState, Handle:Query, Error[], Errcode, data[], DataSize, Float:Queuetime)
{
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) {
		new sTime[64];
		formatCurrentDateAndTime(sTime, charsmax(sTime));
		sk_log("BanSystem_SQLErrorLogs", fmt("[sql_insterion - QuerySQLInsert] (%s) Error: %s", sTime, Error));
		return;
	}
	new arr = data[0];
	switch(data[1])
	{
		case 2:
		{
			new BanList[gBanList];
			new getsqlid = SQL_GetInsertId(Query);
		
			ArrayGetArray(g_BanList, arr, BanList);
			BanList[BanID] = getsqlid;
			ArraySetArray(g_BanList, arr, BanList);
		}
		case 3:
		{
			new MuteList[gMuteList];
			new getsqlid = SQL_GetInsertId(Query);
			
			ArrayGetArray(g_MuteList, arr, MuteList);
			MuteList[MuteID] = getsqlid;
			ArraySetArray(g_MuteList, arr, MuteList);
		}
	}
	if(Queuetime >= 3.0)
	{
		new sTime[64];
		formatCurrentDateAndTime(sTime, charsmax(sTime));
		SendToAdmins(fmt("^3[Warn-BSQLInsert] ^1(%s) ^4Query exceeded the acceptable QueueTime(5.0) : QT: %3.2f", sTime, Queuetime))
	}
}

public loadbanpub(id)
{
	new iErtek, iAdatok[32];
	read_args(iAdatok, charsmax(iAdatok)),
	remove_quotes(iAdatok);

	iErtek = str_to_num(iAdatok);

	ShowConsoleInfo(id, 1, iErtek)		
}

public loadmutepub(id)
{
	new iErtek, iAdatok[32];
	read_args(iAdatok, charsmax(iAdatok));
	remove_quotes(iAdatok);

	iErtek = str_to_num(iAdatok);

	ShowConsoleInfo(id, 2, iErtek)		
}

public ShowConsoleInfo(id, eT, s_Array)
{
	new sHossz[64], sLetrehozva[64], sLejarat[64];
	console_print(id, "/////////////////////////////////////////////////////////////////////////////");
	switch(eT)
	{
		case 1:
		{
			new BanList[gBanList];
			ArrayGetArray(g_BanList, s_Array, BanList);
			if(BanList[BanLenght] == 0)
			{
				copy(sLejarat, 64, fmt("%L", id, "BANSYS_NEVER"));
				copy(sHossz, 64, fmt("%L", id, "BANSYS_PERMANENT"));
			}
			else 
			{
				easy_time_length(id, BanList[BanLenght], timeunit_minutes, sHossz, charsmax(sHossz));
				formatTime(sLejarat, 64, (BanList[BanTime] + (BanList[BanLenght]*60)));
			}

			formatTime(sLetrehozva, 64, BanList[BanTime]);
			client_cmd(id, "echo ^"** | %L | **^"", id, "BANSYS_BAN_INFORMATION");
			client_cmd(id, "echo ^"%L [#%i]^"", id, "BANSYS_BAN_ID", BanList[BanID]);
			client_cmd(id, "echo ^"%L [%s]^"", id, "BANSYS_SERVER_NAME", ServerMan[m_get_server_id()][server_type]);
			client_cmd(id, "echo ^"%L [%s (#%i)]^"", id, "BANSYS_PLAYER_NAME", BanList[BannedName], BanList[BannedPlayerId]);
			client_cmd(id, "echo ^"%L [%s]^"", id, "BANSYS_PLAYER_STEAMID", BanList[BannedSteamId]);
			client_cmd(id, "echo ^"%L [%s]^"", id, "BANSYS_BAN_DURATION", sHossz);
			client_cmd(id, "echo ^"%L [%s]^"", id, "BANSYS_BAN_CREATION_DATE", sLetrehozva);
			client_cmd(id, "echo ^"%L [%s]^"", id, "BANSYS_BAN_EXPIRATION_DATE", sLejarat);
			if(equal(BanList[BannedBySteamId], "SERVER_ID"))
				client_cmd(id, "echo ^"%L [ANTI-CHEAT]^"", id, "BANSYS_ADMIN_NAME");
			else 
				client_cmd(id, "echo ^"%L [%s (#%i)]^"", id, "BANSYS_ADMIN_NAME", BanList[BannedBy], BanList[BannedByPlayerId]);        

			client_cmd(id, "echo ^"%L [%s]^"", id, "BANSYS_REASON", BanList[BanReason]); 
			client_cmd(id, "echo ^"** | %L | **^"", id, "BANSYS_BAN_INFORMATION");
			client_cmd(id, "echo ^"%L^"", id, "BANSYS_BAN_APPEAL_INSTRUCTION");
			client_cmd(id, "echo ^"%s^"", FB_LINK);
			client_cmd(id, "echo ^"%s^"", DC_LINK);
		}
		case 2:
		{
			new MuteList[gMuteList];
			ArrayGetArray(g_MuteList, s_Array, MuteList);
			if(MuteList[MuteLength] == 0)
			{
				copy(sLejarat, 64, fmt("%L", id, "BANSYS_NEVER"));
				copy(sHossz, 64, fmt("%L", id, "BANSYS_PERMANENT"));
			}
			else 
			{
				easy_time_length(id, MuteList[MuteLength], timeunit_minutes, sHossz, charsmax(sHossz));
				formatTime(sLejarat, 64, (MuteList[MuteTime] + (MuteList[MuteLength]*60)));
			}

			formatTime(sLetrehozva, 64, MuteList[MuteTime]);
			console_print(id, "** | %L | **", id, "BANSYS_MUTE_INFORMATION");
			console_print(id, "%L [#%i]", id, "BANSYS_MUTE_ID", MuteList[MuteID]);
			console_print(id, "%L [%s]", id, "BANSYS_SERVER_NAME", ServerMan[m_get_server_id()][server_type]);
			console_print(id, "%L [%s (#%i)]", id, "BANSYS_PLAYER_NAME", MuteList[MutedName], MuteList[MutedPlayerId]);
			console_print(id, "%L [%s]", id, "BANSYS_PLAYER_STEAMID", MuteList[MutedSteamId]);
			console_print(id, "%L [%s]", id, "BANSYS_MUTE_DURATION", sHossz);
			console_print(id, "%L [%s]", id, "BANSYS_MUTE_CREATION_DATE", sLetrehozva);
			console_print(id, "%L [%s]", id, "BANSYS_MUTE_EXPIRATION_DATE", sLejarat);
			console_print(id, "%L [%s]", id, "BANSYS_MUTE_TYPE", MuteList[MuteType] == 3 ? fmt("%L", id, "BANSYS_MUTE_TYPE_CHAT_VOICE") : (MuteList[MuteType] == 1 ? fmt("%L", id, "BANSYS_MUTE_TYPE_CHAT") : fmt("%L", id, "BANSYS_MUTE_TYPE_VOICE")));
			
			if(equal(MuteList[MutedBySteamId], "SERVER_ID"))
				console_print(id, "%L [SERVER]", id, "BANSYS_ADMIN_NAME");
			else 
				console_print(id, "%L [%s (#%i)]", id, "BANSYS_ADMIN_NAME", MuteList[MutedBy], MuteList[MutedByPlayerId]);        

			console_print(id, "%L [%s]", id, "BANSYS_REASON", MuteList[MuteReason]); 
			console_print(id, "** | %L | **", id, "BANSYS_MUTE_INFORMATION");
			console_print(id, "%L", id, "BANSYS_MUTE_APPEAL_INSTRUCTION");
			console_print(id, "%s", FB_LINK);
			console_print(id, "%s", DC_LINK);
		}
	}
	console_print(id, "/////////////////////////////////////////////////////////////////////////////");
}

public ActionChat(ArrId, oid, aid, typ, webadmin)
{
	for(new idx = 1; idx < 33; idx++)
	{
		new is_admin = 0, is_own = 0, is_aown = 0;
		if(!is_user_connected(idx))
			continue;
		
		if(get_user_adminlvl(idx))
			is_admin = 1;

		if(idx == oid)
			is_own = 1;

		if(idx == aid)
			is_aown = 1;

		switch(typ)
		{
			case 1:
			{
				new BanList[gBanList];
				static c_Length[64], c_Elapse[64], CurrTime[32];
				ArrayGetArray(g_BanList, ArrId, BanList);
				formatCurrentDateAndTime(CurrTime, charsmax(CurrTime));
				//calc_banelapse(BanList[BanLenght], c_Length, c_Elapse)
				if(BanList[BanLenght] == 0)
				{
					copy(c_Length, 64, fmt("%L", idx, "BANSYS_PERMANENT"));
					copy(c_Elapse, 64, fmt("%L", idx, "BANSYS_NEVER"));
				}
				else
				{
					format_time(c_Elapse, charsmax(c_Elapse), "%Y.%m.%d - %H:%M:%S", BanList[BanTime] + (BanList[BanLenght]*60));
					easy_time_length(idx, BanList[BanLenght], timeunit_minutes, c_Length, charsmax(c_Length));
				}

				if(is_admin && is_aown)
				{
					sk_chat(idx, "%L", idx, "BANSYS_BAN_SUCCESS", BanList[BannedName]);
					sk_chat(idx, "%L", idx, "BANSYS_REASON_LENGTH_EXPIRE", BanList[BanReason], c_Length, c_Elapse);
					continue;
				}
				if(is_admin)
				{
					if(aid != 0 || webadmin == 1)
						sk_chat(idx, "%L", idx, "BANSYS_PLAYER_BANNED_SERVER", aid > 0 ? Admin_Permissions[get_user_adminlvl(aid)][0] : "WebAdmin", BanList[BannedBy], BanList[BannedName]);
					else
						sk_chat(idx, "%L", idx, "BANSYS_ANTICHEAT_BANNED_PLAYER_SERVER", BanList[BannedName]);
					
					sk_chat(idx, "%L", idx, "BANSYS_REASON_LENGTH_EXPIRE", BanList[BanReason], c_Length, c_Elapse);
					continue;
				}
				if(is_own)
				{
					if(oid == -1)
						continue;

					new map[32];
					get_mapname(map, sizeof (map));
					if(aid != 0 || webadmin == 1)
						sk_chat(idx, "%L", idx, "BANSYS_PLAYER_BANNED_YOU_SERVER", aid > 0 ? Admin_Permissions[get_user_adminlvl(aid)][0] : "WebAdmin", BanList[BannedBy], BanList[BanReason]);
					else
						sk_chat(idx, "%L", idx, "BANSYS_ANTICHEAT_BANNED_YOU_SERVER", BanList[BanReason]);

					sk_chat(idx, "%L", idx, "BANSYS_DETAILS", CurrTime, c_Length, c_Elapse, FB_LINK);
					sk_chat(idx, "Discord: %s", DC_LINK);
					sk_chat(idx, "%L", idx, "BANSYS_BAN_IMAGES_DEMO", map);
					continue;
				}
				else
				{
					if(aid != 0 || webadmin == 1)
						sk_chat(idx, "%L", idx, "BANSYS_PLAYER_BANNED_SERVER", aid > 0 ? Admin_Permissions[get_user_adminlvl(aid)][0] : "WebAdmin", BanList[BannedBy],  BanList[BannedName]);
					else
						sk_chat(idx, "%L", idx, "BANSYS_ANTICHEAT_BANNED_PLAYER_SERVER",  BanList[BannedName]);
				}
			}
			case 2:
			{
				new MuteList[gMuteList];
				static c_Length[64], c_Elapse[64], CurrTime[32];
				ArrayGetArray(g_MuteList, ArrId, MuteList);
				formatCurrentDateAndTime(CurrTime, charsmax(CurrTime));
				//calc_banelapse(MuteList[MuteLength], c_Length, c_Elapse)
				if(MuteList[MuteLength] == 0)
				{
					copy(c_Length, 64, fmt("%L", idx, "BANSYS_PERMANENT"));
					copy(c_Elapse, 64, fmt("%L", idx, "BANSYS_NEVER"));
				}
				else
				{
					format_time(c_Elapse, charsmax(c_Elapse), "%Y.%m.%d - %H:%M:%S", MuteList[MuteTime] + (MuteList[MuteLength]*60));
					easy_time_length(idx, MuteList[MuteLength], timeunit_minutes, c_Length, charsmax(c_Length));
				}

				if(is_admin && is_aown)
				{
					sk_chat(idx, "%L", idx, "BANSYS_MUTE_SUCCESS", MuteList[MutedName], MuteList[MuteType] == 3 ? fmt("%L", idx, "BANSYS_MUTE_TYPE_CHAT_VOICE") : (MuteList[MuteType] == 1 ? fmt("%L", idx, "BANSYS_MUTE_TYPE_CHAT") : fmt("%L", idx, "BANSYS_MUTE_TYPE_VOICE")));
					sk_chat(idx, "%L", idx, "BANSYS_REASON_LENGTH_EXPIRE", MuteList[MuteReason], c_Length, c_Elapse);
					continue;
				}
				if(is_admin || webadmin == 1)
				{
					sk_chat(idx, "%L", idx, "BANSYS_ADMIN_MUTED_PLAYER", aid > 0 ? Admin_Permissions[get_user_adminlvl(aid)][0] : "WebAdmin", MuteList[MutedBy], MuteList[MuteType] == 3 ? fmt("%L", idx, "BANSYS_MUTE_TYPE_CHAT_VOICE") : (MuteList[MuteType] == 1 ? fmt("%L", idx, "BANSYS_MUTE_TYPE_CHAT") : fmt("%L", idx, "BANSYS_MUTE_TYPE_VOICE")), MuteList[MutedName]);
					sk_chat(idx, "%L", idx, "BANSYS_REASON_LENGTH_EXPIRE", MuteList[MuteReason], c_Length, c_Elapse);
					continue;
				}
				if(is_own || webadmin == 1)
				{
					sk_chat(idx, "%L", idx, "BANSYS_YOU_MUTED_REASON", aid > 0 ? Admin_Permissions[get_user_adminlvl(aid)][0] : "WebAdmin", MuteList[MutedBy], MuteList[MuteType] == 3 ? fmt("%L", idx, "BANSYS_MUTE_TYPE_CHAT_VOICE") : (MuteList[MuteType] == 1 ? fmt("%L", idx, "BANSYS_MUTE_TYPE_CHAT") : fmt("%L", idx, "BANSYS_MUTE_TYPE_VOICE")), MuteList[BanReason]);
					sk_chat(idx, "%L", idx, "BANSYS_DETAILS", CurrTime, c_Length, c_Elapse, FB_LINK);
					sk_chat(idx, "Discord: %s", DC_LINK);
					continue;
				}
				else
				{
					sk_chat(idx, "%L", idx, "BANSYS_ADMIN_MUTED_PLAYER", aid > 0 ? Admin_Permissions[get_user_adminlvl(aid)][0] : "WebAdmin", MuteList[MutedBy], MuteList[MuteType] == 3 ? fmt("%L", idx, "BANSYS_MUTE_TYPE_CHAT_VOICE") : (MuteList[MuteType] == 1 ? fmt("%L", idx, "BANSYS_MUTE_TYPE_CHAT") : fmt("%L", idx, "BANSYS_MUTE_TYPE_VOICE")), MuteList[MutedName]);
				}
			}
			case 3:
			{
				new BanList[gBanList], c_Length[128], c_Elapse[64];
				ArrayGetArray(g_BanList, ArrId, BanList);

				if(BanList[BanLenght] == 0)
				{
					copy(c_Length, 64, fmt("%L", idx, "BANSYS_PERMANENT"));
					copy(c_Elapse, 64, fmt("%L", idx, "BANSYS_NEVER"));
				}
				else
				{
					format_time(c_Elapse, charsmax(c_Elapse), "%Y.%m.%d - %H:%M:%S", BanList[BanTime] + (BanList[BanLenght]*60));
					easy_time_length(idx, BanList[BanLenght], timeunit_minutes, c_Length, charsmax(c_Length));
				}

				if(is_admin && is_aown)
				{
					sk_chat(idx, "%L", idx, "BANSYS_BAN_MODIFY_SUCCESS", BanList[BanID], BanList[BannedName]);
					sk_chat(idx, "%L", idx, "BANSYS_REASON_LENGTH_EXPIRE", BanList[BanReason], c_Length, c_Elapse);
					continue;
				}
				if(is_admin)
				{
					sk_chat(idx, "%L", idx, "BANSYS_BAN_MODIFIED_BY_WEB", BanList[ModifiedBy], BanList[BannedName]);
					sk_chat(idx, "%L", idx, "BANSYS_REASON_LENGTH_EXPIRE", BanList[BanReason], c_Length, c_Elapse);
					continue;
				}
			}
			case 4:
			{
				new MuteList[gMuteList], c_Length[128], c_Elapse[64];
				ArrayGetArray(g_MuteList, ArrId, MuteList);

				if(MuteList[MuteLength] == 0)
				{
					copy(c_Length, 64, fmt("%L", idx, "BANSYS_PERMANENT"));
					copy(c_Elapse, 64, fmt("%L", idx, "BANSYS_NEVER"));
				}
				else
				{
					format_time(c_Elapse, charsmax(c_Elapse), "%Y.%m.%d - %H:%M:%S", MuteList[MuteTime] + (MuteList[MuteLength]*60));
					easy_time_length(idx, MuteList[MuteLength], timeunit_minutes, c_Length, charsmax(c_Length));
				}

				if(is_admin && is_aown)
				{
					sk_chat(idx, "%L", idx, "BANSYS_MUTE_MODIFY_SUCCESS", MuteList[MuteID], MuteList[MutedName]);
					sk_chat(idx, "%L", idx, "BANSYS_REASON_LENGTH_EXPIRE", MuteList[MuteReason], c_Length, c_Elapse);
					continue;
				}
				if(is_admin)
				{
					sk_chat(idx, "%L", idx, "BANSYS_MUTE_MODIFIED_BY_WEB", MuteList[mModifiedBy], MuteList[MutedName]);
					sk_chat(idx, "%L", idx, "BANSYS_REASON_LENGTH_EXPIRE", MuteList[MuteReason], c_Length, c_Elapse);
					continue;
				}
			}
		}
	}
}

public LoadWebadmin(callbackid, socket, wid, isNew, type)
{
	new szQuery[2048];
	new data[5];
	data[0] = wid;
	data[1] = isNew;
	data[2] = type;
	data[3] = callbackid;
	data[4] = socket;

	if(type == 1)
		formatex(szQuery, charsmax(szQuery), "SELECT * FROM `amx_bans` WHERE bid = ^"%i^";", wid); 
	else
		formatex(szQuery, charsmax(szQuery), "SELECT * FROM `amx_mutes` WHERE bid = ^"%i^";", wid); 

	SQL_ThreadQuery(m_get_sql(),"sql_loadwebadmin", szQuery, data, sizeof(data));
	callback_answer(callbackid, socket, an_success);
}

public sql_loadwebadmin(FailState,Handle:Query,Error[],Errcode,data[],DataSize)
{
	if(Errcode)
	{
		return log_amx("[ *HIBA*4 ] PROBLEMA  ( %s )", Error);
	}
	if(FailState == TQUERY_CONNECT_FAILED)
	{
		return set_fail_state("[ *HIBA* ] NEM LEHET KAPCSOLODNI AZ ADATBAZISHOZ!");
	}
	else if(FailState == TQUERY_QUERY_FAILED)
	{
		return set_fail_state("[ *HIBA* ] A LEKERDEZES MEGSZAKADT!");
	}

	new isnew = data[1];
	new type = data[2];
	if(SQL_NumRows(Query) > 0) 
	{
		if(type == 1)
		{
			if(isnew == 1)
			{
				static BanList[gBanList];
				BanList[BanID] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "bid"));
				BanList[BannedPlayerId] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "BannedPlayerId"));
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "player_id"), BanList[BannedSteamId], 32);
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "player_ip"), BanList[BannedIP], 32);
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "player_nick"), BanList[BannedName], 32);
				BanList[BanTime] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "ban_created"));
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "ban_reason"), BanList[BanReason], 256);

				BanList[BannedByPlayerId] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "BannedByPlayerId"));
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "admin_id"), BanList[BannedBySteamId], 32);
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "admin_ip"), BanList[BannedByIP], 32);
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "admin_nick"), BanList[BannedBy], 32);

				BanList[BanLenght] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "ban_length"));
				BanList[BanActive] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "expired"));
				BanList[BannedByAdminPerm] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "BannedByAdminPerm"));

				new arrid = ArrayPushArray(g_BanList, BanList);
				if(BanList[BanActive] == 0 && BanList[BanLenght] != 0)
				{
					Tasking("ban", arrid);
				} 

				loaded_bans++;

				new bannedid = cmd_target(bannedid, BanList[BannedSteamId], 2);
				new bannerid = cmd_target(bannerid, BanList[BannedBySteamId], 2);

				if(is_user_connected(bannedid))
				{
					ShowConsoleInfo(bannedid, 1, arrid);
					CallSnapshotting(bannedid);

					if(task_exists(TASK_OFFSET_FINALKICK+bannedid))
						remove_task(TASK_OFFSET_FINALKICK);
					set_task(1.0, "FinKick", bannedid + TASK_OFFSET_FINALKICK);
				}
				ActionChat(arrid, bannedid, bannerid, 1, 1);
			}
			else
			{
				new oldbantime;
				static BanList[gBanList];
				BanList[BanID] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "bid"));
				BanList[BannedPlayerId] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "BannedPlayerId"));
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "player_id"), BanList[BannedSteamId], 32);
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "player_ip"), BanList[BannedIP], 32);
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "player_nick"), BanList[BannedName], 32);
				BanList[BanTime] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "ban_created"));
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "ban_reason"), BanList[BanReason], 256);

				BanList[BannedByPlayerId] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "BannedByPlayerId"));
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "admin_id"), BanList[BannedBySteamId], 32);
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "admin_ip"), BanList[BannedByIP], 32);
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "admin_nick"), BanList[BannedBy], 32);

				BanList[is_modified] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "modified"));
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "modifiedby"), BanList[ModifiedBy], 32);
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "UName"), BanList[UnbannerName], 32);

				oldbantime = BanList[BanLenght];
				BanList[BanLenght] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "ban_length"));

				BanList[BanActive] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "expired"));
				BanList[BannedByAdminPerm] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "BannedByAdminPerm"));
				
				new arrid = check_userban(-1, BanList[BanID]);
				ArraySetArray(g_BanList, arrid, BanList);
				if(isnew == 2)
				{
					if(oldbantime != BanList[BanLenght])
					{
						if(BanList[BanActive] == 0 && BanList[BanLenght] != 0)
							Tasking("ban", arrid);

					}
					new id = cmd_target(id, BanList[BannedBySteamId], 2);
					ActionChat(arrid, -1, id, 3, 0);
				}
				else if(isnew == 3)
				{
					if(task_exists(arrid+TASK_OFFSET_BANELAPSE))
						remove_task(arrid+TASK_OFFSET_BANELAPSE);

					BanList[BanActive] = 2;

					ArraySetArray(g_BanList, arrid, BanList);
					sk_chat_lang("%L", "BANSYS_UNBAN_SUCCESS", BanList[UnbannerName], BanList[BannedName], BanList[BannedBy]);
				}
			}
		}
		else if(type == 2)
		{
			if(isnew == 1)
			{
				static MuteList[gMuteList];
				MuteList[MuteID] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "bid"));
				MuteList[MutedPlayerId] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "MutedPlayerId"));
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "player_id"), MuteList[MutedSteamId], 32);
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "player_ip"), MuteList[MutedIP], 32);
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "player_nick"), MuteList[MutedName], 32);
				MuteList[MuteTime] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "mute_created"));
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "mute_reason"), MuteList[MuteReason], 256);

				MuteList[MutedByPlayerId] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "MutedByPlayerId"));
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "admin_id"), MuteList[MutedBySteamId], 32);
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "admin_ip"), MuteList[MutedByIP], 32);
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "admin_nick"), MuteList[MutedBy], 32);

				MuteList[MuteType] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "mute_type"));
				MuteList[MuteLength] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "mute_length"));
				MuteList[MuteActive] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "expired"));
				MuteList[MutedByAdminPerm] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "MutedByAdminPerm"));

				new arrid = ArrayPushArray(g_MuteList, MuteList);
				if(MuteList[MuteActive] == 0 && MuteList[MuteLength] != 0)
					Tasking("mute", arrid);

				loaded_mutes++;

				new Mutedid = cmd_target(Mutedid, MuteList[MutedSteamId], 2);
				new bannerid = cmd_target(bannerid, MuteList[MutedBySteamId], 2);

				if(is_user_connected(Mutedid))
				{
				ShowConsoleInfo(Mutedid, 2, arrid);

				if(MuteList[MuteType] > 1)
					set_speak(Mutedid, SPEAK_MUTED);
				else
					set_speak(Mutedid, SPEAK_NORMAL);

				glob_Player[Mutedid][is_gaged] = arrid;
				}
				ActionChat(arrid, Mutedid, bannerid, 2, 1);
			}
			else
			{
				new oldbantime;
				static MuteList[gMuteList];
				MuteList[MuteID] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "bid"));
				MuteList[MutedPlayerId] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "MutedPlayerId"));
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "player_id"), MuteList[MutedSteamId], 32);
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "player_ip"), MuteList[MutedIP], 32);
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "player_nick"), MuteList[MutedName], 32);
				MuteList[MuteTime] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "mute_created"));
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "mute_reason"), MuteList[MuteReason], 256);

				MuteList[MutedByPlayerId] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "MutedByPlayerId"));
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "admin_id"), MuteList[MutedBySteamId], 32);
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "admin_ip"), MuteList[MutedByIP], 32);
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "admin_nick"), MuteList[MutedBy], 32);

				MuteList[MuteType] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "mute_type"));
				MuteList[is_modified] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "modified"));
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "modifiedby"), MuteList[mModifiedBy], 32);
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "UName"), MuteList[UnmuterName], 32);

				oldbantime = MuteList[MuteLength];
				MuteList[MuteLength] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "mute_length"));

				MuteList[MuteActive] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "expired"));
				MuteList[MutedByAdminPerm] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "MutedByAdminPerm"));
				
				new arrid = check_usermute(-1, MuteList[MuteID]);
				ArraySetArray(g_MuteList, arrid, MuteList);

				if(isnew == 2)
				{
				if(oldbantime != MuteList[MuteLength])
				{
					if(MuteList[MuteActive] == 0 && MuteList[MuteLength] != 0)
					{
					Tasking("mute", arrid);
					} 
				}
				new id = cmd_target(id, MuteList[MutedBySteamId], 2);
				ActionChat(arrid, -1, id, 4, 0);

				new mid = cmd_target(mid, MuteList[MutedSteamId], 2);
				if(is_user_connected(mid))
				{
					if(MuteList[MuteType] > 1)
					set_speak(mid, SPEAK_MUTED);
					else
					set_speak(mid, SPEAK_NORMAL);
				}
				}
				else if(isnew == 3)
				{
				if(task_exists(arrid+TASK_OFFSET_BANELAPSE))
					remove_task(arrid+TASK_OFFSET_BANELAPSE);

				MuteList[MuteActive] = 2;

				ArraySetArray(g_MuteList, arrid, MuteList);
				new mid = cmd_target(mid, MuteList[MutedSteamId], 2);
				if(is_user_connected(mid))
					CheckIsHaveAnotherGag(mid);
				sk_chat_lang("%L", "BANSYS_UNMUTE_SUCCESS", MuteList[UnmuterName], MuteList[MutedName], MuteList[MutedBy]);
				}
			}
		}
	}
	
	return PLUGIN_CONTINUE;
}

public WOB_kick(callbackid, socket, id, wob_validator, wob_note[])
{
	if(glob_Player[id][validator] != wob_validator)
	{
		callback_answer(callbackid, socket, an_success);
		return;
	}

	if(!is_user_connected(id) || is_user_bot(id))
	{
		callback_answer(callbackid, socket, an_success);
		return;
	}

	Action(id, "kick", fmt("[Blacklist] (%s)", wob_note), 0, 0, 0);
	SendToShedi(fmt("id: %i, name: %s | BLAKCLIST KICK | %s", id, glob_Player[id][PlayerName], wob_note));

	callback_answer(callbackid, socket, an_success);
}

public VPN_kick(callbackid, socket, id, wob_validator)
{
	if(glob_Player[id][validator] != wob_validator)
	{
		callback_answer(callbackid, socket, an_success);
		return;
	}

	if(!is_user_connected(id) || is_user_bot(id))
	{
		callback_answer(callbackid, socket, an_success);
		return;
	}

	Action(id, "kick", fmt("%L", id, "BANSYS_VPN_PROXY_RESTRICTION"), 0, 0, 0);
	
	SendToShedi(fmt("id: %i, name: %s | VPN/PROXY/DATACENTER KICK | ", id, glob_Player[id][PlayerName]));
	callback_answer(callbackid, socket, an_success);
}

public newuser_print(callbackid, socket, id, wob_validator)
{
	if(glob_Player[id][validator] != wob_validator)
	{
		callback_answer(callbackid, socket, an_success);
		return;
	}

	if(!is_user_connected(id) || is_user_bot(id))
	{
		callback_answer(callbackid, socket, an_success);
		return;
	}

	new players[32], pnum;
	get_players(players, pnum, "ch");
	for(new i; i<pnum; i++)
	{
		new idx = players[i];
		if(!(get_user_flags(idx) & ADMIN_BAN))
			continue;
		sk_chat(idx, "^4BanSysv2^1 új játékost érzékelt: ^4%s^1.", glob_Player[id][PlayerName]);
		client_cmd(idx, "spk fvox/warning.wav");
		client_cmd(idx, "spk fvox/bell.wav");
	}

	SendToShedi(fmt("id: %i, name: %s | newuser | ", id, glob_Player[id][PlayerName]));
	callback_answer(callbackid, socket, an_success);
}

public validationfailed(callbackid, socket, id, wob_validator, type)
{
	if(glob_Player[id][validator] != wob_validator)
	{
		callback_answer(callbackid, socket, an_success);
		return;
	}

	if(!is_user_connected(id) || is_user_bot(id))
	{
		callback_answer(callbackid, socket, an_success);
		return;
	}

	ClientValidationFailed(id, type);
	callback_answer(callbackid, socket, an_success);
}

public ClientValidationFailed(id, type)
{
	sql_addrow(-1, 1, id, 0, fmt("Kliens ellenőrzési hiba(%i)", type));
	server_cmd("kick #%d ^"%L^"", get_user_userid(id), id, "BANSYS_CLIENT_ERROR", type, CS_DOWNLOAD);
	sk_chat_lang("%L", "BANSYS_KICKED_FOR_FAILED_CHECK", glob_Player[id][PlayerName]);
	
	SendToShedi(fmt("id: %i, name: %s | VALIDATOR%i KICK | ", id, glob_Player[id][PlayerName], type));
}

public SetLangauge(callbackid, socket, id, wob_validator, lang[])
{
	if(glob_Player[id][validator] != wob_validator)
	{
		callback_answer(callbackid, socket, an_success);
		return;
	}

	if(!is_user_connected(id) || is_user_bot(id))
	{
		callback_answer(callbackid, socket, an_success);
		return;
	}

	set_user_lang(id, lang);

	callback_answer(callbackid, socket, an_success);
}

public version_kick(callbackid, socket, id, wob_validator)
{
	if(glob_Player[id][validator] != wob_validator)
	{
		callback_answer(callbackid, socket, an_success);
		return;
	}

	if(!is_user_connected(id) || is_user_bot(id))
	{
		callback_answer(callbackid, socket, an_success);
		return;
	}

	if(ncl_is_client_api_ready(id))
	{
		new eNclUsing:ncv = ncl_is_using_nextclient(id);
		if(ncv == NCL_USING_VERIFICATED)
		{
			callback_answer(callbackid, socket, an_success);
			return;
		}
	}
	
	Action(id, "kick", fmt("%L", id, "BANSYS_VERSION_RESTRICTION"), 0, 0, 0);
	
	SendToShedi(fmt("id: %i, name: %s | VERSION KICK | ", id, glob_Player[id][PlayerName]));
	callback_answer(callbackid, socket, an_success);
}

bool:RegexTester(id, m_string[], RegexText[], NoMatchText[])
{
	new ret, error[128];
	new Regex:regex_handle = regex_match(m_string, RegexText, ret, error, charsmax(error));

	switch(regex_handle)
	{
		case REGEX_MATCH_FAIL:
		{
			log_amx("---REGEX MATCH FAIL---");
			log_amx("ERROR:");
			log_amx(error);
			// There was an error matching against the pattern
			// Check the {error} variable for message, and {ret} for error code
		}
		case REGEX_PATTERN_FAIL:
		{
			log_amx("---REGEX TATTERN ERROR---");
			log_amx("ERROR:");
			log_amx(error);
			// There is an error in your pattern
			// Check the {error} variable for message, and {ret} for error code
		}
		case REGEX_NO_MATCH:
		{
			sk_chat(id, "^1%s^1", NoMatchText);
		}
		default:
		{
			// Matched m_string {ret} times
			regex_free(regex_handle);
			return true;
			// Free the Regex handle
		}
	}
	regex_free(regex_handle);
	return false;
}
public SendToAdmins(const sText[])
{
	new id, iMaxNum;
	iMaxNum = get_maxplayers();
	new sTime[64];
	formatCurrentDateAndTime(sTime, charsmax(sTime));
	for(id = 0 ; id <= iMaxNum ; id++) 
	{
		if(get_user_adminlvl(id) > 0)
		{
			client_cmd(id, "spk warning")
			client_print_color(id, print_team_default, "^4[SQL WARN] ^1~ ^3%s", sText)
		}
	}
	sk_log("SQL_Warnings", fmt("%s", sText))
}