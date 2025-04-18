#pragma compress 1
#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <engine>
#include <nvault>
#include <sqlx>	

#define PLUGIN "KnifeZone"
#define VERSION "1.1.4"
#define AUTHOR "Kova"
//#define NOTFULL "1"

#define _CLASSNAME "PD_OBJECT"
#define _TASKOFFSET 1642662
#define _MSG_ERROR "^4[%s] ^1Egy blockerre kell nézned amit modosítani akarsz!"
#define _KZ_GROUP (1<<27)
#define _MAXPLAYER 32

#if defined NOTFULL
	new Handle:g_SqlTuple;
	static const SQLINFO[][] = { "mysqlgame.clans.hu", "demoanalis893", "EbY7a7aWuLy5AqA", "demoanalis893"}; //Sql mentéshez itt kell meganod a szervert és adatbázíst
#endif

enum _:Zone
{
	zName[32],
	Float:zLocation[3],
	Float:zMins[3],
	Float:zMaxs[3]
}

new g_SprId_LaserBeam;
new g_hVault = INVALID_HANDLE;
new HamHook:fwd_Ham_Touch;
public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	server_print("no_amxx_uncompress");

	new base[16];
	get_mapname(base, sizeof (base));
	new vaultname[32];
	formatex(vaultname, 31, "knifezone_%s", base);
	g_hVault = nvault_open(vaultname);
	if(g_hVault == INVALID_HANDLE) {
		set_fail_state("Error opening nVault!");
		return;
	}

	g_SprId_LaserBeam = engfunc(EngFunc_PrecacheModel, "sprites/laserbeam.spr")
	register_clcmd("kz", "CmdKnifeZone", ADMIN_CVAR);
	register_clcmd("kz_vis", "CmdKnifeZone_Visualize", ADMIN_CVAR);
	register_clcmd("kz_addsize", "CmdKnifeZone_AddSize", ADMIN_CVAR);
	register_clcmd("kz_setsize", "CmdKnifeZone_SetSize", ADMIN_CVAR);
	register_clcmd("kz_addloc", "CmdKnifeZone_AddLoc", ADMIN_CVAR);
	register_clcmd("kz_setloc", "CmdKnifeZone_SetLoc", ADMIN_CVAR);
	register_clcmd("kz_listall", "CmdKnifeZone_ListAll", ADMIN_CVAR);
	register_clcmd("kz_saveall", "CmdKnifeZone_SaveAll", ADMIN_CVAR);
	register_clcmd("kz_deleteall", "CmdKnifeZone_DeleteAll", ADMIN_CVAR);
	register_clcmd("kz_remove", "CmdKnifeZone_Remove", ADMIN_CVAR);
	register_clcmd("kz_test", "cmdSet_test", ADMIN_CVAR);
	register_clcmd("kz_fwd", "cmdSet_ham_fwd", ADMIN_CVAR);
	
	fwd_Ham_Touch = RegisterHam(Ham_Touch, "info_target", "HAM_TouchDetector__pre", 0);
	RegisterHam(Ham_TraceAttack, "player", "HAM_TrackAttack__pre", 0);

	set_task(0.1, "OnMapStart",_,_,_,"c");
	#if defined NOTFULL
		set_task(0.5, "IsValid",_,_,_,"c");
	#endif
	
}

new bool:ham_fwd_enabled = true;
public cmdSet_ham_fwd(id)
{
	ham_fwd_enabled = !ham_fwd_enabled;
	if(ham_fwd_enabled)
		EnableHamForward(fwd_Ham_Touch);
	else
		DisableHamForward(fwd_Ham_Touch);
	client_print_color(0, print_team_default, "^4[DEBUG] ^1%b!", ham_fwd_enabled);
}

new bool:zonetest[33] = false;
public cmdSet_test(id)
{
	zonetest[id] = !zonetest[id];
	client_print_color(0, print_team_default, "^4[DEBUG] ^1%b!", zonetest[id]);
}

public Advert()
{
	client_print_color(0, print_team_default, "^4[%s] ^1A szerveren ^4%s^1 által készített ^3%s_v%s^1 fut!",PLUGIN,AUTHOR,PLUGIN,VERSION);
}

