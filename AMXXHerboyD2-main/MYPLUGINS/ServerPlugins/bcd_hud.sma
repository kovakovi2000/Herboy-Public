#include <amxmodx>
#include <amxmisc>
#include <csx>

new g_c4timer;
new mp_timec4;
new bool:b_planted = false;

new const PLUGIN[] = "Bomb CountHUD Timer"
new const VERSION[] = "0.1"
new const AUTHOR[] = "SAMURAI"

public plugin_init()
{
    register_plugin(PLUGIN,VERSION,AUTHOR);
    mp_timec4 = get_cvar_num("mp_c4timer");
    
    register_event("RoundTime", "newRound", "bc");
    register_event("SendAudio", "endRound", "a", "2&%!MRAD_terwin", "2&%!MRAD_ctwin", "2&%!MRAD_rounddraw");

}


public newRound()
{
    g_c4timer = 0
    b_planted = false;
}

public endRound()
{
    g_c4timer = -2
}

public bomb_planted()
{
    mp_timec4 = get_cvar_num("mp_c4timer")
    
    b_planted = true;
    g_c4timer = mp_timec4 
    set_task(1.0, "dispTime", 652450, "", 0, "b")
}

public bomb_defused()
{
	mp_timec4 = get_cvar_num("mp_c4timer")
	
	if(b_planted)
	remove_task(652450);
}

public bomb_explode()
{
    mp_timec4 = get_cvar_num("mp_c4timer")

    if(b_planted)
    remove_task(652450)
    
}
   

public dispTime()
{
    mp_timec4 = get_cvar_num("mp_c4timer")
    
    if(!b_planted)
    remove_task(652450)
    
    if(g_c4timer < 8) set_hudmessage(150, 0, 0, -1.0, 0.80, 0, 1.0, 1.0, 0.01, 0.01, -1)

    if(g_c4timer > 7) set_hudmessage(150, 150, 0, -1.0, 0.80, 0, 1.0, 1.0, 0.01, 0.01, -1)

    if(g_c4timer > 13) set_hudmessage(0, 150, 0, -1.0, 0.80, 0, 1.0, 1.0, 0.01, 0.01, -1)
        
    
    show_hudmessage(0, "C4: %d",g_c4timer)
    g_c4timer--
    
}
