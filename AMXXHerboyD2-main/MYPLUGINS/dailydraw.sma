#include <amxmodx>
#include <amxmisc>
#include <sk_utils>
#include <reapi>
#include <regsystem>
#include <fakemeta>
#include <mod>
#include <fun>
#include <regex>

#define PLUGIN "Daily Draw"
#define VERSION "1.0"
#define AUTHOR "Kova"

#define SETTASK_ID_INBETWEEN 3462263

#define DRAW_PRICE 1.0 // Price for daily draw
#define JACKPOT_PRIZE 5.0 // Prize for jackpot
#define JACKPOT_BASED_POOL JACKPOT_PRIZE*100.0 // Base pool for jackpot
#define DRAW_HOUR 20
#define DRAW_MINUTE 00
#define DRAW_LENGTH 10

#define DRAW_MINIMUM_ENTRY 5
#define JACKPOT_MINIMUM_ENTRY 1

new const MENUPREFIX[] = "\r[\wHerBoy\r] \yOnlyD2 \d~";

new g_iFreezeTime;
new g_ForceTrigger;
new g_ScreenFade;
new g_SyncA, g_SyncB, g_SyncC, g_SyncD;
new g_bIsDailyDraw;

public LoadUtils() {}

new Array:aDaliyEntries_DD;
new Array:aDaliyEntries_DD_names;
new g_tLastDraw_DD;
new Array:aDaliyEntries_DD_winners;
enum _:eDD
{
    DD_ACCOUNTID,
    DD_NAME[33],
    DD_TIME,
    Float:DD_PRICE
}

new Array:aDaliyEntries_JP;
new Array:aDaliyEntries_JP_numbers;
new Array:aDaliyEntries_JP_names;
new g_tLastDraw_JP;
new Float:g_tLastPrize_JP;
new Array:aDaliyEntries_JP_winners;
enum _:eJP
{
    JP_ACCOUNTID,
    JP_NAME[33],
    JP_TIME,
    JP_NUMBER,
    Float:JP_PRIZE
}

public plugin_init() {
    register_plugin(PLUGIN, VERSION, AUTHOR);

    register_clcmd("forcedd", "cmd_force_dailydraw");

    register_clcmd("say", "Hook_Say");

    register_clcmd("say /ddw", "cmd_dailydraw_winners");
    register_clcmd("say /jpw", "cmd_dailyjackpot_winners");

    bind_pcvar_num(get_cvar_pointer("mp_freezetime"),g_iFreezeTime);

    register_event("HLTV", "event_new_round", "a", "1=0", "2=0");
    RegisterHookChain(RG_CBasePlayer_Spawn, "fw_Spawn__post", .post = true); 

    aDaliyEntries_DD = ArrayCreate();
    aDaliyEntries_DD_names = ArrayCreate(33);
    aDaliyEntries_DD_winners = ArrayCreate(eDD);

    aDaliyEntries_JP = ArrayCreate();
    aDaliyEntries_JP_numbers = ArrayCreate();
    aDaliyEntries_JP_names = ArrayCreate(33);
    aDaliyEntries_JP_winners = ArrayCreate(eJP);

    g_ScreenFade = get_user_msgid("ScreenFade");
    g_SyncA = CreateHudSyncObj();
    g_SyncB = CreateHudSyncObj();
    g_SyncC = CreateHudSyncObj();
    g_SyncD = CreateHudSyncObj();
}

public plugin_precache()
{
    precache_generic("sound/Herboynew/jackpot.wav");
}

public plugin_cfg()
{
    LoadDrawsWinners();
    LoadJackpotsWinners();
}

/*
* Load the last 5 winners and the last draw time
*/
public LoadDrawsWinners()
{
    //load the last 5 winners
    static Query[10048];
    formatex(Query, charsmax(Query), "SELECT * FROM `daliy_draws_winners` ORDER BY `time` DESC LIMIT 5");
    SQL_ThreadQuery(m_get_sql(), "LoadDrawsWinnersCallback", Query, _, 0);
}

public LoadDrawsWinnersCallback(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime)
{
    if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) 
    {
        log_amx("[DailyDraw] Error from LoadDrawsWinnersCallback:");
        log_amx("%s", Error);
        return;
    }

    new lastwintime = 0;
    if(SQL_NumRows(Query) > 0) 
    {
        while(SQL_MoreResults(Query))
        {
            new eWinner[eDD];
            eWinner[DD_ACCOUNTID] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "accountid"));
            SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "name"), eWinner[DD_NAME], 33);
            eWinner[DD_TIME] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "time"));
            SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "prize"), eWinner[DD_PRICE]);
            ArrayPushArray(aDaliyEntries_DD_winners, eWinner);

            if(eWinner[DD_TIME] > lastwintime)
                lastwintime = eWinner[DD_TIME];

            SQL_NextRow(Query);
        }
    }

    g_tLastDraw_DD = lastwintime;
    LoadDraws(g_tLastDraw_DD);
}

public LoadDraws(lastwintime)
{
    static Query[10048];
    formatex(Query, charsmax(Query), "SELECT * FROM `daliy_draws` WHERE `time` > %d", lastwintime);
    SQL_ThreadQuery(m_get_sql(), "LoadDrawsCallback", Query, _, 0);
}

