#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <reapi>
#include <rt_api>

public stock const PLUGIN[] = "Revive Teammates: Core";
public stock const CFG_FILE[] = "addons/amxmodx/configs/rt_configs/rt_core.cfg";

// Custom Player Models https://dev-cs.ru/resources/928/
native bool:custom_player_models_get_path(const player, path[] = "", length = 0);
native bool:custom_player_models_get_body(const player, const any:team, &body);
native bool:custom_player_models_get_skin(const player, const any:team, &skin);

enum CVARS {
	Float:REVIVE_TIME,
	Float:ANTIFLOOD_TIME,
	Float:CORPSE_TIME,
	Float:SEARCH_RADIUS,
	FORCE_FWD_MODE,
	CORPSE_MODEL_MODE
};

new g_eCvars[CVARS];

enum Forwards {
	ReviveStart,
	ReviveStart_Post,
	ReviveLoop_Pre,
	ReviveLoop_Post,
	ReviveEnd,
	ReviveCancelled,
	CreatingCorpseStart,
	CreatingCorpseEnd
};

new g_eForwards[Forwards];

new g_iPlantingPluginID;

new Float:g_fLastUse[MAX_PLAYERS + 1], g_iTimeUntil[MAX_PLAYERS + 1];

new Float:g_fVecSpawnOrigin[3];
new HookChain:g_pHook_GetPlayerSpawnSpot;
new g_szModel[MAX_PLAYERS + 1][64];
new Modes:g_iCurrentMode[MAX_PLAYERS + 1] = { MODE_NONE, ... };

public plugin_precache() {
	CreateCvars();

	server_cmd("exec %s", CFG_FILE);
	server_exec();
}

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHORS);

	register_dictionary("rt_library.txt");

	register_message(get_user_msgid("ClCorpse"), "MessageHook_ClCorpse");

	RegisterHookChain(RG_CSGameRules_CleanUpMap, "CSGameRules_CleanUpMap_Post", true);
	RegisterHookChain(RG_CBasePlayer_UseEmpty, "CBasePlayer_UseEmpty_Pre", false);
	DisableHookChain((g_pHook_GetPlayerSpawnSpot = RegisterHookChain(RG_CSGameRules_GetPlayerSpawnSpot, "CSGameRules_GetPlayerSpawnSpot_Pre", false)));
	RegisterHookChain(RG_CBasePlayer_Spawn, "CBasePlayer_Spawn_Pre", false);
	RegisterHookChain(RG_CBasePlayer_SetClientUserInfoModel, "CBasePlayer_SetClientUserInfoModel_Pre");

	g_eForwards[ReviveStart] = CreateMultiForward("rt_revive_start", ET_STOP, FP_CELL, FP_CELL, FP_CELL, FP_CELL);
	g_eForwards[ReviveStart_Post] = CreateMultiForward("rt_revive_start_post", ET_IGNORE, FP_CELL, FP_CELL, FP_CELL, FP_CELL);
	g_eForwards[ReviveLoop_Pre] = CreateMultiForward("rt_revive_loop_pre", ET_STOP, FP_CELL, FP_CELL, FP_CELL, FP_FLOAT, FP_CELL);
	g_eForwards[ReviveLoop_Post] = CreateMultiForward("rt_revive_loop_post", ET_IGNORE, FP_CELL, FP_CELL, FP_CELL, FP_FLOAT, FP_CELL);
	g_eForwards[ReviveEnd] = CreateMultiForward("rt_revive_end", ET_IGNORE, FP_CELL, FP_CELL, FP_CELL, FP_CELL);
	g_eForwards[ReviveCancelled] = CreateMultiForward("rt_revive_cancelled", ET_IGNORE, FP_CELL, FP_CELL, FP_CELL, FP_CELL);
	g_eForwards[CreatingCorpseStart] = CreateMultiForward("rt_creating_corpse_start", ET_STOP, FP_CELL, FP_CELL);
	g_eForwards[CreatingCorpseEnd] = CreateMultiForward("rt_creating_corpse_end", ET_IGNORE, FP_CELL, FP_CELL, FP_ARRAY);

	g_iPlantingPluginID = is_plugin_loaded("rt_planting.amxx", true);
}

