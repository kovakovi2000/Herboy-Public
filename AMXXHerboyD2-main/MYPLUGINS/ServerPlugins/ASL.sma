#include <amxmodx>
#include <amxmisc>
#include <reapi>

#define PLUGIN "AirSpeedLimit"
#define VERSION "1.6"
#define AUTHOR "Kova"

#define SPEEDLIMIT 500.0

public plugin_init() {
    register_plugin(PLUGIN, VERSION, AUTHOR)

    set_task(0.1, "Check",_,_,_,"b");
}

public Check()
{
    for(new i = 0; i < 33; i++)
    {
        if(!is_user_alive(i))
            continue;

        SpeedTester(i);
    }
}

public SpeedTester(id)
{
    static Float:NewVelocity[3];
    static Float:VerticalVelocity;
    static Float:speed;

    get_entvar(id, var_velocity, NewVelocity);
    VerticalVelocity = NewVelocity[2];
    NewVelocity[2] = 0.0;
    speed = vector_length(NewVelocity);
    if(speed > SPEEDLIMIT)
    {
        NewVelocity[0] = NewVelocity[0] * (SPEEDLIMIT / speed);
        NewVelocity[1] = NewVelocity[1] * (SPEEDLIMIT / speed);
        NewVelocity[2] = VerticalVelocity;
        set_entvar(id, var_velocity, NewVelocity);
    }
}

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1038\\ f0\\ fs16 \n\\ par }
*/
