#include <amxmodx>
#include <hamsandwich> 
#include <reapi>
#include <fun>
#include <sk_utils>

#pragma compress 1

#define VERSION "1.2"

new bool:HBKActive[33]=false;
new bool:g_hbkStarted = false;
new HbkChoice;
new NoScope=false;
new gmsgSetFOV;
new g_korkezdes;

#define REMOVE_WEAPONS
new g_iMaxPlayers 
#define IsPlayer(%1)    ( 1 <= %1 <= g_iMaxPlayers ) 

enum _:g_eWeaponData 
{ 
	_NameForChat[32], 
	_WeaponName[32], 
	_Ammo, 
	WeaponIdType:_CSW 
} 
enum _:g_eWeaponTypes 
{ 
	S 
} 
new const g_szSecondary[][g_eWeaponData]= 
{ 
	{"Glock18",     "weapon_glock18",     240,     WEAPON_GLOCK18}, 
	{"Usp",     "weapon_usp",        240,     WEAPON_USP}, 
	{"P228",     "weapon_p228",        240,     WEAPON_P228}, 
	{"Dual Elites", "weapon_elite",     240,     WEAPON_ELITE}, 
	{"Fiveseven",     "weapon_fiveseven",    240,     WEAPON_FIVESEVEN}, 
	{"Deagle",     "weapon_deagle",     240,     WEAPON_DEAGLE} 
} 
new g_WpnID[g_eWeaponTypes]

public plugin_precache() 
{ 
	precache_sound("hbk/hbk.wav") 
	precache_sound("hbk/hbk_end.wav")
} 	
public ujkor()
{
	g_korkezdes += 1;
}
public plugin_init() 
{ 
	register_plugin("HerBoy Kor", VERSION, "Eimador")

	register_clcmd("say /hbk", "HBKMenu", ADMIN_BAN);
	register_clcmd("hbk", "HBKMenu", ADMIN_BAN);

	register_clcmd("drop", "PlayerDropCheck");
	register_event("SetFOV","zoom","b","1<90") //NoZoom 
	RegisterHam(Ham_Spawn, "player", "SpawnPlayer", 1)
	register_event("HLTV", "ujkor", "a", "1=0", "2=0");
	register_logevent("HBKEndNow", 2, "1=Round_Start")
	register_logevent("HBKEndNow", 2,"1=Round_End") 
	RegisterHookChain(RG_CBasePlayer_HasRestrictItem, "Fw_HasRestrictItem_Pre", 0)

	g_iMaxPlayers = get_maxplayers()
	gmsgSetFOV = get_user_msgid( "SetFOV" );

	register_dictionary("hb_rounds.txt");
}

public client_putinserver(id)
{
	if(g_hbkStarted){
		HBKActive[id] = true;
	}
}

public SpawnPlayer(id)
{
	if(g_hbkStarted && HBKActive[id]){
		GivePlayerItem(id);
	}
}

public HBKMenu(id)
{
	if(!(get_user_flags(id) & ADMIN_BAN))
		return PLUGIN_HANDLED;

	if(g_hbkStarted){
		sk_chat(id, "A ^3HerBoy kör jelenleg ^4fut!");
		return PLUGIN_HANDLED;
	}

	if(!is_user_alive(id)){
		sk_chat(id, "^3Életben kell lenned, hogy használhasd a parancsot!");
		return PLUGIN_HANDLED;
	}
	
	new szMenu[128];
	formatex(szMenu, charsmax(szMenu), "\r[\wHerBoy\r] \yOnly Dust 2 \r» \r[ \wFegyver kör \r] v%s^n", VERSION);

	new menu = menu_create(szMenu, "HBKHandle")

	menu_additem(menu, "\y|\d-\r-\y[ \wKés kör\y ]\r-\d-\y|")  //0
	menu_additem(menu, "\y|\d-\r-\y[ \wGránát + Kés kör\y ]\r-\d-\y|")  //1
	menu_additem(menu, "\y|\d-\r-\y[ \wShotgun kör\y ]\r-\d-\y|")  //2
	menu_additem(menu, "\y|\d-\r-\y[ \wDeagle kör\y ]\r-\d-\y|")  //3
	menu_additem(menu, "\y|\d-\r-\y[ \wAWP kör\y ]\r-\d-\y|")  //4
	menu_additem(menu, "\y|\d-\r-\y[ \wRandom pisztoly kör\y ]\r-\d-\y|")  //5
	menu_additem(menu, "\y|\d-\r-\y[ \wBeretta kör\y ]\r-\d-\y|")  //6
	menu_additem(menu, "\y|\d-\r-\y[ \wUSP & Glock kör\y ]\r-\d-\y|")  //7
	menu_additem(menu, "\y|\d-\r-\y[ \wTMP kör\y ]\r-\d-\y|")  //8
	menu_additem(menu, "\y|\d-\r-\y[ \wVégtelen gránát kör\y ]\r-\d-\y|") //9 
	menu_additem(menu, "\y|\d-\r-\y[ \wScout kör\y ]\r-\d-\y|")// 10
	menu_additem(menu, "\y|\d-\r-\y[ \wAwp No-Scope kör\y ]\r-\d-\y|"); // 11
	menu_additem(menu, "\y|\d-\r-\y[ \wP90 kör\y ]\r-\d-\y|"); //12 
	
	menu_setprop(menu, MPROP_EXITNAME, "\rKilépés");
	menu_setprop(menu, MPROP_NEXTNAME, "\yKövetkező");
	menu_setprop(menu, MPROP_BACKNAME, "\yVissza");	

	menu_display( id, menu );

	return PLUGIN_HANDLED;
}

