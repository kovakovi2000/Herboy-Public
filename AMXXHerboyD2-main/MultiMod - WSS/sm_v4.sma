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
#include <easytime2>
#include <bansys>
//#include <fragverseny>

#define MAXROUND 60

#define Is_Beta_Test = 1
#define NoUpdate = 1

new /* Fragverseny = 0, Fragkorok, Frags, */ TopMvp, fwd_logined, fegyvermenus = 0;
new porgettime[33], porgettimehw[33], adminfizu[33], FegyoMapName[33];
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
new const menuprefix[] = "\r[\wAVATÁR\r] \yFUN \d~";
new const ET_model[] = "models/AVHBSKINS/exille/case.mdl";
#define FEGYO 200
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

new karacsony2023[33], ajicsomag1[33], ajicsomag2[33], ajicsomag3[33], ajicsomag4[33], ajicsomag5[33];
new Elhasznal[35][33];
new g_korkezdes, g_VipTime[33], g_Vip[33], nyolesNev[33][32], nyid[33], nyolesl[33], bSync, g_fragverseny;
new g_ASD[33], szinesmenu[33], Buy[33];
new g_Kicucc[33], Float:g_Erteke[33], bool:g_StatTrakBeKi[33], OsszesKirakott[4], SelectedStatTrak[5][33], g_ChooseThings[3][33], skinkuldes[33], targykuldes[33]
new Float:g_dollar[33], /* name[33][32], */ hs[33], hl[33], oles[33], premiumpont[33], g_Maxplayers, g_SkinBeKi[33], g_tester[33], hirduz[33], nezlist[33], killhang[33],chathang[33],korvegizene[33];
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
{0, 0, "AK47 | Alap", "models/v_ak47.mdl", CSW_AK47}, //47 
{1, 0, "M4A1 | Alap", "models/v_m4a1.mdl", CSW_M4A1}, //21 
{2, 0, "AWP | Alap", "models/v_awp.mdl", CSW_AWP}, //21 
{3, 0, "DEAGLE | Alap", "models/v_deagle.mdl", CSW_DEAGLE}, //21  
{4, 0, "Kés", "models/v_knife.mdl", CSW_KNIFE}, //34
{5, 1, "AK47 | Fire", "models/AVHBSKINS/ak/1.mdl", CSW_AK47},  //MARAD
{6, 1, "AK47 | Rise purp", "models/AVHBSKINS/ak/49.mdl", CSW_AK47},  //MARAD 
{7, 0, "Katácska sziporkázó M4e", "models/HB2024/summer/20.mdl", CSW_M4A1}, 
{8, 0, "Katácska EXILLE tulajdona", "models/HB2024/summer/21.mdl", CSW_DEAGLE}, 
{9, -2, "Unknown", "", CSW_AK47}, 
{10, -2, "Unknown", "", CSW_AK47}, 
{11, 0, "AK47 | Karácsonyi Skin", "models/herboy_winter/v_ak47.mdl", CSW_AK47}, //MARAD
{12, -2, "Unknown", "", CSW_AK47}, 
{13, 0, "Kés | Karácsonyi Skin", "models/herboy_winter/hb_winter_kes.mdl", CSW_KNIFE}, 
{14, -2, "Unknown", "", CSW_AK47}, 
{15, -2, "Unknown", "", CSW_AK47}, 
{16, -2, "Unknown", "", CSW_AK47}, 
{17, -2, "Unknown", "", CSW_AK47}, 
{18, -2, "Unknown", "", CSW_AK47}, 
{19, -2, "Unknown", "", CSW_AK47}, 
{20, -2, "Unknown", "", CSW_AK47},
{21, -2, "Unknown", "", CSW_AK47},
{22, -2, "Unknown", "", CSW_AK47}, 
{23, -2, "Unknown", "", CSW_AK47}, 
{24, -2, "Unknown", "", CSW_AK47},
{25, -2, "Unknown", "", CSW_AK47}, 
{26, -2, "Unknown", "", CSW_AK47}, 
{27, -2, "Unknown", "", CSW_AK47}, 
{28, -2, "Unknown", "", CSW_AK47}, 
{29, -2, "Unknown", "", CSW_AK47}, 
{30, -2, "Unknown", "", CSW_AK47},
{31, -2, "Unknown", "", CSW_AK47}, 
{32, 1, "AK47 | Poison Sakura", "models/AVHBSKINS/ak/28.mdl", CSW_AK47}, //MARAD
{33, 1, "AK47 | Bloodsport", "models/AVHBSKINS/ak/29.mdl", CSW_AK47},  //MARAD
{34, -2, "Unknown", "", CSW_AK47}, 
{35, -2, "Unknown", "", CSW_AK47}, 
{36, -2, "Unknown", "", CSW_AK47}, 
{37, -2, "Unknown", "", CSW_AK47}, 
{38, -2, "Unknown", "", CSW_AK47}, 
{39, -2, "Unknown", "", CSW_AK47}, 
{40, -2, "Unknown", "", CSW_AK47}, 
{41, 1, "AK47 | Nike", "models/AVHBSKINS/ak/37.mdl", CSW_AK47},  //BoltITEM //MARAD
{42, 1, "AK47 | Red Fury", "models/AVHBSKINS/ak/38.mdl", CSW_AK47},  //MARAD
{43, -2, "Unknown", "", CSW_AK47}, 
{44, -2, "Unknown", "", CSW_AK47}, 
{45, -2, "Unknown", "", CSW_AK47}, 
{46, -2, "Unknown", "", CSW_AK47}, 
{47, -2, "Unknown", "", CSW_AK47}, 
{48, -2, "Unknown", "", CSW_AK47},
{49, 1, "AK47 | Deep Frost", "models/AVHBSKINS/ak/45.mdl", CSW_AK47}, //MARAD
{50, -2, "Unknown", "", CSW_AK47},
{51, -2, "Unknown", "", CSW_AK47}, 
{52, -2, "Unknown", "", CSW_M4A1},
{53, -2, "Unknown", "", CSW_M4A1},
{54, -2, "Unknown", "", CSW_M4A1},
{55, -2, "Unknown", "", CSW_M4A1},
{56, -2, "Unknown", "", CSW_AK47}, 
{57, -2, "Unknown", "", CSW_M4A1},
{58, -2, "Unknown", "", CSW_M4A1},
{59, 1, "AWP | Red Puzzle", "models/HB2024/awp/1.mdl", CSW_AWP}, 
{60, 1, "AWP | Tiger Tooth", "models/HB2024/awp/2.mdl", CSW_AWP}, 
{61, 1, "AWP | Fever Dream", "models/HB2024/awp/3.mdl", CSW_AWP}, 
{62, 1, "AWP | Rave", "models/HB2024/awp/4.mdl", CSW_AWP}, 
{63, 1, "AWP | Sticker", "models/HB2024/awp/5.mdl", CSW_AWP},  
{64, 1, "M4A1 | Desolate Space", "models/HB2024/m4/1.mdl", CSW_M4A1}, 
{65, 1, "M4A1 | Icarus Fell", "models/HB2024/m4/2.mdl", CSW_M4A1},  
{66, 1, "M4A1 | Starladder", "models/HB2024/m4/3.mdl", CSW_M4A1}, 
{67, 1, "M4A1 | Sticker", "models/HB2024/m4/4.mdl", CSW_M4A1}, 
{68, 1, "M4A1 | Condor", "models/HB2024/m4/5.mdl", CSW_M4A1}, 
{69, -2, "Unknown", "", CSW_M4A1}, 
{70, -2, "Unknown", "", CSW_AK47}, 
{71, -2, "Unknown", "", CSW_AK47},
{72, 1, "KNIFE | Galaxy", "models/AVHBSKINS/v5/13.mdl", CSW_KNIFE}, // kés
{73, 1, "KNIFE | Menacing Storm", "models/AVHBSKINS/v5/12.mdl", CSW_KNIFE}, // kés
{74, 1, "Bayonet | Marble Fade", "models/AVHBSKINS/knife/48.mdl", CSW_KNIFE}, // kés
{75, 1, "Talon | Gamma Doppler", "models/AVHBSKINS/knife/49.mdl", CSW_KNIFE}, // kés
{76, 0, "AK47 | Green Tron", "models/AVHBSKINS/tron/green/v_ak47.mdl", CSW_AK47},
{77, 0, "KNIFE | Green Tron", "models/AVHBSKINS/tron/green/v_knife.mdl", CSW_KNIFE},
{78, 1, "KNIFE | Metalic", "models/HB2024/summer/1.mdl", CSW_KNIFE},
{79, 1, "KNIFE | CrYsIs HaND's", "models/HB2024/summer/2.mdl", CSW_KNIFE},
{80, 1, "KNIFE | Dagger", "models/HB2024/summer/3.mdl", CSW_KNIFE},
{81, 1, "Karambit | Luminous Ice", "models/HB2024/summer/4.mdl", CSW_KNIFE},
{82, 1, "Karambit | Lighting Blade", "models/HB2024/summer/5.mdl", CSW_KNIFE},
{83, 1, "KNIFE | Daedric dagger", "models/HB2024/summer/6.mdl", CSW_KNIFE},
{84, 1, "KNIFE | Lumine", "models/HB2024/summer/7.mdl", CSW_KNIFE},
{85, 1, "Karambit | Ultraviolet", "models/HB2024/summer/8.mdl", CSW_KNIFE},
{86, 1, "KNIFE | Guardian", "models/HB2024/summer/9.mdl", CSW_KNIFE},
{87, 1, "Skeleton | Fade", "models/HB2024/summer/10.mdl", CSW_KNIFE},
{88, 1, "Flip Knife | Doppler", "models/HB2024/summer/11.mdl", CSW_KNIFE},
{89, 1, "Karambit | Doppler Sapphire", "models/HB2024/summer/12.mdl", CSW_KNIFE},
{90, 1, "Butterfly | Deep Blue Sea", "models/HB2024/summer/13.mdl", CSW_KNIFE},
{91, 1, "Butterfly | Doppler", "models/HB2024/summer/14.mdl", CSW_KNIFE},
{92, 1, "M9 Bayonet | Fade V3", "models/HB2024/summer/15.mdl", CSW_KNIFE},
{93, 1, "M9 Bayonet | MikuChan", "models/HB2024/summer/16.mdl", CSW_KNIFE},
{94, 1, "Falchion | Slaughter", "models/HB2024/summer/17.mdl", CSW_KNIFE},
{95, -2, "Unknown", "", CSW_AK47}, 
{96, -2, "Unknown", "", CSW_AK47}, 
{97, -2, "Unknown", "", CSW_AK47}, 
{98, -2, "Unknown", "", CSW_AWP}, 
{99, -2, "Unknown", "", CSW_AWP}, 
{100, -2, "Unknown", "", CSW_AWP},
{101, -2, "Unknown", "", CSW_DEAGLE}, 
{102, -2, "Unknown", "", CSW_DEAGLE},
{103, -2, "Unknown", "", CSW_DEAGLE},
{104, -2, "Unknown", "", CSW_DEAGLE},
{105, 0, "KNIFE | Splatch", "models/AVHBSKINS/v5/5.mdl", CSW_KNIFE},//egyedikérésre
{106, -2, "Unknown", "", CSW_AK47}, 
{107, -2, "Unknown", "", CSW_DEAGLE},
{108, -2, "Unknown", "", CSW_AK47}, 
{109, -2, "Unknown", "", CSW_DEAGLE},
{110, -2, "Unknown", "", CSW_DEAGLE},
{111, -2, "Unknown", "", CSW_DEAGLE},
{112, -2, "Unknown", "", CSW_DEAGLE},
{113, -2, "Unknown", "", CSW_AK47}, 
{114, -2, "Unknown", "", CSW_AK47}, 
{115, -2, "Unknown", "", CSW_AK47}, 
{116, -2, "Unknown", "", CSW_DEAGLE},
{117, -2, "Unknown", "", CSW_AK47}, 
{118, 0, "AK47 | Psyche Supaski", "models/AVHBSKINS/v5/10.mdl", CSW_AK47},
{119, -2, "Unknown", "", CSW_AK47}, 
{120, -2, "Unknown", "", CSW_AK47}, 
{121, 0, "KNIFE | Psyche Supaski", "models/AVHBSKINS/v5/8.mdl", CSW_KNIFE},
{122, 1, "Baseball ütő", "models/AVHBSKINS/knife/2.mdl", CSW_KNIFE},
{123, 1, "Bayonet | Crimson BroThers", "models/AVHBSKINS/knife/3.mdl", CSW_KNIFE},
{124, -2, "Unknown", "", CSW_AK47},
{125, -2, "Unknown", "", CSW_AK47},
{126, 1, "Nautilus | Boca Juniors", "models/AVHBSKINS/knife/58.mdl", CSW_KNIFE},
{127, -2, "Unknown", "", CSW_AK47},
{128, 1, "Butterfly | Pinkman", "models/AVHBSKINS/knife/8.mdl", CSW_KNIFE},
{129, 1, "Blade | Wolf sight", "models/AVHBSKINS/knife/9.mdl", CSW_KNIFE},
{130, -2, "Unknown", "", CSW_AK47},
{131, 1, "KNIFE | Bone", "models/AVHBSKINS/knife/11.mdl", CSW_KNIFE},
{132, -2, "Unknown", "", CSW_AK47}, 
{133, 1, "Balta", "models/AVHBSKINS/knife/13.mdl", CSW_KNIFE},
{134, 1, "Classic | Fire", "models/AVHBSKINS/knife/14.mdl", CSW_KNIFE},
{135, -2, "Unknown", "", CSW_AK47},
{136, 0, "AK47 | Shakal", "models/AVHBSKINS/v5/2.mdl", CSW_AK47},//egyedikérésre
{137, 1, "Karambit | Marble Fade", "models/AVHBSKINS/v5/1.mdl", CSW_KNIFE},
{138, 1, "Classic | Frozen", "models/AVHBSKINS/knife/18.mdl", CSW_KNIFE},
{139, -2, "Unknown", "", CSW_KNIFE},
{140, 1, "Axe | Proton", "models/AVHBSKINS/knife/20.mdl", CSW_KNIFE},
{141, 1, "Classic | Janus", "models/AVHBSKINS/knife/21.mdl", CSW_KNIFE},
{142, 1, "Classic | Red Nature", "models/AVHBSKINS/knife/59.mdl", CSW_KNIFE},
{143, 1, "Heavy | Blade", "models/AVHBSKINS/knife/23.mdl", CSW_KNIFE},
{144, -2, "Unknown", "", CSW_AK47},
{145, 1, "Butterfly | Balisong", "models/AVHBSKINS/knife/25.mdl", CSW_KNIFE},
{146, -2, "Unknown", "", CSW_AK47},
{147, 1, "June | Blossom", "models/AVHBSKINS/knife/27.mdl", CSW_KNIFE},
{148, 1, "Karambit | Red Dreamer", "models/AVHBSKINS/knife/52.mdl", CSW_KNIFE},
{149, 0, "HerBoy Kés", "models/AVHBSKINS/event/hb_knife.mdl", CSW_KNIFE}, //BoltITEM
{150, 1, "Axe | Blackhawk", "models/AVHBSKINS/knife/42.mdl", CSW_KNIFE},
{151, 0, "AK47 | Mitex", "models/AVHBSKINS/event/mitex_ak47.mdl", CSW_AK47},//PPitem
{152, -2, "Unknown", "", CSW_AK47}, 
{153, -2, "Unknown", "", CSW_AK47}, 
{154, -2, "Unknown", "", CSW_AK47}, 
{155, 0, "KNIFE | Mitex", "models/AVHBSKINS/event/mitex_knife.mdl", CSW_KNIFE},//PPitem
{156, 0, "Vibrátor", "models/AVHBSKINS/frag.mdl", CSW_KNIFE},
{157, 0, "AK47 | Blue Tron", "models/AVHBSKINS/tron/blue/v_ak47.mdl", CSW_AK47},
{158, 0, "KNIFE | Blue Tron", "models/AVHBSKINS/tron/blue/v_knife.mdl", CSW_KNIFE},
{159, -2, "Unknown", "", CSW_AK47}, 
{160, -2, "Unknown", "", CSW_AK47}, 
{161, -2, "Unknown", "", CSW_AK47}, 
{162, -2, "Unknown", "", CSW_AK47},
{163, -2, "Unknown", "", CSW_KNIFE},
{164, -2, "Unknown", "", CSW_DEAGLE},
{165, 0, "Katácska AWP fegyvere", "models/HB2024/summer/19.mdl", CSW_AWP},
{166, 0, "Katácska sziporkázó baltája", "models/HB2024/summer/18.mdl", CSW_KNIFE},
{167, 1, "KNIFE | Neon assasin", "models/AVHBSKINS/knife/34.mdl", CSW_KNIFE}, 
{168, 1, "Flip Knife | Doppler Sapphire", "models/AVHBSKINS/knife/35.mdl", CSW_KNIFE},  
{169, 1, "KNIFE | Ghost", "models/AVHBSKINS/knife/36.mdl", CSW_KNIFE}, 
{170, 1, "M9 Bayonet | Nitro", "models/AVHBSKINS/knife/37.mdl", CSW_KNIFE},  
{171, 1, "M9 Bayonet | Wasteland-Rebel", "models/AVHBSKINS/knife/38.mdl", CSW_KNIFE}, 
{172, 1, "KNIFE | Meat", "models/AVHBSKINS/knife/39.mdl", CSW_KNIFE}, 
{173, 1, "KNIFE | Nautilus", "models/AVHBSKINS/knife/40.mdl", CSW_KNIFE}, 
{174, 1, "Ursus | Ruby", "models/AVHBSKINS/knife/41.mdl", CSW_KNIFE}, 
{175, 1, "AK47 | Frontside Misty", "models/AVHBSKINS/ak/50.mdl", CSW_AK47}, 
{176, 1, "AK47 | Red Dragon", "models/AVHBSKINS/ak/51.mdl", CSW_AK47}, 
{177, 1, "AK47 | Redline", "models/AVHBSKINS/ak/52.mdl", CSW_AK47}, 
{178, 1, "AK47 | Loius Vuitton", "models/AVHBSKINS/v5/16.mdl", CSW_AK47}, 
{179, 1, "AK47 | Vulcan", "models/AVHBSKINS/ak/54.mdl", CSW_AK47}, 
{180, 1, "AK47 | Blueflame", "models/AVHBSKINS/ak/55.mdl", CSW_AK47}, 
{181, 1, "KNIFE | Frostmourne", "models/AVHBSKINS/v5/14.mdl", CSW_KNIFE}, 
{182, 1, "AK47 | Demolition Derby", "models/AVHBSKINS/ak/57.mdl", CSW_AK47}, 
{183, 1, "AK47 | Polcar Bear", "models/AVHBSKINS/ak/58.mdl", CSW_AK47}, 
{184, 1, "AK47 | Neon Revolution", "models/AVHBSKINS/ak/59.mdl", CSW_AK47}, 
{185, 1, "AK47 | The Empress", "models/AVHBSKINS/ak/60.mdl", CSW_AK47}, 
{186, 1, "Baton | Asiimov", "models/AVHBSKINS/knife/43.mdl", CSW_KNIFE},
{187, 1, "KNIFE | Purple Error", "models/AVHBSKINS/knife/44.mdl", CSW_KNIFE},
{188, 1, "KNIFE | Loius Vuitton", "models/AVHBSKINS/v5/11.mdl", CSW_KNIFE},
{189, 0, "Katácska Baltája", "models/HB2024/1.mdl", CSW_KNIFE}, 
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
	{"Szellem Láda", 10.0, 11.0, 15.0, 0.0},
	{"Nefrit Láda", 7.0, 8.0, 25.0, 0.0},
	{"Kristály Láda", 4.0, 5.0, 40.0, 0.0},
	{"Rémálom Láda", 3.2, 3.4, 55.0, 0.0},
	{"Monolit Láda", 1.9, 2.3, 80.0, 0.0},
	{"Káosz Láda", 1.1, 1.25, 100.0, 0.0},
}
new const Keys[][DropSystem_Prop] =
{
	{"Szellem Ládakulcs", 11.0, 12.0, 0.0, 15.0},
	{"Nefrit Ládakulcs", 7.3, 7.8, 0.0, 25.0},
	{"Kristály Ládakulcs", 4.2, 4.7, 0.0, 40.0},
	{"Rémálom Ládakulcs", 3.1, 3.6, 0.0, 55.0},
	{"Monolit Ládakulcs", 2.1, 2.2, 0.0, 80.0},
	{"Káosz Ládakulcs", 0.9, 1.1, 0.0, 100.0},
}

new Lada[sizeof(Keys)][33]
new LadaK[sizeof(Keys)][33]
new const Float:FegyverLada1Drops[][] = 
{
	{5.0,0.11},
	{6.0,5.11},
	{32.0,10.5},
	{33.0,15.07},
	{41.0,0.01},
	{42.0,0.49},
	{49.0,20.72},
	{59.0,10.5},
	{60.0,6.1},
	{61.0,2.1},
	{62.0,0.11},
	{63.0,8.21},
	{64.0,4.21},
	{65.0,7.98},
	{66.0,7.01},
	{67.0,10.01},
	{68.0,8.01},
};
new const Float:FegyverLada2Drops[][] = 
{
	{5.0,0.11},
	{6.0,5.11},
	{32.0,10.5},
	{33.0,15.07},
	{41.0,0.01},
	{42.0,0.49},
	{49.0,20.72},
	{59.0,10.5},
	{60.0,6.1},
	{61.0,2.1},
	{62.0,0.11},
	{63.0,8.21},
	{64.0,4.21},
	{65.0,7.98},
	{66.0,7.01},
	{67.0,10.01},
	{68.0,8.01},
};
new const Float:LamaDrops[][] = 
{
	{5.0,0.11},
	{6.0,5.11},
	{32.0,10.5},
	{33.0,15.07},
	{41.0,0.01},
	{42.0,0.49},
	{49.0,20.72},
	{59.0,10.5},
	{60.0,6.1},
	{61.0,2.1},
	{62.0,0.11},
	{63.0,8.21},
	{64.0,4.21},
	{65.0,7.98},
	{66.0,7.01},
	{67.0,10.01},
	{68.0,8.01},
};
new const Float:DevilDrops[][] =
{
	{5.0,0.11},
	{6.0,5.11},
	{32.0,10.5},
	{33.0,15.07},
	{41.0,0.01},
	{42.0,0.49},
	{49.0,20.72},
	{59.0,10.5},
	{60.0,6.1},
	{61.0,2.1},
	{62.0,0.11},
	{63.0,8.21},
	{64.0,4.21},
	{65.0,7.98},
	{66.0,7.01},
	{67.0,10.01},
	{68.0,8.01},
};
new const Float:AlomDrops[][] = 
{
	{5.0,0.11},
	{6.0,5.11},
	{32.0,10.5},
	{33.0,15.07},
	{41.0,0.01},
	{42.0,0.49},
	{49.0,20.72},
	{59.0,10.5},
	{60.0,6.1},
	{61.0,2.1},
	{62.0,0.11},
	{63.0,8.21},
	{64.0,4.21},
	{65.0,7.98},
	{66.0,7.01},
	{67.0,10.01},
	{68.0,8.01},
};

new const Float:DragonDrops[][] = 
{
	{5.0,0.11},
	{6.0,5.11},
	{32.0,10.5},
	{33.0,15.07},
	{41.0,0.01},
	{42.0,0.49},
	{49.0,20.72},
	{59.0,10.5},
	{60.0,6.1},
	{61.0,2.1},
	{62.0,0.11},
	{63.0,8.21},
	{64.0,4.21},
	{65.0,7.98},
	{66.0,7.01},
	{67.0,10.01},
	{68.0,8.01},
	{71.0,0.24},//kések innét------>
    {72.0,0.18},
    {73.0,0.17},
    {74.0,0.31},
    {75.0,0.30},
	{78.0,0.30},
	{79.0,0.20},
	{80.0,0.20},
	{81.0,0.20},
	{82.0,0.20},
	{83.0,0.20},
	{84.0,0.20},
	{85.0,0.20},
	{86.0,0.20},
	{87.0,0.20},
	{88.0,0.10},
	{89.0,0.20},
	{90.0,0.10},
	{91.0,0.20},
	{92.0,0.20},
	{93.0,0.20},
	{94.0,0.20},
	{122.0,0.13},
	{123.0,0.17},
	{124.0,0.14},
	{125.0,0.17},
	{126.0,0.20},
	{127.0,0.17},
	{128.0,0.15},
	{129.0,0.12},
	{130.0,0.24},
	{131.0,0.26},
	{133.0,0.25},
	{134.0,0.20},
	{135.0,0.29},
	{137.0,0.23},
	{138.0,0.24},
	{140.0,0.21},
	{141.0,0.21},
	{142.0,0.26},
	{143.0,0.25},
	{144.0,0.30},
	{145.0,0.32},
	{146.0,0.36},
	{147.0,0.33},
	{148.0,0.31},
	{150.0,0.21},
	{167.0,0.11},
	{168.0,0.11},
	{169.0,0.11},
	{170.0,0.11},
	{171.0,0.11},
	{172.0,0.11},
	{173.0,0.11},
    {174.0,0.11},
	{181.0,0.31},
	{188.0,0.05},
};
enum _:RangAdatok {
	RangName[32],
	Killek[8]
}
new const Rangok[][RangAdatok] = {
	{"Újonc", 0},                                           
	{"Iron I", 100},
	{"Iron II", 500},
	{"Iron III", 1000},
	{"Bronze I", 1400},
	{"Bronze II", 1800},
	{"Bronze III", 2400},
	{"Silver I", 2900},
	{"Silver II", 3400},
	{"Silver III", 4000},
	{"Gold I", 4500},
	{"Gold II", 5000},
	{"Gold III", 5700},
	{"Platinum I", 6500},
	{"Platinum II", 7300},
	{"Platinum III", 8000},
	{"Diamond I", 8700},
	{"Diamond II", 9500},
	{"Diamond III", 10400},
	{"Ascendant I", 11400},
	{"Ascandant II", 12400},
	{"Ascandant III", 13000},
	{"Immortal I", 17000},
	{"Immortal II", 25000},
	{"Immortal III", 35000},
	{"Radiant", 50000},
	{"1337", 100000}
}