#if defined NOTFULL
	public plugin_cfg()
	{
		g_SqlTuple = SQL_MakeDbTuple(SQLINFO[0], SQLINFO[1], SQLINFO[2], SQLINFO[3]);
	}

	public IsValid()
	{
		new Query[512];
		formatex(Query, charsmax(Query), "SELECT ALLOWED FROM PluginProduct WHERE ID = 1;")
		SQL_ThreadQuery(g_SqlTuple, "CheckInfo", Query);
	}

	public CheckInfo(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime) 
	{
		if(FailState == TQUERY_CONNECT_FAILED)
			set_fail_state("[KNIFEZONE E-2] Bocsi de nem tudok az ellenőrző adatbázishoz csatlakozni");
		else if(FailState == TQUERY_QUERY_FAILED)
			set_fail_state("[KNIFEZONE E-3] Bocsi de nem tudok az ellenőrző adatbázishoz csatlakozni");
		if(Errcode)
			log_amx("[HIBA*] HIBAT DOBTAM: %s",Error);

		if(SQL_NumRows(Query) > 0)
		{
			if(!SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "ALLOWED")))
			{
				set_fail_state("[KNIFEZONE E-0] A pluginod ki lett kapcsova");
			}
		}
		else set_fail_state("[KNIFEZONE E-1] Bocsi de nem tudok az ellenőrző adatbázishoz csatlakozni");
	}
#endif

public HAM_TouchDetector__pre(iEnt, Touched)
{
	if(!is_valid_ent(iEnt) || !is_valid_ent(Touched))
		return HAM_IGNORED;

	new classname[32];
	entity_get_string(iEnt, EV_SZ_classname, classname, charsmax(classname));
	if(!equal(classname, _CLASSNAME))
		return HAM_IGNORED;

	if(is_user_connected(Touched))
	{
		if(zonetest[Touched])
			client_print_color(Touched, print_team_default, "^4[DEBUG] Zonába vagy! %.4f", get_gametime())
		entity_set_float(Touched, EV_FL_fuser1, (get_gametime() + 0.1) );
	}
		
	
	return HAM_IGNORED;
} 

public HAM_TrackAttack__pre(victim, attacker, Float:damage, Float:dir[3], ptr, bits)
{
	if(	is_user_connected(victim) && 
		is_user_connected(attacker) && 
		(entity_get_float(victim, EV_FL_fuser1) > get_gametime() || entity_get_float(attacker, EV_FL_fuser1) > get_gametime()) && 
		get_user_weapon(attacker, _, _) != CSW_KNIFE)
		return HAM_SUPERCEDE;
	return HAM_IGNORED;
}

public CmdKnifeZone(id)
{
	if( !(get_user_flags(id) & ADMIN_IMMUNITY) )
		return;

	new arg_name[32];
	read_argv(1, arg_name, charsmax(arg_name));
	if(arg_name[0] == EOS)
	{ 
		client_print(id, print_console, "kz <#Name>");
		return;
	}

	new Float:Origin[3];
	pev(id, pev_origin, Origin);
	Origin[0] = float(floatround(Origin[0]));
	Origin[1] = float(floatround(Origin[1]));
	Origin[2] = float(floatround(Origin[2]));

	knifezone(arg_name, Origin, Float:{-100.0, -100.0, -100.0}, Float:{100.0, 100.0, 100.0}, true);
	client_print_color(id, print_team_default, "^4[%s] ^1Létrehoztál egy Blockert! Név:%s",PLUGIN, arg_name);
}

