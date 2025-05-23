#include <amxmodx>
#include <reapi>
#include <xs>
#include <fakemeta>
#include <cstrike>

new g_msgSyncHud;

#define SPECTATOR_CAN_SEE_DMG

#if AMXX_VERSION_NUM < 183
	new MaxClients;
#endif

public plugin_init() {
	register_plugin("Simple Damager", "1.0", "mforce");	// thanks to neugomon

	RegisterHookChain(RG_CBasePlayer_TakeDamage, "CBasePlayer_TakeDamage_Post", true);
	g_msgSyncHud  = CreateHudSyncObj();
#if AMXX_VERSION_NUM < 183
	MaxClients = get_maxplayers();
#endif
}

public CBasePlayer_TakeDamage_Post(const id, pevInflictor, attacker, Float:flDamage) {
	if(!(1 <= attacker <= MaxClients) || !(1 <= id <= MaxClients) || flDamage < 1.0 || !rg_is_player_can_takedamage(id, attacker))
		return;

	if(sm_is_ent_visible(id, attacker)) {
		set_hudmessage(.red = 0, .green = 100, .blue = 200, .x = -1.0, .y = 0.55, .holdtime = 2.0, .channel = -1);
		ShowSyncHudMsg(attacker, g_msgSyncHud, "%.0f^n", flDamage);
	}
	
	set_hudmessage(.red = 255, .green = 0, .blue = 0, .x = 0.45, .y = 0.50, .holdtime = 2.0, .channel = -1);
	ShowSyncHudMsg(id, g_msgSyncHud, "%.0f^n", flDamage);

#if defined SPECTATOR_CAN_SEE_DMG
	static i, players[32], pnum, specid, iuser2;
	get_players(players, pnum, "bch");
	for(i = 0; i < pnum; i++) {
		specid = players[i];
		iuser2 = get_entvar(specid, var_iuser2);
		if(iuser2 == attacker) {
			set_hudmessage(.red = 0, .green = 100, .blue = 200, .x = -1.0, .y = 0.55, .holdtime = 2.0, .channel = -1);
			ShowSyncHudMsg(specid, g_msgSyncHud, "%.0f^n", flDamage);
		}
		else if(iuser2 == id) {
			set_hudmessage(.red = 255, .green = 0, .blue = 0, .x = 0.45, .y = 0.50, .holdtime = 2.0, .channel = -1);
			ShowSyncHudMsg(specid, g_msgSyncHud, "%.0f^n", flDamage);
		}
	}
#endif
}

stock bool:sm_is_ent_visible(index, entity, ignoremonsters = 0) {
	new Float:start[3], Float:dest[3];
	pev(index, pev_origin, start);
	pev(index, pev_view_ofs, dest);
	xs_vec_add(start, dest, start);

	pev(entity, pev_origin, dest);
	engfunc(EngFunc_TraceLine, start, dest, ignoremonsters, index, 0);

	new Float:fraction;
	get_tr2(0, TR_flFraction, fraction);

	if (fraction >= 0.9 || get_tr2(0, TR_pHit) == entity)
		return true;

	return false;
}