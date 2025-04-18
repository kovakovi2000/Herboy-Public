#pragma semicolon 1

#include <amxmodx>
#include <reapi>

enum eActions {
	ACTION_HEAL, ACTION_ARMOR, ACTION_WEAPON, ACTION_SPEED, ACTION_GODMODE, ACTION_NOCLIP,
	ACTION_UNAMMO, ACTION_FIRE, ACTION_INVISIBLE, ACTION_MULTIJUMP, ACTION_FREEZE, ACTION_SLAY2,
	ACTION_BURY, ACTION_UNBURY, ACTION_DISARM, ACTION_ROCKET, ACTION_REVIVE, ACTION_QUIT, ACTION_FLASH,
	ACTION_DRUG, ACTION_GLOW, ACTION_TELEPORT, ACTION_GIVEMONEY, ACTION_TAKEMONEY, ACTION_UBERSLAP,
	ACTION_USERORIGIN, ACTION_HRESPAWN, ACTION_TEAM, ACTION_SWAP, ACTION_PASS, ACTION_NOPASS,
	ACTION_EXTEND, ACTION_GLOWCOLORS, ACTION_TEAMSWAP, ACTION_ALLTALK, ACTION_GRAVITY
};

enum eFeatures {
	cmd[32],
	neededargs,
	eActions:action,
	action_access,
	description[128],
};

new const g_Actions[][eFeatures] = {
	{"amx_heal",		3,	ACTION_HEAL, 		ADMIN_LEVEL_A,		"<nick, #userid, authid or @team> <HP to give>"},
	{"amx_armor",		3,	ACTION_ARMOR, 		ADMIN_LEVEL_A,		"<nick, #userid, authid or @team> <ARMOR to give>"},
	{"amx_weapon",		3,	ACTION_WEAPON, 		ADMIN_LEVEL_C,		"<nick, #userid, authid or @team> <Weapon #>"},
	{"amx_speed",		3,	ACTION_SPEED, 		ADMIN_LEVEL_C,		"<nick, #userid, authid or @team> [Speed #]"},
	{"amx_godmode",		3,	ACTION_GODMODE, 	ADMIN_LEVEL_C,		"<nick, #userid, authid or @team> [0|1]"},
	{"amx_noclip",		3,	ACTION_NOCLIP, 		ADMIN_LEVEL_C,		"<nick, #userid, authid or @team> [0|1]"},
	{"amx_unammo",		3,	ACTION_UNAMMO, 		ADMIN_LEVEL_C,		"<nick, #userid, authid or @team> [0|1]"},
	{"amx_fire",		3,	ACTION_FIRE, 		ADMIN_LEVEL_A,		"<nick, #userid, authid or @team> [0|1]"},
	{"amx_invisible",	3,	ACTION_INVISIBLE, 	ADMIN_LEVEL_A,		"<nick, #userid, authid or @team> [0|1]"},
	{"amx_multijump",	3,	ACTION_MULTIJUMP, 	ADMIN_LEVEL_A,		"<nick, #userid, authid or @team> [0|1]"},
	{"amx_doublejump",	3,	ACTION_MULTIJUMP, 	ADMIN_LEVEL_A,		"<nick, #userid, authid or @team> [0|1]"},
	{"amx_freeze",		3,	ACTION_FREEZE, 		ADMIN_LEVEL_A,		"<nick, #userid, authid or @team> [0|1]"},
	{"amx_slay2",		2,	ACTION_SLAY2, 		ADMIN_LEVEL_A,		"<nick, #userid, authid or @team> [2-Blood|3-Explode]"},
	{"amx_bury",		2,	ACTION_BURY, 		ADMIN_LEVEL_B,		"<nick, #userid, authid or @team>"},
	{"amx_unbury",		2,	ACTION_UNBURY, 		ADMIN_LEVEL_A,		"<nick, #userid, authid or @team>"},
	{"amx_disarm",		2,	ACTION_DISARM, 		ADMIN_LEVEL_A,		"<nick, #userid, authid or @team>"},
	{"amx_rocket",		2,	ACTION_ROCKET, 		ADMIN_LEVEL_A,		"<nick, #userid, authid or @team>"},
	{"amx_revive",		2,	ACTION_REVIVE, 		ADMIN_LEVEL_A,		"<nick, #userid, authid or @team>"},
	{"amx_quit",		2,	ACTION_QUIT, 		ADMIN_LEVEL_A,		"<nick, #userid, authid or @team>"},
	{"amx_flash",		2,	ACTION_FLASH, 		ADMIN_LEVEL_A,		"<nick, #userid, authid or @team>"},
	{"amx_drug",		2,	ACTION_DRUG, 		ADMIN_LEVEL_A,		"<nick, #userid, authid or @team>"},
	{"amx_glow",		3,	ACTION_GLOW, 		ADMIN_LEVEL_A,		"<nick, #userid, authid or @team> <color> (or) <rrr> <ggg> <bbb> <aaa>"},
	{"amx_teleport",	2,	ACTION_TELEPORT, 	ADMIN_LEVEL_A,		"<nick, #userid or authid> [x] [y] [z]"},
	{"amx_givemoney",	3,	ACTION_GIVEMONEY, 	ADMIN_LEVEL_C,		"<nick, #userid or authid> <amount>"},
	{"amx_takemoney",	3,	ACTION_TAKEMONEY, 	ADMIN_LEVEL_C,		"<nick, #userid or authid> <amount>"},
	{"amx_uberslap",	2,	ACTION_UBERSLAP, 	ADMIN_LEVEL_A,		"<nick, #userid or authid>"},
	{"amx_userorigin",	2,	ACTION_USERORIGIN, 	ADMIN_LEVEL_A,		"<nick, #userid or authid>"},
	{"amx_hrespawn",	2,	ACTION_HRESPAWN, 	ADMIN_LEVEL_A,		"<nick, #userid or authid>"},
	{"amx_team",		3,	ACTION_TEAM,	 	ADMIN_LEVEL_A,		"<name> <CT/T/Spec>"},
	{"amx_transfer",	3,	ACTION_TEAM,	 	ADMIN_LEVEL_A,		"<name> <CT/T/Spec>"},
	{"amx_swap",		3,	ACTION_SWAP, 		ADMIN_LEVEL_A,		"<name 1> <name 2>"},
	{"amx_pass",		2,	ACTION_PASS, 		ADMIN_LEVEL_A,		"<server password> - Sets the server password"},
	{"amx_nopass",		1,	ACTION_NOPASS, 		ADMIN_LEVEL_A,		"Removes the server password"},
	{"amx_extend",		2,	ACTION_EXTEND, 		ADMIN_LEVEL_A,		"<added time to extend>"},
	{"amx_glowcolors",	1,	ACTION_GLOWCOLORS, 	ADMIN_LEVEL_A,		"shows a list of colors for amx_glow and amx_glow2"},
	{"amx_teamswap",	1,	ACTION_TEAMSWAP, 	ADMIN_LEVEL_A,		"Swaps 2 teams with each other"},
	{"amx_alltalk",		2,	ACTION_ALLTALK, 	ADMIN_LEVEL_A,		"<alltalk #>"},
	{"amx_gravity",		2,	ACTION_GRAVITY, 	ADMIN_LEVEL_A,		"<gravity #>"}
};

enum _:eVariables {
	ScreenFade,
	SetFOV,
	Damage,
	DeathMsg,
	ScoreInfo,
	Hudsync,
	sv_gravity,
	sv_password,
	mp_timelimit,
	sv_alltalk,
	steam1,
	blueflare2,
	white,
	lgtning,
	muzzleflash,
	zbeam5,
	additional_jumps,
	dj_trail_life,
	dj_trail_size,
	dj_trail_brightness,
	extendmax,
	extendtime,
	Float:auto_double_jump_velocity,
	Float:flTrailTime[MAX_CLIENTS + 1],
	PlayerJump[MAX_CLIENTS + 1],
	PlayerCatch[MAX_CLIENTS + 1],
	PlayerIceCube[MAX_CLIENTS + 1],
	Speed[MAX_CLIENTS + 1],
	modelindex
}
new g_iVariables[eVariables];

enum _:eBoolVariables {
	flashsound,
	bulletdamage,
	reviveafterteamswap,
	revdefaultweapon,
	allowcatchfire,
	auto_double_jump,
	dj_trail,
	dj_trail_effect,
	Unammo[MAX_CLIENTS + 1],
	Fire[MAX_CLIENTS + 1],
	DoubleJump[MAX_CLIENTS + 1],
	Trail[MAX_CLIENTS + 1]
}
new bool:g_blVariables[eBoolVariables];

enum _:eSounds {
	thunder_clap,
	rocketfire1,
	headshot2,
	rocket1,
	flashbang2,
	flameburst,
	scream07
};

new const g_szSounds[eSounds][] = {
	"ambience/thunder_clap.wav",
	"weapons/rocketfire1.wav",
	"weapons/headshot2.wav",
	"weapons/rocket1.wav",
	"weapons/flashbang-2.wav",
	"ambience/flameburst1.wav",
	"scientist/scream07.wav"
};

const MAX_COLORS = 30;

new const Float:g_flColors[MAX_COLORS][] = {
	{255.0,0.0,0.0},{255.0,190.0,190.0},{165.0,0.0,0.0},{255.0,100.0,100.0},{0.0,0.0,255.0},{0.0,0.0,136.0},{95.0,200.0,255.0},{0.0,150.0,255.0},
	{0.0,255.0,0.0},{180.0,255.0,175.0},{0.0,155.0,0.0},{150.0,63.0,0.0},{205.0,123.0,64.0},{255.0,255.0,255.0},{255.0,255.0,0.0},{189.0,182.0,0.0},
	{255.0,255.0,109.0},{255.0,150.0,0.0},{255.0,190.0,90.0},{222.0,110.0,0.0},{243.0,138.0,255.0},{255.0,0.0,255.0},{150.0,0.0,150.0},{100.0,0.0,100.0},
	{200.0,0.0,0.0},{220.0,220.0,0.0},{192.0,192.0,192.0},{190.0,100.0,10.0},{114.0,114.0,114.0},{0.0,0.0,0.0}
};

new const g_szColors[MAX_COLORS][] = {
	"red","pink","darkred","lightred","blue","darkblue","lightblue","aqua",
	"green","lightgreen","darkgreen","brown","lightbrown","white","yellow","darkyellow",
	"lightyellow","orange","lightorange","darkorange","lightpurple","purple","darkpurple","violet",
	"maroon","gold","silver","bronze","grey","off"
};

