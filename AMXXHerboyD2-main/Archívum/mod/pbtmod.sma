#include <amxmodx>
#include <amxmisc>
#include <dhudmessage>
#include <cstrike>
#include <colorchat>
#include <hamsandwich>
#include <engine>
#include <fun>
#include <sqlx>
#include <fakemeta>
#include <pbtnewd2mod>

new const PLUGIN[] = "pbTD2Mod";
new const VERSION[] = "1.0";
new const AUTHOR[] = "";

//A MÓD 80%-át GeTT ÍRTA. A 20% EGY ALAP SKINRENDSZERRŐL LETT FELÉPÍTVE.
//A SKINRENDSZER ALAP FORRÁSA: HLMOD.HU FÓRUM.

#if AMXX_VERSION_NUM < 183 
new Ham:Ham_Player_ResetMaxSpeed = Ham_Item_PreFrame 
#endif 

#pragma semicolon 1
#pragma tabsize 0

new const Prefix[] = "\r[\y*pbT#\r]"; //Jatekban megjelent PrefiX
new const C_Prefix[] = "^4[*pbT#]"; //Chat Prefix
#define PREFIX "[*pbT#]"
#define SERVER_ID	1
#define VIPTIME 31 * 86400
#define VIPTIMEKUPON 15 * 86400
 new FragVerseny[33];
new const Chat_Prefix[] = "[Információ]";

new s_HOSZT[] = "db.synhosting.eu";
new s_FELHASZNALO[] = "stekler19931118";
new s_ADATBAZIS[] = "stekler19931118";
new s_JELSZO[] = "1992klau1992";
new AccountId[33];
new bool:g_Bejelentkezve[33];
new filename[128];
new Keres[33], Kereskedik[33], KerID[33], KerDB[33], Float:KerDollar[33], JelolID[33],Fogad[33],Targy[33],KivLada[33],addolasikulcs,g_iVipNum[33],accountpause,AutoLogin=1,s_addvariable[33],viptorol,vip_porgetes,g_screenfade;
new Top[3][15], TopNev[3][15][32], TopRang[15];
new g_frozen[33];
new caseid;
new g_snapshot[33];
//EVENTEK
new ajandekcsomag[33],vipkupon[33],havazas=1;
#define LADA 7 //Ladak Szama

#define TULAJ ADMIN_IMMUNITY
#define FOADMIN ADMIN_CVAR
#define ADMIN ADMIN_BAN
#define VIP ADMIN_LEVEL_H

#define DLMIN 1 //Minimum Dollar drop
#define DLMAX 2 //Maximum Dollar drop

#define VIPELET 10 //VIP-nek jaro +elet


new const l_Nevek[][] = { "Bronz Láda", "Színözön Láda", "Falchion Láda", "Operation B. Láda", "Phoenix Láda", "Huntsman Láda","Árnyék Láda" };

enum _:Adatok {
Type[8],
Nev[64],
Model[64],
BoltiAr[8]
}


new g_StartTime[33], g_EndTime[32], bool:SwitchFrag, bool:FirstTask, x_tempid, g_iTime[33], g_iVipTime[33];
//---------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------
new kill[32], h_lada[33];
new Lada[LADA][33], Kulcs[33], Float:Dollar[33], Rang[33], Oles[33], Gun[12][33],biztonsagikerdes[33], Hud[33], D_Oles[33], name[33][33], Masodpercek[33], SMS[33], Vip[33], Float:Erteke[33], kicucc[33],kicucc2[33], kirakva[33], pido;
new g_Felhasznalonev[33][100], g_Jelszo[33][100], g_JelszoUj[33][100], g_JelszoRegi[33][100],s_biztonsagikerdes[33][100], s_valasz[33][100],s_valaszirt[33][100],s_temporarypass[33][100], g_FHVIP[33][100],g_Indok[33][100], adminname[33][100], g_trickban[33][100];
new g_RegisztracioVagyBejelentkezes[33], g_Id[33], g_Email[33][100];
new g_Aktivitas[33], g_Folyamatban[33], Send[33], TempID,Performer;
new Banned_Name[33][40],Banned_Ip[33][40],Banned_Steamid[33][40];
new Handle:g_SqlTuple;
new Temp[192];

static color[10];

new const view_hud[][] =
{
    "A Fragverseny véget ért!^nElső: %s",
    "A Fragverseny véget ért!^nElső: %s | Második: %s",
    "A Fragverseny véget ért!^nElső: %s | Második: %s | Harmadik: %s",
    "Jelenleg Fragverseny van (%s-%s)^n1. %s - Ölés: %i",
    "Jelenleg Fragverseny van (%s-%s)^n1. %s - Ölés: %i | 2. %s - Ölés: %i",
    "Jelenleg Fragverseny van (%s-%s)^n1. %s - Ölés: %i | 2. %s - Ölés: %i | 3. %s - Ölés: %i",
    "A Fragverseny elkezdődik %s-kor..."
};

enum _:Rangs { Szint[32], Xp[8] };

enum _:WPNS
{
AK47,
M4A1,
AWP,
FAMAS,
MP5NAVY,
GALIL,
SCOUT,
DEAGLE,
USP,
GLOCK18,
KNIFE
}
new const kivalasztott[33][WPNS];
new const FegyverAdatok[][Adatok] = {
	{ 0,"\yAK47 | HyperBeast \y(\r1,55% esĂ©ly\y)", "models/pbt2019/ak47/hyper_beast_ak47.mdl", 1200 }, //3
	{ 0,"\yAK47 | Neon Revolution \y(\r1,55% esĂ©ly\y)", "models/pbt2019/ak47/neon_revolution_ak47.mdl",1200 }, //6
	{ 0,"\yAK47 | GreenLine \y(\r1,55% esĂ©ly\y)", "models/pbt2019/ak47/green_line_ak47.mdl",1200 }, //2
	{ 0,"\yAK47 | Runner \y(\r1,55% esĂ©ly\y)","models/pbt2019/ak47/runner_ak47.mdl",1200 }, //15
	{ 0,"\yAK47 | Storm \y(\r1,55% esĂ©ly\y)", "models/pbt2019/ak47/storm_ak47.mdl",1200}, //16
	{ 0,"\yAK47 | Neon \y(\r1,55% esĂ©ly\y)", "models/pbt2019/ak47/neon_ak47.mdl",1200 }, //5
	{ 0,"\yAK47 | Cannibal \y(\r1,55% esĂ©ly\y)", "models/pbt2019/ak47/cannibal_ak47.mdl",1200 }, //1
	{ 0,"\rAK47 | Neptune \y(\r8% esĂ©ly\y)", "models/pbt2019/ak47/neptune_ak47.mdl",600 }, //7
	{ 0,"\rAK47 | Palladin \y(\r8% esĂ©ly\y)", "models/pbt2019/ak47/palladin_ak47.mdl",600 }, //8
	{ 0,"\rAK47 | Pantera \y(\r8% esĂ©ly\y)", "models/pbt2019/ak47/pantera_ak47.mdl",600 }, //9
	{ 0,"\rAK47 | Phantom \y(\r8% esĂ©ly\y)", "models/pbt2019/ak47/phantom_ak47.mdl",600 }, //10
	{ 0,"\rAK47 | Psycho \y(\r8% esĂ©ly\y)", "models/pbt2019/ak47/pszio_ak47.mdl",600 }, //11
	{ 0,"\rAK47 | Puma \y(\r8% esĂ©ly\y)", "models/pbt2019/ak47/puma_ak47.mdl",600}, //12
	{ 0,"\rAK47 | Red Skull \y(\r8% esĂ©ly\y)", "models/pbt2019/ak47/red_skull_ak47.mdl",600 }, //13
	{ 0,"\dAK47 | Revenge \y(\r70% esĂ©ly\y)", "models/pbt2019/ak47/revenge_ak47.mdl",600 }, //14
	{ 0,"\dAK47 | Light Of King \y(\r70% esĂ©ly\y)", "models/pbt2019/ak47/light_of_king_ak47.mdl",600 }, //4
	{ 0,"\dAK47 | Neon \y(\r70% esĂ©ly\y)", "models/pbt2019/ak47/neon_ak47.mdl",600 }, //5
	{ 0,"\dAK47 | Street \y(\r70% esĂ©ly\y)", "models/pbt2019/ak47/street_ak47.mdl",600}, //17
	{ 0,"\dAK47 | Superman \y(\r70% esĂ©ly\y)", "models/pbt2019/ak47/superman_ak47.mdl",600}, //18(\r\r
	{ 1,"\yM4A1 | Asiimov \y(\r1,55% esĂ©ly\y)", "models/pbt2019/m4a1/asiimov_m4a1.mdl",1200 },//19
	{ 1,"\yM4A1-S | HyperBeast \y(\r1,55% esĂ©ly\y)", "models/pbt2019/m4a1/hyperbeast_m4a1.mdl",1200 }, //25
	{ 1,"\yM4A4-S | DragonKing \y(\r1,55% esĂ©ly\y)", "models/pbt2019/m4a1/dragonking_m4a1.mdl",1200 }, //21
	{ 1,"\yM4A1-S | Toxicator \y(\r1,55% esĂ©ly\y)", "models/pbt2019/m4a1/toxicator_m4a1.mdl",1200 },
	{ 1,"\rM4A1 | Ultra Violette \y(\r8% esĂ©ly\y)","models/pbt2019/m4a1/ultraviolett_m4a1.mdl",600 },
	{ 1,"\rM4A1-S | Howl \y(\r8% esĂ©ly\y)", "models/pbt2019/m4a1/howl_m4a1.mdl",600}, //2
	{ 1,"\rM4A4-S | Dragon \y(\r8% esĂ©ly\y)", "models/pbt2019/m4a1/dragon_m4a1.mdl",600 },// 20
	{ 1,"\wM4A1 | Ghost \y(\r20% esĂ©ly\y)", "models/pbt2019/m4a1/ghost_m4a1.mdl",150 }, //22
	{ 1,"\wM4A1 | Godzilla \y(\r20% esĂ©ly\y)", "models/pbt2019/m4a1/godzilla_m4a1.mdl",150 }, //23
	{ 1,"\wM4A1 | Kinder \y(\r20% esĂ©ly\y)", "models/pbt2019/m4a1/kinder_m4a1.mdl",150 },
	{ 1,"\wM4A1 | Merlin \y(\r20% esĂ©ly\y)", "models/pbt2019/m4a1/merlin_m4a1.mdl",150 },
	{ 1,"\wM4A4-S | Picasso \y(\r20% esĂ©ly\y)", "models/pbt2019/m4a1/picasso_m4a1.mdl",150 },
	{ 1,"\wM4A1 | Psycho \y(\r20% esĂ©ly\y)", "models/pbt2019/m4a1/pszio_m4a1.mdl",150 }, 
	{ 1,"\dM4A1-S | Reborg \y(\r70% esĂ©ly\y)", "models/pbt2019/m4a1/reborg_m4a1.mdl",150 },
	{ 1,"\dM4A1 | Spiritual \y(\r70% esĂ©ly\y)", "models/pbt2019/m4a1/spiritual_m4a1.mdl",150 },
	{ 1,"\dM4A1 | Storm \y(\r70% esĂ©ly\y)", "models/pbt2019/m4a1/storm_m4a1.mdl",150 }, 
	{ 1,"\dM4A1 | Superman \y(\r70% esĂ©ly\y)", "models/pbt2019/m4a1/superman_m4a1.mdl",150 },
	{ 1,"\dM4A4-S | Virus \y(\r70% esĂ©ly\y)", "models/pbt2019/m4a1/virus_m4a1.mdl",150 }, 
	{ 1,"\dM4A1-S | Vulcan (\r70% esĂ©ly\y)", "models/pbt2019/m4a1/vulcan_m4a1.mdl",150 },
	{ 1,"\dM4A1 | Winterboss (\r70% esĂ©ly\y)", "models/pbt2019/m4a1/winterboss_m4a1.mdl",150 },
	{ 2,"\yAWP | Asiimov \y(\r1,55% esĂ©ly\y)", 		 "models/pbt2019/awp/Asiimov_awp.mdl",1200},
	{ 2,"\yAWP | HyperBeast \y(\r1,55% esĂ©ly\y)",       "models/pbt2019/awp/hyper_beast_awp.mdl",1200},
	{ 2,"\yAWP | Colot \y(\r1,55% esĂ©ly\y)",   "models/pbt2019/awp/kolot_awp.mdl",1200},
	{ 2,"\rAWP | Medusa \y(\r8% esĂ©ly\y)",   "models/pbt2019/awp/medusa_awp.mdl",600},
	{ 2,"\rAWP | Unicornis \y(\r8% esĂ©ly\y)",     "models/pbt2019/awp/unicornis_awp.mdl",600},
	{ 2,"\rAWP | Death Awp \y(\r8% esĂ©ly\y)", "models/pbt2019/awp/death_awp.mdl",600},
	{ 2,"\rAWP | Green Wolf \y(\r8% esĂ©ly\y)", "models/pbt2019/awp/green_wolf.mdl",600},
	{ 2,"\wAWP | Lady \y(\r20% esĂ©ly\y)",    "models/pbt2019/awp/lady_headshot.mdl",150},
	{ 2,"\wAWP | OceanShark \y(\r20% esĂ©ly\y)",       "models/pbt2019/awp/ocean_shark.mdl",150},
	{ 2,"\wAWP | Polip \y(\r20% esĂ©ly\y)",         "models/pbt2019/awp/polip_awp.mdl",150},
	{ 2,"\wAWP | Revenant \y(\r20% esĂ©ly\y)",    "models/pbt2019/awp/revenant_awp.mdl",150},
	{ 2,"\wAWP | Robin Hood \y(\r20% esĂ©ly\y)",        "models/pbt2019/awp/robin_hood_awp.mdl",150},
	{ 2,"\wAWP | Silent Killer \y(\r20% esĂ©ly\y)",   "models/pbt2019/awp/silent_killer_awp.mdl",150},
	{ 2,"\wAWP | Virus \y(\r20% esĂ©ly\y)",  "models/pbt2019/awp/virus_awp.mdl",150},
	{ 2,"\wAWP | Warworg \y(\r20% esĂ©ly\y)",     "models/pbt2019/awp/warworg_awp.mdl",150},
	{ 3,"\wFAMAS | Asiimov \y(\r20% esĂ©ly\y)",      "models/pbt2019/famas/asiimov_famas.mdl",0},
	{ 3,"\dFAMAS | Color \y(\r70% esĂ©ly\y)",   "models/pbt2019/famas/color_famas.mdl",0},
	{ 3,"\dFAMAS | Killer \y(\r70% esĂ©ly\y)",     "models/pbt2019/famas/killer_bagoly_famas.mdl",0},
	{ 3,"\dFAMAS | MarbleFade \y(\r70% esĂ©ly\y)",     "models/pbt2019/famas/marbelefade_famas.mdl",0},
	{ 3,"\dFAMAS | Polip \y(\r70% esĂ©ly\y)",   "models/pbt2019/famas/polip_famas.mdl",0},
	{ 3,"\dFAMAS | Wolf \y(\r70% esĂ©ly\y)",     "models/pbt2019/famas/wolf_famas.mdl",0},
	{ 4,"\dMP5 | Asiimov \y(\r70% esĂ©ly\y)", "models/pbt2019/mp5/asiimov_mp5.mdl",0 },
	{ 4,"\dMP5 | Dual Magma \y(\r70% esĂ©ly\y)", "models/pbt2019/mp5/dual_magma_mp5.mdl",0 },
	{ 4,"\dMP5 | Dual \y(\r70% esĂ©ly\y)", "models/pbt2019/mp5/dual_mp5.mdl",0 },
	{ 4,"\dMP5 | Magma \y(\r70% esĂ©ly\y)", "models/pbt2019/mp5/magma_mp5.mdl",0 },
	{ 4,"\dMP5 | Neon \y(\r70% esĂ©ly\y)", "models/pbt2019/mp5/neon_mp5.mdl",0 },
	{ 4,"\dMP7 | Nuclear \y(\r70% esĂ©ly\y)", "models/pbt2019/mp5/nuclear_mp5.mdl",0 },
	{ 4,"\dMP5 | Unicornis \y(\r70% esĂ©ly\y)", "models/pbt2019/mp5/unicornis_mp5.mdl",0 },
	{ 5,"\rGALIL | HyperBeast \y(\r20% esĂ©ly\y)", "models/pbt2019/galil/hyperbeast_galil.mdl",0 },
	{ 5,"\dGALIL | Coup \y(\r70% esĂ©ly\y)", "models/pbt2019/galil/coup_galil.mdl",0},
	{ 5,"\dGALIL | Dragon \y(\r70% esĂ©ly\y)", "models/pbt2019/galil/dragon_galil.mdl",0 },
	{ 5,"\dGALIL | Sirius \y(\r70% esĂ©ly\y)", "models/pbt2019/galil/sirius_galil.mdl",0 }, //107
	{ 6,"\dSCOUT | HyperBeast \y(\r70% esĂ©ly\y)", "models/pbt2019/scout/hyper_beast_scout.mdl",0}, //123
	{ 6,"\dSCOUT | Crossbow \y(\r70% esĂ©ly\y)", "models/pbt2019/scout/crossbow.mdl",0 },
	{ 6,"\dSCOUT | Esport \y(\r70% esĂ©ly\y)", "models/pbt2019/scout/esport_scout.mdl",0 },
	{ 7,"\rDEAGLE | Toxicator \y(\r8% esĂ©ly\y)", "models/pbt2019/deagle/toxicator.mdl",0 },
	{ 7,"\rDEAGLE | Asiimov \y(\r8% esĂ©ly\y)", "models/pbt2019/deagle/asiimov_deagle.mdl",0 },
	{ 7,"\rDEAGLE | Dragon Lore \y(\r8% esĂ©ly\y)", "models/pbt2019/deagle/dragon_lore_deagle.mdl",0 },
	{ 7,"\rDEAGLE | Aligator \y(\r8% esĂ©Ă©ly\y)", "models/pbt2019/deagle/alligator_deagle.mdl",0 },
	{ 7,"\rDEAGLE | Anarchia \y(\r8% esĂ©ly\y)", "models/pbt2019/deagle/anarhia_deagle.mdl",0 },
	{ 7,"\rDEAGLE | Ancient\y(\r8% esĂ©ly\y) ", "models/pbt2019/deagle/ancient_deagle.mdl",0 },
	{ 7,"\rDEAGLE | Plasma \y(\r8% esĂ©ly\y)", "models/pbt2019/deagle/plasma_deagle.mdl",0 },
	{ 7,"\wDEAGLE | Red Asiimov \y(\r20% esĂ©ly\y)", "models/pbt2019/deagle/red_asiimov_deagle.mdl",0 }, //55
	{ 7,"\wDEAGLE | Sas \y(\r20% esĂ©ly\y)", "models/pbt2019/deagle/sas_deagle.mdl",0 },
	{ 7,"\wDEAGLE | Wolf \y(\r20% esĂ©ly\y)", "models/pbt2019/deagle/wolf_deagle.mdl",0 }, //84
	{ 8,"\wUSP-S | HyperBeast \y(\r20% esĂ©ly\y)", "models/pbt2019/usp/hyperbeast_usp.mdl",0 },
	{ 8,"\wUSP-S | Asiimov \y(\r20% esĂ©ly\y)", "models/pbt2019/usp/asimov_usp.mdl",0},
	{ 8,"\dUSP-S | Blue \y(\r70% esĂ©ly\y)", "models/pbt2019/usp/blue_usp.mdl",0 },
	{ 8,"\dUSP-S | Death \y(\r70% esĂ©ly\y)", "models/pbt2019/usp/death_usp.mdl",0 },
	{ 8,"\dUSP-S | Draco \y(\r70% esĂ©ly\y)", "models/pbt2019/usp/draco_usp.mdl",0},
	{ 8,"\dUSP-S | Gold \y(\r70% esĂ©ly\y)", "models/pbt2019/usp/gold_usp.mdl",0 },
	{ 8,"\dUSP-S | GreenWar \y(\r70% esĂ©ly\y)", "models/pbt2019/usp/green_war_usp.mdl",0 },
	{ 8,"\dUSP-S | Jackel \y(\r70% esĂ©ly\y)", "models/pbt2019/usp/jackel_usp.mdl",0},
	{ 8,"\dUSP-S | Picasso \y(\r70% esĂ©ly\y)", "models/pbt2019/usp/picasso.mdl",0 }, //117
	{ 10,"\yKNIFE | Yedi Kard \y(\r0,01% esĂ©ly\y)", "models/pbt2019/knife/yedi_kard.mdl",0 },
	{ 9,"\dGLOCK | Blue Devil \y(\r70% esĂ©ly\y)", "models/pbt2019/glock/neptune_glock.mdl",0},
	{ 9,"\dGLOCK | Hyper Beast \y(\r70% esĂ©ly\y)", "models/pbt2019/glock/hyperbeast_glock.mdl",0 },
	{ 9,"\dGLOCK | Neon Noir \y(\r70% esĂ©ly\y)", "models/pbt2019/glock/neonnoir_glock.mdl",0 },
	{ 9,"\dGLOCK | Marauder \y(\r70% esĂ©ly\y)", "models/pbt2019/glock/empress.mdl",0 },
	{ 10,"\yKNIFE | Abershark \y(\r0,44% esĂ©ly\y)", "models/pbt2019/knife/abershark_karambit.mdl",0 },
	{ 10,"\yKNIFE | Blueprint GUT \y(\r0,44% esĂ©ly\y)", "models/pbt2019/knife/blueprint_gut.mdl",0 },
	{ 10,"\yKNIFE | Death Flip \y(\r0,44% esĂ©ly\y)", "models/pbt2019/knife/death_flip.mdl",0 },
	{ 10,"\yKNIFE | Gurst flip \y(\r0,44% esĂ©ly\y)", "models/pbt2019/knife/gurst_flip.mdl",0 },
	{ 10,"\yKNIFE | Hyperbeast \y(\r0,44% esĂ©ly\y)","models/pbt2019/knife/hyperbeast_karambit.mdl",0 },
	{ 10,"\yKNIFE | Kung Fu \y(\r0,44% esĂ©ly\y)", "models/pbt2019/knife/kung_fu.mdl",0 },
	{ 10,"\yKNIFE | Butterfly Lite \y(\r0,44% esĂ©ly\y)","models/pbt2019/knife/lite_butterfly.mdl",0 },
	{ 10,"\yKNIFE | Lum1a butterfly \y(\r0,44% esĂ©ly\y)", "models/pbt2019/knife/lum1a_butterfly.mdl",0 },
	{ 10,"\yKNIFE | Machine Karambit \y(\r0,44% esĂ©ly\y)", "models/pbt2019/knife/machine_karambit.mdl",0},
	{ 10,"\yKNIFE | Minecraft Fejsze \y(\r0,44% esĂ©ly\y)", "models/pbt2019/knife/minecraft_fejsze.mdl",0 },
	{ 10,"\yKNIFE | NeoAssassin Butterfly \y(\r0,44% esĂ©ly\y)", "models/pbt2019/knife/neoassasin_butterfly.mdl",0 },
	{ 10,"\yKNIFE | Ocassion \y(\r0,44% esĂ©ly\y)", "models/pbt2019/knife/ocassion_karambit.mdl",0 },
	{ 10,"\yKNIFE | Ork \y(\r0,44% esĂ©ly\y)", "models/pbt2019/knife/ork.mdl",0 },
	{ 10,"\yKNIFE | Purpy Yellow Huntsman \y(\r0,44% esĂ©ly\y)", "models/pbt2019/knife/purpyellow_hunstman.mdl",0 },
	{ 10,"\yKNIFE | Sapphire Death Huntsman \y(\r0,44% esĂ©ly\y)", "models/pbt2019/knife/saphiredeath_hunstman.mdl",0 },
	{ 10,"\yKNIFE | Sarex Karambit \y(\r0,44% esĂ©ly\y)", "models/pbt2019/knife/sarex_karambit.mdl",0},
	{ 10,"\yKNIFE | Scifi Karambit \y(\r0,01% esĂ©ly\y)", "models/pbt2019/knife/scifi_karambit.mdl",0 },
	{ 10,"\yKNIFE | Shark Bayonet \y(\r0,44% esĂ©ly\y)", "models/pbt2019/knife/shark_bayonet.mdl",0 },
	{ 10,"\yKNIFE | Skull Bayonet \y(\r0,01% esĂ©ly\y)", "models/pbt2019/knife/skull_bayonett.mdl",0 },
	{ 10,"\yKNIFE | Sport Karambit \y(\r0,44% esĂ©ly\y)", "models/pbt2019/knife/sport_karambit.mdl",0 },
	{ 10,"\yKNIFE | Toxic Huntsman \y(\r0,01% esĂ©ly\y)", "models/pbt2019/knife/toxic_hunstman.mdl",0 },
	{ 10,"\yKNIFE | Vampire Gut \y(\r0,01% esĂ©ly\y)", "models/pbt2019/knife/vampire_gut.mdl",0 },
	{ 10,"\yKNIFE | Wolf Karambit \y(\r0,01% esĂ©ly\y)", "models/pbt2019/knife/wolf_karambit.mdl",0 },
	{ 0,"ALAP | AK-47", "models/pbt2019/alap/AK47.mdl",0 },
	{ 1,"ALAP | M4A1", "models/pbt2019/alap/M4A1.mdl",0 },
	{ 2,"ALAP | AWP", "models/pbt2019/alap/AWP2.mdl",0 },
	{ 3,"ALAP | FAMAS", "models/pbt2019/alap/FAMAS.mdl",0 },
	{ 4,"ALAP | MP5", "models/pbt2019/alap/MP5.mdl",0 },
	{ 5,"ALAP | GALIL", "models/pbt2019/alap/GALIL.mdl",0 },
	{ 6,"ALAP | SCOUT", "models/pbt2019/alap/SCOUT.mdl",0 },
	{ 7,"ALAP | DEAGLE", "models/pbt2019/alap/DEAGLE.mdl",0 },
	{ 8,"ALAP | GLOCK18", "models/pbt2019/alap/GLOCK.mdl",0 },
	{ 9,"ALAP | USP", "models/pbt2019/alap/USP.mdl",0 },
	{ 10,"ALAP | KĂ‰S", "models/pbt2019/alap/KNIFE.mdl",0 },
	{ 10,"FragBajnok KĂ‰S", "models/pbt2019/knife/lum1a_butterfly.mdl",0 },
	{ 10,"VIP KĂ‰S", "models/pbt2019/knife/pbtvip_knife.mdl",0 }
};

new const PiacTargy[][] = {
{"AK47 | Superman" },
{"AK47 | Fireserpent"}, 
{"AK47 | Arubis"}, 
{"AK47 | Aquamarine"}, 
{"AK47 | Chrismass"}, 
{"AK47 | Cyrex"}, 
{"AK47 | Fuel Injector"},
{"AK47 | GreeN"},
{"AK47 | Grafity"},
{"AK47 | SnakE"},
{"AK47 | Point Disarray"},
{"AK47 | Red Asiimov"},
{"AK47 | NeON"},
{"AK47 | Color"},
{"AK47 | Space"},
{"AK47 | Dragon Lore"},
{"AK47 | Vulcan"},
{"AK47 | Winterboss"},
{"AK47 | Asiomov"},
{"M4A1 | Aqua"},
{"M4A1 | Burn"},
{"M4A1 | Hell"},
{"M4A1 | Desolate Space"},
{"M4A1 | Skull"},
{"M4A1-S | Exec"},
{"M4A1-S | Howl"},
{"M4A1 | Parazit"},
{"M4A1 | Superman"},
{"M4A1 | Toxicator"},
{"M4A1 | Fire"},
{"M4A1-S | Kill Confirmed"},
{"M4A1 | Dragonking"},
{"M4A1 | Lucfier"},
{"M4A1 | Water Elemetnal"},
{"M4A1-S | Master Piece"},
{"M4A1 | Zombie Hunter"},
{"M4A1 | Velocty"},
{"M4A1-S | Cyrex"},
{"M4A1 | Asiimov"},
{"AWP | Green"},
{"AWP | Hyper Beast"},
{"AWP | Dragon Lore"},
{"AWP | RoBoT"},
{"AWP | Corterica"},
{"AWP | SuperMan"},
{"AWP | Unicornis"},
{"AWP | Anime"},
{"AWP | ReD"},
{"AWP | American"},
{"AWP | Line"},
{"AWP | Marihuana"},
{"AWP | ReDBull"},
{"AWP | Black Rose"},
{"AWP | Asiimov"},
{"FAMAS | Blue"},
{"FAMAS | Nuclear"},
{"FAMAS | Sugár"},
{"FAMAS | Pulse"},
{"FAMAS | Valence"},
{"FAMAS | Tiger"},
{"MP5 | Dual"},
{"MP5 | Nuclear"},
{"MP5 | Flame"},
{"MP5 | Sugárveszély"},
{"MP5 | GolD Dual"},
{"MP5 | Carbonite"},
{"MP5 | NeON"},
{"GALIL | Eco"},
{"GALIL | Odyssy"},
{"GALIL | Chatterbox"},
{"GALIL | Cerberus"},
{"SCOUT | Kék Álom"},
{"SCOUT | Véres Viz"},
{"SCOUT | Terepmintás"},
{"DEAGLE | Valentin"},
{"DEAGLE | Ocean"},
{"DEAGLE | ReD Asiimov"},
{"DEAGLE | Dragon Lore"},
{"DEAGLE | Robot"},
{"DEAGLE | Sugárveszély"},
{"DEAGLE | Asiimov"},
{"DEAGLE | Yelow"},
{"DEAGLE | Wolf"},
{"DEAGLE | Hipnotikus"},
{"USP-S | Blue"},
{"USP-S | GreeN"},
{"USP-S | Engraved"},
{"USP-S | Magma"},
{"USP-S | Caiman"},
{"USP-S | Gold"},
{"USP-S | Wolf"},
{"USP-S | Rose"},
{"USP-S | Asiimov"},
{"GLOCK | Blue Devil"},
{"GLOCK | Híper Beast"},
{"GLOCK | Electro"},
{"GLOCK | Marauder"},
{"\rKNIFE | Acero Karambit"},
{"\rKNIFE | CrimsonWeb Karambit"},
{"\rKNIFE | Doppler Karambit"},
{"\rKNIFE | Doppler Rubi Karambit"},
{"\rKNIFE | Doppler Zafiro Karambit"},
{"\rKNIFE | MarbleFade Karambit"},
{"\rKNIFE | TigerTooth Karambit"},
{"\rKNIFE | M9 Bayonet SappHire"},
{"\rKNIFE | M9 Bayonet CrimsonWeb"},
{"\rKNIFE | M9 Bayonet BlackLaminate"},
{"\rKNIFE | M9 Bayonet Forest DDPAT"},
{"\rKNIFE | Lore Flip"},
{"\rKNIFE | Fade Flip"},
{"\rKNIFE | Vampire Flip"},
{"\rKNIFE | Asiimov GUT"},
{"\rKNIFE | Razer GUT"},
{"\rKNIFE | Vampire Gut"},
{"\rKNIFE | CS:GO NeonRider"},
{"\rKNIFE | CS:GO Shadow Dagger"},
{"\rKNIFE | CS:GO Fire"},
{"\rKNIFE | Fade Pillangókés"},
{"\rKNIFE | DopplerOcean Pillangókés"},
{"\rKNIFE | DopplerPink Huntsman"},
{"\rKNIFE | HyperBeast Huntsman"},
{"\rBronz Láda"},
{"\rSzínözön Láda"},
{"\rFalchion Láda"},
{"\rOperation B. Láda"},
{"\rPhoenix Láda"},
{"\rHunstman Láda"},
{"\rÁrnyék Láda"},
{"\rKulcs"}
};
new const Rangok[][Rangs] =
{
	{ "Silver I", 25 },
	{ "Silver II", 100 },
	{ "Silver III", 250 },
	{ "Silver IV", 500 },
	{ "Silver E", 700 },
	{ "Silver E.M", 850 },
	{ "GNI", 1000 },
	{ "GNII", 3000 },
	{ "GNIII", 4500 },
	{ "GN Master", 6500 },
	{ "MGI", 8500 },
	{ "MGII", 9999 },
	{ "MGE", 10500 },
	{ "DMG", 12000 },
	{ "LE", 14000 },
	{ "LEM", 16000 },
	{ "SMFC", 18000 },
	{ "The Global Elite", 20000 },
	{ "The Global Elite", 1000000 }
};

new const LadaDrop0[] = {
	6,
	41,
	45,
	80,
	13,
	32,
	52,
	85,
	65,
	35,
	58,
	68,
	89,
	97,
	104,
	117,
	118//17
};

new const LadaDrop1[] = {
	5,
	40,
	44,
	79,
	12,
	31,
	51,
	84,
	55,
	34,
	57,
	66,
	88,
	96,
	103,
	115,
	116//17
};

new const LadaDrop2[] = {
	4,
	39,
	43,
	78,
	11,
	30,
	50,
	67,
	18,
	33,
	56,
	65,
	87,
	95,
	102,
	113,
	114//17
};

