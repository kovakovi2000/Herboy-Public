#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <mod>


#define RED 64
#define GREEN 64
#define BLUE 64
#define UPDATEINTERVAL 1.0

#define ECHOCMD

#define FLAG ADMIN_BAN

new const PLUGIN[] = "nezolista";
new const VERSION[] = "1.2a";
new const AUTHOR[] = "eki";

new gMaxPlayers;
new gCvarOn;
new gCvarImmunity;
new bool:gOnOff[33] = { true, ... };

new g_Fps[33]
new g_Count[33]

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	register_cvar(PLUGIN, VERSION, FCVAR_SERVER, 0.0);
	gCvarOn = register_cvar("amx_speclist", "1", 0, 0.0);
	gCvarImmunity = register_cvar("amx_speclist_immunity", "1", 0, 0.0);
	
	
	gMaxPlayers = get_maxplayers();
	
	set_task(UPDATEINTERVAL, "tskShowSpec", 123094, "", 0, "b", 0);
}

public client_PostThink( id )
{
	g_Count[ id ]++ 
	
	static Last[ 33 ] 
	
	if( floatround( get_gametime( ) ) == Last[ id ] ) 
		return
	
	Last[ id ] = floatround( get_gametime( ) ) 
	
	g_Fps[ id ] = g_Count[ id ] 
	g_Count[ id ] = 0
	
	return
}

public cmdSpecList(id)
{
	if( gOnOff[id] )
	{
		gOnOff[id] = false;
	}
	else
	{
		gOnOff[id] = true;
	}
	
	#if defined ECHOCMD
	return PLUGIN_CONTINUE;
	#else
	return PLUGIN_HANDLED;
	#endif
}

public tskShowSpec()
{
	if( !get_pcvar_num(gCvarOn) )
	{
		return PLUGIN_CONTINUE;
	}
	
	static szHud[1102];
	static szName[34];
	static bool:send;
	
	for( new alive = 1; alive <= gMaxPlayers; alive++ )
	{
		new bool:sendTo[33];
		send = false;
		
		if( !is_user_alive(alive) )
		{
			continue;
		}
		
		sendTo[alive] = true;
		
		get_user_name(alive, szName, 32);
		format(szHud, 45, "%s | [%d FPS] ^n^nNézők:^n", szName, g_Fps[alive]); 
		
		for( new dead = 1; dead <= gMaxPlayers; dead++ )
		{
			if( is_user_connected(dead) )
			{
				if( is_user_alive(dead)
				|| is_user_bot(dead) )
				{
					continue;
				}
				
				if( pev(dead, pev_iuser2) == alive )
				{
					if( !(get_pcvar_num(gCvarImmunity)&&get_user_flags(dead, 0)&FLAG) )
					{
						get_user_name(dead, szName, 32);
						add(szName, 33, "^n", 0);
						add(szHud, 1101, szName, 0);
						send = true;
					}
					
					sendTo[dead] = true;
					
				}
			}
		}
		
		if( send == true )
		{
			for( new i = 1; i <= gMaxPlayers; i++ )
			{
				if( sendTo[i] == true
				&& !sm_get_speclist(i) )
				{
					set_hudmessage(random_num(0,255), random_num(0,255), random_num(0,255),
					0.75, 0.15, 0, 0.0, UPDATEINTERVAL + 0.1, 0.0, 0.0, -1);
					
					show_hudmessage(i, szHud);
				}
			}
		}
	}
	
	return PLUGIN_CONTINUE;
}

public client_connect(id)
{
	gOnOff[id] = true;
}

public client_disconnected(id)
{
	gOnOff[id] = true;
}