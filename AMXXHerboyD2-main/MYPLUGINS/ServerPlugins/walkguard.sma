#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <xs>

#define PLUGIN "WalkGuard"
#define VERSION "1.3.2"
#define AUTHOR "mogel"


enum ZONEMODE {
	ZM_NOTHING,
	ZM_CAMPING,
	ZM_CAMPING_T1,	// Terrorista
	ZM_CAMPING_T2,	// Terror elharito
	ZM_BLOCK_ALL,
	ZM_KILL,
	ZM_KILL_T1,
	ZM_KILL_T2
}

new zonemode[ZONEMODE][] = { "ZONE_MODE_NONE", "ZONE_MODE_CAMPER", "ZONE_MODE_CAMPER_T1", "ZONE_MODE_CAMPER_T2", "ZONE_MODE_BLOCKING",  "ZONE_MODE_CHEATER",  "ZONE_MODE_CHEATER_T1",  "ZONE_MODE_CHEATER_T2" }
new zonename[ZONEMODE][] = { "wgz_none", "wgz_camper", "wgz_camper_t1", "wgz_camper_t2", "wgz_block_all", "wgz_kill", "wgz_kill_t1", "wgz_kill_t2" }
new solidtyp[ZONEMODE] = { SOLID_NOT, SOLID_TRIGGER, SOLID_TRIGGER, SOLID_TRIGGER, SOLID_BBOX, SOLID_TRIGGER, SOLID_TRIGGER, SOLID_TRIGGER }
new zonecolor[ZONEMODE][3] = {
	{ 255, 0, 255 },		
	{ 0, 255, 0 },		
	{ 0, 255, 128 },		
	{ 128, 255, 0 },		
	{ 255, 255, 255 },	
	{ 255, 0, 0 },	
	{ 255, 0, 128 },	
	{ 255, 128, 0 }	
}

#define ZONEID pev_iuser1
#define CAMPERTIME pev_iuser2

new zone_color_aktiv[3] = { 0, 0, 255 }
new zone_color_red[3] = { 255, 0, 0 }
new zone_color_green[3] = { 255, 255, 0 }


#define MAXZONES 100
new zone[MAXZONES]
new maxzones		
new index		


new setupunits = 10	
new direction = 0	
new koordinaten[3][] = { "TRANSLATE_X_KOORD", "TRANSLATE_Y_KOORD", "TRANSLATE_Z_KOORD" }

new spr_dot		

new editor = 0	

new camperzone[33]
new Float:campertime[33]
new Float:camping[33]

#define TASK_BASIS_CAMPER 2000
#define TASK_BASIS_SHOWZONES 1000

new pcv_damage
new pcv_botdamage
new pcv_immunity
new pcv_direction
new pcv_botdirection
new pcv_damageicon


new slap_direction
new slap_botdirection
new slap_damage
new slap_botdamage
new admin_immunity
new icon_damage	

enum ROUNDSTATUS {
	RS_UNDEFINED,
	RS_RUNNING,
	RS_FREEZETIME,
	RS_END,
}

new ROUNDSTATUS:roundstatus = RS_UNDEFINED

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)

	register_cvar("WalkGuard", VERSION, FCVAR_SERVER | FCVAR_SPONLY | FCVAR_UNLOGGED)
	server_cmd("WalkGuard %s", VERSION)

	pcv_damage = register_cvar("wg_damage", "10")
	pcv_botdamage = register_cvar("wg_botdamage", "0")
	pcv_immunity = register_cvar("wg_immunity", "0")
	pcv_direction = register_cvar("wg_direction", "1")
	pcv_botdirection = register_cvar("wg_botdirection", "1")
	pcv_damageicon = register_cvar("wg_damageicon", "262144")

	register_menu("MainMenu", -1, "MainMenuAction", 0)
	register_menu("EditMenu", -1, "EditMenuAction", 0)
	register_menu("KillMenu", -1, "KillMenuAction", 0)


	register_clcmd("walkguardmenu", "InitWalkGuard", ADMIN_RCON, " - Megnyitja a walkguard menüt")

	register_dictionary("walkguard.txt")

	register_event("HLTV", "Event_FreezeTime", "a", "1=0", "2=0")
	register_logevent("Event_RoundStart", 2, "1=Round_Start")
	register_logevent("Event_RoundEnd", 2, "1=Round_End")

	register_forward(FM_Touch, "fw_touch")

	set_task(1.0, "LoadWGZ")
}

public plugin_precache() {
	precache_model("models/gib_skull.mdl")
	spr_dot = precache_model("sprites/dot.spr")
}

public client_disconnect(player) {
	if (player == editor) HideAllZones()
}

public Event_FreezeTime() {
	roundstatus = RS_FREEZETIME
}