public CmdKnifeZone_Visualize(id)
{
	if( !(get_user_flags(id) & ADMIN_IMMUNITY) )
		return;

	new arg1[32], arg2[32];
	read_argv(1, arg1, charsmax(arg1));
	read_argv(2, arg2, charsmax(arg2));
	if(arg1[0] == EOS)
	{ 
		client_print(id, print_console, "kz_vis <#0 - invisible / 1 - visible> <#kz_id>");
		return;
	}

	new iEnt = -1;

	if(arg2[0] == EOS)
	{ 
		client_print(id, print_console, "kz_vis <#0 - invisible / 1 - visible> <(Optional) #kz_id>");
		return;
	}
	iEnt = str_to_num(arg2);
	if(is_valid_ent(iEnt))
	{
		new classname[32];
		entity_get_string(iEnt, EV_SZ_classname, classname, charsmax(classname));
		if(!equal(classname, _CLASSNAME))
		{
			client_print_color(id, print_team_default, _MSG_ERROR,PLUGIN);
			return;
		}
	}

	if(str_to_num(arg1) > 0)
		VisualizeBlocker(iEnt, true);
	else
		VisualizeBlocker(iEnt, false);

	client_print_color(id, print_team_default, "^4[%s] ^1Láthatová tettél egy blockert!",PLUGIN);
}

public CmdKnifeZone_AddSize(id)
{
	if( !(get_user_flags(id) & ADMIN_IMMUNITY) )
		return;

	new min_0[32], min_1[32], min_2[32], max_0[32], max_1[32], max_2[32], kz_id[32];

	read_argv(1, kz_id, charsmax(kz_id));
	read_argv(2, min_0, charsmax(min_0));
	read_argv(3, min_1, charsmax(min_1));
	read_argv(4, min_2, charsmax(min_2));
	read_argv(5, max_0, charsmax(max_0));
	read_argv(6, max_1, charsmax(max_1));
	read_argv(7, max_2, charsmax(max_2));

	if(min_0[0] == EOS || min_1[0] == EOS || min_2[0] == EOS || max_0[0] == EOS || max_1[0] == EOS || max_2[0] == EOS || kz_id[0] == EOS)
	{
	client_print(id, print_console, "kz_addsize <#kz_id> <#mins[0]> <#mins[1]> <mins[2]> <maxs[0]> <maxs[1]> <maxs[2]>");
	return;
	}
	new iEnt = str_to_num(kz_id);
	if(!is_valid_ent(iEnt))
	{
		client_print_color(id, print_team_default, _MSG_ERROR,PLUGIN);
		return;
	}
	new classname[32];
	entity_get_string(iEnt, EV_SZ_classname, classname, charsmax(classname));
	if(!equal(classname, _CLASSNAME))
	{
		client_print_color(id, print_team_default, _MSG_ERROR,PLUGIN);
		return;
	}
	new Float:Mins[3];
	new Float:Maxs[3];
	entity_get_vector(iEnt, EV_VEC_mins, Mins);
	entity_get_vector(iEnt, EV_VEC_maxs, Maxs);

	new Float:newVector[3];
	copy_vector(newVector, float(str_to_num(min_0)), float(str_to_num(min_1)), float(str_to_num(min_2)));
	sum_vector(Mins, newVector, Mins);
	copy_vector(newVector, float(str_to_num(max_0)), float(str_to_num(max_1)), float(str_to_num(max_2)));
	sum_vector(Maxs, newVector, Maxs);
	entity_set_size(iEnt, Mins, Maxs);
	client_print_color(id, print_team_default, "^4[%s] ^1Új értekek: Mins{%f.1 | %f.1 | %f.1} Maxs{%f.1 | %f.1 | %f.1}",PLUGIN, Mins[0], Mins[1], Mins[2], Maxs[0], Maxs[1], Maxs[2]);
}

