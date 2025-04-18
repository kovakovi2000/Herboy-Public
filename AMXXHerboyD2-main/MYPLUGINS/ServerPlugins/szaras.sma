#include <amxmodx>
#include <fakemeta>

#define MAX_PLAYERS 32

new const DOOKIE_CLASSNAME[] = "amx_dookie"
new const DOOKIE_MODEL1[] = "models/dookie2.mdl"
new const DOOKIE_MODEL2[] = "models/dookie3.mdl"
new const DOOKIE_SOUND1[] = "dookie/dookie1.wav"
new const DOOKIE_SOUND2[] = "dookie/dookie3.wav"
new const STEAM_SPRITE[] = "sprites/xsmoke3.spr"
new const SMOKE_SPRITE[] = "sprites/steam1.spr"

new Float:pl_origins[MAX_PLAYERS+1][3]
new pl_dookied[MAX_PLAYERS+1]
new hs_counter[MAX_PLAYERS+1]
new steamsprite
new smoke

new gmsgShake
new bool:g_RestartAttempt[MAX_PLAYERS+1]
new amx_dookie, amx_superdookie

public plugin_precache(){
	engfunc(EngFunc_PrecacheSound, DOOKIE_SOUND1)
	engfunc(EngFunc_PrecacheSound, DOOKIE_SOUND2)
	engfunc(EngFunc_PrecacheModel, DOOKIE_MODEL1)
	engfunc(EngFunc_PrecacheModel, DOOKIE_MODEL2)
	steamsprite = engfunc(EngFunc_PrecacheModel, STEAM_SPRITE)
	smoke = engfunc(EngFunc_PrecacheModel, SMOKE_SPRITE)
}

public plugin_init()
{
	register_plugin("Urites", "2.4", "edited by Ek1`") 

	register_clcmd("szaras", "take_a_dookie")
	register_clcmd("takeadookie", "take_a_dookie")

	register_clcmd("szarhelp", "do_help", 0, "Sugo")
	register_clcmd("say", "HandleSay")
	register_clcmd("clcmd_fullupdate", "fullupdateCmd")

	register_forward(FM_Think, "fwdThink")

	register_event("TextMsg", "eRestartAttempt", "a", "2=#Game_will_restart_in")
	register_event("ResetHUD", "eResetHUD", "be")
	register_event("DeathMsg","eDeathMsg", "a")

	gmsgShake = get_user_msgid("ScreenShake")

	amx_dookie = register_cvar("amx_dookie", "2")
	amx_superdookie = register_cvar("amx_superdookie", "2")
}

public fullupdateCmd() {
	return PLUGIN_HANDLED_MAIN
}

public eRestartAttempt() {
	new players[32], num
	get_players(players, num, "a")
	for (new i; i < num; ++i)
		g_RestartAttempt[players[i]] = true
}

public eResetHUD(id) {
	if (g_RestartAttempt[id]) {
		g_RestartAttempt[id] = false
		return
	}
	KillDookie(id)
}