public Event_RoundStart() {
	roundstatus = RS_RUNNING
	
	slap_damage = get_pcvar_num(pcv_damage)
	slap_direction = get_pcvar_num(pcv_direction)
	slap_botdamage = get_pcvar_num(pcv_botdamage)
	slap_botdirection = get_pcvar_num(pcv_botdirection)
	admin_immunity = get_pcvar_num(pcv_immunity)
	icon_damage = get_pcvar_num(pcv_damageicon)
}

public Event_RoundEnd() {
	roundstatus = RS_END
}
public fw_touch(zone, player) {
	if (editor) return FMRES_IGNORED

	if (!pev_valid(zone) || !is_user_connected(player))
		return FMRES_IGNORED

	static classname[33]
	pev(player, pev_classname, classname, 32)
	if (!equal(classname, "player")) 
		return FMRES_IGNORED
	
	pev(zone, pev_classname, classname, 32)
	if (!equal(classname, "walkguardzone")) 
		return FMRES_IGNORED
	
	if (roundstatus == RS_RUNNING) 
		ZoneTouch(player, zone)
	
	return FMRES_IGNORED
}

public ZoneTouch(player, zone) {

	new zm = pev(zone, ZONEID)
	new userteam = get_user_team(player)

	if (admin_immunity && (get_user_flags(player) & ADMIN_IMMUNITY)) return
	
	if ( (ZONEMODE:zm == ZM_KILL) || ((ZONEMODE:zm == ZM_KILL_T1) && (userteam == 1)) || ((ZONEMODE:zm == ZM_KILL_T2) && (userteam == 2)) ) 
		set_task(0.1, "ZoneModeKill", player)
	

	if ( (ZONEMODE:zm == ZM_CAMPING) || ((ZONEMODE:zm == ZM_CAMPING_T1) && (userteam == 1)) || ((ZONEMODE:zm == ZM_CAMPING_T2) && (userteam == 2)) ) {
		if (!camping[player]) {
			client_print(player, print_center, "%L", player, "WALKGUARD_CAMPING_INIT")
			camperzone[player] = zone
			campertime[player] = get_gametime()
			camping[player] = get_gametime()
			set_task(0.5, "ZoneModeCamper", TASK_BASIS_CAMPER + player, _, _, "b")
		} else {

			camping[player] = get_gametime()
		}
	}
}

public ZoneModeKill(player) {
	if (!is_user_connected(player) || !is_user_alive(player)) return
	user_silentkill(player)
	for(new i = 0; i < 5; i++) client_print(player, print_chat, "[WalkGuard] %L", player, "WALKGUARD_KILL_MESSAGE")
	client_cmd(player,"speak ambience/thunder_clap.wav")
}

public ZoneModeCamper(player) {
	player -= TASK_BASIS_CAMPER

	if (!is_user_connected(player))
	{
		remove_task(TASK_BASIS_CAMPER + player)
		return
	}
	
	new Float:gametime = get_gametime();
	if ((gametime - camping[player]) > 0.5)
	{
		campertime[player] = 0.0
		camping[player] = 0.0
		remove_task(TASK_BASIS_CAMPER + player)
		return
	}

	new ct = pev(camperzone[player], CAMPERTIME)
	new left = ct - floatround( gametime - campertime[player]) 
	if (left < 1)
	{
		client_print(player, print_center, "%L", player, "WALKGUARD_CAMPING_DAMG")
		if (is_user_bot(player))
		{
			if (slap_botdirection) RandomDirection(player)
			fm_fakedamage(player, "camping", float(slap_botdamage), 0)
		} else
		{
			if (slap_direction) RandomDirection(player)
			fm_fakedamage(player, "camping", float(slap_damage), icon_damage)
		}
	} else
	{
		client_print(player, print_center, "%L", player, "WALKGUARD_CAMPING_TIME", left)
	}
}

public RandomDirection(player) {
	new Float:velocity[3]
	velocity[0] = random_float(-256.0, 256.0)
	velocity[1] = random_float(-256.0, 256.0)
	velocity[2] = random_float(-256.0, 256.0)
	set_pev(player, pev_velocity, velocity)
}

public CreateZone(Float:position[3], Float:mins[3], Float:maxs[3], zm, campertime) {
	new entity = fm_create_entity("info_target")
	set_pev(entity, pev_classname, "walkguardzone")
	fm_entity_set_model(entity, "models/gib_skull.mdl")
	fm_entity_set_origin(entity, position)

	set_pev(entity, pev_movetype, MOVETYPE_FLY)
	new id = pev(entity, ZONEID)
	if (editor)
	{
		set_pev(entity, pev_solid, SOLID_NOT)
	} else
	{
		set_pev(entity, pev_solid, solidtyp[ZONEMODE:id])
	}
	
	fm_entity_set_size(entity, mins, maxs)
	
	fm_set_entity_visibility(entity, 0)
	
	set_pev(entity, ZONEID, zm)
	set_pev(entity, CAMPERTIME, campertime)

	
	return entity
}