enum _:eTaskId {
	TASKID_FIRE1,
	TASKID_FIRE2,
	TASKID_TRAIL
};

new const g_szIceModel[] = "models/ras_freezemodel.mdl";

new Float:flHRespawn_Origin[MAX_CLIENTS + 1][3],
	Float:g_flSavedOrigin[MAX_CLIENTS + 1][3];

public plugin_init() {
	register_plugin("ReAmx_Super", "1.8", "PurposeLess");
	register_dictionary("reamx_super.txt");

	register_clcmd("say /admin", "@clcmd_admin");
	register_clcmd("say /admins", "@clcmd_admin");

	for(new iAction = 0; iAction < sizeof(g_Actions); iAction++) {
		register_concmd(g_Actions[iAction][cmd], "@call_function", g_Actions[iAction][action], g_Actions[iAction][description], .FlagManager = 0);
	}

	register_event("CurWeapon", "@event_curweapon", "be", "1=1", "3=1");

	RegisterHookChain(RG_CBasePlayer_Spawn, "@CBasePlayer_Spawn_Post", .post=true);
	RegisterHookChain(RG_CBasePlayer_Killed, "@CBasePlayer_Killed_Post", .post=true);
	RegisterHookChain(RG_CBasePlayer_TakeDamage, "@CBasePlayer_TakeDamage_Post", .post=true);
	RegisterHookChain(RG_CBasePlayer_ResetMaxSpeed, "@CBasePlayer_ResetMaxSpeed_Pre", .post=false);
	RegisterHookChain(RG_CBasePlayer_Jump, "@CBasePlayer_Jump_Pre", .post=false);

	bind_pcvar_num(create_cvar("reamx_super_extendmax", "9"), g_blVariables[extendmax]);
	bind_pcvar_num(create_cvar("reamx_super_extendtime", "15"), g_blVariables[extendtime]);
	bind_pcvar_num(create_cvar("reamx_super_flashsound", "1", _, _, true, 0.0, true, 1.0), g_blVariables[flashsound]);
	bind_pcvar_num(create_cvar("reamx_super_bulletdamage", "1", _, _, true, 0.0, true, 1.0), g_blVariables[bulletdamage]);
	bind_pcvar_num(create_cvar("reamx_super_reviveafterteamswap", "1", _, _, true, 0.0, true, 1.0), g_blVariables[reviveafterteamswap]);
	bind_pcvar_num(create_cvar("reamx_super_revdefaultweapon", "1", _, _, true, 0.0, true, 1.0), g_blVariables[revdefaultweapon]);
	bind_pcvar_num(create_cvar("reamx_super_allowcatchfire", "1", _, _, true, 0.0, true, 1.0), g_blVariables[allowcatchfire]);
	bind_pcvar_num(create_cvar("reamx_super_additional_jumps", "1"), g_iVariables[additional_jumps]);
	bind_pcvar_num(create_cvar("reamx_super_auto_double_jump", "0", _, _, true, 0.0, true, 1.0), g_blVariables[auto_double_jump]);
	bind_pcvar_num(create_cvar("reamx_super_dj_trail", "0", _, _, true, 0.0, true, 1.0), g_blVariables[dj_trail]);
	bind_pcvar_num(create_cvar("reamx_super_dj_trail_effect", "1", _, _, true, 0.0, true, 1.0), g_blVariables[dj_trail_effect]);
	bind_pcvar_num(create_cvar("reamx_super_dj_trail_life", "2"), g_iVariables[dj_trail_life]);
	bind_pcvar_num(create_cvar("reamx_super_dj_trail_size", "2"), g_iVariables[dj_trail_size]);
	bind_pcvar_num(create_cvar("reamx_super_dj_trail_brightness", "150"), g_iVariables[dj_trail_brightness]);
	bind_pcvar_float(create_cvar("reamx_super_auto_double_jump_velocity", "350.0"), g_iVariables[auto_double_jump_velocity]);

	set_pcvar_num(get_cvar_pointer("sv_maxspeed"), 2000);

	g_iVariables[ScreenFade] = get_user_msgid("ScreenFade");
	g_iVariables[SetFOV] = get_user_msgid("SetFOV");
	g_iVariables[Damage] = get_user_msgid("Damage");
	g_iVariables[DeathMsg] = get_user_msgid("DeathMsg");
	g_iVariables[ScoreInfo] = get_user_msgid("ScoreInfo");
	g_iVariables[Hudsync] = CreateHudSyncObj();

	g_iVariables[sv_gravity] = get_cvar_pointer("sv_gravity");
	g_iVariables[sv_password] = get_cvar_pointer("sv_password");
	g_iVariables[mp_timelimit] = get_cvar_pointer("mp_timelimit");
	g_iVariables[sv_alltalk] = get_cvar_pointer("sv_alltalk");
}

public plugin_precache()
{
	g_iVariables[steam1] = precache_model("sprites/steam1.spr");
	g_iVariables[blueflare2] = precache_model("sprites/blueflare2.spr");
	g_iVariables[white] = precache_model("sprites/white.spr");
	g_iVariables[lgtning] = precache_model("sprites/lgtning.spr");
	g_iVariables[muzzleflash] = precache_model("sprites/muzzleflash.spr");
	g_iVariables[zbeam5] = precache_model("sprites/zbeam5.spr");
	g_iVariables[modelindex] = precache_model(g_szIceModel);

	for(new i = 0; i < sizeof(g_szSounds); i++) {
		precache_sound(g_szSounds[i]);
	}
}

public client_disconnected(pPlayer) {
	g_iVariables[PlayerJump][pPlayer] = 0;
	g_blVariables[Fire][pPlayer] = false;
	g_blVariables[DoubleJump][pPlayer] = false;
	g_blVariables[PlayerCatch][pPlayer] = false;
	g_iVariables[Speed][pPlayer] = 0;

	remove_task(pPlayer);
	remove_task(pPlayer + TASKID_FIRE1);
	remove_task(pPlayer + TASKID_FIRE2);

	if(g_blVariables[dj_trail]) {
		remove_task(pPlayer + TASKID_TRAIL);
		g_blVariables[Trail][pPlayer] = false;
	}

	if(!is_nullent(g_iVariables[PlayerIceCube][pPlayer])) {
		set_entvar(g_iVariables[PlayerIceCube][pPlayer], var_flags, FL_KILLME);
	}
}

@call_function(const pPlayer, const eActions:iAction, const iCid) {
	if(~get_user_flags(pPlayer) & g_Actions[iAction][action_access]) {
		console_print(pPlayer, "%L", LANG_PLAYER, "NO_ACC_COM");
		return PLUGIN_HANDLED;
	}

	if(read_argc() < g_Actions[iAction][neededargs]) {
		console_print(pPlayer, "%L: %s %s", LANG_PLAYER, "USAGE", g_Actions[iAction][cmd], g_Actions[iAction][description]);
		return PLUGIN_HANDLED;
	}

	enum VariableDescription {
		VD_TEAM,
		VD_PLAYER,
		VD_ONLYALIVE,
		VD_IMMUNITY,
		VD_IGNORESTEAM,
		VD_MORENEGATIVE,
		VD_MOREZERO,
		VD_ONLYONOFF_ARG,
		VD_ONLYONOFF_ARG2
	};

	new bool:iVariables[VariableDescription];

	switch(iAction) {
		case ACTION_HEAL, ACTION_ARMOR, ACTION_WEAPON: {
			iVariables[VD_TEAM] = true;
			iVariables[VD_PLAYER] = true;
			iVariables[VD_ONLYALIVE] = true;
			iVariables[VD_MOREZERO] = true;
		}
		case ACTION_GODMODE, ACTION_NOCLIP, ACTION_UNAMMO, ACTION_INVISIBLE, ACTION_MULTIJUMP, ACTION_FREEZE: {
			iVariables[VD_TEAM] = true;
			iVariables[VD_PLAYER] = true;
			iVariables[VD_ONLYALIVE] = true;
			iVariables[VD_ONLYONOFF_ARG2] = true;
		}
		case ACTION_DRUG, ACTION_GLOW: {
			iVariables[VD_TEAM] = true;
			iVariables[VD_PLAYER] = true;
			iVariables[VD_ONLYALIVE] = true;
		}
		case ACTION_GIVEMONEY, ACTION_TAKEMONEY: {
			iVariables[VD_TEAM] = true;
			iVariables[VD_PLAYER] = true;
			iVariables[VD_MOREZERO] = true;
		}
		case ACTION_FIRE: {
			iVariables[VD_TEAM] = true;
			iVariables[VD_PLAYER] = true;
			iVariables[VD_ONLYALIVE] = true;
			iVariables[VD_IMMUNITY] = true;
			iVariables[VD_ONLYONOFF_ARG2] = true;
		}
		case ACTION_BURY, ACTION_UNBURY, ACTION_DISARM, ACTION_SLAY2, ACTION_ROCKET, ACTION_FLASH, ACTION_TELEPORT: {
			iVariables[VD_TEAM] = true;
			iVariables[VD_PLAYER] = true;
			iVariables[VD_ONLYALIVE] = true;
			iVariables[VD_IMMUNITY] = true;
		}
		case ACTION_REVIVE: {
			iVariables[VD_TEAM] = true;
			iVariables[VD_PLAYER] = true;
			iVariables[VD_IMMUNITY] = true;
		}
		case ACTION_USERORIGIN, ACTION_UBERSLAP: {
			iVariables[VD_PLAYER] = true;
			iVariables[VD_ONLYALIVE] = true;
			iVariables[VD_IMMUNITY] = true;
		}
		case ACTION_QUIT: {
			iVariables[VD_PLAYER] = true;
			iVariables[VD_ONLYALIVE] = true;
			iVariables[VD_IMMUNITY] = true;
			iVariables[VD_IGNORESTEAM] = true;
		}
		case ACTION_TEAM, ACTION_SWAP, ACTION_HRESPAWN: {
			iVariables[VD_PLAYER] = true;
		}
		case ACTION_SPEED: {
			iVariables[VD_TEAM] = true;
			iVariables[VD_PLAYER] = true;
			iVariables[VD_ONLYALIVE] = true;
			iVariables[VD_MORENEGATIVE] = true;
		}
		case ACTION_ALLTALK: {
			iVariables[VD_ONLYONOFF_ARG] = true;
		}
	}

	new szArg[32], szArg2[32], iArg, iArg2;
	read_argv(1, szArg, charsmax(szArg));
	read_argv(2, szArg2, charsmax(szArg2));
	iArg = str_to_num(szArg);
	iArg2 = str_to_num(szArg2);

	if(iVariables[VD_MORENEGATIVE] && iArg2 < 0) {
		console_print(pPlayer, "%L", LANG_PLAYER, "REAMX_SUPER_AMOUNT_GREATER");
		return PLUGIN_HANDLED;
	}

	if(iVariables[VD_MOREZERO] && iArg2 <= 0) {
		console_print(pPlayer, "%L", LANG_PLAYER, "REAMX_SUPER_AMOUNT_GREATER");
		return PLUGIN_HANDLED;
	}

	if(iVariables[VD_ONLYONOFF_ARG]) {
		iArg = clamp(iArg, 0, 1);
	}

	if(iVariables[VD_ONLYONOFF_ARG2]) {
		iArg2 = clamp(iArg2, 0, 1);
	}

	if(iVariables[VD_TEAM]) {
		if(szArg[0] == '@' && !szArg[4]) {
			new iPlayers[MAX_CLIENTS], szFlags[3], iNum;

			switch(szArg[1]) {
				case 'T','t': {
					szFlags = iVariables[VD_ONLYALIVE] ? "ae" : "e";
					copy(szArg[1], charsmax(szArg), "TERRORIST");
				}
				case 'C','c': {
					szFlags = iVariables[VD_ONLYALIVE] ? "ae" : "e";
				}
				case 'A','a': {
					szFlags = iVariables[VD_ONLYALIVE] ? "a" : "";
				}
			}

			get_players(iPlayers, iNum, szFlags, szArg[1]);

			if(!iNum) {
				console_print(pPlayer, "%L", LANG_PLAYER, "REAMX_SUPER_NO_PLAYERS");
				return PLUGIN_HANDLED;
			}

			for(new i = 0, pId; i < iNum; i++) {
				pId = iPlayers[i];

				if(iVariables[VD_IMMUNITY] && (get_user_flags(pId) & ADMIN_IMMUNITY && pPlayer != pId)) {
					continue;
				}

				@call_function_handler(iAction, pPlayer, pId, szArg, szArg2, iArg, iArg2, true, false);
				return PLUGIN_HANDLED;
			}
		}
	}

	if(iVariables[VD_PLAYER]) {
		new pId = cmd_target(pPlayer, szArg, bool:iVariables[VD_ONLYALIVE], bool:iVariables[VD_IMMUNITY]);

		if(!pId) {
			return PLUGIN_HANDLED;
		}

		if(iVariables[VD_IGNORESTEAM] && is_user_steam(pId)) {
			console_print(pPlayer, "%L", LANG_PLAYER, "REAMX_SUPER_NO_KICK_STEAM");
			return PLUGIN_HANDLED;
		}

		@call_function_handler(iAction, pPlayer, pId, szArg, szArg2, iArg, iArg2, false, true);
		return PLUGIN_HANDLED;
	}

	@call_function_handler(iAction, pPlayer, 0, szArg, szArg2, iArg, iArg2, false, false);
	return PLUGIN_HANDLED;
}

