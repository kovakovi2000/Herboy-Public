#include <amxmodx>
#include <reapi>
#include <fakemeta>
#include <hamsandwich>
#include <xs>
#include <vector>
#include <mod>

#pragma dynamic 62768 

#define PLUGIN_NAME "HitBox FIX"
#define VERSION "4.3"
#define AUTHOR "Kova"

#define bGet(%2,%1) (%1 & (1<<(%2&31)))
#define bSet(%2,%1) (%1 |= (1<<(%2&31)))
#define bRem(%2,%1) (%1 &= ~(1 <<(%2&31)))

new Float:g_flTempPunch[3]
new Float:g_flPlayerPunchAngle[33][3]
new g_isUserDisabled;
new bool:bGO = true
new bool:g_bShot[33], bool:g_bDelay[33]
new Float:g_flAccuracy

public plugin_init()
{
    register_plugin(PLUGIN_NAME, VERSION, AUTHOR)
    register_forward(FM_UpdateClientData , "UpdateClientData",0);
    RegisterHam(Ham_Spawn, "player" ,"SetPlayerRecoilStatus", 1);
    
    new weaponName[24];

    for (new i = 1; i < MAX_WEAPONS - 1; i++)
    {
        if ((1<<i) & ((1<<2) | (1<<CSW_KNIFE) | (1<<CSW_HEGRENADE) | (1<<CSW_FLASHBANG) | (1<<CSW_SMOKEGRENADE) | (1<<CSW_C4)))
            continue;

        rg_get_weapon_info(WeaponIdType:i, WI_NAME, weaponName, charsmax(weaponName));

        if((1<<i) & ((1<<2) | (1<<CSW_XM1014) | (1<<CSW_ELITE) | (1<<CSW_SG550) | (1<<CSW_USP) | (1<<CSW_GLOCK18) | (1<<CSW_AWP) | (1<<CSW_M3) | (1<<CSW_G3SG1) | (1<<CSW_DEAGLE) | (1<<CSW_SCOUT)))
            continue;

        RegisterHam( Ham_Item_PostFrame, weaponName, "Ham_Item_PostFrame_Post", true );
        RegisterHam( Ham_Weapon_PrimaryAttack, weaponName, "Ham_Weapon_PrimaryAttack_Pre",false );
    }
}
public SetPlayerRecoilStatus(id){
    if(sm_get_recoilcontrol(id))
    {
        bSet(id, g_isUserDisabled)
    }
    else
    { 
        bRem(id, g_isUserDisabled)
    }
}
public Ham_Weapon_PrimaryAttack_Pre(iEnt){
    static id
    id = pev(iEnt, pev_owner)
    if(bGet(id, g_isUserDisabled)) 
    {
        return HAM_IGNORED;
    }
    g_bShot[id] = true
    get_entvar(id,var_punchangle,g_flPlayerPunchAngle[id])
    set_member(iEnt,m_Weapon_bDelayFire,false)
     
    g_flAccuracy = get_member(iEnt, m_Weapon_flAccuracy)
    //server_print("acc %f", g_flAccuracy)
    g_flAccuracy = g_flAccuracy *0.9
    set_member(iEnt, m_Weapon_flAccuracy,g_flAccuracy)
}
public Ham_Item_PostFrame_Post(iEnt){
    
    static id
    id = pev(iEnt, pev_owner)
    if(g_bShot[id]){
        set_member(iEnt,m_Weapon_bDelayFire,false)
        get_entvar(id,var_punchangle,g_flTempPunch)
        //xs_vec_mul_scalar(g_flTempPunch, 0.9, g_flTempPunch);
        set_entvar(id,var_punchangle,g_flPlayerPunchAngle[id])
        xs_vec_sub(g_flTempPunch,g_flPlayerPunchAngle[id],g_flPlayerPunchAngle[id])
        g_bShot[id] = false
        g_bDelay[id] = true
    }
}
public UpdateClientData( id, iSendWeapons, cd_handle )
{
    if(g_bDelay[id]){
        //get_cd(cd_handle,CD_PunchAngle, g_flTempPunch)

        //xs_vec
        get_entvar(id,var_punchangle,g_flTempPunch)
        xs_vec_add(g_flTempPunch,g_flPlayerPunchAngle[id],g_flTempPunch)
        set_entvar(id,var_punchangle,g_flTempPunch)
        g_bDelay[id]=false
    }
	//set_cd(cd_handle, CD_flNextAttack, get_gametime() + 0.001)

    return FMRES_IGNORED;
}
public asd(id){
    bGO = !bGO
    client_print(id, print_chat," go: %s", bGO ? "megy":"nem")
}
/*
@CBasePlayer_PreThink(const id){
    if(!is_user_alive(id)) return

	static buttons, oldbuttons;
	buttons = get_entvar(id, var_button);
	oldbuttons = get_entvar(id, var_oldbuttons);

    if(buttons & IN_ATTACK && !(oldbuttons & IN_ATTACK) && bGO)
    {
        g_bShot[id] = true
        get_entvar(id,var_punchangle,g_flPlayerPunchAngle[id])
        //the client pressed the IN_USE button, not holding the button down
    }
}
@CBasePlayer_PostThink(const id){
    if(!is_user_alive(id)) return
    if(g_bShot[id]){
        get_entvar(id,var_punchangle,g_flTempPunch)
        set_entvar(id,var_punchangle,g_flPlayerPunchAngle[id])
        xs_vec_sub(g_flTempPunch,g_flPlayerPunchAngle[id],g_flPlayerPunchAngle[id])
        g_bShot[id] = false
        g_bDelay[id] = true
    }
}*/