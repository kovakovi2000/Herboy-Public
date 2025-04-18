#include <amxmodx>
#include <amxmisc>

#define PLUGIN "BombaHangok"
#define VERSION "1.0"
#define AUTHOR "THRILLER"


forward bomb_planted(planter);



public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
}

new bomb_sounds[][] = 
{
	"herboynew/planted1",
	"herboynew/planted2",
	"herboynew/planted3"
}

public plugin_precache(){
	precache_sound("herboynew/planted1.wav")
	precache_sound("herboynew/planted2.wav")
	precache_sound("herboynew/planted3.wav")
}


public bomb_planted(id) {    

	client_cmd(0,"spk %s",bomb_sounds[random(sizeof bomb_sounds)]);
}