@call_function_handler(const eActions:iAction, const pPlayer, const pId, const szArg[], const szArg2[], const iArg, const iArg2, const bool:blTeam, const bool:blNoArg2) {
	switch(iAction) {
		case ACTION_HEAL: {
			set_entvar(pId, var_health, Float:get_entvar(pId, var_health) + float(iArg2));

			send_print_arg(pPlayer, pId, szArg, iArg2, blTeam, "REAMX_SUPER_HEAL_TEAM_P", "REAMX_SUPER_HEAL_TEAM_C", "REAMX_SUPER_HEAL_PLAYER_P", "REAMX_SUPER_HEAL_PLAYER_C");
		}
		case ACTION_ARMOR: {
			set_entvar(pId, var_armorvalue, Float:get_entvar(pId, var_armorvalue) + float(iArg2));

			send_print_arg(pPlayer, pId, szArg, iArg2, blTeam, "REAMX_SUPER_ARMOR_TEAM_P", "REAMX_SUPER_ARMOR_TEAM_C", "REAMX_SUPER_ARMOR_PLAYER_P", "REAMX_SUPER_ARMOR_PLAYER_C");
		}
		case ACTION_WEAPON: {
			rg_give_weapon(pId, iArg2);

			send_print_arg(pPlayer, pId, szArg, iArg2, blTeam, "REAMX_SUPER_WEAPON_TEAM_P", "REAMX_SUPER_WEAPON_TEAM_C", "REAMX_SUPER_WEAPON_PLAYER_P", "REAMX_SUPER_WEAPON_PLAYER_C");
		}
		case ACTION_GODMODE: {
			set_entvar(pId, var_takedamage, iArg2 ? DAMAGE_NO : DAMAGE_AIM);

			send_print_arg(pPlayer, pId, szArg, iArg2, blTeam, "REAMX_SUPER_GODMODE_TEAM_P", "REAMX_SUPER_GODMODE_TEAM_C", "REAMX_SUPER_GODMODE_PLAYER_P", "REAMX_SUPER_GODMODE_PLAYER_C");
		}
		case ACTION_NOCLIP: {
			set_entvar(pId, var_movetype, iArg2 ? MOVETYPE_NOCLIP : MOVETYPE_WALK);

			send_print_arg(pPlayer, pId, szArg, iArg2, blTeam, "REAMX_SUPER_NOCLIP_TEAM_P", "REAMX_SUPER_NOCLIP_TEAM_C", "REAMX_SUPER_NOCLIP_PLAYER_P", "REAMX_SUPER_NOCLIP_PLAYER_C");
		}
		case ACTION_SPEED: {
			g_iVariables[Speed][pPlayer] = iArg2;

			if(!iArg2) {
				rg_reset_maxspeed(pPlayer);
			}
			else {
				new Float:flSpeed = 250.0 + (50.0 * float(iArg2));
				set_entvar(pPlayer, var_maxspeed, flSpeed);
			}

			send_print_arg(pPlayer, pId, szArg, iArg2, blTeam, "REAMX_SUPER_SPEED_TEAM_P", "REAMX_SUPER_SPEED_TEAM_C", "REAMX_SUPER_SPEED_PLAYER_P", "REAMX_SUPER_SPEED_PLAYER_C");
		}
		case ACTION_GIVEMONEY: {
			rg_add_account(pId, iArg2, AS_ADD);

			send_print_arg(pPlayer, pId, szArg, iArg2, blTeam, "REAMX_SUPER_GIVEMONEY_TEAM_P", "REAMX_SUPER_GIVEMONEY_TEAM_C", "REAMX_SUPER_GIVEMONEY_PLAYER_P", "REAMX_SUPER_GIVEMONEY_PLAYER_C");
		}
		case ACTION_TAKEMONEY: {
			rg_add_account(pId, -iArg2, AS_ADD);

			send_print_arg(pPlayer, pId, szArg, iArg2, blTeam, "REAMX_SUPER_TAKEMONEY_TEAM_P", "REAMX_SUPER_TAKEMONEY_TEAM_C", "REAMX_SUPER_TAKEMONEY_PLAYER_P", "REAMX_SUPER_TAKEMONEY_PLAYER_C");
		}
		case ACTION_UNAMMO: {
			g_blVariables[Unammo][pId] = bool:iArg2;

			send_print_arg(pPlayer, pId, szArg, iArg2, blTeam, "REAMX_SUPER_UNAMMO_TEAM_P", "REAMX_SUPER_UNAMMO_TEAM_C", "REAMX_SUPER_UNAMMO_PLAYER_P", "REAMX_SUPER_UNAMMO_PLAYER_C");
		}
		case ACTION_ALLTALK: {
			set_pcvar_num(g_iVariables[sv_alltalk], iArg);

			send_print_onlypc(pPlayer, iArg, "REAMX_SUPER_ALLTALK_P", "REAMX_SUPER_ALLTALK_C");
		}
		case ACTION_GRAVITY: {
			set_pcvar_num(g_iVariables[sv_gravity], iArg);

			send_print_onlypc(pPlayer, iArg, "REAMX_SUPER_GRAVITY_P", "REAMX_SUPER_GRAVITY_C");
		}
		case ACTION_BURY: {
			rg_bury_player(pId);

			send_print_onlynames(pPlayer, pId, szArg, blTeam, "REAMX_SUPER_BURY_TEAM_P", "REAMX_SUPER_BURY_TEAM_C", "REAMX_SUPER_BURY_PLAYER_P", "REAMX_SUPER_BURY_PLAYER_C");
		}
		case ACTION_UNBURY: {
			rg_unbury_player(pId);

			send_print_onlynames(pPlayer, pId, szArg, blTeam, "REAMX_SUPER_UNBURY_TEAM_P", "REAMX_SUPER_UNBURY_TEAM_C", "REAMX_SUPER_UNBURY_PLAYER_P", "REAMX_SUPER_UNBURY_PLAYER_C");
		}
		case ACTION_DISARM: {
			rg_remove_all_items(pId);
			rg_give_item(pId, "weapon_knife");

			send_print_onlynames(pPlayer, pId, szArg, blTeam, "REAMX_SUPER_DISARM_TEAM_P", "REAMX_SUPER_DISARM_TEAM_C", "REAMX_SUPER_DISARM_PLAYER_P", "REAMX_SUPER_DISARM_PLAYER_C");
		}
		case ACTION_SLAY2: {
			slay_player(pId, iArg2);

			send_print_onlynames(pPlayer, pId, szArg, blTeam, "REAMX_SUPER_SLAY2_TEAM_P", "REAMX_SUPER_SLAY2_TEAM_C", "REAMX_SUPER_SLAY2_PLAYER_P", "REAMX_SUPER_SLAY2_PLAYER_C");
		}
		case ACTION_ROCKET: {
			rg_rocket_player(pId);

			send_print_onlynames(pPlayer, pId, szArg, blTeam, "REAMX_SUPER_ROCKET_TEAM_P", "REAMX_SUPER_ROCKET_TEAM_C", "REAMX_SUPER_ROCKET_PLAYER_P", "REAMX_SUPER_ROCKET_PLAYER_C");
		}
		case ACTION_UBERSLAP: {
			set_task(0.1, "@uberslap_player", pId, .flags = "a", .repeat = 99);

			send_print_onlynames(pPlayer, pId, szArg, blTeam, "REAMX_SUPER_UBERSLAP_TEAM_P", "REAMX_SUPER_UBERSLAP_TEAM_C", "REAMX_SUPER_UBERSLAP_PLAYER_P", "REAMX_SUPER_UBERSLAP_PLAYER_C");
		}
		case ACTION_REVIVE: {
			rg_give_default_items_func(pId);

			send_print_onlynames(pPlayer, pId, szArg, blTeam, "REAMX_SUPER_REVIVE_TEAM_P", "REAMX_SUPER_REVIVE_TEAM_C", "REAMX_SUPER_REVIVE_PLAYER_P", "REAMX_SUPER_REVIVE_PLAYER_C");
		}
		case ACTION_QUIT: {
			client_cmd(pId, "quit");
			rg_send_audio(0, g_szSounds[thunder_clap]);

			send_print_onlynames(pPlayer, pId, szArg, blTeam, "", "", "REAMX_SUPER_QUIT_PLAYER_P", "REAMX_SUPER_QUIT_PLAYER_C");
		}
		case ACTION_DRUG: {
			rg_drug_player(pId);

			send_print_onlynames(pPlayer, pId, szArg, blTeam, "REAMX_SUPER_DRUG_TEAM_P", "REAMX_SUPER_DRUG_TEAM_C", "REAMX_SUPER_DRUG_PLAYER_P", "REAMX_SUPER_DRUG_PLAYER_C");
		}
		case ACTION_FLASH: {
			flash_player(pId);

			send_print_onlynames(pPlayer, pId, szArg, blTeam, "REAMX_SUPER_FLASH_TEAM_P", "REAMX_SUPER_FLASH_TEAM_C", "REAMX_SUPER_FLASH_PLAYER_P", "REAMX_SUPER_FLASH_PLAYER_C");
		}
		case ACTION_FREEZE: {
			if(iArg2) {
				freeze_player(pId);

				send_print_onlynames(pPlayer, pId, szArg, blTeam, "REAMX_SUPER_FREEZE_TEAM_P", "REAMX_SUPER_FREEZE_TEAM_C", "REAMX_SUPER_FREEZE_PLAYER_P", "REAMX_SUPER_FREEZE_PLAYER_C");
			}
			else {
				unfreeze_player(pId);

				send_print_onlynames(pPlayer, pId, szArg, blTeam, "REAMX_SUPER_UNFREEZE_TEAM_P", "REAMX_SUPER_UNFREEZE_TEAM_C", "REAMX_SUPER_UNFREEZE_PLAYER_P", "REAMX_SUPER_UNFREEZE_PLAYER_C");
			}
		}
		case ACTION_USERORIGIN: {
			get_entvar(pPlayer, var_origin, g_flSavedOrigin[pPlayer]);

			console_print(pPlayer, "%L", LANG_PLAYER, "REAMX_SUPER_USERORIGIN", pId, g_flSavedOrigin[pPlayer][0], g_flSavedOrigin[pPlayer][1], g_flSavedOrigin[pPlayer][2]);
		}
		case ACTION_TELEPORT: {
			if(read_argc() > 2) {
				new szY[8], szZ[8];
				read_argv(3, szY, charsmax(szY));
				read_argv(4, szZ, charsmax(szZ));

				g_flSavedOrigin[pPlayer][0] = float(iArg2);
				g_flSavedOrigin[pPlayer][1] = str_to_float(szY);
				g_flSavedOrigin[pPlayer][2] = str_to_float(szZ);
			}

			set_entvar(pId, var_origin, g_flSavedOrigin[pPlayer]);

			send_print_onlynames(pPlayer, pId, szArg, blTeam, "REAMX_SUPER_TELEPORT_TEAM_P", "REAMX_SUPER_TELEPORT_TEAM_C", "REAMX_SUPER_TELEPORT_PLAYER_P", "REAMX_SUPER_TELEPORT_PLAYER_C");
		}
		case ACTION_PASS: {
			set_pcvar_string(g_iVariables[sv_password], szArg);

			send_print_onlypc(pPlayer, iArg2, "REAMX_SUPER_SET_PASSWORD_P", "REAMX_SUPER_SET_PASSWORD_C");
		}
		case ACTION_NOPASS: {
			set_pcvar_string(g_iVariables[sv_password], "");

			send_print_onlypc(pPlayer, iArg2, "REAMX_SUPER_REMOVE_PASSWORD_P", "REAMX_SUPER_REMOVE_PASSWORD_C");
		}
		case ACTION_TEAM: {
			admin_transfer(pPlayer, pId, szArg2);
		}
		case ACTION_SWAP: {
			admin_swap(pPlayer, pId, szArg2);
		}
		case ACTION_EXTEND: {
			admin_extend(pPlayer, iArg);
		}
		case ACTION_GLOWCOLORS: {
			admin_glowcolors(pPlayer);
		}
		case ACTION_GLOW: {
			if(is_str_num(szArg2)) {
				new szArg3[32], szArg4[32], szArg5[32], Float:flColor[3], Float:flAmount;
				read_argv(3, szArg3, charsmax(szArg3));
				read_argv(4, szArg4, charsmax(szArg4));
				read_argv(5, szArg5, charsmax(szArg5));
				flColor[0] = str_to_float(szArg2);
				flColor[1] = str_to_float(szArg3);
				flColor[2] = str_to_float(szArg4);
				flAmount = (szArg5[0] == EOS ? 255.0 : str_to_float(szArg5));

				admin_glow(pPlayer, pId, blTeam, szArg, szArg2, true, flColor, flAmount);
				console_print(pPlayer, "YES [%f][%f][%f]", flColor[0], flColor[1], flColor[2]);
			}
			else {
				admin_glow(pPlayer, pId, blTeam, szArg, szArg2, false, {0.0,0.0,0.0}, 0.0);
			}
		}
		case ACTION_INVISIBLE: {
			set_entvar(pPlayer, var_effects, iArg2 ? get_entvar(pPlayer, var_effects) | EF_NODRAW : get_entvar(pPlayer, var_effects) & ~EF_NODRAW);

			send_print_arg(pPlayer, pId, szArg, iArg2, blTeam, "REAMX_SUPER_INVISIBLE_TEAM_P", "REAMX_SUPER_INVISIBLE_TEAM_C", "REAMX_SUPER_INVISIBLE_PLAYER_P", "REAMX_SUPER_INVISIBLE_PLAYER_C");
		}
		case ACTION_FIRE: {
			admin_fire(pId, iArg2);

			send_print_fire(pPlayer, pId, szArg, iArg2, blTeam, "REAMX_SUPER_FIRE_TEAM_P", "REAMX_SUPER_FIRE_TEAM_C", "REAMX_SUPER_FIRE_PLAYER_P", "REAMX_SUPER_FIRE_PLAYER_C");
		}
		case ACTION_MULTIJUMP: {
			g_blVariables[DoubleJump][pId] = bool:iArg2;

			send_print_arg(pPlayer, pId, szArg, iArg2, blTeam, "REAMX_SUPER_DOUBLEJUMP_TEAM_P", "REAMX_SUPER_DOUBLEJUMP_TEAM_C", "REAMX_SUPER_DOUBLEJUMP_PLAYER_P", "REAMX_SUPER_DOUBLEJUMP_PLAYER_C");
		}
		case ACTION_TEAMSWAP: {
			rg_swap_all_players();
			rg_respawn_all_players();

			client_print_color(0, 0, "%L", LANG_PLAYER, "REAMX_SUPER_TEAMSWAP_P", pPlayer);
			console_print(pPlayer, "%L", LANG_PLAYER, "REAMX_SUPER_TEAMSWAP_C");
		}
		case ACTION_HRESPAWN: {
			if(is_user_alive(pId)) {
				console_print(pPlayer, "%L", LANG_PLAYER, "REAMX_SUPER_HRESPAWN_NO_ALIVE");
				return;
			}

			rg_give_default_items_func(pId);
			set_entvar(pId, var_origin, flHRespawn_Origin[pId]);

			send_print_onlynames(pPlayer, pId, szArg, blTeam, "", "", "REAMX_SUPER_HRESPAWN_PLAYER_P", "REAMX_SUPER_HRESPAWN_PLAYER_C");
		}
	}
}

