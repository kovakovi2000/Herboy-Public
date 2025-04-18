#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <engine>
#include <fun>
#include <hamsandwich>
#include <fakemeta>
#include <xs>
#include <fakemeta_util>
#include <sqlx>
#include <sk_utils>
#include <regsystem>
#include <easytime>
#include <bansys>

#define PLUGIN "Admin Panel"
#define VERSION "v1.0b"

enum _:Rl_Prop
{
  Rule[100],
  TimeOfMin,
  RouleType[33],
}
enum _:BannedPlayers
{
  dp_name[33],
  dp_steamid[33],
  dp_ipaddress[33],
  dp_connected,
  dp_leaved,
  dp_userid,
  ap_name[33],
  ap_steamid[33],
  ap_ipaddress[33],
  ap_ban_reason[100],
  ap_ban_time,
  ap_ban_length,
  ap_lvl
}
enum _:MutedPlayers
{
  mp_name[33],
  mp_steamid[33],
  mp_ipaddress[33],
  mp_connected,
  mp_leaved,
  mp_userid,
  amp_name[33],
  amp_steamid[33],
  amp_ipaddress[33],
  amp_mute_reason[100],
  amp_mute_time,
  amp_mute_length,
  amp_mutetype,
  amp_lvl
}
enum _:Admin_Props
{
  a_name[33],
  a_steamid[33],
  a_ipaddress[33],
  a_lastconnected,
  a_lastleaved,
  a_last30dayac,
  a_last14dayac,
  a_last7dayac,
  a_addedtime,
  a_addedby,
  a_lvl,
  a_bans,
  a_kicks,
  a_mutes,
  a_userid
}
enum _:DisconnedtedPlayers
{
  dp_name[33],
  dp_steamid[33],
  dp_ipaddress[33],
  dp_connected,
  dp_leaved,
  dp_userid
}
enum _:Pl_Props
{
  p_name[33],
  p_steamid[33],
  p_ipaddress[33],
  p_connected,
  p_userid,
  p_lvl
}
enum _:MenuProps
{
  SelectedPlayer,
  SelectedType,
  SelectedRuleType,
  SelectedRule,
  SelectedRuleMuteType,
  Esetek
}
new Menuk[33][MenuProps];
new ap_Player[33][Pl_Props];
new const RulesOfBan[][Rl_Prop] = 
{
  {"SegédProgram (WallHack)", 0, "| 4.3.1"},
  {"SegédProgram (AimBot/AutoAIM)", 0, "| 4.3.1"},
  {"SegédProgram (SpeedHack)", 0, "| 4.3.1"},
  {"SegédProgram (Egyéb)", 0, "| 4.3.1"},
  {"Scan kérés megtagadása", 0, "| 4.3.1.4"},
  {"Scan kérés alatti szerver elhagyás", 0, "| 4.3.1.4"},
  {"Spawnhelyen való tartózkodás", 10, "| 4.3.16 "},
  {"Rushháló mögött való tartózkodás", 15, "| 4.3.17"},
  {"Magas PING / Laggolás", 5, "| 4.3.15"},
  {"IP / Szerverhírdetés", 21600, "| 4.3.11"},
  {"Kempelés", 10, "| 4.3.17"},
  {"Tiltás Alatt", 0, "| 4.3.2"},
  {"PP-vel/PP Itemmel való átverés", 0, "| 4.3.14"},
  {"Adminnak mutatkozás", 43830, "| 4.3.12"},
  {"Rasszizmus", 1440, "| 4.3.3"},
  {"Szerverszídás (Enyhe)", 6880, "| 4.3.13"},
  {"Szerverszídás (Súlyos)", 28400, "| 4.3.13"},
  {"Fenyegetőzés / Zsarolás", 120, "| 4.3.5"},
  {"Szerver / Módhibák súlyos kihasználása", 0, "| 4.3.20"},
  {"Vezetőség szidalmazása (Súlyos)", 0, "| 4.3.7"},
  {"Adminisztrátor szídás (Súlyos)", 0, "| 4.3.7"},
  {"Illetéktelen fiókbelépés", 0, "| 1.8"},
  {"Közösségromboló tevékenység (Enyhe)", 4440, "| 4.3.21"},
  {"Közösségromboló tevékenység (Súlyos)", 0, "| 4.3.21"},
}
new const RulesOfMute[][Rl_Prop] = 
{
  {"Provokálás", 120, "| 4.3.5"},
  {"Szülőszídás / Hozzátartozószídás", 1440, "| 4.3.8"},
  {"Zavaró Tevékenység (ChatSpam)", 300, "| 4.3.10"},
  {"Zavaró Tevékenység (Mikrofon)", 700, "| 4.3.10"},
  {"16 életév alatti mikrofonhasználat", 262980, "| 4.3.6"},
  {"Túlzott káromkodás", 180, "| 4.3.5"},
  {"Rasszizmus", 1440, "| 4.3.3"},
  {"Halottként nem beszélünk / Súgás", 30, "| 4.3.9"},
  {"IP / Szerverhírdetés", 21600, "| 4.3.11"},
  {"Fenyegetőzés / Zsarolás", 400, "| 4.3.5"},
  {"Szerverszídás (Enyhe)", 14000, "| 4.3.13"},
  {"Szerverszídás (Súlyos)", 43830, "| 4.3.13"},
  {"Vezetőség szidalmazása (Enyhe)", 14400, "| 4.3.7"},
  {"Adminisztrátor szídás (Enyhe)", 14400, "| 4.3.7"},
  {"Közösségromboló tevékenység (Enyhe)", 8880, "| 4.3.21"},
  {"Kirívó információk szivárogtatása", 0, "| 4.3.20"},
}
public plugin_init()
{
  register_plugin(PLUGIN, VERSION, "shediware")
  register_clcmd("say /adminpanel", "show_actionmenu")
}
public LoadUtils()
{
} 
new const AdminPanelNm[][] = 
{
  {""},
  {"Kitiltás"},
  {"Némítás"},
  {"Áthelyezés"},
  {"Megölés \d/\r Megütögetés"},
}
public show_adminpanel(id)
{
  new Menu[512], MenuKey
  add(Menu, 511, fmt("[\rHerBoy \d- \rSystems\w] \y» \wAdminisztrációs Panel^n^n"));
  add(Menu, 511, fmt("\w[\r1\w] \wJátékosok \rkezelése^n"));
  add(Menu, 511, fmt("\w[\r2\w] \wLelépett Játékosok \rkezelése^n"));
  add(Menu, 511, fmt("\w[\r3\w] \wAdminok \rkezelése^n^n"));
  add(Menu, 511, fmt("\w[\r4\w] \wKitiltott játékosok \rkezelése^n"));
  add(Menu, 511, fmt("\w[\r5\w] \wNémított játékosok \rkezelése^n^n"));

  add(Menu, 511, fmt("\wwww.herboy.hu @ 2018-2022^n^n"));
  add(Menu, 511, fmt("\w[\r0\w] \rKilépés a menüből.^n"));

  MenuKey = (1<<0 | 1<<1 | 1<<2 | 1<<3 | 1<<4 | 1<<5 | 1<<6 | 1<<7 | 1<<8 | 1<<9);
  show_menu(id, MenuKey, Menu, -1, "REGMAIN");
  return PLUGIN_CONTINUE
}
public show_adminpanel_h(id, MenuKey)
{
  MenuKey++;
  switch(MenuKey)
  {
    case 1: show_adminpanel_clientcmd(id);
    default:
    {
      show_menu(id, 0, "^n", 1);
      return
    }
  }
}
public show_adminpanel_clientcmd(id) 
{
  new players[32], pnum, iName[35], szTempid[10]
  get_players(players, pnum)
  new menu = menu_create(fmt("[\rHerBoy \d- \rSystems\w] \y» \wJátékosok \rkezelése"), "show_adminpanel_clientcmd_h");

  for(new i; i<pnum; i++)
  {
    get_user_name(players[i], iName, charsmax(iName))
    num_to_str(players[i], szTempid, charsmax(szTempid))
    menu_additem(menu, iName, szTempid)
  }
  menu_display(id, menu, 0)
}
public PlayerChooser_h(id, menu, item)
{
  if(item == MENU_EXIT) 
  {
    menu_destroy(menu);
    return PLUGIN_HANDLED;
  }
  new data[6], szName[64], access, callback;
  menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
  new key = str_to_num(data);
  Menuk[id][SelectedPlayer] = key;
  show_choosen(id, key)
}
public show_choosen(id, ap_selected)
{
  new Menu[512], MenuKey, CsTeams:Csapatok = cs_get_user_team(ap_selected)
  add(Menu, 511, fmt("[\rHerBoy \d- \rSystems\w] \y» \wKezelés^n^n"));
  add(Menu, 511, fmt("Név: \y%s\d(\r#%i\d)^n\wRegisztrált: \y%s^n\wAdmin Szint: \y%s^n^n", ap_Player[ap_selected][p_name], ap_Player[ap_selected][p_userid]));

  add(Menu, 511, fmt("\w[\r1\w] \rKirúgás^n"));
  add(Menu, 511, fmt("\w[\r2\w] \rKitiltás^n"));
  add(Menu, 511, fmt("\w[\r3\w] \rNémítás^n"));
  add(Menu, 511, fmt("\w[\r4\w] \rMegütés^n"));
  add(Menu, 511, fmt("\w[\r5\w] \rMegölés^n"));

  if(Csapatok != CS_TEAM_SPECTATOR)
    add(Menu, 511, fmt("\w[\r6\w] \yÁthelyezés \rSpectatorba^n"));
  if(Csapatok == CS_TEAM_CT)
    add(Menu, 511, fmt("\w[\r7\w] \yÁthelyezés \rTerroristákhoz^n"));
  else if(Csapatok == CS_TEAM_T)
    add(Menu, 511, fmt("\w[\r7\w] \yÁthelyezés \rTerrorelhárítókhoz^n"));

  add(Menu, 511, fmt("\wwww.herboy.hu @ 2018-2022^n^n"));
  add(Menu, 511, fmt("\w[\r0\w] \rKilépés a menüből.^n"));

  MenuKey = (1<<0 | 1<<1 | 1<<2 | 1<<3 | 1<<4 | 1<<5 | 1<<6 | 1<<7);
  show_menu(id, MenuKey, Menu, -1, "CHOOSENMENU");
  return PLUGIN_CONTINUE;
}
public show_choosen(id, MenuKey)
{
  MenuKey++;
  switch(MenuKey)
  {
    case 1: skbs_kick_user(Menuk[id][SelectedPlayer], id, "AFK/CAMP/EGYEB")
    case 2: show_domenu(id, Menuk[id][SelectedPlayer], 1)
    case 3: show_domenu(id, Menuk[id][SelectedPlayer], 2)
    case 4: 
    {
      client_cmd(id, fmt("amx_slap ^"%s^" 0", ap_Player[Menuk[id][SelectedPlayer]][p_steamid]))
      show_choosen(id, Menuk[id][SelectedPlayer])
    }
    case 5:
    {
      user_kill(Menuk[id][SelectedPlayer])
      sk_chat(0, "Játékos: ^4%s^1 megölve ^4%s^1 által.", ap_Player[Menuk[id][SelectedPlayer]][p_name], ap_Player[id][p_name])
    }
    case 6:
    {
      new CsTeams:Csapatok = cs_get_user_team(Menuk[id][SelectedPlayer])
      if(Csapatok != CS_TEAM_SPECTATOR)
      {
        user_kill(Menuk[id][SelectedPlayer])
        cs_set_user_team(Menuk[id][SelectedPlayer], CS_TEAM_SPECTATOR)
        sk_chat(0, "Játékos: ^4%s^1 áthelyezve ide ^4[ ^3SPECTATOR ^4] ^4%s^1 által.", ap_Player[Menuk[id][SelectedPlayer]][p_name], ap_Player[id][p_name])
      }
    }
    case 7:
    {
      new CsTeams:Csapatok = cs_get_user_team(Menuk[id][SelectedPlayer])
      if(Csapatok == CS_TEAM_CT)
      {
        user_kill(Menuk[id][SelectedPlayer])
        sk_chat(0, "Játékos: ^4%s^1 áthelyezve ide ^4[ ^3TERRORIST ^4] ^4%s^1 által.", ap_Player[Menuk[id][SelectedPlayer]][p_name], ap_Player[id][p_name])
        cs_set_user_team(Menuk[id][SelectedPlayer], CS_TEAM_T)
      }
      else if(Csapatok == CS_TEAM_T)
      {
        user_kill(Menuk[id][SelectedPlayer])
        sk_chat(0, "Játékos: ^4%s^1 áthelyezve ide ^4[ ^3COUNTER-TERRORIST ^4] ^4%s^1 által.", ap_Player[Menuk[id][SelectedPlayer]][p_name], ap_Player[id][p_name])
        cs_set_user_team(Menuk[id][SelectedPlayer], CS_TEAM_CT)
      }
    }
    default:
    {
      show_menu(id, 0, "^n", 1);
      return
    }
  }
}
public show_domenu(id, ap_selected, type)
{
  new MaxRulesOfBan = 0, MaxRulesOfMute = 0;
  new menu = menu_create(fmt("[\rHerBoy \d- \rSystems\w] \y» \wAdminisztrátori Panel \r[\w%s\r]", AdminPanelNm[type]), "show_domenu_h");
  if(type == 1)
    MaxRulesOfBan = sizeof(RulesOfBan);
  else 
    MaxRulesOfMute = sizeof(RulesOfMute);

  new MaxRule = MaxRulesOfBan+MaxRulesOfMute;
  for(new i; i < MaxRule; i++)
  {
    if(type == 1)
      menu_additem(menu, fmt("%s", RulesOfBan[i][Rule]), fmt("%i",i))
    else
      menu_additem(menu, fmt("%s", RulesOfMute[i][Rule]), fmt("%i",i))
  }
  Menuk[id][SelectedRuleType] = type;
}
public show_domenu_h(id, menu, item)
{
  if(item == MENU_EXIT) {
    menu_destroy(menu);
    return PLUGIN_HANDLED;
  }

  new data[6], szName[64], access, callback;
  menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
  Menuk[id][SelectedRule] = str_to_num(data);
  show_actionmenu(id)
}
public show_actionmenu(id)
{
  Menuk[id][SelectedRuleMuteType] = 3;
  Menuk[id][SelectedRule] = 8;
  Menuk[id][SelectedRuleType] = 1;
  Menuk[id][Esetek] = random_num(1,3)
  new Name[33]
  get_user_name(id, Name, 33)
  new Menu[512], MenuKey, Ido
  new TimeLen[128], KitiltasLejarata[40]
  Ido = 43830*Menuk[id][Esetek]//(Menuk[id][SelectedRuleType] == 1 ? RulesOfBan[Menuk[id][SelectedRule]][TimeOfMin] : RulesOfMute[Menuk[id][SelectedRule]][TimeOfMin])
  format_time(KitiltasLejarata, charsmax(KitiltasLejarata), "%Y.%m.%d - %H:%M:%S", get_systime()+Ido*60)
  easy_time_length(Ido, timeunit_minutes, TimeLen, charsmax(TimeLen));
  add(Menu, 511, fmt("[\rHerBoy \d- \rSystems\w] \y» \wKezelés^n^n"));
  add(Menu, 511, fmt("Név: \r%s \w(\r#%i\w)^n", Name, Menuk[id][SelectedPlayer]));
  add(Menu, 511, fmt("\wIndok: \r%s^n", RulesOfBan[13][Rule]))//(Menuk[id][SelectedRuleType] == 1 ? RulesOfBan[Menuk[id][SelectedRule]][Rule] : RulesOfMute[Menuk[id][SelectedRule]][Rule])));
  add(Menu, 511, fmt("\wIdő: \r%s^n", TimeLen));
  add(Menu, 511, fmt("\w%s lejárata: \r%s^n^n", AdminPanelNm[Menuk[id][SelectedRuleType]], KitiltasLejarata));

  add(Menu, 511, fmt("\w[\r1\w] \wIndok \rmegváltozatása^n"));
  add(Menu, 511, fmt("\w[\r2\w] \wEsetek: \w[\r%i\w]^n^n", Menuk[id][Esetek]));

  if(Menuk[id][SelectedRuleType] == 1)
    add(Menu, 511, fmt("\w[\r3\w] \y%s^n", AdminPanelNm[Menuk[id][SelectedRuleType]]));
  else
  {
    add(Menu, 511, fmt("\w[\r3\w] \wTípus: \w[\r%s\w]^n^n", Menuk[id][SelectedRuleMuteType] == 3 ? "Chat/Voice" : (Menuk[id][SelectedRuleMuteType] == 1 ? "Chat" : "Voice")));
    add(Menu, 511, fmt("\w[\r4\w] \y%s^n", AdminPanelNm[Menuk[id][SelectedRuleType]]));
  }
  add(Menu, 511, fmt("^n\wwww.herboy.hu @ 2018-2022^n^n"));
  add(Menu, 511, fmt("\w[\r0\w] \rKilépés a menüből.^n"));

  MenuKey = (1<<0 | 1<<1 | 1<<2 | 1<<3 | 1<<4);
  show_menu(id, MenuKey, Menu, -1, "ACTIONMENU");
  return PLUGIN_CONTINUE;
}
public show_action_h(id, MenuKey)
{
  MenuKey++;
  switch(MenuKey)
  {
    case 1: show_domenu(id, Menuk[id][SelectedPlayer], Menuk[id][SelectedRuleType]);
    case 2: client_cmd(id, "messagemode ESETEK");
    case 3:
    {
      if(Menuk[id][SelectedRuleType] == 1)
      {
        new BanIndok[100]
        format(BanIndok, 100, "%s %s", RulesOfBan[Menuk[id][SelectedRule]][Rule], RulesOfBan[Menuk[id][SelectedRule]][RouleType])
        skbs_ban_user(Menuk[id][SelectedPlayer], id, RulesOfBan[Menuk[id][SelectedRule]][TimeOfMin]*Menuk[id][Esetek], BanIndok)
      }
      else
      {
        if(Menuk[id][SelectedRuleMuteType] == 3)
          Menuk[id][SelectedRuleMuteType] = 1
        else
          Menuk[id][SelectedRuleMuteType]++;
      }
    }
    case 4: 
    { 
      if(Menuk[id][SelectedRuleType] == 2) 
      {
        new MuteIndok[100]
        format(MuteIndok, 100, "%s %s", RulesOfMute[Menuk[id][SelectedRule]][Rule], RulesOfMute[Menuk[id][SelectedRule]][RouleType])
        skbs_mute_user(Menuk[id][SelectedPlayer], id, RulesOfMute[Menuk[id][SelectedRule]][TimeOfMin]*Menuk[id][Esetek], MuteIndok, Menuk[id][SelectedRuleMuteType]);
      }
    }
    default:
    {
      show_menu(id, 0, "^n", 1);
      return
    }
  }
}

