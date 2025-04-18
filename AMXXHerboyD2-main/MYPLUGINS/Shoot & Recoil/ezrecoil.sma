#include <amxmodx>
#include <hamsandwich>
#include <fakemeta>
#include <engine>
#include <reapi>
#include <xs>
#include <sk_utils>
#include <manager>

#define PLUGIN "EzRecoil"
#define VERSION "1.0.0"
#define AUTHOR "Kova"

#define bGet(%2,%1) (%1 & (1<<(%2&31)))
#define bSet(%2,%1) (%1 |= (1<<(%2&31)))
#define bRem(%2,%1) (%1 &= ~(1 <<(%2&31)))

#define TASK_OFFSET_JOINMENU 9074

static szQuery[3584];

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	register_menucmd(register_menuid("recoilmenu"), 0xFFFF, "recoilmenu_h");
	register_clcmd("say /recoil", "PromptUser");

	new weaponName[24];

	for (new i = 1; i < MAX_WEAPONS - 1; i++)
	{
		if ((1<<i) & ((1<<2) | (1<<CSW_KNIFE) | (1<<CSW_HEGRENADE) | (1<<CSW_FLASHBANG) | (1<<CSW_SMOKEGRENADE) | (1<<CSW_C4)))
			continue;

		rg_get_weapon_info(WeaponIdType:i, WI_NAME, weaponName, charsmax(weaponName));

		
		if((1<<i) & ((1<<2) | (1<<CSW_XM1014) | (1<<CSW_ELITE) | (1<<CSW_SG550) | (1<<CSW_USP) | (1<<CSW_GLOCK18) | (1<<CSW_AWP) | (1<<CSW_M3) | (1<<CSW_G3SG1) | (1<<CSW_DEAGLE) | (1<<CSW_SCOUT)))
		{
			//RegisterHam(Ham_Weapon_PrimaryAttack, weaponName, "@CBasePlayerWeapon_PrimaryAttack_Post", true);
		}
		else
		{
			RegisterHam(Ham_Weapon_PrimaryAttack, weaponName, "@CBasePlayerWeapon_PrimaryAttack_Post", true);
			RegisterHam(Ham_Weapon_PrimaryAttack, weaponName, "@CBasePlayerWeapon_PrimaryAttack_Pre", false);
			RegisterHam(Ham_Item_Deploy, weaponName, "@CBasePlayerWeapon_Deloy_Post", true);
		}
	}
}

new bInitAttack = 0;
new bInAir = 0;
new shots[33];
new bEnabled;

public client_PreThink(id)
{
	if(!bGet(id, bEnabled))
		return;
	if(!is_user_alive(id))
		return;

	static iButton, iFlags;

	iButton = get_user_button(id);
	iFlags = get_entvar(id, var_flags);
	if((iButton & IN_ATTACK) && !bGet(id, bInitAttack)) {
		bSet(id, bInitAttack);
	}
	else if(!(iButton & IN_ATTACK) && bGet(id, bInitAttack)) {
		bRem(id, bInitAttack);
	}

	if(iFlags & FL_ONGROUND) {
		bRem(id, bInAir);
	}
	else {
		bSet(id, bInAir);
	}
}

@CBasePlayerWeapon_Deloy_Post(weapon)
{
	static id; id = get_member(weapon, m_pPlayer);

	if(!bGet(id, bEnabled))
		return;

	shots[id] = 0;
}

new Float:vecPunchAngle[33][3];
@CBasePlayerWeapon_PrimaryAttack_Pre(weapon)
{
	static id; id = get_member(weapon, m_pPlayer);

	if(!bGet(id, bEnabled))
		return;

	static Float:NewVelocity[3];
	static Float:speed;speed = vector_length(NewVelocity);
	get_entvar(id, var_velocity, NewVelocity);
	if(speed > 90.0)
		set_member(weapon, m_Weapon_flAccuracy, 1.0);
	else
		set_member(weapon, m_Weapon_flAccuracy, 0.0);

	
	get_entvar(id, var_punchangle, vecPunchAngle[id]);
	
	if(shots[id] > 1 && vecPunchAngle[id][0] == 0.0 && vecPunchAngle[id][1] == 0.0 && vecPunchAngle[id][2] == 0.0) {
		shots[id] = 0;
	}
	shots[id] += 1;
}

