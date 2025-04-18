#include <amxmodx>
#include <cstrike>
#include <fakemeta>
#include <hamsandwich>
#include <regex>
#include <engine>
#include <fun>
#include <sqlx>
#include <bansys>
#include <sk_utils>
#include <regsystem>
#include <ezsck>
#include <lang>
#include <langsys>
#include <manager>
#include <reapi>
//langs
//https://chatgpt.com/share/672be3f7-7b60-800e-9cde-6326017a9d41
new AllowedForLoginPanel[33] = 0, g_Maxplayers;
new IsAllowedForReRegister[33] = 0;
new  g_screenfade,  fwd_loadcmd;
#define VALIDATED_TASK_OFFSET 46236053
#define DEMO_TASK_OFFSET 46236153
#define DEMO_TASK_DETAIL 45236253
#define CHOOSE_TEAM_VGUI_MENU_ID 2
#define CHOOSE_TEAM1_CLASS_VGUI_MENU_ID 26
#define CHOOSE_TEAM2_CLASS_VGUI_MENU_ID 27
#define HASHSIZE 512
#define SALT "{{6&#9Ii<hL&6{aO&tV@&#eE>5100<&eP}{&xU>#<xS><##{iS}{lleY2069}}"

enum _:RegisterProperties
{
	gId,
	gName[33],
	gIP[33],
	gSteamID[33],
	gUsername[33],
	gPassword[33],
	RegisterDate[33],
	gPasswordAgain[33],
	gPasswordHash[HASHSIZE],
	gEmail[64],
	gProgress, 
	PlayTime,
	InProgress,
	LoginKey[40],
	Logined,
	Active,
	SwitchedTeam,
	IsHaveAccount,
	Logined_Print,
	PremiumPoint,
	Kills,
	Deaths,
	HS,
	AdminL,
	lang_types:plang,
	lang_types:plangByIP,
	HelpUsername[33],
	HelpEmail[33],
	bool:isIChoosedTeam
}


new s_Player[33][RegisterProperties];
public plugin_init()
{
	register_plugin("[SK] - RegSystem", "v2.2", "Shedi");
	register_impulse(201, "CheckMenu");
	register_concmd("hb_set_admin", "CmdSetAdmin", _, "<#id> <jog>");
	register_clcmd("say /menu", "CheckMenu");
	register_clcmd("Felhasznalonev", "set_username");
	register_clcmd("Jelszo", "set_password");
	register_clcmd("JelszoUjra", "set_passwordAgain");
	register_clcmd("Email", "set_email");
	register_message(get_user_msgid("ShowMenu"), "Message_ShowMenu");
	register_message(get_user_msgid("VGUIMenu"), "Message_VGUIMenu");
	register_clcmd("chooseteam", "HamHook_Player_ChangeTeam");
	register_clcmd("jointeam", "HamHook_Player_ChangeTeam");
	register_clcmd("joinclass", "HamHook_Player_ChangeTeam");
	register_menucmd(register_menuid("REGMAIN"), 0xFFFF, "hRegmain");
	register_menucmd(register_menuid("reglogmenu"), 0xFFFF, "h_reglogin");
	register_event("HLTV", "ResetPlayerChoosedTeam", "a", "1=0", "2=0");
	register_logevent("update_team_count",2,"1=Round_Start")
	fwd_loadcmd = CreateMultiForward("Load_User_Data", ET_IGNORE, FP_CELL);
	set_task(1.0, "AddPlayTime",_,_,_,"b");
	g_Maxplayers = get_maxplayers();

	g_screenfade = get_user_msgid("ScreenFade")
	set_task(1.0, "sql_active_check");

	register_dictionary("regsystem.txt");
}
public plugin_natives()
{
	register_native("sk_get_pp","native_sk_get_pp",1);
	register_native("sk_set_pp","native_sk_set_pp",1);
	register_native("sk_get_accountid","native_sk_get_accountid",1);
	register_native("sk_get_logged","native_sk_get_logged",1);
	register_native("sk_get_playtime","native_sk_get_playtime",1);
	register_native("sk_get_RegisterDate","native_sk_get_RegisterDate",1);
	register_native("get_user_adminlvl","native_get_user_adminlvl",1);
	register_native("set_user_lang","native_set_user_lang",1);
	register_native("user_next_lang","native_user_next_lang",1);
	register_native("get_user_by_accountid","native_get_user_by_accountid",1);
}

public native_user_next_lang(const index)
{
	next_lang(index, true);
}

public native_sk_get_RegisterDate(const index, regdate[], const len)
{
	param_convert(2);
	copy(regdate, len, s_Player[index][RegisterDate]);
}

public native_set_user_lang(const index, lang[])
{
	if(!is_user_connected(index))
		return;

	param_convert(2);
	s_Player[index][plangByIP] = get_enum_by_str(lang);
	if(s_Player[index][plang] == lang_types:lang_none)
	{
		s_Player[index][plang] = s_Player[index][plangByIP];
		new slang[3];
		get_lang_by_enum(s_Player[index][plangByIP], slang);
		set_user_info(index, "lang", slang);
	}
}

public native_sk_get_pp(index)
{
	return s_Player[index][PremiumPoint];
}

public native_sk_set_pp(index, amount)
{
		s_Player[index][PremiumPoint] = amount;
		return s_Player[index][PremiumPoint];
}

public native_sk_get_accountid(index)
{
	return s_Player[index][gId];
}

public native_sk_get_logged(index)
{
	return s_Player[index][Logined];
}

public native_sk_get_playtime(index)
{
	return s_Player[index][PlayTime];
}

public native_get_user_adminlvl(index)
{
	return s_Player[index][AdminL];
}


public CmdSetAdmin(id, level, cid){
	if(!str_to_num(Admin_Permissions[s_Player[id][AdminL]][2])){
	console_print(id, "%L **#1", id, "GENERAL_INSUFFICIENT_PERMISSIONS_ERROR");
	return PLUGIN_HANDLED;
	}

	new Arg1[32], Arg2[32], Arg_Int[2];
	new szName[32];
	get_user_name(id, szName, charsmax(szName));
	read_argv(1, Arg1, charsmax(Arg1));
	read_argv(2, Arg2, charsmax(Arg2));

	Arg_Int[0] = str_to_num(Arg1);
	Arg_Int[1] = str_to_num(Arg2);
	
	if(Arg_Int[0] < 1 || Arg_Int[1] >= sizeof(Admin_Permissions))
		return PLUGIN_HANDLED;	

	new Data[1];
	new Is_Online = Check_Id_Online(Arg_Int[0]);
	static Query[10048];
	
	Data[0] = id;
	
	if(m_get_server_id() == 1)
		formatex(Query, charsmax(Query), "UPDATE `herboy_regsystem` SET `AdminLvL2` = %d WHERE `id` = %d;", Arg_Int[1], Arg_Int[0]);
	else formatex(Query, charsmax(Query), "UPDATE `herboy_regsystem` SET `AdminLvL1` = %d WHERE `id` = %d;", Arg_Int[1], Arg_Int[0]);
	SQL_ThreadQuery(m_get_reg_sql(), "QuerySetAdminData", Query, Data, 1);
	
	if(Is_Online){
		if(Arg_Int[1] > 0)
			sk_chat(0, "^1Játékos: ^3%s ^1(#^3%d^1) | %s jogot kapott! ^3%s^1(#^3%d^1) által!", s_Player[Is_Online][gName], Arg_Int[0], Admin_Permissions[Arg_Int[1]][0], s_Player[id][gName], s_Player[id][gId]);	
		else
			sk_chat(0, "^1Játékos: ^3%s ^1(#^3%d^1) | Jogok megvonva! ^3%s^1(#^3%d^1) által!", s_Player[Is_Online][gName], Arg_Int[0], s_Player[id][gName], s_Player[id][gId]);	
		
		give_permission(Is_Online);
		s_Player[Is_Online][AdminL] = Arg_Int[1];
	}
	else{
		if(Arg_Int[1] > 0)
			sk_chat(0, "^1Játékos: ^3- ^1(#^3%d^1) | %s jogot kapott! ^3%s^1(#^3%d^1) által!", Arg_Int[0], Admin_Permissions[Arg_Int[1]][0], s_Player[id][gName], s_Player[id][gId]);	
		else
			sk_chat(0, "^1Játékos: ^3- ^1(#^3%d^1) | Jogok megvonva! ^3%s^1(#^3%d^1) által!", Arg_Int[0], s_Player[id][gName], s_Player[id][gId]);		
	}
		
	return PLUGIN_HANDLED;
}

