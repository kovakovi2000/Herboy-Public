#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <engine>
#include <fun>
#include <hamsandwich>
#include <fakemeta>
#include <xs>
#include <fakemeta_util>
#include <sqlx>
#include <sk_utils>
#include <regsystem>
#include <easytime>
#include <bansys>

#define Is_Beta_Test = 1
#define NoUpdate = 1


new /* Fragverseny = 0, Fragkorok, Frags, */ TopMvp, fwd_logined, fegyvermenus = 0, g_Admin_Level[33];
new porgettime[33], FegyoMapName[33];
new BerakeTER[33];
new BerakeCT[33], vastype[33] = 0;
new betett[33];
new g_Mute[33][33]
new global_maprestart = 0;
enum _:gune {
	AK47,
	M4A1,
	AWP,
	DEAGLE,
	KNIFE
}
new const ET_model[] = "models/PT_Shediboii/caseasd.mdl";
#define FEGYO 115
#define Music 16
#define FEGYOSQL 200
#define LADASZAM 8
#define COST_KEYDROPUPGRADE 10
#define COST_CASEDROPUPGRADE 16
// RANGSYSTEM
// new g_CTWins, g_TEWins;
new Rang[33]/*,  ProfileRank[33], lvlblocked[33] */;
new eloELO[33], Float:eloXP[33];
new rELO[33], Float:rXP[33], Wins[33];
//
new Handle:g_SqlSMSTuple
// new sqltupleid = 0;

enum _:PremiumVIP
{
	isPremium,
	PremiumTime
}
new Vip[33][PremiumVIP]
new Options[33][2]
// new AllRegistedRank;
new p_playernum;
//CVARS
//MENTÉS
new g_Id[33];
//MENTÉS
new gWPCT;
new gWPTE;
new maxkor, aSync
new String[512], Float:EXPT[33], erdem[33];

new Elhasznal[5][33];
new g_korkezdes, g_VipTime[33], g_Vip[33], nyolesNev[33][32], nyid[33], nyolesl[33], bSync;
new g_ASD[33], szinesmenu[33], Buy[33];
new g_Kicucc[33], Float:g_Erteke[33], bool:g_StatTrakBeKi[33], OsszesKirakott[4], SelectedStatTrak[5][33], g_ChooseThings[3][33], skinkuldes[33], targykuldes[33]
new Float:g_dollar[33], /* name[33][32], */ hs[33], hl[33], oles[33], premiumpont[33], g_Maxplayers, g_SkinBeKi[33], g_tester[33];
new g_Tools[2][33], g_NameTagKey, bool:g_NameTagBeKi[33], g_Kirakva[33], HudOff[33], Send[33], TempID
const KEYSMENU = MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6|MENU_KEY_7|MENU_KEY_8|MENU_KEY_9|MENU_KEY_0;
new bool:g_NameTagBeKiSend[33], bool:g_StatTrakBeKiSend[33], g_kUserID[33], targyakfogadasa[33], dSync, /* bSync,  cSync,*/ HBPont[33], NyeremenyOles[33];
new g_Chat_Prefix[33][32], VanPrefix[33], g_MVPoints[33], oldhud[33], bool:Korvegi[33];
new Selectedgun[gune][33];
new Array:g_Admins;
enum _:TEAMS {TE, CT};
new g_Awps[TEAMS];
new Ajandekcsomag[33], gmsg_SetFOV, Vane[33]

enum _:LoadDatass {
	weapid,
	PiacraHelyezheto,
	GunName[64],
	ModelName[64],
	EntName[8]
} 
enum _:LoadEntities {
	ModelName[64],
	EntName[8]
} 

enum _:AdminData{
	Id,
	Name[32],
	Permission
}
enum _:playersys
{
	Id,
	Float:EXP,
	SSzint,
	steamid[32],
	f_PlayerNames[64],
	CaseSelectedSlot,
	SkinDisplay,
	InHandWepInvSlot,
	ToolsStattrak,
	ToolsNametag,
	ScreenEffect,
	AdminIll,
	WeaponHud,
	SelectedMusicBox,
}
new Player[33][playersys];
enum _:vip_Properties
{
	v_id,
	v_isVip,
	v_time,
	v_moneydrop,
	v_casedrop,
	v_keydrop
}
new Player_Vip[33][vip_Properties];
enum _:QuestProp
{
	is_Questing,
	QuestKill,
	QuestKillCount,
	is_head,
	QuestWeapon,
	Float:QuestDollarReward,
	QuestCaseReward,
	QuestKeyReward,
	QuestCase,
	QuestKey,
	QuestStatTrakReward,
	QuestNametagReward,
	Float:QuestSkipDollar,
	QuestRare,
}
new Questing[33][QuestProp];
enum _:RouletProps
{
	Piros,
	Fekete,
	Szurke,
	Zold,
	Float:Placed,
	MiPorog
}
new Roulette[33][RouletProps]
new const FegyverInfo[][LoadDatass] = {
{0, 0, "AK47 | Default", "models/v_ak47.mdl", CSW_AK47}, 
{1, 0, "M4A1 | Default", "models/v_m4a1.mdl", CSW_M4A1}, //13
{2, 0, "AWP | Default", "models/v_awp.mdl", CSW_AWP}, //26
{3, 0, "DEAGLE | Default", "models/v_deagle.mdl", CSW_DEAGLE}, //39
{4, 0, "Kés", "models/v_knife.mdl", CSW_KNIFE}, //50
{5, 1, "AK47 | Block Cartel", "models/avatarnew/blackcartel.mdl", CSW_AK47}, 
{6, -2, "AK47 | Blue Bones", "models/avatarnew/bluebones.mdl", CSW_AK47}, 
{7, 1, "AK47 | Blue Flame", "models/avatarnew/blueflame.mdl", CSW_AK47}, 
{8,-2, "AK47 | Desert Camo", "models/avatarnew/desertcamo.mdl", CSW_AK47}, 
{9, -2, "AK47 | Forest Camo", "models/avatarnew/forestcamo.mdl", CSW_AK47}, 
{10, -2, "AK47 | Blue Tron", "models/avatarnew/bluetron.mdl", CSW_AK47}, 
{11, 1, "AK47 | Akihabara Accept", "models/avatarnew/akihabara.mdl", CSW_AK47}, 
{12, -2, "Unknown", "", CSW_M4A1}, 
{13, 1, "AK47 | Aquamarine Revenge", "models/avatarnew/aqua_ak47.mdl", CSW_AK47}, 
{14, -2, "AK47 | Astronaut", "models/avatarnew/astronaut.mdl", CSW_AK47}, 
{15, -2, "AK47 | Bloodsport", "models/avatarnew/bloodsport.mdl", CSW_AK47}, 
{16, -2, "AK47 | Blue Lines", "models/avatarnew/bluelines.mdl", CSW_AK47}, 
{17, 1, "AK47 | Carbon Lines", "models/avatarnew/carbonlines.mdl", CSW_AK47}, 
{18, 1, "AK47 | Case Hardened", "models/avatarnew/casehardened.mdl", CSW_AK47}, 
{19, 1, "AK47 | Demolition Derby", "models/avatarnew/demolitionderby.mdl", CSW_AK47}, 
{20, -2, "Unknown", "", CSW_M4A1}, 
{21, -2, "AK47 | Elite Build", "models/avatarnew/elitebuild.mdl", CSW_AK47}, 
{22, 1, "AK47 | Fire", "models/avatarnew/fire_ak47.mdl", CSW_AK47}, 
{23, 1, "AK47 | Fire Serpent", "models/avatarnew/fireserpent.mdl", CSW_AK47}, 
{24, 1, "AK47 | Frontside Misty", "models/avatarnew/frontsidemisty.mdl", CSW_AK47}, 
{25, 1, "AK47 | Fuel Injector", "models/avatarnew/fuelinjector_ak47.mdl", CSW_AK47}, 
{26, 1, "AK47 | Grimmjow", "models/avatarnew/grimmjow.mdl", CSW_AK47}, 
{27, 1, "AK47 | Hydroponic", "models/avatarnew/hydroponic.mdl", CSW_AK47}, 
{28, 1, "AK47 | It", "models/avatarnew/it.mdl", CSW_AK47}, 
{29, 1, "AK47 | Jaguar", "models/avatarnew/jaguar.mdl", CSW_AK47}, 
{30, -2, "AK47 | Jet-Set", "models/avatarnew/jetset.mdl", CSW_AK47}, 
{31, 1, "AK47 | Neon Revolution", "models/avatarnew/neonrevolution.mdl", CSW_AK47}, 
{32, 1, "AK47 | Next Technology", "models/avatarnew/nexttechnolgy.mdl", CSW_AK47}, 
{33, 1, "AK47 | Point Dissaray", "models/avatarnew/pointdissaray.mdl", CSW_AK47}, 
{34, -2, "Unknown", "", CSW_M4A1}, 
{35, -2, "Unknown", "", CSW_M4A1}, 
{36, 1, "AK47 | Propaganda", "models/avatarnew/propaganda.mdl", CSW_AK47}, 
{37, 1, "AK47 | Purple-94", "models/avatarnew/purple94.mdl", CSW_AK47}, 
{38, 1, "AK47 | Red Force", "models/avatarnew/redforce.mdl", CSW_AK47}, 
{39, -2, "AK47 | Redline", "models/avatarnew/redline.mdl", CSW_AK47}, 
{40, 1, "AK47 | Rise", "models/avatarnew/rise.mdl", CSW_AK47}, 
{41, 1, "AK47 | Shark Attack", "models/avatarnew/sharkattack.mdl", CSW_AK47}, 
{42, 1, "AK47 | Starladder", "models/avatarnew/starladder_ak47.mdl", CSW_AK47}, 
{43, 1, "AK47 | Sticker", "models/avatarnew/sticker_ak47.mdl", CSW_AK47}, 
{44, 1, "AK47 | The Empress", "models/avatarnew/theempress.mdl", CSW_AK47}, 
{45, 1, "AK47 | UFO", "models/avatarnew/ufo.mdl", CSW_AK47}, 
{46, 1, "AK47 | Ultimate Red", "models/avatarnew/ultimatered.mdl", CSW_AK47}, 
{47, -2, "AK47 | Vanquish", "models/avatarnew/vanquish.mdl", CSW_AK47}, 
{48, 1, "AK47 | Vulcan", "models/avatarnew/vulcan.mdl", CSW_AK47}, 
{49, -2, "AK47 | Wasteland Rebel", "models/avatarnew/wastelandrebel.mdl", CSW_AK47}, 
{50, -2, "AK47 | Whiteout", "models/avatarnew/whiteout.mdl", CSW_AK47}, 
{51, 1, "AK47 | Challenger", "models/avatarnew/challenger.mdl", CSW_AK47}, 
{52, -2, "Unknown", "", CSW_M4A1}, 
{53, -2, "Unknown", "", CSW_M4A1}, 
{54, -2, "Unknown", "", CSW_M4A1}, 
{55, 1, "M4A1 | Poseidon", "models/avatarnew/poseidon.mdl", CSW_M4A1},
{56, -2, "Unknown", "", CSW_M4A1}, 
{57, -2, "M4A1 | Basilisk", "models/avatarnew/basilisk.mdl", CSW_M4A1},
{58, 1, "M4A1 | Bumblebee", "models/avatarnew/bumblebee.mdl", CSW_M4A1},
{59, 1, "M4A1 | Chanticos Fire", "models/avatarnew/chanticosfire.mdl", CSW_M4A1},
{60, 1, "M4A1 | Colored", "models/avatarnew/colored.mdl", CSW_M4A1},
{61, 1, "M4A1 | Desolate Space", "models/avatarnew/desolatespace.mdl", CSW_M4A1},
{62, 1, "M4A1 | Dragon King", "models/avatarnew/dragonking_m4a1.mdl", CSW_M4A1},
{63, -2, "M4A1 | Fallout", "models/avatarnew/fallout.mdl", CSW_M4A1},
{64, 1, "M4A1 | Firestyle", "models/avatarnew/firestyle.mdl", CSW_M4A1},
{65, 1, "M4A1 | Flashback", "models/avatarnew/flashback.mdl", CSW_M4A1},
{66, -2, "Unknown", "", CSW_M4A1}, 
{67, -2, "Unknown", "", CSW_M4A1}, 
{68, -2, "Unknown", "", CSW_M4A1}, 
{69, 1, "M4A1 | Hyper Beast", "models/avatarnew/hyperbeast_m4a1.mdl", CSW_M4A1},
{70, 1, "M4A1 | Icarus Fell", "models/avatarnew/icerusfell.mdl", CSW_M4A1},
{71, 1, "M4A1 | Master Piece", "models/avatarnew/masterpiece.mdl", CSW_M4A1},
{72, 1, "M4A1 | Music Arts", "models/avatarnew/musicarts.mdl", CSW_M4A1},
{73, -2, "M4A1 | MX", "models/avatarnew/mx.mdl", CSW_M4A1},
{74, 1, "M4A1 | Neon Electro", "models/avatarnew/neonelectro.mdl", CSW_M4A1},
{75, 1, "M4A1 | Nuclear Leek", "models/avatarnew/nuclearleek.mdl", CSW_M4A1},
{76, -2, "M4A1 | Optimus", "models/avatarnew/optimus.mdl", CSW_M4A1},
{77, 1, "M4A1 | Starladder", "models/avatarnew/starladder_m4a1.mdl", CSW_M4A1},
{78, 1, "M4A1 | Sticker", "models/avatarnew/sticker_m4a1.mdl", CSW_M4A1},
{79, 1, "M4A1 | Faust", "models/avatarnew/faust.mdl", CSW_M4A1},
{80, 1, "M4A1 | High Voltage God", "models/avatarnew/highvoltagegod.mdl", CSW_M4A1},
{81, -2, "M4A1 | Councilor", "models/avatarnew/councilor.mdl", CSW_M4A1},
{82, 1, "M4A1 | Thundering Red", "models/avatarnew/thunderingred.mdl", CSW_M4A1},
{83, 1, "M4A1 | Decimator", "models/avatarnew/decimator.mdl", CSW_M4A1},
{84, -2, "M4A1 | Neonovy", "models/avatarnew/neonovy.mdl", CSW_M4A1},
{85, 1, "M4A1 | Condor", "models/avatarnew/condor.mdl", CSW_M4A1},
{86, 1, "M4A1 | Grand Supreme", "models/avatarnew/grandsupreme.mdl", CSW_M4A1},
{87, 1, "M4A1 | Great Britain", "models/avatarnew/greatbritain.mdl", CSW_M4A1},
{88, 1, "M4A1 | Hot Lava", "models/avatarnew/hotlava.mdl", CSW_M4A1},
{89, -2, "M4A1 | Nuclear", "models/avatarnew/nuclear.mdl", CSW_M4A1},
{90, -2, "Unknown", "", CSW_M4A1}, 
{91, -2, "M4A1 | Galaxy", "models/avatarnew/galaxy.mdl", CSW_M4A1},
{92, -2, "Unknown", "", CSW_AWP}, 
{93, 1, "AWP | Lines", "models/avatarnew/lines.mdl", CSW_AWP},
{94, -2, "AWP | Malaysia", "models/avatarnew/malaysia.mdl", CSW_AWP},
{95, 1, "AWP | Red Puzzle", "models/avatarnew/redpuzzle.mdl", CSW_AWP},
{96, 1, "AWP | Snow Camo", "models/avatarnew/snowcamo.mdl", CSW_AWP},
{97, 1, "AWP | Tiger Tooth", "models/avatarnew/tigertooth.mdl", CSW_AWP},
{98, -2, "AWP | Turtle Style", "models/avatarnew/turtlestyle.mdl", CSW_AWP},
{99, 1, "AWP | Crosshair", "models/avatarnew/crosshair.mdl", CSW_AWP},
{100, 1, "AWP | Artistic", "models/avatarnew/artistic.mdl", CSW_AWP},
{101, 1, "AWP | Asiimov", "models/avatarnew/asiimov_awp.mdl", CSW_AWP},
{102, -2, "AWP | Banshee", "models/avatarnew/banshee.mdl", CSW_AWP},
{103, 1, "AWP | Bloody Camo", "models/avatarnew/bloodycamo.mdl", CSW_AWP},
{104, 1, "AWP | Bluvy", "models/avatarnew/bluvy.mdl", CSW_AWP},
{105, -2, "AWP | Boom", "models/avatarnew/boom.mdl", CSW_AWP},
{106, -2, "AWP | Colorway", "models/avatarnew/colorway.mdl", CSW_AWP},
{107, 1, "AWP | Cyrex", "models/avatarnew/cyrex_awp.mdl", CSW_AWP},
{108, 1, "AWP | Dragon Lore", "models/avatarnew/dragonlore_awp.mdl", CSW_AWP},
{109, -2, "AWP | Elite Build", "models/avatarnew/elitebuild_awp.mdl", CSW_AWP},
{110, -2, "Unknown", "", CSW_AWP}, 
{111, 1, "AWP | Fire", "models/avatarnew/fire_awp.mdl", CSW_AWP},
{112, 1, "AWP | Frontside Misty", "models/avatarnew/frontsidemisty_awp.mdl", CSW_AWP},
{113, 1, "AWP | Black", "models/avatarnew/black.mdl", CSW_AWP},
{114, 1, "AWP | Graphite", "models/avatarnew/graphite.mdl", CSW_AWP},
{115, 1, "AWP | Hyper Beast", "models/avatarnew/hyperbeast_awp.mdl", CSW_AWP},
{116, 1, "AWP | Jacket", "models/avatarnew/jacket.mdl", CSW_AWP},
{117, 1, "AWP | Lightning Strike", "models/avatarnew/lightningstrike.mdl", CSW_AWP},
{118, -2, "Unknown", "", CSW_AWP}, 
{119, 1, "AWP | Ohka", "models/avatarnew/ohka.mdl", CSW_AWP},
{120, 1, "AWP | Oni Taiji", "models/avatarnew/onitaiji.mdl", CSW_AWP},
{121, -2, "Unknown", "", CSW_AWP}, 
{122, 1, "AWP | Rave", "models/avatarnew/rave.mdl", CSW_AWP},
{123, -2, "AWP | Red", "models/avatarnew/red.mdl", CSW_AWP},
{124, 1, "AWP | Red Dragon", "models/avatarnew/reddragon.mdl", CSW_AWP},
{125, 1, "AWP | Red 2.0", "models/avatarnew/red2.mdl", CSW_AWP},
{126, -2, "AWP | Silver Red Camo", "models/avatarnew/silverredcamo.mdl", CSW_AWP},
{127, -2, "AWP | Sticker", "models/avatarnew/sticker_awp.mdl", CSW_AWP},
{128, -2, "AWP | Golden", "models/avatarnew/golden.mdl", CSW_AWP},
{129, 1, "DEAGLE | Forest Camo", "models/avatarnew/forestcamo_deagle.mdl", CSW_DEAGLE},
{130, 1, "DEAGLE | Neon Electro", "models/avatarnew/neonelectro_deagle.mdl", CSW_DEAGLE},
{131, -2, "DEAGLE | Russia", "models/avatarnew/russia.mdl", CSW_DEAGLE},
{132, 1, "DEAGLE | Wildfire", "models/avatarnew/wildfire.mdl", CSW_DEAGLE},
{133, 1, "DEAGLE | Black And Red", "models/avatarnew/blackandred.mdl", CSW_DEAGLE},
{134, -2, "DEAGLE | Blaze", "models/avatarnew/blaze.mdl", CSW_DEAGLE},
{135, 1, "DEAGLE | Circuit Board", "models/avatarnew/circuitboard.mdl", CSW_DEAGLE},
{136, 1, "DEAGLE | Crimson Web", "models/avatarnew/crimsonweb.mdl", CSW_DEAGLE},
{137, -2, "DEAGLE | Debra", "models/avatarnew/debra.mdl", CSW_DEAGLE},
{138, 1, "DEAGLE | Fade", "models/avatarnew/fade.mdl", CSW_DEAGLE},
{139, 1, "DEAGLE | Fire", "models/avatarnew/fire_deagle.mdl", CSW_DEAGLE},
{140, -2, "DEAGLE | Geometry", "models/avatarnew/geometry.mdl", CSW_DEAGLE},
{141, 1, "DEAGLE | Gold", "models/avatarnew/gold.mdl", CSW_DEAGLE},
{142, 1, "DEAGLE | Green", "models/avatarnew/green.mdl", CSW_DEAGLE},
{143, 1, "DEAGLE | Hypnotic", "models/avatarnew/hypnotic.mdl", CSW_DEAGLE},
{144, 1, "DEAGLE | Iron Man", "models/avatarnew/ironman.mdl", CSW_DEAGLE},
{145, -2, "DEAGLE | Modernia", "models/avatarnew/modernia.mdl", CSW_DEAGLE},
{146, -2, "DEAGLE | Oxide Blaze", "models/avatarnew/oxideblaze.mdl", CSW_DEAGLE},
{147, -2, "DEAGLE | Red Camo", "models/avatarnew/redcamo.mdl", CSW_DEAGLE},
{148, 1, "DEAGLE | Redline", "models/avatarnew/redline_deagle.mdl", CSW_DEAGLE},
{149, -2, "Kard | Arabian", "models/avatarnew/arabian.mdl", CSW_KNIFE},
{150, -2, "Bowie | Blaze", "models/avatarnew/blaze_knife.mdl", CSW_KNIFE},
{151, -2, "Bowie | Crimson Web", "models/avatarnew/b_crimson.mdl", CSW_KNIFE},
{152, -2, "Bowie | Fade", "models/avatarnew/b_fade.mdl", CSW_KNIFE},
{153, -2, "Butterfly Kés | Boreal Forest", "models/avatarnew/butterflyboreal.mdl", CSW_KNIFE},
{154, 1, "Kacsacomb", "models/avatarnew/kacsacomb.mdl", CSW_KNIFE},
{155, 1, "Classic | Cold", "models/avatarnew/cold.mdl", CSW_KNIFE},
{156, 1, "Classic | Fade", "models/avatarnew/fade_knife.mdl", CSW_KNIFE},
{157, 1, "Classic | Fire", "models/avatarnew/fire_knife.mdl", CSW_KNIFE},
{158, 1, "Classic | Frozen", "models/avatarnew/frozen.mdl", CSW_KNIFE},
{159, 1, "Classic | Gamma Doppler", "models/avatarnew/gammadoppler.mdl", CSW_KNIFE},
{160, 1, "Classic | Griff", "models/avatarnew/griff.mdl", CSW_KNIFE},
{161, 1, "Classic | Howl", "models/avatarnew/howl_knife.mdl", CSW_KNIFE},
{162, -2, "Classic | Marble", "models/avatarnew/marble.mdl", CSW_KNIFE},
{163, 1, "Classic | Marble Fade", "models/avatarnew/marblefade.mdl", CSW_KNIFE},
{164, -2, "Falchion | Case Hardened", "models/avatarnew/casehardened_knife.mdl", CSW_KNIFE},
{165, 1, "Falchion | Doppler Blue", "models/avatarnew/dopplerblue.mdl", CSW_KNIFE},
{166, -2, "Flip | Armageddon", "models/avatarnew/armageddon.mdl", CSW_KNIFE},
{167, 1, "Flip | Lore", "models/avatarnew/flip_lore.mdl", CSW_KNIFE,},
{168, 1, "Gut Knife | Autotronic", "models/avatarnew/autotronic.mdl", CSW_KNIFE},
{169, 1, "Huntsman | Crimson Web", "models/avatarnew/h_crimson.mdl", CSW_KNIFE},
{170, 1, "Karambit | Blossoming Rose", "models/avatarnew/blossomingrose.mdl", CSW_KNIFE},
{171, 1, "Karambit | Doppler Sapphire", "models/avatarnew/dopplersapphire.mdl", CSW_KNIFE},
{172, -2, "Karambit | Water Elemental", "models/avatarnew/waterelemental.mdl", CSW_KNIFE},
{173, -2, "Unknown", "", CSW_AWP}, 
{174, 1, "Karambit | Superfurry", "models/avatarnew/superfurry.mdl", CSW_KNIFE},
{175, 1, "Classic | Asiimov", "models/avatarnew/asiimov_knife.mdl", CSW_KNIFE},
{176, -2, "Unknown", "", CSW_AWP}, 
{177, -2, "Unknown", "", CSW_AWP}, 
{178, -2, "Unknown", "", CSW_AWP}, 
{179, -2, "Unknown", "", CSW_AWP}, 
{180, -2, "Unknown", "", CSW_AWP}, 
{181, 1, "Minecraft Balta", "models/avatarnew/balta.mdl", CSW_KNIFE},
{182, -2, "Shadow Daggers | Crimson Web", "models/avatarnew/sd_crimson.mdl", CSW_KNIFE},
{183, 1, "Shadow Daggers | Neon Rider", "models/avatarnew/neonrider_knife.mdl", CSW_KNIFE},
{184, 1, "Skeleton | Crimson Web", "models/avatarnew/sk_crimson.mdl", CSW_KNIFE},
{185, 1, "Skeleton | Fade", "models/avatarnew/sk_fade.mdl", CSW_KNIFE},
{186, 1, "Survival | Case Hardened", "models/avatarnew/s_casehardened.mdl", CSW_KNIFE},
{187, 1, "Talon | Ice", "models/avatarnew/ice.mdl", CSW_KNIFE},
{188, 1, "Ursus | Fade", "models/avatarnew/ur_fade.mdl", CSW_KNIFE},
{189, -2, "Classic | Vaporwave", "models/avatarnew/vaporwave.mdl", CSW_KNIFE},
{190, 0, "AK47 | Black Ice", "models/avatarnew/event/blackiceak.mdl", CSW_AK47},
{191, 0, "M4A1 | Black Ice", "models/avatarnew/event/blackicem4.mdl", CSW_M4A1},
{192, 0, "AWP | Black Ice", "models/avatarnew/event/blackicewp.mdl", CSW_AWP},
{193, 0, "DEAGLE | Black Ice", "models/avatarnew/event/blackicedg.mdl", CSW_DEAGLE},
{194, 0, "KNIFE | Black Ice", "models/avatarnew/event/blackiceks.mdl", CSW_KNIFE},

}
new g_Weapons[sizeof(FegyverInfo)][33]
new g_GunNames[sizeof(FegyverInfo)][33][100]
new g_StatTrak[sizeof(FegyverInfo)][33]
new g_StatTrakKills[sizeof(FegyverInfo)][33]
// new g_msgScreenFade;
enum _:MusicDatas
{
	m_Boxid,
	m_BoxName[128],
	AvailableFrom,
	isLimited, 
	Float:BoxCost,
	Float:SellCost
}
enum _:MusicBoxDatas
{
	MusicID,
	Boxid,
	BoxName[128],
	MusicName[128],
	MusicLocation[128],

}
new const MusicBox[][MusicDatas] = 
{
	{-1, "Nics", 0, 0, 0.00, 0.00},
	{1, "Decemberi", 1669849200, 0, 130.00, 50.00},
	{2, "Karácsonyi", 1703372400, 0, 0.00, 50.00},
	{3, "Januári", 1672527600, 0, 271.00, 50.00},
}
new const MusicBoxMusics[][MusicBoxDatas] = 
{
	{1, 1, "Decemberi", "Baby Eazy E", "av/december/1.mp3"},
	{1, 1, "Decemberi", "Baby Eazy E", "av/december/babyeazyei.mp3"},
	{2, 1, "Decemberi", "Dirtydisco - TV Maci", "av/december/tvmaci.mp3"},
	{3, 1, "Decemberi", "Zámbó Jimmy - Nézz le rám", "av/december/nezzleram.mp3"},
	{4, 1, "Decemberi", "MANUEL - Messziről jöttem", "av/december/manuel.mp3"},
	{5, 1, "Decemberi", "Fehércsokis Shaken Espresso", "av/december/fehercsokis.mp3"},
	{6, 1, "Decemberi", "Korda Gyurka - Reptér", "av/december/repter.mp3"},
	{7, 1, "Decemberi", "Black Eyed Peas - Shut Up", "av/december/blackeyedpeas-shutup.mp3"},
	{8, 1, "Decemberi", "Hupikék Törpikék - Hard Techno", "av/december/torpikek.mp3"},
	{9, 1, "Decemberi", "UHH FUCK ME DADDY!", "av/december/fukmedaddy.mp3"},
	{10, 1, "Decemberi", "Armand Van Helden - You Dont knómí", "av/december/youdontknowme.mp3"},
	{11, 2, "Karácsonyi", "DJ Scamp [TNT] - Fehér Karácsony", "av/karacsony/feherkaracsony.mp3"},
	{12, 2, "Karácsonyi", "Loser", "av/karacsony/loser.mp3"},
	{13, 2, "Karácsonyi", "Wham - Last Christmas", "av/karacsony/lastchristmas.mp3"},
	{14, 3, "Januári", "R3HAB - Karate", "av/januar/karate.mp3"},
	{15, 3, "Januári", "Bakermat - Baianá", "av/januar/bakermatbaiana.mp3"},
	{16, 3, "Januári", "Charmes - Ready", "av/januar/charmes_reade.mp3"},
	{17, 3, "Januári", "Uberjak - Jetfuel", "av/januar/jetfuel.mp3"},
	{18, 3, "Januári", "Let's Go Project - Yeke Yeke", "av/januar/yekeyeke.mp3"},
	{19, 3, "Januári", "The Weeknd - Save Your Tears", "av/januar/saveyourtears.mp3"},
	{20, 3, "Januári", "Tujamo - Riverside", "av/januar/riverside.mp3"},
	{21, 3, "Januári", "Reset - Vukk", "av/januar/vuk.mp3"},
	{22, 3, "Januári", "Usher - Yeah!", "av/januar/yeah.mp3"},
	{232, 3, "Januári", "Usher - Yeah!", "av/januar/yeah.mp3"},
}
new MusicBoxBuyed[sizeof(MusicBox)][33], MusicBoxEquiped[33];
enum _:DropSystem_Prop
{
	d_Name[32],
	Float:d_rarity,
	Float:VipDropchance,
	Float:CaseCost,
	Float:KeyCost
}

new const Cases[][DropSystem_Prop] =
{
	{"Fegyver Láda I", 10.0, 11.0, 15.0, 0.0},
	{"Fegyver Láda II", 7.0, 8.0, 25.0, 0.0},
	{"Láma Láda", 4.0, 5.0, 40.0, 0.0},
	{"Devil Láda", 3.2, 3.4, 55.0, 0.0},
	{"Álom Láda", 1.9, 2.3, 80.0, 0.0},
	{"Dragon Láda", 1.1, 1.25, 100.0, 0.0},
}
new const Keys[][DropSystem_Prop] =
{
	{"Fegyver Ládakulcs I", 11.0, 12.0, 0.0, 15.0},
	{"Fegyver Ládakulcs II", 7.3, 7.8, 0.0, 25.0},
	{"Láma Ládakulcs", 4.2, 4.7, 0.0, 40.0},
	{"Devil Ládakulcs", 3.1, 3.6, 0.0, 55.0},
	{"Álom Ládakulcs", 2.1, 2.2, 0.0, 80.0},
	{"Dragon Ládakulcs", 0.9, 1.1, 0.0, 100.0},
}

new Lada[sizeof(Keys)][33]
new LadaK[sizeof(Keys)][33]
new const Float:FegyverLada1Drops[][] = 
{
	{5.0,	21.11},
	{7.0,	45.4},
	{8.0,	52.6},
	{9.0,	59.1},
	{15.0,21.5},
	{16.0,42.6},
	{17.0,27.5},
	{18.0,28.5},
	{21.0,23.5},
	{23.0,27.5},
	{26.0,23.5},
	{27.0,53.5},
	{31.0,0.5},
	{29.0,27.5},
	{30.0,48.6},
	{32.0,16.6},
	{33.0,44.6},
	{37.0,52.6},
	{38.0,49.6},
	{39.0,50.6},
	{43.0,26.4},
	{46.0,49.1},
	{48.0,19.5},
	{49.0,21.5},
	{50.0,19.5},
	{51.0,18.7},
	{55.0,17.3},
	{57.0,46.2},
	{58.0,20.2},
	{60.0,1.1},
	{63.0,44.21},
	{64.0,17.2},
	{65.0,16.2},
	{71.0,14.2},
	{72.0,19.2},
	{73.0,18.9},
	{74.0,23.1},
	{75.0,16.2},
	{78.0,16.4},
	{79.0,50.4},
	{81.0,48.2},
	{82.0,52.2},
	{85.0,17.2},
	{86.0,56.2},
	{87.0,16.2},
	{88.0,16.2},
	{89.0,48.2},
	{93.0,42.3},
	{94.0,22.4},
	{96.0,22.3},
	{100.0,46.2},
	{101.0,21.3},
	{104.0,23.3},
	{106.0,25.3},
	{107.0,35.6},
	{113.0,48.6},
	{114.0,22.4},
	{116.0,49.6},
	{119.0,42.6},
	{123.0,44.6},
	{124.0,21.6},
	{125.0,42.6},
	{127.0,52.6},
	{128.0,23.4},
	{129.0,54.6},
	{130.0,44.6},
	{131.0,47.6},
	{132.0,23.8},
	{133.0,18.2},
	{135.0,19.3},
	{137.0,42.6},
	{140.0,18.9},
	{141.0,38.6},
	{142.0,48.6},
	{143.0,18.2},
	{145.0,20.5},
	{146.0,18.8},
	{147.0,45.6},
	{148.0,35.6},
};
new const Float:FegyverLada2Drops[][] = 
{
	{5.0, 25.11},
	{7.0,	39.1},
	{8.0,	48.3},
	{9.0,	45.6},
	{15.0,25.1},
	{16.0,48.6},
	{17.0,25.5},
	{18.0,26.1},
	{21.0,25.1},
	{23.0,26.1},
	{24.0,2.6},
	{25.0,2.1},
	{26.0,22.1},
	{27.0,48.3},
	{29.0,23.1},
	{30.0,36.3},
	{32.0,19.1},
	{33.0,36.3},
	{37.0,48.3},
	{31.0,0.8},
	{38.0,45.3},
	{43.0,22.4},
	{48.0,22.5},
	{49.0,22.1},
	{50.0,22.1},
	{51.0,19.1},
	{55.0,22.3},
	{57.0,40.2},
	{62.0,19.1},
	{63.0,42.2},
	{64.0,19.2},
	{65.0,20.1},
	{71.0,21.2},
	{72.0,22.2},
	{73.0,27.0},
	{74.0,20.1},
	{75.0,25.2},
	{78.0,25.1},
	{79.0,47.4},
	{80.0,0.2},
	{81.0,47.2},
	{82.0,47.7},
	{85.0,26.1},
	{86.0,49.7},
	{87.0,25.2},
	{88.0,25.1},
	{89.0,41.2},
	{93.0,38.3},
	{94.0,24.1},
	{95.0,1.5},
	{96.0,24.5},
	{97.0,2.3},
	{98.0,15.4},
	{100.0,35.7},
	{106.0,19.5},
	{107.0,38.9},
	{108.0,2.1},
	{109.0,3.2},
	{111.0,0.5},
	{112.0,3.6},
	{113.0,39.9},
	{115.0,0.4},
	{116.0,36.9},
	{117.0,4.6},
	{125.0,35.9},
	{127.0,44.9},
	{131.0,39.6},
	{133.0,21.7},
	{135.0,25.1},
	{137.0,34.6},
	{138.0,5.1},
	{140.0,24.7},
	{143.0,21.1},
	{144.0,5.7},
	{145.0,23.7},
	{147.0,39.6},
	{148.0,44.6},
};
new const Float:LamaDrops[][] = 
{
	{5.0, 26.2},
	{7.0,	35.6},
	{8.0,	36.2},
	{9.0,	36.2},
	{11.0, 2.1},
	{13.0, 1.9},
	{15.0,26.2},
	{16.0,36.2},
	{17.0,26.5},
	{18.0,26.2},
	{19.0,1.6},
	{23.0,22.2},
	{24.0,2.9},
	{29.0,24.5},
	{30.0,35.2},
	{32.0,24.6},
	{33.0,35.2},
	{37.0,36.2},
	{39.0,38.3},
	{43.0,21.5},
	{45.0,3.0},
	{47.0,33.0},
	{48.0,24.2},
	{51.0,24.5},
	{55.0,23.4},
	{57.0,35.1},
	{58.0,21.2},
	{59.0,23.2},
	{60.0,2.1},
	{61.0,2.0},
	{64.0,18.2},
	{70.0,1.8},
	{31.0,1.0},
	{71.0,16.1},
	{73.0,26.3},
	{74.0,16.1},
	{77.0,0.4},
	{78.0,19.4},
	{79.0,38.1},
	{81.0,38.2},
	{83.0,1.8},
	{84.0,0.2},
	{87.0,19.1},
	{88.0,22.1},
	{89.0,38.2},
	{93.0,37.7},
	{97.0,2.6},
	{98.0,20.7},
	{99.0,0.2},
	{101.0,24.5},
	{102.0,4.2},
	{103.0,4.6},
	{104.0,21.5},
	{105.0,4.1},
	{109.0,4.1},
	{112.0,4.1},
	{114.0,19.7},
	{117.0,4.8},
	{119.0,38.9},
	{122.0,0.8},
	{123.0,35.9},
	{126.0,4.2},
	{133.0,20.4},
	{134.0,4.4},
	{135.0,21.4},
	{140.0,21.4},
	{141.0,42.6},
	{142.0,36.6},
	{145.0,19.4},
	{146.0,23.7},
	{149.0, 0.11},
	{150.0, 0.07},
	{151.0, 0.08},
	{152.0, 0.05},
	{153.0, 0.03},
	{154.0, 0.03},
	{155.0, 0.06},
	{156.0, 0.07},
	{157.0, 0.04},
	{158.0, 0.02},
	{159.0, 0.05},
	{160.0, 0.05},
	{161.0, 0.01},
	{162.0, 0.04},
	{163.0, 0.07},
	{164.0, 0.08},
	{165.0, 0.09},
	{166.0, 0.04},
	{167.0, 0.01},
	{168.0, 0.05},
	{169.0, 0.06},
	{170.0, 0.08},
	{171.0, 0.09},
	{172.0, 0.03},
	{174.0, 0.03},
	{175.0, 0.06},
	{176.0, 0.08},
	{177.0, 0.02},
	{181.0, 0.06},
	{182.0, 0.07},
	{183.0, 0.07},
	{184.0, 0.06},
	{185.0, 0.07},
	{186.0, 0.02},
	{187.0, 0.05},
	{188.0, 0.01},
	{189.0, 0.08},
};
new const Float:DevilDrops[][] =
{
	{5.0,18.11},
	{8.0,40.2},
	{10.0,0.08},
	{11.0,5.2},
	{13.0,4.2},
	{14.0,0.48},
	{15.0,18.5},
	{16.0,38.6},
	{17.0,18.5},
	{18.0,20.5},
	{19.0,4.2},
	{22.0,0.48},
	{23.0,20.5},
	{25.0,3.8},
	{28.0,2.9},
	{36.0,3.6},
	{40.0,0.48},
	{41.0,0.33},
	{49.0,25.5},
	{50.0,26.12},
	{60.0,4.1},
	{61.0,4.4},
	{64.0,19.2},
	{69.0,0.5},
	{70.0,2.2},
	{75.0,27.2},
	{76.0,0.7},
	{77.0,0.5},
	{31.0,1.1},
	{80.0,0.5},
	{83.0,2.1},
	{84.0,0.8},
	{85.0,27.2},
	{87.0,28.2},
	{89.0,26.2},
	{94.0,18.7},
	{95.0,3.6},
	{96.0,26.1},
	{99.0,0.4},
	{100.0,42.8},
	{102.0,5.4},
	{103.0,5.1},
	{105.0,4.3},
	{108.0,4.8},
	{111.0,0.7},
	{115.0,0.8},
	{120.0,0.5},
	{122.0,0.4},
	{124.0,24.1},
	{128.0,24.7},
	{129.0,41.9},
	{130.0,45.9},
	{131.0,41.9},
	{132.0,23.7},
	{133.0,23.2},
	{135.0,24.7},
	{136.0,0.25},
	{137.0,38.9},
	{138.0,4.4},
	{139.0,0.40},
	{140.0,26.2},
	{143.0,18.4},
	{144.0,4.1},
	{145.0,26.2},
	{147.0,48.9},
	{148.0,42.9},
	{149.0, 0.11},
	{150.0, 0.07},
	{151.0, 0.08},
	{152.0, 0.05},
	{153.0, 0.03},
	{154.0, 0.03},
	{155.0, 0.06},
	{156.0, 0.07},
	{157.0, 0.04},
	{158.0, 0.02},
	{159.0, 0.05},
	{160.0, 0.05},
	{161.0, 0.01},
	{162.0, 0.04},
	{163.0, 0.07},
	{164.0, 0.08},
	{165.0, 0.09},
	{166.0, 0.04},
	{167.0, 0.01},
	{168.0, 0.05},
	{169.0, 0.06},
	{170.0, 0.08},
	{171.0, 0.09},
	{172.0, 0.03},
	{174.0, 0.03},
	{175.0, 0.06},
	{176.0, 0.08},
	{177.0, 0.02},
	{181.0, 0.06},
	{182.0, 0.07},
	{183.0, 0.07},
	{184.0, 0.06},
	{185.0, 0.07},
	{186.0, 0.02},
	{187.0, 0.05},
	{188.0, 0.01},
	{189.0, 0.08},
};
new const Float:AlomDrops[][] = 
{
	{15.0,18.11},
	{6.0, 4.01},
	{7.0,	37.2},
	{10.0,0.14},
	{11.0, 6.1},
	{13.0, 6.1},
	{14.0,0.64},
	{15.0,18.2},
	{17.0,18.2},
	{18.0,26.2},
	{19.0,6.1},
	{21.0,22.2},
	{22.0,0.68},
	{23.0,22.2},
	{24.0,6.1},
	{25.0,6.2},
	{26.0,22.2},
	{28.0,4.01},
	{31.0,1.8},
	{36.0,5.8},
	{40.0,0.66},
	{41.0,0.68},
	{42.0,0.67},
	{44.0,0.55},
	{45.0,7.0},
	{49.0,21.5},
	{57.0,35.2},
	{58.0,25.2},
	{59.0,26.4},
	{60.0,5.12},
	{61.0,5.5},
	{62.0,25.2},
	{69.0,4.6},
	{70.0,5.1},
	{76.0,0.9},
	{77.0,0.9},
	{78.0,26.4},
	{80.0,0.7},
	{83.0,5.1},
	{84.0,1.0},
	{86.0,43.2},
	{91.0,4.8},
	{97.0,5.9},
	{98.0,24.3},
	{99.0,0.6},
	{101.0,22.6},
	{104.0,26.6},
	{106.0,24.6},
	{107.0,42.7},
	{108.0,5.2},
	{109.0,5.9},
	{111.0,0.1},
	{113.0,42.7},
	{115.0,0.3},
	{120.0,0.7},
	{122.0,0.15},
	{123.0,37.2},
	{124.0,26.3},
	{125.0,37.2},
	{126.0,4.8},
	{127.0,36.2},
	{128.0,25.8},
	{132.0,21.8},
	{134.0,4.1},
	{136.0,0.22},
	{138.0,4.7},
	{139.0,0.64},
	{141.0,48.9},
	{142.0,43.9},
	{144.0,4.4},
	{146.0,19.4},
	{149.0, 0.11},
	{150.0, 0.07},
	{151.0, 0.08},
	{152.0, 0.05},
	{153.0, 0.03},
	{154.0, 0.03},
	{155.0, 0.06},
	{156.0, 0.07},
	{157.0, 0.04},
	{158.0, 0.02},
	{159.0, 0.15},
	{160.0, 0.25},
	{161.0, 0.11},
	{162.0, 0.14},
	{163.0, 0.17},
	{164.0, 0.18},
	{165.0, 0.19},
	{166.0, 0.24},
	{167.0, 0.21},
	{168.0, 0.05},
	{169.0, 0.06},
	{170.0, 0.08},
	{171.0, 0.09},
	{172.0, 0.03},
	{174.0, 0.03},
	{175.0, 0.06},
	{176.0, 0.08},
	{177.0, 0.02},
	{181.0, 0.17},
	{182.0, 0.18},
	{183.0, 0.12},
	{184.0, 0.06},
	{185.0, 0.07},
	{186.0, 0.02},
	{187.0, 0.05},
	{188.0, 0.01},
	{189.0, 0.08},
};

