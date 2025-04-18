#include <amxmodx>
#include <hamsandwich>
#include <fakemeta>
#include <reapi>

enum {
	GRENADE_HEGRENADE,
	GRENADE_FLASHBANG,
	GRENADE_SMOKEGRENADE,
	MAX_GRENADES,
}

new const GRENADES_WORLD_MODEL[MAX_GRENADES][] = {
	"models/w_hegrenade.mdl",
	"models/w_flashbang.mdl",
	"models/w_smokegrenade.mdl",
}

new g_iCvar_CanDropGrenade[MAX_GRENADES]
new Float:mp_item_staytime

public plugin_init() {
	register_plugin("Drop Grenades", "1.0.2", "fl0wer")

	RegisterHookChain(RG_CBasePlayer_DropPlayerItem, "@CBasePlayer_DropPlayerItem_Pre", false)
	RegisterHam(Ham_Touch, "weaponbox", "@CWeaponBox_Touch_Pre", false)

	new grenades[][] = {
		"weapon_hegrenade",
		"weapon_flashbang",
		"weapon_smokegrenade",
	}

	for (new i = 0; i < sizeof(grenades); i++) {
		RegisterHam(Ham_CS_Item_CanDrop, grenades[i], "@CGrenade_Item_CanDrop_Pre", false)
	}

	bind_pcvar_num(
		create_cvar(
			"amx_candrop_hegrenade", "1", _, "Player can drop HE grenade. (Default: 1)",
			true, 0.0, true, 1.0
		),
		g_iCvar_CanDropGrenade[GRENADE_HEGRENADE]
	)
	bind_pcvar_num(
		create_cvar(
			"amx_candrop_flasbang", "1", _, "Player can drop flashbang. (Default: 1)",
			true, 0.0, true, 1.0
		),
		g_iCvar_CanDropGrenade[GRENADE_FLASHBANG]
	)
	bind_pcvar_num(
		create_cvar(
			"amx_candrop_smokegrenade", "1", _, "Player can drop smoke grenade. (Default: 1)",
			true, 0.0, true, 1.0
		),
		g_iCvar_CanDropGrenade[GRENADE_SMOKEGRENADE]
	)
	bind_pcvar_float(get_cvar_pointer("mp_item_staytime"), mp_item_staytime)
}

public plugin_precache() {
	for (new i = 0; i < sizeof(GRENADES_WORLD_MODEL); i++) {
		precache_model(GRENADES_WORLD_MODEL[i])
	}
}

@CGrenade_Item_CanDrop_Pre(id) {
	new player = get_member(id, m_pPlayer)
	new primaryAmmoType = get_member(id, m_Weapon_iPrimaryAmmoType)
	if (get_member(player, m_rgAmmo, primaryAmmoType) <= 0) {
		return HAM_IGNORED
	}
	new WeaponIdType:weaponId = get_member(id, m_iId)
	if (!g_iCvar_CanDropGrenade[mapFromWeaponId(weaponId)]) {
		return HAM_IGNORED
	}
	SetHamReturnInteger(true)
	return HAM_OVERRIDE
}

@CBasePlayer_DropPlayerItem_Pre(id, itemName[]) {
	// check alive
	if (strlen(itemName)) {
		return HC_CONTINUE
	}
	new weapon = get_member(id, m_pActiveItem)
	if (is_nullent(weapon)) {
		return HC_CONTINUE
	}
	new WeaponIdType:weaponId = get_member(weapon, m_iId)
	new mappedWeapon = mapFromWeaponId(weaponId)
	if (mappedWeapon == -1) {
		return HC_CONTINUE
	}
	if (!g_iCvar_CanDropGrenade[mappedWeapon]) {
		return HC_CONTINUE
	}
	new primaryAmmoType = get_member(weapon, m_Weapon_iPrimaryAmmoType)
	new ammo = get_member(id, m_rgAmmo, primaryAmmoType)
	if (ammo <= 1) {
		return HC_CONTINUE
	}
	new Float:vecOrigin[3]
	new Float:vecAngles[3]
	new Float:vecVelocity[3]
	new Float:vecViewForward[3]
	get_entvar(id, var_origin, vecOrigin)
	get_entvar(id, var_angles, vecAngles)
	angle_vector(vecAngles, ANGLEVECTOR_FORWARD, vecViewForward)
	for (new i = 0; i < 3; i++) {
		vecOrigin[i] += vecViewForward[i] * 10.0
		vecVelocity[i] = vecViewForward[i] * 400.0
	}
	new weaponBox = CreateWeaponBox(
		id,
		GRENADES_WORLD_MODEL[mappedWeapon],
		vecOrigin,
		vecAngles,
		vecVelocity,
		mp_item_staytime
	)
	if (weaponBox) {
		set_entvar(weaponBox, var_iuser1, weaponId)
		set_member(id, m_rgAmmo, ammo - 1, primaryAmmoType)
	}
	SetHookChainReturn(ATYPE_INTEGER, NULLENT)
	return HC_SUPERCEDE
}

CreateWeaponBox(player, const modelName[], Float:vecOrigin[3], Float:vecAngles[3], Float:vecVelocity[3], Float:lifeTime) {
	new id = rg_create_entity("weaponbox", true)
	if (id) {
		vecAngles[0] = 0.0
		vecAngles[2] = 0.0
		set_entvar(id, var_movetype, MOVETYPE_TOSS)
		set_entvar(id, var_solid, SOLID_TRIGGER)
		set_entvar(id, var_owner, player)
		set_entvar(id, var_origin, vecOrigin)
		set_entvar(id, var_angles, vecAngles)
		set_entvar(id, var_velocity, vecVelocity)
		set_entvar(id, var_nextthink, get_gametime() + lifeTime)
		SetThink(id, "@CWeaponBox_Kill")
		engfunc(EngFunc_SetSize, NULL_VECTOR, NULL_VECTOR)
		engfunc(EngFunc_SetModel, id, modelName)
		set_member(id, m_WeaponBox_bIsBomb, false)
	}
	return id
}

@CWeaponBox_Kill(id) {
	set_entvar(id, var_flags, FL_KILLME)
}

@CWeaponBox_Touch_Pre(id, other) {
	if (!(get_entvar(id, var_flags) & FL_ONGROUND)) {
		return HAM_IGNORED
	}
	if (!is_user_alive(other)) {
		return HAM_IGNORED
	}
	if (get_member(other, m_bIsVIP) || get_member(other, m_bShieldDrawn)) {
		return HAM_IGNORED
	}
	new WeaponIdType:weaponId = get_entvar(id, var_iuser1)
	if (weaponId == WEAPON_NONE) {
		return HAM_IGNORED
	}
	new ammoType = rg_get_weapon_info(weaponId, WI_AMMO_TYPE)
	new maxRounds = rg_get_weapon_info(weaponId, WI_MAX_ROUNDS)
	if (get_member(other, m_rgAmmo, ammoType) < maxRounds) {
		new name[32]
		rg_get_weapon_info(weaponId, WI_NAME, name, charsmax(name))
		rg_give_item(other, name)

		SetTouch(id, "")
		set_entvar(id, var_flags, FL_KILLME)
	}
	return HAM_SUPERCEDE
}

mapFromWeaponId(WeaponIdType:weaponId) {
	switch (weaponId) {
		case WEAPON_HEGRENADE: {
			return GRENADE_HEGRENADE
		}
		case WEAPON_FLASHBANG: {
			return GRENADE_FLASHBANG
		}
		case WEAPON_SMOKEGRENADE: {
			return GRENADE_SMOKEGRENADE
		}
	}
	return -1
}
