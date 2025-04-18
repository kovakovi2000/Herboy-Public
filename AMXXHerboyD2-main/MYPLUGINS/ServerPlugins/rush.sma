/* Anti Rush by kiki | Support: www.hlmod.hu
 * Verzió: 2.8
 * 
 * Changelog:	1.0 - Alap verzió, csak dust2re, valamikor 2011-ben
 * 				2.0 - Bővített verzió, menü csinálása, zóna mód, visszalökés, és játékos megölése, cvarok létrehozása...stb
 * 				2.1 - Kisebb hibbák javítása
 * 				2.2 - Rush mehet mert... Indok megadása, új parancsok
 * 				2.3 - Üzenetek, és létfontosságú dolgok, csak akkor futnak le, ha van zóna létrehozva, olyan mapon ahol nincs, nem fognak megjelenni az üzenetek.
 * 				2.4 - Csapat beállítása 1-1 zónára. Ez jól jön a túszos, és egyéb pályákhoz.
 * 				2.5 - Konfig mappa átnevezve, nem kontabilis előző verzióval.
 * 				2.6 - ct elo jatekosok csekkolasa is <- terrorista zonahoz.
 * 				2.7 - Új cvar mely lehetővé teszi, hogy kiválaszt színes, vagy épp sima chat üzenetek jelenjenek meg.
 * 				2.8 - Villám effekt cvar, az ölőz zónához. Alapból ki van kapcsolva.
 */


#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <sk_utils>
#include <xs>

#define MAXZONAK 100
#define ZONAMUTATAS 3333
#define TASKRUSH 4444
#define UnitsToMeters(%1)	(%1*0.0254) //Unitot átrakja méterré!
#define clamp_byte(%1)     ( clamp( %1, 0, 255 ) ) 
#define write_coord_f(%1)  ( engfunc( EngFunc_WriteCoord, %1 ) )
#define null_vector        ( Float:{ 0.0, 0.0, 0.0 } )

enum ZONAMOD
{
	SEMMI,
	OLES,
	RUSH
}

enum CSAPATOK
{
	MINDENKI,
	TE,
	CT
}

new tipus[ZONAMOD] = { SOLID_NOT, SOLID_TRIGGER, SOLID_TRIGGER }
new zonaneve[ZONAMOD][] = { "zona_nincs", "zona_oles", "zona_rush"}
new zonamod[ZONAMOD][] = { "NINCS", "JATEKOS MEGOLESE", "RUSH ZONA"}
new csapatneve[CSAPATOK][] = { "zona_mindenki", "zona_te", "zona_ct"}
new celcsapat[CSAPATOK][] = { "MINDENKI", "TERRORISTAK", "ZSARUK"}

new zone_color_red[3] = { 255, 0, 0 }
new zone_color_green[3] = { 255, 255, 0 }
new zone_color_blue[3] = { 0, 0, 255 }

new zonaszin[ZONAMOD][3] = 
{
	{ 255, 0, 255 },
	{ 255, 0, 0 },
	{ 0, 255, 0 }
}

new szerkeszto = 0

new zona[MAXZONAK]
new maxzonak
new ezazona
new kordinata = 0	// 0 - X | 1 - Y | 2 - Z
new kordinatak[3][] = { "X", "Y", "Z" }

new alaptavolsag=10 //Unitba kell megadni!

new spr_dot
new light
new smoke
new villamlas
new g_screenfade

new bool:rushmehet

new cvar_alivenum
new cvar_time
new cvar_menusounds
new cvar_colorchat
new cvar_thunder

public plugin_init() 
{
	register_plugin("Anti-Rush", "2.8", "kiki - hlmod.hu")
	register_cvar("Rush Vedo", "By kiki33", FCVAR_SERVER)

	register_clcmd("say /rush", "rushmenu", ADMIN_MENU)
	register_clcmd("say_team /rush", "rushmenu", ADMIN_MENU)
	register_clcmd("say /antirush", "rushmenu", ADMIN_MENU)
	register_clcmd("say_team /antirush", "rushmenu", ADMIN_MENU)
	register_clcmd("antirush", "rushmenu", ADMIN_MENU)
	
	register_logevent( "eRound_start", 2, "1=Round_Start" );
	register_event("SendAudio", "bomb_planted", "a", "2&%!MRAD_BOMBPL")
	register_logevent("eRoundEnd", 2, "1=Round_End")

	register_forward(FM_Touch, "fw_touch")
	
	g_screenfade = get_user_msgid("ScreenFade")
	
	cvar_alivenum = register_cvar("rush_alive_players", "2") //Ha ketto vagy kevesebb terrorista el mehet a rush
	cvar_time = register_cvar("rush_time", "60.0") //Mennyi ido mulva lehessen korkezdestol rusholni. Erteke FLOAT!!!
	cvar_menusounds = register_cvar("rush_menusounds", "1") //Menuben a gombok nyomasara hangok jatszodnak le. Bekapcsolasa ajanlott! 1:be | 0:ki
	cvar_colorchat = register_cvar("rush_colorchat", "1"); //Színes chat üzenetek. 0:kikapcsolva 1: bekapcsolva
	cvar_thunder = register_cvar("rush_thundereffect", "0"); //Villámlás effekt őlős zónához. 0: kikapcsolva 1: bekapcsolva

	set_task(1.0, "zonakbetoltese")
}
public LoadUtils() 
{
	}
