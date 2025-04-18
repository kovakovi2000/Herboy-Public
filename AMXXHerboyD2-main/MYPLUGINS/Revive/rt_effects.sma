#include <amxmodx>
#include <fakemeta>
#include <reapi>
#include <rt_api>
#include <hamsandwich>
#include <mod>

public stock const PLUGIN[] = "Revive Teammates: Effects";
public stock const CFG_FILE[] = "addons/amxmodx/configs/rt_configs/rt_effects.cfg";

new const CORPSE_SPRITE_CLASSNAME[] = "rt_corpse_sprite";

#define bGet(%2,%1) (%1 & (1<<(%2&31)))
#define bSet(%2,%1) (%1 |= (1<<(%2&31)))
#define bRem(%2,%1) (%1 &= ~(1 <<(%2&31)))

new g_iUserSpriteDisabled;

enum CVARS {
	SPECTATOR,
	NOTIFY_DHUD,
	REVIVE_COLORS[MAX_COLORS_LENGTH],
	REVIVE_COORDS[MAX_COORDS_LENGTH],
	PLANTING_COLORS[MAX_COLORS_LENGTH],
	PLANTING_COORDS[MAX_COORDS_LENGTH],
	CORPSE_SPRITE[MAX_RESOURCE_PATH_LENGTH],
	Float:SPRITE_SCALE,
	REVIVE_GLOW[32],
	PLANTING_GLOW[32]
};

new g_eCvars[CVARS];

enum DHudData {
	COLOR_R,
	COLOR_G,
	COLOR_B,
	Float:COORD_X,
	Float:COORD_Y
};

enum GlowColors
{
	Float:REVIVE_COLOR,
	Float:PLANTING_COLOR
};
new Float:g_eGlowColors[GlowColors][3];

new g_eDHudData[Modes][DHudData];

new Float:g_fTime;

public plugin_precache() {
	CreateCvars();

	server_cmd("exec %s", CFG_FILE);
	server_exec();

	if(g_eCvars[CORPSE_SPRITE][0] != EOS)
		precache_model(g_eCvars[CORPSE_SPRITE]);

	new szHudColors[3][4];

	if(parse(g_eCvars[REVIVE_COLORS], szHudColors[0], charsmax(szHudColors[]),
	szHudColors[1], charsmax(szHudColors[]), szHudColors[2], charsmax(szHudColors[])) == 3) {
		g_eDHudData[MODE_REVIVE][COLOR_R] = str_to_num(szHudColors[0]);
		g_eDHudData[MODE_REVIVE][COLOR_G] = str_to_num(szHudColors[1]);
		g_eDHudData[MODE_REVIVE][COLOR_B] = str_to_num(szHudColors[2]);
	}

	if(parse(g_eCvars[PLANTING_COLORS], szHudColors[0], charsmax(szHudColors[]),
	szHudColors[1], charsmax(szHudColors[]), szHudColors[2], charsmax(szHudColors[])) == 3) {
		g_eDHudData[MODE_PLANT][COLOR_R] = str_to_num(szHudColors[0]);
		g_eDHudData[MODE_PLANT][COLOR_G] = str_to_num(szHudColors[1]);
		g_eDHudData[MODE_PLANT][COLOR_B] = str_to_num(szHudColors[2]);
	}

	new szHudCoords[2][8];

	if(parse(g_eCvars[REVIVE_COORDS], szHudCoords[0], charsmax(szHudCoords[]), szHudCoords[1], charsmax(szHudCoords[])) == 2) {
		g_eDHudData[MODE_REVIVE][COORD_X] = str_to_float(szHudCoords[0]);
		g_eDHudData[MODE_REVIVE][COORD_Y] = str_to_float(szHudCoords[1]);
	}

	if(parse(g_eCvars[PLANTING_COORDS], szHudCoords[0], charsmax(szHudCoords[]), szHudCoords[1], charsmax(szHudCoords[])) == 2) {
		g_eDHudData[MODE_PLANT][COORD_X] = str_to_float(szHudCoords[0]);
		g_eDHudData[MODE_PLANT][COORD_Y] = str_to_float(szHudCoords[1]);
	}
}

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHORS);

	register_dictionary("rt_library.txt");

	RegisterHam(Ham_Spawn, "player" ,"SetPlayerReviveSpriteStatus", 1);

	if(g_eCvars[CORPSE_SPRITE][0] != EOS)
		register_forward(FM_AddToFullPack, "AddToFullPack_Pre", false);
}
public SetPlayerReviveSpriteStatus(id){
    if(sm_get_revivesprite(id))
      bSet(id, g_iUserSpriteDisabled)
    else bRem(id, g_iUserSpriteDisabled)
}
public plugin_cfg() {
	g_fTime = get_pcvar_float(get_cvar_pointer("rt_revive_time"));

	if(g_eCvars[REVIVE_GLOW][0] != EOS)
		g_eGlowColors[REVIVE_COLOR] = parseHEXColor(g_eCvars[REVIVE_GLOW]);

	if(g_eCvars[PLANTING_GLOW][0] != EOS)
		g_eGlowColors[PLANTING_COLOR] = parseHEXColor(g_eCvars[PLANTING_GLOW]);
}