rg_give_weapon(const pPlayer, const iWeapon) {
	switch(iWeapon) {
		case 1: {
			rg_give_item(pPlayer, "weapon_knife");
		}
		case 11: {
			rg_give_user_weapon(pPlayer, WEAPON_GLOCK18, "weapon_glock18");
		}
		case 12: {
			rg_give_user_weapon(pPlayer, WEAPON_USP, "weapon_usp");
		}
		case 13: {
			rg_give_user_weapon(pPlayer, WEAPON_P228, "weapon_p228");
		}
		case 14: {
			rg_give_user_weapon(pPlayer, WEAPON_DEAGLE, "weapon_deagle");
		}
		case 15: {
			rg_give_user_weapon(pPlayer, WEAPON_FIVESEVEN, "weapon_fiveseven");
		}
		case 16: {
			rg_give_user_weapon(pPlayer, WEAPON_ELITE, "weapon_elite");
		}
		case 17: {
			rg_give_user_weapon(pPlayer, WEAPON_GLOCK18, "weapon_glock18");
			rg_give_user_weapon(pPlayer, WEAPON_USP, "weapon_usp");
			rg_give_user_weapon(pPlayer, WEAPON_P228, "weapon_p228");
			rg_give_user_weapon(pPlayer, WEAPON_DEAGLE, "weapon_deagle");
			rg_give_user_weapon(pPlayer, WEAPON_FIVESEVEN, "weapon_fiveseven");
			rg_give_user_weapon(pPlayer, WEAPON_ELITE, "weapon_elite");
		}
		case 21: {
			rg_give_user_weapon(pPlayer, WEAPON_M3, "weapon_m3");
		}
		case 22: {
			rg_give_user_weapon(pPlayer, WEAPON_XM1014, "weapon_xm1014");
		}
		case 31: {
			rg_give_user_weapon(pPlayer, WEAPON_TMP, "weapon_tmp");
		}
		case 32: {
			rg_give_user_weapon(pPlayer, WEAPON_MAC10, "weapon_mac10");
		}
		case 33: {
			rg_give_user_weapon(pPlayer, WEAPON_MP5N, "weapon_mp5navy");
		}
		case 34: {
			rg_give_user_weapon(pPlayer, WEAPON_P90, "weapon_p90");
		}
		case 35: {
			rg_give_user_weapon(pPlayer, WEAPON_UMP45, "weapon_ump45");
		}
		case 40: {
			rg_give_user_weapon(pPlayer, WEAPON_FAMAS, "weapon_famas");
		}
		case 41: {
			rg_give_user_weapon(pPlayer, WEAPON_GALIL, "weapon_galil");
		}
		case 42: {
			rg_give_user_weapon(pPlayer, WEAPON_AK47, "weapon_ak47");
		}
		case 43: {
			rg_give_user_weapon(pPlayer, WEAPON_M4A1, "weapon_m4a1");
		}
		case 44: {
			rg_give_user_weapon(pPlayer, WEAPON_SG552, "weapon_sg552");
		}
		case 45: {
			rg_give_user_weapon(pPlayer, WEAPON_AUG, "weapon_aug");
		}
		case 46: {
			rg_give_user_weapon(pPlayer, WEAPON_SCOUT, "weapon_scout");
		}
		case 47: {
			rg_give_user_weapon(pPlayer, WEAPON_SG550, "weapon_sg550");
		}
		case 48: {
			rg_give_user_weapon(pPlayer, WEAPON_AWP, "weapon_awp");
		}
		case 49: {
			rg_give_user_weapon(pPlayer, WEAPON_G3SG1, "weapon_g3sg1");
		}
		case 51: {
			rg_give_user_weapon(pPlayer, WEAPON_M249, "weapon_m249");
		}
		case 60: {
			rg_give_shield(pPlayer);
			rg_give_item(pPlayer, "item_assaultsuit");
			rg_give_user_weapon(pPlayer, WEAPON_GLOCK, "weapon_glock");
			rg_give_user_weapon(pPlayer, WEAPON_FLASHBANG, "weapon_flashbang");
			rg_give_user_weapon(pPlayer, WEAPON_HEGRENADE, "weapon_hegrenade");
		}
		case 61: {
			rg_give_shield(pPlayer);
			rg_give_item(pPlayer, "item_assaultsuit");
			rg_give_user_weapon(pPlayer, WEAPON_GLOCK, "weapon_usp");
			rg_give_user_weapon(pPlayer, WEAPON_FLASHBANG, "weapon_flashbang");
			rg_give_user_weapon(pPlayer, WEAPON_HEGRENADE, "weapon_hegrenade");
		}
		case 62: {
			rg_give_shield(pPlayer);
			rg_give_item(pPlayer, "item_assaultsuit");
			rg_give_user_weapon(pPlayer, WEAPON_DEAGLE, "weapon_deagle");
			rg_give_user_weapon(pPlayer, WEAPON_FLASHBANG, "weapon_flashbang");
			rg_give_user_weapon(pPlayer, WEAPON_HEGRENADE, "weapon_hegrenade");
		}
		case 63: {
			rg_give_shield(pPlayer);
			rg_give_item(pPlayer, "item_assaultsuit");
			rg_give_user_weapon(pPlayer, WEAPON_FIVESEVEN, "weapon_fiveseven");
			rg_give_user_weapon(pPlayer, WEAPON_FLASHBANG, "weapon_flashbang");
			rg_give_user_weapon(pPlayer, WEAPON_HEGRENADE, "weapon_hegrenade");
		}
		case 81:{
			rg_give_item(pPlayer, "item_kevlar");
		}
		case 82:{
			rg_give_item(pPlayer, "item_assaultsuit");
		}
		case 83:{
			rg_give_user_weapon(pPlayer, WEAPON_HEGRENADE, "weapon_hegrenade");
		}
		case 84:{
			rg_give_user_weapon(pPlayer, WEAPON_FLASHBANG, "weapon_flashbang");
		}
		case 85:{
			rg_give_user_weapon(pPlayer, WEAPON_SMOKEGRENADE, "weapon_smokegrenade");
		}
		case 86:{
			rg_give_item(pPlayer, "item_thighpack");
		}
		case 87:{
			rg_give_shield(pPlayer);
		}
		case 88:{
			for(new InventorySlotType:i = PRIMARY_WEAPON_SLOT, iWeapon; i < C4_SLOT; i++) {
				iWeapon = get_member(pPlayer, m_rgpPlayerItems, i);

				if(is_nullent(iWeapon)) {
					continue;
				}

				rg_set_user_bpammo(pPlayer, get_member(iWeapon, m_iId), rg_get_iteminfo(iWeapon, ItemInfo_iMaxAmmo1));
			}
		}
		case 89:{
			rg_give_user_weapon(pPlayer, WEAPON_HEGRENADE, "weapon_hegrenade");
			rg_give_user_weapon(pPlayer, WEAPON_FLASHBANG, "weapon_flashbang");
			rg_give_user_weapon(pPlayer, WEAPON_SMOKEGRENADE, "weapon_smokegrenade");
		}
		case 91:{
			rg_give_item(pPlayer, "weapon_c4");
		}
		case 100:{
			rg_give_item(pPlayer, "item_assaultsuit");
			rg_give_user_weapon(pPlayer, WEAPON_AWP, "weapon_awp");
			rg_give_user_weapon(pPlayer, WEAPON_DEAGLE, "weapon_deagle");
			rg_give_user_weapon(pPlayer, WEAPON_HEGRENADE, "weapon_hegrenade");
			rg_give_user_weapon(pPlayer, WEAPON_FLASHBANG, "weapon_flashbang");
			rg_give_user_weapon(pPlayer, WEAPON_SMOKEGRENADE, "weapon_smokegrenade");
		}
	}
}