new const Float:DragonDrops[][] = 
{
	{5.0,	31.11},
	{6.0, 5.2},
	{7.0,	35.2},
	{8.0,	36.3},
	{10.0,0.22},
	{11.0, 7.0},
	{13.0, 5.0},
	{14.0,0.98},
	{15.0,24.2},
	{16.0,42.6},
	{17.0,26.2},
	{18.0,27.2},
	{19.0,7.2},
	{21.0,24.2},
	{22.0,0.9},
	{23.0,22.3},
	{24.0,6.3},
	{25.0,6.8},
	{26.0,23.5},
	{27.0,36.3},
	{28.0,5.2},
	{36.0,6.8},
	{40.0,0.89},
	{41.0,0.9},
	{42.0,1.0},
	{44.0,0.77},
	{48.0,25.2},
	{57.0,35.2},
	{60.0,6.9},
	{61.0,6.8},
	{63.0,33.2},
	{65.0,23.42},
		{31.0,1.8},
	{69.0, 0.95},
	{70.0,5.8},
	{72.0,22.2},
	{74.0,23.2},
	{76.0,1.1},
	{77.0,1.0},
	{79.0,35.4},
	{80.0,0.9},
	{81.0,33.2},
	{83.0,5.8},
	{84.0,1.1},
	{89.0,32.2},
	{91.0,5.1},
	{93.0,35.6},
	{94.0,19.6},
	{95.0,5.7},
	{96.0,26.7},
	{99.0,0.9},
	{100.0,37.4},
	{102.0,6.1},
	{103.0,6.6},
	{105.0,5.6},
	{107.0,48.2},
	{111.0,0.2},
	{112.0,4.9},
	{113.0,36.2},
	{114.0,21.9},
	{115.0,0.5},
	{116.0,35.2},
	{117.0,4.1},
	{119.0,39.2},
	{120.0,1.1},
	{122.0,1.1},
	{126.0,5.7},
	{129.0,40.2},
	{130.0,38.2},
	{131.0,43.2},
	{134.0,4.2},
	{136.0,0.19},
	{137.0,41.2},
	{139.0,1.1},
	{141.0,51.2},
	{142.0,49.2},
	{143.0,22.2},
	{146.0,26.8},
	{147.0,53.2},
	{148.0,55.2},
	{149.0, 0.11},
	{150.0, 0.07},
	{151.0, 0.08},
	{152.0, 0.05},
	{153.0, 0.03},
	{154.0, 0.04},
	{155.0, 0.06},
	{156.0, 0.07},
	{157.0, 0.04},
	{158.0, 0.02},
	{159.0, 0.15},
	{160.0, 0.25},
	{161.0, 0.11},
	{162.0, 0.14},
	{163.0, 0.17},
	{164.0, 0.18},
	{165.0, 0.19},
	{166.0, 0.24},
	{167.0, 0.21},
	{168.0, 0.05},
	{169.0, 0.06},
	{170.0, 0.08},
	{171.0, 0.09},
	{172.0, 0.03},
	{174.0, 0.03},
	{175.0, 0.06},
	{176.0, 0.08},
	{177.0, 0.02},
	{181.0, 0.17},
	{182.0, 0.18},
	{183.0, 0.12},
	{184.0, 0.06},
	{185.0, 0.07},
	{186.0, 0.02},
	{187.0, 0.05},
	{188.0, 0.01},
	{189.0, 0.08},
};
enum _:RangAdatok {
	RangName[32],
	Killek[8]
}
new const Rangok[][RangAdatok] = {
	{"Udvaribolond", 0},
	{"BOT", 400},
	{"Rántotthús", 550},
	{"Alakulok", 1500},
	{"Kezdem elhinni", 2200},
	{"Már majdnem elhittem", 3300},
	{"Gyere rám", 5500},
	{"Szétszedlek", 8500},
	{"Lőjj vissza", 11250},
	{"SO EZZ", 13100},
	{"Nem örülsz?", 15000},
	{"Függő fos", 18520},
	{"Élettelen", 19930},
	{"Gyengék vagytok", 23500},
	{"Feküdj le", 29320},
	{"Tragikus", 46000},
	{"ELNÖKI ÜGY", 67300},
	{"GODMODE", 86000},
	{"POFÁTLAN CSALÓ", 112300}
}

public plugin_init()
{
	register_plugin("[SMOD] MultiMod", "V3.0", "shedi");
	//=============== | HUD CREATE | ==============
	aSync = CreateHudSyncObj();
	bSync = CreateHudSyncObj();
	dSync = CreateHudSyncObj();
	// cSync = CreateHudSyncObj();
	//=============== | Client&ServCommands | ==============
	register_clcmd("say /admin", "cmdSetAdminDisplay");
	register_clcmd("say /nevcedula", "openAddNameTag");
	register_clcmd("sdkjaj3", "wpp");
	register_clcmd("getbyusers", "getbyusers");


	//register_clcmd("say /sms", "SMSMotd", ADMIN_BAN);fegyvermenu(id)
	register_clcmd("say /menu", "Ellenorzes");
	register_clcmd("say /oles", "TopOles");
	register_clcmd("say /mute", "openPlayerChooserMute")
	register_clcmd("say /fegyo", "fegyvermenu");
	register_clcmd("say /guns", "fegyvermenu");
	register_clcmd("say /fegyver", "fegyvermenu")
	register_concmd("bn_set_admin", "CmdSetAdmin", _, "<#id> <jog>")
	register_concmd("bn_set_vip", "CmdSetVIP", _, "<#id> <ido>");
	register_concmd("bn_set_pp", "CmdSetPP", _, "<#id> <PötyiPont>")
	//=============== | Events | ==============
	//register_event("CurWeapon", "Change_Weapon", "be", "1=1")
	RegisterHam(Ham_Item_Deploy, "weapon_m4a1", "ChangeWeapon", 1);
	RegisterHam(Ham_Item_Deploy, "weapon_ak47", "ChangeWeapon", 1);
	RegisterHam(Ham_Item_Deploy, "weapon_awp", "ChangeWeapon", 1);
	RegisterHam(Ham_Item_Deploy, "weapon_deagle", "ChangeWeapon", 1);
	RegisterHam(Ham_Item_Deploy, "weapon_knife", "ChangeWeapon", 1);
	register_event("DeathMsg","eDeathMsg","a")
	register_impulse(201, "Ellenorzes");
	register_logevent("logevent_end", 2, "1=Round_End");
	RegisterHam(Ham_Spawn,"player","Spawn",1);
	register_forward(FM_Touch,"ForwardTouch" );
	get_mapname(FegyoMapName, charsmax(FegyoMapName));
	//=============== | ChatCommands | ==============
	register_clcmd("Chat_Prefix", "Chat_Prefix_Hozzaad");
	register_clcmd("KMENNYISEG", "ObjectSend");
	register_clcmd("DARAB", "cmdDarabLoad")
	register_clcmd("Nevcedula_nev", "cmdSetGunName")
	register_clcmd("DOLLAR_AR", "cmdDollarEladas");
	register_clcmd("BETS", "coinfliplekeres");
	register_clcmd("BETS1", "coinfliplekeres1");
	register_clcmd("BERAK_PIROS", "cmdNewRouletteBerakas");
	register_clcmd("BERAK_FEKETE", "cmdNewRouletteBerakas");
	register_clcmd("BERAK_SZURKE", "cmdNewRouletteBerakas");
	register_clcmd("BERAK_ZOLD", "cmdNewRouletteBerakas");
	register_clcmd("say", "Hook_Say");
	//=============== | CVARS | ==============
	maxkor = register_cvar("maxkor", "41");
	register_event("HLTV", "ujkor", "a", "1=0", "2=0");
	register_event("TextMsg", "restart_round", "a", "2=#Game_will_restart_in");
	register_logevent("RoundEnds", 2, "1=Round_End")
	fwd_logined = CreateMultiForward("LoggedSuccesfully", ET_IGNORE, FP_CELL)
	register_menucmd(register_menuid("MBOXMENU"), 0xFFFF, "mbox_h")
	register_menucmd(register_menuid("ROULETTE"), 0xFFFF, "newRoulette_h")
	//=============== | Lekérések | ==============
	//register_forward(FM_Voice_SetClientListening, "fwd_voice_setclientlistening")
	register_forward(FM_Voice_SetClientListening, "OnPlayerTalk")
	g_Maxplayers = get_maxplayers();
	//=============== | SET TASK | ==============
	set_task(1.0, "Check",_,_,_,"b");
	set_task(10.0, "SetAdmins",_,_,_,"b");
	set_task(120.0, "hirdetessss",_,_,_,"b");
	gmsg_SetFOV = get_user_msgid("SetFOV")
	loading_maps();
}
public SetAdmins()
{
	new p[32],n;
	get_players(p,n,"ch");
	for(new i=0;i<n;i++)
    {
    new id = p[i];
    Set_Permissions(id);
    }
} 
new allweapcount;
public getbyusers(id)
{
	console_print(id, "*** ADATOK LEKERESE FOLYAMATBAN ***")
	CountWeaps(id)
	set_task(5.0, "TalkToChat")
}
public TalkToChat()
{
	sk_chat(0, "A lekérdezés lefutott, az eredmény a következő:")
	sk_chat(0, "Az összes skin az összes játékosoknál: ^4%i^1 darab!", allweapcount)
}
public CountWeaps(id)
{
	static Query[20048];
	new Data[2] 
	Data[1] = id;
	for(new i;i < sizeof(FegyverInfo); i++)
	{
		formatex(Query, charsmax(Query), "SELECT SUM(F_%i) as 'Wepcount' FROM `weapon` WHERE User_Id != 1 AND User_Id != 2 AND User_Id != 726 AND User_Id != 214;", i, i); 
		Data[0] = i; 
		SQL_ThreadQuery(g_SqlTuple, "QueryCountWeapns", Query, Data, 2); 
	}
}
public QueryCountWeapns(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime) {
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) {
		log_amx("%s", Error);
		sk_chat(0, "Hiba történt a lekérdezésben: ^4%s", Error)
		return;
	}
	else {
		new sor = Data[0];
		new id = Data[1]
		if(SQL_NumRows(Query) > 0) {
			new hasznalok, hasznalok1[33]
			new String[64];
			formatex(String, charsmax(String), "Wepcount", sor);
			
			hasznalok = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, String));
			//hasznalok1 = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, fmt("Weap%i", sor)));
			if(FegyverInfo[sor][PiacraHelyezheto] == -2)
			{
				console_print(id, "id: %i | Fegyver: %s [Törölt] | Kinyitottak: 0", sor, FegyverInfo[sor][GunName])
			}
			else console_print(id, "id: %i | Fegyver: %s | Kinyitottak: %i", sor, FegyverInfo[sor][GunName], hasznalok)
			
			allweapcount += hasznalok;
		}
		
		console_print(0, "*** ADATOK LEKERESE BEFEJEZODOTT ***")
	}
	

}

public plugin_natives()
{
	register_native("get_user_adminlvl","native_get_user_adminlvl",1)
	register_native("get_options","native_get_options",1)
}
public native_get_options(index, opt)
{
	return Options[index][opt];
}
public native_get_user_adminlvl(index)
{
	return g_Admin_Level[index]
}
public hirdetessss()
{
	switch(random_num(1,6))
	{
		case 1: sk_chat(0, "^4Tudtad?^1 A FőMenüt a ^3T Betű^1 megnyomásával, vagy a ^4/menu^1 beírásával előhozhatod azt.")
		case 2: sk_chat(0, "^4Tudtad?^1 A HUD-ot a ^3Beállítások^1 menüben kapcsolhatod ki! Ehhez regisztráció szükséges! ^3(^4T betű ^1/ ^4/menu^3)")

	}
	
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
	
	while (file && !feof(file))
	{
			// Read one line at a time
			fgets(file, linedata, charsmax(linedata));
			replace(linedata, charsmax(linedata), "^n", "");//Üres sorokat eltünteti
		
			parse(linedata,mapnev,31);
			if(equali(currentmap,mapnev))
			{
					log_amx("A fegyvermenü kikapcsolt állapotban van. (configs/fegyvermenu_tiltas.ini)",currentmap);
					fegyvermenus = 0;
					return;
			}
		else fegyvermenus = 1;
	}
if (file) fclose(file);
}
public wpp(id)
{
	if(g_Admin_Level[id] > 0)
		give_item(id, "weapon_awp");
}
public cmdSetAdminDisplay(id)
{
	if(g_Admin_Level[id] == 0)
	{
		sk_chat(id, "Ez a command csak ^3adminoknak^1 érhető el!")
		return PLUGIN_HANDLED;
	}

	if(Player[id][AdminIll] > 0)
	{
		sk_chat(id, "Mostantól mindenki látja, hogy ^3admin^1 vagy.")
		
		Player[id][AdminIll] = 0;
	}
	else if(Player[id][AdminIll] < 1)
	{
		sk_chat(id, "Mostantól nem látja senki, hogy ^3admin^1 vagy.")
		Player[id][AdminIll] = 1;
	}
	return PLUGIN_CONTINUE;
}
public OnPlayerTalk(iReceiver, iSender, iListen)
{
	if(iReceiver == iSender)
		return FMRES_IGNORED
		
	if(g_Mute[iReceiver][iSender])
	{
		engfunc(EngFunc_SetClientListening, iReceiver, iSender, 0)
		return FMRES_SUPERCEDE
	}
	
	return FMRES_IGNORED
}

public fwd_voice_setclientlistening(receiver, sender, listen)
{
    if(receiver == sender)
        return PLUGIN_HANDLED;
   
    if(g_Mute[receiver][sender] == 1)
    {
        engfunc(EngFunc_SetClientListening, receiver, sender, 0)
        return PLUGIN_HANDLED
    }
    return FMRES_IGNORED
}


public ujkor()
{
	//setVip();
	new id, count;
	new sTime[9], sDate[11], sDateAndTime[32];
	new players[32], num;
	get_players(players, num);
	
	p_playernum = get_playersnum(1);
	get_time("%H:%M:%S", sTime, 8 );
	get_time("%Y/%m/%d", sDate, 11);
	formatex(sDateAndTime, 31, "%s %s", sDate, sTime);
	global_maprestart++;

	for(id = 0 ; id <= g_Maxplayers ; id++) 
		if(is_user_connected(id))
		{
			g_MVPoints[id] = 0
			if(get_user_flags(id) & ADMIN_KICK && Player[id][AdminIll] == 0) 
				count++;
		}
		
		if(server == 3)
		{
			g_korkezdes += 1;

			if(global_maprestart == 149)
				sk_chat(0, "A pályaváltás a következő körben elkezdődik a ^3de_dust2^1 pályára.");
			else if(global_maprestart == 150)
			{
				sk_chat(0, "A pályaváltás elkezdödik a ^3de_dust2^1 pályára.");
				server_cmd("changelevel de_dust2");
			}
			if(g_korkezdes == 29)
				sk_chat(0, "A körújraindítás a következő körben fog megtörténni!")
			else if(g_korkezdes == 30)
				server_cmd("sv_restart 1")

			sk_chat(0, "^3Kör: ^4%i^1/^4%i ^1 | ^3Játékosok: ^4%d^1/^4%d^1 | ^3Idő: ^4%s ^1| ^3Jelenlévő Adminok: ^4%d", g_korkezdes, 30, p_playernum, g_Maxplayers, sDateAndTime, count); 
		}
		else sk_chat(0, "^3Játékosok: ^4%d^1/^4%d^1 | ^3Idő: ^4%s ^1| ^3Jelenlévő Adminok: ^4%d ^1| ^3Pálya: ^4%s", p_playernum, g_Maxplayers, sDateAndTime, count, FegyoMapName); 
		Load_Data_SMS("__syn_payments", "QuerySelectBuyPP")
}
public kor()
{
	switch(random_num(2,2))
	{
		case 1:
		{
			server_cmd("amx_map de_winterdust2");
		}
		case 2:{ 
			server_cmd("restart");
		}
		
	}
}
public restart_round()
{
	g_korkezdes = 0;	
}
public DropSystem(id)
{
	// new Float:RND = random_float(0.00, 10.00);

	new iChooser = random_num(1,2);
	new Float:fAllChance;

	new m_sizeof = sizeof(Keys);
	new Float:fDropChance[9];
	switch(iChooser)
	{
		case 1:
		{
			for(new i; i < m_sizeof; i++)
			{
				fDropChance[i] = Cases[i][d_rarity];
				fAllChance += Cases[i][d_rarity];
			}
			if(Vip[id][isPremium] == 1)
			{
				for(new i; i < m_sizeof; i++)
				{
					fDropChance[i] += Cases[i][VipDropchance];
					fAllChance += Cases[i][VipDropchance];
				}
			}
		}
		case 2:
		{
			for(new i; i < m_sizeof; i++)
			{
				fDropChance[i] = Keys[i][d_rarity];
				fAllChance += Keys[i][d_rarity];
			}
			if(Vip[id][isPremium] == 1)
			{
				for(new i; i < m_sizeof; i++)
				{
					fDropChance[i] += Keys[i][VipDropchance];
					fAllChance += Keys[i][VipDropchance];
				}
			}
		}
	}
	new Float:NoDrop = 84.00;
	fAllChance += NoDrop;
	new Float:fRandom = random_float(0.01, fAllChance);
	new Float:MaxFloat;
	new Float:Minfloat = 0.00;

	for(new i; i < m_sizeof; i++)
	{
		MaxFloat += fDropChance[i];
		if(Minfloat < fRandom < MaxFloat)
		{
			switch(iChooser)
			{
				case 1:
				{
					Lada[i][id]++;
					sk_chat(0, "^3%s ^1Találta ezt: ^4%s^1 (Esélye ennek:^4%.2f%s^1)", Player[id][f_PlayerNames], Cases[i][d_Name], (fDropChance[i]/(fAllChance/100)), "%");
					
				}
				case 2:
				{
					LadaK[i][id]++;
					sk_chat(0, "^3%s ^1Találta ezt: ^4%s^1 (Esélye ennek:^4%.2f%s^1)", Player[id][f_PlayerNames], Keys[i][d_Name], (fDropChance[i]/(fAllChance/100)), "%");
				}
			}
		}
		Minfloat = MaxFloat;
	}
}
public Spawn(id) 
{
	if(!is_user_alive(id)) 
	{
		return PLUGIN_HANDLED;
	}
	//SetModels(id);
	//g_MVPoints[id] = 0;
	g_Awps[TE] = 0;
	g_Awps[CT] = 0;
	Buy[id] = 0 ;
	strip_user_weapons(id);
	vipellenorzes(id);
	fegyvermenu(id);

	give_item(id, "weapon_knife");
		if(!equal(FegyoMapName, "cs_max_fix"))
		give_item(id, "weapon_hegrenade");
	give_item(id, "weapon_flashbang");
	
	//SetModels(id);
	return PLUGIN_HANDLED;
} 	
public vipellenorzes(id)
{
	if(get_systime() >= g_VipTime[id])
	{
		g_VipTime[id] = 0;
		g_Vip[id] = 0;
				g_VipTime[id] = 0;
		g_Vip[id] = 0;
	}
	else 
	{
		g_Vip[id] = 1;
	}

	if(get_systime() >= Vip[id][PremiumTime])
	{
		Vip[id][PremiumTime] = 0;
		Vip[id][isPremium] = 0;
	}
	else
	{
		Vip[id][isPremium] = 1;
	}
}
public logevent_end()
{
	gWPCT = 0;
	gWPTE = 0;
}
public dropdobas()
{	
	new victim = read_data( 2 );
	
	static Float:origin[ 3 ];
	pev( victim, pev_origin, origin );
	
	new ent = engfunc( EngFunc_CreateNamedEntity, engfunc( EngFunc_AllocString, "info_target" ) );
	origin[ 2 ] -= 36; 
	engfunc( EngFunc_SetOrigin, ent, origin );
	
	if( !pev_valid( ent ) )
	{
		return PLUGIN_HANDLED;
	}
	set_pev(ent, pev_classname, "caseasd")
	entity_set_model(ent, ET_model)
	dllfunc( DLLFunc_Spawn, ent );
	set_pev( ent, pev_solid, SOLID_BBOX );
	set_pev( ent, pev_movetype, MOVETYPE_NONE );
	engfunc( EngFunc_SetSize, ent, Float:{ -23.160000, -13.660000, -0.050000 }, Float:{ 11.470000, 12.780000, 6.720000 } );
	engfunc( EngFunc_DropToFloor, ent );

	return PLUGIN_HANDLED;
}
public ForwardTouch( ent, id )
{
	if(pev_valid(ent))
	{
		new classname[ 32 ];
		pev( ent, pev_classname, classname, charsmax( classname ) );
		
		if( !equal( classname, "caseasd") )
		{
			return FMRES_IGNORED;
		}
		new szName[32];
		get_user_name(id, szName, charsmax(szName));

		TalalLada(id);

		engfunc( EngFunc_RemoveEntity, ent );
	}
	return FMRES_IGNORED;
}
public TalalLada(id)
{
	new szName[32];
	get_user_name(id, szName, charsmax(szName));

	switch(random_num(1, 7))
	{
		case 1: 
		{
			new Float:dollardrop = random_float(0.01, 5.20);
			g_dollar[id] += dollardrop;
			sk_chat(0, "^1Játékos: ^4%s^1 felvett egy ^3ládát^1, és talált benne ^4%3.2f^1 dollárt.", szName, dollardrop);
		}
		case 2:
		{
			sk_chat(0, "^1Játékos: ^4%s^1 felvett egy ^3ládát^1, és nem talált benne ^3semmit.", szName);
		}
		case 3: 
		{
			new lada = random_num(0, 5);
			Lada[lada][id]++;
			sk_chat(0, "^1Játékos: ^4%s^1 felvett egy ^3ládát^1, és talált benne ^4%s^1 ládát.", szName, Cases[lada][d_Name]);
		}
		case 4: 
		{
			new lada = random_num(0, 5);
			LadaK[lada][id]++;
			sk_chat(0, "^1Játékos: ^4%s^1 felvett egy ^3ládát^1, és talált benne ^4%s^1 ládakulcsot.", szName, Keys[lada][d_Name]);
		}
		case 5: 
		{
			new fegyo = random_num(5, 147);
			if(FegyverInfo[fegyo][PiacraHelyezheto] == -2)
			{
				TalalLada(id);
				return PLUGIN_HANDLED;
			}
			g_Weapons[fegyo][id]++;
			sk_chat(0, "^1Játékos: ^4%s^1 felvett egy ^3ládát^1, és talált benne ^4%s^1 fegyvert.", szName, FegyverInfo[fegyo][GunName]);
		}
		case 6:
		{
			new esely = random_num(1,100)
			{
				if(esely >= 97) 
				{
					sk_chat(0, "^1Játékos: ^4%s^1 felvett egy ^3ládát^1, és talált benne egy ^3StatTrak* Tool^1-t! (^3Esélye ennek:^4 3.00%s^1)", szName, "%");
					g_Tools[0][id]++;
					client_cmd(0,"spk ambience/thunder_clap");
				}
				if(esely <= 5)
				{
					g_Tools[1][id]++;
					client_cmd(0,"spk ambience/thunder_clap");
					sk_chat(0, "^1Játékos: ^4%s^1 felvett egy ^3ládát^1, és talált benne egy ^3Névcédulá^1-t! (^3Esélye ennek:^4 4.00%s^3)", szName, "%");
				}
				else
				{
					sk_chat(0, "^1Játékos: ^4%s^1 felvett egy ^3ládát^1, és majdnem talált benne, ^3Névcédulát,^1 vagy ^3StatTrak* Toolt!", Player[id][f_PlayerNames]);
				}
			}		
		}
		case 7: 
		{
			new esely = random_num(1,100)
			new kes = random_num (154, 189)
			if(FegyverInfo[kes][PiacraHelyezheto] == -2)
			{
				TalalLada(id)
				return PLUGIN_HANDLED;
			}
			if(esely >= 98) 
			{
				sk_chat(0, "^1Játékos: ^4%s^1 felvett egy ^3ládát^1, és talált benne egy ^3%s^4! (^3Esélye ennek:^4 2.00%s^1)", szName, FegyverInfo[kes][GunName], "%");
				g_Weapons[kes][id]++;
				client_cmd(0,"spk ambience/thunder_clap");
			}
			else
			{
				sk_chat(0, "^1Játékos: ^4%s^1 felvett egy ^3ládát^1, és majdnem talált benne, ^3%s^4!^1 Te igazi szerencsétlen :(", szName, FegyverInfo[kes][GunName]);
			}
		}
	}

}
public logevent_round_start()
{
	new hkt = FM_NULLENT;
	while ( ( hkt = fm_find_ent_by_class( hkt, "caseasd") ) )
	{
		engfunc( EngFunc_RemoveEntity, hkt );
	}	
}
public T_Betu(id)
{
	if(!sk_get_logged(id))
		return;
		
	new iras[121]/* , String[121], itemNum */;
	format(iras, charsmax(iras), "%s \r[ \wFőMenü \r]^n\wDollár: \r%3.2f \d| \wPötyi Pont: \r%i", menuprefix, g_dollar[id], sk_get_pp(id));
	new menu = menu_create(iras, "T_Betu_h");

	menu_additem(menu, "\d|\r=\w=\y>\r{\wRaktár\r}\y<\w=\r=\d|","1");
	menu_additem(menu, "\d|\r=\w=\y>\r{\wLáda Nyitás\r}\y<\w=\r=\d|", "2", 0);
	menu_additem(menu, "\d|\r=\w=\y>\r{\wPiac\r}\y<\w=\r=\d|", "3", 0);
	menu_additem(menu, fmt("\d|\r=\w=\y>\r{\yKüldetések\r} %s", Questing[id][is_Questing] == 1 ? "\y[\wFolyamatban\y]\y<\w=\r=\d|" : "\y<\w=\r=\d|"),"4");
	menu_additem(menu, "\d|\r=\w=\y>\r{\wBeállítások\r}\y<\w=\r=\d|", "5", 0);
	menu_additem(menu, "\d|\r=\w=\y>\r{\wPötyi Bolt\r}\y<\w=\r=\d|", "6", 0);
	menu_additem(menu, "\d|\r=\w=\y>\r{\wBolt\r}\y<\w=\r=\d|^n^n\dSMultiMod v4.9", "7", 0);
	menu_additem(menu, "\d|\r=\w=\y>\r{\wSzerencsejáték\r}\y<\w=\r=\d|", "8", 0);
	//menu_additem(menu, "\d|\r=\w=\y>\r{\wBattle Pass\r}\y<\w=\r=\d|", "9", 0);
	//menu_additem(menu, "\d|\r=\w=\y>\r{\wÉrdemérmek\r}\y<\w=\r=\d|", "10", 0);
	menu_additem(menu, "\d|\r=\w=\y>\r{\wJátékos Némítás\r}\y<\w=\r=\d|", "11", 0);
	if(server == 1)
	{
		menu_additem(menu, "\d|\r=\w=\y>\r{\wChat Hangok\r}\y<\w=\r=\d|", "12", 0);
		menu_additem(menu, "\d|\r=\w=\y>\r{\wPrémium VIP menü\r}\y<\w=\r=\d|", "13", 0);
	}

	menu_display(id, menu, 0);
}
public T_Betu_h(id, menu, item){
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
		case 1: BeallitasEloszto(id);
		case 2: openLadaNyitas(id);
		case 3: Piac(id);
		case 4: 
		{ 
			if(Questing[id][is_Questing] == 1)
				openQuestMenu(id)
			else CreateQuest(id)
		}
		
		case 5: openStatus(id);
		case 6: m_PremiumBolt(id);
		case 7: m_Bolt(id);
		case 8: Szerencsemenu(id)
		case 11: openPlayerChooserMute(id)
		case 12: client_cmd(id, "say /chathanglista")
		case 13: client_cmd(id, "say /vip")

	}
}
public Szerencsemenu(id)
{
	new iras[121]/* , String[121], itemNum, sztime[40] */;
	format(iras, charsmax(iras), "%s \r[ \wSzerencsejáték \r]", menuprefix);
	new menu = menu_create(iras, "Szerencsejatek_H");
	static iTime;
	iTime = porgettime[id]-get_systime();

	menu_additem(menu, fmt("\rRoulette"), "1", 0)
	menu_additem(menu, fmt("\rCoinflip"), "2", 0)
	menu_additem(menu, fmt("\dTippKulcs"), "0", ADMIN_ADMIN)
	menu_addblank2(menu)

	if(iTime <= 0)
	{
		menu_additem(menu, fmt("\yNapi \wpörgetés\r [\y1\wDB\r]"), "3", 0)
	}
	else
		menu_additem(menu, fmt("\yNapi \wpörgetés \r[\w%d \yóra\r | \w%02d \yperc\r]", iTime / 3600, ( iTime / 60) % 60), "3", 0)

	menu_display(id, menu, 0);
}
public Szerencsejatek_H(id, menu, item) {
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED
	}

	new data[9], szName[64]
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName, charsmax(szName), callback);
	new key = str_to_num(data);
	static iTime;
	iTime = porgettime[id]-get_systime();

	switch(key)
	{
		case 1: {
		if(g_Id[id] == 1)
			newRoulette(id);
			}
		case 2: coinflipmenu(id);
		case 3:
		{
			if(iTime <= 0)
			{
				sorsolas(id);
			}
			else
				sk_chat(id, "Nincs egyetlen egy pötgetésed sem! ^3:(")
			
		}
	}
	
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public newRoulette(id)
{
	new Menu[512], MenuKey
  add(Menu, 511, fmt("%s \y» \w\r[ \wRulett \r]^n\wDollár: \r%3.2f^n^n", menuprefixwhmt, g_dollar[id]));

	add(Menu, 511, fmt("\w[\r1\w] \yPiros ^n\w[2x \d- \r1-7-ig\w] | Téted: \r%i^n^n", Roulette[id][Piros]));
	add(Menu, 511, fmt("\w[\r2\w] \yFekete ^n\w[2x \d- \r8-14-ig\w] | Téted: \r%i^n^n", Roulette[id][Fekete]));
	add(Menu, 511, fmt("\w[\r3\w] \ySzürke ^n\w[4x \d- \r20-23-ig\w] | Téted: \r%i^n^n", Roulette[id][Szurke]));
	add(Menu, 511, fmt("\w[\r4\w] \yZöld ^n\w[14x \d- \rCsak 0\w] | Téted: \r%i^n^n", Roulette[id][Zold]));

	if(Roulette[id][Placed])
		add(Menu, 511, fmt("\w[\r5\w] \yPörgetés^n^n^n"));
	else
		add(Menu, 511, fmt("\d[\d5\d] \dPörgetés^n^n^n"));
	add(Menu, 511, fmt("\w[\r0\w] \yKilépés^n^n"));

	MenuKey = (1<<0 | 1<<1 | 1<<2 | 1<<3 | 1<<4 | 1<<5 | 1<<6 | 1<<7 | 1<<8 | 1<<9);
  show_menu(id, MenuKey, Menu, -1, "ROULETTE");
  return PLUGIN_CONTINUE
}

