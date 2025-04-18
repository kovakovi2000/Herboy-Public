#include <amxmodx>
#include <hamsandwich>
#include <fakemeta>
#include <xs>

#define MAX_PLAYERS		32

enum
{
	normal,
	slower,
	medium
}

const m_pPlayer  = 		41
const XoCGrenade = 		4

new const GrenadeClassNames[][] =
{
	"weapon_flashbang",
	"weapon_hegrenade" //,"weapon_smokegrenade"
}

new const Float:VelocityMultiplier[] =
{
	1.0,
	0.5,
	0.7
}

new HandleThrowType[MAX_PLAYERS+1]

public plugin_init()
{
	new const PluginVersion[] = "1.1"
	register_plugin("Pop Grenades",PluginVersion,"EFFx/HamletEagle")

	register_event("CurWeapon", "event_CurWeapon", "be", "1=1")

	for(new i; i < sizeof GrenadeClassNames; i++)
	{
		RegisterHam(Ham_Weapon_SecondaryAttack, GrenadeClassNames[i], "CBasePlayerWpn_SecondaryAttack", false)
	}
}

public event_CurWeapon(id)
{
	HandleThrowType[id] = normal
}

public CBasePlayerWpn_SecondaryAttack(const grenadeEntity)
{
	if(pev_valid(grenadeEntity))
	{
		new id = get_pdata_cbase(grenadeEntity, m_pPlayer, XoCGrenade)
		new buttons = pev(id, pev_button)
		
		if(buttons & IN_ATTACK)
		{
			HandleThrowType[id] = medium
		}
		else 
		{
			HandleThrowType[id] = slower
		}
		
		ExecuteHamB(Ham_Weapon_PrimaryAttack, grenadeEntity)
	}
}

public grenade_throw(id, grenadeEntity, grenadeWeaponIndex) 
{
	if(pev_valid(grenadeEntity))
	{
		new Float:grenadeVelocity[3]
		pev(grenadeEntity, pev_velocity, grenadeVelocity)
		
		new Float:multiplier = VelocityMultiplier[HandleThrowType[id]]
		xs_vec_mul_scalar(grenadeVelocity, multiplier, grenadeVelocity)
		set_pev(grenadeEntity, pev_velocity, grenadeVelocity)
		
		HandleThrowType[id] = normal
	}
}  
