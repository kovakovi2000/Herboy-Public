#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <engine>
#include <fun>
#include <hamsandwich>
#include <fakemeta>
#include <xs>
#include <fakemeta_stocks>
#include <fakemeta_util>
#include <sqlx>
#include <regex>
#include <ServerPrefix>
#include <sorsjegy>
#include <regsystem>

new const PLUGIN[] = "Dark*.*Angel'S MultiMod";
new CHATPREFIX[64];
new MENUPREFIX[64];
new const VERSION[] = "v5.0 EarlyBeta";
new const AUTHOR[] = "Shedi @ DarkSystem's";
new const SHEDIIRAS[] = "Shedi"
new const sql_csatlakozas[][] = { "127.0.0.1", "herboy", "caTG8zwJzB2uGdDC", "herboybans" };

#define CLEAR ""
#define MAX_RANKS 18

new Trie:sanklist, g_iTime, RankSetted = 0, VoltMarVote = 0, fwd_logined;
new g_Maxplayers, blockall = 0, ServerName[128], karbantartas = 0;
new gWPCT, gWPTE, nyolesNev[33][32], nyid[33], nyolesl[33]
new AdminChangedMap = 0, SMapName[32]
new FegyoMapName[32];
enum _:PlayerSys
{
	Name[33],
	steamid[33],
	Float:Dollar,
	PremiumPont,
	PlayTime,
	UserId,
	Kills,
	HS,
	Deaths,
	SkinOnOff,
	RoundEndSound,
	UltimateSound,
	HudType,
	HudOff,
	WeaponHud,
	LastConnectTime[33],
	MarketSelected,
	EquipmentedSkin,
	EquipmentedSkinArray,
	vipTime,
	is_Vip,
	pvipTime,
	is_pVip,
	PressedVIPMenu,
	BuyVIPDay,
	NametagTool,
	StatTrakTool,
	ChatPrefix[16],
	isPrefixed,
	SelectedToTools,
	openSelectItemRow,
	AdminLvL,
	is_Inkodnitoed,
	Rang,
	BuyedWeap,
	UsedAWP,
	eloPoints,
	eloElo,
	Float:eloXP,
	Float:rXP,
	BattlePass_Level,
	AdminTime,
	BattlePass_Purchased,
	ProfilRank,
	Wins,
	FragKills,
	SendTemp,
	SendType,
	NyeremenyKills,
	DeletType,
	SelectedForDelete,
	CaseOrKeySelected,
	SelectedTSkin,
	SelectedCTSkin,
	NowRank,
	PlayedCount,
	SelectedMusicKit,
	MVPPoints,
	ConnectedBefore,
	PorgetTime,
	VipPorgetes,
	SanksOff
}
enum _:MarketSys
{
	MarketProductTime[32],
	m_SellerName[33],
	m_SellerId,
	m_sqlid,
	m_WeaponId,
	Float:m_Cost,
	m_SelectedToPlace,
	m_Nametag[100],
	m_STKills,
	m_Is_Nametaged,
	m_Is_StatTraked
}
enum _:InventorySystem
{
	sqlid,
	w_id,
	w_userid,
	is_StatTraked,
	StatTrakKills,
	is_Nametaged,
	Nametag[100],
	w_tradable,
	w_equipped,
	w_deleted,
	w_systime,
	Changed
}
enum _:JoinedUserIds
{
	JoinedUserId
}
enum _:stats_Properties
{
	wName[32],
	wKills, //deathM
	wHSs, //deathM
	wDeaths, //deathM
	wAllHitCount,
	wAllShotCount
}
enum _:MusicDatas
{
	MusicKitName[64],
	MusicLocation[64],
	Float:MusicKitPound_D,
	MusicKitPound_P
}
enum _:SanksInfo
{
	SankName[64],
	SankLocation[64]
}
enum _:TippKeyDatas
{
	Float:NyeremenyDollar,
	MinKey,
	MaxKey,
	AllowedTippKey,
	HaveKey,
	NyertesKulcs
}
new Top15_list[15][stats_Properties];
new Player_Stats[33][stats_Properties];
new Array:g_Inventory;
new Array:g_Products;	
new Array:g_UserId;
new Handle:g_SqlTupleMOD
enum _:LoadDatass {
	w_id,
	GunName[64],
	ModelName[128],
	Rarity[8],
	Color1,
	Color2,
	Color3,
	EntName[8]
} 
enum _:LoadSkin {
	ch_id,
	pSkinName[10],
	PName[64],
	ModelLoc[128],
	EntityName[8]
} 
enum _:SelectedGun
{
	AK47,
	M4A1,
	AWP,
	DG,
	KNIFE
}
static const EquipmentedDef[SelectedGun] = 
{
	{0},
	{1},
	{2},
	{3},
	{4},
}
enum _:ServerCvars
{
	Float:vipCost,
	pvipCost,
	Float:StatTrakCost,
	Float:NametagCost,
	Float:ChatPrefixCost,
	Float:SorsjegyCost,
	Float:XPBoosterCost,
	maxkor,
	ppevent,
	Float:ppszorzaspaypal,
	Float:ppszorzassms
}
enum _:DropSystem_Prop
{
	d_Name[32],
	Float:d_rarity,
	Float:k_rarity,
	Float:VipDropchance,
	Float:CaseCost,
	Float:KeyCost,
	Float:EventDropchance,
	Float:pVipDropChance,
}
new const JutalmakFrag1[][] =
{
	{"10 Színözön Láda + 10 Kulcs"},
	{"10 Platinum Láda + 10 Kulcs"},
	{"1 Hét VIP"},
	{"20.00$"},
	{"21.00$"},
	{"1 Hét VIP"},
	{"7 Színözön Láda + 7 Kulcs"},
	{"7 Platinum Láda + 7 Kulcs"},
	{"1 Hét VIP"},
	{"30.00$"},
	{"20.00$"},
	{"1 Hét VIP"}
}
new const JutalmakFrag2[][] =
{
	{"10 Arany Láda + 10 Kulcs"},
	{"10 Belépő Láda + 10 Kulcs"},
	{"3 Nap VIP"},
	{"20.00$"},
	{"15.00$"},
	{"5 Nap VIP"},
	{"7 Belépő Láda + 7 Kulcs"},
	{"3 Nap VIP"},
	{"20.00$"},
	{"15.00$"}
}
new const JutalmakFrag3[][] =
{
	{"7 Kezdő Láda + 7 Kulcs"},
	{"1 Nap VIP"},
	{"10.00$"},
	{"7.00$"},
	{"3 Nap VIP"},
	{"1 Nap VIP"},
	{"15.00$"},
	{"10.00$"},
	{"10 Alap Láda + 10 Kulcs"},
}
new const Cases[][DropSystem_Prop] =
{
	{"Alap láda", 7.3, 0.0, 2.00, 0.00, 0.00, 20.8, 0.00},
	{"Kezdő Láda", 6.9, 0.0, 3.00, 0.00, 0.00, 17.2, 0.00},
	{"Belépő Láda", 5.2, 0.0, 8.00, 0.00, 0.00, 6.11, 0.00},
	{"Arany Láda", 4.4, 0.0, 13.00, 0.00, 0.00, 5.17, 0.00},
	{"Platinum Láda", 3.1, 0.0, 14.00, 0.00, 0.00, 3.55, 0.00},
	{"Színözön Láda", 2.7, 0.0, 20.00, 0.00, 0.00, 2.02, 0.00},
	{"Prémium Láda", 0.001, 0.0, 0.00, 0.00, 0.00, 0.00, 5.50}
	//NEW CASES AND KEYS HERE!
}
new const Keys[][DropSystem_Prop] =
{
	{"Alap ládakulcs", 0.0, 7.1, 2.00, 0.00, 0.00, 20.8},
	{"Kezdő ládakulcs", 0.0, 6.9, 3.00, 0.00, 0.00, 17.2},
	{"Belépő ládakulcs", 0.0, 5.7, 8.00, 0.00, 0.00, 6.11},
	{"Arany ládakulcs", 0.0, 4.2, 13.00, 0.00, 0.00, 5.17},
	{"Platinum ládakulcs", 0.0, 3.2, 14.00, 0.00, 0.00, 3.55},
	{"Színözön ládakulcs", 0.0, 2.1, 20.00, 0.00,	0.00,2.02},
	{"Prémium Láda", 0.0, 0.001, 0.00, 0.00, 0.00, 0.00, 5.50}
	//NEW CASES AND KEYS HERE!
}
new const MusicKitInfos[][MusicDatas] = {
	{"Zene 1", "darksounds/new1.mp3", 0.00, 0}, 

}
new mvpr_kit[33][sizeof(MusicKitInfos)]
new const SankSoundsList[][SanksInfo] = {
	{"szopd", "darksounds/szopd.wav"}
}
new const Float:AlapDrops[][] =
{
	{5.0,	31.11},
	{5.0,	31.11},
	{8.0,	28.31},
	{11.0,	11.22},
	{13.0,	25.00},
	{17.0,	19.32},
	{18.0,	8.11},
	{20.0,	17.6},
	{21.0,	18.00},
	{25.0,	9.00},
	{29.0,	44.11},
	{47.0,	13.00},
	{50.0,	35.00},
	{51.0,	40.00},
	{53.0,	36.00},
	{57.0,	41.33},
	{58.0,	12.26},
	{63.0,	13.52},
	{65.0,	31.675},
	{59.0,	43.24},
	{72.0,	12.37},
	{74.0,	23.00},
	{75.0,	6.29},
	{88.0,	15.21},
	{93.0,	17.28},
	{100.0,	21.21},
	{103.0,	37.10},
	{106.0,	14.00},
	{112.0,	18.11},
	{121.0,	9.11},
	{123.0,	40.27},
	{126.0,	42.225},
	{128.0,	9.22},
	{131.0,	22.11},
	{135.0,	44.33},
	{136.0,	37.22},
			{139.0, 9.02 },
	{141.0, 9.03 },
	{142.0, 9.02 },
	{146.0, 9.03 },
	{147.0, 9.03 },
	{150.0, 9.03 },
	{153.0, 9.02 },
	{154.0, 9.02 },
	{156.0, 9.02 },
	{157.0, 9.03 },
	{159.0, 9.02 },
	{160.0, 9.03 },
	{152.0, 9.04 },
	{155.0, 9.05 },
	{165.0, 9.02 },
	{166.0, 9.03 },
	{170.0, 9.05 },
	{158.0, 9.06 },
	{163.0, 9.04 },
	{164.0, 9.04 },
	{140.0, 7.04 },
	{143.0, 8.02 },
	{144.0, 7.03 },
	{145.0, 6.05 },
	{149.0, 8.04 },
	{151.0, 9.03 },
	{171.0, 4.04 },
	{175.0, 8.03 },
	{178.0, 9.04 },
	{179.0, 3.05 },
	{181.0, 10.06 }
};
new const Float:KezdoDrops[][] =
{
	{5.0,	31.11},
	{10.0,	2.22},
	{15.0,	3.31},
	{22.0,	7.31},
	{27.0,	8.00},
	{34.0,	2.32},
	{35.0,	3.11},
	{6.0,	12.22},
	{7.0,	13.31},
	{9.0,	25.31},
	{12.0,	31.00},
	{14.0,	9.32},
	{16.0,	8.11},
	{19.0,	8.6},
	{23.0,	11.00},
	{28.0,	5.11},
	{30.0,	6.50},
	{32.0,	8.56},
	{37.0,	2.88},
	{11.0,	11.22},
	{18.0,	8.11},
	{25.0,	9.00},
	{42.0,	21.22},
	{44.0,	23.31},
	{54.0,	35.31},
	{56.0,	55.00},
	{60.0,	35.55},
	{67.0,	12.11},
	{73.0,	8.6},
	{47.0,	13.00},
	{50.0,	35.00},
	{51.0,	40.00},
	{53.0,	36.00},
	{57.0,	41.33},
	{58.0,	12.26},
	{63.0,	13.52},
	{65.0,	31.65},
	{59.0,	43.24},
	{72.0,	12.37},
	{74.0,	23.00},
	{47.0,	13.00},
	{58.0,	12.26},
	{63.0,	13.52},
	{72.0,	12.37},
	{78.0,	23.29},
	{79.0,	15.21},
	{82.0,	13.28},
	{85.0,	19.29},
	{87.0,	51.21},
	{89.0,	21.28},
	{91.0,	22.29},
	{95.0,	10.21},
	{97.0,	6.28},
	{99.0,	13.29},
	{75.0,	6.29},
	{88.0,	15.21},
	{93.0,	17.28},
	{109.0,	25.11},
	{110.0,	15.22},
	{114.0,	8.00},
	{118.0,	5.11},
	{124.0,	12.22},
	{127.0,	30.00},
	{130.0,	22.11},
	{132.0,	30.22},
	{134.0,	18.00},
	{137.0,	6.00},
	{121.0,	9.11},
	{128.0,	9.22},
			{139.0, 9.02 },
	{141.0, 9.03 },
	{142.0, 9.02 },
	{146.0, 9.03 },
	{147.0, 9.03 },
	{150.0, 9.03 },
	{153.0, 9.02 },
	{154.0, 9.02 },
	{156.0, 9.02 },
	{157.0, 9.03 },
	{159.0, 9.02 },
	{160.0, 9.03 },
	{152.0, 9.04 },
	{155.0, 9.05 },
	{165.0, 9.02 },
	{166.0, 9.03 },
	{170.0, 9.05 },
	{158.0, 9.06 },
	{163.0, 9.04 },
	{164.0, 9.04 },
	{140.0, 7.04 },
	{143.0, 8.02 },
	{144.0, 7.03 },
	{145.0, 6.05 },
	{149.0, 8.04 },
	{151.0, 9.03 },
	{171.0, 4.04 },
	{175.0, 8.03 },
	{178.0, 9.04 },
	{179.0, 3.05 },
	{181.0, 10.06 }
};
new const Float:BelepoDrops[][] =
{
	{5.0,	31.11},
	{6.0,	12.22},
	{7.0,	13.31},
	{9.0,	25.31},
	{12.0,	31.00},
	{14.0,	9.32},
	{16.0,	8.11},
	{19.0,	8.6},
	{23.0,	11.00},
	{26.0,	44.00},
	{28.0,	5.11},
	{30.0,	6.50},
	{31.0,	55.11},
	{32.0,	8.56},
	{37.0,	2.88},
	{38.0,	45.00},
	{39.0,	33.11},
	{11.0,	11.22},
	{18.0,	8.11},
	{25.0,	9.00},
	{43.0,	21.22},
	{46.0,	5.31},
	{49.0,	6.31},
	{55.0,	10.00},
	{64.0,	8.555},
	{66.0,	8.11},
	{68.0,	4.6},
	{70.0,	9.11},
	{47.0,	13.00},
	{50.0,	35.00},
	{53.0,	36.00},
	{58.0,	12.26},
	{63.0,	13.52},
	{65.0,	31.675},
	{72.0,	12.37},
	{74.0,	23.00},
	{47.0,	13.00},
	{58.0,	12.26},
	{77.0,	2.29},
	{81.0,	9.21},
	{84.0,	10.28},
	{92.0,	12.29},
	{94.0,	2.5},
	{96.0,	15.28},
	{102.0,	4.29},
	{78.0,	23.29},
	{79.0,	15.21},
	{82.0,	13.28},
	{85.0,	19.29},
	{89.0,	21.28},
	{91.0,	22.29},
	{95.0,	10.21},
	{97.0,	6.28},
	{99.0,	13.29},
	{75.0,	6.29},
	{88.0,	15.21},
	{93.0,	17.28},
	{105.0,	3.11},
	{107.0,	8.22},
	{111.0,	8.00},
	{117.0,	8.99},
	{119.0,	15.22},
	{120.0,	5.00},
	{125.0,	6.51},
	{129.0,	3.11},
	{109.0,	25.11},
	{110.0,	15.22},
	{114.0,	8.00},
	{118.0,	5.11},
	{124.0,	12.22},
	{127.0,	30.00},
	{130.0,	22.11},
	{132.0,	30.22},
	{134.0,	18.00},
	{137.0,	6.00},
	{121.0,	9.11},
	{128.0,	9.22},
	//{138.0,	8.00},
		{139.0, 9.02 },
	{141.0, 9.03 },
	{142.0, 9.02 },
	{146.0, 9.03 },
	{147.0, 9.03 },
	{150.0, 9.03 },
	{153.0, 9.02 },
	{154.0, 9.02 },
	{156.0, 9.02 },
	{157.0, 9.03 },
	{159.0, 9.02 },
	{160.0, 9.03 },
	{152.0, 9.04 },
	{155.0, 9.05 },
	{165.0, 9.02 },
	{166.0, 9.03 },
	{170.0, 9.05 },
	{158.0, 9.06 },
	{163.0, 9.04 },
	{164.0, 9.04 },
	{140.0, 7.04 },
	{143.0, 8.02 },
	{144.0, 7.03 },
	{145.0, 6.05 },
	{149.0, 8.04 },
	{151.0, 9.03 },
	{171.0, 4.04 },
	{175.0, 8.03 },
	{178.0, 9.04 },
	{179.0, 3.05 },
	{181.0, 10.06 }
};
new const Float:AranyDrops[][] =
{
	{5.0,	31.11},
	{33.0,	5.22},
	{36.0,	2.31},
	{40.0,	5.31},
	{41.0,	6.00},
	{16.0,	8.11},
	{6.0,	12.22},
	{7.0,	13.31},
	{9.0,	25.31},
	{12.0,	31.00},
	{14.0,	9.32},
	{16.0,	8.11},
	{19.0,	8.6},
	{23.0,	11.00},
	{26.0,	44.00},
	{10.0,	2.22},
	{15.0,	3.31},
	{22.0,	7.31},
	{27.0,	8.00},
	{34.0,	2.32},
	{35.0,	3.11},
	{6.0,	12.22},
	{7.0,	13.31},
	{45.0,	5.31},
	{52.0,	2.00},
	{61.0,	4.555},
	{62.0,	2.11},
	{69.0,	7.6},
	{71.0,	3.6},
	{49.0,	6.31},
	{55.0,	10.00},
	{64.0,	8.555},
	{66.0,	8.11},
	{68.0,	4.6},
	{70.0,	9.11},
	{47.0,	13.00},
	{50.0,	35.00},
	{53.0,	36.00},
	{58.0,	12.26},
	{53.0,	36.00},
	{57.0,	41.33},
	{58.0,	12.26},
	{63.0,	13.52},
	{65.0,	31.675},
	{76.0,	3.29},
	{86.0,	7.21},
	{90.0,	3.28},
	{98.0,	4.29},
	{101.0,	8.5},
	{104.0,	1.0},
	{77.0,	2.29},
	{81.0,	9.21},
	{84.0,	10.28},
	{92.0,	12.29},
	{94.0,	2.5},
	{96.0,	15.28},
	{102.0,	4.29},
	{75.0,	6.29},
	{88.0,	15.21},
	{93.0,	17.28},
	{100.0,	21.21},
	{103.0,	37.10},
	{78.0,	23.29},
	{79.0,	15.21},
	{82.0,	13.28},
	{85.0,	19.29},
	{211.0,	0.000001},
	{212.0,	0.000001},
	{108.0,	6.11},
	{113.0,	4.22},
	{116.0,	6.00},
	{122.0,	2.99},
	{133.0,	3.22},
	{105.0,	3.11},
	{107.0,	8.22},
	{111.0,	8.00},
	{117.0,	8.99},
	{119.0,	15.22},
	{120.0,	5.00},
	{125.0,	6.51},
	{129.0,	3.11},
	{121.0,	9.11},
	{123.0,	40.27},
	{126.0,	42.225},
	{128.0,	9.22},
	{131.0,	22.11},
	{109.0,	25.11},
	{110.0,	15.22},
	{114.0,	8.00},
	{139.0, 9.02 },
	{141.0, 9.03 },
	{142.0, 9.02 },
	{146.0, 9.03 },
	{147.0, 9.03 },
	{150.0, 9.03 },
	{153.0, 9.02 },
	{154.0, 9.02 },
	{156.0, 9.02 },
	{157.0, 9.03 },
	{159.0, 9.02 },
	{160.0, 9.03 },
	{152.0, 9.04 },
	{155.0, 9.05 },
	{165.0, 9.02 },
	{166.0, 9.03 },
	{170.0, 9.05 },
	{158.0, 9.06 },
	{163.0, 9.04 },
	{164.0, 9.04 }
};
new const Float:PlatinumDrops[][] =
{
	{5.0,	31.11},
	{33.0,	5.22},
	{36.0,	2.31},
	{40.0,	5.31},
	{41.0,	6.00},
	{16.0,	8.11},
	{6.0,	12.22},
	{7.0,	13.31},
	{14.0,	9.32},
	{16.0,	8.11},
	{19.0,	8.6},
	{23.0,	11.00},
	{10.0,	2.22},
	{15.0,	3.31},
	{22.0,	7.31},
	{27.0,	8.00},
	{34.0,	2.32},
	{35.0,	3.11},
	{6.0,	12.22},
	{211.0,	0.000001},
	{212.0,	0.000001},
	{7.0,	13.31},
	{45.0,	5.31},
	{52.0,	2.00},
	{61.0,	4.555},
	{62.0,	2.11},
	{69.0,	7.6},
	{71.0,	3.6},
	{49.0,	6.31},
	{55.0,	10.00},
	{64.0,	8.555},
	{66.0,	8.11},
	{68.0,	4.6},
	{70.0,	9.11},
	{47.0,	13.00},
	{58.0,	12.26},
	{58.0,	12.26},
	{63.0,	13.52},
	{76.0,	3.29},
	{86.0,	7.21},
	{90.0,	3.28},
	{98.0,	4.29},
	{101.0,	8.5},
	{104.0,	1.0},
	{77.0,	2.29},
	{81.0,	9.21},
	{84.0,	10.28},
	{92.0,	12.29},
	{94.0,	2.5},
	{96.0,	15.28},
	{102.0,	4.29},
	{75.0,	6.29},
	{88.0,	15.21},
	{93.0,	17.28},
	{100.0,	21.21},
	{79.0,	15.21},
	{82.0,	13.28},
	{85.0,	19.29},
	{108.0,	6.11},
	{113.0,	4.22},
	{116.0,	6.00},
	{122.0,	2.99},
	{133.0,	3.22},
	{105.0,	3.11},
	{107.0,	8.22},
	{111.0,	8.00},
	{117.0,	8.99},
	{119.0,	15.22},
	{120.0,	5.00},
	{125.0,	6.51},
	{129.0,	3.11},
	{121.0,	9.11},
	{128.0,	9.22},
	{110.0,	15.22},
	{114.0,	8.00},
	//{161.0, 0.03 },
	{167.0, 0.03 },
	{168.0, 0.02 },
	{169.0, 0.02 },
	{172.0, 0.02 },
	{173.0, 0.03 },
	{174.0, 0.02 },
	{176.0, 0.03 },
	{177.0, 0.03 },
	{180.0, 0.03 },
	{182.0, 0.02 },
	{183.0, 0.02 },
	{184.0, 0.02 },
	{152.0, 0.04 },
	{155.0, 0.05 },
	{165.0, 0.02 },
	{158.0, 0.06 },
	{163.0, 0.04 },
	{164.0, 0.04 },
};
new const Float:SzinozonDrops[][] =
{
	{5.0,	31.11},
	{33.0,	5.22},
	{36.0,	2.31},
	{40.0,	5.31},
	{41.0,	6.00},

	{16.0,	8.11},
	{6.0,	12.22},
	{14.0,	9.32},
	{16.0,	8.11},
	{19.0,	8.6},
	{23.0,	11.00},
	{10.0,	2.22},
	{15.0,	3.31},
	{22.0,	7.31},
	{27.0,	8.00},
	{34.0,	2.32},
	{35.0,	3.11},

	{6.0,	12.22},
	{7.0,	13.31},
	//M4A1
	{45.0,	5.31},
	{52.0,	2.00},
	{61.0,	4.555},
	{62.0,	2.11},
	{69.0,	7.6},
	{71.0,	3.6},

	{49.0,	6.31},
	{55.0,	10.00},
	{64.0,	8.555},
	{66.0,	8.11},
	{68.0,	4.6},
	{70.0,	9.11},
	{58.0,	12.26},
	{58.0,	12.26},

	//AWP
	{76.0,	3.29},
	{86.0,	7.21},
	{90.0,	3.28},
	{98.0,	4.29},
	{101.0,	8.5},
	{104.0,	1.0},

	{77.0,	2.29},
	{81.0,	9.21},
	{84.0,	10.28},
	{92.0,	12.29},
	{94.0,	2.5},
	{96.0,	15.28},
	{102.0,	4.29},
	{211.0,	0.000001},
	{212.0, 0.000001},
	{75.0,	6.29},
	{88.0,	15.21},
	{79.0,	15.21},
	{82.0,	13.28},

	//
	{108.0,	6.11},
	{113.0,	4.22},
	{116.0,	6.00},
	{122.0,	2.99},
	{133.0,	3.22},

	{105.0,	3.11},
	{107.0,	8.22},
	{120.0,	5.00},
	{125.0,	6.51},
	{129.0,	3.11},
	{114.0,	8.00},
	//KÉS
	{138.0, 0.32 },
	{161.0, 0.03 },
	{167.0, 0.03 },
	{168.0, 0.02 },
	{169.0, 0.02 },
	{172.0, 0.02 },
	{173.0, 0.03 },
	{174.0, 0.02 },
	{176.0, 0.03 },
	{177.0, 0.03 },
	{180.0, 0.03 },
	{182.0, 0.02 },
	{183.0, 0.02 },
	{184.0, 0.02 },
	{152.0, 0.04 },
	{155.0, 0.05 },
	{165.0, 0.02 },
	{158.0, 0.06 },
	{163.0, 0.04 },
	{164.0, 0.04 },
	{139.0, 0.02 },
	{141.0, 0.03 },
	{142.0, 0.02 },
	{146.0, 0.03 },
	{147.0, 0.03 },
	{150.0, 0.03 },
	{153.0, 0.02 },
	{154.0, 0.02 },
	{156.0, 0.02 },
	{157.0, 0.03 },
	{159.0, 0.02 },
	{160.0, 0.03 },
};

new m_alaplada = sizeof(AlapDrops);//"\w", 255, 255, 255
new m_kezdolada = sizeof(KezdoDrops);//"\d", 90, 90, 90,
new m_belepolada = sizeof(BelepoDrops);//"\r", 255, 0, 0,
new m_aranylada = sizeof(AranyDrops);//"\y", 255, 255, 0,
new m_platlada = sizeof(PlatinumDrops);
new m_szinozonlada = sizeof(SzinozonDrops);
new bool:FegyverMenuTiltas = false;

