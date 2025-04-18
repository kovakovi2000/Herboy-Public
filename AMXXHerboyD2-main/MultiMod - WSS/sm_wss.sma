#include <amxmodx>
#include <amxmisc>
#include <reapi>
#include <cstrike>
#include <engine>
#include <fun>
#include <hamsandwich>
#include <manager>
#include <fakemeta>
#include <csx>
#include <fakemeta_stocks>
#include <fakemeta_util>
#include <sqlx>
#include <sk_utils>
#include <bansys>
#include <regsystem>
#include <easytime2>

new iKills[33], iDeaths[33], iHS[33], iSkins[33], iPoints[33], iKredits[33], iSelectedPack[33], isScreenEffect[33], iHud[33], iRoundSound[33], isInkognitoed[33];
new sm_PlayerName[33][33], dSync, g_Mute[33][33];
new fwd_logined, g_korkezdes, iMaxrounds, iNextMapNum = 0;

new const MENUPREFIX[] = "\y[\r~|\wHerBoy\r|~\y] \rONLYDUST2\d ~";
//new const CHATPdddREFIX[] = "^4[^1~^3|^4He rBoy^3|^1~^4] ^3»^1";

#define MusicMax 56
enum _:WeaponLoad
{
	pa_id,
	PackName[33],
	NeedPoints,
	sModelName[33],
	isKredit
}
new const NextMaps[][] = 
{
	"-",
	"de_dust2",
	"de_dust2",
	"de_winterdust2",
	"de_dust2"
}
new const PackInfo[][WeaponLoad] = {
	{0, "Default", 0, "default", 0},
	{1, "Marihuana", 0, "marihuana", 0},
	{2, "Orange Frontside", 50, "orangefront", 0},
	{3, "Green Asiimov", 150, "greenasimov", 0},
	{4, "Gold", 300, "gold", 0},
	{5, "Razer", 600, "razer", 0},
	{6, "Taktik", 800, "taktik", 0},
	{7, "Nike", 3800, "nike", 0},
	{8, "Dark Snake", 7530, "darksnake", 0},
	{9, "Adidas", 13200, "adidas", 0},
	{10, "Grafity", 18321, "grafity", 0},
	{11, "Hyper Beast", 23450, "hyperbeast", 0},
	{12, "Lava", 33660, "lava", 0},
	{13, "Technologic", 47320, "technologic", 0},
	{14, "Wolf", 77400, "wolf", 0},
	{15, "Printstream", 150000, "printstream", 0},
	{16, "Blue Tron", 300, "bluetron", 1},
	{17, "Black Ice", 300, "blackice", 1},
}
public plugin_init()
{
	register_plugin("[sMod WSS] ~ SkinSystem", "v1.0", "shedi")
	iMaxrounds = register_cvar("maxkor", "60");
	
	register_clcmd("say dc", "dc");
	register_clcmd("say /dc", "dc");
	register_clcmd("say /mute", "openPlayerChooserMute");
	register_clcmd("say /admin", "clientGoToIncognito");

	register_clcmd("say", "Hook_Say");
	register_clcmd("say_team", "Hook_Say");

	register_event("CurWeapon", "ChangeWeapon", "be", "1=1");

	// RegisterHam(Ham_Item_Deploy, "weapon_ak47", "ChangeWeapon", 1);
	// RegisterHam(Ham_Item_Deploy, "weapon_m4a1", "ChangeWeapon", 1);
	// RegisterHam(Ham_Item_Deploy, "weapon_awp", "ChangeWeapon", 1);
	// RegisterHam(Ham_Item_Deploy, "weapon_deagle", "ChangeWeapon", 1);
	// RegisterHam(Ham_Item_Deploy, "weapon_knife", "ChangeWeapon", 1);
	// RegisterHam(Ham_Item_Deploy, "weapon_hegrenade", "ChangeWeapon", 1);
	// RegisterHam(Ham_Item_Deploy, "weapon_flashbang", "ChangeWeapon", 1);
	// RegisterHam(Ham_Item_Deploy, "weapon_c4", "ChangeWeapon", 1);

	register_impulse(201, "openMainMenu");
	register_event("HLTV", "ujkor", "a", "1=0", "2=0");
	register_event("DeathMsg","eDeathMsg","a")
	register_logevent("RoundEnds", 2, "1=Round_End")
	RegisterHookChain(RG_RoundEnd, "sv_roundend", false);
	register_forward(FM_Voice_SetClientListening, "OnPlayerTalk")
	fwd_logined = CreateMultiForward("LoggedSuccesfully", ET_IGNORE, FP_CELL);
	RegisterHam(Ham_Spawn,"player","Spawn",1);

	set_task(1.0, "SecCheck",_,_,_,"b");
	set_task(45.0, "Hirdetes",_,_,_,"b");
	dSync = CreateHudSyncObj();
	register_dictionary("modv5.txt");
	register_dictionary("wss.txt");
	register_dictionary("general.txt");
}
public Spawn(id) 
{
	if(!is_user_alive(id)) 
	{
		return PLUGIN_HANDLED;
	}
	SetModels(id);
	return PLUGIN_HANDLED;
} 	
public clientGoToIncognito(id)
{
	if(get_user_adminlvl(id) == 0)
	{
		sk_chat(id, "Ez a command csak ^3adminoknak^1 érhető el!")
		return PLUGIN_HANDLED;
	}

	if(isInkognitoed[id] > 0)
	{
		sk_chat(id, "Mostantól nem látja senki, hogy ^3admin^1 vagy!")
		isInkognitoed[id] = 0;
	}
	else if(isInkognitoed[id] < 1)
	{
		sk_chat(id, "Mostantól mindenki látja senki, hogy ^3admin^1 vagy!")
		isInkognitoed[id] = 1;
	}
	return PLUGIN_CONTINUE;
}
public SetModels(id)
{
	new random_t = random_num(1,4)
	{
		if(cs_get_user_team(id) == CS_TEAM_T)
		{
			switch(random_t)
			{
				case 1: cs_set_user_model(id, "hb_leet", true)
				case 2: cs_set_user_model(id, "hb_arctic", true)
				case 3: cs_set_user_model(id, "hb_guerilla", true)
				case 4: cs_set_user_model(id, "hb_terror", true)
			}
		}
		if(cs_get_user_team(id) == CS_TEAM_CT)
		{
			switch(random_t)
			{
				case 1: cs_set_user_model(id, "hb_gign", true)
				case 2: cs_set_user_model(id, "hb_gsg9", true)
				case 3: cs_set_user_model(id, "hb_sas", true)
				case 4: cs_set_user_model(id, "hb_urban", true)
			}
		}
	}
}
public dc() {
	sk_chat_lang("%L ^4discord.gg/herboyd2", "WSS_DISCORD_SERVER");
}
new hirdetesszam = -1;
public Hirdetes()	
{
	if(hirdetesszam == -1)
		hirdetesszam = random(20);
	hirdetesszam++;
	switch(hirdetesszam)
	{
		case 1: sk_chat_lang("%L", "MOD_ADVERT_RULES")
		case 2: sk_chat_lang("%L", "MOD_ADVERT_BANS_MUTES")
		case 3: sk_chat_lang("%L", "MOD_ADVERT_WEBSITE_TEAMSPEAK")
		case 4: sk_chat_lang("%L", "MOD_ADVERT_EXPLOIT_WARNING")
		case 5: sk_chat_lang("%L", "MOD_ADVERT_ADMIN_RECRUITMENT_OPEN")
		case 6: sk_chat_lang("%L", "MOD_ADVERT_TRANSLATION")
		case 7: sk_chat_lang("%L", "WSS_MUTE_PLAYER")
		case 8: sk_chat_lang("%L", "WSS_CUSTOM_CROSSHAIR")
		case 9: sk_chat_lang("%L ^4/mute^1, ^4/ch^1, ^4/crosshair^1, ^4/rs^1, ^4/top15^1, ^4/rank^1, ^4/dc^1, ^4/sounds", "WSS_AVAILABLE_COMMANDS")
		case 10: sk_chat_lang("%L ^4discord.gg/herboyd2", "WSS_DISCORD_LINK")
		case 11: sk_chat_lang("%L", "WSS_SUGGESTIONS_WELCOME")
		case 12: sk_chat_lang("%L", "WSS_FORGOT_PASSWORD", "www.herboyd2.hu/forgetpassword")
		case 13: sk_chat_lang("%L", "WSS_MAP_SUGGESTION")
		case 14: sk_chat_lang("%L", "WSS_HUD_TOGGLE")
		case 15: sk_chat_lang("%L", "WSS_BOMB_DEFUSE_POINTS")
		case 16: sk_chat_lang("%L", "WSS_BOMB_EXPLOSION_POINTS")
		case 17: sk_chat_lang("%L", "WSS_RULES_ARE_MANDATORY")
		case 18: sk_chat_lang("%L", "WSS_HEAD_ADMINS")
		case 19: sk_chat_lang("%L", "WSS_SWEARING_POLICY")
		case 20: sk_chat_lang("%L", "WSS_SERVER_IMPROVEMENTS")
	}
	if(hirdetesszam >= 20)
		hirdetesszam = 0;
}
public ujkor()
{
	new id;
	new sDateAndTime[40];

	new p_playernum = get_playersnum(1);
	format_time(sDateAndTime, charsmax(sDateAndTime), "%m.%d - %H:%M:%S", get_systime())
	
	g_korkezdes++;

	for(id = 0 ; id < 33 ; id++) 
	{
		if(is_user_connected(id))
		{
			if(sk_get_logged(id) && !is_user_bot(id))
				QueryUpdateUserDatas(id);
		} 
	}
	new nowmap[33]
	get_mapname(nowmap, charsmax(nowmap))

	sk_chat_lang("%L", "WSS_ROUND_INFO", g_korkezdes, get_pcvar_num(iMaxrounds), p_playernum, 32, sDateAndTime); 

	if(g_korkezdes == 2)
	{
		iNextMapNum = random_num(1, 4)
		if(equali(nowmap, NextMaps[iNextMapNum]))
			iNextMapNum = random_num(1, 4)

		sk_chat_lang("%L ^4%s", "WSS_NEXT_MAP_SELECTED", NextMaps[iNextMapNum]);
	}
	else if(g_korkezdes >= get_pcvar_num(iMaxrounds))
	{
		if(callfunc_begin("mensure_ending", "fpsmeter.amxx") == 1)
		{
			callfunc_end()
		}
		sk_chat_lang("%L ^4%s", "WSS_MAP_CHANGE_STARTED", NextMaps[iNextMapNum]);
		message_begin(MSG_ALL, SVC_INTERMISSION)
		message_end()
		set_task(4.0, "pkor");
	}
}
public pkor()
{
	engine_changelevel(fmt("%s", NextMaps[iNextMapNum]));
}
public OnPlayerTalk(iReceiver, iSender, iListen)
{
	if(iReceiver == iSender)
		return FMRES_IGNORED
		
	if(g_Mute[iReceiver][iSender])
	{
		engfunc(EngFunc_SetClientListening, iReceiver, iSender, 0)
		return FMRES_SUPERCEDE
	}
	
	return FMRES_IGNORED
}
public eDeathMsg()
{
	new Killer = read_data(1);
	new Victim = read_data(2);
	new Headshot = read_data(3);
	
	if(!is_user_connected(Killer) || !is_user_connected(Victim))
		return PLUGIN_HANDLED;

	if(Killer == Victim)
		return PLUGIN_HANDLED;

	iDeaths[Victim]++;
	iKills[Killer]++;

	if(Headshot)
	{
		iHS[Killer]++;
		iPoints[Killer] += random_num(1, 6)
		if(isScreenEffect[Killer])
		{
			message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("ScreenFade"), {0,0,0}, Killer);
			write_short(12000);
			write_short(0);
			write_short(0);
			write_byte(0);
			write_byte(0);
			write_byte(200);
			write_byte(120);
			message_end(); 
		}
	}
	else
		iPoints[Killer] += random_num(1, 3)

	return PLUGIN_CONTINUE;
}
// public ChangeWeapon(iEnt)
// {
// 	new id = get_pdata_cbase(iEnt, 41, 4);
// 	if(id > 32 || id < 1)
// 		return HAM_IGNORED;

