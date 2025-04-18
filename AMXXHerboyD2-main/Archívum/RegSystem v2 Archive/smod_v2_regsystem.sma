
#include <amxmodx>
#include <cstrike>
#include <fakemeta>
#include <hamsandwich>
#include <regex>
#include <engine>
#include <sqlx>
#include <bansys>
#include <sk_utils>
#include <reapi>
#include <regsystem>

new server, AllowedForLoginPanel[33] = 0;
new g_screenfade, fwd_loadcmd;
#define DEMO_TASK_OFFSET 46236253
#define DEMO_TASK_DETAIL 45236253

enum _:RegisterProperties
{
  gId,
  gName[33],
  gIP[33],
  gSteamID[33],
  gUsername[33],
  gPassword[33],
  gPasswordAgain[33],
  gPasswordHash[100],
  gEmail[33],
  gProgress, 
  gAutoLogin,
  InProgress,
  LoginKey[33],
  Logined,
  Logined_Print,
  Active,
  SwitchedTeam,
  IsHaveAccount,
  HelpUsername[33],
  HelpEmail[33]
}
new s_Player[33][RegisterProperties]
public plugin_init()
{
  register_plugin("[SK] - RegSystem", "v2.0", "shedike");
  register_impulse(201, "CheckMenu");
  register_clcmd("Felhasznalonev", "set_username");
  register_clcmd("Jelszo", "set_password");
  register_clcmd("JelszoUjra", "set_passwordAgain");
  register_clcmd("Email", "set_email");
  register_clcmd("showteammenu", "ChooseTeam")

  register_menucmd(register_menuid("REGMAIN"), 0xFFFF, "hRegmain")
  register_menucmd(register_menuid("reglogmenu"), 0xFFFF, "h_reglogin")
  register_menucmd(register_menuid("TEAMMENU"), 0xFFFF, "ChooseTeamh")
  register_message(get_user_msgid("ShowMenu"), "TextMenu")
  register_message(get_user_msgid("VGUIMenu"), "VGUIMenu1")
  register_clcmd("jointeam", "BlockJoin")
  register_clcmd("chooseteam", "BlockJoin")
  g_screenfade = get_user_msgid("ScreenFade")
  fwd_loadcmd = CreateMultiForward("Load_User_Data", ET_IGNORE, FP_CELL)

  new ServerIP[33]
  get_user_ip(0, ServerIP, 33, 0)

  if(equali(ServerIP, "37.221.214.193:27280"))
    server = 1;
  else if(equali(ServerIP, "37.221.214.193:27650"))  
    server = 2;
  else if(equali(ServerIP, "37.221.214.193:27215"))  
    server = 3;
  else if(equali(ServerIP, "37.221.214.193:27200"))  
    server = 4;
  else if(equali(ServerIP, "37.221.214.193:27100"))  
    server = 5;
}
public plugin_natives()
{
  register_native("sk_get_accountid","native_sk_get_accountid",1)
  register_native("sk_get_logged","native_sk_get_logged",1)
  register_native("sk_set_autologin","native_sk_set_autologin",1)
  register_native("sk_get_autologin","native_sk_get_autologin",1)
}
public native_sk_get_accountid(index)
{
  return s_Player[index][gId];
}
public native_sk_get_logged(index)
{
  return s_Player[index][Logined];
}
public native_sk_set_autologin(index, set)
{
  s_Player[index][gAutoLogin] = set;
  sk_chat(index, "Sikeresen %s^1 az Automatikus bejelentkezést!", set == 1 ? "^4Bekapcsoltad" : "^3Kikapcsoltad")
}
public native_sk_get_autologin(index)
{
  return s_Player[index][gAutoLogin];
}
public CheckMenu(id)
{
  if(AllowedForLoginPanel[id] && skbs_is_Validated(id))
  {
    if(!s_Player[id][Logined] && s_Player[id][InProgress] == 0)
      regmenu(id);
  }
  return PLUGIN_CONTINUE;
}
public BlockJoin(id)
{
  if(!s_Player[id][Logined])
    return PLUGIN_HANDLED
  return PLUGIN_CONTINUE
}
public TextMenu(msgid, dest, id)
{
  if(!is_user_connected(id))
      return PLUGIN_CONTINUE

  new menu_text[64];

  get_msg_arg_string(4, menu_text, charsmax(menu_text)) //TODO Mi van ebbe, ha más mit a rádióé akkor legyen ellenörízve, úgy ez VGUIMenu1(...)-ben is

  if(!s_Player[id][Logined])
    return PLUGIN_HANDLED
  else
    ChooseTeam(id)

  return PLUGIN_HANDLED
}
public VGUIMenu1(msgid, dest, id)
{
  if(!is_user_connected(id))
      return PLUGIN_CONTINUE

  new menu_text[64];

  get_msg_arg_string(4, menu_text, charsmax(menu_text))

  if(!s_Player[id][Logined])
    return PLUGIN_HANDLED
  else
    ChooseTeam(id)
    
  return PLUGIN_HANDLED
}
static FrameCall;
public server_frame()
{
  if(FrameCall < 400)
  {
    FrameCall++;
    return;
  }
  else
    FrameCall = 0;
  
  new p[32],n, id;
  get_players(p,n,"ch");
  for(new i=0;i<n;i++)
  {
    id = p[i];
    if(!s_Player[id][Logined] || cs_get_user_team(id) == CS_TEAM_UNASSIGNED)
    {
      if(!skbs_is_Validated(id))
        client_print(id, print_center, "Várakozás a Kliens ellenőrzésére, internetedtől függően akár 14 másodpercig is eltarthat.");
      else if(s_Player[id][InProgress] == 4)
        client_print(id, print_center, "Bejelentkezés folyamatban kérlek várj! [ Fiókadatok / Skinek betöltése... ]");
      else if(!s_Player[id][Logined])
        client_print(id, print_center, "Regisztrálj vagy Jelentkezz be! [ T Betű ]");
      else 
        client_print(id, print_center, "Válassz egy csapatot! [ M Betű ]");

      message_begin(MSG_ONE_UNRELIABLE, g_screenfade, {0,0,0}, id)
      write_short(1<<12)
      write_short(1<<12)
      write_short(0x0000)
      write_byte(0)
      write_byte(0)
      write_byte(0)
      write_byte(255)
      message_end()
    }
  }
}
public skbs_user_validated_success(id)
{
  AllowedForLoginPanel[id] = 1;
  sk_chat(id, "Most már betudsz jelentkezni vagy regisztrálni!")
  skbs_get_UniqueKey32(id, s_Player[id][LoginKey], 32);
  if(s_Player[id][LoginKey][0] != EOS)
    SQL_LoadUserAccount(id, 1);
  else
    regmenu(id);
}
public regmenu(id)
{
  if(s_Player[id][InProgress] > 0)
    return PLUGIN_HANDLED;

  s_Player[id][gProgress] = 0;
  new Menu[512], MenuKey
  add(Menu, 511, fmt("[\rHerBoy \d- \rSystems\w] \y» ^n\wRegisztrálj vagy jelentkezz be!^n^n"));
  if(!s_Player[id][IsHaveAccount])
    add(Menu, 511, fmt("\w[\r1\w] \rRegisztráció^n"));
  else add(Menu, 511, fmt("\d[\d1\d] \dRegisztráció \w(\rVan már fiókod!\w)^n"));
  add(Menu, 511, fmt("\w[\r2\w] \yBejelentkezés^n"));
  add(Menu, 511, fmt("\w[\r3\w] \wElfelejtett jelszó^n^n"));

  add(Menu, 511, fmt("\dBejelentkezéssel elfogadod az Általános Szerződési Feltételeinket!^n"));
  add(Menu, 511, fmt("\wwww.herboy.hu @ 2018-2022^n^n"));

  MenuKey = (1<<0 | 1<<1 | 1<<2 | 1<<3 | 1<<4 | 1<<5 | 1<<6 | 1<<7 | 1<<8 | 1<<9);
  show_menu(id, MenuKey, Menu, -1, "REGMAIN");
  return PLUGIN_CONTINUE
}
public hRegmain(id, MenuKey)
{
  MenuKey++;
  switch(MenuKey)
  {
    case 1: 
    {
      if(s_Player[id][IsHaveAccount] == 0)
      {
        s_Player[id][gProgress] = 1;
        regloginmenu(id, 1)
      }
      else 
      {
        sk_chat(id, "Neked már van fiókod! Jelentkezz be, vagy keress fel minket teamspeaken, vagy csoportba!")
        regmenu(id)
      }
    }
    case 2: 
    {
      s_Player[id][gProgress] = 2;
      regloginmenu(id, 2)
    }
    default:
    {
      regmenu(id)
    }
  }
}
public regloginmenu(id, reg_type)
{
  new Menu[512], MenuKey
  add(Menu, 511, fmt("[\rHerBoy \d- \rSystems\w] \y» ^n\wRegisztrálj vagy jelentkezz be! \r* = Kötelező^n^n"));

  add(Menu, 511, fmt("\w[\r1\w] \wFelhasználónév\r*: \r%s^n", s_Player[id][gUsername]));
  add(Menu, 511, fmt("\w[\r2\w] \wJelszó\r*: \r%s^n", s_Player[id][gPassword]));
  if(reg_type == 1)
  {
    add(Menu, 511, fmt("\w[\r3\w] \wJelszó Újra\r*: \r%s^n", s_Player[id][gPasswordAgain]));
    add(Menu, 511, fmt("\w[\r4\w] \wEmail: \r%s^n^n", s_Player[id][gEmail]));
    if(!s_Player[id][IsHaveAccount])
      add(Menu, 511, fmt("\w[\r5\w] \yRegisztrálás^n"));
    else add(Menu, 511, fmt("\d[\d5\d] \dRegisztrálás \w(\rVan már fiókod!\w)^n"));
    add(Menu, 511, fmt("\w[\r6\w] \yAuto bejelentkezés \w[%s\w]^n", s_Player[id][gAutoLogin] == 1 ? "\yBekapcsolva" : "\rKikapcsolva"));
  }
  if(reg_type == 2)
    add(Menu, 511, fmt("\w[\r3\w] \yBejelentkezés^n"));


  add(Menu, 511, fmt("^n\dBejelentkezéssel elfogadod az Általános Szerződési Feltételeinket!^n"));
  add(Menu, 511, fmt("\wwww.herboy.hu @ 2018-2022^n^n"));
  if(reg_type == 1 || reg_type == 2)
  add(Menu, 511, fmt("\w[\r0\w] \rVissza a főmenübe.^n"));

  MenuKey = (1<<0 | 1<<1 | 1<<2 | 1<<3 | 1<<4 | 1<<5 | 1<<6 | 1<<7 | 1<<8 | 1<<9);
  show_menu(id, MenuKey, Menu, -1, "reglogmenu");
  return PLUGIN_CONTINUE
}
public h_reglogin(id, MenuKey)
{
  new m_joinstate = get_member(id, m_iJoiningState);
  MenuKey++;
  switch(MenuKey)
  {
    case 1: 
    {
      client_cmd(id, "messagemode Felhasznalonev")
    }
    case 2: client_cmd(id, "messagemode Jelszo")
    case 3: 
    {
      if(s_Player[id][gProgress] == 1)
        client_cmd(id, "messagemode JelszoUjra")
      else if(s_Player[id][gProgress] == 2)
        Login(id);
    }
    case 4: 
    {
      if(s_Player[id][gProgress] == 1)
        client_cmd(id, "messagemode Email")
      else if(s_Player[id][gProgress] == 2)
        regloginmenu(id, 2)
    }
    case 5: 
    {
      if(s_Player[id][gProgress] == 1)
      {
        if(s_Player[id][IsHaveAccount] == 0)
        {
          Register(id);
        }
        else
        {
          sk_chat(id, "Neked már van fiókod! Jelentkezz be, vagy keress fel minket teamspeaken, vagy csoportba!")
          regmenu(id)
        }
      }
      else if(s_Player[id][gProgress] == 2)
        regloginmenu(id, 2)
    }
    case 6: 
    {
      if(s_Player[id][gProgress] == 1)
        s_Player[id][gAutoLogin] = !s_Player[id][gAutoLogin];
      else if(s_Player[id][gProgress] == 2)
        regloginmenu(id, 2)
    }
    case 7..9:
    {
      if(s_Player[id][gProgress] == 1)
        regloginmenu(id, 1)
      else if(s_Player[id][gProgress] == 2)
        regloginmenu(id, 2)
    }
    default: 
    {
      regmenu(id)
    }
  }
}

