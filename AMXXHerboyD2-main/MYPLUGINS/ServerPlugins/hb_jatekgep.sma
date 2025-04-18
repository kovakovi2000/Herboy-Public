#include <amxmodx>
#include <engine>
#include <fakemeta>

#define PLUGIN "Herboy Játékgép"
#define VERSION "0.1B"
#define AUTHOR "EXILLE"

#define NPCMDL "models/AVHBSKINS/jatekgep/npc.mdl"

new bool:hozzanyult[33]

public plugin_precache()
{
	precache_model(NPCMDL);
}

native hb_jatekgep(id);
native Szerencsemenu(id);

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	npc_betolt()
	register_touch("npc","player","npc_erint") 
}
public npc_erint(ent, id)
{
	if(hozzanyult[id])
		return PLUGIN_HANDLED
	client_print_color(id, print_chat, "^4[^1~^3|^4HerBoy^3|^1~^4] ^3» ^3Hozzáértél ^1a ^4Játékgép^1-hez!")
	hozzanyult[id] = true

	npc_menu(id)
	set_task(40.0, "npc_ujra", id)
	return PLUGIN_HANDLED
}
public npc_ujra(id)
	hozzanyult[id] = false
public npc_betolt()
{
	new Float:origin[3]
	
	new file[192], map[32]
	get_mapname(map, 31)
	formatex(file, charsmax(file), "addons/amxmodx/configs/jatekgep/%s.cfg", map)
	new elsopoz[8], masodikpoz[8], harmadikpoz[8]
	new lines = file_size(file, 1)
	if(lines > 0)
	{
		new buff[256], len
		read_file(file, random(lines), buff, charsmax(buff), len)	
		parse(buff, elsopoz, 7, masodikpoz, 7, harmadikpoz, 7)
			
		origin[0] = str_to_float(elsopoz)
		origin[1] = str_to_float(masodikpoz)
		origin[2] = str_to_float(harmadikpoz)
		new ent = create_entity("info_target")
		set_pev(ent, pev_classname, "npc")
		entity_set_model(ent, NPCMDL)
		set_pev(ent,pev_solid, SOLID_BBOX)
		set_pev(ent, pev_movetype, MOVETYPE_TOSS)
		engfunc(EngFunc_SetOrigin, ent, origin)
		engfunc(EngFunc_SetSize, ent, Float:{-10.0,-10.0,-49.0}, Float:{10.0,10.0,25.0})
		engfunc(EngFunc_DropToFloor, ent)
	}
	else
		log_amx("Nem talalhato a betoltendo fajl")
}
public client_putinserver(id)
	hozzanyult[id] = false
public npc_menu(id)
{
	new menu = menu_create("\r[\wHerBoy\r] \yOnly Dust 2 \r» [ \wJátékgép \r]", "npc_menuh" )
	
	menu_additem(menu,"\y|\d-\r-\y[ \wPörgetés\y ]\r-\d-\y|","1",0)
	menu_additem(menu, "\y|\d-\r-\y[ \wSzerencsejáték\y ]\r-\d-\y|", "2", 0);
	menu_additem(menu, "\y|\d-\r-\y[ \wTop10\y ]\r-\d-\y|", "3", 0);
//	menu_additem(menu, "\y|\d-\r-\y[ \wTéli Ajándék\y ]\r-\d-\y|", "4", 0);

	menu_setprop(menu, MPROP_EXITNAME, "\rKilépés")
//    menu_setprop(menu, MPROP_NEXTNAME, "\yKövetkező")
//    menu_setprop(menu, MPROP_BACKNAME, "\yVissza")

	menu_display(id, menu, 0)
}
public npc_menuh(id, menu, item) {
	if(item == MENU_EXIT)
	{
		menu_destroy(menu)
		return
	}
	
	new data[9], szName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
	new key = str_to_num(data);
	
	switch(key)
	{
		case 1 : {
			hb_jatekgep(id);
		}
		case 2 : {
			Szerencsemenu(id);
		}
		case 3 : {
			client_cmd(id, "say /top15");
		}
		case 4 : {
			client_cmd(id, "karacsonyiaji");
		}

	}
}