public LoadDrawsCallback(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime)
{
    if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) 
    {
        log_amx("[DailyDraw] Error from LoadDrawsCallback:");
        log_amx("%s", Error);
        return;
    }

    if(SQL_NumRows(Query) > 0) 
    {
        while(SQL_MoreResults(Query))
        {
            new accountid = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "accountid"));
            new name[33]; SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "name"), name, 33);
            ArrayPushCell(aDaliyEntries_DD, accountid);
            ArrayPushArray(aDaliyEntries_DD_names, name);

            SQL_NextRow(Query);
        }
    }
}

/*
* Load the last 5 winners and the last draw time
*/
public LoadJackpotsWinners()
{
    //load the last 5 winners
    static Query[10048];
    formatex(Query, charsmax(Query), "SELECT * FROM `dalily_jackpot_winners` ORDER BY `time` DESC LIMIT 5");
    SQL_ThreadQuery(m_get_sql(), "LoadJackpotsWinnersCallback", Query, _, 0);
}

public LoadJackpotsWinnersCallback(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime)
{
    if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) 
    {
        log_amx("[DailyDraw] Error from LoadJackpotsWinnersCallback:");
        log_amx("%s", Error);
        return;
    }

    new lastwintime = 0;
    new Float:lastwinprize = 0.0;
    if(SQL_NumRows(Query) > 0) 
    {
        while(SQL_MoreResults(Query))
        {
            new eWinner[eJP];
            eWinner[JP_ACCOUNTID] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "accountid"));
            SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "name"), eWinner[JP_NAME], 33);
            eWinner[JP_TIME] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "time"));
            eWinner[JP_NUMBER] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "number"));
            SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "prize"), eWinner[JP_PRIZE]);
            ArrayPushArray(aDaliyEntries_JP_winners, eWinner);

            if(eWinner[JP_TIME] > lastwintime)
            {
                lastwintime = eWinner[JP_TIME];
                if(eWinner[JP_ACCOUNTID] == -1)
                    lastwinprize = eWinner[JP_PRIZE] - JACKPOT_BASED_POOL;
                else
                    lastwinprize = 0.0;
            }

            SQL_NextRow(Query);
        }
    }

    g_tLastDraw_JP = lastwintime;
    g_tLastPrize_JP = lastwinprize;
    LoadJackpots(g_tLastDraw_JP);
}

public LoadJackpots(lastwintime)
{
    static Query[10048];
    formatex(Query, charsmax(Query), "SELECT * FROM `dalily_jackpot` WHERE `time` > %d", lastwintime);
    SQL_ThreadQuery(m_get_sql(), "LoadJackpotsCallback", Query, _, 0);
}

public LoadJackpotsCallback(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime)
{
    if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) 
    {
        log_amx("[DailyDraw] Error from LoadJackpotsCallback:");
        log_amx("%s", Error);
        return;
    }

    if(SQL_NumRows(Query) > 0)
    {
        while(SQL_MoreResults(Query))
        {
            new accountid = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "accountid"));
            new name[33]; SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "name"), name, 33);
            new number = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "number"));
            ArrayPushCell(aDaliyEntries_JP, accountid);
            ArrayPushArray(aDaliyEntries_JP_names, name);
            ArrayPushCell(aDaliyEntries_JP_numbers, number);

            SQL_NextRow(Query);
        }
    }
}

public fw_Spawn__post(id)
{
    if(!g_bIsDailyDraw)
        return;

    set_pev(id, pev_flags, pev(id, pev_flags) | FL_FROZEN);
}

public cmd_force_dailydraw(id, level, cid)
{
    new accountid = sk_get_accountid(id);
    if(accountid != 3 && accountid != 1)
        return PLUGIN_HANDLED;
    
    g_ForceTrigger = true;

    console_print(id, "You forced the daily draw event on the next round start.");
    setTime(1);

    return PLUGIN_HANDLED;
}

public cmd_dailydraw_winners(id)
{
    if(!sk_get_logged(id))
    {
        is_user_connected()
        sk_chat(id, "Csak regisztrált és bejeletkezett játékosok tudják ezt használni.");
        return;
    }
    new Float:currDollar = get_user_dollar(id);
    new menu = menu_create(fmt("\d%s \r[ \wNapi Szerencsejáték\r ]^n\rDollárod:\w%3.2f$", MENUPREFIX, currDollar), "cmd_dailydraw_winners_handler");

    //add a pressable button for jackpot buy
    //check if already have
    if(ArrayFindValue(aDaliyEntries_DD, sk_get_accountid(id)) == -1)
        menu_additem(menu, fmt("\rNapi sorsjegy vásárlása \y[\w%3.2f$\y]", DRAW_PRICE), "-1");
    else
        menu_additem(menu, fmt("\rMár vettél ma napi sorsjegyet."), "-2");

    //add a menu for current winnable prize
    new bought_amount = ArraySize(aDaliyEntries_DD);
    new win_history_size = ArraySize(aDaliyEntries_DD_winners);

    if(bought_amount >= DRAW_MINIMUM_ENTRY)
        menu_addtext2(menu, fmt("\wNapi sorsolás nyereménye jelenleg: \y[\w%3.2f$\y]", float(bought_amount)*DRAW_PRICE));
    else
        menu_addtext2(menu, fmt("\wNapi sorsoláshoz %d játékos kell még!", DRAW_MINIMUM_ENTRY-bought_amount));
    
    menu_addblank2(menu)
    for(new i = 0; i < win_history_size; i++)
    {
        new eWinner[eDD];
        ArrayGetArray(aDaliyEntries_DD_winners, i, eWinner);

        new date[12];
        format_time(date, charsmax(date), "%m.%d", eWinner[DD_TIME]);
        menu_addtext2(menu, fmt("\r%s \w| \y%3.2f$ \w| \y%s", date, eWinner[DD_PRICE], eWinner[DD_NAME]));
    }

    //fill in the empty spaces so that exit button is at 10th position
    for(new i = win_history_size+3; i < 9; i++)
        menu_addblank2(menu);

    menu_additem(menu, fmt("%L", id, "GENERAL_MENU_EXIT"), "-3");
    //remove back and next button
    menu_setprop(menu, MPROP_PERPAGE, 0);
    menu_display(id, menu);
}

