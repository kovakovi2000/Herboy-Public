#include <amxmodx>
#include <amxmisc>
#include <hamsandwich>
#include <cstrike>
#include <colorchat>
#include <engine>
#include <fun>
#include <sqlx>
#include <fakemeta>
#include <dollar>
#include <shedi_reg_system>


#pragma semicolon 1

new const PLUGIN[] = "[Sex~ +18] Kb Másolata";
new const VERSION[] = "1.0";
new const AUTHOR[] = "exodus"; //Ne írd át köszi.

//-------------------------------------------------------------------------------------------------------
//Beállítások
//-------------------------------------------------------------------------------------------------------

new const Prefix[] = "[.:*[DanGeR]*:.] OnlyDust2 By: Shediboii"; //Menüben megjelenő prefix
new const C_Prefix[] = "^1[^3.:*^4[^3DanGeR^4]^3*:.^1]"; //Chat Prefix

new const Website[] = "TSIP: Nincs"; //Menükben megjelenő elérhetőség

new const SQLINFO[][] =
{
"db.freedom-cs16.tk",
"szerver",
"freedomGame2019A",
"Perfect"
};
new const Elerhetoseg[] = "TeamSpeak: ts3.perfectcs.ml";

#define VIPIDO 24

#define File "addons/amxmodx/configs/musiclist.ini"
#define FEGYO 119 //Fegyverek száma
#define LADA 6 //Ládák száma

new const Float:Ritkasag[][] = { 1.0 }; //kés drop esélye
new const LadaNevek[][] = {
"Fegyver Láda 1",
"Fegyver Láda 2",
"Ezüst Láda",
"Arany Láda",
"Gyémánt Láda",
"Prémium Láda"
};
//--
//-------------------------------------------------------------------------------------------------------
//Tömbök
//-------------------------------------------------------------------------------------------------------

//ó¡jdolgok
new Top[4][15], TopNev[4][15][32], TopRang[15], Evente, Mod, dSync, bSync;
new HudString1[512];
new HudString2[512];
//Fragverseny
new fragverseny[33];
new hs[33], hl[33];
new gWPCT, g_korkezdes;
new gWPTE;
new g_QuestHead[33], g_Quest[33], g_QuestKills[2][33], g_ASD[33], SzinesHud[33], g_QuestWeapon[33], Buy[33], g_Jutalom[4][33], g_QuestMVP[33], HudOff[33], g_VipKupon[3][33], g_MVP[33], g_MVPoints[33], TopMvp;
//Kellékek
enum _:TEAMS {TE, CT};
new OsszesSkin[FEGYO][33], Lada[LADA][33], Kulcs[33], Dollar[33], Rang[33], Oles[33], Skin[5][33], Gun[33], DropOles[33], g_VipTime[33], g_PVipTime[33], g_Vip[33], Masodpercek[33];
new MusicData[40][3][64], Mp3File[96], MusicNum, PreviousMusic = -1, bool:Off[33], MaxFileLine;
new g_Awps[TEAMS], Send[33], TempID, g_Maxplayers;
new g_Chat_Prefix[32][33], VanPrefix[33], perfectpont[33];
new g_StartTime[33], g_EndTime[32], Fkill[33], bool:SwitchFrag, bool:FirstTask, x_tempid;
//Piac
new Erteke[33], kicucc[33], kirakva[33], pido;

//Mentés
new name[32][33], maxkor, g_Admin_Level[33];
new Handle:g_SqlTuple;
const KEYSMENU = MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6|MENU_KEY_7|MENU_KEY_8|MENU_KEY_9|MENU_KEY_0;
//-----------------------------------------------------------------------------------------------------
new Temp[192];
static color[10];

enum _:Rangs { Szint[32], Xp[8] };

new Array:g_Admins;
//-------------------------------------------------------------------------------------------------------

enum _:AdminData{
Id,
Name[32],
Permission
}
new const Admin_Permissions[][][] = {
//Rang név | Jogok | Hozzáadhat-e admint? (0-Nem | 1-Igen)| Hozzáadhat-e VIP-t? (0-Nem | 1-Igen)
{"Játékos", "z", "0", "0"}, //Játékos - 0
{"Konfigos", "abcvnmlpoikujzhtgrfedwsayc", "1", "1"}, //Tulajdonos - 4
{"Tulajdonos", "abcvnmlpoikujzhtgrfedwsayc", "1", "1"}, //Tulajdonos - 4
{"FőAdmin", "bmcfscdtiue", "4", "1"}, //FőAdmin - 3
{"Admin", "bmcfscdtiue", "0", "0"} //Admin - 2

};

new const Fegyverek[FEGYO][] =
{
{ "Anubis | AK47" },
{ "Aquamarine | AK47" },
{ "Astronaut | AK47" },
{ "Black and Green | AK47" },
{ "Bloodsport | AK47" },
{ "Blue Line | AK47" },
{ "BooM | AK47" },
{ "Cyrex | AK47" },
{ "Demolition | AK47" },
{ "Dragon Lore | AK47" },
{ "Elite Build | AK47" },
{ "Misty | AK47" },
{ "Peacock | AK47" },
{ "Gold | AK47" },
{ "Graffity | AK47" },
{ "Horas | AK47" },
{ "Illusion | AK47" },
{ "Jaguar | AK47" },
{ "Marihuana | AK47" },
{ "Revolution | AK47" },
{ "Orion | AK47" },
{ "Propaganda | AK47" },
{ "Redline | AK47" },
{ "Skull | AK47" },
{ "Alliance | M4A1" },
{ "Chaos | M4A1" },
{ "Blood | M4A1" },
{ "Imitation | M4A1" },
{ "Chantigos Fire | M4A1" },
{ "CooL | M4A1" },
{ "Cyrex | M4A1" },
{ "Dragon | M4A1" },
{ "Fade | M4A1" },
{ "Hellfire | M4A1" },
{ "Hyper Beast | M4A1" },
{ "Icarus | M4A1" },
{ "Industrya | M4A1" },
{ "Kendall | M4A1" },
{ "Kite | M4A1" },
{ "Nuclear | M4A1" },
{ "Poseidon | M4A1" },
{ "Tron | M4A1" },
{ "Ultimate | M4A1" },
{ "Spiritual | M4A1" },
{ "Fire M4A1" },
{ "Wandal | M4A1" },
{ "WildStyle | M4A1" },
{ "Equalizer | M4A1" },
{ "Mechanikus | M4A1" },
{ "Aranytekercs | AWP" },
{ "Babylon | AWP" },
{ "Boom | AWP" },
{ "Captain Strike | AWP" },
{ "Comic | AWP" },
{ "De Jackal | AWP" },
{ "Death | AWP" },
{ "Deimos | AWP" },
{ "Disco Party | AWP" },
{ "Dragon Lore | AWP" },
{ "Electic Hive | AWP" },
{ "Glasgow | AWP" },
{ "Bacteria | AWP" },
{ "Ice Palm | AWP" },
{ "Leviathan Kiss | AWP" },
{ "Machine | AWP" },
{ "Medusa | AWP" },
{ "Paw | AWP" },
{ "Plasmax | AWP" },
{ "Primal | AWP" },
{ "RedLine | AWP" },
{ "Ronin | AWP" },
{ "Tiger | AWP" },
{ "Virus | AWP" },
{ "Unicorn | AWP" },
{ "Back | DEAGLE" },
{ "Black and Red | DEAGLE" },
{ "Countrains | DEAGLE" },
{ "Disruption | DEAGLE" },
{ "Color | DEAGLE" },
{ "Cyberwanderer | DEAGLE" },
{ "Lightning | DEAGLE" },
{ "Blaze | DEAGLE" },
{ "Engraved | DEAGLE" },
{ "Dragon | DEAGLE" },
{ "Extreme | DEAGLE" },
{ "Flames | DEAGLE" },
{ "Frankenstein | DEAGLE" },
{ "Glorius | DEAGLE" },
{ "Glory | DEAGLE" },
{ "Graan | DEAGLE" },
{ "Hypnotic | DEAGLE" },
{ "Ice Dragon | DEAGLE" },
{ "Jupiters | DEAGLE" },
{ "Kumicho | DEAGLE" },
{ "Oakley | DEAGLE" },
{ "Orochi | DEAGLE" },
{ "Oxide | DEAGLE" },
{ "Plasmax | DEAGLE" },
{ "Standard | DEAGLE" },
{ "Assimov | Kés" },
{ "Bayonet Autotronic | Kés" },
{ "Bayonet Forest | Kés" },
{ "Bayonet Noel | Kés" },
{ "Ultra Gaming | Kés" },
{ "Blood | Kés" },
{ "Butterfly Doppler |Kés" },
{ "ComouFlage | Kés" },
{ "CrAcKeR | Kés" },
{ "Flachion Web | Kés" },
{ "Flachion Slaughter | Kés" },
{ "Flip Fade | Kés" },
{ "Huntsman Crimson | Kés" },
{ "Huntsman Hardened | Kés" },
{ "Huntsman Doppler | Kés" },
{ "Huntsman Forest | Kés" },
{ "Karambit White | Kés" },
{ "Karambit Blaze | Kés" },
{ "Umbrella Corp | Kés" },
{ "Yellow | Kés" }
};
new const m_AK47[][] =
{
"models/p_d2/Alap/v_ak47.mdl",
"models/p_d2/ak47/Anubis.mdl",
"models/p_d2/ak47/Aquamarine_Revenge.mdl",
"models/p_d2/ak47/Astronaut.mdl",
"models/p_d2/ak47/Black_and_Green.mdl",
"models/p_d2/ak47/Bloodsport.mdl",
"models/p_d2/ak47/Blue_Lines.mdl",
"models/p_d2/ak47/BooM.mdl",
"models/p_d2/ak47/Cyrex.mdl",
"models/p_d2/ak47/Demolition_Derby.mdl",
"models/p_d2/ak47/Dragon_Lore.mdl",
"models/p_d2/ak47/Elite_Build.mdl",
"models/p_d2/ak47/frontside_misty.mdl",
"models/p_d2/ak47/Furious_Peacock.mdl",
"models/p_d2/ak47/Gold.mdl",
"models/p_d2/ak47/Graffiti.mdl",
"models/p_d2/ak47/Horas.mdl",
"models/p_d2/ak47/Illusion.mdl",
"models/p_d2/ak47/Jaguar.mdl",
"models/p_d2/ak47/MARIHUANA.mdl",
"models/p_d2/ak47/Neon_Revolution.mdl",
"models/p_d2/ak47/ORION.mdl",
"models/p_d2/ak47/Propaganda.mdl",
"models/p_d2/ak47/Redline.mdl",
"models/p_d2/ak47/Skull.mdl"
};
new const m_M4A1[][] =
{
"models/p_d2/Alap/v_m4a1.mdl",
"models/p_d2/m4a1/Alliance_v2.mdl",
"models/p_d2/m4a1/Aqua_Chaos.mdl",
"models/p_d2/m4a1/Blood.mdl",
"models/p_d2/m4a1/Blue_Force_Imitation.mdl",
"models/p_d2/m4a1/Chanticos_Fire.mdl",
"models/p_d2/m4a1/CooL.mdl",
"models/p_d2/m4a1/Cyrex.mdl",
"models/p_d2/m4a1/dragon.mdl",
"models/p_d2/m4a1/fade.mdl",
"models/p_d2/m4a1/Hellfire.mdl",
"models/p_d2/m4a1/Icarus_Fell.mdl",
"models/p_d2/m4a1/Industrya.mdl",
"models/p_d2/m4a1/Kendall.mdl",
"models/p_d2/m4a1/Kite.mdl",
"models/p_d2/m4a1/nuclear.mdl",
"models/p_d2/m4a1/Poseidon.mdl",
"models/p_d2/m4a1/Tron_v2.mdl",
"models/p_d2/m4a1/Ultimate.mdl",
"models/p_d2/m4a1/Spiritual.mdl",
"models/p_d2/m4a1/vandal.mdl",
"models/p_d2/m4a1/WildStyle.mdl",
"models/p_d2/m4a1/Mortal_Equalizer.mdl",
"models/p_d2/m4a1/Mechanikus.mdl",
"models/p_d2/m4a1/Melanik_Abyssal.mdl",
"models/p_d2/m4a1/Neon_Line.mdl"
};
new const m_AWP[][] =
{
"models/p_d2/Alap/v_awp.mdl",
"models/p_d2/awp/Aranytekercs.mdl",
"models/p_d2/awp/Babylon.mdl",
"models/p_d2/awp/BOOM.mdl",
"models/p_d2/awp/Captain_Strike.mdl",
"models/p_d2/awp/comic.mdl",
"models/p_d2/awp/De_Jackal.mdl",
"models/p_d2/awp/Death.mdl",
"models/p_d2/awp/Deimos.mdl",
"models/p_d2/awp/Disco_Party.mdl",
"models/p_d2/awp/Dragon_Lore.mdl",
"models/p_d2/awp/Electic_Hive.mdl",
"models/p_d2/awp/Glasgow_Beast.mdl",
"models/p_d2/awp/Ice_Palm.mdl",
"models/p_d2/awp/Leviathan_Kiss.mdl",
"models/p_d2/awp/Lightning_strike.mdl",
"models/p_d2/awp/Machine.mdl",
"models/p_d2/awp/Medusa.mdl",
"models/p_d2/awp/PAW.mdl",
"models/p_d2/awp/Plasmax.mdl",
"models/p_d2/awp/Primal.mdl",
"models/p_d2/awp/RedLine.mdl",
"models/p_d2/awp/Ronin.mdl",
"models/p_d2/awp/Tiger.mdl",
"models/p_d2/awp/virus.mdl",
"models/p_d2/awp/Unicorn.mdl"
};
new const m_DEAGLE[][] =
{
"models/p_d2/Alap/v_deagle.mdl",
"models/p_d2/deagle/Bach.mdl",
"models/p_d2/deagle/Black_and_Red.mdl",
"models/p_d2/deagle/BlackCountrains.mdl",
"models/p_d2/deagle/Cobalt_Disruption.mdl",
"models/p_d2/deagle/CoLoR_DeAgLe.mdl",
"models/p_d2/deagle/Cyberwanderer_Black.mdl",
"models/p_d2/deagle/d1.mdl",
"models/p_d2/deagle/2.mdl",
"models/p_d2/deagle/d2.mdl",
"models/p_d2/deagle/Extreme.mdl",
"models/p_d2/deagle/Flames.mdl",
"models/p_d2/deagle/Frankenstein.mdl",
"models/p_d2/deagle/Glorius.mdl",
"models/p_d2/deagle/glory.mdl",
"models/p_d2/deagle/Gold.mdl",
"models/p_d2/deagle/Graan.mdl",
"models/p_d2/deagle/Hypnotic.mdl",
"models/p_d2/deagle/Ice_Dragon.mdl",
"models/p_d2/deagle/Jupiters_Mist.mdl",
"models/p_d2/deagle/Kumicho_Dragon.mdl",
"models/p_d2/deagle/OakleyDeagle.mdl",
"models/p_d2/deagle/Orochi.mdl",
"models/p_d2/deagle/Oxide_Blaze.mdl",
"models/p_d2/deagle/Plasmax.mdl",
"models/p_d2/deagle/Standard.mdl"
};
new const m_KNIFE[][] =
{
"models/p_d2/Alap/v_knife.mdl",
"models/p_d2/knife/Asiimov.mdl",
"models/p_d2/knife/BayonetAutotronic.mdl",
"models/p_d2/knife/Bayonet_Boreal_Forest.mdl",
"models/p_d2/knife/Bayonet_Noel.mdl",
"models/p_d2/knife/Ultra_Gaming.mdl",
"models/p_d2/knife/Blood_Knife.mdl",
"models/p_d2/knife/Butterfly_Knife_Doppler.mdl",
"models/p_d2/knife/Camouflage.mdl",
"models/p_d2/knife/CrAcKeR.mdl",
"models/p_d2/knife/Falchion_Knife_Crimson_Web.mdl",
"models/p_d2/knife/Falchion_Knife_Slaughter.mdl",
"models/p_d2/knife/Flip_Knife_Fade.mdl",
"models/p_d2/knife/Flip_Tiger_Tooth_V2.mdl",
"models/p_d2/knife/Huntsman_Knife_Crismon_Web.mdl",
"models/p_d2/knife/Huntsman_Knifen_Case_Hardened.mdl",
"models/p_d2/knife/Huntsman_Knifen_Doppler.mdl",
"models/p_d2/knife/Huntsman_Knifen_Forest_DDPAT.mdl",
"models/p_d2/knife/Karambit_Black_White.mdl",
"models/p_d2/knife/Karambit_Blaze.mdl",
"models/p_d2/knife/Umbrella_Corp.mdl"
};
new const Rangok[][Rangs] =
{
{ "Nem jó, de nem is tragikus", 30 },
{ "Összetört", 100 },
{ "Elismert", 250 },
{ "Láv mí", 500 },
{ "Gyatlov elvtárs", 700 },
{ "Paraszt", 850 },
{ "Szexcica", 1000 },
{ "Elbûvölõ szökevény", 2000 },
{ "Büdös", 3000 },
{ "Pornósztár", 4800 },
{ "Rendfenttartó‚", 8500 },
{ "Buzi", 9999 },
{ "Katona", 10500 },
{ "killer", 12000 },
{ "Ich bite", 14000 },
{ "Veszélyes", 16000 },
{ "Brutális", 18000 },
{ "Veterán", 2000000 },
{ "--------------", 0 }
};

