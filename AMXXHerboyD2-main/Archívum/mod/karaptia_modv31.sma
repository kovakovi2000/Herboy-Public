#pragma tabsize 0
#include <amxmodx>
#include <dhudmessage>
#include <hamsandwich>
#include <colorchat>
#include <cstrike>
#include <engine>
#include <fun>
#include <fakemeta>
#include <fakemeta_util>
#include <sqlx>
#include <amxmisc>
#include <csstats>
#include <csx>

//SZÖVEGEK

new const PLUGIN[] = "[SKIN_RENDSZER_V2.0]";
new const VERSION[] = "1.0";
new const AUTHOR[] = "TwisT";




new const Prefix[] = "[K]ÁRPÁTI[A]- FUN »"; //Menüben megjelenő prefix
new const C_Prefix[] = "^4[K]ÁRPÁTI[A]- FUN ^3»"; //Chat Prefix
new const PR[] = "[K]ÁRPÁTI[A]- FUN »"; //Menükben megjelenő prefix
new const C_PR[] = "^4[K]ÁRPÁTI[A]- FUN ^3»"; //Chatben megjelenő prefix



#define TULAJ ADMIN_IMMUNITY
#define FOADMIN ADMIN_LEVEL_G
#define ADMIN ADMIN_BAN
#define VIP ADMIN_LEVEL_H
#define CASE2 5 //Kulcsok száma
#define LADA 5 //Ládák száma
#define FEGYO 181 //Fegyverek száma
#define STK 12 //Statrakok száma
#define skinek	7 //Skinek száma
#define MAXERDEM 8 //maximum Érdem Érem

#define MAXPLAYERS 33
#define MAXRANK 4 //maximum rang

#define MAX_BUFFER_LENGTH	4095 //motd megjelenő max szám
#define IS_PLAYER(%1)			(1 <= %1 <= gMaxPlayers)

//MYSQL ADATBÁZIS

new const SQLINFO[][] = { "mysql.srkhost.eu", "u24795_PJULczGQKS", "TJCXM4Sfh1MD", "s24795_patrik" };


enum _:Teams { Te, Ct };
new	g_Awps[Teams], bool:g_UseWeapon[33];


new SayText;


new bool:AccountBelepve[33], bool:Beirtcedula[33], g_Jutalom[4][33], g_QuestKills[2][33];

new TopMvp, awpkoralt,	 prefiszem[33][100], Fegyverneve[FEGYO][33][100], bool:fegyverkivalasztas[33];


// Regisztráció és Bejelentkezés
new g_UserName[33][100], g_Password[33][100], g_UserMail[33][100], g_RegistOrLogin[33];
new g_InProgress[33],bool:g_LoggedIn[33], bool:g_Mail[33], g_Password1[33][100];

//IDO-KORLÁT-ESEMÉNYEK
new g_VipTime[33],	Masodpercek[33], OsszesSkin[FEGYO][33], Skin[skinek][33];

new Statrak[STK][33], g_Kulcs[CASE2][33],	Lada[LADA][33], aSync, bSync, Mod, TempID;

new kibestat[33], bool:Hud[33], Oles[33], bool:FegyverHud[33], bool:Beirtprefix[33];
new AdminLevel[33], AdminRangDisable[33], ChatType[33];

new dobozszam,	cvar,	counter = 0, bool:megvan, bool:generalva;


enum _:SelGuns { AK47, M4A1, AWP, DEAGLE, KNIFE, SMOKE, HEG, FLASH, C4	};
new Selectedgun[33][SelGuns];

enum _:adathalmaz{Dollar, g_Id, bypass_kartya, hudszin, g_MVPoints, Osszes_kartya, szerencse, kartya, alapchat, chatprefix};	
new g_adatok[adathalmaz][MAXPLAYERS];


enum _:adatv2{Nevcedula, hanyasnevcedula, g_QuestMVP, g_QuestHead, g_Quest, g_QuestWeapon, patrik_zeneji, ZenePont, Erteke, kicucc};	
new g_AdatV2[adatv2][MAXPLAYERS];				 


enum _:DataPlayer{SMS, MPrefi, Kulcs, fagyaszto, Gun, teljesitmeny, Rang, teljesitmenyoles, felszedett, Send, kirakva, ExpBoost};	
new g_playerData[DataPlayer][MAXPLAYERS];


new const ET_model[][] =
 {
	"models/box1.mdl",
	"models/box2.mdl"
}

new Handle:g_SqlTuple;


static color[10];
new x_tempid;


	/*-----[ ByPASS ]------*/
enum _:Ermek{ErdemSzam, ErdemNevek[64], ErdemIdeje};
new const ErdemErme[MAXERDEM][Ermek] ={
	{0, "	Nem Elérhető", 0},	
	{1, "Szint 1", 3600},	
	{2, "Szint 2", 7200},	
	{3, "Szint 3", 10800},	
	{4, "Szint 4", 18000},	
	{5, "Szint 5", 36000},	
	{6, "Szint 6", 72000},	
	{7, "Szint 7", 90000}
};
 
enum _:eerdemerem{eTime, ErdemSzint};	
new g_Erdem[eerdemerem][MAXPLAYERS];



new gSzamolas;

enum _:playersys { Float:Euro };
enum _:birtok { Float:penz };

new Player[33][playersys];
new penzem[33][birtok];


enum _:dropSystem{	g_WeapID, Name[64],	ModelName[64], EntName[8], Float:Ritkasag};
enum _:zenek{	Nevei[64],	mp3ak[64],	zenepontok	};
enum _:Rangs{	Szint[32],	Xp[8]	};
enum _:jOgR{	rangokjogok[32]	};
enum _:Adatok{	Nevei[64],	Model[64],	fgy_oles[8]	};
enum _:ertekeke{	Neve[32],	Szintje[8], mutato[8], Szazalek[32]	};
enum _:ladakulcsSystem{	Nevv[64],	Float:ritka	};
enum _:boltos{	Neve[32],	Float:Ara[8]	};


new const LadaNevei[][ladakulcsSystem] =
{
{	" Fegyver | Láda", 53.23	},
{	" Mester  | Láda", 47.76	},
{	" Hibrid | Láda", 35.34	},
{	" Tréning | Láda", 23.65	},
{	" Prémium | Láda", 13.13 }
};

new const KulcsNevek[][ladakulcsSystem] =
{
{	" Fegyver | Kulcs", 42.17	},
{	" Mester	| Kulcs", 40.83	},
{	" Hibrid | Kulcs", 30.15	},
{	" Tréning | Kulcs", 20.33	},
{	" Prémium | Kulcs", 10.50 }
};


new const gGiftModels[][] = {
	"models/box1.mdl",
	"models/box2.mdl"
};
new const Admin_Permissions[][][] = {
	//rang név | Jogok | Hozzáadhat-e admint? (0-Nem | 1-Igen)| Hozzáadhat-e VIP-t? (0-Nem | 1-Igen) | Bannolhat accot? 0 nem 1 igen
	{"Játékos", "z", "0", "0"}, //Játékos - 0
	{"Fejlesztő", "abcvnmlpoikujzhtgrfedwsyc", "1", "1"}, //Konfigos - 1
	{"Tulajdonos", "abcvnmlpoikujzhtgrfedwsayc", "1", "1"}, //Tulajdonos - 2
	{"Tulaj helyettes", "abcvnmlpoikujzhtgrfedwsayc", "1", "1"}, //Tulajdonos - 2
	{"FőAdmin", "bmcfscgdtiue", "0", "1"}, //FőAdmin - 4
	{"Admin", "bmcfscdtiue", "0", "0"}, //Admin - 5
	{"Queen", "bmcfscdtiue", "0", "0"} //Admin - 5
};
new const szGiftClassname[] = "Present_Entity";

new gInfoTarget;

new gMaxPlayers;

new const Rangok[][Rangs] =
{
{ "Újonc", 0	},
{ "Lelkes", 100	},
{ "Tag", 250	},
{ "Beavatott", 400	},
{ "Tud valamit", 550	},
{ "Fanatikus", 800	},
{ "Senior Tag", 1210	},
{ "Jómunkásember", 1560	},
{ "Nagyúr", 2200	},
{ "Félisten", 2400	},
{ "Pusztitó", 2700	},
{ "Gyilkológép", 3200	},
{ "Östag", 3700	},
{ "Veterán", 4200	},
{ "Őskövület", 5000	},
{ "Mindenható", 6000	},
{ "Megállíthatatlan", 7000	},
{ "Szerencsés", 10000	},
{ "Legenda", 12000	},
{ "ENBER NEM BÍRSZ VELEM", 15000 }
};

new const Fegyverek[][dropSystem] =
{ /*  sorszám  | fegyver neve |  elérhetősége | fegyver elérhetősége | %-s dropp */  /* CSW_AK47, CSW_AWP, CSW_DEAGLE, CSW_M4A1, CSW_KNIFE*/
	{ 0,	"AK47 | Default", "models/v_ak47.mdl",	CSW_AK47, 1.00 },
	{ 1,	"AWP | Default", "models/v_awp.mdl", CSW_AWP, 1.00 },
	{ 2,	"DEAGLE | Default", "models/v_deagle.mdl", CSW_DEAGLE, 1.00 },
	{ 3,	"M4A1 | Default", "models/v_m4a1.mdl", CSW_M4A1, 1.00 },
	{ 4,	"KÉS | Default", "models/v_knife.mdl", CSW_KNIFE, 1.00 },
	{ 5,	"AK47 | Anubis", "models/karpatia/ak47/ak47_anubis.mdl",	CSW_AK47, 10.13 },
	{ 6,	"AK47 | Astronaut",	"models/karpatia/ak47/ak47_astronaut.mdl", CSW_AK47, 10.12	},
	{ 7,	"AK47 | Black gold",	"models/karpatia/ak47/ak47_black_gold.mdl", CSW_AK47, 10.70 },
	{ 8,	"AK47 | Bloodsport", "models/karpatia/ak47/ak47_bloodsport.mdl", CSW_AK47, 13.23 },
	{ 9,	"AK47 | Blue", "models/karpatia/ak47/ak47_blue.mdl", CSW_AK47, 12.56 },
	{ 10,	"AK47 | Blue Carbon", "models/karpatia/ak47/ak47_blue_carbon.mdl", CSW_AK47, 12.87 },
	{ 11,	"AK47 | Brown", "models/karpatia/ak47/ak47_brown.mdl", CSW_AK47, 25.12 }, 
	{ 12,	"AK47 | Carbon Line", "models/karpatia/ak47/ak47_carbon_line.mdl", CSW_AK47, 10.13 },
	{ 13,	"AK47 | Desert Camo", "models/karpatia/ak47/ak47_desert_camo.mdl", CSW_AK47, 45.15 }, 
	{ 14,	"AK47 | Elite Build", "models/karpatia/ak47/ak47_elite_build.mdl", CSW_AK47, 14.32 },
	{ 15,	"AK47 | Frontside Misty", "models/karpatia/ak47/ak47_frontside_misty.mdl", CSW_AK47, 12.52 },
	{ 16,	"M4A1 | Asiimov", "models/karpatia/m4a1/m4a1_asiimov.mdl", CSW_M4A1, 10.13 },
	{ 17,	"M4A1 | Atomic", "models/karpatia/m4a1/m4a1_atomic.mdl", CSW_M4A1, 16.01 },
	{ 18,	"M4A1 | Basilisk", "models/karpatia/m4a1/m4a1_basilisk.mdl", CSW_M4A1, 14.25 },
	{ 19,	"M4A1 | Howl", "models/karpatia/m4a1/m4a1_howl.mdl", CSW_M4A1, 8.91 },
	{ 20,	"M4A1 | Bush Master", "models/karpatia/m4a1/m4a1_bush_master.mdl", CSW_M4A1, 21.79 },
	{ 21,	"M4A1 | Color", "models/karpatia/m4a1/m4a1_color.mdl", CSW_M4A1, 13.52 },
	{ 22,	"M4A1 | Dragon King", "models/karpatia/m4a1/m4a1_dragon_king.mdl", CSW_M4A1, 15.58 },
	{ 23,	"M4A1 | Cyrex", "models/karpatia/m4a1/m4a1_cyrex.mdl", CSW_M4A1, 21.90 },
	{ 24,	"M4A1 | Decimator", "models/karpatia/m4a1/m4a1_decimator.mdl", CSW_M4A1, 14.82 },
	{ 25,	"M4A1 | Desert", "models/karpatia/m4a1/m4a1_desert.mdl", CSW_M4A1, 17.90 },
	{ 26,	"M4A1 | Desolate Space", "models/karpatia/m4a1_desolate_space.mdl", CSW_M4A1, 23.41 },
	{ 27,	"AWP | Frontside Misty", "models/karpatia/awp/awp_frontside_misty.mdl", CSW_AWP, 0.13 },
	{ 28,	"AWP | Airsoft", "models/karpatia/awp/awp_airsoft.mdl", CSW_AWP, 10.01 }, 
	{ 29,	"AWP | Artistic", "models/karpatia/awp/awp_artistic.mdl", CSW_AWP, 13.30 },
	{ 30,	"AWP | Assimov", "models/karpatia/awp/awp_assimov.mdl", CSW_AWP, 24.49 },
	{ 31,	"AWP | Banshee", "models/karpatia/awp/awp_banshee.mdl", CSW_AWP, 11.93 },
	{ 32,	"AWP | Bloody Camo", "models/karpatia/awp/awp_bloody_camo.mdl", CSW_AWP, 13.27 },
	{ 33,	"AWP | Boom", "models/karpatia/awp/awp_boom.mdl", CSW_AWP, 10.93 },
	{ 34,	"AWP | Brown", "models/karpatia/awp/awp_brown.mdl", CSW_AWP, 14.73 },
	{ 35,	"AWP | Christmas", "models/karpatia/awp/awp_christmas.mdl", CSW_AWP, 17.48 },
	{ 36,	"AWP | Cloud-9", "models/karpatia/awp/awp_cloud9.mdl", CSW_AWP, 16.18 },
	{ 37,	"AWP | Cyrex", "models/karpatia/awp/awp_cyrex.mdl", CSW_AWP, 24.47 },
	{ 38,	"AWP | Dragon Lore", "models/karpatia/awp/awp_dragon_lore.mdl", CSW_AWP, 8.73 },
	{ 39,	"AWP | Elite Build", "models/karpatia/awp/awp_elitebuild.mdl", CSW_AWP, 21.00 },
	{ 40,	"AWP | Fever Dream", "models/karpatia/awp/awp_fever_dream.mdl", CSW_AWP, 18.00 },
	{ 41,	"DEAGLE | Blue Crystal LIMITÁLT", "models/karpatia/deagle/deagle_blue_crystal.mdl", CSW_DEAGLE, 0.13 },
	{ 42,	"DEAGLE | Blue metal *VIP", "models/karpatia/deagle/deagle_bluemetal.mdl", CSW_DEAGLE, 0.01 }, 
	{ 43,	"DEAGLE | Color", "models/karpatia/deagle/deagle_color.mdl", CSW_DEAGLE, 17.44 },
	{ 44,	"DEAGLE | Comic", "models/karpatia/deagle/deagle_comic.mdl", CSW_DEAGLE, 11.23 },
	{ 45,	"DEAGLE | Crocodilus", "models/karpatia/deagle/deagle_crocodilus.mdl", CSW_DEAGLE, 11.47 },
	{ 46,	"DEAGLE | Debra", "models/karpatia/deagle/deagle_debra.mdl", CSW_DEAGLE, 16.18 },
	{ 47,	"DEAGLE | Fade", "models/karpatia/deagle/deagle_fade.mdl", CSW_DEAGLE, 16.97 },
	{ 48,	"DEAGLE | Frontside Misty", "models/karpatia/deagle/deagle_frontside_misty.mdl", CSW_DEAGLE, 13.36 },
	{ 49,	"DEAGLE | Galaxy", "models/karpatia/deagle/deagle_galaxy.mdl", CSW_DEAGLE, 19.31 },
	{ 50,	"DEAGLE | Ghost", "models/karpatia/deagle/deagle_ghost.mdl", CSW_DEAGLE, 24.61 },
	{ 51,	"Blue Night | KNIFE", "models/karpatia/knife/knife_blue_night.mdl", CSW_KNIFE, 23.13 },
	{ 52,	"M9 echo | KNIFE", "models/karpatia/knife/knife_m9echo.mdl", CSW_KNIFE, 25.21 },
	{ 53,	"Tron Orange | KNIFE", "models/karpatia/knife/knife_tron_colors_orange.mdl", CSW_KNIFE, 13.23 },
	{ 54,	"Fade | KNIFE", "models/karpatia/knife/knife_fade.mdl", CSW_KNIFE, 10.13 },
	{ 55,	"Frozen | KNIFE", "models/karpatia/knife/knife_frozen.mdl", CSW_KNIFE, 5.32 },
	{ 56,	"Galaxy IAN | KNIFE", "models/karpatia/knife/knife_galaxy_ian.mdl", CSW_KNIFE, 10.11 },
	{ 57,	"Gamme Doppler | KNIFE", "models/karpatia/knife/knife_gamma_doppler.mdl", CSW_KNIFE, 7.30 },
	{ 58,	"Butterfly Fade | KNIFE LIMITÁLT", "models/karpatia/knife/knife_butterflyfade.mdl", CSW_KNIFE, 2.13 },
	{ 59,	"Ghost | KNIFE", "models/karpatia/knife/knife_ghost.mdl", CSW_KNIFE, 10.10 },
	{ 60,	"Lore | KNIFE", "models/karpatia/knife/knife_lore.mdl", CSW_KNIFE, 10.31 },
	{ 61,	"Marble Fade | KNIFE LIMITÁLT", "models/karpatia/knife/knife_marble_fade.mdl", CSW_KNIFE, 2.30 },
	{ 62,	"Standart | KNIFE", "models/karpatia/knife/knife_standart.mdl", CSW_KNIFE, 12.64 },
	{ 63,	"Tron Blue | KNIFE", "models/karpatia/knife/knife_tron_colors_blue.mdl", CSW_KNIFE, 13.73 },
	{ 64,	"Tron Blue2 | KNIFE", "models/karpatia/knife/knife_tron_colors_bluev2.mdl", CSW_KNIFE, 7.98 },
	{ 65,	"Tron Green | KNIFE", "models/karpatia/knife/knife_tron_colors_green.mdl", CSW_KNIFE, 12.51 },
	{ 66,	"Tron Green2 | KNIFE","models/karpatia/knife/knife_tron_colors_greenv2.mdl", CSW_KNIFE, 5.13 },
	{ 67,	"Tron Orange | KNIFE", "models/karpatia/knife/knife_tron_colors_orangev2.mdl", CSW_KNIFE, 5.90 },
	{ 68,	"Tron Purple | KNIFE", "models/karpatia/knife/knife_tron_colors_purple.mdl", CSW_KNIFE, 14.13 },
	{ 69,	"Tron Red | KNIFE", "models/karpatia/knife/knife_tron_colors_red.mdl", CSW_KNIFE, 14.89 },
	{ 70,	"Var White | KNIFE", "models/karpatia/knife/knife_var_colors_white.mdl", CSW_KNIFE, 1.23 },
	{ 71,	"ALAP | KNIFE", "models/v_knife.mdl", CSW_KNIFE, 1.23 },
	{ 72,	"Ultra | KNIFE", "models/karpatia/knife/knife_ultra.mdl", CSW_KNIFE, 16.99 },
	{ 73,	"Misericórdia | KNIFE", "models/dildo/dildo2.mdl", CSW_KNIFE, 26.40	},
	{ 74,	"AK47 | Furious", "models/karpatia/ak47/ak47_furious.mdl", CSW_AK47, 17.65	},
	{ 75,	"AK47 | Galaxy", "models/karpatia/ak47/ak47_galaxy.mdl", CSW_AK47, 12.80 },
	{ 76,	"AK47 | Graffiti", "models/karpatia/ak47/ak47_graffiti.mdl", CSW_AK47, 16.52	},
	{ 77,	"M4A1 | Ultimate", "models/karpatia/m4a1/m4a1_ultimate.mdl", CSW_M4A1, 13.91	},
	{ 78,	"M4A1 | White", "models/karpatia/m4a1/m4a1_white.mdl", CSW_M4A1, 11.79	},
	{ 79,	"M4A1 | Wild Style", "models/karpatia/m4a1/m4a1_wild_style.mdl", CSW_M4A1, 10.05 },
	{ 80,	"Gaya Blue | KNIFE", "models/karpatia/valorant/gaya_blue.mdl", CSW_KNIFE, 16.99	},
	{ 81,	"Gaya Green | KNIFE", "models/karpatia/valorant/gaya_green.mdl", CSW_KNIFE, 19.98	},
	{ 82,	"AK47 | Elderflame Dark", "models/karpatia/valorant/ak47_elderflame_dark.mdl", CSW_AK47, 19.80	},
	{ 83,	"M4A1 | Reaver Black", "models/karpatia/valorant/reaver_m4_black.mdl", CSW_M4A1, 10.52	},
	{ 84,	"AWP | Elderflame Blue", "models/karpatia/valorant/elderflame_awp_kek.mdl", CSW_AWP, 13.91	},
	{ 85,	"DEAGLE | Protocol", "models/karpatia/valorant/protocol_sheriff.mdl", CSW_DEAGLE, 21.79	},
	{ 86,	"KNIFE | Velocity", "models/karpatia/valorant/karambit_velocity_yoru.mdl", CSW_KNIFE, 13.05 },
	{ 87,	"Smoke | ALAP", "models/karpatia/v_smokegrenade.mdl", CSW_SMOKEGRENADE, 10.05 },
	{ 88,	"HEG | ALAP", "models/karpatia/v_hegrenade.mdl", CSW_HEGRENADE, 10.05 },
	{ 89,	"Flash | ALAP", "models/karpatia/v_flashbang.mdl", CSW_FLASHBANG, 10.05 },
	{ 90,	"C4 | ALAP", "models/karpatia/v_c4.mdl", CSW_C4, 10.05 },
	{ 91,	"AK47 | Elderflame Red", "models/karpatia/valorant/ak47_elderflame_red.mdl",	CSW_AK47, 1.00 },
	{ 92,	"AWP | Elderflame Dark", "models/karpatia/valorant/elderflame_awp_dark.mdl", CSW_AWP, 1.00 },
	{ 93,	"DEAGLE | Arcane", "models/karpatia/valorant/arcane_deagle.mdl", CSW_DEAGLE, 1.00 },
	{ 94,	"M4A1 | Reaver White", "models/karpatia/valorant/reaver_m4_def.mdl", CSW_M4A1, 1.00 },
	{ 95,	"Gaya Green | KNIFE", "models/karpatia/valorant/gaya_green.mdl", CSW_KNIFE, 1.00 },
	{ 96,	"AK47 | WHITE", "models/karpatia/valorant/gaya_ak_feher.mdl",	CSW_AK47, 1.00 },
	{ 97,	"AWP | Cool Ice", "models/karpatia/valorant/awp_cool_ice.mdl", CSW_AWP, 1.00 },
	{ 98,	"DEAGLE | Reaver Ghost", "models/karpatia/valorant/reaver_usp.mdl", CSW_DEAGLE, 1.00 },
	{ 99,	"M4A1 | Champions", "models/karpatia/valorant/champions_m4.mdl", CSW_M4A1, 1.00 },
	{ 100,	"Prime2.0 | KNIFE", "models/karpatia/valorant/prime2_kes.mdl", CSW_KNIFE, 1.00 },
	{ 101,	"AK47 | Prime Blue", "models/karpatia/valorant/prime_ak_kek.mdl",	CSW_AK47, 1.00 },
	{ 102,	"AWP | Elderflame Blue", "models/karpatia/valorant/elderflame_awp_kek.mdl", CSW_AWP, 1.00 },
	{ 103,	"DEAGLE | Clouds", "models/karpatia/hianyzok/deagle/deagle_clouds.mdl", CSW_DEAGLE, 1.00 },
	{ 104,	"M4A1 | Assimov Limited", "models/karpatia/hianyzok/m4a1/m4a4_asiimov_lime.mdl", CSW_M4A1, 1.00 },
	{ 105,	"Champions | KNIFE", "models/karpatia/valorant/champions_karambit.mdl", CSW_KNIFE, 1.00 },
	{ 106,	"AK47 | Prime Default", "models/karpatia/valorant/prime_ak_def.mdl",	CSW_AK47, 1.00 },
	{ 107,	"AWP | White", "models/karpatia/hianyzok/awp/awp_white.mdl", CSW_AWP, 1.00 },
	{ 108,	"DEAGLE | Galaxy", "models/karpatia/hianyzok/deagle/deagle_galaxy.mdl", CSW_DEAGLE, 1.00 },
	{ 109,	"M4A1 | Hanami", "models/karpatia/hianyzok/m4a1/m4a4_hanami.mdl", CSW_M4A1, 1.00 },
	{ 110,  "KÉS | Bayonet Lore", "models/karpatia/hianyzok/knife/knife_bayonet_lore.mdl", CSW_KNIFE, 1.00 },
	{ 111,  "AK47 | Fire Madness", "models/karpatia/hianyzok/ak47/ak47_fire_madness.mdl",	CSW_AK47, 1.00 },
	{ 112,  "AWP | Green and Black", "models/karpatia/hianyzok/awp/awp_green_and_black.mdl", CSW_AWP, 1.00 },
	{ 113,  "DEAGLE | Lasers", "models/karpatia/hianyzok/deagle/deagle_lasers.mdl", CSW_DEAGLE, 1.00 },
	{ 114,  "M4A1 | Death Walker", "models/karpatia/hianyzok/m4a1/m4a4_death_walker.mdl", CSW_M4A1, 1.00 },
	{ 115,  "Bayonet Doppler | KNIFE", "models/karpatia/hianyzok/knife/knife_bayonet_doppler.mdl", CSW_KNIFE, 1.00 },
	{ 116,  "AK47 | Grapics Light", "models/karpatia/ak47/ak47_graphics_light.mdl", CSW_AK47, 15.23 },
	{ 117,  "AK47 | Howl", "models/karpatia/ak47/ak47_howl.mdl", CSW_AK47, 11.22 },
	{ 118,  "AK47 | Illusion", "models/karpatia/ak47/ak47_illusion.mdl", CSW_AK47, 12.13 },
	{ 119,  "AK47 | Neon Revolution", "models/karpatia/ak47/ak47_neon_revolution.mdl", CSW_AK47, 14.32 },
	{ 120,  "AK47 | Nightmare", "models/karpatia/ak47/ak47_nightmare.mdl", CSW_AK47, 25.23 },
	{ 121,  "AK47 | Obstacle", "models/karpatia/ak47/ak47_obstacle.mdl", CSW_AK47, 23.12 },
	{ 122,  "AK47 | Polar Bear", "models/karpatia/ak47/ak47_polar_bear.mdl", CSW_AK47, 17.23 },
	{ 123,  "AK47 | Purple", "models/karpatia/ak47/ak47_purple.mdl", CSW_AK47, 18.20 },
	{ 124,  "AK47 | Rampage", "models/karpatia/ak47/ak47_rampage.mdl", CSW_AK47, 14.17 },
	{ 125,  "AK47 | Red Carbon", "models/karpatia/ak47/ak47_red_carbon.mdl", CSW_AK47, 12.60 },
	{ 126,  "AK47 | Red Line", "models/karpatia/ak47/ak47_redline.mdl", CSW_AK47, 11.32 },
	{ 127,  "AK47 | Rise", "models/karpatia/ak47/ak47_rise.mdl", CSW_AK47, 15.00 },
	{ 128,  "AK47 | Starladder", "models/karpatia/ak47/ak47_starladder.mdl", CSW_AK47, 13.60 },
	{ 129,  "AK47 | Stelar", "models/karpatia/ak47/ak47_stelar.mdl", CSW_AK47, 22.31 },
	{ 130,  "AK47 | Sticker", "models/karpatia/ak47/ak47_stricker.mdl", CSW_AK47, 14.52 },
	{ 131,  "AK47 | The Empress", "models/karpatia/ak47/ak47_the_empress.mdl", CSW_AK47, 8.72 },
	{ 132,  "AK47 | Tiger Strike", "models/karpatia/ak47/ak47_tigerstrike.mdl", CSW_AK47, 13.56 },
	{ 133,  "AK47 | Transparent", "models/karpatia/ak47/ak47_transparent.mdl", CSW_AK47, 17.32 },
	{ 134,  "AK47 | Unlimited", "models/karpatia/ak47/ak47_unlimited.mdl", CSW_AK47, 9.32 },
	{ 135,  "AK47 | Vulcan", "models/karpatia/ak47/ak47_vulcan.mdl", CSW_AK47, 10.13 },
	{ 136,  "AK47 | Wasteland Rebel", "models/karpatia/ak47/ak47_wasteland_rebel.mdl", CSW_AK47, 11.20 },
	{ 137,	"M4A1 | Elite Build", "models/karpatia/m4a1/m4a1_elite_build.mdl", CSW_M4A1, 23.41 },
	{ 138,	"M4A1 | Fade", "models/karpatia/m4a1/m4a1_fade.mdl", CSW_M4A1, 17.32 },
	{ 139,	"M4A1 | Fire", "models/karpatia/m4a1/m4a1_fire.mdl", CSW_M4A1, 11.41 },
	{ 140,	"M4A1 | Flashback", "models/karpatia/m4a1/m4a1_flasback.mdl", CSW_M4A1, 25.31 },
	{ 141,	"M4A1 | Frontside Misty", "models/karpatia/m4a1/m4a1_frontside_misty.mdl", CSW_M4A1, 12.43 },
	{ 142,	"M4A1 | Golden Coil", "models/karpatia/m4a1/m4a1_golden_coil.mdl", CSW_M4A1, 8.41 },
	{ 143,	"M4A1 | Hermus", "models/karpatia/m4a1/m4a1_hermus.mdl", CSW_M4A1, 23.25 },
	{ 144,	"M4A1 | Hot Lava", "models/karpatia/m4a1/m4a1_hot_lava.mdl", CSW_M4A1, 13.23 },
	{ 145,	"M4A1 | Hyper Beast", "models/karpatia/m4a1/m4a1_hyper_beast.mdl", CSW_M4A1, 13.46 },
	{ 146,	"M4A1 | Icarus", "models/karpatia/m4a1/m4a1_icarus.mdl", CSW_M4A1, 11.91 },
	{ 147,	"M4A1 | Monstah", "models/karpatia/m4a1/m4a1_monstah.mdl", CSW_M4A1, 14.23 },
	{ 148,	"M4A1 | Neo Noir", "models/karpatia/m4a1/m4a1_neo_noir.mdl", CSW_M4A1, 17.02 },
	{ 149,	"M4A1 | Neon", "models/karpatia/m4a1/m4a1_neon.mdl", CSW_M4A1, 11.56 },
	{ 150,	"M4A1 | Nightmare", "models/karpatia/m4a1/m4a1_nightmare.mdl", CSW_M4A1, 10.25 },
	{ 151,	"M4A1 | Red", "models/karpatia/m4a1/m4a1_red.mdl", CSW_M4A1, 13.62 },
	{ 152,	"M4A1 | Red Tape", "models/karpatia/m4a1/m4a1_red_tape.mdl", CSW_M4A1, 11.23 },
	{ 153,	"M4A1 | Star", "models/karpatia/m4a1/m4a1_star.mdl", CSW_M4A1, 16.16 },
	{ 154,	"M4A1 | Vandal", "models/karpatia/m4a1/m4a1_vandal.mdl", CSW_M4A1, 11.52 },
	{ 155,	"AWP | Frontside Misty", "models/karpatia/awp/awp_frontside_misty.mdl", CSW_AWP, 14.32 },
	{ 156,	"AWP | Graffiti", "models/karpatia/awp/awp_graffiti.mdl", CSW_AWP, 18.32 },
	{ 157,	"AWP | Hyper Beast", "models/karpatia/awp/awp_hyper_beast.mdl", CSW_AWP, 13.63 },
	{ 158,	"AWP | Iron Man", "models/karpatia/awp/awp_iron_man.mdl", CSW_AWP, 11.25 },
	{ 159,	"AWP | Lightning", "models/karpatia/awp/awp_lightning.mdl", CSW_AWP, 16.25 },
	{ 160,	"AWP | Malaysia", "models/karpatia/awp/awp_malaysia.mdl", CSW_AWP, 13.11 },
	{ 161,	"AWP | Man O War", "models/karpatia/awp/awp_man_o_war.mdl", CSW_AWP, 10.68 },
	{ 162,	"AWP | Medusa", "models/karpatia/awp/awp_medusa.mdl", CSW_AWP, 16.25 },
	{ 163,	"AWP | Phobos", "models/karpatia/awp/awp_phobos.mdl", CSW_AWP, 19.23 },
	{ 164,	"AWP | Raptor", "models/karpatia/awp/awp_raptor.mdl", CSW_AWP, 21.25 },
	{ 165,	"AWP | Rave", "models/karpatia/awp/awp_rave.mdl", CSW_AWP, 23.51 },
	{ 166,	"AWP | Red Edition", "models/karpatia/awp/awp_red_edition.mdl", CSW_AWP, 11.52 },
	{ 167,	"AWP | Snow", "models/karpatia/awp/awp_snow.mdl", CSW_AWP, 16.60 },
	{ 168,	"AWP | Sticker", "models/karpatia/awp/awp_stricker.mdl", CSW_AWP, 13.56 },
	{ 169,	"AWP | Tiger", "models/karpatia/awp/awp_tiger.mdl", CSW_AWP, 19.32 },
	{ 170,	"DEAGLE | Glory", "models/karpatia/deagle/deagle_glory.mdl", CSW_DEAGLE, 11.52 },
	{ 171,	"DEAGLE | Jungle", "models/karpatia/deagle/deagle_jungle.mdl", CSW_DEAGLE, 16.32 },
	{ 172,	"DEAGLE | Jupiters", "models/karpatia/deagle/deagle_jupiters.mdl", CSW_DEAGLE, 21.25 },
	{ 173,	"DEAGLE | Orochi", "models/karpatia/deagle/deagle_orochi.mdl", CSW_DEAGLE, 11.26 },
	{ 174,	"DEAGLE | Oxide Blaze", "models/karpatia/deagle/deagle_oxide_blaze.mdl", CSW_DEAGLE, 17.41 },
	{ 175,	"DEAGLE | Rusted Metal", "models/karpatia/deagle/deagle_rusted_metal.mdl", CSW_DEAGLE, 16.31 },
	{ 176,	"DEAGLE | Stoner", "models/karpatia/deagle/deagle_stoner.mdl", CSW_DEAGLE, 23.62 },
	{ 177,	"DEAGLE | Utopian Dreams", "models/karpatia/deagle/deagle_utopian_dreams.mdl", CSW_DEAGLE, 17.22 },
	{ 178,	"DEAGLE | Wild Fire", "models/karpatia/deagle/deagle_wild_fire.mdl", CSW_DEAGLE, 13.22 },
	{ 179,	"Tron Purple2 | KNIFE", "models/karpatia/knife/kknife_tron_colors_purplev2.mdl", CSW_KNIFE, 6.89 },
	{ 180,	"Tron Red2 | KNIFE", "models/karpatia/knife/knife_tron_colors_redv2.mdl", CSW_KNIFE, 5.89 }
	
};
new g_PlayerHWA[33][FEGYO];