public cmd_dailydraw_winners_handler(id, menu, item)
{
    if( item == MENU_EXIT )
    {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }

    new data[6], szName[64];
    new access, callback;
    menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
    new key = str_to_num(data);

    switch(key)
    {
        case -1:
        {
            cmd_dailydraw(id);
        }
        case -2:
        {
            sk_chat(id, "Már vettél ma napi sorsjegyet.");
            cmd_dailydraw_winners(id);
        }
        default: {}
    }

    menu_destroy(menu);
    return PLUGIN_HANDLED;
}

public cmd_dailyjackpot_winners(id)
{
    if(!sk_get_logged(id))
    {
        sk_chat(id, "Csak regisztrált és bejeletkezett játékosok tudják ezt használni.");
        return;
    }
    new Float:currDollar = get_user_dollar(id);
    new menu = menu_create(fmt("\d%s \r[ \wJackpot\r ]^n\rDollárod:\w%3.2f$", MENUPREFIX, currDollar), "cmd_dailyjackpot_winners_handler");

    //add a pressable button for jackpot buy
    //check if already have
    new array_index = ArrayFindValue(aDaliyEntries_JP, sk_get_accountid(id));
    if(array_index == -1)
        menu_additem(menu, fmt("\rJackpot sorsjegy vásárlása \y[\w%3.2f$\y]", JACKPOT_PRIZE), "-1");
    else
    {
        menu_additem(menu, fmt("\rMár vettél ma jackpot sorsjegyet. (\w%04d\r)", ArrayGetCell(aDaliyEntries_JP_numbers, array_index)), "-2");
    }

    //add a menu for current winnable prize
    new bought_amount = ArraySize(aDaliyEntries_JP);
    new win_history_size = ArraySize(aDaliyEntries_JP_winners)


    if(bought_amount >= JACKPOT_MINIMUM_ENTRY)
        menu_addtext2(menu, fmt("\wJackpot nyereménye jelenleg: \y[\w%3.2f$\y]", (g_tLastPrize_JP+JACKPOT_BASED_POOL+(bought_amount*JACKPOT_PRIZE))));
    else
        menu_addtext2(menu, fmt("\wJackpot sorsoláshoz %d játékos kell még!", JACKPOT_MINIMUM_ENTRY-bought_amount));
    
    menu_addblank2(menu)
    for(new i = 0; i < win_history_size; i++)
    {
        new eWinner[eJP];
        ArrayGetArray(aDaliyEntries_JP_winners, i, eWinner);
        
        new date[12];
        format_time(date, charsmax(date), "%m.%d", eWinner[JP_TIME]);
        if(eWinner[JP_ACCOUNTID] == -1)
            menu_addtext2(menu, fmt("\r%s \w| \y%3.2f$ \w| \r%s \w| \w%04d", date, eWinner[JP_PRIZE], "-", eWinner[JP_NUMBER]));
        else
            menu_addtext2(menu, fmt("\r%s \w| \y%3.2f$ \w| \y%s \w| \w%04d", date, eWinner[JP_PRIZE], eWinner[JP_NAME], eWinner[JP_NUMBER]));
    }

    //fill in the empty spaces so that exit button is at 10th position
    for(new i = win_history_size+3; i < 9; i++)
        menu_addblank2(menu);

    menu_additem(menu, fmt("%L", id, "GENERAL_MENU_EXIT"), "-3");
    //remove back and next button
    menu_setprop(menu, MPROP_PERPAGE, 0);
    menu_display(id, menu);
}

public cmd_dailyjackpot_winners_handler(id, menu, item)
{
    if( item == MENU_EXIT )
    {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }

    new data[6], szName[64];
    new access, callback;
    menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
    new key = str_to_num(data);

    switch(key)
    {
        case -1:
        {
            cmd_dailyjackpot(id, "");
        }
        case -2:
        {
            sk_chat(id, "Már vettél ma jackpot sorsjegyet.");
            cmd_dailyjackpot_winners(id);
        }
        default: {}
    }

    menu_destroy(menu);
    return PLUGIN_HANDLED;
}

public Hook_Say(id)
{
    new Message[128];
    read_args(Message, charsmax(Message));
    remove_quotes(Message);
    new sArgs[2][33];
    
    if(strfind(Message, " ", false) != -1)
    {
        new len = strlen(Message);
        new pos = strfind(Message, " ", true);
        copy(sArgs[0], pos, Message);
        copy(sArgs[1], len-pos, Message[pos+1]);
    }
    else
    {
        copy(sArgs[0], 32, Message);
    }

    if(equal(sArgs[0], "/dd"))
    {
        cmd_dailydraw(id);
    }
    else if(equal(sArgs[0], "/jp"))
    {
        cmd_dailyjackpot(id, sArgs[1]);
    }

    return PLUGIN_CONTINUE;
}