@CBasePlayerWeapon_PrimaryAttack_Post(weapon)
{
	static id; id = get_member(weapon, m_pPlayer);

	if(!bGet(id, bEnabled))
		return;
	
	if(bGet(id, bInAir) || shots[id] > 3)
		return;

	static Float:NewVelocity[3];
	get_entvar(id, var_velocity, NewVelocity);
	static Float:speed;speed = vector_length(NewVelocity);
	if(speed > 90.0)
		return;

	new Float:vecPunchAngleCurr[3];
	get_entvar(id, var_punchangle, vecPunchAngleCurr);

	for (new i = 0; i < 3; i++)
	{
		vecPunchAngleCurr[i] -= vecPunchAngle[id][i];
		vecPunchAngleCurr[i] *= 0.3 + ((shots[id] > 1) ? (float(shots[id])*0.2) : (float(shots[id])*0.11));
		vecPunchAngleCurr[i] += vecPunchAngle[id][i];
	}

	set_entvar(id, var_punchangle, vecPunchAngleCurr);
}












public client_putinserver(id)
{
	if(random(2) == 1)
		bSet(id, bEnabled);
	else
		bRem(id, bEnabled);

	if(task_exists(id+TASK_OFFSET_JOINMENU))
		remove_task(id+TASK_OFFSET_JOINMENU);
	set_task(10.0, "PromptUser", id+TASK_OFFSET_JOINMENU);
}

public PromptUser(id)
{
	if(id > 33) id -= TASK_OFFSET_JOINMENU;

	if(task_exists(id+TASK_OFFSET_JOINMENU))
		remove_task(id+TASK_OFFSET_JOINMENU);

	if(!is_user_connected(id))
		return PLUGIN_HANDLED;
	
	static menu_id, menu_key;
	get_user_menu(id, menu_id, menu_key);
	if(menu_id != 0)
	{
		set_task(1.0, "PromptUser", id+TASK_OFFSET_JOINMENU);
		return PLUGIN_HANDLED;
	}

	new Menu[512], MenuKey;
	add(Menu, 511, "[\rHerBoy\w] \y» \wEzRecoil^n^n");
	add(Menu, 511, "\rSzeretnéd kipróbálni a recoil módosítást?^n");
	add(Menu, 511, "\wEz egy teszt melyet alapján eldöntjük, hogy szükségetek van-e erre^n");
	add(Menu, 511, "\wavagy ez egy felesleges változtatás amit el kell meghagyni.^n");
	add(Menu, 511, "\d(újracsatlakozásnál újra betudod állítani)^n^n");
	add(Menu, 511, "\w[\r1\w] \yKiprobálom (támogatom)^n");
	add(Menu, 511, "\w[\r2\w] \yHagyjuk (jó ahogy most van)^n");
	
	
	

	MenuKey = (1<<0 | 1<<1 | 1<<2 | 1<<3 | 1<<4 | 1<<5 | 1<<6 | 1<<7 | 1<<8 | 1<<9);
	show_menu(id, MenuKey, Menu, -1, "recoilmenu");

	return PLUGIN_CONTINUE;
}


public recoilmenu_h(id, MenuKey){
	MenuKey++;
	switch(MenuKey)
	{
		case 1: {
			bSet(id, bEnabled);
			sk_chat(id, "Te a ^4teszt ^1recoilt fogod használni következő körtől (állítsd át ^4/recoil ^1commanddal)");
		}
		case 2: {
			bRem(id, bEnabled);
			sk_chat(id, "Te a ^4alap ^1recoilt fogod használni következő körtől (állítsd át ^4/recoil ^1commanddal)");
		}
		default: {
			PromptUser(id);
		}
	}
	if(task_exists(id+TASK_OFFSET_JOINMENU))
		remove_task(id+TASK_OFFSET_JOINMENU);
}

public plugin_cfg()
{
	SQL_ThreadQuery(m_get_sql(), "QueryErrorHandler", "CREATE TABLE IF NOT EXISTS _recoil_vote (steamid VARCHAR(32) NOT NULL UNIQUE, recoil_enabled BOOLEAN NOT NULL, PRIMARY KEY (steamid));", _, _);
}

public client_disconnected(id)
{
	if(is_user_bot(id))
		return;

	new steamid[32];
	get_user_authid(id, steamid, charsmax(steamid));
	
	formatex(szQuery, charsmax(szQuery), "INSERT INTO _recoil_vote (steamid, recoil_enabled) VALUES ('%s', %s) ON DUPLICATE KEY UPDATE recoil_enabled = VALUES(recoil_enabled);", steamid, (bGet(id, bEnabled) ? "TRUE" : "FALSE"));
	SQL_ThreadQuery(m_get_sql(), "QueryErrorHandler", szQuery, _, _);
}

public QueryErrorHandler(FailState, Handle:Query, Error[], Errcode, data[], DataSize, Float:Queuetime){
	if( FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED ){
		if(contain(Error, "Duplicate entry") == -1)
			log_amx("%s", Error);
		return;
	}
}

































//#define DEBUG
// #if defined DEBUG

// new g_iSpriteId;
// new g_iFwdFM_TraceLine_Post;

// public plugin_precache()
// 	g_iSpriteId = precache_model("sprites/3dmflared.spr");

