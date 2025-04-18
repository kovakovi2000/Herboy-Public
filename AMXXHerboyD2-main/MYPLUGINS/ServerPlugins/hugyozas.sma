#include <amxmodx> 
#if !defined NO_CS_CZ
#include <fun>
#endif
#include <engine>

#define AUTHOR "KRoTaL"
 
 
new piss_model
new piss_sprite
new water_splash
new count_piss[33]
new count_puddle[33]
new bool:PissFlag[33]
new bool:aim[33]
new Float:aim_origin[33][3]
#if !defined NO_CS_CZ
new player_origins[33][3]
new mod_name[32]
#endif
 
public piss_on_player(id) 
{
 
if (get_cvar_num("amx_maxpees")==0) 
	return PLUGIN_HANDLED 
if (!is_user_alive(id)) 
	return PLUGIN_HANDLED 
if(PissFlag[id])
	return PLUGIN_HANDLED
 
#if !defined NO_CS_CZ
new player_origin[3], players[32], inum=0, dist, last_dist=99999, last_id 
 
get_user_origin(id,player_origin,0) 
get_players(players,inum,"b") 
if (inum>0) { 
	for (new i=0;i<inum;i++) { 
		if (players[i]!=id) { 
			dist = get_distance(player_origin,player_origins[players[i]]) 
			if (dist<last_dist) { 
				last_id = players[i] 
				last_dist = dist 
			} 
		} 
	} 
	if (last_dist<80) { 
#endif
		if (count_piss[id] > get_cvar_num("amx_maxpees")) { 
			client_print_color(id,print_chat,"^4[AVATÁR] ^3» ^3Körönként ^1csak ^4%d ^3alkalommal tudsz hugyozni!", get_cvar_num("amx_maxpees"), (get_cvar_num("amx_maxpees")>1) ? "s" : "") 
			return PLUGIN_CONTINUE 
		}
		new player_name[32] 
		get_user_name(id, player_name, 31)
		#if !defined NO_CS_CZ
		new dead_name[32]
		get_user_name(last_id, dead_name, 31)
		client_print_color(0,print_chat,"^4[AVATÁR] ^3» ^4%s ^3lehugyozta ^4%s ^3hulláját! ^3HÁHÁHÁ!", player_name, dead_name)
		#else
		client_print(0,print_chat,"^4%s ^3hugyozik!", player_name)
		#endif
		count_piss[id]+=1
		count_puddle[id]=1
		new ids[1]
		ids[0]=id
		PissFlag[id]=true
		aim[id]=false
		#if !defined NO_CS_CZ
		if( (equali(mod_name,"cstrike")) || (equali(mod_name,"czero")) )
		{
			client_cmd(id, "weapon_knife")
			set_user_maxspeed(id, -1.0)
		}
		#endif
		emit_sound(id,CHAN_VOICE,"piss/pissing.wav", 1.0, ATTN_NORM, 0, PITCH_NORM) 
		switch(get_cvar_num("amx_piss_effect"))
		{
			case 0:  set_task(0.2,"make_pee",1481+id,ids,1,"a",48)
			case 1:  set_task(0.1,"make_pee",1481+id,ids,1,"a",102)
			default: set_task(0.2,"make_pee",1481+id,ids,1,"a",48)
		}
		set_task(2.2,"place_puddle",3424+id,ids,1,"a",4)
		#if !defined NO_CS_CZ
		set_task(12.0,"weapons_back",6794+id,ids,1)
	}
	else
	{
		client_print_color(id,print_chat,"^4[AVATÁR] ^3» ^3Nincs hulla a közeledben.")
		return PLUGIN_HANDLED
	}
}
#endif
return PLUGIN_HANDLED
}
 
public sqrt(num) 
{ 
	new div = num 
	new result = 1 
	while (div > result) { 
		div = (div + result) / 2 
		result = num / div 
	} 
	return div 
} 
 
