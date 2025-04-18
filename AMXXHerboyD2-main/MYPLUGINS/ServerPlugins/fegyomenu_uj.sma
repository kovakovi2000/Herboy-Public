    #include < amxmodx >
    #include < amxmisc >
    #include < fun >
    #include < fakemeta >
    #include < cstrike >
    #include < hamsandwich >
    #include <regsystem>
     
    #pragma semicolon       1
     
    #define VERSION         "0.0.1"
     
    #define Max_Players     32
     
    #define OFFSET_PRIMARYWEAPON    116
    #define OFFSET_C4_SLOT      372
    
    #define Money_Hud       ( 1 << 5 )
     
    new g_iWPCT;
    new g_iWPTE;
     
    new pCvarMaxCTWps;
    new pCvarMaxTEWps;
     
    new pCvarWPBlock;
     
    new pCvarFlash;
    new pCvarHe;
    new pCvarSmoke;
     
    new pCvarKevlar;
    new pCvarDefuser;
     
    new pCvarPrefix;
    new pCvarMoney;
    new pCvarBlockBuy;
    new pCvarUnAmmo;
     
    new const g_szMessages [ ] [ ] =
    {
        "",
        "GUNMENU_AWP_TEAM_LIMIT",
        "GUNMENU_AWP_RESTRICTION",
        "GUNMENU_BUY_DISABLED",
        "GUNMENU_ALREADY_CHOSEN",
    };
     
    new const g_szWeaponMenuNames [ ] [ ] =  {
       
        "M4A1",
        "AK47",
        "AWP",
        "SCOUT",
        "FAMAS",
        "GALIL",
        "MP5",
        "XM1014",
        "M3" ,
        "AUG" ,
        "SG552"
    };
     
    new const g_szWeaponsName [ ] [ ] = {
       
        "weapon_m4a1",
        "weapon_ak47",
        "weapon_awp",
        "weapon_scout",
        "weapon_famas",
        "weapon_galil",
        "weapon_mp5navy",
        "weapon_xm1014",
        "weapon_m3" ,
        "weapon_aug" ,
        "weapon_sg552"
    };
     
    const DoNotReload = ( ( 1 << CSW_HEGRENADE ) | ( 1 << CSW_SMOKEGRENADE ) | ( 1 << CSW_FLASHBANG ) | ( 1 << CSW_KNIFE ) | ( 1 << CSW_C4 ) );
    new const maxAmmo[ 31 ] = {
       
        0,
        52,
        0,
        90,
        1,
        32,
        1,
        100,
        90,
        1,
        120,
        100,
        100,
        90,
        90,
        90,
        100,
        120,
        30,
        120,
        200,
        32,
        90,
        120,
        90,
        2,
        35,
        90,
        90,
        0,
        100
    };
     
    new g_szBuyCommands[  ][  ] =
    {
        "usp", "glock", "deagle", "p228", "elites", "fn57", "m3", "xm1014", "mp5", "tmp", "p90", "mac10", "ump45", "ak47",
        "galil", "famas", "sg552", "m4a1", "aug", "scout", "awp", "g3sg1", "sg550", "m249", "vest", "vesthelm", "flash", "hegren",
        "sgren", "defuser", "nvgs", "shield", "primammo", "secammo", "km45", "9x19mm", "nighthawk", "228compact", "12gauge",
        "autoshotgun", "smg", "mp", "c90", "cv47", "defender", "clarion", "krieg552", "bullpup", "magnum", "d3au1", "krieg550",
        "buyammo1", "buyammo2"
    };
     
    new const g_szMenuCommands[  ] [  ] =
    {
        "fegyver",
        "say fegyver",
        "say_team fegyver",
        "/fegyver",
        "say /fegyver",
        "say_team /fegyver",

        "fegyo",
        "say fegyo",
        "say_team fegyo",
        "/fegyo",
        "say /fegyo",
        "say_team /fegyo",

        "weapon",
        "say weapon",
        "say_team weapon",
        "/weapon",
        "say /weapon",
        "say_team /weapon",

        "wep",
        "say wep",
        "say_team wep",
        "/wep",
        "say /wep",
        "say_team /wep",

        "guns",
        "say guns",
        "say_team guns",
        "/guns",
        "say /guns",
        "say_team /guns",

        "arma",
        "say arma",
        "say_team arma",
        "/arma",
        "say /arma",
        "say_team /arma",

        "zbran",
        "say zbran",
        "say_team zbran",
        "/zbran",
        "say /zbran",
        "say_team /zbran",

        "oruzje",
        "say oruzje",
        "say_team oruzje",
        "/oruzje",
        "say /oruzje",
        "say_team /oruzje",

        "waffen",
        "say waffen",
        "say_team waffen",
        "/waffen",
        "say /waffen",
        "say_team /waffen",

        "zbroja",
        "say zbroja",
        "say_team zbroja",
        "/zbroja",
        "say /zbroja",
        "say_team /zbroja"
    };
     
    new g_szChatPrefix[ 64 ];
    new g_msgHideWeapon;
    new g_bHasWeapon[ 33 ];
     
    public plugin_init ( ) {
       
        register_plugin( "AWM", VERSION, "#YouCantStopMe" );
        loading_maps();
        RegisterHam( Ham_Spawn, "player", "func_OpenWeaponMenu", 1 );
        pCvarMaxCTWps   = register_cvar( "awm_max_ct_awp",  "2" ); // Ct-n�l 2 AWP-s lehet.
        pCvarMaxTEWps   = register_cvar( "awm_max_te_awp",  "2" ); // Terrorist�kn�l 2 AWP-s lehet.
       
        pCvarWPBlock    = register_cvar( "awm_allow_wp_player",     "4" ); // Ha mindk�t csapatban van 4-4 j�t�kos akkor engedi az AWP-t
       
        pCvarFlash  = register_cvar( "awm_give_flash",  "1" ); // Itt tudod be�ll�tani ,hogy adjon-e f�st gr�n�tot. ( 0 = Nem ad ) Alap: 2 Flash gr�n�t
        pCvarHe     = register_cvar( "awm_give_he",         "1" ); // Itt tudod be�ll�tani ,hogy adjon-e f�st gr�n�tot. ( 0 = Nem ad ) Alap: 1 Roban� gr�n�t
        pCvarSmoke  = register_cvar( "awm_give_smoke",  "1" ); // Itt tudod be�ll�tani ,hogy adjon-e f�st gr�n�tot. ( 0 = Nem ad )
       
        pCvarKevlar = register_cvar( "awm_give_kevlar", "1" ); // Itt tudod be�ll�tani ,hogy adjon-e kevl�rt. ( 0 = Nem Ad ) Alap: 2 ( Kevl�r + Sisak )
        pCvarDefuser    = register_cvar( "awm_give_defuser",    "1" ); // Itt tudod be�ll�tani ,hogy adjon-e defusert. ( 0 = Nem Ad )
       
        pCvarUnAmmo = register_cvar( "awm_unlimited_ammo",  "0" ); // Itt tudod be�ll�tani ,hogy elfoggyon-e a t�r vagy ne. Alap: 1 ( Teh�t nem fogy el a t�r )
       
        pCvarBlockBuy   = register_cvar( "awm_block_buy",   "1" ); // Itt tudod be�ll�tani ,hogy tiltsa-e a v�s�rl�st vagy ne. Alap 1 ( Teh�t tiltva van ) ( 0 = Nincs tiltva )
        pCvarMoney  = register_cvar( "awm_set_money",   "0" ); // Itt tudod be�ll�tani ,hogy mennyi p�nze legyen a j�t�kosoknak. ( 0 = Nincs , elt�nik a hudr�l is ) Alap: 0
        pCvarPrefix     = register_cvar( "awm_prefix",      "^4[^1~^3|^4HerBoy^3|^1~^4] ^3»" ); // Itt tudod be�ll�tani, hogy mi legyen a Fegyvermen� prefix-je.
       
        g_msgHideWeapon = get_user_msgid( "HideWeapon" );
       
        for( new i = 0; i < sizeof( g_szBuyCommands ); i++ )
            register_clcmd( g_szBuyCommands[ i ], "cmd_BlockBuy" );
       
        for( new i = 0; i < sizeof( g_szMenuCommands ); i++ )
            register_clcmd( g_szMenuCommands[ i ], "cmd_ShowWeaponMenu" );
       
        register_event( "ResetHUD", "onResetHUD", "b" );
        register_event( "CurWeapon", "eCurWeapon", "be", "1=1" );
       
        register_message( g_msgHideWeapon, "msgHideWeapon" );
       
        register_logevent( "eRoundEnd", 2, "1=Round_End" );

        register_dictionary("fegyvermenu_uj.txt");
        register_dictionary("general.txt");
    }
     
    public loading_maps()
    {  
        new fajl[64],linedata[1024],currentmap[64],mapnev[32];
        get_mapname(currentmap,charsmax(currentmap));
        formatex(fajl, charsmax(fajl), "addons/amxmodx/configs/fegyvermenu_tiltas.ini");
     
        if (!file_exists("addons/amxmodx/configs/fegyvermenu_tiltas.ini")) {
            new len,buffer[512];
            len += formatex(buffer[len], charsmax(buffer),";Csak írd be azoknak a mapoknak a nevét amelyiken ne működjön a fegyvermenü. Pl:^n");
            len += formatex(buffer[len], charsmax(buffer)-len,";^"awp_india^"^n");
       
            new file = fopen("addons/amxmodx/configs/fegyvermenu_tiltas.ini", "at");
       
            fprintf(file, buffer);
            fclose(file);
            return;
        }
     
        new file = fopen(fajl, "rt");
     
        while (file && !feof(file)) {
            // Read one line at a time
            fgets(file, linedata, charsmax(linedata));
            replace(linedata, charsmax(linedata), "^n", "");//Üres sorokat eltünteti
       
            parse(linedata,mapnev,31);
            if(equali(currentmap,mapnev)) {
                log_amx("A plugin '%s' mapon nem fut. (configs/fegyvermenu_tiltas.ini)",currentmap);
                pause("ad");
                return;
            }
        }
        if (file) fclose(file);
    }
     
    public client_putinserver( iClient ) {
       
        g_bHasWeapon[ iClient ] = false;
    }
     
    public client_disconnected( iClient ) {
       
        g_bHasWeapon[ iClient ] = false;
    }
     
    public cmd_ShowWeaponMenu( iClient ) {
        if(!is_user_connected(iClient)) return PLUGIN_HANDLED;
       
        switch( g_bHasWeapon[ iClient ] ) {
           
            case true: {
                get_pcvar_string( pCvarPrefix, g_szChatPrefix, charsmax( g_szChatPrefix ) );
                ColorChat( iClient, "^4%s^1 %L" , g_szChatPrefix, iClient, g_szMessages[ 4 ] );
               
                return PLUGIN_HANDLED;
            }
            case false:     func_OpenWeaponMenu( iClient );
        }
        return PLUGIN_HANDLED;
    }
     
    public cmd_BlockBuy( iClient ) {
       
        if( !get_pcvar_num( pCvarBlockBuy ) )
            return PLUGIN_CONTINUE;
       
        get_pcvar_string( pCvarPrefix, g_szChatPrefix, charsmax( g_szChatPrefix ) );
        ColorChat( iClient,  "^4%s^1 %L" , g_szChatPrefix, iClient, g_szMessages[ 3 ] );
        return PLUGIN_HANDLED;
    }
     
    public eCurWeapon( iClient ) {
       
        if( get_pcvar_num( pCvarUnAmmo ) ) {
           
            if( is_user_alive( iClient ) ) {
               
                new weapon = read_data( 2 );
                if( !( DoNotReload & ( 1 << weapon ) ) ) {
               
                    cs_set_user_bpammo( iClient, weapon, maxAmmo[ weapon ] );
                }
            }
        }
    }
     
    public onResetHUD( iClient ) {
       
        if( !get_pcvar_num( pCvarMoney ) ) {
           
            message_begin( MSG_ONE, g_msgHideWeapon, _, iClient );
            write_byte( Money_Hud );
            message_end( );
        }
    }
     
    public msgHideWeapon( ) {
       
        if( !get_pcvar_num( pCvarMoney ) ) {
           
            set_msg_arg_int( 1, ARG_BYTE, get_msg_arg_int( 1 ) | Money_Hud );
        }
    }
     
    public eRoundEnd ( ) {
       
        g_iWPCT = 0;
        g_iWPTE = 0;
    }
     
    public func_OpenWeaponMenu ( iClient ) {
       
        if(!sk_get_logged(iClient))
            return;

        if(!is_user_connected(iClient) || !is_user_alive( iClient ) )
            return;
           
        cs_set_user_money( iClient, get_pcvar_num( pCvarMoney ) );
       
        get_pcvar_string( pCvarPrefix, g_szChatPrefix, charsmax( g_szChatPrefix ) );
       
        g_bHasWeapon[ iClient ] = false;
       
        new szMenuTitle[ 121 ];
        new szMenuItem[ 121 ];
       
        format( szMenuTitle, charsmax( szMenuTitle ), "\r[\wHerBoy\r] \wOnlyDust2\r » \r[ \w%L \r]", iClient, "GUNMENU_WEAPON_MENU");
     
        StripUserWeapons( iClient );
        new menu = menu_create( szMenuTitle, "func_OpenWeaponMenu_handler" );
       
        for( new i = 0; i < sizeof( g_szWeaponMenuNames ); i++ ) {
           
            if( i != 2 ) {
               
                format( szMenuItem, charsmax( szMenuItem ), "\y|\d-\r-\y[ \w%s\y ]\r-\d-\y|", g_szWeaponMenuNames[ i ] );
            }
            else {
                switch( get_user_team( iClient ) )
                {
                    case 1: format( szMenuItem, charsmax( szMenuItem ), "\r|\y-\r-\y[ \w%s\y ]\r-\y-\r| \d~ \r|\d MAX: \y%d\r|", g_szWeaponMenuNames[ i ], get_pcvar_num( pCvarMaxTEWps ) );
                    case 2: format( szMenuItem, charsmax( szMenuItem ), "\r|\y-\r-\y[ \w%s\y ]\r-\y-\r| \d- \yMAX: \y%d", g_szWeaponMenuNames[ i ], get_pcvar_num( pCvarMaxCTWps ) );
                    default: continue;
                }
            }
           
            menu_additem( menu, szMenuItem, _, 0 );
        }
       
        menu_setprop( menu, MPROP_EXIT, MEXIT_ALL );
        menu_setprop( menu, MPROP_BACKNAME, fmt("%L", iClient, "GENERAL_MENU_BACK") );
        menu_setprop( menu, MPROP_NEXTNAME, fmt("%L", iClient, "GENERAL_MENU_NEXT") );
        menu_setprop( menu, MPROP_EXITNAME, fmt("%L", iClient, "GENERAL_MENU_EXIT") );
        menu_display( iClient, menu );
    }
     
    public func_OpenWeaponMenu_handler( iClient, iMenu, iItem ) {
       
        if( iItem == MENU_EXIT ) {
           
            menu_destroy( iMenu );
            return PLUGIN_HANDLED;
        }
       
        new data[ 6 ], szName[ 64 ];
        new access, callback;
        menu_item_getinfo( iMenu, iItem, access, data, charsmax( data ), szName, charsmax( szName ), callback );
       
        get_pcvar_string( pCvarPrefix, g_szChatPrefix, charsmax( g_szChatPrefix ) );
       
        if( iItem != 2 ) {
           
            give_item( iClient, g_szWeaponsName[ iItem ] );
           
            ColorChat( iClient,  "^4%s^1 %L", g_szChatPrefix, iClient, "GUNMENU_PACKAGE_CHOICE", g_szWeaponMenuNames[ iItem ] );
        }
        else {
           
            new iTeams[ CsTeams ];
            GetPlayerCount( iTeams );
           
            if( iTeams[ CS_TEAM_T ] < get_pcvar_num( pCvarWPBlock )
            || iTeams[ CS_TEAM_CT ] < get_pcvar_num( pCvarWPBlock ) ) {
               
                ColorChat( iClient,  "%L", iClient, g_szMessages[ 2 ], g_szChatPrefix );
                func_OpenWeaponMenu( iClient );
               
                return PLUGIN_HANDLED;
            }
           
            new CsTeams:userTeam = cs_get_user_team( iClient );
            if( userTeam == CS_TEAM_CT ) {
               
                if( g_iWPCT < get_pcvar_num( pCvarMaxCTWps ) ) {
                   
                    give_item( iClient, g_szWeaponsName[ iItem ] );
                   
                    ColorChat( iClient, "^4%s^1 %L", g_szChatPrefix, iClient, "GUNMENU_PACKAGE_CHOICE", g_szWeaponMenuNames[ iItem ] );
                    g_iWPCT++;
                }
                else {
                   
                    client_print( iClient, print_center, "%L", iClient, g_szMessages[ 1 ] );
                    func_OpenWeaponMenu ( iClient );
                   
                    return PLUGIN_HANDLED;
                }
            }
           
            if( userTeam == CS_TEAM_T ) {
               
                if( g_iWPTE < get_pcvar_num( pCvarMaxTEWps ) ) {
                   
                   
                    give_item( iClient, g_szWeaponsName[ iItem ] );
                   
                    ColorChat( iClient,  "^4%s^1 %L", g_szChatPrefix, iClient, "GUNMENU_PACKAGE_CHOICE", g_szWeaponMenuNames[ iItem ] );
                    g_iWPTE++;
                }
                else {
                   
                    client_print( iClient, print_center, "%L", iClient, g_szMessages[ 1 ] );
                    func_OpenWeaponMenu( iClient );
                   
                    return PLUGIN_HANDLED;
                }
            }
        }
       
        give_item( iClient, "weapon_knife" );
        give_player_stuff( iClient );
        Pisztolymenu(iClient);
           
        menu_destroy( iMenu );
        return PLUGIN_HANDLED;
    }
           
    public Pisztolymenu(iClient)
    {
        new szMenuTitle[ 121 ];

        format( szMenuTitle, charsmax( szMenuTitle ), "\r[\wHerBoy\r] \wOnlyDust2\r » \r[ \w%L \r]", iClient, "GUNMENU_WEAPON_MENU");

        new menu = menu_create(szMenuTitle, "Pisztolymenu_handler");
       
        menu_additem(menu, "\y|\d-\r-\y[ \wDeagle\y ]\r-\d-\y|", "0", 0);
        menu_additem(menu, "\y|\d-\r-\y[ \wUsp\y ]\r-\d-\y|", "1", 0);
        menu_additem(menu, "\y|\d-\r-\y[ \wGlock18\y ]\r-\d-\y|", "2", 0);
        menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
        menu_display(iClient, menu, 0);
    }
     
    public Pisztolymenu_handler(iClient, menu, item)
    {
        new command[6], name[64], access, callback;
        menu_item_getinfo(menu, item, access, command, sizeof command - 1, name, sizeof name - 1, callback);
     
        switch(item) {
            case 0: {
                give_item(iClient, "weapon_deagle");
                cs_set_user_bpammo(iClient, CSW_DEAGLE, 35);
                ColorChat( iClient,  "^4%s^1 %L", g_szChatPrefix, iClient, "GUNMENU_DEAGLE_CHOICE");
            }
            case 1: {
                give_item(iClient, "weapon_usp");
                cs_set_user_bpammo(iClient, CSW_USP, 100);
                ColorChat( iClient,  "^4%s^1 %L", g_szChatPrefix, iClient, "GUNMENU_USP_CHOICE");
            }
            case 2: {
                give_item(iClient, "weapon_glock18");
                cs_set_user_bpammo(iClient, CSW_GLOCK18, 120);
                ColorChat( iClient,  "^4%s^1 %L", g_szChatPrefix, iClient, "GUNMENU_GLOCK_CHOICE");
            }
        }
       
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }
    GetPlayerCount( iTeamPlayers[ CsTeams ] ) {
       
        new iPlayers[ 32 ] , iPlayerCount;
       
        get_players( iPlayers , iPlayerCount );
       
        for ( new i = 0 ; i < iPlayerCount ; i++ )
            iTeamPlayers[ cs_get_user_team( iPlayers[ i ] ) ]++;
    }  
     
    stock give_player_stuff( iClient ) {
       
        if( get_pcvar_num( pCvarFlash ) ) {
           
            give_item( iClient, "weapon_flashbang" );
        }
       
        if( get_pcvar_num( pCvarHe ) ) {
           
            give_item( iClient, "weapon_hegrenade" );
            cs_set_user_bpammo( iClient, CSW_HEGRENADE, get_pcvar_num( pCvarHe ) );
        }
       
        if( get_pcvar_num( pCvarSmoke ) ) {
           
            give_item( iClient, "weapon_smokegrenade" );
            cs_set_user_bpammo( iClient, CSW_SMOKEGRENADE, get_pcvar_num( pCvarSmoke ) );
        }
       
        if( get_pcvar_num( pCvarKevlar ) ) {
           
            switch( get_pcvar_num( pCvarKevlar ) ) {
               
                case 1: give_item( iClient, "item_kevlar" );
                case 2: give_item( iClient, "item_assaultsuit" );
                default: return PLUGIN_CONTINUE;
            }
        }
       
        if( get_pcvar_num( pCvarDefuser ) ) {
           
            give_item( iClient, "item_thighpack" );
        }
       
        if( !get_pcvar_num( pCvarUnAmmo ) ) {
           
            new weapons[ 32 ];
            new weaponsnum;
            get_user_weapons( iClient, weapons, weaponsnum );
            for( new i = 0; i < weaponsnum; i++ )
                if( is_user_alive( iClient ) )
                    if( maxAmmo[ weapons[ i ] ] > 0 )
                        cs_set_user_bpammo( iClient, weapons[ i ], maxAmmo[ weapons[ i ] ] );
        }
       
        g_bHasWeapon[ iClient ] = true;
        return PLUGIN_CONTINUE;
    }
     
     
    //Stolen from CSDM Weapon Menu
    stock StripUserWeapons( iClient ) {
       
        new iC4Ent = get_pdata_cbase( iClient, OFFSET_C4_SLOT );
         
        if( iC4Ent > 0 ) {
           
            set_pdata_cbase( iClient, OFFSET_C4_SLOT, FM_NULLENT );
        }
         
        strip_user_weapons( iClient );
        set_pdata_int( iClient, OFFSET_PRIMARYWEAPON, 0 );
         
        if( iC4Ent > 0 )  {
           
            set_pev( iClient, pev_weapons, pev( iClient, pev_weapons ) | ( 1 << CSW_C4 ) );
            set_pdata_cbase( iClient, OFFSET_C4_SLOT, iC4Ent );
           
            cs_set_user_bpammo( iClient, CSW_C4, 1 );
            cs_set_user_plant( iClient, 1 );
        }
       
        return PLUGIN_HANDLED;
    }
     
    stock ColorChat( iClient, const input[], any:...)
    {
        new count = 1, players[ 32 ];
        static msg[ 191 ];
        vformat( msg, 190, input, 3 );
       
        replace_all( msg, 190, "^x01" , "^1");
        replace_all( msg, 190, "^x03" , "^3");
        replace_all( msg, 190, "^x04" , "^4");
       
        if ( iClient )  players[ 0 ] = iClient; else get_players( players , count , "ch" );
        {
            for ( new i = 0; i < count; i++ )
            {
                if ( is_user_connected( players[ i ] ) )
                {
                    message_begin( MSG_ONE_UNRELIABLE , get_user_msgid( "SayText" ), _, players[ i ] );
                    write_byte( players[ i ] );
                    write_string( msg );
                    message_end(  );
                }
            }
        }
    }