// public plugin_cfg()
// {
// 	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_glock18",   "Ham_Attack_Pre",  0);
// 	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_glock18",   "Ham_Attack_Post", 1);
// 	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_usp",       "Ham_Attack_Pre",  0);
// 	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_usp",       "Ham_Attack_Post", 1);
// 	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_p228",      "Ham_Attack_Pre",  0);
// 	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_p228",      "Ham_Attack_Post", 1);
// 	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_deagle",    "Ham_Attack_Pre",  0);
// 	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_deagle",    "Ham_Attack_Post", 1);
// 	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_elite",     "Ham_Attack_Pre",  0);
// 	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_elite",     "Ham_Attack_Post", 1);
// 	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_fiveseven", "Ham_Attack_Pre",  0);
// 	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_fiveseven", "Ham_Attack_Post", 1);
	
// 	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_m3",        "Ham_Attack_Pre",  0);
// 	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_m3",        "Ham_Attack_Post", 1);
// 	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_xm1014",    "Ham_Attack_Pre",  0);
// 	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_xm1014",    "Ham_Attack_Post", 1);
	
// 	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_mac10",     "Ham_Attack_Pre",  0);
// 	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_mac10",     "Ham_Attack_Post", 1);
// 	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_tmp",       "Ham_Attack_Pre",  0);
// 	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_tmp",       "Ham_Attack_Post", 1);
// 	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_mp5navy",   "Ham_Attack_Pre",  0);
// 	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_mp5navy",   "Ham_Attack_Post", 1);
// 	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_ump45",     "Ham_Attack_Pre",  0);
// 	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_ump45",     "Ham_Attack_Post", 1);
// 	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_p90",       "Ham_Attack_Pre",  0);
// 	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_p90",       "Ham_Attack_Post", 1);
	
// 	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_galil",     "Ham_Attack_Pre",  0);
// 	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_galil",     "Ham_Attack_Post", 1);
// 	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_famas",     "Ham_Attack_Pre",  0);
// 	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_famas",     "Ham_Attack_Post", 1);
// 	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_ak47",      "Ham_Attack_Pre",  0);
// 	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_ak47",      "Ham_Attack_Post", 1);
// 	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_m4a1",      "Ham_Attack_Pre",  0);
// 	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_m4a1",      "Ham_Attack_Post", 1);
// 	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_sg552",     "Ham_Attack_Pre",  0);
// 	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_sg552",     "Ham_Attack_Post", 1);
// 	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_aug",       "Ham_Attack_Pre",  0);
// 	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_aug",       "Ham_Attack_Post", 1);
// 	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_g3sg1",     "Ham_Attack_Pre",  0);
// 	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_g3sg1",     "Ham_Attack_Post", 1);
// 	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_sg550",     "Ham_Attack_Pre",  0);
// 	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_sg550",     "Ham_Attack_Post", 1);
// 	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_scout",     "Ham_Attack_Pre",  0);
// 	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_scout",     "Ham_Attack_Post", 1);
// 	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_awp",       "Ham_Attack_Pre",  0);
// 	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_awp",       "Ham_Attack_Post", 1);
	
// 	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_m249",      "Ham_Attack_Pre",  0);
// 	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_m249",      "Ham_Attack_Post", 1);
// }

// public Ham_Attack_Pre(iEnt)
// {
// 	if( g_iFwdFM_TraceLine_Post )
// 	{
// 		unregister_forward(FM_TraceLine, g_iFwdFM_TraceLine_Post, 1);
// 		g_iFwdFM_TraceLine_Post = 0;
// 	}
// 	g_iFwdFM_TraceLine_Post = register_forward(FM_TraceLine, "FM_TraceLine_Post", 1);
// }

// public Ham_Attack_Post(iEnt)
// {
// 	if( g_iFwdFM_TraceLine_Post )
// 	{
// 		unregister_forward(FM_TraceLine, g_iFwdFM_TraceLine_Post, 1);
// 		g_iFwdFM_TraceLine_Post = 0;
// 	}
// }

// public FM_TraceLine_Post(Float:fStart[3], Float:fEnd[3], iNoMonsters, iEntToSkip, iTraceResult)
// {
// 	static Float:s_fTraceEnd[3];
// 	get_tr(TR_vecEndPos, s_fTraceEnd);
	
// 	message_begin(MSG_ALL, SVC_TEMPENTITY);
// 	write_byte(TE_SPRITE);
// 	engfunc(EngFunc_WriteCoord, s_fTraceEnd[0]);
// 	engfunc(EngFunc_WriteCoord, s_fTraceEnd[1]);
// 	engfunc(EngFunc_WriteCoord, s_fTraceEnd[2]);
// 	write_short(g_iSpriteId);
// 	write_byte(1);
// 	write_byte(255);
// 	message_end();
// }
// #endif