public cmd_dailydraw(id)
{
    if(!sk_get_logged(id))
    {
        sk_chat(id, "Csak regisztrált és bejeletkezett játékosok tudják ezt használni.");
        return;
    }
    new Float:currDollar = get_user_dollar(id);
    if(currDollar < DRAW_PRICE)
    {
        sk_chat(id, "Nincs elég ^3pénzed^1 a napi sorsjegyhez. ^3Csóró vagy :(");
        return;
    }

    new accountid = sk_get_accountid(id);
    new current_prize = floatround(float(ArraySize(aDaliyEntries_DD))*DRAW_PRICE);
    if(ArrayFindValue(aDaliyEntries_DD, accountid) != -1)
    {
        sk_chat(id, "Már vettél ma sorsjegyet, eddigi tét összesen: ^4[ ^3%d$ ^4]", current_prize);
        return;
    }

    if(g_bIsDailyDraw)
    {
        sk_chat(id, "A sorsolási idő alatt ^3NEM^1 tudsz venni sorsjegyet. ^4[ ^3%02d:%02d - %02d:%02d ^4]", DRAW_HOUR, DRAW_MINUTE, DRAW_HOUR, DRAW_MINUTE+DRAW_LENGTH);
        return;
    }

    new name[33];
    get_user_name(id, name, charsmax(name));
    sk_chat(0, "^3%s^1 vett egy napi sorsjegyet! ^3/dd^1-vel te is vehetsz. Jelenlegi tét: ^4[ ^3%d$ ^4]", name, current_prize);

    static Query[10048];
    static data[1];
    data[0] = id;
    replace_all(name, charsmax(name), "^"", "");
    formatex(Query, charsmax(Query), "INSERT INTO `daliy_draws` (`accountid`, `name`, `time`) VALUES (^"%d^", ^"%s^", ^"%d^")", accountid, name, get_systime());
    SQL_ThreadQuery(m_get_sql(), "QueryCallback_insert_daliy_draws", Query, data, 1);

    /* Table creation command for daliy_draws
    CREATE TABLE `daliy_draws` (
        `id` INT NOT NULL AUTO_INCREMENT,
        `accountid` INT NOT NULL,
        `name` VARCHAR(33) NOT NULL,
        `time` INT NOT NULL,
        PRIMARY KEY (`id`)
    ) ENGINE = InnoDB;
    */
}

public cmd_dailyjackpot(id, sJackpot_number[])
{
    if(!sk_get_logged(id))
    {
        sk_chat(id, "Csak regisztrált és bejeletkezett játékosok tudják ezt használni.");
        return;
    }
    new Float:currDollar = get_user_dollar(id);
    if(currDollar < JACKPOT_PRIZE)
    {
        sk_chat(id, "Nincs elég ^3pénzed^1 a jackpot sorsoláshoz. ^3Csóró vagy :(");
        return;
    }

    new accountid = sk_get_accountid(id);
    new current_prize = floatround((float(ArraySize(aDaliyEntries_JP))*JACKPOT_PRIZE)+JACKPOT_BASED_POOL+g_tLastPrize_JP);
    if(ArrayFindValue(aDaliyEntries_JP, accountid) != -1)
    {
        sk_chat(id, "Már vettél ma jackpot sorsjegyet, eddigi tét összesen: ^4[ ^3%d$ ^4]", current_prize);
        return;
    }

    if(g_bIsDailyDraw)
    {
        sk_chat(id, "A sorsolási idő alatt ^3NEM^1 tudsz venni sorsjegyet. ^4[ ^3%02d:%02d - %02d:%02d ^4]", DRAW_HOUR, DRAW_MINUTE, DRAW_HOUR, DRAW_MINUTE+DRAW_LENGTH);
        return;
    }
    
    trim(sJackpot_number);
    if(regex_match(sJackpot_number, "^^[0-9]{4}$", _, _, _, "i") <= Regex:0)
    {
        sk_chat(id, "Nem megfelelő jackpot számot adtál meg. ^4/jp <4 számjegy> ^1(pl.: ^4/jp 1234^1)");	
        return;
    }

    new iJackpot_number = str_to_num(sJackpot_number);

    if(ArrayFindValue(aDaliyEntries_JP_numbers, iJackpot_number) != -1)
    {
        sk_chat(id, "Ez a szám már foglalt.");
        return;
    }

    new name[33];
    get_user_name(id, name, charsmax(name));
    sk_chat(0, "^3%s^1 vett egy jackpot sorsjegyet! ^3/jp^1-vel te is vehetsz. Jelenlegi tét: ^4[ ^3%d$ ^4]", name, current_prize);

    static Query[10048];
    static data[2];
    data[0] = id;
    data[1] = iJackpot_number;
    replace_all(name, charsmax(name), "^"", "");
    formatex(Query, charsmax(Query), "INSERT INTO `dalily_jackpot` (`accountid`, `name`, `time`, `number`) VALUES (^"%d^", ^"%s^", ^"%d^", ^"%d^")", accountid, name, get_systime(), iJackpot_number);
    SQL_ThreadQuery(m_get_sql(), "QueryCallback_insert_dalily_jackpot", Query, data, 2);

    /* Table creation command for dalily_jackpot
    CREATE TABLE `dalily_jackpot` (
        `id` INT NOT NULL AUTO_INCREMENT,
        `accountid` INT NOT NULL,
        `name` VARCHAR(33) NOT NULL,
        `time` INT NOT NULL,
        `number` INT NOT NULL,
        PRIMARY KEY (`id`)
    ) ENGINE = InnoDB;
    */
}

public QueryCallback_insert_dalily_jackpot(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime)
{
    if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) 
    {
        log_amx("[DailyDraw] Error from QueryCallback_insert_dalily_jackpot:");
        log_amx("%s", Error);
        return;
    }
    new id = Data[0];
    new iJackpot_number = Data[1];
    if(is_user_connected(id))
    {
        new name[33];
        get_user_name(id, name, charsmax(name));

        ArrayPushArray(aDaliyEntries_JP_names, name);
        ArrayPushCell(aDaliyEntries_JP_numbers, iJackpot_number);
        ArrayPushCell(aDaliyEntries_JP, sk_get_accountid(id));
        add_user_dollar(id, -JACKPOT_PRIZE);
        sk_chat(id, "^3Sikeresen^1 vettél egy jackpot sorsjegyet, ^4este 8-kor^1 sorsolás!");
    }
}

public QueryCallback_insert_daliy_draws(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime)
{
    if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) 
    {
        log_amx("[DailyDraw] Error from QueryCallback_insert_daliy_draws:");
        log_amx("%s", Error);
        return;
    }
    new id = Data[0];
    if(is_user_connected(id))
    {
        new name[33];
        get_user_name(id, name, charsmax(name));

        ArrayPushArray(aDaliyEntries_DD_names, name);
        ArrayPushCell(aDaliyEntries_DD, sk_get_accountid(id));
        add_user_dollar(id, -DRAW_PRICE);
        sk_chat(id, "^3Sikeresen^1 vettél egy napi sorsjegyet, ^4este 8-kor^1 sorsolás!");
    }
}