public QuerySetAdminData(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime){
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) {
		log_amx("%s", Error);
		return;
	}
}
stock Check_Id_Online(id){
	for(new idx = 0; idx <= g_Maxplayers; idx++){
		if(!is_user_connected(idx))
			continue;
					
		if(s_Player[idx][gId] == id)
			return idx;
	}
	return 0;
}

public CheckMenu(id)
{
  if(AllowedForLoginPanel[id] && skbs_is_Validated(id))
  {
    if(!s_Player[id][Logined] && s_Player[id][InProgress] == 0)
      regmenu(id);
  }
  return PLUGIN_CONTINUE;
}
public Message_ShowMenu(iMsgId, iDest, pPlayer) {
	static szBuffer[32];
	get_msg_arg_string(4, szBuffer, charsmax(szBuffer));

	if (equali(szBuffer, "#Team_Select", 12)) {
		cl_ShowChooseTeam(pPlayer)
		return PLUGIN_HANDLED;
	}

	get_msg_arg_string(4, szBuffer, charsmax(szBuffer));
	if (equali(szBuffer, "#Terrorist_Select", 17) || equali(szBuffer, "#CT_Select", 10)) {
		cl_ShowChooseTeam(pPlayer)
		return PLUGIN_HANDLED;
	}

	return PLUGIN_CONTINUE;
}
public Message_VGUIMenu(iMsgId, iDest, pPlayer) 
{
	new iMenuId = get_msg_arg_int(1);

	if (iMenuId == CHOOSE_TEAM_VGUI_MENU_ID) {
		cl_ShowChooseTeam(pPlayer)
		return PLUGIN_HANDLED;
	}

	if (iMenuId == CHOOSE_TEAM1_CLASS_VGUI_MENU_ID) {
		cl_ShowChooseTeam(pPlayer)
		return PLUGIN_HANDLED;
	}

	if (iMenuId == CHOOSE_TEAM2_CLASS_VGUI_MENU_ID) {
		cl_ShowChooseTeam(pPlayer)
		return PLUGIN_HANDLED;
	}

	return PLUGIN_CONTINUE;
}
public HamHook_Player_ChangeTeam(pPlayer, iKey) {
	cl_ShowChooseTeam(pPlayer)
	return PLUGIN_HANDLED;
}
public ResetPlayerChoosedTeam()
{
	for(new id = 0 ; id < 33 ; id++) 
	{
		if(is_user_connected(id) && !is_user_bot(id))
		{
			s_Player[id][isIChoosedTeam] = false;
		} 
	}
}
new bool:bTeamChoose[33];
public cl_ShowChooseTeam(id)
{
	if(is_user_bot(id) || !is_user_connected(id))
		return;
	
	if(!s_Player[id][Logined_Print])
	{
		regmenu(id)
		return;
	}

	if(s_Player[id][isIChoosedTeam])
	{
		sk_chat(id, "%L", id, "REGSYS_ALREADY_PICKED_TEAM");
		return;
	}

	new menu = menu_create(fmt("\w[\rHerBoy\w] \y» \w%L", id, "REGSYS_TEAM_SELECTION"), "cl_ShowChooseTeam_h");

	new numAliveTR, numAliveCT, numDeadTR, numDeadCT;
	rg_initialize_player_counts(numAliveTR, numAliveCT, numDeadTR, numDeadCT);
	new CsTeams:teams = cs_get_user_team(id)

	menu_additem(menu, fmt("%s%L \r[\w%i\r]", ((can_jointeam_team(TEAM_TERRORIST) && teams != CS_TEAM_T) ? "\w" : "\d"), id, "REGSYS_JOIN_TERRORISTS", (numAliveTR+numDeadTR)), "1");
	menu_additem(menu, fmt("%s%L \r[\w%i\r]", ((can_jointeam_team(TEAM_CT) && teams != CS_TEAM_CT) ? "\w" : "\d"), id, "REGSYS_JOIN_COUNTER_TERRORISTS", (numAliveCT+numDeadCT)), "2")
	menu_addtext2(menu, "\")
	menu_addblank2(menu);
	menu_additem(menu, fmt("\w%L", id, "REGSYS_AUTO_TEAM_CHANGE"), "3");

	new spec_join = teams != CS_TEAM_SPECTATOR;
	menu_additem(menu, fmt("%s%L^n", (spec_join ? "\w" : "\d"), id, "REGSYS_JOIN_SPECTATORS"), "4", (spec_join ? 0 : ADMIN_ADMIN));
	
	menu_addtext2(menu, "\wwww.herboyd2.hu @ 2018-2024 ")

	if(teams == CS_TEAM_UNASSIGNED)
	{
		menu_setprop(menu, MPROP_PERPAGE, 0); 
		menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	}

	menu_display(id, menu, 0);

	bTeamChoose[id] = true;
}

public refresh_cl_ShowChooseTeam(id)
{
	if(!bTeamChoose[id])
		return;
	
	cl_ShowChooseTeam(id);
}

public can_jointeam_team(TeamName:target_team)
{
	new numAliveTR, numAliveCT, numDeadTR, numDeadCT;
	rg_initialize_player_counts(numAliveTR, numAliveCT, numDeadTR, numDeadCT);
	new canCjoin = ((numAliveTR + numDeadTR) - (numAliveCT + numDeadCT));

	if(target_team == TEAM_TERRORIST && 1 >= canCjoin)
		return true;
	if(target_team == TEAM_CT && -1 <= canCjoin)
		return true;
	return false;
}

public update_team_count()
{
	for(new id = 0; id < 33; id++)
	{
		if(!bTeamChoose[id] || is_user_bot(id) || !is_user_connected(id))
			continue;

		refresh_cl_ShowChooseTeam(id);
	}
}

public cl_ShowChooseTeam_h(id, menu, item){
	bTeamChoose[id] = false;
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return;
	}
	
	new data[9], szName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
	new key = str_to_num(data);
	new CsTeams:teams = cs_get_user_team(id)

	switch(key)
	{
    case 1: 
		{
			if(teams != CS_TEAM_T)
			{
				if(can_jointeam_team(TEAM_TERRORIST))
				{
					if(is_user_alive(id))
						user_silentkill(id, 1);

					set_member(id, m_iTeam, TEAM_TERRORIST);
					if(teams == CS_TEAM_UNASSIGNED || teams == CS_TEAM_SPECTATOR)
						set_member(id, m_iJoiningState, GETINTOGAME);
					else
						rg_set_user_team(id, TEAM_TERRORIST);

					s_Player[id][isIChoosedTeam] = true;
					if(s_Player[id][Logined] == 0)
						s_Player[id][Logined] = 1;

					update_team_count()
				}
				else
				{
					sk_chat(id, "%L", id, "REGSYS_TERRORIST_TEAM_FULL");
					cl_ShowChooseTeam(id);
					return;
				}
			}
			else
			{
				sk_chat(id, "%L", id, "REGSYS_ALREADY_IN_TERRORIST_TEAM")
				cl_ShowChooseTeam(id);
				return;
			}
		}
    case 2:
		{
			if(teams != CS_TEAM_CT)
			{
				if(can_jointeam_team(TEAM_CT))
				{
					if(is_user_alive(id))
						user_silentkill(id, 1);
					set_member(id, m_iTeam, TEAM_CT);

					if(teams == CS_TEAM_UNASSIGNED || teams == CS_TEAM_SPECTATOR)
						set_member(id, m_iJoiningState, GETINTOGAME);
					else
						rg_set_user_team(id, TEAM_CT);

					s_Player[id][isIChoosedTeam] = true;

					if(s_Player[id][Logined] == 0)
						s_Player[id][Logined] = 1;

					update_team_count()
				}
				else
				{
					sk_chat(id, "%L", id, "REGSYS_COUNTER_TERRORIST_TEAM_FULL");
					cl_ShowChooseTeam(id);
					return;
				}
			}
			else
			{
				sk_chat(id, "%L", id, "REGSYS_ALREADY_IN_COUNTER_TERRORIST_TEAM")
				cl_ShowChooseTeam(id);
				return;
			}
		}
		case 3: 
		{
			if(is_user_alive(id))
				user_silentkill(id, 1);
			new iRandomTeam = random_num(1, 2)	
			if(iRandomTeam == 1 && can_jointeam_team(TEAM_TERRORIST))
			{
				if(teams == CS_TEAM_UNASSIGNED || teams == CS_TEAM_SPECTATOR)
				{
					set_member(id, m_iTeam, TEAM_TERRORIST);
					set_member(id, m_iJoiningState, GETINTOGAME);
				}
				else
					rg_set_user_team(id, TEAM_TERRORIST);
			}
			else
			{
				if(teams == CS_TEAM_UNASSIGNED || teams == CS_TEAM_SPECTATOR)
				{
					set_member(id, m_iTeam, TEAM_CT);
					set_member(id, m_iJoiningState, GETINTOGAME);
				}
				else
					rg_set_user_team(id, TEAM_CT);
			}

			if(s_Player[id][Logined] == 0)
				s_Player[id][Logined] = 1;

			s_Player[id][isIChoosedTeam] = true;
			update_team_count()
		}

		case 4:
		{ 
			if(teams != CS_TEAM_UNASSIGNED)
			{
				user_silentkill(id, 1);
				rg_set_user_team(id, TEAM_SPECTATOR);
			}
			else
			{
				if(s_Player[id][Logined] == 0)
					s_Player[id][Logined] = 1;
				rg_join_team(id, TEAM_SPECTATOR)
			}	
		}
	}


}
static FrameCall;
public server_frame()
{
  if(FrameCall < 400)
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
    if(!s_Player[id][Logined] || cs_get_user_team(id) == CS_TEAM_UNASSIGNED)
    {
      if(!skbs_is_Validated(id))
        client_print(id, print_center, "%L", id, "REGSYS_WAIT_FOR_CLIENT");
      else if(s_Player[id][InProgress] == 4)
        client_print(id, print_center, "%L", id, "REGSYS_LOGIN_STATUS");
      else if(!s_Player[id][Logined_Print])
        client_print(id, print_center, "%L", id, "REGSYS_REGISTER_LOGIN_PROMPT");
      else 
        client_print(id, print_center, "%L", id, "REGSYS_SELECT_TEAM_PROMPT");

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
public skbs_user_validated_success(id)
{
	set_task(random_float(0.5, 2.5), "task_validated_successfully", id+VALIDATED_TASK_OFFSET);
}

public task_validated_successfully(id)
{
	if(task_exists(id))
		remove_task(id);
	id -= VALIDATED_TASK_OFFSET;

	AllowedForLoginPanel[id] = 1;
	sk_chat(id, "%L", id, "REGSYS_READY_TO_LOGIN_OR_REGISTER");
	skbs_get_UniqueKey32(id, s_Player[id][LoginKey], charsmax(s_Player[][LoginKey]));
	if(s_Player[id][LoginKey][0] != EOS)
		SQL_LoadUserAccount(id, 1);
	else
	{
		regmenu(id);
	}
}

public AddPlayTime()
{
	new p[32],n;
	get_players(p,n,"ch");
	for(new i=0;i<n;i++)
	{
		new id = p[i];
		if(s_Player[id][Logined])
			s_Player[id][PlayTime]++;
	}
} 
public regmenu(id)
{   
	if(!skbs_is_Validated(id))
		return PLUGIN_HANDLED;

	if(s_Player[id][plang] == lang_types:lang_none)
	{
		new slang[3];
		get_lang_by_enum(s_Player[id][plangByIP], slang);
		set_user_info(id, "lang", slang);
	}
	else
	{
		new slang[3];
		get_lang_by_enum(s_Player[id][plang], slang);
		set_user_info(id, "lang", slang);
	}
	if(s_Player[id][InProgress] > 0 || s_Player[id][Logined_Print] == 1)
    return PLUGIN_HANDLED;

	s_Player[id][gProgress] = 0;
	new Menu[512], MenuKey;
	add(Menu, 511, fmt("[\rHerBoy\w] \y» ^n\w%L!^n^n", id, "REGSYS_REGISTER_PROMPT"));
	if(!s_Player[id][IsHaveAccount])
		add(Menu, 511, fmt("\w[\r1\w] \r%L^n", id, "REGSYS_REGISTER"));
	else add(Menu, 511, fmt("\d[\d1\d] \d%L^n", id, "REGSYS_REGISTER_ACCOUNT_PROMPT"));

	add(Menu, 511, fmt("\w[\r2\w] \y%L^n", id, "REGSYS_LOGIN"));
	add(Menu, 511, fmt("\w[\r3\w] \w%L^n^n", id, "REGSYS_FORGOT_PASSWORD"));

	
	new currlang[3];
	get_user_info(id, "lang", currlang, charsmax(currlang));
	strtoupper(currlang);
	add(Menu, 511, fmt("\w[\r4\w] \w%L^n", id, "REGSYS_LANGUAGE", currlang));


	add(Menu, 511, fmt("\wMagyar | English | Română | Slovenský^n"));
	add(Menu, 511, fmt("\wSrpski | Deutsch | Ukraïns'ka^n"));
	
	if(!s_Player[id][IsHaveAccount])
		add(Menu, 511, fmt("^n\yAdatörlés volt 11.20-án! Regisztrálj újra!^n"));
	
	add(Menu, 511, fmt("^n\wwww.herboyd2.hu @ 2018-2024^n^n"));

	MenuKey = (1<<0 | 1<<1 | 1<<2 | 1<<3 | 1<<4 | 1<<5 | 1<<6 | 1<<7 | 1<<8 | 1<<9);
	show_menu(id, MenuKey, Menu, -1, "REGMAIN");
	return PLUGIN_CONTINUE;
}

public hRegmain(id, MenuKey)
{
	MenuKey++;
	switch(MenuKey)
	{
		case 1: 
		{
			if(s_Player[id][IsHaveAccount] == 0)
			{
				s_Player[id][gProgress] = 1;
				regloginmenu(id, 1);
			}
			else 
			{
				sk_chat(id, "%L", id, "REGSYS_ACCOUNT_EXISTS_NOTICE");
				client_cmd(id, "spk events/friend_died.wav");
				regmenu(id);
			}
		}
		case 2: 
		{
			s_Player[id][gProgress] = 2;
			regloginmenu(id, 2);
		}
		case 3:
		{
			sk_chat(id, "%L ^4www.herboyd2.hu/forgetpassword", id, "REGSYS_FORGOT_PASSWORD_LINK");
			sk_chat(id, "%L", id, "REGSYS_FOUND_ACCOUNT_USERNAME", s_Player[id][HelpUsername]);
			regmenu(id);
		}
		case 4:
		{
			if(s_Player[id][plang] == lang_types:lang_none)
				s_Player[id][plang] = s_Player[id][plangByIP];
			next_lang(id, false);
			regmenu(id);
		}
		default: 
		{
			regmenu(id);
		}
	}
}

public regloginmenu(id, reg_type)
{
	if(s_Player[id][Logined_Print] == 1)
		return PLUGIN_HANDLED;

	new Menu[512], MenuKey;
	add(Menu, 511, fmt("[\rHerBoy\w] \y» ^n\w%L^n^n", id, "REGSYS_REGISTER_PROMPT_REQUIRED"));

	add(Menu, 511, fmt("\w[\r1\w] \w%L\r*: \r%s^n", id, "REGSYS_USERNAME", s_Player[id][gUsername]));
	add(Menu, 511, fmt("\w[\r2\w] \w%L\r*: \r%s^n", id, "REGSYS_PASSWORD", s_Player[id][gPassword]));
	if(reg_type == 1)
	{
		add(Menu, 511, fmt("\w[\r3\w] \w%L\r*: \r%s^n", id, "REGSYS_PASSWORD_AGAIN", s_Player[id][gPasswordAgain]));
		add(Menu, 511, fmt("\w[\r4\w] \w%L\r*: \r%s^n", id, "REGSYS_EMAIL", s_Player[id][gEmail]));
		add(Menu, 511, fmt("\d[ \y@ \d] %L^n^n", id, "REGSYS_ALT_KEY_COMBINATION"));
		
		
		add(Menu, 511, fmt("\r%L^n", id, "REGSYS_REGISTER_ACCEPT_POLICY"));
		if(!s_Player[id][IsHaveAccount])
			add(Menu, 511, fmt("\w[\r5\w] \y%L^n", id, "REGSYS_REGISTER"));
		else add(Menu, 511, fmt("\d[\d5\d] \d%L^n", id, "REGSYS_REGISTER_ACCOUNT_PROMPT"));
	}
	if(reg_type == 2)
	{
		add(Menu, 511, fmt("\r^n%L!^n", id, "REGSYS_ACCEPT_POLICY"));
		add(Menu, 511, fmt("\w[\r3\w] \y%L^n", id, "REGSYS_LOGIN"));
	}

	add(Menu, 511, fmt("^n\wwww.herboyd2.hu @ 2018-2024^n^n"));
	if(reg_type == 1 || reg_type == 2)
		add(Menu, 511, fmt("\w[\r0\w] \r%L.^n", id, "REGSYS_BACK_TO_MAIN"));

	MenuKey = (1<<0 | 1<<1 | 1<<2 | 1<<3 | 1<<4 | 1<<5 | 1<<6 | 1<<7 | 1<<8 | 1<<9);
	show_menu(id, MenuKey, Menu, -1, "reglogmenu");
	return PLUGIN_CONTINUE;
}

public h_reglogin(id, MenuKey)
{
		//new m_joinstate = get_member(id, m_iJoiningState);
		MenuKey++;
		switch(MenuKey)
		{
				case 1: 
				{
					client_cmd(id, "messagemode Felhasznalonev");
					regloginmenu(id, s_Player[id][gProgress]);
				}
				case 2: 
				{
					client_cmd(id, "messagemode Jelszo");
					regloginmenu(id, s_Player[id][gProgress]);
				}
				case 3: 
				{
						if(s_Player[id][gProgress] == 1)
						{
							regloginmenu(id, s_Player[id][gProgress]);
							client_cmd(id, "messagemode JelszoUjra");
						}
								
						else if(s_Player[id][gProgress] == 2)
								Login(id);
				}
				case 4: 
				{
						if(s_Player[id][gProgress] == 1)
						{
							sk_chat(id, "%L", id, "REGSYS_WRITE_AT_SYMBOL")
							regloginmenu(id, s_Player[id][gProgress]);
							client_cmd(id, "messagemode Email");
						}
								
						else if(s_Player[id][gProgress] == 2)
								regloginmenu(id, 2);
				}
				case 5: 
				{
					if(s_Player[id][gProgress] == 1)
					{
						if(s_Player[id][IsHaveAccount] == 0)
						{
							Register(id);
						}
						else
						{
							sk_chat(id, "%L", id, "REGSYS_ACCOUNT_EXISTS_NOTICE")
							client_cmd(id, "spk events/friend_died.wav")
							regmenu(id)
						}
					}
					else if(s_Player[id][gProgress] == 2)
						regloginmenu(id, 2)
				}
				case 7..9:
				{
						if(s_Player[id][gProgress] == 1)
								regloginmenu(id, 1);
						else if(s_Player[id][gProgress] == 2)
								regloginmenu(id, 2);
				}
				default: 
				{
						regmenu(id);
				}
		}
}

public set_username(id)
{
		if(s_Player[id][Logined])
				return;

		new Arg[32];
		read_argv(1, Arg, charsmax(Arg));

		if(!(RegexTester(id, Arg, "^^[a-zA-Z0-9]{4,16}+$", fmt("%L", id, "REGSYS_USERNAME_REQUIREMENTS"))))
		{
			client_cmd(id, "spk events/friend_died.wav")
			regloginmenu(id, s_Player[id][gProgress]);
			return;
		}

		copy(s_Player[id][gUsername], 32, Arg);
		regloginmenu(id, s_Player[id][gProgress]);
}

public set_password(id)
{
	if(s_Player[id][Logined])
		return;

	new Arg[HASHSIZE];
	read_argv(1, Arg, charsmax(Arg));
	if(!(RegexTester(id, Arg, "^^[a-zA-Z0-9]{4,32}+$", fmt("%L", id, "REGSYS_PASSWORD_REQUIREMENTS"))))
	{
		client_cmd(id, "spk events/friend_died.wav")
		regloginmenu(id, s_Player[id][gProgress]);
		return;
	}
	else
	{
		copy(s_Player[id][gPassword], 32, Arg);
		new hash[HASHSIZE];

		formatex(Arg[strlen(Arg)], HASHSIZE, "%s", SALT);
		hash_string(Arg, Hash_Sha3_512, hash, charsmax(hash))
		hash_string(hash, Hash_Sha3_512, hash, charsmax(hash))
		copy(s_Player[id][gPasswordHash], charsmax(hash), hash)
	}
	regloginmenu(id, s_Player[id][gProgress]);
}

public set_passwordAgain(id)
{
	if(s_Player[id][Logined])
		return;


	new Arg[32];
	read_argv(1, Arg, charsmax(Arg));

	if(!(RegexTester(id, Arg, "^^[a-zA-Z0-9]{4,32}+$", fmt("%L", id, "REGSYS_PASSWORD_REQUIREMENTS"))))
	{
		client_cmd(id, "spk events/friend_died.wav")
		regloginmenu(id, 1) 
		return;
	}	
	copy(s_Player[id][gPasswordAgain], 32, Arg);
	regloginmenu(id, 1) 
}

public set_email(id)
{
	if(s_Player[id][Logined])
		return;
	
	new Arg[63];
	read_argv(1, Arg, charsmax(Arg));
	if(!(RegexTester(id, Arg, "^^[-+_.a-zA-Z0-9]{1,63}+@(herboy|gmail|freemail|yahoo|outlook|icloud|proton|tutanota|mail|gmx|posteo|zoho|citromail)\.(hu|com|de|me)$", fmt("%L", id, "REGSYS_EMAIL_REJECTION"))))
	{
		client_cmd(id, "spk events/friend_died.wav")
		regloginmenu(id, 1);
		return;
	}
	else
		copy(s_Player[id][gEmail], 64, Arg);
	regloginmenu(id, 1);
}

public Register(id)
{
	if(equal(s_Player[id][gUsername], "") || equal(s_Player[id][gPassword],""))
	{
		client_cmd(id, "spk events/friend_died.wav")
		sk_chat(id, "%L", id, "REGSYS_REGISTRATION_INCOMPLETE");
		regloginmenu(id, 1);
		return;
	}
	if(equal(s_Player[id][gEmail], ""))
	{
		client_cmd(id, "spk events/friend_died.wav")
		sk_chat(id, "%L", id, "REGSYS_EMAIL_IS_REQUIRED");
		regloginmenu(id, 1);
		return;
	}
	if(!equal(s_Player[id][gPassword], s_Player[id][gPasswordAgain]))
	{
		client_cmd(id, "spk events/friend_died.wav")
		sk_chat(id, "%L", id, "REGSYS_PASSWORDS_DO_NOT_MATCH");
		regloginmenu(id, 1);
		return;
	}
	else
	{
		sk_chat(id, "%L", id, "REGSYS_REGISTRATION_IN_PROGRESS");
		s_Player[id][InProgress] = 1;
		SQL_CheckAccount(id, 1);
	}
}

public Login(id)
{
	if(equali(s_Player[id][gUsername], "") || equali(s_Player[id][gPassword],""))
	{
		client_cmd(id, "spk events/friend_died.wav")
		sk_chat(id, "%L", id, "REGSYS_LOGIN_INCOMPLETE");
		regloginmenu(id, 2);
		return;
	}
	else
	{
		sk_chat(id, "%L", id, "REGSYS_LOGIN_IN_PROGRESS");
		s_Player[id][InProgress] = 1;
		SQL_CheckAccount(id, 2);
	}
}

public SQL_CheckAccount(id, logreg)
{
	static Query[20048];
	new Data[2];
	Data[0] = id;
	Data[1] = logreg;
	formatex(Query, charsmax(Query), "SELECT Username FROM `herboy_regsystem` WHERE `Username` = ^"%s^" LIMIT 1;", s_Player[id][gUsername]);
	SQL_ThreadQuery(m_get_reg_sql(), "Query_CheckAccount", Query, Data, 2);
}

public SQL_CheckEmail(id, logreg)
{
	static Query[20048];
	new Data[2];
	Data[0] = id;
	Data[1] = logreg;
	formatex(Query, charsmax(Query), "SELECT Email FROM `herboy_regsystem` WHERE `Email` = ^"%s^" LIMIT 1;", s_Player[id][gEmail]);
	SQL_ThreadQuery(m_get_reg_sql(), "Query_CheckAccount", Query, Data, 2);
}

public Query_CheckAccount(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime) {
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) {
		log_amx("%s", Error);
		set_fail_state("* Hibas lekerdezes itt, SQL Check Account: %s", Error);
		return;
	}
	else {
		new id = Data[0];
		new RegOrLogin = Data[1];
		
		new AccountFound = SQL_NumRows(Query);
		if(RegOrLogin == 1)
		{
			if(AccountFound)
			{
				client_cmd(id, "spk events/friend_died.wav")
				sk_chat(id, "%L", id, "REGSYS_USERNAME_ALREADY_REGISTERED");
				s_Player[id][InProgress] = 0;
				regloginmenu(id, 1);
				return;
			}
			else if(!equal(s_Player[id][gEmail], "")) SQL_CheckEmail(id, 3);
			else{
				if(IsAllowedForReRegister[id] == 1)
					SQL_CreateUserAccount_old(id);
			}

		}
		else if(RegOrLogin == 2)
		{
			if(!AccountFound)
			{
				client_cmd(id, "spk events/friend_died.wav")
				sk_chat(id, "%L", id, "REGSYS_INVALID_CREDENTIALS_OR_NO_ACCOUNT");
				s_Player[id][InProgress] = 0;
				regloginmenu(id, 2);
				return;
			}
			else SQL_LoadUserAccount(id, 0)
		}
		else if(RegOrLogin == 3)
		{
			if(AccountFound)
			{
				client_cmd(id, "spk events/friend_died.wav")
				sk_chat(id, "%L", id, "REGSYS_EMAIL_ALREADY_REGISTERED");
				s_Player[id][InProgress] = 0;
				regloginmenu(id, 1);
				return;
			}
			else 
			{
				if(IsAllowedForReRegister[id] == 1)
					SQL_CreateUserAccount_old(id);
			}
		}
	}
}

public SQL_CreateUserAccount_old(id)
{
	static Query[20048];
	new Data[1];
	Data[0] = id;
	new sTime[64];
	formatCurrentDateAndTime(sTime, charsmax(sTime));
	formatex(Query, charsmax(Query), "INSERT INTO `herboy_regsystem` (`Username`, `Password`, `Email`, `RegisterName`, `RegisterIP`, `RegisterID`, `RegisterDate`, `plang`) VALUES (^"%s^", ^"%s^",^"%s^",^"%s^",^"%s^",^"%s^",^"%s^", %i)", s_Player[id][gUsername], s_Player[id][gPasswordHash], s_Player[id][gEmail], s_Player[id][gName],s_Player[id][gIP], s_Player[id][gSteamID], sTime, s_Player[id][plang]);
	
	SQL_ThreadQuery(m_get_reg_sql(), "Query_CreateUserAccount_old", Query, Data, 2);
} 
public Query_CreateUserAccount_old(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime) {
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) {
		if(contain(Error, "Duplicate entry") == -1)
		{
			new id = Data[0];	
			log_amx("%s", Error);
			SQL_CreateUserAccount_old(id);
		}
		return;
	}
	else {
		new id = Data[0];	
		new getsqlid = SQL_GetInsertId(Query);
		if(callfunc_begin("send_register_email", "EzSck.amxx") == 1)
		{
			callfunc_push_int(getsqlid)
			callfunc_end()
		}
		sk_chat(id, "%L ^4%s", id, "REGSYS_REGISTRATION_SUCCESS", s_Player[id][gUsername]);
		s_Player[id][InProgress] = 0;
		s_Player[id][gUsername][0] = EOS;
		s_Player[id][gPassword][0] = EOS;
		s_Player[id][gProgress] = 2;
		s_Player[id][IsHaveAccount] = 1;
		regloginmenu(id, 2);
	}
}
public SQL_LoadUserAccount(id, fastlogin)
{
	static Query[20048];
	new Data[2];
	Data[0] = id;
	Data[1] = fastlogin;

	if(fastlogin == 0)
		formatex(Query, charsmax(Query), "SELECT * FROM herboy_regsystem WHERE Username = ^"%s^" AND Password = ^"%s^" LIMIT 1;", s_Player[id][gUsername], s_Player[id][gPasswordHash]);
	else
		formatex(Query, charsmax(Query), "SELECT * FROM herboy_regsystem WHERE LoginKey = ^"%s^" LIMIT 1;", s_Player[id][LoginKey]);

	SQL_ThreadQuery(m_get_reg_sql(), "Query_LoadUserAccount", Query, Data, 2);
}