public CreateNewZone(Float:position[3]) {
	new Float:mins[3] = { -32.0, -32.0, -32.0 }
	new Float:maxs[3] = { 32.0, 32.0, 32.0 }
	return CreateZone(position, mins, maxs, 0, 10);
}

public CreateZoneOnPlayer(player) {
	new Float:position[3]
	pev(player, pev_origin, position)
	
	new entity = CreateNewZone(position)
	FindAllZones()
	
	for(new i = 0; i < maxzones; i++) if (zone[i] == entity) index = i;
}

public SaveWGZ(player) {
	new zonefile[200]
	new mapname[50]

	get_configsdir(zonefile, 199)
	format(zonefile, 199, "%s/walkguard", zonefile)
	if (!dir_exists(zonefile)) mkdir(zonefile)

	get_mapname(mapname, 49)
	format(zonefile, 199, "%s/%s.wgz", zonefile, mapname)
	delete_file(zonefile)
	
	FindAllZones()
	
	write_file(zonefile, "; V1 - WalkGuard Zone-File")
	write_file(zonefile, "; <zonename> <position (x/y/z)> <mins (x/y/z)> <maxs (x/y/z)> [<parameter>] ")
	write_file(zonefile, ";")
	write_file(zonefile, ";")
	write_file(zonefile, "; parameter")
	write_file(zonefile, ";")
	write_file(zonefile, ";   - wgz_camper    <time>")
	write_file(zonefile, ";   - wgz_camper_t1 <time>")
	write_file(zonefile, ";   - wgz_camper_t2 <time>")
	write_file(zonefile, ";   - wgz_camper_t3 <time>")
	write_file(zonefile, ";   - wgz_camper_t4 <time>")
	write_file(zonefile, ";")
	write_file(zonefile, "")
	
	for(new i = 0; i < maxzones; i++)
	{
		new z = zone[i]
		
		new zm = pev(z, ZONEID)
		
		new Float:pos[3]
		pev(z, pev_origin, pos)
		
		new Float:mins[3], Float:maxs[3]
		pev(z, pev_mins, mins)
		pev(z, pev_maxs, maxs)
		
		new output[1000]
		format(output, 999, "%s", zonename[ZONEMODE:zm])
		format(output, 999, "%s %.1f %.1f %.1f", output, pos[0], pos[1], pos[2])
		format(output, 999, "%s %.0f %.0f %.0f", output, mins[0], mins[1], mins[2])
		format(output, 999, "%s %.0f %.0f %.0f", output, maxs[0], maxs[1], maxs[2])
		
		if ((ZONEMODE:zm == ZM_CAMPING) || (ZONEMODE:zm == ZM_CAMPING_T1) || (ZONEMODE:zm == ZM_CAMPING_T2))
		{
			new ct = pev(z, CAMPERTIME)
			format(output, 999, "%s %i", output, ct)
		}
		
		write_file(zonefile, output)
	}
	
	client_print(player, print_chat, "%L", player, "ZONE_FILE_SAVED", zonefile)
}

public LoadWGZ() {
	new zonefile[200]
	new mapname[50]


	get_configsdir(zonefile, 199)
	format(zonefile, 199, "%s/walkguard", zonefile)

	get_mapname(mapname, 49)
	format(zonefile, 199, "%s/%s.wgz", zonefile, mapname)
	
	if (!file_exists(zonefile))
	{
		log_amx("Nem letezik a zona fajl")
		return
	}
	

	new input[1000], line = 0, len
	
	while( (line = read_file(zonefile , line , input , 127 , len) ) != 0 ) 
	{
		if (!strlen(input)  || (input[0] == ';')) continue;

		new data[20], zm = 0, ct		
		new Float:mins[3], Float:maxs[3], Float:pos[3]	


		strbreak(input, data, 20, input, 999)
		zm = -1
		for(new i = 0; ZONEMODE:i < ZONEMODE; ZONEMODE:i++)
		{
			if (equal(data, "wgz_camper_te")) format(data, 19, "wgz_camper_t1")
			if (equal(data, "wgz_camper_ct")) format(data, 19, "wgz_camper_t2")
			if (equal(data, zonename[ZONEMODE:i])) zm = i;
		}
		
		if (zm == -1)
		{
			log_amx("Ismeretlen zona -> '%s'", data)
			continue;
		}
		strbreak(input, data, 20, input, 999);	pos[0] = str_to_float(data);
		strbreak(input, data, 20, input, 999);	pos[1] = str_to_float(data);
		strbreak(input, data, 20, input, 999);	pos[2] = str_to_float(data);
		
		strbreak(input, data, 20, input, 999);	mins[0] = str_to_float(data);
		strbreak(input, data, 20, input, 999);	mins[1] = str_to_float(data);
		strbreak(input, data, 20, input, 999);	mins[2] = str_to_float(data);
		strbreak(input, data, 20, input, 999);	maxs[0] = str_to_float(data);
		strbreak(input, data, 20, input, 999);	maxs[1] = str_to_float(data);
		strbreak(input, data, 20, input, 999);	maxs[2] = str_to_float(data);

		if ((ZONEMODE:zm == ZM_CAMPING) || (ZONEMODE:zm == ZM_CAMPING_T1) || (ZONEMODE:zm == ZM_CAMPING_T2))
		{
			
			strbreak(input, data, 20, input, 999)
			ct = str_to_num(data)
		}

	
		CreateZone(pos, mins, maxs, zm, ct);
	}
	
	FindAllZones()
	HideAllZones()
}

