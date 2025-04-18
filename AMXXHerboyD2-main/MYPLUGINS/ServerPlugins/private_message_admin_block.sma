#include <amxmodx>
#include <amxmisc>
#include <private_message>

#pragma semicolon 1

#define PLUGIN_NAME "Private Message: Admin Block"
#define PLUGIN_VERSION "1.1"
#define PLUGIN_AUTHOR "Denzer"

public plugin_init()
{
    register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);

    register_clcmd("say /pmblock", "CmdMessagesBlock", ADMIN_LEVEL_A);
    register_clcmd("pmblock", "CmdMessagesBlock", ADMIN_LEVEL_A);

    register_dictionary("private_message.txt");
}

public CmdMessagesBlock(id, level, cid)
{
    if(!cmd_access(id, level, cid, 0))
        return PLUGIN_HANDLED;

    new bool:block = pm_is_chat_blocked();
    pm_block_use(!block);
    client_print_color(0, print_team_default, "%l %l", "PM_PREFIX", block ? "PM_BLOCKED_UNBLOCKED_ADMIN" : "PM_BLOCKED_BLOCKED_ADMIN", id);
    return PLUGIN_HANDLED;
}