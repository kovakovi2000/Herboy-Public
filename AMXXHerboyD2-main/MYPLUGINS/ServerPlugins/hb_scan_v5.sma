#include <amxmodx>
#include <amxmisc>
#include <fun>
#include <cstrike>
#include <regsystem>
#include <sk_utils>
#include <bansys>

#pragma tabsize 0

new bool: hascan[33], admin, target[33], targetIP[32], targetName[32], cvars[2]
new const TAG[] = "^4[^1~^3|^4HerBoy^3|^1~^4] ^3»^1"

new bool: choosed[33], gCvarSpecbeRak, gCvarCsinalIdo, admin_spec, ban_ido

public plugin_init() {
	register_plugin("Scan", "5.0", "Ek1`");
	
	register_clcmd("scanmenu", "scanmenu")
	register_clcmd ("say", "scan");
	register_clcmd ("say_team", "scan");
	
	gCvarSpecbeRak = register_cvar("scan_specbe_rak", "1");
	gCvarCsinalIdo = register_cvar("scan_csinalasi_ido", "5");
	
	admin_spec = register_cvar("scan_admin_spec", "0");
	ban_ido = register_cvar("scan_ban_ido", "1440");

    cvars[0] = register_cvar("scan_access_flag", "d") // kick jog
	cvars[1] = register_cvar("scan_disconnect_ban", "1");

	register_dictionary("scan.txt");
	
}

public client_connect(id)
{
	hascan[id] = false;
	choosed[id]= false
}

public client_disconnect(id)
{
	if(hascan[id] & get_pcvar_num(cvars[1]))
	{
        server_cmd("amx_ban %d 1440 ^"[Auto. BAN] - Lecsatlakozás SCAN adás közben.^"", targetIP);
	}
}


public scan(id)
{
	new szSaid[195], text[512]
	read_args(szSaid, sizeof(szSaid) -1);
	remove_quotes(szSaid);
	
	if(contain(szSaid, "/scan") != -1)
	{
		if(get_user_adminlvl(id) == 0){
		console_print( id , "* Nincs engedélyed ehhez a parancshoz." );
        return PLUGIN_HANDLED
		}

		new target[32];
		copy( target, sizeof(target) -1, szSaid[6]);
		if(equal(target,""))
		{
			ColorChat(id, "%L", LANG_SERVER, "HASZNALD_IGY", TAG)
			return PLUGIN_HANDLED
		}

		for(new x=0;x<=get_maxplayers();x++)
		{
			if(hascan[x]/*||target[x]>0*/)
			{
				ColorChat(id, "%L", LANG_SERVER, "FOLYAMATBAN", TAG, get_name(admin), get_name(x));
				break
			}
		}
		
		new player = cmd_target(id, target, 2);
		
		if(hascan[player])
		{
			ColorChat(id, "%L", LANG_SERVER, "SCAN_KERVE", TAG, get_name(admin), get_name(player));
			return PLUGIN_HANDLED;
		}
		
		if(player)
		{
			if(get_pcvar_num(admin_spec)==1)
			{
				ColorChat(0, "%L", LANG_SERVER, "CSAK_NEZO", TAG);
				return PLUGIN_HANDLED
			}
			new timer[32]
			get_time("%Y/%m/%d - %H:%M:%S", timer,31);
			hascan[player] = true;
			target[player]=id
			admin=id
			targetIP=get_ip(player)
			targetName=get_name(player)
			
			choosed[id]=false
			
			client_cmd(player, ";Snapshot");
			
			sk_chat(0, "^4%s: ^3%s^1 ^4SCAN^1-t kért tőle: ^4%s^1-t Ekkor: ^4%s", id > 0 ? Admin_Permissions[get_user_adminlvl(id)][0] : "Server RCON", sk_name(admin), sk_name(player), timer)
			//ColorChat(0, "%L", LANG_SERVER, "SCANT_CSINAL", TAG, Admin_Permissions[get_user_adminlvl(admin)], sk_name(admin), sk_name(player), timer);
			ColorChat(0, "%L", LANG_SERVER, "KEP_KESZULT", TAG);
			ColorChat(0, "%L", LANG_SERVER, "LETOLTO_LINK", TAG);
			
			if(get_pcvar_num(gCvarSpecbeRak)==1)
			{
				if(is_user_alive(player))  
				user_silentkill(player)
				cs_set_user_team(player, CS_TEAM_SPECTATOR)
			}
			
			new Float:Minutes = get_pcvar_float(gCvarCsinalIdo) * 60.0;
			set_task(Minutes / 3.0, "BanMenu", id );//??
			
			ColorChat(id, "%L", LANG_SERVER, "SCAN_ADASI_IDO", TAG, get_pcvar_num(gCvarCsinalIdo), get_pcvar_num(gCvarCsinalIdo)==1?"":"SCAN", get_name(id));
			
			formatex(text,charsmax(text),"[HERBOY] Dátum: %s  %s SCAN-t kért tőle: %s", timer, sk_name(id), sk_name(player))
			write_file("addons/amxmodx/logs/scan.txt", text,-1)
			sk_log("Scan", fmt("[SCAN] Dátum: %s Admin: %s SCAN-t kért tőle: %s [Admin ID:%i] -> (AccID: %i)", timer, get_name(id), get_name(player), sk_get_accountid(id), sk_get_accountid(player)))
		}
		else
		{
			ColorChat(id, "%L", LANG_SERVER, "NEM_LETEZO_JATEKOS", TAG);
			return PLUGIN_HANDLED
		}
		
		return PLUGIN_HANDLED;
	}
	return PLUGIN_CONTINUE;
}