public FX_Box(Float:sizemin[3], Float:sizemax[3], color[3], life) {
	
	message_begin(MSG_ALL, SVC_TEMPENTITY);

	write_byte(31);
	
	write_coord( floatround( sizemin[0] ) ); 
	write_coord( floatround( sizemin[1] ) ); 
	write_coord( floatround( sizemin[2] ) ); 
	
	write_coord( floatround( sizemax[0] ) ); 
	write_coord( floatround( sizemax[1] ) );
	write_coord( floatround( sizemax[2] ) ); 

	write_short(life)	
	
	write_byte(color[0])	
	write_byte(color[1])
	write_byte(color[2])
	
	message_end(); 
}

public FX_Line(start[3], stop[3], color[3], brightness) {
	message_begin(MSG_ONE_UNRELIABLE, SVC_TEMPENTITY, _, editor) 
	
	write_byte( TE_BEAMPOINTS ) 
	
	write_coord(start[0]) 
	write_coord(start[1])
	write_coord(start[2])
	
	write_coord(stop[0])
	write_coord(stop[1])
	write_coord(stop[2])
	
	write_short( spr_dot )
	
	write_byte( 1 ) 
	write_byte( 1 ) 
	write_byte( 4 )
	write_byte( 5 )
	write_byte( 0 ) 	
	
	write_byte( color[0] )   
	write_byte( color[1] )    
	write_byte( color[2] )   
	
	write_byte( brightness ) 
	write_byte( 0 )  
	
	message_end() 
}

public DrawLine(Float:x1, Float:y1, Float:z1, Float:x2, Float:y2, Float:z2, color[3]) {
	new start[3]
	new stop[3]
	
	start[0] = floatround( x1 )
	start[1] = floatround( y1 )
	start[2] = floatround( z1 )
	
	stop[0] = floatround( x2 )
	stop[1] = floatround( y2 )
	stop[2] = floatround( z2 )

	FX_Line(start, stop, color, 200)
}

public ShowAllZones() {
	FindAllZones()
	
	for(new i = 0; i < maxzones; i++)
	{
		new z = zone[i]
		remove_task(TASK_BASIS_SHOWZONES + z)
		set_pev(z, pev_solid, SOLID_NOT)
		set_task(0.2, "ShowZoneBox", TASK_BASIS_SHOWZONES + z, _, _, "b")
	}
}

