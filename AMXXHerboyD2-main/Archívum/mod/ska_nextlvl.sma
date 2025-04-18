//95% optimalized last at:  2019.08.23 04:51
//Semantics edit last at:   2019.09.08 18:15
//Project started at:       2019.08.16 11:39
#pragma tabsize 0
#include <amxmodx>
#include <cstrike>
#include <fakemeta>
#include <hamsandwich>
#include <sqlx>
#include <regex>
#include <engine>
#include <RegSystem_SKA>
#include <fun>
#include <Settings_native>
#include <ServerPrefix>

#define PLUGIN "NextLvL Mod"
#define VERSION "0.4.1"
#define AUTHOR "Kova, Adek, Shedi" //DO NOT CHANGE
                                      //SQL SAVE, Admin System(Credit ~ Dooz) - Shedi
                                      //SintaxManger - Adek
                                      //Front/Back-end, SemanticsManeger - Kova

#define CaseDrops_CaseNum 7   //CASE EXTEND NEED HERE, Ha ládát akarsz böviteni itt is kell!
#define CaseDrops_Openable 10 //Max fegyver amennyít lehet nyítni 1 ládából! Ha a láda elönezet MODT-t használod akkor 10 fölött már nem tudja megjeleníteni feltétlen!

#define Cost_ToolsStattrak 100.0        //Stattrak felszerelő ára                     > $
#define Cost_ToolsNametag 50.0          //Névcédula felszerelő ára                    > $
#define Cost_InventoryExtend 20.0       //1 raktár férőhely ára                       > $
#define Cost_WeaponRepair 10.0          //a fegyveren való javítása 1%-éknak az ára   > $
#define Cost_WeaponRestore 1000.0       //0%-os fegyver helyreállításának ára         > $
#define Cost_WeaponMakePermanent 2000   //fegyver véglegesítésének ára                > Végtelen darabka
#define Return_BreakPermanent 1000      //Végleges fegyverből visszajövő összeg       > Végtelen darabka

//Azt határozza meg hány golyót kell kilőni hogy 1%-ot rololjon a fegyver
#define WeaponWorstByAttacks_AutomaticGun 300   //ak47, m4a1, mp5, famas
#define WeaponWorstByAttacks_SingleShotGun 150  //deagle, awp, scout
#define WeaponWorstByHitsNWepChange_Melee 300   //kés //sebzésnél romlik+amikor előveszed (a tok surlodása koptatja az élét)

#define Market_MaxCost 1000000  //maximum ennyiért tudsz kirakni valamit a piacra      > $
#define Market_MaxAmount 100    //maximum ennyit tudsz kirakni valamiből a piacra      > mennyiség
#define Market_MaxProduct 10    //maximum ennyi adak/fegyver lehet kint a piacon       > mennyiség

const InventoryMaxExtend = 400; //maximum inventory méret (nem ajánlatos állítani)
const InventoryMAX = 1200;      //mivel nem Dinamikus tömbe lett megoldva ezért lehetnek vele problémák ha indexen kivul mutatunk erre az esetre van ez! (legyen az inventory 4x-erese)

new Prefix[32]; //A prefix ami mindenhol megjelenik?

//SQL
  new Handle:g_SqlTuple;
  static const SQLINFO[][] = { "127.0.0.1", "root", "root_jelszó", "Adatbázis_Név"}; //Sql mentéshez itt kell meganod a szervert és adatbázíst
  static Query[10048];

new g_Maxplayers;
new String[512];
new StringHud[128];
new StringMotd[1536];

new logline[250];
new Filename_ItemTransaction[100];
new Filename_Give[100];
//INCLUDE
    new fwd_musiccmd;

new Array:g_Admins;
enum _:AdminData{
	Id,
	Name[32],
	Permission
}
enum _:TEAMS {T, CT};
new g_Awps[TEAMS];
new g_AwpCanAdd = 0;
new g_PlayingPlayers;
new s_AdminLevel[33];
enum _:rank_Properties
{
  r_Name[32],
  Float:r_Need
}
new const Admin_Permissions[][][] = { //jogokat lehet kedved szerint bövíteni ()
	//Rang név | Jogok | Hozzáadhat-e admint? (0-Nem | 1-Igen)| Hozzáadhat-e VIP-t? (0-Nem | 1-Igen)
	{"Játékos", "z", "0", "0"}, //0
	{"Fejlesztő", "abcvnmlpoikujzhtgrfedwsayc", "1", "1"}, //1
	{"Tulajdonos", "abcvnmlpoikujzhtgrfedwsayc", "1", "1"}, //2
	{"SzuperAdmin", "abmcfscdtiue", "1", "1"}, //3
	{"FőAdmin", "bmcfscdtiue", "0", "1"}, //4
	{"Admin", "bmcfscdtiue", "0", "0"}  //5
};
static const g_Ranks[][rank_Properties] =
{
  //szabadon bövíthető elvehető modosítható!
  {"Kifejezhetlenül szar(-5k)", -5000.0},
  {"Szánalmas(-2k)", -2000.0},
  {"Inkább töröld le(-1k)", -1000.0},
  {"Tehetségtelen(-500)", -500.0},
  {"Béna(-100)", -100.0},
  {"Gyakorlatlan(-50)", -50.0},
  {"Kezdő(-10)", -10.0},
  {"Midranger(0)", 0.0},
  {"Kezdő(+10)", 10.0},
  {"Jártas(+50)", 50.0},
  {"Ügyes(+100)", 100.0},
  {"Tehetséges(+500)", 500.0},
  {"Pusztitó(+1k)", 1000.0},
  {"Gyilkológép(+2k)", 2000.0},
  {"Hihetetlen(+5k)", 5000.0},
  {"Félisten(+10k)", 10000.0},
  {"Halál Isten(+20k)", 20000.0},
  {"Minden6ó(+30k)", 30000.0},
  {"Megállíthatatlan(+50k)", 50000.0},
  {"Legenda(+100k)", 100000.0}
}
new g_Rank_id_Middle;

enum _:stats_Properties
{
  Name[32],
  Kills, //deathM
  HSs, //deathM
  Deaths, //deathM
  AllHitCount,
  AllShotCount
}
new Player_Stats[33][stats_Properties];
new Top15_list[15][stats_Properties];

enum _:product_Properties
{
  product_SQL_key,
  UTS_EndTimeDate,
  Type,
  product_id,
  Amount,
  Price,
  Seller_User_id,
  p_w_Is_NameTaged,
  p_w_NameTag[32],
  p_w_Is_Stattrak,
  p_w_Stattrak_Kills,
  p_w_Damage_Level,
  p_w_AttackCount
}
new Array:g_Products;


enum _:search_Properties
{
  SelectedSearchType,
  weaponsearch_Type,
  weaponsearch_MaxDamage,
  weaponsearch_MinDamage,
  weaponsearch_MaxCost,
  weaponsearch_MinCost,
  weaponsearch_Stattrak,
  weaponsearch_Nametag,
  casesearch_Type,
  casesearch_MaxAmount,
  casesearch_MinAmount,
  casesearch_MaxCost,
  casesearch_MinCost,
  keysearch_MaxAmount,
  keysearch_MinAmount,
  keysearch_MaxCost,
  keysearch_MinCost,
  infinityfragmentsearch_MaxAmount,
  infinityfragmentsearch_MinAmount,
  infinityfragmentsearch_MaxCost,
  infinityfragmentsearch_MinCost,
  playersearch_User_id
}
new searchsettings_Player[33][search_Properties];

enum _:player_Properties
{
  FirstServerLogin,
  Float:Euro,
  PlayTime, //HUD
  ToolsStattrak,
  ToolsNametag,
  InfinityFragment,
  InventorySize,
  InventorySizeMax,
  InventoryWriteableSize,
  InventorySelectedSlot,
  CaseSelectedSlot,
  ShopSelectedSlot,
  MarketSelectedSlot,
  PreMarketSelectedType,
  TypedMarketPrice,
  TypedMarketAmount,
  MarketSize,
  ShopTypedAmount,
  SkinDisplay, //Settings
  HudDisplayPlayerInfo, //Settings
  HudDisplayWeaponInfo, //Settings
  SoundPlay, //Settings
  RoundEndSoundPlay, //Settings
  KnifeSoundPlay, //Settings
  ItemBreakSoundPlay, //Settings
  CanSendMe, //Settings
  SilentTransfer, //Settings
  Ranking, //Settings
  SilentAdminMod, //Settings
  InHandWepInvSlot,
  Keys,
  WeaponBuyInRound,
  Float:RankPoint,
  RankPrefix[32],
  Now_Rank
}
new s_Player[33][player_Properties];

new AllRegistedRank;

new Player_Cases[33][CaseDrops_CaseNum];
new CasesEmpty[CaseDrops_CaseNum];

enum _:Equipment
{
  AK47,
  AWP,
  DEAGLE,
  FAMAS,
  M4A1,
  MP5,
  SCOUT,
  KNIFE
}
new Equipmented[33][Equipment];

static const EquipmentedDef[Equipment] = 
{
  {0},
  {1},
  {2},
  {3},
  {4},
  {5},
  {6},
  {7}
}

enum _:weapon_Properties
{
  SQL_Key,
  w_UserId,
  w_id,
  w_Is_NameTaged,
  w_NameTag[32],
  w_Is_Stattrak,
  w_Stattrak_Kills,
  w_Damage_Level,
  w_AttackCount,
  w_Tradable,
  w_Equiped,
  w_Deleted
}
new Inventory[33][InventoryMAX][weapon_Properties];

new Item[weapon_Properties];
static const EmptyItem[weapon_Properties];

new const g_CasesNames[][] =
{
  //Láda hozzáadás bonyolultabb müvelet a pluginban több helyen meg van jelölve a következő szöveggel: "CASE EXTEND NEED HERE"
  "S0-Fusion Láda",
  "S0-Power Láda",
  "S0-Thunder Láda",
  "S0-Light Láda",
  "S0-Boom Láda",
  "S1-BlackIce Láda",
  "S2-??? Láda"
  //CASE EXTEND NEED HERE, Ha ládát akarsz böviteni itt is kell!
}
new const Float:s_DropCaseChance[] =
{
  14.0,
  13.0,
  12.0,
  11.0,
  10.0,
  5.0,
  0.05
  //CASE EXTEND NEED HERE, Ha ládát akarsz böviteni itt is kell!
}
new Float:s_DropCaseChanceOverAll;

new const Float:CaseDrops[CaseDrops_CaseNum][CaseDrops_Openable][2] =
{
  {//Fusion
    {8.0, 4.0 },
    {13.0, 20.0 },
    {18.0, 14.0 },
    {23.0, 20.0 },
    {28.0, 2.0 },
    {33.0, 14.0 },
    {38.0, 20.0 },
    {43.0, 0.05 },
    {0.0, 0.0 },
    {0.0, 0.0 }
  },
  {//Power
    {9.0, 1.0 },
    {14.0, 4.0 },
    {19.0, 18.0 },
    {24.0, 10.0 },
    {29.0, 10.0 },
    {34.0, 12.0 },
    {39.0, 18.0 },
    {44.0, 0.04 },
    {0.0, 0.0 },
    {0.0, 0.0 }
  },
  {//Thunder
    {10.0, 14.0 },
    {15.0, 12.0 },
    {20.0, 10.0 },
    {25.0, 16.0 },
    {30.0, 3.0 },
    {35.0, 18.0 },
    {40.0, 12.0 },
    {45.0, 0.03 },
    {0.0, 0.0 },
    {0.0, 0.0 }
  },
  {//Light
    {11.0, 3.0 },
    {16.0, 3.0 },
    {21.0, 16.0 },
    {26.0, 4.0 },
    {31.0, 4.0 },
    {36.0, 1.0 },
    {41.0, 3.0 },
    {46.0, 0.02 },
    {0.0, 0.0 },
    {0.0, 0.0 }
  },
  {//Boom
    {12.0, 18.0 },
    {17.0, 10.0 },
    {22.0, 20.0 },
    {27.0, 20.0 },
    {32.0, 16.0 },
    {37.0, 14.0 },
    {42.0, 16.0 },
    {47.0, 0.01 },
    {0.0, 0.0 },
    {0.0, 0.0 }
  },
  {//Black Ice
    {49.0, 4.5 },
    {50.0, 6.0 },
    {51.0, 7.0 },
    {52.0, 8.0 },
    {53.0, 5.0 },
    {54.0, 9.0 },
    {55.0, 10.0 },
    {56.0, 0.02 },
    {57.0, 0.02 },
    {58.0, 0.02 }
  },
  {//New case
    {0.0, 0.0 },
    {0.0, 0.0 },
    {0.0, 0.0 },
    {0.0, 0.0 },
    {0.0, 0.0 },
    {0.0, 0.0 },
    {0.0, 0.0 },
    {0.0, 0.0 },
    {0.0, 0.0 },
    {0.0, 0.0 }
  }
  //CASE EXTEND NEED HERE, Ha ládát akarsz böviteni itt is kell!
}

enum _:Properties
{
  w_id,
  w_name[32],
  w_model[128],
  w_type[16],
  w_ImgLink[128]
}
new const g_Weapon[][Properties] = 
{
  //Default models
  {0 ,"AK47 | Default", "models/NextLvL/Default/v_ak47.mdl", CSW_AK47, "http://perfectcs.ml/P/bg.jpg"},
  {1 ,"AWP | Default", "models/NextLvL/Default/v_awp.mdl", CSW_AWP, "http://perfectcs.ml/P/bg.jpg"},
  {2 ,"DEAGLE | Default", "models/NextLvL/Default/v_deagle.mdl", CSW_DEAGLE, "http://perfectcs.ml/P/bg.jpg"},
  {3 ,"FAMAS | Default", "models/NextLvL/Default/v_famas.mdl", CSW_FAMAS, "http://perfectcs.ml/P/bg.jpg"},
  {4 ,"M4A1 | Default", "models/NextLvL/Default/v_m4a1.mdl", CSW_M4A1, "http://perfectcs.ml/P/bg.jpg"},
  {5 ,"MP5 | Default", "models/NextLvL/Default/v_mp5.mdl", CSW_MP5NAVY, "http://perfectcs.ml/P/bg.jpg"},
  {6 ,"SCOUT | Default", "models/NextLvL/Default/v_scout.mdl", CSW_SCOUT, "http://perfectcs.ml/P/bg.jpg"},
  {7 ,"KÉS | Default", "models/NextLvL/Default/v_knife.mdl", CSW_KNIFE, "http://perfectcs.ml/P/bg.jpg"},
   //First
  {8 ,"AK47 | Aquamarine Revenge", "models/NextLvL/Serias_0/AK47/AquamarineRevenge.mdl", CSW_AK47, "http://perfectcs.ml/P/8.jpg"},
  {9 ,"AK47 | Astronaut", "models/NextLvL/Serias_0/AK47/Astronaut.mdl", CSW_AK47, "http://perfectcs.ml/P/9.jpg"},
  {10 ,"AK47 | Bloodsport", "models/NextLvL/Serias_0/AK47/Bloodsport.mdl", CSW_AK47, "http://perfectcs.ml/P/10.jpg"},
  {11 ,"AK47 | Demolition Derby", "models/NextLvL/Serias_0/AK47/DemolitionDerby.mdl", CSW_AK47, "http://perfectcs.ml/P/11.jpg"},
  {12 ,"AK47 | Horas", "models/NextLvL/Serias_0/AK47/Horas.mdl", CSW_AK47, "http://perfectcs.ml/P/12.jpg"},
  {13 ,"AWP | Captain Strike", "models/NextLvL/Serias_0/AWP/CaptainStrike.mdl", CSW_AWP, "http://perfectcs.ml/P/13.jpg"},
  {14 ,"AWP | De Jackal", "models/NextLvL/Serias_0/AWP/DeJackal.mdl", CSW_AWP, "http://perfectcs.ml/P/14.jpg"},
  {15 ,"AWP | Dragon Lore", "models/NextLvL/Serias_0/AWP/DragonLore.mdl", CSW_AWP, "http://perfectcs.ml/P/15.jpg"},
  {16 ,"AWP | Golden Roll", "models/NextLvL/Serias_0/AWP/GoldenRoll.mdl", CSW_AWP, "http://perfectcs.ml/P/16.jpg"},
  {17 ,"AWP | Virus", "models/NextLvL/Serias_0/AWP/Virus.mdl", CSW_AWP, "http://perfectcs.ml/P/17.jpg"},

  {18 ,"DEAGLE | Black Countrains", "models/NextLvL/Serias_0/DEAGLE/BlackCountrains.mdl", CSW_DEAGLE,"http://perfectcs.ml/P/18.jpg"},
  {19 ,"DEAGLE | Cyberwanderer Black", "models/NextLvL/Serias_0/DEAGLE/CyberwandererBlack.mdl", CSW_DEAGLE, "http://perfectcs.ml/P/19.jpg"},
  {20 ,"DEAGLE | Extreme", "models/NextLvL/Serias_0/DEAGLE/Extreme.mdl", CSW_DEAGLE, "http://perfectcs.ml/P/20.jpg"},
  {21 ,"DEAGLE | Graan", "models/NextLvL/Serias_0/DEAGLE/Graan.mdl", CSW_DEAGLE, "http://perfectcs.ml/P/21.jpg"},
  {22 ,"DEAGLE | Ice Dragon", "models/NextLvL/Serias_0/DEAGLE/IceDragon.mdl", CSW_DEAGLE, "http://perfectcs.ml/P/22.jpg"},

  {23 ,"FAMAS | Fade", "models/NextLvL/Serias_0/FAMAS/Fade.mdl", CSW_FAMAS, "http://perfectcs.ml/P/23.jpg"},
  {24 ,"FAMAS | Purple Pulse", "models/NextLvL/Serias_0/FAMAS/PurplePulse.mdl", CSW_FAMAS, "http://perfectcs.ml/P/24.jpg"},
  {25 ,"FAMAS | Roll Cage", "models/NextLvL/Serias_0/FAMAS/RollCage.mdl", CSW_FAMAS, "http://perfectcs.ml/P/25.jpg"},
  {26 ,"FAMAS | Spitfire", "models/NextLvL/Serias_0/FAMAS/Spitfire.mdl", CSW_FAMAS, "http://perfectcs.ml/P/26.jpg"},
  {27 ,"FAMAS | Valence", "models/NextLvL/Serias_0/FAMAS/Valence.mdl", CSW_FAMAS, "http://perfectcs.ml/P/27.jpg"},

  {28 ,"M4A1 | Alliance", "models/NextLvL/Serias_0/M4A1/Alliance.mdl", CSW_M4A1, "http://perfectcs.ml/P/28.jpg"},
  {29 ,"M4A1 | Fade", "models/NextLvL/Serias_0/M4A1/Fade.mdl", CSW_M4A1, "http://perfectcs.ml/P/29.jpg"},
  {30 ,"M4A1 | Nuclear", "models/NextLvL/Serias_0/M4A1/Nuclear.mdl", CSW_M4A1, "http://perfectcs.ml/P/30.jpg"},
  {31 ,"M4A1 | Spiritual", "models/NextLvL/Serias_0/M4A1/Spiritual.mdl", CSW_M4A1, "http://perfectcs.ml/P/31.jpg"},
  {32 ,"M4A1 | Wild Style", "models/NextLvL/Serias_0/M4A1/WildStyle.mdl", CSW_M4A1, "http://perfectcs.ml/P/32.jpg"},

  {33 ,"MP5 | Ares", "models/NextLvL/Serias_0/MP5/Ares.mdl", CSW_MP5NAVY, "http://perfectcs.ml/P/33.jpg"},
  {34 ,"MP5 | Golden", "models/NextLvL/Serias_0/MP5/Golden.mdl", CSW_MP5NAVY, "http://perfectcs.ml/P/34.jpg"},
  {35 ,"MP5 | Nemesis", "models/NextLvL/Serias_0/MP5/Nemesis.mdl", CSW_MP5NAVY, "http://perfectcs.ml/P/35.jpg"},
  {36 ,"MP5 | Spooky", "models/NextLvL/Serias_0/MP5/Spooky.mdl", CSW_MP5NAVY, "http://perfectcs.ml/P/36.jpg"},
  {37 ,"MP5 | Water", "models/NextLvL/Serias_0/MP5/Water.mdl", CSW_MP5NAVY, "http://perfectcs.ml/P/37.jpg"},

  {38 ,"SCOUT | Blood In The Water", "models/NextLvL/Serias_0/SCOUT/BloodInTheWater.mdl", CSW_SCOUT, "http://perfectcs.ml/P/38.jpg"},
  {39 ,"SCOUT | Dragon Fire", "models/NextLvL/Serias_0/SCOUT/DragonFire.mdl", CSW_SCOUT, "http://perfectcs.ml/P/39.jpg"},
  {40 ,"SCOUT | Fade", "models/NextLvL/Serias_0/SCOUT/Fade.mdl", CSW_SCOUT, "http://perfectcs.ml/P/40.jpg"},
  {41 ,"SCOUT | Necropos", "models/NextLvL/Serias_0/SCOUT/Necropos.mdl", CSW_SCOUT, "http://perfectcs.ml/P/41.jpg"},
  {42 ,"SCOUT | Wooden", "models/NextLvL/Serias_0/SCOUT/Wooden.mdl", CSW_SCOUT, "http://perfectcs.ml/P/42.jpg"},

  {43 ,"Bayonet | Autotronic Animation", "models/NextLvL/Serias_0/KNIFE/Bayonet-Autotronic.mdl", CSW_KNIFE, "http://perfectcs.ml/P/43.jpg"},
  {44 ,"Butterfly | KnifeBlaze", "models/NextLvL/Serias_0/KNIFE/Butterfly-KnifeBlaze.mdl", CSW_KNIFE, "http://perfectcs.ml/P/44.jpg"},
  {45 ,"Filp | BlackPearl", "models/NextLvL/Serias_0/KNIFE/Filp-BlackPearl.mdl", CSW_KNIFE, "http://perfectcs.ml/P/45.jpg"},
  {46 ,"Karmabit | Blossoming", "models/NextLvL/Serias_0/KNIFE/Karmabit-Blossoming.mdl", CSW_KNIFE, "http://perfectcs.ml/P/46.jpg"},
  {47 ,"M9 Bayonet | Galant", "models/NextLvL/Serias_0/KNIFE/M9-BayonetGalant.mdl", CSW_KNIFE, "http://perfectcs.ml/P/47.jpg"},

  {48 ,"M9 Bayonet | LuckyestOwner", "models/NextLvL/Serias_0/KNIFE/M9-BayonetLucky.mdl", CSW_KNIFE, "http://perfectcs.ml/P/bg.jpg"}, // 1 a 100000-hez a drop esélye

  {49 ,"AK47 | BlackIce", "models/NextLvL/Serias_1/ak47.mdl", CSW_AK47, "http://perfectcs.ml/P/49.jpg"},
  {50 ,"AWP | BlackIce", "models/NextLvL/Serias_1/awp.mdl", CSW_AWP, "http://perfectcs.ml/P/50.jpg"},
  {52 ,"DEAGLE | BlackIce", "models/NextLvL/Serias_1/deagle.mdl", CSW_DEAGLE, "http://perfectcs.ml/P/51.jpg"},
  {53 ,"FAMAS | BlackIce", "models/NextLvL/Serias_1/famas.mdl", CSW_FAMAS, "http://perfectcs.ml/P/52.jpg"},
  {54 ,"M4A1 | BlackIce", "models/NextLvL/Serias_1/m4a1.mdl", CSW_M4A1, "http://perfectcs.ml/P/53.jpg"},
  {55 ,"MP5 | BlackIce", "models/NextLvL/Serias_1/mp5.mdl", CSW_MP5NAVY, "http://perfectcs.ml/P/54.jpg"},
  {56 ,"SCOUT | BlackIce", "models/NextLvL/Serias_1/scout.mdl", CSW_SCOUT, "http://perfectcs.ml/P/55.jpg"},
  {57 ,"Butterfly | BlackIce", "models/NextLvL/Serias_1/Butterfly.mdl", CSW_KNIFE, "http://perfectcs.ml/P/56.jpg"},
  {58 ,"Shadow Daggers | BlackIce", "models/NextLvL/Serias_1/Dagger.mdl", CSW_KNIFE, "http://perfectcs.ml/P/57.jpg"},
  {51 ,"Karambit | BlackIce", "models/NextLvL/Serias_1/Karambit.mdl", CSW_KNIFE, "http://perfectcs.ml/P/58.jpg"},
  //Itt tudsz hozzáadni skineket, FONTOS mindig csak az aljára adjál hozzá mert különben elcsuszik a mentés!
  //A kének amit ott meghivsz azt maximum 100x100px-el lehet!!!
 }
public plugin_precache() 
{
  g_Admins = ArrayCreate(AdminData);
  new m_g_Weapon_size = sizeof(g_Weapon);
  for(new i;i < m_g_Weapon_size; i++) precache_model(g_Weapon[i][w_model]);
  precache_sound("NextLvL/KnifeOpen.wav");
  precache_sound("NextLvL/ItemBreak.wav");

  new m_s_DropCaseChance_size = sizeof(s_DropCaseChance);
  for(new i; i < m_s_DropCaseChance_size; i++)
  {
    s_DropCaseChanceOverAll += s_DropCaseChance[i];
  }

  new m_g_Ranks_sizeof = sizeof(g_Ranks);
  for(new i; i < m_g_Ranks_sizeof;i++)
  {
    if(g_Ranks[i][r_Need] == 0.0)
    {
      g_Rank_id_Middle = i;
      break;
    }
  }

  Prefix = Get_ServerPrefix();

  //Fájlba logolást nem sikerült megoldani, nem fektettem rá hangsúlyt.
  get_time("addons/amxmodx/logs/mod/%Y-%m-%d/ItemTransaction.log", Filename_ItemTransaction, 99);
  get_time("addons/amxmodx/logs/mod/%Y-%m-%d/Give.log", Filename_Give, 99);
}

public plugin_init() 
{
  register_plugin(PLUGIN, VERSION, AUTHOR);

  register_impulse(201, "MainMenu");
  register_clcmd("weapon_list", "CmdListItem");
  register_concmd("weapon_give", "CmdGiveItem", _, "<#User_ID> <Weapon_Id (command: weapon_list)> <Tradable> <IsStattrak / -1 for Random> <Stattrak_Kills> <IsNameTaged> <NameTag> <Damage_Lvl / -1 for Random>");
  register_concmd("money_give", "CmdGiveMoney", _, "<#User_ID> <Money Amount>");
  register_clcmd("case_list", "CmdListCase");
  register_concmd("case_give", "CmdGiveCase", _, "<#User_ID> <Case id> <Case Amount>");
  register_concmd("key_give", "CmdGiveKey", _, "<#User_ID> <Key Amount>");
  register_concmd("if_give", "CmdGiveInfinityFragment", _, "<#User_ID> <InfinityFragment Amount>");
  register_concmd("fd_set_admin", "CmdSetAdmin", _, "<#id> <jog> | <1 Developer> <2 Tulaj> <3 SzuperAdmin> <2 FoAdmin> <1 Admin>");
  
  register_clcmd("Nevcedula", "Get_NameTag");
  register_clcmd("Mennyiseg", "Get_ShopAmount");

  register_clcmd("MaxHasznaltsag", "Get_MaxDamage");
  register_clcmd("MinHasznaltsag", "Get_MinDamage");
  register_clcmd("MaxMennyiseg", "Get_MaxAmount");
  register_clcmd("MinMennyiseg", "Get_MinAmount");
  register_clcmd("MaxAr", "Get_MaxCost");
  register_clcmd("MinAr", "Get_MinCost");
  register_clcmd("idmegad", "Get_SearchById");

  register_clcmd("PiaciAr", "Get_MarketCost");
  register_clcmd("PiaciMennyiseg", "Get_MarketAmount");
  
  register_event("DeathMsg", "deathM", "a");
  
  register_clcmd("say /guns", "WeaponMenu");
  register_clcmd("say /fegyo", "WeaponMenu");
  register_clcmd("say /fegyver", "WeaponMenu");
  register_clcmd("say /rs", "CmdResetScore");
  register_clcmd("say_team /rs", "CmdResetScore");

  register_clcmd("say /top15", "CmdTop15");
  register_clcmd("say /rank", "CmdRank");

  register_clcmd("say", "Hook_Say");
  register_clcmd("say_team", "Hook_Say");

  RegisterHam(Ham_Spawn,"player","PlayerSpawn", 1);
  RegisterHam(Ham_Spawn,"player","WeaponMenu", 1);

  RegisterHam(Ham_Item_Deploy, "weapon_m4a1", "Change_Weapon", 1);
  RegisterHam(Ham_Item_Deploy, "weapon_ak47", "Change_Weapon", 1);
  RegisterHam(Ham_Item_Deploy, "weapon_awp", "Change_Weapon", 1);
  RegisterHam(Ham_Item_Deploy, "weapon_deagle", "Change_Weapon", 1);
  RegisterHam(Ham_Item_Deploy, "weapon_knife", "Change_Weapon", 1);
  RegisterHam(Ham_Item_Deploy, "weapon_scout", "Change_Weapon", 1);
  RegisterHam(Ham_Item_Deploy, "weapon_mp5navy", "Change_Weapon", 1);
  RegisterHam(Ham_Item_Deploy, "weapon_famas", "Change_Weapon", 1);
  RegisterHam(Ham_Item_Deploy, "weapon_c4", "Change_Weapon", 1);
  RegisterHam(Ham_Item_Deploy, "weapon_flashbang", "Change_Weapon", 1);
  RegisterHam(Ham_Item_Deploy, "weapon_hegrenade", "Change_Weapon", 1);

  RegisterHam(Ham_TakeDamage, "player", "PlayerGetHit");
  RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_m4a1", "Attack_AutomaticGun", 1);
  RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_ak47", "Attack_AutomaticGun", 1);
  RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_mp5navy", "Attack_AutomaticGun", 1);
  RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_famas", "Attack_AutomaticGun", 1);

  RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_awp", "Attack_SingleShotGun", 1);
  RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_deagle", "Attack_SingleShotGun", 1);
  RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_scout", "Attack_SingleShotGun", 1);

  fwd_musiccmd=CreateMultiForward("Toggle", ET_IGNORE, FP_CELL)

  register_event("HLTV", "NewRoundStart", "a", "1=0", "2=0");

  set_task(0.1, "OnMapStart",_,_,_,"c");
  register_event("30", "OnMapEnd", "a");
  register_clcmd("amx_map", "MapChangeByClient"); // forward to OnMapEnd if client have 'f' flag!
  //register_concmd("map", "OnMapEnd"); EZ ITT EGY HIBALEHETŐSÉG, ha 'map' commanddal váltasz pályát akkor nem ment a piac!
  register_concmd("amx_map", "OnMapEnd");

  set_task(0.1, "Check",_,_,_,"b");

  g_Maxplayers = get_maxplayers();
  g_Products = ArrayCreate(product_Properties);
}