public set_username(id)
{
  if(s_Player[id][Logined])
    return;

  new Arg[32];
  read_argv(1, Arg, charsmax(Arg));

  if(RegexTester(id, Arg, "^^[a-zA-Z0-9]{4,16}+$", "A felhasználónév, angol ABC betűit és számokat tartalmazhatja, és a hossza maximum 16 karakter lehet."))
    copy(s_Player[id][gUsername], 32, Arg);
  regloginmenu(id, s_Player[id][gProgress])
}
public set_password(id)
{
  if(s_Player[id][Logined])
    return;
  new Arg[32];
  read_argv(1, Arg, charsmax(Arg));

  if(RegexTester(id, Arg, "^^[a-zA-Z0-9]{4,32}+$", "A jelszó, angol ABC betűit és számokat tartalmazhatja, és a hossza maximum 32 karakter lehet."))
  {
    copy(s_Player[id][gPassword], 32, Arg);
    new hash[256];
    hash_string(Arg, Hash_Md5, hash, charsmax(hash));
    hash_string(hash, Hash_Md5, hash, charsmax(hash));
    copy(s_Player[id][gPasswordHash], 100, hash);
  }
  regloginmenu(id, s_Player[id][gProgress]);
}
public set_passwordAgain(id)
{
  if(s_Player[id][Logined])
    return;
  new Arg[32];
  read_argv(1, Arg, charsmax(Arg));

  if(RegexTester(id, Arg, "^^[a-zA-Z0-9]{4,32}+$", "A jelszó, angol ABC betűit és számokat tartalmazhatja, és a hossza maximum 32 karakter lehet."))
    copy(s_Player[id][gPasswordAgain], 32, Arg);
  regloginmenu(id, 1) 
}
public set_email(id)
{
  if(s_Player[id][Logined])
    return;
  new Arg[32];
  read_argv(1, Arg, charsmax(Arg));

  if(RegexTester(id, Arg, "^^[-+_.a-zA-Z0-9]{1,16}+@(herboy|gmail|freemail|yahoo|citromail)\.(hu|com)$", "A email, magyar ABC betűit tartalmazhatja, és a hossza maximum 16 karakter lehet (domain nélkül)."))
    copy(s_Player[id][gEmail], 32, Arg);
  else
    s_Player[id][gEmail][0] = EOS;
  regloginmenu(id, 1)
}
public Register(id)
{
  if(equal(s_Player[id][gUsername], "") || equal(s_Player[id][gPassword],""))
  {
    sk_chat(id, "Valamit nem töltöttél ki, a regisztráció befejezéséhez tölts ki mindent!");
    regloginmenu(id, 1)
    return;
  }
  if(!equal(s_Player[id][gPassword], s_Player[id][gPasswordAgain]))
  {
    sk_chat(id, "A két jelszó nem egyezik!");
    regloginmenu(id, 1)
    return;
  }
  else
  {
    sk_chat(id, "Regisztráció ^3folyamatban^1, kérlek várj türelemmel!");
    s_Player[id][InProgress] = 1;
    SQL_CheckAccount(id, 1)
  }
}
public Login(id)
{
  if(equali(s_Player[id][gUsername], "") || equali(s_Player[id][gPassword],""))
  {
    sk_chat(id, "Valamit nem töltöttél ki, a bejelentkezéshez tölts ki mindent!");
    regloginmenu(id, 2)
    return;
  }
  else
  {
    sk_chat(id, "Bejelentkezés ^3folyamatban^1, kérlek várj türelemmel!");
    s_Player[id][InProgress] = 1;
    SQL_CheckAccount(id, 2)
  }
}
public SQL_CheckSteamIDAccount(id)
{
  static Query[20048]
  new Data[1];
  Data[0] = id;

  formatex(Query, charsmax(Query), "SELECT * FROM `herboy_regsystem` WHERE RegisterID = ^"%s^" LIMIT 1;", s_Player[id][gSteamID])
  SQL_ThreadQuery(g_SqlTuple, "SQL_CheckSteamIDAccount_h", Query, Data, 1);
}
public SQL_CheckSteamIDAccount_h(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime)
{
  if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED)
  {
    log_amx("%s", Error);
    set_fail_state("* Hibas lekerdezes itt, LoadUser: %s", Error)
    return;
  }
  else
  {
    new id = Data[0];
    
    if(SQL_NumRows(Query) > 0)
    {
      s_Player[id][IsHaveAccount] = 1;
    }
    else s_Player[id][IsHaveAccount] = 0;
  }
}
public SQL_CheckAccount(id, logreg)
{
  static Query[20048];
  new Data[2];
  Data[0] = id;
  Data[1] = logreg;
  formatex(Query, charsmax(Query), "SELECT Username, RegisterID FROM `herboy_regsystem` WHERE `Username` = ^"%s^" OR `RegisterID` = ^"%s^" LIMIT 1;", s_Player[id][gUsername], s_Player[id][gSteamID])
  SQL_ThreadQuery(g_SqlTuple, "Query_CheckAccount", Query, Data, 2);
}
public SQL_CheckEmail(id, logreg)
{
  static Query[20048];
  new Data[2];
  Data[0] = id;
  Data[1] = logreg;
  formatex(Query, charsmax(Query), "SELECT Email FROM `herboy_regsystem` WHERE `Email` = ^"%s^" LIMIT 1;", s_Player[id][gEmail])
  SQL_ThreadQuery(g_SqlTuple, "Query_CheckAccount", Query, Data, 2);
}
public Query_CheckAccount(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime) {
  if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) {
    log_amx("%s", Error);
    set_fail_state("* Hibas lekerdezes itt, SQL Check Account: %s", Error)
    return;
  }
  else {
    new id = Data[0];
    new RegOrLogin = Data[1];
    
    new AccountFound = SQL_NumRows(Query);
    if(RegOrLogin == 1)
    {
      new registerid[33];
      SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "RegisterID"), registerid, 33);
      if(equal(s_Player[id][gSteamID], registerid))
        AccountFound = 2;
      
      if(AccountFound == 1)
      {
        sk_chat(id, "Ezzel a felhasználónévvel már regisztráltak!");
        s_Player[id][InProgress] = 0;
        regloginmenu(id, 1);
        return;
      }
      else if(AccountFound == 2)
      {
        sk_chat(id, "Neked már van fiókod! Jelentkezz be, vagy keress fel minket teamspeaken, vagy csoportba!");
        s_Player[id][InProgress] = 0;
        s_Player[id][IsHaveAccount] = 1;
        regloginmenu(id, 1);
        return;
      }
      else if(s_Player[id][IsHaveAccount] == 1)
      {
        sk_chat(id, "Neked már van fiókod! Jelentkezz be, vagy keress fel minket teamspeaken, vagy csoportba!");
        s_Player[id][InProgress] = 0;
        regloginmenu(id, 1);
        return;
      }
      else if(!equal(s_Player[id][gEmail], "")) SQL_CheckEmail(id, 3);
      else SQL_CreateUserAccount(id);

    }
    else if(RegOrLogin == 2)
    {
      if(!AccountFound)
      {
        sk_chat(id, "Hibás felhasználónév vagy jelszó, vagy ez a fiók nem létezik!");
        s_Player[id][InProgress] = 0;
        regloginmenu(id, 2);
        return;
      }
      else SQL_LoadUserAccount(id, 0)
    }
    else if(RegOrLogin == 3)
    {
      if(AccountFound)
      {
        sk_chat(id, "Ezzel a emaillel már regisztráltak!");
        s_Player[id][InProgress] = 0;
        regloginmenu(id, 1);
        return;
      }
      else SQL_CreateUserAccount(id)
    }
  }
}
public SQL_CreateUserAccount(id)
{
  static Query[20048]
  new Data[1];
  Data[0] = id;
  new sTime[64];
  formatCurrentDateAndTime(sTime, charsmax(sTime));
  if(s_Player[id][gAutoLogin])
    formatex(Query, charsmax(Query), "INSERT INTO `herboy_regsystem` (`id`, `Username`, `Password`, `Email`, `LoginKey`, `RegisterName`, `RegisterIP`, `RegisterID`, `RegisterDate`) VALUES (%i, ^"%s^", ^"%s^",^"%s^",^"%s^",^"%s^",^"%s^",^"%s^",^"%s^")", s_Player[id][gId], s_Player[id][gUsername], s_Player[id][gPasswordHash], s_Player[id][gEmail], s_Player[id][LoginKey], s_Player[id][gName],s_Player[id][gIP], s_Player[id][gSteamID], sTime)
  else
    formatex(Query, charsmax(Query), "INSERT INTO `herboy_regsystem` (`id`,`Username`, `Password`, `Email`, `RegisterName`, `RegisterIP`, `RegisterID`, `RegisterDate`) VALUES (%i, ^"%s^", ^"%s^",^"%s^",^"%s^",^"%s^",^"%s^",^"%s^")", s_Player[id][gId], s_Player[id][gUsername], s_Player[id][gPasswordHash], s_Player[id][gEmail], s_Player[id][gName],s_Player[id][gIP], s_Player[id][gSteamID], sTime)
  
  SQL_ThreadQuery(g_SqlTuple, "Query_CreateUserAccount", Query, Data, 2);
}
public Query_CreateUserAccount(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime) {
  if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) {
    log_amx("%s", Error);
    set_fail_state("* Hibas lekerdezes itt, SQL Create Account: %s", Error)
    return;
  }
  else {
    new id = Data[0];	

    sk_chat(id, "Sikeresen regisztráltál, most már bejelentkezhetsz, felhasználónév: ^4%s", s_Player[id][gUsername])
    s_Player[id][InProgress] = 0;
    s_Player[id][gUsername][0] = EOS;
    s_Player[id][gPassword][0] = EOS;
    s_Player[id][gProgress] = 2
    regloginmenu(id, 2)
  }
}
public SQL_LoadUserAccount(id, fastlogin)
{
  static Query[20048]
  new Data[2];
  Data[0] = id;
  Data[1] = fastlogin;

  if(fastlogin == 0)
    formatex(Query, charsmax(Query), "SELECT * FROM herboy_regsystem WHERE Username = ^"%s^" AND Password = ^"%s^" LIMIT 1;", s_Player[id][gUsername], s_Player[id][gPasswordHash])
  else
    formatex(Query, charsmax(Query), "SELECT * FROM herboy_regsystem WHERE LoginKey = ^"%s^" LIMIT 1;", s_Player[id][LoginKey])

  SQL_ThreadQuery(g_SqlTuple, "Query_LoadUserAccount", Query, Data, 2);
}
public Query_LoadUserAccount(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime) {
  new isfastlogined = Data[1]
  if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) {
    log_amx("%s", Error);
    set_fail_state("* Hibas lekerdezes itt, SQL Create Account: %s", Error)
    return;
  }
  else 
  {
    new id = Data[0];
    if(SQL_NumRows(Query) > 0) 
    {
      if(isfastlogined == 1)
      {
        sk_chat(id, "Automatikus bejelentkezés ^3folyamatban^1, kérlek várj türelemmel!");
      }
      s_Player[id][InProgress] = 4;
      s_Player[id][Active] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Active"));
      s_Player[id][gAutoLogin] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "AutoLogin"));
      SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Username"), s_Player[id][gUsername], 33);
      if(s_Player[id][Active] > 0)
      {
        sk_chat(id, "A fiókba már valaki bejelentkezett ezen a szerveren: ^4%s", ServerID[s_Player[id][Active]][server_type])
        regloginmenu(id, 2)
        s_Player[id][InProgress] = 0;
        return;
      }
      s_Player[id][gId] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "id"));
      //TODO Forward;
      
      new fwdloadtestret
      ExecuteForward(fwd_loadcmd,fwdloadtestret, id);
      //LoggedSuccesfully(id)
    }
    else
    {
      if(isfastlogined == 1)
        regmenu(id)
      else
      {
        sk_chat(id, "Hibás felhasználónév vagy jelszó, vagy a fiók nem létezik!")
        regloginmenu(id, 2)
        s_Player[id][InProgress] = 0;
        return;
      }
    }
  }
}
public LoggedSuccesfully(id)
{
  if(!is_user_connected(id))
    return;
  
  s_Player[id][Active] = server;
  s_Player[id][Logined] = 1;
  s_Player[id][InProgress] = 0;
  show_menu(id, 0, "^n", 1);
  Update_LastLogins(id);
  SQL_InsertLogin(id);
  sk_chat(id, "Üdv ^4%s^1(^4#%i^1), ^3sikeresen^1 bejelentkeztél a(z) ^3%s^1(^4#%i^1) szerverünkre! Jó játékot kívánunk!", s_Player[id][gUsername], s_Player[id][gId], ServerID[s_Player[id][Active]][server_type], ServerID[s_Player[id][Active]][server_id])
  ChooseTeam(id);
  if(task_exists(id+DEMO_TASK_OFFSET))
    remove_task(id+DEMO_TASK_OFFSET);
  set_task(5.0, "Demo", id+DEMO_TASK_OFFSET);

}
public ChooseTeam(id)
{
  new iPlayers[32], iNumT, iNumCTs, iNumSpec, Menu[512], MenuKey
  get_players(iPlayers, iNumT, "che", "TERRORIST")
  get_players(iPlayers, iNumCTs, "che", "CT")
  get_players(iPlayers, iNumSpec, "che", "SPECTATOR")
  new CsTeams:teams = cs_get_user_team(id) 

  add(Menu, 511, fmt("[\rHerBoy \d- \rSystems\w] \y» ^n\wVálassz egy csapatot!^n^n"));

  add(Menu, 511, fmt("\w[\r1\w] \rTerrorista \ycsapat \w[\r%i\w]^n", iNumT));
  add(Menu, 511, fmt("\w[\r2\w] \rTerrorelhárító \ycsapat \w[\r%i\w]^n^n",iNumCTs));

  if(teams == CS_TEAM_SPECTATOR || teams == CS_TEAM_UNASSIGNED)
    add(Menu, 511, fmt("\w[\r5\w] \yAutomatikus csapatválasztás^n"));

  add(Menu, 511, fmt("\w[\r6\w] \yNéző \w[\r%i\w]^n",iNumSpec));

  if(teams != CS_TEAM_UNASSIGNED)
    add(Menu, 511, fmt("^n\w[\r0\w] \rKilépés a menüből.^n"));

  add(Menu, 511, fmt("^n\wwww.herboy.hu @ 2018-2022^n^n"));

  MenuKey = (1<<0 | 1<<1 | 1<<2 | 1<<3 | 1<<4 | 1<<5 | 1<<6 | 1<<7 | 1<<8 | 1<<9);
  show_menu(id, MenuKey, Menu, -1, "TEAMMENU");
  return PLUGIN_CONTINUE
}