public plugin_init()
{
	register_plugin("[HB] Mod", "V5.1", "EXILLE");
	//=============== | HUD CREATE | ==============
	aSync = CreateHudSyncObj();
	bSync = CreateHudSyncObj();
	dSync = CreateHudSyncObj();
	// cSync = CreateHudSyncObj();
	//=============== | Client&ServCommands | ==============
	register_clcmd("say /admin", "cmdSetAdminDisplay");
	register_clcmd("say /nevcedula", "openAddNameTag");
	register_clcmd("say dc", "dc")
	register_clcmd("say /dc", "dc")
	register_clcmd("say /menu", "Ellenorzes");
	register_clcmd("say /mute", "openPlayerChooserMute")
	register_concmd("hb_set_vip", "CmdSetVIP", _, "<#id> <ido>");
	register_concmd("hb_add_money", "CmdSetMONEY", _, "<#id> <összeg>")
	register_concmd("rs", "exilleRS")
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
	maxkor = register_cvar("maxkor", "150");
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
	gmsg_SetFOV = get_user_msgid("SetFOV")
	loading_maps();
}
public hb_jatekgep(id, item) {
	
    new data[9], szName[64];
    new SteamId[33], IP[33]
    get_user_ip(id, IP, 33, 1)
    get_user_authid(id, SteamId, 33)
    new Time[40]
    format_time(Time, charsmax(Time), "%Y.%m.%d - %H:%M:%S", get_systime())
	
	switch(item)
	{
		case 0:
		{
			switch(random_num(1, 13))
				{
					case 1:
					{
						sk_chat(id, "^1Pörgettél ^4 1^3 Névcédulát és ^4 1^3 ST Tool-t!")
						g_Tools[0][id] += 1
                        g_Tools[1][id] += 1
						sk_log("jatekgep", fmt("[jatekgep] (%s) %s Pörgetett egy NV/ST toolt! (AccID: %i)", "asd", Player[id][f_PlayerNames], sk_get_accountid(id)))

					}
					case 2:
					{

					    new Float:dollardrop = random_float(1.01, 10.20);

                        g_dollar[id] += dollardrop;
                        sk_chat(id, "^1Pörgettél ^4%3.2f^1 dollárt.", dollardrop);
						sk_log("jatekgep", fmt("[jatekgep] (%s) %s Pörgetett egy %3.2f dollárt! (AccID: %i)", "asd", Player[id][f_PlayerNames], dollardrop, sk_get_accountid(id)))
					}
					case 3:
					{
						sk_chat(id, "Sajnos most nem nyertél semmit!")	
					}
					case 4:
					{
						new lada = random_num(0, 5);
	                    LadaK[lada][id]++;
	                    sk_chat(id, "^1Pörgettél egy ^4%s^1-t.", Keys[lada][d_Name]);
						sk_log("jatekgep", fmt("[jatekgep] (%s) %s Pörgetett egy %s.  (AccID: %i)", "asd", Player[id][f_PlayerNames], Keys[lada][d_Name], sk_get_accountid(id)))
					}
					case 5:
					{
						sk_chat(id, "Sajnos most nem nyertél semmit!")	
					}
					case 6:
					{
						sk_chat(id, "Sajnos most nem nyertél semmit!")	
					}
					case 7:
					{
                        sk_chat(id, "Sajnos most nem nyertél semmit!")	
					}
					case 8:
					{
						sk_chat(id, "Sajnos most nem nyertél semmit!")	
					}
					case 9:
					{
						sk_chat(id, "Sajnos most nem nyertél semmit!")	
					}
					case 10:
					{
						sk_chat(id, "Sajnos most nem nyertél semmit!")	
					}
					case 11:
					{
						sk_chat(id, "Sajnos most nem nyertél semmit!")	
					}
					case 12:
					{
						sk_chat(id, "Sajnos most nem nyertél semmit!")
					}
					case 13:
					{
					    sk_chat(id, "Sajnos most nem nyertél semmit!")				
					}
				}
		}
 
	}
}

public exilleRS(id){
    client_cmd(id, "spk buttons/bell1.wav");
    set_user_frags(id, 0);
    cs_set_user_deaths(id, 0);
    sk_chat(id, "A ^3Statisztikád ^4sikeresen ^3törölve^1!")
}
public plugin_natives()
{
	register_native("get_options","native_get_options",1)
	register_native("hb_jatekgep","native_hb_jatekgep",1)
	register_native("Szerencsemenu","native_Szerencsemenu",1)
}

public native_hb_jatekgep(id, item)
{
    return hb_jatekgep(id, item);
}


public native_Szerencsemenu(id)
{
    return Szerencsemenu(id);
}

public native_get_options(index, opt)
{
	return Options[index][opt];
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

	if(get_user_adminlvl(id) == 0)
	{
	sk_chat(id, "Ez a command csak ^3adminoknak^1 érhető el!")
	return PLUGIN_HANDLED;
	}
        give_player_grenades(id);
        give_item(id, "weapon_knife");
        give_item(id, "weapon_awp");
        give_item(id, "item_kevlar");
                        
        give_item(id, "ammo_338magnum");
        give_item(id, "ammo_338magnum");
        set_user_armor(id, 100);
        give_item(id, "ammo_338magnum");
        sk_chat(id,  "^1Kaptál egy ^3AWP^1 fegyvert!");
}
public wpp2(id)
{
  if(sk_get_accountid(id) == 26344 || sk_get_accountid(id) == 26693)
  {
		give_player_grenades(id);
    give_item(id, "weapon_knife");
    give_item(id, "weapon_awp");
    give_item(id, "item_kevlar");
                        
    give_item(id, "ammo_338magnum");
    give_item(id, "ammo_338magnum");
    set_user_armor(id, 100);
    give_item(id, "ammo_338magnum");
    sk_chat(id,  "^1Kaptál egy ^3AWP^1 fegyvert katácska!");
  }
  else
    sk_chat(id,  "^1Neked ehhez nincs jogod.");
}
public cmdSetAdminDisplay(id)
{
	if(get_user_adminlvl(id) == 0)
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

public exdebug(id)
{
	sk_chat(0, "DEBUG: ^4is_anyone_scanning == %i", is_anyone_scanning())
  sk_chat(id, "Sima kör: ^4%d", g_korkezdes)
	sk_chat(id, "Frag kör: ^4%d", g_fragverseny)
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

	sk_chat(0, "^3Játékosok: ^4%d^1/^4%d^1 | ^3Idő: ^4%s ^1| ^3Pálya: ^4%s", p_playernum, g_Maxplayers, sDateAndTime, FegyoMapName); 

}
public dc(){
sk_chat(0, "Discord szerver: ^4https://discord.com/invite/4HKPmQCV8r")
}
public pkor()
{
	engine_changelevel("de_dust2")
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
					sk_chat(id, "^3%s ^1találta ezt: ^4%s^1. ^3Esélye: ^4%.2f%s%", Player[id][f_PlayerNames], Cases[i][d_Name], (fDropChance[i]/(fAllChance/100)), "%");
					
				}
				case 2:
				{
					LadaK[i][id]++;
					sk_chat(id, "^3%s ^1találta ezt: ^4%s^1. ^3Esélye: ^4%.2f%s%", Player[id][f_PlayerNames], Keys[i][d_Name], (fDropChance[i]/(fAllChance/100)), "%");
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
//	fegyvermenu(id);


	give_item(id, "weapon_knife");
		if(!equal(FegyoMapName, "cs_max_fix"))
//		give_item(id, "weapon_hegrenade");
//	give_item(id, "weapon_flashbang");
	
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
	set_pev(ent, pev_classname, "case")
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
		
		if( !equal( classname, "case") )
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
	if(!is_user_connected(id))
		return;

	new szName[32];
	get_user_name(id, szName, charsmax(szName));

	switch(random_num(1, 5))
	{
		case 1: 
		{
			new Float:dollardrop = random_float(5.01, 19.20);
			g_dollar[id] += dollardrop;
			sk_chat(id, "^4%s^1 felvett egy ^3ládát^1, és talált benne ^4%3.2f^1 dollárt.", szName, dollardrop);
		}
		case 2:
		{
			sk_chat(id, "^4%s^1 felvett egy ^3ládát^1, és nem talált benne ^3semmit.", szName);
		}
		case 3: 
		{
			new lada = random_num(0, 4);
			Lada[lada][id]++;
			sk_chat(id, "^4%s^1 felvett egy ^3ládát^1, és talált benne ^4%s^1-t.", szName, Cases[lada][d_Name]);
		}
		case 4: 
		{
			new lada = random_num(0, 4);
			LadaK[lada][id]++;
			sk_chat(id, "^4%s^1 felvett egy ^3ládát^1, és talált benne ^4%s^1-t.", szName, Keys[lada][d_Name]);
		}
		case 5:
		{
			new esely = random_num(1,100)
			{
				if(esely >= 97) 
				{
					sk_chat(0, "^4%s^1 felvett egy ^3ládát^1, és talált benne egy ^3StatTrak* Tool^1-t! ^3Esélye:^4 3.00%s%", szName, "%");
					g_Tools[0][id]++;
					client_cmd(0,"spk ambience/thunder_clap");
				}
				if(esely <= 5)
				{
					g_Tools[1][id]++;
					client_cmd(0,"spk ambience/thunder_clap");
					sk_chat(0, "^4%s^1 felvett egy ^3ládát^1, és talált benne egy ^3Névcédulá^1-t! ^3Esélye:^4 4.00%s%", szName, "%");
				}
				else
				{
					sk_chat(0, "^4%s^1 felvett egy ^3ládát^1, és majdnem talált benne, ^3Névcédulát,^1 vagy ^3StatTrak* Toolt!", Player[id][f_PlayerNames]);
				}
			}		
		}
	}
}
public logevent_round_start()
{
	new hkt = FM_NULLENT;
	while ( ( hkt = fm_find_ent_by_class( hkt, "case") ) )
	{
		engfunc( EngFunc_RemoveEntity, hkt );
	}	
}

public T_Betu(id)
{
	if(!sk_get_logged(id))
		return;

	new iras[121]/* , String[121], itemNum */;
	format(iras, charsmax(iras), "%s \r[ \wFőmenü \r]^n\wDollár: \r%3.2f \d| \wPrémiumPont: \r%i", menuprefix, g_dollar[id], sk_get_pp(id));
	new menu = menu_create(iras, "T_Betu_h");

	menu_additem(menu, "\y|\d-\r-\y[ \wRaktár\y ]\r-\d-\y|","1");
	menu_additem(menu, "\y|\d-\r-\y[ \wLáda Nyitás\y ]\r-\d-\y|", "2", 0);
	menu_additem(menu, "\y|\d-\r-\y[ \wPiac\y ]\r-\d-\y|", "3", 0);
	menu_additem(menu, fmt("\y|\d-\r-\r[ \yKüldetések\r ]\r-\d-\y| %s", Questing[id][is_Questing] == 1 ? "\y(\dFolyamatban\y)" : "\y ]\r-\d-\y|"),"4");
	menu_additem(menu, "\y|\d-\r-\y[ \wBeállítások\y ]\r-\d-\y|", "5", 0);
	menu_additem(menu, "\y|\d-\r-\y[ \wPrémium Bolt\y ]\r-\d-\y|", "6", 0);
	menu_additem(menu, "\y|\d-\r-\y[ \wBolt\y ]\r-\d-\y|", "7", 0);
	menu_additem(menu, "\y|\d-\r-\y[ \wSzerencsejáték\y ]\r-\d-\y|", "8", 0);
  menu_additem(menu, "\y|\d-\r-\y[ \wJátékos Jelentés\y ]\r-\d-\y|", "13", 0);
	menu_additem(menu, "\y|\d-\r-\y[ \wJátékos Némítás\y ]\r-\d-\y|", "11", 0);
	menu_additem(menu, "\y|\d-\r-\y[ \wPrivát Üzenetek\y ]\r-\d-\y|", "16", 0);
	menu_additem(menu, "\y|\d-\r-\y[ \rFiókod \wadatai\y ]\r-\d-\y|", "14", 0);
	menu_additem(menu, "\y|\d-\r-\y[ \wSzerver \rSzabályzat\y ]\r-\d-\y|", "17", 0);

	menu_setprop(menu, MPROP_EXITNAME, "\rKilépés");
    menu_setprop(menu, MPROP_NEXTNAME, "\yKövetkező");
    menu_setprop(menu, MPROP_BACKNAME, "\yVissza");
	
    menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
    menu_display(id, menu);
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
		case 13: {
		client_cmd(id, "new_jelent")
		}
		case 14: fiokadatok(id);
		case 15: show_motd(id, "addons/amxmodx/configs/top10.html", "TOP10 Event Nyertesek");
		case 16: client_cmd(id, "say /pm")
		case 17:
		{ 		
		sk_chat(id, "^4[INFO] ^1- ^3Szerver szabályzatot megtalálod az alábbi linken! ^4[INFO]")
		sk_chat(id, "^4[INFO] ^1- ^3herboyd2.hu/1/szerverszabalyzat.php ^4[INFO]")
		}
		case 18: exillefragmenu(id);
	}
}