public AddToFullPack_Pre(es, e, ent, host, flags, player, pSet) {
	if(player || !FClassnameIs(ent, CORPSE_SPRITE_CLASSNAME))
		return FMRES_IGNORED;

	if(TeamName:get_entvar(ent, var_team) != TeamName:get_member(host, m_iTeam) || bGet(host, g_iUserSpriteDisabled)) {
		forward_return(FMV_CELL, false);
		return FMRES_SUPERCEDE;
	}

	return FMRES_IGNORED;
}

public rt_revive_start(const iEnt, const iPlayer, const iActivator, const Modes:eMode) {
	switch(eMode) {
		case MODE_REVIVE: {
			if(g_eCvars[SPECTATOR]) {
				rg_internal_cmd(iPlayer, "specmode", "4");
				set_entvar(iPlayer, var_iuser2, iActivator);
				set_member(iPlayer, m_hObserverTarget, iActivator);
				set_member(iPlayer, m_flNextObserverInput, get_gametime() + 1.25);
			}

			if(g_eCvars[NOTIFY_DHUD]) {
				DisplayDHudMessage(iActivator, eMode, "RT_DHUD_REVIVE", iPlayer);
				DisplayDHudMessage(iPlayer, eMode, "RT_DHUD_REVIVE2", iActivator);
			}

			if(g_eCvars[REVIVE_GLOW][0] != EOS)
				rg_set_rendering(iEnt, kRenderFxGlowShell, g_eGlowColors[REVIVE_COLOR], kRenderNormal, 30.0);
		}
		case MODE_PLANT: {
			if(g_eCvars[NOTIFY_DHUD])
				DisplayDHudMessage(iActivator, eMode, "RT_DHUD_PLANTING", iPlayer);

			if(g_eCvars[PLANTING_GLOW][0] != EOS)
				rg_set_rendering(iEnt, kRenderFxGlowShell, g_eGlowColors[PLANTING_COLOR], kRenderNormal, 30.0);
		}
	}
}

public rt_revive_cancelled(const iEnt, const iPlayer, const iActivator, const Modes:eMode) {
	if(g_eCvars[NOTIFY_DHUD]) {
		if(iActivator != RT_NULLENT)
			ClearDHudMessages(iActivator);

		if(iPlayer != RT_NULLENT)
			ClearDHudMessages(iPlayer);
	}

	switch(eMode)
	{
		case MODE_REVIVE:
		{
			if(g_eCvars[REVIVE_GLOW][0] != EOS)
				rg_set_rendering(iEnt);
		}
		case MODE_PLANT:
		{
			if(g_eCvars[PLANTING_GLOW][0] != EOS)
				rg_set_rendering(iEnt);
		}
	}
}

public rt_revive_end(const iEnt, const iPlayer, const iActivator, const Modes:eMode) {
	if(g_eCvars[NOTIFY_DHUD]) {
		ClearDHudMessages(iActivator);
		ClearDHudMessages(iPlayer);
	}

	switch(eMode)
	{
		case MODE_REVIVE:
		{
			static iMode;
			iMode = get_entvar(iEnt, var_iuser3);

			if(any:iMode != MODE_PLANT && g_eCvars[REVIVE_GLOW][0] != EOS)
				rg_set_rendering(iEnt);
		}
		case MODE_PLANT:
		{
			if(g_eCvars[PLANTING_GLOW][0] != EOS)
				rg_set_rendering(iEnt);
		}
	}
}

public rt_creating_corpse_end(const iEnt, const iPlayer, const Float:fVecOrigin[3]) {
	if(g_eCvars[CORPSE_SPRITE][0] == EOS)
		return;

	new iEntSprite = rg_create_entity("info_target");

	engfunc(EngFunc_SetOrigin, iEntSprite, fVecOrigin);
	engfunc(EngFunc_SetModel, iEntSprite, g_eCvars[CORPSE_SPRITE]);

	set_entvar(iEntSprite, var_classname, CORPSE_SPRITE_CLASSNAME);
	set_entvar(iEntSprite, var_owner, iPlayer);
	set_entvar(iEntSprite, var_iuser1, iEnt);
	set_entvar(iEntSprite, var_team, TeamName:get_entvar(iEnt, var_team));
	set_entvar(iEntSprite, var_scale, g_eCvars[SPRITE_SCALE]);
	set_entvar(iEntSprite, var_renderfx, kRenderFxNone);
	set_entvar(iEntSprite, var_rendercolor, Float:{255.0, 255.0, 255.0});
	set_entvar(iEntSprite, var_rendermode, kRenderTransAlpha);
	set_entvar(iEntSprite, var_renderamt, 255.0);
	set_entvar(iEntSprite, var_nextthink, get_gametime() + 0.1);

	SetThink(iEntSprite, "CorpseSprite_Think");
}

public CorpseSprite_Think(const iEnt) {
	new iHostEnt = get_entvar(iEnt, var_iuser1);

	if(is_nullent(iHostEnt) || !FClassnameIs(iHostEnt, DEAD_BODY_CLASSNAME)) {
		RemoveCorpses(get_entvar(iEnt, var_owner), CORPSE_SPRITE_CLASSNAME);
		return;
	}

	set_entvar(iEnt, var_nextthink, get_gametime() + 0.1);
}