new const MutasdPrefixet[][jOgR] =
{
	{ "Játékos"	},			//[0]
	{ "Tulajdonos"	},		//[1]
	{ "Tulaj Helyettes"	},	//[2]
	{ "Főadmin"	},			//[3]
	{ "Admin"	},			//[4]
	{ "Kezdő Admin"	},		//[5]
	{ "PRÉMIUM V.I.P"	},	//[6]
	{ "V.I.P"	},			//[7]
	{ "Kis VIP"	},			//[8]
	{ "Támogató"	},			//[9]
	{ "Pici:3"	},			//[10]
	{ "Top1"	},				//[11]
	{ "Top2"	},				//[12]
	{ "Top3"	},				//[13]
	{ "Fragverseny királya"	},	//[14]
	{ "STREAMER"	},		//[15]
	{ "YouTuber [LVL 2]"	},		//[16]
	{ "YouTuber [LVL 3]"	},		//[17]
	{ "YouTuber [LVL 4]"	},		//[18]
	{ "YouTuber [LVL 5]"	},	//[19]
	{ "Aladár az aszfaltos"	},		//[20]
	{ "FürDich"	},		//[21]
	{ "3 Napos VIP"	},		//[22]
	{ "1 Hetes VIP"	},		//[23]
	{ "PRÉMIUM TAG" },		//[24]
	{ "BYPASS TAG" },		//[25]
	{ "QUEEN" },		//[26]
	{ "Fejlesztő" }		//[27]
};
new const AllMusic[][zenek] =
{
	{ "ALAP ZENE",	"sound/karpatia_zene/alapszam.mp3", 0	}, 
	{ "Sej Haj Akácfa",	"sound/karpatia_zene/sejhajakacfa.mp3", 0	}, 
	{ "Száz forintnak",	"sound/karpatia_zene/szazforintnak.mp3", 0	}, 
	{ "Zsebembe nem férnek az eurók",	"sound/karpatia_zene/zsebembenemfernekazeruok.mp3", 0	}, 
	{ "ALORS ON DANSE",	"sound/karpatia_zene/alorsondanse.mp3", 0	}, 
	{ "Balenciaga",	"sound/karpatia_zene/balenciaga.mp3", 0	}, 
	{ "Beton.Hofi,Hundred Sins - BAGIRA",	"sound/karpatia_zene/bagira.mp3", 0	}, 
	{ "DESH - MALIBU",	"sound/karpatia_zene/malibu.mp3", 0	}, 
	{ "Farruko - Pepas",	"sound/karpatia_zene/pepas.mp3", 0	}, 
	{ "KKevin - Fekete Bárány",	"sound/karpatia_zene/feketebarany.mp3", 0	}, 
	{ "L.L. Junior feat. Kenedi Veronika - Úgy szeretnék",	"sound/karpatia_zene/szeretnek.mp3", 0 } , 
	{ "Timbaland - Give It To Me",	"sound/karpatia_zene/giveme.mp3", 0 } , 
	{ "VZS - A testvérek összefognak",	"sound/karpatia_zene/ossze.mp3", 0 } 
};
new const LenStars[][] = {
	"",
	"*",
	"**",
	"***",
	"****",
	"*****",
	"******",
	"*******",
	"********",
	"*********",
	"**********",
	"***********",
	"************",
	"*************",
	"**************",
	"***************",
	"****************"
};

enum _:eRank{eRankNum, eRankName[64], eRankTime,};
new const cRanks[MAXRANK][eRank] ={
	{0, "Újonc Admin", 0},	//(rang száma), (rang neve), (rang ideje mpben. [30 perc = 1800mp | 60 perc = 3600mp] ..stb)
	{1, "Kezdő Admin", 18000},	//5 óra 				1óra 3600 másodperc
	{2, "Haladó Admin", 54000},	//15 óra
	{3, "Admin", 108000}	//30 óra
};


enum _:ePlayer{eTime, eRanks,};
new g_ePlayer[ePlayer][MAXPLAYERS];

new bool:FegyverMenuTiltas = false;
public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	/*-----[ Parancsok ]------*/
	register_impulse(201, "openMainMenu");
	
	register_clcmd("say /menu", "openMainMenu");
	register_clcmd("say /fegyver", "weaponSearch");
	register_clcmd("say /gun", "weaponSearch");
	register_clcmd("say /guns", "weaponSearch");
	register_clcmd("say /kor", "szerokoreleje");
	register_clcmd("say /idm", "miazidm");
	register_clcmd("say /vip", "premiumvipcsomag");
	register_clcmd("say /szeretlekpatrikeh", "bypass_adjidot");
	register_clcmd("say /rang", "Rangsorol");
	//register_clcmd("say /rank", "Rangsorol");
	//register_concmd("set_admin", "CmdSetAdmin", _, "<#id> <jog>");
	
	 /*-----[ Fegyver Lekérések ]------*/

	RegisterHam(Ham_Item_Deploy, "weapon_m4a1", "Change_Weapon5", 1);
	RegisterHam(Ham_Item_Deploy, "weapon_ak47", "Change_Weapon4", 1);
	RegisterHam(Ham_Item_Deploy, "weapon_awp", "Change_Weapon3", 1);
	RegisterHam(Ham_Item_Deploy, "weapon_deagle", "Change_Weapon1", 1);
	RegisterHam(Ham_Item_Deploy, "weapon_knife", "Change_Weapon2", 1);
	RegisterHam(Ham_Item_Deploy, "weapon_smokegrenade", "Change_Weapon6", 1);
	RegisterHam(Ham_Item_Deploy, "weapon_hegrenade", "Change_Weapon6", 1);
	RegisterHam(Ham_Item_Deploy, "weapon_flashbang", "Change_Weapon6", 1);
	RegisterHam(Ham_Item_Deploy, "weapon_c4", "Change_Weapon6", 1);

	/*-----[ Lekérések ]------*/
	register_clcmd("FELHASZNALONEV", "cmdFelhasznalonev"); 
	register_clcmd("JELSZAVAD", "cmdJelszo");
	register_clcmd("JELSZAVAD_UJRA", "cmdJelszo1");
	register_clcmd("EMAIL", "cmdEmail");
	
	register_clcmd("Reg_nevcedula1", "ak47regisztralas_nevcedula");
	register_clcmd("Reg_nevcedula2", "m4regisztralas_nevcedula");
	register_clcmd("Reg_nevcedula3", "awpregisztralas_nevcedula");
	register_clcmd("Reg_nevcedula4", "deagregisztralas_nevcedula");
	register_clcmd("Reg_nevcedula5", "kesregisztralas_nevcedula");

	register_clcmd("Mennyit_szeretnel_elkuldeni", "oles_kuld");
	register_clcmd("Mennyit_szeretnel_elvenni", "oles_elvetel");
	register_clcmd("Reg_Prefix", "regisztralas_prefix");
	register_clcmd("hanyas_rangot_adsz", "rangadasos_kuld");
	register_clcmd("adjal_fagyasztast", "fagyasztast_kuld");
	register_clcmd("adjal_kredit", "kredit_kuld");
	register_clcmd("KMENNYISEG", "ObjectSend");
	register_clcmd("KMENNYISEGSKIN", "ObjectSendSkin");

	//Trade System by Kova
	register_clcmd("tSetMoney", "tSetMoney");
	register_clcmd("say /fogad", "cmdDeal");

	
	/*-----[ iLen-es menükhöz ]------*/
	register_menu("openMainMenu", 1023, "hopenmain");
	register_menu("openQuestMenu", 1023, "h_openQuestMenu");
	register_menu("fOMENURaktar", 1023, "valasz_skinek");
	register_menu("LadaNyitas", 1023, "ladanyitasok");
	register_menu("showMenu_Main", 1023, "h_openRegisterMainMenu");
	register_menu("openGunMenu", 1023, "h_openGunMenu");
	register_menu("adminreszleg", 1023, "h_adminresz");
	register_menu("nevcedRaktar", 1023, "nevcvalasz_skinek");
	register_menu("kereskedelem", 1023, "kereskedelem_h");
	register_menu("szerverbolt", 1023, "szerverbolt_h");
	register_menu("bypass_fomenu", 1023, "bypass_h");
	register_menu("Beallitasok", 1023, "Beallitasok_h");
	
	/*-----[ Eventek ]------*/
	
	register_logevent("szerokoreleje", 2, "0=World triggered", "1=Round_Start");
	register_event("HLTV", "EVENT_RoundStart", "a", "1=0", "2=0")	
	register_think(szGiftClassname, "forward_GiftThink");
	gInfoTarget = engfunc(EngFunc_AllocString, "info_target");
 
	register_touch(szGiftClassname, "player", "forward_TouchGift");
	
	/*-----[ HUD ]------*/
 
	
	aSync = CreateHudSyncObj();
	bSync = CreateHudSyncObj();
	
	gMaxPlayers = get_maxplayers();

	/*-----[ Eventek ]------*/
	register_event("DeathMsg", "Halal", "a");
	register_event("DeathMsg", "EVENT_DeathMsg", "a");

	RegisterHam(Ham_Spawn,"player","korkezdespalyaval",1);
	RegisterHam(Ham_Spawn,"player","resetModels",1);
	register_logevent("fagyellenorzes", 2, "0=World triggered", "1=Round_Start");
	register_logevent("hostage_rescued",3,"2=Rescued_A_Hostage");
	register_logevent("hostage_touched",3,"2=Touched_A_Hostage");
	register_logevent("RoundEnds", 2, "1=Round_End");
	register_logevent("ElsoKor", 2, "0=World triggered", "1&Restart_Round_");
	register_logevent("ElsoKor", 2, "0=World triggered", "1=Game_Commencing");

	
	RegisterHam(Ham_Killed, "player", "fwdKilledPost");

	
	/*-----[ Lekérések ]------*/
	set_task(1.0, "AutoCheck",_,_,_,"b");
	set_task(1.0, "fagyellenorzes",_,_,_,"b");
	//set_task(5.0, "hirdesstekurva",_,_,_,"b");
	/*-----[ Chat részlet ]------*/
	SayText = get_user_msgid("SayText");
	register_clcmd("say", "sayhook");
	register_clcmd("say_team", "saythook");
	//register_clcmd("say", "sayhook");
	//register_clcmd("say_team", "sayhook");
	
	new sMapName[32];
	get_mapname(sMapName, charsmax(sMapName));

	
	/*-----[AWP FEGYVER KORLÁT]-----*/
	
	awpkoralt = register_cvar("awp_korlat", "3");

	/*-----[ Pálya Lekérések ]------*/
	if(containi( sMapName, "awp" ) != -1)
		FegyverMenuTiltas = true;
	if(containi( sMapName, "awp4one" ) != -1)
		FegyverMenuTiltas = true;
	else if(containi(sMapName, "de") != -1)
		FegyverMenuTiltas = false;
	else if(containi(sMapName, "css") != -1)
		FegyverMenuTiltas = false;
	else if(containi(sMapName, "he") != -1)
		FegyverMenuTiltas = true;
	else if(containi(sMapName, "fy") != -1)
		FegyverMenuTiltas = true;
	else if(containi(sMapName, "35hp") != -1)
		FegyverMenuTiltas = true;
	else if(containi(sMapName, "aim") != -1)
		FegyverMenuTiltas = true;
	else if(containi( sMapName, "scout") != -1)
	{
		
		FegyverMenuTiltas = true;
		RegisterHam(Ham_Spawn,"player","scoutkezdes",1);
		new scout_gravity = get_pcvar_num( register_cvar( "scout_gravity", "215" ) );
		server_cmd( "sv_gravity %d", scout_gravity );
	}	

		/*-----[ ajandek doboz ]------*/
	// set_task(300.0, "keszit",_,_,_,"b");
	set_task(1.0, "szamlalo",_,_,_,"b");
	register_touch("nyeremendoboz","player","remove");
	cvar = register_cvar("sv_maxdoboz", "0");
}
public hirdesstekurva()
{
	ColorChat(0, GREEN, "%s - A szerver új ipcímre költözött, kérlek mentsd el az IP-t: 45.67.159.217:27015", C_Prefix);
}
public miazidm(id)
{
	ColorChat(id, GREEN, "%s A te Account Id-d: ^4%i", C_Prefix, g_adatok[g_Id][id])
}
public ElsoKor()
{
	gSzamolas = 0;
}	
public fagyellenorzes(id)
{
	for(new id = 1; id < 33; id++)
	{
		if(g_playerData[fagyaszto][id] >=	1)
		{
			set_pev(id, pev_flags, pev(id, pev_flags) | FL_FROZEN);
			pev(id, pev_v_angle, 0.0);
		}
	}
}
public bypass_check(id)
{
	if(g_playerData[MPrefi][id] == 25 || g_playerData[MPrefi][id] == 1)
	{	
	if(g_Erdem[eRanks][id] == MAXRANK)
	return FMRES_IGNORED;
	
	
	
	new sName[64], iTime;
	
	iTime = g_Erdem[eTime][id] + get_user_time(id);
	get_user_name(id, sName, charsmax(sName));

	if(g_Erdem[eTime][id] < 0)
		g_Erdem[eTime][id] = 0
	
	if(iTime >= ErdemErme[g_Erdem[ErdemSzint][id]][ErdemIdeje])
	{
		kibestat[id]++;
		ColorChat(0, GREEN, "^4[ByPass]^3 %s^1 elérte ^4 %s.^3GRATULÁLUNK!", sName, ErdemErme[g_Erdem[ErdemSzint][id]][ErdemNevek]);

		ColorChat(id, GREEN, "^1--------===^3[^4 KÁRPÁTIA ByPass Előfizetés^3 ]^1===--------");
		ColorChat(id, GREEN, "^4[ByPass]^1 Sikeresen előre léptél^4 +1 Szintet!^3 ByPass Rendszer^1 menüben vedd át a^4 jutalmad!");
		ColorChat(id, GREEN, "^1--------===^3[^4 KÁRPÁTIA ByPass Előfizetés^3 ]^1===--------");
		}
}
	return FMRES_SUPERCEDE;
}

public vipCheck(id)
{
	if(g_playerData[MPrefi][id] == 22 || g_playerData[MPrefi][id] == 6)
	{
		if(g_VipTime[id] >= 10)
			Update(id, 1);
		else if(g_VipTime[id] <= 10)
		{
			g_playerData[MPrefi][id] = 0;
			g_VipTime[id] = 0;
			Update(id, 0);
			ColorChat(id, GREEN, "Sajnálom, lejárt az 1 hetes VIP-d!");
		}
	}
}
public EXPcheck(id)
{
	new Float:EXPEuro;
	EXPEuro += random_float(100.00,100.00);

	

	if(Player[id][Euro] >= 100.00)
	{
		g_playerData[Rang][id] += 1;
		Player[id][Euro] -= EXPEuro;
		Update(id, 0);

		new nev[32]; get_user_name(id, nev, 31);

		ColorChat(id, GREEN, "^4[K]ÁRPÁTI[A]^3» ^1A rangod növekedett!");
		ColorChat(0, GREEN, "^4[K]ÁRPÁTI[A]^3» ^1 Szintet lépett:^3 %s", nev);
	}
	if(Player[id][Euro] < 0.00)
	{
		Player[id][Euro] = 0.00;
	}
}


public AutoCheck()
{
	new p[32],n;
	get_players(p,n,"ch");
	for(new i=0;i<n;i++)
	{
		new id = p[i];
		if(Hud[id])
			InfoHud(id);
	}
}
public CheckRank_p(id)
{
	if(g_playerData[MPrefi][id] == 4)
	{
	if(g_ePlayer[eRanks][id] == MAXRANK)
	return FMRES_IGNORED;
	
	
	
	new sName[64], iTime;
	
	iTime = g_ePlayer[eTime][id] + get_user_time(id);
	get_user_name(id, sName, charsmax(sName));
	
	
	if(iTime >= cRanks[g_ePlayer[eRanks][id]][eRankTime])
	{
		g_ePlayer[eRanks][id]++;
		ColorChat(id, GREEN, "^4[ADMIN SZINT]^3 %s^4 %s^1 rangba lépett!", sName, cRanks[g_ePlayer[eRanks][id]][eRankName]);
		}
	}
	return FMRES_SUPERCEDE;
}
public InfoHud(id)
{ 
	new m_Index;
	
	if(is_user_alive(id))
		m_Index = id;
	else
		m_Index = entity_get_int(id, EV_INT_iuser2);

	new Nev[32];
	get_user_name(m_Index, Nev, 31);
	new iMasodperc, iPerc, iOra, iNap;
	iMasodperc = Masodpercek[m_Index] + get_user_time(m_Index);
	iPerc = iMasodperc / 60;
	iOra = iPerc / 60;
	iMasodperc = iMasodperc - iPerc * 60;
	iPerc = iPerc - iOra * 60;
	iNap = iOra / 24;
	new ctime[64], cdate[64];
	get_time("%H:%M:%S", ctime, 63);
	get_time("%d.%m.%Y", cdate, 63);
	static stats[8], stats2[4];
	get_user_stats2(m_Index, stats2);
	
	new ibyMasodperc, ibyPerc, ibyOra, ibyNap;
	if(g_playerData[MPrefi][m_Index] == 25)
		ibyMasodperc = g_Erdem[eTime][m_Index] + get_user_time(m_Index);

	ibyPerc = ibyMasodperc / 60;
	ibyOra = ibyPerc / 60;
	ibyMasodperc = ibyMasodperc - ibyPerc * 60;
	ibyPerc = ibyPerc - iOra * 60;
	ibyNap = ibyOra / 24;

	new HudString1[512], HudString2[512];
			
	new iLen, iLen2;

	iLen += formatex(HudString1[iLen], 512,"Név: ^n^n");
	iLen2 += formatex(HudString2[iLen2], 512,"					 %s (#%d)^n^n", Nev, g_adatok[g_Id][m_Index]);

	if(g_playerData[MPrefi][m_Index] == 25)
	{
		iLen += formatex(HudString1[iLen], 512,"ByPAss idő: ^n");
		iLen2 += formatex(HudString2[iLen2], 512,"											%d Nap |	%d Óra^n", ibyNap, ibyOra);
	}
	
	iLen += formatex(HudString1[iLen], 512,"ByPAss Szint: ^n");
	iLen2 += formatex(HudString2[iLen2], 512,"											  %s^n", ErdemErme[g_Erdem[ErdemSzint][m_Index]][ErdemNevek]);

	iLen += formatex(HudString1[iLen], 512,"Prefix: ^n");
	iLen2 += formatex(HudString2[iLen2], 512,"					  %s^n", prefiszem[m_Index]);


	iLen += formatex(HudString1[iLen], 512,"Játszott idő: ^n");
	iLen2 += formatex(HudString2[iLen2], 512,"									  	 %d Nap |	%d Óra |	%d Perc^n", iNap, iOra, iPerc);

	iLen += formatex(HudString1[iLen], 512,"Jelenlegi idő: ^n");
	iLen2 += formatex(HudString2[iLen2], 512,"										    %s^n", ctime, cdate);

	iLen += formatex(HudString1[iLen], 512,"Szint lépés(EXP): ^n");
	iLen2 += formatex(HudString2[iLen2], 512,"														   %3.2f%/100.00%%%% ^n", Player[m_Index][Euro]);

	if(g_playerData[ExpBoost][m_Index] >= 1)
	{
	iLen += formatex(HudString1[iLen], 512,"EXP BOOST: ^n");
	iLen2 += formatex(HudString2[iLen2], 512,"														   AKTÍV ^n");
	}

	set_hudmessage(23, 255, 30, 0.01, 0.15, 0, 6.0, 1.1, 0.0, 0.0, -1);
	ShowSyncHudMsg(id, aSync, HudString1);

	set_hudmessage(255, 255, 0, 0.01, 0.15, 0, 6.0, 1.1, 0.0, 0.0, -1);
	ShowSyncHudMsg(id, bSync, HudString2);

	if(is_user_alive(m_Index) && g_adatok[hudszin][m_Index] == 0)
	{
		set_hudmessage(random(256), random(256), random(256), 0.01, 0.15, 0, 6.0, 1.1, 0.0, 0.0, next_hudchannel(id));
		ShowSyncHudMsg(id, bSync, HudString2);
	}
	else if(is_user_alive(m_Index) && g_adatok[hudszin][m_Index] == 1)
	{
		set_hudmessage(0, 255, 0, 0.01, 0.15, 0, 6.0, 1.1, 0.0, 0.0, next_hudchannel(id));
		ShowSyncHudMsg(id, bSync, HudString2);
	}
}

public m_Addolas(id)
{
	if(get_user_flags(id) & TULAJ)
	{
		Oles[id] += 10;
		Lada[0][id] += 1000;
		g_playerData[Kulcs][id] += 1000;
	}
}

public plugin_precache()
{

	for(new i;i < sizeof(Fegyverek); i++) precache_model(Fegyverek[i][ModelName]);

	for(new i = 0; i < sizeof gGiftModels; i++) precache_model(gGiftModels[i]);


	for(new i;i < sizeof(AllMusic); i++) precache_generic(AllMusic[i][mp3ak]);
	
	precache_model("models/player/ct/ct.mdl");
	precache_model("models/player/t/t.mdl");

	precache_model("models/player/ctvip/ctvip.mdl");
	precache_model("models/player/tvip/tvip.mdl");
   

}
public Change_Weapon6(iEnt)
{
	if(!pev_valid(iEnt))
		return HAM_IGNORED;

	new id = get_pdata_cbase(iEnt, 41, 4);

	if(is_user_alive(id))
	{


	new iWeapon = cs_get_weapon_id(iEnt);
		 
	switch(iWeapon)
	{
	case CSW_SMOKEGRENADE: entity_set_string(id, EV_SZ_viewmodel,	Fegyverek[Selectedgun[id][SMOKE]][ModelName]);
	case CSW_HEGRENADE: entity_set_string(id, EV_SZ_viewmodel,	Fegyverek[Selectedgun[id][HEG]][ModelName]);
	case CSW_FLASHBANG: entity_set_string(id, EV_SZ_viewmodel,	Fegyverek[Selectedgun[id][FLASH]][ModelName]);
	case CSW_C4: entity_set_string(id, EV_SZ_viewmodel,	Fegyverek[Selectedgun[id][C4]][ModelName]);

	}
	}
	return HAM_IGNORED;
}

public Change_Weapon1(iEnt)
{
	if(!pev_valid(iEnt))
		return HAM_IGNORED;

	new id = get_pdata_cbase(iEnt, 41, 4);

	if(is_user_alive(id))
	{


	new iWeapon = cs_get_weapon_id(iEnt);
		 
	switch(iWeapon)
	{
	case CSW_DEAGLE: entity_set_string(id, EV_SZ_viewmodel,	Fegyverek[Selectedgun[id][DEAGLE]][ModelName]);

	}
	}
	return HAM_IGNORED;
}

public Change_Weapon2(iEnt)
{
	if(!pev_valid(iEnt))
		return HAM_IGNORED;

	new id = get_pdata_cbase(iEnt, 41, 4);

	if(is_user_alive(id))
	{


	new iWeapon = cs_get_weapon_id(iEnt);
		 
	switch(iWeapon)
	{
	case CSW_KNIFE: entity_set_string(id, EV_SZ_viewmodel,	Fegyverek[Selectedgun[id][KNIFE]][ModelName]);
		}
	}
	return HAM_IGNORED;
}

public Change_Weapon3(iEnt)
{
	if(!pev_valid(iEnt))
		return HAM_IGNORED;

	new id = get_pdata_cbase(iEnt, 41, 4);

	if(is_user_alive(id))
	{


	new iWeapon = cs_get_weapon_id(iEnt);
		 
	switch(iWeapon)
	{
	case CSW_AWP: entity_set_string(id, EV_SZ_viewmodel,	Fegyverek[Selectedgun[id][AWP]][ModelName]);
		}
	}
	return HAM_IGNORED;
}

public Change_Weapon4(iEnt)
{
	if(!pev_valid(iEnt))
		return HAM_IGNORED;

	new id = get_pdata_cbase(iEnt, 41, 4);

	if(is_user_alive(id))
	{


	new iWeapon = cs_get_weapon_id(iEnt);
		 
	switch(iWeapon)
	{
	case CSW_AK47: entity_set_string(id, EV_SZ_viewmodel,	Fegyverek[Selectedgun[id][AK47]][ModelName]);
		}
	}
	return HAM_IGNORED;
}
public Change_Weapon5(iEnt)
{
	if(!pev_valid(iEnt))
		return HAM_IGNORED;

	new id = get_pdata_cbase(iEnt, 41, 4);

	if(is_user_alive(id))
	{


	new iWeapon = cs_get_weapon_id(iEnt);
		 
	switch(iWeapon)
	{
	case CSW_M4A1: entity_set_string(id, EV_SZ_viewmodel,	Fegyverek[Selectedgun[id][M4A1]][ModelName]);
		}
	}
	return HAM_IGNORED;
}


public resetModels(id)
{
	if(g_playerData[MPrefi][id]	>= 1)
	{
		if(cs_get_user_team(id) == CS_TEAM_T) cs_set_user_model(id, "tvip")
		else if(cs_get_user_team(id) == CS_TEAM_CT) cs_set_user_model(id, "ctvip")
	}
	else 
	{
		if(cs_get_user_team(id) == CS_TEAM_T) cs_set_user_model(id, "t")
		else if(cs_get_user_team(id) == CS_TEAM_CT) cs_set_user_model(id, "ct")
	}

	return PLUGIN_CONTINUE
}


public	openMainMenu(id) 
{
	if(!g_LoggedIn[id])
	{
		showMenu_Main(id)
		return PLUGIN_HANDLED
	}
	static menu[512],len;
	len = 0;

	len = formatex(menu[len], charsmax(menu) - len, "%s^n \yEuro:\w	%3.2f \r| \yPrémium Pont:\w %d^n^n", Prefix, penzem[id][penz], g_playerData[SMS][id]);
	
	len += formatex(menu[len], charsmax(menu) - len, "\r[1] \y»\w RAKTÁR^n");
	len += formatex(menu[len], charsmax(menu) - len, "\r[2] \y»\w Szerver Bolt^n");
	len += formatex(menu[len], charsmax(menu) - len, "\r[3] \y»\w LÁDA NYITÁS ^n");
	len += formatex(menu[len], charsmax(menu) - len, "\r[4] \y»\w ZENE KÉSZLET^n");
	len += formatex(menu[len], charsmax(menu) - len, "\r[5] \y»\r ByPASS Előfizetés^n");
	len += formatex(menu[len], charsmax(menu) - len, "\r[6] \y»\w KÜLDETÉSEK^n");
	len += formatex(menu[len], charsmax(menu) - len, "\r[7] \y»\w BEÁLLÍTÁSOK^n");
	len += formatex(menu[len], charsmax(menu) - len, "\r[8] \y»\w ADMIN Részleg^n^n");
	len += formatex(menu[len], charsmax(menu) - len, "\y»\w Kilépés a menüből \y»» [9] Gomb^n");
	 
	len += formatex(menu[len], charsmax(menu) - len, "\y»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»^n");
	len += formatex(menu[len], charsmax(menu) - len, "\y»\dSzerver IP:	 \w87.229.115.198:27041 ^n");
	len += formatex(menu[len], charsmax(menu) - len, "\y»\dMod Verzió:\y 2.1 \d||\w by TwisT^n");
	
	new keys = MENU_KEY_0|MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6|MENU_KEY_7|MENU_KEY_8|MENU_KEY_9;
	show_menu(id, keys, menu, -1, "openMainMenu");
	return PLUGIN_HANDLED;	
}	


public hopenmain(id,key)
 {
 
	new randomKills = random_num(5,25);
	new randomWeapon = random_num(0,5);
	new randomHead = random_num(0,1);
	new randomPremium = random_num(50,300);
	
	switch(key) 
	{
		case 0: fOMENURaktar(id);
		case 1:	szerverbolt(id);
		case 2:	LadaNyitas(id);
		case 3:	zene_kivalasztas(id);
		case 4:	bypass_fomenu(id);
		case 5:
		{
			if(g_AdatV2[g_Quest][id] == 0)
			{
				g_QuestKills[0][id] = randomKills;
				g_AdatV2[g_QuestWeapon][id] = randomWeapon;
				g_AdatV2[g_QuestHead][id] = randomHead;
				g_Jutalom[2][id] = randomPremium;
				g_AdatV2[g_Quest][id] = 1;
				openQuestMenu(id);
			}
			else
				openQuestMenu(id);
		}
		case 6:	Beallitasok(id);
		case 7:	
		{
			if(get_user_flags(id) & TULAJ)
				adminreszleg(id);
			else
				ColorChat(id, GREEN, "^4[K]ÁRPÁTI[A]- FUN » ^1Ezt a menüt csak ^4Tulajdonos ^1használhatja!");
		}
		case 8:	return PLUGIN_HANDLED;
	}
	return PLUGIN_HANDLED;
}
public adminreszleg(id)
{
	static menu[512],len;
	len = 0;

	len = formatex(menu[len], charsmax(menu) - len, "%s^n Admin Részleg^n^n", Prefix);
	
	len += formatex(menu[len], charsmax(menu) - len, "\r[1] \y»\w Adatkezelés\r^n");
	len += formatex(menu[len], charsmax(menu) - len, "\r[2] \y»\w Fagyasztás\r^n");

	new keys = MENU_KEY_0|MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6|MENU_KEY_7|MENU_KEY_8|MENU_KEY_9;
	show_menu(id, keys, menu, -1, "adminreszleg");
	return PLUGIN_HANDLED;	
}	
public h_adminresz(id, key)
{
	switch(key)
	{
		case 0:adatkezelo(id); 
		case 1:fagyasztasom(id);	 
	}
	return PLUGIN_HANDLED;
}
public openQuestMenu(id)
{
	static menu[512],len;
	len = 0;

	new const QuestWeapons[][] = { "AK47", "M4A1", "AWP", "DEAGLE", "AWP", "AK47", "M4A1", "DEAGLE", "KNIFE", "Nincs" };
	new const QuestHeadKill[][] = { "Nincs", "Csak fejlövés" };

	len = formatex(menu[len], charsmax(menu) - len, "%s^n", Prefix, penzem[id][penz], g_playerData[SMS][id]);
	

	len += formatex(menu[len], charsmax(menu) - len, "\wFeladat: \yÖlj meg\w %d\y játékost^n", g_QuestKills[0][id]);
	 
	len += formatex(menu[len], charsmax(menu) - len, "\dKüldetéshez kell még\y %d\w ölés^n", g_QuestKills[0][id]-g_QuestKills[1][id]);
	len += formatex(menu[len], charsmax(menu) - len, "\dÖlés Korlát: \y%s^n", QuestHeadKill[g_AdatV2[g_QuestHead][id]]);
	len += formatex(menu[len], charsmax(menu) - len, "\wFegyver Korlát: \y%s \w(\yAKTÍV\w)^n", QuestWeapons[g_AdatV2[g_QuestWeapon][id]]);
	 
	len += formatex(menu[len], charsmax(menu) - len, "\y»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»^n");
	len += formatex(menu[len], charsmax(menu) - len, "\wJutalom:^n\yPrémium Pont [%d P.P]^n", g_Jutalom[2][id]);
	len += formatex(menu[len], charsmax(menu) - len, "\y»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»^n^n");

	len += formatex(menu[len], charsmax(menu) - len, "\y»\w Kilépéshez nyomj meg egy\y Számot^n", "MENU_KEY_9");


	new keys = MENU_KEY_0|MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6|MENU_KEY_7|MENU_KEY_8|MENU_KEY_9;
	show_menu(id, keys, menu, -1, "openQuestMenu");
	return PLUGIN_HANDLED; 
}
public h_openQuestMenu(id)
	return PLUGIN_HANDLED;

public fOMENURaktar(id)
{
	static menu[512],len;
	len = 0;


	len = formatex(menu[len], charsmax(menu) - len, "%s^n^n", Prefix);
	
	len += formatex(menu[len], charsmax(menu) - len, "\r[1] \y» AWP SKIN^n");
	len += formatex(menu[len], charsmax(menu) - len, "\r[2] \y» AK47 SKIN^n");
	len += formatex(menu[len], charsmax(menu) - len, "\r[3] \y» M4A1 SKIN^n");
	len += formatex(menu[len], charsmax(menu) - len, "\r[4] \y» DEAGLE SKIN^n");
	len += formatex(menu[len], charsmax(menu) - len, "\r[5] \y» KNIFE SKIN^n");
	len += formatex(menu[len], charsmax(menu) - len, "\r[6] \y» LIMITÁLT SKIN^n");
	len += formatex(menu[len], charsmax(menu) - len, "\r[7] \y» PRÉMIUM VIP Csomag^n^n");
	len += formatex(menu[len], charsmax(menu) - len, "\r[8] \y» Fegyver Névcédula \r[5000 Prémium Pont]^n");
	len += formatex(menu[len], charsmax(menu) - len, "\r[9] \y» Kereskedelem/Csere^n^n");
	len += formatex(menu[len], charsmax(menu) - len, "\y»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»^n");
	len += formatex(menu[len], charsmax(menu) - len, "\y»\dMod Verzió:\y 2.1 \d||\w by TwisT^n");
	
	new keys = MENU_KEY_0|MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6|MENU_KEY_7|MENU_KEY_8|MENU_KEY_9;
	show_menu(id, keys, menu, -1, "fOMENURaktar");
	return PLUGIN_HANDLED;	
}
public valasz_skinek(id,key)
{	
	switch(key) 
	{
		case 0: awp_menu(id);
		case 1: ak47_menu(id);
		case 2: m4a1_menu(id);
		case 3: deagle_menu(id);
		case 4: kes_menu(id);
		case 5: limitalt_menu(id);
		case 6:
		if(1 <= g_playerData[MPrefi][id] <= 6)
			{
			ujpremium_menu(id);	
			}	 
		else 
			{
				ColorChat(id, GREEN, "^4[K]ÁRPÁTI[A]- FUN » ^1Ezt a menüt csak ^4Prémium VIP ^1használhatja!");
			}	 
		case 7:	 
		{
			if(g_playerData[SMS][id] >= 5000)
			{
				g_playerData[SMS][id] = 5000;
				nevcedRaktar(id);

			}
			else
				ColorChat(id, GREEN, "%s ^1Nincs elég Prémium Pontod", C_Prefix);
		}
		case 8:	kereskedelem(id);
		case 9:	return PLUGIN_HANDLED;
	 }
}
public ujpremium_menu(id) 
{
Selectedgun[id][AK47] = 82;
Selectedgun[id][M4A1] = 83;
Selectedgun[id][AWP] = 84;
Selectedgun[id][DEAGLE] = 85;
Selectedgun[id][KNIFE] = 86;
ColorChat(id, GREEN, "^4[K]ÁRPÁTI[A]- FUN » ^1Sikeresen felszerelted: ^3Prémium VIP Csomagot");
}