public CmdKnifeZone_SetSize(id)
{
	if( !(get_user_flags(id) & ADMIN_IMMUNITY) )
		return;

	new min_0[32], min_1[32], min_2[32], max_0[32], max_1[32], max_2[32], kz_id[32];

	read_argv(1, kz_id, charsmax(kz_id));
	read_argv(2, min_0, charsmax(min_0));
	read_argv(3, min_1, charsmax(min_1));
	read_argv(4, min_2, charsmax(min_2));
	read_argv(5, max_0, charsmax(max_0));
	read_argv(6, max_1, charsmax(max_1));
	read_argv(7, max_2, charsmax(max_2));

	if(min_0[0] == EOS || min_1[0] == EOS || min_2[0] == EOS || max_0[0] == EOS || max_1[0] == EOS || max_2[0] == EOS || kz_id[0] == EOS)
	{ 
	client_print(id, print_console, "kz_setsize <#kz_id> <#mins[0]> <#mins[1]> <mins[2]> <maxs[0]> <maxs[1]> <maxs[2]>");
	return;
	}
	new iEnt = str_to_num(kz_id);
	if(!is_valid_ent(iEnt))
	{
		client_print_color(id, print_team_default, _MSG_ERROR,PLUGIN);
		return;
	}
	new classname[32];
	entity_get_string(iEnt, EV_SZ_classname, classname, charsmax(classname));
	if(!equal(classname, _CLASSNAME))
	{
		client_print_color(id, print_team_default, _MSG_ERROR,PLUGIN);
		return;
	}
	new Float:Mins[3];
	new Float:Maxs[3];
	new Float:newVector[3];
	copy_vector(newVector, float(str_to_num(min_0)), float(str_to_num(min_1)), float(str_to_num(min_2)));
	sum_vector(Mins, newVector, Mins);
	copy_vector(newVector, float(str_to_num(max_0)), float(str_to_num(max_1)), float(str_to_num(max_2)));
	sum_vector(Maxs, newVector, Maxs);
	entity_set_size(iEnt, Mins, Maxs);
	client_print_color(id, print_team_default, "^4[%s] ^1Új értekek: Mins{%f.1 | %f.1 | %f.1} Maxs{%f.1 | %f.1 | %f.1}",PLUGIN, Mins[0], Mins[1], Mins[2], Maxs[0], Maxs[1], Maxs[2]);
}

public CmdKnifeZone_AddLoc(id)
{
	if( !(get_user_flags(id) & ADMIN_IMMUNITY) )
		return;

	new origin_0[32], origin_1[32], origin_2[32], kz_id[32];

	read_argv(1, kz_id, charsmax(kz_id));
	read_argv(2, origin_0, charsmax(origin_0));
	read_argv(3, origin_1, charsmax(origin_1));
	read_argv(4, origin_2, charsmax(origin_2));

	if(origin_0[0] == EOS || origin_1[0] == EOS || origin_2[0] == EOS || kz_id[0] == EOS)
	{ 
	client_print(id, print_console, "kz_addloc <#kz_id> <#Origin[0]> <#Origin[1]> <#Origin[2]>");
	return;
	}
	new iEnt = str_to_num(kz_id);
	if(!is_valid_ent(iEnt))
	{
		client_print_color(id, print_team_default, _MSG_ERROR,PLUGIN);
		return;
	}
	new classname[32];
	entity_get_string(iEnt, EV_SZ_classname, classname, charsmax(classname));
	if(!equal(classname, _CLASSNAME))
	{
		client_print_color(id, print_team_default, _MSG_ERROR,PLUGIN);
		return;
	}

	new Float:Origin[3];
	pev(iEnt, pev_origin, Origin);
	new Float:newVector[3];
	copy_vector(newVector, float(str_to_num(origin_0)), float(str_to_num(origin_1)), float(str_to_num(origin_2)));
	sum_vector(Origin, newVector, Origin);
	entity_set_origin(iEnt, Origin);

	client_print_color(id, print_team_default, "^4[%s] ^1Új értekek: Origin{%f.1 | %f.1 | %f.1} ",PLUGIN, Origin[0], Origin[1], Origin[2]);
}