rg_give_user_weapon(const pPlayer, const WeaponIdType:iNum, const szWeaponName[]) {
	if(rg_has_item_by_name(pPlayer, szWeaponName)) {
		new iWeapon = rg_find_weapon_bpack_by_name(pPlayer, szWeaponName);
		rg_set_user_bpammo(pPlayer, iNum, rg_get_iteminfo(iWeapon, ItemInfo_iMaxAmmo1));
	}
	else {
		rg_set_user_bpammo(pPlayer, iNum, rg_get_iteminfo(rg_give_item(pPlayer, szWeaponName), ItemInfo_iMaxAmmo1));
	}
}

rg_bury_player(const pPlayer) {
	new Float:flOrigin[3];
	get_entvar(pPlayer, var_origin, flOrigin);
	flOrigin[2] -= 35.0;
	set_entvar(pPlayer, var_origin, flOrigin);
}

rg_unbury_player(const pPlayer) {
	new Float:flOrigin[3];
	get_entvar(pPlayer, var_origin, flOrigin);
	flOrigin[2] += 35.0;
	set_entvar(pPlayer, var_origin, flOrigin);
}

rg_rocket_player(const pPlayer) {
	rh_emit_sound2(pPlayer, 0, CHAN_WEAPON, g_szSounds[rocketfire1]);
	set_entvar(pPlayer, var_maxspeed, 0.01);
	set_task(1.2, "@rocket_liftoff", pPlayer);
}

slay_player(const pPlayer, const iType) {
	new Float:flOrigin[3], Float:flOrigin2[3];
	get_entvar(pPlayer, var_origin, flOrigin);
	flOrigin[2] -= 26.0;

	flOrigin2[0] = flOrigin[0] + 15.0;
	flOrigin2[1] = flOrigin[1] + 150.0;
	flOrigin2[2] = flOrigin[2] + 400.0;

	switch(iType) {
		case 1: {
			lightning(flOrigin2, flOrigin);
			rh_emit_sound2(pPlayer, 0, CHAN_ITEM, g_szSounds[thunder_clap]);
		}
		case 2:{
			blood(flOrigin);
			rh_emit_sound2(pPlayer, 0, CHAN_ITEM, g_szSounds[headshot2]);
		}
		case 3: {
			explode(flOrigin);
		}
	}

	user_kill(pPlayer, 1);
}

lightning(const Float:iVec[3], const Float:iVec2[3]) {
	message_begin_f(MSG_BROADCAST, SVC_TEMPENTITY); {
		write_byte(0);
		write_coord_f(iVec[0]);
		write_coord_f(iVec[1]);
		write_coord_f(iVec[2]);
		write_coord_f(iVec2[0]);
		write_coord_f(iVec2[1]);
		write_coord_f(iVec2[2]);
		write_short(g_iVariables[lgtning]);
		write_byte(1);
		write_byte(5);
		write_byte(2);
		write_byte(20);
		write_byte(30);
		write_byte(200);
		write_byte(200);
		write_byte(200);
		write_byte(200);
		write_byte(200);
	}
	message_end();

	message_begin_f(MSG_PVS, SVC_TEMPENTITY, iVec2); {
		write_byte(9);
		write_coord_f(iVec2[0]);
		write_coord_f(iVec2[1]);
		write_coord_f(iVec2[2]);
	}
	message_end();

	message_begin_f(MSG_BROADCAST, SVC_TEMPENTITY, iVec2); {
		write_byte(5);
		write_coord_f(iVec2[0]);
		write_coord_f(iVec2[1]);
		write_coord_f(iVec2[2]);
		write_short(g_iVariables[steam1]);
		write_byte(10);
		write_byte(10);
	}
	message_end();
}

blood(const Float:iVec[3]) {
	message_begin_f(MSG_BROADCAST,SVC_TEMPENTITY);
	write_byte(10);
	write_coord_f(iVec[0]);
	write_coord_f(iVec[1]);
	write_coord_f(iVec[2]);
	message_end();
}


explode(const Float:iVec[3]) {
	message_begin_f(MSG_BROADCAST, SVC_TEMPENTITY, iVec); {
		write_byte(21);
		write_coord_f(iVec[0]);
		write_coord_f(iVec[1]);
		write_coord_f(iVec[2] + 16);
		write_coord_f(iVec[0]);
		write_coord_f(iVec[1]);
		write_coord_f(iVec[2] + 1936);
		write_short(g_iVariables[white]);
		write_byte(0);
		write_byte(0);
		write_byte(2);
		write_byte(16);
		write_byte(0);
		write_byte(188);
		write_byte(220);
		write_byte(255);
		write_byte(255);
		write_byte(0);
	}
	message_end();

	message_begin_f(MSG_BROADCAST, SVC_TEMPENTITY); {
		write_byte(12);
		write_coord_f(iVec[0]);
		write_coord_f(iVec[1]);
		write_coord_f(iVec[2]);
		write_byte(188);
		write_byte(10);
	}
	message_end();

	message_begin_f(MSG_BROADCAST, SVC_TEMPENTITY, iVec); {
		write_byte(5);
		write_coord_f(iVec[0]);
		write_coord_f(iVec[1]);
		write_coord_f(iVec[2]);
		write_short(g_iVariables[steam1]);
		write_byte(2);
		write_byte(10);
	}
	message_end();
}