public MapChangeByClient(id)
{
  new Arg1[32];
  read_argv(1, Arg1, charsmax(Arg1));

  if((get_user_flags(id) & ADMIN_MAP) && equali(Arg1, "de_dust2"))
  {
    OnMapEnd();
    return PLUGIN_CONTINUE;
  }
  else
  {
    if((get_user_flags(id) & ADMIN_MAP))
      client_print(id, print_console, "Ez egy Only de_dust2, tiszta'ba vagy vele?");
    return PLUGIN_HANDLED;
  }
}

new g_IsStarted = 0;
public OnMapStart()
{
  if(g_IsStarted != 0)
    return;
  
  server_print(" ");
  server_print("[DEBUG] The map ready and Data load form SQL is started!");
  server_print(" ");
  Load_Data_15("NextLvL_Player_Stats", "TablaAdatValasztas15_PlayerStats");
  Load_Data_Market("NextLvL_g_Products", "TablaAdatValasztas_gProducts");
  g_IsStarted++;
}
new g_IsEnded = 0;
public OnMapEnd()
{
  if(g_IsEnded != 0)
    return;
  
  server_print(" ");
  server_print("[DEBUG] The map will change and Data save into SQL is started!");
  server_print(" ");
  Update_g_Products();
  g_IsEnded++;
}

public plugin_natives()
{
  register_native("Settings_Get_RoundEndSoundPlay","native_Settings_Get_RoundEndSoundPlay",1)
  register_native("Settings_Get_SoundPlay","native_Settings_Get_SoundPlay",1)
}
public native_Settings_Get_RoundEndSoundPlay(id)
{
  if(!(ska_is_user_logged(id)))
    return -1;
  
  if(s_Player[id][RoundEndSoundPlay])
    return 1;
  else
    return 0;
}
public native_Settings_Get_SoundPlay(id)
{
  if(!(ska_is_user_logged(id)))
    return -1;
  
  if(s_Player[id][SoundPlay])
    return 1;
  else
    return 0;
}

public Attack_AutomaticGun(ent)
{
  static id; id = pev(ent, 18);

  Player_Stats[id][AllShotCount]++;

  new m_InHandWepInvSlot = s_Player[id][InHandWepInvSlot];

  switch(m_InHandWepInvSlot)
  {
    case -1:
      return HAM_IGNORED;
  }

  if(Inventory[id][m_InHandWepInvSlot][w_Damage_Level] == 101)
    return HAM_IGNORED;

  Inventory[id][m_InHandWepInvSlot][w_AttackCount]++;

  if(Inventory[id][m_InHandWepInvSlot][w_AttackCount] >= WeaponWorstByAttacks_AutomaticGun)
  {
    Inventory[id][m_InHandWepInvSlot][w_AttackCount] = 0;
    Inventory[id][m_InHandWepInvSlot][w_Damage_Level] -= 1;
    if(Inventory[id][m_InHandWepInvSlot][w_Damage_Level] <= 0)
    {
      WeaponBreak(id, m_InHandWepInvSlot);
    }
  }
  return HAM_IGNORED;
}

public Attack_SingleShotGun(ent)
{
  static id; id = pev(ent, 18);

  Player_Stats[id][AllShotCount]++;
  
  new m_InHandWepInvSlot = s_Player[id][InHandWepInvSlot];

  switch(m_InHandWepInvSlot)
  {
    case -1:
      return HAM_IGNORED;
  }

  if(Inventory[id][m_InHandWepInvSlot][w_Damage_Level] == 101)
    return HAM_IGNORED;

  Inventory[id][m_InHandWepInvSlot][w_AttackCount]++;

  if(Inventory[id][m_InHandWepInvSlot][w_AttackCount] >= WeaponWorstByAttacks_SingleShotGun)
  {
    Inventory[id][m_InHandWepInvSlot][w_AttackCount] = 0;
    Inventory[id][m_InHandWepInvSlot][w_Damage_Level] -= 1;
    if(Inventory[id][m_InHandWepInvSlot][w_Damage_Level] <= 0)
    {
      WeaponBreak(id, m_InHandWepInvSlot);
    }
  }
  return HAM_IGNORED;
}

public PlayerGetHit(victim, inflictor, attacker, Float:damage, bits)
{
  if(!(bits & DMG_BULLET))
    return HAM_IGNORED;
  
  if(get_user_weapon(attacker) == 29)
  {
    new m_InHandWepInvSlot = s_Player[attacker][InHandWepInvSlot];

    if(m_InHandWepInvSlot == -1 || Inventory[attacker][m_InHandWepInvSlot][w_Damage_Level] == 101)
      return HAM_IGNORED;

    Inventory[attacker][m_InHandWepInvSlot][w_AttackCount]++;
    if(Inventory[attacker][m_InHandWepInvSlot][w_AttackCount] >= WeaponWorstByHitsNWepChange_Melee)
    {
      Inventory[attacker][m_InHandWepInvSlot][w_AttackCount] = 0;
      Inventory[attacker][m_InHandWepInvSlot][w_Damage_Level] -= 1;
      if(Inventory[attacker][m_InHandWepInvSlot][w_Damage_Level] <= 0)
      {
        WeaponBreak(attacker, m_InHandWepInvSlot);
      }
    }
    return HAM_IGNORED;
  }
  
  Player_Stats[attacker][AllHitCount]++;
  return HAM_IGNORED;
}

public PlayerSpawn(id)
{
  if(!is_user_alive(id))
    return;
  
  new m_HaveBomb = 0;
  if(user_has_weapon(id, CSW_C4))
    m_HaveBomb = 1;

  strip_user_weapons(id);
  s_Player[id][InHandWepInvSlot] = -1;
  if(m_HaveBomb)
    give_item(id, "weapon_c4");

  s_Player[id][WeaponBuyInRound] = 0;
  SetUserRank(id);
} 

public WeaponMenu(id)
{
  if(!is_user_alive(id))
  {
    client_print_color(id, print_team_default, "^4%s ^1Halottként nem tudsz fegyvert venni!", Prefix);
    return;
  }
  else if(s_Player[id][WeaponBuyInRound])
  {
    client_print_color(id, print_team_default, "^4%s ^1Ebben a körben már választottál fegyvert!", Prefix);
    return;
  }
    
  formatex(String, charsmax(String), "\r%s \y» \wFegyvermenü", Prefix);
  new menu = menu_create(String , "WeaponMenu_h");

  formatex(String, charsmax(String), "\r[\w*~\y%s\w~*\r]", g_Weapon[Inventory[id][Equipmented[id][M4A1]][w_id]][w_name]);
  menu_additem(menu, String, "1", 0);

  formatex(String, charsmax(String), "\r[\w*~\y%s\w~*\r]", g_Weapon[Inventory[id][Equipmented[id][AK47]][w_id]][w_name]);
  menu_additem(menu, String, "2", 0);

  formatex(String, charsmax(String), "\r[\w*~\y%s\w~*\r] \wCsapatonként 2 ember", g_Weapon[Inventory[id][Equipmented[id][AWP]][w_id]][w_name]);
  menu_additem(menu, String, "3", 0);

  formatex(String, charsmax(String), "\r[\w*~\y%s\w~*\r]", g_Weapon[Inventory[id][Equipmented[id][FAMAS]][w_id]][w_name]);
  menu_additem(menu, String, "4", 0);

  formatex(String, charsmax(String), "\r[\w*~\y%s\w~*\r]", g_Weapon[Inventory[id][Equipmented[id][MP5]][w_id]][w_name]);
  menu_additem(menu, String, "5", 0);

  formatex(String, charsmax(String), "\r[\w*~\y%s\w~*\r]", g_Weapon[Inventory[id][Equipmented[id][SCOUT]][w_id]][w_name]);
  menu_additem(menu, String, "6", 0);



  menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
  menu_display(id, menu);
}

public WeaponMenu_h(id, menu, item)
{
  if(!is_user_alive(id))
  {
    client_print_color(id, print_team_default, "^4%s ^1Halottként nem tudsz fegyvert venni!", Prefix);
    menu_destroy(menu);
    return;
  }
  if(item == MENU_EXIT)
  {
    menu_destroy(menu);
    return;
  }
  new data[6], szName[64];
  new access, callback;
  menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
  new key = str_to_num(data);

  new m_Added = 1;

  new m_HaveBomb = 0;
  if(user_has_weapon(id, CSW_C4))
    m_HaveBomb = 1;

  new m_Team[10];
  get_user_team(id, m_Team, 10);

  strip_user_weapons(id);
  switch(key)
  {
    case 1:
    {
      give_item(id, "weapon_m4a1");
      give_item(id, "ammo_556nato");
      give_item(id, "ammo_556nato");
      give_item(id, "ammo_556nato");
    }
    case 2:
    {
      give_item(id, "weapon_ak47");
      give_item(id, "ammo_762nato");
      give_item(id, "ammo_762nato");
      give_item(id, "ammo_762nato");
    }
    case 3:
    {
      if((((contain(m_Team, "TERRORIST") == 0) && g_Awps[T] <= 2) || ((contain(m_Team, "CT") == 0) && g_Awps[CT] <= 2)) && g_AwpCanAdd)
      {
        if(contain(m_Team, "CT") == 0)
        {
          g_Awps[CT]++;
        }
        else
        {
          g_Awps[T]++;
        }
        give_item(id, "weapon_awp");
        give_item(id, "ammo_338magnum");
        give_item(id, "ammo_338magnum");
        give_item(id, "ammo_338magnum");
      }
      else
      {
        m_Added = 0;
        if((contain(m_Team, "TERRORIST") == 0 && g_Awps[T] <= 2) || (contain(m_Team, "CT") == 0 && g_Awps[CT] <= 2))
          client_print_color(id, print_team_default, "^4%s ^1Nincs meg/kör elején nem volt meg a 4v4 az AWP-hez!", Prefix);
        else
          client_print_color(id, print_team_default, "^4%s ^1A csapatodban már ki lett osztva a 2 AWP!", Prefix);
          
        WeaponMenu(id);
      }
    }
    case 4:
    {
      give_item(id, "weapon_famas");
      give_item(id, "ammo_556nato");
      give_item(id, "ammo_556nato");
      give_item(id, "ammo_556nato");
    }
    case 5:
    {
      give_item(id, "weapon_mp5navy");
      give_item(id, "ammo_9mm");
      give_item(id, "ammo_9mm");
      give_item(id, "ammo_9mm");
    }
    case 6:
    {
      give_item(id, "weapon_scout");
      give_item(id, "ammo_762nato");
      give_item(id, "ammo_762nato");
      give_item(id, "ammo_762nato");
    }
  }

  if(m_HaveBomb)
  {
    give_item(id, "weapon_c4");
    cs_set_user_plant(id);
  }

  if(m_Added)
  {
    
    if(contain(m_Team, "CT") == 0)
    {
      give_item(id, "item_thighpack");
      cs_set_user_defuse(id);
    }

    give_item(id, "item_kevlar");
    set_user_armor(id, 100);
    give_item(id, "weapon_hegrenade");
    give_item(id, "weapon_flashbang");
    give_item(id, "weapon_flashbang");
    give_item(id, "weapon_deagle");
    give_item(id, "ammo_50ae");
    give_item(id, "ammo_50ae");
    give_item(id, "ammo_50ae");
    give_item(id, "weapon_knife");
    s_Player[id][WeaponBuyInRound] = 1;
  }

  menu_destroy(menu);
}


public SetUserRank(id)
{
  if(!(s_Player[id][Ranking]))
  {
    s_Player[id][RankPrefix] = "";
    return;
  }

  new Float:m_RankPoint = s_Player[id][RankPoint];
  new Float:OldRank = 0.0;
  new Float:NowRank = 0.0;

  new m_g_Ranks_sizeof = sizeof(g_Ranks);
  new m_StartFrom = g_Rank_id_Middle;
  if(m_RankPoint > 0.0 && m_RankPoint <= g_Ranks[m_g_Ranks_sizeof - 1][r_Need])
  {
    NowRank = g_Ranks[m_StartFrom][r_Need];
    for(new i = m_StartFrom;i < m_g_Ranks_sizeof;i++)
    {
      OldRank = NowRank;
      NowRank = g_Ranks[i+1][r_Need];
      if(OldRank <= m_RankPoint < NowRank)
      {
        copy(s_Player[id][RankPrefix], 31, g_Ranks[i][r_Name]);
        return;
      }
    }
  }
  else if(m_RankPoint >= g_Ranks[m_g_Ranks_sizeof - 1][r_Need])
  {
    copy(s_Player[id][RankPrefix], 31, g_Ranks[m_g_Ranks_sizeof - 1][r_Name]);
    return;
  }

  if(m_RankPoint == 0.0)
  {
    copy(s_Player[id][RankPrefix], 31, g_Ranks[g_Rank_id_Middle][r_Name]);
    return;
  }

  m_RankPoint = floatabs(m_RankPoint); //-1000 >> 1000

  if(m_RankPoint > 0.0 && m_RankPoint <= floatabs(g_Ranks[0][r_Need]))
  {
    NowRank = floatabs(g_Ranks[0][r_Need]);
    for(new i = 0;i < g_Rank_id_Middle + 1 ;i++)
    {
      OldRank = NowRank;
      NowRank = floatabs(g_Ranks[i+1][r_Need]);
      if(OldRank > m_RankPoint >= NowRank)
      {
        copy(s_Player[id][RankPrefix], 31, g_Ranks[i+1][r_Name]);
        return;
      }
    }
  }
  else
  {
    copy(s_Player[id][RankPrefix], 31, g_Ranks[0][r_Name]);
    return;
  }
}

public NewRoundStart()
{
  g_Awps[T] = 0;
  g_Awps[CT] = 0;

  new Players[32], iNum;
  new any:m_Team;
  new t_num = 0;
  new ct_num = 0;
  get_players(Players, iNum, "ch");
  new Player;
  for (new i=0; i<iNum; i++)
  {
    Player = Players[i];
    if(ska_is_user_logged(Player))
    {
      Update_Player_Stats(Player);
      SetUserRank(Player);
    }

    m_Team = cs_get_user_team(Player);
    switch(m_Team)
    {
      case CS_TEAM_CT:
      {
        ct_num++;
      }
      case CS_TEAM_T:
      {
        t_num++;
      }
    }
  }
  if(t_num >= 4 && ct_num >= 4)
    g_AwpCanAdd = 1;
  else
    g_AwpCanAdd = 0;
  g_PlayingPlayers = ct_num + t_num;

  Load_Data_15("NextLvL_Player_Stats", "TablaAdatValasztas15_PlayerStats");
}

public Change_Weapon(iEnt)
{
  if(!pev_valid(iEnt))
    return;

  new id = get_pdata_cbase(iEnt, 41, 4);

  if(s_Player[id][SkinDisplay] == 0)
  {
    s_Player[id][InHandWepInvSlot] = -1;
    return;
  }

  if(!pev_valid(id))
    return;

  //if(!Gun[id])
  //return;

  new iWeapon = cs_get_weapon_id(iEnt);
  new m_Equipmented = -1;
  switch(iWeapon)
  {
    case CSW_AK47:
    {
      m_Equipmented = Equipmented[id][AK47];
      if(Inventory[id][m_Equipmented][w_Equiped] == 1)
      {
        entity_set_string(id, EV_SZ_viewmodel,  g_Weapon[Inventory[id][m_Equipmented][w_id]][w_model]);
        s_Player[id][InHandWepInvSlot] = m_Equipmented;
      }              
    }
    case CSW_M4A1:
    {
      m_Equipmented = Equipmented[id][M4A1];
      if(Inventory[id][m_Equipmented][w_Equiped] == 1)
      {
        entity_set_string(id, EV_SZ_viewmodel,  g_Weapon[Inventory[id][m_Equipmented][w_id]][w_model]);
        s_Player[id][InHandWepInvSlot] = m_Equipmented;
      }
    }
    case CSW_AWP:
    {
      m_Equipmented = Equipmented[id][AWP];
      if(Inventory[id][m_Equipmented][w_Equiped] == 1)
      {
        entity_set_string(id, EV_SZ_viewmodel,  g_Weapon[Inventory[id][m_Equipmented][w_id]][w_model]);
        s_Player[id][InHandWepInvSlot] = m_Equipmented;
      }              
    }
    case CSW_DEAGLE:
    {
      m_Equipmented = Equipmented[id][DEAGLE];
      if(Inventory[id][m_Equipmented][w_Equiped] == 1)
      {
        entity_set_string(id, EV_SZ_viewmodel,  g_Weapon[Inventory[id][m_Equipmented][w_id]][w_model]);
        s_Player[id][InHandWepInvSlot] = m_Equipmented;
      }              
    }
    case CSW_KNIFE:
    {
      m_Equipmented = Equipmented[id][KNIFE];
      if(Inventory[id][m_Equipmented][w_Equiped] == 1)
      {
        entity_set_string(id, EV_SZ_viewmodel,  g_Weapon[Inventory[id][m_Equipmented][w_id]][w_model]);
        s_Player[id][InHandWepInvSlot] = m_Equipmented;

        new m_InHandWepInvSlot = s_Player[id][InHandWepInvSlot];
        if(Inventory[id][m_InHandWepInvSlot][w_Damage_Level] != 101)
        {
          Inventory[id][m_InHandWepInvSlot][w_AttackCount]++;
          if(Inventory[id][m_InHandWepInvSlot][w_AttackCount] >= WeaponWorstByHitsNWepChange_Melee)
          {
            Inventory[id][m_InHandWepInvSlot][w_AttackCount] = 0;
            Inventory[id][m_InHandWepInvSlot][w_Damage_Level] -= 1;
            if(Inventory[id][m_InHandWepInvSlot][w_Damage_Level] <= 0)
            {
              WeaponBreak(id, m_InHandWepInvSlot);
            }
          }
        }
      }              
    }
    case CSW_FAMAS:
    {
      m_Equipmented = Equipmented[id][FAMAS];
      if(Inventory[id][m_Equipmented][w_Equiped] == 1)
      {
        entity_set_string(id, EV_SZ_viewmodel,  g_Weapon[Inventory[id][m_Equipmented][w_id]][w_model]);
        s_Player[id][InHandWepInvSlot] = m_Equipmented;
      }
          
    }
    case CSW_MP5NAVY:
    {
      m_Equipmented = Equipmented[id][MP5];
      if(Inventory[id][m_Equipmented][w_Equiped] == 1)
      {
        entity_set_string(id, EV_SZ_viewmodel,  g_Weapon[Inventory[id][m_Equipmented][w_id]][w_model]);
        s_Player[id][InHandWepInvSlot] = m_Equipmented;
      }
          
    }
    case CSW_SCOUT:
    {
      m_Equipmented = Equipmented[id][SCOUT];
      if(Inventory[id][m_Equipmented][w_Equiped] == 1)
      {
        entity_set_string(id, EV_SZ_viewmodel,  g_Weapon[Inventory[id][m_Equipmented][w_id]][w_model]);
        s_Player[id][InHandWepInvSlot] = m_Equipmented;
      }
          
    }
    default:
    {
      s_Player[id][InHandWepInvSlot] = -1;
    }
  }
}

public Hook_Say(id)
{
  if(!ska_is_user_logged(id))
  {
    client_print_color(id, print_team_default, "^4%s ^1Nem tudsz írni ameddig nem jelentkezel be!", Prefix);
    return PLUGIN_HANDLED;
  }

  new Message[512], Status[16], Num[5];

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
  || (contain(Message, "https://") != -1)
  || (contain(Message, ".io") != -1)
  || (contain(Message, ".tsdns.") != -1)
  || (contain(Message, "ts3.run") != -1)
  || (contain(Message, ".com") != -1)
  || (contain(Message, ".ro") != -1)
  || (contain(Message, ".hu") != -1))
    Num[4] = 1;

  if((Num[0] >= 3 && Num[1] >= 1 && Num[2] >= 8) || (Num[3] >= 3) || Num[4]){
    client_print_color(id, print_team_default,  "^4%s ^1 Tilos a hirdetés!", Prefix);
    return PLUGIN_HANDLED;
  }

  if(Message[0] == '@' || equal (Message, "") || Message[0] == '/')
    return PLUGIN_HANDLED;

  if(!is_user_alive(id))
    Status = "*Halott* ";

  new len;
  
  len += formatex(String[len], charsmax(String)-len, "^1%s", Status);

  if(s_AdminLevel[id] > 0 && s_Player[id][SilentAdminMod] == 0)
    len += formatex(String[len], charsmax(String)-len, "^4[%s]", Admin_Permissions[s_AdminLevel[id]][0]);
  
  if(!equali(s_Player[id][RankPrefix], ""))
    len += formatex(String[len], charsmax(String)-len, "^4[%s]", s_Player[id][RankPrefix]);
  
  if(s_AdminLevel[id] > 0 && s_Player[id][SilentAdminMod] == 0)
    len += formatex(String[len], charsmax(String)-len, "^3%s:^4", Player_Stats[id][Name]);
  else
    len += formatex(String[len], charsmax(String)-len, "^3%s:^1", Player_Stats[id][Name]);
  
  format(Message, charsmax(Message), "%s %s", String, Message);

  for(new i; i < g_Maxplayers; i++)
  {
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

new Killer, Victim, HsKiller;

public deathM()
{
  Killer = read_data(1);
  Victim = read_data(2);
  HsKiller = read_data(3);

  if(Killer == Victim)
  {
    Player_Stats[Victim][Deaths]++;
    s_Player[Victim][RankPoint] += -2.0;
    return PLUGIN_HANDLED;
  }

  new m_InHandWepInvSlot = s_Player[Killer][InHandWepInvSlot];
  if(m_InHandWepInvSlot != -1 && Inventory[Killer][m_InHandWepInvSlot][w_Is_Stattrak])
  {
    Inventory[Killer][m_InHandWepInvSlot][w_Stattrak_Kills]++;
  }

  Player_Stats[Killer][Kills]++;
  Player_Stats[Victim][Deaths]++;
  s_Player[Victim][RankPoint] += -1.0;

  s_Player[Killer][RankPoint] += 1.0;
  if(HsKiller)
  {
    s_Player[Killer][RankPoint] += 0.2;
    Player_Stats[Killer][HSs]++;
  }

  RandomReward(Killer, 20, 10, 10);

  client_print_color(Victim, print_team_default, "^4%s ^1A gyilkosodnak ^4%i ^1HP-ja maradt!", Prefix, get_user_health(Killer));
  return PLUGIN_CONTINUE;
}

public HudX(id)
{
  new m_Index;
  if(is_user_alive(id))
    m_Index = id;
  else
    m_Index = entity_get_int(id, EV_INT_iuser2);
  
  if (!ska_is_user_logged(m_Index))
    return;
  if(s_Player[id][HudDisplayPlayerInfo] == 1)
  {
    new i_Seconds, i_Minutes, i_Hours, i_Days;
    i_Seconds = s_Player[m_Index][PlayTime] + get_user_time(m_Index);
    i_Minutes = i_Seconds / 60;
    i_Hours = i_Minutes / 60;
    i_Seconds = i_Seconds - i_Minutes * 60;
    i_Minutes = i_Minutes - i_Hours * 60;
    i_Days = i_Hours / 24;
    i_Hours = i_Hours - (i_Days * 24);
    
    set_hudmessage(255, 255, 255, 0.01, 0.15, 0, 6.0, 0.2, 0.0, 0.0, -1);
    formatex(String, 511, "Név: %s(#%i)!^n[ Dollár: %.2f$ ]^n[ Ölés: %i | HS: %i ]^n[ Halál: %i ]^n[ RangPont: %.3f ]^n[ Játszott idő: %i Nap %i Óra %i Perc ]", Player_Stats[m_Index][Name], ska_get_user_id(m_Index), s_Player[m_Index][Euro], Player_Stats[m_Index][Kills], Player_Stats[m_Index][HSs], Player_Stats[m_Index][Deaths], s_Player[m_Index][RankPoint], i_Days, i_Hours, i_Minutes);
    replace_all(String, 511, ".", ",");
    show_hudmessage(id, String);
  }

  new m_InHandWepInvSlot = s_Player[m_Index][InHandWepInvSlot];
  if(m_InHandWepInvSlot == -1)
    return;

  if(s_Player[id][HudDisplayWeaponInfo] == 1)
  {
    new Len;
    if(Inventory[m_Index][m_InHandWepInvSlot][w_Is_NameTaged] == 1)
      Len += formatex(StringHud[Len], charsmax(StringHud)-Len, "^"%s^"", Inventory[m_Index][m_InHandWepInvSlot][w_NameTag]);
    else
      Len += formatex(StringHud[Len], charsmax(StringHud)-Len, "%s", g_Weapon[Inventory[m_Index][m_InHandWepInvSlot][w_id]][w_name]);

    if(Inventory[m_Index][m_InHandWepInvSlot][w_Is_Stattrak] == 1)
      Len += formatex(StringHud[Len], charsmax(StringHud)-Len, " | Ölések:%i", Inventory[m_Index][m_InHandWepInvSlot][w_Stattrak_Kills]);

    if(m_InHandWepInvSlot > 7)
    {
      new m_w_Damage_Level = Inventory[m_Index][m_InHandWepInvSlot][w_Damage_Level];
      formatex(StringHud[Len], charsmax(StringHud)-Len, "^nHasználtság: %i%s",m_w_Damage_Level , "%");
      if(m_w_Damage_Level == 101)
      {
        set_hudmessage(255, 200, 0, -1.0, 0.72, 0, 0.0, 0.2, 0.0, 0.0, -1);
        formatex(StringHud[Len], charsmax(StringHud)-Len, "^nTörhetetlen");
      }
      else if(containi(Inventory[m_Index][m_InHandWepInvSlot][w_NameTag], "[R6S]") != -1)
      {
        set_hudmessage(random(255), random(255), random(255), -1.0, 0.72, 0, 0.0, 0.12, 0.0, 0.0, -1);
      }
      else if(m_w_Damage_Level > 10)
      {
        set_hudmessage(255, 255, 255, -1.0, 0.72, 0, 0.0, 0.2, 0.0, 0.0, -1);
      }
      else
      {
        set_hudmessage(255, 0, 0, -1.0, 0.72, 0, 0.0, 0.2, 0.0, 0.0, -1);
      }
    }
    else if(containi(Inventory[m_Index][m_InHandWepInvSlot][w_NameTag], "[R6S]") != -1)
    {
      set_hudmessage(random(255), random(255), random(255), -1.0, 0.72, 0, 0.0, 0.12, 0.0, 0.0, -1);
    }
    else
    {
      set_hudmessage(255, 255, 255, -1.0, 0.72, 0, 0.0, 0.2, 0.0, 0.0, -1);
    }
    show_hudmessage(id, StringHud);
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

public OpenCase(id, case_id)
{
  new Float:OverAll = 0.0;
  new Float:ChanceOld = 0.0;
  new Float:ChanceNow = 0.0;
  new OpenedWepID = 0;
  new Float:OpenedWepChance = 0.0;

  for(new i;i < CaseDrops_Openable;i++)
  {
    OverAll += CaseDrops[case_id][i][1];
  }
  new Float:RandomNumber = random_float(0.01,OverAll);

  for(new i = 0; i < CaseDrops_Openable;i++)
  {
    ChanceOld = ChanceNow;
    ChanceNow += CaseDrops[case_id][i][1];
    if(ChanceOld < RandomNumber < ChanceNow)
    {
      InventoryAddNewItem(id, floatround(CaseDrops[case_id][i][0]), 0, "", -1, 0, -1, 1);
      OpenedWepID = floatround(CaseDrops[case_id][i][0]);
      OpenedWepChance = CaseDrops[case_id][i][1];
      s_Player[id][Keys]--;
      Player_Cases[id][case_id]--;
    }
  }

  if(g_Weapon[OpenedWepID][w_type] == CSW_KNIFE)
  {
    client_print_color(0, print_team_default, "^4%s ^3%s ^1Nyitott:^4%s^1-t ebből:^4%s^1 ( Esélye:^4%.3f%s ^1)", Prefix, Player_Stats[id][Name], WeaponText(id, (s_Player[id][InventoryWriteableSize] - 1) ), g_CasesNames[case_id],(OpenedWepChance/(OverAll/100.0)),"%");
    for(new i;i < 33;i++)
    {
      if(s_Player[i][KnifeSoundPlay] == 1)
        client_cmd(i,"spk NextLvL/KnifeOpen");
    }
    
  }
  else
  {
    client_print_color(id, print_team_default, "^4%s ^1Nyitottál:^4%s^1-t ebből:^4%s^1 ( Esélye:^4%.3f%s ^1)", Prefix, WeaponText(id, (s_Player[id][InventoryWriteableSize] - 1) ), g_CasesNames[case_id],(OpenedWepChance/(OverAll/100.0)),"%");
  }   
}
public bomb_planted(id)
{
  if(g_PlayingPlayers >= 3)
    RandomReward(id, 20, 10, 10);
  client_print_color(0, print_team_red, "^4%s ^3%s ^1Élesítette a bombát!",Prefix, Player_Stats[id][Name]);
}
public bomb_defused(id)
{
  if(g_PlayingPlayers >= 3)
    RandomReward(id, 20, 10, 10);
  client_print_color(0, print_team_blue, "^4%s ^3%s ^1Hatástalanította a bombát!",Prefix, Player_Stats[id][Name]);
}
public RandomReward(id, Drop_VD, Drop_Case, Drop_Key)
{
  new len;
  new Float:MoneyReward = random_float(0.20, 0.60);
  s_Player[id][Euro] += MoneyReward;

  len += formatex(String[len], charsmax(String)-len, "Jutalom: ^4%.2f$", MoneyReward);

  new RND = random(Drop_VD);
  if(RND == 0)
  {
    new IFReward = random_num(1,5);
    s_Player[id][InfinityFragment] += IFReward;
    len += formatex(String[len], charsmax(String)-len, "^1 | ^4%iVD", IFReward);
  }

  RND = random(Drop_Key);
  if(RND == 0)
  {
    s_Player[id][Keys]++;
    len += formatex(String[len], charsmax(String)-len, "^1 | ^4Kulcs");
  }
  replace_all(String, 511, ".", ",");
  client_print_color(id, print_team_default, "^4%s ^1%s!", Prefix, String);

  RND = random(100000);
  if(RND == 0)
  {
    if((s_Player[id][InventoryWriteableSize]) < InventoryMAX)
    {
      InventoryAddNewItem(id, 48, 1, "", 0, 0, 100, 0);
      for(new i;i < 4; i++)
        client_print_color(0, print_team_default, "^4%s ^1ATYA ÉG! ^4%s kapott egy kést amire egy a tizezer az esély minden ölésnél!", Prefix);
    }
    else
    {
      client_print_color(0, print_team_default, "^4%s ^1ATYA ÉG! ^4%s KAPOTT VOLNA egy kést amire egy a tizezer az esély minden ölésnél!", Prefix);
    }
  }

  RND = random(Drop_Case);
  if(RND == 0)
  {
    DropCase(id);
  }
}

public DropCase(id)
{
  new Float:Chance = random_float(0.0, s_DropCaseChanceOverAll);
  new Float:ChanceOld = 0.0;
  new Float:ChanceNow = 0.0;

  new m_s_DropCaseChance_size = sizeof(s_DropCaseChance);
  for(new i; i < m_s_DropCaseChance_size; i++)
  {
    ChanceOld = ChanceNow;
    ChanceNow += s_DropCaseChance[i];
    if(ChanceOld < Chance < ChanceNow)
    {
      Player_Cases[id][i]++;
      client_print_color(id, print_team_default, "^4%s ^1Találtál egy: %s! ( Esélye ennek:^4%.2f%s ^1)", Prefix, g_CasesNames[i], (s_DropCaseChance[i]/(s_DropCaseChanceOverAll/100.0)), "%");
      i = m_s_DropCaseChance_size;
    }
  }
}


/*
?????? ????? ??? ?? ?? ??
?????? ????? ?????? ?? ??
?????? ????? ?????? ?? ??
?????? ????? ?????? ?? ??
?????? ????? ?? ??? ?????
?????? ????? ?? ??? ?????
*/

public MainMenu(id)
{
  if(!(ska_is_user_logged(id)))
    return PLUGIN_HANDLED;

  formatex(String, charsmax(String), "\r%s \y» \wFőmenü", Prefix);
  new menu = menu_create(String, "MainMenu_h");
  formatex(String, charsmax(String), "\wRaktár [\y%i\w/\r%i\w]", s_Player[id][InventorySize], s_Player[id][InventorySizeMax]);
  menu_additem(menu, String, "0", 0);
  
  menu_additem(menu, "\wLádák", "1", 0);

  menu_additem(menu, "\wÁruház", "2", 0);

  menu_additem(menu, "\wPiac", "3", 0);

  menu_additem(menu, "\wBeállítások", "4", 0);

  menu_additem(menu, "\wSzabályzat", "5", 0);

  menu_setprop(menu, MPROP_EXITNAME, "Kilépés");

  menu_display(id, menu, 0);
  return PLUGIN_HANDLED;
}

public MainMenu_h(id, menu, item)
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
      Inventory_Menu(id);
    }
    case 1:
    {
      Cases_Menu(id);
    }
    case 2:
    {
      Shop_Menu(id);
    }
    case 3:
    {
      Market_Menu(id);
    }
    case 4:
    {
      Settings_Menu(id);
    }
    case 5:
    {
      Rules_Menu(id);
    }
  }
  menu_destroy(menu);
}