public client_disconnected(iPlayer) {
	g_fLastUse[iPlayer] = 0.0;

	PlayerSpawnOrDisconnect(iPlayer);
}

public client_remove(iPlayer) {
	g_iCurrentMode[iPlayer] = MODE_NONE;
}

public CSGameRules_CleanUpMap_Post() {
	arrayset(g_iCurrentMode, MODE_NONE, sizeof(g_iCurrentMode));
	RemoveCorpses(0, DEAD_BODY_CLASSNAME);
}

public CBasePlayer_UseEmpty_Pre(const iActivator) {
	if(~get_entvar(iActivator, var_flags) & FL_ONGROUND)
		return;

	new iEnt = RT_NULLENT;

	new Float:fVecPlOrigin[3], Float:fVecEntOrigin[3];
	get_entvar(iActivator, var_origin, fVecPlOrigin);

	while((iEnt = rg_find_ent_by_class(iEnt, DEAD_BODY_CLASSNAME)) > 0) {
		if(!is_nullent(iEnt)) {
			get_entvar(iEnt, var_vuser4, fVecEntOrigin);

			if(ExecuteHam(Ham_FVecInViewCone, iActivator, fVecEntOrigin) && vector_distance(fVecPlOrigin, fVecEntOrigin) < g_eCvars[SEARCH_RADIUS]) {
				Corpse_Use(iEnt, iActivator);
				return;
			}
		}
	}
}

public CSGameRules_GetPlayerSpawnSpot_Pre(const iPlayer) {
	DisableHookChain(g_pHook_GetPlayerSpawnSpot);

	set_entvar(iPlayer, var_flags, get_entvar(iPlayer, var_flags) | FL_DUCKING);

	set_entvar(iPlayer, var_velocity, NULL_VECTOR);
	set_entvar(iPlayer, var_v_angle, NULL_VECTOR);

	new Float:fVecAngles[3];
	get_entvar(iPlayer, var_angles, fVecAngles);
	fVecAngles[0] = fVecAngles[2] = 0.0;
	set_entvar(iPlayer, var_angles, fVecAngles);

	set_entvar(iPlayer, var_punchangle, NULL_VECTOR);
	set_entvar(iPlayer, var_fixangle, 1);

	engfunc(EngFunc_SetSize, iPlayer, Float:{-16.000000, -16.000000, -18.000000}, Float:{16.000000, 16.000000, 32.000000});
	engfunc(EngFunc_SetOrigin, iPlayer, g_fVecSpawnOrigin);

	SetHookChainReturn(ATYPE_INTEGER, RT_NULLENT);
	return HC_SUPERCEDE;
}

public CBasePlayer_Spawn_Pre(const iPlayer) {
	PlayerSpawnOrDisconnect(iPlayer);
}

public CBasePlayer_SetClientUserInfoModel_Pre(const iPlayer, szInfoBuffer[], szNewModel[]) {
	copy(g_szModel[iPlayer], charsmax(g_szModel[]), szNewModel);
}