@rocket_liftoff(const pPlayer) {
	set_entvar(pPlayer, var_gravity, -0.50);
	client_cmd(pPlayer, "+jump;wait;wait;-jump");
	rh_emit_sound2(pPlayer, 0, CHAN_VOICE, g_szSounds[rocket1]);

	@rocket_effects(pPlayer);
}

@rocket_effects(const pPlayer) {
	if(!is_user_alive(pPlayer)) {
		remove_task(pPlayer);
		return;
	}

	static Float:flOrigin[3];
	get_entvar(pPlayer, var_origin, flOrigin);

	message_begin_f(MSG_ONE, g_iVariables[Damage], .player = pPlayer); {
		write_byte(30);
		write_byte(30);
		write_long(1<<16);
		write_coord_f(flOrigin[0]);
		write_coord_f(flOrigin[1]);
		write_coord_f(flOrigin[2]);
	}
	message_end();

	static Float:flPlayerOrigin[MAX_CLIENTS + 1];

	if(flPlayerOrigin[pPlayer] == flOrigin[2]) {
		rocket_explode(pPlayer);
	}

	flPlayerOrigin[pPlayer] = flOrigin[2];

	message_begin_f(MSG_BROADCAST, SVC_TEMPENTITY); {
		write_byte(15);
		write_coord_f(flOrigin[0]);
		write_coord_f(flOrigin[1]);
		write_coord_f(flOrigin[2]);
		write_coord_f(flOrigin[0]);
		write_coord_f(flOrigin[1]);
		write_coord_f(flOrigin[2] - 30);
		write_short(g_iVariables[blueflare2]);
		write_byte(5);
		write_byte(1);
		write_byte(1);
		write_byte(10);
		write_byte(5);
	}
	message_end();

	message_begin_f(MSG_BROADCAST,SVC_TEMPENTITY); {
		write_byte(17);
		write_coord_f(flOrigin[0]);
		write_coord_f(flOrigin[1]);
		write_coord_f(flOrigin[2] - 30);
		write_short(g_iVariables[muzzleflash]);
		write_byte(15);
		write_byte(255);
	}
	message_end();

	set_task(0.2, "@rocket_effects", pPlayer);
}

rocket_explode(const pPlayer) {
	static Float:flOrigin[3];
	get_entvar(pPlayer, var_origin, flOrigin);

	message_begin_f(MSG_BROADCAST, SVC_TEMPENTITY, flOrigin); {
		write_byte(21);
		write_coord_f(flOrigin[0]);
		write_coord_f(flOrigin[1]);
		write_coord_f(flOrigin[2] - 10);
		write_coord_f(flOrigin[0]);
		write_coord_f(flOrigin[1]);
		write_coord_f(flOrigin[2] + 1910);
		write_short(g_iVariables[white]);
		write_byte(0);
		write_byte(0);
		write_byte(2);
		write_byte(16);
		write_byte(0);
		write_byte(188);
		write_byte(220);
		write_byte(255);
		write_byte(255);
		write_byte(0);
	}
	message_end();

	message_begin_f(MSG_BROADCAST, SVC_TEMPENTITY); {
		write_byte(12);
		write_coord_f(flOrigin[0]);
		write_coord_f(flOrigin[1]);
		write_coord_f(flOrigin[2]);
		write_byte(188);
		write_byte(10);
	}
	message_end();

	message_begin_f(MSG_BROADCAST, SVC_TEMPENTITY, flOrigin); {
		write_byte(5);
		write_coord_f(flOrigin[0]);
		write_coord_f(flOrigin[1]);
		write_coord_f(flOrigin[2]);
		write_short(g_iVariables[steam1]);
		write_byte(2);
		write_byte(10);
	}
	message_end();

	user_kill(pPlayer, 1);

	rh_emit_sound2(pPlayer, 0, CHAN_VOICE, g_szSounds[rocket1], 0.0, 0.0, (1<<5));

	set_entvar(pPlayer, var_maxspeed, 1.0);
	set_entvar(pPlayer, var_gravity, 1.00);
}

@uberslap_player(const pPlayer) {
	user_slap(pPlayer, (get_entvar(pPlayer, var_health) > 1.0) ? 1 : 0);
}

rg_give_default_items_func(const pPlayer) {
	rg_round_respawn(pPlayer);

	if(g_blVariables[revdefaultweapon]) {
		rg_give_default_items(pPlayer);
	}
}

rg_drug_player(const pPlayer) {
	message_begin(MSG_ONE, g_iVariables[SetFOV], .player = pPlayer);
	write_byte(180);
	message_end();
}

flash_player(const pPlayer) {
	message_begin(MSG_ONE, g_iVariables[ScreenFade], .player = pPlayer); {
		write_short(1<<15);
		write_short(1<<10);
		write_short(1<<12);
		write_byte(255);
		write_byte(255);
		write_byte(255);
		write_byte(255);
	}
	message_end();

	if(g_blVariables[flashsound]) {
		rh_emit_sound2(pPlayer, 0, CHAN_BODY, g_szSounds[flashbang2], 1.0, ATTN_NORM, 0, PITCH_HIGH);
	}
}

freeze_player(const pPlayer) {
	new iFlags = get_entvar(pPlayer, var_flags);

	if(~iFlags & FL_FROZEN) {

		set_entvar(pPlayer, var_flags, iFlags | FL_FROZEN);

		new iEnt = g_iVariables[PlayerIceCube][pPlayer];

		if(is_nullent(iEnt)) {
			iEnt = g_iVariables[PlayerIceCube][pPlayer] = rg_create_entity("info_target");

			set_entvar(iEnt, var_body, 1);
			set_entvar(iEnt, var_owner, pPlayer);
			set_entvar(iEnt, var_solid, SOLID_BBOX);
			set_entvar(iEnt, var_modelindex, g_iVariables[modelindex]);
			rg_set_user_rendering(iEnt, kRenderFxNone, {255.0, 255.0, 255.0}, kRenderTransAdd, 60.0);
		}
		else {
			set_entvar(iEnt, var_effects, get_entvar(iEnt, var_effects) & ~EF_NODRAW);
		}

		new Float:flOrigin[3];
		get_entvar(pPlayer, var_origin, flOrigin);
		flOrigin[2] -= 25.0;
		set_entvar(iEnt, var_origin, flOrigin);
	}
}

unfreeze_player(const pPlayer) {
	new iFlags = get_entvar(pPlayer, var_flags);

	if(iFlags & FL_FROZEN) {
		set_entvar(pPlayer, var_flags, iFlags & ~FL_FROZEN);

		set_entvar(g_iVariables[PlayerIceCube][pPlayer], var_effects, EF_NODRAW);
	}
}

admin_transfer(const pPlayer, const pId, const szArg[]) {
	new szTeamName[32];

	switch(szArg[0])
	{
		case 'T','t': {
			rg_set_user_team(pId, TEAM_TERRORIST);
			szTeamName = "Terrorists";

			rg_give_default_items_func(pId);
		}
		case 'C','c': {
			rg_set_user_team(pId, TEAM_CT);
			szTeamName = "Counter-Terrorists";

			rg_give_default_items_func(pId);
		}
		case 'S','s': {
			user_silentkill(pId);
			rg_set_user_team(pId, TEAM_SPECTATOR);
			szTeamName = "Spectator";
		}
		default: {
			console_print(pPlayer, "[AMX_TEAM] %L", pPlayer, "REAMX_SUPER_TEAM_INVALID");
			return;
		}
	}

	client_print_color(0, 0, "%L", LANG_PLAYER, "REAMX_SUPER_TEAM_P", pPlayer, pId, szTeamName);
	console_print(pPlayer, "[AMX_TEAM] %L", pPlayer, "REAMX_SUPER_TEAM_C", pId, szTeamName);
}

admin_swap(const pPlayer, const pId, const arg[]) {
	new pId2 = cmd_target(pPlayer, arg, false, false);

	if(!pId2) {
		return;
	}

	new TeamName:iTeam1 = get_member(pId, m_iTeam);
	new TeamName:iTeam2 = get_member(pId2, m_iTeam);

	if(iTeam1 == iTeam2) {
		console_print(pPlayer, "[AMX_SWAP] %L", pPlayer, "REAMX_SUPER_SWAP_ERROR1");
		return;
	}

	if(iTeam1 == TEAM_UNASSIGNED || iTeam2 == TEAM_UNASSIGNED) {
		console_print(pPlayer, "[AMX_SWAP] %L", pPlayer, "REAMX_SUPER_SWAP_ERROR2");
		return;
	}

	if(iTeam1 == TEAM_SPECTATOR) {
		user_silentkill(pId2);
	}
	else if(iTeam2 == TEAM_SPECTATOR) {
		user_silentkill(pId);
	}

	rg_set_user_team(pId, iTeam2);
	rg_set_user_team(pId2, iTeam1);

	if(iTeam2 != TEAM_SPECTATOR) {
		rg_give_default_items_func(pId);
	}
	if(iTeam1 != TEAM_SPECTATOR) {
		rg_give_default_items_func(pId2);
	}

	client_print_color(0, 0, "%L", LANG_PLAYER, "REAMX_SUPER_SWAP_P", pPlayer, pId, pId2);
	console_print(pPlayer, "[AMX_SWAP] %L", pPlayer, "REAMX_SUPER_SWAP_C", pId, pId2);
}

admin_extend(const pPlayer, const iLimit)
{
	if(iLimit <= 0) {
		console_print(pPlayer, "[AMX_EXTEND] %L", pPlayer, "REAMX_SUPER_AMOUNT_GREATER");
		return;
	}

	static iExtended = 0;

	if(iExtended >= g_blVariables[extendmax]) {
		console_print(pPlayer, "[AMX_EXTEND] %L", pPlayer, "REAMX_SUPER_EXTEND_ERROR1", iExtended);
		return;
	}

	if(iLimit > g_blVariables[extendtime]) {
		console_print(pPlayer, "[AMX_EXTEND] %L", pPlayer, "REAMX_SUPER_EXTEND_ERROR2", g_blVariables[extendtime]);
		return;
	}

	set_pcvar_float(g_iVariables[mp_timelimit], get_pcvar_float(g_iVariables[mp_timelimit]) + iLimit);
	++iExtended;

	client_print_color(0, 0, "%L", LANG_PLAYER, "REAMX_SUPER_EXTEND_P", pPlayer, iLimit);
	console_print(pPlayer, "[AMX_EXTEND] %L", pPlayer, "REAMX_SUPER_EXTEND_C", iLimit);
}