public Rules_Menu(id)
{
  formatex(String, charsmax(String), "\r%s \y» \wSzabályzat", Prefix);
  new menu = menu_create(String, "Rules_Menu_h");

  menu_addtext2(menu, "\r*\wA szabályzat nem ismerése nem mentesít alóla!\r*");
  menu_addtext2(menu, "\rTILOS \wSGS/BGS/GS-ezni.\d(Max. 2 óra)");
  menu_addtext2(menu, "\rTILOS \wCT-nek CT kezdön kempelni.\d(Max. 1 óra)");
  menu_addtext2(menu, "\rTILOS \wT-nek meg fél perc után T kezdön.\d(Max. 1 óra)");
  menu_addtext2(menu, "\rTILOS \wcsúnya, obszcén, rasszista szavakat használni!\d(Max. 3 óra)");
  menu_addtext2(menu, "\rTILOS \wcsalni, bármilyen külsö fájlt/segédprogramot használni!\d(örök)");
  menu_addtext2(menu, "\rTILOS \wa scant adását vissza utasítani.\d(1 hét)");
  menu_addtext2(menu, "\rTILOS \wadminnak kiadni magad <jogok nélkül>\d(örök)");
  menu_addtext2(menu, "\rTILOS \wIP-t vagy Weboldalat reklámozni.\d(örök)");
  menu_addtext2(menu, "\rTILOS \wban alatt visszatérni a szerverre.\d(örök)");
  menu_addtext2(menu, "\rTILOS \wa szerver hibáit BUG-jait kihasználni.\d(Max. 1 nap)");
  menu_addtext2(menu, "\rA tulajoknak jogukban áll magasabb banidőt kiszabni!");
  menu_setprop(menu, MPROP_NEXTNAME, "Lapozás Előre");
  menu_setprop(menu, MPROP_BACKNAME, "Lapozás Vissza");
  menu_setprop(menu, MPROP_EXITNAME, "Vissza a Főmenübe");
  menu_display(id, menu, 0);
}

public Rules_Menu_h(id, menu, item)
{
  menu_destroy(menu);
  MainMenu(id);
  return;
}

public Market_Menu(id)
{
  formatex(String, charsmax(String), "\r%s \y» \wPiac", Prefix);
  new menu = menu_create(String, "Market_Menu_h");

  formatex(String, charsmax(String), "\wKeresés");
  menu_additem(menu, String, "1", 0);
  formatex(String, charsmax(String), "\wKeresési beállítások");
  menu_additem(menu, String, "2", 0);

  menu_setprop(menu, MPROP_EXITNAME, "Vissza a Főmenübe");
  menu_display(id, menu, 0);
}

public Market_Menu_h(id, menu, item)
{
  if(item == MENU_EXIT)
  {
    menu_destroy(menu);
    MainMenu(id);
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
      menu_destroy(menu);
      Market_Search(id);
    }
    case 2:
    {
      menu_destroy(menu);
      Market_SearchSettings(id);
    }
  }
}

public Market_Search(id)
{
  formatex(String, charsmax(String), "\r%s \y» \wPiac Keresésí találatok", Prefix);
  new menu = menu_create(String, "Market_Search_h");

  new m_g_Products_sizeof = ArraySize(g_Products);
  new m_Product[product_Properties];
  new NumStr[9];
  new UTS_TimeNow = parse_time("0", "%S",_);
  new m_WasValid = 0;

  for(new i; i < m_g_Products_sizeof;i++)
  {
    ArrayGetArray(g_Products ,i ,m_Product);

    if(m_Product[Price] < 0)
      continue;

    if(m_Product[UTS_EndTimeDate] < UTS_TimeNow)
    {
      ReturnFromMarket(i);
      continue;
    }

    switch(searchsettings_Player[id][SelectedSearchType])
    {
      case 0: //fegyver
      {
        if(m_Product[Type] != 0)
          continue;
        
        if(searchsettings_Player[id][weaponsearch_MinCost] <= m_Product[Price] <= searchsettings_Player[id][weaponsearch_MaxCost])
        {
          if(searchsettings_Player[id][weaponsearch_MinDamage] <= m_Product[p_w_Damage_Level] <= searchsettings_Player[id][weaponsearch_MaxDamage])
          {
            if(searchsettings_Player[id][weaponsearch_Stattrak] == -1 || (searchsettings_Player[id][weaponsearch_Stattrak] == 0 && m_Product[p_w_Is_Stattrak] == 0) || (searchsettings_Player[id][weaponsearch_Stattrak] == 1 && m_Product[p_w_Is_Stattrak] == 1))
            {
              switch(searchsettings_Player[id][weaponsearch_Type])
              {
                case -1:
                {
                  new len;
                  if(m_Product[p_w_Damage_Level] > 100)
                    len = formatex(String[len], charsmax(String) - len, "\y%i,0$ \w- \rÖrök", m_Product[Price]);
                  else
                    len = formatex(String[len], charsmax(String) - len, "\y%i,0$ \w- \r%i%s ",m_Product[Price], m_Product[p_w_Damage_Level], "%");
                  len += formatex(String[len], charsmax(String) - len, "\w%s", g_Weapon[m_Product[product_id]][w_name]);
                  if(m_Product[p_w_Is_Stattrak])
                    len += formatex(String[len], charsmax(String) - len, " \rST*");

                  if(m_Product[p_w_Is_NameTaged])
                    len += formatex(String[len], charsmax(String) - len, " \rNC*");

                  num_to_str(i, NumStr, 8);
                  menu_additem(menu, String, NumStr, 0);
                  m_WasValid = 1;
                }
                case 0:
                {
                  if(g_Weapon[m_Product[product_id]][w_type] == CSW_AK47)
                  {
                    new len;
                    if(m_Product[p_w_Damage_Level] > 100)
                      len = formatex(String[len], charsmax(String) - len, "\y%i,0$ \w- \rÖrök", m_Product[Price]);
                    else
                      len = formatex(String[len], charsmax(String) - len, "\y%i,0$ \w- \r%i%s ",m_Product[Price], m_Product[p_w_Damage_Level], "%");
                    len += formatex(String[len], charsmax(String) - len, "\w%s", g_Weapon[m_Product[product_id]][w_name]);
                    if(m_Product[p_w_Is_Stattrak])
                      len += formatex(String[len], charsmax(String) - len, " \rST*");

                    if(m_Product[p_w_Is_NameTaged])
                      len += formatex(String[len], charsmax(String) - len, " \rNC*");

                    num_to_str(i, NumStr, 8);
                    menu_additem(menu, String, NumStr, 0);
                    m_WasValid = 1;
                  }
                }
                case 1:
                {
                  if(g_Weapon[m_Product[product_id]][w_type] == CSW_AWP)
                  {
                    new len;
                    if(m_Product[p_w_Damage_Level] > 100)
                      len = formatex(String[len], charsmax(String) - len, "\y%i,0$ \w- \rÖrök", m_Product[Price]);
                    else
                      len = formatex(String[len], charsmax(String) - len, "\y%i,0$ \w- \r%i%s ",m_Product[Price], m_Product[p_w_Damage_Level], "%");
                    len += formatex(String[len], charsmax(String) - len, "\w%s", g_Weapon[m_Product[product_id]][w_name]);
                    if(m_Product[p_w_Is_Stattrak])
                      len += formatex(String[len], charsmax(String) - len, " \rST*");

                    if(m_Product[p_w_Is_NameTaged])
                      len += formatex(String[len], charsmax(String) - len, " \rNC*");

                    num_to_str(i, NumStr, 8);
                    menu_additem(menu, String, NumStr, 0);
                    m_WasValid = 1;
                  }
                }
                case 2:
                {
                  if(g_Weapon[m_Product[product_id]][w_type] == CSW_DEAGLE)
                  {
                    new len;
                    if(m_Product[p_w_Damage_Level] > 100)
                      len = formatex(String[len], charsmax(String) - len, "\y%i,0$ \w- \rÖrök", m_Product[Price]);
                    else
                      len = formatex(String[len], charsmax(String) - len, "\y%i,0$ \w- \r%i%s ",m_Product[Price], m_Product[p_w_Damage_Level], "%");
                    len += formatex(String[len], charsmax(String) - len, "\w%s", g_Weapon[m_Product[product_id]][w_name]);
                    if(m_Product[p_w_Is_Stattrak])
                      len += formatex(String[len], charsmax(String) - len, " \rST*");

                    if(m_Product[p_w_Is_NameTaged])
                      len += formatex(String[len], charsmax(String) - len, " \rNC*");

                    num_to_str(i, NumStr, 8);
                    menu_additem(menu, String, NumStr, 0);
                    m_WasValid = 1;
                  }
                }
                case 3:
                {
                  if(g_Weapon[m_Product[product_id]][w_type] == CSW_FAMAS)
                  {
                    new len;
                    if(m_Product[p_w_Damage_Level] > 100)
                      len = formatex(String[len], charsmax(String) - len, "\y%i,0$ \w- \rÖrök", m_Product[Price]);
                    else
                      len = formatex(String[len], charsmax(String) - len, "\y%i,0$ \w- \r%i%s ",m_Product[Price], m_Product[p_w_Damage_Level], "%");
                    len += formatex(String[len], charsmax(String) - len, "\w%s", g_Weapon[m_Product[product_id]][w_name]);
                    if(m_Product[p_w_Is_Stattrak])
                      len += formatex(String[len], charsmax(String) - len, " \rST*");

                    if(m_Product[p_w_Is_NameTaged])
                      len += formatex(String[len], charsmax(String) - len, " \rNC*");

                    num_to_str(i, NumStr, 8);
                    menu_additem(menu, String, NumStr, 0);
                    m_WasValid = 1;
                  }
                }
                case 4:
                {
                  if(g_Weapon[m_Product[product_id]][w_type] == CSW_M4A1)
                  {
                    new len;
                    if(m_Product[p_w_Damage_Level] > 100)
                      len = formatex(String[len], charsmax(String) - len, "\y%i,0$ \w- \rÖrök", m_Product[Price]);
                    else
                      len = formatex(String[len], charsmax(String) - len, "\y%i,0$ \w- \r%i%s ",m_Product[Price], m_Product[p_w_Damage_Level], "%");
                    len += formatex(String[len], charsmax(String) - len, "\w%s", g_Weapon[m_Product[product_id]][w_name]);
                    if(m_Product[p_w_Is_Stattrak])
                      len += formatex(String[len], charsmax(String) - len, " \rST*");

                    if(m_Product[p_w_Is_NameTaged])
                      len += formatex(String[len], charsmax(String) - len, " \rNC*");

                    num_to_str(i, NumStr, 8);
                    menu_additem(menu, String, NumStr, 0);
                    m_WasValid = 1;
                  }
                }
                case 5:
                {
                  if(g_Weapon[m_Product[product_id]][w_type] == CSW_MP5NAVY)
                  {
                    new len;
                    if(m_Product[p_w_Damage_Level] > 100)
                      len = formatex(String[len], charsmax(String) - len, "\y%i,0$ \w- \rÖrök", m_Product[Price]);
                    else
                      len = formatex(String[len], charsmax(String) - len, "\y%i,0$ \w- \r%i%s ",m_Product[Price], m_Product[p_w_Damage_Level], "%");
                    len += formatex(String[len], charsmax(String) - len, "\w%s", g_Weapon[m_Product[product_id]][w_name]);
                    if(m_Product[p_w_Is_Stattrak])
                      len += formatex(String[len], charsmax(String) - len, " \rST*");

                    if(m_Product[p_w_Is_NameTaged])
                      len += formatex(String[len], charsmax(String) - len, " \rNC*");

                    num_to_str(i, NumStr, 8);
                    menu_additem(menu, String, NumStr, 0);
                    m_WasValid = 1;
                  }
                }
                case 6:
                {
                  if(g_Weapon[m_Product[product_id]][w_type] == CSW_SCOUT)
                  {
                    new len;
                    if(m_Product[p_w_Damage_Level] > 100)
                      len = formatex(String[len], charsmax(String) - len, "\y%i,0$ \w- \rÖrök", m_Product[Price]);
                    else
                      len = formatex(String[len], charsmax(String) - len, "\y%i,0$ \w- \r%i%s ",m_Product[Price], m_Product[p_w_Damage_Level], "%");
                    len += formatex(String[len], charsmax(String) - len, "\w%s", g_Weapon[m_Product[product_id]][w_name]);
                    if(m_Product[p_w_Is_Stattrak])
                      len += formatex(String[len], charsmax(String) - len, " \rST*");

                    if(m_Product[p_w_Is_NameTaged])
                      len += formatex(String[len], charsmax(String) - len, " \rNC*");

                    num_to_str(i, NumStr, 8);
                    menu_additem(menu, String, NumStr, 0);
                    m_WasValid = 1;
                  } 
                } 
                case 7:
                {
                  if(g_Weapon[m_Product[product_id]][w_type] == CSW_KNIFE)
                  {
                    new len;
                    if(m_Product[p_w_Damage_Level] > 100)
                      len = formatex(String[len], charsmax(String) - len, "\y%i,0$ \w- \rÖrök", m_Product[Price]);
                    else
                      len = formatex(String[len], charsmax(String) - len, "\y%i,0$ \w- \r%i%s ",m_Product[Price], m_Product[p_w_Damage_Level], "%");
                    len += formatex(String[len], charsmax(String) - len, "\w%s", g_Weapon[m_Product[product_id]][w_name]);
                    if(m_Product[p_w_Is_Stattrak])
                      len += formatex(String[len], charsmax(String) - len, " \rST*");

                    if(m_Product[p_w_Is_NameTaged])
                      len += formatex(String[len], charsmax(String) - len, " \rNC*");

                    num_to_str(i, NumStr, 8);
                    menu_additem(menu, String, NumStr, 0);
                    m_WasValid = 1;
                  }
                }
              }
            }
          }
        }
      }
      case 1: //láda
      {
        if(m_Product[Type] != 1)
          continue;
        
        if(searchsettings_Player[id][casesearch_MinCost] <= m_Product[Price] <= searchsettings_Player[id][casesearch_MaxCost])
        {
          if(searchsettings_Player[id][casesearch_MinAmount] <= m_Product[Amount] <= searchsettings_Player[id][casesearch_MaxAmount])
          {
            switch(searchsettings_Player[id][casesearch_Type])
            {
              case -1:
              {
                formatex(String, charsmax(String), "\y%i,0$ \w- %s [\r%i\w]", m_Product[Price], g_CasesNames[m_Product[product_id]], m_Product[Amount]);
                num_to_str(i, NumStr, 8);
                menu_additem(menu, String, NumStr, 0);
                m_WasValid = 1;
              }
              case 0:
              {
                if(m_Product[product_id] == 0)
                {
                  formatex(String, charsmax(String), "\y%i,0$ \w- %s [\r%i\w]", m_Product[Price], g_CasesNames[m_Product[product_id]], m_Product[Amount]);
                  num_to_str(i, NumStr, 8);
                  menu_additem(menu, String, NumStr, 0);
                  m_WasValid = 1;
                }
              }
              case 1:
              {
                if(m_Product[product_id] == 1)
                {
                  formatex(String, charsmax(String), "\y%i,0$ \w- %s [\r%i\w]", m_Product[Price], g_CasesNames[m_Product[product_id]], m_Product[Amount]);
                  num_to_str(i, NumStr, 8);
                  menu_additem(menu, String, NumStr, 0);
                  m_WasValid = 1;
                }
              }
              case 2:
              {
                if(m_Product[product_id] == 2)
                {
                  formatex(String, charsmax(String), "\y%i,0$ \w- %s [\r%i\w]", m_Product[Price], g_CasesNames[m_Product[product_id]], m_Product[Amount]);
                  num_to_str(i, NumStr, 8);
                  menu_additem(menu, String, NumStr, 0);
                  m_WasValid = 1;
                }
              }
              case 3:
              {
                if(m_Product[product_id] == 3)
                {
                  formatex(String, charsmax(String), "\y%i,0$ \w- %s [\r%i\w]", m_Product[Price], g_CasesNames[m_Product[product_id]], m_Product[Amount]);
                  num_to_str(i, NumStr, 8);
                  menu_additem(menu, String, NumStr, 0);
                  m_WasValid = 1;
                }
              }
              case 4:
              {
                if(m_Product[product_id] == 4)
                {
                  formatex(String, charsmax(String), "\y%i,0$ \w- %s [\r%i\w]", m_Product[Price], g_CasesNames[m_Product[product_id]], m_Product[Amount]);
                  num_to_str(i, NumStr, 8);
                  menu_additem(menu, String, NumStr, 0);
                  m_WasValid = 1;
                }
              }
              case 5:
              {
                if(m_Product[product_id] == 5)
                {
                  formatex(String, charsmax(String), "\y%i,0$ \w- %s [\r%i\w]", m_Product[Price], g_CasesNames[m_Product[product_id]], m_Product[Amount]);
                  num_to_str(i, NumStr, 8);
                  menu_additem(menu, String, NumStr, 0);
                  m_WasValid = 1;
                }
              }
              //CASE EXTEND NEED HERE, Ha ládát akarsz böviteni itt is kell!
            }
          }
        }
      }
      case 2: //kulcs
      {
        if(m_Product[Type] != 2)
          continue;
        
        if(searchsettings_Player[id][keysearch_MinCost] <= m_Product[Price] <= searchsettings_Player[id][keysearch_MaxCost])
        {
          if(searchsettings_Player[id][keysearch_MinAmount] <= m_Product[Amount] <= searchsettings_Player[id][keysearch_MaxAmount])
          {
            formatex(String, charsmax(String), "\y%i,0$ \w- Kulcs [\r%i\w]", m_Product[Price], m_Product[Amount]);
            num_to_str(i, NumStr, 8);
            menu_additem(menu, String, NumStr, 0);
            m_WasValid = 1;
          }
        }
      }
      case 3: //Végtelen bisz basz
      {
        if(m_Product[Type] != 3)
          continue;
        
        if(searchsettings_Player[id][infinityfragmentsearch_MinCost] <= m_Product[Price] <= searchsettings_Player[id][infinityfragmentsearch_MaxCost])
        {
          if(searchsettings_Player[id][infinityfragmentsearch_MinAmount] <= m_Product[Amount] <= searchsettings_Player[id][infinityfragmentsearch_MaxAmount])
          {
            formatex(String, charsmax(String), "\y%i,0$ \w- Végtelen Darabka [\r%i\w]", m_Product[Price], m_Product[Amount]);
            num_to_str(i, NumStr, 8);
            menu_additem(menu, String, NumStr, 0);
            m_WasValid = 1;
          }
        }
      }
      case 4: //Játékos
      {
        if(m_Product[Seller_User_id] != searchsettings_Player[id][playersearch_User_id])
          continue;

        switch(m_Product[Type])
        {
          case 0://fegyver
          {
            new len;
            if(m_Product[p_w_Damage_Level] > 100)
              len = formatex(String[len], charsmax(String) - len, "\y%i,0$ \w- \rÖrök", m_Product[Price]);
            else
              len = formatex(String[len], charsmax(String) - len, "\y%i,0$ \w- \r%i%s ",m_Product[Price], m_Product[p_w_Damage_Level], "%");
            
            len += formatex(String[len], charsmax(String) - len, "\w%s", g_Weapon[m_Product[product_id]][w_name]);
            if(m_Product[p_w_Is_Stattrak])
              len += formatex(String[len], charsmax(String) - len, " \rST*");
            
            if(m_Product[p_w_Is_NameTaged])
              len += formatex(String[len], charsmax(String) - len, " \rNC*");

            num_to_str(i, NumStr, 8);
            menu_additem(menu, String, NumStr, 0);
            m_WasValid = 1;
          }
          case 1://Láda
          {
            formatex(String, charsmax(String), "\y%i,0$ \w- %s [\r%i\w]", m_Product[Price], g_CasesNames[m_Product[product_id]], m_Product[Amount]);
            num_to_str(i, NumStr, 8);
            menu_additem(menu, String, NumStr, 0);
            m_WasValid = 1;
          }
          case 2://Kulcs
          {
            formatex(String, charsmax(String), "\y%i,0$ \w- Kulcs [\r%i\w]", m_Product[Price], m_Product[Amount]);
            num_to_str(i, NumStr, 8);
            menu_additem(menu, String, NumStr, 0);
            m_WasValid = 1;
          }
          case 3://végtelen biszbasz
          {
            formatex(String, charsmax(String), "\y%i,0$ \w- Végtelen Darabka [\r%i\w]", m_Product[Price], m_Product[Amount]);
            num_to_str(i, NumStr, 8);
            menu_additem(menu, String, NumStr, 0);
            m_WasValid = 1;
          }
        }
      }
    }
  }

  menu_setprop(menu, MPROP_NEXTNAME, "Lapozás Előre");
  menu_setprop(menu, MPROP_BACKNAME, "Lapozás Vissza");
  menu_setprop(menu, MPROP_EXITNAME, "Vissza a Piac menübe");

  if(m_WasValid)
    menu_display(id, menu, 0);
  else
  {
    client_print_color(id, print_team_default, "^4%s ^1Nincs találat!", Prefix);
    menu_destroy(menu);
    Market_Menu(id);
  }
}

public Market_Search_h(id, menu, item)
{
  if(item == MENU_EXIT)
  {
    menu_destroy(menu);
    Market_Menu(id);
    return;
  }
  new data[9], szName[64];
  new access, callback;
  menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
  new key = str_to_num(data);

  s_Player[id][MarketSelectedSlot] = key;

  menu_destroy(menu);
  Market_ProductInfo(id);
}

public Market_ProductInfo(id)
{
  formatex(String, charsmax(String), "\r%s \y» \wÁrucikk leírás", Prefix);
  new menu = menu_create(String, "Market_ProductInfo_h");

  new m_Product[product_Properties];
  ArrayGetArray(g_Products, s_Player[id][MarketSelectedSlot], m_Product);

  if(m_Product[Seller_User_id] == ska_get_user_id(id))
  {
    formatex(String, charsmax(String), "\rTörlés a piacról \d[%i.0$]", m_Product[Price]);
    menu_additem(menu, String, "-1", 0);
  }
  else
  {
    if(m_Product[Price] <= s_Player[id][Euro])
      formatex(String, charsmax(String), "\yVásárlás \w- \r%i.0$", m_Product[Price]);
    else
      formatex(String, charsmax(String), "\dVásárlás \w- \r%i.0$", m_Product[Price]);
    menu_additem(menu, String, "1", 0);
  }
  
  menu_addblank2(menu);
  new StringTime[32];
  format_time(StringTime, 31, "%Y/%m/%d - %H:%M:%S", m_Product[UTS_EndTimeDate]);
  formatex(String, charsmax(String), "\wLejárat:\r%s", StringTime);
  menu_addtext2(menu, String);
  switch(m_Product[Type])
  {
    case 0://fegyver
    {
      formatex(String, charsmax(String), "\wFegyver Eredeti neve: \r%s",g_Weapon[m_Product[product_id]][w_name]);
      menu_addtext2(menu, String);

      if(m_Product[p_w_Damage_Level] > 100)
        formatex(String, charsmax(String), "\wHasználtság: \rTörhetetlen");
      else
        formatex(String, charsmax(String), "\wHasználtság: \r%i%s", m_Product[p_w_Damage_Level], "%");
      menu_addtext2(menu, String);

      if(m_Product[p_w_Is_NameTaged])
        formatex(String, charsmax(String), "\wNévcédula: \r^"%s^"", m_Product[p_w_NameTag]);
      else
        formatex(String, charsmax(String), "\wNévcédula: \dNincs");
      menu_addtext2(menu, String);

      if(m_Product[p_w_Is_Stattrak])
        formatex(String, charsmax(String), "\wStatTrak: \r%i", m_Product[p_w_Stattrak_Kills]);
      else
        formatex(String, charsmax(String), "\wStatTark: \d-");
      menu_addtext2(menu, String);
    }
    case 1://láda
    {
      formatex(String, charsmax(String), "\wLáda neve: \r%s",g_Weapon[m_Product[product_id]][w_name]);
      menu_addtext2(menu, String);
      formatex(String, charsmax(String), "\wMennyiség: \r%i",m_Product[Amount]);
      menu_addtext2(menu, String);
    }
    case 2://kulcs
    {
      formatex(String, charsmax(String), "\wÁrucikk: \rKulcs");
      menu_addtext2(menu, String);
      formatex(String, charsmax(String), "\wMennyiség: \r%i",m_Product[Amount]);
      menu_addtext2(menu, String);
    }
    case 3://végtelen biszbasz
    {
      formatex(String, charsmax(String), "\wÁrucikk: \rVégtelen darabka");
      menu_addtext2(menu, String);
      formatex(String, charsmax(String), "\wMennyiség: \r%i",m_Product[Amount]);
      menu_addtext2(menu, String);
    }
  }

  menu_setprop(menu, MPROP_EXITNAME, "Vissza a Keresési találatokhoz");
  menu_display(id, menu, 0);
}

public Market_ProductInfo_h(id, menu, item)
{
  if(item == MENU_EXIT)
  {
    menu_destroy(menu);
    Market_Search(id);
    return;
  }
  new data[9], szName[64];
  new access, callback;
  menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
  new key = str_to_num(data);
  if(key == 1)
  {
    BuyFromMarket(id, s_Player[id][MarketSelectedSlot]);
  }
  else if(key == -1)
  {
    ReturnFromMarket(s_Player[id][MarketSelectedSlot]);
  }
  menu_destroy(menu);
  Market_Search(id);
}