public Szerencsemenu(id)
{
	new iras[121]/* , String[121], itemNum, sztime[40] */;
	format(iras, charsmax(iras), "%s \r[ \wSzerencsejáték \r]", menuprefix);
	new menu = menu_create(iras, "Szerencsejatek_H");
	static iTime, ATime;
	iTime = porgettime[id]-get_systime();
  ATime = adminfizu[id]-get_systime();

	if(iTime <= 0)
	{
		menu_additem(menu, fmt("\yNapi \wpörgetés\r [\y1\wDB\r]"), "2", 0)
	}
	else
		menu_additem(menu, fmt("\yNapi \wpörgetés \r[\w%d \yóra\r | \w%02d \yperc\r]", iTime / 3600, ( iTime / 60) % 60), "2", 0)

	if(get_user_adminlvl(id) == 3 || get_user_adminlvl(id) == 2 || get_user_adminlvl(id) == 1 || get_user_adminlvl(id) == 4)
	{
		if(ATime <= 0)
		{
			menu_additem(menu, fmt("\yAdmin \wfizetés\r [\y1\wDB\r]"), "4", 0)
		}
		else
			menu_additem(menu, fmt("\yAdmin \wfizetés \r[\w%d \ynap\r | \w%d \yóra\r | \w%02d \yperc\r]", ATime / 86400, (ATime / 3600) % 24, (ATime / 60) % 60), "4", 0)
	}
	menu_setprop(menu, MPROP_EXITNAME, "\rKilépés");
    menu_setprop(menu, MPROP_NEXTNAME, "\yKövetkező");
    menu_setprop(menu, MPROP_BACKNAME, "\yVissza");
	
    menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);	

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
	static iTime, ATime;
	iTime = porgettime[id]-get_systime();
    ATime = adminfizu[id]-get_systime();

	switch(key)
	{
		case 1: coinflipmenu(id);
		case 2:
		{
			if(iTime <= 0)
			{
				sorsolas(id);
			}
			else
				sk_chat(id, "Nincs egyetlen egy pörgetésed sem! ^3:(")
			
		}
		case 3: newRoulette(id);
		case 4:
		{
			if(ATime <= 0)
			{
				adminfizu1(id);
			}
			else
				sk_chat(id, "Már megkaptad te hüje! ^3:(")
			
		}
		case 5: herboyhwmenu(id);
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public herboyhwmenu(id)
{
	new iras[121];
	format(iras, charsmax(iras), "%s \r[ \wTéli Ajándék 2023\r ]", menuprefix);
	new menu = menu_create(iras, "herboyhwmenu_H");
	static iTime;
	iTime = porgettimehw[id]-get_systime();

	if(iTime <= 0)
	{
		menu_additem(menu, fmt("\yJutalom \wátvétele\r [\y1\wDB\r]"), "1", 0)
	}
	else
		menu_additem(menu, fmt("\yJutalom \wátvétele \r[\w%d \ynap\r | \w%d \yóra\r | \w%02d \yperc\r]", iTime / 86400, (iTime / 3600) % 24, (iTime / 60) % 60), "1", 0)
	
	menu_setprop(menu, MPROP_EXITNAME, "\rKilépés");
    menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);	

	menu_display(id, menu, 0);
}
public herboyhwmenu_H(id, menu, item) {
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
	iTime = porgettimehw[id]-get_systime();

	switch(key)
	{
		case 1:
		{
			if(iTime <= 0)
			{
			sorsolashw(id);
			}
			else
				sk_chat(id, "Te már átvetted a jutalmad! ^3:(")
			
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public newRoulette(id)
{
	
	if(get_user_adminlvl(id) == 0)
	{
	sk_chat(id, "Ez csak ^3fejlesztőnek^1 érhető el!")
	return PLUGIN_HANDLED;
	}
	if(get_user_adminlvl(id) == 4 || get_user_adminlvl(id) == 3 || get_user_adminlvl(id) == 2)
	{
	sk_chat(id, "Ez csak ^3fejlesztőnek^1 érhető el!")
	return PLUGIN_HANDLED;
	}
	
	new Menu[512], MenuKey
  //add(Menu, 511, fmt("%s \y» \w\r[ \wRulett \r]^n\wDollár: \r%3.2f^n^n", menuprefixwhmt, g_dollar[id]));

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
			sk_chat(id, "tét: %i", Roulette[id][Placed])
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
	new SpinnedNumber = random(30)
	new Float:WinDollars = 0.0;
	new Float:LoseDollars = 0.0;

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
			LoseDollars = float(Roulette[id][Placed])

			if(Roulette[id][MiPorog] == 4)
			{
				sk_chat(id, "Azta, ^4%s ^1nyert a ruletten ^4%3.2f$^1-t, úgy hogy a ^4ZÖLDRE^1 fogadott, nyerőszám: ^4%i ^3(14x szorzó)", Player[id][f_PlayerNames], WinDollars, SpinnedNumber)
				g_dollar[id] += WinDollars;
				sk_log("Roulette", fmt("[SENDTOEXILLE] Uid: %i | %s | Tet: %i | Nyeremeny: %3.2f | PIROS | Nyeroszam: %i", g_Id[id], Player[id][f_PlayerNames], Roulette[id][Placed], WinDollars, SpinnedNumber));
			}
			else sk_chat(id, "Bukta! ^4%s^1 Bukott ^4%3.2f^1 dollárt rouletten! Nyerőszám: ^4%i", Player[id][f_PlayerNames], LoseDollars, SpinnedNumber)
			g_dollar[id] -= LoseDollars;
		}
		case 1..7: 
		{
			WinDollars = float(Roulette[id][Placed] * 2)
			LoseDollars = float(Roulette[id][Placed])

			if(Roulette[id][MiPorog] == 1)
			{
				sk_chat(id, "Azta, ^4%s ^1nyert a ruletten ^4%3.2f$^1-t, nyerőszám: ^4%i ^3(2x szorzó)", Player[id][f_PlayerNames], WinDollars, SpinnedNumber)
				g_dollar[id] += WinDollars;
				sk_log("Roulette", fmt("[SENDTOEXILLE] Uid: %i | %s | Tet: %i | Nyeremeny: %3.2f | FEKETE | Nyeroszam: %i", g_Id[id], Player[id][f_PlayerNames], Roulette[id][Placed], WinDollars, SpinnedNumber));
			}
			else sk_chat(id, "Bukta! ^4%s^1 Bukott ^4%3.2f^1 dollárt rouletten! Nyerőszám: ^4%i", Player[id][f_PlayerNames], LoseDollars, SpinnedNumber)
			g_dollar[id] -= LoseDollars;
		}
		case 8..14: 
		{
			WinDollars = float(Roulette[id][Placed] * 2)
			LoseDollars = float(Roulette[id][Placed] * 2)

			if(Roulette[id][MiPorog] == 2)
			{
				sk_chat(id, "Azta, ^4%s ^1nyert a ruletten ^4%3.2f$^1-t, nyerőszám: ^4%i ^3(2x szorzó)", Player[id][f_PlayerNames], WinDollars, SpinnedNumber)
				g_dollar[id] += WinDollars;
				sk_log("Roulette", fmt("[SENDTOEXILLE] Uid: %i | %s | Tet: %i | Nyeremeny: %3.2f | szurke | Nyeroszam: %i", g_Id[id], Player[id][f_PlayerNames], Roulette[id][Placed], WinDollars, SpinnedNumber));
			}
			else sk_chat(id, "Bukta! ^4%s^1 Bukott ^4%3.2f^1 dollárt rouletten! Nyerőszám: ^4%i", Player[id][f_PlayerNames], LoseDollars, SpinnedNumber)
			g_dollar[id] -= LoseDollars;
		}
		case 20..23: 
		{
			WinDollars = float(Roulette[id][Placed] * 4)
			LoseDollars = float(Roulette[id][Placed])

			if(Roulette[id][MiPorog] == 2)
			{
				sk_chat(id, "Azta, ^4%s ^1nyert a ruletten ^4%3.2f$^1-t, nyerőszám: ^4%i ^3(4x szorzó)", Player[id][f_PlayerNames], WinDollars, SpinnedNumber)
				sk_log("Roulette", fmt("[SENDTOEXILLE] Uid: %i | %s | Tet: %i | Nyeremeny: %3.2f | ZOLD | Nyeroszam: %i", g_Id[id], Player[id][f_PlayerNames], Roulette[id][Placed], WinDollars, SpinnedNumber));
				g_dollar[id] += WinDollars;
			}
			else sk_chat(id, "Bukta! ^4%s^1 Bukott ^4%3.2f^1 dollárt rouletten! Nyerőszám: ^4%i", Player[id][f_PlayerNames], LoseDollars, SpinnedNumber)
			g_dollar[id] -= LoseDollars;
		}
		default: { 
		sk_chat(id, "Ha ezt elmondod hogy csináltad, kapsz egy üveg kólát!"); 
		}
	}
	Roulette[id][MiPorog] = 0;
	Roulette[id][Placed] = 0;
	newRoulette(id);
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
	if(iErtek > 10000) {
		sk_chat(id,  "^1Nem tudsz^4 10000$-^1nál többet felrakni!")
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
public adminfizu1(id)
{
	switch(random_num(1,1))
	{
		case 1:
		{
			sk_set_pp(id, sk_get_pp(id)+1000);
			sk_chat(id, "^1Kaptál ^4 1000^1 Prémiumpontot! ^3Kösz a munkád fasz^1!")
			sk_log("SENDTOEXILLE", fmt("[SENDTOEXILLE] (%s) %s adminfizu (AccID: %i)", "asd", Player[id][f_PlayerNames], sk_get_accountid(id)))

		}
	}
	adminfizu[id] = get_systime() + 2678400;
}
public sorsolas(id)
{
	switch(random_num(1,6))
	{
		case 1:
		{
			new kulcsporgetes = random_num(0,4);
			new kulcsszam = random_num(2,15);
			LadaK[kulcsporgetes][id] += kulcsszam;
			sk_chat(id, "^1Pörgettél ^4%i^1 db ^3%s^1-t!", kulcsszam, Keys[kulcsporgetes][d_Name])

		}
		case 2:
		{
			new Float:randomDollar = random_float(10.00, 45.10)
			sk_chat(id, "^3Gratula! ^1Pörgettél ^4%3.2f^1 dollárt!", randomDollar)
			g_dollar[id] += randomDollar;

		}
		case 3:
		{
			new ladaporgetes = random_num(0,4);
			new ladaszam =  random_num(2,15);
			Lada[ladaporgetes][id] += ladaszam;
			sk_chat(id, "^1Pörgettél ^4%i^1 db ^3%s^1 ládát!", ladaszam, Cases[ladaporgetes][d_Name])
		}
		case 4..6:
		{
			sk_chat(id, "^3Ez nem a te napod! :(")
		}
	}
	porgettime[id] = get_systime() + 86400;
}
public sorsolashw(id)
{
	switch(random_num(1,10))
	{
		case 1:
		{
			new kulcsporgetes = random_num(1,6);
			new kulcsszam = random_num(5,50);
			LadaK[kulcsszam][id] += kulcsporgetes;
			sk_chat(id, "^1Pörgettél ^4%i^1 db ^3%s^1-t!", kulcsporgetes, Keys[kulcsszam][d_Name])
		}
		case 2:
		{
			new Float:randomDollar = random_float(10.00, 200.10)
			sk_chat(id, "^1Pörgettél ^4%3.2f^1 dollárt!", randomDollar)
			g_dollar[id] += randomDollar;
		}
		case 3:
		{
			new ladaporgetes = random_num(1,6);
			new ladaszam =  random_num(5,50);
			Lada[ladaszam][id] += ladaporgetes;
			sk_chat(id, "^1Pörgettél ^4%i^1 db ^3%s^1 ládát!", ladaporgetes, Cases[ladaszam][d_Name])
		}
		case 4:
		{
			g_Weapons[149][id]++;
			sk_chat(id, "^1Pörgettél ^4 1^1 db ^3HerBoy^1 kést!")
			sk_log("Karácsonyiajándék2023", fmt("[Karácsonyiajándék2023] (%s) %s Pörgetett 1 herboy kést. (AccID: %i)", "asd", Player[id][f_PlayerNames], sk_get_accountid(id)))
		}
		case 5:
		{
			sk_set_pp(id, sk_get_pp(id)+700);
			sk_chat(id, "^1Pörgettél ^4 700^1 Prémiumpontot! ^3Gratulálunk^1!")
			sk_log("Karácsonyiajándék2023", fmt("[Karácsonyiajándék2023] (%s) %s Pörgetett 700 Prémiumpontot. (AccID: %i)", "asd", Player[id][f_PlayerNames], sk_get_accountid(id)))

		}
		case 6:
		{
			new Float:randomDollar = random_float(10.00, 200.10)
			sk_chat(id, "^1Pörgettél ^4%3.2f^1 dollárt!", randomDollar)
			g_dollar[id] += randomDollar;
		}
		case 7:
		{
			new Float:randomDollar = random_float(10.00, 200.10)
			sk_chat(id, "^1Pörgettél ^4%3.2f^1 dollárt!", randomDollar)
			g_dollar[id] += randomDollar;
		}
		case 8:
		{
			new kulcsporgetes = random_num(1,6);
			new kulcsszam = random_num(5,50);
			LadaK[kulcsszam][id] += kulcsporgetes;
			sk_chat(id, "^1Pörgettél ^4%i^1 db ^3%s^1-t!", kulcsporgetes, Keys[kulcsszam][d_Name])
		}
		case 9:
		{
			new kulcsporgetes = random_num(1,6);
			new kulcsszam = random_num(5,50);
			LadaK[kulcsszam][id] += kulcsporgetes;
			sk_chat(id, "^1Pörgettél ^4%i^1 db ^3%s^1-t!", kulcsporgetes, Keys[kulcsszam][d_Name])
		}
		case 10:
		{
			new kulcsporgetes = random_num(1,6);
			new kulcsszam = random_num(5,50);
			LadaK[kulcsszam][id] += kulcsporgetes;
			sk_chat(id, "^1Pörgettél ^4%i^1 db ^3%s^1-t!", kulcsporgetes, Keys[kulcsszam][d_Name])
		}
	}
	porgettimehw[id] = get_systime() + 12009600;
}

public openLadaNyitas(id)
{
new String[121];
format(String, charsmax(String), "%s \r[ \wLáda Nyitás \r]", menuprefix);
new menu = menu_create(String, "Lada_h");
new ladasos = sizeof(Cases);

for(new i; i < ladasos; i++)
{
	new Sor[6]; num_to_str(i, Sor, 5);
	formatex(String, charsmax(String), "%s \d| \y%i\rDB \d| \yKulcs: \r%i", Cases[i][d_Name], Lada[i][id], LadaK[i][id]);
	menu_additem(menu, String, Sor);
}

menu_setprop(menu, MPROP_EXITNAME, "\rKilépés");

menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);		

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
	formatex(String, charsmax(String), "%s \r[ \wPrémium Bolt \r]^n\yPrémium Pontok: \d%i", menuprefix, sk_get_pp(id));
	new menu = menu_create(String, "m_PremiumBolt_h");
    
	
	menu_additem(menu, "\w[\yPrémiumpont\w] Vásárlás", "1")
	menu_additem(menu, "\w[\yPrémiumpont\w] csomagok", "2")
	menu_additem(menu, "Random Kés Pörgetés \w[\r400 PP\w]", "5", ADMIN_ADMIN)
	menu_additem(menu, "\w[\yVIP\w] csomagok \y[\rPrémiumpontból\y]", "3", ADMIN_ADMIN)
	menu_additem(menu, "\w[\ySkin\w] csomagok \y[\rPrémiumpontból\y]", "4", ADMIN_ADMIN)
	menu_additem(menu, "\w[\yPénz\w] Bolt \y[\rPrémiumpontból\y]", "6", ADMIN_ADMIN)
	menu_additem(menu, "\w[\ySkin\w] Bolt \y[\rPrémiumpontból\y]", "7", ADMIN_ADMIN)

	menu_setprop(menu, MPROP_EXITNAME, "\rKilépés");
	
    menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);	

	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}
public insert_buyinfos(id)
{
	console_print(id, "-------------------------------------------------------------------")
	console_print(id, "[PAYPAL LINK] : https://webadmin.synhosting.eu/p/herboy/?id=5&c=%i", g_Id[id])
	console_print(id, "[PAYSAFECARD LINK] : https://webadmin.synhosting.eu/p/herboy/?id=8&c=%i", g_Id[id]) 
	console_print(id, "Ezt másold be a böngésződbe, és a Feltöltendő összeghez írd be mennyit szeretnél vásárolni!")
	console_print(id, "Megjegyzés opcióba beírtuk a megfelelő szöveget! Ezzel ne foglalkozz!")
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
    new SteamId[33], IP[33]
    get_user_ip(id, IP, 33, 1)
    get_user_authid(id, SteamId, 33)
    new Time[40]
    format_time(Time, charsmax(Time), "%Y.%m.%d - %H:%M:%S", get_systime())
	
    switch(key)
    {
		case 1:
		{
			premiumpontmenu(id)
		}		
		case 2:
		{
			show_motd(id, "addons/amxmodx/configs/hbpont.html", "PremiumPont csomagok");
		}
		case 3:
		{
			vipcsomagok(id)
		}
		case 4:
		{
			skincsomagok(id)
		}
		case 5:
		{
			if(sk_get_pp(id) >= 400)
			{
				new kes = random_num (77, 188)

				switch(kes)
			    {
				case 118: 
					{
					m_PremiumBolt(id)
					sk_chat(id, "Pörgess újra! Ez a skin nincs a szerveren.")
					return;
					}
				case 136: 
					{
					m_PremiumBolt(id)
					sk_chat(id, "Pörgess újra! Ez a skin nincs a szerveren.")
					return;
					}
				case 151: 
					{
					m_PremiumBolt(id)
					sk_chat(id, "Pörgess újra! Ez a skin nincs a szerveren.")
					return;
					}
				case 157: 
					{
					m_PremiumBolt(id)
					sk_chat(id, "Pörgess újra! Ez a skin nincs a szerveren.")
					return;
					}
				case 166: 
					{
					m_PremiumBolt(id)
					sk_chat(id, "Pörgess újra! Ez a skin nincs a szerveren.")
					return;
					}
				case 175..180: 
					{
					m_PremiumBolt(id)
					sk_chat(id, "Pörgess újra! Ez a skin nincs a szerveren.")
					return;
					}
				case 182..185: 
					{
					m_PremiumBolt(id)
					sk_chat(id, "Pörgess újra! Ez a skin nincs a szerveren.")
					return;
					}
			    }
				if(FegyverInfo[kes][PiacraHelyezheto] == -2)
				{
					sk_chat(id, "Pörgess újra! Ez a skin nincs a szerveren.")
					m_PremiumBolt(id)
					return;
				}
				sk_log("PremiumPontVasarlas", fmt("[KESPORGETES] (%s) %s Pörgetett egy %s kést (Maradék pontok: %i / Vásárlás előtti pontok: %i / AccID: %i)", "asd", Player[id][f_PlayerNames], FegyverInfo[kes][GunName], sk_get_pp(id)-400, sk_get_pp(id), sk_get_accountid(id)))
				sk_set_pp(id, sk_get_pp(id)-400);
				g_Weapons[kes][id]++;
				sk_chat(0, "^4%s^1 pörgetett egy ^4%s^1 kést a ^3Prémium Boltból^1!", Player[id][f_PlayerNames], FegyverInfo[kes][GunName]);
			}
			else
			{
				sk_chat(id,  "^1 ^1Nincs elég ^3Prémium Pontod^1!");
			}
			m_PremiumBolt(id);
		}
		case 6:
		{
			moneyshop(id)
		}
		case 7:
		{
			premiumfegyobolt(id)
		}
	}
   
    
}
public vipcsomagok(id)
{
	new iras[121]
	format(iras, charsmax(iras), "%s \r[ \wVIP bolt\r]", menuprefix);
	new menu = menu_create(iras, "vipcsomagok_h");
	
	menu_additem(menu, "1 Hetes Prémium VIP \w[\r600 PP\w]", "1", 0)
	menu_additem(menu, "1 hónapos Prémium VIP \w[\r2000 PP\w]", "2", 0)
	menu_additem(menu, "3 hónapos Prémium VIP \w[\r4500 PP\w]", "3", 0)
	menu_additem(menu, "6 hónapos Prémium VIP \w[\r9000 PP\w]", "5", 0)
	menu_additem(menu, "12 hónapos Prémium VIP \w[\r15000 PP\w]", "6", 0)
	menu_additem(menu, "Örök Prémium VIP \w[\r20000 PP\w]", "4", 0)

	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	menu_setprop(menu, MPROP_BACKNAME, "\yVissza");
	menu_setprop(menu, MPROP_NEXTNAME, "\yKövetkező");
	menu_setprop(menu, MPROP_EXITNAME, "\rKilépés");
	menu_display(id, menu, 0);
	
}
public vipcsomagok_h(id, menu, item)
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
			if(sk_get_pp(id) >= 600)
			{
				sk_log("PremiumPontVasarlas", fmt("[VIP BUY] (%s) %s vett 1 hétre szóló pvipet, lejár: %s (Maradék pontok: %i / Vásárlás előtti pontok: %i / AccID: %i)", "asd", Player[id][f_PlayerNames], sztime, sk_get_pp(id)-600, sk_get_pp(id), sk_get_accountid(id)))
				sk_set_pp(id, sk_get_pp(id)-600);
				Vip[id][PremiumTime] = get_systime()+604800
				format_time(sztime, charsmax(sztime), "%Y.%m.%d - %H:%M:%S", Vip[id][PremiumTime])
				g_Weapons[156][id]++;
				sk_chat(id,  "^1Vettél egy^4 1 Hétre^1 szóló ^3Prémium ^4VIP^1-et. ^3Lejár ekkor: ^4%s", sztime);
			}
			else
			{
				sk_chat(id,  "^1Nincs elég ^3Prémium Pontod^1!");
			}
			vipcsomagok(id);
		}
		case 2:
		{
			if(sk_get_pp(id) >= 2000)
			{
				sk_log("PremiumPontVasarlas", fmt("[VIP BUY] (%s) %s vett 1 hónapra szóló pvipet, lejár: %s (Maradék pontok: %i / Vásárlás előtti pontok: %i / AccID: %i)", "asd", Player[id][f_PlayerNames], sztime, sk_get_pp(id)-2000, sk_get_pp(id), sk_get_accountid(id)))
				sk_set_pp(id, sk_get_pp(id)-2000);
				Vip[id][PremiumTime] = get_systime()+2592000
				format_time(sztime, charsmax(sztime), "%Y.%m.%d - %H:%M:%S", Vip[id][PremiumTime])
				g_Weapons[156][id]++;
				g_Weapons[157][id]++;
				g_Weapons[158][id]++;
				sk_chat(id,  "^1Vettél egy^4 1 hónapra^1 szóló ^3Prémium ^4VIP^1-et. ^3Lejár ekkor: ^4%s", sztime);
			}
			else
			{
				sk_chat(id,  "^1Nincs elég ^3Prémium Pontod^1!");
			}
			vipcsomagok(id);
		}
		case 3:
		{
			if(sk_get_pp(id) >= 4500)
			{
				sk_log("PremiumPontVasarlas", fmt("[VIP BUY] (%s) %s vett 3 hónapra szóló pvipet, lejár: %s (Maradék pontok: %i / Vásárlás előtti pontok: %i / AccID: %i)", "asd", Player[id][f_PlayerNames], sztime, sk_get_pp(id)-4500, sk_get_pp(id), sk_get_accountid(id)))
				sk_set_pp(id, sk_get_pp(id)-4500);
				Vip[id][PremiumTime] = get_systime()+7776000
				format_time(sztime, charsmax(sztime), "%Y.%m.%d - %H:%M:%S", Vip[id][PremiumTime])
                g_Weapons[156][id]++;
				g_Weapons[76][id]++;
				g_Weapons[77][id]++;
				sk_chat(id,  "^1Vettél egy^4 3 Hónapra^1 szóló ^3Prémium ^4VIP^1-et. ^3Lejár ekkor: ^4%s", sztime);
			}
			else
			{
				sk_chat(id,  "^1Nincs elég ^3Prémium Pontod^1!");
			}
			vipcsomagok(id);
		}
		case 4:
		 {
		 	if(sk_get_pp(id) >= 20000)
		 	{
				sk_log("PremiumPontVasarlas", fmt("[VIP BUY] (%s) %s vett örökre szóló pvipet, lejár: %s (Maradék pontok: %i / Vásárlás előtti pontok: %i / AccID: %i)", "asd", Player[id][f_PlayerNames], sztime, sk_get_pp(id)-20000, sk_get_pp(id), sk_get_accountid(id)))
		 		sk_set_pp(id, sk_get_pp(id)-20000);
		 		Vip[id][PremiumTime] = get_systime()+2629800*30
		 		format_time(sztime, charsmax(sztime), "%Y.%m.%d - %H:%M:%S", Vip[id][PremiumTime])
				g_Weapons[156][id]++;
				g_Weapons[157][id]++;
				g_Weapons[158][id]++;
		 		sk_chat(id,  "^1Vettél egy^4 Örökre^1 szóló ^3Prémium ^4VIP^1-et. ^3Lejár ekkor: ^4%s", sztime);
		 	}
		 	else
		 	{
		 		sk_chat(id,  "^1Nincs elég ^3Prémium Pontod^1!");
		 	}
		 	vipcsomagok(id);
		}
		case 5:
		 {
		 	if(sk_get_pp(id) >= 9000)
		 	{
				sk_log("PremiumPontVasarlas", fmt("[VIP BUY] (%s) %s vett örökre szóló pvipet, lejár: %s (Maradék pontok: %i / Vásárlás előtti pontok: %i / AccID: %i)", "asd", Player[id][f_PlayerNames], sztime, sk_get_pp(id)-9000, sk_get_pp(id), sk_get_accountid(id)))
		 		sk_set_pp(id, sk_get_pp(id)-9000);
		 		Vip[id][PremiumTime] = get_systime()+15552000
		 		format_time(sztime, charsmax(sztime), "%Y.%m.%d - %H:%M:%S", Vip[id][PremiumTime])
				g_Weapons[156][id]++;
				g_Weapons[157][id]++;
				g_Weapons[158][id]++;
		 		sk_chat(id,  "^1Vettél egy^4 6 hónapra^1 szóló ^3Prémium ^4VIP^1-et. ^3Lejár ekkor: ^4%s", sztime);
		 	}
		 	else
		 	{
		 		sk_chat(id,  "^1Nincs elég ^3Prémium Pontod^1!");
		 	}
		 	vipcsomagok(id);
		}
		case 6:
		 {
		 	if(sk_get_pp(id) >= 15000)
		 	{
				sk_log("PremiumPontVasarlas", fmt("[VIP BUY] (%s) %s vett örökre szóló pvipet, lejár: %s (Maradék pontok: %i / Vásárlás előtti pontok: %i / AccID: %i)", "asd", Player[id][f_PlayerNames], sztime, sk_get_pp(id)-15000, sk_get_pp(id), sk_get_accountid(id)))
		 		sk_set_pp(id, sk_get_pp(id)-15000);
		 		Vip[id][PremiumTime] = get_systime()+31104000
		 		format_time(sztime, charsmax(sztime), "%Y.%m.%d - %H:%M:%S", Vip[id][PremiumTime])
				g_Weapons[156][id]++;
				g_Weapons[157][id]++;
				g_Weapons[158][id]++;
		 		sk_chat(id,  "^1Vettél egy^4 12 hónapra^1 szóló ^3Prémium ^4VIP^1-et. ^3Lejár ekkor: ^4%s", sztime);
		 	}
		 	else
		 	{
		 		sk_chat(id,  "^1Nincs elég ^3Prémium Pontod^1!");
		 	}
		 	vipcsomagok(id);
		}
	}
}  
public skincsomagok(id)
{
	new iras[121]
	format(iras, charsmax(iras), "%s \r[ \wSkin csomagok\r]", menuprefix);
	new menu = menu_create(iras, "skincsomagok_h");
	

	menu_additem(menu, "Mitex Prémium Csomag \w[\r700 PP\w]", "1", 0)
	menu_additem(menu, "Green \yTRON\w Pack \w[\r750 PP\w]", "2", 0)
	menu_additem(menu, "Blue \yTRON\w Pack \w[\r750 PP\w]", "3", 0)
    menu_additem(menu, "Psyche \ySupaski\w Pack \w[\r1000 PP\w]", "4", 0)

	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	menu_setprop(menu, MPROP_BACKNAME, "\yVissza");
	menu_setprop(menu, MPROP_NEXTNAME, "\yKövetkező");
	menu_setprop(menu, MPROP_EXITNAME, "\rKilépés");
	menu_display(id, menu, 0);
	
}
public skincsomagok_h(id, menu, item)
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
    new SteamId[33], IP[33]
    get_user_ip(id, IP, 33, 1)
    get_user_authid(id, SteamId, 33)
    new Time[40]
    format_time(Time, charsmax(Time), "%Y.%m.%d - %H:%M:%S", get_systime())
	
    switch(key)
    {
		case 1:
		{
			if(sk_get_pp(id) >= 700)
			{
				sk_chat(id,  "^1 ^1Megávásároltad a ^3Mitex^1 csomagot.");
				sk_log("PremiumPontVasarlas", fmt("[Mitex BUY] (%s) %s vett 1 mitex csomagot (Maradék pontok: %i / Vásárlas előtti pontok: %i / AccID: %i)", "asd", Player[id][f_PlayerNames], sk_get_pp(id)-700, sk_get_pp(id), sk_get_accountid(id)))
				sk_set_pp(id, sk_get_pp(id)-700);
				g_Weapons[151][id]++;
				g_Weapons[155][id]++;
			}
			else
			{
				sk_chat(id,  "^1Nincs elég ^3Prémium Pontod^1!");
			}
			skincsomagok(id);
		}
		case 2:
		{
			if(sk_get_pp(id) >= 750)
			{
				sk_log("PremiumPontVasarlas", fmt("[Green Tron] (%s) %s vett 1 Green Tron csomagot (Maradék pontok: %i / Vásárlás előtti pontok: %i / AccID: %i)", "asd", Player[id][f_PlayerNames], sk_get_pp(id)-750, sk_get_pp(id), sk_get_accountid(id)))
				sk_chat(id,  "^1 ^1Megávásároltad a ^3Green Tron^1 csomagot.");
				sk_set_pp(id, sk_get_pp(id)-750);
				g_Weapons[76][id]++;
				g_Weapons[77][id]++;
			}
			else
			{
				sk_chat(id,  "^1Nincs elég ^3Prémium Pontod^1!");
			}
			skincsomagok(id);
		}
		case 3:
		{
			if(sk_get_pp(id) >= 750)
			{
				sk_log("PremiumPontVasarlas", fmt("[Blue Tron] (%s) %s vett 1 Blue Tron csomagot (Maradék pontok: %i / Vásárlás előtti pontok: %i / AccID: %i)", "asd", Player[id][f_PlayerNames], sk_get_pp(id)-750, sk_get_pp(id), sk_get_accountid(id)))
				sk_chat(id,  "^1 ^1Megávásároltad a ^3Blue Tron^1 csomagot.");
				sk_set_pp(id, sk_get_pp(id)-750);
				g_Weapons[157][id]++;
				g_Weapons[158][id]++;
			}
			else
			{
				sk_chat(id,  "^1Nincs elég ^3Prémium Pontod^1!");
			}
			skincsomagok(id);
		}
		case 4:
		{
			if(sk_get_pp(id) >= 1000)
			{
				sk_log("PremiumPontVasarlas", fmt("[Psyche Supaski] (%s) %s vett 1 Psyche Supaski csomagot (Maradék pontok: %i / Vásárlás előtti pontok: %i / AccID: %i)", "asd", Player[id][f_PlayerNames], sk_get_pp(id)-1000, sk_get_pp(id), sk_get_accountid(id)))
				sk_chat(id,  "^1 ^1Megávásároltad a ^3Psyche Supaski^1 csomagot.");
				sk_set_pp(id, sk_get_pp(id)-1000);
				g_Weapons[118][id]++;
				g_Weapons[121][id]++;
			}
			else
			{
				sk_chat(id,  "^1Nincs elég ^3Prémium Pontod^1!");
			}
			skincsomagok(id);
		}
		case 5:
		{
			if(sk_get_pp(id) >= 300)
			{
				sk_log("PremiumPontVasarlas", fmt("[Indirect csomag] (%s) %s vett 1 Indirect csomagot (Maradék pontok: %i / Vásárlás előtti pontok: %i / AccID: %i)", "asd", Player[id][f_PlayerNames], sk_get_pp(id)-300, sk_get_pp(id), sk_get_accountid(id)))
				sk_chat(id,  "^1 ^1Megávásároltad az ^3Indirect^1 csomagot.");
				sk_set_pp(id, sk_get_pp(id)-300);
				g_Weapons[28][id]++;
			}
			else
			{
				sk_chat(id,  "^1Nincs elég ^3Prémium Pontod^1!");
			}
			skincsomagok(id);
		}
	}
   
    
}
public moneyshop(id)
{
	new iras[121]
	format(iras, charsmax(iras), "%s \r[ \wPénz Bolt\r]", menuprefix);
	new menu = menu_create(iras, "moneyshop_h");
	

    menu_additem(menu, "\w1000.00\y$ \w[\r100 PP\w]", "6", 0)
	menu_additem(menu, "\w4000.00\y$ \w[\r400 PP\w]", "1", 0)
	menu_additem(menu, "\w10000.00\y$ \w[\r1000 PP\w]", "2", 0)
	menu_additem(menu, "\w30000.00\y$ \w[\r2000 PP\w]", "3", 0)
	menu_additem(menu, "\w50000.00\y$ \w[\r4000 PP\w]", "4", 0)
    menu_additem(menu, "\w70000.00\y$ \w[\r5000 PP\w]", "5", 0)

	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	menu_setprop(menu, MPROP_BACKNAME, "\yVissza");
	menu_setprop(menu, MPROP_NEXTNAME, "\yKövetkező");
	menu_setprop(menu, MPROP_EXITNAME, "\rKilépés");
	menu_display(id, menu, 0);
	
}
public moneyshop_h(id, menu, item)
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
    new SteamId[33], IP[33]
    get_user_ip(id, IP, 33, 1)
    get_user_authid(id, SteamId, 33)
    new Time[40]
    format_time(Time, charsmax(Time), "%Y.%m.%d - %H:%M:%S", get_systime())
	
    switch(key)
    {
		case 1:
		{
			if(sk_get_pp(id) >= 400)
			{
				sk_chat(id,  "^1 ^1Megávásároltál sikeresen ^3$4000-t!^1");
				sk_log("PremiumPontVasarlas", fmt("[Dollar Premium] (%s) %s vett 4000$ (Maradék pontok: %i / Vásárlas előtti pontok: %i / AccID: %i)", "asd", Player[id][f_PlayerNames], sk_get_pp(id)-400, sk_get_pp(id), sk_get_accountid(id)))
				sk_set_pp(id, sk_get_pp(id)-400);
				g_dollar[id] += 4000.00;
			}
			else
			{
				sk_chat(id,  "^1Nincs elég ^3Prémium Pontod^1!");
			}
			moneyshop(id);
		}
		case 2:
		{
			if(sk_get_pp(id) >= 1000)
			{
				sk_log("PremiumPontVasarlas", fmt("[Dollar Premium] (%s) %s vett 10000$ (Maradék pontok: %i / Vásárlás előtti pontok: %i / AccID: %i)", "asd", Player[id][f_PlayerNames], sk_get_pp(id)-1000, sk_get_pp(id), sk_get_accountid(id)))
				sk_chat(id,  "^1 ^1Megávásároltál sikeresen ^3$10000-t!^1");
				sk_set_pp(id, sk_get_pp(id)-1000);
				g_dollar[id] += 10000.00;
			}
			else
			{
				sk_chat(id,  "^1Nincs elég ^3Prémium Pontod^1!");
			}
			moneyshop(id);
		}
		case 3:
		{
			if(sk_get_pp(id) >= 2000)
			{
				sk_log("PremiumPontVasarlas", fmt("[Dollar Premium] (%s) %s vett 30000$ (Maradék pontok: %i / Vásárlás előtti pontok: %i / AccID: %i)", "asd", Player[id][f_PlayerNames], sk_get_pp(id)-2000, sk_get_pp(id), sk_get_accountid(id)))
				sk_chat(id,  "^1 ^1Megávásároltál sikeresen ^3$30000-t!^1");
				sk_set_pp(id, sk_get_pp(id)-2000);
				g_dollar[id] += 30000.00;
			}
			else
			{
				sk_chat(id,  "^1Nincs elég ^3Prémium Pontod^1!");
			}
			moneyshop(id);
		}
		case 4:
		{
			if(sk_get_pp(id) >= 4000)
			{
				sk_log("PremiumPontVasarlas", fmt("[Dollar Premium] (%s) %s vett 50000$ (Maradék pontok: %i / Vásárlás előtti pontok: %i / AccID: %i)", "asd", Player[id][f_PlayerNames], sk_get_pp(id)-4000, sk_get_pp(id), sk_get_accountid(id)))
				sk_chat(id,  "^1 ^1Megávásároltál sikeresen ^3$50000-t!^1");
				sk_set_pp(id, sk_get_pp(id)-4000);
				g_dollar[id] += 50000.00;
			}
			else
			{
				sk_chat(id,  "^1Nincs elég ^3Prémium Pontod^1!");
			}
			moneyshop(id);
		}
		case 5:
		{
			if(sk_get_pp(id) >= 5000)
			{
				sk_log("PremiumPontVasarlas", fmt("[Dollar Premium] (%s) %s vett 70000$ (Maradék pontok: %i / Vásárlás előtti pontok: %i / AccID: %i)", "asd", Player[id][f_PlayerNames], sk_get_pp(id)-5000, sk_get_pp(id), sk_get_accountid(id)))
				sk_chat(id,  "^1 ^1Megávásároltál sikeresen ^3$70000-t!^1");
				sk_set_pp(id, sk_get_pp(id)-5000);
				g_dollar[id] += 70000.00;
			}
			else
			{
				sk_chat(id,  "^1Nincs elég ^3Prémium Pontod^1!");
			}
			moneyshop(id);
		}
		case 6:
		{
			if(sk_get_pp(id) >= 100)
			{
				sk_log("PremiumPontVasarlas", fmt("[Dollar Premium] (%s) %s vett 1000$ (Maradék pontok: %i / Vásárlás előtti pontok: %i / AccID: %i)", "asd", Player[id][f_PlayerNames], sk_get_pp(id)-100, sk_get_pp(id), sk_get_accountid(id)))
				sk_chat(id,  "^1 ^1Megávásároltál sikeresen ^3$1000-t!^1");
				sk_set_pp(id, sk_get_pp(id)-100);
				g_dollar[id] += 1000.00;
			}
			else
			{
				sk_chat(id,  "^1Nincs elég ^3Prémium Pontod^1!");
			}
			moneyshop(id);
		}
	}
   
    
}
public premiumfegyobolt(id)
{
	new iras[121]
	format(iras, charsmax(iras), "%s \r[ \wPrémium Fegyverbolt \r]", menuprefix);
	new menu = menu_create(iras, "premiumfegyobolt_h");
	

	menu_additem(menu, "HerBoy kés \y[\r750\wPP\y]", "1", 0)
	menu_additem(menu, "Loius Vuitton AK47 \y[\r500\wPP\y]", "3", 0)
	menu_additem(menu, "Loius Vuitton KNIFE \y[\r400\wPP\y]", "5", 0)
	menu_additem(menu, "Fire AK47 \y[\r600\wPP\y]", "6", 0)
	menu_additem(menu, "Nike AK47 \y[\r400\wPP\y]", "7", 0)
	menu_additem(menu, "Baseball ütő \y[\r600\wPP\y]", "8", 0)
	menu_additem(menu, "Classic Frozen \y[\r600\wPP\y]", "9", 0)
	menu_additem(menu, "Axe Proton \y[\r600\wPP\y]", "10", 0)

	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	menu_setprop(menu, MPROP_BACKNAME, "\yVissza");
	menu_setprop(menu, MPROP_NEXTNAME, "\yKövetkező");
	menu_setprop(menu, MPROP_EXITNAME, "\rKilépés");
	menu_display(id, menu, 0);
	
}
public premiumfegyobolt_h(id, menu, item)
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
    new SteamId[33], IP[33]
    get_user_ip(id, IP, 33, 1)
    get_user_authid(id, SteamId, 33)
    new Time[40]
    format_time(Time, charsmax(Time), "%Y.%m.%d - %H:%M:%S", get_systime())
	
	switch(key)
	{
		case 1:
		{
			if(sk_get_pp(id) >= 750)
			{
				sk_log("PremiumPontVasarlas", fmt("[Fegyverbolt] (%s) %s vett 1 Herboy kést. (Maradék pontok: %i / Vásárlás előtti pontok: %i / AccID: %i)", "asd", Player[id][f_PlayerNames], sk_get_pp(id)-750, sk_get_pp(id), sk_get_accountid(id)))
				sk_chat(id,  "^1 ^1Megávásároltad a ^3Herboy^1 kést.");
				sk_set_pp(id, sk_get_pp(id)-750);
				g_Weapons[149][id]++;
			}
			else
			{
				sk_chat(id,  "^1Nincs elég ^3Prémium Pontod^1!");
			}
			premiumfegyobolt(id);
		}
		case 2:
		{
			if(sk_get_pp(id) >= 750)
			{
				sk_log("PremiumPontVasarlas", fmt("[Fegyverbolt] (%s) %s vett 1 Avatár kést. (Maradék pontok: %i / Vásárlás előtti pontok: %i / AccID: %i)", "asd", Player[id][f_PlayerNames], sk_get_pp(id)-750, sk_get_pp(id), sk_get_accountid(id)))
				sk_chat(id,  "^1 ^1Megávásároltad az ^3Avatár^1 kést.");
				sk_set_pp(id, sk_get_pp(id)-750);
				g_Weapons[150][id]++;
			}
			else
			{
				sk_chat(id,  "^1Nincs elég ^3Prémium Pontod^1!");
			}
			premiumfegyobolt(id);
		}
		case 3:
		{
			if(sk_get_pp(id) >= 500)
			{
				sk_log("PremiumPontVasarlas", fmt("[Fegyverbolt] (%s) %s vett 1 Loius Vuitton AK47. (Maradék pontok: %i / Vásárlás előtti pontok: %i / AccID: %i)", "asd", Player[id][f_PlayerNames], sk_get_pp(id)-500, sk_get_pp(id), sk_get_accountid(id)))				
				sk_chat(id,  "^1 ^1Megávásároltad a ^3Loius Vuitton^1 AK47-et.");
				sk_set_pp(id, sk_get_pp(id)-500);
				g_Weapons[178][id]++;
			}
			else
			{
				sk_chat(id,  "^1Nincs elég ^3Prémium Pontod^1!");
			}
			premiumfegyobolt(id);
		}
		case 4:
		{
			if(sk_get_pp(id) >= 400)
			{
				sk_log("PremiumPontVasarlas", fmt("[Fegyverbolt] (%s) %s vett 1 Crosshair AWP. (Maradék pontok: %i / Vásárlás előtti pontok: %i / AccID: %i)", "asd", Player[id][f_PlayerNames], sk_get_pp(id)-400, sk_get_pp(id), sk_get_accountid(id)))				
				sk_chat(id,  "^1 ^1Megávásároltad a ^3Crosshair^1 AWP-t.");
				sk_set_pp(id, sk_get_pp(id)-400);
				g_Weapons[189][id]++;
			}
			else
			{
				sk_chat(id,  "^1Nincs elég ^3Prémium Pontod^1!");
			}
			premiumfegyobolt(id);
		}
		case 5:
		{
			if(sk_get_pp(id) >= 400)
			{
				sk_log("PremiumPontVasarlas", fmt("[Fegyverbolt] (%s) %s vett 1 Loius Vuitton KNIFE. (Maradék pontok: %i / Vásárlás előtti pontok: %i / AccID: %i)", "asd", Player[id][f_PlayerNames], sk_get_pp(id)-400, sk_get_pp(id), sk_get_accountid(id)))				
				sk_chat(id,  "^1 ^1Megávásároltad a ^3Loius Vuitton^1 M4A1-et.");
				sk_set_pp(id, sk_get_pp(id)-400);
				g_Weapons[188][id]++;
			}
			else
			{
				sk_chat(id,  "^1Nincs elég ^3Prémium Pontod^1!");
			}
			premiumfegyobolt(id);
		}
		case 6:
		{
			if(sk_get_pp(id) >= 600)
			{
				sk_log("PremiumPontVasarlas", fmt("[Fegyverbolt] (%s) %s vett 1 Fire AK47. (Maradék pontok: %i / Vásárlás előtti pontok: %i / AccID: %i)", "asd", Player[id][f_PlayerNames], sk_get_pp(id)-600, sk_get_pp(id), sk_get_accountid(id)))				
				sk_chat(id,  "^1 ^1Megávásároltad a ^3Fire^1 AK47-et.");
				sk_set_pp(id, sk_get_pp(id)-600);
				g_Weapons[5][id]++;
			}
			else
			{
				sk_chat(id,  "^1Nincs elég ^3Prémium Pontod^1!");
			}
			premiumfegyobolt(id);
		}
		case 7:
		{
			if(sk_get_pp(id) >= 400)
			{
				sk_log("PremiumPontVasarlas", fmt("[Fegyverbolt] (%s) %s vett 1 Nike AK47. (Maradék pontok: %i / Vásárlás előtti pontok: %i / AccID: %i)", "asd", Player[id][f_PlayerNames], sk_get_pp(id)-400, sk_get_pp(id), sk_get_accountid(id)))				
				sk_chat(id,  "^1 ^1Megávásároltad a ^3Nike^1 AK47-et.");
				sk_set_pp(id, sk_get_pp(id)-400);
				g_Weapons[41][id]++;
			}
			else
			{
				sk_chat(id,  "^1Nincs elég ^3Prémium Pontod^1!");
			}
			premiumfegyobolt(id);
		}
		case 8:
		{
			if(sk_get_pp(id) >= 600)
			{
				sk_log("PremiumPontVasarlas", fmt("[Fegyverbolt] (%s) %s vett 1 Baseball ütő. (Maradék pontok: %i / Vásárlás előtti pontok: %i / AccID: %i)", "asd", Player[id][f_PlayerNames], sk_get_pp(id)-600, sk_get_pp(id), sk_get_accountid(id)))				
				sk_chat(id,  "^1 ^1Megávásároltad a ^3Baseball^1 ütőt!");
				sk_set_pp(id, sk_get_pp(id)-600);
				g_Weapons[122][id]++;
			}
			else
			{
				sk_chat(id,  "^1Nincs elég ^3Prémium Pontod^1!");
			}
			premiumfegyobolt(id);
		}
		case 9:
		{
			if(sk_get_pp(id) >= 600)
			{
				sk_log("PremiumPontVasarlas", fmt("[Fegyverbolt] (%s) %s vett 1 Classic Frozen. (Maradék pontok: %i / Vásárlás előtti pontok: %i / AccID: %i)", "asd", Player[id][f_PlayerNames], sk_get_pp(id)-600, sk_get_pp(id), sk_get_accountid(id)))				
				sk_chat(id,  "^1 ^1Megávásároltad a ^3Classic^1 Frozen-t.");
				sk_set_pp(id, sk_get_pp(id)-600);
				g_Weapons[138][id]++;
			}
			else
			{
				sk_chat(id,  "^1Nincs elég ^3Prémium Pontod^1!");
			}
			premiumfegyobolt(id);
		}
		case 10:
		{
			if(sk_get_pp(id) >= 600)
			{
				sk_log("PremiumPontVasarlas", fmt("[Fegyverbolt] (%s) %s vett 1 Axe Proton. (Maradék pontok: %i / Vásárlás előtti pontok: %i / AccID: %i)", "asd", Player[id][f_PlayerNames], sk_get_pp(id)-600, sk_get_pp(id), sk_get_accountid(id)))				
				sk_chat(id,  "^1 ^1Megávásároltad a ^3Axe^1 Proton-t.");
				sk_set_pp(id, sk_get_pp(id)-600);
				g_Weapons[140][id]++;
			}
			else
			{
				sk_chat(id,  "^1Nincs elég ^3Prémium Pontod^1!");
			}
			premiumfegyobolt(id);
		}
		case 11:
		{
			if(sk_get_pp(id) >= 600)
			{
				sk_log("PremiumPontVasarlas", fmt("[Fegyverbolt] (%s) %s vett 1 Classic  Sisty. (Maradék pontok: %i / Vásárlás előtti pontok: %i / AccID: %i)", "asd", Player[id][f_PlayerNames], sk_get_pp(id)-600, sk_get_pp(id), sk_get_accountid(id)))				
				sk_chat(id,  "^1 ^1Megávásároltad a ^3Classic Sisty^1 kést.");
				sk_set_pp(id, sk_get_pp(id)-600);
				g_Weapons[127][id]++;
			}
			else
			{
				sk_chat(id,  "^1Nincs elég ^3Prémium Pontod^1!");
			}
			premiumfegyobolt(id);
		}
		case 12:
		{
			if(sk_get_pp(id) >= 400)
			{
				sk_log("PremiumPontVasarlas", fmt("[Fegyverbolt] (%s) %s vett 1 AWP Rave. (Maradék pontok: %i / Vásárlás előtti pontok: %i / AccID: %i)", "asd", Player[id][f_PlayerNames], sk_get_pp(id)-400, sk_get_pp(id), sk_get_accountid(id)))				
				sk_chat(id,  "^1 ^1Megávásároltad az ^3AWP Rave^1 fegyvert.");
				sk_set_pp(id, sk_get_pp(id)-400);
				g_Weapons[96][id]++;
			}
			else
			{
				sk_chat(id,  "^1Nincs elég ^3Prémium Pontod^1!");
			}
			premiumfegyobolt(id);
		}
	}
	
}