new const LadaDrop3[] = {
	3,
	22,
	42,
	77,
	10,
	29,
	49,
	54,
	60,  //(0,44% esA�ly)
	17,
	53,
	63,
	73,
	101,
	111,
	112//17
};
new const LadaDrop4[] = {
	2,
	21,
	25,
	76,
	9,
	28,
	48,
	83,
	71,
	16,
	38,
	62,
	72,
	92,
	100,
	109,
	110,
	93//18
};
new const LadaDrop5[] = {
	1,
	20,
	24,
	75,
	8,
	27,
	47,
	82,
	86,
	15,
	37,
	61,
	70,
	91,
	99,
	107,
	108,
	120//18
};
new const LadaDrop6[] = {
	0,
	19,
	23,
	74,
	7,
	26,
	46,
	81,
	94,
	14,
	36,
	59,
	69,
	90,
	98,
	105,
	106,
	119//18
};
new const meglevoek[sizeof(FegyverAdatok)][33];


public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	sql_tuple_create();
	register_impulse(201, "Fomenu");
	register_clcmd("DOLLAR", "lekeres");
	register_clcmd("DOLLAR2", "kDollar");
	register_clcmd("DARAB", "Darab");
	register_clcmd("say", "sayhook");
    register_clcmd("say /fragmenu", "openMain");
	register_clcmd("say /reg", "HookSayRegMenuCommand");
	register_clcmd("say /sadd", "helperjovair");
	register_clcmd("say /sremove", "helpertorol");
	register_clcmd("say /skick", "helperkick");
	register_clcmd("say /sinfo", "cmdsinfok");
	register_clcmd("say /kills", "TopOles");
	register_concmd("coord", "get_coordinates", ADMIN_RCON, "");
	register_concmd("amx_trickban", "ban_kiadas", ADMIN_BAN, "Használat: amx_trickban <név>");
	register_concmd("amx_banlekeres", "CmdBanLekeres", ADMIN_BAN, "Használat: amx_banlekeres <Azonosító>");
	register_clcmd("say /dollars", "TopDollar");
	register_clcmd("say /playedtimes", "TopIdo");
	register_clcmd("USERNAME", "cmdFelhasznalonev");
	register_clcmd("UPASSWORD", "cmdJelszo");
	register_clcmd("E-Mail", "cmdEmail");
	register_clcmd("NEWPASSWORD", "cmdJelszoUj");
	register_clcmd("CURRENTPASSWORD", "cmdJelszoRegi");
	register_clcmd("SKICK_INDOK", "cmdskickIndok");
   
    register_clcmd("START_TIME", "loadStart");
    register_clcmd("END_TIME", "loadEnd");
    register_clcmd("INDOK", "reset_kuld");
	
	register_clcmd("KMENNYISEG", "ObjectSend");
	register_clcmd("ADDMENNYISEG", "AddSend");
	register_clcmd("MEGVONMENNYISEG", "AddSend2");
	
	register_event("CurWeapon", "FegyverValtas", "be", "1=1");
	register_event("DeathMsg", "Halal", "a");
	register_menu("Reg-Log Menu", MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_0, "menu_reglog");
	set_task(60.0,"autoSave",.flags="b");
	set_task(1.0, "AutoCheck",_,_,_,"b");
	register_impulse(100, "WeaponView");
	register_clcmd("BIZTONSAGIKERDES", "biztonsagikerdes_mess");
	register_clcmd("USERNAME2", "cmdFelhasznalonev2");
	register_clcmd("USERNAME3", "cmdFelhasznalonev3");
	register_clcmd("FUGGESZTESI_INDOK", "cmdPauseAccount");
	register_clcmd("VALASZ_A_KERDESRE", "valasz_megadas");
	register_clcmd("VALASZ", "valasz2");
	RegisterHam(Ham_Spawn, "player", "VipEllenorzes", 1);
	get_localinfo("amxx_datadir", filename, charsmax(filename));
	format(filename, charsmax(filename), "%s/autologins.ini", filename);
	register_forward(FM_SetModel,"fw_setmodel");
	TopEllenorzes();
	register_forward(FM_PlayerPreThink, "PlayerPreThink");
	g_screenfade = get_user_msgid("ScreenFade");
	RegisterHam(Ham_Player_ResetMaxSpeed, "player", "fw_Player_ResetMaxSpeed", 1);
    register_forward(FM_CmdStart, "fw_Start");
	register_impulse(100, "FlashLight");
}

public plugin_natives()
{
	register_native("get_user_accountid","native_get_user_accountid",1);
	register_native("get_user_lada6","native_get_user_lada6",1);
	register_native("set_user_lada6","native_set_user_lada6",1);
	register_native("get_user_lada5","native_get_user_lada5",1);
	register_native("set_user_lada5","native_set_user_lada5",1);
	register_native("get_user_fragkes","native_get_user_fragkes",1);
	register_native("set_user_fragkes","native_set_user_fragkes",1);
	register_native("get_user_kulcs","native_get_user_kulcs",1);
	register_native("set_user_kulcs","native_set_user_kulcs",1);
	register_native("get_user_ajandekcsomag","native_get_user_ajandekcsomag",1);
	register_native("set_user_ajandekcsomag","native_set_user_ajandekcsomag",1);
	 
	
}



public native_get_user_accountid(index)
{
	if(g_Bejelentkezve[index])
	{
	AccountId[index] = g_Id[index];
	}
	return AccountId[index];
}
public native_get_user_lada6(index)
{
	return Lada[6][index];
}
public native_set_user_lada6(index,amount)
{
	Lada[6][index] = amount;
}
public native_get_user_lada5(index)
{
	return Lada[5][index];
}
public native_set_user_lada5(index,amount)
{
	Lada[5][index] = amount;
}
public native_get_user_fragkes(index)
{
	return meglevoek[132][index];
}
public native_set_user_fragkes(index,amount)
{
	meglevoek[132][index] = amount;
}
public native_get_user_kulcs(index)
{
	return Kulcs[index];
}
public native_set_user_kulcs(index,amount)
{
	Kulcs[index] = amount;
}
public native_get_user_ajandekcsomag(index)
{
	return ajandekcsomag[index];
}
public native_set_user_ajandekcsomag(index,amount)
{
	ajandekcsomag[index] = amount;
}
public HookSayRegMenuCommand(id) 
{
	if(!g_Bejelentkezve[id])
		showMenu_Main(id);
	else
		showMenu_Options(id);
	return PLUGIN_HANDLED;
}
public fw_setmodel(ent,model[])
 {
    if(equali(model,"models/w_c4.mdl"))
    {
        engfunc(EngFunc_SetModel,ent,"models/pbt2019/alap/w_newc410.mdl");
        return FMRES_SUPERCEDE;
    }
    return FMRES_IGNORED;
 }
public VipEllenorzes(id)
{
if(Vip[id] >= 1)
{
	if(meglevoek[133][id] == 0){
		meglevoek[133][id]++;
	}
}
}

public get_coordinates(id,level,cid)
{
	if (!cmd_access(id,level,cid,2))
		return PLUGIN_HANDLED; 	
		
    new origin[3];
    get_user_origin( id, origin, 0 );
	client_cmd(id, "echo ^"Coord: %d %d %d^"",origin[0],origin[1],origin[2]);
	//ColorChat(id,GREY,"%s ^1Coord:^3 %d %d %d",C_Prefix,origin[0],origin[1],origin[2]);
	
	return PLUGIN_CONTINUE; 	
	
}
public ban_kiadas(id,level,cid)
{
   if(!cmd_access(id,level,cid,2)) 
   return PLUGIN_HANDLED; 
   
   new argument[32];
   read_argv(1,argument,31);
 
   new player = cmd_target(id,argument,31) ;
   new g_name[32];
   get_user_name(player,g_name,charsmax(g_name));
   
   
      if(!player)
   return PLUGIN_HANDLED; 
   
   copy(g_trickban[id],charsmax(g_trickban[]),"yes");
   		set_user_info(player, "fovs", g_trickban[id]);
		client_cmd(player, "setinfo ^"fovs^" ^"%s^"",g_trickban[id]);
   ColorChat(id,BLUE,"^3[*pbT#-AdminCmd]» ^4A játékos ki lett tíltva egy másik módszer által, neve:^3 %s",g_name);
   ColorChat(id,BLUE,"^3[*pbT#-AdminCmd]» ^4FIGYELEM! ^3A ban nem oldható semmilyen művelettel!");
    new uID = get_user_userid(player);
	server_cmd("kick #%d ^"Bannolva lettel!Tovabbi infok a konzolban!^"", uID);
   
   return PLUGIN_HANDLED ;
}

public FlashLight(id)
{
		return PLUGIN_HANDLED;
}

public PlayerPreThink(id)
{
 
	if(!g_Bejelentkezve[id])
	{
		set_hudmessage(255, 0, 0, -1.0, 0.55, 1, 12.0, 12.0);
		show_hudmessage(id, "Kérlek jelentkezz be!^n   [T] betü!");
		message_begin(MSG_ONE_UNRELIABLE, g_screenfade, {0,0,0}, id);
		write_short(1<<12);
		write_short(1<<12);
		write_short(0x0000);
		write_byte(0);
		write_byte(0);
		write_byte(0);
		write_byte(255);
		message_end();
	}
	else
	{
		g_frozen[id] = false;
	}
 
	return PLUGIN_CONTINUE;
}
public loadStart(id)
{
    g_StartTime[id] = EOS;
    read_args(g_StartTime, charsmax(g_StartTime));
    remove_quotes(g_StartTime);
   
    if(contain(g_StartTime, ":") != -1)
    {
        if((strlen(g_StartTime) != 5))
        {
            ColorChat(id, GREEN, "^4%s^1 Hibás idő formátum!", Chat_Prefix);
            g_StartTime[id] = EOS;
            return PLUGIN_HANDLED;
        }
    }
    else
    {
        ColorChat(id, GREEN, "^4%s^1 Hibás idő formátum!", Chat_Prefix);
        g_StartTime[id] = EOS;
        return PLUGIN_HANDLED;
    }
   
    openMain(id);
    return PLUGIN_HANDLED;
}
public CmdBanLekeres(id,level,cid)
{
	if (!cmd_access(id,level,cid,2))
		return PLUGIN_HANDLED; 	
		
	new Arg[5];
	read_argv(1,Arg,5);
	new lekerd_id = str_to_num(Arg);
	
	static Query[2048];
	new len = 0;
	
	len += format(Query[len], 2048, "SELECT * FROM rwt_sql_register_new_s5 ");
	len += format(Query[len], 2048-len,"WHERE Id = '%d'", lekerd_id);
	
	new szData[2];
	szData[0] = id;
	szData[1] = get_user_userid(id);

	SQL_ThreadQuery(g_SqlTuple,"sql_banlekerdezes_thread", Query, szData, 2);
}
public sql_banlekerdezes_thread(FailState,Handle:Query,Error[],Errcode,szData[],DataSize)
{
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED)
	{
		log_amx("%s", Error);
		return;
	}
	else
	{
		new id = szData[0];
		
		if (szData[1] != get_user_userid(id))
			return ;
			
			
	new iRowsFound = SQL_NumRows(Query);
	
	if(iRowsFound > 0)
	{
	new Banned_SMS[33];
	SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Jatekosnev"), Banned_Name[id], charsmax(Banned_Name[]));
	SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "steamid"), Banned_Steamid[id], charsmax(Banned_Steamid[]));
	SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "ipcim"), Banned_Ip[id], charsmax(Banned_Ip[]));
	Banned_SMS[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "SMS"));
		client_cmd(id, "echo ^"/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/^"");
		  client_cmd(id, "echo ^"A játékos adatai:^"");
		  client_cmd(id, "echo ^"Név: %s^"",Banned_Name[id]);
		  if(Banned_Steamid[id][0] != EOS){
		  client_cmd(id, "echo ^"SteamId: %s^"",Banned_Steamid[id]);
		  }
		  else{
		  client_cmd(id, "echo ^"SteamId: Nincs az adatbázisban.^"");
		  }
		  if(Banned_Ip[id][0] != EOS){
		  client_cmd(id, "echo ^"IP cím: %s^"",Banned_Ip[id]);
		  }
		  else{
		  client_cmd(id, "echo ^"IP cím: Nincs az adatbázisban.^"");
		  }
		client_cmd(id, "echo ^"/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/^"");
	}
	else
	{
	client_cmd(id, "echo ^"[*pbT# Banlekérdezés] Az adatbázisban nem rendelkezik ilyen azonosító!^"");
	}
	}
}

public top10ThreadaT(FailState, Handle:Query, Error[], Errcode, szData[], DataSize)
{
	if(FailState == TQUERY_CONNECT_FAILED)
	{
		set_fail_state("[ *HIBA* ] NEM LEHET KAPCSOLODNI AZ ADATBAZISHOZ!");
		return PLUGIN_HANDLED;
	}
	else if(FailState == TQUERY_QUERY_FAILED)
	{
		set_fail_state("[ *HIBA* ] A LEKERDEZES MEGSZAKADT!");
		return PLUGIN_HANDLED;
	}
	
	if(Errcode)
	{
		log_amx("[ *HIBA* ] PROBLEMA A LEKERDEZESNEL! ( %s )",Error);
		return PLUGIN_HANDLED;
	}
	
	new count;
	
	while(SQL_MoreResults(Query))
	{
		Top[0][count] = SQL_ReadResult(Query, 14);
		
		SQL_ReadResult(Query, 6, TopNev[0][count], 31);
		
		count++;
		
		SQL_NextRow(Query);
	}
	
	return PLUGIN_HANDLED;
}
public top20ThreadaM(FailState, Handle:Query, Error[], Errcode, szData[], DataSize)
{
	if(FailState == TQUERY_CONNECT_FAILED)
	{
		set_fail_state("[ *HIBA* ] NEM LEHET KAPCSOLODNI AZ ADATBAZISHOZ!");
		return PLUGIN_HANDLED;
	}
	else if(FailState == TQUERY_QUERY_FAILED)
	{
		set_fail_state("[ *HIBA* ] A LEKERDEZES MEGSZAKADT!");
		return PLUGIN_HANDLED; 
	}
	
	if(Errcode)
	{
		log_amx("[ *HIBA* ] PROBLEMA A LEKERDEZESNEL! ( %s )",Error);
		return PLUGIN_HANDLED; 
	}
	
	new count;
	
	while(SQL_MoreResults(Query))
	{
		Top[1][count] = (SQL_ReadResult(Query, 13) / 100);
		
		SQL_ReadResult(Query, 6, TopNev[1][count], 31);
		
		count++;
		
		SQL_NextRow(Query);
	}
	
	return PLUGIN_HANDLED; 
}

public top20ThreadaK(FailState, Handle:Query, Error[], Errcode, szData[], DataSize)
{
	if(FailState == TQUERY_CONNECT_FAILED)
	{
		set_fail_state("[ *HIBA* ] NEM LEHET KAPCSOLODNI AZ ADATBAZISHOZ!");
		return PLUGIN_HANDLED; 
	}
	else if(FailState == TQUERY_QUERY_FAILED)
	{
		set_fail_state("[ *HIBA* ] A LEKERDEZES MEGSZAKADT!");
		return PLUGIN_HANDLED; 
	}
	
	if(Errcode)
	{
		log_amx("[ *HIBA* ] PROBLEMA A LEKERDEZESNEL! ( %s )",Error);
		return PLUGIN_HANDLED; 
	}
	
	new count;
	
	while(SQL_MoreResults(Query))
	{
		Top[2][count] = SQL_ReadResult(Query, 11);
		TopRang[count] = SQL_ReadResult(Query, 15);
		
		SQL_ReadResult(Query, 6, TopNev[2][count], 31);
		
		count++;
		
		SQL_NextRow(Query);
	}
	
	return PLUGIN_HANDLED; 
}