public Market_SearchSettings(id)
{
  formatex(String, charsmax(String), "\r%s \y» \wKeresési beállítások", Prefix);
  new menu = menu_create(String, "Market_SearchSettings_h");

  switch(searchsettings_Player[id][SelectedSearchType])
  {
    case 0:
    {
      formatex(String, charsmax(String), "\yFegyver alapú \w[\y%i\w/\r5\w]", (searchsettings_Player[id][SelectedSearchType]+1));
      menu_additem(menu, String, "0", 0);
      
      switch(searchsettings_Player[id][weaponsearch_Type])
      {
        case -1:
          formatex(String, charsmax(String), "\wFegyver Tipus:\rMind");
        case 0:
          formatex(String, charsmax(String), "\wFegyver Tipus:\rAK47");
        case 1:
          formatex(String, charsmax(String), "\wFegyver Tipus:\rAWP");
        case 2:
          formatex(String, charsmax(String), "\wFegyver Tipus:\rDEAGLE");
        case 3:
          formatex(String, charsmax(String), "\wFegyver Tipus:\rFAMAS");
        case 4:
          formatex(String, charsmax(String), "\wFegyver Tipus:\rM4A1");
        case 5:
          formatex(String, charsmax(String), "\wFegyver Tipus:\rMP5");
        case 6:
          formatex(String, charsmax(String), "\wFegyver Tipus:\rSCOUT");
        case 7:
          formatex(String, charsmax(String), "\wFegyver Tipus:\rKÉS");
      }
      menu_additem(menu, String, "1", 0);


      if(searchsettings_Player[id][weaponsearch_MaxDamage] >= 101)
        formatex(String, charsmax(String), "\wMax használtság:\rTörhetetlen");
      else
        formatex(String, charsmax(String), "\wMax használtság:\r%i%s", searchsettings_Player[id][weaponsearch_MaxDamage], "%");
      menu_additem(menu, String, "2", 0);


      if(searchsettings_Player[id][weaponsearch_MinDamage] >= 101)
        formatex(String, charsmax(String), "\wMin használtság:\rTörhetetlen");
      else
        formatex(String, charsmax(String), "\wMin használtság:\r%i%s", searchsettings_Player[id][weaponsearch_MinDamage], "%");
      menu_additem(menu, String, "3", 0);
      

      formatex(String, charsmax(String), "\wMax ár:\r%i$", searchsettings_Player[id][weaponsearch_MaxCost]);
      menu_additem(menu, String, "4", 0);
      formatex(String, charsmax(String), "\wMin ár:\r%i$", searchsettings_Player[id][weaponsearch_MinCost]);
      menu_additem(menu, String, "5", 0);

      switch(searchsettings_Player[id][weaponsearch_Stattrak])
      {
        case -1:
          formatex(String, charsmax(String), "\wStatTrak:\rMind");
        case 0:
          formatex(String, charsmax(String), "\wStatTrak:\rNem");
        case 1:
          formatex(String, charsmax(String), "\wStatTrak:\rIgen");
      }
      menu_additem(menu, String, "6", 0);
      
      
      switch(searchsettings_Player[id][weaponsearch_Nametag])
      {
        case -1:
          formatex(String, charsmax(String), "\wNévcédula:\rMind");
        case 0:
          formatex(String, charsmax(String), "\wNévcédula:\rNem");
        case 1:
          formatex(String, charsmax(String), "\wNévcédula:\rIgen");
      }
      menu_additem(menu, String, "7", 0);
    }
    case 1:
    {
      formatex(String, charsmax(String), "\yLáda alapú \w[\y%i\w/\r5\w]", (searchsettings_Player[id][SelectedSearchType]+1));
      menu_additem(menu, String, "0", 0);

      if(searchsettings_Player[id][casesearch_Type] == -1)
        formatex(String, charsmax(String), "\wLáda Tipus:\rMind");
      else
        formatex(String, charsmax(String), "\wLáda Tipus:\r%s", g_CasesNames[searchsettings_Player[id][casesearch_Type]]);
      menu_additem(menu, String, "1", 0);


      formatex(String, charsmax(String), "\wMax mennyiség:\r%i db", searchsettings_Player[id][casesearch_MaxAmount]);
      menu_additem(menu, String, "2", 0);
      formatex(String, charsmax(String), "\wMin mennyiség:\r%i db", searchsettings_Player[id][casesearch_MaxAmount]);
      menu_additem(menu, String, "3", 0);
      formatex(String, charsmax(String), "\wMax ár:\r%i$", searchsettings_Player[id][casesearch_MaxCost]);
      menu_additem(menu, String, "4", 0);
      formatex(String, charsmax(String), "\wMin ár:\r%i$", searchsettings_Player[id][casesearch_MinCost]);
      menu_additem(menu, String, "5", 0);
    }
    case 2://kulcs
    {
      formatex(String, charsmax(String), "\yKulcs alapú \w[\y%i\w/\r5\w]", (searchsettings_Player[id][SelectedSearchType]+1));
      menu_additem(menu, String, "0", 0);

      formatex(String, charsmax(String), "\wMax mennyiség:\r%i db", searchsettings_Player[id][keysearch_MaxAmount]);
      menu_additem(menu, String, "2", 0);
      formatex(String, charsmax(String), "\wMin mennyiség:\r%i db", searchsettings_Player[id][keysearch_MaxAmount]);
      menu_additem(menu, String, "3", 0);
      formatex(String, charsmax(String), "\wMax ár:\r%i$", searchsettings_Player[id][keysearch_MaxCost]);
      menu_additem(menu, String, "4", 0);
      formatex(String, charsmax(String), "\wMin ár:\r%i$", searchsettings_Player[id][keysearch_MinCost]);
      menu_additem(menu, String, "5", 0);
    }
    case 3://végtelen biszbasz
    {
      formatex(String, charsmax(String), "\yVégtelen darabka alapú \w[\y%i\w/\r5\w]", (searchsettings_Player[id][SelectedSearchType]+1));
      menu_additem(menu, String, "0", 0);

      formatex(String, charsmax(String), "\wMax mennyiség:\r%i db", searchsettings_Player[id][infinityfragmentsearch_MaxAmount]);
      menu_additem(menu, String, "2", 0);
      formatex(String, charsmax(String), "\wMin mennyiség:\r%i db", searchsettings_Player[id][infinityfragmentsearch_MaxAmount]);
      menu_additem(menu, String, "3", 0);
      formatex(String, charsmax(String), "\wMax ár:\r%i$", searchsettings_Player[id][infinityfragmentsearch_MaxCost]);
      menu_additem(menu, String, "4", 0);
      formatex(String, charsmax(String), "\wMin ár:\r%i$", searchsettings_Player[id][infinityfragmentsearch_MinCost]);
      menu_additem(menu, String, "5", 0);
    }
    case 4://player
    {
      formatex(String, charsmax(String), "\yJátékos alapú \w[\y%i\w/\r5\w]", (searchsettings_Player[id][SelectedSearchType]+1));
      menu_additem(menu, String, "0", 0);

      formatex(String, charsmax(String), "\wOnline játékos lista:\r%i", searchsettings_Player[id][playersearch_User_id]);
      menu_additem(menu, String, "1", 0);
      formatex(String, charsmax(String), "\w#id alapján:\r%i", searchsettings_Player[id][playersearch_User_id]);
      menu_additem(menu, String, "2", 0);
    }
  }

  menu_setprop(menu, MPROP_NEXTNAME, "Lapozás Előre");
  menu_setprop(menu, MPROP_BACKNAME, "Lapozás Vissza");
  menu_setprop(menu, MPROP_EXITNAME, "Vissza a Piac menübe");
  menu_display(id, menu, 0);
}

public Market_SearchSettings_h(id, menu, item)
{
  if(item == MENU_EXIT)
  {
    menu_destroy(menu);
    Market_Menu(id);
    return;
  }
  new data[9], szName[64];
  new access, callback;
  menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
  new key = str_to_num(data);
  
  if(key == 0)
  {
    if(searchsettings_Player[id][SelectedSearchType] < 4)
      searchsettings_Player[id][SelectedSearchType]++;
    else
      searchsettings_Player[id][SelectedSearchType] = 0;
    Market_SearchSettings(id);
  }
  else
  {
    switch(searchsettings_Player[id][SelectedSearchType])
    {
      case 0:
      {
        switch(key)
        {
          case 1: //fegyver alapú
          {
            if(searchsettings_Player[id][weaponsearch_Type] < 7)
              searchsettings_Player[id][weaponsearch_Type]++;
            else
              searchsettings_Player[id][weaponsearch_Type] = -1;
            Market_SearchSettings(id);
          }
          case 2:
            client_cmd(id, "messagemode MaxHasznaltsag");
          case 3:
            client_cmd(id, "messagemode MinHasznaltsag");
          case 4:
            client_cmd(id, "messagemode MaxAr");
          case 5:
            client_cmd(id, "messagemode MinAr");
          case 6:
          {
            if(searchsettings_Player[id][weaponsearch_Stattrak] < 1)
              searchsettings_Player[id][weaponsearch_Stattrak]++;
            else
              searchsettings_Player[id][weaponsearch_Stattrak] = -1;
            Market_SearchSettings(id);
          }
          case 7:
          {
            if(searchsettings_Player[id][weaponsearch_Nametag] < 1)
              searchsettings_Player[id][weaponsearch_Nametag]++;
            else
              searchsettings_Player[id][weaponsearch_Nametag] = -1;
            Market_SearchSettings(id);
          }
        }
      }
      case 1: //láda alapú
      {
        switch(key)
        {
          case 1:
          {
            if(searchsettings_Player[id][casesearch_Type] < CaseDrops_CaseNum-1)
              searchsettings_Player[id][casesearch_Type]++;
            else
              searchsettings_Player[id][casesearch_Type] = -1;
            Market_SearchSettings(id);
          }
          case 2:
            client_cmd(id, "messagemode MaxMennyiseg");
          case 3:
            client_cmd(id, "messagemode MinMennyiseg");
          case 4:
            client_cmd(id, "messagemode MaxAr");
          case 5:
            client_cmd(id, "messagemode MinAr");
        }
      }
      case 2..3: //kulcs / végtelen biszbasz alapú
      {
        switch(key)
        {
          case 2:
            client_cmd(id, "messagemode MaxMennyiseg");
          case 3:
            client_cmd(id, "messagemode MinMennyiseg");
          case 4:
            client_cmd(id, "messagemode MaxAr");
          case 5:
            client_cmd(id, "messagemode MinAr");
        }
      }
      case 4: //játékos alapó
      {
        switch(key)
        {
          case 1:
            {
              SelectPlayerFromOnline(id);
            }
          case 2:
            client_cmd(id, "messagemode idmegad");
        }
      }
    }
  }
  menu_destroy(menu);
}

public SelectPlayerFromOnline(id)
{
  formatex(String, charsmax(String), "\r%s \y» \wJátékos kiválasztása",Prefix);
  new menu = menu_create(String, "SelectPlayerFromOnline_h");

  new Players[32], iNum;
  get_players(Players, iNum, "ch");
  new Player
  new NumStr[9];
  new m_WasValuedUser = 0;
  for (new i=0; i<iNum; i++)
  {
    Player = Players[i];
    if(ska_is_user_logged(Player) && Player != id)
    {
      num_to_str(ska_get_user_id(Player), NumStr, 8);
      formatex(String, charsmax(String), "%s(#%s)", Player_Stats[Player][Name], NumStr);
      menu_additem(menu, String, NumStr, 0);
      m_WasValuedUser = 1;
    }
  }

  menu_setprop(menu, MPROP_NEXTNAME, "Lapozás Előre");
  menu_setprop(menu, MPROP_BACKNAME, "Lapozás Vissza");
  menu_setprop(menu, MPROP_EXITNAME, "Vissza a Keresési beállítások");
  
  if(m_WasValuedUser)
    menu_display(id, menu, 0);
  else
  {
    client_print_color(id, print_team_default, "^4%s ^1Nincs senki bejelentkezve a szerveren rajtad kivül :c !",Prefix);
    menu_destroy(menu);
  }
}

public SelectPlayerFromOnline_h(id, menu, item)
{
  if(item == MENU_EXIT)
  {
    menu_destroy(menu);
    Market_SearchSettings(id);
    return;
  }
  new data[9], szName[64];
  new access, callback;
  menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
  new key = str_to_num(data);

  searchsettings_Player[id][playersearch_User_id] = key;

  menu_destroy(menu);
  Market_SearchSettings(id);
}

public Shop_Menu(id)
{
  s_Player[id][ShopTypedAmount] = 1;
  
  formatex(String, charsmax(String), "\r%s \y» \wÁruház", Prefix);
  new menu = menu_create(String, "Shop_Menu_h");

  formatex(String, charsmax(String), "\y%.1f$ \w- StatTrak felszerelő [\r%i\w]",Cost_ToolsStattrak, s_Player[id][ToolsStattrak]);
  replace_all(String, 511, ".", ",");
  menu_additem(menu, String, "1", 0);
  formatex(String, charsmax(String), "\y%.1f$ \w- Névcédula felszerelő [\r%i\w]",Cost_ToolsNametag, s_Player[id][ToolsNametag]);
  replace_all(String, 511, ".", ",");
  menu_additem(menu, String, "2", 0);

  formatex(String, charsmax(String), "\y%.1f$ \w- 1 raktár férőhely [\r%i/%i\w]",Cost_InventoryExtend, s_Player[id][InventorySizeMax], InventoryMaxExtend);
  replace_all(String, 511, ".", ",");
  menu_additem(menu, String, "3", 0);

  menu_setprop(menu, MPROP_NEXTNAME, "Lapozás Előre");
  menu_setprop(menu, MPROP_BACKNAME, "Lapozás Vissza");
  menu_setprop(menu, MPROP_EXITNAME, "Vissza a Főmenübe");
  menu_display(id, menu, 0);
}

public Shop_Menu_h(id, menu, item)
{
  if(item == MENU_EXIT)
  {
    menu_destroy(menu);
    MainMenu(id);
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
      Shop_Info(id, key);
    }
    case 2:
    {
      Shop_Info(id, key);
    }
    case 3:
    {
      Shop_Info(id, key);
    }
  }
  menu_destroy(menu);
}

public Shop_Info(id, m_ShopSelectedSlot)
{
  formatex(String, charsmax(String), "\r%s \y» \wÁruház Termék Info", Prefix);
  new menu = menu_create(String, "Shop_Info_h");

  
  new len;
  if(m_ShopSelectedSlot == 1 && s_Player[id][Euro] >= Cost_ToolsStattrak) //STATRÁK vásárlása
    len += formatex(String[len], charsmax(String) - len, "\y");
  else if(m_ShopSelectedSlot == 2 && s_Player[id][Euro] >= Cost_ToolsNametag) //NÉVCÉDULA vásrlás
    len += formatex(String[len], charsmax(String) - len, "\y");
  else if(m_ShopSelectedSlot == 3 && s_Player[id][Euro] >= (Cost_InventoryExtend * float(s_Player[id][ShopTypedAmount])))
    len += formatex(String[len], charsmax(String) - len, "\y");
  else
    len += formatex(String[len], charsmax(String) - len, "\d");
    

  len += formatex(String[len], charsmax(String) - len, "Vásárlás");
  if(m_ShopSelectedSlot == 3 && s_Player[id][ShopTypedAmount] > 1)
  {
    len += formatex(String[len], charsmax(String) - len, " \w- \r%.1f$", Cost_InventoryExtend * float(s_Player[id][ShopTypedAmount]));
  }
  replace_all(String, 511, ".", ",");
  menu_additem(menu, String, "1", 0);
  
  len = 0;
  switch(m_ShopSelectedSlot)
  {
    case 1: //Statrak leírás
    {
      len = formatex(String, charsmax(String), "\rA StatTrak:\w^n");
      len += formatex(String[len], charsmax(String) - len, "  -Fegyver kiegészítő^n");
      len += formatex(String[len], charsmax(String) - len, "  -Számolja az öléseket^n");
      len += formatex(String[len], charsmax(String) - len, "  -A fegyverinfo hud-on kijelzi^n");
      len += formatex(String[len], charsmax(String) - len, "  -ujra felszereléssel nullázodik");
    }
    case 2: //névcédula leírás
    {
      len = formatex(String, charsmax(String), "\rA Névcédula:\w^n");
      len += formatex(String[len], charsmax(String) - len, "  -Fegyver kiegészítő^n");
      len += formatex(String[len], charsmax(String) - len, "  -Eltudod vele nevezni^n");
      len += formatex(String[len], charsmax(String) - len, "  -A fegyverinfo hud-on kijelzi^n");
      len += formatex(String[len], charsmax(String) - len, "  -ujra felszereléssel átnevezhető");
    }
    case 3:
    {
      formatex(String, charsmax(String), "\yMennyiség megadása \w- \r%i", s_Player[id][ShopTypedAmount]);
      menu_additem(menu, String, "2", 0);
      len = formatex(String, charsmax(String), "\rRaktár férőhely\w^n");
      len += formatex(String[len], charsmax(String) - len, "  -Maximum ennyi fegyver lehet a raktáradban^n");
      len += formatex(String[len], charsmax(String) - len, "  -Maximum %i-ig tudod bövíteni^n", InventoryMaxExtend);
    }
  }
  menu_addblank2(menu);
  menu_addtext2(menu, String);
  
  menu_setprop(menu, MPROP_EXITNAME, "Vissza az Áruházba");
  s_Player[id][ShopSelectedSlot] = m_ShopSelectedSlot;
  menu_display(id, menu, 0);
}

public Shop_Info_h(id, menu, item)
{
  if(item == MENU_EXIT)
  {
    menu_destroy(menu);
    Shop_Menu(id);
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
      switch(s_Player[id][ShopSelectedSlot])
      {
        case 1:
        {
          if(s_Player[id][Euro] >= Cost_ToolsStattrak)
          {
            s_Player[id][Euro] -= Cost_ToolsStattrak;
            s_Player[id][ToolsStattrak]++;
            client_print_color(id, print_team_default, "^4%s ^1Sikeresen megvetted a StatTrak felszerelést.", Prefix);
          }
          else
            client_print_color(id, print_team_default, "^4%s ^1Nincs elég pénzed hogy megvedd a StatTrak felszerelést.", Prefix);
        }
        case 2:
        {
          if(s_Player[id][Euro] >= Cost_ToolsNametag)
          {
            s_Player[id][Euro] -= Cost_ToolsNametag;
            s_Player[id][ToolsNametag]++;
            client_print_color(id, print_team_default, "^4%s ^1Sikeresen megvetted a Névcédula felszerelést.", Prefix);
          }
          else
            client_print_color(id, print_team_default, "^4%s ^1Nincs elég pénzed hogy megvedd a Névcédula felszerelést.", Prefix);
        }
        case 3:
        {
          if(s_Player[id][ShopTypedAmount] + s_Player[id][InventorySizeMax] <= InventoryMaxExtend)
          {
            if(s_Player[id][Euro] >= (Cost_InventoryExtend * float(s_Player[id][ShopTypedAmount])) )
            {
              s_Player[id][Euro] -= (Cost_InventoryExtend * float(s_Player[id][ShopTypedAmount]) );
              s_Player[id][InventorySizeMax] += s_Player[id][ShopTypedAmount];
              client_print_color(id, print_team_default, "^4%s ^1Sikeresen megvetted a Raktár férőhelyet.", Prefix);
            }
            else
              client_print_color(id, print_team_default, "^4%s ^1Nincs elég pénzed hogy megvedd az raktár bövítés(eket)!", Prefix);
          }
          else
            client_print_color(id, print_team_default, "^4%s ^1Ezzel a vásárlással túllépnéd a raktár maximum méretét!", Prefix);
        }
      }
      Shop_Info(id, s_Player[id][ShopSelectedSlot]);
    }
    case 2:
    {
      client_cmd(id, "messagemode Mennyiseg");
    }
  }
  
  menu_destroy(menu);
}


public Settings_Menu(id)
{
  formatex(String, charsmax(String), "\r%s \y» \wBeállítások", Prefix);
  new menu = menu_create(String, "Settings_Menu_h");

  // HUD Infó [Egyszerű | Részletes | Kikapcsolva]
  menu_additem(menu, s_Player[id][SkinDisplay] == 1 ? "Fegyver kinézet: \r[BE] \y| \d[KI]":"Fegyver kinézet: \d[BE] \y| \r[KI]", "1", 0);
  menu_additem(menu, s_Player[id][HudDisplayPlayerInfo] == 1 ? "\w[\rHUD\w]Játékos info: \r[BE] \y| \d[KI]":"\w[\rHUD\w]Játékos info: \d[BE] \y| \r[KI]", "2", 0);
  menu_additem(menu, s_Player[id][HudDisplayWeaponInfo] == 1 ? "\w[\rHUD\w]Fegyver info: \r[BE] \y| \d[KI]":"\w[\rHUD\w]Fegyver info: \d[BE] \y| \r[KI]", "3", 0);
  menu_additem(menu, s_Player[id][SoundPlay] == 1 ? "\w[\rHANG\w]Ölés: \r[BE] \y| \d[KI]":"\w[\rHANG\w]Ölés: \d[BE] \y| \r[KI]", "4", 0);
  menu_additem(menu, s_Player[id][RoundEndSoundPlay] == 1 ? "\w[\rHANG\w]Körvégi: \r[BE] \y| \d[KI]":"\w[\rHANG\w]Körvégi: \d[BE] \y| \r[KI]", "5", 0);
  menu_additem(menu, s_Player[id][KnifeSoundPlay] == 1 ? "\w[\rHANG\w]Kés nyitás: \r[BE] \y| \d[KI]":"\w[\rHANG\w]Kés nyitás: \d[BE] \y| \r[KI]", "6", 0);
  menu_additem(menu, s_Player[id][CanSendMe] == 1 ? "\w[\rKÜLDÉS\w]Tárgyak fogadása: \r[BE] \y| \d[KI]":"\w[\rKÜLDÉS\w]Tárgyak fogadása: \d[BE] \y| \r[KI]", "7", 0);
  menu_additem(menu, s_Player[id][SilentTransfer] == 1 ? "\w[\rKÜLDÉS\w]Csendes küldés/fogadás: \r[BE] \y| \d[KI]":"\w[\rKÜLDÉS\w]Csendes küldés/fogadás: \d[BE] \y| \r[KI]", "8", 0);
  menu_additem(menu, s_Player[id][Ranking] == 1 ? "ChatRangPrefix: \r[BE] \y| \d[KI]":"ChatRangPrefix: \d[BE] \y| \r[KI]", "9", 0);
  if(s_AdminLevel[id] > 0)
    menu_additem(menu, s_Player[id][SilentAdminMod] == 1 ? "InkognitóAdmin: \r[BE] \y| \d[KI]":"InkognitóAdmin: \d[BE] \y| \r[KI]", "10", 0);
  //"
  menu_setprop(menu, MPROP_NEXTNAME, "Lapozás Előre");
  menu_setprop(menu, MPROP_BACKNAME, "Lapozás Vissza");
  menu_setprop(menu, MPROP_EXITNAME, "Vissza a Főmenübe");
  menu_display(id, menu, 0);
}
public Settings_Menu_h(id, menu, item)
{
  if(item == MENU_EXIT)
  {
    menu_destroy(menu);
    MainMenu(id);
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
      s_Player[id][SkinDisplay] = !s_Player[id][SkinDisplay];
    }
    case 2:
    {
      s_Player[id][HudDisplayPlayerInfo] = !s_Player[id][HudDisplayPlayerInfo];
    }
    case 3:
    {
      s_Player[id][HudDisplayWeaponInfo] = !s_Player[id][HudDisplayWeaponInfo];
    }
    case 4:
    {
      s_Player[id][SoundPlay] = !s_Player[id][SoundPlay];
    }
    case 5:
    {
      s_Player[id][RoundEndSoundPlay] = !s_Player[id][RoundEndSoundPlay];
      new fwdtogglemusic
      ExecuteForward(fwd_musiccmd,fwdtogglemusic,id);
    }
    case 6:
    {
      s_Player[id][KnifeSoundPlay] = !s_Player[id][KnifeSoundPlay];
    }
    case 7:
    {
      s_Player[id][CanSendMe] = !s_Player[id][CanSendMe];
    }
    case 8:
    {
      s_Player[id][SilentTransfer] = !s_Player[id][SilentTransfer];
    }
    case 9:
    {
      s_Player[id][Ranking] = !s_Player[id][Ranking];
    }
    case 10:
    {
      s_Player[id][SilentAdminMod] = !s_Player[id][SilentAdminMod];
    }
  }
  Settings_Menu(id);
  menu_destroy(menu);
}

public Cases_Menu(id)
{
  formatex(String, charsmax(String), "\r%s \y» \wLádák [\rKulcs:\y%i\w]",Prefix, s_Player[id][Keys]);
  new menu = menu_create(String, "Cases_Menu_h");

  new m_g_CasesNames_size = sizeof(g_CasesNames);
  for(new i;i < m_g_CasesNames_size;i++)
  {
    formatex(String, charsmax(String), "\w%s [\r%i\w]", g_CasesNames[i], Player_Cases[id][i]);

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
    MainMenu(id);
    return;
  }
  new data[9], szName[64];
  new access, callback;
  menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
  new key = str_to_num(data);
  
  if(key == (CaseDrops_CaseNum - 1))
  {
    client_print_color(id, print_team_default, "^4%s ^1A láda megszerezhető, de még nem nyítható!",Prefix);
    Cases_Menu(id);
  }
  else
  {
    s_Player[id][CaseSelectedSlot] = key;
    CaseInfo(id);
  }
  
  menu_destroy(menu);
  
}

public CaseInfo(id)
{
  formatex(String, charsmax(String), "\r%s \y» \w%s Információ [\rKulcs:\y%i\w]",Prefix,g_CasesNames[s_Player[id][CaseSelectedSlot]], s_Player[id][Keys]);
  new menu = menu_create(String, "CaseInfo_h");

  if(InventoryCanAdd(id, "") == 1 && Player_Cases[id][s_Player[id][CaseSelectedSlot]] > 0 && s_Player[id][Keys] > 0)
    formatex(String, charsmax(String), "\yNyitás");
  else
    formatex(String, charsmax(String), "\dNyitás");
  menu_additem(menu, String, "0", 0);

  formatex(String, charsmax(String), "\wTartalom megtekintése");
  menu_additem(menu, String, "1", 0);

  if(Player_Cases[id][s_Player[id][CaseSelectedSlot]] > 0)
    formatex(String, charsmax(String), "\yPiacra helyezés");
  else
    formatex(String, charsmax(String), "\dPiacra helyezés");
  menu_additem(menu, String, "2", 0);

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
      if(InventoryCanAdd(id, "Megtelt a Raktárad! (Az áruházban tudod bövíteni)") == 1)
      {
        if(Player_Cases[id][s_Player[id][CaseSelectedSlot]] > 0)
        {
          if(s_Player[id][Keys] > 0)
          {
            OpenCase(id, s_Player[id][CaseSelectedSlot]);
          }
          else
          {
            client_print_color(id, print_team_default, "^4%s ^1Nincs kulcsod!",Prefix);
          }
        }
        else
        {
          client_print_color(id, print_team_default, "^4%s ^1Nincs ilyen ládád!",Prefix);
        }
      }
      CaseInfo(id);
    }
    case 1:
    {
      ShowCaseContent(id, s_Player[id][CaseSelectedSlot]);
      CaseInfo(id);
    }
    case 2:
    {
      if(Player_Cases[id][s_Player[id][CaseSelectedSlot]] > 0)
      {
        s_Player[id][TypedMarketAmount] = 1;
        s_Player[id][TypedMarketPrice] = 0;
        PlaceOnMarket_Menu(id, 1);
      }
      else
        client_print_color(id, print_team_default, "^4%s ^1Nincs ilyen ládád!",Prefix);
    }
  }
  menu_destroy(menu);
}