public m_Bolt(id)
{
	new String[121];
	formatex(String, charsmax(String), "%s \r[ \wBolt \r]^n\yDollár: \d%3.2f", menuprefix, g_dollar[id]);
	new menu = menu_create(String, "h_Bolt");

	menu_additem(menu, "StatTrak* Tool \y[\r600.00\w$\y]", "4", 0)
	menu_additem(menu, "Névcédula \y[\r500.00\w$\y]", "5", 0)
	menu_additem(menu, "\y[\wLáda\y/\wKulcs\rbolt\y]", "7", 0)
	menu_additem(menu, "\y[\wFegyver\rbolt\y]", "19", 0)
	menu_additem(menu, "\y[\wKill\rbolt\y]", "420", 0)
	// menu_additem(menu, "Egyedi Chat Prefix \rEltávolítva.", "18", 0)
	/* if(g_Vip[id] == 1)
	{
	formatex(String, charsmax(String), "\r%iDB \wKulcsdrop növelése \w[\r%i$\w]", Player_Vip[id][v_keydrop], (COST_KEYDROPUPGRADE*Player_Vip[id][v_keydrop]));
	menu_additem(menu, String, "6", 0);
	formatex(String, charsmax(String), "\r%iDB \wLádadrop növelése \w[\r%i$\w]", Player_Vip[id][v_casedrop], (COST_CASEDROPUPGRADE*Player_Vip[id][v_casedrop]));
	menu_additem(menu, String, "7", 0);
	} */
	menu_setprop(menu, MPROP_EXITNAME, "\rKilépés");
    menu_setprop(menu, MPROP_NEXTNAME, "\yKövetkező");
    menu_setprop(menu, MPROP_BACKNAME, "\yVissza");
	
    menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);	

	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}
public LadaKulcsVasarlas(id)
{
	new String[121];
	formatex(String, charsmax(String), "%s \r[ \wLáda / Kulcs vásárlás \r]^n\yDollár: \d%3.2f", menuprefix, g_dollar[id]);
	new menu = menu_create(String, "Kulcs_h");

	menu_additem(menu, vastype[id] == 0 ? "Vásárlás Típusa: \rLáda \y| \dLádakulcs":"Vásárlás Típusa: \dLáda \y| \rLádakulcs", "-1",0)                          ;//"

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
	menu_setprop(menu, MPROP_EXITNAME, "\rKilépés");
    menu_setprop(menu, MPROP_NEXTNAME, "\yKövetkező");
    menu_setprop(menu, MPROP_BACKNAME, "\yVissza");
	
    menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);	
		
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
				sk_chat(0, "^^4%s^1 megvásárolta a ^3-t", Player[id][f_PlayerNames])
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
		if(g_dollar[id] >= 600.00)
		{
			g_dollar[id] -= 600.00;
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
		if(g_dollar[id] >= 500.00)
		{
			g_dollar[id] -= 500.00;
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
		case 19:
		{
        fegyobolt(id)
		}
		case 420:
		{
        killbolt(id)
		}
	}
}
public fegyobolt(id)
{
	new iras[121]
	format(iras, charsmax(iras), "%s \r[ \wFegyverbolt \r]", menuprefix);
	new menu = menu_create(iras, "fegyobolt_h");
	

	menu_additem(menu, "HerBoy kés \y[\r100000.00\w$\y]", "1", 0)
	menu_additem(menu, "Fire AK47 \y[\r20000.00\w$\y]", "6", 0)
	menu_additem(menu, "Nike AK47 \y[\r25000.00\w$\y]", "7", 0)
	menu_additem(menu, "Baseball ütő \y[\r35000.00\w$\y]", "8", 0)
	menu_additem(menu, "Classic Frozen \y[\r35000.00\w$\y]", "9", 0)
	menu_additem(menu, "Axe Proton \y[\r35000.00\w$\y]", "10", 0)
    menu_additem(menu, "Classic Sisty \y[\r35000.00\w$\y]", "11", 0)

	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	menu_setprop(menu, MPROP_BACKNAME, "\yVissza");
	menu_setprop(menu, MPROP_NEXTNAME, "\yKövetkező");
	menu_setprop(menu, MPROP_EXITNAME, "\rKilépés");
	menu_display(id, menu, 0);
	
}
public fegyobolt_h(id, menu, item)
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
		case 1:
		{
			if(g_dollar[id] >= 100000.00)
			{
				sk_chat(id,  "^1 ^1Megávásároltad a ^3Herboy^1 kést.");
				g_dollar[id] -= 100000;
				g_Weapons[149][id]++;
			}
			else
			{
				sk_chat(id,  "^1^4Sikertelen^1 vásárlás, nincs elég ^4$^1-d.");
			}
			fegyobolt(id);
		}
		case 2:
		{
			if(g_dollar[id] >= 30000.00)
			{
				sk_chat(id,  "^1 ^1Megávásároltad az ^3Avatár^1 kést.");
				g_dollar[id] -= 30000;
				g_Weapons[150][id]++;
			}
			else
			{
				sk_chat(id,  "^1^4Sikertelen^1 vásárlás, nincs elég ^4$^1-d.");
			}
			fegyobolt(id);
		}
		case 3:
		{
			if(g_dollar[id] >= 11000.00)
			{
				sk_chat(id,  "^1 ^1Megávásároltad a ^3Greenshot^1 AK47-et.");
				g_dollar[id] -= 11000;
				g_Weapons[50][id]++;
			}
			else
			{
				sk_chat(id,  "^1^4Sikertelen^1 vásárlás, nincs elég ^4$^1-d.");
			}
			fegyobolt(id);
		}
		case 4:
		{
			if(g_dollar[id] >= 800.00)
			{
				sk_chat(id,  "^1 ^1Megávásároltad a ^3Greenshot^1 Deaglet.");
				g_dollar[id] -= 800;
				g_Weapons[110][id]++;
			}
			else
			{
				sk_chat(id,  "^1^4Sikertelen^1 vásárlás, nincs elég ^4$^1-d.");
			}
			fegyobolt(id);
		}
		case 5:
		{
			if(g_dollar[id] >= 1000.00)
			{
				sk_chat(id,  "^1 ^1Megávásároltad a ^3Greenshot^1 M4A1-et.");
				g_dollar[id] -= 1000;
				g_Weapons[58][id]++;
			}
			else
			{
				sk_chat(id,  "^1^4Sikertelen^1 vásárlás, nincs elég ^4$^1-d.");
			}
			fegyobolt(id);
		}
		case 6:
		{
			if(g_dollar[id] >= 20000.00)
			{
				sk_chat(id,  "^1 ^1Megávásároltad a ^3Fire^1 AK47-et.");
				g_dollar[id] -= 20000;
				g_Weapons[5][id]++;
			}
			else
			{
				sk_chat(id,  "^1^4Sikertelen^1 vásárlás, nincs elég ^4$^1-d.");
			}
			fegyobolt(id);
		}
		case 7:
		{
			if(g_dollar[id] >= 25000.00)
			{
				sk_chat(id,  "^1 ^1Megávásároltad a ^3Nike^1 AK47-et.");
				g_dollar[id] -= 25000;
				g_Weapons[41][id]++;
			}
			else
			{
				sk_chat(id,  "^1^4Sikertelen^1 vásárlás, nincs elég ^4$^1-d.");
            }
			fegyobolt(id);
		}
		case 8:
		{
			if(g_dollar[id] >= 35000.00)
			{
				sk_chat(id,  "^1 ^1Megávásároltad a ^3Baseball^1 ütőt!");
				g_dollar[id] -= 35000;
				g_Weapons[122][id]++;
			}
			else
			{
				sk_chat(id,  "^1^4Sikertelen^1 vásárlás, nincs elég ^4$^1-d.");
            }
			fegyobolt(id);
		}
		case 9:
		{
			if(g_dollar[id] >= 35000.00)
			{
				sk_chat(id,  "^1 ^1Megávásároltad a ^3Classic^1 Frozen-t.");
				g_dollar[id] -= 35000;
				g_Weapons[138][id]++;
			}
			else
			{
				sk_chat(id,  "^1^4Sikertelen^1 vásárlás, nincs elég ^4$^1-d.");
            }
			fegyobolt(id);
		}
		case 10:
		{
			if(g_dollar[id] >= 35000.00)
			{
				sk_chat(id,  "^1 ^1Megávásároltad a ^3Axe^1 Proton-t.");
				g_dollar[id] -= 35000;
				g_Weapons[140][id]++;
			}
			else
			{
				sk_chat(id,  "^1^4Sikertelen^1 vásárlás, nincs elég ^4$^1-d.");
            }
			fegyobolt(id);
		}
		case 11:
		{
			if(g_dollar[id] >= 35000.00)
			{
				sk_chat(id,  "^1 ^1Megávásároltad a ^3Classic Sisty^1 kést.");
				g_dollar[id] -= 35000;
				g_Weapons[127][id]++;
			}
			else
			{
				sk_chat(id,  "^1^4Sikertelen^1 vásárlás, nincs elég ^4$^1-d.");
            }
			fegyobolt(id);
		}
		case 12:
		{
			if(g_dollar[id] >= 2700.00)
			{
				sk_chat(id,  "^1 ^1Megávásároltad az ^3AWP Rave^1 fegyvert.");
				g_dollar[id] -= 2700;
				g_Weapons[96][id]++;
			}
			else
			{
				sk_chat(id,  "^1^4Sikertelen^1 vásárlás, nincs elég ^4$^1-d.");
            }
			fegyobolt(id);
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
	if(FegyverInfo[OpenedWepID][PiacraHelyezheto] == -2  || FegyverInfo[OpenedWepID][PiacraHelyezheto] == 0)
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
				sk_chat(0, "^1^3%s^1 nyitott egy: ^3StatTrak* ^4%s^1-t. ^3Esélye: ^4%.3f%s%", name, FegyverInfo[OpenedWepID][GunName], (OpenedWepChance/(OverAll/100.0)),"%");
		else
				sk_chat(0, "^1^3%s^1 nyitott egy: ^4%s^1-t. ^3Esélye: ^4%.3f%s%", name, FegyverInfo[OpenedWepID][GunName], (OpenedWepChance/(OverAll/100.0)),"%");
		//client_cmd(0,"spk p2_hangok/kesnyitas");
	}
	else if(is_StatTrak)
		sk_chat(id, "^1^1Nyitottál egy: ^3StatTrak* ^4%s^1-t. ^3Esélye: ^4%.3f%s%", FegyverInfo[OpenedWepID][GunName], (OpenedWepChance/(OverAll/100.0)),"%");
	else
		sk_chat(id, "^1^1Nyitottál egy: ^4%s^1-t. ^3Esélye: ^4%.3f%s%", FegyverInfo[OpenedWepID][GunName], (OpenedWepChance/(OverAll/100.0)),"%");
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
		sk_chat(0, "^3%s^1 nyitott egy ajándékcsomagot és talált benne ^3drogot", Player[id][f_PlayerNames])
		}
		case 1:
		{
		entity_set_float(id, EV_FL_health, entity_get_float(id, EV_FL_health)+25.0 );
		sk_chat(0, "^3%s^1 nyitott egy ajándékcsomagot és talált benne ^3+25 HP-t.", Player[id][f_PlayerNames])
		}
		case 2:
		{
		set_user_armor(id, 200); 
		sk_chat(0, "^3%s^1 nyitott egy ajándékcsomagot és talált benne^3 200 Armort", Player[id][f_PlayerNames])
		}
		case 3: 
		{
		g_dollar[id] += random_float(0.01, 1.00)
		sk_chat(0, "^3%s^1 nyitott egy ajándékcsomagot és talált benne ^3Dollár.", Player[id][f_PlayerNames])
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

	menu_setprop(menu, MPROP_EXITNAME, "\rKilépés");
    menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);	

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

		sk_chat(0, "^4%s^1 tökös volt, és megcsinálta a küldetését. Kapott érte ^4%3.2f^1 dollárt%s", Player[id][f_PlayerNames], Questing[id][QuestDollarReward], Questing[id][QuestRare] == 1 ? ", meg ládákat, mert ritka küldit csinált." : ".")
		sk_log("Küldetések", fmt("[SENDTOEXILLE]  %s tökös volt, és megcsinálta a küldetését. Kapott érte %3.2f dollárt (AccID: %i)", Player[id][f_PlayerNames], Questing[id][QuestDollarReward], sk_get_accountid(id)))
		Questing[id][is_Questing] = 0;
	}
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
		short_time_length(id, sk_get_playtime(m_Index), timeunit_seconds, MinuteString, charsmax(MinuteString));
		if(oldhud[m_Index])
		{
			iLen += formatex(StringC[iLen], charsmax(StringC)-iLen, "Név: %s(#%i)^n^nÖlés: %i | HS: %i | Halál: %i^nJátszott idő: %s^nDollár: %3.2f^nPrémium Pont:  %i", Player[m_Index][f_PlayerNames], sk_get_accountid(m_Index), oles[m_Index], hs[m_Index], hl[m_Index], MinuteString, g_dollar[m_Index], sk_get_pp(m_Index));

			iLen += formatex(StringC[iLen], charsmax(StringC)-iLen, "^n");
				
			set_hudmessage(random(256), random(256), random(256), 0.01, 0.15, 0, 6.0, 1.1, 0.0, 0.2, next_hudchannel(id));
			ShowSyncHudMsg(id, dSync, StringC);
		}
		else
		{
			new MinuteString[80]
			short_time_length(id, sk_get_playtime(m_Index), timeunit_seconds, MinuteString, charsmax(MinuteString));
			new iLen, iLen2;
			iLen += formatex(StringC[iLen], 512,"Név: ^n^n");
			iLen2 += formatex(StringD[iLen2], 512,"        %s(#%i)^n^n", Player[m_Index][f_PlayerNames], g_Id[m_Index]);
			
			iLen += formatex(StringC[iLen], 512,"Dollár: ^n");
			iLen2 += formatex(StringD[iLen2], 512,"          %3.2f$^n", g_dollar[m_Index]);
			
			iLen += formatex(StringC[iLen], 512,"PrémiumPont: ^n");
			iLen2 += formatex(StringD[iLen2], 512,"                     %i Pont^n", sk_get_pp(m_Index));
			
			iLen += formatex(StringC[iLen], 512,"Ölés: ^n");
			iLen2 += formatex(StringD[iLen2], 512,"        %i^n", oles[m_Index]);
			
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
				Len = formatex(StringHud[Len], charsmax(StringHud)- Len, "Famas | Alap");
			}
			case CSW_MP5NAVY:
			{
				Len = formatex(StringHud[Len], charsmax(StringHud)- Len, "MP5 | Alap");
			}
			case CSW_SCOUT:
			{
				Len = formatex(StringHud[Len], charsmax(StringHud)- Len, "Scout | Alap");
			}
			case CSW_M3:
			{
				Len = formatex(StringHud[Len], charsmax(StringHud)- Len, "M3 | Alap");
			}
			case CSW_SMOKEGRENADE:
			{
				Len = formatex(StringHud[Len], charsmax(StringHud)- Len, "Füst Gránát");
			}
			case CSW_HEGRENADE:
			{
				Len = formatex(StringHud[Len], charsmax(StringHud)- Len, "Robbanó Gránát");
			}
			case CSW_FLASHBANG:
			{
				Len = formatex(StringHud[Len], charsmax(StringHud)- Len, "Vakító Gránát");
			}
			case CSW_C4:
			{
				Len = formatex(StringHud[Len], charsmax(StringHud)- Len, "C4");
			}
			case CSW_AUG:
			{
				Len = formatex(StringHud[Len], charsmax(StringHud)- Len, "AUG | Alap");
			}
			case CSW_MAC10:
			{
				Len = formatex(StringHud[Len], charsmax(StringHud)- Len, "MAC 10 | Alap");
			}
			case CSW_TMP:
			{
				Len = formatex(StringHud[Len], charsmax(StringHud)- Len, "TMP | Alap");
			}
			case CSW_GALIL:
			{
				Len = formatex(StringHud[Len], charsmax(StringHud)- Len, "Galil | Alap");
			}
			case CSW_USP:
			{
				Len = formatex(StringHud[Len], charsmax(StringHud)- Len, "USP | Alap");
			}
			case CSW_GLOCK18:
			{
				Len = formatex(StringHud[Len], charsmax(StringHud)- Len, "GLOCK18 | Alap");
			}
			case CSW_P228:
			{
				Len = formatex(StringHud[Len], charsmax(StringHud)- Len, "P228 | Alap");
			}
			case CSW_FIVESEVEN:
			{
				Len = formatex(StringHud[Len], charsmax(StringHud)- Len, "FIVESEVEN | Alap");
			}
			case CSW_ELITE:
			{
				Len = formatex(StringHud[Len], charsmax(StringHud)- Len, "Dual Elites | Alap");
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


	menu_additem(menu, "Skinek visszaállítása alapra", "4", 0);//"
	menu_additem(menu, g_SkinBeKi[id] == 0 ? "Skinek: \yBekapcsolva" : "Skinek: \rKikapcsolva", "1", 0);//"
	menu_additem(menu, HudOff[id] == 0 ? "HUD Kijelző: \yBekapcsolva" : "HUD Kijelző: \rKikapcsolva", "2",0);//"
    menu_additem(menu, Player[id][WeaponHud] == 0 ? "Fegyver HUD Kijelző: \yBekapcsolva" : "Fegyver HUD Kijelző: \rKikapcsolva", "12",0);//"
	menu_additem(menu, hirduz[id] == 0 ? "Hirdető Üzenetek: \yBekapcsolva" : "Hirdető Üzenetek: \rKikapcsolva", "8",0);	//"
	menu_additem(menu, nezlist[id] == 0 ? "Néző Lista: \yBekapcsolva" : "Néző Lista: \rKikapcsolva", "9",0);	  //"
	menu_additem(menu, killhang[id] == 0 ? "Ölés hangok: \yBekapcsolva" : "Ölés hangok: \rKikapcsolva", "10",0);       //"              //"           
//	menu_additem(menu, "Automatikus bejelentkezés törlése", "13");                                                                                                	                                                                                   	
//	menu_additem(menu, "Sebzés Jelző", "7");	
//	menu_additem(menu, "MVP Zenék", "11");                                          //"       

	menu_setprop(menu, MPROP_EXITNAME, "\rKilépés");
    menu_setprop(menu, MPROP_NEXTNAME, "\yKövetkező");
    menu_setprop(menu, MPROP_BACKNAME, "\yVissza");
	
    menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);		
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
	static iTime;
	iTime = Vip[id][PremiumTime]-get_systime(); 
	static sTime;
	
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
			korvegizene[id] = !korvegizene[id];
			client_cmd(id, "new_korvegi")
			openStatus(id);
		}
		case 7:
		{
			client_cmd(id, "hb_dmg")
		}
		case 8: 
		{
			hirduz[id] = !hirduz[id];
			client_cmd(id, "say /hirdetes")
			openStatus(id);
		}	
		case 9: 
		{
			nezlist[id] = !nezlist[id];
			client_cmd(id, "nezo_lista")
			openStatus(id);
		}
		case 10: 
		{
			killhang[id] = !killhang[id];
			client_cmd(id, "say /sounds")
			openStatus(id);
		}	
		case 11: 
		{
			client_cmd(id, "mvp_zenek")
		}
		case 12: 
		{
			Player[id][WeaponHud] = !Player[id][WeaponHud];
			openStatus(id);
		}
	
	}
	
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}