public CmdKnifeZone_SetLoc(id)
{
	if( !(get_user_flags(id) & ADMIN_IMMUNITY) )
		return;

	new origin_0[32], origin_1[32], origin_2[32], kz_id[32];

	read_argv(1, kz_id, charsmax(kz_id));
	read_argv(2, origin_0, charsmax(origin_0));
	read_argv(3, origin_1, charsmax(origin_1));
	read_argv(4, origin_2, charsmax(origin_2));

	if(origin_0[0] == EOS || origin_1[0] == EOS || origin_2[0] == EOS || kz_id[0] == EOS)
	{ 
		client_print(id, print_console, "kz_setloc <#kz_id> <#Origin[0]> <#Origin[1]> <#Origin[2]>");
		return;
	}
	new iEnt = str_to_num(kz_id);
	if(!is_valid_ent(iEnt))
	{
		client_print_color(id, print_team_default, _MSG_ERROR,PLUGIN);
		return;
	}
	new classname[32];
	entity_get_string(iEnt, EV_SZ_classname, classname, charsmax(classname));
	if(!equal(classname, _CLASSNAME))
	{
		client_print_color(id, print_team_default, _MSG_ERROR,PLUGIN);
		return;
	}

	new Float:Origin[3];
	copy_vector(Origin, float(str_to_num(origin_0)), float(str_to_num(origin_1)), float(str_to_num(origin_2)));
	entity_set_origin(iEnt, Origin);

	client_print_color(id, print_team_default, "^4[%s] ^1Új értekek: Origin{%f.1 | %f.1 | %f.1} ",PLUGIN, Origin[0], Origin[1], Origin[2]);
}

public CmdKnifeZone_Remove(id)
{
	if( !(get_user_flags(id) & ADMIN_IMMUNITY) )
		return;

	new arg[32];
	read_argv(1, arg, charsmax(arg));
	new iEnt;


	if(arg[0] == EOS)
	{
		new body;
		get_user_aiming(id, iEnt, body);
		if(!is_valid_ent(iEnt))
		{
			client_print_color(id, print_team_default, _MSG_ERROR,PLUGIN);
			return;
		}
		new classname[32];
		entity_get_string(iEnt, EV_SZ_classname, classname, charsmax(classname));
		if(!equal(classname, _CLASSNAME))
		{
			client_print_color(id, print_team_default, _MSG_ERROR,PLUGIN);
			return;
		}
	}
	else
	{
		iEnt = str_to_num(arg);
		if(!is_valid_ent(iEnt))
		{
			client_print_color(id, print_team_default, _MSG_ERROR,PLUGIN);
			return;
		}
		new classname[32];
		entity_get_string(iEnt, EV_SZ_classname, classname, charsmax(classname));
		if(!equal(classname, _CLASSNAME))
		{
			client_print_color(id, print_team_default, _MSG_ERROR,PLUGIN);
			return;
		}
	}


	new Float:Mins[3];
	new Float:Maxs[3];
	new Float:Origin[3];
	entity_get_vector(iEnt, EV_VEC_mins, Mins);
	entity_get_vector(iEnt, EV_VEC_maxs, Maxs);
	pev(iEnt, pev_origin, Origin);
	client_print_color(id, print_team_default, "^4[%s] ^1Törölt értekek: Mins{%f.1 | %f.1 | %f.1} Maxs{%f.1 | %f.1 | %f.1} Origin{%f.1 | %f.1 | %f.1}",PLUGIN, Mins[0], Mins[1], Mins[2], Maxs[0], Maxs[1], Maxs[2], Origin[0], Origin[1], Origin[2]);
	VisualizeBlocker(iEnt, false);
	remove_entity(iEnt);
}

public CmdKnifeZone_ListAll(id)
{
	if( !(get_user_flags(id) & ADMIN_IMMUNITY) )
		return;

	new iEnt = -1
	while((iEnt = find_ent_by_class(iEnt, _CLASSNAME)))
	{
		if(!is_valid_ent(iEnt))
			continue;
		
		static Name[32];
		static Float:Origin[3];
		static Float:Mins[3];
		static Float:Maxs[3];
		
		entity_get_string(iEnt, EV_SZ_globalname, Name, 31);
		entity_get_vector(iEnt, EV_VEC_origin, Origin);
		entity_get_vector(iEnt, EV_VEC_mins, Mins);
		entity_get_vector(iEnt, EV_VEC_maxs, Maxs);
		
		console_print(id, "[%s - %i]", Name, iEnt);
		console_print(id, "Mins{%f.1 | %f.1 | %f.1}", Mins[0], Mins[1], Mins[2]);
		console_print(id, "Maxs{%f.1 | %f.1 | %f.1}", Maxs[0], Maxs[1], Maxs[2]);
		console_print(id, "Origin{%f.1 | %f.1 | %f.1}", Origin[0], Origin[1], Origin[2]);
	}
}

