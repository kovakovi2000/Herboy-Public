// vim: set ts=4 sw=4 tw=99 noet:
//
// AMX Mod X, based on AMX Mod by Aleksander Naszko ("OLO").
// Copyright (C) The AMX Mod X Development Team.
//
// This software is licensed under the GNU General Public License, version 3 or higher.
// Additional exceptions apply. For full license details, see LICENSE.txt or visit:
//     https://alliedmods.net/amxmodx-license

//
// Admin Votes Plugin
//

#include <amxmodx>
#include <amxmisc>
#include <sk_utils>
#include <regsystem>

new g_Answer[128]
new g_optionName[4][64]
new g_voteCount[4]
new g_validMaps
new g_yesNoVote
new g_coloredMenus
new g_voteCaller
new g_Execute[256]
new g_execLen
new avote_names[33][33]
new bool:g_execResult
new Float:g_voteRatio

public plugin_init()
{
	register_plugin("Admin Votes", AMXX_VERSION_STR, "AMXX Dev Team")
	register_dictionary("adminvote.txt")
	register_dictionary("common.txt")
	register_dictionary("mapsmenu.txt")
	register_menucmd(register_menuid("Change map to "), MENU_KEY_1|MENU_KEY_2, "voteCount")
	register_menucmd(register_menuid("Choose map: "), MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4, "voteCount")
	register_menucmd(register_menuid("Kick "), MENU_KEY_1|MENU_KEY_2, "voteCount")
	register_menucmd(register_menuid("Ban "), MENU_KEY_1|MENU_KEY_2, "voteCount")
	register_menucmd(register_menuid("Vote: "), MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4, "voteCount")
	register_menucmd(register_menuid("The result: "), MENU_KEY_1|MENU_KEY_2, "actionResult")
	register_concmd("amx_votemap", "cmdVoteMap", ADMIN_VOTE, "<map> [map] [map] [map]")
	register_concmd("amx_vote", "cmdVote", ADMIN_VOTE, "<question> <answer#1> <answer#2>")
	
	g_coloredMenus = colored_menus()
}
public client_putinserver(id)
{
	get_user_name(id, avote_names[id], charsmax(avote_names))
}
public delayedExec(cmd[])
	server_cmd("%s", cmd)

public autoRefuse()
{

}

public actionResult(id, key)
{
	remove_task(4545454)
	
	switch (key)
	{
		case 0:
		{
			set_task(2.0, "delayedExec", 0, g_Execute, g_execLen)
		}
		case 1: autoRefuse()
	}
	
	return PLUGIN_HANDLED
}

public checkVotes()
{
	new best = 0
	
	if (!g_yesNoVote)
	{
		for (new a = 0; a < 4; ++a)
			if (g_voteCount[a] > g_voteCount[best])
		
		best = a
	}

	new votesNum = g_voteCount[0] + g_voteCount[1] + g_voteCount[2] + g_voteCount[3]
	new iRatio = votesNum ? floatround(g_voteRatio * float(votesNum), floatround_ceil) : 1
	new iResult = g_voteCount[best]
	new players[MAX_PLAYERS], pnum, i
	
	get_players(players, pnum, "c")
	
	if (iResult < iRatio)
	{
			if (g_yesNoVote)

				sk_chat(0, "A szavazás sikertelen! ^3(igen %i) (nem %i) (%i szükséges)", g_voteCount[0], g_voteCount[1], iRatio)
			else
				sk_chat(0, "A szavazás sikertelen! ^3(van %i) (%i szükséges)",iResult, iRatio)

		log_amx("Vote: failed (got ^"%d^") (needed ^"%d^")", iResult, iRatio)
		
		return PLUGIN_CONTINUE
	}

	g_execLen = format(g_Execute, charsmax(g_Execute), g_Answer, g_optionName[best]) + 1
	
	if (g_execResult)
	{
		g_execResult = false
		
		if (is_user_connected(g_voteCaller))
		{
			new menuBody[512], lTheResult[32], lYes[16], lNo[16]
			
			format(lTheResult, charsmax(lTheResult), "%L", g_voteCaller, "THE_RESULT")
			format(lYes, charsmax(lYes), "%L", g_voteCaller, "YES")
			format(lNo, charsmax(lNo), "%L", g_voteCaller, "NO")
			
			new len = format(menuBody, charsmax(menuBody), g_coloredMenus ? "\y%s: \w%s^n^n" : "%s: %s^n^n", lTheResult, g_Execute)//"
			
			len += format(menuBody[len], charsmax(menuBody) - len, g_coloredMenus ? "\y%L^n\w" : "%L^n", g_voteCaller, "WANT_CONTINUE")
			format(menuBody[len], charsmax(menuBody) - len, "^n1. %s^n2. %s", lYes, lNo)
			show_menu(g_voteCaller, 0x03, menuBody, 10, "The result: ")
			set_task(10.0, "autoRefuse", 4545454)
		}
		else
			set_task(2.0, "delayedExec", 0, g_Execute, g_execLen)
	}
	
	sk_chat(0, "A szavazás sikeres! Az eredmény: ^4%s", g_Execute)
	log_amx("Vote: succes (got ^"%d^") (needed ^"%d^") (result ^"%s^")", iResult, iRatio, g_Execute)
	
	return PLUGIN_CONTINUE
}

