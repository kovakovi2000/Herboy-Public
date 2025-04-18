#include <amxmodx>
#include <cstrike>
#include <fakemeta>
#include <hamsandwich>
#include <regex>
#include <engine>
#include <sqlx>

#define KESZITO "Shedi"
#define SEGITO "Kova"
#define PLUGINNAME "SK Regisztrációs rendszer"
#define VERZIOSZAM "1.1"
#define HASHSIZE 256

#define onactive 1
#define offactive 0

new const Prefix[] = "\w[.:SKA:.]";
new const Stars[] = "*******************************";
new const ChatPrefix[] = "^4[.:SKA:.] ^3»";
new const DemoName[] = "ska_demo"

new const tablanev[] = "ska_register";

static szQuery[10048];
new const SQL_INFO[][] = { "IP", "username", "Pw", "DB name" };

new String[121], AutoLogin[33];
new g_screenfade, g_Maxplayers;
new fwd_updatecmd, fwd_loadcmd, fwd_loadcmd1;

new Handle:g_SqlTuple;
enum _:player_prop
{
    steamid[32],
    ip[32],
    name[32],
    adminname[32],
    registerip[32],
    StarsOff,
    AccountId,
    Language,
    LoggedIn,
    InProgress,Active,
    RegOrLogin,
    IsBanned,
    BannedReason[32],
    Password[32],
    PasswordAgain[32],
    PasswordHash[HASHSIZE],
    StaredPassword[32],
    StaredPassAgain[32],
    Username[32],
    PINCode[4],
    SQLPINCode[4]
}
new Player[33][player_prop];
enum _:sqlupdates
{
    S_Ban,
    S_BanReason[32],
    S_BanName,
    S_ArgInt
}
new BanSystem[33][sqlupdates];
new REGEX[][][] =
{
    {"A PINKód csak számokból állhat, és minimum^4 4^1 karakterből!", "PINCode only consist of numbers, minimum^4 4 characters.", "\y[\w%s\y]\d "},
    {"Csak kis és nagybetü + számok (Minimum 4, maximum 16 karakter)", "Small, Large chars and numbers, also in^4 6-16^1 char range!", "\y[\w%s\y]\d "},}
