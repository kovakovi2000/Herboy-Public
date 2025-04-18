#include <amxmodx>
#include <reapi>
#include <ammoclip>
#include <tsstats>

#define PLUGIN "AmmoCounter"
#define VERSION "1.0"
#define AUTHOR "Kova"

new g_wShots[33][MAX_WEAPONS];
new g_wShotsLast[33][MAX_WEAPONS];

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR);
    RegisterHookChain(RG_CBasePlayer_AddPlayerItem, "fw_AddPlayerItem__post", .post = true);
    RegisterHookChain(RG_CBasePlayer_DropPlayerItem, "fw_DropPlayerItem__pre", .post = false);
    RegisterHookChain(RG_RoundEnd, "fw_RoundEnd__pre", .post = false);
    RegisterHookChain(RG_CBasePlayer_Spawn, "fw_Spawn__pre", .post = false); 
    RegisterHookChain(RG_CBasePlayer_Killed, "fw_Killed__pre", .post = false); 

    register_clcmd("statstest", "cmd_statstest");
}

public cmd_statstest(id)
{
    for(new i = 1; i < MAX_WEAPONS; i++)
    {
        new shots = get_user_shot_ammo(id, i);
        
        if(shots == -1)
            continue;

        new weaponName[32];
        get_weaponname(i, weaponName, charsmax(weaponName));

        console_print(id, "Weapon %s (%d): %d shots", weaponName, i, shots);
    }
}

public plugin_natives()
{
    register_native("get_user_shot_ammo","native_get_user_shot_ammo", 1);
    register_native("callculate_user_ammo","native_callculate_user_ammo", 1);
    register_native("restart_user_shot_ammo","native_restart_user_shot_ammo", 1);
}

public native_get_user_shot_ammo(const index, const at_id)
{
	return callculate_shots_weapon(index, at_id);
}

public native_callculate_user_ammo(const index)
{
    callculate_shots(index);
}

public native_restart_user_shot_ammo(const index, const iwpn)
{
    restart_stats_weapon(index, iwpn);
}

public LoadUtils() {}

stock callculate_shots(const id)
{
    static izStats[STATSX_MAX_STATS] = {0, ...};
    static izBody[MAX_BODYHITS] = {0, ...};
    
    for(new iwpn = 1; iwpn < MAX_WEAPONS; iwpn++) {
        if (!get_user_wstats(id, iwpn, izStats, izBody))
            continue;
        
        g_wShots[id][iwpn] += izStats[STATSX_SHOTS] - g_wShotsLast[id][iwpn];
        g_wShotsLast[id][iwpn] = izStats[STATSX_SHOTS];
    }
}

stock callculate_shots_weapon(const id, const iwpn)
{
    static izStats[STATSX_MAX_STATS] = {0, ...};
    static izBody[MAX_BODYHITS] = {0, ...};
    
    if (!get_user_wstats(id, iwpn, izStats, izBody))
        return -1;
        
    g_wShots[id][iwpn] += izStats[STATSX_SHOTS] - g_wShotsLast[id][iwpn];
    g_wShotsLast[id][iwpn] = izStats[STATSX_SHOTS];

    return g_wShots[id][iwpn];
}

stock clear_stats(const id)
{
    static izStats[STATSX_MAX_STATS] = {0, ...};
    static izBody[MAX_BODYHITS] = {0, ...};

    for(new iwpn = 1; iwpn < MAX_WEAPONS; iwpn++) {
        if (!get_user_wstats(id, iwpn, izStats, izBody))
            continue;
        
        g_wShots[id][iwpn] = 0;
        g_wShotsLast[id][iwpn] = izStats[STATSX_SHOTS];
    }
}

stock restart_stats_weapon(const id, const iwpn)
{
    static izStats[STATSX_MAX_STATS] = {0, ...};
    static izBody[MAX_BODYHITS] = {0, ...};

    if (!get_user_wstats(id, iwpn, izStats, izBody))
        return;
    
    g_wShots[id][iwpn] = 0;
    g_wShotsLast[id][iwpn] = izStats[STATSX_SHOTS];
}

public fw_AddPlayerItem__post(const id, const eItem)
{
    if(!is_user_connected(id))
        return;
    new iwpn = get_member(eItem, m_iId)
    restart_stats_weapon(id, iwpn);
}

public fw_DropPlayerItem__pre(const id)
{
    if(!is_user_connected(id))
        return;
    
    new eWep = get_member(id, m_pActiveItem);
    if (is_nullent(eWep))
		return;

    new iwpn = get_member(eWep, m_iId);
    callculate_shots_weapon(id, iwpn);
}

public fw_Killed__pre(const victim, const attacker, const gib)
{
    callculate_shots(victim);
}

public fw_RoundEnd__pre(const WinStatus:status, const ScenarioEventEndRound:event, const Float:tmDelay)
{
    for(new id = 1; id < 33; id++)
    {
        if(is_user_alive(id))
            callculate_shots(id);
    }
}

public fw_Spawn__pre(const id)
{
    clear_stats(id);
}

public client_putinserver(id)
{
    for(new iwpn = 0; iwpn < MAX_WEAPONS; iwpn++) {
        g_wShots[id][iwpn] = 0;
        g_wShotsLast[id][iwpn] = 0;
    }
}

public client_disconnected(id)
{
    if(is_user_connected(id))
        callculate_shots(id);
}