public Query_LoadUserAccount(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime) {
	new isfastlogined = Data[1];
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) {
		log_amx("%s", Error);
		set_fail_state("* Hibas lekerdezes itt, SQL Create Acco unt: %s", Error);
		return;
	}
	else 
	{
		new id = Data[0];
		if(SQL_NumRows(Query) > 0) 
		{
			new lastloginedsteamid[33], sElapse[33], sBy[33], sStart[33], sReason[100], sBanned;
			s_Player[id][gId] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "id"));
			sBanned = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "uac_banned"));
			SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Username"), s_Player[id][gUsername], 33);
			SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "LastLoginID"), lastloginedsteamid, 33);
			if(isfastlogined == 1)
			{
				sk_chat(id, "%L", id, "REGSYS_AUTO_LOGIN_IN_PROGRESS");
			}
			s_Player[id][InProgress] = 4;
			
			SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "RegisterDate"), s_Player[id][RegisterDate], 33);
			s_Player[id][PremiumPoint] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "PremiumPoint"));
			s_Player[id][Active] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Active"));
			s_Player[id][PlayTime] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "PlayTime"));
			if(m_get_server_id() == 1)
				s_Player[id][AdminL] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "AdminLvL2"));
			else
				s_Player[id][AdminL] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "AdminLvL1"));
			s_Player[id][plang] = lang_types:SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "plang"));
			if(s_Player[id][plang] != lang_types:lang_none)
			{
				new slang[3];
				get_lang_by_enum(s_Player[id][plang], slang);
				set_user_info(id, "lang", slang);
			}
			if(sBanned == 1)
			{
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "uac_bannedby"), sBy, 33);
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "uac_elapse"), sElapse, 33);
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "uac_started"), sStart, 33);
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "uac_reason"), sReason, 100);
				client_cmd(id, "spk events/friend_died.wav")
				sk_chat(id, "%L", id, "REGSYS_BANNED_ACCOUNT_CONTACT", s_Player[id][gUsername], s_Player[id][gId]);
				sk_chat(id, "%L ^4%s", id, "REGSYS_BAN_DETAILS", sBy, sStart, sElapse);
				sk_chat(id, "%L ^4%s", id, "REGSYS_BAN_REASON", sReason);
				sk_chat(id, "%L ^3[ ^4https://www.facebook.com/groups/herboyonlyd2 ^3]", id, "REGSYS_CONTACT_FACEBOOK");
				sk_chat(id, "%L ^3[ ^4discord.gg/herboyd2 ^3]", id, "REGSYS_CONTACT_DISCORD");
				Update_LastLogins(id, 1);
				s_Player[id][gUsername][0] = EOS;
				s_Player[id][gPassword][0] = EOS;
				s_Player[id][gPasswordAgain][0] = EOS;
				s_Player[id][gPasswordHash][0] = EOS;
				s_Player[id][RegisterDate][0] = EOS;
				s_Player[id][gEmail][0] = EOS;
				s_Player[id][Active] = 0;
				s_Player[id][AdminL] = 0;
				s_Player[id][Logined] = 0;
				s_Player[id][InProgress] = 0;
				s_Player[id][SwitchedTeam] = 0;
				s_Player[id][PlayTime] = 0;
				s_Player[id][PremiumPoint] = 0;
				IsAllowedForReRegister[id] = 1;
				s_Player[id][plang] = lang_types:lang_none;
				CheckMenu(id);
				return;
			}
			if(s_Player[id][Active] > 0 && !equal(s_Player[id][gSteamID], lastloginedsteamid))
			{
				client_cmd(id, "spk events/friend_died.wav")
				sk_chat(id, "%L ^4%s", id, "REGSYS_ACCOUNT_ALREADY_LOGGED_IN", ServerMan[m_get_server_id()][server_type]);
				regloginmenu(id, 2);
				s_Player[id][InProgress] = 0;
				return;
			}
			if(!equal(s_Player[id][gSteamID], lastloginedsteamid) && isfastlogined) 
			{
				Update_LastLogins(id, 1);
				SQL_InsertLogin(id, 2);
				sk_chat(id, "%L", id, "REGSYS_LOGOUT_MISMATCHED_STEAMID", s_Player[id][gUsername], s_Player[id][gId]);
				client_cmd(id, "spk events/friend_died.wav")
				s_Player[id][gUsername][0] = EOS;
				s_Player[id][gPassword][0] = EOS;
				s_Player[id][gPasswordAgain][0] = EOS;
				s_Player[id][gPasswordHash][0] = EOS;
				s_Player[id][gEmail][0] = EOS;
				s_Player[id][Active] = 0;
				s_Player[id][Logined] = 0;
				s_Player[id][InProgress] = 0;
				s_Player[id][SwitchedTeam] = 0;
				s_Player[id][PlayTime] = 0;
				s_Player[id][PremiumPoint] = 0;
				IsAllowedForReRegister[id] = 1;
				s_Player[id][plang] = lang_types:lang_none;
				CheckMenu(id);
				return;
			}
			new fwdloadtestret;
			ExecuteForward(fwd_loadcmd,fwdloadtestret, id);
			new sTime[64];
			formatCurrentDateAndTime(sTime, charsmax(sTime));
			client_cmd(id, "spk Herboynew/hello")
		}
		else
		{
			if(isfastlogined == 0)
				SQL_InsertLogin(id, 1);
			client_cmd(id, "spk events/friend_died.wav")
			sk_chat(id, "%L", id, "REGSYS_INVALID_CREDENTIALS_OR_NO_ACCOUNT");
			s_Player[id][InProgress] = 0;
			regmenu(id);
			return;
		}
	}
}

