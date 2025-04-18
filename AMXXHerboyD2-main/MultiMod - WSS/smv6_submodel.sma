/* Sublime AMXX Editor v4.2 */

#include <amxmodx>
#include <cstrike>
#include <reapi>
#include <fakemeta>
#include <amxmisc>
#include <engine>
#include <hamsandwich>
#include <reapi>
#include <mod>

#define PLUGIN  "[sMod v5] - Submodel Technology"
#define AUTHOR  "Shedi, Kova"

#define bGet(%2,%1) (%1 & (1<<(%2&31)))
#define bSet(%2,%1) (%1 |= (1<<(%2&31)))
#define bRem(%2,%1) (%1 &= ~(1 <<(%2&31)))

new g_bDisabled;

new g_bInTrow;
#define TASK_OFFSET_DEBUGWEAP 967200
#define TASK_OFFSET_DEBUGWEAP_PHASE 969300

#define WEAPONTYPE_ELITE 				1
#define WEAPONTYPE_GLOCK18				2
#define WEAPONTYPE_FAMAS 				3
#define WEAPONTYPE_OTHER 				4
#define WEAPONTYPE_M4A1 				5
#define WEAPONTYPE_USP 					6

#define IDLE_ANIM 						0
#define GRENADE_PULLPIN 				1
#define C4_PRESSBUTTON 				3
#define KNIFE_STABMISS 					5
#define KNIFE_MIDATTACK1HIT 			6
#define KNIFE_MIDATTACK2HIT 			7
#define KNIFE_SLASH1        		1
#define KNIFE_SLASH2        		4
#define GLOCK18_SHOOT2 					4
#define GLOCK18_SHOOT3 					5
#define AK47_SHOOT1 					3
#define AUG_SHOOT1 						3
#define AWP_SHOOT2 						2
#define DEAGLE_SHOOT1 					2
#define ELITE_SHOOTLEFT5 				6
#define ELITE_SHOOTRIGHT5 				12
#define CLARION_SHOOT2 					4
#define CLARION_SHOOT3 					3
#define FIVESEVEN_SHOOT1 				1
#define G3SG1_SHOOT 					1
#define GALIL_SHOOT3 					5
#define M3_FIRE2 						2
#define XM1014_FIRE2 					2
#define M4A1_SHOOT3						3
#define M4A1_UNSIL_SHOOT3 				10
#define M249_SHOOT2 					2
#define MAC10_SHOOT1 					3
#define MP5N_SHOOT1 					3
#define P90_SHOOT1 						3
#define P228_SHOOT2 					2
#define SCOUT_SHOOT 					1
#define SG550_SHOOT 					1
#define SG552_SHOOT2 					4
#define TMP_SHOOT3 						5
#define UMP45_SHOOT2 					4
#define USP_UNSIL_SHOOT3 				11
#define USP_SHOOT3						3

#define DRYFIRE_PISTOL "weapons/dryfire_pistol.wav"
#define DRYFIRE_RIFLE "weapons/dryfire_rifle.wav"
#define GLOCK18_BURST_SOUND "weapons/glock18-1.wav"
#define GLOCK18_SHOOT_SOUND "weapons/glock18-2.wav"
#define AK47_SHOOT_SOUND "weapons/ak47-1.wav"
#define AUG_SHOOT_SOUND "weapons/aug-1.wav"
#define AWP_SHOOT_SOUND "weapons/awp1.wav"
#define DEAGLE_SHOOT_SOUND "weapons/deagle-1.wav"
#define ELITE_SHOOT_SOUND "weapons/elite_fire.wav"
#define CLARION_BURST_SOUND "weapons/famas-1.wav"
#define CLARION_SHOOT_SOUND "weapons/famas-1.wav"
#define FIVESEVEN_SHOOT_SOUND "csgor/fiveseven.wav"
#define G3SG1_SHOOT_SOUND "weapons/g3sg1-1.wav"
#define GALIL_SHOOT_SOUND "weapons/galil-1.wav"
#define M3_SHOOT_SOUND "weapons/m3-1.wav"
#define XM1014_SHOOT_SOUND "weapons/xm1014-1.wav"
#define M4A1_SILENT_SOUND "weapons/m4a1-1.wav"
#define M4A1_SHOOT_SOUND "weapons/m4a1_unsil-1.wav"
#define M249_SHOOT_SOUND "weapons/m249-1.wav"
#define MAC10_SHOOT_SOUND "weapons/mac10-1.wav"
#define MP5_SHOOT_SOUND "weapons/mp5-1.wav"
#define P90_SHOOT_SOUND "weapons/p90-1.wav"
#define P228_SHOOT_SOUND "weapons/p228-1.wav"
#define SCOUT_SHOOT_SOUND "weapons/scout_fire-1.wav"
#define SG550_SHOOT_SOUND "weapons/sg550-1.wav"
#define SG552_SHOOT_SOUND "weapons/sg552-1.wav"
#define TMP_SHOOT_SOUND "weapons/tmp-1.wav"
#define UMP45_SHOOT_SOUND "weapons/ump45-1.wav"
#define USP_SHOOT_SOUND "weapons/usp_unsil-1.wav"
#define USP_SILENT_SOUND "weapons/usp1.wav"
#define GRENADE_PULLPIN_SOUND "weapons/pinpull.wav"
#define C4_PRESSBUTTON_SOUND ""
#define KNIFE_SLASH1_SOUND "weapons/knife_slash1.wav"
#define KNIFE_SLASH2_SOUND "weapons/knife_slash2.wav"