new const FegyverInfo[][LoadDatass] = {
	{0, "AK47 | Default", "models/v_ak47.mdl", "\d", 90, 90, 90, CSW_AK47}, 
	{1, "M4A1 | Default", "models/v_m4a1.mdl", "\d", 90, 90, 90, CSW_M4A1},
	{2, "AWP | Default", "models/v_awp.mdl", "\d", 90, 90, 90, CSW_AWP}, //26
	{3, "DEAGLE | Default", "models/v_deagle.mdl", "\d", 90, 90, 90, CSW_DEAGLE}, //39
	{4, "KNIFE | Default", "models/v_knife.mdl", "\d", 90, 90, 90, CSW_KNIFE},
	{5, "AK47 | Dragon King", "models\herboy\dragonking.mdl", "\r", 255, 0, 0, CSW_AK47}, // ALAP
	{6, "AK47 | Dragon King", "models\herboy\dragonking.mdl", "\w", 255, 255, 255, CSW_AK47},
	{7, "AK47 | Bloodsport", "models/herboy/v5mod/Bloodsport.mdl", "\w", 255, 255, 255, CSW_AK47},
	{8, "AK47 | Blue Bones", "models/herboy/v5mod/Blue_Bones.mdl", "\d", 90, 90, 90, CSW_AK47},
	{9, "AK47 | Brown", "models/herboy/v5mod/Brown.mdl", "\w", 255, 255, 255, CSW_AK47},
	{10, "AK47 | Devil Scope", "models/herboy/v5mod/devilScope.mdl", "\r", 255, 0, 0, CSW_AK47},
	{11, "AK47 | Elite Build", "models/herboy/v5mod/EliteBuild.mdl", "\d", 90, 90, 90, CSW_AK47},
	{12, "AK47 | Fire Serpent", "models/herboy/v5mod/FireSerpent.mdl", "\w", 255, 255, 255, CSW_AK47},
	{13, "AK47 | Frontside Misty", "models/herboy/v5mod/Frontsidemisty.mdl", "\d", 90, 90, 90, CSW_AK47},
	{14, "AK47 | Fuel Injector", "models/herboy/v5mod/FuelInjector.mdl", "\w", 255, 255, 255, CSW_AK47},
	{15, "AK47 | Furious Peacock", "models/herboy/v5mod/FuriousPeacock.mdl", "\r", 255, 0, 0, CSW_AK47},
	{16, "AK47 | Galaxy", "models/herboy/v5mod/Galaxy.mdl", "\w", 255, 255, 255, CSW_AK47},
	{17, "AK47 | Ganesha", "models/herboy/v5mod/Ganesha.mdl", "\d", 90, 90, 90, CSW_AK47},
	{18, "AK47 | Graffiti", "models/herboy/v5mod/Graffiti.mdl", "\d", 90, 90, 90, CSW_AK47},
	{19, "AK47 | Graphics Light", "models/herboy/v5mod/GraphicsLight.mdl", "\w", 255, 255, 255, CSW_AK47},
	{20, "AK47 | Grimmjow", "models/herboy/v5mod/Grimmjow.mdl", "\d", 90, 90, 90, CSW_AK47},
	{21, "AK47 | Lightning", "models/herboy/v5mod/Lighting.mdl", "\d", 90, 90, 90, CSW_AK47},
	{22, "AK47 | Meres", "models/herboy/v5mod/Meres.mdl", "\r", 255, 0, 0, CSW_AK47},
	{23, "AK47 | Neon Revolution", "models/herboy/v5mod/NeonRevolution.mdl", "\w", 255, 255, 255, CSW_AK47},
	{24, "AK47 | Neva", "models/herboy/v5mod/Neva.mdl", "\d", 90, 90, 90, CSW_AK47},
	{25, "AK47 | Next Technology", "models/herboy/v5mod/NextTechnology.mdl", "\d", 90, 90, 90, CSW_AK47},
	{26, "AK47 | Pintstripe", "models/herboy/v5mod/Pinstripe.mdl", "\w", 255, 255, 255, CSW_AK47},
	{27, "AK47 | Plate", "models/herboy/v5mod/plateversion.mdl", "\r", 255, 0, 0, CSW_AK47},
	{28, "AK47 | Propaganda", "models/herboy/v5mod/Propaganda.mdl", "\w", 255, 255, 255, CSW_AK47},
	{29, "AK47 | Purple94", "models/herboy/v5mod/Purple94.mdl", "\d", 90, 90, 90, CSW_AK47},
	{30, "AK47 | Rampage", "models/herboy/v5mod/rampage.mdl", "\w", 255, 255, 255, CSW_AK47},
	{31, "AK47 | Red Dragon", "models/herboy/v5mod/redDragon.mdl", "\w", 255, 255, 255, CSW_AK47},
	{32, "AK47 | Redline", "models/herboy/v5mod/redline.mdl", "\w", 255, 255, 255, CSW_AK47},
	{33, "AK47 | Rise", "models/herboy/v5mod/rise.mdl", "\y", 255, 255, 0, CSW_AK47},
	{34, "AK47 | Shark Attack", "models/herboy/v5mod/SharkAttack.mdl", "\r", 255, 0, 0, CSW_AK47},
	{35, "AK47 | Something", "models/herboy/v5mod/Something.mdl", "\r", 255, 0, 0, CSW_AK47},
	{36, "AK47 | Tron", "models/herboy/v5mod/Tron.mdl", "\y", 255, 255, 0, CSW_AK47},
	{37, "AK47 | U.F.O", "models/herboy/v5mod/UFO.mdl", "\w", 255, 255, 255, CSW_AK47},
	{38, "AK47 | Weed", "models/herboy/v5mod/wEED.mdl", "\w", 255, 255, 255, CSW_AK47},
	{39, "AK47 | Whiteout", "models/herboy/v5mod/whiteoutEdition.mdl", "\w", 255, 255, 255, CSW_AK47},
	{40, "AK47 | Anubis", "models/herboy/v5mod/anubis.mdl", "\y", 255, 255, 0, CSW_AK47},
	{41, "AK47 | Marihuana", "models\herboy/marihuana.mdl", "\y", 255, 255, 0, CSW_AK47},
	{42, "M4A1 | Bazilisk", "models/herboy/v5mod/Basilisk.mdl", "\w", 255, 255, 255, CSW_M4A1},
	{43, "M4A1 | Bercut", "models/herboy/v5mod/Bercut.mdl", "\r", 255, 0, 0, CSW_M4A1},
	{44, "M4A1 | Condor", "models/herboy/v5mod/Condor.mdl", "\w", 255, 255, 255, CSW_M4A1},
	{45, "M4A1 | Cutter", "models/herboy/v5mod/Cutter.mdl", "\y", 255, 255, 0, CSW_M4A1},
	{46, "M4A1 | Demolition Derby", "models/herboy/v5mod/demolitionDerby.mdl", "\r", 255, 0, 0, CSW_M4A1},
	{47, "M4A1 | Fallout", "models/herboy/v5mod/Fallout.mdl", "\d", 90, 90, 90, CSW_M4A1},
	{48, "M4A1 | High Voltage God", "models/herboy/v5mod/HighVoltageGod.mdl", "\r", 255, 0, 0, CSW_M4A1},
	{49, "M4A1 | Mechano Cannon", "models/herboy/v5mod/MechanoCannon.mdl", "\r", 255, 0, 0, CSW_M4A1},
	{50, "M4A1 | Musica", "models/herboy/v5mod/Musica.mdl", "\d", 90, 90, 90, CSW_M4A1},
	{51, "M4A1 | MX", "models/herboy/v5mod/MX.mdl", "\d", 90, 90, 90, CSW_M4A1},
	{52, "M4A1 | Optimus", "models/herboy/v5mod/OPTIMUS.mdl", "\y", 255, 255, 0, CSW_M4A1},
	{53, "M4A1 | Plasmax", "models/herboy/v5mod/Plasmax.mdl", "\d", 90, 90, 90, CSW_M4A1},
	{54, "M4A1 | Thundering Red", "models/herboy/v5mod/ThunderingRed.mdl", "\w", 255, 255, 255, CSW_M4A1},
	{55, "M4A1 | Ultramarine", "models/herboy/v5mod/Ultramarine.mdl", "\r", 255, 0, 0, CSW_M4A1},
	{56, "M4A1 | Asiimov", "models/herboy/v5mod/Assimov.mdl", "\w", 255, 255, 255, CSW_M4A1},
	{57, "M4A1 | Bonusz", "models/herboy/v5mod/Bonusz.mdl", "\d", 90, 90, 90, CSW_M4A1},
	{58, "M4A1 | Chanticos", "models/herboy/v5mod/Chantino.mdl", "\d", 90, 90, 90, CSW_M4A1},
	{59, "M4A1 | Critical", "models/herboy/v5mod/Critikal.mdl", "\d", 90, 90, 90, CSW_M4A1},
	{60, "M4A1 | Cyrex", "models/herboy/v5mod/Cyrex.mdl", "\w", 255, 255, 255, CSW_M4A1},
	{61, "M4A1 | Desolated Space", "models/herboy/v5mod/desolate.mdl", "\y", 255, 255, 0, CSW_M4A1},
	{62, "M4A1 | Dragoned", "models/herboy/v5mod/dragoned.mdl", "\y", 255, 255, 0, CSW_M4A1},
	{63, "M4A1 | Dragon King", "models/herboy/v5mod/dragonking.mdl", "\d", 90, 90, 90, CSW_M4A1},
	{64, "M4A1 | Grafiti", "models/herboy/v5mod/Grafiti.mdl", "\r", 255, 0, 0, CSW_M4A1},
	{65, "M4A1 | Hands", "models/herboy/v5mod/Hands1.mdl", "\d", 90, 90, 90, CSW_M4A1},
	{66, "M4A1 | Hyper Beast", "models/herboy/v5mod/Hippernigga.mdl", "\r", 255, 0, 0, CSW_M4A1},
	{67, "M4A1 | Howl", "models/herboy/v5mod/Howl.mdl", "\w", 255, 255, 255, CSW_M4A1},
	{68, "M4A1 | Legend", "models/herboy/v5mod/Legend.mdl", "\r", 255, 0, 0, CSW_M4A1},
	{69, "M4A1 | Modern", "models/herboy/v5mod/Modern.mdl", "\y", 255, 255, 0, CSW_M4A1},
	{70, "M4A1 | Night Wolf", "models/herboy/v5mod/NightWolf.mdl", "\r", 255, 0, 0, CSW_M4A1},
	{71, "M4A1 | Reflex", "models/herboy/v5mod/reflex.mdl", "\y", 255, 255, 0, CSW_M4A1},
	{72, "M4A1 | Roulet", "models/herboy/v5mod/roulet.mdl", "\d", 90, 90, 90, CSW_M4A1},
	{73, "M4A1 | Tetko", "models/herboy/v5mod/Tetko.mdl", "\w", 255, 255, 255, CSW_M4A1},
	{74, "M4A1 | Zombie Hunter", "models/herboy/v5mod/Zombihunter.mdl", "\d", 90, 90, 90, CSW_M4A1},	
	{75, "AWP | Boom", "models/herboy/v5mod/BACH.mdl", "\d", 90, 90, 90, CSW_AWP},
	{76, "AWP | Black Dragon", "models/herboy/v5mod/BlackDragon.mdl", "\y", 255, 255, 0, CSW_AWP},
	{77, "AWP | Blood Hunter", "models/herboy/v5mod/BloodHunter.mdl", "\r", 255, 0, 0, CSW_AWP},
	{78, "AWP | Bluvy", "models/herboy/v5mod/Bluvy.mdl", "\w", 255, 255, 255, CSW_AWP},
	{79, "AWP | Blue Line", "models/herboy/v5mod/blueline.mdl", "\w", 255, 255, 255, CSW_AWP},
	{80, "AWP | Crosshair *PP", "models/herboy/v5mod/crosshair.mdl", "\y", 255, 255, 0, CSW_AWP}, // PRÉMIUM GYANÚS
	{81, "AWP | Crouser", "models/herboy/v5mod/Crouser.mdl", "\r", 255, 0, 0, CSW_AWP},
	{82, "AWP | Dragon Lore", "models/herboy/v5mod/dragonLore.mdl", "\w", 255, 255, 255, CSW_AWP},
	{83, "AWP | Elite Build", "models/herboy/v5mod/EliteBuild.mdl", "\w", 255, 255, 255, CSW_AWP},
	{84, "AWP | Hyper Beast", "models/herboy/v5mod/HyperBeast.mdl", "\r", 255, 0, 0, CSW_AWP},
	{85, "AWP | Gold", "models/herboy/v5mod/Gold.mdl", "\w", 255, 255, 255, CSW_AWP},
	{86, "AWP | Gungir", "models/herboy/v5mod/Gungnir.mdl", "\y", 255, 255, 0, CSW_AWP},
	{87, "AWP | Hawking", "models/herboy/v5mod/Hawking.mdl", "\w", 255, 255, 255, CSW_AWP},
	{88, "AWP | Malaysia", "models/herboy/v5mod/MALAYSIA.mdl", "\d", 90, 90, 90, CSW_AWP},
	{89, "AWP | Medusa", "models/herboy/v5mod/Medusa.mdl", "\w", 255, 255, 255, CSW_AWP},
	{90, "AWP | Neo Noir", "models/herboy/v5mod/Neo-Noir.mdl", "\y", 255, 255, 0, CSW_AWP},
	{91, "AWP | Phobos", "models/herboy/v5mod/Phobos.mdl", "\w", 255, 255, 255, CSW_AWP},
	{92, "AWP | Prince", "models/herboy/v5mod/Prince.mdl", "\r", 255, 0, 0, CSW_AWP},
	{93, "AWP | Raptor", "models/herboy/v5mod/raptor.mdl", "\d", 90, 90, 90, CSW_AWP},
	{94, "AWP | Rave", "models/herboy/v5mod/rave.mdl", "\r", 255, 0, 0, CSW_AWP},
	{95, "AWP | Razer", "models/herboy/v5mod/razer2.mdl", "\w", 255, 255, 255, CSW_AWP},
	{96, "AWP | Red Mosaic", "models/herboy/v5mod/redMosaic.mdl", "\r", 255, 0, 0, CSW_AWP},
	{97, "AWP | Red", "models/herboy/v5mod/red.mdl", "\w", 255, 255, 255, CSW_AWP},
	{98, "AWP | Romeo And Juliet", "models/herboy/v5mod/romeoandJuliet.mdl", "\y", 255, 255, 0, CSW_AWP},
	{99, "AWP | Smoke", "models/herboy/v5mod/Smoke.mdl", "\w", 255, 255, 255, CSW_AWP},
	{100, "AWP | Sticker", "models/herboy/v5mod/Sticker.mdl", "\d", 90, 90, 90, CSW_AWP},
	{101, "AWP | Lightning Strike", "models/herboy/v5mod/LightningStrike.mdl", "\y", 255, 255, 0, CSW_AWP},
	{102, "AWP | Tiger", "models/herboy/v5mod/Tiger.mdl", "\r", 255, 0, 0, CSW_AWP},
	{103, "AWP | Utsuho", "models/herboy/v5mod/Utsuho.mdl", "\d", 90, 90, 90, CSW_AWP},
	{104, "AWP | Célkereszt", "models/herboy/v5mod/zoom.mdl", "\y", 255, 255, 0, CSW_AWP},

	{105, "DEAGLE | Alexandria", "models/herboy/v5mod/Alexandria.mdl", "\r", 255, 0, 0, CSW_DEAGLE},
	{106, "DEAGLE | Asiimov", "models/herboy/v5mod/Asimov.mdl", "\d", 90, 90, 90, CSW_DEAGLE},
	{107, "DEAGLE | Bloodsport", "models/herboy/v5mod/Bloodsport1.mdl", "\r", 255, 0, 0, CSW_DEAGLE},
	{108, "DEAGLE | Crimsonweb", "models/herboy/v5mod/CrimsonWeb.mdl", "\y", 255, 255, 0, CSW_DEAGLE},
	{109, "DEAGLE | Cyberwanderer Black", "models/herboy/v5mod/CyberwandererBlack.mdl", "\w", 255, 255, 255, CSW_DEAGLE},
	{110, "DEAGLE | Dragon Lore", "models/herboy/v5mod/dragonlore1.mdl", "\w", 255, 255, 255, CSW_DEAGLE},
	{111, "DEAGLE | Eldorado", "models/herboy/v5mod/Eldorado.mdl", "\r", 255, 0, 0, CSW_DEAGLE},
	{112, "DEAGLE | Ironforg", "models/herboy/v5mod/Ironforg.mdl", "\d", 90, 90, 90, CSW_DEAGLE},
	{113, "DEAGLE | Kill Confirmed", "models/herboy/v5mod/KillConfirmed.mdl", "\y", 255, 255, 0, CSW_DEAGLE},
	{114, "DEAGLE | LSD", "models/herboy/v5mod/LSD.mdl", "\w", 255, 255, 255, CSW_DEAGLE},
	{115, "DEAGLE | Mechano Cannon", "models/herboy/v5mod/MechanoCannon1.mdl", "\y", 255, 255, 0, CSW_DEAGLE},
	{116, "DEAGLE | Modernia", "models/herboy/v5mod/Modernia.mdl", "\r", 255, 0, 0, CSW_DEAGLE},
	{117, "DEAGLE | Red Lightning", "models/herboy/v5mod/redLightning.mdl", "\w", 255, 255, 255, CSW_DEAGLE},
	{118, "DEAGLE | SKRILLEX", "models/herboy/v5mod/SKRILLEX.mdl", "\r", 255, 0, 0, CSW_DEAGLE},
	{119, "DEAGLE | Frontside Misty", "models/herboy/v5mod/SnowWhirlwind.mdl", "\r", 255, 0, 0, CSW_DEAGLE},
	{120, "DEAGLE | Black Red", "models/herboy/v5mod/BlackRed.mdl", "\d", 90, 90, 90, CSW_DEAGLE},
	{121, "DEAGLE | Bocef", "models/herboy/v5mod/Bocef.mdl", "\y", 255, 255, 0, CSW_DEAGLE},
	{122, "DEAGLE | Empero", "models/herboy/v5mod/Empero.mdl", "\d", 90, 90, 90, CSW_DEAGLE},
	{123, "DEAGLE | Full", "models/herboy/v5mod/Full.mdl", "\w", 255, 255, 255, CSW_DEAGLE},
	{124, "DEAGLE | Kumicho Dragon", "models/herboy/v5mod/KumichoDragon.mdl", "\r", 255, 0, 0, CSW_DEAGLE},
	{125, "DEAGLE | Global", "models/herboy/v5mod/Global.mdl", "\d", 90, 90, 90, CSW_DEAGLE},
	{126, "DEAGLE | Himea", "models/herboy/v5mod/Himea.mdl", "\w", 255, 255, 255, CSW_DEAGLE},
	{127, "DEAGLE | Join", "models/herboy/v5mod/Join.mdl", "\d", 90, 90, 90, CSW_DEAGLE},
	{128, "DEAGLE | Laserdigi", "models/herboy/v5mod/Laserdigi.mdl", "\r", 255, 0, 0, CSW_DEAGLE},
	{129, "DEAGLE | Laser", "models/herboy/v5mod/Lasser.mdl", "\w", 255, 255, 255, CSW_DEAGLE},
	{130, "DEAGLE | Látvány", "models/herboy/v5mod/Latvany.mdl", "\d", 90, 90, 90, CSW_DEAGLE},
	{131, "DEAGLE | Nakare", "models/herboy/v5mod/Nakare.mdl", "\w", 255, 255, 255, CSW_DEAGLE},
	{132, "DEAGLE | Neon", "models/herboy/v5mod/Neonned.mdl", "\y", 255, 255, 0, CSW_DEAGLE},
	{133, "DEAGLE | Nevendula", "models/herboy/v5mod/Nevendula.mdl", "\w", 255, 255, 255, CSW_DEAGLE},
	{134, "DEAGLE | Old Dragon", "models/herboy/v5mod/OldDragon.mdl", "\d", 90, 90, 90, CSW_DEAGLE},
	{135, "DEAGLE | Razer", "models/herboy/v5mod/razer.mdl", "\d", 90, 90, 90, CSW_DEAGLE},
	{136, "DEAGLE | Blaze", "models/herboy/v5mod/Blaze.mdl", "\w", 255, 255, 255, CSW_DEAGLE},
	{137, "DEAGLE | Skinaru", "models/herboy/v5mod/Skinaru.mdl", "\d", 90, 90, 90, CSW_DEAGLE},

	{138, "Karambit | Abstact", "models/herboy/v5mod/ABSTR.mdl", "\y", 255, 255, 0, CSW_KNIFE},
	{139, "Bayonet | Shark", "models/herboy/v5mod/BayonetShark.mdl", "\r", 255, 0, 0, CSW_KNIFE},
	{140, "Butterfly | Fade", "models/herboy/v5mod/ButterflyFade.mdl", "\y", 255, 255, 0, CSW_KNIFE},
	{141, "Butterfly | Crimson Web", "models/herboy/v5mod/ButterflyKnifeCrimsonWeb.mdl", "\y", 255, 255, 0, CSW_KNIFE},
	{142, "Butterfly | Dragorian", "models/herboy/v5mod/ButterflyKnifeDragonian.mdl", "\r", 255, 0, 0, CSW_KNIFE},
	{143, "Butterfly | Lite", "models/herboy/v5mod/ButterflyKnifeLite.mdl", "\r", 255, 0, 0, CSW_KNIFE},
	{144, "Butterfly | Song Of Ice", "models/herboy/v5mod/ButterflyKnifeSongofIce.mdl", "\r", 255, 0, 0, CSW_KNIFE},
	{145, "Falchion Doppler | Blue", "models/herboy/v5mod/FalchionDopplerBlue.mdl", "\y", 255, 255, 0, CSW_KNIFE},
	{146, "Falchion Slaughther", "models/herboy/v5mod/FalchionSlaughther.mdl", "\y", 255, 255, 0, CSW_KNIFE},
	{147, "Falchion Slaughther", "models/herboy/v5mod/FalchionSlaughther.mdl", "\y", 255, 255, 0, CSW_KNIFE},
	{148, "KNIFE | Green Soul", "models/herboy/v5mod/GreenSoulKnife.mdl", "\r", 255, 0, 0, CSW_KNIFE},
	{149, "KNIFE | Grizzly", "models/herboy/v5mod/grizzLY.mdl", "\y", 255, 255, 0, CSW_KNIFE},
	{150, "Gut Knife | Lavatron", "models/herboy/v5mod/GutKnifeLavatron.mdl", "\r", 255, 0, 0, CSW_KNIFE},
	{151, "Gut Knife | Vibranium", "models/herboy/v5mod/GutKnifeVibranium.mdl", "\r", 255, 0, 0, CSW_KNIFE},
	{152, "Karambit | Superfurry", "models/herboy/v5mod/KarambitSuperfurry.mdl", "\y", 255, 255, 0, CSW_KNIFE},
	{153, "Karambit | Tigertooth", "models/herboy/v5mod/KarambitTigerTooth.mdl", "\y", 255, 255, 0, CSW_KNIFE},
	{154, "Karambit | Ultraviolet", "models/herboy/v5mod/KarambitUltraviolet.mdl", "\r", 255, 0, 0, CSW_KNIFE},
	{155, "Karambit | Blue Dreamer", "models/herboy/v5mod/KarambitBlueDreamer.mdl", "\y", 255, 255, 0, CSW_KNIFE},
	{156, "Karambit | Kombat", "models/herboy/v5mod/Kombat.mdl", "\y", 255, 255, 0, CSW_KNIFE},
	{157, "M9 Bayonet | Armageddon", "models/herboy/v5mod/M9BayonetArmageddon.mdl", "\r", 255, 0, 0, CSW_KNIFE},
	{158, "M9 Bayonet | Damascus Steel", "models/herboy/v5mod/M9BayonetDamascusSteel.mdl", "\y", 255, 255, 0, CSW_KNIFE},
	{159, "M9 Bayonet | Doppler Sapphire", "models/herboy/v5mod/M9BayonetDopplerSapphire.mdl", "\y", 255, 255, 0, CSW_KNIFE},
	{160, "M9 Bayonet | Dragon Soul", "models/herboy/v5mod/M9BayonetDragonSoul.mdl", "\y", 255, 255, 0, CSW_KNIFE},
	{161, "M9 Bayonet | Gamma Doppler *PP", "models/herboy/v5mod/M9BayonetGammaDoppler.mdl", "\r", 255, 0, 0, CSW_KNIFE}, //PÉPÉ GYANÚS
	{162, "KNIFE | Marble Fade", "models/herboy/v5mod/MarbleFade.mdl", "\r", 255, 0, 0, CSW_KNIFE},
	{163, "Navaja | Fade", "models/herboy/v5mod/Navaja.mdl", "\r", 255, 0, 0, CSW_KNIFE},
	{164, "KNIFE | Fade", "models/herboy/v5mod/Standard.mdl", "\r", 255, 0, 0, CSW_KNIFE},
	{165, "Butterfly | Asiimov", "models/herboy/v5mod/AsiimovButterfly.mdl", "\r", 255, 0, 0, CSW_KNIFE},
	{166, "Assasin", "models/herboy/v5mod/Assasin.mdl", "\y", 255, 255, 0, CSW_KNIFE}, //PÉPÉ GYANÚS
	{167, "Balta", "models/herboy/v5mod/Balta.mdl", "\y", 255, 255, 0, CSW_KNIFE}, //PÉPÉ GYANÚS
	{168, "KNIFE | Death", "models/herboy/v5mod/death.mdl", "\y", 255, 255, 0, CSW_KNIFE},
	{169, "Karambit | Galaxy", "models/herboy/v5mod/GalaxyKarambit.mdl", "\r", 255, 0, 0, CSW_KNIFE},
	{170, "Karambit | Gamma", "models/herboy/v5mod/Gammakarambit.mdl", "\r", 255, 0, 0, CSW_KNIFE}, 
	{171, "KNIFE | Heineken", "models/herboy/v5mod/Heineken.mdl", "\y", 255, 255, 0, CSW_KNIFE},
	{172, "M9 Bayonet | Lore", "models/herboy/v5mod/LoreBayonet.mdl", "\y", 255, 255, 0, CSW_KNIFE},
	{173, "Butterfly | Lore", "models/herboy/v5mod/LoreButterfly.mdl", "\y", 255, 255, 0, CSW_KNIFE},
	{174, "Gut Knife | Lore", "models/herboy/v5mod/LoreGut.mdl", "\r", 255, 0, 0, CSW_KNIFE},
	{175, "Karambit | Lore", "models/herboy/v5mod/LoreKarambit.mdl", "\y", 255, 255, 0, CSW_KNIFE},
	{176, "Butterfly | Marble", "models/herboy/v5mod/MarbeleButterfly.mdl", "\y", 255, 255, 0, CSW_KNIFE}, 
	{177, "Gut Knife | Razer", "models/herboy/v5mod/razerGut.mdl", "\r", 255, 0, 0, CSW_KNIFE},
	{178, "Flip | Asus ROG", "models/herboy/v5mod/rogFlip.mdl", "\r", 255, 0, 0, CSW_KNIFE},
	{179, "Karambit | Naplemente", "models/herboy/v5mod/KarambitNaplemente.mdl", "\y", 255, 255, 0, CSW_KNIFE},
	{180, "Owine | Fekete tigrisfog", "models/herboy/v5mod/Tigrisfog.mdl", "\r", 255, 0, 0, CSW_KNIFE},
	{181, "Vibrátor", "models/herboy/v5mod/Vibrator.mdl", "\y", 255, 255, 0, CSW_KNIFE},
	{182, "Biohazard Knife", "models/herboy/v5mod/biohazard.mdl", "\y", 255, 255, 0, CSW_KNIFE},
	{183, "Wolf Sight Blade", "models/herboy/v5mod/wolfslight.mdl", "\y", 255, 255, 0, CSW_KNIFE},

	{184, "AK47 | CARRY KOVA", "models/herboy/v5mod/privskin/kovak.mdl", "\y", 255, 255, 0, CSW_AK47},
	{185, "DEAGLE | CARRY KOVA", "models/herboy/v5mod/privskin/kovadg.mdl", "\y", 255, 255, 0, CSW_DEAGLE},
	{186, "KNIFE | CARRY KOVA", "models/herboy/v5mod/privskin/kovakk.mdl", "\y", 255, 255, 0, CSW_KNIFE},
	{187, "AK47 | Black Ice", "models/herboy/blackice/ak47.mdl", "\y", 255, 255, 0, CSW_AK47},  //75
	{188, "M4A1 | Black Ice", "models/herboy/blackice/m4a1.mdl", "\y", 255, 255, 0, CSW_M4A1}, 
	{189, "AWP | Black Ice", "models/herboy/blackice/awp.mdl", "\y", 255, 255, 0, CSW_AWP}, 
	{190, "DEAGLE | Black Ice", "models/herboy/blackice/deagle.mdl", "\y", 255, 255, 0, CSW_DEAGLE}, 
	{191, "AK47 | Cannabis Life", "models/herboy/cannabis/v_cannabislife_vipak47.mdl", "\y", 255, 255, 0, CSW_AK47},  //79
	{192, "M4A1 | Cannabis Life", "models/herboy/cannabis/v_cannabislife_vipm4a1.mdl", "\y", 255, 255, 0, CSW_M4A1},  //75
	{193, "AWP | Cannabis Life", "models/herboy/cannabis/v_cannabislife_vipawp.mdl", "\y", 255, 255, 0, CSW_AWP}, 
	{194, "DEAGLE | Cannabis Life", "models/herboy/cannabis/v_cannabislife_vipdeagle.mdl", "\y", 255, 255, 0, CSW_DEAGLE}, 
	{195, "Karambit | Black Ice", "models/herboy/blackice/Karambit.mdl", "\y", 255, 255, 0, CSW_KNIFE},
	{196, "Shadow Daggers | Black Ice", "models/herboy/blackice/Daggers.mdl", "\y", 255, 255, 0, CSW_KNIFE},
	{197, "Butterfly | Black Ice", "models/herboy/blackice/Butterfly.mdl", "\y", 255, 255, 0, CSW_KNIFE},
	{198, "Karambit | Cannabis Life", "models/herboy/cannabis/v_cannabislife_vipknife.mdl", "\y", 255, 255, 0, CSW_KNIFE},
	{199, "Gradient | MultiHearth", "models/herboy/cannabis/v_cannabislife_vipknife.mdl", "\y", 255, 255, 0, CSW_KNIFE}, //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	{200, "Gradient | Rainbow", "models/herboy/cannabis/v_cannabislife_vipknife.mdl", "\y", 255, 255, 0, CSW_KNIFE},

	{201, "AK47 | Taktik - VIP", "models/herboy/tron/red/v_ak47.mdl", "\y", 255, 255, 0, CSW_AK47},  //79
	{202, "M4A1 | Taktik - VIP", "models/herboy/tron/red/v_ak47.mdl", "\y", 255, 255, 0, CSW_M4A1},  //75
	{203, "AWP | Taktik - VIP", "models/herboy/tron/red/v_ak47.mdl", "\y", 255, 255, 0, CSW_AWP}, 
	{204, "DEAGLE | Taktik - VIP", "models/herboy/tron/red/v_ak47.mdl", "\y", 255, 255, 0, CSW_DEAGLE}, 
	{205, "Gut Knife | Taktik - VIP", "models/herboy/tron/red/v_ak47.mdl", "\y", 255, 255, 0, CSW_KNIFE},
	{206, "AK47 | Indirect - VIP", "models/herboy/tron/red/v_ak47.mdl", "\y", 255, 255, 0, CSW_AK47},  //79
	{207, "M4A1 | Indirect - VIP", "models/herboy/tron/red/v_ak47.mdl", "\y", 255, 255, 0, CSW_M4A1},  //75
	{208, "AWP | Indirect - VIP", "models/herboy/tron/red/v_ak47.mdl", "\y", 255, 255, 0, CSW_AWP}, 
	{209, "DEAGLE | Indirect - VIP", "models/herboy/tron/red/v_ak47.mdl", "\y", 255, 255, 0, CSW_DEAGLE}, 
	{210, "M9 Bayonet | Indirect - VIP", "models/herboy/tron/red/v_ak47.mdl", "\y", 255, 255, 0, CSW_KNIFE},
	{211, "M4A1 | Tron", "models/herboy/tron/blue/v_m4a1.mdl", "\y", 255, 255, 0, CSW_M4A1}, 
	{212, "DEAGLE | Tron", "models/herboy/tron/blue/v_deagle.mdl", "\y", 255, 255, 0, CSW_DEAGLE},
	{213, "AWP | Tron", "models/herboy/tron/blue/v_awp.mdl", "\y", 255, 255, 0, CSW_AWP}, 
	{214, "KNIFE | Tron", "models/herboy/tron/blue/v_knife.mdl", "\y", 255, 255, 0, CSW_KNIFE},

	{215, "AK47 | Red Tron", "models/herboy/tron/red/v_ak47.mdl", "\y", 255, 0, 255, CSW_AK47},
	{216, "M4A1 | Red Tron", "models/herboy/tron/red/v_m4a1.mdl", "\y", 255, 0, 255, CSW_M4A1}, 
	{217, "DEAGLE | Red Tron", "models/herboy/tron/red/v_deagle.mdl", "\y", 255, 0, 255, CSW_DEAGLE},
	{218, "AWP | Red Tron", "models/herboy/tron/red/v_awp.mdl", "\y", 255, 0, 255, CSW_AWP}, 
	{219, "KNIFE | Red Tron", "models/herboy/tron/red/v_knife.mdl", "\y", 255, 0, 255, CSW_KNIFE},

	{220, "AK47 | Green Tron", "models/herboy/tron/green/v_ak47.mdl", "\y", 255, 0, 255, CSW_AK47},
	{221, "M4A1 | Green Tron", "models/herboy/tron/green/v_m4a1.mdl", "\y", 255, 0, 255, CSW_M4A1}, 
	{222, "DEAGLE | Green Tron", "models/herboy/tron/green/v_deagle.mdl", "\y", 255, 0, 255, CSW_DEAGLE},
	{223, "AWP | Green Tron", "models/herboy/tron/green/v_awp.mdl", "\y", 255, 0, 255, CSW_AWP}, 
	{224, "KNIFE | Green Tron", "models/herboy/tron/green/v_knife.mdl", "\y", 255, 0, 255, CSW_KNIFE},

	{225, "AK47 | Lime Tron", "models/herboy/tron/lime/v_ak47.mdl", "\y", 255, 0, 255, CSW_AK47},
	{226, "M4A1 | Lime Tron", "models/herboy/tron/lime/v_m4a1.mdl", "\y", 255, 0, 255, CSW_M4A1}, 
	{227, "DEAGLE | Lime Tron", "models/herboy/tron/lime/v_deagle.mdl", "\y", 255, 0, 255, CSW_DEAGLE},
	{228, "AWP | Lime Tron", "models/herboy/tron/lime/v_awp.mdl", "\y", 255, 0, 255, CSW_AWP}, 
	{229, "KNIFE | Lime Tron", "models/herboy/tron/lime/v_knife.mdl", "\y", 255, 0, 255, CSW_KNIFE},
}
new const SkinModelsInfo[][LoadSkin] = {
	{0, "joker", "Joker | T Playerskin", "models/player/joker/joker.mdl", CS_TEAM_T},
	{1, "skinhead", "Skinhead | CT Playerskin", "models/player/skinhead/skinhead.mdl", CS_TEAM_CT},
	{2, "tommy", "Tommy Vercetti | T Playerskin", "models/player/tommy/tommy.mdl", CS_TEAM_T},
	{3, "twctclass", "TWR Class | CT Playerskin", "models/player/twctclass/twctclass.mdl", CS_TEAM_CT},
	{4, "twtrclass", "TWR Class | T Playerskin", "models/player/twtrclass/twtrclass.mdl", CS_TEAM_T},
	{5, "umbrella", "Umbrella | CT Playerskin", "models/player/umbrella/umbrella.mdl", CS_TEAM_CT},
	{6, "jason", "Jason | T Playerskin", "models/player/jason/jason.mdl", CS_TEAM_T},
	{7, "anonim", "Anonim | CT Playerskin", "models/player/anonim/anonim.mdl", CS_TEAM_CT},
}
enum _:RangAdatok {
	RangName[32],
	ELO[8]
}
new const Rangok[][RangAdatok] = {
	{"Újonc", 0},
	{"Elismert", 400},
	{"Mester", 800},
	{"Tehénbaszó", 1500},
	{"Szarzsák", 2200},
	{"Csövesbánat", 3300},
	{"Hajléktalan", 5500},
	{"Elbűvölő szökevény", 8500},
	{"Szolga", 11250},
	{"Sztár", 13100},
	{"Rendfenttartó", 15000},
	{"Alázó", 18520},
	{"Gyilkos", 19930},
	{"Kocka", 23500},
	{"Büdös Kocka", 29320},
	{"Pornósztár", 46000},
	{"Vérengző", 67300},
	{"Pusztitó", 86000},
	{"Brutális", 112300},
	{"The Global Elite", 9112300},
	{"The Global Elite", 991120300},
}	
new const PrivateRanks[][] = {
	{"Recruit Rank 0"},
	{"Private Rank 1"},
	{"Private Rank 2"},
	{"Private Rank 3"},
	{"Private Rank 4"},
	{"Corporal Rank 5"},
	{"Corporal Rank 6"},
	{"Corporal Rank 7"},
	{"Corporal Rank 8"},
	{"Sergeant Rank 9"},
	{"Sergeant Rank 10"},
	{"Sergeant Rank 11"},
	{"Sergeant Rank 12"},
	{"Master Sergeant Rank 13"},
	{"Master Sergeant Rank 14"},
	{"Master Sergeant Rank 15"},
	{"Master Sergeant Rank 16"},
	{"Sergeant Major Rank 17"},
	{"Sergeant Major Rank 18"},
	{"Sergeant Major Rank 19"},
	{"Sergeant Major Rank 20"},
	{"Lieutenant Rank 21"},
	{"Lieutenant Rank 22"},
	{"Lieutenant Rank 23"},
	{"Lieutenant Rank 24"},
	{"Captain Rank 25"},
	{"Captain Rank 26"},
	{"Captain Rank 27"},
	{"Captain Rank 28"},
	{"Major Rank 29"},
	{"Major Rank 30"},
	{"Major Rank 31"},
	{"Major Rank 32"},
	{"Colonel Rank 33"},
	{"Colonel Rank 34"},
	{"Colonel Rank 35"},
	{"Brigadier General Rank 36"},
	{"Major General Rank 37"},
	{"Lieutenant General Rank 38"},
	{"General Rank 39"},
	{"Global General Rank 40"},
	{"--- Give Service Medal ---"},
	{"--- Give Service Medal ---"},
}
new const Admin_Permissions[][][] = {
	//rang név | Jogok | Hozzáadhat-e admint? (0-Nem | 1-Igen)| Hozzáadhat-e VIP-t? (0-Nem | 1-Igen) | Bannolhat accot? 0 nem 1 igen
	{"Játékos", "z", "0", "0"}, //Játékos - 0
	{"Fejlesztő", "abcvnmlpoikujzhtgrfedwsyc", "1", "1"}, //Konfigos - 1
	{"Tulajdonos", "abcvnmlpoikujzhtgrfedwsayc", "1", "1"}, //Tulajdonos - 2
	{"FőAdmin", "bmcfscjgdtiue", "4", "1"}, //FőAdmin - 4
	{"Admin", "bmcfscdtijue", "0", "0"}, //Admin - 5
	{"Moderátor", "bmcfsjcdtiue", "0", "0"}, //Admin - 6
	{"Hacker", "bmcfscdtjiue", "0", "0"}, //Kova egyedi fisfos - 7
	{"Streamer", "z", "0", "0"}
};
new Market[33][MarketSys]
new SltGun[33][SelectedGun][2];
new Key[33][sizeof(Keys)], Case[33][sizeof(Cases)];
new TippKey[33][TippKeyDatas]
new g_Player[33][PlayerSys], FirstJoin[33] = 0;
new SCvar[ServerCvars]
new dSync, aSync, cSync, g_korkezdes;
new Handle:g_SqlTuple;
new Fragverseny = 0, Fragkorok
new FragJutalmak1, FragJutalmak2, FragJutalmak3;
new AllRegistedRank;
new g_CTWins, g_TEWins;
new g_Mute[33][33];
public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	dSync = CreateHudSyncObj();
	aSync = CreateHudSyncObj();
	cSync = CreateHudSyncObj();
	//EBUGS
	register_clcmd("giveItem", "cmdGive", _, "Elso switch!", ADMIN_IMMUNITY);
	SCvar[vipCost] = register_cvar("vip_cost", "20.00");
	SCvar[pvipCost] = register_cvar("pvip_cost", "400");
	SCvar[StatTrakCost] = register_cvar("st_cost", "30.00");
	SCvar[NametagCost] = register_cvar("nt_cost", "55.00");
	SCvar[ChatPrefixCost] = register_cvar("chat_cost", "25.00");
	SCvar[SorsjegyCost] = register_cvar("sors_cost", "10.00");
	SCvar[XPBoosterCost] = register_cvar("xbo_cost", "50.00");
	SCvar[ppszorzaspaypal] = register_cvar("ppszorzo_paypal", "1.00");
	SCvar[ppszorzassms] = register_cvar("ppszorzo_sms", "1.00");
	SCvar[ppevent] = register_cvar("pp_event", "0");
	SCvar[maxkor] = register_cvar("maxkor", "60");
	get_mapname(FegyoMapName, charsmax(FegyoMapName));
	//EGISTERS
	register_impulse(201, "CheckMain");
	register_concmd("bn_set_admin", "CmdSetAdmin", _, "<#id> <jog>");
	register_concmd("bn_set_vip", "CmdSetVIP", _, "<#id> <ido>");
	register_concmd("amx_map", "cmdSMap", ADMIN_MAP, "<mapname>")
	//register_clcmd("say /teszt", "adddd", ADMIN_ADMIN);
	register_clcmd("say /fegyo", "fegyvermenu");
	register_clcmd("say /top15", "CmdTop15");
	register_clcmd("say /admin", "cmdAdmin");
	register_clcmd("say /banlista", "cmdBanlista");
	register_clcmd("say /rank", "CmdRank");
	register_clcmd("say /guns", "fegyvermenu");
	register_clcmd("say /fegyver", "fegyvermenu");
	register_clcmd("say /oles", "TopOles");
	register_clcmd("say /mute", "openPlayerChooserMute", ADMIN_IMMUNITY)
	register_clcmd("say /karbantartas", "setKarbi", ADMIN_IMMUNITY);
	register_clcmd("say spawn", "hpDobas")
	register_concmd("bugfix", "teszt1", ADMIN_IMMUNITY);
	register_concmd("/addolascsakshedi", "adddd", ADMIN_IMMUNITY);
	register_clcmd("say", "Hook_Say");

	register_menucmd(register_menuid("MAINMENU"), 1023, "hMainMenu")
	register_menucmd(register_menuid("ARUHAZMENU"), 1023, "Aruhaz_h")
	register_menucmd(register_menuid("RAKTARMENU"), 1023, "hRaktarMenu")
	register_menucmd(register_menuid("KUKASWITCH"), 1023, "KukaSwitchHandler")
	register_menucmd(register_menuid("MARKETMENU"), 1023, "hMarketMenu")
	register_menucmd(register_menuid("TOOLSMENU"), 1023, "hToolsMenu")
	register_menucmd(register_menuid("KULDESMENU"), 1023, "openMarketSwitch_h")
	register_clcmd("DOLLAR_AR", "cmdDollarEladas");
	register_clcmd("VIPnap", "cmdVIPDay")
	register_clcmd("SET_NAMETAG", "cmdAddNametag")
	register_clcmd("SET_RENAMETAG", "cmdAddNametag")
	register_clcmd("EnterPrefix", "set_Prefix");
	register_clcmd("Kuldes_Mennyisege", "ObjectSend");
	RegisterHam(Ham_Item_Deploy, "weapon_m4a1", "Change_Weapon", 1);
	RegisterHam(Ham_Item_Deploy, "weapon_ak47", "Change_Weapon", 1);
	RegisterHam(Ham_Item_Deploy, "weapon_awp", "Change_Weapon", 1);
	RegisterHam(Ham_Item_Deploy, "weapon_deagle", "Change_Weapon", 1);
	RegisterHam(Ham_Item_Deploy, "weapon_knife", "Change_Weapon", 1);
	RegisterHam(Ham_Item_Deploy, "weapon_m249", "NoWeapChange", 1);
	RegisterHam(Ham_Item_Deploy, "weapon_aug", "NoWeapChange", 1);
	RegisterHam(Ham_Item_Deploy, "weapon_famas", "NoWeapChange", 1);
	RegisterHam(Ham_Item_Deploy, "weapon_galil", "NoWeapChange", 1);
	RegisterHam(Ham_Item_Deploy, "weapon_mp5navy", "NoWeapChange", 1);
	RegisterHam(Ham_Item_Deploy, "weapon_xm1014", "NoWeapChange", 1);
	RegisterHam(Ham_Item_Deploy, "weapon_m3", "NoWeapChange", 1);
	RegisterHam(Ham_Item_Deploy, "weapon_scout", "NoWeapChange", 1);
	RegisterHam(Ham_Item_Deploy, "weapon_mac10", "NoWeapChange", 1);
	RegisterHam(Ham_Item_Deploy, "weapon_tmp", "NoWeapChange", 1);
	RegisterHam(Ham_Item_Deploy, "weapon_hegrenade", "NoWeapChange", 1);
	RegisterHam(Ham_Item_Deploy, "weapon_smokegrenade", "NoWeapChange", 1);
	RegisterHam(Ham_Item_Deploy, "weapon_flashbang", "NoWeapChange", 1);
	RegisterHam(Ham_TakeDamage, "player", "PlayerGetHit");
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_m4a1", "Attack_AutomaticGun", 1);
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_ak47", "Attack_AutomaticGun", 1);
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_mp5navy", "Attack_AutomaticGun", 1);
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_famas", "Attack_AutomaticGun", 1);
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_galil", "Attack_AutomaticGun", 1);
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_aug", "Attack_AutomaticGun", 1);
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_tmp", "Attack_AutomaticGun", 1);
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_mac10", "Attack_AutomaticGun", 1);
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_awp", "Attack_SingleShotGun", 1);
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_deagle", "Attack_SingleShotGun", 1);
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_scout", "Attack_SingleShotGun", 1)
	register_forward(FM_Touch,"ForwardTouch" );
	register_forward(FM_Touch,"ForwardMedkitTouch" );
fwd_logined = CreateMultiForward("LoggedSuccesfully", ET_IGNORE, FP_CELL)
	RegisterHam(Ham_Spawn, "player" ,"Spawn", 1);
	register_event("DeathMsg","eDeathMsg","a")
	register_event("HLTV", "ujkor", "a", "1=0", "2=0");
	register_event("Money", "setUserMoney", "b");
	register_event("TextMsg", "restart_round", "a", "2=#Game_will_restart_in");
	register_event("SendAudio", "TerrorsWin" , "a", "2&%!MRAD_terwin");
	register_event("SendAudio", "CTerrorsWin", "a", "2&%!MRAD_ctwin");
	register_logevent("RoundEnds", 2, "1=Round_End")
	register_forward(FM_Voice_SetClientListening, "fwd_voice_setclientlistening");

	if(containi( FegyoMapName, "awp" ) != -1)
	{
		FegyverMenuTiltas = true;
		RegisterHam(Ham_Spawn,"player","awpkezdes",1);
	}
	else if(containi( FegyoMapName, "scout") != -1)
	{		
		FegyverMenuTiltas = true;
		RegisterHam(Ham_Spawn,"player","scoutkezdes",1);
	}	

	if(containi( FegyoMapName, "awp4one" ) != -1)
		FegyverMenuTiltas = true;
	else if(containi(FegyoMapName, "aim") != -1)
		FegyverMenuTiltas = true;
	else if(containi(FegyoMapName, "cs_deagle5") != -1)
		FegyverMenuTiltas = true;
	else if(containi(FegyoMapName, "$") != -1)
		FegyverMenuTiltas = true;
	else if(containi(FegyoMapName, "fy") != -1)
		FegyverMenuTiltas = true;
	else if(containi(FegyoMapName, "de") != -1)
		FegyverMenuTiltas = false;
	else if(containi(FegyoMapName, "css") != -1)
		FegyverMenuTiltas = false;
	else if(containi(FegyoMapName, "he") != -1)
		FegyverMenuTiltas = true;
	else if(containi(FegyoMapName, "35hp") != -1)
		FegyverMenuTiltas = true;
	else if(containi(FegyoMapName, "ka") != -1)
		FegyverMenuTiltas = true;
	else if(containi(FegyoMapName, "1hp") != -1)
		FegyverMenuTiltas = true;
	else if(containi(FegyoMapName, "pool") != -1)
		FegyverMenuTiltas = true;

	//TASK
	g_Maxplayers = get_maxplayers();
	set_task(1.0, "Check",_,_,_,"b");
	set_task(120.0, "Hirdetes",_,_,_,"b");

	g_Inventory = ArrayCreate(InventorySystem);
	g_Products = ArrayCreate(MarketSys);
}
public CheckMain(id)
{
	if(sk_get_logged(id))
		openMainMenu(id);
}
public awpkezdes(id)
{	
	strip_user_weapons(id);
	give_item(id, "weapon_awp");
	give_item(id, "weapon_knife");
	cs_set_user_bpammo(0, CSW_AWP, 90);
	client_print_color(id, print_team_default, "^4%s^1Megkaptad ^3AWP ^1fegyvert^4 90 tölténnyel.", CHATPREFIX);
}
public scoutkezdes(id)
{
	strip_user_weapons(id);
	give_item(id, "weapon_scout");
	give_item(id, "weapon_knife");
	cs_set_user_bpammo(0, CSW_SCOUT, 90);
	client_print_color(id, print_team_default, "^4%s^1Megkaptad ^3SCOUT ^1fegyvert^4 90 tölténnyel.", CHATPREFIX);
}	
public cmdBanlista(id)
{
	show_motd(id, "http://herboyteam.hu/ban/teszt.php", "Banlista")
}
public cmdAdmin(id)
{
	show_motd(id, "http://rtdteam.hu/admin/index.php", "Adminok")
}
public fwd_voice_setclientlistening(receiver, sender, listen) 
{
	if(receiver == sender)
		return FMRES_IGNORED
		
	if(g_Mute[receiver][sender])
	{
		EF_SetClientListening(receiver, sender, false)
		return FMRES_SUPERCEDE
	}
	return FMRES_IGNORED
}
public Hirdetes()
{
	switch(random_num(1,1))
	{
		case 1: client_print_color(0, print_team_default, "^4%s^1Jelenleg nincs ^3dupla pp^1 jóváírás!", CHATPREFIX)
		case 2: client_print_color(0, print_team_default, "^4%s^1Szeretnél egyedi célkeresztet? Írd be a chatre ^4/cross", CHATPREFIX)
		case 3: client_print_color(0, print_team_default, "^4%s^3Tilos^1 a ^3BGS/SGS/GS^1 jutalom^3 1 ^1hetes ban!", CHATPREFIX)
		case 4: client_print_color(0, print_team_default, "^4%s^4Tudtad?^1 A szerverbe bekerült^3 3 új ^4Tron^1 fegyvercsomag! ^3Prémium ^1menüben megtalálható, eladható verzióban!", CHATPREFIX)
		case 5: client_print_color(0, print_team_default, "^4%s^4Tudtad?^1 A vicces hangokat mostmár megtudod nézni a ^3/hangok^1 paranccsal!", CHATPREFIX)
		case 6: client_print_color(0, print_team_default, "^4%s^4Tudtad?^1 A ^3/mute^1 paranccsal letudod ^4némítani^1 a játékosokat!", CHATPREFIX)
		case 7: client_print_color(0, print_team_default, "^4%s^4Parancsok! ^1bind betű ^3takeadookie^1 - ^3szarás ^1| ^3ejaculate^1 - ^3kiverés^1 |^3 puke ^1-^3 hányás^4, a holttesten!", CHATPREFIX)
	}
}
public setKarbi(id)
{
	karbantartas = 1;
}
public Attack_AutomaticGun(ent)
{
	static id; id = pev(ent, 18);

	Player_Stats[id][wAllShotCount]++;

	return HAM_IGNORED;
}