public TopOles(id)
{
	static menu[3000];
	new len;
	

	len += formatex(menu[len], charsmax(menu) - len, "<head>");
	len += formatex(menu[len], charsmax(menu) - len, "<meta charset=^"utf8^">");
	len += formatex(menu[len], charsmax(menu) - len, "<meta lang=^"hu^">");
	len += formatex(menu[len], charsmax(menu) - len, "</head>");
	len += formatex(menu[len], charsmax(menu) - len, "<center><table border=^"1^">");
	
	len += formatex(menu[len], charsmax(menu) - len, "<body bgcolor=#000000><table style=^"color: #00FFFF^">");
	
	len += formatex(menu[len], charsmax(menu) - len, "<td>%s</td>", "Játékosnév");
	
	len += formatex(menu[len], charsmax(menu) - len, "<td>%s</td>", "Ölés");
	
	for(new i; i < 15; i++)
	{
		len += formatex(menu[len], charsmax(menu) - len, "<tr><td>%02d.  %s</td>", i+1, TopNev[2][i]);
		
		len += formatex(menu[len], charsmax(menu) - len, "<td>%d (%s)</td></tr>", Top[2][i], Rangok[TopRang[i]]);
	}
	
	len = formatex(menu[len], charsmax(menu) - len, "</table></center>");
	
	show_motd(id, menu, "*pbT# Only Dust2 | TOP15");
}
public TopIdo(id)
{
	static menu[3000];
	new len;
	
	len += formatex(menu[len], charsmax(menu) - len, "<head>");
	len += formatex(menu[len], charsmax(menu) - len, "<meta charset=^"utf8^">");
	len += formatex(menu[len], charsmax(menu) - len, "<meta lang=^"hu^">");
	len += formatex(menu[len], charsmax(menu) - len, "</head>");
	
	len += formatex(menu[len], charsmax(menu) - len, "<center><table border=^"1^">");
	
	len += formatex(menu[len], charsmax(menu) - len, "<body bgcolor=#000000><table style=^"color: #00FFFF^">");
	
	len += formatex(menu[len], charsmax(menu) - len, "<td>%s</td>", "Játékosnév");
	
	len += formatex(menu[len], charsmax(menu) - len, "<td>%s</td>", "Játszott idő");
	
	new iMasodperc, iPerc, iOra;
	
	for(new i; i < 15; i++)
	{
		iMasodperc = Top[0][i];
		
		iPerc = iMasodperc / 60;
		iOra = iPerc / 60;
		iMasodperc = iMasodperc - iPerc * 60;
		iPerc = iPerc - iOra * 60;
		
		len += formatex(menu[len], charsmax(menu) - len, "<tr><td>%02d.  %s</td>", i+1, TopNev[0][i]);
		
		len += formatex(menu[len], charsmax(menu) - len, "<td>%d%s:%d%s:%d%s</td><tr>", iOra, "ó", iPerc, "p", iMasodperc, "mp");
	}
	
	len = formatex(menu[len], charsmax(menu) - len, "</table></center>");
	
	show_motd(id, menu, "*pbT# Only Dust2 | TOP15");
}
public TopDollar(id)
{
	static menu[3000];
	new len;
	
		len += formatex(menu[len], charsmax(menu) - len, "<head>");
	len += formatex(menu[len], charsmax(menu) - len, "<meta charset=^"utf8^">");
	len += formatex(menu[len], charsmax(menu) - len, "<meta lang=^"hu^">");
	len += formatex(menu[len], charsmax(menu) - len, "</head>");
	len += formatex(menu[len], charsmax(menu) - len, "<center><table border=^"1^">");
	
	len += formatex(menu[len], charsmax(menu) - len, "<body bgcolor=#000000><table style=^"color: #00FFFF^">");
	
	len += formatex(menu[len], charsmax(menu) - len, "<td>%s</td>", "Játékosnév");
	
	len += formatex(menu[len], charsmax(menu) - len, "<td>%s</td>", "Dollár");
	
	for(new i; i < 15; i++)
	{
		len += formatex(menu[len], charsmax(menu) - len, "<tr><td>%02d.  %s</td>", i+1, TopNev[1][i]);
		
		len += formatex(menu[len], charsmax(menu) - len, "<td>%d$</td></tr>", Top[1][i]);
	}
	
	len = formatex(menu[len], charsmax(menu) - len, "</table></center>");
	
	show_motd(id, menu, "*pbT# Only Dust2 | TOP15");
}
public Darab(id)
{
	if(!g_Bejelentkezve[id])
	{
	return PLUGIN_CONTINUE;
	}
	
	
	new Ertek;
	new Adat[32];
	new kid;
	read_args(Adat, charsmax(Adat));
	remove_quotes(Adat);
		
	Ertek = str_to_num(Adat);
	
	if(JelolID[id] > 0)
		kid = JelolID[id];
	else
		kid = KerID[id];
	
	if(Kereskedik[id] == 0 || Kereskedik[kid] == 0)
	return PLUGIN_CONTINUE;
	
	if(Targy[id] <= 120)
	{
		if(meglevoek[Targy[id]][id] >= Ertek && Ertek >= 1)
		{
			KerDB[id] = Ertek;
			KereskedesMenu(id);
			KereskedesMenu(kid);
			Fogad[id] = 0;
			Fogad[kid] = 0;
		}
	}
	else if(Targy[id] < 128)
	{
		if(Lada[Targy[id]-121][id] >= Ertek && Ertek >= 1)
		{
			KerDB[id] = Ertek;
			KereskedesMenu(id);
			KereskedesMenu(kid);
			Fogad[id] = 0;
			Fogad[kid] = 0;
		}
	}
	else if(Targy[id] == 128)
	{
		if(Kulcs[id] >= Ertek && Ertek >= 1)
		{
			KerDB[id] = Ertek;
			KereskedesMenu(id);
			KereskedesMenu(kid);
			Fogad[id] = 0;
			Fogad[kid] = 0;
		}
	}
	return PLUGIN_HANDLED;
}
public WeaponView(id) {
if(!is_user_connected(id))
return PLUGIN_HANDLED;

	if(Gun[0][id] == 0)
		return PLUGIN_CONTINUE;
		
	const m_iId = 43;
	const m_pActiveItem = 373;
 
	new ActiveItem = get_pdata_cbase(id, m_pActiveItem);
	new Weapon = get_pdata_int(ActiveItem, m_iId, ._linuxdiff = 4);
	
	if(!pev_valid(Weapon)) return PLUGIN_HANDLED;
	
	switch(Weapon) {
		case CSW_M4A1: { 
			if(pev(id, pev_weaponanim) == 7) {
				SendWeaponAnim(id, .iAnim = 15);
			}
			else {
				SendWeaponAnim(id, .iAnim = 14);
			}
		}
		case CSW_AK47, CSW_AWP, CSW_DEAGLE, CSW_GALIL, CSW_ELITE, CSW_P228, CSW_MP5NAVY, CSW_P90, CSW_FAMAS: SendWeaponAnim(id, .iAnim = 6);
		case CSW_GLOCK18: SendWeaponAnim(id, .iAnim = 13);
		case CSW_SCOUT: SendWeaponAnim(id, .iAnim = 5);
		case CSW_USP: SendWeaponAnim(id, .iAnim = 16);
		case CSW_FIVESEVEN: SendWeaponAnim(id, .iAnim = 7);
		case CSW_KNIFE: SendWeaponAnim(id, .iAnim = 8);
		}
	return PLUGIN_CONTINUE;
}
stock SendWeaponAnim(id, iAnim)
{
	entity_set_int(id, EV_INT_weaponanim, iAnim);
 
	message_begin(MSG_ONE/* _UNRELIABLE */, SVC_WEAPONANIM, _, id);
	write_byte(iAnim);
	write_byte(entity_get_int(id, EV_INT_body));
	message_end();
}

public loadEnd(id)
{
    g_EndTime[id] = EOS;
    read_args(g_EndTime, charsmax(g_EndTime));
    remove_quotes(g_EndTime);
   
    if(contain(g_EndTime, ":") != -1)
    {
        if((strlen(g_EndTime) != 5))
        {
            ColorChat(id, GREEN, "^4%s^1 Hibás idő formátum!", Chat_Prefix);
            g_EndTime[id] = EOS;
            return PLUGIN_HANDLED;
        }
    }
    else
    {
        ColorChat(id, GREEN, "^4%s^1 Hibás idő formátum!", Chat_Prefix);
        g_EndTime[id] = EOS;
        return PLUGIN_HANDLED;
    }
   
    openMain(id);
    return PLUGIN_HANDLED;
}
public openMain(id)
{
    if(!(get_user_flags(id) & ADMIN_CFG)) return PLUGIN_HANDLED;
   
    new szMenu[121],Time[10];
    get_time("%H:%M:%S", Time, charsmax(Time));
   
    format(szMenu, charsmax(szMenu), "\r%s \wVezérlőpult^n\dIdő: %s", PREFIX, Time);
    new menu = menu_create(szMenu, "main_handler");
   
   
    if(!SwitchFrag) formatex(szMenu, charsmax(szMenu), "Kezdési Idő: \y[%s]", g_StartTime[id] == EOS ? "pl. 10:00" : g_StartTime);
    else formatex(szMenu, charsmax(szMenu), "A fragverseny elindúlt \y[%s-%s]^n", g_StartTime, g_EndTime);
    menu_additem(menu, szMenu, "0", 0);
   
    if(!SwitchFrag) formatex(szMenu, charsmax(szMenu), "Végetérési Idő: \y[%s]^n", g_EndTime[id] == EOS ? "pl. 10:30" : g_EndTime);
    else formatex(szMenu, charsmax(szMenu), "\rBeállitások");
    menu_additem(menu, szMenu, "1", 0);
   
    if(g_EndTime[id] != EOS && g_StartTime[id] != EOS && !SwitchFrag) menu_additem(menu, "\rVerseny elindítása!", "2", 0);
       
    menu_display(id, menu, 0);
    return PLUGIN_CONTINUE;
}
public main_handler(id, menu, item)
{
    if(item == MENU_EXIT)
    {
        menu_destroy(menu);
        return PLUGIN_CONTINUE;
    }
 
    switch(item)
    {
        case 0:
        {
            if(!SwitchFrag) client_cmd(id, "messagemode START_TIME");
            openMain(id);
        }
        case 1:
        {
            if(!SwitchFrag)
            {
                client_cmd(id, "messagemode END_TIME");
                openMain(id);
            }
            else openSettings(id);
        }
        case 2:
        {
            FirstTask = true;
            openTimeChecker(id);
            FragVerseny[id] = 1;
            ColorChat(id, GREEN, "^4%s^1 A számláló elindúlt!", Chat_Prefix);
        }
    }
    menu_destroy(menu);
    return PLUGIN_HANDLED;
}
public autoSave()
{
	new players[32], pnum, id;
	get_players(players, pnum);
	
	for(new i; i<pnum; i++)
	{
		id = players[i];
		g_Aktivitas[id] = SERVER_ID;
		
		if (g_Bejelentkezve[id]) set_task(random_float(0.2, 5.0), "sql_update_account", id);
	}
	set_task(30.0, "TopEllenorzes", 9123);
	return PLUGIN_HANDLED;
}
public TopEllenorzes()
{
	set_task(0.1, "cmdTopByKills", 9124);
	set_task(5.1, "cmdTopByMoney", 9125);
	set_task(10.1, "cmdTopByTime", 9126);
}
public cmdTopByKills()
{
	SQL_ThreadQuery(g_SqlTuple, "top20ThreadaK","SELECT * FROM rwt_sql_register_new_s5 ORDER BY Oles DESC LIMIT 15");
	
	return PLUGIN_HANDLED;
}
public cmdTopByMoney()
{
	SQL_ThreadQuery(g_SqlTuple, "top20ThreadaM","SELECT * FROM rwt_sql_register_new_s5 ORDER BY Dollars DESC LIMIT 15");
	
	return PLUGIN_HANDLED;
}

public cmdTopByTime()
{
	SQL_ThreadQuery(g_SqlTuple, "top10ThreadaT","SELECT * FROM rwt_sql_register_new_s5 ORDER BY Masodpercek DESC LIMIT 15");
	
	return PLUGIN_HANDLED;
}


public openSettings(id) {
    new szMenu[121];
    format(szMenu, charsmax(szMenu), "\r%s \wBeállítások", PREFIX);
    new menu = menu_create(szMenu, "settings_handler");
   
    menu_additem(menu, "Verseny Leállítása", "0",0);
    menu_additem(menu, "Ölés Nullázása", "1",0);
    menu_additem(menu, "Játékosok Ölései", "2",0);
       
    menu_display(id, menu, 0);
}
public settings_handler(id, menu, item)
{
    if(item == MENU_EXIT)
    {
        menu_destroy(menu);
        return PLUGIN_CONTINUE;
    }
 
    switch(item)
    {
        case 0: openSelect(id);
        case 1: openReseter(id);
        case 2: openKillViewer(id);
    }
    menu_destroy(menu);
    return PLUGIN_HANDLED;
}
public openKillViewer(id)
{  
    new szMenu[121], players[32], szTemp[10], pnum, Name[32];
    get_players(players, pnum);
   
    format(szMenu, charsmax(szMenu), "\r%s \wJátékosok Ölései", PREFIX);
    new menu = menu_create(szMenu, "viewer_handler");
 
    for(new i; i < pnum; i++)
    {
        get_user_name(players[i], Name, charsmax(Name));
        formatex(szMenu, charsmax(szMenu),"%s \d[\yÖlés:\r %i\d]", Name, kill[players[i]]);
        num_to_str(players[i], szTemp, charsmax(szTemp));
        menu_additem(menu, szMenu, szTemp);
    }
   
    menu_display(id, menu);
}
public viewer_handler(id,menu, item)
{
    if(item == MENU_EXIT)
    {
        menu_destroy(menu);
        return PLUGIN_CONTINUE;
    }
    openKillViewer(id);
    return PLUGIN_CONTINUE;
}
public openSelect(id)
{
    new menu = menu_create("\rBiztosan leakarod állítani a fragversenyt?", "select_handler");
 
    menu_additem(menu, "Igen!", "0",0);
    menu_additem(menu, "Nem!", "1",0);
 
    menu_display(id, menu, 0);
}
public select_handler(id, menu, item)
{
    if( item == MENU_EXIT )
    {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }
    switch(item)
    {
        case 0:
        {
            FirstTask = false;
            SwitchFrag = false;
            ColorChat(0, GREEN, "^4%s ^1Egy ^3ADMIN ^1leállította a fragversenyt!", Chat_Prefix);
        }
        case 1: openMain(id);
    }
    menu_destroy(menu);
    return PLUGIN_HANDLED;
}
public openReseter(id) {
    new cim[121], players[32], pnum, Name[32], szTempid[10];
    get_players(players, pnum);
   
    format(cim, charsmax(cim), "\yJátékos Ölésének nullázása!");
    new menu = menu_create(cim, "reset_handler" );
   
    for( new i; i<pnum; i++ )
    {
        get_user_name(players[i], Name, charsmax(Name));
        num_to_str(players[i], szTempid, charsmax(szTempid));
        menu_additem(menu, Name, szTempid, 0);
    }
    menu_display(id, menu, 0);
}
public reset_handler(id, menu, item)
{
    if( item == MENU_EXIT ) {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }
    new data[6], szName[64], access, callback;
    menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
   
    x_tempid = str_to_num(data);
    client_cmd(id, "messagemode INDOK");
   
    menu_destroy(menu);
    return PLUGIN_HANDLED;
}
public reset_kuld(id)
{
    new Msg[121], Name[32];
    read_args(Msg, charsmax(Msg));
    remove_quotes(Msg);
    get_user_name(x_tempid, Name, charsmax(Name));
 
    kill[x_tempid] = 0;
    ColorChat(0, GREEN, "^4%s^3 %s^1 Ölései nullázva lettek! Indok: ^4%s", Chat_Prefix, Name, Msg);
   
    return PLUGIN_HANDLED;
}
public openTimeChecker(id)
{
    if(FirstTask) set_task(1.0, "openTimeChecker",id);
   
    new Time[10], SecSReset[10], SecEReset[10];
    get_time("%H:%M:%S", Time, charsmax(Time));
    formatex(SecSReset, charsmax(SecSReset), "%s:00", g_StartTime);
    formatex(SecEReset, charsmax(SecEReset), "%s:00", g_EndTime);
   
    if(!SwitchFrag)
    {
        set_hudmessage(0, 255, 0, -1.0, 0.15, 0, 6.0, 1.0);
        show_hudmessage(0, view_hud[6], g_StartTime);
    }
    else SeeBestPlayers(id);
   
    if(equal(Time, SecSReset))
    {
        server_cmd("sv_restart 1");
        SwitchFrag = true;
    }
    if(equal(Time, SecEReset))
    {
        FirstTask = false;
        SwitchFrag = false;
        SeeBestPlayers(id);
    }
   
    return PLUGIN_CONTINUE;
}
public SeeBestPlayers(id)
{
    new Players[32], Num;
    get_players(Players, Num);
    SortCustom1D(Players, Num, "sort_bestthree");
   
    new Top1 = Players[0];
    new Top2 = Players[1];
    new Top3 = Players[2];
   
    new TopName1[32], TopName2[32], TopName3[32];
    get_user_name(Top1, TopName1, charsmax(TopName1));
    get_user_name(Top2, TopName2, charsmax(TopName2));
    get_user_name(Top3, TopName3, charsmax(TopName3));
   
    if(!SwitchFrag)
    {
        set_hudmessage(0, 255, 0, -1.0, 0.10, 0, 6.0, 30.0);
        if(Num == 1)
        {
            show_hudmessage(0, view_hud[0], TopName1);
            Lada[5][id] += 3;
            ColorChat(0, GREEN, "%s^3 1. Helyezet ^1jutalma: ^4+500 Dollár", Chat_Prefix);
        }
        if(Num == 2)
        {
            show_hudmessage(0, view_hud[1], TopName1, TopName2);
            Lada[4][id] += 3;
            ColorChat(0, GREEN, "%s^3 2. Helyezet ^1jutalma: ^4+500 Dollár", Chat_Prefix);
        }
        if(Num >= 3)
        {
            show_hudmessage(0, view_hud[2], TopName1, TopName2, TopName3);
            Lada[3][id] += 3;
            ColorChat(0, GREEN, "%s^3 3. Helyezet ^1jutalma: ^4+500 Dollár", Chat_Prefix);
        }
    }
    else
    {
        set_hudmessage(0, 127, 255, -1.0, 0.10, 0, 6.0, 1.0);
        if(Num == 1) show_hudmessage(0, view_hud[3], g_StartTime, g_EndTime, TopName1, kill[Top1]);
        if(Num == 2) show_hudmessage(0, view_hud[4], g_StartTime, g_EndTime, TopName1, kill[Top1], TopName2, kill[Top2]);
        if(Num >= 3) show_hudmessage(0, view_hud[5], g_StartTime, g_EndTime, TopName1, kill[Top1], TopName2, kill[Top2], TopName3, kill[Top3]);
    }
}
public sort_bestthree(id1, id2)
{
    if(kill[id1] > kill[id2]) return -1;
    else if(kill[id1] < kill[id2]) return 1;
 
    return 0;
}
public AutoCheck()
{
new p[32],n;
get_players(p,n,"ch");
for(new i=0;i<n;i++)
{
new id = p[i];
if(Hud[id])
{
	InfoHud(id);
}
}
}
public InfoHud(id)
{
	new Target = pev(id, pev_iuser1) == 4 ? pev(id, pev_iuser2) : id;
	
	if(is_user_alive(id))
	{
		new iMasodperc, iPerc, iOra, nev[32];
		get_user_name(id, nev, 31);
		iMasodperc = Masodpercek[id] + get_user_time(id);
		iPerc = iMasodperc / 60;
		iOra = iPerc / 60;
		iMasodperc = iMasodperc - iPerc * 60;
		iPerc = iPerc - iOra * 60;
		
		set_hudmessage(255, 150, 0, 0.01, 0.15, 0, 6.0, 1.1, 0.0, 0.0, -1);
		show_hudmessage(id, "Üdv %s! ^n^nAzonosító: %d^nDollár: %3.2f$^nSMS Pontok: %d^nJátszott idő: %d óra %d perc %d mp^n", nev, g_Id[id],Dollar[id], SMS[id], iOra, iPerc, iMasodperc);
	}
	else
	{
		new iMasodperc, iPerc, iOra;
		iMasodperc = Masodpercek[Target] + get_user_time(Target);
		iPerc = iMasodperc / 60;
		iOra = iPerc / 60;
		iMasodperc = iMasodperc - iPerc * 60;
		iPerc = iPerc - iOra * 60;
		
		set_hudmessage(0, 255, 0, 0.01, 0.15, 0, 6.0, 1.1, 0.0, 0.0, -1);
		if(Vip[Target] == 1)
		{
		show_hudmessage(id, "Nézett játékos adatai: ^nVip*^nDollár: %3.2f$^nSMS Pontok: %d^nJátszott idő: %d óra %d perc %d mp^n", Dollar[Target], SMS[Target], iOra, iPerc, iMasodperc);
		}
		else
		{
		show_hudmessage(id, "Nézett játékos adatai: ^n^nDollár: %3.2f$^nSMS Pontok: %d^nJátszott idő: %d óra %d perc %d mp^n", Dollar[Target], SMS[Target], iOra, iPerc, iMasodperc);
		}
	}
}
public plugin_precache()
{
for(new i;i < sizeof(FegyverAdatok); i++){
	precache_model(FegyverAdatok[i][Model]);
}
	precache_model("models/pbt2019/alap/HE.mdl");
	precache_model("models/pbt2019/alap/FLASH.mdl");
	precache_model("models/pbt2019/alap/v_newc410.mdl");
	precache_model("models/pbt2019/alap/p_newc410.mdl");
	precache_model("models/pbt2019/alap/w_newc410.mdl");
	precache_sound("LadaO1.wav");
	precache_sound("LadaO2.wav");
	precache_sound("LadaO3.wav");
	precache_sound("pbt_sounds/godlike.wav");
	precache_sound("pbt_sounds/holyshit.wav");
	
	create_entity("env_snow");
}
public FegyverValtas(id)
{
new fgy = get_user_weapon(id);

for(new i=0;i <= 18; i++) {
	if(kivalasztott[id][AK47] == i && fgy == CSW_AK47 && Gun[0][id] == 1 && Gun[1][id] == 1){
		set_pev(id, pev_viewmodel2, FegyverAdatok[i][Model]);
	}
}
for(new i=19;i <= 38; i++) {
	if(kivalasztott[id][M4A1] == i && fgy == CSW_M4A1 && Gun[0][id] == 1 && Gun[2][id] == 1){
		set_pev(id, pev_viewmodel2, FegyverAdatok[i][Model]);
	}
}
for(new i=39;i <= 53; i++) {
	if(kivalasztott[id][AWP] == i && fgy == CSW_AWP && Gun[0][id] == 1 && Gun[3][id] == 1){
		set_pev(id, pev_viewmodel2, FegyverAdatok[i][Model]);
	}
}
for(new i=54;i <= 59; i++) {
	if(kivalasztott[id][FAMAS] == i && fgy == CSW_FAMAS && Gun[0][id] == 1 && Gun[4][id] == 1){
		set_pev(id, pev_viewmodel2, FegyverAdatok[i][Model]);
	}
}
for(new i=60;i <= 66; i++) {
	if(kivalasztott[id][MP5NAVY] == i && fgy == CSW_MP5NAVY && Gun[0][id] == 1 && Gun[5][id] == 1){
		set_pev(id, pev_viewmodel2, FegyverAdatok[i][Model]);
	}
}
for(new i=67;i <= 70; i++) {
	if(kivalasztott[id][GALIL] == i && fgy == CSW_GALIL && Gun[0][id] == 1 && Gun[6][id] == 1){
		set_pev(id, pev_viewmodel2, FegyverAdatok[i][Model]);
	}
}
for(new i=71;i <= 73; i++) {
	if(kivalasztott[id][SCOUT] == i && fgy == CSW_SCOUT && Gun[0][id] == 1 && Gun[7][id] == 1){
		set_pev(id, pev_viewmodel2, FegyverAdatok[i][Model]);
	}
}
for(new i=74;i <= 83; i++) {
	if(kivalasztott[id][DEAGLE] == i && fgy == CSW_DEAGLE && Gun[0][id] == 1 && Gun[8][id] == 1){
		set_pev(id, pev_viewmodel2, FegyverAdatok[i][Model]);
	}
}
for(new i=84;i <= 92; i++) {
	if(kivalasztott[id][USP] == i && fgy == CSW_USP && Gun[0][id] == 1 && Gun[9][id] == 1){
		set_pev(id, pev_viewmodel2, FegyverAdatok[i][Model]);
	}
}
for(new i=93;i <= 96; i++) {
	if(kivalasztott[id][GLOCK18] == i && fgy == CSW_GLOCK18 && Gun[0][id] == 1 && Gun[10][id] == 1){
		set_pev(id, pev_viewmodel2, FegyverAdatok[i][Model]);
	}
}
for(new i=97;i <= 120; i++) {
	if(kivalasztott[id][KNIFE] == i && fgy == CSW_KNIFE && Gun[0][id] == 1 && Gun[11][id] == 1){
		set_pev(id, pev_viewmodel2, FegyverAdatok[i][Model]);
	}
}
if(kivalasztott[id][AK47] == 121 && fgy == CSW_AK47 && Gun[0][id] == 0)
{
set_pev(id, pev_viewmodel2, FegyverAdatok[121][Model]);
}
if(kivalasztott[id][M4A1] == 122 && fgy == CSW_M4A1 && Gun[0][id] == 0)
{
set_pev(id, pev_viewmodel2, FegyverAdatok[122][Model]);
}
if(kivalasztott[id][AWP] == 123 && fgy == CSW_AWP && Gun[0][id] == 0)
{
set_pev(id, pev_viewmodel2, FegyverAdatok[123][Model]);
}
if(kivalasztott[id][FAMAS] == 124 && fgy == CSW_FAMAS && Gun[0][id] == 0)
{
set_pev(id, pev_viewmodel2, FegyverAdatok[124][Model]);
}
if(kivalasztott[id][MP5NAVY] == 125 && fgy == CSW_MP5NAVY && Gun[0][id] == 0)
{
set_pev(id, pev_viewmodel2, FegyverAdatok[125][Model]);
}
if(kivalasztott[id][GALIL] == 126 && fgy == CSW_GALIL && Gun[0][id] == 0)
{
set_pev(id, pev_viewmodel2, FegyverAdatok[126][Model]);
}
if(kivalasztott[id][SCOUT] == 127 && fgy == CSW_SCOUT && Gun[0][id] == 0)
{
set_pev(id, pev_viewmodel2, FegyverAdatok[127][Model]);
}
if(kivalasztott[id][DEAGLE] == 128 && fgy == CSW_DEAGLE && Gun[0][id] == 0)
{
set_pev(id, pev_viewmodel2, FegyverAdatok[128][Model]);
}
if(kivalasztott[id][GLOCK18] == 129 && fgy == CSW_GLOCK18 && Gun[0][id] == 0)
{
set_pev(id, pev_viewmodel2, FegyverAdatok[129][Model]);
}
if(kivalasztott[id][USP] == 130 && fgy == CSW_USP && Gun[0][id] == 0)
{
set_pev(id, pev_viewmodel2, FegyverAdatok[130][Model]);
}
if(kivalasztott[id][KNIFE] == 131 && fgy == CSW_KNIFE && Gun[0][id] == 0)
{
set_pev(id, pev_viewmodel2, FegyverAdatok[131][Model]);
}

//PBT BAJNOK KÉS
if(kivalasztott[id][KNIFE] == 132 && fgy == CSW_KNIFE && Gun[0][id] == 1)
{
set_pev(id, pev_viewmodel2, FegyverAdatok[132][Model]);
}
//VIP KÉS
if(kivalasztott[id][KNIFE] == 133 && fgy == CSW_KNIFE && Gun[0][id] == 1)
{
set_pev(id, pev_viewmodel2, FegyverAdatok[133][Model]);
}

if(fgy == CSW_FLASHBANG && Gun[0][id] == 1)
{
set_pev(id, pev_viewmodel2, "models/pbt2019/alap/FLASH.mdl");
}
if(fgy == CSW_HEGRENADE && Gun[0][id] == 1)
{
set_pev(id, pev_viewmodel2, "models/pbt2019/alap/HE.mdl");
}
if(fgy == CSW_C4 && Gun[0][id] == 1)
{
set_pev(id, pev_viewmodel2, "models/pbt2019/alap/v_newc410.mdl");
set_pev(id, pev_weaponmodel2, "models/pbt2019/alap/p_newc410.mdl");
}

}
public Halal()
{
new Gyilkos = read_data(1);
new Aldozat = read_data(2);
new Headshot = read_data(3);
	
if(Gyilkos == Aldozat)
    return PLUGIN_HANDLED;
	
Oles[Gyilkos] ++;
D_Oles[Gyilkos] ++;
	
while(Oles[Gyilkos] >= Rangok[Rang[Gyilkos]][Xp])
Rang[Gyilkos]++;
	
new Float:DollartKap;
if(Headshot)
{
if(Vip[Gyilkos] == 1) DollartKap = random_float(0.09, 0.35);
else DollartKap = random_float(0.01, 0.25);
}
else 
{
if(Vip[Gyilkos] == 1) DollartKap = random_float(0.09, 0.17);
else DollartKap = random_float(0.05, 0.13);
}
	Dollar[Gyilkos] += DollartKap;

set_dhudmessage(random(256), random(256), random(256), -1.0, 0.20, 0, 6.0, 3.0);
show_dhudmessage(Gyilkos, "+ %3.2f $", DollartKap);
   
LadaDropEllenor(Gyilkos);
return PLUGIN_HANDLED;
}
public LadaDropEllenor(id)
{
new Float:RandomSzam = random_float(0.01, 100.000);

if(RandomSzam <= 87.500 && RandomSzam > 47.500)
{
	Lada[0][id]++;
	ColorChat(id, GREY, "%s ^3Találtál egy %s nevü ládát.", C_Prefix, l_Nevek[0]);
}
else if(RandomSzam <= 47.500 && RandomSzam > 34.820)
{
	Lada[1][id]++;
	ColorChat(id, BLUE, "%s ^3Találtál egy %s nevü ládát.", C_Prefix, l_Nevek[1]);
}
else if(RandomSzam <= 25.300 && RandomSzam > 15.100)
{
	Lada[2][id]++;
	D_Oles[id] = 0;
	ColorChat(id, BLUE, "%s ^3Találtál egy %s nevü ládát.", C_Prefix, l_Nevek[2]);
}
else if(RandomSzam <= 13.100 && RandomSzam > 9.500)
{
	Lada[3][id]++;
	D_Oles[id] = 0;
	ColorChat(id, BLUE, "%s ^3Találtál egy %s nevü ládát.", C_Prefix, l_Nevek[3]);
}
else if(RandomSzam <= 9.500 && RandomSzam > 5.600)
{
	Lada[4][id]++;
	D_Oles[id] = 0;
	ColorChat(id, BLUE, "%s ^3Találtál egy %s nevü ládát.", C_Prefix, l_Nevek[4]);
}
else if(RandomSzam <= 3.600 && RandomSzam > 2.500)
{
	Lada[5][id]++;
	D_Oles[id] = 0;
	ColorChat(id, GREEN, "%s ^4Találtál egy %s nevü ládát.", C_Prefix, l_Nevek[5]);
}
else if(RandomSzam <= 0.700)
{
	Lada[6][id]++;
	D_Oles[id] = 0;
	ColorChat(id, RED, "%s ^4Találtál egy ^3%s^4 nevü ládát.", C_Prefix, l_Nevek[6]);
}
}

public ObjectSend(id)
{
new Data[121];
new SendName[32], TempName[32];

read_args(Data, charsmax(Data));
remove_quotes(Data);
get_user_name(id, SendName, 31);
get_user_name(TempID, TempName, 31);

if(str_to_num(Data) < 1) 
	return PLUGIN_HANDLED;

if(Send[id] == 1 && Dollar[id] >= str_to_num(Data))
{
	Dollar[TempID] += str_to_num(Data);
	Dollar[id] -= str_to_num(Data);
	ColorChat(0, GREEN, "%s^3%s ^1Küldött ^4%d Dollár^1-t ^3%s^1-nak", C_Prefix, SendName, str_to_num(Data), TempName);
}
if(Send[id] == 2 && Kulcs[id] >= str_to_num(Data))
{
	Kulcs[TempID] += str_to_num(Data);
	Kulcs[id] -= str_to_num(Data);
	ColorChat(0, GREEN, "%s^3%s ^1Küldött ^4%d Kulcs^1-ot ^3%s^1-nak", C_Prefix, SendName, str_to_num(Data), TempName);
}
if(Send[id] == 3 && SMS[id] >= str_to_num(Data))
{
	SMS[TempID] += str_to_num(Data);
	SMS[id] -= str_to_num(Data);
	ColorChat(0, GREEN, "%s^3%s ^1Küldött ^4%d SMS Pont^1-ot ^3%s^1-nak", C_Prefix, SendName, str_to_num(Data), TempName);
}


if(Send[id] == 4 && Lada[0][id] >= str_to_num(Data))
{
	Lada[0][TempID] += str_to_num(Data);
	Lada[0][id] -= str_to_num(Data);
	ColorChat(0, GREEN, "%s^3%s ^1Küldött ^4%d %s^1-t ^3%s^1-nak", C_Prefix, SendName, str_to_num(Data), l_Nevek[0], TempName);
}
if(Send[id] == 5 && Lada[1][id] >= str_to_num(Data))
{
	Lada[1][TempID] += str_to_num(Data);
	Lada[1][id] -= str_to_num(Data);
	ColorChat(0, GREEN, "%s^3%s ^1Küldött ^4%d %s^1-t ^3%s^1-nak", C_Prefix, SendName, str_to_num(Data), l_Nevek[1], TempName);
}
if(Send[id] == 6 && Lada[2][id] >= str_to_num(Data))
{
	Lada[2][TempID] += str_to_num(Data);
	Lada[2][id] -= str_to_num(Data);
	ColorChat(0, GREEN, "%s^3%s ^1Küldött ^4%d %s^1-t ^3%s^1-nak", C_Prefix, SendName, str_to_num(Data), l_Nevek[2], TempName);
}
if(Send[id] == 7 && Lada[3][id] >= str_to_num(Data))
{
	Lada[3][TempID] += str_to_num(Data);
	Lada[3][id] -= str_to_num(Data);
	ColorChat(0, GREEN, "%s^3%s ^1Küldött ^4%d %s^1-t ^3%s^1-nak", C_Prefix, SendName, str_to_num(Data), l_Nevek[3], TempName);
}
if(Send[id] == 8 && Lada[4][id] >= str_to_num(Data))
{
	Lada[4][TempID] += str_to_num(Data);
	Lada[4][id] -= str_to_num(Data);
	ColorChat(0, GREEN, "%s^3%s ^1Küldött ^4%d %s^1-t ^3%s^1-nak", C_Prefix, SendName, str_to_num(Data), l_Nevek[4], TempName);
}
if(Send[id] == 9 && Lada[5][id] >= str_to_num(Data))
{
	Lada[5][TempID] += str_to_num(Data);
	Lada[5][id] -= str_to_num(Data);
	ColorChat(0, GREEN, "%s^3%s ^1Küldött ^4%d %s^1-t ^3%s^1-nak", C_Prefix, SendName, str_to_num(Data), l_Nevek[5], TempName);
}
if(Send[id] == 10 && Lada[6][id] >= str_to_num(Data))
{
	Lada[6][TempID] += str_to_num(Data);
	Lada[6][id] -= str_to_num(Data);
	ColorChat(0, GREEN, "%s^3%s ^1Küldött ^4%d %s^1-t ^3%s^1-nak", C_Prefix, SendName, str_to_num(Data), l_Nevek[6], TempName);
}


return PLUGIN_HANDLED;
}
showMenu_RegLog(id)
{
	static menu[255];
	new len;
	
	len += formatex(menu[len], charsmax(menu) - len, "\y[*pbT#] \rOnly Dust2 Reg rendszer^n");
	len += formatex(menu[len], charsmax(menu) - len, "\r1. \wFelhasználónév:\y %s^n", g_Felhasznalonev[id]);
	len += formatex(menu[len], charsmax(menu) - len, "\r2. \wJelszó:\y %s^n^n", g_Jelszo[id]);
	
	if(g_RegisztracioVagyBejelentkezes[id] == 1 )
		len += formatex(menu[len], charsmax(menu) - len, "\r3. \yRegisztráció^n^n^n^n^n^n^n^n");
	else
		len += formatex(menu[len], charsmax(menu) - len, "\r3. \yBejelentkezés^n^n^n^n^n^n^n^n");
	
	len += formatex(menu[len], charsmax(menu) - len, "\r0. \wVissza a RegMenübe");
	
	set_pdata_int(id, 205, 0);
	show_menu(id, MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_0, menu, -1, "Reg-Log Menu");
}
public menu_reglog(id, key)
{
	if (!is_user_connected(id) || g_Bejelentkezve[id])
		return PLUGIN_HANDLED;
	
	switch(key)
	{
		case 0:
		{
			client_cmd(id, "messagemode USERNAME");
			showMenu_RegLog(id);
		}
		case 1:
		{
			client_cmd(id, "messagemode UPASSWORD");
			showMenu_RegLog(id);
		}
		case 2: cmdRegisztracioBejelentkezes(id);
		case 9: showMenu_Main(id);
	}
	return PLUGIN_HANDLED;
}
public showMenu_Main(id)
{
	new Text[1337];
	formatex(Text, 125, "\r[*pbT#] \wOnly Dust2 Reg rendszer\y -/\wKijelentkezve");
	new menuLoginCreate = menu_create(Text, "createMenu_Main");
	
	formatex(Text, 125, "\yRegisztráció");
	menu_additem(menuLoginCreate, Text, "1");
	formatex(Text, 125, "\yBejelentkezés");
	menu_additem(menuLoginCreate, Text, "2");
		formatex(Text, 125, "\rElfelejtettem a jelszavam!");
	menu_additem(menuLoginCreate, Text, "3");
	
	
	formatex(Text, charsmax(Text), "BACK");
	menu_setprop(menuLoginCreate, MPROP_BACKNAME, Text);
	formatex(Text, charsmax(Text), "NEXT");
	menu_setprop(menuLoginCreate, MPROP_NEXTNAME, Text);
	formatex(Text, charsmax(Text), "EXIT");
	menu_setprop(menuLoginCreate, MPROP_EXITNAME, Text);
 
	menu_setprop(menuLoginCreate, MPROP_EXIT, MEXIT_ALL);
	menu_display(id, menuLoginCreate,0);
	
	return PLUGIN_HANDLED;
}

public showMenu_Options(id)
{
	new Text[255];
	
	formatex(Text, 99, "\y[*pbT#] \rOnly Dust2\y -/\wBejelentkezve");
	new menuLoginCreate = menu_create(Text, "createMenu_Options");
	
	formatex(Text, 99, "\wE-Mail:\y %s^n", g_Email[id]);
	menu_additem(menuLoginCreate, Text, "1");
	
	if(biztonsagikerdes[id] == 1)
	{
	menu_additem(menuLoginCreate, "\wBiztonsági kérdés:\y Van", "2");
	}
	else if(biztonsagikerdes[id] == 0)
	{
	menu_additem(menuLoginCreate, "\wBiztonsági kérdés:\r Nincs", "2");
	}
	
	formatex(Text, 99, "\wÚj jelszó:\y %s", g_JelszoUj[id]);
	menu_additem(menuLoginCreate, Text, "3");
	
	formatex(Text, 99, "\wJelenlegi jelszó:\y %s", g_JelszoRegi[id]);
	menu_additem(menuLoginCreate, Text, "4");
	
	formatex(Text, 99, "\wJelszó váltás^n");
	menu_additem(menuLoginCreate, Text, "5");
		
	menu_setprop(menuLoginCreate, MPROP_EXIT, MEXIT_ALL);
	menu_setprop(menuLoginCreate, MPROP_BACKNAME, "BACK");
	menu_setprop(menuLoginCreate, MPROP_NEXTNAME, "NEXT");
	menu_setprop(menuLoginCreate, MPROP_EXITNAME, "EXIT");
	menu_setprop(menuLoginCreate, MPROP_PERPAGE, 7);
	
	menu_display(id, menuLoginCreate, 0);
	
	return PLUGIN_HANDLED;
}
public sql_update_account(id)
{	
	static Query[10048];
	new len = 0;
	
	new b[191], c[191];
	new client_name[33];
	new steamid[32],player_ip[23];
	get_user_ip(id, player_ip, 22,1);
	get_user_authid(id, steamid, charsmax(steamid));
	get_user_name(id, client_name, 32);
	
	format(b, 190, "%s", g_Jelszo[id]);
	format(c, 190, "%s", client_name);

	replace_all(b, 190, "\", "\\");
	replace_all(b, 190, "'", "\'");
	replace_all(c, 190, "\", "\\");
	replace_all(c, 190, "'", "\'"); 

	len += format(Query[len], 10048, "UPDATE rwt_sql_register_new_s5 SET ");
	len += format(Query[len], 10048-len,"Jelszo = '%s', ", b)               ;
	len += format(Query[len], 10048-len,"Jatekosnev = '%s', ", c);
	len += format(Query[len], 10048-len,"Email = '%s', ", g_Email[id]);
	len += format(Query[len], 10048-len,"BiztKerdes = '%s', ", s_biztonsagikerdes[id]);
	len += format(Query[len], 10048-len,"BiztValasz = '%s', ", s_valasz[id]);
	len += format(Query[len], 10048-len,"Kulcs = '%d', ", Kulcs[id]);
	len += format(Query[len], 10048-len,"Szint = '%d', ", Rang[id]);
	len += format(Query[len], 10048-len,"AutoLogin = '%d', ", AutoLogin);
	len += format(Query[len], 10048-len,"Dollars = '%d', ", floatround(Dollar[id]*100));
	len += format(Query[len], 10048-len,"SMS = '%d', ", SMS[id]);
	len += format(Query[len], 10048-len,"Hud = '%d', ", Hud[id]);
	len += format(Query[len], 10048-len,"Vip = '%d', ", Vip[id]);
	len += format(Query[len], 10048-len,"Masodpercek = '%d', ", Masodpercek[id]+get_user_time(id));
	len += format(Query[len], 10048-len,"DropOles = '%d', ", D_Oles[id]);
	len += format(Query[len], 10048-len,"Oles = '%d', ", Oles[id]);
	len += format(Query[len], 10048-len,"biztonsagikerdes = '%d', ", biztonsagikerdes[id]);
	len += format(Query[len], 10048-len,"kivak = '%d', ", kivalasztott[id][AK47]);
	len += format(Query[len], 10048-len,"kivm4 = '%d', ", kivalasztott[id][M4A1]);
	len += format(Query[len], 10048-len,"kivawp = '%d', ", kivalasztott[id][AWP]);
	len += format(Query[len], 10048-len,"kivfamas = '%d', ", kivalasztott[id][FAMAS]);
	len += format(Query[len], 10048-len,"kivmp5 = '%d', ", kivalasztott[id][MP5NAVY]);
	len += format(Query[len], 10048-len,"kivgalil = '%d', ", kivalasztott[id][GALIL]);
	len += format(Query[len], 10048-len,"kivscout = '%d', ", kivalasztott[id][SCOUT]);
	len += format(Query[len], 10048-len,"kivdeagle = '%d', ", kivalasztott[id][DEAGLE]);
	len += format(Query[len], 10048-len,"kivusp = '%d', ", kivalasztott[id][USP]);
	len += format(Query[len], 10048-len,"kivglock = '%d', ", kivalasztott[id][GLOCK18]);
	len += format(Query[len], 10048-len,"kivknife = '%d', ", kivalasztott[id][KNIFE]);
	len += format(Query[len], 10048-len,"s_addvariable = '%d', ", s_addvariable[id]);
	len += format(Query[len], 10048-len,"porgetesido = '%d', ", g_iTime[id]);
	len += format(Query[len], 10048-len,"viptime = '%d', ", g_iVipTime[id]);
	if(Vip[id] == 1)
	{
	len += format(Query[len], 10048-len,"voltvip = '%d', ", g_iVipNum[id]);
	}
	len += format(Query[len], 10048-len,"steamid = '%s', ", steamid);
	len += format(Query[len], 10048-len,"ipcim = '%s', ", player_ip);
	len += format(Query[len], 10048-len,"h_lada = '%d', ", h_lada[id]);
	len += format(Query[len], 10048-len,"ajandekcsomag = '%d', ", ajandekcsomag[id]);
	len += format(Query[len], 10048-len,"vipkupon = '%d', ", vipkupon[id]);
	len += format(Query[len], 10048-len,"havazas = '%d', ", havazas);

	for(new i=0; i <=11;i++)
	{
	len += formatex(Query[len], charsmax(Query)-len,"Gun%d = ^"%i^", ", i, Gun[i][id]);
	}
		
	for(new i;i <= 120; i++)
	{
		
		len += formatex(Query[len], charsmax(Query)-len, "F%d = ^"%i^", ", i, meglevoek[i][id]);
	}
	for(new i=132; i <= 133; i++)
	{
		len += formatex(Query[len], charsmax(Query)-len, "kulonkes%d = ^"%i^", ", i, meglevoek[i][id]);
	}
	
	for(new i=0; i < LADA; i++)
	{
		len += formatex(Query[len], charsmax(Query)-len, "L%d = ^"%i^", ", i, Lada[i][id]);
	}
	
	
	len += format(Query[len], 10048-len,"Aktivitas = '%d' ", g_Aktivitas[id]);
	len += format(Query[len], 10048-len,"WHERE Id = '%d'", g_Id[id]);

	SQL_ThreadQuery(g_SqlTuple,"sql_update_account_thread", Query);
}

public createMenu_Options(id, menuLoginCreate, item)
{		
	new data[6], iName[64], access, callback;
	menu_item_getinfo(menuLoginCreate, item, access, data, 5, iName, 63, callback);
	
	new key = str_to_num(data);
	
	if(!g_Bejelentkezve[id])
		return PLUGIN_HANDLED;
	
	switch(key)
	{
		case 1:
		{
			client_cmd(id, "messagemode E-mail");
			showMenu_Options(id);
		}
				case 2:
		{
			if(biztonsagikerdes[id] == 1)
			{
			ColorChat(id,BLUE,"%s ^3Neked van biztonsági kérdésed!",C_Prefix);
			}
			else if(biztonsagikerdes[id] == 0)
			{
			client_cmd(id, "messagemode BIZTONSAGIKERDES");
			}
		}
		case 3:
		{
			client_cmd(id, "messagemode NEWPASSWORD");
			showMenu_Options(id);
		}
		case 4:
		{
			client_cmd(id, "messagemode CURRENTPASSWORD");
			showMenu_Options(id);
		}
		case 5:
		{
			if(g_JelszoRegi[id][0] != EOS)
			{
				if(equal(g_JelszoRegi[id], g_Jelszo[id]))
				{	
					if(g_JelszoUj[id][0] != EOS)
					{
						if((strlen(g_JelszoUj[id]) > 16))
						{
							ColorChat(id,GREY, "^1 Az új jelszó nem lehet hosszabb, mint 16 karakter.");
							g_JelszoUj[id][0] = EOS;
							showMenu_Options(id);
							return PLUGIN_HANDLED;
						}
						
						if((strlen(g_JelszoUj[id]) < 4))
						{
							ColorChat(id,GREY, "^1 Az új Jelszó nem lehet rovidebb, mint 4 karakter.");
							g_JelszoUj[id][0] = EOS;
							showMenu_Options(id);
							return PLUGIN_HANDLED;
						}
					
						g_Jelszo[id] = g_JelszoUj[id];
						
						new b[191];
	
						format(b, charsmax(b), "%s", g_Jelszo[id]);
					
						replace_all(b, charsmax(b), "\", "\\");
						replace_all(b, charsmax(b), "'", "\'");
						
						ColorChat(id,GREY, "^1 Sikeres jelszó váltás! Új Jelszavad:^3 %s", g_Jelszo[id]);
						
						sql_update_account(id);
						
						g_JelszoUj[id][0] = EOS;
						g_JelszoRegi[id][0] = EOS;
					}
					else
					{
						ColorChat(id,GREY, "^1 Nem adtál meg új jelszót.");
						showMenu_Options(id);
					}
				}
				else
				{
					ColorChat(id,GREY, "Hibás jelenlegi jelszó.");
					showMenu_Options(id);
				}
			}
			else
			{
				ColorChat(id,GREY, "^1 Nem adtad meg a jelenlegi jelszót");
				showMenu_Options(id);
			}
		}
	}
	return PLUGIN_HANDLED;
}

public createMenu_Main(id, menuLoginCreate, item)
{		
	new data[6], iName[64], access, callback;
	menu_item_getinfo(menuLoginCreate, item, access, data, 5, iName, 63, callback);
	
	new key = str_to_num(data);
	switch(key)
	{
		case 1:
		{
			
			if(!g_Bejelentkezve[id])
			{
				g_RegisztracioVagyBejelentkezes[id] = 1;
				showMenu_RegLog(id);
			}
			else
			{	
				ColorChat(id,GREY, "Már be vagy jelentkezve.");
				showMenu_Main(id);
			}
		}
		case 2:
		{
			if(!g_Bejelentkezve[id])
			{
				g_RegisztracioVagyBejelentkezes[id] = 2;
				showMenu_RegLog(id);
			}
			else
			{	
				ColorChat(id,GREY, "Már be vagy jelentkezve.");
				showMenu_Main(id);
			}
		}
		case 3:
		{
		ColorChat(id,BLUE,"%s ^3Add meg a felhasználóneved!",C_Prefix);
		client_cmd(id, "messagemode USERNAME2");
		}
	}
	return PLUGIN_HANDLED;
}

public cmdFelhasznalonev(id)
{
	if(g_Bejelentkezve[id])
		return PLUGIN_HANDLED;
	
	g_Felhasznalonev[id][0] = EOS;
	read_args(g_Felhasznalonev[id], 99);
	remove_quotes(g_Felhasznalonev[id]);
	
	showMenu_RegLog(id);
	return PLUGIN_HANDLED;
}
public cmdFelhasznalonev2(id)
{
	if(g_Bejelentkezve[id])
		return PLUGIN_HANDLED;
	
	g_Felhasznalonev[id][0] = EOS;
	read_args(g_Felhasznalonev[id], 99);
	remove_quotes(g_Felhasznalonev[id]);
	
	usernamecheckforquestion(id);
	
	return PLUGIN_HANDLED;
}
public cmdFelhasznalonev3(id)
{
	if(!g_Bejelentkezve[id])
		return PLUGIN_HANDLED;
	
	g_FHVIP[id][0] = EOS;
	read_args(g_FHVIP[id], 99);
	remove_quotes(g_FHVIP[id]);
	
	if(viptorol == 1)
	sql_delete_vip(id);
	else
	sql_update_vip(id);
	
	return PLUGIN_HANDLED;
}
public helperjovair(id)
{
if(get_user_flags(id) & ADMIN_CVAR)
{
addolasikulcs = 911;
PlayerChoose2(id);
}
else
{
ColorChat(id,RED,"%s ^3Számodra ez a funkció nem elérhető!",C_Prefix);
}
}
public helpertorol(id)
{
if(get_user_flags(id) & ADMIN_CVAR)
{
addolasikulcs = 913;
PlayerChoose2(id);
}
else
{
ColorChat(id,RED,"%s ^3Számodra ez a funkció nem elérhető!",C_Prefix);
}
}
public helperkick(id)
{
if(get_user_flags(id) & ADMIN_CHAT)
{
addolasikulcs = 912;
PlayerChoose2(id);
}
}
public cmdsinfok(id)
{
if(get_user_flags(id) & ADMIN_CHAT)
{
show_motd(id, "addons/amxmodx/configs/sinfok.txt", "Szabályzat");
}
}

public cmdPauseAccount(id)
{
	if(!g_Bejelentkezve[id])
		return PLUGIN_HANDLED;
	
	g_Indok[id][0] = EOS;
	read_args(g_Indok[id], 99);
	remove_quotes(g_Indok[id]);
	
	sqlfelfuggesztfiok(id);
	
	return PLUGIN_HANDLED;
}
public usernamecheckforquestion(id)
{
new szQuery[2048];
	new len = 0;
	
	new a[191];
	
	format(a, 190, "%s", g_Felhasznalonev[id]);

	replace_all(a, 190, "\", "\\");
	replace_all(a, 190, "'", "\'");
	
	len += format(szQuery[len], 2048, "SELECT * FROM rwt_sql_register_new_s5 ");
	len += format(szQuery[len], 2048-len,"WHERE Felhasznalonev = '%s'", a);
	
	new szData[2];
	szData[0] = id;
	szData[1] = get_user_userid(id);

	SQL_ThreadQuery(g_SqlTuple,"sql_biztonsagikerdes_check", szQuery, szData, 2);
}
public sql_biztonsagikerdes_check(FailState,Handle:Query,Error[],Errcode,szData[],DataSize)
{
	if(FailState == TQUERY_CONNECT_FAILED)
	{
		set_fail_state("[ *HIBA* ] NEM LEHET KAPCSOLODNI AZ ADATBAZISHOZ!");
		return;
	}
	else if(FailState == TQUERY_QUERY_FAILED)
	{
		set_fail_state("[ *HIBA* ] A LEKERDEZES MEGSZAKADT!");
		return;
	}
	
	if(Errcode)
	{
		log_amx("[ *HIBA* ] PROBLEMA A LEKERDEZESNEL! ( %s )",Error);
		return;
	}
	
	new id = szData[0];
	
	if (szData[1] != get_user_userid(id))
		return;
	
	//new iRowsFound = SQL_NumRows(Query);
	
	sql_account_loadonlyquestion(id);

}
public sql_account_loadonlyquestion(id)
{
static Query[10048];
	new len = 0;
	
	new a[191];
	
	format(a, 190, "%s", g_Felhasznalonev[id]);

	replace_all(a, 190, "\", "\\");
	replace_all(a, 190, "'", "\'");
	
	len += format(Query[len], 10048, "SELECT * FROM rwt_sql_register_new_s5 ");
	len += format(Query[len], 10048-len,"WHERE Felhasznalonev = '%s'", a);
	
	new szData[2];
	szData[0] = id;
	szData[1] = get_user_userid(id);

	SQL_ThreadQuery(g_SqlTuple,"sql_account_load_onlyquestion", Query, szData, 2);
}
public sql_account_load_onlyquestion(FailState,Handle:Query,Error[],Errcode,szData[],DataSize)
{
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED)
	{
		log_amx("%s", Error);
		return;
	}
	else
	{
		new id = szData[0];
		
		if (szData[1] != get_user_userid(id))
			return ;
		
		
			SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "BiztKerdes"), s_biztonsagikerdes[id], charsmax(s_biztonsagikerdes[]));
			SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "BiztValasz"), s_valasz[id], charsmax(s_valasz[]));
			SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Jelszo"), s_temporarypass[id], charsmax(s_temporarypass[]));
			
			ColorChat(id,BLUE,"%s ^3%s",C_Prefix, s_biztonsagikerdes[id]);
			ColorChat(id,BLUE,"%s ^3%s",C_Prefix, s_biztonsagikerdes[id]);
			ColorChat(id,BLUE,"%s ^3Írd be! A radarnál látod mit írsz!",C_Prefix);
			client_cmd(id, "messagemode VALASZ");
	}
}
public valasz2(id)
{
	read_args(s_valaszirt[id], 99);
	remove_quotes(s_valaszirt[id]);
	
	if(equal(s_valaszirt[id],s_valasz[id]))
	{
	g_Jelszo[id] = s_temporarypass[id];
	ColorChat(id,BLUE,"%s ^3A jelenlegi jelszód:^4 %s ^3Beírtuk a bejelentkezés paneledre!",C_Prefix,s_temporarypass[id]);
	}
	else
	{
	ColorChat(id,RED,"%s ^3Rossz a válaszod!",C_Prefix);
	}
}
				
			

public cmdEmail(id)
{
	if(!g_Bejelentkezve[id])
		return PLUGIN_HANDLED;
	
	g_Email[id][0] = EOS;
	read_args(g_Email[id], 99);
	remove_quotes(g_Email[id]);
	
	if(contain(g_Email[id], ".hu") != -1
	|| contain(g_Email[id], ".com") != -1
	|| contain(g_Email[id], ".ro") != -1 
	|| contain(g_Email[id], ".cz") != -1 
	|| contain(g_Email[id], ".pl") != -1 
	|| contain(g_Email[id], ".eu") != -1 
	|| contain(g_Email[id], ".lt") != -1)
	{
		if(contain(g_Email[id], "@") != -1)
		{
			new const VP[] = "\";
			new const AP[] = "'";
			
			if(contain(g_Email[id], VP) != -1
			|| contain(g_Email[id], AP) != -1)
			{
				ColorChat(id,GREY, "^1 Az E-Mail cim nem megfelelő formában van.");
				g_Email[id][0] = EOS;
			}
			else
				showMenu_Options(id);
		}
		else
		{
			ColorChat(id,GREY, "^1 Az E-Mail cim nem megfelelő formában van.");
			g_Email[id][0] = EOS;
		}
		
	}
	else
	{
		ColorChat(id,GREY, "^1 Az E-Mail cim nem megfelelő formában van.");
		g_Email[id][0] = EOS;
	}
	
	showMenu_Options(id);
	return PLUGIN_HANDLED;
}

public cmdJelszoUj(id)
{
	if(!g_Bejelentkezve[id])
		return PLUGIN_HANDLED;
	
	g_JelszoUj[id][0] = EOS;
	read_args(g_JelszoUj[id], 99);
	remove_quotes(g_JelszoUj[id]);
	
	showMenu_Options(id);
	return PLUGIN_HANDLED;
}

public cmdskickIndok(id)
{
if(get_user_flags(id) & ADMIN_CHAT)
{

	g_Indok[id][0] = EOS;
	read_args(g_Indok[id], 99);
	remove_quotes(g_Indok[id]);
	
	new uID = get_user_userid(TempID);
	new sz_sname[33],sz_victimname[33];
	get_user_name(id, sz_sname, charsmax(sz_sname));
	get_user_name(TempID, sz_victimname, charsmax(sz_victimname));
	server_cmd("banid 1 #%d", uID);
	client_cmd(TempID, "echo ^"[*pbT#] Ki lettél rúgva! Indok: %s Segítő: %s^"; disconnect", g_Indok[id],sz_sname);
	ColorChat(0, RED, "%s %s ^1Ki lett rúgva!^3 ||^1Indok:^4 %s ^3||^1Segítő:^4 %s", C_Prefix,sz_victimname,g_Indok[id],sz_sname);
}
	return PLUGIN_HANDLED;
}
public cmdJelszoRegi(id)
{
	if(!g_Bejelentkezve[id])
		return PLUGIN_HANDLED;
	
	g_JelszoRegi[id][0] = EOS;
	read_args(g_JelszoRegi[id], 99);
	remove_quotes(g_JelszoRegi[id]);
	
	showMenu_Options(id);
	return PLUGIN_HANDLED;
}

public cmdJelszo(id)
{
	if(g_Bejelentkezve[id] == true)
		return PLUGIN_HANDLED;
	
	g_Jelszo[id][0] = EOS;
	read_args(g_Jelszo[id], 99);
	remove_quotes(g_Jelszo[id]);
	
	showMenu_RegLog(id);
	return PLUGIN_HANDLED;
}
public biztonsagikerdes_mess(id)
{
		if(!g_Bejelentkezve[id])
		return PLUGIN_HANDLED;
		
		s_biztonsagikerdes[id][0] = EOS;
		read_args(s_biztonsagikerdes[id], 99);
		remove_quotes(s_biztonsagikerdes[id]);

	client_cmd(id, "messagemode VALASZ_A_KERDESRE");
	ColorChat(id,BLUE,"%s ^3Írd meg rá a választ!",C_Prefix);
	
return PLUGIN_HANDLED;
}
public valasz_megadas(id)
{
	if(!g_Bejelentkezve[id])
		return PLUGIN_HANDLED;
		
		s_valasz[id][0] = EOS;
		read_args(s_valasz[id], 99);
		remove_quotes(s_valasz[id]);
		
		
	ColorChat(id,BLUE,"%s ^3Sikeres művelet!",C_Prefix);
	biztonsagikerdes[id] = 1;

return PLUGIN_HANDLED;	
}
public cmdRegisztracioBejelentkezes(id)
{
	if(g_Bejelentkezve[id] == true)
		return PLUGIN_HANDLED;
	
	if((strlen(g_Jelszo[id]) > 16))
	{
		ColorChat(id,GREY, "^1 A Jelszó nem lehet hosszabb, mint 16 karakter.");
		g_Jelszo[id][0] = EOS;
		showMenu_RegLog(id);
		return PLUGIN_HANDLED;
	}
	
	if((strlen(g_Jelszo[id]) < 4))
	{
		ColorChat(id,GREY, "A Jelszó nem lehet rovidebb, mint 4 karakter.");
		g_Jelszo[id][0] = EOS;
		showMenu_RegLog(id);
		return PLUGIN_HANDLED;
	}
	
	switch(g_RegisztracioVagyBejelentkezes[id])
	{
		case 1:
		{
			if(g_Folyamatban[id] == 0)
			{
				ColorChat(id,GREY, "^1 Regisztráció folyamatban...");
				sql_account_check(id);
				showMenu_RegLog(id);
				g_Folyamatban[id] = 1;
			}
			else  showMenu_RegLog(id);
		}
		case 2:
		{
			if(g_Folyamatban[id] == 0)
			{
				ColorChat(id,GREY, "^1 Bejelentkezés folyamatban...");
				sql_account_check(id);
				showMenu_RegLog(id);
				g_Folyamatban[id] = 1;
			}
			else  showMenu_RegLog(id);
		}
	}
	
	return PLUGIN_CONTINUE;
}
public sql_tuple_create() 
{
	g_SqlTuple = SQL_MakeDbTuple(s_HOSZT, s_FELHASZNALO, s_JELSZO, s_ADATBAZIS);
	sql_active_check();
	//sql_load_server()
}
public sql_table_create_thread(FailState,Handle:Query,Error[],Errcode,Data[],DataSize)
{
	if(FailState == TQUERY_CONNECT_FAILED)
		return set_fail_state("[ *HIBA* ] NEM LEHET KAPCSOLODNI AZ ADATBAZISHOZ!");
	else if(FailState == TQUERY_QUERY_FAILED)
		return set_fail_state("[ *HIBA* ] A LEKERDEZES MEGSZAKADT!");
	
	if(Errcode)
		return log_amx("[ *HIBA* ] PROBLEMA A LEKERDEZESNEL! ( %s )",Error);
	
	return PLUGIN_CONTINUE;
}
public sql_active_check()
{
	new szQuery[2048];
	new len = 0;
	
	len += format(szQuery[len], 2048, "UPDATE rwt_sql_register_new_s5 SET ");
	len += format(szQuery[len], 2048-len,"Aktivitas = '0' ");
	len += format(szQuery[len], 2048-len,"WHERE Aktivitas = '%d'", SERVER_ID);
	
	SQL_ThreadQuery(g_SqlTuple,"sql_active_check_thread", szQuery);
}
public sql_active_check_thread(FailState,Handle:Query,Error[],Errcode,Data[],DataSize)
{
	if(FailState == TQUERY_CONNECT_FAILED)
		return set_fail_state("[ *HIBA* ] NEM LEHET KAPCSOLODNI AZ ADATBAZISHOZ!");
	else if(FailState == TQUERY_QUERY_FAILED)
		return set_fail_state("[ *HIBA* ] A LEKERDEZES MEGSZAKADT!");
	
	if(Errcode)
		return log_amx("[ *HIBA* ] PROBLEMA A LEKERDEZESNEL! ( %s )",Error);
	
	return PLUGIN_CONTINUE;
}
public sql_account_check(id)
{
	new szQuery[2048];
	new len = 0;
	
	new a[191];
	
	format(a, 190, "%s", g_Felhasznalonev[id]);

	replace_all(a, 190, "\", "\\");
	replace_all(a, 190, "'", "\'");
	
	len += format(szQuery[len], 2048, "SELECT * FROM rwt_sql_register_new_s5 ");
	len += format(szQuery[len], 2048-len,"WHERE Felhasznalonev = '%s'", a);
	
	new szData[2];
	szData[0] = id;
	szData[1] = get_user_userid(id);

	SQL_ThreadQuery(g_SqlTuple,"sql_account_check_thread", szQuery, szData, 2);
}
public sql_account_check_thread(FailState,Handle:Query,Error[],Errcode,szData[],DataSize)
{
	if(FailState == TQUERY_CONNECT_FAILED)
	{
		set_fail_state("[ *HIBA* ] NEM LEHET KAPCSOLODNI AZ ADATBAZISHOZ!");
		return;
	}
	else if(FailState == TQUERY_QUERY_FAILED)
	{
		set_fail_state("[ *HIBA* ] A LEKERDEZES MEGSZAKADT!");
		return;
	}
	
	if(Errcode)
	{
		log_amx("[ *HIBA* ] PROBLEMA A LEKERDEZESNEL! ( %s )",Error);
		return;
	}
	
	new id = szData[0];
	
	if (szData[1] != get_user_userid(id))
		return;
	
	new iRowsFound = SQL_NumRows(Query);
	
	if(g_RegisztracioVagyBejelentkezes[id] == 1)
	{	
		if(iRowsFound > 0)
		{
			ColorChat(id,GREY, "^1 Ez a Felhasználónév már Regisztrálva van.");
			g_Folyamatban[id] = 0;
			showMenu_RegLog(id);
		}
		else sql_account_create(id);
	}
	else if(g_RegisztracioVagyBejelentkezes[id] == 2)
	{
			
		if(iRowsFound == 0)
		{
			ColorChat(id,GREY, "^1 Hibás felhasználónév vagy jelszó!");
			g_Folyamatban[id] = 0;
			showMenu_RegLog(id);
		}
		else sql_account_checkpause(id);
		//else sql_account_load(id);
	}
}
public sql_account_checkpause(id)
{
new szQuery[2048];
	new len = 0;
	
	new a[191];
	
	format(a, 190, "%s", g_Felhasznalonev[id]);

	replace_all(a, 190, "\", "\\");
	replace_all(a, 190, "'", "\'");
	
	len += format(szQuery[len], 2048, "SELECT AccountPauseReason,AccountPauseAdmin FROM rwt_sql_register_new_s5 ");
	len += format(szQuery[len], 2048-len,"WHERE Felhasznalonev = '%s' AND AccountPause = '1'", a);
	
	new szData[2];
	szData[0] = id;
	szData[1] = get_user_userid(id);

	SQL_ThreadQuery(g_SqlTuple,"sql_account_checkpause_thread", szQuery, szData, 2);
}
public sql_account_checkpause_thread(FailState,Handle:Query,Error[],Errcode,szData[],DataSize)
{
	if(FailState == TQUERY_CONNECT_FAILED)
	{
		set_fail_state("[ *HIBA* ] NEM LEHET KAPCSOLODNI AZ ADATBAZISHOZ!");
		return;
	}
	else if(FailState == TQUERY_QUERY_FAILED)
	{
		set_fail_state("[ *HIBA* ] A LEKERDEZES MEGSZAKADT!");
		return;
	}
	
	if(Errcode)
	{
		log_amx("[ *HIBA* ] PROBLEMA A LEKERDEZESNEL! ( %s )",Error);
		return;
	}
	
	new id = szData[0];
	
	if (szData[1] != get_user_userid(id))
		return;
	
	new iRowsFound = SQL_NumRows(Query);
	
	if(iRowsFound > 0)
	{
	SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "AccountPauseReason"), g_Indok[id], charsmax(g_Indok[]));
	SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "AccountPauseAdmin"), adminname[id], charsmax(adminname[]));
	ColorChat(id,RED,"%s ^3Ez a fiók fel lett függesztve!^1 ||^3Indok:^4 %s ^1||^3Admin:^4 %s",C_Prefix,g_Indok[id],adminname[id]);
	}
	else sql_account_load(id);

}

public sql_account_create(id)
{
	new szQuery[2048];
	new len = 0;
	
	new a[191], b[191];
	
	format(a, 190, "%s", g_Felhasznalonev[id]);
	format(b, 190, "%s", g_Jelszo[id]);

	replace_all(a, 190, "\", "\\");
	replace_all(a, 190, "'", "\'");
	replace_all(b, 190, "\", "\\");
	replace_all(b, 190, "'", "\'");
	 
	len += format(szQuery[len], 2048, "INSERT INTO rwt_sql_register_new_s5 ");
	len += format(szQuery[len], 2048-len,"(Felhasznalonev,Jelszo,kivak,kivm4,kivawp,kivfamas,kivmp5,kivgalil,kivscout,kivdeagle,kivusp,kivglock,kivknife,Gun0,Gun1,Gun2,Gun3,Gun4,Gun5,Gun6,Gun7,Gun8,Gun9,Gun10,Gun11,Hud,ult_hang) VALUES('%s','%s','121','122','123','124','125','126','127','128','129','130','131','1','1','1','1','1','1','1','1','1','1','1','1','1','1')", a, b);
	
	new szData[2];
	szData[0] = id;
	szData[1] = get_user_userid(id);

	SQL_ThreadQuery(g_SqlTuple,"sql_account_create_thread", szQuery, szData, 2);
}

public sql_account_create_thread(FailState,Handle:Query,Error[],Errcode,szData[],DataSize)
{
	if(FailState == TQUERY_CONNECT_FAILED)
	{
		set_fail_state("[ *HIBA* ] NEM LEHET KAPCSOLODNI AZ ADATBAZISHOZ!");
		return;
	}
	else if(FailState == TQUERY_QUERY_FAILED)
	{
		set_fail_state("[ *HIBA* ] A LEKERDEZES MEGSZAKADT!");
		return; 
	}
	
	if(Errcode)
	{
		log_amx("[ *HIBA* ] PROBLEMA A LEKERDEZESNEL! ( %s )",Error);
		return; 
	}
		
	new id = szData[0];
	
	if (szData[1] != get_user_userid(id))
		return;
	
	ColorChat(id,GREY, "^1 Sikeres regisztráció, lépj be!");
	ColorChat(id,GREY, "^1 Felhasználóneved:^3 %s^1 | Jelszavad:^3 %s", g_Felhasznalonev[id], g_Jelszo[id]);
	g_Folyamatban[id] = 0;
	g_RegisztracioVagyBejelentkezes[id] = 2;
	showMenu_RegLog(id);
	
	return;
}
public sql_account_load(id)
{
	//new szQuery[10048]
	static Query[10048];
	new len = 0;
	
	new a[191];
	
	format(a, 190, "%s", g_Felhasznalonev[id]);

	replace_all(a, 190, "\", "\\");
	replace_all(a, 190, "'", "\'");
	
	len += format(Query[len], 10048, "SELECT * FROM rwt_sql_register_new_s5 ");
	len += format(Query[len], 10048-len,"WHERE Felhasznalonev = '%s'", a);
	
	new szData[2];
	szData[0] = id;
	szData[1] = get_user_userid(id);

	SQL_ThreadQuery(g_SqlTuple,"sql_account_load_thread", Query, szData, 2);
}

public sql_account_load_thread(FailState,Handle:Query,Error[],Errcode,szData[],DataSize)
{
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED)
	{
		log_amx("%s", Error);
		return;
	}
	else
	{
		new id = szData[0];
		
		if (szData[1] != get_user_userid(id))
			return ;
		
		new szSqlPassword[100];
		SQL_ReadResult(Query, 2, szSqlPassword, 99);
		
		if(equal(g_Jelszo[id], szSqlPassword))
		{
			g_Aktivitas[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Aktivitas"));
					
			if (g_Aktivitas[id] > 0)
			{
				ColorChat(id,GREY, "^1 Ezzel a Felhasználónével már valaki bejelentkezett!");
				showMenu_RegLog(id);
				return;
			}
				
			
			
			SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Email"), g_Email[id], charsmax(g_Email[]));
			SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "BiztKerdes"), s_biztonsagikerdes[id], charsmax(s_biztonsagikerdes[]));
			SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "BiztValasz"), s_valasz[id], charsmax(s_valasz[]));
			Rang[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Szint"));
			Dollar[id] = float(SQL_ReadResult(Query, 13))/100;
			SMS[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "SMS"));
			Oles[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Oles"));
			AutoLogin = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "AutoLogin"));
			biztonsagikerdes[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "biztonsagikerdes"));
			D_Oles[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "DropOles"));
			Vip[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Vip"));
			Kulcs[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Kulcs"));
			Hud[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Hud"));
			
			Masodpercek[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Masodpercek"));
			g_iTime[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "porgetesido"));
			g_iVipTime[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "viptime"));
			g_iVipNum[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "voltvip"));
			h_lada[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "h_lada"));
			ajandekcsomag[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "ajandekcsomag"));
			vipkupon[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "vipkupon"));
			havazas = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "havazas"));
			client_cmd(id, "cl_weather %d", havazas);
			
			g_Id[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Id"));
			
			for(new i=0;i<= 11;i++)
			{
				new String[64];
				formatex(String, charsmax(String), "Gun%d", i);
				Gun[i][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, String));
			}
			for(new i=0;i <= 120; i++)
			{
				new String[64];
				formatex(String, charsmax(String), "F%d", i);
				meglevoek[i][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, String));
			}
			for(new i=132;i <= 133; i++)
			{
				new String[64];
				formatex(String, charsmax(String), "kulonkes%d", i);
				meglevoek[i][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, String));
			}
			for(new i;i < LADA; i++)
			{
				new String[64];
				formatex(String, charsmax(String), "L%d", i);
				Lada[i][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, String));
			}
			
				kivalasztott[id][AK47]   = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "kivak"));
				kivalasztott[id][M4A1]   = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "kivm4"));
				kivalasztott[id][AWP]   = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "kivawp"));
				kivalasztott[id][FAMAS] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "kivfamas"));
				kivalasztott[id][MP5NAVY]   = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "kivmp5"));
				kivalasztott[id][GALIL] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "kivgalil"));
				kivalasztott[id][SCOUT] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "kivscout"));
				kivalasztott[id][DEAGLE] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "kivdeagle"));
				kivalasztott[id][USP]     = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "kivusp"));
				kivalasztott[id][GLOCK18] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "kivglock"));
				kivalasztott[id][KNIFE] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "kivknife"));
				new fast_cache[33];
				fast_cache[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "ult_hang"));
				set_user_ajandekcsomag(id,fast_cache[id]);
				
			
			g_Aktivitas[id] = SERVER_ID;
			
			//acces_creater(id)
			s_addvariable[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "s_addvariable"));
			
			if(s_addvariable[id] >= 1)
			{
			set_user_flags(id, get_user_flags(id) | ADMIN_CHAT);
			}
			
			static iTime;
			iTime = g_iVipTime[id] - get_systime( );
			if(iTime <= 0 && g_iVipTime[id] > 0)
			{
			Vip[id] = 0;
			g_iVipNum[id] = 1;
			}
			
			sql_update_account(id);
			
			ColorChat(id,GREY, "^1 Üdv^3 %s^1, Sikeresen Bejelentkeztél.", g_Felhasznalonev[id]);
			
			g_Folyamatban[id] = 0;
			g_Bejelentkezve[id] = true;
			native_get_user_accountid(id);
			//AdminBelepes(id)
			Fomenu(id);
		}
		else
		{
			ColorChat(id,GREY, "Hibás Felhasználónév vagy Jelszó.");
			g_Folyamatban[id] = 0;
			showMenu_RegLog(id);
		}
	}
}
/*
public sql_load_server()
{
	new szQuery[2048];
	new len = 0;
	
	len += format(szQuery[len], 2048, "SELECT * FROM rwt_sql_register_new_s5_s ");
	len += format(szQuery[len], 2048-len,"WHERE Server = '%d'", SERVER_ID);
	
	SQL_ThreadQuery(g_SqlTuple,"sql_load_server_thread", szQuery);
}

public sql_load_server_thread(FailState,Handle:Query,Error[],Errcode,szData[],DataSize)
{
	if(FailState == TQUERY_CONNECT_FAILED)
		return set_fail_state("[ *HIBA* ] NEM LEHET KAPCSOLODNI AZ ADATBAZISHOZ!");
	else if(FailState == TQUERY_QUERY_FAILED)
		return set_fail_state("[ *HIBA* ] A LEKERDEZES MEGSZAKADT!");
	
	if(Errcode)
		return log_amx("[ *HIBA* ] PROBLEMA A LEKERDEZESNEL! ( %s )",Error);
	
	for(new i=0; i <= 19; i++)
	{
	new String[64];
	formatex(String, charsmax(String), "Kes%d", i);
		OsszesKes[i] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, String));
	}
	
	for(new i=0; i <= 135; i++)
	{
	new String[256];
	formatex(String, charsmax(String), "Wpn%d", i);
		OsszesFegyver[i] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, String));
	}
		
	return PLUGIN_CONTINUE;
}



public sql_update_server()
{
	new szQuery[2548]
	new len = 0
	
	len += format(szQuery[len], 2548, "UPDATE rwt_sql_register_new_s5_s SET ")

	for(new i=0; i <= 19; i++)
	{
		len += format(szQuery[len], 2548-len,"Kes%d = '%d', ", i, OsszesKes[i])
	}
	
	for(new i=0; i <= 134; i++)
	{
		len += format(szQuery[len], 2548-len,"Wpn%d = '%d', ", i, OsszesFegyver[i])
	}
	
	len += format(szQuery[len], 2548-len,"Wpn135 = '%d' ", OsszesFegyver[135])
	len += format(szQuery[len], 2548-len,"WHERE Server = '%d'", SERVER_ID)

	SQL_ThreadQuery(g_SqlTuple,"sql_update_servere_thread", szQuery)
}


public sql_update_servere_thread(FailState,Handle:Query,Error[],Errcode,Data[],DataSize)
{
	if(FailState == TQUERY_CONNECT_FAILED)
		return set_fail_state("[ *HIBA* ] NEM LEHET KAPCSOLODNI AZ ADATBAZISHOZ!")
	else if(FailState == TQUERY_QUERY_FAILED)
		return set_fail_state("[ *HIBA* ] A LEKERDEZES MEGSZAKADT!")
	
	if(Errcode)
		return log_amx("[ *HIBA* ] PROBLEMA A LEKERDEZESNEL! ( %s )",Error)
	
	return PLUGIN_CONTINUE
}
*/
public sql_update_account_thread(FailState,Handle:Query,Error[],Errcode,Data[],DataSize)
{
	if(FailState == TQUERY_CONNECT_FAILED)
		return set_fail_state("[ *HIBA* ] NEM LEHET KAPCSOLODNI AZ ADATBAZISHOZ!");
	else if(FailState == TQUERY_QUERY_FAILED)
		return set_fail_state("[ *HIBA* ] A LEKERDEZES MEGSZAKADT!");
	
	if(Errcode)
		return log_amx("[ *HIBA* ] PROBLEMA A LEKERDEZESNEL! ( %s )",Error);
	
	
	return PLUGIN_CONTINUE;
}