public ShowZoneBox(entity) {
	entity -= TASK_BASIS_SHOWZONES
	if ((!fm_is_valid_ent(entity)) || !editor) return

	new Float:pos[3]
	pev(entity, pev_origin, pos)
	if (!fm_is_in_viewcone(editor, pos) && (entity != zone[index])) return		


	new Float:editorpos[3]
	pev(editor, pev_origin, editorpos)
	new Float:hitpoint[3]	
	fm_trace_line(-1, editorpos, pos, hitpoint)

	if (entity == zone[index]) DrawLine(editorpos[0], editorpos[1], editorpos[2] - 16.0, pos[0], pos[1], pos[2], { 255, 0, 0} )

	new Float:dh = vector_distance(editorpos, pos) - vector_distance(editorpos, hitpoint)
	if ( (floatabs(dh) > 128.0) && (entity != zone[index])) return			

	new Float:mins[3], Float:maxs[3]
	pev(entity, pev_mins, mins)
	pev(entity, pev_maxs, maxs)

	mins[0] += pos[0]
	mins[1] += pos[1]
	mins[2] += pos[2]
	maxs[0] += pos[0]
	maxs[1] += pos[1]
	maxs[2] += pos[2]
	
	new id = pev(entity, ZONEID)
	
	new color[3]
	color[0] = (zone[index] == entity) ? zone_color_aktiv[0] : zonecolor[ZONEMODE:id][0]
	color[1] = (zone[index] == entity) ? zone_color_aktiv[1] : zonecolor[ZONEMODE:id][1]
	color[2] = (zone[index] == entity) ? zone_color_aktiv[2] : zonecolor[ZONEMODE:id][2]
	
	DrawLine(maxs[0], maxs[1], maxs[2], mins[0], maxs[1], maxs[2], color)
	DrawLine(maxs[0], maxs[1], maxs[2], maxs[0], mins[1], maxs[2], color)
	DrawLine(maxs[0], maxs[1], maxs[2], maxs[0], maxs[1], mins[2], color)

	DrawLine(mins[0], mins[1], mins[2], maxs[0], mins[1], mins[2], color)
	DrawLine(mins[0], mins[1], mins[2], mins[0], maxs[1], mins[2], color)
	DrawLine(mins[0], mins[1], mins[2], mins[0], mins[1], maxs[2], color)

	DrawLine(mins[0], maxs[1], maxs[2], mins[0], maxs[1], mins[2], color)
	DrawLine(mins[0], maxs[1], mins[2], maxs[0], maxs[1], mins[2], color)
	DrawLine(maxs[0], maxs[1], mins[2], maxs[0], mins[1], mins[2], color)
	DrawLine(maxs[0], mins[1], mins[2], maxs[0], mins[1], maxs[2], color)
	DrawLine(maxs[0], mins[1], maxs[2], mins[0], mins[1], maxs[2], color)
	DrawLine(mins[0], mins[1], maxs[2], mins[0], maxs[1], maxs[2], color)

	if (entity != zone[index]) return
	

	if (direction == 0)
	{
		DrawLine(maxs[0], maxs[1], maxs[2], maxs[0], mins[1], mins[2], zone_color_green)
		DrawLine(maxs[0], maxs[1], mins[2], maxs[0], mins[1], maxs[2], zone_color_green)
		
		DrawLine(mins[0], maxs[1], maxs[2], mins[0], mins[1], mins[2], zone_color_red)
		DrawLine(mins[0], maxs[1], mins[2], mins[0], mins[1], maxs[2], zone_color_red)
	}
	if (direction == 1)	
	{
		DrawLine(mins[0], mins[1], mins[2], maxs[0], mins[1], maxs[2], zone_color_red)
		DrawLine(maxs[0], mins[1], mins[2], mins[0], mins[1], maxs[2], zone_color_red)

		DrawLine(mins[0], maxs[1], mins[2], maxs[0], maxs[1], maxs[2], zone_color_green)
		DrawLine(maxs[0], maxs[1], mins[2], mins[0], maxs[1], maxs[2], zone_color_green)
	}	
	if (direction == 2)	
	{
		DrawLine(maxs[0], maxs[1], maxs[2], mins[0], mins[1], maxs[2], zone_color_green)
		DrawLine(maxs[0], mins[1], maxs[2], mins[0], maxs[1], maxs[2], zone_color_green)

		DrawLine(maxs[0], maxs[1], mins[2], mins[0], mins[1], mins[2], zone_color_red)
		DrawLine(maxs[0], mins[1], mins[2], mins[0], maxs[1], mins[2], zone_color_red)
	}
}

public HideAllZones() {
	editor = 0
	for(new i = 0; i < maxzones; i++)
	{
		new id = pev(zone[i], ZONEID)
		set_pev(zone[i], pev_solid, solidtyp[ZONEMODE:id])
		remove_task(TASK_BASIS_SHOWZONES + zone[i])
	}
}

public FindAllZones() {
	new entity = -1
	maxzones = 0
	while( (entity = fm_find_ent_by_class(entity, "walkguardzone")) )
	{
		zone[maxzones] = entity
		maxzones++
	}
}

public InitWalkGuard(player) {
	new name[33], steam[33]
	get_user_name(player, name, 32)
	get_user_authid(player, steam, 32)
	
	if (!(get_user_flags(player) & ADMIN_RCON))
	{
		log_amx("nincs joga: '%s' <%s>", name, steam)
		return PLUGIN_HANDLED
	}
	
	editor = player
	FindAllZones();
	ShowAllZones();
	
	set_task(0.1, "OpenWalkGuardMenu", player)

	return PLUGIN_HANDLED
}