public take_a_dookie(id) {
	new dookie = get_pcvar_num(amx_dookie)
	if(!dookie)
		return PLUGIN_HANDLED
	if (!is_user_alive(id))
		return PLUGIN_HANDLED

	if (pl_dookied[id] > dookie) {
		client_print_color(id, print_chat, "^4[AVATÁR] ^3» ^3Körönként ^1csak ^4%d ^3alkalommal tudsz szarni!", dookie)
		return PLUGIN_HANDLED
	}

	new Float:cur_origin[3], players[MAX_PLAYERS], player, pl_num, Float:dist, Float:last_dist=99999.0, last_id

	pev(id, pev_origin, cur_origin)
	get_players(players, pl_num, "b")

	if(!pl_num) {
		client_print_color(id, print_chat,"^4[AVATÁR] ^3» ^3Nincs hulla amire lehetne szarni.")
		return PLUGIN_HANDLED
	}
		
	for (new i=0;i<pl_num;i++) {
		player = players[i]
		if (player!=id) {
			dist = get_distance_f(cur_origin,pl_origins[player])
			if (dist<last_dist) {
				last_id = player
				last_dist = dist
			}
		}
	}
	if(last_dist<80.0) {		
		new superdookie = get_pcvar_num(amx_superdookie)
		if(hs_counter[id] >= superdookie)
 		{
			hs_counter[id] -= superdookie
 			++pl_dookied[id]

			new Float:origin[3]
			pev(id, pev_origin, origin)

			engfunc(EngFunc_EmitSound, id, CHAN_VOICE, DOOKIE_SOUND2, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

			message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
			write_byte(TE_SMOKE)
			engfunc(EngFunc_WriteCoord, origin[0])
			engfunc(EngFunc_WriteCoord, origin[1])
			engfunc(EngFunc_WriteCoord, origin[2])
			write_short(smoke)
			write_byte(60)
			write_byte(5)
			message_end()

			new dookier[32], dookied[32]
			get_user_name(last_id, dookied, 31)
			get_user_name(id, dookier, 31)
			CreateSuperDookie(id)
			client_print_color(0,print_chat,"^4[AVATÁR] ^3» SZENT SZAR! ^4%s ^3leszarta ^4%s ^3hulláját! HÁHÁHÁ!", dookier, dookied)
			return PLUGIN_HANDLED
		}
		else
		{
			++pl_dookied[id]
			new Float:origin[3]
			pev(id, pev_origin, origin)

			engfunc(EngFunc_EmitSound, id, CHAN_VOICE, DOOKIE_SOUND1, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

			message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
			write_byte(TE_SMOKE)
			engfunc(EngFunc_WriteCoord, origin[0])
			engfunc(EngFunc_WriteCoord, origin[1])
			engfunc(EngFunc_WriteCoord, origin[2])
			write_short(smoke)
			write_byte(60)
			write_byte(5)
			message_end()

			new dookier[32], dookied[32]
			get_user_name(last_id, dookied, charsmax(dookied))
			get_user_name(id, dookier, charsmax(dookier))
			CreateDookie(id)
			client_print_color(0, print_chat,"^4[AVATÁR] ^3» ^4%s ^3telibe szarta ^4%s ^3hulláját!", dookier, dookied)
			return PLUGIN_HANDLED
		}
	}
	else
	{
		client_print_color(id, print_chat, "^4[AVATÁR] ^3» ^3Nincs hulla a közeledben.")
		return PLUGIN_HANDLED
	}
	
	return PLUGIN_HANDLED
}

public eDeathMsg() {
	new victim = read_data(2)
	pev(victim, pev_origin, pl_origins[victim])
	if(read_data(3))
		hs_counter[read_data(1)]++
}

public CreateDookie(id){

	new Float:origin[3]
	pev(id, pev_origin, origin)

	new ent
	ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))

	if(!ent)
		return

	set_pev(ent, pev_classname, DOOKIE_CLASSNAME)

	engfunc(EngFunc_SetModel, ent, DOOKIE_MODEL1)

	new Float:MinBox[3]
	new Float:MaxBox[3]
	for(new a; a<3; a++) {
		MinBox[a] = -1.0
		MaxBox[a] = 1.0
	}
	engfunc(EngFunc_SetSize, ent, MinBox, MaxBox)
	engfunc(EngFunc_SetOrigin, ent, origin)

	set_pev(ent, pev_solid, SOLID_SLIDEBOX)
	set_pev(ent, pev_movetype, MOVETYPE_TOSS)
	set_pev(ent, pev_owner, id)

	new Float:global_Time
	global_get(glb_time, global_Time)
	set_pev(ent, pev_nextthink, global_Time + 1.0)
}

public CreateSuperDookie(id){

	new Float:origin[3]
	pev(id, pev_origin, origin)

	new ent
	ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))

	if(!ent)
		return

	set_pev(ent, pev_classname, DOOKIE_CLASSNAME)

	engfunc(EngFunc_SetModel, ent, DOOKIE_MODEL2)

	new Float:MinBox[3]
	new Float:MaxBox[3]

	for(new a; a<3; a++) {
		MinBox[a] = -1.0
		MaxBox[a] = 1.0
	}

	engfunc(EngFunc_SetSize, ent, MinBox, MaxBox)
	engfunc(EngFunc_SetOrigin, ent, origin)

	set_pev(ent, pev_solid, SOLID_SLIDEBOX)
	set_pev(ent, pev_movetype, MOVETYPE_TOSS)
	set_pev(ent, pev_owner, id)

	//shake
	new all[MAX_PLAYERS], all_num
	get_players(all, all_num, "a")

	for (new i=0;i<all_num;i++)
	{
		message_begin(MSG_ONE, gmsgShake, _, all[i])
		write_short(1<<15) // shake amount
		write_short(1<<11) // shake lasts this long
		write_short(1<<15) // shake noise frequency
		message_end()
	}

	//poo matter
	for (new j = 0; j < 10; j++)
	{
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte(TE_BLOODSTREAM)
		engfunc(EngFunc_WriteCoord, origin[0])
		engfunc(EngFunc_WriteCoord, origin[1])
		engfunc(EngFunc_WriteCoord, origin[2] - 20.0)
		write_coord(random_num(-100,100)) // x
		write_coord(random_num(-100,100)) // y
		write_coord(random_num(20,300)) // z
		write_byte(100) // color
		write_byte(random_num(100,200)) // speed
		message_end()
	}

	new Float:global_Time
	global_get(glb_time, global_Time)
	set_pev(ent, pev_nextthink, global_Time + 1.0)

}