public plugin_precache() 
{
	villamlas = precache_sound("ambience/thunder_clap.wav");
	precache_model("models/gib_skull.mdl")
	//precache_model("sprites/antirush/antirush.spr") HAMAROSAN
	light = precache_model("sprites/lgtning.spr")
	smoke = precache_model("sprites/steam1.spr")
	spr_dot = precache_model("sprites/dot.spr")
}

public client_disconnect(id) 
{
	if (id == szerkeszto) zonakeltuntetese()
}

public zonakmentese(id) 
{
	new zonafajl[200]
	new palya[50]
	
	get_configsdir(zonafajl, 199)
	format(zonafajl, 199, "%s/antirush_by_kiki", zonafajl)

	if (!dir_exists(zonafajl)) mkdir(zonafajl)
	
	get_mapname(palya, 49)
	format(zonafajl, 199, "%s/%s.kordinatak", zonafajl, palya)
	delete_file(zonafajl)
	
	zonakereses()
	
	new szoveg[120];
	format(szoveg, 119, "; Ez a konfig a %s palyahoz tartozik!", palya)
	
	write_file(zonafajl, "; Anti-Rush By kiki - hlmod.hu")
	write_file(zonafajl, szoveg)
	write_file(zonafajl, "")
	
	for(new i = 0; i < maxzonak; i++)
	{
		new z = zona[i]
		new zm = pev(z, pev_iuser1)
		new csp = pev(z, pev_iuser2)
		
		new Float:pos[3]
		pev(z, pev_origin, pos)
		
		new Float:mins[3], Float:maxs[3]
		pev(z, pev_mins, mins)
		pev(z, pev_maxs, maxs)
		
		new output[1200];
		format(output, 1199, "%s %s", zonaneve[ZONAMOD:zm], csapatneve[CSAPATOK:csp])

		format(output, 1199, "%s %.1f %.1f %.1f", output, pos[0], pos[1], pos[2])

		format(output, 1199, "%s %.0f %.0f %.0f", output, mins[0], mins[1], mins[2])
		format(output, 1199, "%s %.0f %.0f %.0f", output, maxs[0], maxs[1], maxs[2])
		
		write_file(zonafajl, output)
	}
	
	if(get_pcvar_num(cvar_colorchat)) print_color(id, "!g[ANTI-RUSH]!t Sikeres mentés...")
	else client_print(id, print_chat, "[ANTI-RUSH] Sikeres mentés...")
}

public zonakbetoltese() 
{
	new zonafajl[200]
	new palya[50]

	get_configsdir(zonafajl, 199)
	format(zonafajl, 199, "%s/antirush_by_kiki", zonafajl)
	
	get_mapname(palya, 49)
	format(zonafajl, 199, "%s/%s.kordinatak", zonafajl, palya)
	
	if (!file_exists(zonafajl))
	{
		log_to_file("ANTIRUSH-KIKI.log", "Nem talalok %s-en mentett zonakat", palya);
		return
	}
	
	new input[1200], line = 0, len
	
	while( (line = read_file(zonafajl , line , input , 127 , len) ) != 0 ) 
	{
		if (!strlen(input)  || (input[0] == ';')) continue;

		new data[20], zm = 0, csp = 0
		new Float:mins[3], Float:maxs[3], Float:pos[3]

		strbreak(input, data, 20, input, 1199)
		zm = -1
		for(new i = 0; ZONAMOD:i < ZONAMOD; ZONAMOD:i++)
		{
			if (equal(data, zonaneve[ZONAMOD:i])) zm = i;
		}
		
		strbreak(input, data, 20, input, 1199)
		csp = -1
		for(new i = 0; CSAPATOK:i < CSAPATOK; CSAPATOK:i++)
		{
			if (equal(data, csapatneve[CSAPATOK:i])) csp = i;
		}
		
		if (zm == -1 || csp == -1)
		{
			log_to_file("ANTIRUSH-KIKI.log", "Felismerhetetlen sor: %s. Tovabblepes...", data);
			continue;
		}
		
		strbreak(input, data, 20, input, 1199);	pos[0] = str_to_float(data);
		strbreak(input, data, 20, input, 1199);	pos[1] = str_to_float(data);
		strbreak(input, data, 20, input, 1199);	pos[2] = str_to_float(data);
		
		strbreak(input, data, 20, input, 1199);	mins[0] = str_to_float(data);
		strbreak(input, data, 20, input, 1199);	mins[1] = str_to_float(data);
		strbreak(input, data, 20, input, 1199);	mins[2] = str_to_float(data);
		strbreak(input, data, 20, input, 1199);	maxs[0] = str_to_float(data);
		strbreak(input, data, 20, input, 1199);	maxs[1] = str_to_float(data);
		strbreak(input, data, 20, input, 1199);	maxs[2] = str_to_float(data);

		zonakeszites(pos, mins, maxs, zm, csp);
	}
	
	zonakereses()
	zonakeltuntetese()
}

