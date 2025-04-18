#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fakemeta>

#define PLUGIN "EntityDataDisplay"
#define VERSION "1.0.0"
#define AUTHOR "Kova"

#define g_Slot 32
#define EDD_TaskID 3453463
#define EV_FL_ZT 3453463

#define g_Classname_Originer "Originer"
//#define g_Model_Originer "models/ZW/w_Originer.mdl"
#define g_ThinkTime 0.01

new bool:p_EDD[g_Slot+1];
new TypedEnt[g_Slot+1];
new OriginerEnt[g_Slot+1];
new ToggleOriginer[g_Slot+1];

new String[1024];
new Len;
new Dis[33];

new g_MsgSync_0;
new g_MsgSync_1;

public plugin_init() 
{
    register_plugin(PLUGIN, VERSION, AUTHOR)

    register_clcmd("EDD", "SwitchEntityDataDisplay");
}

public plugin_precache()
{
    g_MsgSync_0 = CreateHudSyncObj();
    g_MsgSync_1 = CreateHudSyncObj();
    //precache_model(g_Model_Originer);
}

public ShowOriginer(id)
{
    if(TypedEnt[id] == 0 || ToggleOriginer[id] != 0)
        return;

    if(OriginerEnt[id] != 0)
    {
        remove_entity(OriginerEnt[id]);
        return;
    }

    ToggleOriginer[id] = 1;
    OriginerEnt[id] = 0;

    //new Float:bone_origin[3], Float:bone_angles[3];
    //engfunc(EngFunc_GetBonePosition, TypedEnt[id], BoneNum[id], bone_origin, bone_angles);

    new iEnt = create_entity("info_target");
    OriginerEnt[id] = iEnt;
    entity_set_string(iEnt, EV_SZ_classname, g_Classname_Originer);
    //entity_set_model(iEnt, g_Model_Originer);
    entity_set_int(iEnt, EV_INT_movetype, MOVETYPE_FOLLOW);
    set_pev(iEnt, pev_aiment, TypedEnt[id]);
    set_pev(iEnt, pev_rendermode, kRenderNormal);
    //entity_set_int(iEnt, EV_INT_solid, SOLID_BBOX);
    entity_set_byte(iEnt, EV_BYTE_controller1, 125);
    entity_set_size(iEnt, Float:{0.0, 0.0, 0.0}, Float:{0.0, 0.0, 0.0});
    set_pev(iEnt, pev_owner, id);
}

public Entity_list_all(id)
{
    new entitycount = entity_count();
    new Step = -1;
    new counted;
    new ClassName[32];
    new Model[128];
    console_print(id, "Entity list:")
    do
    {
        Step++;
        if(is_valid_ent(Step))
        {
            counted++;
            entity_get_string(Step, EV_SZ_classname, ClassName, 32);
            entity_get_string(Step, EV_SZ_model, Model, 128);
            console_print(id, "%4.0f* | C: %s | M: %s",float(Step), ClassName, Model);
        }
        if(Step > 2048)
            break;
    }
    while(entitycount != counted)
}