new const Float:FegyverLada1_drops[][] =
{
{0.0, 4.0 },
{2.0, 1.0 },
{3.0, 14.0 },
{4.0, 3.0 },
{5.0, 18.0 },
{6.0, 20.0 },
{10.0, 4.0 },
{11.0, 12.0 },
{15.0, 3.0 },
{16.0, 10.0 },
{18.0, 14.0 },
{21.0, 18.0 },
{22.0, 10.0 },
{26.0, 16.0 },
{27.0, 20.0 },
{31.0, 20.0 },
{33.0, 10.0 },
{34.0, 16.0 },
{36.0, 4.0 },
{38.0, 20.0 },
{39.0, 2.0 },
{40.0, 10.0 },
{43.0, 3.0 },
{45.0, 4.0 },
{48.0, 16.0 },
{50.0, 14.0 },
{51.0, 12.0 },
{53.0, 18.0 },
{54.0, 1.0 },
{56.0, 14.0 },
{59.0, 20.0 },
{62.0, 18.0 },
{63.0, 12.0 },
{66.0, 3.0 },
{68.0, 16.0 },
{69.0, 14.0 },
{70.0, 10.0 },
{72.0, 2.0 },
{75.0, 16.0 },
{80.0, 14.0 },
{82.0, 16.0 },
{84.0, 1.0 },
{86.0, 18.0 },
{88.0, 12.0 },
{89.0, 4.0 },
{90.0, 14.0 },
{91.0, 1.0 },
{94.0, 10.0 },
{96.0, 18.0 }
};

new const Float:FegyverLada2_drops[][] =
{
{1.0, 1.0},
{7.0, 14.0},
{8.0, 3.0},
{9.0, 4.0},
{12.0, 2.0},
{13.0, 14.0},
{14.0, 18.0},
{17.0, 16.0},
{19.0, 10.0},
{20.0, 14.0},
{23.0, 20.0},
{24.0, 4.0},
{25.0, 10.0},
{28.0, 18.0},
{29.0, 20.0},
{30.0, 16.0},
{32.0, 3.0},
{35.0, 10.0},
{37.0, 20.0},
{41.0, 20.0},
{42.0, 18.0},
{44.0, 4.0},
{46.0, 2.0},
{47.0, 12.0},
{49.0, 1.0},
{52.0, 2.0},
{55.0, 3.0},
{57.0, 18.0},
{58.0, 1.0},
{60.0, 12.0},
{61.0, 16.0},
{64.0, 14.0},
{65.0, 10.0},
{67.0, 14.0},
{71.0, 16.0},
{73.0, 12.0},
{74.0, 10.0},
{76.0, 4.0},
{77.0, 14.0},
{78.0, 16.0},
{79.0, 3.0},
{81.0, 18.0},
{83.0, 20.0},
{85.0, 14.0},
{87.0, 16.0},
{92.0, 1.0},
{93.0, 4.0},
{95.0, 14.0},
{97.0, 12.0},
{98.0, 16.0}
};

new const Float:EzustLada_drops[][] =
{
{0.0, 4.0 },
{1.0, 1.0 },
{2.0, 1.0 },
{3.0, 7.0 },
{4.0, 3.0 },
{7.0, 7.0 },
{8.0, 3.0 },
{9.0, 4.0 },
{10.0, 4.0 },
{11.0, 6.0 },
{12.0, 2.0 },
{13.0, 7.0 },
{15.0, 3.0 },
{16.0, 5.0 },
{18.0, 7.0 },
{19.0, 5.0 },
{20.0, 7.0 },
{22.0, 5.0 },
{24.0, 4.0 },
{25.0, 5.0 },
{32.0, 3.0 },
{33.0, 5.0 },
{35.0, 5.0 },
{36.0, 4.0 },
{39.0, 2.0 },
{40.0, 5.0 },
{43.0, 3.0 },
{44.0, 4.0 },
{45.0, 4.0 },
{46.0, 2.0 },
{47.0, 6.0 },
{49.0, 1.0 },
{50.0, 7.0 },
{51.0, 6.0 },
{52.0, 2.0 },
{54.0, 1.0 },
{55.0, 3.0 },
{56.0, 7.0 },
{58.0, 1.0 },
{60.0, 6.0 },
{63.0, 6.0 },
{64.0, 7.0 },
{65.0, 5.0 },
{66.0, 3.0 },
{67.0, 7.0 },
{69.0, 7.0 },
{70.0, 5.0 },
{72.0, 2.0 },
{73.0, 6.0 },
{74.0, 5.0 },
{76.0, 4.0 },
{77.0, 7.0 },
{79.0, 3.0 },
{80.0, 7.0 },
{84.0, 1.0 },
{85.0, 7.0 },
{88.0, 6.0 },
{89.0, 4.0 },
{90.0, 7.0 },
{91.0, 1.0 },
{92.0, 1.0 },
{93.0, 4.0 },
{94.0, 5.0 },
{95.0, 7.0 },
{97.0, 6.0 },
//-----------------knifes
{99.0, 0.04 },
{100.0, 0.02 },
{101.0, 0.03 },
{102.0, 0.05 },
{103.0, 0.06 },
{104.0, 0.08 },
{105.0, 0.04 },
{106.0, 0.05 },
{107.0, 0.06 },
{108.0, 0.07 },
{109.0, 0.02 },
{110.0, 0.01 },
{111.0, 0.07 },
{112.0, 0.02 },
{113.0, 0.04 },
{114.0, 0.04 },
{115.0, 0.04 },
{116.0, 0.03 },
{117.0, 0.06 },
{118.0, 0.03 }
};

new const Float:AranyLada_drops[][] =
{
{0.0, 4.0 },
{1.0, 1.0 },
{2.0, 1.0 },
{4.0, 3.0 },
{8.0, 3.0 },
{9.0, 4.0 },
{10.0, 4.0 },
{11.0, 6.0 },
{12.0, 2.0 },
{15.0, 3.0 },
{16.0, 5.0 },
{19.0, 5.0 },
{22.0, 5.0 },
{24.0, 4.0 },
{25.0, 5.0 },
{32.0, 3.0 },
{33.0, 5.0 },
{35.0, 5.0 },
{36.0, 4.0 },
{39.0, 2.0 },
{40.0, 5.0 },
{43.0, 3.0 },
{44.0, 4.0 },
{45.0, 4.0 },
{46.0, 2.0 },
{47.0, 6.0 },
{49.0, 1.0 },
{51.0, 6.0 },
{52.0, 2.0 },
{54.0, 1.0 },
{55.0, 3.0 },
{58.0, 1.0 },
{60.0, 6.0 },
{63.0, 6.0 },
{65.0, 5.0 },
{66.0, 3.0 },
{70.0, 5.0 },
{72.0, 2.0 },
{73.0, 6.0 },
{74.0, 5.0 },
{76.0, 4.0 },
{79.0, 3.0 },
{84.0, 1.0 },
{88.0, 6.0 },
{89.0, 4.0 },
{91.0, 1.0 },
{92.0, 1.0 },
{93.0, 4.0 },
{94.0, 5.0 },
{97.0, 6.0 },
//-----------------knifes
{99.0, 0.05 },
{100.0, 0.03 },
{101.0, 0.04 },
{102.0, 0.06 },
{103.0, 0.07 },
{104.0, 0.09 },
{105.0, 0.05 },
{106.0, 0.06 },
{107.0, 0.07 },
{108.0, 0.08 },
{109.0, 0.03 },
{110.0, 0.02 },
{111.0, 0.08 },
{112.0, 0.03 },
{113.0, 0.05 },
{114.0, 0.05 },
{115.0, 0.05 },
{116.0, 0.04 },
{117.0, 0.07 },
{118.0, 0.04 }
};

new const Float:GyemantLada_drops[][] =
{
{0.0, 4.0 },
{1.0, 1.0 },
{2.0, 1.0 },
{4.0, 3.0 },
{8.0, 3.0 },
{9.0, 4.0 },
{10.0, 4.0 },
{12.0, 2.0 },
{15.0, 3.0 },
{16.0, 5.0 },
{19.0, 5.0 },
{22.0, 5.0 },
{24.0, 4.0 },
{25.0, 5.0 },
{32.0, 3.0 },
{33.0, 5.0 },
{35.0, 5.0 },
{36.0, 4.0 },
{39.0, 2.0 },
{40.0, 5.0 },
{43.0, 3.0 },
{44.0, 4.0 },
{45.0, 4.0 },
{46.0, 2.0 },
{49.0, 1.0 },
{52.0, 2.0 },
{54.0, 1.0 },
{55.0, 3.0 },
{58.0, 1.0 },
{65.0, 5.0 },
{66.0, 3.0 },
{70.0, 5.0 },
{72.0, 2.0 },
{74.0, 5.0 },
{76.0, 4.0 },
{79.0, 3.0 },
{84.0, 1.0 },
{89.0, 4.0 },
{91.0, 1.0 },
{92.0, 1.0 },
{93.0, 4.0 },
{94.0, 5.0 },
//-----------------knifes
{99.0, 0.06 },
{100.0, 0.04 },
{101.0, 0.05 },
{102.0, 0.07 },
{103.0, 0.08 },
{104.0, 0.1 },
{105.0, 0.06 },
{106.0, 0.07 },
{107.0, 0.08 },
{108.0, 0.09 },
{109.0, 0.04 },
{110.0, 0.03 },
{111.0, 0.09 },
{112.0, 0.04 },
{113.0, 0.06 },
{114.0, 0.06 },
{115.0, 0.06 },
{116.0, 0.05 },
{117.0, 0.08 },
{118.0, 0.05 }
};

new const Float:PremiumLada_drops[][] =
{
{0.0, 4.0 },
{1.0, 1.0 },
{2.0, 1.0 },
{4.0, 3.0 },
{8.0, 3.0 },
{9.0, 4.0 },
{10.0, 4.0 },
{12.0, 2.0 },
{15.0, 3.0 },
{24.0, 4.0 },
{32.0, 3.0 },
{36.0, 4.0 },
{39.0, 2.0 },
{43.0, 3.0 },
{44.0, 4.0 },
{45.0, 4.0 },
{46.0, 2.0 },
{49.0, 1.0 },
{52.0, 2.0 },
{54.0, 1.0 },
{55.0, 3.0 },
{58.0, 1.0 },
{66.0, 3.0 },
{72.0, 2.0 },
{76.0, 4.0 },
{79.0, 3.0 },
{84.0, 1.0 },
{89.0, 4.0 },
{91.0, 1.0 },
{92.0, 1.0 },
{93.0, 4.0 },
//-----------------knifes
{99.0, 0.08 },
{100.0, 0.06 },
{101.0, 0.07 },
{102.0, 0.09 },
{103.0, 0.10 },
{104.0, 0.12 },
{105.0, 0.08 },
{106.0, 0.09 },
{107.0, 0.10 },
{108.0, 0.11 },
{109.0, 0.06 },
{110.0, 0.05 },
{111.0, 0.11 },
{112.0, 0.06 },
{113.0, 0.08 },
{114.0, 0.08 },
{115.0, 0.08 },
{116.0, 0.07 },
{117.0, 0.10 },
{118.0, 0.07 }
};

public plugin_init() 
{
dSync = CreateHudSyncObj();
bSync = CreateHudSyncObj();
register_plugin(PLUGIN, VERSION, AUTHOR);

register_impulse(201, "Ellenorzes");
register_clcmd("say /rs", "reset_score");
register_clcmd("say /guns", "fegyvermenu");
register_clcmd("say /fegyo", "fegyvermenu");
register_clcmd("say /fegyver", "fegyvermenu");
register_clcmd("say /id", "CheckIdMenu");
register_clcmd("say /rangok", "Tagfelvetel");
register_clcmd("say /topdollar", "TopDollar");
register_clcmd("say /topoles", "TopOles");
register_clcmd("say /topido", "TopIdo");


register_concmd("bn_set_admin", "CmdSetAdmin", _, "<#id> <jog>");
register_concmd("bn_set_vip", "CmdSetVIP", _, "<#id> <ido>");
register_clcmd("DOLLAR", "lekeres");
register_clcmd("say", "Hook_Say");
register_clcmd("KMENNYISEG", "ObjectSend");
register_clcmd("KMENNYISEGSKIN", "ObjectSendSkin");
register_clcmd("Chat_Prefix", "Chat_Prefix_Hozzaad");

RegisterHam(Ham_Item_Deploy, "weapon_m4a1", "Change_Weapon", 1);
RegisterHam(Ham_Item_Deploy, "weapon_ak47", "Change_Weapon", 1);
RegisterHam(Ham_Item_Deploy, "weapon_awp", "Change_Weapon", 1);
RegisterHam(Ham_Item_Deploy, "weapon_deagle", "Change_Weapon", 1);
RegisterHam(Ham_Item_Deploy, "weapon_knife", "Change_Weapon", 1);

register_event("DeathMsg", "Halal", "a");
set_task(1.0, "AutoCheck",_,_,_,"b");
maxkor = register_cvar("maxkor", "50");

set_task(1.0, "LoadAdmins",_,_,_,"b");
RegisterHam(Ham_Spawn,"player","fegyvermenu", 1);
RegisterHam(Ham_Spawn,"player","nezzedazeventidot",1);
RegisterHam(Ham_Spawn,"player","Spawn",1);

RegisterHam(Ham_Spawn,"player","fraghud",1);
register_event("HLTV", "ujkor", "a", "1=0", "2=0");
register_event("HLTV", "mentes", "a", "1=0", "2=0");
register_event("TextMsg", "restart_round", "a", "2=#Game_will_restart_in");
register_logevent("RoundEnds", 2, "1=Round_End"),

register_logevent("PlayMusic", 2, "1=Round_End");
register_logevent("logevent_end", 2, "1=Round_End");
register_logevent("korvegiajandek", 2, "1=Round_End");
LoadMusic();
g_Maxplayers = get_maxplayers();
register_menu("Admin Info Menu", KEYSMENU, "Admin_Info_Menu_Handler");
}
public plugin_natives()
{
register_native("set_user_dollar","native_set_user_dollar",1);
register_native("get_user_dollar","native_get_user_dollar",1);

}
public ujkor()
{
LoadAdmins();
new id, count;
new p_playernum;
new sTime[9], sDate[11], sDateAndTime[32];

p_playernum = get_playersnum(1);
get_time("%H:%M:%S", sTime, 8 );
get_time("%Y/%m/%d", sDate, 11);
formatex(sDateAndTime, 31, "%s %s", sDate, sTime);

g_korkezdes += 1;

for(id = 1 ; id <= g_Maxplayers ; id++) 
if(is_user_connected(id)) 
if(get_user_flags(id) & ADMIN_KICK) 
count++;

client_print_color(0, print_team_default, "^4%s^3 Kör: ^4%d^1/^4%d ^1| ^3Játékosok: ^4%d^1/^4%d^1 | Idő: ^4%s ^1| ^3Jelenlévő Adminok: ^4%d^1", C_Prefix, g_korkezdes, get_pcvar_num(maxkor), p_playernum, g_Maxplayers, sDateAndTime, count); 

if(g_korkezdes >= get_pcvar_num(maxkor))
{
server_cmd("amx_map de_dust2");
}
}
public mentes(id){
if(dw_is_user_logged(id))
{
Update_User_Data(id);
}   
}