public Fomenu(id)
{
	if(g_Bejelentkezve[id])
	{
	new String[121];
	format(String, charsmax(String), "%s^n\dDollár: \r%3.2f $ \d| SMS Pont: \r%d^n\wV1.9", Prefix, Dollar[id], SMS[id]);
	new menu = menu_create(String, "Fomenu_h");
	
	menu_additem(menu, "\w»\r{\yRaktár\r}", "1", 0);
	menu_additem(menu, "\w»\r{\yLádaNyitás\r}\y *Új", "2", 0);
	menu_additem(menu, "\w»\r{\yPiac\r}", "3", 0);
	menu_additem(menu, "\w»\r{\yBolt\r}\y", "4", 0);
	menu_additem(menu, "\w»\r{\yKuka\r}", "5", 0);
	menu_additem(menu, "\w»\r{\ySzerver Szabályzat\r}", "6", 0);
	if(Rang[id] == 18)
	{
	format(String, charsmax(String), "\w»\r{\yBeállítások\r}^n^n\dRangod: \r%s^n\dKövetkező Rangod: \yNincs", Rangok[Rang[id]][Szint]);
	}
	else
	{
	format(String, charsmax(String), "\w»\r{\yBeállítások\r}\y^n^n\dRangod: \r%s^n\dKövetkező Rangod: \y%s \r[\y%d\d/\w%d\r]", Rangok[Rang[id]][Szint],Rangok[Rang[id]+1][Szint],Oles[id],Rangok[Rang[id]][Xp]);
	}
	menu_additem(menu, String, "7", 0);
	menu_additem(menu, "\w»\r{\yFelhasználói felület\r}", "8", 0);
	
	menu_display(id, menu, 0);
	}
	else
	{
		showMenu_Main(id);
	}
}
public Fomenu_h(id, menu, item){
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return;
	}
	
	new data[9], szName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
	new key = str_to_num(data);
	
	switch(key)
	{
		case 1: Raktar(id);
		case 2: LadaNyitas(id);
		case 3: Piac(id);
		case 4: Shop(id);
		case 5: Kuka(id);
		case 6: show_motd(id, "addons/amxmodx/configs/szabalyzat.txt", "Szabályzat");
		case 7: Beallitasok(id);
		case 8: felhaszmenu(id);
	}
}
public skinshop(id)
{
	new String[256];
	format(String, charsmax(String), "%s \r- \ySkinek Boltja^nDollĂˇr:\r %3.2f $", Prefix,Dollar[id]);
	new menu = menu_create(String, "skinshoph");
	
	menu_additem(menu, "\w»\yKNIFE\r", "1", 0);
	menu_additem(menu, "\w»\yAK47\r", "2", 0);
	menu_additem(menu, "\w»\yM4A1\r", "3", 0);
	menu_additem(menu, "\w»\yAWP\r", "4", 0);
	menu_additem(menu, "\w»\yDEAGLE\r", "5", 0);
	
	menu_display(id, menu, 0);
}
public skinshoph(id, menu, item){
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return;	
	}
	
	new data[9], szName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
	new key = str_to_num(data);
	
	switch(key) 
	{
		case 1 : {
			kesek(id);
		}
		case 2: {
			ak47(id);
		}
		case 3 : {
			m4a1(id);
		}
		case 4: {
			awp(id);
		}
		case 5 : {
			deagle(id);
		}
	}
skinshop(id);
}
public kesek(id) {
new String[256];
format(String, charsmax(String), "%s \r- \yTárgyak vásárlása^nDollár:\r %3.2f $", Prefix,Dollar[id]);
new menu = menu_create(String, "kesekh");

for(new i=98;i <= 120; i++)
	{
			new Sor[6]; num_to_str(i, Sor, 5);
			formatex(String, charsmax(String), "%s \r| \y%d $", FegyverAdatok[i][Nev],FegyverAdatok[i][BoltiAr]);
			menu_additem(menu, String, Sor);
	}


		menu_display(id, menu);
	}
public kesekh(id, menu, item){
		
		if(item == MENU_EXIT)
		{
			menu_destroy(menu);
			return;
		}

		new data[9], szName[64],VevoNev[32];
		get_user_name(id,VevoNev,charsmax(VevoNev));
		new access, callback;
		menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
		new key = str_to_num(data);

		if(Dollar[id] >= FegyverAdatok[key][BoltiAr])
		{
		meglevoek[key][id]++;
		Dollar[id] -= FegyverAdatok[key][BoltiAr];
		ColorChat(id,TEAM_COLOR,"%s^3 %s^1 Vett egy^4 %s nevü tárgyat %d ért!",C_Prefix,VevoNev,FegyverAdatok[key][Nev],FegyverAdatok[key][BoltiAr]);
		}
		else
		{
		ColorChat(id,RED,"%s ^3Nincs elég pénzed!",C_Prefix);
		}
		 
	kesek(id);
}