public make_pee(ids[]) 
{ 
	new id=ids[0]
	new vec[3] 
	new aimvec[3] 
	new velocityvec[3] 
	new length 
	get_user_origin(id,vec) 
	get_user_origin(id,aimvec,3) 
	new distance = get_distance(vec,aimvec) 
	new speed = floatround(distance*1.9)
 
	velocityvec[0]=aimvec[0]-vec[0] 
	velocityvec[1]=aimvec[1]-vec[1] 
	velocityvec[2]=aimvec[2]-vec[2] 
 
	length=sqrt(velocityvec[0]*velocityvec[0]+velocityvec[1]*velocityvec[1]+velocityvec[2]*velocityvec[2]) 
 
	velocityvec[0]=velocityvec[0]*speed/length 
	velocityvec[1]=velocityvec[1]*speed/length 
	velocityvec[2]=velocityvec[2]*speed/length 
 
	switch(get_cvar_num("amx_piss_effect"))
	{
		case 0:
		{
			message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
			write_byte(101)
			write_coord(vec[0])
			write_coord(vec[1])
			write_coord(vec[2])
			write_coord(velocityvec[0]) 
			write_coord(velocityvec[1]) 
			write_coord(velocityvec[2]) 
			write_byte(102) 
			write_byte(160) 
			message_end()
		}
		case 1:
		{
			message_begin(MSG_BROADCAST,SVC_TEMPENTITY) 
			write_byte(106) 
			write_coord(vec[0]) 
			write_coord(vec[1]) 
			write_coord(vec[2]) 
			write_coord(velocityvec[0]) 
			write_coord(velocityvec[1]) 
			write_coord(velocityvec[2]+100) 
			write_angle (0) 
			write_short (piss_model) 
			write_byte (0) 
			write_byte (255) 
			message_end()  
 
			message_begin(MSG_BROADCAST,SVC_TEMPENTITY) 
			write_byte (1)    
			write_short (id) 
			write_coord(aimvec[0]) 
			write_coord(aimvec[1]) 
			write_coord(aimvec[2]) 
			write_short(piss_sprite) 
			write_byte( 1 ) 
			write_byte( 6 ) 
			write_byte( 1 ) 
			write_byte( 8 ) 
			write_byte( 0 ) 
			write_byte( 255 ) 
			write_byte( 255 ) 
			write_byte( 0 ) 
			write_byte( 200 ) 
			write_byte( 10 )  
			message_end()
 
			message_begin( MSG_BROADCAST,SVC_TEMPENTITY)
			write_byte(17)
			write_coord(aimvec[0]) 
			write_coord(aimvec[1]) 
			write_coord(aimvec[2]) 
			write_short(water_splash)
			write_byte(16)
			write_byte(18)
			message_end()
 
		}
		default:
		{
			message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
			write_byte(101)
			write_coord(vec[0])
			write_coord(vec[1])
			write_coord(vec[2])
			write_coord(velocityvec[0]) 
			write_coord(velocityvec[1]) 
			write_coord(velocityvec[2]) 
			write_byte(102) 
			write_byte(160) 
			message_end()
		}
	}
} 
 
