#include <amxmodx>
#include <amxmisc>
#include <reapi>

new const Plugin_sName[] = "Unreal Evol Blocker";
new const Plugin_sVersion[] = "1.1";
new const Plugin_sAuthor[] = "Karaulov";

public plugin_init()
{
    register_plugin(Plugin_sName, Plugin_sVersion, Plugin_sAuthor);
    //register_cvar("unreal_evol_detect", Plugin_sVersion, FCVAR_SERVER | FCVAR_SPONLY);
    register_clcmd("+rrr","skiprrr");
    register_clcmd("-rrr","skiprrr");
}

public skiprrr(id)
{
    return PLUGIN_HANDLED;
}

public client_putinserver(id)
{
    if (task_exists(id))
        remove_task(id);
    set_task(1.0,"start_evol_detect",id,_,_,"b")
}

public client_disconnected(id)
{
    if (task_exists(id))
        remove_task(id);
}

public start_evol_detect(id)
{
    if (is_user_connected(id) && is_user_alive(id))
    {
        client_cmd(id,"+rrr;-rrr;")
    }
}