new PIN[][][] =
{
    {"\y[\w%s\y]\d Adj meg egy PIN Kódót!", "\y[\w%s\y]\d Type PIN Code!", "\y[\w%s\y]\d "},
    {"Adj meg egy PINKódót, mert neked nincs!^nA PINkód a fiókod biztonsága érdekében!", "\d Type PINCode, the PINCode protect your account.", "\d "},
    {"Kész", "\d Done", "\d "},
    {"A mostani IP-d nem egyezik a Regisztráltal,ezért írd be a PIN kódót!", "\d This account registered IP does not match yours! Please enter your PIN Code!", ""},
    {"Adj meg egy PINKódót, a fiókod biztonsága érdekében!", "\dType PINCode, the PINCode protect your account.", "\d "},
    {"%s^1 A mostani IP-d nem egyezik a Regisztráltal, vagy nincs PIN kódód. Írd be a pinkódod!", "%s^1 This account registered IP does not match yours! Please enter your PIN Code!", "\d "},
    {"%s^1 Adj meg egy PINKódót, a fiókod biztonsága érdekében!", "%s^1 Type PINCode, the PINCode protect your account.", "\d "},
}
new REGCHAT[][][] =
{
    {"%s^1 Regisztráció folyamatban kérlek várj!", "%s^1 Register in progress, please wait!", ""},
    {"%s^1 Bejelentkezés folyamatban kérlek várj!", "%s^1 Logining in progress, please wait!", ""},
    {"%s^1 Valamit elfelejtettél kitölteni!", "%s^1 You forget to fill something!", ""},
    {"%s^1 Hibás felhasználónév vagy jelszó!", "%s^1 Incorrect username, or password.", ""},
    {"%s^1 Ezzel a felhasználónévvel már regisztráltak!", "%s^1 This username is already registered!", ""},
    {"%s^1 Sikeresen ^4regisztráltál,^1 felhasználónév: ^4%s", "%s^1 Succesfully register, username: ^4%s", ""},
    {"%s^1 Sikeresen ^4bejelentkeztél!^1 Üdv ^3%s^1(^3#^4%i^1), jó játékot!", "%s^1 Succesfully ^4logged in^1! Hi ^3%s(^3#^4%i^1), good game!", ""},
    {"%s^3 Hiba^1 a ^3bejelelentkezés^1 közben, ^3felhasználó^1 már ^3használatban van!", "%s^1 Someting went wrong, someone already in the profil!", ""},
    {"Regisztrálj vagy Jelentkezz be!", "Register or Login!", ""},
    {"%s^1 A két jelszó nem egyezik!", "%s^1 The tpyed two password not equal!", ""},
    {"^"Hibás PINkód!^"", "^"Wrong PINCode^"", ""},
}
new DEMO[][][] =
{
    {"^4%s^1 Demó felvétel elkezdődőtt! ^3Demónév: ^4%s.dem^1.", "%s^1 Demo recording started, ^3Demo name: ^4%s.dem^1.", ""},
    {"^4%s^3 Dátum: ^4 %s^1 |^3 Játékosnév: ^4%s", "%s^1 Date: ^4 %s^1 |^3 PlayerName: ^4%s", ""},
}
new NYELV[][][] =
{
    {"Nyelv: \yMagyar\d | English | Românesc", "Language: \dMagyar | \yEnglish\d | Românesc", "Limba: \dMagyar | English | \yRomânesc"}
}
new REGMENURESZ[][][] =
{
    {"Felhasználónév: \r%s", "Username: \r%s", "Username: \r%s"},
    {"Jelszó: \r%s", "Password: \r%s", "Password: \r%s"},
    {"Jelszó újra: \r%s", "Password again: \r%s", "Password again: \r%s"},
    {"\yRegisztráció", "\yRegister", "\yRegister"},
    {"\yBejelentkezés", "\yLogin", "\yLogin"},
    {"Jelszó Csillagozás \r[BE]", "Register Stairs \r[ON]", ""},
    {"Jelszó Csillagozás \d[KI]", "Register Stairs \d[OFF]", ""}

}
new REGMENU[][][] = 
{
    {"\y[\w%s\y]\d Regisztrálj vagy Jelentkezz be!", "\y[\w%s\y]\d Register or Login!", "\y[\w%s\y]\d Înscrieți-vă sau conectați-vă!"},
    {"Regisztráció", "Register", "Inregistrare"},
    {"Bejelentkezés^n", "Login^n", "Autentificare^n"},
    {"\y[\w%s\y]\d Regisztrációs menü", "\y[\w%s\y]\d Register menu", "\y[\w%s\y]\d Meniu de înregistrare"},
    {"\y[\w%s\y]\d Bejelentkezés menü", "\y[\w%s\y]\d Login menu", "\y[\w%s\y]\d Meniu de autentificare"}
    
}
public plugin_init()
{
    register_plugin(PLUGINNAME, VERZIOSZAM, KESZITO);
    register_impulse(201, "control");
    
    register_clcmd("PIN", "get_PIN");
    register_clcmd("Username", "get_Username");
    register_clcmd("Pass", "get_Password");
    register_concmd("bn_ban_account", "CmdBanAccount", _, "<#id> <tiltas/oldas>")
    register_clcmd("PassAgain", "get_PasswordAgain");
    fwd_loadcmd=CreateMultiForward("Load_User_Data", ET_IGNORE, FP_CELL)
    fwd_loadcmd1=CreateMultiForward("Load_User_Weapons", ET_IGNORE, FP_CELL)
    fwd_updatecmd=CreateMultiForward("Update_User_Data", ET_IGNORE, FP_CELL)
    g_Maxplayers = get_maxplayers();
    g_screenfade = get_user_msgid("ScreenFade")
}
public plugin_natives()
{
    register_native("ska_get_user_id","native_sh_get_user_id",1)
    register_native("ska_is_user_logged","native_sh_get_user_logged",1)
}
public native_sh_get_user_id(index)
{
	return Player[index][AccountId];
}
public native_sh_get_user_logged(index)
{
	return Player[index][LoggedIn];
}
public control(id)
{
    if(!Player[id][LoggedIn])
        ChooseMenu(id);
}
public CmdBanAccount(id, level, cid){

	new Arg1[32], Arg2[32], Arg3[32], Arg_Int[2];
	
	read_argv(1, Arg1, charsmax(Arg1));
	read_argv(2, Arg2, charsmax(Arg2));
	read_argv(3, Arg3, charsmax(Arg3));

	Arg_Int[0] = str_to_num(Arg1);
	Arg_Int[1] = str_to_num(Arg2);
	
	if(Arg_Int[0] < 1)
		return PLUGIN_HANDLED;	
	
	new Banned;
	
	if(Arg_Int[1] == 0)
		Banned = 0;
	else
		Banned = 1;
	
	new Query[512], Data[2], Is_Online = Check_Id_Online(Arg_Int[0]);
	
	Data[0] = id;
	Data[1] = get_user_userid(id);

	formatex(Query, charsmax(Query), "UPDATE `ska_register` SET `Banned` = %d WHERE `Id` = %d;", Banned, Arg_Int[0]);

	SQL_ThreadQuery(g_SqlTuple, "QuerySetData", Query, Data, 2);
	
	if(Is_Online){
	server_cmd("kick #%d ^"A fiókod véglegesen ki lett tíltva a szerverről.^"", get_user_userid(Is_Online));
	if(Arg_Int[1] > 0)
	{
	client_print_color(0, print_team_default, "^3[^4PerFecT^3]^1 Játékos: ^3%s^1(^3#^1%i^1) fiókja ki lett tíltva a szerverről, ^3örökre.", Player[Is_Online][name], Arg_Int[0]);
	client_print_color(0, print_team_default, "^3[^4PerFecT^3]^1 ^3Adminisztrátor: ^4%s^1(^3#^1%i^1) által.", Player[id][name], Player[id][AccountId]);
	}
	else
	{
	client_print_color(0, print_team_default, "^3[^4PerFecT^3]^1 Játékos: ^3-^1(^3#^1%i^1) fiókja feloldásra került.", Arg_Int[0]);
	client_print_color(0, print_team_default, "^3[^4PerFecT^3] ^3Adminisztrátor: ^4%s^1(^3#^1%i^1) által.", Player[id][name], Player[id][AccountId]);
	}
	}
	else{
	if(Arg_Int[1] > 0)
	{
	client_print_color(0, print_team_default, "^3[^4PerFecT^3]^1 Játékos: ^3-^1(^3#^1%i^1) fiókja ki lett tíltva a szerverről, ^3örökre.", Arg_Int[0]);
	client_print_color(0, print_team_default, "^3[^4PerFecT^3] ^3Adminisztrátor: ^4%s^1(^3#^1%i^1) által.", Player[id][name], Player[id][AccountId]);
	}
	else
	{
	client_print_color(0, print_team_default, "^3[^4PerFecT^3]^1 Játékos: ^3-^1(^3#^1%i^1) fiókja feloldásra került.", Arg_Int[0]);
	client_print_color(0, print_team_default, "^3[^4PerFecT^3] ^3Adminisztrátor: ^4%s^1(^3#^1%i^1) által.", Player[id][name], Player[id][AccountId]);	
	}
	}
		
	return PLUGIN_HANDLED;
}
stock Check_Id_Online(id)
{
	for(new idx = 1; idx < g_Maxplayers; idx++)
	{
		if(!is_user_connected(idx) || !Player[idx][LoggedIn])
			continue;
		
		if(Player[idx][AccountId] == id)
			return idx;
	}
	return 0;
}
static FrameCall;
public server_frame()
{
	if(FrameCall < 500)
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
		if(Player[id][LoggedIn] == 0)
		{
			formatex(String, charsmax(String), REGCHAT[8][Player[id][Language]]);
			client_print(id, print_center, String);
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
public ChooseMenu(id)
{
    formatex(String, charsmax(String), REGMENU[0][Player[id][Language]], Prefix);
    new menu = menu_create(String, "ChooseMenu_h");

    menu_additem(menu, REGMENU[1][Player[id][Language]], "1", 0);
    menu_additem(menu, REGMENU[2][Player[id][Language]], "3", 0);

    format(String, charsmax(String), NYELV[0][Player[id][Language]]);
    menu_additem(menu, String, "6", 0);

    menu_display(id, menu, 0);
    return PLUGIN_HANDLED;
}
public ChooseMenu_h(id, menu, item)
{
	new data[9], szName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
	new key = str_to_num(data);
	
	switch(key)
        {
            case 1:
            {
            RegisterMenu(id)
            Player[id][RegOrLogin] = 1;
            }
            case 3:
            {
            LoginMenu(id);
            Player[id][RegOrLogin] = 2;
            }
            case 6:
            {   
            if(Player[id][Language] == 0)
            {
                Player[id][Language] = 1;
            }
            else 
            {
                Player[id][Language] = 0;
            }
            ChooseMenu(id);
            }
        }
}
public RegisterMenu(id)
{
	formatex(String, charsmax(String), REGMENU[3][Player[id][Language]], Prefix);
	new menu = menu_create(String, "RegisterMenu_h");
	
	format(String, charsmax(String), REGMENURESZ[0][Player[id][Language]], Player[id][Username])
	menu_additem(menu, String, "1", 0);
	if(Player[id][StarsOff] == 0)
	{
	format(String, charsmax(String), REGMENURESZ[1][Player[id][Language]], Player[id][StaredPassword]);
	menu_additem(menu, String, "2", 0);
	}
	else
	{
	format(String, charsmax(String), REGMENURESZ[1][Player[id][Language]], Player[id][Password])
	menu_additem(menu, String, "2", 0);
	}
	if(Player[id][StarsOff] == 0)
	{
	format(String, charsmax(String), REGMENURESZ[2][Player[id][Language]], Player[id][StaredPassAgain])
	menu_additem(menu, String, "3", 0);
	}
	else
	{
	format(String, charsmax(String), REGMENURESZ[2][Player[id][Language]], Player[id][PasswordAgain])
	menu_additem(menu, String, "3", 0);
	}

	menu_additem(menu, REGMENURESZ[3][Player[id][Language]], "4", 0);
	menu_addblank2(menu);
	if(Player[id][StarsOff] == 0)
	{
	format(String, charsmax(String), REGMENURESZ[5][Player[id][Language]])
	menu_additem(menu, String, "5", 0);
	}
	else
	{
	format(String, charsmax(String), REGMENURESZ[6][Player[id][Language]])
	menu_additem(menu, String, "5", 0)
	}
	format(String, charsmax(String), NYELV[0][Player[id][Language]]);
	menu_additem(menu, String, "6", 0);
	
	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}
public RegisterMenu_h(id, menu, item)
{
	new data[9], szName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
	new key = str_to_num(data);

	switch(key)
    {
        case 1:
        {
        client_cmd(id, "messagemode Username"); 
        }
        case 2:
        {
        client_cmd(id, "messagemode Pass");
        
        }
        case 3: 
        {
        client_cmd(id, "messagemode PassAgain");
        }
        case 4:
        {
        Player[id][RegOrLogin] = 1;
        RegLog(id);
        }
        case 5:
        {
	if(Player[id][StarsOff])
	 {
	   Player[id][StarsOff] = 0;
	   RegisterMenu(id);
	  }
	else
	 {
	   Player[id][StarsOff] = 1;
	   RegisterMenu(id);
	  }
        }
        case 6:
        {
	if(Player[id][Language] == 0)
	{
		Player[id][Language] = 1;
	}
	else 
	{
		Player[id][Language] = 0;
	}
	RegisterMenu(id);
        }
        }
}
public LoginMenu(id)
{
	formatex(String, charsmax(String), REGMENU[4][Player[id][Language]], Prefix);
	new menu = menu_create(String, "LoginMenu_h");
	
	format(String, charsmax(String), REGMENURESZ[0][Player[id][Language]], Player[id][Username])
	menu_additem(menu, String, "1", 0);
	
	if(Player[id][StarsOff] == 0)
	{
	format(String, charsmax(String), REGMENURESZ[1][Player[id][Language]], Player[id][StaredPassword]);
	menu_additem(menu, String, "2", 0);
	}
	else
	{
	format(String, charsmax(String), REGMENURESZ[1][Player[id][Language]], Player[id][Password])
	menu_additem(menu, String, "2", 0);
	}
	menu_addblank2(menu);
	menu_additem(menu, REGMENURESZ[4][Player[id][Language]], "3", 0);
	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}
public LoginMenu_h(id, menu, item)
{
	new data[9], szName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
	new key = str_to_num(data);

	switch(key)
    {
        case 1:
        {
        client_cmd(id, "messagemode Username"); 
        }
        case 2:
        {
        client_cmd(id, "messagemode Pass");
        }
        case 3:
        {
        Player[id][RegOrLogin] = 2;
        RegLog(id);
        }
        case 5:
        {
        if(Player[id][StarsOff])
        {
            Player[id][StarsOff] = 0;
            LoginMenu(id);
        }
        else
        {
            Player[id][StarsOff] = 1;
            LoginMenu(id);
        }
        }
        case 6:
        {
           if(Player[id][Language] == 0)
           {
		Player[id][Language] = 1;
           }
           else 
           {
		Player[id][Language] = 0;
           }
           LoginMenu(id);
        }
    }
}
public get_Username(id)
{
    new Arg[32];
    read_argv(1, Arg, charsmax(Arg));
    if(RegexTester(id, Arg, "^^[a-zA-Z0-9]{4,16}+$", REGEX[1][Player[id][Language]]))
    {   
        copy(Player[id][Username], 32, Arg);
    }
  
    if(Player[id][RegOrLogin] == 1)
        RegisterMenu(id);
    else 
        LoginMenu(id);
}
public get_Password(id)
{
    new Arg[32];
    read_argv(1, Arg, charsmax(Arg));
    if(RegexTester(id, Arg, "^^[a-zA-Z0-9]{4,16}+$", REGEX[1][Player[id][Language]]))
    {
        copy(Player[id][Password], 32, Arg);
    }
    formatex(Player[id][StaredPassword], strlen(Arg), "%s", Stars);
    if(Player[id][RegOrLogin] == 1)
        RegisterMenu(id);
    else 
        LoginMenu(id);
	
    new hash[256];
    hash_string(Arg, Hash_Keccak_512, hash, charsmax(hash));
    copy(Player[id][PasswordHash], HASHSIZE, hash);
}
public get_PasswordAgain(id)
{
    new Arg[32];
    read_argv(1, Arg, charsmax(Arg));
    if(RegexTester(id, Arg, "^^[a-zA-Z0-9]{4,16}+$", REGEX[1][Player[id][Language]]))
        copy(Player[id][PasswordAgain], 32, Arg);

    formatex(Player[id][StaredPassAgain], strlen(Arg), "%s", Stars);
    if(Player[id][RegOrLogin] == 1)
        RegisterMenu(id);
    else 
        LoginMenu(id);
}
public RegLog(id)
{
    if(Player[id][RegOrLogin] == 1)
    { 
        if(equali(Player[id][Username], "") || equali(Player[id][Password],""))
        {
            client_print_color(id, print_team_default, REGCHAT[2][Player[id][Language]], ChatPrefix);
            Player[id][RegOrLogin] = 0;
            return;
        }
        if(!equal(Player[id][Password], Player[id][PasswordAgain]))
        {
            client_print_color(id, print_team_default, REGCHAT[9][Player[id][Language]], ChatPrefix);
            Player[id][RegOrLogin] = 0;
            return;
        }
        else
        {
            client_print_color(id, print_team_default, REGCHAT[0][Player[id][Language]], ChatPrefix);
            Player[id][InProgress] = 1;
            sql_account_check(id);
        }
    }
    if(Player[id][RegOrLogin] == 2)
    {
        if(equali(Player[id][Username], "") || equali(Player[id][Password],""))
        {
            client_print_color(id, print_team_default, REGCHAT[2][Player[id][Language]], ChatPrefix);
            Player[id][RegOrLogin] = 0;
            return;
        }
        else 
        {
            client_print_color(id, print_team_default, REGCHAT[1][Player[id][Language]], ChatPrefix);
            Player[id][InProgress] = 1;
            sql_account_check(id);
        } 
    }
}
public sql_account_check(id)
{
	new len = 0

	new a[191]
	
	format(a, 190, "%s", Player[id][Username])
	
	replace_all(a, 190, "\", "\\")
	replace_all(a, 190, "'", "\'") 
	
	len += format(szQuery[len], 2048, "SELECT * FROM %s ", tablanev)
	len += format(szQuery[len], 2048-len,"WHERE Username = '%s'", a)
	
	new szData[2];
	szData[0] = id;
	szData[1] = get_user_userid(id);
	
	SQL_ThreadQuery(g_SqlTuple,"sql_account_check_thread", szQuery, szData, 2)
}

public sql_account_check_thread(FailState,Handle:Query,Error[],Errcode,szData[],DataSize)
{
if(Errcode)
{
	log_amx("[ *HIBA* ] PROBLEMA A LEKERDEZESNEL! ( %s )",Error)
	return 
}
if(FailState == TQUERY_CONNECT_FAILED)
{
	set_fail_state("[ *HIBA* ] NEM LEHET KAPCSOLODNI AZ ADATBAZISHOZ!")
	return 
}
else if(FailState == TQUERY_QUERY_FAILED)
{
	set_fail_state("[ *HIBA* ] A LEKERDEZES MEGSZAKADT!")
	return 
}

new id = szData[0];

if (szData[1] != get_user_userid(id))
	return;

new iFound = SQL_NumRows(Query)
new Float:randomtime = random_float(1.00, 6.00)

if(Player[id][RegOrLogin] == 1)
{
	if(iFound > 0)
	{
		client_print_color(id, print_team_default, REGCHAT[4][Player[id][Language]], ChatPrefix);
		Player[id][InProgress] = 0;
		RegisterMenu(id);
	}
	else 
		sql_accountcreate(id);
}
if(Player[id][RegOrLogin] == 2)
{
	if(iFound == 0)
	{
		client_print_color(id, print_team_default, REGCHAT[3][Player[id][Language]], ChatPrefix);
		Player[id][InProgress] = 0;
		LoginMenu(id);
	}
	else  
	sql_account_load(id)
		
}
}
public sql_accountcreate(id)
{
	new len = 0
	
	new sTime[9], sDate[11], sDateAndTime[32];
	get_time("%H:%M:%S", sTime, 8 ); get_time("%Y/%m/%d", sDate, 11);
	formatex(sDateAndTime, 31, "%s %s", sDate, sTime);
	
	len += format(szQuery[len], 2048, "INSERT INTO %s ", tablanev)
	len += format(szQuery[len], 2048-len,"(Username,Password,RegistrationIP,RegistrationID,RegistrationName, RegistrationDate) VALUES(^"%s^", ^"%s^", ^"%s^",^"%s^",^"%s^",^"%s^")", Player[id][Username],Player[id][PasswordHash], Player[id][ip], Player[id][steamid], Player[id][name], sDateAndTime)
	
	new szData[2];
	szData[0] = id;
	szData[1] = get_user_userid(id);
	
	SQL_ThreadQuery(g_SqlTuple,"sql_account_thread", szQuery, szData, 2)
}
public sql_account_thread(FailState,Handle:Query,Error[],Errcode,szData[],DataSize)
{
    if(Errcode)
    {
        log_amx("[ *HIBA* ] PROBLEMA A LEKERDEZESNEL! ( %s )",Error)
        return 
    }

    if(FailState == TQUERY_CONNECT_FAILED)
    {
        set_fail_state("[ *HIBA* ] NEM LEHET KAPCSOLODNI AZ ADATBAZISHOZ!")
        return 
    }
    else if(FailState == TQUERY_QUERY_FAILED)
    {
        set_fail_state("[ *HIBA* ] A LEKERDEZES MEGSZAKADT!")
        return 
    }
    new id = szData[0];
    if (szData[1] != get_user_userid(id))
    return;

    client_print_color(id, print_team_default, REGCHAT[5][Player[id][Language]], ChatPrefix, Player[id][Username]);
    Player[id][InProgress] = 0;
    Player[id][RegOrLogin] = 0;
    LoginMenu(id);
    return;
}
public sql_account_load(id)
{
    new len = 0

    len += format(szQuery[len], 2048, "SELECT * FROM %s ", tablanev)
    len += format(szQuery[len], 2048-len,"WHERE Username = ^"%s^"", Player[id][Username])

    new szData[2];
    szData[0] = id;
    szData[1] = get_user_userid(id);

    SQL_ThreadQuery(g_SqlTuple,"sql_account_load_thread", szQuery, szData, 2)
}

public sql_account_load_thread(FailState,Handle:Query,Error[],Errcode,szData[],DataSize) 
{
    if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED)
    {
        log_amx("%s", Error);
        return;
    }
    else
    {
        new id = szData[0];

        if (szData[1] != get_user_userid(id))
            return;

        new szSqlPassword[HASHSIZE]
        SQL_ReadResult(Query, 2, szSqlPassword, HASHSIZE)

        if(equal(Player[id][PasswordHash], szSqlPassword))
        {
            new szSqlIP[32]
            SQL_ReadResult(Query, 4, szSqlIP, 32)

            Player[id][IsBanned] = SQL_ReadResult(Query, 13)

            if(Player[id][IsBanned] > 0)
            {
                client_print_color(id, print_team_default, "^4%s^1 Ez a fiók ki van ^3tíltva^1 a szerverről, ^4véglegesen.", ChatPrefix);
                client_print_color(id, print_team_default, "^4%s^1 Ha fellebbezni szeretnél, keress fel egy ^3FőAdmin^1-t vagy egy ^3Tulajdonos^1-t.", ChatPrefix);
                Player[id][InProgress] = 0;
                return;
            }

            Player[id][Active] = SQL_ReadResult(Query, 7)

            if (Player[id][Active] > 0)
            {
                client_print_color(id, print_team_default, REGCHAT[7][Player[id][Language]], ChatPrefix);
                LoginMenu(id);
                Player[id][InProgress] = 0;
                return;
            }
            Player[id][Active] = 1;

            Player[id][AccountId] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Id"));
            Player[id][SQLPINCode] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "PIN"));

            /*
            if(Player[id][SQLPINCode] == 0)
            {
                PinCodeCreatorMenu(id);
                client_print_color(id, print_team_default, PIN[6][Player[id][Language]], ChatPrefix);
                return;
            }
            if(!equal(szSqlIP, Player[id][ip]))
            {
                PinCodeCreatorMenu(id);
                client_print_color(id, print_team_default, PIN[5][Player[id][Language]], ChatPrefix);
                return;
            }
            */
		client_print_color(id, print_team_default, REGCHAT[6][Player[id][Language]], ChatPrefix, Player[id][name], Player[id][AccountId]);
		Player[id][RegOrLogin] = 0;
		Player[id][InProgress] = 0;
		Player[id][LoggedIn] = 1;
		new fwdloadtestret
		ExecuteForward(fwd_loadcmd,fwdloadtestret,id);
		new fwdloadtestret1
		ExecuteForward(fwd_loadcmd1,fwdloadtestret1,id);
		Start_Logged_Demo(id);
        //set_user_info(id, "perfectusername", Player[id][Username]);
        //set_user_info(id, "perfecthash", Player[id][PasswordHash]);
        //client_cmd(id, "setinfo ^"perfectusername^" ^"%s^"", Player[id][Username]);
        //client_cmd(id, "setinfo ^"perfecthash^" ^"%s^"", Player[id][PasswordHash]);
        //client_cmd(id, "setinfo ^"perfectautologin^" ^"0^"");
        engclient_cmd(id, "setinfo autologin 0")
        engclient_cmd(id, "setinfo perfectusername %s", Player[id][Username])
		Update(id, 1);
		Update(id, 4);
           
        }
        else
        {
            client_print_color(id, print_team_default, REGCHAT[3][Player[id][Language]], ChatPrefix);
            Player[id][RegOrLogin] = 0;
            LoginMenu(id);
        }
    }
}
public Start_Logged_Demo(id) {
    new sTime[9], sDate[11], sDateAndTime[32];
    get_time("%H:%M:%S", sTime, 8 );
    get_time("%Y/%m/%d", sDate, 11);
    formatex(sDateAndTime, 31, "%s %s", sDate, sTime);

    client_cmd(id, "stop; record ^"%s.dem^"", DemoName);
    
    client_print_color(id, print_team_default,DEMO[0][Player[id][Language]], ChatPrefix, DemoName);
    client_print_color(id, print_team_default,DEMO[1][Player[id][Language]], ChatPrefix, sDateAndTime, Player[id][name]);
}
public PinCodeCreatorMenu(id)
{
    formatex(String, charsmax(String), PIN[0][Player[id][Language]], Prefix);
    new menu = menu_create(String, "Pin_h");

    if(Player[id][SQLPINCode] == 0)
        formatex(String, charsmax(String), PIN[1][Player[id][Language]]);
    else
        formatex(String, charsmax(String), PIN[3][Player[id][Language]]);
    menu_addtext2(menu, String);
    formatex(String, charsmax(String), "\yPIN: \r%d^n^n", Player[id][PINCode]);
    menu_additem(menu, String, "1",0);
    formatex(String, charsmax(String), PIN[2][Player[id][Language]]);
    menu_additem(menu, String, "2",0);

    menu_display(id, menu, 0);
    return PLUGIN_HANDLED;
}
public Pin_h(id, menu, item)
{
	new data[9], szName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
	new key = str_to_num(data);

	switch(key)
    {
        case 1:
        {
            client_cmd(id, "messagemode PIN");
        }
        case 2:
        {
            if(Player[id][SQLPINCode] == 0)
            {
                Update(id, 2);
                sql_account_load(id);
            }
            else if(equal(Player[id][SQLPINCode], Player[id][PINCode]))
            {
                client_print_color(id, print_team_default, REGCHAT[6][Player[id][Language]], ChatPrefix, Player[id][name], Player[id][AccountId]);
                Player[id][RegOrLogin] = 0;
                Player[id][InProgress] = 0;
                Player[id][LoggedIn] = 1;
                new fwdloadtestret
                ExecuteForward(fwd_loadcmd,fwdloadtestret,id);
                Start_Logged_Demo(id);
                Update(id, 3);
                Update(id, 1);
                Update(id, 4);
            }
            else
                server_cmd("amx_kick #%d ^"Hibás PINKÓD^"", get_user_userid(id));
        }
    }
}
public get_PIN(id)
{
    new Arg[32];
    read_argv(1, Arg, charsmax(Arg));
    if(RegexTester(id, Arg, "^^[1-9]{0,1}[0-9]{4,4}$", REGEX[0][Player[id][Language]]))
    {
        Player[id][PINCode] = str_to_num(Arg);
    }
    PinCodeCreatorMenu(id);
}
public UpdateBan(id)
{
	new Len;
	
	Len += formatex(szQuery[Len], charsmax(szQuery), "UPDATE `%s` SET ", tablanev);
	
	Len += formatex(szQuery[Len], charsmax(szQuery)-Len, "Banned = ^"%i^", ", BanSystem[id][S_Ban]);
	Len += formatex(szQuery[Len], charsmax(szQuery)-Len, "BannedReason = ^"%s^", ", BanSystem[id][S_BanReason]);
	Len += formatex(szQuery[Len], charsmax(szQuery)-Len, "AdminName = ^"%s^", ", BanSystem[id][S_BanName]);
	
	Len += formatex(szQuery[Len], charsmax(szQuery)-Len, "Parameter = '0' WHERE `Id` =  %d;", BanSystem[id][S_ArgInt]);
	
	SQL_ThreadQuery(g_SqlTuple, "QuerySetData", szQuery);

}
public Update(id, UpdateType)
{
new Len;
new sTime[9], sDate[11], sDateAndTime[32];
get_time("%H:%M:%S", sTime, 8 ); get_time("%Y/%m/%d", sDate, 11);
formatex(sDateAndTime, 31, "%s %s", sDate, sTime);

Len += formatex(szQuery[Len], charsmax(szQuery), "UPDATE `%s` SET ", tablanev);

switch(UpdateType)
{
    case 1:
    {
        Len += formatex(szQuery[Len], charsmax(szQuery)-Len, "LastLoggedSteamID = ^"%s^", ", Player[id][steamid]);
        Len += formatex(szQuery[Len], charsmax(szQuery)-Len, "LastLoggedName = ^"%s^", ", Player[id][name]);
        Len += formatex(szQuery[Len], charsmax(szQuery)-Len, "LastLoggedDate = ^"%s^", ", sDateAndTime);
        Len += formatex(szQuery[Len], charsmax(szQuery)-Len, "LastLoggedIP = ^"%s^", ", Player[id][ip]);
    }
    case 2:
    {
        Len += formatex(szQuery[Len], charsmax(szQuery)-Len, "PIN = ^"%i^", ", Player[id][PINCode]);   
    }
    case 3:
    {
        Len += formatex(szQuery[Len], charsmax(szQuery)-Len, "RegistrationIP = ^"%s^", ", Player[id][ip]);
    }
    case 4:
    {
        Len += formatex(szQuery[Len], charsmax(szQuery)-Len, "Active = ^"%i^", ", onactive);
    }
    case 5:
    {
        Len += formatex(szQuery[Len], charsmax(szQuery)-Len, "Active = ^"%i^", ", offactive);
    }
}
	
Len += formatex(szQuery[Len], charsmax(szQuery)-Len, "Parameter = '0' WHERE `Id` =  %d;", Player[id][AccountId]);

SQL_ThreadQuery(g_SqlTuple, "QuerySetData", szQuery);

}
public QuerySetData(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime){
if( FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED )
{
	log_amx("%s", Error);
	return;
}
}
public client_putinserver(id)
{
    GiveDatas(id);
    ResetAccountData(id);
    ResetAccountInfos(id);
}
public client_disconnected(id)
{
    if(Player[id][LoggedIn])
    {
    Update(id, 5);

    Player[id][Active] = 0;
    Player[id][RegOrLogin] = 0;
    Player[id][LoggedIn] = 0;
    

    new fwdupdatetestret
    ExecuteForward(fwd_updatecmd,fwdupdatetestret,id);
    }
}
public ResetAccountData(id)
{
    get_user_info(id, "perfectautologin", AutoLogin[id], 32);
    if(AutoLogin[id] == 1)
    {
        get_user_info(id, "perfectusername", Player[id][Username], charsmax(Player[][Username]));
        get_user_info(id, "perfecthash", Player[id][PasswordHash], charsmax(Player[][PasswordHash]));
    }
    Player[id][AccountId] = 0;
    Player[id][Password] = "";
    Player[id][Username] = "";
    Player[id][StaredPassword] = "";
    Player[id][StaredPassAgain] = "";
    Player[id][PasswordAgain] = "";
    Player[id][PasswordHash] = "";
    Player[id][BannedReason] = "";
    Player[id][IsBanned] = 0;
    Player[id][PINCode] = 0;
}
public ResetAccountInfos(id)
{    
    Player[id][InProgress] = 0;
    Player[id][Language] = 0;
    Player[id][StarsOff] = 0;
    Player[id][LoggedIn] = 0;

}
public GiveDatas(id)
{
    Player[id][name] = "";
    Player[id][steamid] = "";
    Player[id][ip] = "";
    get_user_name(id, Player[id][name], 32);
    get_user_authid(id, Player[id][steamid], 32);
    get_user_ip(id, Player[id][ip], 32);
}