public awp_menu(id)
{
	new szMenu[121],String[6]
	formatex(szMenu, charsmax(szMenu), "|K|ÁRPÁTI|A|~\wAWP SKINEK")
	new menu = menu_create(szMenu, "hRaktarom");
 
	for(new i;i < sizeof(Fegyverek); i++)
	{
		if(27 <= Fegyverek[i][g_WeapID] <= 40)	
		{
		if(g_PlayerHWA[id][i] > 0)
		{
			formatex(szMenu, charsmax(szMenu), "%s \r[\y%i \rDB]", Fegyverek[i][Name], g_PlayerHWA[id][i]);
			num_to_str(i, String, 5);
			menu_additem(menu, szMenu, String);
			}
		}
	}
	menu_display(id, menu, 0);
}

public ak47_menu(id)
{
	new szMenu[121],String[6]
	formatex(szMenu, charsmax(szMenu), "|K|ÁRPÁTI|A|~\wAK47 SKINEK")
	new menu = menu_create(szMenu, "hRaktarom");
 
	for(new i;i < sizeof(Fegyverek); i++)	
	{
		if(5 <= Fegyverek[i][g_WeapID] <= 15)
		{
		if(g_PlayerHWA[id][i] > 0)
		{
			formatex(szMenu, charsmax(szMenu), "%s \r[\y%i \rDB]", Fegyverek[i][Name], g_PlayerHWA[id][i]);
			num_to_str(i, String, 5);
			menu_additem(menu, szMenu, String);
			}
	}
}
	menu_display(id, menu, 0);
}

public m4a1_menu(id)
{
	new szMenu[121],String[6]
	formatex(szMenu, charsmax(szMenu), "|K|ÁRPÁTI|A|~\wM4A1 SKINEK")
	new menu = menu_create(szMenu, "hRaktarom");
 
	for(new i;i < sizeof(Fegyverek); i++)
	{
		if(16 <= Fegyverek[i][g_WeapID] <= 26)
		{
		if(g_PlayerHWA[id][i] > 0)
		{
			formatex(szMenu, charsmax(szMenu), "%s \r[\y%i \rDB]", Fegyverek[i][Name], g_PlayerHWA[id][i]);
			num_to_str(i, String, 5);
			menu_additem(menu, szMenu, String);
			}
		}
	}
	menu_display(id, menu, 0);
}

public deagle_menu(id)
{
	new szMenu[121],String[6]
	formatex(szMenu, charsmax(szMenu), "|K|ÁRPÁTI|A|~\wDEAGLE SKINEK")
	new menu = menu_create(szMenu, "hRaktarom");
 
	for(new i;i < sizeof(Fegyverek); i++)
	{
		if(41 <= Fegyverek[i][g_WeapID] <= 50)
		{
		if(g_PlayerHWA[id][i] > 0)
		{
			formatex(szMenu, charsmax(szMenu), "%s \r[\y%i \rDB]", Fegyverek[i][Name], g_PlayerHWA[id][i]);
			num_to_str(i, String, 5);
			menu_additem(menu, szMenu, String);
			}
		}
	}
	menu_display(id, menu, 0);
}

public kes_menu(id)
{
	new szMenu[121],String[6]
	formatex(szMenu, charsmax(szMenu), "|K|ÁRPÁTI|A|~\wKNIFE SKINEK")
	new menu = menu_create(szMenu, "hRaktarom");
 
	for(new i;i < sizeof(Fegyverek); i++)
	{
		if(51 <= Fegyverek[i][g_WeapID] <= 70)
		{
		if(g_PlayerHWA[id][i] > 0)
		{
			formatex(szMenu, charsmax(szMenu), "%s \r[\y%i \rDB]", Fegyverek[i][Name], g_PlayerHWA[id][i]);
			num_to_str(i, String, 5);
			menu_additem(menu, szMenu, String);
			}
		}
	}
	menu_display(id, menu, 0);
}

public limitalt_menu(id)
{
	new szMenu[121],String[6]
	formatex(szMenu, charsmax(szMenu), "|K|ÁRPÁTI|A|~\wLIMITÁLT SKINEK")
	new menu = menu_create(szMenu, "hRaktarom");
 
	for(new i;i < sizeof(Fegyverek); i++)
	{
		if(72 <= Fegyverek[i][g_WeapID] <= 81)
		{
		if(g_PlayerHWA[id][i] > 0)
		{
			formatex(szMenu, charsmax(szMenu), "%s \r[\y%i \rDB]", Fegyverek[i][Name], g_PlayerHWA[id][i]);
			num_to_str(i, String, 5);
			menu_additem(menu, szMenu, String);
			}
		}
	}
	menu_display(id, menu, 0);
}
public hRaktarom(id, menu, item) {
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED
	}

	new data[9], szName[64]
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName, charsmax(szName), callback);
	new key = str_to_num(data);
	
	if(Fegyverek[key][EntName] == CSW_AK47) 
	{
		Selectedgun[id][AK47] = key;
	}
	else if(Fegyverek[key][EntName] == CSW_M4A1) 
	{
		Selectedgun[id][M4A1] = key;
	}
	else if(Fegyverek[key][EntName] == CSW_AWP) 
	{
		Selectedgun[id][AWP] = key;
	}
	else if(Fegyverek[key][EntName] == CSW_DEAGLE) 
	{
		Selectedgun[id][DEAGLE] = key;
	}
	else if(Fegyverek[key][EntName] == CSW_KNIFE) 
	{
		Selectedgun[id][KNIFE] = key;
	}
	ColorChat(id, GREEN, "^4[K]ÁRPÁTI[A]- FUN » ^1Felszerelted a ^3%s^1 fegyvert", Fegyverek[key][Name]);
	
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public Halal()
{

	new Gyilkos = read_data(1);
	new Aldozat = read_data(2);
	new fejloves = read_data(3);




	if(!g_LoggedIn[Gyilkos] || !g_LoggedIn[Aldozat])
	{
		return PLUGIN_HANDLED;
	}
    else if(g_LoggedIn[Gyilkos] || g_LoggedIn[Aldozat])
	{
	if(Gyilkos == Aldozat)
		return PLUGIN_HANDLED;

	
	
	g_adatok[g_MVPoints][Gyilkos]++;
	
	new Float:EXPEuro;
	new Float:EXPoostEuro;
	new Float:penzEuro;
	new penzdollar;
	new fejesdollar;

	EXPEuro += random_float(0.01,1.15);
	EXPoostEuro += random_float(10.01,30.15);
	penzEuro += random_float(0.01,1.15);
	penzdollar += random_num(1,10);
	fejesdollar += random_num(10,30);

	Player[Gyilkos][Euro] += EXPEuro;
	
	if(g_playerData[ExpBoost][Gyilkos] >= 1) 
	{
	Player[Gyilkos][Euro] += EXPoostEuro;
	ColorChat(Gyilkos, GREEN, "^4[K]ÁRPÁTI[A]- EXP BOOST »^3 %3.2f%%%^1 jutalom!", EXPoostEuro);
	}

	penzem[Gyilkos][penz] += penzEuro;
	g_adatok[Dollar][Gyilkos] += penzdollar;
	g_adatok[Dollar][fejloves] += fejesdollar;


	new Float:minuszEuro;

	minuszEuro += random_float(1.10, 2.10);	

	Player[Aldozat][Euro] -= minuszEuro;
	set_dhudmessage(0, 255, 0, -1.0, 0.20, 2, 6.0, 3.0);
	show_dhudmessage(Aldozat, "Megöltek téged, ezért vesztettél [	%3.2f%%%% EXP ]", minuszEuro);

	// RANG RENDSZER DOLGAI

	
	Oles[Gyilkos]++;

	if( g_AdatV2[g_Quest][Gyilkos] == 1)
		Quest(Gyilkos);
	
	if(Mod == 1)	
	g_playerData[SMS][Gyilkos] += penzdollar;
	ColorChat(Gyilkos, GREEN, "^3[^1PRÉMIUM EVENT^3] ^1Szereztél ^4%d Prémium Pontot", penzdollar);

	//if(Mod == 2)
		//eventkordroppoljon(Gyilkos);

	
	randomadas(Gyilkos);
	return PLUGIN_HANDLED;
    }
}

public randomadas(id)
{
	new adj_egyet = random_num(0, 1);

	switch(adj_egyet)
	{
		case 0:
			szerzettcucc(id);
		case 1:
			eventkordroppoljon(id);
	}
	return PLUGIN_HANDLED;
}


public szerzettcucc(id)
{
	new const OpenableIDs[] = {0, 1, 2, 3, 4};

	new Float:Total = 0.0;
	new OpenableIDs_size = sizeof(OpenableIDs);
	for(new i = 0; i < OpenableIDs_size; i++)
		Total += LadaNevei[OpenableIDs[i]][ritka];

	new Float:RandomPoint = random_float(0.01, Total);
	
	new Float:currenttotal
	for(new i = 0; i < OpenableIDs_size; i++)
	{
		new Float:NextCT = currenttotal + LadaNevei[OpenableIDs[i]][ritka];

		if(currenttotal < RandomPoint && RandomPoint <= NextCT)
		{
			Lada[OpenableIDs[i]][id]++;
				
			new nev[32]; get_user_name(id, nev, 31); 
			ColorChat(0, GREEN, "^4[K]ÁRPÁTI[A]- FUN »^3 %s ^1szerzett egy ^4%s^1(^3esélye:^4 %.2f%%%%^1)", nev, LadaNevei[OpenableIDs[i]][Name], LadaNevei[OpenableIDs[i]][ritka] / (Total / 100.0));
			break;
		}
		currenttotal = NextCT;
	}
}
public eventkordroppoljon(id)
{
	new const OpenableIDs[] = {0, 1, 2, 3, 4};

	new Float:Total = 0.0;
	new OpenableIDs_size = sizeof(OpenableIDs);
	for(new i = 0; i < OpenableIDs_size; i++)
		Total += KulcsNevek[OpenableIDs[i]][ritka];

	new Float:RandomPoint = random_float(0.01, Total);
	
	new Float:currenttotal
	for(new i = 0; i < OpenableIDs_size; i++)
	{
		new Float:NextCT = currenttotal + KulcsNevek[OpenableIDs[i]][ritka];

		if(currenttotal < RandomPoint && RandomPoint <= NextCT)
		{
			g_Kulcs[OpenableIDs[i]][id]++;
			new nev[32]; get_user_name(id, nev, 31);
			ColorChat(0, GREEN, "^4[K]ÁRPÁTI[A]- FUN »^3  %s ^1szerzett egy ^4%s^1(^3esélye:^4 %.2f%%%%^1)", nev, KulcsNevek[OpenableIDs[i]][Nevv], KulcsNevek[OpenableIDs[i]][ritka] / (Total / 100.0));
			break;
		}
		currenttotal = NextCT;
	}
}

public scoutkezdes(id)
{
	
	new sMapName[32];
	get_mapname(sMapName, charsmax(sMapName));

	if ( containi( sMapName, "scout" ) != -1 )
	{
		
	strip_user_weapons(id);
	give_item(id, "weapon_scout");
	give_item(id, "weapon_knife");
	cs_set_user_bpammo(0, CSW_SCOUT, 90);
	ColorChat(id, GREEN, "^3[^1Infó^3] ^1Megkaptad ^3Scout fegyvert ^1 200 tölténnyel");
	}
}	

public korkezdespalyaval(id)
{

	if(g_LoggedIn[id])
	{
	if(!is_user_alive(id))
	return PLUGIN_HANDLED;

	openGunMenu(id);
	vipCheck(id);
	infoklekerdezes(id);
	nezdmaravipet(id);
	EXPcheck(id);
	CheckRank_p(id);

	g_UseWeapon[id] = false;
	cs_set_user_money(id, 0);
	strip_user_weapons(id);
	give_item(id, "weapon_knife");

	g_Awps[Te] = 0;
	g_Awps[Ct] = 0;

	if(g_Erdem[eTime][id] < 0)
		g_Erdem[eTime][id] = 0

	g_adatok[g_MVPoints][id] = 0;	
	
	Selectedgun[id][SMOKE] = 87;
	Selectedgun[id][HEG] = 88;
	Selectedgun[id][FLASH] = 89;
	Selectedgun[id][C4] = 90;


	if(Selectedgun[id][AK47] == 0)	
	{
		Selectedgun[id][AK47] = 0;
		Selectedgun[id][AWP] = 1;
		Selectedgun[id][DEAGLE] = 2;
		Selectedgun[id][M4A1] = 3;
		Selectedgun[id][KNIFE] = 4;
	}

	if(1 >= g_playerData[MPrefi][id] <= 7)
	{
		give_item(id, "weapon_flashbang");
		/*----- set_user_health(id, get_user_health(id) + 5);------*/
		ColorChat(id, GREEN, "^3[^1VIP^3] ^1Kaptál ^3(^1 Flash Gránátot^3)");	
	}	

    
	}
	else
	{		
	if(!is_user_alive(id))
	return PLUGIN_HANDLED;

	openGunMenu(id);
	vipCheck(id);
	infoklekerdezes(id);
	nezdmaravipet(id);
	EXPcheck(id);
	CheckRank_p(id);

	g_UseWeapon[id] = false;
	cs_set_user_money(id, 0);
	strip_user_weapons(id);
	give_item(id, "weapon_knife");

	g_Awps[Te] = 0;
	g_Awps[Ct] = 0;

	g_adatok[g_MVPoints][id] = 0;	
	
	Selectedgun[id][SMOKE] = 87;
	Selectedgun[id][HEG] = 88;
	Selectedgun[id][FLASH] = 89;
	Selectedgun[id][C4] = 90;


	if(Selectedgun[id][AK47] == 0)	
	{
		Selectedgun[id][AK47] = 0;
		Selectedgun[id][AWP] = 1;
		Selectedgun[id][DEAGLE] = 2;
		Selectedgun[id][M4A1] = 3;
		Selectedgun[id][KNIFE] = 4;
	}
}
	return PLUGIN_HANDLED;
}

public client_disconnected(id)
{
	if(g_LoggedIn[id])
	{
	Update(id, 0);
	sql_update_account_nametag(id);
	ChatType[id] = 1
	AdminLevel[id] = 0;
	AdminRangDisable[id] = 0;
	g_playerData[Rang][id] = 0;
	g_playerData[MPrefi][id] = 0;
	Oles[id] = 0;
	g_playerData[Kulcs][id] = 0;
	Masodpercek[id] = 0;
	g_playerData[teljesitmenyoles][id] = 0;
	g_playerData[teljesitmeny][id] = 0;
	g_adatok[chatprefix][id] = 0;
	g_playerData[fagyaszto][id] = 0;
	g_playerData[SMS][id] = 0;
	g_adatok[kartya][id] = 0;
	g_playerData[Gun][id] = 1;
	g_adatok[szerencse][id] = 0;
	g_adatok[Osszes_kartya][id] = 0;
	g_AdatV2[g_Quest][id] = 0;
	g_AdatV2[g_QuestWeapon][id] = 0;
	g_AdatV2[g_QuestMVP][id] = 0;
	g_AdatV2[g_QuestHead][id] = 0;
	g_VipTime[id] = 0
	g_adatok[Dollar][id] = 0;
	g_AdatV2[Nevcedula][id] = 0;
	g_AdatV2[hanyasnevcedula][id] = 0;
	kibestat[id] = 0;
	Hud[id] = false;
	FegyverHud[id] = false;
	AccountBelepve[id] = false;
	g_adatok[alapchat][id] = 0;
	g_AdatV2[patrik_zeneji][id] = 0;
	g_AdatV2[ZenePont][id]= 0;
	g_ePlayer[eTime][id] = 0;
	g_ePlayer[eRanks][id] = 0;
	g_playerData[ExpBoost][id] = 0;
	/*-----[ ByPass ]------*/
	g_Erdem[ErdemSzint][id] = 0;
	g_Erdem[eTime][id] = 0;
	g_adatok[bypass_kartya][id] = 0;
	g_adatok[hudszin][id] = 0;

	/*-----[ Fegyver skinek ]------*/
	Selectedgun[id][AK47] = 0;
	Selectedgun[id][AWP] = 0;
	Selectedgun[id][DEAGLE] = 0;
	Selectedgun[id][M4A1] = 0;
	Selectedgun[id][KNIFE] = 0;

	
	g_PlayerHWA[id][180] = 0;

	for(new i;i < FEGYO; i++) OsszesSkin[i][id] = 0;
	for(new i;i < skinek; i++) Skin[i][id] = 0;
	for(new i;i < CASE2; i++) g_Kulcs[i][id] = 0;
	for(new i;i < STK; i++) Statrak[i][id] = 0;
	for(new i;i < 4; i++) g_Jutalom[i][id] = 0;
	for(new i;i < 2; i++) g_QuestKills[i][id] = 0;
	for(new i;i < LADA; i++) Lada[i][id] = 0;


	Beirtprefix[id] = false;
	Beirtcedula[id] = false;
	fegyverkivalasztas[id] = false;
	g_LoggedIn[id] = false;
	Beirtcedula[id] = false;
	AccountBelepve[id] = false;

	g_UserName[id][0] = EOS;
	g_Password[id][0] = EOS;
	g_Password1[id][0] = EOS;
	g_UserMail[id][0] = EOS;
	prefiszem[id][0] = EOS;
	Fegyverneve[id][0][0] = EOS;


	SetTradesToDefault(id); //Trade System by Kova
	}
}
public client_putinserver(id)
{
	if(!is_user_bot(id))
	{
		g_LoggedIn[id] = false;
		szerverbelepes(id);
		new ip[33];
		get_user_ip(id, ip, charsmax(ip), 1);
	}
}

public showMenu_Main(id)
{

	static menu[512], len;
	len = 0;


	len = formatex(menu[len], charsmax(menu) - len, "%s^nFiók Panel^n^n", Prefix);
	
	len += formatex(menu[len], charsmax(menu) - len, "\r[\w1\r] \y»\w Regisztráció^n");
	len += formatex(menu[len], charsmax(menu) - len, "\r[\w2\r] \y»\w Bejelentkezés^n^n");
	len += formatex(menu[len], charsmax(menu) - len, "\rElfelejtett jelszó? \y-> \r[\w3\r] \w Gomb^n");


	len += formatex(menu[len], charsmax(menu) - len, "\y»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»^n");
	len += formatex(menu[len], charsmax(menu) - len, "\y»\dSzerver IP:	 \w87.229.115.198:27041 ^n");
	len += formatex(menu[len], charsmax(menu) - len, "\y»\dMod Verzió:\y 2.1 \d||\w by TwisT^n");
	len += formatex(menu[len], charsmax(menu) - len, "^n");
	len += formatex(menu[len], charsmax(menu) - len, "^n");
	len += formatex(menu[len], charsmax(menu) - len, "^n");
	len += formatex(menu[len], charsmax(menu) - len, "\y»\w Kilépés a menüből \y»» [6-7-8-9] Gomb^n");


	new keys = MENU_KEY_0|MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6|MENU_KEY_7|MENU_KEY_8|MENU_KEY_9;
	show_menu(id, keys, menu, -1, "showMenu_Main");
	return PLUGIN_HANDLED;	
}

public h_openRegisterMainMenu(id, key)
{

	switch(key)
	{
		case 0:
		{
			g_RegistOrLogin[id] = 1
			g_Mail[id] = false
			showMenu_RegLog(id)
		}
		case 1:
		{
			g_RegistOrLogin[id] = 2
			g_Mail[id] = false
			showMenu_RegLog(id)
		}
		case 2:
		{
			g_UserMail[id][0] = EOS
			g_Mail[id] = true
			showMenu_GotBackPass(id)
		}
		case 6..8:	return PLUGIN_HANDLED;
		}
	return PLUGIN_HANDLED;
}
public showMenu_GotBackPass(id)
{
	new szMenu[121]
	format(szMenu, charsmax(szMenu), "%s \r- \dElfelejtett jelszó", PR)
	new menu = menu_create(szMenu, "menu_backpass");

	formatex(szMenu, charsmax(szMenu), "E-Mail:\d %s^n^n", g_UserMail[id][0] == EOS ? "Nincs megadva" : g_UserMail[id])
	menu_additem(menu, szMenu, "0", 0);

	menu_additem(menu, "\rKérem a jelszavam!", "1", 0);

	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}
public menu_backpass(id, menu, item)
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
			client_cmd(id, "messagemode EMAIL")
			showMenu_GotBackPass(id)
		}
		case 1: sql_gotpass_check(id)
	}
	return PLUGIN_HANDLED;
}
public sql_gotpass_check(id)
{
	new Query[2048]
	new len = 0
	new a[191]

	if((strlen(g_UserMail[id]) == 0))
	{
		ColorChat(id, GREEN, "^4%s^1 Nem adtál meg E-Mailt!", C_PR)
		showMenu_GotBackPass(id)
		return PLUGIN_HANDLED
	}

	format(a, 190, "%s", g_UserMail[id])

	replace_all(a, 190, "\", "\\")
	replace_all(a, 190, "'", "\'")

	len += format(Query[len], 2048, "SELECT * FROM karpatiasql ")
	len += format(Query[len], 2048-len,"WHERE Email = '%s'", a)

	new szData[2];
	szData[0] = id;
	szData[1] = get_user_userid(id);

	SQL_ThreadQuery(g_SqlTuple,"sql_gotpass_check_thread", Query, szData, 2)

	return PLUGIN_CONTINUE;
}

public sql_gotpass_check_thread(FailState,Handle:Query,Error[],Errcode,szData[],DataSize)
{
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED)
	{
		log_amx("%s", Error)
		return
	}
	else
	{
		new id = szData[0];

		if (szData[1] != get_user_userid(id))
			return;

		new iRowsFound = SQL_NumRows(Query)

		if(iRowsFound == 0)
		{
			ColorChat(id, GREEN, "^4%s^1 Nem található ilyen ^3E-Mail ^1cím!", C_PR)
			showMenu_GotBackPass(id)
		}
		else
		{
			new szSqlPass[100]
			SQL_ReadResult(Query, 2, szSqlPass, 99)

			ColorChat(id, GREEN, "^4%s^1 Ehez az ^3E-Mail ^1címhez tartozó jelszó:^3 %s", C_Prefix, szSqlPass)
			showMenu_Main(id)
		}
	}
}

public cmdJelszo(id)
{
	if(g_LoggedIn[id] == true)
		return PLUGIN_HANDLED

	g_Password[id][0] = EOS
	read_args(g_Password[id], 99)
	remove_quotes(g_Password[id])

	if((strlen(g_Password[id]) < 4) || (strlen(g_Password[id]) > 16))
	{
		ColorChat(id, GREEN, "^4%s^1 A jelszavad nem lehet rövidebb 4, illetve hosszabb 16 karakternél!", C_Prefix)
		g_Password[id][0] = EOS
	}

	showMenu_RegLog(id)
	return PLUGIN_HANDLED
}

public cmdJelszo1(id)
{
	if(g_LoggedIn[id] == true)
		return PLUGIN_HANDLED

	g_Password1[id][0] = EOS
	read_args(g_Password1[id], 99)
	remove_quotes(g_Password1[id])

	if((strlen(g_Password1[id]) < 4) || (strlen(g_Password1[id]) > 16))
	{
		ColorChat(id, GREEN, "^4%s^1 A jelszavad nem lehet rövidebb 4, illetve hosszabb 16 karakternél!", C_Prefix)
		g_Password1[id][0] = EOS
	}

	showMenu_RegLog(id)
	return PLUGIN_HANDLED
}

public cmdFelhasznalonev(id)
{
	if(g_LoggedIn[id])
		return PLUGIN_HANDLED
	
	g_UserName[id][0] = EOS
	read_argv(1, g_UserName[id], 99);
	remove_quotes(g_UserName[id])

	if((strlen(g_UserName[id]) < 2) || (strlen(g_UserName[id]) > 20))
	{
		ColorChat(id, GREEN, "^4%s^1 A ^3Felhasználóneved ^1nem lehet rövidebb 2, illetve hosszabb 20 karakternél!", C_Prefix)
		return PLUGIN_HANDLED
	}

	if(g_Mail[id]) 
		showMenu_GotBackPass(id)
	else 
		showMenu_RegLog(id)
	return PLUGIN_HANDLED
}

public cmdEmail(id)
{
	if(g_LoggedIn[id])
		return PLUGIN_HANDLED

	g_UserMail[id][0] = EOS
	read_args(g_UserMail[id], 99)
	remove_quotes(g_UserMail[id])

	if(contain(g_UserMail[id], ".hu") != -1
	|| contain(g_UserMail[id], ".com") != -1
	|| contain(g_UserMail[id], ".ro") != -1
	|| contain(g_UserMail[id], ".cz") != -1
	|| contain(g_UserMail[id], ".de") != -1
	|| contain(g_UserMail[id], ".pl") != -1
	|| contain(g_UserMail[id], ".eu") != -1
	|| contain(g_UserMail[id], ".lt") != -1)
	{
		if(contain(g_UserMail[id], "@") != -1)
		{
			new const VP[] = "\"

			if(contain(g_UserMail[id], VP) != -1
			|| contain(g_UserMail[id], "'") != -1)
			{
				ColorChat(id, GREEN, "^4%s^1 Hibás ^3E-Mail^1 formátum!", C_Prefix)
				g_UserMail[id][0] = EOS
			}
			else {
				if(g_Mail[id]) showMenu_GotBackPass(id)
				else showMenu_RegLog(id)
			}
		}
		else
		{
			ColorChat(id, GREEN, "^4%s^1 Hibás ^3E-Mail^1 formátum!", C_Prefix)
			g_UserMail[id][0] = EOS
		}

	}
	else
	{
		ColorChat(id, GREEN, "^4%s^1 Hibás ^3E-Mail^1 formátum!", C_Prefix)
		g_UserMail[id][0] = EOS
	}

	if(g_Mail[id]) showMenu_GotBackPass(id)
	else showMenu_RegLog(id)
	return PLUGIN_HANDLED
}

public cmdRegisztracioBejelentkezes(id)
{
	if(g_LoggedIn[id] == true)
		return PLUGIN_HANDLED

	if((strlen(g_UserName[id]) == 0))
	{
		ColorChat(id, GREEN, "^4%s^1 Nem adtál meg felhasználónevet!", C_Prefix)
		showMenu_RegLog(id)
		return PLUGIN_HANDLED
	}

	if((strlen(g_Password[id]) == 0))
	{
		ColorChat(id, GREEN, "^4%s^1 Nem adtál meg jelszót!", C_Prefix)
		showMenu_RegLog(id)
		return PLUGIN_HANDLED
	}

	if(g_RegistOrLogin[id] == 1)
	{
		if(!equali(g_Password[id], g_Password1[id]))
		{
			ColorChat(id, GREEN, "^4%s^1 A megadott két jelszó nem egyezik!", C_Prefix)
			showMenu_RegLog(id)
			return PLUGIN_HANDLED
		}
	}

	switch(g_RegistOrLogin[id])
	{
		case 1:
		{
			if(g_InProgress[id] == 0)
			{
				ColorChat(id, GREEN, "^4%s^1 A Regisztráció folyamatban...", C_Prefix)
				sql_account_check(id)
				showMenu_RegLog(id)
				g_InProgress[id] = 1
			}
			else showMenu_RegLog(id)
		}
		case 2:
		{
			if(g_InProgress[id] == 0)
			{
				ColorChat(id, GREEN, "^4%s^1 A Bejelentkezés folyamatban...", C_Prefix)
				sql_account_check(id)
				showMenu_RegLog(id)
				g_InProgress[id] = 1
			}
			else showMenu_RegLog(id)
		}
	}

	return PLUGIN_CONTINUE
}