public LoggedSuccesfully(id)
{
	s_Player[id][Active] = m_get_server_id();
	s_Player[id][InProgress] = 0;
	s_Player[id][Logined_Print] = 1;
	IsAllowedForReRegister[id] = 0;
	show_menu(id, 0, "^n", 1);
	Update_LastLogins(id, 0);
	SQL_InsertLogin(id, 0);
	cl_ShowChooseTeam(id)
	Demo(id);
	sk_chat(id, "%L", id, "REGSYS_LOGIN_SUCCESS", s_Player[id][gUsername], s_Player[id][gId], ServerMan[m_get_server_id()][server_type], ServerMan[m_get_server_id()][server_id]);
	give_permission(id);

	new sTime[64];
	formatCurrentDateAndTime(sTime, charsmax(sTime));

}
public give_permission(id){
	new Flags;
	Flags = read_flags(Admin_Permissions[s_Player[id][AdminL]][1]);
	set_user_flags(id, Flags);
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
public SQL_InsertLogin(id, isFail)
{
	static Query[20048];
	new Data[1];
	Data[0] = id;
	new sTime[64];
	formatCurrentDateAndTime(sTime, charsmax(sTime));

	formatex(Query, charsmax(Query), "INSERT INTO `herboy_reglogin_log` (`username`, `name`, `steamid`, `ipaddress`, `datetime`, `userid`, `LoginKey`, `LoggedServer`, `failed`) VALUES (^"%s^", ^"%s^",^"%s^",^"%s^",^"%s^",^"%i^", ^"%s^",^"%i^",^"%i^")", s_Player[id][gUsername], s_Player[id][gName], s_Player[id][gSteamID], s_Player[id][gIP], sTime, s_Player[id][gId], s_Player[id][LoginKey], m_get_server_id(), isFail);
	SQL_ThreadQuery(m_get_reg_sql(), "Query_InsertLoginLog", Query, Data, 2);
}

public Query_InsertLoginLog(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime) {
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) {
		log_amx("%s", Error);
		set_fail_state("* Hibas lekerdezes itt, SQL Login Log: %s", Error);
		return;
	}
}

