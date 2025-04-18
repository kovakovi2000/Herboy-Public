#pragma semicolon 1

#include <amxmodx>
#include <hamsandwich>
#include <fakemeta>
#include <engine>
#include <reapi>
#include <xs>

#define HEAVY_LOAD

#define bGet(%2,%1) (%1 & (1<<(%2&31)))
#define bSet(%2,%1) (%1 |= (1<<(%2&31)))
#define bRem(%2,%1) (%1 &= ~(1 <<(%2&31)))

new const Float:WEAPONS_RECOIL[MAX_WEAPONS] =
{
	0.3, // WEAPON_NONE
	0.3, // WEAPON_P228
	0.3, // WEAPON_GLOCK
	0.3, // WEAPON_SCOUT
	0.3, // WEAPON_HEGRENADE
	0.3, // WEAPON_XM1014
	0.3, // WEAPON_C4
	0.3, // WEAPON_MAC10
	0.3, // WEAPON_AUG
	0.3, // WEAPON_SMOKEGRENADE
	0.3, // WEAPON_ELITE
	0.3, // WEAPON_FIVESEVEN
	0.3, // WEAPON_UMP45
	0.3, // WEAPON_SG550
	0.3, // WEAPON_GALIL
	0.3, // WEAPON_FAMAS
	0.3, // WEAPON_USP
	0.3, // WEAPON_GLOCK18
	0.3, // WEAPON_AWP
	0.3, // WEAPON_MP5N
	0.3, // WEAPON_M249
	0.3, // WEAPON_M3
	0.3, // WEAPON_M4A1
	0.3, // WEAPON_TMP
	0.3, // WEAPON_G3SG1
	0.3, // WEAPON_FLASHBANG
	0.3, // WEAPON_DEAGLE
	0.3, // WEAPON_SG552
	0.3, // WEAPON_AK47
	0.3, // WEAPON_KNIFE
	0.3, // WEAPON_P90
};

public plugin_init()
{
	register_plugin("recoil_manager", "2.0.0", "Kova");

	// new weaponName[24];

	// for (new i = 1; i < MAX_WEAPONS - 1; i++)
	// {
	// 	if ((1<<i) & ((1<<2) | (1<<CSW_KNIFE) | (1<<CSW_HEGRENADE) | (1<<CSW_FLASHBANG) | (1<<CSW_SMOKEGRENADE) | (1<<CSW_C4)))
	// 		continue;

	// 	rg_get_weapon_info(WeaponIdType:i, WI_NAME, weaponName, charsmax(weaponName));

	// 	RegisterHam(Ham_Weapon_PrimaryAttack, weaponName, "@CBasePlayerWeapon_PrimaryAttack_Post", true);
	// 	RegisterHam(Ham_Weapon_PrimaryAttack, weaponName, "@CBasePlayerWeapon_PrimaryAttack_Pre", false);
	// }

	RegisterHookChain(RG_CBaseEntity_FireBullets3, "@CBaseEntity_FireBullets3_Pre", false);
	RegisterHookChain(RG_CBaseEntity_FireBullets3, "@CBaseEntity_FireBullets3_Post", true);
	RegisterHookChain(RG_CBaseEntity_FireBullets, "@CBaseEntity_FireBullets_Pre", false);

	
}


#if defined HEAVY_LOAD

new Float:lastattack_start[33];
new Float:lastattack_stop[33];
new Float:lastattack_init[33];
new Float:lastattack_stamp[33];
new Float:lastattack_inter[33];
new Float:lastattack_global[33];
new Float:spead_shot[33];

new bInitAttack = 0;
new bCurrAttack = 0;


public client_PreThink(id)
{
    new btn;

    if(!is_user_alive(id))
        return;
    btn = get_user_button(id);
    if((btn & IN_ATTACK) && !bGet(id, bInitAttack)) {
		lastattack_start[id] = get_gametime();
		bSet(id, bInitAttack);
		bSet(id, bCurrAttack);
		client_print(id, print_chat,"+attack");
	}
	else if(!(btn & IN_ATTACK) && bGet(id, bInitAttack)) {
		lastattack_stop[id] = get_gametime();
		lastattack_inter[id] = 0.0;
		bRem(id, bInitAttack);
		client_print(id, print_chat,"-attack");
	}
}

// @CBasePlayerWeapon_PrimaryAttack_Pre(weapon)
// {
// 	set_member(weapon, m_Weapon_flAccuracy, 0.001);
// }