public place_puddle(ids[]) 
{
	new id=ids[0]
	if(!aim[id])
	{
		new origin[3]
		get_user_origin(id,origin,3) 
		aim_origin[id][0]=float(origin[0])
		aim_origin[id][1]=float(origin[1])
		aim_origin[id][2]=float(origin[2])
	}
 
	new puddle_entity
	puddle_entity = create_entity("info_target")
 
	if(puddle_entity == 0) {
		return PLUGIN_HANDLED_MAIN
	}
 
	new Float:MinBox[3]
	new Float:MaxBox[3]
 
	MinBox[0] = -1.0
	MinBox[1] = -1.0
	MinBox[2] = -1.0
	MaxBox[0] = 1.0
	MaxBox[1] = 1.0
	MaxBox[2] = 1.0
 
	entity_set_vector(puddle_entity, EV_VEC_mins, MinBox)
	entity_set_vector(puddle_entity, EV_VEC_maxs, MaxBox)
 
	switch(count_puddle[id])
	{
		case 1:
		{          
			entity_set_string(puddle_entity, EV_SZ_classname, "piss_puddle1")
			entity_set_model(puddle_entity, "models/piss/piss_puddle1.mdl")
		}
		case 2:
		{          
			entity_set_string(puddle_entity, EV_SZ_classname, "piss_puddle2")
			entity_set_model(puddle_entity, "models/piss/piss_puddle2.mdl")
		}
		case 3:
		{          
			entity_set_string(puddle_entity, EV_SZ_classname, "piss_puddle3")
			entity_set_model(puddle_entity, "models/piss/piss_puddle3.mdl")
		}
		case 4:
		{          
			entity_set_string(puddle_entity, EV_SZ_classname, "piss_puddle4")
			entity_set_model(puddle_entity, "models/piss/piss_puddle4.mdl")
		}
		case 5:
		{          
			entity_set_string(puddle_entity, EV_SZ_classname, "piss_puddle5")
			entity_set_model(puddle_entity, "models/piss/piss_puddle5.mdl")
			#if defined NO_CS_CZ
   			PissFlag[id]=false
			#endif
		}
		default: {}
	}
 
	entity_set_origin(puddle_entity, aim_origin[id])
	entity_set_int(puddle_entity, EV_INT_solid, 3)   
	entity_set_int(puddle_entity, EV_INT_movetype, 6) 
	entity_set_edict(puddle_entity, EV_ENT_owner, id)
 
	count_puddle[id]+=1
	aim[id]=true 
 
   	return PLUGIN_CONTINUE
}
 
public death_event() 
{ 
   	new victim = read_data(2)
 	#if !defined NO_CS_CZ  	
	get_user_origin(victim,player_origins[victim],0) 
	#endif
 
	if(PissFlag[victim]) 
		reset_piss(victim)
 
   	return PLUGIN_CONTINUE 
}
 
#if !defined NO_CS_CZ
public weapons_back(ids[]) 
{ 
   	PissFlag[ids[0]]=false 
	if( (equali(mod_name,"cstrike")) || (equali(mod_name,"czero")) )
	{
		set_user_maxspeed(ids[0], 250.0)
	}
}
 
public cur_weapon(id) 
{ 
	if(PissFlag[id]) 
	{ 
		if( (equali(mod_name,"cstrike")) || (equali(mod_name,"czero")) )
		{
			client_cmd(id, "weapon_knife")
			set_user_maxspeed(id, -1.0)
		}
	}
 
	return PLUGIN_CONTINUE
} 
#endif
 
public reset_piss(id) 
{
	if(task_exists(1481+id))
		remove_task(1481+id)
	if(task_exists(3424+id))
		remove_task(3424+id)
	#if !defined NO_CS_CZ
	if(task_exists(6794+id))
		remove_task(6794+id)
	#endif
	emit_sound(id,CHAN_VOICE,"piss/pissing.wav", 0.0, ATTN_NORM, 0, PITCH_NORM) 
	PissFlag[id]=false
 
	return PLUGIN_CONTINUE 
}
 
public reset_hud(id)
{
	if(task_exists(1481+id))
		remove_task(1481+id)
	if(task_exists(3424+id))
		remove_task(3424+id)
	#if !defined NO_CS_CZ
	if(task_exists(6794+id))
		remove_task(6794+id)
	#endif
	emit_sound(id,CHAN_VOICE,"piss/pissing.wav", 0.0, ATTN_NORM, 0, PITCH_NORM) 
	PissFlag[id]=false
 
	new iCurrent
 
	for (new i=1 ; i<count_piss[id] ; i++)
	{                
		iCurrent = find_ent_by_class(-1, "piss_puddle1")
		if(iCurrent != -1)
			remove_entity(iCurrent)
		iCurrent = find_ent_by_class(-1, "piss_puddle2")
		if(iCurrent != -1)
			remove_entity(iCurrent)
		iCurrent = find_ent_by_class(-1, "piss_puddle3")
		if(iCurrent != -1)
			remove_entity(iCurrent)
		iCurrent = find_ent_by_class(-1, "piss_puddle4")
		if(iCurrent != -1)
			remove_entity(iCurrent)
		iCurrent = find_ent_by_class(-1, "piss_puddle5")
		if(iCurrent != -1)
			remove_entity(iCurrent)
      }
	count_piss[id]=1
 
	return PLUGIN_CONTINUE 
} 