public CmdKnifeZone_SaveAll(id)
{
	if( !(get_user_flags(id) & ADMIN_IMMUNITY) )
		return;
	
	nvault_prune(g_hVault, 0, 2147483647);
	new iEnt = -1;
	new counter = 0;
	while((iEnt = find_ent_by_class(iEnt, _CLASSNAME)))
	{
		if(!is_valid_ent(iEnt))
			continue;
		
		static Name[32];
		static Float:Origin[3];
		static Float:Mins[3];
		static Float:Maxs[3];
		
		entity_get_string(iEnt, EV_SZ_globalname, Name, 31);
		entity_get_vector(iEnt, EV_VEC_origin, Origin);
		entity_get_vector(iEnt, EV_VEC_mins, Mins);
		entity_get_vector(iEnt, EV_VEC_maxs, Maxs);
		
		new temp[Zone];
		copy(temp[zName], 31, Name);
		sum_vector(temp[zLocation], Origin, temp[zLocation]);
		sum_vector(temp[zMins], Mins, temp[zMins]);
		sum_vector(temp[zMaxs], Maxs, temp[zMaxs]);

		new str[128];
		zone_to_str(temp, str, charsmax(str));
		new num[8];
		num_to_str(counter, num, 7);
		nvault_set( g_hVault, num, str);
		counter++;
	}
}

public CmdKnifeZone_DeleteAll(id)
{
	if( !(get_user_flags(id) & ADMIN_IMMUNITY) )
		return;

	nvault_prune(g_hVault, 0, 2147483647);
}

public OnMapStart()
{
	new counter = 0;
	do
	{
		new num[8];
		num_to_str(counter, num, 7);

		new str[128];
		nvault_get( g_hVault, num , str , 127);
		counter++;

		if(str[0] == EOS)
			break;
		
		new temp[Zone];
		str_to_zone(str, temp);

		knifezone(temp[zName], temp[zLocation], temp[zMins], temp[zMaxs], false);
	} while(true)
}


new bool:IsZone = false;
public knifezone(Name[32], Float:Location[3], Float:Mins[3], Float:Maxs[3], bool:Visual)
{
	if(!IsZone)
	{
		IsZone = true;
		set_task(150.0, "Advert",_,_,_,"b");
	}
	new iEnt = create_entity("info_target");
	entity_set_origin(iEnt, Location);
	entity_set_vector(iEnt, EV_VEC_angles, Float:{ 0.0, 0.0, 0.0 });
	entity_set_float(iEnt, EV_FL_takedamage, 0.0);
	entity_set_string(iEnt, EV_SZ_classname, _CLASSNAME);
	entity_set_string(iEnt, EV_SZ_globalname, Name);
	entity_set_int(iEnt, EV_INT_movetype, MOVETYPE_FLY);
	entity_set_int(iEnt, EV_INT_groupinfo, _KZ_GROUP);
	entity_set_int(iEnt, EV_INT_solid, SOLID_TRIGGER);
	entity_set_size(iEnt, Mins, Maxs);

	VisualizeBlocker(iEnt, Visual);
}

public VisualizeBlocker(iEnt, bool:Activate)
{
	if(!Activate && task_exists(_TASKOFFSET + iEnt))
		remove_task(_TASKOFFSET + iEnt);
	else if(Activate && !task_exists(_TASKOFFSET + iEnt))
		set_task(0.1, "VisualizeBox",_TASKOFFSET + iEnt,_,_,"b");
}

