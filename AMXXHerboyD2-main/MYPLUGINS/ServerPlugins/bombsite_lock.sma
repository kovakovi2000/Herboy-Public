#include <amxmodx>
#include <colorchat>
#include <engine>

new const Version[] = "0.3";
new const PREFIX[] = "^4[^1~^3|^4HerBoy^3|^1~^4] ^3»";

enum BombSites
{
	BOMBSITE_A,
	BOMBSITE_B
}

new g_iBombSiteEntity[ BombSites ];
new bool:g_bBombSiteStatus[ BombSites ];
new g_iPlayerWithBomb;
new bool:g_bPlayerHoldingBomb;

new g_iHUDEntity;

new g_pCVarAllowPlantNum;
new g_pCVarLockSiteNum;
new g_pCVarLockSite;

public plugin_init( ) 
{
	register_plugin( "BombSite Lock" , Version , "bugsy" );
	
	register_concmd( "bl_setbombsite" , "SetBombSiteConsole" , ADMIN_KICK );
	register_concmd( "bl_bombsitemenu" , "ShowBombSiteMenu" , ADMIN_KICK );
	
	register_event( "CurWeapon" , "fw_EvCurWeapon" , "b" , "1=1" );
	register_event( "WeapPickup", "fw_EvWeapPickup" , "be" , "1=6" );
	register_event( "BombDrop" ,  "fw_EvBombDrop" , "bc" );
	
	register_logevent( "fw_EvRoundStart" , 2 , "1=Round_Start" );  

	g_pCVarAllowPlantNum = register_cvar( "bl_allowplantctnum" , "0" );
	g_pCVarLockSiteNum = register_cvar( "bl_locksitectnum" , "5" );
	g_pCVarLockSite = register_cvar( "bl_locksite" , "b" );
	
	g_iHUDEntity = create_entity( "info_target" );
	entity_set_string( g_iHUDEntity , EV_SZ_classname , "bl_hud_entity" );
	register_think( "bl_hud_entity" , "fw_HUDEntThink" );

	new szMap[ 11 ] , BombSites:bsBombSiteA , BombSites:bsBombSiteB;
	get_mapname( szMap , charsmax( szMap ) );
	
	if ( equal( szMap , "de_chateau" ) || equal( szMap , "de_dust2" ) || equal( szMap , "de_train" ) )
	{
		bsBombSiteA = BOMBSITE_B;
		bsBombSiteB = BOMBSITE_A;
	}
	else
	{
		bsBombSiteA = BOMBSITE_A;
		bsBombSiteB = BOMBSITE_B;	
	}
	
	g_iBombSiteEntity[ bsBombSiteA ] = find_ent_by_class( -1 , "func_bomb_target" );
	g_iBombSiteEntity[ bsBombSiteB ] = find_ent_by_class( g_iBombSiteEntity[ bsBombSiteA ] , "func_bomb_target" );
}

public client_disconnect( id )
{
	if ( g_iPlayerWithBomb == id )
	{
		g_iPlayerWithBomb = 0;
		g_bPlayerHoldingBomb = false;
	}
}

public fw_EvCurWeapon( id )
{
	if ( id == g_iPlayerWithBomb )
	{
		if ( read_data( 2 ) == CSW_C4 ) 
		{
			g_bPlayerHoldingBomb = true;
			entity_set_float( g_iHUDEntity , EV_FL_nextthink , ( get_gametime() + 1.0 ) );
		}
		else
		{
			g_bPlayerHoldingBomb = false;
		}
	}
}

public fw_EvWeapPickup( id )
{
	g_iPlayerWithBomb = id;
}

public fw_EvBombDrop()
{
	g_iPlayerWithBomb = 0;
	g_bPlayerHoldingBomb = false;
}

