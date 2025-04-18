
#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>
#include <string>
#include <engine>
#include <sqlx>	
#include <sk_utils>
#include <regsystem>
#include <manager> 

#define PLUGIN "ShadowBan"
#define VERSION "1.0b"
#define AUTHOR "Kova"

#define PUNISH_IGNORE 1
#define PUNISH_MISS 2
#define PUNISH_REDIRECT 3
#define PUNISH_LAG 4

#define bGet(%2,%1) (%1 & (1<<(%2&31)))
#define bSet(%2,%1) (%1 |= (1<<(%2&31)))
#define bRem(%2,%1) (%1 &= ~(1 <<(%2&31)))
// new doLag;
// new Float:g_LagLength[33];
static Query[10048];

new StringHud[128];
new bool:g_Hud[33] = false;

enum _:Punishments
{
	SteamID[33],
	bool:doPunish,
	Float:WeakHitPresent,
	Float:LagPresent,
	Float:LagSpike,
	Float:BulletPlierPresent,
	bool:isBigHitbox
}

enum _:eCurrentActive
{
	eWeakhit,
	eLag,
	eBulletPiler,
	eBigHitbox
}

new ActivePunish[eCurrentActive];
public ClearCurrentActive(id)
{
	bRem(id, ActivePunish[eWeakhit]);
	bRem(id, ActivePunish[eLag]);
	bRem(id, ActivePunish[eBulletPiler]);
	bRem(id, ActivePunish[eBigHitbox]);
}

new g_Users[33][Punishments];
public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	set_task(1.0, "taskLag",_,_,_,"b");

	RegisterHam(Ham_TraceAttack, "player", "HAM_TraceAttack__pre", 0);
	//register_forward(FM_AddToFullPack,"FWD_AddToFullPack", 0);

	register_clcmd("shadowban", "CMD_SoftBan", ADMIN_IMMUNITY, "<target> <type/command> <value>");
	register_clcmd("shadowban_display", "CMD_SoftBan_Display", ADMIN_IMMUNITY);
}

public Load_Bans(id)
{
	new Data[1];
	Data[0] = id;
	formatex(Query, charsmax(Query), "SELECT * FROM `amx_shadowban` WHERE `Steamid` = ^"%s^" LIMIT 1;", g_Users[id][SteamID]);
	SQL_ThreadQuery(m_get_sql(), "QueryShadowBans", Query, Data, 1);
}

public QueryShadowBans(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime) {
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) {
		log_amx("%s", Error);
		set_fail_state("* Hibas lekerdezes itt, LoadShadowBans: %s", Error);
		return;
	}
	else {
		new id = Data[0];
		
		if(SQL_NumRows(Query) > 0) 
		{
			SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "WeakHitPresent"), g_Users[id][WeakHitPresent]);
			SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "LagPresent"), g_Users[id][LagPresent]);
			SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "LagSpike"), g_Users[id][LagSpike]);
			SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "BulletPlierPresent"), g_Users[id][BulletPlierPresent]);
			g_Users[id][doPunish] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "doPunish")) == 1 ? (true) : (false);
			g_Users[id][isBigHitbox] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "isBigHitbox")) == 1 ? (true) : (false);
		}
		else
			CreateUserShadow(id);

		//client_print_color(id, print_team_default, "DEBUG: %.2f, %.2f, %.2f, %.2f, %i, %i", g_Users[id][WeakHitPresent], g_Users[id][LagPresent], g_Users[id][LagSpike], g_Users[id][BulletPlierPresent], g_Users[id][doPunish], g_Users[id][isBigHitbox]);
	}
}

public CreateUserShadow(id)
{
	new Data[1];
	Data[0] = id;
	formatex(Query, charsmax(Query), "INSERT INTO `amx_shadowban` (`Steamid`, `WeakHitPresent`, `LagPresent`,`LagSpike`, `BulletPlierPresent`,`doPunish`, `isBigHitbox`) VALUES (^"%s^", ^"%.2f^", ^"%.2f^", ^"%.2f^", ^"%.2f^", ^"%i^", ^"%i^");", g_Users[id][SteamID], g_Users[id][WeakHitPresent], g_Users[id][LagPresent], g_Users[id][LagSpike], g_Users[id][BulletPlierPresent], g_Users[id][doPunish], g_Users[id][isBigHitbox]);
	SQL_ThreadQuery(m_get_sql(), "QueryInsertShadows", Query, Data, 1);
}