public eRoundEnd()
{
	if(zonaszam() >= 1)
	{
		rushmehet=true
	}
}
 
public eRound_start()
{
	if(zonaszam() >= 1)
	{
		rushmehet=false;
		
		if(task_exists(TASKRUSH))
		{
			remove_task(TASKRUSH)
		}
		
		set_task(get_pcvar_float(cvar_time), "rush_mehet", TASKRUSH)
		 
		new mennyi = floatround(get_pcvar_float(cvar_time))
		new players[32], num
		get_players(players,num)
		for(new i = 0; i < num; i++)
		{
			if(get_user_team(players[i]) == 2)
			{ 
				sk_chat(players[i], "Még ^4%i^1 másodpercig nem ^4rusholhatsz!", mennyi)
			}
		}
	}
}
 
public bomb_planted()
{
	if(zonaszam() >= 1)
	{
		rush_mehet(1)
	}
}

public rush_mehet(szam)
{
	rushmehet = true;
	if(task_exists(TASKRUSH))
	{
		remove_task(TASKRUSH)
	}
	new players[32], num
	get_players(players,num)
	for(new i = 0; i < num; i++)
	{
		if(is_user_connected(players[i]))
		{ 
			set_dhudmessage(random(255), random(255), random(255), -1.0, 0.3, 2, 6.0, 6.0)
			show_dhudmessage(players[i], ".: [ A CT-k rusholhatnak! ] :.")
			switch(szam)
			{ 
				case 1: 
				{
					sk_chat(players[i], "Mehet a ^3rush^1, mert a ^3bomba^1 élesítve lett!")
				}
				case 2: 
				{
					sk_chat(players[i], "Mehet a ^3rush^1, mert kevesebb mint ^4%i^3 terrorista^1 él!", get_pcvar_num(cvar_alivenum))
				}
				case 3: 
				{
					sk_chat(players[i], "Mehet a ^3rush^1, mert kevesebb mint ^4%i^3 terrorelhárító él!", get_pcvar_num(cvar_alivenum))
				}
				default: 
				{
					sk_chat(players[i], "Mehet a ^3rush^1, mert letelt az ^3idő!")
				}
			}
		}
	}
}

public fw_touch(zona, player) 
{
	if (szerkeszto) return FMRES_IGNORED

	if (!pev_valid(zona) || !is_user_connected(player))
		return FMRES_IGNORED

	if(zonaszam() >= 1)
	{
		static classname[33]
		pev(player, pev_classname, classname, 32)
		if (!equal(classname, "player")) 
			return FMRES_IGNORED
		
		pev(zona, pev_classname, classname, 32)
		if (!equal(classname, "rushzona")) 
			return FMRES_IGNORED
		
		new csapat = get_user_team(player)
		
		if (csapat == 2 && get_alivetesnum() <= get_pcvar_num(cvar_alivenum) && rushmehet == false)
		{
			rush_mehet(2)
			return FMRES_IGNORED
		}
		
		if(csapat == 1 && get_alivectsnum() <= get_pcvar_num(cvar_alivenum) && rushmehet == false)
		{
			rush_mehet(3)
			return FMRES_IGNORED
		}
		
		if(rushmehet == false)
		{
			zonastuff(player, zona)
		}
	}
	return FMRES_IGNORED
}

