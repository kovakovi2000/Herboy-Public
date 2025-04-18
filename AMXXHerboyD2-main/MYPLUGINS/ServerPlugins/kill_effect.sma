#include <amxmodx>
#include <fakemeta>

enum colors { red, green, blue };

#define ONLY_HS
//#define ADMIN_KILL ADMIN_BAN
const g_SprEffectMinLife = 1;
const g_SprEffectMaxLife = 2;
new g_SprEffectColor[colors] = 
{
	20, // r
	20, // g
	20  // b
};
new const g_SprFiles[colors][] =
{
	"sprites/red.spr",
	"sprites/green.spr",
	"sprites/blue.spr"
};

#if AMXX_VERSION_NUM < 183
	#define message_begin_f(%1,%2,%3,%4) engfunc(EngFunc_MessageBegin, %1, %2, %3, %4)
	#define write_coord_f(%1) engfunc(EngFunc_WriteCoord, %1)
#endif
new g_SprEffect[colors];

public plugin_precache()
{
	for(new i; i < sizeof g_SprFiles; i++)
		g_SprEffect[any:i] = precache_model(g_SprFiles[any:i]);
}

public plugin_init()
{
	register_plugin("Kill Effect", "0.2", "neugomon");
	register_event("DeathMsg", "eventDeath", "a");
}

public eventDeath()
{
	new victim = read_data(2);
	if(!is_user_connected(victim))
		return;
#if defined ADMIN_KILL
	if(~get_user_flags(victim) & ADMIN_KILL)
		return;
#endif
#if defined ONLY_HS
	if(!read_data(3))
		return;
#endif		
	new Float:fOrigin[3];
	pev(victim, pev_origin, fOrigin);
	
	UTIL_SendMessage(fOrigin, red, g_SprEffect[red]);
	UTIL_SendMessage(fOrigin, green, g_SprEffect[green]);
	UTIL_SendMessage(fOrigin, blue, g_SprEffect[blue]);
}

UTIL_SendMessage(Float:fOrigin[3], colors:color, sprite)
{
	message_begin_f(MSG_BROADCAST, SVC_TEMPENTITY, Float:{0.0, 0.0, 0.0}, 0);
	write_byte(TE_SPRITETRAIL);
	write_coord_f(fOrigin[0]);
	write_coord_f(fOrigin[1]);
	write_coord_f(fOrigin[2] + 50.0);
	write_coord_f(fOrigin[0]);
	write_coord_f(fOrigin[1]);
	write_coord_f(fOrigin[2] + 30.0);
	write_short(sprite);
	write_byte(g_SprEffectColor[color]);
	write_byte(random_num(g_SprEffectMinLife, g_SprEffectMaxLife));
	write_byte(2);
	write_byte(50);
	write_byte(10);
	message_end();
}