public sql_account_check(id)
{
	new szQuery[2048]
	new len = 0

	new a[191]

	format(a, 190, "%s", g_UserName[id])

	replace_all(a, 190, "\", "\\")
	replace_all(a, 190, "'", "\'")

	len += format(szQuery[len], 2048, "SELECT * FROM karpatiasql ")
	len += format(szQuery[len], 2048-len,"WHERE Felhasznalonev = '%s'", a)

	new szData[2];
	szData[0] = id;
	szData[1] = get_user_userid(id);

	SQL_ThreadQuery(g_SqlTuple,"sql_account_check_thread", szQuery, szData, 2)
}

public sql_account_check_thread(FailState,Handle:Query,Error[],Errcode,szData[],DataSize)
{
	if(FailState == TQUERY_CONNECT_FAILED)
	{
		set_fail_state("[ *HIBA* ] NEM LEHET KAPCSOLODNI AZ ADATBAZISHOZ!")
		return
	}
	else if(FailState == TQUERY_QUERY_FAILED)
	{
		set_fail_state("[ *HIBA* ] A LEKERDEZES MEGSZAKADT!")
		return;
	}

	if(Errcode)
	{
		log_amx("[ *HIBA* ] PROBLEMA A LEKERDEZESNEL! ( %s )",Error)
		return;
	}

	new id = szData[0];

	if (szData[1] != get_user_userid(id))
		return;

	new iRowsFound = SQL_NumRows(Query)

	if(g_RegistOrLogin[id] == 1)
	{
		if(iRowsFound > 0)
		{
			ColorChat(id, GREEN, "^4%s^1 A Fiók név	már használva van. Kérlek jelentkezz be másik fiókba!", C_Prefix)
			g_InProgress[id] = 0
			showMenu_RegLog(id)
		}
		else
			sql_account_create(id) 
	}
	else if(g_RegistOrLogin[id] == 2)
	{
		if(iRowsFound == 0)
		{
			ColorChat(id, GREEN, "^4%s^1 Hibás ^3Felhasználónév^1 vagy ^3Jelszó^1!", C_Prefix)
			g_InProgress[id] = 0
			showMenu_RegLog(id)
		}
		else if(AccountBelepve[id] == true)
		{
			ColorChat(id, GREEN, "^4%s^1 A Fiókkal már bevannak lépve. Kérlek jelentkezz be másik fiókba!", C_Prefix)
			g_InProgress[id] = 0
			showMenu_RegLog(id)
		}
		else
			sql_account_load(id)
	}
}

public sql_account_create(id)
{
	new Query[2048]
	new len = 0

	new a[191], b[191], c[191]

	format(a, 190, "%s", g_UserName[id])
	format(b, 190, "%s", g_Password[id])
	format(c, 190, "%s", g_UserMail[id])

	replace_all(a, 190, "\", "\\")
	replace_all(a, 190, "'", "\'")
	replace_all(b, 190, "\", "\\")
	replace_all(b, 190, "'", "\'")
	replace_all(c, 190, "\", "\\")
	replace_all(c, 190, "'", "\'")

	len += format(Query[len], 2048, "INSERT INTO karpatiasql ")
	len += format(Query[len], 2048-len,"(Felhasznalonev,Jelszo,Email) VALUES('%s','%s','%s')", a, b, c)

	new szData[2];
	szData[0] = id;
	szData[1] = get_user_userid(id);

	SQL_ThreadQuery(g_SqlTuple,"sql_account_create_thread", Query, szData, 2)
}
public sql_account_create_thread(FailState,Handle:Query,Error[],Errcode,szData[],DataSize)
{
	if(FailState == TQUERY_CONNECT_FAILED)
	{
		set_fail_state("[ *HIBA* ] NEM LEHET KAPCSOLODNI AZ ADATBAZISHOZ!")
		return
	}
	else if(FailState == TQUERY_QUERY_FAILED)
	{
		set_fail_state("[ *HIBA* ] A LEKERDEZES MEGSZAKADT!")
		return;
	}

	if(Errcode)
	{
		log_amx("[ *HIBA* ] PROBLEMA A LEKERDEZESNEL! ( %s )",Error)
		return;
	}

	new id = szData[0];

	if (szData[1] != get_user_userid(id))
		return;

	if(g_UserMail[id][0] == EOS) ColorChat(id, GREEN, "^4%s^1 Sikeresen regisztráltál! Felhasználónév:^3 %s^1 | Jelszó:^3 %s", C_Prefix, g_UserName[id], g_Password[id])
	else ColorChat(id, GREEN, "^4%s^1 Sikeresen regisztráltál! Felhasználónév:^3 %s^1 | Jelszó:^3 %s^1 | E-Mail:^3 %s", C_Prefix, g_UserName[id], g_Password[id], g_UserMail[id])
	g_InProgress[id] = 0;
	g_RegistOrLogin[id] = 2;
	showMenu_RegLog(id)
	
	return;
}
public showMenu_RegLog(id)
{
	new szMenu[121]
	format(szMenu, charsmax(szMenu), "%s \r- \dRegisztráció és Bejelentkezés", PR)
	new menu = menu_create(szMenu, "menu_reglog");

	formatex(szMenu, charsmax(szMenu), "\yFelhasználónév:\w %s^n", g_UserName[id][0] == EOS ? "Nincs megadva \r*" : g_UserName[id])
	menu_additem(menu, szMenu, "0", 0);
	formatex(szMenu, charsmax(szMenu), "\yJelszó:\w %s%s", g_Password[id][0] == EOS ? "Nincs megadva \r*" : LenStars[strlen(g_Password[id])], g_RegistOrLogin[id] == 2 ? "^n" : "")
	menu_additem(menu, szMenu, "1", 0);
	if(g_RegistOrLogin[id] == 1 )
	{
		formatex(szMenu, charsmax(szMenu), "\yJelszó Újra:\w %s^n", g_Password1[id][0] == EOS ? "Nincs megadva \r*" : LenStars[strlen(g_Password1[id])])
		menu_additem(menu, szMenu, "2", 0);
		formatex(szMenu, charsmax(szMenu), "\yE-Mail:\w %s^n^n", g_UserMail[id][0] == EOS ? "Nincs megadva" : g_UserMail[id])
		menu_additem(menu, szMenu, "3", 0);
	}

	if(g_RegistOrLogin[id] == 1 )
		menu_additem(menu, "\rRegisztráció", "4", 0);
	else
		menu_additem(menu, "\rBejelentkezés", "4", 0);
	menu_display(id, menu, 0);
	
	return PLUGIN_HANDLED;
}
public menu_reglog(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}

	new data[9], szName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
	new key = str_to_num(data);

	switch(key)
	{
		case 0:
		{
			client_cmd(id, "messagemode FELHASZNALONEV")
			showMenu_RegLog(id)
		}
		case 1:
		{
			client_cmd(id, "messagemode JELSZAVAD")
			showMenu_RegLog(id)
		}
		case 2:
		{
			client_cmd(id, "messagemode JELSZAVAD_UJRA")
			showMenu_RegLog(id)
		}
		case 3:
		{
			client_cmd(id, "messagemode EMAIL")
			showMenu_RegLog(id)
		}
		case 4: cmdRegisztracioBejelentkezes(id)
	}
	
	return PLUGIN_HANDLED;
}

public plugin_cfg()
{
	g_SqlTuple = SQL_MakeDbTuple(SQLINFO[0], SQLINFO[1], SQLINFO[2], SQLINFO[3]);
}

public sql_account_load(id)
{
	static szQuery[10048]
	new len = 0

	new a[191]

	format(a, 190, "%s", g_UserName[id])

	replace_all(a, 190, "\", "\\")
	replace_all(a, 190, "'", "\'")

	len += format(szQuery[len], 10048, "SELECT * FROM karpatiasql ")
	len += format(szQuery[len], 10048-len,"WHERE Felhasznalonev = '%s'", a)


	new szData[2];
	szData[0] = id;
	szData[1] = get_user_userid(id);

	SQL_ThreadQuery(g_SqlTuple,"QuerySelectData", szQuery, szData, 2)
}


public QuerySelectData(FailState,Handle:Query,Error[],Errcode,szData[],DataSize)
{
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED)
	{
		log_amx("%s", Error)
		return
	}
	else
	{
		new id = szData[0];

		if (szData[1] != get_user_userid(id))
			return ;

		log_amx("%s", Error)
		new szSqlPassword[100]
		SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Jelszo"), szSqlPassword, 99);
		
		new ip[32];
		get_user_ip(id, ip, charsmax(ip), 1);

		
		if(equal(g_Password[id], szSqlPassword))
		{
			g_adatok[g_Id][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "id"));
			SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "ip"), ip[id], charsmax(ip[]));
			SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Prefix"), prefiszem[id], charsmax(prefiszem[]));
			SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Email"), g_UserMail[id], charsmax(g_UserMail[]));
			g_playerData[Rang][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Szint"));
			g_playerData[MPrefi][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "rangokjogok"));
			g_AdatV2[ZenePont][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "ZenePont"));
			g_playerData[SMS][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "SMS"));
			g_AdatV2[patrik_zeneji][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "zenekeszlet"));
			kibestat[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "kibestat"));
			Hud[id] = bool:SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Hud"));
			FegyverHud[id] = bool:SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "FegyverHud"));
			Oles[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Oles"));
			g_adatok[szerencse][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Osszes_szerencse"));
			g_adatok[Osszes_kartya][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Osszes_kartya"));
			g_playerData[fagyaszto][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "fagyaszto"));
			g_adatok[kartya][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "kartya"));
			SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "EXP"), Player[id][Euro]);
			SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Euro"), penzem[id][penz]);
			Masodpercek[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Masodpercek"));
			g_playerData[teljesitmeny][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "teljesitmeny"));
			g_playerData[teljesitmenyoles][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "teljesitmenyoles"));
			g_adatok[chatprefix][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "chatprefix"));
			g_AdatV2[g_Quest][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "QuestH"));
			g_AdatV2[g_QuestMVP][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "QuestMVP"));
			g_QuestKills[0][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "QuestNeed"));
			g_QuestKills[1][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "QuestHave"));
			g_AdatV2[g_QuestWeapon][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "QuestWeap"));
			g_AdatV2[g_QuestHead][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "QuestHead"));
			g_Jutalom[0][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "JutLada"));
			g_Jutalom[1][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "JutKulcs")); 
			g_Jutalom[2][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "JutPont"));
			g_Jutalom[3][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "JutDoll")); 
			g_playerData[ExpBoost][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "expboost")); 
			g_playerData[Kulcs][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Kulcs"));
			g_adatok[hudszin][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "hudszin"));
			g_adatok[bypass_kartya][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "by_passkartya"));
			g_adatok[alapchat][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "alapchat"));
			g_adatok[Dollar][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Dollar"));
			g_VipTime[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "g_VipTime"));
			g_Erdem[ErdemSzint][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "ByPass"));
			g_Erdem[eTime][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "ByPassIdo"));
			AdminLevel[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "AdminLevel"));
			AdminRangDisable[id]  = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "ADMS"));
			ChatType[id]  = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "CH"));
			if(g_playerData[MPrefi][id] == 4)
			{
			g_ePlayer[eTime][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "qTime"));
			g_ePlayer[eRanks][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "qRanks"));
			}
			
			for(new i;i < sizeof(Fegyverek); i++)
			{
				new String[64];
				formatex(String, charsmax(String), "Nevcedula_%d", i);
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, String), Fegyverneve[i][id], charsmax(Fegyverneve[]));
				//console_print(0, "Nevcedula_%d | FgyName: %s", i, Fegyverneve[i][id])
			}
			//for(new i; i < sizeof(Fegyverek); i++){
				//new String[64];
				//formatex(String, charsmax(String), "Nevcedula_%d", i);
				//Fegyverneve[i][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, String))
				//SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Nevcedula_%d"), Fegyverneve[i][id], charsmax(Fegyverneve[][]))
				//SQL_ReadResult(Query, i, Fegyverneve[i][id], 99)
			//}
			for(new i;i < FEGYO; i++){
				new String[64];
				formatex(String, charsmax(String), "F_%d", i);
				g_PlayerHWA[id][i] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, String));
			}
			for(new i;i < FEGYO; i++){
				new String[64];
				formatex(String, charsmax(String), "F_%d", i);
				g_PlayerHWA[id][i] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, String));
			}
			for(new i;i < LADA; i++){
				new String[64];
				formatex(String, charsmax(String), "L_%d", i);
				Lada[i][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, String));
			}
			for(new i;i < CASE2; i++){
				new String[64];
				formatex(String, charsmax(String), "K_%d", i);
				g_Kulcs[i][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, String));
			}
			/* for(new i;i < skinek; i++)
			{
				new String[64];
				formatex(String, charsmax(String), "Skin%d", i);
				Skin[i][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, String));
			} */
			Selectedgun[id][AK47] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Skin0"));
			Selectedgun[id][M4A1] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Skin1"));
			Selectedgun[id][AWP] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Skin2"));
			Selectedgun[id][DEAGLE] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Skin3"));
			Selectedgun[id][KNIFE] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Skin4"));

			for(new i;i < STK; i++)
			{
				new String[64];
				formatex(String, charsmax(String), "St%d", i);
				Statrak[i][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, String));
			}

			g_InProgress[id] = 0;
			g_LoggedIn[id] = true;
			g_PlayerHWA[id][180]++;
			openMainMenu(id);
			if(Errcode)
			log_amx("[HIBA*] HIBAT DOBTAM: %s",Error);
			
			new nev[32]; get_user_name(id, nev, 31); 
			AccountBelepve[id] = true;
			
			//Set_Permissions(id)
			//if(AdminLevel[id] > 0)

				ColorChat(0, GREEN, "^1[K]ÁRPÁTI[A]- FUN »^4 %s (Account ID: #%d) ^3%s^1 bejelentkezett!", nev, g_adatok[g_Id][id], MutasdPrefixet[g_playerData[MPrefi][id]])
		}
		else
		{
			ColorChat(id, GREEN, "^4%s^1 Hibás ^3Felhasználónév^1 vagy ^3Jelszó^1!", C_Prefix);
			ColorChat(id, GREEN, "^4%s^1 Hiba %s!", C_Prefix, Error);
			g_InProgress[id] = 0;
			showMenu_RegLog(id);
			
			if(Errcode)
			log_amx("[HIBA*] HIBAT DOBTAM: %s",Error);
		}
	}
}

public Update(const id, const part)
{
	static Query[14096];
	new Len;
	new sName[32];
	new a[191];
	new b[191];
	
	new ip[32];
	get_user_ip(id, ip, charsmax(ip), 1);

	format(a, 190, "%s", g_UserName[id])
	format(b, 190, "%s", ip[id])

	get_user_name(id, sName, charsmax(sName));

	replace_all(sName, charsmax(sName), "\", "\\");
	replace_all(sName, charsmax(sName), "'", "\'");

	Len += formatex(Query[Len], charsmax(Query), "UPDATE `karpatiasql` SET ");


	if ( part == 0 )
	{
		Len += formatex(Query[Len], charsmax(Query)-Len, "ip = ^"%s^", ", ip[id]);
		Len += formatex(Query[Len], charsmax(Query)-Len, "Prefix = ^"%s^", ", prefiszem[id]);
		Len += formatex(Query[Len], charsmax(Query)-Len, "Masodpercek = ^"%i^", ", Masodpercek[id]+get_user_time(id));
		Len += formatex(Query[Len], charsmax(Query)-Len, "teljesitmenyoles = ^"%i^", ", g_playerData[teljesitmenyoles][id]);
		Len += formatex(Query[Len], charsmax(Query)-Len, "teljesitmeny = ^"%i^", ", g_playerData[teljesitmeny][id]);
		Len += formatex(Query[Len], charsmax(Query)-Len, "chatprefix = ^"%i^", ", g_adatok[chatprefix][id]);
		Len += formatex(Query[Len], charsmax(Query)-Len, "zenekeszlet = '%i', ", g_AdatV2[patrik_zeneji][id]);
		Len += formatex(Query[Len], charsmax(Query)-Len, "QuestH = ^"%i^", ", g_AdatV2[g_Quest][id]);
		Len += formatex(Query[Len], charsmax(Query)-Len, "QuestMVP = ^"%i^", ", g_AdatV2[g_QuestMVP][id]);
		Len += formatex(Query[Len], charsmax(Query)-Len, "QuestNeed = ^"%i^", ", g_QuestKills[0][id]);
		Len += formatex(Query[Len], charsmax(Query)-Len, "QuestHave = ^"%i^", ", g_QuestKills[1][id]);
		Len += formatex(Query[Len], charsmax(Query)-Len, "QuestWeap = ^"%i^", ", g_AdatV2[g_QuestWeapon][id]);
		Len += formatex(Query[Len], charsmax(Query)-Len, "QuestHead = ^"%i^", ", g_AdatV2[g_QuestHead][id]);
		Len += formatex(Query[Len], charsmax(Query)-Len, "JutLada = ^"%i^", ", g_Jutalom[0][id]);
		Len += formatex(Query[Len], charsmax(Query)-Len, "JutKulcs = ^"%i^", ", g_Jutalom[1][id]);
		Len += formatex(Query[Len], charsmax(Query)-Len, "JutPont = ^"%i^", ", g_Jutalom[2][id]);
		Len += formatex(Query[Len], charsmax(Query)-Len, "JutDoll = ^"%i^", ", g_Jutalom[3][id]);
		Len += formatex(Query[Len], charsmax(Query)-Len, "Oles = ^"%i^", ", Oles[id]);
		Len += formatex(Query[Len], charsmax(Query)-Len, "Dollar = ^"%i^", ", g_adatok[Dollar][id]);
		Len += formatex(Query[Len], charsmax(Query)-Len, "ZenePont = ^"%i^", ", g_AdatV2[ZenePont][id]);
		Len += formatex(Query[Len], charsmax(Query)-Len, "Szint = ^"%i^", ", g_playerData[Rang][id]);
		Len += formatex(Query[Len], charsmax(Query)-Len, "fagyaszto = ^"%i^", ", g_playerData[fagyaszto][id]);
		Len += formatex(Query[Len], charsmax(Query)-Len, "Osszes_kartya = ^"%i^", ", g_adatok[Osszes_kartya][id]);
		Len += formatex(Query[Len], charsmax(Query)-Len, "Osszes_szerencse = ^"%i^", ", g_adatok[szerencse][id]);
		Len += formatex(Query[Len], charsmax(Query)-Len, "kartya = ^"%i^", ", g_adatok[kartya][id]);
		Len += formatex(Query[Len], charsmax(Query)-Len, "expboost = ^"%i^", ", g_playerData[ExpBoost][id]);
		Len += formatex(Query[Len], charsmax(Query)-Len, "rangokjogok = ^"%i^", ", g_playerData[MPrefi][id]); 
		Len += formatex(Query[Len], charsmax(Query)-Len, "EXP = ^"%.2f^", ", Player[id][Euro]);
		Len += formatex(Query[Len], charsmax(Query)-Len, "Euro = ^"%.2f^", ", penzem[id][penz]); 
		Len += formatex(Query[Len], charsmax(Query)-Len, "SMS = ^"%i^", ", g_playerData[SMS][id]);
		Len += formatex(Query[Len], charsmax(Query)-Len, "hudszin = ^"%i^", ", g_adatok[hudszin][id]);
		Len += formatex(Query[Len], charsmax(Query)-Len, "by_passkartya = ^"%i^", ", g_adatok[bypass_kartya][id]);
		Len += formatex(Query[Len], charsmax(Query)-Len, "kibestat = ^"%i^", ", kibestat[id]);
		Len += formatex(Query[Len], charsmax(Query)-Len, "Hud = ^"%i^", ", Hud[id]);
		Len += formatex(Query[Len], charsmax(Query)-Len, "FegyverHud = ^"%i^", ", FegyverHud[id]);
		Len += formatex(Query[Len], charsmax(Query)-Len, "Kulcs = ^"%i^", ", g_playerData[Kulcs][id]);
		Len += formatex(Query[Len], charsmax(Query)-Len, "alapchat = ^"%i^", ", g_adatok[alapchat][id]);
		Len += formatex(Query[Len], charsmax(Query)-Len, "ADMS = ^"%i^", ", AdminRangDisable[id]);
		Len += formatex(Query[Len], charsmax(Query)-Len, "AdminLevel = ^"%i^", ", AdminLevel[id]);
		Len += formatex(Query[Len], charsmax(Query)-Len, "CH = ^"%i^", ", ChatType[id]);
		//Len += formatex(Query[Len], charsmax(Query)-Len, "ToolsNametag = ^"%i^", ", s_Player[id][ToolsNametag]);

		if(g_playerData[MPrefi][id] == 4)
		{
			Len += formatex(Query[Len], charsmax(Query)-Len, "qRanks = ^"%i^",", g_ePlayer[eRanks][id]);
			Len += formatex(Query[Len], charsmax(Query)-Len, "qTime = ^"%i^",", g_ePlayer[eTime][id] + get_user_time(id));
		}
		if(g_playerData[MPrefi][id] == 25 || g_playerData[MPrefi][id] == 1 )
		{
			Len += formatex(Query[Len], charsmax(Query)-Len, "ByPass = ^"%i^",", g_Erdem[ErdemSzint][id]);
			Len += formatex(Query[Len], charsmax(Query)-Len, "ByPassIdo = ^"%i^",", g_Erdem[eTime][id] + get_user_time(id));
		}

		for(new i;i < FEGYO; i++) Len += formatex(Query[Len], charsmax(Query)-Len, "F_%d = ^"%i^", ", i, g_PlayerHWA[id][i]); 

		for(new i;i < CASE2; i++) Len += formatex(Query[Len], charsmax(Query)-Len, "K_%d = ^"%i^", ", i, g_Kulcs[i][id]);

		for(new i;i < LADA; i++)	Len += formatex(Query[Len], charsmax(Query)-Len, "L_%d = ^"%i^", ", i, Lada[i][id]);

		//for(new i;i < skinek; i++) Len += formatex(Query[Len], charsmax(Query)-Len, "Skin%d = ^"%i^", ", i, Skin[i][id]);
		Len += formatex(Query[Len], charsmax(Query)-Len, "Skin0 = ^"%i^", ", Selectedgun[id][AK47]);
		Len += formatex(Query[Len], charsmax(Query)-Len, "Skin1 = ^"%i^", ", Selectedgun[id][M4A1]);
		Len += formatex(Query[Len], charsmax(Query)-Len, "Skin2 = ^"%i^", ", Selectedgun[id][AWP]);
		Len += formatex(Query[Len], charsmax(Query)-Len, "Skin3 = ^"%i^", ", Selectedgun[id][DEAGLE]);
		Len += formatex(Query[Len], charsmax(Query)-Len, "Skin4 = ^"%i^", ", Selectedgun[id][KNIFE]);

		for(new i;i < STK; i++)	Len += formatex(Query[Len], charsmax(Query)-Len, "St%d = ^"%i^", ", i, Statrak[i][id]);

	}
	if(part == 1)	
	{	
		Len += formatex(Query[Len], charsmax(Query)-Len, "g_VipTime = ^"%i^", ", g_VipTime[id]-get_user_time(id));
	}	
		Len += formatex(Query[Len], charsmax(Query)-Len, "Jatekosnev = '%s' ", sName); 
		Len += formatex(Query[Len], charsmax(Query)-Len, "WHERE	Felhasznalonev = '%s'", a);

	SQL_ThreadQuery(g_SqlTuple, "QuerySetData", Query);
}	

public sql_update_account_nametag(id)
{	
	
	static Query[14096];
	new Len;
	new sName[32];
	new a[191];

	format(a, 190, "%s", g_UserName[id])

	get_user_name(id, sName, charsmax(sName));

	replace_all(sName, charsmax(sName), "\", "\\");
	replace_all(sName, charsmax(sName), "'", "\'");

	Len += formatex(Query[Len], charsmax(Query), "UPDATE `karpatiasql` SET ");

	for(new i; i < sizeof(Fegyverek); i++)
		Len += format(Query[Len], charsmax(Query)-Len, "Nevcedula_%d = '%s', ", i, Fegyverneve[i][id])
	
	
	Len += formatex(Query[Len], charsmax(Query)-Len, "Jatekosnev = '%s' ", sName);
	
	Len += formatex(Query[Len], charsmax(Query)-Len, "WHERE	Felhasznalonev = '%s'", a);
	

	SQL_ThreadQuery(g_SqlTuple, "QuerySetData", Query)
}

public createTableThread(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime)
{
	if(FailState == TQUERY_CONNECT_FAILED)
		set_fail_state("[HIBA*] NEM TUDTAM CSATLAKOZNI AZ ADATBAZISHOZ!");
	else if(FailState == TQUERY_QUERY_FAILED)
		set_fail_state("Query Error");
		log_amx("[HIBA*] HIBAT DOBTAM: %s",Error);
}

public QuerySetData(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime)
{
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED)
	{
		log_amx("%s", Error);
		return PLUGIN_HANDLED;
	}

	return PLUGIN_HANDLED;
}

/*-----[ CHAT RÉSZLET]------*/
public sayhook(id)
{
	new sMessage[512], sText[128], sDeath[16], Len, sName[64];
	read_args(sMessage, charsmax(sMessage));
	remove_quotes(sMessage);
	
	if(strlen(sMessage) == 0 || sMessage[0] == '/' || sMessage[0] == '@')
		return PLUGIN_HANDLED;
	
	format(sDeath, charsmax(sDeath), is_user_alive(id) ? "":"*Halott*");
	Len += formatex(sText[Len], charsmax(sText)-Len, "^4%s", sDeath);

	if(g_playerData[MPrefi][id] == 1 || g_playerData[MPrefi][id] == 2 || g_playerData[MPrefi][id] == 3 || g_playerData[MPrefi][id] == 4 || g_playerData[MPrefi][id] == 5 || g_playerData[MPrefi][id] == 25 || g_playerData[MPrefi][id] == 27)
		Len += formatex(sText[Len], charsmax(sText)-Len, "^4[%s]", MutasdPrefixet[g_playerData[MPrefi][id]][rangokjogok]);
	else	
		Len += formatex(sText[Len], charsmax(sText)-Len, "^2[%s]", MutasdPrefixet[g_playerData[MPrefi][id]][rangokjogok]);

	
	Len += formatex(sText[Len], charsmax(sText)-Len, "^1[%s]", prefiszem[id]);
	
	get_user_team(id, color, 9);
	get_user_name(id, sName, charsmax(sName));
	
	if(g_playerData[MPrefi][id] == 1 || g_playerData[MPrefi][id] == 2 || g_playerData[MPrefi][id] == 3 || g_playerData[MPrefi][id] == 4 || g_playerData[MPrefi][id] == 5 || g_playerData[MPrefi][id] == 25 || g_playerData[MPrefi][id] == 27)
		format(sMessage, charsmax(sMessage), "^4%s ^3%s^4: %s", sText, sName, sMessage);
	else	
		format(sMessage, charsmax(sMessage), "%s ^3%s^1: %s", sText, sName, sMessage);
	
	for(new i; i < get_maxplayers(); i++)
	{
		if(!is_user_connected(i))
			continue;

		switch(cs_get_user_team(id))
		{
			case 1: ColorChat(i, RED, sMessage);
			case 2: ColorChat(i, BLUE, sMessage);
		}
		if(cs_get_user_team(id) == CS_TEAM_SPECTATOR)
		ColorChat(i, GREY, sMessage);
	}
	return PLUGIN_HANDLED;
}
public saythook(id)
{
	new sMessage[512], sText[128], sDeath[16], Len, sName[64];
	read_args(sMessage, charsmax(sMessage));
	remove_quotes(sMessage);
	
	if(strlen(sMessage) == 0 || sMessage[0] == '/' || sMessage[0] == '@')
		return PLUGIN_HANDLED;
	
	new iTeam, sTeam[32];
	iTeam = get_user_team(id, sTeam, charsmax(sTeam));
	
	switch(iTeam)
	{
		case CS_TEAM_CT: {sTeam = "Terrorelhárító";}
		case CS_TEAM_T: {sTeam = "Terrorista";}
		case CS_TEAM_SPECTATOR: {sTeam = "Nézelődő";}
	}
	
	format(sDeath, charsmax(sDeath), is_user_alive(id) ? "":"*Halott*");
	
	
	Len += formatex(sText[Len], charsmax(sText)-Len, "^3(%s)", sTeam);
	Len += formatex(sText[Len], charsmax(sText)-Len, "^1%s", sDeath);
	
	Len += formatex(sText[Len], charsmax(sText)-Len, "^4[%s]", MutasdPrefixet[g_playerData[MPrefi][id]][rangokjogok]);
	Len += formatex(sText[Len], charsmax(sText)-Len, "^4[%s]", Rangok[g_playerData[Rang][id]][Szint]);
	Len += formatex(sText[Len], charsmax(sText)-Len, "^1[%s]", prefiszem[id]);
	
	
	get_user_team(id, color, 9);
	get_user_name(id, sName, charsmax(sName));
	format(sMessage, charsmax(sMessage), "%s ^3%s^1: %s", sText, sName, sMessage);

	
	for(new i; i < get_maxplayers(); i++)
	{
		if(!is_user_connected(i))
			continue;
		
		if(cs_get_user_team(id) == CS_TEAM_CT)
			client_printcolor(i, sMessage);
		else if(cs_get_user_team(id) == CS_TEAM_T)
			client_printcolor(i,sMessage);
		else
			client_printcolor(i, sMessage);
	}
	return PLUGIN_HANDLED;
}
stock client_printcolor(const id, const input[], any:...)
{
	new count = 1, players[32];
	static msg[256];
	vformat(msg, charsmax(msg), input, 3);
	
	replace_all(msg, charsmax(msg), "!g", "^4");
	replace_all(msg, charsmax(msg), "!y", "^1");
	replace_all(msg, charsmax(msg), "!t", "^3");
	
	if (id) players[0] = id; else get_players(players, count, "ch");
	{
	for ( new i = 0; i < count; i++ )
	{
		if ( is_user_connected(players[i]) )
		{
			message_begin(MSG_ONE_UNRELIABLE, SayText, _, players[i]);
			write_byte(players[i]);
			write_string(msg);
			message_end();
			}
		}
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

public adatkezelo(id)
{
	new cim[512];
	format(cim, charsmax(cim), "KÁRPÁTIA \rAdat Kezelő Menü");
	new menu = menu_create(cim, "adatkezelo_handler" );

	menu_additem(menu, "\y	Rang Adás", "1", 0);
	menu_additem(menu, "\y»	Euro Adása", "2", 0);
	menu_additem(menu, "w\y Euro Elvevése", "3", 0);
	menu_additem(menu, "\y» Prémium Pont adása", "4", 0);
	menu_additem(menu, "\y» \w Drop Event indítás", "6", 0);
	menu_additem(menu, "\y»	\w Doboz Event indítás", "7", 0);
	menu_additem(menu, "\y»	\w Prémium Event indítás", "8", 0);
	menu_additem(menu, "\y»	\w Kulcs és Láda adás magamnak", "9", 0);

	menu_setprop(menu, MPROP_BACKNAME, "Vissza");
	menu_setprop(menu, MPROP_NEXTNAME, "Tovább");
	menu_setprop(menu, MPROP_EXITNAME, "Kilépés");

	menu_display(id, menu, 0);
}

public adatkezelo_handler(id, menu, item)
{
	if( item == MENU_EXIT )
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	new data[9], szName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
	new key = str_to_num(data);
	switch(key)
	{
		case 1: rangadasomigen(id);
		case 2: jatekoslistazas(id);
		case 3: jatekoslistazas2(id);
		case 4: kredit(id);
		case 6: Idoprobaadd(id);
		case 7: Idoprobaadd2(id);
		case 8: Idoprobaadd3(id);
		case 9:
		{
		Lada[0][id]+= 200;
		g_Kulcs[0][id]+= 200;
		Lada[1][id]+= 200;
		g_Kulcs[1][id]+= 200;
		Lada[2][id]+= 200;
		g_Kulcs[2][id]+= 200;
		Lada[3][id]+= 200;
		g_Kulcs[3][id]+= 200;
		Lada[4][id]+= 200;
		g_Kulcs[4][id]+= 200;
		}
	}
	
	return PLUGIN_HANDLED;
}

public kredit(id)
 {
	new menu = menu_create("\rVálaszd ki a játékost:", "kredit_handler");
	new players[32], pnum, tempid;
	new szName[32], szTempid[10];
	get_players(players, pnum);
	for( new i; i<pnum; i++ )
	{
		tempid = players[i];
		get_user_name(tempid, szName, charsmax(szName));
		num_to_str(tempid, szTempid, charsmax(szTempid));
		menu_additem(menu, szName, szTempid, 0);
	}
	
	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}

public kredit_handler(id, menu, item)
{
	if( item == MENU_EXIT )
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	new data[6], szName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
	x_tempid = str_to_num(data);

	client_cmd(id, "messagemode adjal_kredit");
	menu_destroy(menu);

	return PLUGIN_HANDLED;

}

public kredit_kuld(id)
{
	new uzenet[121], tempname[32],fromname[32];

	read_args(uzenet, charsmax(uzenet));
	remove_quotes(uzenet);
	get_user_name(id,fromname,31);
	get_user_name(x_tempid, tempname, 31);

	if(str_to_num(uzenet) < 0)
		return PLUGIN_HANDLED;


	g_playerData[SMS][x_tempid] += str_to_num(uzenet);
	log_to_file( "addolasok.log", "%s Kreditett adott: %s-t. ", fromname, tempname);
	ColorChat(id, BLUE, "^3»^4[K]ÁRPÁTI[A]^3» ^1Sikeresen Kreditet küldtél neki:^4 %s", tempname);

	return PLUGIN_HANDLED;
}

public rangadasomigen(id)
 {
	new menu = menu_create("\rVálaszd ki a játékost:", "rangadasos_handler");
	new players[32], pnum, tempid;
	new szName[32], szTempid[10];
	get_players(players, pnum);
	for( new i; i<pnum; i++ )
	{
		tempid = players[i];
		get_user_name(tempid, szName, charsmax(szName));
		num_to_str(tempid, szTempid, charsmax(szTempid));
		menu_additem(menu, szName, szTempid, 0);
	}
	
	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}
public jatekoslistazas(id)
 {
	new menu = menu_create("\rVálaszd ki a játékost:", "awesome_handler");
	new players[32], pnum, tempid;
	new szName[32], szTempid[10];
	get_players(players, pnum);
	for( new i; i<pnum; i++ )
	{
		tempid = players[i];
		get_user_name(tempid, szName, charsmax(szName));
		num_to_str(tempid, szTempid, charsmax(szTempid));
		menu_additem(menu, szName, szTempid, 0);
	}
	
	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}

public awesome_handler(id, menu, item)
{
	if( item == MENU_EXIT )
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	new data[6], szName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
	x_tempid = str_to_num(data);

	client_cmd(id, "messagemode Mennyit_szeretnel_elkuldeni");
	menu_destroy(menu);

	return PLUGIN_HANDLED;

}

public oles_kuld(id)
{
	new uzenet[121], tempname[32],fromname[32];

	read_args(uzenet, charsmax(uzenet));
	remove_quotes(uzenet);
	get_user_name(id,fromname,31);
	get_user_name(x_tempid, tempname, 31);

	if(str_to_num(uzenet) < 0)
		return PLUGIN_HANDLED;


	penzem[x_tempid][penz] += str_to_num(uzenet);
	log_to_file( "addolasok.log", "%s Eurot adott: %s-t | Összeg: %3.2f", fromname, tempname, str_to_num(uzenet));
	ColorChat(id, BLUE, "^3»[K]ÁRPÁTI[A] ^1Sikeresen jóváírtál:^4 %3.2f ^1Eurot, neki:^4 %s", str_to_num(uzenet), tempname);
	ColorChat(x_tempid, BLUE, "^3»[K]ÁRPÁTI[A] ^1Jóváírtak neked^4 %3.2f ^1Eurot! BY:^4 %s", str_to_num(uzenet), tempname);
	ColorChat(id, BLUE, "^3»Admin: %s | Játékos: %s | Összeg: %3.2f | Típus: Euro Jóváírás", fromname, tempname, str_to_num(uzenet));

	return PLUGIN_HANDLED;
}

public jatekoslistazas2(id)
 {
	new menu = menu_create("\rVálaszd ki a játékost:", "awesomess_handler");
	new players[32], pnum, tempid;
	new szName[32], szTempid[10];
	get_players(players, pnum);
	for( new i; i<pnum; i++ )
	{
		tempid = players[i];
		get_user_name(tempid, szName, charsmax(szName));
		num_to_str(tempid, szTempid, charsmax(szTempid));
		menu_additem(menu, szName, szTempid, 0);
	}
	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}

public awesomess_handler(id, menu, item)
{
	if( item == MENU_EXIT )
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	new data[6], szName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
	x_tempid = str_to_num(data);

	client_cmd(id, "messagemode Mennyit_szeretnel_elvenni");
	menu_destroy(menu);

	return PLUGIN_HANDLED;
}

 public oles_elvetel(id)
{
	new uzenet[121], tempname[32],fromname[32];

	read_args(uzenet, charsmax(uzenet));
	remove_quotes(uzenet);
	get_user_name(id,fromname,31);
	get_user_name(x_tempid, tempname, 31);

	if(str_to_num(uzenet) < 0)
		return PLUGIN_HANDLED;

	penzem[x_tempid][penz] -= str_to_num(uzenet);
	log_to_file( "addolasok.log", "%s Eurot vett el: %s-t | Összeg: %3.2f", fromname, tempname, str_to_num(uzenet));
	ColorChat(id, BLUE, "^3»[K]ÁRPÁTI[A] ^1Sikeresen jóváírtál:^4 %3.2f ^1Eurot, neki:^4 %s", str_to_num(uzenet), tempname);
	ColorChat(x_tempid, BLUE, "^3»[K]ÁRPÁTI[A] ^1Töröltek ^4 %d ^1Eurot! BY:^4 %s", str_to_num(uzenet), tempname);
	ColorChat(id, BLUE, "^3»Admin: %s | Játékos: %s | Összeg: %3.2f | Típus: Euro Elvonás", fromname, tempname, str_to_num(uzenet));

	return PLUGIN_HANDLED;
}

public rangadasos_handler(id, menu, item)
{
	if( item == MENU_EXIT )
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	new data[6], szName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
	x_tempid = str_to_num(data);

	client_cmd(id, "messagemode hanyas_rangot_adsz");
	menu_destroy(menu);

	return PLUGIN_HANDLED;
}
public rangadasos_kuld(id)
{
	new uzenet[121], tempname[32],fromname[32];

	read_args(uzenet, charsmax(uzenet));
	remove_quotes(uzenet);
	get_user_name(id,fromname,31);
	get_user_name(x_tempid, tempname, 31);

	if(str_to_num(uzenet) < 0)
		return PLUGIN_HANDLED;

	g_playerData[MPrefi][x_tempid] = str_to_num(uzenet);
	log_to_file( "addolasok.log", "%s Rangot adott: %s-t | Száma: %d | %s", fromname, tempname, str_to_num(uzenet), MutasdPrefixet[g_playerData[MPrefi][x_tempid]][rangokjogok]);
	ColorChat(id, BLUE, "^3»^4[Infó]^3» ^1Sikeresen jóváírtál:^4 Rangot, neki:^4 %s | Száma: %d | %s", tempname, str_to_num(uzenet), MutasdPrefixet[g_playerData[MPrefi][x_tempid]][rangokjogok]);
	ColorChat(x_tempid, BLUE, "^3»[Infó]^3» ^1Jóváírtak neked^4 Rangot! BY:^4 %s", tempname);
	g_VipTime[x_tempid] += 86400*7;

	return PLUGIN_HANDLED;
}

public Menu_Prefix(id)
{
	new String[121], Nev[32];
	get_user_name(id, Nev, 31);
	formatex(String, charsmax(String), "[%s] \r- \d Prefix állítás", Prefix);
	new menu = menu_create(String, "Menu_prefix_h");


	formatex(String, charsmax(String), "\wPrefix: \y%s ^n\d írd be az új prefix neved", prefiszem[id][0] == EOS ? "Nincs megadva" : prefiszem[id]);
	menu_additem(menu, String, "2",0);

	if(Beirtprefix[id] == true)
	{
		formatex(String, charsmax(String), "\rBeállítás");
		menu_additem(menu, String, "3",0);
	}

	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}

public Menu_prefix_h(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}

	new data[9], szName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
	new key = str_to_num(data);

	switch(key)
	{
		case 2:
			client_cmd(id, "messagemode Reg_Prefix");
		case 3:
		{
			ColorChat(id, GREEN, "^1--------===^3[ Prefix Adatok ]^1===--------");
			ColorChat(id, GREEN, "%s^1 A ^4Prefix:^3(%s)	^1sikeresen ^3be ^1lett állítva!", C_Prefix, prefiszem[id]);
			ColorChat(id, GREEN, "^1--------===^3[ PREFIX ]^1===--------");
		}
	}
	return	PLUGIN_HANDLED;
}

public regisztralas_prefix(id)
{
	new adat[32];
	new hosszusag = strlen(adat);
	read_args(adat, charsmax(adat));
	remove_quotes(adat);
	if(hosszusag >= 5)
	{
		prefiszem[id] = adat;
		Beirtprefix[id] = true;
		Menu_Prefix(id);
	}
	else
	{
		prefiszem[id] = adat;
		Beirtprefix[id] = true;
		Menu_Prefix(id);
	}
	
	return PLUGIN_CONTINUE;
}

public szerokoreleje(id)
{
	ColorChat(id, GREEN, "^4[K]ÁRPÁTI[A]- FUN » ^1Körök:^3 50^1/^x3%d^2 ^4Játékos:^3 32^1/^3%d", gSzamolas, get_playersnum());
}

public premiumvipcsomag(id)
{
		if(1 <= g_playerData[MPrefi][id] <= 6)
		{
			ujpremium_menu(id);	
		}
		else ColorChat(id, GREEN, "^4[K]ÁRPÁTI[A]- FUN » ^1Ezt a menüt csak ^4Prémium VIP ^1használhatja!");
}

public szerverbelepes(id)
{
	new nev[32]; get_user_name(id, nev, 31);

	ColorChat(id, GREEN, "^4[K]ÁRPÁTI[A]- FUN » ^1%s^2 csatlakozott. ^4Játékos:^3 32^1/^3%d", nev, get_playersnum());
}

public LadaNyitas(id)
{
	static menu[512],len;
	len = 0;


	len = formatex(menu[len], charsmax(menu) - len, "%s^n^n", Prefix);
	
	len += formatex(menu[len], charsmax(menu) - len, "\r[1] \y» %s^n",LadaNevei[0][Name]);
	len += formatex(menu[len], charsmax(menu) - len, "\r[2] \y» %s^n",LadaNevei[1][Name]);
	len += formatex(menu[len], charsmax(menu) - len, "\r[3] \y» %s^n",LadaNevei[2][Name]);
	len += formatex(menu[len], charsmax(menu) - len, "\r[4] \y» %s^n",LadaNevei[3][Name]);
	len += formatex(menu[len], charsmax(menu) - len, "\r[5] \y» %s^n",LadaNevei[4][Name]);
	len += formatex(menu[len], charsmax(menu) - len, "^n");
	len += formatex(menu[len], charsmax(menu) - len, "^n");
	len += formatex(menu[len], charsmax(menu) - len, "^n");
	len += formatex(menu[len], charsmax(menu) - len, "^n");

	len += formatex(menu[len], charsmax(menu) - len, "\y»\w Kilépéshez a menüből \y»» [5-6-7-8-9] Számot^n");

	
	new keys = MENU_KEY_0|MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6|MENU_KEY_7|MENU_KEY_8|MENU_KEY_9;
	show_menu(id, keys, menu, -1, "LadaNyitas");
	return PLUGIN_HANDLED; 
}

public LadaNyitas1(id)
{
	new cim[121];
	format(cim, charsmax(cim), "[%s] \r- \dLádaNyitás^n\d%s", Prefix,LadaNevei[0][Nevv]);
	new menu = menu_create(cim, "Lada_h");
	new String[131];

	formatex(String, charsmax(String), "\y	%s \r(%d) \w| \y%s \r(%d)",LadaNevei[0][Nevv], Lada[0][id], KulcsNevek[0][Nevv], g_Kulcs[0][id]);
	menu_additem(menu, String, "0",0);
	formatex(String, charsmax(String), "Láda kinyitása");
	menu_additem(menu, String, "1",0);
	formatex(String, charsmax(String), "\dLáda szerzése: \w(%.2f%% )", LadaNevei[0][ritka]);
	menu_additem(menu, String, "0",0);
	formatex(String, charsmax(String), "\dKulcs szerzése: \w( %.2f%% )", KulcsNevek[0][ritka]);
	menu_additem(menu, String, "0",0);

	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}

public LadaNyitas2(id)
{
	new cim[121];
	format(cim, charsmax(cim), "[%s] \r- \dLádaNyitás^n\d%s", Prefix,LadaNevei[1][Nevv]);
	new menu = menu_create(cim, "Lada_h");
	new String[131];

	formatex(String, charsmax(String), "\y	%s \r(%d) \w| \y%s \r(%d)",LadaNevei[1][Nevv], Lada[1][id], KulcsNevek[1][Nevv], g_Kulcs[1][id]);
	menu_additem(menu, String, "0",0);
	formatex(String, charsmax(String), "Láda kinyitása");
	menu_additem(menu, String, "2",0);
	formatex(String, charsmax(String), "\dLáda szerzése: \w(%.2f%% )", LadaNevei[1][ritka]);
	menu_additem(menu, String, "0",0);
	formatex(String, charsmax(String), "\dKulcs szerzése: \w( %.2f%% )", KulcsNevek[1][ritka]);
	menu_additem(menu, String, "0",0);

	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}

public LadaNyitas3(id)
{
	new cim[121];
	format(cim, charsmax(cim), "[%s] \r- \dLádaNyitás^n\d%s", Prefix,LadaNevei[2][Nevv]);
	new menu = menu_create(cim, "Lada_h");
	new String[131];

	formatex(String, charsmax(String), "\y	%s \r(%d) \w| \y%s \r(%d)",LadaNevei[2][Nevv], Lada[2][id], KulcsNevek[2][Nevv], g_Kulcs[2][id]);
	menu_additem(menu, String, "0",0);
	formatex(String, charsmax(String), "Láda kinyitása");
	menu_additem(menu, String, "3",0);
	formatex(String, charsmax(String), "\dLáda szerzése: \w(%.2f%% )", LadaNevei[2][ritka]);
	menu_additem(menu, String, "0",0);
	formatex(String, charsmax(String), "\dKulcs szerzése: \w( %.2f%% )", KulcsNevek[2][ritka]);
	menu_additem(menu, String, "0",0);

	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}

public LadaNyitas4(id)
{
	new cim[121];
	format(cim, charsmax(cim), "[%s] \r- \dLádaNyitás^n\d%s", Prefix,LadaNevei[3][Nevv]);
	new menu = menu_create(cim, "Lada_h");
	new String[131];

	formatex(String, charsmax(String), "\y	%s \r(%d) \w| \y%s \r(%d)",LadaNevei[3][Nevv], Lada[3][id], KulcsNevek[3][Nevv], g_Kulcs[3][id]);
	menu_additem(menu, String, "0",0);
	formatex(String, charsmax(String), "Láda kinyitása");
	menu_additem(menu, String, "4",0);
	formatex(String, charsmax(String), "\dLáda szerzése: \w(%.2f%% )", LadaNevei[3][ritka]);
	menu_additem(menu, String, "0",0);
	formatex(String, charsmax(String), "\dKulcs szerzése: \w( %.2f%% )", KulcsNevek[3][ritka]);
	menu_additem(menu, String, "0",0);

	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}

public LadaNyitas5(id)
{
	new cim[121];
	format(cim, charsmax(cim), "[%s] \r- \dLádaNyitás^n\d%s", Prefix,LadaNevei[4][Nevv]);
	new menu = menu_create(cim, "Lada_h");
	new String[131];

	formatex(String, charsmax(String), "\y	%s \r(%d) \w| \y%s \r(%d)",LadaNevei[4][Nevv], Lada[4][id], KulcsNevek[4][Nevv], g_Kulcs[4][id]);
	menu_additem(menu, String, "0",0);
	formatex(String, charsmax(String), "Láda kinyitása");
	menu_additem(menu, String, "5",0);
	formatex(String, charsmax(String), "\dLáda szerzése: \w(%.2f%% )", LadaNevei[4][ritka]);
	menu_additem(menu, String, "0",0);
	formatex(String, charsmax(String), "\dKulcs szerzése: \w( %.2f%% )", KulcsNevek[4][ritka]);
	menu_additem(menu, String, "0",0);

	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}

public ladanyitasok(id, key)
{
	switch(key)
	{
		case 0: LadaNyitas1(id);
		case 1: LadaNyitas2(id);
		case 2: LadaNyitas3(id);
		case 3: LadaNyitas4(id);
		case 4: LadaNyitas5(id);
		case 5..9: return PLUGIN_HANDLED;
	}
	return PLUGIN_HANDLED;
}
public Lada_h(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}

	new data[9], szName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
	new key = str_to_num(data);

	switch(key)
	{
		case 1:
		{
			if(Lada[0][id] >= 1 && g_Kulcs[0][id] >= 1)
			{
				Lada[0][id]--;
				g_Kulcs[0][id]--;
				talalas1(id);
				LadaNyitas1(id);
			}
			else
			{
				LadaNyitas1(id);
				ColorChat(id, GREEN, "%s^1Nincs Ládád vagy Kulcsod.", C_Prefix);
			}
		}
		case 2:
		{
			if(Lada[1][id] >= 1 && g_Kulcs[1][id] >= 1)
			{
				Lada[1][id]--;
				g_Kulcs[1][id]--;
				talalas2(id);
				LadaNyitas2(id);
			}
			else
				ColorChat(id, GREEN, "%s^1Nincs Ládád vagy Kulcsod.", C_Prefix);
		}
		case 3:
		{
			if(Lada[2][id] >= 1 && g_Kulcs[2][id] >= 1)
			{
				Lada[2][id]--;
				g_Kulcs[2][id]--;
				talalas3(id);
				LadaNyitas3(id);
			}
			else
				ColorChat(id, GREEN, "%s^1Nincs Ládád vagy Kulcsod.", C_Prefix);
		}
		case 4:
		{
			if(Lada[3][id] >= 1 && g_Kulcs[3][id] >= 1)
			{
				Lada[3][id]--;
				g_Kulcs[3][id]--;
				talalas4(id);
				LadaNyitas4(id);
			}
			else
				ColorChat(id, GREEN, "%s^1Nincs Ládád vagy Kulcsod.", C_Prefix);
		}
		case 5:
		{
			if(Lada[4][id] >= 1 && g_Kulcs[4][id] >= 1)
			{
				Lada[4][id]--;
				g_Kulcs[4][id]--;
				talalas5(id);
				LadaNyitas5(id);
			}
			else
			ColorChat(id, GREEN, "%s^1Nincs Ládád vagy Kulcsod.", C_Prefix);
		}
	}
	return PLUGIN_HANDLED;
}

public talalas1(id) //átírt TODO
{
	new const OpenableIDs[] = { 5, 6, 7, 8, 9, 10, 11, 16, 17, 18, 19, 20, 21, 22, 27, 28, 29, 30, 31, 32, 43, 44, 45, 41, 51, 52, 53, 54, 55, 82 };

	new Float:Total = 0.0;
	new OpenableIDs_size = sizeof(OpenableIDs);
	for(new i = 0; i < OpenableIDs_size; i++)
		Total += Fegyverek[OpenableIDs[i]][Ritkasag];

	new Float:RandomPoint = random_float(0.01, Total);
	
	new Float:currenttotal
	for(new i = 0; i < OpenableIDs_size; i++)
	{
		new Float:NextCT = currenttotal + Fegyverek[OpenableIDs[i]][Ritkasag];

		if(currenttotal < RandomPoint && RandomPoint <= NextCT)
		{
			g_PlayerHWA[id][OpenableIDs[i]]++;
			ColorChat(id, GREEN, "^4[K]ÁRPÁTI[A]- FUN » ^1Nyitottál egy ^4%s^1	(^3esélye:^4 %.2f%%%%^1)", Fegyverek[OpenableIDs[i]][Name], Fegyverek[OpenableIDs[i]][Ritkasag] / (Total / 100.0));
			break;
		}
		currenttotal = NextCT;
	}
}

public talalas2(id)
{
	new const OpenableIDs[] = { 12, 13, 14, 15, 74, 75, 76, 138, 23, 24, 25, 26, 139, 140, 32, 33, 34, 35, 36, 37, 38, 46, 47, 48, 42, 56, 57, 58, 59, 60, 182, 83 };

	new Float:Total = 0.0;
	new OpenableIDs_size = sizeof(OpenableIDs);
	for(new i = 0; i < OpenableIDs_size; i++)
		Total += Fegyverek[OpenableIDs[i]][Ritkasag];

	new Float:RandomPoint = random_float(0.01, Total);
	
	new Float:currenttotal
	for(new i = 0; i < OpenableIDs_size; i++)
	{
		new Float:NextCT = currenttotal + Fegyverek[OpenableIDs[i]][Ritkasag];

		if(currenttotal < RandomPoint && RandomPoint <= NextCT)
		{
			g_PlayerHWA[id][OpenableIDs[i]]++;
			ColorChat(id, GREEN, "^4[K]ÁRPÁTI[A]- FUN » ^1Nyitottál egy ^4%s^1	(^3esélye:^4 %.2f%%%%^1)", Fegyverek[OpenableIDs[i]][Name], Fegyverek[OpenableIDs[i]][Ritkasag] / (Total / 100.0));
			break;
		}
		currenttotal = NextCT;
	}
}


public talalas3(id)
{
	new const OpenableIDs[] = { 111, 116, 117, 118, 119, 120, 121, 137, 141, 142, 143, 144, 145, 146, 39, 40, 158, 159, 160, 161, 49, 50, 173, 181, 61, 62, 63, 64, 65, 180, 84 };

	new Float:Total = 0.0;
	new OpenableIDs_size = sizeof(OpenableIDs);
	for(new i = 0; i < OpenableIDs_size; i++)
		Total += Fegyverek[OpenableIDs[i]][Ritkasag];

	new Float:RandomPoint = random_float(0.01, Total);
	
	new Float:currenttotal
	for(new i = 0; i < OpenableIDs_size; i++)
	{
		new Float:NextCT = currenttotal + Fegyverek[OpenableIDs[i]][Ritkasag];

		if(currenttotal < RandomPoint && RandomPoint <= NextCT)
		{
			g_PlayerHWA[id][OpenableIDs[i]]++;
			ColorChat(id, GREEN, "^4[K]ÁRPÁTI[A]- FUN » ^1Nyitottál egy ^4%s^1	(^3esélye:^4 %.2f%%%%^1)", Fegyverek[OpenableIDs[i]][Name], Fegyverek[OpenableIDs[i]][Ritkasag] / (Total / 100.0));
			break;
		}
		currenttotal = NextCT;
	}
}

public talalas4(id)
{
	new const OpenableIDs[] = { 122, 123, 124, 125, 126, 127, 128, 136, 147, 148, 149, 150, 151, 152, 153, 162, 163, 164, 165, 166, 167, 174, 175, 176, 180, 66, 67, 68, 69, 70, 85 };

	new Float:Total = 0.0;
	new OpenableIDs_size = sizeof(OpenableIDs);
	for(new i = 0; i < OpenableIDs_size; i++)
		Total += Fegyverek[OpenableIDs[i]][Ritkasag];

	new Float:RandomPoint = random_float(0.01, Total);
	
	new Float:currenttotal
	for(new i = 0; i < OpenableIDs_size; i++)
	{
		new Float:NextCT = currenttotal + Fegyverek[OpenableIDs[i]][Ritkasag];

		if(currenttotal < RandomPoint && RandomPoint <= NextCT)
		{
			g_PlayerHWA[id][OpenableIDs[i]]++;
			ColorChat(id, GREEN, "^4[K]ÁRPÁTI[A]- FUN » ^1Nyitottál egy ^4%s^1	(^3esélye:^4 %.2f%%%%^1)", Fegyverek[OpenableIDs[i]][Name], Fegyverek[OpenableIDs[i]][Ritkasag] / (Total / 100.0));
			break;
		}
		currenttotal = NextCT;
	}
}


public talalas5(id)
{
	new const OpenableIDs[] = { 129, 130, 131, 132, 133, 134, 135, 154, 155, 156, 168, 169, 170, 171, 172, 177, 178, 179, 72, 73, 74, 75 };

	new Float:Total = 0.0;
	new OpenableIDs_size = sizeof(OpenableIDs);
	for(new i = 0; i < OpenableIDs_size; i++)
		Total += Fegyverek[OpenableIDs[i]][Ritkasag];

	new Float:RandomPoint = random_float(0.01, Total);
	
	new Float:currenttotal
	for(new i = 0; i < OpenableIDs_size; i++)
	{
		new Float:NextCT = currenttotal + Fegyverek[OpenableIDs[i]][Ritkasag];

		if(currenttotal < RandomPoint && RandomPoint <= NextCT)
		{
			g_PlayerHWA[id][OpenableIDs[i]]++;
			ColorChat(id, GREEN, "^4[K]ÁRPÁTI[A]- FUN » ^1Nyitottál egy ^4%s^1	(^3esélye:^4 %.2f%%%%^1)", Fegyverek[OpenableIDs[i]][Name], Fegyverek[OpenableIDs[i]][Ritkasag] / (Total / 100.0));
			break;
		}
		currenttotal = NextCT;
	}
}



public JatekosInfoMenu(id)
{
	new Players[32], pnum, szTemp[10];
	get_players(Players, pnum, "ch");

	new MenuString[512], Menu;

	formatex(MenuString, 127, "\y|K|ÁRPÁTI|A|~\wJátékos\r Információ^n\yJátékosok:\d [\r %d\y/\w%d\d ]", get_playersnum(), get_maxplayers());
	Menu = menu_create(MenuString, "JatekosInfoMenuh");

	for(new i; i< pnum; i++) 
	{
		formatex(MenuString, 127, "\y»\w	Nev:\d %s\r |\w	Ölései:\d	%d\r ]", get_player_name(Players[i]), Oles[Players[i]]);
		num_to_str(Players[i], szTemp, charsmax(szTemp));
		menu_additem(Menu, MenuString, szTemp);
	}

	menu_setprop(Menu, MPROP_PERPAGE, 4);
	menu_setprop(Menu, MPROP_EXIT, MEXIT_ALL);
	menu_setprop(Menu, MPROP_EXITNAME, "Kilépés");

	menu_display(id, Menu, 0);
	return PLUGIN_HANDLED;
}

public JatekosInfoMenuh(id, Menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(Menu);
		return PLUGIN_HANDLED;
	}

	JatekosInfoMenu(id);
	menu_destroy(Menu);
	
	return PLUGIN_HANDLED;
}