public SwitchEntityDataDisplay(id)
{
    new Arg[32];
    new Arg2[32];
    read_argv(1, Arg, charsmax(Arg));
    read_argv(2, Arg2, charsmax(Arg2));

    if(str_to_num(Arg) != 0)
        TypedEnt[id] = str_to_num(Arg);
    else if(equal(Arg, "me"))
        TypedEnt[id] = id;
    else if(equal(Arg, "c"))
        TypedEnt[id] = -1;
    else if(equal(Arg, "0"))
    {
        TypedEnt[id] = 0;

        if(OriginerEnt[id] != 0) remove_entity(OriginerEnt[id]);
        OriginerEnt[id] = 0;
        ToggleOriginer[id] = 0;
    }
    else if(equal(Arg, "z"))
    {
        Enity_Move_Z(TypedEnt[id], float(str_to_num(Arg2)));
        return;
    }
    else if(equal(Arg, "x"))
    {
        Enity_Move_X(TypedEnt[id], float(str_to_num(Arg2)));
    }
    else if(equal(Arg, "y"))
    {
        Enity_Move_Y(TypedEnt[id], float(str_to_num(Arg2)));
    }
    else if(equal(Arg, "del"))
    {
        remove_entity(str_to_num(Arg2));
        return;
    }
    else if(equal(Arg, "list"))
    {
        Entity_list_all(id);
        return;
    }
    else if(equal(Arg, "dis"))
    {
        Dis[id] = str_to_num(Arg2)
        return;
    }
    else if(equal(Arg, "loc"))
    {
        new Float:Origin[3];
        pev(TypedEnt[id], pev_origin, Origin);
        console_print(id, "%i* | X=%.3f | Y=%.3f | Z=%.3f^n", TypedEnt[id], Origin[0], Origin[1], Origin[2]);
        return;
    }
    else
        p_EDD[id] = !p_EDD[id];
    
    new p[32],n, bool:Was = false;
    get_players(p,n,"ch");
    for(new i=0;i<n;i++)
    {
        if(p_EDD[p[i]])
            Was = true;
    }
    new TaskExist = task_exists(EDD_TaskID,_);
    if( Was && TaskExist )
        return;
    else if(Was && !TaskExist)
        set_task(0.1, "t_EDD", EDD_TaskID,_,_,"b");
    else if(!Was && TaskExist)
    {
        remove_task(EDD_TaskID,_);
        new p[32],n, forID;
        get_players(p,n,"ach");
        for(new i=0;i<n;i++)
        {
            forID = p[i];
            if(is_valid_ent(OriginerEnt[forID]))
            {
                remove_entity(OriginerEnt[forID]);
                OriginerEnt[forID] = 0;
                ToggleOriginer[forID] = 0;
            }
        }
    }

}

public Enity_Move_Z(iEnt, Float:Distance)
{
    client_print_color(0, print_team_default, "^4[EDD] ^1Entity:%i ^4| ^1Moved on Z:%.3f", iEnt, Distance);
    new Float:tOrigin[3];
    pev(iEnt, pev_origin, tOrigin)
    tOrigin[2] += Distance;
    entity_set_origin(iEnt, tOrigin);
}

public Enity_Move_X(iEnt, Float:Distance)
{
    client_print_color(0, print_team_default, "^4[EDD] ^1Entity:%i ^4| ^1Moved on X:%.3f", iEnt, Distance);
    new Float:tOrigin[3];
    pev(iEnt, pev_origin, tOrigin)
    tOrigin[0] += Distance;
    entity_set_origin(iEnt, tOrigin);
}

public Enity_Move_Y(iEnt, Float:Distance)
{
    client_print_color(0, print_team_default, "^4[EDD] ^1Entity:%i ^4| ^1Moved on Y:%.3f", iEnt, Distance);
    new Float:tOrigin[3];
    pev(iEnt, pev_origin, tOrigin)
    tOrigin[1] += Distance;
    entity_set_origin(iEnt, tOrigin);
}

public t_EDD()
{
    new p[32],n;
    get_players(p,n,"ach");
    for(new i=0;i<n;i++)
        h_EDD(p[i]);
}