public Attack_SingleShotGun(ent)
{
	static id; id = pev(ent, 18);

	Player_Stats[id][wAllShotCount]++;
	
	return HAM_IGNORED;
}

public PlayerGetHit(victim, inflictor, attacker, Float:damage, bits)
{
	if(!(bits & DMG_BULLET))
		return HAM_IGNORED;
	
	Player_Stats[attacker][wAllHitCount]++;
	return HAM_IGNORED;
}
public cmdSMap(id)
{
	if(!id == 0)
	{
	if(g_Player[id][AdminLvL] < 1)
		return;
	}
		
	new arg[32], name[33];
	get_user_name(id, name, charsmax(name))
	new arglen = read_argv(1, arg, charsmax(arg))

	if(!is_map_valid(arg) || contain(arg, "..") != -1)
	{
		console_print(id, "Ez a pálya nem létezik, pályaváltás megállítva!")
		return;
	}

	client_print_color(0, print_team_default, "^4%s^1Admin: ^4%s^1 pályaváltás a következőre: ^4%s", CHATPREFIX, name, arg)
	AdminChangedMap = 1;
	copy(SMapName, 32, arg);

	Update_g_Products();
	Update_g_Inventory();
}
public do_chmap()
{
	if(AdminChangedMap == 1)
	{
		server_cmd("changelevel %s", SMapName)
	}
	else
	{
		new nextMap[32];
		get_cvar_string("amx_nextmap",nextMap,31)
		server_cmd("changelevel %s",nextMap);
	}
}
public TerrorsWin() {
	g_TEWins++;
}
public CTerrorsWin() {
	g_CTWins++;
}
public SetRanks()
{
	new players[32], num, i, Win, Lose, rankolas = sizeof(Rangok)
	get_players(players, num);

	if(RankSetted == 1)
		return;
	
	for(new id = 1; id < g_Maxplayers; id++)
	{
		if(!sk_get_logged(id))
			continue;

		if(g_TEWins > g_CTWins && get_user_team(id) == CS_TEAM_T) 
		{
			g_Player[id][Wins]++;

			Win = 1
			g_Player[id][eloElo] += 5*g_Player[id][PlayedCount]
			g_Player[id][eloXP] += 23.1*g_Player[id][PlayedCount]
		}
		else if(g_CTWins > g_TEWins && get_user_team(id) == CS_TEAM_CT) 
		{
			g_Player[id][Wins]++;
			
			Win = 1
			g_Player[id][eloElo] += 5*g_Player[id][PlayedCount]
			g_Player[id][eloXP] += 23.1*g_Player[id][PlayedCount]
		}
		else if(g_CTWins == g_TEWins) 
		{
			g_Player[id][Wins]++;

			Win = 1
			g_Player[id][eloElo] += 13*g_Player[id][PlayedCount]
			g_Player[id][eloXP] += 40.1*g_Player[id][PlayedCount]
		}

		if(g_TEWins < g_CTWins && get_user_team(id) == CS_TEAM_T) 
		{
			Lose = 1
			g_Player[id][eloElo] -= 6*g_Player[id][PlayedCount]
			g_Player[id][eloXP] += 10.6*g_Player[id][PlayedCount]
		}
		else if(g_CTWins < g_TEWins && get_user_team(id) == CS_TEAM_CT) 
		{
			Lose = 1
			g_Player[id][eloElo] -= 6*g_Player[id][PlayedCount]
			g_Player[id][eloXP] += 10.6*g_Player[id][PlayedCount]
		}
		if(Win)
		{
			g_Player[id][eloPoints] += g_Player[id][eloElo]
			g_Player[id][rXP] += g_Player[id][eloXP]
		}
		else if(Lose)
		{
			g_Player[id][eloPoints] -= g_Player[id][eloElo]
			g_Player[id][rXP] += g_Player[id][eloXP]

		}

		for(new y;y < rankolas; y++) 
		{
			if(g_Player[id][Wins] > 4)
			{
				if(g_Player[id][eloPoints] >= Rangok[y][ELO] && g_Player[id][eloPoints] < Rangok[y+1][ELO]) 
				{
					if(g_Player[id][Rang] >= 18)
					{
						client_print_color(id, print_team_default, "^4%s^1Elérted a maximum Rangot!", CHATPREFIX)
						g_Player[id][Rang] = 18;
					}
					else 
					{
						g_Player[id][Rang] = y+1;
					}	
				}
			}
			if(g_Player[id][rXP] >= 5000.00)		
			{
				g_Player[id][ProfilRank]++;
				g_Player[id][rXP] -= 5000.00;
			}
			if(g_Player[id][ProfilRank] > 40)
				g_Player[id][ProfilRank] = 0;
		}	
		set_dhudmessage(0, 127, 255, -1.0, 0.18, 2, 6.0, 17.0)
		show_dhudmessage(id, "PROFIL RANK:^n[ %s | %3.2f / 5000 ]^n^nSKILL FOKOZAT:^n[ %s ]^n^n%d nyert meccs.", PrivateRanks[g_Player[id][ProfilRank]][1], g_Player[id][rXP], Rangok[g_Player[id][Rang]][RangName], g_Player[id][Wins])
	}
	Update_g_Products();
	RankSetted = 1;
	set_task(20.0, "Update_g_Inventory")
}
public Spawn(id) 
{
	if(!is_user_alive(id)) 
		return PLUGIN_HANDLED;
		
	g_Player[id][BuyedWeap] = 0;
	strip_user_weapons(id);
	give_item(id, "weapon_knife");
	
	if(g_Player[id][is_Vip])
	{
		if(get_systime() >= g_Player[id][vipTime])
		{
			client_print_color(id, print_team_default, "%s^1Lejárt a ^3VIP^1-ed!", CHATPREFIX)
			g_Player[id][vipTime] = 0;
			g_Player[id][is_Vip] = 0;
			g_Player[id][SelectedTSkin] = -1;
			g_Player[id][SelectedCTSkin] = -1;
		}
	}
	if(g_Player[id][is_pVip] > 0)
	{
		if(get_systime() >= g_Player[id][pvipTime])
		{
			client_print_color(id, print_team_default, "%s^1Lejárt a ^3Prémium ^4VIP^1-ed!", CHATPREFIX)
			g_Player[id][pvipTime] = 0;
			g_Player[id][is_pVip] = 0;
			g_Player[id][SelectedTSkin] = -1;
			g_Player[id][SelectedCTSkin] = -1;
		}
	}
	fegyvermenu(id);
	SetModels(id);
	g_Player[id][PlayedCount]++
	Update_Player_Stats(id);

	return PLUGIN_HANDLED;
}
public SetModels(id)
{
	new CsTeams:iTeam = cs_get_user_team(id);
	switch(iTeam)
	{
		case CS_TEAM_T:
		{
			if(g_Player[id][SelectedTSkin] >= 0 && g_Player[id][is_pVip] > 0)
				cs_set_user_model(id, SkinModelsInfo[g_Player[id][SelectedTSkin]][pSkinName])
			else
				cs_set_user_model(id, "leet")
		}
		case CS_TEAM_CT:
		{
			if(g_Player[id][SelectedCTSkin] >= 0 && g_Player[id][is_pVip] > 0)
				cs_set_user_model(id, SkinModelsInfo[g_Player[id][SelectedCTSkin]][pSkinName])
			else
				cs_set_user_model(id, "gsg9")
		}
	}
}
public ujkor()
{
	new id, count;
	new Players[32], iNum;
	new sDateAndTime[40];

	new p_playernum = get_playersnum(1);
	format_time(sDateAndTime, charsmax(sDateAndTime), "%m.%d - %H:%M:%S", get_systime())
	
	g_korkezdes++;

	for(id = 0 ; id <= g_Maxplayers ; id++) 
	{
		if(is_user_connected(id)) 
			if(g_Player[id][AdminLvL] > 0 && g_Player[id][is_Inkodnitoed] == 0) 
				count++; 
	}

	if(Fragverseny)
	{
		Fragkorok -= 1;
		fragonroundstart();
		server_cmd("hostname ^"[~|HerBoy|~] - Dust2 | Fragverseny van @ herboy.hu^"");
	}
	client_print_color(0, print_team_default, "^4%s^3Kör: ^4%d^1/^4%d ^1| ^3Pálya: ^4%s^1 | ^3Játékosok: ^4%d^1/^4%d^1 | ^3Idő: ^4%s ^1| ^3Jelenlévő Adminok: ^4%d", CHATPREFIX, g_korkezdes, get_pcvar_num(SCvar[maxkor]), FegyoMapName, p_playernum, g_Maxplayers, sDateAndTime, count); 
	
	if(g_korkezdes >= get_pcvar_num(SCvar[maxkor]))
	{
		blockall = 1;

		SetRanks();

	}
	if(Fragkorok == 1 && Fragverseny == 1)
	{
		server_cmd("hostname ^"%s^"", ServerName);
		EndTheFrag();
		Fragverseny = 0;
	}

	gWPTE = 0;
	gWPCT = 0;
	Load_This(id, "playerstats2", "TablaAdatValasztas15_PlayerStats");
	Load_Data("__syn_payments", "QuerySelectSMS");
}
public cmdGive(id)
{
	new Arg1[32], Arg2[32], Arg3[32], Arg4[32], Arg5[32], Arg6[33], Arg7[32];
	new Inventory[InventorySystem]
	
	read_argv(1, Arg1, charsmax(Arg1));
	read_argv(2, Arg2, charsmax(Arg2));
	read_argv(3, Arg3, charsmax(Arg3));
	read_argv(4, Arg4, charsmax(Arg4));
	read_argv(5, Arg5, charsmax(Arg5));
	read_argv(6, Arg6, charsmax(Arg6));
	read_argv(7, Arg7, charsmax(Arg7));
	
	Inventory[sqlid] = -1;
	Inventory[w_userid] = str_to_num(Arg1);
	Inventory[w_id] = str_to_num(Arg2);
	Inventory[is_StatTraked] = str_to_num(Arg3);
	Inventory[StatTrakKills] = str_to_num(Arg4);
	Inventory[is_Nametaged] = str_to_num(Arg5);
	Inventory[w_tradable] = str_to_num(Arg7);
	Inventory[w_deleted] = 0;

	copy(Inventory[Nametag], 100, Arg6);
	
	new WasOnline = 0;
	for(new i = 1;i < 33;i++)
	{
		if(g_Player[i][UserId] == Inventory[w_userid])
		{
			client_print_color(i, print_team_default, "^4%s^1Sikeresen addoltak neked erről a fiókról: ^1%s(#%i)^1!",CHATPREFIX, g_Player[id][Name], g_Player[id][UserId]);
			new arryid = ArrayPushArray(g_Inventory, Inventory);
			//UpdateItem(i, 1, 1, arryid, str_to_num(Arg1), str_to_num(Arg2), str_to_num(Arg5), Arg6, str_to_num(Arg3), str_to_num(Arg4), str_to_num(Arg7), 0, -1, get_systime(), 0)
			WasOnline = 1;
			break;
		}
	}
	if(!WasOnline)
		console_print(id, "Ő nem elérhető!")
}
public teszt1(id)
{
	new Arg1[32], Arg2[32]
	read_argv(1, Arg1, charsmax(Arg1));
	read_argv(2, Arg2, charsmax(Arg2));

	AddToInv(id, str_to_num(Arg1), str_to_num(Arg2), 0, 0, 0, "", 0)
}
public manual_load_market(id)
{
	Load_Data("OfflineMarket", "QuerySelect_Market");
	LoadInventory(id)
}
public MapChangeByClient(id)
{
	Update_g_Products();
	Update_g_Inventory();
}
public debugmarket(id)
{
	Market[id][m_SelectedToPlace] = 0
}
public adddd(id)
{
	new CaseIf = sizeof(Cases);
	for(new i=0; i < CaseIf; i++)
	{
		Case[id][i] += 100;
		Key[id][i] += 100;
	}


	console_print(id, "works")

	//LoadInventory(id);
	g_Player[id][PremiumPont] += 155555;
	g_Player[id][Dollar] += 150000;
	//blockall = 1;
}
public addd(id)
{
	console_print(id, "works")
}
public NoWeapChange(iEnt)
{
	if(!pev_valid(iEnt))
	return;
	
	new id = get_pdata_cbase(iEnt, 41, 4);
	
	if(!pev_valid(id))
		return;

	g_Player[id][EquipmentedSkinArray] = -1
}
public Change_Weapon(iEnt)
{
	if(!pev_valid(iEnt))
	return;


	new id = get_pdata_cbase(iEnt, 41, 4);
	new EntWeapon;

	if(!pev_valid(id))
		return;

	new iWeapon = cs_get_weapon_id(iEnt);

	switch(iWeapon)
	{
		case CSW_AK47: EntWeapon = AK47;
		case CSW_M4A1: EntWeapon = M4A1;
		case CSW_AWP: EntWeapon = AWP;
		case CSW_DEAGLE: EntWeapon = DG;
		case CSW_KNIFE: 
		{
			EntWeapon = KNIFE;
			if(g_Player[id][is_pVip] == 2)
				set_user_maxspeed(id, 310.00)
			else
				set_user_maxspeed(id, 290.00)
		}
	}
	if(!sk_get_logged(id))
	{
		g_Player[id][EquipmentedSkin] = EquipmentedDef[EntWeapon]
		g_Player[id][EquipmentedSkinArray] = -1;
		return;
	}
	
	for(new i = 201; i < 211; i++)
	{
		if(SltGun[id][EntWeapon][0] == i)
		{
			entity_set_string(id, EV_SZ_viewmodel, FegyverInfo[SltGun[id][EntWeapon][0]][ModelName]);
			g_Player[id][EquipmentedSkin] = SltGun[id][EntWeapon][0];
			g_Player[id][EquipmentedSkinArray] = -1;
			return;
		}
	}
	
	if(g_Player[id][SkinOnOff] == 0)
	{
		entity_set_string(id, EV_SZ_viewmodel, FegyverInfo[SltGun[id][EntWeapon][0]][ModelName]);
		g_Player[id][EquipmentedSkin] = SltGun[id][EntWeapon][0]
		g_Player[id][EquipmentedSkinArray] = SltGun[id][EntWeapon][1]

	}
	else 
	{
		g_Player[id][EquipmentedSkin] = EquipmentedDef[EntWeapon]
		g_Player[id][EquipmentedSkinArray] = -1;
	}
}
public setUserMoney(id) {
	if(is_user_connected(id))
	{
		set_pdata_int(id, 115, 0) 
		message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("Money"), _, id)
		write_long(floatround(g_Player[id][Dollar]))
		write_byte(1)
		message_end()
	}
}
public DropSystem(id)
{
	new Float:RND = random_float(0.00, 10.00)

	new iChooser = random_num(1,2);
	new Float:fAllChance;

	new m_sizeof = sizeof(Cases);
	new Float:fDropChance[11];
	switch(iChooser)
	{
		case 1:
		{
			for(new i; i < m_sizeof; i++)
			{
				fDropChance[i] = Cases[i][d_rarity];
				fAllChance += Cases[i][d_rarity];
			}
		}
		case 2:
		{
			for(new i; i < m_sizeof; i++)
			{
				fDropChance[i] = Keys[i][k_rarity];
				fAllChance += Keys[i][k_rarity];
			}
		}
	}
	new Float:NoDrop = 2.00;
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
					Case[id][i]++;
					client_print_color(0, print_team_default, "^4%s^1Játékos: ^4%s^1 Talált egy: ^3%s^1-t. ^4(^1Esélye ennek: ^3%3.2f%%^4)", CHATPREFIX, g_Player[id][Name], Cases[i][d_Name], (fDropChance[i]/(fAllChance/100)));
				}
				case 2:
				{
					Key[id][i]++;
					client_print_color(0, print_team_default, "^4%s^1Játékos: ^4%s^1 Talált egy: ^3%s^1-t. ^4(^1Esélye ennek: ^3%3.2f%%^4)", CHATPREFIX, g_Player[id][Name], Keys[i][d_Name], (fDropChance[i]/(fAllChance/100)));
				}
			}
		}
		Minfloat = MaxFloat;
	}
}
public plugin_precache() {
	new fegyver = sizeof(FegyverInfo)
	new playermodels = sizeof(SkinModelsInfo)
	new musiclist = sizeof(MusicKitInfos)
	new sanksoundlist = sizeof(SankSoundsList)
	sanklist = TrieCreate()

	for(new i;i < fegyver; i++) 
		precache_model(FegyverInfo[i][ModelName])

	for(new i;i < musiclist; i++)
		precache_sound(MusicKitInfos[i][MusicLocation])

	for(new i;i < sanksoundlist; i++)
	{
		precache_sound(SankSoundsList[i][SankLocation])
		TrieSetString(sanklist, SankSoundsList[i][SankName], SankSoundsList[i][SankLocation]);
	}

	precache_model("models/PT_Shediboii/caseasd.mdl");
	precache_model("models/PT_Shediboii/caseasd.mdl");
	CHATPREFIX = Get_ServerPrefix();
	MENUPREFIX = Get_ServerNamePrefix();

	
}
public Check()
{
	if(Fragverseny == 0)
		automatikusfrag()

	new p[32],n;
	get_players(p,n,"ch");

	for(new i=0;i<n;i++)
	{
		new id = p[i];
		HudX(id);
	}
}
public eDeathMsg(){
	new Killer = read_data(1);
	new Victim = read_data(2);
	new isHS = read_data(3);
	new TempWeapon[InventorySystem], VIPHP = get_user_health(Killer);
	new Float:reMoney = random_float(0.03, 0.07)
	new Float:doXP, Float:reXP, Float:doMoney

	new eDeath = random_num(2, 13)
	new rHss = random_num(2, 20);
	new rKill = random_num(2, 15);

	if(g_Player[Killer][is_pVip] == 1)
	{
		if(isHS) 
			VIPHP += 5
		else 
			VIPHP += 2

		doXP = random_float(1.51, 3.00); 
		reXP = random_float(0.05, 0.25);
		doMoney = random_float(0.05, 0.30)
	}
	else if(g_Player[Killer][is_pVip] == 2)
	{
		if(isHS) 
			VIPHP += 7
		else 
			VIPHP += 4

		doXP = random_float(1.21, 1.51); 
		reXP = random_float(0.05, 0.32);
		doMoney = random_float(0.05, 0.41)
	}
	else
	{
		doXP = random_float(0.15, 0.99); 
		reXP = random_float(0.05, 0.16);
		doMoney = random_float(0.05, 0.13)
	}
	
	if(Killer == Victim)
	{
		g_Player[Victim][Deaths]++;
		g_Player[Victim][eloXP] -= reXP*2.5;
		g_Player[Victim][eloElo] -= eDeath*3;
		Player_Stats[Victim][wDeaths]++;
		return PLUGIN_HANDLED
	}

	if(isHS)
	{
		g_Player[Killer][Dollar] += doMoney*1.1;
		g_Player[Killer][Kills]++;
		g_Player[Killer][HS]++;
		g_Player[Killer][eloXP] += doXP*1.1;
		g_Player[Victim][eloXP] -= doXP;
		g_Player[Victim][Deaths]++;
		Player_Stats[Killer][wHSs]++;
		g_Player[Killer][eloElo] += rHss;
		fm_set_user_frags(Killer, get_user_frags(Killer)+1);
	}
	else
	{
		g_Player[Killer][Dollar] += doMoney;
		g_Player[Killer][Kills]++;
		g_Player[Killer][eloXP] += doXP;
		g_Player[Victim][eloXP] -= doXP;
		g_Player[Victim][Deaths]++;
		g_Player[Killer][eloElo] += rKill;
	}
	Player_Stats[Victim][wDeaths]++;
	Player_Stats[Killer][wKills]++;
	g_Player[Killer][MVPPoints]++;
	g_Player[Killer][NyeremenyKills]++
	g_Player[Victim][eloElo] -= eDeath
	
	if(Fragverseny)
		g_Player[Killer][FragKills]++;

	if(g_Player[Victim][Dollar] > 10.00)
		g_Player[Victim][Dollar] -= reMoney;

	if(g_Player[Killer][is_pVip] == 2)
	{
		new Float:ppFloat = random_float(0.55, 115.55)
		if(ppFloat < 2.00)
			g_Player[Killer][PremiumPont]++;
	}

	if(g_Player[Killer][EquipmentedSkinArray] > 0)
	{
		ArrayGetArray(g_Inventory, g_Player[Killer][EquipmentedSkinArray], TempWeapon);

		if(TempWeapon[is_StatTraked])
		{
			TempWeapon[StatTrakKills]++;
			TempWeapon[Changed] = 1;
			ArraySetArray(g_Inventory, g_Player[Killer][EquipmentedSkinArray], TempWeapon);
			//UpdateItem(Killer, 1, 3, g_Player[Killer][EquipmentedSkinArray], g_Player[Killer][UserId], TempWeapon[w_id], TempWeapon[is_Nametaged], TempWeapon[Nametag], TempWeapon[is_StatTraked], TempWeapon[StatTrakKills], TempWeapon[w_tradable], TempWeapon[w_equipped], TempWeapon[sqlid], TempWeapon[w_systime], TempWeapon[w_deleted])
		}
	}
	
	client_print_color(Victim, print_team_default, "^4%s^1Megölt téged: ^3%s^1 maradt ^3%i^4HP-^1ja!", CHATPREFIX, g_Player[Killer][Name], get_user_health(Killer));

	new esely = random_num(1,300)
	{
		if(esely >= 270) 
		{
			dropdobas()
		}
		if(esely <= 10)
		{
			//hpDobas()
		}
	}
	if(g_Player[Killer][is_pVip] > 0)
	{
		set_user_health(Killer, VIPHP)
		message_begin(MSG_ONE, get_user_msgid("ScreenFade"), {0,0,0}, Killer)
		write_short(1<<10)
		write_short(1<<10)
		write_short(0x0000)
		write_byte(0)
		write_byte(0)
		write_byte(200)
		write_byte(75)
		message_end()
	}
	if(!sk_get_logged(Killer))
		return;
		
	DropSystem(Killer);
	return;
}
public hpDobas()
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
	set_pev(ent, pev_classname, "medkit")
	entity_set_model(ent, "models/PT_Shediboii/medkit.mdl")
	dllfunc( DLLFunc_Spawn, ent );
	set_pev( ent, pev_solid, SOLID_BBOX );
	set_pev( ent, pev_movetype, MOVETYPE_NONE );
	engfunc( EngFunc_SetSize, ent, Float:{ -23.160000, -13.660000, -0.050000 }, Float:{ 11.470000, 12.780000, 6.720000 } );
	engfunc( EngFunc_DropToFloor, ent );

	return PLUGIN_HANDLED;
}
public ForwardMedkitTouch( ent, id )
{
	if(pev_valid(ent))
	{
		new classname[ 32 ];
		pev( ent, pev_classname, classname, charsmax( classname ) );
		
		if( !equal( classname, "medkit") )
			return FMRES_IGNORED;
		
		if(entity_get_float(ent, EV_FL_nextthink) > get_gametime())
			return FMRES_IGNORED;
		entity_set_float(ent, EV_FL_nextthink, get_gametime() + 1.0);

		new szName[32];
		get_user_name(id, szName, charsmax(szName));

		new hpd = get_user_health(id)

		if(hpd > 70)
		{
			client_print_color(id, print_team_default, "^4%s^1Ezt az életcsomagot nem tudod felvenni, mivel a HP-d több mint^4 70!", CHATPREFIX)
			return FMRES_IGNORED;
		}

		set_user_health(id, 100)
		client_print_color(0, print_team_default, "^4%s^1Játékos: ^4%s^1 felvett egy ^3életcsomagot^1, ezért^4 100HP^1-ja lett!", CHATPREFIX, szName)
		message_begin(MSG_ONE, get_user_msgid("ScreenFade"), {0,0,0}, id)
		write_short(1<<10)
		write_short(1<<10)
		write_short(0x0000)
		write_byte(0)
		write_byte(200)
		write_byte(0)
		write_byte(75)
		message_end()

		engfunc( EngFunc_RemoveEntity, ent );
	}
	return FMRES_IGNORED;
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
	entity_set_model(ent, "models/PT_Shediboii/caseasd.mdl")
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

		TalalLada(id)

		engfunc( EngFunc_RemoveEntity, ent );
	}
	return FMRES_IGNORED;
}
public TalalLada(id)
{
	new szName[32];
	get_user_name(id, szName, charsmax(szName));

	switch(random_num(1, 6))
	{
		case 1: 
		{
			new Float:dollardrop = random_float(1.01, 2.20);
			g_Player[id][Dollar] += dollardrop;
			client_print_color(0, print_team_default, "^4%s^1Játékos: ^4%s^1 felvett egy ^3ládát^1, és talált benne ^4%3.2f^1 dollárt.", CHATPREFIX, szName, dollardrop);
		}
		case 2: 
		{
			new lada = random_num(0, 5);
			Case[id][lada]++;
			client_print_color(0, print_team_default, "^4%s^1Játékos: ^4%s^1 felvett egy ^3ládát^1, és talált benne ^4%s^1 ládát.", CHATPREFIX, szName, Cases[lada][d_Name]);
		}
		case 3: 
		{
			new lada = random_num(0, 5);
			Key[id][lada]++;
			client_print_color(0, print_team_default, "^4%s^1Játékos: ^4%s^1 felvett egy ^3ládát^1, és talált benne ^4%s^1 ládakulcsot.", CHATPREFIX, szName, Keys[lada][d_Name]);
		}
		case 4: 
		{
			new esely = random_num(1,110)
			new fegyo = random_num (5, 137)
			{
				if(esely >= 80) 
				{
					client_cmd(0,"spk ambience/thunder_clap");
					AddToInv(id, g_Player[id][UserId], fegyo, 0, 0, 0, "", 1)
					client_print_color(0, print_team_default, "^4%s^1Játékos: ^4%s^1 felvett egy ^3ládát^1, és talált benne ^4%s^1 fegyvert.", CHATPREFIX, szName, FegyverInfo[fegyo][GunName]);
				}
				else client_print_color(0, print_team_default, "^4%s^1Játékos: ^4%s^1 felvett egy ^3ládát^1, és ^3MAJDNEM^1 talált benne, egy ^4%s^1 fegyvert", CHATPREFIX, g_Player[id][Name]);
			}
		}
		case 5:
		{
			new esely = random_num(1,100)
			{
				if(esely >= 97) 
				{
					client_print_color(0, print_team_default, "^4%s^1Játékos: ^4%s^1 felvett egy ^3ládát^1, és talált benne egy ^3StatTrak* Tool^1-t! (^3Esélye ennek:^4 3.00%s^1)", CHATPREFIX, szName, "%");
					g_Player[id][StatTrakTool]++;				
					client_cmd(0,"spk ambience/thunder_clap");
				}
				if(esely <= 3)
				{
					g_Player[id][NametagTool]++;
					client_cmd(0,"spk ambience/thunder_clap");
					client_print_color(0, print_team_default, "^4%s^1Játékos: ^4%s^1 felvett egy ^3ládát^1, és talált benne egy ^3Névcédulá^1-t! (^3Esélye ennek:^4 4.00%s^3)", CHATPREFIX, szName, "%");
				}
				else
				{
					client_print_color(0, print_team_default, "^4%s^1Játékos: ^4%s^1 felvett egy ^3ládát^1, és ^3MAJDNEM^1 talált benne, ^3Névcédulát,^1 vagy ^3StatTrak* Toolt!", CHATPREFIX, g_Player[id][Name]);
				}
			}		
		}
		case 6: 
		{
			new esely = random_num(1,110)
			new kes = random_num (138, 183)
			{
				if(esely >= 109) 
				{
					client_print_color(0, print_team_default, "^4%s^1Játékos: ^4%s^1 felvett egy ^3ládát^1, és talált benne egy ^3%s^4! (^3Esélye ennek:^4 2.00%s^1)", CHATPREFIX, szName, FegyverInfo[kes][GunName], "%");
					AddToInv(id, g_Player[id][UserId], kes, 0, 0, 0, "", 1)
					client_cmd(0,"spk ambience/thunder_clap");
				}
				else
				{
					client_print_color(0, print_team_default, "^4%s^1Játékos: ^4%s^1 felvett egy ^3ládát^1, és ^3MAJDNEM^1 talált benne, ^3%s^4!^1 Te igazi szerencsétlen :(", CHATPREFIX, szName, FegyverInfo[kes][GunName]);
				}
			}
		}
	}

}
public openMainMenu(id)
{
	new Menu[512], MenuString[128], MenuKey
	format(MenuString, 127, "\d%s \wFőmenü^n^n", MENUPREFIX)
	add(Menu, 511, MenuString);
	
	format(MenuString, 127, fmt("\r1. \wRaktár \r/\w Felszerelések^n"))
	add(Menu, 511, MenuString);
	if(blockall)
		format(MenuString, 127, fmt("\d2. \dLáda Nyitás^n"))
	else
		format(MenuString, 127, fmt("\r2. \wLáda Nyitás^n"))
	add(Menu, 511, MenuString);
	if(blockall)
		format(MenuString, 127, fmt("\d3. \dPiac \d// Csereközpont^n"))
	else
		format(MenuString, 127, fmt("\r3. \wPiac \r/\w Csereközpont^n"))
	add(Menu, 511, MenuString);
	format(MenuString, 127, fmt("\r4. \wBeállítások \r/\w Profil Információk^n"))
	add(Menu, 511, MenuString);
	format(MenuString, 127, fmt("\r5. \wÁruház^n"))
	add(Menu, 511, MenuString);
	format(MenuString, 127, fmt("\r6. \wPrémium Menü^n"))
	add(Menu, 511, MenuString);
	format(MenuString, 127, fmt("\r7. \yVIP\w Menü^n"))
	add(Menu, 511, MenuString);
	format(MenuString, 127, fmt("\r8. \wSzerencsejáték^n"))
	add(Menu, 511, MenuString);
	format(MenuString, 127, fmt("\r9. \wKüldetések \r/\w Teljesítmények^n^n\r0. \wKilépés a menüből."))
	add(Menu, 511, MenuString);
	
	MenuKey = (1<<0 | 1<<1 | 1<<2 | 1<<3 | 1<<4 | 1<<5 | 1<<6 | 1<<7 | 1<<8 | 1<<9);
	show_menu(id, MenuKey, Menu, -1, "MAINMENU");
	return PLUGIN_CONTINUE
}
public hMainMenu(id, MenuKey)
{
	MenuKey++;
	switch(MenuKey)
	{
		case 1: openInventorySwitch(id);
		case 2: 
		{
			if(blockall == 0) 
				openCaseSwitch(id);
			else
				client_print_color(id, print_team_default, "^4%s^1Amíg a ^3szerver^1 a ^3raktárakat^1 menti, addig nem lehet megnyitni a ^3ládanyitás^1-t, adatvesztés biztonsága érdekében!", CHATPREFIX)
		}
		case 3: 
		{
			if(blockall == 0) 
				openMarketMenu(id);
			else
				client_print_color(id, print_team_default, "^4%s^1Amíg a ^3szerver^1 a ^3raktárakat^1 menti, addig nem lehet megnyitni a ^3piac^1-ot, adatvesztés biztonsága érdekében!", CHATPREFIX)
		}
		case 4: openSettings(id);
		case 5: openAruhazMenu(id);
		case 6: m_PremiumBolt(id);
		case 7: VIPFelulet(id);
		case 8:
		{
			Szerencsemenu(id);
		}
		default:{
			show_menu(id, 0, "^n", 1);
			return
		}
	}
}
public Szerencsemenu(id)
{
	new iras[121], String[121], itemNum, sztime[40];
	format(iras, charsmax(iras), "\y%s^nSzerencsejáték", MENUPREFIX);
	new menu = menu_create(iras, "Szerencsejatek_H");
	static iTime;
	iTime = g_Player[id][PorgetTime]-get_systime();

	menu_additem(menu, fmt("\yTippKulcs"), "1", 0)
	menu_additem(menu, fmt("\ySkin\r Gambling \d/Hamarosan"), "1", 0)
	menu_additem(menu, fmt("\yItem\r Gambling \d/Hamarosan"), "4", 0)
	menu_additem(menu, fmt("\rRoulette \d/Hamarosan"), "2", 0)

	if(iTime <= 0)
	{
		if(g_Player[id][is_Vip])
		menu_additem(menu, fmt("\yNapi \wpörgetés\r [\y2\wDB\r]\y*VIP"), "3", 0)
		else
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
	iTime = g_Player[id][PorgetTime]-get_systime();

	switch(key)
	{
		case 1: TippKeyMenu(id);
		case 3:
		{
			if(iTime <= 0)
			{
				sorsolas(id);
			}
			else
				client_print_color(id, print_team_default, "^4%s^1Nincs egyetlen egy pörgetésed sem! ^3:(", CHATPREFIX);
		}
	}
	
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public sorsolas(id)
{
	switch(random_num(1,5))
	{
		case 1:
		{
			new kulcsporgetes = random_num(1,6);
			new kulcsszam = random(6);
			Key[id][kulcsszam] += kulcsporgetes;
			client_print_color(id, print_team_default, "^4%s^1Pörgettél ^4%i^1 db ^3%s^1 kulcsot!", CHATPREFIX, kulcsporgetes, Keys[kulcsszam][d_Name])
		}
		case 2:
		{
			client_print_color(id, print_team_default, "^4%s^3Ez nem a te napod! :(", CHATPREFIX) 
		}
		case 3:
		{
			new Float:randomDollar = random_float(5.00, 25.10)
			client_print_color(id, print_team_default, "^4%s^3Gratula! ^1Pörgettél ^4%3.2f^1 dollárt!", CHATPREFIX, randomDollar)
			g_Player[id][Dollar] += randomDollar;
		}
		case 4:
		{
			client_print_color(id, print_team_default, "^4%s^3Ez nem a te napod! :(", CHATPREFIX)
		}
		case 5:
		{
			new ladaporgetes = random_num(1,6);
			new ladaszam = random(6);
			Case[id][ladaszam] += ladaporgetes;
			client_print_color(id, print_team_default, "^4%s^1Pörgettél ^4%i^1 db ^3%s^1 ládát!", CHATPREFIX, ladaporgetes, Cases[ladaszam][d_Name])
		}
	}
	g_Player[id][VipPorgetes]++
	if(g_Player[id][is_Vip] == 1 && g_Player[id][VipPorgetes] <= 1)
		Szerencsemenu(id)
	else
		g_Player[id][PorgetTime] = get_systime() + 86400;
}
public VIPFelulet(id)
{
	new iras[121], String[121], itemNum, sztime[40];
	format(iras, charsmax(iras), "\y%s^nVIP Felület", MENUPREFIX);
	new menu = menu_create(iras, "VIPFelulet_h");


	if(g_Player[id][is_Vip] || g_Player[id][is_pVip])
	{
		menu_additem(menu, fmt("\yIndirect\w csomag \r[\yFelszerelés\r]"), "1", 0)
		menu_additem(menu, fmt("\yTaktik\w csomag \r[\yFelszerelés\r]"), "2", 0)	
	}
	else
	{
		menu_additem(menu, "\yIndirect\w csomag \r[\dVIP szükséges\r]", "0", 0)
		menu_additem(menu, "\yTaktik\w csomag \r[\dVIP szükséges\r]", "0", 0)
	}
	
	menu_display(id, menu, 0);
}
public openZenekeszlet(id)
{
	new szMenu[256]
	formatex(szMenu, charsmax(szMenu), "%s^nZenekészlet Raktár", MENUPREFIX)
	new menu = menu_create(szMenu, "Zenekeszlet_h");
	new musiclist = sizeof(MusicKitInfos)

	for(new i;i < musiclist; i++)
	{
		if(mvpr_kit[id][i] >= 1)
		{
			new Sor[6]; num_to_str(i, Sor, 5);
			formatex(szMenu, charsmax(szMenu), "%s \r[\w%i\y DB\r]", MusicKitInfos[i][MusicKitName], mvpr_kit[id][i]);
			menu_additem(menu, szMenu, Sor);
		}
	}

	menu_display(id, menu, 0);
}
public Zenekeszlet_h(id, menu, item) {
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED
	}

	new data[9], szName[64]
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName, charsmax(szName), callback);
	new key = str_to_num(data);
	
	if(mvpr_kit[id][key]> 0)
		g_Player[id][SelectedMusicKit] = key

	if(mvpr_kit[id][key] > 0)
			client_print_color(id, print_team_default, "^4%s^1Kivalásztottad a(z) ^3%s^1 zenekészletet.", CHATPREFIX, MusicKitInfos[key][MusicKitName])	
	else
		client_print_color(id, print_team_default, "^4%s^1Nincsen meg a választott zenekészleted! Vásárolj egyet az áruházba!", CHATPREFIX)
	
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public m_Zenekeszlet(id)
{
	new String[1026];
	formatex(String, charsmax(String), "%s \r- \dZenekészlet Áruház^n\yDollár: \d%3.2f", MENUPREFIX, g_Player[id][Dollar]);
	new menu = menu_create(String, "m_Zenekeszlet_h");
	new musiclist = sizeof(MusicKitInfos)

	for(new i;i < musiclist; i++)
	{
		new Sor[6]; num_to_str(i, Sor, 5);
		formatex(String, charsmax(String), "\w%s \r|\w Ár:\r %3.2f\y$", MusicKitInfos[i][MusicKitName], MusicKitInfos[i][MusicKitPound_D]);
		menu_additem(menu, String, Sor);
	}

	menu_setprop(menu, MPROP_PERPAGE, 6);
	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}
public m_Zenekeszlet_h(id, menu, item)
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

	if(g_Player[id][Dollar] >= MusicKitInfos[key][MusicKitPound_D])
	{
		client_print_color(0, print_team_default, "%s^1Játékos: ^4%s^1 megvásárolta a ^3%s^1 zenekészletet!", CHATPREFIX, g_Player[id][Name], MusicKitInfos[key][MusicKitName]);
		g_Player[id][Dollar] -= MusicKitInfos[key][MusicKitPound_D]
		mvpr_kit[id][key]++;
	}
	else
	{
		client_print_color(id, print_team_default, "%s ^1Nincs elég egyenleged!", CHATPREFIX);
	}
}
public VIPFelulet_h(id, menu, item)
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
		case 0: VIPFelulet(id);
		case 1:
		{
			SltGun[id][AK47][0] = 206
			SltGun[id][M4A1][0] = 207
			SltGun[id][AWP][0] = 208
			SltGun[id][DG][0] = 209
			SltGun[id][KNIFE][0] = 210
			client_print_color(id, print_team_default, "^4%s^1 Te felszerelted a ^3Indirect^1 fegyvercsomagot!", CHATPREFIX)
		}
		case 2:
		{
			SltGun[id][AK47][0] = 201
			SltGun[id][M4A1][0] = 202
			SltGun[id][AWP][0] = 203
			SltGun[id][DG][0] = 204
			SltGun[id][KNIFE][0] = 205
			client_print_color(id, print_team_default, "^4%s^1 Te felszerelted a ^3Taktik^1 fegyvercsomagot!", CHATPREFIX)
		}
	}
	
}
public openMarketMenu(id)
{
	new Menu[512], MenuString[128], MenuKey
	format(MenuString, 127, "\d%s \wPiac \r/\w Csereközpont^n^n", MENUPREFIX)
	add(Menu, 511, MenuString);
	
	format(MenuString, 127, fmt("\r1. \wEladás^n"))
	add(Menu, 511, MenuString);
	format(MenuString, 127, fmt("\r2. \wVásárlás^n"))
	add(Menu, 511, MenuString);
	format(MenuString, 127, fmt("\r3. \ySkin \wküldés^n"))
	add(Menu, 511, MenuString);
	format(MenuString, 127, fmt("\r4. \yLáda \wküldés^n"))
	add(Menu, 511, MenuString);
	format(MenuString, 127, fmt("\r5. \yKulcs \wküldés^n"))
	add(Menu, 511, MenuString);
	format(MenuString, 127, fmt("\r6. \yDollár \wküldés \r[\y%3.2f\w$\r]^n", g_Player[id][Dollar]))
	add(Menu, 511, MenuString);
	format(MenuString, 127, fmt("\r7. \yNévcédula \wküldés \r[\y%i\w DB\r]^n", g_Player[id][NametagTool]))
	add(Menu, 511, MenuString);
	format(MenuString, 127, fmt("\r8. \yStatTrak* Tool \wküldés \r[\y%i\w DB\r]^n", g_Player[id][StatTrakTool]))
	add(Menu, 511, MenuString);
	
	MenuKey = (1<<0 | 1<<1 | 1<<2 | 1<<3 | 1<<4 | 1<<5 | 1<<6 | 1<<7 | 1<<8 | 1<<9);
	show_menu(id, MenuKey, Menu, -1, "KULDESMENU");
	return PLUGIN_CONTINUE
}