#define IsPlayer(%0,%1)                    (1 <= %0 <= %1)

new const g_szGEvents[25][] = 
{
    "events/awp.sc",
    "events/g3sg1.sc",
    "events/ak47.sc",
    "events/scout.sc",
    "events/m249.sc",
    "events/m4a1.sc",
    "events/sg552.sc",
    "events/aug.sc",
    "events/sg550.sc",
    "events/m3.sc",
    "events/xm1014.sc",
    "events/usp.sc",
    "events/mac10.sc",
    "events/ump45.sc",
    "events/fiveseven.sc",
    "events/p90.sc",
    "events/deagle.sc",
    "events/p228.sc",
    "events/glock18.sc",
    "events/mp5n.sc",
    "events/tmp.sc",
    "events/elite_left.sc",
    "events/elite_right.sc",
    "events/galil.sc",
    "events/famas.sc"
}
new GrenadeName[][] =
{
	"weapon_hegrenade",
	"weapon_flashbang",
	"weapon_smokegrenade"
}
// 512 because of MAX_EVEN TS const from engine. Found this as the most reasonable way to achieve it without a loop in playback event.
new bool:g_bGEventID[512]
new TraceBullets[][] = { "func_breakable", "func_wall", "func_door", "func_plat", "func_rotating", "worldspawn", "func_door_rotating" }
new iPlayer_SubmodelIndex[33] = -1;
new g_iMaxPlayers


public plugin_precache()
{
	g_iMaxPlayers = get_maxplayers()
	precache_sound(DRYFIRE_PISTOL)
	precache_sound(DRYFIRE_RIFLE)
	precache_sound(GLOCK18_BURST_SOUND)
	precache_sound(GLOCK18_SHOOT_SOUND)
	precache_sound(AK47_SHOOT_SOUND)
	precache_sound(AUG_SHOOT_SOUND)
	precache_sound(AWP_SHOOT_SOUND)
	precache_sound(DEAGLE_SHOOT_SOUND)
	precache_sound(ELITE_SHOOT_SOUND)
	precache_sound(CLARION_BURST_SOUND)
	precache_sound(CLARION_SHOOT_SOUND)
	precache_sound(FIVESEVEN_SHOOT_SOUND)
	precache_sound(G3SG1_SHOOT_SOUND)
	precache_sound(GALIL_SHOOT_SOUND)
	precache_sound(M3_SHOOT_SOUND)
	precache_sound(XM1014_SHOOT_SOUND)
	precache_sound(M4A1_SILENT_SOUND)
	precache_sound(M4A1_SHOOT_SOUND)
	precache_sound(M249_SHOOT_SOUND)
	precache_sound(MAC10_SHOOT_SOUND)
	precache_sound(MP5_SHOOT_SOUND)
	precache_sound(P90_SHOOT_SOUND)
	precache_sound(P228_SHOOT_SOUND)
	precache_sound(SCOUT_SHOOT_SOUND)
	precache_sound(SG550_SHOOT_SOUND)
	precache_sound(SG552_SHOOT_SOUND)
	precache_sound(TMP_SHOOT_SOUND)
	precache_sound(UMP45_SHOOT_SOUND)
	precache_sound(USP_SHOOT_SOUND)
	precache_sound(USP_SILENT_SOUND)
	precache_sound(GRENADE_PULLPIN_SOUND)

	RegisterHookChain(RH_SV_AddResource, "RH_SV_AddResource_Post", 1)
}