public HBKHandle(id, menu, iItem) 
{ 
	if(iItem == MENU_EXIT){ 
		menu_destroy(menu); 
		return PLUGIN_HANDLED; 
	} 

	set_dhudmessage(random_num(0,255), random_num(0,255), random_num(0,255), -1.0, 0.0, 0, 6.0, 12.0, 0.1, 0.2)
	show_dhudmessage(0, "-=[ %L ]=-", LANG_PLAYER, "HBROUND_MSG_START");

	new Name[32];
	get_user_name(id, Name, 31);
	HbkChoice = iItem;

	new p[32],n, idx;
	get_players(p,n,"ch");
	for(new i=0;i<n;i++)
	{
		idx = p[i];
		if(!is_user_connected(id))
			continue;
		
		new HBKName[64];

		switch(iItem)
		{
			case 0: copy(HBKName, charsmax(HBKName), fmt("%L", idx, "HBROUND_TYPE_KNIFE"));
			case 1: copy(HBKName, charsmax(HBKName), fmt("%L", idx, "HBROUND_TYPE_GRENADE_KNIFE"));
			case 2: copy(HBKName, charsmax(HBKName), fmt("%L", idx, "HBROUND_TYPE_SHOTGUN"));
			case 3: copy(HBKName, charsmax(HBKName), fmt("%L", idx, "HBROUND_TYPE_DEAGLE"));
			case 4: copy(HBKName, charsmax(HBKName), fmt("%L", idx, "HBROUND_TYPE_AWP"));
			case 5: copy(HBKName, charsmax(HBKName), fmt("%L", idx, "HBROUND_TYPE_RANDOM_PISTOL"));
			case 6: copy(HBKName, charsmax(HBKName), fmt("%L", idx, "HBROUND_TYPE_BERETTA"));
			case 7: copy(HBKName, charsmax(HBKName), fmt("%L", idx, "HBROUND_TYPE_USP_GLOCK"));
			case 8: copy(HBKName, charsmax(HBKName), fmt("%L", idx, "HBROUND_TYPE_TMP"));
			case 9: copy(HBKName, charsmax(HBKName), fmt("%L", idx, "HBROUND_TYPE_INFINITE_GRENADE"));
			case 10: copy(HBKName, charsmax(HBKName), fmt("%L", idx, "HBROUND_TYPE_SCOUT"));
			case 11: copy(HBKName, charsmax(HBKName), fmt("%L", idx, "HBROUND_TYPE_AWP_NOSCOPE"));
			case 12: copy(HBKName, charsmax(HBKName), fmt("%L", idx, "HBROUND_TYPE_P90"));
		}
		
		
		sk_chat(idx, "%L", idx, "HBROUND_MSG_STARTED", Name, HBKName);
		sk_chat(idx, "%L", idx, "HBROUND_MSG_NO_WEAPONS");
		
		set_dhudmessage(192, 192, 192, -1.0, 0.05, 0, 6.0, 12.0, 0.1, 0.2) 
		show_dhudmessage(idx, "[ %s ] %L", HBKName, idx, "HBROUND_MSG_ROUND");
	}
	


	server_cmd("mp_infinite_ammo 1;sv_restart 1")
	set_task(2.0,"HBK_RoundRestart");

	menu_destroy(menu); 
	return PLUGIN_HANDLED; 
}  
public HBK_RoundRestart()
{
	GiveWeaponToAll()
	g_hbkStarted = true 

	server_cmd("mp_give_player_c4 0; mp_forcerespawn 1.30")
	pause("c", "slaylosers.amxx")
	pause("c", "fegyomenu_uj.amxx")
	pause("c", "rush.amxx")
	client_cmd(0, "spk hbk/hbk.wav; cl_weather 1") //	
	
	//unpause("c", "hbk_addon_hsmode.amxx") //show_vote	

}
public HBKEndNow()
{
	if(g_hbkStarted)
	{   
		g_hbkStarted = false
		HbkChoice = 0

		NoScope=false; 

		EndSpecialRound()
		sk_chat_lang("%L", "HBROUND_MSG_ENDED");
	}
}