public zonastuff(jatekos, zona) 
{
	new ez = pev(zona, pev_iuser1)
	new csap = pev(zona, pev_iuser2)
	new csapat = get_user_team(jatekos)
	
	if(ZONAMOD:ez == OLES && is_user_alive(jatekos)) 
	{
		if(CSAPATOK:csap == MINDENKI || csapat == 1 && CSAPATOK:csap == TE || csapat == 2 && CSAPATOK:csap == CT)
		{
			if(get_pcvar_num(cvar_thunder))
			{
				new j_poz[3], coord[3]
				get_user_origin(jatekos,j_poz);
				coord[0] = j_poz[0] + 150;
				coord[1] = j_poz[1] + 150;
				coord[2] = j_poz[2] + 800;
				create_thunder(coord,j_poz);
				spawnStaticSound( jatekos, j_poz, villamlas, VOL_NORM, ATTN_NORM, PITCH_NORM, .flags = 0 );
				user_kill(jatekos)
			}
			else user_kill(jatekos)

			sk_chat(jatekos, "Meghaltál, mert ^3rusholni^1 próbáltál!")
		}
	}
	
	if(ZONAMOD:ez == RUSH && is_user_alive(jatekos)) 
	{
		if(CSAPATOK:csap == MINDENKI || (csapat == 1) && (CSAPATOK:csap == TE) || (csapat == 2) && (CSAPATOK:csap == CT))
		{
			new Float: velocity[3]
			new Float: DW
			pev(jatekos,pev_velocity,velocity)
			DW=vector_length ( velocity )+0.0001
			velocity[0]=(velocity[0]/DW)*(-500.0)
			velocity[1]=(velocity[1]/DW)*(-500.0)
			if(velocity[2]<0) velocity[2]=velocity[2]*(-1.0)+15.0 
			set_pev(jatekos,pev_velocity,velocity)
			message_begin(MSG_ONE_UNRELIABLE, g_screenfade, {0,0,0}, jatekos)
			write_short(1<<12)
			write_short(5)
			write_short(0x0000)
			write_byte(255)
			write_byte(255)
			write_byte(255)
			write_byte(255)
			message_end()
		}
	}
}

public zonakereses() 
{
	new entity = -1
	maxzonak = 0
	while( (entity = fm_find_ent_by_class(entity, "rushzona")) )
	{
		zona[maxzonak] = entity
		maxzonak++
	}
}

public zonakmutatasa() 
{
	zonakereses()
	
	for(new i = 0; i < maxzonak; i++)
	{
		new z = zona[i];
		remove_task(ZONAMUTATAS + z)
		set_pev(z, pev_solid, SOLID_NOT)
		set_task(0.2, "mutasdazonakat", ZONAMUTATAS + z, _, _, "b")
	}
}

public zonakeltuntetese() 
{
	szerkeszto = 0
	for(new i = 0; i < maxzonak; i++)
	{
		new id = pev(zona[i], pev_iuser1)
		set_pev(zona[i], pev_solid, tipus[ZONAMOD:id])
		remove_task(ZONAMUTATAS + zona[i])
	}
}

public rushmenu(id) 
{
	if (get_user_flags(id) & ADMIN_RCON)
	{
		szerkeszto = id
		zonakereses();
		zonakmutatasa();
		
		set_task(0.1, "rushmenunyitas", id)
	}

	return PLUGIN_HANDLED
}

public rushmenunyitas(id) 
{
	new item1[1024], item2[1024], palya[50];
	get_mapname(palya, 49);
	format(item1, 1023, "\yAnti-Rush By kiki | www.hlmod.hu^n\wTalált zónák: \r%d\w | Pálya: \r%s", maxzonak, palya)
	format(item2, 1023, "\yAnti-Rush By kiki | www.hlmod.hu^n\wTalált zónák: \r%d\w | Pálya: \r%s^n\wZóna Index: \r%d", maxzonak, palya, ezazona)
	
	if(maxzonak <= 0)
	{
		new menu = menu_create(item1, "alap_handler");
		menu_additem( menu, "\wÚj zóna készítése", "a", 0 );
		menu_setprop( menu, MPROP_EXITNAME, "Kilépés" );
		menu_setprop( menu, MPROP_NEXTNAME, "Következő" );
		menu_setprop( menu, MPROP_BACKNAME, "Vissza" );
		menu_setprop( menu, MPROP_EXIT, MEXIT_ALL);
		menu_display(id, menu, 0 );
	}
	else
	{
		new menu = menu_create(item2, "alap_handler");
		new item3[120];
		format(item3, 119, "\wEnnek a zónának a szerkesztése: %d", ezazona)
		menu_additem( menu, "Új zóna készítése", "a", 0 );
		menu_addblank( menu, 0);
		menu_additem( menu, item3, "b", 0 );
		menu_additem( menu, "Előző zóna", "b", 0 );
		menu_additem( menu, "Következő zóna", "b", 0 );
		menu_additem( menu, "Kijelölt zóna \rtörlése", "b", 0 );
		menu_additem( menu, "Összes zóna mentése", "b", 0 );
		menu_setprop( menu, MPROP_EXITNAME, "Kilépés" );
		menu_setprop( menu, MPROP_NEXTNAME, "Következő" );
		menu_setprop( menu, MPROP_BACKNAME, "Vissza" );
		menu_setprop( menu, MPROP_EXIT, MEXIT_ALL);
		menu_display(id, menu, 0 );
	}
	
	if(get_pcvar_num(cvar_menusounds)) client_cmd(id, "spk sound/buttons/blip1.wav")
}

