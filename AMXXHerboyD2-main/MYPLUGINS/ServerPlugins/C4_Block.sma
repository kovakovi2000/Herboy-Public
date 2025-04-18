
#include <amxmodx>
#include <reapi>

public plugin_init()
{
    register_plugin("C4_Block", "2.0.0", "Ek1`");
    RegisterHookChain(RG_CSGameRules_GiveC4, "CSGameRules_GiveC4_Pre", MaxClients);
}

public CSGameRules_GiveC4_Pre()
{
    new Players[32];
    new Count;
    get_players(Players, Count, "ach", "T");
    if (Count < 2)
    {
        client_print_color(MaxClients, -2, "\x04[\x01~\x03|\x04HerBoy\x03|\x01~\x04] \x03» \x01A \x03Bomba \x01nincs kiadva ha\x03 1 Játékos \x01van.");
        SetHookChainReturn(ATYPE_INTEGER, 0);
        return HC_SUPERCEDE
    }
    return HC_CONTINUE
}

 