public hugy_help(id) 
{
	client_print_color(id, print_chat, "^4[AVATAR]] ^3» ^1Valakit ^3leakarsz hugyozni? ^4Használd a betűt^3 amire bindelted!")
	client_print_color(id, print_chat, "^4[AVATAR]] ^3» ^1Ha ^3hugyozni ^1akarsz, ^3írd be konzolba: ^4bind ^"x^" ^"piss^"")
	client_print_color(id, print_chat, "^4[AVATAR]] ^3» ^1Ha ez kész akkor az ^4x-el ^3tudsz hugyozni.")
 
	return PLUGIN_CONTINUE
}
 
public handle_say(id) 
{
	new said[192]
	read_args(said,192)
	remove_quotes(said)
 
	if( (containi(said, "hugyozas") != -1) && !(containi(said, "hugyozas") != -1) ) {
		client_print_color(id, print_chat, "^4[AVATAR]] ^3» ^1Írd be ^3konzolba a további infókért: ^4hugyhelp")
	}
 
	return PLUGIN_CONTINUE
}
 
public plugin_precache() 
{ 
	if (file_exists("sound/piss/pissing.wav"))
		precache_sound( "piss/pissing.wav")   
	if (file_exists("models/piss/piss_puddle1.mdl"))  	
		precache_model("models/piss/piss_puddle1.mdl")  
	if (file_exists("models/piss/piss_puddle2.mdl"))  	
		precache_model("models/piss/piss_puddle2.mdl") 
	if (file_exists("models/piss/piss_puddle3.mdl"))  	
		precache_model("models/piss/piss_puddle3.mdl") 
	if (file_exists("models/piss/piss_puddle4.mdl"))  	
		precache_model("models/piss/piss_puddle4.mdl") 
	if (file_exists("models/piss/piss_puddle5.mdl"))  	
		precache_model("models/piss/piss_puddle5.mdl") 
	if (file_exists("models/piss/piss.mdl"))  	
		piss_model = precache_model("models/piss/piss.mdl")  
	piss_sprite = precache_model("sprites/plasma.spr")
	water_splash = precache_model("sprites/wsplash3.spr")
 
   	return PLUGIN_CONTINUE 
}
 
public client_connect(id)
{
	PissFlag[id]=false
	count_piss[id]=1
 
	return PLUGIN_CONTINUE
}
 
public client_disconnect(id)
{
	reset_hud(id)
 
	return PLUGIN_CONTINUE
}
 
public plugin_init() 
{ 
	register_plugin("AMXX Piss","2.1","edited by Ek1`") 
	register_clcmd("piss","piss_on_player",1,"- Pisilj a halott testere") 
	register_clcmd("hugyhelp","hugy_help",1,"- Hogyan pisilj | segitseg") 
	register_clcmd("say","handle_say")
	register_cvar("amx_maxpees","6")
	register_cvar("amx_piss_admin","0")
	register_cvar("amx_piss_effect","2")
	register_event("DeathMsg","death_event","a") 
	register_event("ResetHUD", "reset_hud", "be")
	#if !defined NO_CS_CZ
	register_event("CurWeapon","cur_weapon","be","1=1")
	get_modname(mod_name,31)
	#endif
 
	return PLUGIN_CONTINUE
}
