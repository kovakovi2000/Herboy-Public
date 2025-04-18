/*	Copyright © 2009, ConnorMcLeod

	Reload Status Bar is free software;
	you can redistribute it and/or modify it under the terms of the
	GNU General Public License as published by the Free Software Foundation.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with Reload Status Bar; if not, write to the
	Free Software Foundation, Inc., 59 Temple Place - Suite 330,
	Boston, MA 02111-1307, USA.
*/

#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>

#define PLUGIN "Reload Speed"
#define AUTHOR "ConnorMcLeod"
#define VERSION "1.0.0"

const NOCLIP_WPN_BS	= ((1<<2)|(1<<CSW_HEGRENADE)|(1<<CSW_SMOKEGRENADE)|(1<<CSW_FLASHBANG)|(1<<CSW_KNIFE)|(1<<CSW_C4))
const SHOTGUNS_BS	= ((1<<CSW_M3)|(1<<CSW_XM1014))

const m_pPlayer			= 41
const m_fInReload			= 54

const m_flNextAttack		= 83

new gmsgBarTime2

new g_pCvarReloadSpeed, g_pCvarReloadBar

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)

	g_pCvarReloadSpeed = register_cvar("amx_reload_speed", "0.2")
	g_pCvarReloadBar = register_cvar("amx_reload_bar", "1")

	new szWeapon[17]
	for(new i=1; i<=CSW_P90; i++)
	{
		if(	!( NOCLIP_WPN_BS & (1<<i) )
		&&	!( SHOTGUNS_BS & (1<<i) )
		&&	get_weaponname(i, szWeapon, charsmax(szWeapon)) )
		{
			RegisterHam(Ham_Weapon_Reload, szWeapon, "Weapon_Reload", 1)
			RegisterHam(Ham_Item_Holster, szWeapon, "Item_Holster")

		}
	}

	gmsgBarTime2 = get_user_msgid("BarTime2")
}

public Weapon_Reload( iEnt )
{
	if( get_pdata_int(iEnt, m_fInReload, 4) )
	{
		new id = get_pdata_cbase(iEnt, m_pPlayer, 4)
		new Float:flNextAttack = get_pdata_float(id, m_flNextAttack, 5) * get_pcvar_float(g_pCvarReloadSpeed)
		set_pdata_float(id, m_flNextAttack, flNextAttack, 5)
		
		if( get_pcvar_num(g_pCvarReloadBar) )
		{
			new iSeconds = floatround(flNextAttack, floatround_ceil)
			Make_BarTime2(id, iSeconds, 100 - floatround( (flNextAttack/iSeconds) * 100 ))
		}
	}
}

public Item_Holster( iEnt )
{
	if( get_pdata_int(iEnt, m_fInReload, 4) )
	{
		Make_BarTime2(get_pdata_cbase(iEnt, m_pPlayer, 4), 0, 0)
	}
}

Make_BarTime2(id, iSeconds, iPercent)
{
	message_begin(MSG_ONE_UNRELIABLE, gmsgBarTime2, _, id)
	write_short(iSeconds)
	write_short(iPercent)
	message_end()
}
