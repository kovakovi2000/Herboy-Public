#include <amxmodx>
#include <amxmisc>
#include <fun>
#include <cstrike>
#include <engine>
#include <fakemeta>
#include <hamsandwich>


#define PLUGIN_NAME		"Fragindito"
#define PLUGIN_VERSION	"1.0"
#define PLUGIN_AUTHOR	"Hunti :D"
#define MAX_PLAYERS		32
#define prefix "[Avatár]"


const UNIT_SECOND = (1 << 12);
new Float:playervolumes[33]
new g_message_hud;
new g_unique;
new g_count_;
new g_count__screens;
new g_count__final;
new g_finish;
new g_maxplayers;

new g_message_screenshake;
new g_message_screenfade;
new gScreenFade,gScreenShake;
new iRandomNumber,SyncHuds;

enum RestartSettings
{
iTas
}

enum Messages
{
	mScreenShake,
	mScreenFade
}


new g_StartTime[33], g_EndTime[32], kill[33], SwitchFrag, bool:FirstTask, x_tempid

new const view_hud[][] =
{
	"A Fragverseny véget ért!^nElső: %s",
	"A Fragverseny véget ért!^nElső: %s | Második: %s",
	"A Fragverseny véget ért!^nElső: %s | Második: %s | Harmadik: %s",
	"Jelenleg Fragverseny van (%s-%s)^n1. %s - ÖLÉS: %i",
	"Jelenleg Fragverseny van (%s-%s)^n1. %s - ÖLÉS: %i | 2. %s - ÖLÉS: %i",
	"Jelenleg Fragverseny van (%s-%s)^n1. %s - ÖLÉS: %i | 2. %s - ÖLÉS: %i | 3. %s - ÖLÉS: %i",
	"A Fragverseny elkezdődik %s-kor..."
}	
	
	
	
	
	
new RestartSetting[RestartSettings]

public plugin_precache()
{
	precache_model("models/AVHBSKINS/frag.mdl")
	precache_sound("frag/egy.wav");
	precache_sound("frag/ketto.wav");
	precache_sound("frag/harom.wav");
	precache_sound("frag/negy.wav");
	precache_sound("frag/ot.wav");
	precache_sound("frag/h11.wav");
	precache_sound("weapons/c4_explode1.wav");
	precache_generic("sound/frag/ff32.mp3");
}

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);
	
	//register_concmd("zene", "concmd_RockFinal");
	
	g_message_screenshake = get_user_msgid("ScreenShake");
	g_message_screenfade = get_user_msgid("ScreenFade");
	gScreenFade = get_user_msgid("ScreenFade")
	register_clcmd("fragindit", "openMain")
	register_clcmd("kills", "openKillViewer")

	
	register_clcmd("START_TIME", "loadStart")
	register_clcmd("END_TIME", "loadEnd")
	register_clcmd("INDOK", "reset_kuld")
	
	register_event("DeathMsg","halal","a")

	RegisterHam(Ham_Item_Deploy, "weapon_knife", "Change_Weapon", 1);
	g_message_hud = CreateHudSyncObj();
	
	g_maxplayers = get_maxplayers();
}
public plugin_natives()
{
  register_native("sk_fragversenyrunning","native_fragversenyrunning",1)
}
public native_fragversenyrunning()
{
	return SwitchFrag;
}
public Change_Weapon(iEnt)
{
	if(SwitchFrag == 0 || SwitchFrag == 1 || SwitchFrag == 3)
		return PLUGIN_HANDLED;
		
	if(!pev_valid(iEnt))
		return;

	new id = get_pdata_cbase(iEnt, 41, 4);

	if(!pev_valid(id))
		return;

	entity_set_string(id, EV_SZ_viewmodel, "models/AVHBSKINS/frag.mdl");
}
public concmd_RockFinal()
{
	if(g_unique)
	{
		console_print(0, "1 mapon,csak 1x índithatsz fragversenyt,ha szeretnél további fragversenyt,válts mapot!");
		return PLUGIN_HANDLED;
	}
	client_print_color(0, print_team_default, "^4[INFO]^1 Az ^3MP3^1 hang erejét ^3feljebb vettük!!");
	client_print_color(0, print_team_default, "^4[INFO]^1 Az ^3FRAGVERSENY INTRO^1 hamarosan elkezdődik!");
	client_print_color(0, print_team_default, "^4[INFO]^1 ^3EPILEPSZIÁS ROHAM KÖVETKEZIK!!!");

	server_cmd("mp_give_player_c4 0; mp_roundtime 333;mp_forcerespawn 0.00001")
	pause("c", "hirdeto.amxx")
	pause("c", "AQS.amxx")
	pause("c", "crx_remusic.amxx")
	g_count_ = 1;
	getPlayerSound()
	set_task(19.5,"fn_Vale");
	set_task(0.4,"Fade",.flags = "a",.repeat = 50)
	set_task(1.0,"ConLoTr")
  set_task(0.3, "fn_PlayMusic");

	set_task(1.0, "setPlayerItems")
	
	g_unique = 1

	return PLUGIN_HANDLED;
}
public setPlayerItems()
{
	new id
	for(id = 0 ; id <= g_maxplayers ; id++) 
	if(is_user_connected(id))
	{
		if(is_user_alive(id))
		{
			set_user_godmode(id, 1)
			set_user_health(id, 999)
			strip_user_weapons(id);
			give_item(id, "weapon_knife");
		}
	}
}
public getPlayerSound()
{
	new id
	for(id = 0 ; id <= g_maxplayers ; id++) 
	if(is_user_connected(id))
	{
		new volume[33], Float:volumefloat[33]
		get_user_info(id, "MP3Volume", volume, 99);
		get_user_info(id, "MP3Volume", volumefloat, 99);
	}
}
public setPlayerSound()
{
	new id
	for(id = 0 ; id <= g_maxplayers ; id++) 
	if(is_user_connected(id))
	{
		kill[id] = 0;
		client_cmd(id, "^"MP3Volume^" ^"%3.2f^"",playervolumes[id]);
		set_user_info(id, "MP3Volume", playervolumes[id]);
	}
}
public Fade()
{
	SetMessage(mScreenFade, (3<<6), (3<<6), (3<<6), 0, 0, 0, 255)
}