public plugin_init()
{
	register_plugin(PLUGIN, "1.0", AUTHOR)

	register_forward(FM_PlaybackEvent, "FM_Hook_PlayBackEvent_Pre")
	register_forward(FM_PlaybackEvent, "FM_Hook_PlayBackEvent_Primary_Pre")

	register_forward(FM_ClientUserInfoChanged, "FM_ClientUserInfoChanged_ClientWeap_Pre")

	RegisterHookChain(RG_CBasePlayerWeapon_DefaultDeploy, "RG_CBasePlayerWeapon_DefaultDeploy_Post", 1);
	RegisterHookChain(RH_SV_StartSound, "RH_SV_StartSound_Pre");
	RegisterHookChain(RG_CBasePlayerWeapon_DefaultReload, "RG_CBasePlayerWeapon_DefaultReload_Pre", 0);
	RegisterHookChain(RG_CBasePlayer_Observer_FindNextPlayer, "RG_CBasePlayer_Observer_FindNextPlayer_Post", 1);

	for (new i; i < sizeof(TraceBullets); i++)
	{
		RegisterHam(Ham_TraceAttack, TraceBullets[i], "HamF_TraceAttack_Post", 1)
	}

	for( new i; i < sizeof(GrenadeName); i++ )
	{
		RegisterHam(Ham_Weapon_PrimaryAttack, GrenadeName[i], "Ham_GrenadePrimaryAttack_Pre")
		//RegisterHam(Ham_Weapon_SecondaryAttack, GrenadeName[i], "Ham_GrenadeSecondaryAttack_Pre")
	}
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_knife", "Ham_KnifePrimaryAttack_Pre", 0) // NEM JÓ
	RegisterHam(Ham_Weapon_SecondaryAttack, "weapon_knife", "Ham_KnifeSecondaryAttack_Pre", 0) // NEM JÓ
}

public RG_CBasePlayer_Observer_FindNextPlayer_Post(const id)
{
	new iTarget = get_member(id, m_hObserverTarget);
	if (is_user_alive(iTarget) && iPlayer_SubmodelIndex[iTarget] != -1)
		SendWeaponAnim(iTarget)
}

public Ham_KnifePrimaryAttack_Pre(iEnt)
{
	if (is_nullent(iEnt))
		return

	new id = GetEntityOwner(iEnt)

	WeaponShootInfo2(id, iEnt, KNIFE_SLASH1, KNIFE_SLASH1_SOUND, 1, WEAPONTYPE_OTHER);

	return;
}

public Ham_KnifeSecondaryAttack_Pre(iEnt)
{
	if (is_nullent(iEnt))
		return

	new id = GetEntityOwner(iEnt)

	WeaponShootInfo2(id, iEnt, KNIFE_SLASH2, KNIFE_SLASH2_SOUND, 1, WEAPONTYPE_OTHER);

	return;
}

public Ham_GrenadePrimaryAttack_Pre(iEnt)
{
	if (is_nullent(iEnt))
		return

	new id = GetEntityOwner(iEnt)

	if(bGet(id, g_bInTrow))
		return;
	
	bSet(id, g_bInTrow);

	switch(GetWeaponEntity(iEnt))
	{
		case CSW_HEGRENADE: WeaponShootInfo2(id, iEnt, GRENADE_PULLPIN, GRENADE_PULLPIN_SOUND, 1, WEAPONTYPE_OTHER);
		case CSW_FLASHBANG: WeaponShootInfo2(id, iEnt, GRENADE_PULLPIN, GRENADE_PULLPIN_SOUND, 1, WEAPONTYPE_OTHER);
		case CSW_SMOKEGRENADE: WeaponShootInfo2(id, iEnt, GRENADE_PULLPIN, GRENADE_PULLPIN_SOUND, 1, WEAPONTYPE_OTHER);
	}
}

