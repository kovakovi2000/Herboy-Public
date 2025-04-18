#include <amxmodx>
#include <fakemeta>

public plugin_init() register_message(107, "StatusIcon");

public StatusIcon(msg, dest, id) {
    new icon[8]; get_msg_arg_string(2, icon, 7);

    if(equal(icon, "buyzone") && get_msg_arg_int(1)) {
        set_pdata_int(id, 235, get_pdata_int(id, 235) & ~(1<<0));
        return 1;
    }
    return 0;
} 