public event_new_round()
{
    if(IsTimeBetween(DRAW_HOUR, DRAW_MINUTE, DRAW_LENGTH) || g_ForceTrigger)
    {
        new drawStartTime = get_systime() - (DRAW_LENGTH * 60);
        if(g_tLastDraw_DD > drawStartTime && !g_ForceTrigger)
            return;

        g_ForceTrigger = false;

        //check if limit met
        if(ArraySize(aDaliyEntries_DD) < DRAW_MINIMUM_ENTRY || ArraySize(aDaliyEntries_JP) < JACKPOT_MINIMUM_ENTRY)
        {
            sk_chat(0, "^3Nem sikerült^1 elindítani a napi sorsolást, mert ^3NEM^1 volt elég résztvevő.");
            sk_chat(0, "^3** ^1Jackpot: ^3%d^1/^4%d ^3| ^1Napi sorsjegy: ^3%d^1/^4%d ^3**", ArraySize(aDaliyEntries_JP), JACKPOT_MINIMUM_ENTRY, ArraySize(aDaliyEntries_DD), DRAW_MINIMUM_ENTRY);
            return;
        }

        sk_chat(0, "^3** ^1Napi sorsolás elindult. ^3| ^1Jackpot: ^4%.2f$ ^3| ^1Napi sorsjegy: ^4%.2f$ ^3**", (g_tLastPrize_JP+JACKPOT_BASED_POOL+(ArraySize(aDaliyEntries_JP)*JACKPOT_PRIZE)) , ArraySize(aDaliyEntries_DD)*DRAW_PRICE);

        new gameclock = get_member_game(m_iRoundTimeSecs);
        setTime(gameclock + 20);

        set_task(0.1, "start_dailydraw");
        set_task(0.1, "dailydraw_tick", SETTASK_ID_INBETWEEN,_,_,"b");
    }
}

public dailydraw_tick()
{
    message_begin(MSG_ALL, g_ScreenFade, {0,0,0})
    write_short(1<<12)
    write_short(1<<12)
    write_short(0x0000)
    write_byte(0)
    write_byte(0)
    write_byte(0)
    write_byte(255)
    message_end()
}

new Float:stake_tick = 0.5;
new winner_draw = -1;
new winner_jackpot = -1;
new stage = 0;
new jackpot_winner_numbers[4];
public start_dailydraw()
{
    g_bIsDailyDraw = true;
    freeze_unfreeze(0);
    winner_draw = -1;
    winner_jackpot = -1;
    stake_tick = 0.5;
    stage = 0;
    staking_tick();
    hud_disabled_all(true);
}


