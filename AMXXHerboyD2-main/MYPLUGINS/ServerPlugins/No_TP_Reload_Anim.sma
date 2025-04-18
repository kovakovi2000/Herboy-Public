#include <amxmodx>
#include <hamsandwich>
#include <fakemeta>

#define PLUGIN "No TP Reload Anim"
#define VERSION "1.0.0"
#define AUTHOR "Kova"

#define GetOwner(%1) (pev_valid(%1) ? pev(%1, 18) : 0)
#define GetSequence(%1) (is_user_connected(%1) ? pev(%1, 75) : 0)

new const WEAPONCONST[][] = 
{
    "weapon_glock18", "weapon_usp", "weapon_p228", "weapon_fiveseven", "weapon_deagle", "weapon_elite", "weapon_tmp", "weapon_mac10", "weapon_ump45",
    "weapon_mp5navy", "weapon_p90", "weapon_scout", "weapon_awp", "weapon_famas", "weapon_galil", "weapon_m3", "weapon_xm1014", "weapon_ak47", 
    "weapon_m4a1", "weapon_aug", "weapon_sg552", "weapon_sg550", "weapon_g3sg1", "weapon_m249"
};
new PreSeq[33]; new PostSeq;

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR);

    for(new i; i < sizeof(WEAPONCONST); i++)
    {
        RegisterHam(Ham_Weapon_Reload, WEAPONCONST[i], "HamHook_reload_pre", 0);
        RegisterHam(Ham_Weapon_Reload, WEAPONCONST[i], "HamHook_reload_post", 1);
    }
}

public HamHook_reload_pre(iEnt)
{
    static id; id = GetOwner(iEnt);
    PreSeq[id] = GetSequence(id);
}

public HamHook_reload_post(iEnt)
{
    static id; id = GetOwner(iEnt);
    PostSeq = GetSequence(id);
    if(PreSeq[id] == (PostSeq - 2))
        set_pev(id, pev_sequence, PreSeq[id]);
    if(PreSeq[id] == (PostSeq - 1))
        set_pev(id, pev_sequence, (PreSeq[id] - 1) );
}