public bomb_planting(id)
{
	SendWeaponAnim(id, C4_PRESSBUTTON);
}

public RG_CBasePlayerWeapon_DefaultReload_Pre(const ent, iClipSize, animation, Float:fDelay)
{
	if(is_nullent(ent))
		return

	new iPlayer = GetEntityOwner(ent)
	
	new weapon = GetWeaponEntity(ent)

	new clipInWeapon, ammoInWeapon;
	get_user_ammo(iPlayer, weapon, clipInWeapon, ammoInWeapon)

	if(clipInWeapon == iClipSize)
		return;

	if(!(CSW_P228 <= weapon <= CSW_P90))
		return
	
	SendWeaponAnim(iPlayer, animation);
}

public d21(id)
{
	server_cmd("restart");
	return PLUGIN_CONTINUE;
}

public RH_SV_StartSound_Pre(const recipients, const entity, const channel, const sample[], const volume, Float:attenuation, const fFlags, const pitch)
{
	if(!is_user_connected(entity))
		return

	if(containi(sample, "dryfire_rifle") != -1)
	{
		SetHookChainArg(4, ATYPE_STRING, DRYFIRE_RIFLE)
	}
	else if(containi(sample, "dryfire_pistol") != -1)
	{
		SetHookChainArg(4, ATYPE_STRING, DRYFIRE_PISTOL)
	}
}
public HamF_TraceAttack_Post(iEnt, iAttacker, Float:damage, Float:fDir[3], ptr, iDamageType)
{
	if(is_nullent(iAttacker))
		return

	new iWeapon
	static Float:vecEnd[3]

	iWeapon = GetPlayerActiveItem(iAttacker)
	
	new iWeaponEnt = GetWeaponEntity(iWeapon)

	if(!IsValidWeapon(iWeaponEnt) || !iWeaponEnt || iWeaponEnt == CSW_KNIFE)
		return

	get_tr2(ptr, TR_vecEndPos, vecEnd)

	engfunc(EngFunc_MessageBegin, MSG_PAS, SVC_TEMPENTITY, vecEnd, 0)
	write_byte(TE_GUNSHOTDECAL)
	engfunc(EngFunc_WriteCoord, vecEnd[0])
	engfunc(EngFunc_WriteCoord, vecEnd[1])
	engfunc(EngFunc_WriteCoord, vecEnd[2])
	write_short(iEnt)
	write_byte(random_num(41, 45))
	message_end()
}

public RH_SV_AddResource_Post(ResourceType_t:type, const filename[], size, flags, index)
{
	switch(type)
	{
		case t_eventscript:
		{
			for(new i; i < sizeof(g_szGEvents); i++)
			{
				if (equali(filename, g_szGEvents[i]))
				{
					g_bGEventID[index] = true
					break;
				}
			}
		}
	}
}

public FM_Hook_PlayBackEvent_Pre(iFlags, pPlayer, iEvent, Float:fDelay, Float:vecOrigin[3], Float:vecAngle[3], Float:flParam1, Float:flParam2, iParam1, iParam2, bParam1, bParam2)
{
	for(new i = 0; i < 33; i++)
	{
		if((get_entvar(i, var_iuser1) != OBS_IN_EYE || get_entvar(i, var_iuser2) != pPlayer) || bGet(pPlayer, g_bDisabled))
			continue

		return FMRES_SUPERCEDE
	}

	return FMRES_IGNORED
}
public FM_Hook_PlayBackEvent_Primary_Pre(iFlags, id, eventid, Float:delay, Float:FlOrigin[3], Float:FlAngles[3], Float:FlParam1, Float:FlParam2, iParam1, iParam2, bParam1, bParam2)
{
	if(!is_user_connected(id) || is_nullent(id) || !IsPlayer(id, g_iMaxPlayers) || !g_bGEventID[eventid])
		return FMRES_IGNORED

	new iEnt = get_user_weapon(id)

	PrimaryAttackReplace(id, iEnt)

	if(bGet(id, g_bDisabled))
		return FMRES_IGNORED
	return FMRES_SUPERCEDE
}