public CBaseEntity_FireBullets_Pre(iAttacker, cShots, Float:vecSrc[3],  Float:vecDirShooting[3], Float:vecSpread[3], Float:flDistance, iBulletType, iTracerFreq, iDamage, pevAttacker)
{
	client_print(iAttacker, print_chat,"CBaseEntity_FireBullets_Pre");
	if(get_user_weapon(iAttacker) != CSW_M3 || get_user_weapon(iAttacker) != CSW_XM1014)
		return HC_CONTINUE;
	
	xs_vec_mul_scalar(vecSpread, 0.1, vecSpread);
	SetHookChainArg(5, ATYPE_VECTOR, vecSpread);

	return HC_CONTINUE;
}

@CBaseEntity_FireBullets3_Pre(iAttacker, Float:vecSrc[3], Float:vecDirShooting[3], Float:vecSpread, Float:flDistance, iPenetration, iBulletType, iDamage, Float:flRangeModifier, pevAttacker, bool:bPistol, shared_rand)
{

	client_print(iAttacker, print_chat,"CBaseEntity_FireBullets3_Pre");

	// SetHookChainArg(4, ATYPE_FLOAT, 0.0);
	// SetHookChainArg(12, ATYPE_INTEGER, 0);
	// if(bGet(iAttacker, bInitAttack) && bGet(iAttacker, bCurrAttack))
	// {
	// 	bRem(iAttacker, bCurrAttack);
	// 	SetHookChainArg(4, ATYPE_FLOAT, 0.0);
	// 	SetHookChainArg(12, ATYPE_INTEGER, 0);
	// 	client_print(iAttacker, print_chat,"set");

	// 	static Float:vecPunchAngle[3];
	// 	get_entvar(iAttacker, var_punchangle, vecPunchAngle);

	// 	for (new i = 0; i < 3; i++)
	// 		vecPunchAngle[i] *= 0.3;

	// 	set_entvar(iAttacker, var_punchangle, vecPunchAngle);


	// }

	return HC_CONTINUE;
}

@CBaseEntity_FireBullets3_Post(iAttacker, Float:vecSrc[3], Float:vecDirShooting[3], Float:vecSpread, Float:flDistance, iPenetration, iBulletType, iDamage, Float:flRangeModifier, pevAttacker, bool:bPistol, shared_rand)
{
	client_print(iAttacker, print_chat,"CBaseEntity_FireBullets3_Post, vecS: %3.2f, rnd: %i", vecSpread, shared_rand);
}

// @CBasePlayerWeapon_PrimaryAttack_Post(weapon)
// {
// 	static id; id = get_member(weapon, m_pPlayer);
// 	rg_set_user_ammo(id, WEAPON_AK47, 30);
// 	static Float:gametime; gametime = get_gametime();
// 	if(bGet(id, bInitAttack) && lastattack_inter[id] == 0.0)
// 	{
// 		lastattack_global[id] -= lastattack_init[id] - gametime;
// 		if(lastattack_global[id] < 0.0)
// 			lastattack_global[id] = 0.0;

// 		lastattack_init[id] = gametime;
// 		spead_shot[id] = 0.0;
// 		client_print(id, print_chat,"bInitAttack");
// 	}
// 	spead_shot[id]++;
	
// 	static Float:diff; diff = lastattack_stamp[id] - gametime;
// 	static Float:offset; 
	
// 	//offset = (1.0 - (diff ^ Float:0x80000000))*(lastattack_global[id]*0.1)*(spead_shot[id]*0.1);

// 	if(offset < 0.0) offset = 0.15;
// 	client_print(id, print_chat,"diff: %f", diff);
// 	client_print(id, print_chat,"lastattack_global: %f", lastattack_global[id]);
// 	client_print(id, print_chat,"lastattack_inter: %f", lastattack_inter[id]);
// 	client_print(id, print_chat,"spead_shot: %f", spead_shot[id]);
// 	client_print(id, print_center,"offset: %f", offset);
// 	if(diff > 1.0)
// 	{
// 		lastattack_stamp[id] = gametime;
// 		return;
// 	}
// 	else if(diff < 0.0)
// 	{
// 		diff = 0.1;
// 	}
// 	lastattack_global[id] += diff;
// 	lastattack_inter[id] += diff;
// 	offset = 0.3 + lastattack_inter[id];

// 	static Float:vecPunchAngle[3];
// 	get_entvar(id, var_punchangle, vecPunchAngle);

// 	for (new i = 0; i < 3; i++)
// 		vecPunchAngle[i] *= offset > 1.0 ? 1.0 : offset;

// 	set_entvar(id, var_punchangle, vecPunchAngle);

// 	lastattack_stamp[id] = gametime;
// }

