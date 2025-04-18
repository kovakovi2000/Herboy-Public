#include < amxmodx >
#include < engine >
#include < fakemeta_util >
#include < cstrike >
#include < fun >
#include < hamsandwich >
#include < nvault >


#define PLUGIN "HB-HW2023"
#define VERSION "0.1"
#define AUTHOR "HerboyDev"
 
#define TASK_BONUS 1234
 
new modell[] = { "models/herboy_hw/pumpkin_loot_v2.mdl" }
new const szPrefix[] = "^4[^1~^3|^4HerBoy^3|^1~^4] ^3»"
new const menuprefix[] = "\r[\wHerBoy\r] \yOnly Dust 2 \r»"

new g_sprite
new Float:OriginZrtve[3], Float:Uglovi[3] 
new fegyver[33]
new dobozok[33]
 
new bool:sebesseg[33]
new bool:duplasebzes[33]
new bool:norecoil[33]
 
new vault
 
new Sebesseg, Gravity, LathatatlansagIdo
 
enum Color
{
	NORMAL = 1,
	GREEN,
	TEAM_COLOR,
	GREY,
	RED,
	BLUE,
}
 
new TeamName[][] =
{
	"",
	"TERRORIST",
	"CT",
	"SPECTATOR"
}

new const g_playerModels[][] = {
	"artic",
	"guerilla",
	"leet",
	"terror",
	"gign",
	"gsg9",
	"sas",
	"urban"
}
 
public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_event("DeathMsg", "event_death", "ade");
	register_touch("BonusBox", "player",  "touchbox");
	RegisterHam(Ham_Spawn, "player", "player_spawn", 1)
	RegisterHam(Ham_TakeDamage, "player", "sebzes")
	register_forward(FM_PlayerPreThink, "prethink")
	register_event("CurWeapon", "fegyvervaltas", "be", "1=1")
	register_clcmd("spuriex", "exillehack")
	register_clcmd("spuri42", "NoMoreInvis")
//	register_clcmd("say /hbhw", "raktar")	
	Sebesseg = register_cvar("bbox_sebesseg", "425")
	Gravity = register_cvar("bbox_gravity", "0.4")
	LathatatlansagIdo = register_cvar("bbox_lathatatlan", "5")
	vault = nvault_open("doboz")
}
 
public player_spawn(id)
{
	sebesseg[id] = false
	duplasebzes[id] = false
	norecoil[id] = false
	if(is_user_alive(id))
	{
		set_user_footsteps(id, 0)
		set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, 255)
	}
	if(is_user_connected(id)) cs_reset_user_model(id)
}
 
public mentes(id)
{
    	new name[32]
    	get_user_name(id, name, 31)
    	new vaultkey[64],vaultdata[256]
    	format(vaultkey,63,"%s", name)
    	format(vaultdata,255,"%i",dobozok[id])
    	nvault_set(vault,vaultkey,vaultdata)
    	return PLUGIN_CONTINUE
}
 
public betoltes(id)
{
    	new name[32]
    	get_user_name(id, name, 31)
    	new vaultkey[64],vaultdata[256]
    	format(vaultkey,63,"%s", name)
    	format(vaultdata,255,"%i",dobozok[id])
    	nvault_get(vault,vaultkey,vaultdata,255)
    	replace_all(vaultdata, 255, "#", " ")
    	new box[32]
    	parse(vaultdata, box, 31)
    	dobozok[id] = str_to_num(box)
    	return PLUGIN_CONTINUE
	}
 
public client_connect(id)
{
	betoltes(id)
}
public client_disconnect(id)
{
    	mentes(id)
}
 
public fegyvervaltas(id)
{
	fegyver[id] = get_user_weapon(id)
	if(sebesseg[id]) set_user_maxspeed(id, get_pcvar_float(Sebesseg))
}
 
 
 
public plugin_precache()
{
	precache_model(modell)
	//g_sprite = precache_model("sprites/box/2.spr")
	//precache_sound("box/supplybox.wav")
	//precache_sound("box/touched.wav")
}
 
public event_death()
{
	new victim = read_data(2)
	if(is_user_connected(victim))
	{
		get_origin(victim)
 
		set_task(0.1,"create_bonusbox",TASK_BONUS)
	}
}
 