public FM_ClientUserInfoChanged_ClientWeap_Pre(id)
{
	new userInfo[6] = "cl_lw"
	new clientValue[2]

	if(bGet(id, g_bDisabled))
	{
		if (get_user_info(id, userInfo, clientValue, charsmax(clientValue)))
		{
			new serverValue[2] = "1"
			set_user_info(id, userInfo, serverValue)

			return FMRES_SUPERCEDE
		}
	}
	else
	{
		if (get_user_info(id, userInfo, clientValue, charsmax(clientValue)))
		{
			new serverValue[2] = "0"
			set_user_info(id, userInfo, serverValue)

			return FMRES_SUPERCEDE
		}
	}
	

	return FMRES_IGNORED
}

WeaponDrawAnim(iEntity)
{
	if(is_nullent(iEntity))
		return -1

	static DrawAnim, WeaponState:mWeaponState

	mWeaponState = get_member(iEntity, m_Weapon_iWeaponState)

	switch(GetWeaponEntity(iEntity))
	{
		case CSW_P228, CSW_XM1014, CSW_M3: DrawAnim = 6
		case CSW_SCOUT, CSW_SG550, CSW_M249, CSW_G3SG1: DrawAnim = 4
		case CSW_MAC10, CSW_AUG, CSW_UMP45, CSW_GALIL, CSW_FAMAS, CSW_MP5NAVY, CSW_TMP, CSW_SG552, CSW_AK47, CSW_P90: DrawAnim = 2
		case CSW_ELITE: DrawAnim = 15
		case CSW_FIVESEVEN, CSW_AWP, CSW_DEAGLE: DrawAnim = 5
		case CSW_GLOCK18: DrawAnim = 8
		case CSW_KNIFE, CSW_HEGRENADE, CSW_FLASHBANG, CSW_SMOKEGRENADE: DrawAnim = 3
		case CSW_C4: DrawAnim = 1
		case CSW_USP:
		{
			DrawAnim = (mWeaponState & WPNSTATE_USP_SILENCED) ? 6 : 14
		}
		case CSW_M4A1:
		{
			DrawAnim = (mWeaponState & WPNSTATE_M4A1_SILENCED) ? 5 : 12
		}
	}
	return DrawAnim
}