public alap_handler(id, menu, item)
{
	if ( item == MENU_EXIT )
    {
		szerkeszto = 0
		zonakeltuntetese()
		menu_destroy( menu );
		return PLUGIN_HANDLED;
    }
	
	new szData[6], szName[64];
	new item_access, item_callback;
	menu_item_getinfo( menu, item, item_access, szData,charsmax( szData ), szName,charsmax( szName ), item_callback );

	switch( szData[0] )
	{
        case 'a':
        {
            switch( item )
            {
                case 0:
				{
					if (maxzonak < MAXZONAK - 1)
					{
						ujzonajatekospoz(id);
						zonakmutatasa();
						rushmenunyitas(id);
					} else
					{
						if(get_pcvar_num(cvar_colorchat)) print_color(id, "!g[ANTI-RUSH]!t Nem lehet több zónát létrehozni!");
						else client_print(id, print_chat, "[ANTI-RUSH] Nem lehet több zónát létrehozni!")
						rushmenunyitas(id);
					}
					menu_destroy( menu );
					return PLUGIN_HANDLED;
				}
            }
        }
        case 'b':
        {
            switch( item )
            {
                case 1:
                {
                    if (fm_is_valid_ent(zona[ezazona])) szerkesztesmenu(id); else rushmenunyitas(id);
                }
                case 2:
                {
					ezazona = (ezazona > 0) ? ezazona - 1 : ezazona;
					rushmenunyitas(id)
                }
				case 3:
                {
					ezazona = (ezazona < maxzonak - 1) ? ezazona + 1 : ezazona;
					rushmenunyitas(id)
                }
				case 4:
                {
                    zonatorlese(id);
                }
				case 5:
                {
					zonakmentese(id)
					rushmenunyitas(id)
                }
            }
        }
		case 't':
        {
            switch( item )
            {
                case 0:
                {
					if(get_pcvar_num(cvar_colorchat)) print_color(id, "!g[ANTI-RUSH]!t Nem törölted ezt a zónát.");
					else client_print(id, print_chat, "[ANTI-RUSH] Nem törölted ezt a zónát.")
					rushmenunyitas(id)
                }
                case 1:
                {
					if(get_pcvar_num(cvar_colorchat)) print_color(id, "!g[ANTI-RUSH]!t A zóna törlése sikeres.");
					else client_print(id, print_chat, "[ANTI-RUSH] A zóna törlése sikeres.")
					fm_remove_entity(zona[ezazona])
					ezazona--;
					if (ezazona < 0) ezazona = 0;
					zonakereses()
					rushmenunyitas(id)
                }
            }
        }
		case 's':
        {
            switch( item )
            {
                case 0:
                {
					new zm = -1
					zm = pev(zona[ezazona], pev_iuser1)
					if (ZONAMOD:zm == RUSH) zm = 0; else zm++;
					set_pev(zona[ezazona], pev_iuser1, zm)
					szerkesztesmenu(id)
                }
				case 1:
                {
					new csp = -1
					csp = pev(zona[ezazona], pev_iuser2)
					if (CSAPATOK:csp == CT) csp = 0; 
					else csp++;
					set_pev(zona[ezazona], pev_iuser2, csp)
					szerkesztesmenu(id)
                }
				case 2:
				{
					kordinata = (kordinata < 2) ? kordinata + 1 : 0
					szerkesztesmenu(id)
				}
				case 3:
				{
					r_kicsinyites()
					szerkesztesmenu(id)
				}
				case 4:
				{
					r_nagyitas()
					szerkesztesmenu(id)
				}
				case 5:
				{
					y_kicsinyites()
					szerkesztesmenu(id)
				}
				case 6:
				{
					y_nagyitas()
					szerkesztesmenu(id)
				}
				case 7:
				{
					alaptavolsag = (alaptavolsag < 100) ? alaptavolsag * 10 : 1
					szerkesztesmenu(id)
				}
				case 8:
				{
					rushmenunyitas(id)
				}
            }
        }
    }
	
	menu_destroy( menu );
	return PLUGIN_HANDLED;
}