public ak47(id) {
new String[256];
format(String, charsmax(String), "%s \r- \yTárgyak vásárlása^nDollár:\r %3.2f $", Prefix,Dollar[id]);
new menu = menu_create(String, "ak47h");

	for(new i=0;i <= 18; i++)
	{
			new Sor[6]; num_to_str(i, Sor, 5);
			formatex(String, charsmax(String), "%s \r| \y%d $", FegyverAdatok[i][Nev],FegyverAdatok[i][BoltiAr]);
			menu_additem(menu, String, Sor);
	}



	menu_display(id, menu);
}

public ak47h(id, menu, item){

	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return;
	}

	new data[9], szName[64],VevoNev[32];
		get_user_name(id,VevoNev,charsmax(VevoNev));
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
	new key = str_to_num(data);

		 if(Dollar[id] >= FegyverAdatok[key][BoltiAr])
		{
		meglevoek[key][id]++;
		Dollar[id] -= FegyverAdatok[key][BoltiAr];
		ColorChat(id,TEAM_COLOR,"%s^3 %s^1 Vett egy^4 %s nevü tárgyat %d ért!",C_Prefix,VevoNev,FegyverAdatok[key][Nev],FegyverAdatok[key][BoltiAr]);
		}
		else
		{
		ColorChat(id,RED,"%s ^3Nincs elég pénzed!",C_Prefix);
		}
		
ak47(id);
}


public m4a1(id) {
new String[256];
format(String, charsmax(String), "%s \r- \yTárgyak vásárlása^nDollár:\r %3.2f $", Prefix,Dollar[id]);
new menu = menu_create(String, "m4a1h");

		for(new i=19;i <= 38; i++)
	{
			new Sor[6]; num_to_str(i, Sor, 5);
			formatex(String, charsmax(String), "%s \r| \y%d $", FegyverAdatok[i][Nev],FegyverAdatok[i][BoltiAr]);
			menu_additem(menu, String, Sor);
	}



	menu_display(id, menu);
}

public m4a1h(id, menu, item){

	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return;
	}

	new data[9], szName[64],VevoNev[32];
		get_user_name(id,VevoNev,charsmax(VevoNev));
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
	new key = str_to_num(data);
	
	 if(Dollar[id] >= FegyverAdatok[key][BoltiAr])
		{
		meglevoek[key][id]++;
		Dollar[id] -= FegyverAdatok[key][BoltiAr];
		ColorChat(id,TEAM_COLOR,"%s^3 %s^1 Vett egy^4 %s nevü tárgyat %d ért!",C_Prefix,VevoNev,FegyverAdatok[key][Nev],FegyverAdatok[key][BoltiAr]);
		}
		else
		{
		ColorChat(id,RED,"%s ^3Nincs elég pénzed!",C_Prefix);
		}
		
	m4a1(id);
	}

	
	public awp(id) {
new String[256];
format(String, charsmax(String), "%s \r- \yTárgyak vásárlása^nDollár:\r %3.2f $", Prefix,Dollar[id]);
new menu = menu_create(String, "awph");

		for(new i=39;i <= 53; i++)
	{
			new Sor[6]; num_to_str(i, Sor, 5);
			formatex(String, charsmax(String), "%s \r| \y%d $", FegyverAdatok[i][Nev],FegyverAdatok[i][BoltiAr]);
			menu_additem(menu, String, Sor);
	}

		menu_display(id, menu);
	}
public awph(id, menu, item){
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return;
	}

	new data[9], szName[64],VevoNev[32];
		get_user_name(id,VevoNev,charsmax(VevoNev));
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
	new key = str_to_num(data);

	if(Dollar[id] >= FegyverAdatok[key][BoltiAr])
		{
		meglevoek[key][id]++;
		Dollar[id] -= FegyverAdatok[key][BoltiAr];
		ColorChat(id,TEAM_COLOR,"%s^3 %s^1 Vett egy^4 %s nevü tárgyat %d ért!",C_Prefix,VevoNev,FegyverAdatok[key][Nev],FegyverAdatok[key][BoltiAr]);
		}
		else
		{
		ColorChat(id,RED,"%s ^3Nincs elég pénzed!",C_Prefix);
		}
		awp(id);
}
public deagle(id) {
new String[256];
format(String, charsmax(String), "%s \r- \yTĂˇrgyak vĂˇsĂˇrlĂˇsa^nDollĂˇr:\r %3.2f $", Prefix,Dollar[id]);
new menu = menu_create(String, "deagkeh");

			for(new i=74;i <= 83; i++)
			{
			new Sor[6]; num_to_str(i, Sor, 5);
			formatex(String, charsmax(String), "%s \r| \y%d $", FegyverAdatok[i][Nev],FegyverAdatok[i][BoltiAr]);
			menu_additem(menu, String, Sor);
			}


			menu_display(id, menu);
		}
		public deagleh(id, menu, item){

			if(item == MENU_EXIT)
			{
				menu_destroy(menu);
				return;
			}

			new data[9], szName[64],VevoNev[32];
		get_user_name(id,VevoNev,charsmax(VevoNev));
			new access, callback;
			menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
			new key = str_to_num(data);

			
			if(Dollar[id] >= FegyverAdatok[key][BoltiAr])
			{
			meglevoek[key][id]++;
			Dollar[id] -= FegyverAdatok[key][BoltiAr];
			ColorChat(id,TEAM_COLOR,"%s^3 %s^1 Vett egy^4 %s nevü tárgyat %d ért!",C_Prefix,VevoNev,FegyverAdatok[key][Nev],FegyverAdatok[key][BoltiAr]);
			}
			else
			{
			ColorChat(id,RED,"%s ^3Nincs elég pénzed!",C_Prefix);
			}
		
	deagle(id);
}


public Shop(id)
{
new String[256],String2[256];
static iTime;
	iTime = g_iVipTime[id] - get_systime( );
if(Vip[id] == 1)
{
format(String, charsmax(String), "%s \r- \yBolt^nSMS Pont:\r %d ^n\yVip lejárati idő:\y [\r%d nap\y]", Prefix,SMS[id],iTime / 86400);
}
else
{
format(String, charsmax(String), "%s \r- \yBolt^nSMS Pont:\r %d ^n", Prefix,SMS[id]);
}
new menu = menu_create(String, "shop_h");

if(Vip[id] == 0)
{
if(g_iVipNum[id] == 1)
{
menu_additem(menu, "\w»\rVip hosszabbítás\y [208 HUF/30Nap]", "1", 0);
}
else
{
menu_additem(menu, "\w»\rVip vásárlás\y [508 HUF/30Nap]", "1", 0);
}
}
/*
else
{
formatex(String2, charsmax(String2), "\yVip lejárati idő:\y [\r%d nap\y]", iTime / 86400);
menu_additem(menu, String2, "1");
}
*/
menu_additem(menu, "\w»\yHE Gránát\r(2Pont)", "2", 0);
menu_additem(menu, "\w»\yVakítóGránát\r(2Pont)", "3", 0);
menu_additem(menu, "\w»\y+20 HP & +20 AP\r(4pont)", "4", 0);
menu_additem(menu, "\w»\yFegyvermenü\r(6Pont)", "5", 0);
menu_additem(menu, "\w»\yC4\r(8Pont)", "6", 0);

menu_display(id, menu, 0);
}
public shop_h(id, menu, item){
if(item == MENU_EXIT)
{
menu_destroy(menu);
return;
}

new data[9], szName[64];
new access, callback;
menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
new key = str_to_num(data);

switch(key) 
	{
		case 1: 
		{
			if(Vip[id] == 0)
			{
			if(g_iVipNum[id] == 1)
			{
			if(SMS[id] >= 208)
			{
			Vip[id] = 1;
			SMS[id] -= 208;
			ColorChat(id,RED,"%s ^1A vip jogod hosszabbítva lett!^3 -208HUF, +30Nap",C_Prefix);
			g_iVipTime[id] = get_systime( ) + VIPTIME;
			sql_update_account(id);
			}
			else
			{
			ColorChat(id,RED,"%s ^3Nincs elég SMS pontod!",C_Prefix);
			}
			}
			else
			{
			if(SMS[id] >= 508)
			{
			Vip[id] = 1;
			SMS[id] -= 508;
			ColorChat(id,RED,"%s ^1A vip jogod aktiválva lett!^3 -508HUF",C_Prefix);
			g_iVipTime[id] = get_systime( ) + VIPTIME;
			sql_update_account(id);
			}
			/*
			else if(ajandekcsomag[id] >= 10)
			{
			Vip[id] = 1;
			ajandekcsomag[id] -= 10;
			ColorChat(id,RED,"%s ^1A vip jogod aktiválva lett!^3 -10 ajándékcsomag",C_Prefix);
			g_iVipTime[id] = get_systime( ) + VIPTIME;
			sql_update_account(id);
			}
			*/
			else
			{
			ColorChat(id,RED,"%s ^3Nincs elég SMS pontod!",C_Prefix);
			}
			}
			}
		}
		case 2: 
		{
			if(SMS[id] >= 2)
			{
			give_item(id, "weapon_hegrenade");
			SMS[id] -= 2;
			}
			else
			{
			ColorChat(id,RED,"%s ^3Nincs elég SMS pontod!",C_Prefix);
			}
		}
		case 3: 
		{
			if(SMS[id] >= 2)
			{
			give_item(id, "weapon_flashbang");
			SMS[id] -= 2;
			}
			else
			{
			ColorChat(id,RED,"%s ^3Nincs elég SMS pontod!",C_Prefix);
			}
		}
		case 4: 
		{
			if(SMS[id] >= 4)
			{
			if(get_user_health(id) <= 80)
			{
			set_user_health(id, get_user_health(id)+20);
			give_item(id, "item_assaultsuit");
			set_user_armor(id, get_user_armor(id)+20);
			SMS[id] -= 4;
			}
			else
			{
			ColorChat(id,RED,"^3Sajnálom elérted a maximális HPt!");
			}
			}
			else
			{
			ColorChat(id,RED,"%s ^3Nincs elég SMS pontod!",C_Prefix);
			}
		}
		case 5: 
		{
			if(SMS[id] >= 6)
			{
			Fegyvermenu(id);
			SMS[id] -= 6;
			}
			else
			{
			ColorChat(id,RED,"%s ^3Nincs elég SMS pontod!",C_Prefix);
			}
		}
		case 6: 
		{
			if(cs_get_user_team(id) == CS_TEAM_T) {
			if(SMS[id] >= 8)
			{
				give_item(id, "weapon_c4");
				cs_set_user_plant(id, 1 );
				SMS[id] -= 8;
			}
			else
			{
			ColorChat(id,RED,"%s ^3Nincs elég SMS pontod!",C_Prefix);
			}
			}
			else
			{
			ColorChat(id,RED,"%s ^3Te nem vagy a^4 Terrorista ^3csapatban!",C_Prefix);
			}
		}
		 
	}
}

public felhaszmenu(id)
{
new String[256],String2[256];
format(String, charsmax(String), "%s \r- \dFelhasználói Panel^n\d", Prefix);
new menu = menu_create(String, "felhasz_h");

menu_additem(menu, "\w»\d{\yFiók beállítás\d}^n", "1", 0);
menu_additem(menu, "\w»\d{\ySMS Támogatás\r/\yVip vásárlás\d}^n", "2", 0);
if(get_user_flags(id) & ADMIN_BAN)
{
format(String2, charsmax(String2),"\d[\rJátékos fiók felfüggesztése & feloldása\d]");
menu_addtext(menu, String2, 0);
menu_additem(menu, "\w»\rFelfüggesztés", "3", 0);
menu_additem(menu, "\w»\yFeloldás^n", "4", 0);
}
if(get_user_flags(id) & ADMIN_CVAR)
menu_additem(menu, "\w»\d[\yJátékosnak való addolás\d]", "5", 0);
if(get_user_flags(id) & ADMIN_CVAR)
menu_additem(menu, "\w»\d[\rJátékostól való megvonás\d]", "6", 0);
if(get_user_flags(id) & ADMIN_BAN)
menu_additem(menu, "\w»\d[\rJátékosról kép készítése\y[BANHOZ]\d]", "7", 0);

menu_display(id, menu, 0);
}
public felhasz_h(id, menu, item){
if(item == MENU_EXIT)
{
menu_destroy(menu);
return;
}

new data[9], szName[64];
new access, callback;
menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
new key = str_to_num(data);

switch(key) 
	{
		case 1: 
		{
			showMenu_Options(id);
		}
		case 2: 
		{
			show_motd(id, "addons/amxmodx/configs/smssupport.txt", "SMS Támogatás");
		}
		case 3: 
		{
		if(get_user_flags(id) & ADMIN_BAN)
		{
			addolasikulcs = 1000;
			accountpause = 1;
			PlayerChoose(id);
		}
		}
		case 4: 
		{
		if(get_user_flags(id) & ADMIN_BAN)
		{
			addolasikulcs = 1000;
			accountpause = 0;
			PlayerChoose(id);
		}
		}
		case 5: 
		{
		if(get_user_flags(id) & ADMIN_CVAR)
		{
			staffaddolas(id);
		}
		}
		case 6: 
		{
		if(get_user_flags(id) & ADMIN_CVAR)
		{
			//PlayerChoose3(id);
			megkerdezes(id);
		}
		}
		case 7: 
		{
		if(get_user_flags(id) & ADMIN_BAN)
		{
			addolasikulcs = 9950;
			PlayerChoose2(id);
		}
		}
	}
}
public megkerdezes(id)
{
new String[256];
format(String, charsmax(String), "%s \r- \dVálassz az opciók közül^n\d", Prefix);
new menu = menu_create(String, "megkerd_h");

menu_additem(menu, "\w»\d{\yItem Megvonás\d}^n", "1", 0);
menu_additem(menu, "\w»\d{\yVIP Megvonás\r Felhasználónév \yalapján\d}^n", "2", 0);

menu_display(id, menu, 0);
}
public megkerd_h(id, menu, item){
if(item == MENU_EXIT)
{
menu_destroy(menu);
return;
}

new data[9], szName[64];
new access, callback;
menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
new key = str_to_num(data);

switch(key) 
	{
		case 1: 
		{
			PlayerChoose3(id);
		}
		case 2: 
		{
			viptorol = 1;
			ColorChat(id,BLUE,"%s ^3Írd be a felhasználónevét!",C_Prefix);
			client_cmd(id, "messagemode USERNAME3");
		}
	}
}
public staffaddolas(id)
{
new String[256];
format(String, charsmax(String), "%s \r- \yMit szeretnél addolni?^n\d", Prefix);
new menu = menu_create(String, "staffadd_h");
for(new i=0; i <= 120; i++)
{
	new Sor[6]; num_to_str(i, Sor, 5);
	formatex(String, charsmax(String), "\w%s", FegyverAdatok[i][Nev]);
	menu_additem(menu, String, Sor);
}
for(new i=121; i <= 127; i++)
{
	new Sor[6]; num_to_str(i, Sor, 5);
	formatex(String, charsmax(String), "\y%s",l_Nevek[i-121][0]);
	menu_additem(menu, String, Sor);
}
formatex(String, charsmax(String), "\rKulcs");
menu_additem(menu, String, "128");
formatex(String, charsmax(String), "\rV\yI\dP \wAddolás!");
menu_additem(menu, String, "129");


menu_display(id, menu, 0);
}
public staffadd_h(id, menu, item){
if(item == MENU_EXIT)
{
menu_destroy(menu);
return;
}

new data[9], szName[64];
new access, callback;
menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
new key = str_to_num(data);

addolasikulcs = key;
if(key == 129)
{
addvip(id);
}
else
{
PlayerChoose2(id);
}
}
public PlayerChoose2(id)
{
	new String[121];
	format(String, charsmax(String), "%s \r- \dVálassz Játékost", Prefix);
	new Menu = menu_create(String, "PlayerHandler2");
	
	new players[32], pnum, tempid;
	new szName[32], szTempid[10];
	get_players(players, pnum);
	
	for( new i; i<pnum; i++ )
	{
		tempid = players[i];
		{
			get_user_name(tempid, szName, charsmax(szName));
			num_to_str(tempid, szTempid, charsmax(szTempid));
			menu_additem(Menu, szName, szTempid, 0);
		}
	}
	
	menu_display(id, Menu, 0);
	return PLUGIN_HANDLED;
}
public PlayerHandler2(id, Menu, item)
{
	if( item == MENU_EXIT )
	{
		menu_destroy(Menu);
		return PLUGIN_HANDLED;
	}
	new Data[6], szName[64];
	new access, callback;
	menu_item_getinfo(Menu, item, access, Data,charsmax(Data), szName,charsmax(szName), callback);
	TempID = str_to_num(Data);
	
	if(addolasikulcs == 9950)
	{
	client_cmd( TempID, "snapshot" );
	g_snapshot[TempID]++;
	ColorChat(id,BLUE,"%s ^3A személyről kép lett készítve! Összes:^4 %d",C_Prefix,g_snapshot[TempID]);
	}
	else if(addolasikulcs == 999)
	{
	Vip[TempID] = 1;
	new p_name[33];
	get_user_name(id,p_name,charsmax(p_name));
	ColorChat(TempID,BLUE,"%s ^4%s ^3Jóváírt neked egy^4 Vip ^3tagot!",C_Prefix,p_name);
	ColorChat(id,BLUE,"%s Sikeres jóváírás!",C_Prefix);
	sql_update_account(id);
	}
	else if(addolasikulcs == 911)
	{
	s_addvariable[TempID] = 1;
	new s_name[33], performer_name[33];
	get_user_name(TempID, s_name,charsmax(s_name));
	get_user_name(id, performer_name,charsmax(performer_name));
	ColorChat(0,BLUE,"%s %s ^3Növelte^4 %s ^3jogát^4 segítői ^3szintre!",C_Prefix,performer_name,s_name);
	ColorChat(TempID,BLUE,"%s ^3További infókért írd be:^4 /sinfo",C_Prefix);
	set_user_flags(TempID, get_user_flags(TempID) | ADMIN_CHAT);
	}
	else if(addolasikulcs == 912)
	{
	client_cmd(id, "messagemode SKICK_INDOK");
	}
	else if(addolasikulcs == 913)
	{
	s_addvariable[TempID] = 0;
	new s_name[33], performer_name[33];
	get_user_name(TempID, s_name,charsmax(s_name));
	get_user_name(id, performer_name,charsmax(performer_name));
	ColorChat(0,BLUE,"%s %s ^3Csökkentette^4 %s ^3jogát^4 felhasználói ^3szintre!",C_Prefix,performer_name,s_name);
	remove_user_flags(TempID, get_user_flags(TempID) | ADMIN_CHAT);
	}
	else if(addolasikulcs == 129)
	{
	addvip(id);
	}
	else
	{
	client_cmd(id, "messagemode ADDMENNYISEG");
	}
	menu_destroy(Menu);
	return PLUGIN_HANDLED;
}
public AddSend(id)
{
new Data[121];
new SendName[32];

read_args(Data, charsmax(Data));
remove_quotes(Data);

get_user_name(id, SendName, 31);

if(str_to_num(Data) < 1) 
	return PLUGIN_HANDLED;


if(addolasikulcs <= 120)
{
	meglevoek[addolasikulcs][TempID] += str_to_num(Data);
	ColorChat(TempID, BLUE, "%s^3%s ^1Jóváírt neked^4 %d DB^4 %s ^1nevü skint!", C_Prefix, SendName, str_to_num(Data), FegyverAdatok[addolasikulcs][Nev]);
}
else if(addolasikulcs >= 121 && addolasikulcs != 128 && addolasikulcs != 129)
{
addolasikulcs -= 121;
Lada[addolasikulcs][TempID] += str_to_num(Data);
ColorChat(TempID, BLUE, "%s^3%s ^1Jóváírt neked^4 %d DB^4 %s nevü itemet!", C_Prefix, SendName, str_to_num(Data), l_Nevek[addolasikulcs][0]);
}
else if(addolasikulcs == 128)
{
Kulcs[TempID] += str_to_num(Data);
ColorChat(TempID, BLUE, "%s^3%s ^1Jóváírt neked^4 %d DB^4 Kulcs^1-ot", C_Prefix, SendName, str_to_num(Data));
}

return PLUGIN_HANDLED;
}
public addvip(id)
{
new String[256];
format(String, charsmax(String), "%s \r- \yVálassz az opciók közül!^n\d", Prefix);
new menu = menu_create(String, "addvip_h");
formatex(String, charsmax(String), "\y»Fentlévő játékosnak");
menu_additem(menu, String, "1");
formatex(String, charsmax(String), "\y»Felhasználónév alapján^n\rMegjegyzés: Akkor válaszd ezt az opciót ha offline a játékos!");
menu_additem(menu, String, "2");


menu_display(id, menu, 0);
}
public addvip_h(id, menu, item){
if(item == MENU_EXIT)
{
menu_destroy(menu);
return;
}

new data[9], szName[64];
new access, callback;
menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
new key = str_to_num(data);

switch(key) 
	{
		case 1: 
		{
			addolasikulcs = 999;
			PlayerChoose2(id);
		}
		case 2: 
		{
			client_cmd(id, "messagemode USERNAME3");
			ColorChat(id,BLUE,"%s ^3Írd be a felhasználónevét!",C_Prefix);
		}
	}
}
public sql_delete_vip(id)
{	
	static Query[256];
	
	new a[191];
	
	format(a, 190, "%s", g_FHVIP[id]);
	
	replace_all(a, 190, "\", "\\");
	replace_all(a, 190, "'", "\'");
	
	formatex(Query, charsmax(Query), "UPDATE rwt_sql_register_new_s5 SET Vip = '0' WHERE Felhasznalonev = '%s'", a);
	
	new Data[2];
	Data[0] = id;
	Data[1] = get_user_userid(id);
	
	SQL_ThreadQuery(g_SqlTuple, "sql_delete_vip_thread", Query, Data, 2);
}
public sql_delete_vip_thread(FailState,Handle:Query,Error[],Errcode,Data[],DataSize)
{
	if(FailState == TQUERY_CONNECT_FAILED)
		return set_fail_state("[ *HIBA* ] NEM LEHET KAPCSOLODNI AZ ADATBAZISHOZ!");
	else if(FailState == TQUERY_QUERY_FAILED)
		return set_fail_state("[ *HIBA* ] A LEKERDEZES MEGSZAKADT!");
	
	if(Errcode)
		return log_amx("[ *HIBA* ] PROBLEMA A LEKERDEZESNEL! ( %s )",Error);
		
		new id = Data[0];
		
		if(Data[1] != get_user_userid(id))
		return PLUGIN_HANDLED;
		
		ColorChat(id,BLUE,"%s ^3A VIP törlése megtörtént a következő felhasználónévre:^4 %s",C_Prefix,g_FHVIP[id]);
		viptorol = 0;
	
	return PLUGIN_CONTINUE;
}

public sql_update_vip(id)
{	
	static Query[256];
	
	new a[191];
	
	format(a, 190, "%s", g_FHVIP[id]);
	
	replace_all(a, 190, "\", "\\");
	replace_all(a, 190, "'", "\'");
	
	formatex(Query, charsmax(Query), "UPDATE rwt_sql_register_new_s5 SET Vip = '1' WHERE Felhasznalonev = '%s'", a);
	
	new Data[2];
	Data[0] = id;
	Data[1] = get_user_userid(id);
	
	SQL_ThreadQuery(g_SqlTuple, "sql_update_vip_thread", Query, Data, 2);
}
public sql_update_vip_thread(FailState,Handle:Query,Error[],Errcode,Data[],DataSize)
{
	if(FailState == TQUERY_CONNECT_FAILED)
		return set_fail_state("[ *HIBA* ] NEM LEHET KAPCSOLODNI AZ ADATBAZISHOZ!");
	else if(FailState == TQUERY_QUERY_FAILED)
		return set_fail_state("[ *HIBA* ] A LEKERDEZES MEGSZAKADT!");
	
	if(Errcode)
		return log_amx("[ *HIBA* ] PROBLEMA A LEKERDEZESNEL! ( %s )",Error);
		
		new id = Data[0];
		
		if(Data[1] != get_user_userid(id))
		return PLUGIN_HANDLED;
		
		ColorChat(id,BLUE,"%s ^3A VIP adása megtörtént a következő felhasználónévre:^4 %s",C_Prefix,g_FHVIP[id]);
	
	return PLUGIN_CONTINUE;
}

public staffmegvonas(id)
{
new String[256];
format(String, charsmax(String), "%s \y- \rMit szeretnél elvonni?^n\d", Prefix);
new menu = menu_create(String, "staffmegv_h");
for(new i=0; i <= 120; i++)
{
	if(meglevoek[i][TempID] > 0)
	{
	new Sor[6]; num_to_str(i, Sor, 5);
	formatex(String, charsmax(String), "\w%s \w[\y%d DB\w]", FegyverAdatok[i][Nev],meglevoek[i][TempID]);
	menu_additem(menu, String, Sor);
	}
}
for(new i=121; i <= 127; i++)
{
	if(Lada[i-121][TempID] > 0)
	{
	new Sor[6]; num_to_str(i, Sor, 5);
	formatex(String, charsmax(String), "\y%s \w[\y%d DB\w]",l_Nevek[i-121][0], Lada[i-121][TempID]);
	menu_additem(menu, String, Sor);
	}
}
if(meglevoek[132][TempID] > 0)
{
formatex(String, charsmax(String), "\yFragBajnok Kés");
menu_additem(menu, String, "128");
}
if(meglevoek[133][TempID] > 0)
{
formatex(String, charsmax(String), "\rV\yI\dP \wKés");
menu_additem(menu, String, "129");
}
formatex(String, charsmax(String), "\rKulcs \w[\y%d DB\w]",Kulcs[TempID]);
menu_additem(menu, String, "130");
if(Vip[id] > 0)
{
formatex(String, charsmax(String), "\rV\yI\dP \wElvonás!!!!!!");
menu_additem(menu, String, "131");
}



menu_display(id, menu, 0);
}
public staffmegv_h(id, menu, item){
if(item == MENU_EXIT)
{
menu_destroy(menu);
return;
}

new data[9], szName[64],p_name[33];
new access, callback;
get_user_name(id,p_name,charsmax(p_name));
menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
new key = str_to_num(data);

addolasikulcs = key;
if(key == 131)
{
Vip[TempID] = 0;
if(get_user_health(TempID) == 120)
{
set_user_health(TempID,100);
meglevoek[133][id] = 0;
kivalasztott[id][KNIFE] = 131;
set_pev(id,pev_viewmodel2,FegyverAdatok[131][Model]);
}
ColorChat(TempID, RED, "%s^1%s ^3Megvont a^4 VIPPED^3-től!", C_Prefix, p_name);
sql_update_account(id);
}
else
{
client_cmd(id, "messagemode MEGVONMENNYISEG");
}
}
public PlayerChoose3(id)
{
	new String[121];
	format(String, charsmax(String), "%s \d- \rVálassz Játékost", Prefix);
	new Menu = menu_create(String, "PlayerHandler3");
	
	new players[32], pnum, tempid;
	new szName[32], szTempid[10];
	get_players(players, pnum);
	
	for( new i; i<pnum; i++ )
	{
		tempid = players[i];
		{
			get_user_name(tempid, szName, charsmax(szName));
			num_to_str(tempid, szTempid, charsmax(szTempid));
			menu_additem(Menu, szName, szTempid, 0);
		}
	}
	
	menu_display(id, Menu, 0);
	return PLUGIN_HANDLED;
}
public PlayerHandler3(id, Menu, item)
{
	if( item == MENU_EXIT )
	{
		menu_destroy(Menu);
		return PLUGIN_HANDLED;
	}
	new Data[6], szName[64];
	new access, callback;
	menu_item_getinfo(Menu, item, access, Data,charsmax(Data), szName,charsmax(szName), callback);
	TempID = str_to_num(Data);
	
	staffmegvonas(id);
	
	menu_destroy(Menu);
	return PLUGIN_HANDLED;
}
public AddSend2(id)
{
new Data[121];
new SendName[32];

read_args(Data, charsmax(Data));
remove_quotes(Data);

get_user_name(id, SendName, 31);

if(str_to_num(Data) < 1) 
	return PLUGIN_HANDLED;


if(addolasikulcs <= 120)
{
	meglevoek[addolasikulcs][TempID] -= str_to_num(Data);
	ColorChat(TempID, RED, "%s^3%s ^1Elvett tőled^4 %d DB^4 %s ^1nevü skint!", C_Prefix, SendName, str_to_num(Data), FegyverAdatok[addolasikulcs][Nev]);
	if(FegyverAdatok[addolasikulcs][Type] == 0)
	{
	kivalasztott[TempID][AK47] = 121;
	}
	else if(FegyverAdatok[addolasikulcs][Type] == 1)
	{
	kivalasztott[TempID][M4A1] = 122;
	}
	else if(FegyverAdatok[addolasikulcs][Type] == 2)
	{
	kivalasztott[TempID][AWP] = 123;
	}
	else if(FegyverAdatok[addolasikulcs][Type] == 3)
	{
	kivalasztott[TempID][FAMAS] = 124;
	}
	else if(FegyverAdatok[addolasikulcs][Type] == 4)
	{
	kivalasztott[TempID][MP5NAVY] = 125;
	}
	else if(FegyverAdatok[addolasikulcs][Type] == 5)
	{
	kivalasztott[TempID][GALIL] = 126;
	}
	else if(FegyverAdatok[addolasikulcs][Type] == 6)
	{
	kivalasztott[TempID][SCOUT] = 127;
	}
	else if(FegyverAdatok[addolasikulcs][Type] == 7)
	{
	kivalasztott[TempID][DEAGLE] = 128;
	}
	else if(FegyverAdatok[addolasikulcs][Type] == 8)
	{
	kivalasztott[TempID][USP] = 129;
	}
	else if(FegyverAdatok[addolasikulcs][Type] == 9)
	{
	kivalasztott[TempID][GLOCK18] = 130;
	}
	else if(FegyverAdatok[addolasikulcs][Type] == 10)
	{
	kivalasztott[TempID][KNIFE] = 131;
	}
}
else if(addolasikulcs >= 121 && addolasikulcs != 128 && addolasikulcs != 129)
{
addolasikulcs -= 121;
Lada[addolasikulcs][TempID] -= str_to_num(Data);
ColorChat(TempID, RED, "%s^3%s ^1Elvett tőled^4 %d DB^4 %s ^1nevü itemet!", C_Prefix, SendName, str_to_num(Data), l_Nevek[addolasikulcs][0]);
}
else if(addolasikulcs == 128)
{
meglevoek[132][TempID] -= str_to_num(Data);
ColorChat(TempID, RED, "%s^3%s ^1Elvett tőled egy^4 FragBajnok KÉS ^1nevü skint!", C_Prefix, SendName);
	if(FegyverAdatok[132][Type] == 10)
	{
	kivalasztott[TempID][KNIFE] = 131;
	}
}
else if(addolasikulcs == 129)
{
meglevoek[133][TempID] -= str_to_num(Data);
ColorChat(TempID, RED, "%s^3%s ^1Elvett tőled egy^4 VIP KÉS ^1nevü skint!", C_Prefix, SendName);
	if(FegyverAdatok[133][Type] == 10)
	{
	kivalasztott[TempID][KNIFE] = 131;
	}
}
else if(addolasikulcs == 130)
{
Kulcs[TempID] -= str_to_num(Data);
ColorChat(TempID, RED, "%s^3%s ^1Elvett tőled^4 %d DB^4 Kulcs^1-ot", C_Prefix, SendName, str_to_num(Data));
}


return PLUGIN_HANDLED;
}


public Beallitasok(id)
{
new String[121];
format(String, charsmax(String), "%s \r- \dBeállítások", Prefix);
new menu = menu_create(String, "Beallitasok_h");

if(Gun[0][id] == 1)
{
menu_additem(menu, "Skinek: \yBekapcsolva \d(testreszabható)", "1",0);
}
else
{
menu_additem(menu, "Skinek: \dKikapcsolva", "1",0);
}
if(Hud[id] == 1)
{
menu_additem(menu, "HUD: \yBekapcsolva", "2",0);
}
else
{
menu_additem(menu, "HUD: \dKikapcsolva", "2",0);
}

menu_additem(menu, "\ySebzésjelző testreszabása", "3", 0);
formatex(String, charsmax(String), "\yAutomatikus Adat kitöltés bejelentkezésnél:\r [\y%s\r]", AutoLogin == 1 ? "\yBekapcsolva" : "\dKikapcsolva");
menu_additem(menu, String, "4", 0);
formatex(String, charsmax(String), "\yHavazás:\r [\y%s\r]", havazas == 1 ? "\yBekapcsolva" : "\dKikapcsolva");
menu_additem(menu, String, "5", 0);

menu_display(id, menu, 0);
}
public Beallitasok_h(id, menu, item){
if(item == MENU_EXIT)
{
menu_destroy(menu);
return;
}

new data[9], szName[64];
new access, callback;
menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
new key = str_to_num(data);

switch(key) 
	{
		case 1: 
		{
			if(Gun[0][id] == 1)
			{
				skintestreszab(id);
			}
			else 
			{
				Gun[0][id] = 1;
				Beallitasok(id);
			}
		}
		case 2: 
		{
			if(Hud[id] == 1)
			{
				Hud[id] = 0;
			}
			else 
			{
				Hud[id] = 1;
			}
			Beallitasok(id);
		}
		case 3:
		{
		client_cmd(id,"sebzesmenu");
		}
		case 4:
		{
		if(AutoLogin == 1)
		{
		AutoLogin = 0;
		new Temporary_Felhasznalonev[33][20],Temporary_Jelszo[33][20];
		Temporary_Felhasznalonev[id][0] = EOS;
		Temporary_Jelszo[id][0] = EOS;
		set_user_info(id, "pbtusername", Temporary_Felhasznalonev[id]);
		set_user_info(id, "pbtpassword", Temporary_Jelszo[id]);
		client_cmd(id, "setinfo ^"pbtusername^" ^"%s^"", Temporary_Felhasznalonev[id]);
		client_cmd(id, "setinfo ^"pbtpassword^" ^"%s^"", Temporary_Jelszo[id]);
		}
		else
		{
		AutoLogin = 1;
		set_user_info(id, "pbtusername", g_Felhasznalonev[id]);
		set_user_info(id, "pbtpassword", g_Jelszo[id]);
		client_cmd(id, "setinfo ^"pbtusername^" ^"%s^"", g_Felhasznalonev[id]);
		client_cmd(id, "setinfo ^"pbtpassword^" ^"%s^"", g_Jelszo[id]);
		}
		ColorChat(id,BLUE,"%s ^3Sikeres művelet!",C_Prefix);
		sql_update_account(id);
		Beallitasok(id);
		}
		case 5:
		{
		if(havazas == 1)
		{
		havazas = 0;
		client_cmd(id, "cl_weather 0");
		}
		else
		{
		havazas = 1;
		client_cmd(id, "cl_weather 1");
		}
		sql_update_account(id);
		Beallitasok(id);
		}
		
	}
}
public skintestreszab(id)
{
new String[256];
format(String, charsmax(String), "%s \r- \dSkinek\r/\dTestreszabás", Prefix);
new menu = menu_create(String, "testreszab_h");

menu_additem(menu, "\rSkinek Kikapcsolása", "1", 0);
formatex(String, charsmax(String), "\yAK47 Skin\r-[%s\r]", Gun[1][id] == 1 ? "\y\yBekapcsolva" : "\d\dKikapcsolva");
menu_additem(menu, String, "2", 0);
formatex(String, charsmax(String), "\yM4A1/A4 Skin\r-[\y%s\r]", Gun[2][id] == 1 ? "\yBekapcsolva" : "\dKikapcsolva");
menu_additem(menu, String, "3", 0);
formatex(String, charsmax(String), "\yAWP Skin\r-[\y%s\r]", Gun[3][id] == 1 ? "\yBekapcsolva" : "\dKikapcsolva");
menu_additem(menu, String, "4", 0);
formatex(String, charsmax(String), "\yFAMAS Skin\r-[\y%s\r]", Gun[4][id] == 1 ? "\yBekapcsolva" : "\dKikapcsolva");
menu_additem(menu, String, "5", 0);
formatex(String, charsmax(String), "\yMP5 Skin\r-[\y%s\r]", Gun[5][id] == 1 ? "\yBekapcsolva" : "\dKikapcsolva");
menu_additem(menu, String, "6", 0);
formatex(String, charsmax(String), "\yGALIL Skin\r-[\y%s\r]", Gun[6][id] == 1 ? "\yBekapcsolva" : "\dKikapcsolva");
menu_additem(menu, String, "7", 0);
formatex(String, charsmax(String), "\ySCOUT Skin\r-[\y%s\r]", Gun[7][id] == 1 ? "\yBekapcsolva" : "\dKikapcsolva");
menu_additem(menu, String, "8", 0);
formatex(String, charsmax(String), "\yDEAGLE Skin\r-[\y%s\r]", Gun[8][id] == 1 ? "\yBekapcsolva" : "\dKikapcsolva");
menu_additem(menu, String, "9", 0);
formatex(String, charsmax(String), "\yUSP Skin\r-[\y%s\r]", Gun[9][id] == 1 ? "\yBekapcsolva" : "\dKikapcsolva");
menu_additem(menu, String, "10", 0);
formatex(String, charsmax(String), "\yGLOCK Skin\r-[\y%s\r]", Gun[10][id] == 1 ? "\yBekapcsolva" : "\dKikapcsolva");
menu_additem(menu, String, "11", 0);
formatex(String, charsmax(String), "\yKNIFE Skin\r-[\y%s\r]", Gun[11][id] == 1 ? "\yBekapcsolva" : "\dKikapcsolva");
menu_additem(menu, String, "12", 0);

menu_display(id, menu, 0);
}
public testreszab_h(id, menu, item){
if(item == MENU_EXIT)
{
menu_destroy(menu);
return;
}

new data[9], szName[64];
new access, callback;
menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
new key = str_to_num(data);

switch(key) 
	{
		case 1: 
		{
		Gun[0][id] = 0;
		}
		case 2:{
		if(Gun[1][id] == 1){
		Gun[1][id] = 0;
		}
		else{
		Gun[1][id] = 1;
		}
		}
				case 3:{
		if(Gun[2][id] == 1){
		Gun[2][id] = 0;
		}
		else{
		Gun[2][id] = 1;
		}
		}
				case 4:{
		if(Gun[3][id] == 1){
		Gun[3][id] = 0;
		}
		else{
		Gun[3][id] = 1;
		}
		}
				case 5:{
		if(Gun[4][id] == 1){
		Gun[4][id] = 0;
		}
		else{
		Gun[4][id] = 1;
		}
		}
				case 6:{
		if(Gun[5][id] == 1){
		Gun[5][id] = 0;
		}
		else{
		Gun[5][id] = 1;
		}
		}
				case 7:{
		if(Gun[6][id] == 1){
		Gun[6][id] = 0;
		}
		else{
		Gun[6][id] = 1;
		}
		}
				case 8:{
		if(Gun[7][id] == 1){
		Gun[7][id] = 0;
		}
		else{
		Gun[7][id] = 1;
		}
		}
				case 9:{
		if(Gun[8][id] == 1){
		Gun[8][id] = 0;
		}
		else{
		Gun[8][id] = 1;
		}
		}
				case 10:{
		if(Gun[9][id] == 1){
		Gun[9][id] = 0;
		}
		else{
		Gun[9][id] = 1;
		}
		}
				case 11:{
		if(Gun[10][id] == 1){
		Gun[10][id] = 0;
		}
		else{
		Gun[10][id] = 1;
		}
		}
				case 12:{
		if(Gun[11][id] == 1){
		Gun[11][id] = 0;
		}
		else{
		Gun[11][id] = 1;
		}
		}
	}
	if(Gun[0][id] != 0)
	skintestreszab(id);
}
public LadaNyitas(id)
{
new String[151];
formatex(String, charsmax(String), "%s \r- \dLádaNyitás^n\wKulcs: \d[\r%d DB\d]", Prefix, Kulcs[id]);
new menu = menu_create(String, "Lada_h");

		formatex(String, charsmax(String), "\rAjándékcsomag \d[\r%d DB\d]",ajandekcsomag[id]);
	menu_additem(menu, String, "0", 0);
	formatex(String, charsmax(String), "%s \d[\r%d DB\d]", l_Nevek[0][0], Lada[0][id]);
	menu_additem(menu, String, "1", 0);
	formatex(String, charsmax(String), "%s \d[\r%d DB\d]", l_Nevek[1][0], Lada[1][id]);
	menu_additem(menu, String, "2", 0);
	formatex(String, charsmax(String), "%s \d[\r%d DB\d]", l_Nevek[2][0], Lada[2][id]);
	menu_additem(menu, String, "3", 0);
	formatex(String, charsmax(String), "%s \d[\r%d DB\d]", l_Nevek[3][0], Lada[3][id]);
	menu_additem(menu, String, "4", 0);
	formatex(String, charsmax(String), "%s \d[\r%d DB\d]", l_Nevek[4][0], Lada[4][id]);
	menu_additem(menu, String, "5", 0);
	formatex(String, charsmax(String), "%s \d[\r%d DB\d]", l_Nevek[5][0], Lada[5][id]);
	menu_additem(menu, String, "6", 0);
	formatex(String, charsmax(String), "%s \d[\r%d DB\d]", l_Nevek[6][0], Lada[6][id]);
	menu_additem(menu, String, "7", 0);

menu_display(id, menu, 0);
}

public Lada_h(id, menu, item){
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return;
	}
	
	new data[9], szName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
	new key = str_to_num(data);
	
	switch(key)
	{
	case 0:
	{
	if(ajandekcsomag[id] > 0)
	{
		new Float:RandomSzam = random_float(0.01, 100.000);
		if(RandomSzam <= 100.000 && RandomSzam > 70.000)
		{
			Lada[5][id]++;
			ColorChat(id, GREY, "%s ^3Gratulálok,a markodat 1DB^4 %s ^3ütötte!", C_Prefix, l_Nevek[5]);
		}
		else if(RandomSzam <= 70.000 && RandomSzam > 40.000)
		{
			Lada[6][id]++;
			ColorChat(id, BLUE, "%s ^3Gratulálok,a markodat 1DB^4 %s ^3ütötte!", C_Prefix, l_Nevek[6]);
		}
		else if(RandomSzam <= 40.000 && RandomSzam > 15.000)
		{
			switch(random_num(1,2))
			{
			case 1:{
			Kulcs[id]++;
			ColorChat(id, BLUE, "%s ^3Gratulálok,a markodat 1DB^4 Kulcs ^3ütötte!", C_Prefix);
			}
			case 2:{
			SMS[id] += 2;
			}
			}
		}
		else
		{
			vipkupon[id]++;
			ColorChat(id, RED, "%s ^3Gratulálok,a markodat 1DB VIP kupon ütötte, raktárban megtalálható!", C_Prefix);
		}
	ajandekcsomag[id]--;
	}
	}
	case 1,2,3:
	{
	caseopen_q(id);
	caseid = key-1;
	}
	case 4,5,6:
	{
	caseopen_q(id);
	caseid = key-1;
	}
	case 7:
	{
	caseopen_q(id);
	caseid = key-1;
	}
}
	
}
public caseopen_q(id)
{
new String[121];
formatex(String, charsmax(String), "%s \r- \dLádaNyitás\r ^n[\y%s\r]", Prefix, l_Nevek[caseid][0]);
new menu = menu_create(String, "caseopen_q_h");
	formatex(String, charsmax(String), "\w»\yNyitás");
	menu_additem(menu, String, "1", 0);
	formatex(String, charsmax(String), "\wLáda Tartalma");
	menu_additem(menu, String, "2", 0);

menu_display(id, menu, 0);
}
public caseopen_q_h(id, menu, item){
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return;
	}
	
	new data[9], szName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
	new key = str_to_num(data);
	
	switch(key)
	{
	case 1:
	{
		if(Lada[caseid][id] >= 1 && Kulcs[id] >= 1)
		{
		Lada[caseid][id] --;
		Kulcs[id] --;
		KivLada[id] = caseid;
		new hangrandom = random_num(0,2);
		if(hangrandom == 0)
		client_cmd(id, "spk sound/LadaO1.wav");
		else if(hangrandom == 1)
		client_cmd(id, "spk sound/LadaO2.wav");
		else if(hangrandom == 2)
		client_cmd(id, "spk sound/LadaO3.wav");
		Talal(id);
		}
		else
		{
		LadaNyitas(id);
		ColorChat(id, GREEN, "%s ^1Nincs ládád vagy kulcsod", C_Prefix);
		}
	}
	case 2:
	{
	if(caseid == 0)
	show_motd(id, "addons/amxmodx/configs/ladak/0.txt", "Ládák Tartalma");
	else if(caseid == 1)
	show_motd(id, "addons/amxmodx/configs/ladak/1.txt", "Ládák Tartalma");
	else if(caseid == 2)
	show_motd(id, "addons/amxmodx/configs/ladak/2.txt", "Ládák Tartalma");
	else if(caseid == 3)
	show_motd(id, "addons/amxmodx/configs/ladak/3.txt", "Ládák Tartalma");
	else if(caseid == 4)
	show_motd(id, "addons/amxmodx/configs/ladak/4.txt", "Ládák Tartalma");
	else if(caseid == 5)
	show_motd(id, "addons/amxmodx/configs/ladak/5.txt", "Ládák Tartalma");
	else if(caseid == 6)
	show_motd(id, "addons/amxmodx/configs/ladak/6.txt", "Ládák Tartalma");
	}
	}
}


