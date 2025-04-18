#include <amxmodx>
#include <sk_utils>
#include <sqlx>
#include <regsystem>
#include <easytime2>
#include <manager>

#pragma compress 1

#define PLUGIN "Prize Draw event"
#define VERSION "1.0"
#define AUTHOR "Kova"

#define TEAM_T 1
#define TEAM_CT 2
#define TEAM_SPEC 3

// CREATE TABLE `amx_drawprizetime` (`steamid` VARCHAR(33) NOT NULL , `PlayTime` INT(11) NOT NULL , `skId` INT(11) NOT NULL , `claimed` TINYINT(1) NOT NULL , `SteamURL` TEXT NOT NULL , PRIMARY KEY (`steamid`)) ENGINE = InnoDB;
new SteamId[33][33];
new LastActive[33];
new skId[33];
new MinForPrize[33];


public plugin_init() {
    register_plugin(PLUGIN, VERSION, AUTHOR);
    new time = get_systime();
    if(time < 1732057201 && time < 1734735599)
        return;

    register_clcmd("say /nyeremeny", "DrawPrizeDisplay");
    register_clcmd("say /nyeremény", "DrawPrizeDisplay");
    register_clcmd("say /nyeremenyjatek", "DrawPrizeDisplay");
    register_clcmd("say /nyereményjáték", "DrawPrizeDisplay");
    set_task(60.0, "CheckActivity",_,_,_,"b");
    set_task(567.0, "AdvertPrizedraw",_,_,_,"b");
}

public AdvertPrizedraw()
{
    sk_chat(0, "A ^3top 50 legtöbb időt ^3 játszott játékosok között kisorsolunk egy ^4ASUS TUF Gaming VG279Q1R monitort^1!");
    sk_chat(0, "Nézd meg mennyi játszott időd van és ÍRD BE: ^4/nyeremeny");
    sk_chat(0, "További részletek:^4 https://herboyd2.hu/prizedraw");
}

public client_putinserver(id)
{
    if(is_user_connected(id) && !is_user_bot(id))
    {
        get_user_authid(id, SteamId[id], 33)
        LastActive[id] = get_systime() + 60;
        skId[id] = 0;
        MinForPrize[id] = 1;
    }
}

public LoggedSuccesfully(id)
{
    static szQuery[256];
    new Data[1];
    Data[0] = id;
    formatex(szQuery, charsmax(szQuery), "SELECT * FROM `amx_drawprizetime` WHERE `steamid` = ^"%s^";", SteamId[id])
    SQL_ThreadQuery(m_get_sql(), "QuerySelect", szQuery, Data, 1);
}
public QuerySelect(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime) {
    if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) {
        log_amx("%s", Error);
        return;
    }
    else {
        new id = Data[0];
        
        if(SQL_NumRows(Query) > 0)
            MinForPrize[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "PlayTime"));
        
        skId[id] = sk_get_accountid(id);
    }
}

public client_disconnected(id)
{
    update_user_data(id);
}

public update_user_data(id)
{
    if(skId[id] == 0)
        return;
    static szQuery[256];
    //INSERT INTO `amx_drawprizetime` (steamid, PlayTime, skId) VALUES ("STEAM_0:0:1234", 10, 5, 0, "") ON DUPLICATE KEY UPDATE PlayTime=15;
    formatex(szQuery, charsmax(szQuery), "INSERT INTO `amx_drawprizetime` (steamid, PlayTime, skId, claimed, SteamURL) VALUES (^"%s^", %i, %i, 0, ^"^") ON DUPLICATE KEY UPDATE PlayTime=%i;", SteamId[id], MinForPrize[id], skId[id], MinForPrize[id]);
    SQL_ThreadQuery(m_get_sql(), "QueryUpdate", szQuery, _, _); 
}

public QueryUpdate(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime) {
    if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) {
        log_amx("%s", Error);
        return;
    }
}

public client_command(id)
{
    LastActive[id] = get_systime();
    return PLUGIN_CONTINUE;
}

public CheckActivity()
{
    new time = get_systime();
    if(time > 1734735599)
        return;

    for(new id = 0; id < 33; id++)
    {
        if(/* !IsUserSteam[id] && */ sk_get_logged(id) && LastActive[id] > (get_systime() - 60))
        {
            static team; team = get_user_team(id);
            if(team == TEAM_T || team == TEAM_CT)
                MinForPrize[id]++;
        }
    }
}

public DrawPrizeDisplay(id)
{
    // if(IsUserSteam[id])
    // {
    //     sk_chat(id, "Sajnáljuk de ebben csak ^4Nonsteam ^1játékosok vehetnek részt!");
    // }
    if(!sk_get_logged(id))
    {
        sk_chat(id, "Sajnáljuk de ebben csak ^4regisztrált ^1játékosok vehetnek részt! Nyomd meg a ^3T ^1gombot és regisztrálj/jelentkezz be!");
    }
    else
    {
        new sMinutes[80];
        easy_time_length(id, MinForPrize[id], timeunit_minutes, sMinutes, charsmax(sMinutes));
        sk_chat(id, "Neked jelenleg ^4%s ^1játszott időd van!", sMinutes);
        sk_chat(id, "Nézd meg a toplistát itt:^4 https://herboyd2.hu/prizedraw", sMinutes);
    }
    return PLUGIN_HANDLED;
}