public szerkesztesmenu(id) 
{
	new cim[120], jelenlegi[120], csapatm[120], mkord[120], tavolsag[120];
	
	format(tavolsag, 119, "\wEltolás \y%.2f \wméterrel!", UnitsToMeters(alaptavolsag))

	format(cim, 119, "\wZóna szerkesztése: \r%d", ezazona)
	new menu = menu_create(cim, "alap_handler" );

	new zm = -1
	if (fm_is_valid_ent(zona[ezazona]))
	{
		zm = pev(zona[ezazona], pev_iuser1)
	}
	
	if (zm != -1)
	{
		format(jelenlegi, 119, "\wJelenlegi mód: \r%s", zonamod[ZONAMOD:zm])
		menu_additem( menu, jelenlegi, "s", 0 );
	}
	
	new csp = -1
	csp = pev(zona[ezazona], pev_iuser2)
	format(csapatm, 119, "\wCsapat: \r%s", celcsapat[CSAPATOK:csp])
	menu_additem( menu, csapatm, "s", 0 );
	
	format(mkord, 119, "\wMéret változtatása a \y%s \wkordinátán!", kordinatak[kordinata])
	menu_additem( menu, mkord, "s", 0 );
	menu_addblank( menu, 0);
	menu_additem( menu, "\r Eltolás közepe fele", "s", 0 );
	menu_additem( menu, "\r Közepe felől nagyítás", "s", 0 );
	menu_additem( menu, "\y Eltolás közepe fele", "s", 0 );
	menu_additem( menu, "\y Közepe felől nagyítás", "s", 0 );
	menu_addblank( menu, 0);
	menu_additem( menu, tavolsag, "s", 0 );
	menu_addblank( menu, 0);
	menu_additem( menu, "\wVissza a főmenübe", "s", 0 );
	
	menu_setprop( menu, MPROP_PERPAGE, 0 );
	menu_setprop( menu, MPROP_EXITNAME, "Kilépés" );
	menu_setprop( menu, MPROP_EXIT, MEXIT_ALL);

	menu_display(id, menu, 0 );
	if(get_pcvar_num(cvar_menusounds)) client_cmd(id, "spk sound/buttons/blip1.wav")
}

public r_kicsinyites() 
{
	new entity = zona[ezazona]
	
	new Float:pos[3]
	pev(entity, pev_origin, pos)

	new Float:mins[3], Float:maxs[3]
	pev(entity, pev_mins, mins)
	pev(entity, pev_maxs, maxs)

	if ((floatabs(mins[kordinata]) + maxs[kordinata]) < alaptavolsag + 1) return

	mins[kordinata] += float(alaptavolsag) / 2.0
	maxs[kordinata] -= float(alaptavolsag) / 2.0
	pos[kordinata] += float(alaptavolsag) / 2.0
	
	set_pev(entity, pev_origin, pos)
	fm_entity_set_size(entity, mins, maxs)
}

public r_nagyitas() 
{
	new entity = zona[ezazona]
	
	new Float:pos[3]
	pev(entity, pev_origin, pos)

	new Float:mins[3], Float:maxs[3]
	pev(entity, pev_mins, mins)
	pev(entity, pev_maxs, maxs)

	mins[kordinata] -= float(alaptavolsag) / 2.0
	maxs[kordinata] += float(alaptavolsag) / 2.0
	pos[kordinata] -= float(alaptavolsag) / 2.0
	
	set_pev(entity, pev_origin, pos)
	fm_entity_set_size(entity, mins, maxs)
}

public y_kicsinyites() 
{
	new entity = zona[ezazona]
	
	new Float:pos[3]
	pev(entity, pev_origin, pos)

	new Float:mins[3], Float:maxs[3]
	pev(entity, pev_mins, mins)
	pev(entity, pev_maxs, maxs)

	if ((floatabs(mins[kordinata]) + maxs[kordinata]) < alaptavolsag + 1) return

	mins[kordinata] += float(alaptavolsag) / 2.0
	maxs[kordinata] -= float(alaptavolsag) / 2.0
	pos[kordinata] -= float(alaptavolsag) / 2.0
	
	set_pev(entity, pev_origin, pos)
	fm_entity_set_size(entity, mins, maxs)
}

