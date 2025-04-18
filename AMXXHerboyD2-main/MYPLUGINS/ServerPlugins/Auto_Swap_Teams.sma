#include <amxmodx>
#include <cstrike>
#include <fakemeta_util>

//#pragma semicolon 1

new rounds_count=1, after_half=0;
new enable, live, half_rounds;

public plugin_init() 
{
	register_plugin("Auto Swap Teams", "1.6", "lo3 & many good guy:)");
	
	enable = register_cvar("ast_enable","1");
	half_rounds = register_cvar("ast_half_rounds","7");
	live = register_cvar("ast_live","1");

	register_event("HLTV", "event_round_start", "a", "1=0", "2=0");
	register_event("TextMsg", "restart", "a", "2&#Game_C", "2&#Game_W");
	register_event("SendAudio", "event_round_end", "a", "2&%!MRAD_terwin", "2&%!MRAD_ctwin", "2&%!MRAD_rounddraw");
	
	register_dictionary("Auto_Swap_Teams.txt");
}

public restart()
{
	rounds_count = 1;
}

public event_round_start()
{
    if(get_pcvar_num(enable)==1)
    {
		set_cvar_num("mp_maxrounds", get_pcvar_num(half_rounds)*2);
		
		if(after_half==0 && rounds_count <= get_pcvar_num(half_rounds))
		{
			set_hudmessage(100, 100, 100, -1.0, 0.40, 1, 6.0, 2.0, 1.0, 0.1, -1);
			show_hudmessage(0, "%L^n[%i/%i]", LANG_PLAYER, "ROUNDS1", rounds_count,get_pcvar_num(half_rounds));
			client_print(0, print_chat,"%L [%i/%i]", LANG_PLAYER, "ROUNDS1_CHAT", rounds_count, get_pcvar_num(half_rounds));
		}
		else if(after_half==1 && rounds_count <= get_pcvar_num(half_rounds))
		{
			set_hudmessage(100, 20, 30, -1.0, 0.40, 1, 6.0, 2.0, 1.0, 0.1, -1);
			show_hudmessage(0, "%L^n[%i/%i]", LANG_PLAYER, "ROUNDS2", rounds_count,get_pcvar_num(half_rounds));
			client_print(0, print_chat,"%L [%i/%i]", LANG_PLAYER, "ROUNDS2_CHAT", rounds_count, get_pcvar_num(half_rounds));
		}
    }
	else
	{
		donothing();
	}
}

public event_round_end()  /*Round Count ++ @ roundend*/
{
	rounds_count++;
	if( rounds_count > get_pcvar_num( half_rounds ) && after_half == 0)
	{
		new c_players[32], number;
		get_players( c_players, number );
		
		for( new i; i < number; i++ ){
			delay_change( c_players[i] );
		}
	}
	else if(rounds_count > get_pcvar_num(half_rounds)&&after_half == 1)
	{
		set_task(5.0, "changemap");
	}
}
public swap_teams(id)
{
	fm_strip_user_weapons(id);
	switch( cs_get_user_team(id) )
	{
		case CS_TEAM_CT: cs_set_user_team(id, CS_TEAM_T );
		case CS_TEAM_T: cs_set_user_team(id, CS_TEAM_CT );
	}
	
	client_print(0,print_chat,"%L", LANG_PLAYER, "LIVE_NOTICE");
	
	if(get_pcvar_num(live)==1)
	{	
		after_half = 1;
		rounds_count = 1;
		restartRound(id);
	}
	else
	{
		after_half = 1;
		rounds_count = 1;
		anothergame(id);
	}
}

public restartRound(id)
{
	set_task(3.0, "livego",id);
	set_task(4.0, "livego",id);
	set_task(5.0, "livego",id);
	set_task(5.1, "anothergame",id);
	return PLUGIN_HANDLED;
}

public livego(id)
{
	server_cmd("sv_restartround 1");
	client_print(id,print_chat,"%L", LANG_PLAYER, "LIVE");
}

public anothergame(id)
{
	client_print(id,print_chat,"%L", LANG_PLAYER, "NEW_TEAM"); 
	client_print(id,print_chat,"%L", LANG_PLAYER, "GOOD_GAME");
}

public donothing()
{
	return PLUGIN_HANDLED;
}

public changemap()
{
	new ntmap[32];
	get_cvar_string("amx_nextmap", ntmap, 31);
	server_cmd("changelevel %s", ntmap);
}

delay_change(id)
{
    switch(id)
    {
        case 1..7: set_task( 0.2, "swap_teams", id );
        case 8..15: set_task( 0.4, "swap_teams", id );
        case 16..23: set_task( 0.6, "swap_teams", id );
        case 24..32: set_task( 0.8, "swap_teams", id );
    }
}  
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil\\ fcharset136 Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1028\\ f0\\ fs16 \n\\ par }
*/