public OpenWalkGuardMenu(player) {
	new trans[70]
	new menu[1024]
	new zm = -1
	new ct
	new menukeys = MENU_KEY_0 + MENU_KEY_4 + MENU_KEY_9
	
	if (fm_is_valid_ent(zone[index]))
	{
		zm = pev(zone[index], ZONEID)
		ct = pev(zone[index], CAMPERTIME)
	}
	
	format(menu, 1023, "\dWalkGuard-Menu - Verzio %s\w", VERSION)
	format(menu, 1023, "%s^n", menu)		
	format(menu, 1023, "%s^n", menu)		
	format(menu, 1023, "%L", player, "WGM_ZONE_FOUND", menu, maxzones)
	
	if (zm != -1)
	{
		format(trans, 69, "%L", player, zonemode[ZONEMODE:zm])
		if (ZONEMODE:zm == ZM_CAMPING)
		{
			format(menu, 1023, "%L", player, "WGM_ZONE_CURRENT_CAMP", menu, index + 1, trans, ct)
		} else
		{
			format(menu, 1023, "%L", player, "WGM_ZONE_CURRENT_NONE", menu, index + 1, trans)
		}

		menukeys += MENU_KEY_2 + MENU_KEY_3 + MENU_KEY_1
		format(menu, 1023, "%s^n", menu)	
		format(menu, 1023, "%s^n", menu)	
		format(menu, 1023, "%L", player, "WGM_ZONE_EDIT", menu)
		format(menu, 1023, "%L", player, "WGM_ZONE_CHANGE", menu)
	}
	
	format(menu, 1023, "%s^n", menu)	
	format(menu, 1023, "%L" ,player, "WGM_ZONE_CREATE", menu)
	
	if (zm != -1)
	{
		menukeys += MENU_KEY_6
		format(menu, 1023, "%L", player, "WGM_ZONE_DELETE", menu)
	}
	format(menu, 1023, "%L", player, "WGM_ZONE_SAVE", menu)
		
	format(menu, 1023, "%s^n", menu)		
	format(menu, 1023, "%L" ,player, "WGM_ZONE_EXIT", menu)
	
	show_menu(player, menukeys, menu, -1, "MainMenu")
	client_cmd(player, "spk sound/buttons/blip1.wav")
}

public MainMenuAction(player, key) {
	key = (key == 10) ? 0 : key + 1
	switch(key) 
	{
		case 1: {
				if (fm_is_valid_ent(zone[index])) OpenEditMenu(player); else OpenWalkGuardMenu(player);
			}
		case 2: {
				index = (index > 0) ? index - 1 : index;
				OpenWalkGuardMenu(player)
			}
		case 3: {
				index = (index < maxzones - 1) ? index + 1 : index;
				OpenWalkGuardMenu(player)
			}
		case 4:	{
			
				if (maxzones < MAXZONES - 1)
				{
					CreateZoneOnPlayer(player);
					ShowAllZones();
					MainMenuAction(player, 0);
				} else
				{
					client_print(player, print_chat, "%L", player, "ZONE_FULL")
					client_cmd(player, "spk sound/buttons/button10.wav")
					set_task(0.5, "OpenWalkGuardMenu", player)
				}
			}
		case 6: {
				OpenKillMenu(player);
			}
		case 9: {		
				SaveWGZ(player)
				OpenWalkGuardMenu(player)
			}
		case 10:{
				editor = 0
				HideAllZones()
			}
	}
}

public OpenEditMenu(player) {
	new trans[70]
	
	new menu[1024]
	new menukeys = MENU_KEY_0 + MENU_KEY_1 + MENU_KEY_4 + MENU_KEY_5 + MENU_KEY_6 + MENU_KEY_7 + MENU_KEY_8 + MENU_KEY_9
	
	format(menu, 1023, "\dWalkGuard-Zona szerkesztes\w")
	format(menu, 1023, "%s^n", menu)		
	format(menu, 1023, "%s^n", menu)		

	new zm = -1
	new ct
	if (fm_is_valid_ent(zone[index]))
	{
		zm = pev(zone[index], ZONEID)
		ct = pev(zone[index], CAMPERTIME)
	}
	
	if (zm != -1)
	{
		format(trans, 69, "%L", player, zonemode[ZONEMODE:zm])
		if ((ZONEMODE:zm == ZM_CAMPING) || (ZONEMODE:zm == ZM_CAMPING_T1) || (ZONEMODE:zm == ZM_CAMPING_T2))
		{
			format(menu, 1023, "%L", player, "WGE_ZONE_CURRENT_CAMP", menu, trans, ct)
			format(menu, 1023, "%L", player, "WGE_ZONE_CURRENT_CHANGE", menu)
			menukeys += MENU_KEY_2 + MENU_KEY_3
		} else
		{
			format(menu, 1023, "%L", player, "WGE_ZONE_CURRENT_NONE", menu, trans)
			format(menu, 1023, "%s^n", menu)	
		}
	}
	
	format(menu, 1023, "%s^n", menu)		
	
	format(trans, 49, "%L", player, koordinaten[direction])
	format(menu, 1023, "%L", player, "WGE_ZONE_SIZE_INIT", menu, trans)
	format(menu, 1023, "%L", player, "WGE_ZONE_SIZE_MINS", menu)
	format(menu, 1023, "%L", player, "WGE_ZONE_SIZE_MAXS", menu)
	format(menu, 1023, "%L", player, "WGE_ZONE_SIZE_STEP", menu, setupunits)
	format(menu, 1023, "%s^n", menu)		
	format(menu, 1023, "%s^n", menu)		
	format(menu, 1023, "%L", player, "WGE_ZONE_SIZE_QUIT", menu)
	
	show_menu(player, menukeys, menu, -1, "EditMenu")
	client_cmd(player, "spk sound/buttons/blip1.wav")
}