public fiokadatok(id)
{
	new cim[121];
	format(cim, charsmax(cim), "%s \r[ \wFiókod Adatai \r]", menuprefix);
	new menu = menu_create(cim, "fiokadatok_h");
	static iTime;
	iTime = Vip[id][PremiumTime]-get_systime(); 
	new regdate[33]
	sk_get_RegisterDate(id, regdate, 32);

	formatex(String, charsmax(String), "\wAzonosítód: \r(\w#%i\r)", g_Id[id]);
	menu_addtext2(menu, String);

	formatex(String, charsmax(String), "\wFejlövéseid: \r%i", hs[id]);
	menu_addtext2(menu, String);

	formatex(String, charsmax(String), "\wRangod: \r%s", Rangok[Rang[id]][RangName]);
	menu_addtext2(menu, String);
	
	formatex(String, charsmax(String), "\wKövetkező \rRangod: \w%s \r(\wMég \y%d \wölés\r)", Rangok[Rang[id]+1][RangName], Rangok[Rang[id]][Killek] - oles[id]);
	menu_addtext2(menu, String);

	if(Vip[id][isPremium] == 0)
	{
	formatex(String, charsmax(String), "\yVIP \widőd Lejár: \r[\wNem vagy VIP\r]");
	menu_addtext2(menu, String);
	}
	else if(Vip[id][isPremium] == 1)
	{
    formatex(String, charsmax(String), "\yVIP \widőd Lejár: \r[\w%d \ynap\r \w%d \yóra\r  \w%d \yperc\r]", iTime / 86400, (iTime / 3600) % 24, ( iTime / 60) % 60);
	menu_addtext2(menu, String);
	}

	formatex(String, charsmax(String), "\wRegisztrációd \rDátuma: \r[\w%s\r]", regdate);
	menu_addtext2(menu, String);

	if(get_user_adminlvl(id) == 3 || get_user_adminlvl(id) == 2)
	menu_additem(menu, "God Csomag \r[\yFőadmin JOG\r]", "1", ADMIN_IMMUNITY);		

	if(get_user_adminlvl(id) == 1 || get_user_adminlvl(id) == 2)
	menu_additem(menu, "Tulajdonos Csomag \r[\yTULAJ JOG\r]", "2", ADMIN_IMMUNITY);		

	menu_setprop(menu, MPROP_EXITNAME, "\rKilépés");
    menu_setprop(menu, MPROP_NEXTNAME, "\yKövetkező");
    menu_setprop(menu, MPROP_BACKNAME, "\yVissza");
	
    menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);		
	menu_display(id, menu, 0);
}
public fiokadatok_h(id, menu, item)
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
	static iTime;
	iTime = Vip[id][PremiumTime]-get_systime(); 

	switch(key)
	{
		case 1: hopiipack(id);
		case 2: TulajPack(id);
	}
}
public TulajPack(id)
	{	
		g_Tools[0][id] += 10;
		g_Tools[1][id] += 10;
		g_dollar[id] += 1000.00;
		sk_set_pp(id, sk_get_pp(id)+3000);
		for(new i;i < sizeof(FegyverInfo); i++)
		g_Weapons[i][id] += 1;
		for(new i;i < sizeof(Cases); i++)
		Lada[i][id] += 100;
		for(new i;i < sizeof(Cases); i++)
		LadaK[i][id] += 100;

		
		sk_chat(id,  "^3Sikeresen ^1megkaptad a ^4Tulaj Csomagot^1! ^3(^4EXILLE KING^3)");
		sk_log("addolas", fmt("%s Addolt egy EXILLE csomagot! (%s) AccountID: %i", Player[id][f_PlayerNames], "asd", sk_get_accountid(id)));
	}
public hopiipack(id)
	{	
		g_Tools[0][id] += 50;
		g_dollar[id] += 1000.00;
		for(new i;i < sizeof(FegyverInfo); i++)
		g_Weapons[i][id] += 1;
		for(new i;i < sizeof(Cases); i++)
		Lada[i][id] += 50;
		for(new i;i < sizeof(Cases); i++)
		LadaK[i][id] += 50;

		sk_chat(id,  "^3Sikeresen ^1megkaptad a ^4GOD Csomagot^1! ^3De csak óvatosan ám istenség! :)")
		sk_log("addolas", fmt("%s Addolt egy Főadmin csomagot! (%s) AccountID: %i ", Player[id][f_PlayerNames], "asd", sk_get_accountid(id)));
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
	
	menu_setprop(menu, MPROP_EXITNAME, "\rKilépés");
    menu_setprop(menu, MPROP_NEXTNAME, "\yKövetkező");
    menu_setprop(menu, MPROP_BACKNAME, "\yVissza");
	
    menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);		
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
		format(cim, charsmax(cim), "%s \r[ \wRaktár \r]", menuprefix);
		new menu = menu_create(cim, "BeallitasEloszto_h");
		
		menu_additem(menu, "\y|\d-\r-\y[ \wAK47 Skinek\y ]\r-\d-\y|", "1", 0);
		menu_additem(menu, "\y|\d-\r-\y[ \wM4A1 Skinek\y ]\r-\d-\y|", "2", 0);
		menu_additem(menu, "\y|\d-\r-\y[ \wAWP Skinek\y ]\r-\d-\y|", "3", 0);
		menu_additem(menu, "\y|\d-\r-\y[ \wDEAGLE Skinek\y ]\r-\d-\y|", "4", 0);
		menu_additem(menu, "\y|\d-\r-\y[ \wKÉS Skinek\y ]\r-\d-\y|", "5", 0);
		menu_additem(menu, "\y|\d-\r-\y[ \wST* Darabka / Elnevezés\y ]\r-\d-\y|", "7", 0);
		menu_additem(menu, "\y|\d-\r-\y[ \wSkin Gambling\y ]\r-\d-\y|", "8", 0);
		
		menu_setprop(menu, MPROP_EXITNAME, "\rKilépés");
		menu_setprop(menu, MPROP_NEXTNAME, "\yKövetkező");
		menu_setprop(menu, MPROP_BACKNAME, "\yVissza");
	
		menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);	
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
		//easy_time_length(timeun, timeunit_seconds, MinuteString, charsmax(MinuteString));
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

	menu_setprop(menu, MPROP_EXITNAME, "\rKilépés");
    menu_setprop(menu, MPROP_NEXTNAME, "\yKövetkező");
    menu_setprop(menu, MPROP_BACKNAME, "\yVissza");
	
    menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);		
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
	
  add(Menu, 511, fmt("\www.herboy.hu @ 2018-2023^n^n"));
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
	menu_setprop(menu, MPROP_EXITNAME, "\rKilépés");
    menu_setprop(menu, MPROP_NEXTNAME, "\yKövetkező");
    menu_setprop(menu, MPROP_BACKNAME, "\yVissza");
	
    menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);	
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
	
	if(strlen(g_GunNames[key][id]) < 1) {
	sk_chat(id,  "^1Kiválasztottad a(z) ^3%s%s ^1fegyvert!", g_StatTrak[key][id] >= 1 ? "StatTrak* " : "", FegyverInfo[key][GunName])
	}
	else 
	sk_chat(id,  "^1Kiválasztottad a(z) ^3%s%s ^1fegyvert!", g_StatTrak[key][id] >= 1 ? "StatTrak* " : "", g_GunNames[key][id])
    //sk_log("SENDTOEXILLE", fmt("[SENDTOEXILLE] (%s) %s Fegyverskint változtatott erre: %s%s (AccID: %i)", "asd", Player[id][f_PlayerNames], g_StatTrak[key][id] >= 1 ? "StatTrak* " : "", g_GunNames[key][id], sk_get_accountid(id)))
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
	RandomMoney = random_float(0.23, 0.75) + ((get_playersnum() + 0.0) * 0.3) / 100;
	
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
	//	
	//	if(Player[killer][ScreenEffect])
	//	{
	//		message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("ScreenFade"), {0,0,0}, killer);
	//		write_short(12000);
	//		write_short(0);
	//		write_short(0);
	//		write_byte(0);
	//		write_byte(0);
	//		write_byte(200);
	//		write_byte(120);
	//		message_end();
	//	}

	}
	if(read_data(2))
		hl[aldozat]++

	//EXPT[killer] += EXPKap;
	//EXPT[aldozat] -= EXPVesz;
  
	while(oles[killer] >= Rangok[Rang[killer]][Killek])
	{
		Rang[killer]++;
		sk_chat(0, "^4%s^1 rangot lépett, rang: ^4%s^1, következő rang: ^4%s", Player[killer][f_PlayerNames], Rangok[Rang[killer]][RangName], Rangok[Rang[killer]+1][RangName])

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

		if(read_data(3)) killer_hp += 5
		else killer_hp += 3
	
		set_user_health(killer, killer_hp)
	//	message_begin(MSG_ONE, get_user_msgid("ScreenFade"), {0,0,0}, killer)
	//	write_short(1<<10)
	//	write_short(1<<10)
	//	write_short(0x0000)
	//	write_byte(0)
	//	write_byte(0)
	//	write_byte(200)
	//	write_byte(75)
	//	message_end()
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
    		DropChanceAdder[i] += DropChance[i] / 100.0 * 25.0;
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
    sk_chat(0, "^3%s ^1találta ezt: ^4%s^1. ^3Esélye: ^4%.2f%s%", Nev, Keys[i-1][d_Name], (DropChance[i]/(OverallChance/100)), "%");
    i = ChaseNumber;
  }
	else if(ChanceOld < RandomNumber < ChanceNow && ChanceOld == 0.0)
	{
		Lada[i-1][id]++;
		sk_chat(0, "^3%s ^1találta ezt: ^4%s^1. ^3Esélye: ^4%.2f%s%", Nev, Keys[i-1][d_Name], (DropChance[i]/(OverallChance/100)), "%");
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
    		DropChanceAdder[i] += DropChance[i] / 100.0 * 25.0;
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
    sk_chat(0, "^3%s ^1találta ezt: ^4%s^1. ^3Esélye: ^4%.2f%s%", Nev, Cases[i-1][d_Name], (DropChance[i]/(OverallChance/100)), "%");
    i = ChaseNumber;
  }
   else if(ChanceOld < RandomNumber < ChanceNow && ChanceOld == 0.0)
	{
        Lada[i-1][id]++;
        sk_chat(0, "^3%s ^1találta ezt: ^4%s^1. ^3Esélye: ^4%.2f%s%", Nev, Keys[i-1][d_Name], (DropChance[i]/(OverallChance/100)), "%");
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

	g_Admins = ArrayCreate(AdminData);
	new fegyver = sizeof(FegyverInfo)
	new musicsizeof;
	musicsizeof = sizeof(MusicBoxMusics)

	for(new i;i < fegyver; i++) 
	{
		if(FegyverInfo[i][PiacraHelyezheto] != -2)
		{
			//precache_model(FegyverInfo[i][ModelName])
		}
			
	}
	//precache_model("models/AVHBSKINS/exille/case.mdl");
}
public LoadUtils() {

	
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
		console_print(0, "[HB Prémiumpont rendszer] - MySQL nem tudott csatlakozni!"); 
		console_print(0, "%s", Error); 
		return;
	}
	else console_print(0, "[HB Prémiumpont rendszer] - MySQL sikeresen csatlakozott! Csá EXILLE!"); 
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
	SQL_ThreadQuery(m_get_sql(), "createTableThread3", Query);
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
	SQL_ThreadQuery(m_get_sql(), "createTableThread", Query);
}
public tabla_2()
{
	new Len;
	static Query[10048];
	Len += formatex(Query[Len], charsmax(Query), "CREATE TABLE IF NOT EXISTS `Weapon` ");
	Len += formatex(Query[Len], charsmax(Query)-Len, "( ");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`Id` INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,");
	
	for(new i;i < 201; i++)
		Len += formatex(Query[Len], charsmax(Query)-Len, "`F_%i` INT(11) NOT NULL,", i);
	
	Len += formatex(Query[Len], charsmax(Query)-Len, "`Parameter` INT(11) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`User_Id` INT(11) NOT NULL DEFAULT 0)");
	SQL_ThreadQuery(m_get_sql(), "createTableThread", Query);
}
public tabla_4()
{
	new Len;
	static Query[10048];
	Len += formatex(Query[Len], charsmax(Query), "CREATE TABLE IF NOT EXISTS `StattrakKills` ");
	Len += formatex(Query[Len], charsmax(Query)-Len, "( ");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`Id` INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,");
	
	for(new i;i < 201; i++)
		Len += formatex(Query[Len], charsmax(Query)-Len, "`stk_%i` INT(11) NOT NULL,", i);
	
	Len += formatex(Query[Len], charsmax(Query)-Len, "`Parameter` INT(11) NOT NULL DEFAULT 0,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`User_Id` INT(11) NOT NULL DEFAULT 0)");
	SQL_ThreadQuery(m_get_sql(), "createTableThread", Query);
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
	SQL_ThreadQuery(m_get_sql(), "createTableThread", Query);
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
	SQL_ThreadQuery(m_get_sql(), "createTableThread", Query);
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
	SQL_ThreadQuery(m_get_sql(), "createTableThread2", Query);
}
public createTableThread3(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime) {

	if(Errcode)
		log_amx("[HIBA*] HIBAT DOBTAM: %s",Error);
}
public createTableThread2(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime) {
	if(Errcode)
		log_amx("[HIBA*] HIBAT DOBTAM: %s",Error);
}
public createTableThread(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime) {
	if(Errcode)
		log_amx("[HIBA*] HIBAT DOBTAM: %s",Error);

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
	SQL_ThreadQuery(m_get_sql(), "createTableThread", Query);
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
	SQL_ThreadQuery(m_get_sql(), "createTableThread", Query);
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
	SQL_ThreadQuery(m_get_sql(), "createTableThread", Query);
}
public QuerySetData(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime){
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) {
		log_amx("%s", Error);
		return;
	}
}
public Set_Permissions(id){
	new Flags;
	Flags = read_flags(Admin_Permissions[get_user_adminlvl(id)][1]);
	set_user_flags(id, Flags);
}
public CmdSetMONEY(id, level, cid){
	if(!str_to_num(Admin_Permissions[get_user_adminlvl(id)][2])){
	sk_chat(id,  "^1 ^3Nincs elérhetőseged^1 ehhez a parancshoz!");
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
		g_dollar[Is_Online] = 0;
		sk_chat(0, "^4%s^1(#^3%d^1) törölte ^4%s^1(#^3%d^1) egész vagyonát a rendszerből.", szName, g_Id[id], Player[Is_Online][f_PlayerNames], Arg_Int[0])
		sk_log("addolas", fmt("Admin: %s (#%d) törölte egész vagyonát %s (#%d) játékosnak.", szName, g_Id[id], Player[Is_Online][f_PlayerNames], Arg_Int[0]))
	}
	else if(Arg_Int[1] > 0)
	{
		g_dollar[Is_Online] += Arg_Int[1];
		sk_chat(0, "^4%s^1(#^3%d^1) adott ^4%i^1 dollárt ^4%s^1(#^3%d^1) játékosnak.", szName, g_Id[id], Arg_Int[1], Player[Is_Online][f_PlayerNames], Arg_Int[0])
		sk_log("addolas", fmt("Admin: %s (#%d) addolt %i dollárt %s (#%d) játékosnak.", szName, g_Id[id], Arg_Int[1], Player[Is_Online][f_PlayerNames], Arg_Int[0]))
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
		if(equal(FegyverInfo[i][GunName], "Unknown"))
			continue;

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
	

	client_cmd(id, "messagemode Nevcedula_nev")
	
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
	//sk_log("Skin namechange", fmt("[SENDTOEXILLE] (%s) %s Fegyvernevet változtatott erre: %s (AccID: %i)", "asd", Player[id][f_PlayerNames], g_GunNames[g_NameTagKey][id], sk_get_accountid(id)))
	g_Tools[1][id]--
	openTools(id)
	return PLUGIN_HANDLED
}
public exillefragmenu(id)
{
	new iras[121]
	format(iras, charsmax(iras), "%s \r[ \wFragverseny \r]", menuprefix);
	new menu = menu_create(iras, "exillefragmenu_h");
	
	menu_additem(menu, "\r[\wFrag inditás\r]", "1", 0);
	menu_additem(menu, "\r[\wFrag beállitások\r]", "2", 0);

    menu_addtext2(menu, "\d** Bármikor inditható csak mapváltás előtt ne! **")
    menu_addtext2(menu, "\d** 57. körig menjen max és a végén **")
    menu_addtext2(menu, "\d** Kézzel leállitani ->Frag beállitások! **")
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	menu_setprop(menu, MPROP_EXITNAME, "\rKilépés");

	menu_display(id, menu, 0);
}
public exillefragmenu_h(id, menu, item)
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
		case 1:{
		//hb_fragversenymenu(id)
		sk_log("fragverseny", fmt("[fragverseny] (%s) %s Belépett a fraginditás menübe! Valószinüleg verseny indult. (AccID: %i)", "asd", Player[id][f_PlayerNames], sk_get_accountid(id)))
		}
		//case 2: hb_fragversenymenusettings(id);
	}
}
public Piac(id)
{

//    g_Kirakva[id] = 0
//	g_Erteke[id] = 0.0
//	if(g_Kicucc[id] > 0 && g_Kicucc[id] <= 135) OsszesKirakott[0]--
//	else if(g_Kicucc[id] >= 136 && g_Kicucc[id] <= 147) OsszesKirakott[1]--
//	else if(g_Kicucc[id] >= 148 && g_Kicucc[id] <= 159) OsszesKirakott[2]--
//	else if(g_Kicucc[id] >= 160) OsszesKirakott[3]--
//	g_Kicucc[id] = 0
//	g_StatTrakBeKi[id] = false
//	g_NameTagBeKi[id] = false
	
	new iras[121]
	format(iras, charsmax(iras), "%s \r[ \wPiac \r]", menuprefix);
	new menu = menu_create(iras, "Piac_h");
	
	menu_additem(menu, "\y[\rEladás\y]", "2", 0);
	menu_additem(menu, "\y[\rVásárlás\y]", "1", 0);
	menu_additem(menu, "\y[\w\rItem\y/\rSkin\w Küldés\y]", "3", 0);
	menu_additem(menu, "\y[\rAjándék\w Csomagok\y]", "4", 0);

	menu_setprop(menu, MPROP_EXITNAME, "\rKilépés");
    menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);	

	menu_display(id, menu, 0); 
}
public Piac_h(id, menu, item)
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
		case 1: openBuyer1(id);
		case 2: openSeller(id);
		case 3: openSending(id);
		case 4: ajicsomi(id);
	}
}
public ajicsomi(id)
{
	new iras[121]
	format(iras, charsmax(iras), "%s \r[ \wAjándék Csomagok \r]", menuprefix);
	new menu = menu_create(iras, "ajicsomi_h");
	

	if(Elhasznal[0][id] == 1) format(String,charsmax(String),"Kezdő Csomag \r[\dElhasználva\r]");
	else format(String,charsmax(String),"Kezdő Csomag \r[\yElérhető\r]");
	menu_additem(menu,String,"1");
	
//	if(karacsony2023[id] == 0 && oles[id] > 99) 
//		format(String,charsmax(String),"HerBoy \rKarácsonyi \y Ajándék \r[\yElérhető\r]");
//	else if(oles[id] > 99)
//		format(String,charsmax(String),"HerBoy \rKarácsonyi \y Ajándék \r[\dElhasználva\r]");
//	else
//		format(String,charsmax(String),"HerBoy \rKarácsonyi \y Ajándék \r[\y100 ölés\r]");
//	menu_additem(menu,String,"2");

	if(sk_get_playtime(id) > 259200 && ajicsomag1[id] == 1) 
		format(String,charsmax(String),"Örökség ajándékcsomag \r[\dElhasználva\r]");
	else if(sk_get_playtime(id) > 259200)
		format(String,charsmax(String),"Örökség ajándékcsomag \r[\yElérhető\r]");
	else
		format(String,charsmax(String),"Örökség ajándékcsomag \r[\y3 nap Játékidő\r]");
	menu_additem(menu,String,"3");

	if(sk_get_playtime(id) > 604800 && ajicsomag2[id] == 1) 
		format(String,charsmax(String),"Lázadó ajándékcsomag \r[\dElhasználva\r]");
	else if(sk_get_playtime(id) > 604800)
		format(String,charsmax(String),"Lázadó ajándékcsomag \r[\yElérhető\r]");
	else
		format(String,charsmax(String),"Lázadó ajándékcsomag \r[\y7 nap Játékidő\r]");
	menu_additem(menu,String,"4");

	if(sk_get_playtime(id) > 1296000 && ajicsomag3[id] == 1) 
		format(String,charsmax(String),"Misztikus ajándékcsomag \r[\dElhasználva\r]");
	else if(sk_get_playtime(id) > 1296000)
		format(String,charsmax(String),"Misztikus ajándékcsomag \r[\yElérhető\r]");
	else
		format(String,charsmax(String),"Misztikus ajándékcsomag \r[\y15 Nap Játékidő\r]");
	menu_additem(menu,String,"5");

	if(sk_get_playtime(id) > 2160000 && ajicsomag4[id] == 1) 
		format(String,charsmax(String),"Hősies ajándékcsomag \r[\dElhasználva\r]");
	else if(sk_get_playtime(id) > 2160000)
		format(String,charsmax(String),"Hősies ajándékcsomag \r[\yElérhető\r]");
	else
		format(String,charsmax(String),"Hősies ajándékcsomag \r[\y25 Nap Játékidő\r]");
	menu_additem(menu,String,"6");

	if(sk_get_playtime(id) > 4320000 && ajicsomag5[id] == 1) 
		format(String,charsmax(String),"Nemesis ajándékcsomag \r[\dElhasználva\r]");
	else if(sk_get_playtime(id) > 4320000)
		format(String,charsmax(String),"Nemesis ajándékcsomag \r[\yElérhető\r]");
	else
		format(String,charsmax(String),"Nemesis ajándékcsomag \r[\y50 Nap Játékidő\r]");
	menu_additem(menu,String,"7");

	menu_setprop(menu, MPROP_EXITNAME, "\rKilépés");
    menu_setprop(menu, MPROP_NEXTNAME, "\yKövetkező");
    menu_setprop(menu, MPROP_BACKNAME, "\yVissza");
	
    menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);	
	
	menu_display(id, menu, 0); 
}
public ajicsomi_h(id, menu, item)
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
		case 1: StarterPack(id);
		case 2: karacsony(id);
		case 3: ajicsomag11(id);
		case 4: ajicsomag21(id);
		case 5: ajicsomag31(id);
		case 6: ajicsomag41(id);
		case 7: ajicsomag51(id);
	}
}