public QueryInsertShadows(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime){
	if( FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED ){
		log_amx("%s", Error);
		set_fail_state("* Hibas lekerdezes itt, CreateShadowBan: %s", Error);
		return;
	}
	else{
		new id = Data[0];
	
		Load_Bans(id);
	}
}

public UpdateProfiles(id)
{
	new Len;

	Len += formatex(Query[Len], charsmax(Query), "UPDATE `amx_shadowban` SET ");
	Len += formatex(Query[Len], charsmax(Query)-Len, "WeakHitPresent = ^"%.2f^", ", g_Users[id][WeakHitPresent]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "LagPresent = ^"%.2f^", ", g_Users[id][LagPresent]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "LagSpike = ^"%.2f^", ", g_Users[id][LagSpike]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "BulletPlierPresent = ^"%.2f^", ", g_Users[id][BulletPlierPresent]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "doPunish = ^"%i^", ", g_Users[id][doPunish] ? 1 : 0);
	Len += formatex(Query[Len], charsmax(Query)-Len, "isBigHitbox = ^"%i^" ", g_Users[id][isBigHitbox] ? 1 : 0);

	Len += formatex(Query[Len], charsmax(Query)-Len, "WHERE `Steamid` =	^"%s^";", g_Users[id][SteamID]);

	SQL_ThreadQuery(m_get_sql(), "QuerySetData_ShadowBans", Query);
}

public QuerySetData_ShadowBans(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime)
{
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) 
	{
		log_amx("Error from QuerySetData_ShadowBans:");
		log_amx("%s", Error);
		return;
	}
}

public CMD_SoftBan_Display(id,level,cid)
{
	if (!cmd_access(id, level, cid, 0, true))
		return PLUGIN_HANDLED;

	g_Hud[id] = !g_Hud[id];
	console_print(id, "[%s]", (g_Hud[id] ? "You will see the truth..." : "You blind to the truth!"));
	return PLUGIN_HANDLED;
}