public ChooseTeamh(id, MenuKey)
{
  new CsTeams:teams = cs_get_user_team(id) 
  MenuKey++;
  switch(MenuKey)
  {
    case 1: 
    {
      engclient_cmd(id, "jointeam", "1")
      engclient_cmd(id, "joinclass", "2")
      if(teams == CS_TEAM_UNASSIGNED && s_Player[id][SwitchedTeam] == 0) 
      {
        s_Player[id][SwitchedTeam] = 1;
        set_member(id, m_iJoiningState, GETINTOGAME);
      }
    }
    case 2: 
    {
      engclient_cmd(id, "jointeam", "2")
      engclient_cmd(id, "joinclass", "2")
      if(teams == CS_TEAM_UNASSIGNED && s_Player[id][SwitchedTeam] == 0) 
      {
        s_Player[id][SwitchedTeam] = 1;
        set_member(id, m_iJoiningState, GETINTOGAME);
      }
        
      show_menu(id, 0, "^n", 1);
    }
    case 5:
    {
      if(teams == CS_TEAM_SPECTATOR || teams == CS_TEAM_UNASSIGNED)
      {
        engclient_cmd(id, "jointeam", "5")
        engclient_cmd(id, "joinclass", "5")
        show_menu(id, 0, "^n", 1);

        if(teams == CS_TEAM_UNASSIGNED && s_Player[id][SwitchedTeam] == 0) 
        {
          s_Player[id][SwitchedTeam] = 1;
          set_member(id, m_iJoiningState, GETINTOGAME);
        }
      }
    }
    case 6: 
    {
      if(teams == CS_TEAM_UNASSIGNED)
      {
        engclient_cmd(id, "jointeam", "6")
        engclient_cmd(id, "joinclass", "6")
        show_menu(id, 0, "^n", 1);
      }
      else
      {
        user_silentkill(id);
        rg_set_user_team(id, TEAM_SPECTATOR);
        show_menu(id, 0, "^n", 1);
      }
    }
    default:
    {
      if(teams == CS_TEAM_UNASSIGNED)
        ChooseTeam(id);
      else
      {
        show_menu(id, 0, "^n", 1);
        return
      }
    }
  }
}
bool:RegexTester(id, m_string[], RegexText[], NoMatchText[])
{
  new ret, error[128];
  new Regex:regex_handle = regex_match(m_string, RegexText, ret, error, charsmax(error));
  
  switch(regex_handle)
  {
    case REGEX_MATCH_FAIL:
    {
      log_amx("---REGEX MATCH FAIL---");
      log_amx("ERROR:");
      log_amx(error);
      log_amx("RET:");
      // There was an error matching against the pattern
      // Check the {error} variable for message, and {ret} for error code
    }
    case REGEX_PATTERN_FAIL:
    {
      log_amx("---REGEX TATTERN ERROR---");
      log_amx("ERROR:");
      log_amx(error);
      log_amx("RET:");
      // There is an error in your pattern
      // Check the {error} variable for message, and {ret} for error code
    }
    case REGEX_NO_MATCH:
    {
      sk_chat(id, "^4%s", NoMatchText)
    }
    default:
    {
      // Matched m_string {ret} times
      regex_free(regex_handle);
      return true;
      // Free the Regex handle
    }
  }
  regex_free(regex_handle);
  return false;
}
public LoadUtils()
{
  sql_active_check()
}
public SQL_InsertLogin(id)
{
  static Query[20048]
  new Data[1];
  Data[0] = id;
  new sTime[64];
  formatCurrentDateAndTime(sTime, charsmax(sTime));

  formatex(Query, charsmax(Query), "INSERT INTO `herboy_reglogin_log` (`username`, `name`, `steamid`, `ipaddress`, `datetime`, `AutoLogined`, `userid`, `LoginKey`) VALUES (^"%s^", ^"%s^",^"%s^",^"%s^",^"%s^",^"%i^",^"%i^", ^"%s^")", s_Player[id][gUsername], s_Player[id][gName], s_Player[id][gSteamID], s_Player[id][gIP], sTime, s_Player[id][gAutoLogin], s_Player[id][gId], s_Player[id][LoginKey])
  SQL_ThreadQuery(g_SqlTuple, "Query_InsertLoginLog", Query, Data, 2);
}
public Query_InsertLoginLog(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime) {
  if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) {
    log_amx("%s", Error);
    set_fail_state("* Hibas lekerdezes itt, SQL Login Log: %s", Error)
    return;
  }
}
public Update_LastLogins(id)
{
  static Query[20048]
  new Len;
  new sTime[64];
  formatCurrentDateAndTime(sTime, charsmax(sTime));

  Len += formatex(Query[Len], charsmax(Query), "UPDATE `herboy_regsystem` SET ");
  Len += formatex(Query[Len], charsmax(Query)-Len, "LastLoginID = ^"%s^", ", s_Player[id][gSteamID]);
  Len += formatex(Query[Len], charsmax(Query)-Len, "LastLoginIP = ^"%s^", ", s_Player[id][gIP]);
  Len += formatex(Query[Len], charsmax(Query)-Len, "LastLoginIP = ^"%s^", ", s_Player[id][gIP]);
  Len += formatex(Query[Len], charsmax(Query)-Len, "AutoLogin = ^"%i^", ", s_Player[id][gAutoLogin]);
  Len += formatex(Query[Len], charsmax(Query)-Len, "LoginKey = ^"%s^", ", s_Player[id][LoginKey]);
  Len += formatex(Query[Len], charsmax(Query)-Len, "WebToken = ^"%s^", ", s_Player[id][LoginKey]);
  Len += formatex(Query[Len], charsmax(Query)-Len, "LastLoginName = ^"%s^", ", s_Player[id][gName]);
  Len += formatex(Query[Len], charsmax(Query)-Len, "LastLoginDate = ^"%s^", ", sTime);
  Len += formatex(Query[Len], charsmax(Query)-Len, "Active = ^"%i^" ", s_Player[id][Active]);
  Len += formatex(Query[Len], charsmax(Query)-Len, "WHERE `id` =	%d;", s_Player[id][gId]);

  SQL_ThreadQuery(g_SqlTuple, "QueryUpdateLastLogins", Query);
}
public Update_Disconnect(id)
{
  static Query[20048]
  new Len;
  new sTime[64];
  formatCurrentDateAndTime(sTime, charsmax(sTime));

  Len += formatex(Query[Len], charsmax(Query), "UPDATE `herboy_regsystem` SET ");
  Len += formatex(Query[Len], charsmax(Query)-Len, "Active = ^"0^" ");
  Len += formatex(Query[Len], charsmax(Query)-Len, "WHERE `id` =	%d;", s_Player[id][gId]);

  SQL_ThreadQuery(g_SqlTuple, "QueryUpdateLastLogins", Query);
}
public QueryUpdateLastLogins(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime)
{
  if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) 
  {
    log_amx("Error from Profiles:");
    log_amx("%s", Error);
    return;
  }
}
public client_disconnected(id)
{
  if(is_user_bot(id) || is_user_hltv(id) || !is_user_connected(id))
    return;

  if(s_Player[id][Logined])
    Update_Disconnect(id);
}
public client_putinserver(id)
{
  if(is_user_bot(id) || is_user_hltv(id) || !is_user_connected(id))
    return;

  CheckMenu(id)
  set_member(id, m_iJoiningState, JOINED);
  get_user_name(id, s_Player[id][gName], 33)
  get_user_authid(id, s_Player[id][gSteamID], 33)
  get_user_ip(id, s_Player[id][gIP], 33, 1)
  s_Player[id][gAutoLogin] = 1;
  s_Player[id][gUsername][0] = EOS;
  s_Player[id][gPassword][0] = EOS;
  s_Player[id][gPasswordAgain][0] = EOS;
  s_Player[id][gPasswordHash][0] = EOS;
  s_Player[id][gEmail][0] = EOS;
  s_Player[id][Active] = 0;
  AllowedForLoginPanel[id] = 0;
  s_Player[id][Logined] = 0;
  s_Player[id][InProgress] = 0;
  s_Player[id][SwitchedTeam] = 0;
  CreateHerBoyProfile(id);
  SQL_CheckSteamIDAccount(id);
}
public CreateHerBoyProfile(id)
{
  static Query[20048]
  new Data[1];
  Data[0] = id;

  formatex(Query, charsmax(Query), "SELECT * FROM `herboy` WHERE STEAMID = ^"%s^" LIMIT 1;", s_Player[id][gSteamID])
  SQL_ThreadQuery(g_SqlTuple, "QueryLoadUser1", Query, Data, 1);
}
public QueryLoadUser1(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime)
{
  if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED)
  {
    log_amx("%s", Error);
    set_fail_state("* Hibas lekerdezes itt, LoadUser: %s", Error)
    return;
  }
  else
  {
    new id = Data[0];
    
    if(SQL_NumRows(Query) > 0)
    {
      s_Player[id][gId] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "ID"));
    }
    else
      CreateProfile(id)
  }
}
public CreateProfile(id)
{
  static Query[20048]
  new Data[1];
  Data[0] = id;
  formatex(Query, charsmax(Query), "INSERT INTO `herboy` (`STEAMID`, `IP`, `Nev`) VALUES (^"%s^", ^"%s^", ^"%s^");", s_Player[id][gSteamID], s_Player[id][gIP], s_Player[id][gName]);
  SQL_ThreadQuery(g_SqlTuple, "QueryInsertProfile", Query, Data, 1);
}
public QueryInsertProfile(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime){
  if( FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED ){
    log_amx("%s", Error);
    set_fail_state("* Hibas lekerdezes itt, LoadUser: %s", Error)
    return;
  }
  else{
    new id = Data[0];
  
    CreateHerBoyProfile(id);
  }
}
public write_demo_info(id, info[])
{
  if(is_user_connected(id))
  {
    message_begin(MSG_ONE, SVC_SENDEXTRAINFO, _, id)
    write_string(info)
    write_byte(0)
    message_end()
  }
}