public staking_tick()
{
    if(stage > 10 && stake_tick <= 0.7)
        stake_tick += 0.05;
    

    new random = winner_draw == -1 ? random_num(0, ArraySize(aDaliyEntries_DD)-1) : winner_draw;
    //new accountid = ArrayGetCell(aDaliyEntries_DD, random);
    new name[33]; ArrayGetArray(aDaliyEntries_DD_names, random, name);
    jackpot_winner_numbers[0] = (stage >= 12) ? jackpot_winner_numbers[0] : random_num(0, 9);
    jackpot_winner_numbers[1] = (stage >= 15) ? jackpot_winner_numbers[1] : random_num(0, 9);
    jackpot_winner_numbers[2] = (stage >= 18) ? jackpot_winner_numbers[2] : random_num(0, 9);
    jackpot_winner_numbers[3] = (stage >= 21) ? jackpot_winner_numbers[3] : random_num(0, 9);
    if(stage < 10)
    {
        copy(name, 33, "");
        jackpot_winner_numbers[0] = 0;
        jackpot_winner_numbers[1] = 0;
        jackpot_winner_numbers[2] = 0;
        jackpot_winner_numbers[3] = 0;
    }

    new name_length = strlen(name);

    if(random_num(0, 3) != 1 && stage > 15 && winner_draw == -1)
        winner_draw = random;

    if(stage == 9)
        stake_tick = 3.0;
    if(stage == 10)
        stake_tick = 0.05;

    if(stage == 21)
    {
        //rig the winner numbers for testing
        // jackpot_winner_numbers[0] = 1;
        // jackpot_winner_numbers[1] = 2;
        // jackpot_winner_numbers[2] = 3;
        // jackpot_winner_numbers[3] = 4;


        new winner_number = jackpot_winner_numbers[0]*1000 + jackpot_winner_numbers[1]*100 + jackpot_winner_numbers[2]*10 + jackpot_winner_numbers[3];
        for(new i = 0; i < ArraySize(aDaliyEntries_JP_numbers); i++)
        {
            if(ArrayGetCell(aDaliyEntries_JP_numbers, i) == winner_number)
            {
                winner_jackpot = i;
                break;
            }
        }

        give_winner_reward_draw(winner_draw);
        give_winner_reward_jackpot(winner_jackpot, winner_number);
        if(winner_jackpot == -1)
            winner_jackpot = -2;
            
        stake_tick = 3.0;
    }

    for(new id = 0; id < 33; id++)
    {
        if(!is_user_connected(id) || !sk_get_logged(id))
            continue;

        new iLenA = 0;
        new HudStringA[300];
        if(stage >= 0) iLenA += formatex(HudStringA[iLenA], charsmax(HudStringA), "-| Nap sorsjegy %02d:%02d - %02d:%02d |-^n", DRAW_HOUR, DRAW_MINUTE, DRAW_HOUR, DRAW_MINUTE+DRAW_LENGTH);
        if(stage >= 1) iLenA += formatex(HudStringA[iLenA], charsmax(HudStringA), "Részvételhez a /dd paranccsal vehetsz %d$-ért.^n", floatround(DRAW_PRICE));
        if(stage >= 2) iLenA += formatex(HudStringA[iLenA], charsmax(HudStringA), "+-----------------------------------+^n");
        
        if(stage >= 3) {
            iLenA += formatex(HudStringA[iLenA], charsmax(HudStringA), "|");
            for(new i = 0; i < (40-name_length)/2; i++)
                iLenA += formatex(HudStringA[iLenA], charsmax(HudStringA), " ");
            iLenA += formatex(HudStringA[iLenA], charsmax(HudStringA), "^3%s", name);
            for(new i = 0; i < (40-name_length)/2; i++)
                iLenA += formatex(HudStringA[iLenA], charsmax(HudStringA), " ");
            iLenA += formatex(HudStringA[iLenA], charsmax(HudStringA), "|^n");
        }
        if(stage >= 4) iLenA += formatex(HudStringA[iLenA], charsmax(HudStringA), "+-----------------------------------+^n");
        
        if(winner_draw != -1)
            set_hudmessage(255, 255, 0, -1.0, 0.34, 0, 6.0, stake_tick+0.02, 0.0, (stage == 21) ? 2.0 : 0.0, next_hudchannel(id));
        else
            set_hudmessage(255, 255, 255, -1.0, 0.34, 0, 6.0, stake_tick+0.02, 0.0, (stage == 21) ? 2.0 : 0.0, next_hudchannel(id));
        ShowSyncHudMsg(id, g_SyncA, HudStringA);

        if(stage == 4)
        {
            set_hudmessage(0, 255, 0, -1.0, 0.46, 0, 6.0, 3.01, 3.0, 0.0, next_hudchannel(id));
            ShowSyncHudMsg(id, g_SyncC, fmt("%i$", floatround(DRAW_PRICE*float(ArraySize(aDaliyEntries_DD)))));
        }


        new iLenB = 0;
        new HudStringB[300];

        if(stage >= 5) iLenB += formatex(HudStringB[iLenB], charsmax(HudStringB), "-| Nap JackPot %02d:%02d - %02d:%02d |-^n", DRAW_HOUR, DRAW_MINUTE, DRAW_HOUR, DRAW_MINUTE+DRAW_LENGTH);
        if(stage >= 6) iLenB += formatex(HudStringB[iLenB], charsmax(HudStringB), "Részvételhez a /jp paranccsal vehetsz %d$-ért.^n", floatround(JACKPOT_PRIZE));
        if(stage >= 7) iLenB += formatex(HudStringB[iLenB], charsmax(HudStringB), "+----------%s----%s----%s----%s------------+^n", (stage >= 12) ? "v" : "--", (stage >= 15) ? "v" : "--", (stage >= 18) ? "v" : "--", (stage >= 21) ? "v" : "--");
        
        if(stage > 10) iLenB += formatex(HudStringB[iLenB], charsmax(HudStringB), "|            %d     %d     %d     %d             |^n", jackpot_winner_numbers[0], jackpot_winner_numbers[1], jackpot_winner_numbers[2], jackpot_winner_numbers[3]);
        if(stage >= 8 && stage < 10) iLenB += formatex(HudStringB[iLenB], charsmax(HudStringB), "|            X     X     X     X             |^n");
        if(stage >= 9) iLenB += formatex(HudStringB[iLenB], charsmax(HudStringB), "+----------%s----%s----%s----%s------------+^n", (stage >= 12) ? "^^" : "--", (stage >= 15) ? "^^" : "--", (stage >= 18) ? "^^" : "--", (stage >= 21) ? "^^" : "--");


        if(winner_jackpot == -1)
            set_hudmessage(255, 255, 255, -1.0, 0.53, 0, 6.0, stake_tick+0.01, 0.0, (stage == 21) ? 2.0 : 0.0, next_hudchannel(id));
        else if(winner_jackpot == -2)
            set_hudmessage(255, 0, 0, -1.0, 0.53, 0, 6.0, stake_tick+0.01, 0.0, (stage == 21) ? 2.0 : 0.0, next_hudchannel(id));
        else
            set_hudmessage(255, 0, 255, -1.0, 0.53, 0, 6.0, stake_tick+0.01, 0.0, (stage == 21) ? 2.0 : 0.0, next_hudchannel(id));
        
        ShowSyncHudMsg(id, g_SyncB, HudStringB);

        if(stage == 9)
        {
            set_hudmessage(0, 255, 0, -1.0, 0.65, 0, 6.0, 2.01, 3.0, 0.0, next_hudchannel(id));
            ShowSyncHudMsg(id, g_SyncD, fmt("%i$", floatround(g_tLastPrize_JP+JACKPOT_BASED_POOL+(JACKPOT_PRIZE*float(ArraySize(aDaliyEntries_JP))))));
        }

        if(stage < 10)
            client_cmd(id, "spk fvox/bell");
        else
        {
            client_cmd(id, "spk weapons/xbow_hitbod2");

            set_hudmessage(0, 255, 0, -1.0, 0.46, 0, 6.0, stake_tick+0.01, 0.0, (stage == 21) ? 2.0 : 0.0, next_hudchannel(id));
            ShowSyncHudMsg(id, g_SyncC, fmt("%i$", floatround(DRAW_PRICE*float(ArraySize(aDaliyEntries_DD)))));

            set_hudmessage(0, 255, 0, -1.0, 0.65, 0, 6.0, stake_tick+0.01, 0.0, (stage == 21) ? 2.0 : 0.0, next_hudchannel(id));
            ShowSyncHudMsg(id, g_SyncD, fmt("%i$", floatround(g_tLastPrize_JP+JACKPOT_BASED_POOL+(JACKPOT_PRIZE*float(ArraySize(aDaliyEntries_JP))))));
        }
    }

    stage++;

    if((winner_draw == -1 && winner_jackpot == -1) || stage <= 21)
        set_task(stake_tick, "staking_tick");
    else
    {
        set_task(3.5, "finished_dailydraw1");
        set_task(5.0, "finished_dailydraw2");
    }
}