public fw_EvRoundStart()
{
	new iAllowPlantNum = get_pcvar_num( g_pCVarAllowPlantNum );
	new iLockSiteNum = get_pcvar_num( g_pCVarLockSiteNum );		
	new iPlayers[ 32 ] , iNum , iCTCount;
	
	get_players( iPlayers , iNum , "h" );
	
	for ( new i = 0 ; i < iNum ; i++ )
		if ( get_user_team( iPlayers[ i ] ) == 2 )
			iCTCount++;
	
	if ( iCTCount < iAllowPlantNum )
	{
		SetBombSiteLock( BOMBSITE_A , true );
		SetBombSiteLock( BOMBSITE_B , true );
		
	    ColorChat(0, NORMAL, "%s ^3Bombalerakó (A & B) lezárva, ameddig ^4%d CT nem lesz.^1", PREFIX, iAllowPlantNum);
	}
	else if ( iCTCount < iLockSiteNum ) 
	{
		new szSite[ 2 ];
		get_pcvar_string( g_pCVarLockSite , szSite , charsmax( szSite ) );
		szSite[ 0 ] = toupper( szSite[ 0 ] );
		
		if ( !( 'A' <= szSite[ 0 ] <= 'B' ) )
			return PLUGIN_CONTINUE;
			
		SetBombSiteLock( ( szSite[ 0 ] == 'A' ) ? BOMBSITE_A : BOMBSITE_B , true );		
		SetBombSiteLock( ( szSite[ 0 ] == 'A' ) ? BOMBSITE_B : BOMBSITE_A , false );			
		
		ColorChat(0, NORMAL, "%s ^3Bombalerakó ^4(%s) ^3lezárva, ameddig ^4%d ^3CT nem lesz.^1", PREFIX, szSite , iLockSiteNum);
	}
	else
	{
		SetBombSiteLock( BOMBSITE_A , false );
		SetBombSiteLock( BOMBSITE_B , false );
	}
	
	return PLUGIN_CONTINUE;
}

public SetBombSiteConsole( id , AdminLevel )
{
	if ( !( get_user_flags( id ) & AdminLevel ) )
	{
		console_print( id , "* Nincs engedélyed ehhez a parancshoz." );
		return PLUGIN_HANDLED;
	}
	
	if ( !g_iBombSiteEntity[ BOMBSITE_A ] || !g_iBombSiteEntity[ BOMBSITE_B ] )
	{
		console_print( id , "* Bombalerakó Lezáras: Ezen a pályán nem engedélyezett!" );
		return PLUGIN_HANDLED;
	}
	
	new szSite[ 3 ] , szState[ 3 ] , iState , BombSites:bsSite;
	read_argv( 1 , szSite , charsmax( szSite ) );
	read_argv( 2 , szState , charsmax( szState ) );
	
	iState = str_to_num( szState );

	if ( ( strlen( szSite ) > 1 ) || !is_str_num( szState ) || !( 0 <= iState <= 1 ) )
		szSite[ 0 ] = 'X';
	else
		szSite[ 0 ] = toupper( szSite[ 0 ] );
	
	switch ( szSite[ 0 ] )
	{
		case 'A':
		{
			bsSite = BOMBSITE_A;
		}
		case 'B':
		{
			bsSite = BOMBSITE_B;
		}
		default:
		{
			console_print( id , "* Bombalerakó lezárása: Ismeretlen argumentum! Megfelelő: 'fb_setbombsite a\b 0\1'" );
			return PLUGIN_HANDLED;
		}
	}
	
	SetBombSiteLock( bsSite , bool:iState );

	console_print( id , "* Bombalerakó (%s) jelenleg %s" , szSite , iState ? "szabad" : "zart" );
	
	set_hudmessage( random(255), random(255), random(255), -1.0 , 0.65 , 0 , 3.0 , 3.0 , .channel = -1 );
	show_hudmessage( 0 , "Bombalerakó (%s) jelenleg %s" , szSite , iState ? "szabad" : "zart" );
	
	return PLUGIN_HANDLED;
}

public ShowBombSiteMenu( id , AdminLevel )
{
	if ( !( get_user_flags( id ) & AdminLevel ) )
	{
		console_print( id , "* Nincs engedélyed ehhez a parancshoz." );
		return PLUGIN_HANDLED;
	}
	
	if ( !g_iBombSiteEntity[ BOMBSITE_A ] || !g_iBombSiteEntity[ BOMBSITE_B ] )
	{
		console_print( id , "* Bombalerakó Lezárás: Ezen a pályán nem engedélyezett!" );
		return PLUGIN_HANDLED;
	}
	
	new iMenu = menu_create( "Bombalerakó zárolas menü" , "MenuHandler" );
	new iCallBack = menu_makecallback( "MenuCallBack" );

	menu_additem( iMenu , "A zárolása" , .callback = iCallBack );
	menu_additem( iMenu , "B zárolása" , .callback = iCallBack );
	menu_additem( iMenu , "A feloldása" , .callback = iCallBack );
	menu_additem( iMenu , "B feloldása" , .callback = iCallBack );
	menu_additem( iMenu , "A & B zárolása" , .callback = iCallBack );
	menu_additem( iMenu , "A & B feloldása" , .callback = iCallBack );
	
	menu_display( id , iMenu );
	
	return PLUGIN_HANDLED;
}

