#include <amxmodx>
#include <reapi>
#include <fakemeta>
#include <hamsandwich>
#include <xs>
#include <vector>

#pragma dynamic 62768 

#define PLUGIN_NAME "HitBox FIX"
#define VERSION "4.6"
#define AUTHOR "Kova"

new Float:g_flAccuracy

public plugin_init()
{
    register_plugin(PLUGIN_NAME, VERSION, AUTHOR)

    new weaponName[24];

    for (new i = 1; i < MAX_WEAPONS - 1; i++)
    {
        if ((1<<i) & ((1<<2) | (1<<CSW_KNIFE) | (1<<CSW_HEGRENADE) | (1<<CSW_FLASHBANG) | (1<<CSW_SMOKEGRENADE) | (1<<CSW_C4)))
            continue;

        rg_get_weapon_info(WeaponIdType:i, WI_NAME, weaponName, charsmax(weaponName));

        if((1<<i) & ((1<<2) | (1<<CSW_XM1014) | (1<<CSW_ELITE) | (1<<CSW_SG550) | (1<<CSW_USP) | (1<<CSW_GLOCK18) | (1<<CSW_AWP) | (1<<CSW_M3) | (1<<CSW_G3SG1) | (1<<CSW_DEAGLE) | (1<<CSW_SCOUT)))
            continue;
        
        RegisterHam( Ham_Weapon_PrimaryAttack, weaponName, "Ham_Weapon_PrimaryAttack_Pre",false );
    }
}

public Ham_Weapon_PrimaryAttack_Pre(iEnt){

    g_flAccuracy = get_member(iEnt, m_Weapon_flAccuracy)
    g_flAccuracy = g_flAccuracy * 0.7
    set_member(iEnt, m_Weapon_flAccuracy,g_flAccuracy)
}