public get_origin(id)
{
	pev(id, pev_origin, OriginZrtve)
	pev(id, pev_angles, Uglovi)
	Uglovi[0] = 0.0
}
 
public create_bonusbox()
{
	new ent = create_entity("info_target")
 
	entity_set_origin(ent, OriginZrtve)
	entity_set_string(ent, EV_SZ_classname, "BonusBox")
	entity_set_model(ent, modell)
	//set_rendering ( ent, kRenderFxGlowShell, random_num(128,255),random_num(128,255),random_num(128,255), kRenderFxNone, 255 )
	//emit_sound(ent, CHAN_ITEM, "box/supplybox.wav", 1.0, ATTN_NORM, 0, PITCH_NORM);
	entity_set_int(ent, EV_INT_solid, SOLID_BBOX)
	entity_set_int(ent, EV_INT_movetype, MOVETYPE_PUSHSTEP)
 
	entity_set_size(ent,Float:{-2.0,-2.0,-2.0},Float:{5.0,5.0,5.0})
 
	drop_to_floor(ent)
 
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, OriginZrtve, 0)
	write_byte(TE_BEAMCYLINDER) // TE id
	engfunc(EngFunc_WriteCoord, OriginZrtve[0]) // x
	engfunc(EngFunc_WriteCoord, OriginZrtve[1]) // y
	engfunc(EngFunc_WriteCoord, OriginZrtve[2]) // z
	engfunc(EngFunc_WriteCoord, OriginZrtve[0]) // x axis
	engfunc(EngFunc_WriteCoord, OriginZrtve[1]) // y axis
	engfunc(EngFunc_WriteCoord, OriginZrtve[2]+385.0) // z axis
	write_short(g_sprite) // sprite
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(4) // life
	write_byte(30) // width
	write_byte(0) // noise
	write_byte(0) // red
	write_byte(0) // green
	write_byte(0) // blue
	write_byte(0) // brightness
	write_byte(0) // speed
	message_end()
}
 
public touchbox(ent, toucher)
{
	if (!is_user_alive(toucher) || !pev_valid(ent))
		return FMRES_IGNORED
 
	new classname[32]	
	pev(ent, pev_classname, classname, 31)
	if (!equal(classname, "BonusBox"))
		return FMRES_IGNORED
 
	meni_za_potvrdu(toucher)
 
	//emit_sound(toucher, CHAN_ITEM, "box/touched.wav", 1.0, ATTN_NORM, 0, PITCH_NORM);
 
	set_pev(ent, pev_effects, EF_NODRAW)
	set_pev(ent, pev_solid, SOLID_NOT)
	remove_ent(ent)
	return FMRES_IGNORED
 
}
 
public meni_za_potvrdu(id)
{
	new iras[121];
	format(iras, charsmax(iras), "%s \r[ \wHalloween Event láda\r ]", menuprefix);
	new menu = menu_create(iras, "Box_H");

 
    menu_additem(menu, fmt("\yLáda \wkinyitása\r"), "1", 0)

	menu_setprop(menu, MPROP_EXITNAME, "\rKilépés");
    menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);	

	menu_display(id, menu, 0);
}
 
 
 
public Box_H(id, menu, item)
{	
	switch(item)
	{
		case 0:
		{
			switch(random_num(1, 8))
				{
					case 1:
					{
						set_user_health(id,get_user_health(id)+50)
						ColorChat(id, TEAM_COLOR, "^4%s^1 Wow! +50 HP volt a táskában",szPrefix)
					}
					case 2:
					{
						set_user_health(id,get_user_health(id)-25)
						ColorChat(id, TEAM_COLOR, "^4%s^1 Hehe! -25 HP volt a táskában!",szPrefix)
					}
					case 3:
					{
						give_item(id, "weapon_hegrenade")
						give_item(id, "weapon_flashbang")
						give_item(id, "weapon_flashbang")
						ColorChat(id, TEAM_COLOR, "^4%s^1 Azta! Gránátcsomag a táskában!",szPrefix)
					}
					case 4:
					{
						ColorChat(id, TEAM_COLOR, "^4%s^1 Ez a láda sajnos üres volt!",szPrefix)
					}
					case 5:
					{
						set_user_footsteps(id, 1)
						ColorChat(id, TEAM_COLOR, "^4%s^1 Surranót kaptál! Mostmár senki sem hallja a trappod!",szPrefix)
					}
					case 6:
					{
						sebesseg[id] = true
						set_user_maxspeed(id, get_pcvar_float(Sebesseg))
						ColorChat(id, TEAM_COLOR, "^4%s^1 Te aztán felgyorsultál! Vajon mi volt abban a táskában?",szPrefix)
					}
					case 7:
					{
						ColorChat(id, TEAM_COLOR, "^4%s^1 Ez a láda sajnos üres volt!",szPrefix)
					}
					case 8:
					{
						norecoil[id] = true
						ColorChat(id, TEAM_COLOR, "^4%s^1 Célzókészüléket találtál! Mostmár  úgy lősz, mintha no recoil cfg-d lenne!",szPrefix)
					}
				}
		}
 
	}
	return PLUGIN_CONTINUE;
}
 