SetMessage(Messages:MessageType, Duration = 0, HoldTime = 0, FadeType = 0, R = 0, G = 0, B = 0, Intensity = 0)
{
	switch(MessageType)
	{
		case mScreenFade:
		{
			message_begin(MSG_BROADCAST, gScreenFade)
			write_short(Duration)
			write_short(HoldTime)
			write_short(FadeType)
			write_byte(R)
			write_byte(G)
			write_byte(B)
			write_byte(Intensity)
			message_end()
		}
	}
}

public fn_Vale()
{
	new sMsg[64];
	
	if(g_count_ > 5)
		formatex(sMsg, charsmax(sMsg), "A fragverseny %i másodperc múlva kezdődik", g_count_);
	else
	{
		new sSound[64];
		
		switch(g_count_)
		{
			case 5:
			{
				client_cmd(0, "spk frag/ot.wav");
				
				new i;
				for(i = 1; i <= g_maxplayers; ++i)
				{
					if(!is_user_connected(i))
						continue;
				}
				
				for(i = 1; i <= g_maxplayers; ++i)
				{
					if(!is_user_connected(i))
						continue;
					
					ClearSyncHud(i, g_message_hud);
				}
				
				set_lights("i");
			}
			case 4:
			{
				client_cmd(0, "spk frag/negy.wav");
				set_lights("g");
			}
			case 3:
			{
				client_cmd(0, "spk frag/harom.wav");
				set_lights("e");
			}
			case 2:
			{
				client_cmd(0, "spk frag/ketto.wav");
				set_lights("c");
			}
			case 1:
			{
				set_lights("a");
			}
			case 0:
			{	
				g_count_ = 1;
				return;
			}
		}
		client_cmd(0, "spk ^"%s^"", sSound);
		
		set_dhudmessage(255, 255, 0, -1.0, 0.3, 0, 0.0, 0.3, 0.3, 0.3);
		show_dhudmessage(0, "", g_count_);
	}
	
	if(g_count_ > 5)
	{
		set_hudmessage(255, 255, 0, -1.0, 0.3, 0, 0.0, 3.0, 2.0, 1.0, -1);
		ShowSyncHudMsg(0, g_message_hud, "", sMsg);
	}
	
	--g_count_;
	
	set_task(1.0, "fn_Vale");
}

