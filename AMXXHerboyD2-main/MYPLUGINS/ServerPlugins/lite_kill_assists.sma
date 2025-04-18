#include <amxmodx>
#include <fun>
#include <cstrike>
#include <sk_utils>

new const PREFIX[] = "KillAssists"

// Vedd ki a // jelet a # elől, ha azonnal frissíteni szeretnéd a fragek számát elosztáskor, nem csak kör elején.
//#define LIVE_UPDATE

#define IsValidPlayers(%1,%2) ((1 <= %1 <= 32) && (1 <= %2 <= 32))

new g_iAssist[33];
new g_iAssDamage[33][33];

public plugin_init()
{
	register_plugin("Lite Kill Assists", "1.17", "neygomon");
	
	register_event("HLTV",     "eRoundStart", "a", "1=0", "2=0");
	register_event("DeathMsg", "eDeathMsg", "a", "1>0");
	register_event("Damage",   "eDamage", "be", "2!0", "3=0", "4!0");
}

public client_disconnected(id)
	ResetAssist(id);

public eRoundStart()
{
	new pl[32], pnum; get_players(pl, pnum);
	for(new i; i < pnum; i++)
		ResetAssist(pl[i]);
}
	
public eDeathMsg()
{
	static pKiller, pVictim;
	pKiller = read_data(1);
	pVictim = read_data(2);
	if(pKiller == pVictim || pKiller == g_iAssist[pVictim] || !is_user_connected(g_iAssist[pVictim])) return;
	
	cs_set_user_money(g_iAssist[pVictim], cs_get_user_money(g_iAssist[pVictim]) + 300);
	static iFrags; iFrags = get_user_frags(g_iAssist[pVictim]) + 1;
	set_user_frags(g_iAssist[pVictim], iFrags);
#if defined LIVE_UPDATE
	static mScoreInfo; if(!mScoreInfo) mScoreInfo = get_user_msgid("ScoreInfo");
	message_begin(MSG_ALL, mScoreInfo);
	write_byte(g_iAssist[pVictim]);
	write_short(iFrags);
	write_short(get_user_deaths(g_iAssist[pVictim]));
	write_short(0);
	write_short(get_user_team(g_iAssist[pVictim]));
	message_end();
#endif
	static victim[32];
	get_user_name(pVictim, victim, charsmax(victim));
	sk_chat(g_iAssist[pVictim], "Kaptál ^3+1^1 fraget, mert segítettél ^4%s^1 megölésében.", victim)
	ResetAssist(pVictim);
}

public eDamage(id)
{
	static pAttacker; pAttacker = get_user_attacker(id);
	if(id == pAttacker || !IsValidPlayers(id, pAttacker)) return;
	g_iAssDamage[id][pAttacker] += read_data(2);
	if(!g_iAssist[id] && g_iAssDamage[id][pAttacker] >= 50)
		g_iAssist[id] = pAttacker;
}

ResetAssist(id)
{
	g_iAssist[id] = 0;
	arrayset(g_iAssDamage[id], 0, sizeof g_iAssDamage[]);
}

stock ChatColor(const id, const szMessage[], any:...) {
	static pnum, players[32], szMsg[190], IdMsg; 
	vformat(szMsg, charsmax(szMsg), szMessage, 3);
	
	if(!IdMsg) IdMsg = get_user_msgid("SayText");
	
	if(id) { 
		if(!is_user_connected(id)) return;
		players[0] = id;
		pnum = 1; 
    } 
	else get_players(players, pnum, "ch");
	
	for(new i; i < pnum; i++) {
		message_begin(MSG_ONE, IdMsg, .player = players[i]);
		write_byte(players[i]);
		write_string(szMsg);
		message_end();
	}
}