stock rg_set_rendering(const id, const fx = kRenderFxNone, const Float:fColor[3] = {0.0, 0.0, 0.0}, const render = kRenderNormal, const Float:fAmount = 0.0)
{
	set_entvar(id, var_renderfx, fx);
	set_entvar(id, var_rendercolor, fColor);
	set_entvar(id, var_rendermode, render);
	set_entvar(id, var_renderamt, fAmount);
}

stock Float:parseHEXColor(const value[])
{
	new Float:result[3];

	if(value[0] != '#' && strlen(value) != 7)
		return result;

	result[0] = parse16bit(value[1], value[2]);
	result[1] = parse16bit(value[3], value[4]);
	result[2] = parse16bit(value[5], value[6]);

	return result;
}

stock Float:parse16bit(ch1, ch2)
{
	return float(parseHex(ch1) * 16 + parseHex(ch2));
}

stock parseHex(const ch)
{
	switch(ch)
	{
		case '0'..'9': return (ch - '0');
		case 'a'..'f': return (10 + ch - 'a');
		case 'A'..'F': return (10 + ch - 'A');
	}

	return 0;
}

stock DisplayDHudMessage(const iPlayer, const Modes:eMode, any:...) {
	new szMessage[128];
	SetGlobalTransTarget(iPlayer);
	vformat(szMessage, charsmax(szMessage), "%l", 3);

	set_dhudmessage(g_eDHudData[eMode][COLOR_R], g_eDHudData[eMode][COLOR_G], g_eDHudData[eMode][COLOR_B],
	g_eDHudData[eMode][COORD_X], g_eDHudData[eMode][COORD_Y], .holdtime = g_fTime);
	show_dhudmessage(iPlayer, szMessage);
}

stock ClearDHudMessages(const iPlayer, const iChannel = 8) {
	for(new i; i < iChannel; i++)
		show_dhudmessage(iPlayer, "");
}

public CreateCvars() {
	bind_pcvar_num(create_cvar(
		"rt_spectator",
		"1",
		FCVAR_NONE,
		"Automatically observe the resurrecting player",
		true,
		0.0,
		true,
		1.0),
		g_eCvars[SPECTATOR]
	);
	bind_pcvar_num(create_cvar(
		"rt_notify_dhud",
		"1",
		FCVAR_NONE,
		"Notification above the timer(DHUD)",
		true,
		0.0,
		true,
		1.0),
		g_eCvars[NOTIFY_DHUD]
	);
	bind_pcvar_string(create_cvar(
		"rt_revive_dhud_colors",
		"0 255 0",
		FCVAR_NONE,
		"DHUD's color at resurrection"),
		g_eCvars[REVIVE_COLORS],
		charsmax(g_eCvars[REVIVE_COLORS])
	);
	bind_pcvar_string(create_cvar(
		"rt_revive_dhud_coords",
		"-1.0 0.8",
		FCVAR_NONE,
		"DHUD's coordinates at resurrection"),
		g_eCvars[REVIVE_COORDS],
		charsmax(g_eCvars[REVIVE_COORDS])
	);
	bind_pcvar_string(create_cvar(
		"rt_planting_dhud_colors",
		"255 0 0",
		FCVAR_NONE,
		"DHUD's color at planting"),
		g_eCvars[PLANTING_COLORS],
		charsmax(g_eCvars[PLANTING_COLORS])
	);
	bind_pcvar_string(create_cvar(
		"rt_planting_dhud_coords",
		"-1.0 0.8",
		FCVAR_NONE,
		"DHUD's coordinates at planting"),
		g_eCvars[PLANTING_COORDS],
		charsmax(g_eCvars[PLANTING_COORDS])
	);
	bind_pcvar_string(create_cvar(
		"rt_corpse_sprite",
		"sprites/herboyd2/rev_arrow.spr",
		FCVAR_NONE,
		"Resurrection sprite over a corpse. To disable the function, leave the cvar empty"),
		g_eCvars[CORPSE_SPRITE],
		charsmax(g_eCvars[CORPSE_SPRITE])
	);
	bind_pcvar_float(create_cvar(
		"rt_sprite_scale",
		"0.15",
		FCVAR_NONE,
		"Sprite scale",
		true,
		0.1,
		true,
		0.5),
		g_eCvars[SPRITE_SCALE]
	);
	bind_pcvar_string(create_cvar(
		"rt_revive_glow",
		"#5da130",
		FCVAR_NONE,
		"The color of the corpse being resurrected(HEX)"),
		g_eCvars[REVIVE_GLOW],
		charsmax(g_eCvars[REVIVE_GLOW])
	);
	bind_pcvar_string(create_cvar(
		"rt_planting_glow",
		"#9b2d30",
		FCVAR_NONE,
		"The color of the corpse being planted(HEX)"),
		g_eCvars[PLANTING_GLOW],
		charsmax(g_eCvars[PLANTING_GLOW])
	);
}