public EditMenuAction(player, key) {
	key = (key == 10) ? 0 : key + 1
	switch(key)
	{
		case 1: {
				new zm = -1
				zm = pev(zone[index], ZONEID)
				if (ZONEMODE:zm == ZM_KILL_T2) zm = 0; else zm++;
				set_pev(zone[index], ZONEID, zm)
				OpenEditMenu(player)
			}
		case 2: {
				new ct = pev(zone[index], CAMPERTIME)
				ct = (ct > 5) ? ct - 1 : 5
				set_pev(zone[index], CAMPERTIME, ct)
				OpenEditMenu(player)
			}
		case 3: {
				new ct = pev(zone[index], CAMPERTIME)
				ct = (ct < 30) ? ct + 1 : 30
				set_pev(zone[index], CAMPERTIME, ct)
				OpenEditMenu(player)
			}
		case 4: {
				direction = (direction < 2) ? direction + 1 : 0
				OpenEditMenu(player)
			}
		case 5: {
				ZuRotAddieren()
				OpenEditMenu(player)
			}
		case 6: {
				VonRotAbziehen()
				OpenEditMenu(player)
			}
		case 7: {
				VonGelbAbziehen()
				OpenEditMenu(player)
			}
		case 8: {
				ZuGelbAddieren()
				OpenEditMenu(player)
			}
		case 9: {
				setupunits = (setupunits < 100) ? setupunits * 10 : 1
				OpenEditMenu(player)
			}
		case 10:{
				OpenWalkGuardMenu(player)
			}
	}
}

public VonRotAbziehen() {
	new entity = zone[index]
	
	new Float:pos[3]
	pev(entity, pev_origin, pos)

	new Float:mins[3], Float:maxs[3]
	pev(entity, pev_mins, mins)
	pev(entity, pev_maxs, maxs)

	
	mins[direction] -= float(setupunits) / 2.0
	maxs[direction] += float(setupunits) / 2.0
	pos[direction] -= float(setupunits) / 2.0
	
	set_pev(entity, pev_origin, pos)
	fm_entity_set_size(entity, mins, maxs)
}

public ZuRotAddieren() {
	new entity = zone[index]
	
	new Float:pos[3]
	pev(entity, pev_origin, pos)

	new Float:mins[3], Float:maxs[3]
	pev(entity, pev_mins, mins)
	pev(entity, pev_maxs, maxs)

	if ((floatabs(mins[direction]) + maxs[direction]) < setupunits + 1) return

	mins[direction] += float(setupunits) / 2.0
	maxs[direction] -= float(setupunits) / 2.0
	pos[direction] += float(setupunits) / 2.0
	
	set_pev(entity, pev_origin, pos)
	fm_entity_set_size(entity, mins, maxs)
}

public VonGelbAbziehen() {
	new entity = zone[index]
	
	new Float:pos[3]
	pev(entity, pev_origin, pos)

	new Float:mins[3], Float:maxs[3]
	pev(entity, pev_mins, mins)
	pev(entity, pev_maxs, maxs)

	if ((floatabs(mins[direction]) + maxs[direction]) < setupunits + 1) return

	mins[direction] += float(setupunits) / 2.0
	maxs[direction] -= float(setupunits) / 2.0
	pos[direction] -= float(setupunits) / 2.0
	
	set_pev(entity, pev_origin, pos)
	fm_entity_set_size(entity, mins, maxs)
}

public ZuGelbAddieren() {
	new entity = zone[index]

	new Float:pos[3]
	pev(entity, pev_origin, pos)

	new Float:mins[3], Float:maxs[3]
	pev(entity, pev_mins, mins)
	pev(entity, pev_maxs, maxs)


	mins[direction] -= float(setupunits) / 2.0
	maxs[direction] += float(setupunits) / 2.0
	pos[direction] += float(setupunits) / 2.0
	
	set_pev(entity, pev_origin, pos)
	fm_entity_set_size(entity, mins, maxs)
}

