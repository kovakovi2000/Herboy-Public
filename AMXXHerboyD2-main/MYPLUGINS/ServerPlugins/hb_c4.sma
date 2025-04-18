#include <amxmodx>
#include <engine> 
#include <fakemeta>
#include <csx>
#include <sk_utils>
public LoadUtils()
{ }
#define PLUGIN  "HerBoyD2 C4"
#define VERSION "1.0"
#define AUTHOR  "EXILLE"

#define WORLD_MODEL "models/hb_multimod_v5/event/hb_c4.mdl"
#define OLDWORLD_MODEL "models/w_c4.mdl"


new xEnt, xC4[33]

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_forward(FM_SetModel, "xFwSetModel")
}

public client_putinserver(id) { xC4[id] = true

}
public plugin_precache()
{
	precache_model(WORLD_MODEL)
}


public xFwSetModel(ent, model[])
{
	if(!is_valid_ent(ent))
		return FMRES_IGNORED

	new className[33]
	entity_get_string(ent, EV_SZ_classname, className, 32)
	
	if(equali(model, OLDWORLD_MODEL))
	{		
		if(equal(className, "weaponbox") || equal(className, "armoury_entity") || equal(className, "grenade"))
		{
			new x = random_num(1, 3)

			engfunc(EngFunc_SetModel, ent, WORLD_MODEL)
			entity_set_int(ent, EV_INT_sequence, x)
			entity_set_float(ent, EV_FL_framerate, 1.0)

			xEnt = ent

			return FMRES_SUPERCEDE
		}
	}
	
	return FMRES_IGNORED
}



stock xRegisterSay(szsay[], szfunction[])
{
	new sztemp[64]
	formatex(sztemp, 63 , "say /%s", szsay)
	register_clcmd(sztemp, szfunction)
	
	formatex(sztemp, 63 , "say .%s", szsay)
	register_clcmd(sztemp, szfunction)
	
	formatex(sztemp, 63 , "say_team /%s", szsay)
	register_clcmd(sztemp, szfunction )
	
	formatex(sztemp, 63 , "say_team .%s", szsay)
	register_clcmd(sztemp, szfunction)
}

stock xClientPrintColor(const id, const input[], any:...)
{
	new count = 1, players[32]
	static msg[191]
	vformat(msg, 190, input, 3)
	
	replace_all(msg, 190, "!g", "^4")
	replace_all(msg, 190, "!y", "^1")
	replace_all(msg, 190, "!t", "^3")
	replace_all(msg, 190, "!t2", "^0")
	
	if (id) players[0] = id; else get_players(players, count, "ch")

	for (new i = 0; i < count; i++)
	{
		if (is_user_connected(players[i]))
		{
			message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, players[i])
			write_byte(players[i])
			write_string(msg)
			message_end()
		}
	}
}
