#include <amxmodx>  
#include <fun>
#include <cstrike>

#define PLUGIN "Gyors kes"  
#define VERSION "1.0"  
#define AUTHOR "CocaIne"   

new CVAR_SPEED
public plugin_init() {
    register_plugin(PLUGIN, VERSION, AUTHOR)
    register_event("CurWeapon","change","be","1=1")  
    CVAR_SPEED = register_cvar("kes_speed","300")
    
}

public change(id) {
    new clip, ammo  
    new weapon = get_user_weapon(id, clip, ammo)  
    if(weapon == CSW_KNIFE) {    
           
        {
	new Speed = get_pcvar_float(CVAR_SPEED)
 
        set_user_maxspeed(id, Speed)
          
        }

    }
}