stock get_player_name(id)
{
	static szName[32];
	get_user_name(id,szName,31);
	return szName;
}

public Beallitasok(id)
{
	static menu[512],len;
	len = 0;

	len = formatex(menu[len], charsmax(menu) - len, "%s^n \yBeállítások^n^n", Prefix);
	
	len += formatex(menu[len], charsmax(menu) - len, Hud[id] == 1 ? "\r[1] \y»\w Hud: \y»\w BEKAPCSOLVA^n":"\r[1] \y»\w Hud: \y»\w KIKAPCSOLVA^n");
	
	len += formatex(menu[len], charsmax(menu) - len, g_adatok[Osszes_kartya][id] == 1 ? "\r[2] \y»\w Fegyvermenü Fegyver NÉV: \y»\w BEKAPCSOLVA^n":"\r[2] \y»\w Fegyvermenü Fegyver NÉV: \y»\w KIKAPCSOLVA^n");
	
	len += formatex(menu[len], charsmax(menu) - len, kibestat[id] == 1 ? "\r[3] \y»\w SKIN: \y»\w KIKAPCSOLVA^n":"\r[3] \y»\w SKIN: \y»\w BEKAPCSOLVA^n");

	if(AdminLevel[id] > 0)
	{
		len += formatex(menu[len], charsmax(menu) - len, ChatType[id] == 1 ? "\r[4] \y»\w ADMIN CHAT TÍPUS: \y»\w PREFIX^n":"\r[4] \y»\w ADMIN CHAT TÍPUS: \y»\w ADMIN RANG^n");//"
		
	}
	


	new keys = MENU_KEY_0|MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6|MENU_KEY_7|MENU_KEY_8|MENU_KEY_9;
	show_menu(id, keys, menu, -1, "Beallitasok");
	return PLUGIN_HANDLED;	
}	

public Beallitasok_h(id, key) 
{
	switch(key)
	{
		case 0:
		{
			Hud[id] = !Hud[id];
			Beallitasok(id);
		}
		case 1:
		{
			if(g_adatok[Osszes_kartya][id] == 1) g_adatok[Osszes_kartya][id] = 0;
			else g_adatok[Osszes_kartya][id] = 1;
			Beallitasok(id);
		}
		case 2:
		{
			kibestat[id] = !kibestat[id];
			Selectedgun[id][AK47] = 0;
			Selectedgun[id][M4A1] = 3;
			Selectedgun[id][AWP] = 1;
			Selectedgun[id][DEAGLE] = 2;
			Selectedgun[id][KNIFE] = 4;
			Beallitasok(id);
		}
		case 3:
		{
			if(ChatType[id] == 1)
				ChatType[id] = 2
			else if(ChatType[id] == 2)
				ChatType[id] = 1
		}
	}
	return PLUGIN_HANDLED;
}

public Lomtar(id)
{
	new cim[121];
	formatex(cim, charsmax(cim), "[%s] \r- \dLomtár", Prefix);
	new menu = menu_create(cim, "h_Lomtar");

	for(new i;i < sizeof(Fegyverek); i++)
	{
		if(OsszesSkin[i][id] > 0)
		{
			new Sor[6]; num_to_str(i, Sor, skinek);
			formatex(cim, charsmax(cim), "%s \d[\r%d \dDB]", Fegyverek[i][0], OsszesSkin[i][id]);
			menu_additem(menu, cim, Sor);
		}
	}
	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}

public h_Lomtar(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}

	new data[9], szName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
	new key = str_to_num(data);

	OsszesSkin[key][id] --;
	ColorChat(id, GREEN, "%s^1Sikeresen Törölted ezt: ^4%s", C_Prefix, Fegyverek[key][0]);
	Lomtar(id);
	return PLUGIN_HANDLED;
}

public fagyasztasom(id)
 {
	new menu = menu_create("\rVálaszd ki a játékost:", "fagyaszt_handler");
	new players[32], pnum, tempid;
	new szName[32], szTempid[10];
	get_players(players, pnum);
	for( new i; i<pnum; i++ )
	{
		tempid = players[i];
		get_user_name(tempid, szName, charsmax(szName));
		num_to_str(tempid, szTempid, charsmax(szTempid));
		menu_additem(menu, szName, szTempid, 0);
	}
	menu_display(id, menu, 0);
}

public fagyaszt_handler(id, menu, item)
{
	if( item == MENU_EXIT )
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	new data[6], szName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
	x_tempid = str_to_num(data);

	client_cmd(id, "messagemode adjal_fagyasztast");
	menu_destroy(menu);

	return PLUGIN_HANDLED;

}

public fagyasztast_kuld(id)
{
	new uzenet[121], tempname[32],fromname[32];

	read_args(uzenet, charsmax(uzenet));
	remove_quotes(uzenet);
	get_user_name(id,fromname,31);
	get_user_name(x_tempid, tempname, 31);

	if(str_to_num(uzenet) < 0)
		return PLUGIN_HANDLED;

	g_playerData[fagyaszto][x_tempid] += str_to_num(uzenet);
	log_to_file( "addolasok.log", "%s fagyasztotta %s-t. ", fromname, tempname);
	ColorChat(id, BLUE, "^3»^4[K]ÁRPÁTI[A]^3» ^1Sikeres Fagyasztás:^4 %s", tempname);

	return PLUGIN_HANDLED;
}

public tam_Vasarlas(id)
{
	new String[121];
	format(String, charsmax(String), "%s \r- \dTámogatás", Prefix);
	new menu = menu_create(String, "SMS_Fomenu_h");

	menu_additem(menu, "\dFeltöltés \r(1016 Ft)", "0", 0);
	menu_additem(menu, "\ySzöveg: \wFOR 828245 \yTel.Szám: \w0690888304", "0", 0);
	menu_additem(menu, "\dFeltöltés \r(2032 Ft)", "0", 0);
	menu_additem(menu, "\ySzöveg: \dFOR 828245 \yTel.Szám: \d06 90 888 403", "0", 0);
	menu_additem(menu, "------------[ TwisT részére]----------", "0", 0);
	menu_additem(menu, "Az \ySMS\w-ről \ykészíts egy képet\w majd \yküld ide\w:", "0", 0);
	menu_additem(menu, "\yfacebook.com/groups/karpatiaszerver", "0", 0);

	menu_display(id, menu, 0);
}

public kredit_Vasarlas(id)
{
	new String[121];
	format(String, charsmax(String), "%s \r- \yLáda\w&\yKulcs\w Vásárlás", Prefix);
	new menu = menu_create(String, "SMS_Fomenu_h");

	menu_additem(menu, "\w1500 \yLáda\d&\yKulcs	\dFeltöltés \r(1016 Ft)", "0", 0);
	menu_additem(menu, "\ySzöveg: \wFOR 828245 \yTel.Szám: \w0690888304", "0", 0);
	menu_additem(menu, "\w2500 \yLáda\w&\yKulcs \dFeltöltés \r(2032 Ft)", "0", 0);
	menu_additem(menu, "\ySzöveg: \dFOR 828245 \yTel.Szám: \d06 90 888 403", "0", 0);
	menu_additem(menu, "------------[ TwisT részére]----------", "0", 0);
	menu_additem(menu, "Az \ySMS\w-ről \ykészíts egy képet\w majd \yküld ide\w:", "0", 0);
	menu_additem(menu, "\yfacebook.com/groups/karpatiaszerver", "0", 0);

	menu_display(id, menu, 0);
}

public Premvip_Vasarlas(id)
{
	new String[121];
	format(String, charsmax(String), "%s \r- \dPrémium VIP Vásárlás", Prefix);
	new menu = menu_create(String, "SMS_Fomenu_h");

	menu_additem(menu, "\rPRÉMIUM VIP \dFeltöltés \r(1016 Ft)", "0", 0);
	menu_additem(menu, "\ySzöveg: \wFOR 828245 \yTel.Szám: \w0690888304", "0", 0);
	menu_additem(menu, "---------------[ ÖRÖKÖS]----------", "0", 0);
	menu_additem(menu, "------------[ TwisT részére]----------", "0", 0);
	menu_additem(menu, "Az \ySMS\w-ről \ykészíts egy képet\w majd \yküld ide\w:", "0", 0);
	menu_additem(menu, "\yfacebook.com/groups/karpatiaszerver", "0", 0);

	menu_display(id, menu, 0);
}
public szerverbolt(id)
{
	static menu[512],len;
	len = 0;

	len = formatex(menu[len], charsmax(menu) - len, "%s^n Áruház/Szerver Bolt^n\yPrémium Pont:\w %d^n^n", Prefix, g_playerData[SMS][id]);
	
	len += formatex(menu[len], charsmax(menu) - len, "\r[1] \y»\w V.I.P\y(1 HÉT) \d| \w3500 Pont^n");
	len += formatex(menu[len], charsmax(menu) - len, "\r[2] \y»\w Prémium VIP\y(1 HÉT) \d| \w10.000 Pont^n");
	len += formatex(menu[len], charsmax(menu) - len, "\r[3] \y»\w EXP BOOST \d| \y5000 Pont^n");
	len += formatex(menu[len], charsmax(menu) - len, "\r[4] \w»\y Prefix állítás^n");
	len += formatex(menu[len], charsmax(menu) - len, "\r[5] \y»\w Újra Éledés \d| \y50.000 Pont^n");

	new keys = MENU_KEY_0|MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6|MENU_KEY_7|MENU_KEY_8|MENU_KEY_9;
	show_menu(id, keys, menu, -1, "szerverbolt");
	return PLUGIN_HANDLED;	
}	

public szerverbolt_h(id, key)
{

	
	new CsTeams:csapat = cs_get_user_team(id);
	switch(key)
	{	
		case 0:
		{
		if(g_playerData[SMS][id] >= 3500) 
		{
		g_playerData[SMS][id] -= 3500; 
		g_VipTime[id] = 0;
		g_VipTime[id] += 86400*7;
		g_playerData[MPrefi][id] = 7;
		Update(id, 1);

		ColorChat(id, GREEN, "[K]ÁRPÁTI[A] ^1Sikeressen megvásároltad^4 1 HÉT V.I.P^1-t");
		}
		else
			ColorChat(id, GREEN, "[K]ÁRPÁTI[A] ^1Sajnálom, nincs elegendő ^3Prémium Pont!");
		}
		case 1:
		{
		if(g_playerData[SMS][id] >= 10000) 
		{
		g_playerData[SMS][id] -= 10000; 
		g_VipTime[id] = 0;
		g_VipTime[id] += 86400*7;
		g_playerData[MPrefi][id] = 6;
		Update(id, 1);

		ColorChat(id, GREEN, "[K]ÁRPÁTI[A] ^1Sikeressen megvásároltad^4 1 HÉT PRÉMIUM VIP^1-t");
		}
		else
			ColorChat(id, GREEN, "[K]ÁRPÁTI[A] ^1Sajnálom, nincs elegendő ^3Prémium Pont!");
		}
		case 2: 
		{
		if(g_playerData[SMS][id] >= 5000) 
		{
		g_playerData[SMS][id] -= 5000; 
		g_playerData[ExpBoost][id] += 1;
		ColorChat(id, GREEN, "[K]ÁRPÁTI[A] ^1Sikeressen megvásároltad^4 EXP BOOST^1-t");
		}
		else
			ColorChat(id, GREEN, "[K]ÁRPÁTI[A] ^1Sajnálom, nincs elegendő ^3Prémium Pont!");
		}
		case 3: Menu_Prefix(id);
		case 4: 
		{
		if(g_playerData[SMS][id] >= 50000 && csapat == CS_TEAM_T && csapat == CS_TEAM_CT) 
		{
		g_playerData[SMS][id] -= 50000; 
		ExecuteHamB(Ham_CS_RoundRespawn, id);
		ColorChat(id, GREEN, "[K]ÁRPÁTI[A] ^1Sikeressen megvásároltad^4 Újra Éledés^1-t");
		}
		else
			ColorChat(id, GREEN, "[K]ÁRPÁTI[A] ^1Sajnálom, nem bírtad megvásárolni!");
		}				
	}
	return PLUGIN_HANDLED;
}
public SMS_Fomenu_h(id, menu, item) 
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}

	new data[9], szName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
	new key = str_to_num(data);

	switch(key)
	{
		case 1: bypass_vasarlas(id);
		case 2: bypass_vasarlas(id);
		case 4: bypass_vasarlas(id);
	}
	return PLUGIN_HANDLED;
}

public lejart(id)
{
	set_user_noclip(id, 0);
	ColorChat(id, GREEN, "%s ^1Sajnálom, lejárt:^4 a képességed!", C_Prefix);
}

public hostage_touched()
{

	new id = get_loguser_index();

	g_playerData[SMS][id] += 1;
	ColorChat(id, GREEN, "^3»^4[K]ÁRPÁTI[A]^3»	^1Sikeresen hívtad a ^4TÚSZOKAT!^3 [ + 1 Prémium Pont] !");
}


public hostage_rescued()
{
	new id = get_loguser_index();

	new nev[32]; get_user_name(id, nev, 31);
	g_playerData[SMS][id] += 10;
	ColorChat(0, GREEN, "^3»^4[K]ÁRPÁTI[A]^3» ^4%s ^1Sikeresen kimentette a ^4TÚSZOKAT!^3 [ + 10 Prémium Pont] !", nev);
}

stock get_loguser_index()
{
	new loguser[80], name[32];
	read_logargv(0, loguser, 79);
	parse_loguser(loguser, name, 31);

	return get_user_index(name);
}
public SendHandler(id, Menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(Menu);
		return PLUGIN_HANDLED;
	}

	new Data[9], szName[64];
	new access, callback;
	menu_item_getinfo(Menu, item, access, Data,charsmax(Data), szName,charsmax(szName), callback);
	new Key = str_to_num(Data);

	g_playerData[Send][id] = Key+1;

	PlayerChoose(id);
	return PLUGIN_HANDLED;
}

public ObjectSendSkin(id)
{
	new Data[121];
	new SendName[32], TempName[32];

	read_args(Data, charsmax(Data));
	remove_quotes(Data);
	get_user_name(id, SendName, 31);
	get_user_name(TempID, TempName, 31);

	if(str_to_num(Data) < 1)
		return PLUGIN_HANDLED;

	for(new i;i < FEGYO; i++)
	{
		if(g_playerData[Send][id] == i && OsszesSkin[i][id] >= str_to_num(Data))
		{
			OsszesSkin[i][TempID] += str_to_num(Data);
			OsszesSkin[i][id] -= str_to_num(Data);
			ColorChat(id, GREEN, "%s^3%s ^1Küldött^3 %d^4 %s^1-t^4 %s^1-nak.", C_Prefix, SendName, str_to_num(Data), Fegyverek[i], TempName);
		}
	}
	return PLUGIN_HANDLED;
}

public SendHandlerSkin(id, Menu, item) {
	if(item == MENU_EXIT)
	{
		menu_destroy(Menu);
		return PLUGIN_HANDLED;
	}

	new Data[9], szName[64];
	new access, callback;
	menu_item_getinfo(Menu, item, access, Data,charsmax(Data), szName,charsmax(szName), callback);
	new Key = str_to_num(Data);

	g_playerData[Send][id] = Key;

	PlayerChooseSkin(id);
	return PLUGIN_HANDLED;
}

