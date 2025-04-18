#include <amxmodx>
#include <hamsandwich>
#include <fakemeta>
#include <engine>
#include <xs>

#define VERSION		"0.0.1"

new g_pEnabled;

public plugin_init()
{
	register_plugin( "No Shoot Through Walls", VERSION, "hornet" );
	
	g_pEnabled = register_cvar( "nowalls_enabled", "1" );
	
	RegisterHam( Ham_TraceAttack, "player", "CBasePlayer_TraceAttack" );
}

public CBasePlayer_TraceAttack( iVictim, iAttacker, Float:flDamage, Float:vDirection[ 3 ], ptr, Bits )
{
	if( get_pcvar_num( g_pEnabled ) && iAttacker && get_user_weapon( iAttacker ) != CSW_KNIFE )
	{
		static Float:vStart[ 3 ], Float:vEnd[ 3 ], Float:flFraction;
		
		get_tr2( ptr, TR_vecEndPos, vEnd );
		get_tr2( ptr, TR_flFraction, flFraction );
		
		xs_vec_mul_scalar( vDirection, -1.0, vDirection );
		xs_vec_mul_scalar( vDirection, flFraction * 9999.0, vStart );
		xs_vec_add( vStart, vEnd, vStart );
		
		new iTarget = trace_line( iVictim, vEnd, vStart, vEnd );
		
		if( !iTarget )
			return HAM_SUPERCEDE;
	}
	
	return HAM_IGNORED;
}