public fn_PlayMusic()
{
	if(g_count_ == 1)
	{
		++g_count_;
		
		set_task(0.3, "fn_PlayMusic");
		
		return;
	}
	
	new sSound[64];
	
	switch(g_count_)
	{
		case 6:
		{
			client_cmd(0, "MP3Volume 0.2");
			set_task(1.0, "SetMP3S", _,_,_, "a", 80)
			client_cmd(0, "mp3 play ^"sound/frag/ff32.mp3^"");
			
			new i;
			for(i = 1; i <= g_maxplayers; ++i)
			{
				if(!is_user_connected(i))
					continue;
}
			
			g_count_ = 1;
			g_count__final = 1;
			
			set_task(20.0, "fn_ChangeRender");
			set_task(46.0, "fn_ChangeNumber");
			set_task(46.8, "StartCrazy");
			set_task(60.0, "fn_ChangeScreens");
			set_task(73.5, "fn_Finish");
			
			return;
		}
	}
	
	client_cmd(0, "spk ^"%s^"", sSound);
	
	++g_count_;
	
	set_task(0.3, "fn_PlayMusic");
}
public SetMP3S()
{
	if(SwitchFrag == 2)
		client_cmd(0, "MP3Volume 0.2");
}
public fn_ChangeRender()
{
	if(g_count_ == 60 || g_finish)
		return;

	static i;
	static Float:vecOrigin[3];
	
	for(i = 1; i <= g_maxplayers; ++i)
	{
		if((g_count_ % 2) == 0)
		{
			if(!is_user_connected(i))
				continue;
			
			message_begin(MSG_ONE_UNRELIABLE, g_message_screenshake, _, i);
			write_short(UNIT_SECOND * 9);
			write_short(UNIT_SECOND * 6);
			write_short(UNIT_SECOND * 9);
			message_end();
			
			if(!is_user_alive(i))
				continue;
			
			entity_get_vector(i, EV_VEC_origin, vecOrigin);
			
			engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0);
			write_byte(TE_DLIGHT);
			engfunc(EngFunc_WriteCoord, vecOrigin[0]);
			engfunc(EngFunc_WriteCoord, vecOrigin[1]);
			engfunc(EngFunc_WriteCoord, vecOrigin[2]);
			write_byte(40);
			write_byte(random_num(50, 250));
			write_byte(random_num(50, 250));
			write_byte(random_num(50, 250));
			write_byte(50);
			write_byte(10);
			message_end();
		}
		
		if(!is_user_alive(i))
			continue;
		
		set_user_rendering(i, kRenderFxGlowShell, random_num(150, 250), random_num(150, 250), random_num(150, 250), kRenderNormal, 25);
	}
	
	++g_count_;
	
	set_task(0.5, "fn_ChangeRender");
}

public fn_ChangeScreens()
{
	if(g_count__screens == 75 || g_finish)
		return;
	
	static i;
	if((g_count__screens % 15) == 0)
	{
		for(i = 1; i <= g_maxplayers; ++i)
		{
			if(!is_user_connected(i))
				continue;
			
			message_begin(MSG_ONE_UNRELIABLE, g_message_screenshake, _, i);
			write_short(UNIT_SECOND * 28);
			write_short(UNIT_SECOND * 18);
			write_short(UNIT_SECOND * 28);
			message_end();
		}
	}
	
	for(i = 1; i <= g_maxplayers; ++i)
	{
		if(!is_user_connected(i))
			continue;
		
		message_begin(MSG_ONE_UNRELIABLE, g_message_screenfade, _, i)
		write_short(UNIT_SECOND*4);
		write_short(UNIT_SECOND*4);
		write_short(0x0000);
		write_byte(random_num(100, 250));
		write_byte(random_num(100, 250));
		write_byte(random_num(100, 250));
		write_byte(200);
		message_end();
	} 
	++g_count__screens;
	
	set_task(0.2, "fn_ChangeScreens");
}

