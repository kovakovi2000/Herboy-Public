#include <amxmodx>
#include <amxmisc>
#include <hamsandwich>
#include <cstrike>
#include <engine>
#include <fakemeta>
#include <fun>
#include <xsqls>
#include <bbc_systems>
#include <tutor>
#include <ColorChat>
#include <mcdhud_api>
#include <fakemeta_util>
#include <geoip>

#pragma compress 1

#define MENU_MAIN_BUTTONS	(1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<5)|(1<<6)|(1<<7)|(1<<8)|(1<<9)

new const MainFolder[] = "pbt2020";

new const g_HOST[] = "db.synhosting.eu";
new const g_USERNAME[] = "nickname123";
new const g_PASSWORD[] = "1992klau1992";
new const g_DATABASE[] = "nickname123";

new const MainMusic[] = "2019 | CS:GO Mix | Sept.";

new const YellowOpen[]= "case_holyshit2.wav";
new const AchvUnlock[]= "achv_unlock.wav";
new const CashTune[]= "cash_tune.wav";

new const GrenadeFlashbang[]	= "w_flashbang.mdl";
new const GrenadeHegrenade[]	= "w_hegrenade.mdl";

new const BombC4[]= "w_c4.mdl";
new const BombBack[]= "w_backpack.mdl";

new const KnifeTerrorist[]	= "v_knife_t.mdl";
new const KnifeCTerrorist[]	= "v_knife_ct.mdl";

new const AdvertiseCount	= 0;
new const AchievementCount	= 37;

// #define	IS_HALLOWEEN_ENABLED
#define GET_HALLOWEEN_PUMPKIN_MODEL_NAME	"halloween_pumpkin.mdl"
#define GET_HALLOWEEN_PUPKIN_DROP_CHANCE	20

new const Float: MarketExtra	= 1.1;

enum _:Colors
{
	C_BLUE,
	C_PURPLE,
	C_PINK,
	C_RED,
	C_YELLOW,
	C_ORANGE
};

new const WEAPONENTNAMES[][] =
{
	""}, "weapon_p228"}, ""}, "weapon_scout"}, "weapon_hegrenade"}, "weapon_xm1014"}, "weapon_c4"}, "weapon_mac10"},
	"weapon_aug"}, "weapon_smokegrenade"}, "weapon_elite"}, "weapon_fiveseven"}, "weapon_ump45"}, "weapon_sg550"},
	"weapon_galil"}, "weapon_famas"}, "weapon_usp"}, "weapon_glock18"}, "weapon_awp"}, "weapon_mp5navy"}, "weapon_m249"},
	"weapon_m3"}, "weapon_m4a1"}, "weapon_tmp"}, "weapon_g3sg1"}, "weapon_flashbang"}, "weapon_deagle"}, "weapon_sg552"},
	"weapon_ak47"}, "weapon_knife"}, "weapon_p90"
}	

new const Guns[][][] =
{
	{ CSW_C4, -2,	0,	"Alap | C4"},"v_c4_v3.mdl"},0,	-1	},
	{ CSW_HEGRENADE, 	-1,	1,	"Alap | HEGRENADE"},	"v_hegrenade_v3.mdl"},	0,	-1	},
	{ CSW_FLASHBANG, 	-1,	2,	"Alap | FLASHBANG"},	"v_flashbang_v3.mdl"},	0,	-1	},
	{ CSW_KNIFE, -1,	0,	"Alap | KNIFE"},"v_knife_t.mdl"},	0,	-1	},
	{ CSW_AK47, 1,	90,	"Alap | AK47"},"v_ak47_v3.mdl"},	2700,	6	},
	{ CSW_M4A1, 1,	90,	"Alap | M4A4"},"v_m4a4_v3.mdl"},	3100,	14	},
	{ CSW_AWP, 1,	30,	"Alap | AWP"},"v_awp_v3.mdl"},4750,	6	},
	{ CSW_SCOUT, 1,	90,	"Alap | SCOUT"},"v_scout_v3.mdl"},	3000,	-1	},
	{ CSW_MP5NAVY, 1,	120,	"Alap | MP5"},"v_mp5_v3.mdl"},1700,	-1	},
	{ CSW_FAMAS, 1,	90,	"Alap | FAMAS"},"v_famas_v3.mdl"},	2250,	-1	},
	{ CSW_GALIL, 1,	90,	"Alap | GALIL"},"v_galil_v3.mdl"},	2000,	-1	},
	{ CSW_P90, 1,	90,	"Alap | P90"},"v_p90_v3.mdl"},2350,	-1	},
	{ CSW_GLOCK18, 2,	120,	"Alap | GLOCK18"},	"v_glock18_v3.mdl"},	200,	-1	},
	{ CSW_USP, 2,	100,	"Alap | USP-S"},"v_usp_v3.mdl"},200,	16	},
	{ CSW_DEAGLE, 2,	35,	"Alap | DEAGLE"},	"v_deagle_v3.mdl"},	700,	6	},
	{ CSW_ELITE, 2,	120,	"Alap | ELITE"},"v_elite_v3.mdl"},	500,	-1	},
	{ CSW_P228, 2,	52,	"Alap | P228"},"v_p228_v3.mdl"},	500,	-1	},
	{ CSW_FIVESEVEN, 	2,	100,	"Alap | FIVESEVEN"},	"v_fiveseven_v3.mdl"},	500,	-1	},
	{ CSW_M3, 1,	32,	"Alap | M3"},"v_m3_v3.mdl"},2200,	7	},
	{ CSW_XM1014, 1,	32,	"Alap | XM1014"},	"v_xm1014.mdl"},2000,	7	},
	{ CSW_MAC10, 1,	100,	"Alap | MAC-10"},	"v_mac10.mdl"},1400,	6	}
}

new const Cases[][][] =
{
	{ "Chroma Case"}, "38.18"},	1	},
	{ "Chroma 2 Case"}, "22.30"},	1	},
	{ "Chroma 3 Case"}, "18.69"},	1	},
	{ "Falchion Case"}, "14.15"},	1	},
	{ "Huntsman Case"}, "11.87"},	1	},
	{ "Breakout Case"}, "8.63"},1	},
	{ "Shadow Case"}, "3.74"},1	},
	{ "Gamma Case"}, "1.52"},1	},
	{ "Gamma 2 Case"}, "0.36"},1	},
	{ "eSport Summer (2019) Case"},	"0.00"},2	},
	{ "Hydra Case"},	"0.00"},2	},
	{ "eSport Winter (2019) Case"},	"0.00"},2	},
	{ "Clutch Case"},"1.00"},1	},
	{ "Phoenix Case"},"0.00"},2	},
	{ "Horizon Case"},"0.55"},1	},
	{ "Pumpkin Case (Special)"},	"0.00"},2	}
}


new const Coins[][][] =
{
	{ "2017"}, 	0},
	{ "Operation Hydra"}, 3},
	{ "2018"}, 	1},
	{ "Operation Phoenix"}, 2},
	{ "FRAG_BRONZE"}, 4},
	{ "FRAG_SILVER"}, 4},
	{ "FRAG_GOLD"}, 	4},
	{ "FRAG_DIAMOND"}, 4}
}

new const Weapons[][][] =
{
{ CSW_AK47, 1,	"AK47 | Jet Set"},"v_ak47_jetset.mdl"},	"Chroma 3 Case;"},C_PURPLE,	-1,	""	},
{ CSW_AK47, 1,	"AK47 | Vulcan"},"v_ak47_vulcan_v3.mdl"},	"Huntsman Case;"},C_RED,6,	""	},
{ CSW_AK47, 0,	"AK47 | Light Of King "}, 	"light_of_king_ak47.mdl"},";"},C_BLUE,6,	""	},
{ CSW_AK47, 1,	"AK47 | Aquamarine"},"v_ak47_aquamarine_v3.mdl"},"Falchion Case;"},C_PINK,6,	""	},
{ CSW_AK47, 1,	"AK47 | Cyrex"},	"v_ak47_cyrex_v3.mdl"},	"Shadow Case;"},	C_RED,6,	""	},
{ CSW_AK47, 1,	"AK47 | Street "}, "street_ak47.mdl"},	"Breakout Case;"},C_RED,6,	""	},
{ CSW_AK47, 1,	"AK47 | Frontside"},"v_ak47_frontside_v2.mdl"},"Huntsman Weapon;"},C_PURPLE,	6,	""	},
{ CSW_AK47, 0,	"AK47 | Frozen"},"v_ak47_frozen.mdl"},	";"},C_BLUE,-1,	""	},
{ CSW_AK47, 1,	"AK47 | Superman "}, "superman_ak47.mdl"},	"Gamma Case;"},	C_BLUE,6,	""	},
{ CSW_AK47, 1,	"AK47 | Jaguar"},"v_ak47_jaguar.mdl"},	"Gamma 2 Case;"},C_BLUE,-1,	""	},
{ CSW_AK47, 1,	"AK47 | Neon "}, "neon_ak47.mdl"},	"Gamma Case;"},	C_PINK,-1,	""	},
{ CSW_AK47, 1,	"AK47 | Point"},	"v_ak47_point_v2.mdl"},	"Chroma 2 Case;"},C_PURPLE,	6,	""	},
{ CSW_AK47, 1,	"AK47 | Space"},	"v_ak47_space_v3.mdl"},	"Shadow Case;"},	C_BLUE,6,	""	},
{ CSW_AK47, 1,	"AK47 | Superman "}, "superman_ak47.mdl"},	"Falchion Case;"},C_BLUE,-1,	""	},
{ CSW_AK47, 1,	"AK47 | Revenge "}, "revenge_ak47.mdl"},	"Breakout Case;"},C_PINK,6,	""	},
{ CSW_AK47, 1,	"AK47 | Red Skull "}, "red_skull_ak47.mdl"},	"Gamma 2 Case;"},C_PURPLE,	6,	""	},
{ CSW_AWP, 1,	"AWP | Asiimov "},  "Asiimov_awp.mdl"},	"Gamma Case;"},	C_RED,6,	""	},
{ CSW_AWP, 1,	"AWP | Colot "},   "kolot_awp.mdl"},	"Chroma 3 Case;"},C_BLUE,-1,	""	},
{ CSW_AWP, 1,	"AWP | Medusa "},   "medusa_awp.mdl"},	"Chroma 2 Case;"},C_PINK,-1,	""	},
{ CSW_AWP, 1,	"AWP | Unicornis "}, "unicornis_awp.mdl"},	"Huntsman Weapon;"},C_BLUE,6,	""	},
{ CSW_AWP, 1,	"AWP | Dragon King"},"v_awp_dragonking.mdl"},	"Breakout Case;"},C_PINK,-1,	""	},
{ CSW_AWP, 1,	"AWP | Dragon Lore"},"v_awp_dragonlore_v3.mdl"},";"},C_RED,6,	"Operation Phoenix;"	},
{ CSW_AWP, 1,	"AWP | Death Awp "}, "death_awp.mdl"},	"Chroma Case;"},	C_BLUE,6,	""	},
{ CSW_AWP, 1,	"AWP | HyperBeast "},   	"hyper_beast_awp.mdl"},	"Shadow Case;"},	C_RED,6,	""	},
{ CSW_AWP, 1,	"AWP | OceanShark "},   	"ocean_shark.mdl"},	"Falchion Case;"},C_BLUE,-1,	""	},
{ CSW_AWP, 1,	"AWP | Polip "}, "polip_awp.mdl"},	"Gamma Case;"},	C_BLUE,6,	""	},
{ CSW_AWP, 1,	"AWP | Silent Killer "},   	"silent_killer_awp.mdl"},"Gamma 2 Case;"},C_PURPLE,	6,	""	},
{ CSW_AWP, 1,	"AWP | Robin Hood "},	"robin_hood_awp.mdl"},	"Chroma 2 Case;"},C_RED,6,	""	},
{ CSW_AWP, 1,	"AWP | Revenant "},"revenant_awp.mdl"},	"Falchion Case;"},C_PURPLE,	-1,	""	},
{ CSW_AWP, 1,	"AWP | Lady "},  "lady_headshot.mdl"},	"Breakout Case;"},C_PURPLE,	6,	""	},
{ CSW_AWP, 1,	"AWP | Green Wolf "}, "green_wolf.mdl"},	"Breakout Case;"},C_PINK,6,	""	},
{ CSW_DEAGLE, 1,	"DEAGLE | Asiimov "}, "asiimov_deagle.mdl"},	"Gamma Case;"},	C_RED,6,	""	},
{ CSW_DEAGLE, 1,	"DEAGLE | Dragon Lore "}, 	"dragon_lore_deagle.mdl"},"Falchion Case;"},C_PURPLE,	6,	""	},
{ CSW_DEAGLE, 1,	"DEAGLE | Aligator "}, "alligator_deagle.mdl"},	"Chroma 2 Case;"},C_BLUE,-1,	""	},
{ CSW_DEAGLE, 1,	"DEAGLE | Anarchia "}, "anarhia_deagle.mdl"},	"Chroma Case;"},	C_PURPLE,	6,	""	},
{ CSW_DEAGLE, 1,	"DEAGLE | Ancient "}, "ancient_deagle.mdl"},	"Chroma 3 Case;"},C_PURPLE,	6,	""	},
{ CSW_DEAGLE, 1,	"DEAGLE | Toxicator "}, "toxicator.mdl"},	"Huntsman Case;"},C_RED,-1,	""	},
{ CSW_DEAGLE, 1,	"DEAGLE | Plasma "}, "plasma_deagle.mdl"},	"Gamma Case;"},	C_BLUE,-1,	""	},
{ CSW_DEAGLE, 1,	"DEAGLE | Red Asiimov "}, 	"red_asiimov_deagle.mdl"},"Gamma 2 Case;"},C_PINK,6,	""	},
{ CSW_DEAGLE, 1,	"DEAGLE | Sas "}, "sas_deagle.mdl"},	"Shadow Case;"},	C_BLUE,-1,	""	},
{ CSW_DEAGLE, 1,	"DEAGLE | Wolf "}, "wolf_deagle.mdl" ,	"Breakout Case;"},C_BLUE,6,	""	},
{ CSW_FAMAS, 1,	"FAMAS | Killer "}, "killer_bagoly_famas.mdl"},"Gamma 2 Case;"},C_RED,-1,	""	},
{ CSW_FAMAS, 1,	"FAMAS | MarbleFade "}, 	"marbelefade_famas.mdl"},"Falchion Case;"},C_PURPLE,	-1,	""	},
{ CSW_FAMAS, 1,	"FAMAS | Polip "},   "polip_famas.mdl"},	"Shadow Case;"},	C_PURPLE,	-1,	""	},
{ CSW_FAMAS, 1,	"FAMAS | Wolf "}, "wolf_famas.mdl"},	"Chroma 2 Case;"},C_BLUE,-1,	""	},
{ CSW_GALIL, 1,	"GALIL | HyperBeast "}, "hyperbeast_galil.mdl"},	"Huntsman Case;"},C_PINK,-1,	""	},
{ CSW_GALIL, 1,	"GALIL | Coup "}, "coup_galil.mdl"},	";"},C_RED,-1,	""	},
{ CSW_GALIL, 1,	"GALIL | Sirius "}, "sirius_galil.mdl"},	"Chroma Case;"},	C_RED,-1,	""	},
{ CSW_GALIL, 1,	"GALIL | Odyssy"},"v_galil_odyssy_v2.mdl"},"Chroma 3 Case;"},C_PINK,-1,	""	},
{ CSW_GLOCK18, 1,	"GLOCK | Blue Devil "}, "neptune_glock.mdl"},	";"},C_BLUE,-1,	""	},
{ CSW_GLOCK18, 0,	"GLOCK | Catacombs"},"v_glock_catacombs.mdl"},";"},C_PURPLE,	-1,	""	},
{ CSW_GLOCK18, 0,	"GLOCK | Neon Noir "}, "neonnoir_glock.mdl"},	";"},C_BLUE,-1,	""	},
{ CSW_GLOCK18, 1,	"GLOCK | Marauder "}, "empress.mdl"},"Huntsman Case;"},C_PINK,-1,	""	},
{ CSW_GLOCK18, 1,	"GLOCK | Hyper Beast "}, 	"hyperbeast_glock.mdl"},	"Shadow Case;"},	C_RED,-1,	""	},
{ CSW_M3, 1,	"M3 | Hyper Beast"},"v_m3_hyperbeast.mdl"},	"Breakout Case;"},C_RED,-1,	""	},
{ CSW_XM1014, 1,	"XM1014 | Quicksilver"},"v_xm1014_quicksilver.mdl"},"Chroma Case;"},	C_BLUE,-1,	""	},
{ CSW_M3, 0,	"M3 | Short"},	"v_m3_short.mdl"},	";"},C_PURPLE,	-1,	""	},
{ CSW_M3, 1,	"M3 | Koi"},	"v_m3_koi.mdl"},"Huntsman Case;"},C_PINK,-1,	""	},
{ CSW_MP5NAVY, 1,	"MP5 | Asiimov "}, "asiimov_mp5.mdl"},	"Breakout Case; Pumpkin Case (Special)"},C_PINK,-1,	""	},
{ CSW_MP5NAVY, 1,	"MP5 | Unicornis "}, "unicornis_mp5.mdl"},	"Chroma 3 Case;"},C_PURPLE,	-1,	""	},
{ CSW_AK47, 1,	"AK47 | Cartel"},"v_ak47_cartel.mdl"},	"Chroma Case;"},	C_PINK,-1,	""	},
{ CSW_MP5NAVY, 1,	"MP5 | Dual "}, 	"dual_mp5.mdl"},"Gamma Case;"},	C_RED,-1,	""	},
{ CSW_P90, 1,	"P90 | Grim"},	"v_p90_grim.mdl"},	"Chroma Case;"},	C_BLUE,-1,	""	},
{ CSW_P90, 1,	"P90 | Desert Warfare"},"v_p90_desertwarfare.mdl"},"Chroma 2 Case;"},C_BLUE,-1,	""	},
{ CSW_P90, 1,	"P90 | Monster"},"v_p90_monster_v3.mdl"},	"Gamma 2 Case;"},C_RED,-1,	""	},
{ CSW_P90, 1,	"P90 | Asiimov"},"v_p90_asiimov_v3.mdl"},	"Shadow Case;"},	C_PINK,-1,	""	},
{ CSW_P90, 1,	"P90 | Death by Kitty"},"v_p90_deathbykitty.mdl"},"Huntsman Case;"},C_PURPLE,	-1,	""	},
{ CSW_SCOUT, 1,	"SCOUT | HyperBeast "}, "hyper_beast_scout.mdl" ,"Chroma 3 Case;"},C_RED,-1,	""	},
{ CSW_SCOUT, 1,	"SCOUT | Crossbow "}, "crossbow.mdl"},"Chroma Case;"},	C_BLUE,-1,	""	},
{ CSW_SCOUT, 1,	"SCOUT | Esport "}, "esport_scout.mdl"},	"Falchion Case;"},C_RED,-1,	""	},
{ CSW_USP, 1,	"USP-S | Asiimov "}, "asimov_usp.mdl"},	"Gamma 2 Case;"},C_RED,-1,	""	},
{ CSW_USP, 1,	"USP-S | Jackel "}, "jackel_usp.mdl"},	"Falchion Case;"},C_BLUE,16,	""	},
{ CSW_USP, 1,	"USP-S | Lead Conduit"},"v_usp_leadconduit_v2.mdl"},"Chroma 3 Case;"},C_BLUE,-1,	""	},
{ CSW_USP, 0,	"USP-S | Immun"},"v_usp_immun.mdl"},	";"},C_BLUE,-1,	""	},
{ CSW_USP, 1,	"USP-S | Kill Confirmed"},	"v_usp_killconfirmed_v2.mdl"},"Shadow Case;"},	C_PINK,16,	""	},
{ CSW_USP, 1,	"USP-S | GreenWar "}, "green_war_usp.mdl"},"Breakout Case;"},C_BLUE,16,	""	},
{ CSW_USP, 1,	"USP-S | Draco "}, "draco_usp.mdl"},	"Huntsman Case; Pumpkin Case (Special);"},C_PURPLE,	-1,	""	},
{ CSW_USP, 1,	"USP-S | Death "}, "death_usp.mdl"},	"Chroma Case;"},	C_BLUE,16,	""	},
{ CSW_USP, 1,	"USP-S | Blue "}, "blue_usp.mdl"},"Gamma Case; Pumpkin Case (Special);"},	C_PURPLE,	16,	""	},
{ CSW_M4A1, 1,	"M4A1 | Asiimov "}, "asiimov_m4a1.mdl"},	"Gamma Case;"},	C_RED,-1,	""	},
{ CSW_M4A1, 1,	"M4A1 | Winterboss "}, "winterboss_m4a1.mdl"},	"Chroma 3 Case;"},C_BLUE,-1,	""	},
{ CSW_M4A1, 1,	"M4A1-S | Cyrex"}, "v_m4a_cyrex_v2.mdl"},	"Chroma 2 Case;"},C_BLUE,-1,	""	},
{ CSW_M4A1, 1,	"M4A4-S | DragonKing "}, 	"dragonking_m4a1.mdl"},	"Breakout Case;"},C_PINK,-1,	""	},
{ CSW_M4A1, 1,	"M4A1-S | Basilisk"}, "v_m4a1_basilisk.mdl"},	"Falchion Case;"},C_BLUE,-1,	""	},
{ CSW_ELITE, 1,	"ELITES | Urban Shock"}, 	"v_elite_urbanshock.mdl"},"Chroma Case;"},	C_PURPLE,	-1,	""	},
{ CSW_M4A1, 1,	"M4A1-S | HyperBeast "}, 	"hyperbeast_m4a1.mdl"},	"Gamma 2 Case;"},C_RED,-1,	""	},
{ CSW_M4A1, 1,	"M4A1-S | Howl "}, "howl_m4a1.mdl"},	"Gamma Case;"},	C_BLUE,-1,	""	},
{ CSW_M4A1, 1,	"M4A4 | Poseidon"}, "v_m4a4_poseidon_v3.mdl"},"Huntsman Case;"},C_BLUE,-1,	""	},
{ CSW_M4A1, 1,	"M4A1-S | Vulcan "}, "vulcan_m4a1.mdl"},	"Chroma 3 Case;"},C_PURPLE,	-1,	""	},
{ CSW_M4A1, 0,	"M4A4-S | Virus "}, "virus_m4a1.mdl" ,	";"},C_BLUE,-1,	""	},
{ CSW_M4A1, 1,	"M4A1 | Superman "}, "superman_m4a1.mdl"},	"Chroma Case;"},	C_BLUE,-1,	""	},
{ CSW_KNIFE, 1,	"KNIFE | Gurst flip "}, "gurst_flip.mdl"},	"Gamma 2 Case;"},C_YELLOW,	-1,	""	},
{ CSW_KNIFE, 1,	"BAYONET | Asiimov"}, "v_knife_bayonet_asii.mdl"},"Gamma 2 Case;"},C_YELLOW,	-1,	""	},
{ CSW_KNIFE, 1,	"BUTTERFLY | Asiimov"},"v_knife_butterfly_asii.mdl"},"Gamma 2 Case;"},C_YELLOW,	-1,	""	},
{ CSW_KNIFE, 1,	"KNIFE | Lum1a butterfly "}, 	"lum1a_butterfly.mdl"},	"Gamma Case; Pumpkin Case (Special);"},	C_YELLOW,	-1,	""	},
{ CSW_KNIFE, 1,	"KNIFE | Machine Karambit "}, 	"machine_karambit.mdl"},	"Gamma Case; Pumpkin Case (Special);"},	C_YELLOW,	-1,	""	},
{ CSW_KNIFE, 1,	"KNIFE | NeoAssassin Butterfly "}, "neoassasin_butterfly.mdl"},"Gamma Case; Pumpkin Case (Special);"},	C_YELLOW,	-1,	""	},
{ CSW_KNIFE, 1,	"KNIFE | Ocassion "}, "ocassion_karambit.mdl"},"Gamma Case; Pumpkin Case (Special);"},	C_YELLOW,	-1,	""	},
{ CSW_KNIFE, 1,	"KNIFE | Ork "}, "ork.mdl"},";"},C_YELLOW,	-1,	""	},
{ CSW_KNIFE, 1,	"KNIFE | Purpy Yellow Huntsman "}, "purpyellow_hunstman.mdl"},"Shadow Case;"},	C_YELLOW,	-1,	""	},
{ CSW_KNIFE, 1,	"KNIFE | Scifi Karambit "}, 	"scifi_karambit.mdl"},	"Shadow Case;"},	C_YELLOW,	-1,	""	},
{ CSW_KNIFE, 1,	"KARAMBIT | Doppler S"}, 	"v_knife_karambit_dopler_v2.mdl"},	"Shadow Case;"},	C_YELLOW,	-1,	""	},
{ CSW_KNIFE, 1,	"KNIFE | Sapphire Death Huntsman "}, "saphiredeath_hunstman.mdl"},	"Breakout Case;"},C_YELLOW,	-1,	""	},
{ CSW_KNIFE, 1,	"KNIFE | Sarex Karambit "},	 "sarex_karambit.mdl"},	"Breakout Case;"},C_YELLOW,	-1,	""	},
{ CSW_KNIFE, 1,	"FLIP | Fade"}, 	"v_knife_flip_fade_v2.mdl"},"Breakout Case;"},C_YELLOW,	-1,	""	},
{ CSW_KNIFE, 1,	"KNIFE | Shark Bayonet "}, 	"shark_bayonet.mdl"},	"Breakout Case;"},C_YELLOW,	-1,	""	},
{ CSW_KNIFE, 1,	"KNIFE | Skull Bayonet "}, 	"skull_bayonett.mdl"},	";"},C_YELLOW,	-1,	""	},
{ CSW_KNIFE, 1,	"KNIFE | Sport Karambit "}, 	"sport_karambit.mdl"},	"Huntsman Case;"},C_YELLOW,	-1,	""	},
{ CSW_KNIFE, 1,	"KARAMBIT | Lore"}, "v_knife_lorek.mdl"},	";"},C_YELLOW,	-1,	""	},
{ CSW_KNIFE, 1,	"GUT | Lore"}, 	"v_knife_gut_lore.mdl"},	"Chroma 3 Case;"},C_YELLOW,	-1,	""	},
{ CSW_KNIFE, 1,	"KNIFE | Vampire Gut "}, 	"vampire_gut.mdl"},	"Chroma 2 Case;"},C_YELLOW,	-1,	""	},
{ CSW_KNIFE, 1,	"KNIFE | Minecraft Fejsze "},	 "minecraft_fejsze.mdl"},"Chroma Case;"},	C_YELLOW,	-1,	""	},
{ CSW_AK47, 1,	"AK47 | Neon Revolution"},	"v_ak47_neonrev_v3.mdl"},"eSport Summer (2019) Case;"},	C_PINK,6,	""	},
{ CSW_AK47, 1,	"AK47 | Puma "}, "puma_ak47.mdl"},	"eSport Summer (2019) Case;"},	C_RED,6,	""	},
{ CSW_AWP, 1,	"AWP | Virus "},  "virus_awp.mdl"},	"eSport Summer (2019) Case;"},	C_PURPLE,	6,	""	},
{ CSW_AWP, 1,	"AWP | Warworg "}, "warworg_awp.mdl"},	"eSport Summer (2019) Case;"},	C_PINK,6,	"Operation Phoenix;"	},
{ CSW_DEAGLE, 1,	"DEAGLE | Color Sas"},"v_deagle_colorsas.mdl"},"eSport Summer (2019) Case;"},	C_BLUE,6,	""	},
{ CSW_USP, 1,	"USP-S | Neo-Noir"}, "v_usp_neonoir_v2.mdl"},	"eSport Summer (2019) Case;"},	C_BLUE,16,	""	},
{ CSW_M4A1, 1,	"M4A1 | Storm "}, "storm_m4a1.mdl" ,	"eSport Summer (2019) Case;"},	C_PURPLE,	14,	"Operation Phoenix;"	},
{ CSW_M4A1, 1,	"M4A1 | Spiritual "}, "spiritual_m4a1.mdl"},	"eSport Summer (2019) Case;"},	C_RED,14,	"Operation Phoenix;"	},
{ CSW_KNIFE, 1,	"BAYONET | Lore"}, "v_knife_bayonet_lore_v3.mdl"},"eSport Summer (2019) Case;"},	C_YELLOW,	8,	""	},
{ CSW_KNIFE, 1,	"KARAMBIT | Case Hardened"}, 	"v_knife_karambit_case_v3.mdl"},"eSport Summer (2019) Case;"},	C_YELLOW,	8,	""	},	
{ CSW_AK47, 1,	"AK47 | Asiimov"},"v_ak47_assimov_v2.mdl"},"Falchion Case;"},C_PURPLE,	6,	""	},
{ CSW_AK47, 1,	"AK47 | Psycho "}, "pszio_ak47.mdl"},	"Gamma Case;"},	C_RED,6,	""	},
{ CSW_AK47, 1,	"AK47 | Phantom "}, "phantom_ak47.mdl"},	"Chroma 2 Case;"},C_BLUE,6,	""	},
{ CSW_AK47, 1,	"AK47 | Pantera "}, "pantera_ak47.mdl"},	"Huntsman Case;"},C_PINK,6,	""	},
{ CSW_AK47, 0,	"AK47 | Palladin "}, "palladin_ak47.mdl"},	";"},C_BLUE,6,	""	},
{ CSW_AK47, 1,	"AK47 | Neptune "}, "neptune_ak47.mdl"},	"Shadow Case;"},	C_RED,6,	""	},
{ CSW_AWP, 1,	"AWP | Cryex"},	"v_awp_cyrex_v2.mdl"},	"Chroma 2 Case;"},C_BLUE,-1,	""	},
{ CSW_AWP, 1,	"AWP | Lighting Strike"},	"v_awp_lightingstrike.mdl"},";"},C_PURPLE,	6,	""	},
{ CSW_USP, 1,	"USP-S | HyperBeast "},"hyperbeast_usp.mdl"},	"Huntsman Case;"},C_PINK,16,	""	},
{ CSW_M4A1, 1,	"M4A1-S | Reborg "}, "reborg_m4a1.mdl"},	"Chroma 3 Case;"},C_BLUE,14,	""	},
{ CSW_M4A1, 1,	"M4A1 | Psycho "}, "pszio_m4a1.mdl"},	"Shadow Case;"},	C_RED,14,	""	},
{ CSW_M4A1, 0,	"M4A1-S | Toxicator "}, "toxicator_m4a1.mdl"},	";"},C_PINK,14,	""	},
{ CSW_M4A1, 0,	"M4A1 | Ultra Violette "},	"ultraviolett_m4a1.mdl"},	";"},C_BLUE,14,	""	},
{ CSW_KNIFE, 1,	"KARAMBIT | Hyper Beast"},	"v_knife_karambit_hyperb_v3.mdl"},	"Gamma 2 Case;"},C_YELLOW,	8,	""	},
{ CSW_KNIFE, 1,	"HUNTSMAN | Hyper Beast"},	"v_knife_huntsman_hyperb_v3.mdl"},	";"},C_YELLOW,	8,	""	},
{ CSW_KNIFE, 1,	"HUNTSMAN | Sapphire"}, "v_knife_huntsman_sapphire.mdl"},	";"},C_YELLOW,	8,	""	},
{ CSW_KNIFE, 1,	"KARAMBIT | Tiger Tooth"},	"v_knife_karambit_tiger_v2.mdl"},	"Chroma 3 Case;"},C_YELLOW,	8,	""	},
{ CSW_AK47, 1,	"AK47 | HyperBeast "}, "hyper_beast_ak47.mdl" ,"Hydra Case;"},	C_RED,6,	""	},
{ CSW_AK47, 1,	"AK47 | Cannibal "}, "cannibal_ak47.mdl" ,	"Hydra Case;"},	C_BLUE,6,	""	},
{ CSW_AWP, 1,	"AWP | Fever Dream"},"v_awp_feverdream_v2.mdl"},"Hydra Case;"},	C_PINK,6,	""	},
{ CSW_AWP, 1,	"AWP | Oni Taiji"},"v_awp_oni_v3.mdl"},	"Hydra Case;"},	C_PURPLE,	6,	""	},
{ CSW_M4A1, 1,	"M4A4-S | Dragon "}, "dragon_m4a1.mdl"},	"Hydra Case;"},	C_PINK,14,	""	},
{ CSW_M4A1, 1,	"M4A1 | Ghost "}, "ghost_m4a1.mdl"},	"Hydra Case;"},	C_PURPLE,	14,	""	},
{ CSW_USP, 1,	"USP-S | Laser"}, "v_usp_laser_v3.mdl"},	"Hydra Case;"},	C_BLUE,16,	""	},
{ CSW_KNIFE, 1,	"KARAMBIT | Alima"},"v_knife_karambit_alima_v3.mdl"},	"Hydra Case;"},	C_YELLOW,	8,	""	},
{ CSW_KNIFE, 1,	"BAYONET | Vampire"},"v_knife_bayonet_vamp.mdl"},"Hydra Case;"},	C_YELLOW,	8,	""	},
{ CSW_FIVESEVEN, 	1,	"FIVESEVEN | Monkey Business"},	"v_fiveseven_banana_v3.mdl"},"eSport Winter (2019) Case;"},	C_PINK,-1,	"Operation Phoenix;"	},
{ CSW_FIVESEVEN, 	1,	"FIVESEVEN | Triumviratus"},	"v_fiveseven_trum_v3.mdl"},"eSport Winter (2019) Case;"},	C_BLUE,-1,	""	},
{ CSW_P228,	 	1,	"P228 | Asiimov"},"v_p228_asii_v3.mdl"},	"eSport Winter (2019) Case;"},	C_PURPLE,	-1,	"Operation Phoenix;"	},
{ CSW_M4A1,	 	1,	"M4A1 | Godzilla "}, "godzilla_m4a1.mdl" ,	"eSport Winter (2019) Case;"},	C_RED,14,	"Operation Phoenix;"	},
{ CSW_AK47,	 	1,	"AK47 | Fuel Injector"},"v_ak47_fuel_v3.mdl"},	"eSport Winter (2019) Case;"},	C_PINK,6,	""	},
{ CSW_AK47,	 	1,"AK47 | GreenLine "}, 	"green_line_ak47.mdl" ,	"eSport Winter (2019) Case;"},	C_BLUE,6,	""	},
{ CSW_KNIFE, 1,	"KARAMBIT | Cyan Eagle"},	"v_knife_karambit_cyan_v3.mdl"},"eSport Winter (2019) Case;"},	C_YELLOW,	8,	""	},
{ CSW_AK47,	 	1,	"AK47 | Runner "},"runner_ak47.mdl" ,	"Clutch Case;"},	C_PURPLE,	6,	""	},
{ CSW_AK47,	 	1,	"AK47 | Storm "}, "storm_ak47.mdl"},	"Clutch Case;"},	C_PINK,6,	""	},
{ CSW_AK47,	 	1,	"AK47 | Acid "}, "acid_ak47.mdl"},	"Clutch Case;"},	C_BLUE,6,	""	},
{ CSW_M4A1, 1,	"M4A4-S | Picasso "}, "picasso_m4a1.mdl"},	"Clutch Case;"},	C_RED,14,	""	},
{ CSW_AWP, 1,	"AWP | RedSkull"},"v_awp_redskull.mdl"},	 "Clutch Case;"},	C_PINK,6,	""	},
{ CSW_USP, 1,	"USP-S | Road Rash"}, "v_usp_roadrash_v2.mdl"},"Clutch Case;"},	C_PURPLE,	16,	""	},
{ CSW_KNIFE, 1,	"BAYONET | Vampire"},"v_knife_bayonet_vamp.mdl"},"Clutch Case;"},	C_YELLOW,	8,	""	},
{ CSW_KNIFE, 1,	"BAYONET | Lore"}, "v_knife_bayonet_lore_v3.mdl"},"Clutch Case;"},	C_YELLOW,	8,	""	},
{ CSW_KNIFE, 1,	"KARAMBIT | Cyan Eagle"},	"v_knife_karambit_cyan_v3.mdl"},"Clutch Case;"},	C_YELLOW,	8,	""	},
{ CSW_KNIFE, 1,	"BUTTERFLY | Case Harded"}, 	"v_knife_butterfly_case_v2.mdl"},	"Clutch Case;"},	C_YELLOW,	-1,	""	},
{ CSW_USP, 1,	"USP-S | Blueprint"}, "v_usp_blueprint.mdl"},	"Phoenix Case;"},C_BLUE,16,	""	},
{ CSW_M3, 1,	"M3 | Antique"}, "v_m3_antique.mdl"},	"Phoenix Case;"},C_BLUE,7,	""	},
{ CSW_MAC10, 1,	"MAC-10 | Heat"}, "v_mac10_heat.mdl"},	"Phoenix Case;"},C_BLUE,6,	""	},
{ CSW_FAMAS, 1,	"FAMAS | Asiimov "},  	"asiimov_famas.mdl"},	"Phoenix Case;"},C_BLUE,6,	""	},
{ CSW_P90, 1,	"P90 | Trigon"}, "v_p90_trigon.mdl"},	"Phoenix Case;"},C_PURPLE,	6,	""	},
{ CSW_DEAGLE, 1,	"DEAGLE | Directive"}, "v_deagle_directive.mdl"},"Phoenix Case;"},C_PURPLE,	6,	""	},
{ CSW_DEAGLE, 1,	"DEAGLE | Conspiracy"}, "v_deagle_conspiracy.mdl"},"Phoenix Case;"},C_PINK,6,	""	},
{ CSW_AWP, 1,	"AWP | Mortis"}, "v_awp_mortis_v4.mdl"},	"Phoenix Case;"},C_PINK,6,	""	},
{ CSW_AK47, 1,	"AK47 | The Empress"}, "v_ak47_empress.mdl"},	"Phoenix Case;"},C_RED,6,	""	},
{ CSW_KNIFE, 1,	"KNIFE | Butterfly Lite "},	"lite_butterfly.mdl"},	"Phoenix Case;"},C_YELLOW,	8,	""	},
{ CSW_KNIFE, 1,	"BAYONET | Gamma"}, "v_knife_bayonet_gamma.mdl"},"Phoenix Case;"},C_YELLOW,	8,	""	},
{ CSW_KNIFE, 1,	"FALCHION | Case Harded"}, 	"v_knife_falchion_case_v2.mdl"},"Chroma 2 Case;"},C_YELLOW,	8,	""	},
{ CSW_USP, 1,	"USP-S | Picasso "}, "picasso.mdl" ,"Chroma 2 Case;"},C_PURPLE,	16,	""	},
{ CSW_KNIFE, 1,	"FALCHION | Doppler"}, "v_knife_falchion_dopler_v2.mdl"},	"Falchion Case;"},C_YELLOW,	8,	""	},
{ CSW_KNIFE, 1,	"FALCHION | Marble Fade"}, 	"v_knife_falchion_marble_v2.mdl"},	"Falchion Case;"},C_ORANGE,	8,	""	},
{ CSW_KNIFE, 1,	"HUNTSMAN | Rust Coat"}, 	"v_knife_huntsman_rust.mdl"},"Huntsman Case;"},C_YELLOW,	8,	""	},
{ CSW_KNIFE, 1,	"STILETTO | Vanilla"}, "v_knife_stiletto.mdl"},	"Horizon Case;"},C_YELLOW,	8,	""	},
{ CSW_KNIFE, 1,	"NAVAJA | Vanilla"}, "v_knife_navaja.mdl"},	"Horizon Case;"},C_YELLOW,	8,	""	},
{ CSW_AK47, 1,	"AK47 | HyperBeast "}, "hyper_beast_ak47.mdl"},	"Horizon Case;"},C_RED,6,	""	},
{ CSW_DEAGLE, 1,	"DEAGLE | Code Red"}, "v_deagle_codered.mdl"},	"Horizon Case;"},C_RED,6,	""	},
{ CSW_M4A1, 1,	"M4A1 | Merlin "}, "merlin_m4a1.mdl"},	"Horizon Case;"},C_PINK,14,	""	},
{ CSW_ELITE, 1,	"ELITES | Royal Consort"}, 	"v_elite_royalconsort.mdl"},"Horizon Case;"},C_PURPLE,	-1,	""	},
{ CSW_M3, 1,	"M3 | Toy Soldier"}, "v_m3_toysoldier.mdl"},	"Horizon Case;"},C_PURPLE,	7,	""	},
{ CSW_FAMAS, 1,	"FAMAS | Color "},   "color_famas.mdl"},	"Horizon Case;"},C_BLUE,6,	""	},
{ CSW_P90, 1,	"P90 | Traction"}, "v_p90_traction.mdl"},	"Horizon Case;"},C_BLUE,6,	""	},
{ CSW_MP5NAVY, 1,	"MP5 | Neon "}, 	"neon_mp5.mdl"},"Horizon Case;"},C_BLUE,-1,	""	},
{ CSW_KNIFE, 1,	"NAVAJA | Crimson Web"}, 	"v_knife_navaja_crimson.mdl"},"Horizon Case; Pumpkin Case (Special);"},C_YELLOW,	8,	""	},
{ CSW_KNIFE, 1,	"NAVAJA | Boreal Forest"}, 	"v_knife_navaja_boreal.mdl"},"Horizon Case;"},C_YELLOW,	8,	""	},
{ CSW_KNIFE, 1,	"URSUS | Crimson Web"}, "v_knife_ursus_crimson.mdl"},"Pumpkin Case (Special);"},	C_YELLOW,	8,	""	},
{ CSW_M4A1, 1,	"M4A1 | Kinder "}, "kinder_m4a1.mdl"},	"Pumpkin Case (Special);"},	C_BLUE,-1,	""	},
{ CSW_GLOCK18, 1,	"GLOCK | Wasteland Rebel"},	"v_glock_wasteland.mdl"},"Pumpkin Case (Special);"},	C_RED,-1,	""	},
{ CSW_AWP, 1,	"AWP | Boom"}, 	"v_awp_boom.mdl"},	"Pumpkin Case (Special);"},	C_RED,6,	""	},
}

new const Music_Basic[][][] =
{
	{ "Ashes Remain | On My Own"}, 	"Remain.mp3"},
	{ "Bruno Mars | 24K Magic"}, 	"24KMagic.mp3"},
	{ "Imagine Dragons | Believer"}, "Believer.mp3"},
	{ "Axwell & Ingrosso | More Than You Know"},	"MoreThanYouKnow.mp3"	},
	{ "Rag'n'Bone Man | Human"}, 	"Human.mp3"},
	{ "AWOLNATION | SAIL"}, "SAIL.mp3"},
	{ "Glitch Mob | Seven Nation Army"}, "SevenNationArmy.mp3"	},
	{ "Sia | Move Your Body"}, 	"MoveYourBody.mp3"	},
	{ "Esterly | This Is My World"}, "ThisIsMyWorld.mp3"	},
	{ "Wiz Khalifa | See You Again"}, "SeeYouAgain.mp3"	}
}

new const Musics[][][] =
{
	{ "Eminem | Till I Collapse"}, 	1,	"eminem_tillicollapse.mp3"},
	{ "Fifth Harmony | Worth It"}, 	1,	"fifthharmony_worthit.mp3"},
	{ "Wiz Khalifa | Black & Yellow"}, 1,	"wizkhalifa_blackandyellow.mp3"},
	{ "Basslovers United | Drunken"}, 1,	"bassloversunited_drunken.mp3"},
	{ "Lost Frequencies & Netsky | Here With You"}, 	1,	"herewithyou.mp3"	},
	{ "Marshmello | Moving On"}, 	1,	"moving_on.mp3"},
	{ "Axwell & Ingrosso | More Than You Know"},	1,	"morethanyouknow.mp3"	},
	{ "Tristam | Flights"}, 1,	"tristam_flights.mp3"	},
	{ "Eminem | I'm not Afraid"}, 	1,	"eminem_imnotafraid.mp3"},
	{ "Luis Fonsi | Despacito"}, 	1,	"luis_despa.mp3"	},
	{ "Black Veil Brides | In The End"}, 1,	"bvb_intheend.mp3"	}
}

new const Types[][][] = 
{ 
	{ "50.0"}, 	"10 10 250"}, 	"50 50 250"	},
	{ "25.0"},	"100 0 250"}, 	"100 50 250"	},
	{ "15.0"},	"250 0 200"}, 	"250 50 200"	},
	{ "8.0"}, 	"250 10 10"}, 	"250 150 150"	},
	{ "2.0"},	"220 200 0"}, 	"220 200 100" 	},
	{ "0.0"},	"220 40 10"}, 	"255 100 0" 	}
}

new const Rangs[][][] =
{
	{ "UnRanked"}, 1 	},
	{ "Silver I"}, 10 	},
	{ "Silver II"}, 20 	},
	{ "Silver III"}, 	30 	},
	{ "Silver IV"}, 40 	},
	{ "Silver Elite"}, 	70 	},
	{ "Silver Elite Master"}, 100 	},
	{ "Gold Nova I"}, 	150 	},
	{ "Gold Nova II"}, 	200 	},
	{ "Gold Nova III"}, 	250 	},
	{ "Gold Nova Master"}, 	350	},
	{ "Master Guardian I"}, 	500	},
	{ "Master Guardian II"}, 650 	},
	{ "Master Guardian Elite"}, 900 	},
	{ "Distinguished Master Guardian"}, 	1500 	},
	{ "Legendary Eagle"}, 	2500 	},
	{ "Legendary Eagle Master"}, 5000 	},
	{ "Supreme Master First Class"}, 	10000 	},
	{ "The Global Elite"}, 	20000 	}
}

new const MultiLangCmds[][][] = 
{ 
	{ "cmdSearch"},"Piac_Nev"}, "Market_Name"},
	{ "cmdMaxAr"},"Piac_MaxAr"},"Market_MaxCost"	},
	{ "cmdMinAr"},"Piac_MinAr"},"Market_MinCost"	},
	{ "cmdOwner"},"Piac_Tulajdonos"},	"Market_Owner"},
	{ "cmdCost"},"Piac_Ar"},"Market_Cost"},
	{ "cmdTradeMoney"},	"Csere_Osszeg"},"Trade_Money"},
	{ "cmdAddName"},"Nevcedula_Szoveg"},	"Nametag_Text"},
	{ "cmdAddNameAgain"},	"Nevcedula_Szoveg_Ujra"},"Nametag_TextAgain"	}
}

new Handle:g_SqlTuple;

new g_WrongCase[sizeof Cases];

new Array: g_Items, Array: g_UserIDs, Array: g_Achvs, Array: g_UserRanks;

enum _:ItemData
{
	wd_item,
	wd_sub,
	wd_owner,
	wd_added,
	wd_traded,
	wd_new,
	wd_market,
	wd_stattrak,
	wd_stattrak_value,
	wd_market_added,
	wd_market_adder[32],
	Float: wd_market_cost,
	wd_toucher[32],
	wd_trade,
	wd_id,
	wd_inuse,
	wd_name[32]
};

enum _:AchvData
{
	ad_reward,
	ad_target,
	ad_name_hu[64],
	ad_name_hu_latin1[64]
};

new Message[191], Found[5], g_UtolsoUzenet[33][191], g_Enabled[1], g_Top[3], g_GlobalArraySize;

new g_Selected[33][33], g_Picked[33][33], g_Option[33][6], g_Item[33], g_Purchase[64][3];
new g_Music[33], g_Guns[33], g_Awp_Count[2], g_Elso[33], g_Utolso[33], g_Best[3];
new g_Blocked[33], g_Page[33], g_FirstHud[33], g_Search[33][6], g_SearchName[33][32];
new g_MsgSync[3], g_Click[33], g_ClickEffect[33][7][2], g_Rang[33][2], g_BlockedMenu[33];
new g_Admin[33][2], g_Trade[33], g_ListMode[33], g_Ready[33], g_rwTCash[33], g_DamageStop[33];
new g_Achievements[33][37], g_NameTag[33][32], g_NameTagAgain[33][32], g_FullLoad[33];
new g_BombDefusing, g_RoundStart, g_KillCounter[33], g_BombPlanted, g_TeamChanged;
new g_Developer[33], g_Coin[33], g_Xp[33], g_Lv[33], g_OPSt[33][3], g_LastClip[33], g_MapName[32];
new g_CountedKillsThisRound[33], g_MusicKit[33], g_Stats[33][12], g_iLastAnim[33], g_M4A1_Clip[33];
new g_M4A1[33], g_Event[33][1], g_iDeleteAll[33], g_iFragPlaces[33][3];

new Float: g_Money[33], Float: g_MarketCost[33], Float: g_SearchCost[33][2];
new Float: g_TradeMoney[33];

public plugin_init()
{
	register_plugin("Global Offensive Final"}, "2.0.0"}, "JohanCorn");
	
	new y, m, d; date(y, m, d);
	
	if ( y != 2019 )
set_fail_state("Trial Expired!");
	
	do_check_structure();
	
	register_dictionary("jc_global_offensive_final.txt");
	register_dictionary("fgo.txt");
	
	for (new i; i < sizeof WEAPONENTNAMES; i++)
	{
if (WEAPONENTNAMES[i][0])
	RegisterHam(Ham_Item_Deploy, WEAPONENTNAMES[i], "fw_Item_Deploy_Post"}, 1);
	}
	
	for (new i; i < sizeof WEAPONENTNAMES; i++)
	{
if (WEAPONENTNAMES[i][0])
	RegisterHam(Ham_Item_AddToPlayer, WEAPONENTNAMES[i], "fw_Item_AddToPlayer");
	}
	
	RegisterHam(Ham_Item_PostFrame, "weapon_m4a1"}, "fw_Item_PostFrame");	
	RegisterHam(Ham_Weapon_Reload, "weapon_m4a1"}, "fw_Weapon_Reload");
	RegisterHam(Ham_Weapon_Reload, "weapon_m4a1"}, "fw_Weapon_Reload_Post"}, 1);
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_m4a1" , "fw_Weapon_PrimaryAttack_Post" , 1);
	RegisterHam(Ham_Spawn, "player"}, "fw_Spawn_Post"}, 1);
	RegisterHam(Ham_TakeDamage, "player"}, "fw_TakeDamage");
	
	register_message(get_user_msgid("StatusIcon"), "msgStatusIcon");
	
	register_clcmd("say /fegyver"}, "cmdBuy");
	register_clcmd("say /guns"}, "cmdBuy");
	
	register_clcmd("say /rs"}, "cmdResetScore");
	register_clcmd("say /resetscore"}, "cmdResetScore");
	
	register_clcmd("say /rankstats"}, "cmdRankStats");
	register_clcmd("say /top15"}, "cmdTop15");
	register_clcmd("say /rank"}, "cmdRank");
	register_clcmd("say /frags"}, "cmdFrags");
	
	register_impulse(201, "cmdChooseteam");
	register_impulse(100, "cmdAnim");
	
	register_clcmd("chooseteam"}, "cmdChooseteam");
	register_clcmd("say"}, "hook_say");
	register_clcmd("say_team"}, "hook_teamsay");
	register_clcmd("buy"}, "cmdBuy2");
	
	for (new i; i < sizeof MultiLangCmds; i++)
	{
register_clcmd(MultiLangCmds[i][1], MultiLangCmds[i][0]);
register_clcmd(MultiLangCmds[i][2], MultiLangCmds[i][0]);
	}
	
	register_menu("Main Menu"}, MENU_MAIN_BUTTONS, "menu_main");
	register_menu("Option Menu"}, MENU_MAIN_BUTTONS, "menu_option");
	register_menu("Item Menu"}, MENU_MAIN_BUTTONS, "menu_item");
	register_menu("MarketT Menu"}, MENU_MAIN_BUTTONS, "menu_markett");
	register_menu("MarketI Menu"}, MENU_MAIN_BUTTONS, "menu_marketi");
	register_menu("CaseOpen Menu"}, MENU_MAIN_BUTTONS, "menu_caseopen");
	register_menu("Delete Menu"}, MENU_MAIN_BUTTONS, "menu_delete");
	register_menu("Shop Menu"}, MENU_MAIN_BUTTONS, "menu_shop");
	register_menu("Trade Menu"}, MENU_MAIN_BUTTONS, "menu_trade");

	register_event("CurWeapon"}, "fw_CurWeapon"}, "be"}, "1=1");
	register_event("TextMsg"}, "fw_TextMsg"}, "a"}, "2=#Game_will_restart_in");
	register_event("TextMsg"}, "fw_TextMsg"}, "a"}, "2=#Game_Commencing");
	register_event("SendAudio"}, "won_event_te" , "a"}, "2&%!MRAD_terwin");
	register_event("SendAudio"}, "won_event_ct"}, "a"}, "2&%!MRAD_ctwin");
	register_event("DeathMsg"}, "fw_Death"}, "a");
	register_event("HLTV"}, "fw_HLTV_StartR"}, "a"}, "1=0"}, "2=0");
	
	register_forward(FM_SetModel, "fw_SetModel");
	register_forward(FM_SetModel, "fw_SetModel_Post"}, 1);
	register_forward(FM_ClientUserInfoChanged, "fw_ClientUserInfoChanged");
	
	#if defined IS_HALLOWEEN_ENABLED
	
register_forward(FM_Touch, "fw_Touch");

	#endif
	
	set_task(1.0, "TaskOneSecond"}, .flags="b");
	set_task(45.0, "TaskQuarterToMinute"}, .flags="b");
	set_task(60.0, "TaskOneMinute"}, .flags="b");
	
	register_concmd("bbc_set_admin"}, "cmdSetAdmin");
	register_concmd("bbc_add_items"}, "cmdAddItems");
	
	g_MsgSync[0] = CreateHudSyncObj();
	g_MsgSync[1] = CreateHudSyncObj();
	g_MsgSync[2] = CreateHudSyncObj();
	
	tutorInit();
	
	get_mapname(g_MapName, charsmax(g_MapName));
}

public do_a_test(id)
{
	for ( new i; i < sizeof ( Cases ); i++ )
createItem(2, i, bbc_get_user_id(id), 0);
}

public fw_TakeDamage(victim, inflictor, attacker, Float:damage)
{
	if ( victim == attacker )
return;
	
	if ( !is_user_connected(attacker) || !is_user_connected(victim) )
return;

	g_Stats[attacker][6] += floatround(damage);

	native_bbc_set_user_achv(attacker, 9, native_bbc_get_user_achv(attacker, 9) + floatround(damage));
	native_bbc_set_user_achv(attacker, 10, native_bbc_get_user_achv(attacker, 10) + floatround(damage));

	if ( !g_DamageStop[attacker] )
return;

	if ( cs_get_user_team(attacker) != cs_get_user_team(victim) )
SetHamParamFloat(4, damage * 0.01);
}

public cmdAnim(id)
{
	if ( is_user_alive(id) && g_iLastAnim[id] + 2 < get_systime() )
	{
new Weapon, WeaponName[64]; 
	
if ( cs_get_user_weapon(id) == CSW_USP ) {
	
	get_weaponname(CSW_USP, WeaponName, charsmax(WeaponName) )
	Weapon = find_ent_by_owner(-1, WeaponName, id)
	SendWeaponAnim(id, cs_get_weapon_silen(Weapon) ? 16 : 17);
}
else if ( cs_get_user_weapon(id) == CSW_M4A1 ) {
	
	get_weaponname(CSW_M4A1, WeaponName, charsmax(WeaponName) )
	Weapon = find_ent_by_owner(-1, WeaponName, id)
	SendWeaponAnim(id, cs_get_weapon_silen(Weapon) ? 14 : 15);
}
else if ( cs_get_user_weapon(id) == CSW_KNIFE ) SendWeaponAnim(id, 8);
else if ( cs_get_user_weapon(id) == CSW_GLOCK18 ) SendWeaponAnim(id, 13);
else if ( cs_get_user_weapon(id) == CSW_P228 ) SendWeaponAnim(id, 7);
else if ( cs_get_user_weapon(id) == CSW_DEAGLE ) SendWeaponAnim(id, 6);
else if ( cs_get_user_weapon(id) == CSW_FIVESEVEN ) SendWeaponAnim(id, 6);
else if ( cs_get_user_weapon(id) == CSW_ELITE ) SendWeaponAnim(id, 16);
else if ( cs_get_user_weapon(id) == CSW_AK47 ) SendWeaponAnim(id, 6);
else if ( cs_get_user_weapon(id) == CSW_AWP ) SendWeaponAnim(id, 6);
else if ( cs_get_user_weapon(id) == CSW_M3 ) SendWeaponAnim(id, 7);
else if ( cs_get_user_weapon(id) == CSW_XM1014 ) SendWeaponAnim(id, 7);
else if ( cs_get_user_weapon(id) == CSW_FAMAS ) SendWeaponAnim(id, 6);
else if ( cs_get_user_weapon(id) == CSW_GALIL ) SendWeaponAnim(id, 6);
else if ( cs_get_user_weapon(id) == CSW_P90 ) SendWeaponAnim(id, 6);
else if ( cs_get_user_weapon(id) == CSW_MAC10 ) SendWeaponAnim(id, 6);
else if ( cs_get_user_weapon(id) == CSW_MP5NAVY ) SendWeaponAnim(id, 6);
else if ( cs_get_user_weapon(id) == CSW_SCOUT ) SendWeaponAnim(id, 5);

g_iLastAnim[id] = get_systime();

set_weapons_timeidle(id, cs_get_user_weapon(id), 4.0);
	}
	
	return PLUGIN_CONTINUE;
}

public cmdConvert(id, args[])
{
	new arg1[32];
	new arg2[32];

	argbreak(args, arg1, charsmax(arg1), arg2, charsmax(arg2));
	
	if ( g_rwTCash[id] )
	{
if ( str_to_num(arg1) == str_to_num(arg2) && arg1[0] && arg2[0] )
{
	new Float: NewMoney;
	
	if ( str_to_num(arg1) > g_rwTCash[id] )
	{
NewMoney = float(g_rwTCash[id] * 2);
client_printcolor(id, "%L"}, id, "T_CONVERT_FINISH"}, do_num_to_str(g_rwTCash[id]), NewMoney);
g_rwTCash[id] = 0;
	}
	else
	{
NewMoney = float(str_to_num(arg1) * 2);
g_rwTCash[id] -= str_to_num(arg1);
client_printcolor(id, "%L"}, id, "T_CONVERT_FINISH"}, do_num_to_str(str_to_num(arg1)), NewMoney);
	}
	
	g_Money[id] += NewMoney;
}
else
	client_printcolor(id, "%L"}, id, "T_CONVERT_FORM");
	}
	else
client_printcolor(id, "%L"}, id, "T_CONVERT_FAIL_NO");
}

public fw_HLTV_StartR()
{
	g_Awp_Count[0] = 0;
	g_Awp_Count[1] = 0;
	
	for ( new i; i < 33; i++ )
g_CountedKillsThisRound[i] = 0;
	
	new Ent;
	
	while((Ent = engfunc(EngFunc_FindEntityByString, Ent, "classname"}, "weapon_awp")))
	{
if ( is_user_connected(pev(Ent, pev_owner)) )
{
	if(cs_get_user_team(pev(Ent, pev_owner)) == CS_TEAM_CT)
g_Awp_Count[0] ++;
	else if(cs_get_user_team(pev(Ent, pev_owner)) == CS_TEAM_T)
g_Awp_Count[1] ++;
}
	}
	
	#if defined IS_HALLOWEEN_ENABLED
	
while((Ent = engfunc(EngFunc_FindEntityByString, Ent, "classname"}, "HalloweenPumpkin")))
	remove_entity(Ent);

	#endif
	
	g_RoundStart = get_systime();
	g_BombPlanted = 0;
}

public cmdAddItems(id) { 
	
	if ( g_Admin[id][0] >= 3 ) {

// for ( new i; i < sizeof Musics; i++ ) {
// 	
// 	createItem(4, i, bbc_get_user_id(id), 0);	// Minden Zenek�szlet
// 	createItem(4, i, bbc_get_user_id(id), 1);	// Minden Zenek�szlet (StatTrak*)
// }

for ( new i; i < sizeof Cases; i++ ) {
	
	createItem(2, i, bbc_get_user_id(id), 0);	// Minden L�da
	createItem(3, 0, bbc_get_user_id(id), 0);	// Minden L�d�hoz Kulcs
}

// for ( new i; i < 20; i++ ) {
// 	
// 	createItem(2, 14, bbc_get_user_id(id), 0);	// 20db Horizon Case
// }

// for ( new i; i < sizeof Weapons; i++ ) {
// 	
// 	createItem(1, i, bbc_get_user_id(id), 0);	// Minden Fegyver �s K�s
// 	createItem(1, i, bbc_get_user_id(id), 1);	// Minden Fegyver �s K�s (StatTrak*)
// }
	}
}

public cmdResetScore(id)
{
	if(!g_Enabled[0])
	{	
if(is_user_connected(id))
{
	cs_set_user_deaths(id, 0);
	set_user_frags(id, 0);
	cs_set_user_deaths(id, 0);
	set_user_frags(id, 0);
	
	client_printcolor(id, "%L"}, id, "T_RESET_SCORE");
}
	}
}

public plugin_natives()
{
	register_native("bbc_call_user_login"}, "native_bbc_call_user_login"}, 1);
	register_native("bbc_call_user_login_post"}, "native_bbc_call_user_login_post"}, 1);
	register_native("bbc_call_force_update"}, "native_bbc_call_force_update"}, 1);
	
	register_native("bbc_get_server_enabled"}, "native_bbc_get_server_enabled"}, 1);
	
	register_native("bbc_get_user_achv"}, "native_bbc_get_user_achv"}, 1);
	register_native("bbc_set_user_achv"}, "native_bbc_set_user_achv"}, 1);
	
	register_native("bbc_get_user_admin_lvl"}, "native_bbc_get_user_admin_lvl"}, 1);
}

public native_bbc_get_user_admin_lvl(id)
	return g_Admin[id][0];

public native_bbc_call_force_update(id)
	sql_update_user_to_account(id, 1);
	
public native_bbc_get_user_achv(id, achv)
	return g_Achievements[id][achv];
	
public native_bbc_set_user_achv(id, achv, amount)
{
	if ( g_Achievements[id][achv] < 100000000 )
	{
g_Achievements[id][achv] = amount;
cmdAchvEdit(id, achv);
	}
}

public cmdAchvEdit(id, achv)
{
	new Data[AchvData];
	ArrayGetArray(g_Achvs, achv, Data);
	
	if ( 100000000 > g_Achievements[id][achv] >= Data[ad_target] )
	{
static players[32], pnum, idx;
get_players(players, pnum, "ch");

new user_name[32];
get_user_name(id, user_name, charsmax(user_name));

for ( new i; i < pnum; i++ )
{
	idx = players[i];
	
	client_printcolor(idx, "%L"}, idx, "T_ACHV_UNLOCK"}, user_name, Data[ad_name_hu_latin1]);
}

g_Achievements[id][achv] = get_systime();
g_Money[id] += float(Data[ad_reward]);

client_cmd(id, "spk %s/%s"}, MainFolder, AchvUnlock);

tutorMake(id, TUTOR_GREEN, 5.0, "%L^n%s"}, id, "T_ACHV_UNLOCKED"}, Data[ad_name_hu]);

sql_update_user_to_account(id, 1);
	}
}

public plugin_precache()
{
	new String[128];
	
	#if defined IS_HALLOWEEN_ENABLED
	
formatex(String, charsmax(String), "models/%s/%s"}, MainFolder, GET_HALLOWEEN_PUMPKIN_MODEL_NAME);
precache_model(String);

	#endif
	
	for(new i; i < sizeof Guns; i++)
	{
formatex(String, charsmax(String), "models/%s/%s"}, MainFolder, Guns[i][4]);

if(Guns[i][4][0]) 
	precache_model(String);
	
if(Guns[i][4][0]) 
	precache_viewmodel_sound(String);
	}
	
	for(new i; i < sizeof Weapons; i++)
	{
formatex(String, charsmax(String), "models/%s/%s"}, MainFolder, Weapons[i][3]);

if(Weapons[i][1][0] && Weapons[i][3][0]) 
	precache_model(String);
	
if(Weapons[i][1][0] && Weapons[i][3][0]) 
	precache_viewmodel_sound(String);
	}
	
	for(new i; i < sizeof Musics; i++)
	{
formatex(String, charsmax(String), "sound/%s/%s"}, MainFolder, Musics[i][2]);

if(Musics[i][1][0] && Musics[i][2][0]) 
	precache_generic(String);
	}
	
	for(new i; i < sizeof Music_Basic; i++)
	{
formatex(String, charsmax(String), "sound/%s/%s"}, MainFolder, Music_Basic[i][1]);

if(Music_Basic[i][1][0]) 
	precache_generic(String);
	}
	
	formatex(String, charsmax(String), "%s/%s"}, MainFolder, YellowOpen);
	precache_sound(String);
	
	formatex(String, charsmax(String), "%s/%s"}, MainFolder, AchvUnlock);
	precache_sound(String);

	formatex(String, charsmax(String), "%s/%s"}, MainFolder, CashTune);
	precache_sound(String);
	
	formatex(String, charsmax(String), "models/%s/%s"}, MainFolder, GrenadeFlashbang);
	precache_model(String);
	
	formatex(String, charsmax(String), "models/%s/%s"}, MainFolder, GrenadeHegrenade);
	precache_model(String);
	
	formatex(String, charsmax(String), "models/%s/%s"}, MainFolder, BombC4);
	precache_model(String);
	
	formatex(String, charsmax(String), "models/%s/%s"}, MainFolder, BombBack);
	precache_model(String);
	
	formatex(String, charsmax(String), "models/%s/%s"}, MainFolder, KnifeTerrorist);
	precache_model(String);
	
	formatex(String, charsmax(String), "models/%s/%s"}, MainFolder, KnifeCTerrorist);
	precache_model(String);
	
	formatex(String, charsmax(String), "models/%s/%s"}, MainFolder, "v_m4a1_v3.mdl");
	precache_model(String);
	
	precache_generic("sound/rivals_wow1.mp3");
	precache_generic("sound/rivals_wow2.mp3");
	precache_generic("sound/rivals_wow4.mp3");
	precache_generic("sound/rivals_wow5.mp3");
	
	tutorPrecache();
}

public fw_TextMsg()
{
	for(new i; i < 33; i++)
g_Blocked[i] = 0;
	
	do_music(0);
}

public won_event_te()
{
	new iLeader, iScore;
	
	for ( new i; i < 33; i++ )
	{
if ( !is_user_connected(i) )
	continue;
	
if ( cs_get_user_team(i) != CS_TEAM_T )
	continue;
	
if ( !g_CountedKillsThisRound[i] )
	continue;

if ( iScore < g_CountedKillsThisRound[i] )
{
	iScore = g_CountedKillsThisRound[i];
	iLeader = i;
}	
	}
	
	g_Best[0] = iLeader;
	do_add_case();
	do_music(1);
	
	static players[32], pnum, idx;
	get_players(players, pnum, "chae"}, "TERRORIST");
	
	for ( new i; i < pnum; i++ )
	{
idx = players[i];
native_bbc_set_user_achv(idx, 7, native_bbc_get_user_achv(idx, 7) + 1);
native_bbc_set_user_achv(idx, 8, native_bbc_get_user_achv(idx, 8) + 1);
native_bbc_set_user_achv(idx, 12, native_bbc_get_user_achv(idx, 12) + 3250);

if ( equal(g_MapName, "css_dust2") || equal(g_MapName, "css_dust2_remake") || equal(g_MapName, "de_dust2_2006") ) 
	native_bbc_set_user_achv(idx, 30, native_bbc_get_user_achv(idx, 30) + 1);
	
if ( equal(g_MapName, "de_nuke") || equal(g_MapName, "css_nuke_winter") ) 
	native_bbc_set_user_achv(idx, 31, native_bbc_get_user_achv(idx, 31) + 1);
	
if ( equal(g_MapName, "de_inferno") || equal(g_MapName, "css_inferno") || equal(g_MapName, "de_inferno2010") ) 
	native_bbc_set_user_achv(idx, 32, native_bbc_get_user_achv(idx, 32) + 1);
	
if ( equal(g_MapName, "de_train") || equal(g_MapName, "css_train") ) 
	native_bbc_set_user_achv(idx, 33, native_bbc_get_user_achv(idx, 33) + 1);
	
if ( equal(g_MapName, "cs_office") || equal(g_MapName, "csg_office") ) 
	native_bbc_set_user_achv(idx, 34, native_bbc_get_user_achv(idx, 34) + 1);
	
if ( equal(g_MapName, "de_dust") || equal(g_MapName, "de_dust_csgo") ) 
	native_bbc_set_user_achv(idx, 35, native_bbc_get_user_achv(idx, 35) + 1);
	
if ( equal(g_MapName, "de_aztec") || equal(g_MapName, "css_aztec") ) 
	native_bbc_set_user_achv(idx, 36, native_bbc_get_user_achv(idx, 36) + 1);
	}
	
	do_team_change();
}

public won_event_ct()
{
	new iLeader, iScore;
	
	for ( new i; i < 33; i++ )
	{
if ( !is_user_connected(i) )
	continue;
	
if ( cs_get_user_team(i) != CS_TEAM_CT )
	continue;
	
if ( !g_CountedKillsThisRound[i] )
	continue;

if ( iScore < g_CountedKillsThisRound[i] )
{
	iScore = g_CountedKillsThisRound[i];
	iLeader = i;
}	
	}
	
	g_Best[0] = iLeader;
	do_add_case();
	do_music(2);
	
	static players[32], pnum, idx;
	get_players(players, pnum, "chae"}, "CT");
	
	for ( new i; i < pnum; i++ )
	{
idx = players[i];
native_bbc_set_user_achv(idx, 7, native_bbc_get_user_achv(idx, 7) + 1);
native_bbc_set_user_achv(idx, 8, native_bbc_get_user_achv(idx, 8) + 1);
native_bbc_set_user_achv(idx, 12, native_bbc_get_user_achv(idx, 12) + 3250);

if ( equal(g_MapName, "de_dust") || equal(g_MapName, "css_dust2") || equal(g_MapName, "css_dust2_remake") || equal(g_MapName, "de_dust2_2006") ) 
	native_bbc_set_user_achv(idx, 30, native_bbc_get_user_achv(idx, 30) + 1);
	}
	
	do_team_change();
}

public do_team_change()
{
	if ( !g_TeamChanged && get_gametime() >= 60*15 )
	{
g_TeamChanged = 1;

static players[32], pnum, idx;
get_players(players, pnum, "ch");

for ( new i; i < pnum; i++ )
{
	idx = players[i];

	if ( cs_get_user_team(idx) == CS_TEAM_CT )
cs_set_user_team(idx, CS_TEAM_T);
	else if ( cs_get_user_team(idx) == CS_TEAM_T )
cs_set_user_team(idx, CS_TEAM_CT);

	client_printcolor(idx, "%L"}, idx, "T_TEAM_CHANGE");
}
	}
}

public bomb_planted(planter)
{
	g_CountedKillsThisRound[planter] += 3;
}

public bomb_defused(defuser)
{
	g_CountedKillsThisRound[defuser] += 3;
}

public do_music(winner)
{
	static players[32], pnum, taskid;
	get_players(players, pnum, "ch");
	
	new ZeneOn, player_name[32], ZeneST = -1;
	
	if(!g_Best[0] || g_Music[g_Best[0]] == -100)
ZeneOn = random_num(0, sizeof Music_Basic-1);
	else
	{
new Data[ItemData];
ArrayGetArray(g_Items, g_Music[g_Best[0]], Data);

if ( Data[wd_stattrak] )
{
	Data[wd_stattrak_value] ++;
	ArraySetArray(g_Items, g_Music[g_Best[0]], Data);
	
	sql_update_row_item(g_Music[g_Best[0]], 3);
}

ZeneOn = Data[wd_sub];

if ( Data[wd_stattrak] )
	ZeneST = Data[wd_stattrak_value]
	}	
	
	for(new i; i < pnum; i++)
	{
taskid = players[i];

if(is_user_connected(taskid) && g_Option[taskid][3])
{
	if(!g_Best[0])
	{
client_printcolor(taskid, "%L:$4! %s"}, taskid, "T_UNDERPLAY"}, Music_Basic[ZeneOn][0]);
client_cmd(taskid, "mp3 play sound/%s/%s"}, MainFolder, Music_Basic[ZeneOn][1]);
	}
	else if(g_Music[g_Best[0]] == -100)
	{
get_user_name(g_Best[0], player_name, charsmax(player_name));
client_printcolor(taskid, "%L:$4! %s"}, taskid, "T_PLAYERNON"}, player_name, Music_Basic[ZeneOn][0]);
client_cmd(taskid, "mp3 play sound/%s/%s"}, MainFolder, Music_Basic[ZeneOn][1]);
	}
	else
	{
get_user_name(g_Best[0], player_name, charsmax(player_name));
client_printcolor(taskid, "%L:$4! %s"}, taskid, "T_PLAYERWIN"}, player_name, Musics[ZeneOn][0]);
client_cmd(taskid, "mp3 play sound/%s/%s"}, MainFolder, Musics[ZeneOn][2]);
	}
}

if ( winner == 1 )
	set_dhudmessage(255, 100, 25, -1.0, 0.05, 0, 0.0, 0.0, 5.0, 5.0);
else if ( winner == 2 )
	set_dhudmessage(25, 100, 255, -1.0, 0.05, 0, 0.0, 0.0, 5.0, 5.0);

if ( winner && g_Best[0] )
{
	if ( !g_Best[0] )
show_dhudmessage(taskid, "%L"}, taskid, winner == 1 ? "T_WINNER_T" : "T_WINNER_CT");	
	if ( ZeneST == -1 )
show_dhudmessage(taskid, "%L^n%L"}, taskid, winner == 1 ? "T_WINNER_T" : "T_WINNER_CT"}, taskid, "T_PLAYERMVP"}, player_name);
	else
show_dhudmessage(taskid, "%L^n%L^n%L"}, taskid, winner == 1 ? "T_WINNER_T" : "T_WINNER_CT"}, taskid, "T_PLAYERMVP"}, player_name, taskid, "T_PLAYERMVP_ST"}, ZeneST);
}
	}
	
	g_Best[0] = 0;
	g_Best[1] = 0;
	g_Best[2] = 0;
}

public createItem(Item, Sub, Owner, StatTrak)
{
	g_GlobalArraySize ++;
	
	new Data[ItemData];
	
	Data[wd_id] = g_GlobalArraySize;
	Data[wd_item] = Item;
	Data[wd_sub] = Sub;
	Data[wd_owner] = Owner;
	Data[wd_stattrak] = StatTrak;
	Data[wd_new] = 1;
	Data[wd_added] = get_systime();
	Data[wd_traded] = get_systime();
	
	ArrayPushArray(g_Items, Data);	
	
	sql_add_row_to_items(Item, Sub, Owner, StatTrak);
}

public client_putinserver(id)
{	
	for(new i; i < 33; i++)
	{
g_Selected[id][i] = -1;
g_Picked[id][i] = -1;
	}
	
	for ( new i; i < 12; i ++ )
g_Stats[id][i] = 0;
	
	g_Music[id] = -100;
	g_Blocked[id] = 0;
	g_Page[id] = 0;
	g_Money[id] = 0.0;
	g_Trade[id] = 0;
	g_rwTCash[id] = 0;
	g_FullLoad[id] = 0;
	g_Coin[id] = -1;
	g_MusicKit[id] = 0;
	g_Developer[id] = 0;
	g_Xp[id] = 0;
	g_Lv[id] = 0;
	g_OPSt[id][0] = 0;
	g_OPSt[id][1] = 0;
	g_OPSt[id][2] = 0;
	g_CountedKillsThisRound[id] = 0;
	g_iDeleteAll[id] = 0;
	g_iFragPlaces[id][0] = 0;
	g_iFragPlaces[id][1] = 1;
	g_iFragPlaces[id][2] = 2;
	
	do_name_control(id);
}

public cmdChooseteam(id)
{
	if (bbc_get_user_id(id))
	{
if(!g_BlockedMenu[id])
{
	g_ListMode[id] = 0;
	
	showMenu_Main(id);
	showMenu_Main(id);
	showMenu_Main(id);
}
	}
	
	return PLUGIN_HANDLED;
}

public cmdOwner(id)
{
	new Owner[16];
	read_args(Owner, 15);
	remove_quotes(Owner);
	
	if(equal(Owner, "") || equal(Owner, " "))
	{
g_Search[id][4] = 0;
showMenu_Search(id);
return PLUGIN_HANDLED;
	}
	
	g_Search[id][4] = str_to_num(Owner);
	showMenu_Search(id);
	
	return PLUGIN_CONTINUE;
}

public cmdCost(id)
{
	if ( !bbc_get_user_id(id) )
return PLUGIN_HANDLED;
	
	new Cost[11];
	read_args(Cost, 10);
	remove_quotes(Cost);
	
	if(equal(Cost, "") || equal(Cost, " "))
	{
showMenu_MarketT(id);
return PLUGIN_HANDLED;
	}
	
	g_MarketCost[id] = str_to_float(Cost);
	showMenu_MarketT(id);
	
	return PLUGIN_CONTINUE;
}

public cmdMaxAr(id)
{
	new Cost[11];
	read_args(Cost, 10);
	remove_quotes(Cost);
	
	if(equal(Cost, ""))
	{
g_SearchCost[id][0] == 0.0;
g_Search[id][2] = 0;
showMenu_Search(id);
return PLUGIN_HANDLED;
	}
	
	g_SearchCost[id][0] = str_to_float(Cost);
	g_Search[id][2] = 1;
	showMenu_Search(id);
	
	return PLUGIN_CONTINUE;
}

public cmdMinAr(id)
{
	new Cost[11];
	read_args(Cost, 10);
	remove_quotes(Cost);
	
	if(equal(Cost, ""))
	{
g_SearchCost[id][1] == 0.0;
g_Search[id][3] = 0;
showMenu_Search(id);
return PLUGIN_HANDLED;
	}
	
	g_SearchCost[id][1] = str_to_float(Cost);
	g_Search[id][3] = 1;
	showMenu_Search(id);
	
	return PLUGIN_CONTINUE;
}

public cmdSearch(id)
{
	new Name[33];
	read_args(Name, 32);
	remove_quotes(Name);
	
	copy(g_SearchName[id], 31, Name);
	showMenu_Search(id);
	
	return PLUGIN_CONTINUE;
}

public cmdAddName(id)
{
	if ( !bbc_get_user_id(id) )
return PLUGIN_HANDLED;
	
	new Name[32];
	read_args(Name, 31);
	remove_quotes(Name);
	
	copy(g_NameTag[id], 31, Name);
	client_printcolor(id, "%L"}, id, "T_NAMETAG_AGAIN");
	client_msgmode_w_lang(id, 7);
	
	return PLUGIN_CONTINUE;
}

public cmdAddNameAgain(id)
{
	new Name[32];
	read_args(Name, 31);
	remove_quotes(Name);
	
	copy(g_NameTagAgain[id], 31, Name);
	
	if ( equal(g_NameTag[id], g_NameTagAgain[id]) )
	{
new Data[ItemData], Tag;
ArrayGetArray(g_Items, g_Item[id], Data);
copy(Data[wd_name], sizeof(Data[wd_name]) - 1, g_NameTag[id]);
ArraySetArray(g_Items, g_Item[id], Data);

for ( new i; i < ArraySize(g_Items); i++ )
{
	ArrayGetArray(g_Items, i, Data);
	
	if ( Data[wd_owner] == bbc_get_user_id(id) )
if ( Data[wd_item] == 5 )
	if ( !Data[wd_market] )
Tag = i;
}

ArrayGetArray(g_Items, Tag, Data);
Data[wd_item] = 0;
ArraySetArray(g_Items, Tag, Data);

sql_update_row_item(g_Item[id], 7);
sql_update_row_item(Tag, 4);

client_printcolor(id, "%L"}, id, "T_NAMETAG_ADDED"}, g_NameTag[id]);
	}	
	else
client_printcolor(id, "%L"}, id, "T_NAMETAG_NOCORR");

	showMenu_Item(id);
	
	return PLUGIN_CONTINUE;
}

public cmdBuy(id) {
	
	if ( cs_get_user_buyzone(id) ) {
	
g_Guns[id] = 1;
showMenu_Guns(id);
	}
}

public fw_Spawn_Post(id)
{
	if ( !is_user_bot(id) && is_user_connected(id) ) {	

strip_user_weapons(id);
give_item(id, "weapon_knife");

new Ip[32], State[3];
get_user_ip(id, Ip, charsmax(Ip), 1);
geoip_code2_ex(Ip, State);

if ( equal(State, "US") )
	server_cmd("kick #%i ^"I HOPE IT'S THAT ALL^""}, get_user_userid(id));

if(!g_Blocked[id])
{
	for(new i; i < 33; i++)
g_Picked[id][i] = g_Selected[id][i];
}

g_Picked[id][CSW_KNIFE] = g_Selected[id][CSW_KNIFE];

g_Blocked[id] = 1;
g_Guns[id] = 1;

for ( new i; i < sizeof Guns; i++ ) {
	
	if ( Guns[i][1][0] == -1 ) {

new Name[33];
get_weaponname(Guns[i][0][0], Name, 32);
give_item(id, Name);

if(Guns[i][0][0] != CSW_KNIFE)
	cs_set_user_bpammo(id, Guns[i][0][0], Guns[i][2][0]);
	}
}

if ( g_FullLoad[id] )
	showMenu_Guns(id);
	
set_task(0.5, "showMenu_Guns"}, id);

if(g_Option[id][2] == 1)
	g_Option[id][2] = 2;
else if(g_Option[id][2] == 3)
	g_Option[id][2] = 0;
	
give_item(id, "item_assaultsuit");
	
if(cs_get_user_team(id) == CS_TEAM_CT)
	give_item(id, "item_thighpack");
	
g_KillCounter[id] = 0;
g_LastClip[id] = -1;
	}
}

public fw_Death()
{
	new id = read_data(1);
	new victim = read_data(2);
	new hs = read_data(3);
	
	new Weapon[32];
	read_data(4, Weapon, charsmax(Weapon));
	
	g_Stats[victim][7] ++;
	g_Stats[victim][9] --;
	g_Stats[id][9] += 2;
	
	if ( id != victim && is_user_connected(id) && is_user_connected(victim) )
	{
#if defined IS_HALLOWEEN_ENABLED tutorMake

	if ( !(random_num(1,GET_HALLOWEEN_PUPKIN_DROP_CHANCE)-1) ) {
	
new iOrigin[3];
get_user_origin(victim, iOrigin, 0);

new Float:fOrigin[3];
IVecFVec(iOrigin, fOrigin);

do_create_ent_for_halloween(fOrigin);
	}
	
#endif

if ( cs_get_user_team(victim) == CS_TEAM_CT )
	g_Stats[id][0] ++;
else if ( cs_get_user_team(victim) == CS_TEAM_T )
	g_Stats[id][1] ++;

do_add_money(id, random_float(0.7, 0.99));
native_bbc_set_user_achv(id, 2, native_bbc_get_user_achv(id, 2) + 1);
native_bbc_set_user_achv(id, 3, native_bbc_get_user_achv(id, 3) + 1);

if ( g_BombDefusing == victim )
	native_bbc_set_user_achv(id, 4, native_bbc_get_user_achv(id, 4) + 1);
	
g_KillCounter[id] ++;
g_CountedKillsThisRound[id] ++;

new Data[ItemData], Tag;

g_Xp[id] ++;

if ( g_Xp[id] >= 80 )
{
	g_Lv[id] ++;
	
	if ( g_Lv[id] >= 40 )
	{
new Data[ItemData];

for ( new i; i < ArraySize(g_Items); i++ )
{
	ArrayGetArray(g_Items, i, Data);
	
	if ( Data[wd_owner] == bbc_get_user_id(id) )
if ( Data[wd_item] == 6 && Data[wd_sub] == 2 )
	Tag = i;
}

static players[32], pnum, idx;
get_players(players, pnum, "ch");

new user_name[32];
get_user_name(id, user_name, charsmax(user_name));

if ( Tag )
{
	ArrayGetArray(g_Items, Tag, Data);
	
	if ( Data[wd_stattrak_value] < 5 )
	{
Data[wd_stattrak_value] ++;
ArraySetArray(g_Items, Tag, Data);

sql_update_row_item(Tag, 3);

for ( new j; j < pnum; j++ )
{
	idx = players[j];

	client_printcolor(idx, "%L"}, idx, "T_MEDAL_YEAR_FINISH2"}, user_name, Coins[2][0], Data[wd_stattrak_value]+1);
}

new R[8], G[8], B[8];
	
if ( Data[wd_stattrak_value] == 1 )
{
	copy(R, charsmax(R), "150");
	copy(G, charsmax(G), "150");
	copy(B, charsmax(B), "150");
}
else
	parse(Types[Weapons[g_ClickEffect[id][3][0]][5][0]][2], R, charsmax(R), G, charsmax(G), B, charsmax(B));

message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("ScreenFade"), {0,0,0}, id);
write_short(1<<12);
write_short(1<<12);
write_short(0x0000);
write_byte(str_to_num(R));
write_byte(str_to_num(G));
write_byte(str_to_num(B));
write_byte(50);
message_end();
	}
}
else
{
	createItem(6, 2, bbc_get_user_id(id), 0);
	
	for ( new j; j < pnum; j++ )
	{
idx = players[j];
	
client_printcolor(idx, "%L"}, idx, "T_MEDAL_YEAR_FINISH"}, user_name, Coins[2][0]);
	}
}

g_Lv[id] = 1;
	}
	
	g_Xp[id] = 0;
}

new Found;

for(new m; m < ArraySize(g_Items); m++)
{
	ArrayGetArray(g_Items, m, Data);
 	
	if ( Data[wd_item] == 6 && Data[wd_sub] == 3 && Data[wd_owner] == bbc_get_user_id(id) )
Found = 1;
}

if ( Found )
{
	g_OPSt[id][0] ++;
	g_OPSt[id][2] += random_num(2,3);
	
	if ( hs )
g_OPSt[id][1] ++;
}

if ( g_OPSt[id][2] >= 100 )
{	
	do_operaton_drop(id);	
	g_OPSt[id][2] = 0;
}

if ( g_KillCounter[id] == 5 )
	native_bbc_set_user_achv(id, 11, native_bbc_get_user_achv(id, 11) + 1);
	
if ( hs )
{
	native_bbc_set_user_achv(id, 13, native_bbc_get_user_achv(id, 13) + 1);
}

new iClip, iAmmo;
get_user_weapon(id, iClip, iAmmo);	

if ( equal(Weapon, "awp") )
	native_bbc_set_user_achv(id, 14, native_bbc_get_user_achv(id, 14) + 1);
	
if ( equal(Weapon, "elite") )
	native_bbc_set_user_achv(id, 15, native_bbc_get_user_achv(id, 15) + 1);

if ( equal(Weapon, "knife") )
	native_bbc_set_user_achv(id, 16, native_bbc_get_user_achv(id, 16) + 1);
	
if ( get_user_health(id) == 1 )
	native_bbc_set_user_achv(id, 17, native_bbc_get_user_achv(id, 17) + 1);
	
if ( equal(Weapon, "elite") && get_user_weapon(victim) == CSW_ELITE )
	native_bbc_set_user_achv(id, 18, native_bbc_get_user_achv(id, 18) + 1);
	
if ( !(pev(id, pev_flags) & FL_ONGROUND) )
	native_bbc_set_user_achv(id, 19, native_bbc_get_user_achv(id, 19) + 1);
	
if ( !(pev(victim, pev_flags) & FL_ONGROUND) )
	native_bbc_set_user_achv(id, 20, native_bbc_get_user_achv(id, 20) + 1);
	
if ( equal(Weapon, "fiveseven") )
	native_bbc_set_user_achv(id, 21, native_bbc_get_user_achv(id, 21) + 1);
	
if ( is_user_connected(id) )
{
	if ( iClip == 1 && !equal(Weapon, "awp") && !equal(Weapon, "scout") )
native_bbc_set_user_achv(id, 22, native_bbc_get_user_achv(id, 22) + 1);
}

if ( equal(Weapon, "grenade") && !is_user_alive(id) )
	native_bbc_set_user_achv(id, 23, native_bbc_get_user_achv(id, 23) + 1);
	
if ( equal(Weapon, "deagle") )
	native_bbc_set_user_achv(id, 24, native_bbc_get_user_achv(id, 24) + 1);
	
if ( g_LastClip[id] == iClip )
	native_bbc_set_user_achv(id, 25, native_bbc_get_user_achv(id, 25) + 1);

g_LastClip[id] = iClip;

if ( equal(Weapon, "glock18") )
	native_bbc_set_user_achv(id, 26, native_bbc_get_user_achv(id, 26) + 1);
	
if ( equal(Weapon, "ak47") )
	native_bbc_set_user_achv(id, 27, native_bbc_get_user_achv(id, 27) + 1);
	
if ( equal(Weapon, "m4a1") )
	native_bbc_set_user_achv(id, 28, native_bbc_get_user_achv(id, 28) + 1);
	
if ( equal(Weapon, "usp") )
	native_bbc_set_user_achv(id, 29, native_bbc_get_user_achv(id, 29) + 1);
	


native_bbc_set_user_achv(id, 12, native_bbc_get_user_achv(id, 12) + 300);
	}
	
	g_Blocked[victim] = 0;
	
	if(is_user_connected(id))
	{
if(g_Picked[id][get_user_weapon(id)] > -1)
{
	new Data[ItemData];
	ArrayGetArray(g_Items, g_Picked[id][get_user_weapon(id)], Data);
	
	if(Data[wd_stattrak] && (Data[wd_owner] == bbc_get_user_id(id)))
	{
new szWeapon[20];
read_data(4, szWeapon, charsmax(szWeapon));

if(!equal(szWeapon, "grenade"))
{
	Data[wd_stattrak_value] ++;
	ArraySetArray(g_Items, g_Picked[id][get_user_weapon(id)], Data);
	sql_update_row_item(g_Picked[id][get_user_weapon(id)], 3);
}
	}
}
	}
	
	if(is_user_connected(id))
	{
if(cs_get_user_team(id) == CS_TEAM_CT)
	g_Best[1] = id;
else if(cs_get_user_team(id) == CS_TEAM_T)
	g_Best[2] = id;
	}
	
	if(g_Rang[id][1] < Rangs[sizeof Rangs-1][1][0])
g_Rang[id][1] ++;
	
	if(g_Rang[victim][1])
g_Rang[victim][1] --;
	
	if ( bbc_get_user_id(id) ) {
	
do_make_rank(id);
do_make_rank(victim);
	}
	
	return PLUGIN_CONTINUE;
}

public fw_Weapon_PrimaryAttack_Post(ent) {
	
	new owner, weaponid;
	
	owner = fm_cs_get_weapon_ent_owner(ent);
	weaponid = cs_get_weapon_id(ent);
	
	new Data[ItemData];

	if ( g_Picked[owner][CSW_M4A1] > -1 )
ArrayGetArray(g_Items, g_Picked[owner][CSW_M4A1], Data);
	
	if ( weaponid == CSW_M4A1 && ( g_Picked[owner][CSW_M4A1] == -1 || contain(Weapons[Data[wd_sub]][2], "M4A4") != -1 ) ) {

set_pdata_float(ent , 47 , 9999.0, 4);
	}
}

public fw_Item_Deploy_Post(ent) {
	
	new owner, weaponid;
	
	owner = fm_cs_get_weapon_ent_owner(ent);
	weaponid = cs_get_weapon_id(ent);
	
	if ( is_user_connected(owner) ) {
	
replace_weapon_models(owner, weaponid);

g_FirstHud[owner] = 0;
g_iLastAnim[owner] = get_systime();

new Data[ItemData];
	
if ( g_Picked[owner][CSW_M4A1] > -1 )
	ArrayGetArray(g_Items, g_Picked[owner][CSW_M4A1], Data);

if ( weaponid == CSW_M4A1 && ( g_Picked[owner][CSW_M4A1] == -1 || contain(Weapons[Data[wd_sub]][2], "M4A4") != -1 ) ) {
	
	set_pdata_float(ent , 47 , 9999.0, 4);
}
else if ( weaponid == CSW_M4A1 && ( g_Picked[owner][CSW_M4A1] == -2 || contain(Weapons[Data[wd_sub]][2], "-S") != -1 ) ) {
	
	SendWeaponAnim(owner, 5);
}
	}
}

replace_weapon_models(id, weaponid)
{
	if(g_Option[id][0] && !is_user_bot(id))
	{
new String[64];
	
if(g_Picked[id][weaponid] < 0)
{
	for(new i; i < sizeof Guns; i++)
	{
if ( weaponid == CSW_KNIFE ) {
	
	if ( cs_get_user_team(id) == CS_TEAM_CT )
formatex(String, charsmax(String), "models/%s/%s"}, MainFolder, KnifeCTerrorist);
	else
formatex(String, charsmax(String), "models/%s/%s"}, MainFolder, KnifeTerrorist);
	
	set_pev(id, pev_viewmodel2, String);
}
else if(Guns[i][0][0] == weaponid)
{
	if(Guns[i][4][0])
	{
if ( weaponid != CSW_M4A1 || g_Picked[id][weaponid] == -1 )
	formatex(String, charsmax(String), "models/%s/%s"}, MainFolder, Guns[i][4]);
else
	formatex(String, charsmax(String), "models/%s/%s"}, MainFolder, "v_m4a1_v3.mdl");

set_pev(id, pev_viewmodel2, String);
	}
}
	}
}
else
{
	new Data[ItemData];
	ArrayGetArray(g_Items, g_Picked[id][weaponid], Data);
	
	if(Data[wd_item] == 1)
	{
if(Weapons[Data[wd_sub]][0][0] == weaponid)
{
	if(Weapons[Data[wd_sub]][3][0])
	{
formatex(String, charsmax(String), "models/%s/%s"}, MainFolder, Weapons[Data[wd_sub]][3]);
set_pev(id, pev_viewmodel2, String);
	}
}
	}
}
	}
}

showMenu_Main(id)
{
	new Menu[512], Len, Contacted;
	
	for(new i; i < 33; i++)
	{
if(id == g_Trade[i])
	Contacted = 1;
	}
	
	// Men� l�trehoz�sa �s fel�p�t�se.

	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r%L\w |\y *pbT# Only D2\d Final\r *^n"}, id, "M_OUR_TEAM");
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "^n");
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\y1.\r{\y%L\r}^n"}, id, "M_WEAPONS");
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\y2.\r{\y%L\r}^n"}, id, "M_CASES_KEYS");
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\y3.\r{\y%L\r}^n"}, id, "M_MUSICS");
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\y4.\r{\y%L\r}^n"}, id, "M_MARKET");
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\y5.\r{\y%L\r}^n"}, id, "M_SHOP");
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\y6.\r{\y%L%s\r}^n"}, id, "M_TRADECENTER"}, Contacted && g_Option[id][4] ? "\r *!*" : "");
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\y7.\r{\y%L\r}^n"}, id, "M_ACHIEVEMENTS");
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\y8.\r{\y%L\r}^n"}, id, "M_OPTIONS");
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "^n");
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\y0.\w %L"}, id, "M_EXIT");
	
	// Men� befejez�se �s lez�r�sa.
	
	set_pdata_int(id, 205, 0);
	show_menu(id, MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6|MENU_KEY_7|MENU_KEY_8|MENU_KEY_0, Menu, -1, "Main Menu");
	
	return PLUGIN_HANDLED;
}

public menu_main(id, key)
{
	if (!is_user_connected(id))
return PLUGIN_HANDLED;

	g_Item[id] = -1;
	g_Page[id] = 0;
	
	if(!key) showMenu_Select(id);	
	else if(key == 1) showMenu_Cases(id);
	else if(key == 2) showMenu_Musics(id);
	else if(key == 3) showMenu_Market(id);
	else if(key == 4) showMenu_ShopList(id);
	else if(key == 5) showMenu_Trade(id);
	else if(key == 6) showMenu_Achievements(id);
	else if(key == 7) showMenu_Option(id);
	
	return PLUGIN_HANDLED;
}

showMenu_MarketT(id)
{
	new Float: Atlag, Menu[512], Len, All;
	
	// Kijel�lt fegyver bet�lt�se.
	
	new DataS[ItemData];
	ArrayGetArray(g_Items, g_Item[id], DataS);
	
	// Piacon l�v� azonos fegyverek �sszesz�ml�l�sa �s az �tlag�r kalkul�l�sa.
	
	for(new i; i < ArraySize(g_Items); i++)
	{
new Data[ItemData];
ArrayGetArray(g_Items, i, Data);

if(Data[wd_item] == DataS[wd_item])
{
	if(Data[wd_market])
	{
if(Data[wd_sub] == DataS[wd_sub])
{
	if(Data[wd_stattrak] == DataS[wd_stattrak])
	{
All ++;
Atlag += Data[wd_market_cost];
	}
}
	}
}
	}
	
	Atlag = Atlag/All;
	
	// Men� l�trehoz�sa �s fel�p�t�se.

	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r%L\w |\y %L\r *^n"}, id, "M_OUR_TEAM"}, id, "M_MARKET_PLACE");
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "^n");
	
	if(DataS[wd_item] == 2)
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\w%L:\r %s\d (%.2f%%)^n"}, id, "M_OBJECT"}, Cases[DataS[wd_sub]][0], str_to_float(Cases[wd_sub][1]));
	else if(DataS[wd_item] == 3)
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\w%L:\r %L^n"}, id, "M_OBJECT"}, id, "M_KEY");
	else if(DataS[wd_item] == 4)
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\w%L:\r %s^n"}, id, "M_OBJECT"}, Musics[DataS[wd_sub]][0]);
	else if(DataS[wd_item] == 5)
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\w%L:\r %L^n"}, id, "M_OBJECT"}, id, "M_NAMETAG");
	else if ( DataS[wd_item] == 7 )
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\w%L:\r %L%s^n"}, id, "M_VIEWED"}, id, "M_MUSIC_KIT_BOX"}, DataS[wd_stattrak] ? "\d (StatTrak*)" : "");
	else if(DataS[wd_stattrak])
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\w%L:\r %s\d (%L)^n"}, id, "M_OBJECT"}, Weapons[DataS[wd_sub]][2], id, "M_STATTRAK_TM");
	else
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\w%L:\r %s^n"}, id, "M_OBJECT"}, Weapons[DataS[wd_sub]][2]);

	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\w%L:\r %.2f Dollár\w | %L:\r %d%L^n"}, id, "M_ATLAG_COST"}, Atlag, id, "M_ON_MARKET"}, All, id, "M_PCS");
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\w%L:\r %.2f Dollár\w | %L:\r %.2f Dollár^n"}, id, "M_MY_COST"}, g_MarketCost[id], id, "M_FULL_COST"}, g_MarketCost[id]*MarketExtra);
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "^n");
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r1.\w %L^n"}, id, "M_SET_COST");
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r2.\w %L\d (%L!)^n"}, id, "M_PLACE"}, id, "M_PERM");
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "^n");
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r0.\w %L"}, id, "M_CANCEL");
	
	// Men� befejez�se �s lez�r�sa.
	
	set_pdata_int(id, 205, 0);
	show_menu(id, MENU_KEY_1|MENU_KEY_2|MENU_KEY_0, Menu, -1, "MarketT Menu");
	
	return PLUGIN_HANDLED;
}

public menu_markett(id, key)
{
	if(!is_user_connected(id))
return PLUGIN_HANDLED;
	
	if(!key)
	{
client_msgmode_w_lang(id, 4);
client_printcolor(id, "%L"}, id, "T_SET_COST");
	}
	else if(key == 1)
	{
if (g_MarketCost[id] < 0.5)
{
	showMenu_MarketT(id);
	client_printcolor(id, "%L"}, id, "T_MARKET_MIN");
}
else
{
	new Data[ItemData];
	ArrayGetArray(g_Items, g_Item[id], Data);
	
	if ( Data[wd_item] == 1 ) {
	
client_printcolor(id, "%L:$3! %s$1! |$4! %.2f Dollár$1! %L"}, id, "T_PLACED_ITEM"}, Weapons[Data[wd_sub]][2], g_MarketCost[id]*MarketExtra, id, "T_PLACED_COST");
log_to_file("fgo_market_add.log"}, "#%d | %i | %i | %i | %.2f | %s%s ^"%s^""}, bbc_get_user_id(id), Data[wd_item], Data[wd_sub], Data[wd_stattrak] ? Data[wd_stattrak_value] : -1, g_MarketCost[id]*MarketExtra, Weapons[Data[wd_sub]][2][0], Data[wd_stattrak] ? " (StatTrak*)" : ""}, Data[wd_name]);
	}
	else if ( Data[wd_item] == 2 ) {
	
client_printcolor(id, "%L:$3! %s$1! |$4! %.2f Dollár$1! %L"}, id, "T_PLACED_ITEM"}, Cases[Data[wd_sub]][0], g_MarketCost[id]*MarketExtra, id, "T_PLACED_COST");
log_to_file("fgo_market_add.log"}, "#%d | %i | %i | %.2f | %s"}, bbc_get_user_id(id), Data[wd_item], Data[wd_sub], g_MarketCost[id]*MarketExtra, Cases[Data[wd_sub]][0]);
	}
	else if ( Data[wd_item] == 3 ) {
	
client_printcolor(id, "%L:$3! %L$1! |$4! %.2f Dollár$1! %L"}, id, "T_PLACED_ITEM"}, id, "M_KEY"}, g_MarketCost[id]*MarketExtra, id, "T_PLACED_COST");
log_to_file("fgo_market_add.log"}, "#%d | %i | %i | %.2f | %s"}, bbc_get_user_id(id), Data[wd_item], Data[wd_sub], g_MarketCost[id]*MarketExtra, "Key");
	}
	else if ( Data[wd_item] == 4 ) {
	
client_printcolor(id, "%L:$3! %s$1! |$4! %.2f Dollár$1! %L"}, id, "T_PLACED_ITEM"}, Musics[Data[wd_sub]][0], g_MarketCost[id]*MarketExtra, id, "T_PLACED_COST");
log_to_file("fgo_market_add.log"}, "#%d | %i | %i | %i | %.2f | %s%s"}, bbc_get_user_id(id), Data[wd_item], Data[wd_sub], Data[wd_stattrak] ? Data[wd_stattrak_value] : -1, g_MarketCost[id]*MarketExtra, Musics[Data[wd_sub]][0], Data[wd_stattrak] ? " (StatTrak*)" : "");
	}
	else if ( Data[wd_item] == 5 ) {
	
client_printcolor(id, "%L:$3! %L$1! |$4! %.2f Dollár$1! %L"}, id, "T_PLACED_ITEM"}, id, "M_NAMETAG"}, g_MarketCost[id]*MarketExtra, id, "T_PLACED_COST");
log_to_file("fgo_market_add.log"}, "#%d | %i | %i | %.2f | %s"}, bbc_get_user_id(id), Data[wd_item], Data[wd_sub], g_MarketCost[id]*MarketExtra, "Name Tag");
	}
	else if ( Data[wd_item] == 7 ) {
	
client_printcolor(id, "%L:$3! %L$1! |$4! %.2f Dollár$1! %L"}, id, "T_PLACED_ITEM"}, id, "M_MUSIC_KIT_BOX"}, g_MarketCost[id]*MarketExtra, id, "T_PLACED_COST");
log_to_file("fgo_market_add.log"}, "#%d | %i | %i | %i | %.2f | %s%s"}, bbc_get_user_id(id), Data[wd_item], Data[wd_sub], Data[wd_stattrak] ? Data[wd_stattrak_value] : -1, g_MarketCost[id]*MarketExtra, "Music Kit Box"}, Data[wd_stattrak] ? " (StatTrak*)" : ""}, Data[wd_name]);
	}
	
	Data[wd_market] = 1;
	Data[wd_market_cost] = g_MarketCost[id]*MarketExtra;
	Data[wd_market_added] = get_systime();
	
	new player_name[32];
	get_user_name(id, player_name, charsmax(player_name));
	
	copy(Data[wd_market_adder], sizeof(Data[wd_market_adder]) - 1, player_name);
	ArraySetArray(g_Items, g_Item[id] , Data);
	
	sql_update_row_item(g_Item[id], 2);
	
	g_MarketCost[id] = 0.0;
}
	}
	else if(key == 9)
showMenu_Item(id);
	
	return PLUGIN_HANDLED;
}

showMenu_MarketI(id)
{
	new Menu[512], Len;
	
	// Kijel�lt fegyver bet�lt�se.
	
	new Data[ItemData];
	ArrayGetArray(g_Items, g_Item[id], Data);
	
	// Kihelyez�si d�tum konvert�l�sa.
	
	new Time[32];
	format_time(Time, charsmax(Time), "%Y-%m-%d %H:%M:%S"}, Data[wd_market_added]);
	
	// Men� l�trehoz�sa �s fel�p�t�se.

	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r%L\w |\y %L\r *^n"}, id, "M_OUR_TEAM"}, id, "M_MARKET");
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "^n");
	
	if(Data[wd_item] == 1)
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\w%L:\r %s%s^n"}, id, "M_VIEWED"}, Weapons[Data[wd_sub]][2], Data[wd_stattrak] ? "\d (StatTrak*)" : "");
	else if(Data[wd_item] == 2)
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\w%L:\r %s\d (%L: %.2f%%)^n"}, id, "M_VIEWED"}, Cases[Data[wd_sub]][0], id, "M_CHANCE"}, str_to_float(Cases[Data[wd_sub]][1]));
	else if(Data[wd_item] == 3)
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\w%L:\r %L^n"}, id, "M_VIEWED"}, id, "M_KEY"}, str_to_float(Cases[Data[wd_sub]][1]));	
	else if(Data[wd_item] == 4)
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\w%L:\r %s^n"}, id, "M_VIEWED"}, Musics[Data[wd_sub]][0]);	
	else if ( Data[wd_item] == 7 )
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\w%L:\r %L%s^n"}, id, "M_VIEWED"}, id, "M_MUSIC_KIT_BOX"}, Data[wd_stattrak] ? "\d (StatTrak*)" : "");
	
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\w%L:\r %s\d (#%d)^n"}, id, "M_SELLER"}, Data[wd_market_adder], Data[wd_owner]);
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\w%L:\r %s^n"}, id, "M_PLACED"}, Time);
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "^n");
	
	if(Data[wd_owner] == bbc_get_user_id(id))
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r1.\w %L^n"}, id, "M_PLACE_REM");
	else if(g_Money[id] >= Data[wd_market_cost])
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r1.\w %L\r |\y %.2f Dollár^n"}, id, "M_PURCHASE"}, Data[wd_market_cost]);
	else
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r1.\d %L\r |\y %.2f Dollár^n"}, id, "M_PURCHASE"}, Data[wd_market_cost]);

	Len += formatex(Menu[Len], charsmax(Menu) - Len, "^n");
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r0.\w %L"}, id, "M_BACK");
	
	// Men� befejez�se �s lez�r�sa.
	
	set_pdata_int(id, 205, 0);
	show_menu(id, MENU_KEY_0|MENU_KEY_1, Menu, -1, "MarketI Menu");
	
	return PLUGIN_HANDLED;
}

public menu_marketi(id, key)
{
	if (!is_user_connected(id))
return PLUGIN_HANDLED;

	if(!key)
	{
new Data[ItemData];
ArrayGetArray(g_Items, g_Item[id], Data);

if(Data[wd_owner] == bbc_get_user_id(id))
{
	if ( Data[wd_item] == 1 ) {
	
log_to_file("fgo_market_rem.log"}, "#%d | %i | %i | %i | %.2f | %s%s ^"%s^""}, bbc_get_user_id(id), Data[wd_item], Data[wd_sub], Data[wd_stattrak] ? Data[wd_stattrak_value] : -1, Data[wd_market_cost], Weapons[Data[wd_sub]][2][0], Data[wd_stattrak] ? " (StatTrak*)" : ""}, Data[wd_name]);
	}
	else if ( Data[wd_item] == 2 ) {
	
log_to_file("fgo_market_rem.log"}, "#%d | %i | %i | %.2f | %s"}, bbc_get_user_id(id), Data[wd_item], Data[wd_sub], Data[wd_market_cost], Cases[Data[wd_sub]][0]);
	}
	else if ( Data[wd_item] == 3 ) {
	
log_to_file("fgo_market_rem.log"}, "#%d | %i | %i | %.2f | %s"}, bbc_get_user_id(id), Data[wd_item], Data[wd_sub], Data[wd_market_cost], "Key");
	}
	else if ( Data[wd_item] == 4 ) {
	
log_to_file("fgo_market_rem.log"}, "#%d | %i | %i | %i | %.2f | %s%s"}, bbc_get_user_id(id), Data[wd_item], Data[wd_sub], Data[wd_stattrak] ? Data[wd_stattrak_value] : -1, Data[wd_market_cost], Musics[Data[wd_sub]][0], Data[wd_stattrak] ? " (StatTrak*)" : "");
	}
	else if ( Data[wd_item] == 5 ) {
	
log_to_file("fgo_market_rem.log"}, "#%d | %i | %i | %.2f | %s"}, bbc_get_user_id(id), Data[wd_item], Data[wd_sub], Data[wd_market_cost], "Name Tag");
	}
	else if ( Data[wd_item] == 7 ) {
	
log_to_file("fgo_market_rem.log"}, "#%d | %i | %i | %i | %.2f | %s%s"}, bbc_get_user_id(id), Data[wd_item], Data[wd_sub], Data[wd_stattrak] ? Data[wd_stattrak_value] : -1, Data[wd_market_cost], "Music Kit Box"}, Data[wd_stattrak] ? " (StatTrak*)" : ""}, Data[wd_name]);
	}
	
	new Data[ItemData];
	ArrayGetArray(g_Items, g_Item[id], Data);
	Data[wd_market] = 0;
	Data[wd_market_cost] = 0.0;
	Data[wd_market_added] = 0;
	Data[wd_stattrak_value] = 0;
	
	copy(Data[wd_market_adder], sizeof(Data[wd_market_adder]) - 1, "");
	ArraySetArray(g_Items, g_Item[id] , Data);
	
	client_printcolor(id, "%L"}, id, "T_MARKET_REM");
	showMenu_Market(id);
	
	sql_update_row_item(g_Item[id], 2);
}
else if ( g_Money[id] >= Data[wd_market_cost] ) {
	
	new Data[ItemData];
	ArrayGetArray(g_Items, g_Item[id], Data);
	
	if ( Data[wd_market] ) {

g_Money[id] -= Data[wd_market_cost];

sql_update_user_to_account(id, 1);

new players[32], Num, Tempid, Found;
get_players(players, Num, "ch")

for ( new i; i < Num; i++ ) {
	
	Tempid = players[i];
	
	if ( id != Tempid ) {

if ( bbc_get_user_id(Tempid) == Data[wd_owner] ) {
	
	g_Money[Tempid] += Data[wd_market_cost]/1.1;
	Found = 1;
	
	new client_name[32];
	get_user_name(id, client_name, charsmax(client_name));
	
	client_printcolor(Tempid, "%L"}, Tempid, "T_MARKET_SELL"}, client_name, Data[wd_market_cost]);
	
	sql_update_user_to_account(Tempid, 1);
}
	}
}
	
if ( !Found )
	sql_update_user_money(Data[wd_owner], Data[wd_market_cost]/1.1);
	
if ( Data[wd_item] == 1 ) {
	
	client_printcolor(id, "%L:$3! %s$1! |$4! %.2f Dollár$1! %L"}, id, "T_MARKET_BUY"}, Weapons[Data[wd_sub]][2], Data[wd_market_cost]*MarketExtra, id, "T_PLACED_COST");
	log_to_file("fgo_market_sell.log"}, "#%d | %i | %i | %i | %.2f | %s%s ^"%s^"%s"}, bbc_get_user_id(id), Data[wd_item], Data[wd_sub], Data[wd_stattrak] ? Data[wd_stattrak_value] : -1, Data[wd_market_cost], Weapons[Data[wd_sub]][2][0], Data[wd_stattrak] ? " (StatTrak*)" : ""}, Data[wd_name], Found ? " | - Paid!" : "");
}
else if ( Data[wd_item] == 2 ) {

	client_printcolor(id, "%L:$3! %s$1! |$4! %.2f Dollár$1! %L"}, id, "T_MARKET_BUY"}, Cases[Data[wd_sub]][0], Data[wd_market_cost]*MarketExtra, id, "T_PLACED_COST");
	log_to_file("fgo_market_sell.log"}, "#%d | %i | %i | %.2f | %s%s"}, bbc_get_user_id(id), Data[wd_item], Data[wd_sub], Data[wd_market_cost], Cases[Data[wd_sub]][0], Found ? " | - Paid!" : "");
}
else if ( Data[wd_item] == 3 ) {

	client_printcolor(id, "%L:$3! %L$1! |$4! %.2f Dollár$1! %L"}, id, "T_MARKET_BUY"}, id, "M_KEY"}, Data[wd_market_cost]*MarketExtra, id, "T_PLACED_COST");
	log_to_file("fgo_market_sell.log"}, "#%d | %i | %i | %.2f | %s%s"}, bbc_get_user_id(id), Data[wd_item], Data[wd_sub], Data[wd_market_cost], "Key"}, Found ? " | - Paid!" : "");
}
else if ( Data[wd_item] == 4 ) {

	client_printcolor(id, "%L:$3! %s$1! |$4! %.2f Dollár$1! %L"}, id, "T_MARKET_BUY"}, Musics[Data[wd_sub]][0], Data[wd_market_cost]*MarketExtra, id, "T_PLACED_COST");
	log_to_file("fgo_market_sell.log"}, "#%d | %i | %i | %i | %.2f | %s%s%s"}, bbc_get_user_id(id), Data[wd_item], Data[wd_sub], Data[wd_stattrak] ? Data[wd_stattrak_value] : -1, Data[wd_market_cost], Musics[Data[wd_sub]][0], Data[wd_stattrak] ? " (StatTrak*)" : ""}, Found ? " | - Paid!" : "");
}
else if ( Data[wd_item] == 5 ) {

	client_printcolor(id, "%L:$3! %L$1! |$4! %.2f Dollár$1! %L"}, id, "T_MARKET_BUY"}, id, "M_NAMETAG"}, Data[wd_market_cost]*MarketExtra, id, "T_PLACED_COST");
	log_to_file("fgo_market_sell.log"}, "#%d | %i | %i | %.2f | %s%s"}, bbc_get_user_id(id), Data[wd_item], Data[wd_sub], Data[wd_market_cost], "Name Tag"}, Found ? " | - Paid!" : "");
}
else if ( Data[wd_item] == 7 ) {

	client_printcolor(id, "%L:$3! %L$1! |$4! %.2f Dollár$1! %L"}, id, "T_MARKET_BUY"}, id, "M_MUSIC_KIT_BOX"}, Data[wd_market_cost]*MarketExtra, id, "T_PLACED_COST");
	log_to_file("fgo_market_sell.log"}, "#%d | %i | %i | %i | %.2f | %s%s%s"}, bbc_get_user_id(id), Data[wd_item], Data[wd_sub], Data[wd_stattrak] ? Data[wd_stattrak_value] : -1, Data[wd_market_cost], "Music Kit Box"}, Data[wd_stattrak] ? " (StatTrak*)" : ""}, Data[wd_name], Found ? " | - Paid!" : "");
}
	
copy(Data[wd_market_adder], sizeof(Data[wd_market_adder]) - 1, "");
	
Data[wd_owner] = bbc_get_user_id(id);
Data[wd_market] = 0;
Data[wd_market_cost] = 0.0;
Data[wd_market_added] = 0;
Data[wd_new] = 1;
Data[wd_stattrak_value] = 0;

ArraySetArray(g_Items, g_Item[id] , Data);
showMenu_Market(id);

sql_update_row_item(g_Item[id], 2);
	}
	else
client_printcolor(id, "%L"}, id, "T_MARKET_NOTA");
}
else {
	
	showMenu_MarketI(id);
	client_printcolor(id, "%L"}, id, "T_MARKET_CANT");
}
	}
	else if ( key == 9 )
showMenu_Market(id);
	
	return PLUGIN_HANDLED;
}

showMenu_Delete(id)
{
	new menu[512], len;

	len += formatex(menu[len], charsmax(menu) - len, "\r%L\w |\y %L\r *^n"}, id, "M_OUR_TEAM"}, id, "M_DELETENOW");
	len += formatex(menu[len], charsmax(menu) - len, "^n");
	
	new Data[ItemData];
	ArrayGetArray(g_Items, g_Item[id], Data);
	
	if ( !g_iDeleteAll[id] )
len += formatex(menu[len], charsmax(menu) - len, "\w%L^n"}, id, "M_DELETETEXT");
	else {

new DataS[ItemData], iCaseSum;

for ( new i; i < ArraySize(g_Items); i++ ) {

	ArrayGetArray(g_Items, i, DataS);
	
	if ( DataS[wd_owner] == bbc_get_user_id(id) ) {

if ( DataS[wd_item] == 2 && Data[wd_sub] == DataS[wd_sub] && !DataS[wd_market] ) {
	
	iCaseSum ++;
}
	}
}
	
len += formatex(menu[len], charsmax(menu) - len, "\w%L^n"}, id, "M_DELETETEXT2"}, Cases[Data[wd_sub]][0], iCaseSum);
	}
	
	len += formatex(menu[len], charsmax(menu) - len, "^n");
	len += formatex(menu[len], charsmax(menu) - len, "\r1.\w %L\d (%L!)^n"}, id, "M_YES"}, id, "M_PERM");
	len += formatex(menu[len], charsmax(menu) - len, "^n");
	len += formatex(menu[len], charsmax(menu) - len, "\r0.\w %L"}, id, "M_EXIT");
	
	set_pdata_int(id, 205, 0);
	show_menu(id, MENU_KEY_1|MENU_KEY_0, menu, -1, "Delete Menu");
	
	return PLUGIN_HANDLED;
}

public menu_delete(id, key) {
	
	if ( !is_user_connected(id) )
return PLUGIN_HANDLED;
	
	if ( !key ) {
	
if ( !g_iDeleteAll[id] ) {

	new Data[ItemData];
	ArrayGetArray(g_Items, g_Item[id], Data);
	
	if ( Data[wd_item] == 1 ) {
	
client_printcolor(id, "%L:$3! %s"}, id, "T_DELETED"}, Weapons[Data[wd_sub]][2]);
log_to_file("fgo_delete_item.log"}, "#%d | %i | %i | %i | %s%s ^"%s^""}, bbc_get_user_id(id), Data[wd_item], Data[wd_sub], Data[wd_stattrak] ? Data[wd_stattrak_value] : -1, Weapons[Data[wd_sub]][2][0], Data[wd_stattrak] ? " (StatTrak*)" : ""}, Data[wd_name]);
	}
	else if(Data[wd_item] == 2) {

client_printcolor(id, "%L:$3! %s"}, id, "T_DELETED"}, Cases[Data[wd_sub]][0]);
log_to_file("fgo_delete_item.log"}, "#%d | %i | %i | %s"}, bbc_get_user_id(id), Data[wd_item], Data[wd_sub], Cases[Data[wd_sub]][0]);
	}
	else if(Data[wd_item] == 3) {

client_printcolor(id, "%L:$3! %L"}, id, "T_DELETED"}, id, "M_KEY");
log_to_file("fgo_delete_item.log"}, "#%d | %i | %i | %s"}, bbc_get_user_id(id), Data[wd_item], Data[wd_sub], "Key");
	}
	else if(Data[wd_item] == 4) {
	
client_printcolor(id, "%L:$3! %s"}, id, "T_DELETED"}, Musics[Data[wd_sub]][0]);
log_to_file("fgo_market_add.log"}, "#%d | %i | %i | %i | %s%s"}, bbc_get_user_id(id), Data[wd_item], Data[wd_sub], Data[wd_stattrak] ? Data[wd_stattrak_value] : -1, Musics[Data[wd_sub]][0], Data[wd_stattrak] ? " (StatTrak*)" : "");
	}
	
	Data[wd_item] = 0;
	ArraySetArray(g_Items, g_Item[id], Data);
	
	sql_update_row_item(g_Item[id], 4);
}
else {
	
	new Data[ItemData], DataS[ItemData], iCaseSum;
	ArrayGetArray(g_Items, g_Item[id], Data);

	for ( new i; i < ArraySize(g_Items); i++ ) {

ArrayGetArray(g_Items, i, DataS);

if ( DataS[wd_owner] == bbc_get_user_id(id) ) {
	
	if ( DataS[wd_item] == 2 && Data[wd_sub] == DataS[wd_sub] && !DataS[wd_market] ) {

DataS[wd_item] = 0;
ArraySetArray(g_Items, i, DataS);
sql_update_row_item(i, 4);

iCaseSum ++;
	}
}
	}
	
	client_printcolor(id, "%L:$3! %s$1! (%i%L)"}, id, "T_DELETED"}, Cases[Data[wd_sub]][0], iCaseSum, id, "M_PCS");
	log_to_file("fgo_delete_item.log"}, "#%d | %i | %i | %s - ALL!"}, bbc_get_user_id(id), Data[wd_item], Data[wd_sub], Cases[Data[wd_sub]][0]);
}
	}
	else
showMenu_Item(id);
	
	return PLUGIN_HANDLED;
}

showMenu_Trade(id)
{
	new Name[32];
	get_user_name(g_Trade[id], Name, charsmax(Name));
	
	new Ready, All[2];
	new Data[ItemData];
	
	if(g_Trade[g_Trade[id]] == id)
Ready = 1;

	for(new i; i < ArraySize(g_Items); i++)
	{
ArrayGetArray(g_Items, i, Data);

if(Data[wd_owner] == bbc_get_user_id(id))
{
	if(Data[wd_trade])
All[0] ++;
}
else if(Data[wd_owner] == bbc_get_user_id(g_Trade[id]))
{
	if(Data[wd_trade])
All[1] ++;
}
	}
	
	new Menu[512], Len;

	Len += formatex(Menu[Len], charsmax(Menu), "\r%L\w |\y %L\r *^n"}, id, "M_OUR_TEAM"}, id, "M_TRADECENTER");
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "^n");
	
	if(g_Trade[id])
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r1.\w %L:\r %s\d (%L!)^n"}, id, "M_INVITED"}, Name, id, Ready ? "M_READY" : "M_WAITING");
	else
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r1.\w %L:\d -||-^n"}, id, "M_INVITED"}, Name);
	
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "^n");
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r2.\w %L\d (%d%L)\r +\y %.2f Dollár^n"}, id, "M_MYITEMS"}, All[0], id, "M_PCS"}, g_TradeMoney[id]);
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r3.%s %L\d (%d%L)\r +\y %.2f Dollár^n"}, !g_Trade[id] ? "\d" : "\w"}, id, "M_TRADEITEMS"}, All[1], id, "M_PCS"}, g_TradeMoney[g_Trade[id]]);
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "^n");
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r4.%s %L\d (%L!)^n"}, !g_Trade[id] ? "\d" : "\w"}, id, "M_ACCEPT"}, id, g_Ready[id] ? "M_READY" : "M_WAITING");
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r5.\w %L\d (%L!)^n"}, id, "M_REFUND"}, id, "M_PERM");
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "^n");
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r0.\w %L"}, id, "M_EXIT");
	
	set_pdata_int(id, 205, 0);
	show_menu(id, MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_0, Menu, -1, "Trade Menu");
	
	return PLUGIN_HANDLED;
}

public menu_trade(id, key)
{
	if (!is_user_connected(id))
return PLUGIN_HANDLED;
	
	if(!key)
	{
showMenu_Players(id);
	}
	if(key == 1)
	{
g_ListMode[id] = 1;
showMenu_List(id);
	}
	else if(key == 2)
	{
if(g_Trade[id])
{
	g_ListMode[id] = 2;
	showMenu_List(id);
}
else
{
	client_printcolor(id, "%L"}, id, "T_NOCLTRADE");
	showMenu_Trade(id);
}
	}
	else if ( key == 3 ) {

if ( g_Trade[id] ) {
	
	if ( !g_Ready[id] ) {

g_Ready[id] = 1;
showMenu_Trade(id);
client_printcolor(id, "%L"}, id, "T_INVACCEPT");
client_printcolor(g_Trade[id], "%L"}, g_Trade[id], "T_INVACCEPTO");
	}
	else {

g_Ready[id] = 0;
showMenu_Trade(id);
client_printcolor(id, "%L"}, id, "T_INVADENLI");
client_printcolor(g_Trade[id], "%L"}, g_Trade[id], "T_INVADENLIO");
	}
	
	if ( g_Ready[id] && g_Ready[g_Trade[id]] ) {

new Data[ItemData];

for ( new i; i < ArraySize(g_Items); i++ )
{
	ArrayGetArray(g_Items, i, Data);

	if ( Data[wd_owner] == bbc_get_user_id(id) && Data[wd_trade] ) {

Data[wd_owner] = bbc_get_user_id(g_Trade[id]);
Data[wd_trade] = 0;
ArraySetArray(g_Items, i, Data);

sql_update_row_item(i, 5);

if ( Data[wd_item] == 1 ) {
	
	log_to_file("fgo_trade.log"}, "#%d -> #%d | %i | %i | %i | %.2f | %s%s ^"%s^""}, bbc_get_user_id(id), bbc_get_user_id(g_Trade[id]), Data[wd_item], Data[wd_sub], Data[wd_stattrak] ? Data[wd_stattrak_value] : -1, g_MarketCost[id]*MarketExtra, Weapons[Data[wd_sub]][2][0], Data[wd_stattrak] ? " (StatTrak*)" : ""}, Data[wd_name]);
}
else if ( Data[wd_item] == 2 ) {

	log_to_file("fgo_trade.log"}, "#%d -> #%d | %i | %i | %.2f | %s"}, bbc_get_user_id(id), bbc_get_user_id(g_Trade[id]), Data[wd_item], Data[wd_sub], g_MarketCost[id]*MarketExtra, Cases[Data[wd_sub]][0]);
}
else if ( Data[wd_item] == 3 ) {

	log_to_file("fgo_trade.log"}, "#%d -> #%d | %i | %i | %.2f | %s"}, bbc_get_user_id(id), bbc_get_user_id(g_Trade[id]), Data[wd_item], Data[wd_sub], g_MarketCost[id]*MarketExtra, "Key");
}
else if ( Data[wd_item] == 4 ) {

	log_to_file("fgo_trade.log"}, "#%d -> #%d | %i | %i | %i | %.2f | %s%s"}, bbc_get_user_id(id), bbc_get_user_id(g_Trade[id]), Data[wd_item], Data[wd_sub], Data[wd_stattrak] ? Data[wd_stattrak_value] : -1, g_MarketCost[id]*MarketExtra, Musics[Data[wd_sub]][0], Data[wd_stattrak] ? " (StatTrak*)" : "");
}
else if ( Data[wd_item] == 5 ) {

	log_to_file("fgo_trade.log"}, "#%d -> #%d | %i | %i | %.2f | %s"}, bbc_get_user_id(id), bbc_get_user_id(g_Trade[id]), Data[wd_item], Data[wd_sub], g_MarketCost[id]*MarketExtra, "Name Tag");
}
else if ( Data[wd_item] == 7 ) {

	log_to_file("fgo_trade.log"}, "#%d -> #%d | %i | %i | %i | %.2f | %s%s"}, bbc_get_user_id(id), bbc_get_user_id(g_Trade[id]), Data[wd_item], Data[wd_sub], Data[wd_stattrak] ? Data[wd_stattrak_value] : -1, g_MarketCost[id]*MarketExtra, "Music Kit Box"}, Data[wd_stattrak] ? " (StatTrak*)" : ""}, Data[wd_name]);
}
	}
	else if ( Data[wd_owner] == bbc_get_user_id(g_Trade[id]) && Data[wd_trade] ) {

Data[wd_owner] = bbc_get_user_id(id);
Data[wd_trade] = 0;
ArraySetArray(g_Items, i, Data);

sql_update_row_item(i, 5);

if ( Data[wd_item] == 1 ) {
	
	log_to_file("fgo_trade.log"}, "#%d -> #%d | %i | %i | %i | %.2f | %s%s ^"%s^""}, bbc_get_user_id(g_Trade[id]), bbc_get_user_id(id), Data[wd_item], Data[wd_sub], Data[wd_stattrak] ? Data[wd_stattrak_value] : -1, g_MarketCost[id]*MarketExtra, Weapons[Data[wd_sub]][2][0], Data[wd_stattrak] ? " (StatTrak*)" : ""}, Data[wd_name]);
}
else if ( Data[wd_item] == 2 ) {

	log_to_file("fgo_trade.log"}, "#%d -> #%d | %i | %i | %.2f | %s"}, bbc_get_user_id(g_Trade[id]), bbc_get_user_id(id), Data[wd_item], Data[wd_sub], g_MarketCost[id]*MarketExtra, Cases[Data[wd_sub]][0]);
}
else if ( Data[wd_item] == 3 ) {

	log_to_file("fgo_trade.log"}, "#%d -> #%d | %i | %i | %.2f | %s"}, bbc_get_user_id(g_Trade[id]), bbc_get_user_id(id), Data[wd_item], Data[wd_sub], g_MarketCost[id]*MarketExtra, "Key");
}
else if ( Data[wd_item] == 4 ) {

	log_to_file("fgo_trade.log"}, "#%d -> #%d | %i | %i | %i | %.2f | %s%s"}, bbc_get_user_id(g_Trade[id]), bbc_get_user_id(id), Data[wd_item], Data[wd_sub], Data[wd_stattrak] ? Data[wd_stattrak_value] : -1, g_MarketCost[id]*MarketExtra, Musics[Data[wd_sub]][0], Data[wd_stattrak] ? " (StatTrak*)" : "");
}
else if ( Data[wd_item] == 5 ) {

	log_to_file("fgo_trade.log"}, "#%d -> #%d | %i | %i | %.2f | %s"}, bbc_get_user_id(g_Trade[id]), bbc_get_user_id(id), Data[wd_item], Data[wd_sub], g_MarketCost[id]*MarketExtra, "Name Tag");
}
else if ( Data[wd_item] == 7 ) {

	log_to_file("fgo_trade.log"}, "#%d -> #%d | %i | %i | %i | %.2f | %s%s"}, bbc_get_user_id(g_Trade[id]), bbc_get_user_id(id), Data[wd_item], Data[wd_sub], Data[wd_stattrak] ? Data[wd_stattrak_value] : -1, g_MarketCost[id]*MarketExtra, "Music Kit Box"}, Data[wd_stattrak] ? " (StatTrak*)" : ""}, Data[wd_name]);
}
	}
}

g_Money[id] += g_TradeMoney[g_Trade[id]];
g_Money[g_Trade[id]] += g_TradeMoney[id];

g_Money[id] -= g_TradeMoney[id];
g_Money[g_Trade[id]] -= g_TradeMoney[g_Trade[id]];

if ( g_TradeMoney[id] > 0.0 )
	log_to_file("fgo_trade.log"}, "#%d -> #%d | %.2f Dollár"}, bbc_get_user_id(id), bbc_get_user_id(g_Trade[id]), g_TradeMoney[id])

if ( g_TradeMoney[g_Trade[id]] > 0.0 )
	log_to_file("fgo_trade.log"}, "#%d -> #%d | %.2f Dollár"}, bbc_get_user_id(g_Trade[id]), bbc_get_user_id(id), g_TradeMoney[g_Trade[id]])

client_printcolor(id, "%L"}, id, "T_TRADE_FINISHED");
client_printcolor(g_Trade[id], "%L"}, g_Trade[id], "T_TRADE_FINISHED");

sql_update_user_to_account(id, 1);
sql_update_user_to_account(g_Trade[id], 1);

g_TradeMoney[id] = 0.0;
g_TradeMoney[g_Trade[id]] = 0.0;

g_Ready[id] = 0;
g_Ready[g_Trade[id]] = 0;

g_Trade[g_Trade[id]] = 0;
g_Trade[id] = 0;

showMenu_Trade(id);
	}
}
else
{
	client_printcolor(id, "%L"}, id, "T_NOCLTRADE");
	showMenu_Trade(id);
}
	}
	else if(key == 4)
	{
new Name[32];
get_user_name(id, Name, charsmax(Name));

if(g_Trade[id])
{
	client_printcolor(g_Trade[id], "%L"}, g_Trade[id], "T_INVTOTEND"}, Name);
	g_TradeMoney[g_Trade[id]] = 0.0;	
}

client_printcolor(id, "%L"}, id, "T_INVTOTENDME");

new Data[ItemData];

for(new i; i < ArraySize(g_Items); i++)
{
	ArrayGetArray(g_Items, i, Data);

	if(Data[wd_owner] == bbc_get_user_id(id) && Data[wd_trade])
	{
Data[wd_trade] = 0;
ArraySetArray(g_Items, i, Data);
	}
	
	if(id == g_Trade[g_Trade[id]])
	{
if(Data[wd_owner] == bbc_get_user_id(g_Trade[id]) && Data[wd_trade])
{
	Data[wd_trade] = 0;
	ArraySetArray(g_Items, i, Data);
}
	}
}

g_Ready[g_Trade[id]] = 0;
g_Ready[id] = 0;
g_TradeMoney[g_Trade[id]] = 0.0;
g_TradeMoney[id] = 0.0;
g_Trade[g_Trade[id]] = 0;
g_Trade[id] = 0;
	}
	else if ( key == 9 )
showMenu_Main(id);
	
	return PLUGIN_HANDLED;
}

showMenu_Option(id)
{
	new menu[512], len;

	len += formatex(menu[len], charsmax(menu), "\r%L\w |\y %L\r *^n"}, id, "M_OUR_TEAM"}, id, "M_OPTIONS");
	len += formatex(menu[len], charsmax(menu) - len, "^n");
	len += formatex(menu[len], charsmax(menu) - len, "\r1.\w %L^n"}, id, "M_LANG");
	len += formatex(menu[len], charsmax(menu) - len, "\r2.\w %L:\y %L^n"}, id, "M_OPT1"}, id, g_Option[id][0] ? "M_ON" : "M_OFF");
	len += formatex(menu[len], charsmax(menu) - len, "\r3.\w %L:\y %L^n"}, id, "M_OPT2"}, id, g_Option[id][1] ? "M_ON" : "M_OFF");
	
	if(!g_Option[id][2])
len += formatex(menu[len], charsmax(menu) - len, "\r4.\w %L:\y %L^n"}, id, "M_OPT3"}, id, "M_OFF");
	else if(g_Option[id][2] == 2)
len += formatex(menu[len], charsmax(menu) - len, "\r4.\w %L:\y %L^n"}, id, "M_OPT3"}, id, "M_ON");
	else
len += formatex(menu[len], charsmax(menu) - len, "\r4.\w %L:\y %L^n"}, id, "M_OPT3"}, id, "M_WAIT");

	len += formatex(menu[len], charsmax(menu) - len, "\r5.\w %L:\y %L^n"}, id, "M_OPT4"}, id, g_Option[id][3] ? "M_ON" : "M_OFF");
	len += formatex(menu[len], charsmax(menu) - len, "\r6.\w %L:\y %L^n"}, id, "M_OPT5"}, id, g_Option[id][4] ? "M_ON" : "M_OFF");
	len += formatex(menu[len], charsmax(menu) - len, "\r7.\w %L:\y %L^n"}, id, "M_OPT6"}, id, g_Option[id][5] ? "M_ON" : "M_OFF");
	
	len += formatex(menu[len], charsmax(menu) - len, "^n");
	len += formatex(menu[len], charsmax(menu) - len, "\r0.\w %L"}, id, "M_EXIT");
	
	set_pdata_int(id, 205, 0);
	show_menu(id, MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6|MENU_KEY_7|MENU_KEY_0, menu, -1, "Option Menu");
	
	return PLUGIN_HANDLED;
}

public menu_option(id, key)
{
	if (!is_user_connected(id))
return PLUGIN_HANDLED;
	
	if ( !key )
	{
new Nyelv[8];
get_user_info(id, "lang"}, Nyelv, charsmax(Nyelv));

if ( equal(Nyelv, "en") )
	set_user_info(id, "lang"}, "hu");
else
	set_user_info(id, "lang"}, "en");

client_printcolor(id, "%L"}, id, "T_LANGCHANGE");
showMenu_Option(id);
	}
	else if(key == 1)
	{
if(g_Option[id][0])
	g_Option[id][0] = 0;
else
	g_Option[id][0] = 1;

client_printcolor(id, "%L"}, id, g_Option[id][0] ? "T_BW_ON" : "T_BW_OFF");
showMenu_Option(id);
	}
	else if(key == 2)
	{
if(g_Option[id][1])
	g_Option[id][1] = 0;
else
	g_Option[id][1] = 1;

client_printcolor(id, "%L"}, id, g_Option[id][1] ? "T_BI_ON" : "T_BI_OFF");
showMenu_Option(id);
	}
	else if(key == 3)
	{
if(!g_Option[id][2])
{
	g_Option[id][2] = 1;
	client_printcolor(id, "%L"}, id, "T_MM_ON");
}
else if(g_Option[id][2] == 1)
{
	g_Option[id][2] = 0;
	client_printcolor(id, "%L"}, id, "T_MM_AUTOFF");
}
else if(g_Option[id][2] == 2)
{
	g_Option[id][2] = 3;
	client_printcolor(id, "%L"}, id, "T_MM_OFF");
}
else
{
	g_Option[id][2] = 2;
	client_printcolor(id, "%L"}, id, "T_MM_AUTON");
}

showMenu_Option(id);
	}
	else if(key == 4)
	{
if(g_Option[id][3])
	g_Option[id][3] = 0;
else
	g_Option[id][3] = 1;

client_printcolor(id, "%L"}, id, g_Option[id][3] ? "T_MU_ON" : "T_MU_OFF");
showMenu_Option(id);
	}
	else if(key == 5)
	{
if(g_Option[id][4])
	g_Option[id][4] = 0;
else
	g_Option[id][4] = 1;

client_printcolor(id, "%L"}, id, g_Option[id][4] ? "T_TR_ON" : "T_TR_OFF");
showMenu_Option(id);
	}
	else if(key == 6)
	{
if(g_Option[id][5])
	g_Option[id][5] = 0;
else
	g_Option[id][5] = 1;

client_printcolor(id, "%L"}, id, g_Option[id][5] ? "T_IN_ON" : "T_IN_OFF");
showMenu_Option(id);
	}
	else if(key == 9)
showMenu_Main(id);

	return PLUGIN_HANDLED;
}

showMenu_Item(id)
{
	new Menu[512], Len, Colored, Time[32];
	new Data[ItemData];
	
	if(g_Item[id] > -1)
ArrayGetArray(g_Items, g_Item[id], Data);
	
	if(g_Item[id] == -100)
	{
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r%L\w |\y %L\r *^n"}, id, "M_OUR_TEAM"}, id, "M_MUSIC_VIEW");
Len += formatex(Menu[Len], charsmax(Menu) - Len, "^n");

format_time(Time, charsmax(Time), "%Y-%m-%d %H:%M:%S"}, g_Elso[id]);
	
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\w%L:\r %s"}, id, "M_VIEWED"}, MainMusic);
Len += formatex(Menu[Len], charsmax(Menu) - Len, "^n");
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\w%L:\r %s^n"}, id, "M_COLLECTED"}, Time);
Len += formatex(Menu[Len], charsmax(Menu) - Len, "^n");

if(g_Music[id] == g_Item[id])
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r1.\w %L\d (%L!)^n"}, id, "M_SET"}, id, "M_READY");
else
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r1.\w %L^n"}, id, "M_SET");

Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r2.\d %L^n"}, id, "M_PLACE_MARKET");
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r3.\d %L^n"}, id, "M_DELETE");
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r4.\d %L^n"}, id, "M_ADDTRADE");
Len += formatex(Menu[Len], charsmax(Menu) - Len, "^n");
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r0.\w %L"}, id, "M_BACK_TO_CASES");

set_pdata_int(id, 205, 0);
show_menu(id, MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_0, Menu, -1, "Item Menu");
	}
	else if(g_Item[id] == -101)
	{
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r%L\w |\y %L\r *^n"}, id, "M_OUR_TEAM"}, id, "M_WEAPON_VIEW");
Len += formatex(Menu[Len], charsmax(Menu) - Len, "^n");

format_time(Time, charsmax(Time), "%Y-%m-%d %H:%M:%S"}, g_Elso[id]);
	
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\w%L:\r %s\d (%L)^n"}, id, "M_VIEWED"}, "Alap | M4A1-S"}, id, "M_BASIC");
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\w%L:\r %s^n"}, id, "M_COLLECTED"}, Time);
Len += formatex(Menu[Len], charsmax(Menu) - Len, "^n");

if(g_Selected[id][CSW_M4A1] == -2)
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r1.\w %L\d (%L!)^n"}, id, "M_EQUIP"}, id, "M_READY");
else
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r1.\w %L^n"}, id, "M_EQUIP");
	
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r2.\d %L^n"}, id, "M_PLACE_MARKET");
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r3.\d %L^n"}, id, "M_DELETE");
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r4.\d %L^n"}, id, "M_ADDTRADE");
Len += formatex(Menu[Len], charsmax(Menu) - Len, "^n");
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r0.\w %L"}, id, "M_BACK_TO_WPNS");

set_pdata_int(id, 205, 0);
show_menu(id, MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_0, Menu, -1, "Item Menu");
	}
	else if(g_Item[id] < 0)
	{
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r%L\w |\y %L\r *^n"}, id, "M_OUR_TEAM"}, id, "M_WEAPON_VIEW");
Len += formatex(Menu[Len], charsmax(Menu) - Len, "^n");

format_time(Time, charsmax(Time), "%Y-%m-%d %H:%M:%S"}, g_Elso[id]);
	
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\w%L:\r %s\d (%L)^n"}, id, "M_VIEWED"}, Guns[g_Item[id]*-1][3], id, "M_BASIC");
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\w%L:\r %s^n"}, id, "M_COLLECTED"}, Time);
Len += formatex(Menu[Len], charsmax(Menu) - Len, "^n");

if(g_Selected[id][Guns[g_Item[id]*-1][0][0]] == -1)
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r1.\w %L\d (%L!)^n"}, id, "M_EQUIP"}, id, "M_READY");
else
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r1.\w %L^n"}, id, "M_EQUIP");
	
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r2.\d %L^n"}, id, "M_PLACE_MARKET");
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r3.\d %L^n"}, id, "M_DELETE");
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r4.\d %L^n"}, id, "M_ADDTRADE");
Len += formatex(Menu[Len], charsmax(Menu) - Len, "^n");
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r0.\w %L"}, id, "M_BACK_TO_WPNS");

set_pdata_int(id, 205, 0);
show_menu(id, MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_0, Menu, -1, "Item Menu");
	}
	else if(Data[wd_item] == 1)
	{
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r%L\w |\y %L\r *^n"}, id, "M_OUR_TEAM"}, id, "M_WEAPON_VIEW");
Len += formatex(Menu[Len], charsmax(Menu) - Len, "^n");

format_time(Time, charsmax(Time), "%Y-%m-%d %H:%M:%S"}, Data[wd_traded]);
	
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\w%L:\r %s "}, id, "M_VIEWED"}, Weapons[Data[wd_sub]][2]);

if(Data[wd_stattrak])
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\d(%L)"}, id, "M_STATTRAK_TM");

Len += formatex(Menu[Len], charsmax(Menu) - Len, "^n");
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\w%L:\r %s^n"}, id, "M_COLLECTED"}, Time);

if ( Data[wd_name] != EOS )
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\w%L:\y ^"%s^"^n"}, id, "M_NAMETAG"}, Data[wd_name]);

if ( Data[wd_stattrak] )
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\w%L:\y %d^n"}, id, "H_STATTRAK_KILLS"}, Data[wd_stattrak_value]);

Len += formatex(Menu[Len], charsmax(Menu) - Len, "^n");

for(new j; j < 33; j++)
{
	if(g_Selected[id][j] == g_Item[id])
	{
Colored = 1;
break;
	}
	else
Colored = 0;
}
	
if(Colored)
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r1.\w %L\d (%L!)^n"}, id, "M_EQUIP"}, id, "M_READY");
else
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r1.%s %L^n"}, Data[wd_trade] ? "\d" : "\w"}, id, "M_EQUIP");
	
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r2.%s %L^n"}, (Colored || Data[wd_trade]) ? "\d" : "\w"}, id, "M_PLACE_MARKET");
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r3.%s %L^n"}, (Colored || Data[wd_trade]) ? "\d" : "\w"}, id, "M_DELETE");

if(Data[wd_trade])
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r4.%s %L\d (%L!)^n"}, Colored ? "\d" : "\w"}, id, "M_ADDTRADE"}, id, "M_READY");
else
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r4.%s %L^n"}, Colored ? "\d" : "\w"}, id, "M_ADDTRADE");
	
Colored = 0;
	
for(new i; i < ArraySize(g_Items); i++)
{
	new DataS[ItemData];
	ArrayGetArray(g_Items, i, DataS);
	
	if(DataS[wd_owner] == bbc_get_user_id(id))
if(DataS[wd_item] == 5)
	if(!DataS[wd_market])
Colored = i;
}

if ( Data[wd_name] == EOS )
{
	if ( Colored )
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r5.%s %L\d (-1%L %L)^n"}, Data[wd_trade] ? "\d" : "\w"}, id, "M_ADDNAME"}, id, "M_PCS"}, id, "M_NAMETAG");
	else
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r5.\d %L (-1%L %L)^n"}, id, "M_ADDNAME"}, id, "M_PCS"}, id, "M_NAMETAG");
}
else
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r5.\w %L^n"}, id, "M_REMNAME");
	
Len += formatex(Menu[Len], charsmax(Menu) - Len, "^n");

if(g_ListMode[id])
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r0.\w %L"}, id, "M_BACK_TO_TRADE");
else
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r0.\w %L"}, id, "M_BACK_TO_WPNS");

set_pdata_int(id, 205, 0);
show_menu(id, MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_0, Menu, -1, "Item Menu");

if(Data[wd_new])
{
	Data[wd_new] = 0;
	ArraySetArray(g_Items, g_Item[id], Data);
	sql_update_row_item(g_Item[id], 1);
}
	}
	else if(Data[wd_item] == 2)
	{
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r%L\w |\y %L\r *^n"}, id, "M_OUR_TEAM"}, id, "M_CASE_VIEW");
Len += formatex(Menu[Len], charsmax(Menu) - Len, "^n");

format_time(Time, charsmax(Time), "%Y-%m-%d %H:%M:%S"}, Data[wd_traded]);
	
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\w%L:\r %s\d (%L: %.2f%%)"}, id, "M_VIEWED"}, Cases[Data[wd_sub]][0], id, "M_CHANCE"}, str_to_float(Cases[Data[wd_sub]][1]));
Len += formatex(Menu[Len], charsmax(Menu) - Len, "^n");
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\w%L:\r %s^n"}, id, "M_COLLECTED"}, Time);
Len += formatex(Menu[Len], charsmax(Menu) - Len, "^n");

new iCaseSum;

for ( new i; i < ArraySize(g_Items); i++ ) {
	
	new DataS[ItemData];
	ArrayGetArray(g_Items, i, DataS);
	
	if ( DataS[wd_owner] == bbc_get_user_id(id) ) {

if ( DataS[wd_item] == 3 )
	if ( !DataS[wd_market] )
Colored = i;

if ( DataS[wd_item] == 2 && Data[wd_sub] == DataS[wd_sub] && !DataS[wd_market] ) {
	
	iCaseSum ++;
}
	}
}

if(Colored)
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r1.%s %L\d (-1%L %L)^n"}, Data[wd_trade] ? "\d" : "\w"}, id, "M_OPEN"}, id, "M_PCS"}, id, "M_KEY");
else
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r1.\d %L (-1%L %L)^n"}, id, "M_OPEN"}, id, "M_PCS"}, id, "M_KEY");

Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r2.%s %L^n"}, Data[wd_trade] || !Data[wd_sub] ? "\d" : "\w"}, id, "M_PLACE_MARKET");
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r3.%s %L^n"}, Data[wd_trade] ? "\d" : "\w"}, id, "M_DELETE");

if(Data[wd_trade])
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r4.\w %L\d (%L!)^n"}, id, "M_ADDTRADE"}, id, "M_READY");
else
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r4.\w %L^n"}, id, "M_ADDTRADE");
	
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r5.\w %L^n"}, id, "M_ITEMSVIEW");
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r6.\w %L^n"}, id, "DELETE_ALL_SAME_CASES"}, Cases[Data[wd_sub]][0], iCaseSum);

Len += formatex(Menu[Len], charsmax(Menu) - Len, "^n");

if(g_ListMode[id])
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r0.\w %L"}, id, "M_BACK_TO_TRADE");
else
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r0.\w %L"}, id, "M_BACK_TO_CASES");

set_pdata_int(id, 205, 0);
show_menu(id, MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6|MENU_KEY_0, Menu, -1, "Item Menu");
	}
	else if(Data[wd_item] == 3)
	{
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r%L\w |\y %L\r *^n"}, id, "M_OUR_TEAM"}, id, "M_CASE_VIEW");
Len += formatex(Menu[Len], charsmax(Menu) - Len, "^n");

format_time(Time, charsmax(Time), "%Y-%m-%d %H:%M:%S"}, Data[wd_traded]);
	
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\w%L:\r %L"}, id, "M_VIEWED"}, id, "M_KEY");
Len += formatex(Menu[Len], charsmax(Menu) - Len, "^n");
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\w%L:\r %s^n"}, id, "M_COLLECTED"}, Time);
Len += formatex(Menu[Len], charsmax(Menu) - Len, "^n");
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r1.\d %L^n"}, id, "M_USE");
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r2.%s %L^n"}, Data[wd_trade] ? "\d" : "\w"}, id, "M_PLACE_MARKET");
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r3.%s %L^n"}, Data[wd_trade] ? "\d" : "\w"}, id, "M_DELETE");

if(Data[wd_trade])
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r4.\w %L\d (%L!)^n"}, id, "M_ADDTRADE"}, id, "M_READY");
else
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r4.\w %L^n"}, id, "M_ADDTRADE");

Len += formatex(Menu[Len], charsmax(Menu) - Len, "^n");
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r0.\w %L"}, id, "M_BACK_TO_CASES");

set_pdata_int(id, 205, 0);
show_menu(id, MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_0, Menu, -1, "Item Menu");
	}
	else if(Data[wd_item] == 4)
	{
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r%L\w |\y %L\r *^n"}, id, "M_OUR_TEAM"}, id, "M_MUSIC_VIEW");
Len += formatex(Menu[Len], charsmax(Menu) - Len, "^n");

format_time(Time, charsmax(Time), "%Y-%m-%d %H:%M:%S"}, Data[wd_traded]);
	
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\w%L:\r %s^n"}, id, "M_VIEWED"}, Musics[Data[wd_sub]][0]);
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\w%L:\r %s^n"}, id, "M_COLLECTED"}, Time);

if ( Data[wd_stattrak] )
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\w%L:\y %d^n"}, id, "H_STATTRAK_MVP"}, Data[wd_stattrak_value]);

Len += formatex(Menu[Len], charsmax(Menu) - Len, "^n");

if(g_Music[id] == g_Item[id])
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r1.\w %L\d (%L!)^n"}, id, "M_SET"}, id, "M_READY");
else
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r1.%s %L^n"}, Data[wd_trade] ? "\d" : "\w"}, id, "M_SET");

Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r2.%s %L^n"}, (g_Music[id] == g_Item[id] || Data[wd_trade]) ? "\d" : "\w"}, id, "M_PLACE_MARKET");
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r3.%s %L^n"}, (g_Music[id] == g_Item[id] || Data[wd_trade]) ? "\d" : "\w"}, id, "M_DELETE");

if(Data[wd_trade])
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r4.\w %L\d (%L!)^n"}, id, "M_ADDTRADE"}, id, "M_READY");
else
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r4.%s %L^n"}, g_Music[id] == g_Item[id] ? "\d" : "\w"}, id, "M_ADDTRADE");

Len += formatex(Menu[Len], charsmax(Menu) - Len, "^n");

if(g_ListMode[id])
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r0.\w %L"}, id, "M_BACK_TO_TRADE");
else
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r0.\w %L"}, id, "M_BACK_TO_CASES");

set_pdata_int(id, 205, 0);
show_menu(id, MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_0, Menu, -1, "Item Menu");
	}
	else if(Data[wd_item] == 5)
	{
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r%L\w |\y %L\r *^n"}, id, "M_OUR_TEAM"}, id, "M_CASE_VIEW");
Len += formatex(Menu[Len], charsmax(Menu) - Len, "^n");

format_time(Time, charsmax(Time), "%Y-%m-%d %H:%M:%S"}, Data[wd_traded]);
	
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\w%L:\r %L"}, id, "M_VIEWED"}, id, "M_NAMETAG");
Len += formatex(Menu[Len], charsmax(Menu) - Len, "^n");
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\w%L:\r %s^n"}, id, "M_COLLECTED"}, Time);
Len += formatex(Menu[Len], charsmax(Menu) - Len, "^n");
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r1.\d %L^n"}, id, "M_USE");
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r2.%s %L^n"}, Data[wd_trade] ? "\d" : "\w"}, id, "M_PLACE_MARKET");
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r3.%s %L^n"}, Data[wd_trade] ? "\d" : "\w"}, id, "M_DELETE");

if(Data[wd_trade])
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r4.\w %L\d (%L!)^n"}, id, "M_ADDTRADE"}, id, "M_READY");
else
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r4.\w %L^n"}, id, "M_ADDTRADE");

Len += formatex(Menu[Len], charsmax(Menu) - Len, "^n");
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r0.\w %L"}, id, "M_BACK_TO_CASES");

set_pdata_int(id, 205, 0);
show_menu(id, MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_0, Menu, -1, "Item Menu");
	}
	else if(Data[wd_item] == 6)
	{
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r%L\w |\y %L\r *^n"}, id, "M_OUR_TEAM"}, id, "M_CASE_VIEW");
Len += formatex(Menu[Len], charsmax(Menu) - Len, "^n");

format_time(Time, charsmax(Time), "%Y-%m-%d %H:%M:%S"}, Data[wd_traded]);
	
if ( Coins[Data[wd_sub]][1][0] <= 1 )
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\w%L:\r %L\d (%s)"}, id, "M_VIEWED"}, id, "T_MEDAL"}, Coins[Data[wd_sub]][0]);
else if ( Coins[Data[wd_sub]][1][0] == 4 )
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\w%L:\r %L"}, id, "M_VIEWED"}, id, Coins[Data[wd_sub]][0]);
else if ( Coins[Data[wd_sub]][1][0] >= 2 )
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\w%L:\r %s %L"}, id, "M_VIEWED"}, Coins[Data[wd_sub]][0], id, "T_COIN");
	
Len += formatex(Menu[Len], charsmax(Menu) - Len, "^n");
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\w%L:\r %s^n"}, id, "M_COLLECTED"}, Time);

if ( Coins[Data[wd_sub]][1][0] == 2 )
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\w%L:\y %.2f%%\d (%L)^n"}, id, "T_MEDAL_XP"}, float(g_OPSt[id][2]), id, "T_MEDAL_DROP");
else if ( Coins[Data[wd_sub]][1][0] == 1 )
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\w%L:\y %.2f%%\d (%L)^n"}, id, "T_MEDAL_XP"}, float(g_Xp[id])/80*100, id, "T_COIN_DROP");

if ( Coins[Data[wd_sub]][1][0] <= 1 )
{
	if ( Coins[Data[wd_sub]][1][0] == 1 )
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\w%L:\y %d.^n"}, id, "TO_MEDAL_LV"}, g_Lv[id]);
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\w%L:\y %dx^n"}, id, "T_MEDAL_TIMES"}, Data[wd_stattrak_value]+1);
}

Len += formatex(Menu[Len], charsmax(Menu) - Len, "^n");

if ( g_Coin[id] == g_Item[id] )
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r1.\w %L\d (%L!)^n"}, id, "M_USE"}, id, "M_READY");
else
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r1.\w %L^n"}, id, "M_USE");
	
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r2.\d %L^n"}, id, "M_PLACE_MARKET");
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r3.\d %L^n"}, id, "M_DELETE");
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r4.\d %L^n"}, id, "M_ADDTRADE");

Len += formatex(Menu[Len], charsmax(Menu) - Len, "^n");
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r0.\w %L"}, id, "M_BACK_TO_CASES");

set_pdata_int(id, 205, 0);
show_menu(id, MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_0, Menu, -1, "Item Menu");
	}
	else if(Data[wd_item] == 7)
	{
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r%L\w |\y %L\r *^n"}, id, "M_OUR_TEAM"}, id, "M_CASE_VIEW");
Len += formatex(Menu[Len], charsmax(Menu) - Len, "^n");

format_time(Time, charsmax(Time), "%Y-%m-%d %H:%M:%S"}, Data[wd_traded]);
	
if ( !Data[wd_sub] )
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\w%L:\r %L%s"}, id, "M_VIEWED"}, id, "M_MUSIC_KIT_BOX"}, Data[wd_stattrak] ? "\d (StatTrak*)" : "");

Len += formatex(Menu[Len], charsmax(Menu) - Len, "^n");
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\w%L:\r %s^n"}, id, "M_COLLECTED"}, Time);
Len += formatex(Menu[Len], charsmax(Menu) - Len, "^n");
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r1.%s %L^n"}, Data[wd_trade] ? "\d" : "\w"}, id, "M_OPEN");
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r2.%s %L^n"}, Data[wd_trade] ? "\d" : "\w"}, id, "M_PLACE_MARKET");

if(Data[wd_trade])
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r3.\w %L\d (%L!)^n"}, id, "M_ADDTRADE"}, id, "M_READY");
else
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r3.\w %L^n"}, id, "M_ADDTRADE");

Len += formatex(Menu[Len], charsmax(Menu) - Len, "^n");

if(g_ListMode[id])
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r0.\w %L"}, id, "M_BACK_TO_TRADE");
else
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r0.\w %L"}, id, "M_BACK_TO_CASES");

set_pdata_int(id, 205, 0);
show_menu(id, MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_0, Menu, -1, "Item Menu");
	}
	
	return PLUGIN_HANDLED;
}

public menu_item(id, key)
{
	if (!is_user_connected(id))
return PLUGIN_HANDLED;
	
	new Colored;
	new Data[ItemData];
	new DataS[ItemData];
	
	if(g_Item[id] > -1)
ArrayGetArray(g_Items, g_Item[id], Data);
	
	if ( g_Item[id] == -101 )
	{
if ( !key )
{
	if ( g_Selected[id][CSW_M4A1] != -2 )
	{
if ( g_Selected[id][CSW_M4A1] != -1 )
{
	ArrayGetArray(g_Items, g_Selected[id][CSW_M4A1], Data);
	Data[wd_inuse] = -1;
	ArraySetArray(g_Items, g_Selected[id][CSW_M4A1], Data);

	sql_update_row_item(g_Selected[id][CSW_M4A1], 6);
}

g_Selected[id][CSW_M4A1] = -2;
client_printcolor(id, "%L:$3! %s"}, id, "T_WPN_EQUIPED"}, "Alap | M4A1-S");
	}
	else
client_printcolor(id, "%L:$3! %s"}, id, "T_WPN_ALREADY_EQUIPED"}, "Alap | M4A1-S");

	showMenu_Item(id);
}
else if(key == 1)
{
	client_printcolor(id, "%L"}, id, "T_BASIC_WPN_SORT");
	showMenu_Item(id);
}
else if(key == 2)
{
	client_printcolor(id, "%L"}, id, "T_BASIC_WPN_SORT");
	showMenu_Item(id);
}
else if(key == 3)
{
	client_printcolor(id, "%L"}, id, "T_BASIC_WPN_SORT");
	showMenu_Item(id);
}
else if ( key == 9 ) {
	
	new All = 1;
	
	for ( new i; i < sizeof Guns; i++ ) {
	
if ( g_Option[id][1] && Guns[i][1][0] > -1 ) {
	
	All ++;
}
	}
	
	if ( All <= 7 )
g_Page[id] = 0;
	else if ( All%7 )
g_Page[id] = All/7;
	else
g_Page[id] = All/7 - 1;
	
	showMenu_Select(id);
}
	}
	else if(g_Item[id] == -100)
	{
if(!key)
{
	if ( g_Music[id] != g_Item[id] )
	{
ArrayGetArray(g_Items, g_Music[id], Data);
Data[wd_inuse] = -1;
ArraySetArray(g_Items, g_Music[id], Data);

sql_update_row_item(g_Music[id], 6);

g_Music[id] = g_Item[id];
client_printcolor(id, "%L:$3! %s"}, id, "T_MUSIC_SET"}, MainMusic);
	}
	else
client_printcolor(id, "%L:$3! %s"}, id, "T_MUSIC_ALREADY_EQUIPED"}, MainMusic);

	showMenu_Item(id);
}
else if(key == 1)
{
	client_printcolor(id, "%L"}, id, "T_BASIC_MUSIC_SORT");
	showMenu_Item(id);
}
else if(key == 2)
{
	client_printcolor(id, "%L"}, id, "T_BASIC_MUSIC_SORT");
	showMenu_Item(id);
}
else if(key == 3)
{
	client_printcolor(id, "%L"}, id, "T_BASIC_MUSIC_SORT");
	showMenu_Item(id);
}
else if(key == 9)
	showMenu_Musics(id);
	}
	else if(g_Item[id] < 0)
	{
if(!key)
{
	if(g_Selected[id][Guns[g_Item[id]*-1][0][0]] != -1)
	{
if(g_Selected[id][Guns[g_Item[id]*-1][0][0]] != -2)
{
	Data[wd_inuse] = -1;
	ArraySetArray(g_Items, g_Selected[id][Guns[g_Item[id]*-1][0][0]], Data);

	sql_update_row_item(g_Selected[id][Guns[g_Item[id]*-1][0][0]], 6);
}

g_Selected[id][Guns[g_Item[id]*-1][0][0]] = -1;
client_printcolor(id, "%L:$3! %s"}, id, "T_WPN_EQUIPED"}, Guns[g_Item[id]*-1][3]);
	}
	else
client_printcolor(id, "%L:$3! %s"}, id, "T_WPN_ALREADY_EQUIPED"}, Guns[g_Item[id]*-1][3]);

	showMenu_Item(id);
}
else if(key == 1)
{
	client_printcolor(id, "%L"}, id, "T_BASIC_WPN_SORT");
	showMenu_Item(id);
}
else if(key == 2)
{
	client_printcolor(id, "%L"}, id, "T_BASIC_WPN_SORT");
	showMenu_Item(id);
}
else if(key == 3)
{
	client_printcolor(id, "%L"}, id, "T_BASIC_WPN_SORT");
	showMenu_Item(id);
}
else if ( key == 9 ) {
	
	new All = 0;
	
	for ( new i; i < sizeof Guns; i++ ) {
	
if ( g_Option[id][1] && Guns[i][1][0] > -1 ) {
	
	if ( g_Item[id]*-1 >= i )
All ++;
}
	}
	
	if ( All <= 7 )
g_Page[id] = 0;
	else if ( All%7 )
g_Page[id] = All/7;
	else
g_Page[id] = All/7 - 1;
	
	showMenu_Select(id);
}
	}
	else if(Data[wd_item] == 1)
	{
for ( new i; i < 33; i++ )
{
	if(g_Selected[id][i] == g_Item[id])
	{
Colored = 1;
break;
	}
	else
Colored = 0;
}

if ( !key )
{
	if(Data[wd_trade])
client_printcolor(id, "%L"}, id, "T_EQUIPED_WPN_SORT");
	else if(!Colored)
	{
if(g_Selected[id][Weapons[Data[wd_sub]][0][0]] > -1)
{
	ArrayGetArray(g_Items, g_Selected[id][Weapons[Data[wd_sub]][0][0]], DataS);
	DataS[wd_inuse] = -1;
	ArraySetArray(g_Items, g_Selected[id][Weapons[Data[wd_sub]][0][0]], DataS);

	sql_update_row_item(g_Selected[id][Weapons[Data[wd_sub]][0][0]], 6);
}

g_Selected[id][Weapons[Data[wd_sub]][0][0]] = g_Item[id];
client_printcolor(id, "%L:$3! %s%s"}, id, "T_WPN_EQUIPED"}, Weapons[Data[wd_sub]][2], Data[wd_stattrak] ? " (StatTrak*)" : "");

Data[wd_inuse] = Weapons[Data[wd_sub]][0][0];
ArraySetArray(g_Items, g_Item[id], Data);

sql_update_row_item(g_Item[id], 6);
	}
	else
	{
for(new i; i < sizeof Guns; i++)
{
	if(Guns[i][0][0] == Weapons[Data[wd_sub]][0][0])
	{
Colored = i;
break;
	}
}
	
client_printcolor(id, "%L:$3! %s"}, id, "T_WPN_EQUIPED"}, Guns[Colored][3]);
g_Selected[id][Weapons[Data[wd_sub]][0][0]] = -1;

Data[wd_inuse] = -1;
ArraySetArray(g_Items, g_Item[id], Data);

sql_update_row_item(g_Item[id], 6);
	}
	
	showMenu_Item(id);
}
else if(key == 1)
{
	if(!Colored && !Data[wd_trade])
showMenu_MarketT(id);
	else
	{
client_printcolor(id, "%L"}, id, "T_EQUIPED_WPN_SORT");
showMenu_Item(id);
	}
}
else if(key == 2)
{
	if(!Colored && !Data[wd_trade]) {

g_iDeleteAll[id] = 0;
showMenu_Delete(id);
	}
	else
	{
client_printcolor(id, "%L"}, id, "T_EQUIPED_WPN_SORT");
showMenu_Item(id);
	}
}
else if(key == 3)
{
	if(!Colored)
	{
if(!Data[wd_trade])
{
	client_printcolor(id, "%L:$3! %s"}, id, "M_TRADEADD"}, Weapons[Data[wd_sub]][2]);
	
	Data[wd_trade] = 1;
	g_Ready[id] = 0;
	g_Ready[g_Trade[id]] = 0;
	ArraySetArray(g_Items, g_Item[id], Data);
	
	if(id == g_Trade[g_Trade[id]])
client_printcolor(g_Trade[id], "%L:$3! %s"}, g_Trade[id], "T_INVITEADD"}, Weapons[Data[wd_sub]][2]);
}
else
{
	client_printcolor(id, "%L:$3! %s"}, id, "M_TRADEREM"}, Weapons[Data[wd_sub]][2]);
	
	Data[wd_trade] = 0;
	g_Ready[id] = 0;
	g_Ready[g_Trade[id]] = 0;
	ArraySetArray(g_Items, g_Item[id], Data);
	
	if(id == g_Trade[g_Trade[id]])
client_printcolor(g_Trade[id], "%L:$3! %s"}, g_Trade[id], "T_INVITEREM"}, Weapons[Data[wd_sub]][2]);
}

showMenu_Item(id);
	}
	else
	{
client_printcolor(id, "%L"}, id, "T_EQUIPED_WPN_SORT");
showMenu_Item(id);
	}
}
else if ( key == 4 )
{
	if ( Data[wd_name] == EOS )
	{
Colored = 0;
	
for(new i; i < ArraySize(g_Items); i++)
{
	new DataS[ItemData];
	ArrayGetArray(g_Items, i, DataS);
	
	if(DataS[wd_owner] == bbc_get_user_id(id))
if(DataS[wd_item] == 5)
	if(!DataS[wd_market])
Colored = i;
}

if ( Colored )
{
	if ( !Data[wd_trade] )
client_msgmode_w_lang(id, 6);
	else
client_printcolor(id, "%L"}, id, "T_TRADE_IET_SORT");
}	
else
	client_printcolor(id, "%L"}, id, "T_NO_NAMETAG");
	}
	else
	{
new Data[ItemData];
ArrayGetArray(g_Items, g_Item[id], Data);
copy(Data[wd_name], sizeof(Data[wd_name]) - 1, "");
ArraySetArray(g_Items, g_Item[id], Data);

sql_update_row_item(g_Item[id], 7);

client_printcolor(id, "%L"}, id, "T_NAMETAG_REMOVE");
	}
	
	showMenu_Item(id);
}
else if ( key == 9 ) {
	
	new All;
	
	if ( !g_ListMode[id] ) {
	
All = 1;

for ( new i; i < sizeof Guns; i++ ) {

	if ( g_Option[id][1] && Guns[i][1][0] > -1 ) {

All ++;
	}
}

for ( new i; i < ArraySize(g_Items); i++ ) {

	new DataS[ItemData];
	ArrayGetArray(g_Items, i, DataS);
	
	if ( DataS[wd_item] == 1 && Weapons[DataS[wd_sub]][1][0] ) {

if ( DataS[wd_owner] == bbc_get_user_id(id) ) {
	
	All ++;
	
	if ( Data[wd_id] == DataS[wd_id] )
break;
}
	}
}
	}
	else {
	
All = 1;

for ( new i; i < ArraySize(g_Items); i++ ) {

	new DataS[ItemData];
	ArrayGetArray(g_Items, i, DataS);
	
	if ( DataS[wd_item] == 1 && Weapons[DataS[wd_sub]][1][0] ) {

if ( DataS[wd_owner] == bbc_get_user_id(id) && DataS[wd_trade] ) {
	
	All ++;
	
	if ( Data[wd_id] == DataS[wd_id] )
break;
}
	}
}
	
	}
	
	if ( All <= 7 )
g_Page[id] = 0;
	else if ( All%7 )
g_Page[id] = All/7;
	else
g_Page[id] = All/7 - 1;
	
	if ( !g_ListMode[id] )
showMenu_Select(id);
	else
showMenu_List(id);
}
	}
	else if(Data[wd_item] == 2)
	{
if(!key)
{
	if(!Data[wd_trade])
do_open_case(id, g_Item[id]);
	else
	{
client_printcolor(id, "%L"}, id, "T_TRADE_IET_SORT");
showMenu_Item(id);
	}
}
else if(key == 1)
{
	if(Data[wd_sub])
	{
if(!Data[wd_trade])
{
	showMenu_MarketT(id);
}
else
{
	client_printcolor(id, "%L"}, id, "T_TRADE_IET_SORT");
	showMenu_Item(id);
}
	}
	else
	{
client_printcolor(id, "%L"}, id, "T_MARKET_NOTACH");
showMenu_Item(id);
	}
}
else if(key == 2)
{
	if(!Data[wd_trade]) {

g_iDeleteAll[id] = 0;
showMenu_Delete(id);
	}
	else
	{
client_printcolor(id, "%L"}, id, "T_TRADE_IET_SORT");
showMenu_Item(id);
	}
}
else if(key == 3)
{
	if(!Data[wd_trade])
	{
client_printcolor(id, "%L:$3! %s"}, id, "M_TRADEADD"}, Cases[Data[wd_sub]][0]);

Data[wd_trade] = 1;
g_Ready[id] = 0;
g_Ready[g_Trade[id]] = 0;
ArraySetArray(g_Items, g_Item[id], Data);

if(id == g_Trade[g_Trade[id]])
	client_printcolor(g_Trade[id], "%L:$3! %s"}, g_Trade[id], "T_INVITEADD"}, Cases[Data[wd_sub]][0]);
	}
	else
	{
client_printcolor(id, "%L:$3! %s"}, id, "M_TRADEREM"}, Cases[Data[wd_sub]][0]);

Data[wd_trade] = 0;
g_Ready[id] = 0;
g_Ready[g_Trade[id]] = 0;
ArraySetArray(g_Items, g_Item[id], Data);

if(id == g_Trade[g_Trade[id]])
	client_printcolor(g_Trade[id], "%L:$3! %s"}, g_Trade[id], "T_INVITEREM"}, Cases[Data[wd_sub]][0]);
	}
	
	showMenu_Item(id);
}
else if ( key == 4 )
	do_MOTD_CaseItems(id, Data[wd_sub]);
else if ( key == 5 ) {
	
	g_iDeleteAll[id] = 1;
	showMenu_Delete(id);
}	
else if(key == 9)
{
	if(!g_ListMode[id])
showMenu_Cases(id);
	else
showMenu_List(id);
}
	}
	else if(Data[wd_item] == 3)
	{
if(!key)
{
	client_printcolor(id, "%L"}, id, "T_KEY_USE");
	showMenu_Item(id);
}
else if(key == 1)
{
	if(!Data[wd_trade])
showMenu_MarketT(id);
	else
	{
client_printcolor(id, "%L"}, id, "T_TRADE_IET_SORT");
showMenu_Item(id);
	}
}
else if(key == 2)
{
	if(!Data[wd_trade]) {

g_iDeleteAll[id] = 0;
showMenu_Delete(id);
	}
	else
	{
client_printcolor(id, "%L"}, id, "T_TRADE_IET_SORT");
showMenu_Item(id);
	}
}
else if(key == 3)
{
	if(!Data[wd_trade])
	{
client_printcolor(id, "%L:$3! %L"}, id, "M_TRADEADD"}, id, "M_KEY");

Data[wd_trade] = 1;
g_Ready[id] = 0;
g_Ready[g_Trade[id]] = 0;
ArraySetArray(g_Items, g_Item[id], Data);

if(id == g_Trade[g_Trade[id]])
	client_printcolor(g_Trade[id], "%L:$3! %L"}, g_Trade[id], "T_INVITEADD"}, id, "M_KEY");
	}
	else
	{
client_printcolor(id, "%L:$3! %L"}, id, "M_TRADEREM"}, id, "M_KEY");

Data[wd_trade] = 0;
ArraySetArray(g_Items, g_Item[id], Data);

if(id == g_Trade[g_Trade[id]])
	client_printcolor(g_Trade[id], "%L:$3! %L"}, g_Trade[id], "T_INVITEREM"}, id, "M_KEY");
	}
	
	showMenu_Item(id);
}
else if(key == 9)
{
	if(!g_ListMode[id])
showMenu_Cases(id);
	else
showMenu_List(id);
}
	}
	else if(Data[wd_item] == 4)
	{
if(!key)
{
	if(g_Music[id] != g_Item[id] && !Data[wd_trade])
	{
if(g_Music[id] != -100)
{
	ArrayGetArray(g_Items, g_Music[id], DataS);
	DataS[wd_inuse] = -1;
	ArraySetArray(g_Items, g_Music[id], DataS);

	sql_update_row_item(g_Music[id], 6);
}

g_Music[id] = g_Item[id];
client_printcolor(id, "%L:$3! %s"}, id, "T_MUSIC_SET"}, Musics[Data[wd_sub]][0]);

Data[wd_inuse] = 1;
ArraySetArray(g_Items, g_Item[id], Data);

sql_update_row_item(g_Item[id], 6);
	}
	else
client_printcolor(id, "%L:$3! %s"}, id, "T_MUSIC_ALREADY_EQUIPED"}, Musics[Data[wd_sub]][0]);

	showMenu_Item(id);
}
else if(key == 1)
{
	if(g_Music[id] != g_Item[id] && !Data[wd_trade])
showMenu_MarketT(id);
	else
	{
client_printcolor(id, "%L"}, id, "T_SET_MUSIC_SORT");
showMenu_Item(id);
	}
}
else if(key == 2)
{
	if(g_Music[id] != g_Item[id] && !Data[wd_trade]) {

g_iDeleteAll[id] = 0;
showMenu_Delete(id);
	}
	else
	{
client_printcolor(id, "%L"}, id, "T_SET_MUSIC_SORT");
showMenu_Item(id);
	}
}
else if(key == 3)
{
	if(g_Music[id] != g_Item[id])
	{
if(!Data[wd_trade])
{
	client_printcolor(id, "%L:$3! %s"}, id, "M_TRADEADD"}, Musics[Data[wd_sub]][0]);
	
	Data[wd_trade] = 1;
	g_Ready[id] = 0;
	g_Ready[g_Trade[id]] = 0;
	ArraySetArray(g_Items, g_Item[id], Data);
	
	if(id == g_Trade[g_Trade[id]])
client_printcolor(g_Trade[id], "%L:$3! %s"}, g_Trade[id], "T_INVITEADD"}, Musics[Data[wd_sub]][0]);
}
else
{
	client_printcolor(id, "%L:$3! %s"}, id, "M_TRADEREM"}, Musics[Data[wd_sub]][0]);
	
	Data[wd_trade] = 0;
	g_Ready[id] = 0;
	g_Ready[g_Trade[id]] = 0;
	ArraySetArray(g_Items, g_Item[id], Data);
	
	if(id == g_Trade[g_Trade[id]])
client_printcolor(g_Trade[id], "%L:$3! %s"}, g_Trade[id], "T_INVITEREM"}, Musics[Data[wd_sub]][0]);
}

showMenu_Item(id);
	}
	else
	{
client_printcolor(id, "%L"}, id, "T_SET_MUSIC_SORT");
showMenu_Item(id);
	}
}
else if(key == 9)
{
	if(!g_ListMode[id])
showMenu_Musics(id);
	else
showMenu_List(id);
}
	}
	else if(Data[wd_item] == 5)
	{
if(!key)
{
	client_printcolor(id, "%L"}, id, "T_TAG_USE");
	showMenu_Item(id);
}
else if(key == 1)
{
	if(!Data[wd_trade])
showMenu_MarketT(id);
	else
	{
client_printcolor(id, "%L"}, id, "T_TRADE_IET_SORT");
showMenu_Item(id);
	}
}
else if(key == 2)
{
	if(!Data[wd_trade]) {

g_iDeleteAll[id] = 0;
showMenu_Delete(id);
	}
	else
	{
client_printcolor(id, "%L"}, id, "T_TRADE_IET_SORT");
showMenu_Item(id);
	}
}
else if(key == 3)
{
	if(!Data[wd_trade])
	{
client_printcolor(id, "%L:$3! %L"}, id, "M_TRADEADD"}, id, "M_NAMETAG");

Data[wd_trade] = 1;
g_Ready[id] = 0;
g_Ready[g_Trade[id]] = 0;
ArraySetArray(g_Items, g_Item[id], Data);

if(id == g_Trade[g_Trade[id]])
	client_printcolor(g_Trade[id], "%L:$3! %L"}, g_Trade[id], "T_INVITEADD"}, id, "M_NAMETAG");
	}
	else
	{
client_printcolor(id, "%L:$3! %L"}, id, "M_TRADEREM"}, id, "M_NAMETAG");

Data[wd_trade] = 0;
g_Ready[id] = 0;
g_Ready[g_Trade[id]] = 0;
ArraySetArray(g_Items, g_Item[id], Data);

if(id == g_Trade[g_Trade[id]])
	client_printcolor(g_Trade[id], "%L:$3! %L"}, g_Trade[id], "T_INVITEREM"}, id, "M_NAMETAG");
	}
	
	showMenu_Item(id);
}
else if(key == 9)
{
	if(!g_ListMode[id])
showMenu_Cases(id);
	else
showMenu_List(id);
}
	}
	else if ( Data[wd_item] == 6 )
	{
if ( !key )
{
	if ( g_Coin[id] != g_Item[id] )
	{
if ( g_Coin[id] != -1 )
{
	ArrayGetArray(g_Items, g_Coin[id], Data);
	Data[wd_inuse] = -1;
	ArraySetArray(g_Items, g_Coin[id], Data);
	sql_update_row_item(g_Coin[id], 6);
}

g_Coin[id] = g_Item[id];
	
ArrayGetArray(g_Items, g_Coin[id], Data);
Data[wd_inuse] = g_Item[id];
ArraySetArray(g_Items, g_Coin[id], Data);

sql_update_row_item(g_Coin[id], 6);

if ( Coins[Data[wd_sub]][1][0] <= 1 )
	client_printcolor(id, "%L:$3! %L (%s)"}, id, "T_MEDAL_EQUIP"}, id, "T_MEDAL"}, Coins[Data[wd_sub]][0]);
else if ( Coins[Data[wd_sub]][1][0] >= 2 )
	client_printcolor(id, "%L:$3! %s %L"}, id, "T_MEDAL_EQUIP"}, Coins[Data[wd_sub]][0], id, "T_COIN");
	}
	else
	{
ArrayGetArray(g_Items, g_Coin[id], Data);
Data[wd_inuse] = -1;
ArraySetArray(g_Items, g_Coin[id], Data);

sql_update_row_item(g_Coin[id], 6);

client_printcolor(id, "%L"}, id, "T_MDEAL_REM");

g_Coin[id] = -1;
	}
	
	showMenu_Item(id);
}
else if ( key == 1 || key == 2 || key == 3 )
{
	client_printcolor(id, "%L"}, id, "T_MEDAL_CANT");
	showMenu_Item(id);
}
else if ( key == 9 )
{
	if ( !g_ListMode[id] )
showMenu_Cases(id);
	else
showMenu_List(id);
}
	}
	else if(Data[wd_item] == 7)
	{
if(!key)
{
	if(!Data[wd_trade])
	{
new Array: MusicsInBox;
MusicsInBox = ArrayCreate(1);

for ( new i; i < sizeof(Musics); i++ )
{
	if ( Musics[i][1][0] )
ArrayPushCell(MusicsInBox, i);
}

new MusicKit = random_num(0, ArraySize(MusicsInBox)-1);

Data[wd_item] = 0;
ArraySetArray(g_Items, g_Item[id], Data);
sql_update_row_item(g_Item[id], 4);

createItem(4, MusicKit, bbc_get_user_id(id), Data[wd_stattrak]);

static players[32], pnum, taskid;
get_players(players, pnum, "ch");

new player_name[32];
get_user_name(id, player_name, charsmax(player_name));

for ( new i; i < pnum; i++ )
{
	taskid = players[i];
	client_printcolor(taskid, "%L"}, taskid, "T_OPENMUSICBOX"}, player_name, Musics[MusicKit][0], Data[wd_stattrak]  ? " (StatTrak*)" : "");
}
	}
	else
	{
client_printcolor(id, "%L"}, id, "T_TRADE_IET_SORT");
showMenu_Item(id);
	}
}
else if(key == 1)
{
	if(!Data[wd_trade])
	{
showMenu_MarketT(id);
	}
	else
	{
client_printcolor(id, "%L"}, id, "T_TRADE_IET_SORT");
showMenu_Item(id);
	}
}
else if(key == 2)
{
	if(!Data[wd_trade])
	{
client_printcolor(id, "%L:$3! %L$1! %s"}, id, "M_TRADEADD"}, id, "M_MUSIC_KIT_BOX"}, Data[wd_stattrak] ? "(StatTrak*)" : "");

Data[wd_trade] = 1;
g_Ready[id] = 0;
g_Ready[g_Trade[id]] = 0;
ArraySetArray(g_Items, g_Item[id], Data);

if(id == g_Trade[g_Trade[id]])
	client_printcolor(g_Trade[id], "%L:$3! %L$1! %s"}, g_Trade[id], "T_INVITEADD"}, g_Trade[id], "M_MUSIC_KIT_BOX"}, Data[wd_stattrak] ? "(StatTrak*)" : "");
	}
	else
	{
client_printcolor(id, "%L:$3! %L$1! %s"}, id, "M_TRADEREM"}, id, "M_MUSIC_KIT_BOX"}, Data[wd_stattrak] ? "(StatTrak*)" : "");

Data[wd_trade] = 0;
g_Ready[id] = 0;
g_Ready[g_Trade[id]] = 0;
ArraySetArray(g_Items, g_Item[id], Data);

if(id == g_Trade[g_Trade[id]])
	client_printcolor(g_Trade[id], "%L:$3! %L$1! %s"}, g_Trade[id], "T_INVITEREM"}, g_Trade[id], "M_MUSIC_KIT_BOX"}, Data[wd_stattrak] ? "(StatTrak*)" : "");
	}
	
	showMenu_Item(id);
}
else if(key == 9)
{
	if(!g_ListMode[id])
showMenu_Cases(id);
	else
showMenu_List(id);
}
	}
	
	return PLUGIN_HANDLED;
}

public showMenu_Select(id)
{
	new Text[100], Count[64], Colored, All;
	
	// Oldalsz�m illeszt�se az elemekt�l f�gg�en.
	
	formatex(Text, 99, "\r%L\w |\y %L\r *\w"}, id, "M_OUR_TEAM"}, id, "M_WEAPONS"}, id, "M_PAGES");

	// Men� l�trehoz�sa �s fel�p�t�se.
	
	new Menu = menu_create(Text, "createMenu_Select");
	
	// Fegyverek (Alap) kilist�z�sa, ha enged�lyezve vannak.
	
	for(new i; i < sizeof Guns; i++)
	{
if(g_Option[id][1] && Guns[i][1][0] > -1)
{
	if(g_Selected[id][Guns[i][0][0]] == -1)
Colored = 1;
	else
Colored = 0;
	
	formatex(Text, 99, "%s%s"}, Colored ? "\y":"\d"}, Guns[i][3]);
	formatex(Count, charsmax(Count), "-%d"}, i);
	menu_additem(Menu, Text, Count);
}
	}
	
	// M4A1-S
	
	if ( g_Selected[id][CSW_M4A1] == -2 )
Colored = 1;
	else
Colored = 0;
	
	formatex(Text, charsmax(Text), "%sAlap | M4A1-S"}, Colored ? "\y":"\d");
	formatex(Count, charsmax(Count), "-%d"}, 101);
	menu_additem(Menu, Text, Count);
	
	// Fegyverek (Egy�b) kilist�z�sa, ha azok az azonos�t�hoz tartoznak.
	
	for(new i; i < ArraySize(g_Items); i++)
	{
new Data[ItemData];
ArrayGetArray(g_Items, i, Data);

if(Data[wd_item] == 1 && Weapons[Data[wd_sub]][1][0])
{
	if(Data[wd_owner] == bbc_get_user_id(id))
	{
if(!Data[wd_market])
{
	for(new j; j < 33; j++)
	{
if(g_Selected[id][j] == i)
{
	Colored = 1;
	break;
}
else
	Colored = 0;
	}
	
	formatex(Text, 99, "%s%s%s%s"}, Colored ? "\y":""}, Weapons[Data[wd_sub]][2], Data[wd_stattrak] ? "\d (StatTrak*)" : ""}, Data[wd_new] ? "\r *NEW*" : "");
	formatex(Count, charsmax(Count), "%d"}, i);
	menu_additem(Menu, Text, Count);
	
	All = 1;
}
	}
}
	}
	
	// Men� befejez�se �s lez�r�sa.
	
	formatex(Text, 99, "%L"}, id, "M_BACK");
	menu_setprop(Menu, MPROP_BACKNAME, Text);
	
	formatex(Text, 99, "%L"}, id, "M_NEXT");
	menu_setprop(Menu, MPROP_NEXTNAME, Text);
	
	formatex(Text, 99, "%L"}, id, "M_EXIT");
	menu_setprop(Menu, MPROP_EXITNAME, Text);
	
	menu_display(id, Menu, g_Page[id]);
	
	if(!All)
client_printcolor(id, "%L"}, id, "T_EMPTY_SECTION_WPN");
}

public createMenu_Select(id, Menu, item)
{
	if( item == MENU_EXIT )
	{
showMenu_Main(id);
return PLUGIN_HANDLED;
	}
	
	new data[32], iName[64], access, callback;
	menu_item_getinfo(Menu, item, access, data, 31, iName, 63, callback)
	
	new key = str_to_num(data);
	
	g_Item[id] = key;
	showMenu_Item(id);
	
	return PLUGIN_HANDLED;
}

public showMenu_Cases(id)
{
	new Text[128], Count[64], Case, Keys, Tag, Coin, Caps;
	
	formatex(Text, charsmax(Text), "\r%L\w |\y %L\r *\w"}, id, "M_OUR_TEAM"}, id, "M_CASES_KEYS");

	new Menu = menu_create(Text, "createMenu_Cases");

	for(new i; i < ArraySize(g_Items); i++)
	{
new Data[ItemData];
ArrayGetArray(g_Items, i, Data);
	
if(Data[wd_owner] == bbc_get_user_id(id))
{
	if ( Data[wd_item] == 2 && !Data[wd_market] && !g_WrongCase[Data[wd_sub]] )
	{	
formatex(Text, charsmax(Text), "%s"}, Cases[Data[wd_sub]][0]);
formatex(Count, charsmax(Count), "%d"}, i);
menu_additem(Menu, Text, Count);
Case ++;
	}
	else if ( Data[wd_item] == 3 && !Data[wd_market] )
	{	
formatex(Text, charsmax(Text), "%L"}, id, "M_KEY");
formatex(Count, charsmax(Count), "%d"}, i);
menu_additem(Menu, Text, Count);
Keys ++;
	}
	else if ( Data[wd_item] == 5 && !Data[wd_market] )
	{	
formatex(Text, charsmax(Text), "%L"}, id, "M_NAMETAG");
formatex(Count, charsmax(Count), "%d"}, i);
menu_additem(Menu, Text, Count);
Tag ++;
	}
	else if ( Data[wd_item] == 6 )
	{	
if ( Coins[Data[wd_sub]][1][0] <= 1 )
	formatex(Text, charsmax(Text), "%s%L\d (%s)"}, g_Coin[id] == i ? "\y" : "\w"}, id, "T_MEDAL"}, Coins[Data[wd_sub]][0]);
else if ( Coins[Data[wd_sub]][1][0] == 4 )
	formatex(Text, charsmax(Text), "%s%L"}, g_Coin[id] == i ? "\y" : "\w"}, id, Coins[Data[wd_sub]][0]);
else if ( Coins[Data[wd_sub]][1][0] >= 2 )
	formatex(Text, charsmax(Text), "%s%s %L"}, g_Coin[id] == i ? "\y" : "\w"}, Coins[Data[wd_sub]][0], id, "T_COIN");

formatex(Count, charsmax(Count), "%d"}, i);
menu_additem(Menu, Text, Count);
Coin ++;
	}
	else if ( Data[wd_item] == 7 && !Data[wd_market] )
	{	
if ( !Data[wd_sub] )
	formatex(Text, charsmax(Text), "%L%s"}, id, "M_MUSIC_KIT_BOX"}, Data[wd_stattrak] ? "\d (StatTrak*)" : "");

formatex(Count, charsmax(Count), "%d"}, i);
menu_additem(Menu, Text, Count);
Caps ++;
	}
}
	}
	
	formatex(Text, charsmax(Text), "%L"}, id, "M_BACK");
	menu_setprop(Menu, MPROP_BACKNAME, Text);
	
	formatex(Text, charsmax(Text), "%L"}, id, "M_NEXT");
	menu_setprop(Menu, MPROP_NEXTNAME, Text);
	
	formatex(Text, charsmax(Text), "%L"}, id, "M_EXIT");
	menu_setprop(Menu, MPROP_EXITNAME, Text);
	
	menu_display(id, Menu, g_Page[id]);
	
	if ( !Keys && !Case && !Tag && !Coin && !Caps )
client_printcolor(id, "%L"}, id, "T_EMPTY_SECTION_CASE");
}

public createMenu_Cases(id, Menu, item)
{
	if( item == MENU_EXIT )
	{
showMenu_Main(id);
return PLUGIN_HANDLED;
	}
	
	new data[32], iName[64], access, callback, All;
	menu_item_getinfo(Menu, item, access, data, 31, iName, 63, callback)
	
	new key = str_to_num(data)
	
	g_Item[id] = key;
	showMenu_Item(id);
	
	for(new i; i < ArraySize(g_Items); i++)
	{
new Data[ItemData];
ArrayGetArray(g_Items, i, Data);
	
if(Data[wd_owner] == bbc_get_user_id(id))
{
	if(i <= key)
	{
if(Data[wd_item] == 2)
{
	if(!Data[wd_market] && !g_WrongCase[Data[wd_sub]])
All ++;
}
else if(Data[wd_item] == 3)
{
	if(!Data[wd_market])
All ++;
}
else if(Data[wd_item] == 5)
{
	if(!Data[wd_market])
All ++;
}
else if(Data[wd_item] == 6)
	All ++;
else if(Data[wd_item] == 7)
{
	if(!Data[wd_market])
All ++;
}
	}
}
	}
	
	g_Page[id] = (All-1)/7;
	
	return PLUGIN_HANDLED;
}

public showMenu_Musics(id)
{
	new Text[100], Count[64];
	
	formatex(Text, 99, "\r%L\w |\y %L\r *\w"}, id, "M_OUR_TEAM"}, id, "M_MUSICS");

	new Menu = menu_create(Text, "createMenu_Musics");
	
	formatex(Text, 99, "%s%s"}, g_Music[id] == -100 ? "\y" : "\d"}, MainMusic);
	menu_additem(Menu, Text, "-100");
	
	for(new i; i < ArraySize(g_Items); i++)
	{
new Data[ItemData];
ArrayGetArray(g_Items, i, Data);
	
if(Data[wd_owner] == bbc_get_user_id(id))
{
	if(Data[wd_item] == 4 && !Data[wd_market])
	{	
formatex(Text, 99, "%s%s%s"}, g_Music[id] == i ? "\y" : "\w"}, Musics[Data[wd_sub]][0], Data[wd_stattrak] ? "\d (StatTrak*)" : "");
formatex(Count, charsmax(Count), "%d"}, i);
menu_additem(Menu, Text, Count);
	}
}
	}
	
	formatex(Text, 99, "%L"}, id, "M_BACK");
	menu_setprop(Menu, MPROP_BACKNAME, Text);
	
	formatex(Text, 99, "%L"}, id, "M_NEXT");
	menu_setprop(Menu, MPROP_NEXTNAME, Text);
	
	formatex(Text, 99, "%L"}, id, "M_EXIT");
	menu_setprop(Menu, MPROP_EXITNAME, Text);
	
	menu_display(id, Menu, g_Page[id]);
}

public createMenu_Musics(id, Menu, item)
{
	if( item == MENU_EXIT )
	{
showMenu_Main(id);
return PLUGIN_HANDLED;
	}
	
	new data[32], iName[64], access, callback, All = 1;
	menu_item_getinfo(Menu, item, access, data, 31, iName, 63, callback)
	
	new key = str_to_num(data)
	
	g_Item[id] = key;
	showMenu_Item(id);
	
	for(new i; i < ArraySize(g_Items); i++)
	{
new Data[ItemData];
ArrayGetArray(g_Items, i, Data);
	
if(Data[wd_owner] == bbc_get_user_id(id))
	if(i <= key)
if(Data[wd_item] == 4)
	if(!Data[wd_market])
All ++;
	}
	
	g_Page[id] = (All-1)/7;
	
	return PLUGIN_HANDLED;
}

public showMenu_Guns(id)
{
	if(!g_BlockedMenu[id])
	{
new Text[100], Count[64];

formatex(Text, 99, "\r%L\w |\y %L\r *\w"}, id, "M_OUR_TEAM"}, id, "M_EQUIPMENTS");
	
new Menu = menu_create(Text, "createMenu_Guns");

for(new i; i < sizeof Guns; i++)
{
	new Data[ItemData];
	
	if(g_Selected[id][Guns[i][0][0]] > -1)
ArrayGetArray(g_Items, g_Selected[id][Guns[i][0][0]], Data);
	
	if(is_user_connected(id))
	{
if(g_Guns[id])
{
	if(Guns[i][1][0] == 1)
	{	
if ( Guns[i][0][0] == CSW_M4A1 )
	formatex(Text, 99, "%s%s\d%s\r |\y %d $"}, cs_get_user_money(id) >= Guns[i][5][0] ? "\w" : "\d"}, (g_Selected[id][Guns[i][0][0]] > -1) ? Weapons[Data[wd_sub]][2] : (g_Selected[id][Guns[i][0][0]] == -2 ? "Alap | M4A1-S" : Guns[i][3]), (g_Selected[id][Guns[i][0][0]] != -1 && Data[wd_stattrak]) ? " (StatTrak*)" : ""}, Guns[i][5][0]);
else if(Guns[i][0][0] != CSW_AWP)
	formatex(Text, 99, "%s%s\d%s\r |\y %d $"}, cs_get_user_money(id) >= Guns[i][5][0] ? "\w" : "\d"}, (g_Selected[id][Guns[i][0][0]] == -1) ? Guns[i][3] : Weapons[Data[wd_sub]][2], (g_Selected[id][Guns[i][0][0]] != -1 && Data[wd_stattrak]) ? " (StatTrak*)" : ""}, Guns[i][5][0]);
else
	formatex(Text, 99, "%s%s\d%s\r |\y %d $\d [ Max:4 ]"}, cs_get_user_money(id) >= Guns[i][5][0] ? "\w" : "\d"}, (g_Selected[id][Guns[i][0][0]] == -1) ? Guns[i][3] : Weapons[Data[wd_sub]][2], (g_Selected[id][Guns[i][0][0]] != -1 && Data[wd_stattrak]) ? " (StatTrak*)" : ""}, Guns[i][5][0]);

formatex(Count, charsmax(Count), "%d"}, i);
menu_additem(Menu, Text, Count);
	}
}
else 
{
	if(Guns[i][1][0] == 2)
	{	
formatex(Text, 99, "%s%s\d%s\r |\y %d $"}, cs_get_user_money(id) >= Guns[i][5][0] ? "\w" : "\d"}, (g_Selected[id][Guns[i][0][0]] == -1) ? Guns[i][3] : Weapons[Data[wd_sub]][2], (g_Selected[id][Guns[i][0][0]] != -1 && Data[wd_stattrak]) ? " (StatTrak*)" : ""}, Guns[i][5][0]);
formatex(Count, charsmax(Count), "%d"}, i);
menu_additem(Menu, Text, Count);
	}
}
	}
}

formatex(Text, 99, "%L"}, id, "M_BACK");
menu_setprop(Menu, MPROP_BACKNAME, Text);

formatex(Text, 99, "%L"}, id, "M_NEXT");
menu_setprop(Menu, MPROP_NEXTNAME, Text);

formatex(Text, 99, "%L"}, id, "M_EXIT");
menu_setprop(Menu, MPROP_EXITNAME, Text);

menu_display(id, Menu, 0);
	}
}

public addWpn(KeyS[])
{
	new id = KeyS[0];
	new key = KeyS[1];
	
	if ( is_user_connected(id) ) {
	
g_Picked[id][Guns[key][0][0]] = g_Selected[id][Guns[key][0][0]];

new Name[33];
get_weaponname(Guns[key][0][0], Name, 32);
give_item(id, Name);
cs_set_user_bpammo(id, Guns[key][0][0], Guns[key][2][0]);
client_cmd(id, Name);
replace_weapon_models(id, Guns[key][0][0])

if ( Guns[key][0][0] == CSW_M4A1 ) {
	
	new Data[ItemData];
	
	if ( g_Picked[id][CSW_M4A1] > -1 )
ArrayGetArray(g_Items, g_Picked[id][Guns[key][0][0]], Data);

	if ( g_Picked[id][CSW_M4A1] == -2 || contain(Weapons[Data[wd_sub]][2], "-S") != -1 ) {
	
new Weapon, WeaponName[64];
get_weaponname(CSW_M4A1, WeaponName, charsmax(WeaponName) );
Weapon = find_ent_by_owner(-1, WeaponName, id);

if ( pev_valid(Weapon) ) {
	
	cs_set_weapon_ammo(Weapon, 20);
	cs_set_weapon_silen(Weapon, 1);
}
	}
}
	}
}

public createMenu_Guns(id, Menu, item) {	

	if ( item == MENU_EXIT ) {

if ( is_user_connected(id) ) {

	if ( g_Guns[id] ) {

if ( cs_get_user_buyzone(id) ) {

	g_Guns[id] = 0;
	showMenu_Guns(id);
}
	}
}

return PLUGIN_HANDLED;
	}
	
	new data[32], iName[64], access, callback;
	menu_item_getinfo(Menu, item, access, data, 31, iName, 63, callback)
	
	new key = str_to_num(data);
	
	if ( key == -1 ) {
	
if ( cs_get_user_buyzone(id) )
	showMenu_Guns(id);
	}
	else
	{
if(is_user_connected(id))
{
	if ( cs_get_user_buyzone(id) ) {
	
if(cs_get_user_money(id) >= Guns[key][5][0])
{
	if(Guns[key][0][0] != CSW_AWP || (cs_get_user_team(id) == CS_TEAM_CT && g_Awp_Count[0] < 4) || (cs_get_user_team(id) == CS_TEAM_T && g_Awp_Count[1] < 4))
	{
cs_set_user_money(id, cs_get_user_money(id) - Guns[key][5][0])

UTIL_DropWeapon(id, Guns[key][1][0]);

new KeyS[2];
KeyS[0] = id;
KeyS[1] = key;

set_task(0.1, "addWpn"}, id, KeyS, 2);

if(g_Selected[id][Guns[key][0][0]] > -1)
{
	new Data[ItemData];
	ArrayGetArray(g_Items, g_Selected[id][Guns[key][0][0]], Data);
	
	static player_name[32];
	get_user_name(id, player_name, charsmax(player_name));

	copy(Data[wd_toucher], sizeof(Data[wd_toucher]) - 1, player_name);
	
	ArraySetArray(g_Items, g_Selected[id][Guns[key][0][0]], Data);
}

if ( g_Guns[id] && cs_get_user_buyzone(id) )
{
	g_Guns[id] = 0;
	showMenu_Guns(id);
}

if(Guns[key][0][0] == CSW_AWP)
{
	if(cs_get_user_team(id) == CS_TEAM_CT)
g_Awp_Count[0] ++;
	else if(cs_get_user_team(id) == CS_TEAM_T)
g_Awp_Count[1] ++;
}
	}
	else if ( cs_get_user_buyzone(id) )
showMenu_Guns(id);
}
else if ( cs_get_user_buyzone(id) )
	showMenu_Guns(id);
	}
	else
client_printcolor(id, "%L"}, id, "BUYZONE_LEFT");
}
	}
	
	return PLUGIN_HANDLED;
}

public showMenu_Market(id)
{
	new Text[128], Count[64], Data[ItemData];
	
	formatex(Text, 127, "\r%L\w |\y %L\r *\w"}, id, "M_OUR_TEAM"}, id, "M_MARKET");

	new Menu = menu_create(Text, "createMenu_Market");
	
	formatex(Text, 127, "\r%L"}, id, "M_SEARCH_OPT");
	menu_additem(Menu, Text, "-1");
	
	for(new i = ArraySize(g_Items)-1; i >= 0 ; i--)
	{
ArrayGetArray(g_Items, i, Data);

if(Data[wd_market])
{
	if(Data[wd_item] == 1)
	{
if(!g_Search[id][5] || g_Search[id][5] == 1)
{
	if(equal(g_SearchName[id], "") || contain(Weapons[Data[wd_sub]][2], g_SearchName[id]) != -1)
	{
if(!g_Search[id][1] || (g_Search[id][1] == 1 && !Data[wd_stattrak]) || (g_Search[id][1] == 2 && Data[wd_stattrak]))
{
	if(!g_Search[id][2] || (g_Search[id][2] && g_SearchCost[id][0] >= Data[wd_market_cost]))
	{
if(!g_Search[id][3] || (g_Search[id][3] && g_SearchCost[id][1] <= Data[wd_market_cost]))
{
	if(!g_Search[id][4] || (Data[wd_owner] == g_Search[id][4]))
	{
formatex(Text, 127, "%s%s%s\r |\y %.2f Dollár"}, Data[wd_owner] == bbc_get_user_id(id) ? "\y" : ""}, Weapons[Data[wd_sub]][2], Data[wd_stattrak] ? "\d (StatTrak*)" : ""}, Data[wd_market_cost]);
formatex(Count, charsmax(Count), "%d"}, i);
menu_additem(Menu, Text, Count);
	}
}
	}
}
	}
}
	}
	else if(Data[wd_item] == 2)
	{
if(!g_Search[id][5] || g_Search[id][5] == 2)
{
	if(equal(g_SearchName[id], "") || contain(Cases[Data[wd_sub]][0], g_SearchName[id]) != -1)
	{
if(!g_Search[id][1] || g_Search[id][1] == 1)
{
	if(!g_Search[id][2] || (g_Search[id][2] && g_SearchCost[id][0] >= Data[wd_market_cost]))
	{
if(!g_Search[id][3] || (g_Search[id][3] && g_SearchCost[id][1] <= Data[wd_market_cost]))
{
	if(!g_Search[id][4] || (Data[wd_owner] == g_Search[id][4]))
	{
formatex(Text, 127, "%s%s\r |\y %.2f Dollár"}, Data[wd_owner] == bbc_get_user_id(id) ? "\y" : ""}, Cases[Data[wd_sub]][0], Data[wd_market_cost]);
formatex(Count, charsmax(Count), "%d"}, i);
menu_additem(Menu, Text, Count);
	}
}
	}
}
	}
}
	}
	else if(Data[wd_item] == 3)
	{
if(!g_Search[id][5] || g_Search[id][5] == 3)
{
	if(equal(g_SearchName[id], "") || contain("Key"}, g_SearchName[id]) != -1 || contain("Kulcs"}, g_SearchName[id]) != -1)
	{
if(!g_Search[id][1] || g_Search[id][1] == 1)
{
	if(!g_Search[id][2] || (g_Search[id][2] && g_SearchCost[id][0] >= Data[wd_market_cost]))
	{
if(!g_Search[id][3] || (g_Search[id][3] && g_SearchCost[id][1] <= Data[wd_market_cost]))
{
	if(!g_Search[id][4] || (Data[wd_owner] == g_Search[id][4]))
	{
formatex(Text, 127, "%s%L\r |\y %.2f Dollár"}, Data[wd_owner] == bbc_get_user_id(id) ? "\y" : ""}, id, "M_KEY"}, Data[wd_market_cost]);
formatex(Count, charsmax(Count), "%d"}, i);
menu_additem(Menu, Text, Count);
	}
}
	}
}
	}
}
	}
	else if(Data[wd_item] == 4)
	{
if(!g_Search[id][5] || g_Search[id][5] == 4)
{
	if(equal(g_SearchName[id], "") || contain(Musics[Data[wd_sub]][0], g_SearchName[id]) != -1)
	{
if(!g_Search[id][1] || g_Search[id][1] == 1)
{
	if(!g_Search[id][2] || (g_Search[id][2] && g_SearchCost[id][0] >= Data[wd_market_cost]))
	{
if(!g_Search[id][3] || (g_Search[id][3] && g_SearchCost[id][1] <= Data[wd_market_cost]))
{
	if(!g_Search[id][4] || (Data[wd_owner] == g_Search[id][4]))
	{
formatex(Text, 127, "%s%s\r |\y %.2f Dollár"}, Data[wd_owner] == bbc_get_user_id(id) ? "\y" : ""}, Musics[Data[wd_sub]][0], Data[wd_market_cost]);
formatex(Count, charsmax(Count), "%d"}, i);
menu_additem(Menu, Text, Count);
	}
}
	}
}
	}
}
	}
	else if(Data[wd_item] == 5)
	{
if(!g_Search[id][5] || g_Search[id][5] == 5)
{
	if(equal(g_SearchName[id], "") || contain("Name"}, g_SearchName[id]) != -1 || contain("N�v"}, g_SearchName[id]) != -1)
	{
if(!g_Search[id][1] || g_Search[id][1] == 1)
{
	if(!g_Search[id][2] || (g_Search[id][2] && g_SearchCost[id][0] >= Data[wd_market_cost]))
	{
if(!g_Search[id][3] || (g_Search[id][3] && g_SearchCost[id][1] <= Data[wd_market_cost]))
{
	if(!g_Search[id][4] || (Data[wd_owner] == g_Search[id][4]))
	{
formatex(Text, 127, "%s%L\r |\y %.2f Dollár"}, Data[wd_owner] == bbc_get_user_id(id) ? "\y" : ""}, id, "M_NAMETAG"}, Data[wd_market_cost]);
formatex(Count, charsmax(Count), "%d"}, i);
menu_additem(Menu, Text, Count);
	}
}
	}
}
	}
}
	}
}
	}
	
	formatex(Text, 99, "%L"}, id, "M_BACK");
	menu_setprop(Menu, MPROP_BACKNAME, Text);
	
	formatex(Text, 99, "%L"}, id, "M_NEXT");
	menu_setprop(Menu, MPROP_NEXTNAME, Text);
	
	formatex(Text, 99, "%L"}, id, "M_EXIT");
	menu_setprop(Menu, MPROP_EXITNAME, Text);
	
	menu_display(id, Menu, 0);
}

public createMenu_Market(id, Menu, item)
{
	if( item == MENU_EXIT )
	{
showMenu_Main(id);
return PLUGIN_HANDLED;
	}
	
	new data[32], iName[64], access, callback;
	menu_item_getinfo(Menu, item, access, data, 31, iName, 63, callback)
	
	new key = str_to_num(data);
	
	if(key == -1)
showMenu_Search(id);
	else
	{
g_Item[id] = str_to_num(data);
showMenu_MarketI(id);
	}
	
	return PLUGIN_HANDLED;
}

public showMenu_Search(id)
{
	new Text[100], Filter;
	
	if(g_Search[id][0] || g_Search[id][1] || g_Search[id][2] || g_Search[id][3] || g_Search[id][4] || g_Search[id][5] || !equal(g_SearchName[id], ""))
Filter = 1;
	
	formatex(Text, 99, "\r%L\w |\y %L\r *\w^n%L:\y %L\w | %L:\y 1/1"}, id, "M_OUR_TEAM"}, id, "M_MARKET_SEARCH"},  id, "M_FILTER"}, id, Filter ? "M_ON" : "M_OFF"}, id, "M_PAGES");

	new Menu = menu_create(Text, "createMenu_Search");
	
	if(!g_Search[id][5])
formatex(Text, charsmax(Text), "%L?\r |\y %L"}, id, "M_SRC_WHAT"}, id, "M_SRC_MINDONE");
	else if(g_Search[id][5] == 1)
formatex(Text, charsmax(Text), "%L?\r |\y %L"}, id, "M_SRC_WHAT"}, id, "M_WEAPONS");
	else if(g_Search[id][5] == 2)
formatex(Text, charsmax(Text), "%L?\r |\y %L"}, id, "M_SRC_WHAT"}, id, "M_CASES");
	else if(g_Search[id][5] == 3)
formatex(Text, charsmax(Text), "%L?\r |\y %L"}, id, "M_SRC_WHAT"}, id, "M_KEYS");
	else if(g_Search[id][5] == 4)
formatex(Text, charsmax(Text), "%L?\r |\y %L"}, id, "M_SRC_WHAT"}, id, "M_MUSICSS");
	else if(g_Search[id][5] == 5)
formatex(Text, charsmax(Text), "%L?\r |\y %L"}, id, "M_SRC_WHAT"}, id, "M_NAMETAGS");
	menu_additem(Menu, Text, "1");
	
	if(equal(g_SearchName[id], ""))
formatex(Text, charsmax(Text), "%L?\r |\y %L"}, id, "M_SRC_NAME"}, id, "M_SRC_MINDONE");
	else
formatex(Text, charsmax(Text), "%L?\r |\y %s"}, id, "M_SRC_NAME"}, g_SearchName[id]);
	menu_additem(Menu, Text, "2");
	
	if(!g_Search[id][2])
formatex(Text, charsmax(Text), "Max. %L?\r |\y %L"}, id, "M_COST"}, id, "M_SRC_MINDONE");
	else
formatex(Text, charsmax(Text), "Max. %L?\r |\y %.2f Dollár"}, id, "M_COST"}, g_SearchCost[id][0]);
	menu_additem(Menu, Text, "3");

	if(!g_Search[id][3])
formatex(Text, charsmax(Text), "Min. %L?\r |\y %L"}, id, "M_COST"}, id, "M_SRC_MINDONE");
	else
formatex(Text, charsmax(Text), "Min. %L?\r |\y %.2f Dollár"}, id, "M_COST"}, g_SearchCost[id][1]);
	menu_additem(Menu, Text, "4");
	
	if(!g_Search[id][1])
formatex(Text, charsmax(Text), "%L?\r |\y %L"}, id, "M_STATTRAK"}, id, "M_SRC_MINDONE");
	else if(g_Search[id][1] == 1)
formatex(Text, charsmax(Text), "%L?\r |\y %L"}, id, "M_STATTRAK"}, id, "M_NO");
	else if(g_Search[id][1] == 2)
formatex(Text, charsmax(Text), "%L?\r |\y %L"}, id, "M_STATTRAK"}, id, "M_YES");
	menu_additem(Menu, Text, "5");
	
	if(!g_Search[id][4])
formatex(Text, charsmax(Text), "%L #ID?\r |\y %L"}, id, "M_OWNER"}, id, "M_SRC_MINDONE");
	else
formatex(Text, charsmax(Text), "%L #ID?\r |\y #%d"}, id, "M_OWNER"}, g_Search[id][4]);
	menu_additem(Menu, Text, "6");
	
	formatex(Text, 99, "%L"}, id, "M_BACK");
	menu_setprop(Menu, MPROP_BACKNAME, Text);
	
	formatex(Text, 99, "%L"}, id, "M_NEXT");
	menu_setprop(Menu, MPROP_NEXTNAME, Text);
	
	formatex(Text, 99, "%L"}, id, "M_BACK");
	menu_setprop(Menu, MPROP_EXITNAME, Text);
	
	menu_display(id, Menu, 0);
}

public createMenu_Search(id, Menu, item)
{
	if( item == MENU_EXIT )
	{
showMenu_Market(id);
return PLUGIN_HANDLED;
	}
	
	new data[32], iName[64], access, callback;
	menu_item_getinfo(Menu, item, access, data, 31, iName, 63, callback)
	
	new key = str_to_num(data);
	
	if(key == 1)
	{
if(!g_Search[id][5])
	g_Search[id][5] = 1;
else if(g_Search[id][5] == 1)
	g_Search[id][5] = 2;
else if(g_Search[id][5] == 2)
	g_Search[id][5] = 3;
else if(g_Search[id][5] == 3)
	g_Search[id][5] = 4;
else if(g_Search[id][5] == 4)
	g_Search[id][5] = 5;
else if(g_Search[id][5] == 5)
	g_Search[id][5] = 0;	
	}
	else if(key == 2)
	{
client_msgmode_w_lang(id, 0);
showMenu_Search(id)
	}
	else if(key == 3)
	{
client_msgmode_w_lang(id, 1);
showMenu_Search(id)
	}
	else if(key == 4)
	{
client_msgmode_w_lang(id, 2);
showMenu_Search(id)
	}
	else if(key == 5)
	{
if(!g_Search[id][1])
	g_Search[id][1] = 1;
else if(g_Search[id][1] == 1)
	g_Search[id][1] = 2;
else if(g_Search[id][1] == 2)
	g_Search[id][1] = 0;	
	}
	else if(key == 6)
	{
client_msgmode_w_lang(id, 3);
showMenu_Search(id)
	}
	
	showMenu_Search(id);
	
	return PLUGIN_HANDLED;
}

public do_open_case(id, caseid)
{
	new Key = -1;
	
	new KeyData[ItemData];
	
	for ( new i; i < ArraySize(g_Items); i++ )
	{
ArrayGetArray(g_Items, i, KeyData);

if ( KeyData[wd_owner] == bbc_get_user_id(id) )
	if ( KeyData[wd_item] == 3 )
if ( !KeyData[wd_market] )
	Key = i;
	}
	
	new DataS[ItemData];
	ArrayGetArray(g_Items, g_Item[id], DataS);

	if ( Key != -1 )
	{
new Array: Guns_In_Case;
Guns_In_Case = ArrayCreate(1);

ArrayGetArray(g_Items, Key, KeyData);

new Type, Float: All;

for (new i; i < sizeof Types-1; i++)
{
	All += str_to_float(Types[i][0]);
}

new Float: Random = random_float(0.0, All);

for (new i; i < sizeof Types; i++)
{
	if (Random <= str_to_float(Types[i][0]))
Type = i;
}

for (new i; i < sizeof Weapons; i++)
{
	if ( contain(Weapons[i][4], Cases[DataS[wd_sub]][0]) != -1 )
	{
if (Type == Weapons[i][5][0])
{
	ArrayPushCell(Guns_In_Case, i);
}
	}
}

if (ArraySize(Guns_In_Case))
{
	new Weapon = random_num(0, ArraySize(Guns_In_Case)-1);
	new Winner = ArrayGetCell(Guns_In_Case, Weapon);
	new StatTrak = (random_num(1, 100) >= 70 ? 1 : 0);
	
	new random_effect = random_num(10,15);
	
	new DataX[5]
	DataX[0] = id;
	DataX[1] = Winner;
	DataX[2] = DataS[wd_sub];
	DataX[3] = random_effect;
	DataX[4] = StatTrak;
	
	g_Click[id] = random_effect;
	
	do_case_effect(DataX);
	createItem(1, Winner, bbc_get_user_id(id), StatTrak);
	
	KeyData[wd_item] = 0;
	
	ArraySetArray(g_Items, Key, KeyData);
	sql_update_row_item(Key, 4);
	
	DataS[wd_item] = 0;
	
	ArraySetArray(g_Items, caseid, DataS);
	sql_update_row_item(caseid, 4);
	
	log_to_file("fgo_case_open.log"}, "#%d | %i | %i | %i | %s%s"}, bbc_get_user_id(id), 1, Winner, StatTrak, Weapons[Winner][2][0], StatTrak ? " (StatTrak*)" : "");
}
	}
	else
	{
showMenu_Item(id);
client_printcolor(id, "%L"}, id, "T_NO_KEY");
	}
}

public fw_Item_AddToPlayer(ent, id)
{
	if(!is_valid_ent(ent) || !is_user_connected(id))
return HAM_IGNORED;

	new ipulse = entity_get_int(ent, EV_INT_impulse);
	
	if(ipulse >= 1000000)
	{
for (new i; i < 33; i++)
{
	if(1000000 > ipulse - i*1000000 >= 0)
	{
g_Picked[id][cs_get_weapon_id(ent)] = ipulse-i*1000000;
break;
	}
}
	}
	else if (ipulse < 0)
	{
g_Picked[id][cs_get_weapon_id(ent)] = ipulse;
	}
	
	
	return HAM_IGNORED;
}

public fw_SetModel(entity, const model[])
{	
	new String[128];
	
	if(equal(model[7], "w_fl"}, 4))
	{	
formatex(String, charsmax(String), "models/%s/%s"}, MainFolder, GrenadeFlashbang);
entity_set_model(entity, String);

return FMRES_SUPERCEDE;
	}
	else if(equal(model[7], "w_he"}, 4))
	{	
formatex(String, charsmax(String), "models/%s/%s"}, MainFolder, GrenadeHegrenade);
entity_set_model(entity, String);

return FMRES_SUPERCEDE;
	}
	else if(equal(model[7], "w_c4"}, 4))
	{	
formatex(String, charsmax(String), "models/%s/%s"}, MainFolder, BombC4);
entity_set_model(entity, String);

return FMRES_SUPERCEDE;
	}
	else if(equal(model[7], "w_ba"}, 4))
	{	
formatex(String, charsmax(String), "models/%s/%s"}, MainFolder, BombBack);
entity_set_model(entity, String);

return FMRES_SUPERCEDE;
	}
	
	return FMRES_IGNORED;
}

public fw_SetModel_Post(entity, model[])
{
	if(!is_valid_ent(entity))
return FMRES_IGNORED;
	
	new szClassName[33];
	entity_get_string(entity, EV_SZ_classname, szClassName, charsmax(szClassName));

	if(!equal(szClassName, "weaponbox"))
return FMRES_IGNORED;
	
	new id = entity_get_edict(entity, EV_ENT_owner);
	
	if(g_Picked[id][get_user_weapon(id)] > 0)
	{
new Data[ItemData];
ArrayGetArray(g_Items, g_Picked[id][get_user_weapon(id)], Data);
	
new Name[33];
get_weaponname(Weapons[Data[wd_sub]][0][0], Name, 32);

new iStoredID = find_ent_by_owner(-1, Name, entity);
	
if(!is_valid_ent(iStoredID))
	return FMRES_IGNORED;

new Data2[ItemData];
ArrayGetArray(g_Items, g_Picked[id][cs_get_weapon_id(iStoredID)], Data2);
	
new R[8], G[8], B[8];
parse(Types[Weapons[Data2[wd_sub]][5][0]][1], R, charsmax(R), G, charsmax(G), B, charsmax(B));

fm_set_rendering(entity, kRenderFxGlowShell, str_to_num(R), str_to_num(G), str_to_num(B), kRenderNormal, 16);
	
entity_set_int(iStoredID, EV_INT_impulse, id*1000000+g_Picked[id][get_user_weapon(id)]);

if(Data[wd_toucher] == EOS)
{
	static player_name[32];
	get_user_name(id, player_name, charsmax(player_name));
	
	copy(Data[wd_toucher], sizeof(Data[wd_toucher]) - 1, player_name);
}
else
	copy(Data[wd_toucher], sizeof(Data[wd_toucher]) - 1, Data[wd_toucher]);

ArraySetArray(g_Items, g_Picked[id][get_user_weapon(id)], Data);
	}
	else
	{
if(get_user_weapon(id))
{
	new Name[33];
	get_weaponname(get_user_weapon(id), Name, 32);
	
	new iStoredID = find_ent_by_owner(-1, Name, entity);

	if(!is_valid_ent(iStoredID))
return FMRES_IGNORED;

	entity_set_int(iStoredID, EV_INT_impulse, g_Picked[id][get_user_weapon(id)]);
	
	fm_set_rendering(entity, kRenderFxGlowShell, 200, 200, 200, kRenderNormal, 16);
}
	}
	
	return FMRES_IGNORED;
}

public TaskOneSecond()
{
	new players[32], pnum, id;
	get_players(players, pnum, "ch");
	
	new Data[ItemData];

	for ( new i; i < pnum; i++ )
	{
id = players[i];

// client_print(id, print_console, "DEBUG: %i"}, bbc_get_user_id(id));

if ( bbc_get_user_id(id) )
{
	g_Stats[id][4] ++;
	
	do_name_guns(id);
	
	new Len, Text[256], sid, achvs;
	
	sid = !is_user_alive(id) ? pev(id, pev_iuser2) : id;
	
	if ( g_Coin[sid] != -1 )
ArrayGetArray(g_Items, g_Coin[sid], Data);
	
	if ( g_Coin[sid] == -1 )
set_hudmessage(200, 200, 200, 0.01, 0.17, 0, 1.0, 1.0);
	else
	{
if ( Data[wd_sub] == 4 )
	set_hudmessage(205, 127, 50, 0.01, 0.17, 0, 1.0, 1.0);
else if ( Data[wd_sub] == 5 )
	set_hudmessage(192, 192, 192, 0.01, 0.17, 0, 1.0, 1.0);
else if ( Data[wd_sub] == 6 )
	set_hudmessage(212, 175, 55, 0.01, 0.17, 0, 1.0, 1.0);
else if ( Data[wd_sub] == 7 )
	set_hudmessage(150, 155, 240, 0.01, 0.17, 0, 1.0, 1.0);
else if ( Data[wd_sub] == 1 )
	set_hudmessage(25, 255, 25, 0.01, 0.17, 0, 1.0, 1.0);
else if ( Data[wd_sub] == 3 )
	set_hudmessage(255, 100, 25, 0.01, 0.17, 0, 1.0, 1.0);
else if ( !Data[wd_stattrak_value] )
	set_hudmessage(150, 150, 150, 0.01, 0.17, 0, 1.0, 1.0);
else
{
	new R[8], G[8], B[8];
	parse(Types[Data[wd_stattrak_value]-1][1], R, charsmax(R), G, charsmax(G), B, charsmax(B));
	
	set_hudmessage(str_to_num(R), str_to_num(G), str_to_num(B), 0.01, 0.17, 0, 1.0, 1.0);
}
	}
	
	for ( new j; j < AchievementCount; j++ )
	{
if ( g_Achievements[sid][j] >= 100000000 )
	achvs ++;
	}
	
	Len += formatex(Text[Len], charsmax(Text) - Len, "Rank: %s^n"}, Rangs[g_Rang[sid][0]][0]);
	
	if ( g_MusicKit[sid] )
Len += formatex(Text[Len], charsmax(Text) - Len, "- %L^n"}, id, "T_MUSIC_KIT_OWNER");

	Len += formatex(Text[Len], charsmax(Text) - Len, "^n");
	
	if ( id == sid )
	{
Len += formatex(Text[Len], charsmax(Text) - Len, "%L:^n- Dollár: %.2f^n- COIN: %s"}, id, "M_CASH"}, g_Money[id], do_num_to_str(g_rwTCash[id]));
	
Len += formatex(Text[Len], charsmax(Text) - Len, "^n");
Len += formatex(Text[Len], charsmax(Text) - Len, "^n");
	}
	
	new iMenuId, iMenuKeys;
	get_user_menu(id, iMenuId, iMenuKeys);
	
	if ( g_Coin[sid] != -1 && !iMenuId )
	{
if ( Coins[Data[wd_sub]][1][0] <= 1 )
	Len += formatex(Text[Len], charsmax(Text) - Len, "%L (%s)^n"}, id, "T_MEDAL"}, Coins[Data[wd_sub]][0]);
else if ( Coins[Data[wd_sub]][1][0] == 4 )
{
	Len += formatex(Text[Len], charsmax(Text) - Len, "%L^n"}, id, Coins[Data[wd_sub]][0]);
	Len += formatex(Text[Len], charsmax(Text) - Len, "- %L: %s^n"}, id, "FRAG_WINS1"}, do_num_to_str(g_iFragPlaces[sid][0]));
	Len += formatex(Text[Len], charsmax(Text) - Len, "- %L: %s^n"}, id, "FRAG_WINS2"}, do_num_to_str(g_iFragPlaces[sid][1]));
	Len += formatex(Text[Len], charsmax(Text) - Len, "- %L: %s"}, id, "FRAG_WINS3"}, do_num_to_str(g_iFragPlaces[sid][2]));
}
else if ( Coins[Data[wd_sub]][1][0] >= 2 )
{
	Len += formatex(Text[Len], charsmax(Text) - Len, "%s %L^n"}, Coins[Data[wd_sub]][0], id, "T_COIN");
	
	if ( Data[wd_sub] == 3 )
	{
Len += formatex(Text[Len], charsmax(Text) - Len, "- %L: %s^n"}, id, "T_OP_KILLS"}, do_num_to_str(g_OPSt[sid][0]));
Len += formatex(Text[Len], charsmax(Text) - Len, "- %L: %s"}, id, "T_OP_HEADS"}, do_num_to_str(g_OPSt[sid][1]));
	}
}


	}
	
	if ( bbc_get_user_id(sid) )
ShowSyncHudMsg(id, g_MsgSync[2], Text);
}
	}
}

public TaskQuarterToMinute()
{
	static players[32], pnum, id;
	get_players(players, pnum, "ch");
	
	for(new i; i < pnum; i++)
	{
id = players[i];

sql_update_user_to_account(id, 1);

new Text[128];
formatex(Text, charsmax(Text), "RWT_ADV_%d"}, random_num(0, AdvertiseCount));

if ( AdvertiseCount )
	client_printcolor(id, "%L"}, id, Text);
	}
}
	
public TaskOneMinute()
{
	static players[32], pnum, id;
	get_players(players, pnum, "ch");
	
	for(new i; i < pnum; i++)
	{
id = players[i];

sql_update_user_to_account(id, 1);

if(g_Admin[id][0])
{
	if(0 < g_Admin[id][1] <= get_systime())
	{
sql_update_admin(bbc_get_user_id(id), 0, get_systime());
client_printcolor(id, "%L"}, id, "BBC_ADM_EXP");
g_Admin[id][0] = 0;
removeUserAdmin(id)
	}
}
	}
	
	sql_load_purchase();
	sql_user_rank_select();
	
	new Day[16];
	get_time("%A"}, Day, charsmax(Day));
	 
	if (equali(Day, "Tuesday") || equali(Day, "Thursday") || equali(Day, "Saturday"))
	{
new h,m,s;
time(h,m,s);

if ((h == 19) && (m >= 30))
{
	if(!g_Enabled[0])
	{
g_Enabled[0] = 1;
server_cmd("sv_restart 1");

for(new i; i < pnum; i++)
{
	id = players[i];
	
	client_printcolor(id, "%L"}, id, "T_FRAG_ON");
	client_printcolor(id, "%L"}, id, "T_FRAG_ON");
	client_printcolor(id, "%L"}, id, "T_FRAG_ON");
}

log_to_file("fgo_frags.log"}, "START");
	}
}
else
{
	if(g_Enabled[0])
	{
g_Enabled[0] = 0;

SortCustom1D(players, pnum, "do_short_best");

new client_name[3][33];

for(new i; i < 3; i++)
{
	g_Top[i] = players[i];
	get_user_name(g_Top[i], client_name[i], 32);
}

g_Money[g_Top[0]] += 500.0;
g_Money[g_Top[1]] += 250.0;
g_Money[g_Top[2]] += 100.0;

for(new i; i < pnum; i++)
{
	id = players[i];
	
	if (is_user_connected(id))
	{	
client_printcolor(id, "%L"}, id, "T_FRAG_END");
	}
}

if(pnum == 1)
	client_printcolor(0, "1.$3! %s$1! ($4!%d$1!)"}, client_name[0], get_user_frags(g_Top[0]));
else if(pnum == 2)
	client_printcolor(0, "1.$3! %s$1! ($4!%d$1!) | 2.$3! %s$1! ($4!%d$1!)"}, client_name[0], get_user_frags(g_Top[0]), client_name[1], get_user_frags(g_Top[2]));
else if(pnum >= 3)
	client_printcolor(0, "1.$3! %s$1! ($4!%d$1!) | 2.$3! %s$1! ($4!%d$1!) | 3.$3! %s$1! ($4!%d$1!)"}, client_name[0], get_user_frags(g_Top[0]), client_name[1], get_user_frags(g_Top[1]), client_name[2], get_user_frags(g_Top[2]));
	
log_to_file("go_final_frag.log"}, "1ST: %s (#%d) | 2ND: %s (#%d) | 3RD: %s (#%d)"}, client_name[0], bbc_get_user_id(g_Top[0]), client_name[1], bbc_get_user_id(g_Top[1]), client_name[2], bbc_get_user_id(g_Top[2]));
	
sql_add_row_to_frags(bbc_get_user_id(g_Top[0]), bbc_get_user_id(g_Top[1]), bbc_get_user_id(g_Top[2]), client_name[0], client_name[1], client_name[2], get_user_frags(g_Top[0]), get_user_frags(g_Top[1]), get_user_frags(g_Top[2]))
	
g_iFragPlaces[g_Top[0]][0] ++;
g_iFragPlaces[g_Top[1]][1] ++;
g_iFragPlaces[g_Top[2]][2] ++;

do_check_frags(g_Top[0]);
do_check_frags(g_Top[1]);
do_check_frags(g_Top[2]);
	
for(new i; i < pnum; i++)
{
	id = players[i];
	
	if (is_user_connected(id))
	{	
cs_set_user_deaths(id, 0);
set_user_frags(id, 0);
cs_set_user_deaths(id, 0);
set_user_frags(id, 0);
	}
}
	}
}
	}
}

public do_check_frags(id) {

	new iReward;

	if ( g_iFragPlaces[id][0] + g_iFragPlaces[id][1] + g_iFragPlaces[id][2] == 1 ) {
createItem(6, 4, bbc_get_user_id(id), 0);
iReward = 1;
	}
	else if ( g_iFragPlaces[id][0] + g_iFragPlaces[id][1] + g_iFragPlaces[id][2] == 25 ) {
createItem(6, 5, bbc_get_user_id(id), 0);
iReward = 2;
	}
	else if ( g_iFragPlaces[id][0] + g_iFragPlaces[id][1] + g_iFragPlaces[id][2] == 100 ) {
createItem(6, 6, bbc_get_user_id(id), 0);
iReward = 3;
	}
	else if ( g_iFragPlaces[id][0] + g_iFragPlaces[id][1] + g_iFragPlaces[id][2] == 250 ) {
createItem(6, 7, bbc_get_user_id(id), 0);
iReward = 4;
	}
	
	static players[32], pnum, idx;
	get_players(players, pnum, "ch");
	
	new user_name[32];
	get_user_name(id, user_name, charsmax(user_name));
	
	for ( new i; i < pnum; i++ )
	{
idx = players[i];

if ( iReward == 1 )
	client_printcolor(idx, "%L"}, idx, "FRAG_COIN_GET"}, user_name, idx, "FRAG_BRONZE");
else if ( iReward == 2 )
	client_printcolor(idx, "%L"}, idx, "FRAG_COIN_GET"}, user_name, idx, "FRAG_SILVER");
else if ( iReward == 3 )
	client_printcolor(idx, "%L"}, idx, "FRAG_COIN_GET"}, user_name, idx, "FRAG_GOLD");
else if ( iReward == 4 )
	client_printcolor(idx, "%L"}, idx, "FRAG_COIN_GET"}, user_name, idx, "FRAG_DIAMOND");
	}
}

public do_short_best(id1, id2)
{
	if(get_user_frags(id1)-get_user_deaths(id1) > get_user_frags(id2)-get_user_deaths(id2))
return -1;
	else if(get_user_frags(id1)-get_user_deaths(id1) < get_user_frags(id2)-get_user_deaths(id2))
return 1;

	return 0;
}

public fw_CurWeapon(id)
{
	if (!g_FirstHud[id])
	{
do_name_guns(id);

g_FirstHud[id] = 1;

new iClip, iAmmo;
get_user_weapon(id, iClip, iAmmo);

g_LastClip[id] = -1;
	}
}

public do_name_guns(id)
{
	new NameTag[32];
	
	if(is_user_alive(id))
	{	
if(g_Option[id][0])
{
	if(g_Picked[id][get_user_weapon(id)] > 0)
	{
new Data[ItemData];
ArrayGetArray(g_Items, g_Picked[id][get_user_weapon(id)], Data);

static player_name[32];
get_user_name(id, player_name, charsmax(player_name));

format(NameTag, charsmax(NameTag), "^"%s^""}, Data[wd_name]);

if(!equal(Data[wd_toucher], player_name) && Data[wd_toucher] != EOS)
{
	set_hudmessage(200, 200, 200, -1.0, 0.8, 0, 1.0, 1.0);
	ShowSyncHudMsg(id, g_MsgSync[1], "%L"}, id, "H_SWPN"}, Data[wd_toucher]);
	
	new R[8], G[8], B[8];
	parse(Types[Weapons[Data[wd_sub]][5][0]][1], R, charsmax(R), G, charsmax(G), B, charsmax(B));
	
	set_hudmessage(str_to_num(R), str_to_num(G), str_to_num(B), -1.0, 0.8, 0, 1.0, 1.0);
	
	if(Data[wd_stattrak])
ShowSyncHudMsg(id, g_MsgSync[0], "^n%s (%L*)^n%L: %L"}, Data[wd_name] != EOS ? NameTag : Weapons[Data[wd_sub]][2], id, "M_STATTRAK"}, id, "H_STATTRAK_KILLS"}, id, "H_STATTRAK_ERROR");
	else
ShowSyncHudMsg(id, g_MsgSync[0], "^n%s"}, Data[wd_name] != EOS ? NameTag : Weapons[Data[wd_sub]][2]);
}
else
{
	new R[8], G[8], B[8];
	parse(Types[Weapons[Data[wd_sub]][5][0]][1], R, charsmax(R), G, charsmax(G), B, charsmax(B));
	
	set_hudmessage(str_to_num(R), str_to_num(G), str_to_num(B), -1.0, 0.8, 0, 2.0, 2.0);
	
	if(Data[wd_stattrak])
ShowSyncHudMsg(id, g_MsgSync[0], "^n%s (%L*)^n%L: %d"}, Data[wd_name] != EOS ? NameTag : Weapons[Data[wd_sub]][2], id, "M_STATTRAK"}, id, "H_STATTRAK_KILLS"}, Data[wd_stattrak_value]);
	else
ShowSyncHudMsg(id, g_MsgSync[0], "^n%s"}, Data[wd_name] != EOS ? NameTag : Weapons[Data[wd_sub]][2]);
	
	ClearSyncHud(id, g_MsgSync[1]);
}
	}
	else
	{
for(new i; i < sizeof Guns; i++)
{
	if(Guns[i][0][0] == get_user_weapon(id))
	{
set_hudmessage(200, 200, 200, -1.0, 0.8, 0, 1.0, 1.0);

if ( get_user_weapon(id) != CSW_M4A1 || g_Picked[id][CSW_M4A1] == -1 )
	ShowSyncHudMsg(id, g_MsgSync[0], "^n%s"}, Guns[i][3]);
else
	ShowSyncHudMsg(id, g_MsgSync[0], "^nCS:GO | M4A1-S");

ClearSyncHud(id, g_MsgSync[1]);
	}
}
	}
}
	}
	else
	{
new sid = pev(id, pev_iuser2);

if(g_Option[sid][0])
{
	if (!is_user_alive(sid))
return;

	if(g_Picked[sid][get_user_weapon(sid)] > -1)
	{
new Data[ItemData];
ArrayGetArray(g_Items, g_Picked[sid][get_user_weapon(sid)], Data);

static player_name[32];
get_user_name(sid, player_name, charsmax(player_name));

format(NameTag, charsmax(NameTag), "^"%s^""}, Data[wd_name]);

if(!equal(Data[wd_toucher], player_name) && Data[wd_toucher] != EOS)
{
	set_hudmessage(200, 200, 200, -1.0, 0.8, 0, 1.0, 1.0);
	ShowSyncHudMsg(id, g_MsgSync[1], "%L^n"}, id, "H_SWPN"}, Data[wd_toucher]);
	
	new R[8], G[8], B[8];
	parse(Types[Weapons[Data[wd_sub]][5][0]][1], R, charsmax(R), G, charsmax(G), B, charsmax(B));
	
	set_hudmessage(str_to_num(R), str_to_num(G), str_to_num(B), -1.0, 0.8, 0, 1.0, 1.0);
	
	if(Data[wd_stattrak])
ShowSyncHudMsg(id, g_MsgSync[0], "^n%s (%L*)^n%L: %L"}, Data[wd_name] != EOS ? NameTag : Weapons[Data[wd_sub]][2], id, "M_STATTRAK"}, id, "H_STATTRAK_KILLS"}, id, "H_STATTRAK_ERROR");
	else
ShowSyncHudMsg(id, g_MsgSync[0], "^n%s"}, Data[wd_name] != EOS ? NameTag : Weapons[Data[wd_sub]][2]);
}
else
{
	new R[8], G[8], B[8];
	parse(Types[Weapons[Data[wd_sub]][5][0]][1], R, charsmax(R), G, charsmax(G), B, charsmax(B));
	
	set_hudmessage(str_to_num(R), str_to_num(G), str_to_num(B), -1.0, 0.8, 0, 2.0, 2.0);
	
	if(Data[wd_stattrak])
ShowSyncHudMsg(id, g_MsgSync[0], "^n%s (%L*)^n%L: %d"}, Data[wd_name] != EOS ? NameTag : Weapons[Data[wd_sub]][2], id, "M_STATTRAK"}, id, "H_STATTRAK_KILLS"}, Data[wd_stattrak_value]);
	else
ShowSyncHudMsg(id, g_MsgSync[0], "^n%s"}, Data[wd_name] != EOS ? NameTag : Weapons[Data[wd_sub]][2]);
	
	ClearSyncHud(id, g_MsgSync[1]);
}
	}
	else
	{
for(new i; i < sizeof Guns; i++)
{
	if(Guns[i][0][0] == get_user_weapon(sid))
	{
set_hudmessage(200, 200, 200, -1.0, 0.8, 0, 1.0, 1.0);
ShowSyncHudMsg(id, g_MsgSync[0], "^n%s"}, Guns[i][3]);

ClearSyncHud(id, g_MsgSync[1]);
	}
}
	}
}
	}
}

public do_check_structure()
{
	new Correct[sizeof Cases][sizeof Types], All[sizeof Cases];
	
	for (new i; i < sizeof Cases; i++)
	{
for (new j; j < sizeof Weapons; j++)
{
	if ( contain(Weapons[j][4], Cases[i][0]) != -1 )
Correct[i][Weapons[j][5][0]] = 1;
}
	}
	
	for (new i; i < sizeof Cases; i++)
	{
for (new k; k < sizeof Types-1; k++)
	if (Correct[i][k])
All[i] ++;

if (All[i] < sizeof Types-1)
	g_WrongCase[i] = 1;
	}	
}

stock count_ct()
{
	new i, count = 0;
	
	for(i = 1; i < 33; i++)
	{
if(is_user_connected(i))
{
	if(cs_get_user_team(i) == CS_TEAM_CT && is_user_alive(i))
count++;
}
	}
	return count;
}

stock ount_te()
{
	new i, count = 0;
	
	for(i = 1; i < 33; i++)
	{
if(is_user_connected(i))
{
	if(cs_get_user_team(i) == CS_TEAM_T && is_user_alive(i))
count++;
}
	}
	return count;
}

stock fm_cs_get_current_weapon_ent(id)
	return get_pdata_cbase(id, 373, 5);

stock fm_cs_get_weapon_ent_owner(ent)
	return get_pdata_cbase(ent, 41, 4);

stock client_printcolor(const id, const input[], any:...)
{
	new count = 1, players[32];
	new msg[191], text[191];
	
	vformat(msg, 190, input, 3);
	
	replace_all(msg, 190, "$4!"}, "^4");
	replace_all(msg, 190, "$1!"}, "^1");
	replace_all(msg, 190, "$3!"}, "^3"); 

	formatex(text, 190, "^4*pbT#^3 »^1 %s"}, msg);

	if (id) players[0] = id; else get_players(players, count, "ch")
	{
for (new i = 0; i < count; i++)
{
	if (is_user_connected(players[i]))
	{
message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, players[i]);
write_byte(players[i]);
write_string(text);
message_end();
	}
}
	}
	
return PLUGIN_HANDLED;
}

stock client_msgmode_w_lang(id, row)
{
	// Nyelv be�ll�t�s lek�rdez�se.
	
	new Lang[8];
	get_user_info(id, "lang"}, Lang, charsmax(Lang));
	
	// Sz�veg �r�s el�k�sz�t�se a megfelel� nyelven.

	if(contain(Lang	, "hu") != -1)
client_cmd(id, "messagemode %s"}, MultiLangCmds[row][1]);
	else
client_cmd(id, "messagemode %s"}, MultiLangCmds[row][2]);
}

stock UTIL_DropWeapon(id, slot)
{
	if(!(1 <= slot <= 2))
return 0;
	
	new iCount; iCount = 0;
	new iEntity; iEntity = get_pdata_cbase(id, (367 + slot), 5);
	
	if(iEntity > 0)
	{
new iNext;
new szWeaponName[32];

do {
	iNext = get_pdata_cbase(iEntity, 42, 4);
	
	if(get_weaponname(cs_get_weapon_id(iEntity), szWeaponName, charsmax(szWeaponName)))
	{  
client_cmd(id, "%s; wait; drop %s"}, szWeaponName, szWeaponName);
iCount++;
	}
}

while(( iEntity = iNext) > 0);
	}
	
	return iCount;
}

public native_bbc_call_user_login(id)
{
	bbc_set_user_progress(id, 1);
	sql_user_account_check(id);
	
	return PLUGIN_HANDLED;
}

public native_bbc_call_user_login_post(id)
{
	sql_update_user_to_account(id, 1);
	cmdChooseteam(id);
	
	new Found = 0;
	
	for ( new i; i < ArraySize(g_UserIDs); i++ ) {

if ( ArrayGetCell(g_UserIDs, i) == bbc_get_user_id(id) )
	Found = 1;
	}
	
	if ( !Found ) {

sql_load_rows_from_items_user(id);
ArrayPushCell(g_UserIDs, bbc_get_user_id(id));
	}
	else {
new Data[ItemData];

for ( new i; i < ArraySize(g_Items); i++ ) {	
	
	ArrayGetArray(g_Items, i, Data);
	
	if ( Data[wd_item] == 1 && Data[wd_inuse] != -1 && Data[wd_owner] == bbc_get_user_id(id) ) {

g_Selected[id][Data[wd_inuse]] = i;
g_Picked[id][Data[wd_inuse]] = i;
	}
	
	if ( Data[wd_item] == 4 && Data[wd_inuse] != -1 && Data[wd_owner] == bbc_get_user_id(id) )
g_Music[id] = i;
	
	if ( Data[wd_item] == 6 && Data[wd_inuse] != -1 && Data[wd_owner] == bbc_get_user_id(id) )
g_Coin[id] = i;

	if ( Data[wd_item] == 4 && Data[wd_owner] == bbc_get_user_id(id) )
g_MusicKit[id] = i;
}
	}
	
	if ( g_Selected[id][CSW_M4A1] == -1 && g_M4A1[id] == 1 )
g_Selected[id][CSW_M4A1] = -2;
	
	if ( g_Admin[id][0] )
if ( (g_Admin[id][1] == -1) || ( g_Admin[id][1] > get_systime() ) )
	setUserAdmin(id);
	
	g_FullLoad[id] = 1;

	if ( is_user_alive(id) ) {

cmdBuy(id);
set_task(0.5, "reload_model"}, id);
	}
	
	if ( !g_Lv[id] )
g_Lv[id] = 1;

	new CurrentRank = ArrayFindValue(g_UserRanks, bbc_get_user_id(id))+1;
	
	if ( !g_Stats[id][8] || CurrentRank < g_Stats[id][8] )
g_Stats[id][8] = CurrentRank;

	/*
	if ( !g_Event[id][0] && ( g_Stats[id][0] + g_Stats[id][1] > 100 ) ) {
	
client_printcolor(id, "%L"}, id, "FGO_MSG_EVENT");
	
createItem(2, 12, bbc_get_user_id(id), 0);
createItem(2, 13, bbc_get_user_id(id), 0);

g_Event[id][0] = 1;
	}
	*/
	return PLUGIN_HANDLED;
}

stock set_weapons_timeidle(id, WeaponId ,Float:TimeIdle)
{
	if(!is_user_alive(id))
return;

	static entwpn; entwpn = fm_get_user_weapon_entity(id, WeaponId);
	
	if(!pev_valid(entwpn)) 
return;

	set_pdata_float(entwpn, 47, TimeIdle, 4);
	set_pdata_float(entwpn, 48, TimeIdle + 1.0, 4);
}

public reload_model(id)
	replace_weapon_models(id, cs_get_user_weapon(id));

public native_bbc_get_server_enabled(param)
	return g_Enabled[param];

public plugin_cfg()
{
	g_SqlTuple = SQL_MakeDbTuple(g_HOST, g_USERNAME, g_PASSWORD, g_DATABASE);
	
	g_Items = ArrayCreate(ItemData);
	g_UserIDs = ArrayCreate();
	g_Achvs = ArrayCreate(AchvData);
	g_UserRanks = ArrayCreate(1);
	
	sql_load_rows_count();
	sql_delete_empty();
	sql_update_row_market();
	sql_load_rows_from_achvs();
	sql_user_rank_select();
}

public plugin_end()
{
	SQL_FreeHandle(g_SqlTuple);
	ArrayDestroy(g_Items);
	ArrayDestroy(g_UserIDs);
	ArrayDestroy(g_Achvs);
}	
public sql_user_account_check(id)
{
	new Query[508] = EOS;
	new Len = 0;
	
	Len += format(Query[Len], charsmax(Query), "SELECT * FROM `final_go_register` ");
	Len += format(Query[Len], charsmax(Query)-Len, "WHERE `Id` = '%d'"}, bbc_get_user_id(id));
	
	new xData[2];
	xData[0] = id;
	xData[1] = get_user_userid(id);

	SQL_ThreadQuery(g_SqlTuple,"sql_user_account_check_thr"}, Query, xData, 2);
}

public sql_user_account_check_thr(FailState, Handle:Query, Error[], Errcode, xData[], DataSize, Float:Queuetime)
{
	if ( Errcode )
log_to_file("sql_error_found.log"}, Error);
	
	if ( FailState == TQUERY_CONNECT_FAILED )
set_fail_state("SQL: Hiba a Csatlakozaskor!");
	else if ( FailState == TQUERY_QUERY_FAILED )
set_fail_state("SQL: Hiba a Szerkezetben!");

	new id = xData[0];
	
	if ( xData[1] != get_user_userid(id) )
return;
	
	new iRowsFound = SQL_NumRows(Query);
	
	bbc_set_user_progress(id, 0);
	
	if(!iRowsFound)
	{
bbc_set_user_progress(id, 1);
sql_add_user_to_accounts(id);
	}
	else
	{
bbc_set_user_progress(id, 1);
sql_load_user_from_accounts(id);
	}
}
	
public sql_add_user_to_accounts(id)
{
	new NickName[191] = EOS;
	
	get_user_name(id, NickName, charsmax(NickName));
	format(NickName, charsmax(NickName), "%s"}, NickName);

	replace_all(NickName, 190, "\"}, "\\")
	replace_all(NickName, 190, "'"}, "\'")
	
	new Query[1016] = EOS;
	new Len = 0;
	
	Len += formatex(Query[Len], charsmax(Query), "INSERT INTO `final_go_register` ");
	Len += formatex(Query[Len], charsmax(Query) - Len, "(`Id`, `FirstLogin`, `LastLogin`, `LastName`)");
	Len += formatex(Query[Len], charsmax(Query) - Len, " VALUES ");
	Len += formatex(Query[Len], charsmax(Query) - Len, "('%d','%d','%d','%s');"}, bbc_get_user_id(id), get_systime(), get_systime(), NickName);
	
	new xData[2];
	xData[0] = id;
	xData[1] = get_user_userid(id);
	
	SQL_ThreadQuery(g_SqlTuple, "sql_add_user_to_accounts_thr"}, Query, xData, 2);
}

public sql_add_user_to_accounts_thr(FailState, Handle:Query, Error[], Errcode, xData[], DataSize, Float:Queuetime)
{
	if ( Errcode )
log_to_file("sql_error_found.log"}, Error);
	
	if ( FailState == TQUERY_CONNECT_FAILED )
set_fail_state("SQL: Hiba a Csatlakozaskor!");
	else if ( FailState == TQUERY_QUERY_FAILED )
set_fail_state("SQL: Hiba a Szerkezetben!");

	new id = xData[0];
	
	if ( xData[1] != get_user_userid(id) )
return;

	bbc_set_user_progress(id, 0);
	
	sql_load_user_from_accounts(id)
}

public sql_load_user_from_accounts(id)
{
	new Query[508] = EOS;
	new Len = 0;
	
	Len += format(Query[Len], charsmax(Query), "SELECT * FROM `final_go_register` ");
	Len += format(Query[Len], charsmax(Query)-Len, "WHERE `Id` = '%d';"}, bbc_get_user_id(id));
	
	new xData[2];
	xData[0] = id;
	xData[1] = get_user_userid(id);

	SQL_ThreadQuery(g_SqlTuple,"sql_load_user_from_accounts_thr"}, Query, xData, 2);
}

public sql_load_user_from_accounts_thr(FailState, Handle:Query, Error[], Errcode, xData[], DataSize, Float:Queuetime)
{
	if ( Errcode )
log_to_file("sql_error_found.log"}, Error);
	
	if ( FailState == TQUERY_CONNECT_FAILED )
set_fail_state("SQL: Hiba a Csatlakozaskor!");
	else if ( FailState == TQUERY_QUERY_FAILED )
set_fail_state("SQL: Hiba a Szerkezetben!");

	new id = xData[0];
	
	if ( xData[1] != get_user_userid(id) )
return;
	
	SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Money"), g_Money[id]);
	
	g_Elso[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "FirstLogin"));
	
	new Text[64];
	
	for ( new i; i < AchievementCount; i ++ )
	{
format(Text, charsmax(Text), "Achv%d"}, i);
g_Achievements[id][i] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, Text));
	}
	
	g_Option[id][0] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Opt0"));
	g_Option[id][1] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Opt1"));
	g_Option[id][2] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Opt2"));
	g_Option[id][3] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Opt3"));
	g_Option[id][4] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Opt4"));
	g_Option[id][5] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Opt5"));
	g_Rang[id][0] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "RangLvL"));
	g_Rang[id][1] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "RangScR"));
	g_Admin[id][0] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "AdminLvL"));
	g_Admin[id][1] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "AdminExp"));
	g_rwTCash[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Cash"));
	g_Developer[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Developer"));
	g_Xp[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Xp"));
	g_Lv[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Lv"));
	g_OPSt[id][0] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "OP_St0"));
	g_OPSt[id][1] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "OP_St1"));
	g_OPSt[id][2] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "OP_St2"));
	g_DamageStop[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "DamageStop"));
	g_Stats[id][0] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "StatsKilledCT"));
	g_Stats[id][1] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "StatsKilledTE"));
	g_Stats[id][2] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "StatsPlantedC4"));
	g_Stats[id][3] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "StatsDefusedC4"));
	g_Stats[id][4] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "StatsOnlineTime"));
	g_Stats[id][5] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "StatsRescuedHost"));
	g_Stats[id][6] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "StatsDealedDamage"));
	g_Stats[id][7] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "StatsKilled"));
	g_Stats[id][8] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "StatsBest"));
	g_Stats[id][9] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "StatsScore"));
	g_M4A1[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "M4A1"));
	g_Event[id][0] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Ev0"));
	
	g_iFragPlaces[id][0] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "FragFirstPlace"));
	g_iFragPlaces[id][1] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "FragSecondPlace"));
	g_iFragPlaces[id][2] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "FragThirdPlace"));

	bbc_set_user_progress(id, 0);
	bbc_call_user_back(id);
}

public client_disconnected(id)
{
	sql_update_user_to_account(id, 0);
	trade_disconnect_sect(id);
	
	g_CountedKillsThisRound[id] = 0;
}

public sql_update_user_to_account(id, logged)
{
	if(bbc_get_user_id(id))
	{
new NickName[128];

get_user_name(id, NickName, charsmax(NickName));
	
replace_all(NickName, charsmax(NickName), "\"}, "\\")
replace_all(NickName, charsmax(NickName), "'"}, "\'")

static Query[4096];
new Len = 0;

Len += formatex(Query[Len], charsmax(Query), "UPDATE `final_go_register` SET ");

if(!g_Elso[id])
{
	 g_Elso[id] = get_systime();
	 Len += formatex(Query[Len], charsmax(Query) - Len, "FirstLogin = '%d', "}, g_Elso[id]);
}

if(!g_Utolso[id])
{
	 g_Utolso[id] = get_systime();
	 Len += formatex(Query[Len], charsmax(Query) - Len, "LastLogin = '%d', "}, g_Utolso[id]);
}

for ( new i; i < AchievementCount; i ++ )
{
	Len += formatex(Query[Len], charsmax(Query) - Len, "Achv%d = '%d', "}, i, g_Achievements[id][i]);
}

Len += formatex(Query[Len], charsmax(Query) - Len, "Opt0 = '%d', "}, g_Option[id][0]);
Len += formatex(Query[Len], charsmax(Query) - Len, "Opt1 = '%d', "}, g_Option[id][1]);
Len += formatex(Query[Len], charsmax(Query) - Len, "Opt2 = '%d', "}, g_Option[id][2]);
Len += formatex(Query[Len], charsmax(Query) - Len, "Opt3 = '%d', "}, g_Option[id][3]);
Len += formatex(Query[Len], charsmax(Query) - Len, "Opt4 = '%d', "}, g_Option[id][4]);
Len += formatex(Query[Len], charsmax(Query) - Len, "Opt5 = '%d', "}, g_Option[id][5]);
Len += formatex(Query[Len], charsmax(Query) - Len, "RangLvL = '%d', "}, g_Rang[id][0]);
Len += formatex(Query[Len], charsmax(Query) - Len, "RangScR = '%d', "}, g_Rang[id][1]);
Len += formatex(Query[Len], charsmax(Query) - Len, "Money = '%.2f', "}, g_Money[id]);
Len += formatex(Query[Len], charsmax(Query) - Len, "Cash = '%d', "}, g_rwTCash[id]);
Len += formatex(Query[Len], charsmax(Query) - Len, "Xp = '%d', "}, g_Xp[id]);
Len += formatex(Query[Len], charsmax(Query) - Len, "Lv = '%d', "}, g_Lv[id]);
Len += formatex(Query[Len], charsmax(Query) - Len, "OP_St0 = '%d', "}, g_OPSt[id][0]);
Len += formatex(Query[Len], charsmax(Query) - Len, "OP_St1 = '%d', "}, g_OPSt[id][1]);
Len += formatex(Query[Len], charsmax(Query) - Len, "OP_St2 = '%d', "}, g_OPSt[id][2]);
Len += formatex(Query[Len], charsmax(Query) - Len, "StatsKilledCT = '%d', "}, g_Stats[id][0]);
Len += formatex(Query[Len], charsmax(Query) - Len, "StatsKilledTE = '%d', "}, g_Stats[id][1]);
Len += formatex(Query[Len], charsmax(Query) - Len, "StatsPlantedC4 = '%d', "}, g_Stats[id][2]);
Len += formatex(Query[Len], charsmax(Query) - Len, "StatsDefusedC4 = '%d', "}, g_Stats[id][3]);
Len += formatex(Query[Len], charsmax(Query) - Len, "StatsOnlineTime = '%d', "}, g_Stats[id][4]);
Len += formatex(Query[Len], charsmax(Query) - Len, "StatsRescuedHost = '%d', "}, g_Stats[id][5]);
Len += formatex(Query[Len], charsmax(Query) - Len, "StatsDealedDamage = '%d', "}, g_Stats[id][6]);
Len += formatex(Query[Len], charsmax(Query) - Len, "StatsKilled = '%d', "}, g_Stats[id][7]);
Len += formatex(Query[Len], charsmax(Query) - Len, "StatsBest = '%d', "}, g_Stats[id][8]);
Len += formatex(Query[Len], charsmax(Query) - Len, "StatsScore = '%d', "}, g_Stats[id][9]);
Len += formatex(Query[Len], charsmax(Query) - Len, "Logged = '%d', "}, logged);
Len += formatex(Query[Len], charsmax(Query) - Len, "M4A1 = '%d', "}, g_M4A1[id]);

Len += formatex(Query[Len], charsmax(Query) - Len, "FragFirstPlace = '%d', "}, g_iFragPlaces[id][0]);
Len += formatex(Query[Len], charsmax(Query) - Len, "FragSecondPlace = '%d', "}, g_iFragPlaces[id][1]);
Len += formatex(Query[Len], charsmax(Query) - Len, "FragThirdPlace = '%d', "}, g_iFragPlaces[id][2]);

Len += formatex(Query[Len], charsmax(Query) - Len, "Ev0 = '%d', "}, g_Event[id][0]);
Len += formatex(Query[Len], charsmax(Query) - Len, "LastName = '%s' "}, NickName);
Len += formatex(Query[Len], charsmax(Query) - Len, "WHERE `Id` = '%d';"}, bbc_get_user_id(id));
	
SQL_ThreadQuery(g_SqlTuple,"sql_update_user_to_account_thr"}, Query);
	}
}

public sql_update_user_to_account_thr(FailState, Handle:Query, Error[], Errcode, xData[], DataSize, Float:Queuetime)
{
	if ( Errcode )
log_to_file("sql_error_found.log"}, Error);
	
	if ( FailState == TQUERY_CONNECT_FAILED )
set_fail_state("SQL: Hiba a Csatlakozaskor!");
	else if ( FailState == TQUERY_QUERY_FAILED )
set_fail_state("SQL: Hiba a Szerkezetben!");
}

public sql_add_row_to_items(Item, Sub, Owner, StatTrak)
{
	new Query[1024] = EOS;
	new Len = 0;
	
	Len += formatex(Query[Len], charsmax(Query), "INSERT INTO `final_go_items` ");
	Len += formatex(Query[Len], charsmax(Query) - Len, "(`Item`, `Sub`, `Owner`, `Added`, `Traded`, `New`, `Stattrak`)");
	Len += formatex(Query[Len], charsmax(Query) - Len, " VALUES ");
	Len += formatex(Query[Len], charsmax(Query) - Len, "('%d', '%d', '%d', '%d', '%d', '1', '%d');"}, Item, Sub, Owner, get_systime(), get_systime(), StatTrak);
	
	SQL_ThreadQuery(g_SqlTuple, "sql_add_row_to_items_thr"}, Query);
	
	// log_to_file( "go_final_item_add_pre.log"}, "An Item Added to Sql! (%d|%d|%d|%d|%d)"}, g_GlobalArraySize, Item, Sub, Owner, StatTrak);
}

public sql_add_row_to_items_thr(FailState, Handle:Query, Error[], Errcode, xData[], DataSize, Float:Queuetime)
{
	if ( Errcode )
log_to_file("sql_error_found.log"}, Error);
	
	if ( FailState == TQUERY_CONNECT_FAILED )
set_fail_state("SQL: Hiba a Csatlakozaskor!");
	else if ( FailState == TQUERY_QUERY_FAILED )
set_fail_state("SQL: Hiba a Szerkezetben!");
}

public sql_load_rows_from_achvs()
{
	new Query[1024] = EOS;
	new Len = 0;
	
	Len += formatex(Query[Len], charsmax(Query), "SELECT Reward, Target, HU_Name, CONVERT(CAST(`HU_Name` as BINARY) USING latin1) AS HU_NameLatin1 FROM `final_go_achvs`");

	SQL_ThreadQuery(g_SqlTuple, "sql_load_rows_from_achvs_thr"}, Query);
}

public sql_load_rows_from_achvs_thr(FailState, Handle:Query, Error[], Errcode, xData[], DataSize, Float:Queuetime)
{
	if ( Errcode )
log_to_file("sql_error_found.log"}, Error);
	
	if ( FailState == TQUERY_CONNECT_FAILED )
set_fail_state("SQL: Hiba a Csatlakozaskor!");
	else if ( FailState == TQUERY_QUERY_FAILED )
set_fail_state("SQL: Hiba a Szerkezetben!");

	new Data[AchvData];

	while ( SQL_MoreResults(Query) )
	{
Data[ad_reward] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Reward"));
Data[ad_target] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Target"));

SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "HU_Name"), Data[ad_name_hu], charsmax(Data[ad_name_hu]));
SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "HU_NameLatin1"), Data[ad_name_hu_latin1], charsmax(Data[ad_name_hu_latin1]));

ArrayPushArray(g_Achvs, Data);
SQL_NextRow(Query);
	}
}

public sql_delete_empty()
{
	new Query[508] = EOS;
	new Len = 0;
	
	Len += formatex(Query[Len], charsmax(Query), "DELETE FROM `final_go_items` WHERE `Item` = '0';");

	SQL_ThreadQuery(g_SqlTuple, "sql_delete_empty_thr"}, Query);
}

public sql_delete_empty_thr(FailState, Handle:Query, Error[], Errcode, xData[], DataSize, Float:Queuetime)
{
	if ( Errcode )
log_to_file("sql_error_found.log"}, Error);
	
	if ( FailState == TQUERY_CONNECT_FAILED )
set_fail_state("SQL: Hiba a Csatlakozaskor!");
	else if ( FailState == TQUERY_QUERY_FAILED )
set_fail_state("SQL: Hiba a Szerkezetben!");
}

public sql_load_rows_count()
{
	new Query[508] = EOS;
	new Len = 0;
	
	Len += formatex(Query[Len], charsmax(Query), "SELECT MAX(Id) AS Rows FROM `final_go_items`");

	SQL_ThreadQuery(g_SqlTuple, "sql_load_rows_count_thr"}, Query);
}

public sql_load_rows_count_thr(FailState, Handle:Query, Error[], Errcode, xData[], DataSize, Float:Queuetime)
{
	if ( Errcode )
log_to_file("sql_error_found.log"}, Error);
	
	if ( FailState == TQUERY_CONNECT_FAILED )
set_fail_state("SQL: Hiba a Csatlakozaskor!");
	else if ( FailState == TQUERY_QUERY_FAILED )
set_fail_state("SQL: Hiba a Szerkezetben!");

	if ( Query )
	{
g_GlobalArraySize = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Rows"));

sql_load_rows_from_items();
	}
	
	// log_to_file("go_final_items_load_post.log"}, "The Rows Count is %i..."}, g_GlobalArraySize);
}

public sql_load_rows_from_items()
{
	new Query[508] = EOS;
	new Len = 0;
	
	Len += formatex(Query[Len], charsmax(Query), "SELECT * FROM `final_go_items` WHERE `Item` > '0' AND `Market` = '1';");

	SQL_ThreadQuery(g_SqlTuple, "sql_load_rows_from_items_thr"}, Query);
}

public sql_load_rows_from_items_thr(FailState, Handle:Query, Error[], Errcode, xData[], DataSize, Float:Queuetime)
{
	if ( Errcode )
log_to_file("sql_error_found.log"}, Error);
	
	if ( FailState == TQUERY_CONNECT_FAILED )
set_fail_state("SQL: Hiba a Csatlakozaskor!");
	else if ( FailState == TQUERY_QUERY_FAILED )
set_fail_state("SQL: Hiba a Szerkezetben!");

	new Data[ItemData];
	ArrayPushArray(g_Items, Data);
	
	new Rows;

	while ( SQL_MoreResults(Query) )
	{
Data[wd_id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Id"));
Data[wd_item] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Item"));
Data[wd_sub] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Sub"));
Data[wd_owner] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Owner"));
Data[wd_added] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Added"));
Data[wd_traded] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Traded"));
Data[wd_new] = 0;
Data[wd_market] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Market"));
Data[wd_market_added] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "MarketAdded"));
Data[wd_stattrak] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Stattrak"));
Data[wd_stattrak_value] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "StattrakValue"));
Data[wd_inuse] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "InUse"));

SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "MarketAdder"), Data[wd_market_adder], charsmax(Data[wd_market_adder]));
SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Name"), Data[wd_name], charsmax(Data[wd_name]));
SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "MarketCost"), Data[wd_market_cost])

ArrayPushArray(g_Items, Data);
Rows ++;

SQL_NextRow(Query);
	}
	
	// log_to_file("go_final_items_load_post.log"}, "Items Loaded to Market Count is %i..."}, Rows);
}

public sql_load_rows_from_items_user(id)
{
	new Query[508] = EOS;
	new Len = 0;
	
	Len += formatex(Query[Len], charsmax(Query), "SELECT * FROM `final_go_items` WHERE Owner = '%d' AND `Item` > '0' AND `Market` = '0';"}, bbc_get_user_id(id));

	new xData[2];
	xData[0] = id;
	xData[1] = get_user_userid(id);
	
	SQL_ThreadQuery(g_SqlTuple, "sql_load_rows_from_items_u_thr"}, Query, xData, 2);
}

public sql_load_rows_from_items_u_thr(FailState, Handle:Query, Error[], Errcode, xData[], DataSize, Float:Queuetime)
{
	if ( Errcode )
log_to_file("sql_error_found.log"}, Error);
	
	if ( FailState == TQUERY_CONNECT_FAILED )
set_fail_state("SQL: Hiba a Csatlakozaskor!");
	else if ( FailState == TQUERY_QUERY_FAILED )
set_fail_state("SQL: Hiba a Szerkezetben!");

	new id = xData[0];

	if ( xData[1] != get_user_userid(id) )
return;

	new Data[ItemData];
	ArrayPushArray(g_Items, Data);
	
	new Rows;

	while ( SQL_MoreResults(Query) )
	{
Data[wd_id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Id"));
Data[wd_item] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Item"));
Data[wd_sub] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Sub"));
Data[wd_owner] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Owner"));
Data[wd_added] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Added"));
Data[wd_traded] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Traded"));
Data[wd_new] = 0;
Data[wd_market] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Market"));
Data[wd_market_added] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "MarketAdded"));
Data[wd_stattrak] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Stattrak"));
Data[wd_stattrak_value] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "StattrakValue"));
Data[wd_inuse] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "InUse"));

SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "MarketAdder"), Data[wd_market_adder], charsmax(Data[wd_market_adder]));
SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Name"), Data[wd_name], charsmax(Data[wd_name]));
SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "MarketCost"), Data[wd_market_cost])

ArrayPushArray(g_Items, Data);
Rows ++;

SQL_NextRow(Query);
	}
	
	for ( new i; i < ArraySize(g_Items); i++ )
	{	
ArrayGetArray(g_Items, i, Data);

if ( Data[wd_item] == 1 && Data[wd_inuse] != -1 && Data[wd_owner] == bbc_get_user_id(id) )
{
	g_Selected[id][Data[wd_inuse]] = i;
	g_Picked[id][Data[wd_inuse]] = i;
}

if ( Data[wd_item] == 4 && Data[wd_inuse] != -1 && Data[wd_owner] == bbc_get_user_id(id) )
	g_Music[id] = i;
	
if(Data[wd_item] == 6 && Data[wd_inuse] != -1 && Data[wd_owner] == bbc_get_user_id(id))
	g_Coin[id] = i;
	
if ( Data[wd_item] == 4 && Data[wd_owner] == bbc_get_user_id(id) )
	g_MusicKit[id] = i;
	}
	
	g_FullLoad[id] = 1;
	
	if ( is_user_alive(id) )
cmdBuy(id);
	
	// log_to_file("go_final_items_load_post.log"}, "Items Loaded to an User Count is %i..."}, Rows);
}

public sql_update_row_market()
{
	new Query[1024] = EOS;
	new Len = 0;
	
	Len += formatex(Query[Len], charsmax(Query), "UPDATE `final_go_items` SET ");
	Len += formatex(Query[Len], charsmax(Query) - Len, "`Market` = '0', ");
	Len += formatex(Query[Len], charsmax(Query) - Len, "`MarketAdded` = '0', ");
	Len += formatex(Query[Len], charsmax(Query) - Len, "`MarketAdder` = '-', ");
	Len += formatex(Query[Len], charsmax(Query) - Len, "`MarketCost` = '0', ");
	Len += formatex(Query[Len], charsmax(Query) - Len, "`New` = '1' ");
	Len += formatex(Query[Len], charsmax(Query) - Len, "WHERE MarketAdded < '%d';"}, get_systime() - (60*60*24*7));
	
	SQL_ThreadQuery(g_SqlTuple, "sql_update_row_market_thr"}, Query);
}

public sql_update_row_market_thr(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime)
{
	if ( Errcode )
log_to_file("sql_error_found.log"}, Error);
	
	if ( FailState == TQUERY_CONNECT_FAILED )
set_fail_state("SQL: Hiba a Csatlakozaskor!");
	else if ( FailState == TQUERY_QUERY_FAILED )
set_fail_state("SQL: Hiba a Szerkezetben!");
}

public sql_update_row_item(bid, bre)
{
	new Data[ItemData];
	ArrayGetArray(g_Items, bid, Data);
	
	new Query[1024] = EOS;
	new Len = 0;
	
	Len += formatex(Query[Len], charsmax(Query), "UPDATE `final_go_items` SET ");
	
	if(bre == 1)
	{
Len += formatex(Query[Len], charsmax(Query) - Len, "`New` = '%d' "}, Data[wd_new]);
	}
	else if(bre == 2)
	{
new NickName[128];
format(NickName, charsmax(NickName), "%s"}, Data[wd_market_adder]);
	
replace_all(NickName, charsmax(NickName), "\"}, "\\")
replace_all(NickName, charsmax(NickName), "'"}, "\'")

Len += formatex(Query[Len], charsmax(Query) - Len, "`Market` = '%d', "}, Data[wd_market]);
Len += formatex(Query[Len], charsmax(Query) - Len, "`MarketAdded` = '%d', "}, Data[wd_market_added]);
Len += formatex(Query[Len], charsmax(Query) - Len, "`MarketAdder` = '%s', "}, NickName);
Len += formatex(Query[Len], charsmax(Query) - Len, "`MarketCost` = '%.2f', "}, Data[wd_market_cost]);
Len += formatex(Query[Len], charsmax(Query) - Len, "`Owner` = '%d', "}, Data[wd_owner]);
Len += formatex(Query[Len], charsmax(Query) - Len, "`New` = '%d' "}, Data[wd_new]);
	}
	else if(bre == 3)
	{
Len += formatex(Query[Len], charsmax(Query) - Len, "`Stattrak` = '%d', "}, Data[wd_stattrak]);
Len += formatex(Query[Len], charsmax(Query) - Len, "`StattrakValue` = '%d' "}, Data[wd_stattrak_value]);
	}
	else if(bre == 4)
	{
Len += formatex(Query[Len], charsmax(Query) - Len, "`Item` = '%d' "}, Data[wd_item]);
	}
	else if(bre == 5)
	{
Len += formatex(Query[Len], charsmax(Query) - Len, "`Owner` = '%d' "}, Data[wd_owner]);
	}
	else if(bre == 6)
	{
Len += formatex(Query[Len], charsmax(Query) - Len, "`InUse` = '%d' "}, Data[wd_inuse]);
	}
	else if(bre == 7)
	{
new TagName[128];
format(TagName, charsmax(TagName), "%s"}, Data[wd_name]);
	
replace_all(TagName, charsmax(TagName), "\"}, "\\")
replace_all(TagName, charsmax(TagName), "'"}, "\'")

Len += formatex(Query[Len], charsmax(Query) - Len, "`Name` = '%s' "}, TagName);
	}
	
	Len += formatex(Query[Len], charsmax(Query) - Len, "WHERE Id = '%d';"}, Data[wd_id]);
	
	SQL_ThreadQuery(g_SqlTuple, "sql_update_row_item_thr"}, Query);
}

public sql_update_row_item_thr(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime)
{
	if ( Errcode )
log_to_file("sql_error_found.log"}, Error);
	
	if ( FailState == TQUERY_CONNECT_FAILED )
set_fail_state("SQL: Hiba a Csatlakozaskor!");
	else if ( FailState == TQUERY_QUERY_FAILED )
set_fail_state("SQL: Hiba a Szerkezetben!");
}

public sql_update_user_money(bbcid, Float:amount)
{
	new Query[508] = EOS;
	new Len = 0;
	
	Len += formatex(Query[Len], charsmax(Query), "UPDATE `final_go_register` SET ");
	Len += formatex(Query[Len], charsmax(Query) - Len, "`Money` = `Money` + '%.2f' "}, amount);
	Len += formatex(Query[Len], charsmax(Query) - Len, "WHERE Id = '%d';"}, bbcid);
	
	new xData[2];
	xData[0] = floatround(amount);
	xData[1] = bbcid;
	
	SQL_ThreadQuery(g_SqlTuple, "sql_update_user_money_thr"}, Query, xData, 2);
}

public sql_update_user_money_thr(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime)
{
	if ( Errcode )
log_to_file("sql_error_found.log"}, Error);

	log_to_file("fgo_market_payout.log"}, "#%d | %i.00 Dollár"}, Data[1], Data[0]);
	
	if ( FailState == TQUERY_CONNECT_FAILED )
set_fail_state("SQL: Hiba a Csatlakozaskor!");
	else if ( FailState == TQUERY_QUERY_FAILED )
set_fail_state("SQL: Hiba a Szerkezetben!");
}

public do_case_effect(Data[])
{
	new id = Data[0];
	new wo = Data[1];
	new cas = Data[2];
	new rand = Data[3];
	new stat = Data[4];
	
	new Array: Guns_In_Case;
	Guns_In_Case = ArrayCreate(1);
	
	new Weapon;
	new Winner;
	
	if(g_Click[id] == rand)
	{
for (new j; j < 7; j++)
{
	for (new i; i < sizeof Weapons; i++)
	{
if ( contain(Weapons[i][4], Cases[cas][0]) != -1 )
	ArrayPushCell(Guns_In_Case, i);
	}
	
	Weapon = random_num(0, ArraySize(Guns_In_Case)-1);
	Winner = ArrayGetCell(Guns_In_Case, Weapon);
	
	g_ClickEffect[id][j][0] = Winner;
	g_ClickEffect[id][j][1] = (random_num(1, 100) >= 70 ? 1 : 0);
}

g_BlockedMenu[id] = 1;
	}
	else if(g_Click[id])
	{
for (new i; i < sizeof Weapons; i++)
{
	if ( contain(Weapons[i][4], Cases[cas][0]) != -1 )
ArrayPushCell(Guns_In_Case, i);
}

Weapon = random_num(0, ArraySize(Guns_In_Case)-1);
Winner = ArrayGetCell(Guns_In_Case, Weapon);

if(g_Click[id] == 3)
{
	g_ClickEffect[id][0][0] = wo;
	g_ClickEffect[id][0][1] = stat;
}

g_ClickEffect[id][6][0] = g_ClickEffect[id][5][0];
g_ClickEffect[id][5][0] = g_ClickEffect[id][4][0];
g_ClickEffect[id][4][0] = g_ClickEffect[id][3][0];
g_ClickEffect[id][3][0] = g_ClickEffect[id][2][0];
g_ClickEffect[id][2][0] = g_ClickEffect[id][1][0];
g_ClickEffect[id][1][0] = g_ClickEffect[id][0][0];
g_ClickEffect[id][0][0] = Winner;

g_ClickEffect[id][6][1] = g_ClickEffect[id][5][1];
g_ClickEffect[id][5][1] = g_ClickEffect[id][4][1];
g_ClickEffect[id][4][1] = g_ClickEffect[id][3][1];
g_ClickEffect[id][3][1] = g_ClickEffect[id][2][1];
g_ClickEffect[id][2][1] = g_ClickEffect[id][1][1];
g_ClickEffect[id][1][1] = g_ClickEffect[id][0][1];
g_ClickEffect[id][0][1] = (random_num(1, 100) >= 70 ? 1 : 0);
	}
	else if(!g_Click[id])
	{
static player_name[32];
get_user_name(id, player_name, charsmax(player_name));

static players[32], pnum, taskid;
get_players(players, pnum);

for(new i; i < pnum; i++)
{
	taskid = players[i];
	client_printcolor(taskid, "%L"}, taskid, "T_OPENCASE"}, player_name, Cases[cas][0], Weapons[g_ClickEffect[id][3][0]][2], stat ? " (StatTrak*)" : "");

	if(Weapons[g_ClickEffect[id][3][0]][5][0] == C_YELLOW)
client_cmd(taskid, "spk %s/%s"}, MainFolder, YellowOpen);
}

new R[8], G[8], B[8];
parse(Types[Weapons[g_ClickEffect[id][3][0]][5][0]][1], R, charsmax(R), G, charsmax(G), B, charsmax(B));

message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("ScreenFade"), {0,0,0}, id);
write_short(1<<12);
write_short(1<<12);
write_short(0x0000);
write_byte(str_to_num(R));
write_byte(str_to_num(G));
write_byte(str_to_num(B));
write_byte(50);
message_end();

g_BlockedMenu[id] = 0;
	}
	
	if(g_Click[id])
	{
new Float:Time = 0.07*(rand-g_Click[id]);

new Data[5];
Data[0] = id;
Data[1] = wo;
Data[2] = cas;
Data[3] = rand;
Data[4] = stat;

set_task(Time, "do_case_effect"}, id, Data, sizeof(Data));
g_Click[id] --;

client_cmd(id, "spk weapons/ak47_boltpull.wav");
showMenu_CaseOpen(id, cas);
	}
}

showMenu_CaseOpen(id, casetype)
{
	new Menu[512], Len
	
	Len += formatex(Menu[Len], charsmax(Menu), "\r%L\w |\y %s %L\r *^n"}, id, "M_OUR_TEAM"}, Cases[casetype][0], id, "M_OPEN2");
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "^n");
	
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\d  %s %s^n"}, Weapons[g_ClickEffect[id][0][0]][2], g_ClickEffect[id][0][1] ? "(StatTrak*)" : "");
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\d%s %s^n"}, Weapons[g_ClickEffect[id][1][0]][2], g_ClickEffect[id][1][1] ? "(StatTrak*)" : "");
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\d  %s %s^n"}, Weapons[g_ClickEffect[id][2][0]][2], g_ClickEffect[id][2][1] ? "(StatTrak*)" : "");
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r->\w %s\d %s^n"}, Weapons[g_ClickEffect[id][3][0]][2], g_ClickEffect[id][3][1] ? "(StatTrak*)" : "");
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\d  %s %s^n"}, Weapons[g_ClickEffect[id][4][0]][2], g_ClickEffect[id][4][1] ? "(StatTrak*)" : "");
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\d%s %s^n"}, Weapons[g_ClickEffect[id][5][0]][2], g_ClickEffect[id][5][1] ? "(StatTrak*)" : "");
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\d  %s %s^n"}, Weapons[g_ClickEffect[id][6][0]][2], g_ClickEffect[id][6][1] ? "(StatTrak*)" : "");
	
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "^n");
	
	if (!g_Click[id])
	{
Len += formatex(Menu[Len], charsmax(Menu) - Len, "\r0.%s %L"}, g_Click[id] ? "\d" : "\w"}, id, "M_EXIT");
set_pdata_int(id, 205, 0);
show_menu(id, MENU_KEY_0, Menu, -1, "CaseOpen Menu");
	}
	else
	{
Len += formatex(Menu[Len], charsmax(Menu), "\r%L\w |\y %s %L\r *"}, id, "M_OUR_TEAM"}, Cases[casetype][0], id, "M_OPEN2");
set_pdata_int(id, 205, 0);
show_menu(id, -1, Menu, -1, "CaseOpen Menu");
	}
	
	return PLUGIN_HANDLED;
}

public menu_caseopen(id, key)
{
	if (!is_user_connected(id))
return PLUGIN_HANDLED;
	
	return PLUGIN_HANDLED;
}

public hook_say(id)
{
	read_args(Message, charsmax(Message));
	remove_quotes(Message);
	
	new arg1[16];
	new arg2[32];
 
	argbreak(Message, arg1, charsmax(arg1), arg2, charsmax(arg2))
 
	if ( equal(arg1, "/konvertalas"}, 12) || equal(arg1, "/convert"}, 8) )
cmdConvert(id, arg2);

	for(new i; i < sizeof Found; i++)
Found[i] = 0;
	
	while(Found[0] < strlen(Message))
	{
if(Message[Found[0]] == '.')
	Found[1] ++;
	
if(Message[Found[0]] == ':')
	Found[2] ++;
	
if(Message[Found[0]] == '1' || Message[Found[0]] == '2' || Message[Found[0]] == '3' || Message[Found[0]] == '4' || Message[Found[0]] == '5'
|| Message[Found[0]] == '6' || Message[Found[0]] == '7' || Message[Found[0]] == '8' || Message[Found[0]] == '9' || Message[Found[0]] == '0')
	Found[3] ++;
	
Found[0] ++;
	}

	if((contain(Message, "www.") != -1) || (contain(Message, "http://") != -1) || (contain(Message, "smmg.hu") != -1)
	|| (contain(Message, "diwat26.hu") != -1) || (contain(Message, "prokillers.hu") != -1))
Found[4] = 1;

	if ( bbc_get_user_muted(id) )
	{
client_print(id, print_center, "%L"}, id, "MSG_PLAYER_UNDER_MUTE");
return PLUGIN_HANDLED;
	}

	if((Found[1] >= 3 && Found[2] >= 1 && Found[0] >= 7) || Found[4])
	{
client_printcolor(id, "%L"}, id, "T_NO_REKLAM");
return PLUGIN_HANDLED;
	}

	if (Message[0] == '@' || equal (Message, "") || Message[0] == '/' || (contain(Message, "%") != -1) || !bbc_get_user_id(id))
return PLUGIN_HANDLED;

	if(equal(g_UtolsoUzenet[id], Message))
	{
client_printcolor(id, "%L"}, id, "T_NO_REPEAT");
return PLUGIN_HANDLED;
	}
	
	new Ip[16], Steam[32];
	get_user_ip(id, Ip, charsmax(Ip));
	get_user_authid(id, Steam, charsmax(Steam));
	
	if((contain(Message, "Spec_Help_Text") != -1)
	|| (contain(Message, "Spec_Duck") != -1)
	|| (contain(Message, "Cstrike_GIGN_Label") != -1)
	|| (contain(Message, "Cstrike_Spetsnaz_Label") != -1))
	{
log_to_file( "protect_me_containfix.log"}, "Str: %s | Ip: %s | SteamID: %s"}, Message, Ip, Steam);
return PLUGIN_HANDLED;
	}
	
	g_UtolsoUzenet[id] = Message;
	
	new AdminRang[33];
	
	if(g_Admin[id][0] >= 3)
AdminRang = "T_ADMIN3";
	else if(g_Admin[id][0] >= 2)
AdminRang = "T_ADMIN2";
	else if(g_Admin[id][0] >= 1)
AdminRang = "T_ADMIN1";

	new Name[33];
	get_user_name(id, Name, charsmax(Name));
	
	new MessageS[191];
	
	static players[32], pnum, is;
	get_players(players, pnum);
	
	for(new i; i < pnum; i++)
	{
is = players[i];
	
if ( is_user_connected(id) && !is_user_bot(is) )
{
	if ( !g_Admin[id][0] || (g_Admin[id][0] && g_Option[id][5]) )
formatex(MessageS, charsmax(MessageS), "^x01%s^x01[%s]^x03 %s:^x01 %s"}, is_user_alive(id) ? "" : "*DEAD* "}, Rangs[g_Rang[id][0]][0], Name, Message);
	else
formatex(MessageS, charsmax(MessageS), "^x01%s^x04[%L]^x01 [%s]^x03 %s:^x04 %s"}, is_user_alive(id) ? "" : "*DEAD* "}, is, AdminRang, Rangs[g_Rang[id][0]][0], Name, Message);

	if ( cs_get_user_team(id) == CS_TEAM_CT )
ColorChat(is, BLUE, MessageS);
	else if ( cs_get_user_team(id) == CS_TEAM_T )
ColorChat(is, RED, MessageS);
	else
ColorChat(is, GREY, MessageS);
}
	}
	
	new sql_team;
	
	if(cs_get_user_team(id) == CS_TEAM_CT)
sql_team = 0;
	else if(cs_get_user_team(id) == CS_TEAM_T)
sql_team = 1;
	else
sql_team = 2;
	
	sql_say_text_create(get_systime(), 0, is_user_alive(id) ? 1 : 0, sql_team, Name, Message, Ip, Steam);

	return PLUGIN_HANDLED;
}

public hook_teamsay(id)
{
	read_args(Message, charsmax(Message));
	remove_quotes(Message);

	for(new i; i < sizeof Found; i++)
Found[i] = 0;
	
	while(Found[0] < strlen(Message))
	{
if(Message[Found[0]] == '.')
	Found[1] ++;
	
if(Message[Found[0]] == ':')
	Found[2] ++;
	
if(Message[Found[0]] == '1' || Message[Found[0]] == '2' || Message[Found[0]] == '3' || Message[Found[0]] == '4' || Message[Found[0]] == '5'
|| Message[Found[0]] == '6' || Message[Found[0]] == '7' || Message[Found[0]] == '8' || Message[Found[0]] == '9' || Message[Found[0]] == '0')
	Found[3] ++;
	
Found[0] ++;
	}

	if((contain(Message, "www.") != -1) || (contain(Message, "http://") != -1) || (contain(Message, "smmg.hu") != -1)
	|| (contain(Message, "diwat26.hu") != -1) || (contain(Message, "prokillers.hu") != -1))
Found[4] = 1;

	if ( bbc_get_user_muted(id) )
	{
client_print(id, print_center, "%L"}, id, "MSG_PLAYER_UNDER_MUTE");
return PLUGIN_HANDLED;
	}

	if((Found[1] >= 3 && Found[2] >= 1 && Found[0] >= 7) || Found[4])
	{
client_printcolor(id, "%L"}, id, "T_NO_REKLAM");
return PLUGIN_HANDLED;
	}

	if (equal (Message, "") || Message[0] == '/' || (contain(Message, "%") != -1) || !bbc_get_user_id(id))
return PLUGIN_HANDLED;

	if(equal(g_UtolsoUzenet[id], Message))
	{
client_printcolor(id, "%L"}, id, "T_NO_REPEAT");
return PLUGIN_HANDLED;
	}
	
	new Ip[16], Steam[32];
	get_user_ip(id, Ip, charsmax(Ip));
	get_user_authid(id, Steam, charsmax(Steam));
	
	if((contain(Message, "Spec_Help_Text") != -1)
	|| (contain(Message, "Spec_Duck") != -1)
	|| (contain(Message, "Cstrike_GIGN_Label") != -1)
	|| (contain(Message, "Cstrike_Spetsnaz_Label") != -1))
	{
log_to_file( "protect_me_containfix.log"}, "Str: %s | Ip: %s | SteamID: %s"}, Message, Ip, Steam);
return PLUGIN_HANDLED;
	}
	
	g_UtolsoUzenet[id] = Message;
	
	new AdminRang[33];
	
	if(g_Admin[id][0] >= 3)
AdminRang = "T_ADMIN3";
	else if(g_Admin[id][0] >= 2)
AdminRang = "T_ADMIN2";
	else if(g_Admin[id][0] >= 1)
AdminRang = "T_ADMIN1";

	new Team[9];
	
	if(cs_get_user_team(id) == CS_TEAM_CT)
Team = "(CT)";
	else if(cs_get_user_team(id) == CS_TEAM_T)
Team = "(T)";
	else
Team = "(SPEC)";

	new Name[33];
	get_user_name(id, Name, charsmax(Name));
	
	new MessageS[191];
	
	static players[32], pnum, is;
	get_players(players, pnum);
	
	for(new i; i < pnum; i++)
	{
is = players[i];
	
if ( is_user_connected(id) && !is_user_bot(is) )
{
	if ( Message[0] == '@' )
	{
if ( g_Admin[is][0] )
{
	formatex(MessageS, charsmax(MessageS), "^x01-> ADMIN!^x03 %s:^x01 %s"}, Name, Message);

	if ( cs_get_user_team(id) == CS_TEAM_CT )
ColorChat(is, BLUE, MessageS);
	else if ( cs_get_user_team(id) == CS_TEAM_T )
ColorChat(is, RED, MessageS);
	else
ColorChat(is, GREY, MessageS);
}
	}
	else if ( cs_get_user_team(id) == cs_get_user_team(is) )
	{
if ( !g_Admin[id][0] || (g_Admin[id][0] && g_Option[id][5]) )
	formatex (MessageS, charsmax(MessageS), "^x01%s%s^x01 [%s]^x03 %s:^x01 %s"}, is_user_alive(id) ? "" : "*DEAD* "}, Team, Rangs[g_Rang[id][0]][0], Name, Message);
else
	formatex (MessageS, charsmax(MessageS), "^x01%s%s^x04 [%L]^x01 [%s]^x03 %s:^x04 %s"}, is_user_alive(id) ? "" : "*DEAD* "}, Team, is, AdminRang, Rangs[g_Rang[id][0]][0], Name, Message);
	
if ( cs_get_user_team(id) == CS_TEAM_CT )
	ColorChat(is, BLUE, MessageS);
else if ( cs_get_user_team(id) == CS_TEAM_T )
	ColorChat(is, RED, MessageS);
else
	ColorChat(is, GREY, MessageS);
	}
}
	}
	
	new sql_team;
	
	if(cs_get_user_team(id) == CS_TEAM_CT)
sql_team = 0;
	else if(cs_get_user_team(id) == CS_TEAM_T)
sql_team = 1;
	else
sql_team = 2;
	
	sql_say_text_create(get_systime(), 1, is_user_alive(id) ? 1 : 0, sql_team, Name, Message, Ip, Steam);

	return PLUGIN_HANDLED;
}

public do_add_money(id, Float: Money)
{
	g_Money[id] += Money;
	
	set_dhudmessage(random(255), random(255), random(255), -1.0, 0.2, 0, 6.0, 2.0);
	show_dhudmessage(id, "+%.2f Dollár"}, Money);
}

public do_make_rank(id)
{
	if(g_Option[id][2])
	{
if((sizeof Rangs-1 > g_Rang[id][0]) && g_Rang[id][1] >= Rangs[g_Rang[id][0]][1][0])
	g_Rang[id][0] ++;
else if((g_Rang[id][0] > 1) && (g_Rang[id][1] < Rangs[g_Rang[id][0]-1][1][0]))
	g_Rang[id][0] --;
	}
}

public showMenu_List(id)
{
	new Text[100], Count[64];
	new Data[ItemData];
	
	if(g_ListMode[id] == 1)
formatex(Text, 99, "\r%L\w |\y %L\r *\w"}, id, "M_OUR_TEAM"}, id, "M_MYITEMS");
	else if(g_ListMode[id] == 2)
formatex(Text, 99, "\r%L\w |\y %L\r *\w"}, id, "M_OUR_TEAM"}, id, "M_TRADEITEMS");
	
	new Menu = menu_create(Text, "createMenu_List");
	
	formatex(Text, 99, "\y%L\r |\y %.2f Dollár"}, id, "M_MONEYTRADE"}, (g_ListMode[id] == 1) ? g_TradeMoney[id] : g_TradeMoney[g_Trade[id]]);
	menu_additem(Menu, Text, "-100");

	for(new i; i < ArraySize(g_Items); i++)
	{
ArrayGetArray(g_Items, i, Data);
	
if((g_ListMode[id] == 1 && Data[wd_owner] == bbc_get_user_id(id))
|| (g_ListMode[id] == 2 && Data[wd_owner] == bbc_get_user_id(g_Trade[id])))
{
	if(Data[wd_item] == 1 && !Data[wd_market] && Data[wd_trade])
	{	
formatex(Text, 99, "%s%s"}, Weapons[Data[wd_sub]][2], Data[wd_stattrak] ? "\d (StatTrak*)" : "");
formatex(Count, charsmax(Count), "%d"}, i);
menu_additem(Menu, Text, Count);
	}
	else if(Data[wd_item] == 2 && !Data[wd_market] && !g_WrongCase[Data[wd_sub]] && Data[wd_trade])
	{	
formatex(Text, 99, "%s"}, Cases[Data[wd_sub]][0]);
formatex(Count, charsmax(Count), "%d"}, i);
menu_additem(Menu, Text, Count);
	}
	else if(Data[wd_item] == 3 && !Data[wd_market] && Data[wd_trade])
	{	
formatex(Text, 99, "%L"}, id, "M_KEY");
formatex(Count, charsmax(Count), "%d"}, i);
menu_additem(Menu, Text, Count);
	}
	else if(Data[wd_item] == 4 && !Data[wd_market] && Data[wd_trade])
	{	
formatex(Text, 99, "%s"}, Musics[Data[wd_sub]][0]);
formatex(Count, charsmax(Count), "%d"}, i);
menu_additem(Menu, Text, Count);
	}
	else if(Data[wd_item] == 5 && !Data[wd_market] && Data[wd_trade])
	{	
formatex(Text, 99, "%L"}, id, "M_NAMETAG");
formatex(Count, charsmax(Count), "%d"}, i);
menu_additem(Menu, Text, Count);
	}
}
	}
	
	formatex(Text, 99, "%L"}, id, "M_BACK");
	menu_setprop(Menu, MPROP_BACKNAME, Text);
	
	formatex(Text, 99, "%L"}, id, "M_NEXT");
	menu_setprop(Menu, MPROP_NEXTNAME, Text);
	
	formatex(Text, 99, "%L"}, id, "M_BACK_TO_TRADE");
	menu_setprop(Menu, MPROP_EXITNAME, Text);
	
	menu_display(id, Menu, g_Page[id]);
}

public createMenu_List(id, Menu, item)
{
	if( item == MENU_EXIT )
	{
showMenu_Trade(id);
return PLUGIN_HANDLED;
	}
	
	new data[32], iName[64], access, callback, All;
	menu_item_getinfo(Menu, item, access, data, 31, iName, 63, callback)
	
	new key = str_to_num(data);
	new Data[ItemData];
	
	for(new i; i < ArraySize(g_Items); i++)
	{
ArrayGetArray(g_Items, i, Data);
	
if((g_ListMode[id] == 1 && Data[wd_owner] == bbc_get_user_id(id))
|| (g_ListMode[id] == 2 && Data[wd_owner] == bbc_get_user_id(g_Trade[id])))
{
	if(Data[wd_item] == 1 && !Data[wd_market] && Data[wd_trade])
All ++;
	else if(Data[wd_item] == 2 && !Data[wd_market] && !g_WrongCase[Data[wd_sub]] && Data[wd_trade])
All ++;
	else if(Data[wd_item] == 3 && !Data[wd_market] && Data[wd_trade])
All ++;
	else if(Data[wd_item] == 4 && !Data[wd_market] && Data[wd_trade])
All ++;
}
	}
	
	g_Page[id] = (All-1)/7;
	
	if(g_ListMode[id] == 1)
	{
if(key != -100)
{
	g_Item[id] = key;
	showMenu_Item(id);
}
else
{
	showMenu_List(id);
	client_msgmode_w_lang(id, 5);
}
	}
	else if(g_ListMode[id] == 2)
showMenu_List(id);
	
	return PLUGIN_HANDLED;
}

public cmdTradeMoney(id)
{
	new Cost[11];
	read_args(Cost, 10);
	remove_quotes(Cost);
	
	if(equal(Cost, "") || equal(Cost, " "))
	{
showMenu_Trade(id);
return PLUGIN_HANDLED;
	}

	g_TradeMoney[id] = str_to_float(Cost);
	g_Ready[id] = 0;
	g_Ready[g_Trade[id]] = 0;
	
	if ( g_TradeMoney[id] < 	0.0 )
g_TradeMoney[id] = 0.0;
	
	if ( g_TradeMoney[id] > g_Money[id] )
g_TradeMoney[id] = g_Money[id];

	if ( g_Trade[id] && g_TradeMoney[id] != str_to_float(Cost) )
client_printcolor(g_Trade[id], "%L:$4! %.2f Dollár"}, g_Trade[id], "T_INVMON"}, g_TradeMoney[id]);
	
	if ( g_TradeMoney[id] != str_to_float(Cost) )
client_printcolor(id, "%L:$4! %.2f Dollár"}, id, "T_INVMONS"}, g_TradeMoney[id]);
	
	showMenu_Trade(id);
	showMenu_Trade(id);
	
	return PLUGIN_CONTINUE;
}

public showMenu_Players(id) {	
	
	new Text[128];
	formatex(Text, charsmax(Text), "\r%L\w |\y %L\r *\w"}, id, "M_OUR_TEAM"}, id, "M_TRADECENTER");
	
	new Menu = menu_create(Text, "createMenu_Players");
	
	new players[32], pnum, tempid;
	get_players(players, pnum, "ch");
	
	new name[32], sid[8], count;
	
	for ( new i; i < pnum; i++ ) {

tempid = players[i];

if ( id != tempid && bbc_get_user_id(id) && bbc_get_user_id(tempid) ) {
	
	get_user_name(tempid, name, charsmax(name));
	num_to_str(tempid, sid, charsmax(sid));
	
	if ( g_Option[tempid][4] && ( !g_Trade[tempid] || g_Trade[tempid] == id ) ) {

formatex(Text, charsmax(Text),"%s%s\d (#%d)"}, g_Trade[tempid] == id ? "\y" : "\w"}, name, bbc_get_user_id(tempid));
menu_additem(Menu, Text, sid);
	}
	else {

formatex(Text, charsmax(Text),"\d%s (#%d)"}, name, bbc_get_user_id(tempid));
menu_additem(Menu, Text, "-1"}, ADMIN_ADMIN);
	}
	
	count ++;
}
	}
	
	formatex(Text, charsmax(Text), "%L"}, id, "M_BACK");
	menu_setprop(Menu, MPROP_BACKNAME, Text);
	
	formatex(Text, charsmax(Text), "%L"}, id, "M_NEXT");
	menu_setprop(Menu, MPROP_NEXTNAME, Text);
	
	formatex(Text, charsmax(Text), "%L"}, id, "M_BACK_TO_TRADE");
	menu_setprop(Menu, MPROP_EXITNAME, Text);
	
	menu_display(id, Menu, g_Page[id]);
	
	if ( !count ) {

client_printcolor(id, "%L"}, id, "T_NO_PLAYERS");
showMenu_Trade(id)
	}
	
	return PLUGIN_HANDLED;
}

public createMenu_Players(id, menu, item) {

	if ( item == MENU_EXIT ) {

showMenu_Trade(id);
return PLUGIN_HANDLED;
	}
	
	new data[32], iName[64], access, callback;
	menu_item_getinfo(menu, item, access, data, 31, iName, 63, callback);
	
	new key = str_to_num(data);
	
	if ( key == -1 )
showMenu_Players(id);
	else {

if ( g_Trade[id] != key ) {
	
	g_Trade[id] = key;
	
	new name[32];
	get_user_name(id, name, charsmax(name));
	
	if ( g_Trade[g_Trade[id]] == id ) {

g_Trade[id] = key;

client_printcolor(key, "%L"}, id, "T_INVONDE"}, name);
showMenu_Trade(id);
	}
	else {

client_printcolor(key, "%L"}, id, "T_INVTOT"}, name);
showMenu_Trade(id);
	}
}
else
	showMenu_Trade(id);
	}
	
	return PLUGIN_HANDLED;
}

public showMenu_Achievements(id) {	
	
	new Text[128];
	formatex(Text, charsmax(Text), "\r%L\w |\y %L\r *\w"}, id, "OUR_TEAM"}, id, "TEXT_ACHVS_TITLE_ACHVS");
	
	new Menu = menu_create(Text, "createMenu_Achievements");
	
	new players[32], pnum, idx;
	get_players(players, pnum, "ch");
	
	new user_name[32], user_id[8];
	get_user_name(id, user_name, charsmax(user_name));
	num_to_str(bbc_get_user_id(id), user_id, charsmax(user_id));
	
	new achvs;
	
	for ( new j; j < AchievementCount; j++ ) {

if ( g_Achievements[id][j] >= 100000000 )
	achvs ++;
	}
	
	formatex(Text, charsmax(Text),"\y%s\d (#%d)\r (%.2f%%)"}, user_name, bbc_get_user_id(id), float(achvs)/AchievementCount*100);
	menu_additem(Menu, Text, user_id);
	
	for ( new i; i < pnum; i++ ) {

idx = players[i];

if ( id != idx && bbc_get_user_id(id) && bbc_get_user_id(idx)) {
	
	achvs = 0;
	
	for ( new j; j < AchievementCount; j++ ) {

if ( g_Achievements[idx][j] >= 100000000 )
	achvs ++;
	}
	
	get_user_name(idx, user_name, charsmax(user_name));
	num_to_str(bbc_get_user_id(idx), user_id, charsmax(user_id));
	formatex(Text, charsmax(Text),"%s\d (#%d)\r (%.2f%%)"}, user_name, bbc_get_user_id(idx), float(achvs)/AchievementCount*100);
	menu_additem(Menu, Text, user_id);
}
	}
	
	formatex(Text, charsmax(Text), "%L"}, id, "MENU_BUTTON_BACK");
	menu_setprop(Menu, MPROP_BACKNAME, Text);
	
	formatex(Text, charsmax(Text), "%L"}, id, "MENU_BUTTON_NEXT");
	menu_setprop(Menu, MPROP_NEXTNAME, Text);
	
	formatex(Text, charsmax(Text), "%L"}, id, "MENU_BUTTON_BACK_TO_MAIN");
	menu_setprop(Menu, MPROP_EXITNAME, Text);
	
	menu_display(id, Menu, 0);
	
	return PLUGIN_HANDLED;
}

public createMenu_Achievements(id, menu, item) {	
	
	if ( item == MENU_EXIT ) {

showMenu_Main(id);

return PLUGIN_HANDLED;
	}
	
	new data[32], iName[64], access, callback;
	menu_item_getinfo(menu, item, access, data, 31, iName, 63, callback);
	
	new Text[2048], Len;
	
	Len += formatex(Text[Len], charsmax(Text) - Len, "<html>");
	Len += formatex(Text[Len], charsmax(Text) - Len, "<head>");
	Len += formatex(Text[Len], charsmax(Text) - Len, "<title>Redirect</title>");
	Len += formatex(Text[Len], charsmax(Text) - Len, "<meta http-equiv=^"refresh^" content=^"http://pbt-server.webtan.eu"}, str_to_num(data));
	Len += formatex(Text[Len], charsmax(Text) - Len, "</head>");
	Len += formatex(Text[Len], charsmax(Text) - Len, "</html>");
	
	show_motd(id, Text);
	
	return PLUGIN_HANDLED;
}

public do_add_case()
{
	new Case, Float: All, Float: Random;
	
	for ( new i; i < sizeof Cases; i++ )
	{
if ( str_to_float(Cases[i][1]) > 0.0 )
	All += str_to_float( Cases[i][1] );
	}
	
	static players[32], pnum, id;
	get_players(players, pnum);

	for ( new i; i < pnum; i++ )
	{
id = players[i];

if ( is_user_connected(id) && !is_user_bot(id) && bbc_get_user_id(id) && cs_get_user_team(id) != CS_TEAM_SPECTATOR)
{
	if ( random_float(1.0, 100.0) <= 20.0 ) 
	{
Random = random_float(0.0, All);

for ( new j; j < sizeof Cases; j++ )
{
	if ( Random <= str_to_float(Cases[j][1]) )
	{
if ( Cases[j][2][0] == 1 )
	Case = j;
	}
}

createItem(2, Case, bbc_get_user_id(id), 0);

static player_name[32];
get_user_name(id, player_name, charsmax(player_name));

static players2[32], pnum2, id2;
get_players(players2, pnum2);

for(new i; i < pnum2; i++)
{
	id2 = players2[i];
	
	client_printcolor(id2, "%L"}, id2, "T_CASE_GIVEN"}, player_name, Cases[Case][0]);
}

// log_to_file( "go_final_case_add.log"}, "#%d | %d"}, bbc_get_user_id(id), Case);
	
Case = 0;
	}
}
	}
}

public trade_disconnect_sect(id)
{
	new Data[ItemData];

	for(new i; i < ArraySize(g_Items); i++)
	{
ArrayGetArray(g_Items, i, Data);
	
if(Data[wd_owner] == bbc_get_user_id(id) && Data[wd_trade])
{
	Data[wd_trade] = 0;
	ArraySetArray(g_Items, i, Data);
}
	}
	
	static players[32], pnum, id2;
	get_players(players, pnum);
	
	for(new i; i < pnum; i++)
	{
id2 = players[i];

if(g_Trade[id2] == id)
{
	g_Trade[id2] = 0;
	g_Ready[id2] = 0;
}
	}
	
	g_Trade[id] = 0;
	g_Ready[id] = 0;
	g_TradeMoney[id] = 0.0;
}

public setUserAdmin(id)
{
	if(g_Admin[id][0] >= 1)
	{
set_user_flags(id, ADMIN_KICK);
set_user_flags(id, ADMIN_BAN);
set_user_flags(id, ADMIN_CHAT);
set_user_flags(id, ADMIN_SLAY);
set_user_flags(id, ADMIN_VOTE);
set_user_flags(id, ADMIN_LEVEL_A);
set_user_flags(id, ADMIN_LEVEL_B);
set_user_flags(id, ADMIN_LEVEL_C);
set_user_flags(id, ADMIN_LEVEL_D),
set_user_flags(id, ADMIN_LEVEL_E);
set_user_flags(id, ADMIN_LEVEL_F);
set_user_flags(id, ADMIN_LEVEL_G);
set_user_flags(id, ADMIN_MENU);
set_user_flags(id, ADMIN_MAP);

remove_user_flags(id, ADMIN_USER);
	}
	
	if(g_Admin[id][0] >= 2)
	{
set_user_flags(id, ADMIN_LEVEL_H);
	}
	
	if(g_Admin[id][0] >= 3)
	{
set_user_flags(id, ADMIN_CVAR);
set_user_flags(id, ADMIN_CFG);
set_user_flags(id, ADMIN_PASSWORD);
set_user_flags(id, ADMIN_RCON);
	}
}

public removeUserAdmin(id)
{
	remove_user_flags(id, ADMIN_KICK);
	remove_user_flags(id, ADMIN_BAN);
	remove_user_flags(id, ADMIN_CHAT);
	remove_user_flags(id, ADMIN_SLAY);
	remove_user_flags(id, ADMIN_CHAT);
	remove_user_flags(id, ADMIN_VOTE);
	remove_user_flags(id, ADMIN_MAP);
	remove_user_flags(id, ADMIN_LEVEL_A);
	remove_user_flags(id, ADMIN_LEVEL_B);
	remove_user_flags(id, ADMIN_LEVEL_C);
	remove_user_flags(id, ADMIN_LEVEL_D);
	remove_user_flags(id, ADMIN_LEVEL_E);
	remove_user_flags(id, ADMIN_LEVEL_F);
	remove_user_flags(id, ADMIN_LEVEL_G);
	remove_user_flags(id, ADMIN_LEVEL_H);
	remove_user_flags(id, ADMIN_CVAR);
	remove_user_flags(id, ADMIN_CFG);
	remove_user_flags(id, ADMIN_RCON);
	remove_user_flags(id, ADMIN_PASSWORD);
	remove_user_flags(id, ADMIN_MENU),
	
	set_user_flags(id, ADMIN_USER);

	return PLUGIN_HANDLED;
}

public cmdSetAdmin(id) 
{ 
	if(g_Admin[id][0] >= 3 || !id)
	{
new Arg1[7], Arg2[2], Arg3[5];

read_argv(1, Arg1, 6);
read_argv(2, Arg2, 1);
read_argv(3, Arg3, 4);

new eId = str_to_num(Arg1);
new eRang = str_to_num(Arg2);
new eNap = str_to_num(Arg3);

static players[32], pnum, tempid, bool:found;
get_players(players, pnum);

if(eRang > 3)
	eRang = 3;

if(eId > 0)
{
	for(new i; i < pnum; i++)
	{
tempid = players[i];

if(!is_user_bot(tempid))
{
	if(bbc_get_user_id(tempid) == eId)
	{
if(eNap != 0 && eRang > 0)
{
	g_Admin[tempid][0] = eRang;
	
	if(eNap >= 0)
g_Admin[tempid][1] = get_systime()+(24*3600*eNap);
	else
g_Admin[tempid][1] = -1;

	setUserAdmin(tempid);

	sql_update_admin(eId, eRang, g_Admin[tempid][1]);
	
	static player_name[32]; get_user_name(tempid, player_name, charsmax(player_name));
	client_printcolor(id, "%L"}, id, "BBC_ADM_SET"}, player_name, eId, eNap);
}
else
{
	g_Admin[tempid][0] = 0;
	g_Admin[tempid][1] = 0;
	
	removeUserAdmin(tempid);
	
	sql_update_admin(eId, 0, get_systime());
	
	static player_name[32]; get_user_name(tempid, player_name, charsmax(player_name));
	client_printcolor(id, "%L"}, id, "BBC_ADM_REM"}, player_name, eId);
}

found = true;
	}
}
	}
	
	if(!found)
	{

if(eNap > 0 && eRang > 0)
{
	if(eNap >= 0)
sql_update_admin(eId, eRang, get_systime()+(24*3600*eNap));
	else
sql_update_admin(eId, eRang, -1);
	
	client_printcolor(id, "%L"}, id, "BBC_ADM_SET"}, "-"}, eId, eNap);
}
else
{
	sql_update_admin(eId, 0, get_systime());
	
	client_printcolor(id, "%L"}, id, "BBC_ADM_REM"}, "-"}, eId);
}
	}
}
	}
	else
client_printcolor(id, "!g*pbT#!t »!n %L"}, id, "BBC_ADM_ACCESS");

	return PLUGIN_HANDLED;
}

public sql_update_admin(gid, rang, timestamp)
{
	new Query[508] = EOS;
	new Len = 0;
	
	Len += formatex(Query[Len], charsmax(Query), "UPDATE `final_go_register` SET ");
	Len += formatex(Query[Len], charsmax(Query) - Len, "`AdminLvL` = '%d', "}, rang);
	Len += formatex(Query[Len], charsmax(Query) - Len, "`AdminExp` = '%d' "}, timestamp);
	Len += formatex(Query[Len], charsmax(Query) - Len, "WHERE Id = '%d';"}, gid);
	
	SQL_ThreadQuery(g_SqlTuple,"sql_update_admin_thr"}, Query)
}

public sql_update_admin_thr(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime)
{
	if ( Errcode )
log_to_file("sql_error_found.log"}, Error);
	
	if ( FailState == TQUERY_CONNECT_FAILED )
set_fail_state("SQL: Hiba a Csatlakozaskor!");
	else if ( FailState == TQUERY_QUERY_FAILED )
set_fail_state("SQL: Hiba a Szerkezetben!");
}

public sql_say_text_create(syst, type, alive, team, name[], text[], ip[], steamid[])
{
	new Query[508] = EOS;
	new Len = 0;
	
	new a[191], b[191];
	
	format(a, 190, "%s"}, name);
	format(b, 190, "%s"}, text);

	replace_all(a, 190, "\"}, "\\")
	replace_all(a, 190, "'"}, "\'")
	replace_all(b, 190, "\"}, "\\")
	replace_all(b, 190, "'"}, "\'")
	
	Len += formatex(Query[Len], charsmax(Query), "INSERT INTO `rwt_s1_say` ");
	Len += formatex(Query[Len], charsmax(Query) - Len, "(systime,type,alive,team,name,text,ip,steamid) VALUES('%d','%d','%d','%d','%s','%s','%s','%s')"}, syst, type, alive, team, a, b, ip, steamid);

	SQL_ThreadQuery(g_SqlTuple,"sql_say_text_create_thread_s"}, Query)
}

public sql_say_text_create_thread_s(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime)
{
	if ( Errcode )
log_to_file("sql_error_found.log"}, Error);
	
	if ( FailState == TQUERY_CONNECT_FAILED )
set_fail_state("SQL: Hiba a Csatlakozaskor!");
	else if ( FailState == TQUERY_QUERY_FAILED )
set_fail_state("SQL: Hiba a Szerkezetben!");
}

public fw_ClientUserInfoChanged(id)
	do_name_control(id);

public do_name_control(id)
{
	if(!is_user_connected(id))
return PLUGIN_CONTINUE;
 
	new name[32], ip[32], steamid[32];
	get_user_name(id, name, 31);
	get_user_ip(id, ip, 31);
	get_user_authid(id, steamid, 31);
 
	if((contain(name, "Spec_Help_Text") != -1)
	|| (contain(name, "Spec_Duck") != -1)
	|| (contain(name, "Cstrike_GIGN_Label") != -1)
	|| (contain(name, "Cstrike_Spetsnaz_Label") != -1))
	{
log_to_file( "protect_me_containfix.log"}, "Name: %s | Ip: %s | SteamID: %s"}, name, ip, steamid);

server_cmd("kick #%d ^"Ezt Bebuktad. ;)^""}, get_user_userid(id))

return PLUGIN_CONTINUE;
	}
	
	return PLUGIN_CONTINUE;
}

public do_complete_purchase()
{
	static players[32], pnum, tempid;
	get_players(players, pnum);

	for ( new j; j < pnum; j++ )
	{
tempid = players[j];

if ( is_user_connected(tempid) && !is_user_bot(tempid) && bbc_get_user_id(tempid) )
{
	new All;
	
	for ( new i; i < 64; i++ )
	{
if ( g_Purchase[i][0] )
{
	if ( bbc_get_user_id(tempid) == g_Purchase[i][2] )
	{
All += g_Purchase[i][1];

sql_update_purchase(g_Purchase[i][0]);

g_Purchase[i][0] = 0;
g_Purchase[i][1] = 0;
g_Purchase[i][2] = 0;
	}
}
	}
	
	if ( All )
	{
client_printcolor(tempid, "%L"}, tempid, "T_DONOR_GOT"}, do_num_to_str(All));

g_rwTCash[tempid] += All;

static players2[32], pnum2, tempid2;
get_players(players2, pnum2);

new client_name[32];
get_user_name(tempid, client_name, charsmax(client_name));

for ( new k; k < pnum2; k++ )
{
	tempid2 = players2[k];
	
	if ( is_user_connected(tempid2) && !is_user_bot(tempid2) && bbc_get_user_id(tempid2) )
	{
mcdhud_set(0, 255, 0, -1.0, 0.09, 0, 0.1, 5.5, 0.1, 0.1, 1, false);
	
if ( All >= 12000 )
{
	mcdhud_show(tempid2, "%L"}, tempid2, "H_ALL4"}, client_name, do_num_to_str(All));
	client_cmd(tempid2, "mp3 play sound/rivals_wow4.mp3");
}
else if ( All >= 6000 )
{
	mcdhud_show(tempid2, "%L"}, tempid2, "H_ALL3"}, client_name, do_num_to_str(All));
	client_cmd(tempid2, "mp3 play sound/rivals_wow2.mp3");
}
else if ( All >= 2000 )
{
	mcdhud_show(tempid2, "%L"}, tempid2, "H_ALL2"}, client_name, do_num_to_str(All));
	client_cmd(tempid2, "mp3 play sound/rivals_wow5.mp3");
}
else
{
	mcdhud_show(tempid2, "%L"}, tempid2, "H_ALL1"}, client_name, do_num_to_str(All));
	client_cmd(tempid2, "mp3 play sound/rivals_wow1.mp3");
}

if ( tempid != tempid2 )
	client_printcolor(tempid2, "%L"}, tempid2, "T_DONOR_ALL"}, client_name, do_num_to_str(All));
	}	
}

	}
	
	if ( All )
	{
if ( !g_rwTCash[tempid] )
	client_printcolor(tempid, "%L"}, tempid, "T_BALANCE_PRO"}, g_Money[tempid]);
else
	client_printcolor(tempid, "%L"}, tempid, "T_BALANCE_PRO2"}, g_Money[tempid], do_num_to_str(g_rwTCash[tempid]));
	}
}
	}
}

public sql_load_purchase()
{
	new Query[2048], Len;
	
	Len += formatex(Query[Len], charsmax(Query), "SELECT ");
	Len += formatex(Query[Len], charsmax(Query) - Len, "ID, UserID, Amount, Used FROM pgaming_buy_s1 ");
	Len += formatex(Query[Len], charsmax(Query) - Len, "WHERE Used = '0';")
	
	SQL_ThreadQuery(g_SqlTuple, "sql_load_purchase_thr"}, Query);
}

public sql_load_purchase_thr(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime)
{
	if ( Errcode )
log_to_file("sql_error_found.log"}, Error);
	
	if ( FailState == TQUERY_CONNECT_FAILED )
set_fail_state("SQL: Hiba a Csatlakozaskor!");
	else if ( FailState == TQUERY_QUERY_FAILED )
set_fail_state("SQL: Hiba a Szerkezetben!");

	new Count;
	
	while ( SQL_MoreResults(Query) )
	{
g_Purchase[Count][0] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "ID"));
g_Purchase[Count][1] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Amount"));
g_Purchase[Count][2] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "UserID"));

SQL_NextRow(Query);

Count ++;
	}
	
	do_complete_purchase();
}

public sql_update_purchase(pid)
{
	new Query[2048], Len;
	
	Len += formatex(Query[Len], charsmax(Query), "UPDATE pgaming_buy_s1 SET ");
	Len += formatex(Query[Len], charsmax(Query) - Len, "Used = '1' ");
	Len += formatex(Query[Len], charsmax(Query) - Len, "WHERE ID = '%d'"}, pid)

	SQL_ThreadQuery(g_SqlTuple,"sql_update_purchase_thr"}, Query)
}

public sql_update_purchase_thr(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime)
{
	if ( Errcode )
log_to_file("sql_error_found.log"}, Error);
	
	if ( FailState == TQUERY_CONNECT_FAILED )
set_fail_state("SQL: Hiba a Csatlakozaskor!");
	else if ( FailState == TQUERY_QUERY_FAILED )
set_fail_state("SQL: Hiba a Szerkezetben!");
}

public do_operaton_drop(id)
{
	new player_name[32];
	get_user_name(id, player_name, charsmax(player_name));
	
	new Array: Guns_In_Case;
	Guns_In_Case = ArrayCreate(1);
	
	static players2[32], pnum2, id2;
	get_players(players2, pnum2);
	
	new CaseName[64];

	if ( !random_num(0,3) )
	{
format(CaseName, charsmax(CaseName), "Operation Phoenix");

if ( !random_num(0,11) )
{
	for (new j; j < sizeof Weapons; j++)
	{
if ( contain(Weapons[j][7], CaseName) != -1 )
	if (C_RED == Weapons[j][5][0])
ArrayPushCell(Guns_In_Case, j);
	}
}
else if ( !random_num(0,5) )
{
	for (new j; j < sizeof Weapons; j++)
	{
if (contain(Weapons[j][7], CaseName) != -1)
	if (C_PINK == Weapons[j][5][0])
ArrayPushCell(Guns_In_Case, j);
	}
}
else
{
	for (new j; j < sizeof Weapons; j++)
	{
if (contain(Weapons[j][7], CaseName) != -1)
	if (C_PURPLE == Weapons[j][5][0])
ArrayPushCell(Guns_In_Case, j);
	}
}

new Weapon = random_num(0, ArraySize(Guns_In_Case)-1);
new Winner = ArrayGetCell(Guns_In_Case, Weapon);

createItem(1, Winner, bbc_get_user_id(id), 0);

for(new i; i < pnum2; i++)
{
	id2 = players2[i];
	client_printcolor(id2, "%L"}, id2, "T_OP_DROP_WPN"}, player_name, Weapons[Winner][2], Coins[3][0]);
}

new R[8], G[8], B[8];
parse(Types[Weapons[Winner][5][0]][1], R, charsmax(R), G, charsmax(G), B, charsmax(B));

message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("ScreenFade"), {0,0,0}, id);
write_short(1<<12);
write_short(1<<12);
write_short(0x0000);
write_byte(str_to_num(R));
write_byte(str_to_num(G));
write_byte(str_to_num(B));
write_byte(50);
message_end();
	}
	else
	{
for(new i; i < pnum2; i++)
{
	id2 = players2[i];
	
	client_printcolor(id2, "%L"}, id2, "T_OP_DROP_CASE"}, player_name, Cases[13][0], Coins[3][0]);
}

message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("ScreenFade"), {0,0,0}, id);
write_short(1<<12);
write_short(1<<12);
write_short(0x0000);
write_byte(10);
write_byte(250);
write_byte(200);
write_byte(50);
message_end();

createItem(2, 13, bbc_get_user_id(id), 0);
	}
}

public plugin_log()
{
	new logdata0[128], logdata1[64], logdata2[64], logdata3[64];
	new name[32], id;

	read_logargv(0,logdata0, charsmax(logdata0));
	read_logargv(1,logdata1, charsmax(logdata1));
	read_logargv(2,logdata2, charsmax(logdata2));
	read_logargv(3,logdata3, charsmax(logdata3));

	if ( equal(logdata1,"triggered") )
	{
parse_loguser(logdata0, name, charsmax(name));
id = get_user_index(name);

if ( equal(logdata2,"Rescued_A_Hostage") ) 
{
	g_Stats[id][5] ++;
	g_Stats[id][9] += 2;
}	
else if ( equal(logdata2,"Begin_Bomb_Defuse_Without_Kit") )
{
	g_BombDefusing = id;
}
else if ( equal(logdata2,"Begin_Bomb_Defuse_With_Kit") )
{
	g_BombDefusing = id;
}
else if ( equal(logdata2,"Defused_The_Bomb") )
{
	native_bbc_set_user_achv(id, 5, native_bbc_get_user_achv(id, 5) + 1);
	g_Stats[id][9] += 3;
	g_Stats[id][3] ++;
}
else if ( equal(logdata2,"Planted_The_Bomb") )
{
	g_BombPlanted = id;
	
	g_Stats[id][9] += 3;
	g_Stats[id][2] ++;

	native_bbc_set_user_achv(id, 1, native_bbc_get_user_achv(id, 1) + 1);
	
	if ( g_RoundStart + 25 > get_systime() )
native_bbc_set_user_achv(id, 6, native_bbc_get_user_achv(id, 6) + 1);
}
else
	g_BombDefusing = -1;
	}
	else if ( equal(logdata3, "Target_Bombed") )
	{
if ( g_BombPlanted )
	native_bbc_set_user_achv(g_BombPlanted, 0, native_bbc_get_user_achv(g_BombPlanted, 0) + 1);
	}
}

public cmdRankStats(id)
{
	new Page[2048], iLen;

	sql_update_user_to_account(id, 1);
	
	iLen += formatex(Page[iLen], charsmax(Page) - iLen, "<html>");
	iLen += formatex(Page[iLen], charsmax(Page) - iLen, "<head>");
	iLen += formatex(Page[iLen], charsmax(Page) - iLen, "<title>Redirect</title>");
	iLen += formatex(Page[iLen], charsmax(Page) - iLen, "<meta http-equiv=^"refresh^" content=^"0;http://rivals.sunwell.hu/s1_rankstats.php?ID=%i^">"}, bbc_get_user_id(id));
	iLen += formatex(Page[iLen], charsmax(Page) - iLen, "</head>");
	iLen += formatex(Page[iLen], charsmax(Page) - iLen, "</html>");
	
	show_motd(id, Page);
	
	return PLUGIN_HANDLED;
}

public cmdFrags(id)
{
	new Page[2048], iLen;

	iLen += formatex(Page[iLen], charsmax(Page) - iLen, "<html>");
	iLen += formatex(Page[iLen], charsmax(Page) - iLen, "<head>");
	iLen += formatex(Page[iLen], charsmax(Page) - iLen, "<title>Redirect</title>");
	iLen += formatex(Page[iLen], charsmax(Page) - iLen, "<meta http-equiv=^"refresh^" content=^"0;http://rivals.sunwell.hu/s1_frags.php^">");
	iLen += formatex(Page[iLen], charsmax(Page) - iLen, "</head>");
	iLen += formatex(Page[iLen], charsmax(Page) - iLen, "</html>");
	
	show_motd(id, Page);
	
	return PLUGIN_HANDLED;
}

public cmdTop15(id)
{
	new Page[2048], iLen;

	iLen += formatex(Page[iLen], charsmax(Page) - iLen, "<html>");
	iLen += formatex(Page[iLen], charsmax(Page) - iLen, "<head>");
	iLen += formatex(Page[iLen], charsmax(Page) - iLen, "<title>Redirect</title>");
	iLen += formatex(Page[iLen], charsmax(Page) - iLen, "<meta http-equiv=^"refresh^" content=^"0;http://rivals.sunwell.hu/s1_top15.php^">");
	iLen += formatex(Page[iLen], charsmax(Page) - iLen, "</head>");
	iLen += formatex(Page[iLen], charsmax(Page) - iLen, "</html>");
	
	show_motd(id, Page);
	
	return PLUGIN_HANDLED;
}

public cmdRank(id)
{	
	client_printcolor(id, "%L"}, id, "T_CURRANK"}, do_num_to_str(ArrayFindValue(g_UserRanks, bbc_get_user_id(id))+1), do_num_to_str(ArraySize(g_UserRanks)));
	
	return PLUGIN_HANDLED;
}

public sql_user_rank_select()
{
	new Query[1024], Len;
	
	Len += formatex(Query[Len], charsmax(Query) - Len, "SELECT `Id` FROM `final_go_register` ORDER BY `StatsScore` DESC");

	SQL_ThreadQuery(g_SqlTuple, "sql_user_rank_select_thr"}, Query);
}

public sql_user_rank_select_thr(FailState, Handle:Query, Error[], Errcode, xData[], DataSize, Float:Queuetime)
{
	if ( Errcode )
log_to_file("sql_error_found.log"}, Error);
	
	if ( FailState == TQUERY_CONNECT_FAILED )
set_fail_state("SQL: Hiba a Csatlakozaskor!");
	else if ( FailState == TQUERY_QUERY_FAILED )
set_fail_state("SQL: Hiba a Szerkezetben!");

	ArrayClear(g_UserRanks);

	while ( SQL_MoreResults(Query) )
	{
ArrayPushCell(g_UserRanks, SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Id")));

SQL_NextRow(Query);
	}
}

stock SendWeaponAnim(id, iAnim)
{
	entity_set_int(id, EV_INT_weaponanim, iAnim);
	message_begin(MSG_ONE/* _UNRELIABLE */, SVC_WEAPONANIM, _, id);
	write_byte(iAnim);
	write_byte(entity_get_int(id, EV_INT_body));
	message_end();
}

stock do_num_to_str(const inum)
{
	static istr[32], nstr[32];
	num_to_str(inum, istr, charsmax(istr));
	
	new len = (strlen(istr)-1)/3+strlen(istr);
	new count = -1;
	
	for(new i = strlen(istr); i >= 0; i--)
	{
nstr[len] = istr[i];
len --;
count ++;

if(count == 3 && len > 0)
{
	nstr[len] = '.';
	len --;
	count = 0;
}
	}
	
	return nstr;
}

public do_MOTD_CaseItems(id, caseid)
{
	new Text[1024], Len;

	Len += formatex(Text[Len], charsmax(Text) - Len, "<html><head><meta charset=^"UTF-8^"></head><body style=^"background-color:black^"><b><center><br><font style=^"color: white^">%s</font><br><br>"}, Cases[caseid][0]);
	
	new Array: BlueItems = ArrayCreate(1);
	new Array: PurpleItems = ArrayCreate(1);
	new Array: PinkItems = ArrayCreate(1);
	new Array: RedItems = ArrayCreate(1);
	new Array: YellowItems = ArrayCreate(1);
	
	for ( new i; i < sizeof Weapons; i++ )
	{
if ( contain(Weapons[i][4], Cases[caseid][0]) != -1 )
{
	if ( C_BLUE == Weapons[i][5][0] )
ArrayPushCell(BlueItems, i);
	else if ( C_PURPLE == Weapons[i][5][0] )
ArrayPushCell(PurpleItems, i);
	else if ( C_PINK == Weapons[i][5][0] )
ArrayPushCell(PinkItems, i);
	else if ( C_RED == Weapons[i][5][0] )
ArrayPushCell(RedItems, i);
	else if ( C_YELLOW == Weapons[i][5][0] )
ArrayPushCell(YellowItems, i);
}
	}
	
	Len += formatex(Text[Len], charsmax(Text) - Len, "<font style=^"color:blue^">");
	
	for ( new i; i < ArraySize(BlueItems); i++ )
Len += formatex(Text[Len], charsmax(Text) - Len, "%s<br>"}, Weapons[ArrayGetCell(BlueItems, i)][2]);

	Len += formatex(Text[Len], charsmax(Text) - Len, "</font>");
	
	Len += formatex(Text[Len], charsmax(Text) - Len, "<font style=^"color:BlueViolet^">");
	
	for ( new i; i < ArraySize(PurpleItems); i++ )
Len += formatex(Text[Len], charsmax(Text) - Len, "%s<br>"}, Weapons[ArrayGetCell(PurpleItems, i)][2]);

	Len += formatex(Text[Len], charsmax(Text) - Len, "</font>");
	
	Len += formatex(Text[Len], charsmax(Text) - Len, "<font style=^"color:DeepPink^">");
	
	for ( new i; i < ArraySize(PinkItems); i++ )
Len += formatex(Text[Len], charsmax(Text) - Len, "%s<br>"}, Weapons[ArrayGetCell(PinkItems, i)][2]);

	Len += formatex(Text[Len], charsmax(Text) - Len, "</font>");
	
	Len += formatex(Text[Len], charsmax(Text) - Len, "<font style=^"color:red^">");
	
	for ( new i; i < ArraySize(RedItems); i++ )
Len += formatex(Text[Len], charsmax(Text) - Len, "%s<br>"}, Weapons[ArrayGetCell(RedItems, i)][2]);

	Len += formatex(Text[Len], charsmax(Text) - Len, "</font>");
	
	Len += formatex(Text[Len], charsmax(Text) - Len, "<font style=^"color:yellow^">");
	
	for ( new i; i < ArraySize(YellowItems); i++ )
Len += formatex(Text[Len], charsmax(Text) - Len, "%s<br>"}, Weapons[ArrayGetCell(YellowItems, i)][2]);

	Len += formatex(Text[Len], charsmax(Text) - Len, "</font>");
	
	Len += formatex(Text[Len], charsmax(Text) - Len, "</center></b></body></html>");
	
	show_motd(id, Text);
}

public fw_Item_PostFrame(ent)
{
	static id; id = pev(ent, pev_owner);
	
	if ( !is_user_alive(id) )
return HAM_IGNORED

	new Data[ItemData];

	if ( g_Picked[id][CSW_M4A1] > -1 )
ArrayGetArray(g_Items, g_Picked[id][CSW_M4A1], Data);

	if ( g_Picked[id][CSW_M4A1] == -2 || contain(Weapons[Data[wd_sub]][2], "-S") != -1 )
	{
static Float:flNextAttack; flNextAttack = get_pdata_float(id, 83, 5);
static bpammo; bpammo = cs_get_user_bpammo(id, CSW_M4A1);

static iClip; iClip = get_pdata_int(ent, 51, 4);
static fInReload; fInReload = get_pdata_int(ent, 54, 4);

if ( fInReload && flNextAttack <= 0.0 )
{
	static temp1;
	temp1 = min(20 - iClip, bpammo);
	
	set_pdata_int(ent, 51, iClip + temp1, 4);
	cs_set_user_bpammo(id, CSW_M4A1, bpammo - temp1);	
	
	set_pdata_int(ent, 54, 0, 4);
	
	fInReload = 0;
}	
	}
	
	return HAM_IGNORED
}

public fw_Weapon_Reload(ent)
{
	static id; id = pev(ent, pev_owner);
	
	if ( !is_user_alive(id) )
return HAM_IGNORED;

	new Data[ItemData];

	if ( g_Picked[id][CSW_M4A1] > -1 )
ArrayGetArray(g_Items, g_Picked[id][CSW_M4A1], Data);

	if ( g_Picked[id][CSW_M4A1] == -2 || contain(Weapons[Data[wd_sub]][2], "-S") != -1 )
	{
g_M4A1_Clip[id] = -1;
	
static BPAmmo; BPAmmo = cs_get_user_bpammo(id, CSW_M4A1);
static iClip; iClip = get_pdata_int(ent, 51, 4);
	
if ( BPAmmo <= 0 )
	return HAM_SUPERCEDE;
	
if ( iClip >= 20 )
	return HAM_SUPERCEDE;	

g_M4A1_Clip[id] = iClip;
	}
	
	return HAM_HANDLED;
}

public fw_Weapon_Reload_Post(ent)
{
	static id; id = pev(ent, pev_owner);
	
	if( !is_user_alive(id) )
return HAM_IGNORED;

	new Data[ItemData];

	if ( g_Picked[id][CSW_M4A1] > -1 )
ArrayGetArray(g_Items, g_Picked[id][CSW_M4A1], Data);

	if ( g_Picked[id][CSW_M4A1] == -2 || contain(Weapons[Data[wd_sub]][2], "-S") != -1 )
	{
if ( (get_pdata_int(ent, 54, 4) == 1) )
{
	if ( g_M4A1_Clip[id] == -1 )
return HAM_IGNORED;
	
	set_pdata_int(ent, 51, g_M4A1_Clip[id], 4);
	set_pdata_float(id, 83, 3.0, 5);
}
	}
	
	return HAM_HANDLED;
}

stock precache_viewmodel_sound(const model[])
{
	new file, i, k;
	
	if ( (file = fopen(model, "rt")) )
	{
new szsoundpath[64], NumSeq, SeqID, Event, NumEvents, EventID;

fseek(file, 164, SEEK_SET);
fread(file, NumSeq, BLOCK_INT);
fread(file, SeqID, BLOCK_INT);

for ( i = 0; i < NumSeq; i ++ )
{
	fseek(file, SeqID + 48 + 176 * i, SEEK_SET);
	fread(file, NumEvents, BLOCK_INT);
	fread(file, EventID, BLOCK_INT);
	fseek(file, EventID + 176 * i, SEEK_SET);
	
	for ( k = 0; k < NumEvents; k ++ )
	{
fseek(file, EventID + 4 + 76 * k, SEEK_SET);
fread(file, Event, BLOCK_INT);
fseek(file, 4, SEEK_CUR);

if ( Event != 5004 )
	continue;

fread_blocks(file, szsoundpath, 64, BLOCK_CHAR);

if ( strlen(szsoundpath) )
{
	strtolower(szsoundpath);
	new Str[64];
	formatex(Str, charsmax(Str), "sound/%s"}, szsoundpath);
	
	if ( file_exists(Str) )
engfunc(EngFunc_PrecacheGeneric, Str);
}
	}
}
	}
	
	fclose(file);
}

public msgStatusIcon(msg_id, msg_dest, id)
{
	if ( !is_user_alive(id) )
return PLUGIN_CONTINUE;

	new icon[8];
	get_msg_arg_string(2, icon, charsmax(icon))
	
	if ( equal(icon, "buyzone") )
return PLUGIN_HANDLED;

	return PLUGIN_CONTINUE;
}

public cmdBuy2(id)
	return PLUGIN_HANDLED;

#if defined IS_HALLOWEEN_ENABLED

	public do_create_ent_for_halloween(const Float: fOrigin[3]) {
	
new ent = create_entity("info_target");
set_pev(ent, pev_classname, "HalloweenPumpkin");

new String[128];
formatex(String, charsmax(String), "models/%s/%s"}, MainFolder, GET_HALLOWEEN_PUMPKIN_MODEL_NAME);
entity_set_model(ent, String);

set_pev(ent, pev_origin, fOrigin);
set_pev(ent,pev_solid, SOLID_BBOX);
set_pev(ent, pev_movetype, MOVETYPE_TOSS);
engfunc(EngFunc_SetSize, ent, Float:{-10.0,-10.0,0.0}, Float:{10.0,10.0,25.0});
engfunc(EngFunc_DropToFloor, ent);

fm_set_rendering(ent, kRenderFxGlowShell, 200, 50, 0, kRenderNormal, 16);
	}
	
	public fw_Touch(toucher, touched) {

if ( !is_user_alive(toucher) || !pev_valid(touched) )
	return FMRES_IGNORED;

new classname[32];
pev(touched, pev_classname, classname, charsmax(classname));

if ( !equal(classname, "HalloweenPumpkin") )
	return FMRES_IGNORED;

new players[32], pnum;
get_players(players, pnum, "ch");

new user_name[32];
get_user_name(toucher, user_name, charsmax(user_name));

for ( new i; i < pnum; i++ )
	client_printcolor(players[i], "%L"}, players[i], "HALLOWEEN_CASE_ADDED"}, user_name);

createItem(2, 15, bbc_get_user_id(toucher), 0);
	
set_pev(touched, pev_effects, EF_NODRAW);
set_pev(touched, pev_solid, SOLID_NOT);
remove_entity(touched);

log_to_file("fgo_halloween_add.log"}, "#%d -> Pumpkin Case!"}, bbc_get_user_id(toucher));

return FMRES_IGNORED;
	}
	
#endif

public sql_add_row_to_frags(const iFUID, const iSUID, const iTUID, FUName[], SUName[], TUName[], const iFUFrags, const iSUFrags, const iTUFrags)
{
	new Query[1024], Len;
	
	replace_all(FUName, 127, "\"}, "\\")
	replace_all(FUName, 127, "'"}, "\'")
	
	replace_all(SUName, 127, "\"}, "\\")
	replace_all(SUName, 127, "'"}, "\'")
	
	replace_all(TUName, 127, "\"}, "\\")
	replace_all(TUName, 127, "'"}, "\'")
	
	Len += formatex(Query[Len], charsmax(Query), "INSERT INTO `final_go_frags` ");
	Len += formatex(Query[Len], charsmax(Query) - Len, "(`FirstUserID`, `SecondUserID`, `ThirdUserID`, `FirstUserName`, `SecondUserName`, `ThirdUserName`, `FirstUserFrags`, `SecondUserFrags`, `ThirdUserFrags`)");
	Len += formatex(Query[Len], charsmax(Query) - Len, " VALUES ");
	Len += formatex(Query[Len], charsmax(Query) - Len, "('%i', '%i', '%i', '%s', '%s', '%s', '%i', '%i', '%i');"}, iFUID, iSUID, iTUID, FUName, SUName, TUName, iFUFrags, iSUFrags, iTUFrags);
	
	SQL_ThreadQuery(g_SqlTuple, "sql_add_row_to_frags_thr"}, Query);
}

public sql_add_row_to_frags_thr(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime)
{
	if ( Errcode )
log_to_file("sql_error_found.log"}, Error);
	
	if ( FailState == TQUERY_CONNECT_FAILED )
set_fail_state("SQL: Hiba a Csatlakozaskor!");
	else if ( FailState == TQUERY_QUERY_FAILED )
set_fail_state("SQL: Hiba a Szerkezetben!");
}

public showMenu_ShopList(id) {	
	
	new Text[128];
	formatex(Text, charsmax(Text), "\r%L\w |\y %L\r *"}, id, "M_OUR_TEAM"}, id, "M_SHOP");
	
	new Menu = menu_create(Text, "createMenu_ShopList");
	
	formatex(Text, charsmax(Text), "%L\r |\y 19.99 Dollár\d (1%L)"}, id, "M_KEY"}, id, "M_PCS");
	menu_additem(Menu, Text, "1");
	
	formatex(Text, charsmax(Text), "%L\r |\y 599.99 Dollár\d (1%L)"}, id, "M_NAMETAG"}, id, "M_PCS");
	menu_additem(Menu, Text, "2");
	
	formatex(Text, charsmax(Text), "%L\d (StatTrak*)\r |\y 910 COIN\d (1%L)"}, id, "M_MUSIC_KIT_BOX"}, id, "M_PCS");
	menu_additem(Menu, Text, "3");
	
	formatex(Text, charsmax(Text), "%L\r |\y 510 COIN\d (1%L)"}, id, "M_MUSIC_KIT_BOX"}, id, "M_PCS");
	menu_additem(Menu, Text, "4");
	
	formatex(Text, charsmax(Text), "%s\r |\y 120 COIN\d (1%L)"}, Cases[14][0], id, "M_PCS");
	menu_additem(Menu, Text, "5");
	
	#if defined IS_HALLOWEEN_ENABLED
	
formatex(Text, charsmax(Text), "%s\r |\y 150 COIN\d (1%L)"}, Cases[15][0], id, "M_PCS");
menu_additem(Menu, Text, "6");

	#endif
	
	formatex(Text, charsmax(Text), "%L"}, id, "M_BACK");
	menu_setprop(Menu, MPROP_BACKNAME, Text);
	
	formatex(Text, charsmax(Text), "%L"}, id, "M_NEXT");
	menu_setprop(Menu, MPROP_NEXTNAME, Text);
	
	formatex(Text, charsmax(Text), "%L"}, id, "M_EXIT");
	menu_setprop(Menu, MPROP_EXITNAME, Text);
	
	menu_display(id, Menu, 0);
	
	return PLUGIN_HANDLED;
}

public createMenu_ShopList(id, Menu, Item) {	
	
	if ( Item == MENU_EXIT ) {

showMenu_Main(id);

return PLUGIN_HANDLED;
	}
	
	new Data[32], Name[64], iAccess, iCallback;
	menu_item_getinfo(Menu, Item, iAccess, Data, charsmax(Data), Name, charsmax(Name), iCallback);
	
	g_Item[id] = str_to_num(Data);
	showMenu_Shop(id);
	
	return PLUGIN_HANDLED;
}
 final_go_achvs
public showMenu_Shop(id) {

	new Menu[512], iLen, ItemName[64];

	iLen += formatex(Menu[iLen], charsmax(Menu), "\r%L\w |\y %L\r *^n"}, id, "M_OUR_TEAM"}, id, "M_SHOP");
	iLen += formatex(Menu[iLen], charsmax(Menu) - iLen, "^n");
	
	if ( g_Item[id] == 1 )
formatex(ItemName, charsmax(ItemName), "%L"}, id, "M_KEY");
	else if ( g_Item[id] == 2 )
formatex(ItemName, charsmax(ItemName), "%L"}, id, "M_NAMETAG");
	else if ( g_Item[id] == 3 )
formatex(ItemName, charsmax(ItemName), "%L (StatTrak*)"}, id, "M_MUSIC_KIT_BOX");
	else if ( g_Item[id] == 4 )
formatex(ItemName, charsmax(ItemName), "%L"}, id, "M_MUSIC_KIT_BOX");
	else if ( g_Item[id] == 5 )
formatex(ItemName, charsmax(ItemName), "%s"}, Cases[14][0]);
	else if ( g_Item[id] == 6 )
formatex(ItemName, charsmax(ItemName), "%s"}, Cases[15][0]);
	
	iLen += formatex(Menu[iLen], charsmax(Menu) - iLen, "\w%L^n"}, id, "ASK_FOR_BUY"}, ItemName);
	iLen += formatex(Menu[iLen], charsmax(Menu) - iLen, "^n");
	
	if ( g_Item[id] == 1 ) {

iLen += formatex(Menu[iLen], charsmax(Menu) - iLen, "\r1.\w %L\r |\y 19.99 Dollár\d (1%L)^n"}, id, "M_YES"}, id, "M_PCS");
iLen += formatex(Menu[iLen], charsmax(Menu) - iLen, "\r2.\w %L\r |\y 120 COIN\d (10%L)^n"}, id, "M_YES"}, id, "M_PCS");
	}
	else if ( g_Item[id] == 2 ) {

iLen += formatex(Menu[iLen], charsmax(Menu) - iLen, "\r1.\w %L\r |\y 599.99 Dollár\d (1%L)^n"}, id, "M_YES"}, id, "M_PCS");
iLen += formatex(Menu[iLen], charsmax(Menu) - iLen, "\r2.\w %L\r |\y 60 COIN\d (1%L)^n"}, id, "M_YES"}, id, "M_PCS");
	}
	else if ( g_Item[id] == 3 ) {

iLen += formatex(Menu[iLen], charsmax(Menu) - iLen, "\r1.\w %L\r |\y 910 COIN\d (1%L)^n"}, id, "M_YES"}, id, "M_PCS");
iLen += formatex(Menu[iLen], charsmax(Menu) - iLen, "\r2.\w %L\r |\y 8.190 COIN\d (10%L)\w [-10%%]^n"}, id, "M_YES"}, id, "M_PCS");
	}
	else if ( g_Item[id] == 4 ) {

iLen += formatex(Menu[iLen], charsmax(Menu) - iLen, "\r1.\w %L\r |\y 510 COIN\d (1%L)^n"}, id, "M_YES"}, id, "M_PCS");
iLen += formatex(Menu[iLen], charsmax(Menu) - iLen, "\r2.\w %L\r |\y 4.590 COIN\d (10%L)\w [-10%%]^n"}, id, "M_YES"}, id, "M_PCS");
	}
	else if ( g_Item[id] == 5 ) {

iLen += formatex(Menu[iLen], charsmax(Menu) - iLen, "\r1.\w %L\r |\y 120 COIN\d (1%L)^n"}, id, "M_YES"}, id, "M_PCS");
iLen += formatex(Menu[iLen], charsmax(Menu) - iLen, "\r2.\w %L\r |\y 1.020 COIN\d (10%L)\w [-15%%]^n"}, id, "M_YES"}, id, "M_PCS");
	}
	else if ( g_Item[id] == 6 ) {

iLen += formatex(Menu[iLen], charsmax(Menu) - iLen, "\r1.\w %L\r |\y 150 COIN\d (1%L)^n"}, id, "M_YES"}, id, "M_PCS");
iLen += formatex(Menu[iLen], charsmax(Menu) - iLen, "\r2.\w %L\r |\y 1.275 COIN\d (10%L)\w [-15%%]^n"}, id, "M_YES"}, id, "M_PCS");
	}
	
	iLen += formatex(Menu[iLen], charsmax(Menu) - iLen, "^n");
	iLen += formatex(Menu[iLen], charsmax(Menu) - iLen, "\r0.\w %L"}, id, "M_EXIT");
	
	set_pdata_int(id, 205, 0);
	show_menu(id, MENU_KEY_1|MENU_KEY_2|MENU_KEY_0, Menu, -1, "Shop Menu");
	
	return PLUGIN_HANDLED;
}

public menu_shop(id, key) {

	if ( !is_user_connected(id) )
return PLUGIN_HANDLED;

	if ( g_Item[id] == 1 ) {

if ( !key ) {
	
	if ( g_Money[id] >= 19.99 ) {

client_printcolor(id, "%L:$3! %L$1! (%i%L)"}, id, "T_BUYI"}, id, "M_KEY"}, 1, id, "M_PCS");
createItem(3, 0, bbc_get_user_id(id), 0);

g_Money[id] -= 19.99;
client_cmd(id, "spk %s/%s"}, MainFolder, CashTune);

log_to_file("fgo_shop_purchase.log"}, "#%d | %i | %i | %L"}, bbc_get_user_id(id), 3, 1,  id, "M_KEY");
	}
	else {

client_printcolor(id, "%L:$3! %L$1! (%i%L)"}, id, "T_NOGP"}, id, "M_KEY"}, 1, id, "M_PCS");
showMenu_Shop(id);
	}
}
else if ( key == 1 ) {
	
	if ( g_rwTCash[id] >= 120 ) {

client_printcolor(id, "%L:$3! %L$1! (%i%L)"}, id, "T_BUYI"}, id, "M_KEY"}, 10, id, "M_PCS");

for ( new i; i < 10; i++ )
createItem(3, 0, bbc_get_user_id(id), 0);

g_rwTCash[id] -= 120;
client_cmd(id, "spk %s/%s"}, MainFolder, CashTune);

log_to_file("fgo_shop_purchase.log"}, "#%d | %i | %i | %L"}, bbc_get_user_id(id), 3, 10, id, "M_KEY");
	}
	else {

client_printcolor(id, "%L:$3! %L$1! (%i%L)"}, id, "T_NOCASH"}, id, "M_KEY"}, 10, id, "M_PCS");
showMenu_Shop(id);
	}
}
	}
	else if ( g_Item[id] == 2 ) {

if ( !key ) {
	
	if ( g_Money[id] >= 599.99 ) {

client_printcolor(id, "%L:$3! %L$1! (%i%L)"}, id, "T_BUYI"}, id, "M_NAMETAG"}, 1, id, "M_PCS");
createItem(5, 0, bbc_get_user_id(id), 0);

g_Money[id] -= 599.99;
client_cmd(id, "spk %s/%s"}, MainFolder, CashTune);

log_to_file("fgo_shop_purchase.log"}, "#%d | %i | %i | %L"}, bbc_get_user_id(id), 5, 1,  id, "M_NAMETAG");
	}
	else {

client_printcolor(id, "%L:$3! %L$1! (%i%L)"}, id, "T_NOGP"}, id, "M_NAMETAG"}, 1, id, "M_PCS");
showMenu_Shop(id);
	}
}
else if ( key == 1 ) {
	
	if ( g_rwTCash[id] >= 90 ) {

client_printcolor(id, "%L:$3! %L$1! (%i%L)"}, id, "T_BUYI"}, id, "M_NAMETAG"}, 1, id, "M_PCS");
createItem(5, 0, bbc_get_user_id(id), 0);

g_rwTCash[id] -= 90;
client_cmd(id, "spk %s/%s"}, MainFolder, CashTune);

log_to_file("fgo_shop_purchase.log"}, "#%d | %i | %i | %L"}, bbc_get_user_id(id), 5, 1, id, "M_NAMETAG");
	}
	else {

client_printcolor(id, "%L:$3! %L$1! (%i%L)"}, id, "T_NOCASH"}, id, "M_NAMETAG"}, 10, id, "M_PCS");
showMenu_Shop(id);
	}
}
	}
	else if ( g_Item[id] == 3 ) {

if ( !key ) {
	
	if ( g_rwTCash[id] >= 910 ) {

client_printcolor(id, "%L:$3! %L$1! (StatTrak*) (%i%L)"}, id, "T_BUYI"}, id, "M_MUSIC_KIT_BOX"}, 1, id, "M_PCS");

createItem(7, 0, bbc_get_user_id(id), 1);

g_rwTCash[id] -= 910;
client_cmd(id, "spk %s/%s"}, MainFolder, CashTune);

log_to_file("fgo_shop_purchase.log"}, "#%d | %i | %i | %L (StatTrak*)"}, bbc_get_user_id(id), 7, 1, id, "M_MUSIC_KIT_BOX");
	}
	else {

client_printcolor(id, "%L:$3! %L$1! (StatTrak*) (%i%L)"}, id, "T_NOCASH"}, id, "M_MUSIC_KIT_BOX"}, 1, id, "M_PCS");
showMenu_Shop(id);
	}
}
else if ( key == 1 ) {
	
	if ( g_rwTCash[id] >= 8190 ) {

client_printcolor(id, "%L:$3! %L$1! (StatTrak*) (%i%L)"}, id, "T_BUYI"}, id, "M_MUSIC_KIT_BOX"}, 10, id, "M_PCS");

for ( new i; i < 10; i++ )
createItem(7, 0, bbc_get_user_id(id), 1);

g_rwTCash[id] -= 8190;
client_cmd(id, "spk %s/%s"}, MainFolder, CashTune);

log_to_file("fgo_shop_purchase.log"}, "#%d | %i | %i | %L (StatTrak*)"}, bbc_get_user_id(id), 7, 10, id, "M_MUSIC_KIT_BOX");
	}
	else {

client_printcolor(id, "%L:$3! %L$1! (StatTrak*) (%i%L)"}, id, "T_NOCASH"}, id, "M_MUSIC_KIT_BOX"}, 10, id, "M_PCS");
showMenu_Shop(id);
	}
}
	}
	else if ( g_Item[id] == 4 ) {

if ( !key ) {
	
	if ( g_rwTCash[id] >= 510 ) {

client_printcolor(id, "%L:$3! %L$1! (%i%L)"}, id, "T_BUYI"}, id, "M_MUSIC_KIT_BOX"}, 1, id, "M_PCS");

createItem(7, 0, bbc_get_user_id(id), 0);

g_rwTCash[id] -= 510;
client_cmd(id, "spk %s/%s"}, MainFolder, CashTune);

log_to_file("fgo_shop_purchase.log"}, "#%d | %i | %i | %L"}, bbc_get_user_id(id), 7, 1, id, "M_MUSIC_KIT_BOX");
	}
	else {

client_printcolor(id, "%L:$3! %L$1! (%i%L)"}, id, "T_NOCASH"}, id, "M_MUSIC_KIT_BOX"}, 1, id, "M_PCS");
showMenu_Shop(id);
	}
}
else if ( key == 1 ) {
	
	if ( g_rwTCash[id] >= 4590 ) {

client_printcolor(id, "%L:$3! %L$1! (%i%L)"}, id, "T_BUYI"}, id, "M_MUSIC_KIT_BOX"}, 10, id, "M_PCS");

for ( new i; i < 10; i++ )
createItem(7, 0, bbc_get_user_id(id), 0);

g_rwTCash[id] -= 4590;
client_cmd(id, "spk %s/%s"}, MainFolder, CashTune);

log_to_file("fgo_shop_purchase.log"}, "#%d | %i | %i | %L"}, bbc_get_user_id(id), 7, 10, id, "M_MUSIC_KIT_BOX");
	}
	else {

client_printcolor(id, "%L:$3! %L$1! (%i%L)"}, id, "T_NOCASH"}, id, "M_MUSIC_KIT_BOX"}, 10, id, "M_PCS");
showMenu_Shop(id);
	}
}
	}
	else if ( g_Item[id] == 5 ) {

if ( !key ) {
	
	if ( g_rwTCash[id] >= 120 ) {

client_printcolor(id, "%L:$3! %s$1! (%i%L)"}, id, "T_BUYI"}, Cases[14][0], 1, id, "M_PCS");

createItem(2, 14, bbc_get_user_id(id), 0);

g_rwTCash[id] -= 120;
client_cmd(id, "spk %s/%s"}, MainFolder, CashTune);

log_to_file("fgo_shop_purchase.log"}, "#%d | %i | %i | %i | %s"}, bbc_get_user_id(id), 2, 14, 1, Cases[14][0]);
	}
	else {

client_printcolor(id, "%L:$3! %s$1! (%i%L)"}, id, "T_NOCASH"}, Cases[14][0], 1, id, "M_PCS");
showMenu_Shop(id);
	}
}
else if ( key == 1 ) {
	
	if ( g_rwTCash[id] >= 1020 ) {

client_printcolor(id, "%L:$3! %s$1! (%i%L)"}, id, "T_BUYI"}, Cases[14][0], 10, id, "M_PCS");

for ( new i; i < 10; i++ )
createItem(2, 14, bbc_get_user_id(id), 0);

g_rwTCash[id] -= 1020;
client_cmd(id, "spk %s/%s"}, MainFolder, CashTune);

log_to_file("fgo_shop_purchase.log"}, "#%d | %i | %i | %i | %s"}, bbc_get_user_id(id), 2, 14, 10, Cases[14][0]);
	}
	else {

client_printcolor(id, "%L:$3! %s$1! (%i%L)"}, id, "T_NOCASH"}, Cases[14][0], 10, id, "M_PCS");
showMenu_Shop(id);
	}
}
	}
	else if ( g_Item[id] == 6 ) {

if ( !key ) { HU_Name
	
	if ( g_rwTCash[id] >= 150 ) {

client_printcolor(id, "%L:$3! %s$1! (%i%L)"}, id, "T_BUYI"}, Cases[15][0], 1, id, "M_PCS");

createItem(2, 15, bbc_get_user_id(id), 0);

g_rwTCash[id] -= 150;
client_cmd(id, "spk %s/%s"}, MainFolder, CashTune);

log_to_file("fgo_shop_purchase.log"}, "#%d | %i | %i | %i | %s"}, bbc_get_user_id(id), 2, 15, 1, Cases[15][0]);
	}
	else {

client_printcolor(id, "%L:$3! %s$1! (%i%L)"}, id, "T_NOCASH"}, Cases[15][0], 1, id, "M_PCS");
showMenu_Shop(id);
	}
}
else if ( key == 1 ) {
	
	if ( g_rwTCash[id] >= 1275 ) {

client_printcolor(id, "%L:$3! %s$1! (%i%L)"}, id, "T_BUYI"}, Cases[15][0], 10, id, "M_PCS");

for ( new i; i < 10; i++ )
createItem(2, 15, bbc_get_user_id(id), 0);

g_rwTCash[id] -= 1275;
client_cmd(id, "spk %s/%s"}, MainFolder, CashTune);

log_to_file("fgo_shop_purchase.log"}, "#%d | %i | %i | %i | %s"}, bbc_get_user_id(id), 2, 15, 10, Cases[15][0]);
	}
	else {

client_printcolor(id, "%L:$3! %s$1! (%i%L)"}, id, "T_NOCASH"}, Cases[15][0], 10, id, "M_PCS");
showMenu_Shop(id);
	}
}
	}
	
	return PLUGIN_HANDLED;
}