#else

#endif



#define DEBUG
#if defined DEBUG

new g_iSpriteId;
new g_iFwdFM_TraceLine_Post;

public plugin_precache()
	g_iSpriteId = precache_model("sprites/3dmflared.spr");

public plugin_cfg()
{
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_glock18",   "Ham_Attack_Pre",  0);
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_glock18",   "Ham_Attack_Post", 1);
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_usp",       "Ham_Attack_Pre",  0);
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_usp",       "Ham_Attack_Post", 1);
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_p228",      "Ham_Attack_Pre",  0);
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_p228",      "Ham_Attack_Post", 1);
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_deagle",    "Ham_Attack_Pre",  0);
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_deagle",    "Ham_Attack_Post", 1);
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_elite",     "Ham_Attack_Pre",  0);
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_elite",     "Ham_Attack_Post", 1);
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_fiveseven", "Ham_Attack_Pre",  0);
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_fiveseven", "Ham_Attack_Post", 1);
	
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_m3",        "Ham_Attack_Pre",  0);
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_m3",        "Ham_Attack_Post", 1);
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_xm1014",    "Ham_Attack_Pre",  0);
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_xm1014",    "Ham_Attack_Post", 1);
	
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_mac10",     "Ham_Attack_Pre",  0);
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_mac10",     "Ham_Attack_Post", 1);
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_tmp",       "Ham_Attack_Pre",  0);
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_tmp",       "Ham_Attack_Post", 1);
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_mp5navy",   "Ham_Attack_Pre",  0);
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_mp5navy",   "Ham_Attack_Post", 1);
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_ump45",     "Ham_Attack_Pre",  0);
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_ump45",     "Ham_Attack_Post", 1);
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_p90",       "Ham_Attack_Pre",  0);
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_p90",       "Ham_Attack_Post", 1);
	
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_galil",     "Ham_Attack_Pre",  0);
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_galil",     "Ham_Attack_Post", 1);
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_famas",     "Ham_Attack_Pre",  0);
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_famas",     "Ham_Attack_Post", 1);
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_ak47",      "Ham_Attack_Pre",  0);
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_ak47",      "Ham_Attack_Post", 1);
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_m4a1",      "Ham_Attack_Pre",  0);
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_m4a1",      "Ham_Attack_Post", 1);
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_sg552",     "Ham_Attack_Pre",  0);
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_sg552",     "Ham_Attack_Post", 1);
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_aug",       "Ham_Attack_Pre",  0);
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_aug",       "Ham_Attack_Post", 1);
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_g3sg1",     "Ham_Attack_Pre",  0);
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_g3sg1",     "Ham_Attack_Post", 1);
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_sg550",     "Ham_Attack_Pre",  0);
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_sg550",     "Ham_Attack_Post", 1);
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_scout",     "Ham_Attack_Pre",  0);
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_scout",     "Ham_Attack_Post", 1);
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_awp",       "Ham_Attack_Pre",  0);
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_awp",       "Ham_Attack_Post", 1);
	
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_m249",      "Ham_Attack_Pre",  0);
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_m249",      "Ham_Attack_Post", 1);
}

public Ham_Attack_Pre(iEnt)
{
	if( g_iFwdFM_TraceLine_Post )
	{
		unregister_forward(FM_TraceLine, g_iFwdFM_TraceLine_Post, 1);
		g_iFwdFM_TraceLine_Post = 0;
	}
	g_iFwdFM_TraceLine_Post = register_forward(FM_TraceLine, "FM_TraceLine_Post", 1);
}

public Ham_Attack_Post(iEnt)
{
	if( g_iFwdFM_TraceLine_Post )
	{
		unregister_forward(FM_TraceLine, g_iFwdFM_TraceLine_Post, 1);
		g_iFwdFM_TraceLine_Post = 0;
	}
}

public FM_TraceLine_Post(Float:fStart[3], Float:fEnd[3], iNoMonsters, iEntToSkip, iTraceResult)
{
	static Float:s_fTraceEnd[3];
	get_tr(TR_vecEndPos, s_fTraceEnd);
	
	message_begin(MSG_ALL, SVC_TEMPENTITY);
	write_byte(TE_SPRITE);
	engfunc(EngFunc_WriteCoord, s_fTraceEnd[0]);
	engfunc(EngFunc_WriteCoord, s_fTraceEnd[1]);
	engfunc(EngFunc_WriteCoord, s_fTraceEnd[2]);
	write_short(g_iSpriteId);
	write_byte(1);
	write_byte(255);
	message_end();
}
#endif