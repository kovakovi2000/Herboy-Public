/**
 *
 * Recoil Fix
 *  by Numb
 *
 *
 * Description:
 *  Have you ever watched someone play while being dead, and questioned
 *  yourself, why their bullets go directly into the middle of the
 *  crosshair when they are spraying like hell, while your go way above
 *  the crosshair? Well, I did, and found the answer. While you are
 *  spectating someone, you see their middle of the screen twice higher
 *  than they do (you see twice the recoil they actually do). Well,
 *  this plugin has many features, one of which is making you see the
 *  exact the same recoil, the spectated person has.
 *
 *
 * Requires:
 *  FakeMeta
 *  HamSandWich
 *
 *
 * Cvars:
 *
 *  + "recoil_fix" - state of the plugin.
 *  - "0" - disabled.
 *  - "1" - fix visual recoil for dead (make dead see what alive
 *         normally do). [default]
 *  - "2" - fix visual recoil for alive (make alive see what dead
 *         normally do).
 *  - "3" - the way it's meant to be (see additional info).
 *
 *
 * Additional Info:
 *  Tested in Counter-Strike 1.6 with amxmodx 1.8.2 (dev build hg20).
 *  Setting "recoil_fix" cvar to "3" or above, will change the actual
 *  recoil. It will make it twice smaller, therefor all spread bullets
 *  will go close to the crosshair (not extremely above it, as you are
 *  used to). This is the way it was intended to be in the first place
 *  long long time ago. It will also change visual recoil for dead. How
 *  ever I do not recommend setting the cvar to anything but "1",
 *  cause... Well "3" or above is changing the actual gameplay, and
 *  people can get confused why their bullets are going not as high as
 *  expected (they would actually go fairly near the corsshair), and
 *  "2" can also confuse people, why their recoil is twice stronger
 *  than  expected, while actually it's the same (only visual location
 *  of crosshair changes).
 *
 *
 * Notes:
 *  Just imagine the amount of the people who got falsely blamed and
 *  banned for using no-recoil script or some other cheat... I had this
 *  plugin idea for quite some time, and people tried to convince me
 *  that it has nothing to do with that... Well, I looked into it, and
 *  even some no-recoil scripts - I laughed, seriously, those things do
 *  nothing but make the game harder, at least in my opinion.
 *
 *
 * Warnings:
 *  Some bots may have a few issues with this plugin, cause by default
 *  they may be having a twice lower recoil already (for example
 *  Potti - a controllable fakeplayer
 *  ( http://forums.alliedmods.net/showthread.php?p=255078 )
 *  plugin/bot). So, having "recoil_fix" set to "1" may have an effect
 *  of no recoil for the dead person watching the alive bot. Setting it
 *  to "2", should have no effect on bots at all. Setting it to "3" or
 *  above, may cause issues of bots having no recoil what so ever.
 *
 *
 * ChangeLog:
 *
 *  + 1.0
 *  - First release.
 *
 *
 * Downloads:
 *  Amx Mod X forums: https://forums.alliedmods.net/showthread.php?p=1866111#post1866111
 *
**/


#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>

#define PLUGIN_NAME	"Recoil Fix"
#define PLUGIN_VERSION	"1.0"
#define PLUGIN_AUTHOR	"Numb"

#define SetPlayerBit(%1,%2)    ( %1 |=  ( 1 << ( %2 & 31 ) ) )
#define ClearPlayerBit(%1,%2)  ( %1 &= ~( 1 << ( %2 & 31 ) ) )
#define CheckPlayerBit(%1,%2)  ( %1 &   ( 1 << ( %2 & 31 ) ) )

#define m_pPlayer 41

new g_iCvar_RecoilFix;
new g_iAlive;

//#define DEBUG
//#define DEBUG_ANGLE

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);
	
	register_forward(FM_PlayerPostThink,  "FM_PlayerPostThink_Pre",   0);
	register_forward(FM_UpdateClientData, "FM_UpdateClientData_Post", 1);
	
	RegisterHam(Ham_Spawn,  "player", "Ham_Spawn_player_Post",  1);
	RegisterHam(Ham_Killed, "player", "Ham_Killed_player_Post", 1);
	
	g_iCvar_RecoilFix = register_cvar("recoil_fix", "3"); // 1 fix for dead, 2 fix for alive, 3 real fix
}

public plugin_unpause()
{
	g_iAlive = 0;
	
	new iPlayers[32], iPlayerNum;
	get_players(iPlayers, iPlayerNum, "a");
	for( new iLoop; iLoop<iPlayerNum; iLoop++ )
		SetPlayerBit(g_iAlive, iPlayers[iLoop]);
}

public client_disconnected(iPlrId)
	ClearPlayerBit(g_iAlive, iPlrId);