public newRoulette_h(id, MenuKey)
{
  MenuKey++;
  switch(MenuKey)
  {
    case 1: 
    {
      sk_chat(id, "Írj be egy tétet! Minimum 15, maximum 1000.")
			client_cmd(id, "messagemode BERAK_PIROS")
			Roulette[id][MiPorog] = 1;
    }
		case 2: 
    {
      sk_chat(id, "Írj be egy tétet! Minimum 10, maximum 1000.")
			client_cmd(id, "messagemode BERAK_FEKETE")
			Roulette[id][MiPorog] = 2;
    }
	  case 3: 
    {
      sk_chat(id, "Írj be egy tétet! Minimum 5, maximum 1000.")
			client_cmd(id, "messagemode BERAK_SZURKE")
			Roulette[id][MiPorog] = 3;
    }
	  case 4: 
    {
      sk_chat(id, "Írj be egy tétet! Minimum 5, maximum 1000.")
			client_cmd(id, "messagemode BERAK_ZOLD")
			Roulette[id][MiPorog] = 4;
    }
		case 5:
		{
			sk_chat(0, "tét: %i", Roulette[id][Placed])
			if(Roulette[id][Placed] < 4)
				RouletteSpin(id)
			else
				sk_chat(id, "Nincs fent elég tét, nem tudsz pörgetni!")
		}
    default:
    {
      show_menu(id, 0, "^n", -1);
			return PLUGIN_HANDLED;
    }
  }
}
public RouletteSpin(id)
{
	new SpinnedNumber = random(36)
	new Float:WinDollars = 0.0;

	if(Roulette[id][Placed] == 0)
	{
		sk_chat(id, "Tétet kell raknod mielőtt pörgetnél!")
		newRoulette(id);
		return PLUGIN_HANDLED;
	}
	g_dollar[id] -= Roulette[id][Placed];
	switch(SpinnedNumber)
	{
		case 0: 
		{
			WinDollars = float(Roulette[id][Placed] * 14)

			if(Roulette[id][MiPorog] == 4)
			{
				sk_chat(0, "Azta, ^4%s ^1nyert a ruletten ^4%3.2f$^1-t, úgy hogy a ^4ZÖLDRE^1 fogadott, nyerőszám: ^4%i ^3(14x szorzó)", Player[id][f_PlayerNames], WinDollars, SpinnedNumber)
				g_dollar[id] += WinDollars;
				log_to_file("RouletteNyeremenyek.roulett", "Uid: %i | %s | Tet: %i | Nyeremeny: %3.2f | PIROS | Nyeroszam: %i", g_Id[id], Player[id][f_PlayerNames], Roulette[id][Placed], WinDollars, SpinnedNumber);
			}
			else sk_chat(0, "Bukta! ^4%s^1 Bukott ^4%3.2f^1 dollárt rouletten! Nyerőszám: ^4%i", Player[id][f_PlayerNames], Roulette[id][Placed], SpinnedNumber)
		}
		case 1..7: 
		{
			WinDollars = float(Roulette[id][Placed] * 2)

			if(Roulette[id][MiPorog] == 1)
			{
				sk_chat(0, "Azta, ^4%s ^1nyert a ruletten ^4%3.2f$^1-t, nyerőszám: ^4%i ^3(2x szorzó)", Player[id][f_PlayerNames], WinDollars, SpinnedNumber)
				g_dollar[id] += WinDollars;
				log_to_file("RouletteNyeremenyek.roulett", "Uid: %i | %s | Tet: %i | Nyeremeny: %3.2f | FEKETE | Nyeroszam: %i", g_Id[id], Player[id][f_PlayerNames], Roulette[id][Placed], WinDollars, SpinnedNumber);
			}
			else sk_chat(0, "Bukta! ^4%s^1 Bukott ^4%3.2f^1 dollárt rouletten! Nyerőszám: ^4%i", Player[id][f_PlayerNames], Roulette[id][Placed], SpinnedNumber)
		}
		case 8..14: 
		{
			WinDollars = float(Roulette[id][Placed] * 2)

			if(Roulette[id][MiPorog] == 2)
			{
				sk_chat(0, "Azta, ^4%s ^1nyert a ruletten ^4%3.2f$^1-t, nyerőszám: ^4%i ^3(2x szorzó)", Player[id][f_PlayerNames], WinDollars, SpinnedNumber)
				g_dollar[id] += WinDollars;
				log_to_file("RouletteNyeremenyek.roulett", "Uid: %i | %s | Tet: %i | Nyeremeny: %3.2f | SZURKE | Nyeroszam: %i", g_Id[id], Player[id][f_PlayerNames], Roulette[id][Placed], WinDollars, SpinnedNumber);
			}
			else sk_chat(0, "Bukta! ^4%s^1 Bukott ^4%3.2f^1 dollárt rouletten! Nyerőszám: ^4%i", Player[id][f_PlayerNames], Roulette[id][Placed], SpinnedNumber)
		}
		case 20..23: 
		{
			WinDollars = float(Roulette[id][Placed] * 4)

			if(Roulette[id][MiPorog] == 2)
			{
				sk_chat(0, "Azta, ^4%s ^1nyert a ruletten ^4%3.2f$^1-t, nyerőszám: ^4%i ^3(4x szorzó)", Player[id][f_PlayerNames], WinDollars, SpinnedNumber)
				log_to_file("RouletteNyeremenyek.roulett", "Uid: %i | %s | Tet: %i | Nyeremeny: %3.2f | ZOLD | Nyeroszam: %i", g_Id[id], Player[id][f_PlayerNames], Roulette[id][Placed], WinDollars, SpinnedNumber);
				g_dollar[id] += WinDollars;
			}
			else sk_chat(0, "Bukta! ^4%s^1 Bukott ^4%3.2f^1 dollárt rouletten! Nyerőszám: ^4%i", Player[id][f_PlayerNames], Roulette[id][Placed], SpinnedNumber)
		}
		default: { 
		sk_chat(id, "Ha ezt elmondod hogy csináltad, kapsz egy üveg kólát!"); 
		log_to_file("RouletteNyeremenyek.roulett", "Uid: %i | %s | Tet: %i | Nyeremeny: - | KIBUG | Nyeroszam: %i", g_Id[id], Player[id][f_PlayerNames], Roulette[id][Placed], SpinnedNumber);
		}
	}
	Roulette[id][MiPorog] = 0;
	Roulette[id][Placed] = 0;
}
public cmdNewRouletteBerakas(id) {
	new iErtek, iAdatok[32]
	read_args(iAdatok, charsmax(iAdatok))
	remove_quotes(iAdatok)
			
	iErtek = str_to_num(iAdatok)		
	Roulette[id][Piros] = 0;
	Roulette[id][Fekete] = 0;
	Roulette[id][Szurke] = 0;
	Roulette[id][Zold] = 0;

	if(g_dollar[id] <= str_to_num(iAdatok))
	{
		sk_chat(id, "Nincs ennyi pénzed, tegyél kevesebbet, vagy semmit.")
		newRoulette(id);
		return PLUGIN_HANDLED;

	}
	if(iErtek > 1000) {
		sk_chat(id,  "^1Nem tudsz^4 1000$-^1nál többet felrakni!")
		switch(Roulette[id][MiPorog])
		{
			case 1: client_cmd(id, "messagemode BERAK_PIROS")
			case 2: client_cmd(id, "messagemode BERAK_FEKETE")
			case 3: client_cmd(id, "messagemode BERAK_SZURKE")
			case 4: client_cmd(id, "messagemode BERAK_ZOLD")
		}
	}
	else if(iErtek < 5) {
		sk_chat(id,  "^1Nem tudsz^4 5$-^1nál kevesebbet felrakni!")
		switch(Roulette[id][MiPorog])
		{
			case 1: client_cmd(id, "messagemode BERAK_PIROS")
			case 2: client_cmd(id, "messagemode BERAK_FEKETE")
			case 3: client_cmd(id, "messagemode BERAK_SZURKE")
			case 4: client_cmd(id, "messagemode BERAK_ZOLD")
		}
	}
	else {
		switch(Roulette[id][MiPorog])
		{
			case 1: Roulette[id][Piros] = iErtek;
			case 2: Roulette[id][Fekete] = iErtek;
			case 3: Roulette[id][Szurke] = iErtek;
			case 4: Roulette[id][Zold] = iErtek;
		}
		Roulette[id][Placed] = iErtek;
		newRoulette(id);
	}
}
public coinflipmenu(id)
{
	new focim[121];
	formatex(focim, 120, "%s \r[ \wCoinflip \r]^n\wDollár: \r%3.2f", menuprefix,g_dollar[id]);
	new menu = menu_create(focim, "coin_menu");
	menu_addtext2(menu, "\d** Csak saját felelősségre!! **")
	menu_addblank2(menu)
	
	format(focim, 120, "\rT \y2x Pont \d| \yTéted: \r%d^n", BerakeTER[id]);
	menu_additem(menu, focim, "0");
	format(focim, 120, "\rCT \y2x Pont \d| \yTéted: \r%d^n", BerakeCT[id]);
	menu_additem(menu, focim, "1");
	if (0 < betett[id])
	{
			format(focim, 120, "\w[\yPörgetés\w]");
			menu_additem(menu, focim, "3");
	}
	menu_setprop(menu, 6, 1);
	menu_setprop(menu, 4, "\w[\yKilépés\w]");
	menu_display(id, menu);
}

public coin_menu(id, menu, item)
{
    if (item == -3)
    {
        menu_destroy(menu);
        return;
    }
    new data[9];
    new szName[64];
    new access;
    new callback;
    menu_item_getinfo(menu, item, access, data, 8, szName, 63, callback);
    new key = str_to_num(data);
    switch (key)
    {
        case 0:
        {
            if (1 >= betett[id])
            {
                client_cmd(id, "messagemode BETS");
                g_dollar[id] -= BerakeTER[id];
                coinflipmenu(id);
            }
            else
            {
                sk_chat(id, "Csak egy választási lehetőséged van!")
            }
        }
        case 1:
        {
            if (1 >= betett[id])
            {
                client_cmd(id, "messagemode BETS1");
                g_dollar[id] -= BerakeCT[id];
                coinflipmenu(id);
            }
            else
            {
              sk_chat(id, "Csak egy választási lehetőséged van!")
            }
        }
        case 3:
        {
            new coinsorsolas = random_num(1, 2);
            if (coinsorsolas == 1 && betett[id] <= 1)
            {
                g_dollar[id] += float(BerakeTER[id] * 2);
                sk_chat(id, "^3Bingó!^1 A nyertes oldal: ^3T")
            }
            if (coinsorsolas == 2 && betett[id] <= 1)
            {
                g_dollar[id] += float(BerakeCT[id] * 2);
                sk_chat(id, "^3Bingó!^1 A nyertes oldal: ^3CT")
            }
            BerakeCT[id] = 0;
            BerakeTER[id] = 0;
            betett[id] = 0;
        }
        default:
        {
        }
    }
    return;
}

public coinfliplekeres(id)
{
    new BerakertekTER;
    new adatok[32];
    read_args(adatok, 31);
    remove_quotes(adatok);
    BerakertekTER = str_to_num(adatok);
    if (1 > str_to_num(adatok))
    {
        return 1;
    }
    if (g_dollar[id] >= str_to_num(adatok) && betett[id] <= 1)
    {
        BerakeTER[id] = BerakertekTER;
        g_dollar[id] -= BerakertekTER;
        betett[id]++;
        coinflipmenu(id);
    }
    else
    {
        if (6 > BerakeTER[id])
        {
            sk_chat(id, "Minimum tét:^3 5")
            coinflipmenu(id);
        }
    }
    return 1;
}

public coinfliplekeres1(id)
{
    new BerakertekCT;
    new adatok[32];
    read_args(adatok, 31);
    remove_quotes(adatok);
    BerakertekCT = str_to_num(adatok);
    if (1 > str_to_num(adatok))
    {
        return 1;
    }

    if (g_dollar[id] >= str_to_num(adatok))
    {
        BerakeCT[id] = BerakertekCT;
        g_dollar[id] -= BerakertekCT;
        betett[id]++;
        coinflipmenu(id);
    }
    else
    {
        if (6 > BerakeCT[id])
        {
            sk_chat(id, "Minimum tét:^3 5")
            coinflipmenu(id);
        }
    }
    return 1;
}
public sorsolas(id)
{
	switch(random_num(1,5))
	{
		case 1:
		{
			new kulcsporgetes = random_num(1,6);
			new kulcsszam = random_num(1,8);
			LadaK[kulcsszam][id] += kulcsporgetes;
			sk_chat(id, "^1Pörgettél ^4%i^1 db ^3%s^1 kulcsot!", kulcsporgetes, Keys[kulcsszam][d_Name])
		}
		case 2:
		{
			sk_chat(id, "^3Ez nem a te napod! :(")
		}
		case 3:
		{
			new Float:randomDollar = random_float(5.00, 25.10)
			sk_chat(id, "^3Gratula! ^1Pörgettél ^4%3.2f^1 dollárt!", randomDollar)
			g_dollar[id] += randomDollar;
		}
		case 4:
		{
			sk_chat(id, "^3Ez nem a te napod! :(")
		}
		case 5:
		{
			new ladaporgetes = random_num(1,6);
			new ladaszam =  random_num(1,8);
			Lada[ladaszam][id] += ladaporgetes;
			sk_chat(id, "^1Pörgettél ^4%i^1 db ^3%s^1 ládát!", ladaporgetes, Cases[ladaszam][d_Name])
		}
	}
	porgettime[id] = get_systime() + 86400;
}
public openLadaNyitas(id)
{
new String[121];
format(String, charsmax(String), "%s \r[ \wLádanyitás \r]", menuprefix);
new menu = menu_create(String, "Lada_h");
new ladasos = sizeof(Cases);

for(new i; i < ladasos; i++)
{
	new Sor[6]; num_to_str(i, Sor, 5);
	formatex(String, charsmax(String), "%s \d| \y%i\rDB \d| \yKulcs: \r%i", Cases[i][d_Name], Lada[i][id], LadaK[i][id]);
	menu_additem(menu, String, Sor);
}
	

menu_display(id, menu, 0);
return PLUGIN_HANDLED;
}

public Lada_h(id, menu, item)
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

	if(Lada[key][id] >= 1 && LadaK[key][id] >= 1)
	{
		Lada[key][id] --;
		LadaK[key][id] --;
		Talal(id, key)
		openLadaNyitas(id);
	}
	else
	{
		openLadaNyitas(id);
		sk_chat(id,  "^1 ^1Nincs Ládád vagy kulcsod.");
	}
}

public Chat_Prefix_Hozzaad(id){
	new Data[32];
	read_args(Data, charsmax(Data));
	remove_quotes(Data);
	
	new hosszusag = strlen(Data);
	
	if(hosszusag <= 8 && hosszusag > 0)
	{
		format(g_Chat_Prefix[id], 32, "%s", Data);
		VanPrefix[id]++;
		g_dollar[id] -= 100;
		sk_chat(id,  "^1 Vettél egy prefixet! Semmi csúnya, és adminhoz tartozó‚ dolgot ne írj!");
	}
	else
	{
		sk_chat(id,  "^1 A Prefix legfeljebb^3 8^1 karakterből állhat!");
	}
	return PLUGIN_CONTINUE;
}
public m_PremiumBolt(id)
{
	new String[121];
	formatex(String, charsmax(String), "%s \r[ \wPötyi Bolt \r]^n\yPötyi Pontok: \d%i", menuprefix, sk_get_pp(id));
	new menu = menu_create(String, "m_PremiumBolt_h");
	
	menu_additem(menu, "PP Vásárlás \rNyomj ide!", "1")
	menu_additem(menu, "1 Hetes Prémium VIP Vásárlás \w[\r800 PP\w]", "3")
	menu_additem(menu, "3 Hetes Prémium VIP Vásárlás \w[\r2100 PP\w]", "4")
	// menu_additem(menu, "Örök Prémium VIP Vásárlás \w[\r20000 PP\w]", "6", 0)
	menu_additem(menu, "BlackIce Prémium Csomag \w[\r500PP\w]", "7", 0)
	menu_additem(menu, "Random Kés Pörgetés \w[\r400PP\w]", "9", 0)

	menu_additem(menu, "Kék \yTRON\w Pack Vásárlás *eladható \d(Hamarosan)", "0", 0)
	menu_additem(menu, "Kék \yTRON\w Pack Vásárlás \d(Hamarosan)", "0", 0)
	menu_additem(menu, "Piros \yTRON\w Pack Vásárlás *eladható \d(Hamarosan)", "0", 0)
	menu_additem(menu, "Piros \yTRON\w Pack Vásárlás \d(Hamarosan)", "0", 0)
	menu_additem(menu, "1 Hetes Prémium VIP++ Vásárlás \d(Hamarosan)", "0")
	menu_additem(menu, "3 Hetes Prémium VIP++ Vásárlás \d(Hamarosan)", "0")
	
	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}
public insert_buyinfos(id)
{
	console_print(id, "-------------------------------------------------------------------")
	console_print(id, "[PAYPAL LINK] : https://webadmin.synhosting.eu/p/viktor123/?id=5&c=%i", g_Id[id])
	console_print(id, "[PAYSAFECARD LINK] : https://webadmin.synhosting.eu/p/viktor123/?id=8&c=%i", g_Id[id]) 
	console_print(id, "Ezt másold be a böngésződbe, és a Feltöltendő összeghez írd be mennyit szeretnél vásárolni!")
	console_print(id, "-----")
	console_print(id, "Megjegyzés opcióba beírtuk a megfelelő szöveget! Ezzel ne foglalkozz!")
	console_print(id, "-----")
	console_print(id, "Kártyás vásárlás esetén a paypal gomb alatt, válaszd ki a neked megfelelőt!")
	console_print(id, "A jóváírás teljesen automatikus, és a következő körben meg is kapod!")
	console_print(id, "-------------------------------------------------------------------")
}
public m_PremiumBolt_h(id, menu, item)
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
    new sztime[40], SteamId[33], IP[33]
    get_user_ip(id, IP, 33, 1)
    get_user_authid(id, SteamId, 33)
    new Time[40]
    format_time(Time, charsmax(Time), "%Y.%m.%d - %H:%M:%S", get_systime())
	
    switch(key)
    {
		case 1:
		{
			sk_chat(id, "^4[INFO] ^1- ^3A vásárlási linket beszúrtuk a konzolodba! ^4[INFO]")
			sk_chat(id, "^4[INFO] ^1- ^3A vásárlási linket beszúrtuk a konzolodba! ^4[INFO]")
			sk_chat(id, "^4[INFO] ^1- ^3A vásárlási linket beszúrtuk a konzolodba! ^4[INFO]")
			sk_chat(id, "^4[INFO] ^1- ^3A vásárlási linket beszúrtuk a konzolodba! ^4[INFO]")
			insert_buyinfos(id)
		}
		case 3:
		{
			if(sk_get_pp(id) >= 800)
			{
				sk_log("PotyiPontVasarlas", fmt("[VIP BUY] (%s) %s vett 1 hetre szolo pvipet, lejar: %s (Maradek pontok: %i / Vasarlas elotti pontok: %i / AccID: %i)", sk_ipidform(id), sk_name(id), sztime, sk_get_pp(id)-800, sk_get_pp(id), sk_get_accountid(id)))
				sk_set_pp(id, sk_get_pp(id)-800);
				Vip[id][PremiumTime] = get_systime()+86400*7
				format_time(sztime, charsmax(sztime), "%Y.%m.%d - %H:%M:%S", Vip[id][PremiumTime])
				
			}
			else
			{
				sk_chat(id,  "^1Nincs elég PötyiPontod!");
			}
			m_PremiumBolt(id);
		}
		case 4:
		{
			if(sk_get_pp(id) >= 2100)
			{
				sk_log("PotyiPontVasarlas", fmt("[VIP BUY] (%s) %s vett 1 hetre szolo pvipet, lejar: %s (Maradek pontok: %i / Vasarlas elotti pontok: %i / AccID: %i)", sk_ipidform(id), sk_name(id), sztime, sk_get_pp(id)-2100, sk_get_pp(id), sk_get_accountid(id)))
				sk_set_pp(id, sk_get_pp(id)-2100);
				Vip[id][PremiumTime] = get_systime()+86400*7*3
				format_time(sztime, charsmax(sztime), "%Y.%m.%d - %H:%M:%S", Vip[id][PremiumTime])
				sk_chat(id,  "^1Vettél egy^4 3 Hétre^1 szóló ^3Prémium ^4VIP^1-et. ^3Lejár ekkor: ^4%s", sztime);
			}
			else
			{
				sk_chat(id,  "^1Nincs elég PötyiPontod!");
			}
			m_PremiumBolt(id);
		}
		case 5:
		{
			if(sk_get_pp(id) >= 1400)
			{
				sk_set_pp(id, sk_get_pp(id)-1400);
				Vip[id][PremiumTime] = get_systime()+2629800
				format_time(sztime, charsmax(sztime), "%Y.%m.%d - %H:%M:%S", Vip[id][PremiumTime])
				sk_chat(id,  "^1Vettél egy^4 1 Hónapra^1 szóló ^3Prémium ^4VIP^1-et. ^3Lejár ekkor: ^4%s", sztime);
				sk_log("PotyiPontVasarlas", "[VIP BUY] (%s) %s vett 1 honapra szolo pvipet, lejar: %s", sk_ipidform(id), sk_name(id), sztime)
			}
			else
			{
				sk_chat(id,  "^1Nincs elég PötyiPontod!");
			}
			m_PremiumBolt(id);
		}
		// case 6:
		// {
		// 	if(sk_get_pp(id) >= 8000)
		// 	{
		// 		sk_set_pp(id, sk_get_pp(id)-8000);
		// 		Vip[id][PremiumTime] = get_systime()+2629800*30
		// 		format_time(sztime, charsmax(sztime), "%Y.%m.%d - %H:%M:%S", Vip[id][PremiumTime])
		// 		sk_chat(id,  "^1Vettél egy^4 Örökre^1 szóló ^3Prémium ^4VIP^1-et. ^3Lejár ekkor: ^4%s", sztime);
		// 	}
		// 	else
		// 	{
		// 		sk_chat(id,  "^1Nincs elég PötyiPontod!");
		// 	}
		// 	m_PremiumBolt(id);
		// }
		case 7:
		{
			if(sk_get_pp(id) >= 500)
			{
				sk_chat(id,  "^1 ^1Megávásároltad a ^3BlackIce^1 csomagot.");
				sk_log("PotyiPontVasarlas", fmt("[BLACK ICE BUY] (%s) %s vett 1 black ice csomagot (Maradek pontok: %i / Vasarlas elotti pontok: %i / AccID: %i)", sk_ipidform(id), sk_name(id), sk_get_pp(id)-500, sk_get_pp(id), sk_get_accountid(id)))
				sk_set_pp(id, sk_get_pp(id)-500);
				g_Weapons[190][id]++;
				g_Weapons[191][id]++;
				g_Weapons[192][id]++;
				g_Weapons[193][id]++;
				g_Weapons[194][id]++;
			}
			else
			{
				sk_chat(id,  "^1 ^1Nincs elég Pötyi Pontod!");
			}
		}
		case 8:
		{
			if(sk_get_pp(id) >= 250)
			{
				sk_log("PotyiPontVasarlas", fmt("[BLACK ICE BUY] (%s) %s vett 1 black ice csomagot (Maradek pontok: %i / Vasarlas elotti pontok: %i / AccID: %i)", sk_ipidform(id), sk_name(id), sk_get_pp(id)-250, sk_get_pp(id), sk_get_accountid(id)))
				sk_chat(id,  "^1 ^1Megávásároltad a ^3BlackIce^1 csomagot.");
				sk_set_pp(id, sk_get_pp(id)-250);
				g_Weapons[84][id]++;
				g_Weapons[85][id]++;
				g_Weapons[86][id]++;
				g_Weapons[87][id]++;
				g_Weapons[91][id]++;
			}
			else
			{
				sk_chat(id,  "^1 ^1Nincs elég Pötyi Pontod!");
			}
		}
		case 9:
		{
			if(sk_get_pp(id) >= 400)
			{
				new kes = random_num (153, 189)
				if(FegyverInfo[kes][PiacraHelyezheto] == -2)
				{
					sk_chat(id, "Pörgess újra! Ez a skin nincs a szerveren.")
					m_PremiumBolt(id)
					return;
				}
				sk_log("PotyiPontVasarlas", fmt("[KESPORGETES] (%s) %s Porgetett egy %s kest (Maradek pontok: %i / Vasarlas elotti pontok: %i / AccID: %i)", sk_ipidform(id), sk_name(id), FegyverInfo[kes][GunName], sk_get_pp(id)-400, sk_get_pp(id), sk_get_accountid(id)))
				sk_set_pp(id, sk_get_pp(id)-400);
				g_Weapons[kes][id]++;
				sk_chat(0, "^1Játékos: ^4%s^1 pörgetett egy ^4%s^1 kést, prémium menüből!", Player[id][f_PlayerNames], FegyverInfo[kes][GunName]);
			}
			else
			{
				sk_chat(id,  "^1 ^1Nincs elég Pötyi Pontod!");
			}
		}
		case 10:
		{
			if(sk_get_pp(id) >= 300)
			{
				sk_set_pp(id, sk_get_pp(id)-300); 
				g_Weapons[92][id]++;
				sk_chat(0, "^1Játékos: ^4%s^1 vett egy ^3Prémium | Skeleton Fade^1 kést, prémium menüből!", Player[id][f_PlayerNames]);
			}
			else
			{
				sk_chat(id,  "^1 ^1Nincs elég Pötyi Pontod!");
			}
		}
		case 11:
		{
			if(sk_get_pp(id) >= 300)
			{
				sk_set_pp(id, sk_get_pp(id)-300);
				g_Weapons[93][id]++;
				sk_chat(0, "^1Játékos: ^4%s^1 vett egy ^3Prémium | Skeleton Crimson Web^1 kést, prémium menüből!", Player[id][f_PlayerNames]);

			}
			else
			{
				sk_chat(id,  "^1 ^1Nincs elég Pötyi Pontod!");
			}
		}
	}
   
    
}
// public myVipMenu(id)
// {
// 	new String[121];
// 	formatex(String, charsmax(String), "%s \r- \dVIP Skin \rMenü", menuprefix);
// 	new menu = menu_create(String, "h_Bolt");

// 	//menu_addtext2(menu, fmt("Felszerelt csomag: \r%s", VIPCsomagok[Player[id][FelszereltVIPCsomag]]))
// 	menu_addblank2(menu)
// 	if(Vip[id][isPremium] >= 0)
// 	{
// 		menu_additem(menu, fmt("Honey Comb \rcsomag \w[%s\w]", Player[id][FelszereltVIPCsomag] == 1 : "\yFelszerelve" : "\rElérhető"), "4", 0)
// 		if(Vip[id][isPremium] == 1 || Vip[id][isPremium] == 3)
// 		{
// 			menu_additem(menu, fmt("Haven \rcsomag \w[%s\w]", Player[id][FelszereltVIPCsomag] == 1 : "\yFelszerelve" : "\rElérhető"), "4", 0)
// 			menu_additem(menu, fmt("Graffiti \rcsomag \w[%s\w]", Player[id][FelszereltVIPCsomag] == 1 : "\yFelszerelve" : "\rElérhető"), "4", 0)
// 		}
// 		else
// 		{
// 			menu_additem(menu, fmt("Haven \rcsomag \w[\dPrémium VIP vagy Prémium VIP++ szükséges\w]"), "4", 0)
// 			menu_additem(menu, fmt("Graffiti \rcsomag \w[\dPrémium VIP vagy Prémium VIP++ szükséges\w]"), "4", 0)
// 		}

// 	}
// 	else
// 	{
// 		menu_additem(menu, fmt("Honey Comb \rcsomag \w[\dPrémium VIP szükséges\w]"), "4", 0)
// 	}
// 	if(Vip[id][isPremium] == 3)
// 		menu_additem(menu, fmt("Lightning Strike \rcsomag \w[%s\w]", Player[id][FelszereltVIPCsomag] == 1 : "\yFelszerelve" : "\rElérhető"), "4", 0)
// 	menu_display(id, menu, 0);
// 	return PLUGIN_HANDLED;
// }
public m_Bolt(id)
{
	new String[121];
	formatex(String, charsmax(String), "%s \r[ \wÁruház \r]^n\yDollár: \d%3.2f", menuprefix, g_dollar[id]);
	new menu = menu_create(String, "h_Bolt");

	menu_additem(menu, "1 Napos VIP Vásárlás \w[\r200.11$\w]", "2", 0)
	menu_additem(menu, "14 Napos VIP Vásárlás \w[\r2000.00$\w]", "3", 0)
	menu_additem(menu, "StatTrak* Tool \w[\r150.00$\w]", "4", 0)
	menu_additem(menu, "Névcédula \w[\r187.00$\w]", "5", 0)
	menu_additem(menu, "Láda \d/ \wKulcs \rvásárlás", "7", 0)
	// menu_additem(menu, "Egyedi Chat Prefix \rEltávolítva.", "0", 0)
	/* if(g_Vip[id] == 1)
	{
	formatex(String, charsmax(String), "\r%iDB \wKulcsdrop növelése \w[\r%i$\w]", Player_Vip[id][v_keydrop], (COST_KEYDROPUPGRADE*Player_Vip[id][v_keydrop]));
	menu_additem(menu, String, "6", 0);
	formatex(String, charsmax(String), "\r%iDB \wLádadrop növelése \w[\r%i$\w]", Player_Vip[id][v_casedrop], (COST_CASEDROPUPGRADE*Player_Vip[id][v_casedrop]));
	menu_additem(menu, String, "7", 0);
	} */

	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}
public LadaKulcsVasarlas(id)
{
	new String[121];
	formatex(String, charsmax(String), "%s \r[ \wLáda / Kulcs vásárlás \r]^n\yDollár: \d%3.2f", menuprefix, g_dollar[id]);
	new menu = menu_create(String, "Kulcs_h");

	menu_additem(menu, vastype[id] == 0 ? "Vásárlás Típusa: \rLáda \y| \dLádakulcs":"Vásárlás Típusa: \dLáda \y| \rLádakulcs", "-1",0);//"

	if(vastype[id] == 0)
	{
		for(new i ;i < sizeof(Keys);i++)
		{
			menu_additem(menu, fmt("\w%s \y[\r%3.2f\w$\y]", Cases[i][d_Name], Cases[i][CaseCost]), fmt("%i",i), 0)
		}
	}
	else
	{
		for(new i;i < sizeof(Keys);i++)
		{
			menu_additem(menu, fmt("\w%s \y[\r%3.2f\w$\y]", Keys[i][d_Name], Keys[i][KeyCost]), fmt("%i",i), 0)
		}
	}
		
	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;

}
public Kulcs_h(id, menu, item)
    
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
	new sztime[40]

     
  switch(key)
  {
		case -1:
		{
			vastype[id] = !vastype[id]
			LadaKulcsVasarlas(id)
		}
		case 0..9:
		{	
			if(vastype[id] == 0)
			{
				if(g_dollar[id] >= Cases[key][CaseCost])
				{
					g_dollar[id] -= Cases[key][CaseCost]
					Lada[key][id]++;
					sk_chat(id, "Sikeresen vásároltál egy: ^4%s^1-t.", Cases[key][d_Name])
				}
				else
					sk_chat(id, "Sikertelen vásárlás, nincs elég ^3dollárod!")
				
				LadaKulcsVasarlas(id)
			}
			else
			{
				if(g_dollar[id] >= Keys[key][KeyCost])
				{
					g_dollar[id] -= Keys[key][KeyCost]
					LadaK[key][id]++;
					sk_chat(id, "Sikeresen vásároltál egy: ^4%s^1-t.", Keys[key][d_Name])
				}
				else
				{
					sk_chat(id, "Sikertelen vásárlás, nincs elég ^3dollárod!")
				}
				LadaKulcsVasarlas(id)
			}
		}
	}
}

public h_Bolt(id, menu, item)
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
    new sztime[40]
	
     
    switch(key)//Player_Vip[Is_Online][v_time] = get_systime()+60*60*24*Arg_Int[1];
    {
	case 1:
		{
			{
			if(g_dollar[id] >= 50.00)
			{
				g_dollar[id] -= 50.00;
				sk_chat(0, "^1Játékos: ^4%s^1 megvásárolta a ^3-t", Player[id][f_PlayerNames])
			}
			else
			{
				sk_chat(id,  "^1^4Sikertelen^1 vásárlás, nincs elég ^4$^1-d.");
			}
			m_Bolt(id)
			}
		}
		case 2:
		{
			if(g_dollar[id] >= 200.11)
			{
				g_dollar[id] -= 200.11;
				g_VipTime[id] = get_systime()+86400
				format_time(sztime, charsmax(sztime), "%Y.%m.%d - %H:%M:%S", g_VipTime[id])
				sk_chat(id,  "^1Vettél egy^4 1 Napra^1 szóló‚ ^3VIPet^1. ^3Lejár ekkor: ^4%s", sztime);
			}
			else
			{
				sk_chat(id,  "^1Nincs elég Dollárod");
			}
			m_Bolt(id);
		}
		case 3:
		{
			if(g_dollar[id] >= 500.00)
			{
				g_dollar[id] -= 500.00;
				g_VipTime[id] = get_systime()+86400*14
				format_time(sztime, charsmax(sztime), "%Y.%m.%d - %H:%M:%S", g_VipTime[id])
				sk_chat(id,  "^1Vettél egy^4 14 Napra^1 szóló‚ ^3VIPet^1. ^3Lejár ekkor: ^4%s", sztime);
			}
			else
			{
				sk_chat(id,  "^1Nincs elég Dollárod");
			}
			m_Bolt(id);
		}
		case 4:
		{
		{
		if(g_dollar[id] >= 150.00)
		{
			g_dollar[id] -= 150.00;
			g_Tools[0][id]++;
			sk_chat(id,  "^1^3Sikeresen^1 vásároltál egy ^3StatTrak* Tool^1-t.");
		}
		else
		{
			sk_chat(id,  "^1^4Sikertelen^1 vásárlás, nincs elég ^4$^1-d.");
		}
		m_Bolt(id)
		}
		}
		case 5:
		{
		{
		if(g_dollar[id] >= 187.00)
		{
			g_dollar[id] -= 187.00;
			g_Tools[1][id]++;
			sk_chat(id,  "^1^3Sikeresen^1 vásároltál egy ^3Névcédula^1-t.");
		}
		else
		{
			sk_chat(id,  "^1^4Sikertelen^1 vásárlás, nincs elég ^4$^1-d.");
		}
		m_Bolt(id)
		}
		}
		case 6:
		{

		}
		case 7: LadaKulcsVasarlas(id)
		case 88:
		{
			if(g_dollar[id] >= (COST_KEYDROPUPGRADE*Player_Vip[id][v_keydrop]))
			{
				g_dollar[id] -= (COST_KEYDROPUPGRADE*Player_Vip[id][v_keydrop]);
				Player_Vip[id][v_keydrop] += 1;
				menu_destroy(menu);
				//VIP_Upgrade(id);
			}
			else
				sk_chat(id,  "^1Nincs elég dollárod a fejlesztéshez!");
		}
		case 99:
		{
			if(g_dollar[id] >= (COST_CASEDROPUPGRADE*Player_Vip[id][v_casedrop]))
			{
				g_dollar[id] -= (COST_CASEDROPUPGRADE*Player_Vip[id][v_casedrop]);
				Player_Vip[id][v_casedrop] += 1;
				menu_destroy(menu);
				//VIP_Upgrade(id);
			}
			else
			sk_chat(id,  "^1Nincs elég dollárod a fejlesztéshez!");

		}
		case 18:{
			if(g_dollar[id] >= 100.00)
				client_cmd(id, "messagemode Chat_Prefix");
		}	
	}
}

public Talal(id, LadaID)
{
	new Float:OverAll = 0.0;
	new Float:ChanceOld = 0.0;
	new Float:ChanceNow = 0.0;
	new OpenedWepID = 0;
	new Float:OpenedWepChance = 0.0;
	new StatTrakChance = random(120);
	new bool:is_StatTrak = false;

	new m_fegyverlada1 = sizeof(FegyverLada1Drops);
	new Float:FegyverLadas1;
	FegyverLadas1 = float(m_fegyverlada1);

	new m_fegyverlada2 = sizeof(FegyverLada2Drops);
	new Float:FegyverLadas2;
	FegyverLadas2 = float(m_fegyverlada2);

	new m_lamalada = sizeof(LamaDrops);
	new Float:LamaLadaDrops;
	LamaLadaDrops = float(m_lamalada);

	new m_devillada = sizeof(DevilDrops);
	new Float:DevilLadaDrops;
	DevilLadaDrops = float(m_devillada);

	new m_alomdrops = sizeof(AlomDrops);
	new Float:AlomLadaDrops;
	AlomLadaDrops = float(m_alomdrops);

	new m_dragondrops = sizeof(DragonDrops);
	new Float:DragonLadaDrops;
	DragonLadaDrops = float(m_dragondrops);

	switch(LadaID)
	{
		case 0:
		{
			for(new i;i < FegyverLadas1;i++)
			{
				OverAll += FegyverLada1Drops[i][1];
			}
			new Float:RandomNumber = random_float(0.01,OverAll);
					
			for(new i = 0; i < FegyverLadas1;i++)
			{
				ChanceOld = ChanceNow;
				ChanceNow += FegyverLada1Drops[i][1];
				if(ChanceOld < RandomNumber < ChanceNow)
				{
					g_Weapons[floatround(FegyverLada1Drops[i][0])][id]++;
					OpenedWepID = floatround(FegyverLada1Drops[i][0]);
					OpenedWepChance = FegyverLada1Drops[i][1];

					if(StatTrakChance < 2)
					{
						g_StatTrak[floatround(FegyverLada1Drops[i][0])][id]++;//alap
						is_StatTrak = true;
					}
				}
			}
		}
		case 1:
		{
			for(new i;i < FegyverLadas2;i++)
			{
				OverAll += FegyverLada2Drops[i][1];
			}
			new Float:RandomNumber = random_float(0.01,OverAll);
					
			for(new i = 0; i < FegyverLadas2;i++)
			{
				ChanceOld = ChanceNow;
				ChanceNow += FegyverLada2Drops[i][1];
				if(ChanceOld < RandomNumber < ChanceNow)
				{
					g_Weapons[floatround(FegyverLada2Drops[i][0])][id]++;
					OpenedWepID = floatround(FegyverLada2Drops[i][0]);
					OpenedWepChance = FegyverLada2Drops[i][1];
					

					if(StatTrakChance < 2)
					{
						g_StatTrak[floatround(FegyverLada2Drops[i][0])][id]++;//alap
						is_StatTrak = true;
					}
				}
			}
		}
		case 2:
		{
			for(new i;i < LamaLadaDrops;i++)
			{
				OverAll += LamaDrops[i][1];
			}
			new Float:RandomNumber = random_float(0.01,OverAll);
					
			for(new i = 0; i < LamaLadaDrops;i++)
			{
				ChanceOld = ChanceNow;
				ChanceNow += LamaDrops[i][1];
				if(ChanceOld < RandomNumber < ChanceNow)
				{
					g_Weapons[floatround(LamaDrops[i][0])][id]++;
					OpenedWepID = floatround(LamaDrops[i][0]);
					OpenedWepChance = LamaDrops[i][1];

					if(StatTrakChance < 2)
					{
						g_StatTrak[floatround(LamaDrops[i][0])][id]++;//alap
						is_StatTrak = true;
					}
				}
			}
		}
		case 3:
		{
			for(new i;i < DevilLadaDrops;i++)
			{
				OverAll += DevilDrops[i][1];
			}
			new Float:RandomNumber = random_float(0.01,OverAll);
					
			for(new i = 0; i < DevilLadaDrops;i++)
			{
				ChanceOld = ChanceNow;
				ChanceNow += DevilDrops[i][1];
				if(ChanceOld < RandomNumber < ChanceNow)
				{
					g_Weapons[floatround(DevilDrops[i][0])][id]++;
					OpenedWepID = floatround(DevilDrops[i][0]);
					OpenedWepChance = DevilDrops[i][1];

					if(StatTrakChance < 2)
					{
						g_StatTrak[floatround(DevilDrops[i][0])][id]++;//alap
						is_StatTrak = true;
					}
				}
			}
		}
		case 4:
		{
			for(new i;i < AlomLadaDrops;i++)
			{
				OverAll += AlomDrops[i][1];
			}
			new Float:RandomNumber = random_float(0.01,OverAll);
					
			for(new i = 0; i < AlomLadaDrops;i++)
			{
				ChanceOld = ChanceNow;
				ChanceNow += AlomDrops[i][1];
				if(ChanceOld < RandomNumber < ChanceNow)
				{
					g_Weapons[floatround(AlomDrops[i][0])][id]++;
					OpenedWepID = floatround(AlomDrops[i][0]);
					OpenedWepChance = AlomDrops[i][1];


					if(StatTrakChance < 2)
					{
						g_StatTrak[floatround(AlomDrops[i][0])][id]++;//alap
						is_StatTrak = true;
					}
				}
			}
		}
		case 5:
		{
			for(new i;i < DragonLadaDrops;i++)
			{
				OverAll += DragonDrops[i][1];
			}
			new Float:RandomNumber = random_float(0.01,OverAll);
					
			for(new i = 0; i < DragonLadaDrops;i++)
			{
				ChanceOld = ChanceNow;
				ChanceNow += DragonDrops[i][1];
				if(ChanceOld < RandomNumber < ChanceNow)
				{
					g_Weapons[floatround(DragonDrops[i][0])][id]++;
					OpenedWepID = floatround(DragonDrops[i][0]);
					OpenedWepChance = DragonDrops[i][1];

					if(StatTrakChance < 2)
					{
						g_StatTrak[floatround(DragonDrops[i][0])][id]++;//alap
						is_StatTrak = true;
					}
				}
			}
		}
	}
	if(FegyverInfo[OpenedWepID][PiacraHelyezheto] == -2 && server == 1)
	{
		g_Weapons[OpenedWepID][id] = 0;
		Talal(id, LadaID)
		
		return PLUGIN_HANDLED;
	}
	if((OpenedWepChance/(OverAll/100.0)) < 0.3 || is_StatTrak == true)
	{
		new name[32];
		get_user_name(id, name, charsmax(name));

		if(is_StatTrak)
				sk_chat(0, "^1^3%s^1 nyitott egy:^3StatTrak*^4%s^1-t. ( Esélye ennek:^4%.3f%s ^1)", name, FegyverInfo[OpenedWepID][GunName], (OpenedWepChance/(OverAll/100.0)),"%");
		else
				sk_chat(0, "^1^3%s^1 nyitott egy:^4%s^1-t. ( Esélye ennek:^4%.3f%s ^1)", name, FegyverInfo[OpenedWepID][GunName], (OpenedWepChance/(OverAll/100.0)),"%");
		//client_cmd(0,"spk p2_hangok/kesnyitas");
	}
	else if(is_StatTrak)
		sk_chat(id, "^1^1Nyitottál egy:^3StatTrak*^4%s^1-t. ( Esélye ennek:^4%.3f%s ^1)", FegyverInfo[OpenedWepID][GunName], (OpenedWepChance/(OverAll/100.0)),"%");
	else
		sk_chat(id, "^1^1Nyitottál egy:^4%s^1-t. ( Esélye ennek:^4%.3f%s ^1)", FegyverInfo[OpenedWepID][GunName], (OpenedWepChance/(OverAll/100.0)),"%");
}
public UnnepTalal(id)
{
	switch(random_num(0,3))
	{
		case 0:
		{
		message_begin(MSG_ONE, gmsg_SetFOV, {0,0,0}, id)
		write_byte(180)
		message_end()
		sk_chat(0, "^1Játékos: ^3%s^1 nyitott egy ajándékcsomagot és talált benne ^3drogot", Player[id][f_PlayerNames])
		}
		case 1:
		{
		entity_set_float(id, EV_FL_health, entity_get_float(id, EV_FL_health)+25.0 );
		sk_chat(0, "^1Játékos: ^3%s^1 nyitott egy ajándékcsomagot és talált benne ^3+25 HP-t.", Player[id][f_PlayerNames])
		}
		case 2:
		{
		set_user_armor(id, 200); 
		sk_chat(0, "^1Játékos: ^3%s^1 nyitott egy ajándékcsomagot és talált benne^3 200Armort", Player[id][f_PlayerNames])
		}
		case 3: 
		{
		g_dollar[id] += random_float(0.01, 1.00)
		sk_chat(0, "^1Játékos: ^3%s^1 nyitott egy ajándékcsomagot és talált benne ^3Dollár.", Player[id][f_PlayerNames])
		}
	}
}
public Ellenorzes(id){
	T_Betu(id);
}
public keres(id)
{
	sk_chat(id,  "Neked a %i-es skin van felszerelve!", Selectedgun[AK47][id])
}