public restart_round()
{
g_korkezdes = 0;	
}
public native_get_user_dollar(index)
{
return Dollar[index];
}
public native_set_user_dollar(index,amount)
{
Dollar[index]=amount;
}
public korvegiajandek(id)
{
new Players[32], iNum;
new tt_num = 0;
new ct_num = 0;
get_players(Players, iNum, "ch");
for(new i=0;i<iNum;i++)
{
if(cs_get_user_team(Players[i])==CS_TEAM_T) 
{tt_num++;}
else if(cs_get_user_team(Players[i])==CS_TEAM_CT) 
{ct_num++;}
}
iNum = tt_num + ct_num;
new randomkulcs, randomperfect, randomdollar;
new Nyertesek[6][32];
new NyertertesCount;
new NyertesekID[6];
randomkulcs = random_num(0,2);
randomperfect = random_num(1,4);
randomdollar = random_num(1,15);
new Float:present;
new Nev[32];
present = ((iNum / 100.0) * 20.0);
for (new i; i < floatround(present); i++)
{
new iRandom = Players[ random_num(0,iNum) ];
get_user_name(iRandom, Nev, 31);
new bool:contains = false;
for(new Index; Index < NyertertesCount; Index++)
{
if (contains == false && NyertesekID[Index] == iRandom)
contains = true;
}

if (is_user_connected(iRandom) && dw_is_user_logged(iRandom) && !contains && !(cs_get_user_team(iRandom)==CS_TEAM_SPECTATOR))
{
NyertertesCount++;
Nyertesek[i] = Nev;
NyertesekID[i] = iRandom;
Kulcs[iRandom] += randomkulcs;
perfectpont[iRandom] +=randomperfect;
Dollar[iRandom] += randomdollar;
}
else
{
i--;
}
}
if (iNum < 3)
ColorChat(0, GREEN, "^4%s ^1Ajándék: Nem kapott senki ajándékot, mert nincs elég játékos!", C_Prefix);
else
{
ColorChat(0, GREEN, "^4%s ^1Ajándékok: ^4Kulcs:%i, Perfectpont:%i, Dollar:%i", C_Prefix, randomkulcs, randomperfect, randomdollar);
if(NyertertesCount == 1) ColorChat(0, GREEN, "^4%s Nyertes: ^4%s", C_Prefix, Nyertesek[0]);
else if(NyertertesCount == 2) ColorChat(0, GREEN, "^4%s Nyertesek: ^4%s^1,^4%s^1", C_Prefix, Nyertesek[0], Nyertesek[1]);
else if(NyertertesCount == 3) ColorChat(0, GREEN, "^4%s Nyertesek: ^4%s^1,^4%s^1,^4%s^1", C_Prefix, Nyertesek[0], Nyertesek[1], Nyertesek[2]);
else if(NyertertesCount == 4) ColorChat(0, GREEN, "^4%s Nyertesek: ^4%s^1,^4%s^1,^4%s^1,^4%s^1", C_Prefix, Nyertesek[0], Nyertesek[1], Nyertesek[2], Nyertesek[3]);
else if(NyertertesCount == 5) ColorChat(0, GREEN, "^4%s Nyertesek: ^4%s^1,^4%s^1,^4%s^1,^4%s^1,^4%s^1", C_Prefix, Nyertesek[0], Nyertesek[1], Nyertesek[2], Nyertesek[3], Nyertesek[4]);
else if(NyertertesCount == 6) ColorChat(0, GREEN, "^4%s Nyertesek: ^4%s^1,^4%s^1,^4%s^1,^4%s^1,^4%s^1,^4%s^1", C_Prefix, Nyertesek[0], Nyertesek[1], Nyertesek[2], Nyertesek[3], Nyertesek[4], Nyertesek[5]);
}
}
public SzerencseMenu(id)
{	
new cim[121], String[121];
format(cim, charsmax(cim), "[%s]^n\yMVP Pont: \d%d", Prefix, g_MVP[id]);
new menu = menu_create(cim, "SzerencseMenu_h");

menu_additem(menu, "Pörgetés", "1", 0);
menu_additem(menu, "1 Pörgetés 10 MVP Pont", "2", 0);

menu_display(id, menu, 0);
}
public SzerencseMenu_h(id, menu, item){
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
	if(g_MVP[id] >= 10)
	{
		g_MVP[id] -=10;
		RandomCucc(id);
	}
	else
	{
		openQuestMenu(id);
	}
}
case 2: SzerencseMenu(id);
}
}
public RandomCucc(id) {

switch(random_num(1, 9)) {
	case 1: {
		new Num;
		Num = random_num(10, 300);
		Dollar[id] += Num;
		client_print_color(0, print_team_default, "^3%s^4 %s^1 Pörgetett, nyert ^4%d^1 Dollárt! ^3Gratulálunk!", C_Prefix, name[id], Num);
	}
	case 2: {
		new Num;
		Num = random_num(10, 100);
		perfectpont[id] += Num;
		client_print_color(0, print_team_default, "^3%s^4 %s^1 Pörgetett, nyert ^4%d^1 PerFecT Pontot! ^3Gratulálunk!", C_Prefix, name[id], Num);
	}
	case 3: {
		new Num;
		Num = random_num(10, 100);
		Dollar[id] -= Num;
		client_print_color(0, print_team_default, "^3%s^4 %s^1 Pörgetett, vesztett ^4%d^1 Dollárt! ^3Sajnáljuk!", C_Prefix, name[id], Num);
	}
	case 4: {
		new Num;
		Num = random_num(10, 50);
		perfectpont[id] -= Num;
		client_print_color(0, print_team_default, "^3%s^4 %s^1 Pörgetett, vesztett ^4%d^1 PerFecT Pontot! ^3Sajnáljuk!", C_Prefix, name[id], Num);
	}
	case 5: {
		new Num;
		Num = random_num(10, 300);
		Dollar[id] += Num;
		client_print_color(0, print_team_default, "^3%s^4 %s^1 Pörgetett, nyert ^4%d^1 Dollárt! ^3Gratulálunk!", C_Prefix, name[id], Num);
	}
	case 6: {
		new Num;
		Num = random_num(10, 100);
		perfectpont[id] += Num;
		client_print_color(0, print_team_default, "^3%s^4 %s^1 Pörgetett, nyert ^4%d^1 PerFecT Pontot! ^3Gratulálunk!", C_Prefix, name[id], Num);
	}
	case 7: {
		client_print_color(0, print_team_default, "^3%s^4 %s^1 Pörgetett, nem kapott semmit! ^3Sajnáljuk!", C_Prefix, name[id]);
	}
	case 8: {
		client_print_color(0, print_team_default, "^3%s^4 %s^1 Pörgetett, nem kapott semmit! ^3Sajnáljuk!", C_Prefix, name[id]);
	}
	case 9: {
		client_print_color(0, print_team_default, "^3%s^4 %s^1 Pörgetett, nem kapott semmit! ^3Sajnáljuk!", C_Prefix, name[id]);
	}
}
return;
}
public nyerteselso(id)
{
new RandomCase = random_num(1, 7);
new RandomNumX = random_num(1, 7);
Kulcs[id] += RandomNumX;
Lada[RandomCase][id] += RandomNumX;
ColorChat(0, GREEN, "^4%s ^3%s ^1kapott ^4%d^1db ^3%s^1-t, és ^4%d^1db kulcsot az első helyezettre!", C_Prefix, name[id], RandomNumX, LadaNevek[RandomCase], RandomNumX);
}
public nyertesmasodik(id)
{
new RandomCase = random_num(1, 5);
new RandomNumX = random_num(1, 5);
Kulcs[id] += RandomNumX;
Lada[RandomCase][id] += RandomNumX;
ColorChat(0, GREEN, "^4%s ^3%s ^1kapott ^4%d^1db ^3%s^1-t, és ^4%d^1db kulcsot az második helyezettre!", C_Prefix, name[id], RandomNumX);
}
public nyertesharmadik(id)
{
new RandomNumPerfect = random_num(1, 200);
new RandomNumDollar = random_num(1, 300);
perfectpont[id] += RandomNumPerfect;
Dollar[id] += RandomNumDollar;
ColorChat(0, GREEN, "^4%s ^3%s ^1kapott ^4%d^1 dollárt, és ^4%d^1 perfect pontot, a harmadik helyezettre!", C_Prefix, name[id], RandomNumDollar, RandomNumPerfect);
}
public Tagfelvetel(id)
{
new String[121];
formatex(String, charsmax(String), "[%s] \r- \dű", Prefix);
new menu = menu_create(String, "Fomenu_h");

menu_additem(menu, "\yNem jó‚, de nem tragikus \y\w30 Ölés\y", "7", 0);
menu_additem(menu, "\yÖsszetört \y\w100 Ölés\y", "7", 0);
menu_additem(menu, "\yElismert \y\w250 Ölés\y", "7", 0);
menu_additem(menu, "\yLáv mí \y\w500 Ölés\y", "7", 0);
menu_additem(menu, "\yGyatlov Elvtárs \y\w700 Ölés\y", "7", 0);
menu_additem(menu, "\yParaszt \y\w850 Ölés\y", "7", 0);
menu_additem(menu, "\ySzexcica \y\w1000 Ölés\y", "7", 0);
menu_additem(menu, "\yElbűvölő Szökevény \y\w2000 Ölés\y", "7", 0);
menu_additem(menu, "\yBüdös \y\w3000Ölés\y", "7", 0);
menu_additem(menu, "\yPornó‚sztár \y\w4800 Ölés\y", "7", 0);
menu_additem(menu, "\yRendfenttartó‚ \y\w8500 Ölés\y", "7", 0);
menu_additem(menu, "\yBuzi \y\w9999 Ölés\y", "7", 0);
menu_additem(menu, "\yKatona \y\w10500 Ölés\y", "7", 0);
menu_additem(menu, "\ykiller \y\w12000 Ölés\y", "7", 0);
menu_additem(menu, "\yIch bite \y\w14000 Ölés\y", "7", 0);
menu_additem(menu, "\yVeszélyes \y\w16000 Ölés\y", "7", 0);
menu_additem(menu, "\yBrutális \y\w18000 Ölés\y", "7", 0);
menu_additem(menu, "\yVeterán \y\w2000000 Ölés\y", "7", 0);

menu_setprop(menu, MPROP_EXITNAME, "Kilépés");
menu_setprop(menu, MPROP_BACKNAME, "Vissza");
menu_setprop(menu, MPROP_NEXTNAME, "Tovább");

menu_display(id, menu, 0);
return PLUGIN_HANDLED;
}
public logevent_end()
{
gWPCT = 0;
gWPTE = 0;
}
public nezzedazeventidot(id){
vipCheck(id);
//PvipCheck(id);
Vipellenorzes(id);
}

public reset_score(id)
{
cs_set_user_deaths(id, 0);
set_user_frags(id, 0);
cs_set_user_deaths(id, 0);
set_user_frags(id, 0);

new name[33];
get_user_name(id, name, 32);
client_print_color(0, print_team_default, "%s Játékos: ^3%s^1 nullázta a statisztikáját.", C_Prefix, name);
}
public plugin_precache()
{
g_Admins = ArrayCreate(AdminData);
for(new i;i < sizeof(m_AK47); i++)
{
	precache_model(m_AK47[i]);
}
for(new i;i < sizeof(m_M4A1); i++)
{
	precache_model(m_M4A1[i]);
}
for(new i;i < sizeof(m_AWP); i++)
{
	precache_model(m_AWP[i]);
}
for(new i;i < sizeof(m_DEAGLE); i++)
{
	precache_model(m_DEAGLE[i]);
}
for(new i;i < sizeof(m_KNIFE); i++)
{
	precache_model(m_KNIFE[i]);
}

precache_sound("p2_hangok/kesnyitas.wav");

new Len, Line[196], Data[3][64], Download[40][64];
MaxFileLine = file_size(File, 1);
for(new Num = 0; Num < MaxFileLine; Num++)
{
	read_file(File, Num, Line, 196, Len);
	parse(Line, Data[0], 63, Data[1], 63, Data[2], 63);
	remove_quotes(Line);
	if(Line[0] == ';' || 2 > strlen(Line))
	{
		continue;
	}
	remove_quotes(Data[2]);
	format(Download[Num], 63, "%s", Data[2]);
	precache_sound(Download[Num]);
}
}
public LoadMusic()
{
new Len, Line[196], Data[3][64];
MaxFileLine = file_size(File, 1);
for(new Num; Num < MaxFileLine; Num++)
{
	MusicNum++;
	read_file(File, Num, Line, 196, Len);
	parse(Line, Data[0], 63, Data[1], 63, Data[2], 63);
	remove_quotes(Line);
	if(Line[0] == ';' || 2 > strlen(Line))
	{
		continue;
	}
	remove_quotes(Data[0]);
	remove_quotes(Data[1]);
	remove_quotes(Data[2]);
	format(MusicData[MusicNum][0], 63, "%s", Data[0]);
	format(MusicData[MusicNum][1], 63, "%s", Data[1]);
	format(MusicData[MusicNum][2], 63, "%s", Data[2]);
}
}
public PlayMusic() {
new Num = random_num(1, MusicNum);
if(MusicNum > 1)
{
	if(Num == PreviousMusic)
	{
		PlayMusic();
		return PLUGIN_HANDLED;
	}
}
formatex(Mp3File, charsmax(Mp3File), "sound/%s", MusicData[Num][2]);
new Players[32], PlayersNum, id;
get_players(Players, PlayersNum, "c");
for(new i; i < PlayersNum; i++)
{
	id = Players[i];
	if(Off[id])
	{
		continue;
	}
	client_cmd(id, "mp3 play %s", Mp3File);
	if(strlen(MusicData[Num][0]) > 3 && strlen(MusicData[Num][1]) > 3)
	{
		ColorChat(id, GREEN, "%s^1Zene:^3 %s^1 - ^3%s", C_Prefix, MusicData[Num][0], MusicData[Num][1]);
	}
	else
	{
		ColorChat(id, GREEN, "%s^1Zene:^3 Ismeretlen", C_Prefix);
	}
}
PreviousMusic = Num;
return PLUGIN_HANDLED;
}

/*
public FegyverValtas(id)
{
new fgy = get_user_weapon(id);

for(new i;i < sizeof(m_AK47); i++)
{
	if(Skin[0][id] == i && fgy == CSW_AK47 && Gun[id] == 1)
	{
		set_pev(id, pev_viewmodel2, m_AK47[i]);
	}
}
for(new i;i < sizeof(m_M4A1); i++)
{
	if(Skin[1][id] == i && fgy == CSW_M4A1 && Gun[id] == 1)
	{
		set_pev(id, pev_viewmodel2, m_M4A1[i]);
	}
}
for(new i;i < sizeof(m_AWP); i++)
{
	if(Skin[2][id] == i && fgy == CSW_AWP && Gun[id] == 1)
	{
		set_pev(id, pev_viewmodel2, m_AWP[i]);
	}
}
for(new i;i < sizeof(m_DEAGLE); i++)
{
	if(Skin[3][id] == i && fgy == CSW_DEAGLE && Gun[id] == 1)
	{
		set_pev(id, pev_viewmodel2, m_DEAGLE[i]);
	}
}
for(new i;i < sizeof(m_KNIFE); i++)
{
	if(Skin[4][id] == i && fgy == CSW_KNIFE && Gun[id] == 1)
	{
		set_pev(id, pev_viewmodel2, m_KNIFE[i]);
	}
}
}
*/
public Change_Weapon(iEnt)
{
if(!pev_valid(iEnt))
	return;
	
	new id = get_pdata_cbase(iEnt, 41, 4);
	
	if(!pev_valid(id))
		return;
	
	if(!Gun[id])
		return;
	
	new iWeapon = cs_get_weapon_id(iEnt);
	new iSize;
	
	switch(iWeapon){
		case CSW_AK47:
		{
			iSize = sizeof(m_AK47);
			
			for(new i; i < iSize; i++)
			{
				if(Skin[0][id] == i)
					entity_set_string(id, EV_SZ_viewmodel,  m_AK47[i]);
			}
		}
		case CSW_M4A1:
		{
			iSize = sizeof(m_M4A1);
			for(new i;i < iSize; i++)
			{
				if(Skin[1][id] == i)
					entity_set_string(id, EV_SZ_viewmodel,  m_M4A1[i]);
			}
		}
		case CSW_AWP:
		{
			iSize = sizeof(m_AWP);
			for(new i;i < iSize; i++)
			{
				if(Skin[2][id] == i)
					entity_set_string(id, EV_SZ_viewmodel,  m_AWP[i]);
			}
		}
		case CSW_DEAGLE:
		{
			iSize = sizeof(m_DEAGLE);
			for(new i;i < iSize; i++)
			{
				if(Skin[3][id] == i)
					entity_set_string(id, EV_SZ_viewmodel,  m_DEAGLE[i]);	
			}
		}
		case CSW_KNIFE:
		{
			iSize  = sizeof(m_KNIFE);
			for(new i;i < iSize; i++)
			{
				if(Skin[4][id] == i)
					entity_set_string(id, EV_SZ_viewmodel,  m_KNIFE[i]);
			}
		}
	}
}

