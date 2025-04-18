#include <amxmodx>  
#include <amxmisc>  
#include <fakemeta>  
#include <engine>  
#include <sk_utils>

#define MAX_BS 2  

new const site_name[][] =  
{  
"B Plant",  
"A Plant",  
"C Plant"  
//etc  
}  

public plugin_init()  
{ 
register_logevent("BombPlant", 3, "2=Planted_The_Bomb");
}  
public LoadUtils()
{
	}
public BombPlant()  
{  
	new sites_ent[MAX_BS]  
	new Float:sites_origin[MAX_BS][3]  
	new Float:c4_origin[3]  
	new sites = find_bs(sites_ent, sites_origin)  
	new c4 = find_c4(c4_origin)  
	
	if(!sites || !c4)  
		return  
	
	//new planted_site = sites_ent[0]  
	new Float: planted_origin[3]  
	planted_origin[0] = sites_origin[0][0]  
	planted_origin[1] = sites_origin[0][1]  
	planted_origin[2] = sites_origin[0][2]  
	new site = 0  
	for(new i = 1; i < sites; i++)  
	{  
		if(get_distance_f(c4_origin, planted_origin) > get_distance_f(c4_origin, sites_origin[i]))  
		{  
			planted_origin[0] = sites_origin[i][0]  
			planted_origin[1] = sites_origin[i][1]  
			planted_origin[2] = sites_origin[i][2]  
			//planted_site = sites_ent[i]  
			site = i  
		}  
	}  
	new mostmap[33]
	get_mapname(mostmap, charsmax(mostmap))
	if(equal("hb_dust2_2006", mostmap) || equal("hb_dust2_remake", mostmap)|| equal("hbcss_dust2", mostmap))
	{
		if(site == 0)
			site = 1
		else if(site == 1)
			site = 0;
	}
	
	sk_chat(0, "A bomba plantolva a(z) ^3[ ^4%s^3 ]^1-on.", site_name[site])
}  

stock find_bs(bs_ent[MAX_BS], Float:bs_origin[MAX_BS][3])  
{  
	new bs_found = 0  
	bs_ent[0] = -1  
	for(new i = 0; i < MAX_BS; i++)  
	{  
		bs_ent[i] = engfunc(EngFunc_FindEntityByString, bs_ent[i], "classname", "func_bomb_target")  
		if(i < MAX_BS - 1)  
			bs_ent[i+1] = bs_ent[i]  
		bs_found++  
		get_brush_entity_origin(bs_ent[i], bs_origin[i])  
	}  
	return bs_found  
}  

stock find_c4(Float:origin[3])  
{  
	new ent = -1  
	while((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", "grenade")) && (!(get_pdata_int(ent, 96) & (1<<8)))) { }  
	if(ent)  
	{  
		pev(ent, pev_origin, origin)  
		return 1  
	}  
	return 0  
}
stock print_color(const id, const input[], any:...) {
	new count = 1, players[32]
	static msg[191]
	vformat(msg, 190, input, 3)
	
	replace_all(msg, 190, "!g", "^4")
	replace_all(msg, 190, "!y", "^1")
	replace_all(msg, 190, "!t", "^3")    
	
	if (id) players[0] = id; else get_players(players, count, "ch")
	{
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
	return PLUGIN_HANDLED
} 