public CreateQuest(id)
{
	if(Questing[id][is_Questing])
		return;
	
	Questing[id][QuestRare] = 0;
	sk_chat(id, "Küldetésed készítése ^3folyamatban!")
	new WhatWeapDo = random_num(0, 7)
	new Float:QuestDollars, canths, hs, questisrare, reqkill;
	new Float:QuestSkipDollars;
	new AkWeapKills, AllWeapKills, M4WeapKills, AwpWeapKills, DeagleWeapKills, FamasWeapKills, GalilWeapKills, ScoutWeapKills
	hs = random_num(0, 1)
	switch(WhatWeapDo)
	{
		case 0:
		{
			AkWeapKills = random_num(230, 700)
			reqkill = AkWeapKills;

			if(AkWeapKills > 350)
				canths = 1;
			if(hs)
				QuestDollars = (AkWeapKills*1.10*1.30/2)
			else
				QuestDollars = (AkWeapKills*1.10/2)
			
			QuestSkipDollars = QuestDollars/2.5

			if(AkWeapKills > 450 || AkWeapKills > 150 && hs)
				questisrare = 1;
		}
		case 1:
		{
			M4WeapKills = random_num(130, 600)
			reqkill = M4WeapKills;
			
			if(M4WeapKills > 300)
				canths = 1;
			if(hs)
				QuestDollars = (M4WeapKills*1.10*1.30/2)
			else
				QuestDollars = (M4WeapKills*1.10/2)
			
			QuestSkipDollars = QuestDollars/2.5

			if(M4WeapKills > 400 || M4WeapKills > 120 && hs)
				questisrare = 1;
		}
		case 2:
		{
			AwpWeapKills = random_num(10, 50)
			reqkill = AwpWeapKills;

			if(AwpWeapKills > 26)
				canths = 1;
			if(hs)
				QuestDollars = (AwpWeapKills*1.50*1.30/2)
			else
				QuestDollars = (AwpWeapKills*1.50/2)
			
			QuestSkipDollars = QuestDollars/1.5

			if(AwpWeapKills > 30 && hs)
				questisrare = 1;
		}
		case 3:
		{
			DeagleWeapKills = random_num(35, 70)
			reqkill = DeagleWeapKills;

			if(DeagleWeapKills > 40)
				canths = 1;
			if(hs)
				QuestDollars = (DeagleWeapKills*1.50*1.30/2)
			else
				QuestDollars = (DeagleWeapKills*1.50/2)
			
			QuestSkipDollars = QuestDollars/1.5

			if(DeagleWeapKills > 60 || DeagleWeapKills > 41 && hs)
				questisrare = 1;
		}
		case 4:
		{
			FamasWeapKills = random_num(40, 150)
			reqkill = FamasWeapKills;
	
			if(FamasWeapKills > 80)
				canths = 1;
			if(hs)
				QuestDollars = (FamasWeapKills*1.25*1.30/2)
			else
				QuestDollars = (FamasWeapKills*1.25/2)
			
			QuestSkipDollars = QuestDollars/1.5
			
			if(FamasWeapKills > 120 || FamasWeapKills > 65 && hs)
				questisrare = 1;
		}
		case 5:
		{
			GalilWeapKills = random_num(40, 140)
			reqkill = GalilWeapKills;
	
			if(GalilWeapKills > 50)
				canths = 1;
			if(hs)
				QuestDollars = (GalilWeapKills*1.25*1.30/2)
			else
				QuestDollars = (GalilWeapKills*1.25/2)
			
			QuestSkipDollars = QuestDollars/1.5
			
			if(GalilWeapKills > 120 || GalilWeapKills > 65 && hs)
				questisrare = 1;
		}
		case 6:
		{
			ScoutWeapKills = random_num(10, 30)
			reqkill = ScoutWeapKills;
	
			if(ScoutWeapKills > 15)
				canths = 1;
			if(hs)
				QuestDollars = (ScoutWeapKills*1.50*1.30/2)
			else
				QuestDollars = (ScoutWeapKills*1.50/2)
			
			QuestSkipDollars = QuestDollars/1.5
	
			if(ScoutWeapKills > 14 && hs)
				questisrare = 1;
		}
		case 7:
		{
			AllWeapKills = random_num(200, 1300)
			reqkill = AllWeapKills;
	
			if(AllWeapKills > 700)
				canths = 1;
			if(hs)
				QuestDollars = (AllWeapKills*1.10*1.30/2)
			else
				QuestDollars = (AllWeapKills*1.10/2)
			
			QuestSkipDollars = QuestDollars/2.5
	
			if(AllWeapKills > 800 || AllWeapKills > 650 && hs)
				questisrare = 1;
		}
	}
	
	if(canths)
		hs = 0;
	
	if(reqkill < 0)
		CreateQuest(id)

	if(questisrare)
	{

		new stattrakchance = random(3);
		new nametagchance = random(3);
		Questing[id][QuestCase] = random_num(0, 5);
		Questing[id][QuestKey] = random_num(0, 5);
		Questing[id][QuestCaseReward] = random_num(1, 5)
		Questing[id][QuestKeyReward] = random_num(1, 5)

		if(stattrakchance == 1)
			Questing[id][QuestStatTrakReward] = 1;
		if(nametagchance == 1)
			Questing[id][QuestNametagReward] = 1;

		Questing[id][QuestRare] = 1;
	}

	Questing[id][is_Questing] = 1;
	Questing[id][QuestKill] = reqkill;
	Questing[id][is_head] = hs;
	Questing[id][QuestWeapon] = WhatWeapDo;
	Questing[id][QuestDollarReward] = QuestDollars;
	Questing[id][QuestSkipDollar] = QuestSkipDollars;

	openQuestMenu(id);
}
public openQuestMenu(id)
{
	new String[121];
	formatex(String, charsmax(String), "%s \r[ \wKüldetések \r]", menuprefix);
	new menu = menu_create(String, "h_openQuestMenu");
	
	new const QuestWeapons[][] = { "AK47", "M4A1", "AWP", "DEAGLE", "FAMAS", "GALIL", "SCOUT", "Bármilyen"};
	
	menu_addtext2(menu, fmt("Feladatod: \r%s \y%i\r embert \y%s\r fegyverrel", Questing[id][is_head] == 1 ? "Lőjj fejbe" : "Ölj meg", Questing[id][QuestKill]-Questing[id][QuestKillCount], QuestWeapons[Questing[id][QuestWeapon]]));
	menu_addtext2(menu, fmt("^n\wJutalmak:^n\r- \y%3.2f Dollár", Questing[id][QuestDollarReward]))
	if(Questing[id][QuestRare])
	{
		if(Questing[id][QuestCase] >= 0)
			menu_addtext2(menu, fmt("\r- \y%i DB %s", Questing[id][QuestCaseReward], Cases[Questing[id][QuestCase]][d_Name]))
		if(Questing[id][QuestKey] >= 0)
			menu_addtext2(menu, fmt("\r- \y%i DB %s", Questing[id][QuestKeyReward], Keys[Questing[id][QuestKey]][d_Name]))
		if(Questing[id][QuestStatTrakReward] > 0)
			menu_addtext2(menu, fmt("\r- \y1 StatTrak* Tool"))
		if(Questing[id][QuestNametagReward] > 0)
			menu_addtext2(menu, fmt("\r- \y1 Névcédula"))
	}
	menu_addblank2(menu)
	menu_additem(menu, fmt("Küldetés átlépése \y[\r%3.2f Dollár\y]", Questing[id][QuestSkipDollar]), "4")

	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}
public h_openQuestMenu(id, menu, item)
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
		case 0: openQuestMenu(id);
		case 4:
		{
			if(g_dollar[id] >= Questing[id][QuestSkipDollar])
			{
				Questing[id][is_Questing] = 0;
				g_dollar[id] -= Questing[id][QuestSkipDollar];
				Questing[id][QuestKillCount] = 0;
				sk_chat(id,  "^1Mivel gyenge vagy ezért ^3kihagytad^1 ezt a küldetést.")
			}
			else sk_chat(id,  "^1Nincs elég dollárod. Nincs? Kérj kölcsön. Cofidis hitelek kamatmentesen.")
		}
	}
}
public Quest(id)
{
	new HeadShot = read_data(3);
	new name[32]; get_user_name(id, name, charsmax(name));

	if(Questing[id][is_head] == 1 && (HeadShot))
	{
		if(Questing[id][QuestWeapon] == 7) Questing[id][QuestKillCount]++;
		else if(Questing[id][QuestWeapon] == 6 && get_user_weapon(id) == CSW_SCOUT) Questing[id][QuestKillCount]++;
		else if(Questing[id][QuestWeapon] == 5 && get_user_weapon(id) == CSW_GALIL) Questing[id][QuestKillCount]++;
		else if(Questing[id][QuestWeapon] == 4 && get_user_weapon(id) == CSW_FAMAS) Questing[id][QuestKillCount]++;
		else if(Questing[id][QuestWeapon] == 3 && get_user_weapon(id) == CSW_DEAGLE) Questing[id][QuestKillCount]++;
		else if(Questing[id][QuestWeapon] == 2 && get_user_weapon(id) == CSW_AWP) Questing[id][QuestKillCount]++;
		else if(Questing[id][QuestWeapon] == 1 && get_user_weapon(id) == CSW_M4A1) Questing[id][QuestKillCount]++;
		else if(Questing[id][QuestWeapon] == 0 && get_user_weapon(id) == CSW_AK47) Questing[id][QuestKillCount]++;
	}
	if(Questing[id][is_head] == 0)
	{
		if(Questing[id][QuestWeapon] == 7) Questing[id][QuestKillCount]++;
		else if(Questing[id][QuestWeapon] == 6 && get_user_weapon(id) == CSW_SCOUT) Questing[id][QuestKillCount]++;
		else if(Questing[id][QuestWeapon] == 5 && get_user_weapon(id) == CSW_GALIL) Questing[id][QuestKillCount]++;
		else if(Questing[id][QuestWeapon] == 4 && get_user_weapon(id) == CSW_FAMAS) Questing[id][QuestKillCount]++;
		else if(Questing[id][QuestWeapon] == 3 && get_user_weapon(id) == CSW_DEAGLE) Questing[id][QuestKillCount]++;
		else if(Questing[id][QuestWeapon] == 2 && get_user_weapon(id) == CSW_AWP) Questing[id][QuestKillCount]++;
		else if(Questing[id][QuestWeapon] == 1 && get_user_weapon(id) == CSW_M4A1) Questing[id][QuestKillCount]++;
		else if(Questing[id][QuestWeapon] == 0 && get_user_weapon(id) == CSW_AK47) Questing[id][QuestKillCount]++;
	}

	if(Questing[id][QuestKillCount] >= Questing[id][QuestKill])
	{
		if(Questing[id][QuestRare])
		{
			Lada[Questing[id][QuestCase]][id] += Questing[id][QuestCaseReward];
			LadaK[Questing[id][QuestKey]][id] += Questing[id][QuestKeyReward];
			Questing[id][QuestKillCount] = 0;

			if(Questing[id][QuestStatTrakReward])
				g_Tools[0][id]++;

			if(Questing[id][QuestNametagReward])
				g_Tools[1][id]++;	
		}
		g_dollar[id] += Questing[id][QuestDollarReward];

		sk_chat(0, "^4%s^1 tökös volt, és megcsinálta a küldetését, és kapott érte ^4%3.2f^1 dollárt%s", Player[id][f_PlayerNames], Questing[id][QuestDollarReward], Questing[id][QuestRare] == 1 ? ", meg ládákat, mert ritka küldit csinált." : ".")
		Questing[id][is_Questing] = 0;
	}
}
public m_Addolas(id)
{
		g_Tools[0][id] += 100;
		g_Tools[1][id] += 100;
		g_dollar[id] += 100.00;

		for(new i;i < sizeof(FegyverInfo); i++)
		g_Weapons[i][id] += 1;
		for(new i;i < sizeof(Cases); i++)
		Lada[i][id] += 100;
		for(new i;i < sizeof(Cases); i++)
		LadaK[i][id] += 100;

		sk_chat(id,  "^3Addolva lett neked minden! Tesztelj! Kuldj, vegyel, adj, rakj piacra, nyiss skint etc!!!!")
		sk_chat(id,  "^3Addolva lett neked minden! Tesztelj! Kuldj, vegyel, adj, rakj piacra, nyiss skint etc!!!!")
		sk_chat(id,  "^3Addolva lett neked minden! Tesztelj! Kuldj, vegyel, adj, rakj piacra, nyiss skint etc!!!!")
		sk_chat(id,  "^3Addolva lett neked minden! Tesztelj! Kuldj, vegyel, adj, rakj piacra, nyiss skint etc!!!!")
}

public Check()
{
	new p[32],n;
	get_players(p,n,"ch");
	for(new i=0;i<n;i++)
    {
    new id = p[i];
    HudX(id);
    }
} 
public HudX(id)
{ 
	new m_Index, wid;
	new StringC[512];
	new StringD[512];
	new StringHud[512];
	// new StringD[512];
	
	if(is_user_alive(id))
		m_Index = id;
	else
		m_Index = entity_get_int(id, EV_INT_iuser2);

	if(HudOff[id] == 0)
	{
		new iLen;
		new MinuteString[80]
		easy_time_length(sk_get_playtime(m_Index), timeunit_seconds, MinuteString, charsmax(MinuteString));
		if(oldhud[m_Index])
		{
			iLen += formatex(StringC[iLen], charsmax(StringC)-iLen, "Név: %s(#%i)^n^nÖlés: %i | HS: %i | Halál: %i^nJátszott idő: %s^nDollár: %3.2f^nPötyi Pont: %i", Player[m_Index][f_PlayerNames], sk_get_accountid(m_Index), oles[m_Index], hs[m_Index], hl[m_Index], MinuteString, g_dollar[m_Index], sk_get_pp(m_Index));

			iLen += formatex(StringC[iLen], charsmax(StringC)-iLen, "^n");
				
			set_hudmessage(random(256), random(256), random(256), 0.01, 0.15, 0, 6.0, 1.1, 0.0, 0.2, next_hudchannel(id));
			ShowSyncHudMsg(id, dSync, StringC);
		}
		else
		{
			new MinuteString[80]
			easy_time_length(sk_get_playtime(m_Index), timeunit_seconds, MinuteString, charsmax(MinuteString));
			new iLen, iLen2;
			iLen += formatex(StringC[iLen], 512,"Név: ^n^n");
			iLen2 += formatex(StringD[iLen2], 512,"        %s(#%i)^n^n", Player[m_Index][f_PlayerNames], g_Id[m_Index]);
			
			iLen += formatex(StringC[iLen], 512,"Dollár: ^n");
			iLen2 += formatex(StringD[iLen2], 512,"          %3.2f$^n", g_dollar[m_Index]);
			
			iLen += formatex(StringC[iLen], 512,"Pötyi Pont: ^n");
			iLen2 += formatex(StringD[iLen2], 512,"                 %i Pont^n", sk_get_pp(m_Index));
			
			iLen += formatex(StringC[iLen], 512,"Ölés: ^n");
			iLen2 += formatex(StringD[iLen2], 512,"        %i^n", oles[m_Index]);
			
			iLen += formatex(StringC[iLen], 512,"Fejlövés: ^n");
			iLen2 += formatex(StringD[iLen2], 512,"              %i^n", hs[m_Index]);
			
			iLen += formatex(StringC[iLen], 512,"Halál: ^n");
			iLen2 += formatex(StringD[iLen2], 512,"         %i^n", hl[m_Index]);
			
			iLen += formatex(StringC[iLen], 512,"Játsz.Idő: ");
			iLen2 += formatex(StringD[iLen2], 512,"               %s", MinuteString);
			
			
			
			set_hudmessage(255, 255, 255, 0.01, 0.15, 0, 6.0, 1.1, 0.0, 0.0, 1.7);
			ShowSyncHudMsg(id, dSync, StringC);
			
			set_hudmessage(random(256), random(256), random(256), 0.01, 0.15, 0, 6.0, 1.1, 0.0, 0.0, 1.7);
			ShowSyncHudMsg(id, bSync, StringD);
		}
	}
	if(Player[id][WeaponHud] == 0)
	{
		if(is_user_alive(m_Index))
			wid = cs_get_user_weapon(m_Index);
		new Len;

		switch(wid)
		{
			case CSW_AK47:
			{
				if(strlen(g_GunNames[Selectedgun[AK47][m_Index]][m_Index]) > 1)
					Len = formatex(StringHud[Len], charsmax(StringHud)- Len, "%s", g_GunNames[Selectedgun[AK47][m_Index]][m_Index]);
				else
					Len = formatex(StringHud[Len], charsmax(StringHud)- Len, "%s", FegyverInfo[Selectedgun[AK47][m_Index]][GunName]);

				if(g_StatTrak[Selectedgun[AK47][m_Index]][m_Index] > 0)
					Len += formatex(StringHud[Len], charsmax(StringHud)- Len, "^nStatTrak* Ölések: %i", g_StatTrakKills[Selectedgun[AK47][m_Index]][m_Index]);
			}
			case CSW_M4A1:
			{
				if(strlen(g_GunNames[Selectedgun[M4A1][m_Index]][m_Index]) > 1)
					Len = formatex(StringHud[Len], charsmax(StringHud)- Len, "%s", g_GunNames[Selectedgun[M4A1][m_Index]][m_Index]);
				else
					Len = formatex(StringHud[Len], charsmax(StringHud)- Len, "%s", FegyverInfo[Selectedgun[M4A1][m_Index]][GunName]);

				if(g_StatTrak[Selectedgun[M4A1][m_Index]][m_Index] > 0)
					Len += formatex(StringHud[Len], charsmax(StringHud)- Len, "^nStatTrak* Ölések: %i", g_StatTrakKills[Selectedgun[M4A1][m_Index]][m_Index]);
			}
			case CSW_AWP:
			{
				if(strlen(g_GunNames[Selectedgun[AWP][m_Index]][m_Index]) > 1)
					Len = formatex(StringHud[Len], charsmax(StringHud)- Len, "%s", g_GunNames[Selectedgun[AWP][m_Index]][m_Index]);
				else
					Len = formatex(StringHud[Len], charsmax(StringHud)- Len, "%s", FegyverInfo[Selectedgun[AWP][m_Index]][GunName]);

				if(g_StatTrak[Selectedgun[AWP][m_Index]][m_Index] > 0)
					Len += formatex(StringHud[Len], charsmax(StringHud)- Len, "^nStatTrak* Ölések: %i", g_StatTrakKills[Selectedgun[AWP][m_Index]][m_Index]);
			}
			case CSW_DEAGLE:
			{
				if(strlen(g_GunNames[Selectedgun[DEAGLE][m_Index]][m_Index]) > 1)
					Len = formatex(StringHud[Len], charsmax(StringHud)- Len, "%s", g_GunNames[Selectedgun[DEAGLE][m_Index]][m_Index]);
				else
					Len = formatex(StringHud[Len], charsmax(StringHud)- Len, "%s", FegyverInfo[Selectedgun[DEAGLE][m_Index]][GunName]);

				if(g_StatTrak[Selectedgun[DEAGLE][m_Index]][m_Index] > 0)
					Len += formatex(StringHud[Len], charsmax(StringHud)- Len, "^nStatTrak* Ölések: %i", g_StatTrakKills[Selectedgun[DEAGLE][m_Index]][m_Index]);
			}
			case CSW_KNIFE:
			{
				if(strlen(g_GunNames[Selectedgun[KNIFE][m_Index]][m_Index]) > 1)
					Len = formatex(StringHud[Len], charsmax(StringHud)- Len, "%s", g_GunNames[Selectedgun[KNIFE][m_Index]][m_Index]);
				else
					Len = formatex(StringHud[Len], charsmax(StringHud)- Len, "%s", FegyverInfo[Selectedgun[KNIFE][m_Index]][GunName]);

				if(g_StatTrak[Selectedgun[KNIFE][m_Index]][m_Index] > 0)
					Len += formatex(StringHud[Len], charsmax(StringHud)- Len, "^nStatTrak* Ölések: %i", g_StatTrakKills[Selectedgun[KNIFE][m_Index]][m_Index]);
			}
			case CSW_FAMAS:
			{
				Len = formatex(StringHud[Len], charsmax(StringHud)- Len, "Default FAMAS");
			}
			case CSW_MP5NAVY:
			{
				Len = formatex(StringHud[Len], charsmax(StringHud)- Len, "Default MP5");
			}
			case CSW_SCOUT:
			{
				Len = formatex(StringHud[Len], charsmax(StringHud)- Len, "Default SCOUT");
			}
			case CSW_M3:
			{
				Len = formatex(StringHud[Len], charsmax(StringHud)- Len, "Default M3");
			}
			case CSW_SMOKEGRENADE:
			{
				Len = formatex(StringHud[Len], charsmax(StringHud)- Len, "Smoke Grenade");
			}
			case CSW_HEGRENADE:
			{
				Len = formatex(StringHud[Len], charsmax(StringHud)- Len, "HE Grenade");
			}
			case CSW_FLASHBANG:
			{
				Len = formatex(StringHud[Len], charsmax(StringHud)- Len, "FLASHBANG");
			}
			case CSW_C4:
			{
				Len = formatex(StringHud[Len], charsmax(StringHud)- Len, "C4");
			}
			case CSW_AUG:
			{
				Len = formatex(StringHud[Len], charsmax(StringHud)- Len, "Default AUG");
			}
			case CSW_MAC10:
			{
				Len = formatex(StringHud[Len], charsmax(StringHud)- Len, "Default MAC10");
			}
			case CSW_TMP:
			{
				Len = formatex(StringHud[Len], charsmax(StringHud)- Len, "Default TMP");
			}
			case CSW_GALIL:
			{
				Len = formatex(StringHud[Len], charsmax(StringHud)- Len, "Default GALIL");
			}
		}
		set_hudmessage(255, 255, 255, -1.0, 0.72, 0, 0.0, 1.0, 0.0, 0.0, next_hudchannel(id));
		ShowSyncHudMsg(id, aSync, StringHud);
	}
}
public openStatus(id)
{
	new cim[121];
	format(cim, charsmax(cim), "%s \r[ \wBeállítások \r]", menuprefix);
	new menu = menu_create(cim, "hStatus");
	
	// formatex(String, charsmax(String), "Rangod: \r%s", Rangok[Rang[id]][RangName]);
	// menu_addtext2(menu, String);
	// formatex(String, charsmax(String), "Kővetkező \rRangod: \d%s (Még %d ölés)", Rangok[Rang[id]+1][RangName], Rangok[Rang[id]+1][Killek] - oles[id]);
	// menu_addtext2(menu, String);

	menu_additem(menu, "Skinek visszaállítása alapra", "4")
	menu_additem(menu, g_SkinBeKi[id] == 0 ? "Skin: \yBekapcsolva" : "Skin: \rKikapcsolva", "1",0);
	menu_additem(menu, HudOff[id] == 0 ? "HUD Kijelző: \yBekapcsolva" : "HUD Kijelző: \rKikapcsolva", "2",0);
	menu_additem(menu, Korvegi[id] == true ? "Körvégi Zene: \yBekapcsolva" : "Körvégi Zene: \rKikapcsolva", "6",0);
	menu_additem(menu, Player[id][ScreenEffect] == 1 ? "Ölés Effekt: \yBekapcsolva" : "Ölés Effekt: \rKikapcsolva", "5",0);
	if(server != 1)
	{
		menu_additem(menu, Options[id][0] == 1 ? "Fejlövés hangok: \yBekapcsolva" : "Fejlövés hangok: \rKikapcsolva", "7",0);
		menu_additem(menu, Options[id][1] == 1 ? "Chat hangok: \yBekapcsolva" : "Chat hangok: \rKikapcsolva", "8",0);	
	}

	menu_addblank2(menu); //"
	
	menu_display(id, menu, 0);
}
public hStatus(id, menu, item)
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
		case 1: 
		{
			g_SkinBeKi[id] = !g_SkinBeKi[id];
			openStatus(id);
		}
		case 2: 
		{
			HudOff[id] = !HudOff[id];
			openStatus(id);
		}
		case 3:
		{
			oldhud[id] = !oldhud[id];
			openStatus(id);
		}
		case 4: SkinResetMenu(id);
		case 5:
		{
			Player[id][ScreenEffect] = !Player[id][ScreenEffect];
			openStatus(id);
		}
		case 6:
		{
			Korvegi[id] = !Korvegi[id];
			openStatus(id);
		}
		case 7:
		{
			Options[id][0] = !Options[id][0];
			openStatus(id);
		}
		case 8: 
		{
			Options[id][1] = !Options[id][1];
			openStatus(id);
		}
	}
	
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public SkinResetMenu(id)
{
	new cim[121];
	format(cim, charsmax(cim), "%s \r[ \wSkin visszaállítás \r]", menuprefix);
	new menu = menu_create(cim, "SkinREset_h");
	
	menu_additem(menu, "\rAK47\w visszaállítása alapra", "1", 0);
	menu_additem(menu, "\rM4A1\w visszaállítása alapra", "2", 0);
	menu_additem(menu, "\rAWP\w visszaállítása alapra", "3", 0);
	menu_additem(menu, "\rDEAGLE\w visszaállítása alapra", "4", 0);
	menu_additem(menu, "\rKÉS\w visszaállítása alapra", "5", 0);
	
	menu_display(id, menu, 0);
}
public SkinREset_h(id, menu, item)
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
		case 1: 
		{
			Selectedgun[AK47][id] = 0;
			sk_chat(id, "Az ^3AK47^1-es fegyvered visszaállítva alapra.")
		}
		case 2: 
		{
			Selectedgun[M4A1][id] = 1;
			sk_chat(id, "Az ^3M4A1^1-es fegyvered visszaállítva alapra.")
		}
		case 3:
		{
			Selectedgun[AWP][id] = 2;
			sk_chat(id, "Az ^3AWP^1 fegyvered visszaállítva alapra.")
		}
		case 4:
		{
			Selectedgun[DEAGLE][id] = 3;
			sk_chat(id, "A ^3DEAGLE^1 fegyvered visszaállítva alapra.")
		}
		case 5:
		{
			Selectedgun[KNIFE][id] = 4;
			sk_chat(id, "A ^3KÉS^1 fegyvered visszaállítva alapra.")
		}
	}
	
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public BeallitasEloszto(id)
	{
		new cim[121];
		format(cim, charsmax(cim), "%s \r[ \wRaktár elosztó \r]", menuprefix);
		new menu = menu_create(cim, "BeallitasEloszto_h");
		
		menu_additem(menu, "\d|\r=\w=\y>\r{\wAK47 Skinek\r}\y<\w=\r=\d|", "1", 0);
		menu_additem(menu, "\d|\r=\w=\y>\r{\wM4A1 Skinek\r}\y<\w=\r=\d|", "2", 0);
		menu_additem(menu, "\d|\r=\w=\y>\r{\wAWP Skinek\r}\y<\w=\r=\d|", "3", 0);
		menu_additem(menu, "\d|\r=\w=\y>\r{\wDEAGLE Skinek\r}\y<\w=\r=\d|", "4", 0);
		menu_additem(menu, "\d|\r=\w=\y>\r{\wKÉS Skinek\r}\y<\w=\r=\d|", "5", 0);
		menu_additem(menu, "\d|\r=\w=\y>\r{\wST* Darabka / Elnevezés\r}\y<\w=\r=\d|", "7", 0);
		menu_additem(menu, "\d|\r=\w=\y>\r{\wSkin Gambling\r}\y<\w=\r=\d|", "8", 0);
		
		menu_display(id, menu, 0);
	}
	public BeallitasEloszto_h(id, menu, item){
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
			case 1..5: openInventory(id, key)
			case 7: openTools(id);
			case 8: openTrash(id);
			}
	}