public voteCount(id, key)
{
	if (get_cvar_num("amx_vote_answers"))
	{
		if (g_yesNoVote)
			sk_chat(0, "^4%s: ^3%s^1 %s szavazott.", id > 0 ? Admin_Permissions[get_user_adminlvl(id)][0] : "Server RCON", avote_names[id], key ? "nemre" : "igenre")
		else
			sk_chat(0, "^4%s: ^3%s^1 %i-ra/re szavazott.", id > 0 ? Admin_Permissions[get_user_adminlvl(id)][0] : "Server RCON", avote_names[id], key + 1)
	}
	++g_voteCount[key]
	
	return PLUGIN_HANDLED
}

public cmdVoteMap(id, level, cid)
{
	if (!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED
	
	new Float:voting = get_cvar_float("amx_last_voting")
	if (voting > get_gametime())
	{
		console_print(id, "%L", id, "ALREADY_VOTING")
		return PLUGIN_HANDLED
	}
	
	if (voting && voting + get_cvar_float("amx_vote_delay") > get_gametime())
	{
		console_print(id, "%L", id, "VOTING_NOT_ALLOW")
		return PLUGIN_HANDLED
	}

	new argc = read_argc()
	if (argc > 5) argc = 5
	
	g_validMaps = 0
	copy(g_optionName[0][0], 64, "N/A")
	copy(g_optionName[1][0], 64, "N/A")
	copy(g_optionName[2][0], 64, "N/A")
	copy(g_optionName[3][0], 64, "N/A")
	
	for (new i = 1; i < argc; ++i)
	{
		read_argv(i, g_optionName[g_validMaps], 31)

		if (contain(g_optionName[g_validMaps], "..") != -1)
			continue

		if (is_map_valid(g_optionName[g_validMaps]))
			g_validMaps++
	}
	
	if (g_validMaps == 0)
	{
		new lMaps[16]
		
		format(lMaps, charsmax(lMaps), "%L", id, (argc == 2) ? "MAP_IS" : "MAPS_ARE")
		console_print(id, "%L", id, "GIVEN_NOT_VALID", lMaps)
		return PLUGIN_HANDLED
	}

	new menu_msg[256], len = 0
	new keys = 0
	
	if (g_validMaps > 1)
	{
		keys = MENU_KEY_0
		len = format(menu_msg, charsmax(menu_msg), g_coloredMenus ? "\y%L: \w^n^n" : "%L: ^n^n", LANG_SERVER, "CHOOSE_MAP")//"
		new temp[128]
		
		for (new a = 0; a < g_validMaps; ++a)
		{
			format(temp, charsmax(temp), "%d.  %s^n", a+1, g_optionName[a])
			len += copy(menu_msg[len], charsmax(menu_msg) - len, temp)
			keys |= (1<<a)
		}
		
		format(menu_msg[len], charsmax(menu_msg) - len, "^n0.  %L", LANG_SERVER, "NONE")
		g_yesNoVote = 0
	} else {
		new lChangeMap[32], lYes[16], lNo[16]
		
		format(lChangeMap, charsmax(lChangeMap), "%L", LANG_SERVER, "CHANGE_MAP_TO")
		format(lYes, charsmax(lYes), "%L", LANG_SERVER, "YES")
		format(lNo, charsmax(lNo), "%L", LANG_SERVER, "NO")
		format(menu_msg, charsmax(menu_msg), g_coloredMenus ? "\y%s %s?\w^n^n1.  %s^n2.  %s" : "%s %s?^n^n1.  %s^n2.  %s", lChangeMap, g_optionName[0], lYes, lNo)
		keys = MENU_KEY_1|MENU_KEY_2
		g_yesNoVote = 1
	}
	
	new authid[32], name[MAX_NAME_LENGTH]
	
	get_user_authid(id, authid, charsmax(authid))
	get_user_name(id, name, charsmax(name))
	
	if (argc == 2)
		sk_log("VoteMapActivity", fmt("[AMX_VOTEMAP] %s %s votemap %s", id > 0 ? Admin_Permissions[get_user_adminlvl(id)][0] : "Server RCON", avote_names[id], g_optionName[0]))
	else
		sk_log("VoteMapActivity", fmt("[AMX_VOTEMAP] %s %s votemaps (map#1 ^"%s^") (map#2 ^"%s^") (map#3 ^"%s^") (map#4 ^"%s^")", id > 0 ? Admin_Permissions[get_user_adminlvl(id)][0] : "Server RCON", avote_names[id], g_optionName[0], g_optionName[1], g_optionName[2], g_optionName[3]))

	if(argc == 2)
		sk_chat(0, "^4%s: ^3%s^1 pályaszavazás a következőre ^4%s^1-t.", id > 0 ? Admin_Permissions[get_user_adminlvl(id)][0] : "Server RCON", avote_names[id], g_optionName[0])
	else
		sk_chat(0, "^4%s: ^3%s^1 pályaszavazás a következőkre ^4%s, %s, %s, %s^1-t.", id > 0 ? Admin_Permissions[get_user_adminlvl(id)][0] : "Server RCON", avote_names[id], g_optionName[0], g_optionName[1], g_optionName[2], g_optionName[3])

	g_execResult = true
	new Float:vote_time = get_cvar_float("amx_vote_time") + 2.0
	
	set_cvar_float("amx_last_voting", get_gametime() + vote_time)
	g_voteRatio = get_cvar_float("amx_votemap_ratio")
	g_Answer = "changelevel %s"
	show_menu(0, keys, menu_msg, floatround(vote_time), (g_validMaps > 1) ? "Choose map: " : "Change map to ")//"
	set_task(vote_time, "checkVotes", 99889988)
	g_voteCaller = id
	console_print(id, "%L", id, "VOTING_STARTED")
	g_voteCount = {0, 0, 0, 0}
	
	return PLUGIN_HANDLED
}

public cmdVote(id, level, cid)
{
	if (!cmd_access(id, level, cid, 4))
		return PLUGIN_HANDLED
	
	new Float:voting = get_cvar_float("amx_last_voting")
	if (voting > get_gametime())
	{
		console_print(id, "%L", id, "ALREADY_VOTING")
		return PLUGIN_HANDLED
	}
	
	if (voting && voting + get_cvar_float("amx_vote_delay") > get_gametime())
	{
		console_print(id, "%L", id, "VOTING_NOT_ALLOW")
		return PLUGIN_HANDLED
	}

	new quest[48]
	read_argv(1, quest, charsmax(quest))
	
	trim(quest);
	
	if (containi(quest, "sv_password") != -1 || containi(quest, "rcon_password") != -1)
	{
		console_print(id, "%L", id, "VOTING_FORBIDDEN")
		return PLUGIN_HANDLED
	}
	
	new count=read_argc();

	for (new i=0;i<4 && (i+2)<count;i++)
	{
		read_argv(i+2, g_optionName[i], charsmax(g_optionName[]));
	}

	new authid[32], name[MAX_NAME_LENGTH]
	
	get_user_authid(id, authid, charsmax(authid))
	get_user_name(id, name, charsmax(name))
	sk_log("VoteMapActivity", fmt("[AMX_VOTE] %s %s vote %s (%s - %s)", id > 0 ? Admin_Permissions[get_user_adminlvl(id)][0] : "Server RCON", avote_names[id], quest, g_optionName[0], g_optionName[1]))
	sk_chat(0, "^4%s: ^3%s^1 szavazás a következőre ^4%s^1-t.", id > 0 ? Admin_Permissions[get_user_adminlvl(id)][0] : "Server RCON", avote_names[id], quest)

	new menu_msg[512], lVote[16]
	
	format(lVote, charsmax(lVote), "%L", LANG_SERVER, "VOTE")
	
	count-=2;
	if (count>4)
	{
		count=4;
	}
	// count now shows how many options were listed
	new keys=0;
	for (new i=0;i<count;i++)
	{
		keys |= (1<<i);
	}
	
	new len=formatex(menu_msg, charsmax(menu_msg), g_coloredMenus ? "\y%s: %s\w^n^n" : "%s: %s^n^n", lVote, quest);
	
	for (new i=0;i<count;i++)
	{
		len+=formatex(menu_msg[len], charsmax(menu_msg) - len ,"%d.  %s^n",i+1,g_optionName[i]);
	}
	g_execResult = false
	
	new Float:vote_time = get_cvar_float("amx_vote_time") + 2.0
	
	set_cvar_float("amx_last_voting", get_gametime() + vote_time)
	g_voteRatio = get_cvar_float("amx_vote_ratio")
	replace_all(quest, charsmax(quest), "%", "");
	format(g_Answer, charsmax(g_Answer), "%s - ^"%%s^"", quest)
	show_menu(0, keys, menu_msg, floatround(vote_time), "Vote: ")
	set_task(vote_time, "checkVotes", 99889988)
	g_voteCaller = id
	console_print(id, "%L", id, "VOTING_STARTED")
	g_voteCount = {0, 0, 0, 0}
	g_yesNoVote = 0
	
	return PLUGIN_HANDLED
}
public LoadUtils(){}