public OpenKillMenu(player) {
	new menu[1024]
	
	format(menu, 1023, "%L", player, "ZONE_KILL_INIT")
	format(menu, 1023, "%L", player, "ZONE_KILL_ASK", menu)
	
	show_menu(player, MENU_KEY_1 + MENU_KEY_0, menu, -1, "KillMenu")
	
	client_cmd(player, "spk sound/buttons/button10.wav")
}

public KillMenuAction(player, key) {
	key = (key == 10) ? 0 : key + 1
	switch(key)
	{
		case 1: {
				client_print(player, print_chat, "[WalkGuard] %L", player, "ZONE_KILL_NO")
			}
		case 10:{
				fm_remove_entity(zone[index])
				index--;
				if (index < 0) index = 0;
				client_print(player, print_chat, "[WalkGuard] %L", player, "ZONE_KILL_YES")
				FindAllZones()
			}
	}
	OpenWalkGuardMenu(player)
}

stock fm_set_kvd(entity, const key[], const value[], const classname[] = "") {
	if (classname[0])
		set_kvd(0, KV_ClassName, classname)
	else {
		new class[32]
		pev(entity, pev_classname, class, sizeof class - 1)
		set_kvd(0, KV_ClassName, class)
	}

	set_kvd(0, KV_KeyName, key)
	set_kvd(0, KV_Value, value)
	set_kvd(0, KV_fHandled, 0)

	return dllfunc(DLLFunc_KeyValue, entity, 0)
}

stock fm_fake_touch(toucher, touched)
	return dllfunc(DLLFunc_Touch, toucher, touched)

stock fm_DispatchSpawn(entity)
	return dllfunc(DLLFunc_Spawn, entity)

stock fm_remove_entity(index)
	return engfunc(EngFunc_RemoveEntity, index)

stock fm_find_ent_by_class(index, const classname[])
	return engfunc(EngFunc_FindEntityByString, index, "classname", classname)

stock fm_is_valid_ent(index)
	return pev_valid(index)

stock fm_entity_set_size(index, const Float:mins[3], const Float:maxs[3])
	return engfunc(EngFunc_SetSize, index, mins, maxs)

stock fm_entity_set_model(index, const model[])
	return engfunc(EngFunc_SetModel, index, model)

stock fm_create_entity(const classname[])
	return engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, classname))

stock fm_fakedamage(victim, const classname[], Float:takedmgdamage, damagetype) {
	new class[] = "trigger_hurt"
	new entity = fm_create_entity(class)
	if (!entity)
		return 0

	new value[16]
	float_to_str(takedmgdamage * 2, value, sizeof value - 1)
	fm_set_kvd(entity, "dmg", value, class)

	num_to_str(damagetype, value, sizeof value - 1)
	fm_set_kvd(entity, "damagetype", value, class)

	fm_set_kvd(entity, "origin", "8192 8192 8192", class)
	fm_DispatchSpawn(entity)

	set_pev(entity, pev_classname, classname)
	fm_fake_touch(entity, victim)
	fm_remove_entity(entity)

	return 1
}

stock fm_entity_set_origin(index, const Float:origin[3]) {
	new Float:mins[3], Float:maxs[3]
	pev(index, pev_mins, mins)
	pev(index, pev_maxs, maxs)
	engfunc(EngFunc_SetSize, index, mins, maxs)

	return engfunc(EngFunc_SetOrigin, index, origin)
}

stock fm_set_entity_visibility(index, visible = 1) {
	set_pev(index, pev_effects, visible == 1 ? pev(index, pev_effects) & ~EF_NODRAW : pev(index, pev_effects) | EF_NODRAW)

	return 1
}

stock bool:fm_is_in_viewcone(index, const Float:point[3]) {
	new Float:angles[3]
	pev(index, pev_angles, angles)
	engfunc(EngFunc_MakeVectors, angles)
	global_get(glb_v_forward, angles)
	angles[2] = 0.0

	new Float:origin[3], Float:diff[3], Float:norm[3]
	pev(index, pev_origin, origin)
	xs_vec_sub(point, origin, diff)
	diff[2] = 0.0
	xs_vec_normalize(diff, norm)

	new Float:dot, Float:fov
	dot = xs_vec_dot(norm, angles)
	pev(index, pev_fov, fov)
	if (dot >= floatcos(fov * M_PI / 360))
		return true

	return false
}

stock fm_trace_line(ignoreent, const Float:start[3], const Float:end[3], Float:ret[3]) {
	engfunc(EngFunc_TraceLine, start, end, ignoreent == -1 ? 1 : 0, ignoreent, 0)

	new ent = get_tr2(0, TR_pHit)
	get_tr2(0, TR_vecEndPos, ret)

	return pev_valid(ent) ? ent : 0
}