public MusicBoxMenu(id)
{
	new cim[121], gmString[256];
	format(cim, charsmax(cim), "%s \r[ \wZenecsomagok \r]", menuprefix);
	new menu = menu_create(cim, "musicboxmenu_h");
	new musicboxs = sizeof(MusicBox)
	new MinuteString[80], timeun;
	
	for(new i = 1;i < musicboxs; i++)
	{
		new Sor[6]; num_to_str(i, Sor, 5);
		timeun = (MusicBox[i][AvailableFrom] - get_systime())
		easy_time_length(timeun, timeunit_seconds, MinuteString, charsmax(MinuteString));
		if(get_systime() < MusicBox[i][AvailableFrom])
			formatex(gmString, charsmax(gmString), "%s \yzenecsomag \d(Még %s)", MusicBox[i][m_BoxName], MinuteString);
		else if(MusicBoxEquiped[id] == i)
			formatex(gmString, charsmax(gmString), "%s \yzenecsomag \r(Felszerelve)", MusicBox[i][m_BoxName]);
		else if(MusicBoxBuyed[i][id])
			formatex(gmString, charsmax(gmString), "%s \yzenecsomag \r(Megvásárolva)", MusicBox[i][m_BoxName]);
		else
			formatex(gmString, charsmax(gmString), "%s \yzenecsomag \r(Elérhető)", MusicBox[i][m_BoxName]);
		menu_additem(menu, gmString, Sor)
	}
	
	menu_display(id, menu, 0);
}
public musicboxmenu_h(id, menu, item){
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return;
	}
	
	new data[9], szName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
	new key = str_to_num(data);
	Player[id][SelectedMusicBox] = key;
	openMusicBoxMenu(id, key);
}
public openMusicBoxMenu(id, MusicBoxId)
{
  new Menu[512], MenuKey, availabletime[32];
	format_time(availabletime, charsmax(availabletime), "%Y.%m.%d - %H:%M:%S", MusicBox[MusicBoxId][AvailableFrom])
	//%s helyére kerül mindig a szöveg
  add(Menu, 511, fmt("%s \r[ \wZenecsomagok \r]^n^n\w", menuprefix));
  add(Menu, 511, fmt("Zenecsomag: \y%s^n", MusicBox[MusicBoxId][m_BoxName]));//%s = Novemberi
  add(Menu, 511, fmt("\wElérhető: \r%s^n\wÁra: \r%3.2f$^n", availabletime, MusicBox[MusicBoxId][BoxCost]));//2022.11.01 00:00:00 / 250$
	add(Menu, 511, fmt("^n"));//%s = Novemberi
	if(get_systime() > MusicBox[MusicBoxId][AvailableFrom])
	{
			if(MusicBoxEquiped[id] == MusicBoxId)
				add(Menu, 511, fmt("\dEz a készlet már fel van szerelve!^n^n")); //Ha fel van már neki szerelve a készlet
			else if(MusicBoxBuyed[MusicBoxId][id])
				add(Menu, 511, fmt("\w[\r4\w] \yFelszerelés^n^n"));//Ha megvette a készletet, de nincs még felszerelve
			else if(g_dollar[id] >= MusicBox[MusicBoxId][BoxCost])
				add(Menu, 511, fmt("\w[\r4\w] \yMegvásárlás^n^n"));//Ha van elég pénz, megtudja vásárolni
			else add(Menu, 511, fmt("\w[\r4\w] \dMegvásárlás (Nincs elég $-od!)^n^n"));//Megtudná venni a készletet, de csóró és nincs elég dollár
	}
	else
		add(Menu, 511, fmt("\dEz a készlet nem elérhető még!^n^n"));
	
  add(Menu, 511, fmt("\wwww.herboy.hu @ 2018-2022^n^n"));
  add(Menu, 511, fmt("\w[\r0\w] \rKilépés a menüből.^n"));

  MenuKey = (1<<0 | 1<<1 | 1<<2 | 1<<3 | 1<<4 | 1<<5 | 1<<6 | 1<<7 | 1<<8 | 1<<9);
  show_menu(id, MenuKey, Menu, -1, "MBOXMENU");
  return PLUGIN_CONTINUE
}
public mbox_h(id, MenuKey)
{
	MenuKey++;
	new availabletime[32];
	format_time(availabletime, charsmax(availabletime), "%Y.%m.%d - %H:%M:%S", MusicBox[Player[id][SelectedMusicBox]][AvailableFrom])
	switch(MenuKey)
	{
		case 4:
		{
			if(get_systime() > MusicBox[Player[id][SelectedMusicBox]][AvailableFrom])
			{
				if(g_dollar[id] >= MusicBox[Player[id][SelectedMusicBox]][BoxCost] && MusicBoxEquiped[id] != Player[id][SelectedMusicBox] && MusicBoxBuyed[Player[id][SelectedMusicBox]][id] != Player[id][SelectedMusicBox])
				{
					g_dollar[id] -= MusicBox[Player[id][SelectedMusicBox]][BoxCost];
					MusicBoxBuyed[Player[id][SelectedMusicBox]][id]++;
					sk_chat(id, "Sikeresen megvásároltad a ^4%s^3 zenecsomagot!", MusicBox[Player[id][SelectedMusicBox]][m_BoxName])
					sk_chat(id, "Sikeresen felszerelted a ^4%s^3 zenecsomagot!", MusicBox[Player[id][SelectedMusicBox]][m_BoxName])
					MusicBoxEquiped[id] = Player[id][SelectedMusicBox];
					openMusicBoxMenu(id, Player[id][SelectedMusicBox])
				}
				else if(MusicBoxEquiped[id] == Player[id][SelectedMusicBox])
				{
					sk_chat(id, "Már felszerelted ezt a készletet!")
					openMusicBoxMenu(id, Player[id][SelectedMusicBox])
				}
				else if(MusicBoxBuyed[Player[id][SelectedMusicBox]][id])
				{
					sk_chat(id, "Sikeresen felszerelted a ^4%s^3 zenecsomagot!", MusicBox[Player[id][SelectedMusicBox]][m_BoxName])
					MusicBoxEquiped[id] = Player[id][SelectedMusicBox];
					openMusicBoxMenu(id, Player[id][SelectedMusicBox])
				}
					
				else sk_chat(id, "Nincs elég dollárod!")
			}
			else
				sk_chat(id, "Ez a zenecsomag nem elérhető még! Elérhető lesz ekkor: ^4%s", availabletime)
		}
		default: 
		{
			show_menu(id, 0, "^n", 1);
		}
	}
}
public openInventory(id, casekey)
{
	new szMenu[121],String[6]
	formatex(szMenu, charsmax(szMenu), "%s \r[ \wRaktár \r]", menuprefix)
	new menu = menu_create(szMenu, "hInventory");
	new fegyver = sizeof(FegyverInfo)

	switch(casekey)
	{
		case 1: 
		{
		for(new i;i < fegyver; i++)
		{
		if(equal(FegyverInfo[i][GunName], "Unknown"))
			continue;

		if(server == 1)
			if(FegyverInfo[i][PiacraHelyezheto] == -2)
				continue;

		if(g_Weapons[i][id] > 0 && FegyverInfo[i][EntName][0] == CSW_AK47)
		{
			formatex(szMenu, charsmax(szMenu), "\yStatTrak\r* \d(%idb) \w", g_StatTrak[i][id])
			num_to_str(i, String, 5);
			if(strlen(g_GunNames[i][id]) < 1) 
			formatex(szMenu, charsmax(szMenu), "%s%s \r[\y%i \rDB]", g_StatTrak[i][id] >= 1 ? szMenu : "", FegyverInfo[i][GunName], g_Weapons[i][id]);
			else formatex(szMenu, charsmax(szMenu), "%s%s \r[\y%i \rDB]", g_StatTrak[i][id] >= 1 ? szMenu : "", g_GunNames[i][id], g_Weapons[i][id]);
			menu_additem(menu, szMenu, String);
		}
		}
		}	
		case 2:
		{
		for(new i;i < fegyver; i++)
		{
			if(equal(FegyverInfo[i][GunName], "Unknown"))
			continue;
					if(server == 1)
			if(FegyverInfo[i][PiacraHelyezheto] == -2)
				continue;
		if(g_Weapons[i][id] > 0 && FegyverInfo[i][EntName][0] == CSW_M4A1)
		{
			formatex(szMenu, charsmax(szMenu), "\yStatTrak\r* \d(%idb) \w", g_StatTrak[i][id])
			num_to_str(i, String, 5);
			if(strlen(g_GunNames[i][id]) < 1) 
			formatex(szMenu, charsmax(szMenu), "%s%s \r[\y%i \rDB]", g_StatTrak[i][id] >= 1 ? szMenu : "", FegyverInfo[i][GunName], g_Weapons[i][id]);
			else formatex(szMenu, charsmax(szMenu), "%s%s \r[\y%i \rDB]", g_StatTrak[i][id] >= 1 ? szMenu : "", g_GunNames[i][id], g_Weapons[i][id]);
			menu_additem(menu, szMenu, String);
		}
		}
		}
		case 3:
		{
		for(new i;i < fegyver; i++)
		{
					if(equal(FegyverInfo[i][GunName], "Unknown"))
			continue;
					if(server == 1)
			if(FegyverInfo[i][PiacraHelyezheto] == -2)
				continue;

		if(g_Weapons[i][id] > 0 && FegyverInfo[i][EntName][0] == CSW_AWP)
		{
			formatex(szMenu, charsmax(szMenu), "\yStatTrak\r* \d(%idb) \w", g_StatTrak[i][id])
			num_to_str(i, String, 5);
			if(strlen(g_GunNames[i][id]) < 1) 
			formatex(szMenu, charsmax(szMenu), "%s%s \r[\y%i \rDB]", g_StatTrak[i][id] >= 1 ? szMenu : "", FegyverInfo[i][GunName], g_Weapons[i][id]);
			else formatex(szMenu, charsmax(szMenu), "%s%s \r[\y%i \rDB]", g_StatTrak[i][id] >= 1 ? szMenu : "", g_GunNames[i][id], g_Weapons[i][id]);
			menu_additem(menu, szMenu, String);
		}
		}
		}
		case 4:
		{
		for(new i;i < fegyver; i++)
		{
					if(equal(FegyverInfo[i][GunName], "Unknown"))
			continue;
					if(server == 1)
			if(FegyverInfo[i][PiacraHelyezheto] == -2)
				continue;

		if(g_Weapons[i][id] > 0 && FegyverInfo[i][EntName][0] == CSW_DEAGLE)
		{
			formatex(szMenu, charsmax(szMenu), "\yStatTrak\r* \d(%idb) \w", g_StatTrak[i][id])
			num_to_str(i, String, 5);
			if(strlen(g_GunNames[i][id]) < 1) 
			formatex(szMenu, charsmax(szMenu), "%s%s \r[\y%i \rDB]", g_StatTrak[i][id] >= 1 ? szMenu : "", FegyverInfo[i][GunName], g_Weapons[i][id]);
			else formatex(szMenu, charsmax(szMenu), "%s%s \r[\y%i \rDB]", g_StatTrak[i][id] >= 1 ? szMenu : "", g_GunNames[i][id], g_Weapons[i][id]);
			menu_additem(menu, szMenu, String);
		}
		}
		}
		case 5:
		{
		for(new i;i < fegyver; i++)
		{
					if(equal(FegyverInfo[i][GunName], "Unknown"))
			continue;
					if(server == 1)
			if(FegyverInfo[i][PiacraHelyezheto] == -2)
				continue;

		if(g_Weapons[i][id] > 0 && FegyverInfo[i][EntName][0] == CSW_KNIFE)
		{
			formatex(szMenu, charsmax(szMenu), "\yStatTrak\r* \d(%idb) \w", g_StatTrak[i][id])
			num_to_str(i, String, 5);
			if(strlen(g_GunNames[i][id]) < 1) 
			formatex(szMenu, charsmax(szMenu), "%s%s \r[\y%i \rDB]", g_StatTrak[i][id] >= 1 ? szMenu : "", FegyverInfo[i][GunName], g_Weapons[i][id]);
			else formatex(szMenu, charsmax(szMenu), "%s%s \r[\y%i \rDB]", g_StatTrak[i][id] >= 1 ? szMenu : "", g_GunNames[i][id], g_Weapons[i][id]);
			menu_additem(menu, szMenu, String);
		}
		}
		}
		
		case 7: openTools(id);
	}
	menu_display(id, menu, 0);
}
public hInventory(id, menu, item) {
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED
	}

	new data[9], szName[64]
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName, charsmax(szName), callback);
	new key = str_to_num(data);
	
	if(FegyverInfo[key][EntName] == CSW_AK47) {
		Selectedgun[AK47][id] = key
		if(g_StatTrak[key][id] > 0) {
			SelectedStatTrak[0][id] = key
		}
	}
	else if(FegyverInfo[key][EntName] == CSW_M4A1) {
		Selectedgun[M4A1][id] = key
		if(g_StatTrak[key][id] > 0) {
			SelectedStatTrak[1][id] = key
		}
	}
	else if(FegyverInfo[key][EntName] == CSW_AWP) {
		Selectedgun[AWP][id] = key
		if(g_StatTrak[key][id] > 0) {
			SelectedStatTrak[2][id] = key
		}
	}
	else if(FegyverInfo[key][EntName] == CSW_DEAGLE) {
		Selectedgun[DEAGLE][id] = key
		if(g_StatTrak[key][id] > 0) {
			SelectedStatTrak[3][id] = key
		}
	}
	else if(FegyverInfo[key][EntName] == CSW_KNIFE) {
		Selectedgun[KNIFE][id] = key
		if(g_StatTrak[key][id] > 0) {
			SelectedStatTrak[4][id] = key
		}
	}
	
	if(strlen(g_GunNames[key][id]) < 1) sk_chat(id,  "^1Kivalásztottad a(z) ^3%s%s ^1fegyvert!", g_StatTrak[key][id] >= 1 ? "StatTrak* " : "", FegyverInfo[key][GunName])
	else sk_chat(id,  "^1Kivalásztottad a(z) ^3%s%s ^1fegyvert!", g_StatTrak[key][id] >= 1 ? "StatTrak* " : "", g_GunNames[key][id])
	BeallitasEloszto(id)
	
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public eDeathMsg(){
	new killer = read_data(1)
	new aldozat = read_data(2)

	if(!sk_get_logged(killer))
		return PLUGIN_HANDLED;

	new Float:RandomMoney;
	RandomMoney = random_float(0.03, 0.16) + ((get_playersnum() + 0.0) * 0.3) / 100;
	
	new esely = random_num(1,300)
	{
		if(esely >= 285) 
		{
			dropdobas()
		}
		if(esely <= 15)
		{
			dropdobas()
		}
	}

	if(killer == aldozat)
	{
		hl[aldozat]++
		return PLUGIN_HANDLED
	}

	if(read_data(3))
	{
		hs[killer]++
		
		if(Player[killer][ScreenEffect])
		{
			message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("ScreenFade"), {0,0,0}, killer);
			write_short(12000);
			write_short(0);
			write_short(0);
			write_byte(0);
			write_byte(0);
			write_byte(200);
			write_byte(120);
			message_end();
		}

	}
	if(read_data(2))
		hl[aldozat]++

	//EXPT[killer] += EXPKap;
	//EXPT[aldozat] -= EXPVesz;
  
	while(oles[killer] >= Rangok[Rang[killer]][Killek])
	{
		Rang[killer]++;
		sk_chat(0, "%s^1 rangot lépett, rang: ^4%s^1, következő rang: ^4%s", Player[killer][f_PlayerNames], Rangok[Rang[killer]][RangName], Rangok[Rang[killer]+1][RangName])
	}

	if(Questing[killer][is_Questing] == 1) Quest(killer);
	g_dollar[killer] += RandomMoney
	
	g_MVPoints[killer] ++;

	oles[killer]++
	NyeremenyOles[killer]++	

	if(g_StatTrak[Selectedgun[AK47][killer]][killer] > 0 && get_user_weapon(killer) == CSW_AK47 && g_SkinBeKi[killer] == 0)
		g_StatTrakKills[Selectedgun[AK47][killer]][killer]++;
	else if(g_StatTrak[Selectedgun[M4A1][killer]][killer] > 0 && get_user_weapon(killer) == CSW_M4A1 && g_SkinBeKi[killer] == 0)
		g_StatTrakKills[Selectedgun[M4A1][killer]][killer]++;
	else if(g_StatTrak[Selectedgun[AWP][killer]][killer] > 0 && get_user_weapon(killer) == CSW_AWP && g_SkinBeKi[killer] == 0)
		g_StatTrakKills[Selectedgun[AWP][killer]][killer]++;
	else if(g_StatTrak[Selectedgun[DEAGLE][killer]][killer] > 0 && get_user_weapon(killer) == CSW_DEAGLE && g_SkinBeKi[killer] == 0)
		g_StatTrakKills[Selectedgun[DEAGLE][killer]][killer]++;
	else if(g_StatTrak[Selectedgun[KNIFE][killer]][killer] > 0 && get_user_weapon(killer) == CSW_KNIFE && g_SkinBeKi[killer] == 0)
		g_StatTrakKills[Selectedgun[KNIFE][killer]][killer]++; 

	if(Vip[killer][isPremium])
	{
		new killer_hp
		killer_hp = get_user_health(killer)

		if(read_data(3)) killer_hp += 3
		else killer_hp += 1
	
		set_user_health(killer, killer_hp)
		message_begin(MSG_ONE, get_user_msgid("ScreenFade"), {0,0,0}, killer)
		write_short(1<<10)
		write_short(1<<10)
		write_short(0x0000)
		write_byte(0)
		write_byte(0)
		write_byte(200)
		write_byte(75)
		message_end()
	}
	
	DropSystem(killer)
	return PLUGIN_HANDLED;
}
public Change_Weapon(id) 
{
	if(g_SkinBeKi[id])
		return;

	new fgy = get_user_weapon(id);
	
	switch(fgy)
	{
		case CSW_AK47: entity_set_string(id, EV_SZ_viewmodel, FegyverInfo[Selectedgun[AK47][id]][ModelName]);
		case CSW_M4A1: entity_set_string(id, EV_SZ_viewmodel, FegyverInfo[Selectedgun[M4A1][id]][ModelName]);
		case CSW_AWP: entity_set_string(id, EV_SZ_viewmodel, FegyverInfo[Selectedgun[AWP][id]][ModelName]);
		case CSW_DEAGLE: entity_set_string(id, EV_SZ_viewmodel, FegyverInfo[Selectedgun[DEAGLE][id]][ModelName]);
		case CSW_KNIFE: entity_set_string(id, EV_SZ_viewmodel, FegyverInfo[Selectedgun[KNIFE][id]][ModelName]);
	}
}
public ChangeWeapon(iEnt)
{
	if(!pev_valid(iEnt))
		return;

	new id = get_pdata_cbase(iEnt, 41, 4);

	if(g_SkinBeKi[id])
		return;
		
	if(!pev_valid(id))
		return;

	new iWeapon = cs_get_weapon_id(iEnt);

	switch(iWeapon)
	{
		case CSW_AK47: entity_set_string(id, EV_SZ_viewmodel, FegyverInfo[Selectedgun[AK47][id]][ModelName]);
		case CSW_M4A1: entity_set_string(id, EV_SZ_viewmodel, FegyverInfo[Selectedgun[M4A1][id]][ModelName]);
		case CSW_AWP: entity_set_string(id, EV_SZ_viewmodel, FegyverInfo[Selectedgun[AWP][id]][ModelName]);
		case CSW_DEAGLE: entity_set_string(id, EV_SZ_viewmodel, FegyverInfo[Selectedgun[DEAGLE][id]][ModelName]);
		case CSW_KNIFE: entity_set_string(id, EV_SZ_viewmodel, FegyverInfo[Selectedgun[KNIFE][id]][ModelName]);
	}
}
public KillDrop1(id)
{
const ChaseNumber = 9;
new Float:DropChance[ChaseNumber]; 

DropChance[0] = 4.5;
DropChance[1] = 5.0;
DropChance[2] = 5.0;
DropChance[3] = 4.0;
DropChance[4] = 3.0;
DropChance[5] = 1.0;
DropChance[6] = 1.0;
DropChance[7] = 0.001;
DropChance[8] = 1.8;
//DropChance[8] = 0.50;

new Float:NoDropChance = 77.0;

new szName[32];
get_user_name(id, szName, charsmax(szName));
new Nev[32]; get_user_name(id, Nev, 31);

{
  new Float:DropChanceAdder[ChaseNumber];
  if (Vip[id][isPremium] ==1) //---------------------------VIPS----------------------//
	{
		for (new i = 0; i < ChaseNumber;i++)
    	{
    		DropChanceAdder[i] += DropChance[i] / 100.0 * 20.0;
  		}
	}
  
  for (new i = 0; i < ChaseNumber;i++) //Apply Vip&Event multiplier
  {
    DropChance[i] += DropChanceAdder[i];
  }
}
new Float:OverallChance;
for (new i = 0; i < ChaseNumber;i++) //Apply Vip&Event multiplier
  {
    OverallChance += DropChance[i];
  }

OverallChance += NoDropChance;
new Float:RandomNumber = random_float(0.01,OverallChance);

new Float:ChanceOld = 0.0;
new Float:ChanceNow = 0.0;

for(new i = 0; i < ChaseNumber;i++)
{
  ChanceOld = ChanceNow;
  ChanceNow += DropChance[i];
  if((ChanceOld < RandomNumber < ChanceNow)&&!(ChanceOld == 0.0))
  {
    LadaK[i-1][id]++;
    sk_chat(0, "^3%s ^1Találta ezt: ^4%s^1 (Esélye ennek:^4%.2f%s^1)", Nev, Keys[i-1][d_Name], (DropChance[i]/(OverallChance/100)), "%");
    i = ChaseNumber;
  }
	else if(ChanceOld < RandomNumber < ChanceNow && ChanceOld == 0.0)
	{
		Lada[i-1][id]++;
		sk_chat(0, "^3%s ^1Találta ezt: ^4%s^1 ( Esélye ennek:^4%.2f%s ^1)", Nev, Keys[i-1][d_Name], (DropChance[i]/(OverallChance/100)), "%");
		i = ChaseNumber;
	}
 }
}
public KillDrop(id)
{
const ChaseNumber = 9;
new Float:DropChance[ChaseNumber]; 

DropChance[0] = 4.5;
DropChance[1] = 6.0;
DropChance[2] = 5.0;
DropChance[3] = 4.0;
DropChance[4] = 3.0;
DropChance[5] = 1.0;
DropChance[6] = 1.0;
DropChance[7] = 0.01;
DropChance[8] = 1.8;
//DropChance[8] = 0.50;

new Float:NoDropChance = 79.0;

new szName[32];
get_user_name(id, szName, charsmax(szName));
new Nev[32]; get_user_name(id, Nev, 31);

{
  new Float:DropChanceAdder[ChaseNumber];
  
  if (Vip[id][isPremium] ==1) //---------------------------VIPS----------------------//
	{
		for (new i = 0; i < ChaseNumber;i++)
    	{
    		DropChanceAdder[i] += DropChance[i] / 100.0 * 20.0;
  		}
	}
  
  
  for (new i = 0; i < ChaseNumber;i++) //Apply Vip&Event multiplier
  {
    DropChance[i] += DropChanceAdder[i];
  }
}
new Float:OverallChance;
for (new i = 0; i < ChaseNumber;i++) //Apply Vip&Event multiplier
  {
    OverallChance += DropChance[i];
  }

OverallChance += NoDropChance;
new Float:RandomNumber = random_float(0.01,OverallChance);

new Float:ChanceOld = 0.0;
new Float:ChanceNow = 0.0;

for(new i = 0; i < ChaseNumber;i++)
{
  ChanceOld = ChanceNow;
  ChanceNow += DropChance[i];
  if((ChanceOld < RandomNumber < ChanceNow)&&!(ChanceOld == 0.0))
  {
    Lada[i-1][id]++;
    sk_chat(0, "^3%s ^1Találta ezt: ^4%s^1 (Esélye ennek:^4%.2f%s^1)", Nev, Cases[i-1][d_Name], (DropChance[i]/(OverallChance/100)), "%");
    i = ChaseNumber;
  }
   else if(ChanceOld < RandomNumber < ChanceNow && ChanceOld == 0.0)
	{
        Lada[i-1][id]++;
        sk_chat(0, "^3%s ^1Találta ezt: ^4%s^1 ( Esélye ennek:^4%.2f%s ^1)", Nev, Keys[i-1][d_Name], (DropChance[i]/(OverallChance/100)), "%");
        i = ChaseNumber;
	}
 }
}
public SetModels(id)
{
  if(Vip[id][isPremium])
  {
    if (cs_get_user_team(id) == CS_TEAM_T) cs_set_user_model(id, "balkam_romanov")
    else if(cs_get_user_team(id) == CS_TEAM_CT) cs_set_user_model(id, "FBI_ava")
  }

}
public plugin_precache() {
	new s_
	new ServerIP[33]
	get_user_ip(0, ServerIP, 33, 0);

	if(equali(ServerIP, "37.221.209.130:27350"))
	{
		s_ = 1
	}
	else if(equali(ServerIP, "37.221.209.130:27185"))
	{
		s_ = 2
	}
	else if(equali(ServerIP, "37.221.209.130:27295"))
	{
		s_ = 3
	}

	g_Admins = ArrayCreate(AdminData);
	new fegyver = sizeof(FegyverInfo)
	new musicsizeof;
	musicsizeof = sizeof(MusicBoxMusics)
	if(s_ == 1)
	{
		for(new i;i < fegyver; i++) 
		{
			if(FegyverInfo[i][PiacraHelyezheto] != -2)
			{
				precache_model(FegyverInfo[i][ModelName])
				//console_print(0, "[AV] %s - Betoltve!", FegyverInfo[i][ModelName])
			}
				
		}
	}
	else
	{
		for(new i;i < fegyver; i++) 
		{
			if(FegyverInfo[i][ModelName] != EOS)
			{
				precache_model(FegyverInfo[i][ModelName])
				//console_print(0, "[HB] %s - Betoltve!", FegyverInfo[i][ModelName])
			}		
		}
	}


	for(new i = 1;i < musicsizeof; i++)
	{
		precache_sound(MusicBoxMusics[i][MusicLocation]) 
	}
	precache_model("models/PT_Shediboii/caseasd.mdl");
}
public LoadUtils() {

/* 	tabla_1();
	tabla_2();
	tabla_3();
	tabla_4();
	tabla_5();
	tabla_6();
	tabla_7();
	tabla_8();
	tabla_9();
	tabla_10(); */
	g_SqlSMSTuple = SQL_MakeDbTuple("db.synhosting.eu", "viktor123", "YRfvPx1kvH", "viktor123", 10);
	TestSMSSQl("__syn_payments", "QueryTestSMSSql")
	
}
public TestSMSSQl(Table_Name[], ForwardMetod[])
{
	new Query[512];
	new Data[1];
	formatex(Query, charsmax(Query), "SELECT * FROM `%s`;",Table_Name);
	SQL_ThreadQuery(g_SqlSMSTuple, ForwardMetod, Query, Data, 1);
}
public QueryTestSMSSql(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime){
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) {
		console_print(0, "[Automatic Credit System] - MySQL Connection failed! Check error logs!"); 
		console_print(0, "%s", Error); 
		return;
	}
	else console_print(0, "[Automatic Credit System] - MySQL Connection succesful! Hi viktor123!"); 
}
public tabla_7()
{
	new Len;
	static Query[10048];
	Len += formatex(Query[Len], charsmax(Query), "CREATE TABLE IF NOT EXISTS `shedi_kuldik` ");
	Len += formatex(Query[Len], charsmax(Query)-Len, "( ");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`Id` INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`QuestH1` int(11) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`QuestMVP1` int(11) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`QuestNeed1` int(11) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`QuestHave1` int(11) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`QuestWeap1` int(11) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`QuestHead1` int(11) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`JutLada1` int(11) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`JutKulcs1` int(11) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`JutPont1` int(11) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`JutST` int(11) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`JutNC` int(11) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`JutDoll1` float(32) NOT NULL,"); 
	Len += formatex(Query[Len], charsmax(Query)-Len, "`Parameter` INT(11) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`User_Id` INT(11) NOT NULL DEFAULT 0)");
	SQL_ThreadQuery(g_SqlTuple, "createTableThread3", Query);
}
public tabla_6()
{

	new Len;
	static Query[10048];
	Len += formatex(Query[Len], charsmax(Query), "CREATE TABLE IF NOT EXISTS `shedi_testers` ");
	Len += formatex(Query[Len], charsmax(Query)-Len, "( ");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`Id` INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`Name` VARCHAR(32) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`Parameter` INT(11) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`User_Id` INT(11) NOT NULL DEFAULT 0)");
	SQL_ThreadQuery(g_SqlTuple, "createTableThread", Query);
}
public tabla_2()
{
	new Len;
	static Query[10048];
	Len += formatex(Query[Len], charsmax(Query), "CREATE TABLE IF NOT EXISTS `Weapon` ");
	Len += formatex(Query[Len], charsmax(Query)-Len, "( ");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`Id` INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,");
	
	for(new i;i < 200; i++)
		Len += formatex(Query[Len], charsmax(Query)-Len, "`F_%i` INT(11) NOT NULL,", i);
	
	Len += formatex(Query[Len], charsmax(Query)-Len, "`Parameter` INT(11) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`User_Id` INT(11) NOT NULL DEFAULT 0)");
	SQL_ThreadQuery(g_SqlTuple, "createTableThread", Query);
}
public tabla_4()
{
	new Len;
	static Query[10048];
	Len += formatex(Query[Len], charsmax(Query), "CREATE TABLE IF NOT EXISTS `StattrakKills` ");
	Len += formatex(Query[Len], charsmax(Query)-Len, "( ");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`Id` INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,");
	
	for(new i;i < 200; i++)
		Len += formatex(Query[Len], charsmax(Query)-Len, "`stk_%i` INT(11) NOT NULL,", i);
	
	Len += formatex(Query[Len], charsmax(Query)-Len, "`Parameter` INT(11) NOT NULL DEFAULT 0,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`User_Id` INT(11) NOT NULL DEFAULT 0)");
	SQL_ThreadQuery(g_SqlTuple, "createTableThread", Query);
}
public tabla_10()
{
	new Len;
	static Query[10048];
	Len += formatex(Query[Len], charsmax(Query), "CREATE TABLE IF NOT EXISTS `ErdemErmek` ");
	Len += formatex(Query[Len], charsmax(Query)-Len, "( ");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`Id` INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,");
	
	for(new i;i < 30; i++)
	{
		Len += formatex(Query[Len], charsmax(Query)-Len, "`rm_%i` INT(11) NOT NULL,", i);
		Len += formatex(Query[Len], charsmax(Query)-Len, "`CollectedTime_%i` VARCHAR(32) NOT NULL,", i);
	}
	
	Len += formatex(Query[Len], charsmax(Query)-Len, "`Parameter` INT(11) NOT NULL DEFAULT 0,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`User_Id` INT(11) NOT NULL DEFAULT 0)");
	SQL_ThreadQuery(g_SqlTuple, "createTableThread", Query);
}
public tabla_5()
{
	new Len;
	static Query[10048];
	Len += formatex(Query[Len], charsmax(Query), "CREATE TABLE IF NOT EXISTS `Stattrak` ");
	Len += formatex(Query[Len], charsmax(Query)-Len, "( ");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`Id` INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,");
	
	for(new i;i < 200; i++)
		Len += formatex(Query[Len], charsmax(Query)-Len, "`st_%i` INT(11) NOT NULL,", i);
	
	Len += formatex(Query[Len], charsmax(Query)-Len, "`Parameter` INT(11) NOT NULL DEFAULT 0,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`User_Id` INT(11) NOT NULL DEFAULT 0)");
	SQL_ThreadQuery(g_SqlTuple, "createTableThread", Query);
}
public tabla_3()
{

	new Len;
	static Query[10048];
	Len += formatex(Query[Len], charsmax(Query), "CREATE TABLE IF NOT EXISTS `Nevcedula2` ");
	Len += formatex(Query[Len], charsmax(Query)-Len, "( ");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`Id` INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,");
	
	for(new i = 158;i < 250; i++)
		Len += formatex(Query[Len], charsmax(Query)-Len, "`N%i` VARCHAR(32) NOT NULL,", i);
		
	Len += formatex(Query[Len], charsmax(Query)-Len, "`Parameter` INT(11) NOT NULL DEFAULT 0,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`User_Id` INT(11) NOT NULL DEFAULT 0)");
	SQL_ThreadQuery(g_SqlTuple, "createTableThread2", Query);
}
public createTableThread3(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime) {
	if(FailState == TQUERY_CONNECT_FAILED)
		set_fail_state("[HIBA*] NEM TUDTAM CSATLAKOZNI AZ ADATBAZISHOZ!");
	else if(FailState == TQUERY_QUERY_FAILED)
		set_fail_state("Query Error");
	if(Errcode)
		log_amx("[HIBA*] HIBAT DOBTAM: %s",Error);
}
public createTableThread2(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime) {
	if(Errcode)
		log_amx("[HIBA*] HIBAT DOBTAM: %s",Error);
	if(FailState == TQUERY_CONNECT_FAILED)
		set_fail_state("[HIBA*] NEM TUDTAM CSATLAKOZNI AZ ADATBAZISHOZ!");
	else if(FailState == TQUERY_QUERY_FAILED)
		set_fail_state("Query Error");
}
public createTableThread(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime) {
	if(Errcode)
		log_amx("[HIBA*] HIBAT DOBTAM: %s",Error);
	if(FailState == TQUERY_CONNECT_FAILED)
		set_fail_state("[HIBA*] NEM TUDTAM CSATLAKOZNI AZ ADATBAZISHOZ!");
	else if(FailState == TQUERY_QUERY_FAILED)
		set_fail_state("Query Error");
}
public tabla_1() {
	
	new Len;
	static Query[10048];
	Len += formatex(Query[Len], charsmax(Query), "CREATE TABLE IF NOT EXISTS `profiles` ");
	Len += formatex(Query[Len], charsmax(Query)-Len, "( ");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`User_Id` INT(11) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`Dollars` float(32) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`gamename` varchar(32) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`oles` INT(11) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`premiumpont` INT(11) NOT NULL,")
	Len += formatex(Query[Len], charsmax(Query)-Len, "`fejloves` INT(11) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`KSzint` INT(11) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`Exp` float(32) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`STTool` INT(11) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`Kulcs` INT(11) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`SzinesFomenu` INT(11) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`Nevcedula` INT(11) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`halal` INT(11) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`Id` INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,");
	
	for(new i;i < LADASZAM; i++)
		Len += formatex(Query[Len], charsmax(Query)-Len, "`Case%i` INT(11) NOT NULL,", i);

	for(new i;i < 5; i++)
		Len += formatex(Query[Len], charsmax(Query)-Len, "`Skin%i` INT(11) NOT NULL,", i);
	
	Len += formatex(Query[Len], charsmax(Query)-Len, "`Admin_Szint` INT(1) NOT NULL)");
	SQL_ThreadQuery(g_SqlTuple, "createTableThread", Query);
}
public tabla_8() {
	
	new Len;
	static Query[10048];
	Len += formatex(Query[Len], charsmax(Query), "CREATE TABLE IF NOT EXISTS `skins` ");
	Len += formatex(Query[Len], charsmax(Query)-Len, "( ");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`User_Id` INT(11) NOT NULL,");
	for(new i;i < 5; i++)
	Len += formatex(Query[Len], charsmax(Query)-Len, "`Skin%i` INT(11) NOT NULL,", i);
	Len += formatex(Query[Len], charsmax(Query)-Len, "`Id` INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY)");
	SQL_ThreadQuery(g_SqlTuple, "createTableThread", Query);
}
public tabla_9() {
	
	new Len;
	static Query[10048];
	Len += formatex(Query[Len], charsmax(Query), "CREATE TABLE IF NOT EXISTS `MusicKits` ");
	Len += formatex(Query[Len], charsmax(Query)-Len, "( ");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`User_Id` INT(11) NOT NULL,");
	for(new i;i < 15; i++)
	Len += formatex(Query[Len], charsmax(Query)-Len, "`Kit%i` INT(11) NOT NULL,", i);
	Len += formatex(Query[Len], charsmax(Query)-Len, "`Parameter` INT(11) NOT NULL DEFAULT 0,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`Id` INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY)");
	SQL_ThreadQuery(g_SqlTuple, "createTableThread", Query);
}
public Load_Data_SMS(Table_Name[], ForwardMetod[])
{	
	new Query[512];
	new Data[1];
	formatex(Query, charsmax(Query), "SELECT * FROM `%s`;",Table_Name);
	SQL_ThreadQuery(g_SqlSMSTuple, ForwardMetod, Query, Data, 1);
}
/* public SMSMotd(id)
{
  new jatekfizetes[50] = "https://jatekfizetes.hu";
  new len;
  new StringMotd[2500]
  new year, month, day;
  date(year, month, day);

  len += formatex(StringMotd[len], charsmax(StringMotd) - len, "<HTML><HEAD><meta charset=^"UTF-8^"><TITLE>Pötyi Pont Vásárlás</TITLE></HEAD>");
  len += formatex(StringMotd[len], charsmax(StringMotd) - len, "<BODY><center>");
  len += formatex(StringMotd[len], charsmax(StringMotd) - len, "<h1><center></center></h1><h2>Csomagok:</h2>")
  len += formatex(StringMotd[len], charsmax(StringMotd) - len, "Elkündendő üzenet:<b><h1> SYN marosi %i</h1></b><br><br>", g_Id[id])
  len += formatex(StringMotd[len], charsmax(StringMotd) - len, "<h2>FONTOS hogy a SYN, marosi és a szám között legyen egy-egy space!</h2><br><br>")
  if(month == 08 && day == 31 || month == 09 && day == 30 || month == 10 && day == 31 || month == 11 && day == 30 || month == 12 && day == 31 || month == 01 && day == 31)
  {
	len += formatex(StringMotd[len], charsmax(StringMotd) - len, "Jelenleg DUPLA Pötyi Pont jóváírás van!<br>")
	len += formatex(StringMotd[len], charsmax(StringMotd) - len, "400 PP - 330FT - Telefonszám:0690642030<br>")
	len += formatex(StringMotd[len], charsmax(StringMotd) - len, "680 PP - 508FT - Telefonszám:0690643646<br>")
	len += formatex(StringMotd[len], charsmax(StringMotd) - len, "1160 PP - 1016FT - Telefonszám:0690888355<br>")
	len += formatex(StringMotd[len], charsmax(StringMotd) - len, "2200 PP - 2032FT - Telefonszám:0690888466<br>")
	len += formatex(StringMotd[len], charsmax(StringMotd) - len, "6500 PP - 5080FT - Telefonszám:0690649099<br><br>")
  }
  else
  {
	len += formatex(StringMotd[len], charsmax(StringMotd) - len, "Minden hónap utolsó napján, DUPLA Jóváírás!<br>")
	len += formatex(StringMotd[len], charsmax(StringMotd) - len, "200 PP - 330FT - Telefonszám:0690642030<br>")
	len += formatex(StringMotd[len], charsmax(StringMotd) - len, "340 PP - 508FT - Telefonszám:0690643646<br>")
	len += formatex(StringMotd[len], charsmax(StringMotd) - len, "580 PP - 1016FT - Telefonszám:0690888355<br>")
	len += formatex(StringMotd[len], charsmax(StringMotd) - len, "1100 PP - 2032FT - Telefonszám:0690888466<br>")
	len += formatex(StringMotd[len], charsmax(StringMotd) - len, "3000 PP - 5080FT - Telefonszám:0690649099<br><br>")
  }
  
  len += formatex(StringMotd[len], charsmax(StringMotd) - len, "* <h1>Az elrontott SMS-ekért felelősséget nem vállalunk!</h1><br>")
  len += formatex(StringMotd[len], charsmax(StringMotd) - len, "* <h1>Ha többet szeretnél vásárolni, egymás után is küldheted, jóváírja.</h1><br>")
  len += formatex(StringMotd[len], charsmax(StringMotd) - len, "A feltüntetett összegek bruttó árakat tartalmaznak! (Végleges árak)<br>");
  len += formatex(StringMotd[len], charsmax(StringMotd) - len, "Technikai háttér:<br>Az Emelt Díjas SMS Rendszert a <a href=^"%s^">https://jatekfizetes.hu</a> (Pannora Kft. ) biztosítja.<br>A szolgáltatás csak a telefonszámlát fizető, felelős személy beleegyezésével használható.<br>Hiba esetén az ügyfélszolgálat elérhető: +3630 469-4278 (H-P: 9-16:30-ig), e-mail: info@jatekfizetes.hu</BODY></HTML>", jatekfizetes)
  show_motd(id, StringMotd, "[AV-HB] Pötyi Pont vásárlás | SMS");
} */

