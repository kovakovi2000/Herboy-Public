#include <amxmodx>
#include <amxmisc>
#include <sockets>
#include <sk_utils>

#define PLUGIN "TS3 Jelentés"
#define VERSION "1.0"
#define AUTHOR "MASKED"//+hackziner az alapokért +mforce a Jelentés rendszer pluginjáért

#define QUERYPORT 10011
#define JELENT_IDOKOZ 180.0 //Mennyi időnközönként jelenthetnek a játékosok msp-ben megadva
#define FLAG ADMIN_KICK

new tcp_socket
new ts_ip[32]
new ts_virtual_server[32]
new ts_query[32]
new ts_query_password[32]
new status
new format_msg[256]
new g_iTarget[33]
new bool:jelenthet[33]
new indok[300]
new tag
new Prefix

new request


public plugin_init() {

	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_cvar("ts_version",VERSION,FCVAR_SERVER)
	register_cvar("ts_ip","ts.herdboy.hu",FCVAR_SERVER) //TS3 szervered IP vagy Domain címe
	register_cvar("ts_virtual_server","1",FCVAR_SERVER) //Virtuális szerver kiválasztása, ha nem tudod kérdezd meg a szolgáltatód
	register_cvar("ts_query","serveradmin",FCVAR_PROTECTED) //Query Fiók felhasználóneve az alap: serveradmin
	register_cvar("ts_query_password","fIGi8PF1",FCVAR_PROTECTED)//Query Fiók jelszava
	register_clcmd("say /jelent", "jelent")
	register_clcmd("say_team /jelent", "jelent")
	register_clcmd("_Jelent", "jelentok")
	Prefix = register_cvar("ts_prefix", "Szervered Neve") //Itt tudod a Szervered prefixét beállítani
	
	get_cvar_string("ts_ip",ts_ip,31)
	get_cvar_string("ts_virtual_server",ts_virtual_server,31)
	get_cvar_string("ts_query",ts_query,31)
	get_cvar_string("ts_query_password",ts_query_password,31)
	
	tcp_socket=socket_open(ts_ip,QUERYPORT,SOCKET_TCP,status)
	if(status!=0)
	{
		server_print("TS: Nem Sikerült csatlakozni a szerverhez!")
		return PLUGIN_CONTINUE
	}
	else server_print("TS: Sikeres csatlakozas a TS3 szerverhez.")

	set_task(1.0,"tsconnect",0,"",0,"b")
	set_task(20.0, "keeplogin",_,_,_,"b");
	return PLUGIN_CONTINUE
}

public keeplogin(){
	format(format_msg,64,"use %s^n",ts_virtual_server)
	socket_send(tcp_socket,format_msg,63)
}

public LoadUtils()
{

}

public client_authorized(id) {
	jelenthet[id] = true
}

public client_disconnect(id) {
	if(task_exists(id)) remove_task(id)
}

public tsconnect(){
	static buffer[5012]
	if(socket_change(tcp_socket,1))
	{
		socket_recv(tcp_socket,buffer,5011)
		if(containi(buffer,"TS3")==0)
		{
			request=1
			format(format_msg,64,"login %s %s^n",ts_query,ts_query_password)
			socket_send(tcp_socket,format_msg,63)
			format(format_msg,64,"use %s^n",ts_virtual_server)
			socket_send(tcp_socket,format_msg,63)
		}
		if(containi(buffer,"error id=0 msg=ok")==0)
		{
			if(request==1)
			{
				server_print("TS: Sikeres Query bejelentkezés!")
				format(format_msg,64,"use %s^n",ts_virtual_server)
				socket_send(tcp_socket,format_msg,63)
				request=3
			}
			if(request==3)
			{
				server_print("TS: Sikeres Virtualis szerver választás!")
				request=0
			}
			if(request==4)
			{
				sk_chat(tag, "A jelentés ^3sikeresen^1 elküldve!")
				socket_send(tcp_socket,fmt("sendtextmessage targetmode=3 target=999 msg=[B][COLOR=#00ff00]nincs[/COLOR]\sjelentette\s[COLOR=#00ff00]nincs[/COLOR]-t.\sIndok:\s[COLOR=#ff0000]kacsakutya[/COLOR][/B]"),63)
				server_print("TS: Jelentés Kézbesítve!")
				request=0
			}
		}
	}
}