public Update_LastLogins(id, delautolog)
{
		static Query[20048];
		new Len;
		new sTime[64];
		formatCurrentDateAndTime(sTime, charsmax(sTime));

		Len += formatex(Query[Len], charsmax(Query), "UPDATE `herboy_regsystem` SET ");
		if(!delautolog)
		{
			Len += formatex(Query[Len], charsmax(Query)-Len, "LastLoginID = ^"%s^", ", s_Player[id][gSteamID]);
			Len += formatex(Query[Len], charsmax(Query)-Len, "LastLoginIP = ^"%s^", ", s_Player[id][gIP]);
			Len += formatex(Query[Len], charsmax(Query)-Len, "LastLoginIP = ^"%s^", ", s_Player[id][gIP]);
			Len += formatex(Query[Len], charsmax(Query)-Len, "LastLoginName = ^"%s^", ", s_Player[id][gName]);
			Len += formatex(Query[Len], charsmax(Query)-Len, "LastLoginDate = ^"%s^", ", sTime);
			Len += formatex(Query[Len], charsmax(Query)-Len, "LastLoggedOn = ^"%i^", ", m_get_server_id());
		}

		Len += formatex(Query[Len], charsmax(Query)-Len, "plang = ^"%i^", ", (s_Player[id][plang] == lang_types:lang_none ? s_Player[id][plangByIP] : s_Player[id][plang]) );

		if(!delautolog)
			Len += formatex(Query[Len], charsmax(Query)-Len, "LoginKey = ^"%s^", ", s_Player[id][LoginKey]);
		else
			Len += formatex(Query[Len], charsmax(Query)-Len, "LoginKey = ^"0^", ");

		if(!delautolog)
			Len += formatex(Query[Len], charsmax(Query)-Len, "Active = %i ", s_Player[id][Active]);
		else
			Len += formatex(Query[Len], charsmax(Query)-Len, "Active = 0 ");
		
		Len += formatex(Query[Len], charsmax(Query)-Len, "WHERE `id` =	%d;", s_Player[id][gId]);

		SQL_ThreadQuery(m_get_reg_sql(), "QueryUpdateLastLogins", Query);
}