public fn_Finish()
{
	g_finish = 1;
	client_print_color(0, print_team_default, "^4[INFO]^1 A ^3fragverseny elkezdődőtt! ^3| ^4Tart: ^3%s", g_EndTime);
	client_print_color(0, print_team_default, "^4[INFO]^1 Az ^3epilepsziás^1 rohamot nem szenvedő játékosoknak jó játékot!");

	server_cmd("mp_give_player_c4 1; mp_roundtime 2;mp_forcerespawn 0")
	unpause("c", "hirdeto.amxx")
	unpause("c", "AQS.amxx")
	unpause("c", "crx_remusic.amxx")
	setPlayerSound()
	client_cmd(0, "mp3 stop; stopsound");
	
	
	client_cmd(0, "spk weapons/c4_explode1.wav");
	client_cmd(0, "spk frag/h11.wav");
	
	new i;
	for(i = 1; i <= g_maxplayers; ++i)
	{
		if(!is_user_connected(i))
			continue;
		
		message_begin(MSG_ONE_UNRELIABLE, g_message_screenfade, _, i)
		write_short(UNIT_SECOND*4);
		write_short(UNIT_SECOND*4);
		write_short(0x0000);
		write_byte(255);
		write_byte(255);
		write_byte(25);
		write_byte(255);
		message_end();
		
		set_user_rendering(i);
	}
	
	set_task(0.3, "fn_R");
	set_task(1.0, "fn_Restart3");
}
public client_putinserver(id)
{
	kill[id] = 0;
}
 
public fn_R()
{
	server_cmd("mp_give_player_c4 1; mp_roundtime 2;mp_forcerespawn 0")
	server_cmd("sv_restart 1")
	server_cmd("fragmenu")
}

public fn_Restart3()
{
	SwitchFrag = 1
}