public Corpse_Use(const iEnt, const iActivator) {
	if(is_nullent(iEnt) || get_member_game(m_bRoundTerminating) || !ExecuteHam(Ham_IsPlayer, iActivator))
		return;

	new iPlayer = get_entvar(iEnt, var_owner);
	new TeamName:iPlTeam = TeamName:get_member(iPlayer, m_iTeam);
	new TeamName:iActTeam = TeamName:get_member(iActivator, m_iTeam);
	new TeamName:iEntTeam = TeamName:get_entvar(iEnt, var_team);
	new Modes:eCurrentMode = (iActTeam == iPlTeam) ? MODE_REVIVE : MODE_PLANT;

	if(g_iPlantingPluginID == INVALID_PLUGIN_ID && eCurrentMode == MODE_PLANT)
		return;

	if(iActTeam == TEAM_SPECTATOR || iPlTeam == TEAM_SPECTATOR)
		return;

	if(iEntTeam != iPlTeam) {
		NotifyClient(iActivator, print_team_red, "RT_CHANGE_TEAM");
		return;
	}

	if(get_entvar(iEnt, var_iuser1)) {
		NotifyClient(iActivator, print_team_red, "RT_ACTIVATOR_EXISTS");
		return;
	}

	if(!is_user_alive(iActivator)) {
		ResetCorpseThink(g_eForwards[ReviveCancelled], iEnt, iPlayer, iActivator, eCurrentMode);
		return;
	}

	new fwRet;
	ExecuteForward(g_eForwards[ReviveStart], fwRet, iEnt, iPlayer, iActivator, eCurrentMode);

	if(fwRet == PLUGIN_HANDLED) {
		ResetCorpseThink(g_eForwards[ReviveCancelled], iEnt, iPlayer, iActivator, eCurrentMode);
		return;
	}

	new Float:fGameTime = get_gametime();

	if(g_fLastUse[iActivator] > fGameTime) {
		NotifyClient(iActivator, print_team_red, "RT_ANTI_FLOOD");
		ResetCorpseThink(g_eForwards[ReviveCancelled], iEnt, iPlayer, iActivator, eCurrentMode);
		return;
	}

	g_fLastUse[iActivator] = fGameTime + g_eCvars[ANTIFLOOD_TIME];

	NotifyClient(iActivator, print_team_blue, eCurrentMode == MODE_REVIVE ? "RT_TIMER_REVIVE" : "RT_TIMER_PLANT", iPlayer);

	g_iTimeUntil[iActivator] = 0;

	set_entvar(iEnt, var_iuser1, iActivator);
	set_entvar(iEnt, var_iuser2, eCurrentMode);
	set_entvar(iEnt, var_fuser1, fGameTime + g_eCvars[REVIVE_TIME]);
	set_entvar(iEnt, var_fuser3, g_eCvars[REVIVE_TIME]);
	set_entvar(iEnt, var_nextthink, fGameTime + 0.1);

	g_iCurrentMode[iActivator] = eCurrentMode;

	ExecuteForward(g_eForwards[ReviveStart_Post], _, iEnt, iPlayer, iActivator, eCurrentMode);
}