public Update_Disconnect(id)
{
		static Query[20048];
		new Len;
		new sTime[64];
		formatCurrentDateAndTime(sTime, charsmax(sTime));

		Len += formatex(Query[Len], charsmax(Query), "UPDATE `herboy_regsystem` SET ");
		Len += formatex(Query[Len], charsmax(Query)-Len, "Active = 0, ");
		Len += formatex(Query[Len], charsmax(Query)-Len, "PlayTime = ^"%i^", ", s_Player[id][PlayTime]);
		Len += formatex(Query[Len], charsmax(Query)-Len, "PremiumPoint = ^"%i^", ", s_Player[id][PremiumPoint]);
		Len += formatex(Query[Len], charsmax(Query)-Len, "plang = ^"%i^" ", (s_Player[id][plang] == lang_types:lang_none ? s_Player[id][plangByIP] : s_Player[id][plang]) );
		Len += formatex(Query[Len], charsmax(Query)-Len, "WHERE `id` =	%d;", s_Player[id][gId]);
		
		SQL_ThreadQuery(m_get_reg_sql(), "QueryUpdateLastLogins", Query);
}

public QueryUpdateLastLogins(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime)
{

	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) 
	{
		log_amx("Errsor fro m Profillles:");
		log_amx("%s", Error);
		return;
	}
}

