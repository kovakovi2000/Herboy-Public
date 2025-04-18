#include <amxmodx>
#include <cstrike>
#include <fun>
#include <sk_utils>
 
new const Version[] = "0.1";
 
const MaxPlayers = 32;
 
new g_pCvarKillPoints;
new g_iCurrentZoom[ MaxPlayers + 1 ];
 
public plugin_init()
{
    register_plugin( "No Scope Announce" , Version , "bugsy" );
   
    register_event( "DeathMsg"  , "fw_EvDeathMsg"  , "a" , "1>0" , "4=scout" , "4=awp" );
    register_event( "CurWeapon" , "fw_EvCurWeapon" , "b" , "1=1" , "2=3" , "2=18" );
   
    g_pCvarKillPoints = register_cvar( "ns_killpoints" , "2" );
}
 
public fw_EvDeathMsg()
{
    static iKiller , szName[ 33 ], sz1Name[ 33 ], hskill[44];
   
    iKiller = read_data( 1 );
    new aldozat = read_data(2)
    new iHS = read_data(3)
 
    if ( is_user_connected( iKiller ) && ( g_iCurrentZoom[ iKiller ] == CS_SET_NO_ZOOM ) )
    {
        get_user_name( iKiller , szName , charsmax( szName ) );
        get_user_name( aldozat , sz1Name , charsmax( sz1Name ) );
        if(iHS)
        {
          sk_chat(0, "^3WÁÁÁÓÓÓÓÓ! ^4%s^1 FEJBELŐTTE ^4%s^1-t ^3NOSCOPE^1-al. ^4Gratula!", szName, sz1Name)
        }
        else 
          sk_chat(0, "^3WÁÁÁÓÓÓÓÓ! ^4%s^1 megölte ^4%s^1-t ^3NOSCOPE^1-al. ^4Gratula!", szName, sz1Name)
      
        
       
        set_user_frags( iKiller , get_user_frags( iKiller ) + 1 );
    }
}
 
public fw_EvCurWeapon( id )
{
    g_iCurrentZoom[ id ] = cs_get_user_zoom( id );
}
public LoadUtils()
{}