public CMD_SoftBan(id,level,cid)
{
	if (!cmd_access(id, level, cid, 2, true))
		return PLUGIN_HANDLED;

	new arg_target[32];
	read_argv(1, arg_target, charsmax(arg_target));

	new target = cmd_target(id, arg_target, (CMDTARGET_ALLOW_SELF | CMDTARGET_NO_BOTS));
	if(target == 0)
		return PLUGIN_HANDLED;

	new arg_key[32], arg_value[32];
	read_argv(2, arg_key, charsmax(arg_key));
	strtolower(arg_key);
	new wasvalue = read_argv(3, arg_value, charsmax(arg_value));
	new Float:value = str_to_float(arg_value);
	if(equal(arg_key, "disable"))
	{
		g_Users[target][doPunish] = false;
		console_print(id, "[Target will no longer experience Softban]");
	}
	else if(equal(arg_key, "enable"))
	{
		g_Users[target][doPunish] = true;
		console_print(id, "[Target will experience Softban]");
		console_print(id, "^tTarget set ^"WeakHitPresent^" to: %.2f", g_Users[target][WeakHitPresent]);
		console_print(id, "^tTarget set ^"LagPresent^" to: %.2f", g_Users[target][LagPresent]);
		console_print(id, "^tTarget set ^"LagSpike^" to: %.2f", g_Users[target][LagSpike]);
		console_print(id, "^tTarget set ^"BulletPlierPresent^" to: %.2f", g_Users[target][BulletPlierPresent]);
		console_print(id, "^tTarget set ^"isBigHitbox^" to: %s", (g_Users[target][isBigHitbox] ? "true" : "false") );
	}
	else if(equal(arg_key, "view"))
	{
		console_print(id, "[%s]", (g_Users[target][doPunish] ? "Target will experience Softban" : "Target will not experience Softban"));
		console_print(id, "^tTarget set ^"WeakHitPresent^" to: %.2f", g_Users[target][WeakHitPresent]);
		console_print(id, "^tTarget set ^"LagPresent^" to: %.2f", g_Users[target][LagPresent]);
		console_print(id, "^tTarget set ^"LagSpike^" to: %.2f", g_Users[target][LagSpike]);
		console_print(id, "^tTarget set ^"BulletPlierPresent^" to: %.2f", g_Users[target][BulletPlierPresent]);
		console_print(id, "^tTarget set ^"isBigHitbox^" to: %s", (g_Users[target][isBigHitbox] ? "true" : "false") );
	}
	else if(equal(arg_key, "clear"))
	{
		g_Users[target][doPunish] = false;
		g_Users[target][WeakHitPresent] = 0.0;
		g_Users[target][BulletPlierPresent] = 0.0;
		g_Users[target][LagPresent] = 0.0;
		g_Users[target][LagSpike] = 0.0;
		g_Users[target][isBigHitbox] = false;
		console_print(id, "[Target will not experience Softban]");
		console_print(id, "^tTarget set ^"WeakHitPresent^" to: %.2f", g_Users[target][WeakHitPresent]);
		console_print(id, "^tTarget set ^"LagPresent^" to: %.2f", g_Users[target][LagPresent]);
		console_print(id, "^tTarget set ^"LagSpike^" to: %.2f", g_Users[target][LagSpike]);
		console_print(id, "^tTarget set ^"BulletPlierPresent^" to: %.2f", g_Users[target][BulletPlierPresent]);
		console_print(id, "^tTarget set ^"isBigHitbox^" to: %s", (g_Users[target][isBigHitbox] ? "true" : "false") );
	}
	else if(equal(arg_key, "all"))
	{
		g_Users[target][doPunish] = true;
		g_Users[target][WeakHitPresent] = 5.0;
		g_Users[target][BulletPlierPresent] = 5.0;
		g_Users[target][LagPresent] = 0.5;
		g_Users[target][LagSpike] = 0.5;
		g_Users[target][isBigHitbox] = true;
		console_print(id, "[Target will experience Softban]");
		console_print(id, "^tTarget set ^"WeakHitPresent^" to: %.2f", g_Users[target][WeakHitPresent]);
		console_print(id, "^tTarget set ^"LagPresent^" to: %.2f", g_Users[target][LagPresent]);
		console_print(id, "^tTarget set ^"LagSpike^" to: %.2f", g_Users[target][LagSpike]);
		console_print(id, "^tTarget set ^"BulletPlierPresent^" to: %.2f", g_Users[target][BulletPlierPresent]);
		console_print(id, "^tTarget set ^"isBigHitbox^" to: %s", (g_Users[target][isBigHitbox] ? "true" : "false") );
	}
	else if(equal(arg_key, "weakhit"))
	{
		g_Users[target][WeakHitPresent] = (wasvalue > 0 ? value : 5.0);
		console_print(id, "Target set ^"WeakHitPresent^" to: %.2f", g_Users[target][WeakHitPresent]);
	}
	else if(equal(arg_key, "lag"))
	{
		g_Users[target][LagPresent] = (wasvalue > 0 ? value : 0.5);
		console_print(id, "Target set ^"LagPresent^" to: %.2f", g_Users[target][LagPresent]);
	}
	else if(equal(arg_key, "lagspike"))
	{
		g_Users[target][LagSpike] = (wasvalue > 0 ? value : 0.5);
		console_print(id, "Target set ^"LagSpike^" to: %.2f", g_Users[target][LagSpike]);
	}
	else if(equal(arg_key, "bulletplier"))
	{
		g_Users[target][BulletPlierPresent] = (wasvalue > 0 ? value : 5.0);
		console_print(id, "Target set ^"BulletPlierPresent^" to: %.2f", g_Users[target][BulletPlierPresent]);
	}
	else if(equal(arg_key, "bighitbox"))
	{
		g_Users[target][isBigHitbox] = (wasvalue > 0 ? (!g_Users[target][isBigHitbox]) : (value == 0.0 ? (false) : (true)) );
		console_print(id, "Target set ^"isBigHitbox^" to: %s", (g_Users[target][isBigHitbox] ? "true" : "false") );
	}
	else
	{
		console_print(id, "Unkown type | <disable, enable, view, all, WeakHit, Lag, LagSpike, BulletPlier, BigHitbox>");
	}
	return PLUGIN_HANDLED;
}

public taskLag()
{
	new p[32],n;
	get_players(p,n,"ch");
	for(new i=0;i<n;i++)
	{
		new id = p[i];
		/* if(g_Users[id][doPunish])
		{
			new Float:possibility = random_float(0.0, 100.0);
			checklag(id, possibility);
		}
		else */ 
		if(g_Hud[id])
		{
			new observered = entity_get_int(id, EV_INT_iuser2);
			if(g_Users[observered][doPunish])
			{
				formatex(StringHud, charsmax(StringHud), "[%s%s%s ]", (bGet(observered, ActivePunish[eWeakhit]) ? " WEAKHIT": ""), 
																		//(bGet(observered, ActivePunish[eLag]) ? " LAG": ""), 
																		(bGet(observered, ActivePunish[eBulletPiler]) ? " BULLETPILER": ""), 
																		(bGet(observered, ActivePunish[eBigHitbox]) ? " BIGHITBOX": "") 
				);
				ClearCurrentActive(observered);
				set_hudmessage(255, 255, 255, -1.0, 0.72, 0, 0.0, 1.1, 0.0, 0.0, -1);
				show_hudmessage(id, StringHud);
			}
		}
	}
}