public give_winner_reward_draw(winner)
{
    new accountid = ArrayGetCell(aDaliyEntries_DD, winner);
    new name[33]; ArrayGetArray(aDaliyEntries_DD_names, winner, name);
    new Float:prize = DRAW_PRICE*float(ArraySize(aDaliyEntries_DD));
    add_user_dollar_offline(accountid, prize);
    sk_chat(0, "^2Napi sorsjegy nyertese: %s (#%i) | %.2f$", name, accountid, prize);

    new eWinner[eDD];
    eWinner[DD_ACCOUNTID] = accountid;
    copy(eWinner[DD_NAME], 33, name);
    eWinner[DD_PRICE] = prize;
    eWinner[DD_TIME] = get_systime();
    ArrayPushArray(aDaliyEntries_DD_winners, eWinner);
    //remove the older entries
    if(ArraySize(aDaliyEntries_DD_winners) > 5)
        ArrayDeleteItem(aDaliyEntries_DD_winners, 0);

    //insert into table for history daliy_draws_winners
    static Query[10048];
    replace_all(name, charsmax(name), "^"", "");
    formatex(Query, charsmax(Query), "INSERT INTO `daliy_draws_winners` (`accountid`, `name`, `prize`, `time`) VALUES (^"%d^", ^"%s^", ^"%.2f^", ^"%d^")", accountid, name, prize, get_systime());
    SQL_ThreadQuery(m_get_sql(), "QueryCallback_insert_daliy_draws_winners", Query);

    /* Table creation command for daliy_draws_winners
    CREATE TABLE `daliy_draws_winners` (
        `id` INT NOT NULL AUTO_INCREMENT,
        `accountid` INT NOT NULL,
        `name` VARCHAR(33) NOT NULL,
        `prize` FLOAT NOT NULL,
        `time` INT NOT NULL,
        PRIMARY KEY (`id`)
    ) ENGINE = InnoDB;
    */
}

public QueryCallback_insert_daliy_draws_winners(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime)
{
    if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) 
    {
        log_amx("[DailyDraw] Error from QueryCallback_insert_daliy_draws_winners:");
        log_amx("%s", Error);
        return;
    }

    ArrayClear(aDaliyEntries_DD);
    ArrayClear(aDaliyEntries_DD_names);

    g_tLastDraw_DD = get_systime();
}