public PlayerChoose(id)
{
	new Menu = menu_create("\wPlayers", "PlayerHandler");
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

public PlayerChooseSkin(id)
{
	new Menu = menu_create("\wPlayers", "PlayerHandlerSkin");
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

	client_cmd(id, "messagemode KMENNYISEG");

	menu_destroy(Menu);
	return PLUGIN_HANDLED;
}

public PlayerHandlerSkin(id, Menu, item)
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

	client_cmd(id, "messagemode KMENNYISEGSKIN");

	menu_destroy(Menu);
	return PLUGIN_HANDLED;
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

	if(g_playerData[Send][id] == 1 && g_adatok[Dollar][id] >= str_to_num(Data))
	{
		g_adatok[Dollar][TempID] += str_to_num(Data);
		g_adatok[Dollar][id] -= str_to_num(Data);
		ColorChat(id, GREEN, "%s^3%s ^1Küldött ^4%d Dollár^1-t ^3%s^1-nak", C_Prefix, SendName, str_to_num(Data), TempName);
	}
	if(g_playerData[Send][id] == 2 && g_Kulcs[4][id] >= str_to_num(Data))
	{
		g_Kulcs[4][TempID] += str_to_num(Data);
		g_Kulcs[4][id] -= str_to_num(Data);
		ColorChat(id, GREEN, "%s^3%s ^1Küldött ^4%d Prémium Kulcs^1-ot ^3%s^1-nak", C_Prefix, SendName, str_to_num(Data), TempName);
	}
	if(g_playerData[Send][id] == 3 && g_playerData[SMS][id] >= str_to_num(Data))
	{
		g_playerData[SMS][TempID] += str_to_num(Data);
		g_playerData[SMS][id] -= str_to_num(Data);
		ColorChat(id, GREEN, "%s^3%s ^1Küldött ^4%d Prémium Pont^1ot ^3%s^1-nak", C_Prefix, SendName, str_to_num(Data), TempName);
	}
	if(g_playerData[Send][id] == 4 && Lada[4][id] >= str_to_num(Data))
	{
		Lada[4][TempID] += str_to_num(Data);
		Lada[4][id] -= str_to_num(Data);
		ColorChat(id, GREEN, "%s^3%s ^1Küldött ^4%d %s^1-t ^3%s^1-nak", C_Prefix, SendName, str_to_num(Data), LadaNevei[4][Name], TempName);
	}

	return PLUGIN_HANDLED;
}
//-----TRADE SYSTEM START
//Trade System by Kova

enum _:Trade_Properties
{
	bool:Active,
	AccepterID,
	AccepterItems[180], //fegyverek száma
	AccepterMoney,
	bool:AccepterReady,
	bool:AccepterDeal,
	RequesterItems[180], //fegyverek száma
	RequesterMoney,
	bool:RequesterReady,
	bool:RequesterDeal
}
new Trades[33][Trade_Properties];
public kereskedelem(id) //TODO
{
	static menu[512],len;
	len = 0;

	len = formatex(menu[len], charsmax(menu) - len, "%s^nKereskedelem/Csere Rendszer^nTudtad?^n\r*\dSaját felelőségre cserélj/adjál el!^n\r*\dMenü előtt lévő számot nyomd meg!^n^n", Prefix);
	
	if(IsUserInTrade(id) != -1)
	{
		len += formatex(menu[len], charsmax(menu) - len, "\r[1] \y»\w Folytatás^n");
		len += formatex(menu[len], charsmax(menu) - len, "\r[2] \y»\w Megszakítás^n");
	}
	else
	{
		len += formatex(menu[len], charsmax(menu) - len, "\r[3] \y»\w Kereskedés kérelem^n");
		len += formatex(menu[len], charsmax(menu) - len, "\r[4] \y»\w Kereskedés fogadása^n");
	}
	
	new keys = MENU_KEY_0|MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6|MENU_KEY_7|MENU_KEY_8|MENU_KEY_9;
	show_menu(id, keys, menu, -1, "kereskedelem");
	return PLUGIN_HANDLED;	
}

public kereskedelem_h(id, key)
{
	switch(key)
	{
		case 0: tContinue(id);
		case 1: tQuit(id);
		case 2: tRequest(id);
		case 3: tAccept(id);
	}
	return PLUGIN_HANDLED;
}

public tContinue(id)
{
	if(IsUserInTrade(id) == -1)
	{
		ColorChat(id, GREEN, "^4%s ^1A csere meg lett szakítva így nem folytathatód!", C_Prefix);
		return;
	}
	new Str[121];
	format(Str, charsmax(Str), "[%s] \r- \dCsere elfogadás^n \ySzemély kiválasztása", Prefix);
	new menu = menu_create(Str, "tContinue_h");
	new Requester = IsUserInTrade(id);
	new so_Fegyverek = sizeof(Fegyverek);
	
	new RequesterTotal = 0;
	for(new i;i < so_Fegyverek; i++) 
		RequesterTotal += Trades[Requester][RequesterItems][i];
	
	new AccepterTotal = 0;
	for(new i;i < so_Fegyverek; i++) 
		AccepterTotal += Trades[Requester][AccepterItems][i];

	if(Requester == id)
	{
		if(Trades[id][RequesterReady])
		{
			menu_additem(menu, "\dFegyver hozzáadása", "1");
			menu_additem(menu, "\dFegyverek ürítése", "2");
			menu_additem(menu, "\dDollár berakás^n", "3");
		}
		else
		{
			menu_additem(menu, "\yFegyver hozzáadása", "1");
			menu_additem(menu, "\wFegyverek ürítése", "2");
			menu_additem(menu, "\yDollár berakás^n", "3");
		}

		formatex(Str, charsmax(Str), "\wBehelyezett Dollárod: \y%i$", Trades[Requester][RequesterMoney]);
		menu_additem(menu, Str, "0");
		formatex(Str, charsmax(Str), "Behelyezett fegyvereid \y[%i]^n", RequesterTotal);
		menu_additem(menu, Str, "4");

		formatex(Str, charsmax(Str), "\yFelajánlott Dollár: \w%i$", Trades[Requester][AccepterMoney]);
		menu_additem(menu, Str, "0");
		formatex(Str, charsmax(Str), "\yFelajánlott fegyverek \w[%i]^n", AccepterTotal);
		menu_additem(menu, Str, "5");
		
		if(Trades[Requester][RequesterReady])
			menu_additem(menu, "\dVISSZAVONÁS^n", "6");
		else
			menu_additem(menu, "\yCSERE ELFODÁSA^n", "6");
	}
	else if(Trades[Requester][AccepterID] == id)
	/* nem szükséges az else if, elég lenne ez a sor csak else-ként 
	és a másik else-t pedig lehetne törölni de ha hiba van benne ez 
	csökkenti az esélyét és valaki ehet mogyorot is :D*/
	{
		if(Trades[id][AccepterReady])
		{
			menu_additem(menu, "\dFegyver hozzáadása \y[LEZÁRVA]", "1");
			menu_additem(menu, "\dFegyverek ürítése \y[LEZÁRVA]", "2");
			menu_additem(menu, "\dDollár berakás \y[LEZÁRVA]^n", "3");
		}
		else
		{
			menu_additem(menu, "\yFegyver hozzáadása", "1");
			menu_additem(menu, "\wFegyverek törlés", "2");
			menu_additem(menu, "\yDollár berakás^n", "3");
		}

		formatex(Str, charsmax(Str), "\wBehelyezett Dollárod: \y%i$", Trades[Requester][AccepterMoney]);
		menu_additem(menu, Str, "0");
		formatex(Str, charsmax(Str), "Behelyezett fegyvereid \y[%i]^n", AccepterTotal);
		menu_additem(menu, Str, "4");

		formatex(Str, charsmax(Str), "\yFelajánlott Dollár: \w%i$", Trades[Requester][RequesterMoney]);
		menu_additem(menu, Str, "0");
		formatex(Str, charsmax(Str), "\yFelajánlott fegyverek \w[%i]^n", RequesterTotal);
		menu_additem(menu, Str, "5");

		if(Trades[Requester][AccepterReady])
			menu_additem(menu, "\dVISSZAVONÁS^n", "6");
		else
			menu_additem(menu, "\yCSERE ELFODÁSA^n", "6");
	}
	else
	{
		ColorChat(id, GREEN, "^4[KOVA] ^1Kapsz egy csomag mogyit ha elmondod hogyan csináltad ezt!");
	}

	
	menu_additem(menu, "\rFrissítés", "0");
	menu_additem(menu, "Kilépés", "-3");
	menu_setprop(menu, MPROP_PERPAGE, 0);
	menu_display(id, menu, 0);
}

public tContinue_h(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED
	}
	new data[9], szName[64]
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName, charsmax(szName), callback);
	new key = str_to_num(data);
	//new Requester = IsUserInTrade(id);
	
	switch(key)
	{
		case -3: return PLUGIN_HANDLED;
		case 1: tWeaponAdd(id);
		case 2: tWeaponReset(id);
		case 3: client_cmd(id, "messagemode tSetMoney");
		case 4: tOverViewWeapon(id, true);
		case 5: tOverViewWeapon(id, false);
		case 6: tReady(id);
		default: tContinue(id);
	}

	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public tOverViewWeapon(id, bool:IsMy)
{
	new Requester = IsUserInTrade(id);
	if(Requester == -1)
	{
		ColorChat(id, GREEN, "^4%s ^1A csere meg lett szakítva így nem folytathatód!", C_Prefix);
		return;
	}
	if(IsUserReady(id, Requester))
		return;
	
	new Str[121];
	if(IsMy)
		format(Str, charsmax(Str), "[%s] \r- \dCsere^n \yBehelyezett fegyvereid", Prefix);
	else
		format(Str, charsmax(Str), "[%s] \r- \dCsere^n \yFelajánlott fegyverek", Prefix);
	new menu = menu_create(Str, "tContinue_h");
	
	new so_Fegyverek = sizeof(Fegyverek);
	new bool:HaveWeapon = false;
	if(Requester == id)
	{
		if(IsMy) 
		{
			for(new i;i < so_Fegyverek; i++) 
			{
				if((Trades[Requester][RequesterItems][i]) > 0)
				{
					formatex(Str, charsmax(Str), "%s \r[\y%i \rDB]", Fegyverek[i][Name], (Trades[Requester][RequesterItems][i]));
					menu_additem(menu, Str, "0");
					HaveWeapon = true;
				}
			}
		}
		else 
		{
			for(new i;i < so_Fegyverek; i++) 
			{
				if((Trades[Requester][AccepterItems][i]) > 0)
				{
					formatex(Str, charsmax(Str), "%s \r[\y%i \rDB]", Fegyverek[i][Name], (Trades[Requester][AccepterItems][i]));
					menu_additem(menu, Str, "0");
					HaveWeapon = true;
				}
			}
		}
	}
	else
	{
		if(IsMy) 
		{
			for(new i;i < so_Fegyverek; i++) 
			{
				if((Trades[Requester][AccepterItems][i]) > 0)
				{
					formatex(Str, charsmax(Str), "%s \r[\y%i \rDB]", Fegyverek[i][Name], (Trades[Requester][AccepterItems][i]));
					menu_additem(menu, Str, "0");
					HaveWeapon = true;
				}
			}
		}
		else 
		{
			for(new i;i < so_Fegyverek; i++) 
			{
				if((Trades[Requester][RequesterItems][i]) > 0)
				{
					formatex(Str, charsmax(Str), "%s \r[\y%i \rDB]", Fegyverek[i][Name], (Trades[Requester][RequesterItems][i]));
					menu_additem(menu, Str, "0");
					HaveWeapon = true;
				}
			}
		}
	}
	if(HaveWeapon)
		menu_display(id, menu, 0);
	else
	{
		ColorChat(id, GREEN, "^4%s ^1Nem lett még behelyezve semmi!", C_Prefix);
		tContinue(id)
	}
}

public tWeaponAdd(id)
{
	new Requester = IsUserInTrade(id);
	if(Requester == -1)
	{
		ColorChat(id, GREEN, "^4%s ^1A csere meg lett szakítva így nem folytathatód!", C_Prefix);
		return;
	}
	if(IsUserReady(id, Requester))
		return;
	
	new Str[121], num[3];
	format(Str, charsmax(Str), "[%s] \r- \dCsere^n \yFegyver behelyezése", Prefix);
	new menu = menu_create(Str, "tWeaponAdd_h");
	
	new so_Fegyverek = sizeof(Fegyverek);
	new bool:HaveWeapon = false;
	if(Requester == id)
	{
		for(new i;i < so_Fegyverek; i++)
		{
			if((g_PlayerHWA[id][i] - Trades[Requester][RequesterItems][i]) > 0)
			{
				formatex(Str, charsmax(Str), "%s \r[\y%i \rDB]", Fegyverek[i][Name], (g_PlayerHWA[id][i] - Trades[Requester][RequesterItems][i]));
				num_to_str(i, num, 5);
				menu_additem(menu, Str, num);
				HaveWeapon = true;
			}
		}
	}
	else
	{
		for(new i;i < so_Fegyverek; i++)
		{
			if((g_PlayerHWA[id][i] - Trades[Requester][AccepterItems][i]) > 0)
			{
				formatex(Str, charsmax(Str), "%s \r[\y%i \rDB]", Fegyverek[i][Name], (g_PlayerHWA[id][i] - Trades[Requester][AccepterItems][i]));
				num_to_str(i, num, 5);
				menu_additem(menu, Str, num);
				HaveWeapon = true;
			}
		}
	}
	if(HaveWeapon)
		menu_display(id, menu, 0);
	else
	{
		ColorChat(id, GREEN, "^4%s ^1Nincs fegyver amit behelyezhetnél!", C_Prefix);
		tContinue(id)
	}
}

public tWeaponAdd_h(id, menu, item) {
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED
	}

	new data[9], szName[64]
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName, charsmax(szName), callback);
	new key = str_to_num(data);
	new Requester = IsUserInTrade(id);
	
	if(Requester == id)
		Trades[Requester][RequesterItems][key] += ((g_PlayerHWA[id][key] - Trades[Requester][RequesterItems][key]) > 0) ? 1 : 0;
	else
		Trades[Requester][AccepterItems][key] += ((g_PlayerHWA[id][key] - Trades[Requester][AccepterItems][key]) > 0) ? 1 : 0;

	menu_destroy(menu);
	tContinue(id);
	return PLUGIN_HANDLED;
}

public tWeaponReset(id)
{
	new Requester = IsUserInTrade(id);
	if(Requester == -1)
	{
		ColorChat(id, GREEN, "^4%s ^1A csere meg lett szakítva így nem folytathatód!", C_Prefix);
		return;
	}
	if(IsUserReady(id, Requester))
		return;
	
	if(Requester == id)
		Trades[Requester][RequesterItems][0] = EOS;
	else
		Trades[Requester][AccepterItems][0] = EOS;

	tContinue(id);
}

public tSetMoney(id)
{
	new Requester = IsUserInTrade(id);
	if(Requester == -1)
	{
		ColorChat(id, GREEN, "^4%s ^1A csere meg lett szakítva így nem folytathatód!", C_Prefix);
		return;
	}
	if(IsUserReady(id, Requester))
		return;
	new Arg[32];
	read_argv(1, Arg, charsmax(Arg));
	new Amount = str_to_num(Arg);
	if(Amount < 0)
	{
		ColorChat(id, GREEN, "^4%s ^1Nem írhatsz be negazív számot!", C_Prefix);
		tContinue(id);
		return;
	}
	if(Requester == id)
	{
		if(Amount <= g_adatok[Dollar][Requester])
			Trades[Requester][RequesterMoney] = Amount;
		else
			ColorChat(Requester, GREEN, "^4%s ^1Nincs ennyi pénzed!", C_Prefix);
	}
	else
	{
		new Accepter = Trades[Requester][AccepterID];
		if(Amount <= g_adatok[Dollar][Accepter])
			Trades[Requester][AccepterMoney] = Amount;
		else
			ColorChat(Accepter, GREEN, "^4%s ^1Nincs ennyi pénzed!", C_Prefix);
	}
	
	tContinue(id);
}

public tReady(id)
{
	new Requester = IsUserInTrade(id);
	if(Requester == -1)
	{
		ColorChat(id, GREEN, "^4%s ^1A csere meg lett szakítva így nem folytathatód!", C_Prefix);
		return;
	}
	if(Requester == id)
	{
		if(Trades[Requester][RequesterReady])
		{
			Trades[Requester][RequesterReady] = false
			Trades[Requester][AccepterReady] = false
			Trades[Requester][RequesterDeal] = false
		}
		else
			Trades[Requester][RequesterReady] = true
	}
	else
	{
		if(Trades[Requester][AccepterReady])
		{
			Trades[Requester][AccepterReady] = false
			Trades[Requester][RequesterReady] = false
			Trades[Requester][AccepterReady] = false
		}
		else
			Trades[Requester][AccepterReady] = true
	}
	if(Trades[Requester][AccepterReady] && Trades[Requester][RequesterReady])
	{
		ColorChat(Requester, GREEN, "^4%s ^1Írd be hogy ^3/fogad ^1hogy végbemenjen a csere! (Vissza vonni a menübe tudod)", C_Prefix);
		ColorChat(Trades[Requester][AccepterID], GREEN, "^4%s ^1Írd be hogy ^3/fogad ^1hogy végbemenjen a csere!", C_Prefix);
	}
	tContinue(id);
}

public cmdDeal(id)
{
	new Requester = IsUserInTrade(id);
	if(Requester == -1)
	{
		ColorChat(id, GREEN, "^4%s ^1A csere meg lett szakítva így nem folytathatód!", C_Prefix);
		return;
	}
	if(!Trades[Requester][AccepterReady] || !Trades[Requester][RequesterReady])
	{
		ColorChat(id, GREEN, "^4%s ^1Elöbb mind 2 félnek el kell fogadnia a cserét!", C_Prefix);
		return;
	}
	if(Requester == id)
		Trades[Requester][RequesterDeal] = true;
	else
		Trades[Requester][AccepterDeal] = true;
	
	if(Trades[Requester][RequesterDeal] && Trades[Requester][AccepterDeal])
		TradeDone(Requester, Trades[Requester][AccepterID]);
	else
		ColorChat(id, GREEN, "^4%s ^1A másik fél még nem írta be...", C_Prefix);
}

public TradeDone(Requester, Accepter)
{
	if(!is_user_connected(Requester) || !is_user_connected(Accepter))
	{
		if(is_user_connected(Requester))
			ColorChat(Requester, GREEN, "^4%s ^1A másik fél lecsatlakozott!", C_Prefix);

		if(is_user_connected(Accepter))
			ColorChat(Accepter, GREEN, "^4%s ^1A másik fél lecsatlakozott!", C_Prefix);
	}

	new so_Fegyverek = sizeof(Fegyverek);
	for(new i;i < so_Fegyverek; i++)//weapon | Requester -> Accepter
	{
		g_PlayerHWA[Accepter][i] += Trades[Requester][RequesterItems][i];
		g_PlayerHWA[Requester][i] -= Trades[Requester][RequesterItems][i];
	}
	for(new i;i < so_Fegyverek; i++)//weapon | Accepter -> Requester
	{
		g_PlayerHWA[Requester][i] += Trades[Requester][AccepterItems][i];
		g_PlayerHWA[Accepter][i] -= Trades[Requester][AccepterItems][i];
	}

	g_adatok[Dollar][Requester] += Trades[Requester][AccepterMoney];
	g_adatok[Dollar][Accepter] -= Trades[Requester][AccepterMoney];

	g_adatok[Dollar][Accepter] += Trades[Requester][RequesterMoney];
	g_adatok[Dollar][Requester] -= Trades[Requester][RequesterMoney];

	LogTrade(Requester, Accepter);
	SetTradesToDefault(Requester);
	ColorChat(Accepter, GREEN, "^4%s ^1A csere sikeresen végbement!", C_Prefix);
	ColorChat(Requester, GREEN, "^4%s ^1A csere sikeresen végbement!", C_Prefix);
}

new const LogFile[] = "trade.log";
public LogTrade(Requester, Accepter)
{
	new iLen;
	new so_Fegyverek = sizeof(Fegyverek);

	iLen = 0;
	new nRequester[32];
	get_user_name(Requester, nRequester, 31);
	new rOffer[1536];
	if(Trades[Requester][RequesterMoney] > 0)
		iLen += formatex(rOffer[iLen], 1536,"^tMoney:%i^n", Trades[Requester][RequesterMoney]);
	for(new i;i < so_Fegyverek; i++)
	{
		if(Trades[Requester][RequesterItems][i] > 0)
			iLen += formatex(rOffer[iLen], 1536,"^t%s [%i]^n",Fegyverek[i][Name], Trades[Requester][RequesterItems][i]);
	}

	iLen = 0;
	new nAccepter[32];
	get_user_name(Accepter, nAccepter, 31);
	new aOffer[1536];
	if(Trades[Requester][AccepterMoney] > 0)
		iLen += formatex(aOffer[iLen], 1536,"^tMoney:%i^n", Trades[Requester][AccepterMoney]);
	for(new i;i < so_Fegyverek; i++)
	{
		if(Trades[Requester][AccepterItems][i] > 0)
			iLen += formatex(aOffer[iLen], 1536,"^t%s [%i]^n",Fegyverek[i][Name], Trades[Requester][AccepterItems][i]);
	}

	log_to_file( LogFile, "^n-------- |CSERE KEZDETE| --------^n[REQUESTER]^nInGameName:^"%s^"^nUserName:^"%s^"^n{^n%s}^n^n[ACCEPTER]^nInGameName:^"%s^"^nUserName:^"%s^"^n{^n%s}^n-------- |CSERE VÉGE| --------", nRequester,g_UserName[Requester],rOffer,nAccepter,g_UserName[Accepter],aOffer);
}

public tQuit(id)
{
	new Requester = IsUserInTrade(id);
	if(Requester == id)
	{
		ColorChat(Requester, GREEN, "^4%s ^1A csere meg lett szakítva!", C_Prefix);
		ColorChat(Trades[Requester][AccepterID], GREEN, "^4%s ^1A csere meg lett szakítva a másik fél által!", C_Prefix);
	}
	else
	{
		ColorChat(Trades[Requester][AccepterID], GREEN, "^4%s ^1A csere meg lett szakítva!", C_Prefix);
		ColorChat(Requester, GREEN, "^4%s ^1A csere meg lett szakítva a másik fél által!", C_Prefix);
	}
	SetTradesToDefault(Requester);
}

public tAccept(id)
{
	new Str[121];
	format(Str, charsmax(Str), "[%s] \r- \dCsere elfogadás^n \ySzemély kiválasztása", Prefix);
	new menu = menu_create(Str, "tAccept_h");

	new p[32],n, String[2];
	get_players(p,n,"ch");
	static xid;
	new name[32];
	for(new i=0;i<n;i++)
	{
		xid = p[i];
		if(!IsAccepterForUser(xid, id))
			continue;

		num_to_str(xid, String, 2);
		get_user_name(xid, name, 31);
		menu_additem(menu, name, String);
	}
	menu_display(id, menu, 0);
}

public tAccept_h(id, menu, item) 
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED
	}
	new data[9], szName[64]
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName, charsmax(szName), callback);
	new acceptedfrom = str_to_num(data);

	{//Accept
		if(Trades[acceptedfrom][AccepterID] != id)
		{
			new name[33];
			get_user_name(acceptedfrom, name, 32);
			ColorChat(id, GREEN, "^4%s ^3%s már másnak ajánlott fel cserét. :(", C_Prefix, name);
			menu_destroy(menu);
			return PLUGIN_HANDLED;
		}
		Trades[acceptedfrom][Active] = true;
		
		new name[33];
		get_user_name(id, name, 32);
		ColorChat(acceptedfrom, GREEN, "^4%s ^3%s ^1Elfogatta a cserekereskedelmedet!", C_Prefix, name);
		get_user_name(acceptedfrom, name, 32);
		ColorChat(id, GREEN, "^4%s ^1Elfogattad ^3%s ^1cserekereskedelmét!", C_Prefix, name);
	}

	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public tRequest(id)
{
	new Str[121];
	format(Str, charsmax(Str), "[%s] \r- \dCsere Kérés^n \ySzemély kiválasztása", Prefix);
	new menu = menu_create(Str, "tRequest_h");

	new p[32],n, String[2];
	get_players(p,n,"ch");
	static xid;
	new name[32];
	for(new i=0;i<n;i++)
	{
		xid = p[i];
		if(!g_LoggedIn[xid] || IsUserInTrade(xid) != -1 || xid == id)
			continue;
		
		num_to_str(xid, String, 2);
		get_user_name(xid, name, 31);
		menu_additem(menu, name, String);
	}

	menu_display(id, menu, 0);
}

public tRequest_h(id, menu, item) 
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED
	}
	new data[9], szName[64]
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName, charsmax(szName), callback);
	new requested = str_to_num(data);

	{//request
		SetTradesToDefault(id);
		if(IsUserInTrade(requested) != -1)
		{
			ColorChat(id, GREEN, "^4%s ^1Sajnos ő már belépette egy cserébe. :c", C_Prefix);
			return PLUGIN_HANDLED
		}
		if(Trades[requested][AccepterID] == id)
		{
			Trades[requested][Active] = true;
			
			new name[33];
			get_user_name(id, name, 32);
			ColorChat(requested, GREEN, "^4%s ^3%s ^1Elfogatta a cserekereskedelmedet!", C_Prefix, name);
			get_user_name(requested, name, 32);
			ColorChat(id, GREEN, "^4%s ^1Elfogattad ^3%s ^1cserekereskedelmét!", C_Prefix, name);
		}
		else
		{
			Trades[id][AccepterID] = requested;
			new name[33];
			get_user_name(id, name, 32);
			ColorChat(requested, GREEN, "^4%s ^1Csere felkérést kaptál tőle: ^3%s", C_Prefix, name);
			get_user_name(requested, name, 32);
			ColorChat(id, GREEN, "^4%s ^1Csere felkérést küldtél neki: ^3%s", C_Prefix, name);
		}
	}

	menu_destroy(menu);
	return PLUGIN_HANDLED
}

public SetTradesToDefault(id)
{
	Trades[id][Active] = false;

	Trades[id][AccepterID] = 0;
	Trades[id][AccepterItems][0] = EOS;
	Trades[id][AccepterMoney] = 0;
	Trades[id][AccepterReady] = false;
	Trades[id][AccepterDeal] = false;

	Trades[id][RequesterItems][0] = EOS;
	Trades[id][RequesterMoney] = 0;
	Trades[id][RequesterReady] = false;
	Trades[id][RequesterDeal] = false;
}

public IsAccepterForUser(id, Accepter)
{
	if(Trades[id][AccepterID] == Accepter)
		return true;
	return false;
}

public IsUserInTrade(id)
{
	if(Trades[id][Active])
		return id;
	
	for(new i = 0; i < 33; i++)
	{
		if(Trades[i][AccepterID] == id && Trades[i][Active])
			return i;
	}

	return -1;
}

IsUserReady(id, req=-1)
{
	new Requester = (req == -1) ? IsUserInTrade(id) : req;
	if(Requester == id)
		return Trades[Requester][RequesterReady];
	return Trades[Requester][AccepterReady];
}
//Trade System by Kova
//-----TRADE SYSTEM END


public nezdmaravipet(id)
{
	if(g_playerData[MPrefi][id] == 22)
	{
		if(g_VipTime[id] >= 10)
		{
			g_playerData[MPrefi][id] = 22;
			Update(id, 1);
		}
		else if(g_VipTime[id] <= 10)
		{
			g_playerData[MPrefi][id] = 0;
			g_VipTime[id] = 0;
			Update(id, 0);
		}
	}
}
public Quest(id)
{
	new HeadShot = read_data(3);
	new name[32]; get_user_name(id, name, charsmax(name));


	if(g_AdatV2[g_QuestHead][id] == 1 && (HeadShot))
	{
		if(g_AdatV2[g_QuestWeapon][id] == 9) g_QuestKills[1][id]++;
		else if(g_AdatV2[g_QuestWeapon][id] == 8 && get_user_weapon(id) == CSW_KNIFE) g_QuestKills[1][id]++;
		else if(g_AdatV2[g_QuestWeapon][id] == 7 && get_user_weapon(id) == CSW_DEAGLE) g_QuestKills[1][id]++;
		else if(g_AdatV2[g_QuestWeapon][id] == 6 && get_user_weapon(id) == CSW_M4A1) g_QuestKills[1][id]++;
		else if(g_AdatV2[g_QuestWeapon][id] == 5 && get_user_weapon(id) == CSW_AK47) g_QuestKills[1][id]++;
		else if(g_AdatV2[g_QuestWeapon][id] == 4 && get_user_weapon(id) == CSW_AWP) g_QuestKills[1][id]++;
		else if(g_AdatV2[g_QuestWeapon][id] == 3 && get_user_weapon(id) == CSW_DEAGLE) g_QuestKills[1][id]++;
		else if(g_AdatV2[g_QuestWeapon][id] == 2 && get_user_weapon(id) == CSW_AWP) g_QuestKills[1][id]++;
		else if(g_AdatV2[g_QuestWeapon][id] == 1 && get_user_weapon(id) == CSW_M4A1) g_QuestKills[1][id]++;
		else if(g_AdatV2[g_QuestWeapon][id] == 0 && get_user_weapon(id) == CSW_AK47) g_QuestKills[1][id]++;
	}
	if(g_AdatV2[g_QuestHead][id] == 0)
	{
		if(g_AdatV2[g_QuestWeapon][id] == 9) g_QuestKills[1][id]++;
		else if(g_AdatV2[g_QuestWeapon][id] == 8 && get_user_weapon(id) == CSW_KNIFE) g_QuestKills[1][id]++;
		else if(g_AdatV2[g_QuestWeapon][id] == 7 && get_user_weapon(id) == CSW_DEAGLE) g_QuestKills[1][id]++;
		else if(g_AdatV2[g_QuestWeapon][id] == 6 && get_user_weapon(id) == CSW_M4A1) g_QuestKills[1][id]++;
		else if(g_AdatV2[g_QuestWeapon][id] == 5 && get_user_weapon(id) == CSW_AK47) g_QuestKills[1][id]++;
		else if(g_AdatV2[g_QuestWeapon][id] == 4 && get_user_weapon(id) == CSW_AWP) g_QuestKills[1][id]++;
		else if(g_AdatV2[g_QuestWeapon][id] == 3 && get_user_weapon(id) == CSW_DEAGLE) g_QuestKills[1][id]++;
		else if(g_AdatV2[g_QuestWeapon][id] == 2 && get_user_weapon(id) == CSW_AWP) g_QuestKills[1][id]++;
		else if(g_AdatV2[g_QuestWeapon][id] == 1 && get_user_weapon(id) == CSW_M4A1) g_QuestKills[1][id]++;
		else if(g_AdatV2[g_QuestWeapon][id] == 0 && get_user_weapon(id) == CSW_AK47) g_QuestKills[1][id]++;
	}

	if(g_QuestKills[1][id] >= g_QuestKills[0][id])
	{
		g_playerData[SMS][id] += g_Jutalom[2][id];
		g_QuestKills[1][id] = 0;
		g_AdatV2[g_QuestWeapon][id] = 0;
		g_AdatV2[g_QuestMVP][id]++;
		g_AdatV2[g_Quest][id] = 0;
		ColorChat(id, GREEN, "%s ^1A küldetésre kapott jutalmakat megkaptad.", C_Prefix); 
		ColorChat(0, GREEN, "[K]ÁRPÁTI[A] ^3%s^1 befejezte a kiszabott küldetéseket. A jutalmakat megkapta", name);
	}
}

public fiokinfom(id)
{

	new szText[512];
	new cim[121];

	new iMasodperc, iPerc, iOra;
	iMasodperc = Masodpercek[id] + get_user_time(id);
	iPerc = iMasodperc / 60;
	iOra = iPerc / 60;
	iMasodperc = iMasodperc - iPerc * 60;
	iPerc = iPerc - iOra * 60;

	format(cim, charsmax(cim), "\d|K|ÁRPÁTI|A|~ \yFiók Információ ");
	new menu = menu_create(cim, "SMS_Fomenu_h" );


	formatex(szText, charsmax(szText), "\dEXP:\y %3.2f%", Player[id][Euro])
	menu_additem(menu, szText, "0", 0);


	formatex(szText, charsmax(szText), "\dRang\y: %s", Rangok[g_playerData[Rang][id]][Szint])
	menu_additem(menu, szText, "0", 0);

	formatex(szText, charsmax(szText), "\dJogosultság:\y %s", MutasdPrefixet[g_playerData[MPrefi][id]][rangokjogok])
	menu_additem(menu, szText, "0", 0);

	formatex(szText, charsmax(szText), "\dPrefix:\y %s", prefiszem[id])
	menu_additem(menu, szText, "0", 0);


	formatex(szText, charsmax(szText), "\dJáték időd:\y %d Óra %d Perc %d Másodperc", iOra, iPerc, iMasodperc)
	menu_additem(menu, szText, "0", 0);

	menu_display(id, menu, 0);
}

public weaponSearch(id)
{
	if(!g_UseWeapon[id]) 
		openGunMenu(id)
	else 
		ColorChat(id, GREEN, "%s ^1Te már válaszotttál fegyvert", C_Prefix);
}

public openGunMenu(id)
{
	if(FegyverMenuTiltas)
		return PLUGIN_HANDLED;
	
	
	static menu[512],len;
	len = 0;

	len = formatex(menu[len], charsmax(menu) - len, "%s^n \yFegyvermenü^n^n", Prefix);
	

	

	if(g_adatok[Osszes_kartya][id] == 0)
	len += formatex(menu[len], charsmax(menu) - len, "\r[1] \y»\w AK47^n");
	else
	 len += formatex(menu[len], charsmax(menu) - len, "\r[1] \y»\w %s %s^n", Fegyverek[Selectedgun[id][AK47]][Name],	Fegyverneve[Fegyverek[Selectedgun[id][AK47]][g_WeapID]][id]);


	if(g_adatok[Osszes_kartya][id] == 0)
	len += formatex(menu[len], charsmax(menu) - len, "\r[2] \y»\w M4A1^n");
	else
	len += formatex(menu[len], charsmax(menu) - len, "\r[2] \y»\w %s %s^n", Fegyverek[Selectedgun[id][M4A1]][Name],	Fegyverneve[Fegyverek[Selectedgun[id][M4A1]][g_WeapID]][id]);


	if(g_adatok[Osszes_kartya][id] == 0)
	len += formatex(menu[len], charsmax(menu) - len, "\r[3] \y»\w AWP^n");
	else
		len += formatex(menu[len], charsmax(menu) - len, "\r[3] \y»\w %s %s^n", Fegyverek[Selectedgun[id][AWP]][Name],	Fegyverneve[Fegyverek[Selectedgun[id][AWP]][g_WeapID]][id]);


	

	len += formatex(menu[len], charsmax(menu) - len, "\r[4] \y»\w GALIL^n");

	len += formatex(menu[len], charsmax(menu) - len, "\r[5] \y»\w FAMAS^n");

	len += formatex(menu[len], charsmax(menu) - len, "\r[6] \y»\w MP5^n");

	len += formatex(menu[len], charsmax(menu) - len, "\r[7] \y»\w SCOUT^n");

	len += formatex(menu[len], charsmax(menu) - len, "\r[8] \y»\w M3^n");

	len += formatex(menu[len], charsmax(menu) - len, "\r[9] \y»\w P90^n");
	
	len += formatex(menu[len], charsmax(menu) - len, "^n^nTudtad?^n");
	len += formatex(menu[len], charsmax(menu) - len, "\r*\dAWP-t csapatonként 3 ember használhatja^n");
	len += formatex(menu[len], charsmax(menu) - len, "\r*\dAWP 3v3 játékostól használható!^n");

	new keys = MENU_KEY_0|MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6|MENU_KEY_7|MENU_KEY_8|MENU_KEY_9;
	show_menu(id, keys, menu, -1, "openGunMenu");
	return PLUGIN_HANDLED;	
}
stock IsFvF()
{
	new Players[32], iNum;
	
	new awpkorlatom = get_pcvar_num(awpkoralt);

	new any:m_Team;
	new t_num = 0;
	new ct_num = 0;
	get_players(Players, iNum, "ch");
	new Player;
	for (new i=0; i<iNum; i++)
	{
		Player = Players[i];
		m_Team = cs_get_user_team(Player);
		switch(m_Team)
		{
			case CS_TEAM_CT:
				ct_num++;
			case CS_TEAM_T:
				t_num++;
		}
	}
	if(t_num >= awpkorlatom && ct_num >= awpkorlatom)
		return true;
	
	return false;
}