public AutoCheck()
{
	new p[32],n;
	get_players(p,n,"ch");
	for(new i=0;i<n;i++)
	{
		new id = p[i];
	{
		dHud(id);
	}
}
}
public dHud(id) {
new m_Index;

if(is_user_alive(id))
	m_Index = id;
	else
		m_Index = entity_get_int(id, EV_INT_iuser2);
	
	if (!dw_is_user_logged(m_Index))
		return;
	
	if(HudOff[id] == 0)
	{
		new i_Seconds, i_Minutes, i_Hours, i_Days;
		i_Seconds = Masodpercek[m_Index] + get_user_time(m_Index);
		i_Minutes = i_Seconds / 60;
		i_Hours = i_Minutes / 60;
		i_Seconds = i_Seconds - i_Minutes * 60;
		i_Minutes = i_Minutes - i_Hours * 60;
		i_Days = i_Hours / 24;
		i_Hours = i_Hours - (i_Days * 24);
		
		new iLen, iLen2;
		iLen += formatex(HudString1[iLen], 512,"Név: ^n^n");
		iLen2 += formatex(HudString2[iLen2], 512,"       %s(#%i)^n^n", name[m_Index], dw_get_user_id(m_Index));
		
		iLen += formatex(HudString1[iLen], 512,"Dollár: ^n");
		iLen2 += formatex(HudString2[iLen2], 512,"          %i$^n", Dollar[m_Index]);
		
		iLen += formatex(HudString1[iLen], 512,"Egyenleg: ^n");
		iLen2 += formatex(HudString2[iLen2], 512,"               0 HUF^n");
		
		iLen += formatex(HudString1[iLen], 512,"Ölés: ^n");
		iLen2 += formatex(HudString2[iLen2], 512,"        %i^n", Oles[m_Index]);
		
		iLen += formatex(HudString1[iLen], 512,"Fejlövés: ^n");
		iLen2 += formatex(HudString2[iLen2], 512,"              %i^n", hs[m_Index]);
		
		iLen += formatex(HudString1[iLen], 512,"Halál: ^n");
		iLen2 += formatex(HudString2[iLen2], 512,"         %i^n", hl[m_Index]);
		
		iLen += formatex(HudString1[iLen], 512,"Játsz.Idő: ");
		iLen2 += formatex(HudString2[iLen2], 512,"               %i Nap %i Óra %i Perc", i_Days, i_Hours, i_Minutes);
		
		
		
		set_hudmessage(255, 255, 255, 0.01, 0.15, 0, 6.0, 1.1, 0.0, 0.0, 1.7);
		
		ShowSyncHudMsg(id, dSync, HudString1);
		
		set_hudmessage(0, 255, 0, 0.01, 0.15, 0, 6.0, 1.1, 0.0, 0.0, 1.7);
		ShowSyncHudMsg(id, bSync, HudString2);
	}
}
public InfoHud(id)
{
	new Target = pev(id, pev_iuser1) == 4 ? pev(id, pev_iuser2) : id;
	
	if(is_user_alive(id)){
		new iMasodperc, iPerc, iOra, Nev[32], iVMasodperc, iNap;
		get_user_name(id, Nev, 31);
		iVMasodperc = g_VipTime[id] - get_user_time(id);
		iMasodperc = Masodpercek[id] + get_user_time(id);
		iPerc = iMasodperc / 60;
		iOra = iPerc / 60;
		iMasodperc = iMasodperc - iPerc * 60;
		iPerc = iPerc - iOra * 60;
		iNap = iOra / 24;
		iOra = iOra - (iNap * 24);
		
		set_hudmessage(255, 255, 255, 0.01, 0.15, 0, 6.0, 1.1, 0.0, 0.0, -1);
		show_hudmessage(id, "Köszöntelek a szerveren!^nNév: %s(#%i)!^n[ Dollár: %i$ ]^n[ PerFecT Pont: %i ]^n[ MVP: %i]^n[ Ölés: %i | HS: %i ]^n[ Halál: %i ]^n[ Játszott idő: %i Nap %i Óra %i Perc ]", name[id], dw_get_user_id(id), Dollar[id], perfectpont[id], g_MVP[id], Oles[id], hs[id], hl[id], iNap, iOra, iPerc);
	}
	else {
		if(!dw_is_user_logged(Target))
			return;
		
		new iMasodperc, iPerc, iOra, iNap, Nev[32], iVMasodperc;
		iVMasodperc = g_VipTime[Target] - get_user_time(Target);
		get_user_name(Target, Nev, 31);
		iMasodperc = Masodpercek[Target] + get_user_time(Target); // + get_user_time(Target);
		iPerc = iMasodperc / 60;
		iOra = iPerc / 60;
		iMasodperc = iMasodperc - iPerc * 60;
		iPerc = iPerc - iOra * 60;
		iNap = iOra / 24;
		iOra = iOra - (iNap * 24);
		
		set_hudmessage(255, 255, 255, 0.01, 0.15, 0, 6.0, 1.1, 0.0, 0.0, -1);
		show_hudmessage(id, "Nézett játékos:^n%s(#%d)!^n^nÖlés: [%d]^nDollár: [%d]^nMVP Pont: [%d]^nRang: [%s]^nFejlövés: [%d]^nHalál: [%d]^nJátszott idő: [%d Nap %d Óra %d Perc]^nParancsok: [/rangok]", Nev, dw_get_user_id(Target), Oles[Target], Dollar[Target], g_MVP[Target], Rangok[Rang[Target]][Szint], hs[Target], hl[Target], iNap, iOra, iPerc);
	}
}
public fraghud(id)
{
	if(fragverseny[id] == 1){
		set_dhudmessage(random(256), random(256), random(256), -1.0, 0.20, 0, 6.0, 6.0);
		show_dhudmessage(id, "Jelenleg: Fragverseny van!^n%s-től, %s-ig.", g_StartTime, g_EndTime);
	}
}
public Halal()
{
	cmdTopByKills();
	cmdTopByMoney();
	cmdTopByTime();
	
	new killer = read_data(1);
	new aldozat = read_data(2);
	
	if(read_data(3))
		hs[killer]++;
	if(read_data(2))
		hl[aldozat]++;
	
	if(killer == aldozat)
	{
		return PLUGIN_HANDLED;
	}
	
	
	if(g_Vip[killer] >= 1)
	{
		switch(random_num(1,2))
		{
			case 1:
			{
				new Num = random_num(0, 10);
				DropOles[killer]++;
				g_MVPoints[killer]++;
				Oles[killer]++;
				Dollar[killer] += Num;
				ColorChat(killer, GREEN, "%s^1 Amiért megöltél egy ellenséget ezért jutalmat kapsz. ^3(^4 %d ^1Dollár^3)", C_Prefix, Num);
			}
			case 2:
			{
				new Num = random_num(0, 8);
				DropOles[killer]++;
				g_MVPoints[killer]++;
				Oles[killer]++;
				perfectpont[killer] += Num;
				ColorChat(killer, GREEN, "%s^1 Amiért megöltél egy ellenséget ezért jutalmat kapsz. ^3(^4 %d ^1PerFecT Pont^3)", C_Prefix, Num);
			}
		}
	}
	else
	{
		switch(random_num(1,2))
		{
			case 1:
			{
				new Num = random_num(0, 5);
				DropOles[killer]++;
				Oles[killer]++;
				Fkill[killer]++;
				g_MVPoints[killer]++;
				Dollar[killer] += Num;
				ColorChat(killer, GREEN, "%s^1 Amiért megöltél egy ellenséget ezért jutalmat kapsz. ^3(^4 %d ^1Dollár^3)", C_Prefix, Num);
			}
			case 2:
			{
				new Num = random_num(0, 4);
				DropOles[killer]++;
				g_MVPoints[killer]++;
				Oles[killer]++;
				Fkill[killer]++;
				perfectpont[killer] += Num;
				ColorChat(killer, GREEN, "%s^1 Amiért megöltél egy ellenséget ezért jutalmat kapsz. ^3(^4 %d ^1PerFecT Pont^3)", C_Prefix, Num);
			}
		}
	}
	
	while(Oles[killer] >= Rangok[Rang[killer]][Xp])
		Rang[killer]++;
	
	if(g_Quest[killer] == 1) Quest(killer);
	
	KillDrop(killer);
	return PLUGIN_HANDLED;
	
	if(!SwitchFrag) return PLUGIN_HANDLED;
	if(killer == aldozat || killer == 0)
		return PLUGIN_HANDLED;
}
public DropEllenorzes(id)
{
	new LadaID = random_num(1, LADA);
	
	if(DropOles[id] == 5)
	{
		Lada[LadaID][id]++;
		ColorChat(id, GREEN, "%s^1Találtál egy ^4%s^1-t.", C_Prefix, LadaNevek[LadaID][0]);
	}
	if(DropOles[id] == 7)
	{
		Kulcs[id]++;
		ColorChat(id, GREEN, "%s^1Találtál egy ^4Kulcs^1-t.", C_Prefix);
		DropOles[id] = 0;
	}
}
public KillDrop(id)
{
	const ChaseNumber = 7;
	new Float:DropChance[ChaseNumber]; 
	
	DropChance[0] = 5.0;
	DropChance[1] = 10.0;
	DropChance[2] = 10.0;
	DropChance[3] = 5.0;
	DropChance[4] = 4.0;
	DropChance[5] = 3.0;
	DropChance[6] = 1.0;
	new Float:NoDropChance = 71.0;
	
	new szName[32];
	get_user_name(id, szName, charsmax(szName));
	new Nev[32]; get_user_name(id, Nev, 31);
	
{
	new Float:DropChanceAdder[ChaseNumber];
	
	if (g_Vip[id]==1) //---------------------------VIPS----------------------//
	{
		for (new i = 0; i < ChaseNumber;i++)
		{
			DropChanceAdder[i] += DropChance[i] / 100.0 * 15.0;
		}
	}
	if (Evente == 1) //---------------------------Event_1----------------------//
	{
		for (new i = 1; i < ChaseNumber;i++)
		{
			if(i < 4)
				DropChanceAdder[i] += DropChance[i] / 100.0* 15.0;
				else
					DropChanceAdder[i] += DropChance[i] / 100.0 * 10.0;
			}
		}
		else if (Evente == 2) //---------------------------Event_2----------------------//
		{
			DropChanceAdder[0] += DropChance[0] / 100.0 * 15.0;
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
			ColorChat(0, GREEN, "^4%s ^3%s ^1Találta ezt: ^4%s^1 ( Esélye ennek:^4%.2f%s ^1)", C_Prefix, Nev, LadaNevek[i-1], (DropChance[i]/(OverallChance/100)), "%");
			i = ChaseNumber;
		}
		else if(ChanceOld < RandomNumber < ChanceNow && ChanceOld == 0.0)
		{
			Kulcs[id]++;
			ColorChat(0, GREEN, "^4%s ^3%s ^1Találta ezt: ^4Kulcs^1 ( Esélye ennek:^4%.2f%s ^1)", C_Prefix, Nev, (DropChance[i]/(OverallChance/100)), "%");
			i = ChaseNumber;
		}
	}
}
public Vipellenorzes(id)
{
	if(Masodpercek[id] >= VIPIDO*3600)
	{
		g_VipTime[id] = 86400*24;
	}
}
public vipCheck(id)
{
	if(g_VipTime[id] >= 10) VipRak(id);
	else g_Vip[id] = 0;
}
public VipRak(id)
{
	g_Vip[id] = 1;
	set_user_flags(id, ADMIN_LEVEL_H);
	//cs_set_user_vip(id, 1, 0, 1);
}
public openQuestMenu(id)
{
	new String[121];
	formatex(String, charsmax(String), "%s \r- \dKüldetések", Prefix);
	new menu = menu_create(String, "h_openQuestMenu");
	
	new const QuestWeapons[][] = { "AK47", "M4A1", "AWP", "DEAGLE", "FAMAS", "GALIL", "SCOUT", "Nincs" };
	new const QuestHeadKill[][] = { "Nincs", "Csak fejlövés" };
	
	formatex(String, charsmax(String), "\wFeladat: \yÖlj meg %d játékost \d[\yMég %d ölés\d]", g_QuestKills[0][id], g_QuestKills[0][id]-g_QuestKills[1][id]);
	menu_additem(menu, String, "0",0);
	formatex(String, charsmax(String), "\wÖlés Korlát: \y%s", QuestHeadKill[g_QuestHead[id]]);
	menu_additem(menu, String, "0",0);
	formatex(String, charsmax(String), "\wFegyver Korlát: \y%s \d[\rCsak ezzel a fegyverrel ölhetsz\d]^n", QuestWeapons[g_QuestWeapon[id]]);
	menu_additem(menu, String, "0",0);
	formatex(String, charsmax(String), "\wJutalom:^n\y- Dollár [%d $]^n- Láda [%d DB]^n- Kulcs [%d DB]^n- PerFecT Pont [%dP.]^n- Küldetés Pont [+1]^n", g_Jutalom[3][id], g_Jutalom[0][id], g_Jutalom[1][id], g_Jutalom[2][id]);
	menu_additem(menu, String, "0",0);
	formatex(String, charsmax(String), "\wKüldetés kihagyása \d[\r2000 PerFecT Pont\d]");
	menu_additem(menu, String, "1",0);
	
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
			case 1:
		{
			if(perfectpont[id] >= 2000)
			{
				g_QuestKills[1][id] = 0;
				g_QuestWeapon[id] = 0;
				g_Quest[id] = 0;
				perfectpont[id] -= 2000;
				ColorChat(id, GREEN, "%s ^1Kihagytad ezt a küldetést", C_Prefix);
			}
			else ColorChat(id, GREEN, "%s ^1Nincs elég PerFecT Pontod", C_Prefix);
		}
	}
}

public Quest(id)
{
	new HeadShot = read_data(3);
	new randomKeyAll = random_num(0,1);
	new randomCaseAll = random_num(0,1);
	new name[32]; get_user_name(id, name, charsmax(name));
	
	
	if(g_QuestHead[id] == 1 && (HeadShot))
	{
		if(g_QuestWeapon[id] == 7) g_QuestKills[1][id]++;
		else if(g_QuestWeapon[id] == 6 && get_user_weapon(id) == CSW_SCOUT) g_QuestKills[1][id]++;
			else if(g_QuestWeapon[id] == 5 && get_user_weapon(id) == CSW_GALIL) g_QuestKills[1][id]++;
			else if(g_QuestWeapon[id] == 4 && get_user_weapon(id) == CSW_FAMAS) g_QuestKills[1][id]++;
			else if(g_QuestWeapon[id] == 3 && get_user_weapon(id) == CSW_DEAGLE) g_QuestKills[1][id]++;
			else if(g_QuestWeapon[id] == 2 && get_user_weapon(id) == CSW_AWP) g_QuestKills[1][id]++;
			else if(g_QuestWeapon[id] == 1 && get_user_weapon(id) == CSW_M4A1) g_QuestKills[1][id]++;
			else if(g_QuestWeapon[id] == 0 && get_user_weapon(id) == CSW_AK47) g_QuestKills[1][id]++;
		}
	if(g_QuestHead[id] == 0)
	{
		if(g_QuestWeapon[id] == 7) g_QuestKills[1][id]++;
		else if(g_QuestWeapon[id] == 6 && get_user_weapon(id) == CSW_SCOUT) g_QuestKills[1][id]++;
			else if(g_QuestWeapon[id] == 5 && get_user_weapon(id) == CSW_GALIL) g_QuestKills[1][id]++;
			else if(g_QuestWeapon[id] == 4 && get_user_weapon(id) == CSW_FAMAS) g_QuestKills[1][id]++;
			else if(g_QuestWeapon[id] == 3 && get_user_weapon(id) == CSW_DEAGLE) g_QuestKills[1][id]++;
			else if(g_QuestWeapon[id] == 2 && get_user_weapon(id) == CSW_AWP) g_QuestKills[1][id]++;
			else if(g_QuestWeapon[id] == 1 && get_user_weapon(id) == CSW_M4A1) g_QuestKills[1][id]++;
			else if(g_QuestWeapon[id] == 0 && get_user_weapon(id) == CSW_AK47) g_QuestKills[1][id]++;
		}
	
	if(g_QuestKills[1][id] >= g_QuestKills[0][id])
	{
		Lada[randomCaseAll][id] += g_Jutalom[0][id];
		Kulcs[id] += g_Jutalom[1][id];
		perfectpont[id] += g_Jutalom[2][id];
		Dollar[id] += g_Jutalom[3][id];
		g_QuestKills[1][id] = 0;
		g_QuestWeapon[id] = 0;
		g_QuestMVP[id]++;
		g_Quest[id] = 0;
		ColorChat(id, GREEN, "%s ^1A küldetésre kapott jutalmakat megkaptad.", C_Prefix);
		ColorChat(0, GREEN, "^3[^4PerFecT^3]^3 »^4%s^3(%d)^1 befejezte a kiszabott küldetéseket. A jutalmakat megkapta", name[id], dw_get_user_id(id));
	}
}
public egyediprefixmenu(id){
	new String[121];
	if(VanPrefix[id] >= 1)
		format(String, charsmax(String), "[%s]^n\wHasználatban lévő Prefixed: \r%s", Prefix, g_Chat_Prefix[id]);
	else
		format(String, charsmax(String), "[%s]^n\wHasználatban lévő Prefixed: \rNincs", Prefix);
	new menu = menu_create(String, "h_Prefix");
	
	formatex(String, charsmax(String), "Prefix Hozzáadása \w[\y1000$/DB\w]^n^nEddigi prefixek: \r%d", VanPrefix[id]);
	menu_additem(menu, String, "1",0);
	
	menu_setprop(menu, MPROP_EXITNAME, "Kilépés");
	menu_setprop(menu, MPROP_BACKNAME, "Vissza");
	menu_setprop(menu, MPROP_NEXTNAME, "Tovább");
	
	menu_display(id, menu, 0);
}

public h_Prefix(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return;
	}
	new data[9], szName[64], Nev[32];
	get_user_name(id, Nev, 31);
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
	new key = str_to_num(data);
	
	switch(key){
		case 1:{
			if(Dollar[id] >= 1000)
				client_cmd(id, "messagemode Chat_Prefix");
			else
				client_printcolor(id, "%s Nincs elég Dollárod", C_Prefix);
		}		
	}
}
public Chat_Prefix_Hozzaad(id){
	new Data[32];
	read_args(Data, charsmax(Data));
	remove_quotes(Data);
	
	new hosszusag = strlen(Data);
	
	if(hosszusag <= 8 && hosszusag > 0){
		g_Chat_Prefix[id] = Data;
		VanPrefix[id]++;
		Dollar[id] -= 1000;
		client_print_color(id, print_team_default, "%s Vettél egy prefixet! Semmi csúnya, és adminhoz tartozó‚ dolgot ne írj!", C_Prefix);
	}
	else{
		client_print_color(id, print_team_default, "%s A Prefix legfeljebb ^38^1 karakterből állhat!", C_Prefix);
		egyediprefixmenu(id);
	}
	return PLUGIN_CONTINUE;
}
public Fomenu(id)
{	
	new cim[121], String[121];
	format(cim, charsmax(cim), "[%s]^n\yDollár: \d%d \r| \yPerFecT Pont: \d%d", Prefix, Dollar[id], perfectpont[id]);
	new menu = menu_create(cim, "Fomenu_h");
	
	menu_additem(menu, "Raktár", "1", 0);
	menu_additem(menu, "LádaNyitás", "2", 0);
	menu_additem(menu, "Piac", "3", 0);
	menu_additem(menu, "Beállítások", "4", 0);
	menu_additem(menu, "Almenü [Újítva*]", "5", 0);
	menu_additem(menu, "Egyedi Prefix Menü", "6", 0);
	if(g_Quest[id] == 0) format(String,charsmax(String),"Küldetések");
	else format(String,charsmax(String),"Küldetések \r[\yFolyamatban\d]");
	menu_additem(menu,String,"7");
	menu_additem(menu, "Lomtár ", "8", 0);
	menu_additem(menu, "Pörgetés +*10%", "9", 0);
	
	menu_display(id, menu, 0);
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
	new randomKills = random_num(5,50);
	new randomWeapon = random_num(0,7);
	new randomHead = random_num(0,1);
	new randomCase = random_num(0,2);
	new randomKey = random_num(0,4);
	new randomPremium = random_num(10,100);
	new randomDollar = random_num(3,500);
	
	switch(key)
	{
		case 1: Raktar(id);
			case 2: LadaNyitas(id);
			case 3: Piac(id);
			case 4: Beallitasok(id);
			case 5: VIPMenu(id);
			case 6: egyediprefixmenu(id);
			case 7: 
		{
			client_print_color(id, print_team_default, "%s^1 A küldetések menüpont fejlesztés alatt áll!", Prefix);
			client_print_color(id, print_team_default, "%s^1 Várható fejleszése: ^3Silver Küldetések, Gold és Arany küldetések^1!", Prefix);
		}
		case -1:
		{
			if(g_Quest[id] == 0)
			{
				g_QuestKills[0][id] = randomKills;
				g_QuestWeapon[id] = randomWeapon;
				g_QuestHead[id] = randomHead;
				g_Jutalom[0][id] = randomCase;
				g_Jutalom[1][id] = randomKey;
				g_Jutalom[2][id] = randomPremium;
				g_Jutalom[3][id] = randomDollar;
				g_Quest[id] = 1;
				openQuestMenu(id);
			}
			else
			{
				openQuestMenu(id);
			}
		}
		case 8:{
			
			if(kirakva[id] == 1)
			{
				ColorChat(id, GREEN, "[PerFecT]^3 »^1 Amíg piacon kint van egy tárgyad addig nem tudod a kukát használni!");
			}
			else if(kirakva[id] == 0)
			{
				Lomtar(id);
			}
		}
		case 9: SzerencseMenu(id);
		}
}
public PremiumPanel(id)
{
	new String[121];
	
	format(String, charsmax(String), "[%s]^n\Perfect Bolt", Prefix);
	new menu = menu_create(String, "h_PremiumPanel");
	
	menu_additem(menu, "Gyémánt láda vásárlása  \r[\d175 PerFecT Pont\r]", "1", 0);
	menu_additem(menu, "Prémium láda vásárlása  \r[\d300 PerFecT Pont\r]", "2", 0);
	menu_additem(menu, "Kulcs vásárlás  \r[\d50 PerFecT Pont\r]", "3", 0);
	
	menu_display(id, menu, 0);
	
}
public h_PremiumPanel(id, menu, item)
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
			if(perfectpont[id] >= 175)
			{
				perfectpont[id] -= 175;
				Lada[4][id] += 1;
				ColorChat(id, GREEN, "%s^1 Vettél egy^4 Gyémánt ládát", C_Prefix);
			}
			else
			{
				ColorChat(id, GREEN, "%s^1 Nincs elég PerFecT Pontod!", C_Prefix);
			}
			PremiumPanel(id);
		}
		case 2:
		{
			if(perfectpont[id] >= 300)
			{
				perfectpont[id] -= 300;
				Lada[5][id] += 1;
				ColorChat(id, GREEN, "%s^1 Vettél egy^4 Prémium ládát", C_Prefix);
			}
			else
			{
				ColorChat(id, GREEN, "%s^1 Nincs elég PerFecT Pontod!", C_Prefix);
			}
			PremiumPanel(id);
			
		}
		case 3:
		{
			if(perfectpont[id] >= 50)
			{
				perfectpont[id] -= 50;
				Kulcs[id] += 1;
				ColorChat(id, GREEN, "%s^1 Vettél egy^4 Kulcsot", C_Prefix);
			}
			else
			{
				ColorChat(id, GREEN, "%s^1 Nincs elég PerFecT Pontod!", C_Prefix);
			}
			PremiumPanel(id);
		}
		
	}
	return;
	
}
public m_Bolt(id)
{
	new String[121];
	
	format(String, charsmax(String), "[%s]^n\wVIP Vásárlás menü^nNyomj rá egy számra a vásárláshoz.", Prefix);
	new menu = menu_create(String, "h_Bolt");
	
	menu_additem(menu, "1 Napos VIP Vásárlás \r[\d600 PerFecT Pont\r]", "1", 0);
	menu_additem(menu, "3 Napos VIP Vásárlás \r[\d1800 PerFecT Pont\r]", "2", 0);
	menu_additem(menu, "7 Napos VIP Vásárlás \r[\d5600 PerFecT Pont\r]", "3", 0);
	
	menu_display(id, menu, 0);
}