public BanMenu(id)
{
	if(choosed[id])	return
	new MenuTitle[168];
	format(MenuTitle, charsmax(MenuTitle), "%s \r[ \wScan menü \r]", menuprefix);


	new BanMenu = menu_create(MenuTitle, "BanHandler", 0);

	menu_additem(BanMenu, "\y|\d-\r-\y[ \wCsalás\y ]\r-\d-\y|", "1", 0, -1);
	menu_additem(BanMenu, "\y|\d-\r-\y[ \wTiszta\y ]\r-\d-\y|", "2", 0, -1);
	menu_additem(BanMenu, "\y|\d-\r-\y[ \wKérdezze később\y ]\r-\d-\y|", "3", 0, -1);
	menu_additem(BanMenu, "\y|\d-\r-\y[ \wSaját ban\y ]\r-\d-\y|", "4", 0, -1);

	menu_setprop(BanMenu, MPROP_EXIT, MEXIT_NEVER);
	menu_display(id, BanMenu);
}

public BanHandler(id, BanMenu, item)
{
	if(item == MENU_EXIT)
		return PLUGIN_HANDLED;

	new data[6], szName[64];
	new accesss, callback;

	menu_item_getinfo(BanMenu, item, accesss, data, sizeof(data), szName, sizeof(szName), callback);

	switch(str_to_num(data))
	{
		case 1:
		{
			if(!is_user_connected( find_player("c", targetIP)))
			{
				if(is_user_connected(id))
				{
					client_cmd( id, "", targetIP);
				}
				else
				{
					server_cmd("amx_ban %d 0 ^"Piros scan.^"", targetIP);
				}
			}

            ColorChat(0, "%L", LANG_SERVER, "CSALAS", TAG, get_name(admin), targetName);

			choosed[id]=true;
		}

		case 2:
		{
            ColorChat(0, "%L", LANG_SERVER, "TISZTA_JATEKOS", TAG, targetName);

			hascan[id]=false;
			choosed[id]=false;
		}

		case 3:	if(!choosed[id]&&is_user_connected(id)&&is_user_admin(id)&&is_user_connected(target[id]))	set_task(5.0,"BanMenu", id);

		case 4:
		{
			choosed[id]=true;
			menu_destroy(BanMenu);
		}
	}
	menu_destroy( BanMenu );
	return PLUGIN_HANDLED;
}

stock get_name (id) {
	new name [32] ;
	get_user_name (id, name, 31);
	
	return name;
}
stock get_ip(id) {
	new ip [20] ;
	get_user_ip (id, ip, 19,1);
	
	return ip;
}
stock ColorChat(const id, const input[], any:...)
{
    new Count = 1, Players[32];
    static Msg[191];
    vformat(Msg, 190, input, 3);

    replace_all(Msg, 190, "!g", "^4");
    replace_all(Msg, 190, "!y", "^1");
    replace_all(Msg, 190, "!t", "^3");

    if(id) Players[0] = id; else get_players(Players, Count, "ch");
    {
        for (new i = 0; i < Count; i++)
        {
            if (is_user_connected(Players[i]))
            {
                message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, Players[i]);
                write_byte(Players[i]);
                write_string(Msg);
                message_end();
            }
        }
    }
    return PLUGIN_HANDLED
}

public LoadUtils(){}

 public scanmenu(id)
 {
	 	if(get_user_adminlvl(id) == 0){
	sk_chat(id, "* Nincs engedélyed ehhez a parancshoz.")
    return PLUGIN_HANDLED
	}

	new iras[121]
	format(iras, charsmax(iras), "%s \r[ \wScan menü \r]", menuprefix);
    new menu = menu_create(iras, "menu_handler");
    new players[32], pnum, tempid;
    new szName[32], szTempid[10];
 
    get_players(players, pnum);

    for( new i; i<pnum; i++ )
    {
        tempid = players[i];
        get_user_name(tempid, szName, charsmax(szName));
        num_to_str(tempid, szTempid, charsmax(szTempid));

        menu_additem(menu, szName, szTempid, 0);
    }
    menu_setprop(menu, MPROP_EXITNAME, "\rKilépés");
    menu_setprop(menu, MPROP_NEXTNAME, "\yKövetkező");
    menu_setprop(menu, MPROP_BACKNAME, "\yVissza");
	
    menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
    menu_display(id, menu);
}
 
 public menu_handler(id, menu, item)
 {
    if( item == MENU_EXIT )
    {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }
 
    new data[6], szName[64];
    new access, callback;
    menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback)
 
    new tempid = str_to_num(data);
 
    if( is_user_alive(tempid))
	{
    client_cmd(id, "say /scan %s", szName)
    }
	else{
	client_cmd(id, "say /scan %s", szName)
}
    menu_destroy(menu);
 
    return PLUGIN_HANDLED;
 
 }