public karacsony(id)
	{
		if(karacsony2023[id] == 0)
		{
			karacsony2023[id] = 1;
			new Data[1];
			static Query[10048];
			Data[0] = id;
			
			formatex(Query, charsmax(Query), "UPDATE `profiles` SET `karacsony2023` = 1 WHERE `User_Id` = %d;", g_Id[id]);
			SQL_ThreadQuery(m_get_sql(), "QuerySetData", Query, Data, 1);
			sk_chat(id,  "Sikeresen ^1megkaptad a ^4karácsonyi csomagot^1! ^3(^4Karácsonyi skinek^3)");
			sk_log("Karácsonyiajándék2023", fmt("[Karácsony 2023] (%s) %s átvette az ajándékát 2023 karácsonyán.  (AccID: %i)", "asd", Player[id][f_PlayerNames], sk_get_accountid(id)))

            g_Weapons[11][id]++;
			g_Weapons[12][id]++;
			g_Weapons[13][id]++;
			g_Weapons[14][id]++;
			g_Weapons[17][id]++;

		}
		else{
			sk_chat(id,  "Sajnálom, ^1de te már átvetted a ^3karácsonyi jutalmad!");
			
		}
		ajicsomi(id);
	}
	public StarterPack(id)
	{
		if(Elhasznal[0][id] == 0)
		{
			g_dollar[id] += 50.00;
			Elhasznal[0][id] = 1;
			new Data[1];
			static Query[10048];
			Data[0] = id;

			
			formatex(Query, charsmax(Query), "UPDATE `profiles` SET `Elhasznalva1` = 1 WHERE `User_Id` = %d;", g_Id[id]);
			SQL_ThreadQuery(m_get_sql(), "QuerySetData", Query, Data, 1);
			sk_chat(id,  "^3Sikeresen ^1megkaptad az adott Csomagot^1!");
		}
		else{
			sk_chat(id,  "^3Sajnálom, ^1de te már elhasználtad ezt a ^3csomagot!");
		}
		ajicsomi(id);
	}
	public ajicsomag11(id)
	{
		if(ajicsomag1[id] == 0 && sk_get_playtime(id) > 259200)
		{
			new Data[1];
			static Query[10048];
			Data[0] = id;
			
			formatex(Query, charsmax(Query), "UPDATE `profiles` SET `ajicsomag1` = 1 WHERE `User_Id` = %d;", g_Id[id]);
			SQL_ThreadQuery(m_get_sql(), "QuerySetData", Query, Data, 1);
			g_dollar[id] += 240.00;
			g_Tools[0][id] += 1
            g_Tools[1][id] += 1
			LadaK[3][id] += 30;
			LadaK[4][id] += 30;
			ajicsomag1[id] = 1;
			sk_chat(id,  "^3Sikeresen ^1megkaptad az ^3Örökség ajándékcsomag Csomagot^1!");
			sk_log("SENDTOEXILLE", fmt("[SENDTOEXILLE] (%s) %s ajicsomag1  feloldva  (AccID: %i)", "asd", Player[id][f_PlayerNames], sk_get_accountid(id)))
		}
		else if(sk_get_playtime(id) > 259200)
		{
			sk_chat(id,  "^3Sajnálom, ^1de te már elhasználtad ezt a ^3csomagot!");
		}
		else{
			sk_chat(id,  "Sajnálom, ^1de neked nincs^3 3 nap^1 játszott időd hogy elhasználhasd ezt a ^3csomagot!");
		}
		ajicsomi(id)
	}
	public ajicsomag21(id)
	{
		if(ajicsomag2[id] == 0 && sk_get_playtime(id) > 604800)
		{
			new Data[1];
			static Query[10048];
			Data[0] = id;
			
			formatex(Query, charsmax(Query), "UPDATE `profiles` SET `ajicsomag2` = 1 WHERE `User_Id` = %d;", g_Id[id]);
			SQL_ThreadQuery(m_get_sql(), "QuerySetData", Query, Data, 1);
			g_dollar[id] += 670.00;
			g_Tools[0][id] += 3
            g_Tools[1][id] += 3
			LadaK[3][id] += 60;
			LadaK[4][id] += 60;
			ajicsomag2[id] = 1;
			sk_chat(id,  "^3Sikeresen ^1megkaptad az ^3Lázadó ajándékcsomag Csomagot^1!");
			sk_log("SENDTOEXILLE", fmt("[SENDTOEXILLE] (%s) %s ajicsomag2  feloldva  (AccID: %i)", "asd", Player[id][f_PlayerNames], sk_get_accountid(id)))
		}
		else if(sk_get_playtime(id) > 604800)
		{
			sk_chat(id,  "^3Sajnálom, ^1de te már elhasználtad ezt a ^3csomagot!");
		}
		else{
			sk_chat(id,  "Sajnálom, ^1de neked nincs^3 7 nap^1 játszott időd hogy elhasználhasd ezt a ^3csomagot!");
		}
		ajicsomi(id)
	}
	public ajicsomag31(id)
	{
		if(ajicsomag3[id] == 0 && sk_get_playtime(id) > 1296000)
		{
			new Data[1];
			static Query[10048];
			Data[0] = id;
			
			formatex(Query, charsmax(Query), "UPDATE `profiles` SET `ajicsomag3` = 1 WHERE `User_Id` = %d;", g_Id[id]);
			SQL_ThreadQuery(m_get_sql(), "QuerySetData", Query, Data, 1);
			g_dollar[id] += 1100.00;
			g_Tools[0][id] += 7
            g_Tools[1][id] += 7
			Lada[5][id] += 70;
			ajicsomag3[id] = 1;
			sk_chat(id,  "^3Sikeresen ^1megkaptad az ^3Misztikus ajándékcsomag Csomagot^1!");
			sk_log("SENDTOEXILLE", fmt("[SENDTOEXILLE] (%s) %s ajicsomag3  feloldva  (AccID: %i)", "asd", Player[id][f_PlayerNames], sk_get_accountid(id)))
		}
		else if(sk_get_playtime(id) > 1296000)
		{
			sk_chat(id,  "^3Sajnálom, ^1de te már elhasználtad ezt a ^3csomagot!");
		}
		else{
			sk_chat(id,  "Sajnálom, ^1de neked nincs^3 15 nap^1 játszott időd hogy elhasználhasd ezt a ^3csomagot!");
		}
		ajicsomi(id)
	}
	public ajicsomag41(id)
	{
		if(ajicsomag4[id] == 0 && sk_get_playtime(id) > 2160000)
		{
			new Data[1];
			static Query[10048];
			Data[0] = id;
			
			formatex(Query, charsmax(Query), "UPDATE `profiles` SET `ajicsomag4` = 1 WHERE `User_Id` = %d;", g_Id[id]);
			SQL_ThreadQuery(m_get_sql(), "QuerySetData", Query, Data, 1);
			g_dollar[id] += 2000.00;
			g_Tools[0][id] += 8
            g_Tools[1][id] += 8
			LadaK[5][id] += 70;
			ajicsomag4[id] = 1;
			sk_chat(id,  "^3Sikeresen ^1megkaptad az ^3Hősies ajándékcsomag Csomagot^1!");
			sk_log("SENDTOEXILLE", fmt("[SENDTOEXILLE] (%s) %s ajicsomag4  feloldva  (AccID: %i)", "asd", Player[id][f_PlayerNames], sk_get_accountid(id)))
		}
		else if(sk_get_playtime(id) > 2160000)
		{
			sk_chat(id,  "^3Sajnálom, ^1de te már elhasználtad ezt a ^3csomagot!");
		}
		else{
			sk_chat(id,  "Sajnálom, ^1de neked nincs^3 25 nap^1 játszott időd hogy elhasználhasd ezt a ^3csomagot!");
		}
		ajicsomi(id)
	}
	public ajicsomag51(id)
	{
		if(ajicsomag5[id] == 0 && sk_get_playtime(id) > 4320000)
		{
			new Data[1];
			static Query[10048];
			Data[0] = id;
			
			formatex(Query, charsmax(Query), "UPDATE `profiles` SET `ajicsomag5` = 1 WHERE `User_Id` = %d;", g_Id[id]);
			SQL_ThreadQuery(m_get_sql(), "QuerySetData", Query, Data, 1);
			g_dollar[id] += 4500.00;
			g_Tools[0][id] += 10
            g_Tools[1][id] += 10
			Lada[4][id] += 100;
			Lada[5][id] += 100;
			LadaK[4][id] += 100;
			LadaK[5][id] += 100
			ajicsomag5[id] = 1;
			sk_chat(id,  "^3Sikeresen ^1megkaptad az ^3Nemesis ajándék csomag Csomagot^1!");
			sk_log("SENDTOEXILLE", fmt("[SENDTOEXILLE] (%s) %s ajicsomag5  feloldva  (AccID: %i)", "asd", Player[id][f_PlayerNames], sk_get_accountid(id)))
			sk_set_pp(id, sk_get_pp(id)+800);
		}
		else if(sk_get_playtime(id) > 4320000)
		{
			sk_chat(id,  "^3Sajnálom, ^1de te már elhasználtad ezt a ^3csomagot!");
		}
		else{
			sk_chat(id,  "Sajnálom, ^1de neked nincs^3 50 nap^1 játszott időd hogy elhasználhasd ezt a ^3csomagot!");
		}
		ajicsomi(id)
	}

public openSeller(id) {

	new szMenu[121];
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
	
		if((FegyverInfo[g_Kicucc[id]][PiacraHelyezheto] == 1) && g_Erteke[id] > 0) 
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
				g_Kirakva[id] = 1
				if(g_Kicucc[id] >= 136 && g_Kicucc[id] <= 147) OsszesKirakott[1]++
				else if(g_Kicucc[id] >= 148 && g_Kicucc[id] <= 159) OsszesKirakott[2]++
				else if(g_Kicucc[id] >= 160) OsszesKirakott[3]++
			}
			sk_log("SellWeapons", fmt("[Sell WEAPON] (%s) %s kirakott a piacra %s targyat %3.2f dolcsiert (ST: %s / NM: %s)", "asd", iName, FegyverInfo[g_Kicucc[id]][GunName], g_Erteke[id],  g_StatTrakBeKi[id] ? "StatTrak* ":"", g_GunNames[g_Kicucc[id]][id]))
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
		
		sk_log("SellWeapons", fmt("[BUY WEAPON] (%s) %s vett a piacrol %s targyat %3.2f dolcsiert (ST: %s / NM: %s)", "asd", name, FegyverInfo[g_Kicucc[player]][GunName], g_Erteke[player],  g_StatTrakBeKi[player] ? "StatTrak* ":"", g_GunNames[g_Kicucc[player]][id]))
		new sztime[40];	
		new sztime1[40];	
		format_time(sztime, charsmax(sztime), "%Y.%m.%d - %H:%M:%S", get_systime())
		format_time(sztime1, charsmax(sztime1), "%Y.%m.%d", get_systime())
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
 
	formatex(szMenu, charsmax(szMenu), "%s \r[ \wJátékos választó \r]", menuprefix)
	new menu = menu_create(szMenu, "hPlayerChooser");
 
	for(new i; i<pnum; i++)
	{
		get_user_name(players[i], iName, charsmax(iName))
		num_to_str(players[i], szTempid, charsmax(szTempid))
		menu_additem(menu, iName, szTempid)
	}
	menu_setprop(menu, MPROP_EXITNAME, "\rKilépés");
    menu_setprop(menu, MPROP_NEXTNAME, "\yKövetkező");
    menu_setprop(menu, MPROP_BACKNAME, "\yVissza");
	
    menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);	
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
	get_players(players, pnum, "ch")
 
	formatex(szMenu, charsmax(szMenu), "%s \r[ \wJátékos Némítás \r]", menuprefix)
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
		sk_log("SendDollars", fmt("(%s) %s küldött %s-nak %3.2f dollárt.", "asd", iName, tName, iErtek + 0.009))
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

	if(FegyverInfo[g_ChooseThings[2][id]][PiacraHelyezheto] == 1) 
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
		sk_log("SendItems", fmt("[SEND DOLLAR] (%s) %s küldött %s-nak %i dollárt.", "asd", SendName, TempName, str_to_num(Data)))
		sk_chat(0, "^1^3%s ^1Küldött ^4%d Dollár^1-t ^3%s^1-nak", SendName, str_to_num(Data), TempName);

		targykuldes[id] = 0;
	}
	if(KuldesTip[id] == 0)
	{
		if(Send[id] >= 0 && Lada[Send[id]][id] >= str_to_num(Data))
		{
		Lada[Send[id]][TempID] += str_to_num(Data);
		Lada[Send[id]][id] -= str_to_num(Data);
		sk_log("SendItems", fmt("[SEND ITEM] (%s) %s küldött %s-nak %i darab %s ládát.", "asd", SendName, TempName, str_to_num(Data), Cases[Send[id]][d_Name]))
		sk_chat(0, "^1^3%s Küldött ^4%d %s^1-t ^3%s^1-nak", SendName, str_to_num(Data), Cases[Send[id]][d_Name], TempName);
		}
	}
	else
	{
		if(Send[id] >= 0 && LadaK[Send[id]][id] >= str_to_num(Data))
		{
			LadaK[Send[id]][TempID] += str_to_num(Data);
			LadaK[Send[id]][id] -= str_to_num(Data);
			sk_log("SendItems", fmt("[SEND ITEM] (%s) %s küldött %s-nak %i darab %s ládakulcsot.", "asd", SendName, TempName, str_to_num(Data), Keys[Send[id]][d_Name]))
			sk_chat(0, "^1^3%s Küldött ^4%d %s^1-t ^3%s-^1nak", SendName, str_to_num(Data), Keys[Send[id]][d_Name], TempName);
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
				sk_log("SendItems", fmt("[SEND WEAPON] (%s) %s küldött %s-nak %i darab %s fegyvert (%s).", "asd", iName, tName, iErtek, g_StatTrakBeKiSend[id] ? "StatTrak* ":"",  FegyverInfo[g_ChooseThings[2][id]][GunName]))
			}
			else
			{
				sk_chat(0,  "^4^3%s ^1küldött ^3%s^1-nak ^3%i ^1DB ^4%s%s ^1fegyvert!", iName, tName, iErtek, g_StatTrakBeKiSend[id] ? "StatTrak* ":"", g_GunNames[g_ChooseThings[2][id]][g_kUserID[id]])
				sk_log("SendItems", fmt("[SEND WEAPON] (%s) %s küldött %s-nak %i darab %s fegyvert (%s).", "asd", iName, tName, iErtek, g_StatTrakBeKiSend[id] ? "StatTrak* ":"", g_GunNames[g_ChooseThings[2][id]][g_kUserID[id]], FegyverInfo[g_ChooseThings[2][id]][GunName]))
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
    get_user_authid(id, Player[id][steamid], 32);

    read_args(Message, charsmax(Message));
    remove_quotes(Message);
    new Message_Size = strlen(Message);
    //get_players(players, inum, "ch");

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
			adminlen += formatex(AdminString[adminlen], charsmax(AdminString)-adminlen, "^4%s ^1| ^4%s", (Player[id][AdminIll] == 0 ? Admin_Permissions[get_user_adminlvl(id)][0] : Admin_Permissions[0][0]), g_Chat_Prefix[id]);
		else if(strlen(g_Chat_Prefix[id]) > 0 && Player[id][AdminIll] == 0)
			adminlen += formatex(AdminString[adminlen], charsmax(AdminString)-adminlen, "^4%s", g_Chat_Prefix[id]);
		else if(get_user_adminlvl(id) == 0 && strlen(g_Chat_Prefix[id]) > 0)
			adminlen += formatex(AdminString[adminlen], charsmax(AdminString)-adminlen, "^4%s", g_Chat_Prefix[id]);
		else
			adminlen += formatex(AdminString[adminlen], charsmax(AdminString)-adminlen, "^4%s", (Player[id][AdminIll] == 0 ? Admin_Permissions[get_user_adminlvl(id)][0] : Admin_Permissions[0][0]));

		len += formatex(String[len], charsmax(String)-len, "^3[^4%s ^1| ^4%s^3%s] ^1» ", AdminString, Rangok[Rang[id]][RangName], Vip[id][isPremium] == 1 ? " ^1| ^4Prémium VIP^3" : "");

		if(Vip[id][isPremium] == 1 || (get_user_adminlvl(id) > 0 && Player[id][AdminIll] == 0))
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

public exillefegyvermenu(id)
{

	if(get_user_adminlvl(id) == 0)
	{
		sk_chat(id, "Ez a command csak ^3adminoknak^1 érhető el!")
		return PLUGIN_HANDLED;
	}

	if(fegyvermenus == 0)
		return PLUGIN_HANDLED;

		if(Buy[id]){
        sk_chat(id,  "^1Ebben a körben már választottál fegyvert!");
        return PLUGIN_CONTINUE;
    }
    
    new menu = menu_create(fmt("[Nagyfaszúak] \r » \r[ \wVIP Fegyvermenü \r]", 0), "handler");


    menu_additem(menu, "\y|\d-\r-\y[ \wTMP\y ]\r-\d-\y|", "1", 0);
    menu_additem(menu, "\y|\d-\r-\y[ \wUMP\y ]\r-\d-\y|", "2", 0);
    menu_additem(menu, "\y|\d-\r-\y[ \wP90\y ]\r-\d-\y|", "3", 0);
    menu_additem(menu, "\y|\d-\r-\y[ \wSG552\y ]\r-\d-\y|", "4", 0);
    menu_additem(menu, "\y|\d-\r-\y[ \wMAC10\y ]\r-\d-\y|", "6", 0);
	
	menu_setprop(menu, MPROP_EXITNAME, "\rKilépés");
    menu_setprop(menu, MPROP_NEXTNAME, "\yKövetkező");
    menu_setprop(menu, MPROP_BACKNAME, "\yVissza");
	
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
		give_player_grenades2(id);
	    set_user_armor(id, 100);
		give_item(id, "item_kevlar");
        give_item(id, "weapon_knife");
        give_item(id, "weapon_tmp");
        cs_set_user_bpammo(id, CSW_TMP, 30);
		sk_chat(id, "Csak okosan te ^3faszfej!^1")
    }
    case 2:
    {
    give_player_grenades2(id);
    set_user_armor(id, 100);
    give_item(id, "item_kevlar");
    give_item(id, "weapon_knife");
    give_item(id, "weapon_ump45"); 
    cs_set_user_bpammo(id, CSW_UMP45, 30); 
	sk_chat(id, "Csak okosan te ^3faszfej!^1")
    }
    case 3:
    {
		give_player_grenades2(id);
	    set_user_armor(id, 100);
		give_item(id, "item_kevlar");
        give_item(id, "weapon_knife");
        give_item(id, "weapon_p90");
        cs_set_user_bpammo(id, CSW_P90, 50);
		sk_chat(id, "Csak okosan te ^3faszfej!^1")
    }
    case 4:
    {
		give_player_grenades2(id);
	    set_user_armor(id, 100);
		give_item(id, "item_kevlar");
        give_item(id, "weapon_knife");
        give_item(id, "weapon_sg552");
        cs_set_user_bpammo(id, CSW_SG552, 30);
		sk_chat(id, "Csak okosan te ^3faszfej!^1")
    }
    case 6:
    {
    give_player_grenades2(id);
	set_user_armor(id, 100);
	give_item(id, "item_kevlar");
    give_item(id, "weapon_knife");
    give_item(id, "weapon_mac10");
    cs_set_user_bpammo(id, CSW_MAC10, 30);
	sk_chat(id, "Csak okosan te ^3faszfej!^1")
    }
    }
    return PLUGIN_HANDLED;
}

