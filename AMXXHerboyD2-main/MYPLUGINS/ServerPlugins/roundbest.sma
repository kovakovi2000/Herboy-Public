#include <amxmodx> 
#include <amxmisc> 
#include <hamsandwich> 
#include <cstrike> 
#include <sk_utils> 

#define PLUGIN    "New Plugin" 
#define AUTHOR    "Unknown" 
#define VERSION    "1.0" 

new g_iKills[33], g_iHS[33], g_iDmg[33] 

public plugin_init() 
{ 
    register_plugin(PLUGIN,VERSION,AUTHOR) 
     
    RegisterHam(Ham_TakeDamage, "player", "hamTakeDamage") 
    register_event("DeathMsg", "EventDeathMsg", "a") 
    register_logevent("RoundEnd", 2, "1=Round_End")

    register_dictionary("roundbest.txt");
} 
public client_disconnected(id) 
{ 
    g_iDmg[id] = 0; 
    g_iKills[id] = 0; 
    g_iHS[id] = 0; 
} 
public hamTakeDamage(victim, inflictor, attacker, Float:damage, DamageBits) 
{ 
    if( 1 <= attacker <= 32) 
    { 
        if(cs_get_user_team(victim) != cs_get_user_team(attacker)) 
            g_iDmg[attacker] += floatround(damage) 
        else 
            g_iDmg[attacker] -= floatround(damage) 
    } 
} 
public EventDeathMsg() 
{ 
    new killer = read_data(1) 
    new victim = read_data(2) 
    new is_hs = read_data(3) 
     
    if(killer != victim && killer && cs_get_user_team(killer) != cs_get_user_team(victim)) 
    { 
        g_iKills[killer]++; 
         
        if(is_hs) 
            g_iHS[killer]++; 
    } 
    else 
        g_iKills[killer]--; 
} 
public RoundEnd() 
{ 
    new iBestPlayer = get_best_player() 
     
    new szName[32] 
    get_user_name(iBestPlayer, szName, charsmax(szName)) 

    sk_chat_lang("%L", "ROUNDBEST_PLAYER", szName)
    sk_chat_lang("%L", "ROUNDBEST_STATS", g_iKills[iBestPlayer], g_iHS[iBestPlayer])

    for(new i = 0 ; i < 33 ; i++) 
    { 
        g_iDmg[i] = 0; 
        g_iHS[i] = 0; 
        g_iKills[i] = 0; 
    } 
} 
get_best_player() 
{ 
    new players[32], num; 
    get_players(players, num); 
    SortCustom1D(players, num, "sort_bestplayer") 
     
    return players[0] 
} 
public sort_bestplayer(id1, id2) 
{ 
    if(g_iKills[id1] > g_iKills[id2]) 
        return -1; 
    else if(g_iKills[id1] < g_iKills[id2]) 
        return 1; 
    else 
    { 
        if(g_iDmg[id1] > g_iDmg[id2]) 
            return -1; 
        else if(g_iDmg[id1] < g_iDmg[id2]) 
            return 1; 
        else 
            return 0; 
    } 
     
    return 0; 
} 