public Corpse_Think(const iEnt) {
	if(is_nullent(iEnt))
		return;

	new iPlayer = get_entvar(iEnt, var_owner);
	new iActivator = get_entvar(iEnt, var_iuser1);
	new Float:fGameTime = get_gametime();

	if(!iActivator) {
		if(g_eCvars[CORPSE_TIME] && Float:get_entvar(iEnt, var_fuser4) < fGameTime) {
			RemoveCorpses(iPlayer, DEAD_BODY_CLASSNAME);
			return;
		}

		set_entvar(iEnt, var_nextthink, fGameTime + 1.0);
		return;
	}

	new TeamName:iPlTeam = TeamName:get_member(iPlayer, m_iTeam);
	new TeamName:iEntTeam = TeamName:get_entvar(iEnt, var_team);
	new Modes:eCurrentMode = Modes:get_entvar(iEnt, var_iuser2);

	if(iEntTeam != iPlTeam) {
		NotifyClient(iActivator, print_team_red, "RT_CHANGE_TEAM");
		ResetCorpseThink(g_eForwards[ReviveCancelled], iEnt, iPlayer, iActivator, eCurrentMode);
		return;
	}

	if(~get_entvar(iActivator, var_button) & IN_USE) {
		NotifyClient(iActivator, print_team_red, eCurrentMode == MODE_REVIVE ? "RT_CANCELLED_REVIVE" : "RT_CANCELLED_PLANT");
		ResetCorpseThink(g_eForwards[ReviveCancelled], iEnt, iPlayer, iActivator, eCurrentMode);
		return;
	}

	new Float:fTimeUntil[2];
	fTimeUntil[0] = Float:get_entvar(iEnt, var_fuser1);
	fTimeUntil[1] = Float:get_entvar(iEnt, var_fuser3);

	g_iTimeUntil[iActivator]++;

	if(g_iTimeUntil[iActivator] == 10 || g_eCvars[FORCE_FWD_MODE]) {
		if(g_eCvars[FORCE_FWD_MODE]) {
			fTimeUntil[1] -= 0.1;
		}
		else {
			fTimeUntil[1] -= 1.0;
		}

		if(!is_user_alive(iActivator)) {
			ResetCorpseThink(g_eForwards[ReviveCancelled], iEnt, iPlayer, iActivator, eCurrentMode);
			return;
		}

		new fwRet;
		ExecuteForward(g_eForwards[ReviveLoop_Pre], fwRet, iEnt, iPlayer, iActivator, fTimeUntil[1], eCurrentMode);

		if(fwRet == PLUGIN_HANDLED) {
			ResetCorpseThink(g_eForwards[ReviveCancelled], iEnt, iPlayer, iActivator, eCurrentMode);
			return;
		}
	}

	if(fGameTime > fTimeUntil[0]) {
		new Modes:iMode = Modes:get_entvar(iEnt, var_iuser3);

		if(eCurrentMode == MODE_REVIVE && iMode != MODE_PLANT) {
			NotifyClient(iActivator, print_team_red, "RT_REVIVE", iPlayer);
			NotifyClient(iPlayer, print_team_red, "RT_REVIVED", iActivator);

			get_entvar(iActivator, var_origin, g_fVecSpawnOrigin);

			RemoveCorpses(iPlayer, DEAD_BODY_CLASSNAME);

			EnableHookChain(g_pHook_GetPlayerSpawnSpot);
			rg_round_respawn(iPlayer);
			DisableHookChain(g_pHook_GetPlayerSpawnSpot);

			if(is_user_alive(iPlayer))
				engfunc(EngFunc_SetOrigin, iPlayer, g_fVecSpawnOrigin);
		}

		if(!is_user_alive(iActivator)) {
			ResetCorpseThink(g_eForwards[ReviveCancelled], iEnt, iPlayer, iActivator, eCurrentMode);
			return;
		}

		g_iCurrentMode[iActivator] = MODE_NONE;

		ExecuteForward(g_eForwards[ReviveEnd], _, iEnt, iPlayer, iActivator, eCurrentMode);

		return;
	}

	if(g_iTimeUntil[iActivator] == 10 || g_eCvars[FORCE_FWD_MODE]) {
		if(!is_user_alive(iActivator)) {
			ResetCorpseThink(g_eForwards[ReviveCancelled], iEnt, iPlayer, iActivator, eCurrentMode);
			return;
		}

		ExecuteForward(g_eForwards[ReviveLoop_Post], _, iEnt, iPlayer, iActivator, fTimeUntil[1], eCurrentMode);

		g_iTimeUntil[iActivator] = 0;
	}

	set_entvar(iEnt, var_fuser3, fTimeUntil[1]);
	set_entvar(iEnt, var_nextthink, fGameTime + 0.1);
}

