#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>

#define PLUGIN_NAME "Anti He Bug"
#define PLUGIN_VERSION "1.1"
#define PLUGIN_AUTHOR "Numb"

new maxplayers;
new Float:old_gametime;

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);
	
	RegisterHam(Ham_Think, "grenade", "Ham_Think_grenade_Pre", 0);
	
	register_forward(FM_FindEntityInSphere, "FM_FindEntityInSphere_Pre", 0);
	
	maxplayers = get_maxplayers();
}	

public Ham_Think_grenade_Pre(ent)
{
	static model[32];
	pev(ent, pev_model, model, 31);
	if( equal(model, "models/w_hegrenade.mdl") )
		old_gametime = get_gametime();
	else
		old_gametime = 0.0;
}

public FM_FindEntityInSphere_Pre(start, Float:origin[3], Float:radius)
{
	if( radius!=350.0 || old_gametime!=get_gametime() )
		return FMRES_IGNORED;
	
	static hit, trace, Float:ent_origin[3], Float:abs[3], Float:fraction;
	hit = start;
	
	// run the same check to see what its result will be
	while( (hit=engfunc(EngFunc_FindEntityInSphere, hit, origin, radius))>0 )
	{
		// hit an invalid entery
		if( !pev_valid(hit) || is_origin_in_object(origin, hit) )
		{
			forward_return(FMV_CELL, hit);
			return FMRES_SUPERCEDE;
		}
		
		// aim for the body
		get_ent_origin(hit, ent_origin); // get entity origin in professional way
		engfunc(EngFunc_TraceLine, origin, ent_origin, DONT_IGNORE_MONSTERS, 0, trace);
		
		// hit body, grenade ok
		get_tr2(trace, TR_flFraction, fraction);
		if( get_tr2(trace, TR_pHit)==hit || (hit>maxplayers && fraction==1.0) )
		{
			// start backup check (de_dust2 B bug - outmap bug)
			engfunc(EngFunc_TraceLine, ent_origin, origin, DONT_IGNORE_MONSTERS, hit, trace);
			
			// hit body with backup check
			get_tr2(trace, TR_flFraction, fraction);
			if( fraction==1.0 )
			{
				forward_return(FMV_CELL, hit);
				return FMRES_SUPERCEDE;
			}
		}
		
		if( hit>maxplayers )
			continue;
		
		// aim for the head
		pev(hit, pev_absmax, abs);
		ent_origin[2] = (abs[2]-20.0);
		engfunc(EngFunc_TraceLine, origin, ent_origin, DONT_IGNORE_MONSTERS, 0, trace);
		
		// hit player head, grenade ok
		if( get_tr2(trace, TR_pHit)==hit )
		{
			// start backup check (de_dust2 B bug - outmap bug)
			engfunc(EngFunc_TraceLine, ent_origin, origin, DONT_IGNORE_MONSTERS, hit, trace);
			
			// hit player head with backup check
			get_tr2(trace, TR_flFraction, fraction);
			if( fraction==1.0 )
			{
				forward_return(FMV_CELL, hit);
				return FMRES_SUPERCEDE;
			}
		}
		
		// aim for the feet
		pev(hit, pev_absmin, abs);
		ent_origin[2] = (abs[2]+20.0);
		engfunc(EngFunc_TraceLine, origin, ent_origin, DONT_IGNORE_MONSTERS, 0, trace);
		
		// hit player feet, grenade ok
		if( get_tr2(trace, TR_pHit)==hit )
		{
			// start backup check (de_dust2 B bug - outmap bug)
			engfunc(EngFunc_TraceLine, ent_origin, origin, DONT_IGNORE_MONSTERS, hit, trace);
			
			// hit player feet with backup check
			get_tr2(trace, TR_flFraction, fraction);
			if( fraction==1.0 )
			{
				forward_return(FMV_CELL, hit);
				return FMRES_SUPERCEDE;
			}
		}
	}
	
	// grenade could not hit anything, cancel the check
	forward_return(FMV_CELL, -1);
	return FMRES_SUPERCEDE;
}

/*get_ent_origin(ent, Float:origin[3]) // this is the new way of getting entity origin (supports all entities including offset)
{
	static s_fMins_3[3], s_fMaxs_3[3];
	
	pev(ent, pev_origin, origin); // first lets get its origin or offset
	pev(ent, pev_mins, s_fMins_3);
	pev(ent, pev_maxs, s_fMaxs_3);
	
	origin[0] += ((s_fMins_3[0]+s_fMaxs_3[0])*0.5); // now with size formating we are adding to offset real entity origin (brush entity case)
	origin[1] += ((s_fMins_3[1]+s_fMaxs_3[1])*0.5); // in non brush entity case this format is 0, so to real origin we are adding 0 (nothing changes)
	origin[2] += ((s_fMins_3[2]+s_fMaxs_3[2])*0.5);
	
	return 1;
}*/

get_ent_origin(ent, Float:origin[3]) // this is the new way of getting entity origin (supports all entities including offset)
{
	static Float:absmin[3], Float:absmax[3]; // Why I figured it out only now? Why noone of you arent using absolutes???
	
	pev(ent, pev_absmin, absmin); // this way works just like one I commented, only this one requires less cpu usage...
	pev(ent, pev_absmax, absmax);
	
	origin[0] = (absmin[0]+absmax[0])*0.5;
	origin[1] = (absmin[1]+absmax[1])*0.5;
	origin[2] = (absmin[2]+absmax[2])*0.5;
	
	return 1;
}

is_origin_in_object(Float:origin[3], ent)
{
	static Float:absmin[3], Float:absmax[3];
	
	pev(ent, pev_absmin, absmin);
	pev(ent, pev_absmax, absmax);
	
	if( origin[0]>absmin[0] && origin[0]<absmax[0]
	 && origin[1]>absmin[1] && origin[1]<absmax[1]
	 && origin[2]>absmin[2] && origin[2]<absmax[2] )
		return 1;
	
	return 0;
}