public fn_ChangeNumber()
{
	if(g_count__final == 6)
		return;
	
	new sSound[64];
	
	switch(g_count__final)
	{
		case 1: client_cmd(0, "spk frag/ot.wav");
		case 2: client_cmd(0, "spk frag/negy.wav");
		case 3: client_cmd(0, "spk frag/harom.wav");
		case 4: client_cmd(0, "spk frag/ketto.wav");
		case 5: client_cmd(0, "spk frag/egy.wav");
	}
	
	client_cmd(0, "spk ^"%s^"", sSound);
	
	++g_count__final;
	
	set_task(5.0, "fn_ChangeNumber");
	set_lights("i");
	
	set_lights("c");	
	
	set_lights("e");
	
	set_lights("g");
	
	set_lights("");	
}
public StartCrazy()
{
	set_task(0.1,"crazy",.flags = "a",.repeat = 125)
}
public crazy()
{
	new iPlayers[MAX_PLAYERS],iNum,id
	get_players(iPlayers,iNum,"ch")
	for(new i;i < iNum;i++)
	{
		id = iPlayers[i]
		
		new Float:fVec[3]
		fVec[0] = random_float(0.0, 20.0)
		fVec[1] = random_float(0.0, 50.0)
		fVec[2] = random_float(0.0, 70.0)
		
		entity_set_vector(id, EV_VEC_punchangle, fVec)
	}
}
public ConLoTr()
{
	set_dhudmessage(0,100,200,-1.0,0.20,0,1.0,0.5)
	show_dhudmessage(0,"Kezdődjön a fragverseny!")
	
	set_task(2.0,"fn_Messages")
}
public fn_Messages()
{
	new szMsg[55]
    
	new szMessages[][] = { "Love you just the way you are", "---~ [ AVATÁR ] ~--", "Üdvözlünk az avatár szerveren", "Jó játékot kívánunk", "Sok sikert a fragversenyhez" }
	new Float:fTimes[] = { 1.5, 2.0, 1.5, 1.0, 1.2, 0.8, 1.0, 0.6, 0.3, 0.6, 0.4, 0.6, 0.3, 5.4, 4.0, 2.5 }
    
	formatex(szMsg,charsmax(szMsg), RestartSetting[iTas] < 13 ? szMessages[0] : szMessages[RestartSetting[iTas] - 12])
    
	if(RestartSetting[iTas] < 16)
		set_task(fTimes[RestartSetting[iTas]], "fn_Messages")
		
	set_dhudmessage(0,100,200,-1.0,RestartSetting[iTas] < 13 ? sequence(0.25, 0.30, 0.35) : 0.20, 0, 2.0, 0.9)
	//set_dhudmessage(0,100,200,-1.0,RestartSetting[iTas] < 13 ? sequence(0.35, 0.40, 0.45) : 0.20,0,1.0,0.1)
	show_dhudmessage(0, szMsg)
	
	RestartSetting[iTas]++
}
Float:sequence(Float:a,Float:b,Float:c)
{
	new Float:RandomValue
	switch(iRandomNumber)
	{
		case 0:
		{
			iRandomNumber++
			RandomValue = a
		}
		case 1:
		{
			iRandomNumber++
			RandomValue = b
		}
		case 2:
		{
			iRandomNumber = 0
			RandomValue = c
		}
	}
	return RandomValue
}
public halal()
{
	new attacker = read_data(1)
	new victim = read_data(2)
	
	if(SwitchFrag == 0 || SwitchFrag == 3 || SwitchFrag == 2) return PLUGIN_HANDLED
	if(attacker == victim || attacker == 0)
		return PLUGIN_HANDLED
		
	kill[attacker]++
	
	return PLUGIN_CONTINUE;
}
public loadStart(id)
{
	g_StartTime[id] = EOS
	read_args(g_StartTime, charsmax(g_StartTime))
	remove_quotes(g_StartTime)
	
	if(contain(g_StartTime, ":") != -1)
	{
		if((strlen(g_StartTime) != 5))
		{
			client_print_color(id, print_team_default,  "^4%s^1 Hibás idő formátum!", prefix)
			g_StartTime[id] = EOS
			return PLUGIN_HANDLED
		}
	}
	else
	{
		client_print_color(id, print_team_default,  "^4%s^1 Hibás idő formátum!", prefix)
		g_StartTime[id] = EOS
		return PLUGIN_HANDLED
	}
	
	openMain(id)
	return PLUGIN_HANDLED
}
public loadEnd(id)
{
	g_EndTime[id] = EOS
	read_args(g_EndTime, charsmax(g_EndTime))
	remove_quotes(g_EndTime)
	
	if(contain(g_EndTime, ":") != -1)
	{
		if((strlen(g_EndTime) != 5))
		{
			client_print_color(id, print_team_default,  "^4%s^1 Hibás idő formátum!", prefix)
			g_EndTime[id] = EOS
			return PLUGIN_HANDLED
		}
	}
	else
	{
		client_print_color(id, print_team_default,  "^4%s^1 Hibás idő formátum!", prefix)
		g_EndTime[id] = EOS
		return PLUGIN_HANDLED
	}
	
	openMain(id)
	return PLUGIN_HANDLED
}
public openMain(id)
{
	//if(!(get_user_flags(id) & ADMIN_CFG)) return PLUGIN_HANDLED
	
	new szMenu[121],Time[10]
	get_time("%H:%M:%S", Time, charsmax(Time))
	
	format(szMenu, charsmax(szMenu), "\r%s \wVezérlőpult^n\dIdő: %s", prefix, Time)
	new menu = menu_create(szMenu, "main_handler")
	
	if(FirstTask == false)
	{
		if(SwitchFrag == 0) formatex(szMenu, charsmax(szMenu), "Kezdési Idő: \y[%s]",g_StartTime)
		else formatex(szMenu, charsmax(szMenu), "A fragverseny elindúlt \y[%s-%s]^n", g_StartTime, g_EndTime)
		menu_additem(menu, szMenu, "0", 0)
		
		if(SwitchFrag == 0) formatex(szMenu, charsmax(szMenu), "Végetérési Idő: \y[%s]^n", g_EndTime)
		else formatex(szMenu, charsmax(szMenu), "\rBeállitások")
		menu_additem(menu, szMenu, "1", 0)
		
		if(SwitchFrag == 0) menu_additem(menu, "\rVerseny elindítása!", "2", 0)
	}
	else
	{
		menu_addtext2(menu, fmt("A fragverseny elindul ekkor: \r%s",g_StartTime))
		menu_addtext2(menu, fmt("A fragverseny végetér ekkor: \r%s",g_EndTime))

		menu_additem(menu, "Fragverseny leállítása", "3", 0)
	}
		
	menu_display(id, menu, 0)
	return PLUGIN_CONTINUE
}
public main_handler(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}

	switch(item)
	{
		case 0:
		{
			if(SwitchFrag == 0) client_cmd(id, "messagemode START_TIME")
			openMain(id)
		}
		case 1:
		{
			if(SwitchFrag == 0)
			{
				client_cmd(id, "messagemode END_TIME")
				openMain(id)
			}
			else openSettings(id)
		}
		case 2:
		{
			SwitchFrag = 3
			FirstTask = true
			openTimeChecker(id)
			client_print_color(id, print_team_default,  "^4%s^1 A számláló elindult!", prefix)
		}
		case 3:
		{
			FirstTask = false
			SwitchFrag = 0
			client_print_color(0, print_team_default, "Egy ^3ADMIN ^1leállította a fragversenyt!")
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public openSettings(id) {
	new szMenu[121]
	format(szMenu, charsmax(szMenu), "\r%s \wBeállítások", prefix)
	new menu = menu_create(szMenu, "settings_handler");
	
	menu_additem(menu, "Verseny Leállítása", "0",0)
	menu_additem(menu, "Ölés Nullázása", "1",0)
	menu_additem(menu, "Játékosok Ölései", "2",0)
		
	menu_display(id, menu, 0);
}
public settings_handler(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}

	switch(item)
	{
		case 0: openSelect(id)
		case 1: openReseter(id)
		case 2: openKillViewer(id)
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public openKillViewer(id)
{	
	new szMenu[121], players[32], szTemp[10], pnum, Name[32]
	get_players(players, pnum)
	
	format(szMenu, charsmax(szMenu), "\r%s \wJátékosok Ölései", prefix)
	new menu = menu_create(szMenu, "viewer_handler")
 
	for(new i; i < pnum; i++)
	{
		get_user_name(players[i], Name, charsmax(Name))
		formatex(szMenu, charsmax(szMenu),"%s \d[\yÖLÉS:\r %i\d]", Name, kill[players[i]])
		num_to_str(players[i], szTemp, charsmax(szTemp))
		menu_additem(menu, szMenu, szTemp)
	}
	
	menu_display(id, menu);
}
public viewer_handler(id,menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu)
		return PLUGIN_CONTINUE
	}
	openKillViewer(id)
	return PLUGIN_CONTINUE
}
public openSelect(id)
{
	new menu = menu_create("\rBiztosan leakarod állítani a fragversenyt?", "select_handler");	
 
	menu_additem(menu, "Igen!", "0",0)
	menu_additem(menu, "Nem!", "1",0)
 
	menu_display(id, menu, 0);
}
public select_handler(id, menu, item)
{
	if( item == MENU_EXIT )
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	switch(item)
	{
		case 0:
		{
			FirstTask = false
			SwitchFrag = 0
			client_print_color(0, print_team_default, "^4%s ^1Egy ^3ADMIN ^1leállította a fragversenyt!", prefix)
		}
		case 1: openMain(id)
	}
	menu_destroy(menu)
	return PLUGIN_HANDLED
}
public openReseter(id) {
	new cim[121], players[32], pnum, Name[32], szTempid[10]
	get_players(players, pnum)
	
	format(cim, charsmax(cim), "\yJátékos ölésének nullázása!")
	new menu = menu_create(cim, "reset_handler" )
	
	for( new i; i<pnum; i++ )
	{
		get_user_name(players[i], Name, charsmax(Name))
		num_to_str(players[i], szTempid, charsmax(szTempid))
		menu_additem(menu, Name, szTempid, 0)
	}
	menu_display(id, menu, 0)
}
public reset_handler(id, menu, item)
{
	if( item == MENU_EXIT ) {
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	new data[6], szName[64], access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
	
	x_tempid = str_to_num(data);
	client_cmd(id, "messagemode INDOK");
	
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public reset_kuld(id)
{
	new Msg[121], Name[32]
	read_args(Msg, charsmax(Msg))
	remove_quotes(Msg)
	get_user_name(x_tempid, Name, charsmax(Name))
 
	kill[x_tempid] = 0
	client_print_color(0, print_team_default, "^4%s^3 %s^1 ölései nullázva lettek! Indok: ^4%s", prefix, Name, Msg)
	
	return PLUGIN_HANDLED;
}
public openTimeChecker(id)
{
	if(FirstTask) set_task(0.5, "openTimeChecker",id)
	
	new Time[10], SecSReset[10], SecEReset[10]
	get_time("%H:%M:%S", Time, charsmax(Time))
	formatex(SecSReset, charsmax(SecSReset), "%s:00", g_StartTime)
	formatex(SecEReset, charsmax(SecEReset), "%s:00", g_EndTime)
 
	if(SwitchFrag == 3)
	{
		set_hudmessage(0, 255, 0, -1.0, 0.15, 0, 6.0, 0.5)
		show_hudmessage(0, view_hud[6], g_StartTime)
	}
	else SeeBestPlayers(id)
 
	if(equal(Time, SecSReset))
	{
		SwitchFrag = 2
		//server_cmd("sv_restart 1")
		if(SwitchFrag == 2)
			set_task(1.1, "concmd_RockFinal")
	}
	if(equal(Time, SecEReset))
	{
		FirstTask = false
		SwitchFrag == 0
		SeeBestPlayers(id, true)
	}
 
	return PLUGIN_CONTINUE;	
}
SeeBestPlayers(id, cdis=false)
{
	new Players[32], Num;
	get_players(Players, Num);
	SortCustom1D(Players, Num, "sort_bestthree")
 
	new Top1 = Players[0]
	new Top2 = Players[1]
	new Top3 = Players[2]
	
	if(cdis)
	{
		for(new i = 0; i < sizeof(Players); i++)
		{
			new p = Players[i];
			new cname[32];

			get_user_name(p, cname, charsmax(cname));
			console_print(id, "%i. - %s [%i kills]", i+1, cname, kill[p]);
		}
	}
 
	new TopName1[32], TopName2[32], TopName3[32]
	get_user_name(Top1, TopName1, charsmax(TopName1))
	get_user_name(Top2, TopName2, charsmax(TopName2))
	get_user_name(Top3, TopName3, charsmax(TopName3))
 
	if(SwitchFrag == 0)
	{
		set_hudmessage(0, 255, 0, -1.0, 0.10, 0, 6.0, 30.0)
		if(Num == 1) show_hudmessage(0, view_hud[0], TopName1)
		if(Num == 2) show_hudmessage(0, view_hud[1], TopName1, TopName2)
		if(Num >= 3) show_hudmessage(0, view_hud[2], TopName1, TopName2, TopName3)
	}
	else if(SwitchFrag == 1)
	{
		set_hudmessage(0, 127, 255, -1.0, 0.10, 0, 6.0, 0.5)
		if(Num == 1) show_hudmessage(0, view_hud[3], g_StartTime, g_EndTime, TopName1, kill[Top1])
		if(Num == 2) show_hudmessage(0, view_hud[4], g_StartTime, g_EndTime, TopName1, kill[Top1], TopName2, kill[Top2])
		if(Num >= 3) show_hudmessage(0, view_hud[5], g_StartTime, g_EndTime, TopName1, kill[Top1], TopName2, kill[Top2], TopName3, kill[Top3])
	}
}
public sort_bestthree(id1, id2)
{
	if(kill[id1] > kill[id2]) return -1
	else if(kill[id1] < kill[id2]) return 1
 
	return 0
}