public fwdThink(ent) {
	if(!pev_valid(ent))
		return FMRES_IGNORED

	static classname[33]
	pev(ent, pev_classname, classname, charsmax(classname))

	if(!equal(classname, DOOKIE_CLASSNAME))
		return FMRES_IGNORED

	DookieSteam(ent)
	new Float:global_Time
	global_get(glb_time, global_Time)
	set_pev(ent, pev_nextthink, global_Time + 1.0)
	return FMRES_HANDLED
}

public KillDookie(id){
	new iCurrent = -1

	while((iCurrent = engfunc(EngFunc_FindEntityByString, iCurrent, "classname", DOOKIE_CLASSNAME)) > 0) {
		if(pev(iCurrent, pev_owner) == id)
			engfunc(EngFunc_RemoveEntity, iCurrent)
	}

	pl_dookied[id] = 1
}

public DookieSteam(ent)
{
	new Float:origin[3]
	pev(ent, pev_origin, origin)

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_SPRITE)
	engfunc(EngFunc_WriteCoord, origin[0])
	engfunc(EngFunc_WriteCoord, origin[1])
	engfunc(EngFunc_WriteCoord, origin[2] + 10.0)
	write_short(steamsprite)
	write_byte(8)
	write_byte(10)
	message_end()
}

//public do_help(id){

  //new len = 1300
  //new buffer[1301]
  //new title[20]
  //new n = 0

  //n += formatex( buffer[n],len-n, "<html><head><style type=^"text/css^">pre{color:#FFB000;}body{background:#000000;margin-left:8px;margin-top:0px;}</style></head><body><pre>")

  //n += formatex( buffer[n],len-n, "%L", id, "DOOKIE_MOTD1")

  //n += formatex( buffer[n],len-n, "%L", id, "DOOKIE_MOTD2")
  //n += formatex( buffer[n],len-n, "%L", id, "DOOKIE_MOTD3")

  //n += formatex( buffer[n],len-n, "ex:^n^n")
  //n += formatex( buffer[n],len-n, "%L", id, "DOOKIE_MOTD4")

  //n += formatex( buffer[n],len-n, "%L", id, "DOOKIE_MOTD5")
  //n += formatex( buffer[n],len-n, "%L", id, "DOOKIE_MOTD6", get_pcvar_num(amx_superdookie))
  //n += formatex( buffer[n],len-n, "%L", id, "DOOKIE_MOTD7")

  //n += formatex( buffer[n],len-n, "</pre></body></html>")

  //formatex(title, charsmax(title), "%L", id, "DOOKIE_MOTD_TITLE")
  //show_motd(id, buffer, title)
  //return PLUGIN_CONTINUE
//}

public do_help(id)
{
	client_print_color(id, print_chat, "^4[AVATÁR] ^3» ^1Valakit ^3leakarsz szarni? ^4Használd a betűt^3 amire bindelted!")
	client_print_color(id, print_chat, "^4[AVATÁR] ^3» ^1Ha ^3szarni ^1akarsz, ^3írd be konzolba: ^4bind ^"c^" ^"takeadookie^"")
	client_print_color(id, print_chat, "^4[AVATÁR] ^3» ^1Ha ez kész akkor a ^4c-vel ^3tudsz szarni.")
	
	return PLUGIN_CONTINUE
}

public HandleSay(id) {
  new Speech[192]
  read_args(Speech,192)
  remove_quotes(Speech)

  if( (containi(Speech, "dookie") != -1) || (containi(Speech, "szaras") != -1) || (containi(Speech, "defequer") != -1) ) {
    client_print_color(id,print_chat,"^4[AVATÁR] ^3» ^1Írd be ^3konzolba a további infókért: ^4szarhelp")
  }

  return PLUGIN_CONTINUE
}