public y_nagyitas() 
{
	new entity = zona[ezazona]
	
	new Float:pos[3]
	pev(entity, pev_origin, pos)

	new Float:mins[3], Float:maxs[3]
	pev(entity, pev_mins, mins)
	pev(entity, pev_maxs, maxs)

	mins[kordinata] -= float(alaptavolsag) / 2.0
	maxs[kordinata] += float(alaptavolsag) / 2.0
	pos[kordinata] += float(alaptavolsag) / 2.0
	
	set_pev(entity, pev_origin, pos)
	fm_entity_set_size(entity, mins, maxs)
}

public zonatorlese(id) 
{
	new cim[120];
	format(cim, 119, "\yFIGYELMEZTETÉS\w Törölni akarod ezt a zónát: %d ?", ezazona)
	new menu = menu_create(cim, "alap_handler" );
	
	menu_additem( menu, "\wNem, nem szeretném törölni", "t", 0 );
	menu_additem( menu, "\rIgen, törölni szeretném", "t", 0 );
	menu_setprop( menu, MPROP_EXITNAME, "Kilépés" );
	menu_setprop( menu, MPROP_NEXTNAME, "Következő" );
	menu_setprop( menu, MPROP_BACKNAME, "Vissza" );
	menu_setprop( menu, MPROP_EXIT, MEXIT_ALL);
	menu_display(id, menu, 0 );
	
	
	if(get_pcvar_num(cvar_menusounds)) client_cmd(id, "spk sound/buttons/button10.wav")
}

public zonakeszites(Float:position[3], Float:mins[3], Float:maxs[3], zm, csp) 
{
	new entity = fm_create_entity("info_target")
	set_pev(entity, pev_classname, "rushzona")
	fm_entity_set_model(entity, "models/gib_skull.mdl")
	
	fm_entity_set_origin(entity, position)

	set_pev(entity, pev_movetype, MOVETYPE_FLY)
	new id = pev(entity, pev_iuser1)
	if (szerkeszto)
	{
		set_pev(entity, pev_solid, SOLID_NOT)
	} 
	else
	{
		set_pev(entity, pev_solid, tipus[ZONAMOD:id])
	}
	
	fm_entity_set_size(entity, mins, maxs)
	fm_set_entity_visibility(entity, 0)
	
	set_pev(entity, pev_iuser1, zm)
	set_pev(entity, pev_iuser2, csp)
	
	return entity
}

public ujzona(Float:position[3]) 
{
	new Float:mins[3] = { -32.0, -32.0, -32.0 }
	new Float:maxs[3] = { 32.0, 32.0, 32.0 }
	return zonakeszites(position, mins, maxs, 0, 0);
}

public ujzonajatekospoz(player) 
{
	new Float:position[3]
	pev(player, pev_origin, position)
	
	new entity = ujzona(position)
	zonakereses()
	
	for(new i = 0; i < maxzonak; i++) if (zona[i] == entity) ezazona = i;
}

public mutasdazonakat(entity) 
{
	entity -= ZONAMUTATAS
	if ((!fm_is_valid_ent(entity)) || !szerkeszto) return

	new Float:pos[3]
	pev(entity, pev_origin, pos)
	if (!fm_is_in_viewcone(szerkeszto, pos) && (entity != zona[ezazona])) return

	new Float:editorpos[3]
	pev(szerkeszto, pev_origin, editorpos)
	new Float:hitpoint[3]
	fm_trace_line(-1, editorpos, pos, hitpoint)

	if (entity == zona[ezazona]) DrawLine(editorpos[0], editorpos[1], editorpos[2] - 16.0, pos[0], pos[1], pos[2], { 255, 0, 0} )

	new Float:dh = vector_distance(editorpos, pos) - vector_distance(editorpos, hitpoint)
	if ( (floatabs(dh) > 128.0) && (entity != zona[ezazona])) return

	new Float:mins[3], Float:maxs[3]
	pev(entity, pev_mins, mins)
	pev(entity, pev_maxs, maxs)

	mins[0] += pos[0]
	mins[1] += pos[1]
	mins[2] += pos[2]
	maxs[0] += pos[0]
	maxs[1] += pos[1]
	maxs[2] += pos[2]
	
	new id = pev(entity, pev_iuser1)
	
	new color[3]
	color[0] = (zona[ezazona] == entity) ? zone_color_blue[0] : zonaszin[ZONAMOD:id][0]
	color[1] = (zona[ezazona] == entity) ? zone_color_blue[1] : zonaszin[ZONAMOD:id][1]
	color[2] = (zona[ezazona] == entity) ? zone_color_blue[2] : zonaszin[ZONAMOD:id][2]
	
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

	if (entity != zona[ezazona]) return
	
	if (kordinata == 0)	// X
	{
		DrawLine(maxs[0], maxs[1], maxs[2], maxs[0], mins[1], mins[2], zone_color_green)
		DrawLine(maxs[0], maxs[1], mins[2], maxs[0], mins[1], maxs[2], zone_color_green)
		
		DrawLine(mins[0], maxs[1], maxs[2], mins[0], mins[1], mins[2], zone_color_red)
		DrawLine(mins[0], maxs[1], mins[2], mins[0], mins[1], maxs[2], zone_color_red)
	}
	if (kordinata == 1)	// Y
	{
		DrawLine(mins[0], mins[1], mins[2], maxs[0], mins[1], maxs[2], zone_color_red)
		DrawLine(maxs[0], mins[1], mins[2], mins[0], mins[1], maxs[2], zone_color_red)

		DrawLine(mins[0], maxs[1], mins[2], maxs[0], maxs[1], maxs[2], zone_color_green)
		DrawLine(maxs[0], maxs[1], mins[2], mins[0], maxs[1], maxs[2], zone_color_green)
	}	
	if (kordinata == 2)	// Z
	{
		DrawLine(maxs[0], maxs[1], maxs[2], mins[0], mins[1], maxs[2], zone_color_green)
		DrawLine(maxs[0], mins[1], maxs[2], mins[0], maxs[1], maxs[2], zone_color_green)

		DrawLine(maxs[0], maxs[1], mins[2], mins[0], mins[1], mins[2], zone_color_red)
		DrawLine(maxs[0], mins[1], mins[2], mins[0], maxs[1], mins[2], zone_color_red)
	}
}