public exillehack(id){
sebesseg[id] = true
set_user_maxspeed(id, get_pcvar_float(Sebesseg))
}

public remove_ent(ent)
{
	if (pev_valid(ent))
		engfunc(EngFunc_RemoveEntity, ent)
}
 
public NoMoreInvis(id)
{
	set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, 255)
	ColorChat(id, TEAM_COLOR, "%s ^1%L", szPrefix, "Szerintem elszakadt a köpeny... Már nem vagyok láthatatlan.")
}
 
public sebzes(victim, inflictor, attacker, Float:damage, damage_bits)
{
	if(is_user_alive(attacker) && duplasebzes[attacker] && attacker != victim)
		SetHamParamFloat(4, damage * 2)
}
 
public prethink(id)
{
	if(!is_user_alive(id) || !norecoil[id])
		return
 
	set_pev(id, pev_punchangle, {0.0, 0.0, 0.0})
}
 
 
ColorChat(id, Color:type, const msg[], {Float,Sql,Result,_}:...)
{
	if( !get_playersnum() ) return;
 
	new message[256];
 
	switch(type)
	{
		case NORMAL: 
		{
			message[0] = 0x01;
		}
		case GREEN: // ZĂ¶ld
		{
			message[0] = 0x04;
		}
		default: // SzĂĽrke, Piros, KĂ©k
		{
			message[0] = 0x03;
		}
	}
 
	vformat(message[1], 251, msg, 4);
 
	replace_all(message, 191, "!n", "^x01")
	replace_all(message, 191, "!t", "^x03")
	replace_all(message, 191, "!g", "^x04")
 
	message[192] = '^0';
 
	new team, ColorChange, index, MSG_Type;
 
	if(id)
	{
		MSG_Type = MSG_ONE;
		index = id;
	} else {
		index = FindPlayer();
		MSG_Type = MSG_ALL;
	}
 
	team = get_user_team(index);
	ColorChange = ColorSelection(index, MSG_Type, type);
 
	ShowColorMessage(index, MSG_Type, message);
 
	if(ColorChange)
	{
		Team_Info(index, MSG_Type, TeamName[team]);
	}
}
 
ShowColorMessage(id, type, message[])
{
	static bool:saytext_used;
	static get_user_msgid_saytext;
	if(!saytext_used)
	{
		get_user_msgid_saytext = get_user_msgid("SayText");
		saytext_used = true;
	}
	message_begin(type, get_user_msgid_saytext, _, id);
	write_byte(id)		
	write_string(message);
	message_end();	
}
 
Team_Info(id, type, team[])
{
	static bool:teaminfo_used;
	static get_user_msgid_teaminfo;
	if(!teaminfo_used)
	{
		get_user_msgid_teaminfo = get_user_msgid("TeamInfo");
		teaminfo_used = true;
	}
	message_begin(type, get_user_msgid_teaminfo, _, id);
	write_byte(id);
	write_string(team);
	message_end();
 
	return 1;
}
 
ColorSelection(index, type, Color:Type)
{
	switch(Type)
	{
		case RED:
		{
			return Team_Info(index, type, TeamName[1]);
		}
		case BLUE:
		{
			return Team_Info(index, type, TeamName[2]);
		}
		case GREY:
		{
			return Team_Info(index, type, TeamName[0]);
		}
	}
 
	return 0;
}
 
FindPlayer()
{
	new i = -1;
 
	while(i <= get_maxplayers())
	{
		if(is_user_connected(++i))
			return i;
	}
 
	return -1;
}