public VisualizeBox(TASK)
{
    new iEnt = TASK - _TASKOFFSET;
    new Float:Origin[3];
    pev(iEnt, pev_origin, Origin);
    
    new Float:Mins[3];
    new Float:Maxs[3];
    entity_get_vector(iEnt, EV_VEC_mins, Mins);
    entity_get_vector(iEnt, EV_VEC_maxs, Maxs);
    new Float:Start[3];
    new Float:End[3];

    copy_vector(Start, Maxs[0], Maxs[1], Maxs[2]);  sum_vector(Start, Origin, Start);
    copy_vector(End, Mins[0], Maxs[1], Maxs[2]);    sum_vector(End, Origin, End);
    CreateLaster(Start, End, {255, 0, 0, 127});

    copy_vector(Start, Maxs[0], Maxs[1], Maxs[2]);  sum_vector(Start, Origin, Start);
    copy_vector(End, Maxs[0], Mins[1], Maxs[2]);    sum_vector(End, Origin, End);
    CreateLaster(Start, End, {0, 255, 0, 127});

    copy_vector(Start, Maxs[0], Maxs[1], Maxs[2]);  sum_vector(Start, Origin, Start);
    copy_vector(End, Maxs[0], Maxs[1], Mins[2]);    sum_vector(End, Origin, End);
    CreateLaster(Start, End, {0, 0, 255, 127});

    //----------------------

    copy_vector(Start, Mins[0], Mins[1], Mins[2]);  sum_vector(Start, Origin, Start);
    copy_vector(End, Maxs[0], Mins[1], Mins[2]);    sum_vector(End, Origin, End);
    CreateLaster(Start, End, {255, 0, 0, 127});

    copy_vector(Start, Mins[0], Mins[1], Mins[2]);  sum_vector(Start, Origin, Start);
    copy_vector(End, Mins[0], Maxs[1], Mins[2]);    sum_vector(End, Origin, End);
    CreateLaster(Start, End, {0, 255, 0, 127});

    copy_vector(Start, Mins[0], Mins[1], Mins[2]);  sum_vector(Start, Origin, Start);
    copy_vector(End, Mins[0], Mins[1], Maxs[2]);    sum_vector(End, Origin, End);
    CreateLaster(Start, End, {0, 0, 255, 127});

    //--------------------------

    copy_vector(Start, Mins[0], Maxs[1], Maxs[2]);  sum_vector(Start, Origin, Start);
    copy_vector(End, Mins[0], Maxs[1], Mins[2]);    sum_vector(End, Origin, End);
    CreateLaster(Start, End, {255, 255, 255, 127});
    
    copy_vector(Start, Maxs[0], Maxs[1], Mins[2]);  sum_vector(Start, Origin, Start);
    copy_vector(End, Maxs[0], Mins[1], Mins[2]);    sum_vector(End, Origin, End);
    CreateLaster(Start, End, {255, 255, 255, 127});

    copy_vector(Start, Maxs[0], Maxs[1], Mins[2]);  sum_vector(Start, Origin, Start);
    copy_vector(End, Mins[0], Maxs[1], Mins[2]);    sum_vector(End, Origin, End);
    CreateLaster(Start, End, {255, 255, 255, 127});

    copy_vector(Start, Maxs[0], Mins[1], Maxs[2]);  sum_vector(Start, Origin, Start);
    copy_vector(End, Maxs[0], Mins[1], Mins[2]);    sum_vector(End, Origin, End);
    CreateLaster(Start, End, {255, 255, 255, 127});

    copy_vector(Start, Maxs[0], Mins[1], Maxs[2]);  sum_vector(Start, Origin, Start);
    copy_vector(End, Mins[0], Mins[1], Maxs[2]);    sum_vector(End, Origin, End);
    CreateLaster(Start, End, {255, 255, 255, 127});

    copy_vector(Start, Mins[0], Maxs[1], Maxs[2]);  sum_vector(Start, Origin, Start);
    copy_vector(End, Mins[0], Mins[1], Maxs[2]);    sum_vector(End, Origin, End);
    CreateLaster(Start, End, {255, 255, 255, 127});
}

public plugin_end()
{
	nvault_close(g_hVault);
}

/**
* It will copy the values from one to a nother
*
* @param dest   Destination vector buffer to copy to.
* @param src    Source vector buffer to copy from.
*
* @return          1 if successful, 0 otherwise
*/
stock copy_vector(Float:dest[3], Float:src0, Float:src1, Float:src2)
{

    dest[0] = src0;
    dest[1] = src1;
    dest[2] = src2;

    return 1;
}