public FX_Line(start[3], stop[3], color[3], brightness) 
{
	message_begin(MSG_ONE_UNRELIABLE, SVC_TEMPENTITY, _, szerkeszto) 
	
	write_byte( TE_BEAMPOINTS ) 
	
	write_coord(start[0]) 
	write_coord(start[1])
	write_coord(start[2])
	
	write_coord(stop[0])
	write_coord(stop[1])
	write_coord(stop[2])
	
	write_short( spr_dot )
	
	write_byte( 1 )	// framestart 
	write_byte( 1 )	// framerate 
	write_byte( 4 )	// life in 0.1's 
	write_byte( 5 )	// width
	write_byte( 0 ) 	// noise 
	
	write_byte( color[0] )   // r, g, b 
	write_byte( color[1] )   // r, g, b 
	write_byte( color[2] )   // r, g, b 
	
	write_byte( brightness )  	// brightness 
	write_byte( 0 )   	// speed 
	
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

stock print_color(const id, const input[], any:...)
{
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

stock get_alivetesnum() 
{
	new players[32], pnum;
	get_players(players, pnum, "ae", "TERRORIST");
	return pnum;
}

stock get_alivectsnum() 
{
	new players[32], pnum;
	get_players(players, pnum, "ae", "CT");
	return pnum;
}

stock zonaszam()
{
	zonakereses()
	return maxzonak;
}

stock create_thunder(vec1[3],vec2[3])
{
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY); 
	write_byte(0); 
	write_coord(vec1[0]); 
	write_coord(vec1[1]); 
	write_coord(vec1[2]); 
	write_coord(vec2[0]); 
	write_coord(vec2[1]); 
	write_coord(vec2[2]); 
	write_short(light); 
	write_byte(1);
	write_byte(5);
	write_byte(2);
	write_byte(20);
	write_byte(30);
	write_byte(200); 
	write_byte(200);
	write_byte(200);
	write_byte(200);
	write_byte(200);
	message_end();

	message_begin( MSG_PVS, SVC_TEMPENTITY,vec2); 
	write_byte(TE_SPARKS); 
	write_coord(vec2[0]); 
	write_coord(vec2[1]); 
	write_coord(vec2[2]); 
	message_end();
	
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY,vec2); 
	write_byte(TE_SMOKE); 
	write_coord(vec2[0]); 
	write_coord(vec2[1]); 
	write_coord(vec2[2]); 
	write_short(smoke); 
	write_byte(10);  
	write_byte(10)  
	message_end();
}

stock spawnStaticSound( const index, const origin[3], const soundIndex, const Float:vol, const Float:atten, const pitch, const flags ) 
{ 
    message_begin( index ? MSG_ONE : MSG_ALL, SVC_SPAWNSTATICSOUND, .player = index );
    {
        write_coord_f( origin[0] ); 
        write_coord_f( origin[1] ); 
        write_coord_f( origin[2] );
        write_short( soundIndex );
        write_byte( clamp_byte( floatround( vol * 255 ) ) );
        write_byte( clamp_byte( floatround( atten * 64 ) ) );
        write_short( index );        
        write_byte( pitch ); 
        write_byte( flags );   
    }
    message_end();
}