public Talal(id)
{
	new nev[32]; get_user_name(id, nev, 31);
	new Float:Szam = random_float(0.01,100.00);
	new FegyverID0 = random_num(8, 13);
	new FegyverID1 = random_num(8, 13);
	new FegyverID2 = random_num(8, 13);
	new FegyverID3 = random_num(8, 12);
	new FegyverID4 = random_num(8, 13);
	new FegyverID5 = random_num(8, 13);
	new FegyverID6 = random_num(8, 13);
	
	if(KivLada[id] == 0)
	{
		if(Szam >= 30.00 && Szam <= 100.00) //70%os esély
		{
			meglevoek[LadaDrop0[FegyverID0]][id]++;
			ColorChat(id, BLUE, "%s ^3NyitottĂˇl egy %s skint", C_Prefix, FegyverAdatok[LadaDrop0[FegyverID0]][Nev]);
		}
		else if(Szam > 10.00 && Szam < 30.00)//20%os esély
		{
			new liladrop = random_num(5,7);
			meglevoek[LadaDrop0[liladrop]][id]++;
			ColorChat(id, GREEN, "%s ^4NyitottĂˇl egy %s skint", C_Prefix, FegyverAdatok[LadaDrop0[liladrop]][Nev]);
		}
		else if(Szam > 2.00 && Szam < 10.00)//8%os esély
		{
			new pirosdrop = random_num(2,4);
			meglevoek[LadaDrop0[pirosdrop]][id]++;
			ColorChat(id, GREEN, "%s ^4NyitottĂˇl egy %s skint", C_Prefix, FegyverAdatok[LadaDrop0[pirosdrop]][Nev]);
		}
		else if(Szam > 0.45 && Szam < 2.00)//1,55%os esély
		{ 
			new sargadrop = random_num(0,1);
			meglevoek[LadaDrop0[sargadrop]][id]++;
			client_cmd(id, "spk sound/pbT_sounds/holyshit.wav");
			ColorChat(id, RED, "%s ^3NyitottĂˇl egy %s skint", C_Prefix, FegyverAdatok[LadaDrop0[sargadrop]][Nev]);
		}
		else if(Szam > 0.01 && Szam < 0.45)//0,44%os esély
		{ 
			new kesdropa = random_num(14,15);
			meglevoek[LadaDrop0[kesdropa]][id]++;
			ColorChat(id, GREEN, "%s ^1NyitottĂˇl egy %s skint", C_Prefix, FegyverAdatok[LadaDrop1[kesdropa]][Nev]);
		}
		else if(Szam >= 0.00 && Szam <= 0.01)//0,1%os esély
		{ 
			meglevoek[LadaDrop0[16]][id]++;
			ColorChat(id, GREY, "%s ^3NyitottĂˇl egy %s skint", C_Prefix, FegyverAdatok[LadaDrop0[16]][Nev]);
		}
	}
	
	else if(KivLada[id] == 1)
	{
		if(Szam >= 30.00 && Szam <= 100.00) //70%os esély
		{
			meglevoek[LadaDrop1[FegyverID1]][id]++;
			ColorChat(id, BLUE, "%s ^3NyitottĂˇl egy %s skint", C_Prefix, FegyverAdatok[LadaDrop1[FegyverID1]][Nev]);
		}
		else if(Szam > 10.00 && Szam < 30.00)//20%os esély
		{
			new liladrop = random_num(5,7);
			meglevoek[LadaDrop1[liladrop]][id]++;
			ColorChat(id, GREEN, "%s ^4NyitottĂˇl egy %s skint", C_Prefix, FegyverAdatok[LadaDrop1[liladrop]][Nev]);
		}
		else if(Szam > 2.00 && Szam < 10.00)//8%os esély
		{
			new pirosdrop = random_num(2,4);
			meglevoek[LadaDrop1[pirosdrop]][id]++;
			ColorChat(id, GREEN, "%s ^4NyitottĂˇl egy %s skint", C_Prefix, FegyverAdatok[LadaDrop1[pirosdrop]][Nev]);
		}
		else if(Szam > 0.45 && Szam < 2.00)//1,55%os esély
		{ 
			new sargadrop = random_num(0,1);
			meglevoek[LadaDrop1[sargadrop]][id]++;
			client_cmd(id, "spk sound/pbT_sounds/holyshit.wav");
			ColorChat(id, RED, "%s ^3NyitottĂˇl egy %s skint", C_Prefix, FegyverAdatok[LadaDrop1[sargadrop]][Nev]);
		}
		else if(Szam > 0.01 && Szam < 0.45)//0,44%os esély
		{ 
			new kesdropa = random_num(14,15);
			meglevoek[LadaDrop1[kesdropa]][id]++;
			ColorChat(id, GREEN, "%s ^1NyitottĂˇl egy %s skint", C_Prefix, FegyverAdatok[LadaDrop1[kesdropa]][Nev]);
		}
		else if(Szam >= 0.00 && Szam <= 0.01)//0,1%os esély
		{ 
			meglevoek[LadaDrop1[16]][id]++;
			ColorChat(id, GREY, "%s ^3NyitottĂˇl egy %s skint", C_Prefix, FegyverAdatok[LadaDrop1[16]][Nev]);
		}
	}
	else if(KivLada[id] == 2)
	{
		if(Szam >= 30.00 && Szam <= 100.00) //70%os esély
		{
			meglevoek[LadaDrop2[FegyverID2]][id]++;
			ColorChat(id, BLUE, "%s ^3NyitottĂˇl egy %s skint", C_Prefix, FegyverAdatok[LadaDrop2[FegyverID2]][Nev]);
		}
		else if(Szam > 10.00 && Szam < 30.00)//20%os esély
		{
			new liladrop = random_num(5,7);
			meglevoek[LadaDrop2[liladrop]][id]++;
			ColorChat(id, GREEN, "%s ^4NyitottĂˇl egy %s skint", C_Prefix, FegyverAdatok[LadaDrop2[liladrop]][Nev]);
		}
		else if(Szam > 2.00 && Szam < 10.00)//8%os esély
		{
			new pirosdrop = random_num(2,4);
			meglevoek[LadaDrop2[pirosdrop]][id]++;
			ColorChat(id, GREEN, "%s ^4NyitottĂˇl egy %s skint", C_Prefix, FegyverAdatok[LadaDrop2[pirosdrop]][Nev]);
		}
		else if(Szam > 0.45 && Szam < 2.00)//1,55%os esély
		{ 
			new sargadrop = random_num(0,1);
			meglevoek[LadaDrop2[sargadrop]][id]++;
			client_cmd(id, "spk sound/pbT_sounds/holyshit.wav");
			ColorChat(id, RED, "%s ^3NyitottĂˇl egy %s skint", C_Prefix, FegyverAdatok[LadaDrop2[sargadrop]][Nev]);
		}
		else if(Szam > 0.01 && Szam < 0.45)//0,44%os esély
		{ 
			new kesdropa = random_num(14,15);
			meglevoek[LadaDrop2[kesdropa]][id]++;
			ColorChat(id, GREEN, "%s ^1NyitottĂˇl egy %s skint", C_Prefix, FegyverAdatok[LadaDrop2[kesdropa]][Nev]);
		}
		else if(Szam >= 0.00 && Szam <= 0.01)//0,1%os esély
		{ 
			meglevoek[LadaDrop2[16]][id]++;

			ColorChat(id, GREY, "%s ^3NyitottĂˇl egy %s skint", C_Prefix, FegyverAdatok[LadaDrop2[16]][Nev]);
		}
	}	
	else if(KivLada[id] == 3)
	{
		if(Szam >= 30.00 && Szam <= 100.00) //70%os esély
		{
			meglevoek[LadaDrop3[FegyverID3]][id]++;
			ColorChat(id, BLUE, "%s ^3NyitottĂˇl egy %s skint", C_Prefix, FegyverAdatok[LadaDrop3[FegyverID3]][Nev]);
		}
		else if(Szam > 10.00 && Szam < 30.00)//20%os esély
		{
			new liladrop = random_num(5,7);
			meglevoek[LadaDrop3[liladrop]][id]++;
			ColorChat(id, GREEN, "%s ^4NyitottĂˇl egy %s skint", C_Prefix, FegyverAdatok[LadaDrop3[liladrop]][Nev]);
		}
		else if(Szam > 2.00 && Szam < 10.00)//8%os esély
		{
			new pirosdrop = random_num(2,4);
			meglevoek[LadaDrop3[pirosdrop]][id]++;
			ColorChat(id, GREEN, "%s ^4NyitottĂˇl egy %s skint", C_Prefix, FegyverAdatok[LadaDrop3[pirosdrop]][Nev]);
		}
		else if(Szam > 0.45 && Szam < 2.00)//1,55%os esély
		{ 
			new sargadrop = random_num(0,1);
			meglevoek[LadaDrop3[sargadrop]][id]++;
			client_cmd(id, "spk sound/pbT_sounds/holyshit.wav");
			ColorChat(id, RED, "%s ^3NyitottĂˇl egy %s skint", C_Prefix, FegyverAdatok[LadaDrop3[sargadrop]][Nev]);
		}
		else if(Szam > 0.01 && Szam < 0.45)//0,44%os esély
		{ 
			new kesdropa = random_num(13,14);
			meglevoek[LadaDrop3[kesdropa]][id]++;
			ColorChat(id, GREEN, "%s ^1NyitottĂˇl egy %s skint", C_Prefix, FegyverAdatok[LadaDrop3[kesdropa]][Nev]);
		}
		else if(Szam >= 0.00 && Szam <= 0.01)//0,1%os esély
		{ 
			meglevoek[LadaDrop3[15]][id]++;
			ColorChat(id, GREY, "%s ^3NyitottĂˇl egy %s skint", C_Prefix, FegyverAdatok[LadaDrop3[15]][Nev]);
		}
	}	
	else if(KivLada[id] == 4)
	{
		if(Szam >= 30.00 && Szam <= 100.00) //70%os esély
		{
			meglevoek[LadaDrop4[FegyverID4]][id]++;
			ColorChat(id, BLUE, "%s ^3NyitottĂˇl egy %s skint", C_Prefix, FegyverAdatok[LadaDrop4[FegyverID4]][Nev]);
		}
		else if(Szam > 10.00 && Szam < 30.00)//20%os esély
		{
			new liladrop = random_num(5,7);
			meglevoek[LadaDrop4[liladrop]][id]++;
			ColorChat(id, GREEN, "%s ^4NyitottĂˇl egy %s skint", C_Prefix, FegyverAdatok[LadaDrop4[liladrop]][Nev]);
		}
		else if(Szam > 2.00 && Szam < 10.00)//8%os esély
		{
			new pirosdrop = random_num(2,4);
			meglevoek[LadaDrop4[pirosdrop]][id]++;
			ColorChat(id, GREEN, "%s ^4NyitottĂˇl egy %s skint", C_Prefix, FegyverAdatok[LadaDrop4[pirosdrop]][Nev]);
		}
		else if(Szam > 0.45 && Szam < 2.00)//1,55%os esély
		{ 
			new sargadrop = random_num(0,1);
			meglevoek[LadaDrop4[sargadrop]][id]++;
			client_cmd(id, "spk sound/pbT_sounds/holyshit.wav");
			ColorChat(id, RED, "%s ^3NyitottĂˇl egy %s skint", C_Prefix, FegyverAdatok[LadaDrop4[sargadrop]][Nev]);
		}
		else if(Szam > 0.01 && Szam < 0.45)//0,44%os esély
		{ 
			new kesdropa = random_num(14,16);
			meglevoek[LadaDrop4[kesdropa]][id]++;
			ColorChat(id, GREEN, "%s ^1NyitottĂˇl egy %s skint", C_Prefix, FegyverAdatok[LadaDrop4[kesdropa]][Nev]);
		}
		else if(Szam >= 0.00 && Szam <= 0.01)//0,1%os esély
		{ 
			meglevoek[LadaDrop4[17]][id]++;
			ColorChat(id, GREY, "%s ^3NyitottĂˇl egy %s skint", C_Prefix, FegyverAdatok[LadaDrop4[17]][Nev]);
		}
	}
	else if(KivLada[id] == 5)
	{
		if(Szam >= 30.00 && Szam <= 100.00) //70%os esély
		{
			meglevoek[LadaDrop5[FegyverID5]][id]++;
			ColorChat(id, BLUE, "%s ^3NyitottĂˇl egy %s skint", C_Prefix, FegyverAdatok[LadaDrop5[FegyverID5]][Nev]);
		}
		else if(Szam > 10.00 && Szam < 30.00)//20%os esély
		{
			new liladrop = random_num(5,7);
			meglevoek[LadaDrop5[liladrop]][id]++;
			ColorChat(id, GREEN, "%s ^4NyitottĂˇl egy %s skint", C_Prefix, FegyverAdatok[LadaDrop5[liladrop]][Nev]);
		}
		else if(Szam > 2.00 && Szam < 10.00)//8%os esély
		{
			new pirosdrop = random_num(2,4);
			meglevoek[LadaDrop5[pirosdrop]][id]++;
			ColorChat(id, GREEN, "%s ^4NyitottĂˇl egy %s skint", C_Prefix, FegyverAdatok[LadaDrop5[pirosdrop]][Nev]);
		}
		else if(Szam > 0.45 && Szam < 2.00)//1,55%os esély
		{ 
			new sargadrop = random_num(0,1);
			meglevoek[LadaDrop5[sargadrop]][id]++;
			client_cmd(id, "spk sound/pbT_sounds/holyshit.wav");
			ColorChat(id, RED, "%s ^3NyitottĂˇl egy %s skint", C_Prefix, FegyverAdatok[LadaDrop5[sargadrop]][Nev]);
		}
		else if(Szam > 0.01 && Szam < 0.45)//0,44%os esély
		{ 
			new kesdropa = random_num(14,16);
			meglevoek[LadaDrop5[kesdropa]][id]++;

			ColorChat(id, GREEN, "%s ^1NyitottĂˇl egy %s skint", C_Prefix, FegyverAdatok[LadaDrop5[kesdropa]][Nev]);
		}
		else if(Szam >= 0.00 && Szam <= 0.01)//0,1%os esély
		{
			meglevoek[LadaDrop5[17]][id]++;
			client_cmd(id, "spk sound/pbT_sounds/godlike.wav");
			ColorChat(id, GREY, "%s ^3NyitottĂˇl egy %s skint", C_Prefix, FegyverAdatok[LadaDrop5[17]][Nev]);
		}
	}
	else if(KivLada[id] == 6)
	{
		if(Szam >= 30.00 && Szam <= 100.00) //70%os esély
		{
			meglevoek[LadaDrop6[FegyverID6]][id]++;
			ColorChat(id, BLUE, "%s ^3NyitottĂˇl egy %s skint", C_Prefix, FegyverAdatok[LadaDrop6[FegyverID6]][Nev]);
		}
		else if(Szam > 10.00 && Szam < 30.00)//20%os esély
		{
			new liladrop = random_num(5,7);
			meglevoek[LadaDrop6[liladrop]][id]++;
			ColorChat(id, GREEN, "%s ^4NyitottĂˇl egy %s skint", C_Prefix, FegyverAdatok[LadaDrop6[liladrop]][Nev]);
		}
		else if(Szam > 2.00 && Szam < 10.00)//8%os esély
		{
			new pirosdrop = random_num(2,4);
			meglevoek[LadaDrop6[pirosdrop]][id]++;
			ColorChat(id, GREEN, "%s ^4NyitottĂˇl egy %s skint", C_Prefix, FegyverAdatok[LadaDrop6[pirosdrop]][Nev]);
		}
		else if(Szam > 0.45 && Szam < 2.00)//1,55%os esély
		{ 
			new sargadrop = random_num(0,1);
			meglevoek[LadaDrop6[sargadrop]][id]++;
			ColorChat(id, RED, "%s ^3NyitottĂˇl egy %s skint", C_Prefix, FegyverAdatok[LadaDrop6[sargadrop]][Nev]);
		}
		else if(Szam > 0.01 && Szam < 0.45)//0,44%os esély
		{ 
			new kesdropa = random_num(14,16);
			meglevoek[LadaDrop6[kesdropa]][id]++;
			ColorChat(id, GREEN, "%s ^1NyitottĂˇl egy %s skint", C_Prefix, FegyverAdatok[LadaDrop6[kesdropa]][Nev]);
		}
		else if(Szam >= 0.00 && Szam <= 0.01)//0,1%os esély
		{ 
			meglevoek[LadaDrop6[17]][id]++;
			ColorChat(id, GREY, "%s ^3NyitottĂˇl egy %s skint", C_Prefix, FegyverAdatok[LadaDrop6[17]][Nev]);
		}
	}
	LadaNyitas(id);
}
public Raktar(id)
{
	new String[121];
	formatex(String, charsmax(String), "%s \r- \dRaktár", Prefix);
	new menu = menu_create(String, "Raktar_h");
	
	for(new i=0;i <= 120; i++)
	{
		if(meglevoek[i][id] > 0)
		{
			new Sor[6]; num_to_str(i, Sor, 5);
			formatex(String, charsmax(String), "%s \d[\r%d DB \d]", FegyverAdatok[i][Nev],meglevoek[i][id]);
			menu_additem(menu, String, Sor);
		}
	}
	for(new i=132;i <= 133; i++)
	{
		if(meglevoek[i][id] > 0)
		{
			new Sor[6]; num_to_str(i, Sor, 5);
			formatex(String, charsmax(String), "%s \d[\r%d DB \d]", FegyverAdatok[i][Nev],meglevoek[i][id]);
			menu_additem(menu, String, Sor);
		}
	}
	if(vipkupon[id] > 0)
	{
	formatex(String, charsmax(String), "\rVip Kupon\d(15 nap) [\r%d DB \d]", vipkupon[id]);
	menu_additem(menu, String, "134");
	}
	
	menu_display(id, menu, 0);
}
public Raktar_h(id, menu, item){
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return;
	}
	
	new data[9], szName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
	new key = str_to_num(data);
	
	if(key != 134)
	{
	if(FegyverAdatok[key][Type] == 0)
	{
		kivalasztott[id][AK47] = key;
	}
	else if(FegyverAdatok[key][Type] == 1)
	{
		kivalasztott[id][M4A1] = key;
	}
	else if(FegyverAdatok[key][Type] == 2)
	{
		kivalasztott[id][AWP] = key;
	}
	else if(FegyverAdatok[key][Type] == 3)
	{
		kivalasztott[id][FAMAS] = key;
	}
	else if(FegyverAdatok[key][Type] == 4)
	{
		kivalasztott[id][MP5NAVY] = key;
	}
	else if(FegyverAdatok[key][Type] == 5)
	{
		kivalasztott[id][GALIL] = key;
	}
	else if(FegyverAdatok[key][Type] == 6)
	{
		kivalasztott[id][SCOUT] = key;
	}
	else if(FegyverAdatok[key][Type] == 7)
	{
		kivalasztott[id][DEAGLE] = key;
	}
	else if(FegyverAdatok[key][Type] == 8)
	{
		kivalasztott[id][USP] = key;
	}
	else if(FegyverAdatok[key][Type] == 9)
	{
		kivalasztott[id][GLOCK18] = key;
	}
	else if(FegyverAdatok[key][Type] == 10)
	{
		kivalasztott[id][KNIFE] = key;
	}
	}
	else
	{
		vipkupon[id]--;
		Vip[id] = 1;
		ColorChat(id,RED,"%s ^1A vip kupon felhasználva lett!^3 -1 VIP kupon, +15Nap",C_Prefix);
		g_iVipTime[id] = get_systime( ) + VIPTIMEKUPON;
		sql_update_account(id);
	}
	
}
public Kuka(id)
{
	new String[121];
	formatex(String, charsmax(String), "%s \r- \dKuka", Prefix);
	new menu = menu_create(String, "Kuka_h");
	
	for(new i=0;i <= 120; i++)
	{
		if(meglevoek[i][id] > 0)
		{
			new Sor[6]; num_to_str(i, Sor, 5);
			formatex(String, charsmax(String), "%s \d[\r%d DB\d]", FegyverAdatok[i][Nev], meglevoek[i][id]);
			menu_additem(menu, String, Sor);
		}
	}
	menu_display(id, menu, 0);
}
public Kuka_h(id, menu, item){
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return;
	}
	
	new data[9], szName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
	new key = str_to_num(data);
	
	meglevoek[key][id] --;
	
	if(FegyverAdatok[key][Type] == 0)
	{
	kivalasztott[id][AK47] = 121;
	}
	else if(FegyverAdatok[key][Type] == 1)
	{
	kivalasztott[id][M4A1] = 122;
	}
	else if(FegyverAdatok[key][Type] == 2)
	{
	kivalasztott[id][AWP] = 123;
	}
	else if(FegyverAdatok[key][Type] == 3)
	{
	kivalasztott[id][FAMAS] = 124;
	}
	else if(FegyverAdatok[key][Type] == 4)
	{
	kivalasztott[id][MP5NAVY] = 125;
	}
	else if(FegyverAdatok[key][Type] == 5)
	{
	kivalasztott[id][GALIL] = 126;
	}
	else if(FegyverAdatok[key][Type] == 6)
	{
	kivalasztott[id][SCOUT] = 127;
	}
	else if(FegyverAdatok[key][Type] == 7)
	{
	kivalasztott[id][DEAGLE] = 128;
	}
	else if(FegyverAdatok[key][Type] == 8)
	{
	kivalasztott[id][USP] = 129;
	}
	else if(FegyverAdatok[key][Type] == 9)
	{
	kivalasztott[id][GLOCK18] = 130;
	}
	else if(FegyverAdatok[key][Type] == 10)
	{
	kivalasztott[id][KNIFE] = 131;
	}
	ColorChat(id, GREEN, "%s ^1Törölted a ^4%s ^1skined", C_Prefix, FegyverAdatok[key][Nev]);
	Kuka(id);
}
public Piac(id)
{
	new String[121],String2[121];
	static iTime;
	iTime = g_iTime[id] - get_systime( );
	format(String, charsmax(String), "%s \r- \dPiac^n\dDollár: \r%3.2f $", Prefix, Dollar[id]);
	new menu = menu_create(String, "Piac_h");
	
	if(iTime <= 0)
	{
		if(Vip[id] == 1)
		{
		formatex(String2, charsmax(String2), "\r» \yNapi pörgetés\r [2DB]\y*VIP");
		menu_additem(menu, String2, "1", 0);
		}
		else
		{
		formatex(String2, charsmax(String2), "\r» \yNapi pörgetés\r [1DB]");
		menu_additem(menu, String2, "1", 0);
		}
	}
	else
	{
	formatex(String2, charsmax(String2), "\r» \yNapi pörgetés\r [\w%d \yó\r|\w%02d \yp Még\r]", iTime / 3600, ( iTime / 60) % 60);
	menu_additem(menu, String2, "1", 0);
	}
	menu_additem(menu, "\r» \yFegyver Eladás", "6", 0);
	menu_additem(menu, "\r» \yFegyver Vásárlás", "2", 0);
	menu_additem(menu, "\r» \yTárgyak Küldése", "3", 0);
	menu_additem(menu, "\r» \ySzerver Bolt", "4", 0);
	menu_additem(menu, "\r» \yKereskedés", "5", 0);

	
	menu_display(id, menu, 0);
}
public Piac_h(id, menu, item){
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return;
	}
	
	new data[9], szName[64];
	new access, callback;
	static iTime;
	iTime = g_iTime[id] - get_systime( );
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
	new key = str_to_num(data);
	
	switch(key)
	{
		case 1:
		{
		if(iTime <= 0)
		{
			sorsolas(id);
		}
		else
		{
			ColorChat(id,RED,"%s ^3Te elérted a pörgetési limitet!",C_Prefix);
		}
		}
		case 2:
		{
		kicucc[id] = -1;
		Eladas(id);
		}
		case 3: Vasarlas(id);
		case 4: SendMenu(id);
		case 5: szerverbolt(id);
		case 6: KereskedesMenu(id);
	}
}