public ShowCaseContent(id, m_CaseSelectedSlot)
{
  new len;
  
  len += formatex(StringMotd[len], charsmax(StringMotd) - len, "<!DOCTYPE html> <html><head><meta charset=^"UTF-8^">");
  len += formatex(StringMotd[len], charsmax(StringMotd) - len, "</head><body style=^"background-color: rgb(100, 100, 100);^">");
  len += formatex(StringMotd[len], charsmax(StringMotd) - len, "<table border=^"5^" bordercolor=^"White^" align=^"center^" style=^"color: White^">");
  len += formatex(StringMotd[len], charsmax(StringMotd) - len, "<tr><th colspan=^"3^" bgcolor=#6B6B6B><h1>Ezeket nyithatod ebből:</br> <a style=^"color: #00dc00^">%s</a></h1></th>", g_CasesNames[m_CaseSelectedSlot]);
  len += formatex(StringMotd[len], charsmax(StringMotd) - len, "</tr><tr><th>Kép</th><th>Név</th><th>Esély</th></tr>");

  new Float:OverAll = 0.0;

  for(new i;i < CaseDrops_Openable;i++)
  {
        OverAll += CaseDrops[m_CaseSelectedSlot][i][1];
  }
  for(new i; i < CaseDrops_Openable; i++)
  {
    if(CaseDrops[m_CaseSelectedSlot][i][0] != 0.0)
    {
      len += formatex(StringMotd[len], charsmax(StringMotd) - len, "<tr><td><img src=^"%s^"/></th>", g_Weapon[floatround(CaseDrops[m_CaseSelectedSlot][i][0])][w_ImgLink]);
      len += formatex(StringMotd[len], charsmax(StringMotd) - len, "<td>%s</th>", g_Weapon[floatround(CaseDrops[m_CaseSelectedSlot][i][0])][w_name]);
      len += formatex(StringMotd[len], charsmax(StringMotd) - len, "<td>%.4f%s </th></tr>", (CaseDrops[m_CaseSelectedSlot][i][1]/(OverAll/100.0)), "%");
    }
  }

  len += formatex(StringMotd[len], charsmax(StringMotd) - len, "</table></body><html>");
  
  formatex(String, charsmax(String), "%s | Láda tartalom", Prefix);
  show_motd(id, StringMotd, String);
}


public Inventory_Menu(id)
{
  if((s_Player[id][InventorySize]) == 0)
  {
    MainMenu(id);
    client_print_color(id, print_team_default, "^4%s ^1Üres a raktárad!",Prefix)
    return PLUGIN_HANDLED;
  }

  formatex(String, charsmax(String), "\r%s \y» \wRaktár [\y%i\w/\r%i\w]",Prefix, s_Player[id][InventorySize], s_Player[id][InventorySizeMax]);
  new menu = menu_create(String, "Inventory_Menu_h");

  new m_InventoryWriteableSize = s_Player[id][InventoryWriteableSize];
  for(new i;i < m_InventoryWriteableSize; i++)
  {
    Item = Inventory[id][i];
    if(Item[w_Deleted] == 0)
    {
      new Len;
      if(Item[w_Equiped] > 0)
        Len += formatex(String[Len], charsmax(String), "\r! ");
      if(Item[w_Damage_Level] == 0)
        Len += formatex(String[Len], charsmax(String), "\r%i%s \d",Item[w_Damage_Level], "%");
      else if(Item[w_Damage_Level] == 101)
        Len += formatex(String[Len], charsmax(String), "\rÖrök \w");
      else
        Len += formatex(String[Len], charsmax(String), "\r%i%s \w",Item[w_Damage_Level], "%");
      
      Len += formatex(String[Len], charsmax(String), "%s", g_Weapon[Item[w_id]][w_name]);
      
      if(Item[w_Is_Stattrak] == 1 || Item[w_Is_NameTaged] == 1)
      {
        Len += formatex(String[Len], charsmax(String), " - ");
        
        if(Item[w_Is_Stattrak] == 1)
          Len += formatex(String[Len], charsmax(String), "\r*StatTrak* ", Item[w_Stattrak_Kills]);
  
        if(Item[w_Is_NameTaged] == 1)
          Len += formatex(String[Len], charsmax(String), "\r*Névcédula*");
      }
      new Num[4];
      num_to_str(i, Num, 4);
      menu_additem(menu, String, Num, 0);
    }
  }
  
  menu_setprop(menu, MPROP_NEXTNAME, "Lapozás Előre");
  menu_setprop(menu, MPROP_BACKNAME, "Lapozás Vissza");
  menu_setprop(menu, MPROP_EXITNAME, "Vissza a Főmenübe");

  menu_display(id, menu, 0);
  return PLUGIN_HANDLED;
}

public Inventory_Menu_h(id, menu, item)
{
  if(item == MENU_EXIT)
  {
    menu_destroy(menu);
    MainMenu(id);
    return;
  }
  new data[9], szName[64];
  new access, callback;
  menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
  new key = str_to_num(data);
  
  WeaponInfo(id, key);
  s_Player[id][InventorySelectedSlot] = key;
  menu_destroy(menu);
  
}

public WeaponInfoDetails(id)
{
  formatex(String, charsmax(String), "\r%s \y» \wRészletes leírás",Prefix);
  new menu = menu_create(String, "WeaponInfoDetails_h");

  new m_InventorySelectedSlot = s_Player[id][InventorySelectedSlot];
  formatex(String, charsmax(String), "\wEredeti Név: \r%s", g_Weapon[Inventory[id][m_InventorySelectedSlot][w_id]][w_name]);
  menu_addtext2( menu, String);
  
  if(Inventory[id][m_InventorySelectedSlot][w_Damage_Level] == 101)
    formatex(String, charsmax(String), "\wHasználhatoság: \rTörhetetlen");
  else
    formatex(String, charsmax(String), "\wHasználhatoság: \r%i%s", Inventory[id][m_InventorySelectedSlot][w_Damage_Level],"%");
  menu_addtext2( menu, String);
  

  if(Inventory[id][m_InventorySelectedSlot][w_Is_NameTaged] == 1)
  {
    formatex(String, charsmax(String), "\wNévcélula: \r%s", Inventory[id][m_InventorySelectedSlot][w_Is_NameTaged]);
  }
  else
  {
    formatex(String, charsmax(String), "\wNévcélula: \d Nincs");
  }
  menu_addtext2( menu, String);
  

  if(Inventory[id][m_InventorySelectedSlot][w_Is_Stattrak] == 1)
  {
    formatex(String, charsmax(String), "\wStatTrak ölések: \r%i", Inventory[id][m_InventorySelectedSlot][w_Stattrak_Kills]);
  }
  else
  {
    formatex(String, charsmax(String), "\wStatTrak ölések: \d-");
  }
  menu_addtext2( menu, String);
  

  if(Inventory[id][m_InventorySelectedSlot][w_Tradable] == 1)
  {
    formatex(String, charsmax(String), "\wÉrtékesíthető: \rIgen");
  }
  else
  {
    formatex(String, charsmax(String), "\wÉrtékesíthető: \dNem");
  }
  menu_addtext2( menu, String);
  
  menu_setprop(menu, MPROP_EXITNAME, "Vissza a Raktárba");

  menu_display(id, menu, 0);
}

public WeaponInfoDetails_h(id, menu, item)
{
  if(item == MENU_EXIT)
  {
    menu_destroy(menu);
    WeaponInfo(id, s_Player[id][InventorySelectedSlot]);
    return;
  }
}

public WeaponInfo(id, SelectedWep)
{
  if(!(ska_is_user_logged(id)))
    return PLUGIN_HANDLED;

  formatex(String, charsmax(String), "\r%s \y» \wFegyver kezelés [#w_%i]", Prefix, Inventory[id][SelectedWep][w_id]);
  new menu = menu_create(String, "WeaponInfo_h");
  new AddedNum = 0;
  if(IsEquipWeapon(id,SelectedWep) == 1)
  {
    formatex(String, charsmax(String), "\yLeszerelés");
    menu_additem(menu, String, "0", 0); AddedNum++;
  }
  else
  {
    if(Inventory[id][SelectedWep][w_Damage_Level] == 0)
      formatex(String, charsmax(String), "\dFelszerelés");
    else
      formatex(String, charsmax(String), "\yFelszerelés");
    menu_additem(menu, String, "1", 0); AddedNum++;
  }

  menu_additem(menu, "\yRészletes leírás", "5", 0); AddedNum++;
  
  
  if(Inventory[id][SelectedWep][w_Damage_Level] <= 0)
    formatex(String, charsmax(String), "\yHelyreállítás \w- \r%.1f$", Cost_WeaponRestore);
  else if(Inventory[id][SelectedWep][w_Damage_Level] == 100)
    formatex(String, charsmax(String), "\dJavítás \w- \r%.1f$/1%s",Cost_WeaponRepair,"%");
  else if(Inventory[id][SelectedWep][w_Damage_Level] < 100)
    formatex(String, charsmax(String), "\yJavítás \w- \r%.1f$/1%s",Cost_WeaponRepair,"%");
  else if(Inventory[id][SelectedWep][w_Damage_Level] == 101)
    formatex(String, charsmax(String), "\dTörhetetlen");
  replace_all(String, 511, ".", ",");
  menu_additem(menu, String, "2", 0); AddedNum++;


  if(Inventory[id][SelectedWep][w_Is_Stattrak] == 0)
  {
    if(s_Player[id][ToolsStattrak] >= 1)
      formatex(String, charsmax(String), "\yStatTrak Felszerelése \w[\r%i\w]", s_Player[id][ToolsStattrak]);
    else
      formatex(String, charsmax(String), "\dStatTrak Felszerelése \w[\r%i\w]", s_Player[id][ToolsStattrak]);
  }
  else
  {
    if(s_Player[id][ToolsStattrak] >= 1)
      formatex(String, charsmax(String), "\yStatTrak nullázása \w[\r%i\w]", s_Player[id][ToolsStattrak]);
    else
      formatex(String, charsmax(String), "\dStatTrak nullázása \w[\r%i\w]", s_Player[id][ToolsStattrak]);
  }
  menu_additem(menu, String, "6", 0); AddedNum++;


  if(Inventory[id][SelectedWep][w_Is_NameTaged] == 0)
  {
    if(s_Player[id][ToolsNametag] >= 1)
      formatex(String, charsmax(String), "\yNévcédula Felszerelése \w[\r%i\w]", s_Player[id][ToolsNametag]);
    else
      formatex(String, charsmax(String), "\dNévcédula Felszerelése \w[\r%i\w]", s_Player[id][ToolsNametag]);
  }
  else
  {
    if(s_Player[id][ToolsNametag] >= 1)
      formatex(String, charsmax(String), "\yÚjra elnevezés \w[\r%i\w]", s_Player[id][ToolsNametag]);
    else
      formatex(String, charsmax(String), "\dÚjra elnevezés \w[\r%i\w]", s_Player[id][ToolsNametag]);
  }
  menu_additem(menu, String, "7", 0); AddedNum++;


  if(Inventory[id][SelectedWep][w_Damage_Level] != 101)
  {
      if(s_Player[id][InfinityFragment] < Cost_WeaponMakePermanent)
        formatex(String, charsmax(String), "\dVéglegesítés \w[\d%i/%i]",s_Player[id][InfinityFragment],Cost_WeaponMakePermanent);
      else
        formatex(String, charsmax(String), "\yVéglegesítés \w[\d%i/%i]",s_Player[id][InfinityFragment],Cost_WeaponMakePermanent);
      menu_additem(menu, String, "4", 0); AddedNum++;
  }

  

  if(Inventory[id][SelectedWep][w_id] <= 7)
    formatex(String, charsmax(String), "\dÖsszetörés");
  else
  {
    if(Inventory[id][SelectedWep][w_Damage_Level] < 101)
      formatex(String, charsmax(String), "\rÖsszetörés \w[\r+%i\wVégtelen darabka]", floatround((Inventory[id][SelectedWep][w_Damage_Level])/10.0));
    else
      formatex(String, charsmax(String), "\rÖsszetörés \w[\r+%i\wVégtelen darabka]", Return_BreakPermanent);
  }
  menu_additem(menu, String, "3", 0); AddedNum++;


  if(Inventory[id][SelectedWep][w_Tradable] == 1)
    formatex(String, charsmax(String), "\yKüldés");
  else
    formatex(String, charsmax(String), "\dKüldés");
  menu_additem(menu, String, "8", 0); AddedNum++;

  if(Inventory[id][SelectedWep][w_Tradable] == 1)
    formatex(String, charsmax(String), "\yPiacra helyezés");
  else
    formatex(String, charsmax(String), "\dPiacra helyezés");
  menu_additem(menu, String, "9", 0); AddedNum++;

  if(AddedNum < 9)
  {
    new for_size = 9 - AddedNum;
    for(new i;i < for_size;i++)
      menu_addblank2(menu);
  }
  menu_additem(menu, "Vissza a Raktárba", "10", 0);
  menu_setprop( menu, MPROP_PERPAGE, 0 );
  menu_display(id, menu, 0);
  return PLUGIN_HANDLED;
}

public WeaponInfo_h(id, menu, item)
{
  new data[9], szName[64];
  new access, callback;
  menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
  new key = str_to_num(data);
  new m_InventorySelectedSlot = s_Player[id][InventorySelectedSlot];
  switch(key)
  {
    case 0: //leszerelés
      {
        DeEquipWeapon(id, m_InventorySelectedSlot);
        WeaponInfo(id, m_InventorySelectedSlot);
      }
    case 1: //felszerelés
      {
        if(Inventory[id][m_InventorySelectedSlot][w_Damage_Level] <= 0)
          client_print_color(id, print_team_default, "^4%s ^1A teljesen elhasznált fegyvert nem tudod felszerelni!",Prefix);
        else
          EquipWeapon(id, m_InventorySelectedSlot);
        WeaponInfo(id, m_InventorySelectedSlot);
      }
    case 2: //javitás/helyreállítás
      {
        RepairWeapon(id, m_InventorySelectedSlot);
        WeaponInfo(id, m_InventorySelectedSlot);
      }
    case 3: // összetörés
      {
        if(Inventory[id][m_InventorySelectedSlot][w_id] <= 7)
        {
            client_print_color(id, print_team_default, "^4%s ^1Az alap skineket nem tudod összetörni!",Prefix);
            WeaponInfo(id, m_InventorySelectedSlot);
        }
        else
        {
            InventoryDeleteItem(id, m_InventorySelectedSlot);
            Inventory_Menu(id);
        }
      }
    case 4: //Véglegesítés
    {
      if(s_Player[id][InfinityFragment] < Cost_WeaponMakePermanent)
        client_print_color(id, print_team_default, "^4%s ^1Még hiányzik ^4%i ^1végtelen darabka a véglegesítéshez!",Prefix, (Cost_WeaponMakePermanent - s_Player[id][InfinityFragment]));
      else
        WeaponMakePermanent(id, m_InventorySelectedSlot);
      WeaponInfo(id, m_InventorySelectedSlot);
    }
    case 5: // fegyver részletes információ
    {
      WeaponInfoDetails(id);
    }
    case 6: // StatTrak felszerelés/nullázás
    {
      if(s_Player[id][ToolsStattrak] >= 1)
        ItemAddStatTrak(id, m_InventorySelectedSlot);
      else
        client_print_color(id, print_team_default, "^4%s ^1Előbb vásárolj StatTrak felszerelőt!",Prefix);
      WeaponInfo(id, m_InventorySelectedSlot);
    }
    case 7: // Névcédula
    {
      if(s_Player[id][ToolsNametag] >= 1)
        client_cmd(id, "messagemode Nevcedula");
      else
      {
        client_print_color(id, print_team_default, "^4%s ^1Előbb vásárolj Névcédulát!",Prefix);
        WeaponInfo(id, m_InventorySelectedSlot);
      }
    }
    case 8: // Küldés
    {
      if(Inventory[id][m_InventorySelectedSlot][w_Tradable] == 1)
      {
        SelectTarget(id);
      }
      else
      {
        client_print_color(id, print_team_default, "^4%s ^1Ezt nem tudod elküldeni mert nem értékesíthető!",Prefix);
        WeaponInfo(id, m_InventorySelectedSlot);
      }
    }
    case 9: // kihelyezés piacra
    {
      if(Inventory[id][m_InventorySelectedSlot][w_Tradable] == 1)
      {
        s_Player[id][TypedMarketAmount] = 1;
        s_Player[id][TypedMarketPrice] = 0;
        PlaceOnMarket_Menu(id, 0);
      }
      else
      {
        client_print_color(id, print_team_default, "^4%s ^1Ezt nem tudod Piacra helyezni mert nem értékesíthető!",Prefix);
        WeaponInfo(id, m_InventorySelectedSlot);
      }
    }
    case 10:
    {
      menu_destroy(menu);
      Inventory_Menu(id);
      return;
    }
  }
  
  menu_destroy(menu);
}



public SelectTarget(id)
{
  formatex(String, charsmax(String), "\r%s \y» \wJátékos kiválasztása",Prefix);
  new menu = menu_create(String, "SelectTarget_h");

  new Players[32], iNum;
  get_players(Players, iNum, "ch");
  new Player
  new NumStr[2];
  new m_WasValuedUser = 0;
  for (new i=0; i<iNum; i++)
  {
    Player = Players[i];
    if(ska_is_user_logged(Player) && Player != id)
    {
      switch(s_Player[Player][CanSendMe])
      {
        case 1:
        {
          num_to_str(Player, NumStr, 2);
          formatex(String, charsmax(String), "\w%s(#%i)", Player_Stats[Player][Name], ska_get_user_id(Player));
          menu_additem(menu, String, NumStr, 0);
          m_WasValuedUser = 1;
        }
        case 0:
        {
          formatex(String, charsmax(String), "\d%s(#%i)", Player_Stats[Player][Name], ska_get_user_id(Player));
          menu_additem(menu, String, "-1", 0);
        }
      }
    }
  }

  if(m_WasValuedUser)
    menu_display(id, menu, 0);
  else
  {
    client_print_color(id, print_team_default, "^4%s ^1Nincs senki a szerveren akinek küldhetnél :c !",Prefix);
    menu_destroy(menu);
  }
  
}

public SelectTarget_h(id, menu, item)
{
  if(item == MENU_EXIT)
  {
    menu_destroy(menu);
    WeaponInfo(id, s_Player[id][InventorySelectedSlot]);
    return;
  }
  new data[9], szName[64];
  new access, callback;
  menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
  new key = str_to_num(data);
  
  switch(key)
  {
    case -1:
    {
      client_print_color(id, print_team_default, "^4%s ^1A kiválasztott játékosnak kivan kapcsolva a tárgyak fogadása!",Prefix);
      SelectTarget(id);
    }
    default:
    {
      InventorySendItem(id, s_Player[id][InventorySelectedSlot], key);
      Inventory_Menu(id);
    }
  }
  menu_destroy(menu);
}

PlaceOnMarket_Menu(id, m_Type)
{
  formatex(String, charsmax(String), "\r%s \y» \wPiacra helyezés",Prefix);
  new menu = menu_create(String, "PlaceOnMarket_Menu_h");

  switch(m_Type)
  {
    case 0: // fegyver
    {
      s_Player[id][PreMarketSelectedType] = 0;

      {
        Item = Inventory[id][s_Player[id][InventorySelectedSlot]];
        new len;
        if(Item[w_Damage_Level] > 100)
          len = formatex(String[len], charsmax(String) - len, "Árucikk:\rÖrök - ");
        else
          len = formatex(String[len], charsmax(String) - len, "Árucikk:\r%i%s - ", Item[w_Damage_Level], "%");
        len += formatex(String[len], charsmax(String) - len, "%s", g_Weapon[Item[w_id]][w_name]);
        if(Item[w_Is_Stattrak])
          len += formatex(String[len], charsmax(String) - len, " ST*");

        if(Item[w_Is_NameTaged])
          len += formatex(String[len], charsmax(String) - len, " NC*");
      }
      menu_addtext2(menu, String);
      menu_addblank2(menu);
    }
    case 1: //láda
    {
      s_Player[id][PreMarketSelectedType] = 1;

      formatex(String, charsmax(String), "Árucikk:\r%s", g_CasesNames[s_Player[id][CaseSelectedSlot]]);
      menu_addtext2(menu, String);
      menu_addblank2(menu);

      formatex(String, charsmax(String), "Mennyiség:\r%i", s_Player[id][TypedMarketAmount]);
      menu_additem(menu, String, "0", 0);
    }
    case 2: //kulcs
    {
      s_Player[id][PreMarketSelectedType] = 2;
      
      formatex(String, charsmax(String), "Árucikk:\rKulcs");
      menu_addtext2(menu, String);
      menu_addblank2(menu);

      formatex(String, charsmax(String), "Mennyiség:\r%i", s_Player[id][TypedMarketAmount]);
      menu_additem(menu, String, "0", 0);
    }
    case 3: //Végtelen biszbasz
    {
      s_Player[id][PreMarketSelectedType] = 3;

      formatex(String, charsmax(String), "Árucikk:\rVégtelen darabka");
      menu_addtext2(menu, String);
      menu_addblank2(menu);

      formatex(String, charsmax(String), "Mennyiség:\r%i", s_Player[id][TypedMarketAmount]);
      menu_additem(menu, String, "0", 0);
    }
  }
  formatex(String, charsmax(String), "Eladási ár:%i,0$", s_Player[id][TypedMarketPrice]);
  menu_additem(menu, String, "1", 0);
  
  if(s_Player[id][MarketSize] >= Market_MaxProduct)
  {
    formatex(String, charsmax(String), "\dPiacra helyezés \w[\y%i\w/\r%i\w]", s_Player[id][MarketSize], Market_MaxProduct);
    menu_additem(menu, String, "-1", 0);
  }
  else
  {
    formatex(String, charsmax(String), "\yPiacra helyezés \w[\y%i\w/\r%i\w]", s_Player[id][MarketSize], Market_MaxProduct);
    menu_additem(menu, String, "2", 0);
  }
  
  menu_display(id, menu, 0);
}

public PlaceOnMarket_Menu_h(id, menu, item)
{
  if(item == MENU_EXIT)
  {
    menu_destroy(menu);
    switch(s_Player[id][PreMarketSelectedType])
    {
      case 0:
        WeaponInfo(id, s_Player[id][InventorySelectedSlot]);
      case 1:
        CaseInfo(id);
      case 2:
        {}//Need to fill
      case 3:
        {}//Need to fill
    }
    return;
  }
  new data[9], szName[64];
  new access, callback;
  menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
  new key = str_to_num(data);
  menu_destroy(menu);

  switch(key)
  {
    case -1:
    {
      client_print_color(id, print_team_default, "^4%s ^1Megtelt a Piac kapacításod!", Prefix);
      PlaceOnMarket_Menu(id, s_Player[id][PreMarketSelectedType]);
    }
    case 0:
      client_cmd(id, "messagemode PiaciMennyiseg");
    case 1:
      client_cmd(id, "messagemode PiaciAr");
    case 2:
    {
      switch(s_Player[id][PreMarketSelectedType])
      {
        case 0:
          PlaceOnMarket(id, s_Player[id][PreMarketSelectedType], s_Player[id][InventorySelectedSlot], s_Player[id][TypedMarketPrice], s_Player[id][TypedMarketAmount]);
        case 1:
        {
          if(Player_Cases[id][s_Player[id][CaseSelectedSlot]] < s_Player[id][TypedMarketAmount])
          {
            client_print_color(id, print_team_default, "^4%s ^1Nincs annyi ládád amennyit ki akarsz rakni!", Prefix);
          }
          else
            PlaceOnMarket(id, s_Player[id][PreMarketSelectedType], s_Player[id][CaseSelectedSlot], s_Player[id][TypedMarketPrice], s_Player[id][TypedMarketAmount]);
        }
        case 2:
        {
          if(s_Player[id][Keys] < s_Player[id][TypedMarketAmount])
          {
            client_print_color(id, print_team_default, "^4%s ^1Nincs annyi kulcsod amennyit ki akarsz rakni!", Prefix);
          }
          else
            PlaceOnMarket(id, s_Player[id][PreMarketSelectedType], 0, s_Player[id][TypedMarketPrice], s_Player[id][TypedMarketAmount]);
        }
        case 3:
        {
          if(s_Player[id][InfinityFragment] < s_Player[id][TypedMarketAmount])
          {
            client_print_color(id, print_team_default, "^4%s ^1Nincs annyi végtelen darabkád amennyit ki akarsz rakni!", Prefix);
          }
          else
            PlaceOnMarket(id, s_Player[id][PreMarketSelectedType], 0,s_Player[id][TypedMarketPrice], s_Player[id][TypedMarketAmount]);
        }
      }
    }
  }
}

/*
?????? ????? ??? ?? ?? ??   ????? ??? ?? ?????
?????? ????? ?????? ?? ??   ????? ?????? ?????
?????? ????? ?????? ?? ??   ????? ??????  ????
?????? ????? ?????? ?? ??   ????? ??????  ????
?????? ????? ?? ??? ?????   ????? ?? ??? ?????
?????? ????? ?? ??? ?????   ????? ?? ??? ?????
*/


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
      // There was an error matching against the pattern
      // Check the {error} variable for message, and {ret} for error code
    }
    case REGEX_PATTERN_FAIL:
    {
      log_amx("---REGEX TATTERN ERROR---");
      log_amx("ERROR:");
      log_amx(error);
      // There is an error in your pattern
      // Check the {error} variable for message, and {ret} for error code
    }
    case REGEX_NO_MATCH:
    {
      client_print_color(id, print_team_default, "^4%s ^1%s",Prefix, NoMatchText);
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

public ReturnFromMarket(MarketSlot)
{
  new m_Product[product_Properties];
  ArrayGetArray(g_Products, MarketSlot, m_Product);
  new Seller_id = UserOnline(m_Product[Seller_User_id]);
  if(Seller_id != -1)
  {
    switch(m_Product[Type])
    {
      case 0:
      {
        if(InventoryCanAdd(Seller_id, "") == -1)
        {
          return;
        }

        Item[SQL_Key] = -1;
        Item[w_UserId] = m_Product[Seller_User_id];
        Item[w_id] = m_Product[product_id];
        Item[w_Is_NameTaged] = m_Product[p_w_Is_NameTaged];
        copy(Item[w_NameTag], 31, m_Product[p_w_NameTag]);
        Item[w_Is_Stattrak] = m_Product[p_w_Is_Stattrak];
        Item[w_Stattrak_Kills] = m_Product[p_w_Stattrak_Kills];
        Item[w_Damage_Level] = m_Product[p_w_Damage_Level];
        Item[w_Tradable] = 1;
        Item[w_Equiped] = 0;
        Item[w_Deleted] = 0;

        Inventory[Seller_id][s_Player[Seller_id][InventoryWriteableSize]] = Item;
        s_Player[Seller_id][InventoryWriteableSize]++;
        s_Player[Seller_id][InventorySize]++;
      }
      case 1:
      {
        Player_Cases[Seller_id][m_Product[product_id]] += m_Product[Amount];
      }
      case 2:
      {
        s_Player[Seller_id][Keys] += m_Product[Amount];
      }
      case 3:
      {
        s_Player[Seller_id][InfinityFragment] += m_Product[Amount];
      }
    }
    s_Player[Seller_id][MarketSize]--;
    client_print_color(Seller_id, print_team_default, "^4%s ^1Az egyik árucikked lejárt a Piacon vagy vissza kérted!", Prefix);
  }
  else
  {
    new Len;
    switch(m_Product[Type])
    {
      case 0:
      {
        Len = formatex(Query, charsmax(Query), "INSERT INTO `NextLvL_g_Inventory` (`User_Id`, `Weapon_Id`, `Is_NameTaged`, `NameTag`, `Is_StatTraked`, `StatTrak_Kills`, `Damage_Level`, `AttackCount`, `Tradable`, `Equiped`) VALUES (");
        Len += formatex(Query[Len], charsmax(Query)-Len, "%i, ", m_Product[Seller_User_id]);
        Len += formatex(Query[Len], charsmax(Query)-Len, "%i, ", m_Product[product_id]);
        Len += formatex(Query[Len], charsmax(Query)-Len, "%i, ", m_Product[p_w_Is_NameTaged]);
        Len += formatex(Query[Len], charsmax(Query)-Len, "^"%s^", ", m_Product[p_w_NameTag]);
        Len += formatex(Query[Len], charsmax(Query)-Len, "%i, ", m_Product[p_w_Is_Stattrak]);
        Len += formatex(Query[Len], charsmax(Query)-Len, "%i, ", m_Product[p_w_Stattrak_Kills]);
        Len += formatex(Query[Len], charsmax(Query)-Len, "%i, ", m_Product[p_w_Damage_Level]);
        Len += formatex(Query[Len], charsmax(Query)-Len, "%i, ", m_Product[p_w_AttackCount]);
        Len += formatex(Query[Len], charsmax(Query)-Len, "%i, ", 1);
        Len += formatex(Query[Len], charsmax(Query)-Len, "%i", 0);
        Len += formatex(Query[Len], charsmax(Query)-Len, ");");
      }
      case 1:
      {
        Len = formatex(Query, charsmax(Query), "UPDATE `NextLvL_Player_Cases` SET ");
        switch(m_Product[product_id])
        {
          case 0:
            Len += formatex(Query[Len], charsmax(Query)-Len, "S0_Fusion = S0_Fusion + ^"%i^" ", m_Product[Amount]);
          case 1:
            Len += formatex(Query[Len], charsmax(Query)-Len, "S0_Power = S0_Power + ^"%i^" ", m_Product[Amount]);
          case 2:
            Len += formatex(Query[Len], charsmax(Query)-Len, "S0_Thunder = S0_Thunder + ^"%i^" ", m_Product[Amount]);
          case 3:
            Len += formatex(Query[Len], charsmax(Query)-Len, "S0_Light = S0_Light + ^"%i^" ", m_Product[Amount]);
          case 4:
            Len += formatex(Query[Len], charsmax(Query)-Len, "S0_Boom = S0_Boom + ^"%i^" ", m_Product[Amount]);
          case 5:
            Len += formatex(Query[Len], charsmax(Query)-Len, "S1_BlackIce = S1_BlackIce + ^"%i^" ", m_Product[Amount]);
          case 6:
            Len += formatex(Query[Len], charsmax(Query)-Len, "S1_NoName = S1_NoName + ^"%i^" ", m_Product[Amount]);
          //CASE EXTEND NEED HERE, Ha ládát akarsz böviteni itt is kell!
        }
        Len += formatex(Query[Len], charsmax(Query)-Len, "WHERE `User_Id` =  %d;", m_Product[Seller_User_id]);
      }
      case 2:
      {
        formatex(Query, charsmax(Query), "UPDATE `NextLvL_S_Player` SET iKeys = iKeys + ^"%i^" WHERE `User_Id` =  %d;", m_Product[Amount], m_Product[Seller_User_id]);
      }
      case 3:
      {
        formatex(Query, charsmax(Query), "UPDATE `NextLvL_S_Player` SET InfinityFragment = InfinityFragment + ^"%i^" WHERE `User_Id` =  %d;", m_Product[Amount], m_Product[Seller_User_id]);
      }
    }
    SQL_ThreadQuery(g_SqlTuple, "QuerySetData", Query);
    formatex(Query, charsmax(Query), "UPDATE `NextLvL_S_Player` SET MarketSize = MarketSize - 1 WHERE `User_Id` =  %d;", m_Product[Seller_User_id]);
    SQL_ThreadQuery(g_SqlTuple, "QuerySetData", Query);
    }

  m_Product[Price] = -1;
  ArraySetArray(g_Products, MarketSlot, m_Product);
}

public OfflineReward(User_id, m_Price)
{
  formatex(Query, charsmax(Query), "UPDATE `NextLvL_S_Player` SET Dollar = Dollar + ^"%i^" WHERE `User_Id` =  %d;", m_Price, User_id);
  SQL_ThreadQuery(g_SqlTuple, "QuerySetData", Query);
}

public BuyFromMarket(id, MarketSlot)
{
  new m_Product[product_Properties];
  ArrayGetArray(g_Products, MarketSlot, m_Product);

  if(m_Product[Price] < 0)
  {
    client_print_color(id, print_team_default, "^4%s ^1Az árucikk lejárt vagy valami más megvette!", Prefix);
    Market_Search(id);
    return;
  }

  if(!(m_Product[Price] <= s_Player[id][Euro]))
  {
    client_print_color(id, print_team_default, "^4%s ^1Nincs elég pénzed megvenni!", Prefix);
    Market_ProductInfo(id);
    return;
  }

  if(m_Product[Type] == 0 && InventoryCanAdd(id, "Megtelt a Raktárad nem tudod megvenni! (Az áruházban tudod bövíteni)") == 0)
  {
    Market_ProductInfo(id);
    return;
  }

  s_Player[id][Euro] -= m_Product[Price];
  new Seller_id = UserOnline(m_Product[Seller_User_id]);
  if(Seller_id != -1)
  {
    s_Player[Seller_id][Euro] += m_Product[Price];
    client_print_color(Seller_id, print_team_default, "^4%s ^1Megvásárolva valaki az egyik árucikkedet!", Prefix);
  }
  else
    OfflineReward(m_Product[Seller_User_id], m_Product[Price]);
  m_Product[Price] = -1;

  switch(m_Product[Type])
  {
    case 0:
    {
      Item[SQL_Key] = -1;
      Item[w_UserId] = ska_get_user_id(id);
      Item[w_id] = m_Product[product_id];
      Item[w_Is_NameTaged] = m_Product[p_w_Is_NameTaged];
      copy(Item[w_NameTag], 31, m_Product[p_w_NameTag]);
      Item[w_Is_Stattrak] = m_Product[p_w_Is_Stattrak];
      Item[w_Stattrak_Kills] = m_Product[p_w_Stattrak_Kills];
      Item[w_Damage_Level] = m_Product[p_w_Damage_Level];
      Item[w_AttackCount] = m_Product[p_w_AttackCount];
      Item[w_Tradable] = 1;
      Item[w_Equiped] = 0;
      Item[w_Deleted] = 0;

      Inventory[id][s_Player[id][InventoryWriteableSize]] = Item;
      s_Player[id][InventoryWriteableSize]++;
      s_Player[id][InventorySize]++;
    }
    case 1:
    {
      Player_Cases[id][m_Product[product_id]] += m_Product[Amount];
    }
    case 2:
    {
      s_Player[id][Keys] += m_Product[Amount];
    }
    case 3:
    {
      s_Player[id][InfinityFragment] += m_Product[Amount];
    }
  }
  client_print_color(id, print_team_default, "^4%s ^1Sikeres vásárlás!", Prefix);
  m_Product[Price] = -1;
  ArraySetArray(g_Products, MarketSlot, m_Product);
  Market_Search(id);
}

public PlaceOnMarket(id, m_Type, InventorySlot,m_Price, m_Amount)
{
  new m_Product[product_Properties];
  m_Product[product_SQL_key] = -1;
  m_Product[Price] = m_Price;
  m_Product[Seller_User_id] = ska_get_user_id(id);
  m_Product[Amount] = m_Amount;
  new UTS_TimeNow = parse_time("0", "%S",_);
  m_Product[UTS_EndTimeDate] = parse_time("3", "%d",UTS_TimeNow);
  m_Product[Type] = m_Type;

  switch(m_Type)
  {
    case 0: //Fegyver
    {
      if(IsEquipWeapon(id, InventorySlot))
        DeEquipWeapon(id, InventorySlot);
      
      Item = Inventory[id][InventorySlot];
      Inventory[id][InventorySlot][w_Deleted] = 1;
      s_Player[id][InventorySize]--;

      m_Product[product_id] = Item[w_id];
      m_Product[p_w_Is_NameTaged] = Item[w_Is_NameTaged];
      copy(m_Product[p_w_NameTag],31,Item[w_NameTag]);
      m_Product[p_w_Is_Stattrak] = Item[w_Is_Stattrak];
      m_Product[p_w_Stattrak_Kills] = Item[w_Stattrak_Kills];
      m_Product[p_w_Damage_Level] = Item[w_Damage_Level];
      m_Product[p_w_AttackCount] = Item[w_AttackCount];
      client_print_color(0 , print_team_default, "^4%s ^1Kihelyeztek a piacra:^4%s^1!", Prefix, WeaponText(id, InventorySlot));
    }
    case 1: //Láda
    {
      Player_Cases[id][InventorySlot] -= m_Amount;

      m_Product[product_id] = InventorySlot;
      m_Product[p_w_Is_NameTaged] = 0; //Not exist in this case
      copy(m_Product[p_w_NameTag],31,""); //Not exist in this case
      m_Product[p_w_Is_Stattrak] = 0; //Not exist in this case
      m_Product[p_w_Stattrak_Kills] = 0; //Not exist in this case
      m_Product[p_w_Damage_Level] = 0; //Not exist in this case
      m_Product[p_w_AttackCount] = 0; //Not exist in this case
      client_print_color(0 , print_team_default, "^4%s ^1Kihelyeztek a piacra:^4%s ^1[^4%i^1]!", Prefix, g_CasesNames[InventorySlot], m_Amount);
    }
    case 2: //Kulcs
    {
      s_Player[id][Keys] -= m_Amount;

      m_Product[product_id] = 0; //Not exist in this case
      m_Product[p_w_Is_NameTaged] = 0; //Not exist in this case
      copy(m_Product[p_w_NameTag],31,""); //Not exist in this case
      m_Product[p_w_Is_Stattrak] = 0; //Not exist in this case
      m_Product[p_w_Stattrak_Kills] = 0; //Not exist in this case
      m_Product[p_w_Damage_Level] = 0; //Not exist in this case
      m_Product[p_w_AttackCount] = 0; //Not exist in this case
      client_print_color(0 , print_team_default, "^4%s ^1Kihelyeztek a piacra:^4Kulcs ^1[^4%i^1]!", Prefix, m_Amount);
    }
    case 3: // végtelen bisz basz
    {
      s_Player[id][InfinityFragment] -= m_Amount;

      m_Product[product_id] = 0; //Not exist in this case
      m_Product[p_w_Is_NameTaged] = 0; //Not exist in this case
      copy(m_Product[p_w_NameTag],31,""); //Not exist in this case
      m_Product[p_w_Is_Stattrak] = 0; //Not exist in this case
      m_Product[p_w_Stattrak_Kills] = 0; //Not exist in this case
      m_Product[p_w_Damage_Level] = 0; //Not exist in this case
      m_Product[p_w_AttackCount] = 0; //Not exist in this case
      client_print_color(0 , print_team_default, "^4%s ^1Kihelyeztek a piacra:^4Végtelen darabka ^1[^4%i^1]!", Prefix, m_Amount);
    }
  }
  ArrayPushArray(g_Products, m_Product);
  s_Player[id][MarketSize]++;
  client_print_color(id, print_team_default, "^4%s ^1Sikeresen kihelyezted az árucikket!", Prefix);
}

public Get_MarketCost(id)
{
  new Data[32];
  read_args(Data, charsmax(Data));
  remove_quotes(Data);

  if(!(RegexTester(id, Data, "^^[0-9]{1,32}+$", "A beírt adat csak számokat tartalmazhat!")))
  {
    Market_SearchSettings(id);
    return;
  }
  new m_TypedMarketPrice = str_to_num(Data);
  if(m_TypedMarketPrice < 1)
  {
    client_print_color(id, print_team_default, "^4%s ^1Te akarsz fizetni az embereknek hogy vigyék el?", Prefix);
    m_TypedMarketPrice = 0;
  }

  if(m_TypedMarketPrice > Market_MaxCost)
  {
    client_print_color(id, print_team_default, "^4%s ^1Ennyire azért csak nem lehet drága!", Prefix);
    m_TypedMarketPrice = Market_MaxCost;
  }
  s_Player[id][TypedMarketPrice] = m_TypedMarketPrice;
  PlaceOnMarket_Menu(id, s_Player[id][PreMarketSelectedType]);
}

public Get_MarketAmount(id)
{
  new Data[32];
  read_args(Data, charsmax(Data));
  remove_quotes(Data);

  if(!(RegexTester(id, Data, "^^[0-9]{1,32}+$", "A beírt adat csak számokat tartalmazhat!")))
  {
    Market_SearchSettings(id);
    return;
  }
  new m_TypedMarketAmount = str_to_num(Data);
  if(m_TypedMarketAmount < 1)
  {
    client_print_color(id, print_team_default, "^4%s ^1Scammelni csunya dolog!", Prefix);
    m_TypedMarketAmount = 1;
  }

  if(m_TypedMarketAmount > Market_MaxCost)
  {
    client_print_color(id, print_team_default, "^4%s ^1Ha tényleg ennyire sok van akkor inkább használd el!", Prefix);
    m_TypedMarketAmount = Market_MaxAmount;
  }

  s_Player[id][TypedMarketAmount] = m_TypedMarketAmount;
  PlaceOnMarket_Menu(id, s_Player[id][PreMarketSelectedType]);
}

public Get_MaxDamage(id)
{
  new Data[32];
  read_args(Data, charsmax(Data));
  remove_quotes(Data);

  if(!(RegexTester(id, Data, "^^[0-9]{1,32}+$", "A beírt adat csak számokat tartalmazhat!")))
  {
    Market_SearchSettings(id);
    return;
  }
  new m_search_MaxDamage = str_to_num(Data);
  if(m_search_MaxDamage < searchsettings_Player[id][weaponsearch_MinDamage])
  {
    client_print_color(id, print_team_default, "^4%s ^1Nem lehet kisebb a maximum mint a minmum csak egyenlő!", Prefix);
    m_search_MaxDamage = searchsettings_Player[id][weaponsearch_MinDamage];
    Market_SearchSettings(id);
    return;
  }

  if(m_search_MaxDamage > 101)
    m_search_MaxDamage = 101;
  
  searchsettings_Player[id][weaponsearch_MaxDamage] = m_search_MaxDamage;
  Market_SearchSettings(id);
}

public Get_MinDamage(id)
{
  new Data[32];
  read_args(Data, charsmax(Data));
  remove_quotes(Data);

  if(!(RegexTester(id, Data, "^^[0-9]{1,32}+$", "A beírt adat csak számokat tartalmazhat!")))
  {
    Market_SearchSettings(id);
    return;
  }
  new m_search_MinDamage = str_to_num(Data);
  if(m_search_MinDamage > searchsettings_Player[id][weaponsearch_MaxDamage])
  {
    client_print_color(id, print_team_default, "^4%s ^1Nem lehet kisebb a minimum mint a maximum csak egyenlő!", Prefix);
    m_search_MinDamage = searchsettings_Player[id][weaponsearch_MaxDamage];
    Market_SearchSettings(id);
    return;
  }

  if(m_search_MinDamage < 0)
    m_search_MinDamage = 0;
  
  searchsettings_Player[id][weaponsearch_MinDamage] = m_search_MinDamage;
  Market_SearchSettings(id);
}

public Get_MaxAmount(id)
{
  new Data[32];
  read_args(Data, charsmax(Data));
  remove_quotes(Data);

  if(!(RegexTester(id, Data, "^^[0-9]{1,32}+$", "A beírt adat csak számokat tartalmazhat!")))
  {
    Market_SearchSettings(id);
    return;
  }
  new m_search_MaxAmount = str_to_num(Data);
  switch(searchsettings_Player[id][SelectedSearchType])
  {
    case 1:
    {
      if(m_search_MaxAmount < searchsettings_Player[id][casesearch_MinAmount])
      {
        client_print_color(id, print_team_default, "^4%s ^1Nem lehet kisebb a maximum mint a minmum csak egyenlő!", Prefix);
        m_search_MaxAmount = searchsettings_Player[id][casesearch_MinAmount];
      }

      if(m_search_MaxAmount > Market_MaxAmount)
        m_search_MaxAmount = Market_MaxAmount;

      searchsettings_Player[id][casesearch_MaxAmount] = m_search_MaxAmount;
    }
    case 2:
    {
      if(m_search_MaxAmount < searchsettings_Player[id][keysearch_MinAmount])
      {
        client_print_color(id, print_team_default, "^4%s ^1Nem lehet kisebb a maximum mint a minmum csak egyenlő!", Prefix);
        m_search_MaxAmount = searchsettings_Player[id][keysearch_MinAmount];
      }

      if(m_search_MaxAmount > Market_MaxAmount)
        m_search_MaxAmount = Market_MaxAmount;

      searchsettings_Player[id][keysearch_MaxAmount] = m_search_MaxAmount;
    }
    case 3:
    {
      if(m_search_MaxAmount < searchsettings_Player[id][infinityfragmentsearch_MinAmount])
      {
        client_print_color(id, print_team_default, "^4%s ^1Nem lehet kisebb a maximum mint a minmum csak egyenlő!", Prefix);
        m_search_MaxAmount = searchsettings_Player[id][infinityfragmentsearch_MinAmount];
      }

      if(m_search_MaxAmount > Market_MaxAmount)
        m_search_MaxAmount = Market_MaxAmount;

      searchsettings_Player[id][infinityfragmentsearch_MaxAmount] = m_search_MaxAmount;
    }
  }
  Market_SearchSettings(id);
}

public Get_MinAmount(id)
{
  new Data[32];
  read_args(Data, charsmax(Data));
  remove_quotes(Data);

  if(!(RegexTester(id, Data, "^^[0-9]{1,32}+$", "A beírt adat csak számokat tartalmazhat!")))
  {
    Market_SearchSettings(id);
    return;
  }
  new m_search_MinAmount = str_to_num(Data);
  switch(searchsettings_Player[id][SelectedSearchType])
  {
    case 1:
    {
      if(m_search_MinAmount > searchsettings_Player[id][casesearch_MaxAmount])
      {
        client_print_color(id, print_team_default, "^4%s ^1Nem lehet kisebb a minimum mint a maximum csak egyenlő!", Prefix);
        m_search_MinAmount = searchsettings_Player[id][casesearch_MaxAmount];
      }

      if(m_search_MinAmount < 0)
        m_search_MinAmount = 0;

      searchsettings_Player[id][casesearch_MinAmount] = m_search_MinAmount;
    }
    case 2:
    {
      if(m_search_MinAmount > searchsettings_Player[id][keysearch_MaxAmount])
      {
        client_print_color(id, print_team_default, "^4%s ^1Nem lehet kisebb a minimum mint a maximum csak egyenlő!", Prefix);
        m_search_MinAmount = searchsettings_Player[id][keysearch_MaxAmount];
      }

      if(m_search_MinAmount < 0)
        m_search_MinAmount = 0;

      searchsettings_Player[id][keysearch_MinAmount] = m_search_MinAmount;
    }
    case 3:
    {
      if(m_search_MinAmount > searchsettings_Player[id][infinityfragmentsearch_MaxAmount])
      {
        client_print_color(id, print_team_default, "^4%s ^1Nem lehet kisebb a minimum mint a maximum csak egyenlő!", Prefix);
        m_search_MinAmount = searchsettings_Player[id][infinityfragmentsearch_MaxAmount];
      }

      if(m_search_MinAmount < 0)
        m_search_MinAmount = 0;

      searchsettings_Player[id][infinityfragmentsearch_MinAmount] = m_search_MinAmount;
    }
  }
  Market_SearchSettings(id);
}

public Get_MaxCost(id)
{
  new Data[32];
  read_args(Data, charsmax(Data));
  remove_quotes(Data);

  if(!(RegexTester(id, Data, "^^[0-9]{1,32}+$", "A beírt adat csak számokat tartalmazhat!")))
  {
    Market_SearchSettings(id);
    return;
  }
  new m_search_MaxCost = str_to_num(Data);
  switch(searchsettings_Player[id][SelectedSearchType])
  {
    case 0:
    {
      if(m_search_MaxCost < searchsettings_Player[id][weaponsearch_MinCost])
      {
        client_print_color(id, print_team_default, "^4%s ^1Nem lehet kisebb a maximum mint a minimum csak egyenlő!", Prefix);
        m_search_MaxCost = searchsettings_Player[id][weaponsearch_MinCost];
      }

      if(m_search_MaxCost > Market_MaxCost)
        m_search_MaxCost = Market_MaxCost;

      searchsettings_Player[id][weaponsearch_MaxCost] = m_search_MaxCost;
    }
    case 1:
    {
      if(m_search_MaxCost < searchsettings_Player[id][casesearch_MinCost])
      {
        client_print_color(id, print_team_default, "^4%s ^1Nem lehet kisebb a maximum mint a minimum csak egyenlő!", Prefix);
        m_search_MaxCost = searchsettings_Player[id][casesearch_MinCost];
      }

      if(m_search_MaxCost > Market_MaxCost)
        m_search_MaxCost = Market_MaxCost;

      searchsettings_Player[id][casesearch_MaxCost] = m_search_MaxCost;
    }
    case 2:
    {
      if(m_search_MaxCost < searchsettings_Player[id][keysearch_MinCost])
      {
        client_print_color(id, print_team_default, "^4%s ^1Nem lehet kisebb a maximum mint a minimum csak egyenlő!", Prefix);
        m_search_MaxCost = searchsettings_Player[id][keysearch_MinCost];
      }

      if(m_search_MaxCost > Market_MaxCost)
        m_search_MaxCost = Market_MaxCost;

      searchsettings_Player[id][keysearch_MaxCost] = m_search_MaxCost;
    }
    case 3:
    {
      if(m_search_MaxCost < searchsettings_Player[id][infinityfragmentsearch_MinCost])
      {
        client_print_color(id, print_team_default, "^4%s ^1Nem lehet kisebb a maximum mint a minmum csak egyenlő!", Prefix);
        m_search_MaxCost = searchsettings_Player[id][infinityfragmentsearch_MinCost];
      }

      if(m_search_MaxCost > Market_MaxCost)
        m_search_MaxCost = Market_MaxCost;

      searchsettings_Player[id][infinityfragmentsearch_MaxCost] = m_search_MaxCost;
    }
  }
  Market_SearchSettings(id);
}

public Get_MinCost(id)
{
  new Data[32];
  read_args(Data, charsmax(Data));
  remove_quotes(Data);

  if(!(RegexTester(id, Data, "^^[0-9]{1,32}+$", "A beírt adat csak számokat tartalmazhat!")))
  {
    Market_SearchSettings(id);
    return;
  }
  new m_search_MinCost = str_to_num(Data);
  switch(searchsettings_Player[id][SelectedSearchType])
  {
    case 0:
    {
      if(m_search_MinCost > searchsettings_Player[id][weaponsearch_MaxCost])
      {
        client_print_color(id, print_team_default, "^4%s ^1Nem lehet kisebb a minimum mint a maximum csak egyenlő!", Prefix);
        m_search_MinCost = searchsettings_Player[id][weaponsearch_MaxCost];
      }

      if(m_search_MinCost < 0)
        m_search_MinCost = 0;

      searchsettings_Player[id][weaponsearch_MinCost] = m_search_MinCost;
    }
    case 1:
    {
      if(m_search_MinCost > searchsettings_Player[id][casesearch_MaxCost])
      {
        client_print_color(id, print_team_default, "^4%s ^1Nem lehet kisebb a minimum mint a maximum csak egyenlő!", Prefix);
        m_search_MinCost = searchsettings_Player[id][casesearch_MaxCost];
      }

      if(m_search_MinCost < 0)
        m_search_MinCost = 0;

      searchsettings_Player[id][casesearch_MinCost] = m_search_MinCost;
    }
    case 2:
    {
      if(m_search_MinCost > searchsettings_Player[id][keysearch_MaxCost])
      {
        client_print_color(id, print_team_default, "^4%s ^1Nem lehet kisebb a minimum mint a maximum csak egyenlő!", Prefix);
        m_search_MinCost = searchsettings_Player[id][keysearch_MaxCost];
      }

      if(m_search_MinCost < 0)
        m_search_MinCost = 0;

      searchsettings_Player[id][keysearch_MinCost] = m_search_MinCost;
    }
    case 3:
    {
      if(m_search_MinCost > searchsettings_Player[id][infinityfragmentsearch_MaxCost])
      {
        client_print_color(id, print_team_default, "^4%s ^1Nem lehet kisebb a minimum mint a maximum csak egyenlő!", Prefix);
        m_search_MinCost = searchsettings_Player[id][infinityfragmentsearch_MaxCost];
      }

      if(m_search_MinCost < 0)
        m_search_MinCost = 0;

      searchsettings_Player[id][infinityfragmentsearch_MinCost] = m_search_MinCost;
    }
  }
  Market_SearchSettings(id);
}

public Get_SearchById(id)
{
  new Data[32];
  read_args(Data, charsmax(Data));
  remove_quotes(Data);

  if(!(RegexTester(id, Data, "^^[0-9]{1,32}+$", "A beírt adat csak számokat tartalmazhat!")))
  {
    Market_SearchSettings(id);
    return;
  }

  new m_search_User_id = str_to_num(Data);
  if(m_search_User_id < 1)
  {
    client_print_color(id, print_team_default, "^4%s ^1Nem lehet kisebb a 1 a #id!", Prefix);
    m_search_User_id = 1;
  }

  searchsettings_Player[id][playersearch_User_id] = m_search_User_id;
  Market_SearchSettings(id);
}

public Get_ShopAmount(id)
{
  new Data[32];
  read_args(Data, charsmax(Data));
  remove_quotes(Data);

  if(!(RegexTester(id, Data, "^^[0-9]{1,32}+$", "A beírt adat csak számokat tartalmazhat!")))
  {
    Shop_Info(id, s_Player[id][ShopSelectedSlot]);
    return;
  }

  new m_Amount = str_to_num(Data);

  if(m_Amount < 1)
  {
    client_print_color(id, print_team_default, "^4%s ^1Minimum 1-et venned kell!",Prefix);
    Shop_Info(id, s_Player[id][ShopSelectedSlot]);
    return;
  }
  if(InventoryMaxExtend >= (s_Player[id][InventorySizeMax] + m_Amount))
    s_Player[id][ShopTypedAmount] = m_Amount;
  else
    s_Player[id][ShopTypedAmount] = InventoryMaxExtend - s_Player[id][InventorySizeMax];
  
  Shop_Info(id, s_Player[id][ShopSelectedSlot]);
}

public Get_NameTag(id)
{
  new Data[32];
  read_args(Data, charsmax(Data));
  remove_quotes(Data);

  new InventorySlot = s_Player[id][InventorySelectedSlot];
  
  if(!(RegexTester(id, Data, "^^[A-Za-z0-9öüóőúéáűíÖÜÓŐÚÉÁŰÍ <>=\/_.:!\?\*\[\]+,()\-]{1,16}+$", "A beírt szöveg csak magyar abc-t, számok és ^"<>=/_.!?*[]+,()-^"-ket tartalmazhatja!")))
  {
    WeaponInfo(id, InventorySlot);
    return;
  }
  
  Inventory[id][InventorySlot][w_NameTag] = "";
  Inventory[id][InventorySlot][w_NameTag] = Data;
  if(Inventory[id][InventorySlot][w_Is_NameTaged] == 1)
  {
    client_print_color(id, print_team_default, "^4%s ^1Sikeresen átnevezted a fegyveredet!",Prefix);
  }
  else
  {
    Inventory[id][InventorySlot][w_Is_NameTaged] = 1;
    client_print_color(id, print_team_default, "^4%s ^1Sikeresen elnevezted a fegyveredet!",Prefix);
  }
  s_Player[id][ToolsNametag]--;

  WeaponInfo(id, InventorySlot);
}

public WeaponBreak(id, InventorySlot)
{
  DeEquipWeapon(id, InventorySlot);
  client_print_color(id, print_team_default, "^4%s ^1JAJ NE! Összetört a fegyvered!", Prefix);
  if(s_Player[id][ItemBreakSoundPlay])
    client_cmd(id,"spk NextLvL/ItemBreak");
}

public WeaponText(id, InventorySlot)
{

  if(Inventory[id][InventorySlot][w_Is_Stattrak])
    formatex(String, charsmax(String), "%s *ST", g_Weapon[Inventory[id][InventorySlot][w_id]][w_name]);
  else
    formatex(String, charsmax(String), "%s", g_Weapon[Inventory[id][InventorySlot][w_id]][w_name]);
  
  return String;
}

public ItemAddStatTrak(id, InventorySlot)
{
  if(Inventory[id][InventorySlot][w_Is_Stattrak] == 1)
  {
    Inventory[id][InventorySlot][w_Stattrak_Kills] = 0;
    client_print_color(id, print_team_default, "^4%s ^1Sikeresen nulláztad a StatTrak ölések számát!",Prefix);
  }
  else
  {
    Inventory[id][InventorySlot][w_Is_Stattrak] = 1;
    client_print_color(id, print_team_default, "^4%s ^1Sikeresen felszerelted a StatTrak-ot!",Prefix);
  }
  s_Player[id][ToolsStattrak]--;
}
public WeaponMakePermanent(id, InventorySlot)
{
  Inventory[id][InventorySlot][w_Damage_Level] = 101;
  s_Player[id][InfinityFragment] -= Cost_WeaponMakePermanent;
  client_print_color(id, print_team_default, "^4%s ^1Sikeresen véglegesítetted a fegyvert!",Prefix);
}

public RepairWeapon(id, InventorySlot)
{
  if(Inventory[id][InventorySlot][w_Damage_Level] == 101)
  {
    WeaponInfo(id, InventorySlot);
    return;
  }
  
  if(Inventory[id][InventorySlot][w_Damage_Level] <= 0)
    if(s_Player[id][Euro] >= Cost_WeaponRestore)
    {
      s_Player[id][Euro] -= Cost_WeaponRestore;
      Inventory[id][InventorySlot][w_Damage_Level] = 10;
      
      formatex(String, 511, "^4%s ^1Helyreállítottad a kiválasztott fegyvert %.1f$-ért!", Prefix, Cost_WeaponRestore);
      replace_all(String, 511, ".", ",");
      client_print_color(id, print_team_default, String);
      return;
    }
  
  if(Inventory[id][InventorySlot][w_Damage_Level] < 100)
    if(s_Player[id][Euro] >= Cost_WeaponRepair)
    {
      s_Player[id][Euro] -= Cost_WeaponRepair;
      Inventory[id][InventorySlot][w_Damage_Level] += 1;
      formatex(String, 511, "^4%s ^1Javitottál 1%s ot a kiválasztott fegyveren %.1f$-ért!", Prefix, "%", Cost_WeaponRepair);
      replace_all(String, 511, ".", ",");
      client_print_color(id, print_team_default, String);
      return;
    }
  
  if(Inventory[id][InventorySlot][w_Damage_Level] == 100)
    {
      client_print_color(id, print_team_default, "^4%s ^1A kiválasztott fegyver a lehető legjobb minőségű!", Prefix);
      return;
    }
}

public EquipWeapon(id, InventorySlot)
{
  switch(g_Weapon[Inventory[id][InventorySlot][w_id]][w_type])
  {
    case CSW_AK47:
    {
      Inventory[id][Equipmented[id][AK47]][w_Equiped] = 0;
      Equipmented[id][AK47] = InventorySlot;
      Inventory[id][InventorySlot][w_Equiped] = 1;
    }
    case CSW_M4A1:
    {
      Inventory[id][Equipmented[id][M4A1]][w_Equiped] = 0;
      Equipmented[id][M4A1] = InventorySlot;
      Inventory[id][InventorySlot][w_Equiped] = 1;
    }
    case CSW_AWP:
    {
        Inventory[id][Equipmented[id][AWP]][w_Equiped] = 0;
        Equipmented[id][AWP] = InventorySlot;
        Inventory[id][InventorySlot][w_Equiped] = 1;
    }
    case CSW_DEAGLE:
    {
        Inventory[id][Equipmented[id][DEAGLE]][w_Equiped] = 0;
        Equipmented[id][DEAGLE] = InventorySlot;
        Inventory[id][InventorySlot][w_Equiped] = 1;
    }
    case CSW_KNIFE:
    {
        Inventory[id][Equipmented[id][KNIFE]][w_Equiped] = 0;
        Equipmented[id][KNIFE] = InventorySlot;
        Inventory[id][InventorySlot][w_Equiped] = 1;
    }
    case CSW_FAMAS:
    {
        Inventory[id][Equipmented[id][FAMAS]][w_Equiped] = 0;
        Equipmented[id][FAMAS] = InventorySlot;
        Inventory[id][InventorySlot][w_Equiped] = 1;
    }
    case CSW_MP5NAVY:
    {
        Inventory[id][Equipmented[id][MP5]][w_Equiped] = 0;
        Equipmented[id][MP5] = InventorySlot;
        Inventory[id][InventorySlot][w_Equiped] = 1;
    }
    case CSW_SCOUT:
    {
        Inventory[id][Equipmented[id][SCOUT]][w_Equiped] = 0;
        Equipmented[id][SCOUT] = InventorySlot;
        Inventory[id][InventorySlot][w_Equiped] = 1;
    }
  }
}

public DeEquipWeapon(id, InventorySlot)
{
  switch(g_Weapon[Inventory[id][InventorySlot][w_id]][w_type])
  {
    case CSW_AK47:
    {
      Equipmented[id][AK47] = EquipmentedDef[AK47];
      Inventory[id][InventorySlot][w_Equiped] = 0;
      Inventory[id][EquipmentedDef[AK47]][w_Equiped] = 1;
    }
    case CSW_M4A1:
    {
      Equipmented[id][M4A1] = EquipmentedDef[M4A1];
      Inventory[id][InventorySlot][w_Equiped] = 0;
      Inventory[id][EquipmentedDef[M4A1]][w_Equiped] = 1;
    }
    case CSW_AWP:
    {
      Equipmented[id][AWP] = EquipmentedDef[AWP];
      Inventory[id][InventorySlot][w_Equiped] = 0;
      Inventory[id][EquipmentedDef[AWP]][w_Equiped] = 1;
    }
    case CSW_DEAGLE:
    {
      Equipmented[id][DEAGLE] = EquipmentedDef[DEAGLE];
      Inventory[id][InventorySlot][w_Equiped] = 0;
      Inventory[id][EquipmentedDef[DEAGLE]][w_Equiped] = 1;
    }
    case CSW_KNIFE:
    {
      Equipmented[id][KNIFE] = EquipmentedDef[KNIFE];
      Inventory[id][InventorySlot][w_Equiped] = 0;
      Inventory[id][EquipmentedDef[KNIFE]][w_Equiped] = 1;
    }
    case CSW_FAMAS:
    {
      Equipmented[id][FAMAS] = EquipmentedDef[FAMAS];
      Inventory[id][InventorySlot][w_Equiped] = 0;
      Inventory[id][EquipmentedDef[FAMAS]][w_Equiped] = 1;
    }
    case CSW_MP5NAVY:
    {
      Equipmented[id][MP5] = EquipmentedDef[MP5];
      Inventory[id][InventorySlot][w_Equiped] = 0;
      Inventory[id][EquipmentedDef[MP5]][w_Equiped] = 1;
    }
    case CSW_SCOUT:
    {
      Equipmented[id][SCOUT] = EquipmentedDef[SCOUT];
      Inventory[id][InventorySlot][w_Equiped] = 0;
      Inventory[id][EquipmentedDef[SCOUT]][w_Equiped] = 1;
    }
  }
}

public IsEquipWeapon(id, InventorySlot)
{
  switch(g_Weapon[Inventory[id][InventorySlot][w_id]][w_type])
  {
    case CSW_AK47:
    {
      if(Equipmented[id][AK47] == InventorySlot)
        return 1;
    }
    case CSW_M4A1:
    {
      if(Equipmented[id][M4A1] == InventorySlot)
        return 1;
    }
    case CSW_AWP:
    {
      if(Equipmented[id][AWP] == InventorySlot)
        return 1;
    }
    case CSW_DEAGLE:
    {
      if(Equipmented[id][DEAGLE] == InventorySlot)
        return 1;
    }
    case CSW_KNIFE:
    {
      if(Equipmented[id][KNIFE] == InventorySlot)
        return 1;
    }
    case CSW_FAMAS:
    {
      if(Equipmented[id][FAMAS] == InventorySlot)
        return 1;
    }
    case CSW_MP5NAVY:
    {
      if(Equipmented[id][MP5] == InventorySlot)
        return 1;
    }
    case CSW_SCOUT:
    {
      if(Equipmented[id][SCOUT] == InventorySlot)
        return 1;
    }
  }
  return 0;
}

public UserOnline(User_id)
{
  new foundid = -1;
  for(new i = 1;i < 33;i++)
  {
    if(ska_is_user_logged(i))
      if(ska_get_user_id(i) == User_id)
      {
        foundid = i;
        break;
      }
  }

  return foundid;
}

public InventoryClean(id)
{
  new m_InventoryWriteableSize = s_Player[id][InventoryWriteableSize];
  for(new i;i < m_InventoryWriteableSize;i++)
    Inventory[id][i] = EmptyItem;
}

public InventoryCanAdd(id, InvFullText[])
{
  if(!((s_Player[id][InventoryWriteableSize]) < InventoryMAX))
  {
    server_cmd("amx_kick ^"%s^" ^"Olyan mennyiségű tárgy fordult meg az raktáradban hogy veszéjeszted a szerver futását!^"", Player_Stats[id][Name]);
    return -1;
  }
  else if(!(s_Player[id][InventorySize] < s_Player[id][InventorySizeMax]))
  {
    if(InvFullText[0] != EOS)
      client_print_color(id, print_team_default, "^4%s ^1%s",Prefix, InvFullText);
    return 0;
  }
  else
  {
    return 1;
  }
}

public InventoryAddNewItem(id, wep_id, Is_NameTaged, NameTag[32], Is_Stattrak/*-1 for random*/, Stattrak_Kills, Damage_Level/*-1 for random*/, Tradable)
{
  if(!(ska_is_user_logged(id)))
    return;
  
  Item[SQL_Key] = -1;
  Item[w_UserId] = ska_get_user_id(id);
  Item[w_id] = wep_id;
  Item[w_Is_NameTaged] = Is_NameTaged;
  if(Is_NameTaged == 1)
  {
      Item[w_NameTag] = NameTag;
  }
  else
  {
      Item[w_NameTag] = "";
  }
  if(Is_Stattrak == -1)
  {
    new RND = random_num(1,100);
    if(8 >= RND)
      Item[w_Is_Stattrak] = 1;
    else
      Item[w_Is_Stattrak] = 0;
    Item[w_Stattrak_Kills] = 0;
  }
  else
  {
      Item[w_Is_Stattrak] = Is_Stattrak;
      Item[w_Stattrak_Kills] = Stattrak_Kills;
  }  
  if(Damage_Level == -1)
  {
      Item[w_Damage_Level] = random_num(20,100);
  }
  else
  {
      Item[w_Damage_Level] = Damage_Level;
  }
  Item[w_Tradable] = Tradable;
  Item[w_Equiped] = 0;
  Item[w_Deleted] = 0;
  
  if(wep_id <= 7) //Alap fegyvereket ha leadolja akkor legyen rögtön felszerelve!
  {
      Item[w_Equiped] = 1;
  }
  
  Inventory[id][s_Player[id][InventoryWriteableSize]] = Item;
  s_Player[id][InventoryWriteableSize]++;
  s_Player[id][InventorySize]++;
}

public InventorySendItem(id, InventorySlot, target)
{
  if(!(ska_is_user_logged(target)))
    return;
  
  if(InventoryCanAdd(target, "") == 1)
  {
    if(IsEquipWeapon(id, InventorySlot))
    {
      DeEquipWeapon(id, InventorySlot);
    }
    Item = Inventory[id][InventorySlot];
    Inventory[id][InventorySlot][w_Deleted] = 1;
    Item[w_UserId] = ska_get_user_id(target);
    Item[SQL_Key] = -1; //BUGFIX 2019.08.30 12:11
    Inventory[target][s_Player[target][InventoryWriteableSize]] = Item;
    s_Player[id][InventorySize]--;
    s_Player[target][InventoryWriteableSize]++;
    s_Player[target][InventorySize]++;

    if(s_Player[target][SilentTransfer] && s_Player[id][SilentTransfer])
      client_print_color(0, print_team_default, "^4%s ^1Valaki küldött valakinek egy:^4%s^1!",Prefix ,WeaponText(id, InventorySlot));
    else if(s_Player[target][SilentTransfer] && !(s_Player[id][SilentTransfer]))
      client_print_color(0, print_team_default, "^4%s ^1%s küldött valakinek egy:^4%s^1!",Prefix ,Player_Stats[id][Name] ,WeaponText(id, InventorySlot));
    else if(!(s_Player[target][SilentTransfer]) && s_Player[id][SilentTransfer])
      client_print_color(0, print_team_default, "^4%s ^1Valaki küldött %s-nek/nak egy:^4%s^1!",Prefix ,Player_Stats[target][Name] ,WeaponText(id, InventorySlot));
    else
      client_print_color(0, print_team_default, "^4%s ^1%s küldött %s-nek/nak egy:^4%s^1!",Prefix ,Player_Stats[id][Name] ,Player_Stats[target][Name] ,WeaponText(id, InventorySlot));

    client_print_color(id, print_team_default, "^4%s ^1Sikeres küldés neki:%s(#%i)!",Prefix,Player_Stats[target][Name], ska_get_user_id(target));
    client_print_color(target, print_team_default, "^4%s ^1Sikeresen küldött neked:%s(#%i)!",Prefix,Player_Stats[id][Name], ska_get_user_id(id));

    formatex(logline, 249, "ITEM SEND - _SENDER:#%i _ACCEPTER:#%i _ITEMPROP: <#SQL_Key:%i #id:%i #Is_NameTaged:%i #NameTag:%s #Is_Stattrak:%i #Stattrak_Kills:%i #Damage_Level:%i>", ska_get_user_id(id), ska_get_user_id(target),Item[SQL_Key], Item[w_id], Item[w_Is_NameTaged], Item[w_NameTag], Item[w_Is_Stattrak], Item[w_Stattrak_Kills], Item[w_Damage_Level]);
    log_to_file(Filename_ItemTransaction, logline);
  }
  else
  {
    client_print_color(id, print_team_default, "^4%s ^1Sikertelen küldés (MEGTELT A RAKTÁR) neki:%s(#%i)!",Prefix,Player_Stats[target][Name], ska_get_user_id(target));
  }
}

public InventoryDeleteItem(id, InventorySlot)
{
  Inventory[id][InventorySlot][w_Deleted] = 1;
  Inventory[id][InventorySlot][w_Equiped] = 0;
  if(IsEquipWeapon(id, InventorySlot))
    DeEquipWeapon(id, InventorySlot);
  s_Player[id][InventorySize]--;

  if(Inventory[id][InventorySlot][w_Damage_Level] == 101)
    s_Player[id][InfinityFragment] += Return_BreakPermanent;
  else
    s_Player[id][InfinityFragment] += floatround(Inventory[id][InventorySlot][w_Damage_Level]/10.0);
  client_print_color(id, print_team_default, "^4%s ^1Összetörted a kiválasztott fegyvert!",Prefix)
}

public CmdGiveItem(id) //<#User_ID> <Weapon_Id (command: weapon_list)> <Tradable> <IsStattrak / -1 for Random> <Stattrak_Kills> <IsNameTaged> <NameTag> <Damage_Lvl / -1 for Random>
{
  if(s_AdminLevel[id] != 1)
  {
    client_print(id, print_console, "Nincs elérhetőseg ehhez a parancshoz!");
    return;
  }

  new Arg1[32], Arg2[32], Arg3[32], Arg4[32], Arg5[32], Arg6[32], Arg7[32], Arg8[32];

  read_argv(1, Arg1, charsmax(Arg1));
  read_argv(2, Arg2, charsmax(Arg2));
  read_argv(3, Arg3, charsmax(Arg3));
  read_argv(4, Arg4, charsmax(Arg4));
  read_argv(5, Arg5, charsmax(Arg5));
  read_argv(6, Arg6, charsmax(Arg6));
  read_argv(7, Arg7, charsmax(Arg7));
  read_argv(8, Arg8, charsmax(Arg8));
  
  if(Arg1[0] == EOS)
  { 
    client_print(id, print_console, "weapon_give <#User_ID> <Weapon_Id (command: weapon_list)> <Tradable> <IsStattrak / -1 for Random> <Stattrak_Kills> <IsNameTaged> <NameTag> <Damage_Lvl / -1 for Random>");
    return;
  }

  Item[SQL_Key] = -1;
  Item[w_UserId] = str_to_num(Arg1);
  Item[w_id] = str_to_num(Arg2);
  Item[w_Is_NameTaged] = str_to_num(Arg6);
  Item[w_NameTag] = Arg7;
  Item[w_Is_Stattrak] = str_to_num(Arg4);
  Item[w_Stattrak_Kills] = str_to_num(Arg5);
  Item[w_Damage_Level] = str_to_num(Arg8);
  Item[w_Tradable] = str_to_num(Arg3);
  Item[w_Equiped] = 0;
  Item[w_Deleted] = 0;


  if(!(Item[w_id] < sizeof(g_Weapon)))
  {
    client_print(id, print_console, "There's no '%i' weapon ID!", Item[w_id]);
    return;
  }

  if(Item[w_UserId] <= 0)
  {
    client_print(id, print_console, "'%i' is an invalid User ID!", Item[w_id]);
    return;
  }

  if(Item[w_id] <= 7)
  {
    client_print(id, print_console, "You can't add '%i' weapon ID!", Item[w_id]);
    return;
  }
  
  if(Item[w_Damage_Level] > 100)
    Item[w_Damage_Level] = 101;

  if(Item[w_Is_Stattrak] == -1)
    Item[w_Is_Stattrak] = random_num(0, 1);

  if(Item[w_Damage_Level] < 0)
    Item[w_Damage_Level] = random_num(20, 100);

  new WasOnline = 0;
  for(new i = 1;i < 33;i++)
  {
    if(ska_is_user_logged(i))
      if(ska_get_user_id(i) == Item[w_UserId])
      {
        if(InventoryCanAdd(i, "") == 1)
        {
          Inventory[i][s_Player[i][InventoryWriteableSize]] = Item;
          s_Player[i][InventoryWriteableSize]++;
          s_Player[i][InventorySize]++;
          client_print_color(id, print_team_default, "^4%s ^1Sikeres addolás erre a fiókra: ^1%s(#%i)^1!",Prefix, Player_Stats[i][Name],ska_get_user_id(i));
          client_print_color(i, print_team_default, "^4%s ^1Sikeresen addoltak neked erről a fiókról: ^1%s(#%i)^1!",Prefix, Player_Stats[id][Name],ska_get_user_id(id));

          formatex(logline, 249, "WEAPON_GIVE - _ADDER:#%i _TARGET:#%i _ITEMPROP: <#SQL_Key:%i #id:%i #Is_NameTaged:%i #NameTag:%s #Is_Stattrak:%i #Stattrak_Kills:%i #Damage_Level:%i>", ska_get_user_id(id), Item[w_UserId],Item[SQL_Key], Item[w_id], Item[w_Is_NameTaged], Item[w_NameTag], Item[w_Is_Stattrak], Item[w_Stattrak_Kills], Item[w_Damage_Level]);
          log_to_file(Filename_Give, logline);
        }
        else
        {
          client_print(id, print_console, "You can add him bcus his(#%i) inventory is full", Item[w_UserId]);
        }
        WasOnline = 1;
        break;
      }
  }

  if(!WasOnline)
    client_print(id, print_console, "You can add him bcus he(#%i) isn't online!", Item[w_UserId]);

  return;
}

public CmdListItem(id)
{
  client_print(id, print_console, "%s - *Weapon List*", Prefix);
  new m_g_Weapon_size = sizeof(g_Weapon);
  for(new i; i < m_g_Weapon_size;i++)
  {
    client_print(id, print_console, "id:%i | Name:%s", i, g_Weapon[i][w_name]);
  }
}

public CmdGiveMoney(id)
{
  if(s_AdminLevel[id] != 1)
  {
    client_print(id, print_console, "Nincs elérhetőseg ehhez a parancshoz!");
    return;
  }

  new Arg1[32], Arg2[32];

  read_argv(1, Arg1, charsmax(Arg1));
  read_argv(2, Arg2, charsmax(Arg2));

  if(Arg1[0] == EOS)
  {
    client_print(id, print_console, "money_give <#User_ID> <Money Amount>");
    return;
  }

  new m_UserId = str_to_num(Arg1);
  new m_Money = str_to_num(Arg2);

  new WasOnline = 0;
  for(new i = 1;i < 33;i++)
  {
    if(ska_get_user_id(i) == m_UserId)
    {
        s_Player[i][Euro] += m_Money;
        client_print_color(id, print_team_default, "^4%s ^1Sikeres addolás erre a fiókra: ^1%s(#%i)^1!",Prefix, Player_Stats[i][Name],ska_get_user_id(i));
        client_print_color(i, print_team_default, "^4%s ^1Sikeresen addoltak neked erről a fiókról: ^1%s(#%i)^1!",Prefix, Player_Stats[id][Name],ska_get_user_id(id));
        WasOnline = 1;
        i = 33;

        formatex(logline, 249, "MONEY_GIVE - _ADDER:#%i _TARGET:#%i _AMOUNT:%i", ska_get_user_id(id), m_UserId, m_Money);
        log_to_file(Filename_Give, logline);
    }
  }

  if(!WasOnline)
    client_print(id, print_console, "You can add him bcus he(#%i) isn't online!", m_UserId);

  return;
}

public CmdListCase(id)
{
  client_print(id, print_console, "%s - *Case List*", Prefix);
  for(new i; i < CaseDrops_CaseNum;i++)
  {
    client_print(id, print_console, "id:%i | Name:%s", i, g_CasesNames[i]);
  }
}

public CmdGiveKey(id)
{
  if(s_AdminLevel[id] != 1)
  {
    client_print(id, print_console, "Nincs elérhetőseg ehhez a parancshoz!");
    return;
  }

  new Arg1[32], Arg2[32];

  read_argv(1, Arg1, charsmax(Arg1));
  read_argv(2, Arg2, charsmax(Arg2));

  if(Arg1[0] == EOS)
  {
    client_print(id, print_console, "key_give <#User_ID> <Key Amount>");
    return;
  }

  new m_UserId = str_to_num(Arg1);
  new m_KeyAmount = str_to_num(Arg2);

  new WasOnline = 0;
  for(new i = 1;i < 33;i++)
  {
    if(ska_get_user_id(i) == m_UserId)
    {
        s_Player[i][Keys] += m_KeyAmount;
        client_print_color(id, print_team_default, "^4%s ^1Sikeres addolás erre a fiókra: ^1%s(#%i)^1!",Prefix, Player_Stats[i][Name],ska_get_user_id(i));
        client_print_color(i, print_team_default, "^4%s ^1Sikeresen addoltak neked erről a fiókról: ^1%s(#%i)^1!",Prefix, Player_Stats[id][Name],ska_get_user_id(id));
        WasOnline = 1;
        i = 33;

        formatex(logline, 249, "KEY_GIVE - _ADDER:#%i _TARGET:#%i _AMOUNT:%i", ska_get_user_id(id), m_UserId, m_KeyAmount);
        log_to_file(Filename_Give, logline);
    }
  }

  if(!WasOnline)
    client_print(id, print_console, "You can add him bcus he(#%i) isn't online!", m_UserId);

  return;
}

public CmdGiveCase(id)
{
  if(s_AdminLevel[id] != 1)
  {
    client_print(id, print_console, "Nincs elérhetőseg ehhez a parancshoz!");
    return;
  }

  new Arg1[32], Arg2[32], Arg3[32];

  read_argv(1, Arg1, charsmax(Arg1));
  read_argv(2, Arg2, charsmax(Arg2));
  read_argv(3, Arg3, charsmax(Arg3));

  if(Arg1[0] == EOS)
  {
    client_print(id, print_console, "case_give <#User_ID> <Case id> <Case Amount>");
    return;
  }

  new m_UserId = str_to_num(Arg1);
  new m_Case_id = str_to_num(Arg2);
  new m_Case_Amount = str_to_num(Arg3);

  if(m_Case_Amount == 0)
    m_Case_Amount = 1;

  new WasOnline = 0;
  for(new i = 1;i < 33;i++)
  {
    if(ska_get_user_id(i) == m_UserId)
    {
      Player_Cases[i][m_Case_id] += m_Case_Amount;
      client_print_color(id, print_team_default, "^4%s ^1Sikeres addolás erre a fiókra: ^1%s(#%i)^1!",Prefix, Player_Stats[i][Name],ska_get_user_id(i));
      client_print_color(i, print_team_default, "^4%s ^1Sikeresen addoltak neked erről a fiókról: ^1%s(#%i)^1!",Prefix, Player_Stats[id][Name],ska_get_user_id(id));
      WasOnline = 1;
      i = 33;

      formatex(logline, 249, "CASE_GIVE - _ADDER:#%i _TARGET:#%i _AMOUNT:%i #case_id:%i", ska_get_user_id(id), m_UserId, m_Case_Amount, m_Case_id);
      log_to_file(Filename_Give, logline);
    }
  }

  if(!WasOnline)
    client_print(id, print_console, "You can add him bcus he(#%i) isn't online!", m_UserId);

  return;
}

public CmdGiveInfinityFragment(id)
{
  if(s_AdminLevel[id] != 1)
  {
    client_print(id, print_console, "Nincs elérhetőseg ehhez a parancshoz!");
    return;
  }
  
  new Arg1[32], Arg2[32];

  read_argv(1, Arg1, charsmax(Arg1));
  read_argv(2, Arg2, charsmax(Arg2));

  if(Arg1[0] == EOS)
  {
    client_print(id, print_console, "if_give <#User_ID> <InfinityFragment Amount>");
    return;
  }

  new m_UserId = str_to_num(Arg1);
  new m_InfinityFragment = str_to_num(Arg2);

  new WasOnline = 0;
  for(new i = 1;i < 33;i++)
  {
    if(ska_get_user_id(i) == m_UserId)
    {
        s_Player[i][InfinityFragment] += m_InfinityFragment;
        client_print_color(id, print_team_default, "^4%s ^1Sikeres addolás erre a fiókra: ^1%s(#%i)^1!",Prefix, Player_Stats[i][Name],ska_get_user_id(i));
        client_print_color(i, print_team_default, "^4%s ^1Sikeresen addoltak neked erről a fiókról: ^1%s(#%i)^1!",Prefix, Player_Stats[id][Name],ska_get_user_id(id));
        WasOnline = 1;
        i = 33;

        formatex(logline, 249, "IF_GIVE - _ADDER:#%i _TARGET:#%i _AMOUNT:%i", ska_get_user_id(id), m_UserId, m_InfinityFragment);
        log_to_file(Filename_Give, logline);
    }
  }

  if(!WasOnline)
    client_print(id, print_console, "You can add him bcus he(#%i) isn't online!", m_UserId);

  return;
}

public CmdSetAdmin(id, level, cid){
	if(!str_to_num(Admin_Permissions[s_AdminLevel[id]][2])){
		client_print(id, print_console, "Nincs elérhetőseg ehhez a parancshoz!");
		return PLUGIN_HANDLED;
	}

	new Arg1[32], Arg2[32], Arg_Int[2];
	
	read_argv(1, Arg1, charsmax(Arg1));
	read_argv(2, Arg2, charsmax(Arg2));

	Arg_Int[0] = str_to_num(Arg1);
	Arg_Int[1] = str_to_num(Arg2);
	
	if(Arg_Int[0] < 1 || Arg_Int[1] >= sizeof(Admin_Permissions))
		return PLUGIN_HANDLED;	

	new Query[512], Data[2], Is_Online = Check_Id_Online(Arg_Int[0]);
	
	Data[0] = id;
	Data[1] = get_user_userid(id);
	
	formatex(Query, charsmax(Query), "UPDATE `NextLvL_S_Player` SET `Admin_Level` = %d WHERE `User_Id` = %d;", Arg_Int[1], Arg_Int[0]);
	SQL_ThreadQuery(g_SqlTuple, "QuerySetData", Query, Data, 2);
	
	if(Is_Online){
		if(Arg_Int[1] > 0)
			client_print_color(0, print_team_default, "%s Játékos: ^3%s ^1(#^3%d^1) | %s jogot kapott! ^3%s^1(#^3%d^1) által!", Prefix, Player_Stats[Is_Online][Name], Arg_Int[0], Admin_Permissions[Arg_Int[1]][0], Player_Stats[id][Name], ska_get_user_id(id));	
		else
			client_print_color(0, print_team_default, "%s Játékos: ^3%s ^1(#^3%d^1) | Jogok megvonva! ^3%s^1(#^3%d^1) által!", Prefix, Player_Stats[Is_Online][Name], Arg_Int[0], Player_Stats[id][Name], ska_get_user_id(id));	
	
		Set_Permissions(Is_Online);
		s_AdminLevel[Is_Online] = Arg_Int[1];
	}
	else{
		if(Arg_Int[1] > 0)
			client_print_color(0, print_team_default, "%s Játékos: ^3- ^1(#^3%d^1) | %s jogot kapott! ^3%s^1(#^3%d^1) által!", Prefix, Arg_Int[0], Admin_Permissions[Arg_Int[1]][0], Player_Stats[id][Name], ska_get_user_id(id));	
		else
			client_print_color(0, print_team_default, "%s Játékos: ^3- ^1(#^3%d^1) | Jogok megvonva! ^3%s^1(#^3%d^1) által!", Prefix, Arg_Int[0], Player_Stats[id][Name], ska_get_user_id(id));		
	}
		
	return PLUGIN_HANDLED;
}

public CmdResetScore(id)
{
  set_user_frags(id, 0);
  cs_set_user_deaths(id, 0);
  client_print_color(id, print_team_default, "^4%s ^1Sikeresen nulláztad a statisztikádat!",Prefix);
}
public CmdTop15(id)
{
  client_print_color(id, print_team_default, "^4%s ^1A top15 minden kör elején automatikusan frissül!",Prefix);

  new len;
  
  len += formatex(StringMotd[len], charsmax(StringMotd) - len, "<head><meta charset=^"UTF-8^"></head><center><table border=^"1^">");
  len += formatex(StringMotd[len], charsmax(StringMotd) - len, "<body bgcolor=#000000><table style=^"color:#00FFFF^">");
  len += formatex(StringMotd[len], charsmax(StringMotd) - len, "<td>Név</td>");
  len += formatex(StringMotd[len], charsmax(StringMotd) - len, "<td>Ölés</td>");
  len += formatex(StringMotd[len], charsmax(StringMotd) - len, "<td>Halál</td>");
  len += formatex(StringMotd[len], charsmax(StringMotd) - len, "<td>Fejes</td>");
  len += formatex(StringMotd[len], charsmax(StringMotd) - len, "<td>Pontosság</td>");

  for(new i; i < 15; i++)
  {
    len += formatex(StringMotd[len], charsmax(StringMotd) - len, "<tr><td>%i. %s</td>", i+1, Top15_list[i][Name]);
    len += formatex(StringMotd[len], charsmax(StringMotd) - len, "<td>%i</td>", Top15_list[i][Kills]);
    len += formatex(StringMotd[len], charsmax(StringMotd) - len, "<td>%i</td>", Top15_list[i][Deaths]);
    len += formatex(StringMotd[len], charsmax(StringMotd) - len, "<td>%i</td>", Top15_list[i][HSs]);
    len += formatex(StringMotd[len], charsmax(StringMotd) - len, "<td>%.2f</td></tr>", ( Top15_list[i][AllHitCount]/(Top15_list[i][AllShotCount]/100.0) ));
  }
  len = formatex(StringMotd[len], charsmax(StringMotd) - len, "</table></center>");

  show_motd(id, StringMotd, "Top15");
}

public CmdRank(id)
{
  Update_Player_Stats(id);
  Load_Data_All(id, "NextLvL_Player_Stats", "TablaAdatValasztasOsszes_PlayerStats");
}

public client_putinserver(id)
{
  s_Player[id][FirstServerLogin] = 1;
  InventoryClean(id);
  Player_Cases[id] = CasesEmpty;
  Equipmented[id] = EquipmentedDef;
  Player_Stats[id][Kills] = 0;
  Player_Stats[id][HSs] = 0;
  Player_Stats[id][Deaths] = 0;
  Player_Stats[id][AllHitCount] = 0;
  Player_Stats[id][AllShotCount] = 0;
  s_Player[id][Euro] = 0.0;
  s_AdminLevel[id] = 0;
  Player_Stats[id][Name] = "";
  get_user_name(id, Player_Stats[id][Name], 32);
  s_Player[id][PlayTime] = 0;
  s_Player[id][ToolsStattrak] = 0;
  s_Player[id][ToolsNametag] = 0;
  s_Player[id][InfinityFragment] = 0;
  s_Player[id][InventorySize] = 0;
  s_Player[id][InventorySizeMax] = 20;
  s_Player[id][InventoryWriteableSize] = 0;
  s_Player[id][SkinDisplay] = 1;
  s_Player[id][HudDisplayPlayerInfo] = 1;
  s_Player[id][HudDisplayWeaponInfo] = 1;
  s_Player[id][SoundPlay] = 1;
  s_Player[id][RoundEndSoundPlay] = 1;
  s_Player[id][KnifeSoundPlay] = 1;
  s_Player[id][ItemBreakSoundPlay] = 1;
  s_Player[id][CanSendMe] = 1;
  s_Player[id][SilentTransfer] = 0;
  s_Player[id][Ranking] = 1;
  s_Player[id][SilentAdminMod] = 0;
  s_Player[id][Keys] = 0;
  s_Player[id][WeaponBuyInRound] = 0;
  s_Player[id][RankPoint] = 0.0;

  searchsettings_Player[id][SelectedSearchType] = 0;
  searchsettings_Player[id][weaponsearch_Type] = -1;
  searchsettings_Player[id][weaponsearch_MaxDamage] = 101;
  searchsettings_Player[id][weaponsearch_MinDamage] = 0;
  searchsettings_Player[id][weaponsearch_MaxCost] = Market_MaxCost;
  searchsettings_Player[id][weaponsearch_MinCost] = 0;
  searchsettings_Player[id][weaponsearch_Stattrak] = -1;
  searchsettings_Player[id][weaponsearch_Nametag] = -1;
  searchsettings_Player[id][casesearch_Type] = -1;
  searchsettings_Player[id][casesearch_MaxAmount] = Market_MaxAmount;
  searchsettings_Player[id][casesearch_MinAmount] = 0;
  searchsettings_Player[id][casesearch_MaxCost] = Market_MaxCost;
  searchsettings_Player[id][casesearch_MinCost] = 0;
  searchsettings_Player[id][keysearch_MaxAmount] = Market_MaxAmount;
  searchsettings_Player[id][keysearch_MinAmount] = 0;
  searchsettings_Player[id][keysearch_MaxCost] = Market_MaxCost;
  searchsettings_Player[id][keysearch_MinCost] = 0;
  searchsettings_Player[id][infinityfragmentsearch_MaxAmount] = Market_MaxAmount;
  searchsettings_Player[id][infinityfragmentsearch_MinAmount] = 0;
  searchsettings_Player[id][infinityfragmentsearch_MaxCost] = Market_MaxCost;
  searchsettings_Player[id][infinityfragmentsearch_MinCost] = 0;
  searchsettings_Player[id][playersearch_User_id] = 1;
}

public InventoryGiveDefault(id)
{
  if(s_Player[id][FirstServerLogin] == 0)
    return;
  InventoryAddNewItem(id, 0, 0, "", 0, 0, 101, 0);
  InventoryAddNewItem(id, 1, 0, "", 0, 0, 101, 0);
  InventoryAddNewItem(id, 2, 0, "", 0, 0, 101, 0);
  InventoryAddNewItem(id, 3, 0, "", 0, 0, 101, 0);
  InventoryAddNewItem(id, 4, 0, "", 0, 0, 101, 0);
  InventoryAddNewItem(id, 5, 0, "", 0, 0, 101, 0);
  InventoryAddNewItem(id, 6, 0, "", 0, 0, 101, 0);
  InventoryAddNewItem(id, 7, 0, "", 0, 0, 101, 0);
  s_Player[id][FirstServerLogin] = 0;
}
public plugin_cfg()
{
    g_SqlTuple = SQL_MakeDbTuple(SQLINFO[0], SQLINFO[1], SQLINFO[2], SQLINFO[3]);
    
    CreateTable_S_Player();
    CreateTable_Player_Stats();
    CreateTable_Player_Cases();
    CreateTable_g_Inventory();
    CreateTable_g_Products();
}
public CreateTable_g_Products()
{

  new Len;

  Len += formatex(Query[Len], charsmax(Query), "CREATE TABLE IF NOT EXISTS `NextLvL_g_Products` ");
  Len += formatex(Query[Len], charsmax(Query)-Len, "( ");
  Len += formatex(Query[Len], charsmax(Query)-Len, "`product_SQL_key` INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,");
  Len += formatex(Query[Len], charsmax(Query)-Len, "`UTS_EndTimeDate` INT(32) NOT NULL,");
  Len += formatex(Query[Len], charsmax(Query)-Len, "`Type` INT(2) NOT NULL,");
  Len += formatex(Query[Len], charsmax(Query)-Len, "`product_id` INT(11) NOT NULL,");
  Len += formatex(Query[Len], charsmax(Query)-Len, "`Amount` INT(11) NOT NULL,");
  Len += formatex(Query[Len], charsmax(Query)-Len, "`Price` INT(32) NOT NULL,");
  Len += formatex(Query[Len], charsmax(Query)-Len, "`Seller_User_id` INT(32) NOT NULL,");
  Len += formatex(Query[Len], charsmax(Query)-Len, "`p_w_Is_NameTaged` INT(1) NOT NULL,");
  Len += formatex(Query[Len], charsmax(Query)-Len, "`p_w_NameTag` varchar(32) NOT NULL,");
  Len += formatex(Query[Len], charsmax(Query)-Len, "`p_w_Is_Stattrak` INT(1) NOT NULL,");
  Len += formatex(Query[Len], charsmax(Query)-Len, "`p_w_Stattrak_Kills` INT(32) NOT NULL,");
  Len += formatex(Query[Len], charsmax(Query)-Len, "`p_w_Damage_Level` INT(4) NOT NULL,");
  Len += formatex(Query[Len], charsmax(Query)-Len, "`p_w_AttackCount` INT(11) NOT NULL)");
  
  SQL_ThreadQuery(g_SqlTuple, "createTableThread", Query);
}

public CreateTable_S_Player()
{

  new Len;

  Len += formatex(Query[Len], charsmax(Query), "CREATE TABLE IF NOT EXISTS `NextLvL_S_Player` ");
  Len += formatex(Query[Len], charsmax(Query)-Len, "( ");
  Len += formatex(Query[Len], charsmax(Query)-Len, "`Id` INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,");
  Len += formatex(Query[Len], charsmax(Query)-Len, "`User_Id` INT(11) NOT NULL,");
  Len += formatex(Query[Len], charsmax(Query)-Len, "`FirstServerLogin` INT(1) NOT NULL,");
  Len += formatex(Query[Len], charsmax(Query)-Len, "`Dollar` INT(32) NOT NULL,");
  Len += formatex(Query[Len], charsmax(Query)-Len, "`PlayTime` INT(32) NOT NULL,");
  Len += formatex(Query[Len], charsmax(Query)-Len, "`Admin_Level` INT(1) NOT NULL,");
  Len += formatex(Query[Len], charsmax(Query)-Len, "`ToolsStattrak` INT(32) NOT NULL,");
  Len += formatex(Query[Len], charsmax(Query)-Len, "`ToolsNametag` INT(32) NOT NULL,");
  Len += formatex(Query[Len], charsmax(Query)-Len, "`InfinityFragment` INT(32) NOT NULL,");
  Len += formatex(Query[Len], charsmax(Query)-Len, "`InventorySizeMax` INT(6) NOT NULL,");
  Len += formatex(Query[Len], charsmax(Query)-Len, "`MarketSize` INT(6) NOT NULL,");
  Len += formatex(Query[Len], charsmax(Query)-Len, "`SkinDisplay` INT(1) NOT NULL,");
  Len += formatex(Query[Len], charsmax(Query)-Len, "`HudDisplayPlayerInfo` INT(1) NOT NULL,");
  Len += formatex(Query[Len], charsmax(Query)-Len, "`HudDisplayWeaponInfo` INT(1) NOT NULL,");
  Len += formatex(Query[Len], charsmax(Query)-Len, "`SoundPlay` INT(1) NOT NULL,");
  Len += formatex(Query[Len], charsmax(Query)-Len, "`RoundEndSoundPlay` INT(1) NOT NULL,");
  Len += formatex(Query[Len], charsmax(Query)-Len, "`KnifeSoundPlay` INT(1) NOT NULL,");
  Len += formatex(Query[Len], charsmax(Query)-Len, "`ItemBreakSoundPlay` INT(1) NOT NULL,");
  Len += formatex(Query[Len], charsmax(Query)-Len, "`CanSendMe` INT(1) NOT NULL,");
  Len += formatex(Query[Len], charsmax(Query)-Len, "`SilentTransfer` INT(1) NOT NULL,");
  Len += formatex(Query[Len], charsmax(Query)-Len, "`SilentAdminMod` INT(1) NOT NULL,");
  Len += formatex(Query[Len], charsmax(Query)-Len, "`Ranking` INT(1) NOT NULL,");
  Len += formatex(Query[Len], charsmax(Query)-Len, "`iKeys` INT(32) NOT NULL,");
  Len += formatex(Query[Len], charsmax(Query)-Len, "`RankPoint` INT(32) NOT NULL)");
  
  SQL_ThreadQuery(g_SqlTuple, "createTableThread", Query);
}

public CreateTable_Player_Stats()
{
  new Len;

  Len += formatex(Query[Len], charsmax(Query), "CREATE TABLE IF NOT EXISTS `NextLvL_Player_Stats` ");
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

public CreateTable_Player_Cases()
{
  new Len;

  Len += formatex(Query[Len], charsmax(Query), "CREATE TABLE IF NOT EXISTS `NextLvL_Player_Cases` ");
  Len += formatex(Query[Len], charsmax(Query)-Len, "( ");
  Len += formatex(Query[Len], charsmax(Query)-Len, "`Id` INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,");
  Len += formatex(Query[Len], charsmax(Query)-Len, "`User_Id` INT(11) NOT NULL,");
  Len += formatex(Query[Len], charsmax(Query)-Len, "`S0_Fusion` INT(11) NOT NULL,");
  Len += formatex(Query[Len], charsmax(Query)-Len, "`S0_Power` INT(11) NOT NULL,");
  Len += formatex(Query[Len], charsmax(Query)-Len, "`S0_Thunder` INT(11) NOT NULL,");
  Len += formatex(Query[Len], charsmax(Query)-Len, "`S0_Light` INT(11) NOT NULL,");
  Len += formatex(Query[Len], charsmax(Query)-Len, "`S0_Boom` INT(11) NOT NULL,");
  Len += formatex(Query[Len], charsmax(Query)-Len, "`S1_BlackIce` INT(11) NOT NULL,");
  Len += formatex(Query[Len], charsmax(Query)-Len, "`S1_NoName` INT(11) NOT NULL)");
  //CASE EXTEND NEED HERE, Ha ládát akarsz böviteni itt is kell!
  
  SQL_ThreadQuery(g_SqlTuple, "createTableThread", Query);
}

public CreateTable_g_Inventory()
{

  new Len;

  Len += formatex(Query[Len], charsmax(Query), "CREATE TABLE IF NOT EXISTS `NextLvL_g_Inventory` ");
  Len += formatex(Query[Len], charsmax(Query)-Len, "( ");
  Len += formatex(Query[Len], charsmax(Query)-Len, "`SQL_Key` INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,");
  Len += formatex(Query[Len], charsmax(Query)-Len, "`User_Id` INT(11) NOT NULL,");
  Len += formatex(Query[Len], charsmax(Query)-Len, "`Weapon_Id` INT(3) NOT NULL, ");
  Len += formatex(Query[Len], charsmax(Query)-Len, "`Is_NameTaged` INT(1) NOT NULL,");
  Len += formatex(Query[Len], charsmax(Query)-Len, "`NameTag` varchar(32) NOT NULL,");
  Len += formatex(Query[Len], charsmax(Query)-Len, "`Is_StatTraked` INT(1) NOT NULL,");
  Len += formatex(Query[Len], charsmax(Query)-Len, "`StatTrak_Kills` INT(11) NOT NULL,");
  Len += formatex(Query[Len], charsmax(Query)-Len, "`Damage_Level` INT(3) NOT NULL,");
  Len += formatex(Query[Len], charsmax(Query)-Len, "`AttackCount` INT(11) NOT NULL,");
  Len += formatex(Query[Len], charsmax(Query)-Len, "`Tradable` INT(1) NOT NULL,");
  Len += formatex(Query[Len], charsmax(Query)-Len, "`Equiped` INT(1) NOT NULL)");
  
  SQL_ThreadQuery(g_SqlTuple, "createTableThread", Query);
}

public createTableThread(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime) 
{
  if(FailState == TQUERY_CONNECT_FAILED)
  set_fail_state("[HIBA*] NEM TUDTAM CSATLAKOZNI AZ ADATBAZISHOZ!");
  else if(FailState == TQUERY_QUERY_FAILED)
  set_fail_state("Query Error");
  if(Errcode)
log_amx("[HIBA*] HIBAT DOBTAM: %s",Error);
  }
public Load_User_Data(id)
{
  Load_Data(id, "NextLvL_S_Player", "TablaAdatValasztas_sPlayer");
  Load_Data(id, "NextLvL_Player_Stats", "TablaAdatValasztas_PlayerStats");
  Load_Data(id, "NextLvL_Player_Cases", "TablaAdatValasztas_Cases");
  Load_Data(id, "NextLvL_g_Inventory", "TablaAdatValasztas_gInventory");
  Load_Data(id, "NextLvL_BetaTesters", "TablaAdatLetrehoz_BetaTesters")
}

public Load_Data_All(id, Table_Name[], ForwardMetod[])
{
  new Data[1];
  Data[0] = id;
  formatex(Query, charsmax(Query), "SELECT * FROM `%s` ORDER BY ( Kills + ( HSs / 10 ) - Deaths ) * ( AllHitCount / ( AllShotCount / 100 ) ) DESC;",Table_Name);
  SQL_ThreadQuery(g_SqlTuple, ForwardMetod, Query, Data, 1);
}

public Load_Data_15(Table_Name[], ForwardMetod[])
{
  new Data[1];
  formatex(Query, charsmax(Query), "SELECT * FROM `%s` ORDER BY ( Kills + ( HSs / 10 ) - Deaths ) * ( AllHitCount / ( AllShotCount / 100 ) ) DESC;",Table_Name);
  SQL_ThreadQuery(g_SqlTuple, ForwardMetod, Query, Data, 1);
}


public Load_Data(id, Table_Name[], ForwardMetod[])
{
  new Data[1];
  Data[0] = id;
  formatex(Query, charsmax(Query), "SELECT * FROM `%s` WHERE User_Id = %d;",Table_Name ,ska_get_user_id(id))
  SQL_ThreadQuery(g_SqlTuple, ForwardMetod, Query, Data, 1);
}
public Load_Data_Market(Table_Name[], ForwardMetod[])
{
  new Data[1];
  formatex(Query, charsmax(Query), "SELECT * FROM `%s`;",Table_Name)
  SQL_ThreadQuery(g_SqlTuple, ForwardMetod, Query, Data, 1);
}

public TablaAdatLetrehoz_BetaTesters(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime) 
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
      //Már volt fent béta teszt idő alatt
    }
    else 
    {
      new text[512];
      formatex(text, charsmax(text), "INSERT INTO `NextLvL_BetaTesters` (`User_id`) VALUES (%i);", ska_get_user_id(id));
      SQL_ThreadQuery(g_SqlTuple, "QuerySetData", text);
      InventoryGiveDefault(id);
    }
  }
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
        Top15_list[x][AllHitCount] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "AllHitCount"));
        Top15_list[x][AllShotCount] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "AllShotCount"));
        if(Top15_list[x][AllHitCount] != 0 && Top15_list[x][AllShotCount] != 0)
        {
          SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Name"),Top15_list[x][Name] , 31);
          Top15_list[x][Kills] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Kills")); 
          Top15_list[x][HSs] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "HSs"));
          Top15_list[x][Deaths] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Deaths"));
          x++;
        }
        SQL_NextRow(Query);
      }
    }
    /*else 
    {
      new text[512];
      formatex(text, charsmax(text), "INSERT INTO `NextLvL_g_Inventory` (`User_Id`) VALUES (%i);", ska_get_user_id(id));
      SQL_ThreadQuery(g_SqlTuple, "QuerySetData", text);
    }*/
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
        if(SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "User_Id")) == ska_get_user_id(id))
        {
          s_Player[id][Now_Rank] = x;
          if(0 == SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "AllHitCount")) || 0 == SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "AllShotCount")))
            CanNOTRanked = 1;
        }
        SQL_NextRow(Query);
      }
      AllRegistedRank = x;
      if(CanNOTRanked)
      {
        client_print_color(id, print_team_default, "^4%s ^1Rangod: N/%i , Ölések:%i , Halálok:%i , Fejesek:%i , Hatékonyság:%.3f", Prefix, AllRegistedRank, Player_Stats[id][Kills], Player_Stats[id][Deaths], Player_Stats[id][HSs], ( Player_Stats[id][AllHitCount]/(Player_Stats[id][AllShotCount]/100.0) ));
        client_print_color(id, print_team_default, "^4%s ^1Nincs elég adatunk hogy betudjuk sorolni megfelelően!",Prefix);
      }
      else
        client_print_color(id, print_team_default, "^4%s ^1Rangod: %i/%i , Ölések:%i , Halálok:%i , Fejesek:%i , Hatékonyság:%.3f", Prefix, s_Player[id][Now_Rank], AllRegistedRank, Player_Stats[id][Kills], Player_Stats[id][Deaths], Player_Stats[id][HSs], ( Player_Stats[id][AllHitCount]/(Player_Stats[id][AllShotCount]/100.0) ));
    }
    /*else 
    {
      new text[512];
      formatex(text, charsmax(text), "INSERT INTO `NextLvL_g_Inventory` (`User_Id`) VALUES (%i);", ska_get_user_id(id));
      SQL_ThreadQuery(g_SqlTuple, "QuerySetData", text);
    }*/
  }
}