PrimaryAttackReplace(id, iEnt)
{
	switch(iEnt)
	{
		case CSW_GLOCK18: WeaponShootInfo2(id, iEnt, GLOCK18_SHOOT3, GLOCK18_SHOOT_SOUND, 1, WEAPONTYPE_GLOCK18)
		case CSW_AK47: WeaponShootInfo2(id, iEnt, AK47_SHOOT1, AK47_SHOOT_SOUND, 1, WEAPONTYPE_OTHER)
		case CSW_AUG: WeaponShootInfo2(id, iEnt, AUG_SHOOT1, AUG_SHOOT_SOUND, 1, WEAPONTYPE_OTHER)
		case CSW_AWP: WeaponShootInfo2(id, iEnt, AWP_SHOOT2, AWP_SHOOT_SOUND, 1, WEAPONTYPE_OTHER)
		case CSW_DEAGLE: WeaponShootInfo2(id, iEnt, DEAGLE_SHOOT1, DEAGLE_SHOOT_SOUND, 1, WEAPONTYPE_OTHER)
		case CSW_ELITE: WeaponShootInfo2(id, iEnt, ELITE_SHOOTRIGHT5, ELITE_SHOOT_SOUND, 1, WEAPONTYPE_ELITE)
		case CSW_FAMAS: WeaponShootInfo2(id, iEnt, CLARION_SHOOT3, CLARION_SHOOT_SOUND, 1, WEAPONTYPE_FAMAS)
		case CSW_FIVESEVEN: WeaponShootInfo2(id, iEnt, FIVESEVEN_SHOOT1, FIVESEVEN_SHOOT_SOUND, 1, WEAPONTYPE_OTHER)
		case CSW_G3SG1: WeaponShootInfo2(id, iEnt, G3SG1_SHOOT, G3SG1_SHOOT_SOUND, 1, WEAPONTYPE_OTHER)
		case CSW_GALIL: WeaponShootInfo2(id, iEnt, GALIL_SHOOT3, GALIL_SHOOT_SOUND, 1, WEAPONTYPE_OTHER)
		case CSW_M3: WeaponShootInfo2(id, iEnt, M3_FIRE2, M3_SHOOT_SOUND, 1, WEAPONTYPE_OTHER)
		case CSW_XM1014: WeaponShootInfo2(id, iEnt, XM1014_FIRE2, XM1014_SHOOT_SOUND, 1, WEAPONTYPE_OTHER)
		case CSW_M4A1: WeaponShootInfo2(id, iEnt, M4A1_UNSIL_SHOOT3, M4A1_SHOOT_SOUND, 1, WEAPONTYPE_M4A1)
		case CSW_M249: WeaponShootInfo2(id, iEnt, M249_SHOOT2, M249_SHOOT_SOUND, 1, WEAPONTYPE_OTHER)
		case CSW_MAC10: WeaponShootInfo2(id, iEnt, MAC10_SHOOT1, MAC10_SHOOT_SOUND, 1, WEAPONTYPE_OTHER)
		case CSW_MP5NAVY: WeaponShootInfo2(id, iEnt, MP5N_SHOOT1, MP5_SHOOT_SOUND, 1, WEAPONTYPE_OTHER)
		case CSW_P90: WeaponShootInfo2(id, iEnt, P90_SHOOT1, P90_SHOOT_SOUND, 1, WEAPONTYPE_OTHER)
		case CSW_P228: WeaponShootInfo2(id, iEnt, P228_SHOOT2, P228_SHOOT_SOUND, 1, WEAPONTYPE_OTHER)
		case CSW_SCOUT: WeaponShootInfo2(id, iEnt, SCOUT_SHOOT, SCOUT_SHOOT_SOUND, 1, WEAPONTYPE_OTHER)
		case CSW_SG550: WeaponShootInfo2(id, iEnt, SG550_SHOOT, SG550_SHOOT_SOUND, 1, WEAPONTYPE_OTHER)
		case CSW_SG552: WeaponShootInfo2(id, iEnt, SG552_SHOOT2, SG552_SHOOT_SOUND, 1, WEAPONTYPE_OTHER)
		case CSW_TMP: WeaponShootInfo2(id, iEnt, TMP_SHOOT3, TMP_SHOOT_SOUND, 1, WEAPONTYPE_OTHER)
		case CSW_UMP45: WeaponShootInfo2(id, iEnt, UMP45_SHOOT2, UMP45_SHOOT_SOUND, 1, WEAPONTYPE_OTHER)
		case CSW_USP: WeaponShootInfo2(id, iEnt, USP_UNSIL_SHOOT3, USP_SHOOT_SOUND, 1, WEAPONTYPE_USP)
	}
}

public WeaponShootInfo2(iPlayer, iEnt, iAnim, const szSoundFire[], iPlayAnim, iWeaponType)
{
	if(!is_user_connected(iPlayer) || is_nullent(iPlayer) || !IsPlayer(iPlayer, g_iMaxPlayers))
		return

	new iWID
	iWID = GetPlayerActiveItem(iPlayer)

	static szSound[128]

	new WeaponState:iWeaponState = get_member(iWID, m_Weapon_iWeaponState)
	copy(szSound, 512, szSoundFire)

	if(!iWeaponState)
	{
		PlayWeaponState(iPlayer, szSound, iAnim)
		return
	}

	switch(iWeaponType)
	{
		case WEAPONTYPE_ELITE:
		{
			if(iWeaponState & WPNSTATE_ELITE_LEFT)
			{
				PlayWeaponState(iPlayer, ELITE_SHOOT_SOUND, ELITE_SHOOTLEFT5)
			}
		}
		case WEAPONTYPE_GLOCK18:
		{
			if(iWeaponState & WPNSTATE_GLOCK18_BURST_MODE)
			{
				PlayWeaponState(iPlayer, GLOCK18_BURST_SOUND, GLOCK18_SHOOT2)
			}
		}
		case WEAPONTYPE_FAMAS:
		{
			if(iWeaponState & WPNSTATE_FAMAS_BURST_MODE)
			{

				PlayWeaponState(iPlayer, CLARION_BURST_SOUND, CLARION_SHOOT2)
			}
		}
		case WEAPONTYPE_M4A1:
		{
			if(iWeaponState & WPNSTATE_M4A1_SILENCED)
			{

				PlayWeaponState(iPlayer, M4A1_SILENT_SOUND, M4A1_SHOOT3)
			}
		}
		case WEAPONTYPE_USP: 
		{
			if(iWeaponState & WPNSTATE_USP_SILENCED)
			{
				PlayWeaponState(iPlayer, USP_SILENT_SOUND, USP_SHOOT3)
			}
		}
	}
}