public EndSpecialRound()
{
	new players[32], number, Player//, id
	get_players(players, number,"a")
	
	for(new i=0; i < number; i++)
	{	
		Player = players[i]
		HBKActive[Player]=false;
		rg_remove_all_items(Player)
		rg_give_item(Player, "weapon_knife");
		server_cmd("mp_give_player_c4 1; mp_roundtime 2; mp_forcerespawn 0;mp_infinite_ammo 0;")
		client_cmd(0, "cl_weather 0")
		unpause("c", "slaylosers.amxx")
		unpause("c", "fegyomenu_uj.amxx")
		unpause("c", "rush.amxx")

		client_cmd(0, "mp3 stop; stopsound");

		client_cmd(0, "spk hbk/hbk_end.wav");
	
	}
}

public GiveWeaponToAll()
{
	new players[32], number, Player//, id
	get_players(players, number,"a")

	for(new i=0; i < number; i++)
	{	
		Player = players[i]	    
		HBKActive[Player]=true;
		GivePlayerItem(Player);
	}
}

public GivePlayerItem(id)
{	
	rg_remove_all_items(id)
	strip_user_weapons(id)
	rg_give_item(id, "weapon_knife")

	switch(HbkChoice)
	{
		case 0: 
		{  
			rg_give_item(id, "weapon_knife")       
		} 
		case 1: 
		{
			rg_give_item(id, "weapon_hegrenade") 
			rg_give_item(id, "weapon_flashbang") 
			rg_give_item(id, "weapon_flashbang") 
		}
		case 2: 
		{           
			rg_give_item(id, "weapon_m3") 
			rg_give_item(id, "weapon_xm1014") 
			rg_set_user_bpammo(id,WEAPON_M3,240)   
			rg_set_user_bpammo(id,WEAPON_XM1014,240)  
		} 
		case 3: 
		{  
			rg_give_item(id, "weapon_deagle") 
			rg_set_user_bpammo(id,WEAPON_DEAGLE,240)   
		} 
		case 4: 
		{ 
			rg_give_item(id, "weapon_awp") 
			rg_set_user_bpammo(id,WEAPON_AWP,240)              
		} 
		case 5: 
		{   
					g_WpnID[S] = random_num(1, charsmax(g_szSecondary))
					rg_give_item(id, g_szSecondary[g_WpnID[S]][_WeaponName]) 
					rg_set_user_bpammo(id, g_szSecondary[g_WpnID[S]][_CSW], g_szSecondary[g_WpnID[S]][_Ammo])
		} 
		case 6: 
		{    
			rg_give_item(id, "weapon_elite") 
			rg_set_user_bpammo(id,WEAPON_ELITE,240)
		} 
		case 7: 
		{ 
			rg_give_item(id, "weapon_usp") 
			rg_give_item(id, "weapon_glock18") 	

			rg_set_user_bpammo(id,WEAPON_USP,240)
			rg_set_user_bpammo(id,WEAPON_GLOCK18,240)
		} 
		case 8: 
		{ 
			rg_give_item(id, "weapon_tmp") 
			rg_set_user_bpammo(id,WEAPON_TMP,240)  
		} 
		case 9: 
		{ 
			rg_give_item(id, "weapon_hegrenade") 
			rg_give_item(id, "weapon_flashbang") 
			rg_give_item(id, "weapon_flashbang") 

			rg_set_user_bpammo(id,WEAPON_HEGRENADE,240)      
		}
		case 10:
		{ 
			rg_give_item(id, "weapon_scout") 
			rg_set_user_bpammo(id,WEAPON_SCOUT,240)
		}
		case 11:
		{
			NoScope=true;
			rg_give_item(id, "weapon_awp") 
			rg_set_user_bpammo(id,WEAPON_AWP,240)
		}
		case 12:
		{
			rg_give_item(id, "weapon_p90")
			rg_set_user_bpammo(id,WEAPON_P90,240)
		}
	}
}

// NoZoom
public zoom(id) {
	if(NoScope && g_hbkStarted)
	{
		message_begin(MSG_ONE, gmsgSetFOV, {0,0,0}, id)
		write_byte(90) //NO Zooming
		message_end()
	}
	return PLUGIN_CONTINUE;
}

public PlayerDropCheck(id)
{
	if(g_hbkStarted)
	{
		sk_chat(id, "%L", id, "HBROUND_MSG_NO_DROP");
		return PLUGIN_HANDLED;
	}
	return PLUGIN_CONTINUE;
}

public Fw_HasRestrictItem_Pre(id, ItemID:iItem, ItemRestType:iType)
{
	if(g_hbkStarted && IsPlayer(id)) 
	{
		if (iType == ITEM_TYPE_TOUCHED || iType == ITEM_TYPE_BUYING)
		{
			if (iItem)
			{
				SetHookChainReturn(ATYPE_BOOL, HC_SUPERCEDE) // HC_SUPERCEDE = true
			}
		}
	}
	return HC_CONTINUE
}