/**
* It's sum two velicity into one.
*
* @param Velocity1      The first vector what need to be summed.
* @param Velocity2      The second vector what need to be summed.
* @param new_Velocity   The output vector.
*
* @return          1 if successful, 0 otherwise
*/
stock sum_vector(Float:Velocity1[3], Float:Velocity2[3], Float:new_Velocity[3])
{

    new_Velocity[0] = Velocity1[0] + Velocity2[0];
    new_Velocity[1] = Velocity1[1] + Velocity2[1];
    new_Velocity[2] = Velocity1[2] + Velocity2[2];

    return 1;
}

/**
* It's create a colurable laserbeam bitween 2 point
*
* @param StartOrigin    Start position of the laserbeam.
* @param EndOrigin      End position of the laserbeam.
* @param Color          RGBA Color of the laserbeam in 255 range.
*
* @return          1 if successful, 0 otherwise
*/
stock CreateLaster(Float:StartOrigin[3], Float:EndOrigin[3], Color[4])
{
    message_begin(MSG_BROADCAST ,SVC_TEMPENTITY)
    write_byte(TE_BEAMPOINTS)
    engfunc(EngFunc_WriteCoord, StartOrigin[0])
    engfunc(EngFunc_WriteCoord, StartOrigin[1])
    engfunc(EngFunc_WriteCoord, StartOrigin[2])
    engfunc(EngFunc_WriteCoord, EndOrigin[0])
    engfunc(EngFunc_WriteCoord, EndOrigin[1])
    engfunc(EngFunc_WriteCoord, EndOrigin[2])
    write_short(g_SprId_LaserBeam)	// sprite index
    write_byte(0)	// starting frame
    write_byte(0)	// frame rate in 0.1's
    write_byte(1)	// life in 0.1's
    write_byte(20)	// line width in 0.1's
    write_byte(0)	// noise amplitude in 0.01's
    write_byte(Color[0])	// Red
    write_byte(Color[1])	// Green
    write_byte(Color[2])	// Blue
    write_byte(Color[3])	// brightness
    write_byte(0)	// scroll speed in 0.1's
    message_end()
}

stock zone_to_str(zone[Zone], str[], len)
{
	formatex(str, len, "%s|%i|%i|%i|%i|%i|%i|%i|%i|%i",	zone[zName], 
														floatround(zone[zLocation][0]),
														floatround(zone[zLocation][1]),
														floatround(zone[zLocation][2]),
														floatround(zone[zMins][0]),
														floatround(zone[zMins][1]),
														floatround(zone[zMins][2]),
														floatround(zone[zMaxs][0]),
														floatround(zone[zMaxs][1]),
														floatround(zone[zMaxs][2]));
}

stock str_to_zone(str[], temp[Zone])
{
	new pos;
	new tempstr[8];
	pos += split_string(str[ pos ], "|", temp[zName], charsmax(temp[zName]));
	pos += split_string(str[ pos ], "|", tempstr, charsmax(tempstr)); temp[zLocation][0] = float(str_to_num(tempstr));
	pos += split_string(str[ pos ], "|", tempstr, charsmax(tempstr)); temp[zLocation][1] = float(str_to_num(tempstr));
	pos += split_string(str[ pos ], "|", tempstr, charsmax(tempstr)); temp[zLocation][2] = float(str_to_num(tempstr));
	pos += split_string(str[ pos ], "|", tempstr, charsmax(tempstr)); temp[zMins][0] = float(str_to_num(tempstr));
	pos += split_string(str[ pos ], "|", tempstr, charsmax(tempstr)); temp[zMins][1] = float(str_to_num(tempstr));
	pos += split_string(str[ pos ], "|", tempstr, charsmax(tempstr)); temp[zMins][2] = float(str_to_num(tempstr));
	pos += split_string(str[ pos ], "|", tempstr, charsmax(tempstr)); temp[zMaxs][0] = float(str_to_num(tempstr));
	pos += split_string(str[ pos ], "|", tempstr, charsmax(tempstr)); temp[zMaxs][1] = float(str_to_num(tempstr));
	pos += split_string(str[ pos ], "|", tempstr, charsmax(tempstr)); temp[zMaxs][2] = float(str_to_num(tempstr));
}