public give_winner_reward_jackpot(winner, number)
{
    new accountid = -1;
    new name[33];
    new Float:prize = g_tLastPrize_JP+JACKPOT_BASED_POOL+(JACKPOT_PRIZE*float(ArraySize(aDaliyEntries_JP)));

    if(winner > -1)
    {
        client_cmd(0, "spk Herboynew/jackpot.wav");
        accountid = ArrayGetCell(aDaliyEntries_JP, winner);
        ArrayGetArray(aDaliyEntries_JP_names, winner, name);
        add_user_dollar_offline(accountid, prize);
        sk_chat(0, "^3** ^1Jackpot nyertese: ^4%s ^3(#%i) ^3|^4 %.2f$ ^1nyert. ^3| ^1Nyerő számok: ^4%04d ^3**", name, accountid, prize, number);
    }
    else
    {
        sk_chat(0, "^3** ^1Nem volt nyertes a jackpot sorsoláson :( ^3| ^1Nyerő számok: ^4%04d ^3| ^1Nyeremény: ^4%.2f$ ^3**", number, prize);
    }

    new eWinner[eJP];
    eWinner[JP_ACCOUNTID] = accountid;
    copy(eWinner[JP_NAME], 33, name);
    eWinner[JP_PRIZE] = prize;
    eWinner[JP_TIME] = get_systime();
    eWinner[JP_NUMBER] = number;
    ArrayPushArray(aDaliyEntries_JP_winners, eWinner);
    //remove the older entries
    if(ArraySize(aDaliyEntries_JP_winners) > 5)
        ArrayDeleteItem(aDaliyEntries_JP_winners, 0);
    
    //insert into table for history dalily_jackpot_winners
    static Query[10048];
    new data[2];
    data[0] = accountid;
    data[1] = int:prize;
    replace_all(name, charsmax(name), "^"", "");
    formatex(Query, charsmax(Query), "INSERT INTO `dalily_jackpot_winners` (`accountid`, `name`, `number`, `prize`, `time`) VALUES (^"%d^", ^"%s^", ^"%d^", ^"%.2f^", ^"%d^")", accountid, name, number, prize, get_systime());
    SQL_ThreadQuery(m_get_sql(), "QueryCallback_insert_dalily_jackpot_winners", Query, data, 2);

    /* Table creation command for dalily_jackpot_winners
    CREATE TABLE `dalily_jackpot_winners` (
        `id` INT NOT NULL AUTO_INCREMENT,
        `accountid` INT NOT NULL,
        `name` VARCHAR(33) NOT NULL,
        `number` INT NOT NULL,
        `prize` FLOAT NOT NULL,
        `time` INT NOT NULL,
        PRIMARY KEY (`id`)
    ) ENGINE = InnoDB;
    */
}

public QueryCallback_insert_dalily_jackpot_winners(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime)
{
    if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) 
    {
        log_amx("[DailyDraw] Error from QueryCallback_insert_dalily_jackpot_winners:");
        log_amx("%s", Error);
        return;
    }

    ArrayClear(aDaliyEntries_JP);
    ArrayClear(aDaliyEntries_JP_numbers);
    ArrayClear(aDaliyEntries_JP_names);

    new accountid = Data[0];
    new Float:prize = Float:Data[1];
    
    g_tLastDraw_JP = get_systime();
    if(accountid == -1)
        g_tLastPrize_JP = prize - JACKPOT_BASED_POOL;
    else
        g_tLastPrize_JP = 0.0;
}

public finished_dailydraw1()
{
    remove_task(SETTASK_ID_INBETWEEN);
}

public finished_dailydraw2()
{
    freeze_unfreeze(1);
    hud_disabled_all(false);
    g_bIsDailyDraw = false;
}

stock freeze_unfreeze(type)
{
    new players[32], pnum; get_players(players, pnum, "a");
    for(new id, i; i < pnum; i++) {
        id = players[i];
        set_user_noclip(id, !type);
        set_pev(id, pev_flags, type ? (pev(id, pev_flags) & ~FL_FROZEN) : pev(id, pev_flags) | FL_FROZEN);
    }
}

public setTime(iTime) {
    new Float:flStartTime = get_member_game(m_fRoundStartTimeReal);

    set_member_game(m_iRoundTime, iTime);
    set_member_game(m_iRoundTimeSecs, iTime);
    set_member_game(m_fRoundStartTime, flStartTime);

    UpdateTimer(0, GetTimeLeft());
}

GetTimeLeft() {
    new Float:flStartTime = get_member_game(m_fRoundStartTimeReal);
    new iTime = get_member_game(m_iRoundTimeSecs);
    return floatround(flStartTime + float(iTime) - get_gametime());
}

UpdateTimer(iClient, iTime) {
    static iMsgId = 0;
    if(!iMsgId) {
        iMsgId = get_user_msgid("RoundTime");
    }

    message_begin(iClient ? MSG_ONE : MSG_ALL, iMsgId);
    write_short(iTime);
    message_end();
}

public bool:IsTimeBetween(starthour, startminute, lengthminutes)
{
    // Retrieve the current Unix timestamp
    new currentTime = get_systime(3600); // UTC +2

    // Calculate the number of seconds in a day
    new secondsInDay = 86400;

    // Calculate the start of the current day in UTC
    new startOfDayUTC = currentTime - (currentTime % secondsInDay);

    new targetStartTimeUTC = startOfDayUTC + (starthour * 3600) + (startminute * 60); // 18:00 UTC
    new targetEndTimeUTC = targetStartTimeUTC + (lengthminutes * 60); // 18:10 UTC

    // Check if the current time is between the target start and end times
    return (currentTime >= targetStartTimeUTC && currentTime < targetEndTimeUTC);
}

public plugin_end()
{
    ArrayDestroy(aDaliyEntries_DD);
    ArrayDestroy(aDaliyEntries_DD_names);
    ArrayDestroy(aDaliyEntries_DD_winners);

    ArrayDestroy(aDaliyEntries_JP);
    ArrayDestroy(aDaliyEntries_JP_numbers);
    ArrayDestroy(aDaliyEntries_JP_names);
    ArrayDestroy(aDaliyEntries_JP_winners);

    if(task_exists(SETTASK_ID_INBETWEEN))
        remove_task(SETTASK_ID_INBETWEEN);
}
