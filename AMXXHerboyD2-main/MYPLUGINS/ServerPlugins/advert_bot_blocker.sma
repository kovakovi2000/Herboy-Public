#include <amxmodx>
#include <reapi>

#define PLUGIN    "ANTI prime-server.info"
#define AUTHOR    "Kova"
#define VERSION    "1.0"

public plugin_precache() {
    register_plugin(PLUGIN, VERSION, AUTHOR);

    RegisterHookChain(RH_ClientConnected, "RH_ClientConnected_Pre");
}

public RH_ClientConnected_Pre(const client) {

    new szIP[16];
    rh_get_net_from(szIP, charsmax(szIP));
    new iPos = contain(szIP, ":");
    if(iPos != -1)
        copy(szIP[0], iPos, szIP);
    
    console_print(0, "Connection inited from %s", szIP);
    if(contain(szIP, "89.108.88.") != -1)
    {
        console_print(0, "Blocked connection for advert bot %s", szIP);
        server_cmd("addip %i %s", 0, szIP);
    }
}