public QuerySelectBuyPP(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime)
{
  if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED)
  {
    log_amx("%s", Error);
    return;
  }
  else
  {
    if(SQL_NumRows(Query) > 0) 
    {
      new Temptarifa, Tempuserid, SynId, tempQuery[512], TempActive, paymenthodid;
      new year, month, day;
      date(year, month, day);
      while(SQL_MoreResults(Query))
      {
        Tempuserid = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "comment"));
        TempActive = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Active"));
				paymenthodid = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "paymethodid"));

        for(new i; i < 33; i++)
        {
					if(Tempuserid == g_Id[i] && TempActive == 1 && paymenthodid != 0)
					{
						SynId = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "id"));
						Temptarifa = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "amount"));
						sk_set_pp(i, sk_get_pp(i)+Temptarifa)

						sk_chat(0, "Játékos: ^4%s^1 vásárolt ^4%i^1 Pötyi Pontot! A vásárlás jóváírva!", sk_name(i), Temptarifa)
						sk_chat(i, "Köszönjük a vásárlást! ^3[^1Vásárlás id: ^4#%i^3 | ^1Vásárolt pontok: ^4%i^3]", SynId, Temptarifa)

						formatex(tempQuery, charsmax(tempQuery), "UPDATE `__syn_payments` SET `Active`=0 WHERE `id` = %d;", SynId);
						SQL_ThreadQuery(g_SqlSMSTuple, "QuerySetData", tempQuery);
						sk_log("CreditSys", fmt("[VASARLAS] (%s) Comment: %i / Amount %i / SynID: %i", sk_ipidform(i), Tempuserid, Temptarifa, SynId))
					}
		
        }
        SQL_NextRow(Query);
      }
    }
  }
}
public QuerySetData(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime){
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) {
		log_amx("%s", Error);
		return;
	}
}
public Set_Permissions(id){
	new Flags;
	Flags = read_flags(Admin_Permissions[g_Admin_Level[id]][1]);
	set_user_flags(id, Flags);
}
public CmdSetAdmin(id, level, cid){
	if(!str_to_num(Admin_Permissions[g_Admin_Level[id]][2])){
	sk_chat(id,  "^1 ^3Nincs elérhetőséged^1 ehhez a parancshoz!");
	return PLUGIN_HANDLED;
	}

	new Arg1[32], Arg2[32], Arg_Int[2]
	new szName[32];
	get_user_name(id, szName, charsmax(szName));
	read_argv(1, Arg1, charsmax(Arg1));
	read_argv(2, Arg2, charsmax(Arg2));

	Arg_Int[0] = str_to_num(Arg1);
	Arg_Int[1] = str_to_num(Arg2);
	
	if(Arg_Int[0] < 1 || Arg_Int[1] >= sizeof(Admin_Permissions))
		return PLUGIN_HANDLED;	

	new Data[1]
	new Is_Online = Check_Id_Online(Arg_Int[0]);
	static Query[10048];
	
	Data[0] = id;
	
	formatex(Query, charsmax(Query), "UPDATE `profiles` SET `Admin_Szint` = %d WHERE `User_Id` = %d;", Arg_Int[1], Arg_Int[0]);
	SQL_ThreadQuery(g_SqlTuple, "QuerySetData", Query, Data, 1);

	formatex(Query, charsmax(Query), "UPDATE `herboy_regsystem` SET `AdminLVLForWeb` = %d WHERE `id` = %d;", Arg_Int[1], Arg_Int[0]);
	SQL_ThreadQuery(g_SqlTuple, "QuerySetData", Query, Data, 1);
	
	if(Is_Online){
		if(Arg_Int[1] > 0)
			sk_chat(0, "^1Játékos: ^3%s ^1(#^3%d^1) | %s jogot kapott! ^3%s^1(#^3%d^1) által!", Player[Is_Online][f_PlayerNames], Arg_Int[0], Admin_Permissions[Arg_Int[1]][0], szName, g_Id[id]);	
		else
			sk_chat(0, "^1Játékos: ^3%s ^1(#^3%d^1) | Jogok megvonva! ^3%s^1(#^3%d^1) által!", Player[Is_Online][f_PlayerNames], Arg_Int[0], szName,  g_Id[id]);	
		
		Set_Permissions(Is_Online);
		g_Admin_Level[Is_Online] = Arg_Int[1];
	}
	else{
		if(Arg_Int[1] > 0)
			sk_chat(0, "^1Játékos: ^3- ^1(#^3%d^1) | %s jogot kapott! ^3%s^1(#^3%d^1) által!", Arg_Int[0], Admin_Permissions[Arg_Int[1]][0], szName, g_Id[id]);	
		else
			sk_chat(0, "^1Játékos: ^3- ^1(#^3%d^1) | Jogok megvonva! ^3%s^1(#^3%d^1) által!", Arg_Int[0], szName, g_Id[id]);		
	}
		
	return PLUGIN_HANDLED;
}
public CmdSetPP(id, level, cid){
	if(!str_to_num(Admin_Permissions[g_Admin_Level[id]][2])){
	sk_chat(id,  "^1 ^3Nincs elérhetőséged^1 ehhez a parancshoz!");
	return PLUGIN_HANDLED;
	}

	new Arg1[32], Arg2[32], Arg_Int[2]
	new szName[32];
	get_user_name(id, szName, charsmax(szName));
	read_argv(1, Arg1, charsmax(Arg1));
	read_argv(2, Arg2, charsmax(Arg2));

	Arg_Int[0] = str_to_num(Arg1);
	Arg_Int[1] = str_to_num(Arg2);
	
	if(Arg_Int[0] < 1)
		return PLUGIN_HANDLED;	

	new Is_Online = Check_Id_Online(Arg_Int[0]);

	if(Arg_Int[1] == 0)
	{
		sk_set_pp(Is_Online, 0)
		sk_chat(0, "Admin: ^4%s^1(#^3%d^1) törölte ^4%s^1(#^3%d^1) Pötyi Pontjait a rendszerből.", szName, g_Id[id], Player[Is_Online][f_PlayerNames], Arg_Int[0])
	}
	else if(Arg_Int[1] > 0)
	{
		sk_set_pp(Is_Online, sk_get_pp(id)+Arg_Int[1])
		sk_chat(0, "Admin: ^4%s^1(#^3%d^1) adott ^4%i^1 Pötyi Pontot ^4%s^1(#^3%d^1) játékosnak.", szName, g_Id[id], Arg_Int[1], Player[Is_Online][f_PlayerNames], Arg_Int[0])
	}

	return PLUGIN_HANDLED;
}
stock Check_Id_Online(id){
	for(new idx = 0; idx <= g_Maxplayers; idx++){
		if(!is_user_connected(idx))
			continue;
					
		if(g_Id[idx] == id)
			return idx;
	}
	return 0;
}
public openTools(id) {
	new szMenu[121]
	formatex(szMenu, charsmax(szMenu), "%s \r[ \wKiegészítők \r]", menuprefix)
	new menu = menu_create(szMenu, "hTools");
	
	formatex(szMenu, charsmax(szMenu), "\yStatTrak\r* \dTool \r[\w%i \rDB]^n    \wInfó: \dKiválasztott fegyverre felszerelhető, számolja az öléseket^n", g_Tools[0][id])
	menu_additem(menu, szMenu, "0", 0)
	formatex(szMenu, charsmax(szMenu), "\yNévcédula \r[\w%i \rDB]", g_Tools[1][id])
	menu_additem(menu, szMenu, "1", 0)

	menu_display(id, menu, 0)
}
public hTools(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED
	
	}
	
	switch(item)
	{
		case 0: if(g_Tools[0][id] > 0)
		openAddStatTrak(id)
		case 1: if(g_Tools[1][id] > 0) 
		openAddNameTag(id)
		case 3: if(g_Tools[1][id] > 0) {
			if(g_Kirakva[id] == 1) {
				openTools(id)
				sk_chat(id,  "^1Nem szerelhetsz fel Névcédulát amíg valamelyik tárgyad a Piacon van vagy kivan választva!")
				menu_destroy(menu);
				return PLUGIN_HANDLED
			}
			openAddNameTag(id)
		}
	}
	menu_destroy(menu)
	return PLUGIN_HANDLED
}
public openAddStatTrak(id)
{
	new szMenu[121],cim[121]
	formatex(szMenu, charsmax(szMenu), "%s \r[ \wFegyverválasztó \r]", menuprefix)
	new menu = menu_create(szMenu, "hAddStat");
	new fegyver = sizeof(FegyverInfo)
 
	for(new i;i < fegyver; i++)
	{
		if(g_Weapons[i][id] > 0 || g_Weapons[i][id] < 129)
		{
			formatex(szMenu, charsmax(szMenu), "\yST\r* \d(%idb) \w", g_StatTrak[i][id])
			num_to_str(i, cim, 5);
			if(strlen(g_GunNames[i][id]) < 1) formatex(szMenu, charsmax(szMenu), "%s%s \r(\y%i \rDB)", g_StatTrak[i][id] >= 1 ? szMenu : "", FegyverInfo[i][GunName], g_Weapons[i][id]);
			else formatex(szMenu, charsmax(szMenu), "%s%s \r(\y%i \rDB)", g_StatTrak[i][id] >= 1 ? szMenu : "", g_GunNames[i][id], g_Weapons[i][id]);
			menu_additem(menu, szMenu, cim);
		}
	}
	menu_display(id, menu, 0);
}
public hAddStat(id, menu, item) {
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED
	}
	
	new data[9], szName[64]
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName, charsmax(szName), callback);
	new key = str_to_num(data);
	
	if(g_Weapons[key][id] == g_StatTrak[key][id]) sk_chat(id,  "^1Nincs elég fegyvered a raktárba!")
	else {
		g_StatTrak[key][id]++
		g_StatTrakKills[key][id] = 0;
		g_Tools[0][id]--
		sk_chat(id,  "^3StatTrak* ^1Tool sikeresen felszerelve!")
	}
	
	openTools(id)
	
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public openAddNameTag(id)
{
	new szMenu[121], /* String[6], */ cim[121];
	formatex(szMenu, charsmax(szMenu), "%s \r[ \wFegyverelnevezés \r]", menuprefix)
	new menu = menu_create(szMenu, "hAddName");
	new fegyver = sizeof(FegyverInfo)
 
	for(new i;i < fegyver; i++)
	{
		if(g_Weapons[i][id] > 0 && g_Weapons[i][id] < 129)
		{
			formatex(szMenu, charsmax(szMenu), "\yST\r* \d(%idb) \w", g_StatTrak[i][id])
			num_to_str(i, cim, 5);
			if(strlen(g_GunNames[i][id]) < 1) formatex(szMenu, charsmax(szMenu), "%s%s", g_StatTrak[i][id] >= 1 ? szMenu : "", FegyverInfo[i][GunName]);
			else formatex(szMenu, charsmax(szMenu), "%s%s", g_StatTrak[i][id] >= 1 ? szMenu : "", g_GunNames[i][id]);
			menu_additem(menu, szMenu, cim);
		}
	}
	menu_display(id, menu, 0);
}
public hAddName(id, menu, item) {
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED
	}

	new data[9], szName[64]
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName, charsmax(szName), callback);
	g_NameTagKey = str_to_num(data);
	

	if(strlen(g_GunNames[g_NameTagKey][id]) > 0){
		openTools(id)
		sk_chat(id,  "^1Ez a fegyver már egyszer ellett nevezve!")
	}
	else client_cmd(id, "messagemode Nevcedula_nev")
	
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public cmdSetGunName(id) {
	g_GunNames[g_NameTagKey][id][0] = EOS
	read_args(g_GunNames[g_NameTagKey][id], 99)
	remove_quotes(g_GunNames[g_NameTagKey][id])

	if(strlen(g_GunNames[g_NameTagKey][id]) < 3 || strlen(g_GunNames[g_NameTagKey][id]) > 24 || contain(g_GunNames[g_NameTagKey][id][0], "'") != -1)
	{
		sk_chat(id,  "^1A Fegyver Név nem lehet rövidebb 3, illetve hosszabb 24 karakternél, vagy ne használj ' jelet!")
		g_GunNames[g_NameTagKey][id][0] = EOS
		openTools(id)
		return PLUGIN_HANDLED
	}
	new iTxt[100]
	if(FegyverInfo[g_NameTagKey][EntName] == CSW_AK47) formatex(iTxt, charsmax(iTxt), "AK47 | %s", g_GunNames[g_NameTagKey][id])
	else if(FegyverInfo[g_NameTagKey][EntName] == CSW_M4A1) formatex(iTxt, charsmax(iTxt), "M4A1 | %s", g_GunNames[g_NameTagKey][id])
	else if(FegyverInfo[g_NameTagKey][EntName] == CSW_AWP) formatex(iTxt, charsmax(iTxt), "AWP | %s", g_GunNames[g_NameTagKey][id])
	else if(FegyverInfo[g_NameTagKey][EntName] == CSW_DEAGLE) formatex(iTxt, charsmax(iTxt), "DEAGLE | %s", g_GunNames[g_NameTagKey][id])
	else if(FegyverInfo[g_NameTagKey][EntName] == CSW_KNIFE) formatex(iTxt, charsmax(iTxt), "KNIFE | %s", g_GunNames[g_NameTagKey][id])
	
	copy(g_GunNames[g_NameTagKey][id], 99, iTxt)
		
	sk_chat(id,  "^1A Fegyver neve mostantól: ^3%s", g_GunNames[g_NameTagKey][id])
	g_Tools[1][id]--
	openTools(id)
	return PLUGIN_HANDLED
}
public Piac(id)
{
	new iras[121]
	format(iras, charsmax(iras), "%s \r[ \wPiac elosztó \r]", menuprefix);
	new menu = menu_create(iras, "Piac_h");
	
	menu_additem(menu, "Eladás", "2", 0);
	menu_additem(menu, "Vásárlás", "1", 0);
	menu_additem(menu, "\y[\w\rItem\y/\rSkin\w Küldés\y]", "3", 0);


	if(Elhasznal[0][id] == 1) format(String,charsmax(String),"Kezdő Csomag \r[\dElhasználva\r]");
	else format(String,charsmax(String),"Kezdő Csomag \r[\yElérhető\r]");
	menu_additem(menu,String,"5");

/* 	if(Elhasznal[4][id] == 1) format(String,charsmax(String),"Ajándék Csomag \r[\dElhasználva\r]");
	else format(String,charsmax(String),"Ajándék Csomag \r[\yElérhető\r]");
	menu_additem(menu,String,"10");
	
	if(sk_get_playtime(id) > 36000 && Elhasznal[1][id] == 1) 
		format(String,charsmax(String),"Gyakornok Csomag \r[\dElhasználva\r]");
	else if(sk_get_playtime(id) > 36000)
		format(String,charsmax(String),"Gyakornok Csomag \r[\yElérhető\r]");
	else
		format(String,charsmax(String),"Gyakornok Csomag \r[\d10 Óra Játékidő\r]");
	menu_additem(menu,String,"6");
	
	if(sk_get_playtime(id) > 172800 && Elhasznal[2][id] == 1) 
		format(String,charsmax(String),"Profi Csomag \r[\dElhasználva\r]");
	else if(sk_get_playtime(id) > 172800)
		format(String,charsmax(String),"Profi Csomag \r[\yElérhető\r]");
	else
		format(String,charsmax(String),"Profi Csomag \r[\d2 Nap Játékidő\r]");
	menu_additem(menu,String,"7");
	
	if(sk_get_playtime(id) > 432000 && Elhasznal[3][id] == 1) 
		format(String,charsmax(String),"Veterán Csomag \r[\dElhasználva\r]");
	else if(sk_get_playtime(id) > 432000)
		format(String,charsmax(String),"Veterán Csomag \r[\yElérhető\r]");
	else
		format(String,charsmax(String),"Vet erán Csomag \r[\d5 Nap Játékidő\r]");
	menu_additem(menu,String,"8"); */
	
	if(g_Admin_Level[id] == 1 || g_Admin_Level[id] == 2)
		menu_additem(menu, "Tulajdonos Csomag \r[\yTULAJ JOG\r]", "9", ADMIN_IMMUNITY);	
	
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
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
	new key = str_to_num(data);
	
	switch(key)
	{
		case 1: openBuyer1(id);
		case 2: openSeller(id);
		case 3: openSending(id);
		case 5: StarterPack(id);
		case 6: GyakornokPack(id); //36000
		case 7: ProfiPack(id); //36000
		case 8: VeteranPack(id); //36000
		case 9: TulajPack(id);
		case 10: AjandekPack(id);
	}
}
public AjandekPack(id)
	{
		if(Elhasznal[4][id] == 0)
		{
			Elhasznal[4][id] = 1;
			new Data[1];
			static Query[10048];
			Data[0] = id;
			
			formatex(Query, charsmax(Query), "UPDATE `profiles` SET `Elhasznalva5` = 1 WHERE `User_Id` = %d;", g_Id[id]);
			SQL_ThreadQuery(g_SqlTuple, "QuerySetData", Query, Data, 1);
			sk_chat(id,  "Sikeresen ^1megkaptad az ^4Ajándék Csomagot^1! ^3(^4 Random dolog^3 )");

			switch(random_num(1, 2))
			{	
				case 1:
				{
					new Float:dollaresely = random_float(2.00, 10.00);
					g_dollar[id] += dollaresely;
					sk_chat(id,  "Az ajándékcsomag ezt tartalmazta: ^4%3.2f^1 dollár.", dollaresely);
				}
				case 2:
				{
					new dollaresely = random_num(50, 100);
					HBPont[id] += dollaresely;
					sk_chat(id,  "Az ajándékcsomag ezt tartalmazta: ^4%i^1 HBPont.", dollaresely);
				}
			}
		}
		else{
			sk_chat(id,  "Sajnálom, ^1de te már elhasználtad ezt a ^3csomagot!");
		}
	}
	public StarterPack(id)
	{
		if(Elhasznal[0][id] == 0)
		{
			HBPont[id] += 50;
			g_dollar[id] += 20.00;
			Elhasznal[0][id] = 1;
			new Data[1];
			static Query[10048];
			Data[0] = id;

			
			formatex(Query, charsmax(Query), "UPDATE `profiles` SET `Elhasznalva1` = 1 WHERE `User_Id` = %d;", g_Id[id]);
			SQL_ThreadQuery(g_SqlTuple, "QuerySetData", Query, Data, 1);
			sk_chat(id,  "^3Sikeresen ^1megkaptad a ^4Kezdő Csomagot^1! ^3(^4 20.00^1$ ^3és^4 50^1 HB Pont^3 )");
		}
		else{
			sk_chat(id,  "^3Sajnálom, ^1de te már elhasználtad ezt a ^3csomagot!");
		}
	}
	public GyakornokPack(id)
	{
		if(Elhasznal[1][id] == 0 && sk_get_playtime(id) > 36000)
		{
			new Data[1];
			static Query[10048];
			Data[0] = id;
			
			formatex(Query, charsmax(Query), "UPDATE `profiles` SET `Elhasznalva2` = 1 WHERE `User_Id` = %d;", g_Id[id]);
			SQL_ThreadQuery(g_SqlTuple, "QuerySetData", Query, Data, 1);
			HBPont[id] += 200;
			g_dollar[id] += 50.00;
			//Lada[0][id] += 5;
			//LadaK[0][id] += 5;
			Elhasznal[1][id] = 1;
			sk_chat(id,  "^3Sikeresen ^1megkaptad a ^4Gyakornok Csomagot^1! ^3(^4 50.00^1$ ^3és^4 200^1 HB Pont ^3)");
		}
		else if(sk_get_playtime(id) > 36000)
		{
			sk_chat(id,  "^3Sajnálom, ^1de te már elhasználtad ezt a ^3csomagot!");
		}
		else{
			sk_chat(id,  "Sajnálom, ^1de neked nincs^3 10 óra^1 játszott időd hogy elhasználhasd ezt a ^3csomagot!");
		}
	}
	public ProfiPack(id)
	{
		if(Elhasznal[2][id] == 0 && sk_get_playtime(id) > 172800)
		{
			new Data[1];
			static Query[10048];
			Data[0] = id;
			
			formatex(Query, charsmax(Query), "UPDATE `profiles` SET `Elhasznalva3` = 1 WHERE `User_Id` = %d;", g_Id[id]);
			SQL_ThreadQuery(g_SqlTuple, "QuerySetData", Query, Data, 1);
			HBPont[id] += 500;
			g_dollar[id] += 100.00;
			Lada[3][id] += 15;
			//LadaK[3][id] += 15;
			Elhasznal[2][id] = 1;
			sk_chat(id,  "^3Sikeresen ^1megkaptad a ^4Profi Csomagot^1! ^3(^4 100.00^1$ ^3és^4 500^1 HB Pont^3)");
		}
		else if(sk_get_playtime(id) > 172800)
		{
			sk_chat(id,  "^3Sajnálom, ^1de te már elhasználtad ezt a ^3csomagot!");
		}
		else{
			sk_chat(id,  "Sajnálom, ^1de neked nincs^3 2 nap^1 játszott időd hogy elhasználhasd ezt a ^3csomagot!");
		}
	}
	public VeteranPack(id)
	{
		if(Elhasznal[3][id] == 0 && sk_get_playtime(id) > 432000)
		{
			new Data[1];
			static Query[10048];
			Data[0] = id;
			
			formatex(Query, charsmax(Query), "UPDATE `profiles` SET `Elhasznalva4` = 1 WHERE `User_Id` = %d;", g_Id[id]);
			SQL_ThreadQuery(g_SqlTuple, "QuerySetData", Query, Data, 1);
			HBPont[id] += 1500;
			g_dollar[id] += 300.00;
			Lada[4][id] += 15;
			//LadaK[4][id] += 15;
			Elhasznal[3][id] = 1;
			sk_chat(id,  "^3Sikeresen ^1megkaptad a ^4Veterán Csomagot^1! ^3(^4 300^1$ ^3és^4 1500^1 HB Pont ^3)");
		}
		else if(sk_get_playtime(id) > 432000)
		{
			sk_chat(id,  "^3Sajnálom, ^1de te már elhasználtad ezt a ^3csomagot!");
		}
		else{
			sk_chat(id,  "^3Sajnálom, ^1de neked nincs^3 5 nap^1 játszott időd hogy elhasználhasd ezt a ^3csomagot!");
		}
	}
	public TulajPack(id)
	{	
		g_Tools[0][id] += 100;
		g_Tools[1][id] += 100;
		g_dollar[id] += 100.00;
		for(new i;i < sizeof(FegyverInfo); i++)
		g_Weapons[i][id] += 1;
		for(new i;i < sizeof(Cases); i++)
		Lada[i][id] += 100;
		for(new i;i < sizeof(Cases); i++)
		LadaK[i][id] += 100;

		
		sk_chat(id,  "^3Sikeresen ^1megkaptad a ^4Tulaj Csomagot^1! ^3(^4MINDEN CUCC^3)");
	}
public openSeller(id) {
	new szMenu[121], bypass = 0;
	formatex(szMenu, charsmax(szMenu), "%s \r[ \wPiac / Eladás \r]^nDollár: \d%3.2f$", menuprefix, g_dollar[id])
	new menu = menu_create(szMenu, "hEladas");
	new fegyver = sizeof(FegyverInfo)
	if(g_Erteke[id] != 0.0 && g_Kirakva[id] == 1) menu_additem(menu,"\dTárgy visszavonása a Piacról!", "0",0)
	if(g_Kirakva[id] == 0){
		if(g_Kicucc[id] <= fegyver) {
			if(strlen(g_GunNames[g_Kicucc[id]][id]) < 1 || !g_NameTagBeKi[id]) formatex(szMenu, charsmax(szMenu), "Tárgy Név: %s\d%s", g_StatTrakBeKi[id] ? "\yStatTrak\r* ":"", FegyverInfo[g_Kicucc[id]][GunName]);
			else formatex(szMenu, charsmax(szMenu), "Tárgy Név: %s\d%s", g_StatTrakBeKi[id] ? "\yStatTrak\r* ":"", g_GunNames[g_Kicucc[id]][id]);
		}
		else formatex(szMenu, charsmax(szMenu), "Tárgy Név: %s\d%s", g_StatTrakBeKi[id] ? "\yStatTrak\r* ":"", FegyverInfo[g_Kicucc[id]]);
		menu_additem(menu, szMenu, "1", 0);
		formatex(szMenu, charsmax(szMenu), "\wStatTrak* Tool: \d%s", g_StatTrakBeKi[id] ? "BE":"KI")
		menu_additem(menu, szMenu, "2",0)
		formatex(szMenu, charsmax(szMenu), "\wNévcédula: \d%s", g_NameTagBeKi[id] ? "BE":"KI")
		menu_additem(menu, szMenu, "3",0)
		formatex(szMenu, charsmax(szMenu), "Eladási Ár: \r%3.2f$^n", g_Erteke[id])
		menu_additem(menu, szMenu, "4",0)
		if(server == 3)
		{
			if(FegyverInfo[g_Kicucc[id]][PiacraHelyezheto] == -2)
				bypass = 1;
		}
	
		if((FegyverInfo[g_Kicucc[id]][PiacraHelyezheto] == 1 || bypass == 1) && g_Erteke[id] > 0) 
		menu_additem(menu,"\yKirakás a Piacra!","5",0)
		else if(g_Erteke[id] < 1)
		menu_additem(menu,"\dNincs megadva ár!","-1",0)
		else
		menu_additem(menu,"\dEz az item nem helyezhető ki!","-1",0)
	}
	
	menu_display(id, menu, 0);
	return PLUGIN_HANDLED
}
public hEladas(id, menu, item){
	
	if( item == MENU_EXIT ) {
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	
	new data[9], szName[64], iName[32]
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
	get_user_name(id, iName, charsmax(iName))
	new key = str_to_num(data);
	new sztime[40];
	new sztime1[40];	

 
	switch(key)
	{
		case 0:{
			g_Kirakva[id] = 0
			g_Erteke[id] = 0.0
			if(g_Kicucc[id] > 0 && g_Kicucc[id] <= 135) OsszesKirakott[0]--
			else if(g_Kicucc[id] >= 136 && g_Kicucc[id] <= 147) OsszesKirakott[1]--
			else if(g_Kicucc[id] >= 148 && g_Kicucc[id] <= 159) OsszesKirakott[2]--
			else if(g_Kicucc[id] >= 160) OsszesKirakott[3]--
			g_Kicucc[id] = 0
			g_StatTrakBeKi[id] = false
			g_NameTagBeKi[id] = false
		}
		case 1: openSelectItem(id)
		case 2: {
			if(g_Kicucc[id] >= 135) {
				openSeller(id)
				return PLUGIN_HANDLED
			}
			if(g_StatTrak[g_Kicucc[id]][id] != g_Weapons[g_Kicucc[id]][id]) {
			if(!g_StatTrakBeKi[id]) g_StatTrakBeKi[id] = true
				else if(g_StatTrakBeKi[id]) g_StatTrakBeKi[id] = false
			}
			openSeller(id)
		}
		case 3: {
			if(g_Kicucc[id] >= 135) {
				openSeller(id)
				return PLUGIN_HANDLED
			}
			if(g_Weapons[g_Kicucc[id]][id] > 1 && strlen(g_GunNames[g_Kicucc[id]][id]) > 0) {
				if(!g_NameTagBeKi[id]) g_NameTagBeKi[id] = true
				else if(g_NameTagBeKi[id]) g_NameTagBeKi[id] = false
			}
			openSeller(id)
		}
		case 4: client_cmd(id, "messagemode DOLLAR_AR")
		case 5: {
			if(g_Kicucc[id] <= 135) {
				if(g_StatTrakBeKi[id] &&  g_StatTrak[g_Kicucc[id]][id] > 0 || !g_StatTrakBeKi[id] &&  g_StatTrak[g_Kicucc[id]][id] == 0 || !g_StatTrakBeKi[id] &&  g_StatTrak[g_Kicucc[id]][id] > 0) {
					if(strlen(g_GunNames[g_Kicucc[id]][id]) < 1 && g_NameTagBeKi[id]) sk_chat(0, "^4^3%s ^1kirakott egy ^3%s%s ^1fegyvert a Piacra ^4%3.2f$^1-ért!", iName, g_StatTrakBeKi[id] ? "StatTrak* ":"", g_GunNames[g_Kicucc[id]][id], g_Erteke[id])
					else if(strlen(g_GunNames[g_Kicucc[id]][id]) > 0 && !g_NameTagBeKi[id]) sk_chat(0, "^4^3%s ^1kirakott egy ^3%s%s ^1fegyvert a Piacra ^4%3.2f$^1-ért!", iName, g_StatTrakBeKi[id] ? "StatTrak* ":"", FegyverInfo[g_Kicucc[id]][GunName], g_Erteke[id])
					else if(strlen(g_GunNames[g_Kicucc[id]][id]) > 0 && g_NameTagBeKi[id]) sk_chat(0, "^4^3%s ^1kirakott egy ^3%s%s ^1fegyvert a Piacra ^4%3.2f$^1-ért!", iName, g_StatTrakBeKi[id] ? "StatTrak* ":"", g_GunNames[g_Kicucc[id]][id], g_Erteke[id])
					else if(strlen(g_GunNames[g_Kicucc[id]][id]) < 1 && !g_NameTagBeKi[id]) sk_chat(0, "^4^3%s ^1kirakott egy ^3%s%s ^1fegyvert a Piacra ^4%3.2f$^1-ért!", iName, g_StatTrakBeKi[id] ? "StatTrak* ":"", FegyverInfo[g_Kicucc[id]][GunName], g_Erteke[id])
					g_Kirakva[id] = 1
					OsszesKirakott[0]++
				}
				else if(g_StatTrakBeKi[id] && g_StatTrak[g_Kicucc[id]][id] == 0) {
					g_StatTrakBeKi[id] = false
					openSeller(id)
					sk_chat(id,  "^1Ehhez a fegyverhez nincs ^3StatTrak* Tool^1-od!")
				}
			}
			else {
				sk_chat(0, "^4^3%s ^1kirakott egy ^3%s ^1tárgyat a Piacra ^4%3.2f$^1-ért!", iName, FegyverInfo[g_Kicucc[id]][GunName], g_Erteke[id])
				format_time(sztime, charsmax(sztime), "%Y.%m.%d - %H:%M:%S", get_systime())
				format_time(sztime1, charsmax(sztime1), "%Y.%m.%d", get_systime())
				log_to_file("eladas.txt", "%s kirakott egy %s tárgyat a Piacra %3.2f$-ért!", iName, FegyverInfo[g_Kicucc[id]][GunName], g_Erteke[id])
				g_Kirakva[id] = 1
				if(g_Kicucc[id] >= 136 && g_Kicucc[id] <= 147) OsszesKirakott[1]++
				else if(g_Kicucc[id] >= 148 && g_Kicucc[id] <= 159) OsszesKirakott[2]++
				else if(g_Kicucc[id] >= 160) OsszesKirakott[3]++
			}
			sk_log("SellWeapons", fmt("[Sell WEAPON] (%s) %s kirakott a piacra %s targyat %3.2f dolcsiert (ST: %s / NM: %s)", sk_ipidform(id), iName, FegyverInfo[g_Kicucc[id]][GunName], g_Erteke[id],  g_StatTrakBeKi[id] ? "StatTrak* ":"", g_GunNames[g_Kicucc[id]][id]))
		}
	}
	menu_destroy(menu)
	return PLUGIN_HANDLED
}
public cmdDollarEladas(id) {
	new Float:iErtek, iAdatok[32]
	read_args(iAdatok, charsmax(iAdatok))
	remove_quotes(iAdatok)
			
	iErtek = str_to_float(iAdatok)		
			
	if(iErtek > 100000.0) {
		sk_chat(id,  "^1Nem tudsz eladni^3 100000.00$ ^1felett!")
		client_cmd(id, "messagemode DOLLAR_AR")
	}
	else if(iErtek < 0.01) {
		sk_chat(id,  "^1Nem tudsz eladni^3 0.01$ ^1alatt!")
		client_cmd(id, "messagemode DOLLAR_AR")
	}
	else {
		g_Erteke[id] = iErtek + 0.009
		openSeller(id)
	}
}
public openSelectItem(id)
{
	new szMenu[121], String[6]
	formatex(szMenu, charsmax(szMenu), "%s \r[ \wFegyverválasztó \r]", menuprefix)
	new menu = menu_create(szMenu, "hSelectItem");
	new fegyver = sizeof(FegyverInfo)

	for(new i ; i < fegyver; i++)
	{
		if(equal(FegyverInfo[i][GunName], "Unknown"))
			continue;
		if(g_Weapons[i][id] > 0)
		{
			formatex(szMenu, charsmax(szMenu), "\yStatTrak\r* \d(%idb) \w", g_StatTrak[i][id])
			num_to_str(i, String, 5);
			if(strlen(g_GunNames[i][id]) < 1) formatex(szMenu, charsmax(szMenu), "%s%s \r[\y%i \rDB]", g_StatTrak[i][id] >= 1 ? szMenu : "", FegyverInfo[i][GunName], g_Weapons[i][id]);
			else formatex(szMenu, charsmax(szMenu), "%s%s \r[\y%i \rDB]", g_StatTrak[i][id] >= 1 ? szMenu : "", g_GunNames[i][id], g_Weapons[i][id]);
			menu_additem(menu, szMenu, String);
		}
	}

	menu_display(id, menu, 0)
	return PLUGIN_HANDLED
}
public hSelectItem(id, menu, item) {
	if(item == MENU_EXIT){
		menu_destroy(menu)
		return PLUGIN_HANDLED;
	}
	new data[9], szName[64]
	new access, callback
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback)
	new key = str_to_num(data)
	
	if(key < 200)  g_Kicucc[id] = key
	
	g_StatTrakBeKi[id] = false
	g_NameTagBeKi[id] = false
	
	if(g_Kicucc[id] <= 135){
		if(g_StatTrak[g_Kicucc[id]][id] == g_Weapons[g_Kicucc[id]][id]) g_StatTrakBeKi[id] = true
		if(g_Weapons[g_Kicucc[id]][id] == 1 && strlen(g_GunNames[g_Kicucc[id]][id]) > 0) g_NameTagBeKi[id] = true
	}
	openSeller(id)
	
	menu_destroy(menu)
	return PLUGIN_HANDLED
}
public openBuyer1(id) {		
	new szMenu[121]	
	static players[32], temp[10], pnum;	
	get_players(players,pnum,"c")
		
	formatex(szMenu, charsmax(szMenu), "%s \r[ \wPiac / Vásárlás \r]^nDollár: \d%3.2f", menuprefix, g_dollar[id])
	new menu = menu_create(szMenu, "hBuyItems1");
	
	for(new i; i < pnum; i++)
	{	
	if(g_Kirakva[players[i]] == 1 && g_Erteke[players[i]] > 0.00)
		{
			if(!g_NameTagBeKi[players[i]]) formatex(szMenu, charsmax(szMenu), "%s%s \d[\yÁr: \r%3.2f$ \d| \yEladó: \r%s\d]", g_StatTrakBeKi[players[i]] ? "\yStatTrak\r* \w":"", FegyverInfo[g_Kicucc[players[i]]], g_Erteke[players[i]], get_player_name(players[i]));
			else formatex(szMenu, charsmax(szMenu), "%s%s \d[\yÁr: \r%3.2f$ \d| \yEladó: \r%s\d]", g_StatTrakBeKi[players[i]] ? "\yStatTrak\r* \w":"", g_GunNames[g_Kicucc[players[i]]][players[i]], g_Erteke[players[i]], get_player_name(players[i]));
			num_to_str(players[i],temp,charsmax(temp))
			menu_additem(menu, szMenu, temp)
		}
	}
	menu_setprop(menu, MPROP_PERPAGE, 5);
	menu_display(id, menu, 0); 
}
public hBuyItems1(id,menu, item){
	if(item == MENU_EXIT) {
		menu_destroy(menu);
		return PLUGIN_HANDLED
	}
	
	new data[6] ,szName[64],access,callback;
	menu_item_getinfo(menu, item, access, data, charsmax(data), szName, charsmax(szName), callback);
	new player = str_to_num(data);

	new name[32],name2[32]
	get_user_name(id, name, charsmax(name))
	get_user_name(player, name2, charsmax(name2))
	
	if(g_dollar[id] >= g_Erteke[player] && g_Kirakva[player] > 0){
		g_Kirakva[player] = 0
		if(!g_NameTagBeKi[player]) sk_chat(0, "^4^3%s ^1vett egy ^4%s%s ^1fegyvert ^3%s^1-tól ^4%3.2f$^1-ért!", name, g_StatTrakBeKi[player] ? "StatTrak* ":"", FegyverInfo[g_Kicucc[player]][GunName], name2, g_Erteke[player])
		else sk_chat(0, "^4^3%s ^1vett egy ^4%s%s ^1fegyvert ^3%s^1-tól ^4%3.2f$^1-ért!", name, g_StatTrakBeKi[player] ? "StatTrak* ":"", g_GunNames[g_Kicucc[player]][player], name2, g_Erteke[player])
		
		sk_log("SellWeapons", fmt("[BUY WEAPON] (%s) %s vett a piacrol %s targyat %3.2f dolcsiert (ST: %s / NM: %s)", sk_ipidform(id), name, FegyverInfo[g_Kicucc[player]][GunName], g_Erteke[player],  g_StatTrakBeKi[player] ? "StatTrak* ":"", g_GunNames[g_Kicucc[player]][id]))
		new sztime[40];	
		new sztime1[40];	
		format_time(sztime, charsmax(sztime), "%Y.%m.%d - %H:%M:%S", get_systime())
		format_time(sztime1, charsmax(sztime1), "%Y.%m.%d", get_systime())
		log_to_file("vasarlas.txt", "%s vett egy %s fegyvert %s-tól %3.2f$-ért!",name,  g_GunNames[g_Kicucc[player]][player], name2, g_Erteke[player])
		g_dollar[player] += g_Erteke[player]
		g_dollar[id] -= g_Erteke[player]
		g_Erteke[player] = 0.0
		if(g_StatTrakBeKi[player]){
			g_StatTrakBeKi[player] = false
			g_StatTrak[g_Kicucc[player]][id]++
			g_StatTrak[g_Kicucc[player]][player]--
			if(id != player) g_StatTrakKills[g_Kicucc[player]][player] = 0
		}
		if(g_NameTagBeKi[player]){
			g_NameTagBeKi[player] = false
			if(id != player){
				g_GunNames[g_Kicucc[player]][id] = g_GunNames[g_Kicucc[player]][player]
				g_GunNames[g_Kicucc[player]][player][0] = EOS
			}
		}
		g_Weapons[g_Kicucc[player]][id]++
		g_Weapons[g_Kicucc[player]][player]--
		if(g_Weapons[g_Kicucc[player]][player] <= 0)
		{
			new m_WeaponId;
			m_WeaponId = GetWeaponIdFromCSW(FegyverInfo[g_Kicucc[player]][EntName])
			DefaultWeaponIds(player, m_WeaponId);
		}

		g_Kicucc[player] = 0
		OsszesKirakott[0]--
	}
	else {
		sk_chat(id,  "^1Nincs elég dollárod!")
		openBuyer1(id)
	}
	menu_destroy(menu)
	return PLUGIN_HANDLED
}
public openSending(id){
	new szMenu[191]
	formatex(szMenu, charsmax(szMenu), "%s \r[ \wKüldés \r]", menuprefix)
	new menu = menu_create(szMenu, "hSending");
	
	menu_additem(menu, "\yItem \wKüldés", "0", 0);
	//menu_additem(menu, "\yLáda \wKüldés", "1", 0);
	//menu_additem(menu, "\yKulcs \wKüldés", "2", 0);
	menu_additem(menu, "\ySkin \wKüldés", "1", 0);
	format(String, charsmax(String), "Dollár küldés \d[\r%3.2f \d$]", g_dollar[id]);
	menu_additem(menu, String, "2", 0);

	
	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}
