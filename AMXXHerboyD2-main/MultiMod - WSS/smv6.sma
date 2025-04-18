#include <amxmodx>
#include <amxmisc>
#include <reapi>
#include <cstrike>
#include <engine>
#include <fun>
#include <hamsandwich>
#include <manager>
#include <fakemeta>
#include <xs>
#include <csx>
#include <fakemeta_stocks>
#include <fakemeta_util>
#include <sqlx>
#include <regex>
#include <sk_utils>
#include <bansys>
#include <regsystem>
#include <easytime2>
#include <ammoclip>
#include <mod>
#include <skinslist>

#define DEMO_TASK_OFFSET 46236253
#define DEMO_TASK_DETAIL 45236253
#define OFFSET_C4_SLOT      372
#define SCOREATTRIB_NONE    0
#define SCOREATTRIB_DEAD    ( 1 << 0 )
#define SCOREATTRIB_BOMB    ( 1 << 1 )
#define SCOREATTRIB_VIP     ( 1 << 2 )

#define PremiunVIP_PPCost 650
#define ChatPrefix_Cost 200.00

/// RANKING
#define getELOPoints_HS_Min 5
#define getELOPoints_HS_Max 12
#define getELOPoints_Min 3
#define getELOPoints_Max 5
#define remELOPoints_Min 3
#define remELOPoints_Max 6

// RANKING END
#define getEXP_HS_Min 1.0
#define getEXP_HS_Max 1.9
#define getEXP_Min 0.9
#define getEXP_Max 1.7


//INVENTORY
#define InventoryMaxUpgrade 600
#define InventoryMAX 1200
//
#define TorhetetlenitesAra 50000

#define AMMO_338MAG_BUY		10
#define AMMO_357SIG_BUY		13
#define AMMO_45ACP_BUY		12
#define AMMO_50AE_BUY		7
#define AMMO_556NATO_BUY	30
#define AMMO_556NATOBOX_BUY	30
#define AMMO_57MM_BUY		50
#define AMMO_762NATO_BUY	30
#define AMMO_9MM_BUY		30
#define AMMO_BUCKSHOT_BUY	8

new const PLUGIN[] = "[SMOD] ~ MultiMod v6"; 
new const VERSION[] = "v6.1.2";
new const AUTHOR[] = "Shedi";

new const MENUPREFIX[] = "\r[\wHerBoy\r] \yONLYDUST2 \d~";
new const CHATPREFIX[] = "^4[^1~^3|^4HerBoy^3|^1~^4] ^3»^1";
new const ET_model[] = "models/hb_multimod_v5/event/case1.mdl";
new const ETM_model[] = "models/hb_multimod_v5/event/medkit.mdl";
new const HG_model[] = "models/hb_multimod_v5/event/v_hegrenade.mdl";
new const FB_model[] = "models/hb_multimod_v5/event/v_flashbang.mdl";
new const C4_model[] = "models/hb_multimod_v5/event/v_c4.mdl";
new const NPCMDL[] = "models/hb_multimod_v5/event/npc.mdl";

new PiacSzures[][] = {
	"MOD_MARKETSEARCH_ALL",
	"MOD_MARKETSEARCH_AK47",
	"MOD_MARKETSEARCH_M4A1",
	"MOD_MARKETSEARCH_AWP",
	"MOD_MARKETSEARCH_DEAGLE",
	"MOD_MARKETSEARCH_KNIFE",
	"MOD_MARKETSEARCH_CASE_KEY",
	"MOD_MARKETSEARCH_PP_ITEM",
	"MOD_MARKETSEARCH_UNBREAKABLES"
}
new CSW_PiacSzures[] = {
	-1,
	CSW_AK47,
	CSW_M4A1,
	CSW_AWP,
	CSW_DEAGLE,
	CSW_KNIFE,
	-1,
	-1,
	-1
}


new fwd_logined, fwd_mapchange, /* g_screenfade, */ sm_roundstart;
new g_TEWins, g_CTWins, bool:g_SetHudOff = false;
enum _:ServerCvars
{
	maxkor,
	ppevent,
	duplafrag
}
new SCvar[ServerCvars];
new bSync, aSync, g_korkezdes;
new Array:g_Buy[33];
new Array:g_Credit[33];
new Array:g_Market;
new g_Mute[33][33]
new Ajandekcsomag[33][6];

new sm_PlayerName[33][33];
new PrintStreamEvent = 0;
new ExtraFragmentDrop = 0;
enum _:HudWeaponData
{
	h_p_id,
	h_w_id,
	h_Allapot,
	h_isStatTraked,
	h_StatTrakKills,
	h_isNameTaged,
	h_Owner[33],
	h_NameTag[100],
	h_EntId
}
new sm_HudWeapon[33][3][HudWeaponData];
enum _:PlayerMenu
{
	SelectingWeapon,
	SelectedWeaponFor_InvKezeles,
	q_QuestID,
	BuyVIPDay,
	PressedVIPMenu,
	SelectedPlayer_PlayerEdit,
	SelectedFragversenyArray,
	SelectingErem,
	SelectedStoreItem
}
new f_PlayerMenus[33][PlayerMenu]
enum _:PlayerSystem
{
	a_UserId,
	Float:Dollar,
	GepeszKesztyu,
	isVip,
	VipTime,
	StatTrakTool,
	NametagTool,
	Toredek,
	SelectedInvArryKey,
	SelectedCaseForOpen,
	Skins,
	RoundEndSound,
	UltimateSound,
	Huds,
	WeaponHud,
	ReszletesLadanyitas,
	isRegistered,
	SelectedType,
	SendType,
	SendTemp,
	CaseOrKeySelected,
	openSelectItemRow,
	DisplayAdmin,
	Buyed,
	ScreenEffect,
	FirstJoin,
	Rang,
	ChatPrefix[32],
	ChatPrefixAdded,
	ChatPrefixRemove,
	HudTipusok,
	DamageCur,
	DamagerHud,
	AmbientSound,
	fegyvertipus,
	SelectedItemToPlace,
	SelectedLKToPlace,
	SelectedLKToPlaceDarab,
	Float:SetCost, 
	SwitchingOnMarket,
	MarketArrId, 
	odaadva,
	s_death,
	s_kill,
	s_hs,
	PiacSzuro,
	InHandWeap,
	Tolvajkesztyu,
	TolvajkesztyuEndTime,
	TorhetetlenitoKeszlet,
	PorgetSys,
	PorgetASys,
	Float:EXP,
	eELO,
	WinnedRound,
	iPrivateRank,
	iBattlePassPurch,
	iBattlePassLevel,
	iSelectedMedal,
	Ajandekcsomagok,
	VipKupon,
	modconnid,
	Inventory_Size,
	InventoryWriteableSize,
	InventoryMaxSize, 
	NPCTouch,
	isDead,
	TradeEnableKit,
	OldStyleWeaponMenu, 
	DeletType,
	SelectedForDelete,
	RecoilControl,
	ReviveSprite,
	QuakeS,
	SpecL
}
enum _:ErdemEremProp
{
	medal_collected,
	medal_collectedsys
}

enum _:BuySys
{
	BuyName[33],
	BuyCost,
	Float:BuyDollar,
	BuyTime[33],
	BuyId
}
enum _:CreditSys
{
	CreditAmount,
	CreditId,
	CreditBackAdded,
	CreditTime[33]
}
enum _:InventorySystem
{
	w_id,
	sqlid,
	w_userid,
	isStatTraked,
	StatTrakKills,
	isNameTaged,
	Nametag[100],
	Allapot,
	tradable,
	equipped,
	opened,
	openedfrom[33],
	openedBy[33],
	openedById,
	deleted,
	changed,
	firecount,
	is_new,
	f_arrid,
	e_id
}

new const g_ShotsPer1Dmg[] =
{
	200, 	//AK47
	200, 	//M4A1
	50, 	//AWP
	60, 	//DEAGLE
	100, 	//KNIFE
	50, 	//SCOUT
	200, 	//FAMAS
	200, 	//GALIL
	300, 	//M249
	200, 	//TMP
	200, 	//MP5
	200, 	//P90
	30, 	//M3
	40, 	//XM1014
	60, 	//GLOCK18
 	60		//USP
}
new gInventory[33][1200][InventorySystem];
static const EmptyItem[InventorySystem];
new Equipment[33][SelGun][2];
enum _:MarketSystem
{
	m_Type,
	m_Case,
	m_Key,
	m_Darab,
	m_sqlid,
	m_wid,
	m_userid,
	m_isStatTraked,
	m_StatTrakKills,
	m_isNameTaged,
	m_Nametag[100],
	m_Allapot,
	m_opened,
	m_openedfrom[33],
	m_openedBy[33],
	m_openedById,
	m_firecount,
	m_expire,
	Float:m_cost,
	m_SellerName[33],
	m_oldsqlid,
}
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
enum _:DropSystem_Prop
{
	cName[32],
	Float:d_rarity,
	Float:VipDropchance,
	CanDropAndOpenFrom[32],
}
enum _:MusicDatas
{
	MusicKitName[64],
	MusicLocation[64],
	Float:MusicKitPound_D,
	MusicKitPound_P
}
enum _:Fragverseny_Properties
{
	fragid,
	frayday[33],
	fragstarthour,
	fragstartminute,
	fragrounds,
	Float:fragdollartop1,
	Float:fragdollartop2,
	Float:fragdollartop3,
	fragvipdaytop1,
	fragvipdaytop2,
	fragvipdaytop3,	
	fragskinidtop1,
	fragskinidtop2,
	fragskinidtop3,
	fragby[33]
}
enum _:PrintstreamSys
{
	p_tus,
	p_tar,
	p_markolat,
	p_crafttype
}
new g_PrintstreamVaz[33][6]
new g_Printstream[33][PrintstreamSys]
new const Cases[][DropSystem_Prop] =
{
	{"S0 - Aether", 20.5, 2.25, 17386081830},
	{"S0 - Valkyrie", 12.0, 2.5, 1738608183},
	{"S0 - Eclipse", 5.0, 2.5, 1738608183},
	{"S0 - Titan", 30.5, 1.25, 1738608183},
	{"S0 - Phantom", 40.0, 0.5, 1738608183},
	{"S1 - Nemesis", 50.0, 40.0, 1744308000},
	{"S2 - Onyx", 45.0, 30.0, 1746900000},
	{"S3 - Zephyr", 69.0, 0.0, 1749578400},
	{"S4 - Inferno", 23.0, 0.0, 1752170400},
	{"S5 - Specter", 54.0, 0.0, 1754848800},
	{"S6 - Obsidian", 62.0, 0.0, 1757527200},
	{"S7 - Ragnarok", 23.0, 0.0, 1760119200},
	{"S8 - Seraph", 64.0, 0.0, 1762801200},
	{"S9 - Revenant", 46.0, 0.0, 1765393200},
	{"S10 - Chronos", 62.0, 0.0, 1768071600},
	{"S11 - Tempest", 14.0, 0.0, 1770750000},
	{"S12 - Mirage", 53.0, 0.0, 1773169200},
	{"S13 - Wraith", 26.0, 0.0, 1775844000},
	{"S14 - Oracle", 15.0, 0.0, 1778436000},
	{"S15 - Vortex", 73.0, 0.0, 1781114400},
	{"S16 - Umbra", 42.0, 0.0, 1783706400},
	{"S17 - Solstice", 54.0, 0.0, 1786384800},
	{"S18 - Paradox", 12.0, 0.0, 1789063200},
	{"S19 - Havoc", 42.0, 0.0, 1791655200}
}
new const Keys[][DropSystem_Prop] =
{	
	{"S0 - Aether", 18.5, 2.25, 17386081830},
	{"S0 - Valkyrie", 11.0, 2.5, 1738608183},
	{"S0 - Eclipse", 3.2, 2.5, 1738608183},
	{"S0 - Titan", 27.2, 1.25, 1738608183},
	{"S0 - Phantom", 40.9, 1.5, 1738608183},
	{"S1 - Nemesis", 50.0, 15.0, 1744308000},
	{"S2 - Onyx", 35.0, 10.0, 1746900000},
	{"S3 - Zephyr", 15.0, 0.0, 1749578400},
	{"S4 - Inferno", 64.0, 0.0, 1752170400},
	{"S5 - Specter", 25.0, 0.0, 1754848800},
	{"S6 - Obsidian", 64.0, 0.0, 1757527200},
	{"S7 - Ragnarok", 53.0, 0.0, 17601192000},
	{"S8 - Seraph", 25.0, 0.0, 1762801200},
	{"S9 - Revenant", 63.0, 0.0, 1765393200},
	{"S10 - Chronos", 45.0, 0.0, 1768071600},
	{"S11 - Tempest", 14.0, 0.0, 1770750000},
	{"S12 - Mirage", 63.0, 0.0, 1773169200},
	{"S13 - Wraith", 52.0, 0.0, 1775844000},
	{"S14 - Oracle", 24.0, 0.0, 1778436000},
	{"S15 - Vortex", 53.0, 0.0, 1781114400},
	{"S16 - Umbra", 53.0, 0.0, 1783706400},
	{"S17 - Solstice", 42.0, 0.0, 1786384800},
	{"S18 - Paradox", 63.0, 0.0, 1789063200},
	{"S19 - Havoc", 12.0, 0.0, 1791655200},
}
enum _:Store_Properties
{
	StoreName[32],
	Float:BuyDollars,
	BuyPremium,
	StoreMess[100],
	StoreContent[100],
	NotAvailable
}
new const StoreDatas[][Store_Properties] =
{
	{"Raktár Férőhely", 10.0, 99999999, "Raktár Férőhelyed bővítése", "1 férőhely", 0}, //PP ÁRAK VÉGE 99 re végződjön #marketing
	{"Prémium VIP", 1200.0, 99999999, "Extra drop esély, extra bónuszok, ölésnél +hp stb..", "-^n\wHossza: \d1 hét (Ha lelépsz is tellik!)", 1},
	{"Chat Prefix", 200.0, 99999999, "Egyedi Chat előtagot tudsz beállítani", "-^n\wHossza: \d2 hét (Ha lelépsz is tellik!)", 0},
	{"Nametag", 300.0, 99999999, "Ezzel eltudod nevezni a fegyvered", "1 DB Névcédula", 0},
	{"Gépészkesztyű", 500.0, 99999999, "Fegyver Craftolás egyik alapfeltétele", "1 DB Gépészkesztyű", 0},
	{"StatTrak* Tool", 300.0, 99999999, "Ezzel tudod a fegyvereddel számolni az öléseket", "1 DB StatTrak* Tool", 0},
	{"Törhetetlenítő készlet", 20000.0, 99999999, "A 'törékeny' fegyvered törhetetlenné teszi.", "1 DB Törhetetlenítő készlet", 0},
	{"Black Ice", 9000.0, 99999999, "Eladhatatlan, nem küldhető, nem törhetetlen.", "1 DB (AK, M4, AWP, DG, Butterfly^nKarambit, Daggers, FAMAS, MP5)", 0},
	{"Red Tron", 5000.0, 99999999, "Eladhatatlan, nem küldhető, nem törhetetlen.", "1 DB (AK, M4, AWP, DG, KÉS)", 1},
	{"Blue Tron", 5000.0, 99999999, "Eladhatatlan, nem küldhető, nem törhetetlen.", "1 DB (AK, M4, AWP, DG, KÉS)", 0},
	{"Green Tron", 5000.0, 99999999, "Eladhatatlan, nem küldhető, nem törhetetlen.", "1 DB (AK, M4, AWP, DG, KÉS)", 0},
	{"Lila HerBoy kés", 1500.0, 99999999, "Eladhatatlan, nem küldhető, nem törhetetlen.", "1 DB KÉS", 0},
	{"Kék HerBoy kés", 1500.0, 99999999, "Eladhatatlan, nem küldhető, nem törhetetlen.", "1 DB KÉS", 0},
	{"Random Kés", 5000.0, 99999999, "Eladható, küldhető, nem törhetetlen.", "1 DB Random KÉS", 1},
	{"Tolvajkesztyű", 85.0, 99999999, "Extra Drop esélyt biztosít.", "-^n\wHossza: \d12 Óra (Ha lelépsz is tellik!)", 0},
	{"Eladhatóvá alakító készlet", 2500.0, 99999999, "Nem eladható fegyvert teszi eladhatóvá.", "1 DB Eladhatóvá alakító készlet", 0},
	{"BattlePass belépő", 200.0, 99999999, "Belépést jogosít a BattlePass használatához", 0},
}


new m_case_S0_Aether_size = sizeof(case_S0_Aether);
new m_case_S0_Valkyrie_size = sizeof(case_S0_Valkyrie);
new m_case_S0_Eclipse_size = sizeof(case_S0_Eclipse);
new m_case_S0_Titan_size = sizeof(case_S0_Titan);
new m_case_S0_Phantom_size = sizeof(case_S0_Phantom);
new m_case_S1_Nemesis_size = sizeof(case_S1_Nemesis);
new m_case_S2_Onyx_size = sizeof(case_S2_Onyx);
new m_case_S3_Zephyr_size = sizeof(case_S3_Zephyr);
new m_case_S4_Inferno_size = sizeof(case_S4_Inferno);
new m_case_S5_Specter_size = sizeof(case_S5_Specter);
new m_case_S6_Obsidian_size = sizeof(case_S6_Obsidian);
new m_case_S7_Ragnarok_size = sizeof(case_S7_Ragnarok);
new m_case_S8_Seraph_size = sizeof(case_S8_Seraph);
new m_case_S9_Revenant_size = sizeof(case_S9_Revenant);
new m_case_S10_Chronos_size = sizeof(case_S10_Chronos);
new m_case_S11_Tempest_size = sizeof(case_S11_Tempest);
new m_case_S12_Mirage_size = sizeof(case_S12_Mirage);

new gWPCT, gWPTE;
new f_Player[33][PlayerSystem], Case[33][sizeof(Cases)], Key[33][sizeof(Cases)];

enum _:RangAdatok {
	RangName[32],
	sELO[8]
}
new const Rangok[][RangAdatok] = {
	{"Extra Lowest X", -10000},  
	{"Extra Lowest", -5000},    
	{"Lowest Silver III", -1000},    
	{"Lowest Silver II", -500},    
	{"Lowest Silver I", -100},    
	{"NotRanked", 0},                                           
	{"Iron I", 500},
	{"Iron II", 2500},
	{"Iron III", 7500},
	{"Bronze I", 14000},
	{"Bronze II", 18000},
	{"Bronze III", 24000},
	{"Silver I", 29000},
	{"Silver II", 34000},
	{"Silver III", 40000},
	{"Gold I", 45000},
	{"Gold II", 50000},
	{"Gold III", 57000},
	{"Platinum I", 65000},
	{"Platinum II", 73000},
	{"Platinum III", 80000},
	{"Diamond I", 87000},
	{"Diamond II", 95000},
	{"Diamond III", 104000},
	{"Ascendant I", 114000},
	{"Ascendant II", 124000},
	{"Ascendant III", 130000},
	{"Immortal I", 170000},
	{"Immortal II", 250000},
	{"Immortal III", 350000},
	{"Radiant", 500000},
	{"Global Elite", 600000},
	{"Brigad. General", 800000},
	{"Major General", 1000000},
	{"Lieut. General", 2000000},
	{"General", 3000000},
	{"1337", 5000000},
	{"Maximator", 9999999999},
}	
enum _:MedalData {
	medal_id,
	MedalName[100],
	MedalText[128]
}
new const cMedals[][MedalData] = 
{
	{0, "MOD_MEDALS_NAME_NONE", "MOD_MEDALS_DESC_NONE"},
	{1, "MOD_MEDALS_NAME_BETA_TESTER", "MOD_MEDALS_DESC_BETA_TESTER"},
	{2, "MOD_MEDALS_NAME_SERVER_ELITE", "MOD_MEDALS_DESC_SERVER_ELITE"},
	{3, "MOD_MEDALS_NAME_HELLO_NEW_WORLD", "MOD_MEDALS_DESC_HELLO_NEW_WORLD"},
	{4, "MOD_MEDALS_NAME_DIAMOND_MEDAL", "MOD_MEDALS_DESC_DIAMOND_MEDAL"},
	{5, "MOD_MEDALS_NAME_GOLD_MEDAL", "MOD_MEDALS_DESC_GOLD_MEDAL"},
	{6, "MOD_MEDALS_NAME_SILVER_MEDAL", "MOD_MEDALS_DESC_SILVER_MEDAL"},
	{7, "MOD_MEDALS_NAME_IRON_MEDAL", "MOD_MEDALS_DESC_IRON_MEDAL"},
	{8, "MOD_MEDALS_NAME_SUPPORTER", "MOD_MEDALS_DESC_SUPPORTER"},
	{9, "MOD_MEDALS_NAME_ELITE_SUPPORTER", "MOD_MEDALS_DESC_ELITE_SUPPORTER"},
	{10,"MOD_MEDALS_NAME_OMEGA_SUPPORTER", "MOD_MEDALS_DESC_OMEGA_SUPPORTER"},
	{11,"MOD_MEDALS_NAME_SERVER_GEEK", "MOD_MEDALS_DESC_SERVER_GEEK"},
	{12,"MOD_MEDALS_NAME_1_YEAR_SERVICE", "MOD_MEDALS_DESC_1_YEAR_SERVICE"},
	{13,"MOD_MEDALS_NAME_2_YEAR_SERVICE", "MOD_MEDALS_DESC_2_YEAR_SERVICE"},
	{14,"MOD_MEDALS_NAME_3_YEAR_SERVICE", "MOD_MEDALS_DESC_3_YEAR_SERVICE"},
	{15,"MOD_MEDALS_NAME_2024_SILVER_SERVICE", "MOD_MEDALS_DESC_2024_SILVER_SERVICE"},
	{16,"MOD_MEDALS_NAME_2024_GOLD_SERVICE", "MOD_MEDALS_DESC_2024_GOLD_SERVICE"},
	{17,"MOD_MEDALS_NAME_2024_DIAMOND_SERVICE", "MOD_MEDALS_DESC_2024_DIAMOND_SERVICE"},
	{18,"MOD_MEDALS_NAME_2025_IRON_SERVICE", "MOD_MEDALS_DESC_2025_IRON_SERVICE"},
	{19,"MOD_MEDALS_NAME_2025_SILVER_SERVICE", "MOD_MEDALS_DESC_2025_SILVER_SERVICE"},
	{20,"MOD_MEDALS_NAME_2025_BRONZE_SERVICE", "MOD_MEDALS_DESC_2025_BRONZE_SERVICE"},
	{21,"MOD_MEDALS_NAME_2025_GOLD_SERVICE", "MOD_MEDALS_DESC_2025_GOLD_SERVICE"},
	{22,"MOD_MEDALS_NAME_2025_DIAMOND_SERVICE", "MOD_MEDALS_DESC_2025_DIAMOND_SERVICE"},
	{23,"MOD_MEDALS_NAME_STRIKE_WHILE_HOT", "MOD_MEDALS_DESC_STRIKE_WHILE_HOT"},
	{24,"MOD_MEDALS_NAME_BATTLE_PASS", "MOD_MEDALS_DESC_BATTLE_PASS"},
	{25,"MOD_MEDALS_NAME_BATTLE_PASS_GOD", "MOD_MEDALS_DESC_BATTLE_PASS_GOD"},
	{26,"MOD_MEDALS_NAME_RETURNING", "MOD_MEDALS_DESC_RETURNING"},
}
new const BattlePassJutalmak[][] =
{
{ "MOD_BATTLEPASS_REWARD_NONE"},
{ "MOD_BATTLEPASS_REWARD_NONE"},
{ "MOD_BATTLEPASS_REWARD_5_DOLLARS"},
{ "MOD_BATTLEPASS_REWARD_NONE"},
{ "MOD_BATTLEPASS_REWARD_10_DOLLARS"},
{ "MOD_BATTLEPASS_REWARD_NONE"},
{ "MOD_BATTLEPASS_REWARD_GIFT_PACKAGE"},
{ "MOD_BATTLEPASS_REWARD_NONE"},
{ "MOD_BATTLEPASS_REWARD_10_DOLLARS"},
{ "MOD_BATTLEPASS_REWARD_NONE"},
{ "MOD_BATTLEPASS_REWARD_20_XP"},
{ "MOD_BATTLEPASS_REWARD_NONE"},
{ "MOD_BATTLEPASS_REWARD_15_DOLLARS"},
{ "MOD_BATTLEPASS_REWARD_NONE"},
{ "MOD_BATTLEPASS_REWARD_GIFT_PACKAGE"},
{ "MOD_BATTLEPASS_REWARD_NONE"},
{ "MOD_BATTLEPASS_REWARD_STAT_TRAK_TOOL"},
{ "MOD_BATTLEPASS_REWARD_NONE"},
{ "MOD_BATTLEPASS_REWARD_NAME_TAG"},
{ "MOD_BATTLEPASS_REWARD_NONE"},
{ "MOD_BATTLEPASS_REWARD_10_DOLLARS"},
{ "MOD_BATTLEPASS_REWARD_NONE"},
{ "MOD_BATTLEPASS_REWARD_THIEF_GLOVES_1_DAY"},
{ "MOD_BATTLEPASS_REWARD_NONE"},
{ "MOD_BATTLEPASS_REWARD_30_XP"},
{ "MOD_BATTLEPASS_REWARD_NONE"},
{ "MOD_BATTLEPASS_REWARD_30_DOLLARS"},
{ "MOD_BATTLEPASS_REWARD_NONE"},
{ "MOD_BATTLEPASS_REWARD_10_PP"},
{ "MOD_BATTLEPASS_REWARD_NONE"},
{ "MOD_BATTLEPASS_REWARD_5_GIFT_PACKAGES"},
{ "MOD_BATTLEPASS_REWARD_NONE"},
{ "MOD_BATTLEPASS_REWARD_40_XP"},
{ "MOD_BATTLEPASS_REWARD_NONE"},
{ "MOD_BATTLEPASS_REWARD_STAT_TRAK_TOOL"},
{ "MOD_BATTLEPASS_REWARD_NONE"},
{ "MOD_BATTLEPASS_REWARD_NAME_TAG"}, //36LVL
{ "MOD_BATTLEPASS_REWARD_NONE"},
{ "MOD_BATTLEPASS_REWARD_60_DOLLARS"},
{ "MOD_BATTLEPASS_REWARD_NONE"},
{ "MOD_BATTLEPASS_REWARD_10_PP"},
{ "MOD_BATTLEPASS_REWARD_NONE"},
{ "MOD_BATTLEPASS_REWARD_10_GIFT_PACKAGES"},
{ "MOD_BATTLEPASS_REWARD_NONE"},
{ "MOD_BATTLEPASS_REWARD_40_DOLLARS"},
{ "MOD_BATTLEPASS_REWARD_NONE"},
{ "MOD_BATTLEPASS_REWARD_50_XP"},
{ "MOD_BATTLEPASS_REWARD_NONE"},
{ "MOD_BATTLEPASS_REWARD_BATTLEPASS_GOD_MEDAL"},
{ "MOD_BATTLEPASS_REWARD_NONE"},
{ "MOD_BATTLEPASS_REWARD_PRINTSTREAM_AK47"},
{ "MOD_BATTLEPASS_REWARD_NONE"},
{ "MOD_BATTLEPASS_REWARD_STAT_TRAK_TOOL"},
{ "MOD_BATTLEPASS_REWARD_NONE"},
{ "MOD_BATTLEPASS_REWARD_NAME_TAG"},
{ "MOD_BATTLEPASS_REWARD_NONE"},
{ "MOD_BATTLEPASS_REWARD_80_DOLLARS"},
{ "MOD_BATTLEPASS_REWARD_NONE"},
{ "MOD_BATTLEPASS_REWARD_PVIP_COUPON_1_DAY"},
{ "MOD_BATTLEPASS_REWARD_NONE"},
{ "MOD_BATTLEPASS_REWARD_PRINTSTREAM_M4A1"},
{ "MOD_BATTLEPASS_REWARD_NONE"},
{ "MOD_BATTLEPASS_REWARD_100_DOLLARS"},
{ "MOD_BATTLEPASS_REWARD_NONE"},
{ "MOD_BATTLEPASS_REWARD_10_PP"},
{ "MOD_BATTLEPASS_REWARD_NONE"},
{ "MOD_BATTLEPASS_REWARD_15_GIFT_PACKAGES"},
{ "MOD_BATTLEPASS_REWARD_NONE"},
{ "MOD_BATTLEPASS_REWARD_PRINTSTREAM_AWP"},
{ "MOD_BATTLEPASS_REWARD_NONE"},
{ "MOD_BATTLEPASS_REWARD_PLUS_1_LEVEL"},
{ "MOD_BATTLEPASS_REWARD_NONE"},
{ "MOD_BATTLEPASS_REWARD_PRINTSTREAM_DEAGLE"}, //76LVL
{ "MOD_BATTLEPASS_REWARD_NONE"},
{ "MOD_BATTLEPASS_REWARD_UNBREAKABLE_KIT"},
{ "MOD_BATTLEPASS_REWARD_NONE"},
{ "MOD_BATTLEPASS_REWARD_PRINTSTREAM_KNIFE"},
{ "MOD_BATTLEPASS_REWARD_NONE"},
{ "MOD_BATTLEPASS_REWARD_1000_PP"},
{ "MOD_BATTLEPASS_REWARD_LEVEL_MAXED"},
};
new Medal[33][sizeof(cMedals)][ErdemEremProp];


public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	register_impulse(201, "CheckMain");
	SCvar[maxkor] = register_cvar("maxkor", "50");
	SCvar[ppevent] = register_cvar("sm_admintgf", "0");
	SCvar[duplafrag] = register_cvar("sm_duplafrag", "0");
	register_concmd("hb_edit_kills", "cmdKillsEdit", _, "<#id> <ölés> <hs> <halál>")
	register_concmd("hb_set_vip", "CmdSetVIP", _, "<#id> <ido>");
	register_concmd("hb_set_raktar", "CmdSetInventory", _, "<#id> <ido>");
	register_clcmd("say dc", "dc");
	register_clcmd("say /dc", "dc");
	register_clcmd("say /admin", "cmdSetAdminDisplay");
	register_clcmd("say /fegyo", "WeaponMenu");
	register_clcmd("say /mute", "openPlayerChooserMute");
	register_clcmd("say /fegyver", "WeaponMenu");
	register_clcmd("say /guns", "WeaponMenu");
	register_clcmd("say /gun", "WeaponMenu");
	//register_clcmd("say /kepescucc", "GiveMeSkins")
	register_clcmd("EnterPrefix", "set_Prefix");
	register_clcmd("say", "Hook_Say");
	register_clcmd("say_team", "Hook_Say");
	register_clcmd("SkinKereses", "cmdSearchSkinString")
	register_clcmd("SET_NAMETAG", "cmdAddNametag")
	register_clcmd("SET_RENAMETAG", "cmdAddNametag")
	register_clcmd("DOLLAR_AR", "cmdDollarEladas");
	register_clcmd("VIPhet", "cmdVIPDay");
	register_clcmd("LADA_DARAB", "cmdDarabCase")
	register_clcmd("KULCS_DARAB", "cmdDarabKeys")
	register_clcmd("Kuldes_Mennyisege", "ObjectSend");
	
	RegisterHam(Ham_Weapon_SecondaryAttack, "weapon_m4a1", "Ham_BlockSecondaryAttack")
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_m4a1", "Ham_BlockSecondaryAttack", 1)
	RegisterHam(Ham_Item_Deploy, "weapon_m4a1" ,"Ham_BlockSecondaryAttack", 1)

	RegisterHookChain(RG_CBasePlayerWeapon_DefaultDeploy, "RG_ChangeWeapon", 1);
	RegisterHookChain(RG_CBasePlayer_AddPlayerItem, "fw_AddPlayerItem__pre", .post = false);
	npc_betolt()
	register_touch("npc","player","npc_erint") 
	register_forward(FM_Touch,"ForwardTouch" );
	register_forward(FM_Touch,"ForwardMedkitTouch" );
	register_forward(FM_GetGameDescription, "GameDesc" ); 
	register_forward(FM_Voice_SetClientListening, "OnPlayerTalk")
	register_event("HLTV", "ujkor", "a", "1=0", "2=0");
	register_logevent("WeaponCheck", 2, "1=Round_End");
	RegisterHam(Ham_Spawn, "player" ,"Spawn", 1);
	register_menucmd(register_menuid("MARKETMENU"), 1023, "openMarketSwitch_h")
	register_menucmd(register_menuid("RAKTARMENU"), 1023, "hRaktarMenu")
	fwd_logined = CreateMultiForward("LoggedSuccesfully", ET_IGNORE, FP_CELL);
	fwd_mapchange = CreateMultiForward("mod_mapchange", ET_IGNORE);
	register_event("DeathMsg","eDeathMsg","a")
	register_logevent("logevent_end", 2, "1=Round_End");
	register_event("SendAudio", "TerrorsWin" , "a", "2&%!MRAD_terwin");
	register_event("SendAudio", "CTerrorsWin", "a", "2&%!MRAD_ctwin");
	set_task(1.0, "SecCheck",_,_,_,"b");
	set_task(60.0, "Hirdetes",_,_,_,"b");
	aSync = CreateHudSyncObj();
	bSync = CreateHudSyncObj();
	for(new i = 0; i < 33; i++)
	{
		g_Credit[i] = ArrayCreate(CreditSys)
		g_Buy[i] = ArrayCreate(BuySys)
	}
	g_Market = ArrayCreate(MarketSystem)
	//

	register_dictionary("general.txt");
	register_dictionary("modv5.txt");
}
public Ham_BlockSecondaryAttack(ent)
{
	if (is_nullent(ent)) 
		return HAM_IGNORED

	static id

	id = get_member(ent, m_pPlayer)

	if (is_nullent(id) || !is_user_alive(id))
		return HAM_IGNORED

	if(Equipment[id][M4A1][0] > 268 && Equipment[id][M4A1][0] < 342)
	{
		set_member(ent, m_Weapon_flNextSecondaryAttack, 9999.0)
		return HAM_SUPERCEDE
	}

	return HAM_IGNORED
}
public Addolas(id)
{
	new accountid = sk_get_accountid(id);
	if(accountid != 3 && accountid != 1)
		return PLUGIN_HANDLED;

	AddToInv(id, 1, f_Player[id][a_UserId], 1268, 101, 1, 0, 0, "", 1, "", "", f_Player[id][a_UserId], -1);
	AddToInv(id, 1, f_Player[id][a_UserId], 1269, 101, 1, 0, 0, "", 1, "", "", f_Player[id][a_UserId], -1);
	AddToInv(id, 1, f_Player[id][a_UserId], 1270, 101, 1, 0, 0, "", 1, "", "", f_Player[id][a_UserId], -1);
	AddToInv(id, 1, f_Player[id][a_UserId], 1271, 101, 1, 0, 0, "", 1, "", "", f_Player[id][a_UserId], -1);
	AddToInv(id, 1, f_Player[id][a_UserId], 1272, 101, 1, 0, 0, "", 1, "", "", f_Player[id][a_UserId], -1);
}
public placegame(id)
{
	new Float:origin[3];
	entity_get_vector(id, EV_VEC_origin, origin);
	client_print(0, print_chat, "Entity origin: %.2f, %.2f, %.2f", origin[0], origin[1], origin[2]-37.00);
}
public TerrorsWin() {
	g_TEWins++;
	for(new id = 0 ; id < 33 ; id++) 
	{
		if(is_user_connected(id) && cs_get_user_team(id) == CS_TEAM_T)
			f_Player[id][WinnedRound]++;
	}
}
public CTerrorsWin() {
	g_CTWins++;
	
	for(new id = 0 ; id < 33 ; id++) 
	{
		if(is_user_connected(id) && cs_get_user_team(id) == CS_TEAM_CT)
			f_Player[id][WinnedRound]++;
	}
}
public WeaponCheck()
{
	for(new id = 0 ; id < 33 ; id++) 
	{
		if(!is_user_bot(id))
		{
			for(new i = 0; i < 16; i++)
				weapon_deteriorate(id, i, GetWeaponEntById(i));
		}
	}
}
public dc() {
	sk_chat(0, "Discord server: ^4https://discord.gg/herboyd2");
}
public cmdKillsEdit(id, level, cid){
	if(get_user_adminlvl(id) == 0){
	sk_chat(id,  "^1 ^3Nincs elérhetőseged^1 ehhez a parancshoz!");
	return PLUGIN_HANDLED;
	}

	new Arg1[32], Arg2[32], Arg3[32], Arg4[32], Arg_Int[4]
	new szName[32];
	get_user_name(id, szName, charsmax(szName));
	read_argv(1, Arg1, charsmax(Arg1));
	read_argv(2, Arg2, charsmax(Arg2));
	read_argv(3, Arg3, charsmax(Arg3));
	read_argv(4, Arg4, charsmax(Arg4));

	Arg_Int[0] = str_to_num(Arg1);
	Arg_Int[1] = str_to_num(Arg2);
	Arg_Int[2] = str_to_num(Arg3);
	Arg_Int[3] = str_to_num(Arg4);
	
	if(Arg_Int[0] < 1)
		return PLUGIN_HANDLED;	

	new Is_Online = Check_Id_Online(Arg_Int[0]);

	f_Player[Is_Online][s_kill] += Arg_Int[1]
	f_Player[Is_Online][s_hs] += Arg_Int[2]
	f_Player[Is_Online][s_death] += Arg_Int[3]

	sk_chat(0, "^4%s^1(#^3%d^1) ADD ^3[ ^4%i ^1KILL, ^4%i ^1HS, ^4%i ^1DEATH ^3] ^1 FOR ^4%s", sm_PlayerName[id], sk_get_accountid(id), Arg_Int[1], Arg_Int[2], Arg_Int[3], sm_PlayerName[Is_Online])
	return PLUGIN_HANDLED;
}
public CmdSetVIP(id, level, cid)
{
	if(get_user_adminlvl(id) == 0){
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
		f_Player[Is_Online][VipTime] = (f_Player[Is_Online][VipTime] == 0 ? get_systime() : f_Player[Is_Online][VipTime]) + (86400 * Arg_Int[1]);
		format_time(sztime, charsmax(sztime), "%Y.%m.%d - %H:%M:%S", f_Player[Is_Online][VipTime])
		sk_chat(0, "Játékos: ^3%s ^1(#^3%d^1) | VIP Tagságot kapott ^3%d^1 napra! ^3%s^1 által!", sm_PlayerName[Is_Online], Arg_Int[0], Arg_Int[1], szName);
		sk_chat(Is_Online, "Kaptál^4 %d Napra^1 szóló‚ ^3VIPet^1. ^3Lejár ekkor: ^4%s", Arg_Int[1], sztime);	
	}
	
	
	return PLUGIN_HANDLED;
}
public CmdSetInventory(id, level, cid)
{
	if(get_user_adminlvl(id) == 0){
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
		f_Player[Is_Online][InventoryMaxSize] += Arg_Int[1];
		sk_chat(0, "Játékos: ^3%s ^1(#^3%d^1) | Kapott ^3%i^1 raktár férőhelyet ^4%s^1-től!", sm_PlayerName[Is_Online], Arg_Int[0], Arg_Int[1], szName);
	}
	
	
	return PLUGIN_HANDLED;
}
stock Check_Id_Online(id){
	for(new idx = 0; idx < 33; idx++){
		if(!is_user_connected(idx))
			continue;
					
		if(f_Player[idx][a_UserId] == id)
			return idx;
	}
	return 0;
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

public GameDesc( ) { 
	forward_return( FMV_STRING, fmt("MultiMod %s", VERSION) ); 
	return FMRES_SUPERCEDE; 
}  
new sorskins = -1;
public GiveMeSkins(id)
{
	sorskins++;
	console_print(id, "GiveMeSkins %i", sorskins);
	if(FegyverInfo[sorskins][EntName] == CSW_KNIFE)
	{
		strip_user_weapons(id)
		give_item(id, "weapon_knife")
	}
	else
	{
		strip_user_weapons(id)
		give_item(id, "weapon_ak47")
	}
	entity_set_string(id, EV_SZ_viewmodel, FegyverInfo[sorskins][wlocation]);
	static iWeapon 
	iWeapon = GetPlayerActiveItem(id)
	set_entvar(id, var_weaponanim, 0)
	set_entvar(iWeapon, var_body, FegyverInfo[sorskins][submId])

	if(FegyverInfo[sorskins][EntName] != CSW_KNIFE)
		set_task(1.3, "Csinaljkepet", id)
	else set_task(1.0, "Csinaljkepet", id)

}
GetPlayerActiveItem(id)
{
	return get_member(id, m_pActiveItem)
}
public Csinaljkepet(id)
{
	static iWeapon 
	iWeapon = GetPlayerActiveItem(id)
	set_entvar(id, var_weaponanim, 0)
	set_entvar(iWeapon, var_body, FegyverInfo[sorskins][submId])
	if(sorskins != 1000 && sorskins != 1269)
		set_task(0.5, "ShotMeSkins", id)
}
public ShotMeSkins(id)
{
	client_cmd(id, ";snapshot")
	set_task(0.1, "GiveMeSkins", id)
}
public PrintWeapName(id)
{ 
	set_hudmessage(255, 255, 255, 0.68, 0.85, 0, 6.0, 0.9)
	show_hudmessage(id, fmt("Fegyver: ^n%s%s", FegyverInfo[sorskins][MenuWeapon], FegyverInfo[sorskins][wname]))
}
public CheckMain(id)
{
	if(sk_get_logged(id))
		openMainMenu(id);
}
public plugin_natives()
{
	register_native("get_user_ultimatesounds","native_get_user_ultimatesounds", 1);
	register_native("get_user_dollar","native_get_user_dollar", 1);
	register_native("set_user_dollar","native_set_user_dollar", 1);
	register_native("add_user_dollar","native_add_user_dollar", 1);
	register_native("add_user_dollar_offline","native_add_user_dollar_offline", 1);
	register_native("round_counts","native_round_counts", 1);
	register_native("hud_disabled_all","native_hud_disabled_all", 1);
	register_native("open_weapon_menu", "WeaponMenu", 1);
	//register_native("sm_get_submodel","native_get_user_submodel", 1);
	register_native("sm_get_skindisabled","native_get_user_skindisabled", 1);
	register_native("sm_get_recoilcontrol","native_get_user_recoilcontrol", 1);
	register_native("sm_get_revivesprite","native_get_user_revivesprite", 1);

	register_native("sm_get_quakesounds","native_get_user_quakesounds", 1);
	register_native("sm_get_speclist","native_get_user_speclist", 1);
}
public native_get_user_quakesounds(id)
{
	return f_Player[id][QuakeS];
}
public native_get_user_speclist(id)
{
	return f_Player[id][SpecL];
}

public native_get_user_revivesprite(id)
{
	return f_Player[id][ReviveSprite];
}
public native_get_user_recoilcontrol(id)
{
	return f_Player[id][RecoilControl];
}
public native_get_user_skindisabled(id)
{
	return f_Player[id][Skins];
}
public native_hud_disabled_all(bool:disable)
{
	g_SetHudOff = disable;
}
public Float:native_get_user_dollar(index)
{
	return f_Player[index][Dollar]
}
public Float:native_set_user_dollar(index, Float:amount)
{
	f_Player[index][Dollar] = amount;
	return f_Player[index][Dollar];
}
public Float:native_add_user_dollar(index, Float:amount)
{
	f_Player[index][Dollar] += amount;
	return f_Player[index][Dollar];
}
public Float:native_add_user_dollar_offline(accountid, Float:amount)
{
	new id = get_user_by_accountid(accountid)
	if(id != -1)
	{
		f_Player[id][Dollar] += amount;
		return f_Player[id][Dollar];
	}

	static Query[10048];
	formatex(Query, charsmax(Query), "UPDATE `datas` SET `Dollar` = `Dollar` + ^"%.2f^" WHERE `aid` = ^"%d^";", amount, accountid);
	SQL_ThreadQuery(m_get_sql(), "QuerySetData_OfflineDollar", Query, _, 0);
	return -1.0;
}

public QuerySetData_OfflineDollar(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime)
{
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) 
	{
		log_amx("Error from OfflineDollar:");
		log_amx("%s", Error);
		return;
	}
}
public native_round_counts(rounds[])
{
	param_convert(2);

	new temp[2];
	temp[0] = g_korkezdes;
	temp[1] = get_pcvar_num(SCvar[maxkor]);

	copy(rounds, 2, temp);
}
public native_get_user_ultimatesounds(index)
{
	return f_Player[index][UltimateSound]
}
public Hirdetes()	
{
	switch(random_num(0, 17))
	{
		case 0: sk_chat_lang("%L", "MOD_ADVERT_PREMIUM_POINTS")
		case 1: sk_chat_lang("%L", "MOD_ADVERT_RULES")
		case 2: sk_chat_lang("%L", "MOD_ADVERT_BANS_MUTES")
		case 3: sk_chat_lang("%L", "MOD_ADVERT_BANS_MUTES")
		case 4: sk_chat_lang("%L", "MOD_ADVERT_WEBSITE_TEAMSPEAK")
		case 5: sk_chat_lang("%L", "MOD_ADVERT_EXPLOIT_WARNING")
		case 6: sk_chat_lang("%L", "MOD_ADVERT_WEAPON_CUSTOMIZATION")
		case 7: sk_chat_lang("%L", "MOD_ADVERT_WEAPON_DISMANTLING")
		case 8: sk_chat_lang("%L", "MOD_ADVERT_THIEF_GLOVES")
		case 9..12: sk_chat_lang("%L", get_pcvar_num(SCvar[ppevent]) == 1 ? "MOD_ADVERT_ADMIN_RECRUITMENT_OPEN" : "MOD_ADVERT_ADMIN_RECRUITMENT_CLOSED")
		case 13: sk_chat_lang("%L", "MOD_ADVERT_WEBSITE_UPDATE")
		case 14: sk_chat_lang("%L", "MOD_ADVERT_WEAPON_REPAIR_COST")
		case 15: sk_chat_lang("%L", "MOD_ADVERT_COINFLIP")
		//case 16..17: sk_chat_lang("%L", "MOD_ADVERT_PP_BONUS", "%%")
		case 16: sk_chat_lang("%L", "MOD_ADVERT_TRANSLATION")
		case 17: sk_chat(0, "^4Szerencsejátékba tudsz résztvenni a ^3/dd^1 és ^3/jp <4 számjegy> ^1 segítséggével, vagy a játékgépnél!")
	}
}
public ujkor()
{
	sm_roundstart = 0;
	new id, count;
	new sDateAndTime[40];

	new p_playernum = get_playersnum(1);
	format_time(sDateAndTime, charsmax(sDateAndTime), "%m.%d - %H:%M:%S", get_systime())
	
	g_korkezdes++;

	for(id = 0 ; id < 33 ; id++) 
	{
		if(is_user_connected(id))
		{
			if(f_Player[id][isVip])
			{
				if(get_systime() >= f_Player[id][VipTime] && f_Player[id][VipTime] != -1)
				{
					client_print_color(id, print_team_default, "%s^1Lejárt a ^3VIP/PrémiumVIP^1-ed!", CHATPREFIX)
					f_Player[id][VipTime] = 0;
					f_Player[id][isVip] = 0;
				}
			}

			if(f_Player[id][Tolvajkesztyu])
			{
				if(get_systime() >= f_Player[id][TolvajkesztyuEndTime])
				{
					client_print_color(id, print_team_default, "%s^1Lejárt a ^3Tolvajkesztyűd!", CHATPREFIX)
					f_Player[id][TolvajkesztyuEndTime] = 0;
					f_Player[id][Tolvajkesztyu] = 0;
				}
			}
			if(sk_get_logged(id) && !is_user_bot(id))
			{
				QueryUpdateUserDatas(id);
				QueryUpdateCaseDatas(id);
				QueryUpdateQuestData(id);

				for(new i = 0; i < 16; i++)
					UpdateItem(id, 8, Equipment[id][i][1], 0)
				
			}
				
			if(get_user_adminlvl(id) > 0 && f_Player[id][DisplayAdmin] == 1) 
				count++; 
		} 
	}

	client_print_color(0, print_team_default, "^4%s ^3Kör: ^4%d^1/^4%d ^1| ^3Játékosok: ^4%d^1/^4%d^1 | ^3Idő: ^4%s", CHATPREFIX, g_korkezdes, get_pcvar_num(SCvar[maxkor]), p_playernum, 32, sDateAndTime); 

	new starthours;
	time(starthours)

	if(18 <= starthours && 23 > starthours)
	{
		ExtraFragmentDrop = 1;
		sk_chat(0, "Jelenleg ^4Extra Töredék Drop^1 Event van,^4 18 ^1órától,^4 23 ^1óráig!")
	}
	else
	{
		ExtraFragmentDrop = 0;
		sk_chat(0, "Minden nap ^4Extra Töredék Drop^1 event kezdődik,^4 18^1 órától,^4 23 ^1óráig!")
	}

	if(15 <= starthours && 19 > starthours)
	{
		PrintStreamEvent = 1;
		sk_chat(0, "Jelenleg ^4Printstream Drop^1 Event van,^4 15 ^1órától,^4 19 ^1óráig!")
	}
	else
	{
		PrintStreamEvent = 0;
		sk_chat(0, "Minden nap ^4Printstream Drop^1 event kezdődik,^4 15^1 órától,^4 19 ^1óráig!")
	}
	
	if(g_korkezdes >= get_pcvar_num(SCvar[maxkor])-1)
		client_print_color(0, print_team_default, "^4%s^1 A pályaváltás a ^3következő^1 körben elkeződik!", CHATPREFIX);

	if(g_korkezdes >= get_pcvar_num(SCvar[maxkor]))
	{
		ShowTab();
		set_task(3.0, "pkor");
		sk_chat(0, "Pályaváltás^3 16^1 másodperc múlva ^3elkezdődik!");
	}

	gWPTE = 0;
	gWPCT = 0;
	new Ent;
	while ((Ent = engfunc(EngFunc_FindEntityByString, Ent, "classname", "weapon_awp")))
	{
		if(is_user_connected(pev(Ent, pev_owner)))
		{
			if(cs_get_user_team(pev(Ent, pev_owner)) == CS_TEAM_CT)
				gWPCT++;
			else if(cs_get_user_team(pev(Ent, pev_owner)) == CS_TEAM_T)
				gWPTE++;
		}
	}

}
public ShowTab()
{
	message_begin(MSG_ALL, SVC_INTERMISSION)
	message_end()
}
public pkor()
{
	new fwd_mapchangereturn;
	ExecuteForward(fwd_mapchange,fwd_mapchangereturn);
	engine_changelevel("de_dust2");
}

public cmdSetAdminDisplay(id)
{
	if(get_user_adminlvl(id) == 0)
	{
		client_print_color(id, print_team_default, "%s ^1Ez a command csak ^3adminoknak^1 érhető el!", CHATPREFIX)
		return PLUGIN_HANDLED;
	}

	if(f_Player[id][DisplayAdmin] > 0)
	{
		client_print_color(id, print_team_default, "%s ^1Mostantól nem látja senki, hogy ^3admin^1 vagy!", CHATPREFIX)
		f_Player[id][DisplayAdmin] = 0;
	}
	else if(f_Player[id][DisplayAdmin] < 1)
	{
		client_print_color(id, print_team_default, "%s ^1Mostantól mindenki látja, hogy ^3admin^1 vagy!", CHATPREFIX)
		f_Player[id][DisplayAdmin] = 1;
	}
	return PLUGIN_CONTINUE;
}

public Spawn(id)
{
	if(!is_user_alive(id)) 
		return PLUGIN_HANDLED;

	for(new i = 0 ; i < 16 ; i++) 
	{
		if(gInventory[id][Equipment[id][i][1]][Allapot] < 4 && gInventory[id][Equipment[id][i][1]][w_id] > 16) // Ha az állapot elég rossz, és nem default fegyver
		{
			emit_sound(id, CHAN_WEAPON, "Herboynew/break.wav", 1.0, ATTN_STATIC, 0, PITCH_HIGH );
			sk_chat(id, "Jajj ne, tönkrement a(z) ^3%s%s^1 fegyvered! Fegyver kezeléseknél megtudod javítani!", FegyverInfo[Equipment[id][i][0]][MenuWeapon], FegyverInfo[Equipment[id][i][0]][wname])
			gInventory[id][Equipment[id][i][1]][equipped] = 0;
			UpdateItem(id, 8, Equipment[id][i][1], 0) // sql update.

			gInventory[id][i][equipped] = 1;
			Equipment[id][i][0] = gInventory[id][Equipment[id][i][1]][w_id]
			Equipment[id][i][1] = i; //POSSIBLE WRONG WEAPONS!!!
			UpdateItem(id, 8, i, 0)
		}
	}	

	if(f_Player[id][WinnedRound] < 100)
		f_Player[id][Rang] = 5;

	setPlayerRank(id);

	f_Player[id][Buyed] = 0;
	if(!g_SetHudOff)
		WeaponMenu(id);

	SetModels(id);

	return PLUGIN_CONTINUE;	
}
public SetModels(id)
{
	{
		if(cs_get_user_team(id) == CS_TEAM_T)
		{
			cs_set_user_model(id, "hb_leet", true)
		}
		if(cs_get_user_team(id) == CS_TEAM_CT)
		{
			cs_set_user_model(id, "hb_gign", true)
		}
	}
}

public logevent_end()
{
	gWPCT = 0;
	gWPTE = 0;
}
public SetUserScore(id)
{
	new sizeOfFASZOM = sizeof(FegyverInfo)
	for(new i = 5;i<sizeOfFASZOM;i++)
	{
		AddToInv(id, 1, f_Player[id][a_UserId], i, 100, 1, 0, 0, "", 1, "Addolás", sm_PlayerName[id], f_Player[id][a_UserId], -1)
	}
}
public cmdGiveAll(id)
{
	new bname[33];
	copy(bname, charsmax(bname), sm_PlayerName[id])
	for(new i = 0;i<sizeof(Cases);i++)
	{
		Case[id][i] += 155;
		Key[id][i] += 155
	}
	f_Player[id][NametagTool] += 0;
	f_Player[id][StatTrakTool] += 0;
	f_Player[id][Toredek] += 100000;
	f_Player[id][StatTrakTool]+= 0;
	f_Player[id][NametagTool]+= 0;
	f_Player[id][Dollar] += 1500000 
	if(sk_get_accountid(id) == 1)
	{
		g_PrintstreamVaz[id][1]++;
		g_PrintstreamVaz[id][2]++;
		g_PrintstreamVaz[id][3]++;
		g_PrintstreamVaz[id][4]++;
		g_PrintstreamVaz[id][5]++;
		g_Printstream[id][p_tar]++;
		g_Printstream[id][p_tus]++;
		g_Printstream[id][p_markolat]++;
	}


	f_Player[id][odaadva] = 1;
}
public SecCheck()
{
	sm_roundstart++;
	new p[32],n;
	get_players(p,n,"ch");

	if(g_SetHudOff)
		return;

	for(new i=0;i<n;i++)
	{
		new id = p[i];
		HudX(id);
	}
}
public plugin_precache()
{
	new fegyver = sizeof(FegyverInfo)

	for(new i;i < fegyver; i++)
	{
		if(!FegyverInfo[i][is_deleted])
			precache_model(FegyverInfo[i][wlocation])
	}

	precache_model(ET_model);
	precache_model(ETM_model);
	precache_model(HG_model);
	precache_model(FB_model);
	precache_model(C4_model);
	precache_model(NPCMDL);
	precache_sound("Herboynew/open2.wav");
	precache_sound("Herboynew/break.wav");
	precache_sound("Herboynew/cheer.wav");
	precache_sound("items/gunpickup1.wav");
	precache_sound("items/medshot4.wav");
	precache_sound("Herboynew/buy.wav");

	precache_model("models/player/hb_gign/hb_gign.mdl");
	precache_model("models/player/hb_gign/hb_gignT.mdl");

	precache_model("models/player/hb_leet/hb_leet.mdl");
	precache_model("models/player/hb_leet/hb_leetT.mdl");
}
stock GetWeaponIdByEnt(eWeap)
{
	switch(eWeap)
	{
		case CSW_AK47: eWeap = 0;
		case CSW_M4A1: eWeap = 1;
		case CSW_AWP: eWeap = 2;
		case CSW_DEAGLE: eWeap = 3;
		case CSW_KNIFE: eWeap = 4;
		case CSW_SCOUT: eWeap = 5;
		case CSW_FAMAS: eWeap = 6;
		case CSW_GALIL: eWeap = 7;
		case CSW_M249: eWeap = 8;
		case CSW_TMP: eWeap = 9;
		case CSW_MP5NAVY: eWeap = 10;
		case CSW_P90: eWeap = 11;
		case CSW_M3: eWeap = 12;
		case CSW_XM1014: eWeap = 13;
		case CSW_GLOCK18: eWeap = 14;
		case CSW_USP: eWeap = 15;
		default: eWeap = -1;
	}
	return eWeap
}
stock GetWeaponEntById(eWeap)
{
	switch(eWeap)
	{
		case 0: eWeap = CSW_AK47;
		case 1: eWeap = CSW_M4A1;
		case 2: eWeap = CSW_AWP;
		case 3: eWeap = CSW_DEAGLE;
		case 4: eWeap = CSW_KNIFE;
		case 5: eWeap = CSW_SCOUT;
		case 6: eWeap = CSW_FAMAS;
		case 7: eWeap = CSW_GALIL;
		case 8: eWeap = CSW_M249;
		case 9: eWeap = CSW_TMP;
		case 10: eWeap = CSW_MP5NAVY;
		case 11: eWeap = CSW_P90;
		case 12: eWeap = CSW_M3;
		case 13: eWeap = CSW_XM1014;
		case 14: eWeap = CSW_GLOCK18;
		case 15: eWeap = CSW_USP;
		default: eWeap = -1;
	}
	return eWeap
}
stock GetWeaponVariable(iVari)
{
	switch(iVari)
	{
		case CSW_AK47: iVari = 0;
		case CSW_M4A1: iVari = 0;
		case CSW_AWP: iVari = 0;
		case CSW_DEAGLE: iVari = 1;
		case CSW_KNIFE: iVari = 2;
		case CSW_SCOUT: iVari = 0;
		case CSW_FAMAS: iVari = 0;
		case CSW_GALIL: iVari = 0;
		case CSW_M249: iVari = 0;
		case CSW_TMP: iVari = 0;
		case CSW_MP5NAVY: iVari = 0;
		case CSW_P90: iVari = 0;
		case CSW_M3: iVari = 0;
		case CSW_XM1014: iVari = 0;
		case CSW_GLOCK18: iVari = 1;
		case CSW_USP: iVari = 1;
		default: iVari = -1;
	}
	return iVari
}

public update_weapon_edata(const id, const eItem)
{
	if (is_nullent(eItem))
		return;

	new owner_id = get_entvar(eItem, var_euser1);
	new iWeapon = cs_get_weapon_id(eItem);
	new iWeaponVariable = GetWeaponVariable(iWeapon)

	if(id != owner_id && owner_id != -1)
	{
	 	sm_HudWeapon[id][iWeaponVariable][h_p_id] = owner_id;
		sm_HudWeapon[id][iWeaponVariable][h_w_id] = get_entvar(eItem, var_iuser1);
		sm_HudWeapon[id][iWeaponVariable][h_Allapot] = get_entvar(eItem, var_iuser2);
		sm_HudWeapon[id][iWeaponVariable][h_isStatTraked] = get_entvar(eItem, var_iuser3);
		sm_HudWeapon[id][iWeaponVariable][h_StatTrakKills] = get_entvar(eItem, var_iuser4);
		sm_HudWeapon[id][iWeaponVariable][h_isNameTaged] = get_entvar(eItem, var_euser2);
		get_entvar(eItem, var_message, sm_HudWeapon[id][iWeaponVariable][h_Owner], 33);
		get_entvar(eItem, var_noise2, sm_HudWeapon[id][iWeaponVariable][h_NameTag], 100);
		return;
	}

	new EntWeapon = GetWeaponIdByEnt(iWeapon);

	if(EntWeapon == -1)
		return;
	
	if(!sk_get_logged(id))
	{
		set_entvar(eItem, var_iuser1, EntWeapon);
		return;
	}
	new Item[InventorySystem];
	Item = gInventory[id][Equipment[id][EntWeapon][1]]
	set_entvar(eItem, var_euser1, id);
	set_entvar(eItem, var_iuser1, Item[w_id]);
	set_entvar(eItem, var_iuser2, Item[Allapot]);
	set_entvar(eItem, var_iuser3, Item[isStatTraked]);
	set_entvar(eItem, var_iuser4, Item[StatTrakKills]);
	set_entvar(eItem, var_euser2, Item[isNameTaged]);

	if(FegyverInfo[Item[w_id]][submId] != -1 || f_Player[id][Skins])
		set_entvar(eItem, var_euser3, FegyverInfo[Item[w_id]][submId]);
	else
		set_entvar(eItem, var_euser3, -1);

	set_entvar(eItem, var_message, sm_PlayerName[id]);
	set_entvar(eItem, var_noise2, Item[Nametag]);

	sm_HudWeapon[id][iWeaponVariable][h_p_id] = id;
	sm_HudWeapon[id][iWeaponVariable][h_EntId] = eItem;
	sm_HudWeapon[id][iWeaponVariable][h_w_id] = Item[w_id];
	sm_HudWeapon[id][iWeaponVariable][h_Allapot] = Item[Allapot];
	sm_HudWeapon[id][iWeaponVariable][h_isStatTraked] = Item[isStatTraked];
	sm_HudWeapon[id][iWeaponVariable][h_StatTrakKills] = Item[StatTrakKills];
	sm_HudWeapon[id][iWeaponVariable][h_isNameTaged] = Item[isNameTaged];

	copy(sm_HudWeapon[id][iWeaponVariable][h_NameTag], 32, Item[Nametag]);
	copy(sm_HudWeapon[id][iWeaponVariable][h_Owner], 33, sm_PlayerName[id]);
}

public fw_AddPlayerItem__pre(const id, const eItem)
{
	update_weapon_edata(id, eItem);
}
public RG_ChangeWeapon(iEnt)
{
	if(is_nullent(iEnt))
		return

	new id = get_member(iEnt, m_pPlayer)
	new weapon = rg_get_iteminfo(iEnt, ItemInfo_iId)

	if(!(CSW_P228 <= weapon <= CSW_P90) || !sk_get_logged(id))
		return;

	if(!f_Player[id][Skins] || is_user_bot(id))
	{
		f_Player[id][InHandWeap] = -2;
		return;
	}

	switch(weapon)
	{
		case CSW_HEGRENADE: set_entvar(id, var_viewmodel, HG_model);
		case CSW_FLASHBANG: set_entvar(id, var_viewmodel, FB_model);
		case CSW_C4: set_entvar(id, var_viewmodel, C4_model);
	}

	new EntWeapon = GetWeaponIdByEnt(weapon);
	new weapon_model_id = get_entvar(iEnt, var_iuser1);

	if(f_Player[id][Skins] && EntWeapon != -1)
	{
		if(gInventory[id][Equipment[id][EntWeapon][1]][Allapot] != 101 && EntWeapon == 4)
		{
			gInventory[id][Equipment[id][EntWeapon][1]][firecount]++;

			if(gInventory[id][Equipment[id][EntWeapon][1]][firecount] > 30)
			{
				gInventory[id][Equipment[id][EntWeapon][1]][firecount] = 0;
				gInventory[id][Equipment[id][EntWeapon][1]][Allapot]--;
			}
		}
		f_Player[id][InHandWeap] = GetWeaponVariable(weapon);
		set_entvar(id, var_viewmodel, FegyverInfo[weapon_model_id][wlocation])
	}
	else
		f_Player[id][InHandWeap] = -1;

	return;
}
public weapon_deteriorate(const id, const EntWeapon, const csw_iwpn)
{
	if(!sk_get_logged(id))
		return;
	
	if(EntWeapon == -1)
		return;

	if(gInventory[id][Equipment[id][EntWeapon][1]][Allapot] != 101)
	{
		gInventory[id][Equipment[id][EntWeapon][1]][firecount] += get_user_shot_ammo(id, csw_iwpn);
		
		if(gInventory[id][Equipment[id][EntWeapon][1]][firecount] >= g_ShotsPer1Dmg[EntWeapon])
		{
			gInventory[id][Equipment[id][EntWeapon][1]][firecount] -= g_ShotsPer1Dmg[EntWeapon]; //itt mindig az adott fegyverét kell leszedni
			gInventory[id][Equipment[id][EntWeapon][1]][Allapot]--;
		}

		if(gInventory[id][Equipment[id][EntWeapon][1]][firecount] < 0)
			gInventory[id][Equipment[id][EntWeapon][1]][firecount] = 0;

	}
}
public eDeathMsg()
{
	new Killer = read_data(1);
	new Victim = read_data(2);
	new Headshot = read_data(3);
	
	if(!is_user_connected(Killer) || !is_user_connected(Victim))
		return PLUGIN_HANDLED;

	f_Player[Victim][isDead] = 1;

	if(Killer == Victim)
		return PLUGIN_HANDLED;
	
	new killerWeapon = GetWeaponIdByEnt(cs_get_user_weapon(Killer));

	new esely = random_num(1,100)
	if(esely >= 85) 
		PlaceCase()

	if(esely <= 1)
		hpDobas()

	if(!sk_get_logged(Killer))
		return PLUGIN_HANDLED;
	
	if(f_Player[Killer][isVip] > 0)
		set_user_health(Killer, get_user_health(Killer)+3)

	if(Questing[Killer][is_Questing] == 1) Quest(Killer);
	if(Headshot)
	{
		if(!f_Player[Killer][ScreenEffect])
		{
			message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("ScreenFade"), {0,0,0}, Killer);
			write_short(12000);
			write_short(0);
			write_short(0);
			write_byte(0);
			write_byte(0);
			write_byte(200);
			write_byte(120);
			message_end(); 
		}
		f_Player[Killer][EXP] += random_float(getEXP_HS_Min, getEXP_HS_Max)
		f_Player[Killer][eELO] += random_num(getELOPoints_HS_Min, getELOPoints_HS_Max)
	}
	else
	{
		f_Player[Killer][EXP] += random_float(getEXP_Min, getEXP_Max)
		f_Player[Killer][eELO] += random_num(getELOPoints_Min, getELOPoints_Max)
	}
	if(Victim)
		f_Player[Victim][eELO] -= random_num(remELOPoints_Min, remELOPoints_Max)

	if(PrintStreamEvent)
		PrintstreamDrops(Killer)

	if(gInventory[Killer][Equipment[Killer][killerWeapon][1]][isStatTraked] && sm_HudWeapon[Killer][f_Player[Killer][InHandWeap]][h_p_id] == Killer)
	{
		sm_HudWeapon[Killer][f_Player[Killer][InHandWeap]][h_StatTrakKills]++;
		gInventory[Killer][Equipment[Killer][killerWeapon][1]][StatTrakKills]++;
	}
		

	DropSystem(Killer);
	SetReward(Killer, 0, Victim, Headshot, 50);
	client_print_color(Victim, print_team_default, "^4%s ^1Megölt téged: ^3%s^1 maradt ^3%i^4HP-^1ja!", CHATPREFIX, sm_PlayerName[Killer], get_user_health(Killer));

	return PLUGIN_CONTINUE;
}
public setPlayerRank(id)
{
	new iMaxProfRangNum = 100;
	new Float:iNeededEXP = 40.00+float(f_Player[id][iBattlePassLevel]*10);
	if(f_Player[id][EXP] >= iNeededEXP)
	{
		f_Player[id][iPrivateRank]++;
		if(f_Player[id][iPrivateRank] == iMaxProfRangNum-1)
		{
			//GiveServMedal
			f_Player[id][iPrivateRank] = 0;
		}
		f_Player[id][EXP] -= iNeededEXP;

		if(f_Player[id][iBattlePassLevel] < 79)
			AddBattlePassGift(id)
	}

	new iMaxRangNum = sizeof(Rangok);

	for(new y;y < iMaxRangNum; y++) 
	{
		if(f_Player[id][WinnedRound] > 100)
		{
			if(f_Player[id][eELO] >= Rangok[y][sELO] && f_Player[id][eELO] < Rangok[y+1][sELO]) 
			{
				if(f_Player[id][Rang] == iMaxRangNum-1)
				{
				}
				else 
				{
					f_Player[id][Rang] = y+1;
				}
			}
		}
	}

}
public AddBattlePassGift(id)
{
	if(!f_Player[id][iBattlePassPurch])
		return;

	f_Player[id][iBattlePassLevel]++;
	
	switch(f_Player[id][iBattlePassLevel])
	{
		case 2: f_Player[id][Dollar] += 5.00;
		case 4: f_Player[id][Dollar] += 10.00;
		case 6: f_Player[id][Ajandekcsomagok]++;
		case 8: f_Player[id][Dollar] += 10.00;
		case 10: f_Player[id][EXP] += 20.00;
		case 12: f_Player[id][Dollar] += 15.00;
		case 14: f_Player[id][Ajandekcsomagok]+=5;
		case 16: f_Player[id][StatTrakTool]++;
		case 18: f_Player[id][NametagTool]++;
		case 20: f_Player[id][Dollar] += 10.00;
		case 22:
		{
			if(f_Player[id][Tolvajkesztyu])
			{
				f_Player[id][TolvajkesztyuEndTime] += 86400;
				sk_chat(id, "Mivel van aktív tolvajkesztyűd, ezért kaptál még rá +1 napot!")
			}
			else
			{
				f_Player[id][Tolvajkesztyu] = 1;
				f_Player[id][TolvajkesztyuEndTime] = get_systime()+86400;
			}
		}
		case 24: f_Player[id][EXP] += 30.00;
		case 26: f_Player[id][Dollar] += 30.00;
		case 28: sk_set_pp(id, sk_get_pp(id)+100)
		case 30: f_Player[id][Ajandekcsomagok]+= 10;
		case 32: f_Player[id][EXP] += 40.00;
		case 34: f_Player[id][StatTrakTool]++;
		case 36: f_Player[id][NametagTool]++;
		case 38: f_Player[id][Dollar] += 40.00;
		case 40: f_Player[id][EXP] += 50.00;
		case 42: AddMedal(id, 25)
		case 44: AddToInv(id, 0, f_Player[id][a_UserId], 1268, 15, 0, 0, 0, "", 1, "BattlePass", sm_PlayerName[id], f_Player[id][a_UserId], -1)
		case 46: f_Player[id][StatTrakTool]++;
		case 48: f_Player[id][NametagTool]++;
		case 50: f_Player[id][Dollar] += 80.00;
		case 52: f_Player[id][VipKupon]++;
		case 54: AddToInv(id, 0, f_Player[id][a_UserId], 1269, 15, 0, 0, 0, "", 1, "BattlePass", sm_PlayerName[id], f_Player[id][a_UserId], -1)
		case 56: f_Player[id][Dollar] += 100.00;
		case 58: sk_set_pp(id, sk_get_pp(id)+500)
		case 60: f_Player[id][Ajandekcsomagok]+= 15;
		case 62: AddToInv(id, 0, f_Player[id][a_UserId], 1270, 15, 0, 0, 0, "", 1, "BattlePass", sm_PlayerName[id], f_Player[id][a_UserId], -1)
		case 64: AddBattlePassGift(id);
		case 66: AddToInv(id, 0, f_Player[id][a_UserId], 1271, 15, 0, 0, 0, "", 1, "BattlePass", sm_PlayerName[id], f_Player[id][a_UserId], -1)
		case 68: f_Player[id][TorhetetlenitoKeszlet]++;
		case 70: AddToInv(id, 0, f_Player[id][a_UserId], 1272, 15, 0, 0, 0, "", 1, "BattlePass", sm_PlayerName[id], f_Player[id][a_UserId], -1)
		case 72: sk_set_pp(id, sk_get_pp(id)+2500)
	}
	//tudom, hogy furán néz ki de a mindenkinek üzenet és a sk_chat_lang müködése miatt van fura sorrend
	sk_chat_lang("^4%s^1 ^3BattlePass^1 szintet lépett! Jutalma: ^4%L", BattlePassJutalmak[f_Player[id][iBattlePassLevel]], sm_PlayerName[id])
}
public PrintstreamDrops(id)
{
	new Esely = random(1000);

	if(Esely == 1)
	{
		if(random(6) == 1)
		{
			g_PrintstreamVaz[id][5]++;
			client_cmd(0,"spk ambience/thunder_clap");
			sk_chat(0, "^4%s^1 talált egy: ^4Printstream kés vázat ^3|^1 Esélye:^4 0.033%%", sm_PlayerName[id]);
		}
		else sk_chat(0, "^4%s ^3MAJDNEM^1 talált egy: ^4Printstream kés vázat ^3|^1 Esélye:^4 0.067%%");
	}
	else if(Esely == 2)
	{
		new randomvaz = random_num(1, 4)
		g_PrintstreamVaz[id][randomvaz]++;
		client_cmd(0,"spk ambience/thunder_clap");
		//tudom, hogy furán néz ki de a mindenkinek üzenet és a sk_chat_lang müködése miatt van fura sorrend
		sk_chat_lang("^4%s^1 talált egy: ^4Printstream ^1%L^4 vázat ^3|^1 Esélye:^4 0.05%%", PiacSzures[randomvaz], sm_PlayerName[id])
	}
	else if(Esely == 3)
	{
		g_Printstream[id][p_tus]++;
		client_cmd(0,"spk ambience/thunder_clap");
		sk_chat(0, "^4%s^1 talált egy: ^4Printstream tus-t ^3|^1 Esélye:^4 0.20%%", sm_PlayerName[id])
	}
	else if(Esely == 4)
	{
		g_Printstream[id][p_markolat]++;
		client_cmd(0,"spk ambience/thunder_clap");
		sk_chat(0, "^4%s^1 talált egy: ^4Printstream Markolat ^3|^1 Esélye:^4 0.20%%", sm_PlayerName[id])
	}
	else if(Esely == 5)
	{
		g_Printstream[id][p_tar]++;
		client_cmd(0,"spk ambience/thunder_clap");
		sk_chat(0, "^4%s^1 talált egy: ^4Printstream Tár ^3|^1 Esélye:^4 0.20%%", sm_PlayerName[id])
	}
	else
	{

	}
	return;
}
public PlaceFakeCase( )
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
	set_pev(ent, pev_classname, "fakecase")
	entity_set_model(ent, ET_model)
	dllfunc( DLLFunc_Spawn, ent );
	set_pev( ent, pev_solid, SOLID_BBOX );
	set_pev( ent, pev_movetype, MOVETYPE_NONE );
	engfunc( EngFunc_SetSize, ent, Float:{ -23.160000, -13.660000, -0.050000 }, Float:{ 11.470000, 12.780000, 6.720000 } );
	engfunc( EngFunc_DropToFloor, ent );

	return PLUGIN_HANDLED;
}
public PlaceCase( )
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
		if(is_user_bot(id))
			return FMRES_IGNORED;

		new classname[ 32 ];
		pev( ent, pev_classname, classname, charsmax( classname ) );
		
		if( !equal( classname, "case") )
		{
			return FMRES_IGNORED;
		}
		new szName[32];
		get_user_name(id, szName, charsmax(szName));
		if(id > 32 || id < 1)
			return FMRES_IGNORED;

		if(!sk_get_logged(id))
			return FMRES_IGNORED;

		emit_sound(id, CHAN_WEAPON, "items/gunpickup1.wav", 1.0, ATTN_STATIC, 0, PITCH_HIGH );

		TalalLada(id);

		engfunc( EngFunc_RemoveEntity, ent );
	}
	return FMRES_IGNORED;
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
	entity_set_model(ent, ETM_model)
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

		if(id > 32 || id < 1)
			return FMRES_IGNORED;

		if(!sk_get_logged(id))
			return FMRES_IGNORED;

		new hpd = get_user_health(id)

		if(hpd == 100)
			sk_chat(id, "Ezt a ^3MedKit^1-et nem tudod felvenni, mivel^3 100HP^1-n vagy.")
		else
		{
			set_user_health(id, 100)
			sk_chat(0, "^4%s^1 felvett egy ^3MedKit^1-et, ezért^3 100HP^1-ra lett healelve.", sm_PlayerName[id])
			emit_sound(id, CHAN_WEAPON, "items/medshot4.wav", 1.0, ATTN_STATIC, 0, PITCH_HIGH );
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
	}
	return FMRES_IGNORED;
}
public logevent_round_start()
{
	new hkt = FM_NULLENT;
	while ( ( hkt = fm_find_ent_by_class( hkt, "medkit") ) )
	{
		engfunc( EngFunc_RemoveEntity, hkt );
	}	
}
public TalalLada(id)
{
	new RandomizeDrop;
	RandomizeDrop = random_num(1, 13)

	switch(RandomizeDrop)
	{
		case 1:
		{
			new GetLadasMax = GetCanOpenCases();
			new RandomLada = random(GetLadasMax)
			new MaxAddLada = random_num(1, 3);
			Case[id][RandomLada] += MaxAddLada;

			sk_chat(id, "Találtál: ^4%s Ládát^1(^3%i DB^1) ^3|^1 Esélye:^4 30.00%%", Cases[RandomLada][cName], MaxAddLada)
		}
		case 2:
		{
			new GetLadasMax = GetCanOpenCases();
			new RandomKulcs = random(GetLadasMax)
			new MaxAddKulcs = random_num(1, 3);
			Key[id][RandomKulcs] += MaxAddKulcs;

			sk_chat(id, "Találtál: ^4%s Kulcsot^1(^3%i DB^1) ^3|^1 Esélye:^4 30.00%%", Keys[RandomKulcs][cName], MaxAddKulcs)
		}
		case 3:
		{
			new Float:RandomDollars
			new RandomS = random(5)
			switch(RandomS)
			{
				case 0..3: RandomDollars = random_float(1.0, 3.0)
				case 4: RandomDollars = random_float(5.0, 16.0)
				case 5: RandomDollars = random_float(16.0, 28.0)
			}
			if(RandomS != 5)
				sk_chat(id, "Találtál ^4%3.2f^1$-t! ^3|^1 Esélye:^4 30.00%%", RandomDollars)
			else
				sk_chat(id, "^4%s^1 talált ^4%3.2f^1$-t! ^3|^1 Esélye:^4 15.00%%", sm_PlayerName[id], RandomDollars)
			
			f_Player[id][Dollar] += RandomDollars;
		}
		case 4:
		{
			new RandomToredek
			new RandomS = random(5)
			switch(RandomS)
			{
				case 0..3: RandomToredek = random_num(1, 3)
				case 4: RandomToredek = random_num(5, 40)
				case 5: RandomToredek = random_num(50, 110)
			}
			if(RandomS != 5)
				sk_chat(id, "Találtál: ^4Fegyver Töredék^1(^3%i DB^1) ^3|^1 Esélye:^4 10.00%%", RandomToredek)
			else
				sk_chat(id, "^4%s^1 talált egy: ^4Fegyver Töredék^1(^3%i DB^1) ^3|^1 Esélye:^4 7.00%%", sm_PlayerName[id], RandomToredek)
			
			f_Player[id][Toredek] += RandomToredek;
		}
		case 9:
		{
			new STesely = random_num(0, 100)
			if(STesely == 97)
			{
				sk_chat(0, "^4%s^1 talált egy: ^4StatTrak* Felszerelő ^3|^1 Esélye:^4 3.00%%", sm_PlayerName[id])
				client_cmd(0,"spk ambience/thunder_clap");
				f_Player[id][StatTrakTool]++
			}
			else
				sk_chat(id, "^3MAJDNEM^1 találtál egy: ^4StatTrak* Felszerelő ^3|^1 Ennek esélye:^4 3.00%%")
		}
		case 10:
		{
			new NTesely = random_num(0, 100)
			if(NTesely == 97)
			{
				sk_chat(0, "^4%s^1 talált egy: ^4Névcédula ^3|^1 Esélye:^4 3.00%%", sm_PlayerName[id])
				client_cmd(0,"spk ambience/thunder_clap");
				f_Player[id][NametagTool]++
			}
			else
				sk_chat(id, "^3MAJDNEM^1 találtál egy: ^4Névcédula ^3|^1 Ennek esélye:^4 3.00%%")
		}
		default:
			sk_chat(id, "Ez a láda nem rejtett semmi érdekeset ^3:-(")
	}
	return PLUGIN_HANDLED;
}
public SetReward(id, bombplanted, killed, hs, DropToredek)
{
	new String[128], len, Float:randomdollar, DollarEvent;
	if(f_Player[id][isVip])
		DollarEvent = 1;

	if(DollarEvent == 1)
		randomdollar = random_float(0.08, 0.14)
	else
		randomdollar = random_float(0.02, 0.10)

	f_Player[id][Dollar] += randomdollar;
	len += formatex(String[len], charsmax(String) - len, "^1Jutalom: ^3Dollár: ^4%3.2f$ %s^1| ", randomdollar, DollarEvent == 1 ? "+VIP% " : "");

	if(hs)
	{
		if(get_pcvar_num(SCvar[duplafrag]) == 1)
		{
			set_user_frags(id, get_user_frags(id)+1);
			len += formatex(String[len], charsmax(String) - len, "^3Dupla Frag ^1| ");
		}
		f_Player[id][s_hs]++;
	}

	new RandomDrop = random(DropToredek)
	new LimitToredekDrop;
	if(ExtraFragmentDrop)
		LimitToredekDrop = 10;
	else
		LimitToredekDrop = 5;

	if(RandomDrop <= LimitToredekDrop)
	{
		new randomtoredek;
		if(ExtraFragmentDrop)
			randomtoredek = random_num(1,15)
		else
			randomtoredek = random_num(1,5)
		f_Player[id][Toredek] += randomtoredek;
		len += formatex(String[len], charsmax(String) - len, "^3%i Fegyver töredék ^1| ", randomtoredek);
	}
	if(bombplanted == 1)
		len += formatex(String[len], charsmax(String) - len, "^3A bomba plantolásáért!");
	else if(bombplanted == 2)
		len += formatex(String[len], charsmax(String) - len, "^3A bomba hatástalanításáért!");
	else
	{
		f_Player[id][s_kill]++;
		len += formatex(String[len], charsmax(String) - len, "^3%s^1 megöléséért!", sm_PlayerName[killed]);
		f_Player[killed][s_death]++;
	}
		
	client_print_color(id, print_team_default, "^4%s^1 %s", CHATPREFIX, String)
}
stock GetCanOpenCases()
{
	new iMax = sizeof(Cases);
	new iCanOpen = 0;
	for(new i = 0; i < iMax; i++)
	{
		if(Cases[i][CanDropAndOpenFrom] <= get_systime())
			iCanOpen++;
	}
	return iCanOpen;
}
public DropSystem(id)
{
	/* new Float:RND = random_float(0.00, 10.00); */

	new iChooser = random_num(1,2);
	new Float:fAllChance;

	new m_sizeof = GetCanOpenCases();
	new Float:fDropChance[32];
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
				fDropChance[i] = Keys[i][d_rarity];
				fAllChance += Keys[i][d_rarity];
			}
		}
	}
	new Float:NoDrop = 0.0;
	new Float:PassChance = random_float(0.0, 100.0);
	if(f_Player[id][isVip] > 0)
		NoDrop = 70.00;
	else
		NoDrop = 75.00;

	if(f_Player[id][Tolvajkesztyu])
		NoDrop -= 12.5;

	new Float:NoDropChance = (100.00 - NoDrop) / 100.00;
	
	if(NoDrop > PassChance)
		return;

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

					if(f_Player[id][isVip] > 0)
						client_print_color(0, print_team_default, "^4%s ^4%s^1 Talált egy: ^3%s Ládát^1. ^4(^1VIP Drop: ^3%3.2f%%^4)", CHATPREFIX, sm_PlayerName[id], Cases[i][cName], (fDropChance[i]/(fAllChance/100)*NoDropChance));
					else if(f_Player[id][Tolvajkesztyu])
						client_print_color(0, print_team_default, "^4%s ^4%s^1 Talált egy: ^3%s Ládát^1. ^4(^1Tolvajkesztyű Drop: ^3%3.2f%%^4)", CHATPREFIX, sm_PlayerName[id], Cases[i][cName], (fDropChance[i]/(fAllChance/100)*NoDropChance));
					else
						client_print_color(id, print_team_default, "^4%s Találtál egy: ^3%s Ládát^1. ^4(^1Esélye: ^3%3.2f%%^4)", CHATPREFIX, Cases[i][cName], (fDropChance[i]/(fAllChance/100)*NoDropChance));
				}
				case 2:
				{
					Key[id][i]++;

					if(f_Player[id][isVip] > 0)
						client_print_color(0, print_team_default, "^4%s ^4%s^1 Talált egy: ^3%s Kulcsot^1. ^4(^1VIP Drop: ^3%3.2f%%^4)", CHATPREFIX, sm_PlayerName[id], Keys[i][cName], (fDropChance[i]/(fAllChance/100)*NoDropChance));
					else if(f_Player[id][Tolvajkesztyu])
						client_print_color(0, print_team_default, "^4%s ^4%s^1 Talált egy: ^3%s Kulcsot^1-t. ^4(^1Tolvajkesztyű Drop: ^3%3.2f%%^4)", CHATPREFIX, sm_PlayerName[id], Keys[i][cName], (fDropChance[i]/(fAllChance/100)*NoDropChance));
					else
						client_print_color(id, print_team_default, "^4%s Találtál egy: ^3%s Kulcsot^1-t. ^4(^1Esélye: ^3%3.2f%%^4)", CHATPREFIX, Keys[i][cName], (fDropChance[i]/(fAllChance/100)*NoDropChance));
				}
			}
		}
		Minfloat = MaxFloat;
	}
}

public client_putinserver(id)
{
	get_user_name(id, sm_PlayerName[id], charsmax(sm_PlayerName));

	client_cmd(id, "stop");
	f_Player[id][a_UserId] = 0;
	f_Player[id][SelectedType] = 1
	g_Printstream[id][p_crafttype] = 1;
	f_Player[id][Dollar] = 0.0;
	f_Player[id][SelectedItemToPlace] = -1
	f_Player[id][GepeszKesztyu] = 0;
	f_Player[id][StatTrakTool] = 0;
	f_Player[id][NametagTool] = 0;
	f_Player[id][ScreenEffect] = 0;
	f_Player[id][Toredek] = 0;
	f_Player[id][Skins] = 1;
	f_Player[id][FirstJoin] = 0;
	f_Player[id][Toredek] = 0;
	f_Player[id][OldStyleWeaponMenu] = 0;
	f_Player[id][s_death] = 0;
	f_Player[id][s_kill] = 0;
	f_Player[id][s_hs] = 0;
	f_Player[id][WeaponHud] = 0;
	f_Player[id][DisplayAdmin] = 1;
	f_Player[id][ChatPrefixRemove]= -1
	f_Player[id][ChatPrefixAdded] = -1;
	f_Player[id][ChatPrefix][0] = EOS;
	f_Player[id][SelectedLKToPlaceDarab] = 0;
	f_Player[id][SelectedLKToPlace] = 0;
	f_Player[id][isVip] = 0;
	f_Player[id][VipTime] = 0;
	f_Player[id][SendTemp] = 0;
	f_Player[id][openSelectItemRow] = 0;
	f_Player[id][Rang] = 0;
	f_Player[id][PorgetSys] = 0;
	f_Player[id][PorgetASys] = 0;
	f_Player[id][SetCost] = 0.0;
	Questing[id][is_Questing] = 0;
	Questing[id][QuestKillCount] = 0;
	Questing[id][QuestRare] = 0;
	Questing[id][QuestKill] = 0;
	Questing[id][is_head] = 0;
	Questing[id][QuestWeapon] = 0;
	Questing[id][QuestNametagReward] = 0;
	Questing[id][QuestStatTrakReward] = 0;
	Questing[id][QuestCaseReward] = 0;
	Questing[id][QuestKeyReward] = 0;
	Questing[id][QuestCase] = 0;
	Questing[id][QuestKey] = 0;
	f_Player[id][Tolvajkesztyu] = 0;
	f_Player[id][TolvajkesztyuEndTime] = 0;
	f_Player[id][TorhetetlenitoKeszlet] = 0;
	g_Printstream[id][p_tus] = 0;
	g_Printstream[id][p_tar] = 0;
	g_Printstream[id][p_markolat] = 0;
	g_PrintstreamVaz[id][1] = 0;
	g_PrintstreamVaz[id][2] = 0;
	g_PrintstreamVaz[id][3] = 0;
	g_PrintstreamVaz[id][4] = 0;
	g_PrintstreamVaz[id][5] = 0;

	f_Player[id][Inventory_Size] = 0;
	f_Player[id][InventoryWriteableSize] = 0;
	f_Player[id][InventoryMaxSize] = 0;

	f_Player[id][TradeEnableKit] = 0;
	f_Player[id][OldStyleWeaponMenu] = 0;
	f_Player[id][DeletType] = 0;
	f_Player[id][SelectedForDelete] = 0;
	f_Player[id][RecoilControl] = 0;
	f_Player[id][ReviveSprite] = 0;
	f_Player[id][QuakeS] = 0;
	f_Player[id][SpecL] = 0;

	f_Player[id][EXP] = 0.0;
	f_Player[id][eELO] = 0;
	f_Player[id][WinnedRound] = 0;
	f_Player[id][iPrivateRank] = 0;
	f_Player[id][iBattlePassPurch] = 0;
	f_Player[id][iBattlePassLevel] = 0;
	f_Player[id][iSelectedMedal] = 0;
	f_Player[id][modconnid] = 0;
	f_Player[id][NPCTouch] = false
	f_Player[id][isDead] = 1;

	for(new i;i < sizeof(Cases); i++)
		Case[id][i] = 0;
	for(new i;i < sizeof(Cases); i++)
		Key[id][i] = 0;

	new sTime[64];
	formatCurrentDateAndTime(sTime, charsmax(sTime));
	InventoryClean(id)
}

public InventoryClean(id)
{
  new m_InventoryWriteableSize = f_Player[id][InventoryWriteableSize];
  for(new i;i < m_InventoryWriteableSize;i++)
    gInventory[id][i] = EmptyItem;
}

public HudX(id)
{ 
	new m_Index, iLen, Len;
	new HudString[300], Weapon_Hud[120];
	new MinuteString[20]
	if(sk_get_logged(id))
	{
		if(is_user_alive(id))
		{
			m_Index = id;
			iLen += formatex(HudString[iLen], 300,"Üdv %s(#%i)!^n^n", sm_PlayerName[id], sk_get_accountid(id));
		}
		else
		{
			m_Index = entity_get_int(id, EV_INT_iuser2);
			
			if(m_Index == 0)
				m_Index = id;

			iLen += formatex(HudString[iLen], 300,"Nézett játékos: %s(#%i)^n^n", sm_PlayerName[m_Index], sk_get_accountid(m_Index));
		}
		short_time_length(id, sk_get_playtime(m_Index), timeunit_seconds, MinuteString, charsmax(MinuteString));
		iLen += formatex(HudString[iLen], 300,"[ Dollár: %3.2f$ | PP: %i ]^n", f_Player[m_Index][Dollar], sk_get_pp(m_Index));
		iLen += formatex(HudString[iLen], 300,"[ Töredék: %i | Skinek: %i ]^n", f_Player[m_Index][Toredek], f_Player[m_Index][InventoryWriteableSize]);  
		iLen += formatex(HudString[iLen], 300,"[ Ölés: %i | HS: %i | Halál: %i ]^n", f_Player[m_Index][s_kill], f_Player[m_Index][s_hs], f_Player[m_Index][s_death]);  
		iLen += formatex(HudString[iLen], 300,"[ EXP: %3.2f/%3.2f%%% | Ny. kör: %i | BpLvL: %i ]^n", f_Player[m_Index][EXP], 40.00+float(f_Player[m_Index][iBattlePassLevel]*10), f_Player[m_Index][WinnedRound], f_Player[m_Index][iBattlePassLevel]); 
		iLen += formatex(HudString[iLen], 300,"[ Játszott idő: %s ] ^n", MinuteString);
		if(entity_get_int(id, EV_INT_iuser2) != 0)
			iLen += formatex(HudString[iLen], 300,"[ Pontosság javítás: %s ]", f_Player[m_Index][RecoilControl] == 0 ? "Be" : "Ki");

		if(f_Player[id][WeaponHud] == 0)
		{
			if(f_Player[m_Index][InHandWeap] >= 0)
			{
				new siWeaponVariable = f_Player[m_Index][InHandWeap];
				if(sm_HudWeapon[m_Index][siWeaponVariable][h_p_id] != m_Index && sm_HudWeapon[m_Index][siWeaponVariable][h_p_id] != 0)
					Len += formatex(Weapon_Hud[Len], charsmax(Weapon_Hud)-Len, "^"%s^" fegyvere^n", sm_HudWeapon[m_Index][siWeaponVariable][h_Owner]);
				else
					Len += formatex(Weapon_Hud[Len], charsmax(Weapon_Hud)-Len, "^n");

				if(sm_HudWeapon[m_Index][siWeaponVariable][h_isNameTaged])
					Len += formatex(Weapon_Hud[Len], charsmax(Weapon_Hud)-Len, "^"%s^"", sm_HudWeapon[m_Index][siWeaponVariable][h_NameTag]);
				else
					Len += formatex(Weapon_Hud[Len], charsmax(Weapon_Hud)-Len, "%s%s", FegyverInfo[sm_HudWeapon[m_Index][siWeaponVariable][h_w_id]][MenuWeapon], FegyverInfo[sm_HudWeapon[m_Index][siWeaponVariable][h_w_id]][wname]);

				if(sm_HudWeapon[m_Index][siWeaponVariable][h_isStatTraked] == 1)
					Len += formatex(Weapon_Hud[Len], charsmax(Weapon_Hud)-Len, " | %L %i", id, "MOD_HUD_KILLS", sm_HudWeapon[m_Index][siWeaponVariable][h_StatTrakKills]);

				if(sm_HudWeapon[m_Index][siWeaponVariable][h_Allapot] == 101 && sm_HudWeapon[m_Index][siWeaponVariable][h_w_id] > 15)
				{ 
					set_hudmessage(255, 200, 0, -1.0, 0.70, 0, 6.0, 1.01, 0.0, 0.0, next_hudchannel(id));
					formatex(Weapon_Hud[Len], charsmax(Weapon_Hud)-Len, "^n%L", id , "MOD_HUD_UNBREAKABLE"); 
				}
				else if(sm_HudWeapon[m_Index][siWeaponVariable][h_Allapot] == 101 && sm_HudWeapon[m_Index][siWeaponVariable][h_w_id] < 16)
					set_hudmessage(255, 255, 255, -1.0, 0.70, 0, 6.0, 1.01, 0.0, 0.0, next_hudchannel(id));
				else if(sm_HudWeapon[m_Index][siWeaponVariable][h_Allapot] > 10 && sm_HudWeapon[m_Index][siWeaponVariable][h_w_id] > 15)
				{ 
					formatex(Weapon_Hud[Len], charsmax(Weapon_Hud)-Len, "^n%L %i%s", id , "MOD_HUD_USAGE", sm_HudWeapon[m_Index][siWeaponVariable][h_Allapot], "%");
					set_hudmessage(255, 255, 255, -1.0, 0.70, 0, 6.0, 1.01, 0.0, 0.0, next_hudchannel(id));
				}
				else if(sm_HudWeapon[m_Index][siWeaponVariable][h_Allapot] <= 10)
				{
					formatex(Weapon_Hud[Len], charsmax(Weapon_Hud)-Len, "^n%L %i%s", id , "MOD_HUD_USAGE", sm_HudWeapon[m_Index][siWeaponVariable][h_Allapot], "%");
					set_hudmessage(255, 0, 0, -1.0, 0.70, 0, 6.0, 1.01, 0.0, 0.0, next_hudchannel(id));
				}
				
				ShowSyncHudMsg(id, bSync, Weapon_Hud);
			}
			else if(is_user_alive(m_Index) && f_Player[m_Index][InHandWeap] == -1)
			{
				new swid = cs_get_user_weapon(m_Index);
				switch(swid)
				{
					case CSW_FIVESEVEN: Len = formatex(Weapon_Hud[Len], charsmax(Weapon_Hud)- Len, "Heal Gránát");
					case CSW_HEGRENADE: Len = formatex(Weapon_Hud[Len], charsmax(Weapon_Hud)- Len, "HE Grenade");
					case CSW_FLASHBANG: Len = formatex(Weapon_Hud[Len], charsmax(Weapon_Hud)- Len, "FLASHBANG");
					case CSW_C4: Len = formatex(Weapon_Hud[Len], charsmax(Weapon_Hud)- Len, "C4");
					case CSW_AUG: Len = formatex(Weapon_Hud[Len], charsmax(Weapon_Hud)- Len, "Default AUG");
					case CSW_MAC10: Len = formatex(Weapon_Hud[Len], charsmax(Weapon_Hud)- Len, "Default MAC10");
					case CSW_UMP45: Len = formatex(Weapon_Hud[Len], charsmax(Weapon_Hud)- Len, "Default UMP");
					default: Len = formatex(Weapon_Hud[Len], charsmax(Weapon_Hud)- Len, "");
				}

				set_hudmessage(255, 255, 255, -1.0, 0.70, 0, 6.0, 1.01, 0.0, 0.0, next_hudchannel(id));
				ShowSyncHudMsg(id, bSync, Weapon_Hud);
			}
		}
	}
	else
	{
		iLen += formatex(HudString[iLen], 300,"Üdv %s!^n^n", sm_PlayerName[id]);
		iLen += formatex(HudString[iLen], 300,"Regisztrálj vagy Jelentkezz be!^nElfelejtett jelszó: wwww.herboyd2.hu/forgetpassword^n^n");
		iLen += formatex(HudString[iLen], 300,"www.herboyd2.hu ~ 2018-2024");
	}
	if(f_Player[id][Huds] == 0)
	{
		set_hudmessage(random(255), random(255), random(255), 0.01, 0.15, 0, 6.0, 1.01, 0.0, 0.0, next_hudchannel(id));
		ShowSyncHudMsg(id, aSync, HudString);
	}
}
public openMainMenu(id)
{
	if(!sk_get_logged(id))
		return;

	//CheckMedal(id, 2)
	//CheckMedal(id, 3)
	ArrayClear(g_Buy[id])
	Load_Data(id, "buy_datas", "QueryLoadBuyDatas")

	new iras[121];
	format(iras, charsmax(iras), "%s %L", MENUPREFIX, id, "MOD_MENU_MAIN_TITLE", f_Player[id][Dollar], sk_get_pp(id));
	new menu = menu_create(iras, "openMainMenu_h");
	new PiacSize = ArraySize(g_Market)
	new maxpiac, Market[MarketSystem]
	for(new i = 0; i < PiacSize;i++)
	{
		ArrayGetArray(g_Market, i, Market);

		if(Market[m_cost] > 0)
		{
			maxpiac++;
			continue;
		}
	}
	menu_additem(menu, fmt("\y|\d-\r-\y[ \wRaktár \y(\d%i\w/\r%i\y) \y]\r-\d-\y|", f_Player[id][Inventory_Size], f_Player[id][InventoryMaxSize]), "1")
	menu_additem(menu, fmt("\y|\d-\r-\y[ %L \y]\r-\d-\y|", id, "MOD_MENU_MAIN_CASE_OPENING"),"2");
	menu_additem(menu, fmt("\y|\d-\r-\y[ %L \y]\r-\d-\y|", id, "MOD_MENU_MAIN_MARKET", maxpiac),"3");
	menu_additem(menu, fmt("\y|\d-\r-\y[ %L \y]\r-\d-\y|", id, "MOD_MENU_MAIN_SETTINGS"),"4");
	menu_additem(menu, fmt("\y|\d-\r-\y[ %L \y]\r-\d-\y|", id, "MOD_MENU_MAIN_QUESTS"),"5");
	menu_additem(menu, fmt("\y|\d-\r-\y[ \wKuka \y]\r-\d-\y|"), "17")
	menu_additem(menu, fmt("\y|\d-\r-\y[ \wFegyver kezelés \y]\r-\d-\y|"), "16")
	menu_additem(menu, fmt("\y|\d-\r-\y[ \wBattlePass \y]\r-\d-\y|"), "6")
	//menu_additem(menu, fmt("\y|\d-\r-\y[ %L \y]\r-\d-\y|", id, "MOD_MENU_MAIN_WEAPON_VIEWER"),"6");
	menu_additem(menu, fmt("\y|\d-\r-\y[ %L \y]\r-\d-\y|", id, "MOD_MENU_MAIN_STORE"),"9");

	menu_additem(menu, fmt("\y|\d-\r-\y[ %L \y]\r-\d-\y|", id, "MOD_MENU_MAIN_PLAYER_MUTE"),"10");
	menu_additem(menu, fmt("\y|\d-\r-\y[ %L \y]\r-\d-\y|", id, "MOD_MENU_MAIN_PLAYER_REPORT"),"12");
	menu_additem(menu, fmt("\y|\d-\r-\y[ %L \y]\r-\d-\y|", id, "MOD_MENU_MAIN_PRINTSTREAM_CRAFTING"), "13")
	menu_additem(menu, fmt("\y|\d-\r-\y[ %L \y]\r-\d-\y|", id, "MOD_MENU_MAIN_GAMBLING"), "14")
	menu_additem(menu, fmt("\y|\d-\r-\y[ \wAjándékcsomagok \y]\r-\d-\y|"), "15")

	menu_setprop(menu, MPROP_NEXTNAME, fmt("\y%L", id, "GENERAL_MENU_NEXT"));
	menu_setprop(menu, MPROP_BACKNAME, fmt("\d%L", id, "GENERAL_MENU_BACK"));
	menu_setprop(menu, MPROP_EXITNAME, fmt("\r%L", id, "GENERAL_MENU_EXIT"));

	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	menu_display(id, menu);
}
public openMainMenu_h(id, menu, item){
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
			f_Player[id][SwitchingOnMarket] = 0;
			f_Player[id][openSelectItemRow] = 0;
			openInventorySwitch(id);
		}
		case 2: 
		{
			f_Player[id][SwitchingOnMarket] = 0;
			f_Player[id][openSelectItemRow] = 0;
			openCaseSwitch(id);
		}
		case 3: openMarketMenu(id);
		case 4: 
		{
			openSettings(id, 0, 0);
		}
		case 5:
		{ 
			if(Questing[id][is_Questing] == 1)
				openQuestMenu(id)
			else CreateQuest(id)
		}
		case 6: openBattlePass(id, 0)
		case 7: openFegyverCraftMenu(id);
		case 8: openWeaponSeeMenu(id, 0);
		case 9:{
		openAruhaz(id);
		} 
		case 10: openPlayerChooserMute(id)
		case 11: client_cmd(id, "say /pm")
		case 12: client_cmd(id, "new_jelent")
		case 13: openFegyverCraftMenu(id)
		case 14: openSzerencsejatek(id)
		case 15: openAjandekCsomag(id)
		case 16: 
		{
			f_Player[id][SwitchingOnMarket] = 0;
			f_Player[id][openSelectItemRow] = 1;
			openInventorySwitch(id);
		}
		case 17: 
		{
			f_Player[id][SwitchingOnMarket] = 0;
			f_Player[id][openSelectItemRow] = 4;
			openInventorySwitch(id);
		}
	}
}
public Kuka_Menu(id, _SelectedForDelete)
{
	new iras[121], String[121], Item[InventorySystem];
	format(iras, charsmax(iras), "\d%s \r[ \wKuka\r ]", MENUPREFIX);
	new menu = menu_create(iras, "Kuka_h");
	f_Player[id][SelectedForDelete] = _SelectedForDelete;
	if(_SelectedForDelete == -1)
	{
		menu_additem(menu, "\wKiválasztott fegyver:\d Nincs (Katt)", "1", 0);
	}
	else
	{
		Item = gInventory[id][_SelectedForDelete];
		formatex(String, charsmax(String), "\wKiválasztott fegyver:\r %s%s", FegyverInfo[Item[w_id]][MenuWeapon], FegyverInfo[Item[w_id]][wname]);
		menu_additem(menu, String, "1", 0);
	}
	switch(f_Player[id][DeletType])
	{
		case 0: menu_additem(menu, "\wTörlési mód: \rEz a fegyver", "2", 0);
		case 1: menu_additem(menu, "\wTörlési mód: \rÖsszes skin", "2", 0);
		case 2: menu_additem(menu, "\wTörlési mód: \rÖsszes ilyen skin", "2", 0);
	}
	menu_addblank2(menu);
	switch(f_Player[id][DeletType])
	{
		case 0: menu_addtext2(menu, "\r*\w Csak a kiválasztott fegyver törlödik!\r *");
		case 1: menu_addtext2(menu, "\r*\w Összes fegyver, ami nem kés, és nem stattrakos ^nvagy nem névcédulázott, és nem törhetetlen \y(Saját felelősségre!)\r *");
		case 2: menu_addtext2(menu, fmt("\r*\w Minden ilyen (%s%s\w) kinézetű fegyvert töröl, ^nami nem Névcédulázott, nem StatTrakozott, nem törhetetlen\r *", FegyverInfo[Item[w_id]][MenuWeapon], FegyverInfo[Item[w_id]][wname]));
	}
	menu_addblank2(menu);
	if(_SelectedForDelete == -1)
		menu_additem(menu, "\dTÖRLÉS", "3", ADMIN_ADMIN);
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
			f_Player[id][SwitchingOnMarket] = 0;
			f_Player[id][openSelectItemRow] = 4;
			openInventorySwitch(id);
		}
		case 2:
		{
			f_Player[id][DeletType]++;
			if(f_Player[id][DeletType] > 2)
				f_Player[id][DeletType] = 0;

			Kuka_Menu(id, f_Player[id][SelectedForDelete]);
		}
		case 3:
		{
			if(f_Player[id][SelectedForDelete] != -1)
				BeginDelete(id);
			else
				client_print_color(id, print_team_default, "^4%s^1Előbb válassz ki egy fegyvert!", CHATPREFIX)
		}
	}
	return PLUGIN_HANDLED;
}
public BeginDelete(id)
{
	new _SelectedForDelete = f_Player[id][SelectedForDelete];

	switch(f_Player[id][DeletType])
	{
		case 0:	DeleteWeapon(id, _SelectedForDelete);
		case 1:
		{
			new Item[InventorySystem];
			Item = gInventory[id][_SelectedForDelete];
			
			new TempItem[InventorySystem];
			for(new i = 0; i < f_Player[id][InventoryWriteableSize];i++)
			{
				TempItem = gInventory[id][i];
				if(TempItem[isNameTaged] || TempItem[isStatTraked] || FegyverInfo[TempItem[w_id]][EntName] == CSW_KNIFE || TempItem[Allapot] == 101 || TempItem[w_id] < 16)
					continue;
				
				DeleteWeapon(id, i);
			}
		}
		case 2:
		{
			new Item[InventorySystem];
			Item = gInventory[id][_SelectedForDelete];
			
			new TempItem[InventorySystem];
			for(new i = 0; i < f_Player[id][InventoryWriteableSize];i++)
			{
				TempItem = gInventory[id][i];
				if(TempItem[w_id] != Item[w_id] || TempItem[isNameTaged] || TempItem[isStatTraked] || TempItem[Allapot] == 101 || TempItem[w_id] < 16)
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
	Item = gInventory[id][ArrayIndex];
	if(Item[w_id] < 16 || Item[equipped])
		return false;
	if(!Item[deleted] && Item[w_userid] == f_Player[id][a_UserId] && Item[equipped] == 0)
	{
		new t_reward = GetRewardToredek(id, ArrayIndex);
		
		gInventory[id][ArrayIndex][deleted] = 1;
		f_Player[id][Inventory_Size]--;
		f_Player[id][Toredek] += t_reward;
		client_print_color(id, print_team_default, "^4%s^1 Sikeresen törölted ^4%s%s^1 fegyvert, kaptál érte ^4%i^1 töredéket.", CHATPREFIX, FegyverInfo[Item[w_id]][MenuWeapon], FegyverInfo[Item[w_id]][wname], t_reward)
		UpdateItem(id, 7, ArrayIndex, 0)
		f_Player[id][SelectedForDelete] = -1;
		smlog(id, 0, 0, "DEL_WEAPON", "none", fmt("[%s %s] ~ [SQLID: #%i] OpenTime: %i | WeaponID: %i | Durability: %i | StatTraked: %i | NameTag: %s ~ OpenedFrom: %s | GivedFragments: %i", FegyverInfo[gInventory[id][ArrayIndex][w_id]][wname], FegyverInfo[gInventory[id][ArrayIndex][w_id]][ChatWeapon], gInventory[id][ArrayIndex][sqlid], gInventory[id][ArrayIndex][opened], gInventory[id][ArrayIndex][w_id], gInventory[id][ArrayIndex][Allapot], gInventory[id][ArrayIndex][isStatTraked], gInventory[id][ArrayIndex][Nametag], gInventory[id][ArrayIndex][openedfrom], t_reward))		
	}
	else
		return false;
	return true;
}
public GetRewardToredek(id, w_Index)
{
	new RewardToredek = 0;

	new Item[InventorySystem]
	Item = gInventory[id][w_Index];

	if(Item[Allapot] == -101)
		RewardToredek += 50000;

	if(Item[Allapot] < 21)
		RewardToredek += 15;
	else if(Item[Allapot] < 41)
		RewardToredek += 20;
	else if(Item[Allapot] < 61)
		RewardToredek += 30;
	else if(Item[Allapot] < 81)
		RewardToredek += 40;
	else if(Item[Allapot] < 101)
		RewardToredek += 50;

	if(Item[isNameTaged] && Item[StatTrakKills] > 150)
		RewardToredek += 50;

	if(Item[isStatTraked] && Item[StatTrakKills] > 150)
		RewardToredek += 50;

	if(FegyverInfo[Item[w_id]][EntName] == CSW_KNIFE)
		RewardToredek += random_num(500, 2000);

	return RewardToredek;
}
public openAjandekCsomag(id)
{
	new String[121];
	new menu = menu_create(fmt("\d%s \r[ \wAjándékcsomagok \r]", MENUPREFIX), "openAjandek_h");
	menu_additem(menu, fmt("Sima ajándékcsomag \r[\w%i DB\r]", f_Player[id][Ajandekcsomagok]), "1")
	
	if(Ajandekcsomag[id][5] == 1) 
		format(String,charsmax(String),"Kezdő ajándékcsomag \r[\dElhasználva\r]");
	else
		format(String,charsmax(String),"Kezdő ajándékcsomag \r[\yElérhető\r]");
	menu_additem(menu,String,"2");

	if(sk_get_playtime(id) > 259200 && Ajandekcsomag[id][0] == 1) 
		format(String,charsmax(String),"Örökség ajándékcsomag \r[\dElhasználva\r]");
	else if(sk_get_playtime(id) > 259200)
		format(String,charsmax(String),"Örökség ajándékcsomag \r[\yElérhető\r]");
	else
		format(String,charsmax(String),"Örökség ajándékcsomag \r[\d3 nap Játékidő\r]");
	menu_additem(menu,String,"3");

	if(sk_get_playtime(id) > 604800 && Ajandekcsomag[id][1] == 1) 
		format(String,charsmax(String),"Lázadó ajándékcsomag \r[\dElhasználva\r]");
	else if(sk_get_playtime(id) > 604800)
		format(String,charsmax(String),"Lázadó ajándékcsomag \r[\yElérhető\r]");
	else
		format(String,charsmax(String),"Lázadó ajándékcsomag \r[\d7 nap Játékidő\r]");
	menu_additem(menu,String,"4");

	if(sk_get_playtime(id) > 1296000 && Ajandekcsomag[id][2] == 1) 
		format(String,charsmax(String),"Misztikus ajándékcsomag \r[\dElhasználva\r]");
	else if(sk_get_playtime(id) > 1296000)
		format(String,charsmax(String),"Misztikus ajándékcsomag \r[\yElérhető\r]");
	else
		format(String,charsmax(String),"Misztikus ajándékcsomag \r[\d15 Nap Játékidő\r]");
	menu_additem(menu,String,"5");

	if(sk_get_playtime(id) > 2160000 && Ajandekcsomag[id][3] == 1) 
		format(String,charsmax(String),"Hősies ajándékcsomag \r[\dElhasználva\r]");
	else if(sk_get_playtime(id) > 2160000)
		format(String,charsmax(String),"Hősies ajándékcsomag \r[\yElérhető\r]");
	else
		format(String,charsmax(String),"Hősies ajándékcsomag \r[\d25 Nap Játékidő\r]");
	menu_additem(menu,String,"6");

	if(sk_get_playtime(id) > 4320000 && Ajandekcsomag[id][4] == 1) 
		format(String,charsmax(String),"Nemesis ajándékcsomag \r[\dElhasználva\r]");
	else if(sk_get_playtime(id) > 4320000)
		format(String,charsmax(String),"Nemesis ajándékcsomag \r[\yElérhető\r]");
	else
		format(String,charsmax(String),"Nemesis ajándékcsomag \r[\d50 Nap Játékidő\r]");
	menu_additem(menu,String,"7");

	menu_setprop(menu, MPROP_NEXTNAME, fmt("%L", id, "GENERAL_MENU_NEXT"));
	menu_setprop(menu, MPROP_BACKNAME, fmt("%L", id, "GENERAL_MENU_BACK"));
	menu_setprop(menu, MPROP_EXITNAME, fmt("%L", id, "GENERAL_MENU_EXIT"));
	menu_display(id, menu, 0);
}
public openAjandek_h(id, menu, item)
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
			if(f_Player[id][Ajandekcsomagok] > 0)
			{
				f_Player[id][Ajandekcsomagok] -= 1;
				new RandomizeDrop1;
				RandomizeDrop1 = random_num(1, 25)

				switch(RandomizeDrop1)
				{
					case 1:
					{
						new GetLadasMax = GetCanOpenCases();
						new RandomLada = random(GetLadasMax)
						new MaxAddLada = random_num(1, 2);
						Case[id][RandomLada] += MaxAddLada;

						sk_chat(id, "Találtál: ^4%s Ládát^1(^3%i DB^1) ^3|^1 Esélye:^4 30.00%%", Cases[RandomLada][cName], MaxAddLada)
					}
					case 2:
					{
						new GetLadasMax = GetCanOpenCases();
						new RandomKulcs = random(GetLadasMax)
						new MaxAddKulcs = random_num(1, 2);
						Key[id][RandomKulcs] += MaxAddKulcs;

						sk_chat(id, "Találtál: ^4%s Kulcsot^1(^3%i DB^1) ^3|^1 Esélye:^4 30.00%%", Keys[RandomKulcs][cName], MaxAddKulcs)
					}
					case 3:
					{
						new Float:RandomDollars
						new RandomS = random(5)
						switch(RandomS)
						{
							case 0..3: RandomDollars = random_float(1.0, 3.0)
							case 4: RandomDollars = random_float(5.0, 10.0)
							case 5: RandomDollars = random_float(11.0, 16.0)
						}
						if(RandomS != 5)
							sk_chat(id, "Találtál ^4%3.2f^1$-t! ^3|^1 Esélye:^4 30.00%%", RandomDollars)
						else
							sk_chat(id, "^4%s^1 talált ^4%3.2f^1$-t! ^3|^1 Esélye:^4 15.00%%", sm_PlayerName[id], RandomDollars)
						
						f_Player[id][Dollar] += RandomDollars;
					}
					case 4:
					{
						new RandomToredek
						new RandomS = random(5)
						switch(RandomS)
						{
							case 0..3: RandomToredek = random_num(1, 3)
							case 4: RandomToredek = random_num(5, 40)
							case 5: RandomToredek = random_num(50, 110)
						}
						if(RandomS != 5)
							sk_chat(id, "Találtál: ^4Fegyver Töredék^1(^3%i DB^1) ^3|^1 Esélye:^4 10.00%%", RandomToredek)
						else
							sk_chat(id, "^4%s^1 talált egy: ^4Fegyver Töredék^1(^3%i DB^1) ^3|^1 Esélye:^4 7.00%%", sm_PlayerName[id], RandomToredek)
						
						f_Player[id][Toredek] += RandomToredek;
					}
					case 9:
					{
						new STesely = random_num(1, 101)
						if(STesely >= 97)
						{
							sk_chat(0, "^4%s^1 talált egy: ^4StatTrak* Felszerelő ^3|^1 Esélye:^4 3.00%%", sm_PlayerName[id])
							client_cmd(0,"spk ambience/thunder_clap");
							f_Player[id][StatTrakTool]++
						}
						else
							sk_chat(id, "^3MAJDNEM^1 találtál egy: ^4StatTrak* Felszerelő ^3|^1 Ennek esélye:^4 3.00%%")
					}
					case 10:
					{
						new NTesely = random_num(1, 101)
						if(NTesely >= 97)
						{
							sk_chat(0, "^4%s^1 talált egy: ^4Névcédula ^3|^1 Esélye:^4 3.00%%", sm_PlayerName[id])
							client_cmd(0,"spk ambience/thunder_clap");
							f_Player[id][NametagTool]++
						}
						else
							sk_chat(id, "^3MAJDNEM^1 találtál egy: ^4Névcédula ^3|^1 Ennek esélye:^4 3.00%%")
					}
					default:
						sk_chat(id, "Ez az ajándékcsomag nem rejtett semmi érdekeset ^3:-(")
				}
				openAjandekCsomag(id)
			}
			else sk_chat(id,  "^3Sajnálom, ^1de nincs elég ^3ajándékcsomagod!");
		}
		case 2:
		{
			if(Ajandekcsomag[id][5] == 0)
			{
				f_Player[id][Ajandekcsomagok] += 2;
				f_Player[id][Dollar] += 10.00;
				Ajandekcsomag[id][5] = 1;
				
				sk_chat(id,  "^3Sikeresen ^1megkaptad a ^3Kezdő ^1csomagot!");
				updateReward(id, 5)
			}
			else sk_chat(id,  "^3Sajnálom, ^1de te már elhasználtad ezt a ^3csomagot!");
		}
		case 3:
		{
			if(Ajandekcsomag[id][0] == 0 && sk_get_playtime(id) > 259200)
			{
				f_Player[id][Ajandekcsomagok] += 5;
				f_Player[id][Dollar] += 20.00;
				Ajandekcsomag[id][0] = 1;
				
				sk_chat(id,  "^3Sikeresen ^1megkaptad a ^3Örökség ^1csomagot!");
				updateReward(id, 0)
			}
			else if(sk_get_playtime(id) < 259200)
				sk_chat(id,  "^3Sajnálom, ^1de te még nem tudod megkapni ezt a ^3csomagot!");
			else 
				sk_chat(id,  "^3Sajnálom, ^1de te már elhasználtad ezt a ^3csomagot!");
		}
		case 4:
		{
			if(Ajandekcsomag[id][1] == 0 && sk_get_playtime(id) > 604800)
			{
				f_Player[id][Ajandekcsomagok] += 10;
				f_Player[id][Dollar] += 50.00;
				Ajandekcsomag[id][1] = 1;
				
				sk_chat(id,  "^3Sikeresen ^1megkaptad a ^3Lázadó ^1csomagot!");
				updateReward(id, 1)
			}
			else if(sk_get_playtime(id) < 604800)
				sk_chat(id,  "^3Sajnálom, ^1de te még nem tudod megkapni ezt a ^3csomagot!");
			else 
				sk_chat(id,  "^3Sajnálom, ^1de te már elhasználtad ezt a ^3csomagot!");
		}
		case 5:
		{
			if(Ajandekcsomag[id][2] == 0 && sk_get_playtime(id) > 1296000)
			{
				f_Player[id][Ajandekcsomagok] += 10;
				f_Player[id][Dollar] += 50.00;

				Ajandekcsomag[id][2] = 1;

				new GetLadasMax = GetCanOpenCases();
				new RandomLada = random(GetLadasMax)
				new MaxAddLada = random_num(1, 3);
				Case[id][RandomLada] += MaxAddLada;

				new GetKulcsMax = GetCanOpenCases();
				new RandomKulcs = random(GetKulcsMax)
				new MaxAddKulcs = random_num(1, 3);
				Key[id][RandomKulcs] += MaxAddKulcs;
				updateReward(id, 2)
				
				sk_chat(id,  "^3Sikeresen ^1megkaptad a ^3Misztikus ^1csomagot!");
			}
			else if(sk_get_playtime(id) < 1296000)
				sk_chat(id,  "^3Sajnálom, ^1de te még nem tudod megkapni ezt a ^3csomagot!");
			else 
				sk_chat(id,  "^3Sajnálom, ^1de te már elhasználtad ezt a ^3csomagot!");
		}
		case 6:
		{
			if(Ajandekcsomag[id][3] == 0 && sk_get_playtime(id) > 2160000)
			{
				f_Player[id][Ajandekcsomagok] += 20;
				f_Player[id][Dollar] += 80.00;

				Ajandekcsomag[id][3] = 1;

				new GetLadasMax = GetCanOpenCases();
				new RandomLada = random(GetLadasMax)
				new MaxAddLada = random_num(1, 6);
				Case[id][RandomLada] += MaxAddLada;

				new GetKulcsMax = GetCanOpenCases();
				new RandomKulcs = random(GetKulcsMax)
				new MaxAddKulcs = random_num(1, 6);
				Key[id][RandomKulcs] += MaxAddKulcs;
				
				sk_chat(id,  "^3Sikeresen ^1megkaptad a ^3Hősies ^1csomagot!");
				updateReward(id, 3)
			}
			else if(sk_get_playtime(id) < 2160000)
				sk_chat(id,  "^3Sajnálom, ^1de te még nem tudod megkapni ezt a ^3csomagot!");
			else 
				sk_chat(id,  "^3Sajnálom, ^1de te már elhasználtad ezt a ^3csomagot!");
		}
		case 7:
		{
			if(Ajandekcsomag[id][4] == 0 && sk_get_playtime(id) > 4320000)
			{
				f_Player[id][Ajandekcsomagok] += 30;
				f_Player[id][Dollar] += 250.00;

				Ajandekcsomag[id][4] = 1;

				new GetLadasMax = GetCanOpenCases();
				new RandomLada = random(GetLadasMax)
				new MaxAddLada = random_num(1, 10);
				Case[id][RandomLada] += MaxAddLada;

				new GetKulcsMax = GetCanOpenCases();
				new RandomKulcs = random(GetKulcsMax)
				new MaxAddKulcs = random_num(1, 15);
				Key[id][RandomKulcs] += MaxAddKulcs;
				
				sk_chat(id,  "^3Sikeresen ^1megkaptad a ^3Nemesis ^1csomagot!");
				updateReward(id, 4)
			}
			else if(sk_get_playtime(id) < 4320000)
				sk_chat(id,  "^3Sajnálom, ^1de te még nem tudod megkapni ezt a ^3csomagot!");
			else 
				sk_chat(id,  "^3Sajnálom, ^1de te már elhasználtad ezt a ^3csomagot!");
		}
	}
}
public updateReward(id, iReward)
{
	new Data[1];
	static Query[10048];
	Data[0] = id;
	formatex(Query, charsmax(Query), "UPDATE `datas` SET `iRew%i` = 1 WHERE `aid` = %d;", iReward, sk_get_accountid(id));
	SQL_ThreadQuery(m_get_sql(), "QuerySetData_Reward", Query, Data, 1);
}
public QuerySetData_Reward(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime)
{
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) 
	{
		log_amx("Error from updateReward:");
		log_amx("%s", Error);
		return;
	}
}
public openBattlePass(id, leveling)
{
	new szMenu[121];
	new menu = menu_create(fmt("\d%s \r[ \wBattlePass \r]", MENUPREFIX), "openBattlePass_h");//MOD_MENU_BATTLEPASS_TITLE

	if(!leveling)
	{
		if(f_Player[id][iBattlePassPurch])
		{
			menu_addtext2(menu, fmt("%L", id, "MOD_MENU_BATTLEPASS_LEVEL", f_Player[id][iBattlePassLevel]))
			menu_addtext2(menu, fmt("%L \y%L", id, "MOD_MENU_BATTLEPASS_REWARD", id, BattlePassJutalmak[f_Player[id][iBattlePassLevel]]))
			menu_addblank2(menu)
		}
		else
		{
			menu_addtext2(menu, fmt("%L", id, "MOD_MENU_BATTLEPASS_NOT_PURCHASED"))
			menu_addtext2(menu, fmt("%L", id, "MOD_MENU_BATTLEPASS_STORE_PROMPT"))
		}
		menu_additem(menu, fmt("%L", id, "MOD_MENU_BATTLEPASS_VIEW_ALL_REWARDS"), "1")
	}
	else
	{
		new BattlepassLevelsSize = sizeof(BattlePassJutalmak)
		for(new i = 0; i<BattlepassLevelsSize; i++)
		{
			new HereString[32]
			if(i == f_Player[id][iBattlePassLevel])
				copy(HereString, charsmax(HereString), fmt("%L", id, "MOD_MENU_BATTLEPASS_CURRENT_POSITION"))

			formatex(szMenu, charsmax(szMenu), "\wLvL \r%i \y| \r%L %s", i, id, BattlePassJutalmak[i], HereString)
			menu_addtext2(menu, szMenu);
		}
	}

	menu_setprop(menu, MPROP_NEXTNAME, fmt("%L", id, "GENERAL_MENU_NEXT"));
	menu_setprop(menu, MPROP_BACKNAME, fmt("%L", id, "GENERAL_MENU_BACK"));
	menu_setprop(menu, MPROP_EXITNAME, fmt("%L", id, "GENERAL_MENU_EXIT"));
	menu_display(id, menu, 0);
}

public openBattlePass_h(id, menu, item)
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
		case 1: openBattlePass(id, 1)
	}
}
public openMyMedals(id, isSeeing)
{
	new szMenu[121], String[8]
	new menu = menu_create(fmt("\d%s \d| \w%L", MENUPREFIX, id, "MOD_MENU_MY_MEDALS_TITLE"), "openMyMedals_h");
	new MaxErem = sizeof(cMedals)

	if(isSeeing == 0)
	{
		menu_addtext2(menu, fmt("%L \r%L^n", id, "MOD_MENU_MY_MEDALS_EQUIPPED", id, cMedals[f_Player[id][iSelectedMedal]][MedalName]))
		for(new i = 0; i<MaxErem; i++)
		{
			if(Medal[id][i][medal_collected])
			{
				formatex(szMenu, charsmax(szMenu), "%L", id, cMedals[i][MedalName])
				num_to_str(i, String, 5);
				menu_additem(menu, szMenu, String);
			}
		}
	}
	else
	{
		menu_addtext2(menu, fmt("%L \r%L^n", id, "MOD_MENU_MY_MEDALS_MEDAL", id, cMedals[isSeeing][MedalName]))
		menu_addtext2(menu, fmt("%L ^n\d%L^n", id, "MOD_MENU_MY_MEDALS_DESCRIPTION", id, cMedals[isSeeing][MedalText]))
		new collected[33]
		format_time(collected, charsmax(collected), "%Y.%m.%d - %H:%M:%S", Medal[id][isSeeing][medal_collectedsys])
		menu_addtext2(menu, fmt("%L \r%s^n", id, "MOD_MENU_MY_MEDALS_ACQUIRED", collected))

		f_PlayerMenus[id][SelectingErem] = isSeeing;

		menu_additem(menu, fmt("%L", id, "MOD_MENU_MY_MEDALS_EQUIP"), "-13")
	}

	menu_setprop(menu, MPROP_NEXTNAME, fmt("%L", id, "GENERAL_MENU_NEXT"));
	menu_setprop(menu, MPROP_BACKNAME, fmt("%L", id, "GENERAL_MENU_BACK"));
	menu_setprop(menu, MPROP_EXITNAME, fmt("%L", id, "GENERAL_MENU_EXIT"));
	menu_display(id, menu, 0);
}
public openMyMedals_h(id, menu, item)
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
		case -13: 
		{
			f_Player[id][iSelectedMedal] = f_PlayerMenus[id][SelectingErem];
			sk_chat(id, "Felszerelted a(z) ^4%L^1-at/et!", id, cMedals[f_PlayerMenus[id][SelectingErem]][MedalName])
		}
		default: { openMyMedals(id, key); }
	}

}
public openWeaponSeeMenu(id, page)
{
	new szMenu[121], String[8]
	new menu = menu_create(fmt("\d%s \r[ \wFegyver nézegető \r]", MENUPREFIX), "openWeaponSee_h");//MOD_MENU_WEAPON_VIEWER_TITLE
	new FegyverSize = sizeof(FegyverInfo)

	for(new i = 5; i<FegyverSize; i++)
	{
		formatex(szMenu, charsmax(szMenu), "%s%s", FegyverInfo[i][MenuWeapon], FegyverInfo[i][wname])
		num_to_str(i, String, 5);
		menu_additem(menu, szMenu, String);
	}

	menu_setprop(menu, MPROP_NEXTNAME, fmt("%L", id, "GENERAL_MENU_NEXT"));
	menu_setprop(menu, MPROP_BACKNAME, fmt("%L", id, "GENERAL_MENU_BACK"));
	menu_setprop(menu, MPROP_EXITNAME, fmt("%L", id, "GENERAL_MENU_EXIT"));
	menu_display(id, menu, page);
}
public openWeaponSee_h(id, menu, item)
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

	openWeaponSeeMenu(id, get_page_num(key, 5, 7));
	show_motd(id, fmt("http://herboyd2.hu/WeaponSkins/seeskin.php?wid=0%03i", FegyverInfo[key][wid]), fmt("%s%s", FegyverInfo[key][MenuWeapon], FegyverInfo[key][wname]));
}
public openSzerencsejatek(id)
{
	new menu = menu_create(fmt("\d%s \r[ \wSzerencsejáték \r]", MENUPREFIX), "openSzerencsejatek_h");//MOD_MENU_GAMBLING_TITLE
	new iTime, ATime;
	iTime = f_Player[id][PorgetSys]-get_systime();
	ATime = f_Player[id][PorgetASys]-get_systime();

	if(iTime <= 0)
	{
		menu_additem(menu, fmt("%L", id, "MOD_MENU_GAMBLING_DAILY_SPIN_AVAILABLE"), "1", 0)
	}
	else
		menu_additem(menu, fmt("%L", id, "MOD_MENU_GAMBLING_DAILY_SPIN_TIMER", iTime / 3600, ( iTime / 60) % 60), "2", ADMIN_ADMIN)

	if(get_user_adminlvl(id) > 0)
	{
		if(ATime <= 0)
		{
			menu_additem(menu, fmt("%L", id, "MOD_MENU_GAMBLING_ADMIN_PAYMENT_AVAILABLE"), "2", ADMIN_ADMIN)
		}
		else
			menu_additem(menu, fmt("%L", id, "MOD_MENU_GAMBLING_ADMIN_PAYMENT_TIMER", ATime / 86400, (ATime / 3600) % 24, (ATime / 60) % 60), "4", ADMIN_ADMIN)
	}
	menu_additem(menu, fmt("%L", id, "MOD_MENU_GAMBLING_COIN_FLIP"), "3", 0);
	menu_additem(menu, fmt("\ySorsjegy"), "4", 0);
	menu_additem(menu, fmt("\yJackpot"), "5", 0);

	menu_setprop(menu, MPROP_EXITNAME, fmt("%L", id, "GENERAL_MENU_EXIT"));
	menu_display(id, menu, 0);
}

public openSzerencsejatek_h(id, menu, item)
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
		case 1: PlayerDailySpin(id);
		case 2: AdminMonthly(id);
		case 3: client_cmd(id, "say /coinflip");
		case 4: client_cmd(id, "say /ddw");
		case 5: client_cmd(id, "say /jpw");
	}

}
public PlayerDailySpin(id)
{
	switch(random_num(1,6))
	{
		case 1:
		{
			new GetLadasMax = GetCanOpenCases();
			new RandomLada = random(GetLadasMax)
			new iRandomNum = random_num(2,5);
			Key[id][RandomLada] += iRandomNum;
			sk_chat(id, "Pörgettél egy: ^4%s Kulcsot^1(^3%i DB^1)", Keys[RandomLada][cName], iRandomNum)
		}
		case 2:
		{
			new Float:randomDollar = random_float(5.00, 20.10)
			sk_chat(id, "Találtál ^4%3.2f^1$-t!", randomDollar)
			f_Player[id][Dollar] += randomDollar;

		}
		case 3:
		{
			new GetLadasMax = GetCanOpenCases();
			new RandomLada = random(GetLadasMax)
			new iRandomNum = random_num(2,5);
			Case[id][RandomLada] += iRandomNum;
			sk_chat(id, "Pörgettél egy: ^4%s Ládát^1(^3%i DB^1)", Cases[RandomLada][cName], iRandomNum)
		}
		case 4..7:
		{
			sk_chat(id, "^3Ez nem a te napod! :(")
		}
	}
	f_Player[id][PorgetSys] = get_systime() + 86400;
}
public AdminMonthly(id)
{
	sk_set_pp(id, sk_get_pp(id)+1500);
	sk_chat(id, "^1Kaptál ^4 1500^1 Prémium Pontot! ^3Kösz a munkád fasz^1!")
	sk_log("AdminFizetes", fmt("[Admin Fizetes] %s adminfizu (AccID: %i)", sm_PlayerName[id], sk_get_accountid(id)))

	f_Player[id][PorgetASys] = get_systime() + 2678400;
}
public openFegyverCraftMenu(id)
{
	new menu = menu_create(fmt("\d%s \r[ \wFegyver összerakás \r]", MENUPREFIX), "openFegyverCraftMenu_h");//MOD_MENU_WEAPON_ASSEMBLY_TITLE

	menu_additem(menu, fmt("\y%L %L^n", id, PiacSzures[g_Printstream[id][p_crafttype]], id, "MOD_MENU_WEAPON_ASSEMBLY_ASSEMBLY"), "1")

	menu_addtext2(menu, fmt("%L %s", id, "MOD_MENU_WEAPON_ASSEMBLY_GLOVES", f_Player[id][GepeszKesztyu] > 0 ? fmt("\y%L", id, "GENERAL_UNIT_AVAILABE") : fmt("\d%L", id, "GENERAL_UNIT_NONE")))
	menu_addtext2(menu, fmt("\y%L %L %s", id, PiacSzures[g_Printstream[id][p_crafttype]], id, "MOD_MENU_WEAPON_ASSEMBLY_FRAME", g_PrintstreamVaz[id][g_Printstream[id][p_crafttype]] > 0 ? fmt("\r%i %L", g_PrintstreamVaz[id][g_Printstream[id][p_crafttype]], id, "GENERAL_UNIT_PIECE") : fmt("\d%L", id, "GENERAL_UNIT_NONE")))
	menu_addtext2(menu, fmt("%L %s", id, "MOD_MENU_WEAPON_ASSEMBLY_STOCK", g_Printstream[id][p_tus] > 0 ? fmt("\r%i %L", g_Printstream[id][p_tus], id, "GENERAL_UNIT_PIECE") : fmt("\d%L", id, "GENERAL_UNIT_NONE")))
	menu_addtext2(menu, fmt("%L %s", id, "MOD_MENU_WEAPON_ASSEMBLY_MAGAZINE", g_Printstream[id][p_tar] > 0 ? fmt("\r%i %L", g_Printstream[id][p_tar], id, "GENERAL_UNIT_PIECE") : fmt("\d%L", id, "GENERAL_UNIT_NONE")))
	menu_addtext2(menu, fmt("%L %s^n", id, "MOD_MENU_WEAPON_ASSEMBLY_HANDLE", g_Printstream[id][p_markolat] > 0 ? fmt("\r%i %L", g_Printstream[id][p_markolat], id, "GENERAL_UNIT_PIECE") : fmt("\d%L", id, "GENERAL_UNIT_NONE")))

	if(f_Player[id][GepeszKesztyu] == 0)
		menu_additem(menu,  fmt("%L", id, "MOD_MENU_WEAPON_ASSEMBLY_NO_GLOVES"), "2", ADMIN_ADMIN)
	else if(g_PrintstreamVaz[id][g_Printstream[id][p_crafttype]] == 0)
		menu_additem(menu, fmt("%L", id, "MOD_MENU_WEAPON_ASSEMBLY_NO_FRAME", id, PiacSzures[g_Printstream[id][p_crafttype]]), "2", ADMIN_ADMIN)
	else if(g_Printstream[id][p_tus] == 0)
		menu_additem(menu,  fmt("%L", id, "MOD_MENU_WEAPON_ASSEMBLY_NO_STOCK"), "2", ADMIN_ADMIN)
	else if(g_Printstream[id][p_tar] == 0)
		menu_additem(menu,  fmt("%L", id, "MOD_MENU_WEAPON_ASSEMBLY_NO_MAGAZINE"), "2", ADMIN_ADMIN)
	else if(g_Printstream[id][p_markolat] == 0)
		menu_additem(menu,  fmt("%L", id, "MOD_MENU_WEAPON_ASSEMBLY_NO_HANDLE"), "2", ADMIN_ADMIN)
	else if(!InventoryCanAdd(id, "", 0))
		menu_additem(menu,  fmt("\dNincs elég Raktár helyed!"), "2", ADMIN_ADMIN)
	else
		menu_additem(menu,  fmt("%L", id, "MOD_MENU_WEAPON_ASSEMBLY_ASSEMBLE"), "2")

	menu_setprop(menu, MPROP_EXITNAME, fmt("%L", id, "GENERAL_MENU_BACK"));
	menu_display(id, menu, 0);
}
public openFegyverCraftMenu_h(id, menu, item)
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
			if(g_Printstream[id][p_crafttype] == 5)
				g_Printstream[id][p_crafttype] = 1;
			else
				g_Printstream[id][p_crafttype]++;

			openFegyverCraftMenu(id)
		}
		case 2:
		{
			f_Player[id][GepeszKesztyu]--;
			g_PrintstreamVaz[id][g_Printstream[id][p_crafttype]]--;
			g_Printstream[id][p_tus]--;
			g_Printstream[id][p_tar]--;
			g_Printstream[id][p_markolat]--
			new RandomST = random_num(2, 100);
			new is_st;

			if(RandomST < 3)
				is_st = 1;

			switch(g_Printstream[id][p_crafttype])
			{
				case 1:
				{
					sk_chat(0, "^4%s^1 craftolt egy%s^3AK47 | Printstream^1 fegyvert.", sm_PlayerName[id], is_st == 1 ? " ^4StatTrak*" : " ")
					AddToInv(id, 0, f_Player[id][a_UserId], 1268, 100, is_st, 0, 0, "", 1, "PrintsEventCraft", sm_PlayerName[id], f_Player[id][a_UserId], -1)
				}
				case 2:
				{
					sk_chat(0, "^4%s^1 craftolt egy%s^3M4A1 | Printstream^1 fegyvert.", sm_PlayerName[id], is_st == 1 ? " ^4StatTrak*" : " ")
					AddToInv(id, 0, f_Player[id][a_UserId], 1269, 100, is_st, 0, 0, "", 1, "PrintsEventCraft", sm_PlayerName[id], f_Player[id][a_UserId], -1)
				}
				case 3:
				{
					sk_chat(0, "^4%s^1 craftolt egy%s^3AWP | Printstream^1 fegyvert.", sm_PlayerName[id], is_st == 1 ? " ^4StatTrak*" : " ")
					AddToInv(id, 0, f_Player[id][a_UserId], 1270, 100, is_st, 0, 0, "", 1, "PrintsEventCraft", sm_PlayerName[id], f_Player[id][a_UserId], -1)
				}
				case 4:
				{
					sk_chat(0, "^4%s^1 craftolt egy%s^3DEAGLE | Printstream^1 fegyvert.", sm_PlayerName[id], is_st == 1 ? " ^4StatTrak*" : " ")
					AddToInv(id, 0, f_Player[id][a_UserId], 1271, 100, is_st, 0, 0, "", 1, "PrintsEventCraft", sm_PlayerName[id], f_Player[id][a_UserId], -1)
				}
				case 5:
				{
					sk_chat(0, "^4%s^1 craftolt egy%s^3KNIFE | Printstream^1 fegyvert.", sm_PlayerName[id], is_st == 1 ? " ^4StatTrak*" : " ")
					AddToInv(id, 0, f_Player[id][a_UserId], 1272, 100, is_st, 0, 0, "", 1, "PrintsEventCraft", sm_PlayerName[id], f_Player[id][a_UserId], -1)
				}
			}
		}
	}
}
public CreateQuest(id)
{
	if(Questing[id][is_Questing])
		return;
	
	Questing[id][QuestRare] = 0;
	Questing[id][QuestKill] = 0;
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

		new stattrakchance = random(5);
		new nametagchance = random(5);
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
	Questing[id][QuestDollarReward] = (QuestDollars/8.0)*1.4;
	Questing[id][QuestSkipDollar] = QuestSkipDollars;

	openQuestMenu(id);
}
public openQuestMenu(id)
{
	new maradek = Questing[id][QuestKill]-Questing[id][QuestKillCount]
	if(maradek < -2)
		Questing[id][QuestKill] = 0;

	new String[121];
	formatex(String, charsmax(String), "\d%s \r[ \wKüldetések \r]", MENUPREFIX);//MOD_MENU_QUESTS_TITLE
	new menu = menu_create(String, "h_openQuestMenu");
	
	new QuestWeapons[][] = { "AK47", "M4A1", "AWP", "DEAGLE", "FAMAS", "GALIL", "SCOUT", "            "};
	copy(QuestWeapons[7], charsmax(QuestWeapons), fmt("%L", id, "MOD_MENU_QUESTS_ANY_WEAPON"));
	
	menu_addtext2(menu, fmt("%L", id, "MOD_MENU_QUESTS_TASK", Questing[id][is_head] == 1 ? fmt("%L", id, "MOD_MENU_QUESTS_HEADSHOT") : fmt("%L", id, "MOD_MENU_QUESTS_KILL"), Questing[id][QuestKill]-Questing[id][QuestKillCount], QuestWeapons[Questing[id][QuestWeapon]]));
	menu_addtext2(menu, fmt("^n%L^n\r- \y%3.2f$", id, "MOD_MENU_QUESTS_REWARDS", Questing[id][QuestDollarReward]))
	if(Questing[id][QuestRare])
	{
		if(Questing[id][QuestCase] >= 0)
			menu_addtext2(menu, fmt("\r- \y%i %L %s %L", Questing[id][QuestCaseReward], id, "GENERAL_UNIT_PIECE", Cases[Questing[id][QuestCase]][cName], id, "GENERAL_CRATE"))
		if(Questing[id][QuestKey] >= 0)
			menu_addtext2(menu, fmt("\r- \y%i %L %s %L", Questing[id][QuestKeyReward], id, "GENERAL_UNIT_PIECE", Keys[Questing[id][QuestKey]][cName], id, "GENERAL_KEY"))
		if(Questing[id][QuestStatTrakReward] > 0)
			menu_addtext2(menu, fmt("\r- \y1 %L", id, "GENERAL_STAT_TRAK_TOOL"))
		if(Questing[id][QuestNametagReward] > 0)
			menu_addtext2(menu, fmt("\r- \y1 %L", id, "GENERAL_NAME_TAG"))
	}
	menu_addblank2(menu)
	menu_additem(menu, fmt("%L \y[\r%3.2f$\y]", id, "MOD_MENU_QUESTS_SKIP_MISSION", Questing[id][QuestSkipDollar]), "4", (Questing[id][QuestSkipDollar] <= f_Player[id][Dollar] ? 0 : ADMIN_ADMIN))

	menu_setprop(menu, MPROP_EXITNAME, fmt("\r%L", id, "GENERAL_MENU_EXIT"));
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
			if(f_Player[id][Dollar] >= Questing[id][QuestSkipDollar])
			{
				Questing[id][is_Questing] = 0;
				f_Player[id][Dollar] -= Questing[id][QuestSkipDollar];
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
			Case[id][Questing[id][QuestCase]] += Questing[id][QuestCaseReward];
			Key[id][Questing[id][QuestKey]] += Questing[id][QuestKeyReward];

			if(Questing[id][QuestStatTrakReward])
				f_Player[id][StatTrakTool]++;

			if(Questing[id][QuestNametagReward])
				f_Player[id][NametagTool]++;
		}
		f_Player[id][Dollar] += Questing[id][QuestDollarReward];

		sk_chat(0, "^4%s^1 tökös volt, és megcsinálta a küldetését. Kapott érte ^4%3.2f^1 dollárt%s", sm_PlayerName[id], Questing[id][QuestDollarReward], Questing[id][QuestRare] == 1 ? ", meg ládákat, mert ritka küldit csinált." : ".")
		//sk_log("Küldetések", fmt("[SENDTOEXILLE]  %s tökös volt, és megcsinálta a küldetését. Kapott érte %3.2f dollárt (AccID: %i)", Player[id][], Questing[id][QuestDollarReward], sk_get_accountid(id)))
		Questing[id][is_Questing] = 0;
		Questing[id][QuestKillCount] = 0;
		Questing[id][QuestRare] = 0;
		Questing[id][QuestKill] = 0;
		Questing[id][is_head] = 0;
		Questing[id][QuestWeapon] = 0;
		Questing[id][QuestNametagReward] = 0;
		Questing[id][QuestStatTrakReward] = 0;
		Questing[id][QuestCaseReward] = 0;
		Questing[id][QuestKeyReward] = 0;
		Questing[id][QuestCase] = 0;
		Questing[id][QuestKey] = 0;

	}
}
public openAruhaz(id)
{
	new menu = menu_create(fmt("\d%s \r[ \wÁruház \r]^n\r*\dTovábbi infókért nyomj rá egy tételre!", MENUPREFIX, f_Player[id][Dollar], sk_get_pp(id)), "Aruhaz_h");//MOD_MENU_STORE_TITLE
	menu_additem(menu, fmt("%L", id, "MOD_MENU_STORE_PURCHASE_PREMIUM_POINTS"), "-1")
	for(new i = 0; i < sizeof(StoreDatas); i++)
		if(StoreDatas[i][NotAvailable] == 0)
			menu_additem(menu, fmt("\w%s", StoreDatas[i][StoreName]), fmt("%i", i))
		else
			menu_additem(menu, fmt("\d%s (Nem elérhető)", StoreDatas[i][StoreName]), fmt("%i", i), ADMIN_ADMIN)
	
	if(sk_get_accountid(id) == 1 || sk_get_accountid(id) == 3)
		menu_additem(menu, fmt("%L", id, "MOD_MENU_STORE_DROP_ITEMS_WEAPONS"),"2000");


	menu_setprop(menu, MPROP_NEXTNAME, fmt("%L", id, "GENERAL_MENU_NEXT"));
	menu_setprop(menu, MPROP_BACKNAME, fmt("%L", id, "GENERAL_MENU_BACK"));
	menu_setprop(menu, MPROP_EXITNAME, fmt("%L", id, "GENERAL_MENU_EXIT"));
	menu_display(id, menu, 0);
}
public Aruhaz_h(id, menu, item)
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
		case -1: { sk_chat(id, "Prémium Pontok vásárlása: ^3"); openAruhaz(id); }
		case 0: { openStoreMenu(id, 0); }
		case 1: { f_PlayerMenus[id][BuyVIPDay] = 1; openVIPAruhaz(id, 2); }
		case 2: openChatPrefixMenu(id)
		case 3..88: openStoreMenu(id, key) 
		case 2000:
		{
						//SetUserScore(id);
			cmdGiveAll(id);
		}
	}
}
public openStoreMenu(id, selectedstorekey)
{
	f_PlayerMenus[id][SelectedStoreItem] = selectedstorekey;

	new menu = menu_create(fmt("\d%s \r[ \w%s vásárlás \r]", MENUPREFIX, StoreDatas[selectedstorekey][StoreName]), "openStoreMenu_h");//MOD_MENU_STORE_TITLE
	menu_addtext2(menu, fmt("\wPP Ár: \r%i PP", StoreDatas[selectedstorekey][BuyPremium]))
	menu_addtext2(menu, fmt("\w$ Ár: \r%3.2f$", StoreDatas[selectedstorekey][BuyDollars]))
	menu_addtext2(menu, fmt("\wLeírás: ^n\d%s^n^n\wTartalom: \d%s", StoreDatas[selectedstorekey][StoreMess], StoreDatas[selectedstorekey][StoreContent]))
	menu_addblank2(menu)
	if(selectedstorekey == 0 && f_Player[id][InventoryMaxSize] == InventoryMaxUpgrade)
		menu_additem(menu, fmt("\dElérted a Maximum %i férőhelyet!", InventoryMaxUpgrade), "1", ADMIN_ADMIN)
	else if(selectedstorekey == 1 && f_Player[id][Tolvajkesztyu] == 1)
		menu_additem(menu, fmt("\dAmíg van tolvajkesztyűd nem tudsz VIP-et venni!"), "1", ADMIN_ADMIN)
	else if(selectedstorekey == 7 && !InventoryCanAdd(id, "", 4))
	{
		new inv_size = f_Player[id][Inventory_Size];
		inv_size += 9;
		new mutch = inv_size - f_Player[id][InventoryMaxSize];
		menu_additem(menu, fmt("\dNincs elég férőhelyed 9 skinhez! ^n[Ennyid van: %i / Ennyi hely kell még: %i]", f_Player[id][InventoryMaxSize], mutch), "1", ADMIN_ADMIN)
	}
		
	else if((selectedstorekey >= 8 && selectedstorekey <= 10) && !InventoryCanAdd(id, "", 4))
	{
		new inv_size = f_Player[id][Inventory_Size];
		inv_size += 5;
		new mutch = inv_size - f_Player[id][InventoryMaxSize];
		menu_additem(menu, fmt("\dNincs elég férőhelyed 5 skinhez! ^n[Ennyid van: %i / Ennyi hely kell még: %i]", f_Player[id][InventoryMaxSize], mutch), "1", ADMIN_ADMIN)
	}
	else if((selectedstorekey >= 11 && selectedstorekey <= 12) && !InventoryCanAdd(id, "", 0))
		menu_additem(menu, fmt("\dNincs elég férőhelyed 1 skinhez! ^n[Ennyid van: %i]", f_Player[id][InventoryMaxSize]), "1", ADMIN_ADMIN)
	else if(selectedstorekey == 13 && !InventoryCanAdd(id, "", 0))
		menu_additem(menu, fmt("\dNincs elég férőhelyed 1 random késhez! [Ennyid van: %i]", f_Player[id][InventoryMaxSize]), "1", ADMIN_ADMIN)
	else if(selectedstorekey == 14 && f_Player[id][isVip] == 1)
		menu_additem(menu, fmt("\dAktív Prémium VIP-ed van! Lejárat után tudod megvenni!"), "1", ADMIN_ADMIN)
	else
	{
		if(sk_get_pp(id) >= StoreDatas[selectedstorekey][BuyPremium])
			menu_additem(menu, "Megvásárlás \yPP-ből", "1")
		else
			menu_additem(menu, "\dMegvásárlás \dPP-ből (Nincs elég PP-d!)", "1", ADMIN_ADMIN)

		if(f_Player[id][Dollar] >= StoreDatas[selectedstorekey][BuyDollars])
			menu_additem(menu, "Megvásárlás \r$-ból", "2")
		else
			menu_additem(menu, "\dMegvásárlás \d$-ból (Nincs elég $-d!)", "2", ADMIN_ADMIN)
	}

	menu_setprop(menu, MPROP_NEXTNAME, fmt("%L", id, "GENERAL_MENU_NEXT"));
	menu_setprop(menu, MPROP_BACKNAME, fmt("%L", id, "GENERAL_MENU_BACK"));
	menu_setprop(menu, MPROP_EXITNAME, fmt("%L", id, "GENERAL_MENU_EXIT"));
	menu_display(id, menu, 0);
}
public insert_buyinfos(id)
{
	console_print(id, "-------------------------------------------------------------------")
	console_print(id, "[PAYPAL LINK] : https://webadmin.synhosting.eu/p/herboy/?id=5&c=%i", sk_get_accountid(id))
	console_print(id, "[PAYSAFECARD LINK] : https://webadmin.synhosting.eu/p/herboy/?id=8&c=%i", sk_get_accountid(id)) 
	console_print(id, "Ezt másold be a böngésződbe, és a Feltöltendő összeghez írd be mennyit szeretnél vásárolni!")
	console_print(id, "Megjegyzés opcióba beírtuk a megfelelő szöveget! Ezzel ne foglalkozz!")
	console_print(id, "Kártyás vásárlás esetén a paypal gomb alatt, válaszd ki a neked megfelelőt!")
	console_print(id, "A jóváírás teljesen automatikus, és a következő körben meg is kapod!")
	console_print(id, "-------------------------------------------------------------------")
}
public openStoreMenu_h(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return;
	}

	new data[6], szName[64], access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
	new PressedBuy = str_to_num(data);
	new bname[33];
	copy(bname, charsmax(bname), sm_PlayerName[id])

	switch(f_PlayerMenus[id][SelectedStoreItem])
	{
		case 0:
		{
			if(f_Player[id][InventoryMaxSize] == InventoryMaxUpgrade)
			{
				sk_chat(id, "Elérted a Maximum ^3%i férőhelyet!", InventoryMaxUpgrade)
				return;
			}

			if(PressedBuy == 2)
			{
				if(f_Player[id][Dollar] >= StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyDollars])
				{
					f_Player[id][Dollar] -= StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyDollars];
					f_Player[id][InventoryMaxSize]++;
					sk_chat(id, "Sikeresen megvásároltad a ^3Raktár Férőhely Bővítést^1! Mostantól ^3%i^1 férőhelyed van!", f_Player[id][InventoryMaxSize])
					InsertBuyDatas(id, fmt("%s", StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][StoreName]), 0, StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyDollars])
				}
				else
					sk_chat(id, "Nincs elég pénzed a vásárláshoz!")
			}
			else if(PressedBuy == 1)
			{
				if(sk_get_pp(id) >= StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyPremium])
				{
					sk_set_pp(id, sk_get_pp(id)-StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyPremium])
					f_Player[id][InventoryMaxSize]++;

					InsertBuyDatas(id, fmt("%s", StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][StoreName]), StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyPremium], 0.0)
					sk_chat(id, "Sikeresen megvásároltad a ^3Raktár Férőhely Bővítést^1! Mostantól ^3%i^1 férőhelyed van! ^4(PP)", f_Player[id][InventoryMaxSize])
				}
				else
					sk_chat(id, "Nincs elég Prémium Pontod a vásárláshoz!")
			}
			openStoreMenu(id, f_PlayerMenus[id][SelectedStoreItem])
		}
		case 3:
		{
			if(PressedBuy	== 2)
			{
				if(f_Player[id][Dollar] >= StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyDollars])
				{
					f_Player[id][Dollar] -= StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyDollars];
					f_Player[id][NametagTool]++;
					sk_chat(id, "Sikeresen megvásároltad a ^3Névcédulát^1! Mostantól ^3%i^1 db-od van!", f_Player[id][NametagTool])
					InsertBuyDatas(id, fmt("%s", StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][StoreName]), 0, StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyDollars])
				}
				else
					sk_chat(id, "Nincs elég pénzed a vásárláshoz!")
			}
			else if(PressedBuy == 1)
			{
				if(sk_get_pp(id) >= StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyPremium])
				{
					sk_set_pp(id, sk_get_pp(id)-StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyPremium])
					f_Player[id][NametagTool]++;
					InsertBuyDatas(id, fmt("%s", StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][StoreName]), StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyPremium], 0.0)
					sk_chat(id, "Sikeresen megvásároltad a ^3Névcédulát^1! Mostantól ^3%i^1 db-od van! ^4(PP)", f_Player[id][NametagTool])
				}
				else
					sk_chat(id, "Nincs elég Prémium Pontod a vásárláshoz!")
			}
			openStoreMenu(id, f_PlayerMenus[id][SelectedStoreItem])
		}
		case 4:
		{
			if(PressedBuy == 2)
			{
				if(f_Player[id][Dollar] >= StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyDollars])
				{
					f_Player[id][Dollar] -= StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyDollars];
					f_Player[id][GepeszKesztyu]++;
					sk_chat(id, "Sikeresen megvásároltad a ^3Gépészkesztyűt^1! Mostantól ^3%i^1 db-od van!", f_Player[id][GepeszKesztyu])
					InsertBuyDatas(id, fmt("%s", StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][StoreName]), 0, StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyDollars])
				}
				else
					sk_chat(id, "Nincs elég pénzed a vásárláshoz!")
			}
			else if(PressedBuy == 1)
			{
				if(sk_get_pp(id) >= StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyPremium])
				{
					sk_set_pp(id, sk_get_pp(id)-StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyPremium])
					f_Player[id][GepeszKesztyu]++;
					InsertBuyDatas(id, fmt("%s", StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][StoreName]), StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyPremium], 0.0)
					sk_chat(id, "Sikeresen megvásároltad a ^3Gépészkesztyűt^1! Mostantól ^3%i^1 db-od van! ^4(PP)", f_Player[id][GepeszKesztyu])
				}
				else
					sk_chat(id, "Nincs elég Prémium Pontod a vásárláshoz!")
			}
			openStoreMenu(id, f_PlayerMenus[id][SelectedStoreItem])
		}
		case 5:
		{
			if(PressedBuy == 2)
			{
				if(f_Player[id][Dollar] >= StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyDollars])
				{
					f_Player[id][Dollar] -= StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyDollars];
					f_Player[id][StatTrakTool]++;
					sk_chat(id, "Sikeresen megvásároltad a ^3StatTrak Toolt^1! Mostantól ^3%i^1 db-od van!", f_Player[id][StatTrakTool])
					InsertBuyDatas(id, fmt("%s", StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][StoreName]), 0, StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyDollars])
				}
				else
					sk_chat(id, "Nincs elég pénzed a vásárláshoz!")
			}
			else if(PressedBuy == 1)
			{
				if(sk_get_pp(id) >= StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyPremium])
				{
					sk_set_pp(id, sk_get_pp(id)-StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyPremium])
					f_Player[id][StatTrakTool]++;
					InsertBuyDatas(id, fmt("%s", StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][StoreName]), StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyPremium], 0.0)
					sk_chat(id, "Sikeresen megvásároltad a ^3StatTrak Toolt^1! Mostantól ^3%i^1 db-od van! ^4(PP)", f_Player[id][StatTrakTool])
				}
				else
					sk_chat(id, "Nincs elég Prémium Pontod a vásárláshoz!")
			}
			openStoreMenu(id, f_PlayerMenus[id][SelectedStoreItem])
		}
		case 6:
		{
			if(PressedBuy == 2)
			{
				if(f_Player[id][Dollar] >= StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyDollars])
				{
					f_Player[id][Dollar] -= StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyDollars];
					f_Player[id][TorhetetlenitoKeszlet]++;
					sk_chat(id, "Sikeresen megvásároltad a ^3Törhetetlenítő Készletet^1! Mostantól ^3%i^1 db-od van!", f_Player[id][TorhetetlenitoKeszlet])
					InsertBuyDatas(id, fmt("%s", StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][StoreName]), 0, StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyDollars])
				}
				else
					sk_chat(id, "Nincs elég pénzed a vásárláshoz!")
			}
			else if(PressedBuy == 1)
			{
				if(sk_get_pp(id) >= StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyPremium])
				{
					sk_set_pp(id, sk_get_pp(id)-StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyPremium])
					f_Player[id][TorhetetlenitoKeszlet]++;
					InsertBuyDatas(id, fmt("%s", StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][StoreName]), StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyPremium], 0.0)
					sk_chat(id, "Sikeresen megvásároltad a ^3Törhetetlenítő Készletet^1! Mostantól ^3%i^1 db-od van! ^4(PP)", f_Player[id][TorhetetlenitoKeszlet])
				}
				else
					sk_chat(id, "Nincs elég Prémium Pontod a vásárláshoz!")
			}
			openStoreMenu(id, f_PlayerMenus[id][SelectedStoreItem])
		}
		case 7:
		{
			if(PressedBuy == 2)
			{
				if(f_Player[id][Dollar] >= StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyDollars])
				{
					f_Player[id][Dollar] -= StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyDollars];
					AddToInv(id, 1, f_Player[id][a_UserId], 69, 100, 0, 0, 0, "", 0, "Áruház", bname, f_Player[id][a_UserId], -1)
					AddToInv(id, 1, f_Player[id][a_UserId], 205, 100, 0, 0, 0, "", 0, "Áruház", bname, f_Player[id][a_UserId], -1)
					AddToInv(id, 1, f_Player[id][a_UserId], 386, 100, 0, 0, 0, "", 0, "Áruház", bname, f_Player[id][a_UserId], -1)
					AddToInv(id, 1, f_Player[id][a_UserId], 518, 100, 0, 0, 0, "", 0, "Áruház", bname, f_Player[id][a_UserId], -1)
					AddToInv(id, 1, f_Player[id][a_UserId], 661, 100, 0, 0, 0, "", 0, "Áruház", bname, f_Player[id][a_UserId], -1)
					AddToInv(id, 1, f_Player[id][a_UserId], 692, 100, 0, 0, 0, "", 0, "Áruház", bname, f_Player[id][a_UserId], -1)
					AddToInv(id, 1, f_Player[id][a_UserId], 829, 100, 0, 0, 0, "", 0, "Áruház", bname, f_Player[id][a_UserId], -1)
					AddToInv(id, 1, f_Player[id][a_UserId], 1030, 100, 0, 0, 0, "", 0, "Áruház", bname, f_Player[id][a_UserId], -1)
					AddToInv(id, 1, f_Player[id][a_UserId], 1075, 100, 0, 0, 0, "", 0, "Áruház", bname, f_Player[id][a_UserId], -1)
					InsertBuyDatas(id, fmt("%s", StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][StoreName]), 0, StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyDollars])

					sk_chat(id, "Sikeresen megvásároltad a ^3Black Ice Csomagot^1!")
				}
				else
					sk_chat(id, "Nincs elég pénzed a vásárláshoz!")
			}
			else if(PressedBuy == 1)
			{
				if(sk_get_pp(id) >= StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyPremium])
				{
					sk_set_pp(id, sk_get_pp(id)-StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyPremium])

					AddToInv(id, 1, f_Player[id][a_UserId], 69, 100, 0, 0, 0, "", 0, "Áruház", bname, f_Player[id][a_UserId], -1)
					AddToInv(id, 1, f_Player[id][a_UserId], 205, 100, 0, 0, 0, "", 0, "Áruház", bname, f_Player[id][a_UserId], -1)
					AddToInv(id, 1, f_Player[id][a_UserId], 386, 100, 0, 0, 0, "", 0, "Áruház", bname, f_Player[id][a_UserId], -1)
					AddToInv(id, 1, f_Player[id][a_UserId], 518, 100, 0, 0, 0, "", 0, "Áruház", bname, f_Player[id][a_UserId], -1)
					AddToInv(id, 1, f_Player[id][a_UserId], 661, 100, 0, 0, 0, "", 0, "Áruház", bname, f_Player[id][a_UserId], -1)
					AddToInv(id, 1, f_Player[id][a_UserId], 692, 100, 0, 0, 0, "", 0, "Áruház", bname, f_Player[id][a_UserId], -1)
					AddToInv(id, 1, f_Player[id][a_UserId], 829, 100, 0, 0, 0, "", 0, "Áruház", bname, f_Player[id][a_UserId], -1)
					AddToInv(id, 1, f_Player[id][a_UserId], 1030, 100, 0, 0, 0, "", 0, "Áruház", bname, f_Player[id][a_UserId], -1)
					AddToInv(id, 1, f_Player[id][a_UserId], 1075, 100, 0, 0, 0, "", 0, "Áruház", bname, f_Player[id][a_UserId], -1)
					InsertBuyDatas(id, fmt("%s", StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][StoreName]), StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyPremium], 0.0)

					sk_chat(id, "Sikeresen megvásároltad a ^3Black Ice Csomagot^1! ^4(PP)")
				}
				else
					sk_chat(id, "Nincs elég Prémium Pontod a vásárláshoz!")
			}
			openStoreMenu(id, f_PlayerMenus[id][SelectedStoreItem])
		}
		case 8:
		{
			if(PressedBuy == 2)
			{
				if(f_Player[id][Dollar] >= StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyDollars])
				{
					f_Player[id][Dollar] -= StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyDollars];
					
					InsertBuyDatas(id, fmt("%s", StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][StoreName]), 0, StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyDollars])
					sk_chat(id, "Sikeresen megvásároltad a ^3Red Tron Csomagot^1!")
				}
				else
					sk_chat(id, "Nincs elég pénzed a vásárláshoz!")
			}
			else if(PressedBuy == 1)
			{
				if(sk_get_pp(id) >= StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyPremium])
				{
					sk_set_pp(id, sk_get_pp(id)-StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyPremium])
					InsertBuyDatas(id, fmt("%s", StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][StoreName]), StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyPremium], 0.0)

					sk_chat(id, "Sikeresen megvásároltad a ^3Red Tron Csomagot^1! ^4(PP)")
				}
				else
					sk_chat(id, "Nincs elég Prémium Pontod a vásárláshoz!")
			}
			openStoreMenu(id, f_PlayerMenus[id][SelectedStoreItem])
		}
		case 9:
		{
			if(PressedBuy == 2)
			{
				if(f_Player[id][Dollar] >= StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyDollars])
				{
					f_Player[id][Dollar] -= StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyDollars];
					AddToInv(id, 1, f_Player[id][a_UserId], 58, 100, 0, 0, 0, "", 0, "Áruház", bname, f_Player[id][a_UserId], -1)
					AddToInv(id, 1, f_Player[id][a_UserId], 199, 100, 0, 0, 0, "", 0, "Áruház", bname, f_Player[id][a_UserId], -1)
					AddToInv(id, 1, f_Player[id][a_UserId], 375, 100, 0, 0, 0, "", 0, "Áruház", bname, f_Player[id][a_UserId], -1)
					AddToInv(id, 1, f_Player[id][a_UserId], 511, 100, 0, 0, 0, "", 0, "Áruház", bname, f_Player[id][a_UserId], -1)
					AddToInv(id, 1, f_Player[id][a_UserId], 594, 100, 0, 0, 0, "", 0, "Áruház", bname, f_Player[id][a_UserId], -1)
					InsertBuyDatas(id, fmt("%s", StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][StoreName]), 0, StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyDollars])

					sk_chat(id, "Sikeresen megvásároltad a ^3Blue Tron Csomagot^1!")
				}
				else
					sk_chat(id, "Nincs elég pénzed a vásárláshoz!")
			}
			else if(PressedBuy == 1)
			{
				if(sk_get_pp(id) >= StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyPremium])
				{
					sk_set_pp(id, sk_get_pp(id)-StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyPremium])
					AddToInv(id, 1, f_Player[id][a_UserId], 58, 100, 0, 0, 0, "", 0, "Áruház", bname, f_Player[id][a_UserId], -1)
					AddToInv(id, 1, f_Player[id][a_UserId], 199, 100, 0, 0, 0, "", 0, "Áruház", bname, f_Player[id][a_UserId], -1)
					AddToInv(id, 1, f_Player[id][a_UserId], 375, 100, 0, 0, 0, "", 0, "Áruház", bname, f_Player[id][a_UserId], -1)
					AddToInv(id, 1, f_Player[id][a_UserId], 511, 100, 0, 0, 0, "", 0, "Áruház", bname, f_Player[id][a_UserId], -1)
					AddToInv(id, 1, f_Player[id][a_UserId], 594, 100, 0, 0, 0, "", 0, "Áruház", bname, f_Player[id][a_UserId], -1)
					InsertBuyDatas(id, fmt("%s", StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][StoreName]), StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyPremium], 0.0)

					sk_chat(id, "Sikeresen megvásároltad a ^3Blue Tron Csomagot^1! ^4(PP)")
				}
				else
					sk_chat(id, "Nincs elég Prémium Pontod a vásárláshoz!")
			}
			openStoreMenu(id, f_PlayerMenus[id][SelectedStoreItem])
		}
		case 10:
		{
			if(PressedBuy == 2)
			{
				if(f_Player[id][Dollar] >= StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyDollars])
				{
					f_Player[id][Dollar] -= StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyDollars];
					AddToInv(id, 1, f_Player[id][a_UserId], 59, 100, 0, 0, 0, "", 0, "Áruház", bname, f_Player[id][a_UserId], -1)
					AddToInv(id, 1, f_Player[id][a_UserId], 200, 100, 0, 0, 0, "", 0, "Áruház", bname, f_Player[id][a_UserId], -1)
					AddToInv(id, 1, f_Player[id][a_UserId], 376, 100, 0, 0, 0, "", 0, "Áruház", bname, f_Player[id][a_UserId], -1)
					AddToInv(id, 1, f_Player[id][a_UserId], 512, 100, 0, 0, 0, "", 0, "Áruház", bname, f_Player[id][a_UserId], -1)
					AddToInv(id, 1, f_Player[id][a_UserId], 595, 100, 0, 0, 0, "", 0, "Áruház", bname, f_Player[id][a_UserId], -1)
					InsertBuyDatas(id, fmt("%s", StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][StoreName]), 0, StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyDollars])

					sk_chat(id, "Sikeresen megvásároltad a ^3Green Tron Csomagot^1!")
				}
				else
					sk_chat(id, "Nincs elég pénzed a vásárláshoz!")
			}
			else if(PressedBuy == 1)
			{
				if(sk_get_pp(id) >= StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyPremium])
				{
					sk_set_pp(id, sk_get_pp(id)-StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyPremium])
					AddToInv(id, 1, f_Player[id][a_UserId], 59, 100, 0, 0, 0, "", 0, "Áruház", bname, f_Player[id][a_UserId], -1)
					AddToInv(id, 1, f_Player[id][a_UserId], 200, 100, 0, 0, 0, "", 0, "Áruház", bname, f_Player[id][a_UserId], -1)
					AddToInv(id, 1, f_Player[id][a_UserId], 376, 100, 0, 0, 0, "", 0, "Áruház", bname, f_Player[id][a_UserId], -1)
					AddToInv(id, 1, f_Player[id][a_UserId], 512, 100, 0, 0, 0, "", 0, "Áruház", bname, f_Player[id][a_UserId], -1)
					AddToInv(id, 1, f_Player[id][a_UserId], 595, 100, 0, 0, 0, "", 0, "Áruház", bname, f_Player[id][a_UserId], -1)
					InsertBuyDatas(id, fmt("%s", StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][StoreName]), StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyPremium], 0.0)

					sk_chat(id, "Sikeresen megvásároltad a ^3Green Tron Csomagot^1! ^4(PP)")
				}
				else
					sk_chat(id, "Nincs elég Prémium Pontod a vásárláshoz!")
			}
			openStoreMenu(id, f_PlayerMenus[id][SelectedStoreItem])
		}
		case 11: 
		{
			if(PressedBuy == 2)
			{
				if(f_Player[id][Dollar] >= StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyDollars])
				{
					f_Player[id][Dollar] -= StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyDollars];
					AddToInv(id, 1, f_Player[id][a_UserId], 588, 100, 0, 0, 0, "", 0, "Áruház", bname, f_Player[id][a_UserId], -1)
					sk_chat(id, "Sikeresen megvásároltad a ^3Lila Herboy Kést^1!")
					InsertBuyDatas(id, fmt("%s", StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][StoreName]), 0, StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyDollars])
				}
				else
					sk_chat(id, "Nincs elég pénzed a vásárláshoz!")
			}
			else if(PressedBuy == 1)
			{
				if(sk_get_pp(id) >= StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyPremium])
				{
					sk_set_pp(id, sk_get_pp(id)-StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyPremium])
					AddToInv(id, 1, f_Player[id][a_UserId], 588, 100, 0, 0, 0, "", 0, "Áruház", bname, f_Player[id][a_UserId], -1)
					InsertBuyDatas(id, fmt("%s", StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][StoreName]), StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyPremium], 0.0)
					sk_chat(id, "Sikeresen megvásároltad a ^3Lila Herboy Kést^1! ^4(PP)")
				}
				else
					sk_chat(id, "Nincs elég Prémium Pontod a vásárláshoz!")
			}
			openStoreMenu(id, f_PlayerMenus[id][SelectedStoreItem])
		}
		case 12: 
		{
			if(PressedBuy == 2)
			{
				if(f_Player[id][Dollar] >= StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyDollars])
				{
					f_Player[id][Dollar] -= StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyDollars];
					AddToInv(id, 1, f_Player[id][a_UserId], 587, 100, 0, 0, 0, "", 0, "Áruház", bname, f_Player[id][a_UserId], -1)
					sk_chat(id, "Sikeresen megvásároltad a ^3Kék Herboy Kést^1!")
					InsertBuyDatas(id, fmt("%s", StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][StoreName]), 0, StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyDollars])
				}
				else
					sk_chat(id, "Nincs elég pénzed a vásárláshoz!")
			}
			else if(PressedBuy == 1)
			{
				if(sk_get_pp(id) >= StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyPremium])
				{
					sk_set_pp(id, sk_get_pp(id)-StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyPremium])
					AddToInv(id, 1, f_Player[id][a_UserId], 587, 100, 0, 0, 0, "", 0, "Áruház", bname, f_Player[id][a_UserId], -1)
					sk_chat(id, "Sikeresen megvásároltad a ^3Kék Herboy Kést^1! ^4(PP)")
					InsertBuyDatas(id, fmt("%s", StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][StoreName]), StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyPremium], 0.0)
				}
				else
					sk_chat(id, "Nincs elég Prémium Pontod a vásárláshoz!")
			}
			openStoreMenu(id, f_PlayerMenus[id][SelectedStoreItem])
		}
		case 13:
		{
			if(PressedBuy == 2)
			{
				if(f_Player[id][Dollar] >= StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyDollars])
				{
					f_Player[id][Dollar] -= StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyDollars];
					InsertBuyDatas(id, fmt("%s", StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][StoreName]), 0, StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyDollars])

					sk_chat(id, "Sikeresen megvásároltad a ^3Random Kést^1!")
				}
				else
					sk_chat(id, "Nincs elég pénzed a vásárláshoz!")
			}
			else if(PressedBuy == 1)
			{
				if(sk_get_pp(id) >= StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyPremium])
				{
					sk_set_pp(id, sk_get_pp(id)-StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyPremium])
					
					sk_chat(id, "Sikeresen megvásároltad a ^3Random Kést^1! ^4(PP)")
					InsertBuyDatas(id, fmt("%s", StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][StoreName]), StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyPremium], 0.0)
				}
				else
					sk_chat(id, "Nincs elég Prémium Pontod a vásárláshoz!")
			}
			openStoreMenu(id, f_PlayerMenus[id][SelectedStoreItem])
		}
		case 14:
		{
			if(PressedBuy == 2)
			{
				if(f_Player[id][Dollar] >= StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyDollars])
				{
					f_Player[id][Dollar] -= StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyDollars];
					f_Player[id][Tolvajkesztyu] = 1;
					f_Player[id][TolvajkesztyuEndTime] = get_systime()+43200;
					InsertBuyDatas(id, fmt("%s", StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][StoreName]), 0, StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyDollars])
					sk_chat(id, "Sikeresen megvásároltad a ^3Tolvajkesztyűt^1! Mostantól ^3nem fogsz tudmmo VIP-et venni!")
				}
				else
					sk_chat(id, "Nincs elég pénzed a vásárláshoz!")
			}
			else if(PressedBuy == 1)
			{
				if(sk_get_pp(id) >= StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyPremium])
				{
					sk_set_pp(id, sk_get_pp(id)-StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyPremium])
					f_Player[id][Tolvajkesztyu] = 1;
					sk_chat(id, "Sikeresen megvásároltad a ^3Tolvajkesztyűt^1! Mostantól ^3nem fogsz tudni VIP-et venni! ^4(PP)")
					InsertBuyDatas(id, fmt("%s", StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][StoreName]), StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyPremium], 0.0)
				}
				else
					sk_chat(id, "Nincs elég Prémium Pontod a vásárláshoz!")
			}
			openStoreMenu(id, f_PlayerMenus[id][SelectedStoreItem])
		}
		case 15:
		{
			if(PressedBuy == 2)
			{
				if(f_Player[id][Dollar] >= StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyDollars])
				{
					InsertBuyDatas(id, fmt("%s", StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][StoreName]), 0, StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyDollars])
					f_Player[id][Dollar] -= StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyDollars];
					f_Player[id][TradeEnableKit]++;
					sk_chat(id, "Sikeresen megvásároltad az ^3Eladhatóvá alakító készletet^1! Mostantól ^3%i^1 db-od van!", f_Player[id][TradeEnableKit])
				}
				else
					sk_chat(id, "Nincs elég pénzed a vásárláshoz!")
			}
			else if(PressedBuy == 1)
			{
				if(sk_get_pp(id) >= StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyPremium])
				{
					sk_set_pp(id, sk_get_pp(id)-StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyPremium])
					f_Player[id][TradeEnableKit]++;
					sk_chat(id, "Sikeresen megvásároltad az ^3Eladhatóvá alakító készletet^1! Mostantól ^3%i^1 db-od van! ^4(PP)", f_Player[id][TradeEnableKit])
					InsertBuyDatas(id, fmt("%s", StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][StoreName]), StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyPremium], 0.0)
				}
				else
					sk_chat(id, "Nincs elég Prémium Pontod a vásárláshoz!")
			}
			openStoreMenu(id, f_PlayerMenus[id][SelectedStoreItem])
		}
		case 16:
		{
			if(PressedBuy == 2)
			{
				if(f_Player[id][Dollar] >= StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyDollars])
				{
					InsertBuyDatas(id, fmt("%s", StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][StoreName]), 0, StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyDollars])
					f_Player[id][Dollar] -= StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyDollars];
					f_Player[id][iBattlePassPurch] = 1;
					sk_chat(id, "Sikeresen megvásároltad a ^3BattlePass belépőt!")
				}
				else
					sk_chat(id, "Nincs elég pénzed a vásárláshoz!")
			}
			else if(PressedBuy == 1)
			{
				if(sk_get_pp(id) >= StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyPremium])
				{
					sk_set_pp(id, sk_get_pp(id)-StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyPremium])
					
					sk_chat(id, "Sikeresen megvásároltad a ^3BattlePass belépőt! ^4(PP)", f_Player[id][TradeEnableKit])
					InsertBuyDatas(id, fmt("%s", StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][StoreName]), StoreDatas[f_PlayerMenus[id][SelectedStoreItem]][BuyPremium], 0.0)
				}
				else
					sk_chat(id, "Nincs elég Prémium Pontod a vásárláshoz!")
			}
			openStoreMenu(id, f_PlayerMenus[id][SelectedStoreItem])
		}
	}
	
}
public openPlayerChooserMute(id) {
	new szMenu[121], players[32], pnum, iName[32], szTempid[10]
	get_players(players, pnum, "ch")

	formatex(szMenu, charsmax(szMenu), "\d%s \r[ \wJátékos némítás \r]", MENUPREFIX)//MOD_MENU_PLAYER_MUTE_TITLE
	new menu = menu_create(szMenu, "hPlayerChooserMute");

	for(new i; i<pnum; i++)
	{
		get_user_name(players[i], iName, charsmax(iName))
		num_to_str(players[i], szTempid, charsmax(szTempid))
		menu_additem(menu, iName, szTempid)
	}

	menu_setprop(menu, MPROP_NEXTNAME, fmt("%L", id, "GENERAL_MENU_NEXT"));
	menu_setprop(menu, MPROP_BACKNAME, fmt("%L", id, "GENERAL_MENU_BACK"));
	menu_setprop(menu, MPROP_EXITNAME, fmt("%L", id, "GENERAL_MENU_EXIT"));
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

	sk_chat(id, "Te már %s %s játékost.", g_Mute[id][key] ? "^3nem fogod hallani^4": "^4hallod^3", sm_PlayerName[key])
}
public openVIPAruhaz(id, _VipType)
{
	new String[256], iTime[32]
	f_Player[id][PressedVIPMenu] = _VipType;
	formatex(String, charsmax(String), "\d%s \r[ \wVIP Vásárlás \r]", MENUPREFIX, f_Player[id][Dollar], sk_get_pp(id));//MOD_MENU_VIP_PURCHASE_TITLE
	new menu = menu_create(String, "openVIPAruhaz_h");

	menu_addtext2(menu, fmt("%L", id, "MOD_MENU_VIP_PURCHASE_GUIDE_KEY", f_Player[id][Tolvajkesztyu] ? 4 : 3))
	if(f_Player[id][Tolvajkesztyu])
		menu_addtext2(menu, fmt("%L^n", id, "MOD_MENU_VIP_PURCHASE_ACTIVE_THIEF_GLOVE_NOTICE"))
	switch(_VipType)
	{
		case 1:
		{
			if(f_Player[id][isVip] == 1)
			{
				client_print_color(id, print_team_default, "^4%s ^3Sajnálom!^1 Amíg van bármilyen ^3Prémium VIP-ed^1 addig nem tudsz újat vásárolni!", CHATPREFIX)
				menu_destroy(menu);
				return PLUGIN_HANDLED;
			}

			format_time(iTime, 32, "%Y.%m.%d - %H:%M:%S", get_systime()+86400*f_PlayerMenus[id][BuyVIPDay])
			menu_addtext2(menu, fmt("%L", id, "MOD_MENU_VIP_PURCHASE_ITEM_REGULAR_VIP"))
			menu_additem(menu, fmt("%L^n", id, "MOD_MENU_VIP_PURCHASE_DURATION", f_PlayerMenus[id][BuyVIPDay], iTime),"1")
		}
		case 2:
		{
			if(f_Player[id][isVip] == 1)
			{
				client_print_color(id, print_team_default, "^4%s ^3Sajnálom!^1 Amíg van bármilyen ^3Prémium VIP-ed^1 addig nem tudsz újat vásárolni!", CHATPREFIX)
				menu_destroy(menu);
				return PLUGIN_HANDLED;
			}

			format_time(iTime, 32, "%Y.%m.%d - %H:%M:%S", get_systime()+86400*f_PlayerMenus[id][BuyVIPDay]*7)
			menu_addtext2(menu, fmt("%L", id, "MOD_MENU_VIP_PURCHASE_ITEM_PREMIUM_VIP"))
			menu_additem(menu, fmt("%L^n", id, "MOD_MENU_VIP_PURCHASE_DURATION", f_PlayerMenus[id][BuyVIPDay], iTime),"1")

			if(PremiunVIP_PPCost*f_PlayerMenus[id][BuyVIPDay] <= sk_get_pp(id))
				menu_additem(menu, fmt("\y%L", id, "MOD_MENU_VIP_PURCHASE_CONFIRM", PremiunVIP_PPCost*f_PlayerMenus[id][BuyVIPDay]), "2", 0)
			else
				menu_additem(menu, fmt("\d%L", id, "MOD_MENU_VIP_PURCHASE_CONFIRM", PremiunVIP_PPCost*f_PlayerMenus[id][BuyVIPDay]), "-1", 0)
		}
	}
	
	menu_setprop(menu, MPROP_NEXTNAME, fmt("%L", id, "GENERAL_MENU_NEXT"));
	menu_setprop(menu, MPROP_BACKNAME, fmt("%L", id, "GENERAL_MENU_BACK"));
	menu_setprop(menu, MPROP_EXITNAME, fmt("%L", id, "GENERAL_MENU_EXIT"));
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
	new key = str_to_num(data);
	new formattedcumo[128]

	new SteamAjdi[33], IPAjdi[33];
	get_user_authid(id, SteamAjdi, 33)
	get_user_ip(id, IPAjdi, 33, 1)

	format(formattedcumo, sizeof(formattedcumo) - 1, "%s - %s", SteamAjdi, IPAjdi);
	
	switch(key)
	{
		case -1: client_print_color(id, print_team_default, "^4%s^1 Nincs elég egyenleged, hogy megvásárold ezt a tárgyat!", CHATPREFIX);
		case 1: client_cmd(id, "messagemode VIPhet")
		case 2:
		{
			client_cmd(id, "spk Herboynew/buy")
			if(f_Player[id][PressedVIPMenu] == 2)
			{
				if(sk_get_pp(id) >= PremiunVIP_PPCost*f_PlayerMenus[id][BuyVIPDay])
				{
					sk_set_pp(id, sk_get_pp(id)-PremiunVIP_PPCost*f_PlayerMenus[id][BuyVIPDay]);
					f_Player[id][VipTime] += get_systime()+86400*f_PlayerMenus[id][BuyVIPDay]*7;
					f_Player[id][isVip] = 1;
					sk_log("v5PremiumPontVasarlas", fmt("[VIP BUY] (%s) %s vett %i hétre szóló pvipet(Maradék pontok: %i / Vásárlás előtti pontok: %i / AccID: %i)", formattedcumo, sm_PlayerName[id], f_PlayerMenus[id][BuyVIPDay], sk_get_pp(id)-(PremiunVIP_PPCost*f_PlayerMenus[id][BuyVIPDay]), sk_get_pp(id), sk_get_accountid(id)))
					sk_chat(id,  "^1Item megvásárolva: ^3Prémium VIP ^1(%i HÉT^1) ^3| ^4[^1Ára: ^3%i PP^4]", f_PlayerMenus[id][BuyVIPDay], PremiunVIP_PPCost*f_PlayerMenus[id][BuyVIPDay]);
					InsertBuyDatas(id, fmt("PVIP %i HÉT", f_PlayerMenus[id][BuyVIPDay]), PremiunVIP_PPCost*f_PlayerMenus[id][BuyVIPDay], 0.0)

					if(f_Player[id][Tolvajkesztyu])
					{
						f_Player[id][Tolvajkesztyu] = 0;
						f_Player[id][TolvajkesztyuEndTime] = 0;
						f_Player[id][Dollar] += 15.00;
						sk_chat(id, "^3Tolvajkesztyűd töröltük, mert vettél ^3VIP-et! ^1Kaptál vissza^3 15.00$-t!")
					}
				}
			}
			else
			{
				client_print_color(id, print_team_default, "^4%s^1 Nincs elég egyenleged, hogy megvásárold ezt a tárgyat!", CHATPREFIX);
			}
		}
	}
	f_PlayerMenus[id][BuyVIPDay] = 1;
}
public cmdVIPDay(id)
{
	new iArgDate[32]
	read_args(iArgDate, charsmax(iArgDate))
	remove_quotes(iArgDate)
	f_PlayerMenus[id][BuyVIPDay] = str_to_num(iArgDate)

	if(f_PlayerMenus[id][BuyVIPDay] > 650 || f_PlayerMenus[id][BuyVIPDay] <= 0)
	{
		f_PlayerMenus[id][BuyVIPDay] = 1;
		client_print_color(id, print_team_default, "^4%s^1Nanana! Azért ennyire ne legyél telhetetlen!", CHATPREFIX);
		return PLUGIN_HANDLED;
	}
	
	openVIPAruhaz(id, f_Player[id][PressedVIPMenu])
	return PLUGIN_HANDLED;
}
public openChatPrefixMenu(id)
{
	new menu = menu_create(fmt("\d%s \r[ \wChat Prefix vásárlás \r]", MENUPREFIX, f_Player[id][Dollar], sk_get_pp(id)), "Prefix_h");//MOD_MENU_CHAT_PREFIX_PURCHASE_TITLE

	if(strlen(f_Player[id][ChatPrefix]) > 0)
	{
		new sDateAndTime[40], sDateAndTime1[40], len
		format_time(sDateAndTime, charsmax(sDateAndTime), "%Y.%m.%d - %H:%M:%S", f_Player[id][ChatPrefixAdded])
		format_time(sDateAndTime1, charsmax(sDateAndTime1), "%Y.%m.%d - %H:%M:%S", f_Player[id][ChatPrefixRemove])

		menu_addtext2(menu, fmt("%L \r%s", id, "MOD_MENU_CHAT_PREFIX_PURCHASE_PREFIXED", f_Player[id][ChatPrefix]))
		menu_addtext2(menu, fmt("%L \r%s", id, "MOD_MENU_CHAT_PREFIX_PURCHASE_PREFIXED_PURCHASED", sDateAndTime))
		if(f_Player[id][ChatPrefixRemove] == -1)
		{
			if(f_Player[id][a_UserId] == 10043 || f_Player[id][a_UserId] == 2)
				len += formatex(sDateAndTime1[len], charsmax(sDateAndTime1)-len, "\wby \rshedi <3");	

			menu_addtext2(menu, fmt("%L \r%s", id, "MOD_MENU_CHAT_PREFIX_PURCHASE_PREFIXED_EXPIRATION", sDateAndTime1))
			menu_addblank2(menu);
		}
		else
		{
			menu_addtext2(menu, fmt("%L \r%L", id, "MOD_MENU_CHAT_PREFIX_PURCHASE_PREFIXED_EXPIRATION", id, "MOD_MENU_CHAT_PREFIX_PURCHASE_NEVER"))
			menu_addblank2(menu);
		}
	}
	else
	{
		menu_addtext2(menu, fmt("%L \r--", id, "MOD_MENU_CHAT_PREFIX_PURCHASE_PREFIXED"))
		menu_addtext2(menu, fmt("%L \r--", id, "MOD_MENU_CHAT_PREFIX_PURCHASE_PREFIXED_PURCHASED"))
		menu_addtext2(menu, fmt("%L \r--", id, "MOD_MENU_CHAT_PREFIX_PURCHASE_PREFIXED_EXPIRATION"))
		menu_addblank2(menu);
	}

	if(strlen(f_Player[id][ChatPrefix]) > 0)
	{
		menu_additem(menu, fmt("%L \y[\r%3.2f$\y]", id, "MOD_MENU_CHAT_PREFIX_PURCHASE_NEW_PREFIX", ChatPrefix_Cost), "1")
		menu_additem(menu, fmt("%L", id, "MOD_MENU_CHAT_PREFIX_PURCHASE_REMOVE_PREFIX"), "2")
	}	
	else
		menu_additem(menu, fmt("%L \y[\r%3.2f$\y]", id, "MOD_MENU_CHAT_PREFIX_PURCHASE_BUY_PREFIX", ChatPrefix_Cost), "1")

	menu_setprop(menu, MPROP_NEXTNAME, fmt("%L", id, "GENERAL_MENU_NEXT"));
	menu_setprop(menu, MPROP_BACKNAME, fmt("%L", id, "GENERAL_MENU_BACK"));
	menu_setprop(menu, MPROP_EXITNAME, fmt("%L", id, "GENERAL_MENU_EXIT"));
	menu_display(id, menu, 0);
}
public Prefix_h(id, menu, item)
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
			if(f_Player[id][Dollar] >= ChatPrefix_Cost)
				client_cmd(id, "messagemode EnterPrefix");
			else
				client_print_color(id, print_team_default, "^4%s^1 Nincs elég ^3dollárod!", CHATPREFIX);
		}
		case 2:
		{
			f_Player[id][ChatPrefix][0] = EOS;
			f_Player[id][ChatPrefixAdded] = 0;
			f_Player[id][ChatPrefixRemove] = 0;
		}
	}
}
public set_Prefix(id)
{
	if(f_Player[id][Dollar] < 101)
		return;

	new Arg1[32];
	read_argv(1, Arg1, charsmax(Arg1));
	if(!(RegexTester(id, Arg1, "^^[A-Za-z0-9öüóőúéáűíÖÜÓŐÚÉÁŰÍ <>=\/_.:!\?\*\[\]+,()\-]{1,16}+$", "A beírt szöveg csak magyar abc-t, számok és a hossza ^3maximum 16 karakter^1 lehet!")))
	{
		openChatPrefixMenu(id)
		return;
	}

	new Admin_Permissions_size = sizeof(Admin_Permissions);
	for(new i=0; i < Admin_Permissions_size; i++)
	{
		if(equali(Arg1, Admin_Permissions[i][0]))
		{
			client_print_color(id, print_team_default, "^4%s^1Nem használhatod a^1 ^"^3%s^1^" ^4nevű^1 Egyedi Chat Prefixe-t.", CHATPREFIX, f_Player[id][ChatPrefix]);
			openChatPrefixMenu(id)
			return;
		}
	}
	client_cmd(id, "spk Herboynew/buy")
	copy(f_Player[id][ChatPrefix], 16, Arg1)
	f_Player[id][ChatPrefixAdded] = get_systime()
	f_Player[id][ChatPrefixRemove] = get_systime()+1209600;
	f_Player[id][Dollar] -= ChatPrefix_Cost;
	client_print_color(id, print_team_default, "^4%s ^1Sikeresen megvásároltad a^1 ^"^3%s^1^" ^4nevű^1 Chat Prefixed.", CHATPREFIX, f_Player[id][ChatPrefix])
}
public openInventorySwitch(id)
{	
	new iras[121];
	switch(f_Player[id][openSelectItemRow])
	{//MOD_MENU_SKINS_EQUIPMENT_TITLE, MOD_MENU_SKINS_WEAPON_MANAGEMENT_TITLE, MOD_MENU_SKINS_SALE_SENDING_TITLE
		case 0: format(iras, charsmax(iras), "%s \r[ \wFelszerelés \r]", MENUPREFIX);
		case 1: format(iras, charsmax(iras), "%s \r[ \wFegyver kezelés \r]", MENUPREFIX);
		case 3: format(iras, charsmax(iras), "%s \r[ \wSkin Küldés\r/\wCsere \r]", MENUPREFIX);
		case 4: format(iras, charsmax(iras), "%s \r[ \wKUKÁZÁS \r]", MENUPREFIX);
	}

	new menu = menu_create(iras, "hRaktarMenu");
	menu_additem(menu, fmt("\wAK47 \y[\r%s\y]", FegyverInfo[Equipment[id][0][0]][wname]), "2")
	menu_additem(menu, fmt("\wM4A1 \y[\r%s\y]", FegyverInfo[Equipment[id][1][0]][wname]), "3")
	menu_additem(menu, fmt("\wAWP \y[\r%s\y]", FegyverInfo[Equipment[id][2][0]][wname]), "4")
	menu_additem(menu, fmt("\wDEAGLE \y[\r%s\y]", FegyverInfo[Equipment[id][3][0]][wname]), "5")
	menu_additem(menu, fmt("\wKNIFE \y[\r%s\y]", FegyverInfo[Equipment[id][4][0]][wname]), "6")
	menu_additem(menu, fmt("\wSCOUT \y[\r%s\y]^n", FegyverInfo[Equipment[id][5][0]][wname]), "7")
	menu_additem(menu, fmt("\yKeresés", FegyverInfo[Equipment[id][0][0]][wname]), "1")
	menu_additem(menu, fmt("\wFAMAS \y[\r%s\y]", FegyverInfo[Equipment[id][6][0]][wname]), "8")
	menu_additem(menu, fmt("\wGALIL \y[\r%s\y]", FegyverInfo[Equipment[id][7][0]][wname]), "9")
	menu_additem(menu, fmt("\wM249 \y[\r%s\y]", FegyverInfo[Equipment[id][8][0]][wname]), "10")
	menu_additem(menu, fmt("\wTMP \y[\r%s\y]", FegyverInfo[Equipment[id][9][0]][wname]), "11")
	menu_additem(menu, fmt("\wMP5 \y[\r%s\y]", FegyverInfo[Equipment[id][10][0]][wname]), "12")
	menu_additem(menu, fmt("\wP90 \y[\r%s\y]", FegyverInfo[Equipment[id][11][0]][wname]), "13")
	menu_additem(menu, fmt("\wM3 \y[\r%s\y]", FegyverInfo[Equipment[id][12][0]][wname]), "14")
	menu_additem(menu, fmt("\wXM1014 \y[\r%s\y]", FegyverInfo[Equipment[id][13][0]][wname]), "15")
	menu_additem(menu, fmt("\wGLOCK18 \y[\r%s\y]", FegyverInfo[Equipment[id][14][0]][wname]), "16")
	menu_additem(menu, fmt("\wUSP \y[\r%s\y]", FegyverInfo[Equipment[id][15][0]][wname]), "17")

	menu_setprop(menu, MPROP_NEXTNAME, fmt("\y%L", id, "GENERAL_MENU_NEXT"));
	menu_setprop(menu, MPROP_BACKNAME, fmt("\d%L", id, "GENERAL_MENU_BACK"));
	menu_setprop(menu, MPROP_EXITNAME, fmt("\r%L", id, "GENERAL_MENU_EXIT"));

	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	menu_display(id, menu);
}
public hRaktarMenu(id, menu, item)
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
		case 1: client_cmd(id, "messagemode SkinKereses")
		case 2: openInventory(id, CSW_AK47, "")
		case 3: openInventory(id, CSW_M4A1, "")
		case 4: openInventory(id, CSW_AWP, "")
		case 5: openInventory(id, CSW_DEAGLE, "")
		case 6: openInventory(id, CSW_KNIFE, "")
		case 7: openInventory(id, CSW_SCOUT, "")
		case 8: openInventory(id, CSW_FAMAS, "")
		case 9: openInventory(id, CSW_GALIL, "")
		case 10: openInventory(id, CSW_M249, "")
		case 11: openInventory(id, CSW_TMP, "")
		case 12: openInventory(id, CSW_MP5NAVY, "")
		case 13: openInventory(id, CSW_P90, "")
		case 14: openInventory(id, CSW_M3, "")
		case 15: openInventory(id, CSW_XM1014, "")
		case 16: openInventory(id, CSW_GLOCK18, "")
		case 17: openInventory(id, CSW_USP, "")
	}
	return;
}
public cmdSearchSkinString(id) {
	sk_chat(id, "Írd be azt amire szeretnél keresni, pl: ^3Törhetetlen, AK47, Asiimov, ^1vagy akár ^3névcédulára is.")
	new Data[33];
	read_args(Data, charsmax(Data));
	remove_quotes(Data);

	if(!(RegexTester(id, Data, "^^[A-Za-z0-9öüóőúéáűíÖÜÓŐÚÉÁŰÍ <>=\/_.:!\?\*\[\]+,()\-]{1,32}+$", "A beírt szöveg csak magyar abc-t, számok és ^"<>=/_.!?*[]+,()-^"-ket tartalmazhatja, és a hossza nem haladhatja meg a^3 32-őt!")))
	{
		openInventorySwitch(id)
		return;
	}
	openInventory(id, -1, Data)
	return;
}
public openInventory(id, WEAPENT, searchstr[])
{
	new String[8];
	new menu = menu_create(fmt("\d%s \r[ \wRaktár \r]", MENUPREFIX), "Raktar_reszletes");//MOD_MENU_WEAPON_STORAGE_TITLE

	f_Player[id][SelectedInvArryKey] = 0;

	new addCount = 0; 

	for(new i = f_Player[id][InventoryWriteableSize] - 1; i >= 0;i--)
	{
		new Item[InventorySystem];
		Item = gInventory[id][i];
		
		new len;
		if((FegyverInfo[Item[w_id]][EntName] == WEAPENT || WEAPENT == -1) && Item[deleted] == 0)
		{
			new szMenu[256]
			if(Item[equipped])
				len += formatex(szMenu[len], charsmax(szMenu) - len, "\r* \d- ");

			if(FegyverInfo[Item[w_id]][is_deleted])
			{
				if(Item[isNameTaged])
					len += formatex(szMenu[len], charsmax(szMenu) - len, "\d%s^"%s^" (\d%L\d)", FegyverInfo[Item[w_id]][MenuWeapon], Item[Nametag], id, "MOD_MENU_WEAPON_STORAGE_DELETED");
				else
					len += formatex(szMenu[len], charsmax(szMenu) - len, "\d%s%s (\d%L\d)", FegyverInfo[Item[w_id]][MenuWeapon], FegyverInfo[Item[w_id]][wname], id, "MOD_MENU_WEAPON_STORAGE_DELETED");
			}
			else if(Item[Allapot] <= 4)
			{
				if(Item[isNameTaged])
					len += formatex(szMenu[len], charsmax(szMenu) - len, "\d%s^"%s^" (\d%L\d)", FegyverInfo[Item[w_id]][MenuWeapon], Item[Nametag], id, "MOD_MENU_WEAPON_STORAGE_BROKE");
				else
					len += formatex(szMenu[len], charsmax(szMenu) - len, "\d%s%s (\d%L\d)", FegyverInfo[Item[w_id]][MenuWeapon], FegyverInfo[Item[w_id]][wname], id, "MOD_MENU_WEAPON_STORAGE_BROKE");
			}
			else
			{
				if(Item[isNameTaged])
					len += formatex(szMenu[len], charsmax(szMenu) - len, "\w%s^"%s^" (\r%s\w)", FegyverInfo[Item[w_id]][MenuWeapon], Item[Nametag], Item[Allapot] == 101 ? fmt("\y%L", id, "MOD_MENU_WEAPON_STORAGE_UNBREAKABLE") : (fmt("%i%%", Item[Allapot])));
				else
					len += formatex(szMenu[len], charsmax(szMenu) - len, "\w%s%s(\r%s\w)", FegyverInfo[Item[w_id]][MenuWeapon], FegyverInfo[Item[w_id]][wname], Item[Allapot] == 101 ? fmt("\y%L", id, "MOD_MENU_WEAPON_STORAGE_UNBREAKABLE") : (fmt("%i%%", Item[Allapot])));
			}
			
			if(Item[isStatTraked])
				len += formatex(szMenu[len], charsmax(szMenu) - len, " \rsT*");

			if(get_systime() < Item[is_new])
				len += formatex(szMenu[len], charsmax(szMenu) - len, " \y*%L!", id, "MOD_MENU_WEAPON_STORAGE_NEW");

			num_to_str(i, String, 5);

			if(WEAPENT == -1)
			{
				new lower_szmenu[256];
				copy(lower_szmenu, charsmax(lower_szmenu), szMenu)
				strtolower(lower_szmenu)
				strtolower(searchstr)

				if(containi(lower_szmenu, searchstr) != -1)
				{
					menu_additem(menu, szMenu, String);
					
					console_print(id, lower_szmenu)
					addCount++;
					if(addCount % 6 == 0)
						menu_addblank2(menu);
				}
			}
			else
			{
				menu_additem(menu, szMenu, String);
				addCount++;
				if(addCount % 6 == 0)
					menu_addblank2(menu);
			}
		}
	}
	if(addCount == 0)
		menu_addtext2(menu, fmt("\dA keresésedre: \r^"%s^" \dnincs találat!", searchstr))

	menu_setprop(menu, MPROP_NEXTNAME, fmt("%L", id, "GENERAL_MENU_NEXT"));
	menu_setprop(menu, MPROP_BACKNAME, fmt("%L", id, "GENERAL_MENU_BACK"));
	menu_setprop(menu, MPROP_EXITNAME, fmt("%L", id, "GENERAL_MENU_EXIT"));
	menu_display(id, menu, 0);
}

public Raktar_reszletes(id, menu, item) {
	if(item == MENU_EXIT)
	{
		f_Player[id][openSelectItemRow] = 0;
		menu_destroy(menu);
		return PLUGIN_HANDLED
	}

	new data[9], szName[64]
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName, charsmax(szName), callback);
	new key = str_to_num(data);

	if(f_Player[id][openSelectItemRow] == 1)
	{
		f_Player[id][SelectedInvArryKey] = key;
		openInventoryReszletes(id, key);
		return PLUGIN_HANDLED;
	}
	if(FegyverInfo[gInventory[id][key][w_id]][is_deleted])
	{
		sk_chat(id, "Ez a ^3skin^1 már nincs bent a szerveren, csak összetőrni tudod.")
		return PLUGIN_HANDLED;
	}
	if(f_Player[id][openSelectItemRow] == 3)
	{
		if(gInventory[id][key][tradable] == 0)
		{
			client_cmd(id, "spk events/friend_died.wav")
			client_print_color(id, print_team_default, "^4%s^1 Ez a fegyver nem eladható / nem küldhető!", CHATPREFIX)
			return PLUGIN_HANDLED;
		}
		if(gInventory[id][key][equipped])
		{
			client_cmd(id, "spk events/friend_died.wav")
			client_print_color(id, print_team_default, "^4%s^1 Először lekéne szerelni a fegyvert, nem gondolod?", CHATPREFIX)
			return PLUGIN_HANDLED;
		}

		if(f_Player[id][SwitchingOnMarket] != 1)
		{
			new SendToId = f_Player[id][SendTemp];
			if(!InventoryCanAdd(SendToId, "", 0))
			{
				f_Player[id][SendTemp] = 0;
				f_Player[id][openSelectItemRow] = 0;
				sk_chat(id, "Akinek küldeni szerettél volna, annak ^3Tele^1 van a Raktára!")
				return PLUGIN_HANDLED;
			}
			gInventory[id][key][is_new] = get_systime()+21600;
			gInventory[id][key][equipped] = 0;
			gInventory[SendToId][f_Player[SendToId][InventoryWriteableSize]] = gInventory[id][key];
			f_Player[SendToId][Inventory_Size]++;
			f_Player[SendToId][InventoryWriteableSize]++;
			f_Player[id][Inventory_Size]--;
			UpdateItem(id, 4, key, sk_get_accountid(SendToId))

			gInventory[id][key][deleted] = 1;
		}
		else
		{
			f_Player[id][SelectedInvArryKey] = key;
			f_Player[id][SelectedItemToPlace] = 1;
			openSellMenu(id);
			return PLUGIN_HANDLED;
		}

		if(gInventory[id][key][isNameTaged])
			client_print_color(0, print_team_default, "^4%s ^3%s^1 küldött ^4%s^1-nek egy ^3%s%s^1 skint, ^4%s^1 fegyverre.", CHATPREFIX, sm_PlayerName[id], sm_PlayerName[f_Player[id][SendTemp]], gInventory[id][key][isStatTraked] ? "StatTrak* " : "", gInventory[id][key][Nametag], FegyverInfo[gInventory[id][key][w_id]][ChatWeapon]);
		else
			client_print_color(0, print_team_default, "^4%s ^3%s^1 küldött ^4%s^1-nek egy ^3%s%s^1 skint, ^4%s^1 fegyverre.", CHATPREFIX, sm_PlayerName[id], sm_PlayerName[f_Player[id][SendTemp]], gInventory[id][key][isStatTraked] ? "StatTrak* " : "", FegyverInfo[gInventory[id][key][w_id]][wname], FegyverInfo[gInventory[id][key][w_id]][ChatWeapon]);
		
		smlog(id, 0, f_Player[id][SendTemp], "SEND_WEAPON", "none", fmt("[%s %s] ~ [SQLID: #%i] OpenTime: %i | WeaponID: %i | Durability: %i | StatTraked: %i | NameTag: %s ~ OpenedFrom: %s | SendToAccId: #%i", FegyverInfo[gInventory[id][key][w_id]][wname], FegyverInfo[gInventory[id][key][w_id]][ChatWeapon], gInventory[id][key][sqlid], gInventory[id][key][opened], gInventory[id][key][w_id], gInventory[id][key][Allapot], gInventory[id][key][isStatTraked], gInventory[id][key][Nametag], gInventory[id][key][openedfrom], sk_get_accountid(f_Player[id][SendTemp])))
		f_Player[id][openSelectItemRow] = 0;
		return PLUGIN_HANDLED;
	}
	if(f_Player[id][openSelectItemRow] == 4)
	{
		Kuka_Menu(id, key)
		return PLUGIN_HANDLED;
	}
	if(gInventory[id][key][Allapot] > 4)
		WeaponEquipment(id, key, gInventory[id][key][w_id])
	else
	{
		client_cmd(id, "spk events/friend_died.wav")
		client_print_color(id, print_team_default, "^4%s^1 Ez a fegyver ^3tönkrement^1, válassz ki másikat, vagy javítsd meg a ^3fegyver kezelésben ^4(T 1 7)", CHATPREFIX);
		openInventorySwitch(id)
	}
	f_Player[id][openSelectItemRow] = 0;
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public WeaponEquipment(id, nowid, widtemp)
{
	new WeaponID = GetWeaponIdByEnt(FegyverInfo[widtemp][EntName])// A w_idből megint kikeressük a megfelelő weap-idt.
	new iWeaponVariable = GetWeaponVariable(FegyverInfo[widtemp][EntName]);
	console_print(0, "WeaponID: %i | iWeaponVariable: %i", WeaponID, iWeaponVariable)
	new curr_e_id = sm_HudWeapon[id][iWeaponVariable][h_EntId];

	if(FegyverInfo[widtemp][EntName] != CSW_KNIFE)
	{
		weapon_deteriorate(id, WeaponID, FegyverInfo[widtemp][EntName]);
		restart_user_shot_ammo(id, FegyverInfo[widtemp][EntName]);
	} 
	gInventory[id][Equipment[id][WeaponID][1]][equipped] = 0;
	UpdateItem(id, 5, Equipment[id][WeaponID][1], 0)

	gInventory[id][nowid][equipped] = 1;
	UpdateItem(id, 5, nowid, 0)

	Equipment[id][WeaponID][0] = widtemp
	Equipment[id][WeaponID][1] = nowid
	//if(FegyverInfo[widtemp][EntName] != CSW_KNIFE)
	update_weapon_edata(id, curr_e_id);
	// else
	// 	sk_chat(id, "A ^3kés^1 skined a következő ^3HALÁL^1 után látszódik a kezedben!")	

	sk_chat(id, "Sikeresen felszerelted a(z) ^4%s | %s^1 fegyveredet.", FegyverInfo[gInventory[id][nowid][w_id]][ChatWeapon], FegyverInfo[gInventory[id][nowid][w_id]][wname])

}
public openInventoryReszletes(id, arraykey)
{
	new menu = menu_create(fmt("\d%s \r[ \wFegyver kezelés\r ]^n^n\wFegyver: \r%s%s\w[\y#%i\w]", MENUPREFIX, FegyverInfo[gInventory[id][arraykey][w_id]][MenuWeapon], FegyverInfo[gInventory[id][arraykey][w_id]][wname], gInventory[id][arraykey][sqlid]), "openInventoryReszlet_h");//MOD_MENU_WEAPON_MANAGEMENT_TITLE
	new sz1[3], sz2[3], sz3[3]
	if(f_Player[id][NametagTool] > 0)
		copy(sz1, charsmax(sz1), "\y")
	else copy(sz1, charsmax(sz1), "\d")

	if(f_Player[id][StatTrakTool] > 0)
		copy(sz2, charsmax(sz2), "\r")
	else copy(sz2, charsmax(sz2), "\d")

	if(f_Player[id][StatTrakTool] > 0)
		copy(sz3, charsmax(sz3), "\y")
	else copy(sz3, charsmax(sz3), "\d")
	new String[20]
	if(gInventory[id][arraykey][Allapot] <= 4)
		copy(String, charsmax(String), fmt("\d(%L)", id, "MOD_MENU_WEAPON_MANAGEMENT_BROKEN"))
	else copy(String, charsmax(String), "")

	menu_addtext2(menu, fmt("\wNévcédula: %s^n\wStatTrak: %s^n\wÁllapot: %s\d| \wEladható: \r%s^n", 
	gInventory[id][arraykey][isNameTaged] == 1 ? fmt("\y%s", gInventory[id][arraykey][Nametag]) : "\dNincs", gInventory[id][arraykey][isStatTraked] == 1 ? fmt("\rVan \d| \wÖlés: \r%i", gInventory[id][arraykey][StatTrakKills]) : "\dNincs",
	gInventory[id][arraykey][Allapot] == 101 ? fmt("\y%L ", id, "MOD_MENU_WEAPON_STORAGE_UNBREAKABLE") : (fmt("\r%i%% %s", gInventory[id][arraykey][Allapot], String)), gInventory[id][arraykey][tradable] == 1 ? "\yIgen" : "\rNem"))
		
	if(FegyverInfo[gInventory[id][arraykey][w_id]][is_deleted] == 0)
	{
		if(gInventory[id][arraykey][tradable] == 0 && gInventory[id][arraykey][w_id] > 16)
			menu_additem(menu, fmt("\yEladhatóvá alakítás \r[\w%i DB Átalakító készlet\r]", f_Player[id][TradeEnableKit]), "99")
		if(gInventory[id][arraykey][isNameTaged])
			menu_additem(menu, fmt("%L", id, "MOD_MENU_WEAPON_MANAGEMENT_RENAME_EXISTING", sz1, f_Player[id][NametagTool]), "1")
		else
			menu_additem(menu, fmt("%L", id, "MOD_MENU_WEAPON_MANAGEMENT_RENAME_NEW", sz1, f_Player[id][NametagTool]), "1")
		if(gInventory[id][arraykey][isStatTraked])
			menu_additem(menu, fmt("%L", id, "MOD_MENU_WEAPON_MANAGEMENT_RESET_STAT_TRAK", sz2, sz3, f_Player[id][StatTrakTool]), "2");
		else
			menu_additem(menu, fmt("%L", id, "MOD_MENU_WEAPON_MANAGEMENT_EQUIP_STAT_TRAK", sz2, sz3, f_Player[id][StatTrakTool]), "2");

		if(gInventory[id][arraykey][Allapot] < 101 && gInventory[id][arraykey][w_id] > 16)
		{
			if(gInventory[id][arraykey][Allapot] == 100)
				menu_additem(menu, fmt("\d%L \r(\d10%%/30$\r)", id, "MOD_MENU_WEAPON_MANAGEMENT_UPGRADE_WEAPON"), "4", 0)
			else if(gInventory[id][arraykey][Allapot] <= 4)
				menu_additem(menu, fmt("\y%L \r[\w100.00\y$\r]", id, "MOD_MENU_WEAPON_MANAGEMENT_RESTORE_WEAPON"), "4", 0)
			else if(gInventory[id][arraykey][Allapot] <= 90)
				menu_additem(menu, fmt("\y%L \r(\w10%%/15$\r)", id, "MOD_MENU_WEAPON_MANAGEMENT_UPGRADE_WEAPON"), "4", 0)
			else if(gInventory[id][arraykey][Allapot] >= 91)
				menu_additem(menu, fmt("\y%L \r(\w1%%/2$\r)", id, "MOD_MENU_WEAPON_MANAGEMENT_UPGRADE_WEAPON"), "4", 0)
		}

		if(gInventory[id][arraykey][Allapot] < 101 && f_Player[id][TorhetetlenitoKeszlet] > 0)//Ha a fegyvert véglegesítjük 100 Fegyver darabkából akkor 300 lövésenként nem romlik 1%-ot sem soha.
			menu_additem(menu, fmt("\y%L", id, "MOD_MENU_WEAPON_MANAGEMENT_MAKE_UNBREAKABLE"), "6", 0)
		else if(gInventory[id][arraykey][Allapot] < 101 && f_Player[id][TorhetetlenitoKeszlet] == 0)
			menu_additem(menu, fmt("\y%L", id, "MOD_MENU_WEAPON_MANAGEMENT_MAKE_UNBREAKABLE_FRAGMENTS", TorhetetlenitesAra), "5", 0)
		else
			menu_additem(menu, fmt("\d%L", id, "MOD_MENU_WEAPON_MANAGEMENT_ALREADY_UNBREAKABLE"), "5", ADMIN_ADMIN)

		if(gInventory[id][arraykey][Allapot] < 101 && gInventory[id][arraykey][w_id] > 16)
		{
			if(gInventory[id][arraykey][isStatTraked] || gInventory[id][arraykey][isNameTaged]) //Ha a fegyver stattrakos vagy névcédulás akkor érvényes az első pont, ha nem akkor a második.
				menu_additem(menu, fmt("\y%L", id, "MOD_MENU_WEAPON_MANAGEMENT_DISMANTLE", GetRewardToredek(id, arraykey)), "3"); //első pont, ha összetöröd a fegyvered eltűnik a raktáradból, és kapsz helyette fegyver darabkát.
			else
				menu_additem(menu, fmt("\y%L", id, "MOD_MENU_WEAPON_MANAGEMENT_DISMANTLE", GetRewardToredek(id, arraykey)), "3");
		}
		else
			menu_additem(menu, fmt("\d%L", id, "MOD_MENU_WEAPON_MANAGEMENT_CANNOT_DISMANTLE"), "3", ADMIN_ADMIN);
	}
	else
	{
		menu_addtext2(menu, fmt("\w%L^n", id, "MOD_MENU_WEAPON_MANAGEMENT_SKIN_MISSING"));
		if(gInventory[id][arraykey][Allapot] == -101)
			menu_additem(menu, fmt("\y%L", id, "MOD_MENU_WEAPON_MANAGEMENT_DISMANTLE_50000"), "3");
		else if(gInventory[id][arraykey][isStatTraked] || gInventory[id][arraykey][isNameTaged]) //Ha a fegyver stattrakos vagy névcédulás akkor érvényes az első pont, ha nem akkor a második.
			menu_additem(menu, fmt("\y%L", id, "MOD_MENU_WEAPON_MANAGEMENT_DISMANTLE", GetRewardToredek(id, arraykey)), "3"); //első pont, ha összetöröd a fegyvered eltűnik a raktáradból, és kapsz helyette fegyver darabkát.
		else
			menu_additem(menu, fmt("\y%L", id, "MOD_MENU_WEAPON_MANAGEMENT_DISMANTLE", GetRewardToredek(id, arraykey)), "3");
	}
	menu_setprop(menu, MPROP_EXITNAME, fmt("%L", id, "GENERAL_MENU_EXIT"));
	menu_display(id, menu, 0);
}
public openInventoryReszlet_h(id, menu, item) {
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED
	}

	new data[9], szName[64]
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName, charsmax(szName), callback);
	new key = str_to_num(data);
	new arraykey = f_Player[id][SelectedInvArryKey];

	switch(key)
	{
		case -1:
		{
			openInventoryReszletes(id, f_Player[id][SelectedInvArryKey]);
			return PLUGIN_HANDLED;
		}
		case 1:
		{
			if(f_Player[id][NametagTool] > 0)
			{
				if(gInventory[id][arraykey][isNameTaged])
					client_cmd(id, "messagemode SET_RENAMETAG")
				else
					client_cmd(id, "messagemode SET_NAMETAG")
			}
			else client_print_color(id, print_team_default, "^4%s ^1Ebből az ^3Itemből^1 neked nincs semmi! Előszőr vegyél az ^3Áruházban!", CHATPREFIX);
		}
		case 2:
		{
			if(f_Player[id][StatTrakTool] > 0)
			{
				if(gInventory[id][arraykey][isStatTraked])
					gInventory[id][arraykey][StatTrakKills] = 0;
				else
				{
					gInventory[id][arraykey][isStatTraked] = 1;
					gInventory[id][arraykey][StatTrakKills] = 0;
				}

				f_Player[id][StatTrakTool]--;

				client_print_color(id, print_team_default, "^4%s ^1A(z) ^3%s | %s^1 fegyvered mostantól számolja az ^3öléseket!", CHATPREFIX, FegyverInfo[gInventory[id][arraykey][w_id]][ChatWeapon], FegyverInfo[gInventory[id][arraykey][w_id]][wname])
				openInventoryReszletes(id, f_Player[id][SelectedInvArryKey]);
			}
			else client_print_color(id, print_team_default, "^4%s ^1Ebből az ^3Itemből^1 neked nincs semmi! Előszőr vegyél az ^3Áruházban!", CHATPREFIX);
		}
		case 3:
		{
			if(gInventory[id][arraykey][equipped])
			{
				sk_chat(id, "Először lekéne szerelni a fegyvert, nem gondolod?")
				return PLUGIN_HANDLED;
			}
			DeleteWeapon(id, arraykey)

		}
		case 4:
		{
			WeaponRepair(id, f_Player[id][SelectedInvArryKey]);
		}
		case 5:
		{
			if(f_Player[id][Toredek] >= TorhetetlenitesAra)
			{
				gInventory[id][arraykey][Allapot] = 101;
				f_Player[id][Toredek] -= TorhetetlenitesAra;
				client_print_color(id, print_team_default, "%s^1 Sikeresen ^3véglegesítetted^1 a ^4%s%s^1 fegyvered!", CHATPREFIX, FegyverInfo[gInventory[id][arraykey][w_id]][MenuWeapon], FegyverInfo[gInventory[id][arraykey][w_id]][wname])
				UpdateItem(id, 6, f_Player[id][SelectedInvArryKey], 0)
				openInventoryReszletes(id, f_Player[id][SelectedInvArryKey]);
			}
			else sk_chat(id, "Nincs elég töredéked a törhetetlenítéshez!")
		}
		case 6:
		{
			if(f_Player[id][TorhetetlenitoKeszlet] > 0)
			{
				gInventory[id][arraykey][Allapot] = 101;
				f_Player[id][TorhetetlenitoKeszlet]--;
				sk_chat(id, "Felhasználtál egy ^3Törhetetlenítő^1 készletet!")
				client_print_color(id, print_team_default, "%s^1 Sikeresen ^3törhetetlenítetted^1 a ^4%s%s^1 fegyvered!", CHATPREFIX, FegyverInfo[gInventory[id][arraykey][w_id]][MenuWeapon], FegyverInfo[gInventory[id][arraykey][w_id]][wname])
				UpdateItem(id, 6, f_Player[id][SelectedInvArryKey], 0)
				openInventoryReszletes(id, f_Player[id][SelectedInvArryKey]);
			}

		}
	}
	
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public WeaponRepair(id, ArrId)
{

	if(gInventory[id][ArrId][Allapot] == 101)
	{
		openInventoryReszletes(id, ArrId);
		return;
	}
	if(gInventory[id][ArrId][Allapot] == 100)
	{
		sk_chat(id, "A fegyvered remek állapotban van!")
		openInventoryReszletes(id, ArrId);
		return;
	}
	if(gInventory[id][ArrId][Allapot] <= 4)
	{
		if(f_Player[id][Dollar] >= 100)
		{
			f_Player[id][Dollar] -= 100;
			gInventory[id][ArrId][Allapot] = 10;
			sk_chat(id, "A fegyvered helyre lett állítva, az állapota: ^4%i%%", gInventory[id][ArrId][Allapot])
			openInventoryReszletes(id, ArrId);
			UpdateItem(id, 6, ArrId, 0)

			return;
		}
	}
	if(gInventory[id][ArrId][Allapot] < 91)
	{
		if(f_Player[id][Dollar] >= 15)
    {
			f_Player[id][Dollar] -= 15;
			gInventory[id][ArrId][Allapot] += 10;

			if(gInventory[id][ArrId][Allapot] >= 100)
				gInventory[id][ArrId][Allapot] = 100;

			sk_chat(id, "Javítottál a fegyvereden , az állapota: ^4%i%%", gInventory[id][ArrId][Allapot])
			openInventoryReszletes(id, ArrId);
			UpdateItem(id, 6, ArrId, 0)

			return;
		}
	}
	if(gInventory[id][ArrId][Allapot] >= 91)
	{
		if(f_Player[id][Dollar] >= 2)
    {
			f_Player[id][Dollar] -= 2;
			gInventory[id][ArrId][Allapot] += 1;

			if(gInventory[id][ArrId][Allapot] >= 100)
				gInventory[id][ArrId][Allapot] = 100;

			sk_chat(id, "Javítottál a fegyvereden , az állapota: ^4%i%%", gInventory[id][ArrId][Allapot])
			openInventoryReszletes(id, ArrId);
			UpdateItem(id, 6, ArrId, 0)

			return;
	}
	}

}
public cmdAddNametag(id) {
	new Data[32];
	read_args(Data, charsmax(Data));
	remove_quotes(Data);

	if(!(RegexTester(id, Data, "^^[A-Za-z0-9öüóőúéáűíÖÜÓŐÚÉÁŰÍ <>=\/_.:!\?\*\[\]+,()\-]{1,16}+$", "A beírt szöveg csak magyar abc-t, számok és ^"<>=/_.!?*[]+,()-^"-ket tartalmazhatja, és a hossza nem haladhatja meg a^3 16-ot!")))
	{
		openInventoryReszletes(id, f_Player[id][SelectedInvArryKey])
		return;
	}
	new ArrId = f_Player[id][SelectedInvArryKey];
	copy(gInventory[id][ArrId][Nametag], 32, Data)
	gInventory[id][ArrId][isNameTaged] = 1;

	UpdateItem(id, 2, f_Player[id][SelectedInvArryKey], 0)
	client_print_color(id, print_team_default, "^4%s^1A(z) ^3%s%s^1 fegyvered neve mostantól: ^3%s", CHATPREFIX, FegyverInfo[gInventory[id][ArrId][w_id]][MenuWeapon], FegyverInfo[gInventory[id][ArrId][w_id]][wname], gInventory[id][ArrId][Nametag])
	f_Player[id][NametagTool]--;
	openInventoryReszletes(id, f_Player[id][SelectedInvArryKey]);
		
	return;
}
public openCaseSwitch(id)
{
	new cim[300];
	if(f_Player[id][SwitchingOnMarket])
		format(cim, charsmax(cim), "\d%s \r[ \wLáda/Kulcs eladás\r ]", MENUPREFIX)//MOD_MENU_CASE_KEY_SELECTION_TITLE
	else
		format(cim, charsmax(cim), "\d%s \r[ \wLáda Nyitás\r ]", MENUPREFIX);//MOD_MENU_CASE_OPENING_TITLE
	new menu = menu_create(cim, "LadaEloszto_h");

	new CaseIf = sizeof(Cases);

	for(new i = 0; i < CaseIf; i++)
	{
		new Sor[6]; num_to_str(i, Sor, 5);

		if(Cases[i][CanDropAndOpenFrom] <= get_systime())
			formatex(cim, charsmax(cim), "%L", id, "MOD_MENU_CASE_KEY_SELECTION_CASE", Cases[i][cName], Case[id][i], Key[id][i]);
		else formatex(cim, charsmax(cim), "\d%s [%idb | %idb Kulcs]", Cases[i][cName], Case[id][i], Key[id][i]);

		menu_additem(menu, cim, Sor);
	}
	if(f_Player[id][Tolvajkesztyu])
	{
		new tLejar[100];
		easy_time_length(id, f_Player[id][TolvajkesztyuEndTime]-get_systime(), timeunit_seconds, tLejar, charsmax(tLejar));
		menu_addtext2(menu, fmt("^n\w%L", id, "MOD_MENU_CASE_KEY_SELECTION_GLOVE_ACTIVE", tLejar));
	}
	else
		menu_addtext2(menu, fmt("^n\w%L", id, "MOD_MENU_CASE_KEY_SELECTION_GLOVE_NONE"));
	

	menu_setprop(menu, MPROP_EXITNAME, fmt("%L", id, "GENERAL_MENU_EXIT"));
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
	if(f_Player[id][SwitchingOnMarket])
	{
		f_Player[id][SelectedLKToPlace] = str_to_num(data);
		f_Player[id][SelectedLKToPlaceDarab] = 0;
		openSellMenu(id);
	}
	else
	{
		f_Player[id][SelectedCaseForOpen] = str_to_num(data);
		openCaseReszletes(id, f_Player[id][SelectedCaseForOpen])
	}

}
public openCaseReszletes(id, caseid)
{
	new menu = menu_create(fmt("\d%s \r[ \wLáda nyitás \r]", MENUPREFIX), "openCaseReszletes_h");//MOD_MENU_CASE_INFORMATION_TITLE
	
	new m_sizeof = GetCanOpenCases();

	new Float:lAllChance;
	new Float:kAllChance;

	new Float:lDropChance[24];
	new Float:kDropChance[24];

	for(new i; i < m_sizeof; i++)
	{
		lDropChance[i] = Cases[i][d_rarity];
		lAllChance += Cases[i][d_rarity];
	}
	for(new i; i < m_sizeof; i++)
	{
		kDropChance[i] = Keys[i][d_rarity];
		kAllChance += Keys[i][d_rarity];
	}
	new Float:NoDrop = 0.0;

	if(f_Player[id][isVip] > 0)
		NoDrop = 70.00;
	else
		NoDrop = 75.00;

	if(f_Player[id][Tolvajkesztyu])
		NoDrop -= 12.5;

	new Float:NoDropChance = (100.00 - NoDrop) / 100.00;

	menu_addtext2(menu, fmt("%L^n", id, "MOD_MENU_CASE_INFORMATION_CASE_KEY_STATS", Cases[caseid][cName], Case[id][caseid], (lDropChance[caseid]/(lAllChance/100)*NoDropChance), Keys[caseid][cName], Key[id][caseid], (kDropChance[caseid]/(lAllChance/100)*NoDropChance)))

	menu_additem(menu, fmt("%L^n", id, "MOD_MENU_CASE_INFORMATION_CASE_CONTENT"), "-1", ADMIN_ADMIN)

	if(Cases[caseid][CanDropAndOpenFrom] <= get_systime())
	{
		menu_additem(menu, fmt("%L", id, "MOD_MENU_CASE_INFORMATION_CASE_MARKET"), "2", 0)
		menu_additem(menu, fmt("%L^n", id, "MOD_MENU_CASE_INFORMATION_KEY_MARKET"), "3", 0)
		if(InventoryCanAdd(id, "", 0))
			menu_additem(menu, fmt("%L^n", id, "MOD_MENU_CASE_INFORMATION_CASE_OPEN"), "4", 0)
		else menu_additem(menu, fmt("\dNyitás (Tele az Inventoryd)"), "4", ADMIN_ADMIN)
	}
	else
	{
		menu_addtext2(menu, "\dEzt a ládát még nem lehet nyitni, sem kapni!")
		new formatted_time[33];
		format_time(formatted_time, charsmax(formatted_time), "%Y.%m.%d - %H:%M:%S", Cases[caseid][CanDropAndOpenFrom])
		menu_addtext2(menu, fmt("\dNyitható ekkortól: %s", formatted_time))
	}

	menu_setprop(menu, MPROP_NEXTNAME, fmt("%L", id, "GENERAL_MENU_NEXT"));
	menu_setprop(menu, MPROP_BACKNAME, fmt("%L", id, "GENERAL_MENU_BACK"));
	menu_setprop(menu, MPROP_EXITNAME, fmt("%L", id, "GENERAL_MENU_EXIT"));
	menu_display(id, menu, 0)
}
public openCaseReszletes_h(id, menu, item)
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
		case -1: ShowCaseContent(id, f_Player[id][SelectedCaseForOpen])
		case 2:
		{
			if(Case[id][f_Player[id][SelectedLKToPlace]] > 0)
			{
				f_Player[id][SelectedItemToPlace] = 2;
				f_Player[id][SelectedLKToPlace] = f_Player[id][SelectedCaseForOpen];
				f_Player[id][SelectedLKToPlaceDarab] = 0;
				openSellMenu(id)
			}
			else
			{
				sk_chat(id, "Nincs egy darabod sem ebből a ládából, mit akarsz kirakni rajta?")
				openCaseReszletes(id, f_Player[id][SelectedCaseForOpen])
				return;
			}
		}
		case 3:
		{
			if(Key[id][f_Player[id][SelectedLKToPlace]] > 0)
			{
				f_Player[id][SelectedItemToPlace] = 3;
				f_Player[id][SelectedLKToPlace] = f_Player[id][SelectedCaseForOpen];
				f_Player[id][SelectedLKToPlaceDarab] = 0;
				openSellMenu(id)
			}
			else
			{
				sk_chat(id, "Nincs egy darabod sem ebből a kulcsból, mit akarsz kirakni rajta?")
				openCaseReszletes(id, f_Player[id][SelectedCaseForOpen])
				return;
			}
		}
		case 4:
		{
			if(!InventoryCanAdd(id, "Tele a raktárad! Vegyél férőhelyet az áruházban!", 0))
				return;

			if(Case[id][f_Player[id][SelectedCaseForOpen]] >= 1 && Key[id][f_Player[id][SelectedCaseForOpen]] >= 1)
			{
				Case[id][f_Player[id][SelectedCaseForOpen]]--;
				Key[id][f_Player[id][SelectedCaseForOpen]]--;
				openCaseReszletes(id, f_Player[id][SelectedCaseForOpen]);
				openCase(id, f_Player[id][SelectedCaseForOpen]);
			}
			else
				client_print_color(id, print_team_default, "%s ^1Nincs Ládád vagy kulcsod.", CHATPREFIX); 
		}
	}
}
public ShowCaseContent(id, cKey)
{
	new String[100]
	formatex(String, charsmax(String), "HERBOYD2 | Láda tartalom");
	show_motd(id, fmt("http://herboyd2.hu/drop.php?case=%s Láda&cid=%i", Cases[cKey][cName], cKey), String);
	return PLUGIN_HANDLED;
}

public super_case_open(const case_array[][eDropChange], const case_size, &Float:OverAll, &Float:OpenChance, id)
{
	new Float:ChanceOld = 0.0;
	new Float:ChanceNow = 0.0;
	new OpenedWepID = -1;
	OverAll = 0.0;
	OpenChance = 0.0;
	
	for(new i;i < case_size; i++) {
		new item_id = case_array[i][cWeaponId];
		new Float:item_change_modifier = case_array[i][cDropChance];
		OverAll += 
			item_change_modifier *
			FegyverInfo[item_id][wBaseDropChance] *
			DropModifier[FegyverInfo[item_id][SelectedEnt]];
	}
	new Float:RandomNumber = random_float(0.00000001,OverAll);

	for(new i = 0; i < case_size; i++)
	{
		new item_id = case_array[i][cWeaponId];
		new Float:item_change_modifier = case_array[i][cDropChance];

		ChanceOld = ChanceNow;
		ChanceNow += 
			item_change_modifier *
			FegyverInfo[item_id][wBaseDropChance] *
			DropModifier[FegyverInfo[item_id][SelectedEnt]];

		if(ChanceOld < RandomNumber < ChanceNow)
		{
			OpenedWepID = item_id;
			OpenChance = ChanceNow-ChanceOld;
		}
	}
	return OpenedWepID;
}

public openCase(id, CaseKey)
{
	new bname[33], lname[50];
	copy(bname, charsmax(bname), sm_PlayerName[id])
	new Float:OverAll = 0.0;
	new RandomizeBroke = random_num(17, 44)
	if(random(999999) == 69)
		RandomizeBroke = 101;
	new OpenedWepID = 0;
	new Float:OpenedWepChance = 0.0;
	new Float:StatTrakChance = random_float(0.0, 100.0);
	new st = 0;
	if(StatTrakChance < 1.0)
		st = 1;

	copy(lname, charsmax(lname), fmt("%s Láda", Cases[CaseKey][cName]))

	switch(CaseKey)
	{
		case 0 : OpenedWepID = super_case_open(case_S0_Aether, 			m_case_S0_Aether_size, 		     OverAll, OpenedWepChance, id);
		case 1 : OpenedWepID = super_case_open(case_S0_Valkyrie, 		m_case_S0_Valkyrie_size, 	     OverAll, OpenedWepChance, id);
		case 2 : OpenedWepID = super_case_open(case_S0_Eclipse, 		m_case_S0_Eclipse_size, 	     OverAll, OpenedWepChance, id);
		case 3 : OpenedWepID = super_case_open(case_S0_Titan, 			m_case_S0_Titan_size, 		     OverAll, OpenedWepChance, id);
		case 4 : OpenedWepID = super_case_open(case_S0_Phantom, 		m_case_S0_Phantom_size, 	     OverAll, OpenedWepChance, id);
		case 5 : OpenedWepID = super_case_open(case_S1_Nemesis, 		m_case_S1_Nemesis_size, 	     OverAll, OpenedWepChance, id);
		case 6 : OpenedWepID = super_case_open(case_S2_Onyx, 			m_case_S2_Onyx_size, 		     OverAll, OpenedWepChance, id);
		case 7 : OpenedWepID = super_case_open(case_S3_Zephyr, 			m_case_S3_Zephyr_size, 		     OverAll, OpenedWepChance, id);
		case 8 : OpenedWepID = super_case_open(case_S4_Inferno, 		m_case_S4_Inferno_size, 	     OverAll, OpenedWepChance, id);
		case 9 : OpenedWepID = super_case_open(case_S5_Specter, 		m_case_S5_Specter_size, 	     OverAll, OpenedWepChance, id);
		case 10: OpenedWepID = super_case_open(case_S6_Obsidian, 		m_case_S6_Obsidian_size, 	     OverAll, OpenedWepChance, id);
		case 11: OpenedWepID = super_case_open(case_S7_Ragnarok, 		m_case_S7_Ragnarok_size, 	     OverAll, OpenedWepChance, id);
		case 12: OpenedWepID = super_case_open(case_S8_Seraph, 			m_case_S8_Seraph_size, 		     OverAll, OpenedWepChance, id);
		case 13: OpenedWepID = super_case_open(case_S9_Revenant, 		m_case_S9_Revenant_size, 	     OverAll, OpenedWepChance, id);
		case 14: OpenedWepID = super_case_open(case_S10_Chronos, 		m_case_S10_Chronos_size, 	     OverAll, OpenedWepChance, id);
		case 15: OpenedWepID = super_case_open(case_S11_Tempest, 		m_case_S11_Tempest_size, 	     OverAll, OpenedWepChance, id);
		case 16: OpenedWepID = super_case_open(case_S12_Mirage, 		m_case_S12_Mirage_size, 	     OverAll, OpenedWepChance, id);
	}
	
	AddToInv(id, 1, f_Player[id][a_UserId], OpenedWepID, RandomizeBroke, st, 0, 0, "", 1, lname, bname, f_Player[id][a_UserId], -1)
	
	if(st == 1 || FegyverInfo[OpenedWepID][EntName] == CSW_KNIFE)
	{
		client_print_color(0, print_team_default, "^4%s ^3%s^1 nyitott egy ^3%s%s^1 skint ^4%s^1 fegyverre, ebből: ^4%s Láda^1. ^3(^1Esélye: ^4%.3f%%^3)", CHATPREFIX, sm_PlayerName[id], st ? "StatTrak*" : "", FegyverInfo[OpenedWepID][wname], FegyverInfo[OpenedWepID][ChatWeapon], Cases[CaseKey][cName], (OpenedWepChance/(OverAll/100.0)));
		client_cmd(0, "spk Herboynew/open2")
	}
	else
	{
		client_print_color(id, print_team_default, "^4%s^1 Nyitottál egy ^3%s%s^1 skint ^4%s^1 fegyverre, ebből: ^4%s Láda^1. ^3(^1Esélye: ^4%.3f%%^3)", CHATPREFIX, st ? "StatTrak*" : "", FegyverInfo[OpenedWepID][wname], FegyverInfo[OpenedWepID][ChatWeapon], Cases[CaseKey][cName], (OpenedWepChance/(OverAll/100.0)));
	}	 
} 
public openSettings(id, page, pInfo)
{
	new MenuString[121];
	format(MenuString, charsmax(MenuString), "\d%s \r[ \wBeállítások \r]", MENUPREFIX);//MOD_MENU_PROFILE_INFO_SETTINGS_TITLE

	new menu = menu_create(MenuString, "SettingsPost");
	if(pInfo)
	{
		new regdate[33], fVipTime[100], fPlayTime[66]
		sk_get_RegisterDate(id, regdate, 32);
		easy_time_length(id, sk_get_playtime(id), timeunit_seconds, fPlayTime, charsmax(fPlayTime));
		new CreditsSize = ArraySize(g_Credit[id]);
		new BuySize = ArraySize(g_Buy[id]);

		menu_additem(menu, fmt("%L",   id, "MOD_MENU_PROFILE_INFO_SETTINGS_CREDITS", CreditsSize), "7")
		menu_additem(menu, fmt("%L^n", id, "MOD_MENU_PROFILE_INFO_SETTINGS_PURCHASES", BuySize), "8")

		menu_addtext2(menu, fmt("%L \r%s\d(#%i)", id, "MOD_MENU_PROFILE_INFO_SETTINGS_USERNAME", sm_PlayerName[id], sk_get_accountid(id)))
		menu_addtext2(menu, fmt("%L \r%s",        id, "MOD_MENU_PROFILE_INFO_SETTINGS_REGISTERED", regdate))
		menu_addtext2(menu, fmt("%L \r%s",        id, "MOD_MENU_PROFILE_INFO_SETTINGS_PLAYTIME", fPlayTime))

		switch(f_Player[id][isVip])
		{
			case 0: menu_addtext2(menu, fmt("%L", id, "MOD_MENU_PROFILE_INFO_SETTINGS_VIP_TYPE_NONE"))
			case 1: menu_addtext2(menu, fmt("%L", id, "MOD_MENU_PROFILE_INFO_SETTINGS_VIP_TYPE_PREMIUM"))
			case 2: menu_addtext2(menu, fmt("%L", id, "MOD_MENU_PROFILE_INFO_SETTINGS_VIP_TYPE_PREMIUM"))
			case 3: menu_addtext2(menu, fmt("%L", id, "MOD_MENU_PROFILE_INFO_SETTINGS_VIP_TYPE_PREMIUM_PLUS"))
		}
		if(f_Player[id][VipTime] > 0)
		{
			new vLejar[33];
			easy_time_length(id, f_Player[id][VipTime]-get_systime(), timeunit_seconds, fVipTime, charsmax(fVipTime));
			format_time(vLejar, charsmax(vLejar), "%Y.%m.%d - %H:%M:%S", f_Player[id][VipTime])
			menu_addtext2(menu, fmt("%L^n", id, "MOD_MENU_PROFILE_INFO_SETTINGS_VIP_EXPIRES_AT_DATE", fVipTime, vLejar))
		}
		else if(f_Player[id][VipTime] == -1)
			menu_addtext2(menu, fmt("%L^n", id, "MOD_MENU_PROFILE_INFO_SETTINGS_VIP_EXPIRES_AT_NEVER"))
		else if(f_Player[id][VipTime] == 0)
			menu_addtext2(menu, fmt("%L^n", id, "MOD_MENU_PROFILE_INFO_SETTINGS_VIP_EXPIRES_AT_NONE"))

	}
	else
	{
		new currlang[3];
		get_user_info(id, "lang", currlang, charsmax(currlang));
		strtoupper(currlang);
		menu_additem(menu, "Profil Információk", "13")
		menu_additem(menu, fmt("%L [\r%s\w]", id, "MOD_MENU_PROFILE_INFO_SETTINGS_LANGUAGE", currlang), "9");

		menu_additem(menu, fmt("Régi Stilusú fegyvermenü: %s", f_Player[id][OldStyleWeaponMenu] == 1 ? "\yBekapcsolva" : "\dKikapcsolva"), "10")
		menu_additem(menu, fmt("Pontosság javítás: %s", f_Player[id][RecoilControl] == 0 ? "\yBekapcsolva" : "\dKikapcsolva"), "11")
		menu_additem(menu, fmt("Újraélesztési hullajelző: %s", f_Player[id][ReviveSprite] == 0 ? "\yBekapcsolva" : "\dKikapcsolva"), "12")
		menu_additem(menu, fmt("Quake Hangok: %s", f_Player[id][QuakeS] == 0 ? "\yBekapcsolva" : "\dKikapcsolva"), "5")
		menu_additem(menu, fmt("Néző lista: %s", f_Player[id][SpecL] == 0 ? "\yBekapcsolva" : "\dKikapcsolva"), "6")
		menu_additem(menu, fmt("%L %L", id, "MOD_MENU_PROFILE_INFO_SETTINGS_WEAPON_SKINS", id, f_Player[id][Skins] == 1 ? "MOD_MENU_PROFILE_INFO_SETTINGS_ENABLED" : "MOD_MENU_PROFILE_INFO_SETTINGS_DISABLED"), "1")
		menu_additem(menu, fmt("%L %L", id, "MOD_MENU_PROFILE_INFO_SETTINGS_HUD", id, f_Player[id][Huds] == 0 ? "MOD_MENU_PROFILE_INFO_SETTINGS_ENABLED" : "MOD_MENU_PROFILE_INFO_SETTINGS_DISABLED"), "2")
		menu_additem(menu, fmt("%L %L", id, "MOD_MENU_PROFILE_INFO_SETTINGS_WEAPON_HUD", id, f_Player[id][WeaponHud] == 0 ? "MOD_MENU_PROFILE_INFO_SETTINGS_ENABLED" : "MOD_MENU_PROFILE_INFO_SETTINGS_DISABLED"), "3")
		menu_additem(menu, fmt("%L %L", id, "MOD_MENU_PROFILE_INFO_SETTINGS_SCREEN_EFFECT", id, f_Player[id][ScreenEffect] == 0 ? "MOD_MENU_PROFILE_INFO_SETTINGS_ENABLED" : "MOD_MENU_PROFILE_INFO_SETTINGS_DISABLED"), "4")
	}

	menu_setprop(menu, MPROP_NEXTNAME, fmt("%L", id, "GENERAL_MENU_NEXT"));
	menu_setprop(menu, MPROP_BACKNAME, fmt("%L", id, "GENERAL_MENU_BACK"));
	menu_setprop(menu, MPROP_EXITNAME, fmt("%L", id, "GENERAL_MENU_EXIT"));
	menu_display(id, menu, page)
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
		case 1: { f_Player[id][Skins] = !f_Player[id][Skins]; openSettings(id, 0, 0); }
		case 2: { f_Player[id][Huds] = !f_Player[id][Huds]; openSettings(id, 0, 0); }
		case 3: { f_Player[id][WeaponHud] = !f_Player[id][WeaponHud]; openSettings(id, 0, 0); }
		case 4: { f_Player[id][ScreenEffect] = !f_Player[id][ScreenEffect]; openSettings(id, 0, 0); }
		case 5: { f_Player[id][QuakeS] = !f_Player[id][QuakeS]; openSettings(id, 0, 0); }
		case 6: { f_Player[id][SpecL] = !f_Player[id][SpecL]; openSettings(id, 0, 0); }
		case 7: openMyCredits(id)
		case 8: openMyBuyt(id)
		case 9: { user_next_lang(id); openSettings(id, 0, 0); }
		case 10: { f_Player[id][OldStyleWeaponMenu] = !f_Player[id][OldStyleWeaponMenu]; openSettings(id, 0, 0); }
		case 11: { f_Player[id][RecoilControl] = !f_Player[id][RecoilControl]; openSettings(id, 0, 0); }
		case 12: { f_Player[id][ReviveSprite] = !f_Player[id][ReviveSprite]; openSettings(id, 0, 0); }
		case 13: openSettings(id, 0, 1)
	}
		
}
public openMyCredits(id)
{
	new szMenu[256]
	new menu = menu_create(fmt("\d%s \r[ \wJóváírásaim\r ]", MENUPREFIX), "openMyCredits_h");//MOD_MENU_PP_CREDITS_TITLE
	new CreditsSize = ArraySize(g_Credit[id]);
	new Credit[CreditSys]
	if(CreditsSize == 0)
	{
		menu_addtext2(menu, fmt("%L", id, "MOD_MENU_PP_CREDITS_NO_CREDIT"))
	}
	else
	{
		for(new i = 0; i < CreditsSize;i++)
		{
			new len;
			ArrayGetArray(g_Credit[id], i, Credit);
			if(Credit[CreditBackAdded] == 2)
				len += formatex(szMenu[len], charsmax(szMenu) - len, "%L", id, "MOD_MENU_PP_CREDITS_REFUND", Credit[CreditAmount], Credit[CreditTime]);
			else if(Credit[CreditBackAdded] == 5)
				len += formatex(szMenu[len], charsmax(szMenu) - len, "%L", id, "MOD_MENU_PP_CREDITS_PAYPAL", Credit[CreditAmount], Credit[CreditTime]);
			else
				len += formatex(szMenu[len], charsmax(szMenu) - len, "%L", id, "MOD_MENU_PP_CREDITS_CREDITED", Credit[CreditAmount], Credit[CreditTime]);
			menu_addtext2(menu, szMenu);
		}
	}
	menu_setprop(menu, MPROP_NEXTNAME, fmt("%L", id, "GENERAL_MENU_NEXT"));
	menu_setprop(menu, MPROP_BACKNAME, fmt("%L", id, "GENERAL_MENU_BACK"));
	menu_setprop(menu, MPROP_EXITNAME, fmt("%L", id, "GENERAL_MENU_EXIT"));
	menu_setprop(menu, MPROP_PERPAGE, 5);
	menu_display(id, menu, 0);

	return PLUGIN_HANDLED;
}
public openMyBuyt(id)
{
	new szMenu[256]
	new menu = menu_create(fmt("\d%s \r[ \wVásárlásaim\r ]", MENUPREFIX), "openMyCredits_h");//MOD_MENU_PP_PURCHASE_TITLE
	new BuySize = ArraySize(g_Buy[id]);
	new Buy[BuySys]
	if(BuySize == 0)
	{
		menu_addtext2(menu, fmt("%L", id, "MOD_MENU_PP_PURCHASE_NO_PURCHASE"))
	}
	else
	{
		for(new i = 0; i < BuySize;i++)
		{
			new len;
			ArrayGetArray(g_Buy[id], i, Buy);
			/*													 MOD_MENU_PP_PURCHASE_ITEM*/
			if(Buy[BuyCost] > 0)
				len += formatex(szMenu[len], charsmax(szMenu) - len, "\w%s \r~ \d(%s) \r[%i PP]", Buy[BuyName], Buy[BuyTime], Buy[BuyCost]);
			else
				len += formatex(szMenu[len], charsmax(szMenu) - len, "\w%s \r~ \d(%s) \r[%3.2f$]", Buy[BuyName], Buy[BuyTime], Buy[BuyDollar]);
			menu_addtext2(menu, szMenu);
		}
	}
	menu_setprop(menu, MPROP_NEXTNAME, fmt("%L", id, "GENERAL_MENU_NEXT"));
	menu_setprop(menu, MPROP_BACKNAME, fmt("%L", id, "GENERAL_MENU_BACK"));
	menu_setprop(menu, MPROP_EXITNAME, fmt("%L", id, "GENERAL_MENU_EXIT"));
	menu_setprop(menu, MPROP_PERPAGE, 5);
	menu_display(id, menu, 0);

	return PLUGIN_HANDLED;
}
public openMyCredits_h(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return;
	}

	new data[9], szName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
	/* new key = str_to_num(data); */
} 
public openMarketMenu(id)
{
	new Menu[512], MenuString[128], MenuKey
	format(MenuString, 127, "\d%s \r[ \wPiac \d/\w Küldés \r]^n^n", MENUPREFIX)//MOD_MENU_MARKET_TRADE_CENTER_TITLE
	add(Menu, 511, MenuString);
	
	format(MenuString, 127, fmt("\r1. %L^n", id, "MOD_MENU_MARKET_TRADE_CENTER_SELL"))
	add(Menu, 511, MenuString);
	format(MenuString, 127, fmt("\r2. %L^n^n", id, "MOD_MENU_MARKET_TRADE_CENTER_BUY"))
	add(Menu, 511, MenuString);
	format(MenuString, 127, fmt("\r3. %L^n", id, "MOD_MENU_MARKET_TRADE_CENTER_SEND_SKIN"))
	add(Menu, 511, MenuString);
	format(MenuString, 127, fmt("\r4. \rItem\w küldés^n"))
	add(Menu, 511, MenuString);

	format(MenuString, 127, fmt("^n\r0. \w%L", id, "GENERAL_MENU_EXIT"));
	add(Menu, 511, MenuString); 
	
	MenuKey = (1<<0 | 1<<1 | 1<<2 | 1<<3 | 1<<4 | 1<<5 | 1<<6 | 1<<7 | 1<<8 | 1<<9);
	show_menu(id, MenuKey, Menu, -1, "MARKETMENU");
	return PLUGIN_CONTINUE
}

public openMarketSwitch_h(id, MenuKey)
{
	MenuKey++;
	switch(MenuKey)
	{
		case 1: openSellMenu(id)
		case 2: openBuyMenu(id);
		case 3:
		{
			f_Player[id][SwitchingOnMarket] = 0
			f_Player[id][SendType] = 3
			openPlayerChooser(id);
		}
		case 4: 
		{
			openSendItemMenu(id)
		}
		default:{
			show_menu(id, 0, "^n", 1);
			return
		}
	}
}
public openSendItemMenu(id)
{
	new menu = menu_create(fmt("\d%s \r[ \wItem küldés \r]", MENUPREFIX), "openSendItem_h");

	menu_additem(menu, fmt("%L", id, "MOD_MENU_MARKET_TRADE_CENTER_SEND_CASE"), "1")
	menu_additem(menu, fmt("%L", id, "MOD_MENU_MARKET_TRADE_CENTER_SEND_KEY"), "2")
	menu_additem(menu, fmt("%L", id, "MOD_MENU_MARKET_TRADE_CENTER_SEND_DOLLAR", f_Player[id][Dollar]), "3")
	menu_additem(menu, fmt("%L", id, "MOD_MENU_MARKET_TRADE_CENTER_SEND_NAME_TAG", f_Player[id][NametagTool]), "4")
	menu_additem(menu, fmt("%L", id, "MOD_MENU_MARKET_TRADE_CENTER_SEND_STAT_TRAK_TOOL", f_Player[id][StatTrakTool]), "5")
	menu_additem(menu, fmt("%L", id, "MOD_MENU_MARKET_TRADE_CENTER_SEND_WEAPON_FRAGMENT", f_Player[id][Toredek]), "6")
	

	menu_setprop(menu, MPROP_NEXTNAME, fmt("%L", id, "GENERAL_MENU_NEXT"));
	menu_setprop(menu, MPROP_BACKNAME, fmt("%L", id, "GENERAL_MENU_BACK"));
	menu_setprop(menu, MPROP_EXITNAME, fmt("%L", id, "GENERAL_MENU_EXIT"));
	menu_display(id, menu, 0);

	return PLUGIN_HANDLED;
}
public openSendItem_h(id, menu, item)
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
			f_Player[id][SendType] = 4
			openSelector(id, 1);
		}
		case 2: 
		{
			f_Player[id][SendType] = 5
			openSelector(id, 2);
		}
		case 3:
		{
			f_Player[id][SendType] = 6
			openPlayerChooser(id);
		}
		case 4:
		{
			f_Player[id][SendType] = 7
			openPlayerChooser(id);
		}
		case 5:
		{
			f_Player[id][SendType] = 8
			openPlayerChooser(id);
		}
		case 6:
		{
			f_Player[id][SendType] = 9
			openPlayerChooser(id);
		}
	}

}
public openSelector(id, MenuValasztott)
{
	new String[121];
	format(String, charsmax(String), "\d%s \r[ \wLáda / Kulcs küldés\r ]", MENUPREFIX);//MOD_MENU_CASE_KEY_SENDING_TITLE
	new menu = menu_create(String, "openSelector_h");
	new ladasos = GetCanOpenCases();

	switch(MenuValasztott)
	{
		case 1: 
		{
			for(new i;i < ladasos; i++)
			{
				new Sor[6]; num_to_str(i, Sor, 5);
				formatex(String, charsmax(String), "%s %L \r[\w%i\y %L\r]", Cases[i][cName], id, "GENERAL_CRATE", Case[id][i], id, "GENERAL_UNIT_PIECE");
				menu_additem(menu, String, Sor);
			}
		}
		case 2:
		{
			for(new i;i < ladasos; i++)
			{
				new Sor[6]; num_to_str(i, Sor, 5);
				formatex(String, charsmax(String), "%s %L \r[\w%i\y %L\r]", Keys[i][cName], id, "GENERAL_KEY", Key[id][i], id, "GENERAL_UNIT_PIECE");
				menu_additem(menu, String, Sor);
			}
		}
	}	

	menu_setprop(menu, MPROP_NEXTNAME, fmt("%L", id, "GENERAL_MENU_NEXT"));
	menu_setprop(menu, MPROP_BACKNAME, fmt("%L", id, "GENERAL_MENU_BACK"));
	menu_setprop(menu, MPROP_EXITNAME, fmt("%L", id, "GENERAL_MENU_EXIT"));
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

	f_Player[id][CaseOrKeySelected] = key;
	openPlayerChooser(id);

}

public openPlayerChooser(id) {
	new szMenu[121], players[32], pnum, iName[32], szTempid[10]
	get_players(players, pnum, "c")

	formatex(szMenu, charsmax(szMenu), "\d%s \r[ \wJátákos kiválasztás\r ]", MENUPREFIX)//MOD_MENU_SELECT_PLAYER_TITLE
	new menu = menu_create(szMenu, "hPlayerChooser");

	for(new i; i<pnum; i++)
	{
		if(!sk_get_logged(players[i]))
			continue;
		
		get_user_name(players[i], iName, charsmax(iName))
		num_to_str(players[i], szTempid, charsmax(szTempid))

		if(f_Player[id][SendType] == 3 && InventoryCanAdd(players[i], "", 0))
			menu_additem(menu, iName, szTempid)
		else if(f_Player[id][SendType] == 3 && !InventoryCanAdd(players[i], "", 0))
			menu_additem(menu, fmt("\d%s (Raktár TELE!)", iName), szTempid, ADMIN_ADMIN)
		else menu_additem(menu, iName, szTempid)
	}

	menu_setprop(menu, MPROP_NEXTNAME, fmt("%L", id, "GENERAL_MENU_NEXT"));
	menu_setprop(menu, MPROP_BACKNAME, fmt("%L", id, "GENERAL_MENU_BACK"));
	menu_setprop(menu, MPROP_EXITNAME, fmt("%L", id, "GENERAL_MENU_EXIT"));
	menu_display(id, menu, 0)
}
public hPlayerChooser(id, menu, item)
{
	if(item == MENU_EXIT) {
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	new data[6], szName[64], access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
	f_Player[id][SendTemp] = str_to_num(data);
	
	if(id == f_Player[id][SendTemp]) {
		client_print_color(id, print_team_default, "^4%s^1 Magadnak nem küldhetsz semmit!", CHATPREFIX)
		menu_destroy(menu);
		return PLUGIN_HANDLED
	}
	switch(f_Player[id][SendType])
	{
		case 3:
		{
			f_Player[id][openSelectItemRow] = 3;
			openInventorySwitch(id)
		}
		case 4..9:
		{
			client_cmd(id, "messagemode Kuldes_Mennyisege")
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
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

	if(f_Player[id][SendType] == 4 && Case[id][f_Player[id][CaseOrKeySelected]] >= str_to_num(Data))
	{
		Case[f_Player[id][SendTemp]][f_Player[id][CaseOrKeySelected]] += str_to_num(Data);
		Case[id][f_Player[id][CaseOrKeySelected]] -= str_to_num(Data);
		client_print_color(0, print_team_default, "^4%s ^4%s^1 küldött ^3%i darab ^4%s^1-t ^3%s^1 játékosnak.", CHATPREFIX, sm_PlayerName[id], str_to_num(Data), Cases[f_Player[id][CaseOrKeySelected]][cName],sm_PlayerName[f_Player[id][SendTemp]]);
		format(LogMSG,charsmax(LogMSG),"UserId: %i | KName: %s | Targy: %d - %iDB | Date: %s | FoId: %i | FoName: %s", f_Player[id][a_UserId], sm_PlayerName[id], Cases[f_Player[id][CaseOrKeySelected]][cName], str_to_num(Data), sztime, f_Player[f_Player[id][SendTemp]][a_UserId], sm_PlayerName[f_Player[id][SendTemp]]);
		f_Player[id][SendType] = 0;
	}
	else if(f_Player[id][SendType] == 5 && Key[id][f_Player[id][CaseOrKeySelected]] >= str_to_num(Data))
	{
		Key[f_Player[id][SendTemp]][f_Player[id][CaseOrKeySelected]] += str_to_num(Data);
		Key[id][f_Player[id][CaseOrKeySelected]] -= str_to_num(Data);
		client_print_color(0, print_team_default, "^4%s ^4%s^1 küldött ^3%i darab ^4%s^1-t ^3%s^1 játékosnak.", CHATPREFIX, sm_PlayerName[id], str_to_num(Data), Keys[f_Player[id][CaseOrKeySelected]][cName], sm_PlayerName[f_Player[id][SendTemp]]);
		format(LogMSG,charsmax(LogMSG),"UserId: %i | KName: %s | Targy: %d - %iDB | Date: %s | FoId: %i | FoName: %s", f_Player[id][a_UserId], sm_PlayerName[id], Keys[f_Player[id][CaseOrKeySelected]][cName], str_to_num(Data), sztime, f_Player[f_Player[id][SendTemp]][a_UserId], sm_PlayerName[f_Player[id][SendTemp]]);
	}
	else if(f_Player[id][SendType] == 6 && f_Player[id][Dollar] >= str_to_num(Data))
	{
		f_Player[f_Player[id][SendTemp]][Dollar] += str_to_num(Data);
		f_Player[id][Dollar] -= str_to_num(Data);
		client_print_color(0, print_team_default, "^4%s ^4%s^1 küldött ^3%d ^4dollárt^1-t ^3%s^1 játékosnak.", CHATPREFIX, sm_PlayerName[id], str_to_num(Data), sm_PlayerName[f_Player[id][SendTemp]]);
		format(LogMSG,charsmax(LogMSG),"UserId: %i | KName: %s | Targy: %d $ | Date: %s | FoId: %i | FoName: %s", f_Player[id][a_UserId], sm_PlayerName[id], str_to_num(Data), sztime, f_Player[f_Player[id][SendTemp]][a_UserId], sm_PlayerName[f_Player[id][SendTemp]]);

		f_Player[id][SendType] = 0;
	}
	else if(f_Player[id][SendType] == 7 && f_Player[id][NametagTool] >= str_to_num(Data))
	{
		f_Player[f_Player[id][SendTemp]][NametagTool] += str_to_num(Data);
		f_Player[id][NametagTool] -= str_to_num(Data);
		client_print_color(0, print_team_default, "^4%s ^4%s^1 küldött ^3%d ^4Névcédulá^1-t ^3%s^1 játékosnak.", CHATPREFIX, sm_PlayerName[id], str_to_num(Data), sm_PlayerName[f_Player[id][SendTemp]]);
		format(LogMSG,charsmax(LogMSG),"UserId: %i | KName: %s | Targy: %d Nevcedula | Date: %s | FoId: %i | FoName: %s", f_Player[id][a_UserId], sm_PlayerName[id], str_to_num(Data), sztime, f_Player[f_Player[id][SendTemp]][a_UserId], sm_PlayerName[f_Player[id][SendTemp]]);
		f_Player[id][SendType] = 0;
	}
	else if(f_Player[id][SendType] == 8 && f_Player[id][StatTrakTool] >= str_to_num(Data))
	{
		f_Player[f_Player[id][SendTemp]][StatTrakTool] += str_to_num(Data);
		f_Player[id][StatTrakTool] -= str_to_num(Data);
		client_print_color(0, print_team_default, "^4%s ^4%s^1 küldött ^3%d ^4StatTrak* Tool^1-t ^3%s^1 játékosnak.", CHATPREFIX, sm_PlayerName[id], str_to_num(Data),sm_PlayerName[f_Player[id][SendTemp]]);
		format(LogMSG,charsmax(LogMSG),"UserId: %i | KName: %s | Targy: %d StatTrak* Tool | Date: %s | FoId: %i | FoName: %s", f_Player[id][a_UserId], sm_PlayerName[id], str_to_num(Data), sztime, f_Player[f_Player[id][SendTemp]][a_UserId], sm_PlayerName[f_Player[id][SendTemp]]);
		f_Player[id][SendType] = 0;
	}
	else if(f_Player[id][SendType] == 9 && f_Player[id][Toredek] >= str_to_num(Data))
	{
		f_Player[f_Player[id][SendTemp]][Toredek] += str_to_num(Data);
		f_Player[id][Toredek] -= str_to_num(Data);
		client_print_color(0, print_team_default, "^4%s ^4%s^1 küldött ^3%d ^4Fegyver Töredék^1-et ^3%s^1 játékosnak.", CHATPREFIX, sm_PlayerName[id], str_to_num(Data), sm_PlayerName[f_Player[id][SendTemp]]);
		format(LogMSG,charsmax(LogMSG),"UserId: %i | KName: %s | Targy: %d Fegyver Töredék | Date: %s | FoId: %i | FoName: %s", f_Player[id][a_UserId], sm_PlayerName[id], str_to_num(Data), sztime, f_Player[f_Player[id][SendTemp]][a_UserId], sm_PlayerName[f_Player[id][SendTemp]]);
		f_Player[id][SendType] = 0;
	}
	return PLUGIN_HANDLED;
}
public openSellMenu(id)
{

	new Market[MarketSystem], maxkihelyezes = 0, maximumplace = 0;
	new MarketSizeof = ArraySize(g_Market);

	if(f_Player[id][isVip] == 1)
		maximumplace = 6;
	else
		maximumplace = 3;

	for(new i = 0; i < MarketSizeof;i++)
	{
		ArrayGetArray(g_Market, i, Market);

		if(Market[m_userid] == sk_get_accountid(id) && Market[m_cost] > 0)
		{
			maxkihelyezes++;
			continue;
		}
	}

	new String[121];
	format(String, charsmax(String), "%s \r[ \wEladás \r]^n\wKirakott itemek: \r%i\d/\r%i", MENUPREFIX, maxkihelyezes, maximumplace);//MOD_MENU_MARKET_SALE_TITLE
	new menu = menu_create(String, "openSellMenu_h");
	if(maxkihelyezes < maximumplace)
	{
		if(f_Player[id][SelectedItemToPlace] == -1)
			menu_additem(menu, "Válassz ki, hogy mit szeretnél eladni!", "-1")
		else if(f_Player[id][SelectedItemToPlace] == 1)
		{
			new ArrId = f_Player[id][SelectedInvArryKey];
			menu_additem(menu, fmt("%L: \r%s%s\w[\y#%i\w]", id, "GENERAL_WEAPON", FegyverInfo[gInventory[id][ArrId][w_id]][MenuWeapon], FegyverInfo[gInventory[id][ArrId][w_id]][wname], gInventory[id][ArrId][sqlid]), "-1")
		
			if(gInventory[id][ArrId][isNameTaged])
				menu_addtext2(menu, fmt("\w%L: \y%s", id, "GENERAL_NAME_TAG", gInventory[id][ArrId][Nametag]))
			else
				menu_addtext2(menu, fmt("\w%L: \dNincs", id, "GENERAL_NAME_TAG"))

			new String[20]
			if(gInventory[id][ArrId][Allapot] <= 4)
				copy(String, charsmax(String), fmt("\d(%L)", id, "GENERAL_BROKEN"))
			else copy(String, charsmax(String), "")

			if(gInventory[id][ArrId][isStatTraked])
				menu_addtext2(menu, fmt("\wStatTrak: \r%L \d| \w%L: \r%i^n\w%L: \r%s^n", id, "GENERAL_UNIT_AVAILABE", id, "GENERAL_KILLS", gInventory[id][ArrId][StatTrakKills], id, "GENERAL_CONDITION", gInventory[id][ArrId][Allapot] == 101 ? fmt("\y%L", id, "GENERAL_UNBRAKEABLE") : (fmt("%i%% %s", gInventory[id][ArrId][Allapot], String))));
			else
			{
				menu_addtext2(menu, fmt("\wStatTrak: \d%L^n\w%L: \r%s^n", id, "GENERAL_UNIT_NONE", id, "GENERAL_CONDITION", gInventory[id][ArrId][Allapot] == 101 ? fmt("\y%L", id, "GENERAL_UNBRAKEABLE") : (fmt("%i%% %s", gInventory[id][ArrId][Allapot], String))));
			}
		}
		else if(f_Player[id][SelectedItemToPlace] == 2)
		{
			menu_additem(menu, fmt("%L: \r%s", id, "GENERAL_CRATE", Cases[f_Player[id][SelectedLKToPlace]][cName]), "-1")
			if(f_Player[id][SelectedLKToPlaceDarab] != 0)
				menu_additem(menu, fmt("%L: \y%i", id, "GENERAL_UNIT_PIECE_F", f_Player[id][SelectedLKToPlaceDarab]), "4")
			else
				menu_additem(menu, fmt("%L: \d%L", id, "GENERAL_UNIT_PIECE_F", id, "GENERAL_NOT_GIVEN"), "4")
		}	
		else if(f_Player[id][SelectedItemToPlace] == 3)
		{
			menu_additem(menu, fmt("%L: \r%s", id, "GENERAL_KEY", Keys[f_Player[id][SelectedLKToPlace]][cName]), "-1")
			if(f_Player[id][SelectedLKToPlaceDarab] != 0)
				menu_additem(menu, fmt("%L: \y%i", id, "GENERAL_UNIT_PIECE_F", f_Player[id][SelectedLKToPlaceDarab]), "3")
			else
				menu_additem(menu, fmt("%L: \d%L", id, "GENERAL_UNIT_PIECE_F", id, "GENERAL_NOT_GIVEN"), "3")
		}
		else menu_additem(menu, fmt("%L", id, "GENERAL_REPORT_TO_DEVELOPER"), "-1")

		if(f_Player[id][SetCost] > 0.9)
			menu_additem(menu, fmt("%L \r%3.2f$^n", id, "MOD_MENU_MARKET_SALE_PRICE", f_Player[id][SetCost]), "1")
		else
			menu_additem(menu, fmt("%L \d%L^n", id, "MOD_MENU_MARKET_SALE_PRICE", id, "GENERAL_NOT_GIVEN"), "1")

		if(f_Player[id][SelectedItemToPlace] > 0)
		{
			if(f_Player[id][SetCost] == 0)
				menu_addtext2(menu, fmt("%L", id, "MOD_MENU_MARKET_SALE_ENTER_PRICE"))
			else
				menu_additem(menu, fmt("%L", id, "MOD_MENU_MARKET_SALE_LIST_ON_MARKET"), "2")
		}
	}
	else
	{
		menu_addtext2(menu, fmt("%L", id, "MOD_MENU_MARKET_SALE_MAX_REACHED"))
		menu_addtext2(menu, fmt("%L \r%i/%i", id, "MOD_MENU_MARKET_SALE_MAX_ITEMS", maxkihelyezes, maximumplace))
		menu_addtext2(menu, fmt("%L", id, "MOD_MENU_MARKET_SALE_REMOVE_ITEM_PROMPT"))
		menu_addtext2(menu, fmt("%L", id, "MOD_MENU_MARKET_SALE_WITHDRAW_ITEM"))
	}
	
	menu_setprop(menu, MPROP_NEXTNAME, fmt("%L", id, "GENERAL_MENU_NEXT"));
	menu_setprop(menu, MPROP_BACKNAME, fmt("%L", id, "GENERAL_MENU_BACK"));
	menu_setprop(menu, MPROP_EXITNAME, fmt("%L", id, "GENERAL_MENU_EXIT"));
	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}
public cmdDarabCase(id)
{
	sk_chat(id, "Ha az össezes ládád akarod eladni, pl 2, akkor csak 1-et tudsz kirakni! Azaz 1-el kevesebbet írj be!")
	new iErtek, iAdatok[32]
	read_args(iAdatok, charsmax(iAdatok))
	remove_quotes(iAdatok)
	
	iErtek = str_to_num(iAdatok)
	
	if(iErtek < 1)
	{
		sk_chat(id, "A darabnak 0 felett kell lennie!")
		openSellMenu(id)
		return PLUGIN_HANDLED;
	}
	if(Case[id][f_Player[id][SelectedLKToPlace]] <= iErtek)
	{
		sk_chat(id, "Nincs ennyi ládád! Adj meg kevesebbet!")
		openSellMenu(id)
		return PLUGIN_HANDLED;
	}
	else
	{
		f_Player[id][SelectedLKToPlaceDarab] = iErtek;
		openSellMenu(id)
		return PLUGIN_HANDLED;
	}
}
public cmdDarabKeys(id)
{
	sk_chat(id, "Ha az össezes kulcsod akarod eladni, pl 2, akkor csak 1-et tudsz kirakni! Azaz 1-el kevesebbet írj be!")
	new iErtek, iAdatok[32]
	read_args(iAdatok, charsmax(iAdatok))
	remove_quotes(iAdatok)
	
	iErtek = str_to_num(iAdatok)
	if(iErtek < 1)
	{
		sk_chat(id, "A darabnak 0 felett kell lennie!")
		openSellMenu(id)
		return PLUGIN_HANDLED;
	}
	
	if(Key[id][f_Player[id][SelectedLKToPlace]] <= iErtek)
	{
		sk_chat(id, "Nincs ennyi kulcsod! Adj meg kevesebbet!")
		openSellMenu(id)
		return PLUGIN_HANDLED;
	}
	else
	{
		f_Player[id][SelectedLKToPlaceDarab] = iErtek;
		openSellMenu(id)
		return PLUGIN_HANDLED;
	}
}

public openSellMenu_h(id, menu, item)
{
	if(item == MENU_EXIT) {
		f_Player[id][SelectedItemToPlace] = -1;
		f_Player[id][SelectedInvArryKey] = 0;
		f_Player[id][SelectedLKToPlace] = 0;
		f_Player[id][SelectedLKToPlaceDarab] = 0;
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	new data[6], szName[64], access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
	new key = str_to_num(data)

	switch(key)
	{
		case -1: 	
		{
			f_Player[id][SwitchingOnMarket] = 1;
			f_Player[id][openSelectItemRow] = 3;
			openInventorySwitch(id)
		}
		case 1: client_cmd(id, "messagemode DOLLAR_AR")
		case 2: MarketPlace(id)
		case 3: client_cmd(id, "messagemode KULCS_DARAB")
		case 4: client_cmd(id, "messagemode LADA_DARAB")
	}


	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public MarketPlace(id)
{
	new MarketProduct[MarketSystem];
	switch(f_Player[id][SelectedItemToPlace])
	{
		case -1..0:
		{
			sk_chat(id, "^3HIBA:^1 Előbb válaszd ki mit szeretnél eladni!")
		}
		case 1:
		{
			new ArrId = f_Player[id][SelectedInvArryKey];
			if(gInventory[id][ArrId][equipped])
			{
				sk_chat(id, "^3HIBA:^1 Előbb szereld le a fegyvert.");
				openSellMenu(id);
				return PLUGIN_HANDLED;
			}
			
			MarketProduct[m_Type] = 1;
			MarketProduct[m_wid] = gInventory[id][ArrId][w_id];
			MarketProduct[m_userid] = sk_get_accountid(id);
			MarketProduct[m_isStatTraked] = gInventory[id][ArrId][isStatTraked];
			MarketProduct[m_StatTrakKills] = gInventory[id][ArrId][StatTrakKills];
			MarketProduct[m_isNameTaged] = gInventory[id][ArrId][isNameTaged];
			if(MarketProduct[m_isNameTaged])
				copy(MarketProduct[m_Nametag], 32, gInventory[id][ArrId][Nametag])
			else
				MarketProduct[m_Nametag] = EOS;

			MarketProduct[m_Allapot] = gInventory[id][ArrId][Allapot];
			MarketProduct[m_opened] = gInventory[id][ArrId][opened];
			copy(MarketProduct[m_openedfrom], 32, gInventory[id][ArrId][openedfrom])
			copy(MarketProduct[m_openedBy], 32, gInventory[id][ArrId][openedBy])
			MarketProduct[m_openedById] = gInventory[id][ArrId][openedById];
			MarketProduct[m_firecount] = gInventory[id][ArrId][firecount];
			MarketProduct[m_oldsqlid] = gInventory[id][ArrId][sqlid];

			gInventory[id][ArrId][deleted] = 1;
			UpdateItem(id, 7, f_Player[id][SelectedInvArryKey], 0)
			f_Player[id][Inventory_Size]--;

			MarketProduct[m_expire] = get_systime()+259200
			MarketProduct[m_cost] = f_Player[id][SetCost];
			copy(MarketProduct[m_SellerName], 33, sm_PlayerName[id])

			if(gInventory[id][ArrId][isNameTaged])
				sk_chat(0, "^4%s^1 Piacra helyezte: %s^3%s | ^"%s^"^1-t. ^4[^1Ára: ^3%3.2f$^4]", sm_PlayerName[id], MarketProduct[m_isStatTraked] == 1 ? "^4StatTrak*" : " ", FegyverInfo[MarketProduct[m_wid]][ChatWeapon], MarketProduct[m_Nametag], f_Player[id][SetCost])
			else
				sk_chat(0, "^4%s^1 Piacra helyezte: %s^3%s | %s^1-t. ^4[^1Ára: ^3%3.2f$^4]", sm_PlayerName[id], MarketProduct[m_isStatTraked] == 1 ? "^4StatTrak*" : " ", FegyverInfo[MarketProduct[m_wid]][ChatWeapon], FegyverInfo[MarketProduct[m_wid]][wname], f_Player[id][SetCost])
			smlog(id, 0, 0, "SELL_WEAPON", fmt("%3.2f$", MarketProduct[m_cost]), fmt("[%s %s] ~ [SQLID: #%i] OpenTime: %i | WeaponID: %i | Durability: %i | StatTraked: %i | NameTag: %s ~ OpenedFrom: %s", FegyverInfo[MarketProduct[m_wid]][wname], FegyverInfo[MarketProduct[m_wid]][ChatWeapon], MarketProduct[m_oldsqlid], MarketProduct[m_opened], MarketProduct[m_wid], MarketProduct[m_Allapot], MarketProduct[m_isStatTraked], MarketProduct[m_Nametag], MarketProduct[m_openedfrom]))		
		}
		case 2:
		{
			if(f_Player[id][SelectedLKToPlaceDarab] == 0)
			{
				sk_chat(id, "Nulla darab ládát nem rakhatsz piacra..")
				openSellMenu(id)
				return PLUGIN_HANDLED;
			}
			if(Case[id][f_Player[id][SelectedLKToPlace]] < f_Player[id][SelectedLKToPlaceDarab])
			{
				sk_chat(id, "Nincs ennyi ládád, adj meg kevesebbet!")
				openSellMenu(id)
				return PLUGIN_HANDLED;
			}

			MarketProduct[m_Type] = 2;
			MarketProduct[m_userid] = sk_get_accountid(id);
			MarketProduct[m_Case] = f_Player[id][SelectedLKToPlace];
			MarketProduct[m_Darab] = f_Player[id][SelectedLKToPlaceDarab];

			Case[id][f_Player[id][SelectedLKToPlace]] -= f_Player[id][SelectedLKToPlaceDarab];
			MarketProduct[m_expire] = get_systime()+259200
			MarketProduct[m_cost] = f_Player[id][SetCost];
			copy(MarketProduct[m_SellerName], 33, sm_PlayerName[id])

			sk_chat(0, "^4%s^1 Piacra helyezte: ^4%s^1(^3%i DB^1) ^4[^1Ára: ^3%3.2f$^4]", sm_PlayerName[id], Cases[f_Player[id][SelectedLKToPlace]][cName], f_Player[id][SelectedLKToPlaceDarab], f_Player[id][SetCost])
		}
		case 3:
		{
			if(f_Player[id][SelectedLKToPlaceDarab] == 0)
			{
				sk_chat(id, "Nulla darab kulcsot nem rakhatsz piacra..")
				openSellMenu(id)
				return PLUGIN_HANDLED;
			}
			if(Key[id][f_Player[id][SelectedLKToPlace]] < f_Player[id][SelectedLKToPlaceDarab])
			{
				sk_chat(id, "Nincs ennyi kulcsot, adj meg kevesebbet!")
				openSellMenu(id)
				return PLUGIN_HANDLED;
			}

			MarketProduct[m_Type] = 3;
			MarketProduct[m_userid] = sk_get_accountid(id);
			MarketProduct[m_Key] = f_Player[id][SelectedLKToPlace];
			MarketProduct[m_Darab] = f_Player[id][SelectedLKToPlaceDarab];

			Key[id][f_Player[id][SelectedLKToPlace]] -= f_Player[id][SelectedLKToPlaceDarab];
			MarketProduct[m_expire] = get_systime()+259200
			MarketProduct[m_cost] = f_Player[id][SetCost];
			copy(MarketProduct[m_SellerName], 33, sm_PlayerName[id])
			sk_chat(0, "^4%s^1 Piacra helyezte: ^4%s^1(^3%i DB^1) ^4[^1Ára: ^3%3.2f$^4]", sm_PlayerName[id], Keys[f_Player[id][SelectedLKToPlace]][cName], f_Player[id][SelectedLKToPlaceDarab], f_Player[id][SetCost])
		}
	}
	f_Player[id][SelectedItemToPlace] = -1;
	f_Player[id][SelectedInvArryKey] = 0;
	f_Player[id][SelectedLKToPlace] = 0;
	f_Player[id][SelectedLKToPlaceDarab] = 0;
	f_Player[id][SetCost] = 0.0;

	new MarketProductarrayid = ArrayPushArray(g_Market, MarketProduct)
	UpdateItemMarket(MarketProductarrayid)
	return PLUGIN_HANDLED;
}
public openBuyMenu(id)
{
	new NumStr[8];
	new menu = menu_create(fmt("%s \r[ \wVásárlás \r]", MENUPREFIX), "openBuyMenu_h");//MOD_MENU_MARKET_PURCHASE_TITLE
	
	menu_additem(menu, fmt("%L: \r[%L]^n", id, "GENERAL_FILTER", id, PiacSzures[f_Player[id][PiacSzuro]]), "-1")
	new Market[MarketSystem];
	new MarketSizeof = ArraySize(g_Market);

	for(new i = MarketSizeof - 1; i >= 0;i--)
	{
		ArrayGetArray(g_Market, i, Market);

		if(get_systime() >= Market[m_expire] && Market[m_cost] > 0)
		{
			ReturnMarket(i);
			continue;
		}
		if(Market[m_cost] < 0)
			continue;

		switch(f_Player[id][PiacSzuro])
		{
			case 0..4:
			{
				new String[1025], len
				if(f_Player[id][PiacSzuro] == 0)
				{
					if(Market[m_cost] > 0)
					{
						if(Market[m_userid] == sk_get_accountid(id))
							len += formatex(String[len], charsmax(String) - len, "\r* \d- ");
					}
					switch(Market[m_Type])
					{
						case 1:
						{	
							if(Market[m_isNameTaged])
								len += formatex(String[len], charsmax(String) - len, "\w%s^"%s^"", FegyverInfo[Market[m_wid]][MenuWeapon], Market[m_Nametag])
							else
								len += formatex(String[len], charsmax(String) - len, "\w%s%s", FegyverInfo[Market[m_wid]][MenuWeapon], FegyverInfo[Market[m_wid]][wname])

							len += formatex(String[len], charsmax(String) - len, "%s", Market[m_Allapot] == 101 ? fmt("\y(%L)", id, "GENERAL_UNBRKBL") : fmt(" \y(\d%i%%\y)", Market[m_Allapot]))

							if(Market[m_isStatTraked])
								len += formatex(String[len], charsmax(String) - len, " \rsT*");
						}
						case 2: len += formatex(String[len], charsmax(String) - len, "\y%s \r(%i %L)", Cases[Market[m_Case]][cName], Market[m_Darab], id, "GENERAL_UNIT_PIECE_F")
						case 3: len += formatex(String[len], charsmax(String) - len, "\y%s \r(%i %L)", Keys[Market[m_Key]][cName], Market[m_Darab], id, "GENERAL_UNIT_PIECE_F")
					}
					len += formatex(String[len], charsmax(String) - len, " \d| \w%L: \r%3.2f$", id, "GENERAL_PRICE", Market[m_cost]);

					num_to_str(i, NumStr, 8);
					menu_additem(menu, String, NumStr, 0);
				}
				else if(f_Player[id][PiacSzuro] != 6 && f_Player[id][PiacSzuro] != 0)
				{
					if(Market[m_Type] != 1 || Market[m_cost] == 0)
						continue;

					if(FegyverInfo[Market[m_wid]][EntName] != CSW_PiacSzures[f_Player[id][PiacSzuro]])
						continue;

					new String[121]
					if(Market[m_userid] == sk_get_accountid(id))
						len += formatex(String[len], charsmax(String) - len, "\r* \d- ");

					if(Market[m_isNameTaged])
						len += formatex(String[len], charsmax(String) - len, "\w%s^"%s^"", FegyverInfo[Market[m_wid]][MenuWeapon], Market[m_Nametag])
					else
						len += formatex(String[len], charsmax(String) - len, "\w%s%s", FegyverInfo[Market[m_wid]][MenuWeapon], FegyverInfo[Market[m_wid]][wname])

					len += formatex(String[len], charsmax(String) - len, "%s", Market[m_Allapot] == 101 ? fmt("\y(%L)", id, "GENERAL_UNBRKBL") : fmt(" \y(\d%i%%\y)", Market[m_Allapot]))

					if(Market[m_isStatTraked])
						len += formatex(String[len], charsmax(String) - len, " \rsT*");
					
					len += formatex(String[len], charsmax(String) - len, " \d| \w%L: \r%3.2f$", id, "GENERAL_PRICE", Market[m_cost]);

					num_to_str(i, NumStr, 8);
					menu_additem(menu, String, NumStr, 0);
				}
			}
			case 5:
			{
				if(Market[m_Type] != 1 || Market[m_cost] == 0 || FegyverInfo[Market[m_wid]][EntName] != CSW_KNIFE)
					continue;

				new String[121], len
				if(Market[m_userid] == sk_get_accountid(id))
					len += formatex(String[len], charsmax(String) - len, "\r* \d- ");

				if(Market[m_isNameTaged])
					len += formatex(String[len], charsmax(String) - len, "\w%s^"%s^"", FegyverInfo[Market[m_wid]][MenuWeapon], Market[m_Nametag])
				else
					len += formatex(String[len], charsmax(String) - len, "\w%s%s", FegyverInfo[Market[m_wid]][MenuWeapon], FegyverInfo[Market[m_wid]][wname])

				len += formatex(String[len], charsmax(String) - len, "%s", Market[m_Allapot] == 101 ? fmt("\y(%L)", id, "GENERAL_UNBRKBL") : fmt(" \y(\d%i%%\y)", Market[m_Allapot]))

				if(Market[m_isStatTraked])
					len += formatex(String[len], charsmax(String) - len, " \rsT*");
				len += formatex(String[len], charsmax(String) - len, " \d| \w%L: \r%3.2f$", id, "GENERAL_PRICE", Market[m_cost]);

				num_to_str(i, NumStr, 8);
				menu_additem(menu, String, NumStr, 0);
			}
			case 6:
			{
				if(Market[m_cost] == 0)
					continue;

				new String[121], len

				if(Market[m_userid] == sk_get_accountid(id))
					len += formatex(String[len], charsmax(String) - len, "\r* \d- ");

				switch(Market[m_Type])
				{
					case 2: len += formatex(String[len], charsmax(String) - len, "\y%s %L \r(%i %L)", Cases[Market[m_Case]][cName], id, "GENERAL_CRATE", Market[m_Darab], id, "GENERAL_UNIT_PIECE_F")
					case 3: len += formatex(String[len], charsmax(String) - len, "\y%s %L \r(%i %L)", Keys[Market[m_Key]][cName], id, "GENERAL_KEY", Market[m_Darab], id, "GENERAL_UNIT_PIECE_F")
					default: continue;
				}
				len += formatex(String[len], charsmax(String) - len, " \d| \w%L: \r%3.2f$", id, "GENERAL_PRICE", Market[m_cost]);
				num_to_str(i, NumStr, 8);
				menu_additem(menu, String, NumStr, 0);
			}
			case 7:
			{
				if(Market[m_Type] != 1 || Market[m_cost] == 0)
					continue;

				switch(Market[m_wid])
				{
					case 0..190: { continue; } 
					case 196..202: { continue; } 
					case 218..222: { continue; } 
				}

				new String[121], len
				if(Market[m_userid] == sk_get_accountid(id))
					len += formatex(String[len], charsmax(String) - len, "\r* \d- ");

				if(Market[m_isNameTaged])
					len += formatex(String[len], charsmax(String) - len, "\w%s^"%s^"", FegyverInfo[Market[m_wid]][MenuWeapon], Market[m_Nametag])
				else
					len += formatex(String[len], charsmax(String) - len, "\w%s%s", FegyverInfo[Market[m_wid]][MenuWeapon], FegyverInfo[Market[m_wid]][wname])

				len += formatex(String[len], charsmax(String) - len, "%s", Market[m_Allapot] == 101 ? fmt("\y(%L)", id, "GENERAL_UNBRKBL") : fmt(" \y(\d%i%%\y)", Market[m_Allapot]))

				if(Market[m_isStatTraked])
					len += formatex(String[len], charsmax(String) - len, " \rsT*");
				
				len += formatex(String[len], charsmax(String) - len, " \d| \w%L: \r%3.2f$", id, "GENERAL_PRICE", Market[m_cost]);

				num_to_str(i, NumStr, 8);
				menu_additem(menu, String, NumStr, 0);
			}
			case 8:
			{
				if(Market[m_Type] != 1 || Market[m_cost] == 0)
					continue;

				if(Market[m_Allapot] != 101)
					continue;

				new String[121], len
				if(Market[m_userid] == sk_get_accountid(id))
					len += formatex(String[len], charsmax(String) - len, "\r* \d- ");

				if(Market[m_isNameTaged])
					len += formatex(String[len], charsmax(String) - len, "\w%s^"%s^"", FegyverInfo[Market[m_wid]][MenuWeapon], Market[m_Nametag])
				else
					len += formatex(String[len], charsmax(String) - len, "\w%s%s", FegyverInfo[Market[m_wid]][MenuWeapon], FegyverInfo[Market[m_wid]][wname])

				len += formatex(String[len], charsmax(String) - len, "%s", Market[m_Allapot] == 101 ? fmt("\y(%L)", id, "GENERAL_UNBRKBL") : fmt(" \y(\d%i%%\y)", Market[m_Allapot]))

				if(Market[m_isStatTraked])
					len += formatex(String[len], charsmax(String) - len, " \rsT*");
				
				len += formatex(String[len], charsmax(String) - len, " \d| \w%L: \r%3.2f$", id, "GENERAL_PRICE", Market[m_cost]);

				num_to_str(i, NumStr, 8);
				menu_additem(menu, String, NumStr, 0);
			}
		}
	}
	menu_setprop(menu, MPROP_NEXTNAME, fmt("%L", id, "GENERAL_MENU_NEXT"));
	menu_setprop(menu, MPROP_BACKNAME, fmt("%L", id, "GENERAL_MENU_BACK"));
	menu_setprop(menu, MPROP_EXITNAME, fmt("%L", id, "GENERAL_MENU_EXIT"));
	menu_setprop(menu, MPROP_PERPAGE, 5);
	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}
public openBuyMenu_h(id, menu, item)
{
	if(item == MENU_EXIT) {
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	new data[6], szName[64], access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
	new key = str_to_num(data)

	switch(key)
	{
		case -1: 	
		{
			if(f_Player[id][PiacSzuro] != 8)
				f_Player[id][PiacSzuro]++;
			else
			{
				f_Player[id][PiacSzuro] = 0;
			}
			openBuyMenu(id);
			return PLUGIN_HANDLED;
		}
	}
	new Market[MarketSystem];
	ArrayGetArray(g_Market, key, Market)

	if(Market[m_cost] < 0)
	{
		sk_chat(id, "Az ^3itemet^1 amit szerettél volna megnézni, már nincs a piacon!");
		openBuyMenu(id)
		return PLUGIN_HANDLED;
	}
	openBuyMenuInformation(id, key)

	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public openBuyMenuInformation(id, marketarr)
{
	f_Player[id][MarketArrId] = marketarr;

	new String[256], StringTime[31];
		
	formatex(String, charsmax(String), "\d%s \r[ \wVásárlás\r ] ^n\d%3.2f", MENUPREFIX, f_Player[id][Dollar])//MOD_MENU_ITEM_PURCHASE_TITLE
	new menu = menu_create(String, "MarketInfo_buyhandler");

	new Market[MarketSystem];
	ArrayGetArray(g_Market, marketarr, Market);
	format_time(StringTime, 31, "%Y/%m/%d - %H:%M:%S", Market[m_expire])
	switch(Market[m_Type])
	{
		case 1:
		{
			menu_addtext2(menu, fmt("\w%L: \r%s%s\w[\y#%i\w]", id, "GENERAL_WEAPON", FegyverInfo[Market[m_wid]][MenuWeapon], FegyverInfo[Market[m_wid]][wname], Market[m_oldsqlid]))
			menu_addtext2(menu, fmt("\w%L \r%s", id, "MOD_MENU_ITEM_PURCHASE_REMOVE_TIME", StringTime))
			new String[20]
			if(Market[m_Allapot] <= 4)
				copy(String, charsmax(String), fmt("\d(%L)", id, "GENERAL_BROKEN"))
			else copy(String, charsmax(String), "")

			menu_addtext2(menu, fmt("\w%L: \r%s\d(#%i)^n\w%L: \r%s", id, "GENERAL_SELLER", Market[m_SellerName], Market[m_userid], id, "GENERAL_CONDITION", Market[m_Allapot] == 101 ? fmt("\y%L", id, "GENERAL_UNBRAKEABLE") : (fmt("%i%% %s", Market[m_Allapot], String))))

			if(Market[m_isNameTaged])
				menu_addtext2(menu, fmt("\w%L: \r^"%s^"", id, "GENERAL_NAME_TAG", Market[m_Nametag]))
			else
				menu_addtext2(menu, fmt("\w%L: \d%L", id, "GENERAL_NAME_TAG", id, "GENERAL_UNIT_NONE"))

			menu_addtext2(menu, fmt("\wStatTrak\y*: %s \d(\y%L: \r%i\d)^n", Market[m_isStatTraked] ? fmt("\y%L", id, "GENERAL_UNIT_AVAILABE") : fmt("\d%L", id, "GENERAL_UNIT_NONE"), id, "GENERAL_KILLS", Market[m_StatTrakKills]))
		
			menu_additem(menu, "\wFegyver megnézése", "-2", 0) //toDoLang
		}
		case 2:
		{
			menu_addtext2(menu, fmt("\w%L: \y%s %L", id, "GENERAL_ITEM", Cases[Market[m_Case]][cName], id, "GENERAL_CRATE"))
			menu_addtext2(menu, fmt("\w%L: \r%i %L", id, "GENERAL_UNIT_PIECE_F", Market[m_Darab], id, "GENERAL_UNIT_PIECE"))
			menu_addtext2(menu, fmt("\w%L \r%s", id, "MOD_MENU_ITEM_PURCHASE_REMOVE_TIME", StringTime))
			menu_addtext2(menu, fmt("\w%L: \r%s\d(#%i)^n", id, "GENERAL_SELLER", Market[m_SellerName], Market[m_userid]))
		}
		case 3:
		{
			menu_addtext2(menu, fmt("\w%L: \y%s %L", id, "GENERAL_ITEM", Keys[Market[m_Key]][cName], id, "GENERAL_KEY"))
			menu_addtext2(menu, fmt("\w%L: \r%i %L", id, "GENERAL_UNIT_PIECE_F", Market[m_Darab], id, "GENERAL_UNIT_PIECE"))
			menu_addtext2(menu, fmt("\w%L \r%s", id, "MOD_MENU_ITEM_PURCHASE_REMOVE_TIME", StringTime))
			menu_addtext2(menu, fmt("\w%L: \r%s\d(#%i)^n", id, "GENERAL_SELLER", Market[m_SellerName], Market[m_userid]))
		}
	}

	if(Market[m_userid] == f_Player[id][a_UserId])
	{
		if(InventoryCanAdd(id, "", 0))
			menu_additem(menu, fmt("%L", id, "MOD_MENU_ITEM_PURCHASE_WITHDRAW"), "1", 0)
		else
			menu_additem(menu, fmt("\dItem visszavonása [Tele az Inventoryd]"), "1", ADMIN_ADMIN)
	}
	else
	{
		if(InventoryCanAdd(id, "", 0))
			menu_additem(menu, fmt("\y%L \d[\y%L: \r%3.2f\d]", id, "GENERAL_BUY", id, "GENERAL_PRICE", Market[m_cost]), Market[m_cost] <= f_Player[id][Dollar] ? "2" : "-1", 0)
		else
			menu_additem(menu, fmt("\dVásárlás [Tele az Inventoryd]"), "2", ADMIN_ADMIN)
	}

	menu_setprop(menu, MPROP_NEXTNAME, fmt("%L", id, "GENERAL_MENU_NEXT"));
	menu_setprop(menu, MPROP_BACKNAME, fmt("%L", id, "GENERAL_MENU_BACK"));
	menu_setprop(menu, MPROP_EXITNAME, fmt("%L", id, "GENERAL_MENU_EXIT"));
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
		case -2:
		{
			new Market[MarketSystem]
			ArrayGetArray(g_Market, f_Player[id][MarketArrId], Market)
			
			if(FegyverInfo[Market[m_wid]][wid] < 10)
				show_motd(id, fmt("http://herboyd2.hu/WeaponSkins/seeskin.php?wid=000%i", FegyverInfo[Market[m_wid]][wid]), fmt("%s%s", FegyverInfo[Market[m_wid]][MenuWeapon], FegyverInfo[Market[m_wid]][wname]))
			else if(FegyverInfo[Market[m_wid]][wid] < 100)
				show_motd(id, fmt("http://herboyd2.hu/WeaponSkins/seeskin.php?wid=00%i", FegyverInfo[Market[m_wid]][wid]), fmt("%s%s", FegyverInfo[Market[m_wid]][MenuWeapon], FegyverInfo[Market[m_wid]][wname]))
			else
				show_motd(id, fmt("http://herboyd2.hu/WeaponSkins/seeskin.php?wid=0%i", FegyverInfo[Market[m_wid]][wid]), fmt("%s%s", FegyverInfo[Market[m_wid]][MenuWeapon], FegyverInfo[Market[m_wid]][wname]))
		}
		case -1: 
		{
			sk_chat(id, "Nincs elég ^3$^1-od, hogy megvásárolhasd ezt az ^3Itemet!")
			openBuyMenuInformation(id, f_Player[id][MarketArrId]);
		}
		case 1: ReturnMarket(f_Player[id][MarketArrId])
		case 2: BuyFromMarket(id, f_Player[id][MarketArrId])
	}
	return PLUGIN_HANDLED;
}
public BuyFromMarket(id, m_arrayid)
{
	client_cmd(id, "spk Herboynew/buy")
	new Market[MarketSystem];
	ArrayGetArray(g_Market, m_arrayid, Market)

	if(Market[m_cost] < 0)
	{
		sk_chat(id, "Az ^3itemet^1 amit szerettél volna megvenni, már nincs a piacon!");
		openBuyMenu(id)
		return PLUGIN_HANDLED;
	}
	new SellID = UserOnline(Market[m_userid])
	if(SellID != -1)
		f_Player[SellID][Dollar] += Market[m_cost]
	else
		OfflineReward(Market[m_userid], Market[m_cost]);

	switch(Market[m_Type])
	{
		case 1:
		{
			if(!InventoryCanAdd(id, "Tele a raktárad! Vegyél férőhelyet az áruházban!", 0))
				return PLUGIN_HANDLED;

			//TODO ADDINV
			new Inventory[InventorySystem]
			Inventory[w_id] = Market[m_wid]
			Inventory[w_userid] = f_Player[id][a_UserId]
			Inventory[isStatTraked] = Market[m_isStatTraked];
			Inventory[StatTrakKills] = Market[m_StatTrakKills];
			Inventory[isNameTaged] = Market[m_isNameTaged];
			if(Inventory[isNameTaged])
				copy(Inventory[Nametag], 32, Market[m_Nametag])
			else
				Inventory[Nametag] = EOS;

			Inventory[Allapot] = Market[m_Allapot];
			Inventory[opened] = Market[m_opened];
			copy(Inventory[openedfrom], 32, Market[m_openedfrom])
			copy(Inventory[openedBy], 32, Market[m_openedBy])
			Inventory[openedById] = Market[m_openedById];
			Inventory[firecount] = Market[m_firecount];
			Inventory[sqlid] = Market[m_oldsqlid];
			Inventory[is_new] = get_systime()+21600;
			Inventory[deleted] = 0;
			Inventory[equipped] = 0;
			Inventory[tradable] = 1;

			gInventory[id][f_Player[id][InventoryWriteableSize]] = Inventory;
			UpdateItem(id, 1, f_Player[id][InventoryWriteableSize], 0)
			f_Player[id][InventoryWriteableSize]++;
			f_Player[id][Inventory_Size]++;

			new WepName[100], len
			if(Inventory[isNameTaged])
				len += formatex(WepName[len], charsmax(WepName) - len, "^"%s^"", Inventory[Nametag])
			else
				len += formatex(WepName[len], charsmax(WepName) - len, "%s %s", FegyverInfo[Inventory[w_id]][ChatWeapon], FegyverInfo[Inventory[w_id]][wname])

			sk_chat(0, "^4%s^1 vett egy itemet: ^4%s%s^1 ^3%s^1-tól/től ^4%3.2f^1 dollárért!", sm_PlayerName[id], Inventory[isStatTraked] == 1 ? "StatTrak*" : "", WepName, Market[m_SellerName], Market[m_cost])
			smlog(id, 0, 0, "BUY_WEAPON", fmt("%3.2f$", Market[m_cost]), fmt("[%s %s] ~ [SQLID: #%i] OpenTime: %i | WeaponID: %i | Durability: %i | StatTraked: %i | NameTag: %s ~ OpenedFrom: %s | BuyedFromAccId: #%i", FegyverInfo[Market[m_wid]][wname], FegyverInfo[Market[m_wid]][ChatWeapon], Market[m_oldsqlid], Market[m_opened], Market[m_wid], Market[m_Allapot], Market[m_isStatTraked], Market[m_Nametag], Market[m_openedfrom], Market[m_userid]))
			//UpdateItem(id, 1, arrayid, 0)
		}
		case 2:
		{
			Case[id][Market[m_Case]] += Market[m_Darab]
			sk_chat(0, "^4%s^1 vett egy itemet: ^4%s^1(^3%i DB^1) ^3%s^1-tól/től ^4%3.2f^1 dollárért!", sm_PlayerName[id], Cases[Market[m_Case]][cName], Market[m_Darab], Market[m_SellerName], Market[m_cost])
		}
		case 3:
		{
			Key[id][Market[m_Key]] += Market[m_Darab]
			sk_chat(0, "^4%s^1 vett egy itemet: ^4%s^1(^3%i DB^1) ^3%s^1-tól/től ^4%3.2f^1 dollárért!", sm_PlayerName[id], Keys[Market[m_Key]][cName], Market[m_Darab], Market[m_SellerName], Market[m_cost])
		}
	}
	new Len;
	static Query[1024];
	Len += formatex(Query[Len], charsmax(Query)-Len, "DELETE FROM `market` WHERE `m_sqlid` = %i;", Market[m_sqlid]);		
	SQL_ThreadQuery(m_get_sql(), "QuerySetOfflineMarket", Query);
	f_Player[id][Dollar] -= Market[m_cost]
	Market[m_cost] = -1.0;
	ArraySetArray(g_Market, m_arrayid, Market)
	return PLUGIN_HANDLED;
}
public ReturnMarket(MarketSlot)
{
	new Market[MarketSystem], Len;
	ArrayGetArray(g_Market, MarketSlot, Market);

	new Seller_id = UserOnline(Market[m_userid]);
	
	if(Seller_id != -1)
	{
		switch(Market[m_Type])
		{
			case 1:
			{

				new Inventory[InventorySystem]
				Inventory[w_id] = Market[m_wid]
				Inventory[w_userid] = f_Player[Seller_id][a_UserId]
				Inventory[isStatTraked] = Market[m_isStatTraked];
				Inventory[StatTrakKills] = Market[m_StatTrakKills];
				Inventory[isNameTaged] = Market[m_isNameTaged];
				if(Inventory[isNameTaged])
					copy(Inventory[Nametag], 32, Market[m_Nametag])
				else
					Inventory[Nametag] = EOS;

				Inventory[Allapot] = Market[m_Allapot];
				Inventory[opened] = Market[m_opened];
				copy(Inventory[openedfrom], 32, Market[m_openedfrom])
				copy(Inventory[openedBy], 32, Market[m_openedBy])
				Inventory[openedById] = Market[m_openedById];
				Inventory[firecount] = Market[m_firecount];
				Inventory[sqlid] = Market[m_oldsqlid];
				Inventory[is_new] = get_systime()+21600;
				Inventory[deleted] = 0;
				Inventory[equipped] = 0;
				Inventory[tradable] = 1;


				//UpdateItem(Seller_id, 1, arryid, -1)

				gInventory[Seller_id][f_Player[Seller_id][InventoryWriteableSize]] = Inventory;
				UpdateItem(Seller_id, 1, f_Player[Seller_id][InventoryWriteableSize], 0)
				f_Player[Seller_id][InventoryWriteableSize]++;
				f_Player[Seller_id][Inventory_Size]++;

				new WepName[100], len
				if(Inventory[isNameTaged])
					len += formatex(WepName[len], charsmax(WepName) - len, "^"%s^"", Inventory[Nametag])
				else
					len += formatex(WepName[len], charsmax(WepName) - len, "%s%s", FegyverInfo[Inventory[w_id]][MenuWeapon], FegyverInfo[Inventory[w_id]][wname])

				sk_chat(Seller_id, "Item visszaadva: ^4%s%s^1, mert visszavontad, vagy lejárt az ideje!", Inventory[isStatTraked] == 1 ? "StatTrak*" : "", WepName)
				smlog(Seller_id, 0, 0, "BACK_WEAPON_ONLINE", "none", fmt("[%s %s] ~ [SQLID: #%i] OpenTime: %i | WeaponID: %i | Durability: %i | StatTraked: %i | NameTag: %s ~ OpenedFrom: %s", FegyverInfo[Market[m_wid]][wname], FegyverInfo[Market[m_wid]][ChatWeapon], Market[m_oldsqlid], Market[m_opened], Market[m_wid], Market[m_Allapot], Market[m_isStatTraked], Market[m_Nametag], Market[m_openedfrom]))
				
			}
			case 2:
			{
				Case[Seller_id][Market[m_Case]] += Market[m_Darab]
				sk_chat(Seller_id, "Item visszaadva: ^4%s^1(^3%i DB^1), mert visszavontad, vagy lejárt az ideje!", Cases[Market[m_Case]][cName], Market[m_Darab])
			}
			case 3:
			{
				Key[Seller_id][Market[m_Key]] += Market[m_Darab]
				sk_chat(Seller_id, "Item visszaadva: ^4%s^1(^3%i DB^1), mert visszavontad, vagy lejárt az ideje!", Keys[Market[m_Key]][cName], Market[m_Darab])
			}
		}	

		static QueryA[1024], iLen;
		iLen += formatex(QueryA[iLen], charsmax(QueryA)-iLen, "DELETE FROM `market` WHERE `m_sqlid` = %i;", Market[m_sqlid]);		
		SQL_ThreadQuery(m_get_sql(), "QuerySetDeleteMarket", QueryA);
		Market[m_cost] = -1.0;
		ArraySetArray(g_Market, MarketSlot, Market);
	}
	else
	{
		switch(Market[m_Type])
		{
			case 1:
			{
				static sQuery[1024]
				if(Market[m_oldsqlid] > 0)
					Len += formatex(sQuery[Len], charsmax(sQuery)-Len, "INSERT INTO `inventory` (`w_userid`,`w_id`,`IsNameTaged`,`Nametag`,`IsStatTraked`,`StatTrakKills`,`tradable`,`equiped`,`Allapot`,`sqlid`,`opened`,`openedById`,`openedBy`,`openedfrom`, `is_new`, `firecount`) VALUES (");
				else
					Len += formatex(sQuery[Len], charsmax(sQuery)-Len, "INSERT INTO `inventory` (`w_userid`,`w_id`,`IsNameTaged`,`Nametag`,`IsStatTraked`,`StatTrakKills`,`tradable`,`equiped`,`Allapot`,`opened`,`openedById`,`openedBy`,`openedfrom`, `is_new`, `firecount`) VALUES (");
				
				Len += formatex(sQuery[Len], charsmax(sQuery)-Len, "%i,", Market[m_userid]);
				Len += formatex(sQuery[Len], charsmax(sQuery)-Len, "%i,", Market[m_wid]);
				Len += formatex(sQuery[Len], charsmax(sQuery)-Len, "%i,", Market[m_isNameTaged]);
				Len += formatex(sQuery[Len], charsmax(sQuery)-Len, "^"%s^",", Market[m_Nametag]);
				Len += formatex(sQuery[Len], charsmax(sQuery)-Len, "%i,", Market[m_isStatTraked]);
				Len += formatex(sQuery[Len], charsmax(sQuery)-Len, "%i,", Market[m_StatTrakKills]);
				Len += formatex(sQuery[Len], charsmax(sQuery)-Len, "1,");
				Len += formatex(sQuery[Len], charsmax(sQuery)-Len, "0,");
				Len += formatex(sQuery[Len], charsmax(sQuery)-Len, "%i,", Market[m_Allapot]);
				if(Market[m_oldsqlid] > 0)
					Len += formatex(sQuery[Len], charsmax(sQuery)-Len, "%i,", Market[m_oldsqlid]);

				Len += formatex(sQuery[Len], charsmax(sQuery)-Len, "%i,", Market[m_opened]);
				Len += formatex(sQuery[Len], charsmax(sQuery)-Len, "%i,", Market[m_openedById]);
				Len += formatex(sQuery[Len], charsmax(sQuery)-Len, "^"%s^", ", Market[m_openedBy]);
				Len += formatex(sQuery[Len], charsmax(sQuery)-Len, "^"%s^", ", Market[m_openedfrom]);
				Len += formatex(sQuery[Len], charsmax(sQuery)-Len, "%i,", get_systime()+21600);
				Len += formatex(sQuery[Len], charsmax(sQuery)-Len, "%i);", Market[m_firecount]);
				SQL_ThreadQuery(m_get_sql(), "QuerySetOfflineMarket", sQuery);

				new WepName[100], len
				if(Market[m_isNameTaged])
					len += formatex(WepName[len], charsmax(WepName) - len, "^"%s^"", Market[m_Nametag])
				else
					len += formatex(WepName[len], charsmax(WepName) - len, "%s%s", FegyverInfo[Market[m_wid]][MenuWeapon], FegyverInfo[Market[m_wid]][wname])

				sk_chat(0, "Item visszaadva neki: ^4%s^1: ^4%s%s^1, mert lejárt az ideje!", Market[m_SellerName], Market[m_isStatTraked] == 1 ? "StatTrak*" : "", WepName)
				smlog(0, 0, 0, "BACK_WEAPON_OFFLINE", "none", fmt("[%s %s] ~ [SQLID: #%i] OpenTime: %i | WeaponID: %i | Durability: %i | StatTraked: %i | NameTag: %s ~ OpenedFrom: %s | OWNER: #%i", FegyverInfo[Market[m_wid]][wname], FegyverInfo[Market[m_wid]][ChatWeapon], Market[m_oldsqlid], Market[m_opened], Market[m_wid], Market[m_Allapot], Market[m_isStatTraked], Market[m_Nametag], Market[m_openedfrom], Market[m_userid]))
			} 
			case 2:
			{
				static sQuery[1024]
				formatex(sQuery, charsmax(sQuery), "UPDATE `case_datas` SET `Case%i` = `Case%i`+%i WHERE `aid` = ^"%i^";", Market[m_Case], Market[m_Case], Market[m_Darab], Market[m_userid]);
				SQL_ThreadQuery(m_get_sql(), "QuerySetOfflineMarket", sQuery);
				sk_chat(0, "Item visszaadva neki ^4%s^1: ^4%s^1(^3%i DB^1), mert lejárt az ideje!", Market[m_SellerName], Cases[Market[m_Case]][cName], Market[m_Darab])
			}
			case 3:
			{
				static sQuery[1024]
				formatex(sQuery, charsmax(sQuery), "UPDATE `case_datas` SET `Key%i` = `Key%i`+%i WHERE `aid` = ^"%i^";", Market[m_Key], Market[m_Key], Market[m_Darab], Market[m_userid]);
				SQL_ThreadQuery(m_get_sql(), "QuerySetOfflineMarket", sQuery);
				sk_chat(0, "Item visszaadva neki ^4%s^1: ^4%s^1(^3%i DB^1), mert lejárt az ideje!", Market[m_SellerName], Keys[Market[m_Key]][cName], Market[m_Darab])
			}
		}
		if(Market[m_Type] != 1)
		{
			static QueryA[1024], iLen;
			iLen += formatex(QueryA[iLen], charsmax(QueryA)-iLen, "DELETE FROM `market` WHERE `m_sqlid` = %i;", Market[m_sqlid]);		
			SQL_ThreadQuery(m_get_sql(), "QuerySetDeleteMarket", QueryA);
			Market[m_cost] = -1.0;
			ArraySetArray(g_Market, MarketSlot, Market);
		}
	}

}
public OfflineReward(User_ids, Float:m_Price)
{
	new Query[1024];
	formatex(Query, charsmax(Query), "UPDATE `datas` SET Dollar = Dollar + ^"%3.2f^" WHERE `aid` =	%d;", m_Price, User_ids);
	SQL_ThreadQuery(m_get_sql(), "QuerySetData_Profiles", Query);
}
public QuerySetOfflineMarket(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime)
{
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) 
	{
		log_amx("Error from OfflineMarket:");
		log_amx("%s", Error);
		return;
	}
}
public QuerySetData_Profiles(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime)
{
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) 
	{
		log_amx("Error from OfflineMarket:");
		log_amx("%s", Error);
		return;
	}
}
public QuerySetDeleteMarket(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime)
{
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) 
	{
		log_amx("Error from DeleteMarket:");
		log_amx("%s", Error);
		return;
	}
}
public UpdateItemMarket(ItemArray)
{
	static Query[10024]
	new Len;
	new Data[1];
	new Market[MarketSystem];
	ArrayGetArray(g_Market, ItemArray, Market);

	Len = formatex(Query[Len], charsmax(Query), "INSERT INTO `market` (`m_Type`, `m_Case`, `m_Key`, `m_wid`, `m_userid`, `m_isStatTraked`, `m_StatTrakKills`, `m_isNameTaged`,`m_Nametag`, `m_Allapot`, `m_opened`, `m_expire`, `m_cost`, `m_SellerName`, `m_oldsqlid`, `openedfrom`,`openedBy`,`openedById`,`firecount`,`m_darab`) VALUES (");
	Len += formatex(Query[Len], charsmax(Query)-Len, "%i, ", Market[m_Type]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "%i, ", Market[m_Case]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "%i, ", Market[m_Key]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "%i, ", Market[m_wid]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "%i, ", Market[m_userid]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "%i, ", Market[m_isStatTraked]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "%i, ", Market[m_StatTrakKills]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "%i, ", Market[m_isNameTaged]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "^"%s^", ", Market[m_Nametag]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "%i, ", Market[m_Allapot]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "%i, ", Market[m_opened]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "%i, ", Market[m_expire]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "%.2f, ", Market[m_cost]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "^"%s^", ", Market[m_SellerName]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "%i, ", Market[m_oldsqlid]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "^"%s^", ", Market[m_openedfrom]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "^"%s^", ", Market[m_openedBy]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "%i, ", Market[m_openedById]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "%i, ", Market[m_firecount]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "%i); ", Market[m_Darab]);

	Data[0] = ItemArray
	SQL_ThreadQuery(m_get_sql(), "QuerySetData_Market", Query, Data, 1);
}
public QuerySetData_Market(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime)
{
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) 
	{
		log_amx("Error from Market:");
		log_amx("%s", Error);
		return;
	}
	new Market[MarketSystem];
	new getsqlid = SQL_GetInsertId(Query);
	new margo = Data[0]
	ArrayGetArray(g_Market, margo, Market)
	Market[m_sqlid] = getsqlid;
	ArraySetArray(g_Market, margo, Market)
}
public LoadMarket()
{
	static Query[10024]
	new Data[1];
	formatex(Query, charsmax(Query), "SELECT * FROM `market`")
	SQL_ThreadQuery(m_get_sql(), "QueryLoadMarket", Query, Data, 1);
}
public QueryLoadMarket(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime) {
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) {
		log_amx("%s", Error);
		SendToAdmins(fmt("^3[Error-LoadMarket] ^4%s", Error))
		return;
	}
	else {
		/* new id = Data[0]; */
		new Market[MarketSystem];
		
		if(SQL_NumRows(Query) > 0) 
		{
			while(SQL_MoreResults(Query))
			{
				Market[m_Type] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "m_Type"));
				Market[m_Case] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "m_Case"));
				Market[m_Key] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "m_Key"));
				Market[m_userid] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "m_userid"));
				Market[m_sqlid] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "m_sqlid"));
				Market[m_wid] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "m_wid"));
				Market[m_isStatTraked] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "m_isStatTraked"));
				Market[m_StatTrakKills] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "m_StatTrakKills"));				
				Market[m_isNameTaged] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "m_isNameTaged"));
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "m_Nametag"), Market[m_Nametag], 100);
				Market[m_Allapot] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "m_Allapot"));
				Market[m_opened] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "m_opened"));
				Market[m_expire] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "m_expire"));
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "m_cost"), Market[m_cost]);
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "m_SellerName"), Market[m_SellerName], 32);
				Market[m_oldsqlid] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "m_oldsqlid"));
				Market[m_Darab] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "m_darab"));
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "openedfrom"), Market[m_openedfrom], 32);
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "openedBy"), Market[m_openedBy], 32);
				Market[m_firecount] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "firecount"));
				Market[m_openedById] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "openedById"));

				new g_ProductSizeof = ArraySize(g_Market);
				for(new x = 0; x < g_ProductSizeof; x++)
				{
					new ProductMatcher[MarketSystem];
					ArrayGetArray(g_Market, x, ProductMatcher);
					if(Market[m_expire] == ProductMatcher[m_expire] && Market[m_userid] == ProductMatcher[m_userid])
					{
						Market[m_cost] = -1.0;
						break;
					}
				}
				ArrayPushArray(g_Market, Market);
				SQL_NextRow(Query);
			}
		}
	}
}
public UserOnline(User_id)
{
	new foundid = -1;
	for(new i = 1;i < 33;i++)
	{
		if(is_user_connected(i))
			if(f_Player[i][a_UserId] == User_id)
			{
				foundid = i;
				break;
			}
	}
	return foundid;
}
public client_connect(id)
{
	client_cmd(id, "fs_lazy_precache 1");
	engclient_cmd(id, "fs_lazy_precache 1");
}
public cmdDollarEladas(id) {
	new Float:iErtek, iAdatok[32]
	read_args(iAdatok, charsmax(iAdatok))
	remove_quotes(iAdatok)
			
	iErtek = str_to_float(iAdatok)		
			
	if(iErtek > 100000.0) {
		client_print_color(id, print_team_default, "^4%s^1 Nem tudsz eladni^3 100000.00$ ^1felett!", CHATPREFIX)
		client_cmd(id, "messagemode DOLLAR_AR")
		return PLUGIN_HANDLED;
	}
	else if(iErtek < 0.01) {
		client_print_color(id, print_team_default, "^4%s^1 Nem tudsz eladni^3 0.01$ ^1alatt!", CHATPREFIX)
		client_cmd(id, "messagemode DOLLAR_AR")
		return PLUGIN_HANDLED;
	}
	f_Player[id][SetCost] = iErtek;
	openSellMenu(id);
	return PLUGIN_HANDLED;
}
public bomb_planted(id) 
{
	f_Player[id][EXP] += random_float(getEXP_HS_Min, getEXP_HS_Max)
	f_Player[id][eELO] += random_num(getELOPoints_HS_Min, getELOPoints_HS_Max)
	client_cmd(0, "spk herboynew/panted")
	client_print_color(0, print_team_default, "%s^1 ^3%s ^1élesítette a bombát.", CHATPREFIX, sm_PlayerName[id]);
	SetReward(id, 1, 0, 0, 40)
}
public bomb_defused(id) 
{
	f_Player[id][EXP] += random_float(getEXP_HS_Min, getEXP_HS_Max)
	f_Player[id][eELO] += random_num(getELOPoints_HS_Min, getELOPoints_HS_Max)
	client_print_color(0, print_team_default, "%s^1 ^3%s ^1hatástalanította a bombát.", CHATPREFIX, sm_PlayerName[id]);
	SetReward(id, 2, 0, 0, 40)
}
stock WeaponColorHandler(WeaponAllapot)
{
	new ReturnString[8]

	if(WeaponAllapot == 101)
		copy(ReturnString, charsmax(ReturnString), "\y")
	else if(WeaponAllapot < 11)
		copy(ReturnString, charsmax(ReturnString), "\r")
	else
		copy(ReturnString, charsmax(ReturnString), "\w")

	return ReturnString;
}
public WeaponMenu(id)
{
	if(!is_user_connected(id))
		return;
	if(f_Player[id][Buyed]){
		client_print_color(id, print_team_default, "^4%s ^1Ebben a körben már választottál fegyvert!", CHATPREFIX);
		return;
	}
	new menu = menu_create("\r[~|HerBoy|~] \wFegyvermenü", "handler");
	if(!f_Player[id][OldStyleWeaponMenu])
	{
		if(f_Player[id][isDead])
		{
			give_item(id, "weapon_knife");
			menu_additem(menu, "\dNem kérek fegyvert!^n", "-2", ADMIN_ADMIN);
		}
		else
			menu_additem(menu, "\dNem kérek fegyvert!^n", "-2");
	}
	else give_item(id, "weapon_knife");

	if(gInventory[id][Equipment[id][1][1]][isNameTaged])
		menu_additem(menu, fmt("%sM4A1 | ^"%s^"", WeaponColorHandler(gInventory[id][Equipment[id][1][1]][Allapot]), gInventory[id][Equipment[id][1][1]][Nametag]), "1", 0);
	else 
		menu_additem(menu, fmt("%sM4A1 | %s", WeaponColorHandler(gInventory[id][Equipment[id][1][1]][Allapot]), FegyverInfo[Equipment[id][1][0]][wname]), "1", 0);

	if(gInventory[id][Equipment[id][0][1]][isNameTaged])
		menu_additem(menu, fmt("%sAK47 | ^"%s^"", WeaponColorHandler(gInventory[id][Equipment[id][0][1]][Allapot]), gInventory[id][Equipment[id][0][1]][Nametag]), "2", 0);
	else 
		menu_additem(menu, fmt("%sAK47 | %s", WeaponColorHandler(gInventory[id][Equipment[id][0][1]][Allapot]), FegyverInfo[Equipment[id][0][0]][wname]), "2", 0);

	if(gInventory[id][Equipment[id][2][1]][isNameTaged])
		menu_additem(menu, fmt("%sAWP | ^"%s^"", WeaponColorHandler(gInventory[id][Equipment[id][2][1]][Allapot]), gInventory[id][Equipment[id][2][1]][Nametag]), "3", 0);
	else 
		menu_additem(menu, fmt("%sAWP | %s", WeaponColorHandler(gInventory[id][Equipment[id][2][1]][Allapot]), FegyverInfo[Equipment[id][2][0]][wname]), "3", 0);	

	if(gInventory[id][Equipment[id][M249][1]][isNameTaged])
		menu_additem(menu, fmt("%sM249 | ^"%s^"", WeaponColorHandler(gInventory[id][Equipment[id][M249][1]][Allapot]), gInventory[id][Equipment[id][M249][1]][Nametag]), "4", 0);
	else 
		menu_additem(menu, fmt("%sM249 | %s", WeaponColorHandler(gInventory[id][Equipment[id][M249][1]][Allapot]), FegyverInfo[Equipment[id][M249][0]][wname]), "4", 0);	

	menu_additem(menu, "AUG", "5", 0);
	if(f_Player[id][OldStyleWeaponMenu])
	{
		if(gInventory[id][Equipment[id][FAMAS][1]][isNameTaged])
			menu_additem(menu, fmt("%sFAMAS | ^"%s^"", WeaponColorHandler(gInventory[id][Equipment[id][FAMAS][1]][Allapot]), gInventory[id][Equipment[id][FAMAS][1]][Nametag]), "6", 0);
		else 
			menu_additem(menu, fmt("%sFAMAS | %s", WeaponColorHandler(gInventory[id][Equipment[id][FAMAS][1]][Allapot]), FegyverInfo[Equipment[id][FAMAS][0]][wname]), "6", 0);	

		if(gInventory[id][Equipment[id][GALIL][1]][isNameTaged])
			menu_additem(menu, fmt("%sGALIL | ^"%s^"^n^n\wKés: \r%s%s%s", WeaponColorHandler(gInventory[id][Equipment[id][GALIL][1]][Allapot]), gInventory[id][Equipment[id][GALIL][1]][Nametag], WeaponColorHandler(gInventory[id][Equipment[id][4][1]][Allapot]), FegyverInfo[Equipment[id][4][0]][MenuWeapon], FegyverInfo[gInventory[id][Equipment[id][4][1]][w_id]][wname]), "7", 0);
		else 
			menu_additem(menu, fmt("%sGALIL | %s^n^n\wKés: \r%s%s%s", WeaponColorHandler(gInventory[id][Equipment[id][GALIL][1]][Allapot]), FegyverInfo[Equipment[id][GALIL][0]][wname], WeaponColorHandler(gInventory[id][Equipment[id][4][1]][Allapot]), FegyverInfo[Equipment[id][4][0]][MenuWeapon], FegyverInfo[gInventory[id][Equipment[id][4][1]][w_id]][wname]), "7", 0);	
	}
	else
	{
		if(gInventory[id][Equipment[id][FAMAS][1]][isNameTaged])
			menu_additem(menu, fmt("%sFAMAS | ^"%s^"^n^n\wKés: \r%s%s%s", WeaponColorHandler(gInventory[id][Equipment[id][FAMAS][1]][Allapot]), gInventory[id][Equipment[id][FAMAS][1]][Nametag], WeaponColorHandler(gInventory[id][Equipment[id][4][1]][Allapot]), FegyverInfo[Equipment[id][4][0]][MenuWeapon], FegyverInfo[gInventory[id][Equipment[id][4][1]][w_id]][wname]), "6", 0);
		else 
			menu_additem(menu, fmt("%sFAMAS | %s^n^n\wKés: \r%s%s%s", WeaponColorHandler(gInventory[id][Equipment[id][FAMAS][1]][Allapot]), FegyverInfo[Equipment[id][FAMAS][0]][wname], WeaponColorHandler(gInventory[id][Equipment[id][4][1]][Allapot]), FegyverInfo[Equipment[id][4][0]][MenuWeapon], FegyverInfo[gInventory[id][Equipment[id][4][1]][w_id]][wname]), "6", 0);	

		if(gInventory[id][Equipment[id][GALIL][1]][isNameTaged])
			menu_additem(menu, fmt("%sGALIL | ^"%s^"", WeaponColorHandler(gInventory[id][Equipment[id][GALIL][1]][Allapot]), gInventory[id][Equipment[id][GALIL][1]][Nametag]), "7", 0);
		else 
			menu_additem(menu, fmt("%sGALIL | %s", WeaponColorHandler(gInventory[id][Equipment[id][GALIL][1]][Allapot]), FegyverInfo[Equipment[id][GALIL][0]][wname]), "7", 0);	
	}

	if(gInventory[id][Equipment[id][MP5][1]][isNameTaged])
		menu_additem(menu, fmt("%sMP5 | ^"%s^"", WeaponColorHandler(gInventory[id][Equipment[id][MP5][1]][Allapot]), gInventory[id][Equipment[id][MP5][1]][Nametag]), "8", 0);
	else 
		menu_additem(menu, fmt("%sMP5 | %s", WeaponColorHandler(gInventory[id][Equipment[id][MP5][1]][Allapot]), FegyverInfo[Equipment[id][MP5][0]][wname]), "8", 0);	

	if(gInventory[id][Equipment[id][XM1014][1]][isNameTaged])
		menu_additem(menu, fmt("%sXM1014 | ^"%s^"", WeaponColorHandler(gInventory[id][Equipment[id][XM1014][1]][Allapot]), gInventory[id][Equipment[id][XM1014][1]][Nametag]), "9", 0);
	else 
		menu_additem(menu, fmt("%sXM1014 | %s", WeaponColorHandler(gInventory[id][Equipment[id][XM1014][1]][Allapot]), FegyverInfo[Equipment[id][XM1014][0]][wname]), "9", 0);	

	if(gInventory[id][Equipment[id][M3][1]][isNameTaged])
		menu_additem(menu, fmt("%sM3 | ^"%s^"", WeaponColorHandler(gInventory[id][Equipment[id][M3][1]][Allapot]), gInventory[id][Equipment[id][M3][1]][Nametag]), "10", 0);
	else 
		menu_additem(menu, fmt("%sM3 | %s", WeaponColorHandler(gInventory[id][Equipment[id][M3][1]][Allapot]), FegyverInfo[Equipment[id][M3][0]][wname]), "10", 0);	

	if(gInventory[id][Equipment[id][SCOUT][1]][isNameTaged])
		menu_additem(menu, fmt("%sSCOUT | ^"%s^"", WeaponColorHandler(gInventory[id][Equipment[id][SCOUT][1]][Allapot]), gInventory[id][Equipment[id][SCOUT][1]][Nametag]), "11", 0);
	else 
		menu_additem(menu, fmt("%sSCOUT | %s", WeaponColorHandler(gInventory[id][Equipment[id][SCOUT][1]][Allapot]), FegyverInfo[Equipment[id][SCOUT][0]][wname]), "11", 0);	

	menu_additem(menu, "MAC 10", "12", 0);

	if(gInventory[id][Equipment[id][TMP][1]][isNameTaged])
		menu_additem(menu, fmt("%sTMP | ^"%s^"", WeaponColorHandler(gInventory[id][Equipment[id][TMP][1]][Allapot]), gInventory[id][Equipment[id][TMP][1]][Nametag]), "13", 0);
	else 
		menu_additem(menu, fmt("%sTMP | %s", WeaponColorHandler(gInventory[id][Equipment[id][TMP][1]][Allapot]), FegyverInfo[Equipment[id][TMP][0]][wname]), "13", 0);	
	
	if(gInventory[id][Equipment[id][P90][1]][isNameTaged])
		menu_additem(menu, fmt("%sP90 | ^"%s^"", WeaponColorHandler(gInventory[id][Equipment[id][P90][1]][Allapot]), gInventory[id][Equipment[id][P90][1]][Nametag]), "15", 0);
	else 
		menu_additem(menu, fmt("%sP90 | %s", WeaponColorHandler(gInventory[id][Equipment[id][P90][1]][Allapot]), FegyverInfo[Equipment[id][P90][0]][wname]), "15", 0);	

	menu_additem(menu, "UMP", "14", 0);
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);

	menu_setprop(menu, MPROP_NEXTNAME, fmt("%L", id, "GENERAL_MENU_NEXT"));
	menu_setprop(menu, MPROP_BACKNAME, fmt("%L", id, "GENERAL_MENU_BACK"));
	menu_setprop(menu, MPROP_EXITNAME, fmt("%L", id, "GENERAL_MENU_EXIT"));
	menu_display(id, menu);
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

	if(f_Player[id][Buyed])
		return PLUGIN_HANDLED;

	new bool:gotweapon = true;
	if(key != -2)
	{
		rg_drop_items_by_slot(id, PRIMARY_WEAPON_SLOT)
	}
	switch(key)
	{
		case -2:
		{
			rg_instant_reload_weapons(id, 0)
			client_print_color(id, print_team_default, "^4%s^1 Nem kértél fegyvert!", CHATPREFIX);
		}
		case 1:
		{
			cs_set_user_bpammo(id,CSW_M4A1, 3*AMMO_556NATO_BUY);
			give_item(id, "weapon_m4a1");
			client_print_color(id, print_team_default, "^4%s^1 Kaptál egy ^3M4A1^1 fegyvert!", CHATPREFIX);
		}
		case 2:
		{
			cs_set_user_bpammo(id,CSW_AK47, 3*AMMO_762NATO_BUY);
			give_item(id, "weapon_ak47");
			client_print_color(id, print_team_default, "^4%s^1 Kaptál egy ^3AK47^1 fegyvert!", CHATPREFIX);
		}
		case 3:
		{
			new CsTeams:userTeam = cs_get_user_team(id);
			new Players[32], iNum;
			new tt_num = 0;
			new ct_num = 0;
			new limitnum = 1;
			get_players(Players, iNum, "h");
			for(new i=0;i<iNum;i++)
			{
				if(cs_get_user_team(Players[i])==CS_TEAM_T)
					{tt_num++;}
				else if(cs_get_user_team(Players[i])==CS_TEAM_CT)
					{ct_num++;}
			}

			if(tt_num >= 7 && ct_num >= 7)
				limitnum = 2;
			else if(tt_num >= 14 && ct_num >= 14)
				limitnum = 3;

			if (tt_num >=4 && ct_num >= 4)
			{
				if(userTeam == CS_TEAM_CT)
				{
					if(gWPCT < limitnum)
					{
						cs_set_user_bpammo(id,CSW_AWP, 3*AMMO_338MAG_BUY);
						give_item(id, "weapon_awp");
						client_print_color(id, print_team_default, "^4%s^1 Kaptál egy ^3AWP^1 fegyvert!", CHATPREFIX);
						gWPCT++;
					}
					else
					{
						gotweapon = false;
						client_print_color(id, print_team_default, "^4%s^1 Jelenleg csak^3 %i^1 ember ^4AWP^1-zhet csapatonként!", CHATPREFIX, limitnum);
						WeaponMenu(id);
					}
				}
				if(userTeam == CS_TEAM_T)
				{
					if(gWPTE < limitnum)
					{
						
						cs_set_user_bpammo(id,CSW_AWP, 3*AMMO_338MAG_BUY);
						give_item(id, "weapon_awp"); 
						client_print_color(id, print_team_default, "^4%s^1 Kaptál egy ^3AWP^1 fegyvert!", CHATPREFIX);
						gWPTE++;
					}
					else
					{
						gotweapon = false;
						client_print_color(id, print_team_default, "^4%s^1 Jelenleg csak^3 %i^1 ember ^4AWP^1-zhet csapatonként!", CHATPREFIX, limitnum);
						WeaponMenu(id);
					}
				}
			}
			else
			{
				gotweapon = false;
				client_print_color(id, print_team_default, "^4%s^1 Csak^3 4v4^1-től választhatod az ^3AWP Csomagot^1!", CHATPREFIX);
				WeaponMenu(id);
			}
		}
		case 4:
		{
			cs_set_user_bpammo(id,CSW_M249, 3*AMMO_556NATOBOX_BUY);
			give_item(id, "weapon_m249");
			client_print_color(id, print_team_default, "^4%s^1 Kaptál egy ^3MachineGun^1 fegyvert!", CHATPREFIX);
		}  
		case 5:
		{
			cs_set_user_bpammo(id,CSW_AUG, 3*AMMO_556NATO_BUY);
			give_item(id, "weapon_aug");
			client_print_color(id, print_team_default, "^4%s^1 Kaptál egy ^3AUG^1 fegyvert!", CHATPREFIX);
		}
		case 6:
		{
			cs_set_user_bpammo(id,CSW_FAMAS, 3*AMMO_556NATO_BUY);
			give_item(id, "weapon_famas");
			client_print_color(id, print_team_default, "^4%s^1 Kaptál egy ^3Famas^1 fegyvert!", CHATPREFIX);
		}
		case 7:
		{
			cs_set_user_bpammo(id,CSW_GALIL, 3*AMMO_556NATO_BUY);
			give_item(id, "weapon_galil");
			client_print_color(id, print_team_default, "^4%s^1 Kaptál egy ^3Galil^1 fegyvert!", CHATPREFIX);
		}
		case 8:
		{
			cs_set_user_bpammo(id,CSW_MP5NAVY, 3*AMMO_9MM_BUY);		
			give_item(id, "weapon_mp5navy");
			client_print_color(id, print_team_default, "^4%s^1 Kaptál egy ^3SMG^1 fegyvert!", CHATPREFIX);
		}
		case 9:
		{
			cs_set_user_bpammo(id,CSW_XM1014, 3*AMMO_BUCKSHOT_BUY);		
			give_item(id, "weapon_xm1014");
			client_print_color(id, print_team_default, "^4%s^1 Kaptál egy ^3AutoShotgun^1 fegyvert!", CHATPREFIX);
		}
		case 10:
		{
			cs_set_user_bpammo(id,CSW_M3, 3*AMMO_BUCKSHOT_BUY);
			give_item(id, "weapon_m3");
			client_print_color(id, print_team_default, "^4%s^1 Kaptál egy ^3Shotgun^1 fegyvert!", CHATPREFIX);
		}
		case 11:
		{
			cs_set_user_bpammo(id,CSW_SCOUT, 3*AMMO_762NATO_BUY);		
			give_item(id, "weapon_scout");
			client_print_color(id, print_team_default, "^4%s^1 Kaptál egy ^3Scout^1 fegyvert!", CHATPREFIX);
		}
		case 12:
		{
			cs_set_user_bpammo(id,CSW_MAC10, 100);		
			give_item(id, "weapon_mac10");
			client_print_color(id, print_team_default, "^4%s^1 Kaptál egy ^3Pityókahámozó^1 fegyvert!", CHATPREFIX);
		}
		case 13:
		{
			cs_set_user_bpammo(id,CSW_TMP, 3*AMMO_9MM_BUY);		
			give_item(id, "weapon_tmp");
			client_print_color(id, print_team_default, "^4%s^1 Kaptál egy ^3Pityókahámozó^1 fegyvert!", CHATPREFIX);
		}
		case 14:
		{
			cs_set_user_bpammo(id,CSW_UMP45, 100);		
			give_item(id, "weapon_ump45");
			client_print_color(id, print_team_default, "^4%s^1 Kaptál egy ^3Kávédaráló^1 fegyvert!", CHATPREFIX);
		}
		case 15:
		{
			cs_set_user_bpammo(id,CSW_P90, 2*AMMO_57MM_BUY);		
			give_item(id, "weapon_p90");
			client_print_color(id, print_team_default, "^4%s^1 Kaptál egy ^3P90^1 fegyvert!", CHATPREFIX);
		}
	}
	
	if(gotweapon)
	{
		give_player_grenades(id);

		give_item(id, "item_assaultsuit");//item_assaultsuit
		set_user_armor(id, 30);
		if(key != -2)
		{
			PistolMenu(id);
		}
		f_Player[id][Buyed] = 1;
	}
	return PLUGIN_HANDLED;
}
public PistolMenu(id)
{
	if(!is_user_connected(id))
		return;

	new menu = menu_create("\r[~|HerBoy|~] \wPisztoly Menü", "PistolHandler");

	if(gInventory[id][Equipment[id][15][1]][isNameTaged])
		menu_additem(menu, fmt("%sUSP | ^"%s^"", WeaponColorHandler(gInventory[id][Equipment[id][15][1]][Allapot]), gInventory[id][Equipment[id][15][1]][Nametag]), "1", 0);
	else 
		menu_additem(menu, fmt("%sUSP | %s", WeaponColorHandler(gInventory[id][Equipment[id][15][1]][Allapot]), FegyverInfo[Equipment[id][15][0]][wname]), "1", 0);

	if(gInventory[id][Equipment[id][3][1]][isNameTaged])
		menu_additem(menu, fmt("%sDEAGLE | ^"%s^"", WeaponColorHandler(gInventory[id][Equipment[id][3][1]][Allapot]), gInventory[id][Equipment[id][3][1]][Nametag]), "2", 0);
	else 
		menu_additem(menu, fmt("%sDEAGLE | %s", WeaponColorHandler(gInventory[id][Equipment[id][3][1]][Allapot]), FegyverInfo[Equipment[id][3][0]][wname]), "2", 0);

	if(gInventory[id][Equipment[id][14][1]][isNameTaged])
		menu_additem(menu, fmt("%sGLOCK18 | ^"%s^"", WeaponColorHandler(gInventory[id][Equipment[id][14][1]][Allapot]), gInventory[id][Equipment[id][14][1]][Nametag]), "3", 0);
	else 
		menu_additem(menu, fmt("%sGLOCK18 | %s", WeaponColorHandler(gInventory[id][Equipment[id][14][1]][Allapot]), FegyverInfo[Equipment[id][14][0]][wname]), "3", 0);	

	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);

	menu_setprop(menu, MPROP_NEXTNAME, fmt("%L", id, "GENERAL_MENU_NEXT"));
	menu_setprop(menu, MPROP_BACKNAME, fmt("%L", id, "GENERAL_MENU_BACK"));
	menu_setprop(menu, MPROP_EXITNAME, fmt("%L", id, "GENERAL_MENU_EXIT"));
	menu_display(id, menu);
}
public PistolHandler(id, menu, item)
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
	rg_drop_items_by_slot(id, PISTOL_SLOT)

	switch(key)
	{
		case 1:
		{
			cs_set_user_bpammo(id,CSW_USP, 100);
			give_item(id, "weapon_usp");
			client_print_color(id, print_team_default, "^4%s^1 Kaptál egy ^3USP^1 fegyvert!", CHATPREFIX);
		}
		case 2:
		{
			cs_set_user_bpammo(id,CSW_DEAGLE,50);
			give_item(id, "weapon_deagle");
			client_print_color(id, print_team_default, "^4%s^1 Kaptál egy ^3DEAGLE^1 fegyvert!", CHATPREFIX);
		}
		case 3:
		{
			cs_set_user_bpammo(id,CSW_GLOCK18, 120);
			give_item(id, "weapon_glock18");
			client_print_color(id, print_team_default, "^4%s^1 Kaptál egy ^3GLOCK18^1 fegyvert!", CHATPREFIX);
		}
	}
	rg_instant_reload_weapons(id, 0)
	return PLUGIN_HANDLED;
}

stock give_player_grenades(index)
{
	new String[64], len;
	give_item(index, "weapon_hegrenade");
	give_item(index, "weapon_flashbang");
	give_item(index, "weapon_smokegrenade");
	give_item(index, "item_thighpack");
	if(f_Player[index][isVip] == 1)
	{
		give_item(index, "weapon_flashbang");
	}
	if(cs_get_user_team(index) == CS_TEAM_CT)
		len += formatex(String[len], charsmax(String) - len, ", Hatástalanítókészlet, Heal Gránát");

	client_print_color(index, print_team_default, "^4%s^1 Kaptál egy ^3Gránátot, %sFlash%s^1-(t)et.", CHATPREFIX, f_Player[index][isVip] == 1 ? "+2" : "", String);

	f_Player[index][isDead] = 0;

}
public Set_Permissions(id){
	new Flags;
	Flags = read_flags(Admin_Permissions[get_user_adminlvl(id)][1]);
	set_user_flags(id, Flags);
}

public client_disconnected(id)
{
	sm_PlayerName[id][0] = EOS;
	new sTime[64];
	formatCurrentDateAndTime(sTime, charsmax(sTime));

	if(!sk_get_logged(id) || !is_user_connected(id))
		return;

	QueryUpdateUserDatas(id);
	QueryUpdateCaseDatas(id);
	QueryUpdateQuestData(id);

	for(new i = 0; i < 16; i++)
	{
		if(is_user_connected(id))
			weapon_deteriorate(id, i, GetWeaponEntById(i));
		UpdateItem(id, 8, Equipment[id][i][1], 0)
	}

	ArrayClear(g_Buy[id]);
	ArrayClear(g_Credit[id]);
	//TODO INV CLEAR
}
new TempAccountRow[33] = 0;
public Load_User_Data(id)
{
	new sTime[64];
	formatCurrentDateAndTime(sTime, charsmax(sTime));
	f_Player[id][a_UserId] = sk_get_accountid(id);

	Load_Data(id, "datas", "QueryLoadAccountDatas")
}
public Load_Data(id, Table_Name[], ForwardMetod[])
{
	new Query[2048]
	new Data[2];

	Data[0] = id;
	Data[1] = get_user_userid(id)

	if(equali(Table_Name, "__syn_payments"))
		formatex(Query, charsmax(Query), "SELECT * FROM `%s` WHERE comment = ^"%d^";", Table_Name, f_Player[id][a_UserId])
	else
		formatex(Query, charsmax(Query), "SELECT * FROM `%s` WHERE aid = ^"%d^";", Table_Name, f_Player[id][a_UserId])

	new sTime[64];
	formatCurrentDateAndTime(sTime, charsmax(sTime));
	SQL_ThreadQuery(m_get_sql(), ForwardMetod, Query, Data, 2);
}

public QueryLoadAccountDatas(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime){
	new id = Data[0];
	if(Data[1] != get_user_userid(id))
		return;
		
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) {
		log_amx("%s", Error);
		new sTime[64];
		formatCurrentDateAndTime(sTime, charsmax(sTime));
		SendToAdmins(fmt("^3[Error-LoadAccount(#%i)] ^4%s", f_Player[id][a_UserId], Error))
		return;
	}

		
	if(SQL_NumRows(Query) > 0)
	{
		SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Dollar"), f_Player[id][Dollar]);
		f_Player[id][GepeszKesztyu] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "GepeszKesztyu"));
		f_Player[id][NametagTool] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "NametagTool"));
		f_Player[id][StatTrakTool] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "StatTrakTool"));
		f_Player[id][ScreenEffect] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "ScreenEffect"));
		f_Player[id][Toredek] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Toredek"));
		f_Player[id][Skins] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Skins"));
		f_Player[id][FirstJoin] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "FirstJoin"));
		f_Player[id][Huds] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Hud"));
		f_Player[id][WeaponHud] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "WeaponHud"));
		f_Player[id][DisplayAdmin] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "DisplayAdmin"));
		f_Player[id][s_kill] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Kills"));
		f_Player[id][s_death] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Death"));
		f_Player[id][Ajandekcsomagok] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Ajandekcsomag"));
		f_Player[id][s_hs] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "HS"));
		f_Player[id][VipTime] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "VipTime"));
		f_Player[id][Rang] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Rang"));
		f_Player[id][Tolvajkesztyu] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Tolvajkesztyu"));
		f_Player[id][TolvajkesztyuEndTime] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "TolvajkesztyuEndTime"));
		f_Player[id][TorhetetlenitoKeszlet] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "thKeszlet"));
		f_Player[id][OldStyleWeaponMenu] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "OldStyleWeaponMenu"));
		f_Player[id][RecoilControl] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "RecoilControl"));
		f_Player[id][ReviveSprite] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "ReviveSprite"));
		f_Player[id][QuakeS] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "QuakeS"));
		f_Player[id][SpecL] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "SpecL"));
		g_Printstream[id][p_tus] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "p_tus"));
		g_Printstream[id][p_tar] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "p_tar"));
		g_Printstream[id][p_markolat] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "p_markolat"));
		g_PrintstreamVaz[id][1] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "p_1"));
		g_PrintstreamVaz[id][2] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "p_2"));
		g_PrintstreamVaz[id][3] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "p_3"));
		g_PrintstreamVaz[id][4] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "p_4"));
		g_PrintstreamVaz[id][5] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "p_5"));
		f_Player[id][PorgetSys] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "SpinTime"));
		f_Player[id][PorgetASys] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "AdminSpinTime"));
		f_Player[id][modconnid] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "id"));

		SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "EXP"), f_Player[id][EXP]);
		f_Player[id][eELO] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "ELO"));
		f_Player[id][WinnedRound] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "WinnedRound"));
		f_Player[id][iPrivateRank] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "PrivateRank"));
		f_Player[id][iBattlePassPurch] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "BattlePassPurch"));
		f_Player[id][iBattlePassLevel] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "BattlePassLevel"));
		f_Player[id][iSelectedMedal] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "SelectedMedal"));
		f_Player[id][InventoryMaxSize] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Inventory_Size"));

		Ajandekcsomag[id][0] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "iRew0"));
		Ajandekcsomag[id][1] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "iRew1"));
		Ajandekcsomag[id][2] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "iRew2"));
		Ajandekcsomag[id][3] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "iRew3"));
		Ajandekcsomag[id][4] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "iRew4"));
		Ajandekcsomag[id][5] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "iRew5"));

		if(f_Player[id][VipTime] > 0)
			f_Player[id][isVip] = 1;

		f_Player[id][ChatPrefixRemove] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "ChatPrefixRemove"));
		if(f_Player[id][ChatPrefixRemove] == -1)
		{
			f_Player[id][ChatPrefixAdded] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "ChatPrefixAdded"));
			SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "ChatPrefix"), f_Player[id][ChatPrefix], 32);
		}
		else if(get_systime() >= f_Player[id][ChatPrefixRemove])
		{
			f_Player[id][ChatPrefixAdded] = -1;
			f_Player[id][ChatPrefix][0] = EOS;
		}
		else
		{
			f_Player[id][ChatPrefixAdded] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "ChatPrefixAdded"));
			SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "ChatPrefix"), f_Player[id][ChatPrefix], 32);
		}
		if(f_Player[id][FirstJoin] == 1)
		{
			QueryLoadOldDatas_WSS(id)
		}
		Load_Data(id, "case_datas", "QueryLoadCaseDatas")

	}
	else
	{
		TempAccountRow[id] = 0;
		createAccountDatas(id)
	}
}
public QueryLoadCaseDatas(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime){
	new id = Data[0];
	if(Data[1] != get_user_userid(id))
		return;
		
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) {
		log_amx("%s", Error);
		new sTime[64];
		formatCurrentDateAndTime(sTime, charsmax(sTime));
		return;
	}
		
	if(SQL_NumRows(Query) > 0)
	{
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
		Load_Data(id, "buy_datas", "QueryLoadBuyDatas")
		Load_Data(id, "__syn_payments", "QueryLoadCreditDatas")
		//QueryLoadWeapon(id)

	}
}
public QueryLoadBuyDatas(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime){
	new id = Data[0];
	if(Data[1] != get_user_userid(id))
		return;
		
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) {
		log_amx("%s", Error);
		new sTime[64];
		formatCurrentDateAndTime(sTime, charsmax(sTime));
		SendToAdmins(fmt("^3[Error-LoadBuyDatas] ^4%s", Error))
		return;
	}
	new Buy[BuySys]
	if(SQL_NumRows(Query) > 0)
	{
		while(SQL_MoreResults(Query))
		{
			SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "buyname"), Buy[BuyName], 33);
			Buy[BuyCost] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "buycost"));
			SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "buydollar"), Buy[BuyDollar]);
			SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "buytime"), Buy[BuyTime], 32);
			Buy[BuyId] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "aid"));

			ArrayPushArray(g_Buy[id], Buy);
			SQL_NextRow(Query);
		}
	}
}
public QueryLoadCreditDatas(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime){
	new id = Data[0];
	if(Data[1] != get_user_userid(id))
		return;
		
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) {
		log_amx("%s", Error);
		new sTime[64];
		formatCurrentDateAndTime(sTime, charsmax(sTime));
		SendToAdmins(fmt("^3[Error-LoadCreditDatas] ^4%s", Error))
		return;
	}
	new Credit[CreditSys]
	if(SQL_NumRows(Query) > 0)
	{
		while(SQL_MoreResults(Query))
		{
			SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "created"), Credit[CreditTime], 32);
			Credit[CreditAmount] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "amount"));
			Credit[CreditId] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "comment"));
			Credit[CreditBackAdded] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "paymethodid"));

			ArrayPushArray(g_Credit[id], Credit);
			SQL_NextRow(Query);
		}
	}
	Load_Data(id, "kuldetes_new", "QueryLoadQuestDatas")
}
public QueryLoadQuestDatas(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime) {
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) {
		SendToAdmins(fmt("^3[Error-LoadQuestDatas] ^4%s", Error))
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

			QueryLoadWeapon(id)
		}
	}
}
public InsertBuyDatas(id, BuyN[], BuyC, Float:BuyDoll)
{
	new Query[2048]
	new Data[2];

	Data[0] = id;
	Data[1] = get_user_userid(id)

	formatex(Query, charsmax(Query), "INSERT INTO `buy_datas` (`aid`, `buyname`, `buycost`, `buydollar`) VALUES (%d, ^"%s^", %i, %3.2f);", f_Player[id][a_UserId], BuyN, BuyC, BuyDoll);

	SQL_ThreadQuery(m_get_sql(), "QuerySetData_InsertBuyDatas", Query, Data, 2);
	return PLUGIN_HANDLED;
}
public QuerySetData_InsertBuyDatas(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime){
	new id = Data[0];
	if(Data[1] != get_user_userid(id))
		return;
		
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) {
		log_amx("FAIL INSERT STATE ON%s", Error);
		new sTime[64];
		formatCurrentDateAndTime(sTime, charsmax(sTime));
		SendToAdmins(fmt("^3[Error-InsertBuyDatas] ^4%s", Error))
		return;
	}
}
public createAccountDatas(id)
{
	if(TempAccountRow[id] == 3)
	{
		Load_User_Data(id)
		return PLUGIN_HANDLED;
	}
	new Query[2048]
	new Data[2];

	Data[0] = id;
	Data[1] = get_user_userid(id)


	switch(TempAccountRow[id])
	{
		case 0: formatex(Query, charsmax(Query), "INSERT INTO `datas` (`aid`) VALUES (%d);", f_Player[id][a_UserId]);
		case 1: formatex(Query, charsmax(Query), "INSERT INTO `kuldetes_new` (`aid`) VALUES (%d);", f_Player[id][a_UserId]);
		case 2: formatex(Query, charsmax(Query), "INSERT INTO `case_datas` (`aid`) VALUES (%d);", f_Player[id][a_UserId]);
	}
	new sTime[64];
	formatCurrentDateAndTime(sTime, charsmax(sTime));
	SQL_ThreadQuery(m_get_sql(), "QuerySetData_createAccountDatas", Query, Data, 2);
	return PLUGIN_HANDLED;
}
public QuerySetData_createAccountDatas(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime){
	new id = Data[0];
	if(Data[1] != get_user_userid(id))
		return;
		
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) {
		log_amx("FAIL INSERT STATE ON%s", Error);
		new sTime[64];
		formatCurrentDateAndTime(sTime, charsmax(sTime));
		SendToAdmins(fmt("^3[Error-createAccountDatas] ^4%s", Error))
		return;
	}

	TempAccountRow[id]++;
	createAccountDatas(id);
}
public QueryUpdateUserDatas(id){

	new sTime[64];
	formatCurrentDateAndTime(sTime, charsmax(sTime));

	static Query[10048];
	new Len;

	new Data[2];

	Data[0] = id;
	Data[1] = get_user_userid(id)

	Len += formatex(Query[Len], charsmax(Query), "UPDATE `datas` SET ");
	Len += formatex(Query[Len], charsmax(Query)-Len, "Dollar = ^"%.2f^", ", f_Player[id][Dollar]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "GepeszKesztyu = ^"%i^", ", f_Player[id][GepeszKesztyu]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "NametagTool = ^"%i^", ", f_Player[id][NametagTool]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "StatTrakTool = ^"%i^", ", f_Player[id][StatTrakTool]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "ScreenEffect = ^"%i^", ", f_Player[id][ScreenEffect]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "Toredek = ^"%i^", ", f_Player[id][Toredek]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "OldStyleWeaponMenu = ^"%i^", ", f_Player[id][OldStyleWeaponMenu]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "Skins = ^"%i^", ", f_Player[id][Skins]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "FirstJoin = ^"%i^", ", f_Player[id][FirstJoin]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "Hud = ^"%i^", ", f_Player[id][Huds]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "WeaponHud = ^"%i^", ", f_Player[id][WeaponHud]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "Ajandekcsomag = ^"%i^", ", f_Player[id][Ajandekcsomagok]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "DisplayAdmin = ^"%i^", ", f_Player[id][DisplayAdmin]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "VipTime = ^"%i^", ", f_Player[id][VipTime]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "Kills = ^"%i^", ", f_Player[id][s_kill]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "Death = ^"%i^", ", f_Player[id][s_death]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "HS = ^"%i^", ", f_Player[id][s_hs]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "RecoilControl = ^"%i^", ", f_Player[id][RecoilControl]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "ReviveSprite = ^"%i^", ", f_Player[id][ReviveSprite]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "QuakeS = ^"%i^", ", f_Player[id][QuakeS]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "SpecL = ^"%i^", ", f_Player[id][SpecL]);

	Len += formatex(Query[Len], charsmax(Query)-Len, "Tolvajkesztyu = ^"%i^", ", f_Player[id][Tolvajkesztyu]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "TolvajkesztyuEndTime = ^"%i^", ", f_Player[id][TolvajkesztyuEndTime]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "ChatPrefix = ^"%s^", ", f_Player[id][ChatPrefix]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "ChatPrefixAdded = ^"%i^", ", f_Player[id][ChatPrefixAdded]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "ChatPrefixRemove = ^"%i^", ", f_Player[id][ChatPrefixRemove]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "ChatPrefixRemove = ^"%i^", ", f_Player[id][ChatPrefixRemove]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "p_tus = ^"%i^", ", g_Printstream[id][p_tus]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "p_tar = ^"%i^", ", g_Printstream[id][p_tar]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "p_markolat = ^"%i^", ", g_Printstream[id][p_markolat]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "p_1 = ^"%i^", ", g_PrintstreamVaz[id][1]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "p_2 = ^"%i^", ", g_PrintstreamVaz[id][2]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "p_3 = ^"%i^", ", g_PrintstreamVaz[id][3]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "p_4 = ^"%i^", ", g_PrintstreamVaz[id][4]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "p_5 = ^"%i^", ", g_PrintstreamVaz[id][5]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "thKeszlet = ^"%i^", ", f_Player[id][TorhetetlenitoKeszlet]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "SpinTime = ^"%i^", ", f_Player[id][PorgetSys]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "AdminSpinTime = ^"%i^", ", f_Player[id][PorgetASys]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "EXP = ^"%.2f^", ", f_Player[id][EXP]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "ELO = ^"%i^", ", f_Player[id][eELO]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "WinnedRound = ^"%i^", ", f_Player[id][WinnedRound]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "PrivateRank = ^"%i^", ", f_Player[id][iPrivateRank]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "BattlePassPurch = ^"%i^", ", f_Player[id][iBattlePassPurch]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "BattlePassLevel = ^"%i^", ", f_Player[id][iBattlePassLevel]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "SelectedMedal = ^"%i^", ", f_Player[id][iSelectedMedal]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "Inventory_Size = ^"%i^", ", f_Player[id][InventoryMaxSize]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "Rang = ^"%i^" WHERE `aid` =  ^"%d^";", f_Player[id][Rang], f_Player[id][a_UserId]);

	SQL_ThreadQuery(m_get_sql(), "QuerySetData_UpdateAccountDatas", Query, Data, 2);
}
public QuerySetData_UpdateAccountDatas(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime){
	new id = Data[0];
	if(Data[1] != get_user_userid(id))
		return;
		
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) {
		log_amx("FAIL UPDAZTE STATE ON: %s", Error);
		new sTime[64];
		formatCurrentDateAndTime(sTime, charsmax(sTime));
		SendToAdmins(fmt("^3[Error-UpdateAccountDatas] ^4%s", Error))
		return;
	}
}
public QueryUpdateCaseDatas(id){

	new sTime[64];
	formatCurrentDateAndTime(sTime, charsmax(sTime));

	static Query[10048];
	new Len;
	static logQuery[10048];
	new logLen;

	new Data[2];

	Data[0] = id;
	Data[1] = get_user_userid(id)
	
	logLen += formatex(logQuery[logLen], charsmax(logQuery), "UPDATE `case_datas` SET ^n");
	Len += formatex(Query[Len], charsmax(Query), "UPDATE `case_datas` SET ");

	for(new i;i < sizeof(Cases); i++)
	{
		Len += formatex(Query[Len], charsmax(Query)-Len, "Case%d = ^"%i^", ", i, Case[id][i]);
		Len += formatex(Query[Len], charsmax(Query)-Len, "Key%d = ^"%i^", ", i, Key[id][i]);
		logLen += formatex(logQuery[logLen], charsmax(logQuery)-logLen, "Case%d = ^"%i^", ^n", i, Case[id][i]);
		logLen += formatex(logQuery[logLen], charsmax(logQuery)-logLen, "Key%d = ^"%i^", ^n", i, Key[id][i]);
	}
	Len += formatex(Query[Len], charsmax(Query)-Len, "Param = ^"1^" ");
	logLen += formatex(logQuery[logLen], charsmax(logQuery)-logLen, "Param = ^"1^" ");
	logLen += formatex(logQuery[logLen], charsmax(logQuery)-logLen, "WHERE `aid` =  ^"%d^";^n", f_Player[id][a_UserId]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "WHERE `aid` =  ^"%d^";", f_Player[id][a_UserId]);
	
	SQL_ThreadQuery(m_get_sql(), "QueryUpdateCaseData", Query, Data, 2);
}
public QueryUpdateCaseData(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime){
	new id = Data[0];
	if(Data[1] != get_user_userid(id))
		return;
		
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) {
		log_amx("FAIL UPDAZTE CASE STATE ON:%s", Error);
		new sTime[64];
		formatCurrentDateAndTime(sTime, charsmax(sTime));
		SendToAdmins(fmt("^3[Error-UpdateCaseData] ^4%s", Error))
		return;
	}
}
public QueryUpdateQuestData(id){
	static Query[10048];
	new Len;
	
	Len += formatex(Query[Len], charsmax(Query), "UPDATE `kuldetes_new` SET ");
	Len += formatex(Query[Len], charsmax(Query)-Len, "is_Questing = ^"%i^", ", Questing[id][is_Questing]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "PlayerName = ^"%s^", ", sm_PlayerName[id]);
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

	Len += formatex(Query[Len], charsmax(Query)-Len, "WHERE `aid` = ^"%d^";",f_Player[id][a_UserId]);
	
	SQL_ThreadQuery(m_get_sql(), "QuerySetData_Quest", Query);
}
public QuerySetData_Quest(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime)
{
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) 
	{
		log_amx("Error from Quest:");
		log_amx("%s", Error);
		return;
	}
}
/*Item feltöltés SQL
1. FULL INSERT,
2. Nametag,
3. StatTrak,
4. UserID,
5. Equipped,
6. Allapot / Firecount,
7. DELETE,
8. Allapot / Equiped / Firecount*/
public UpdateItem(id, InTheItem, ArrayId, nextuser)
{
	
	new Len;
	new sQuery[2048]
	new Inventory[InventorySystem]
	Inventory = gInventory[id][ArrayId]

	new sTime[64];
	formatCurrentDateAndTime(sTime, charsmax(sTime));

	switch(InTheItem)
	{
		case 1:
		{
			if(Inventory[sqlid] > 0)
				Len += formatex(sQuery[Len], charsmax(sQuery)-Len, "INSERT INTO `inventory` (`w_userid`,`w_id`,`IsNameTaged`,`Nametag`,`IsStatTraked`,`StatTrakKills`,`tradable`,`equiped`,`Allapot`,`sqlid`,`opened`,`openedById`,`openedBy`,`openedfrom`, `is_new`, `firecount`) VALUES (");
			else
				Len += formatex(sQuery[Len], charsmax(sQuery)-Len, "INSERT INTO `inventory` (`w_userid`,`w_id`,`IsNameTaged`,`Nametag`,`IsStatTraked`,`StatTrakKills`,`tradable`,`equiped`,`Allapot`,`opened`,`openedById`,`openedBy`,`openedfrom`, `is_new`, `firecount`) VALUES (");
			Len += formatex(sQuery[Len], charsmax(sQuery)-Len, "%i,", sk_get_accountid(id));
			Len += formatex(sQuery[Len], charsmax(sQuery)-Len, "%i,", Inventory[w_id]);
			Len += formatex(sQuery[Len], charsmax(sQuery)-Len, "%i,", Inventory[isNameTaged]);
			Len += formatex(sQuery[Len], charsmax(sQuery)-Len, "^"%s^",", Inventory[Nametag]);
			Len += formatex(sQuery[Len], charsmax(sQuery)-Len, "%i,", Inventory[isStatTraked]);
			Len += formatex(sQuery[Len], charsmax(sQuery)-Len, "%i,", Inventory[StatTrakKills]);
			Len += formatex(sQuery[Len], charsmax(sQuery)-Len, "%i,", Inventory[tradable]);
			Len += formatex(sQuery[Len], charsmax(sQuery)-Len, "%i,", Inventory[equipped]);
			Len += formatex(sQuery[Len], charsmax(sQuery)-Len, "%i,", Inventory[Allapot]);
			if(Inventory[sqlid] > 0)
				Len += formatex(sQuery[Len], charsmax(sQuery)-Len, "%i,", Inventory[sqlid]);

			Len += formatex(sQuery[Len], charsmax(sQuery)-Len, "%i,", Inventory[opened]);
			Len += formatex(sQuery[Len], charsmax(sQuery)-Len, "%i,", Inventory[openedById]);
			Len += formatex(sQuery[Len], charsmax(sQuery)-Len, "^"%s^", ", Inventory[openedBy]);
			Len += formatex(sQuery[Len], charsmax(sQuery)-Len, "^"%s^", ", Inventory[openedfrom]);
			Len += formatex(sQuery[Len], charsmax(sQuery)-Len, "%i,", Inventory[is_new]);
			Len += formatex(sQuery[Len], charsmax(sQuery)-Len, "%i);", Inventory[firecount]);
		}
		case 2:
		{
			Len += formatex(sQuery[Len], charsmax(sQuery)-Len, "UPDATE `inventory` SET ");
			Len += formatex(sQuery[Len], charsmax(sQuery)-Len, "IsNameTaged = ^"%i^", ", Inventory[isNameTaged]);
			Len += formatex(sQuery[Len], charsmax(sQuery)-Len, "Nametag = ^"%s^" ", Inventory[Nametag]);
			Len += formatex(sQuery[Len], charsmax(sQuery)-Len, "WHERE `sqlid` =	%d;", Inventory[sqlid]);
		}
		case 3:
		{
			Len += formatex(sQuery[Len], charsmax(sQuery)-Len, "UPDATE `inventory` SET ");
			Len += formatex(sQuery[Len], charsmax(sQuery)-Len, "IsStatTraked = ^"%i^", ", Inventory[isStatTraked]);
			Len += formatex(sQuery[Len], charsmax(sQuery)-Len, "StatTrakKills = ^"%i^" ", Inventory[StatTrakKills]);
			Len += formatex(sQuery[Len], charsmax(sQuery)-Len, "WHERE `sqlid` =	%d;", Inventory[sqlid]);
		}
		case 4:
		{
			Len += formatex(sQuery[Len], charsmax(sQuery)-Len, "UPDATE `inventory` SET ");
			Len += formatex(sQuery[Len], charsmax(sQuery)-Len, "w_userid = ^"%i^", ", nextuser);
			Len += formatex(sQuery[Len], charsmax(sQuery)-Len, "is_new = ^"%i^" ", get_systime()+21600);
			Len += formatex(sQuery[Len], charsmax(sQuery)-Len, "WHERE `sqlid` =	%d;", Inventory[sqlid]);
		}
		case 5:
		{
			Len += formatex(sQuery[Len], charsmax(sQuery)-Len, "UPDATE `inventory` SET ");
			Len += formatex(sQuery[Len], charsmax(sQuery)-Len, "Equiped = ^"%i^" ", Inventory[equipped]);
			Len += formatex(sQuery[Len], charsmax(sQuery)-Len, "WHERE `sqlid` =	%d;", Inventory[sqlid]);
		}
		case 6:
		{
			Len += formatex(sQuery[Len], charsmax(sQuery)-Len, "UPDATE `inventory` SET ");
			Len += formatex(sQuery[Len], charsmax(sQuery)-Len, "Allapot = ^"%i^", ", Inventory[Allapot]);
			Len += formatex(sQuery[Len], charsmax(sQuery)-Len, "firecount = ^"%i^" ", Inventory[firecount]);
			Len += formatex(sQuery[Len], charsmax(sQuery)-Len, "WHERE `sqlid` =	%d;", Inventory[sqlid]);
		}
		case 7:
		{
			Len += formatex(sQuery[Len], charsmax(sQuery)-Len, "DELETE FROM `inventory` WHERE `sqlid` = %i;", Inventory[sqlid]);
		}
		case 8:
		{
			Len += formatex(sQuery[Len], charsmax(sQuery)-Len, "UPDATE `inventory` SET ");
			Len += formatex(sQuery[Len], charsmax(sQuery)-Len, "IsStatTraked = ^"%i^", ", Inventory[isStatTraked]);
			Len += formatex(sQuery[Len], charsmax(sQuery)-Len, "StatTrakKills = ^"%i^", ", Inventory[StatTrakKills]);
			Len += formatex(sQuery[Len], charsmax(sQuery)-Len, "Allapot = ^"%i^", ", Inventory[Allapot]);
			Len += formatex(sQuery[Len], charsmax(sQuery)-Len, "Equiped = ^"%i^", ", Inventory[equipped]);
			Len += formatex(sQuery[Len], charsmax(sQuery)-Len, "firecount = ^"%i^" ", Inventory[firecount]);
			Len += formatex(sQuery[Len], charsmax(sQuery)-Len, "WHERE `sqlid` =	%d;", Inventory[sqlid]);
		}
	}
	new Data[3]
	Data[1] = id;
	Data[0] = ArrayId;
	Data[2] = InTheItem;
	SQL_ThreadQuery(m_get_sql(), "QuerySetData_UpdateInventory", sQuery, Data, 3);

}

public QuerySetData_UpdateInventory(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime)
{
	new tempid = Data[1];
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) 
	{
		log_amx("Error from Inventory:");
		log_amx("%s", Error);

		new sTime[64];
		formatCurrentDateAndTime(sTime, charsmax(sTime));
		return;
	}
	new intheitem_ = Data[2]
	if(intheitem_ == 1)
	{
		new getsqlid = SQL_GetInsertId(Query);
		if(gInventory[tempid][Data[0]][sqlid] <= 0)
		{
			gInventory[tempid][Data[0]][sqlid] = getsqlid;
		}
	}
}
#define TASK_OFFSET_IMPORTWSS 712300
#define TASK_OFFSET_IMPORBETA 812400
#define TASK_OFFSET_FINISHLOAD 911200

public QueryLoadWeapon(id)
{
	new Query[2048]
	new Data[1];
	Data[0] = id;
	formatex(Query, charsmax(Query), "SELECT * FROM `inventory` WHERE `w_userid` = %d;", f_Player[id][a_UserId])
	new sTime[64];
	formatCurrentDateAndTime(sTime, charsmax(sTime));
	SQL_ThreadQuery(m_get_sql(), "QueryLoadWeapoDatas", Query, Data, 1);
}
public QueryLoadWeapoDatas(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime) {
	new id = Data[0];
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) {
		log_amx("%s", Error);
		new sTime[64];
		formatCurrentDateAndTime(sTime, charsmax(sTime));
		return PLUGIN_HANDLED;
	}
	else {
		
		if(SQL_NumRows(Query) > 0) 
		{
			new x = 0;
			while(SQL_MoreResults(Query))
			{
				gInventory[id][x][sqlid] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "sqlid"));
				gInventory[id][x][w_id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "w_id"));
				gInventory[id][x][w_userid] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "w_userid"));
				gInventory[id][x][isStatTraked] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "IsStatTraked"));
				gInventory[id][x][StatTrakKills] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "StatTrakKills"));
				gInventory[id][x][isNameTaged] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "IsNameTaged"));
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Nametag"), gInventory[id][x][Nametag], 100);
				gInventory[id][x][Allapot] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Allapot"));
				gInventory[id][x][tradable] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "tradable"));
				gInventory[id][x][equipped] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Equiped"));
				gInventory[id][x][opened] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "opened"));
				gInventory[id][x][firecount] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "firecount"));
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "openedfrom"), gInventory[id][x][openedfrom], 100);
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "openedBy"), gInventory[id][x][openedBy], 100);
				gInventory[id][x][openedById] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "openedById"));
				gInventory[id][x][is_new] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "is_new"));

				if(gInventory[id][x][equipped])
				{
					new WeaponID = GetWeaponIdByEnt(FegyverInfo[gInventory[id][x][w_id]][EntName])
					Equipment[id][WeaponID][0] = gInventory[id][x][w_id]
					Equipment[id][WeaponID][1] = x;
				}

				if(FegyverInfo[gInventory[id][x][w_id]][is_deleted] == 1)
				{
					if(gInventory[id][x][Allapot] == 101)
						gInventory[id][x][Allapot] = -101;
					else
						gInventory[id][x][Allapot] = 0;
				}
				x++;
				f_Player[id][Inventory_Size] = x;
				f_Player[id][InventoryWriteableSize] = x;
				SQL_NextRow(Query);
			}
		}
		if(f_Player[id][FirstJoin] && SQL_NumRows(Query) == 0)
		{
			f_Player[id][FirstJoin] = 0;
			for(new i; i < 16; i++)
				AddToInv(id, 1, f_Player[id][a_UserId], i, 101, 0, 0, 0, "", 0, "DefWWeapon", "Szerver", 0, -1);
		}
		new fwd_loginedreturn;
		ExecuteForward(fwd_logined,fwd_loginedreturn, id);
	}
}

public QueryLoadOldDatas_WSS(id)
{
	new Query[1024]
	new Data[2];
	Data[0] = id;

	client_print_color(id, print_team_default, "^4[IMPORTÁLÁS]^3 ~ ^1A statisztikáid ^3átimportálása^1 a ^4WSS Weapon Pack System^1 modból folyamatban van!")
	client_print_color(id, print_team_default, "^4[IMPORTÁLÁS]^3 ~ ^1A statisztikáid ^3átimportálása^1 a ^4WSS Weapon Pack System^1 modból folyamatban van!")
	formatex(Query, charsmax(Query), "SELECT `iKills`,`iDeaths`,`iHS` FROM `smod_wss` WHERE `aid` = ^"%i^"", f_Player[id][a_UserId])

	SQL_ThreadQuery(m_get_sql(), "QueryGetOldAccountDatas_h_WSS", Query, Data, 1);
}
public QueryGetOldAccountDatas_h_WSS(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime) {
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) {

		log_amx("%s", Error);
		return;
	}
	else {
		new id = Data[0];


		if(SQL_NumRows(Query) > 0) {
			new sKill, sDeath, sHS;
			sKill = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "iKills"));
			sDeath = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "iDeaths"));
			sHS = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "iHS"));

			f_Player[id][s_kill] += sKill;
			f_Player[id][s_death] += sDeath;
			f_Player[id][s_hs] += sHS;
			sk_chat(id, "Beimportáltunk ^4%i^1 ölést, ^4%i^1 halált és ^4%i^1 fejlövést, a ^3WSS Weapon Pack System ^1modból!", sKill, sDeath, sHS)
		}
		else sk_chat(id, "Nem találtunk semmilyen adatot a ^3WSS Weapon Pack System ^1módban!");
		
		QueryLoadOldDatas_BETA(id)
	}
}

public QueryLoadOldDatas_BETA(id)
{
	new Query[1024]
	new Data[2];
	Data[0] = id;

	formatex(Query, charsmax(Query), "SELECT `Kills`,`HS`,`Death` FROM `datas_beta` WHERE `aid` = ^"%i^"", f_Player[id][a_UserId])
	
	SQL_ThreadQuery(m_get_sql(), "QueryGetOldAccountDatas_h_BETA", Query, Data, 1);
}
public QueryGetOldAccountDatas_h_BETA(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime) {
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) {

		log_amx("%s", Error);
		return;
	}
	else {
		new id = Data[0];


		if(SQL_NumRows(Query) > 0) {
			new sKill, sDeath, sHS;
			sKill = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Kills"));
			sDeath = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Death"));
			sHS = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Kills"));

			f_Player[id][s_kill] += sKill;
			f_Player[id][s_death] += sDeath;
			f_Player[id][s_hs] += sHS;
			sk_chat(id, "Beimportáltunk ^4%i^1 ölést, ^4%i^1 halált és ^4%i^1 fejlövést, a ^3MultiMod v6 BETA Test ^1modból!", sKill, sDeath, sHS)
		}
		else sk_chat(id, "Nem találtunk semmilyen adatot a ^3MultiMod v6 BETA Test ^1módban!");
		
	}
}
public AddToInv(id, ServerAdded, userid, weapid, allapota, stattrak, stattrakkills, nametaged, nametag[100], mtradable, wopend[], wwBy[], wAid, wSQLID /*WeapAddolás*/)
{
	new systime_now = get_systime();
	new Inventory[InventorySystem]
	Inventory[sqlid] = wSQLID;
	Inventory[w_userid] = userid
	Inventory[w_id] = weapid
	Inventory[isStatTraked] = stattrak
	Inventory[StatTrakKills] = stattrakkills
	Inventory[isNameTaged] = nametaged
	Inventory[tradable] = mtradable
	Inventory[deleted] = 0
	Inventory[firecount] = 0;
	Inventory[Allapot] = allapota;
	Inventory[changed] = 1;
	Inventory[equipped] = 0;
	Inventory[opened] = systime_now;
	copy(Inventory[openedfrom], 33, wopend)
	copy(Inventory[openedBy], 33, wwBy);
	Inventory[openedById] = wAid;
	
	Inventory[is_new] = get_systime()+21600
	
	if(!ServerAdded)
	{
		if(Inventory[isNameTaged])
			client_print_color(id, print_team_default, "^4%s^1 Kaptál egy ^3%s%s^1 skint a(z) inventorydba, ^4%s^1 fegyverre.", CHATPREFIX, Inventory[isStatTraked] ? "StatTrak*" : "", Inventory[Nametag], FegyverInfo[Inventory[w_id]][ChatWeapon])
		else
			client_print_color(id, print_team_default, "^4%s^1 Kaptál egy ^3%s%s^1 skint a(z) inventorydba, ^4%s^1 fegyverre.", CHATPREFIX, Inventory[isStatTraked] ? "StatTrak*" : "", FegyverInfo[Inventory[w_id]][wname], FegyverInfo[Inventory[w_id]][ChatWeapon]) 
	}
	if(weapid < 16)
	{
		new WeaponID = GetWeaponIdByEnt(FegyverInfo[Inventory[w_id]][EntName])
		Inventory[equipped] = 1;
		Inventory[tradable] = 0;
		Equipment[id][WeaponID][0] = Inventory[w_id];
		Equipment[id][WeaponID][1] = f_Player[id][InventoryWriteableSize];
	}
	gInventory[id][f_Player[id][InventoryWriteableSize]] = Inventory;
	UpdateItem(id, 1, f_Player[id][InventoryWriteableSize], 0)
	smlog(id, 0, 0, "ADD_WEAPON", "none", fmt("[%s %s] ~ OpenTime: %i | WeaponID: %i | Tradable: %i | Durability: %i | StatTraked: %i ~ OpenedFrom: %s", FegyverInfo[Inventory[w_id]][wname], FegyverInfo[Inventory[w_id]][ChatWeapon], systime_now, Inventory[w_id], Inventory[tradable], Inventory[Allapot], Inventory[isStatTraked], Inventory[openedfrom]))
	f_Player[id][InventoryWriteableSize]++;
	f_Player[id][Inventory_Size]++;
}
public Hook_Say(id){
	new Message[512], Status[16], String[256];

	new cmd[21], bool:is_team = false;
	read_argv(0,cmd,20);
	if(equal(cmd,"say_team"))
		is_team = true;

	read_args(Message, charsmax(Message));
	remove_quotes(Message);
	if(Message[0] == '@' || equal (Message, "") || Message[0] == '/')
		return PLUGIN_HANDLED;
	if(cs_get_user_team(id) == CS_TEAM_SPECTATOR)
		Status = "*SPEC* ";
	else if(!is_user_alive(id))
		Status = "*Halott* ";

	new len, adminlen, viplen;
	
	if(is_team)
		len += formatex(String[len], charsmax(String)-len, "^1(csapat) %s", Status);
	else
		len += formatex(String[len], charsmax(String)-len, "^1%s", Status);

	new VipString[64], AdminString[128]

	if(f_Player[id][isVip] == 1 && (get_user_adminlvl(id) == 0 || f_Player[id][DisplayAdmin] == 0))
		viplen += formatex(VipString[viplen], charsmax(VipString) - viplen, " ^1| ^4PVIP^3");
		
	if (sk_get_logged(id))
	{
    // ChatPrefix megjelenítése csak a megfelelő feltételek mellett
    if (strlen(f_Player[id][ChatPrefix]) > 0 && 
        (get_user_adminlvl(id) == 0 || (get_user_adminlvl(id) > 0 && f_Player[id][DisplayAdmin] == 0)))
    {
        adminlen += formatex(AdminString[adminlen], charsmax(AdminString) - adminlen, "^4%s ^1| ", f_Player[id][ChatPrefix]);
    }

    // Admin rang megjelenítése, ha DisplayAdmin aktív
    if (get_user_adminlvl(id) > 0 && f_Player[id][DisplayAdmin] == 1)
    {
        adminlen += formatex(AdminString[adminlen], charsmax(AdminString) - adminlen, "^4%s ^1| ", Admin_Permissions[get_user_adminlvl(id)][0]);
    }

    // A teljes formázott string összeállítása
    len += formatex(String[len], charsmax(String) - len, "^3[^4%s^4%s^4%s^3] ^1» ", AdminString, Rangok[f_Player[id][Rang]][RangName], VipString);

    // Név színének megjelenítése VIP vagy admin státusz alapján
    if (f_Player[id][isVip] == 1 || (get_user_adminlvl(id) > 0 && f_Player[id][DisplayAdmin] == 1))
    {
        len += formatex(String[len], charsmax(String) - len, "^3%s:^4", sm_PlayerName[id]);
    }
    else
    {
        len += formatex(String[len], charsmax(String) - len, "^3%s:^1", sm_PlayerName[id]);
    }
}

	else
		len += formatex(String[len], charsmax(String)-len, "^4[Vendég] ^1» ^3%s:^1", sm_PlayerName[id]);

	format(Message, charsmax(Message), "%s %s", String, Message);

	for(new i; i < 33; i++){
		if(!is_user_connected(i))
			continue;
		if(is_team && cs_get_user_team(id) != cs_get_user_team(i))
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
			client_print_color(id, print_team_default, "^4%s ^1%s",CHATPREFIX, NoMatchText);
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
public plugin_end()
{
	ArrayDestroy(g_Market)
}

public plugin_cfg()
{
	LoadMarket();
}
public SendToAdmins(const sText[])
{

}
public CheckMedal(id, sm_State)
{
	switch(sm_State)
	{
		case 1:
		{
			if(sk_get_playtime(id) > 7776000)
				AddMedal(id, 11)

			if(sk_get_playtime(id) > 1209600)
				AddMedal(id, 2)

			if(sk_get_playtime(id) > 2592000)
				AddMedal(id, 26)
		}
		case 2:
		{
			// reg_unix + one_year < get_systime
			new pure_regdate[33], reg_unix;
			sk_get_RegisterDate(id, pure_regdate, 32);

			reg_unix = parse_time(pure_regdate, "%Y-%m-%d %H:%M:%S")

			if(reg_unix+(31557600) < get_systime())
				AddMedal(id, 12)

			if(reg_unix+(31557600*2) < get_systime())
				AddMedal(id, 13)

			if(reg_unix+(31557600*3) < get_systime())
				AddMedal(id, 14)

			//1645291160
		}
		case 3:
		{
			if(f_Player[id][modconnid] < 101)
				AddMedal(id, 3)
		}
	}
}
public AddMedal(id, MedalId)
{
	if(Medal[id][MedalId][medal_collected])
		return;

	if(f_Player[id][iSelectedMedal] == 0)
		f_Player[id][iSelectedMedal] = MedalId;

	Medal[id][MedalId][medal_collected] = 1;
	Medal[id][MedalId][medal_collectedsys] = get_systime();

	//tudom, hogy furán néz ki de a mindenkinek üzenet és a sk_chat_lang müködése miatt van fura sorrend
	sk_chat_lang("^4%s^1 megszerezte a(z) ^4%L^1 érdemérmet.", cMedals[MedalId][MedalName], sm_PlayerName[id]);
}
public InventoryCanAdd(id, InvFullText[], InvNeedNum)
{
  if(!((f_Player[id][InventoryWriteableSize]) < InventoryMAX))
  {
    server_cmd("amx_kick ^"%s^" ^"Inventory bug, csatlakozz újra.^"", sm_PlayerName[id]);
    return -1;
  }
  else if(!(f_Player[id][Inventory_Size]+InvNeedNum < f_Player[id][InventoryMaxSize]))
  {
    if(InvFullText[0] != EOS)
      sk_chat(id, "^1%s",InvFullText);
    return 0;
  }
  else
  {
    return 1;
  }
}
public npc_erint(ent, id)
{
	if(f_Player[id][NPCTouch])
		return PLUGIN_HANDLED
	client_print_color(id, print_chat, "^4[^1~^3|^4HerBoy^3|^1~^4] ^3» ^3Hozzáértél ^1a ^4Játékgép^1-hez!")
	f_Player[id][NPCTouch] = true

	openSzerencsejatek(id)
	set_task(40.0, "npc_ujra", id)
	return PLUGIN_HANDLED
}
public npc_ujra(id)
{
	f_Player[id][NPCTouch] = false
}
new goedlines = 0;
public npc_betolt()
{
	new Float:origin[3]
	
	new file[192], map[32]
	get_mapname(map, 31)
	formatex(file, charsmax(file), "addons/amxmodx/configs/jatekgep/%s.cfg", map)
	new elsopoz[8], masodikpoz[8], harmadikpoz[8]
	new lines = file_size(file, 1)
	
	if(goedlines == lines)
		return PLUGIN_HANDLED;

	if(lines > 0)
	{
		new buff[256], len
		read_file(file, goedlines, buff, charsmax(buff), len)	
		parse(buff, elsopoz, 7, masodikpoz, 7, harmadikpoz, 7)
			
		origin[0] = str_to_float(elsopoz)
		origin[1] = str_to_float(masodikpoz)
		origin[2] = str_to_float(harmadikpoz)

		new ent = create_entity("info_target")
		set_pev(ent, pev_classname, "npc")
		entity_set_model(ent, NPCMDL)
		set_pev(ent,pev_solid, SOLID_BBOX)
		set_pev(ent, pev_movetype, MOVETYPE_TOSS)
		engfunc(EngFunc_SetOrigin, ent, origin)
		engfunc(EngFunc_SetSize, ent, Float:{-10.0,-10.0,-49.0}, Float:{10.0,10.0,25.0})
		engfunc(EngFunc_DropToFloor, ent)

		goedlines++;
		npc_betolt()
	}
	else
		log_amx("Nem talalhato a betoltendo fajl")

	return PLUGIN_HANDLED;
}
public smlog(id, i_Type, send_id, sActionText[], sCost[], sAction[])
{
	new sTime[64];
	formatCurrentDateAndTime(sTime, charsmax(sTime));
	new Len
	static sQuery[1024]
	Len += formatex(sQuery[Len], charsmax(sQuery)-Len, "INSERT INTO `y_smv6_itemlog` (`AccountID`, `SendToAccountID`, `ActionText`, `Cost`, `Action`) VALUES (");

	Len += formatex(sQuery[Len], charsmax(sQuery)-Len, "%i,", sk_get_accountid(id));
	Len += formatex(sQuery[Len], charsmax(sQuery)-Len, "%i,", sk_get_accountid(send_id));
	Len += formatex(sQuery[Len], charsmax(sQuery)-Len, "^"%s^",", sActionText);
	Len += formatex(sQuery[Len], charsmax(sQuery)-Len, "^"%s^",", sCost);
	Len += formatex(sQuery[Len], charsmax(sQuery)-Len, "^"%s^");", sAction);
	SQL_ThreadQuery(m_get_sql(), "QuerySetOfflineMarket", sQuery);
}