public sorsolas(id)
{
	switch(random_num(1,5))
	{
		case 1:
		{
			ColorChat(id,BLUE,"Gratulálok!^4 3 DB kulcs ^3ütötte a markodat!");
			Kulcs[id] += 3;
		}
		case 2:
		{
			ColorChat(id,RED,"Ez nem a te napod! :[");
		}
		case 3:
		{
			ColorChat(id,BLUE,"Gratulálok!^4 + 4,50$ ^3ütötte a markodat!");
			Dollar[id] += 4.50;
		}
		case 4:
		{
			ColorChat(id,RED,"Ez nem a te napod! :[");
		}
		case 5:
		{
			ColorChat(id,RED,"Ez nem a te napod! :[");
		}
		case 6:
		{
			new randomszam = random_num(0,5);
			Lada[randomszam][id]++;
			ColorChat(id,BLUE,"Gratulálok!^4 1DB %s ^3ütötte a markodat!",l_Nevek[randomszam]);
		}
	}
vip_porgetes++;
if(Vip[id] == 1 && vip_porgetes <= 1)
{
	Piac(id);
}
else
{
g_iTime[id] = get_systime( ) + 86400;
}
sql_update_account(id);
}

public szerverbolt(id)
{
new String[256];
format(String, charsmax(String), "%s \r- \ySzerver Bolt^nDollár:\r %3.2f $", Prefix,Dollar[id]);
new menu = menu_create(String, "szerverbolth");

menu_additem(menu, "\w»\y1DB Kulcs\r(\y1,45$\r)", "1", 0);
menu_additem(menu, "\w»\Skinek Boltja\r", "2", 0);
menu_additem(menu, "\w»\yLáda Vásárlás\r", "3", 0);
menu_additem(menu, "\w»\yLáda Váeladás\", "4", 0);
menu_additem(menu, "\w»\yVicces Cuccok/later\r", "5", 0);


	menu_display(id, menu, 0);
}
public szerverbolth(id, menu, item){

new data[9], szName[64];
new access, callback;
menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
new key = str_to_num(data);

switch(key) 
	{
}
	switch(random_num(1,5))
	{
		case 1:
		{
			if(Dollar[id] >= 1.45)
			{
			Dollar[id] -= 1.45;
			Kulcs[id]++;
			ColorChat(id,BLUE,"%s ^3Sikeresen vettél^4 1 Kulcs^3-ot!",C_Prefix);
			}
			else
			{
			ColorChat(id,RED,"%s ^3Nincs elég dollárod!",C_Prefix);
		case 2: skinshop(id);
		case 3: ladavesz(id);
		case 4:	ladaelad(id);
	/*	case 5:
		{
		funny(id);*/
		}
	}
}
public ladaelad(id)
{
new String[256];
format(String, charsmax(String), "%s \r- \yTárgyak vásárlása^nDollár:\r %3.2f $", Prefix,Dollar[id]);
new menu = menu_create(String, "ladaelad");

menu_additem(menu, "\w»\yBronz Láda\r(\y0,10$\r)", "1", 0);
menu_additem(menu, "\w»\ySzínözön Láda\r(\y0,10$\r)", "2", 0);
menu_additem(menu, "\w»\yFalchion Láda\r(\y0,100$\r)", "3", 0);
menu_additem(menu, "\w»\yOperation Breakout Láda\r(\0,10$\r)", "4", 0);
menu_additem(menu, "\w»\yPhoenix Láda\r(\y0,10$\r)", "5", 0);
menu_additem(menu, "\w»\yHuntsman Láda\r(\y0,10$\r)", "6", 0);
menu_additem(menu, "\w»\yÁrnyék Láda\r(\y0,10$\r)", "7", 0);

menu_display(id, menu, 0);
}
public ladaelad(id, menu, item){
if(item == MENU_EXIT)
{
menu_destroy(menu);
return;
}

new data[9], szName[64];
new access, callback;
menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
new key = str_to_num(data);

switch(key) 
	{
		case 1: 
		{
			if(Dollar[id] <= 3.00)
			{
			Lada[0][id]++;
			Dollar[id] =- 3.00;
			ColorChat(id,BLUE,"%s ^3Sikeresen vettél^4 1 Bronz Ládát^3!",C_Prefix);
			}
			else
			{
			ColorChat(id,RED,"%s ^3Nincs elég dollárod!",C_Prefix);
			}
		}
		case 2: 
		{
			if(Dollar[id] >= 3.00)
			{
			Lada[1][id]++;
			Dollar[id] -= 3.00;
			ColorChat(id,BLUE,"%s ^3Sikeresen vettél^4 1 Színözön Ládát^3!",C_Prefix);
			}
			else
			{
			ColorChat(id,RED,"%s ^3Nincs elég dollárod!",C_Prefix);
			}
		}
		case 3: 
		{
			if(Dollar[id] >= 3.00)
			{
			Lada[2][id]++;
			Dollar[id] -= 3.00;
			ColorChat(id,BLUE,"%s ^3Sikeresen vettél^4 1 Falchion Ládát^3!",C_Prefix);
			}
			else
			{
			ColorChat(id,RED,"%s ^3Nincs elég dollárod!",C_Prefix);
			}
		}
		case 4: 
		{
			if(Dollar[id] >= 3.00)
			{
			Lada[3][id]++;
			Dollar[id] -= 3.00;
			ColorChat(id,BLUE,"%s ^3Sikeresen vettél^4 1 Operation Breakout Ládát^3!",C_Prefix);
			}
			else
			{
			ColorChat(id,RED,"%s ^3Nincs elég dollárod!",C_Prefix);
			}
		}
		case 5: 
		{
			if(Dollar[id] >= 3.00)
			{
			Lada[4][id]++;
			Dollar[id] -= 3.00;
			ColorChat(id,BLUE,"%s ^3Sikeresen vettél^4 1 Phoenix Ládát^3!",C_Prefix);
			}
			else
			{
			ColorChat(id,RED,"%s ^3Nincs elég dollárod!",C_Prefix);
			}
		}
		case 6: 
		{
			if(Dollar[id] >= 3.00)
			{
			Lada[5][id]++;
			Dollar[id] -= 3.00;
			ColorChat(id,BLUE,"%s ^3Sikeresen vettél^4 1 Huntsman Ládát^3!",C_Prefix);
			}
			else
			{
			ColorChat(id,RED,"%s ^3Nincs elég dollárod!",C_Prefix);
			}
		}
		case7: 
		{
			if(Dollar[id] >= 5.00)
			{
			Lada[6][id]++;
			Dollar[id] -= 5.00;
			ColorChat(id,BLUE,"%s ^3Sikeresen vettél^4 1 Árnyék Ládát^3!",C_Prefix);
			}
			else
			{
			ColorChat(id,RED,"%s ^3Nincs elég dollárod!",C_Prefix);
			}
		}
		 
	}
	ladavesz(id);
}
	ladaelad(id);
}	
public ladavesz(id)
{
new String[256];
format(String, charsmax(String), "%s \r- \yTárgyak vásárlása^nDollár:\r %3.2f $", Prefix,Dollar[id]);
new menu = menu_create(String, "ladaveszh");

menu_additem(menu, "\w»\yBronz Láda\r(\y3.00$\r)", "1", 0);
menu_additem(menu, "\w»\ySzínözön Láda\r(\y3.00$\r)", "2", 0);
menu_additem(menu, "\w»\yFalchion Láda\r(\y3.00$\r)", "3", 0);
menu_additem(menu, "\w»\yOperation Breakout Láda\r(\3.00$\r)", "4", 0);
menu_additem(menu, "\w»\yPhoenix Láda\r(\y3.00$\r)", "5", 0);
menu_additem(menu, "\w»\yHuntsman Láda\r(\y3.00$\r)", "6", 0);
menu_additem(menu, "\w»\yÁrnyék Láda\r(\y3.00$\r)", "7", 0);

menu_display(id, menu, 0);
}
public ladaveszh(id, menu, item){
if(item == MENU_EXIT)
{
menu_destroy(menu);
return;
}

new data[9], szName[64];
new access, callback;
menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
new key = str_to_num(data);

switch(key) 
	{
		case 1: 
		{
			if(Dollar[id] >= 3.00)
			{
			Lada[0][id]++;
			Dollar[id] -= 3.00;
			ColorChat(id,BLUE,"%s ^3Sikeresen vettél^4 1 Bronz Ládát^3!",C_Prefix);
			}
			else
			{
			ColorChat(id,RED,"%s ^3Nincs elég dollárod!",C_Prefix);
			}
		}
		case 2: 
		{
			if(Dollar[id] >= 3.00)
			{
			Lada[1][id]++;
			Dollar[id] -= 3.00;
			ColorChat(id,BLUE,"%s ^3Sikeresen vettél^4 1 Színözön Ládát^3!",C_Prefix);
			}
			else
			{
			ColorChat(id,RED,"%s ^3Nincs elég dollárod!",C_Prefix);
			}
		}
		case 3: 
		{
			if(Dollar[id] >= 3.00)
			{
			Lada[2][id]++;
			Dollar[id] -= 3.00;
			ColorChat(id,BLUE,"%s ^3Sikeresen vettél^4 1 Falchion Ládát^3!",C_Prefix);
			}
			else
			{
			ColorChat(id,RED,"%s ^3Nincs elég dollárod!",C_Prefix);
			}
		}
		case 4: 
		{
			if(Dollar[id] >= 3.00)
			{
			Lada[3][id]++;
			Dollar[id] -= 3.00;
			ColorChat(id,BLUE,"%s ^3Sikeresen vettél^4 1 Operation Breakout Ládát^3!",C_Prefix);
			}
			else
			{
			ColorChat(id,RED,"%s ^3Nincs elég dollárod!",C_Prefix);
			}
		}
		case 5: 
		{
			if(Dollar[id] >= 3.00)
			{
			Lada[4][id]++;
			Dollar[id] -= 3.00;
			ColorChat(id,BLUE,"%s ^3Sikeresen vettél^4 1 Phoenix Ládát^3!",C_Prefix);
			}
			else
			{
			ColorChat(id,RED,"%s ^3Nincs elég dollárod!",C_Prefix);
			}
		}
		case 6: 
		{
			if(Dollar[id] >= 3.00)
			{
			Lada[5][id]++;
			Dollar[id] -= 3.00;
			ColorChat(id,BLUE,"%s ^3Sikeresen vettél^4 1 Huntsman Ládát^3!",C_Prefix);
			}
			else
			{
			ColorChat(id,RED,"%s ^3Nincs elég dollárod!",C_Prefix);
			}
		}
		case7: 
		{
			if(Dollar[id] >= 5.00)
			{
			Lada[6][id]++;
			Dollar[id] -= 5.00;
			ColorChat(id,BLUE,"%s ^3Sikeresen vettél^4 1 Árnyék Ládát^3!",C_Prefix);
			}
			else
			{
			ColorChat(id,RED,"%s ^3Nincs elég dollárod!",C_Prefix);
			}
		}
		 
	}
	ladavesz(id);
}
public Eladas(id) {
	new cim[121], ks1[121], ks2[121];
	format(cim, charsmax(cim), "%s \r- \dEladás", Prefix);
	new menu = menu_create(cim, "eladas_h" );
	
	
	if(kirakva[id] == 0){
		for(new i=0; i <= 120; i++) {
			if(kicucc[id] == -1) format(ks1, charsmax(ks1), "Válaszd ki a Tárgyat!");
			else if(kicucc[id] == i) format(ks1, charsmax(ks1), "Tárgy: \r%s", PiacTargy[i]);
		}
		menu_additem(menu, ks1 ,"0",0);
	}
	if(kirakva[id] == 0){
		format(ks2, charsmax(ks2), "\dÁra: \r%3.2f \yDOLLÁR", Erteke[id]);
		menu_additem(menu,ks2,"1",0);
	}
	if(Erteke[id] != 0 && kirakva[id] == 0)
	{
		menu_additem(menu,"Mehet a piacra!","2",0);
	}
	if(Erteke[id] != 0 && kirakva[id] == 1)
		menu_additem(menu,"\wVisszavonás","-2",0);
	
	menu_setprop(menu, MPROP_EXITNAME, "Kilépés");
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	menu_display(id, menu, 0);
}
public eladas_h(id, menu, item){
	if( item == MENU_EXIT )
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	new data[9], szName[64], name[32];
	get_user_name(id, name, charsmax(name));
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
	new key = str_to_num(data);
	
	switch(key)
	{
		case -2:{
			kirakva[id] = 0;
			kicucc[id] = 0;
			Erteke[id] = 0.0;
		}
		case 0:{
			fvalaszt(id);
		}
		case 1:{
			client_cmd(id, "messagemode DOLLAR");
		}
		case 2:{
			for(new i=0; i <= 120; i++)
			{
				if(kicucc[id] == i) //&& meglevoek[i][id] >= 1
				{
					ColorChat(0, GREEN, "%s ^3%s ^1Kirakott egy ^4%s^1 nevü itemet^4 %3.2f ^1dollárért", C_Prefix, name, PiacTargy[i], Erteke[id]);
					kirakva[id] = 1;
				}
			}
		}
	}
	return PLUGIN_HANDLED;
}

public Vasarlas(id)
{      
	new mpont[512], menu, cim[121];
	static players[32],temp[10],pnum;  
	get_players(players,pnum,"c");
	
	format(cim, charsmax(cim), "%s \r- \dVásárlás^nDollár: \r%3.2f $", Prefix, Dollar[id]);
	menu = menu_create(cim, "vasarlas_h" );
	
	for (new i; i < pnum; i++)
	{
		if(kirakva[players[i]] == 1 && Erteke[players[i]] > 0)
		{
			for(new a=0; a <= 120; a++) {
				if(kicucc[players[i]] == a)
					formatex(mpont,256,"\y%s \w%s\d[Ára: \r%3.2f $\d]", PiacTargy[a],get_player_name(players[i]), Erteke[players[i]]);
			}
			
			num_to_str(players[i],temp,charsmax(temp));
			menu_additem(menu, mpont, temp);
		}
	}
	menu_setprop(menu, MPROP_PERPAGE, 6);
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL );
	menu_display(id, menu);
	return PLUGIN_HANDLED;
}  
public vasarlas_h(id,menu, item){
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return;
	}
	if(pido != 0){
		Vasarlas(id);
		return;
	}
	new data[6] ,szName[64],access,callback;
	new name[32], name2[32];
	get_user_name(id, name, charsmax(name));
	
	menu_item_getinfo(menu, item, access, data, charsmax(data), szName, charsmax(szName), callback);
	
	new player = str_to_num(data);
	get_user_name(player, name2, charsmax(name2));
	pido = 2;
	set_task(2.0, "vido");
	
	for(new i=0; i <= 120; i++) {
		if(Dollar[id] >= Erteke[player] && kicucc[player] == i && kirakva[player] == 1)
		{
			kirakva[player] = 0;
			ColorChat(0, GREEN, "%s ^3%s ^1vett egy ^4%s^1-t ^3%s^1-tól ^4%3.2f ^1Dollárért!",C_Prefix, name, PiacTargy[i], name2, Erteke[player]);
			Dollar[player] += Erteke[player];
			Dollar[id] -= Erteke[player];
			meglevoek[i][id] ++;
			meglevoek[i][player] --;
			kicucc[player] = 0;
			Erteke[player] = 0.0;
	if(FegyverAdatok[kicucc[id]][Type] == 0)
	{
		kivalasztott[id][AK47] = 121;
	}
	else if(FegyverAdatok[kicucc[id]][Type] == 1)
	{
		kivalasztott[id][M4A1] = 122;
	}
	else if(FegyverAdatok[kicucc[id]][Type] == 2)
	{
		kivalasztott[id][AWP] = 123;
	}
	else if(FegyverAdatok[kicucc[id]][Type] == 3)
	{
		kivalasztott[id][FAMAS] = 124;
	}
	else if(FegyverAdatok[kicucc[id]][Type] == 4)
	{
		kivalasztott[id][MP5NAVY] = 125;
	}
	else if(FegyverAdatok[kicucc[id]][Type] == 5)
	{
		kivalasztott[id][GALIL] = 126;
	}
	else if(FegyverAdatok[kicucc[id]][Type] == 6)
	{
		kivalasztott[id][SCOUT] = 127;
	}
	else if(FegyverAdatok[kicucc[id]][Type] == 7)
	{
		kivalasztott[id][DEAGLE] = 128;
	}
	else if(FegyverAdatok[kicucc[id]][Type] == 8)
	{
		kivalasztott[id][USP] = 129;
	}
	else if(FegyverAdatok[kicucc[id]][Type] == 9)
	{
		kivalasztott[id][GLOCK18] = 130;
	}
	else if(FegyverAdatok[kicucc[id]][Type] == 10)
	{
		kivalasztott[id][KNIFE] = 131;
	}
		}
		}
	}
	stock get_player_name(id){
static name[32];
get_user_name(id,name,31);
return name;
}
	
public fvalaszt(id) {
	new szMenuTitle[ 121 ],cim[121];
	format( szMenuTitle, charsmax( szMenuTitle ), "%s \r- \dVálassz Fegyvert", Prefix);
	new menu = menu_create( szMenuTitle, "fvalaszt_h" );
	
	for(new i=0; i <= 120; i++) {
		if(meglevoek[i][id] > 0) {
			new Num[6];
			num_to_str(i, Num, 5);
			formatex(cim, charsmax(cim), "%s \d[\r%d DB\d]", PiacTargy[i],meglevoek[i][id]);
			menu_additem(menu, cim, Num);
		}
	}
	
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	menu_display(id, menu, 0);
	
}
public fvalaszt_h(id, menu, item){
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return;
	}
	new data[9], szName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
	new key = str_to_num(data);
	
	kicucc[id] = key;
	
	Eladas(id);
}
public SendMenu(id) 
{
	new String[121];
	format(String, charsmax(String), "%s \r- \dTárgyak Küldése", Prefix);
	new menu = menu_create(String, "SendHandler");
	
	format(String, charsmax(String), "Dollár \d[\r%3.2f $\d]", Dollar[id]);
	menu_additem(menu, String, "0", 0);
	format(String, charsmax(String), "Kulcs \d[\r%d DB\d]", Kulcs[id]);
	menu_additem(menu, String, "1", 0);
	format(String, charsmax(String), "SMS Pont \d[\r%d DB\d]", SMS[id]);
	menu_additem(menu, String, "2", 0);
	format(String, charsmax(String), "%s \d[\r%d DB\d]", l_Nevek[0], Lada[0][id]);
	menu_additem(menu, String, "3", 0);
	format(String, charsmax(String), "%s \d[\r%d DB\d]", l_Nevek[1], Lada[1][id]);
	menu_additem(menu, String, "4", 0);
	format(String, charsmax(String), "%s \d[\r%d DB\d]", l_Nevek[2], Lada[2][id]);
	menu_additem(menu, String, "5", 0);
	format(String, charsmax(String), "%s \d[\r%d DB\d]", l_Nevek[3], Lada[3][id]);
	menu_additem(menu, String, "6", 0);
	format(String, charsmax(String), "%s \d[\r%d DB\d]", l_Nevek[4], Lada[4][id]);
	menu_additem(menu, String, "7", 0);
	format(String, charsmax(String), "%s \d[\r%d DB\d]", l_Nevek[5], Lada[5][id]);
	menu_additem(menu, String, "8", 0);
	format(String, charsmax(String), "%s \d[\r%d DB\d]", l_Nevek[6], Lada[6][id]);
	menu_additem(menu, String, "9", 0);
	format(String, charsmax(String), "Fegyverek küldése");
	menu_additem(menu, String, "10", 0);
	
	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}