public TablaAdatValasztas_sPlayer(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime) 
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
      s_Player[id][FirstServerLogin] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "FirstServerLogin"));
      s_Player[id][Euro] = (float(SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Dollar")))/100.0);
      s_Player[id][PlayTime] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "PlayTime"));
      s_AdminLevel[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Admin_Level"));
      s_Player[id][ToolsStattrak] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "ToolsStattrak"));
      s_Player[id][ToolsNametag] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "ToolsNametag"));
      s_Player[id][InfinityFragment] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "InfinityFragment"));
      s_Player[id][InventorySizeMax] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "InventorySizeMax"));
      s_Player[id][MarketSize] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "MarketSize"));
      s_Player[id][SkinDisplay] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "SkinDisplay"));
      s_Player[id][HudDisplayPlayerInfo] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "HudDisplayPlayerInfo"));
      s_Player[id][HudDisplayWeaponInfo] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "HudDisplayWeaponInfo"));
      s_Player[id][SoundPlay] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "SoundPlay"));
      s_Player[id][RoundEndSoundPlay] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "RoundEndSoundPlay"));
      s_Player[id][KnifeSoundPlay] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "KnifeSoundPlay"));
      s_Player[id][ItemBreakSoundPlay] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "ItemBreakSoundPlay"));
      s_Player[id][CanSendMe] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "CanSendMe"));
      s_Player[id][SilentTransfer] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "SilentTransfer"));
      s_Player[id][SilentAdminMod] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "SilentAdminMod"));
      s_Player[id][Ranking] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Ranking"));
      s_Player[id][Keys] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "iKeys"));
      s_Player[id][RankPoint] = (float(SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "RankPoint")))/100.0);

      new fwdtogglemusic
      ExecuteForward(fwd_musiccmd,fwdtogglemusic,id);
      
      Set_Permissions(id);
    }
    else 
    {
      new text[512];
      formatex(text, charsmax(text), "INSERT INTO `NextLvL_S_Player` (`User_Id`, `FirstServerLogin`) VALUES (%i, 0);", ska_get_user_id(id));
      SQL_ThreadQuery(g_SqlTuple, "QuerySetData", text);
      InventoryGiveDefault(id);
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
         Player_Stats[id][Kills] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Kills")); 
         Player_Stats[id][HSs] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "HSs"));
         Player_Stats[id][Deaths] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Deaths"));
         Player_Stats[id][AllHitCount] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "AllHitCount"));
         Player_Stats[id][AllShotCount] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "AllShotCount"));
       }
       else 
       {
         new text[512];
         formatex(text, charsmax(text), "INSERT INTO `NextLvL_Player_Stats` (`User_Id`) VALUES (%i);", ska_get_user_id(id));
         SQL_ThreadQuery(g_SqlTuple, "QuerySetData", text);
       }
  }
}
public TablaAdatValasztas_Cases(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime) 
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
      Player_Cases[id][0] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "S0_Fusion"));
      Player_Cases[id][1] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "S0_Power"));
      Player_Cases[id][2] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "S0_Thunder"));
      Player_Cases[id][3] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "S0_Light"));
      Player_Cases[id][4] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "S0_Boom"));
      Player_Cases[id][5] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "S1_BlackIce"));
      Player_Cases[id][6] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "S1_NoName"));
      //CASE EXTEND NEED HERE, Ha ládát akarsz böviteni itt is kell!
    }
    else 
    {
      new text[512];
      formatex(text, charsmax(text), "INSERT INTO `NextLvL_Player_Cases` (`User_Id`) VALUES (%i);", ska_get_user_id(id));
      SQL_ThreadQuery(g_SqlTuple, "QuerySetData", text);
    }
  }
}
public Update_Player_Stats(id)
{
  new Len;
  
  Len += formatex(Query[Len], charsmax(Query), "UPDATE `NextLvL_Player_Stats` SET ");
  Len += formatex(Query[Len], charsmax(Query)-Len, "Name = ^"%s^", ", Player_Stats[id][Name]);
  Len += formatex(Query[Len], charsmax(Query)-Len, "Kills = ^"%i^", ", Player_Stats[id][Kills]);
  Len += formatex(Query[Len], charsmax(Query)-Len, "HSs = ^"%i^", ", Player_Stats[id][HSs]);
  Len += formatex(Query[Len], charsmax(Query)-Len, "Deaths = ^"%i^", ", Player_Stats[id][Deaths]);
  Len += formatex(Query[Len], charsmax(Query)-Len, "AllHitCount = ^"%i^", ", Player_Stats[id][AllHitCount]);
  
  Len += formatex(Query[Len], charsmax(Query)-Len, "AllShotCount = ^"%i^" WHERE `User_Id` =  %d;", Player_Stats[id][AllShotCount], ska_get_user_id(id));
  
  SQL_ThreadQuery(g_SqlTuple, "QuerySetData_Stats", Query);
}
public TablaAdatValasztas_gInventory(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime) 
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
      new x = 0;
      while(SQL_MoreResults(Query))
      {
        Inventory[id][x][w_UserId] = ska_get_user_id(id);
        Inventory[id][x][SQL_Key] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "SQL_Key"));
        Inventory[id][x][w_UserId] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "User_Id"));
        Inventory[id][x][w_id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Weapon_Id"));
        Inventory[id][x][w_Is_NameTaged] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Is_NameTaged"));
        SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "NameTag"), Inventory[id][x][w_NameTag], 31);
        Inventory[id][x][w_Is_Stattrak] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Is_StatTraked"));
        Inventory[id][x][w_Stattrak_Kills] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "StatTrak_Kills"));
        Inventory[id][x][w_Damage_Level] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Damage_Level"));
        Inventory[id][x][w_AttackCount] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "AttackCount"));
        Inventory[id][x][w_Tradable] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Tradable"));
        Inventory[id][x][w_Equiped] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Equiped"));
        
        if(Inventory[id][x][w_Equiped])
          EquipWeapon(id, x);
        
        x++;
        s_Player[id][InventorySize] = x;
        s_Player[id][InventoryWriteableSize] = x;
        SQL_NextRow(Query);
      }
    }
    /*else 
    {
      new text[512];
      formatex(text, charsmax(text), "INSERT INTO `NextLvL_g_Inventory` (`User_Id`) VALUES (%i);", ska_get_user_id(id));
      SQL_ThreadQuery(g_SqlTuple, "QuerySetData", text);
    }*/
  }
}
public TablaAdatValasztas_gProducts(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime) 
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
      new m_Product[product_Properties];
      while(SQL_MoreResults(Query))
      {
        m_Product[product_SQL_key] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "product_SQL_key"));
        m_Product[UTS_EndTimeDate] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "UTS_EndTimeDate"));
        m_Product[Type] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Type"));
        m_Product[product_id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "product_id"));
        m_Product[Amount] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Amount"));
        m_Product[Price] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Price"));
        m_Product[Seller_User_id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Seller_User_id"));
        m_Product[p_w_Is_NameTaged] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "p_w_Is_NameTaged"));
        SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "p_w_NameTag"), m_Product[p_w_NameTag], 31);
        m_Product[p_w_Is_Stattrak] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "p_w_Is_Stattrak"));
        m_Product[p_w_Stattrak_Kills] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "p_w_Stattrak_Kills"));
        m_Product[p_w_Damage_Level] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "p_w_Damage_Level"));
        m_Product[p_w_AttackCount] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "p_w_AttackCount"));
        
        ArrayPushArray(g_Products, m_Product);
        SQL_NextRow(Query);
      }
      client_print_color(0, print_team_default, "^4%s ^1A piaci árucikk(ek) sikeresen betöltödtek!",Prefix);
    }
  }
}

