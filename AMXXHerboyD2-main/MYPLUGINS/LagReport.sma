#include < amxmodx >
#include < grip >
#include <sk_utils>

/* SETTINGS */ // NOT NEEDED
new bottoken[] = "MTI5NDY5MzEzNzA1ODM2NTYxMw.GAcXDt.ZfNCaXwUKk9gAWyxNLmeYtmJcrjFqbCJwdnP_c";

new const WEBHOOK[] = "https://discord.com/api/webhooks/1262535786562195548/7jfKjHa6E04DqGYfzYVxvSi6z-ZIn63xnjDgn9F9uxwB_Eui_wZWUvoHrju7vrf1PN0f"//assault

//Commands for which the plugin menu will be available (just too lazy to screw ini)
new const cmds[][] = {
    "say lag", "say_team lag",
    "say /lagreport", "say_team /lagreport",
    "say /laggreport", "say_team /laggreport",
    "say /lag", "say_team /lag"
};

// Reasons in the menu (just too lazy to screw ini)
new const reasons[][] = {
    "Stabil FPS bedroppol",
    "A játék néha egy pillanatra (0.5ms) beakad",
    "Mikrolagg (Játék fut, de pillanatnyi akadás)",
    "Magas / Ingadozó ping. (Előtte stabil volt)",
    "Magas Choke / Loss (net_graph-ból)",
    "Alacsony ping, 0-choke, de mégis akad",
    "Lövés / Túrás akadozik"
};
//#define MY_REASON //If you don't want people to be able to write their reason - comment out
#define REP_IMMUN ADMIN_RCON //Who can't be complained about? [If not needed, comment out]

/*
{rname} - Nickname of the person who filed the complaint | {rip} - IP of the person who filed the complaint | {rauth} - Steam ID of the person who filed the complaint
{vname} - Nickname of the person being complained about | {vip} - IP of the person against whom the complaint is made | {vauth} - StimID of the person being reported
{reason} - Reason for the complaint
{hostname} - Server name | {ip} - Server IP
*/
new const SHABLON_REPORT[] = "@everyone^n^n**{rname}** ({rauth}, {rip}) LAGG REPORT:^n^nDátum: **{currtime}** ^nLagg típusa: **{reason}**^n^n*Player Location:* `https://ipwho.is/{rip}`"; //What will be written in the discord channel
/* SETTINGS */

//MAX_PLAYERS + 1 = 33 <3
new gReason[33][192];

new gHostname[64], gIp[22];

public plugin_init(){
    register_plugin("Discord LagReport", "0.2", "paffgame");
    
    for(new i; i < sizeof cmds; i ++)
        register_clcmd(cmds[i], "create_reasons");

    get_cvar_string("hostname", gHostname, charsmax(gHostname));
    get_user_ip(0, gIp, charsmax(gIp));
}

public create_reasons(id){
    new rMenu = menu_create("Válassz egy típust","handler_reason");
    
    for(new i; i < sizeof reasons; i ++)
        menu_additem(rMenu, reasons[i]);
    
    menu_setprop(rMenu, MPROP_NEXTNAME, "Next");
    menu_setprop(rMenu, MPROP_BACKNAME, "Back");
    menu_setprop(rMenu, MPROP_EXITNAME, "Exit");

    menu_display(id, rMenu);
}
public handler_reason(id, menu, item){
    if(item == MENU_EXIT)
        return;
    
    copy(gReason[id], charsmax(gReason[]), reasons[item]);
    send_report(id);
}

public send_report(id){
    if(!is_user_connected(id))
        return;
    
    new text[2048], steam[35], ip[17], sTime[64];
    get_user_authid(id, steam, charsmax(steam));
    get_user_ip(id, ip, charsmax(ip), 1);
    formatCurrentDateAndTime(sTime, charsmax(sTime));

    // Embed structure for Discord
    format(text, charsmax(text), "{\"embeds\": [{\"title\": \"Lag Report\", \"description\": \"A player reported a lag issue.\", \"color\": 15158332, \"fields\": [ {\"name\": \"Reporter Name\", \"value\": \"%n\", \"inline\": false}, {\"name\": \"Steam ID\", \"value\": \"%s\", \"inline\": false}, {\"name\": \"IP Address\", \"value\": \"%s\", \"inline\": false}, {\"name\": \"Reason\", \"value\": \"%s\", \"inline\": false} ], \"footer\": {\"text\": \"Report Time: %s\"} }]}", id, steam, ip, gReason[id], sTime);

    GoRequest(id, WEBHOOK, "Handler_SendReason", GripRequestTypePost, text);
}

public Handler_SendReason(const id){
    if(!is_user_connected(id))
        return;
    
    if(!HandlerGetErr()){
        #if defined ANTIFLOOD
        AntiFlood[id] = 0;
        #endif
        return;
    }
    
    sk_chat(id, "Lag jelentés elküldve!");
}

public GoRequest(const id, const site[], const handler[], const GripRequestType:type, data[]){
    new GripRequestOptions:options = grip_create_default_options();
    grip_options_add_header(options, "Content-Type", "application/json");
    
    new GripBody: body = grip_body_from_string(data);
    grip_request(site, body, type, handler, options, id);
    
    grip_destroy_body(body);
    grip_destroy_options(options);
}

public bool: HandlerGetErr(){
    if(grip_get_response_state() == GripResponseStateError){
        log_amx("ResponseState is Error");
        return false;
    }
    
    new GripHTTPStatus:err;
    if((err = grip_get_response_status_code()) != GripHTTPStatusNoContent){
        log_amx("ResponseStatusCode is %d", err);
        return false;
    }
    
    return true;
}

public client_authorized(id)
{
    set_task(30.0, "PrintText" , id, "", 0, "a", 5)
}
public PrintText(id)
{
  sk_chat(id, "Ha bármilyen laggot észlelsz, jelezd nekünk a ^3/lagreport^1 menüben!")
} 
public LoadUtils()
{

}