public MenuCallBack( id , iMenu, iItem )
{	
	new iRetVal;
	
	switch ( iItem )
	{
		case 0: iRetVal = g_bBombSiteStatus[ BOMBSITE_A ] ? ITEM_DISABLED : ITEM_ENABLED; 
		case 1: iRetVal = g_bBombSiteStatus[ BOMBSITE_B ] ? ITEM_DISABLED : ITEM_ENABLED;
		case 2: iRetVal = g_bBombSiteStatus[ BOMBSITE_A ] ? ITEM_ENABLED : ITEM_DISABLED;
		case 3: iRetVal = g_bBombSiteStatus[ BOMBSITE_B ] ? ITEM_ENABLED : ITEM_DISABLED;
		case 4: iRetVal = g_bBombSiteStatus[ BOMBSITE_A ] && g_bBombSiteStatus[ BOMBSITE_B ] ? ITEM_DISABLED : ITEM_ENABLED;
		case 5: iRetVal = g_bBombSiteStatus[ BOMBSITE_A ] || g_bBombSiteStatus[ BOMBSITE_B ] ? ITEM_ENABLED : ITEM_DISABLED;
	}	
	
	return iRetVal;
}

public MenuHandler( id , iMenu , iItem )
{
	if( iItem == MENU_EXIT ) 
	{
		menu_destroy( iMenu );
		return PLUGIN_HANDLED;
	}
	
	set_hudmessage( 255 , 255 , 255 , -1.0 , 0.65 , 0 , 3.0 , 3.0 , .channel = -1 );
	
	switch ( iItem )
	{
		case 0:
		{
			SetBombSiteLock( BOMBSITE_A , true );
			show_hudmessage( 0 , "Bombalerakó (A) lezárva" );
		}
		case 1: 
		{
			SetBombSiteLock( BOMBSITE_B , true );
			show_hudmessage( 0 , "Bombalerakó (B) lezárva" );
		}
		case 2:
		{
			SetBombSiteLock( BOMBSITE_A , false );
			show_hudmessage( 0 , "Bombalerakó (A) feloldva" );
		}
		case 3:
		{
			SetBombSiteLock( BOMBSITE_B , false );
			show_hudmessage( 0 , "Bombalerakó (B) feloldva" );
		}
		case 4: 
		{
			SetBombSiteLock( BOMBSITE_A , true );
			SetBombSiteLock( BOMBSITE_B , true );
			show_hudmessage( 0 , "Bombalerakó (A & B) lezárva" );
		}
		case 5: 
		{ 
			SetBombSiteLock( BOMBSITE_A , false );
			SetBombSiteLock( BOMBSITE_B , false );
			show_hudmessage( 0 , "Bombalerakó (A & B) feloldva" );
		}
	}
	
	menu_destroy( iMenu );
	
	return PLUGIN_HANDLED;
}

public fw_HUDEntThink( iEntity )
{
	if( g_bPlayerHoldingBomb && ( g_bBombSiteStatus[ BOMBSITE_A ] || g_bBombSiteStatus[ BOMBSITE_B ] ) && ( iEntity == g_iHUDEntity ) && is_user_alive( g_iPlayerWithBomb ) ) 
	{
		set_hudmessage( random(255), random(255), random(255), -1.0 , 0.87 , 0 , 1.0 , 1.0 , .channel = -1 );
		show_hudmessage( g_iPlayerWithBomb , "Bombalerakó %s %s%s%s %s jelenleg lezárva!" ,	g_bBombSiteStatus[ BOMBSITE_A ] && g_bBombSiteStatus[ BOMBSITE_B ] ? "s" : ""  , 
												g_bBombSiteStatus[ BOMBSITE_A ] ? "A" : "" , 
												g_bBombSiteStatus[ BOMBSITE_A ] && g_bBombSiteStatus[ BOMBSITE_B ] ? " & " : "" , 
												g_bBombSiteStatus[ BOMBSITE_B ] ? "B" : "" ,
												g_bBombSiteStatus[ BOMBSITE_A ] && g_bBombSiteStatus[ BOMBSITE_B ] ? "are" : "" );
		
		entity_set_float( g_iHUDEntity , EV_FL_nextthink , ( get_gametime() + 1.0 ) );
	}
}

SetBombSiteLock( BombSites:bsBombSite , bool:bLockState )	
{
	entity_set_int( g_iBombSiteEntity[ bsBombSite ] , EV_INT_solid , bLockState ? SOLID_NOT : SOLID_TRIGGER );
	g_bBombSiteStatus[ bsBombSite ] = bLockState;
	
	if ( bLockState )
		entity_set_float( g_iHUDEntity , EV_FL_nextthink , ( get_gametime() + 1.0 ) );
}