public hSending(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}
	
	switch(item)
	{
		case 0: {
			targykuldes[id] = 1
			skinkuldes[id] = 0
			SendMenu(id)
		}
		case 1: {
			targykuldes[id] = 0
			skinkuldes[id] = 1
			openPlayerChooser(id)
		}
		case 2: 
		{ 
			targykuldes[id] = 1;
			skinkuldes[id] = 0;
			openPlayerChooser(id); 
			Send[id] = 888381
		}
	}
	
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public openPlayerChooser(id) {
	new szMenu[121], players[32], pnum, iName[32], szTempid[10]
	get_players(players, pnum)
 
	formatex(szMenu, charsmax(szMenu), "%s \r[ \wJátékosválasztó \r]", menuprefix)
	new menu = menu_create(szMenu, "hPlayerChooser");
 
	for(new i; i<pnum; i++)
	{
		get_user_name(players[i], iName, charsmax(iName))
		num_to_str(players[i], szTempid, charsmax(szTempid))
		menu_additem(menu, iName, szTempid)
	}
	menu_display(id, menu, 0)
}
public hPlayerChooser(id, menu, item)
{
	if(item == MENU_EXIT) {
		targykuldes[id] = 0
		skinkuldes[id] = 0
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	new data[6], szName[64], access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
	g_kUserID[id] = str_to_num(data);

	if(g_Kirakva[id] == 1) {
		sk_chat(id,  "^1Nem küldhetsz semmit amíg valamelyik tárgyad a Piacon van vagy kivan választva!")
		menu_destroy(menu);
		return PLUGIN_HANDLED
	}
	
	if(id == g_kUserID[id]) {
		sk_chat(id,  "^1Magadnak nem küldhetsz semmit!")
		menu_destroy(menu);
		return PLUGIN_HANDLED
	}
	
	if(id == g_kUserID[id]) {
		sk_chat(id,   "^1Magadnak nem küldhetsz semmit!")
		menu_destroy(menu);
		return PLUGIN_HANDLED
	}
	if(targykuldes[id] == 1)
	{
	TempID = str_to_num(data);
	client_cmd(id, "messagemode KMENNYISEG");
	}
	else
	{
		openSendSkinMenu(id)
		skinkuldes[id] = 1
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
    }
public openPlayerChooserMute(id) {
	new szMenu[121], players[32], pnum, iName[32], szTempid[10]
	get_players(players, pnum)
 
	formatex(szMenu, charsmax(szMenu), "%s \r[ \wJátékosválasztó \r]", menuprefix)
	new menu = menu_create(szMenu, "hPlayerChooserMute");
 
	for(new i; i<pnum; i++)
	{
		get_user_name(players[i], iName, charsmax(iName))
		num_to_str(players[i], szTempid, charsmax(szTempid))
		menu_additem(menu, iName, szTempid)
	}
	menu_display(id, menu, 0)
}
public hPlayerChooserMute(id, menu, item)
{
	new data[6], szName[64], access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
	new key = str_to_num(data);

	g_Mute[id][key] = !g_Mute[id][key];
	if(key == 0)
		return;

	sk_chat(id, "Te már %s %s játékost.", g_Mute[id][key] ? "^3nem fogod hallani^4": "^4hallod^3", Player[key][f_PlayerNames])
}
public cmdSendMoney(id)
{
	new Float:iErtek, iAdatok[32], iName[33], tName[33]
	read_args(iAdatok, charsmax(iAdatok))
	remove_quotes(iAdatok)
	
	get_user_name(id, iName, charsmax(iName))
	get_user_name(g_kUserID[id], tName, charsmax(tName))
	
	iErtek = str_to_float(iAdatok)
	
	if(iErtek > 100000.0) {
		sk_chat(id,   "^1Maximum^3 100000.00$^1-t küldhetsz!")
		client_cmd(id, "messagemode DOLLAR_KULDES");
		return PLUGIN_HANDLED;
	}
	else if(iErtek < 0.01) {
		sk_chat(id,   "^1Minimum^3 0.01$^1-t küldhetsz!")
		client_cmd(id, "messagemode DOLLAR_KULDES");
		return PLUGIN_HANDLED;
	}
	if(g_dollar[id] >= iErtek) {
		g_dollar[g_kUserID[id]] += iErtek + 0.009
		g_dollar[id] -= iErtek + 0.009
		sk_chat(0,  "^4^3%s ^1küldött ^3%s^1-nak ^4%3.2f$^1-t!", iName, tName, iErtek + 0.009)
		sk_log("SendDollars", fmt("(%s) %s küldött %s-nak %3.2f dollárt.", sk_ipidform(id), iName, tName, iErtek + 0.009))
	}
	else sk_chat(id,   "^1Nincs elég dollárod!")
	return PLUGIN_HANDLED;
}
public openSendSkinMenu(id) {
	new szMenu[121], bypass = 0;
	formatex(szMenu, charsmax(szMenu), "%s \r[ \wSkin küldés \r]", menuprefix)
	new menu = menu_create(szMenu, "hSendSSkin");
	
	if(strlen(g_GunNames[g_ChooseThings[2][id]][id]) < 1 || !g_NameTagBeKi[id]) formatex(szMenu, charsmax(szMenu), "Fegyver Név: %s\d%s", g_StatTrakBeKiSend[id] ? "\yStatTrak\r* ":"", FegyverInfo[g_ChooseThings[2][id]][GunName]);
	else formatex(szMenu, charsmax(szMenu), "Fegyver Név: %s\d%s", g_StatTrakBeKiSend[id] ? "\yStatTrak\r* ":"", g_GunNames[g_ChooseThings[2][id]][id]);
	menu_additem(menu, szMenu, "1", 0);
	formatex(szMenu, charsmax(szMenu), "\wStatTrak* Tool: \d%s", g_StatTrakBeKiSend[id] ? "BE":"KI")
	menu_additem(menu, szMenu, "2",0)
	formatex(szMenu, charsmax(szMenu), "\wNévcédula: \d%s^n", g_NameTagBeKiSend[id] ? "BE":"KI")
	menu_additem(menu, szMenu, "3",0)
	if(server == 3)
	{
		if(FegyverInfo[g_ChooseThings[2][id]][PiacraHelyezheto] == -2)
			bypass = 1;
	}
	if(FegyverInfo[g_ChooseThings[2][id]][PiacraHelyezheto] == 1 || bypass == 1) 
	menu_additem(menu,"\dKüldés!","4",0)
	else
	menu_additem(menu,"\rEzt az itemet nem tudod elküldeni!","-1",0)
	
	menu_display(id, menu, 0);
	return PLUGIN_HANDLED
}
public hSendSSkin(id, menu, item){
	
	if( item == MENU_EXIT ) {
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	
	new data[9], szName[64]
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
	new key = str_to_num(data);
 
	switch(key)
	{
		case 1: openSendSelItem(id)
		case 2: {
			if(g_StatTrak[g_ChooseThings[2][id]][id] != g_Weapons[g_ChooseThings[2][id]][id]) {
				if(!g_StatTrakBeKiSend[id]) g_StatTrakBeKiSend[id] = true
				else if(g_StatTrakBeKiSend[id]) g_StatTrakBeKiSend[id] = false
			}
			openSendSkinMenu(id)
		}
		case 3: {
			if(g_Weapons[g_ChooseThings[2][id]][id] > 1 && strlen(g_GunNames[g_ChooseThings[2][id]][id]) > 0) {
				if(!g_NameTagBeKiSend[id]) g_NameTagBeKiSend[id] = true
				else if(g_NameTagBeKiSend[id]) g_NameTagBeKiSend[id] = false
			}
			openSendSkinMenu(id)
		}
		case 4: {
			if(g_StatTrakBeKiSend[id] &&  g_StatTrak[g_ChooseThings[2][id]][id] > 0 || !g_StatTrakBeKiSend[id] &&  g_StatTrak[g_ChooseThings[2][id]][id] == 0 || !g_StatTrakBeKiSend[id] &&  g_StatTrak[g_ChooseThings[2][id]][id] > 0) client_cmd(id, "messagemode DARAB")
			else if(g_StatTrakBeKiSend[id] && g_StatTrak[g_ChooseThings[2][id]][id] == 0) {
				g_StatTrakBeKiSend[id] = false
				openSendSkinMenu(id)
				sk_chat(id,   "^1Ehhez a fegyverhez nincs ^3StatTrak* Tool^1-od!")
			}
		}
	}
	menu_destroy(menu)
	return PLUGIN_HANDLED
}
public openSendSelItem(id)
{
	new szMenu[121], String[6]
	formatex(szMenu, charsmax(szMenu), "%s \r[ \wFegyverválasztó \r]", menuprefix)
	new menu = menu_create(szMenu, "hSendSelItem");
	new fegyver = sizeof(FegyverInfo)

	for(new i ; i < fegyver; i++)
	{
		if(equal(FegyverInfo[i][GunName], "Unknown"))
			continue;

		if(g_Weapons[i][id] > 0)
		{
			formatex(szMenu, charsmax(szMenu), "\yStatTrak\r* \d(%idb) \w", g_StatTrak[i][id])
			num_to_str(i, String, 5);
			if(strlen(g_GunNames[i][id]) < 1) formatex(szMenu, charsmax(szMenu), "%s%s \r[\y%i \rDB]", g_StatTrak[i][id] >= 1 ? szMenu : "", FegyverInfo[i][GunName], g_Weapons[i][id]);
			else formatex(szMenu, charsmax(szMenu), "%s%s \r[\y%i \rDB]", g_StatTrak[i][id] >= 1 ? szMenu : "", g_GunNames[i][id], g_Weapons[i][id]);
			menu_additem(menu, szMenu, String);
		}
	}

	menu_display(id, menu, 0)
	return PLUGIN_HANDLED
}
public hSendSelItem(id, menu, item) {
	if(item == MENU_EXIT){
		menu_destroy(menu)
		return PLUGIN_HANDLED;
	}
	new data[9], szName[64]
	new access, callback
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback)
	new key = str_to_num(data)
	
	g_ChooseThings[2][id] = key
	
	g_StatTrakBeKiSend[id] = false
	g_NameTagBeKiSend[id] = false
	
	if(g_StatTrak[g_ChooseThings[2][id]][id] == g_Weapons[g_ChooseThings[2][id]][id]) g_StatTrakBeKiSend[id] = true
	if(g_Weapons[g_ChooseThings[2][id]][id] == 1 && strlen(g_GunNames[g_ChooseThings[2][id]][id]) > 0) g_NameTagBeKiSend[id] = true

	openSendSkinMenu(id)
	
	menu_destroy(menu)
	return PLUGIN_HANDLED
}
new KuldesTip[33];

public SendMenu(id) 
{
	new String[121], menu;
	menu = menu_create("\dKüldés:", "SendHandler");
	
	menu_additem(menu, KuldesTip[id] == 0 ? "Küldés Típusa: \rLáda \y| \dLádakulcs^n":"Küldés Típusa: \dLáda \y| \rLádakulcs^n", "-1",0);//"
	
	if(KuldesTip[id] == 0)
	{
		for(new i;i < sizeof(Keys);i++)
		{
			menu_additem(menu, fmt("\w%s \y[\r%i\w DB\y]", Cases[i][d_Name], Lada[i][id]), fmt("%i",i), 0)
		}
	}
	else
	{
		for(new i;i < sizeof(Keys);i++)
		{
			menu_additem(menu, fmt("\w%s \y[\r%i\w DB\y]", Keys[i][d_Name], LadaK[i][id]), fmt("%i",i), 0)
		}
	}

	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}
public SendHandler(id, Menu, item) {
	if(item == MENU_EXIT)
	{
		targykuldes[id] = 0;
		skinkuldes[id] = 0;
		menu_destroy(Menu);
		return PLUGIN_HANDLED;
		
	}
	
	new Data[9], szName[64];
	new access, callback;
	menu_item_getinfo(Menu, item, access, Data,charsmax(Data), szName,charsmax(szName), callback);
	new Key = str_to_num(Data);
	
	if(Key == -1)
	{
		KuldesTip[id] = !KuldesTip[id];
		SendMenu(id);
		return PLUGIN_HANDLED;
	}

	Send[id] = Key;
	openPlayerChooser(id);
	return PLUGIN_HANDLED;
}
public ObjectSend(id)
{
	new Data[121];
	new SendName[32], TempName[32];
	new sztime[40];	
	new sztime1[40];	
	format_time(sztime, charsmax(sztime), "%Y.%m.%d - %H:%M:%S", get_systime())
	format_time(sztime1, charsmax(sztime1), "%Y.%m.%d", get_systime())
	
	read_args(Data, charsmax(Data));
	remove_quotes(Data);
	get_user_name(id, SendName, 31);
	get_user_name(TempID, TempName, 31);

	if(str_to_num(Data) < 1) 
		return PLUGIN_HANDLED;

	if(Send[id] == 888381 && g_dollar[id] >= str_to_num(Data))
	{
		g_dollar[TempID] += str_to_num(Data);
		g_dollar[id] -= str_to_num(Data);
		sk_log("SendItems", fmt("[SEND DOLLAR] (%s) %s küldött %s-nak %i dollárt.", sk_ipidform(id), SendName, TempName, str_to_num(Data)))
		sk_chat(0, "^1^3%s ^1Küldött ^4%d Dollár^1-t ^3%s^1-nak", SendName, str_to_num(Data), TempName);

		targykuldes[id] = 0;
	}
	if(KuldesTip[id] == 0)
	{
		if(Send[id] >= 0 && Lada[Send[id]][id] >= str_to_num(Data))
		{
		Lada[Send[id]][TempID] += str_to_num(Data);
		Lada[Send[id]][id] -= str_to_num(Data);
		sk_log("SendItems", fmt("[SEND ITEM] (%s) %s küldött %s-nak %i darab %s ládát.", sk_ipidform(id), SendName, TempName, str_to_num(Data), Cases[Send[id]][d_Name]))
		sk_chat(0, "%s Küldött %d %s-t %s-nak", SendName, str_to_num(Data), Cases[Send[id]][d_Name], TempName);
		}
	}
	else
	{
		if(Send[id] >= 0 && LadaK[Send[id]][id] >= str_to_num(Data))
		{
			LadaK[Send[id]][TempID] += str_to_num(Data);
			LadaK[Send[id]][id] -= str_to_num(Data);
			sk_log("SendItems", fmt("[SEND ITEM] (%s) %s küldött %s-nak %i darab %s ládakulcsot.", sk_ipidform(id), SendName, TempName, str_to_num(Data), Keys[Send[id]][d_Name]))
			sk_chat(0, "%s Küldött %d %s-t %s-nak", SendName, str_to_num(Data), Keys[Send[id]][d_Name], TempName);
		}
	}
	
	
	return PLUGIN_HANDLED;
}
public Mission_Reward(id, Float:Money, Keys, Keynum, Cases, Casenum)
{
	g_dollar[id] += Money;
	LadaK[Keynum][id] += Keys;
	Lada[Casenum][id] += Cases;
}
public cmdDarabLoad(id)
{
	new iErtek, iAdatok[32], iName[33], tName[33]
	read_args(iAdatok, charsmax(iAdatok))
	remove_quotes(iAdatok)
	
	get_user_name(id, iName, charsmax(iName))
	get_user_name(g_kUserID[id], tName, charsmax(tName))
	
	iErtek = str_to_num(iAdatok)
	
	if(iErtek < 1) {
		sk_chat(id,   "^1Minimum csak 1 darab skint küldhetsz!")
		return PLUGIN_HANDLED
	}

	else if(skinkuldes[id] == 1) {
		if(g_Weapons[g_ChooseThings[2][id]][id] >= iErtek) {
			if(g_StatTrakBeKiSend[id] && g_StatTrak[g_ChooseThings[2][id]][id] >= iErtek){
				g_StatTrak[g_ChooseThings[2][id]][g_kUserID[id]] += iErtek
				g_StatTrak[g_ChooseThings[2][id]][id] -= iErtek
				g_StatTrakKills[g_ChooseThings[2][id]][id] = 0
			}
			else if(g_StatTrakBeKiSend[id] && g_StatTrak[g_ChooseThings[2][id]][id] < iErtek){
				g_StatTrakBeKiSend[id] = false
				sk_chat(id,   "^1Ehhez a fegyverhez nincs elég ^3StatTrak Tool^1-od!")
				return PLUGIN_HANDLED
			}
			if(g_NameTagBeKiSend[id] && strlen(g_GunNames[g_ChooseThings[2][id]][id]) > 0){
				g_GunNames[g_ChooseThings[2][id]][g_kUserID[id]] = g_GunNames[g_ChooseThings[2][id]][id]
				g_GunNames[g_ChooseThings[2][id]][id][0] = EOS
			}
			else if(g_NameTagBeKiSend[id] && strlen(g_GunNames[g_ChooseThings[2][id]][id]) <= 0){
				g_NameTagBeKiSend[id] = false
				sk_chat(id,   "^1Ez a fegyver nincs elnevezve!")
				return PLUGIN_HANDLED
			}
			if(!g_NameTagBeKiSend[id]) 
			{
				sk_chat(0,  "^4^3%s ^1küldött ^3%s^1-nak ^3%i ^1DB ^4%s%s ^1fegyvert!", iName, tName, iErtek, g_StatTrakBeKiSend[id] ? "StatTrak* ":"", FegyverInfo[g_ChooseThings[2][id]][GunName])
				sk_log("SendItems", fmt("[SEND WEAPON] (%s) %s küldött %s-nak %i darab %s fegyvert (%s).", sk_ipidform(id), iName, tName, iErtek, g_StatTrakBeKiSend[id] ? "StatTrak* ":"",  FegyverInfo[g_ChooseThings[2][id]][GunName]))
			}
			else
			{
				sk_chat(0,  "^4^3%s ^1küldött ^3%s^1-nak ^3%i ^1DB ^4%s%s ^1fegyvert!", iName, tName, iErtek, g_StatTrakBeKiSend[id] ? "StatTrak* ":"", g_GunNames[g_ChooseThings[2][id]][g_kUserID[id]])
				sk_log("SendItems", fmt("[SEND WEAPON] (%s) %s küldött %s-nak %i darab %s fegyvert (%s).", sk_ipidform(id), iName, tName, iErtek, g_StatTrakBeKiSend[id] ? "StatTrak* ":"", g_GunNames[g_ChooseThings[2][id]][g_kUserID[id]], FegyverInfo[g_ChooseThings[2][id]][GunName]))
			} 
			new sztime[40];	
			new sztime1[40];	
			format_time(sztime, charsmax(sztime), "%Y.%m.%d - %H:%M:%S", get_systime())
			format_time(sztime1, charsmax(sztime1), "%Y.%m.%d", get_systime())

			g_Weapons[g_ChooseThings[2][id]][g_kUserID[id]] += iErtek
			g_Weapons[g_ChooseThings[2][id]][id] -= iErtek
			if(g_Weapons[g_ChooseThings[2][id]][id] <= 0)
			{
				new WeaponId;
				WeaponId = GetWeaponIdFromCSW(FegyverInfo[g_ChooseThings[2][id]][EntName]);
				DefaultWeaponIds(id, WeaponId);
			}
			g_StatTrakBeKiSend[id] = false
			g_NameTagBeKiSend[id] = false
			skinkuldes[id] = 0
		}
		else sk_chat(id,   "^1Nincs elég Fegyvered!")
	}
	return PLUGIN_HANDLED;
}

public Hook_Say(id)
{
    new Message[512], Status[16], Num[5], nev[32];
    get_user_name(id, nev, charsmax(nev));
    
    read_args(Message, charsmax(Message));
    remove_quotes(Message);
    new Message_Size = strlen(Message);
    //get_players(players, inum, "ch");
		CallGalileo(id, Message)

		if(!sk_get_logged(id))
		{
			sk_chat(id, "A chat használatához be kell jelentkezned, vagy regisztrálnod! ^3(^4T betű ^1/ ^4/menu^3)")
			return PLUGIN_HANDLED;
		}

    if(Message[0] == '@' || equal (Message, "") || equal (Message, "/admin"))// || Message[0] == '/')
        return PLUGIN_HANDLED;

		if(containi(Message, "%s") != -1)
		{
			sk_chat(id, "Tilos a Chat buggoltatás!")
			return PLUGIN_HANDLED;
		}
  
    if(!is_user_alive(id))
        Status = "*Halott* ";

		new len, adminlen;
	
		len += formatex(String[len], charsmax(String)-len, "^1%s", Status);

		new VipString[64], AdminString[128]
		// if(g_Vip[id] == 1)
		// 	len += formatex(VipString[len], charsmax(VipString)-len, " ^1| ^4V.I.P^3");	
		// if(Vip[id][isPremium] == 1)
		// 	len += formatex(VipString[len], charsmax(VipString)-len, " ^1| ^4Prémium VIP^3");	

		if(strlen(g_Chat_Prefix[id]) > 0 && Player[id][AdminIll] == 0 )
			adminlen += formatex(AdminString[adminlen], charsmax(AdminString)-adminlen, "^4%s ^1| ^4%s", (Player[id][AdminIll] == 0 ? Admin_Permissions[g_Admin_Level[id]][0] : Admin_Permissions[0][0]), g_Chat_Prefix[id]);
		else if(strlen(g_Chat_Prefix[id]) > 0 && Player[id][AdminIll] == 0)
			adminlen += formatex(AdminString[adminlen], charsmax(AdminString)-adminlen, "^4%s", g_Chat_Prefix[id]);
		else if(g_Admin_Level[id] == 0 && strlen(g_Chat_Prefix[id]) > 0)
			adminlen += formatex(AdminString[adminlen], charsmax(AdminString)-adminlen, "^4%s", g_Chat_Prefix[id]);
		else
			adminlen += formatex(AdminString[adminlen], charsmax(AdminString)-adminlen, "^4%s", (Player[id][AdminIll] == 0 ? Admin_Permissions[g_Admin_Level[id]][0] : Admin_Permissions[0][0]));

		len += formatex(String[len], charsmax(String)-len, "^3[^4%s ^1| ^4%s^3%s] ^1» ", AdminString, Rangok[Rang[id]][RangName], Vip[id][isPremium] == 1 ? " ^1| ^4Prémium VIP^3" : "");

		if(Vip[id][isPremium] == 1 || (g_Admin_Level[id] > 0 && Player[id][AdminIll] == 0))
			len += formatex(String[len], charsmax(String)-len, "^3%s:^4", nev);
		else
			len += formatex(String[len], charsmax(String)-len, "^3%s:^1", nev);
			
    format(Message, charsmax(Message), "%s %s", String, Message);


    for(new i; i <= g_Maxplayers; i++){
        if(!is_user_connected(i))
            continue;
        if(cs_get_user_team(id) == CS_TEAM_CT)
            client_print_color(i, id, Message);
        else if(cs_get_user_team(id) == CS_TEAM_T)
            client_print_color(i, id, Message);
        else
            client_print_color(i, id, Message);
    }
    
    return PLUGIN_HANDLED;
}
public CallGalileo(id, words[])
{
	if(equal (words, "startvote"))
	{
		if( callfunc_begin("AdminVote", "galileo.amxx") == 1 )
		{
			callfunc_push_int(id)
			callfunc_end()
		}
	}
	else if(equal (words, "/startvote"))
	{
		if( callfunc_begin("AdminVote", "galileo.amxx") == 1 )
		{
			callfunc_push_int(id)
			callfunc_end()
		}
	}
	else if(equal (words, "rtv"))
	{
		if( callfunc_begin("cmd_say", "galileo.amxx") == 1 )
		{
			callfunc_push_int(id)
			callfunc_end()
		}
	}
	else if(equal (words, "nom"))
	{
		if( callfunc_begin("cmd_say", "galileo.amxx") == 1 )
		{
			callfunc_push_int(id)
			callfunc_end()
		}
	}
	else if(equal (words, "/rtv"))
	{
		if( callfunc_begin("cmd_say", "galileo.amxx") == 1 )
		{
			callfunc_push_int(id)
			callfunc_end()
		}
	}
	else if(equal (words, "/nom"))
	{
		if( callfunc_begin("cmd_say", "galileo.amxx") == 1 )
		{
			callfunc_push_int(id)
			callfunc_end()
		}
	}
	else if(equal (words, "nextmap"))
	{
		if( callfunc_begin("sayNextMap", "galileo.amxx") == 1 )
		{
			callfunc_push_int(id)
			callfunc_end()
		}
	}
	else if(equal (words, "timeleft"))
	{
		if( callfunc_begin("sayTimeLeft", "galileo.amxx") == 1 )
		{
			callfunc_push_int(id)
			callfunc_end()
		}
	}
	else if(equal (words, "thetime"))
	{
		if( callfunc_begin("sayTheTime", "galileo.amxx") == 1 )
		{
			callfunc_push_int(id)
			callfunc_end()
		}
	}
	else if(equal (words, "currentmap"))
	{
		if( callfunc_begin("sayCurrentMap", "galileo.amxx") == 1 )
		{
			callfunc_push_int(id)
			callfunc_end()
		}
	}
	else if(equal (words, "recentmaps"))
	{
		if( callfunc_begin("cmd_listrecent", "galileo.amxx") == 1 )
		{
			callfunc_push_int(id)
			callfunc_end()
		}
	}
	else if(equal (words, "nm"))
	{
		if( callfunc_begin("sayNextMap", "galileo.amxx") == 1 )
		{
			callfunc_push_int(id)
			callfunc_end()
		}
	}
	else if(equal (words, "tl"))
	{
		if( callfunc_begin("sayTimeLeft", "galileo.amxx") == 1 )
		{
			callfunc_push_int(id)
			callfunc_end()
		}
	}

}
public fegyvermenu(id)
{
	if(fegyvermenus == 0)
		return PLUGIN_HANDLED;

		if(Buy[id]){
        sk_chat(id,  "^1Ebben a körben már választottál fegyvert!");
        return PLUGIN_CONTINUE;
    } 
    
    new menu = menu_create(fmt("%s \w Fegyvermenü", menuprefixwhmt), "handler");

    if(strlen(g_GunNames[Selectedgun[M4A1][id]][id]) > 1) 
    {
        formatex(String, charsmax(String), "\r[\w*~\y%s\w~*\r]", g_GunNames[Selectedgun[M4A1][id]][id]);
        menu_additem(menu, String, "1", 0);
    }
    else 
    {
        formatex(String, charsmax(String), "\r[\w*~\y%s\w~*\r]", FegyverInfo[Selectedgun[M4A1][id]][GunName]);
        menu_additem(menu, String, "1", 0);
    }
    if(strlen(g_GunNames[Selectedgun[AK47][id]][id]) > 1) 
    {
        formatex(String, charsmax(String), "\r[\w*~\y%s\w~*\r]", g_GunNames[Selectedgun[AK47][id]][id]);
        menu_additem(menu, String, "2", 0);
    }
    else 
    {
        formatex(String, charsmax(String), "\r[\w*~\y%s\w~*\r]", FegyverInfo[Selectedgun[AK47][id]][GunName]);
        menu_additem(menu, String, "2", 0);
    }
    if(strlen(g_GunNames[Selectedgun[AWP][id]][id]) > 1) 
    {
        formatex(String, charsmax(String), "\r[\w*~\y%s\w~*\r]", g_GunNames[Selectedgun[AWP][id]][id]);
        menu_additem(menu, String, "3", 0);
    }
    else 
    {
        formatex(String, charsmax(String), "\r[\w*~\y%s\w~*\r]", FegyverInfo[Selectedgun[AWP][id]][GunName]);
        menu_additem(menu, String, "3", 0);
    }
    menu_additem(menu, "\r[\w*~\yMachineGun\w~*\r]", "4", 0);
    menu_additem(menu, "\r[\w*~\yAUG\w~*\r]", "5", 0);
    menu_additem(menu, "\r[\w*~\yFAMAS\w~*\r]", "6", 0);
    menu_additem(menu, "\r[\w*~\yGALIL\w~*\r]", "7", 0);
    menu_additem(menu, "\r[\w*~\yMP5\w~*\r]", "8", 0);
    menu_additem(menu, "\r[\w*~\yXM1014 Shotgun\w~*\r]", "9", 0);
    menu_additem(menu, "\r[\w*~\yM3 Shotgun\w~*\r]", "10", 0);
    menu_additem(menu, "\r[\w*~\yScout\w~*\r]", "11", 0);
    menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
    menu_display(id, menu);
    return PLUGIN_CONTINUE;
}
public handler(id, menu, item)
{
    if( item == MENU_EXIT )
    {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }
    new data[6], szName[64];
    new access, callback;
    menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
    new key = str_to_num(data);
    switch(key)
    {
    
        case 1:
        {
            
            give_player_grenades(id);
            give_item(id, "weapon_knife");
            set_user_armor(id, 100);
            give_item(id, "weapon_m4a1");
            give_item(id, "item_kevlar");
            
            give_item(id, "ammo_556nato");
            give_item(id, "ammo_556nato");
            give_item(id, "ammo_556nato");
            sk_chat(id,  "^1Kaptál egy ^3M4A1^1 fegyvert!");
        }
        case 2:
        {
            
            give_player_grenades(id);
            give_item(id, "weapon_knife");
            give_item(id, "weapon_ak47");
            give_item(id, "item_kevlar");
            
            give_item(id, "ammo_762nato");
            give_item(id, "ammo_762nato");
            set_user_armor(id, 100);
            give_item(id, "ammo_762nato");
            sk_chat(id,  "^1Kaptál egy ^3AK47^1 fegyvert!");
        }
        case 3:
        {
            new CsTeams:userTeam = cs_get_user_team(id);
            new Players[32], iNum;
            new tt_num = 0;
            new ct_num = 0;
            get_players(Players, iNum, "ch");
            for(new i=0;i<iNum;i++)
            {
                if(cs_get_user_team(Players[i])==CS_TEAM_T)
                    {tt_num++;}
                else if(cs_get_user_team(Players[i])==CS_TEAM_CT)
                {
                    ct_num++;
                }
            }
            if (tt_num >=4 && ct_num >= 4)
            {
                if(userTeam == CS_TEAM_CT)
                {
                    if(gWPCT < 2)
                    {
                        
                        give_player_grenades(id);
                        give_item(id, "weapon_knife");
                        give_item(id, "weapon_awp");
                        give_item(id, "item_kevlar");
                        
                        give_item(id, "ammo_338magnum");
                        give_item(id, "ammo_338magnum");
                        set_user_armor(id, 100);
                        give_item(id, "ammo_338magnum");
                        sk_chat(id,  "^1Kaptál egy ^3AWP^1 fegyvert!");
                        gWPCT++;
                    }
                    else
                    {
                        client_print(id, print_center, "Csak 2 ember wpzhet csapatonkent!");
                        fegyvermenu(id);
                    }
                }
                if(userTeam == CS_TEAM_T)
                {
                    if(gWPTE < 2)
                    {
                        
                        give_player_grenades(id);
                        give_item(id, "weapon_knife");
                        give_item(id, "weapon_awp");
                        set_user_armor(id, 100);
                        give_item(id, "item_kevlar");
                        
                        give_item(id, "ammo_338magnum");
                        give_item(id, "ammo_338magnum");
                        give_item(id, "ammo_338magnum");
                        sk_chat(id,  "^1Kaptál egy ^3AWP^1 fegyvert!");
                        gWPTE++;
                    }
                    else
                    {
                        client_print(id, print_center, "Csak 2 ember wpzhet csapatonkent!");
                        fegyvermenu(id);
                    }
                }
            }
            else
            {
                client_print(id, print_center, "Csak 4vs4-től választhatod az AWP csomagot!");
                fegyvermenu(id);
            }
            
        }
        case 4:
        {
            
            give_player_grenades(id);
            give_item(id, "weapon_knife");
            
            give_item(id, "weapon_m249");
            give_item(id, "item_kevlar");
            give_item(id, "ammo_556natobox");
            give_item(id, "ammo_556natobox");
            set_user_armor(id, 100);
            give_item(id, "ammo_556natobox");
            sk_chat(id,  "^1Kaptál egy ^3MachineGun^1 fegyvert!");
        }  
        case 5:
        {
            
            give_player_grenades(id);
            give_item(id, "weapon_knife");
            
            give_item(id, "weapon_aug");
            give_item(id, "item_kevlar");
            give_item(id, "ammo_556nato");
            give_item(id, "ammo_556nato");
            set_user_armor(id, 100);
            give_item(id, "ammo_556nato");
            sk_chat(id,  "^1Kaptál egy ^3AUG^1 fegyvert!");
        }
        case 6:
        {
            
            give_player_grenades(id);
            give_item(id, "weapon_knife");
            
            give_item(id, "weapon_famas");
            give_item(id, "item_kevlar");
            give_item(id, "ammo_556nato");
            set_user_armor(id, 100);
            give_item(id, "ammo_556nato");
            give_item(id, "ammo_556nato");
            sk_chat(id,  "^1Kaptál egy ^3Famas^1 fegyvert!");
        }
        case 7:
        {
            
            give_player_grenades(id);
            give_item(id, "weapon_knife");
            
            give_item(id, "weapon_galil");
            give_item(id, "ammo_556nato");
            give_item(id, "item_kevlar");
            set_user_armor(id, 100);
            give_item(id, "ammo_556nato");
            give_item(id, "ammo_556nato");
            sk_chat(id,  "^1Kaptál egy ^3Galil^1 fegyvert!");
        }
        case 8:
        {
            
            give_player_grenades(id);
            give_item(id, "item_kevlar");
            give_item(id, "weapon_knife");
            
            give_item(id, "weapon_mp5navy");
            give_item(id, "ammo_9mm");
            give_item(id, "ammo_9mm");
            set_user_armor(id, 100);
            give_item(id, "ammo_9mm");
            sk_chat(id,  "^1Kaptál egy ^3SMG^1 fegyvert!");
        }
        case 9:
        {
            
            give_player_grenades(id);
            give_item(id, "weapon_knife");
            
            give_item(id, "weapon_xm1014");
            give_item(id, "ammo_buckshot");
            set_user_armor(id, 100);
            give_item(id, "item_kevlar");
            give_item(id, "ammo_buckshot");
            give_item(id, "ammo_buckshot");
            sk_chat(id,  "^1Kaptál egy ^3AutoShotgun^1 fegyvert!");
        }
        case 10:
        {
            
            give_player_grenades(id);
            give_item(id, "weapon_knife");
            
            give_item(id, "item_kevlar");
            set_user_armor(id, 100);
            give_item(id, "weapon_m3");
            give_item(id, "ammo_buckshot");
            give_item(id, "ammo_buckshot");
            give_item(id, "ammo_buckshot");
            sk_chat(id,  "^1Kaptál egy ^3Shotgun^1 fegyvert!");
        }
        case 11:
        {
            
            give_player_grenades(id);
            give_item(id, "weapon_knife");
            
            give_item(id, "item_kevlar");
            set_user_armor(id, 100);
            give_item(id, "weapon_scout");
            give_item(id, "ammo_762nato");
            give_item(id, "ammo_762nato");
            give_item(id, "ammo_762nato");
            sk_chat(id,  "^1Kaptál egy ^3Scout^1 fegyvert!");
        }
        case 12:
        {
            
            give_player_grenades(id);
            give_item(id, "item_kevlar");
            give_item(id, "weapon_knife");
            
            give_item(id, "weapon_mac10");
            give_item(id, "ammo_45acp");
            give_item(id, "ammo_45acp");
            set_user_armor(id, 100);
            give_item(id, "ammo_45acp");
            sk_chat(id,  "^1Kaptál egy ^3Pityókahámozó^1 fegyvert!");
        }
        case 13:
        {
            
            give_player_grenades(id);
            give_item(id, "item_kevlar");
            give_item(id, "weapon_knife");
            
            give_item(id, "weapon_tmp");
            give_item(id, "ammo_9mm");
            give_item(id, "ammo_9mm");
            set_user_armor(id, 100);
            give_item(id, "ammo_9mm");
            sk_chat(id,  "^1Kaptál egy ^3Pityókahámozó^1 fegyvert!");
        }
    }
    return PLUGIN_HANDLED;
}

stock give_player_grenades(index)
{
    give_item(index, "item_assaultsuit")
    	if(!equal(FegyoMapName, "cs_max_fix"))
		give_item(index, "weapon_hegrenade");
    give_item(index, "weapon_flashbang");
    give_item(index, "weapon_flashbang");
    give_item(index, "item_thighpack");
    give_item(index, "weapon_deagle");
    Buy[index] = index;
    cs_set_user_bpammo(index,CSW_DEAGLE,50);
    
}
public Pisztolyok(id)
{
    
    formatex(String, charsmax(String), "\r[AV-HB] Fegyvermenü", menuprefix);
    new menu = menu_create(String, "Pisztolyok_h");
    if(strlen(g_GunNames[Selectedgun[DEAGLE][id]][id]) > 1) 
        {
        formatex(String, charsmax(String), "\r[\w*~\y%s\w~*\r]", g_GunNames[Selectedgun[DEAGLE][id]][id]);
        menu_additem(menu, String, "1", 0);
        }
        else 
        {
        formatex(String, charsmax(String), "\r[\w*~\y%s\w~*\r]", FegyverInfo[Selectedgun[DEAGLE][id]][GunName]);
        menu_additem(menu, String, "1", 0);
    }
    menu_additem(menu, "\r[\w*~\yUSP\w~*\r]", "2", 0);
    menu_additem(menu, "\r[\w*~\yGLOCK\w~*\r]", "3", 0);
    
    menu_display(id, menu, 0);
    
    return PLUGIN_HANDLED;
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
            Buy[id] = 1;
            cs_set_user_bpammo(id,CSW_DEAGLE,50);
        }
        case 2:
        {
            give_item(id, "weapon_knife");
            Buy[id] = 1;
            give_item(id, "weapon_usp");
            cs_set_user_bpammo(id,CSW_USP,50);
        }
        case 3:
        {
            give_item(id, "weapon_knife");
            give_item(id, "weapon_glock18");
            Buy[id] = 1;
            cs_set_user_bpammo(id,CSW_GLOCK18,100);
        }
    }
}
public client_putinserver(id)
{
	get_user_name(id, Player[id][f_PlayerNames], 64);
	get_user_authid(id, Player[id][steamid], 32);
	
	if(containi(Player[id][steamid], "VALVE_ID_LAN")  != -1 || containi(Player[id][steamid], "STEAM_ID_LAN") != -1 || containi(Player[id][steamid], "HLTV") != -1)
	{
		sk_chat(0, "Admin: ^4Anti-Cheat^1 kirúgta a szerverről ^4%s^1 játékost, ^4Érvénytelen Kliens^1 indokkal.", Player[id][f_PlayerNames])
		server_cmd("kick #%d ^"Ez a kliens nem kompatiliblis a szerverrel! Tölts le egy másikat innen: www.herboy.hu/kliens.exe!^"", get_user_userid(id));
	}
	Korvegi[id] = true;
	MusicBoxEquiped[id] = -1;
	g_Vip[id] = 0
	g_VipTime[id] = 0;
	rXP[id] = 0.0;
	rELO[id] = 0;
	eloELO[id] = 0;
	eloXP[id] = 0.0;
	Wins[id] = 0;
	Rang[id] = 0;
	g_Id[id] = 0;
	oles[id] = 0;
	hl[id] = 0;
	hs[id] = 0;
	Player[id][SSzint] = 0;

	EXPT[id] = 0.0;
	erdem[id] = 0;
	g_dollar[id] = 0.0;
	g_Erteke[id] = 0.0;
	g_ASD[id] = 1;
	g_Tools[0][id] = 0;
	targykuldes[id] = 0;
	Vane[id] = 0;
	szinesmenu[id] = 1;
	g_tester[id] = 0;
	skinkuldes[id] = 0;
	Vip[id][PremiumTime] = 0;
	Vip[id][isPremium] = 0;
	targyakfogadasa[id] = 1;
	g_Tools[1][id] = 0;
	g_Kirakva[id] = 0;
	g_Admin_Level[id] = 0;
	Questing[id][is_Questing] = 0;

	Player_Vip[id][v_keydrop] = 1;
	Player_Vip[id][v_casedrop] = 1;
	Player_Vip[id][v_moneydrop] = 1;
	Player_Vip[id][v_time] = 0;

	VanPrefix[id] = 0;
	NyeremenyOles[id] = 0;
	Ajandekcsomag[id] = 0;
	

	new weps = sizeof(FegyverInfo)
	for(new i;i < weps; i++)
		g_Weapons[i][id] = 0;
	for(new i;i < weps; i++)
		g_StatTrak[i][id] = 0;
	for(new i;i < weps; i++)
		g_StatTrakKills[i][id] = 0;
	for(new i;i < weps; i++)
		g_GunNames[i][id] = "";
	for(new i;i < sizeof(Cases); i++)
		Lada[i][id] = 0;
	for(new i;i < sizeof(Cases); i++)
		LadaK[i][id] = 0;
	
	for(new i;i < sizeof(MusicBox); i++)
		MusicBoxBuyed[i][id] = 0;

	MusicBoxEquiped[id] = 0;

	if(g_Kirakva[id] > 0) {
		if(g_Kicucc[id] > 0 && g_Kicucc[id] <= 135) OsszesKirakott[0]--
		else if(g_Kicucc[id] >= 136 && g_Kicucc[id] <= 147) OsszesKirakott[1]--
		else if(g_Kicucc[id] >= 148 && g_Kicucc[id] <= 159) OsszesKirakott[2]--
		else if(g_Kicucc[id] >= 160) OsszesKirakott[3]--
		g_Erteke[id] = 0.0
		g_Kicucc[id] = 0
		g_Kirakva[id] = 0
		g_StatTrakBeKi[id] = false
		g_NameTagBeKi[id] = false
	}

	for(new i = 0; i <= g_Maxplayers; ++i)
    g_Mute[id][i] = 0

	client_cmd(id, "fs_lazy_precache 1;gl_fog 0");
	engclient_cmd(id, "fs_lazy_precache 1;gl_fog 0");
	console_print(id, "-------------------------------------------------------------------------")
	console_print(id, "[MultiMod - Precache Manager] Dinamikus betoltorendszer aktivalva!")
	console_print(id, "[MultiMod - Fog Manager] Kod eltuntetve!")
	console_print(id, "[MultiMod - Account Manager] Profil keszen all a betoltesre!")
	console_print(id, "-------------------------------------------------------------------------")
}
public client_logoff(id)
{
	Korvegi[id] = true;
	MusicBoxEquiped[id] = -1;
	g_Vip[id] = 0
	g_VipTime[id] = 0;
	rXP[id] = 0.0;
	rELO[id] = 0;
	eloELO[id] = 0;
	eloXP[id] = 0.0;
	Wins[id] = 0;
	Rang[id] = 0;
	g_Id[id] = 0;
	oles[id] = 0;
	hl[id] = 0;
	hs[id] = 0;
	Player[id][SSzint] = 0;

	EXPT[id] = 0.0;
	erdem[id] = 0;
	g_dollar[id] = 0.0;
	g_Erteke[id] = 0.0;
	g_ASD[id] = 1;
	g_Tools[0][id] = 0;
	targykuldes[id] = 0;
	Vane[id] = 0;
	szinesmenu[id] = 1;
	g_tester[id] = 0;
	skinkuldes[id] = 0;
	Vip[id][PremiumTime] = 0;
	Vip[id][isPremium] = 0;
	targyakfogadasa[id] = 1;
	g_Tools[1][id] = 0;
	g_Kirakva[id] = 0;
	g_Admin_Level[id] = 0;
	Questing[id][is_Questing] = 0;

	Player_Vip[id][v_keydrop] = 1;
	Player_Vip[id][v_casedrop] = 1;
	Player_Vip[id][v_moneydrop] = 1;
	Player_Vip[id][v_time] = 0;

	VanPrefix[id] = 0;
	NyeremenyOles[id] = 0;
	Ajandekcsomag[id] = 0;
	

	new weps = sizeof(FegyverInfo)
	for(new i;i < weps; i++)
		g_Weapons[i][id] = 0;
	for(new i;i < weps; i++)
		g_StatTrak[i][id] = 0;
	for(new i;i < weps; i++)
		g_StatTrakKills[i][id] = 0;
	for(new i;i < weps; i++)
		g_GunNames[i][id] = "";
	for(new i;i < sizeof(Cases); i++)
		Lada[i][id] = 0;
	for(new i;i < sizeof(Cases); i++)
		LadaK[i][id] = 0;
	
	for(new i;i < sizeof(MusicBox); i++)
		MusicBoxBuyed[i][id] = 0;

	MusicBoxEquiped[id] = 0;

	if(g_Kirakva[id] > 0) {
		if(g_Kicucc[id] > 0 && g_Kicucc[id] <= 135) OsszesKirakott[0]--
		else if(g_Kicucc[id] >= 136 && g_Kicucc[id] <= 147) OsszesKirakott[1]--
		else if(g_Kicucc[id] >= 148 && g_Kicucc[id] <= 159) OsszesKirakott[2]--
		else if(g_Kicucc[id] >= 160) OsszesKirakott[3]--
		g_Erteke[id] = 0.0
		g_Kicucc[id] = 0
		g_Kirakva[id] = 0
		g_StatTrakBeKi[id] = false
		g_NameTagBeKi[id] = false
	}

	for(new i = 0; i <= g_Maxplayers; ++i)
    g_Mute[id][i] = 0

	client_cmd(id, "fs_lazy_precache 1;gl_fog 0");
	engclient_cmd(id, "fs_lazy_precache 1;gl_fog 0");
	console_print(id, "-------------------------------------------------------------------------")
	console_print(id, "[MultiMod - Precache Manager] Dinamikus betoltorendszer aktivalva!")
	console_print(id, "[MultiMod - Fog Manager] Kod eltuntetve!")
	console_print(id, "[MultiMod - Account Manager] Profil keszen all a betoltesre!")
	console_print(id, "-------------------------------------------------------------------------")
}