// 	if(!pev_valid(id) || !is_user_alive(id)) 
// 		return HAM_IGNORED;

// 	new sLocation[100], wid = cs_get_weapon_id(iEnt);
//   if(!iSkins[id])
//     return HAM_IGNORED;

// 	switch(wid)
// 	{
//     case CSW_AK47: formatex(sLocation, charsmax(sLocation), "models/sm_wss_v1/v_ak47_%s.mdl", PackInfo[iSelectedPack[id]][sModelName]);
//     case CSW_M4A1: formatex(sLocation, charsmax(sLocation), "models/sm_wss_v1/v_m4a1_%s.mdl", PackInfo[iSelectedPack[id]][sModelName]);
//     case CSW_AWP: formatex(sLocation, charsmax(sLocation), "models/sm_wss_v1/v_awp_%s.mdl", PackInfo[iSelectedPack[id]][sModelName]);
//     case CSW_DEAGLE: formatex(sLocation, charsmax(sLocation), "models/sm_wss_v1/v_deagle_%s.mdl", PackInfo[iSelectedPack[id]][sModelName]);
//     case CSW_KNIFE: formatex(sLocation, charsmax(sLocation), "models/sm_wss_v1/v_knife_%s.mdl", PackInfo[iSelectedPack[id]][sModelName]);