public h_Bolt(id, menu, item){
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
			if(perfectpont[id] >= 600)
			{
				perfectpont[id] -= 600;
				g_VipTime[id] += 86400*1;
				ColorChat(id, GREEN, "%s^1 Vettél egy^4 1 Napra^1 szóló‚ ^3VIPet^1, a VIP menüben be is tudod aktiválni!", C_Prefix);
			}
			else
			{
				ColorChat(id, GREEN, "%s^1 Nincs elég PerFecT Pontod!", C_Prefix);
			}
			m_Bolt(id);
		}
		case 2:
		{
			if(perfectpont[id] >= 1800)
			{
				perfectpont[id] -= 1800;
				g_VipTime[id] += 86400*3;
				ColorChat(id, GREEN, "%s^1 Vettél egy^4 3 Napra^1 szóló‚ ^3VIPet^1, a VIP menüben be is tudod aktiválni!", C_Prefix);
			}
			else
			{
				ColorChat(id, GREEN, "%s^1 Nincs elég PerFecT Pontod!", C_Prefix);
			}
			m_Bolt(id);
		}
		case 3:
		{
			if(perfectpont[id] >= 5600)
			{
				perfectpont[id] -= 5600;
				g_VipTime[id] += 86400*7;
				ColorChat(id, GREEN, "%s^1 Vettél egy^4 7 Napra^1 szóló‚ ^3VIPet^1, a VIP menüben be is tudod aktiválni!", C_Prefix);
			}
			else
			{
				ColorChat(id, GREEN, "%s^1 Nincs elég PerFecT Pontod!", C_Prefix);
			}
			m_Bolt(id);
		}
	}
}
public ShowAdminsMenu(id) {
	new MenuTitle[121], cim[121], Menu, Sor[6], bArraySize = ArraySize(g_Admins), Data[AdminData];
	
	if(bArraySize < 1){
		client_printcolor(id, "%s Nincs egy admin adat sem betöltve! Pró‚báld meg újra később!", C_Prefix);
		return PLUGIN_HANDLED;
	}
	format( MenuTitle, charsmax( MenuTitle ), "\d[.:DNS:.] ~ \yOnly Dust2 \d|\w Admin Lista^n\wOldal:\r%s", bArraySize > 7 ? "" : " 1/1");
	
	Menu = menu_create( MenuTitle, "ShowAdminsMenuHandler");
	
	for(new i; i < bArraySize; i++){
		ArrayGetArray(g_Admins, i , Data);
		
		num_to_str(i, Sor, 5);
		formatex(cim, charsmax(cim), "\w%s \d(#%d)", Data[Name], Data[Id]);
		
		menu_additem(Menu, cim, Sor);
	}
	
	menu_setprop(Menu, MPROP_EXITNAME, "Kilépés");
	menu_setprop(Menu, MPROP_BACKNAME, "Vissza");
	menu_setprop(Menu, MPROP_NEXTNAME, "Tovább");
	menu_display(id, Menu, 0);
	return PLUGIN_HANDLED;
}

public ShowAdminsMenuHandler(id, Menu, item) {
	if(item == MENU_EXIT)
	{
		menu_destroy(Menu);
		return PLUGIN_HANDLED;
	}
	
	Admin_Info(id, item);
	
	return PLUGIN_HANDLED;
}

Admin_Info(id , i){
	new Menu[512], Len, Len2, Data[AdminData], Day, Hour, Minute, Second;
	
	ArrayGetArray(g_Admins, i, Data);
	
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\d[PerFecT] ~ \yOnly Dust2 \d|\w Admin Lista^n^n");
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\wNév: \r%s\d(#%d)^n", Data[Name], Data[Id]);
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\wJog: \r%s^n", Admin_Permissions[Data[Permission]][0]);
	
	Len += formatex(Menu[Len], charsmax(Menu) - Len, "^n\r0.\w Vissza az Admin Listához");
	
	set_pdata_int(id, 205, 0);
	show_menu(id, KEYSMENU, Menu, -1, "Admin Info Menu");
	
	return PLUGIN_HANDLED;
}

public Admin_Info_Menu_Handler(id, key){
	if(!is_user_connected(id))
		return PLUGIN_HANDLED;
	
	switch(key){
		default: ShowAdminsMenu(id);
	}
	
	return PLUGIN_HANDLED;
}
public LoadAdmins(){
	ArrayClear(g_Admins);
	static Query[10048];
	
	formatex(Query, charsmax(Query), "SELECT * FROM `servernew` WHERE `Admin_Level` > 0;");
	SQL_ThreadQuery(g_SqlTuple, "QuerySelectDataAdmins", Query);
}

public QuerySelectDataAdmins(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime) {
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) {
		log_amx("%s", Error);
		return;
	}
	else {
		new Data[AdminData];
		while(SQL_MoreResults(Query)){
			Data[Id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "User_Id"));
			SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Nev"), Data[Name], 31);
			Data[Permission] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Admin_Level"));
			ArrayPushArray(g_Admins, Data);
			
			SQL_NextRow(Query);
		}
	}
}
public CheckIdMenu(id) {
	new cim[121], Menu, Sor[6];
	Menu = menu_create("\dJátékos ID", "CheckIdMenuHandler");
	
	for(new i; i < g_Maxplayers; i++){
		if(!is_user_connected(i))
			continue;
		
		num_to_str(i, Sor, 5);
		
		if(dw_is_user_logged(i))
			formatex(cim, charsmax(cim), "\w%s \d(#%d)", name[i], dw_get_user_id(i));
		else
			formatex(cim, charsmax(cim), "\d%s \d(Nincs bejelentkezve (#0))", name[i]);
		
		menu_additem(Menu, cim, Sor);
	}
	
	menu_setprop(Menu, MPROP_EXITNAME, "Kilépés");
	menu_setprop(Menu, MPROP_BACKNAME, "Vissza");
	menu_setprop(Menu, MPROP_NEXTNAME, "Tovább");
	menu_display(id, Menu, 0);
	return PLUGIN_HANDLED;
}

