#include <amxmodx>
#include <sqlx>
#include <cstrike>
#include <fakemeta>
#include <sk_utils>
#include <regsystem>
#include <manager>

#pragma compress 1

#define PLUGIN "WebAlias"
#define VERSION "1.0"
#define AUTHOR "Kova"

#define TASK_OFFSET 6742532

new bool:first = false;
new steamid[33][32];
static szQuery[3584];


public plugin_init() {
    register_plugin(PLUGIN, VERSION, AUTHOR);

    register_clcmd("say", "Hook_Say");
    register_clcmd("say_team", "Hook_Say");
    set_task(60.0, "MinClock",_,_,_,"b");
}

public MinClock(id)
{
    if(first)
    {
        first = !first;
        return;
    }
    new Len = 0;
    for(new i = 0; i < 33; i++)
	{
		if(is_user_connected(i) && !is_user_bot(i))
            Len += formatex(szQuery[Len], charsmax(szQuery)-Len, "INSERT INTO `amx_activity` (`steamid`) VALUES (^"%s^");", steamid[i]);
	}
    new p[32],n;
    get_players(p,n,"ch");
    Len += formatex(szQuery[Len], charsmax(szQuery)-Len, "INSERT INTO `webplayercount` (`playercount`) VALUES (%i);", n);
    SQL_ThreadQuery(m_get_sql(), "AddAlias", szQuery, _, _);
}

public client_putinserver(id)
{
    if(!is_user_connected(id) || is_user_bot(id))
        return;

    new sName[32], sHash[32], temp[64];
    get_user_authid(id, steamid[id], charsmax(steamid[]));
    get_user_name(id, sName, charsmax(sName));

    formatex(temp, charsmax(temp), "%s%s", steamid[id], sName);
    hash_string(temp, Hash_Md5, sHash, charsmax(sHash));
    
    formatex(szQuery, charsmax(szQuery), "INSERT INTO `amx_alias` (`hash`, `Steamid`, `Name`) VALUES (^"%s^", ^"%s^", ^"%s^");", sHash, steamid[id], sName);
    SQL_ThreadQuery(m_get_sql(), "AddAlias", szQuery, _, _);
}
public AddAlias(FailState, Handle:Query, Error[], Errcode, data[], DataSize, Float:Queuetime){
	if( FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED ){
        if(contain(Error, "Duplicate entry") == -1)
		    log_amx("%s", Error);
        return;
	}
}

public Hook_Say(id)
{
    new Message[512], iTeamsay, sName[32];

    read_args(Message, charsmax(Message));
    
    replace_all(Message, 512, "'", "''");
    replace_all(Message, 512, "\", "\\");

    if(equal(Message, "/rs") || equal(Message, "/top15") || equal(Message, "/rank") || equal(Message, "/rtv") || equal(Message, "/nom"))
        return PLUGIN_HANDLED;

    new cmd[21];
    read_argv(0,cmd,20);
    if(equal(cmd,"say"))
        iTeamsay = 0;
    else
        iTeamsay = 1;

    get_user_name(id, sName, charsmax(sName));
    replace_all(sName, 32, "'", "''");
    formatex(szQuery, charsmax(szQuery), "INSERT INTO `amx_messages` (`Steamid`, `Name`, `Teamsay`, `Team`, `Message`, `Time`) VALUES ('%s', '%s', %i, %i, '%s', %i);", steamid[id], sName, iTeamsay, cs_get_user_team(id), Message, get_systime());
    SQL_ThreadQuery(m_get_sql(), "AddMessage", szQuery, _, _);
}

public AddMessage(FailState, Handle:Query, Error[], Errcode, data[], DataSize, Float:Queuetime){
    if( FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED ){
        log_amx("%s", Error);
        return;
    }
}