public openMarketSwitch_h(id, MenuKey)
{
	MenuKey++;
	switch(MenuKey)
	{
		case 1: MarketMenu(id);	
		case 2: openBuyer1(id);
		case 3: 
		{
			g_Player[id][SendType] = 3
			openPlayerChooser(id);
		} 
		case 4: 
		{
			g_Player[id][SendType] = 4
			openSelector(id, 1);
		}
		case 5: 
		{
			g_Player[id][SendType] = 5
			openSelector(id, 2);
		}
		case 6:
		{
			g_Player[id][SendType] = 6
			openPlayerChooser(id);
		}
		case 7:
		{
			g_Player[id][SendType] = 7
			openPlayerChooser(id);
		}
		case 8:
		{
			g_Player[id][SendType] = 8
			openPlayerChooser(id);
		}
		default:{
			show_menu(id, 0, "^n", 1);
			return
		}
	}
}
public openSelector(id, MenuValasztott)
{
	new String[121];
	format(String, charsmax(String), "%s ^nLáda / Kulcs küldés", MENUPREFIX);
	new menu = menu_create(String, "openSelector_h");
	new ladasos = sizeof(Cases);

	switch(MenuValasztott)
	{
		case 1: 
		{
			for(new i;i < ladasos; i++)
			{
				new Sor[6]; num_to_str(i, Sor, 5);
				formatex(String, charsmax(String), "%s \r[\w%i\y DB\r]", Cases[i][d_Name], Case[id][i]);
				menu_additem(menu, String, Sor);
			}
		}
		case 2:
		{
			for(new i;i < ladasos; i++)
			{
				new Sor[6]; num_to_str(i, Sor, 5);
				formatex(String, charsmax(String), "%s \r[\w%i\y DB\r]", Keys[i][d_Name], Key[id][i]);
				menu_additem(menu, String, Sor);
			}
		}
	}	

	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}
public openSelector_h(id, menu, item)
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

	g_Player[id][CaseOrKeySelected] = key;
	openPlayerChooser(id);

}
public openPlayerChooser(id) {
	new szMenu[121], players[32], pnum, iName[32], szTempid[10]
	get_players(players, pnum)

	formatex(szMenu, charsmax(szMenu), "\r%s^n\wVálassz ki egy játékost!", MENUPREFIX)
	new menu = menu_create(szMenu, "hPlayerChooser");

	for(new i; i<pnum; i++)
	{
		get_user_name(players[i], iName, charsmax(iName))
		num_to_str(players[i], szTempid, charsmax(szTempid))
		menu_additem(menu, iName, szTempid)
	}
	menu_display(id, menu, 0)
	console_print(0, "chooseoff")
}
public hPlayerChooser(id, menu, item)
{
	if(item == MENU_EXIT) {
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	new data[6], szName[64], access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
	g_Player[id][SendTemp] = str_to_num(data);
	client_print_color(0, print_team_default, "%i -- %i", g_Player[id][SendTemp], str_to_num(data))
	
	if(id == g_Player[id][SendTemp]) {
		client_print_color(id, print_team_default, "^4%s^1Magadnak nem küldhetsz semmit!", CHATPREFIX)
		menu_destroy(menu);
		return PLUGIN_HANDLED
	}
	switch(g_Player[id][SendType])
	{
		case 3:
		{
			g_Player[id][openSelectItemRow] = 3;
			openMarketSwitch(id);
		}
		case 4..8:
		{
			client_cmd(id, "messagemode Kuldes_Mennyisege")
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public openInventorySwitch(id)
{
	new Menu[512], MenuString[128], MenuKey
	format(MenuString, 127, "%s \wRaktár \r/\w Felszerelések^n^n", MENUPREFIX);
	add(Menu, 511, MenuString);
	
	format(MenuString, 127, fmt("\r1. \wAK47 \rSkinek^n"))
	add(Menu, 511, MenuString);
	format(MenuString, 127, fmt("\r2. \wM4A1 \rSkinek^n"))
	add(Menu, 511, MenuString);
	format(MenuString, 127, fmt("\r3. \wAWP \rSkinek^n"))
	add(Menu, 511, MenuString);
	format(MenuString, 127, fmt("\r4. \wDEAGLE \rSkinek^n"))
	add(Menu, 511, MenuString);
	format(MenuString, 127, fmt("\r5. \wKÉS \rSkinek^n"))
	add(Menu, 511, MenuString);
	format(MenuString, 127, fmt("\r6. \wJátékos \rSkinek^n^n"))
	add(Menu, 511, MenuString);
	format(MenuString, 127, fmt("\r7. \wKuka^n"))
	add(Menu, 511, MenuString);

	if(blockall)
		format(MenuString, 127, fmt("\d8. \dStatTrak*\d//Névcédula \dfelhelyezés^n"))
	else
		format(MenuString, 127, fmt("\r8. \wStatTrak*\r/\wNévcédula \rfelhelyezés^n"))
	add(Menu, 511, MenuString);

	format(MenuString, 127, fmt("\r9. \wZenekészleteim^n^n\r0. \wKilépés a menüből"))
	add(Menu, 511, MenuString);
	
	MenuKey = (1<<0 | 1<<1 | 1<<2 | 1<<3 | 1<<4 | 1<<5 | 1<<6 | 1<<7 | 1<<8 | 1<<9);
	show_menu(id, MenuKey, Menu, -1, "RAKTARMENU");
	return PLUGIN_CONTINUE
}
public hRaktarMenu(id, MenuKey)
{
	MenuKey++;
	switch(MenuKey)
	{
		case 1: openInventory(id, CSW_AK47)
		case 2: openInventory(id, CSW_M4A1)
		case 3: openInventory(id, CSW_AWP)
		case 4: openInventory(id, CSW_DEAGLE)
		case 5: openInventory(id, CSW_KNIFE)
		case 6: openPlayerSkin(id);
		case 7: Kuka_Menu(id)
		case 8:
		{
			if(blockall == 0) 
				openToolsMenu(id);
			else
				client_print_color(id, print_team_default, "^4%s^1Amíg a ^3szerver^1 a ^3raktárakat^1 menti, addig nem lehet megnyitni ezt a menüt, adatvesztés biztonsága érdekében!", CHATPREFIX)
		}
		case 9: openZenekeszlet(id)
		default:{
			show_menu(id, 0, "^n", 1);
			return
		}
	}
}
//--------- KUKA KEZDETE
public openInventorySelectForDelete(id)
{
	new Menu[512], MenuString[128], MenuKey
	format(MenuString, 127, "%s \wRaktár \r/\w Törlés^n^n", MENUPREFIX);
	add(Menu, 511, MenuString);
	
	format(MenuString, 127, fmt("\r1. \wAK47 \rSkinek^n"))
	add(Menu, 511, MenuString);
	format(MenuString, 127, fmt("\r2. \wM4A1 \rSkinek^n"))
	add(Menu, 511, MenuString);
	format(MenuString, 127, fmt("\r3. \wAWP \rSkinek^n"))
	add(Menu, 511, MenuString);
	format(MenuString, 127, fmt("\r4. \wDEAGLE \rSkinek^n"))
	add(Menu, 511, MenuString);
	format(MenuString, 127, fmt("\r5. \wKÉS \rSkinek^n^n"))
	add(Menu, 511, MenuString);
	
	MenuKey = (1<<0 | 1<<1 | 1<<2 | 1<<3 | 1<<4 | 1<<5 | 1<<6 | 1<<7 | 1<<8 | 1<<9);
	show_menu(id, MenuKey, Menu, -1, "KUKASWITCH");
	return PLUGIN_CONTINUE
}
public KukaSwitchHandler(id, MenuKey)
{
	MenuKey++;
	switch(MenuKey)
	{
		case 1: openInventoryKuka(id, CSW_AK47)
		case 2: openInventoryKuka(id, CSW_M4A1)
		case 3: openInventoryKuka(id, CSW_AWP)
		case 4: openInventoryKuka(id, CSW_DEAGLE)
		case 5: openInventoryKuka(id, CSW_KNIFE)
		default:{
			show_menu(id, 0, "^n", 1);
			return
		}
	}
}

public openInventoryKuka(id, WEAPENT)
{
	new szMenu[256],String[6]
	formatex(szMenu, charsmax(szMenu), "%s Kuka", MENUPREFIX)
	new menu = menu_create(szMenu, "KukaArryHandler");

	new InventorySizeof = ArraySize(g_Inventory);
	new Inventory[InventorySystem];

	for(new i = 0; i < InventorySizeof;i++)
	{
		new len;
		ArrayGetArray(g_Inventory, i, Inventory);

		if(Inventory[w_userid] != g_Player[id][UserId])
			continue;

		if(FegyverInfo[Inventory[w_id]][EntName][0] == WEAPENT && Inventory[w_deleted] == 0 && Inventory[w_tradable] == 1 && Inventory[w_equipped] == 0)
		{
			if(Inventory[w_equipped])
				len += formatex(szMenu[len], charsmax(szMenu) - len, "\r!\d - ");

			if(Inventory[is_StatTraked])
				len += formatex(szMenu[len], charsmax(szMenu) - len, "\yStatTrak\r* \d- ");

			if(Inventory[is_Nametaged])
				len += formatex(szMenu[len], charsmax(szMenu) - len, "%s%s", FegyverInfo[Inventory[w_id]][Rarity], Inventory[Nametag]);
			else
				len += formatex(szMenu[len], charsmax(szMenu) - len, "%s%s", FegyverInfo[Inventory[w_id]][Rarity], FegyverInfo[Inventory[w_id]][GunName]);

			num_to_str(i, String, 5);
			menu_additem(menu, szMenu, String);
		}
	}

	menu_display(id, menu, 0);
}

public KukaArryHandler(id, menu, item) 
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED
	}

	new data[9], szName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName, charsmax(szName), callback);
	new key = str_to_num(data);

	new Inventory[InventorySystem]

	ArrayGetArray(g_Inventory, key, Inventory)

	if(blockall == 0)
	{
		g_Player[id][SelectedForDelete] = key;
		g_Player[id][DeletType] = 0;
		client_print_color(id, print_team_default, "^4%s^1Kiválasztottad TÖRLÉSRE a(z) ^3%s ^1fegyvert!", CHATPREFIX, FegyverInfo[Inventory[w_id]][GunName])
	}
	else 
		client_print_color(id, print_team_default, "^4%s^1Amíg a ^3szerver^1 a ^3raktárakat^1 menti, addig nem tudod kiválasztani a(z) ^3%s^1 fegyvert!", CHATPREFIX, FegyverInfo[Inventory[w_id]][GunName])

	menu_destroy(menu);
	Kuka_Menu(id);
	return PLUGIN_HANDLED;
}

public Kuka_Menu(id)
{
	new iras[121], String[121], Item[InventorySystem], itemNum;
	format(iras, charsmax(iras), "\y%s^nKuka", MENUPREFIX);
	new menu = menu_create(iras, "Kuka_h");

	new _SelectedForDelete = g_Player[id][SelectedForDelete];
	if(_SelectedForDelete == -1)
	{
		menu_additem(menu, "\wKiválasztott fegyver:\d Nincs", "1", 0);
	}
	else
	{
		ArrayGetArray(g_Inventory, _SelectedForDelete, Item);
		formatex(String, charsmax(String), "\wKiválasztott fegyver:\r %s", FegyverInfo[Item[w_id]][GunName]);
		menu_additem(menu, String, "1", 0);
	}
	switch(g_Player[id][DeletType])
	{
		case 0: menu_additem(menu, "\wTörlési mód: \rEgy fegyver", "2", 0);
		case 1: menu_additem(menu, "\wTörlési mód: \rHasonló", "2", 0);
		case 2: menu_additem(menu, "\wTörlési mód: \rÖsszes ilyen", "2", 0);
	}
	menu_addblank2(menu);
	switch(g_Player[id][DeletType])
	{
		case 0: menu_addtext2(menu, "\r*\w Csak a kiválasztott fegyver törlödik!\r*");
		case 1: menu_addtext2(menu, "\r*\w Összes ilyen fegyver amin nincs \rStatTrak* \wvagy\y Névcédula\r*");
		case 2: menu_addtext2(menu, fmt("\r*\w Minden ilyen (%s%s\w) kinézetű fegyvert töröl!\r*", FegyverInfo[Item[w_id]][Rarity], FegyverInfo[Item[w_id]][GunName]));
	}
	menu_addblank2(menu);
	if(_SelectedForDelete == -1)
		menu_additem(menu, "\dTÖRLÉS", "3", 0);
	else
		menu_additem(menu, "\rTÖRLÉS", "3", 0);

	menu_setprop(menu, MPROP_EXITNAME, "Vissza");

	menu_display(id, menu, 0);
}

public Kuka_h(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}

	new data[9], szName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName, charsmax(szName), callback);
	new key = str_to_num(data);

	switch(key)
	{
		case 1:
		{
			openInventorySelectForDelete(id);
		}
		case 2:
		{
			g_Player[id][DeletType]++;
			if(g_Player[id][DeletType] > 2)
				g_Player[id][DeletType] = 0;

			Kuka_Menu(id);
		}
		case 3:
		{
			if(g_Player[id][SelectedForDelete] != -1)
				BeginDelete(id);
			else
				client_print_color(id, print_team_default, "^4%s^1Előbb válassz ki egy fegyvert!", CHATPREFIX)
		}
	}
}
public BeginDelete(id)
{
	new _SelectedForDelete = g_Player[id][SelectedForDelete];

	switch(g_Player[id][DeletType])
	{
		case 0:	DeleteWeapon(id, _SelectedForDelete);
		case 1:
		{
			new Item[InventorySystem];
			ArrayGetArray(g_Inventory, _SelectedForDelete, Item);
			
			new InventorySizeof = ArraySize(g_Inventory);
			new TempItem[InventorySystem];
			for(new i = 0; i < InventorySizeof;i++)
			{
				ArrayGetArray(g_Inventory, i, TempItem);
				if(TempItem[w_id] != Item[w_id] || TempItem[is_Nametaged] || TempItem[is_StatTraked])
					continue;
				
				DeleteWeapon(id, i);
			}
		}
		case 2:
		{
			new Item[InventorySystem];
			ArrayGetArray(g_Inventory, _SelectedForDelete, Item);
			
			new InventorySizeof = ArraySize(g_Inventory);
			new TempItem[InventorySystem];
			for(new i = 0; i < InventorySizeof;i++)
			{
				ArrayGetArray(g_Inventory, i, TempItem);
				if(TempItem[w_id] != Item[w_id])
					continue;
				
				DeleteWeapon(id, i);
			}
		}
		case 3:	DeleteWeapon(id, _SelectedForDelete);
	}
}

public DeleteWeapon(id, ArrayIndex)
{
	new Item[InventorySystem]
	ArrayGetArray(g_Inventory, ArrayIndex, Item);
	if(!Item[w_deleted] && Item[w_userid] == g_Player[id][UserId])
	{
		new Float:randomDollar = random_float(0.01, 0.13)
		g_Player[id][Dollar] += randomDollar
		Item[w_deleted] = 1;
		client_print_color(id, print_team_default, "^4%s^1Sikeresen törölted ^4%s^1 fegyvert, kaptál ^4%3.2f^1 dollárt.", CHATPREFIX, FegyverInfo[Item[w_id]][GunName], randomDollar)
		ArraySetArray(g_Inventory, ArrayIndex, Item);
		//UpdateItem(id, 1, 6, ArrayIndex, g_Player[id][UserId], Item[w_id], Item[is_Nametaged], Item[Nametag], Item[is_StatTraked], Item[StatTrakKills], Item[w_tradable], Item[w_equipped], Item[sqlid], Item[w_systime], Item[w_deleted])
		
		g_Player[id][SelectedForDelete] = -1;
	}
	else
		return false;
	return true;
}
// ------------ KUKA VÉGE
public openToolsMenu(id)
{
	new cim[256], Inventory[InventorySystem];
	format(cim, charsmax(cim), "%s \wStatTrak*\r/\wNévcédula \rfelhelyezés", MENUPREFIX);
	new menu = menu_create(cim, "openTools_h");

	if(g_Player[id][SelectedToTools] == -1)
		menu_additem(menu,"\dElőbb válassz ki egy fegyvert! \d(\w1-es gomb!\d)","1",0)
	else
	{
		ArrayGetArray(g_Inventory, g_Player[id][SelectedToTools], Inventory)
		
		menu_additem(menu, fmt("\wFegyver: %s%s", FegyverInfo[Inventory[w_id]][Rarity], FegyverInfo[Inventory[w_id]][GunName]), "1", 0);

		if(Inventory[is_Nametaged]) //Ha névcédulázott akkor az első sor lesz, ha nem akkor a második
			menu_addtext2(menu, fmt("\wNévcédula\w: \r%s", Inventory[Nametag]))
		else
			menu_addtext2(menu, fmt("\wNévcédula\w: \dNincs"))

		if(Inventory[is_StatTraked]) //Again..
				menu_addtext2(menu, fmt("\wStatTrak\y*\w: \rVan \d| \wÖlések: \r%i", Inventory[StatTrakKills]))
			else
				menu_addtext2(menu, fmt("\wStatTrak\y*\w: \dNincs"))
			
		menu_addblank2(menu)
		if(g_Player[id][NametagTool] >= 1)
		{
			if(Inventory[is_Nametaged]) //Ha névcédulázott akkor 1 névcédulát elhasználva eltudod újra nevezni.
				menu_additem(menu, fmt("\yÚjra elnevezés \r[\r%i \wDB \yNévcédula\r]", g_Player[id][NametagTool]), "2", 0);
			else if(Inventory[is_Nametaged] == 0) 
				menu_additem(menu, fmt("\yElnevezés \y[\r%i \wDB \yNévcédula\r]", g_Player[id][NametagTool]), "2", 0);
		}
		else
		{
			if(Inventory[is_Nametaged]) //Ha névcédulázott akkor 1 névcédulát elhasználva eltudod újra nevezni.
				menu_additem(menu, fmt("\dÚjra elnevezés \d[\d%i \dDB \dNévcédula\d]", g_Player[id][NametagTool]), "-1", 0);
			else if(Inventory[is_Nametaged] == 0) 
				menu_additem(menu, fmt("\dElnevezés \d[\d%i \dDB \dNévcédula\d]", g_Player[id][NametagTool]), "-1", 0);
		}
		if(g_Player[id][StatTrakTool] >= 1)
		{
			if(Inventory[is_StatTraked]) //Ha StatTrak*-os a fegyver akkor tudod 1 StatTrak* Toolért nullázni az öléseket.
				menu_additem(menu, fmt("\rStatTrak* \wNullázása \r[\w%i \wDB \yStatTrak* Tool\r]", g_Player[id][StatTrakTool]), "3", 0);
			else
				menu_additem(menu, fmt("\rStatTrak* \wFelszerelése \r[\w%i \wDB \yStatTrak* Tool\r]", g_Player[id][StatTrakTool]), "3", 0);
		}
		else
		{
			if(Inventory[is_StatTraked]) //Ha StatTrak*-os a fegyver akkor tudod 1 StatTrak* Toolért nullázni az öléseket.
				menu_additem(menu, fmt("\dStatTrak* Nullázása \d[\d%i \dDB \dStatTrak* Tool\d]", g_Player[id][StatTrakTool]), "-1", 0);
			else
				menu_additem(menu, fmt("\dStatTrak* Felszerelése \d[\d%i \dDB \dStatTrak* Tool\d]", g_Player[id][StatTrakTool]), "-1", 0);
		}
	}

	menu_setprop(menu, MPROP_NEXTNAME, "Tovább");
	menu_setprop(menu, MPROP_BACKNAME, "Vissza");
	menu_setprop(menu, MPROP_EXITNAME, "Kilépés");

	menu_display(id, menu, 0);
}
public openTools_h(id, menu, item){
	
	if( item == MENU_EXIT ) {
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	
	new data[9], szName[64], iName[32]
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
	new key = str_to_num(data);
	new Inventory[InventorySystem];

	switch(key)
	{
		case -1:
		{
			client_print_color(id, print_team_default, "^4%s^1Ebből az ^3Itemből^1 neked nincs semmi! Előszőr vegyél az ^3Áruházban!", CHATPREFIX);
			openToolsMenu(id);
		}
		case 1: 
		{
			openToolsSwitch(id);
			g_Player[id][openSelectItemRow] = 2;
		}
		case 2: 
		{
			if(g_Player[id][NametagTool] > 0)
			{
				ArrayGetArray(g_Inventory, g_Player[id][SelectedToTools], Inventory)
				if(Inventory[is_Nametaged])
					client_cmd(id, "messagemode SET_RENAMETAG")
				else
					client_cmd(id, "messagemode SET_NAMETAG")
			}
			else client_print_color(id, print_team_default, "^4%s^1Ebből az ^3Itemből^1 neked nincs semmi! Előszőr vegyél az ^3Áruházban!", CHATPREFIX);
		}
		case 3:
		{
			if(g_Player[id][StatTrakTool] > 0)
			{
				ArrayGetArray(g_Inventory, g_Player[id][SelectedToTools], Inventory)
				if(Inventory[is_StatTraked])
					Inventory[StatTrakKills] = 0;
				else
				{
					Inventory[is_StatTraked] = 1;
					Inventory[StatTrakKills] = 0;
				}

				Inventory[Changed] = 1;
				g_Player[id][StatTrakTool]--;

				ArraySetArray(g_Inventory, g_Player[id][SelectedToTools], Inventory)
				//UpdateItem(id, 1, 3, g_Player[id][SelectedToTools],g_Player[id][UserId], Inventory[w_id], Inventory[is_Nametaged], Inventory[Nametag], Inventory[is_StatTraked], Inventory[StatTrakKills], Inventory[w_tradable], Inventory[w_equipped], Inventory[sqlid], Inventory[w_systime], Inventory[w_deleted])

				client_print_color(id, print_team_default, "^4%s^1A(z) ^3%s^1 fegyvered mostantól számolja az ^3öléseket!", CHATPREFIX, FegyverInfo[Inventory[w_id]][GunName])

				g_Player[id][SelectedToTools] = -1;
			}
			else client_print_color(id, print_team_default, "^4%s^1Ebből az ^3Itemből^1 neked nincs semmi! Előszőr vegyél az ^3Áruházban!", CHATPREFIX);
		}
	
	}
	menu_destroy(menu)
	return PLUGIN_HANDLED
}
public cmdAddNametag(id) {
	new Data[32], Inventory[InventorySystem];
	read_args(Data, charsmax(Data));
	remove_quotes(Data);
	ArrayGetArray(g_Inventory, g_Player[id][SelectedToTools], Inventory)

	if(!(RegexTester(id, Data, "^^[A-Za-z0-9öüóőúéáűíÖÜÓŐÚÉÁŰÍ <>=\/_.:!\?\*\[\]+,()\-]{1,16}+$", "A beírt szöveg csak magyar abc-t, számok és ^"<>=/_.!?*[]+,()-^"-ket tartalmazhatja, és a hossza nem haladhatja meg a^3 16-ot!")))
	{
		openToolsMenu(id);
		return;
	}
	
	copy(Inventory[Nametag], 32, Data)
	Inventory[is_Nametaged] = 1;
	
	ArraySetArray(g_Inventory, g_Player[id][SelectedToTools], Inventory)
	client_print_color(id, print_team_default, "^4%s^1A(z) ^3%s^1 fegyvered neve mostantól: ^3%s", CHATPREFIX, FegyverInfo[Inventory[w_id]][GunName], Inventory[Nametag])
	//UpdateItem(id, 1, 3, g_Player[id][SelectedToTools],g_Player[id][UserId], Inventory[w_id], Inventory[is_Nametaged], Inventory[Nametag], Inventory[is_StatTraked], Inventory[StatTrakKills], Inventory[w_tradable], Inventory[w_equipped], Inventory[sqlid], Inventory[w_systime], Inventory[w_deleted])
	g_Player[id][NametagTool]--;
	g_Player[id][SelectedToTools] = -1;
	return;
}
public openToolsSwitch(id)
{
	new Menu[512], MenuString[128], MenuKey
	format(MenuString, 127, "%s^n\wVálassz ki egy skint.^n^n", MENUPREFIX);
	add(Menu, 511, MenuString);
	
	format(MenuString, 127, fmt("\r1. \wAK47 \rSkinek^n"))
	add(Menu, 511, MenuString);
	format(MenuString, 127, fmt("\r2. \wM4A1 \rSkinek^n"))
	add(Menu, 511, MenuString);
	format(MenuString, 127, fmt("\r3. \wAWP \rSkinek^n"))
	add(Menu, 511, MenuString);
	format(MenuString, 127, fmt("\r4. \wDEAGLE \rSkinek^n"))
	add(Menu, 511, MenuString);
	format(MenuString, 127, fmt("\r5. \wKÉS \rSkinek^n^n\r0. \wKilépés a menüből."))
	add(Menu, 511, MenuString);

	MenuKey = (1<<0 | 1<<1 | 1<<2 | 1<<3 | 1<<4 | 1<<5 | 1<<6 | 1<<7 | 1<<8 | 1<<9);
	show_menu(id, MenuKey, Menu, -1, "TOOLSMENU");
	return PLUGIN_CONTINUE
}
public hToolsMenu(id, MenuKey)
{
	MenuKey++;
	switch(MenuKey)
	{
		case 1: openSelectItem(id, CSW_AK47)
		case 2: openSelectItem(id, CSW_M4A1)
		case 3: openSelectItem(id, CSW_AWP)
		case 4: openSelectItem(id, CSW_DEAGLE)
		case 5: openSelectItem(id, CSW_KNIFE)
		default:{
			show_menu(id, 0, "^n", 1);
			return
		}
	}
}
public openPlayerSkin(id)
{
	new iras[300]
	format(iras, charsmax(iras), "\y%s \wJátékos \rSkinek", MENUPREFIX);
	new menu = menu_create(iras, "openPSkins_H");

	menu_additem(menu, "\yJoker \d| \wT \rPlayerskin", "0", 0);
	menu_additem(menu, "\ySkinhead \d| \wCT \rPlayerskin", "1", 0);
	menu_additem(menu, "\yTommy Vercetti \d| \wT \rPlayerskin", "2", 0);
	menu_additem(menu, "\yTWR Class \d| \wCT \rPlayerskin", "3", 0);
	menu_additem(menu, "\yTWR Class \d| \wT \rPlayerskin", "4", 0);
	menu_additem(menu, "\yUmbrella \d| \wCT \rPlayerskin", "5", 0);
	menu_additem(menu, "\yJason \d| \wT \rPlayerskin", "6", 0);
	menu_additem(menu, "\yAnonim \d| \wCT \rPlayerskin", "7", 0);

	menu_display(id, menu, 0);
}
public openPSkins_H(id, menu, item){
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
			if(g_Player[id][is_pVip] == 2)
				g_Player[id][SelectedTSkin] = key;
		}
		case 1:
		{
			if(g_Player[id][is_pVip] > 0)
				g_Player[id][SelectedCTSkin] = key;
		}
		case 2:
		{
			if(g_Player[id][is_pVip] > 0)
				g_Player[id][SelectedTSkin] = key;
		}
		case 3:
		{
			if(g_Player[id][is_pVip] == 2)
				g_Player[id][SelectedCTSkin] = key;
		}
		case 4:
		{
			if(g_Player[id][is_pVip] == 2)
				g_Player[id][SelectedTSkin] = key;
		}
		case 5:
		{
			if(g_Player[id][is_pVip] > 0)
				g_Player[id][SelectedCTSkin] = key;
		}
		case 6:
		{
			if(g_Player[id][is_pVip] > 0)
				g_Player[id][SelectedTSkin] = key;
		}
		case 7:
		{
			if(g_Player[id][is_pVip] == 2)
				g_Player[id][SelectedCTSkin] = key;
		}
	}
	if(g_Player[id][is_pVip] < 0)
		client_print_color(id, print_team_default, "^4%s^1Nem vagy ^3Prémium VIP^1 vagy ^3Prémium VIP++^1!", CHATPREFIX)

	client_print_color(id, print_team_default, "^4%s^1Sikeresen felszerelted a ^3%s^1-t.", CHATPREFIX, SkinModelsInfo[key][PName])	
}
public openInventory(id, WEAPENT)
{
	new szMenu[256],String[6]
	formatex(szMenu, charsmax(szMenu), "%s Raktár", MENUPREFIX)
	new menu = menu_create(szMenu, "h_Inventory");

	new InventorySizeof = ArraySize(g_Inventory);
	new Inventory[InventorySystem];

	for(new i = 0; i < InventorySizeof;i++)
	{
		new len;
		ArrayGetArray(g_Inventory, i, Inventory);

		if(Inventory[w_userid] != g_Player[id][UserId])
			continue;

		if(FegyverInfo[Inventory[w_id]][EntName][0] == WEAPENT && Inventory[w_deleted] == 0)
		{
			if(Inventory[w_equipped])
				len += formatex(szMenu[len], charsmax(szMenu) - len, "\r!\d - ");

			if(Inventory[is_StatTraked])
				len += formatex(szMenu[len], charsmax(szMenu) - len, "\yStatTrak\r* \d- ");

			if(Inventory[is_Nametaged])
				len += formatex(szMenu[len], charsmax(szMenu) - len, "%s%s", FegyverInfo[Inventory[w_id]][Rarity], Inventory[Nametag]);
			else
				len += formatex(szMenu[len], charsmax(szMenu) - len, "%s%s", FegyverInfo[Inventory[w_id]][Rarity], FegyverInfo[Inventory[w_id]][GunName]);

			num_to_str(i, String, 5);
			menu_additem(menu, szMenu, String);
		}
	}

	menu_display(id, menu, 0);
}
public h_Inventory(id, menu, item) {
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED
	}

	new data[9], szName[64]
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName, charsmax(szName), callback);
	new key = str_to_num(data);

	new Inventory[InventorySystem]

	ArrayGetArray(g_Inventory, key, Inventory)

	if(blockall == 0)
	{
		EquipWeapon(id, Inventory[w_id], key)
		client_print_color(id, print_team_default, "^4%s^1Kivalásztottad a(z) ^3%s ^1fegyvert!", CHATPREFIX, FegyverInfo[Inventory[w_id]][GunName])
	}
	else 
		client_print_color(id, print_team_default, "^4%s^1Amíg a ^3szerver^1 a ^3raktárakat^1 menti, addig nem tudod kiválasztani a(z) ^3%s^1 fegyvert!", CHATPREFIX, FegyverInfo[Inventory[w_id]][GunName])

	
	openInventorySwitch(id)
	////if(TEampWeapon[equipted])
	//slgGun[id][AK47][1] = ArrayPushArray(g_Inventory, TempWeapon);
	
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public EquipWeapon(id, InventorySlot, InventoryIndex)
{
	new Inventory[InventorySystem]
	switch(FegyverInfo[InventorySlot][EntName])
	{
		case CSW_AK47:
		{
			ArrayGetArray(g_Inventory, SltGun[id][AK47][1], Inventory)
			SltGun[id][AK47][0] = 0;
			Inventory[w_equipped] = 0;
			ArraySetArray(g_Inventory, SltGun[id][AK47][1], Inventory)
			//UpdateItem(id, 1, 5, SltGun[id][AK47][1], g_Player[id][UserId], Inventory[w_id], Inventory[is_Nametaged], Inventory[Nametag], Inventory[is_StatTraked], Inventory[StatTrakKills], Inventory[w_tradable], Inventory[w_equipped], Inventory[sqlid], Inventory[w_systime], Inventory[w_deleted])

			SltGun[id][AK47][0] = InventorySlot;
			SltGun[id][AK47][1] = InventoryIndex;

			ArrayGetArray(g_Inventory, SltGun[id][AK47][1], Inventory)
			Inventory[w_equipped] = 1;
			Inventory[Changed] = 1;
			ArraySetArray(g_Inventory, SltGun[id][AK47][1], Inventory)
			//UpdateItem(id, 1, 5, SltGun[id][AK47][1], g_Player[id][UserId], Inventory[w_id], Inventory[is_Nametaged], Inventory[Nametag], Inventory[is_StatTraked], Inventory[StatTrakKills], Inventory[w_tradable], Inventory[w_equipped], Inventory[sqlid], Inventory[w_systime], Inventory[w_deleted])
		}
		case CSW_M4A1:
		{
			ArrayGetArray(g_Inventory, SltGun[id][M4A1][1], Inventory)
			SltGun[id][M4A1][0] = 1;
			Inventory[w_equipped] = 0;
			Inventory[Changed] = 1;
			ArraySetArray(g_Inventory, SltGun[id][M4A1][1], Inventory)
			//UpdateItem(id, 1, 5, SltGun[id][M4A1][1], g_Player[id][UserId], Inventory[w_id], Inventory[is_Nametaged], Inventory[Nametag], Inventory[is_StatTraked], Inventory[StatTrakKills], Inventory[w_tradable], Inventory[w_equipped], Inventory[sqlid], Inventory[w_systime], Inventory[w_deleted])

			SltGun[id][M4A1][0] = InventorySlot;
			SltGun[id][M4A1][1] = InventoryIndex;

			ArrayGetArray(g_Inventory, InventoryIndex, Inventory)
			Inventory[w_equipped] = 1;
			Inventory[Changed] = 1;
			ArraySetArray(g_Inventory, InventoryIndex, Inventory)
			//UpdateItem(id, 1, 5, SltGun[id][M4A1][1], g_Player[id][UserId], Inventory[w_id], Inventory[is_Nametaged], Inventory[Nametag], Inventory[is_StatTraked], Inventory[StatTrakKills], Inventory[w_tradable], Inventory[w_equipped], Inventory[sqlid], Inventory[w_systime], Inventory[w_deleted])
		}
		case CSW_AWP:
		{
			ArrayGetArray(g_Inventory, SltGun[id][AWP][1], Inventory)
			SltGun[id][AWP][0] = 2;
			Inventory[Changed] = 1;
			Inventory[w_equipped] = 0;
			ArraySetArray(g_Inventory, SltGun[id][AWP][1], Inventory)
			//UpdateItem(id, 1, 5, SltGun[id][AWP][1], g_Player[id][UserId], Inventory[w_id], Inventory[is_Nametaged], Inventory[Nametag], Inventory[is_StatTraked], Inventory[StatTrakKills], Inventory[w_tradable], Inventory[w_equipped], Inventory[sqlid], Inventory[w_systime], Inventory[w_deleted])

			SltGun[id][AWP][0] = InventorySlot;
			SltGun[id][AWP][1] = InventoryIndex;

			ArrayGetArray(g_Inventory, InventoryIndex, Inventory)
			Inventory[w_equipped] = 1;
			Inventory[Changed] = 1;
			ArraySetArray(g_Inventory, InventoryIndex, Inventory)
			//UpdateItem(id, 1, 5, SltGun[id][AWP][1], g_Player[id][UserId], Inventory[w_id], Inventory[is_Nametaged], Inventory[Nametag], Inventory[is_StatTraked], Inventory[StatTrakKills], Inventory[w_tradable], Inventory[w_equipped], Inventory[sqlid], Inventory[w_systime], Inventory[w_deleted])
		}
		case CSW_DEAGLE:
		{
			ArrayGetArray(g_Inventory, SltGun[id][DG][1], Inventory)
			SltGun[id][DG][0] = 3;
			Inventory[Changed] = 1;
			Inventory[w_equipped] = 0;
			ArraySetArray(g_Inventory, SltGun[id][DG][1], Inventory)
			//UpdateItem(id, 1, 5, SltGun[id][DG][1], g_Player[id][UserId], Inventory[w_id], Inventory[is_Nametaged], Inventory[Nametag], Inventory[is_StatTraked], Inventory[StatTrakKills], Inventory[w_tradable], Inventory[w_equipped], Inventory[sqlid], Inventory[w_systime], Inventory[w_deleted])

			SltGun[id][DG][0] = InventorySlot;
			SltGun[id][DG][1] = InventoryIndex;

			ArrayGetArray(g_Inventory, InventoryIndex, Inventory)
			Inventory[w_equipped] = 1;
			Inventory[Changed] = 1;
			ArraySetArray(g_Inventory, InventoryIndex, Inventory)
			//UpdateItem(id, 1, 5, SltGun[id][DG][1], g_Player[id][UserId], Inventory[w_id], Inventory[is_Nametaged], Inventory[Nametag], Inventory[is_StatTraked], Inventory[StatTrakKills], Inventory[w_tradable], Inventory[w_equipped], Inventory[sqlid], Inventory[w_systime], Inventory[w_deleted])
		}
		case CSW_KNIFE:
		{
			ArrayGetArray(g_Inventory, SltGun[id][KNIFE][1], Inventory)
			SltGun[id][KNIFE][0] = 4;
			Inventory[Changed] = 1;
			Inventory[w_equipped] = 0;
			ArraySetArray(g_Inventory, SltGun[id][KNIFE][1], Inventory)
			//UpdateItem(id, 1, 5, SltGun[id][KNIFE][1], g_Player[id][UserId], Inventory[w_id], Inventory[is_Nametaged], Inventory[Nametag], Inventory[is_StatTraked], Inventory[StatTrakKills], Inventory[w_tradable], Inventory[w_equipped], Inventory[sqlid], Inventory[w_systime], Inventory[w_deleted])
			
			SltGun[id][KNIFE][0] = InventorySlot;
			SltGun[id][KNIFE][1] = InventoryIndex;

			ArrayGetArray(g_Inventory, InventoryIndex, Inventory)
			Inventory[w_equipped] = 1;
			Inventory[Changed] = 1;
			ArraySetArray(g_Inventory, InventoryIndex, Inventory)
			//UpdateItem(id, 1, 5, SltGun[id][KNIFE][1], g_Player[id][UserId], Inventory[w_id], Inventory[is_Nametaged], Inventory[Nametag], Inventory[is_StatTraked], Inventory[StatTrakKills], Inventory[w_tradable], Inventory[w_equipped], Inventory[sqlid], Inventory[w_systime], Inventory[w_deleted])
		}
	}
}
public DeEquipWeapon(id, InventorySlot)
{
	new Inventory[InventorySystem];

	switch(FegyverInfo[InventorySlot][EntName])
	{
		case CSW_AK47:
		{
			ArrayGetArray(g_Inventory, SltGun[id][AK47][1], Inventory)
			SltGun[id][AK47][0] = 0;
			Inventory[w_equipped] = 0;
			ArraySetArray(g_Inventory, SltGun[id][AK47][1], Inventory)
		}
		case CSW_M4A1:
		{
			ArrayGetArray(g_Inventory, SltGun[id][M4A1][1], Inventory)
			SltGun[id][M4A1][0] = 1;
			Inventory[w_equipped] = 0;
			ArraySetArray(g_Inventory, SltGun[id][M4A1][1], Inventory)
		}
		case CSW_AWP:
		{
			ArrayGetArray(g_Inventory, SltGun[id][AWP][1], Inventory)
			SltGun[id][AWP][0] = 2;
			Inventory[w_equipped] = 0;
			ArraySetArray(g_Inventory, SltGun[id][AWP][1], Inventory)
		}
		case CSW_DEAGLE:
		{
			ArrayGetArray(g_Inventory, SltGun[id][DG][1], Inventory)
			SltGun[id][DG][0] = 3;
			Inventory[w_equipped] = 0;
			ArraySetArray(g_Inventory, SltGun[id][DG][1], Inventory)
		}
		case CSW_KNIFE:
		{
			ArrayGetArray(g_Inventory, SltGun[id][KNIFE][1], Inventory)
			SltGun[id][KNIFE][0] = 4;
			Inventory[w_equipped] = 0;
			ArraySetArray(g_Inventory, SltGun[id][KNIFE][1], Inventory)
		}
	}
}
public IsEquipWeapon(id, InventorySlot)
{
	switch(FegyverInfo[InventorySlot][EntName])
	{
		case CSW_AK47:
		{
			if(SltGun[id][AK47][1] == InventorySlot)
			return 1;
		}
		case CSW_M4A1:
		{
			if(SltGun[id][M4A1][1] == InventorySlot)
			return 1;
		}
		case CSW_AWP:
		{
			if(SltGun[id][AWP][1] == InventorySlot)
			return 1;
		}
		case CSW_DEAGLE:
		{
			if(SltGun[id][DG][1] == InventorySlot)
			return 1;
		}
		case CSW_KNIFE:
		{
			if(SltGun[id][KNIFE][1] == InventorySlot)
			return 1;
		}
	}
	return 0;
}
public openCaseSwitch(id)
{
	new cim[121];
	format(cim, charsmax(cim), "\d%s \rLádaNyitás", MENUPREFIX)
	new menu = menu_create(cim, "LadaEloszto_h");

	new CaseIf = sizeof(Cases);

	for(new i = 0; i < CaseIf; i++)
	{
		new Sor[6]; num_to_str(i, Sor, 5);
		formatex(cim, charsmax(cim), "%s \d| \y%i\rDB \d| \wKulcs: \y%i\rDB", Cases[i][d_Name], Case[id][i], Key[id][i]);
		menu_additem(menu, cim, Sor);
	}
	menu_setprop(menu, MPROP_NEXTNAME, "Tovább");
	menu_setprop(menu, MPROP_BACKNAME, "Vissza");
	menu_setprop(menu, MPROP_EXITNAME, "Kilépés");
	menu_display(id, menu, 0);
}
public LadaEloszto_h(id, menu, item)
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

	if(Case[id][key] >= 1 && Key[id][key] >= 1)
	{
		Case[id][key]--;
		Key[id][key]--;
		openCaseSwitch(id);
		openCase(id, key);
	}
	else
		client_print_color(id, print_team_default, "%s ^1Nincs Ládád vagy kulcsod.", CHATPREFIX);
}
public openCase(id, CaseKey)
{
	new Float:OverAll = 0.0;
	new Float:ChanceOld = 0.0;
	new Float:ChanceNow = 0.0;
	new OpenedWepID = 0;
	new Float:OpenedWepChance = 0.0;
	new Float:StatTrakChance = random_float(1.0, 170.0);
	new st = 0;

	switch(CaseKey)
	{
		case 0:
		{
			for(new i;i < m_alaplada ;i++)
			{
				OverAll += AlapDrops[i][1];
			}
			new Float:RandomNumber = random_float(0.01,OverAll);

			for(new i = 0; i < m_alaplada;i++)
			{
				ChanceOld = ChanceNow;
				ChanceNow += AlapDrops[i][1];

				if(ChanceOld < RandomNumber < ChanceNow)
				{
					if(StatTrakChance < 1.3)
						st = 1;

					AddToInv(id, g_Player[id][UserId], floatround(AlapDrops[i][0]), st, 0, 0, "", 1)
					OpenedWepID = floatround(AlapDrops[i][0]);
					OpenedWepChance = AlapDrops[i][1];
				}
			}
		}
		case 1:
		{
			for(new i;i < m_kezdolada ;i++)
			{
				OverAll += KezdoDrops[i][1];
			}
			new Float:RandomNumber = random_float(0.01,OverAll);

			for(new i = 0; i < m_kezdolada;i++)
			{
				ChanceOld = ChanceNow;
				ChanceNow += KezdoDrops[i][1];

				if(ChanceOld < RandomNumber < ChanceNow)
				{
					if(StatTrakChance < 1.3)
						st = 1;

					AddToInv(id, g_Player[id][UserId], floatround(KezdoDrops[i][0]), st, 0, 0, "", 1)
					OpenedWepID = floatround(KezdoDrops[i][0]);
					OpenedWepChance = KezdoDrops[i][1];
				}
			}
		}
		case 2:
		{
			for(new i;i < m_belepolada ;i++)
			{
				OverAll += BelepoDrops[i][1];
			}
			new Float:RandomNumber = random_float(0.01,OverAll);

			for(new i = 0; i < m_belepolada;i++)
			{
				ChanceOld = ChanceNow;
				ChanceNow += BelepoDrops[i][1];

				if(ChanceOld < RandomNumber < ChanceNow)
				{
					if(StatTrakChance < 1.3)
						st = 1;

					AddToInv(id, g_Player[id][UserId], floatround(BelepoDrops[i][0]), st, 0, 0, "", 1)
					OpenedWepID = floatround(BelepoDrops[i][0]);
					OpenedWepChance = BelepoDrops[i][1];
				}
			}
		}
		case 3:
		{
			for(new i;i < m_aranylada ;i++)
			{
				OverAll += AranyDrops[i][1];
			}
			new Float:RandomNumber = random_float(0.01,OverAll);

			for(new i = 0; i < m_aranylada;i++)
			{
				ChanceOld = ChanceNow;
				ChanceNow += AranyDrops[i][1];
				if(ChanceOld < RandomNumber < ChanceNow)
				{
					if(StatTrakChance <= 3.25)
						st = 1;
	
					AddToInv(id, g_Player[id][UserId], floatround(AranyDrops[i][0]), st, 0, 0, "", 1)
					OpenedWepID = floatround(AranyDrops[i][0]);
					OpenedWepChance = AranyDrops[i][1];
				}
			}
		}
		case 4:
		{
			for(new i;i < m_platlada ;i++)
			{
				OverAll += PlatinumDrops[i][1];
			}
			new Float:RandomNumber = random_float(0.01,OverAll);

			for(new i = 0; i < m_platlada;i++)
			{
				ChanceOld = ChanceNow;
				ChanceNow += PlatinumDrops[i][1];

				if(ChanceOld < RandomNumber < ChanceNow)
				{
					if(StatTrakChance <= 3.25)
						st = 1;

					AddToInv(id, g_Player[id][UserId], floatround(PlatinumDrops[i][0]), st, 0, 0, "", 1)
					OpenedWepID = floatround(PlatinumDrops[i][0]);
					OpenedWepChance =PlatinumDrops[i][1];
				}
			}
		}
		case 5:
		{
			for(new i;i < m_szinozonlada ;i++)
			{
				OverAll += SzinozonDrops[i][1];
			}
			new Float:RandomNumber = random_float(0.01,OverAll);

			for(new i = 0; i < m_szinozonlada;i++)
			{
				ChanceOld = ChanceNow;
				ChanceNow += SzinozonDrops[i][1];
				if(ChanceOld < RandomNumber < ChanceNow)
				{
					if(StatTrakChance <= 3.25)
						st = 1;

					AddToInv(id, g_Player[id][UserId], floatround(SzinozonDrops[i][0]), st, 0, 0, "", 1)
					OpenedWepID = floatround(SzinozonDrops[i][0]);
					OpenedWepChance = SzinozonDrops[i][1];
				}
			}
		}
	}

	if(FegyverInfo[OpenedWepID][EntName] == CSW_KNIFE || st == 1)
	{
		client_print_color(0, print_team_default, "^4%s^1Játékos: ^3%s^1 nyitott egy ^3%s%s^1-t ebből: ^4%s^1. ^3(^1Esélye: ^4%.3f%s^3)", CHATPREFIX, g_Player[id][Name], st ? "StatTrak*" : "", FegyverInfo[OpenedWepID][GunName], Cases[CaseKey][d_Name], (OpenedWepChance/(OverAll/100.0)),"%");
	}
	else
	{
		client_print_color(id, print_team_default, "^4%s^1Nyitottál egy ^3%s%s^1-t ebből: ^4%s^1. ^3(^1Esélye: ^4%.3f%s^3)", CHATPREFIX, st ? "StatTrak*" : "", FegyverInfo[OpenedWepID][GunName], Cases[CaseKey][d_Name], (OpenedWepChance/(OverAll/100.0)),"%");
	}	 
} 
public openSettings(id)
{
	new MenuString[121];
	format(MenuString, charsmax(MenuString), "\y%s Profil Beállítások", MENUPREFIX);
	new menu = menu_create(MenuString, "SettingsPost");

/* 	format(MenuString, charsmax(MenuString), "Játékosnév: \r%s", g_Player[id][Name]);
	menu_addtext2(menu, MenuString);
	format(MenuString, charsmax(MenuString), "\wUtolsó felcsatlakozás: \r%s", g_Player[id][LastConnectTime]);
	menu_addtext2(menu, MenuString); */

	menu_additem(menu, g_Player[id][SkinOnOff] == 0 ? "Skin: \rBekapcsolva \y| \dKikapcsolva":"Skin: \dBekapcsolva \y| \rKikapcsolva", "0",0);//"
	menu_additem(menu, g_Player[id][RoundEndSound] == 1 ? "Körvégi Zene: \rBekapcsolva \y| \dKikapcsolva":"Körvégi Zene:\dBekapcsolva \y| \rKikapcsolva", "1",0);//"
	menu_additem(menu, g_Player[id][UltimateSound] == 0 ? "Ultimate Hangok: \rBekapcsolva \y| \dKikapcsolva":"Ultimate Hangok:\dBekapcsolva \y| \rKikapcsolva", "2",0);//"
	menu_additem(menu, g_Player[id][SanksOff] == 1 ? "Chat Hangok: \rBekapcsolva \y| \dKikapcsolva":"Chat Hangok:\dBekapcsolva \y| \rKikapcsolva", "6",0);//"
	menu_additem(menu, g_Player[id][HudOff] == 0 ? "HUD: \dKikapcsolva \y| \rBekapcsolva":"HUD: \rKikapcsolva \y| \dBekapcsolva", "3",0);//"
	menu_additem(menu, g_Player[id][HudType] == 0 ? "HUD részletessége: \rRészletes \y| \dNormál":"HUD részletessége:\dRészletes \y| \rNormál", "4",0);//"
	menu_additem(menu, g_Player[id][WeaponHud] == 0 ? "Fegyver HUD: \rBekapcsolva \y| \dKikapcsolva":"Fegyver HUD:\dBekapcsolva \y| \rKikapcsolva", "5",0);//"
	menu_setprop(menu, MPROP_NEXTNAME, "Tovább");
	menu_setprop(menu, MPROP_BACKNAME, "Vissza");
	menu_setprop(menu, MPROP_EXITNAME, "Kilépés");
	menu_display(id, menu, 0)
}
public SettingsPost(id, menu, item)
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
		case 0: g_Player[id][SkinOnOff] = !g_Player[id][SkinOnOff]
		case 1: g_Player[id][RoundEndSound] = !g_Player[id][RoundEndSound]
		case 2: g_Player[id][HudType] = !g_Player[id][HudType]
		case 3: g_Player[id][HudOff] = !g_Player[id][HudOff]
		case 4: g_Player[id][HudType] = !g_Player[id][HudType]
		case 5: g_Player[id][WeaponHud] = !g_Player[id][WeaponHud]
		case 6: g_Player[id][SanksOff] = !g_Player[id][SanksOff]
	}
	openSettings(id);
}
public openAruhazMenu(id)
{
	new Menu[512], MenuString[256], MenuKey
	format(MenuString, 127, "\d%s \wÁruház^n^n", MENUPREFIX)
	add(Menu, 511, MenuString);
	new Float:iVipCost = get_pcvar_float(SCvar[vipCost]);
	new Float:iStatTrakCost = get_pcvar_float(SCvar[StatTrakCost]);
	new Float:iNametagCost = get_pcvar_float(SCvar[NametagCost]);
	new Float:iChatPrefixCost = get_pcvar_float(SCvar[ChatPrefixCost]);
	new Float:iSorsjegyCost = get_pcvar_float(SCvar[SorsjegyCost]);
	new Float:iXPBoosterCost = get_pcvar_float(SCvar[XPBoosterCost]);

	format(MenuString, 127, fmt("\r1. \wVIP Vásárlás \y[\r%3.2f$\w/\tnap\y]^n", iVipCost))
	add(Menu, 511, MenuString);
	format(MenuString, 127, fmt("\r2. \wNévcédula Vásárlás \y[\r%3.2f$\y]^n", iNametagCost))
	add(Menu, 511, MenuString);
	format(MenuString, 127, fmt("\r3. \wStatTrak* Felszerelő Vásárlás \y[\r%3.2f$\y]^n", iStatTrakCost))
	add(Menu, 511, MenuString);
	format(MenuString, 127, fmt("\r4. \wZenekészlet Vásárlás \r| \yTovább\r |^n"))
	add(Menu, 511, MenuString);
	format(MenuString, 127, fmt("\r5. \wEgyedi Chat Prefix Vásárlás \y[\r%3.2f$\y]^n", iChatPrefixCost))
	add(Menu, 511, MenuString);
	format(MenuString, 127, fmt("\r6. \w6 Óra \rXP\w Booster Vásárlás \y[\r%3.2f$\y]^n", iXPBoosterCost))
	add(Menu, 511, MenuString);
	format(MenuString, 127, fmt("\r7. \wTippKulcs Vásárlás \y[\r%3.2f$\y]^n", iSorsjegyCost))
	add(Menu, 511, MenuString);
	format(MenuString, 127, fmt("\r8. \wLáda \y/\w Kulcs Vásárlás \r| \yTovább\r |^n^n"))
	add(Menu, 511, MenuString);
	format(MenuString, 127, fmt("\r0. \wKilépés a menüből."))
	add(Menu, 511, MenuString);
	
	MenuKey = (1<<0 | 1<<1 | 1<<2 | 1<<3 | 1<<4 | 1<<5 | 1<<6 | 1<<7 | 1<<8 | 1<<9);
	show_menu(id, MenuKey, Menu, -1, "ARUHAZMENU");
	return PLUGIN_CONTINUE
}
public Aruhaz_h(id, MenuKey)
{
	new Float:iStatTrakCost = get_pcvar_float(SCvar[StatTrakCost]);
	new Float:iNametagCost = get_pcvar_float(SCvar[NametagCost]);
	new Float:iChatPrefixCost = get_pcvar_float(SCvar[ChatPrefixCost]);
	new Float:iSorsjegyCost = get_pcvar_float(SCvar[SorsjegyCost]);
	new Float:iXPBoosterCost = get_pcvar_float(SCvar[XPBoosterCost]);

	MenuKey++;
	switch(MenuKey)
	{
		case 1: openVIPAruhaz(id, 1);
		case 2:
		{
			if(g_Player[id][Dollar] >= iNametagCost)
			{
				g_Player[id][NametagTool]++;
				g_Player[id][Dollar] -= iNametagCost;
				client_print_color(id, print_team_default, "^4%s^1Sikeresen megvásároltad a ^3Névcédulá^1-t.", CHATPREFIX)
			}
			else client_print_color(id, print_team_default, "^4%s^1Nincs elég egyenleged, hogy megvásárold ezt a tárgyat!", CHATPREFIX);
		}
		case 3:
		{
			if(g_Player[id][Dollar] >= iStatTrakCost)
			{
				g_Player[id][StatTrakTool]++;
				g_Player[id][Dollar] -= iStatTrakCost;
				client_print_color(id, print_team_default, "^4%s^1Sikeresen megvásároltad a ^3StatTrak* Felszerelő^1-t.", CHATPREFIX)
			}
			else client_print_color(id, print_team_default, "^4%s^1Nincs elég egyenleged, hogy megvásárold ezt a tárgyat!", CHATPREFIX);
		}
		case 4: m_Zenekeszlet(id)
		
		case 5:
		{
			if(g_Player[id][Dollar] >= iChatPrefixCost)
			{
				client_cmd(id, "messagemode EnterPrefix");
			}
			else client_print_color(id, print_team_default, "^4%s^1Nincs elég egyenleged, hogy megvásárold ezt a tárgyat!", CHATPREFIX);
		}
		case 6:
		{
			if(g_Player[id][Dollar] >= iXPBoosterCost)
			{
				client_print_color(id, print_team_default, "^4%s^1Sikeresen megvásároltad a^3 6 Óra XP Boost^1-ot.", CHATPREFIX)
				g_Player[id][Dollar] -= iXPBoosterCost;
			}
			else client_print_color(id, print_team_default, "^4%s^1Nincs elég egyenleged, hogy megvásárold ezt a tárgyat!", CHATPREFIX);
		}
		case 7:
		{
			if(g_Player[id][Dollar] >= iSorsjegyCost)
			{
				client_print_color(id, print_team_default, "^4%s^1Sikeresen vásároltál egy ^3TippKulcs^1-ot.", CHATPREFIX)
				g_Player[id][Dollar] -= iSorsjegyCost;
				TippKey[id][HaveKey]++
			}
			else client_print_color(id, print_team_default, "^4%s^1Nincs elég egyenleged, hogy megvásárold ezt a tárgyat!", CHATPREFIX);
		}
	}
}
public set_Prefix(id)
{
	new Arg1[32];
	read_argv(1, Arg1, charsmax(Arg1));
	if(!(RegexTester(id, Arg1, "^^[A-Za-z0-9öüóőúéáűíÖÜÓŐÚÉÁŰÍ ]{1,13}+$", "A beírt szöveg csak magyar abc-t, számok és a hossza ^3maximum 13 karakter^1 lehet!")))
	{
		openAruhazMenu(id);
		return;
	}

	new Admin_Permissions_size = sizeof(Admin_Permissions);
	for(new i=0; i < Admin_Permissions_size; i++)
	{
		if(equal(Arg1, Admin_Permissions[i][0]))
		{
		client_print_color(id, print_team_default, "^4%s^1Nem használhatod a^1 ^"^3%s^1^" ^4nevű^1 Egyedi Chat Prefixe-t.", CHATPREFIX, g_Player[id][ChatPrefix]);
		openAruhazMenu(id);
		return;
		}
	}

	copy(g_Player[id][ChatPrefix], 16, Arg1)
	g_Player[id][isPrefixed] = 1;
	g_Player[id][Dollar] -= get_pcvar_float(SCvar[ChatPrefixCost]);
	client_print_color(id, print_team_default, "^4%s^1Sikeresen megvásároltad a^1 ^"^3%s^1^" ^4nevű^1 Egyedi Chat Prefixe-t.", CHATPREFIX, g_Player[id][ChatPrefix])
}
public openVIPAruhaz(id, VipType)
{
	new String[256], iTime[32]
	new Float:iVipCost = get_pcvar_float(SCvar[vipCost]);
	g_Player[id][PressedVIPMenu] = VipType;
	formatex(String, charsmax(String), "%s \dVIP Vásárlás^n\yDollár: \r%3.2f$ \d| \yPrémium Pont: \r%i", MENUPREFIX, g_Player[id][Dollar], g_Player[id][PremiumPont]);
	new menu = menu_create(String, "openVIPAruhaz_h");

	menu_addtext2(menu, "\dKisokos: \wNyomd meg a 3-as gombot, és írj be egy számot. (Ez lesz a nap)")
	switch(VipType)
	{
		case 1:
		{
			format_time(iTime, 32, "%Y.%m.%d - %H:%M:%S", get_systime()+86400*g_Player[id][BuyVIPDay])
			menu_addtext2(menu, "\dTárgy: \wSima VIP")
			menu_additem(menu, fmt("\dHossza: \r%i\y NAP \d(\r%s\d)^n", g_Player[id][BuyVIPDay], iTime),"1")

			if(iVipCost*g_Player[id][BuyVIPDay] <= g_Player[id][Dollar])
				menu_additem(menu, fmt("\yVásárlás \d[\yÁr: \r%3.2f\d]", iVipCost*g_Player[id][BuyVIPDay]), "2", 0)
			else
				menu_additem(menu, fmt("\dVásárlás \d[\yÁr: \r%3.2f\d]", iVipCost*g_Player[id][BuyVIPDay]), "-1", 0)
		}
		case 2:
		{
			if(g_Player[id][is_pVip] > 0)
			{
				client_print_color(id, print_team_default, "^4%s^3Sajnálom!^1 Amíg van bármilyen ^3Prémium VIP-ed^1 addig nem tudsz újat vásárolni!", CHATPREFIX)
				menu_destroy(menu);
				return PLUGIN_HANDLED;
			}
			else
			{
				format_time(iTime, 32, "%Y.%m.%d - %H:%M:%S", get_systime()+86400*g_Player[id][BuyVIPDay]*7)
				menu_addtext2(menu, "\dTárgy: \yPrémium VIP")
				menu_additem(menu, fmt("\dHossza: \r%i\y HÉT\d(\r%s\d)^n", g_Player[id][BuyVIPDay], iTime),"1")

				if(get_pcvar_num(SCvar[pvipCost])*g_Player[id][BuyVIPDay] <= g_Player[id][PremiumPont])
					menu_additem(menu, fmt("\yVásárlás \d[\yÁr: \r%i \yPP\d]", get_pcvar_num(SCvar[pvipCost])*g_Player[id][BuyVIPDay]), "2", 0)
				else
					menu_additem(menu, fmt("\dVásárlás \d[\yÁr: \r%i \yPP\d]", get_pcvar_num(SCvar[pvipCost])*g_Player[id][BuyVIPDay]), "-1", 0)
			}
		}
		case 3:
		{
			if(g_Player[id][is_pVip] > 0)
			{
				client_print_color(id, print_team_default, "^4%s^3Sajnálom!^1 Amíg van bármilyen ^3Prémium VIP-ed^1 addig nem tudsz újat vásárolni!", CHATPREFIX)
				menu_destroy(menu);
				return PLUGIN_HANDLED;
			}
			else
			{
				format_time(iTime, 32, "%Y.%m.%d - %H:%M:%S", get_systime()+86400*g_Player[id][BuyVIPDay]*7)
				menu_addtext2(menu, "\dTárgy: \yPrémium VIP++")
				menu_additem(menu, fmt("\dHossza: \r%i\y HÉT\d(\r%s\d)^n", g_Player[id][BuyVIPDay], iTime),"1")

				if(get_pcvar_num(SCvar[pvipCost])*2*g_Player[id][BuyVIPDay] <= g_Player[id][PremiumPont])
					menu_additem(menu, fmt("\yVásárlás \d[\yÁr: \r%i \yPP\d]", get_pcvar_num(SCvar[pvipCost])*2*g_Player[id][BuyVIPDay]), "2", 0)
				else
					menu_additem(menu, fmt("\dVásárlás \d[\yÁr: \r%i \yPP\d]", get_pcvar_num(SCvar[pvipCost])*2*g_Player[id][BuyVIPDay]), "-1", 0)
			}
		}
	}
	
	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}