public CmdSetVIP(id, level, cid)
{
	if(!str_to_num(Admin_Permissions[g_Admin_Level[id]][3])){
		client_print(id, print_console, "Nincs elérhetőseg ehhez a parancshoz!");
	
		return PLUGIN_HANDLED;
	}
	
	new Arg1[32], Arg2[32], Arg_Int[2];
	new szName[32];
	get_user_name(id, szName, charsmax(szName));
	new sztime[40];	
	read_argv(1, Arg1, charsmax(Arg1));
	read_argv(2, Arg2, charsmax(Arg2));
	
	Arg_Int[0] = str_to_num(Arg1);
	Arg_Int[1] = str_to_num(Arg2);
	
	if(Arg_Int[0] < 1 || Arg_Int[1] < 0)
		return PLUGIN_HANDLED;
	
	new Is_Online = Check_Id_Online(Arg_Int[0]);
	
	if(Is_Online){
		if(Arg_Int[1] > 0)
		{	
			g_VipTime[Is_Online] = get_systime()+86400*Arg_Int[1]
			format_time(sztime, charsmax(sztime), "%Y.%m.%d - %H:%M:%S", g_VipTime[id])
			sk_chat(0, "Játékos: ^3%s ^1(#^3%d^1) | VIP Tagságot kapott ^3%d^1 napra! ^3%s^1(#^3%d^1) által!", Player[Is_Online][f_PlayerNames], Arg_Int[0], Arg_Int[1], szName, g_Id[id]);
			sk_chat(Is_Online, "Kaptál^4 %d Napra^1 szóló‚ ^3VIPet^1. ^3Lejár ekkor: ^4%s", Arg_Int[1], sztime);	
		}
		else 
		{
			sk_chat(0, "Játékos: ^3%s ^1(#^3%d^1) | VIP Tagság megvonva! ^3%s^1(#^3%d^1) által!", Player[Is_Online][f_PlayerNames], Arg_Int[0], szName, g_Id[id]);	
			g_VipTime[Is_Online] = 0;
		}
	}
	else
		client_print(id, print_console, "A jatekos nincs fent!");
	
	
	return PLUGIN_HANDLED;
}
public cmdTopByKills()
	{
		SQL_ThreadQuery(g_SqlTuple, "top3ThreadaK","SELECT * FROM `profiles` ORDER BY NyOles3 DESC LIMIT 15");
		
		return PLUGIN_HANDLED;
	}
	public TopOles(id)
	{
		static menu[3000];
		new len;
		
		len += formatex(menu[len], charsmax(menu) - len, "<head><meta charset=^"UTF-8^"></head><center><table border=^"1^">");
		
		len += formatex(menu[len], charsmax(menu) - len, "<body bgcolor=#000000><table style=^"color: #FF0000^">");
		
		len += formatex(menu[len], charsmax(menu) - len, "<td>Jatekosnev</td>");
		
		len += formatex(menu[len], charsmax(menu) - len, "<td>Oles</td>");
		
		for(new i; i < 15; i++)
		{
			len += formatex(menu[len], charsmax(menu) - len, "<tr><td>%02d.  %s(#%i)</td>", i+1, nyolesNev[i], nyid[i]);
			
			len += formatex(menu[len], charsmax(menu) - len, "<td>%d</td></tr>", nyolesl[i]);
		}
		len += formatex(menu[len], charsmax(menu) - len, "<body bgcolor=#000000><table style=^"color: #32CD32^">");
		len += formatex(menu[len], charsmax(menu) - len, "<td>1. Hely: <br>Steames PUBG Account - </td>");
		len += formatex(menu[len], charsmax(menu) - len, "<td>2. Hely: <br>Gamer egér - </td>");
		len += formatex(menu[len], charsmax(menu) - len, "<td>3. Hely: <br>1 Hónap Prémium VIP</td>");
		
		len += formatex(menu[len], charsmax(menu) - len, "<body bgcolor=#000000><table style=^"color: #0000ff^">");
		len += formatex(menu[len], charsmax(menu) - len, "<td>Kezdete: 2020.08.25 06:00<br>Vége: 2020.09.25 06:00</td>");
		
		len = formatex(menu[len], charsmax(menu) - len, "</table></center>");
		
		show_motd(id, menu, "TOP15 - NYEREMÉNY");
	}
	public top3ThreadaK(FailState, Handle:Query, Error[], Errcode, szData[], DataSize)
	{
		if(FailState == TQUERY_CONNECT_FAILED)
		{
			set_fail_state("[ *HIBA* ] NEM LEHET KAPCSOLODNI AZ ADATBAZISHOZ!");
			return ;
		}
		else if(FailState == TQUERY_QUERY_FAILED)
		{
			set_fail_state("[ *HIBA* ] A LEKERDEZES MEGSZAKADT!");
			return ;
		}
		
		if(Errcode)
		{
			log_amx("[ *HIBA* ] PROBLEMA A LEKERDEZESNEL! ( %s )",Error);
			return ;
		}
		
		new count;
		
		while(SQL_MoreResults(Query))
		{
			nyid[count] = SQL_ReadResult(Query, 0);
			nyolesl[count] = SQL_ReadResult(Query, 3);
			
			SQL_ReadResult(Query, 2, nyolesNev[count], 31);
			
			count++;
			
			SQL_NextRow(Query);
		}
		
		return;
	}
public setVip()
{
	new players[32], pNum;
	get_players(players, pNum, "a");
	
	for (new i = 0; i < pNum; i++)
	{
		new id = players[i];
		if (g_Vip[id] == 1)
		{
			message_begin(MSG_ALL, get_user_msgid("ScoreAttrib"), {0, 0, 0}, id);
			write_byte(id);
			write_byte(4);
			message_end();
		}
	}
	return PLUGIN_HANDLED;
}
public client_authorized(id) {
	Selectedgun[AK47][id] = 0
	Selectedgun[M4A1][id] = 1
	Selectedgun[AWP][id] = 2
	Selectedgun[DEAGLE][id] = 3
	Selectedgun[KNIFE][id] = 4
	
}
public GetWeaponIdFromCSW(wid)
{
	new WeaponId;
	switch(wid)
	{
		case CSW_AK47:
		{
			WeaponId = 28;
		}
		case CSW_M4A1:
		{
			WeaponId = 22;
		} 
		case CSW_AWP:
		{
			WeaponId = 18;
		} 
		case CSW_DEAGLE:
		{
			WeaponId = 26;
		} 
		case CSW_KNIFE:
		{
			WeaponId = 29;
		} 
	}
	return WeaponId;
}
public DefaultWeaponIds(id, wid)
{
	switch(wid)
	{
		case 28: Selectedgun[AK47][id] = 0;
		case 22: Selectedgun[M4A1][id] = 1;
		case 18: Selectedgun[AWP][id] = 2;
		case 26: Selectedgun[DEAGLE][id] = 3;
		case 29: Selectedgun[KNIFE][id] = 4;
	}
}
stock get_player_name(id){
	static name[32]
	get_user_name(id,name,31)
	return name
}

public plugin_end(){
	SQL_FreeHandle(g_SqlTuple);
	ArrayDestroy(g_Admins);
}
public Cases_Menu(id)
{
  formatex(String, charsmax(String), "\r%s \y» \wLádák",menuprefix)
  new menu = menu_create(String, "Cases_Menu_h");

  for(new i;i < LADASZAM;i++)
  {
    formatex(String, charsmax(String), "\w%s [\r%i\w]", i, Lada[id][i]);

    new StringNum[2];
    num_to_str(i, StringNum, 2);
    menu_additem(menu, String, StringNum, 0);
  }

  menu_setprop(menu, MPROP_NEXTNAME, "Lapozás Előre");
  menu_setprop(menu, MPROP_BACKNAME, "Lapozás Vissza");
  menu_setprop(menu, MPROP_EXITNAME, "Vissza a Főmenübe");

  menu_display(id, menu, 0);
  return PLUGIN_HANDLED;
}
public Cases_Menu_h(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		T_Betu(id);
		return;
	}
	new data[9], szName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
	new key = str_to_num(data);
  
	Player[id][CaseSelectedSlot] = key;
	CaseInfo(id);
	
	menu_destroy(menu);
  
}

public CaseInfo(id)
{
	formatex(String, charsmax(String), "\r%s \y» \w%s Információ",menuprefix);
	new menu = menu_create(String, "CaseInfo_h");

	formatex(String, charsmax(String), "\yNyitás");
	menu_additem(menu, String, "0", 0);

	//formatex(String, charsmax(String), "\wTartalom megtekintése");
	//menu_additem(menu, String, "1", 0);

	formatex(String, charsmax(String), "\dPiacra helyezés [Hamarosan]");
	menu_additem(menu, String, "0", 0);

	menu_setprop(menu, MPROP_EXITNAME, "Vissza a Ládákhoz");

	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}

public CaseInfo_h(id, menu, item)
{
  if(item == MENU_EXIT)
  {
    menu_destroy(menu);
    Cases_Menu(id);
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
        if(Lada[id][Player[id][CaseSelectedSlot]] > 0)
        {
          if(LadaK[id][Player[id][CaseSelectedSlot]] > 0)
          {
	 Talal(id, Player[id][CaseSelectedSlot])
          }
          else
          {
            sk_chat(id,  "^1Nincs kulcsod!");
          }
        }
        else
        {
          sk_chat(id,  "^1Nincs ilyen ládád!");
        }
	CaseInfo(id);
    }
    case 1:
    {
      //ShowCaseContent(id, s_Player[id][CaseSelectedSlot]);
      CaseInfo(id);
    }
   
  }
  menu_destroy(menu);
}
public openTrash(id)
{
	new iras[121], String[121],szMenu[121];
	format(iras, charsmax(iras), "%s \r[ \wSkin gambling \r]", menuprefix);
	new menu = menu_create(String, "hTrash");
 
	for(new i;i < sizeof(FegyverInfo); i++)
	{
		if(g_Weapons[i][id] > 0)
		{
			formatex(szMenu, charsmax(szMenu), "\yST\r* \d(%idb) \w", g_StatTrak[i][id])
			num_to_str(i, String, 5);
			if(strlen(g_GunNames[i][id]) < 1) formatex(szMenu, charsmax(szMenu), "%s%s \d(\r%i \dDB)", g_StatTrak[i][id] >= 1 ? szMenu : "", FegyverInfo[i][GunName], g_Weapons[i][id]);
			else formatex(szMenu, charsmax(szMenu), "%s%s \d(\r%i \dDB)", g_StatTrak[i][id] >= 1 ? szMenu : "", g_GunNames[i][id], g_Weapons[i][id]);
			menu_additem(menu, szMenu, String);
		}
	}
	menu_display(id, menu, 0);
}
public hTrash(id, menu, item){
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED
	}
	
	if(g_Kirakva[id] == 1) {
		openTrash(id)
		sk_chat(id,  "^1Nem gamblingelhetsz el semmit amíg valamelyik tárgyad a Piacon van!")
		menu_destroy(menu);
		return PLUGIN_HANDLED
	}

	new data[9], szName[64]
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
	new key = str_to_num(data);
	new Float:randomdolcsi = random_float(0.01, 0.05);
	if(FegyverInfo[key][PiacraHelyezheto] == 0)
	{
		sk_chat(id,  "Nem tudod elgamblingelni a ^3%s^1 nevű skined, mert nem engedélyezett!", FegyverInfo[key][GunName])
		return PLUGIN_HANDLED;
	}
	if(g_StatTrak[key][id] == 1 || g_Weapons[key][id] == 1) g_GunNames[key][id][0] = EOS
	g_Weapons[key][id]--
	if(g_StatTrak[key][id] == g_Weapons[key][id]+1) g_StatTrak[key][id]--
	g_dollar[id] += randomdolcsi
	sk_chat(id,  "Elgamblingelted a ^3%s^1 nevű skined, ezért kaptál ^3%3.2f^1 dollárt.", FegyverInfo[key][GunName], randomdolcsi)
	
	if(FegyverInfo[key][EntName] == CSW_AK47) {
		Selectedgun[AK47][id] = key
		if(g_StatTrak[key][id] > 0) {
			SelectedStatTrak[0][id] = key
		}
	}
	else if(FegyverInfo[key][EntName] == CSW_M4A1) {
		Selectedgun[M4A1][id] = key
		if(g_StatTrak[key][id] > 0) {
			SelectedStatTrak[1][id] = key
		}
	}
	else if(FegyverInfo[key][EntName] == CSW_AWP) {
		Selectedgun[AWP][id] = key
		if(g_StatTrak[key][id] > 0) {
			SelectedStatTrak[2][id] = key
		}
	}
	else if(FegyverInfo[key][EntName] == CSW_DEAGLE) {
		Selectedgun[DEAGLE][id] = key
		if(g_StatTrak[key][id] > 0) {
			SelectedStatTrak[3][id] = key
		}
	}
	else if(FegyverInfo[key][EntName] == CSW_KNIFE) {
		Selectedgun[KNIFE][id] = key
		if(g_StatTrak[key][id] > 0) {
			SelectedStatTrak[4][id] = key
		}
	}
	
	openTrash(id)
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public Load_Data(id, Table_Name[], ForwardMetod[])
{
	new Query[1024]
	new Data[1];
	Data[0] = id;
	formatex(Query, charsmax(Query), "SELECT * FROM `%s` WHERE `User_Id` = %i;",Table_Name, sk_get_accountid(id))
	SQL_ThreadQuery(g_SqlTuple, ForwardMetod, Query, Data, 1);
}

public Load_User_Data(id)
{
	g_Id[id] = sk_get_accountid(id);
	Load_Data(id, "profiles", "QuerySelectProfile");
}

public QuerySelectProfile(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime) {
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) {
		log_amx("%s", Error);
		return;
	}
	else {
		new id = Data[0];
		
		if(SQL_NumRows(Query) > 0) {
			SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Dollars"), g_dollar[id]);
			Rang[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Rang"));
			g_Tools[0][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "STTool"));

			g_SkinBeKi[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "SkinBeKi"));
			Player[id][ScreenEffect] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "ScreenEffect"));
			Player[id][AdminIll] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "AdminIll"));

			HudOff[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "HudBeKi"));
			g_Tools[1][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Nevcedula"));
			g_VipTime[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "viptime"));
			Vip[id][PremiumTime] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "PremiumTime"));
			g_Admin_Level[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Admin_Szint"));
			Player[id][SSzint] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "KSzint"));
			hs[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "fejloves"));
			hl[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "halal"));
			oles[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "oles"));
			porgettime[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "porgettime"));
			Korvegi[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Korvegi"));
			MusicBoxEquiped[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "MusicBoxEquiped"));
			Elhasznal[0][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Elhasznalva1"));
			Elhasznal[1][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Elhasznalva2"));
			Elhasznal[2][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Elhasznalva3"));
			Elhasznal[3][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Elhasznalva4"));
			Elhasznal[4][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Elhasznalva5"));
			Options[id][0] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "HeadshotSounds"));
			Options[id][1] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "ChatSounds"));

			for(new i;i < sizeof(Cases); i++)
			{
				new String[64];
				formatex(String, charsmax(String), "Case%d", i);
				Lada[i][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, String));
			}
			for(new i;i < sizeof(MusicBox); i++)
			{
				new String[64];
				formatex(String, charsmax(String), "MusicBoxBuyed%d", i);
				MusicBoxBuyed[i][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, String));
			}
			for(new i;i < sizeof(Cases); i++)
			{
				new String[64];
				formatex(String, charsmax(String), "Keys%d", i);
				LadaK[i][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, String));
			}
			Load_Data(id, "weapon", "QuerySelectWeapon");
			
			Set_Permissions(id)
		}
		else
		{
			sql_create_profiles_row(id);
			sql_create_skin_row(id);
			sql_create_nametag_row(id);
			sql_create_nametag2_row(id);
			sql_create_weapon_row(id);
			sql_create_st_row(id);
			sql_create_stk_row(id);
			sql_create_kuldik_row(id);
		}
		
	}
}
public QuerySelectKuldik(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime) {
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) {
		log_amx("%s", Error);
		return;
	}
	else {
		new id = Data[0];
		
		if(SQL_NumRows(Query) > 0) {
		Questing[id][is_Questing] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "is_Questing"));
		Questing[id][QuestRare] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Rare"));
		Questing[id][QuestKillCount] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Kills"));
		Questing[id][QuestKill] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "ReqKill"));
		Questing[id][is_head] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "is_head"));
		Questing[id][QuestWeapon] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Weapon"));
		SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "DollarReward"), Questing[id][QuestDollarReward]);
		SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "SkipDollar"), Questing[id][QuestSkipDollar]);
		Questing[id][QuestNametagReward] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "NametagReward"));
		Questing[id][QuestStatTrakReward] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "StatTrakReward"));
		Questing[id][QuestCaseReward] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "LadaDarab"));
		Questing[id][QuestKeyReward] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "KulcsDarab"));
		Questing[id][QuestCase] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "LadaTipus"));
		Questing[id][QuestKey] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "KulcsTipus"));
		new fwd_loginedreturn;
		ExecuteForward(fwd_logined,fwd_loginedreturn, id);
		}
	}
}
public QuerySelectWeapon(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime) {
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) {
		log_amx("%s", Error);
		return;
	}
	else {
		new id = Data[0];
		
		if(SQL_NumRows(Query) > 0) {
            new fegyver = sizeof(FegyverInfo)
            for(new i;i < fegyver; i++)
            {
                new String[64];
                formatex(String, charsmax(String), "F_%d", i);
                g_Weapons[i][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, String));
            }
            Load_Data(id, "nevcedula", "QuerySelectNevcedula");
		}
		
	}
}
public QuerySelectNevcedula(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime) {
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) {
		log_amx("%s", Error);
		return;
	}
	else {
		new id = Data[0];
		
		if(SQL_NumRows(Query) > 0) {
            new fegyver = sizeof(FegyverInfo)
            for(new i;i < 159; i++)
            {
                new String[64];
                formatex(String, charsmax(String), "N%d", i);
                SQL_ReadResult(Query, SQL_FieldNameToNum(Query, String), g_GunNames[i][id], 99);
            }
						Load_Data(id, "nevcedula2", "QuerySelectNevcedula_2");
		}
		
	}
}
public QuerySelectNevcedula_2(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime) {
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) {
		log_amx("%s", Error);
		return;
	}
	else {
		new id = Data[0];
		
		if(SQL_NumRows(Query) > 0) {
            new fegyver = sizeof(FegyverInfo)
            for(new i = 159;i < fegyver; i++)
            {
                new String[64];
                formatex(String, charsmax(String), "N%d", i);
                SQL_ReadResult(Query, SQL_FieldNameToNum(Query, String), g_GunNames[i][id], 99);
            }
            Load_Data(id, "stattrak", "QuerySelectStattrak");
		}
		
	}
}
public QuerySelectStattrak(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime) {
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) {
		log_amx("%s", Error);
		return;
	}
	else {
		new id = Data[0];
		
		if(SQL_NumRows(Query) > 0) {
            new fegyver = sizeof(FegyverInfo)
            for(new i;i < fegyver; i++)
            {
                new String[64];
                formatex(String, charsmax(String), "st_%d", i);
                g_StatTrak[i][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, String));
            }
            Load_Data(id, "stattrakkills", "QuerySelectStKills");
		}
	}
}
public QuerySelectStKills(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime) {
    if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) {
        log_amx("%s", Error);
        return;
    }
    else {
        new id = Data[0];
        
        if(SQL_NumRows(Query) > 0) {
            new fegyver = sizeof(FegyverInfo)
            for(new i;i < fegyver; i++)
            {
                new String[64];
                formatex(String, charsmax(String), "stk_%i", i);
                g_StatTrakKills[i][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, String));
            }
            Load_Data(id, "skins", "QuerySelectSkin");
        }
    }
}
public QuerySelectSkin(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime) {
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) {
		log_amx("%s", Error);
		return;
	}
	else {
		new id = Data[0];
		
		if(SQL_NumRows(Query) > 0) {

		Selectedgun[AK47][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Skin0"));
		Selectedgun[M4A1][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Skin1"));
		Selectedgun[AWP][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Skin2"));
		Selectedgun[DEAGLE][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Skin3"));
		Selectedgun[KNIFE][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Skin4"));
		RemoveOldStuffs(id)
		Load_Data(id, "kuldetes", "QuerySelectKuldik");
		}
	}
}
public QuerySelectMusic(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime) {
    if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) {
        log_amx("%s", Error);
        return;
    }
    else {
        new id = Data[0];
        
       
    }
}
public client_disconnected(id)
{
	if(!sk_get_logged(id))
		return;

	Update(id);
	Update_Fegyver(id);
	Update_Stattrak(id);
	Update_StattrakKills(id);
	Update_Nametag(id, 1);
	Update_Skin(id);
	Update_kuldik(id);
}
public Update(id){
	static Query[10048];
	new Len;
	
	Len += formatex(Query[Len], charsmax(Query), "UPDATE `profiles` SET ");
	Len += formatex(Query[Len], charsmax(Query)-Len, "Dollars = ^"%.2f^", ", g_dollar[id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "Rang = ^"%i^", ", Rang[id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "gamename = ^"%s^", ", Player[id][f_PlayerNames]);


	Len += formatex(Query[Len], charsmax(Query)-Len, "ScreenEffect = ^"%i^", ", Player[id][ScreenEffect]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "AdminIll = ^"%i^", ", Player[id][AdminIll]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "PremiumTime = ^"%i^", ", Vip[id][PremiumTime]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "oles = ^"%i^", ", oles[id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "fejloves = ^"%i^", ", hs[id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "halal = ^"%i^", ", hl[id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "porgettime = ^"%i^", ", porgettime[id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "SkinBeKi = ^"%i^", ", g_SkinBeKi[id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "HudBeKi = ^"%i^", ", HudOff[id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "viptime = ^"%i^", ", g_VipTime[id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "Nevcedula = ^"%i^", ", g_Tools[1][id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "STTool = ^"%i^", ", g_Tools[0][id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "Admin_Szint = ^"%i^", ", g_Admin_Level[id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "Korvegi = ^"%i^", ", Korvegi[id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "MusicBoxEquiped = ^"%i^", ", MusicBoxEquiped[id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "HeadshotSounds = ^"%i^", ", Options[id][0]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "ChatSounds = ^"%i^", ", Options[id][1]);
	for(new i;i < sizeof(Cases); i++)
		Len += formatex(Query[Len], charsmax(Query)-Len, "Case%d = ^"%i^", ", i, Lada[i][id]);

	for(new i;i < sizeof(MusicBox); i++)
		Len += formatex(Query[Len], charsmax(Query)-Len, "MusicBoxBuyed%d = ^"%i^", ", i, MusicBoxBuyed[i][id]);
		
	for(new i;i < sizeof(Cases); i++)
		Len += formatex(Query[Len], charsmax(Query)-Len, "Keys%d = ^"%i^", ", i, LadaK[i][id]);

	Len += formatex(Query[Len], charsmax(Query)-Len, "oles = ^"%i^" WHERE `User_Id` =  %d;", oles[id], g_Id[id]);
	
	SQL_ThreadQuery(g_SqlTuple, "QuerySetData", Query);
}
public Update_kuldik(id){
	static Query[10048];
	new Len;
	
	Len += formatex(Query[Len], charsmax(Query), "UPDATE `kuldetes` SET ");
	Len += formatex(Query[Len], charsmax(Query)-Len, "is_Questing = ^"%i^", ", Questing[id][is_Questing]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "PlayerName = ^"%s^", ", Player[id][f_PlayerNames]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "Rare = ^"%i^", ", Questing[id][QuestRare]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "Kills = ^"%i^", ", Questing[id][QuestKillCount]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "ReqKill = ^"%i^", ", Questing[id][QuestKill]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "is_head = ^"%i^", ", Questing[id][is_head]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "Weapon = ^"%i^", ", Questing[id][QuestWeapon]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "DollarReward = ^"%.2f^", ", Questing[id][QuestDollarReward]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "SkipDollar = ^"%.2f^", ", Questing[id][QuestSkipDollar]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "NametagReward = ^"%i^", ", Questing[id][QuestNametagReward]); 
	Len += formatex(Query[Len], charsmax(Query)-Len, "StatTrakReward = ^"%i^", ", Questing[id][QuestStatTrakReward]); 
	Len += formatex(Query[Len], charsmax(Query)-Len, "LadaTipus = ^"%i^", ", Questing[id][QuestCase]); 
	Len += formatex(Query[Len], charsmax(Query)-Len, "KulcsTipus = ^"%i^", ", Questing[id][QuestKey]); 
	Len += formatex(Query[Len], charsmax(Query)-Len, "LadaDarab = ^"%i^", ", Questing[id][QuestCaseReward]); 
	Len += formatex(Query[Len], charsmax(Query)-Len, "KulcsDarab = ^"%i^" ", Questing[id][QuestKeyReward]); 

	Len += formatex(Query[Len], charsmax(Query)-Len, "WHERE `User_Id` =  %d;",g_Id[id]);
	
	SQL_ThreadQuery(g_SqlTuple, "QuerySetData", Query);
}
public Update_Skin(id){
	static Query[10048];
	new Len;
	
	Len += formatex(Query[Len], charsmax(Query), "UPDATE `skins` SET ");
		
	Len += formatex(Query[Len], charsmax(Query)-Len, "Skin0 = ^"%i^", ", Selectedgun[AK47][id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "Skin1 = ^"%i^", ", Selectedgun[M4A1][id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "Skin2 = ^"%i^", ", Selectedgun[AWP][id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "Skin3 = ^"%i^", ", Selectedgun[DEAGLE][id]);

	Len += formatex(Query[Len], charsmax(Query)-Len, "Skin4 = ^"%i^" WHERE `User_Id` =  %d;", Selectedgun[KNIFE][id], g_Id[id]);
	
	SQL_ThreadQuery(g_SqlTuple, "QuerySetData", Query);
}
public Update_Stattrak(id)
{
	static Query[10048];
	new Len;
	
	Len += formatex(Query[Len], charsmax(Query), "UPDATE `stattrak` SET ");
	
	for(new i;i < sizeof(FegyverInfo); i++)
		Len += formatex(Query[Len], charsmax(Query)-Len, "st_%d = ^"%i^", ", i, g_StatTrak[i][id]);


	Len += format(Query[Len], charsmax(Query)-Len,"Parameter = '0' ")
	Len += formatex(Query[Len], charsmax(Query)-Len, "WHERE `User_Id` =  %d;", g_Id[id]);
	SQL_ThreadQuery(g_SqlTuple, "QuerySetData", Query);
}
public Update_StattrakKills(id)
{
	static Query[10048];
	new Len;
	
	Len += formatex(Query[Len], charsmax(Query), "UPDATE `stattrakkills` SET ");
	
	for(new i;i < sizeof(FegyverInfo); i++)
		Len += formatex(Query[Len], charsmax(Query)-Len, "stk_%d = ^"%i^", ", i, g_StatTrakKills[i][id]);


	Len += format(Query[Len], charsmax(Query)-Len,"Parameter = '0' ")
	Len += formatex(Query[Len], charsmax(Query)-Len, "WHERE `User_Id` =  %d;", g_Id[id]);
	SQL_ThreadQuery(g_SqlTuple, "QuerySetData", Query);
}
public Update_Fegyver(id)
{
	static Query[10048];
	new Len;
	
	Len += formatex(Query[Len], charsmax(Query), "UPDATE `weapon` SET ");
	
	for(new i;i < sizeof(FegyverInfo); i++)
		Len += formatex(Query[Len], charsmax(Query)-Len, "F_%d = ^"%i^", ", i, g_Weapons[i][id]);

	Len += format(Query[Len], charsmax(Query)-Len,"Parameter = '0' ")
	Len += formatex(Query[Len], charsmax(Query)-Len, "WHERE `User_Id` =  %d;", g_Id[id]);
	SQL_ThreadQuery(g_SqlTuple, "QuerySetData", Query);
}
public Update_Nametag(id, load)
{
	static Query[10048];
	new Len;
	
	if(load == 1)
	{
		Len += formatex(Query[Len], charsmax(Query), "UPDATE `nevcedula` SET ");
		for(new i;i < 159; i++)
			Len += formatex(Query[Len], charsmax(Query)-Len, "N%d = ^"%s^", ", i, g_GunNames[i][id]);
	}
	else
	{
		Len += formatex(Query[Len], charsmax(Query), "UPDATE `nevcedula2` SET ");
		for(new i = 159;i < sizeof(FegyverInfo); i++)
			Len += formatex(Query[Len], charsmax(Query)-Len, "N%d = ^"%s^", ", i, g_GunNames[i][id]);
	}
		

	Len += format(Query[Len], charsmax(Query)-Len,"Parameter = '0' ")
	Len += formatex(Query[Len], charsmax(Query)-Len, "WHERE `User_Id` =  %d;", g_Id[id]);
	SQL_ThreadQuery(g_SqlTuple, "QuerySetData", Query);
}

public sql_create_rm_row(id){
	static Query[10048];
	formatex(Query, charsmax(Query), "INSERT INTO `erdemermek` (`User_Id`) VALUES (%d);", g_Id[id]);
	SQL_ThreadQuery(g_SqlTuple, "QuerySetData", Query);
}
public sql_create_profiles_row(id){
	static Query[10048];
	formatex(Query, charsmax(Query), "INSERT INTO `profiles` (`User_Id`) VALUES (%d);", g_Id[id]);
	SQL_ThreadQuery(g_SqlTuple, "QuerySetData", Query);
}	
public sql_create_skin_row(id){
	static Query[10048];
	formatex(Query, charsmax(Query), "INSERT INTO `skins` (`User_Id`) VALUES (%d);", g_Id[id]);
	SQL_ThreadQuery(g_SqlTuple, "QuerySetData", Query);
}	
public sql_create_nametag_row(id){
	static Query[10048];
	formatex(Query, charsmax(Query), "INSERT INTO `nevcedula` (`User_Id`) VALUES (%d);", g_Id[id]);
	SQL_ThreadQuery(g_SqlTuple, "QuerySetData", Query);
}
public sql_create_nametag2_row(id){
	static Query[10048];
	formatex(Query, charsmax(Query), "INSERT INTO `nevcedula2` (`User_Id`) VALUES (%d);", g_Id[id]);
	SQL_ThreadQuery(g_SqlTuple, "QuerySetData", Query);
}		
public sql_create_weapon_row(id){
	static Query[10048];
	formatex(Query, charsmax(Query), "INSERT INTO `weapon` (`User_Id`, `F_0`, `F_1`, `F_2`, `F_3`, `F_4`) VALUES (%d, 1, 1, 1, 1, 1);", g_Id[id]);
	SQL_ThreadQuery(g_SqlTuple, "QuerySetData", Query);
}	
public sql_create_testers_row(id){
	static Query[10048];
	formatex(Query, charsmax(Query), "INSERT INTO `shedi_testers` (`User_Id`,`Name`) VALUES (%d, ^"%s^");", g_Id[id], Player[id][f_PlayerNames]);
	SQL_ThreadQuery(g_SqlTuple, "QuerySetData", Query);
}
public sql_create_st_row(id){
	static Query[10048];
	formatex(Query, charsmax(Query), "INSERT INTO `stattrak` (`User_Id`) VALUES (%d);", g_Id[id]);
	SQL_ThreadQuery(g_SqlTuple, "QuerySetData", Query);
}	
public sql_create_stk_row(id){
	static Query[10048];
	formatex(Query, charsmax(Query), "INSERT INTO `stattrakkills` (`User_Id`) VALUES (%d);", g_Id[id]);
	SQL_ThreadQuery(g_SqlTuple, "QuerySetData", Query);
}	
public sql_create_music_row(id){
	static Query[10048];
	formatex(Query, charsmax(Query), "INSERT INTO `musickits` (`User_Id`) VALUES (%d);", g_Id[id]);
	SQL_ThreadQuery(g_SqlTuple, "QuerySetData", Query);
}
public sql_create_kuldik_row(id){
	Load_User_Data(id);
	static Query[10048];
	formatex(Query, charsmax(Query), "INSERT INTO `kuldetes` (`User_Id`) VALUES (%d);", g_Id[id]);
	SQL_ThreadQuery(g_SqlTuple, "QuerySetData", Query);

}

public RoundEnds()
{
	new players[32], num
	get_players(players, num, "c");
	SortCustom1D(players, num, "SortMVPToPlayer")
	TopMvp = players[0]
	new mvpName[32]
	get_user_name(TopMvp, mvpName, charsmax(mvpName))
	sk_chat(0, "^1A legjobb játékos ebben a körben ^3%s^1 volt!", mvpName)
	if(MusicBoxEquiped[TopMvp] != -1)
 		sortfrommusic(TopMvp)
	for(new i; i < g_Maxplayers; i++)
		g_MVPoints[i] = 0;
}
new latestplayed;
public sortfrommusic(id)
{
	new musicsizeof, sorted;
	musicsizeof = sizeof(MusicBoxMusics)
	for(new i = 1; i < 255; i++)
	{
		sorted = random_num(1, musicsizeof)
		if(sorted < 1 || sorted > 22 || sorted == latestplayed)
			continue;

		if(MusicBoxMusics[sorted][Boxid] == MusicBoxEquiped[id])
		{
			sk_chat(0, "^1Zene: ^3%s zenecsomag ^1| ^3%s", MusicBoxMusics[sorted][BoxName], MusicBoxMusics[sorted][MusicName])
			{
				for(new i; i < g_Maxplayers; i++)
				{
					if(Korvegi[i] == true)
						client_cmd(i, "mp3 play sound/%s", MusicBoxMusics[sorted][MusicLocation])
					g_MVPoints[i] = 0;
				}
			}
			latestplayed = sorted;
			return;
		}
		else continue;
	}
}
public SortMVPToPlayer(id1, id2){
	if(g_MVPoints[id1] > g_MVPoints[id2]) return -1;
	else if(g_MVPoints[id1] < g_MVPoints[id2]) return 1;
 
	return 0;
}
public bomb_planted(id) {
	g_MVPoints[id] += 3
}
public bomb_defused(id) {
	g_MVPoints[id] += 5
}
public RemoveOldStuffs(id)
{
	new maxskins = sizeof(FegyverInfo);
	new Float:adddollars;
	adddollars;
	for(new i; i < maxskins; i++)
	{
		if(FegyverInfo[i][PiacraHelyezheto] == -2 && server == 1 && g_Weapons[i][id] > 0)
		{
			new addedsts, addednt, iskes
			new String[521]

			if(g_StatTrak[i][id] > 0)
			{
				g_Tools[0][id] += g_StatTrak[i][id];
				addedsts += g_StatTrak[i][id];
			}
			if(strlen(g_GunNames[i][id]) > 2)
			{
				addednt++;
				g_Tools[1][id]++;
			}
				
			if(FegyverInfo[i][EntName] == CSW_KNIFE)
			{
				g_dollar[id] += 250.00
				iskes = 1;
			}
			copy(String, 521, fmt("ezért kaptál^3 %s^4%i^1 StatTrak Toolt, és ^4%i^1 névcédulát!", iskes == 1 ? "250.00$-t meg " : "", addedsts, addednt))
			g_Weapons[i][id] = 0;
			g_StatTrak[i][id] = 0;
			g_StatTrakKills[i][id] = 0;
			Selectedgun[AK47][id] = 0
			Selectedgun[M4A1][id] = 1
			Selectedgun[AWP][id] = 2
			Selectedgun[DEAGLE][id] = 3
			Selectedgun[KNIFE][id] = 4

			sk_chat(id, "^4%s^1 törölve lett, %s", FegyverInfo[i][GunName], String)

		}

	}
		// if(Lada[0][id] > 0)
		// 		adddollars += (Lada[0][id]*0.10)
		// if(Lada[1][id] > 0)
		// 	adddollars += (Lada[1][id]*0.10)
		// if(Lada[2][id] > 0)
		// 	adddollars += (Lada[2][id]*0.10)
		// if(Lada[3][id] > 0)
		// 	adddollars += (Lada[3][id]*0.10)
		// if(LadaK[0][id] > 0)
		// 	adddollars += (LadaK[0][id]*0.10)
		// if(LadaK[1][id] > 0)
		// 	adddollars += (LadaK[1][id]*0.10)
		// if(LadaK[2][id] > 0)
		// 	adddollars += (LadaK[2][id]*0.10)
		// if(LadaK[3][id] > 0)
		// 	adddollars += (LadaK[3][id]*0.10)

		// Lada[0][id] = 0;
		// Lada[1][id] = 0;
		// Lada[2][id] = 0;
		// Lada[3][id] = 0;

		// LadaK[0][id] = 0;
		// LadaK[1][id] = 0;
		// LadaK[2][id] = 0;
		// LadaK[3][id] = 0;

		// if(adddollars > 0.10)
		// {
		// 	g_dollar[id] += adddollars;
		// 	sk_chat(id, "A ládáid meg a kulcsaid miatt kaptál ^4%3.2f^1 dollárt!", adddollars)
		// }

}