public FM_PlayerPostThink_Pre(iPlrId)
{
	if( CheckPlayerBit(g_iAlive, iPlrId) && get_pcvar_num(g_iCvar_RecoilFix)>=3 )
	{
		static Float:s_fAngle[3], Float:s_fPunchAngle[3];
		pev(iPlrId, pev_v_angle, s_fAngle);
		pev(iPlrId, pev_punchangle, s_fPunchAngle);
		s_fAngle[0] -= (s_fPunchAngle[0]-180.0);
		s_fAngle[1] -= (s_fPunchAngle[1]-180.0);
		s_fAngle[2] += 180.0;
		
		if( s_fAngle[0]<=0.0 || s_fAngle[0]>360.0 )
			s_fAngle[0] -= (float(floatround((s_fAngle[0]/360.0)))*360.0);
		if( s_fAngle[1]<=0.0 || s_fAngle[1]>360.0 )
			s_fAngle[1] -= (float(floatround((s_fAngle[1]/360.0)))*360.0);
		if( s_fAngle[2]<=0.0 || s_fAngle[2]>360.0 )
			s_fAngle[2] -= (float(floatround((s_fAngle[2]/360.0)))*360.0);
		
		s_fAngle[0] -= 180.0;
		s_fAngle[1] -= 180.0;
		s_fAngle[2] -= 180.0;
		
		set_pev(iPlrId, pev_v_angle, s_fAngle);
	}
	
#if defined DEBUG_ANGLE
	static Float:s_fPlrAngle[3];
	pev(iPlrId, pev_v_angle, s_fPlrAngle);
	client_print(iPlrId, print_center, "Angle %f %f", s_fPlrAngle[0], s_fPlrAngle[1]);
#endif
}

public FM_UpdateClientData_Post(iPlrId, iSendWeapons, iCdHandle)
{
	switch( clamp(get_pcvar_num(g_iCvar_RecoilFix), 0, 3) )
	{
		case 1: // make dead see it from alive point of view (where bullets should go, without spread caclulation)
		{
			if( !CheckPlayerBit(g_iAlive, iPlrId) )
			{
				static Float:s_fPunchAngle[3];
				get_cd(iCdHandle, CD_PunchAngle, s_fPunchAngle);
				s_fPunchAngle[0] *= 0.0;
				s_fPunchAngle[1] *= 0.0;
				s_fPunchAngle[2] *= 0.0;
				set_cd(iCdHandle, CD_PunchAngle, s_fPunchAngle);
			}
		}
		case 2: // make alive see it from dead point of view (where bullets do go, without spread caclulation)
		{
			if( !CheckPlayerBit(g_iAlive, iPlrId) )
			{
				static Float:s_fPunchAngle[3];
				get_cd(iCdHandle, CD_PunchAngle, s_fPunchAngle);
				s_fPunchAngle[0] *= 2.0;
				s_fPunchAngle[1] *= 2.0;
				s_fPunchAngle[2] *= 2.0;
				set_cd(iCdHandle, CD_PunchAngle, s_fPunchAngle);
			}
		}
		case 3: // make dead see it from alive point of view (where bullets do go, without spread caclulation)
		{
			if( !CheckPlayerBit(g_iAlive, iPlrId) )
			{
				static Float:s_fPunchAngle[3];
				get_cd(iCdHandle, CD_PunchAngle, s_fPunchAngle);
				s_fPunchAngle[0] *= 0.0;
				s_fPunchAngle[1] *= 0.0;
				s_fPunchAngle[2] *= 0.0;
				set_cd(iCdHandle, CD_PunchAngle, s_fPunchAngle);
			}
		}
	}
}

public Ham_Spawn_player_Post(iPlrId)
{
	if( is_user_alive(iPlrId) )
		SetPlayerBit(g_iAlive, iPlrId);
	else
		ClearPlayerBit(g_iAlive, iPlrId);
}

public Ham_Killed_player_Post(iPlrId)
{
	if( is_user_alive(iPlrId) )
		SetPlayerBit(g_iAlive, iPlrId);
	else
		ClearPlayerBit(g_iAlive, iPlrId);
}


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
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_p228",      "Ham_Attack_Pre",  0)
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
		unregister_forward(FM_TraceLine, g_iFwdFM_TraceLine_Post, 1)
		g_iFwdFM_TraceLine_Post = 0;
	}
	g_iFwdFM_TraceLine_Post = register_forward(FM_TraceLine, "FM_TraceLine_Post", 1);
}

public Ham_Attack_Post(iEnt)
{
	if( g_iFwdFM_TraceLine_Post )
	{
		unregister_forward(FM_TraceLine, g_iFwdFM_TraceLine_Post, 1)
		g_iFwdFM_TraceLine_Post = 0;
	}
}

public FM_TraceLine_Post(Float:fStart[3], Float:fEnd[3], iNoMonsters, iEntToSkip, iTraceResult)
{
	static Float:s_fTraceEnd[3];
	get_tr(TR_vecEndPos, s_fTraceEnd);
	
	message_begin(MSG_ALL, SVC_TEMPENTITY)
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