public SendHandler(id, Menu, item) {
	if(item == MENU_EXIT)
	{
		menu_destroy(Menu);
		return PLUGIN_HANDLED;
	}
	
	new Data[9], szName[64];
	new access, callback;
	menu_item_getinfo(Menu, item, access, Data,charsmax(Data), szName,charsmax(szName), callback);
	new Key = str_to_num(Data);
	
	Send[id] = Key+1;
	
	PlayerChoose(id);
	return PLUGIN_HANDLED;
}
public PlayerChoose(id)
{
	new String[121];
	format(String, charsmax(String), "%s \r- \dVálassz Játékost", Prefix);
	new Menu = menu_create(String, "PlayerHandler");
	
	new players[32], pnum, tempid;
	new szName[32], szTempid[10];
	get_players(players, pnum);
	for( new i; i<pnum; i++ )
	{
		tempid = players[i];
		{
			get_user_name(tempid, szName, charsmax(szName));
			num_to_str(tempid, szTempid, charsmax(szTempid));
			menu_additem(Menu, szName, szTempid, 0);
		}
	}
	
	menu_display(id, Menu, 0);
	return PLUGIN_HANDLED;
}
public PlayerHandler(id, Menu, item)
{
	if( item == MENU_EXIT )
	{
		menu_destroy(Menu);
		return PLUGIN_HANDLED;
	}
	new Data[6], szName[64];
	new access, callback;
	menu_item_getinfo(Menu, item, access, Data,charsmax(Data), szName,charsmax(szName), callback);
	TempID = str_to_num(Data);
	
	if(addolasikulcs == 1000)
	{
	if(accountpause == 1)
	{
	client_cmd(id, "messagemode FUGGESZTESI_INDOK");
	}
	else if(accountpause == 0)
	{
	sqltorolfelfuggesztfiok(id);
	}
	}
	else
	client_cmd(id, "messagemode KMENNYISEG");
	
	menu_destroy(Menu);
	return PLUGIN_HANDLED;
}
public sqltorolfelfuggesztfiok(id)
{	
	static Query[256];
	
	new a[191];
	
	format(a, 190, "%s", g_Felhasznalonev[TempID]);
	
	replace_all(a, 190, "\", "\\");
	replace_all(a, 190, "'", "\'");
	
	formatex(Query, charsmax(Query), "UPDATE rwt_sql_register_new_s5 SET AccountPause = '0', AccountPauseReason = ' ', AccountPauseAdmin = ' ' WHERE Felhasznalonev = '%s'", a);
	
	new Data[2];
	Data[0] = id;
	Data[1] = get_user_userid(id);
	
	SQL_ThreadQuery(g_SqlTuple, "sqltorolfelfuggesztfiok_thread", Query, Data, 2);
}
public sqltorolfelfuggesztfiok_thread(FailState,Handle:Query,Error[],Errcode,Data[],DataSize)
{
	if(FailState == TQUERY_CONNECT_FAILED)
		return set_fail_state("[ *HIBA* ] NEM LEHET KAPCSOLODNI AZ ADATBAZISHOZ!");
	else if(FailState == TQUERY_QUERY_FAILED)
		return set_fail_state("[ *HIBA* ] A LEKERDEZES MEGSZAKADT!");
	
	if(Errcode)
		return log_amx("[ *HIBA* ] PROBLEMA A LEKERDEZESNEL! ( %s )",Error);
		
		new id = Data[0];
		
		if(Data[1] != get_user_userid(id))
		return PLUGIN_HANDLED;
		
		ColorChat(id,BLUE,"%s^4 %s ^1Címzetü fiók fel lett^3 oldva^1!",C_Prefix,g_Felhasznalonev[TempID]);
	
	return PLUGIN_CONTINUE;
}


public sqlfelfuggesztfiok(id)
{	
	static Query[256];
	
	new a[191], b[191];
	new adminnev[33];
	get_user_name(id, adminnev,charsmax(adminnev));
	
	format(a, 190, "%s", g_Felhasznalonev[TempID]);
	format(b, 190, "%s", g_Indok[id]);
	
	replace_all(a, 190, "\", "\\");
	replace_all(a, 190, "'", "\'");
	replace_all(b, 190, "\", "\\");
	replace_all(b, 190, "'", "\'");
	
	formatex(Query, charsmax(Query), "UPDATE rwt_sql_register_new_s5 SET AccountPause = '1', AccountPauseReason = '%s', AccountPauseAdmin = '%s' WHERE Felhasznalonev = '%s'", b, adminnev,a);
	
	new Data[2];
	Data[0] = id;
	Data[1] = get_user_userid(id);
	
	SQL_ThreadQuery(g_SqlTuple, "sql_account_pause_thread", Query, Data, 2);
}
public sql_account_pause_thread(FailState,Handle:Query,Error[],Errcode,Data[],DataSize)
{
	if(FailState == TQUERY_CONNECT_FAILED)
		return set_fail_state("[ *HIBA* ] NEM LEHET KAPCSOLODNI AZ ADATBAZISHOZ!");
	else if(FailState == TQUERY_QUERY_FAILED)
		return set_fail_state("[ *HIBA* ] A LEKERDEZES MEGSZAKADT!");
	
	if(Errcode)
		return log_amx("[ *HIBA* ] PROBLEMA A LEKERDEZESNEL! ( %s )",Error);
		
		new id = Data[0];
		
		if(Data[1] != get_user_userid(id))
		return PLUGIN_HANDLED;
		
		g_Bejelentkezve[TempID] = false;
		new adminnev[33];
		get_user_name(id,adminnev,charsmax(adminnev));
		ColorChat(id,TEAM_COLOR,"%s^4 %s ^1Címzetü fiók fel lett függesztve!^3 ||^1Indok:^4 %s",C_Prefix,g_Felhasznalonev[TempID],g_Indok[id]);
		ColorChat(TempID,RED,"%s ^3Fiókod fel lett függesztve!^1 ||^3Indok:^4 %s ^1||^3Admin:^4 %s",C_Prefix,g_Indok[id],adminnev);
	
	return PLUGIN_CONTINUE;
}


public KereskedesMenu(id) {
	if(KerDB[id] == 0)
	{
		Targy[id] = -1;
	}
	new String[96], kid, menu, kNev[32];
	
	if(JelolID[id] > 0)
		kid = JelolID[id]   ;
	else
		kid = KerID[id];
	get_user_name(kid, kNev, 31);

	
	if(Keres[id] == 1) {
		format(String, charsmax(String), "\r%s\y szeretne veled kereskedni!", kNev);
	}
	else if(Kereskedik[id] == 1 && Kereskedik[kid] == 1)  {
		format(String, charsmax(String), "\d- \y%s \rtárgyai \d-", kNev);
	}
	else 
	{
		format(String, charsmax(String), "\wKereskedés \rDollár:\d %3.2f$", Dollar[id]);
	}
	
	menu = menu_create(String, "KereskedesMenuh" );
	
	if(Keres[id] == 1) {
		format(String, charsmax(String), "\yElfogad");
		menu_additem(menu, String, "-3");
		
		format(String, charsmax(String), "\yElutasít");
		menu_additem(menu, String, "-2");
	}
	else if(Kereskedik[id] == 1 && Kereskedik[kid] == 1) {
		
		if(Targy[kid] == -1)
			format(String, charsmax(String), "\dSemmi");
		else if(Targy[kid] >= 0)
			format(String, charsmax(String), "\y%s \r(\d%d\r darab)", PiacTargy[Targy[kid]], KerDB[kid]);
		menu_additem(menu, String, "0");
		format(String, charsmax(String), "\rDollár: \d%3.2f$^n^n", KerDollar[kid]);
		menu_additem(menu, String, "0");
		
		if(Targy[id] == -1)
			format(String, charsmax(String), "\dSemmi");
		else if(Targy[id] >= 0)
			format(String, charsmax(String), "\y%s \r(\d%d\r darab)", PiacTargy[Targy[id]], KerDB[id]);
		menu_additem(menu, String, "-4");
		
		format(String, charsmax(String), "\rDollár: \d%3.2f$^n", KerDollar[id]);
		menu_additem(menu, String, "-5");
		
		format(String, charsmax(String), "\yElfogad");
		menu_additem(menu, String, "-6");
		
		format(String, charsmax(String), "\rElutasít");
		menu_additem(menu, String, "-7");
	}
	else /*if(KerID[id] == 0)*/ {
		for(new i; i < 33; i++)
		{
			new namefasz[32], NumToStr[6];
			if(is_user_connected(i))
			{
				if(i == id)
				continue;
				
				if(Keres[i] == 0 && Kereskedik[i] == 0)
				{
					get_user_name(i, namefasz, 32);
					num_to_str(i, NumToStr, 5);
					format(String, charsmax(String), "%s", namefasz);
					menu_additem(menu, String, NumToStr);
				}
			}
		}
	}

	menu_display(id, menu);
}
public KereskedesMenuh(id, menu, item){
	
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	
	new data[9], szName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
	new key = str_to_num(data);
	
	if(key <= 0)
	{
		switch(key)
		{
			case 0 : KereskedesMenu(id);
			case -3 : {
				Keres[id] = 0;
				Kereskedik[id] = 1;
				
				new kid;
				if(JelolID[id] > 0)
					kid = JelolID[id];
				else
					kid = KerID[id];
					
				Kereskedik[kid] = 1;
				ColorChat(kid,BLUE,"%s ^3A másik fél elfogadta a kereskedést!",C_Prefix);
				
				KerDB[id] = 0;
				KerDB[kid] = 0;
				
				kirakva[id] = 0;
				kirakva[kid] = 0;
					
				KereskedesMenu(id);
				KereskedesMenu(kid);
			}
			case -2 : {
				new kid;
				if(JelolID[id] > 0)
					kid = JelolID[id];
				else
					kid = KerID[id];
					ColorChat(kid,RED,"%s ^3A másik fél elutasította a kereskedést!",C_Prefix);
				Kereskedik[id] = 0;
				JelolID[id] = 0;
				Keres[id] = 0;
				Kereskedik[kid] = 0;
				KerID[kid] = 0;
			}
			
			case -4 : {
				KerFegyverek(id);
			}
			
			case -5 : {
				new Cmd[32];
				format(Cmd, charsmax(Cmd), "messagemode DOLLAR2");
				client_cmd(id, Cmd);
			}
			
			case -6 : {
				new kid;
				if(JelolID[id] > 0)
					kid = JelolID[id];
				else
					kid = KerID[id];
				Fogad[id] = 1;
				//ColorChat(id,BLUE,"%s ^3Várakozás a másik fél elfogadására...",C_Prefix);
				if(Fogad[id] == 1 && Fogad[kid] == 1)
				Csere(id, kid);
				else
				KereskedesMenu(id);
			}
			
			case -7 : {
				new kid;
				if(JelolID[id] > 0)
					kid = JelolID[id];
				else
					kid = KerID[id];
					
				Kereskedik[id] = 0;
				JelolID[id] = 0;
				Keres[id] = 0;
				KerID[id] = 0;
				Kereskedik[kid] = 0;
				JelolID[kid] = 0;
				Keres[kid] = 0;
				KerID[kid] = 0;
			}
		}
	}
	else
	{
		new String[128], namefasz[32];
		get_user_name(id, namefasz, 31);
		KerID[id] = key;
		message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, KerID[id]);
		write_byte(KerID[id]);
		format(String, charsmax(String), "4[*pbT#]^3 %s^1 szeretne veled kereskedni!", namefasz);
		write_string(String);
		message_end();
		ColorChat(id,BLUE,"^4[*pbT#]^3 Várakozás a másik fél választására...");
		KereskedesMenu(id);
		Keres[key] = 1;
		Keres[id] = 0;
		Kereskedik[id] = 0;
		JelolID[key] = id;
		set_task(30.0, "KerNulla", KerID[id]);
	}
	return PLUGIN_HANDLED;
}
public KerNulla(id) 
{
	if(is_user_connected(id))
	{
		if(Kereskedik[id] == 0)
		{
			Kereskedik[id] = 0;
			JelolID[id] = 0;
			Keres[id] = 0;
		}
	}
}
public Csere(x, y) {
	if(is_user_connected(x) && is_user_connected(y) ||
	Kereskedik[x] == 1 && Kereskedik[y] == 1  ||
	Fogad[x] == 1 && Fogad[y] == 1)
	{
		if(Targy[x] >= 0 && Targy[x] <= 120)
		{
			meglevoek[Targy[x]][x] -= KerDB[x];
			meglevoek[Targy[x]][y] += KerDB[x];
	if(FegyverAdatok[Targy[x]][Type] == 0)
	{
		kivalasztott[x][AK47] = 121;
	}
	else if(FegyverAdatok[Targy[x]][Type] == 1)
	{
		kivalasztott[x][M4A1] = 122;
	}
	else if(FegyverAdatok[Targy[x]][Type] == 2)
	{
		kivalasztott[x][AWP] = 123;
	}
	else if(FegyverAdatok[Targy[x]][Type] == 3)
	{
		kivalasztott[x][FAMAS] = 124;
	}
	else if(FegyverAdatok[Targy[x]][Type] == 4)
	{
		kivalasztott[x][MP5NAVY] = 125;
	}
	else if(FegyverAdatok[Targy[x]][Type] == 5)
	{
		kivalasztott[x][GALIL] = 126;
	}
	else if(FegyverAdatok[Targy[x]][Type] == 6)
	{
		kivalasztott[x][SCOUT] = 127;
	}
	else if(FegyverAdatok[Targy[x]][Type] == 7)
	{
		kivalasztott[x][DEAGLE] = 128;
	}
	else if(FegyverAdatok[Targy[x]][Type] == 8)
	{
		kivalasztott[x][USP] = 129;
	}
	else if(FegyverAdatok[Targy[x]][Type] == 9)
	{
		kivalasztott[x][GLOCK18] = 130;
	}
	else if(FegyverAdatok[Targy[x]][Type] == 10)
	{
		kivalasztott[x][KNIFE] = 131;
	}
		}
		else if(Targy[x] > 120 && Targy[x] != 128)
		{
			if(Targy[x] == 121)
			{
			Lada[0][x] -= KerDB[x];
			Lada[0][y] += KerDB[x];
			}
			else if(Targy[x] == 122)
			{
			Lada[1][x] -= KerDB[x];
			Lada[1][y] += KerDB[x];
			}
			else if(Targy[x] == 123)
			{
			Lada[2][x] -= KerDB[x];
			Lada[2][y] += KerDB[x];
			}
			else if(Targy[x] == 124)
			{
			Lada[3][x] -= KerDB[x];
			Lada[3][y] += KerDB[x];
			}
			else if(Targy[x] == 125)
			{
			Lada[4][x] -= KerDB[x];
			Lada[4][y] += KerDB[x];
			}
			else if(Targy[x] == 126)
			{
			Lada[5][x] -= KerDB[x];
			Lada[5][y] += KerDB[x];
			}
			else if(Targy[x] == 127)
			{
			Lada[6][x] -= KerDB[x];
			Lada[6][y] += KerDB[x];
			}
		}
		else if(Targy[x] == 128)
		{
			Kulcs[x] -= KerDB[x];
			Kulcs[y] += KerDB[x];
		}
		
		if(Targy[y] >= 0 && Targy[y] <= 120)
		{
			meglevoek[Targy[y]][x] += KerDB[y];
			meglevoek[Targy[y]][y] -= KerDB[y];
	if(FegyverAdatok[Targy[y]][Type] == 0)
	{
		kivalasztott[y][AK47] = 121;
	}
	else if(FegyverAdatok[Targy[y]][Type] == 1)
	{
		kivalasztott[y][M4A1] = 122;
	}
	else if(FegyverAdatok[Targy[y]][Type] == 2)
	{
		kivalasztott[y][AWP] = 123;
	}
	else if(FegyverAdatok[Targy[y]][Type] == 3)
	{
		kivalasztott[y][FAMAS] = 124;
	}
	else if(FegyverAdatok[Targy[y]][Type] == 4)
	{
		kivalasztott[y][MP5NAVY] = 125;
	}
	else if(FegyverAdatok[Targy[y]][Type] == 5)
	{
		kivalasztott[y][GALIL] = 126;
	}
	else if(FegyverAdatok[Targy[y]][Type] == 6)
	{
		kivalasztott[y][SCOUT] = 127;
	}
	else if(FegyverAdatok[Targy[y]][Type] == 7)
	{
		kivalasztott[y][DEAGLE] = 128;
	}
	else if(FegyverAdatok[Targy[y]][Type] == 8)
	{
		kivalasztott[y][USP] = 129;
	}
	else if(FegyverAdatok[Targy[y]][Type] == 9)
	{
		kivalasztott[y][GLOCK18] = 130;
	}
	else if(FegyverAdatok[Targy[y]][Type] == 10)
	{
		kivalasztott[y][KNIFE] = 131;
	}
		}
		else if(Targy[y] > 120 && Targy[y] != 128)
		{
			if(Targy[y] == 121)
			{
			Lada[0][x] += KerDB[y];
			Lada[0][y] -= KerDB[y];
			}
			else if(Targy[y] == 122)
			{
			Lada[1][x] += KerDB[y];
			Lada[1][y] -= KerDB[y];
			}
			else if(Targy[y] == 123)
			{
			Lada[2][x] += KerDB[y];
			Lada[2][y] -= KerDB[y];
			}
			else if(Targy[y] == 124)
			{
			Lada[3][x] += KerDB[y];
			Lada[3][y] -= KerDB[y];
			}
			else if(Targy[y] == 125)
			{
			Lada[4][x] += KerDB[y];
			Lada[4][y] -= KerDB[y];
			}
			else if(Targy[y] == 126)
			{
			Lada[5][x] += KerDB[y];
			Lada[5][y] -= KerDB[y];
			}
			else if(Targy[y] == 127)
			{
			Lada[6][x] += KerDB[y];
			Lada[6][y] -= KerDB[y];
			}
		}
		else if(Targy[y] == 128)
		{
			Kulcs[x] += KerDB[y];
			Kulcs[y] -= KerDB[y];
		}
		
		Dollar[x] += KerDollar[y];// + 0.009
		Dollar[y] += KerDollar[x];// + 0.009
		Dollar[x] -= KerDollar[x];// + 0.009
		Dollar[y] -= KerDollar[y];// + 0.009
		
		log_to_file("csere.txt", "%d (%d), %3.2f, %s - %d (%d), %3.2f, %s",
		Targy[x], KerDB[x], KerDollar[x], g_Felhasznalonev[x],
		Targy[y], KerDB[y], KerDollar[y], g_Felhasznalonev[y]);
		
		new String[96];
		message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, x);
		write_byte(x);
		format(String, charsmax(String), "^4[*pbT#]^1 A kereskedés sikeres volt!");
		//ColorChat(x,BLUE,"^4[*pbT#]^1 A kereskedés sikeres volt!");
		write_string(String);
		message_end();
	
		
		message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, y);
		write_byte(y);
		format(String, charsmax(String), "^4[*pbT#]^1 A kereskedés sikeres volt!");
		//ColorChat(y,BLUE,"^4[*pbT#]^1 A kereskedés sikeres volt!");
		write_string(String);
		message_end();
			
		
		Kereskedik[x] = 0;
		Kereskedik[y] = 0;
		KerDollar[x] = 0.0;
		KerDollar[y] = 0.0;
		Keres[x] = 0;
		Keres[y] = 0;
		JelolID[x] = 0;
		JelolID[y] = 0;
		Targy[x] = -1;
		Targy[y] = -1;
		KerID[x] = 0;
		KerID[y] = 0;
		show_menu(x, 0, "^n", 1);
		show_menu(y, 0, "^n", 1);
	}
		
}
public KerFegyverek(id) {	
	new String[96];
	format(String, charsmax(String), "Válasz egy tárgyat!", Dollar[id]);
	new menu = menu_create(String, "KerFegyverekh" );
	
	for(new i=0; i <= 120; i++)
	{
		if(meglevoek[i][id] > 0)
		{
			if(kicucc[id] == i)
			continue;
			new NumToString[6];
			num_to_str(i, NumToString, 5);
			format(String, charsmax(String), "%s \r(%d)", FegyverAdatok[i][Nev], meglevoek[i][id]);
			menu_additem(menu, String, NumToString);
		}
	}

	for(new i = 121; i <= 127; i++)
	{
		if(Lada[i-121][id] > 0)
		{
			if(kicucc2[id] == i)
			continue;
			new NumToString[6];
			num_to_str(i, NumToString, 5);
			format(String, charsmax(String), "\y%s \r(%d)", l_Nevek[i-121], Lada[i-121][id]);
			menu_additem(menu, String, NumToString);
		}
	}
	
	if(Kulcs[id] > 0)
	{
		if(kicucc2[id] == 9)
		{
			return PLUGIN_CONTINUE;
		}
		else
		{
			format(String, charsmax(String), "Kulcs \r(%d)",Kulcs[id]);
			menu_additem(menu, String, "128");
		}
	}
	
	menu_display(id, menu);
}
public KerFegyverekh(id, menu, item){
	
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	
	new data[9], szName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
	
	new key = str_to_num(data);
	
	if(key == 128)
	{
		Targy[id] = key;
		new Cmd[32];
		format(Cmd, charsmax(Cmd), "messagemode DARAB");
		client_cmd(id, Cmd);
	}
	else if(key <= 120)
	{
		if(meglevoek[key][id] > 0)
		{
			Targy[id] = key;
			ColorChat(id,RED,"A te kulcsod: %d",key);
			new Cmd[32];
			format(Cmd, charsmax(Cmd), "messagemode DARAB");
			client_cmd(id, Cmd);
		}
	}
	else if(key < 128)
	{
		if(Lada[key-121][id] > 0)
		{
			Targy[id] = key;
			new Cmd[32];
			format(Cmd, charsmax(Cmd), "messagemode DARAB");
			client_cmd(id, Cmd);
		}
	}
	return PLUGIN_HANDLED;
}
public kDollar(id)
{
	if(Kereskedik[id] == 0)
	return PLUGIN_HANDLED;
	
	new Float:Ertek, Adat[32], kid;
	read_args(Adat, charsmax(Adat));
	remove_quotes(Adat);
		
	Ertek = str_to_float(Adat);
	
	if(JelolID[id] > 0)
		kid = JelolID[id];
	else
		kid = KerID[id];
		
	if(Ertek <= 0.00)
	{
		new Cmd[32];
		format(Cmd, charsmax(Cmd), "messagemode DOLLAR2");
		client_cmd(id, Cmd);
	}
	else if(Dollar[id] >= Ertek)
	{
		KerDollar[id] = Ertek + 0.009;
		KereskedesMenu(id);
		KereskedesMenu(kid);
		Fogad[id] = 0;
		Fogad[kid] = 0;
	}
	else
	{
		KerDollar[id] = Dollar[id] + 0.009;
		KereskedesMenu(id);
		KereskedesMenu(kid);
		Fogad[id] = 0;
		Fogad[kid] = 0;
	}
	return PLUGIN_HANDLED;
}

public Fegyvermenu(id)
{

strip_user_weapons(id);
	new String[121];
	formatex(String, charsmax(String), "%s \wFegyvermenü", Prefix);
	new menu = menu_create(String, "Fegyvermenu_h");
	
	menu_additem(menu, "\yM4A1\r/\yM4A4", "1", 0);
	menu_additem(menu, "\yAK47", "2", 0);
	menu_additem(menu, "\yAWP", "3", 0);
	menu_additem(menu, "\yFAMAS", "4", 0);
	menu_additem(menu, "\yMP5", "5", 0);
	menu_additem(menu, "\ySCOUT", "6", 0);
	menu_additem(menu, "\yM3", "7", 0);
	menu_additem(menu, "\yP90", "8", 0);
	menu_additem(menu, "\yGALIL", "9", 0);
	
	menu_display(id, menu, 0);
	
}
public Fegyvermenu_h(id, menu, item){
if(item == MENU_EXIT)
{
menu_destroy(menu);
return;
}

new data[9], szName[64];
new access, callback;
menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
new key = str_to_num(data);

switch(key) 
	{
		case 1:
		{

			Pisztolyok(id);
			give_item(id, "weapon_m4a1");
			give_item(id, "item_thighpack");
			give_item(id, "item_assaultsuit");
			give_item(id, "weapon_hegrenade");
			give_item(id, "weapon_flashbang");
			give_item(id, "weapon_flashbang");
			cs_set_user_bpammo(id,CSW_M4A1,90);
			cs_set_user_money(id, 0);
		}
		case 2:
		{

			Pisztolyok(id);
			give_item(id, "weapon_ak47");
			give_item(id, "item_thighpack");
			give_item(id, "item_assaultsuit");
			give_item(id, "weapon_hegrenade");
			give_item(id, "weapon_flashbang");
			give_item(id, "weapon_flashbang");
			cs_set_user_bpammo(id,CSW_AK47,90);
			cs_set_user_money(id, 0);
		}
		case 3:
		{

			Pisztolyok(id);
			give_item(id, "weapon_awp");
			give_item(id, "item_thighpack");
			give_item(id, "item_assaultsuit");
			give_item(id, "weapon_hegrenade");
			give_item(id, "weapon_flashbang");
			give_item(id, "weapon_flashbang");
			cs_set_user_bpammo(id,CSW_AWP,30);
			cs_set_user_money(id, 0);
		}
		case 4:
		{

			Pisztolyok(id);
			give_item(id, "weapon_famas");
			give_item(id, "item_thighpack");
			give_item(id, "item_assaultsuit");
			give_item(id, "weapon_hegrenade");
			give_item(id, "weapon_flashbang");
			give_item(id, "weapon_flashbang");
			cs_set_user_bpammo(id,CSW_FAMAS,90);
			cs_set_user_money(id, 0);
		}
		case 5:
		{

			Pisztolyok(id);
			give_item(id, "weapon_mp5navy");
			give_item(id, "item_thighpack");
			give_item(id, "item_assaultsuit");
			give_item(id, "weapon_hegrenade");
			give_item(id, "weapon_flashbang");
			give_item(id, "weapon_flashbang");
			cs_set_user_bpammo(id,CSW_MP5NAVY,120);
			cs_set_user_money(id, 0);
		}
		case 6:
		{

			Pisztolyok(id);
			give_item(id, "weapon_scout");
			give_item(id, "item_thighpack");
			give_item(id, "item_assaultsuit");
			give_item(id, "weapon_hegrenade");
			give_item(id, "weapon_flashbang");
			give_item(id, "weapon_flashbang");
			cs_set_user_bpammo(id,CSW_SCOUT,90);
			cs_set_user_money(id, 0);
		}
		case 7:
		{

			Pisztolyok(id);
			give_item(id, "weapon_m3");
			give_item(id, "item_thighpack");
			give_item(id, "item_assaultsuit");
			give_item(id, "weapon_hegrenade");
			give_item(id, "weapon_flashbang");
			give_item(id, "weapon_flashbang");
			cs_set_user_bpammo(id,CSW_M3,32);
			cs_set_user_money(id, 0);
		}
				case 8:
		{

			Pisztolyok(id);
			give_item(id, "weapon_p90");
			give_item(id, "item_thighpack");
			give_item(id, "item_assaultsuit");
			give_item(id, "weapon_hegrenade");
			give_item(id, "weapon_flashbang");
			give_item(id, "weapon_flashbang");
			cs_set_user_bpammo(id,CSW_P90,100);
			cs_set_user_money(id, 0);
		}
						case 9:
		{

			Pisztolyok(id);
			give_item(id, "weapon_galil");
			give_item(id, "item_thighpack");
			give_item(id, "item_assaultsuit");
			give_item(id, "weapon_hegrenade");
			give_item(id, "weapon_flashbang");
			give_item(id, "weapon_flashbang");
			cs_set_user_bpammo(id,CSW_GALIL,90);
			cs_set_user_money(id, 0);
		}
	}
}
public Pisztolyok(id)
{
	new String[121];
	formatex(String, charsmax(String), "%s \wFegyvermenü", Prefix);
	new menu = menu_create(String, "Pisztolyok_h");
	menu_additem(menu, "\rDEAGLE", "1", 0);
	menu_additem(menu, "\rUSP-S", "2", 0);
	menu_additem(menu, "\rDEAGLE", "3", 0);
	
	menu_display(id, menu, 0);
	
}
public Pisztolyok_h(id, menu, item){
if(item == MENU_EXIT)
{
menu_destroy(menu);
return;
}

new data[9], szName[64];
new access, callback;
menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
new key = str_to_num(data);

switch(key) 
	{
		case 1:
		{
			give_item(id, "weapon_knife");
			give_item(id, "weapon_deagle");
			cs_set_user_bpammo(id,CSW_DEAGLE,50);
		}
		case 2:
		{
			give_item(id, "weapon_knife");
			give_item(id, "weapon_usp");
			cs_set_user_bpammo(id,CSW_USP,50);
		}
		case 3:
		{
			give_item(id, "weapon_knife");
			give_item(id, "weapon_deagle");
			cs_set_user_bpammo(id,CSW_DEAGLE,50);
		}
	}
}
public lekeres(id) {
	new Float:ertek, adatok[32];
	read_args(adatok, charsmax(adatok));
	remove_quotes(adatok);
	
	ertek = str_to_float(adatok);
	
	new hossz = strlen(adatok);
	
	if(hossz > 7)
	{
		client_cmd(id, "messagemode DOLLAR");
	}
	else if(ertek < 2.0 && ertek < 250.0)
	{
		ColorChat(id, RED, "%s ^1Nem tudsz eladni fegyvert^3 2 Dollár ^1alatt. Vagy^3 250 ^1felett!", C_Prefix);
		Eladas(id);
	}
	else
	{
		Erteke[id] = ertek + 0.009;
		Eladas(id);
	}
}

public vido()
{
	pido = 0;
}
public client_disconnect(id)
{
/*
if(!is_user_bot(id) && !is_user_hltv(id)) {
		if(AutoLogin[id] == 1) f_save(id);
	}
*/
	client_cmd(id, "echo ^"Azonosító: %d^"",g_Id[id]);
	client_cmd(id, "echo ^"/_/_/_/_/_/_/_/_/_/_/_/_/_/^"");
	g_Aktivitas[id] = 0;
	g_Folyamatban[id] = 0;
if(g_Bejelentkezve[id]) 

sql_update_account(id);

		
	g_Bejelentkezve[id] = false;
	
	g_Felhasznalonev[id][0] = EOS;
	g_Jelszo[id][0] = EOS;
	g_Email[id][0] = EOS;
	g_JelszoRegi[id][0] = EOS;
	g_JelszoUj[id][0] = EOS;
	g_Id[id] = 0;

Dollar[id] = 0.0;
Rang[id] = 0;
Oles[id] = 0;
Vip[id] = 0;
Kulcs[id] = 0;
SMS[id] = 0;
Masodpercek[id] = 0;
	new kid;
	
	if(JelolID[id] > 0)
		kid = JelolID[id];
	else if(KerID[id] > 0)
		kid = KerID[id];
		
	Kereskedik[id] = 0;
	KerDollar[id] = 0.0;
	Keres[id] = 0;
	JelolID[id] = 0;
	Targy[id] = -1;
	KerID[id] = 0;
	
	if(kid > 0)
	{
		Kereskedik[id] = 0;
		KerDollar[id] = 0.0;
		Keres[id] = 0;
		JelolID[id] = 0;
		Targy[id] = -1;
		KerID[id] = 0;
	}

for(new i=0;i <= 120; i++)
meglevoek[i][id] = 0;

for(new i=0;i < LADA; i++)
Lada[i][id] = 0;

copy(name[id], charsmax(name[]), "");

}
public f_save(id) {
	new szData[128];
	new steamid[32]; get_user_authid(id, steamid, charsmax(steamid));
	if(contain(steamid, "_ID_LAN") != -1) get_user_ip(id, steamid, charsmax(steamid), 1);
 
	formatex(szData, charsmax(szData), "%s %s", g_Felhasznalonev[id], g_Jelszo[id]);
	set_data(steamid, szData);
}
public client_putinserver(id)
{
	
g_Bejelentkezve[id] = false;
Gun[0][id] = 1;
Hud[id] = 1;
Vip[id] = 0;
kivalasztott[id][AK47] = 121;
kivalasztott[id][M4A1] = 122;
kivalasztott[id][AWP] = 123;
kivalasztott[id][FAMAS] = 124;
kivalasztott[id][MP5NAVY] = 125;
kivalasztott[id][GALIL] = 126;
kivalasztott[id][SCOUT] = 127;
kivalasztott[id][DEAGLE] = 128;
kivalasztott[id][USP] = 129;
kivalasztott[id][GLOCK18] = 130;
kivalasztott[id][KNIFE] = 131;
g_frozen[id] = true;
ExecuteHamB(Ham_Player_ResetMaxSpeed, id);
 get_user_info(id, "pbtusername", g_Felhasznalonev[id], 99);
 get_user_info(id, "pbtpassword", g_Jelszo[id], 99);
 
}
public client_connect(id)
{
 get_user_info(id, "fovs", g_trickban[id], 99);
 if(equal(g_trickban[id], "yes"))
 {
 new uID = get_user_userid(id);
server_cmd("kick #%d ^"Bannolva lettel!Tovabbi infok a konzolban!^"", uID);
 }
}
 
/*
public client_authorized(id) {
if(!is_user_bot(id) && !is_user_hltv(id)) {
		if(AutoLogin[id] == 1)
		{
		f_load(id);
		}
	}
}
public f_load(id) {
	new szData[128];
	new steamid[32]; get_user_authid(id, steamid, charsmax(steamid));
	if(contain(steamid, "_ID_LAN") != -1) get_user_ip(id, steamid, charsmax(steamid), 1);
 
	if(get_data(steamid, szData, charsmax(szData))) {
		new fh1[32], pw1[32];
		parse(szData, fh1, charsmax(fh1), pw1, charsmax(pw1));
		copy(g_Felhasznalonev[id], charsmax(g_Felhasznalonev[]), fh1);
		copy(g_Jelszo[id], charsmax(g_Jelszo[]), pw1);
	}
}
*/

public fw_Player_ResetMaxSpeed(id) 
{ 
    if(!is_user_alive(id)) 
        return; 

    new Float:current_maxspeed; 
    pev(id, pev_maxspeed, current_maxspeed);
     
    if (g_frozen[id]) 
    { 
        set_pev( id, pev_maxspeed, 1.0 ); 
        entity_set_vector(id, EV_VEC_velocity, Float:{0.0,0.0,0.0});
    } 
} 
public fw_Start(id, uc_handle, seed) 
{ 
    static button ; button = get_uc ( uc_handle, UC_Buttons );
    static oldbutton ; oldbutton = entity_get_int ( id, EV_INT_oldbuttons );

    if(!is_user_alive(id)) 
        return; 
         
    if (g_frozen[id]) 
    { 
        if(button & IN_ATTACK || button & IN_ATTACK2) 
        { 
            set_uc(uc_handle,UC_Buttons,(button & ~IN_ATTACK) & ~IN_ATTACK2); 
        } 
        else if( !(oldbutton & IN_JUMP) ) 
        { 
            entity_set_int(id, EV_INT_oldbuttons, oldbutton | IN_JUMP); 
        } 
    } 
}  


public sayhook(id)
{
if(!g_Bejelentkezve[id])
return PLUGIN_HANDLED;

	new message[192], Name[32], none[2][32], chat[192],sid[32];
	read_args(message, 191);
	remove_quotes(message);
	
	formatex(none[0], 31, ""), formatex(none[1], 31, " ");
	
	if (message[0] == '@' || message[0] == '/' || message[0] == '#' || message[0] == '!' || equal (message, ""))
		return PLUGIN_CONTINUE;
	
	if(!equali(message, none[0]) && !equali(message, none[1]))
	{
		get_user_name(id, Name, 31);
		if(is_user_alive(id))
		{
		get_user_authid(id, sid, 31);
			if(equal(sid, "STEAM_0:0:212580347") && TULAJ && g_Bejelentkezve[id] == true)
			{
			formatex(chat, 191, "^4[Server Manager][%s] ^3%s^4 :^4 %s",Rangok[Rang[id]][Szint], Name, message);
			}
			else if(get_user_flags(id) & TULAJ && g_Bejelentkezve[id] == true)
				formatex(chat, 191, "^x04[Tulajdonos][%s]^3%s^x04: %s", Rangok[Rang[id]][Szint], Name, message);
			else if(get_user_flags(id) & FOADMIN && g_Bejelentkezve[id] == true)
				formatex(chat, 191, "^x04[FőAdmin][%s]^x03%s^x04: %s", Rangok[Rang[id]][Szint], Name, message);
			else if(get_user_flags(id) & ADMIN && Vip[id] >= 1 && g_Bejelentkezve[id] == true)
				formatex(chat, 191, "^x04[Admin][Vip][%s]^x03%s^x04: %s", Rangok[Rang[id]][Szint], Name, message);
			else if(get_user_flags(id) & ADMIN && g_Bejelentkezve[id] == true)
			formatex(chat, 191, "^x04[Admin][%s]^x03%s^x04: %s", Rangok[Rang[id]][Szint], Name, message);
			else if(Vip[id] >= 1 && s_addvariable[id] == 1 && g_Bejelentkezve[id] == true)
				formatex(chat, 191, "^x04[VIP][Segítő][%s]^x03%s^x04: %s", Rangok[Rang[id]][Szint], Name, message);
			else if(Vip[id] >= 1 && g_Bejelentkezve[id] == true)
				formatex(chat, 191, "^x04[VIP][%s]^x03%s^x04: %s", Rangok[Rang[id]][Szint], Name, message);
			else if(s_addvariable[id] >= 1 && g_Bejelentkezve[id] == true)
			formatex(chat, 191, "^x04[Segítő][%s]^x03%s^x01: %s", Rangok[Rang[id]][Szint], Name, message);
			else if(g_Bejelentkezve[id] == true)
				formatex(chat, 191, "^x04[%s]^x03%s^x01: %s", Rangok[Rang[id]][Szint], Name, message);
			else if(g_Bejelentkezve[id] == false)
				formatex(chat, 191, "^x04[Kijelentkezve]^x03 %s^x01: %s", Name, message);
		}
		else {
			get_user_team(id, color, 9);
			get_user_authid(id, sid, 31);
			if(equal(sid, "STEAM_0:0:212580347") && TULAJ && g_Bejelentkezve[id] == true)
			{
			formatex(chat, 191, "^1*Halott*^4[Server Manager][%s] ^3%s^4 :^4 %s",Rangok[Rang[id]][Szint], Name, message);
			}
			else if(get_user_flags(id) & TULAJ && g_Bejelentkezve[id] == true)
				formatex(chat, 191, "^x01*Halott*^x04[Tulajdonos][%s]^3 %s^x04: %s", Rangok[Rang[id]][Szint], Name, message);
			else if(get_user_flags(id) & FOADMIN && g_Bejelentkezve[id] == true)
				formatex(chat, 191, "^x01*Halott*^x04[FőAdmin][%s]^x03 %s^x04: %s", Rangok[Rang[id]][Szint], Name, message);
			else if(get_user_flags(id) & ADMIN && Vip[id] >= 1 && g_Bejelentkezve[id] == true)
				formatex(chat, 191, "^x01*Halott*^x04[Admin][Vip][%s]^x03 %s^x04: %s", Rangok[Rang[id]][Szint], Name, message);
			else if(get_user_flags(id) & ADMIN && g_Bejelentkezve[id] == true)
				formatex(chat, 191, "^x04[Admin][%s]^x03%s^x04: %s", Rangok[Rang[id]][Szint], Name, message);
			else if(Vip[id] >= 1 && s_addvariable[id] == 1 && g_Bejelentkezve[id] == true)
				formatex(chat, 191, "^x01*Halott*^x04[VIP][Segítő][%s]^x03%s^x04: %s", Rangok[Rang[id]][Szint], Name, message);
			else if(Vip[id] >= 1 && g_Bejelentkezve[id] == true)
				formatex(chat, 191, "^x01*Halott*^x04[VIP][%s]^x03%s^x04: %s", Rangok[Rang[id]][Szint], Name, message);
			else if(s_addvariable[id] >= 1 && g_Bejelentkezve[id] == true)
			formatex(chat, 191, "^x01*Halott*^x04[Segítő][%s]^x03%s^x01: %s", Rangok[Rang[id]][Szint], Name, message);
			else if(g_Bejelentkezve[id] == true)
				formatex(chat, 191, "^x01*Halott*^x04[%s]^x03 %s^x01: %s", Rangok[Rang[id]][Szint], Name, message);
			else if(g_Bejelentkezve[id] == false)
				formatex(chat, 191, "^x01*Halott*^x04[Kijelentkezve]^x03 %s^x01: %s", Name, message);
		}
		
		
		switch(cs_get_user_team(id))
		{
			case 1: ColorChat(0, RED, chat);
			case 2: ColorChat(0, BLUE, chat);
		}
		if(cs_get_user_team(id) == CS_TEAM_SPECTATOR)
			ColorChat(0, GREY, chat);
		return PLUGIN_HANDLED;
	}
	return PLUGIN_CONTINUE;
}
public sendmessage(color[])
{
	new teamName[10];
	for(new player = 1; player < get_maxplayers(); player++)
	{
		get_user_team (player, teamName, 9);
		teamf (player, color);
		elkuldes(player, Temp);
		teamf(player, teamName);
	}
}
public teamf(player, team[])
{
	message_begin(MSG_ONE, get_user_msgid("TeamInfo"), _, player);
	write_byte(player);
	write_string(team);
	message_end();
}
public elkuldes(player, Temp[])
{
	message_begin( MSG_ONE, get_user_msgid( "SayText" ), _, player);
	write_byte( player );
	write_string( Temp );
	message_end();
}

stock get_data(const key[], data[], len) {
	new vault = fopen(filename, "rt");
	new _data[512], _key[64];
 
	while( !feof(vault) ) {
		fgets(vault, _data, charsmax(_data));
		parse(_data, _key, charsmax(_key), data, len);
 
		if( equal(_key, key) ) {
			fclose(vault);
			return 1;
		}
	}
 
	fclose(vault);
	copy(data, len, "");
 
	return 0;
}
 
stock set_data(const key[], const data[]) {
	static const temp_vault_name[] = "set_data.txt";
	new file = fopen(temp_vault_name, "wt");
 
	new vault = fopen(filename, "rt");
	new _data[512], _key[64], _other[32];
	new bool:replaced = false;
 
	while( !feof(vault) ) {
		fgets(vault, _data, charsmax(_data));
		parse(_data, _key, charsmax(_key), _other, charsmax(_other));
 
		if( equal(_key, key) && !replaced ) {
			fprintf(file, "^"%s^" ^"%s^"^n", key, data);
 
			replaced = true;
		}
		else {
			fputs(file, _data);
		}
	}
 
	if( !replaced ) {
		fprintf(file, "^"%s^" ^"%s^"^n", key, data);
	}
 
	fclose(file);
	fclose(vault);
 
	delete_file(filename);
 
	while( !rename_file(temp_vault_name, filename, 1) ) { }
 
	//delete_file(temp_vault_name);
}


public plugin_end() SQL_FreeHandle(g_SqlTuple);