public mod_mapchange()
{
	static Query[1024];
	formatex(Query[0], charsmax(Query), "UPDATE `herboy_regsystem` SET Active = 0 WHERE Active = %i;", m_get_server_id());
	log_amx("Szerver aktivitási érték a %i szervernek át lett állítva 0-ra", m_get_server_id());
	SQL_ThreadQuery(m_get_reg_sql(), "QueryUpdateActiveFix", Query);
}

public QueryUpdateActiveFix(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime)
{
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) 
	{
		log_amx("Errsor fro m Mapchange ActiveFix:");
		log_amx("%s", Error);
		return;
	}
	log_amx("Szerver aktivitási érték a %i szervernek át lett állítva 0-ra (100%)", m_get_server_id());
}

public client_disconnected(id)
{
		if(is_user_bot(id) || is_user_hltv(id) || !is_user_connected(id))
				return;

		if(s_Player[id][Logined] || s_Player[id][Logined_Print])
				Update_Disconnect(id);
		s_Player[id][PlayTime] = 0;
}

public client_putinserver(id)
{
		if(is_user_bot(id) || is_user_hltv(id) || !is_user_connected(id))
				return;

		set_member(id, m_iJoiningState, JOINED);
		get_user_name(id, s_Player[id][gName], 33);
		get_user_authid(id, s_Player[id][gSteamID], 33);
		get_user_ip(id, s_Player[id][gIP], 33, 1);
		s_Player[id][gUsername][0] = EOS;
		s_Player[id][gPassword][0] = EOS;
		s_Player[id][HelpEmail][0] = EOS;
		s_Player[id][HelpUsername][0] = EOS;
		s_Player[id][gPasswordAgain][0] = EOS;
		s_Player[id][gPasswordHash][0] = EOS;
		s_Player[id][gEmail][0] = EOS;
		IsAllowedForReRegister[id] = 1;
		s_Player[id][Active] = 0;
		AllowedForLoginPanel[id] = 0;
		s_Player[id][Logined] = 0;
		s_Player[id][InProgress] = 0;
		s_Player[id][SwitchedTeam] = 0;
		s_Player[id][PremiumPoint] = 0;
		s_Player[id][AdminL] = 0;
		s_Player[id][gId] = 0;
		s_Player[id][plang] = lang_types:lang_none;
		s_Player[id][plangByIP] = lang_types:lang_none;
		s_Player[id][isIChoosedTeam] = false;
		s_Player[id][IsHaveAccount] = 0;
		s_Player[id][Logined_Print] = 0;
		s_Player[id][HelpUsername][0] = EOS;
		s_Player[id][HelpEmail][0] = EOS; 
		if(task_exists(id+VALIDATED_TASK_OFFSET))
			remove_task(id+VALIDATED_TASK_OFFSET);


		SQL_CheckSteamIDAccount(id);
}
public SQL_CheckSteamIDAccount(id)
{
  static Query[20048];
  new Data[1];
  Data[0] = id;

  formatex(Query, charsmax(Query), "SELECT * FROM `herboy_regsystem` WHERE RegisterID = ^"%s^" LIMIT 1;", s_Player[id][gSteamID])
  SQL_ThreadQuery(m_get_reg_sql(), "SQL_CheckSteamIDAccount_h", Query, Data, 1);
}
public SQL_CheckSteamIDAccount_h(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime)
{
  if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED)
  {
    log_amx("%s", Error);
    set_fail_state("* Hibas lekerdezes itt, SQL_CheckSteamIDAccount_h: %s", Error)
    return;
  }
  else
  {
    new id = Data[0];
    
    if(SQL_NumRows(Query) > 0)
    {
			SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Username"), s_Player[id][HelpUsername], 33);
			SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Email"), s_Player[id][HelpEmail], 33);
			s_Player[id][IsHaveAccount] = 1;
    }
    else s_Player[id][IsHaveAccount] = 0;
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

public Demo(id){
		new map[32];
		get_mapname(map, sizeof (map));
		new sTime[64];
		formatCurrentDateAndTime(sTime, charsmax(sTime));
		client_cmd(id, "stop;record %s", (m_get_server_id() == 1 ? "avatarfun_demo" : "herboyd2_demo"));
		sk_chat(id, "%L", id, "REGSYS_DEMO_RECORDING", (m_get_server_id() == 1 ? "avatarfun_demo.dem" : "herboyd2_demo.dem"));
		sk_chat(id, "%L", id, "REGSYS_DEMO_DETAILS", map, sTime);
		
		if(task_exists(id+DEMO_TASK_DETAIL))
				remove_task(id+DEMO_TASK_DETAIL);
		
		set_task(10.0, "DemoDetail", id+DEMO_TASK_DETAIL);

}

public DemoDetail(id){
	id -= DEMO_TASK_DETAIL;
	
	new user_message[64];
	formatex(user_message,charsmax(user_message),"%s%i","HRBY:ID:", s_Player[id][gId]);
	write_demo_info(id, user_message);
	formatex(user_message,charsmax(user_message),"%s%s","HRBY:KEY:", s_Player[id][LoginKey]);
	write_demo_info(id, user_message);
}

public sql_active_check(){
	static Query[10048];
	new Len;

	Len += formatex(Query[Len], charsmax(Query), "UPDATE herboy_regsystem SET ");
	Len += formatex(Query[Len], charsmax(Query)-Len, "Active = 0 ");
	Len += formatex(Query[Len], charsmax(Query)-Len, "WHERE Active = %i", m_get_server_id());
	
	SQL_ThreadQuery(m_get_reg_sql(), "sql_active_check_thread", Query);
}
public sql_active_check_thread(FailState,Handle:Query,Error[],Errcode,Data[],DataSize)
{
	if(FailState == TQUERY_CONNECT_FAILED)
		return set_fail_state("[ *HIBA* ] NEM LEHET KAPCSOLODNI AZ ADATBAZISHOZ!");
	else if(FailState == TQUERY_QUERY_FAILED)
		return set_fail_state("[ *HIBA* ] A LEKERDEZES MEGSZAKADT!");
	
	if(Errcode)
		return log_amx("[ *HIBA*3 ] PROBLEMA A LEKERDEZESNEL! ( %s )",Error);
	
	return PLUGIN_CONTINUE;
}

public native_get_user_by_accountid(userid)
{
	new p[32],n, id;
	get_players(p,n,"ch");
	for(new i=0;i<n;i++)
	{
		id = p[i];
		if(is_user_connected(id) && s_Player[id][Logined] && s_Player[id][gId] == userid)
			return id;
	}
	return -1;
}

public ex_bought_pp(callbackid, socket, accountid, name[], amount, isGift)
{
	sk_chat_lang("%L", "REGSYS_THANKS_FOR_SUPPORT", name);
	sk_log("PPBUY", fmt("Thanks for supporting #%i %s with %i!", accountid, name, amount));

	for(new i=0;i<33;i++)
	{
		if(is_user_connected(i))
		{
			client_cmd(i, "spk holo/tr_holo_fantastic.wav");
			client_cmd(i, "spk buttons/button4.wav");
		}
	}
	
	new online = native_get_user_by_accountid(accountid);
	if(online == -1)
	{
		callback_answer(callbackid, socket, an_NotOnline);
		return;
	}
	else
	{
		s_Player[online][PremiumPoint] += amount;
		callback_answer(callbackid, socket, an_success);
	}

	if(isGift) sk_chat(online, "%L", online, "REGSYS_GIFT_RECEIVED", name, amount);
	else sk_chat(online, "%L", online, "REGSYS_PURCHASE_THANKS", amount);
}

public next_lang(id, update)
{
	s_Player[id][plang]++;
	if(s_Player[id][plang] > lang_types:lang_ua)
		s_Player[id][plang] = lang_types:lang_en;

	if(update)
	{
		new slang[3];
		get_lang_by_enum(s_Player[id][plang], slang);
		set_user_info(id, "lang", slang);
	}
}
public plugin_precache()
{
	precache_sound("Herboynew/hello.wav");
}