/**
*   Input:
*       id = the user id
*       m_string[] = The string what need to test
*       RegexText[] = The regex pattern
*       NoMatchText[] = If the regex doesn't match this text will be chatprinted to the id
* */
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
            // There was an error matching against the pattern
            // Check the {error} variable for message, and {ret} for error code
        }
        case REGEX_PATTERN_FAIL:
        {
            log_amx("---REGEX TATTERN ERROR---");
            log_amx("ERROR:");
            log_amx(error);
            // There is an error in your pattern
            // Check the {error} variable for message, and {ret} for error code
        }
        case REGEX_NO_MATCH:
        {
            client_print_color(id, print_team_default, "^4%s ^1%s",Prefix, NoMatchText);
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
public plugin_cfg()
{
g_SqlTuple = SQL_MakeDbTuple(SQL_INFO[0], SQL_INFO[1], SQL_INFO[2], SQL_INFO[3]);
createRegTable()  
//createForceLoginTable()
sql_active_check()
}
public sql_active_check()
{
	new szQuery[2048]
	new len = 0
	
	len += format(szQuery[len], 2048, "UPDATE ska_register SET ")
	len += format(szQuery[len], 2048-len,"Active = '0' ")
	len += format(szQuery[len], 2048-len,"WHERE Active = '%d'", onactive)
	
	SQL_ThreadQuery(g_SqlTuple,"sql_active_check_thread", szQuery)
}

public sql_active_check_thread(FailState,Handle:Query,Error[],Errcode,Data[],DataSize)
{
	if(FailState == TQUERY_CONNECT_FAILED)
		return set_fail_state("[ *HIBA* ] NEM LEHET KAPCSOLODNI AZ ADATBAZISHOZ!")
	else if(FailState == TQUERY_QUERY_FAILED)
		return set_fail_state("[ *HIBA* ] A LEKERDEZES MEGSZAKADT!")
	
	if(Errcode)
		return log_amx("[ *HIBA* ] PROBLEMA A LEKERDEZESNEL! ( %s )",Error)
	
	return PLUGIN_CONTINUE
}
public createRegTable()
{
new Len;
Len += formatex(szQuery[Len], charsmax(szQuery), "CREATE TABLE IF NOT EXISTS `%s` ", tablanev);
Len += formatex(szQuery[Len], charsmax(szQuery)-Len, "( ");
Len += formatex(szQuery[Len], charsmax(szQuery)-Len, "`AccountId` INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,");
Len += formatex(szQuery[Len], charsmax(szQuery)-Len, "`Username` varchar(32) NOT NULL,")
Len += formatex(szQuery[Len], charsmax(szQuery)-Len, "`Password` varchar(256) NOT NULL,")
Len += formatex(szQuery[Len], charsmax(szQuery)-Len, "`PIN` INT(4) NOT NULL,")
Len += formatex(szQuery[Len], charsmax(szQuery)-Len, "`RegisterName` varchar(32) NOT NULL,")
Len += formatex(szQuery[Len], charsmax(szQuery)-Len, "`RegisterIP` varchar(32) NOT NULL,")
Len += formatex(szQuery[Len], charsmax(szQuery)-Len, "`RegisterID` varchar(32) NOT NULL,")
Len += formatex(szQuery[Len], charsmax(szQuery)-Len, "`RegisterDate` varchar(32) NOT NULL,")
Len += formatex(szQuery[Len], charsmax(szQuery)-Len, "`Banned` varchar(1) NOT NULL,")
Len += formatex(szQuery[Len], charsmax(szQuery)-Len, "`BannedReason` varchar(32) NOT NULL,")
Len += formatex(szQuery[Len], charsmax(szQuery)-Len, "`Active` INT(1) NOT NULL)")

SQL_ThreadQuery(g_SqlTuple, "createTableThread", szQuery);
}
public createTableThread(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime) {
if(Errcode)
log_amx("[HIBA*] HIBAT DOBTAM: %s",Error);
if(FailState == TQUERY_CONNECT_FAILED)
	set_fail_state("[HIBA*] NEM TUDTAM CSATLAKOZNI AZ ADATBAZISHOZ!");
	else if(FailState == TQUERY_QUERY_FAILED)
		set_fail_state("Query Error");
}
public plugin_end()
{
SQL_FreeHandle(g_SqlTuple);
}
/* 
 if(Player[id][PINCode] == 0)
        {
	        client_print_color(id, print_team_default, "^4%s^1 A bejelentkezeshez megkell adnod egy pinkodot!", ChatPrefix);
            PinCodeCreatorMenu(id);
	        Player[id][PINCode] = 0;
            Player[id][InProgress] = 0;
            return;
        }

*/