public Update_User_Data(id)
{
  Update_s_Player(id);
  Update_Player_Stats(id);
  Update_Player_Cases(id);
  Update_g_Inventory(id);
}

public Update_s_Player(id)
{
  new Len;
  
  Len += formatex(Query[Len], charsmax(Query), "UPDATE `NextLvL_S_Player` SET ");
  Len += formatex(Query[Len], charsmax(Query)-Len, "FirstServerLogin = ^"%i^", ", s_Player[id][FirstServerLogin]);
  Len += formatex(Query[Len], charsmax(Query)-Len, "Dollar = ^"%i^", ", floatround(s_Player[id][Euro]*100.0))
  Len += formatex(Query[Len], charsmax(Query)-Len, "PlayTime = ^"%i^", ", s_Player[id][PlayTime]+get_user_time(id));
  Len += formatex(Query[Len], charsmax(Query)-Len, "ToolsStattrak = ^"%i^", ", s_Player[id][ToolsStattrak]);
  Len += formatex(Query[Len], charsmax(Query)-Len, "ToolsNametag = ^"%i^", ", s_Player[id][ToolsNametag]);
  Len += formatex(Query[Len], charsmax(Query)-Len, "InfinityFragment = ^"%i^", ", s_Player[id][InfinityFragment]);
  Len += formatex(Query[Len], charsmax(Query)-Len, "InventorySizeMax = ^"%i^", ", s_Player[id][InventorySizeMax]);
  Len += formatex(Query[Len], charsmax(Query)-Len, "MarketSize = ^"%i^", ", s_Player[id][MarketSize]);
  Len += formatex(Query[Len], charsmax(Query)-Len, "SkinDisplay = ^"%i^", ", s_Player[id][SkinDisplay]);
  Len += formatex(Query[Len], charsmax(Query)-Len, "HudDisplayPlayerInfo = ^"%i^", ", s_Player[id][HudDisplayPlayerInfo]);
  Len += formatex(Query[Len], charsmax(Query)-Len, "HudDisplayWeaponInfo = ^"%i^", ", s_Player[id][HudDisplayWeaponInfo]);
  Len += formatex(Query[Len], charsmax(Query)-Len, "SoundPlay = ^"%i^", ", s_Player[id][SoundPlay]);
  Len += formatex(Query[Len], charsmax(Query)-Len, "RoundEndSoundPlay = ^"%i^", ", s_Player[id][RoundEndSoundPlay]);
  Len += formatex(Query[Len], charsmax(Query)-Len, "KnifeSoundPlay = ^"%i^", ", s_Player[id][KnifeSoundPlay]);
  Len += formatex(Query[Len], charsmax(Query)-Len, "ItemBreakSoundPlay = ^"%i^", ", s_Player[id][ItemBreakSoundPlay]);
  Len += formatex(Query[Len], charsmax(Query)-Len, "CanSendMe = ^"%i^", ", s_Player[id][CanSendMe]);
  Len += formatex(Query[Len], charsmax(Query)-Len, "SilentTransfer = ^"%i^", ", s_Player[id][SilentTransfer]);
  Len += formatex(Query[Len], charsmax(Query)-Len, "SilentAdminMod = ^"%i^", ", s_Player[id][SilentAdminMod]);
  Len += formatex(Query[Len], charsmax(Query)-Len, "Ranking = ^"%i^", ", s_Player[id][Ranking]);
  Len += formatex(Query[Len], charsmax(Query)-Len, "iKeys = ^"%i^", ", s_Player[id][Keys]);
  Len += formatex(Query[Len], charsmax(Query)-Len, "RankPoint = ^"%i^" ", floatround(s_Player[id][RankPoint]*100.0));

  Len += formatex(Query[Len], charsmax(Query)-Len, "WHERE `User_Id` =  %d;", ska_get_user_id(id));
  
  SQL_ThreadQuery(g_SqlTuple, "QuerySetData_PlayerS", Query);
}