public MessageHook_ClCorpse() {
	if(get_member_game(m_bRoundTerminating))
		return PLUGIN_HANDLED;

	enum {
		arg_body = 10,
		arg_id = 12
	};

	new iPlayer = get_msg_arg_int(arg_id);
	new TeamName:iPlTeam = TeamName:get_member(iPlayer, m_iTeam);

	if(iPlTeam == TEAM_SPECTATOR || g_szModel[iPlayer][0] == EOS)
		return PLUGIN_HANDLED;

	new iEnt = rg_create_entity("info_target");

	new fwRet;
	ExecuteForward(g_eForwards[CreatingCorpseStart], fwRet, iEnt, iPlayer);

	if(fwRet == PLUGIN_HANDLED) {
		set_entvar(iEnt, var_flags, FL_KILLME);
		set_entvar(iEnt, var_nextthink, 0.0);
		return PLUGIN_HANDLED;
	}

	/*new szModel[32], szModelPath[MAX_RESOURCE_PATH_LENGTH];
	get_user_info(iPlayer, "model", szModel, charsmax(szModel));
	formatex(szModelPath, charsmax(szModelPath), "models/player/%s/%s.mdl", szModel, szModel);*/
	new szModelPath[MAX_RESOURCE_PATH_LENGTH];

	if(!custom_player_models_get_path(iPlayer, szModelPath, charsmax(szModelPath))) {
		if(!g_eCvars[CORPSE_MODEL_MODE]) {
			formatex(szModelPath, charsmax(szModelPath), "models/player/%s/%s.mdl", g_szModel[iPlayer], g_szModel[iPlayer]);
		}
		else {
			new szModel[64];
			rh_update_user_info(iPlayer);
			get_user_info(iPlayer, "model", szModel, charsmax(szModel));
			formatex(szModelPath, charsmax(szModelPath), "models/player/%s/%s.mdl", szModel, szModel);
		}
		set_entvar(iEnt, var_body, get_msg_arg_int(arg_body));
		set_entvar(iEnt, var_skin, get_entvar(iPlayer, var_skin));
	}
	else {
		new iBody, iSkin;
		custom_player_models_get_body(iPlayer, iPlTeam, iBody);
		custom_player_models_get_skin(iPlayer, iPlTeam, iSkin);
		set_entvar(iEnt, var_body, iBody);
		set_entvar(iEnt, var_skin, iSkin);
	}

	set_entvar(iEnt, var_modelindex, engfunc(EngFunc_ModelIndex, szModelPath));
	set_entvar(iEnt, var_model, szModelPath);
	//set_entvar(iEnt, var_renderfx, kRenderFxDeadPlayer);
	//set_entvar(iEnt, var_renderamt, float(iPlayer));

	set_entvar(iEnt, var_classname, DEAD_BODY_CLASSNAME);
	set_entvar(iEnt, var_sequence, get_entvar(iPlayer, var_sequence));
	set_entvar(iEnt, var_frame, 255.0);
	set_entvar(iEnt, var_owner, iPlayer);
	set_entvar(iEnt, var_team, iPlTeam);

	new Float:fVecOrigin[3];
	fVecOrigin[0] = float(get_msg_arg_int(2) / 128);
	fVecOrigin[1] = float(get_msg_arg_int(3) / 128);
	fVecOrigin[2] = float(get_msg_arg_int(4) / 128);
	//get_entvar(iPlayer, var_origin, fVecOrigin);
	engfunc(EngFunc_SetOrigin, iEnt, fVecOrigin);

	new Float:fVecAngles[3];
	get_entvar(iPlayer, var_angles, fVecAngles);
	set_entvar(iEnt, var_angles, fVecAngles);

	engfunc(EngFunc_GetBonePosition, iEnt, 2, fVecOrigin, fVecAngles);
	set_entvar(iEnt, var_vuser4, fVecOrigin);

	set_entvar(iEnt, var_fuser2, g_eCvars[SEARCH_RADIUS]);

	set_entvar(iEnt, var_nextthink, get_gametime() + 1.0);
	SetThink(iEnt, "Corpse_Think");

	if(g_eCvars[CORPSE_TIME])
		set_entvar(iEnt, var_fuser4, get_gametime() + g_eCvars[CORPSE_TIME]);

	fVecOrigin[2] += 20.0;

	ExecuteForward(g_eForwards[CreatingCorpseEnd], _, iEnt, iPlayer, PrepareArray(_:fVecOrigin, sizeof(fVecOrigin)));

	return PLUGIN_HANDLED;
}

stock PlayerSpawnOrDisconnect(const iPlayer) {
	new iActivator = RemoveCorpses(iPlayer, DEAD_BODY_CLASSNAME);

	if(is_user_connected(iActivator))
		NotifyClient(iActivator, print_team_red, "RT_DISCONNECTED");

	ResetCorpseThink(g_eForwards[ReviveCancelled], RT_NULLENT, iPlayer, iActivator, MODE_NONE);

	// TODO need to handle corpse user respawn
	//if(g_iCurrentMode[iPlayer]) { }
}