// 		case CSW_HEGRENADE: formatex(sLocation, charsmax(sLocation), "models/hb_multimod_v5/event/v_hegrenade.mdl");
// 		case CSW_FLASHBANG: formatex(sLocation, charsmax(sLocation), "models/hb_multimod_v5/event/v_flashbang.mdl");
// 		case CSW_C4: formatex(sLocation, charsmax(sLocation), "models/sm_wss_v1/v_c4.mdl");
// 	}
// 	entity_set_string(id, EV_SZ_viewmodel, sLocation);

// 	return HAM_IGNORED;
// }

public ChangeWeapon(id)
{
	if(id > 32 || id < 1)
		return PLUGIN_HANDLED;

	if(!is_user_alive(id)) 
		return PLUGIN_HANDLED;

	new sLocation[100], hasnoskin = 0, wid = get_user_weapon(id);
	if(!iSkins[id])
		return PLUGIN_HANDLED;

	switch(wid)
	{
		case CSW_AK47: formatex(sLocation, charsmax(sLocation), "models/sm_wss_v1/v_ak47_%s.mdl", PackInfo[iSelectedPack[id]][sModelName]);
		case CSW_M4A1: formatex(sLocation, charsmax(sLocation), "models/sm_wss_v1/v_m4a1_%s.mdl", PackInfo[iSelectedPack[id]][sModelName]);
		case CSW_AWP: formatex(sLocation, charsmax(sLocation), "models/sm_wss_v1/v_awp_%s.mdl", PackInfo[iSelectedPack[id]][sModelName]);
		case CSW_DEAGLE: formatex(sLocation, charsmax(sLocation), "models/sm_wss_v1/v_deagle_%s.mdl", PackInfo[iSelectedPack[id]][sModelName]);
		case CSW_KNIFE: formatex(sLocation, charsmax(sLocation), "models/sm_wss_v1/v_knife_%s.mdl", PackInfo[iSelectedPack[id]][sModelName]);

		case CSW_HEGRENADE: formatex(sLocation, charsmax(sLocation), "models/hb_multimod_v5/event/v_hegrenade.mdl");
		case CSW_FLASHBANG: formatex(sLocation, charsmax(sLocation), "models/hb_multimod_v5/event/v_flashbang.mdl");
		case CSW_C4: 
		{
			set_pev(id, pev_weaponmodel2, "models/sm_wss_v1/p_c4.mdl")
			formatex(sLocation, charsmax(sLocation), "models/sm_wss_v1/v_c4.mdl");
		}
		default: hasnoskin = 1;
	}
	if(!hasnoskin)
		set_pev(id, pev_viewmodel2, sLocation);

	return PLUGIN_HANDLED;
}
public plugin_precache()
{
	new iMaxPackNum = sizeof(PackInfo);
	for(new i = 0; i < iMaxPackNum;i++)
	{
		precache_model(fmt("models/sm_wss_v1/v_ak47_%s.mdl", PackInfo[i][sModelName]));
		precache_model(fmt("models/sm_wss_v1/v_m4a1_%s.mdl", PackInfo[i][sModelName]));
		precache_model(fmt("models/sm_wss_v1/v_awp_%s.mdl", PackInfo[i][sModelName]));
		precache_model(fmt("models/sm_wss_v1/v_deagle_%s.mdl", PackInfo[i][sModelName]));
		precache_model(fmt("models/sm_wss_v1/v_knife_%s.mdl", PackInfo[i][sModelName]));
	}

	for(new i = 1; i < MusicMax;i++)
		precache_sound(fmt("sm_music/%i.mp3", i));

	precache_model("models/hb_multimod_v5/event/v_hegrenade.mdl");
	precache_model("models/hb_multimod_v5/event/v_flashbang.mdl");
	precache_model("models/sm_wss_v1/p_c4.mdl");
	precache_model("models/sm_wss_v1/v_c4.mdl");

	precache_model("models/player/hb_arctic/hb_arctic.mdl");
	precache_model("models/player/hb_arctic/hb_arcticT.mdl");

	precache_model("models/player/hb_gign/hb_gign.mdl");
	precache_model("models/player/hb_gign/hb_gignT.mdl");

	precache_model("models/player/hb_gsg9/hb_gsg9.mdl");
	precache_model("models/player/hb_gsg9/hb_gsg9T.mdl");

	precache_model("models/player/hb_guerilla/hb_guerilla.mdl");
	precache_model("models/player/hb_guerilla/hb_guerillaT.mdl");

	precache_model("models/player/hb_leet/hb_leet.mdl");
	precache_model("models/player/hb_leet/hb_leetT.mdl");

	precache_model("models/player/hb_sas/hb_sas.mdl");
	precache_model("models/player/hb_sas/hb_sasT.mdl");

	precache_model("models/player/hb_terror/hb_terror.mdl");
	precache_model("models/player/hb_terror/hb_terrorT.mdl");

	precache_model("models/player/hb_urban/hb_urban.mdl");
	precache_model("models/player/hb_urban/hb_urbanT.mdl");
}
public SecCheck()
{
	new p[32],n;
	get_players(p,n,"ch");

	for(new i=0;i<n;i++)
	{
	new id = p[i];
	if(iHud[id])
	HudX(id);
	}
}
public HudX(id)
{ 
	new m_Index, iLen;
	new HudString[512]
	new MinuteString[20]

	if(is_user_alive(id))
	{
		m_Index = id;
		iLen += formatex(HudString[iLen], 512,"%L %s(#%i)!^n^n", id, "WSS_HUD_WELCOME", sm_PlayerName[id], sk_get_accountid(id));
	}
	else
	{
		m_Index = entity_get_int(id, EV_INT_iuser2);
		iLen += formatex(HudString[iLen], 512,"%L %s(#%i)^n^n", id, "WSS_HUD_PLAYER_VIEW", sm_PlayerName[m_Index], sk_get_accountid(m_Index));
	}
	short_time_length(id, sk_get_playtime(m_Index), timeunit_seconds, MinuteString, charsmax(MinuteString));
	iLen += formatex(HudString[iLen], 512,"[ %L ]^n", id, "WSS_HUD_POINTS_CREDITS", iPoints[m_Index], iKredits[m_Index]);
	iLen += formatex(HudString[iLen], 512,"[ %L ]^n", id, "WSS_HUD_KILLS_STATS", iKills[m_Index], iHS[m_Index], iDeaths[m_Index]);  
	iLen += formatex(HudString[iLen], 512,"[ %L %s ]^n^n", id, "WSS_HUD_PLAY_TIME", MinuteString);

	if(iSkins[m_Index])
		iLen += formatex(HudString[iLen], 512,"[ %L %s ]^n", id, "WSS_HUD_PACKAGE", PackInfo[iSelectedPack[m_Index]][PackName]);  

	set_hudmessage(random(255), random(255), random(255), 0.01, 0.15, 0, 6.0, 1.1, 0.0, 0.0, next_hudchannel(id));
	ShowSyncHudMsg(id, dSync, HudString);
}
public openMainMenu(id)
{
	if(!sk_get_logged(id))
		return PLUGIN_HANDLED;

	new menu = menu_create(fmt("%s \y%L", MENUPREFIX, id, "WSS_MAINMENU_MAIN"), "openMainMenu_h");

	menu_additem(menu, fmt("%L", id, "WSS_MAINMENU_WEAPON_PACKS"), "1")
	menu_additem(menu, fmt("%L", id, "WSS_MAINMENU_SETTINGS"), "2")
	menu_additem(menu, fmt("%L", id, "WSS_MAINMENU_PRIVATE_MESSAGE"), "3")
	menu_additem(menu, fmt("%L", id, "WSS_MAINMENU_REPORT_PLAYER"), "4")
	menu_additem(menu, fmt("%L", id, "WSS_MAINMENU_MUTE_PLAYER"), "5")
	menu_addblank2(menu)
	menu_addtext2(menu, fmt("\wwww.herboyd2.hu @ 2018-2024"))

	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	menu_display(id, menu);
	return PLUGIN_CONTINUE;
}
public openMainMenu_h(id, menu, item){
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
	case 1: openPackList(id)
	case 2: openSettings(id)
	case 3: client_cmd(id, "say /pm")
	case 4: client_cmd(id, "new_jelent")
	case 5: openPlayerChooserMute(id)
	}
}
public openPackList(id)
{
new iMaxPackNum = sizeof(PackInfo);
new szMenu[121], sInfo[8]

new menu = menu_create(fmt("%s \y%L", MENUPREFIX, id, "WSS_WEAPONPACKSMENU_MY_PACKAGES"), "openPacks_h");

for(new i = 0; i < iMaxPackNum;i++)
	{
	num_to_str(i, sInfo, 5);

	new iDisableMenu = 0;
	
	if(!PackInfo[i][isKredit])
	{
	if(iSelectedPack[id] == PackInfo[i][pa_id])
		formatex(szMenu, charsmax(szMenu), "\w%s %L", PackInfo[i][PackName], id, "WSS_WEAPONPACKSMENU_EQUIPPED")
	else if(iPoints[id] >= PackInfo[i][NeedPoints])
		formatex(szMenu, charsmax(szMenu), "\w%s %L", PackInfo[i][PackName], id, "WSS_WEAPONPACKSMENU_ACQUIRED")
	else
		{
		formatex(szMenu, charsmax(szMenu), "\d%s %L", PackInfo[i][PackName], id, "WSS_WEAPONPACKSMENU_POINTS_REQUIRED", PackInfo[i][NeedPoints]-iPoints[id])
		iDisableMenu = 1;
	}
	}
	else
	{
	if(iSelectedPack[id] == PackInfo[i][pa_id])
		formatex(szMenu, charsmax(szMenu), "\w%s %L", PackInfo[i][PackName], id, "WSS_WEAPONPACKSMENU_EQUIPPED")
	else if(iKredits[id] >= PackInfo[i][NeedPoints])
		formatex(szMenu, charsmax(szMenu), "\w%s %L", PackInfo[i][PackName], id, "WSS_WEAPONPACKSMENU_ACQUIRED")
	else
	{
		formatex(szMenu, charsmax(szMenu), "\d%s %L", PackInfo[i][PackName], id, "WSS_WEAPONPACKSMENU_CREDITS_REQUIRED", PackInfo[i][NeedPoints]-iKredits[id])
		iDisableMenu = 1;
	}
	}
	
	if(iDisableMenu)
	menu_additem(menu, szMenu, sInfo, ADMIN_ADMIN)
	else
	menu_additem(menu, szMenu, sInfo)
	}

menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
menu_display(id, menu);
}
public openPacks_h(id, menu, item){
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return;
	}

	new data[9], szName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
	new key = str_to_num(data);

	iSelectedPack[id] = key;
	sk_chat(id, "%L", id, "WSS_WEAPONPACKSMENU_SUCCESS", PackInfo[key][PackName]);
}
public openSettings(id)
{
	new regdate[33], fPlayTime[66];

	new menu = menu_create(fmt("%s \y%L", MENUPREFIX, id, "WSS_SETTINGSMENU_SETTINGS"), "openSettings_h");
	sk_get_RegisterDate(id, regdate, 32);
	easy_time_length(id, sk_get_playtime(id), timeunit_seconds, fPlayTime, charsmax(fPlayTime));

	new currlang[3];
	get_user_info(id, "lang", currlang, charsmax(currlang));
	strtoupper(currlang);
	menu_additem(menu, fmt("%L [\r%s\w]", id, "MOD_MENU_PROFILE_INFO_SETTINGS_LANGUAGE", currlang), "5");

	menu_addtext2(menu, fmt("%L^n", id, "WSS_SETTINGSMENU_PLAYER_INFO", sm_PlayerName[id], sk_get_accountid(id), regdate, fPlayTime))

	menu_additem(menu, fmt("\w%L %L", id, "WSS_SETTINGSMENU_SKINS", id, (iSkins[id] == 1 ? "WSS_SETTINGSMENU_ENABLED" : "WSS_SETTINGSMENU_DISABLED")), "1")
	menu_additem(menu, fmt("\w%L %L", id, "WSS_SETTINGSMENU_KILL_EFFECT", id, (isScreenEffect[id] == 1 ? "WSS_SETTINGSMENU_ENABLED" : "WSS_SETTINGSMENU_DISABLED")), "2")
	menu_additem(menu, fmt("\w%L %L", id, "WSS_SETTINGSMENU_HUD", id, (iHud[id] == 1 ? "WSS_SETTINGSMENU_ENABLED" : "WSS_SETTINGSMENU_DISABLED")), "3")
	menu_additem(menu, fmt("\w%L %L", id, "WSS_SETTINGSMENU_ENDROUND_MUSIC", id, (iRoundSound[id] == 1 ? "WSS_SETTINGSMENU_ENABLED" : "WSS_SETTINGSMENU_DISABLED")), "4")
	menu_addtext2(menu, fmt("^n\wwww.herboyd2.hu @ 2018-2024"))

	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	menu_display(id, menu);
}
public openSettings_h(id, menu, item){
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
		case 1: iSkins[id] = !iSkins[id];
		case 2: isScreenEffect[id] = !isScreenEffect[id];
		case 3: iHud[id] = !iHud[id];
		case 4: iRoundSound[id] = !iRoundSound[id];
		case 5: user_next_lang(id);
	}
	openSettings(id)
}
public client_putinserver(id)
{
	get_user_name(id, sm_PlayerName[id], charsmax(sm_PlayerName));

	iKills[id] = 0;
	iDeaths[id] = 0;
	iHS[id] = 0;
	iSkins[id] = 1;
	iPoints[id] = 0;
	iKredits[id] = 0;
	iSelectedPack[id] = 0;
	isScreenEffect[id] = 1;
	iHud[id] = 1;
	iRoundSound[id] = 1;
	isInkognitoed[id] = 1;
	
	for(new i = 0; i < 33; ++i)
		g_Mute[id][i] = 0
}
public client_disconnected(id)
{
	if(sk_get_logged(id) && !is_user_bot(id))
		QueryUpdateUserDatas(id)
}
public Hook_Say(id){
	new Message[512], Status[32], String[256];

	new cmd[21], bool:is_team = false;
	read_argv(0,cmd,20);
	if(equal(cmd,"say_team"))
		is_team = true;

	read_args(Message, charsmax(Message));
	remove_quotes(Message);
	
	if(Message[0] == '@' || Message[0] == ' ' || equal (Message, "") || Message[0] == '/')
		return PLUGIN_HANDLED;

	new len, adminlen;

	if(CsTeams:cs_get_user_team(id) == CS_TEAM_SPECTATOR && is_team == false)
		formatex(Status[0], charsmax(Status), "*%L* ", id, "WSS_CHATPREFIX_SPEC");
	else if(!is_user_alive(id))
		formatex(Status[0], charsmax(Status), "*%L* ", id, "WSS_CHATPREFIX_DEAD");

	if(is_team)
	{
		switch(get_user_team(id))
		{
			case CS_TEAM_CT: len += formatex(String[len], charsmax(String)-len, "^1%s (^3%L^1)", Status, id, "WSS_CHATPREFIX_ANTI_TERRORIST");
			case CS_TEAM_T: len += formatex(String[len], charsmax(String)-len, "^1%s (^3%L^1)", Status, id, "WSS_CHATPREFIX_TERRORIST");
			case CS_TEAM_SPECTATOR: len += formatex(String[len], charsmax(String)-len, "^1%s (^3%L^1)", Status, id, "WSS_CHATPREFIX_SPECTATOR");
		}
	}
	else
		len += formatex(String[len], charsmax(String)-len, "^1%s", Status);

	new AdminString[128]
	if(sk_get_logged(id))
	{
		if(get_user_adminlvl(id) > 0 && isInkognitoed[id] == 1)
			adminlen += formatex(AdminString[adminlen], charsmax(AdminString)-adminlen, "^4%s", Admin_Permissions[get_user_adminlvl(id)][0]);		
		else
			adminlen += formatex(AdminString[adminlen], charsmax(AdminString)-adminlen, "^4%s", Admin_Permissions[0][0]);
	}
	else
		adminlen += formatex(AdminString[adminlen], charsmax(AdminString)-adminlen, "^4%L", id, "WSS_CHATPREFIX_LOGGED_OUT");

	len += formatex(String[len], charsmax(String)-len, "^3[^4%s^3] ^1» ", AdminString);
	if(get_user_adminlvl(id) > 0 && isInkognitoed[id] == 1)
		len += formatex(String[len], charsmax(String)-len, "^3%s:^4", sm_PlayerName[id]);
	else
		len += formatex(String[len], charsmax(String)-len, "^3%s:^1", sm_PlayerName[id]);

	format(Message, charsmax(Message), "%s %s", String, Message);
	if(!sk_get_logged(id))
	{
		client_print_color(id, print_team_default, Message)
		for(new i; i < 33; i++)
		{
			if(!is_user_connected(i) || get_user_adminlvl(i) == 0)
				continue;

			if(cs_get_user_team(id) == CS_TEAM_CT)
				client_print_color(i, id, Message);
			else if(cs_get_user_team(id) == CS_TEAM_T)
				client_print_color(i, id, Message);
			else
				client_print_color(i, id, Message);
		}
		return PLUGIN_HANDLED;
	}

	for(new i; i < 33; i++)
	{
		if(!is_user_connected(i))
			continue;
		if(is_team && cs_get_user_team(id) != cs_get_user_team(i))
			continue;
		
		if(cs_get_user_team(id) == CS_TEAM_CT)
			client_print_color(i, id, Message);
		else if(cs_get_user_team(id) == CS_TEAM_T)
			client_print_color(i, id, Message);
		else
			client_print_color(i, id, Message);
	}
	
	return PLUGIN_HANDLED;
}
public openPlayerChooserMute(id) {
	new players[32], pnum, iName[32], szTempid[10]
	get_players(players, pnum, "ch")

	new menu = menu_create(fmt("%s \y%L", MENUPREFIX, id, "WSS_MUTEMENU_TITLE"), "hPlayerChooserMute");

	for(new i; i<pnum; i++)
	{
		get_user_name(players[i], iName, charsmax(iName))
		num_to_str(players[i], szTempid, charsmax(szTempid))
		menu_additem(menu, iName, szTempid)
	}
	menu_display(id, menu, 0)
}
public hPlayerChooserMute(id, menu, item)
{
	new data[6], szName[64], access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
	new key = str_to_num(data);

	g_Mute[id][key] = !g_Mute[id][key];
	if(key == 0)
		return;

	if(g_Mute[id][key])
		sk_chat(id, "%L", id, "WSS_MUTEMENU_MUTE", sm_PlayerName[key]);
	else
		sk_chat(id, "%L", id, "WSS_MUTEMENU_UNMUTE", sm_PlayerName[key]);
}
public Load_User_Data(id)
{
	new Query[2048]
	new Data[2];

	Data[0] = id;
	Data[1] = get_user_userid(id)

	formatex(Query, charsmax(Query), "SELECT * FROM `smod_wss` WHERE aid = ^"%d^";", sk_get_accountid(id))
	SQL_ThreadQuery(m_get_sql(), "QueryLoadAccountDatas", Query, Data, 2);
}
public QueryLoadAccountDatas(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime){
	new id = Data[0];
	if(Data[1] != get_user_userid(id))
		return;
		
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) {
		log_amx("%s", Error);
		return;
	}

	if(SQL_NumRows(Query) > 0)
	{
		iKills[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "iKills"));
		iHud[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "iHud"));
		iDeaths[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "iDeaths"));
		iHS[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "iHS"));
		iSkins[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "iSkins"));
		iPoints[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "iPoints"));
		iKredits[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "iKredits"));
		iSelectedPack[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "iSelectedPack"));
		isScreenEffect[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "isScreenEffect"));
		iRoundSound[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "iRoundSound"));
		isInkognitoed[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "isInkognitoed"));

		new fwd_loginedreturn;
		ExecuteForward(fwd_logined,fwd_loginedreturn, id);
	}
	else
		createAccountDatas(id)
}
public createAccountDatas(id)
{
	new Query[2048]
	new Data[2];

	Data[0] = id;
	Data[1] = get_user_userid(id)

	formatex(Query, charsmax(Query), "INSERT INTO `smod_wss` (`aid`) VALUES (%d);", sk_get_accountid(id));

	SQL_ThreadQuery(m_get_sql(), "QuerySetData_createAccountDatas", Query, Data, 2);
	return PLUGIN_HANDLED;
}
public QuerySetData_createAccountDatas(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime){
	new id = Data[0];
	if(Data[1] != get_user_userid(id))
		return;
		
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) {
		log_amx("FAIL INSERT STATE ON%s", Error);
		return;
	}

	Load_User_Data(id)
}
public QueryUpdateUserDatas(id){

	new sTime[64];
	formatCurrentDateAndTime(sTime, charsmax(sTime));

	static Query[10048];
	new Len;

	new Data[2];

	Data[0] = id;
	Data[1] = get_user_userid(id)

	Len += formatex(Query[Len], charsmax(Query), "UPDATE `smod_wss` SET ");
	Len += formatex(Query[Len], charsmax(Query)-Len, "iKills = ^"%i^", ", iKills[id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "iHud = ^"%i^", ", iHud[id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "iDeaths = ^"%i^", ", iDeaths[id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "iHS = ^"%i^", ", iHS[id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "iSkins = ^"%i^", ", iSkins[id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "iPoints = ^"%i^", ", iPoints[id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "iKredits = ^"%i^", ", iKredits[id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "iSelectedPack = ^"%i^", ", iSelectedPack[id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "iRoundSound = ^"%i^", ", iRoundSound[id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "isInkognitoed = ^"%i^", ", isInkognitoed[id]);

	Len += formatex(Query[Len], charsmax(Query)-Len, "isScreenEffect = ^"%i^" WHERE `aid` =  ^"%d^";", isScreenEffect[id], sk_get_accountid(id));

	SQL_ThreadQuery(m_get_sql(), "QuerySetData_UpdateAccountDatas", Query, Data, 2);
}
public QuerySetData_UpdateAccountDatas(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime){
	new id = Data[0];
	if(Data[1] != get_user_userid(id))
		return;
		
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) {
		log_amx("FAIL UPDAZTE STATE ON: %s", Error);
		return;
	}
}
public RoundEnds()
{
	new random_music = random_num(1, 55)
	for(new id = 0 ; id < 33 ; id++) 
	{
		if(iRoundSound[id] == 1)
			client_cmd(id, "mp3 play sound/sm_music/%i.mp3", random_music)
	}
}
public sv_roundend()
{
	if(g_korkezdes == 30)
		for(new id = 0; id < 33; id++) 
		{
			if(!is_user_connected(id))
				continue;
			
			switch(cs_get_user_team(id))
			{
				case CS_TEAM_CT: cs_set_user_team(id, CS_TEAM_T);
				case CS_TEAM_T: cs_set_user_team(id, CS_TEAM_CT);
			}
		}
}

public bomb_planted(id)
{
	new p_playernum = get_playersnum(1);
	if(p_playernum < 9)
		return;

	iPoints[id] += 6;
	sk_chat(id, "%L", id, "WSS_PLANTCHAT_PLANT", 6);
}
public bomb_defused(id)
{
	new p_playernum = get_playersnum(1);
	if(p_playernum < 9)
		return;

	sk_chat_lang("%L", "WSS_PLANTCHAT_DEFUSE_TEAM", 4);
	for(new iClient = 0 ; iClient < 33 ; iClient++) 
	{
		if(is_user_connected(iClient) && cs_get_user_team(iClient) == CS_TEAM_CT)
		{
			iPoints[iClient] += 4;
		}
	}
	iPoints[id] += 6;
	sk_chat(id, "%L", id, "WSS_PLANTCHAT_DEFUSE", 6);
}
public bomb_explode()
{
	new p_playernum = get_playersnum(1);
	if(p_playernum < 9)
		return;

	sk_chat_lang("%L", "WSS_PLANTCHAT_EXPLOSION_TEAM", 4);
	for(new iClient = 0 ; iClient < 33 ; iClient++) 
	{
		if(is_user_connected(iClient) && cs_get_user_team(iClient) == CS_TEAM_T)
		{
			iPoints[iClient] += 4;
		}
	}
}