public Demo(id){
  id -= DEMO_TASK_OFFSET;
  client_cmd(id, "record HerBoy");
  if(task_exists(id+DEMO_TASK_DETAIL))
    remove_task(id+DEMO_TASK_DETAIL);
  set_task(10.0, "DemoDetail", id+DEMO_TASK_DETAIL);

}
public DemoDetail(id){
  id -= DEMO_TASK_DETAIL;
  
  new user_message[64];
  formatex(user_message,charsmax(user_message),"%s%i","HRBY:ID:", s_Player[id][gId]);
  write_demo_info(id, user_message);
}
public sql_active_check()
{
  new szQuery[2048]
  new len = 0
  
  len += format(szQuery[len], 2048, "UPDATE herboy_regsystem SET ")
  len += format(szQuery[len], 2048-len,"Active = '0' ")
  len += format(szQuery[len], 2048-len,"WHERE Active = '%d'", server)
  
  SQL_ThreadQuery(g_SqlTuple,"sql_active_check_thread", szQuery)
}

public sql_active_check_thread(FailState,Handle:Query,Error[],Errcode,Data[],DataSize)
{
  if(FailState == TQUERY_CONNECT_FAILED)
    return set_fail_state("[ *HIBA* ] NEM LEHET KAPCSOLODNI AZ ADATBAZISHOZ!")
  else if(FailState == TQUERY_QUERY_FAILED)
    return set_fail_state("[ *HIBA* ] A LEKERDEZES MEGSZAKADT!")
  
  if(Errcode)
    return log_amx("[ *HIBA*3 ] PROBLEMA A LEKERDEZESNEL! ( %s )",Error)
  
  return PLUGIN_CONTINUE
}
