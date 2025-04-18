#include <amxmodx>
#include <manager>
#include <private_message>

#pragma semicolon 1

#define PLUGIN_NAME "Private Message: Logging"
#define PLUGIN_VERSION "1.3"
#define PLUGIN_AUTHOR "Denzer"

// RU: SQL-логирование
// EN: SQL-logging
#define SQL_LOGGING

#if defined SQL_LOGGING
#include <sqlx>

enum _:CVARS
{
    HOST[32],
    USER[16],
    PASS[32],
    DB[16],
    TABLE[32]
};

new g_Cvars[CVARS];

#else
new g_szLogFile[] = "private_message.log";
#endif

public plugin_init()
{
    register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);

#if defined SQL_LOGGING
    new pCvar;
    pCvar = create_cvar("pm_host", "", FCVAR_PROTECTED, "Host");
    bind_pcvar_string(pCvar, g_Cvars[HOST], charsmax(g_Cvars[HOST]));

    pCvar = create_cvar("pm_user", "", FCVAR_PROTECTED, "User");
    bind_pcvar_string(pCvar, g_Cvars[USER], charsmax(g_Cvars[USER]));

    pCvar = create_cvar("pm_pass", "", FCVAR_PROTECTED, "Password");
    bind_pcvar_string(pCvar, g_Cvars[PASS], charsmax(g_Cvars[PASS]));

    pCvar = create_cvar("pm_db", "", FCVAR_PROTECTED, "DB");
    bind_pcvar_string(pCvar, g_Cvars[DB], charsmax(g_Cvars[DB]));

    pCvar = create_cvar("pm_table", "private_messages", FCVAR_PROTECTED, "Table");
    bind_pcvar_string(pCvar, g_Cvars[TABLE], charsmax(g_Cvars[TABLE]));

    AutoExecConfig();
    
#else
    register_dictionary("private_message.txt");
#endif
}

#if defined SQL_LOGGING
public QueryHandler(iFailState, Handle:hQuery, szError[], iErrnum, cData[], iSize, Float:fQueueTime)
{
    if(iFailState != TQUERY_SUCCESS)
        log_amx("SQL Error #%d - %s", iErrnum, szError);
}

public SQL_Logging(sender, receiver, message[])
{
    new szQuery[512], szMessage[280];
    new sender_name[MAX_NAME_LENGTH*2], sender_steamid[24], sender_ip[MAX_IP_LENGTH];
    new receiver_name[MAX_NAME_LENGTH*2], receiver_steamid[24], receiver_ip[MAX_IP_LENGTH];

    get_user_authid(sender, sender_steamid, charsmax(sender_steamid)), get_user_authid(receiver, receiver_steamid, charsmax(receiver_steamid));
    get_user_ip(sender, sender_ip, charsmax(sender_ip), true), get_user_ip(receiver, receiver_ip, charsmax(receiver_ip), true);

    SQL_QuoteString(Empty_Handle, sender_name, charsmax(sender_name), fmt("%n", sender));
    SQL_QuoteString(Empty_Handle, receiver_name, charsmax(receiver_name), fmt("%n", receiver));
    SQL_QuoteString(Empty_Handle, szMessage, charsmax(szMessage), fmt("%s", message));

    formatex(szQuery, charsmax(szQuery), "\
        INSERT INTO `%s` \
        ( \
            sender_name, \
            sender_steamid, \
            sender_ip, \
            receiver_name, \
            receiver_steamid, \
            receiver_ip, \
            message \
        ) \
        VALUES \
        ( \
            '%s', \
            '%s', \
            '%s', \
            '%s', \
            '%s', \
            '%s', \
            '%s' \
        );", g_Cvars[TABLE], sender_name, sender_steamid, sender_ip, receiver_name, receiver_steamid, receiver_ip, szMessage);
    SQL_ThreadQuery(m_get_sql(), "QueryHandler", szQuery);
}
#else
public LogToFile(sender, receiver, message[])
{
    new sender_steamid[24], sender_ip[MAX_IP_LENGTH];
    new receiver_steamid[24], receiver_ip[MAX_IP_LENGTH];

    get_user_authid(sender, sender_steamid, charsmax(sender_steamid)), get_user_authid(receiver, receiver_steamid, charsmax(receiver_steamid));
    get_user_ip(sender, sender_ip, charsmax(sender_ip), true), get_user_ip(receiver, receiver_ip, charsmax(receiver_ip), true);

    log_to_file(g_szLogFile, "^n\
                            %L^n\
                            %L^n\
                            %L^n\
                            ------------------------------", LANG_SERVER, "PM_LOGGING_SENDER", sender, sender_steamid, sender_ip, LANG_SERVER, "PM_LOGGING_RECEIVER", receiver, receiver_steamid, receiver_ip, LANG_SERVER, "PM_LOGGING_MESSAGE", message);
}
#endif

public pm_message_sent(sender, receiver, message[])
{
#if defined SQL_LOGGING
    SQL_Logging(sender, receiver, message);
#else
    LogToFile(sender, receiver, message);
#endif
}