admin_glowcolors(const pPlayer) {
	console_print(pPlayer, "Colors:");

	for(new i=0; i < MAX_COLORS; i++) {
		console_print(pPlayer, "%i %s", i + 1, g_szColors[i]);
	}

	console_print(pPlayer, "[AMX_GLOW] Example: amx_glow ^"PurposeLess^" ^"red^"");
}

admin_glow(const pPlayer, const pId, const bool:blTeam, const szArg[], const szArg2[], const bool:blCustom, {Float,_}:flColor[3], Float:flAmount) {
	new bool:blOff;

	if(!blCustom) {
		new bool:blValid = false;

		for(new i = 0; i < MAX_COLORS; i++) {
			if(equali(szArg2, g_szColors[i])) {
				if(equali(szArg2, "off")) {
					blOff = true;
				}

				flColor[0] = g_flColors[i][0];
				flColor[1] = g_flColors[i][1];
				flColor[2] = g_flColors[i][2];
				flAmount = 255.0;

				blValid = true;
				break;
			}
		}

		if(!blValid) {
			console_print(pPlayer, "[AMX_GLOW] %L", pPlayer, "REAMX_SUPER_GLOW_INVALID");
			return;
		}
	}
	else {
		flColor[0] = floatclamp(flColor[0], 0.0, 255.0);
		flColor[1] = floatclamp(flColor[1], 0.0, 255.0);
		flColor[2] = floatclamp(flColor[2], 0.0, 255.0);
		flAmount = floatclamp(flAmount, 0.0, 255.0);

		if(flColor[0] == 0.0 && flColor[1] == 0.0 && flColor[2] == 0.0 && flAmount == 255.0) {
			blOff = true;
		}
	}

	rg_set_user_rendering(pId, kRenderFxGlowShell, flColor, kRenderTransAlpha, flAmount);

	if(!blOff) {
		send_print_onlynames(pPlayer, pId, szArg, blTeam, "REAMX_SUPER_GLOW_TEAM_P", "REAMX_SUPER_GLOW_TEAM_C", "REAMX_SUPER_GLOW_PLAYER_P", "REAMX_SUPER_GLOW_PLAYER_C");
	}
	else {
		send_print_onlynames(pPlayer, pId, szArg, blTeam, "REAMX_SUPER_UNGLOW_TEAM_P", "REAMX_SUPER_UNGLOW_TEAM_C", "REAMX_SUPER_UNGLOW_PLAYER_P", "REAMX_SUPER_UNGLOW_PLAYER_C");
	}
}

rg_set_user_rendering(const pPlayer, const iFx, const {Float,_}:flColor[3], const iRender, const Float:flAmount)
{
	set_entvar(pPlayer, var_renderfx, iFx);
	set_entvar(pPlayer, var_rendercolor, flColor);
	set_entvar(pPlayer, var_rendermode, iRender);
	set_entvar(pPlayer, var_renderamt, flAmount);
}

@event_curweapon(const pPlayer) {
	if(!g_blVariables[Unammo][pPlayer]) {
		return;
	}

	new iWeapon = read_data(2);
	set_member(get_member(pPlayer, m_pActiveItem), m_Weapon_iClip, rg_get_weapon_info(iWeapon, WI_GUN_CLIP_SIZE) + 1);
}

@CBasePlayer_ResetMaxSpeed_Pre(const pPlayer) {
	if(g_iVariables[Speed][pPlayer] > 0) {
		new Float:flSpeed = 250.0 + (50.0 * g_iVariables[Speed][pPlayer]);
		set_entvar(pPlayer, var_maxspeed, flSpeed);
		return HC_SUPERCEDE;
	}
	return HC_CONTINUE;
}

@CBasePlayer_Spawn_Post(const pPlayer) {
	if(get_member(pPlayer, m_bJustConnected)) {
		return;
	}

	g_iVariables[PlayerJump][pPlayer] = 0;
	g_blVariables[Fire][pPlayer] = false;
	g_blVariables[DoubleJump][pPlayer] = false;
	g_blVariables[PlayerCatch][pPlayer] = false;
	g_iVariables[Speed][pPlayer] = 0;
	remove_task(pPlayer);
	remove_task(pPlayer + TASKID_FIRE1);
	remove_task(pPlayer + TASKID_FIRE2);

	get_entvar(pPlayer, var_origin, flHRespawn_Origin[pPlayer]);
	set_entvar(g_iVariables[PlayerIceCube][pPlayer], var_effects, EF_NODRAW);
}

@CBasePlayer_Killed_Post(const pVictim, pAttacker, iGib) {
	g_iVariables[PlayerJump][pVictim] = 0;
	g_blVariables[Fire][pVictim] = false;
	g_blVariables[DoubleJump][pVictim] = false;
	g_blVariables[PlayerCatch][pVictim] = false;
	g_iVariables[Speed][pVictim] = 0;
	remove_task(pVictim);
	remove_task(pVictim + TASKID_FIRE1);
	remove_task(pVictim + TASKID_FIRE2);
	unfreeze_player(pVictim);
	get_entvar(pVictim, var_origin, flHRespawn_Origin[pVictim]);
}

@CBasePlayer_TakeDamage_Post(const pVictim, pInflictor, pAttacker, Float:flDamage, bitsDamageType) {
	if(g_blVariables[bulletdamage]) {
		if(!is_user_connected(pAttacker) || pVictim == pAttacker || !rg_is_player_can_takedamage(pVictim, pAttacker)) {
			return;
		}

		set_hudmessage(0, 100, 200, -1.0, 0.55, 2, 0.1, 4.0, 0.02, 0.02, -1);
		ShowSyncHudMsg(pAttacker, g_iVariables[Hudsync], "%0.f^n", flDamage);
	}
}

send_print_arg(const pPlayer, const pId, const szArg[], const iNum, const bool:blTeam, const TEAM_P[], const TEAM_C[], const PLAYER_P[], const PLAYER_C[]) {
	if(blTeam) {
		client_print_color(0, 0, "%L", LANG_PLAYER, TEAM_P, pPlayer, iNum, get_teamname(szArg));
		console_print(pPlayer, "%L", LANG_PLAYER, TEAM_C, iNum, get_teamname(szArg));
	}
	else {
		client_print_color(0, 0, "%L", LANG_PLAYER, PLAYER_P, pPlayer, iNum, pId);
		console_print(pPlayer, "%L", LANG_PLAYER, PLAYER_C, iNum, pId);
	}
}

send_print_onlypc(const pPlayer, const iNum, const P[], const C[]) {
	client_print_color(0, 0, "%L", LANG_PLAYER, P, pPlayer, iNum);
	console_print(pPlayer, "%L", LANG_PLAYER, C, iNum);
}

send_print_onlynames(const pPlayer, const pId, const szArg[], const bool:blTeam, const TEAM_P[], const TEAM_C[], const PLAYER_P[], const PLAYER_C[]) {
	if(blTeam) {
		client_print_color(0, 0, "%L", LANG_PLAYER, TEAM_P, pPlayer, get_teamname(szArg));
		console_print(pPlayer, "%L", LANG_PLAYER, TEAM_C, get_teamname(szArg));
	}
	else {
		client_print_color(0, 0, "%L", LANG_PLAYER, PLAYER_P, pPlayer, pId);
		console_print(pPlayer, "%L", LANG_PLAYER, PLAYER_C, pId);
	}
}

send_print_fire(const pPlayer, const pId, const szArg[], const iArg2, const bool:blTeam, const TEAM_P[], const TEAM_C[], const PLAYER_P[], const PLAYER_C[]) {
	new szFire[20];
	formatex(szFire, charsmax(szFire), "%L", LANG_PLAYER, iArg2 ? "REAMX_SUPER_FIRE" : "REAMX_SUPER_UNFIRE");

	if(blTeam)
	{
		client_print_color(0, 0, "%L", LANG_PLAYER, TEAM_P, pPlayer, szFire, get_teamname(szArg));
		console_print(pPlayer, "%L", LANG_PLAYER, TEAM_C, szFire, get_teamname(szArg));
	}
	else
	{
		client_print_color(0, 0, "%L", LANG_PLAYER, PLAYER_P, pPlayer, szFire, pId);
		console_print(pPlayer, "%L", LANG_PLAYER, PLAYER_C, szFire, pId);
	}
}

get_teamname(const szArg[]) {
	new szTeamName[18];

	switch(szArg[1])
	{
		case 't','T': {
			szTeamName = "Terrorist";
		}
		case 'c','C': {
			szTeamName = "Counter-Terrorist";
		}
		default: {
			szTeamName = "all";
		}
	}
	return szTeamName;
}

cmd_target(const pPlayer, const szArg[], const bool:blOnlyAlive, const bool:blImmunity)
{
	new pId = find_player("bl", szArg);

	if(pId) {
		if(pId != find_player("blj", szArg)) {
			console_print(pPlayer, "%L", LANG_PLAYER, "MORE_CL_MATCHT");
			return 0;
		}
	}
	else if((pId = find_player("c", szArg)) == 0 && szArg[0] == '#' && szArg[1]) {
		pId = find_player("k", str_to_num(szArg[1]));
	}
	if(!pId) {
		console_print(pPlayer, "%L", LANG_PLAYER, "CL_NOT_FOUND");
		return 0;
	}
	if(blOnlyAlive && !is_user_alive(pPlayer)) {
		new szName[MAX_NAME_LENGTH];
		get_user_name(pId, szName, charsmax(szName));
		console_print(pPlayer, "%L", LANG_PLAYER, "CANT_PERF_DEAD", szName);
		return 0;
	}
	if(blImmunity && (get_user_flags(pId) & ADMIN_IMMUNITY && pPlayer != pId)) {
		new szName[MAX_NAME_LENGTH];
		get_user_name(pId, szName, charsmax(szName));
		console_print(pPlayer, "%L", LANG_PLAYER, "CLIENT_IMM", szName);
		return 0;
	}
	return pId;
}