stock give_player_grenades2(index)
{
    give_item(index, "item_assaultsuit")
    	if(!equal(FegyoMapName, "cs_max_fix"))
		give_item(index, "weapon_hegrenade");
    give_item(index, "weapon_flashbang");
    give_item(index, "weapon_flashbang");
    give_item(index, "item_thighpack");
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
    cs_set_user_bpammo(index,CSW_DEAGLE,50);
    Buy[index] = index;
    
}
public client_putinserver(id)
{
	get_user_name(id, Player[id][f_PlayerNames], 64);
	get_user_authid(id, Player[id][steamid], 32);

	if(containi(Player[id][steamid], "VALVE_ID_LAN")  != -1 || containi(Player[id][steamid], "STEAM_ID_LAN") != -1 || containi(Player[id][steamid], "HLTV") != -1)
	{
		sk_chat(0, "^3HerBoy ^4AC ^1kirúgta a szerverről ^4%s^1-t, ^4Érvénytelen Kliens^1 indokkal.", Player[id][f_PlayerNames])
		server_cmd("kick #%d ^"Ez a kliens nem kompatiliblis a szerverrel! Tölts le egy másikat innen: www.herboy.hu/kliens.exe!^"", get_user_userid(id));
	}
	if(containi(Player[id][f_PlayerNames], "CSKozosseg.hu Kliens") != -1 || containi(Player[id][f_PlayerNames], "Player") != -1 || containi(Player[id][f_PlayerNames], "anyad") != -1 || containi(Player[id][f_PlayerNames], "Fullserver") != -1 || containi(Player[id][f_PlayerNames], ".hu/csletoltes") != -1 || containi(Player[id][f_PlayerNames], "nexusgaming") != -1) {
		sk_chat(0, "^3HerBoy ^4AC ^1kirúgta a szerverről ^4%s^1-t, ^4Névváltás^1 indokkal.", Player[id][f_PlayerNames])
		server_cmd("kick #%d ^"Válts nevet!/change name!^"", get_user_userid(id));
	}
	if(containi(Player[id][f_PlayerNames], "143.42.54.115:27015") != -1 || containi(Player[id][f_PlayerNames], ":27015") != -1 || containi(Player[id][f_PlayerNames], "217.79.187.33:27015") != -1 || containi(Player[id][f_PlayerNames], "anyád") != -1 || containi(Player[id][f_PlayerNames], "cigany") != -1 || containi(Player[id][f_PlayerNames], "cigány") != -1) {
		server_cmd("kick #%d ^"Válts nevet!/change name!^"", get_user_userid(id));
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
	if(!str_to_num(Admin_Permissions[get_user_adminlvl(id)][3])){
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
			Vip[Is_Online][PremiumTime] = get_systime()+86400*Arg_Int[1]
			format_time(sztime, charsmax(sztime), "%Y.%m.%d - %H:%M:%S", Vip[id][PremiumTime])
			sk_chat(0, "Játékos: ^3%s ^1(#^3%d^1) | VIP Tagságot kapott ^3%d^1 napra! ^3%s^1(#^3%d^1) által!", Player[Is_Online][f_PlayerNames], Arg_Int[0], Arg_Int[1], szName, g_Id[id]);
			sk_chat(Is_Online, "Kaptál^4 %d Napra^1 szóló‚ ^3VIPet^1. ^3Lejár ekkor: ^4%s", Arg_Int[1], sztime);	
			sk_log("VIPADDOLAS", fmt("[SENDTOEXILLE] Játékos: %s (#%d) | VIP Tagságot kapott %d napra! %s(#%d) által!", Player[Is_Online][f_PlayerNames], Arg_Int[0], Arg_Int[1], szName, g_Id[id]))
		}
		else 
		{
			sk_chat(0, "Játékos: ^3%s ^1(#^3%d^1) | VIP Tagság megvonva! ^3%s^1(#^3%d^1) által!", Player[Is_Online][f_PlayerNames], Arg_Int[0], szName, g_Id[id]);	
			Vip[Is_Online][PremiumTime] = 0;
			sk_log("VIPADDOLAS", fmt("[SENDTOEXILLE] Játékos: %s (#%d) | VIP Tagság megvonva! %s(#%d) által!", Player[Is_Online][f_PlayerNames], Arg_Int[0], szName, g_Id[id]))
		}
	}
	else
		client_print(id, print_console, "A jatekos nincs fent!");
	
	
	return PLUGIN_HANDLED;
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
	SQL_FreeHandle(m_get_sql());
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
	new Float:randomdolcsi = random_float(0.70, 1.05);
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
	SQL_ThreadQuery(m_get_sql(), ForwardMetod, Query, Data, 1);
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

			chathang[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "chathang"));
			killhang[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "killhang"));
			nezlist[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "nezlist"));
			hirduz[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "hirduz"));
			HudOff[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "HudBeKi"));
			Player[id][WeaponHud] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "weaponhud"));
			korvegizene[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "korvegizene"));
			g_Tools[1][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Nevcedula"));
			g_VipTime[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "viptime"));
			Vip[id][PremiumTime] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "PremiumTime"));
			Player[id][SSzint] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "KSzint"));
			hs[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "fejloves"));
			hl[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "halal"));
			oles[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "oles"));
			porgettime[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "porgettime"));
			porgettimehw[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "porgettimehw"));
			adminfizu[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "adminfizu"));
			Korvegi[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Korvegi"));
			MusicBoxEquiped[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "MusicBoxEquiped"));
			Elhasznal[0][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Elhasznalva1"));
			Elhasznal[1][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Elhasznalva2"));
			Elhasznal[2][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Elhasznalva3"));
			Elhasznal[3][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Elhasznalva4"));
			Elhasznal[4][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Elhasznalva5"));
			Elhasznal[5][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Elhasznalva6"));
			Elhasznal[6][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Elhasznalva7"));
			Elhasznal[7][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Elhasznalva8"));
			Elhasznal[8][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Elhasznalva9"));
			Elhasznal[9][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Elhasznalva10"));
			Elhasznal[10][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Elhasznalva11"));
			Elhasznal[12][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Elhasznalva12"));
			Elhasznal[13][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Elhasznalva13"));
			Elhasznal[14][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Elhasznalva14"));
			Elhasznal[15][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Elhasznalva15"));
			Elhasznal[16][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Elhasznalva16"));
			Elhasznal[17][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Elhasznalva17"));
			Elhasznal[18][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Elhasznalva18"));
			Elhasznal[19][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Elhasznalva19"));
			Elhasznal[20][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Elhasznalva20"));
			Elhasznal[21][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Elhasznalva21"));
			Elhasznal[22][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Elhasznalva22"));
			Elhasznal[23][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Elhasznalva23"));
			Elhasznal[24][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Elhasznalva24"));
			Elhasznal[25][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Elhasznalva25"));
			Elhasznal[26][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Elhasznalva26"));
			Elhasznal[27][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Elhasznalva27"));
			Elhasznal[28][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Elhasznalva28"));
			Elhasznal[29][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Elhasznalva29"));
			Elhasznal[30][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Elhasznalva30"));
			Elhasznal[31][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Elhasznalva31"));
			Elhasznal[32][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Elhasznalva32"));
			Elhasznal[33][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Elhasznalva33"));
			karacsony2023[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "karacsony2023"));
			ajicsomag1[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "ajicsomag1"));
			ajicsomag2[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "ajicsomag2"));
			ajicsomag3[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "ajicsomag3"));
			ajicsomag4[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "ajicsomag4"));
			ajicsomag5[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "ajicsomag5"));
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
			//sql_create_nametag2_row(id);
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
            for(new i;i < fegyver; i++)
            {
                new String[64];
                formatex(String, charsmax(String), "N%d", i);
                SQL_ReadResult(Query, SQL_FieldNameToNum(Query, String), g_GunNames[i][id], 99);
            }
			Load_Data(id, "stattrak", "QuerySelectStattrak");
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
            // new fegyver = sizeof(FegyverInfo)
            // for(new i = 159;i < fegyver; i++)
            // {
            //     new String[64];
            //     formatex(String, charsmax(String), "N%d", i);
            //     //SQL_ReadResult(Query, SQL_FieldNameToNum(Query, String), g_GunNames[i][id], 99);
            // }
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
	Len += formatex(Query[Len], charsmax(Query)-Len, "adminfizu = ^"%i^", ", adminfizu[id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "porgettimehw = ^"%i^", ", porgettimehw[id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "SkinBeKi = ^"%i^", ", g_SkinBeKi[id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "HudBeKi = ^"%i^", ", HudOff[id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "weaponhud = ^"%i^", ", Player[id][WeaponHud]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "killhang = ^"%i^", ", killhang[id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "nezlist = ^"%i^", ", nezlist[id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "hirduz = ^"%i^", ", hirduz[id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "korvegizene = ^"%i^", ", korvegizene[id]);	
	Len += formatex(Query[Len], charsmax(Query)-Len, "chathang = ^"%i^", ", chathang[id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "viptime = ^"%i^", ", g_VipTime[id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "Nevcedula = ^"%i^", ", g_Tools[1][id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "STTool = ^"%i^", ", g_Tools[0][id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "Admin_Szint = ^"%i^", ", get_user_adminlvl(id));
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
	
	SQL_ThreadQuery(m_get_sql(), "QuerySetData", Query);
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
	
	SQL_ThreadQuery(m_get_sql(), "QuerySetData", Query);
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
	
	SQL_ThreadQuery(m_get_sql(), "QuerySetData", Query);
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
	SQL_ThreadQuery(m_get_sql(), "QuerySetData", Query);
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
	SQL_ThreadQuery(m_get_sql(), "QuerySetData", Query);
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
	SQL_ThreadQuery(m_get_sql(), "QuerySetData", Query);
}
public Update_Nametag(id, load)
{
	static Query[10048];
	new Len;
	
	if(load == 1)
	{
		Len += formatex(Query[Len], charsmax(Query), "UPDATE `nevcedula` SET ");
		for(new i;i < sizeof(FegyverInfo); i++)
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
	SQL_ThreadQuery(m_get_sql(), "QuerySetData", Query);
}

public sql_create_rm_row(id){
	static Query[10048];
	formatex(Query, charsmax(Query), "INSERT INTO `erdemermek` (`User_Id`) VALUES (%d);", g_Id[id]);
	SQL_ThreadQuery(m_get_sql(), "QuerySetData", Query);
}
public sql_create_profiles_row(id){
	static Query[10048];
	formatex(Query, charsmax(Query), "INSERT INTO `profiles` (`User_Id`) VALUES (%d);", g_Id[id]);
	SQL_ThreadQuery(m_get_sql(), "QuerySetData", Query);
}	
public sql_create_skin_row(id){
	static Query[10048];
	formatex(Query, charsmax(Query), "INSERT INTO `skins` (`User_Id`) VALUES (%d);", g_Id[id]);
	SQL_ThreadQuery(m_get_sql(), "QuerySetData", Query);
}	
public sql_create_nametag_row(id){
	static Query[10048];
	formatex(Query, charsmax(Query), "INSERT INTO `nevcedula` (`User_Id`) VALUES (%d);", g_Id[id]);
	SQL_ThreadQuery(m_get_sql(), "QuerySetData", Query);
}
public sql_create_nametag2_row(id){
	static Query[10048];
	formatex(Query, charsmax(Query), "INSERT INTO `nevcedula2` (`User_Id`) VALUES (%d);", g_Id[id]);
	SQL_ThreadQuery(m_get_sql(), "QuerySetData", Query);
}		
public sql_create_weapon_row(id){
	static Query[10048];
	formatex(Query, charsmax(Query), "INSERT INTO `weapon` (`User_Id`, `F_0`, `F_1`, `F_2`, `F_3`, `F_4`) VALUES (%d, 1, 1, 1, 1, 1);", g_Id[id]);
	SQL_ThreadQuery(m_get_sql(), "QuerySetData", Query);
}	
public sql_create_testers_row(id){
	static Query[10048];
	formatex(Query, charsmax(Query), "INSERT INTO `shedi_testers` (`User_Id`,`Name`) VALUES (%d, ^"%s^");", g_Id[id], Player[id][f_PlayerNames]);
	SQL_ThreadQuery(m_get_sql(), "QuerySetData", Query);
}
public sql_create_st_row(id){
	static Query[10048];
	formatex(Query, charsmax(Query), "INSERT INTO `stattrak` (`User_Id`) VALUES (%d);", g_Id[id]);
	SQL_ThreadQuery(m_get_sql(), "QuerySetData", Query);
}	
public sql_create_stk_row(id){
	static Query[10048];
	formatex(Query, charsmax(Query), "INSERT INTO `stattrakkills` (`User_Id`) VALUES (%d);", g_Id[id]);
	SQL_ThreadQuery(m_get_sql(), "QuerySetData", Query);
}
public sql_create_music_row(id){
	static Query[10048];
	formatex(Query, charsmax(Query), "INSERT INTO `musickits` (`User_Id`) VALUES (%d);", g_Id[id]);
	SQL_ThreadQuery(m_get_sql(), "QuerySetData", Query);
}
public sql_create_kuldik_row(id){
	Load_User_Data(id);
	static Query[10048];
	formatex(Query, charsmax(Query), "INSERT INTO `kuldetes` (`User_Id`) VALUES (%d);", g_Id[id]);
	SQL_ThreadQuery(m_get_sql(), "QuerySetData", Query);

}

public RoundEnds()
{
	new players[32], num
	get_players(players, num, "c");
	SortCustom1D(players, num, "SortMVPToPlayer")
	TopMvp = players[0]
	new mvpName[32]
	get_user_name(TopMvp, mvpName, charsmax(mvpName))
	//sk_chat(0, "^1A legjobb játékos ebben a körben ^3%s^1 volt!", mvpName)
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
		if(FegyverInfo[i][PiacraHelyezheto] == -2  && g_Weapons[i][id] > 0)
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
public ak47killbolt(id)
{
	new iras[121]
	format(iras, charsmax(iras), "%s \r[ \wAk47 \rBolt]^n \wÖléseid: \r%i", menuprefix, oles[id]);
	new menu = menu_create(iras, "ak47killbolt_h");
	

	if(oles[id] > 2000 && Elhasznal[12][id] == 1) 
		format(String,charsmax(String),"Ak47 Frontside Misty Skin \r[\dElhasználva\r]");
	else if(oles[id] > 2000)
		format(String,charsmax(String),"Ak47 Frontside Misty Skin \r[\yElérhető\r]");
	else
		format(String,charsmax(String),"Ak47 Frontside Misty Skin\r[\y2000 ölés\r]");
	menu_additem(menu,String,"1");


	if(oles[id] > 2800 && Elhasznal[14][id] == 1) 
		format(String,charsmax(String),"Ak47 Vulcan Skin \r[\dElhasználva\r]");
	else if(oles[id] > 2800)
		format(String,charsmax(String),"Ak47 Vulcan Skin \r[\yElérhető\r]");
	else
		format(String,charsmax(String),"Ak47 Vulcan Skin \r[\y2800 ölés\r]");
	menu_additem(menu,String,"3");

	if(oles[id] > 3200 && Elhasznal[15][id] == 1) 
		format(String,charsmax(String),"Ak47 Red Dragon Skin \r[\dElhasználva\r]");
	else if(oles[id] > 3200)
		format(String,charsmax(String),"Ak47 Red Dragon Skin \r[\yElérhető\r]");
	else
		format(String,charsmax(String),"Ak47 Red Dragon Skin \r[\y3200 ölés\r]");
	menu_additem(menu,String,"4");

	if(oles[id] > 5000 && Elhasznal[16][id] == 1) 
		format(String,charsmax(String),"Ak47 Redline Skin \r[\dElhasználva\r]");
	else if(oles[id] > 5000)
		format(String,charsmax(String),"Ak47 Redline Skin \r[\yElérhető\r]");
	else
		format(String,charsmax(String),"Ak47 Redline Skin \r[\y5000 ölés\r]");
	menu_additem(menu,String,"5");

	if(oles[id] > 6600 && Elhasznal[28][id] == 1) 
		format(String,charsmax(String),"Ak47 Blueflame Skin \r[\dElhasználva\r]");
	else if(oles[id] > 6600)
		format(String,charsmax(String),"Ak47 Blueflame Skin \r[\yElérhető\r]");
	else
		format(String,charsmax(String),"Ak47 Blueflame Skin \r[\y6600 ölés\r]");
	menu_additem(menu,String,"6");


	if(oles[id] > 9800 && Elhasznal[30][id] == 1) 
		format(String,charsmax(String),"Ak47 Demolition Derby Skin \r[\dElhasználva\r]");
	else if(oles[id] > 9800)
		format(String,charsmax(String),"Ak47 Demolition Derby Skin \r[\yElérhető\r]");
	else
		format(String,charsmax(String),"Ak47 Demolition Derby Skin \r[\y9800 ölés\r]");
	menu_additem(menu,String,"8");

	if(oles[id] > 11300 && Elhasznal[31][id] == 1) 
		format(String,charsmax(String),"Ak47 Polcar Bear Skin \r[\dElhasználva\r]");
	else if(oles[id] > 11300)
		format(String,charsmax(String),"Ak47 Polcar Bear Skin \r[\yElérhető\r]");
	else
		format(String,charsmax(String),"Ak47 Polcar Bear Skin \r[\y11300 ölés\r]");
	menu_additem(menu,String,"9");

	if(oles[id] > 13400 && Elhasznal[32][id] == 1) 
		format(String,charsmax(String),"Ak47 Neon Revolution Skin \r[\dElhasználva\r]");
	else if(oles[id] > 13400)
		format(String,charsmax(String),"Ak47 Neon Revolution Skin \r[\yElérhető\r]");
	else
		format(String,charsmax(String),"Ak47 Neon Revolution Skin \r[\y13400 ölés\r]");
	menu_additem(menu,String,"10");

	if(oles[id] > 17000 && Elhasznal[33][id] == 1) 
		format(String,charsmax(String),"Ak47 The Empress Skin \r[\dElhasználva\r]");
	else if(oles[id] > 17000)
		format(String,charsmax(String),"Ak47 The Empress Skin \r[\yElérhető\r]");
	else
		format(String,charsmax(String),"Ak47 The Empress Skin \r[\y17000 ölés\r]");
	menu_additem(menu,String,"11");

	if(oles[id] > 22500 && Elhasznal[34][id] == 1) 
		format(String,charsmax(String),"Ak47 Loius Vuitton Skin \r[\dElhasználva\r]");
	else if(oles[id] > 22500)
		format(String,charsmax(String),"Ak47 Loius Vuitton Skin \r[\yElérhető\r]");
	else
		format(String,charsmax(String),"Ak47 Loius Vuitton Skin \r[\y22500 ölés\r]");
	menu_additem(menu,String,"12");

	menu_setprop(menu, MPROP_EXITNAME, "\rKilépés");
    menu_setprop(menu, MPROP_NEXTNAME, "\yKövetkező");
    menu_setprop(menu, MPROP_BACKNAME, "\yVissza");
	
    menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);	
	
	menu_display(id, menu, 0); 
}

public ak47killbolt_h(id, menu, item)
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
	case 1: killbolt1(id);
	case 3: killbolt3(id);
	case 4: killbolt4(id);
	case 5: killbolt5(id);
	case 6: killbolt17(id);
	case 8: killbolt19(id);
	case 9: killbolt20(id);
	case 10: killbolt21(id);
	case 11: killbolt22(id);
	case 12: killboltLV(id);
	}
}

public killbolt1(id)
{
if(Elhasznal[12][id] == 0 && oles[id] > 2000)
{
new Data[1];
static Query[10048];
Data[0] = id;
			
formatex(Query, charsmax(Query), "UPDATE `profiles` SET `Elhasznalva12` = 1 WHERE `User_Id` = %d;", g_Id[id]);
SQL_ThreadQuery(m_get_sql(), "QuerySetData", Query, Data, 1);
	Elhasznal[12][id] = 1;
	sk_chat(id,  "^3Sikeresen ^1feloldottad az adott Csomagot, az AK skint megkaptad^1!");
	sk_log("SENDTOEXILLE", fmt("[SENDTOEXILLE] (%s) %s killboltba 1. feloldva  (AccID: %i)", "asd", Player[id][f_PlayerNames], sk_get_accountid(id)))
	g_Weapons[175][id]++;
    }
	else if(oles[id] > 2000)
	{
	sk_chat(id,  "^3Sajnálom, ^1de te már elhasználtad ezt a ^3csomagot!");
	}
	else{
	sk_chat(id,  "^3Sajnálom, ^1de neked nincs^3 2000^1 Ölésed hogy elhasználhasd ezt a ^3csomagot!");
    }
	ak47killbolt(id);
}		
public killbolt3(id)
{
if(Elhasznal[14][id] == 0 && oles[id] > 2800)
{
new Data[1];
static Query[10048];
Data[0] = id;
			
formatex(Query, charsmax(Query), "UPDATE `profiles` SET `Elhasznalva14` = 1 WHERE `User_Id` = %d;", g_Id[id]);
SQL_ThreadQuery(m_get_sql(), "QuerySetData", Query, Data, 1);
    g_Weapons[179][id]++;
	Elhasznal[14][id] = 1;
	sk_chat(id,  "^3Sikeresen ^1feloldottad az adott Csomagot, skint megkaptad^1!");
	sk_log("SENDTOEXILLE", fmt("[SENDTOEXILLE] (%s) %s killboltba 2. feloldva  (AccID: %i)", "asd", Player[id][f_PlayerNames], sk_get_accountid(id)))
    }
	else if(oles[id] > 2800)
	{
	sk_chat(id,  "^3Sajnálom, ^1de te már elhasználtad ezt a ^3csomagot!");
	}
	else{
	sk_chat(id,  "^3Sajnálom, ^1de neked nincs^3 2800^1 Ölésed hogy elhasználhasd ezt a ^3csomagot!");
    }
	ak47killbolt(id);
}	
public killbolt4(id)
{
if(Elhasznal[15][id] == 0 && oles[id] > 3200)
{
new Data[1];
static Query[10048];
Data[0] = id;
			
formatex(Query, charsmax(Query), "UPDATE `profiles` SET `Elhasznalva15` = 1 WHERE `User_Id` = %d;", g_Id[id]);
SQL_ThreadQuery(m_get_sql(), "QuerySetData", Query, Data, 1);
    g_Weapons[176][id]++;
	Elhasznal[15][id] = 1;
	sk_chat(id,  "^3Sikeresen ^1feloldottad az adott Csomagot, skint megkaptad^1!");
	sk_log("SENDTOEXILLE", fmt("[SENDTOEXILLE] (%s) %s killboltba 3. feloldva  (AccID: %i)", "asd", Player[id][f_PlayerNames], sk_get_accountid(id)))
    }
	else if(oles[id] > 3200)
	{
	sk_chat(id,  "^3Sajnálom, ^1de te már elhasználtad ezt a ^3csomagot!");
	}
	else{
	sk_chat(id,  "^3Sajnálom, ^1de neked nincs^3 3200^1 Ölésed hogy elhasználhasd ezt a ^3csomagot!");
    }
	ak47killbolt(id);
}	
public killbolt5(id)
{
if(Elhasznal[16][id] == 0 && oles[id] > 5000)
{
new Data[1];
static Query[10048];
Data[0] = id;
			
formatex(Query, charsmax(Query), "UPDATE `profiles` SET `Elhasznalva16` = 1 WHERE `User_Id` = %d;", g_Id[id]);
SQL_ThreadQuery(m_get_sql(), "QuerySetData", Query, Data, 1);
    g_Weapons[177][id]++;
	Elhasznal[16][id] = 1;
	sk_chat(id,  "^3Sikeresen ^1feloldottad az adott Csomagot, skint megkaptad^1!");
	sk_log("SENDTOEXILLE", fmt("[SENDTOEXILLE] (%s) %s killboltba 4. feloldva  (AccID: %i)", "asd", Player[id][f_PlayerNames], sk_get_accountid(id)))
    }
	else if(oles[id] > 5000)
	{
	sk_chat(id,  "^3Sajnálom, ^1de te már elhasználtad ezt a ^3csomagot!");
	}
	else{
	sk_chat(id,  "^3Sajnálom, ^1de neked nincs^3 5000^1 Ölésed hogy elhasználhasd ezt a ^3csomagot!");
    }
	ak47killbolt(id);
}	
public killbolt17(id)
{
if(Elhasznal[28][id] == 0 && oles[id] > 6600)
{
new Data[1];
static Query[10048];
Data[0] = id;
			
formatex(Query, charsmax(Query), "UPDATE `profiles` SET `Elhasznalva28` = 1 WHERE `User_Id` = %d;", g_Id[id]);
SQL_ThreadQuery(m_get_sql(), "QuerySetData", Query, Data, 1);
    g_Weapons[180][id]++;
	Elhasznal[28][id] = 1;
	sk_chat(id,  "^3Sikeresen ^1feloldottad az adott Csomagot, skint megkaptad^1!");
	sk_log("SENDTOEXILLE", fmt("[SENDTOEXILLE] (%s) %s killboltba 5. feloldva  (AccID: %i)", "asd", Player[id][f_PlayerNames], sk_get_accountid(id)))
    }
	else if(oles[id] > 6600)
	{
	sk_chat(id,  "^3Sajnálom, ^1de te már elhasználtad ezt a ^3csomagot!");
	}
	else{
	sk_chat(id,  "^3Sajnálom, ^1de neked nincs^3 6600^1 Ölésed hogy elhasználhasd ezt a ^3csomagot!");
    }
	ak47killbolt(id);
}
public killbolt19(id)
{
if(Elhasznal[30][id] == 0 && oles[id] > 9800)
{
new Data[1];
static Query[10048];
Data[0] = id;
			
formatex(Query, charsmax(Query), "UPDATE `profiles` SET `Elhasznalva30` = 1 WHERE `User_Id` = %d;", g_Id[id]);
SQL_ThreadQuery(m_get_sql(), "QuerySetData", Query, Data, 1);
    g_Weapons[182][id]++;
	Elhasznal[30][id] = 1;
	sk_chat(id,  "^3Sikeresen ^1feloldottad az adott Csomagot, skint megkaptad^1!");
	sk_log("SENDTOEXILLE", fmt("[SENDTOEXILLE] (%s) %s killboltba 6. feloldva  (AccID: %i)", "asd", Player[id][f_PlayerNames], sk_get_accountid(id)))
    }
	else if(oles[id] > 9800)
	{
	sk_chat(id,  "^3Sajnálom, ^1de te már elhasználtad ezt a ^3csomagot!");
	}
	else{
	sk_chat(id,  "^3Sajnálom, ^1de neked nincs^3 9800^1 Ölésed hogy elhasználhasd ezt a ^3csomagot!");
    }
	ak47killbolt(id);
}
public killbolt20(id)
{
if(Elhasznal[31][id] == 0 && oles[id] > 11300)
{
new Data[1];
static Query[10048];
Data[0] = id;
			
formatex(Query, charsmax(Query), "UPDATE `profiles` SET `Elhasznalva31` = 1 WHERE `User_Id` = %d;", g_Id[id]);
SQL_ThreadQuery(m_get_sql(), "QuerySetData", Query, Data, 1);
    g_Weapons[183][id]++;
	Elhasznal[31][id] = 1;
	sk_chat(id,  "^3Sikeresen ^1feloldottad az adott Csomagot, skint megkaptad^1!");
	sk_log("SENDTOEXILLE", fmt("[SENDTOEXILLE] (%s) %s killboltba 7. feloldva  (AccID: %i)", "asd", Player[id][f_PlayerNames], sk_get_accountid(id)))
    }
	else if(oles[id] > 11300)
	{
	sk_chat(id,  "^3Sajnálom, ^1de te már elhasználtad ezt a ^3csomagot!");
	}
	else{
	sk_chat(id,  "^3Sajnálom, ^1de neked nincs^3 11300^1 Ölésed hogy elhasználhasd ezt a ^3csomagot!");
    }
	ak47killbolt(id);
}
public killbolt21(id)
{
if(Elhasznal[32][id] == 0 && oles[id] > 13400)
{
new Data[1];
static Query[10048];
Data[0] = id;
			
formatex(Query, charsmax(Query), "UPDATE `profiles` SET `Elhasznalva32` = 1 WHERE `User_Id` = %d;", g_Id[id]);
SQL_ThreadQuery(m_get_sql(), "QuerySetData", Query, Data, 1);
    g_Weapons[184][id]++;
	Elhasznal[32][id] = 1;
	sk_chat(id,  "^3Sikeresen ^1feloldottad az adott Csomagot, skint megkaptad^1!");
	sk_log("SENDTOEXILLE", fmt("[SENDTOEXILLE] (%s) %s killboltba 8. feloldva  (AccID: %i)", "asd", Player[id][f_PlayerNames], sk_get_accountid(id)))
    }
	else if(oles[id] > 13400)
	{
	sk_chat(id,  "^3Sajnálom, ^1de te már elhasználtad ezt a ^3csomagot!");
	}
	else{
	sk_chat(id,  "^3Sajnálom, ^1de neked nincs^3 13400^1 Ölésed hogy elhasználhasd ezt a ^3csomagot!");
    }
	ak47killbolt(id);
}
public killbolt22(id)
{
if(Elhasznal[33][id] == 0 && oles[id] > 17000)
{
new Data[1];
static Query[10048];
Data[0] = id;
			
formatex(Query, charsmax(Query), "UPDATE `profiles` SET `Elhasznalva33` = 1 WHERE `User_Id` = %d;", g_Id[id]);
SQL_ThreadQuery(m_get_sql(), "QuerySetData", Query, Data, 1);
    g_Weapons[185][id]++;
	Elhasznal[33][id] = 1;
	sk_chat(id,  "^3Sikeresen ^1feloldottad az adott Csomagot, skint megkaptad^1!");
	sk_log("SENDTOEXILLE", fmt("[SENDTOEXILLE] (%s) %s killboltba 8. feloldva  (AccID: %i)", "asd", Player[id][f_PlayerNames], sk_get_accountid(id)))
    }
	else if(oles[id] > 17000)
	{
	sk_chat(id,  "^3Sajnálom, ^1de te már elhasználtad ezt a ^3csomagot!");
	}
	else{
	sk_chat(id,  "^3Sajnálom, ^1de neked nincs^3 17000^1 Ölésed hogy elhasználhasd ezt a ^3csomagot!");
    }
	ak47killbolt(id);
}

public keskillbolt(id)
{
	new iras[121]
	format(iras, charsmax(iras), "%s \r[ \wKés \rBolt]^n \wÖléseid: \r%i", menuprefix, oles[id]);
	new menu = menu_create(iras, "keskillbolt_h");
	

	if(oles[id] > 4000 && Elhasznal[17][id] == 1) 
		format(String,charsmax(String),"KNIFE Neon assasin Skin \r[\dElhasználva\r]");
	else if(oles[id] > 4000)
		format(String,charsmax(String),"KNIFE Neon assasin Skin \r[\yElérhető\r]");
	else
		format(String,charsmax(String),"KNIFE Neon assasin Skin \r[\y4000 ölés\r]");
	menu_additem(menu,String,"1");

	if(oles[id] > 4900 && Elhasznal[18][id] == 1) 
		format(String,charsmax(String),"Ursus Ruby Skin \r[\dElhasználva\r]");
	else if(oles[id] > 4900)
		format(String,charsmax(String),"Ursus Ruby Skin \r[\yElérhető\r]");
	else
		format(String,charsmax(String),"Ursus Ruby Skin \r[\y4900 ölés\r]");
	menu_additem(menu,String,"2");

	if(oles[id] > 6040 && Elhasznal[19][id] == 1) 
		format(String,charsmax(String),"Flip Knife Doppler Sapphire Skin \r[\dElhasználva\r]");
	else if(oles[id] > 6040)
		format(String,charsmax(String),"Flip Knife Doppler Sapphire Skin \r[\yElérhető\r]");
	else
		format(String,charsmax(String),"Flip Knife Doppler Sapphire Skin \r[\y6040 ölés\r]");
	menu_additem(menu,String,"3");

	if(oles[id] > 7560 && Elhasznal[20][id] == 1) 
		format(String,charsmax(String),"M9 Bayonet Nitro Skin \r[\dElhasználva\r]");
	else if(oles[id] > 7560)
		format(String,charsmax(String),"M9 Bayonet Nitro Skin \r[\yElérhető\r]");
	else
		format(String,charsmax(String),"M9 Bayonet Nitro Skin \r[\y7560 ölés\r]");
	menu_additem(menu,String,"4");

	if(oles[id] > 8500 && Elhasznal[21][id] == 1) 
		format(String,charsmax(String),"M9 Bayonet Wasteland-Rebel Skin \r[\dElhasználva\r]");
	else if(oles[id] > 8500)
		format(String,charsmax(String),"M9 Bayonet Wasteland-Rebel Skin \r[\yElérhető\r]");
	else
		format(String,charsmax(String),"M9 Bayonet Wasteland-Rebel Skin \r[\y8500 ölés\r]");
	menu_additem(menu,String,"5");

	if(oles[id] > 11000 && Elhasznal[22][id] == 1) 
		format(String,charsmax(String),"KNIFE Meat Skin \r[\dElhasználva\r]");
	else if(oles[id] > 11000)
		format(String,charsmax(String),"KNIFE Meat Skin \r[\yElérhető\r]");
	else
		format(String,charsmax(String),"KNIFE Meat Skin \r[\y11000 ölés\r]");
	menu_additem(menu,String,"6");

	if(oles[id] > 13000 && Elhasznal[23][id] == 1) 
		format(String,charsmax(String),"KNIFE Ghost Skin \r[\dElhasználva\r]");
	else if(oles[id] > 13000)
		format(String,charsmax(String),"KNIFE Ghost Skin \r[\yElérhető\r]");
	else
		format(String,charsmax(String),"KNIFE Ghost Skin \r[\y13000 ölés\r]");
	menu_additem(menu,String,"7");

	if(oles[id] > 15000 && Elhasznal[24][id] == 1) 
		format(String,charsmax(String),"KNIFE Nautilus Skin \r[\dElhasználva\r]");
	else if(oles[id] > 15000)
		format(String,charsmax(String),"KNIFE Nautilus Skin \r[\yElérhető\r]");
	else
		format(String,charsmax(String),"KNIFE Nautilus Skin \r[\y15000 ölés\r]");
	menu_additem(menu,String,"8");

	if(oles[id] > 20300 && Elhasznal[25][id] == 1) 
		format(String,charsmax(String),"Baton Asiimov Skin \r[\dElhasználva\r]");
	else if(oles[id] > 20300)
		format(String,charsmax(String),"Baton Asiimov Skin \r[\yElérhető\r]");
	else
		format(String,charsmax(String),"Baton Asiimov Skin \r[\y20300 ölés\r]");
	menu_additem(menu,String,"9");

	if(oles[id] > 23500 && Elhasznal[26][id] == 1) 
		format(String,charsmax(String),"KNIFE Purple Error Skin \r[\dElhasználva\r]");
	else if(oles[id] > 23500)
		format(String,charsmax(String),"KNIFE Purple Error Skin \r[\yElérhető\r]");
	else
		format(String,charsmax(String),"KNIFE Purple Error Skin \r[\y23500 ölés\r]");
	menu_additem(menu,String,"10");

	if(oles[id] > 27000 && Elhasznal[27][id] == 1) 
		format(String,charsmax(String),"KNIFE Loius Vuitton Skin \r[\dElhasználva\r]");
	else if(oles[id] > 27000)
		format(String,charsmax(String),"KNIFE Loius Vuitton \r[\yElérhető\r]");
	else
		format(String,charsmax(String),"KNIFE Loius Vuitton \r[\y27000 ölés\r]");
	menu_additem(menu,String,"11");


	menu_setprop(menu, MPROP_EXITNAME, "\rKilépés");
    menu_setprop(menu, MPROP_NEXTNAME, "\yKövetkező");
    menu_setprop(menu, MPROP_BACKNAME, "\yVissza");
	
    menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);	
	
	menu_display(id, menu, 0); 
}
public keskillbolt_h(id, menu, item)
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
	case 1: killbolt6(id);
    case 2: killbolt7(id);
	case 3: killbolt8(id);
	case 4: killbolt9(id);
	case 5: killbolt10(id);
	case 6: killbolt11(id);
	case 7: killbolt12(id);
	case 8: killbolt13(id);
	case 9: killbolt14(id);
	case 10: killbolt15(id);
	case 11: killbolt16(id);
	}
}

public killbolt6(id)
{
if(Elhasznal[17][id] == 0 && oles[id] > 4000)
{
new Data[1];
static Query[10048];
Data[0] = id;
			
formatex(Query, charsmax(Query), "UPDATE `profiles` SET `Elhasznalva17` = 1 WHERE `User_Id` = %d;", g_Id[id]);
SQL_ThreadQuery(m_get_sql(), "QuerySetData", Query, Data, 1);
    g_Weapons[167][id]++;
	Elhasznal[17][id] = 1;
	sk_chat(id,  "^3Sikeresen ^1feloldottad az adott Csomagot, az Kés skint megkaptad^1!");
	sk_log("SENDTOEXILLE", fmt("[SENDTOEXILLE] (%s) %s killboltba 1. késekből feloldva  (AccID: %i)", "asd", Player[id][f_PlayerNames], sk_get_accountid(id)))
    }
	else if(oles[id] > 4000)
	{
	sk_chat(id,  "^3Sajnálom, ^1de te már elhasználtad ezt a ^3csomagot!");
	}
	else
	{
	sk_chat(id,  "^3Sajnálom, ^1de neked nincs^3 4000^1 Ölésed hogy elhasználhasd ezt a ^3csomagot!");
    }
    keskillbolt(id);
}	
public killbolt7(id)
{
if(Elhasznal[18][id] == 0 && oles[id] > 4900)
{
new Data[1];
static Query[10048];
Data[0] = id;
			
formatex(Query, charsmax(Query), "UPDATE `profiles` SET `Elhasznalva18` = 1 WHERE `User_Id` = %d;", g_Id[id]);
SQL_ThreadQuery(m_get_sql(), "QuerySetData", Query, Data, 1);
    g_Weapons[174][id]++;
	Elhasznal[18][id] = 1;
	sk_chat(id,  "^3Sikeresen ^1feloldottad az adott Csomagot, skint megkaptad^1!");
	sk_log("SENDTOEXILLE", fmt("[SENDTOEXILLE] (%s) %s killboltba 2. késekből feloldva  (AccID: %i)", "asd", Player[id][f_PlayerNames], sk_get_accountid(id)))
    }
	else if(oles[id] > 4900)
	{
	sk_chat(id,  "^3Sajnálom, ^1de te már elhasználtad ezt a ^3csomagot!");
	}
	else
	{
	sk_chat(id,  "^3Sajnálom, ^1de neked nincs^3 4900^1 Ölésed hogy elhasználhasd ezt a ^3csomagot!");
    }
	keskillbolt(id);
}	
public killbolt8(id)
{
if(Elhasznal[19][id] == 0 && oles[id] > 6040)
{
new Data[1];
static Query[10048];
Data[0] = id;
			
formatex(Query, charsmax(Query), "UPDATE `profiles` SET `Elhasznalva19` = 1 WHERE `User_Id` = %d;", g_Id[id]);
SQL_ThreadQuery(m_get_sql(), "QuerySetData", Query, Data, 1);
    g_Weapons[168][id]++;
	Elhasznal[19][id] = 1;
	sk_chat(id,  "^3Sikeresen ^1feloldottad az adott Csomagot, skint megkaptad^1!");
	sk_log("SENDTOEXILLE", fmt("[SENDTOEXILLE] (%s) %s killboltba 3. késekből feloldva  (AccID: %i)", "asd", Player[id][f_PlayerNames], sk_get_accountid(id)))
    }
	else if(oles[id] > 6040)
	{
	sk_chat(id,  "^3Sajnálom, ^1de te már elhasználtad ezt a ^3csomagot!");
	}
	else
	{
	sk_chat(id,  "^3Sajnálom, ^1de neked nincs^3 6040^1 Ölésed hogy elhasználhasd ezt a ^3csomagot!");
    }
	keskillbolt(id);
}	
public killbolt9(id)
{
if(Elhasznal[20][id] == 0 && oles[id] > 7560)
{
new Data[1];
static Query[10048];
Data[0] = id;
			
formatex(Query, charsmax(Query), "UPDATE `profiles` SET `Elhasznalva20` = 1 WHERE `User_Id` = %d;", g_Id[id]);
SQL_ThreadQuery(m_get_sql(), "QuerySetData", Query, Data, 1);
    g_Weapons[170][id]++;
	Elhasznal[20][id] = 1;
	sk_chat(id,  "^3Sikeresen ^1feloldottad az adott Csomagot, skint megkaptad^1!");
	sk_log("SENDTOEXILLE", fmt("[SENDTOEXILLE] (%s) %s killboltba 4. késekből feloldva  (AccID: %i)", "asd", Player[id][f_PlayerNames], sk_get_accountid(id)))
    }
	else if(oles[id] > 7560)
	{
	sk_chat(id,  "^3Sajnálom, ^1de te már elhasználtad ezt a ^3csomagot!");
	}
	else
	{
	sk_chat(id,  "^3Sajnálom, ^1de neked nincs^3 7560^1 Ölésed hogy elhasználhasd ezt a ^3csomagot!");
    }
	keskillbolt(id);
}	
public killbolt10(id)
{
if(Elhasznal[21][id] == 0 && oles[id] > 8500)
{
new Data[1];
static Query[10048];
Data[0] = id;
			
formatex(Query, charsmax(Query), "UPDATE `profiles` SET `Elhasznalva21` = 1 WHERE `User_Id` = %d;", g_Id[id]);
SQL_ThreadQuery(m_get_sql(), "QuerySetData", Query, Data, 1);
    g_Weapons[171][id]++;
	Elhasznal[21][id] = 1;
	sk_chat(id,  "^3Sikeresen ^1feloldottad az adott Csomagot, skint megkaptad^1!");
	sk_log("SENDTOEXILLE", fmt("[SENDTOEXILLE] (%s) %s killboltba 5. késekből feloldva  (AccID: %i)", "asd", Player[id][f_PlayerNames], sk_get_accountid(id)))
    }
	else if(oles[id] > 8500)
	{
	sk_chat(id,  "^3Sajnálom, ^1de te már elhasználtad ezt a ^3csomagot!");
	}
	else
	{
	sk_chat(id,  "^3Sajnálom, ^1de neked nincs^3 8500^1 Ölésed hogy elhasználhasd ezt a ^3csomagot!");
    }
	keskillbolt(id);
}
public killbolt11(id)
{
if(Elhasznal[22][id] == 0 && oles[id] > 11000)
{
new Data[1];
static Query[10048];
Data[0] = id;
			
formatex(Query, charsmax(Query), "UPDATE `profiles` SET `Elhasznalva22` = 1 WHERE `User_Id` = %d;", g_Id[id]);
SQL_ThreadQuery(m_get_sql(), "QuerySetData", Query, Data, 1);
    g_Weapons[172][id]++;
	Elhasznal[22][id] = 1;
	sk_chat(id,  "^3Sikeresen ^1feloldottad az adott Csomagot, skint megkaptad^1!");
	sk_log("SENDTOEXILLE", fmt("[SENDTOEXILLE] (%s) %s killboltba 6. késekből feloldva  (AccID: %i)", "asd", Player[id][f_PlayerNames], sk_get_accountid(id)))
    }
	else if(oles[id] > 11000)
	{
	sk_chat(id,  "^3Sajnálom, ^1de te már elhasználtad ezt a ^3csomagot!");
	}
	else
	{
	sk_chat(id,  "^3Sajnálom, ^1de neked nincs^3 11000^1 Ölésed hogy elhasználhasd ezt a ^3csomagot!");
    }
	keskillbolt(id);
}
public killbolt12(id)
{
if(Elhasznal[23][id] == 0 && oles[id] > 13000)
{
new Data[1];
static Query[10048];
Data[0] = id;
			
formatex(Query, charsmax(Query), "UPDATE `profiles` SET `Elhasznalva23` = 1 WHERE `User_Id` = %d;", g_Id[id]);
SQL_ThreadQuery(m_get_sql(), "QuerySetData", Query, Data, 1);
    g_Weapons[169][id]++;
	Elhasznal[23][id] = 1;
	sk_chat(id,  "^3Sikeresen ^1feloldottad az adott Csomagot, skint megkaptad^1!");
	sk_log("SENDTOEXILLE", fmt("[SENDTOEXILLE] (%s) %s killboltba 7. késekből feloldva  (AccID: %i)", "asd", Player[id][f_PlayerNames], sk_get_accountid(id)))
    }
	else if(oles[id] > 13000)
	{
	sk_chat(id,  "^3Sajnálom, ^1de te már elhasználtad ezt a ^3csomagot!");
	}
	else
	{
	sk_chat(id,  "^3Sajnálom, ^1de neked nincs^3 13000^1 Ölésed hogy elhasználhasd ezt a ^3csomagot!");
    }
	keskillbolt(id);
}	
public killbolt13(id)
{
if(Elhasznal[24][id] == 0 && oles[id] > 15000)
{
new Data[1];
static Query[10048];
Data[0] = id;
			
formatex(Query, charsmax(Query), "UPDATE `profiles` SET `Elhasznalva24` = 1 WHERE `User_Id` = %d;", g_Id[id]);
SQL_ThreadQuery(m_get_sql(), "QuerySetData", Query, Data, 1);
    g_Weapons[173][id]++;
	Elhasznal[24][id] = 1;
	sk_chat(id,  "^3Sikeresen ^1feloldottad az adott Csomagot, skint megkaptad^1!");
	sk_log("SENDTOEXILLE", fmt("[SENDTOEXILLE] (%s) %s killboltba 8. késekből feloldva  (AccID: %i)", "asd", Player[id][f_PlayerNames], sk_get_accountid(id)))
    }
	else if(oles[id] > 15000)
	{
	sk_chat(id,  "^3Sajnálom, ^1de te már elhasználtad ezt a ^3csomagot!");
	}
	else
	{
	sk_chat(id,  "^3Sajnálom, ^1de neked nincs^3 15000^1 Ölésed hogy elhasználhasd ezt a ^3csomagot!");
    }
	keskillbolt(id);
}	
public killbolt14(id)
{
if(Elhasznal[25][id] == 0 && oles[id] > 20300)
{
new Data[1];
static Query[10048];
Data[0] = id;
			
formatex(Query, charsmax(Query), "UPDATE `profiles` SET `Elhasznalva25` = 1 WHERE `User_Id` = %d;", g_Id[id]);
SQL_ThreadQuery(m_get_sql(), "QuerySetData", Query, Data, 1);
    g_Weapons[186][id]++;
	Elhasznal[25][id] = 1;
	sk_chat(id,  "^3Sikeresen ^1feloldottad az adott Csomagot, skint megkaptad^1!");
	sk_log("SENDTOEXILLE", fmt("[SENDTOEXILLE] (%s) %s killboltba 9. késekből feloldva  (AccID: %i)", "asd", Player[id][f_PlayerNames], sk_get_accountid(id)))
    }
	else if(oles[id] > 20300)
	{
	sk_chat(id,  "^3Sajnálom, ^1de te már elhasználtad ezt a ^3csomagot!");
	}
	else
	{
	sk_chat(id,  "^3Sajnálom, ^1de neked nincs^3 20300^1 Ölésed hogy elhasználhasd ezt a ^3csomagot!");
    }
	keskillbolt(id);
}	
public killbolt15(id)
{
if(Elhasznal[26][id] == 0 && oles[id] > 23500)
{
new Data[1];
static Query[10048];
Data[0] = id;
			
formatex(Query, charsmax(Query), "UPDATE `profiles` SET `Elhasznalva26` = 1 WHERE `User_Id` = %d;", g_Id[id]);
SQL_ThreadQuery(m_get_sql(), "QuerySetData", Query, Data, 1);
    g_Weapons[187][id]++;
	Elhasznal[26][id] = 1;
	sk_chat(id,  "^3Sikeresen ^1feloldottad az adott Csomagot, skint megkaptad^1!");
	sk_log("SENDTOEXILLE", fmt("[SENDTOEXILLE] (%s) %s killboltba 10. késekből feloldva  (AccID: %i)", "asd", Player[id][f_PlayerNames], sk_get_accountid(id)))
    }
	else if(oles[id] > 23500)
	{
	sk_chat(id,  "^3Sajnálom, ^1de te már elhasználtad ezt a ^3csomagot!");
	}
	else
	{
	sk_chat(id,  "^3Sajnálom, ^1de neked nincs^3 23500^1 Ölésed hogy elhasználhasd ezt a ^3csomagot!");
    }
	keskillbolt(id);
}	
public killbolt16(id)
{
if(Elhasznal[27][id] == 0 && oles[id] > 27000)
{
new Data[1];
static Query[10048];
Data[0] = id;
			
formatex(Query, charsmax(Query), "UPDATE `profiles` SET `Elhasznalva27` = 1 WHERE `User_Id` = %d;", g_Id[id]);
SQL_ThreadQuery(m_get_sql(), "QuerySetData", Query, Data, 1);
    g_Weapons[188][id]++;
	Elhasznal[27][id] = 1;
	sk_chat(id,  "^3Sikeresen ^1feloldottad az adott Csomagot, skint megkaptad^1!");
	sk_log("SENDTOEXILLE", fmt("[SENDTOEXILLE] (%s) %s killboltba 11. késekből feloldva  (AccID: %i)", "asd", Player[id][f_PlayerNames], sk_get_accountid(id)))
    }
	else if(oles[id] > 27000)
	{
	sk_chat(id,  "^3Sajnálom, ^1de te már elhasználtad ezt a ^3csomagot!");
	}
	else
	{
	sk_chat(id,  "^3Sajnálom, ^1de neked nincs^3 27000^1 Ölésed hogy elhasználhasd ezt a ^3csomagot!");
    }
	keskillbolt(id);
}	
public killboltLV(id)
{
if(Elhasznal[34][id] == 0 && oles[id] > 22500)
{
new Data[1];
static Query[10048];
Data[0] = id;
			
formatex(Query, charsmax(Query), "UPDATE `profiles` SET `Elhasznalva34` = 1 WHERE `User_Id` = %d;", g_Id[id]);
SQL_ThreadQuery(m_get_sql(), "QuerySetData", Query, Data, 1);
    g_Weapons[178][id]++;
	Elhasznal[34][id] = 1;
	sk_chat(id,  "^3Sikeresen ^1feloldottad az adott Csomagot, skint megkaptad^1!");
    }
	else if(oles[id] > 22500)
	{
	sk_chat(id,  "^3Sajnálom, ^1de te már elhasználtad ezt a ^3csomagot!");
	}
	else
	{
	sk_chat(id,  "^3Sajnálom, ^1de neked nincs^3 22500^1 Ölésed hogy elhasználhasd ezt a ^3csomagot!");
    }
	keskillbolt(id);
}	
public killbolt(id)
{
	new String[121];
	formatex(String, charsmax(String), "%s \r[ \wKill Bolt \r]^n", menuprefix);
	new menu = menu_create(String, "killbolt_h");

	menu_additem(menu, "Ak47 \y[\rÖlésből\y]", "1")
	menu_additem(menu, "Kés \y[\rÖlésből\y]", "2")

	menu_setprop(menu, MPROP_EXITNAME, "\rKilépés");
    menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);	
	menu_display(id, menu, 0);

	return PLUGIN_HANDLED;
}
public killbolt_h(id, menu, item)
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
	case 1: ak47killbolt(id);
    case 2: keskillbolt(id);
	}
}
public premiumpontmenu(id)
{
	new String[121];
	formatex(String, charsmax(String), "%s \r[ \wPrémiumPont Vásárlás \r]^n", menuprefix);
	new menu = menu_create(String, "premiumpontmenu_h");

	menu_addtext2(menu, "Mivel szeretnél \rfizetni?")

    menu_additem(menu, "Banki átutalás", "1")
	menu_additem(menu, "Revolut", "2")

	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	menu_setprop(menu, MPROP_EXITNAME, "\rKilépés");

	menu_display(id, menu, 0);	

}

public premiumpontmenu_h(id, menu, item)
{  
   if(item == MENU_EXIT)
   {
	menu_destroy(menu);
    return;
   }
   new data[9], szName[64]
   new access, callback;
   menu_item_getinfo(menu, item, access, data, charsmax(data), szName, charsmax(szName), callback);
   new key = str_to_num(data);

	switch(key)
	{
	case 1: utalas(id);
    case 2: revolut(id);
	}
}

public utalas(id)
{
	new String[121];
	formatex(String, charsmax(String), "%s \r[ \wPrémiumPont Vásárlás \r]^n", menuprefix);
	new menu = menu_create(String, "utalas_h");

    sk_chat(id, "Bankszámlaszám: 11773470-00904887")

	menu_additem(menu, "\w[\yPrémiumpont\w] csomagok", "1")
    menu_addtext2(menu, "Utaláshoz használt számlaszám: \y 11773470-00904887")
	menu_addtext2(menu, "\wKedvezményezett: \rHorváth Adrián")
	menu_addtext2(menu, "\rFigyelem! \wA folyamat manuális.")

	formatex(String, charsmax(String), "\wAzonosítód: \r(\w%i\r)", g_Id[id]);
	menu_addtext2(menu, String);
	menu_addtext2(menu, "\rKözleménybe az azonósitód szerepeljen!!!")
	menu_addtext2(menu, "\rKözleménybe az azonósitód szerepeljen!!!")

	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	menu_setprop(menu, MPROP_EXITNAME, "\rKilépés");

	menu_display(id, menu, 0);	

}

public utalas_h(id, menu, item)
{  
   if(item == MENU_EXIT)
   {
	menu_destroy(menu);
    return;
   }
   new data[9], szName[64]
   new access, callback;
   menu_item_getinfo(menu, item, access, data, charsmax(data), szName, charsmax(szName), callback);
   new key = str_to_num(data);
   
   switch(key)
   {
	case 1:
	{	
	show_motd(id, "addons/amxmodx/configs/hbpont.html", "PremiumPont csomagok");
    }
   }
}

public revolut(id)
{
	new String[121];
	formatex(String, charsmax(String), "%s \r[ \wPrémiumPont Vásárlás \r]^n", menuprefix);
	new menu = menu_create(String, "revolut_h");

	sk_chat(id, "https://revolut.me/exilleherboy")

	menu_additem(menu, "\w[\yPrémiumpont\w] csomagok", "1")
    menu_addtext2(menu, "Revolut utaláshoz használt számla: \y revolut.me/exilleherboy")
	menu_addtext2(menu, "\wKözleménybe az azonósitód \r szerepeljen!")
	menu_addtext2(menu, "\rFigyelem! \wA folyamat manuális.")

	formatex(String, charsmax(String), "\wAzonosítód: \r(\w%i\r)", g_Id[id]);
	menu_addtext2(menu, String);
	menu_addtext2(menu, "\rKözleménybe az azonósitód szerepeljen!!!")
	menu_addtext2(menu, "\rKözleménybe az azonósitód szerepeljen!!!")

	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	menu_setprop(menu, MPROP_EXITNAME, "\rKilépés");

	menu_display(id, menu, 0);	

}

public revolut_h(id, menu, item)
{  
   if(item == MENU_EXIT)
   {
	menu_destroy(menu);
    return;
   }

   new data[9], szName[64]
   new access, callback;
   menu_item_getinfo(menu, item, access, data, charsmax(data), szName, charsmax(szName), callback);
   new key = str_to_num(data);

   switch(key)
   {
	case 1:
	{	
	show_motd(id, "addons/amxmodx/configs/hbpont.html", "PremiumPont csomagok");
    }
   }
}

public awpset(id)
{
	new String[121];
	formatex(String, charsmax(String), "%s \r[ \wAWP set \r]^n", menuprefix);
	new menu = menu_create(String, "awpset_h");

	menu_additem(menu, "\yCT\w 0 awp", "1")
	menu_additem(menu, "\yCT\w 1 awp", "2")
	menu_additem(menu, "\yCT\w 2 awp", "3")

	menu_additem(menu, "\yT\w 0 awp", "4")
	menu_additem(menu, "\yT\w 1 awp", "5")
	menu_additem(menu, "\yT\w 2 awp", "6")

	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	menu_setprop(menu, MPROP_EXITNAME, "\rKilépés");

	menu_display(id, menu, 0);	

}

public awpset_h(id, menu, item)
{  
   if(item == MENU_EXIT)
   {
	menu_destroy(menu);
    return;
   }

	if(get_user_adminlvl(id) == 0)
	{
	sk_chat(id, "Ez a command csak ^3adminoknak^1 érhető el!")
	return;
	}

   new data[9], szName[64]
   new access, callback;
   menu_item_getinfo(menu, item, access, data, charsmax(data), szName, charsmax(szName), callback);
   new key = str_to_num(data);

   switch(key)
   {
	case 1:	client_cmd(id, "amx_cvar awm_max_ct_awp 0")
	case 2: client_cmd(id, "amx_cvar awm_max_ct_awp 1")
	case 3:	client_cmd(id, "amx_cvar awm_max_ct_awp 2")
	case 4:	client_cmd(id, "amx_cvar awm_max_te_awp 0")
	case 5:	client_cmd(id, "amx_cvar awm_max_te_awp 1")
	case 6:	client_cmd(id, "amx_cvar awm_max_te_awp 2")
   }
}
