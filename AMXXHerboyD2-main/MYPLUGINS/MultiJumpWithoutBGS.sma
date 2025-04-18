#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <sk_utils>
public LoadUtils() { }

#define _sens 40.0
#define _block 0.25
#define SPEEDLIMIT 300.0

new jumpnum[33] = 0
new bool:dojump[33] = false
new Float:doduck[33] = 0.0
new Float:BlockUntil[33] = 0.0

new Float:NewVelocity[33][3];
new Float:VerticalVelocity[33];
new Float:speed[33];
new bool:g_Alive[33];
new bool:last_FL_ONGROUND[33];

public plugin_init()
{
	register_plugin("MultiJumpBGSBLock","2.3","Kova")
	register_cvar("amx_maxjumps","1")
	RegisterHam(Ham_Spawn, "player", "hamPlayerSpawn", 1);
	register_event("DeathMsg", "eventPlayerDeath", "a");
}

public hamPlayerSpawn(id)
{
    if(!is_user_alive(id))
      return;
 
    g_Alive[id] = true;
}

public eventPlayerDeath()
{
  g_Alive[read_data(2)] = false;
}

public client_putinserver(id)
{
	jumpnum[id] = 0
	dojump[id] = false
	doduck[id] = 0.0
	BlockUntil[id] = 0.0
	last_FL_ONGROUND[id] = true;
}

public client_disconnected(id)
{
	jumpnum[id] = 0
	dojump[id] = false
	doduck[id] = 0.0
	BlockUntil[id] = 0.0
	g_Alive[id] = false;
	last_FL_ONGROUND[id] = true;
}

public client_PreThink(id)
{
	if(!g_Alive[id])
		return PLUGIN_CONTINUE
	
	new nbut = get_user_button(id)
	new obut = get_user_oldbutton(id)

	if(get_entity_flags(id) & FL_ONGROUND)
	{
		if(last_FL_ONGROUND[id] == false)
			SpeedTester(id);
		last_FL_ONGROUND[id] = true;
		if((nbut & IN_DUCK) && !(obut & IN_DUCK))
		{
			doduck[id] = get_gametime() + 0.05;
		}
	}

	if(!(get_entity_flags(id) & FL_ONGROUND))
	{
		last_FL_ONGROUND[id] = false;
		if((nbut & IN_JUMP) && !(obut & IN_JUMP))
		{
			if(jumpnum[id] < get_cvar_num("amx_maxjumps"))
			{
				dojump[id] = true
				jumpnum[id]++
				return PLUGIN_CONTINUE
			}
		}
	}
	if((nbut & IN_JUMP) && (get_entity_flags(id) & FL_ONGROUND))
	{
		jumpnum[id] = 0
		return PLUGIN_CONTINUE
	}
	return PLUGIN_CONTINUE
}

public client_PostThink(id)
{
	if(!g_Alive[id])
		return PLUGIN_CONTINUE

	if(get_gametime() < doduck[id] && fm_distance_to_floor(id) > 0.0)
		BlockUntil[id] = get_gametime() + _block;
		
	if(dojump[id] == true)
	{
		if(BlockUntil[id] > get_gametime())
		{
			dojump[id] = false;
			jumpnum[id]--
			return PLUGIN_CONTINUE;
		}

		new Float:velocity[3]	
		entity_get_vector(id,EV_VEC_velocity,velocity)
		velocity[2] = random_float(265.0,285.0)
		entity_set_vector(id,EV_VEC_velocity,velocity)
		dojump[id] = false
		return PLUGIN_CONTINUE
	}
	return PLUGIN_CONTINUE
}	

public SpeedTester(id)
{
  get_user_velocity(id, NewVelocity[id]);
  VerticalVelocity[id] = NewVelocity[id][2];
  NewVelocity[id][2] = 0.0;
  speed[id] = vector_length(NewVelocity[id]);
  if(speed[id] > SPEEDLIMIT)
  {
    NewVelocity[id][0] = NewVelocity[id][0] * (SPEEDLIMIT / speed[id]);
    NewVelocity[id][1] = NewVelocity[id][1] * (SPEEDLIMIT / speed[id]);
    NewVelocity[id][2] = VerticalVelocity[id];
    set_user_velocity(id, NewVelocity[id]);
  }
}

stock Float:fm_distance_to_floor(index, ignoremonsters = 1) 
{
	new Float:start[3], Float:dest[3], Float:end[3];
	pev(index, pev_origin, start);
	dest[0] = start[0];
	dest[1] = start[1];
	dest[2] = -8191.0;

	engfunc(EngFunc_TraceLine, start, dest, ignoremonsters, index, 0);
	get_tr2(0, TR_vecEndPos, end);

	pev(index, pev_absmin, start);
	new Float:ret = start[2] - end[2];

	return ret > 0 ? ret : 0.0;
}