public Update_Player_Cases(id)
{
  new Len;
  
  Len += formatex(Query[Len], charsmax(Query), "UPDATE `NextLvL_Player_Cases` SET ");
  Len += formatex(Query[Len], charsmax(Query)-Len, "S0_Fusion = ^"%i^", ", Player_Cases[id][0]);
  Len += formatex(Query[Len], charsmax(Query)-Len, "S0_Power = ^"%i^", ", Player_Cases[id][1]);
  Len += formatex(Query[Len], charsmax(Query)-Len, "S0_Thunder = ^"%i^", ", Player_Cases[id][2]);
  Len += formatex(Query[Len], charsmax(Query)-Len, "S0_Light = ^"%i^", ", Player_Cases[id][3]);
  Len += formatex(Query[Len], charsmax(Query)-Len, "S0_Boom = ^"%i^", ", Player_Cases[id][4]);
  Len += formatex(Query[Len], charsmax(Query)-Len, "S1_BlackIce = ^"%i^", ", Player_Cases[id][5]);
  Len += formatex(Query[Len], charsmax(Query)-Len, "S1_NoName = ^"%i^", ", Player_Cases[id][6]);
  //CASE EXTEND NEED HERE, Ha ládát akarsz böviteni itt is kell!

  Len += formatex(Query[Len], charsmax(Query)-Len, "S1_BlackIce = ^"%i^" WHERE `User_Id` =  %d;", Player_Cases[id][5], ska_get_user_id(id));
  
  SQL_ThreadQuery(g_SqlTuple, "QuerySetData_Cases", Query);
}

public Update_g_Inventory(id)
{
  new Len;
  
  new m_InventoryWriteableSize = s_Player[id][InventoryWriteableSize];
  for(new x; x < m_InventoryWriteableSize; x++)
  {
    Len = 0;
    if(Inventory[id][x][SQL_Key] == -1 && Inventory[id][x][w_Deleted] == 1)
    {
      //Nem volt feltöltve táblába (kinyitották és törölték is utánna)
    }
    else if(Inventory[id][x][w_Deleted] == 1)
    {
      Len += formatex(Query[Len], charsmax(Query), "DELETE FROM `NextLvL_g_Inventory` WHERE `SQL_Key` = %d;", Inventory[id][x][SQL_Key]);
    }
    else if(Inventory[id][x][SQL_Key] >= 0)
    {
      Len += formatex(Query[Len], charsmax(Query), "UPDATE `NextLvL_g_Inventory` SET ");
      Len += formatex(Query[Len], charsmax(Query)-Len, "User_Id = ^"%i^", ", Inventory[id][x][w_UserId]);
      Len += formatex(Query[Len], charsmax(Query)-Len, "Weapon_Id = ^"%i^", ", Inventory[id][x][w_id]);
      Len += formatex(Query[Len], charsmax(Query)-Len, "Is_NameTaged = ^"%i^", ", Inventory[id][x][w_Is_NameTaged]);
      Len += formatex(Query[Len], charsmax(Query)-Len, "NameTag = ^"%s^", ", Inventory[id][x][w_NameTag]);
      Len += formatex(Query[Len], charsmax(Query)-Len, "Is_StatTraked = ^"%i^", ", Inventory[id][x][w_Is_Stattrak]);
      Len += formatex(Query[Len], charsmax(Query)-Len, "StatTrak_Kills = ^"%i^", ", Inventory[id][x][w_Stattrak_Kills]);
      Len += formatex(Query[Len], charsmax(Query)-Len, "Damage_Level = ^"%i^", ", Inventory[id][x][w_Damage_Level]);
      Len += formatex(Query[Len], charsmax(Query)-Len, "AttackCount = ^"%i^", ", Inventory[id][x][w_AttackCount]);
      Len += formatex(Query[Len], charsmax(Query)-Len, "Tradable = ^"%i^", ", Inventory[id][x][w_Tradable]);
      Len += formatex(Query[Len], charsmax(Query)-Len, "Equiped = ^"%i^" ", Inventory[id][x][w_Equiped]);
      Len += formatex(Query[Len], charsmax(Query)-Len, "WHERE `SQL_Key` =  %d;", Inventory[id][x][SQL_Key]);
    }
    else
    {
      Len += formatex(Query[Len], charsmax(Query), "INSERT INTO `NextLvL_g_Inventory` (`User_Id`, `Weapon_Id`, `Is_NameTaged`, `NameTag`, `Is_StatTraked`, `StatTrak_Kills`, `Damage_Level`, `AttackCount`, `Tradable`, `Equiped`) VALUES (");
      Len += formatex(Query[Len], charsmax(Query)-Len, "%i, ", Inventory[id][x][w_UserId]);
      Len += formatex(Query[Len], charsmax(Query)-Len, "%i, ", Inventory[id][x][w_id]);
      Len += formatex(Query[Len], charsmax(Query)-Len, "%i, ", Inventory[id][x][w_Is_NameTaged]);
      Len += formatex(Query[Len], charsmax(Query)-Len, "^"%s^", ", Inventory[id][x][w_NameTag]);
      Len += formatex(Query[Len], charsmax(Query)-Len, "%i, ", Inventory[id][x][w_Is_Stattrak]);
      Len += formatex(Query[Len], charsmax(Query)-Len, "%i, ", Inventory[id][x][w_Stattrak_Kills]);
      Len += formatex(Query[Len], charsmax(Query)-Len, "%i, ", Inventory[id][x][w_Damage_Level]);
      Len += formatex(Query[Len], charsmax(Query)-Len, "%i, ", Inventory[id][x][w_AttackCount]);
      Len += formatex(Query[Len], charsmax(Query)-Len, "%i, ", Inventory[id][x][w_Tradable]);
      Len += formatex(Query[Len], charsmax(Query)-Len, "%i", Inventory[id][x][w_Equiped]);
      Len += formatex(Query[Len], charsmax(Query)-Len, ");");
    }
    SQL_ThreadQuery(g_SqlTuple, "QuerySetData_Invi", Query);
  }
}
public Update_g_Products()
{
  new Len;
  
  new m_g_Products_sizeof = ArraySize(g_Products);
  new m_Product[product_Properties];
  for(new x; x < m_g_Products_sizeof; x++)
  {
    ArrayGetArray(g_Products ,x ,m_Product);
    Len = 0;
    if(m_Product[product_SQL_key] == -1 && m_Product[Price] < 0)
    {
      //Nem volt feltöltve táblába (kirakták és megvették utánna utánna)
    }
    else if(m_Product[Price] < 0)
    {
      Len += formatex(Query[Len], charsmax(Query), "DELETE FROM `NextLvL_g_Products` WHERE `product_SQL_key` = %i;", m_Product[product_SQL_key]);
    }
    else if(m_Product[product_SQL_key] == -1)
    {
      Len += formatex(Query[Len], charsmax(Query), "INSERT INTO `NextLvL_g_Products` (`UTS_EndTimeDate`, `Type`, `product_id`, `Amount`, `Price`, `Seller_User_id`, `p_w_Is_NameTaged`, `p_w_NameTag`, `p_w_Is_Stattrak`, `p_w_Stattrak_Kills`, `p_w_Damage_Level`, `p_w_AttackCount`) VALUES (");
      Len += formatex(Query[Len], charsmax(Query)-Len, "%i, ", m_Product[UTS_EndTimeDate]);
      Len += formatex(Query[Len], charsmax(Query)-Len, "%i, ", m_Product[Type]);
      Len += formatex(Query[Len], charsmax(Query)-Len, "%i, ", m_Product[product_id]);
      Len += formatex(Query[Len], charsmax(Query)-Len, "%i, ", m_Product[Amount]);
      Len += formatex(Query[Len], charsmax(Query)-Len, "%i, ", m_Product[Price]);
      Len += formatex(Query[Len], charsmax(Query)-Len, "%i, ", m_Product[Seller_User_id]);
      Len += formatex(Query[Len], charsmax(Query)-Len, "%i, ", m_Product[p_w_Is_NameTaged]);
      Len += formatex(Query[Len], charsmax(Query)-Len, "^"%s^", ", m_Product[p_w_NameTag]);
      Len += formatex(Query[Len], charsmax(Query)-Len, "%i, ", m_Product[p_w_Is_Stattrak]);
      Len += formatex(Query[Len], charsmax(Query)-Len, "%i, ", m_Product[p_w_Stattrak_Kills]);
      Len += formatex(Query[Len], charsmax(Query)-Len, "%i, ", m_Product[p_w_Damage_Level]);
      Len += formatex(Query[Len], charsmax(Query)-Len, "%i);", m_Product[p_w_AttackCount]);
    }
    SQL_ThreadQuery(g_SqlTuple, "QuerySetData_Market", Query);
  }
}

public QuerySetData_PlayerS(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime)
{
  if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) 
  {
    log_amx("Error from s_Player:");
    log_amx("%s", Error);
    return;
  }
}
public QuerySetData_Cases(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime)
{
  if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) 
  {
    log_amx("Error from Player_Cases:");
    log_amx("%s", Error);
    return;
  }
}
public QuerySetData_Invi(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime)
{
  if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) 
  {
    log_amx("Error from Inventory:");
    log_amx("%s", Error);
    return;
  }
}
public QuerySetData_Market(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime)
{
  if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) 
  {
    log_amx("Error from Market:");
    log_amx("%s", Error);
    return;
  }
}
public QuerySetData_Stats(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime)
{
  if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) 
  {
    log_amx("Error from StatS:");
    log_amx("%s", Error);
    return;
  }
}
public QuerySetData(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime)
{
  if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) 
  {
    log_amx("Error from GlobálisDolog:");
    log_amx("%s", Error);
    return;
  }
}
  stock Check_Id_Online(id){
	for(new idx = 1; idx < g_Maxplayers; idx++){
		if(!is_user_connected(idx) || !ska_is_user_logged(idx))
			continue;
					
		if(ska_get_user_id(idx) == id)
			return idx;
	}
	return 0;
}
public Set_Permissions(id){
	new Flags;
	Flags = read_flags(Admin_Permissions[s_AdminLevel[id]][1]);
	set_user_flags(id, Flags);
}
public plugin_end()
{
  ArrayDestroy(g_Admins);
  ArrayDestroy(g_Products);
  SQL_FreeHandle(g_SqlTuple);
}