public h_EDD(id)
{
    new NextHC = next_hudchannel(id);
    Len = 0;
    switch(Dis[id])
    {
        case 0:
        {
            Len += formatex(String[Len], charsmax(String) - Len, "EntityDataDisplay^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EntID:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "ClassName:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "Model:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "HP:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "Origin:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "Angle:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "AnimID:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "Distance:^n");
        }
        case 1:
        {
            Len += formatex(String[Len], charsmax(String) - Len, "EntityDataDisplay^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EntID:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_INT_gamestate:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_INT_oldbuttons:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_INT_groupinfo:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_INT_iuser1:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_INT_iuser2:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_INT_iuser3:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_INT_iuser4:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_INT_weaponanim:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_INT_pushmsec:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_INT_bInDuck:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_INT_flTimeStepSound:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_INT_flSwimTime:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_INT_flDuckTime:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_INT_iStepLeft:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_INT_movetype:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_INT_solid:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_INT_skin:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_INT_body:^n");
        }
        case 2:
        {
            Len += formatex(String[Len], charsmax(String) - Len, "EntityDataDisplay^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EntID:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_INT_effects:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_INT_light_level:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_INT_sequence:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_INT_gaitsequence:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_INT_modelindex:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_INT_playerclass:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_INT_waterlevel:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_INT_watertype:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_INT_spawnflags:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_INT_flags:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_INT_colormap:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_INT_team:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_INT_fixangle:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_INT_weapons:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_INT_rendermode:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_INT_renderfx:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_INT_button:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_INT_impulse:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_INT_deadflag:^n");
        }
        case 3:
        {
            Len += formatex(String[Len], charsmax(String) - Len, "EntityDataDisplay^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EntID:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_FL_impacttime:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_FL_starttime:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_FL_idealpitch:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_FL_pitch_speed:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_FL_ideal_yaw:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_FL_yaw_speed:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_FL_ltime:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_FL_nextthink:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_FL_gravity:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_FL_friction:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_FL_frame:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_FL_animtime:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_FL_framerate:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_FL_health:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_FL_frags:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_FL_takedamage:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_FL_max_health:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_FL_teleport_time:^n");
        }
        case 4:
        {
            Len += formatex(String[Len], charsmax(String) - Len, "EntityDataDisplay^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EntID:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_FL_armortype:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_FL_armorvalue:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_FL_dmg_take:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_FL_dmg_save:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_FL_dmg:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_FL_dmgtime:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_FL_speed:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_FL_air_finished:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_FL_pain_finished:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_FL_radsuit_finished:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_FL_scale:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_FL_renderamt:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_FL_maxspeed:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_FL_fov:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_FL_flFallVelocity:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_FL_fuser1:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_FL_fuser2:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_FL_fuser3:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_FL_fuser4:^n");
        }
        case 5:
        {
            Len += formatex(String[Len], charsmax(String) - Len, "EntityDataDisplay^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EntID:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_VEC_origin:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_VEC_oldorigin:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_VEC_velocity:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_VEC_basevelocity:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_VEC_clbasevelocity:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_VEC_movedir:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_VEC_angles:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_VEC_avelocity:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_VEC_punchangle:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_VEC_v_angle:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_VEC_endpos:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_VEC_startpos:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_VEC_absmin:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_VEC_absmax:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_VEC_mins:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_VEC_maxs:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_VEC_size:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_VEC_rendercolor:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_VEC_view_ofs:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_VEC_vuser1:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_VEC_vuser2:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_VEC_vuser3:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_VEC_vuser4:^n");
        }
        case 6:
        {
            Len += formatex(String[Len], charsmax(String) - Len, "EntityDataDisplay^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EntID:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_ENT_chain:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_ENT_dmg_inflictor:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_ENT_enemy:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_ENT_aiment:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_ENT_owner:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_ENT_groundentity:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_ENT_pContainingEntity:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_ENT_euser1:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_ENT_euser2:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_ENT_euser3:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_ENT_euser4:^n");
        }
        case 7:
        {
            Len += formatex(String[Len], charsmax(String) - Len, "EntityDataDisplay^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EntID:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_SZ_classname:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_SZ_globalname:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_SZ_model:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_SZ_target:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_SZ_targetname:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_SZ_netname:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_SZ_message:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_SZ_noise:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_SZ_noise1:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_SZ_noise2:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_SZ_noise3:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_SZ_viewmodel:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_SZ_weaponmodel:^n");
        }
        case 8:
        {
            Len += formatex(String[Len], charsmax(String) - Len, "EntityDataDisplay^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EntID:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_BYTE_controller1:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_BYTE_controller2:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_BYTE_controller3:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_BYTE_controller4:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_BYTE_blending1:^n");
            Len += formatex(String[Len], charsmax(String) - Len, "EV_BYTE_blending2:^n");
        }
    }
    
    set_hudmessage(255, 255, 255, 0.11, 0.0, 0, 0.0, 0.2, 0.0, 0.0, NextHC);
    ShowSyncHudMsg(id, g_MsgSync_0, String);
    
    new body;
    if(TypedEnt[id] == 0)
        get_user_aiming(id, TypedEnt[id], body);
    else if(TypedEnt[id] == -1)
    {
        new Float:MinDistance = 9999999.0;
        new Float:NowDistance = 0.0;
        new Closest_iEnt = 0;
        new Float:iOrigin[3];
        new Float:eOrigin[3];
        pev(id, pev_origin, iOrigin);
        for(new i = 0; i < 255; i++)
        {
            if(i == id || !is_valid_ent(i))
                continue;
            
            pev(i,pev_origin, eOrigin);
            NowDistance = get_distance_f(iOrigin, eOrigin);
            if(0.001 < NowDistance < MinDistance)
            {
                MinDistance = NowDistance;
                Closest_iEnt = i;
            }
        }
        TypedEnt[id] = Closest_iEnt;
    }
    new iEnt;
    iEnt = TypedEnt[id];

    if (!is_valid_ent(iEnt)) 
    {
        Len = 0;
        Len += formatex(String[Len], charsmax(String) - Len, "^n         %i - INVALID^n", iEnt);
        set_hudmessage(255, 0, 0, 0.30, 0.0, 0, 0.0, 0.2, 0.0, 0.0, NextHC);
        ShowSyncHudMsg(id, g_MsgSync_1, String);
        return;
    }

    Len = 0;
    Len += formatex(String[Len], charsmax(String) - Len, "- FOUND^n");
    Len += formatex(String[Len], charsmax(String) - Len, "%i^n", iEnt);//EntID
    new ClassName[32];
    entity_get_string(iEnt, EV_SZ_classname, ClassName, 31);
    switch(Dis[id])
    {
        case 0:
        {
            Len += formatex(String[Len], charsmax(String) - Len, "%s^n", ClassName);//ClassName
            new Model[128];
            entity_get_string(iEnt, EV_SZ_model, Model, 128);
            Len += formatex(String[Len], charsmax(String) - Len, "%s^n", Model);//Model
            new Float:health;
            pev(iEnt, pev_health, health)
            Len += formatex(String[Len], charsmax(String) - Len, "%.0f^n", health);//HP
            new Float:Origin[3];
            pev(iEnt, pev_origin, Origin);
            Len += formatex(String[Len], charsmax(String) - Len, "X=%.3f | Y=%.3f | Z=%.3f^n", Origin[0], Origin[1], Origin[2]);//Origin
            new Float:Angle[3];
            pev(iEnt, pev_angles, Angle);
            Len += formatex(String[Len], charsmax(String) - Len, "Vertical=%.3f | Horizontal=%.3f | Null=%.3f^n", Angle[0], Angle[1], Angle[2]);//Angle
            new sequence = entity_get_int(iEnt, EV_INT_sequence);
            Len += formatex(String[Len], charsmax(String) - Len, "%i^n", sequence);//Anim
            new Float:iOrigin[3];
            pev(id, pev_origin, iOrigin);
            new Float:Distance = get_distance_f(iOrigin, Origin);
            Len += formatex(String[Len], charsmax(String) - Len, "%.3f^n", Distance);//Distance
        }
        case 1:
        {
            static _Int;
            _Int = entity_get_int(iEnt, EV_INT_gamestate);
            Len += formatex(String[Len], charsmax(String) - Len, "%i^n", _Int);
            _Int = entity_get_int(iEnt, EV_INT_oldbuttons);
            Len += formatex(String[Len], charsmax(String) - Len, "%i^n", _Int);
            _Int = entity_get_int(iEnt, EV_INT_groupinfo);
            Len += formatex(String[Len], charsmax(String) - Len, "%i^n", _Int);
            _Int = entity_get_int(iEnt, EV_INT_iuser1);
            Len += formatex(String[Len], charsmax(String) - Len, "%i^n", _Int);
            _Int = entity_get_int(iEnt, EV_INT_iuser2);
            Len += formatex(String[Len], charsmax(String) - Len, "%i^n", _Int);
            _Int = entity_get_int(iEnt, EV_INT_iuser3);
            Len += formatex(String[Len], charsmax(String) - Len, "%i^n", _Int);
            _Int = entity_get_int(iEnt, EV_INT_iuser4);
            Len += formatex(String[Len], charsmax(String) - Len, "%i^n", _Int);
            _Int = entity_get_int(iEnt, EV_INT_weaponanim);
            Len += formatex(String[Len], charsmax(String) - Len, "%i^n", _Int);
            _Int = entity_get_int(iEnt, EV_INT_pushmsec);
            Len += formatex(String[Len], charsmax(String) - Len, "%i^n", _Int);
            _Int = entity_get_int(iEnt, EV_INT_bInDuck);
            Len += formatex(String[Len], charsmax(String) - Len, "%i^n", _Int);
            _Int = entity_get_int(iEnt, EV_INT_flTimeStepSound);
            Len += formatex(String[Len], charsmax(String) - Len, "%i^n", _Int);
            _Int = entity_get_int(iEnt, EV_INT_flSwimTime);
            Len += formatex(String[Len], charsmax(String) - Len, "%i^n", _Int);
            _Int = entity_get_int(iEnt, EV_INT_flDuckTime);
            Len += formatex(String[Len], charsmax(String) - Len, "%i^n", _Int);
            _Int = entity_get_int(iEnt, EV_INT_iStepLeft);
            Len += formatex(String[Len], charsmax(String) - Len, "%i^n", _Int);
            _Int = entity_get_int(iEnt, EV_INT_movetype);
            Len += formatex(String[Len], charsmax(String) - Len, "%i^n", _Int);
            _Int = entity_get_int(iEnt, EV_INT_solid);
            Len += formatex(String[Len], charsmax(String) - Len, "%i^n", _Int);
            _Int = entity_get_int(iEnt, EV_INT_skin);
            Len += formatex(String[Len], charsmax(String) - Len, "%i^n", _Int);
            _Int = entity_get_int(iEnt, EV_INT_body);
            Len += formatex(String[Len], charsmax(String) - Len, "%i^n", _Int);
        }
        case 2:
        {
            static _Int;
            _Int = entity_get_int(iEnt, EV_INT_effects);
            Len += formatex(String[Len], charsmax(String) - Len, "%i^n", _Int);
            _Int = entity_get_int(iEnt, EV_INT_light_level);
            Len += formatex(String[Len], charsmax(String) - Len, "%i^n", _Int);
            _Int = entity_get_int(iEnt, EV_INT_sequence);
            Len += formatex(String[Len], charsmax(String) - Len, "%i^n", _Int);
            _Int = entity_get_int(iEnt, EV_INT_gaitsequence);
            Len += formatex(String[Len], charsmax(String) - Len, "%i^n", _Int);
            _Int = entity_get_int(iEnt, EV_INT_modelindex);
            Len += formatex(String[Len], charsmax(String) - Len, "%i^n", _Int);
            _Int = entity_get_int(iEnt, EV_INT_playerclass);
            Len += formatex(String[Len], charsmax(String) - Len, "%i^n", _Int);
            _Int = entity_get_int(iEnt, EV_INT_waterlevel);
            Len += formatex(String[Len], charsmax(String) - Len, "%i^n", _Int);
            _Int = entity_get_int(iEnt, EV_INT_watertype);
            Len += formatex(String[Len], charsmax(String) - Len, "%i^n", _Int);
            _Int = entity_get_int(iEnt, EV_INT_spawnflags);
            Len += formatex(String[Len], charsmax(String) - Len, "%i^n", _Int);
            _Int = entity_get_int(iEnt, EV_INT_flags);
            Len += formatex(String[Len], charsmax(String) - Len, "%i^n", _Int);
            _Int = entity_get_int(iEnt, EV_INT_colormap);
            Len += formatex(String[Len], charsmax(String) - Len, "%i^n", _Int);
            _Int = entity_get_int(iEnt, EV_INT_team);
            Len += formatex(String[Len], charsmax(String) - Len, "%i^n", _Int);
            _Int = entity_get_int(iEnt, EV_INT_fixangle);
            Len += formatex(String[Len], charsmax(String) - Len, "%i^n", _Int);
            _Int = entity_get_int(iEnt, EV_INT_weapons);
            Len += formatex(String[Len], charsmax(String) - Len, "%i^n", _Int);
            _Int = entity_get_int(iEnt, EV_INT_rendermode);
            Len += formatex(String[Len], charsmax(String) - Len, "%i^n", _Int);
            _Int = entity_get_int(iEnt, EV_INT_renderfx);
            Len += formatex(String[Len], charsmax(String) - Len, "%i^n", _Int);
            _Int = entity_get_int(iEnt, EV_INT_button);
            Len += formatex(String[Len], charsmax(String) - Len, "%i^n", _Int);
            _Int = entity_get_int(iEnt, EV_INT_impulse);
            Len += formatex(String[Len], charsmax(String) - Len, "%i^n", _Int);
            _Int = entity_get_int(iEnt, EV_INT_deadflag);
            Len += formatex(String[Len], charsmax(String) - Len, "%i^n", _Int);
        }
        case 3:
        {
            static Float:_Float;
            _Float = entity_get_float(iEnt, EV_FL_impacttime);
            Len += formatex(String[Len], charsmax(String) - Len, "%.3f^n", _Float);
            _Float = entity_get_float(iEnt, EV_FL_starttime);
            Len += formatex(String[Len], charsmax(String) - Len, "%.3f^n", _Float);
            _Float = entity_get_float(iEnt, EV_FL_idealpitch);
            Len += formatex(String[Len], charsmax(String) - Len, "%.3f^n", _Float);
            _Float = entity_get_float(iEnt, EV_FL_pitch_speed);
            Len += formatex(String[Len], charsmax(String) - Len, "%.3f^n", _Float);
            _Float = entity_get_float(iEnt, EV_FL_ideal_yaw);
            Len += formatex(String[Len], charsmax(String) - Len, "%.3f^n", _Float);
            _Float = entity_get_float(iEnt, EV_FL_yaw_speed);
            Len += formatex(String[Len], charsmax(String) - Len, "%.3f^n", _Float);
            _Float = entity_get_float(iEnt, EV_FL_ltime);
            Len += formatex(String[Len], charsmax(String) - Len, "%.3f^n", _Float);
            _Float = entity_get_float(iEnt, EV_FL_nextthink);
            Len += formatex(String[Len], charsmax(String) - Len, "%.3f^n", _Float);
            _Float = entity_get_float(iEnt, EV_FL_gravity);
            Len += formatex(String[Len], charsmax(String) - Len, "%.3f^n", _Float);
            _Float = entity_get_float(iEnt, EV_FL_friction);
            Len += formatex(String[Len], charsmax(String) - Len, "%.3f^n", _Float);
            _Float = entity_get_float(iEnt, EV_FL_frame);
            Len += formatex(String[Len], charsmax(String) - Len, "%.3f^n", _Float);
            _Float = entity_get_float(iEnt, EV_FL_animtime);
            Len += formatex(String[Len], charsmax(String) - Len, "%.3f^n", _Float);
            _Float = entity_get_float(iEnt, EV_FL_framerate);
            Len += formatex(String[Len], charsmax(String) - Len, "%.3f^n", _Float);
            _Float = entity_get_float(iEnt, EV_FL_health);
            Len += formatex(String[Len], charsmax(String) - Len, "%.3f^n", _Float);
            _Float = entity_get_float(iEnt, EV_FL_frags);
            Len += formatex(String[Len], charsmax(String) - Len, "%.3f^n", _Float);
            _Float = entity_get_float(iEnt, EV_FL_takedamage);
            Len += formatex(String[Len], charsmax(String) - Len, "%.3f^n", _Float);
            _Float = entity_get_float(iEnt, EV_FL_max_health);
            Len += formatex(String[Len], charsmax(String) - Len, "%.3f^n", _Float);
            _Float = entity_get_float(iEnt, EV_FL_teleport_time);
            Len += formatex(String[Len], charsmax(String) - Len, "%.3f^n", _Float);
        }
        case 4:
        {
            static Float:_Float;
            _Float = entity_get_float(iEnt, EV_FL_armortype);
            Len += formatex(String[Len], charsmax(String) - Len, "%.3f^n", _Float);
            _Float = entity_get_float(iEnt, EV_FL_armorvalue);
            Len += formatex(String[Len], charsmax(String) - Len, "%.3f^n", _Float);
            _Float = entity_get_float(iEnt, EV_FL_dmg_take);
            Len += formatex(String[Len], charsmax(String) - Len, "%.3f^n", _Float);
            _Float = entity_get_float(iEnt, EV_FL_dmg_save);
            Len += formatex(String[Len], charsmax(String) - Len, "%.3f^n", _Float);
            _Float = entity_get_float(iEnt, EV_FL_dmg);
            Len += formatex(String[Len], charsmax(String) - Len, "%.3f^n", _Float);
            _Float = entity_get_float(iEnt, EV_FL_dmgtime);
            Len += formatex(String[Len], charsmax(String) - Len, "%.3f^n", _Float);
            _Float = entity_get_float(iEnt, EV_FL_speed);
            Len += formatex(String[Len], charsmax(String) - Len, "%.3f^n", _Float);
            _Float = entity_get_float(iEnt, EV_FL_air_finished);
            Len += formatex(String[Len], charsmax(String) - Len, "%.3f^n", _Float);
            _Float = entity_get_float(iEnt, EV_FL_pain_finished);
            Len += formatex(String[Len], charsmax(String) - Len, "%.3f^n", _Float);
            _Float = entity_get_float(iEnt, EV_FL_radsuit_finished);
            Len += formatex(String[Len], charsmax(String) - Len, "%.3f^n", _Float);
            _Float = entity_get_float(iEnt, EV_FL_scale);
            Len += formatex(String[Len], charsmax(String) - Len, "%.3f^n", _Float);
            _Float = entity_get_float(iEnt, EV_FL_renderamt);
            Len += formatex(String[Len], charsmax(String) - Len, "%.3f^n", _Float);
            _Float = entity_get_float(iEnt, EV_FL_maxspeed);
            Len += formatex(String[Len], charsmax(String) - Len, "%.3f^n", _Float);
            _Float = entity_get_float(iEnt, EV_FL_fov);
            Len += formatex(String[Len], charsmax(String) - Len, "%.3f^n", _Float);
            _Float = entity_get_float(iEnt, EV_FL_flFallVelocity);
            Len += formatex(String[Len], charsmax(String) - Len, "%.3f^n", _Float);
            _Float = entity_get_float(iEnt, EV_FL_fuser1);
            Len += formatex(String[Len], charsmax(String) - Len, "%.3f^n", _Float);
            _Float = entity_get_float(iEnt, EV_FL_fuser2);
            Len += formatex(String[Len], charsmax(String) - Len, "%.3f^n", _Float);
            _Float = entity_get_float(iEnt, EV_FL_fuser3);
            Len += formatex(String[Len], charsmax(String) - Len, "%.3f^n", _Float);
            _Float = entity_get_float(iEnt, EV_FL_fuser4);
            Len += formatex(String[Len], charsmax(String) - Len, "%.3f^n", _Float);
        }
        case 5:
        {

        }
        case 6:
        {
            static _Int;
            _Int = entity_get_int(iEnt, EV_ENT_chain);
            Len += formatex(String[Len], charsmax(String) - Len, "%i^n", _Int);
            _Int = entity_get_int(iEnt, EV_ENT_dmg_inflictor);
            Len += formatex(String[Len], charsmax(String) - Len, "%i^n", _Int);
            _Int = entity_get_int(iEnt, EV_ENT_enemy);
            Len += formatex(String[Len], charsmax(String) - Len, "%i^n", _Int);
            _Int = entity_get_int(iEnt, EV_ENT_aiment);
            Len += formatex(String[Len], charsmax(String) - Len, "%i^n", _Int);
            _Int = entity_get_int(iEnt, EV_ENT_owner);
            Len += formatex(String[Len], charsmax(String) - Len, "%i^n", _Int);
            _Int = entity_get_int(iEnt, EV_ENT_groundentity);
            Len += formatex(String[Len], charsmax(String) - Len, "%i^n", _Int);
            _Int = entity_get_int(iEnt, EV_ENT_pContainingEntity);
            Len += formatex(String[Len], charsmax(String) - Len, "%i^n", _Int);
            _Int = entity_get_int(iEnt, EV_ENT_euser1);
            Len += formatex(String[Len], charsmax(String) - Len, "%i^n", _Int);
            _Int = entity_get_int(iEnt, EV_ENT_euser2);
            Len += formatex(String[Len], charsmax(String) - Len, "%i^n", _Int);
            _Int = entity_get_int(iEnt, EV_ENT_euser3);
            Len += formatex(String[Len], charsmax(String) - Len, "%i^n", _Int);
            _Int = entity_get_int(iEnt, EV_ENT_euser4);
            Len += formatex(String[Len], charsmax(String) - Len, "%i^n", _Int);
        }
        case 7:
        {
            static _String[32];
            entity_get_string(iEnt, EV_SZ_classname, _String, 31);
            Len += formatex(String[Len], charsmax(String) - Len, "%s^n", _String);
            entity_get_string(iEnt, EV_SZ_globalname, _String, 31);
            Len += formatex(String[Len], charsmax(String) - Len, "%s^n", _String);
            entity_get_string(iEnt, EV_SZ_model, _String, 31);
            Len += formatex(String[Len], charsmax(String) - Len, "%s^n", _String);
            entity_get_string(iEnt, EV_SZ_target, _String, 31);
            Len += formatex(String[Len], charsmax(String) - Len, "%s^n", _String);
            entity_get_string(iEnt, EV_SZ_targetname, _String, 31);
            Len += formatex(String[Len], charsmax(String) - Len, "%s^n", _String);
            entity_get_string(iEnt, EV_SZ_netname, _String, 31);
            Len += formatex(String[Len], charsmax(String) - Len, "%s^n", _String);
            entity_get_string(iEnt, EV_SZ_message, _String, 31);
            Len += formatex(String[Len], charsmax(String) - Len, "%s^n", _String);
            entity_get_string(iEnt, EV_SZ_noise, _String, 31);
            Len += formatex(String[Len], charsmax(String) - Len, "%s^n", _String);
            entity_get_string(iEnt, EV_SZ_noise1, _String, 31);
            Len += formatex(String[Len], charsmax(String) - Len, "%s^n", _String);
            entity_get_string(iEnt, EV_SZ_noise2, _String, 31);
            Len += formatex(String[Len], charsmax(String) - Len, "%s^n", _String);
            entity_get_string(iEnt, EV_SZ_noise3, _String, 31);
            Len += formatex(String[Len], charsmax(String) - Len, "%s^n", _String);
            entity_get_string(iEnt, EV_SZ_viewmodel, _String, 31);
            Len += formatex(String[Len], charsmax(String) - Len, "%s^n", _String);
            entity_get_string(iEnt, EV_SZ_weaponmodel, _String, 31);
            Len += formatex(String[Len], charsmax(String) - Len, "%s^n", _String);
        }
        case 8:
        {
            static _Int;
            _Int = entity_get_int(iEnt, EV_BYTE_controller1);
            Len += formatex(String[Len], charsmax(String) - Len, "%i^n", _Int);
            _Int = entity_get_int(iEnt, EV_BYTE_controller2);
            Len += formatex(String[Len], charsmax(String) - Len, "%i^n", _Int);
            _Int = entity_get_int(iEnt, EV_BYTE_controller3);
            Len += formatex(String[Len], charsmax(String) - Len, "%i^n", _Int);
            _Int = entity_get_int(iEnt, EV_BYTE_controller4);
            Len += formatex(String[Len], charsmax(String) - Len, "%i^n", _Int);
            _Int = entity_get_int(iEnt, EV_BYTE_blending1);
            Len += formatex(String[Len], charsmax(String) - Len, "%i^n", _Int);
            _Int = entity_get_int(iEnt, EV_BYTE_blending2);
            Len += formatex(String[Len], charsmax(String) - Len, "%i^n", _Int);
        }
    }

    //Get mins and maxs
    if(p_EDD[id] && contain(ClassName, "func"))
    {
        static Float: mins[3], Float: maxs[3];
        pev(iEnt, pev_absmin, mins);
        pev(iEnt, pev_absmax, maxs);

        //Draw a box which is the size of the bounding NPC
        message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
        write_byte(TE_BOX)
        engfunc(EngFunc_WriteCoord, mins[0])
        engfunc(EngFunc_WriteCoord, mins[1])
        engfunc(EngFunc_WriteCoord, mins[2])
        engfunc(EngFunc_WriteCoord, maxs[0])
        engfunc(EngFunc_WriteCoord, maxs[1])
        engfunc(EngFunc_WriteCoord, maxs[2])
        write_short(1)  //time
        write_byte(1)   //red
        write_byte(254) //green
        write_byte(1)   //blue
        message_end();

        ShowOriginer(id);
    }

    set_hudmessage(0, 255, 0, 0.30, 0.0, 0, 0.0, 0.2, 0.0, 0.0, NextHC);
    ShowSyncHudMsg(id, g_MsgSync_1, String);
}