public CreateCvars() {
	bind_pcvar_float(create_cvar(
		"rt_revive_time",
		"6.0",
		FCVAR_NONE,
		"Duration of the player's resurrection(in seconds)",
		true,
		1.0),
		g_eCvars[REVIVE_TIME]
	);
	bind_pcvar_float(create_cvar(
		"rt_revive_antiflood",
		"3.0",
		FCVAR_NONE,
		"Duration of anti-flood resurrection(in seconds)",
		true,
		1.0),
		g_eCvars[ANTIFLOOD_TIME]
	);
	bind_pcvar_float(create_cvar(
		"rt_corpse_time",
		"30.0",
		FCVAR_NONE,
		"Duration of a corpse's life (in seconds). If you set it to 0, the corpse lives until the end of the round.",
		true,
		0.0),
		g_eCvars[CORPSE_TIME]
	);
	bind_pcvar_float(create_cvar(
		"rt_search_radius",
		"64.0",
		FCVAR_NONE,
		"Search radius for a corpse",
		true,
		1.0),
		g_eCvars[SEARCH_RADIUS]
	);
	bind_pcvar_num(create_cvar(
		"rt_force_fwd_mode",
		"0",
		FCVAR_NONE,
		"Execute forwards more often. Set this to 1 if 'rt_no_move 1' didn't work properly.",
		true,
		0.0,
		true,
		1.0),
		g_eCvars[FORCE_FWD_MODE]
	);
	bind_pcvar_num(create_cvar(
		"rt_corpse_model_mode",
		"0",
		FCVAR_NONE,
		"Try set this to 1 if corpses lose their custom model.",
		true,
		0.0,
		true,
		1.0),
		g_eCvars[CORPSE_MODEL_MODE]
	);
}

/**
 * Reset entity think
 *
 * @param eForward       Forward type
 * @param iEnt           Corpse entity index
 * @param iPlayer        Player id whose corpse
 * @param iActivator     Player id who ressurect
 * @param eMode          MODE_REVIVE - stopped the resurrection, MODE_PLANT - stopped planting
 *
 * @noreturn
 */
ResetCorpseThink(const eForward, const iEnt, iPlayer, iActivator, const Modes:eMode) {
	if(!is_nullent(iEnt)) {
		set_entvar(iEnt, var_nextthink, get_gametime() + 1.0);
		set_entvar(iEnt, var_iuser1, 0);
	}

	if(iActivator != RT_NULLENT) {
		g_iCurrentMode[iActivator] = MODE_NONE;
	}

	iPlayer = is_user_connected(iPlayer) ? iPlayer : RT_NULLENT;
	iActivator = is_user_connected(iActivator) ? iActivator : RT_NULLENT;

	ExecuteForward(eForward, _, iEnt, iPlayer, iActivator, eMode);
}

public plugin_natives() {
	set_native_filter("native_filter");
	register_native("rt_get_user_mode", "_rt_get_user_mode");
	register_native("rt_reset_use", "_rt_reset_use");
}

public Modes:_rt_get_user_mode() {
	enum { arg_user = 1 };

	return g_iCurrentMode[ get_param(arg_user) ];
}

public bool:_rt_reset_use() {
	enum { arg_user = 1 };

	new pPlayer = get_param(arg_user);

	if(g_iCurrentMode[pPlayer] == MODE_NONE) {
		return false;
	}

	new iEnt = RT_NULLENT;

	while((iEnt = rg_find_ent_by_class(iEnt, DEAD_BODY_CLASSNAME)) > 0) {
		if(!is_entity(iEnt)) {
			continue;
		}

		if(pPlayer == get_entvar(iEnt, var_iuser1)) {
			ResetCorpseThink(g_eForwards[ReviveCancelled], iEnt, get_entvar(iEnt, var_owner), pPlayer, get_entvar(iEnt, var_iuser2));
			return true;
		}
	}

	g_iCurrentMode[pPlayer] = MODE_NONE;
	return false;
}

public native_filter(const szNativeName[], iNativeID, iTrapMode) {
	return PLUGIN_HANDLED;
}