public client_putinserver(id)
{
	g_Hud[id] = false;
	g_Users[id][doPunish] = false;
	g_Users[id][WeakHitPresent] = 0.0;
	g_Users[id][LagPresent] = 0.0;
	g_Users[id][LagSpike] = 0.0;
	g_Users[id][BulletPlierPresent] = 0.0;
	g_Users[id][isBigHitbox] = false;
	get_user_authid(id, g_Users[id][SteamID], charsmax(g_Users[][SteamID]));

	if(!is_user_bot(id) && is_user_connected(id) && !is_user_hltv(id))
		Load_Bans(id);
}

public client_disconnected(id)
{ 
	g_Hud[id] = false;
	if(!is_user_bot(id) && !is_user_hltv(id))
		UpdateProfiles(id);
}

public HAM_TraceAttack__pre(victim, attacker, Float:damage, Float: direction[3], trace, damageBits)
{
	if(is_user_connected(victim) && is_user_connected(attacker))
	{
		switch(DoSoft(attacker, victim, trace))
		{
			case PUNISH_IGNORE: return HAM_IGNORED;
			case PUNISH_MISS: return HAM_SUPERCEDE;
			case PUNISH_REDIRECT: return HAM_HANDLED;
			default: return HAM_IGNORED;
		}
	}
	return HAM_IGNORED;
}

// public FWD_AddToFullPack(ent_state, e, edict_t_ent, host, hostflags, player, pSet) 
// {
// 	if(bGet(host, doLag))
// 	{
// 		if(g_LagLength[host] > halflife_time())
// 		{
// 			if(random(99) != 0)
// 				return FMRES_SUPERCEDE;
// 		}
// 		else
// 			bRem(host, doLag);
// 	}
// 	return FMRES_IGNORED;
// }

stock DoSoft(attacker, victim, trace)
{
	new Float:aOrigin[3];
	new Float:vOrigin[3];
	pev(attacker, pev_origin, aOrigin);
	pev(victim, pev_origin, vOrigin);
	new Float:disFactor = get_distance_f(aOrigin, vOrigin) / 500.0;

	//Ha mind2-en SoftBannoltak nem kell csinálni semmit
	if(g_Users[attacker][doPunish] && g_Users[victim][doPunish])
		return PUNISH_IGNORE;
	else
	{
		new Float:possibility = random_float(0.0, 100.0);
		new HitGroup = get_tr2(trace, TR_iHitgroup);
		//Ha a támadó SoftBannolt
		if(g_Users[attacker][doPunish])
		{
			//checklag(attacker, possibility);
			new Float:pFact = g_Users[attacker][WeakHitPresent] * disFactor * (HitGroup == HIT_HEAD ? 1.1 : 1.0);
			if(possibility < pFact)
			{
				//client_print_color(attacker, print_team_default, "^4[SoftBan] ^1MISS %.2f %s", pFact, (HitGroup == HIT_HEAD ? "Head" : ""));
				bSet(attacker, ActivePunish[eWeakhit]);
				return PUNISH_MISS;
			}
		}
		//Ha az áldozat SoftBannolt
		else if(g_Users[victim][doPunish])
		{
			//checklag(victim, possibility);
			if(HitGroup == HIT_CHEST)
			{
				new Float:pFact = g_Users[victim][WeakHitPresent] * disFactor;
				if(possibility < pFact)
				{
					//client_print_color(victim, print_team_default, "^4[SoftBan] ^1REDIRECT %.2f%", pFact);
					set_tr2(trace, TR_iHitgroup, HIT_HEAD);
					bSet(victim, ActivePunish[eBulletPiler]);
					return PUNISH_REDIRECT;
				}
			}
		}
	}
	return PUNISH_IGNORE;
}

// stock checklag(id, Float:possibility)
// {
// 	new vict;
// 	get_user_aiming(id, vict);
// 	possibility = possibility * (is_user_alive(vict) ? 2.0 : 1.0);
// 	if(possibility < g_Users[id][LagPresent])
// 	{
// 		new Float:spike = g_Users[id][LagSpike] * random_float(0.1, 1.0);
// 		//client_print_color(id, print_team_default, "^4[SoftBan] ^1LAG %.2f%", spike);
// 		g_LagLength[id] = halflife_time() + spike;
// 		bSet(id, doLag);
// 		bSet(id, ActivePunish[eLag]);
// 	}
// }