public openVIPAruhaz_h(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return;
	}
		
	new data[9], szName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
	new Float:iVipCost = get_pcvar_float(SCvar[vipCost]);
	new key = str_to_num(data);
	
	switch(key)
	{
		case -1: client_print_color(id, print_team_default, "^4%s^1Nincs elég egyenleged, hogy megvásárold ezt a tárgyat!", CHATPREFIX);
		case 1: client_cmd(id, "messagemode VIPnap")
		case 2:
		{
			if(g_Player[id][PressedVIPMenu] == 1)
			{
				if(g_Player[id][Dollar] >= iVipCost*g_Player[id][BuyVIPDay])
				{
					g_Player[id][Dollar] -= iVipCost*g_Player[id][BuyVIPDay];
					g_Player[id][vipTime] += get_systime()+86400*g_Player[id][BuyVIPDay];
					g_Player[id][is_Vip] = 1;
					client_print_color(id, print_team_default, "^4%s^1Sikeresen megvásároltad a ^3%i^4 napra^1 szóló ^3VIP^1-ed. Jó szórakozást ^3:)", CHATPREFIX, g_Player[id][BuyVIPDay])
				}
			}
			else if(g_Player[id][PressedVIPMenu] == 2)
			{
				if(g_Player[id][PremiumPont] >= get_pcvar_num(SCvar[pvipCost])*g_Player[id][BuyVIPDay])
				{
					g_Player[id][PremiumPont] -= get_pcvar_num(SCvar[pvipCost])*g_Player[id][BuyVIPDay];
					g_Player[id][pvipTime] += get_systime()+86400*g_Player[id][BuyVIPDay]*7;
					g_Player[id][is_pVip] = 1;
					client_print_color(id, print_team_default, "^4%s^1Sikeresen megvásároltad a ^3%i^4 hétre^1 szóló ^3Prémium VIP^1-ed. Jó szórakozást ^3:)", CHATPREFIX, g_Player[id][BuyVIPDay])
				}
			}
			else if(g_Player[id][PressedVIPMenu] == 3)
			{
				if(g_Player[id][PremiumPont] >= get_pcvar_num(SCvar[pvipCost])*2*g_Player[id][BuyVIPDay])
				{
					g_Player[id][PremiumPont] -= get_pcvar_num(SCvar[pvipCost])*2*g_Player[id][BuyVIPDay];
					g_Player[id][pvipTime] += get_systime()+86400*g_Player[id][BuyVIPDay]*7;
					g_Player[id][is_pVip] = 2;
					client_print_color(id, print_team_default, "^4%s^1Sikeresen megvásároltad a ^3%i^4 hétre^1 szóló ^3Prémium VIP++^1-od. Jó szórakozást ^3:)", CHATPREFIX, g_Player[id][BuyVIPDay])
				}
			}
			else
			{
				client_print_color(id, print_team_default, "^4%s^1Nincs elég egyenleged, hogy megvásárold ezt a tárgyat!", CHATPREFIX);
			}
		}
	}
	g_Player[id][BuyVIPDay] = 1;
}
public cmdVIPDay(id)
{
	new iArgDate[32]
	read_args(iArgDate, charsmax(iArgDate))
	remove_quotes(iArgDate)
	g_Player[id][BuyVIPDay] = str_to_num(iArgDate)

	if(g_Player[id][BuyVIPDay] > 650 || g_Player[id][BuyVIPDay] <= 0)
	{
		g_Player[id][BuyVIPDay] = 1;
		client_print_color(id, print_team_default, "^4%s^1Nanana! Azért ennyire ne legyél telhetetlen!", CHATPREFIX);
		return PLUGIN_HANDLED;
	}
	
	openVIPAruhaz(id, g_Player[id][PressedVIPMenu])
}
public m_PremiumBolt(id)
{
	new String[121];
	formatex(String, charsmax(String), "%s \dPrémium Bolt^n\yPrémium Pontok: \d%i", MENUPREFIX, g_Player[id][PremiumPont]);
	new menu = menu_create(String, "m_PremiumBolt_h");
	
	menu_additem(menu, "PP Vásárlás \rHívás", "-1", 0)
	menu_additem(menu, "PP Vásárlás \rPayPal", "0", 0)
	menu_additem(menu, "1 Hetes \yPrémium \rVIP \w[\r400PP\w]", "1")
	menu_additem(menu, "1 Hetes \yPrémium \rVIP\y++ \w[\r800PP\w]", "2")
	menu_additem(menu, "BlackIce Prémium Csomag \w[\r70PP\w]", "3", 0)
	menu_additem(menu, "CannabisLife Prémium Csomag \w[\r40PP\w]", "4", 0)
	menu_additem(menu, "Random \rKés\w Pörgetés \w[\r200PP\w]", "5", 0)
/* 	menu_additem(menu, "Gradient | Multihearh \w[\r90PP\w]", "6", 0)
	menu_additem(menu, "Gradient | Rainbow \w[\r110PP\w]", "7", 0) */
	menu_additem(menu, "\rPiros\y Tron\r Pack \w[\r300PP\w]", "8", 0)
	menu_additem(menu, "\rZöld\y Tron\r Pack \w[\r300PP\w]", "9", 0)
	menu_additem(menu, "\rLime\y Tron\r Pack\w[\r300PP\w]", "10", 0)
	// menu_additem(menu, "System Lock Prémium Csomag \w[\r70PP\w] \r*ÚJ!", "8", 0)
	// menu_additem(menu, "Graffiti Prémium Csomag \w[\r70PP\w] \r*ÚJ!", "9", 0) 
	
	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
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
	new sztime[40]
	new sTime[9], sDate[11], sDateAndTime[32];
	get_time("%H:%M:%S", sTime, 8 );
	get_time("%Y/%m/%d", sDate, 11);
	formatex(sDateAndTime, 31, "%s %s", sDate, sTime);

	switch(key)
	{
		case -1: show_motd(id, fmt("http://herboyteam.hu/smsvasarlas.php?id=%i", g_Player[id][UserId]), "Prémium Pont - SMS Vásárlás");
		case 1: openVIPAruhaz(id, 2);
		case 2: openVIPAruhaz(id, 3);
		case 3:
		{
			if(g_Player[id][PremiumPont] >= 80)
			{
				AddToInv(id, g_Player[id][UserId], 187, 0, 0, 0, "", 0)
				AddToInv(id, g_Player[id][UserId], 188, 0, 0, 0, "", 0)
				AddToInv(id, g_Player[id][UserId], 189, 0, 0, 0, "", 0)
				AddToInv(id, g_Player[id][UserId], 190, 0, 0, 0, "", 0)
				AddToInv(id, g_Player[id][UserId], 195, 0, 0, 0, "", 0)
				AddToInv(id, g_Player[id][UserId], 196, 0, 0, 0, "", 0)
				AddToInv(id, g_Player[id][UserId], 197, 0, 0, 0, "", 0)
				AddToInv(id, g_Player[id][UserId], 198, 0, 0, 0, "", 0)
				g_Player[id][PremiumPont] -= 80;
				client_print_color(id, print_team_default, "^4%s^1Sikeresen megvásároltad a ^3Black Ice^1 prémium csomagot!", CHATPREFIX)
			}
		}
		case 4:
		{
			if(g_Player[id][PremiumPont] >= 40)
			{
				AddToInv(id, g_Player[id][UserId], 191, 0, 0, 0, "", 0)
				AddToInv(id, g_Player[id][UserId], 192, 0, 0, 0, "", 0)
				AddToInv(id, g_Player[id][UserId], 193, 0, 0, 0, "", 0)
				AddToInv(id, g_Player[id][UserId], 194, 0, 0, 0, "", 0)
				AddToInv(id, g_Player[id][UserId], 198, 0, 0, 0, "", 0)
				g_Player[id][PremiumPont] -= 40;
				client_print_color(id, print_team_default, "^4%s^1Sikeresen megvásároltad a ^3Cannabis Life^1 prémium csomagot!", CHATPREFIX)
			}
		}
		case 5:
		{
			if(g_Player[id][PremiumPont] >= 200)
			{
				new randomknife = random_num(138,183)
				AddToInv(id, g_Player[id][UserId], randomknife, 0, 0, 0, "", 1)
				client_print_color(id, print_team_default, "^4%s^1Sikeresen pörgettél egy ^4%s^1-t!", CHATPREFIX, FegyverInfo[randomknife][GunName])
				g_Player[id][PremiumPont] -= 200;
			}
		}
		case 6:
		{
			if(g_Player[id][PremiumPont] >= 90)
			{
				AddToInv(id, g_Player[id][UserId], 199, 0, 0, 0, "", 0)
				g_Player[id][PremiumPont] -= 90;

				client_print_color(id, print_team_default, "^4%s^1Sikeresen vásároltál egy ^4Gradient | MultiHearth^1 kést!", CHATPREFIX)
			}
		}
		case 7:
		{
			if(g_Player[id][PremiumPont] >= 110)
			{
				AddToInv(id, g_Player[id][UserId], 200, 0, 0, 0, "", 0)
				g_Player[id][PremiumPont] -= 110;

				client_print_color(id, print_team_default, "^4%s^1Sikeresen vásároltál egy ^4Gradient | Rainbow^1 kést!", CHATPREFIX)
			}
		}
		case 8:
		{
			if(g_Player[id][PremiumPont] >= 300)
			{
				AddToInv(id, g_Player[id][UserId], 215, 0, 0, 0, "", 1)
				AddToInv(id, g_Player[id][UserId], 216, 0, 0, 0, "", 1)
				AddToInv(id, g_Player[id][UserId], 217, 0, 0, 0, "", 1)
				AddToInv(id, g_Player[id][UserId], 218, 0, 0, 0, "", 1)
				AddToInv(id, g_Player[id][UserId], 219, 0, 0, 0, "", 1)
				g_Player[id][PremiumPont] -= 300;

				client_print_color(id, print_team_default, "^4%s^1Sikeresen vásároltál egy ^4Piros Tron^1 packot!", CHATPREFIX)
			}
		}
		case 9:
		{
			if(g_Player[id][PremiumPont] >= 300)
			{
				AddToInv(id, g_Player[id][UserId], 220, 0, 0, 0, "", 1)
				AddToInv(id, g_Player[id][UserId], 221, 0, 0, 0, "", 1)
				AddToInv(id, g_Player[id][UserId], 222, 0, 0, 0, "", 1)
				AddToInv(id, g_Player[id][UserId], 223, 0, 0, 0, "", 1)
				AddToInv(id, g_Player[id][UserId], 224, 0, 0, 0, "", 1)
				g_Player[id][PremiumPont] -= 300;

				client_print_color(id, print_team_default, "^4%s^1Sikeresen vásároltál egy ^4Zöld Tron^1 packot!", CHATPREFIX)
			}
		}
		case 10:
		{
			if(g_Player[id][PremiumPont] >= 300)
			{
				AddToInv(id, g_Player[id][UserId], 225, 0, 0, 0, "", 1)
				AddToInv(id, g_Player[id][UserId], 226, 0, 0, 0, "", 1)
				AddToInv(id, g_Player[id][UserId], 227, 0, 0, 0, "", 1)
				AddToInv(id, g_Player[id][UserId], 228, 0, 0, 0, "", 1)
				AddToInv(id, g_Player[id][UserId], 229, 0, 0, 0, "", 1)
				g_Player[id][PremiumPont] -= 300;

				client_print_color(id, print_team_default, "^4%s^1Sikeresen vásároltál egy ^4Lime Tron^1 packot!", CHATPREFIX)
			}
		}
	}
}
public HudX(id)
{ 
	new m_Index, wid, iLen;
	new HudString[512]
	
	if(is_user_alive(id))
		m_Index = id;
	else
		m_Index = entity_get_int(id, EV_INT_iuser2);
	if(!sk_get_logged(id))
		iLen += formatex(HudString[iLen], charsmax(HudString), "^n^nJelentkezz be a [ T Betű ] megnyomásával!^n^n");
	if(Fragverseny)
	{
		new Players[32], Num;
		get_players(Players, Num);
		SortCustom1D(Players, Num, "sort_bestthree")
	
		new Top1 = Players[0]
		new Top2 = Players[1]
		new Top3 = Players[2]
		
		set_hudmessage(0, 127, 255, -1.0, 0.10, 0, 6.0, 1.0);
		ShowSyncHudMsg(id, cSync, "Jelenleg fragverseny van! (Még %i kör)^n1. %s - Ölés: %i | 2. %s - Ölés: %i | 3. %s - Ölés: %i", Fragkorok, g_Player[Top1][Name], g_Player[Top1][FragKills], g_Player[Top2][Name], g_Player[Top2][FragKills], g_Player[Top3][Name], g_Player[Top3][FragKills])
	}
	if(karbantartas)
	{
		set_hudmessage(random(255), random(255), random(255), -1.0, 0.10, 0, 6.0, 1.0);
		ShowSyncHudMsg(id, cSync, "Szerver karbantartása 20:00-kor elkeződik!")

	}

	if(g_Player[id][HudOff] == 0)
	{
		new i_Seconds, i_Minutes, i_Hours, i_Days;
		i_Seconds = g_Player[m_Index][PlayTime] + get_user_time(m_Index);
		i_Minutes = i_Seconds / 60;
		i_Hours = i_Minutes / 60;
		i_Seconds = i_Seconds - i_Minutes * 60;
		i_Minutes = i_Minutes - i_Hours * 60;
		i_Days = i_Hours / 24;
		i_Hours = i_Hours - (i_Days * 24);

		if(sk_get_logged(m_Index))
		{
			if(g_Player[m_Index][HudType] == 0)
				iLen += formatex(HudString[iLen], charsmax(HudString), "Név: %s(#%i)^n^nÖlés: %i | HS: %i | Halál: %i^n%s^n%s^nNyert Meccsek: %i^nJátszott idő: %i Nap %i Óra %i Perc^nEgyenleg:^nDollár: %3.2f^nPrémium Pont: %i^nNyeremény Ölések: --", g_Player[m_Index][Name], g_Player[m_Index][UserId], g_Player[m_Index][Kills], g_Player[m_Index][HS], g_Player[m_Index][Deaths], PrivateRanks[g_Player[m_Index][ProfilRank]], Rangok[g_Player[m_Index][Rang]][RangName], g_Player[m_Index][Wins], i_Days, i_Hours, i_Minutes, g_Player[m_Index][Dollar], g_Player[m_Index][PremiumPont]);
			else
				iLen += formatex(HudString[iLen], charsmax(HudString), "Név: %s(#%i)^n^nÖlés: %i | HS: %i | Halál: %i^nJátszott idő: %i Nap %i Óra %i Perc^nEgyenleg:^nDollár: %3.2f^nPrémium Pont: %i^nNyeremény Ölések: --", g_Player[m_Index][Name], g_Player[m_Index][UserId], g_Player[m_Index][Kills], g_Player[m_Index][HS], g_Player[m_Index][Deaths], i_Days, i_Hours, i_Minutes, g_Player[m_Index][Dollar], g_Player[m_Index][PremiumPont]);
		}
		else
		{
			iLen += formatex(HudString[iLen], charsmax(HudString), "Név: %s^n^nA játékos nincs bejelentkezve!", g_Player[m_Index][Name]);
		}
		set_hudmessage(random(256), random(256), random(256), 0.01, 0.15, 0, 6.0, 1.1, next_hudchannel(id));
		ShowSyncHudMsg(id, dSync, HudString);
	}
	
	if(g_Player[id][WeaponHud] == 0)
	{
		if(!sk_get_logged(m_Index))
			return;
		new Len;
		new TempInv[InventorySystem]

		if(g_Player[m_Index][EquipmentedSkinArray] > 0)
			ArrayGetArray(g_Inventory, g_Player[m_Index][EquipmentedSkinArray], TempInv);

		if(TempInv[is_Nametaged] && g_Player[m_Index][EquipmentedSkinArray] > 0) 
			Len = formatex(HudString[Len], charsmax(HudString)- Len, "%s", TempInv[Nametag]);
		else
			Len = formatex(HudString[Len], charsmax(HudString)- Len, "%s", FegyverInfo[g_Player[m_Index][EquipmentedSkin]][GunName]);
		
		if(TempInv[is_StatTraked] && g_Player[m_Index][EquipmentedSkinArray] > 0)
			Len += formatex(HudString[Len], charsmax(HudString)- Len, "^nStatTrak* Ölések: %i", TempInv[StatTrakKills]); 

		set_hudmessage(FegyverInfo[g_Player[m_Index][EquipmentedSkin]][Color1], FegyverInfo[g_Player[m_Index][EquipmentedSkin]][Color2], FegyverInfo[g_Player[m_Index][EquipmentedSkin]][Color3], -1.0, 0.72, 0, 0.0, 1.0, 0.0, 0.0, next_hudchannel(id));
		ShowSyncHudMsg(id, aSync, HudString);
	}
}
public CmdSetVIP(id, level, cid)
{
	if(!str_to_num(Admin_Permissions[g_Player[id][AdminLvL]][3])){
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
			g_Player[Is_Online][is_Vip] = 1;
			g_Player[Is_Online][vipTime] = get_systime()+86400*Arg_Int[1]
			format_time(sztime, charsmax(sztime), "%Y.%m.%d - %H:%M:%S", g_Player[Is_Online][vipTime])
			client_print_color(0, print_team_default, "^3%s^1Játékos: ^3%s ^1(#^3%d^1) | VIP Tagságot kapott ^3%d^1 napra! ^3%s^1(#^3%d^1) által!", CHATPREFIX, g_Player[Is_Online][Name], Arg_Int[0], Arg_Int[1], szName,g_Player[id][UserId]);
			client_print_color(Is_Online, print_team_default, "^3%s^1Kaptál^4 %d Napra^1 szóló‚ ^3VIPet^1. ^3Lejár ekkor: ^4%s", CHATPREFIX, Arg_Int[1], sztime);	 
		}
		else 
		{
			client_print_color(0, print_team_default, "%sJátékos: ^3%s ^1(#^3%d^1) | VIP Tagság megvonva! ^3%s^1(#^3%d^1) által!", CHATPREFIX, g_Player[Is_Online][Name], Arg_Int[0], szName, g_Player[id][UserId]);	
			g_Player[Is_Online][vipTime] = 0;
			g_Player[Is_Online][is_Vip] = 0;
		}
	}
	else
		client_print(id, print_console, "A jatekos nincs fent!");
	
	return PLUGIN_HANDLED;
}
public Hook_Say(id){
	new Message[512], Status[16], String[256], Num[5];
	
	read_args(Message, charsmax(Message));
	remove_quotes(Message);
	new Message_Size = strlen(Message);
	
	for(new i; i < Message_Size; i++){
		if(Message[i] == '.')
			Num[0] ++;
		
		if(Message[i] == ':')
			Num[1] ++;
		
		if(Message[i] == '1' || Message[i] == '2' || Message[i] == '3' || Message[i] == '4' || Message[i] == '5'
		|| Message[i] == '6' || Message[i] == '7' || Message[i] == '8' || Message[i] == '9' || Message[i] == '0')
		Num[2] ++;
		
		if(Message[i] == 'w')
			Num[3] ++;

	}
	
	if((contain(Message, "www.") != -1)
	|| (contain(Message, "http://") != -1)
	|| (contain(Message, ".io") != -1)
	|| (contain(Message, ".tsdns.") != -1)
	|| (contain(Message, "ts3.run") != -1)
	|| (contain(Message, ".com") != -1)
	|| (contain(Message, ".ro") != -1)
	|| (contain(Message, ".hu") != -1))
	Num[4] = 1;
	
	if(Message[0] == '@' || equal (Message, "") || Message[0] == '/')
		return PLUGIN_HANDLED;
	
	if(!is_user_alive(id))
		Status = "*Halott* ";
	
	new len;
	
	len += formatex(String[len], charsmax(String)-len, "^1%s", Status);

	if(sk_get_logged(id))
	{
		if(g_Player[id][isPrefixed])
			len += formatex(String[len], charsmax(String)-len, "^1(^4%s^1) ", g_Player[id][ChatPrefix]);
	

		else if(g_Player[id][is_pVip] == 2)
			len += formatex(String[len], charsmax(String)-len, "^4[Prémium ^3VIP++^4]");
		else if(g_Player[id][is_Vip] > 0)
			len += formatex(String[len], charsmax(String)-len, "^4[^3VIP^4]");
		if(g_Player[id][AdminLvL] > 0 && g_Player[id][is_Inkodnitoed] == 0)
			len += formatex(String[len], charsmax(String)-len, "^4[%s]", Admin_Permissions[g_Player[id][AdminLvL]][0]);

		len += formatex(String[len], charsmax(String)-len, "^4[%s]", Rangok[g_Player[id][Rang]][RangName]);

		if(g_Player[id][is_pVip] > 0 || g_Player[id][is_Vip] == 1 || g_Player[id][AdminLvL] > 0 && g_Player[id][is_Inkodnitoed] == 0)
			len += formatex(String[len], charsmax(String)-len, "^3%s:^4", g_Player[id][Name]);
		else
			len += formatex(String[len], charsmax(String)-len, "^3%s:^1", g_Player[id][Name]);
	}
	else 
	{
		len += formatex(String[len], charsmax(String)-len, "^4[Nincs bejelentkezve]");
		len += formatex(String[len], charsmax(String)-len, "^3%s:^1", g_Player[id][Name]);
		client_print_color(id, print_team_default, "Jelentkezz be a [ T Betű ] megnyomásával!")
	}

	if(TrieKeyExists(sanklist, Message)) 
	{
		new srvtime = get_systime();
		
		if(srvtime >= g_iTime) {
				new szSound[64];
				TrieGetString(sanklist, Message, szSound, charsmax(szSound));
				playsound(szSound);
				g_iTime = (srvtime + 70);
		}
		else
			client_print_color(id, print_team_default, "^4%s^1Még várnod kell ^4%i^1 másodpercet, hogy hangot tudj lejátszani!", CHATPREFIX, (g_iTime - srvtime))
	}

	new sztime[40]
	format_time(sztime, charsmax(sztime), "%Y.%m.%d - %H:%M:%S", get_systime())
	LogCreate("NewChat", fmt("Date: %s | %s | AccountID: %i -- Játékos: %s | Üzenet: %s", sztime, g_Player[id][steamid], g_Player[id][UserId], g_Player[id][Name], Message))
	
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
playsound(const szSound[]) {
		new makesound[256];
		if(containi(szSound, ".mp3") != -1)
				formatex(makesound, charsmax(makesound), "mp3 play ^"sound/%s^"", szSound);
		else
				formatex(makesound, charsmax(makesound), "spk ^"%s^"", szSound);


		new players[32], num, tempid;
		get_players(players, num, "c");
		for(new i; i<num; i++) {
				tempid = players[i];
				if(g_Player[tempid][SanksOff] == 1)
						client_cmd(tempid, "%s", makesound);
		}
}
public CmdSetAdmin(id, level, cid){
	if(!str_to_num(Admin_Permissions[g_Player[id][AdminLvL]][2])){
		client_print_color(id, print_team_default, "%s ^3Nincs elérhetőséged^1 ehhez a parancshoz!", CHATPREFIX);
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
	
	formatex(Query, charsmax(Query), "UPDATE `herboy` SET `AdminLvl` = %d WHERE `ID` = %d;", Arg_Int[1], Arg_Int[0]);
	SQL_ThreadQuery(g_SqlTuple, "QuerySetData_Profiles", Query, Data, 1);
	
	if(Is_Online)
	{
		if(Arg_Int[1] > 0)
		{
			Set_Permissions(Is_Online);
			client_print_color(0, print_team_default, "%s^1Játékos: ^3%s ^1(#^3%d^1) | ^3%s^1 jogot kapott! ^3%s^1(#^3%d^1) által!", CHATPREFIX, g_Player[Is_Online][Name], Arg_Int[0], Admin_Permissions[Arg_Int[1]][0], g_Player[id][Name], g_Player[id][UserId]);	
		}
		else
		{
			Remove_Permissions(Is_Online);
			client_print_color(0, print_team_default, "%s^1Játékos: ^3%s ^1(#^3%d^1) | Jogok megvonva! ^3%s^1(#^3%d^1) által!", CHATPREFIX, g_Player[Is_Online][Name], Arg_Int[0], g_Player[id][Name], g_Player[id][UserId]);	
		}
		g_Player[Is_Online][AdminLvL] = Arg_Int[1];
	}
	else
	{
		if(Arg_Int[1] > 0)
		{
			client_print_color(0, print_team_default, "%s^1Játékos: ^3- ^1(#^3%d^1) | ^3%s^1 jogot kapott! ^3%s^1(#^3%d^1) által!", CHATPREFIX, Arg_Int[0], Admin_Permissions[Arg_Int[1]][0], g_Player[id][Name], g_Player[id][UserId]);	
		}
		else
		{
			client_print_color(0, print_team_default, "%s^1Játékos: ^3- ^1(#^3%d^1) | Jogok megvonva! ^3%s^1(#^3%d^1) által!", CHATPREFIX, Arg_Int[0], g_Player[id][Name], g_Player[id][UserId]);		
		}	
	}
		
	return PLUGIN_HANDLED;
}
public Set_Permissions(id){
	new Flags;
	Flags = read_flags(Admin_Permissions[g_Player[id][AdminLvL]][1]);
	set_user_flags(id, Flags);
}
public Remove_Permissions(id){
	new Flags;
	Flags = read_flags(Admin_Permissions[g_Player[id][AdminLvL]][1]);
	remove_user_flags(id, Flags);
}
stock Check_Id_Online(id){
	for(new idx = 0; idx <= g_Maxplayers; idx++){
		if(!is_user_connected(idx))
			continue;
					
		if(g_Player[idx][UserId] == id)
			return idx;
	}
	return 0;
}
public fegyvermenu(id)
{
	if(FegyverMenuTiltas == true)
		return;
	if(g_Player[id][BuyedWeap]){
		client_print_color(id, print_team_default, "^4%s^1Ebben a körben már választottál fegyvert!", CHATPREFIX);
		return;
	}
	
	new menu = menu_create("\rHerBoy Fegyvermenü", "weaphandler");
	new Inventory[InventorySystem];
	if(sk_get_logged(id))
	{
		ArrayGetArray(g_Inventory, SltGun[id][M4A1][1], Inventory)

		if(Inventory[is_Nametaged]) 
			menu_additem(menu, fmt("%s%s%s", Inventory[is_StatTraked] ? "\rStatTrak*\d - " : "", FegyverInfo[SltGun[id][M4A1][0]][Rarity], Inventory[Nametag]), "1", 0)
		else
			menu_additem(menu, fmt("%s%s%s", Inventory[is_StatTraked] ? "\rStatTrak*\d - " : "", FegyverInfo[SltGun[id][M4A1][0]][Rarity], FegyverInfo[SltGun[id][M4A1][0]][GunName]), "1", 0)

		ArrayGetArray(g_Inventory, SltGun[id][AK47][1], Inventory)

		if(Inventory[is_Nametaged]) 
			menu_additem(menu, fmt("%s%s%s", Inventory[is_StatTraked] ? "\rStatTrak*\d - " : "", FegyverInfo[SltGun[id][AK47][0]][Rarity], Inventory[Nametag]), "2", 0)
		else
			menu_additem(menu, fmt("%s%s%s", Inventory[is_StatTraked] ? "\rStatTrak*\d - " : "", FegyverInfo[SltGun[id][AK47][0]][Rarity], FegyverInfo[SltGun[id][AK47][0]][GunName]), "2", 0)

		ArrayGetArray(g_Inventory, SltGun[id][AWP][1], Inventory)

		if(Inventory[is_Nametaged]) 
			menu_additem(menu, fmt("%s%s%s", Inventory[is_StatTraked] ? "\rStatTrak*\d - " : "", FegyverInfo[SltGun[id][AWP][0]][Rarity], Inventory[Nametag]), "3", 0)
		else
			menu_additem(menu, fmt("%s%s%s", Inventory[is_StatTraked] ? "\rStatTrak*\d - " : "", FegyverInfo[SltGun[id][AWP][0]][Rarity], FegyverInfo[SltGun[id][AWP][0]][GunName]), "3", 0)
	}
	else
	{
		menu_additem(menu, "\wAK47", "1", 0);
		menu_additem(menu, "\wM4A1", "2", 0);
		menu_additem(menu, "\wAWP", "3", 0);
	}

	menu_additem(menu, "\wMachineGun", "4", 0);
	menu_additem(menu, "\wAUG", "5", 0);
	menu_additem(menu, "\wFAMAS", "6", 0);
	menu_additem(menu, fmt("\wGALIL^n^nKés: %s%s^n\wDeagle: %s%s", FegyverInfo[SltGun[id][KNIFE][0]][Rarity], FegyverInfo[SltGun[id][KNIFE][0]][GunName], FegyverInfo[SltGun[id][DG][0]][Rarity], FegyverInfo[SltGun[id][DG][0]][GunName]), "7", 0);
	menu_additem(menu, "\wMP5", "8", 0);
	menu_additem(menu, "\wXM1014 Shotgun", "9", 0);
	menu_additem(menu, "\wM3 Shotgun", "10", 0);
	menu_additem(menu, "\wScout", "11", 0);
	menu_additem(menu, "\wMAC 10", "12", 0);
	menu_additem(menu, "\wTMP", "13", 0);
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	menu_display(id, menu);
}
public weaphandler(id, menu, item)
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
			
			give_item(id, "weapon_m4a1");
			give_item(id, "item_kevlar");
			
			give_item(id, "ammo_556nato");
			give_item(id, "ammo_556nato");
			give_item(id, "ammo_556nato");
			cs_set_user_bpammo(id, CSW_M4A1, 100)
			client_print_color(id, print_team_default, "^4%s^1Kaptál egy ^3M4A1^1 fegyvert!", CHATPREFIX);
		}
		case 2:
		{
			
			give_player_grenades(id);
			give_item(id, "weapon_knife");
			give_item(id, "weapon_ak47");
			give_item(id, "item_kevlar");
			give_item(id, "ammo_762nato");
			give_item(id, "ammo_762nato");
			
			give_item(id, "ammo_762nato");
			cs_set_user_bpammo(id, CSW_AK47, 100)
			client_print_color(id, print_team_default, "^4%s^1Kaptál egy ^3AK47^1 fegyvert!", CHATPREFIX);
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
			if(tt_num >=4 && ct_num >= 4)
			{
				if(userTeam == CS_TEAM_CT)
				{
					if(gWPCT < 2)
					{
						GiveAWP(id, CS_TEAM_T); //KovaCode
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
						GiveAWP(id, CS_TEAM_T); //KovaCode
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
			cs_set_user_bpammo(id, CSW_M249, 100)
			client_print_color(id, print_team_default, "^4%s^1Kaptál egy ^3MachineGun^1 fegyvert!", CHATPREFIX);
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
			cs_set_user_bpammo(id, CSW_AUG, 100)
			client_print_color(id, print_team_default, "^4%s^1Kaptál egy ^3AUG^1 fegyvert!", CHATPREFIX);
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
			cs_set_user_bpammo(id, CSW_FAMAS, 100)
			client_print_color(id, print_team_default, "^4%s^1Kaptál egy ^3Famas^1 fegyvert!", CHATPREFIX);
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
			cs_set_user_bpammo(id, CSW_GALIL, 100)
			client_print_color(id, print_team_default, "^4%s^1Kaptál egy ^3Galil^1 fegyvert!", CHATPREFIX);
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
			cs_set_user_bpammo(id, CSW_MP5NAVY, 100)
			client_print_color(id, print_team_default, "^4%s^1Kaptál egy ^3SMG^1 fegyvert!", CHATPREFIX);
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
			cs_set_user_bpammo(id, CSW_XM1014, 100)
			client_print_color(id, print_team_default, "^4%s^1Kaptál egy ^3AutoShotgun^1 fegyvert!", CHATPREFIX);
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
			cs_set_user_bpammo(id, CSW_M3, 100)
			client_print_color(id, print_team_default, "^4%s^1Kaptál egy ^3Shotgun^1 fegyvert!", CHATPREFIX);
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
			cs_set_user_bpammo(id, CSW_SCOUT, 100)
			client_print_color(id, print_team_default, "^4%s^1Kaptál egy ^3Scout^1 fegyvert!", CHATPREFIX);
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
			cs_set_user_bpammo(id, CSW_MAC10, 100)
			client_print_color(id, print_team_default, "^4%s^1Kaptál egy ^3Pityókahámozó^1 fegyvert!", CHATPREFIX);
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
			cs_set_user_bpammo(id, CSW_TMP, 260)
			client_print_color(id, print_team_default, "^4%s^1Kaptál egy ^3Pityókahámozó^1 fegyvert!", CHATPREFIX);
		}
	}

	if(key != 3)//KovaCode
		if(g_Player[id][UsedAWP] > 0)
			g_Player[id][UsedAWP]--;

	return PLUGIN_HANDLED;
}

public GiveAWP(id, CS_TEAM) //KovaCode
{
	if(g_Player[id][UsedAWP] > 5)
	{
		client_print_color(id, print_team_default, "^4%s^1Túl sokszor AWP-ztél, hagyd játszani a többieket is AWP-vel!", CHATPREFIX);
		fegyvermenu(id);
		return;
	}
	g_Player[id][UsedAWP]++;

	if(CS_TEAM == CS_TEAM_T)
		gWPTE++;
	else if(CS_TEAM == CS_TEAM_CT)
		gWPCT++;

	give_player_grenades(id);
	give_item(id, "weapon_knife");
	give_item(id, "weapon_awp");
	give_item(id, "item_kevlar");
	give_item(id, "ammo_338magnum");
	give_item(id, "ammo_338magnum");
	give_item(id, "ammo_338magnum");
	cs_set_user_bpammo(id, CSW_AWP, 100)
	set_user_armor(id, 100);
	client_print_color(id, print_team_default, "^4%s^1Kaptál egy ^3AWP^1 fegyvert!", CHATPREFIX);
}

stock give_player_grenades(index)
{
	give_item(index, "weapon_hegrenade");
	give_item(index, "weapon_flashbang");
	give_item(index, "item_thighpack");
	give_item(index, "weapon_deagle");
	g_Player[index][BuyedWeap] = 1;
	cs_set_user_bpammo(index,CSW_DEAGLE,50);
	if(g_Player[index][is_pVip] > 0)
	{
		give_item(index, "weapon_smokegrenade");
		client_print_color(index, print_team_default, "^4%s^1Kaptál egy ^3SMOKE^1 gránátot, mert ^3Prémium VIP^1 tagsággal rendelkezel!", CHATPREFIX);
	}
}
public client_connect(id)
{
	client_cmd(id, "fs_lazy_precache 1");
	engclient_cmd(id, "fs_lazy_precache 1");
}
public client_putinserver(id)
{
	new ConnectTime[32]
	format_time(ConnectTime, charsmax(ConnectTime), "%Y.%m.%d - %H:%M:%S", get_systime())
	copy(g_Player[id][LastConnectTime], 32, ConnectTime)
	get_user_name(id, g_Player[id][Name], 32);
	get_user_authid(id, g_Player[id][steamid], 32);
	Player_Stats[id][wKills] = 0;
	Player_Stats[id][wHSs] = 0;
	Player_Stats[id][wDeaths] = 0;
	Player_Stats[id][wAllHitCount] = 0;
	Player_Stats[id][wAllShotCount] = 0;
	g_Player[id][PlayedCount] = 0;
	g_Player[id][MarketSelected] = -1;
	g_Player[id][BuyVIPDay] = 1;
	g_Player[id][SelectedToTools] = -1;
	g_Player[id][SelectedForDelete] = -1;
	g_Player[id][openSelectItemRow] = 0;
	g_Player[id][DeletType] = 0;
	g_Player[id][SelectedCTSkin] = -1;
	g_Player[id][SelectedTSkin] = -1;
	g_Player[id][FragKills] = 0;
	g_Player[id][PorgetTime] = 0;

	FirstJoin[id] = 0;
	Market[id][m_SelectedToPlace] = -1;

	for(new i = 0; i <= g_Maxplayers; ++i)
		g_Mute[id][i] = 0
}
public MarketMenu(id)
{
	new gmString[121]
	formatex(gmString, charsmax(gmString), "%s^n \wPiac | Eladás^nDollár: \d%3.2f$", MENUPREFIX, g_Player[id][Dollar])
	new menu = menu_create(gmString, "hEladas");

	new Inventory[InventorySystem];
	if(Market[id][m_SelectedToPlace] == -1)
		menu_additem(menu,"\dElőbb válassz ki egy fegyvert! \d(\w1-es gomb!\d)","1",0)
	else
	{
		ArrayGetArray(g_Inventory, Market[id][m_SelectedToPlace], Inventory);
		if(Inventory[w_id] > 4)
		{
			formatex(gmString, charsmax(gmString), "Fegyver név: %s%s", FegyverInfo[Inventory[w_id]][Rarity], FegyverInfo[Inventory[w_id]][GunName]);
			menu_additem(menu, gmString, "1", 0);
		}
		else
			menu_additem(menu,"\dAlap fegyvereket nem rakhatsz ki piacra!","1",0)

		if(Inventory[is_StatTraked])
			menu_addtext2(menu, fmt("\wStatTrak\y*\w: \rVan \d| \wÖlések: \r%i", Inventory[StatTrakKills]))
		else
			menu_addtext2(menu, fmt("\wStatTrak\y*\w: \dNincs"))

		if(Inventory[is_Nametaged])
			menu_addtext2(menu, fmt("\wNévcédula\w: \r%s", Inventory[Nametag]))
		else
			menu_addtext2(menu, fmt("\wNévcédula\w: \dNincs"))
	}
	if(Market[id][m_Cost] > 1)
	{
		formatex(gmString, charsmax(gmString), "Eladási Ár: \r%3.2f$^n", Market[id][m_Cost])
		menu_additem(menu, gmString, "2",0)
	}
	else
		menu_addblank2(menu);
	
	if(Inventory[w_tradable] == 0)
		menu_additem(menu,"\rEz az item nem eladható.","-1",0)
	else if(Market[id][m_Cost] < 1)
		menu_additem(menu,"\dÍrj be egy árat!","2",0)
	else
		menu_additem(menu, "\yKihelyezés a piacra", "3", 0)

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
		case -1: MarketMenu(id);
		case 1: 
		{
			openMarketSwitch(id);
			g_Player[id][openSelectItemRow] = 1;
		}
		case 2: client_cmd(id, "messagemode DOLLAR_AR")
		case 3: PlaceOnMarket(id, Market[id][m_SelectedToPlace], Market[id][m_Cost])
	}
	menu_destroy(menu)
	return PLUGIN_HANDLED
}
public openMarketSwitch(id)
{
	new Menu[512], MenuString[128], MenuKey
	format(MenuString, 127, "%s^n\wVálassz ki egy skin típust!^n^n", MENUPREFIX);
	add(Menu, 511, MenuString);
	
	format(MenuString, 127, fmt("\r1. \wAK47 \rSkinek^n"))
	add(Menu, 511, MenuString);
	format(MenuString, 127, fmt("\r2. \wM4A1 \rSkinek^n"))
	add(Menu, 511, MenuString);
	format(MenuString, 127, fmt("\r3. \wAWP \rSkinek^n"))
	add(Menu, 511, MenuString);
	format(MenuString, 127, fmt("\r4. \wDEAGLE \rSkinek^n"))
	add(Menu, 511, MenuString);
	format(MenuString, 127, fmt("\r5. \wKÉS \rSkinek^n^n\r0. \wKilépés a menüből."))
	add(Menu, 511, MenuString);

	MenuKey = (1<<0 | 1<<1 | 1<<2 | 1<<3 | 1<<4 | 1<<5 | 1<<6 | 1<<7 | 1<<8 | 1<<9);
	show_menu(id, MenuKey, Menu, -1, "MARKETMENU");
	return PLUGIN_CONTINUE
}
public hMarketMenu(id, MenuKey)
{
	MenuKey++;
	switch(MenuKey)
	{
		case 1: openSelectItem(id, CSW_AK47)
		case 2: openSelectItem(id, CSW_M4A1)
		case 3: openSelectItem(id, CSW_AWP)
		case 4: openSelectItem(id, CSW_DEAGLE)
		case 5: openSelectItem(id, CSW_KNIFE)
		default:{
			show_menu(id, 0, "^n", 1);
			return
		}
	}
}
public cmdDollarEladas(id) {
	new Float:iErtek, iAdatok[32]
	read_args(iAdatok, charsmax(iAdatok))
	remove_quotes(iAdatok)
			
	iErtek = str_to_float(iAdatok)		
			
	if(iErtek > 100000.0) {
		client_print_color(id, print_team_default, "^4%s^1Nem tudsz eladni^3 100000.00$ ^1felett!", CHATPREFIX)
		client_cmd(id, "messagemode DOLLAR_AR")
	}
	else if(iErtek < 0.01) {
		client_print_color(id, print_team_default, "^4%s^1Nem tudsz eladni^3 0.01$ ^1alatt!", CHATPREFIX)
		client_cmd(id, "messagemode DOLLAR_AR")
	}
	else {
		Market[id][m_Cost] = iErtek + 0.009
		MarketMenu(id)
	}
}
public openSelectItem(id, entName) //openSelectItem(id, casekey, FEGYVERKEY) 
{
	new szMenu[256],String[6]
	formatex(szMenu, charsmax(szMenu), "%s Fegyver választás", MENUPREFIX)
	new menu = menu_create(szMenu, "hSelectItem");

	new InventorySizeof = ArraySize(g_Inventory);
	new Inventory[InventorySystem];

	for(new i = 0; i < InventorySizeof;i++)
	{
		new len;
		ArrayGetArray(g_Inventory, i, Inventory);

		if(Inventory[w_userid] != g_Player[id][UserId])
			continue;

		if(FegyverInfo[Inventory[w_id]][EntName][0] == entName && Inventory[w_deleted] == 0 && Inventory[w_tradable] == 1)
		{
			if(Inventory[w_equipped])
				len += formatex(szMenu[len], charsmax(szMenu) - len, "\r!\d - ");

			if(Inventory[is_StatTraked])
				len += formatex(szMenu[len], charsmax(szMenu) - len, "\yStatTrak\r* \d- ");

			if(Inventory[is_Nametaged])
				len += formatex(szMenu[len], charsmax(szMenu) - len, "%s%s", FegyverInfo[Inventory[w_id]][Rarity], Inventory[Nametag]);
			else
				len += formatex(szMenu[len], charsmax(szMenu) - len, "%s%s", FegyverInfo[Inventory[w_id]][Rarity], FegyverInfo[Inventory[w_id]][GunName]);

			num_to_str(i, String, 5);
			menu_additem(menu, szMenu, String);
		}
	}

	menu_display(id, menu, 0)
}
public hSelectItem(id, menu, item) {
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED
	}

	new data[9], szName[64]
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName, charsmax(szName), callback);
	new key = str_to_num(data);
	new Inventory[InventorySystem]
	ArrayGetArray(g_Inventory, key, Inventory)

	if(Inventory[w_equipped])
	{
		client_print_color(id, print_team_default, "^4%s^1Előbb ^4szereld le^1 a ^3fegyvered^1 a raktárban, és próbáld újra!", CHATPREFIX)
		menu_destroy(menu)
		return PLUGIN_HANDLED;
	}
	
	switch(g_Player[id][openSelectItemRow])
	{
		case 1:
		{
			Market[id][m_SelectedToPlace] = key
			MarketMenu(id)
		}
		case 2:
		{
			g_Player[id][SelectedToTools] = key
			openToolsMenu(id)
		}
		case 3:
		{
			Inventory[w_equipped] = 0;
			Inventory[Changed] = 1;
			Inventory[w_userid] = g_Player[g_Player[id][SendTemp]][UserId]

			if(Inventory[is_Nametaged])
				client_print_color(0, print_team_default, "^4%s^1Játékos: ^4%s^1 küldött ^4%s^1-nek egy ^3%s%s^1 fegyvert.", CHATPREFIX, g_Player[id][Name], g_Player[g_Player[id][SendTemp]][Name], Inventory[is_StatTraked] ? "StatTrak* " : "", Inventory[Nametag]);
			else
				client_print_color(0, print_team_default, "^4%s^1Játékos: ^4%s^1 küldött ^4%s^1-nek egy ^3%s%s^1 fegyvert.", CHATPREFIX, g_Player[id][Name], g_Player[g_Player[id][SendTemp]][Name], Inventory[is_StatTraked] ? "StatTrak* " : "", FegyverInfo[Inventory[w_id]][GunName]);
			
			ArraySetArray(g_Inventory, key, Inventory)
			//UpdateItem(id, 1, 4, 0, g_Player[id][SendTemp], Inventory[w_id], Inventory[is_Nametaged], Inventory[Nametag], Inventory[is_StatTraked], Inventory[StatTrakKills], Inventory[w_tradable], Inventory[w_equipped], Inventory[sqlid], Inventory[w_systime], Inventory[w_deleted])
			g_Player[id][openSelectItemRow] = 0;
		}
	}
	
	menu_destroy(menu)
	return PLUGIN_HANDLED
}
public openBuyer1(id) {		
	new String[256], NumStr[9];
	static temp[10]

	new ProductsSizeof = ArraySize(g_Products);
	new MarketProduct[MarketSys];
		
	formatex(String, charsmax(String), "%s^n \wPiac | Fegyver Vásárlás^nDollár: \d%3.2f", MENUPREFIX, g_Player[id][Dollar])
	new menu = menu_create(String, "hBuyItems1");

	for(new i = 0; i < ProductsSizeof;i++)
	{
		ArrayGetArray(g_Products, i, MarketProduct);

		if(get_systime() >= MarketProduct[MarketProductTime] && MarketProduct[m_Cost] > 0)
		{
			ReturnMarket(i);
			continue;
		}

		new len;
		if(MarketProduct[m_Cost] > 0)
		{
			len += formatex(String[len], charsmax(String) - len, "\w%s", FegyverInfo[MarketProduct[m_WeaponId]][GunName]);

			if(MarketProduct[m_Is_StatTraked])
				len += formatex(String[len], charsmax(String) - len, " \rST*");

			if(MarketProduct[m_Is_Nametaged])
				len += formatex(String[len], charsmax(String) - len, " \yNévcédula*");

				len += formatex(String[len], charsmax(String) - len, " \d[\yÁr: \r%3.2f\r$\d]", MarketProduct[m_Cost]);


			num_to_str(i, NumStr, 8);

			//if(contain(String, Searchtype))
			menu_additem(menu, String, NumStr, 0);
		}

	}

	menu_display(id, menu, 0); 
}
public hBuyItems1(id, menu, item)
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

	g_Player[id][MarketSelected] = key;
	MarketInfoProduct(id);
}
public MarketInfoProduct(id)
{
	new String[256], StringTime[31], NumStr[9];
		
	formatex(String, charsmax(String), "%s^n \wPiac | Fegyver Vásárlás^nDollár: \d%3.2f", MENUPREFIX, g_Player[id][Dollar])
	new menu = menu_create(String, "MarketInfo_buyhandler");

	new MarketProduct[MarketSys];
	ArrayGetArray(g_Products, g_Player[id][MarketSelected], MarketProduct);
		
	format_time(StringTime, 31, "%Y/%m/%d - %H:%M:%S", MarketProduct[MarketProductTime])
	menu_addtext2(menu, fmt("\wFegyver neve: %s%s", FegyverInfo[MarketProduct[m_WeaponId]][Rarity], FegyverInfo[MarketProduct[m_WeaponId]][GunName]))
	menu_addtext2(menu, fmt("\wTörlés a piacról: \r%s", StringTime))
	menu_addtext2(menu, fmt("\wEladó: \r%s", MarketProduct[m_SellerName]))

	if(MarketProduct[m_Is_Nametaged])
		menu_addtext2(menu, fmt("\wNévcédula: \r^"%s^"", MarketProduct[m_Nametag]))
	else
		menu_addtext2(menu, fmt("\wNévcédula: \dNincs"))

	menu_addtext2(menu, fmt("\wStatTrak\y*: %s \d(\yÖlések: \r%i\d)^n", MarketProduct[m_Is_StatTraked] ? "\rVan" : "\dNincs", MarketProduct[m_STKills]))

	if(MarketProduct[m_SellerId] == g_Player[id][UserId])
	{
		menu_additem(menu, "Fegyver visszavonása a Piacról", "1", 0)
	}
	else
	{
		if(MarketProduct[m_Cost] <= g_Player[id][Dollar])
			menu_additem(menu, fmt("\yVásárlás \d[\yÁr: \r%3.2f\d]", MarketProduct[m_Cost]), "2", 0)
		else
			menu_additem(menu, fmt("\dVásárlás \d[\yÁr: \r%3.2f\d]", MarketProduct[m_Cost]), "-1", 0)
	}
	menu_display(id, menu, 0); 
}
public MarketInfo_buyhandler(id,menu,item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}

	new data[6], szName[64]
	new access, callback;

	menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);	
	new key = str_to_num(data);	

	switch(key)
	{
		case -1: 
		{
			client_print_color(id, print_team_default, "^4%s^1Nincs elég egyenleged, hogy megvásárold ezt a skint!", CHATPREFIX);
			openBuyer1(id);
		}
		case 1: ReturnMarket(g_Player[id][MarketSelected])
		case 2: BuyFromMarket(id, g_Player[id][MarketSelected])
	}
	menu_destroy(id);
}
public ReturnMarket(MarketSlot)
{
	new MarketProduct[MarketSys];
	ArrayGetArray(g_Products, MarketSlot, MarketProduct);

	new Seller_id = UserOnline(MarketProduct[m_SellerId]);
	
	if(Seller_id != -1)
	{
		new Inventory[InventorySystem]
		Inventory[sqlid] = -1;
		Inventory[w_id] = MarketProduct[m_WeaponId];
		Inventory[w_userid] = MarketProduct[m_SellerId]
		Inventory[is_StatTraked] = MarketProduct[m_Is_StatTraked];
		Inventory[StatTrakKills] = MarketProduct[m_STKills];
		Inventory[is_Nametaged] = MarketProduct[m_Is_Nametaged];
		copy(Inventory[Nametag], 100, MarketProduct[m_Nametag]) 
		Inventory[w_deleted] = 0;
		Inventory[w_equipped] = 0;
		Inventory[w_tradable] = 1;
		Inventory[Changed] = 1;
		new arryid = ArrayPushArray(g_Inventory, Inventory);

		//UpdateItem(Seller_id, 1, 1, arryid, g_Player[Seller_id][UserId], MarketProduct[m_WeaponId], MarketProduct[m_Is_Nametaged], MarketProduct[m_Nametag], MarketProduct[m_Is_StatTraked], 0, 1, 0, -1, get_systime(), 0)
		client_print_color(Seller_id, print_team_default, "^4%s^1A(z) ^3%s %s^1 fegyvered visszakerült a raktáradba, mert visszavontad, vagy lejárt az ideje!", CHATPREFIX, MarketProduct[is_StatTraked] ? "StatTrak*" : "", FegyverInfo[MarketProduct[m_WeaponId]][GunName]);
	}
	else
	{
		new Len, Query[3072]
		Len += formatex(Query[Len], charsmax(Query)-Len, "INSERT INTO `inventory` (`w_userid`,`w_id`,`Is_NameTaged`,`NameTag`,`Is_StatTraked`,`StatTrak_Kills`,`Tradable`,`Equiped`) VALUES (");
		Len += formatex(Query[Len], charsmax(Query)-Len, "%i,", MarketProduct[m_SellerId]);
		Len += formatex(Query[Len], charsmax(Query)-Len, "%i,", MarketProduct[m_WeaponId]);
		Len += formatex(Query[Len], charsmax(Query)-Len, "%i,", MarketProduct[m_Is_Nametaged]);
		Len += formatex(Query[Len], charsmax(Query)-Len, "^"%s^",", MarketProduct[m_Nametag]);
		Len += formatex(Query[Len], charsmax(Query)-Len, "%i,", MarketProduct[m_Is_StatTraked]);
		Len += formatex(Query[Len], charsmax(Query)-Len, "%i,", MarketProduct[m_STKills]);
		Len += formatex(Query[Len], charsmax(Query)-Len, "1,");
		Len += formatex(Query[Len], charsmax(Query)-Len, "0);");
		SQL_ThreadQuery(g_SqlTuple, "QuerySetData_Market", Query);
	}

	MarketProduct[m_Cost] = -1.0;
	ArraySetArray(g_Products, MarketSlot, MarketProduct);
}
public BuyFromMarket(id, BuyedMarketSlot)
{
	new MarketProduct[MarketSys];
	new Inventory[InventorySystem]
	ArrayGetArray(g_Products, BuyedMarketSlot, MarketProduct);

	if(MarketProduct[m_Cost] < 0)
	{
		client_print_color(id, print_team_default, "^4%s^1A fegyvert amelyet megszerettél volna venni ^3nem elérhető már^1 a piacon!", CHATPREFIX);
		openBuyer1(id);
		return;
	}

	new Seller_id = UserOnline(MarketProduct[m_SellerId]);
	if(Seller_id != -1)
	{
		g_Player[Seller_id][Dollar] += MarketProduct[m_Cost];
	}
	else
		OfflineReward(MarketProduct[m_SellerId], MarketProduct[m_Cost]);

	client_print_color(0, print_team_default, "^4%s^1Játékos: ^4%s^1 vett egy ^3%s %s^1 fegyvert ^3%s^1-tól/től ^4%3.2f^3 dollárért!", CHATPREFIX, g_Player[id][Name], MarketProduct[m_Is_StatTraked] ? "StatTrak*" : "", FegyverInfo[MarketProduct[m_WeaponId]][GunName], MarketProduct[m_SellerName], MarketProduct[m_Cost]);
	
	Inventory[sqlid] = -1;
	Inventory[w_id] = MarketProduct[m_WeaponId];
	Inventory[w_userid] = g_Player[id][UserId];
	Inventory[is_StatTraked] = MarketProduct[m_Is_StatTraked];
	Inventory[StatTrakKills] = 0;
	Inventory[is_Nametaged] = MarketProduct[m_Is_Nametaged];
	copy(Inventory[Nametag], 100, MarketProduct[m_Nametag]) 
	Inventory[w_deleted] = 0;
	Inventory[w_tradable] = 1;
	Inventory[w_equipped] = 0;
	Inventory[Changed] = 1;

	g_Player[id][Dollar] -= MarketProduct[m_Cost];
	MarketProduct[m_Cost] = -1.0;

	new arryid = ArrayPushArray(g_Inventory, Inventory);

	//UpdateItem(id, 1, 1, arryid, g_Player[id][UserId], MarketProduct[m_WeaponId], MarketProduct[m_Is_Nametaged], MarketProduct[m_Nametag], MarketProduct[m_Is_StatTraked], 0, 1, 0, -1, get_systime(), 0)
	ArraySetArray(g_Products, BuyedMarketSlot, MarketProduct);
}
public PlaceOnMarket(id, SelectedWeapon, FloatWtround)
{
	new MarketProduct[MarketSys];
	new Inventory[InventorySystem]

	ArrayGetArray(g_Inventory, SelectedWeapon, Inventory)
	MarketProduct[MarketProductTime] = get_systime()+86400*3;
	MarketProduct[m_sqlid] = -1;
	MarketProduct[m_Cost] = FloatWtround
	copy(MarketProduct[m_SellerName], 33, g_Player[id][Name]) 
	MarketProduct[m_SellerId] = g_Player[id][UserId];
	MarketProduct[m_WeaponId] = Inventory[w_id];
	MarketProduct[m_Is_StatTraked] = Inventory[is_StatTraked];
	MarketProduct[m_STKills] = Inventory[StatTrakKills];
	Inventory[w_equipped] = 0;
	Inventory[Changed] = 1;
	Inventory[w_deleted] = 1;

	if(Inventory[is_Nametaged])
	{
		copy(MarketProduct[m_Nametag], 100, Inventory[Nametag]);
		MarketProduct[m_Is_Nametaged] = 1;
	}
	else
		MarketProduct[m_Is_Nametaged] = 0;

	client_print_color(0, print_team_default, "^4%s^1Játékos: ^4%s^1 kirakott egy ^3%s %s^1 fegyvert ^4%3.2f^3 dollárért!", CHATPREFIX, g_Player[id][Name], MarketProduct[m_Is_StatTraked] ? "StatTrak*" : "", FegyverInfo[MarketProduct[m_WeaponId]][GunName], MarketProduct[m_Cost]);
	
	ArraySetArray(g_Inventory, SelectedWeapon, Inventory);
	ArrayPushArray(g_Products, MarketProduct);

	Market[id][m_SelectedToPlace] = -1;
	Market[id][m_Cost] = 0.0;
	//UpdateItem(id, 1, 6, 0, 0, 0, 0, "", 0, 0, 1, 0, Inventory[sqlid], get_systime(), 1)
}
public UserOnline(User_id)
{
	new foundid = -1;
	for(new i = 1;i < 33;i++)
	{
		if(is_user_connected(i))
			if(g_Player[i][UserId] == User_id)
			{
				foundid = i;
				break;
			}
	}

	return foundid;
}
new foundsql[33] = -1, allowreturn[33] = 0;
public GetSQLID(id, usr, wpid, wpnametaged, wpstatraked, wptradable, wpsystime, arrayid, folyamatban)
{
	new Query[1024];
	new Data[2]
	Data[0] = id;
	Data[1] = arrayid;
	client_print_color(id, print_team_default, "DEBUG: Beléptem SQLID: Foly: %i, foundsql: %i", folyamatban, foundsql[id])
	client_print_color(id, print_team_default, "SELECT * FROM `inventory` WHERE `w_userid` = %i AND `w_id` = %i AND `Is_NameTaged` = %i AND `Is_StatTraked` = %i AND `Tradable` = %i AND `systime` = %d LIMIT 1;", usr, wpid, wpnametaged, wpstatraked, wptradable, wpsystime)

	if(folyamatban == 1)
	{
		formatex(Query, charsmax(Query), "SELECT * FROM `inventory` WHERE `w_userid` = %i AND `w_id` = %i AND `Is_NameTaged` = %i AND `Is_StatTraked` = %i AND `Tradable` = %i AND `systime` = %d LIMIT 1;", usr, wpid, wpnametaged, wpstatraked, wptradable, wpsystime)
		SQL_ThreadQuery(g_SqlTuple, "QuerySqlId", Query, Data, 2);
		folyamatban = 2;
		client_print_color(id, print_team_default, "DEBUG: Beléptem SQLID: Foly: %i, foundsql: %i", folyamatban, foundsql[id])
	}
	else if(allowreturn[id] == 1)
		return 0;

	return foundsql[id]

}
public QuerySqlId(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime)
{
	new id = Data[0]
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED)
	{
		log_amx("%s", Error);
		client_print_color(id, print_team_default, "^3SQL Error: ^4%s", Error)
		return;
	}
	else
	{
		
		if(SQL_NumRows(Query) > 0)
		{
			new arry = Data[1]
			foundsql[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "SQLID"));
			allowreturn[id] = 2

			new Inventory[InventorySystem];
			ArrayGetArray(g_Inventory, arry, Inventory);

			Inventory[sqlid] = foundsql[id];
			ArraySetArray(g_Inventory, arry, Inventory);

			client_print_color(id, print_team_default, "DEBUG GETSQLID: sqlid: %i", Inventory[sqlid])
		}
		else
		client_print_color(id, print_team_default, "DEBUG NEMTALÁLTAM")
	}
		client_print_color(id, print_team_default, "^3SQL Debug: ^4Beléptem cica")
	return;
}
public Load_User_Data(id)
{
	log_amx("asdadasdasdasdasdasdasdasdadasdasda")
	g_Player[id][UserId] = sk_get_accountid(id)
	static Query[20048];
	new Data[2];
	Data[0] = id;
	Data[1] = get_user_userid(id); 
	formatex(Query, charsmax(Query), "SELECT * FROM `herboy` WHERE `ID` = %d;", g_Player[id][UserId]);
	SQL_ThreadQuery(g_SqlTuple, "QuerySelectProfiles", Query, Data, 2);
}
public QuerySelectProfiles(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime) {
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) {
		log_amx("%s", Error);
		return;
	}
	else {
		new id = Data[0];
		
		if(SQL_NumRows(Query) > 0) {
			SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Dollar"), g_Player[id][Dollar]);
			SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "exp2"), g_Player[id][rXP]);
			FirstJoin[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "FirstJoin"));
			g_Player[id][eloPoints] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "elopoints"));
			g_Player[id][Wins] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Wins"));
			g_Player[id][ProfilRank] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "KSzint"));
			g_Player[id][PlayTime] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Masodpercek"));		
			g_Player[id][HS] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "HS"));
			g_Player[id][Kills] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Oles"));	
			g_Player[id][eloPoints] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "elo_points"));
			g_Player[id][Deaths] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Halal"));
			g_Player[id][NametagTool] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Nametag_Tool"));
			g_Player[id][StatTrakTool] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "ST_Tool"));
			g_Player[id][PremiumPont] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "PotyiPont"));
			g_Player[id][vipTime] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "vip_time"));
			g_Player[id][pvipTime] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "premiumvip_time"));
			g_Player[id][is_Vip] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "isVip"));
			g_Player[id][is_pVip] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "is_pVip"));
			g_Player[id][AdminLvL] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "AdminLvl"));
			g_Player[id][SkinOnOff] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "SkinOff"));
			g_Player[id][HudOff] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "HudOff"));
			g_Player[id][WeaponHud] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "WeapHud"));
			g_Player[id][RoundEndSound] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "RoundSounds"));
			g_Player[id][UltimateSound] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "UltimateSounds"));
			g_Player[id][is_Inkodnitoed] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Inkognitoed"));
			g_Player[id][PlayTime] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Masodpercek"));
			g_Player[id][Rang] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Rang"));
			g_Player[id][BattlePass_Level] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "BattlePass_Level"));
			g_Player[id][BattlePass_Purchased] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "BattlePass_Purchased"));
			g_Player[id][NyeremenyKills] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "NyOles7"));
			g_Player[id][isPrefixed] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "HavePrefix"));
			TippKey[id][HaveKey] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "TippKey"));
			g_Player[id][SelectedMusicKit] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "SelectedMusicKit"));
			SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "ChatPrefix"), g_Player[id][ChatPrefix], 16);
			g_Player[id][PorgetTime] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "PorgetTime"));
			g_Player[id][SanksOff] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "SanksOff"));

			for(new i;i < sizeof(Cases); i++)
			{
				new String[64];
				formatex(String, charsmax(String), "Case%d", i);
				Case[id][i] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, String));
			}
			
			for(new i;i < sizeof(Cases); i++)
			{
				new String[64];
				formatex(String, charsmax(String), "Key%d", i);
				Key[id][i] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, String));
			}

			SltGun[id][AK47][0] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Skin0"));
			SltGun[id][M4A1][0] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Skin1"));
			SltGun[id][AWP][0] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Skin2"));
			SltGun[id][DG][0] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Skin3"));
			SltGun[id][KNIFE][0] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Skin4"));

			g_Player[id][isPrefixed] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "HavePrefix"));

			Set_Permissions(id);
			LoadInventory(id)
			LoadRankSys(id)
			LoadMusicKits(id)
		}
	}
}
public LoadRankSys(id)
{
	static Query[20048];
	new Data[2];
	Data[0] = id;
	Data[1] = get_user_userid(id); 
	formatex(Query, charsmax(Query), "SELECT * FROM `playerstats2` WHERE `User_Id` = %d;", g_Player[id][UserId]);
	SQL_ThreadQuery(g_SqlTuple, "TablaAdatValasztas_PlayerStats", Query, Data, 2);
}
public sql_create_music_row(id){
	static Query[10048];
	formatex(Query, charsmax(Query), "INSERT INTO `MusicKits` (`User_Id`) VALUES (%d);", g_Player[id][UserId]);
	SQL_ThreadQuery(g_SqlTuple, "QuerySetData", Query);

	LoadMusicKits(id);
}
public QuerySetData(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime){
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) {
		log_amx("%s", Error);
		return;
	}
}
public OfflineReward(User_id, m_Price)
{
	new Query[1024];
	formatex(Query, charsmax(Query), "UPDATE `herboy` SET Dollar = Dollar + ^"%3.2f^" WHERE `User_Id` =	%d;", m_Price, User_id);
	SQL_ThreadQuery(g_SqlTuple, "QuerySetData_Profiles", Query);
}
public plugin_cfg()
{
	g_SqlTuple = SQL_MakeDbTuple(sql_csatlakozas[0], sql_csatlakozas[1], sql_csatlakozas[2], sql_csatlakozas[3]);
	SQL_SetCharset(g_SqlTuple, "utf8");
	g_Players_Create()
	g_Inventory_Create()
	g_Product_Create()
	CreateTable_Player_Stats()
	CreateTable_MusicKits()

	g_UserId = ArrayCreate();
	//cmdTopByKills();
	Load_Data("offlinemarket", "QuerySelect_Market");
}
public CreateTable_MusicKits() {
	
	new Len;
	static Query[10048];
	Len += formatex(Query[Len], charsmax(Query), "CREATE TABLE IF NOT EXISTS `MusicKits` ");
	Len += formatex(Query[Len], charsmax(Query)-Len, "( ");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`User_Id` INT(11) NOT NULL,");
	for(new i;i < sizeof(MusicKitInfos); i++)
	Len += formatex(Query[Len], charsmax(Query)-Len, "`Kit%i` INT(11) NOT NULL,", i);
	Len += formatex(Query[Len], charsmax(Query)-Len, "`Parameter` INT(11) NOT NULL DEFAULT 0,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`Id` INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY)");
	SQL_ThreadQuery(g_SqlTuple, "createTableThread", Query);
}
public CreateTable_Player_Stats()
{
	new Len;
	static Query[10048];
	Len += formatex(Query[Len], charsmax(Query), "CREATE TABLE IF NOT EXISTS `playerstats2` ");
	Len += formatex(Query[Len], charsmax(Query)-Len, "( ");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`Id` INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`User_Id` INT(11) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`Name` varchar(32) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`Kills` INT(11) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`HSs` INT(11) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`Deaths` INT(11) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`AllHitCount` INT(32) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`AllShotCount` INT(32) NOT NULL)");
	
	SQL_ThreadQuery(g_SqlTuple, "createTableThread", Query);
}
public g_Players_Create()
{
	new Query[1024];
	new Len;

	Len += formatex(Query[Len], charsmax(Query), "CREATE TABLE IF NOT EXISTS `g_Players` ");
	Len += formatex(Query[Len], charsmax(Query)-Len, "( ");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`Id` INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`UserId` INT(11) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`Name` varchar(32) NOT NULL, ");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`Dollar` float(32) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`PremiumPont` varchar(32) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`AdminLvl` INT(2) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`ST_Tool` INT(11) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`Nametag_Tool` INT(11) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`vip_time` INT(11) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`premiumvip_time` INT(11) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`elo_points` INT(11) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`xps` float(32) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`BattlePass_Level` INT(11) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`BattlePass_Purchased` INT(1) NOT NULL)");

		SQL_ThreadQuery(g_SqlTuple, "createTableThread", Query);
}
public g_Inventory_Create()
{
	new Query[1024];
	new Len;

	Len += formatex(Query[Len], charsmax(Query), "CREATE TABLE IF NOT EXISTS `inventory` ");
	Len += formatex(Query[Len], charsmax(Query)-Len, "( ");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`SQLID` INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`w_userid` INT(11) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`w_id` INT(11) NOT NULL, ");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`Is_NameTaged` INT(1) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`NameTag` varchar(32) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`Is_StatTraked` INT(1) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`StatTrak_Kills` INT(11) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`Tradable` INT(1) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`Equiped` INT(1) NOT NULL)");

		SQL_ThreadQuery(g_SqlTuple, "createTableThread", Query);
}
public g_Product_Create()
{
	new Query[1024];
	new Len;

	Len += formatex(Query[Len], charsmax(Query), "CREATE TABLE IF NOT EXISTS `offlinemarket` ");
	Len += formatex(Query[Len], charsmax(Query)-Len, "( ");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`SQLID` INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`s_userid` INT(11) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`s_SellerName` varchar(32) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`s_EndTime` varchar(32) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`s_w_id` INT(11) NOT NULL, ");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`s_Cost` float(32) NOT NULL, ");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`s_Is_NameTaged` INT(1) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`s_Nametag` varchar(32) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`s_Is_StatTraked` INT(1) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`s_StatTrak_Kills` INT(11) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`s_Tradable` INT(1) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`s_Equiped` INT(1) NOT NULL)");

	SQL_ThreadQuery(g_SqlTuple, "createTableThread", Query);
}
public createTableThread(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime) {
	if(Errcode)
		log_amx("[HIBA*] HIBAT DOBTAM: %s",Error);
	if(FailState == TQUERY_CONNECT_FAILED)
		set_fail_state("[HIBA*] NEM TUDTAM CSATLAKOZNI AZ ADATBAZISHOZ!");
	else if(FailState == TQUERY_QUERY_FAILED)
		set_fail_state("Query Error");
}
public Load_This(id, Table_Name[], ForwardMetod[])
{
	new Data[1];
	Data[0] = id;
	static Query[10048];
	formatex(Query, charsmax(Query), "SELECT * FROM `%s` ORDER BY ( Kills + ( HSs / 10 ) - Deaths ) * ( AllHitCount / ( AllShotCount / 100 ) ) DESC;",Table_Name);
	SQL_ThreadQuery(g_SqlTuple, ForwardMetod, Query, Data, 1);
}
public Load_Data(Table_Name[], ForwardMetod[])
{
	new Query[1024]
	new Data[1];
	formatex(Query, charsmax(Query), "SELECT * FROM `%s`;",Table_Name)
	SQL_ThreadQuery(g_SqlTuple, ForwardMetod, Query, Data, 1);
}
public QuerySelect_Market(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime) 
{
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) 
	{
		log_amx("ERROR FORM LOAD IN MARKET:");
		log_amx("%s", Error);
		return;
	}
	else 
	{
		if(SQL_NumRows(Query) > 0) 
		{
			new MarketProduct[MarketSys];
			while(SQL_MoreResults(Query))
			{
				MarketProduct[m_sqlid] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "SQLID"));
				MarketProduct[MarketProductTime] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "s_EndTime"));
				MarketProduct[m_WeaponId] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "s_w_id"));
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "s_SellerName"), MarketProduct[m_SellerName], 32);
				MarketProduct[m_SellerId] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "s_userid"));
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "s_Cost"), MarketProduct[m_Cost]);
				MarketProduct[m_Is_Nametaged] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "s_Is_NameTaged"));
				MarketProduct[m_Is_StatTraked] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "s_Is_StatTraked"));
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "s_Nametag"), MarketProduct[m_Nametag], 31);
				MarketProduct[m_STKills] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "s_StatTrak_Kills"));

				new g_ProductSizeof = ArraySize(g_Products);
				for(new x = 0; x < g_ProductSizeof; x++)
				{
					new ProductMatcher[MarketSys];
					ArrayGetArray(g_Products, x, ProductMatcher);
					if(MarketProduct[MarketProductTime] == ProductMatcher[MarketProductTime] && MarketProduct[m_SellerId] == ProductMatcher[m_SellerId])
					{
						MarketProduct[m_Cost] = -1;
						break;
					}
				}
				
				ArrayPushArray(g_Products, MarketProduct);
				SQL_NextRow(Query);
			}
			client_print_color(0, print_team_default, "^4%s^1A ^3Piaci^1 árucikkek sikeresen ^3betöltésre^1 kerültek!", CHATPREFIX);
		}
	}
}
public LoadInventory(id)
{
	static Query[10048];
	new Data[1];
	Data[0] = id;
	formatex(Query, charsmax(Query), "SELECT * FROM `inventory` WHERE w_userid = %d;", g_Player[id][UserId])
	SQL_ThreadQuery(g_SqlTuple, "QuerySelect_Inventory", Query, Data, 1);
}
public QuerySelect_Inventory(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime) 
{
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) {
		log_amx("%s", Error);
		return;
	}
	else 
	{
		new id = Data[0];

		new Inventory[InventorySystem]
		new LoadArray[JoinedUserIds];
		new Founded = 0;
		new g_UserId_size = ArraySize(g_UserId);
		for(new i = 0; i < g_UserId_size;i++)
		{
			ArrayGetArray(g_UserId, i, LoadArray);
				
			if(LoadArray[JoinedUserId] == g_Player[id][UserId])
			{
				Founded = 1;
				break;
			}
		}
		if(Founded == 0)
		{
			if(FirstJoin[id] == 1)
			{
				AddToInv(id, g_Player[id][UserId], 0, 0, 0, 0, "", 0)
				AddToInv(id, g_Player[id][UserId], 1, 0, 0, 0, "", 0)
				AddToInv(id, g_Player[id][UserId], 2, 0, 0, 0, "", 0)
				AddToInv(id, g_Player[id][UserId], 3, 0, 0, 0, "", 0)
				AddToInv(id, g_Player[id][UserId], 4, 0, 0, 0, "", 0)

				FirstJoin[id] = 0;
			}
			if(SQL_NumRows(Query) > 0) 
			{
				while(SQL_MoreResults(Query))
				{
					Inventory[sqlid] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "SQLID"));
					Inventory[is_StatTraked] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Is_StatTraked"));
					Inventory[w_id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "w_id"));
					Inventory[is_Nametaged] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Is_NameTaged"));
					Inventory[w_userid] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "w_userid"));
					Inventory[is_StatTraked] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Is_StatTraked"));
					SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "NameTag"), Inventory[Nametag], 100);
					Inventory[StatTrakKills] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "StatTrak_Kills"));
					Inventory[w_tradable] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Tradable"));
					Inventory[w_equipped] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Equiped"));
					Inventory[w_deleted] = 0;
					Inventory[Changed] = 0;
				
					if(Inventory[w_equipped])
					{
						switch(FegyverInfo[Inventory[w_id]][EntName])
						{
							case CSW_AK47:
							{
								SltGun[id][AK47][1] = ArrayPushArray(g_Inventory, Inventory);
							}
							case CSW_M4A1:
							{
								SltGun[id][M4A1][1] = ArrayPushArray(g_Inventory, Inventory);
							}
							case CSW_DEAGLE:
							{
								SltGun[id][DG][1] = ArrayPushArray(g_Inventory, Inventory);
							}
							case CSW_AWP:
							{
								SltGun[id][AWP][1] = ArrayPushArray(g_Inventory, Inventory);
							}		
							case CSW_KNIFE:
							{
								SltGun[id][KNIFE][1] = ArrayPushArray(g_Inventory, Inventory);
							}		
						}
					}
					else ArrayPushArray(g_Inventory, Inventory); //MEGVAN GEC
					SQL_NextRow(Query);
				}	
				
				LoadArray[JoinedUserId] = g_Player[id][UserId];
				ArrayPushArray(g_UserId, LoadArray)
			}
		}
		else if(Founded == 1)
		{
			new InventorySizeof = ArraySize(g_Inventory)
			new EquippedWeaponsNumber = 0
			new i
			for(i = 0; i < InventorySizeof;i++)
			{
				new len;
				ArrayGetArray(g_Inventory, i, Inventory);

				if(Inventory[w_userid] == g_Player[id][UserId] && Inventory[w_equipped] == 1)
				{
					switch(FegyverInfo[Inventory[w_id]][EntName])
					{
						case CSW_AK47:{
							EquippedWeaponsNumber++
							SltGun[id][AK47][1] = i;
						}							
						case CSW_M4A1:{
							EquippedWeaponsNumber++
							SltGun[id][M4A1][1] = i;
						}
							
						case CSW_DEAGLE:{
							EquippedWeaponsNumber++
							SltGun[id][DG][1] = i;
						}
							
						case CSW_AWP:{
							EquippedWeaponsNumber++
							SltGun[id][AWP][1] = i;
						}
							
						case CSW_KNIFE:{
							EquippedWeaponsNumber++
							SltGun[id][KNIFE][1] = i;
						}							
					}
					
					if(EquippedWeaponsNumber == 5){
						break
					}
				}	
			}
		}
	}
}
public client_disconnected(id)
{
	if(!sk_get_logged(id))
		return;

	Update_Player_Stats(id);
	Update_Profiles(id);
	Update_Music(id);
	//Update_Admins(id, 2);
}
public Update_Admins(id, key){
	static Query[3072];
	new Len;
	
	switch(key)
	{
		case 1:
		{
			Len += formatex(Query[Len], charsmax(Query), "UPDATE `profiles` SET ");

			Len += formatex(Query[Len], charsmax(Query)-Len, "LastConnect = ^"%i^", ", get_systime());
			if(!g_Player[id][ConnectedBefore])
			{
				Len += formatex(Query[Len], charsmax(Query)-Len, "ConnectedBefore = ^"1^", ");
				Len += formatex(Query[Len], charsmax(Query)-Len, "FirstConnect = ^"%i^", ", get_systime());
			}
			Len += formatex(Query[Len], charsmax(Query)-Len, "Online = ^"1^" ");
			Len += formatex(Query[Len], charsmax(Query)-Len, "WHERE `User_Id` =  %d;", g_Player[id][UserId]);
		}
		case 2:
		{
			{
			new i_Seconds, i_Minutes, i_Hours, i_Days;
			i_Seconds = g_Player[id][AdminTime] + get_user_time(id);
			i_Minutes = i_Seconds / 60;
			i_Hours = i_Minutes / 60;
			i_Seconds = i_Seconds - i_Minutes * 60;
			i_Minutes = i_Minutes - i_Hours * 60;
			i_Days = i_Hours / 24;
			i_Hours = i_Hours - (i_Days * 24);

			Len += formatex(Query[Len], charsmax(Query), "UPDATE `profiles` SET ");

			Len += formatex(Query[Len], charsmax(Query)-Len, "LastConnect = ^"%i^", ", get_systime());
			if(g_Player[id][AdminLvL])
			{
				Len += formatex(Query[Len], charsmax(Query)-Len, "Time = ^"%i^", ", g_Player[id][AdminTime]+get_user_time(id));
				Len += formatex(Query[Len], charsmax(Query)-Len, "AdminDay = ^"%i^", ", i_Days);
				Len += formatex(Query[Len], charsmax(Query)-Len, "AdminHr = ^"%i^", ", i_Hours);
				Len += formatex(Query[Len], charsmax(Query)-Len, "AdminMn = ^"%i^", ", i_Minutes);
			}
			Len += formatex(Query[Len], charsmax(Query)-Len, "Online = ^"0^" ");
			Len += formatex(Query[Len], charsmax(Query)-Len, "WHERE `User_Id` =  %d;", g_Player[id][UserId]);
			}
		}
	}
	
	
	SQL_ThreadQuery(g_SqlTuple, "QuerySetData", Query);
}
public Update_Profiles(id)
{
	static Query[10048]
	new Len;

	Len += formatex(Query[Len], charsmax(Query), "UPDATE `herboy` SET ");
	Len += formatex(Query[Len], charsmax(Query)-Len, "Nev = ^"%s^", ", g_Player[id][Name]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "FirstJoin = ^"%i^", ", FirstJoin[id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "Dollar = ^"%.2f^", ", g_Player[id][Dollar])
	Len += formatex(Query[Len], charsmax(Query)-Len, "Masodpercek = ^"%i^", ", g_Player[id][PlayTime]+get_user_time(id));
	Len += formatex(Query[Len], charsmax(Query)-Len, "HS = ^"%i^", ", g_Player[id][HS]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "Oles = ^"%i^", ", g_Player[id][Kills]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "Halal = ^"%i^", ", g_Player[id][Deaths]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "PotyiPont = ^"%i^", ", g_Player[id][PremiumPont]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "NyOles7 = ^"%i^", ", g_Player[id][NyeremenyKills]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "ST_Tool = ^"%i^", ", g_Player[id][StatTrakTool]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "Nametag_Tool = ^"%i^", ", g_Player[id][NametagTool]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "HavePrefix = ^"%i^", ", g_Player[id][isPrefixed]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "ChatPrefix = ^"%s^", ", g_Player[id][ChatPrefix]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "vip_time = ^"%i^", ", g_Player[id][vipTime]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "premiumvip_time = ^"%i^", ", g_Player[id][pvipTime]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "elopoints = ^"%i^", ", g_Player[id][eloPoints]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "exp2 = ^"%.2f^", ", g_Player[id][rXP]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "BattlePass_Level = ^"%i^", ", g_Player[id][BattlePass_Level]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "BattlePass_Purchased = ^"%i^", ", g_Player[id][BattlePass_Purchased]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "isVip = ^"%i^", ", g_Player[id][is_Vip]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "is_pVip = ^"%i^", ", g_Player[id][is_pVip]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "SkinOff = ^"%i^", ", g_Player[id][SkinOnOff]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "RoundSounds = ^"%i^", ", g_Player[id][RoundEndSound]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "UltimateSounds = ^"%i^", ", g_Player[id][UltimateSound]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "HudType = ^"%i^", ", g_Player[id][HudType]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "HudOff = ^"%i^", ", g_Player[id][HudOff]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "WeapHud = ^"%i^", ", g_Player[id][WeaponHud]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "TippKey = ^"%i^", ", TippKey[id][HaveKey]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "Wins = ^"%i^", ", g_Player[id][Wins]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "Inkognitoed = ^"%i^", ", g_Player[id][is_Inkodnitoed]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "Rang = ^"%i^", ", g_Player[id][Rang]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "KSzint = ^"%i^", ", g_Player[id][ProfilRank]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "SelectedMusicKit = ^"%i^", ", g_Player[id][SelectedMusicKit]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "PorgetTime = ^"%i^", ", g_Player[id][PorgetTime]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "SanksOff = ^"%i^", ", g_Player[id][SanksOff]);

	for(new i;i < sizeof(Cases); i++)
		Len += formatex(Query[Len], charsmax(Query)-Len, "Case%d = ^"%i^", ", i, Case[id][i]);
		
	for(new i;i < sizeof(Cases); i++)
		Len += formatex(Query[Len], charsmax(Query)-Len, "Key%d = ^"%i^", ", i, Key[id][i]);

	Len += formatex(Query[Len], charsmax(Query)-Len, "Skin0 = ^"%i^", ", SltGun[id][AK47][0]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "Skin1 = ^"%i^", ", SltGun[id][M4A1][0]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "Skin2 = ^"%i^", ", SltGun[id][AWP][0]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "Skin3 = ^"%i^", ", SltGun[id][DG][0]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "Skin4 = ^"%i^" ", SltGun[id][KNIFE][0]);

	Len += formatex(Query[Len], charsmax(Query)-Len, "WHERE `ID` =	%d;", g_Player[id][UserId]);
	new Data[1]
	Data[0] = id;
	SQL_ThreadQuery(g_SqlTuple, "QuerySetData_Profiles", Query, Data);
}
public QuerySetData_Profiles(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime)
{
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) 
	{
		log_amx("Error from Profiles:");
		log_amx("%s", Error);
		return;
	}
}
public Update_Music(id){
	static Query[3072];
	new Len;
	
	Len += formatex(Query[Len], charsmax(Query), "UPDATE `MusicKits` SET ");
		
	for(new i;i < sizeof(MusicKitInfos); i++)
	Len += formatex(Query[Len], charsmax(Query)-Len, "Kit%d = ^"%i^", ", i, mvpr_kit[id][i]);


	Len += formatex(Query[Len], charsmax(Query)-Len, "Parameter = '0' WHERE `User_Id` =  %d;", g_Player[id][UserId]);
	
	SQL_ThreadQuery(g_SqlTuple, "QuerySetData", Query);
}
public Update_g_Products()
{
	new Len;
	new Query[1024]
	
	new g_ProductSizeof = ArraySize(g_Products);
	new MarketProduct[MarketSys];

	for(new i; i < g_ProductSizeof; i++)
	{
		ArrayGetArray(g_Products, i, MarketProduct);
		Len = 0;
		if(MarketProduct[m_sqlid] == -1 && MarketProduct[m_Cost] < 0)
		{
			
		}
		else if(MarketProduct[m_Cost] < 0)
		{
				Len += formatex(Query[Len], charsmax(Query), "DELETE FROM `offlinemarket` WHERE `SQLID` = %i;", MarketProduct[m_sqlid]);
		}
		else if(MarketProduct[m_sqlid] == -1)
		{
		Len += formatex(Query[Len], charsmax(Query), "INSERT INTO `offlinemarket` (`s_userid`, `s_SellerName`, `s_EndTime`, `s_w_id`, `s_Cost`, `s_Is_NameTaged`, `s_Nametag`, `s_Is_StatTraked`, `s_StatTrak_Kills`) VALUES (");
		Len += formatex(Query[Len], charsmax(Query)-Len, "%i, ", MarketProduct[m_SellerId]);
		Len += formatex(Query[Len], charsmax(Query)-Len, "^"%s^", ", MarketProduct[m_SellerName]);
		Len += formatex(Query[Len], charsmax(Query)-Len, "%i, ", MarketProduct[MarketProductTime]);
		Len += formatex(Query[Len], charsmax(Query)-Len, "%i, ", MarketProduct[m_WeaponId]);
		Len += formatex(Query[Len], charsmax(Query)-Len, "^"%.2f^", ", MarketProduct[m_Cost]);
		Len += formatex(Query[Len], charsmax(Query)-Len, "%i, ", MarketProduct[m_Is_Nametaged]);
		Len += formatex(Query[Len], charsmax(Query)-Len, "^"%s^", ", MarketProduct[m_Nametag]);
		Len += formatex(Query[Len], charsmax(Query)-Len, "%i, ", MarketProduct[m_Is_StatTraked]);
		Len += formatex(Query[Len], charsmax(Query)-Len, "%i); ", MarketProduct[m_STKills]);
		}
		SQL_ThreadQuery(g_SqlTuple, "QuerySetData_Market", Query);
	}
}
new totalsend = 0;
new gametick_now;
new runed = 0;