PlayWeaponState(iPlayer, const szShootSound[], iWeaponAnim = -1)
{
	//rh_emit_sound2(iPlayer, 0, CHAN_WEAPON, szShootSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

	if(!bGet(iPlayer, g_bDisabled))
		emit_sound(iPlayer, CHAN_WEAPON, szShootSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	
	if(iWeaponAnim)
		SendWeaponAnim(iPlayer, iWeaponAnim)
}

GetPlayerActiveItem(id)
{
	return get_member(id, m_pActiveItem)
}

GetWeaponEntity(iEnt)
{
	return rg_get_iteminfo(iEnt, ItemInfo_iId)
}

SendWeaponAnim(iPlayer, iAnim = 0)
{
	if(!is_user_connected(iPlayer) || !IsPlayer(iPlayer, g_iMaxPlayers))
		return

	static iWeapon 
	iWeapon = GetPlayerActiveItem(iPlayer)

	if(is_nullent(iWeapon))
		return

	static iBody

	if(iPlayer_SubmodelIndex[iPlayer] != -1)
		iBody = iPlayer_SubmodelIndex[iPlayer]
	else
		iBody = 0;
	
	if(!bGet(iPlayer, g_bDisabled))
	{
		set_entvar(iWeapon, var_body, iBody)
		set_entvar(iPlayer, var_weaponanim, iAnim)

		if(is_user_alive(iPlayer))
			rg_weapon_send_animation(iPlayer, iAnim)
	}

	if(get_entvar(iPlayer, var_iuser1))
		return
		
	for(new i = 0; i < 33; i++)
	{
		if(get_entvar(i, var_iuser1) != OBS_IN_EYE || get_entvar(i, var_iuser2) != iPlayer || !is_user_connected(i)) 
			continue

		set_entvar(i, var_weaponanim, iAnim)

		message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, _, i)
		write_byte(iAnim)

		if(bGet(i, g_bDisabled))
			write_byte(2)
		else
			write_byte(iBody)
		message_end()
	}
}
bool:IsValidWeapon(iWeapon)
{
	if(iWeapon < 1 || iWeapon > 30)
		return false

	return true
}
GetEntityOwner(iEnt)
{
	return get_member(iEnt, m_pPlayer)
}
public RG_CBasePlayerWeapon_DefaultDeploy_Post(ent, sViewModel[], sWeaponModel[], iAnim, szAnimExt[], skiplocal)
{
	if(is_nullent(ent))
		return
	
	new iPlayer = GetEntityOwner(ent)
	new weapon = GetWeaponEntity(ent)

	if(!(CSW_P228 <= weapon <= CSW_P90))
		return
	
	if(!weapon) return

	bRem(iPlayer, g_bInTrow);
	DeployWeaponSwitch(iPlayer, ent)

	return;
}
DeployWeaponSwitch(iPlayer, iEnt)
{
	new iWeapon = GetPlayerActiveItem(iPlayer)
	new userInfo[6] = "cl_lw";

	if (is_nullent(iWeapon))
		return
	
	iPlayer_SubmodelIndex[iPlayer] = get_entvar(iEnt, var_euser3)

	if(sm_get_skindisabled(iPlayer))
	{
		bRem(iPlayer, g_bDisabled)

		new serverValue[2] = "0";
		set_user_info(iPlayer, userInfo, serverValue);
	}
	else
	{
		bSet(iPlayer, g_bDisabled)

		new serverValue[2] = "1";
		set_user_info(iPlayer, userInfo, serverValue);
	}

	SendWeaponAnim(iPlayer, WeaponDrawAnim(iWeapon))
}

public client_putinserver(id)
{
	bRem(id, g_bDisabled);
	iPlayer_SubmodelIndex[id] = -1;

}