public jelent(id)
{
	if(!jelenthet[id])
	{
		sk_chat(id, "Jelenleg nem jelenthetsz, próbálkozz egy kicsit később!")
		return
	}
	new jelentmenu[256]
	formatex(jelentmenu, charsmax(jelentmenu), "\r[HerBoy ~ Avatár] \wCsaló Jelentése", Prefix);
	
	new menu = menu_create(jelentmenu, "jelenth")
	
	new players[32], num
	new szName[32], szTempid[32]
	
	get_players(players, num, "ach")
	
	for(new i; i < num; i++)
	{
		get_user_name(players[i], szName, charsmax(szName))
		num_to_str(get_user_userid(players[i]), szTempid, charsmax(szTempid))
		menu_additem(menu, szName, szTempid, 0)
	}
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)
	menu_setprop(menu, MPROP_BACKNAME, "Vissza")
	menu_setprop(menu, MPROP_NEXTNAME, "Következő")
	menu_setprop(menu, MPROP_EXITNAME, "Kilépés")
	menu_display(id, menu)
}

public jelenth(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}
	
	new szData[6], szName[64], iAccess, iCallback
	menu_item_getinfo(menu, item, iAccess, szData, charsmax(szData), szName, charsmax(szName), iCallback)
	
	g_iTarget[id] = find_player("k", str_to_num(szData))
 
	client_cmd(id, "messagemode _Jelent")
	menu_destroy(menu)
	return PLUGIN_HANDLED
}

public sendtextmessage(id)
{
	new kuldo[32], jelentett[32]
	new a[191], b[191], c[191]
	get_user_name(id, kuldo, charsmax(kuldo))
	get_user_name(g_iTarget[id], jelentett, charsmax(jelentett))
	format(a, 190, "%s", indok)
	replace_all(a, 190, " ", "\s")
	replace_all(a, 190, "|", "\s")
	format(b, 190, "%s", kuldo)
	replace_all(b, 190, " ", "\s")
	replace_all(b, 190, "|", "\s")
	format(c, 190, "%s", jelentett)
	replace_all(c, 190, " ", "\s")//[B][COLOR=#00ff00]%s[/COLOR]\sjelentette\s[COLOR=#00ff00]%s[/COLOR]-t.\sIndok:\s[COLOR=#ff0000]%s[/COLOR][/B]
	replace_all(c, 190, "|", "\s")
	format(format_msg,255,"sendtextmessage targetmode=3 target=999 msg=[B][COLOR=#00ff00]%s[/COLOR]\sjelentette\s[COLOR=#00ff00]%s[/COLOR]-t.\sIndok:\s[COLOR=#ff0000]%s[/COLOR][/B]^n", b, c, a)
	socket_send(tcp_socket,format_msg,255)
	request=4
	tag=id
}

public jelentok(id)
{
	indok[0] = EOS
	read_args(indok, charsmax(indok))
	remove_quotes(indok)
	
	if(!strlen(indok))
		return PLUGIN_HANDLED
	
	new num, jatekos[32]
	get_players(jatekos, num, "ch");
	new kuldo[32], jelentett[32]
	get_user_name(id, kuldo, charsmax(kuldo))
	get_user_name(g_iTarget[id], jelentett, charsmax(jelentett))
	set_task(1.0, "sendtextmessage", id)
	jelenthet[id] = false
	set_task(JELENT_IDOKOZ, "jelentenged", id)
	sk_chat(0, "^4%s^1 jelentette ^3%s^1 játékost. Indok: ^4%s", kuldo, jelentett, indok)
	log_to_file( "jelentesek.log", "%s jelentette %s-t. Indok: %s", kuldo, jelentett, indok)
	return PLUGIN_CONTINUE
}

public jelentenged(id) {
	jelenthet[id] = true
}

public plugin_end () 
{
	socket_close(tcp_socket)
}
