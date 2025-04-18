#include <amxmodx>
#include <colorchat>
 
new const PLUGIN[] = "Chat Hangok";
new const VERSION[] = "1.0";
new const AUTHOR[] = "fasz";
 
 
new const PREFIX[] = "^4[^1~^3|^4AVATÁR^3|^1~^4] ^3»";
 
//#define ACCESS_FLAG             ADMIN_KICK          // - Type // before # if you want it for all players.
#define TIME_BETWEEN_SOUNDS     120                 // - in seconds
 
new Array:musicname, Array:musicpath;
new g_aSize;
new g_iTime, bool:g_iSwitchOff[33];
 
public plugin_init() {
    register_plugin(PLUGIN, VERSION, AUTHOR);
    register_dictionary("funny_sounds.txt");
   
    register_clcmd("say", "sayhandler");
    register_clcmd("say_team", "sayhandler");
	register_clcmd("choffocska", "sound_switchoff");
	register_clcmd("chlista", "musicmenu");
    //set_task(300.0, "toswitchoff", 0, .flags="b")
}
 
public plugin_precache() {
    musicname = ArrayCreate(32);
    musicpath = ArrayCreate(64);
   
    new sBuffer[256], sFile[64], sSoundName[32], sSoundPath[64], pFile;
   
    get_localinfo("amxx_configsdir", sFile, charsmax(sFile));
	format(sFile, charsmax(sFile), "%s/chat_hangok.ini", sFile);
   
    pFile = fopen(sFile, "rt");
   
    if(pFile) {    
        while(!feof(pFile)) {
            fgets(pFile, sBuffer, charsmax(sBuffer));
            trim(sBuffer);
            if(sBuffer[0] == ';' || sBuffer[0] == ' ') continue;
           
            parse(sBuffer, sSoundName, charsmax(sSoundName), sSoundPath, charsmax(sSoundPath));
           
            if(containi(sSoundPath, ".mp3") != -1 || containi(sSoundPath, ".wav") != -1) {
                precache_sound(sSoundPath);
                ArrayPushString(musicname, sSoundName);
                ArrayPushString(musicpath, sSoundPath);
            }
        }
        fclose(pFile);
        g_aSize = ArraySize(musicname);
    }
}
 
public sayhandler(id) {
    #if defined ACCESS_FLAG
    if(~get_user_flags(id) & ACCESS_FLAG) return;
    #endif
   
    new message[190]; read_args(message, charsmax(message));
    remove_quotes(message);
    new sSoundName[32];
   
    for(new i; i<g_aSize; i++) {
        ArrayGetString(musicname, i, sSoundName, charsmax(sSoundName));
        if(equali(message, sSoundName)) {
            expirecheck(i);
        }
    }
}
 
expirecheck(item) {
    new srvtime = get_systime();   
   
    if(srvtime >= g_iTime) {
        playsound(item);
        g_iTime = (srvtime + TIME_BETWEEN_SOUNDS);
    }
    else
 		ColorChat(0, NORMAL, "%s ^3Várnod kell még ^4%d másodpercet ^1az új hang lejátszásáig.", PREFIX, (g_iTime - srvtime));
}
 
playsound(item) {
    new szSound[64]; ArrayGetString(musicpath, item, szSound, charsmax(szSound));
    new makesound[128];
    if(containi(szSound, ".mp3") != -1)
        formatex(makesound, charsmax(makesound), "mp3 play ^"sound/%s^"", szSound);
    else
        formatex(makesound, charsmax(makesound), "spk ^"%s^"", szSound);
   
   
    new players[32], num, tempid;
    get_players(players, num, "c");
    for(new i; i<num; i++) {
        tempid = players[i];
        if(!g_iSwitchOff[tempid])
            client_cmd(tempid, "%s", makesound);
    }
}
 
public sound_switchoff(id) {
    switch(g_iSwitchOff[id]) {
        case false: {
            g_iSwitchOff[id] = true;
            client_cmd(id, "setinfo _funnysoundsoff 1");
        }
        case true: {
            g_iSwitchOff[id] = false;
            client_cmd(id, "setinfo _funnysoundsoff 0");
        }
    }
}
 
public client_putinserver(id) {
    if(is_user_sounds_off(id))
        g_iSwitchOff[id] = true;
}
 
public client_disconnect(id) {
    g_iSwitchOff[id] = false;
}
 
public plugin_end() {
    ArrayDestroy(musicname);
    ArrayDestroy(musicpath);
}
 
stock bool:is_user_sounds_off(id) {
    new switcher[8];
    get_user_info(id, "_funnysoundsoff", switcher, charsmax(switcher));
    if(equal(switcher, "1")) return true;
    return false;
}
 
public musicmenu(id) {
    #if defined ACCESS_FLAG
    if(~get_user_flags(id) & ACCESS_FLAG) return;
    #endif
   
    new s_MenuName[128]; formatex(s_MenuName, charsmax(s_MenuName), "\r[\wAvatár\r] \yFun \r» \r[ \wChat Hanglista \r]");
    new menu = menu_create(s_MenuName, "musicmenu_h");
    new sSoundName[32];
    for(new i; i<g_aSize;i++) {
        ArrayGetString(musicname, i, sSoundName, charsmax(sSoundName));
        menu_additem(menu, sSoundName, "", 0)
    }
    menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
    menu_setprop(menu, MPROP_BACKNAME, "\yVissza");
    menu_setprop(menu, MPROP_NEXTNAME, "\yKövetkező");
    menu_setprop(menu, MPROP_EXITNAME, "\rKilépés");
    menu_display(id, menu, 0);
}
 
public musicmenu_h(id, menu, item) {
    if(item == MENU_EXIT) {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }
   
    expirecheck(item);
   
    menu_destroy(menu);
    return PLUGIN_HANDLED;
}