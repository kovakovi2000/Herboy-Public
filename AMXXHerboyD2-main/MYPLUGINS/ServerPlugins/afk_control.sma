#include <amxmodx>
#include <reapi>
#include <sk_utils>
#include <regsystem>
#include <scan>
 
#pragma semicolon 1
 
#define ACCESS_LEVEL_IMMUNITY (ADMIN_MENU|ADMIN_LEVEL_H)
	// Immunitás jogát itt tudod beállítani
 
#define TIME_AFK_CHECK 15.0 	
	// Mennyi időközönként ellenőrizze, hogy valaki afk-e, minél kevesebb az idő, annál nagyobb terhelést kap a szerver.
	// Ha a NOROUND aktiv (CSDM esetén pl), érdemes a TIME_AFK_CHECK-nek kissebb értéket adni, mivel spawnkor nem indul új kör. // a fordítás lehet nem tökéletes
 
#define MAX_AFK_WARNING 2 	// Hányszor figyelmeztesse a játékos.
#define TIME_SPECT_CHECK 60.0 	// Mennyi időközönként ellenőrizze, hogy valaki néző-e, minél kevesebb az idő, annál nagyobb terhelést kap a szerver.
#define MAX_SPECT_CHECK_PL 6 	// Hány ellenőrzés után rúgja ki a szerver
#define MIN_PLAYERS_CHECK 40 	// Hány játékosnál ellenőrizze a nézőket, csak ha aktív a MAX_SPECT_CHECK_PL
// #define NOROUND		// Végtelen kör esetén használandó. Pl: CSDM, GunGame
#define BOMB_TRANSFER
	// Ha az AFK nál van a bomba akkor eldobja vagy másnak adja
	// Ha csak azt szeretnénk, hogy csak eldobja a bombát
	// Akkor aktiváld NOROUND-ot
 
#define	get_bit(%1,%2)	(%1 & (1 << (%2 & 31)))
#define	set_bit(%1,%2)	%1 |= (1 << (%2 & 31))
#define	clr_bit(%1,%2)	%1 &= ~(1 << (%2 & 31))
 
new Float:g_fOldOrigin[33][3], Float:g_fOldAngles[33][3];
new g_bitValid;
#if defined NOROUND
new g_bitSpec;
#endif
new g_iWarning[33];
new pnum, players[32];
new g_count[33];
 
public plugin_init()
{
#if defined NOROUND
	RegisterHookChain(RG_CBasePlayer_Spawn, "PlrSpwn_Post", true);
	#define VERSION "1.4.1 [NoRnd]"
#else
	register_logevent("LeRoundStart", 2, "1=Round_Start");
	#define VERSION "1.4.1 [Rnd]"
#endif
	register_plugin("AFK Control", VERSION, "neygomon");
	set_task(TIME_SPECT_CHECK, "SpectatorCheck", .flags = "b");
}
 
public client_putinserver(id)
{
	if(is_user_bot(id) || is_user_hltv(id) || get_user_flags(id) & ACCESS_LEVEL_IMMUNITY)
		clr_bit(g_bitValid, id);
	else	set_bit(g_bitValid, id);
	g_count[id] = 0;
#if defined NOROUND
	clr_bit(g_bitSpec, id);
#endif	
}
#if defined NOROUND
public client_disconnected(id)
	remove_task(id);
 
public PlrSpwn_Post(id)
	if(is_user_alive(id))
		LeRoundStart(id);
#endif	
public LeRoundStart(id)
{
#if defined NOROUND
	if(!get_bit(g_bitSpec, id))
	{
		get_entvar(id, var_origin, g_fOldOrigin[id]);
		get_entvar(id, var_angles, g_fOldAngles[id]);
 
		if(!task_exists(id))
			set_task(TIME_AFK_CHECK, "AfkCheck", id, .flags = "b");
		else	change_task(id, TIME_AFK_CHECK);
	}	
#else
	static freezetime;
	if(!freezetime) freezetime = get_cvar_pointer("mp_freezetime");
	if(get_pcvar_num(freezetime) > 0)
		GoCheckPlayers();
	else	set_task(1.0, "GoCheckPlayers");
#endif	
}
 
public GoCheckPlayers()
{
	get_players(players, pnum, "ah");
	for(new i; i < pnum; i++)
	{
		g_iWarning[players[i]] = 0;
		get_entvar(players[i], var_origin, g_fOldOrigin[players[i]]);
		get_entvar(players[i], var_angles, g_fOldAngles[players[i]]);
	}
 
	if(!task_exists(87892789))
		set_task(TIME_AFK_CHECK, "AfkCheck", 87892789, .flags = "b");
	else	change_task(87892789, TIME_AFK_CHECK);
}
 
public AfkCheck(id)
{
	if(id == 87892789) 
		get_players(players, pnum, "ah");
	else if(!is_user_connected(id))
		return;
	else players[0] = id, pnum = 1;
 
	for(new i, Float:fNewOrigin[3], Float:fNewAngles[3], szName[32]; i < pnum; i++)
	{
		get_entvar(players[i], var_origin, fNewOrigin);
		get_entvar(players[i], var_angles, fNewAngles);
 
		if(!xs_vec_equal(g_fOldOrigin[players[i]], fNewOrigin) || !xs_vec_equal(g_fOldAngles[players[i]], fNewAngles))
		{
			g_iWarning[players[i]] = 0;
			xs_vec_copy(fNewOrigin, g_fOldOrigin[players[i]]);
			xs_vec_copy(fNewAngles, g_fOldAngles[players[i]]);
			continue;
		}
 
		get_entvar(players[i], var_netname, szName, charsmax(szName));
		if(++g_iWarning[players[i]] >= MAX_AFK_WARNING)
		{
			user_kill(players[i], 1);
			engclient_cmd(players[i], "jointeam", "6");
			client_cmd(players[i], "spk events/friend_died");
			sk_chat(0, "^3Játékos: ^1%s ^3spectatorba helyezve, mert ^1AFK!", szName);
		}
		else
		{
			client_cmd(players[i], "spk events/tutor_msg");
			sk_chat(players[i], "Nem mozdulsz! ^3Figyelmeztetések: ^4%i^1/^4%i", g_iWarning[players[i]], MAX_AFK_WARNING);
		}
	}	
}
 
public SpectatorCheck()
{
	if(get_playersnum() < MIN_PLAYERS_CHECK)
		return;
 
	new players[32], pnum; 
	get_players(players, pnum, "h");
	for(new i, szName[32]; i < pnum; i++)
	{
		if(!get_bit(g_bitValid, players[i]))
			continue;

		switch(get_member(players[i], m_iTeam)) 
		{
			case 0, 3: 
			{
				if(++g_count[players[i]] >= MAX_SPECT_CHECK_PL)
				{
					get_entvar(players[i], var_netname, szName, charsmax(szName));
					if(get_user_adminlvl(players[i]) == 0 && get_user_scan(players[i]) == 0)
						server_cmd("amx_kick #%d SpecAFK", get_user_userid(players[i]));
				}
			}	
		}	
	}
}
 
stock bool:xs_vec_equal(const Float:vec1[], const Float:vec2[])
	return (vec1[0] == vec2[0]) && (vec1[1] == vec2[1]) && (vec1[2] == vec2[2]);
 
stock xs_vec_copy(const Float:vecIn[], Float:vecOut[])
{
	vecOut[0] = vecIn[0];
	vecOut[1] = vecIn[1];
	vecOut[2] = vecIn[2];
}