public h_openGunMenu(id, key)
{

	switch(key)
	{
		case 0:
		{
			g_UseWeapon[id] = true;

			give_item(id, "weapon_ak47");
			cs_set_user_bpammo(id,CSW_AK47,190);
			give_item(id, "weapon_deagle");
			cs_set_user_bpammo(id,CSW_DEAGLE,160);
			give_item(id, "weapon_knife");
			give_item(id, "weapon_hegrenade");
			give_item(id, "weapon_flashbang");
			
			if(cs_get_user_team(id) == CS_TEAM_CT)
				give_item(id, "item_thighpack");
		}
		case 1:
		{
			g_UseWeapon[id] = true;

			give_item(id, "weapon_m4a1");
			cs_set_user_bpammo(id,CSW_M4A1,190);
			give_item(id, "weapon_deagle");
			cs_set_user_bpammo(id,CSW_DEAGLE,160);
			give_item(id, "weapon_knife");
			give_item(id, "weapon_hegrenade");
			give_item(id, "weapon_flashbang");

			if(cs_get_user_team(id) == CS_TEAM_CT)
				give_item(id, "item_thighpack");
		}
		case 2:
		{
			new CsTeams:_TEAM = cs_get_user_team(id);
			new bool:CanAddAWP = (_TEAM == CS_TEAM_T && g_Awps[Te] < 3 ) || (_TEAM == CS_TEAM_CT && g_Awps[Ct] < 3 );
			if(CanAddAWP && IsFvF())
			{
				if(_TEAM == CS_TEAM_T)
					g_Awps[Te]++;
				else
					g_Awps[Ct]++;
				
				g_UseWeapon[id] = true;

				give_item(id, "weapon_awp");
				cs_set_user_bpammo(id,CSW_AWP,160);
				cs_set_user_money(id, 0);
				give_item(id, "weapon_knife");
				give_item(id, "weapon_hegrenade");
				give_item(id, "weapon_flashbang");
				give_item(id, "weapon_deagle");
				cs_set_user_bpammo(id,CSW_DEAGLE,160);
			
				if(cs_get_user_team(id) == CS_TEAM_CT)
					give_item(id, "item_thighpack");
			}
			else
			{
				if(CanAddAWP)
				{
					ColorChat(id, GREEN, "^3[K]ÁRPÁTI[A]	FUN»^1 Csak^3 3v3^1-tól van ^3AWP fegyver!");
					openGunMenu(id);
				}
				else
				{
					ColorChat(id, GREEN, "^3[K]ÁRPÁTI[A]	FUN»^1 Nincs lehetőség több ^3AWP^1 vásárlására a csapatodban");
					openGunMenu(id);
				}
			}
		}
		case 3:
		{
			g_UseWeapon[id] = true;

			give_item(id, "weapon_galil");
			cs_set_user_bpammo(id,CSW_GALIL,190);
			give_item(id, "weapon_deagle");
			cs_set_user_bpammo(id,CSW_DEAGLE,160);
			give_item(id, "weapon_knife");
			give_item(id, "weapon_hegrenade");
			give_item(id, "weapon_flashbang");
			
			if(cs_get_user_team(id) == CS_TEAM_CT)
				give_item(id, "item_thighpack");
		}
		case 4:
		{
			g_UseWeapon[id] = true;
			give_item(id, "weapon_famas");
			cs_set_user_bpammo(id,CSW_FAMAS,150);
			give_item(id, "weapon_deagle");
			cs_set_user_bpammo(id,CSW_DEAGLE,160);
			give_item(id, "weapon_knife");
			give_item(id, "weapon_hegrenade");
			give_item(id, "weapon_flashbang");
			
			if(cs_get_user_team(id) == CS_TEAM_CT)
				give_item(id, "item_thighpack");
		}
		case 5:
		{
			g_UseWeapon[id] = true;
			give_item(id, "weapon_mp5navy");
			cs_set_user_bpammo(id,CSW_MP5NAVY,190);
			give_item(id, "weapon_deagle");
			cs_set_user_bpammo(id,CSW_DEAGLE,160);
			give_item(id, "weapon_knife");
			give_item(id, "weapon_hegrenade");
			give_item(id, "weapon_flashbang");
			
			if(cs_get_user_team(id) == CS_TEAM_CT)
				give_item(id, "item_thighpack");
		}
		case 6:
		{
			g_UseWeapon[id] = true;
			give_item(id, "weapon_scout");
			cs_set_user_bpammo(id,CSW_SCOUT,130);
			give_item(id, "weapon_deagle");
			cs_set_user_bpammo(id,CSW_DEAGLE,160);
			give_item(id, "weapon_knife");
			give_item(id, "weapon_hegrenade");
			give_item(id, "weapon_flashbang");
			
			if(cs_get_user_team(id) == CS_TEAM_CT)
				give_item(id, "item_thighpack");
		}
		case 7:
		{
			g_UseWeapon[id] = true;
			give_item(id, "weapon_m3");
			cs_set_user_bpammo(id,CSW_M3,136);
			give_item(id, "weapon_deagle");
			cs_set_user_bpammo(id,CSW_DEAGLE,160);
			give_item(id, "weapon_knife");
			give_item(id, "weapon_hegrenade");
			give_item(id, "weapon_flashbang");
			
			if(cs_get_user_team(id) == CS_TEAM_CT)
				give_item(id, "item_thighpack");
		}
		case 8:
		{
			g_UseWeapon[id] = true;
			give_item(id, "weapon_p90");
			cs_set_user_bpammo(id,CSW_P90,190);
			give_item(id, "weapon_deagle");
			cs_set_user_bpammo(id,CSW_DEAGLE,160);
			give_item(id, "weapon_knife");
			give_item(id, "weapon_hegrenade");
			give_item(id, "weapon_flashbang");
			
			if(cs_get_user_team(id) == CS_TEAM_CT)
				give_item(id, "item_thighpack");
		}
	}
	return PLUGIN_HANDLED;
}

public openPistolMenu(id)
{
	new String[121];
	formatex(String, charsmax(String), "%s \r- \dMásodlagos Fegyver", PR);
	new menu = menu_create(String, "h_openPistolMenu");

	
	format(String,charsmax(String),"\d[\wGLOCK18\d]");
	menu_additem(menu,String,"3");

	format(String,charsmax(String),"\d[\wUSP\d]");
	menu_additem(menu,String,"2");

	format(String,charsmax(String),"\d[\wDEAGLE\d]");
	menu_additem(menu,String,"1");

	format(String,charsmax(String),"\d[\wFIVESEVEN\d]");
	menu_additem(menu,String,"4");

	menu_display(id, menu, 0);

	return PLUGIN_HANDLED;
}

public h_openPistolMenu(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}

	new data[9], szName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
	new key = str_to_num(data);

	switch(key)
	{
		case 1:
		{
			give_item(id, "weapon_deagle");
			cs_set_user_bpammo(id,CSW_DEAGLE,160);
		}
		case 2:
		{
			give_item(id, "weapon_usp");
			cs_set_user_bpammo(id,CSW_USP,160);
		}
		case 3:
		{
			give_item(id, "weapon_glock18");
			cs_set_user_bpammo(id,CSW_GLOCK18,160);
		}
		case 4:
		{
			give_item(id, "weapon_fiveseven");
			cs_set_user_bpammo(id,CSW_FIVESEVEN,160);
		}
	}
	return PLUGIN_HANDLED;
}

public infoklekerdezes(id)
{
		new hour, minute, second;
		time(hour, minute, second);

		if(Mod == 3 )
		{
			Mod = 3;
			ColorChat(id, GREEN, "^3Információ- ^1Jelenleg ^4DOBOZ EVENT ^1 van.");
		}
		if(18 <= hour && 10 > hour)
		{
			Mod = 1;
			ColorChat(id, GREEN, "^3Információ- ^1Jelenleg ^4Prémium Event ^1 van ^4(18:00-10:00).");
		}
		if(Mod == 2)
		{
			Mod = 2;
			ColorChat(id, GREEN, "^3Információ- ^1Jelenleg ^4Drop Event ^1 van.");
		}
		if(11 <= hour && 16 > hour)
		{
			Mod = 3;
			ColorChat(id, GREEN, "^3Információ- ^1Jelenleg ^4DOBOZ EVENT ^1 van.");
		}

		return PLUGIN_HANDLED;
}

public Idoprobaadd(id)
{
	ColorChat(id, GREEN, "^3Információ- ^1Sikeresen elindítottad a^4 Drop Eventet");
	Mod = 2;
}

public Idoprobaadd2(id)
{
	ColorChat(id, GREEN, "^3Információ- ^1Sikeresen elindítottad a^4 DOBOZ Eventet");
	Mod = 3;
}

public Idoprobaadd3(id)
{
	ColorChat(id, GREEN, "^3Információ- ^1Sikeresen elindítottad a^4 Prémium Eventet");
	Mod = 4;
}

public zene_kivalasztas(id)
{
	new String[121];
	format(String, charsmax(String), "%s\dZene készlet | \yPontok:\w %i", Prefix,	g_AdatV2[ZenePont][id]);	
	new menu = menu_create(String, "kivalasztott_beallitasa");
			
	for(new i;i < sizeof(AllMusic); i++)
	{
		new a[6]; num_to_str(i, a, 5);
		
		if(g_AdatV2[patrik_zeneji][id] == i)
			formatex(String, charsmax(String), "\y%s \d[\wBEÁLLÍTVA\d]", AllMusic[i][Nevei]);		
		else if(AllMusic[i][zenepontok] <= g_AdatV2[ZenePont][id])
			formatex(String, charsmax(String), "\w%s \d[\rMEGSZEREZVE\d]", AllMusic[i][Nevei]);
		else if(AllMusic[i][zenepontok] > g_AdatV2[ZenePont][id])
			formatex(String, charsmax(String), "\d%s \y[\d%i\w/\r%i", AllMusic[i][Nevei],	g_AdatV2[ZenePont][id],	AllMusic[i][zenepontok]);	
		menu_additem(menu, String, a); 
	}
	
	menu_setprop(menu, MPROP_BACKNAME, "Vissza"); 
	menu_setprop(menu, MPROP_NEXTNAME, "Tovább");
	menu_setprop(menu, MPROP_EXITNAME, "Kilépés");

	menu_display(id, menu, 0);
}

public kivalasztott_beallitasa(id, menu, item)
{
	if( item == MENU_EXIT )
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	new data[9], szName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
	new key = str_to_num(data);

	if(AllMusic[key][zenepontok] <= g_AdatV2[ZenePont][id]) 
	{
		g_AdatV2[patrik_zeneji][id] = key;
		ColorChat(id, GREEN, "^3[K]ÁRPÁTI[A]	FUN»	FUN» ^1Sikeres beállítás: ^3%s", AllMusic[g_AdatV2[patrik_zeneji][id]][Nevei]);
	}
	else
		ColorChat(id, GREEN, "^3[K]ÁRPÁTI[A]	FUN»	FUN» ^1Sajnálom, nincs elegendő ^3Pontod^3!");

	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public RoundEnds(id)
{
	new players[32], num
	get_players(players, num);
	SortCustom1D(players, num, "SortMVPToPlayer")

	new adjrandom_pontot = random_num(1, 5);
	new adjrandom_zenet = random_num(1, 12);

	TopMvp = players[0]

	new mvpName[32]
	get_user_name(TopMvp, mvpName, charsmax(mvpName))

	
	if(g_AdatV2[patrik_zeneji][TopMvp] == 0)
	{
		ColorChat(0, GREEN, "^4[K]ÁRPÁTI[A]^3» ^1Kör legjobb játékosa: ^3%s	^1Zene:^3 Random Zene", mvpName)
		new temp[128];
		formatex(temp, 127, "mp3 play %s", AllMusic[adjrandom_zenet][mp3ak]);
		client_cmd(0, temp);
		gSzamolas += 1;
		
	}
	if(g_AdatV2[patrik_zeneji][TopMvp] >= 1)
	{
		ColorChat(0, GREEN, "^4[K]ÁRPÁTI[A]^3» ^1Kör legjobb játékosa: ^3%s	^1Zene:^3 %s ^1szól!", mvpName, AllMusic[g_AdatV2[patrik_zeneji][TopMvp]][Nevei])
		g_AdatV2[ZenePont][TopMvp] += adjrandom_pontot;
		new temp[128];
		formatex(temp, 127, "mp3 play %s", AllMusic[g_AdatV2[patrik_zeneji][TopMvp]][mp3ak]);
		client_cmd(0, temp);
		gSzamolas += 1;

		}
}
public SortMVPToPlayer(id1, id2)
{
	if(g_adatok[g_MVPoints][id1] > g_adatok[g_MVPoints][id2]) 
		return -1;
	else if(g_adatok[g_MVPoints][id1] < g_adatok[g_MVPoints][id2])
		return 1;
 
	return 0;
}

 
public EVENT_RoundStart()
{
	new players[32], num, tempid;
	get_players(players, num, "c");
 
	for(new i = 0; i < num; i++) {
		tempid = players[i]
		remove_task(tempid);
	}
 
	RemoveEntities(szGiftClassname);
}
 
public EVENT_DeathMsg()
{
	if(Mod == 3){	
	new iKiller = read_data(1);	
	new iVictim = read_data(2);
 
	if(!IS_PLAYER(iVictim)) return;
 
	remove_task(iVictim);
 
	if(iVictim == iKiller) return;
 
	new Float:flOrigin[3];
	pev(iVictim, pev_origin, flOrigin);
 
	flOrigin[2] += -34.0;
 
	new Float:flAngles[3];
	pev(iVictim, pev_angles, flAngles);
 
	new iEntity = engfunc(EngFunc_CreateNamedEntity, gInfoTarget);
 
	if(!pev_valid(iEntity)) return;
 
	set_pev(iEntity, pev_classname, szGiftClassname);
	set_pev(iEntity, pev_angles, flAngles);
 
	engfunc(EngFunc_SetOrigin, iEntity, flOrigin);
	engfunc(EngFunc_SetModel, iEntity, gGiftModels[random_num(0, 1)]);
 
	ExecuteHam(Ham_Spawn, iEntity);
 
	set_pev(iEntity, pev_solid, SOLID_BBOX);
	set_pev(iEntity, pev_movetype, MOVETYPE_NONE);
	set_pev(iEntity, pev_nextthink, get_gametime() + 2.0);
 
	engfunc(EngFunc_SetSize, iEntity, Float:{ -23.160000, -13.660000, -0.050000	}, Float:{ 11.470000, 12.780000, 6.720000 });
	engfunc(EngFunc_DropToFloor, iEntity);
 
	return;
}
}
 
public forward_GiftThink(iEntity) {
	if(pev_valid(iEntity)) {
		set_pev(iEntity, pev_nextthink, get_gametime() + 2.0);
	}
}
 
public forward_TouchGift(iEntity, id) {
	if(!pev_valid(iEntity) || !is_user_alive(id)) return PLUGIN_HANDLED;
 
	
	switch(random_num(1, 4)) 
	{
	case 1: 
		{
		new prempont = random_num(1, 10)	
		g_playerData[SMS][id] += prempont;			
		ColorChat(id, GREEN, "^3[^1Doboz Event^3] ^1Találtál egy ^4 %d Prémium Pontot", prempont);
		}

	case 2: 
		{
		new iBonusHealth = random_num(10, 30)	;
		set_user_health(id, get_user_health(id) + iBonusHealth);
		ColorChat(id, GREEN, "^3[^1Doboz Event^3] ^1Találtál egy ^4+ %d ÉLETET", iBonusHealth);
		}

	case 3: 
		{	
		ColorChat(id, GREEN, "^3[^1Doboz Event^3] ^1HOOPSZ :c ^4EBBEN NEM VOLT ^3SEMMMI! " );
		}

	case 4: 
		{	
		talalas5(id);
		}
	}	

engfunc(EngFunc_RemoveEntity, iEntity);

return PLUGIN_CONTINUE;
}	
 
RemoveEntities(const szClassname[]) 
{
	new iEntity = FM_NULLENT;
 
	while((iEntity = engfunc(EngFunc_FindEntityByString, FM_NULLENT, "classname", szClassname))) {
		engfunc(EngFunc_RemoveEntity, iEntity);
	}
}

public nevcedRaktar(id)
{
	static menu[512],len;
	len = 0;

	len = formatex(menu[len], charsmax(menu) - len, "%s^nFegyver Névcédula beállítás^n^n", Prefix);
	
	len += formatex(menu[len], charsmax(menu) - len, "\r[1] \y»\w AWP^n");
	len += formatex(menu[len], charsmax(menu) - len, "\r[2] \y»\w AK47^n");
	len += formatex(menu[len], charsmax(menu) - len, "\r[3] \y»\w M4A1^n");
	len += formatex(menu[len], charsmax(menu) - len, "\r[4] \y»\w DEAGLE^n");
	len += formatex(menu[len], charsmax(menu) - len, "\r[5] \y»\w KNIFE^n");

	new keys = MENU_KEY_0|MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6|MENU_KEY_7|MENU_KEY_8|MENU_KEY_9;
	show_menu(id, keys, menu, -1, "nevcedRaktar");
	return PLUGIN_HANDLED;	
}	
public nevcvalasz_skinek(id, key)
{
	switch(key) 
	{
		case 0: Menu_nevcedulas3(id);
		case 1: Menu_nevcedulas2(id);
		case 2: Menu_nevcedulas1(id);
		case 3: Menu_nevcedulas4(id);
		case 4: Menu_nevcedulas5(id);
	}
	return PLUGIN_HANDLED;
}
public Menu_nevcedulas1(id)
{
	new String[121], Nev[32], szMenu[121];
	get_user_name(id, Nev, 31);
	formatex(String, charsmax(String), "[%s] \r- \dNévcédula", Prefix);
	new menu = menu_create(String, "m4Menu_nevcedulas_h");


	if(Beirtcedula[id] == false) 
	{
		formatex(szMenu, charsmax(szMenu), "Névcédula:\d nincs megadva^n-------------------^n")
		menu_additem(menu, szMenu, "2", 0);
	}
	if(Fegyverek[Selectedgun[id][M4A1]][g_WeapID] && Beirtcedula[id] == true) 
	{
		formatex(szMenu, charsmax(szMenu), "Névcédula:\d %s^n-------------------^n", Fegyverneve[Fegyverek[Selectedgun[id][M4A1]][g_WeapID]][id])
		menu_additem(menu, szMenu, "2", 0);
	}
	
	
	if(Fegyverek[Selectedgun[id][M4A1]][g_WeapID])
	{
		formatex(szMenu, charsmax(szMenu), "\wFegyver: \y%s^n-------------------^n", Fegyverek[Fegyverek[Selectedgun[id][M4A1]][g_WeapID]][Name]);
		menu_additem(menu, szMenu, "4", 0);
	}
	else if(fegyverkivalasztas[id] == false) 
	{
		formatex(szMenu, charsmax(szMenu), "\wFegyver:\d nincs megadva^n-------------------^n");
		menu_additem(menu, szMenu, "4", 0);
	}
	

	formatex(String, charsmax(String), "\yFELSZERELÉS!");
	menu_additem(menu, String, "3",0);
	

	

	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}
public Menu_nevcedulas2(id)
{
	new String[121], Nev[32], szMenu[121];
	get_user_name(id, Nev, 31);
	formatex(String, charsmax(String), "[%s] \r- \dNévcédula", Prefix);
	new menu = menu_create(String, "ak47Menu_nevcedulas_h");


	if(Beirtcedula[id] == false) 
	{
		formatex(szMenu, charsmax(szMenu), "Névcédula:\d nincs megadva^n-------------------^n")
		menu_additem(menu, szMenu, "2", 0);
	}
	if(Fegyverek[Selectedgun[id][AK47]][g_WeapID] && Beirtcedula[id] == true) 
	{
		formatex(szMenu, charsmax(szMenu), "Névcédula:\d %s^n-------------------^n", Fegyverneve[Fegyverek[Selectedgun[id][AK47]][g_WeapID]][id])
		menu_additem(menu, szMenu, "2", 0);
	}
	
	
	if(Fegyverek[Selectedgun[id][AK47]][g_WeapID])
	{
		formatex(szMenu, charsmax(szMenu), "\wFegyver: \y%s^n-------------------^n", Fegyverek[Fegyverek[Selectedgun[id][AK47]][g_WeapID]][Name]);
		menu_additem(menu, szMenu, "4", 0);
	}
	else if(fegyverkivalasztas[id] == false) 
	{
		formatex(szMenu, charsmax(szMenu), "\wFegyver:\d nincs megadva^n-------------------^n");
		menu_additem(menu, szMenu, "4", 0);
	}
	
	


	formatex(String, charsmax(String), "\yFELSZERELÉS!");
	menu_additem(menu, String, "3",0);
	

	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}
public Menu_nevcedulas3(id)
{
	new String[121], Nev[32], szMenu[121];
	get_user_name(id, Nev, 31);
	formatex(String, charsmax(String), "[%s] \r- \dNévcédula", Prefix);
	new menu = menu_create(String, "awpMenu_nevcedulas_h");


	if(Beirtcedula[id] == false) 
	{
		formatex(szMenu, charsmax(szMenu), "Névcédula:\d nincs megadva^n-------------------^n")
		menu_additem(menu, szMenu, "2", 0);
	}
	if(Fegyverek[Selectedgun[id][AWP]][g_WeapID] && Beirtcedula[id] == true) 
	{
		formatex(szMenu, charsmax(szMenu), "Névcédula:\d %s^n-------------------^n", Fegyverneve[Fegyverek[Selectedgun[id][AWP]][g_WeapID]][id])
		menu_additem(menu, szMenu, "2", 0);
	}
	
	if(Fegyverek[Selectedgun[id][AWP]][g_WeapID])
	{
		formatex(szMenu, charsmax(szMenu), "\wFegyver: \y%s^n-------------------^n", Fegyverek[Fegyverek[Selectedgun[id][AWP]][g_WeapID]][Name]);
		menu_additem(menu, szMenu, "4", 0);
	}
	else if(fegyverkivalasztas[id] == false) 
	{
		formatex(szMenu, charsmax(szMenu), "\wFegyver:\d nincs megadva^n-------------------^n");
		menu_additem(menu, szMenu, "4", 0);
	}
	
	


	
	
	formatex(String, charsmax(String), "\yFELSZERELÉS!");
	menu_additem(menu, String, "3",0);
	

	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}
public Menu_nevcedulas4(id)
{
	new String[121], Nev[32], szMenu[121];
	get_user_name(id, Nev, 31);
	formatex(String, charsmax(String), "[%s] \r- \dNévcédula", Prefix);
	new menu = menu_create(String, "deagMenu_nevcedulas_h");


	if(Beirtcedula[id] == false) 
	{
		formatex(szMenu, charsmax(szMenu), "Névcédula:\d nincs megadva^n-------------------^n")
		menu_additem(menu, szMenu, "2", 0);
	}
	if(Fegyverek[Selectedgun[id][DEAGLE]][g_WeapID] && Beirtcedula[id] == true) 
	{
		formatex(szMenu, charsmax(szMenu), "Névcédula:\d %s^n-------------------^n", Fegyverneve[Fegyverek[Selectedgun[id][DEAGLE]][g_WeapID]][id])
		menu_additem(menu, szMenu, "2", 0);
	}
	
	
		
	if(Fegyverek[Selectedgun[id][DEAGLE]][g_WeapID])
	{
		formatex(szMenu, charsmax(szMenu), "\wFegyver: \y%s^n-------------------^n", Fegyverek[Fegyverek[Selectedgun[id][DEAGLE]][g_WeapID]][Name]);
		menu_additem(menu, szMenu, "4", 0);
	}
	else if(fegyverkivalasztas[id] == false) 
	{
		formatex(szMenu, charsmax(szMenu), "\wFegyver:\d nincs megadva^n-------------------^n");
		menu_additem(menu, szMenu, "4", 0);
	}
	
	


	

	formatex(String, charsmax(String), "\yFELSZERELÉS!");
	menu_additem(menu, String, "3",0);
	

	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}
public Menu_nevcedulas5(id)
{
	new String[121], Nev[32], szMenu[121];
	get_user_name(id, Nev, 31);
	formatex(String, charsmax(String), "[%s] \r- \dNévcédula", Prefix);
	new menu = menu_create(String, "kesMenu_nevcedulas_h");


	if(Beirtcedula[id] == false) 
	{
		formatex(szMenu, charsmax(szMenu), "Névcédula:\d nincs megadva^n-------------------^n")
		menu_additem(menu, szMenu, "2", 0);
	}
	if(Fegyverek[Selectedgun[id][KNIFE]][g_WeapID] && Beirtcedula[id] == true) 
	{
		formatex(szMenu, charsmax(szMenu), "Névcédula:\d %s^n-------------------^n", Fegyverneve[Fegyverek[Selectedgun[id][KNIFE]][g_WeapID]][id]) 
		menu_additem(menu, szMenu, "2", 0);
	}
	
	
	if(Fegyverek[Selectedgun[id][KNIFE]][g_WeapID])
	{
		formatex(szMenu, charsmax(szMenu), "\wFegyver: \y%s^n-------------------^n", Fegyverek[Fegyverek[Selectedgun[id][KNIFE]][g_WeapID]][Name]);
		menu_additem(menu, szMenu, "4", 0);
	}
	else if(fegyverkivalasztas[id] == false) 
	{
		formatex(szMenu, charsmax(szMenu), "\wFegyver:\d nincs megadva^n-------------------^n");
		menu_additem(menu, szMenu, "4", 0);
	}
	
	


	formatex(String, charsmax(String), "\yFELSZERELÉS!");
	menu_additem(menu, String, "3",0);
	

	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}
public ak47Menu_nevcedulas_h(id, menu, item)
{
if(item == MENU_EXIT)
{
menu_destroy(menu);
return PLUGIN_HANDLED;
}

new data[9], szName[64];
new access, callback;
menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
new key = str_to_num(data);

switch(key)
{
case 8: nevcedRaktar(id);
case 4: ak47nevcedulahoz_raktar(id);
case 5: Menu_nevcedulas2(id);
case 2:
{
client_cmd(id, "messagemode Reg_nevcedula1");
}
case 3:
{
	ColorChat(id, GREEN, "^1--------===^3[ NÉVCÉDULA Adatok ]^1===--------");
	ColorChat(id, GREEN, "^1 A ^4Névcédulád^3 (%s) ^1sikeresen ^3be ^1lett állítva^3 %s ^1fegyverre!", Fegyverneve[Fegyverek[Selectedgun[id][AK47]][g_WeapID]][id], Fegyverek[Selectedgun[id][AK47]][g_WeapID]);
	ColorChat(id, GREEN, "^1--------===^3[ NÉVCÉDULA ]^1===--------");
	sql_update_account_nametag(id);
	}
	}
return PLUGIN_HANDLED;
}
public ak47regisztralas_nevcedula(id)
{
	new adat[32];
	read_args(adat, charsmax(adat));
	remove_quotes(adat);

	new fajl[192]
	formatex(fajl, charsmax(fajl), "addons/amxmodx/configs/szavak.ini")
	if ((adat, charsmax(adat)) == file_exists(fajl))
	{
		ColorChat(id, BLUE, "^3»^4[K]ÁRPÁTI[A]^3» ^1A beírt szöveg csak nem^3 (%s)^1 tartalmazhatja!", fajl);
	}
	else
	{
	copy(Fegyverneve[Fegyverek[Selectedgun[id][AK47]][g_WeapID]][id], 100, adat);
	Beirtcedula[id] = true;
	Menu_nevcedulas2(id); 
	}	
}	
public ak47nevcedulahoz_raktar(id)
{
	new szMenu[121],String[6]
	formatex(szMenu, charsmax(szMenu), "|K|ÁRPÁTI|A|~\wFegyver Skinek")
	new menu = menu_create(szMenu, "ak47nevcedulahoz_raktar_h");
 
	for(new i;i < sizeof(Fegyverek); i++)
	{
		if(5 <= Fegyverek[i][g_WeapID] <= 15)
		{
		if(g_PlayerHWA[id][i] > 0)
		{
			formatex(szMenu, charsmax(szMenu), "%s", Fegyverek[i][Name]);
			num_to_str(i, String, 5);
			menu_additem(menu, szMenu, String);
			}
		}
	}
	menu_display(id, menu, 0);
}
// 2
public m4Menu_nevcedulas_h(id, menu, item)
{
if(item == MENU_EXIT)
{
menu_destroy(menu);
return PLUGIN_HANDLED;
}

new data[9], szName[64];
new access, callback;
menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
new key = str_to_num(data);

switch(key)
{
case 8: nevcedRaktar(id);
case 4: m4nevcedulahoz_raktar(id);
case 5: Menu_nevcedulas1(id);
case 2:
{
client_cmd(id, "messagemode Reg_nevcedula2");
}
case 3:
{
	
	ColorChat(id, GREEN, "^1--------===^3[ NÉVCÉDULA Adatok ]^1===--------");
	ColorChat(id, GREEN, "^1 A ^4Névcédulád^3 (%s) ^1sikeresen ^3be ^1lett állítva^3 %s ^1fegyverre!", Fegyverneve[Fegyverek[Selectedgun[id][M4A1]][g_WeapID]][id], Fegyverek[Selectedgun[id][M4A1]][g_WeapID]);
	ColorChat(id, GREEN, "^1--------===^3[ NÉVCÉDULA ]^1===--------");
	sql_update_account_nametag(id);
		}	
	}
return PLUGIN_HANDLED;
}
public m4regisztralas_nevcedula(id)
{
	new adat[32];
	read_args(adat, charsmax(adat));
	remove_quotes(adat);

	new fajl[192]
	formatex(fajl, charsmax(fajl), "addons/amxmodx/configs/szavak.ini")
	if ((adat, charsmax(adat)) == file_exists(fajl))
	{
		ColorChat(id, BLUE, "^3»^4[K]ÁRPÁTI[A]^3» ^1A beírt szöveg csak nem^3 (%s)^1 tartalmazhatja!", fajl);
	}
	else
	{
	copy(Fegyverneve[Fegyverek[Selectedgun[id][M4A1]][g_WeapID]][id], 100, adat);
	Beirtcedula[id] = true;
	Menu_nevcedulas1(id);
	}	
}
public m4nevcedulahoz_raktar(id)
{
	new szMenu[121],String[6]
	formatex(szMenu, charsmax(szMenu), "|K|ÁRPÁTI|A|~\wFegyver Skinek")
	new menu = menu_create(szMenu, "m4nevcedulahoz_raktar_h");
 
	for(new i;i < sizeof(Fegyverek); i++)
	{
		if(16 <= Fegyverek[i][g_WeapID] <= 26)
		{
		if(g_PlayerHWA[id][i] > 0)
		{
			formatex(szMenu, charsmax(szMenu), "%s", Fegyverek[i][Name]);
			num_to_str(i, String, 5);
			menu_additem(menu, szMenu, String);
			}
		}
	}
	menu_display(id, menu, 0);
}
// 3
public awpMenu_nevcedulas_h(id, menu, item)
{
if(item == MENU_EXIT)
{
menu_destroy(menu);
return PLUGIN_HANDLED;
}

new data[9], szName[64];
new access, callback;
menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
new key = str_to_num(data);

switch(key)
{
case 8: nevcedRaktar(id);
case 4: awpnevcedulahoz_raktar(id);
case 5: Menu_nevcedulas3(id);
case 2:
{
client_cmd(id, "messagemode Reg_nevcedula3");
}
case 3:
{
	
	ColorChat(id, GREEN, "^1--------===^3[ NÉVCÉDULA Adatok ]^1===--------");
	ColorChat(id, GREEN, "^1 A ^4Névcédulád^3 (%s) ^1sikeresen ^3be ^1lett állítva^3 %s ^1fegyverre!", Fegyverneve[Fegyverek[Selectedgun[id][AWP]][g_WeapID]][id], Fegyverek[Selectedgun[id][AWP]][g_WeapID]);
	ColorChat(id, GREEN, "^1--------===^3[ NÉVCÉDULA ]^1===--------");
	sql_update_account_nametag(id);
	
}
}
return PLUGIN_HANDLED;
}
public awpregisztralas_nevcedula(id)
{
	new adat[32];
	read_args(adat, charsmax(adat));
	remove_quotes(adat);
	
	new fajl[192]
	formatex(fajl, charsmax(fajl), "addons/amxmodx/configs/szavak.ini")
	if ((adat, charsmax(adat)) == file_exists(fajl))
	{
		ColorChat(id, BLUE, "^3»^4[K]ÁRPÁTI[A]^3» ^1A beírt szöveg csak nem^3 (%s)^1 tartalmazhatja!", fajl);
	}
	else
	{
	copy(Fegyverneve[Fegyverek[Selectedgun[id][AWP]][g_WeapID]][id], 100, adat);
	Beirtcedula[id] = true;
	Menu_nevcedulas3(id);
	}
}
public awpnevcedulahoz_raktar(id)
{
	new szMenu[121],String[6]
	formatex(szMenu, charsmax(szMenu), "|K|ÁRPÁTI|A|~\wFegyver Skinek")
	new menu = menu_create(szMenu, "awpnevcedulahoz_raktar_h");
 
	for(new i;i < sizeof(Fegyverek); i++)
	{
		if(27 <= Fegyverek[i][g_WeapID] <= 40)	
		{
		if(g_PlayerHWA[id][i] > 0)
		{
			formatex(szMenu, charsmax(szMenu), "%s", Fegyverek[i][Name]);
			num_to_str(i, String, 5);
			menu_additem(menu, szMenu, String);
			}
		}
	}
	menu_display(id, menu, 0);
}
// 4
public deagMenu_nevcedulas_h(id, menu, item)
{
if(item == MENU_EXIT)
{
menu_destroy(menu);
return PLUGIN_HANDLED;
}

new data[9], szName[64];
new access, callback;
menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
new key = str_to_num(data);

switch(key)
{
case 8: nevcedRaktar(id);
case 4: deagnevcedulahoz_raktar(id);
case 5: Menu_nevcedulas4(id);
case 2:
{
client_cmd(id, "messagemode Reg_nevcedula4");
}
case 3:
{
	ColorChat(id, GREEN, "^1--------===^3[ NÉVCÉDULA Adatok ]^1===--------");
	ColorChat(id, GREEN, "^1 A ^4Névcédulád^3 (%s) ^1sikeresen ^3be ^1lett állítva^3 %s ^1fegyverre!", Fegyverneve[Fegyverek[Selectedgun[id][DEAGLE]][g_WeapID]][id], Fegyverek[Selectedgun[id][DEAGLE]][g_WeapID]);
	ColorChat(id, GREEN, "^1--------===^3[ NÉVCÉDULA ]^1===--------");
	sql_update_account_nametag(id);
	
}
}
return PLUGIN_HANDLED;
}
public deagregisztralas_nevcedula(id)
{
	new adat[32];
	read_args(adat, charsmax(adat));
	remove_quotes(adat);

	new fajl[192]
	formatex(fajl, charsmax(fajl), "addons/amxmodx/configs/szavak.ini")
	if ((adat, charsmax(adat)) == file_exists(fajl))
	{
		ColorChat(id, BLUE, "^3»^4[K]ÁRPÁTI[A]^3» ^1A beírt szöveg csak nem^3 (%s)^1 tartalmazhatja!", fajl);
	}
	else
	{
	copy(Fegyverneve[Fegyverek[Selectedgun[id][DEAGLE]][g_WeapID]][id], 100, adat);
	Beirtcedula[id] = true;
	Menu_nevcedulas4(id);
	}
}
public deagnevcedulahoz_raktar(id)
{
	new szMenu[121],String[6]
	formatex(szMenu, charsmax(szMenu), "|K|ÁRPÁTI|A|~\wFegyver Skinek")
	new menu = menu_create(szMenu, "deagnevcedulahoz_raktar_h");
 
	for(new i;i < sizeof(Fegyverek); i++)
	{
		if(41 <= Fegyverek[i][g_WeapID] <= 50)
		{
		if(g_PlayerHWA[id][i] > 0)
		{
			formatex(szMenu, charsmax(szMenu), "%s", Fegyverek[i][Name]);
			num_to_str(i, String, 5);
			menu_additem(menu, szMenu, String);
			}
		}
	}
	menu_display(id, menu, 0);
}
// 5
public kesMenu_nevcedulas_h(id, menu, item)
{
if(item == MENU_EXIT)
{
menu_destroy(menu);
return PLUGIN_HANDLED;
}

new data[9], szName[64];
new access, callback;
menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
new key = str_to_num(data);

switch(key)
{
case 8: nevcedRaktar(id);
case 4: kesnevcedulahoz_raktar(id);
case 5: Menu_nevcedulas5(id);
case 2:
{
client_cmd(id, "messagemode Reg_nevcedula5");
}
case 3:
{
	ColorChat(id, GREEN, "^1--------===^3[ NÉVCÉDULA Adatok ]^1===--------");
	ColorChat(id, GREEN, "^1 A ^4Névcédulád^3 (%s) ^1sikeresen ^3be ^1lett állítva^3 %s ^1fegyverre!", Fegyverneve[Fegyverek[Selectedgun[id][KNIFE]][g_WeapID]][id], Fegyverek[Selectedgun[id][KNIFE]][g_WeapID]);
	ColorChat(id, GREEN, "^1--------===^3[ NÉVCÉDULA ]^1===--------");
	sql_update_account_nametag(id);
}
}
return PLUGIN_HANDLED;
}
public kesregisztralas_nevcedula(id)
{
	new adat[32];
	read_args(adat, charsmax(adat));
	remove_quotes(adat);

	new fajl[192]
	formatex(fajl, charsmax(fajl), "addons/amxmodx/configs/szavak.ini")
	if ((adat, charsmax(adat)) == file_exists(fajl))
	{
		ColorChat(id, BLUE, "^3»^4[K]ÁRPÁTI[A]^3» ^1A beírt szöveg csak nem^3 (%s)^1 tartalmazhatja!", fajl);
	}
	else
	{
	copy(Fegyverneve[Fegyverek[Selectedgun[id][KNIFE]][g_WeapID]][id], 100, adat);
	Beirtcedula[id] = true;
	Menu_nevcedulas5(id);
	}
}
public kesnevcedulahoz_raktar(id)
{
	new szMenu[121],String[6]
	formatex(szMenu, charsmax(szMenu), "|K|ÁRPÁTI|A|~\wFegyver Skinek")
	new menu = menu_create(szMenu, "kesnevcedulahoz_raktar_h");
 
	for(new i;i < sizeof(Fegyverek); i++)
	{
		if(51 <= Fegyverek[i][g_WeapID] <= 70)
		{
		if(g_PlayerHWA[id][i] > 0)
		{
			formatex(szMenu, charsmax(szMenu), "%s", Fegyverek[i][Name]);
			num_to_str(i, String, 5);
			menu_additem(menu, szMenu, String);
			}
		}
	}
	menu_display(id, menu, 0);
}
public ak47nevcedulahoz_raktar_h(id, menu, item){
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED
	}

	new data[9], szName[64]
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName, charsmax(szName), callback);
	new key = str_to_num(data);

	Selectedgun[id][AK47] = key;
	ColorChat(id, GREEN, "^4%s ^1Felszerelted a ^3%s^1 fegyvert.", C_Prefix, Fegyverek[Selectedgun[id][AK47]][Name]);
	Menu_nevcedulas2(id);
	
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public m4nevcedulahoz_raktar_h(id, menu, item){
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED
	}

	new data[9], szName[64]
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName, charsmax(szName), callback);
	new key = str_to_num(data);

	
	Selectedgun[id][M4A1] = key;
	ColorChat(id, GREEN, "^4%s ^1Felszerelted a ^3%s^1 fegyvert.", C_Prefix, Fegyverek[Selectedgun[id][M4A1]][Name]);
	
	Menu_nevcedulas1(id);
	
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public awpnevcedulahoz_raktar_h(id, menu, item){
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED
	}

	new data[9], szName[64]
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName, charsmax(szName), callback);
	new key = str_to_num(data);

	
	Selectedgun[id][AWP] = key;
	ColorChat(id, GREEN, "^4%s ^1Felszerelted a ^3%s^1 fegyvert.", C_Prefix, Fegyverek[Selectedgun[id][AWP]][Name]);
	
	Menu_nevcedulas3(id);
	
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public deagnevcedulahoz_raktar_h(id, menu, item){
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED
	}

	new data[9], szName[64]
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName, charsmax(szName), callback);
	new key = str_to_num(data);

	
	Selectedgun[id][DEAGLE] = key;
	ColorChat(id, GREEN, "^4%s ^1Felszerelted a ^3%s^1 fegyvert.", C_Prefix, Fegyverek[Selectedgun[id][DEAGLE]][Name]);
	
	Menu_nevcedulas4(id);
	
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public kesnevcedulahoz_raktar_h(id, menu, item){
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED
	}

	new data[9], szName[64]
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName, charsmax(szName), callback);
	new key = str_to_num(data);

	
	Selectedgun[id][KNIFE] = key;
	ColorChat(id, GREEN, "^4%s ^1Felszerelted a ^3%s^1 fegyvert.", C_Prefix, Fegyverek[Selectedgun[id][KNIFE]][Name]);
	
	Menu_nevcedulas5(id);
	
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public szamlalo(id)
{
	if(generalva == true) {
		counter++
	}
	if(megvan == true) {
		counter = 0
	}
	if(counter > 30 && generalva == true)
	{
		new target = find_ent_by_class(target, "nyeremendoboz")
		engfunc(EngFunc_RemoveEntity, target)
		dobozszam--
		counter = 0
		generalva = false
		switch(random_num(1,5)) {
			case 1: { 
				ColorChat(0, RED, "^4[K]ÁRPÁTI[A] FUN »^1 Sajnos a Dobozt eltűnt! Hamarosan lesz új doboz!");
			}
			case 2: {
				ColorChat(0, RED, "^4[K]ÁRPÁTI[A] FUN »^1 Sajnos a Dobozt eltűnt! Hamarosan lesz új doboz!");
			}
			case 3: {
				ColorChat(0, RED, "^4[K]ÁRPÁTI[A] FUN »^1 Sajnos a Dobozt eltűnt! Hamarosan lesz új doboz!");
			}
			case 4: {
				ColorChat(0, RED, "^4[K]ÁRPÁTI[A] FUN »^1 Sajnos a Dobozt eltűnt! Hamarosan lesz új doboz!");
			}
			case 5: {
				ColorChat(0, RED, "^4[K]ÁRPÁTI[A] FUN »^1 Sajnos a Dobozt eltűnt! Hamarosan lesz új doboz!");
			}
 
		}
 
	}
}
 