public Update_g_Inventory()
{
	new Len = 0;
	gametick_now = get_systime();
	new Query[3072], iTime[32]
	new g_InventorySizeof = ArraySize(g_Inventory);
	new float:timeforsaving = float(g_InventorySizeof / 230);
	client_print_color(0, print_team_default, "^4%s^1Várakozás^3 %i^1 item feltöltésére, feltöltési idő: ^4%3.2f ^3Másodperc^1. Addig a ládanyitás, piac, blokkolva lesz!", CHATPREFIX, g_InventorySizeof, timeforsaving)
	blockall = 1;
	client_print_color(0, print_team_default, "%.2f", timeforsaving); 
	set_task(timeforsaving, "do_chmap", 82820)

	new Inventory[InventorySystem];
	totalsend = 0;
	runed = 0;
	for(new i; i < g_InventorySizeof; i++)
	{
		ArrayGetArray(g_Inventory, i, Inventory);
		//Len = 0;
		if(Inventory[sqlid] == -1 && Inventory[w_deleted] == 1)
		{
			continue;
		}
		else if(Inventory[w_deleted] == 1)
		{
			Len += formatex(Query[Len], charsmax(Query)-Len, "DELETE FROM `inventory` WHERE `SQLID` = %i;", Inventory[sqlid]);
		}
		else if(Inventory[sqlid] >= 0)
		{
			if(Inventory[Changed] == 0){
				if(g_InventorySizeof - 1 == i){
					SQL_ThreadQuery(g_SqlTuple, "QuerySetData_Inventory", Query);
					Len = 0;
					Query[0] = EOS;
					totalsend++;
				}
				continue;
			}
				
			Len += formatex(Query[Len], charsmax(Query)-Len, "UPDATE `inventory` SET ");
			Len += formatex(Query[Len], charsmax(Query)-Len, "w_userid = ^"%i^", ", Inventory[w_userid]);
			Len += formatex(Query[Len], charsmax(Query)-Len, "w_id = ^"%i^", ", Inventory[w_id]);
			Len += formatex(Query[Len], charsmax(Query)-Len, "Is_NameTaged = ^"%i^", ", Inventory[is_Nametaged]);
			Len += formatex(Query[Len], charsmax(Query)-Len, "NameTag = ^"%s^", ", Inventory[Nametag]);
			Len += formatex(Query[Len], charsmax(Query)-Len, "Is_StatTraked = ^"%i^", ", Inventory[is_StatTraked]);
			Len += formatex(Query[Len], charsmax(Query)-Len, "StatTrak_Kills = ^"%i^", ", Inventory[StatTrakKills])		
			Len += formatex(Query[Len], charsmax(Query)-Len, "Tradable = ^"%i^", ", Inventory[w_tradable]);
			Len += formatex(Query[Len], charsmax(Query)-Len, "Equiped = ^"%i^" ", Inventory[w_equipped]);
			Len += formatex(Query[Len], charsmax(Query)-Len, "WHERE `SQLID` =	%d;", Inventory[sqlid]); //Inventory[Changed] = 1;
		}
		else
		{
			Len += formatex(Query[Len], charsmax(Query)-Len, "INSERT INTO `inventory` (`w_userid`,`w_id`,`Is_NameTaged`,`NameTag`,`Is_StatTraked`,`StatTrak_Kills`,`Tradable`,`Equiped`) VALUES (");
			Len += formatex(Query[Len], charsmax(Query)-Len, "%i,", Inventory[w_userid]);
			Len += formatex(Query[Len], charsmax(Query)-Len, "%i,", Inventory[w_id]);
			Len += formatex(Query[Len], charsmax(Query)-Len, "%i,", Inventory[is_Nametaged]);
			Len += formatex(Query[Len], charsmax(Query)-Len, "^"%s^",", Inventory[Nametag]);
			Len += formatex(Query[Len], charsmax(Query)-Len, "%i,", Inventory[is_StatTraked]);
			Len += formatex(Query[Len], charsmax(Query)-Len, "%i,", Inventory[StatTrakKills]);
			Len += formatex(Query[Len], charsmax(Query)-Len, "%i,", Inventory[w_tradable]);
			Len += formatex(Query[Len], charsmax(Query)-Len, "%i);", Inventory[w_equipped]);
		}

		if(Len > 2865 || (g_InventorySizeof - 1) == i)
		{
			SQL_ThreadQuery(g_SqlTuple, "QuerySetData_Inventory", Query);
			Len = 0;
			Query[0] = EOS;
			totalsend++;
		}
	}
}
/*
InTheItem példa:
{
	1 Feltöltés - Update, 
	2 Nametag felh, 
	3 StatTrak felh, 
	4 Felhasz. id csere, 
	5 felhelyezés, 
	6 törlés
}
Teljes példa:
//UpdateItem(id, 1, 1, ArrayGetArray(g_Inventory, key, Inventory), g_Player[id][UserId], Inventory[w_id], Inventory[Is_NameTaged], Inventory[Nametag], Inventory[Is_StatTraked], Inventory[StatTrakKills], Inventory[w_tradable], Inventory[w_equipped], 0)
*/
public UpdateItem(id, ItemType, InTheItem, ArrayId, User, WId, WeaponNametaged, const WeaponNametag[], WeaponStatTraked, WeaponStatTrakKills, WeaponTradable, WeaponEquipped, wsqlid, WeaponSysTime, WeaponDeleted)
{
	new Len;

	switch(ItemType)
	{
		case 1:
		{
			new Query[1024]
			switch(InTheItem)
			{
				case 1:
				{

					if(wsqlid >= 0)
					{
						Len += formatex(Query[Len], charsmax(Query)-Len, "UPDATE `inventory` SET ");
						Len += formatex(Query[Len], charsmax(Query)-Len, "w_userid = ^"%i^", ", User);
						Len += formatex(Query[Len], charsmax(Query)-Len, "w_id = ^"%i^", ", WId);
						Len += formatex(Query[Len], charsmax(Query)-Len, "Is_NameTaged = ^"%i^", ", WeaponNametaged);
						Len += formatex(Query[Len], charsmax(Query)-Len, "NameTag = ^"%s^", ", WeaponNametag);
						Len += formatex(Query[Len], charsmax(Query)-Len, "Is_StatTraked = ^"%i^", ", WeaponStatTraked);
						Len += formatex(Query[Len], charsmax(Query)-Len, "StatTrak_Kills = ^"%i^", ", WeaponStatTrakKills)		
						Len += formatex(Query[Len], charsmax(Query)-Len, "Tradable = ^"%i^", ", WeaponTradable);
						Len += formatex(Query[Len], charsmax(Query)-Len, "Equiped = ^"%i^", ", WeaponEquipped);
						Len += formatex(Query[Len], charsmax(Query)-Len, "systime = ^"%i^" ", WeaponSysTime);
						Len += formatex(Query[Len], charsmax(Query)-Len, "WHERE `SQLID` =	%d;", wsqlid);
					}
					else
					{
						Len += formatex(Query[Len], charsmax(Query)-Len, "INSERT INTO `inventory` (`w_userid`,`w_id`,`Is_NameTaged`,`NameTag`,`Is_StatTraked`,`StatTrak_Kills`,`Tradable`,`systime`,`Equiped`) VALUES (");
						Len += formatex(Query[Len], charsmax(Query)-Len, "%i,", User);
						Len += formatex(Query[Len], charsmax(Query)-Len, "%i,", WId);
						Len += formatex(Query[Len], charsmax(Query)-Len, "%i,", WeaponNametaged);
						Len += formatex(Query[Len], charsmax(Query)-Len, "^"%s^",", WeaponNametag);
						Len += formatex(Query[Len], charsmax(Query)-Len, "%i,", WeaponStatTraked);
						Len += formatex(Query[Len], charsmax(Query)-Len, "%i,", WeaponStatTrakKills);
						Len += formatex(Query[Len], charsmax(Query)-Len, "%i,", WeaponTradable);
						Len += formatex(Query[Len], charsmax(Query)-Len, "%i,", WeaponSysTime);
						Len += formatex(Query[Len], charsmax(Query)-Len, "%i);", WeaponEquipped);
					}
				}
				case 2:
				{
					if(wsqlid == -1)
						wsqlid = GetSQLID(id, User, WId, WeaponNametaged, WeaponStatTraked, WeaponTradable, WeaponSysTime, ArrayId, 1)

					Len += formatex(Query[Len], charsmax(Query)-Len, "UPDATE `inventory` SET ");
					Len += formatex(Query[Len], charsmax(Query)-Len, "is_NameTaged = ^"%i^", ", WeaponNametaged);
					Len += formatex(Query[Len], charsmax(Query)-Len, "NameTag = ^"%s^" ", WeaponNametag);
					Len += formatex(Query[Len], charsmax(Query)-Len, "WHERE `SQLID` =	%d;", wsqlid);
				
				}
				case 3:
				{
					if(wsqlid == -1)
						wsqlid = GetSQLID(id, User, WId, WeaponNametaged, WeaponStatTraked, WeaponTradable, WeaponSysTime, ArrayId, 1)

					Len += formatex(Query[Len], charsmax(Query)-Len, "UPDATE `inventory` SET ");
					Len += formatex(Query[Len], charsmax(Query)-Len, "Is_StatTraked = ^"%i^", ", WeaponStatTraked);
					Len += formatex(Query[Len], charsmax(Query)-Len, "StatTrak_Kills = ^"%i^" ", WeaponStatTrakKills);
					Len += formatex(Query[Len], charsmax(Query)-Len, "WHERE `SQLID` =	%d;", wsqlid);
				}
				case 4:
				{
					if(wsqlid == -1)
						wsqlid = GetSQLID(id, User, WId, WeaponNametaged, WeaponStatTraked, WeaponTradable, WeaponSysTime, ArrayId, 1)

					Len += formatex(Query[Len], charsmax(Query)-Len, "UPDATE `inventory` SET ");
					Len += formatex(Query[Len], charsmax(Query)-Len, "w_userid = ^"%s^" ", User);
					Len += formatex(Query[Len], charsmax(Query)-Len, "WHERE `SQLID` =	%d;", wsqlid);

				}
				case 5:
				{
					if(wsqlid == -1)
						wsqlid = GetSQLID(id, User, WId, WeaponNametaged, WeaponStatTraked, WeaponTradable, WeaponSysTime, ArrayId, 1)

					Len += formatex(Query[Len], charsmax(Query)-Len, "UPDATE `inventory` SET ");
					Len += formatex(Query[Len], charsmax(Query)-Len, "Equiped = ^"%i^" ", WeaponEquipped);
					Len += formatex(Query[Len], charsmax(Query)-Len, "WHERE `SQLID` =	%d;", wsqlid);
				}
				case 6:
				{
					if(wsqlid == -1 && WeaponDeleted == 1)
					{

					}
					else if(wsqlid < 0 && WeaponDeleted == 1)
						Len += formatex(Query[Len], charsmax(Query)-Len, "DELETE FROM `inventory` WHERE `SQLID` = %i;", wsqlid);
				}
			}
			SQL_ThreadQuery(g_SqlTuple, "QuerySetData_NewInventory", Query);
		}
	}
}
public QuerySetData_Inventory(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime)
{
	runed++;
	if(runed == totalsend)
	{
		new sztime[40], szvtime[40]
		format_time(sztime, charsmax(sztime), "%H:%M:%S", get_systime())
		format_time(szvtime, charsmax(szvtime), "%H:%M:%S", gametick_now)
		//console_print(0, "Mapchange allowed: %s // %s // %i", sztime, szvtime, ArraySize(g_Inventory));
		change_task(82820, 0.0, 0);
	}
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) 
	{
		client_print_color(0, print_team_default, "^4SQL ERROR: ^3%s", Error)
		log_amx("Error from Inventory:");
		log_amx("%s", Error);
		return;
	}
}
public QuerySetData_NewInventory(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime)
{
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) 
	{
		client_print_color(0, print_team_default, "^4SQL ERROR: ^3%s", Error)	
		LogCreate("sqlerror", fmt("%s", Error))
		return;
	}
}
public QuerySetData_Market(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime)
{
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) 
	{
		//log_amx("Error from Market:");
		//log_amx("%s", Error);
		return;
	}
}
public CmdTop15(id)
{
	client_print_color(id, print_team_default, "^4%s^1A top15 minden kör elején automatikusan frissül!",CHATPREFIX);

	new len;
	new StringMotd[3000];
	len += formatex(StringMotd[len], charsmax(StringMotd) - len, "<head><meta charset=^"UTF-8^"></head><center><table border=^"1^">");
	len += formatex(StringMotd[len], charsmax(StringMotd) - len, "<body bgcolor=#000000><table style=^"color:#00FFFF^">");
	len += formatex(StringMotd[len], charsmax(StringMotd) - len, "<td>Név								</td>");
	len += formatex(StringMotd[len], charsmax(StringMotd) - len, "<td>Ölés	</td>");
	len += formatex(StringMotd[len], charsmax(StringMotd) - len, "<td>Halál	</td>");
	len += formatex(StringMotd[len], charsmax(StringMotd) - len, "<td>Fejes	</td>");
	len += formatex(StringMotd[len], charsmax(StringMotd) - len, "<td>Pontosság	</td>");

	for(new i; i < 15; i++)
	{
		len += formatex(StringMotd[len], charsmax(StringMotd) - len, "<tr><td>%i. %s</td>", i+1, Top15_list[i][wName]);
		len += formatex(StringMotd[len], charsmax(StringMotd) - len, "<td>%i</td>", Top15_list[i][wKills]);
		len += formatex(StringMotd[len], charsmax(StringMotd) - len, "<td>%i</td>", Top15_list[i][wDeaths]);
		len += formatex(StringMotd[len], charsmax(StringMotd) - len, "<td>%i</td>", Top15_list[i][wHSs]);
		len += formatex(StringMotd[len], charsmax(StringMotd) - len, "<td>%.2f</td></tr>", ( Top15_list[i][wAllHitCount]/(Top15_list[i][wAllShotCount]/100.0) ));
	}
	len = formatex(StringMotd[len], charsmax(StringMotd) - len, "</table></center>");

	show_motd(id, StringMotd, "Top15");
}
public plugin_end()
{
	SQL_FreeHandle(g_SqlTuple);
	ArrayDestroy(g_Inventory);
	ArrayDestroy(g_Products);
	ArrayDestroy(g_UserId);
	TrieDestroy(sanklist);
}

public Update_Player_Stats(id)
{
	new Len;
	static Query[10048];
	Len += formatex(Query[Len], charsmax(Query), "UPDATE `playerstats2` SET ");
	Len += formatex(Query[Len], charsmax(Query)-Len, "Name = ^"%s^", ", g_Player[id][Name]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "Kills = ^"%i^", ", Player_Stats[id][wKills]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "HSs = ^"%i^", ", Player_Stats[id][wHSs]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "Deaths = ^"%i^", ", Player_Stats[id][wDeaths]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "AllHitCount = ^"%i^", ", Player_Stats[id][wAllHitCount]);
	
	Len += formatex(Query[Len], charsmax(Query)-Len, "AllShotCount = ^"%i^" WHERE `User_Id` =  %d;", Player_Stats[id][wAllShotCount], g_Player[id][UserId]);
	
	SQL_ThreadQuery(g_SqlTuple, "QuerySetData", Query);
}
public CmdRank(id)
{
	Update_Player_Stats(id);
	Load_This(id, "playerstats2", "TablaAdatValasztasOsszes_PlayerStats"); 
}
public TablaAdatValasztas15_PlayerStats(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime)
{
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) 
	{
		log_amx("%s", Error)
		return;
	}
	else 
	{
		if(SQL_NumRows(Query) > 0)
		{
			new x = 0;
			while(SQL_MoreResults(Query) && x <= 14)
			{
				Top15_list[x][wAllHitCount] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "AllHitCount"));
				Top15_list[x][wAllShotCount] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "AllShotCount"));
				if(Top15_list[x][wAllHitCount] != 0 && Top15_list[x][wAllShotCount] != 0)
				{
					SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Name"),Top15_list[x][wName] , 31);
					Top15_list[x][wKills] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Kills")); 
					Top15_list[x][wHSs] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "HSs"));
					Top15_list[x][wDeaths] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Deaths"));
					x++;
				}
				SQL_NextRow(Query);
			}
		}
	}
}
public TablaAdatValasztasOsszes_PlayerStats(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime) 
{
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) 
	{
		log_amx("%s", Error)
		return;
	}
	else 
	{
		new id = Data[0];
		new CanNOTRanked = 0;

		if(SQL_NumRows(Query) > 0) 
		{
			new x = 0;
			while(SQL_MoreResults(Query))
			{
				x++;
				if(SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "User_Id")) == g_Player[id][UserId])
				{
					g_Player[id][NowRank] = x;
					if(0 == SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "AllHitCount")) || 0 == SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "AllShotCount")))
						CanNOTRanked = 1;
				}
				SQL_NextRow(Query);
			}
			AllRegistedRank = x;
			if(CanNOTRanked)
			{
				client_print_color(id, print_team_default, "^4%s^4Rangod: ^3NotRanked^1/^3%i ^1| ^4Ölések: ^3%i ^1|^4 Halálok: ^3%i ^1| ^4Fejesek: ^3%i ^1|^4 Hatékonyság: ^3%.3f", CHATPREFIX, AllRegistedRank, Player_Stats[id][wKills], Player_Stats[id][wDeaths], Player_Stats[id][wHSs], ( Player_Stats[id][wAllHitCount]/(Player_Stats[id][wAllShotCount]/100.0) ));
				client_print_color(id, print_team_default, "^4%s^1Nincs elég adatunk hogy betudjuk sorolni megfelelően!",CHATPREFIX);
			}
			else
				client_print_color(id, print_team_default, "^4%s^4Rangod: ^3%i^1/^3%i ^1| ^4Ölések: ^3%i ^1|^4 Halálok: ^3%i ^1| ^4Fejesek: ^3%i ^1|^4 Hatékonyság: ^3%.3f", CHATPREFIX, g_Player[id][NowRank], AllRegistedRank, Player_Stats[id][wKills], Player_Stats[id][wDeaths], Player_Stats[id][wHSs], ( Player_Stats[id][wAllHitCount]/(Player_Stats[id][wAllShotCount]/100.0) ));
		}
	}
}
public TablaAdatValasztas_PlayerStats(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime) 
{
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) 
	{
			log_amx("%s", Error)
			return;
	}
	else 
	{
			new id = Data[0];

			if(SQL_NumRows(Query) > 0) 
			{
				Player_Stats[id][wKills] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Kills")); 
				Player_Stats[id][wHSs] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "HSs"));
				Player_Stats[id][wDeaths] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Deaths"));
				Player_Stats[id][wAllHitCount] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "AllHitCount"));
				Player_Stats[id][wAllShotCount] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "AllShotCount"));
			}
			else 
			{
				new text[512];
				formatex(text, charsmax(text), "INSERT INTO `playerstats2` (`User_Id`) VALUES (%i);", g_Player[id][UserId]);
				SQL_ThreadQuery(g_SqlTuple, "QuerySetData", text);
			}
	}
}
public AddToInv(id, userid, weapid, stattrak, stattrakkills, nametaged, nametag[100], tradable)
{
	new Inventory[InventorySystem]
	new systime_now = get_systime();
	new arryid
	
	Inventory[sqlid] = -1;
	Inventory[w_userid] = userid
	Inventory[w_id] = weapid
	Inventory[is_StatTraked] = stattrak
	Inventory[StatTrakKills] = stattrakkills
	Inventory[is_Nametaged] = nametaged
	Inventory[w_tradable] = tradable
	Inventory[w_deleted] = 0;
	Inventory[w_equipped] = 0;
	Inventory[w_systime] = systime_now;

	copy(Inventory[Nametag], 100, nametag);
	
	if(weapid < 5)
	{
		Inventory[w_equipped] = 1;
		switch(FegyverInfo[Inventory[w_id]][EntName])
		{
			case CSW_AK47:
				SltGun[id][AK47][1] = ArrayPushArray(g_Inventory, Inventory);
			case CSW_M4A1:
				SltGun[id][M4A1][1] = ArrayPushArray(g_Inventory, Inventory);
			case CSW_DEAGLE:
				SltGun[id][DG][1] = ArrayPushArray(g_Inventory, Inventory);
			case CSW_AWP:
				SltGun[id][AWP][1] = ArrayPushArray(g_Inventory, Inventory);
			case CSW_KNIFE:
				SltGun[id][KNIFE][1] = ArrayPushArray(g_Inventory, Inventory);
		}
		SltGun[id][AK47][0] = 0;
		SltGun[id][M4A1][0] = 1;
		SltGun[id][AWP][0] = 2;
		SltGun[id][DG][0] = 3;
		SltGun[id][KNIFE][0] = 4;

	}
	else 
	arryid = ArrayPushArray(g_Inventory, Inventory);

	//UpdateItem(id, 1, 1, arryid, userid, weapid, nametaged, nametag, stattrak, stattrakkills, tradable, 0, -1, systime_now, 0)
	
}
public LoadMusicKits(id)
{
	static Query[10048];
	new Data[1];
	Data[0] = id;
	formatex(Query, charsmax(Query), "SELECT * FROM `MusicKits` WHERE User_Id = %d;", g_Player[id][UserId])
	SQL_ThreadQuery(g_SqlTuple, "QuerySelectMusic", Query, Data, 1);
}
public QuerySelectMusic(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime) {
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) {
		log_amx("%s", Error);
		return;
	}
	else 
	{
		new id = Data[0];
		
		if(SQL_NumRows(Query) > 0) {
			for(new i;i < sizeof(MusicKitInfos); i++)
			{
				new String[64];
				formatex(String, charsmax(String), "Kit%d", i);
				mvpr_kit[id][i] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, String));
			}

				new fwd_loginedreturn;
				ExecuteForward(fwd_logined,fwd_loginedreturn, id);
				log_amx("KURVA")
		}
	else
		sql_create_music_row(id);
	}
}
public QuerySelectSMS(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime)
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
			new ppAmount, Tempuserid, SynId, tempQuery[512], TempActive, PaymentType;

			while(SQL_MoreResults(Query))
			{
				Tempuserid = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "comment"));
				TempActive = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Active"));
				for(new i; i < 33; i++)
				{
					if(Tempuserid == g_Player[i][UserId] && TempActive == 1)
					{
						SynId = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "id"));
						ppAmount = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "amount"));
						PaymentType = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "paymethodid"));
						
						if(PaymentType == 3)
						{
							givepp(i, 3, ppAmount)
							console_print(0, "giveppresz3")
						}
						else if(PaymentType == 5)
						{
							console_print(0, "giveppresz5")
							givepp(i, 5, ppAmount)
						}
						formatex(tempQuery, charsmax(tempQuery), "UPDATE `__syn_payments` SET `Active` = 0 WHERE `id` = %d;", SynId);
						SQL_ThreadQuery(g_SqlTuple, "QuerySetData", tempQuery);
					}

				}
				SQL_NextRow(Query);
			}
		}
	}
}
public givepp(id, pptype, ppAmount)
{
	new Float:levonas, Query[512]
	new Float:ppszorzoSMS = get_pcvar_float(SCvar[ppszorzassms])
	new Float:ppszorzoPayPal = get_pcvar_float(SCvar[ppszorzaspaypal])
	new is_Event = get_pcvar_num(SCvar[ppevent])
	switch(pptype)
	{
		case 1:
		{
			g_Player[id][PremiumPont] += ppAmount;
			formatex(Query, charsmax(Query), "INSERT INTO `__syn_payments` (amount, Active) VALUES (%i, 0)", ppAmount);
			SQL_ThreadQuery(g_SqlTuple, "QuerySetData", Query);
		}
		case 3: 
		{
			ppAmount = ppAmount/2

			if(is_Event == 1)
				levonas = ppAmount*1.72*ppszorzoSMS*0.27 
			else
				levonas = ppAmount*1.72*0.27 

			if(is_Event == 1)
			{
				g_Player[id][PremiumPont] += floatround(ppAmount*1.72*ppszorzoSMS-levonas)
				client_print_color(id, print_team_default, "^4%s^3Sikeres^1 jóváírás! - Jóváírt pontok: ^4%i", CHATPREFIX, floatround(ppAmount*1.72*ppszorzoSMS-levonas))
			}
			else
			{
				client_print_color(id, print_team_default, "^4%s^3Sikeres^1 jóváírás! - Jóváírt pontok: ^4%i", CHATPREFIX, floatround(ppAmount*1.72*ppszorzoSMS-levonas))
				g_Player[id][PremiumPont] += floatround(ppAmount*1.72-levonas)
			}
		}
		case 5:
		{
			g_Player[id][PremiumPont] += floatround(ppAmount*ppszorzoPayPal)
			client_print_color(id, print_team_default, "^4%s^3Sikeres^1 jóváírás! - Jóváírt pontok: ^4%i", CHATPREFIX, floatround(ppAmount*ppszorzoPayPal))
		}
	}
}