public CheckIdMenuHandler(id, Menu, item) {
	if(item == MENU_EXIT)
	{
		menu_destroy(Menu);
		return PLUGIN_HANDLED;
	}
	
	return PLUGIN_HANDLED;
}
public VIPMenu(id)
{
	new cim[121];
	format(cim, charsmax(cim), "[%s]^n\yAlMenü / VIP Menü", Prefix);
	new menu = menu_create(cim, "Vipmenu_h");
	
	menu_additem(menu, "Játékos Azonosítok #?", "2", 0);
	menu_additem(menu, "Adminisztrátorok", "3", 0);
	menu_additem(menu, "VIP Vásárlás", "1", 0);
	menu_additem(menu, "TOP 15 ÖLÉS", "4", 0);
	menu_additem(menu, "TOP 15 DOLLÁR", "5", 0);
	menu_additem(menu, "TOP 15 JÁTSZOTTIDŐ", "6", 0);
	
	menu_display(id, menu, 0);
}
public Vipmenu_h(id, menu, item){
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
			case 1: m_Bolt(id);
			case 2: CheckIdMenu(id);
			case 3: ShowAdminsMenu(id);
			case 4: TopOles(id);
			case 5: TopDollar(id);
			case 6: TopIdo(id);
		}
}
public viplejarat(id)
{
	new iVMasodperc, iVPerc, iVOra, iVNap;
	iVMasodperc = g_VipTime[id] - get_user_time(id);
	iVPerc = iVMasodperc / 60;
	iVOra = iVPerc / 60;
	iVMasodperc = iVMasodperc - iVPerc * 60;
	iVPerc = iVPerc - iVOra * 60;
	
	client_print_color(id, print_team_default, "%s ^1Ennyi ideig van még VIP-ed: ^4%d^1 Óra, ^4%d^1 Perc, ^4%d^1 Másodperc", C_Prefix, iVOra, iVPerc, iVMasodperc);
}
public Beallitasok(id)
{
	new cim[121];
	format(cim, charsmax(cim), "[%s] \r- \dBeállítások", Prefix);
	new menu = menu_create(cim, "Beallitasok_h");
	
	menu_additem(menu, Gun[id] == 1 ? "Skin: \rBekapcsolva \y| Kikapcsolva":"Skin: \wBekapcsolva \y| \rKikapcsolva", "1",0);
	menu_additem(menu, !(HudOff[id] == 1) ? "HUD: \rBekapcsolva \y| Kikapcsolva":"HUD: \wBekapcsolva \y| \rKikapcsolva", "2",0);
	menu_additem(menu, Off[id] == 0 ? "Körvégi Zene: \rBekapcsolva \y| Kikapcsolva":"Körvégi Zene: \wBekapcsolva \y| \rKikapcsolva", "3",0);
	
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
			if(Gun[id] == 1)
			{
				Gun[id] = 0;
			}
			else 
			{
				Gun[id] = 1;
			}
			Beallitasok(id);
		}
		case 2: 
		{
			if(HudOff[id] == 1)
			{
				HudOff[id] = 0;
			}
			else 
			{
				HudOff[id] = 1;
			}
			Beallitasok(id);
		}
		case 3: 
		{
			if(Off[id] == 1)
			{
				Off[id] = 0;
			}
			else 
			{
				Off[id] = 1;
			}
			Beallitasok(id);
		}
	}
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
			new Sor[6]; num_to_str(i, Sor, 5);
			formatex(cim, charsmax(cim), "%s \d[\r%d \dDB]", Fegyverek[i][0], OsszesSkin[i][id]);
			menu_additem(menu, cim, Sor);
		}
	}
	menu_display(id, menu, 0);
}
public h_Lomtar(id, menu, item)
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
	new Num = random_num(0, 5);
	
	OsszesSkin[key][id] --;
	ColorChat(id, GREEN, "%s^1Sikeresen Törölted ezt: ^4%s ^1| ^3Kaptál: ^3%d^1$", C_Prefix, Fegyverek[key][0], Num);
	Lomtar(id);
}
public LadaNyitas(id)
{
	new cim[121], cim1[121], cim2[121], cim3[121], cim4[121], cim5[121];
	format(cim, charsmax(cim), "[%s] \r- \dLádaNyitás^n\wKulcs \d[\r%d \dDB]", Prefix, Kulcs[id]);
	new menu = menu_create(cim, "Lada_h");
	
	format(cim, charsmax(cim), "%s \d[\r%d \dDB]",LadaNevek[0][0], Lada[0][id]);
	menu_additem(menu, cim, "0", 0);
	format(cim1, charsmax(cim1), "%s \d[\r%d \dDB]",LadaNevek[1][0], Lada[1][id]);
	menu_additem(menu, cim1, "1", 0);
	format(cim2, charsmax(cim2), "%s \d[\r%d \dDB]",LadaNevek[2][0], Lada[2][id]);
	menu_additem(menu, cim2, "2", 0);
	format(cim3, charsmax(cim3), "%s \d[\r%d \dDB]",LadaNevek[3][0], Lada[3][id]);
	menu_additem(menu, cim3, "3", 0);
	format(cim4, charsmax(cim4), "%s \d[\r%d \dDB]",LadaNevek[4][0], Lada[4][id]);
	menu_additem(menu, cim4, "4", 0);
	format(cim5, charsmax(cim5), "%s \d[\r%d \dDB]",LadaNevek[5][0], Lada[5][id]);
	menu_additem(menu, cim5, "5", 0);
	
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
	
	if(Lada[key][id] >= 1 && Kulcs[id] >= 1)
	{
		Lada[key][id]--;
		Kulcs[id]--;
		Talal(id, key);
	}
	else
	{
		LadaNyitas(id);
		ColorChat(id, GREEN, "%s^1Nincs Ládát vagy Kulcsod.", C_Prefix);
	}
	LadaNyitas(id);
}
public Raktar(id)
{
	new cim[121];
	format(cim, charsmax(cim), "[%s] \r- \dRaktár^n\yDollár: \d%d", Prefix, Dollar[id]);
	new menu = menu_create(cim, "Raktar_h");
	
	for(new i;i < sizeof(Fegyverek); i++)
	{
		if(OsszesSkin[i][id] > 0)
		{
			new Sor[6]; num_to_str(i, Sor, 5);
			formatex(cim, charsmax(cim), "%s \d[\r%d \dDB]", Fegyverek[i][0], OsszesSkin[i][id]);
			menu_additem(menu, cim, Sor);
		}
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
	
	switch(key) 
	{
		case 0: Skin[0][id] = 1;
			case 1: Skin[0][id] = 2;
			case 2: Skin[0][id] = 3;
			case 3: Skin[0][id] = 4;
			case 4: Skin[0][id] = 5;
			case 5: Skin[0][id] = 6;
			case 6: Skin[0][id] = 7;
			case 7: Skin[0][id] = 8;
			case 8: Skin[0][id] = 9;
			case 9: Skin[0][id] = 10;
			case 10: Skin[0][id] = 11;
			case 11: Skin[0][id] = 12;
			case 12: Skin[0][id] = 13;
			case 13: Skin[0][id] = 14;
			case 14: Skin[0][id] = 15;
			case 15: Skin[0][id] = 16;
			case 16: Skin[0][id] = 17;
			case 17: Skin[0][id] = 18;
			case 18: Skin[0][id] = 19;
			case 19: Skin[0][id] = 20;
			case 20: Skin[0][id] = 21;
			case 21: Skin[0][id] = 22;
			case 22: Skin[0][id] = 23;
			case 23: Skin[0][id] = 24;
			case 24: Skin[1][id] = 1;
			case 25: Skin[1][id] = 2;
			case 26: Skin[1][id] = 3;
			case 27: Skin[1][id] = 4;
			case 28: Skin[1][id] = 5;
			case 29: Skin[1][id] = 6;
			case 30: Skin[1][id] = 7;
			case 31: Skin[1][id] = 8;
			case 32: Skin[1][id] = 9;
			case 33: Skin[1][id] = 10;
			case 34: Skin[1][id] = 11;
			case 35: Skin[1][id] = 12;
			case 36: Skin[1][id] = 13;
			case 37: Skin[1][id] = 14;
			case 38: Skin[1][id] = 15;
			case 39: Skin[1][id] = 16;
			case 40: Skin[1][id] = 17;
			case 41: Skin[1][id] = 18;
			case 42: Skin[1][id] = 19;
			case 43: Skin[1][id] = 20;
			case 44: Skin[1][id] = 21;
			case 45: Skin[1][id] = 22;
			case 46: Skin[1][id] = 23;
			case 47: Skin[1][id] = 24;
			case 48: Skin[1][id] = 25;
			case 49: Skin[2][id] = 1;
			case 50: Skin[2][id] = 2;
			case 51: Skin[2][id] = 3;
			case 52: Skin[2][id] = 4;
			case 53: Skin[2][id] = 5;
			case 54: Skin[2][id] = 6;
			case 55: Skin[2][id] = 7;
			case 56: Skin[2][id] = 8;
			case 57: Skin[2][id] = 9;
			case 58: Skin[2][id] = 10;
			case 59: Skin[2][id] = 11;
			case 60: Skin[2][id] = 12;
			case 61: Skin[2][id] = 13;
			case 62: Skin[2][id] = 14;
			case 63: Skin[2][id] = 15;
			case 64: Skin[2][id] = 16;
			case 65: Skin[2][id] = 17;
			case 66: Skin[2][id] = 18;
			case 67: Skin[2][id] = 19;
			case 68: Skin[2][id] = 20;
			case 69: Skin[2][id] = 21;
			case 70: Skin[2][id] = 22;
			case 71: Skin[2][id] = 23;
			case 72: Skin[2][id] = 24;
			case 73: Skin[2][id] = 25;
			case 74: Skin[3][id] = 1;
			case 75: Skin[3][id] = 2;
			case 76: Skin[3][id] = 3;
			case 77: Skin[3][id] = 4;
			case 78: Skin[3][id] = 5;
			case 79: Skin[3][id] = 6;
			case 80: Skin[3][id] = 7;
			case 81: Skin[3][id] = 8;
			case 82: Skin[3][id] = 9;
			case 83: Skin[3][id] = 10;
			case 84: Skin[3][id] = 11;
			case 85: Skin[3][id] = 12;
			case 86: Skin[3][id] = 13;
			case 87: Skin[3][id] = 14;
			case 88: Skin[3][id] = 15;
			case 89: Skin[3][id] = 16;
			case 90: Skin[3][id] = 17;
			case 91: Skin[3][id] = 18;
			case 92: Skin[3][id] = 19;
			case 93: Skin[3][id] = 20;
			case 94: Skin[3][id] = 21;
			case 95: Skin[3][id] = 22;
			case 96: Skin[3][id] = 23;
			case 97: Skin[3][id] = 24;
			case 98: Skin[3][id] = 25;
			case 99: Skin[4][id] = 1;
			case 100: Skin[4][id] = 2;
			case 101: Skin[4][id] = 3;
			case 102: Skin[4][id] = 4;
			case 103: Skin[4][id] = 5;
			case 104: Skin[4][id] = 6;
			case 105: Skin[4][id] = 7;
			case 106: Skin[4][id] = 8;
			case 107: Skin[4][id] = 9;
			case 108: Skin[4][id] = 10;
			case 109: Skin[4][id] = 11;
			case 110: Skin[4][id] = 12;
			case 111: Skin[4][id] = 13;
			case 112: Skin[4][id] = 14;
			case 113: Skin[4][id] = 15;
			case 114: Skin[4][id] = 16;
			case 115: Skin[4][id] = 17;
			case 116: Skin[4][id] = 18;
			case 117: Skin[4][id] = 19;
			case 118: Skin[4][id] = 20;
		}
}
public SendMenu(id) 
{
	new String[121], menu;
	menu = menu_create("\dKüldés:", "SendHandler");
	
	format(String, charsmax(String), "Dollár \d[\r%d \d$]", Dollar[id]);
	menu_additem(menu, String, "0", 0);
	format(String, charsmax(String), "Kulcs \d[\r%d \dDB]", Kulcs[id]);
	menu_additem(menu, String, "1", 0);
	format(String, charsmax(String), "PerFecT Pont \d[\r%d \dPont]", perfectpont[id]);
	menu_additem(menu, String, "2", 0);
	format(String, charsmax(String), "1 Napos VIPKupon \d[\r%d]", g_VipKupon[0][id]);
	menu_additem(menu, String, "3", 0);
	format(String, charsmax(String), "3 Napos VIPKupon \d[\r%d]", g_VipKupon[1][id]);
	menu_additem(menu, String, "4", 0);
	format(String, charsmax(String), "7 Napos VIPKupon \d[\r%d]", g_VipKupon[2][id]);
	menu_additem(menu, String, "5", 0);
	format(String, charsmax(String), "%s \d[\r%d \dDB]", LadaNevek[0][0], Lada[0][id]);
	menu_additem(menu, String, "6", 0);
	format(String, charsmax(String), "%s \d[\r%d \dDB]", LadaNevek[1][0], Lada[1][id]);
	menu_additem(menu, String, "7", 0);
	format(String, charsmax(String), "%s \d[\r%d \dDB]", LadaNevek[2][0], Lada[2][id]);
	menu_additem(menu, String, "8", 0);
	format(String, charsmax(String), "%s \d[\r%d \dDB]", LadaNevek[3][0], Lada[3][id]);
	menu_additem(menu, String, "9", 0);
	format(String, charsmax(String), "%s \d[\r%d \dDB]", LadaNevek[4][0], Lada[4][id]);
	menu_additem(menu, String, "10", 0);
	format(String, charsmax(String), "%s \d[\r%d \dDB]", LadaNevek[5][0], Lada[5][id]);
	menu_additem(menu, String, "11", 0);
	
	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}
public SendSkinMenu(id) {
	new cim[121], Menu;
	Menu = menu_create("\dKüldés", "SendHandlerSkin");
	
	for(new i;i < sizeof(Fegyverek); i++)
	{
		if(OsszesSkin[i][id] > 0)
		{
			new Sor[6]; num_to_str(i, Sor, 5);
			formatex(cim, charsmax(cim), "%s \d[\r%d \dDB]", Fegyverek[i][0], OsszesSkin[i][id]);
			menu_additem(Menu, cim, Sor);
		}
	}
	
	menu_display(id, Menu, 0);
	return PLUGIN_HANDLED;
}
public Piac(id)
{
	new cim[121];
	format(cim, charsmax(cim), "[%s] \r- \dPiac^n\yDollár: \d%d", Prefix, Dollar[id]);
	new menu = menu_create(cim, "Piac_h");
	
	menu_additem(menu, "Eladás", "1", 0);
	menu_additem(menu, "Vásárlás", "2", 0);
	menu_additem(menu, "\dTárgyak \wKüldése", "3", 0);
	menu_additem(menu, "\dSkin \wKüldése", "4", 0);
	
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
		case 1: Eladas(id);
			case 2: Vasarlas(id);
			case 3: SendMenu(id);
			case 4: SendSkinMenu(id);
		}
}
public Eladas(id) {
	new cim[121], ks1[121], ks2[121];
	format(cim, charsmax(cim), "[%s] \r- \dEladás", Prefix);
	new menu = menu_create(cim, "eladas_h" );
	
	if(kirakva[id] == 0){
		for(new i=0; i < FEGYO; i++) {
			if(kicucc[id] == 0) format(ks1, charsmax(ks1), "Válaszd ki a Tárgyat!");
			else if(kicucc[id] == i) format(ks1, charsmax(ks1), "Tárgy: \r%s", Fegyverek[i-1][0]);
			}
		menu_additem(menu, ks1 ,"0",0);
	}
	if(kirakva[id] == 0){
		format(ks2, charsmax(ks2), "\dÁRa: \r%d \yDOLLÁR", Erteke[id]);
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
public eladas_h(id, menu, item)
{
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
		case -2:
		{
			kirakva[id] = 0;
			kicucc[id] = 0;
			Erteke[id] = 0;
		}
		case 0:
		{
			fvalaszt(id);
		}
		case 1:
		{
			client_cmd(id, "messagemode DOLLAR");
		}
		case 2:
		{
			for(new i=0; i < FEGYO; i++)
			{
				if(kicucc[id] == i && OsszesSkin[i-1][id] >= 1)
				{
					ColorChat(0, GREEN, "^4%s ^3%s ^1Kirakott egy ^4%s^1-t ^4%d ^1Dollárért",C_Prefix, name, Fegyverek[i-1][0], Erteke[id]);
					kirakva[id] = 1;
				}
			}
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public Talal(id, LadaID)
{
	new Float:OverAll = 0.0;
	new Float:ChanceOld = 0.0;
	new Float:ChanceNow = 0.0;
	new OpenedWepID = 0;
	new Float:OpenedWepChance = 0.0;
	
	switch(LadaID)
	{
		case 0:
		{
			for(new i;i < sizeof(FegyverLada1_drops);i++)
			{
				OverAll += FegyverLada1_drops[i][1];
			}
			new Float:RandomNumber = random_float(0.01,OverAll);
			
			for(new i = 0; i < sizeof(FegyverLada1_drops);i++)
			{
				ChanceOld = ChanceNow;
				ChanceNow += FegyverLada1_drops[i][1];
				if(ChanceOld < RandomNumber < ChanceNow)
				{
					OsszesSkin[floatround(FegyverLada1_drops[i][0])][id]++;
					OpenedWepID = floatround(FegyverLada1_drops[i][0]);
					OpenedWepChance = FegyverLada1_drops[i][1];
				}
			}
		}
		case 1:
		{
			for(new i;i < sizeof(FegyverLada2_drops);i++)
			{
				OverAll += FegyverLada2_drops[i][1];
			}
			new Float:RandomNumber = random_float(0.01,OverAll);
			
			for(new i = 0; i < sizeof(FegyverLada2_drops);i++)
			{
				ChanceOld = ChanceNow;
				ChanceNow += FegyverLada2_drops[i][1];
				if(ChanceOld < RandomNumber < ChanceNow)
				{
					OsszesSkin[floatround(FegyverLada2_drops[i][0])][id]++;
					OpenedWepID = floatround(FegyverLada2_drops[i][0]);
					OpenedWepChance = FegyverLada2_drops[i][1];
				}
			}
		}
		case 2:
		{
			for(new i;i < sizeof(EzustLada_drops);i++)
			{
				OverAll += EzustLada_drops[i][1];
			}
			new Float:RandomNumber = random_float(0.01,OverAll);
			
			for(new i = 0; i < sizeof(EzustLada_drops);i++)
			{
				ChanceOld = ChanceNow;
				ChanceNow += EzustLada_drops[i][1];
				if(ChanceOld < RandomNumber < ChanceNow)
				{
					OsszesSkin[floatround(EzustLada_drops[i][0])][id]++;
					OpenedWepID = floatround(EzustLada_drops[i][0]);
					OpenedWepChance = EzustLada_drops[i][1];
				}
			}
		}
		case 3:
		{
			for(new i;i < sizeof(AranyLada_drops);i++)
			{
				OverAll += AranyLada_drops[i][1];
			}
			new Float:RandomNumber = random_float(0.01,OverAll);
			
			for(new i = 0; i < sizeof(AranyLada_drops);i++)
			{
				ChanceOld = ChanceNow;
				ChanceNow += AranyLada_drops[i][1];
				if(ChanceOld < RandomNumber < ChanceNow)
				{
					OsszesSkin[floatround(AranyLada_drops[i][0])][id]++;
					OpenedWepID = floatround(AranyLada_drops[i][0]);
					OpenedWepChance = AranyLada_drops[i][1];
				}
			}
		}
		case 4:
		{
			for(new i;i < sizeof(GyemantLada_drops);i++)
			{
				OverAll += GyemantLada_drops[i][1];
			}
			new Float:RandomNumber = random_float(0.01,OverAll);
			
			for(new i = 0; i < sizeof(GyemantLada_drops);i++)
			{
				ChanceOld = ChanceNow;
				ChanceNow += GyemantLada_drops[i][1];
				if(ChanceOld < RandomNumber < ChanceNow)
				{
					OsszesSkin[floatround(GyemantLada_drops[i][0])][id]++;
					OpenedWepID = floatround(GyemantLada_drops[i][0]);
					OpenedWepChance = GyemantLada_drops[i][1];
				}
			}
		}
		case 5:
		{
			for(new i;i < sizeof(PremiumLada_drops);i++)
			{
				OverAll += PremiumLada_drops[i][1];
			}
			new Float:RandomNumber = random_float(0.01,OverAll);
			
			for(new i = 0; i < sizeof(PremiumLada_drops);i++)
			{
				ChanceOld = ChanceNow;
				ChanceNow += PremiumLada_drops[i][1];
				if(ChanceOld < RandomNumber < ChanceNow)
				{
					OsszesSkin[floatround(PremiumLada_drops[i][0])][id]++;
					OpenedWepID = floatround(PremiumLada_drops[i][0]);
					OpenedWepChance = PremiumLada_drops[i][1];
				}
			}
		}
	}
	if((OpenedWepChance/(OverAll/100.0)) < 0.3)
	{
		new name[32];
		get_user_name(id, name, charsmax(name));
		ColorChat(0, GREEN, "%s^3%s^1 nyitott egy:^4%s^1-t. ( Esélye ennek:^4%.3f%s ^1)", C_Prefix, name, Fegyverek[OpenedWepID], (OpenedWepChance/(OverAll/100.0)),"%");
		client_cmd(0,"spk p2_hangok/kesnyitas");
	}
	else
	{
		ColorChat(id, GREEN, "%s^1Nyitottál egy:^4%s^1-t. ( Esélye ennek:^4%.3f%s ^1)", C_Prefix, Fegyverek[OpenedWepID], (OpenedWepChance/(OverAll/100.0)),"%");
	}
	
}
public fvalaszt(id) {
	new szMenuTitle[ 121 ],cim[121];
	format( szMenuTitle, charsmax( szMenuTitle ), "[%s] \r- \dEladás", Prefix);
	new menu = menu_create( szMenuTitle, "fvalaszt_h" );
	
	for(new i; i < FEGYO; i++)
	{
		if(OsszesSkin[i][id] > 0)
		{
			new Num[6];
			num_to_str(i, Num, 5);
			formatex(cim, charsmax(cim), "%s \d[\r%d \dDB]", Fegyverek[i][0], OsszesSkin[i][id]);
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
	
	kicucc[id] = key+1;
	Eladas(id);
}
public lekeres(id) {
	new ertek, adatok[32];
	read_args(adatok, charsmax(adatok));
	remove_quotes(adatok);
	
	ertek = str_to_num(adatok);
	
	new hossz = strlen(adatok);
	
	if(hossz > 7)
	{
		client_cmd(id, "messagemode DOLLAR");
	}
	else if(ertek < 20)
	{
		ColorChat(id, GREEN, "%s^1Nem tudsz eladni fegyver^3 20 Dollár alatt.", Prefix);
		Eladas(id);
	}
	else
	{
		Erteke[id] = ertek;
		Eladas(id);
	}
}
public Vasarlas(id)
{      
	new mpont[512], menu, cim[121];
	
	static players[32],temp[10],pnum;  
	get_players(players,pnum,"c");
	
	format(cim, charsmax(cim), "[%s] \r- \dVásárlás", Prefix);
	menu = menu_create(cim, "vasarlas_h" );
	
	for (new i; i < pnum; i++)
	{
		if(kirakva[players[i]] == 1 && Erteke[players[i]] > 0)
		{
			for(new a=0; a < FEGYO; a++)
			{
				if(kicucc[players[i]] == a)
					formatex(mpont,256,"\w%s \d[ÁRa: \r%d\d]", Fegyverek[a-1][0], Erteke[players[i]]);
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
	
	for(new i=0; i < FEGYO; i++)
	{
		if(Dollar[id] >= Erteke[player] && kicucc[player] == i && kirakva[player] == 1)
		{
			kirakva[player] = 0;
			ColorChat(0, GREEN, "%s ^3%s ^1vett egy ^4%s ^1%s-tó‚l ^4%d ^1Dollárért!",Prefix, name, Fegyverek[i-1][0], name2, Erteke[player]);
			Dollar[player] += Erteke[player];
			Dollar[id] -= Erteke[player];
			OsszesSkin[i-1][id] ++;
			OsszesSkin[i-1][player] --;
			kicucc[player] = 0;
			Erteke[player] = 0;
		}
	}
}
public vido()
{
	pido = 0;
}
stock get_player_name(id){
	static Nev[32];
	get_user_name(id, Nev,31);
	return Nev;
}
public Ellenorzes(id)
{
	if(dw_is_user_logged(id))
		Fomenu(id);
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
		if(Send[id] == i && OsszesSkin[i][id] >= str_to_num(Data))
		{
			OsszesSkin[i][TempID] += str_to_num(Data);
			OsszesSkin[i][id] -= str_to_num(Data);
			ColorChat(0, GREEN, "%s^3%s ^1Küldött^3 %d^4 %s^1-t^4 %s^1-nak.", C_Prefix, SendName, str_to_num(Data), Fegyverek[i], TempName);
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
	
	Send[id] = Key;
	
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
	ColorChat(0, GREEN, "%s^3%s ^1Küldött ^4%d Kulcs^1-t ^3%s^1-nak", C_Prefix, SendName, str_to_num(Data), TempName);
}
if(Send[id] == 3 && perfectpont[id] >= str_to_num(Data))
{
	perfectpont[TempID] += str_to_num(Data);
	perfectpont[id] -= str_to_num(Data);
	ColorChat(0, GREEN, "%s^3%s ^1Küldött ^4%d PerFecT Pontot^1-t ^3%s^1-nak", C_Prefix, SendName, str_to_num(Data), TempName);
}
if(Send[id] == 4 && g_VipKupon[0][id] >= str_to_num(Data))
{
	g_VipKupon[0][TempID] += str_to_num(Data);
	g_VipKupon[0][id] -= str_to_num(Data);
	ColorChat(0, GREEN, "%s^3%s ^1Küldött ^4%d 1 Napos VIP Kupon^1-t ^3%s^1-nak", C_Prefix, SendName, str_to_num(Data), TempName);
}
if(Send[id] == 5 && g_VipKupon[1][id] >= str_to_num(Data))
{
	g_VipKupon[1][TempID] += str_to_num(Data);
	g_VipKupon[1][id] -= str_to_num(Data);
	ColorChat(0, GREEN, "%s^3%s ^1Küldött ^4%d 3 Napos VIP Kupon^1-t ^3%s^1-nak", C_Prefix, SendName, str_to_num(Data), TempName);
}
if(Send[id] == 6 && g_VipKupon[2][id] >= str_to_num(Data))
{
	g_VipKupon[2][TempID] += str_to_num(Data);
	g_VipKupon[2][id] -= str_to_num(Data);
	ColorChat(0, GREEN, "%s^3%s ^1Küldött ^4%d 7 Napos VIP Kupon^1-t ^3%s^1-nak", C_Prefix, SendName, str_to_num(Data), TempName);
}
if(Send[id] == 7 && Lada[0][id] >= str_to_num(Data))
{
	Lada[0][TempID] += str_to_num(Data);
	Lada[0][id] -= str_to_num(Data);
	ColorChat(0, GREEN, "%s^3%s ^1Küldött ^4%d %s^1-t ^3%s^1-nak", C_Prefix, SendName, str_to_num(Data), LadaNevek[0][0], TempName);
}
if(Send[id] == 8 && Lada[1][id] >= str_to_num(Data))
{
	Lada[1][TempID] += str_to_num(Data);
	Lada[1][id] -= str_to_num(Data);
	ColorChat(0, GREEN, "%s^3%s ^1Küldött ^4%d %s^1-t ^3%s^1-nak", C_Prefix, SendName, str_to_num(Data), LadaNevek[1][0], TempName);
}
if(Send[id] == 9 && Lada[2][id] >= str_to_num(Data))
{
	Lada[2][TempID] += str_to_num(Data);
	Lada[2][id] -= str_to_num(Data);
	ColorChat(0, GREEN, "%s^3%s ^1Küldött ^4%d %s^1-t ^3%s^1-nak", C_Prefix, SendName, str_to_num(Data), LadaNevek[2][0], TempName);
}
if(Send[id] == 10 && Lada[3][id] >= str_to_num(Data))
{
	Lada[3][TempID] += str_to_num(Data);
	Lada[3][id] -= str_to_num(Data);
	ColorChat(0, GREEN, "%s^3%s ^1Küldött ^4%d %s^1-t ^3%s^1-nak", C_Prefix, SendName, str_to_num(Data), LadaNevek[3][0], TempName);
}
if(Send[id] == 11 && Lada[4][id] >= str_to_num(Data))
{
	Lada[4][TempID] += str_to_num(Data);
	Lada[4][id] -= str_to_num(Data);
	ColorChat(0, GREEN, "%s^3%s ^1Küldött ^4%d %s^1-t ^3%s^1-nak", C_Prefix, SendName, str_to_num(Data), LadaNevek[4][0], TempName);
}
if(Send[id] == 12 && Lada[5][id] >= str_to_num(Data))
{
	Lada[5][TempID] += str_to_num(Data);
	Lada[5][id] -= str_to_num(Data);
	ColorChat(0, GREEN, "%s^3%s ^1Küldött ^4%d %s^1-t ^3%s^1-nak", C_Prefix, SendName, str_to_num(Data), LadaNevek[5][0], TempName);
}

return PLUGIN_HANDLED;
}
public Spawn(id) 
{
if(!is_user_alive(id)) 
{
	return PLUGIN_HANDLED;
}
Buy[id] = 0;
fegyvermenu(id);
g_MVPoints[id] = 0;
g_Awps[TE] = 0;
g_Awps[CT] = 0;
return PLUGIN_HANDLED;
} 
public client_putinserver(id)
{
get_user_name(id, name[id], charsmax(name));

Gun[id] = 1;
Dollar[id] = 0;
Rang[id] = 0;
g_Quest[id] = 0;
g_QuestWeapon[id] = 0;
g_QuestMVP[id] = 0;
g_QuestHead[id] = 0;
Oles[id] = 0;
g_Admin_Level[id] = 0;
HudOff[id] = 0;
g_ASD[id] = 1;
g_Vip[id] = 0;
g_MVP[id] = 0;
g_VipTime[id] = 0;
VanPrefix[id] = 0;
g_Chat_Prefix[id] = "";
perfectpont[id] = 0;
Masodpercek[id] = 0;
hl[id] = 0;
hs[id] = 0;
Kulcs[id] = 0;


for(new i;i < FEGYO; i++)
	OsszesSkin[i][id] = 0;
	
	for(new i;i < LADA; i++)
		Lada[i][id] = 0;
	
	for(new i;i < 5; i++)
		Skin[i][id] = 0;
}
public CmdSetAdmin(id, level, cid){
	if(!str_to_num(Admin_Permissions[g_Admin_Level[id]][2])){
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
	
	formatex(Query, charsmax(Query), "UPDATE `servernew` SET `Admin_Level` = %d WHERE `User_Id` = %d;", Arg_Int[1], Arg_Int[0]);
	SQL_ThreadQuery(g_SqlTuple, "QuerySetData", Query, Data, 2);
	
	if(Is_Online){
		if(Arg_Int[1] > 0)
			client_print_color(0, print_team_default, "%s Játékos: ^3%s ^1(#^3%d^1) | %s jogot kapott! ^3%s^1(#^3%d^1) által!", C_Prefix, name[Is_Online], Arg_Int[0], Admin_Permissions[Arg_Int[1]][0], name[id], dw_get_user_id(id));	
		else
			client_print_color(0, print_team_default, "%s Játékos: ^3%s ^1(#^3%d^1) | Jogok megvonva! ^3%s^1(#^3%d^1) által!", C_Prefix, name[Is_Online], Arg_Int[0], name[id], dw_get_user_id(id));	
		
		Set_Permissions(Is_Online);
		g_Admin_Level[Is_Online] = Arg_Int[1];
	}
	else{
		if(Arg_Int[1] > 0)
			client_print_color(0, print_team_default, "%s Játékos: ^3- ^1(#^3%d^1) | %s jogot kapott! ^3%s^1(#^3%d^1) által!", C_Prefix, Arg_Int[0], Admin_Permissions[Arg_Int[1]][0], name[id], dw_get_user_id(id));	
		else
			client_print_color(0, print_team_default, "%s Játékos: ^3- ^1(#^3%d^1) | Jogok megvonva! ^3%s^1(#^3%d^1) által!", C_Prefix, Arg_Int[0], name[id], dw_get_user_id(id));		
	}
	
	return PLUGIN_HANDLED;
}

public CmdSetVIP(id, level, cid){
	if(!str_to_num(Admin_Permissions[g_Admin_Level[id]][3])){
		client_print(id, print_console, "Nincs elérhetőseg ehhez a parancshoz!");
		return PLUGIN_HANDLED;
	}
	
	new Arg1[32], Arg2[32], Arg_Int[2];
	
	read_argv(1, Arg1, charsmax(Arg1));
	read_argv(2, Arg2, charsmax(Arg2));
	
	Arg_Int[0] = str_to_num(Arg1);
	Arg_Int[1] = str_to_num(Arg2);
	
	if(Arg_Int[0] < 1 || Arg_Int[1] < 0)
		return PLUGIN_HANDLED;
	
	new Is_Online = Check_Id_Online(Arg_Int[0]);
	
	if(Is_Online){
		if(Arg_Int[1] > 0){
			client_print_color(0, print_team_default, "%s Játékos: ^3%s ^1(#^3%d^1) | VIP Tagságot kapott ^3%d^1 napra! ^3%s^1(#^3%d^1) által!", C_Prefix, name[Is_Online], Arg_Int[0], Arg_Int[1], name[id], dw_get_user_id(id));	
			g_Vip[Is_Online] = 1;
		}
		else {
			client_print_color(0, print_team_default, "%s Játékos: ^3%s ^1(#^3%d^1) | VIP Tagság megvonva! ^3%s^1(#^3%d^1) által!", C_Prefix, name[Is_Online], Arg_Int[0], name[id], dw_get_user_id(id));	
			g_Vip[Is_Online] = 0;
		}
		
		g_VipTime[Is_Online] = 86400*Arg_Int[1];
		
	}
	else
		client_print(id, print_console, "A jatekos nincs fent!");
	
	
	return PLUGIN_HANDLED;
}
public ClientInfoChanged(id){
	if(!is_user_connected(id))
		return;
	
	new g_New_Name[32];
	get_user_info(id, "name", g_New_Name, 31);
	if(!equal(name[id], g_New_Name)){
		copy(name[id], 31, g_New_Name);
		set_task(0.1,"Set_Permissions",id);
	}
}  

public Set_Permissions(id){
	new Flags;
	Flags = read_flags(Admin_Permissions[g_Admin_Level[id]][1]);
	set_user_flags(id, Flags);
}
public plugin_cfg()
{
	tabla_1();
	tabla_2();
}
public tabla_1()
{
	g_SqlTuple = SQL_MakeDbTuple(SQLINFO[0], SQLINFO[1], SQLINFO[2], SQLINFO[3]);
	
	static Query[10048];
	new Len;
	
	Len += formatex(Query[Len], charsmax(Query), "CREATE TABLE IF NOT EXISTS `servernew` ");
	Len += formatex(Query[Len], charsmax(Query)-Len, "( ");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`Id` INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`User_Id` INT(11) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`Nev` varchar(32) NOT NULL, ");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`Dollars` int(11) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`SMS` int(11) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`Szint` int(11) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`Oles` int(11) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`halal` int(11) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`Hud` int(11) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`Gun` int(11) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`MVP` int(11) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`headsh` int(11) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`Admin_Level` int(11) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`masodpercek` int(11) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`Vip` int(11) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`VipIdo` int(11) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`vanprefix` int(11) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`prefixneve` varchar(32) NOT NULL,");
	
	for(new i;i < FEGYO; i++)
		Len += formatex(Query[Len], charsmax(Query)-Len, "`F_%d` int(11) NOT NULL,", i);
	
	for(new i;i < LADA; i++)
		Len += formatex(Query[Len], charsmax(Query)-Len, "`L_%d` int(11) NOT NULL,", i);
	
	for(new i;i < 5; i++)
		Len += formatex(Query[Len], charsmax(Query)-Len, "`Skin%d` int(11) NOT NULL,", i);
	
	Len += formatex(Query[Len], charsmax(Query)-Len, "`Kulcs` int(11) NOT NULL)");
	
	SQL_ThreadQuery(g_SqlTuple, "createTableThread", Query);
}
public tabla_2()
{
	g_SqlTuple = SQL_MakeDbTuple(SQLINFO[0], SQLINFO[1], SQLINFO[2], SQLINFO[3]);
	
	static Query[10048];
	new Len;
	
	Len += formatex(Query[Len], charsmax(Query), "CREATE TABLE IF NOT EXISTS `ujmode_kuldetes` ");
	Len += formatex(Query[Len], charsmax(Query)-Len, "( ");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`Id` INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`User_Id` INT(11) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`Nev` varchar(32) NOT NULL, ");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`QuestH` int(11) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`QuestMVP` int(11) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`QuestNeed` int(11) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`QuestHave` int(11) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`QuestWeap` int(11) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`QuestHead` int(11) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`JutDoll` int(11) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`JutLada` int(11) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`JutKulcs` int(11) NOT NULL,");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`JutPont` int(11) NOT NULL)");
	
	SQL_ThreadQuery(g_SqlTuple, "createTableThread", Query);
}
public Load_User_Data(id)
{
	static Query[10048];
	new Data[2];
	Data[0] = id;
	Data[1] = get_user_userid(id); 
	
	formatex(Query, charsmax(Query), "SELECT * FROM `servernew` WHERE `User_Id` = %d;", dw_get_user_id(id));
	SQL_ThreadQuery(g_SqlTuple, "QuerySelectData", Query, Data, 2);
}
public QuerySelectData(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime) {
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) {
		log_amx("%s", Error);
		return;
	}
	else {
		new id = Data[0];
		
		if(SQL_NumRows(Query) > 0) {
			Rang[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Szint"));
			Dollar[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Dollars"));
			Oles[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Oles"));
			hl[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "halal"));
			hs[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "headsh"));
			Gun[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Gun"));
			HudOff[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Hud"));
			perfectpont[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "SMS"));
			g_Admin_Level[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Admin_Level"));
			g_Vip[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Vip"));
			g_VipTime[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "VipIdo"));
			g_MVP[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "MVP"));
			VanPrefix[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "vanprefix"));
			Masodpercek[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "masodpercek"));
			SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "prefixneve"), g_Chat_Prefix[id], charsmax(g_Chat_Prefix[]));
			
			
			for(new i;i < FEGYO; i++)
			{
				new String[64];
				formatex(String, charsmax(String), "F_%d", i);
				OsszesSkin[i][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, String));
			}
			
			for(new i;i < LADA; i++)
			{
				new String[64];
				formatex(String, charsmax(String), "L_%d", i);
				Lada[i][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, String));
			}
			for(new i;i < 5; i++)
			{
				new String[64];
				formatex(String, charsmax(String), "Skin%d", i);
				Skin[i][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, String));
			}
			
			Kulcs[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Kulcs"));
			
			
			Set_Permissions(id);
			fegyvermenu(id);
			
		}
		else
			Save_Profile(id);
	}
}

public Save_Profile(id){
	new Query[512], Data[2];
	
	Data[0] = id;
	Data[1] = get_user_userid(id); 
	
	formatex(Query, charsmax(Query), "INSERT INTO `servernew` (`User_Id`, `Nev`) VALUES (%d, ^"%s^");", dw_get_user_id(id), name[id]);
	SQL_ThreadQuery(g_SqlTuple, "QuerySetDataProfile", Query, Data, 2);
}

public QuerySetDataProfile(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime){
	if( FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED ){
		log_amx("%s", Error);
		return;
	}
	else{
		new id = Data[0];
		
		if(Data[1] != get_user_userid(id) )
			return;
	}
}
public Update_User_Data(id)
{
	static Query[10048];
	new Len;
	
	Len += formatex(Query[Len], charsmax(Query), "UPDATE `servernew` SET Dollars = ^"%i^", ",Dollar[id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "Szint = ^"%i^", ", Rang[id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "Oles = ^"%i^", ", Oles[id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "halal = ^"%i^", ", hl[id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "vanprefix = ^"%i^", ", VanPrefix[id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "prefixneve = ^"%s^", ", g_Chat_Prefix[id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "Hud = ^"%i^", ", HudOff[id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "Gun = ^"%i^", ", Gun[id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "MVP = ^"%i^", ", g_MVP[id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "headsh = ^"%i^", ", hs[id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "SMS = ^"%i^", ", perfectpont[id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "Admin_Level = ^"%i^", ", g_Admin_Level[id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "VipIdo = ^"%i^", ", g_VipTime[id]-get_user_time(id));
	Len += formatex(Query[Len], charsmax(Query)-Len, "masodpercek = ^"%i^", ", Masodpercek[id]+get_user_time(id));
	Len += formatex(Query[Len], charsmax(Query)-Len, "Vip = ^"%i^", ", g_Vip[id]);
	
	for(new i;i < FEGYO; i++)
		Len += formatex(Query[Len], charsmax(Query)-Len, "F_%d = ^"%i^", ", i, OsszesSkin[i][id]);
	
	for(new i;i < LADA; i++)
		Len += formatex(Query[Len], charsmax(Query)-Len, "L_%d = ^"%i^", ", i, Lada[i][id]);	
	
	for(new i;i < 5; i++)
		Len += formatex(Query[Len], charsmax(Query)-Len, "Skin%d = ^"%i^", ", i, Skin[i][id]);
	
	Len += formatex(Query[Len], charsmax(Query)-Len, "Kulcs = ^"%i^" WHERE `User_Id` =  %d;", Kulcs[id], dw_get_user_id(id));
	
	SQL_ThreadQuery(g_SqlTuple, "QuerySetData", Query);
}
public createTableThread(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime) {
	if(FailState == TQUERY_CONNECT_FAILED)
		set_fail_state("[HIBA*] NEM TUDTAM CSATLAKOZNI AZ ADATBAZISHOZ!");
	else if(FailState == TQUERY_QUERY_FAILED)
		set_fail_state("Query Error");
	if(Errcode)
		log_amx("[HIBA*] HIBAT DOBTAM: %s",Error);
}

public QuerySetData(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime){
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) {
		log_amx("%s", Error);
		return;
	}
}
public Hook_Say(id){
	if(!dw_is_user_logged(id))
		return PLUGIN_HANDLED;
	
	new Message[512], Status[16], Num[5];
	new strName[512], strText[512];
	
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
	
	if((Num[0] >= 3 && Num[1] >= 1 && Num[2] >= 8) || (Num[3] >= 3) || Num[4]){
		client_print_color(id, print_team_default,  "!g[.:DNS:.] ^1 Tilos a hÃ­rdetÃ©s!");
		return PLUGIN_HANDLED;
	}
	
	if(Message[0] == '@' || equal (Message, "") || Message[0] == '/')
		return PLUGIN_HANDLED;
	
	if(!is_user_alive(id))
		Status = "*Halott* ";
	
	new c_Prefix[32];

	new len, String[512];
  
  	len += formatex(String[len], charsmax(String)-len, "^1%s", Status);

	if(g_Vip[id] == 1)
    len += formatex(String[len], charsmax(String)-len, "^1[^4VIP^1]");
  	if(g_Admin_Level[id] > 0)
    len += formatex(String[len], charsmax(String)-len, "^4[%s]", Admin_Permissions[g_Admin_Level[id]][0]);
	if(g_ASD[id] == 1)
    len += formatex(String[len], charsmax(String)-len, "^4[%s]", Rangok[Rang[id]][Szint]);
	if(strlen(g_Chat_Prefix[id]) > 0)
    len += formatex(String[len], charsmax(String)-len, "^4[%s]", g_Chat_Prefix[id]);

	
  
  	if(g_Admin_Level[id] > 0)
    len += formatex(String[len], charsmax(String)-len, "^3%s:^4", name[id]);
  	else
    len += formatex(String[len], charsmax(String)-len, "^3%s:^1", name[id]);
  
  	format(Message, charsmax(Message), "%s %s", String, Message);

	for(new i; i < g_Maxplayers; i++){
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

stock Check_Id_Online(id){
	for(new idx = 1; idx < g_Maxplayers; idx++){
		if(!is_user_connected(idx) || !dw_is_user_logged(idx))
			continue;
		
		if(dw_get_user_id(idx) == id)
			return idx;
	}
	return 0;
}

stock client_printcolor(const id, const input[], any:...){
	new Message[191];
	vformat(Message, 190, input, 3);
	
	replace_all(Message, 190, "!g", "^4");
	replace_all(Message, 190, "^1", "^1");
	replace_all(Message, 190, "^3", "^3");  
	
	if(id){
		message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, id);
		write_byte(id);
		write_string(Message);
		message_end();
	}
	else {
		for(new idx = 1; idx < g_Maxplayers; idx++){
			if(!is_user_connected(idx))
				continue;
			
			message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, idx);
			write_byte(idx);
			write_string(Message);
			message_end();
		}
	}
	return PLUGIN_HANDLED;
}
public fegyvermenu(id)
{
	if(!dw_is_user_logged(id))
		return;
	
	if(Buy[id]){
		client_print_color(id, print_team_default, "^4%s ^1Ebben a körben már választottál fegyvert!", C_Prefix);
		return;
	}
	
	if(!user_has_weapon(id, CSW_C4))
	{
		if(is_user_connected(id)) strip_user_weapons(id);
		
		new menu = menu_create("\r[PerFecT] Fegyvermenü", "handler");
		menu_additem(menu, "\r[\w*~\yM4A1\w~*\r]", "1", 0);
		menu_additem(menu, "\r[\w*~\yAK47\w~*\r]", "2", 0);
		menu_additem(menu, "\r[\w*~\yAWP\w~*\r] \yElső 4 embernek", "3", 0);
		menu_additem(menu, "\r[\w*~\yMachineGun\w~*\r]", "4", 0);
		menu_additem(menu, "\r[\w*~\yAUG\w~*\r]", "5", 0);
		menu_additem(menu, "\r[\w*~\yFAMAS\w~*\r]", "6", 0);
		menu_additem(menu, "\r[\w*~\yGALIL\w~*\r]", "7", 0);
		menu_additem(menu, "\r[\w*~\yMP5\w~*\r]", "8", 0);
		menu_additem(menu, "\r[\w*~\yXM1014 Shotgun\w~*\r]", "9", 0);
		menu_additem(menu, "\r[\w*~\yM3 Shotgun\w~*\r]", "10", 0);
		menu_additem(menu, "\r[\w*~\yScout\w~*\r]", "11", 0);
		menu_additem(menu, "\r[\w*~\yMAC 10\w~*\r]", "12", 0);
		menu_additem(menu, "\r[\w*~\yTMP\w~*\r]", "13", 0);
		menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
		menu_display(id, menu);
	}
	else
	{
		new menu = menu_create("\r[PerFecT] Fegyvermenü", "handler");
		menu_additem(menu, "\r[\w*~\yM4A1\w~*\r]", "1", 0);
		menu_additem(menu, "\r[\w*~\yAK47\w~*\r]", "2", 0);
		menu_additem(menu, "\r[\w*~\yAWP\w~*\r] \yElső 4 embernek", "3", 0);
		menu_additem(menu, "\r[\w*~\yMachineGun\w~*\r]", "4", 0);
		menu_additem(menu, "\r[\w*~\yAUG\w~*\r]", "5", 0);
		menu_additem(menu, "\r[\w*~\yFAMAS\w~*\r]", "6", 0);
		menu_additem(menu, "\r[\w*~\yGALIL\w~*\r]", "7", 0);
		menu_additem(menu, "\r[\w*~\yMP5\w~*\r]", "8", 0);
		menu_additem(menu, "\r[\w*~\yXM1014 Shotgun\w~*\r]", "9", 0);
		menu_additem(menu, "\r[\w*~\yM3 Shotgun\w~*\r]", "10", 0);
		menu_additem(menu, "\r[\w*~\yScout\w~*\r]", "11", 0);
		menu_additem(menu, "\r[\w*~\yMAC 10\w~*\r]", "12", 0);
		menu_additem(menu, "\r[\w*~\yTMP\w~*\r]", "13", 0);
		menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
		menu_display(id, menu);
	}
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
		Pisztolyok(id);
		give_item(id, "ammo_556nato");
		give_item(id, "ammo_556nato");
		give_item(id, "ammo_556nato");
		client_print_color(id, print_team_default, "^3[^4PerFecT^3]^1 Kaptál egy ^3M4A1^1 fegyvert!");
	}
	case 2:
	{
		
		give_player_grenades(id);
		give_item(id, "weapon_knife");
		give_item(id, "weapon_ak47");
		give_item(id, "item_kevlar");
		Pisztolyok(id);
		give_item(id, "ammo_762nato");
		give_item(id, "ammo_762nato");
		set_user_armor(id, 100);
		give_item(id, "ammo_762nato");
		client_print_color(id, print_team_default, "^3[^4PerFecT^3]^1 Kaptál egy ^3AK47^1 fegyvert!");
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
					{ct_num++;}
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
						Pisztolyok(id);
						give_item(id, "ammo_338magnum");
						give_item(id, "ammo_338magnum");
						set_user_armor(id, 100);
						give_item(id, "ammo_338magnum");
						client_print_color(id, print_team_default, "^3[^4PerFecT^3]^1 Kaptál egy ^3AWP^1 fegyvert!");
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
						Pisztolyok(id);
						give_item(id, "ammo_338magnum");
						give_item(id, "ammo_338magnum");
						give_item(id, "ammo_338magnum");
						client_print_color(id, print_team_default, "^3[^4PerFecT^3]^1 Kaptál egy ^3AWP^1 fegyvert!");
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
			Pisztolyok(id);
			give_item(id, "weapon_m249");
			give_item(id, "item_kevlar");
			give_item(id, "ammo_556natobox");
			give_item(id, "ammo_556natobox");
			set_user_armor(id, 100);
			give_item(id, "ammo_556natobox");
			client_print_color(id, print_team_default, "^3[^4PerFecT^3]^1 Kaptál egy ^3MachineGun^1 fegyvert!");
		}  
		case 5:
		{
			
			give_player_grenades(id);
			give_item(id, "weapon_knife");
			Pisztolyok(id);
			give_item(id, "weapon_aug");
			give_item(id, "item_kevlar");
			give_item(id, "ammo_556nato");
			give_item(id, "ammo_556nato");
			set_user_armor(id, 100);
			give_item(id, "ammo_556nato");
			client_print_color(id, print_team_default, "^3[^4PerFecT^3]^1 Kaptál egy ^3AUG^1 fegyvert!");
		}
		case 6:
		{
			
			give_player_grenades(id);
			give_item(id, "weapon_knife");
			Pisztolyok(id);
			give_item(id, "weapon_famas");
			give_item(id, "item_kevlar");
			give_item(id, "ammo_556nato");
			set_user_armor(id, 100);
			give_item(id, "ammo_556nato");
			give_item(id, "ammo_556nato");
			client_print_color(id, print_team_default, "^3[^4PerFecT^3]^1 Kaptál egy ^3Famas^1 fegyvert!");
		}
		case 7:
		{
			
			give_player_grenades(id);
			give_item(id, "weapon_knife");
			Pisztolyok(id);
			give_item(id, "weapon_galil");
			give_item(id, "ammo_556nato");
			give_item(id, "item_kevlar");
			set_user_armor(id, 100);
			give_item(id, "ammo_556nato");
			give_item(id, "ammo_556nato");
			client_print_color(id, print_team_default, "^3[^4PerFecT^3]^1 Kaptál egy ^3Galil^1 fegyvert!");
		}
		case 8:
		{
			
			give_player_grenades(id);
			give_item(id, "item_kevlar");
			give_item(id, "weapon_knife");
			Pisztolyok(id);
			give_item(id, "weapon_mp5navy");
			give_item(id, "ammo_9mm");
			give_item(id, "ammo_9mm");
			set_user_armor(id, 100);
			give_item(id, "ammo_9mm");
			client_print_color(id, print_team_default, "^3[^4PerFecT^3]^1 Kaptál egy ^3SMG^1 fegyvert!");
		}
		case 9:
		{
			
			give_player_grenades(id);
			give_item(id, "weapon_knife");
			Pisztolyok(id);
			give_item(id, "weapon_xm1014");
			give_item(id, "ammo_buckshot");
			set_user_armor(id, 100);
			give_item(id, "item_kevlar");
			give_item(id, "ammo_buckshot");
			give_item(id, "ammo_buckshot");
			client_print_color(id, print_team_default, "^3[^4PerFecT^3]^1 Kaptál egy ^3AutoShotgun^1 fegyvert!");
		}
		case 10:
		{
			
			give_player_grenades(id);
			give_item(id, "weapon_knife");
			Pisztolyok(id);
			give_item(id, "item_kevlar");
			set_user_armor(id, 100);
			give_item(id, "weapon_m3");
			give_item(id, "ammo_buckshot");
			give_item(id, "ammo_buckshot");
			give_item(id, "ammo_buckshot");
			client_print_color(id, print_team_default, "^3[^4PerFecT^3]^1 Kaptál egy ^3Shotgun^1 fegyvert!");
		}
		case 11:
		{
			
			give_player_grenades(id);
			give_item(id, "weapon_knife");
			Pisztolyok(id);
			give_item(id, "item_kevlar");
			set_user_armor(id, 100);
			give_item(id, "weapon_scout");
			give_item(id, "ammo_762nato");
			give_item(id, "ammo_762nato");
			give_item(id, "ammo_762nato");
			client_print_color(id, print_team_default, "^3[^4PerFecT^3]^1 Kaptál egy ^3Scout^1 fegyvert!");
		}
		case 12:
		{
			
			give_player_grenades(id);
			give_item(id, "item_kevlar");
			give_item(id, "weapon_knife");
			Pisztolyok(id);
			give_item(id, "weapon_mac10");
			give_item(id, "ammo_45acp");
			give_item(id, "ammo_45acp");
			set_user_armor(id, 100);
			give_item(id, "ammo_45acp");
			client_print_color(id, print_team_default, "^3[^4PerFecT^3]^1 Kaptál egy ^3Pityókahámozó^1 fegyvert!");
		}
		case 13:
		{
			
			give_player_grenades(id);
			give_item(id, "item_kevlar");
			give_item(id, "weapon_knife");
			Pisztolyok(id);
			give_item(id, "weapon_tmp");
			give_item(id, "ammo_9mm");
			give_item(id, "ammo_9mm");
			set_user_armor(id, 100);
			give_item(id, "ammo_9mm");
			client_print_color(id, print_team_default, "^3[^4PerFecT^3]^1 Kaptál egy ^3Pityókahámozó^1 fegyvert!");
		}
	}
	return PLUGIN_HANDLED;
}

stock give_player_grenades(index)
{
	give_item(index, "weapon_hegrenade");
	give_item(index, "weapon_flashbang");
	give_item(index, "weapon_flashbang");
	give_item(index, "item_thighpack");
	if(g_Vip[index] == 1)
	{
		give_item(index, "weapon_smokegrenade");
	}
}
public Pisztolyok(id)
{
	new String[121];
	formatex(String, charsmax(String), "\d[PerFecT] Fegyvermenü", Prefix);
	new menu = menu_create(String, "Pisztolyok_h");
	menu_additem(menu, "\r[\w*~\yDEAGLE\w~*\r]", "1", 0);
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
public top20ThreadaK(FailState, Handle:Query, Error[], Errcode, szData[], DataSize)
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
		Top[2][count] = SQL_ReadResult(Query, 6);
		TopRang[count] = SQL_ReadResult(Query, 5);
		
		SQL_ReadResult(Query, 2, TopNev[2][count], 31);
		
		count++;
		
		SQL_NextRow(Query);
	}
	
	return;
}
public TopFOles(id)
{
	static menu[3000];
	new len;
	
	len += formatex(menu[len], charsmax(menu) - len, "<head><meta charset=^"UTF-8^"></head><center><table border=^"1^">");
	
	len += formatex(menu[len], charsmax(menu) - len, "<body bgcolor=#000000><table style=^"color: #00FFFF^">");
	
	len += formatex(menu[len], charsmax(menu) - len, "<td>Jatekosnev</td>");
	
	len += formatex(menu[len], charsmax(menu) - len, "<td>Oles</td>");
	
	for(new i; i < 15; i++)
	{
		len += formatex(menu[len], charsmax(menu) - len, "<tr><td>%02d.  %s</td>", i+1, TopNev[2][i]);
		
		len += formatex(menu[len], charsmax(menu) - len, "<td>%d (%s)</td></tr>", Top[2][i], Rangok[TopRang[i]]);
	}
	
	len = formatex(menu[len], charsmax(menu) - len, "</table></center>");
	
	show_motd(id, menu, "DanGeR OnlyDust2 | TOP 3 FRAGVERSENY Ölések");
}
public TopOles(id)
{
	static menu[3000];
	new len;
	
	len += formatex(menu[len], charsmax(menu) - len, "<head><meta charset=^"UTF-8^"></head><center><table border=^"1^">");
	
	len += formatex(menu[len], charsmax(menu) - len, "<body bgcolor=#000000><table style=^"color: #00FFFF^">");
	
	len += formatex(menu[len], charsmax(menu) - len, "<td>Jatekosnev</td>");
	
	len += formatex(menu[len], charsmax(menu) - len, "<td>Oles</td>");
	
	for(new i; i < 15; i++)
	{
		len += formatex(menu[len], charsmax(menu) - len, "<tr><td>%02d.  %s</td>", i+1, TopNev[2][i]);
		
		len += formatex(menu[len], charsmax(menu) - len, "<td>%d (%s)</td></tr>", Top[2][i], Rangok[TopRang[i]]);
	}
	
	len = formatex(menu[len], charsmax(menu) - len, "</table></center>");
	
	show_motd(id, menu, "PerFecT OnlyDust2 | TOP15 Ölések");
}
public top3ThreadaKFRAG(FailState, Handle:Query, Error[], Errcode, szData[], DataSize)
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
		Top[2][count] = SQL_ReadResult(Query, 6);
		TopRang[count] = SQL_ReadResult(Query, 5);
		
		SQL_ReadResult(Query, 2, TopNev[2][count], 31);
		
		count++;
		
		SQL_NextRow(Query);
	}
	
	return;
}
public cmdTopByKills()
{
	SQL_ThreadQuery(g_SqlTuple, "top20ThreadaKFRAG","SELECT * FROM `servernew` ORDER BY Oles DESC LIMIT 15");
	
	return PLUGIN_HANDLED;
}
public cmdTopByFragKills()
{
	SQL_ThreadQuery(g_SqlTuple, "top20ThreadaK","SELECT * FROM `servernew` ORDER BY Oles DESC LIMIT 15");
	
	return PLUGIN_HANDLED;
}
public cmdTopByMoney()
{
	SQL_ThreadQuery(g_SqlTuple, "top20ThreadaM","SELECT * FROM `servernew` ORDER BY Dollars DESC LIMIT 15");
	
	return PLUGIN_HANDLED;
}
public cmdTopByTime()
{
	SQL_ThreadQuery(g_SqlTuple, "top10ThreadaT","SELECT * FROM `servernew` ORDER BY masodpercek DESC LIMIT 15");
	
	return PLUGIN_HANDLED;
}
public top10ThreadaT(FailState, Handle:Query, Error[], Errcode, szData[], DataSize)
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
		return ;
	}
	
	new count;
	
	while(SQL_MoreResults(Query))
	{
		Top[0][count] = SQL_ReadResult(Query, 10);
		
		SQL_ReadResult(Query, 2, TopNev[0][count], 31);
		
		count++;
		
		SQL_NextRow(Query);
	}
	
	return;
}
public top20ThreadaM(FailState, Handle:Query, Error[], Errcode, szData[], DataSize)
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
		Top[1][count] = SQL_ReadResult(Query, 3);
		
		SQL_ReadResult(Query, 2, TopNev[1][count], 31);
		
		count++;
		
		SQL_NextRow(Query);
	}
	
	return;
}
public TopIdo(id)
{
	static menu[3000];
	new len;
	
	len += formatex(menu[len], charsmax(menu) - len, "<head><meta charset=^"UTF-8^"></head><center><table border=^"1^">");
	
	len += formatex(menu[len], charsmax(menu) - len, "<body bgcolor=#000000><table style=^"color: #00FFFF^">");
	
	len += formatex(menu[len], charsmax(menu) - len, "<td>Játékosnévq</td>");
	
	len += formatex(menu[len], charsmax(menu) - len, "<td>Játszott Idő</td>");
	
	new iMasodperc, iPerc, iOra, iNap;
	
	for(new i; i < 15; i++)
	{
		iMasodperc = Top[0][i];
		
		iPerc = iMasodperc / 60;
		iOra = iPerc / 60;
		iMasodperc = iMasodperc - iPerc * 60;
		iPerc = iPerc - iOra * 60;
		iNap = iOra / 24;
		iOra = iOra - (iNap * 24);
		
		len += formatex(menu[len], charsmax(menu) - len, "<tr><td>%02d.  %s</td>", i+1, TopNev[0][i]);
		
		len += formatex(menu[len], charsmax(menu) - len, "<td>%d Nap %d Óra %d Másodperc %d Perc</td><tr>", iNap, iOra, iPerc, iMasodperc);
	}
	
	len = formatex(menu[len], charsmax(menu) - len, "</table></center>");
	
	show_motd(id, menu, "PerFecT OnlyDust2 | 15 legkockább játékos");
}
public TopDollar(id)
{
	static menu[3000];
	new len;
	
	len += formatex(menu[len], charsmax(menu) - len, "<head><meta charset=^"UTF-8^"></head><center><table border=^"1^">");
	
	len += formatex(menu[len], charsmax(menu) - len, "<body bgcolor=#000000><table style=^"color: #00FFFF^">");
	
	len += formatex(menu[len], charsmax(menu) - len, "<td>Játékosnév</td>");
	
	len += formatex(menu[len], charsmax(menu) - len, "<td>Dollár</td>");
	
	for(new i; i < 15; i++)
	{
		len += formatex(menu[len], charsmax(menu) - len, "<tr><td>%02d.  %s</td>", i+1, TopNev[1][i]);
		
		len += formatex(menu[len], charsmax(menu) - len, "<td>%d$</td></tr>", Top[1][i]);
	}
	
	len = formatex(menu[len], charsmax(menu) - len, "</table></center>");
	
	show_motd(id, menu, "PerFecT OnlyDust2 | TOP15 Dollár");
}
public RoundEnds()
{
	new players[32], num;
	get_players(players, num);
	SortCustom1D(players, num, "SortMVPToPlayer");
	
	TopMvp = players[0];
	
	new mvpName[32];
	get_user_name(TopMvp, mvpName, charsmax(mvpName));
	
	ColorChat(0, GREEN, "%s ^1Ebben a körben a legjobb játékos ^3%s ^1volt! ^1(^4+1 MVP^1)", C_Prefix, mvpName);
	g_MVP[TopMvp]++;
}
public SortMVPToPlayer(id1, id2){
	if(g_MVPoints[id1] > g_MVPoints[id2]) return -1;
	else if(g_MVPoints[id1] < g_MVPoints[id2]) return 1;
		
	return 0;
}
public bomb_planted(id) {
	new Num = random_num(0, 5);
	new Num2 = random_num(0, 2);
	Dollar[id] += Num;
	perfectpont[id] += Num2;
	ColorChat(0, GREEN, "%s ^3%s^4(^1#^4%d^3) ^1élesítette a bombát kapott (^4%d Dollárt, és ^4%d^1 PerFecT Pontot^1)", C_Prefix, name[id], dw_get_user_id(id), Num, Num2);
}
public bomb_defused(id) {
	new Num = random_num(0, 5);
	new Num2 = random_num(0, 2);
	Dollar[id] += Num;
	perfectpont[id] += Num2;
	ColorChat(0, GREEN, "%s ^3%s^4(^1#^4%d^3) ^1hatástalanította a bombát kapott (^4%d Dollárt, és ^4%d^1 PerFecT Pontot^1)", C_Prefix, name[id], dw_get_user_id(id), Num, Num2);
}
public plugin_end()
{
	ArrayDestroy(g_Admins);
	SQL_FreeHandle(g_SqlTuple);
}