public keszit(id)
{
	if(dobozszam < get_pcvar_num(cvar))
	 {	
		new inifile[192], map[32]
		get_mapname(map, 31)
		formatex(inifile, charsmax(inifile), "addons/amxmodx/configs/csdm/%s.spawns.cfg", map)
		new Float:origin[3]
		new elsopoz[8], masodikpoz[8], harmadikpoz[8]
		new lines = file_size(inifile, 1)
		if(lines > 0)
		{
			new randomLine = random(lines);
			new lineBuffer[256], len;
			read_file(inifile, randomLine, lineBuffer, charsmax(lineBuffer), len);	
			parse(lineBuffer, elsopoz, 7, masodikpoz, 7, harmadikpoz, 7)
 
			origin[0] = str_to_float(elsopoz)
			origin[1] = str_to_float(masodikpoz)
			origin[2] = str_to_float(harmadikpoz)
		}
 
 
		new ent = create_entity("info_target")
		set_pev(ent, pev_classname, "nyeremendoboz")
		entity_set_model(ent, ET_model[random(sizeof(ET_model))])
 
		set_pev(ent,pev_solid, SOLID_BBOX)
		set_pev(ent, pev_movetype, MOVETYPE_TOSS)
		engfunc(EngFunc_SetOrigin, ent, origin)
		engfunc(EngFunc_SetSize, ent, Float:{-10.0,-10.0,0.0}, Float:{10.0,10.0,25.0})
		engfunc(EngFunc_DropToFloor, ent)
		//fm_set_rendering(ent, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 16);
		switch(random_num(1,5)) {
			case 1: { 
				ColorChat(0, RED, "^4[K]ÁRPÁTI[A] FUN »^1 ÚJ DOBOZ JELENT MEG!!!^4 KERESSÉTEK MEG");
			}
			case 2: {
				ColorChat(0, RED, "^4[K]ÁRPÁTI[A] FUN »^1 ÚJ DOBOZ JELENT MEG!!!^4 KERESSÉTEK MEG");
			}
			case 3: {
				ColorChat(0, RED, "^4[K]ÁRPÁTI[A] FUN »^1 ÚJ DOBOZ JELENT MEG!!!^4 KERESSÉTEK MEG");
			}
			case 4: {
				ColorChat(0, RED, "^4[K]ÁRPÁTI[A] FUN »^1 ÚJ DOBOZ JELENT MEG!!!^4 KERESSÉTEK MEG");
			}
			case 5: {
				ColorChat(0, RED, "^4[K]ÁRPÁTI[A] FUN »^1 ÚJ DOBOZ JELENT MEG!!!^4 KERESSÉTEK MEG");
			}
 
		}
		dobozszam++
		megvan = false
		generalva = true
	}
}
 
public remove(ent, id)
{
		g_playerData[felszedett][id]++
		dobozszam--
		new nev[32]
		get_user_name(id, nev, 31)
		ColorChat(0, RED, "^4[K]ÁRPÁTI[A] FUN »^3 %s ^1megtalálta a Dobozt, kapott^3 + 1 Dobozt!^4 Gratulálunk!!", nev);
		g_playerData[SMS][id]++;
		
		engfunc(EngFunc_RemoveEntity, ent)
		megvan = true
		generalva = false
}

/*UJITAS- ELOFIZETES*/ 

public bypass_fomenu(id)
{
	static menu[512],len;
	len = 0;

	len = formatex(menu[len], charsmax(menu) - len, "%s^n \yByPass Előfizetés^n^n", Prefix);
	
	len += formatex(menu[len], charsmax(menu) - len, "\r[1] \y»\w Vásárlás^n");
	len += formatex(menu[len], charsmax(menu) - len, "\r[2] \y»\w Fegyver Csomagok^n");
	len += formatex(menu[len], charsmax(menu) - len, "\r[3] \y»\w Különböző Jutalmak^n");
	len += formatex(menu[len], charsmax(menu) - len, "\r[4] \y»\w Egyedi BEÁLLÍTÁSOK^n");
	len += formatex(menu[len], charsmax(menu) - len, "\r[5] \y»\w ByPass Ruha készlet^n");
	

	new keys = MENU_KEY_0|MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6|MENU_KEY_7|MENU_KEY_8|MENU_KEY_9;
	show_menu(id, keys, menu, -1, "bypass_fomenu");
	return PLUGIN_HANDLED;	
}	
public bypass_h(id, key)
{
	switch(key) 
	{
		case 0: 
		{
		bypass_vasarlas(id);
		bypass_vasarlas2(id);
		}
		case 1:
		{
		if(g_playerData[MPrefi][id] == 25 || g_playerData[MPrefi][id] == 1)
			bypass_fegyvercsomagok(id);	
		else 
			ColorChat(id, GREEN, "^4[K]ÁRPÁTI[A] FUN » ^1Ezt a menüt csak ^4ByPass Tag ^1használhatja!");
		}
		case 2:
		{
		if(g_playerData[MPrefi][id] == 25 || g_playerData[MPrefi][id] == 1)
			bypass_jutalmak(id);	
		else 
			ColorChat(id, GREEN, "^4[K]ÁRPÁTI[A] FUN » ^1Ezt a menüt csak ^4ByPass Tag ^1használhatja!");
		}
		case 3:
		{
		if(g_playerData[MPrefi][id] == 25 || g_playerData[MPrefi][id] == 1)
			bypass_egyedibeallitasok(id);	
		else 
			ColorChat(id, GREEN, "^4[K]ÁRPÁTI[A] FUN » ^1Ezt a menüt csak ^4ByPass Tag ^1használhatja!");
		}
		case 4:
		{
		if(g_playerData[MPrefi][id] == 25 || g_playerData[MPrefi][id] == 1)
			bypass_ruhakeszlet(id);	
		else 
			ColorChat(id, GREEN, "^4[K]ÁRPÁTI[A] FUN » ^1Ezt a menüt csak ^4ByPass Tag ^1használhatja!");
		}
	}
}

public bypass_fegyvercsomagok(id)
{
	new cim[121];
	format(cim, charsmax(cim), "[%s] \r- \dByPass\w Fegyver Csomag", Prefix);
	new menu = menu_create(cim, "bypass_fegyvercsomagok_h");
	
	menu_additem(menu, "\yCsomag 1\w Fegyver Csomag", "0", 0);
	menu_additem(menu, "\yCsomag 2\w Fegyver Csomag", "1", 0);
	menu_additem(menu, "\yCsomag 3\w Fegyver Csomag", "2", 0);
	menu_additem(menu, "\yCsomag 4\w Fegyver Csomag", "3", 0);
	menu_additem(menu, "\yCsomag 5\w Fegyver Csomag", "4", 0);
	
	menu_display(id, menu, 0);
}

public bypass_fegyvercsomagok_h(id, menu, item)
{

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
		Selectedgun[id][AK47] = 111;
		Selectedgun[id][M4A1] = 114;
		Selectedgun[id][AWP] = 112;
		Selectedgun[id][DEAGLE] = 113;
		Selectedgun[id][KNIFE] = 115;
		ColorChat(id, GREEN, "^4[K]ÁRPÁTI[A]- FUN » ^1Sikeresen felszerelted ^3csomagot");
		}
		case 1:
		{
		Selectedgun[id][AK47] = 101;
		Selectedgun[id][M4A1] = 104;
		Selectedgun[id][AWP] = 102;
		Selectedgun[id][DEAGLE] = 103;
		Selectedgun[id][KNIFE] = 105;
		ColorChat(id, GREEN, "^4[K]ÁRPÁTI[A]- FUN » ^1Sikeresen felszerelted^3 csomagot");
		}
		case 2: 
		{
		Selectedgun[id][AK47] = 96;
		Selectedgun[id][M4A1] = 99;
		Selectedgun[id][AWP] = 97;
		Selectedgun[id][DEAGLE] = 98;
		Selectedgun[id][KNIFE] = 100;
		ColorChat(id, GREEN, "^4[K]ÁRPÁTI[A]- FUN » ^1Sikeresen felszerelted ^3csomagot");
		}
		case 3: 
		{
		Selectedgun[id][AK47] = 91;
		Selectedgun[id][M4A1] = 94;
		Selectedgun[id][AWP] = 92;
		Selectedgun[id][DEAGLE] = 93;
		Selectedgun[id][KNIFE] = 95;
		ColorChat(id, GREEN, "^4[K]ÁRPÁTI[A]- FUN » ^1Sikeresen felszerelted ^3csomagot");
		}
		case 4: 
		{
		Selectedgun[id][AK47] = 106;
		Selectedgun[id][M4A1] = 109;
		Selectedgun[id][AWP] = 107;
		Selectedgun[id][DEAGLE] = 108;
		Selectedgun[id][KNIFE] = 110;
		ColorChat(id, GREEN, "^4[K]ÁRPÁTI[A]- FUN » ^1Sikeresen felszerelted ^3csomagot");
		}
	}
}

public bypass_jutalmak(id)
{
	new cim[121], String[121];
	format(cim, charsmax(cim), "[%s] \r- \dByPass\w Jutalmak", Prefix);
	new menu = menu_create(cim, "bypass_jutalmak_h");
	
	new iTime;
	
	iTime = g_Erdem[eTime][id] + get_user_time(id);

	if(iTime >= ErdemErme[g_Erdem[ErdemSzint][id]][ErdemIdeje] && kibestat[id] == 0)
	{
		format(String,charsmax(String),"\yÉrj el 1 óra játék időt! [Jutalomhoz nyomj ide]^n\d Jutalom: \r 2.000 Prémium Pont");
		menu_additem(menu,String,"1");
	}
	else
	{
		format(String,charsmax(String),"\dÉrj el 1 óra játék időt!\y [LEZÁRVA]");
		menu_additem(menu,String,"0");
	}

	
	if(iTime >= ErdemErme[g_Erdem[ErdemSzint][id]][ErdemIdeje] &&	kibestat[id] == 1)
	{
		format(String,charsmax(String),"\yÉrj el 2 óra játék időt! [Jutalomhoz nyomj ide]^n\d Jutalom: \r 5.000 Prémium Pont");
		menu_additem(menu,String,"2");
	}
	else
	{
		format(String,charsmax(String),"\dÉrj el 2 óra játék időt!\y [LEZÁRVA]");
		menu_additem(menu,String,"0");
	}

	
	if(iTime >= ErdemErme[g_Erdem[ErdemSzint][id]][ErdemIdeje] &&	kibestat[id] == 2)
	{
		format(String,charsmax(String),"\yÉrj el 3 óra játék időt! [Jutalomhoz nyomj ide]^n\d Jutalom: \r 10.000 Prémium Pont");
		menu_additem(menu,String,"3");
	}
	else
	{
		format(String,charsmax(String),"\dÉrj el 3 óra játék időt!\y [LEZÁRVA]");
		menu_additem(menu,String,"0");
	}

	
	if(iTime >= ErdemErme[g_Erdem[ErdemSzint][id]][ErdemIdeje] &&	kibestat[id] == 3)
	{
		format(String,charsmax(String),"\yÉrj el 5 óra játék időt! [Jutalomhoz nyomj ide]^n\d Jutalom: \r 15.000 Prémium Pont");
		menu_additem(menu,String,"4");
	}
	else
	{
		format(String,charsmax(String),"\dÉrj el 5 óra játék időt! \y[LEZÁRVA]");
		menu_additem(menu,String,"0");
	}

	
	if(iTime >= ErdemErme[g_Erdem[ErdemSzint][id]][ErdemIdeje] &&	kibestat[id] == 4)
	{
		format(String,charsmax(String),"\yÉrj el 10 óra játék időt! [Jutalomhoz nyomj ide]^n\d Jutalom: \r 25.000 Prémium Pont");
		menu_additem(menu,String,"5");
	}
	else
	{
		format(String,charsmax(String),"\dÉrj el 10 óra játék időt! \y[LEZÁRVA]");
		menu_additem(menu,String,"0");
	}

	
	if(iTime >= ErdemErme[g_Erdem[ErdemSzint][id]][ErdemIdeje] &&	kibestat[id] == 5)
	{
		format(String,charsmax(String),"\d Jutalom: \r 35.000 Prémium Pont");
		menu_additem(menu,String,"6");
	}
	else
	{
		format(String,charsmax(String),"\dÉrj el 20 óra játék időt!\y [LEZÁRVA]");
		menu_additem(menu,String,"0");
	}
	
	menu_display(id, menu, 0);
}

public bypass_jutalmak_h(id, menu, item)
{

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
		case 0:	ColorChat(id, GREEN, "^4[K]ÁRPÁTI[A] FUN » ^1Sajnálom, nincs még ehez elért időd!");
		case 1: 
		{
		ColorChat(id, GREEN, "^4[K]ÁRPÁTI[A] FUN » ^1Sikeresen megkaptad a JUTALMAD!!^4 (2000 Prémium Pont)");
		g_playerData[SMS][id] += 2000;
		kibestat[id] = 1;
		}
		case 2:	
		{
		ColorChat(id, GREEN, "^4[K]ÁRPÁTI[A] FUN » ^1Sikeresen megkaptad a JUTALMAD!!^4 (5000 Prémium Pont)");
		g_playerData[SMS][id] += 5000;
		kibestat[id] = 2;
		}
		case 3:	
		{
		ColorChat(id, GREEN, "^4[K]ÁRPÁTI[A] FUN » ^1Sikeresen megkaptad a JUTALMAD!!^4 (10000 Prémium Pont)");
		g_playerData[SMS][id] += 10000;
		kibestat[id] = 3;
		}
		case 4:	
		{
		ColorChat(id, GREEN, "^4[K]ÁRPÁTI[A] FUN » ^1Sikeresen megkaptad a JUTALMAD!!^4 (15000 Prémium Pont)");
		g_playerData[SMS][id] += 15000;
		kibestat[id] = 4;
		}
		case 5:	
		{
		ColorChat(id, GREEN, "^4[K]ÁRPÁTI[A] FUN » ^1Sikeresen megkaptad a JUTALMAD!!^4 (25000 Prémium Pont)");
		g_playerData[SMS][id] += 25000;
		kibestat[id] = 5;
		}
		case 6:	
		{
		ColorChat(id, GREEN, "^4[K]ÁRPÁTI[A] FUN » ^1Sikeresen megkaptad a JUTALMAD!^4 (35000 Prémium Pont)");
		g_playerData[SMS][id] += 35000;
		kibestat[id] = 6;
		}
	}
}

public bypass_egyedibeallitasok(id)
{
	new cim[121], String[121];
	format(cim, charsmax(cim), "[%s] \r- \dByPass\w Egyedi Beállítások", Prefix);
	new menu = menu_create(cim, "bypass_egyedibeallitasok_h");
	
	
	menu_additem(menu, "\yAlap CS1.6 SKINEK", "1", 0);

	if(g_adatok[alapchat][id] == 1)
		format(String,charsmax(String),"\wChat: \y»\w	Rang/Prefix ");
	else
		format(String,charsmax(String),"\wChat: \y»\w	ALAP ");
	menu_additem(menu,String,"2");
	
	if(g_adatok[hudszin][id] == 0)
		format(String,charsmax(String),"\wHUD SZÍN: \y»\w Alap");
	else if(g_adatok[hudszin][id] == 1)
		format(String,charsmax(String),"\wHUD SZÍN: \y»\w	Zöld ");
	menu_additem(menu,String,"4");

	if(g_adatok[Osszes_kartya][id] == 1)
		format(String,charsmax(String),"\wFegyvermenüben skin név: \y»\w BEKAPCSOLVA");
	else
		format(String,charsmax(String),"\wFegyvermenüben skin név: \y»\w KIKAPCSOLVA");
	menu_additem(menu,String,"3");


	
	menu_display(id, menu, 0);
}

public bypass_egyedibeallitasok_h(id, menu, item)
{

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
		case 2: 
		{
			if(g_adatok[alapchat][id] == 0) g_adatok[alapchat][id] = 1;
			else g_adatok[alapchat][id] = 0;
			bypass_egyedibeallitasok(id);
		}
		case 3: 
		{
			if(g_adatok[Osszes_kartya][id] == 1) g_adatok[Osszes_kartya][id] = 0;
			else g_adatok[Osszes_kartya][id] = 1;
			bypass_egyedibeallitasok(id);
		}
		case 4: 
		{
			if(g_adatok[hudszin][id] == 0) g_adatok[hudszin][id] = 1;
			else if(g_adatok[hudszin][id] = 1) g_adatok[hudszin][id] = 0;
			bypass_egyedibeallitasok(id);
		}
	}
}

public bypass_ruhakeszlet(id)
{
	new cim[121];
	format(cim, charsmax(cim), "[%s] \r- \dByPass\w RUHA KÉSZLET", Prefix);
	new menu = menu_create(cim, "bypass_ruhakeszlet_h");
	
	menu_additem(menu, "\yKinézet  \w(TERROR)", "0", 0);
	//menu_additem(menu, "\dhamarosan \w (TERROR)", "1", 0);
	menu_additem(menu, "\yKinézet \w(COUNTER-TERROR)", "2", 0);
	//menu_additem(menu, "\dhamarosan\w	(COUNTER-TERROR)", "3", 0);
	
	menu_display(id, menu, 0);
}

public bypass_ruhakeszlet_h(id, menu, item)
{

	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return;
	}
	
	new data[9], szName[64];
	new access, callback;
	new CsTeams:csapat = cs_get_user_team(id);
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
	new key = str_to_num(data);
	
	switch(key) 
	{
		case 1: bypass_ruhakeszlet(id);
		case 3: bypass_ruhakeszlet(id);
		case 0: 
		{
			if(csapat == CS_TEAM_T)
			{
				cs_set_user_model(id, "spiderman");
				ColorChat(id, GREEN, "^4[K]ÁRPÁTI[A] FUN »^1Sikeresen kiválasztottad a ^3Pókember ^1kinézetet!");
			}
			else
			{
				ColorChat(id, GREEN, "^4[K]ÁRPÁTI[A] FUN »^1Sajnálom, nem tudod kiválasztani a ^3Pókember ^1skint, mert nem vagy ^3Terrorista^1!");
			}
		}
		case 2:
		{
			if(csapat == CS_TEAM_CT)
			{
				cs_set_user_model(id, "batman");
				ColorChat(id, GREEN, "^4[K]ÁRPÁTI[A] FUN »^1Sikeresen kiválasztottad a ^3Batman ^1kinézetet!");
			}
			else
			{
				ColorChat(id, GREEN, "^4[K]ÁRPÁTI[A] FUN »^1Sajnálom, nem tudod kiválasztani a ^3Batman ^1skint, mert nem vagy ^3Anti-Terrorista^1!");
			}
		}
	}
}
public bypass_vasarlas(id)
{
	ColorChat(id, GREEN, "^4[K]ÁRPÁTI[A] FUN »^1MÁJUSI BYPASS VÁSÁRLÁS-->^4FACEBOOK:^1	https://www.facebook.com/szabopatrik10");
	ColorChat(id, GREEN, "^4[K]ÁRPÁTI[A] FUN »^1ByPass Ára:^4 1200 Ft");
}

public bypass_vasarlas2(id)
{
	new String[121];
	format(String, charsmax(String), "%s \r- \dByPaSS Vásárlás", Prefix);
	new menu = menu_create(String, "SMS_Fomenu_h");

	menu_additem(menu, "\rByPaSS Tagság Ára:\w 1200Ft", "0", 0);
	menu_additem(menu, "\yPayPal/Banki utalással!", "0", 0);
	menu_additem(menu, "\yByPass V2\w Tagság 1 ÉVRE\r ÁRA:\y 5000 Ft", "0", 0);
	menu_additem(menu, "------------[ TwisT részére]----------", "0", 0);
	menu_additem(menu, "Facebook:	https://www.facebook.com/szabopatrik10", "0", 0);
	menu_additem(menu, "Chatbe kiírja Facebook Linkem, ott is kibirod másolni!", "0", 0);
	menu_additem(menu, "\dÍrj rám Facebookon, 2 órán belül válaszolni fogok!", "0", 0);

	menu_display(id, menu, 0);
}

public bypass_adjidot(id)
{
	kibestat[id] += 1;
}

public fwdKilledPost(victim, attacker, corpse)
{
		if(!is_user_connected(victim) || !is_user_connected(attacker) || victim == attacker)
				return HAM_IGNORED;
				
		message_begin(MSG_ONE, get_user_msgid("ScreenFade"), {0,0,0}, attacker);
		write_short(1<<10);
		write_short(1<<10);
		write_short(0x0000);
		write_byte(0);
		write_byte(0);
		write_byte(200);
		write_byte(75);
		message_end();
		return HAM_IGNORED;
}

public Rangsorol(id)
{
	new len;
	new StringMotd[1536];
	new String[512];

	len += formatex(StringMotd[len], charsmax(StringMotd) - len, "<!DOCTYPE html> <html><head><meta charset=^"UTF-8^">");
	len += formatex(StringMotd[len], charsmax(StringMotd) - len, "</head><body style=^"background-color: rgb(100, 100, 100);^">");
	len += formatex(StringMotd[len], charsmax(StringMotd) - len, "<table border=^"5^" bordercolor=^"White^" align=^"center^" style=^"color: White^">");
	len += formatex(StringMotd[len], charsmax(StringMotd) - len, "<tr><th colspan=^"3^" bgcolor=#6B6B6B><h1>Jelenlegi Rangod:</br> <a style=^"color: #00dc00^">%s</a></h1></th>", Rangok[g_playerData[Rang][id]][Szint]);
  	len += formatex(StringMotd[len], charsmax(StringMotd) - len, "</tr><tr><th>Rangok</th></tr>");

	for(new i;i < sizeof(Rangok); i++)
	{
		len += formatex(StringMotd[len], charsmax(StringMotd) - len, "<td>%s</th>^n", Rangok[i][Szint]);
	}


	len += formatex(StringMotd[len], charsmax(StringMotd) - len, "</table></body><html>");
	
	formatex(String, charsmax(String), "%s | Rang sorolás", Prefix);
	show_motd(id, StringMotd, String);
}

public bypass_szint(id)
{
	g_Erdem[ErdemSzint][id] += 1;
}

public plugin_end()
{
	SQL_FreeHandle(g_SqlTuple);
}
public CmdSetAdmin(id, level, cid){
	if(!str_to_num(Admin_Permissions[AdminLevel[id]][2])){
		ColorChat(id, GREEN, "%s ^3Nincs elérhetőséged^1 ehhez a parancshoz!", C_Prefix);
		return PLUGIN_HANDLED;
	}

	new Arg1[32], Arg2[32], Arg_Int[2]
	read_argv(1, Arg1, charsmax(Arg1));
	read_argv(2, Arg2, charsmax(Arg2));

	Arg_Int[0] = str_to_num(Arg1);
	Arg_Int[1] = str_to_num(Arg2);
	
	if(Arg_Int[0] < 1 || Arg_Int[1] >= sizeof(Admin_Permissions))
		return PLUGIN_HANDLED;	

	new Data[1]
	new Is_Online = Check_Id_Online(Arg_Int[0]);
	new Query[2048];
	
	Data[0] = id;
	new sName[64], iName[64]
	get_user_name(Is_Online, sName, charsmax(sName));
	get_user_name(id, iName, charsmax(iName));

	formatex(Query, charsmax(Query), "UPDATE `karpatiasql` SET `AdminLevel` = %d WHERE `id` = %d;", Arg_Int[1], Arg_Int[0]);
	SQL_ThreadQuery(g_SqlTuple, "QuerySetData_Profiles", Query, Data, 1);
	
	if(Is_Online)
	{
		if(Arg_Int[1] > 0)
		{
			Set_Permissions(Is_Online);
			ColorChat(0, GREEN, "%s^1Játékos: ^3%s ^1(#^3%d^1) | ^3%s^1 jogot kapott! ^3%s^1(#^3%d^1) által!", C_Prefix, sName, Arg_Int[0], Admin_Permissions[Arg_Int[1]][0], iName, g_adatok[g_Id][id]);	
		}
		else
		{
			Remove_Permissions(Is_Online);
			ColorChat(0, GREEN, "%s^1Játékos: ^3%s ^1(#^3%d^1) | Jogok megvonva! ^3%s^1(#^3%d^1) által!", C_Prefix, sName, Arg_Int[0], iName, g_adatok[g_Id][id]);	
		}
		AdminLevel[Is_Online] = Arg_Int[1];
	}
	else
	{
		if(Arg_Int[1] > 0)
		{
			ColorChat(0, GREEN, "%s^1Játékos: ^3- ^1(#^3%d^1) | ^3%s^1 jogot kapott! ^3%s^1(#^3%d^1) által!", C_Prefix, Arg_Int[0], Admin_Permissions[Arg_Int[1]][0], iName, g_adatok[g_Id][id]);	
		}
		else
		{
			ColorChat(0, GREEN, "%s^1Játékos: ^3- ^1(#^3%d^1) | Jogok megvonva! ^3%s^1(#^3%d^1) által!", C_Prefix, Arg_Int[0], iName, g_adatok[g_Id][id]);		
		}	
	}
		
	return PLUGIN_HANDLED;
}
public Set_Permissions(id){
	new Flags;
	Flags = read_flags(Admin_Permissions[AdminLevel[id]][1]);
	set_user_flags(id, Flags);
}
public Remove_Permissions(id){
	new Flags;
	Flags = read_flags(Admin_Permissions[AdminLevel[id]][1]);
	remove_user_flags(id, Flags);
}
stock Check_Id_Online(id){
	for(new idx = 0; idx <= gMaxPlayers; idx++){
		if(!is_user_connected(idx))
			continue;
					
		if(g_adatok[g_Id][idx] == id)
			return idx;
	}
	return 0;
}
public QuerySetData_Profiles(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime)
{
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) 
	{
		log_amx("Error from admin:");
		log_amx("%s", Error);
		return;
	}
}