@clcmd_admin(const pPlayer)
{
	new szAdminNames[MAX_CLIENTS + 1][MAX_NAME_LENGTH];
	new szMessage[MAX_DIRECTOR_CMD_STRING];
	new iCount, iLen;

	for(new id = 1; id <= MaxClients; id++) {
		if(is_user_connected(id) && get_user_flags(id) & ADMIN_KICK) {
			get_user_name(id, szAdminNames[iCount++], charsmax(szAdminNames[]));
		}
	}

	iLen = formatex(szMessage, charsmax(szMessage), "^4ADMINS ONLINE^1: ");

	if(iCount > 0) {
		for(new x = 0 ; x < iCount ; x++) {
			iLen += formatex(szMessage[iLen], charsmax(szMessage) - iLen, "^3%s%s ", szAdminNames[x], x < (iCount-1) ? "^4, " : "");

			if(iLen > 96) {
				client_print_color(pPlayer, pPlayer, szMessage);
				iLen = formatex(szMessage, charsmax(szMessage), "^4 ");
			}
		}
		client_print_color(pPlayer, pPlayer, szMessage);
	}
	else {
		iLen += formatex(szMessage[iLen], charsmax(szMessage)-iLen, "^3No admins online.");
		client_print_color(pPlayer, pPlayer, szMessage);
	}
	return PLUGIN_HANDLED;
}

admin_fire(const pPlayer, const iNum) {
	if(iNum) {
		g_iVariables[PlayerCatch][pPlayer] = 0;
		g_blVariables[Fire][pPlayer] = true;
		set_task(0.2, "@ignite_effects", pPlayer + TASKID_FIRE1, .flags = "b");
		set_task(1.0, "@ignite_player", pPlayer + TASKID_FIRE2, .flags = "b");
		rh_emit_sound2(pPlayer, 0, CHAN_WEAPON, g_szSounds[scream07], 1.0, ATTN_NORM, 0, PITCH_HIGH);
	}
	else {
		g_blVariables[Fire][pPlayer] = false;
		remove_task(pPlayer + TASKID_FIRE1);
		remove_task(pPlayer + TASKID_FIRE2);
	}
}

@ignite_effects(TaskId) {
	static pPlayer;
	pPlayer = TaskId - TASKID_FIRE1;

	static Float:flOrigin[3];
	get_entvar(pPlayer, var_origin, flOrigin);

	message_begin_f(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(17);
	write_coord_f(flOrigin[0]);
	write_coord_f(flOrigin[1]);
	write_coord_f(flOrigin[2]);
	write_short(g_iVariables[muzzleflash]);
	write_byte(20);
	write_byte(200);
	message_end();

	message_begin_f(MSG_BROADCAST,SVC_TEMPENTITY, flOrigin);
	write_byte(5);
	write_coord_f(flOrigin[0]);
	write_coord_f(flOrigin[1]);
	write_coord_f(flOrigin[2]);
	write_short(g_iVariables[steam1]);
	write_byte(20);
	write_byte(15);
	message_end();
}

@ignite_player(TaskId) {
	new pPlayer = TaskId - TASKID_FIRE2;

	new Float:flOrigin[3];
	get_entvar(pPlayer, var_origin, flOrigin);

	if(get_entvar(pPlayer, var_health) - 10.0 <= 0.0) {
		admin_fire(pPlayer, 0);
		rg_user_silentkill(pPlayer, g_iVariables[PlayerCatch][pPlayer]);
		return;
	}

	set_entvar(pPlayer, var_health, Float:get_entvar(pPlayer, var_health) - 10.0);

	message_begin_f(MSG_ONE, g_iVariables[Damage], .player = pPlayer);
	write_byte(30);
	write_byte(30);
	write_long(1<<21);
	write_coord_f(flOrigin[0]);
	write_coord_f(flOrigin[1]);
	write_coord_f(flOrigin[2]);
	message_end();

	rh_emit_sound2(pPlayer, 0, CHAN_ITEM, g_szSounds[flameburst], 0.6, ATTN_NORM, 0, PITCH_LOW);

	if(g_blVariables[allowcatchfire]) {
		for(new pId = 1, Float:flOrigin2[3]; pId <= MaxClients; pId++) {
			if(!is_user_alive(pId) || g_blVariables[Fire][pId] || pPlayer == pId) {
				continue;
			}

			get_entvar(pId, var_origin, flOrigin2);

			if(get_distance_f(flOrigin, flOrigin2) < 100.0) {
				rh_emit_sound2(pId, 0, CHAN_WEAPON, g_szSounds[scream07], 1.0, ATTN_NORM, 0, PITCH_HIGH);
				client_print_color(0, 0, "%L", LANG_PLAYER, "REAMX_SUPER_CATCH_FIRE", pPlayer, pId);

				admin_fire(pId, 1);
				g_iVariables[PlayerCatch][pId] = pPlayer;
			}
		}
	}
}

rg_user_silentkill(const pVictim, const pAttacker) {
	if(!is_user_connected(pAttacker)) {
		user_kill(pVictim);
		return;
	}

	user_silentkill(pVictim);

	message_begin(MSG_BROADCAST, g_iVariables[DeathMsg], .player = pVictim);
	write_byte(pAttacker);
	write_byte(pVictim);
	write_byte(0);
	message_end();

	new Float:flFrags = get_entvar(pAttacker, var_frags);
	set_entvar(pAttacker, var_frags, flFrags + 1.0);

	message_begin(MSG_BROADCAST, g_iVariables[ScoreInfo]);
	write_byte(pAttacker);
	write_short(floatround(flFrags));
	write_short(get_member(pAttacker, m_iDeaths));
	write_short(0);
	write_short(get_member(pAttacker, m_iTeam));
	message_end();
}

@CBasePlayer_Jump_Pre(const pPlayer) {
	if(!g_blVariables[DoubleJump][pPlayer]) {
		return HC_CONTINUE;
	}

	new iFlags = get_entvar(pPlayer, var_flags);

	if(g_blVariables[auto_double_jump]) {
		if((!(get_entvar(pPlayer, var_oldbuttons) & IN_JUMP)) && iFlags & FL_ONGROUND) {
			new Float:flVelocity[3];
			get_entvar(pPlayer, var_velocity, flVelocity);
			flVelocity[2] = g_iVariables[auto_double_jump_velocity];
			set_entvar(pPlayer, var_velocity, flVelocity);
		}
	}

	static Float:flJumpTime[MAX_CLIENTS + 1];

	if(g_iVariables[PlayerJump][pPlayer] && (iFlags & FL_ONGROUND)) {
		g_iVariables[PlayerJump][pPlayer] = 0;
		flJumpTime[pPlayer] = get_gametime();
		return HC_CONTINUE;
	}

	static Float:flGameTime;

	if((get_entvar(pPlayer, var_oldbuttons) & IN_JUMP || iFlags & FL_ONGROUND) || ((flGameTime = get_gametime()) - flJumpTime[pPlayer]) < 0.2) {
		return HC_CONTINUE;
	}

	if(g_iVariables[PlayerJump][pPlayer] >= g_iVariables[additional_jumps]) {
		return HC_CONTINUE;
	}

	flJumpTime[pPlayer] = flGameTime;

	new Float:flVelocity[3];
	get_entvar(pPlayer, var_velocity, flVelocity);
	flVelocity[2] = random_float(265.0, 285.0);
	set_entvar(pPlayer, var_velocity, flVelocity);

	g_iVariables[PlayerJump][pPlayer]++;

	if(g_blVariables[dj_trail]) {
		func_TrailMessage(pPlayer);
		g_iVariables[flTrailTime][pPlayer] = get_gametime();
	}

	return HC_CONTINUE;
}

func_TrailMessage(const pPlayer) {
	if(g_blVariables[Trail][pPlayer]) {
		return PLUGIN_CONTINUE;
	}

	static iColor[3];

	enum { RED = 0, GREEN, BLUE };

	if(!g_blVariables[dj_trail_effect]) {
		iColor[RED] = random_num(0, 255);
		iColor[GREEN] = random_num(0, 255);
		iColor[BLUE] = random_num(0, 255);
	}
	else
	{
		static TeamName:team;
		team = get_member(pPlayer, m_iTeam);

		switch(team) {
			case TEAM_TERRORIST: iColor = { 255, 0, 0 };
			case TEAM_CT: iColor = { 0, 0, 255 };
		}
	}

	g_blVariables[Trail][pPlayer] = true;

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_BEAMFOLLOW);
	write_short(pPlayer);
	write_short(g_iVariables[zbeam5]);
	write_byte(g_iVariables[dj_trail_life] * 10);
	write_byte(g_iVariables[dj_trail_size]);
	write_byte(iColor[RED]);
	write_byte(iColor[GREEN]);
	write_byte(iColor[BLUE]);
	write_byte(g_iVariables[dj_trail_brightness]);
	message_end();

	g_iVariables[flTrailTime][pPlayer] = get_gametime();
	set_task(1.0, "@task_RemoveTrail", pPlayer + TASKID_TRAIL, .flags = "a", .repeat = 1);

	return PLUGIN_CONTINUE;
}

@task_RemoveTrail(TaskId) {
	new pPlayer = TaskId - TASKID_TRAIL;

	if(!g_blVariables[DoubleJump][pPlayer]) {
		remove_task(pPlayer + TASKID_TRAIL);
		return;
	}

	new Float:flGameTime = get_gametime();

	if(flGameTime - g_iVariables[flTrailTime][pPlayer] < 1.35) {
		remove_task(pPlayer + TASKID_TRAIL);
		set_task(1.0, "@task_RemoveTrail", pPlayer + TASKID_TRAIL, .flags = "a", .repeat = 1);
	}
	else {
		g_blVariables[Trail][pPlayer] = false;

		message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
		write_byte(TE_KILLBEAM);
		write_short(pPlayer);
		message_end();
	}
}

rg_respawn_all_players() {
	if(g_blVariables[reviveafterteamswap]) {
		for(new pPlayer = 1; pPlayer <= MaxClients; pPlayer++) {
			if(is_user_connected(pPlayer) && (TEAM_UNASSIGNED < get_member(pPlayer, m_iTeam) < TEAM_SPECTATOR)) {
				rg_round_respawn(pPlayer);

				if(g_blVariables[revdefaultweapon]) {
					rg_remove_item(pPlayer, "weapon_glock18");
					rg_remove_item(pPlayer, "weapon_usp");
					rg_give_default_items(pPlayer);
				}
			}
		}
	}
}