bool:RegexTester(id, m_string[], RegexText[], NoMatchText[])
{
	new ret, error[128];
	new Regex:regex_handle = regex_match(m_string, RegexText, ret, error, charsmax(error));
	
	switch(regex_handle)
	{
		case REGEX_MATCH_FAIL:
		{
			log_amx("---REGEX MATCH FAIL---");
			log_amx("ERROR:");
			log_amx(error);
			log_amx("RET:");
			// There was an error matching against the pattern
			// Check the {error} variable for message, and {ret} for error code
		}
		case REGEX_PATTERN_FAIL:
		{
			log_amx("---REGEX TATTERN ERROR---");
			log_amx("ERROR:");
			log_amx(error);
			log_amx("RET:");
			// There is an error in your pattern
			// Check the {error} variable for message, and {ret} for error code
		}
		case REGEX_NO_MATCH:
		{
			client_print_color(id, print_team_default, "^4%s^1%s",CHATPREFIX, NoMatchText);
		}
		default:
		{
			// Matched m_string {ret} times
			regex_free(regex_handle);
			return true;
			// Free the Regex handle
		}
	}
	regex_free(regex_handle);
	return false;
}
public LogCreate(const message_fmt1[], const message_fmt[], any:...)
{							
	static filename[96];
	static LogName[96];
	static LogMessage[3068];
	vformat(LogName, sizeof(LogName) - 1, message_fmt1, 2);
	vformat(LogMessage, sizeof(LogMessage) - 1, message_fmt, 2);

	format_time(filename, sizeof(filename) - 1, "%Y%m%d");
	format(filename, sizeof(filename) - 1, "%s__%s.log", LogName, filename);

	log_to_file(filename, "%s", LogMessage);
}
public sort_bestthree(id1, id2)
{
	if(g_Player[id1][FragKills] > g_Player[id2][FragKills]) return -1
	else if(g_Player[id1][FragKills] < g_Player[id2][FragKills]) return 1

	return 0
}
public restart_round()
{
	g_korkezdes = 0;	
}
public automatikusfrag()
{
	new hour, minute, second;
	time(hour, minute, second);
	if(Fragverseny == 0)
	{
		if(hour == 13 && minute == 00)
		{
			get_cvar_string("hostname", ServerName, charsmax(ServerName))
			Fragverseny = 1;
			Fragkorok = 50;
			server_cmd("sv_restart 1");
			SetNyeremeny();
		}
		else if(hour == 18 && minute == 00)
		{
			get_cvar_string("hostname", ServerName, charsmax(ServerName))
			Fragverseny = 1;
			Fragkorok = 50;
			server_cmd("sv_restart 1");
			SetNyeremeny();
		}
		else if(hour == 21 && minute == 00)
		{
			get_cvar_string("hostname", ServerName, charsmax(ServerName))
			Fragverseny = 1;
			Fragkorok = 50;
			server_cmd("sv_restart 1");
			SetNyeremeny();
		}
		else if(hour == 00 && minute == 05)
		{
			get_cvar_string("hostname", ServerName, charsmax(ServerName))
			Fragverseny = 1;
			Fragkorok = 50;
			server_cmd("sv_restart 1");
			SetNyeremeny();
		}
	}
}
public SetNyeremeny()
{
	FragJutalmak1 = random_num(0, 11)
	FragJutalmak2 = random_num(0, 9)
	FragJutalmak3 = random_num(0, 8)

	client_print_color(0, print_team_default, "^4%s^1Első hely: ^3%s^4 | ^1Második hely: ^3%s^4 | ^1Harmadik hely: ^3%s", CHATPREFIX, JutalmakFrag1[FragJutalmak1], JutalmakFrag2[FragJutalmak2], JutalmakFrag3[FragJutalmak3])
}
public fragonroundstart()
{
	client_print_color(0, print_team_default, "^4%s^1Első hely: ^3%s^4 | ^1Második hely: ^3%s^4 | ^1Harmadik hely: ^3%s", CHATPREFIX, JutalmakFrag1[FragJutalmak1], JutalmakFrag2[FragJutalmak2], JutalmakFrag3[FragJutalmak3])
	client_print_color(0, print_team_default, "^4%s^1Jelenleg ^3automatikus^1 fragverseny van, tart még ^4%i^1 körig!", CHATPREFIX, Fragkorok);
}
public EndTheFrag()
{
	new Players[32], Num;
	get_players(Players, Num);
	SortCustom1D(Players, Num, "sort_bestthree")
	
	new Top1 = Players[0]
	new Top2 = Players[1]
	new Top3 = Players[2]
	
	new TopName1[32], TopName2[32], TopName3[32]
	get_user_name(Top1, TopName1, charsmax(TopName1))
	get_user_name(Top2, TopName2, charsmax(TopName2))
	get_user_name(Top3, TopName3, charsmax(TopName3))
	
	client_print_color(0, print_team_default, "^4%s^1A Fragverseny első helyezettje: %s | Jutalma: %s", CHATPREFIX, TopName1, JutalmakFrag1[FragJutalmak1])
	client_print_color(0, print_team_default, "^4%s^1A Fragverseny második helyezettje: %s | Jutalma: %s", CHATPREFIX, TopName2, JutalmakFrag2[FragJutalmak2])
	client_print_color(0, print_team_default, "^4%s^1A Fragverseny harmadik helyezettje: %s | Jutalma: %s", CHATPREFIX, TopName3, JutalmakFrag3[FragJutalmak3])

	switch(FragJutalmak1)
	{
		case 0:
		{
			Key[Top1][5] += 10;
			Case[Top1][5] += 10;
		}
		case 1:
		{
			Key[Top1][4] += 10;
			Case[Top1][4] += 10;
		}
		case 2:
		{
			if(g_Player[Top1][is_Vip])
				g_Player[Top1][vipTime] += 86400*7
			else
				g_Player[Top1][vipTime] += get_systime()+86400*7

			g_Player[Top1][is_Vip] = 1
		}
		case 3:
		{
			g_Player[Top1][Dollar] += 20.00;
		}
		case 4:
		{
			g_Player[Top1][Dollar] += 21.00;
		}
		case 5:
		{
			if(g_Player[Top1][is_Vip])
				g_Player[Top1][vipTime] += 86400*7
			else
				g_Player[Top1][vipTime] += get_systime()+86400*7
				
			g_Player[Top1][is_Vip] = 1
		}
		case 6:
		{
			Key[Top1][5] += 7;
			Case[Top1][5] += 7;
		}
		case 7:
		{
			Key[Top1][4] += 7;
			Case[Top1][4] += 7;	
		}
		case 8:
		{
			if(g_Player[Top1][is_Vip])
				g_Player[Top1][vipTime] += 86400*7
			else
				g_Player[Top1][vipTime] += get_systime()+86400*7
				
			g_Player[Top1][is_Vip] = 1
		}
		case 9:
		{
			g_Player[Top1][Dollar] += 30.00;
		}
		case 10:
		{
			g_Player[Top1][Dollar] += 20.00;
		}
		case 11:
		{
			if(g_Player[Top1][is_Vip])
				g_Player[Top1][vipTime] += 86400*7
			else
				g_Player[Top1][vipTime] += get_systime()+86400*7
				
			g_Player[Top1][is_Vip] = 1
		}
	}
	switch(FragJutalmak2)
	{
		case 0:
		{
			Key[Top2][3] += 10;
			Case[Top2][3] += 10;
		}
		case 1:
		{
			Key[Top2][2] += 10;
			Case[Top2][2] += 10;
		}
		case 2:
		{
			if(g_Player[Top2][is_Vip])
				g_Player[Top2][vipTime] += 86400*3
			else
				g_Player[Top2][vipTime] += get_systime()+86400*3
				
			g_Player[Top2][is_Vip] = 1
		}
		case 3:
		{
			g_Player[Top2][Dollar] += 20.00;
		}
		case 4:
		{
			g_Player[Top2][Dollar] += 15.00;
		}
		case 5:
		{
			if(g_Player[Top2][is_Vip])
				g_Player[Top2][vipTime] += 86400*5
			else
				g_Player[Top2][vipTime] += get_systime()+86400*5
				
			g_Player[Top2][is_Vip] = 1
		}
		case 6:
		{
			Key[Top2][2] += 7;
			Case[Top2][2] += 7;
		}
		case 7:
		{
			if(g_Player[Top2][is_Vip])
				g_Player[Top2][vipTime] += 86400*3
			else
				g_Player[Top2][vipTime] += get_systime()+86400*3
				
			g_Player[Top2][is_Vip] = 1
		}
		case 8:
		{
			g_Player[Top2][Dollar] += 20.00;
		}
		case 9:
		{
			g_Player[Top2][Dollar] += 15.00;
		}
	}
	switch(FragJutalmak3)
	{
		case 0:
		{
			Key[Top3][1] += 7;
			Case[Top3][1] += 7;
		}
		case 1:
		{
			if(g_Player[Top3][is_Vip])
				g_Player[Top3][vipTime] += 86400
			else
				g_Player[Top3][vipTime] += get_systime()+86400
				
			g_Player[Top3][is_Vip] = 1
		}
		case 2:
		{
			g_Player[Top3][Dollar] += 10.00;
		}
		case 3:
		{
			g_Player[Top3][Dollar] += 7.00;
		}
		case 4:
		{
			if(g_Player[Top3][is_Vip])
				g_Player[Top3][vipTime] += 86400*3
			else
				g_Player[Top3][vipTime] += get_systime()+86400*3
				
			g_Player[Top3][is_Vip] = 1
		}
		case 5:
		{
			if(g_Player[Top3][is_Vip])
				g_Player[Top3][vipTime] += 86400
			else
				g_Player[Top3][vipTime] += get_systime()+86400
				
			g_Player[Top3][is_Vip] = 1
		}
		case 6:
		{
			g_Player[Top3][Dollar] += 15.00;
		}
		case 7:
		{
			g_Player[Top3][Dollar] += 10.00;
		}
		case 8:
		{
			Key[Top3][0] += 10;
			Case[Top3][0] += 10;	
		}
	}
}
public cmdTopByKills()
{
	SQL_ThreadQuery(g_SqlTuple, "top3ThreadaK","SELECT * FROM `herboy` ORDER BY NyOles7 DESC LIMIT 15");
	
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
		len += formatex(menu[len], charsmax(menu) - len, "<tr><td>%02d.	%s(#%i)</td>", i+1, nyolesNev[i], nyid[i]);
		
		len += formatex(menu[len], charsmax(menu) - len, "<td>%d</td></tr>", nyolesl[i]);
	}
	len += formatex(menu[len], charsmax(menu) - len, "<body bgcolor=#000000><table style=^"color: #32CD32^">");
	len += formatex(menu[len], charsmax(menu) - len, "<td>1. Hely: <br>Trust GXT 830-RW Avonn Gamer Billentyűzet - </td>");
	len += formatex(menu[len], charsmax(menu) - len, "<td>2. Hely: <br>Trust GXT781 RIXA CAMO gamer egér és alátét - </td>");
	len += formatex(menu[len], charsmax(menu) - len, "<td>3. Hely: <br>4000 PP</td>");
	
	len += formatex(menu[len], charsmax(menu) - len, "<body bgcolor=#000000><table style=^"color: #0000ff^">");
	len += formatex(menu[len], charsmax(menu) - len, "<td>Kezdete: 2021.03.05 4:00<br>Vége: 2021.05.01 06:00</td>");
	
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
		client_print_color(0, print_team_default, "SQL ERROR FROM NYEREMENYJATEK : MEGSZAKADT")
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
		nyid[count] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "User_Id"));
		nyolesl[count] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "NyOles7"));
		SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "gamename"), nyolesNev[count], 32);
		
		count++;
		
		SQL_NextRow(Query);
	}
	
	return;
}
public ObjectSend(id)
{
	new Data[121];
	new LogMSG[512];
	new sztime[40];	
	new sztime1[40];	
	format_time(sztime, charsmax(sztime), "%Y.%m.%d - %H:%M:%S", get_systime())
	format_time(sztime1, charsmax(sztime1), "%Y.%m.%d", get_systime())
	
	read_args(Data, charsmax(Data));
	remove_quotes(Data);

	if(str_to_num(Data) < 1) 
		return PLUGIN_HANDLED;

	if(g_Player[id][SendType] == 4 && Case[id][g_Player[id][CaseOrKeySelected]] >= str_to_num(Data))
	{
		Case[g_Player[id][SendTemp]][g_Player[id][CaseOrKeySelected]] += str_to_num(Data);
		Case[id][g_Player[id][CaseOrKeySelected]] -= str_to_num(Data);
		client_print_color(0, print_team_default, "^4%s^3Játékos: ^4%s^1 küldött ^3%i darab ^4%s^1-t ^3%s^1 játékosnak.", CHATPREFIX, g_Player[id][Name], str_to_num(Data), Cases[g_Player[id][CaseOrKeySelected]][d_Name], g_Player[g_Player[id][SendTemp]][Name]);
		format(LogMSG,charsmax(LogMSG),"UserId: %i | KName: %s | Targy: %d - %iDB | Date: %s | FoId: %i | FoName: %s", g_Player[id][UserId], g_Player[id][Name], Cases[g_Player[id][CaseOrKeySelected]][d_Name], str_to_num(Data), sztime, g_Player[g_Player[id][SendTemp]][UserId], g_Player[g_Player[id][SendTemp]][Name]);
		LogCreate("LadaKuldes", LogMSG)
		g_Player[id][SendType] = 0;
	}
	else if(g_Player[id][SendType] == 5 && Key[id][g_Player[id][CaseOrKeySelected]] >= str_to_num(Data))
	{
		Key[g_Player[id][SendTemp]][g_Player[id][CaseOrKeySelected]] += str_to_num(Data);
		Key[id][g_Player[id][CaseOrKeySelected]] -= str_to_num(Data);
		client_print_color(0, print_team_default, "^4%s^3Játékos: ^4%s^1 küldött ^3%i darab ^4%s^1-t ^3%s^1 játékosnak.", CHATPREFIX, g_Player[id][Name], str_to_num(Data), Keys[g_Player[id][CaseOrKeySelected]][d_Name], g_Player[g_Player[id][SendTemp]][Name]);
		format(LogMSG,charsmax(LogMSG),"UserId: %i | KName: %s | Targy: %d - %iDB | Date: %s | FoId: %i | FoName: %s", g_Player[id][UserId], g_Player[id][Name], Keys[g_Player[id][CaseOrKeySelected]][d_Name], str_to_num(Data), sztime, g_Player[g_Player[id][SendTemp]][UserId], g_Player[g_Player[id][SendTemp]][Name]);
		LogCreate("LadaKulcsKuldes", LogMSG)
	}
	else if(g_Player[id][SendType] == 6 && g_Player[id][Dollar] >= str_to_num(Data))
	{
		g_Player[g_Player[id][SendTemp]][Dollar] += str_to_num(Data);
		g_Player[id][Dollar] -= str_to_num(Data);
		client_print_color(0, print_team_default, "^4%s^3Játékos: ^4%s^1 küldött ^3%d ^4dollárt^1-t ^3%s^1 játékosnak.", CHATPREFIX, g_Player[id][Name], str_to_num(Data), g_Player[g_Player[id][SendTemp]][Name]);
		format(LogMSG,charsmax(LogMSG),"UserId: %i | KName: %s | Targy: %d $ | Date: %s | FoId: %i | FoName: %s", g_Player[id][UserId], g_Player[id][Name], str_to_num(Data), sztime, g_Player[g_Player[id][SendTemp]][UserId], g_Player[g_Player[id][SendTemp]][Name]);
		LogCreate("DollarKuldes", LogMSG)
		g_Player[id][SendType] = 0;
	}
	else if(g_Player[id][SendType] == 7 && g_Player[id][NametagTool] >= str_to_num(Data))
	{
		g_Player[g_Player[id][SendTemp]][NametagTool] += str_to_num(Data);
		g_Player[id][NametagTool] -= str_to_num(Data);
		client_print_color(0, print_team_default, "^4%s^3Játékos: ^4%s^1 küldött ^3%d ^4Névcédulá^1-t ^3%s^1 játékosnak.", CHATPREFIX, g_Player[id][Name], str_to_num(Data), g_Player[g_Player[id][SendTemp]][Name]);
		format(LogMSG,charsmax(LogMSG),"UserId: %i | KName: %s | Targy: %d Nevcedula | Date: %s | FoId: %i | FoName: %s", g_Player[id][UserId], g_Player[id][Name], str_to_num(Data), sztime, g_Player[g_Player[id][SendTemp]][UserId], g_Player[g_Player[id][SendTemp]][Name]);
		LogCreate("Tools_Kuldes", LogMSG)
		g_Player[id][SendType] = 0;
	}
	else if(g_Player[id][SendType] == 8 && g_Player[id][StatTrakTool] >= str_to_num(Data))
	{
		g_Player[g_Player[id][SendTemp]][StatTrakTool] += str_to_num(Data);
		g_Player[id][StatTrakTool] -= str_to_num(Data);
		client_print_color(0, print_team_default, "^4%s^3Játékos: ^4%s^1 küldött ^3%d ^4StatTrak* Tool^1-t ^3%s^1 játékosnak.", CHATPREFIX, g_Player[id][Name], str_to_num(Data), g_Player[g_Player[id][SendTemp]][Name]);
		format(LogMSG,charsmax(LogMSG),"UserId: %i | KName: %s | Targy: %d StatTrak* Tool | Date: %s | FoId: %i | FoName: %s", g_Player[id][UserId], g_Player[id][Name], str_to_num(Data), sztime, g_Player[g_Player[id][SendTemp]][UserId], g_Player[g_Player[id][SendTemp]][Name]);
		LogCreate("Tools_Kuldes", LogMSG)
		g_Player[id][SendType] = 0;
	}
	return PLUGIN_HANDLED;
}
public RoundEnds()
{
	new players[32], num;
	get_players(players, num, "ch");
	SortCustom1D(players, num, "SortMVPToPlayer");
	new TopMvp = players[0];
	new RandomMusic = random(23)
	
	client_print_color(0, print_team_default, "^3%s^1A legjobb játékos ebben a körben ^4%s^1 volt, ezért egy ^4%s^1 zenekészlet szól.", CHATPREFIX, g_Player[TopMvp][Name], MusicKitInfos[RandomMusic][MusicKitName]);
	
	for(new i=0, id = -1;i<num;i++)
	{
		id = players[i];

		if(g_Player[id][RoundEndSound] == 1)
		{
			client_cmd(id, "mp3 play sound/%s", MusicKitInfos[RandomMusic][MusicLocation]);
		}
	}

	g_Player[TopMvp][eloXP] += 15.00;
	g_Player[TopMvp][eloElo] += 15;

	for(new i=0;i<num;i++)
		g_Player[players[i]][MVPPoints] = 0;
}
public SortMVPToPlayer(id1, id2){
	if(g_Player[id1][MVPPoints] > g_Player[id2][MVPPoints]) return -1;
	else if(g_Player[id1][MVPPoints] < g_Player[id2][MVPPoints]) return 1;

	return 0;
}
public bomb_planted(id) {
	g_Player[id][MVPPoints] += 3
	g_Player[id][eloElo] += 10;
	g_Player[id][eloXP] += 5.00;

	client_print_color(0, print_team_default, "^4%s^1Játékos: ^4%s^1 élesítette a bombát!", CHATPREFIX, g_Player[id][Name])
}
public bomb_defused(id) {
	g_Player[id][MVPPoints] += 5
	g_Player[id][eloElo] += 10;
	g_Player[id][eloXP] += 5.00;
	client_print_color(0, print_team_default, "^4%s^1Játékos: ^4%s^1 hatástalanította a bombát!", CHATPREFIX, g_Player[id][Name])
}
public TippKeyMenu(id)
{
	new iras[121], String[121], itemNum, sztime[40];
	format(iras, charsmax(iras), "\y%s TippKulcs", MENUPREFIX);
	new menu = menu_create(iras, "tippkey_h");

	if(TippKey[id][AllowedTippKey])
	{
		menu_addtext2(menu, fmt("Szerinted melyik a jó kulcs? Tippelj egyet!^nNyereményed: \y%3.2f$^n", TippKey[id][NyeremenyDollar]))

		for(new i = TippKey[id][MinKey]; i <= TippKey[id][MaxKey]; i++)
		{
			new Sor[6]; num_to_str(i, Sor, 5);
			formatex(String, charsmax(String), "\d%s", SorsjegyKeys[i]);
			menu_additem(menu, String, Sor);
		}
	}
	else
		{
			menu_additem(menu, fmt("Tippkulcs nyitása \r[\y%i \ddb\r]\d", TippKey[id][HaveKey]), "-1", 0);
			menu_addtext2(menu, fmt("^nHogy mi az a TippKulcs?^nVan 5 kulcs, amiből a helyeset eltalálod,^nha eltalálod a helyes kulcsot akkor jutalomban részesülsz^nha nem találod el nem nyersz semmit!"))
		}

	menu_display(id, menu, 0);
}
public tippkey_h(id, menu, item) {
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED
	}

	new data[9], szName[64]
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName, charsmax(szName), callback);
	new key = str_to_num(data);

	switch(key)
	{
		case -1:
		{
			if(TippKey[id][HaveKey] == 0)
			{
				client_print_color(id, print_team_default, "^4%s^1Nincsen ^3TippKulcsod^1! Menj vásárolj egyet az áruházban!", CHATPREFIX);
				return;
			}

			new kapartjegy = random_num(6, 99)

			TippKey[id][MaxKey] = kapartjegy;
			TippKey[id][MinKey] = TippKey[id][MaxKey]-5;
			TippKey[id][NyertesKulcs] = random_num(TippKey[id][MinKey], TippKey[id][MaxKey])
			
			TippKey[id][AllowedTippKey] = 1;

			new Float:nyertesdollar = random_float(20.00,50.00);
			TippKey[id][NyeremenyDollar] = nyertesdollar;
			
			TippKeyMenu(id);
			return;
		}
		case 0..100:
		{
			if(TippKey[id][NyertesKulcs] == key)
			{
				g_Player[id][Dollar] += TippKey[id][NyeremenyDollar];

				client_print_color(0, print_team_default, "^4%s^1Játékos: ^4%s^1 eltalálta a TippKulcsot, nyertes kulcs: ^4%s^1 nyereménye: ^4%3.2f^1$", CHATPREFIX, g_Player[id][Name], SorsjegyKeys[TippKey[id][NyertesKulcs]][0], TippKey[id][NyeremenyDollar]);

				TippKey[id][MaxKey] = 0;
				TippKey[id][MinKey] = 0;
				TippKey[id][NyertesKulcs] = 0;
				TippKey[id][NyeremenyDollar] = 0.0;
				TippKey[id][AllowedTippKey] = 0;
				TippKey[id][HaveKey]--;
			}
			else
			{
				client_print_color(id, print_team_default, "^4%s^1Sajnáljuk, de ez a TippKulcs nem nyert, próbáld újra!", CHATPREFIX)
				TippKey[id][MaxKey] = 0;
				TippKey[id][MinKey] = 0;
				TippKey[id][NyertesKulcs] = 0;
				TippKey[id][NyeremenyDollar] = 0.0;
				TippKey[id][AllowedTippKey] = 0;
				TippKey[id][HaveKey]--;
			}
		}
	}
	
	menu_destroy(menu);
}

public openPlayerChooserMute(id) {
	new szMenu[121], players[32], pnum, iName[32], szTempid[10]
	get_players(players, pnum)

	formatex(szMenu, charsmax(szMenu), "\r%s \wVálassz ki egy játékost!", MENUPREFIX)
	new menu = menu_create(szMenu, "hPlayerChooserMute");
	new len;

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
	if(!key == 0)
		client_print_color(id, print_team_default, "^4%s^1Te most %s %s.", CHATPREFIX, g_Mute[id][key] ? "^3némítottad^4": "^4hallod^3", g_Player[key][Name])
}
