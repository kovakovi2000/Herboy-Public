new GoToLocalServer = 0;
new PlayedCount[33], erdem2[33];
new TopFrag_1[33], TopFrag_2[33], TopFrag_3[33]
new isRuined = 0;

#include <ServerInclude.dark>


new const MusicKitInfos[][MusicDatas] = {
    // NÉV                         //ELÉRÉSI ÚT                   //ÁR
	{"", "", 00.00, 0}, 
	{"Ella Henderson - Ghost", "sound/musickit/1.mp3", 40.00, 30}, 
	{"The Script - Hall Of Fame", "sound/musickit/2.mp3", 90.00, 40}, //13
	{"K-391 - Windows", "sound/musickit/3.mp3", 110.00, 60}, //13
	{"Elias - God Ls Great", "sound/musickit/4.mp3", 150.00, 100}, //13
	{"AJR - Weak", "sound/musickit/5.mp3", 175.00, 140}, //13
	{"Michael Mind Project - Feeling So Blue", "sound/musickit/6.mp3", 190.00, 170}, //13
	{"The Verkkars - EZ4ENCE", "sound/musickit/7.mp3", 220.00, 230} //13
}
new const g_Ermek[][Erem_Properties] =
{
    {0, "Nincs érdemérem", "Sajnos nincs érdemérmed!"},
    {1, "BETA Teszter érdemérem", "Részt vett az első teszteléseken."},
    {2, "Black Night Diamond érdemérem", "Bent volt az első 1000 regisztrációban."},
    {3, "Black Night Gold érdemérem", "Bent volt az 1000-2000 regisztrációban."},
    {4, "Black Night Bronz érdemérem", "Bent volt az első 2000-3000 regisztrációban."},
    {5, "Black Night Silver érdemérem", "Bent volt az első 3000-4000 regisztrációban."},
    {6, "Dark Angels Iron érdemérem", "Bent volt az első 4000-5000 regisztrációban."},
    {7, "2020-as szolgálati érdemérem - #1", "Végigvitte 2020-ban a 40-es szintet."},
	{8, "2021-es szolgálati érdemérem", "Végigvitte 2021-ben a 40-es szintet."},
    {9, "Fragverseny érdemérem #1", "5 Fragversenyen 1. helyezettként végzett."},
    {10, "Fragverseny érdemérem #2", "5 Fragversenyen 2. helyezettként végzett."},
    {11, "Fragverseny érdemérem #3", "5 Fragversenyen 3. helyezettként végzett."},
    {12, "Támogató érdemérem", "Valamilyen formában támogatta a szervert."},
    {13, "Visszatérő érdemérem", "Legalább 30 játszott napja van a szerveren."},
	{14, "1 éves szolgálati érdemérem", "1 Éve csatlakozott előszőr a szerverre."},
	{15, "2020-as szolgálati érdemérem - #2", "Végigvitte kétszer 2020-ban a 40-es szintet."},
	{16, "2020-as szolgálati érdemérem - #3", "Végigvitte háromszor 2020-ban a 40-es szintet."},
	{17, "2020-as szolgálati érdemérem - #4", "Végigvitte négyszer 2020-ban a 40-es szintet."},
	{18, "2020-as szolgálati érdemérem - #5", "Végigvitte ötször 2020-ban a 40-es szintet."},
	{19, "BETA Teszter érdemérem #2", "Részt vett a 2020/09/15-16-os teszteléseken."},
	{20, "Dark Angel'S Alázója érdemérem", "Több mint 50 nyert meccsje van."},
}
new const EremTipusok[][] =
{
	{"Gyakori"},
	{"Kevésbé Gyakori"},
	{"Ritka"},
	{"Rendkívül Ritka"},
	{"Nem gyűjthető"}
};
enum _:DropSystem_Prop
{
	d_Name[32],
	Float:d_rarity,
	Float:VipDropchance
}

new const Cases[][DropSystem_Prop] =
{
	{"Alap Láda", 4.5, 2.25},
	{"Kezdő Láda", 5.0, 2.5},
	{"Arany Láda", 5.0, 2.5},
	{"Belépő Láda", 2.5, 1.25},
	{"Profi Láda", 1.0, 0.5},
	{"Prémium Láda", 1.0, 0.5},
	{"Karácsonyi Láda", 0.001, 0.001},
	{"Versus Láda", 1.8, 1.0}
}
new const Keys[][DropSystem_Prop] =
{
	{"Alap Ládakulcs", 4.5, 2.25},
	{"Kezdő Ládakulcs", 5.0, 2.5},
	{"Arany Ládakulcs", 5.0, 2.5},
	{"Belépő Ládakulcs", 2.5, 1.25},
	{"Profi Ládakulcs", 1.0, 0.5},
	{"Prémium Ládakulcs", 1.0, 0.5},
	{"Karácsonyi Ládakulcs", 0.001, 0.001},
	{"Versus Ládakulcs", 1.8, 1.0},
}


new const LadaNevek[][] =
{
	{"Alap Láda"},
	{"Kezdő Láda"},
	{"Arany Láda"},
	{"Belépő Láda"},
	{"Profi Láda"},
	{"Prémium Láda"},
	{"Karácsonyi Láda"},
	{"Versus Láda"},
};
new const LadaKNevek[][] =
{
	{"Alap Ládakulcs"},
	{"Kezdő Ládakulcs"},
	{"Arany Ládakulcs"},
	{"Belépő Ládakulcs"},
	{"Profi Ládakulcs"},
	{"Prémium Ládakulcs"},
	{"Karácsonyi Ládakulcs"},
	{"Versus Ládakulcs"}
};
new const LastFrags[][] =
{
    {"A következő fragverseny^3 12:00^1-kor lesz!"},
    {"A következő fragverseny^3 17:00^1-kor lesz!"},
    {"A következő fragverseny^3 20:00^1-kor lesz!"},
    {"A következő fragverseny^3 Holnap 12:00^1-kor lesz!"}
}
new const JutalmakFrag1[][] =
{
    {"15 Prémium Láda + 15 Kulcs"},
    {"15 Profi Láda + 15 Kulcs"},
    {"1 Hét VIP + 30.00$"},
    {"60.00$ + 100 Dark Pont"},
    {"40.00$ + 50 Dark Pont"},
    {"1 Hét VIP"},
    {"10 Prémium Láda + 10 Kulcs"},
    {"15 Profi Láda + 15 Kulcs"},
    {"1 Hét VIP + 30.00$"},
    {"60.00$ + 100 Dark Pont"},
    {"40.00$ + 50 Dark Pont"},
    {"1 Hét VIP"},
    {"1 Random Kés"}
}
new const JutalmakFrag2[][] =
{
    {"10 Profi Láda + 10 Kulcs"},
    {"10 Belépő Láda + 10 Kulcs"},
    {"3 Nap VIP + 30.00$"},
    {"30.00$ + 50 Dark Pont"},
    {"20.00$ + 50 Dark Pont"},
    {"5 Nap VIP"},
    {"10 Profi Láda + 10 Kulcs"},
    {"3 Nap VIP"},
    {"40.00$"},
    {"30.00$ + 50 Dark Pont"},
}
new const JutalmakFrag3[][] =
{
    {"5 Belépő Láda + 5 Kulcs"},
    {"1 Nap VIP + 10.00$"},
    {"20.00$"},
    {"10.00$"},
    {"3 Nap VIP"},
    {"1 Nap VIP"},
    {"20.00$"},
    {"10.00$ + 50 Dark Pont"},
}

new const BattlePass[][] =
{
{ "Nincs."},
{ "Nincs."},
{ "5.00$"},
{ "Nincs."},
{ "10.00$"},
{ "Nincs."},
{ "1 Ajándékcsomag"},
{ "Nincs."},
{ "10.00$"},
{ "Nincs."},
{ "25.00% XP"},
{ "Nincs."},
{ "15.00$"},
{ "Nincs."},
{ "1 Ajándékcsomag"},
{ "Nincs."},
{ "1 StatTrak* Tool"},
{ "Nincs."},
{ "1 Névcédula"},
{ "Nincs."},
{ "10.00$"},
{ "Nincs."},
{ "10 Nap VIP tagság"},
{ "Nincs."},
{ "25.00 XP"},
{ "Nincs."},
{ "30.00$"},
{ "Nincs."},
{ "10 PP"},
{ "Nincs."},
{ "5 Ajándékcsomag"},
{ "Nincs."},
{ "50.00% XP"},
{ "Nincs."},
{ "1 StatTrak* Tool"},
{ "Nincs."},
{ "1 Névcédula"}, //36LVL
{ "Nincs."},
{ "60.00$"},
{ "Nincs."},
{ "10 PP"},
{ "Nincs."},
{ "10 Ajándékcsomag"},
{ "Nincs."},
{ "80.00$"},
{ "Nincs."},
{ "80.00% XP"},
{ "Nincs."},
{ "Black Ice Érdemérem"},
{ "Nincs."},
{ "Cannabis Life Érdemérem"},
{ "Nincs."},
{ "5 StatTrak* Tool"},
{ "Nincs."},
{ "5 Névcédula"},
{ "Nincs."},
{ "100.00$"},
{ "Nincs."},
{ "1 Hét VIP tagság"},
{ "Nincs."},
{ "130 Képességpont"},
{ "Nincs."},
{ "100.00$"},
{ "Nincs."},
{ "10 PP"},
{ "Nincs."},
{ "15 Ajándékcsomag"},
{ "Nincs."},
{ "+1 Szint"},
{ "Nincs."},
{ "1 Red / Blue Knight emberskin"},
{ "Nincs."},
{ "1 Halas Red / Blue emberskin"}, //76LVL
{ "Nincs."},
{ "LEVEL MAXED"}
};
public DropSystem(id)
{
	new Float:RND = random_float(0.00, 10.00)

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
	new Float:NoDrop = 77.00;
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
					client_print_color(0, print_team_default, "^4%s ^3%s ^1Találta ezt: ^4%s^1 (Esélye ennek:^4%.2f%s^1)", PREFIX, Player[id][f_PlayerNames], LadaNevek[i][0], (fDropChance[i]/(fAllChance/100)), "%");
					
				}
				case 2:
				{
					LadaK[i][id]++;
					client_print_color(0, print_team_default, "^4%s ^3%s ^1Találta ezt: ^4%s^1 (Esélye ennek:^4%.2f%s^1)", PREFIX, Player[id][f_PlayerNames], LadaKNevek[i][0], (fDropChance[i]/(fAllChance/100)), "%");
				}
			}
		}
		Minfloat = MaxFloat;
	}
}
new const Admin_Permissions[][][] = {
	//Rang név | Jogok | Hozzáadhat-e admint? (0-Nem | 1-Igen)| Hozzáadhat-e VIP-t? (0-Nem | 1-Igen) | Bannolhat accot? 0 nem 1 igen
	{"Játékos", "z", "0", "0"}, //Játékos - 0
	{"Konfigos", "abcvnmlpoikujzhtgrfedwsayc", "1", "1"}, //Tulajdonos - 4
	{"Tulajdonos", "abcvnmlpoikujzhtgrfedwsayc", "1", "1"}, //Tulajdonos - 4
	{"SzuperAdmin", "abcvnmlpoikujzhtgrfedwsayc", "1", "1"}, //Tulajdonos - 4
	{"FőAdmin", "bmcfscdtiue", "4", "1"}, //FőAdmin - 3
	{"Admin", "bmcfscdtiue", "0", "0"}, //Admin - 2
	{"A szerver szépsége", "tie", "0", "0"} //Admin - 2
};

new const Float:FegyverLada1_drops[][] =
  {
		{6.0, 1.0 },
		{6.0, 1.0 },
		{6.0, 14.0 },
		{7.0, 3.0 },
		{6.0, 1.6 },
		{6.0, 20.0 },
		{10.0, 4.0 },
		{11.0, 12.0 },
		{15.0, 3.0 },
		{16.0, 10.0 },
		{18.0, 06.0 },
		{21.0, 65.0 },
		{22.0, 11.0 },
		{27.0, 75.0 },
		{31.0, 01.0 },
		{33.0, 01.0 },
		{34.0, 01.0 },
		{36.0, 4.0 },
		{38.0, 35.0 },
		{40.0, 61.0 },
		{43.0, 51.0 },
		{45.0, 71.0 },
		{48.0, 01.0 }
	};

new const Float:FegyverLada2_drops[][] =
  {
		{6.0, 1.0},
		{7.0, 14.0},
		{8.0, 3.0},
		{9.0, 4.0},
		{12.0, 2.0},
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
		{49.0, 1.0}
	};

new const Float:EzustLada_drops[][] =
  {
  	{7.0, 1.0 },
  	{6.0, 1.0 },
  	{9.0, 3.0 },
  	{12.0, 3.0 },
  	{8.0, 4.0 },
  	{7.0, 7.0 },
  	{8.0, 3.0 },
  	{9.0, 4.0 },
  	{10.0, 4.0 },
  	{11.0, 6.0 },
  	{12.0, 2.0 },
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
  	{40.0, 5.0 },
  	{43.0, 3.0 },
  	{44.0, 4.0 },
  	{45.0, 4.0 },
  	{46.0, 2.0 },
  	{47.0, 6.0 },
  	{49.0, 1.0 },
  	//-----------------knifes
  	{51.0, 0.01 },
  	{52.0, 0.060 },
  	{53.0, 0.01 },
  	{54.0, 0.02 },
  	{55.0, 0.01 },
  	{56.0, 0.01 },
  	{57.0, 0.02 },
  	{58.0, 0.01 },
  	{59.0, 0.02 },
  	{60.0, 0.05 },
  	{61.0, 0.01 },
  	{62.0, 0.03 },
  	{63.0, 0.07 }
	};

new const Float:AranyLada_drops[][] =
  {
  	{6.0, 1.0 },
  	{6.0, 1.0 },
  	{9.0, 3.0 },
  	{12.0, 3.0 },
  	{8.0, 4.0 },
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
  	{40.0, 5.0 },
  	{43.0, 3.0 },
  	{44.0, 4.0 },
  	{45.0, 4.0 },
  	{46.0, 2.0 },
  	{47.0, 6.0 },
  	{49.0, 1.0 },
  	{51.0, 0.04 },
  	{52.0, 0.02 },
  	{53.0, 0.03 },
  	{54.0, 0.05 },
  	{55.0, 0.06 },
  	{56.0, 0.04 },
  	{57.0, 0.04 },
  	{58.0, 0.05 },
  	{59.0, 0.06 },
  	{60.0, 0.04 },
  	{61.0, 0.02 },
  	{62.0, 0.01 },
  	{63.0, 0.05 }
	};

new const Float:GyemantLada_drops[][] =
  {
  	{6.0, 1.0 },
  	{6.0, 1.0 },
  	{9.0, 3.0 },
  	{12.0, 3.0 },
  	{8.0, 4.0 },
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
  	{40.0, 5.0 },
  	{43.0, 3.0 },
  	{44.0, 4.0 },
  	{45.0, 4.0 },
  	{46.0, 2.0 },
  	{49.0, 1.0 },
	{51.0, 0.04 },
  	{52.0, 0.02 },
  	{53.0, 0.03 },
  	{54.0, 0.05 },
  	{55.0, 0.04 },
  	{56.0, 0.03 },
  	{57.0, 0.04 },
  	{58.0, 0.05 },
  	{59.0, 0.06 },
  	{60.0, 0.04 },
  	{61.0, 0.02 },
  	{62.0, 0.01 },
  	{63.0, 0.04 },
	{75.0, 0.02 },
  	{76.0, 0.04 },
  	{77.0, 0.05 },
  	{78.0, 0.06 },
  	{79.0, 0.03 },
  	{74.0, 0.02 }
  };

new const Float:PremiumLada_drops[][] =
  {
  	{6.0, 1.0 },
  	{6.0, 1.0 },
  	{8.0, 3.0 },
  	{7.0, 3.0 },
  	{9.0, 4.0 },
  	{10.0, 4.0 },
  	{12.0, 2.0 },
  	{15.0, 3.0 },
  	{24.0, 4.0 },
  	{32.0, 3.0 },
  	{36.0, 4.0 },
  	{43.0, 3.0 },
  	{44.0, 4.0 },
  	{45.0, 4.0 },
  	{46.0, 2.0 },
  	{49.0, 1.0 },
  	{51.0, 0.04 },
  	{52.0, 0.02 },
  	{53.0, 0.03 },
  	{54.0, 0.05 },
  	{55.0, 0.06 },
  	{56.0, 0.02 },
  	{57.0, 0.04 },
  	{58.0, 0.05 },
  	{59.0, 0.06 },
  	{60.0, 0.03 },
  	{61.0, 0.02 },
  	{62.0, 0.01 },
  	{63.0, 0.04 },
	{75.0, 0.02 },
  	{76.0, 0.04 },
  	{77.0, 0.05 },
  	{78.0, 0.06 },
  	{79.0, 0.03 },
};
new const Float:ChristmasLada_drops[][] =
  {
  	{51.0, 0.04 },
  	{52.0, 0.04 },
  	{53.0, 0.04 },
  	{54.0, 0.04 },
  	{55.0, 0.04 },
  	{56.0, 0.04 },
  	{57.0, 0.04 },
  	{58.0, 0.04 },
  	{59.0, 0.04 },
  	{60.0, 0.04 },
  	{61.0, 0.04 },
  	{62.0, 0.04 },
  	{63.0, 0.04 },
  	{64.0, 0.04 },
  	{65.0, 0.04 },
  	{66.0, 0.05 },
  	{67.0, 0.04 },
  	{68.0, 0.04 },
  	{69.0, 0.04 },
  	{70.0, 0.03 },
  	{71.0, 0.01 },
  	{72.0, 0.02 },
  	{73.0, 0.04 },
  };
new const Float:Versus_drops[][] =
  {
	{75.0, 0.03 },
  	{76.0, 0.04 },
	{77.0, 0.01 },
	{78.0, 0.02 },
	{79.0, 0.03 },

	{94.0, 0.5 },
  	{95.0, 1.0 },
	{96.0, 2.0 },
	{98.0, 0.7 },
	{99.0, 0.5 },
	{100.0, 1.0 },
	{101.0, 3.0 },
	{102.0, 0.8 },
	{103.0, 4.0 },
	{104.0, 2.5 },

  	{105.0, 1.0 },
  	{106.0, 0.9 },
  	{107.0, 0.1 },
  	{108.0, 3.0 },
	{109.0, 4.0 },
  	{110.0, 1.5 },
  	{111.0, 0.8 },
  	{112.0, 2.1 },
	{113.0, 4.1 },
  };

enum _:RangAdatok {
	RangName[32],
	ELO[8]
}
new const Rangok[][RangAdatok] = {
	{"Unranked", 0},
	{"Silver I", 400},
	{"Silver II", 800},
	{"Silver III", 1500},
	{"Silver IV", 2200},
	{"Silver Elite", 3300},
	{"Silver Elite Master", 5500},
	{"Gold Nova I", 8500},
	{"Gold Nova II", 11250},
	{"Gold Nova III", 13100},
	{"Gold Nova Master", 15000},
	{"Master Guardian I", 18520},
	{"Master Guardian II", 19930},
	{"Master Guardian Elite", 23500},
	{"Distinguished MG", 29320},
	{"Legendary Eagle", 46000},
	{"Legendary Eagle Master", 67300},
	{"Supreme Master First Class", 86000},
	{"The Global Elite", 112300}
}
enum _:PrivateAdatok {
	RangName[32],
	Kills[8]
}
new const PrivateRanks[][PrivateAdatok] = {
	{"Recruit Rank 0", 0},
	{"Private Rank 1", 30},
	{"Private Rank 2", 60},
	{"Private Rank 3", 90},
	{"Private Rank 4", 130},
	{"Corporal Rank 5", 200},
	{"Corporal Rank 6", 250},
	{"Corporal Rank 7", 300},
	{"Corporal Rank 8", 350},
	{"Sergeant Rank 9", 400},
	{"Sergeant Rank 10", 500},
	{"Sergeant Rank 11", 700},
	{"Sergeant Rank 12", 900},
	{"Master Sergeant Rank 13", 1100},
	{"Master Sergeant Rank 14", 1350},
	{"Master Sergeant Rank 15", 1700},
	{"Master Sergeant Rank 16", 2100},
	{"Sergeant Major Rank 17", 2600},
	{"Sergeant Major Rank 18", 3200},
	{"Sergeant Major Rank 19", 4},
	{"Sergeant Major Rank 20", 30},
	{"Lieutenant Rank 21", 60},
	{"Lieutenant Rank 22", 90},
	{"Lieutenant Rank 23", 130},
	{"Lieutenant Rank 24", 200},
	{"Captain Rank 25", 250},
	{"Captain Rank 26", 300},
	{"Captain Rank 27", 350},
	{"Captain Rank 28", 400},
	{"Major Rank 29", 500},
	{"Major Rank 30", 700},
	{"Major Rank 31", 900},
	{"Major Rank 32", 1100},
	{"Colonel Rank 33", 1350},
	{"Colonel Rank 34", 1700},
	{"Colonel Rank 35", 2100},
	{"Brigadier General Rank 36", 2600},
	{"Major General Rank 37", 3200},
	{"Lieutenant General Rank 38", 1700},
	{"General Rank 39", 2100},
	{"Global General Rank 40", 2600},
	{"--- Give Service Medal ---", 888888},
}

public systiime(id)
{
	client_print_color(id, print_team_default, "%d", get_systime())
}
public SetErem(id)
{
	Equipmented_Erem[id] = 5
}
public ERemke(id)
{
	AddErem(id, 5 ,1)
}
public TerrorsWin() {
	g_TEWins++;
}
public CTerrorsWin() {
	g_CTWins++;
}
public giveusp(id)
{
	give_item(id, "weapon_usp");
	cs_set_user_bpammo(id,CSW_USP,50);
}
public Attack_AutomaticGun(ent)
{
  static id; id = pev(ent, 18);

  Player_Stats[id][AllShotCount]++;

  return HAM_IGNORED;
}

public Attack_SingleShotGun(ent)
{
  static id; id = pev(ent, 18);

  Player_Stats[id][AllShotCount]++;
  
  return HAM_IGNORED;
}

public PlayerGetHit(victim, inflictor, attacker, Float:damage, bits)
{
  if(!(bits & DMG_BULLET))
    return HAM_IGNORED;
  
  Player_Stats[attacker][AllHitCount]++;
  return HAM_IGNORED;
}
public vipcheck(id)
{
	new sztime[40], szvtime[40]
	format_time(sztime, charsmax(sztime), "%Y.%m.%d - %H:%M:%S", g_VipTime[id])
	format_time(szvtime, charsmax(szvtime), "%Y.%m.%d - %H:%M:%S", Vip[id][PremiumTime])
	client_print_color(0, print_team_default, "^4[DEBUG] ^1Játékosnév: ^4%s^1 Vip: %i Pvip: %i VIPLejárat: %s PVIP Lejárat: %s", Player[id][f_PlayerNames], g_Vip[id], Vip[id][isPremium], sztime, szvtime)
}

public plugin_natives()
{
  register_native("add_user_reward", "native_add_user_reward",1);
  register_native("get_keyname", "native_get_keyname",1);
  register_native("get_casename", "native_get_casename",1);
  register_native("get_level", "native_get_level",1);
}
public native_add_user_reward(Index, Float:Money, Keys, Keynum, Cases, Casenum)
{
  Mission_Reward(Index, Float:Money, Keys, Keynum, Cases, Casenum);
}
public native_get_keyname(k_id, KeyName[32])
{
	copy(KeyName, 32, LadaKNevek[k_id][0]);
	return KeyName;
}
public native_get_casename(c_id, CaseName[32])
{
	copy(CaseName, 32, LadaNevek[c_id][0]);
	return CaseName;
}
public native_get_level(id)
{
	return Player[id][SSzint];
}

public stopfrag(id)
{
	Fragverseny = 0;
	client_print_color(id, print_team_default, "^4%s^1 A fragversenyt egy Admin Leállította.", PREFIX)
}

public eremadd(id)
{
	new ermek = sizeof(g_Ermek);
	for(new i = 1;i < ermek; i++)
	Erem[i][id]++;
	
}
public automatikusfrag()
{
    new hour, minute, second;
    time(hour, minute, second);

    if(Fragverseny != 0)
		return;
	
	if(hour == 12 && minute == 00)
	{
		Fragverseny = 1;
		Frags++;
		Fragkorok = 40;
		server_cmd("sv_restart 1");
		SetNyeremeny();
	}
	else if(hour == 17 && minute == 00)
	{
		Fragverseny = 1;
		Frags++;
		Fragkorok = 40;
		server_cmd("sv_restart 1");
		SetNyeremeny();
	}
	else if(hour == 20 && minute == 00)
	{
		Fragverseny = 1;
		Frags++;
		Fragkorok = 40;
		server_cmd("sv_restart 1");
		SetNyeremeny();
	}
}
public ujkor()
{
	setVip();
	cmdTopByKills();
	Load_Data_15("PlayerStats", "TablaAdatValasztas15_PlayerStats");
	LoadAdmins();
	new id, count;
	new Players[32], iNum;
	new sTime[9], sDate[11], sDateAndTime[32];
	new players[32], num, i, Len, StringC[128], RankUP, RankDown
	get_players(players, num);
	new year;
  	date(year);
	
	p_playernum = get_playersnum(1);
	get_time("%H:%M:%S", sTime, 8 );
	get_time("%Y/%m/%d", sDate, 11);
	formatex(sDateAndTime, 31, "%s %s", sDate, sTime);
	
	g_korkezdes += 1;

	if(Fragverseny)
		Fragkorok -= 1;
	
	get_players(Players, iNum, "ch");
	new Player1;
	for (new i=0; i<iNum; i++)
	{	
	Player1 = Players[i];
	if(is_user_connected(Player1))
		{
			Update_Player_Stats(Player1);
		}
	}

	for(id = 0 ; id <= g_Maxplayers ; id++) 
		if(is_user_connected(id)) 
		if(get_user_flags(id) & ADMIN_KICK) 
		count++;
	
	client_print_color(0, print_team_default, "^4%s^3 Kör: ^4%d^1/^4%d ^1| ^3Játékosok: ^4%d^1/^4%d^1 | Idő: ^4%s ^1| ^3Jelenlévő Adminok: ^4%d", PREFIX, g_korkezdes, get_pcvar_num(maxkor), p_playernum, g_Maxplayers, sDateAndTime, count); 
	
	if(g_korkezdes >= get_pcvar_num(maxkor))
	{
		Cuccmolek();
		Update_fragers();
	}
	if(Fragkorok == 1 && Fragverseny == 1)
	{
		EndTheFrag();
		Fragverseny = 0;
	}
	Load_Data_SMS("__syn_payments", "QuerySelectSMS")
	fragonroundstart();
}

public Cuccmolek()
{
	new players[32], num, i, RankDown,RankUP, Win, Lose, rankolas = sizeof(Rangok)
	get_players(players, num);
	new year
	date(year)
	new StringC[128], iLen
	
	for(new id = 1; id < g_Maxplayers; id++)
	{
		if(g_TEWins > g_CTWins && get_user_team(id) == CS_TEAM_T) 
		{
			Wins[id]++

			Win = 1
			eloELO[id] += 8*PlayedCount[id];
			eloXP[id] += 9.1*PlayedCount[id];
		}
		else if(g_CTWins > g_TEWins && get_user_team(id) == CS_TEAM_CT) 
		{
			Wins[id]++
			
			Win = 1
			eloELO[id] += 8*PlayedCount[id];
			eloXP[id] += 9.1*PlayedCount[id];
		}
		else if(g_CTWins == g_TEWins) 
		{
			Wins[id]++

			Win = 1
			eloELO[id] += 13*PlayedCount[id];
			eloXP[id] += 13.0*PlayedCount[id];
		}

		if(g_TEWins < g_CTWins && get_user_team(id) == CS_TEAM_T) 
		{
			Lose = 1
			eloELO[id] -= 4*PlayedCount[id]
			eloXP[id] += 5.6*PlayedCount[id];
		}
		else if(g_CTWins < g_TEWins && get_user_team(id) == CS_TEAM_CT) 
		{
			Lose = 1
			eloELO[id] -= 4*PlayedCount[id]
			eloXP[id] += 5.6*PlayedCount[id];
		}
		//eloELO[id] += rELO[id];
		//eloXP[id] += rXP[id];
		if(Win)
		{
			rELO[id] += eloELO[id];
			rXP[id] += eloXP[id];
		}
		else if(Lose)
		{
			rELO[id] -= eloELO[id];
			rXP[id] += eloXP[id];
		}

		for(new y;y < rankolas; y++) 
		{
			if(Wins[id] > 4)
			{
				if(rELO[id] >= Rangok[y][ELO] && rELO[id] < Rangok[y+1][ELO]) 
				{
					if(Rang[id] == 18)
					{
						client_print_color(id, print_team_default, "^4[DEBUG] ^1Elérted a maximum Rangot!")
					}
					else 
					{
						Rang[id] = y+1;
						RankUP = 1;
					}	
				}
			}


			if(rXP[id] >= 5000.00)		
			{
				Player[id][SSzint]++;
				rXP[id] -= 5000.00;

				if(BattlePassPurchased[id])
					battlepass_szint[id]++;

				switch(battlepass_szint[id])
				{
					case 2: g_dollar[id] += 5.00
					case 4: g_dollar[id] += 10.00
					case 6: Ajandekcsomag[id]++;
					case 8: g_dollar[id] += 10.00
					case 10: rXP[id] += 25.00
					case 12: g_dollar[id] += 15.00
					case 14: Ajandekcsomag[id]++;
					case 16: g_Tools[0][id]++
					case 18: g_Tools[1][id]++
					case 20: g_dollar[id] += 10.00
					case 22: g_VipTime[id] += 14400;
					case 24: rXP[id] += 25.00
					case 26: g_dollar[id] += 30.00 
					case 28: premiumpont[id] += 10;
					case 30: Ajandekcsomag[id]+=5;
					case 32: rXP[id] += 50.00
					case 34: g_Tools[0][id]++
					case 36: g_Tools[1][id]++
					case 38: g_dollar[id] += 60.00
					case 40: premiumpont[id] += 10
					case 42: Ajandekcsomag[id]+=5;
					case 44: g_dollar[id] += 80.00
					case 46: rXP[id] += 80.00
					//case 48: BlackIceOwner[id]++;
					//case 50: CannabisLifeOwner[id]++;
					case 52: g_Tools[0][id]+=5
					case 54: g_Tools[1][id]+=5
					case 56: g_dollar[id] += 10.00
					case 58: g_VipTime[id] += 10800;
					//case 60: kepessegpont[id] += 25
					case 62: g_dollar[id] += 100.00
					case 64: premiumpont[id] += 10
					case 66: Ajandekcsomag[id]+=15;
					case 68: rXP[id] += 99.99;
					case 70: client_print_color(id, print_team_default, "Irj rá a tulajdonosra!")
					case 72: client_print_color(id, print_team_default, "Irj rá a tulajdonosra!")

					//default: client_print_color(id, print_team_default, "%s ^1Ezért a szintért nem kapsz jutalmat!", PREFIX)
				}
			}
			if(Player[id][SSzint] > 40)
			{
				Player[id][SSzint] = 0;
				
				if(year == 2020)
				{
					if(Erem[7][id] == 0)
						AddErem(id, 7, 4)
					else if(Erem[7][id] > 0)
						AddErem(id, 15, 4)
					else if(Erem[15][id] == 0)
						AddErem(id, 15, 4)
					else if(Erem[15][id] > 0)
						AddErem(id, 16, 4)
					else if(Erem[16][id] == 0)
						AddErem(id, 16, 4)
					else if(Erem[16][id] > 0)
						AddErem(id, 17, 4)
					else if(Erem[17][id] == 0)
						AddErem(id, 17, 4)
					else if(Erem[18][id] > 0)
						AddErem(id, 18, 4)
				}
				else if (year == 2021)
					AddErem(id, 8, 4)
			}
		
		}	
		set_dhudmessage(0, 127, 255, -1.0, 0.18, 2, 6.0, 10.0)
		show_dhudmessage(id, "PROFIL RANK:^n[ %s | %3.2f / 5000 ]^n^nSKILL FOKOZAT:^n[ %s ]^n^n%d nyert meccs.", PrivateRanks[Player[id][SSzint]][RangName], rXP[id], Rangok[Rang[id]][RangName], Wins[id])

	}
	set_task(10.0, "kor")
}
public SetNyeremeny()
{
	FragJutalmak1 = random(12)
	FragJutalmak2 = random(9)
	FragJutalmak3 = random(7)

	client_print_color(0, print_team_default, "^3[DEBUG]^1 Első hely: ^3%s^4 | ^1Második hely: ^3%s^4 | ^1Harmadik hely: ^3%s", JutalmakFrag1[FragJutalmak1], JutalmakFrag2[FragJutalmak2], JutalmakFrag3[FragJutalmak3])
}
public fragonroundstart()
{
    if(Fragverseny)
	{
		client_print_color(0, print_team_default, "^3[DEBUG]^1 Első hely: ^3%s^4 | ^1Második hely: ^3%s^4 | ^1Harmadik hely: ^3%s", JutalmakFrag1[FragJutalmak1], JutalmakFrag2[FragJutalmak2], JutalmakFrag3[FragJutalmak3])
		client_print_color(0, print_team_default, "^3[DEBUG]^1 Jelenleg ^3automatikus^1 fragverseny van, tart még ^4%i^1 körig!", Fragkorok);
	}
    else
        client_print_color(0, print_team_default, "^3[DEBUG]^1 Jelenleg nincs fragverseny! %s", LastFrags[Frags]);
}
public htmltest(id)
{
	new len, StringMotd[512], a[128], String[128];
	a = "https://edsms.netfizetes.hu/?pa=2503&pr=SILVERHOST&n=1&t=312%208543";

	len += formatex(StringMotd[len], charsmax(StringMotd) - len, "<!DOCTYPE html> <html><head><meta charset=^"UTF-8^">");
	len += formatex(StringMotd[len], charsmax(StringMotd) - len, "</head><body style=^"background-color: rgb(100, 100, 100);^">");
	len += formatex(StringMotd[len], charsmax(StringMotd) - len, "<a href=^"%s^">asd</a>",a);

	formatex(String, charsmax(String), "%s | Láda tartalom", PREFIX);
	show_motd(id, StringMotd, String);
}
public nyeremenyjatek()
{
	
	client_print_color(0, print_team_default, "^3%s ^4---------------| ^3NYEREMÉNYJÁTÉK^4 |---------------", PREFIX);
	client_print_color(0, print_team_default, "^3%s^1 » ^1Első hely: ^4Steames PUBG Account ^3|^1 Második: ^4Gamer Egér", PREFIX);
	client_print_color(0, print_team_default, "^3%s^1 » ^1Harmadik hely:^4 1 Hónap Prémium VIP", PREFIX);
	client_print_color(0, print_team_default, "^3%s^1 »^4 2020.08.25 06:00^1-tól!^3 2020.09.25 20:00-ig! ^1Nyereménylista: ^4/oles", PREFIX);
	client_print_color(0, print_team_default, "^3%s ^4---------------| ^3NYEREMÉNYJÁTÉK^4 |---------------", PREFIX);
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
public CheckIdMenu(id) {
	new cim[121], Menu, Sor[6];
	Menu = menu_create("\dAccount Id-k", "CheckIdMenuHandler");
	
	for(new i; i <= g_Maxplayers; i++){
		if(!is_user_connected(i))
			continue;
			
		num_to_str(i, Sor, 5);
		
		formatex(cim, charsmax(cim), "\w%s \d(#%d)", Player[i][f_PlayerNames], g_Id[i]);
			
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
public ShowAdminsMenu(id) {
	new MenuTitle[121], cim[121], Menu, Sor[6], bArraySize = ArraySize(g_Admins), Data[AdminData];
	
	if(bArraySize < 1){
		client_printcolor(id, "%s Nincs egy admin adat sem betöltve! Próbáld meg újra később!", PREFIX);
		return PLUGIN_HANDLED;
	}
	format( MenuTitle, charsmax( MenuTitle ), "\d[Dark*.*Angel'S] ~ \yOnly Dust2 \d|\w Admin Lista^n\wOldal:\r%s", bArraySize > 7 ? "" : " 1/1");
	
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
	new Menu[512], Len, Data[AdminData];
	
	ArrayGetArray(g_Admins, i, Data);

	Len += formatex(Menu[Len], charsmax(Menu) - Len, "\d[Dark*.*Angel'S] ~ \yOnly Dust2 \d|\w Admin Lista^n^n");
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

	formatex(Query, charsmax(Query), "SELECT * FROM `Profiles` WHERE `Admin_Szint` > 0;");
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
			SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "gamename"), Data[Name], 31);
			Data[Permission] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Admin_Szint"));
			ArrayPushArray(g_Admins, Data);
			
			SQL_NextRow(Query);
		}
	}
}

public Spawn(id) 
{
	if(!is_user_alive(id)) 
	{
		return PLUGIN_HANDLED;
	}
	//mentes(id);
	CheckErem(id);
	PlayedCount[id]++;
	SetModels(id);
	//g_MVPoints[id] = 0;
	g_Awps[TE] = 0;
	g_Awps[CT] = 0;
	Buy[id] = 0 ;
	remove_task(id);
	strip_user_weapons(id);
	vipellenorzes(id);

	fegyvermenu(id);

	give_item(id, "weapon_hegrenade");
	give_item(id, "weapon_flashbang");
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
			new Float:dollardrop = random_float(0.01, 0.20);
			g_dollar[id] += dollardrop;
			client_print_color(0, print_team_default, "%s ^1Játékos: ^4%s^1 felvett egy ^3ládát^1, és talált benne ^4%3.2f^1 dollárt.", PREFIX, szName, dollardrop);
		}
		case 2:
		{
			new pontdrop = random_num(0, 10);
			Darkpont[id] += pontdrop;
			client_print_color(0, print_team_default, "%s ^1Játékos: ^4%s^1 felvett egy ^3ládát^1, és talált benne ^4%3.2f^3 Dark ^1Pontot.", PREFIX, szName, pontdrop);
		}
		case 3: 
		{
			new lada = random_num(0, 5);
			Lada[lada][id]++;
			client_print_color(0, print_team_default, "%s ^1Játékos: ^4%s^1 felvett egy ^3ládát^1, és talált benne ^4%s^1 ládát.", PREFIX, szName, LadaNevek[lada]);
		}
		case 4: 
		{
			new lada = random_num(0, 5);
			LadaK[lada][id]++;
			client_print_color(0, print_team_default, "%s ^1Játékos: ^4%s^1 felvett egy ^3ládát^1, és talált benne ^4%s^1 ládakulcsot.", PREFIX, szName, LadaKNevek[lada]);
		}
		case 5: 
		{
			new fegyo = random_num(5, 50);
			g_Weapons[fegyo][id]++;
			client_print_color(0, print_team_default, "%s ^1Játékos: ^4%s^1 felvett egy ^3ládát^1, és talált benne ^4%s^1 fegyvert.", PREFIX, szName, FegyverInfo[fegyo][GunName]);
		}
		case 6:
		{
			new esely = random_num(1,100)
			{
				if(esely >= 97) 
				{
					client_print_color(0, print_team_default, "%s ^1Játékos: ^4%s^1 felvett egy ^3ládát^1, és talált benne egy ^3StatTrak* Tool^1-t! (^3Esélye ennek:^4 3.00%s^1)", PREFIX, szName, "%");
					g_Tools[0][id]++;
					client_cmd(0,"spk ambience/thunder_clap");
				}
				if(esely <= 5)
				{
					g_Tools[1][id]++;
					client_cmd(0,"spk ambience/thunder_clap");
					client_print_color(0, print_team_default, "%s ^1Játékos: ^4%s^1 felvett egy ^3ládát^1, és talált benne egy ^3Névcédulá^1-t! (^3Esélye ennek:^4 4.00%s^3)", PREFIX, szName, "%");
				}
				else
				{
					client_print_color(0, print_team_default, "%s ^1Játékos: ^4%s^1 felvett egy ^3ládát^1, és majdnem talált benne, ^3Névcédulát,^1 vagy ^3StatTrak* Toolt!", PREFIX, Player[id][f_PlayerNames]);
				}
			}		
		}
		case 7: 
		{
			new esely = random_num(1,100)
			new kes = random_num (51, 73)
			{
				if(esely >= 98) 
				{
					client_print_color(0, print_team_default, "%s ^1Játékos: ^4%s^1 felvett egy ^3ládát^1, és talált benne egy ^3%s^4! (^3Esélye ennek:^4 2.00%s^1)", PREFIX, szName, FegyverInfo[kes][GunName], "%");
					g_Weapons[kes][id]++;
					client_cmd(0,"spk ambience/thunder_clap");
				}
				else
				{
					client_print_color(0, print_team_default, "%s ^1Játékos: ^4%s^1 felvett egy ^3ládát^1, és majdnem talált benne, ^3%s^4!^1 Te igazi szerencsétlen :(", PREFIX, szName, FegyverInfo[kes][GunName]);
				}
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
	new iras[121], String[121], itemNum;
	format(iras, charsmax(iras), "\y%s^nFőmenü", MENUPREFIX);
	new menu = menu_create(iras, "T_Betu_h");

	if(itemNum > 0) format(String,charsmax(String),"\y[\wRaktár\y] "); // \r[\wRaktár\r]
	else format(String,charsmax(String),"\y[\wRaktár\y]");
	menu_additem(menu,String,"1");
	menu_additem(menu, "\y[\wLáda Nyitás\y]", "2", 0);
	menu_additem(menu, "\y[\wPiac \rBéta\y]", "4", 0);
	if(g_Quest[id] == 0) format(String,charsmax(String),"\y[\wKüldetések\y]");
	else format(String,charsmax(String),"\y[\wKüldetések\y] \w- \rFolyamatban");
	menu_additem(menu,String,"3");
	menu_additem(menu, "\y[\wBeállítások\y]", "5", 0);
	menu_additem(menu, "\y[\wPrémium Bolt\r *ÚJ\y]", "6", 0);
	menu_additem(menu, "\y[\wÁruház / Zenekészlet!\y]", "7", 0);
	menu_additem(menu, "\y[\wBattlePass\y]\w", "8", 0);
	menu_additem(menu, "\y[\wÉrdem Érmek\y]\w", "9", 0);
	menu_additem(menu, "\y[\wJátékos Némítás\y]\w", "10", 0);
	//FegyverInfo[Selectedgun[AK47][id]][i][FegyverNev]
	
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

	new randomWeapon = random_num(0,10);
	new randomHead = random_num(0,1);

	new randomKills;
	new Float:randomDollar;
	switch(randomWeapon)
	{
		case 0:
		{
			if(randomHead)
			{
				randomKills = random_num(20,40)
				randomDollar = random_float(20.00,40.00)

			}
			else
			{
				randomKills = random_num(40,120)
				randomDollar = random_float(20.00,60.00)
				if(randomKills == 120)
				client_print_color(0, print_team_default, "^4%s ^1Játékos: ^3%s^1 megütötte a jackpotot,^3 120^1 küldetés öléssel", PREFIX, Player[id][f_PlayerNames]);
			}
		}
		case 1:
		{
			if(randomHead)
			{
				randomKills = random_num(20,40)
				randomDollar = random_float(20.00,40.00)

			}
			else
			{
				randomKills = random_num(40,120)
				randomDollar = random_float(20.00,60.00)
				if(randomKills == 120)
				client_print_color(0, print_team_default, "^4%s ^1Játékos: ^3%s^1 megütötte a jackpotot,^3 120^1 küldetés öléssel", PREFIX, Player[id][f_PlayerNames]);
			}
		}
		case 2:
		{
			if(randomHead)
			{
				randomKills = random_num(5, 10)
				randomDollar = random_float(10.00,30.00)

			}
			else
			{
				randomKills = random_num(10,30)
				randomDollar = random_float(20.00,40.00)
			}
		}
		case 3:
		{
			if(randomHead)
			{
				randomKills = random_num(10, 20)
				randomDollar = random_float(10.00,30.00)

			}
			else
			{
				randomKills = random_num(10,30)
				randomDollar = random_float(20.00,40.00)
			}
		}
		case 4:
		{
			if(randomHead)
			{
				randomKills = random_num(10, 20)
				randomDollar = random_float(10.00,30.00)

			}
			else
			{
				randomKills = random_num(10,30)
				randomDollar = random_float(20.00,40.00)
			}
		}
		case 5:
		{
			if(randomHead)
			{
				randomKills = random_num(10, 20)
				randomDollar = random_float(10.00,30.00)

			}
			else
			{
				randomKills = random_num(10,30)
				randomDollar = random_float(20.00,40.00)
			}
		}
		case 6:
		{
			if(randomHead)
			{
				if(Player[id][SSzint] > 2)
				{
					randomKills = random_num(5, 15)
					randomDollar = random_float(10.00,30.00)
				}
				else 
				{
					randomKills = random_num(5, 10)
					randomDollar = random_float(10.00,25.00)
				}

			}
			else
			{
				randomKills = random_num(10,20)
				randomDollar = random_float(10.00,20.00)
			}
		}
		case 7:
		{
			if(randomHead)
			{
				randomKills = random_num(5, 15)
				randomDollar = random_float(10.00,30.00)
			}
			else
			{
				randomKills = random_num(5, 25)
				randomDollar = random_float(10.00,20.00)
			}
		}
		case 8:
		{
			if(randomHead)
			{
				randomKills = random_num(5, 20)
				randomDollar = random_float(10.00,20.00)
			}
			else
			{
				randomKills = random_num(5, 30)
				randomDollar = random_float(10.00,20.00)
			}
		}
		case 9:
		{
			if(randomHead)
			{
				randomKills = random_num(5, 30)
				randomDollar = random_float(10.00,40.00)
			}
			else
			{
				randomKills = random_num(5, 40)
				randomDollar = random_float(10.00,30.00)
			}
		}
		case 10:
		{
			if(randomHead)
			{
				randomKills = random_num(40, 100)
				randomDollar = random_float(10.00,70.00)
				if(randomKills == 100)
				client_print_color(0, print_team_default, "^4%s ^1Játékos: ^3%s^1 megütötte a jackpotot,^3 100^1 küldetés öléssel", PREFIX, Player[id][f_PlayerNames]);

			}
			else
			{
				randomKills = random_num(40, 150)
				randomDollar = random_float(10.00,90.00)
				if(randomKills == 150)
				client_print_color(0, print_team_default, "^4%s ^1Játékos: ^3%s^1 megütötte a jackpotot,^3 150^1 küldetés öléssel", PREFIX, Player[id][f_PlayerNames]);

			}
		}
	}
	
	new randomCase = random_num(0,2);
	new randomST = random_num(1,2);
	new randomNC = random_num(1,2);
	new randomKey = random_num(0,4);
	new randomPremium = random_num(10,100);
	
	switch(key)
	{
		case 1: BeallitasEloszto(id);
		case 2: openLadaNyitas(id);
		case 3: //MissionMenu(id);
		
		{ 
		
		if(g_Quest[id] == 0)
			{
				g_QuestKills[0][id] = randomKills;
				g_QuestWeapon[id] = randomWeapon;
				g_QuestHead[id] = randomHead;
				g_Jutalom[0][id] = randomCase;
				g_Jutalom[1][id] = randomKey;
				g_Jutalom[2][id] = randomPremium;
				new esely = random_num(1,100)
				{
					if(esely >= 95) 
					{
					g_Jutalom[3][id] = randomST;
					}
					if(esely <= 10)
					{
					g_Jutalom[4][id] = randomNC;
					}
				}				
				g_dollarjutalom[id] = randomDollar;
				g_Quest[id] = 1;
				openQuestMenu(id);
			}
			else
			{
				openQuestMenu(id);
			}
			

		}
		
		case 4: Piac(id);
		case 5: openStatus(id);
		case 6: m_PremiumBolt(id);
		case 7: m_Bolt(id);
		case 8: BattlePassMenu(id);
		case 9: m_EremMenu(id);
		case 10: client_cmd(id, "say /mute");
	}
}
public MissionMenu(id)
{

}
public openLadaNyitas(id)
{
new String[121];
format(String, charsmax(String), "%s ^nLádaNyitás", MENUPREFIX);
new menu = menu_create(String, "Lada_h");
new ladasos = sizeof(LadaNevek);

for(new i;i < ladasos; i++)
{
	new Sor[6]; num_to_str(i, Sor, 5);
	formatex(String, charsmax(String), "%s \d| \y%i\rDB \d| \yKulcs: \r%i", LadaNevek[i][0], Lada[i][id], LadaK[i][id]);
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
		client_print_color(id, print_team_default, "%s ^1Nincs Ládád vagy kulcsod.", PREFIX);
	}
}

public Chat_Prefix_Hozzaad(id){
	new Data[32];
	read_args(Data, charsmax(Data));
	remove_quotes(Data);
	
	new hosszusag = strlen(Data);
	
	if(hosszusag <= 8 && hosszusag > 0){
		format(g_Chat_Prefix[id], 32, "%s", Data);
		VanPrefix[id]++;
		g_dollar[id] -= 100;
		client_print_color(id, print_team_default, "%s Vettél egy prefixet! Semmi csúnya, és adminhoz tartozó‚ dolgot ne írj!", PREFIX);
	}
	else{
		client_print_color(id, print_team_default, "%s A Prefix legfeljebb^3 8^1 karakterből állhat!", PREFIX);
	}
	return PLUGIN_CONTINUE;
}
public m_EremMenu(id)
    {
	new String[520];
	formatex(String, charsmax(String), "%s \r- \dÉrdemérem Menü", MENUPREFIX);
	new menu = menu_create(String, "m_EremMenu_h");
	new ermes = sizeof(g_Ermek)
	
	for(new i;i < ermes; i++)
	{
		if(Erem[i][id] >= 1)
		{
			new Sor[6]; num_to_str(i, Sor, 5);
			formatex(String, charsmax(String), "\w%s", g_Ermek[i]);
			menu_additem(menu, String, Sor);
		}
	}
	
	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
    }
public m_EremMenu_h(id, menu, item)
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

    Menu_EremSelected[id] = key;
    EremInfo(id);
    
}
public EremInfo(id)
{
	new String[1026];
	formatex(String, charsmax(String), "\r%s",MENUPREFIX);
	new menu = menu_create(String, "EremInfo_h");

	formatex(String, charsmax(String), "\wÉrem: \r%s", g_Ermek[Menu_EremSelected[id]][erem_name]);
	menu_addtext2(menu, String);

	formatex(String, charsmax(String), "\wInfó:");
	menu_addtext2(menu, String);

	formatex(String, charsmax(String), "\y%s", g_Ermek[Menu_EremSelected[id]][erem_text]);
	menu_addtext2(menu, String);

	formatex(String, charsmax(String), "\rKitűzés");
	menu_additem(menu, String, "0", 0);

	menu_setprop(menu, MPROP_EXITNAME, "Kilépés");

	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}

public EremInfo_h(id, menu, item)
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
        Equipmented_Erem[id] = Menu_EremSelected[id]
		//client_print_color(id, print_team_default, "^4[DEBUG] ^1Sikeresen kitűzted a ^3%s^1-t.", g_Ermek[Equipmented_Erem[id]][erem_name])
    }
   
  }
  menu_destroy(menu);
}
public m_PremiumBolt(id)
{
	new String[121];
	formatex(String, charsmax(String), "%s \r- \dPrémium Bolt^n\yPrémium Pontok: \d%i", MENUPREFIX, premiumpont[id]);
	new menu = menu_create(String, "m_PremiumBolt_h");
	
	menu_additem(menu, "PP Vásárlás \rSMS", "1", 0)
	menu_additem(menu, "PP Vásárlás \rPayPal", "2", 0)
	menu_additem(menu, "1 Hetes Prémium VIP Vásárlás \w[\r400 PP\w]", "3", 0)
	menu_additem(menu, "3 Hetes Prémium VIP Vásárlás \w[\r1100 PP\w]", "4", 0)
	menu_additem(menu, "1 Hónapos Prémium VIP Vásárlás \w[\r1400 PP\w]", "5", 0)
	menu_additem(menu, "Örök Prémium VIP Vásárlás \w[\r8000 PP\w]", "6", 0)
	menu_additem(menu, "BlackIce Prémium Csomag \w[\r70PP\w]", "7", 0)
	menu_additem(menu, "CannabisLife Prémium Csomag \w[\r40PP\w]", "8", 0)
	menu_additem(menu, "Random Kés Pörgetés \w[\r100PP\w]", "9", 0)
	menu_additem(menu, "Skeleton Knife | Fade \w[\r200PP\w]", "10", 0)
	menu_additem(menu, "Skeleton Knife | Crimson Web \w[\r200PP\w]", "11", 0)
	
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
	
    switch(key)
    {
		case 1:
		{
			SMSMotd(id);
		}
		case 2:
		{
			PayPalMotd(id);
		}
		case 3:
		{
			if(premiumpont[id] >= 400)
			{
				premiumpont[id] -= 400;
				Vip[id][PremiumTime] = get_systime()+86400*7
				format_time(sztime, charsmax(sztime), "%Y.%m.%d - %H:%M:%S", Vip[id][PremiumTime])
				client_print_color(id, print_team_default, "%s^1 Vettél egy^4 1 Hétre^1 szóló ^3Prémium ^4VIP^1-et. ^3Lejár ekkor: ^4%s", PREFIX, sztime);
			}
			else
			{
				client_print_color(id, print_team_default, "%s^1 Nincs elég Prémiumpontod!", PREFIX);
			}
			m_PremiumBolt(id);
		}
		case 4:
		{
			if(premiumpont[id] >= 1100)
			{
				premiumpont[id] -= 1100;
				Vip[id][PremiumTime] = get_systime()+86400*7*3
				format_time(sztime, charsmax(sztime), "%Y.%m.%d - %H:%M:%S", Vip[id][PremiumTime])
				client_print_color(id, print_team_default, "%s^1 Vettél egy^4 3 Hétre^1 szóló ^3Prémium ^4VIP^1-et. ^3Lejár ekkor: ^4%s", PREFIX, sztime);
			}
			else
			{
				client_print_color(id, print_team_default, "%s^1 Nincs elég Prémiumpontod!", PREFIX);
			}
			m_PremiumBolt(id);
		}
		case 5:
		{
			if(premiumpont[id] >= 1400)
			{
				premiumpont[id] -= 1400;
				Vip[id][PremiumTime] = get_systime()+2629800
				format_time(sztime, charsmax(sztime), "%Y.%m.%d - %H:%M:%S", Vip[id][PremiumTime])
				client_print_color(id, print_team_default, "%s^1 Vettél egy^4 1 Hónapra^1 szóló ^3Prémium ^4VIP^1-et. ^3Lejár ekkor: ^4%s", PREFIX, sztime);
			}
			else
			{
				client_print_color(id, print_team_default, "%s^1 Nincs elég Prémiumpontod!", PREFIX);
			}
			m_PremiumBolt(id);
		}
		case 6:
		{
			if(premiumpont[id] >= 8000)
			{
				premiumpont[id] -= 8000;
				Vip[id][PremiumTime] = get_systime()+2629800*30
				format_time(sztime, charsmax(sztime), "%Y.%m.%d - %H:%M:%S", Vip[id][PremiumTime])
				client_print_color(id, print_team_default, "%s^1 Vettél egy^4 Örökre^1 szóló ^3Prémium ^4VIP^1-et. ^3Lejár ekkor: ^4%s", PREFIX, sztime);
			}
			else
			{
				client_print_color(id, print_team_default, "%s^1 Nincs elég Prémiumpontod!", PREFIX);
			}
			m_PremiumBolt(id);
		}
		case 7:
		{
			if(premiumpont[id] >= 80)
			{
				client_print_color(id, print_team_default, "%s ^1Megávásároltad a ^3BlackIce^1 csomagot.", PREFIX);
				premiumpont[id] -= 80;
				g_Weapons[80][id]++;
				g_Weapons[81][id]++;
				g_Weapons[82][id]++;
				g_Weapons[83][id]++;
				g_Weapons[88][id]++;
				g_Weapons[89][id]++;
				g_Weapons[90][id]++;
			}
			else
			{
				client_print_color(id, print_team_default, "%s ^1Nincs elég Prémium Pontod!", PREFIX);
			}
		}
		case 8:
		{
			if(premiumpont[id] >= 40)
			{
				client_print_color(id, print_team_default, "%s ^1Megávásároltad a ^3BlackIce^1 csomagot.", PREFIX);
				premiumpont[id] -= 40;
				g_Weapons[84][id]++;
				g_Weapons[85][id]++;
				g_Weapons[86][id]++;
				g_Weapons[87][id]++;
				g_Weapons[91][id]++;
			}
			else
			{
				client_print_color(id, print_team_default, "%s ^1Nincs elég Prémium Pontod!", PREFIX);
			}
		}
		case 9:
		{
			if(premiumpont[id] >= 100)
			{
				new kes = random_num (51, 73)
				premiumpont[id] -= 100;
				g_Weapons[kes][id]++;
				client_print_color(0, print_team_default, "^3%s^1 Játékos: ^4%s^1 pörgetett egy ^4%s^1 kést, prémium menüből!", PREFIX, Player[id][f_PlayerNames], FegyverInfo[kes][GunName]);
			}
			else
			{
				client_print_color(id, print_team_default, "%s ^1Nincs elég Prémium Pontod!", PREFIX);
			}
		}
		case 10:
		{
			if(premiumpont[id] >= 200)
			{
				premiumpont[id] -= 200;
				g_Weapons[92][id]++;
				client_print_color(0, print_team_default, "^3%s^1 Játékos: ^4%s^1 vett egy ^3Prémium | Skeleton Fade^1 kést, prémium menüből!", PREFIX, Player[id][f_PlayerNames]);
			}
			else
			{
				client_print_color(id, print_team_default, "%s ^1Nincs elég Prémium Pontod!", PREFIX);
			}
		}
		case 11:
		{
			if(premiumpont[id] >= 200)
			{
				premiumpont[id] -= 200;
				g_Weapons[93][id]++;
				client_print_color(0, print_team_default, "^3%s^1 Játékos: ^4%s^1 vett egy ^3Prémium | Skeleton Crimson Web^1 kést, prémium menüből!", PREFIX, Player[id][f_PlayerNames]);
			}
			else
			{
				client_print_color(id, print_team_default, "%s ^1Nincs elég Prémium Pontod!", PREFIX);
			}
		}
	}
   
    
}
public m_Bolt(id)
{
new String[121];
formatex(String, charsmax(String), "%s \r- \dÁruház^n\yDollár: \d%3.2f", MENUPREFIX, g_dollar[id]);
new menu = menu_create(String, "h_Bolt");
	
menu_additem(menu, "BattlePass Vásárlás \w[\r50.00$\w]", "1", ADMIN_ADMIN)
menu_additem(menu, "1 Napos VIP Vásárlás \w[\r20.11$\w]", "2", 0)
menu_additem(menu, "14 Napos VIP Vásárlás \w[\r500.00$\w]", "3", 0)
menu_additem(menu, "StatTrak* Tool \w[\r150.00$\w]", "4", 0)
menu_additem(menu, "Névcédula \w[\r187.00$\w]", "5", 0)
menu_additem(menu, "Zenekészlet Vásárlás (új menü!)", "6", 0)
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

public m_Zenekeszlet(id)
{
	new String[518];
	formatex(String, charsmax(String), "%s \r- \dZenekészlet Áruház^n\yDollár: \d%3.2f", MENUPREFIX, g_dollar[id]);
	new menu = menu_create(String, "m_Zenekeszlet_h");
	
	formatex(String, charsmax(String), "Zene: \y%s\d | \wÁra: \y%3.2f", MusicKitInfos[1][MusicKitName], MusicKitInfos[1][MusicKitPound_D]);
	menu_additem(menu, String, "1", 0);
	formatex(String, charsmax(String), "Zene: \y%s\d | \wÁra: \y%3.2f", MusicKitInfos[2][MusicKitName], MusicKitInfos[2][MusicKitPound_D]);
	menu_additem(menu, String, "2", 0);
	formatex(String, charsmax(String), "Zene: \y%s\d | \wÁra: \y%3.2f", MusicKitInfos[3][MusicKitName], MusicKitInfos[3][MusicKitPound_D]);
	menu_additem(menu, String, "3", 0);
	formatex(String, charsmax(String), "Zene: \y%s\d | \wÁra: \y%3.2f", MusicKitInfos[4][MusicKitName], MusicKitInfos[4][MusicKitPound_D]);
	menu_additem(menu, String, "4", 0);
	formatex(String, charsmax(String), "Zene: \y%s\d | \wÁra: \y%3.2f", MusicKitInfos[5][MusicKitName], MusicKitInfos[5][MusicKitPound_D]);
	menu_additem(menu, String, "5", 0);
	formatex(String, charsmax(String), "Zene: \y%s\d | \wÁra: \y%3.2f", MusicKitInfos[6][MusicKitName], MusicKitInfos[6][MusicKitPound_D]);
	menu_additem(menu, String, "6", 0);
	formatex(String, charsmax(String), "Zene: \y%s\d | \wÁra: \y%3.2f", MusicKitInfos[7][MusicKitName], MusicKitInfos[7][MusicKitPound_D]);
	menu_additem(menu, String, "7", 0);
	
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
	
    switch(key)
    {
		case 1:
		{
			if(g_dollar[id] >= 40.00)
			{
				client_print_color(0, print_team_default, "%s ^1Játékos: ^4%s^1 megvásárolta a ^3%s^1 zenekészletet!", PREFIX, Player[id][f_PlayerNames], MusicKitInfos[1][MusicKitName]);
				g_dollar[id] -= 40.00
				mvpr_kit[1][id]++;
			}
			else
			{
				client_print_color(id, print_team_default, "%s ^1Nincs elég egyenleged, vagy megvan már ez a zenekészlet neked!", PREFIX);
			}
		}
		case 2:
		{
			if(g_dollar[id] >= 90.00)
			{
				client_print_color(0, print_team_default, "%s ^1Játékos: ^4%s^1 megvásárolta a ^3%s^1 zenekészletet!", PREFIX, Player[id][f_PlayerNames], MusicKitInfos[2][MusicKitName]);
				g_dollar[id] -= 90.00
				mvpr_kit[2][id]++;
			}
			else
			{
				client_print_color(id, print_team_default, "%s ^1Nincs elég egyenleged, vagy megvan már ez a zenekészlet neked!", PREFIX);
			}
		}
		case 3:
		{
			if(g_dollar[id] >= 110.00)
			{
				client_print_color(0, print_team_default, "%s ^1Játékos: ^4%s^1 megvásárolta a ^3%s^1 zenekészletet!", PREFIX, Player[id][f_PlayerNames], MusicKitInfos[3][MusicKitName]);
				g_dollar[id] -= 110.00
				mvpr_kit[3][id]++;
			}
			else
			{
				client_print_color(id, print_team_default, "%s ^1Nincs elég egyenleged, vagy megvan már ez a zenekészlet neked!", PREFIX);
			}
		}
		case 4:
		{
			if(g_dollar[id] >= 150.00)
			{
				client_print_color(0, print_team_default, "%s ^1Játékos: ^4%s^1 megvásárolta a ^3%s^1 zenekészletet!", PREFIX, Player[id][f_PlayerNames], MusicKitInfos[4][MusicKitName]);
				g_dollar[id] -= 150.00
				mvpr_kit[4][id]++;
			}
			else
			{
				client_print_color(id, print_team_default, "%s ^1Nincs elég egyenleged, vagy megvan már ez a zenekészlet neked!", PREFIX);
			}
		}
		case 5:
		{
			if(g_dollar[id] >= 175.00)
			{
				client_print_color(0, print_team_default, "%s ^1Játékos: ^4%s^1 megvásárolta a ^3%s^1 zenekészletet!", PREFIX, Player[id][f_PlayerNames], MusicKitInfos[5][MusicKitName]);
				g_dollar[id] -= 175.00
				mvpr_kit[5][id]++;
			}
			else
			{
				client_print_color(id, print_team_default, "%s ^1Nincs elég egyenleged, vagy megvan már ez a zenekészlet neked!", PREFIX);
			}
		}
		case 6:
		{
			if(g_dollar[id] >= 190.00)
			{
				client_print_color(0, print_team_default, "%s ^1Játékos: ^4%s^1 megvásárolta a ^3%s^1 zenekészletet!", PREFIX, Player[id][f_PlayerNames], MusicKitInfos[6][MusicKitName]);
				g_dollar[id] -= 190.00
				mvpr_kit[6][id]++;
			}
			else
			{
				client_print_color(id, print_team_default, "%s ^1Nincs elég egyenleged, vagy megvan már ez a zenekészlet neked!", PREFIX);
			}
		}
		case 7:
		{
			if(g_dollar[id] >= 220.00)
			{
				client_print_color(0, print_team_default, "%s ^1Játékos: ^4%s^1 megvásárolta a ^3%s^1 zenekészletet!", PREFIX, Player[id][f_PlayerNames], MusicKitInfos[7][MusicKitName]);
				g_dollar[id] -= 220.00
				mvpr_kit[7][id]++;
			}
			else
			{
				client_print_color(id, print_team_default, "%s ^1Nincs elég egyenleged, vagy megvan már ez a zenekészlet neked!", PREFIX);
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
				BattlePassPurchased[id] = 1;
				client_print_color(0, print_team_default, "^4%s^1 Játékos: ^4%s^1 megvásárolta a ^3BattlePass-t", PREFIX, Player[id][f_PlayerNames])
			}
			else
			{
				client_print_color(id, print_team_default, "%s^4Sikertelen^1 vásárlás, nincs elég ^4$^1-d.", PREFIX);
			}
			m_Bolt(id)
			}
		}
		case 2:
		{
			if(g_dollar[id] >= 20.11)
			{
				g_dollar[id] -= 20.11;
				g_VipTime[id] = get_systime()+86400
				format_time(sztime, charsmax(sztime), "%Y.%m.%d - %H:%M:%S", g_VipTime[id])
				client_print_color(id, print_team_default, "%s^1 Vettél egy^4 1 Napra^1 szóló‚ ^3VIPet^1. ^3Lejár ekkor: ^4%s", PREFIX, sztime);
			}
			else
			{
				client_print_color(id, print_team_default, "%s^1 Nincs elég Dollárod", PREFIX);
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
				client_print_color(id, print_team_default, "%s^1 Vettél egy^4 14 Napra^1 szóló‚ ^3VIPet^1. ^3Lejár ekkor: ^4%s", PREFIX, sztime);
			}
			else
			{
				client_print_color(id, print_team_default, "%s^1 Nincs elég Dollárod", PREFIX);
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
			client_print_color(id, print_team_default, "%s^1 ^3Sikeresen^1 vásároltál egy ^3StatTrak* Tool^1-t.", PREFIX);
		}
		else
		{
			client_print_color(id, print_team_default, "%s^4Sikertelen^1 vásárlás, nincs elég ^4$^1-d.", PREFIX);
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
			client_print_color(id, print_team_default, "%s^1 ^3Sikeresen^1 vásároltál egy ^3Névcédula^1-t.", PREFIX);
		}
		else
		{
			client_print_color(id, print_team_default, "%s^4Sikertelen^1 vásárlás, nincs elég ^4$^1-d.", PREFIX);
		}
		m_Bolt(id)
		}
		}
		case 6:
		{
			m_Zenekeszlet(id);
		}
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
				client_print_color(id, print_team_default, "^4%s ^1Nincs elég dollárod a fejlesztéshez!", PREFIX);
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
			client_print_color(id, print_team_default, "^4%s ^1Nincs elég dollárod a fejlesztéshez!", PREFIX);

		}
		case 18:{
			if(g_dollar[id] >= 100.00)
				client_cmd(id, "messagemode Chat_Prefix");
			else
				client_printcolor(id, "%s Nincs elég Dollárod", PREFIX);
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

new m_fegyverladas = sizeof(FegyverLada1_drops);
new Float:FegyverLadas1;
FegyverLadas1 = float(m_fegyverladas);

new m_fegyverladas2 = sizeof(FegyverLada2_drops);
new Float:FegyverLadas12;
FegyverLadas12 = float(m_fegyverladas2);

new m_fegyverladas3 = sizeof(EzustLada_drops);
new Float:FegyverLadas13;
FegyverLadas13 = float(m_fegyverladas3);

new m_fegyverladas4 = sizeof(AranyLada_drops);
new Float:FegyverLadas14;
FegyverLadas14 = float(m_fegyverladas4);

new m_fegyverladas5 = sizeof(GyemantLada_drops);
new Float:FegyverLadas15;
FegyverLadas15 = float(m_fegyverladas5);

new m_fegyverladas6 = sizeof(PremiumLada_drops);
new Float:FegyverLadas16;
FegyverLadas16 = float(m_fegyverladas6);

new m_fegyverladas7 = sizeof(ChristmasLada_drops);
new Float:FegyverLadas17;
FegyverLadas17 = float(m_fegyverladas7);

new m_fegyverladas8 = sizeof(Versus_drops);
new Float:FegyverLadas18;
FegyverLadas18 = float(m_fegyverladas8);
switch(LadaID)
{
case 0:
	{
	for(new i;i < FegyverLadas1;i++)
		{
		OverAll += FegyverLada1_drops[i][1];
		}
		new Float:RandomNumber = random_float(0.01,OverAll);
			
		for(new i = 0; i < FegyverLadas1;i++)
			{
				ChanceOld = ChanceNow;
				ChanceNow += FegyverLada1_drops[i][1];
				if(ChanceOld < RandomNumber < ChanceNow)
				{
					g_Weapons[floatround(FegyverLada1_drops[i][0])][id]++;
					OpenedWepID = floatround(FegyverLada1_drops[i][0]);
					OpenedWepChance = FegyverLada1_drops[i][1];
	
					if(StatTrakChance < 3)
					{
						g_StatTrak[floatround(FegyverLada1_drops[i][0])][id]++;
						is_StatTrak = true;
					}
				}
			}
		}
	case 1:
	{
	for(new i;i < FegyverLadas12;i++)
		{
		OverAll += FegyverLada2_drops[i][1];
		}
		new Float:RandomNumber = random_float(0.01,OverAll);
			
			for(new i = 0; i < FegyverLadas12;i++)
			{
				ChanceOld = ChanceNow;
				ChanceNow += FegyverLada2_drops[i][1];
				if(ChanceOld < RandomNumber < ChanceNow)
				{
					g_Weapons[floatround(FegyverLada2_drops[i][0])][id]++;
					OpenedWepID = floatround(FegyverLada2_drops[i][0]);
					OpenedWepChance = FegyverLada2_drops[i][1];
	
					if(StatTrakChance < 3)
					{
						g_StatTrak[floatround(FegyverLada2_drops[i][0])][id]++;
						is_StatTrak = true;
					}
				}
			}
		}
case 2:
	{
	for(new i;i < FegyverLadas13;i++)
		{
		OverAll += EzustLada_drops[i][1];
		}
		new Float:RandomNumber = random_float(0.01,OverAll);
			
		for(new i = 0; i < FegyverLadas13;i++)
			{
			ChanceOld = ChanceNow;
			ChanceNow += EzustLada_drops[i][1];
			if(ChanceOld < RandomNumber < ChanceNow)
			{
				g_Weapons[floatround(EzustLada_drops[i][0])][id]++;
				OpenedWepID = floatround(EzustLada_drops[i][0]);
				OpenedWepChance = EzustLada_drops[i][1];

				if(StatTrakChance < 3)
				{
					g_StatTrak[floatround(EzustLada_drops[i][0])][id]++;
					is_StatTrak = true;
				}
			}
		}
	}
case 3:
	{
	for(new i;i < FegyverLadas14;i++)
		{
		OverAll += AranyLada_drops[i][1];
		}
		new Float:RandomNumber = random_float(0.01,OverAll);
			
		for(new i = 0; i < FegyverLadas14;i++)
			{
				ChanceOld = ChanceNow;
				ChanceNow += AranyLada_drops[i][1];
				if(ChanceOld < RandomNumber < ChanceNow)
				{
					g_Weapons[floatround(AranyLada_drops[i][0])][id]++;
					OpenedWepID = floatround(AranyLada_drops[i][0]);
					OpenedWepChance = AranyLada_drops[i][1];

					if(StatTrakChance < 3)
					{
						g_StatTrak[floatround(AranyLada_drops[i][0])][id]++;
						is_StatTrak = true;
					}
				}
			}
		}
case 4:
	{
	for(new i;i < FegyverLadas15;i++)
		{
		OverAll += GyemantLada_drops[i][1];
		}
		new Float:RandomNumber = random_float(0.01,OverAll);
			
		for(new i = 0; i < FegyverLadas15;i++)
			{
				ChanceOld = ChanceNow;
				ChanceNow += GyemantLada_drops[i][1];
				if(ChanceOld < RandomNumber < ChanceNow)
				{
					g_Weapons[floatround(GyemantLada_drops[i][0])][id]++;
					OpenedWepID = floatround(GyemantLada_drops[i][0]);
					OpenedWepChance = GyemantLada_drops[i][1];

					if(StatTrakChance < 3)
					{
						g_StatTrak[floatround(GyemantLada_drops[i][0])][id]++;
						is_StatTrak = true;
					}
				}
			}
		}
case 5:
	{
	for(new i;i < FegyverLadas16;i++)
		{
		OverAll += PremiumLada_drops[i][1];
		}
		new Float:RandomNumber = random_float(0.01,OverAll);
				
		for(new i = 0; i < FegyverLadas16;i++)
			{
			ChanceOld = ChanceNow;
				ChanceNow += PremiumLada_drops[i][1];
				if(ChanceOld < RandomNumber < ChanceNow)
				{
					g_Weapons[floatround(PremiumLada_drops[i][0])][id]++;
					OpenedWepID = floatround(PremiumLada_drops[i][0]);
					OpenedWepChance = PremiumLada_drops[i][1];

					if(StatTrakChance < 3)
					{
						g_StatTrak[floatround(PremiumLada_drops[i][0])][id]++;
						is_StatTrak = true;
					}
				}
			}
		}
		case 6:
		{
		for(new i;i < FegyverLadas17;i++)
		{
			OverAll += ChristmasLada_drops[i][1];
		}
		new Float:RandomNumber = random_float(0.01,OverAll);
				
		for(new i = 0; i < FegyverLadas17;i++)
				{
				ChanceOld = ChanceNow;
				ChanceNow += ChristmasLada_drops[i][1];
				
				if(ChanceOld < RandomNumber < ChanceNow)
				{
					g_Weapons[floatround(ChristmasLada_drops[i][0])][id]++;
					OpenedWepID = floatround(ChristmasLada_drops[i][0]);
					OpenedWepChance = ChristmasLada_drops[i][1];

					if(StatTrakChance < 3)
					{
						g_StatTrak[floatround(ChristmasLada_drops[i][0])][id]++;
						is_StatTrak = true;
					}
				}
			}
		}
		case 7:
		{
		for(new i;i < FegyverLadas18;i++)
		{
			OverAll += Versus_drops[i][1];
		}
		new Float:RandomNumber = random_float(0.01,OverAll);
				
		for(new i = 0; i < FegyverLadas18;i++)
				{
				ChanceOld = ChanceNow;
				ChanceNow += Versus_drops[i][1];
				
				if(ChanceOld < RandomNumber < ChanceNow)
				{
					g_Weapons[floatround(Versus_drops[i][0])][id]++;
					OpenedWepID = floatround(Versus_drops[i][0]);
					OpenedWepChance = Versus_drops[i][1];

					if(StatTrakChance < 3)
					{
						g_StatTrak[floatround(Versus_drops[i][0])][id]++;
						is_StatTrak = true;
					}
				}
			}
		}
  }
if((OpenedWepChance/(OverAll/100.0)) < 0.3 || is_StatTrak == true)
{
new name[32];
get_user_name(id, name, charsmax(name));

if(is_StatTrak)
	client_print_color(0, print_team_red, "%s^3%s^1 nyitott egy:^3StatTrak*^4%s^1-t. ( Esélye ennek:^4%.3f%s ^1)", PREFIX, name, FegyverInfo[OpenedWepID][GunName], (OpenedWepChance/(OverAll/100.0)),"%");
else
	client_print_color(0, print_team_red, "%s^3%s^1 nyitott egy:^4%s^1-t. ( Esélye ennek:^4%.3f%s ^1)", PREFIX, name, FegyverInfo[OpenedWepID][GunName], (OpenedWepChance/(OverAll/100.0)),"%");
//client_cmd(0,"spk p2_hangok/kesnyitas");
}
else
	{
	if(is_StatTrak)
		client_print_color(id, print_team_red, "%s^1Nyitottál egy:^3StatTrak*^4%s^1-t. ( Esélye ennek:^4%.3f%s ^1)", PREFIX, FegyverInfo[OpenedWepID][GunName], (OpenedWepChance/(OverAll/100.0)),"%");
	else
		client_print_color(id, print_team_red, "%s^1Nyitottál egy:^4%s^1-t. ( Esélye ennek:^4%.3f%s ^1)", PREFIX, FegyverInfo[OpenedWepID][GunName], (OpenedWepChance/(OverAll/100.0)),"%");
	}
  
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
		client_print_color(0, print_team_default, "^4%s^1 Játékos: ^3%s^1 nyitott egy ajándékcsomagot és talált benne ^3drogot", PREFIX, Player[id][f_PlayerNames])
		}
		case 1:
		{
		entity_set_float(id, EV_FL_health, entity_get_float(id, EV_FL_health)+25.0 );
		client_print_color(0, print_team_default, "^4%s^1 Játékos: ^3%s^1 nyitott egy ajándékcsomagot és talált benne ^3+25 HP-t.", PREFIX, Player[id][f_PlayerNames])
		}
		case 2:
		{
		set_user_armor(id, 200); 
		client_print_color(0, print_team_default, "^4%s^1 Játékos: ^3%s^1 nyitott egy ajándékcsomagot és talált benne^3 200Armort", PREFIX, Player[id][f_PlayerNames])
		}
		case 3: 
		{
		g_dollar[id] += random_float(0.01, 1.00)
		client_print_color(0, print_team_default, "^4%s^1 Játékos: ^3%s^1 nyitott egy ajándékcsomagot és talált benne ^3Dollár.", PREFIX, Player[id][f_PlayerNames])
		}
	}
}
public Ellenorzes(id){
	T_Betu(id);
}
public keres(id)
{
	client_print_color(id, print_team_default, "Neked a %i-es skin van felszerelve!", Selectedgun[AK47][id])
}
public openQuestMenu(id)
{
	new String[121];
	formatex(String, charsmax(String), "%s \r- \dKüldetések", MENUPREFIX);
	new menu = menu_create(String, "h_openQuestMenu");
	
	new const QuestWeapons[][] = { "AK47", "M4A1", "AWP", "DEAGLE", "FAMAS", "GALIL", "SCOUT", "DEAGLE", "DEAGLE", "TMP", "Nincs" };
	new const QuestHeadKill[][] = { "Nincs", "Csak fejlövés" };
	
	formatex(String, charsmax(String), "\wFeladat: \yÖlj meg %d játékost \d[\yMég %d ölés\d]", g_QuestKills[0][id], g_QuestKills[0][id]-g_QuestKills[1][id]);
	menu_addtext2(menu, String);
	formatex(String, charsmax(String), "\wÖlés Korlát: \y%s", QuestHeadKill[g_QuestHead[id]]);
	menu_addtext2(menu, String);
	formatex(String, charsmax(String), "\wFegyver Korlát: \y%s \d[\rCsak ezzel a fegyverrel ölhetsz\d]^n", QuestWeapons[g_QuestWeapon[id]]);
	menu_addtext2(menu, String);
	formatex(String, charsmax(String), "\wJutalom:^n\y- Dollár [%3.2f $]^n- Láda [%d DB]^n- Kulcs [%d DB]^n- ST*Tool [%dDB]- NC [%dDB]^n", g_dollarjutalom[id], g_Jutalom[0][id], g_Jutalom[1][id], g_Jutalom[3][id], g_Jutalom[4][id]);
	menu_addtext2(menu, String);
	formatex(String, charsmax(String), "\wKüldetés kihagyása \d[\r150$\d]");
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
			if(g_dollar[id] >= 150)
			{
				g_QuestKills[1][id] = 0;
				g_QuestWeapon[id] = 0;
				g_Quest[id] = 0;
				g_dollar[id] -= 150;
				client_print_color(id, print_team_default, "^4%s^1 Kihagytad ezt a küldetést", PREFIX)
			}
			else client_print_color(id, print_team_default, "^4%s^1 Nincs elég dollárod", PREFIX)
		}
	}
}
public Quest(id)
{
new HeadShot = read_data(3);
new randomCaseAll = random_num(0,1);
new name[32]; get_user_name(id, name, charsmax(name));


if(g_QuestHead[id] == 1 && (HeadShot))
{
	if(g_QuestWeapon[id] == 10) g_QuestKills[1][id]++;
	else if(g_QuestWeapon[id] == 9 && get_user_weapon(id) == CSW_TMP) g_QuestKills[1][id]++;
	else if(g_QuestWeapon[id] == 8 && get_user_weapon(id) == CSW_DEAGLE) g_QuestKills[1][id]++;
	else if(g_QuestWeapon[id] == 7 && get_user_weapon(id) == CSW_DEAGLE) g_QuestKills[1][id]++;
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
	if(g_QuestWeapon[id] == 10) g_QuestKills[1][id]++;
	else if(g_QuestWeapon[id] == 9 && get_user_weapon(id) == CSW_TMP) g_QuestKills[1][id]++;
	else if(g_QuestWeapon[id] == 8 && get_user_weapon(id) == CSW_DEAGLE) g_QuestKills[1][id]++;
	else if(g_QuestWeapon[id] == 7 && get_user_weapon(id) == CSW_DEAGLE) g_QuestKills[1][id]++;
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
	g_Tools[0][id] += g_Jutalom[3][id];
	g_Tools[1][id] += g_Jutalom[4][id];
	//Darkpont[id] += g_Jutalom[2][id];
	g_dollar[id] += g_dollarjutalom[id];
	g_QuestKills[1][id] = 0;
	g_QuestWeapon[id] = 0;
	rXP[id] += 150;
	rELO[id] += random(100);
	g_QuestMVP[id]++;
	g_Quest[id] = 0;
	client_print_color(id, print_team_default, "^4%s ^1A küldetésre kapott jutalmakat megkaptad! A map végén kapsz^3 150^1 XP-t!", PREFIX);
	client_print_color(0, print_team_default, "^4%s ^4%s^1 befejezte a kiszabott küldetéseket. A jutalmakat megkapta", PREFIX, name);
}
}
public m_Addolas(id)
{
		g_Tools[0][id] += 100;
		g_Tools[1][id] += 100;
		g_dollar[id] += 100.00;
		for(new i;i < FEGYO; i++)
		g_Weapons[i][id] += 1;
		for(new i;i < LADASZAM; i++)
		Lada[i][id] += 100;
		for(new i;i < LADASZAM; i++)
		LadaK[i][id] += 100;

		client_print_color(id, print_team_default, "^3Addolva lett neked minden! Tesztelj! Kuldj, vegyel, adj, rakj piacra, nyiss skint etc!!!!")
		client_print_color(id, print_team_default, "^3Addolva lett neked minden! Tesztelj! Kuldj, vegyel, adj, rakj piacra, nyiss skint etc!!!!")
		client_print_color(id, print_team_default, "^3Addolva lett neked minden! Tesztelj! Kuldj, vegyel, adj, rakj piacra, nyiss skint etc!!!!")
		client_print_color(id, print_team_default, "^3Addolva lett neked minden! Tesztelj! Kuldj, vegyel, adj, rakj piacra, nyiss skint etc!!!!")
}

public Check()
{
	if(Fragverseny != 0)
		set_task(1.0,"automatikusfrag");

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
	new StringC[512]
	new StringHud[512]
	new HudString2[512]
	
	if(is_user_alive(id))
		m_Index = id;
	else
		m_Index = entity_get_int(id, EV_INT_iuser2);

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

	if(Fragverseny)
	{
	set_hudmessage(0, 127, 255, -1.0, 0.10, 0, 6.0, 1.0);
	ShowSyncHudMsg(id, cSync, "Jelenleg fragverseny van! (Még %i kör)^n1. %s - Ölés: %i | 2. %s - Ölés: %i | 3. %s - Ölés: %i", Fragkorok, TopName1, FragRacers[Top1][FragerKills], TopName2, FragRacers[Top2][FragerKills], TopName3, FragRacers[Top3][FragerKills])
	}

	if(HudOff[id] == 0)
	{
		new i_Seconds, i_Minutes, i_Hours, i_Days, iLen;
		i_Seconds = masodpercek[m_Index] + get_user_time(m_Index);
		i_Minutes = i_Seconds / 60;
		i_Hours = i_Minutes / 60;
		i_Seconds = i_Seconds - i_Minutes * 60;
		i_Minutes = i_Minutes - i_Hours * 60;
		i_Days = i_Hours / 24;
		i_Hours = i_Hours - (i_Days * 24);

		iLen += formatex(StringC[iLen], charsmax(StringC)-iLen, "Név: %s(#%i)^n^nÖlés: %i | HS: %i | Halál: %i^nJátszott idő: %i Nap %i Óra %i Perc^nNyJáték Ölés: %i^nNyert meccsek: %i^n^nEgyenleg:^nDollár: %3.2f^nPrémium Pont: %i", Player[m_Index][f_PlayerNames], g_Id[m_Index], oles[m_Index], hs[m_Index], hl[m_Index], i_Days, i_Hours, i_Minutes, NyeremenyOles[m_Index], Wins[m_Index], g_dollar[m_Index], premiumpont[m_Index]);

		iLen += formatex(StringC[iLen], charsmax(StringC)-iLen, "^n");

		if(Equipmented_Erem[m_Index] > 0)
			iLen += formatex(StringC[iLen], charsmax(StringC)-iLen, "^n%s", g_Ermek[Equipmented_Erem[m_Index]][erem_name]);
			
		set_hudmessage(random(256), random(256), random(256), 0.01, 0.15, 0, 6.0, 1.1, 0.0, next_hudchannel(id));
		ShowSyncHudMsg(id, dSync, StringC);
	}
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
		set_hudmessage(255, 255, 255, -1.0, 0.72, 0, 0.0, 0.9, 0.0, 0.0, 2);
		show_hudmessage(id, StringHud);
	}
}
public openStatus(id)
{
	new cim[121];
	format(cim, charsmax(cim), "[%s] \r- \dBeállítások", MENUPREFIX);
	new menu = menu_create(cim, "hStatus");
	
	formatex(String, charsmax(String), "Profile Rank: \r%s \y[\w%3.2f\y/\w5000\y]", PrivateRanks[Player[id][SSzint]][RangName], rXP[id]);
	menu_addtext2(menu, String);
	formatex(String, charsmax(String), "Rangod: \r%s", Rangok[Rang[id]][RangName]);
	menu_addtext2(menu, String);
	formatex(String, charsmax(String), "Kővetkező \rRangod: \d%s", Rangok[Rang[id]+1][RangName]);
	menu_addtext2(menu, String);

	if(g_Admin_Level[id] > 0)
	{
	    menu_additem(menu, "\dJátékos Account #Id-k", "6", 0);
	    menu_additem(menu, "\dAdmin Lista", "7", 0);
	    //menu_additem(menu, InkAdmin[id] == 1 ? "InkognitóAdmin: \rBekapcsolva \y| \wKikapcsolva":"InkognitóAdmin: \wBekapcsolva \y| \rKikapcsolva", "4", 0);
	}

	menu_additem(menu, g_SkinBeKi[id] == 0 ? "Skin: \rBekapcsolva \y| \wKikapcsolva":"Skin:\wBekapcsolva \y| \rKikapcsolva", "1",0);
	menu_additem(menu, HudOff[id] == 0 ? "HUD: \rBekapcsolva \y| \wKikapcsolva":"HUD: \wBekapcsolva \y| \rKikapcsolva", "2",0);
	//menu_additem(menu, Off[id] == 0 ? "Körvégi Zene: \rBekapcsolva \y| \wKikapcsolva":"Körvégi Zene: \wBekapcsolva \y| \rKikapcsolva", "3",0);
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
			targyakfogadasa[id] = !targyakfogadasa[id];
			openStatus(id);
		}
		case 5:
		{
			szinesmenu[id] = !szinesmenu[id];
			openStatus(id);
		}
        case 6:
        {
            CheckIdMenu(id);
        }
        case 7:
        {
            ShowAdminsMenu(id);
        }
	}
	
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public BeallitasEloszto(id)
	{
		new cim[121];
		format(cim, charsmax(cim), "%s^nRaktár elosztó", MENUPREFIX);
		new menu = menu_create(cim, "BeallitasEloszto_h");
		
		menu_additem(menu, "AK47 Skinek", "1", 0);
		menu_additem(menu, "M4A1 Skinek", "2", 0);
		menu_additem(menu, "AWP Skinek", "3", 0);
		menu_additem(menu, "DEAGLE Skinek", "4", 0);
		menu_additem(menu, "KÉS Skinek", "5", 0);
		menu_additem(menu, "Zenekészleteim", "6", 0);
		menu_additem(menu, "StatTrak/Névcédula felhelyezés", "7", 0);
		menu_additem(menu, "Fegyver Törlés", "9", 0);
		
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
			case 6: openZenekeszlet(id);
			case 7: openTools(id);
			//case 7: openTrash(id);
			}
	}
public openZenekeszlet(id)
{
	new szMenu[121]
	formatex(szMenu, charsmax(szMenu), "%s^nZenekészlet Raktár", MENUPREFIX)
	new menu = menu_create(szMenu, "hZInventory");

	formatex(szMenu, charsmax(szMenu), "%s \r[\y%i \rDB]", MusicKitInfos[1][MusicKitName], mvpr_kit[1][id])
	menu_additem(menu, szMenu, "1", 0);
	formatex(szMenu, charsmax(szMenu), "%s \r[\y%i \rDB]", MusicKitInfos[2][MusicKitName], mvpr_kit[2][id])
	menu_additem(menu, szMenu, "2", 0);
	formatex(szMenu, charsmax(szMenu), "%s \r[\y%i \rDB]", MusicKitInfos[3][MusicKitName], mvpr_kit[3][id])
	menu_additem(menu, szMenu, "3", 0);
	formatex(szMenu, charsmax(szMenu), "%s \r[\y%i \rDB]", MusicKitInfos[4][MusicKitName], mvpr_kit[4][id])
	menu_additem(menu, szMenu, "4", 0);
	formatex(szMenu, charsmax(szMenu), "%s \r[\y%i \rDB]", MusicKitInfos[5][MusicKitName], mvpr_kit[5][id])
	menu_additem(menu, szMenu, "5", 0);
	formatex(szMenu, charsmax(szMenu), "%s \r[\y%i \rDB]", MusicKitInfos[6][MusicKitName], mvpr_kit[6][id])
	menu_additem(menu, szMenu, "6", 0);
	formatex(szMenu, charsmax(szMenu), "%s \r[\y%i \rDB]", MusicKitInfos[7][MusicKitName], mvpr_kit[7][id])
	menu_additem(menu, szMenu, "7", 0);

	menu_display(id, menu, 0);
}
public hZInventory(id, menu, item) {
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED
	}

	new data[9], szName[64]
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName, charsmax(szName), callback);
	new key = str_to_num(data);
	
	if(mvpr_kit[key][id] > 0)
		mvpr_have_selectedkit[id] = key

	// if(mvpr_kit[1][id] > 0)
	// 	mvpr_have_selectedkit[id] = 1
	
	// else if(mvpr_kit[2][id] > 0)
	// 	mvpr_have_selectedkit[id] = 2
	
	// else if(mvpr_kit[3][id] > 0)
	// 	mvpr_have_selectedkit[id] = 3
	
	// else if(mvpr_kit[4][id] > 0)
	// 	mvpr_have_selectedkit[id] = 4

	// else if(mvpr_kit[5][id] > 0)
	// 	mvpr_have_selectedkit[id] = 5
	
	// else if(mvpr_kit[6][id] > 0)
	// 	mvpr_have_selectedkit[id] = 6

	// else if(mvpr_kit[7][id] > 0)
	// 	mvpr_have_selectedkit[id] = 7
	
	if(mvpr_kit[key][id] > 0)
    	client_print_color(id, print_team_default, "^4%s ^1Kivalásztottad a(z) ^3%s^1 zenekészletet.", PREFIX, MusicKitInfos[key][MusicKitName])	
	else
		client_print_color(id, print_team_default, "^4%s ^1Nincsen meg a választott zenekészleted! Vásárolj egyet az áruházba!", PREFIX)

	BeallitasEloszto(id)
	
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public openInventory(id, casekey)
{
	new szMenu[121],String[6]
	formatex(szMenu, charsmax(szMenu), "%s^nRaktár", MENUPREFIX)
	new menu = menu_create(szMenu, "hInventory");
	new fegyver = sizeof(FegyverInfo)

	switch(casekey)
	{
		case 1: 
		{
		for(new i;i < fegyver; i++)
		{
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
	
	if(strlen(g_GunNames[key][id]) < 1) client_print_color(id, print_team_default, "^4%s ^1Kivalásztottad a(z) ^3%s%s ^1fegyvert!", PREFIX, g_StatTrak[key][id] >= 1 ? "StatTrak* " : "", FegyverInfo[key][GunName])
	else client_print_color(id, print_team_default, "^4%s ^1Kivalásztottad a(z) ^3%s%s ^1fegyvert!", PREFIX, g_StatTrak[key][id] >= 1 ? "StatTrak* " : "", g_GunNames[key][id])
	BeallitasEloszto(id)
	
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public eDeathMsg(){
	new killer = read_data(1)
	new aldozat = read_data(2)
	//ELO
	new rHss = random_num(2, 20);
	new Float:rFHss = random_float(1.0, 17.0);

	new rKill = random_num(2, 15);
	new Float:rFKill = random_float(1.0, 14.0)

	new eDeath = random_num(2, 4)
	new Float:eFDeath = random_float(0.5, 2.5)
	//

	new Float:EXPKap; 
	new Float:EXPVesz;
	new Float:RandomMoney

	EXPKap += random_float(0.01,1.43);
	EXPVesz += random_float(0.01,0.15);
	RandomMoney = random_float(0.05, 0.10) + ((get_playersnum() + 0.0) * 0.3) / 100
	
	new esely = random_num(1,300)
	{
		if(esely >= 295) 
		{
			dropdobas()
		}
		if(esely <= 5)
		{
			dropdobas()
		}
	}

	if(killer == aldozat)
	{
		eloELO[aldozat] -= eDeath;
		eloXP[aldozat] -= eFDeath;
		hl[aldozat]++
		Player_Stats[aldozat][Deaths]++;
		return PLUGIN_HANDLED
	}

	if(read_data(3))
	{
		Player_Stats[killer][HSs]++;
		hs[killer]++
		eloELO[killer] += rHss;
		eloXP[killer] += rFHss;
	}
	else
	{
		eloELO[killer] += rKill;
		eloXP[killer] += rFKill;
	}
	if(read_data(2))
		hl[aldozat]++
	
	eloELO[aldozat] -= eDeath;
	eloXP[aldozat] -= eFDeath;

	Player_Stats[killer][Kills]++;
	Player_Stats[aldozat][Deaths]++;

	//EXPT[killer] += EXPKap;
	//EXPT[aldozat] -= EXPVesz;

	if(g_Quest[killer] == 1) Quest(killer);
	g_dollar[killer] += RandomMoney
	
	g_MVPoints[killer] ++;

	oles[killer]++
	NyeremenyOles[killer]++	

	if(Fragverseny)
		FragRacers[killer][FragerKills]++;

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
		else killer_hp += 2
	
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
public expis(id)
{
	new szName[32];
	get_user_name(id, szName, charsmax(szName));

	if(EXPT[id] >= 100.0)
		{
		client_cmd(id,"spk misc/cow");

		if(Player[id][SSzint] > 50)
			client_print_color(id, print_team_default, "^4[DEBUG]^1 LVL: 50 MAXED! NoRankUp!")
		else
		{
			Player[id][SSzint]++;
			EXPT[id] -= 100.0;
			g_dollar[id] += 5.00;
		    client_print_color(0, print_team_default, "^4%s^1 Játékos: ^4%s^1 szintet lépett, és kapott 5$-t!", PREFIX, szName);
		}
	}
}
public Change_Weapon(iEnt)
{
	if(!pev_valid(iEnt))
	return;
	
	new id = get_pdata_cbase(iEnt, 41, 4);
	
	if(!pev_valid(id))
		return;

	if(g_SkinBeKi[id])
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
  if (g_Vip[id]==1 || Vip[id][isPremium] ==1) //---------------------------VIPS----------------------//
	{
		for (new i = 0; i < ChaseNumber;i++)
    	{
    		DropChanceAdder[i] += DropChance[i] / 100.0 * 15.0;
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
    client_print_color(0, print_team_default, "^4%s ^3%s ^1Találta ezt: ^4%s^1 (Esélye ennek:^4%.2f%s^1)", PREFIX, Nev, LadaKNevek[i-1], (DropChance[i]/(OverallChance/100)), "%");
    i = ChaseNumber;
  }
	else if(ChanceOld < RandomNumber < ChanceNow && ChanceOld == 0.0)
	{
		Lada[i-1][id]++;
		client_print_color(0, print_team_default, "^4%s ^3%s ^1Találta ezt: ^4%s^1 ( Esélye ennek:^4%.2f%s ^1)", PREFIX, Nev, LadaKNevek[i-1], (DropChance[i]/(OverallChance/100)), "%");
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
  
  if (g_Vip[id]==1 || Vip[id][isPremium] ==1) //---------------------------VIPS----------------------//
	{
		for (new i = 0; i < ChaseNumber;i++)
    	{
    		DropChanceAdder[i] += DropChance[i] / 100.0 * 15.0;
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
    client_print_color(0, print_team_default, "^4%s ^3%s ^1Találta ezt: ^4%s^1 (Esélye ennek:^4%.2f%s^1)", PREFIX, Nev, LadaNevek[i-1], (DropChance[i]/(OverallChance/100)), "%");
    i = ChaseNumber;
  }
   else if(ChanceOld < RandomNumber < ChanceNow && ChanceOld == 0.0)
	{
        Lada[i-1][id]++;
        client_print_color(0, print_team_default, "^4%s ^3%s ^1Találta ezt: ^4%s^1 ( Esélye ennek:^4%.2f%s ^1)", PREFIX, Nev, LadaKNevek[i-1], (DropChance[i]/(OverallChance/100)), "%");
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
	for(new i;i < fegyver; i++) 
	precache_model(FegyverInfo[i][ModelName])
	precache_model("models/PT_Shediboii/caseasd.mdl");
	precache_sound("musickit/1.mp3");
	precache_sound("musickit/2.mp3");
	precache_sound("musickit/3.mp3");
	precache_sound("musickit/4.mp3");
	precache_sound("musickit/5.mp3");
	precache_sound("musickit/6.mp3");
	precache_sound("musickit/7.mp3");

	precache_model("models/player/balkam_romanov/balkam_romanov.mdl")
	precache_model("models/player/FBI_ava/FBI_ava.mdl")
/* 	precache_model("models/player/shedi_newmodels_T/shedi_newmodels_T.mdl")
	precache_model("models/player/shedi_newmodels_CT/shedi_newmodels_CT.mdl")
	precache_model("models/player/VIP_shedi_newmodels_T/VIP_shedi_newmodels_T.mdl")
	precache_model("models/player/VIP_shedi_newmodels_CT/VIP_shedi_newmodels_CT.mdl")
	precache_model("models/player/A_shedi_newmodels_T/A_shedi_newmodels_T.mdl")
	precache_model("models/player/A_shedi_newmodels_CT/A_shedi_newmodels_CT.mdl") */
}
public plugin_cfg() {

	g_SqlTuple = SQL_MakeDbTuple(sql_csatlakozas[0], sql_csatlakozas[1], sql_csatlakozas[2], sql_csatlakozas[3]);
	console_print(0, "**[#1]** Csatlakozva: %s", sql_csatlakozas[0])

	tabla_1();
	tabla_2();
	tabla_3();
	tabla_4();
	tabla_5();
	tabla_6();
	tabla_7();
	tabla_8();
	tabla_9();
	tabla_10();
	CreateTable_Player_Stats();
	LoadFragers();
}
public CreateTable_Player_Stats()
{
  new Len;
  static Query[10048];
  Len += formatex(Query[Len], charsmax(Query), "CREATE TABLE IF NOT EXISTS `PlayerStats` ");
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
	Len += formatex(Query[Len], charsmax(Query), "CREATE TABLE IF NOT EXISTS `Nevcedula` ");
	Len += formatex(Query[Len], charsmax(Query)-Len, "( ");
	Len += formatex(Query[Len], charsmax(Query)-Len, "`Id` INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,");
	
	for(new i;i < 200; i++)
		Len += formatex(Query[Len], charsmax(Query)-Len, "`N_%i` VARCHAR(32) NOT NULL,", i);
		
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
	if(FailState == TQUERY_CONNECT_FAILED)
		set_fail_state("[HIBA*] NEM TUDTAM CSATLAKOZNI AZ ADATBAZISHOZ!");
	else if(FailState == TQUERY_QUERY_FAILED)
		set_fail_state("Query Error");
	if(Errcode)
		log_amx("[HIBA*] HIBAT DOBTAM: %s",Error);
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
	Len += formatex(Query[Len], charsmax(Query), "CREATE TABLE IF NOT EXISTS `Profiles` ");
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
	Len += formatex(Query[Len], charsmax(Query), "CREATE TABLE IF NOT EXISTS `Skins` ");
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
	SQL_ThreadQuery(g_SqlTuple, ForwardMetod, Query, Data, 1);
}
public SMSMotd(id)
{
  new jatekfizetes[50] = "https://jatekfizetes.hu";
  new len;
  new StringMotd[2500]
  new year, month, day;
  date(year, month, day);

  len += formatex(StringMotd[len], charsmax(StringMotd) - len, "<HTML><HEAD><meta charset=^"UTF-8^"><TITLE>Prémium Pont Vásárlás</TITLE></HEAD>");
  len += formatex(StringMotd[len], charsmax(StringMotd) - len, "<BODY><center>");
  len += formatex(StringMotd[len], charsmax(StringMotd) - len, "<h1><center></center></h1><h2>Csomagok:</h2>")
  len += formatex(StringMotd[len], charsmax(StringMotd) - len, "Elkündendő üzenet:<b><h1> SYN marosi %i</h1></b><br><br>", g_Id[id])
  len += formatex(StringMotd[len], charsmax(StringMotd) - len, "<h2>FONTOS hogy a SYN, marosi és a szám között legyen egy-egy space!</h2><br><br>")
  if(month == 08 && day == 31 || month == 09 && day == 30 || month == 10 && day == 31 || month == 11 && day == 30 || month == 12 && day == 31 || month == 01 && day == 31)
  {
	len += formatex(StringMotd[len], charsmax(StringMotd) - len, "Jelenleg DUPLA Prémium Pont jóváírás van!<br>")
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
  show_motd(id, StringMotd, "[.:*[Dark*.*Angel'S]*:.] Prémium pont vásárlás | SMS");
}
public PayPalMotd(id)
{
  new len;
  new StringMotd[2500]
  len += formatex(StringMotd[len], charsmax(StringMotd) - len, "<HTML><HEAD><meta charset=^"UTF-8^"><TITLE>Prémium Pont Vásárlás</TITLE></HEAD>");
  len += formatex(StringMotd[len], charsmax(StringMotd) - len, "<BODY><center>");
  len += formatex(StringMotd[len], charsmax(StringMotd) - len, "<h1><center>PayPal Vásárlás</center></h1><h2>Csomagok:</h2>")
  len += formatex(StringMotd[len], charsmax(StringMotd) - len, "Elkündendő üzenet:<b><h1> PremiumPont (%i)</h1></b><br><br>", g_Id[id])
  len += formatex(StringMotd[len], charsmax(StringMotd) - len, "<h2>PayPal fiók email címe: csomoska60@gmail.com</h2><br><br>")
  len += formatex(StringMotd[len], charsmax(StringMotd) - len, "330 PP - 330FT<br>")
  len += formatex(StringMotd[len], charsmax(StringMotd) - len, "508 PP - 508FT<br>")
  len += formatex(StringMotd[len], charsmax(StringMotd) - len, "1016 PP - 1016FT<br>")
  len += formatex(StringMotd[len], charsmax(StringMotd) - len, "2032 PP - 2032FT<br>")
  len += formatex(StringMotd[len], charsmax(StringMotd) - len, "5080 PP - 5080FT<br><br>")
  len += formatex(StringMotd[len], charsmax(StringMotd) - len, "* <h1>Ha elküldted, akkor várj türelemmel, pár órán belűl jóváírjuk! Vagy keress fel egy tulajdonost!</h1><br>")
  len += formatex(StringMotd[len], charsmax(StringMotd) - len, "A feltüntetett összegek bruttó árakat tartalmaznak! (Végleges árak)<br>");
  show_motd(id, StringMotd, "[.:*[Dark*.*Angel'S]*:.] Prémium pont vásárlás | PayPal");
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
      new Temptarifa, Tempuserid, SynId, tempQuery[512], TempActive;
      new year, month, day;
      date(year, month, day);
      while(SQL_MoreResults(Query))
      {
        Tempuserid = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "comment"));
        TempActive = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Active"));
        for(new i; i < 33; i++)
        {
		if(Tempuserid == g_Id[i] && TempActive  == 1)
		{
			SynId = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "id"));
			Temptarifa = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "amount"));

			if(month == 08 && day == 31 || month == 09 && day == 30 || month == 10 && day == 31 || month == 11 && day == 30 || month == 12 && day == 31 || month == 01 && day == 31)
			{
				if(Temptarifa == 150)
				{
					premiumpont[i] += 400;
					client_print_color(i, print_team_default, "^3%s^1 Vásárlási tranzakció ^3(^4#%i^3) ^1|^3 Ár:^4 330FT ^1|^3 Jóváírt pontok:^4 400", PREFIX, SynId);
				}
				else if(Temptarifa == 240)
				{
					client_print_color(i, print_team_default, "^3%s^1 Vásárlási tranzakció ^3(^4#%i^3) ^1|^3 Ár:^4 508FT ^1|^3 Jóváírt pontok:^4 680", PREFIX, SynId);
					premiumpont[i] += 680;
				}
				else if(Temptarifa == 480)
				{
					client_print_color(i, print_team_default, "^3%s^1 Vásárlási tranzakció ^3(^4#%i^3) ^1|^3 Ár:^4 1016FT ^1|^3 Jóváírt pontok:^4 1160", PREFIX, SynId);
					premiumpont[i] += 1160;
				}
				else if(Temptarifa == 960)
				{
					client_print_color(i, print_team_default, "^3%s^1 Vásárlási tranzakció ^3(^4#%i^3) ^1|^3 Ár:^4 2032FT ^1|^3 Jóváírt pontok:^4 2200", PREFIX, SynId);
					premiumpont[i] += 2200;
				}
				else if(Temptarifa == 2400)
				{
					client_print_color(i, print_team_default, "^3%s^1 Vásárlási tranzakció ^3(^4#%i^3) ^1|^3 Ár:^4 5080FT ^1|^3 Jóváírt pontok:^4 6500", PREFIX, SynId);
					premiumpont[i] += 6500;
				}
			}
			else
			{
				if(Temptarifa == 150)
				{
					premiumpont[i] += 200;
					client_print_color(i, print_team_default, "^3%s^1 Vásárlási tranzakció ^3(^4#%i^3) ^1|^3 Ár:^4 330FT ^1|^3 Jóváírt pontok:^4 200", PREFIX, SynId);
				}
				else if(Temptarifa == 240)
				{
					client_print_color(i, print_team_default, "^3%s^1 Vásárlási tranzakció ^3(^4#%i^3) ^1|^3 Ár:^4 508FT ^1|^3 Jóváírt pontok:^4 340", PREFIX, SynId);
					premiumpont[i] += 340;
				}
				else if(Temptarifa == 330)
				{
					client_print_color(i, print_team_default, "^3%s^1 Vásárlási tranzakció ^3(^4#%i^3) ^1|^3 Ár:^4 330FT ^1|^3 Jóváírt pontok:^4 330", PREFIX, SynId);
					premiumpont[i] += 330;
				}
				else if(Temptarifa == 480)
				{
					client_print_color(i, print_team_default, "^3%s^1 Vásárlási tranzakció ^3(^4#%i^3) ^1|^3 Ár:^4 1016FT ^1|^3 Jóváírt pontok:^4 580", PREFIX, SynId);
					premiumpont[i] += 580;
				}
				else if(Temptarifa == 960)
				{
					client_print_color(i, print_team_default, "^3%s^1 Vásárlási tranzakció ^3(^4#%i^3) ^1|^3 Ár:^4 2032FT ^1|^3 Jóváírt pontok:^4 1100", PREFIX, SynId);
					premiumpont[i] += 1100;
				}
				else if(Temptarifa == 2400)
				{
					client_print_color(i, print_team_default, "^3%s^1 Vásárlási tranzakció ^3(^4#%i^3) ^1|^3 Ár:^4 5080FT ^1|^3 Jóváírt pontok:^4 3000", PREFIX, SynId);
					premiumpont[i] += 3000;
				}
			}
			AddErem(i, 12, 3)

			formatex(tempQuery, charsmax(tempQuery), "INSERT INTO `smslog` (`userid`, `tarifa`, `Active`) VALUES (%i, %i, 0);", Tempuserid,Temptarifa);
			SQL_ThreadQuery(g_SqlTuple, "QuerySetData", tempQuery);
			formatex(tempQuery, charsmax(tempQuery), "DELETE FROM `__syn_payments` WHERE `id` = %d;", SynId);
			SQL_ThreadQuery(g_SqlTuple, "QuerySetData", tempQuery);
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
	client_print_color(id, print_team_default, "%s ^3Nincs elérhetőséged^1 ehhez a parancshoz!");
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
	
	formatex(Query, charsmax(Query), "UPDATE `Profiles` SET `Admin_Szint` = %d WHERE `User_Id` = %d;", Arg_Int[1], Arg_Int[0]);
	SQL_ThreadQuery(g_SqlTuple, "QuerySetData", Query, Data, 1);
	
	if(Is_Online){
		if(Arg_Int[1] > 0)
			client_print_color(0, print_team_default, "%s Játékos: ^3%s ^1(#^3%d^1) | %s jogot kapott! ^3%s^1(#^3%d^1) által!", PREFIX, Player[Is_Online][f_PlayerNames], Arg_Int[0], Admin_Permissions[Arg_Int[1]][0], szName, g_Id[id]);	
		else
			client_print_color(0, print_team_default, "%s Játékos: ^3%s ^1(#^3%d^1) | Jogok megvonva! ^3%s^1(#^3%d^1) által!", PREFIX, Player[Is_Online][f_PlayerNames], Arg_Int[0], szName,  g_Id[id]);	
		
		Set_Permissions(Is_Online);
		g_Admin_Level[Is_Online] = Arg_Int[1];
	}
	else{
		if(Arg_Int[1] > 0)
			client_print_color(0, print_team_default, "%s Játékos: ^3- ^1(#^3%d^1) | %s jogot kapott! ^3%s^1(#^3%d^1) által!", PREFIX, Arg_Int[0], Admin_Permissions[Arg_Int[1]][0], szName, g_Id[id]);	
		else
			client_print_color(0, print_team_default, "%s Játékos: ^3- ^1(#^3%d^1) | Jogok megvonva! ^3%s^1(#^3%d^1) által!", PREFIX, Arg_Int[0], szName, g_Id[id]);		
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
	formatex(szMenu, charsmax(szMenu), "%s^nFegyver kiegészítők / Extrák", MENUPREFIX)
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
				client_print_color(id, print_team_default, "^4%s ^1Nem szerelhetsz fel Névcédulát amíg valamelyik tárgyad a Piacon van vagy kivan választva!", PREFIX)
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
	formatex(szMenu, charsmax(szMenu), "%s^nVálaszd ki a fegyvert", MENUPREFIX)
	new menu = menu_create(szMenu, "hAddStat");
	new fegyver = sizeof(FegyverInfo)
 
	for(new i;i < fegyver; i++)
	{
		if(g_Weapons[i][id] > 0)
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
	
	if(g_Weapons[key][id] == g_StatTrak[key][id]) client_print_color(id, print_team_default, "^4%s ^1Nincs elég fegyvered a raktárba!", PREFIX)
	else {
		g_StatTrak[key][id]++
		g_StatTrakKills[key][id] = 0;
		g_Tools[0][id]--
		client_print_color(id, print_team_default, "^4%s ^3StatTrak* ^1Tool sikeresen felszerelve!", PREFIX)
	}
	
	openTools(id)
	
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public openAddNameTag(id)
{
	new szMenu[121],String[6] ,cim[121]
	formatex(szMenu, charsmax(szMenu), "%s^nVálaszd ki azt a fegyvered amit elszeretnél nevezni!", MENUPREFIX)
	new menu = menu_create(szMenu, "hAddName");
	new fegyver = sizeof(FegyverInfo)
 
	for(new i;i < fegyver; i++)
	{
		if(g_Weapons[i][id] > 0)
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
		client_print_color(id, print_team_default, "^4%s ^1Ez a fegyver már egyszer ellett nevezve!", PREFIX)
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
		client_print_color(id, print_team_default, "^4%s ^1A Fegyver Név nem lehet rövidebb 3, illetve hosszabb 24 karakternél, vagy ne használj ' jelet!", PREFIX)
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
		
	client_print_color(id, print_team_default, "^4%s ^1A Fegyver neve mostantól: ^3%s", PREFIX, g_GunNames[g_NameTagKey][id])
	g_Tools[1][id]--
	openTools(id)
	return PLUGIN_HANDLED
}
public Piac(id)
{
	new iras[121]
	format(iras, charsmax(iras), "\y%s^nPiac Elosztó", MENUPREFIX);
	new menu = menu_create(iras, "Piac_h");
	
	menu_additem(menu, "Vásárlás", "1", 0);
	menu_additem(menu, "Eladás", "2", 0);
	menu_additem(menu, "\y[\w\rItem\y/\rSkin\w Küldés\y]", "3", 0);

	/*if(Elhasznal[0][id] == 1) format(String,charsmax(String),"Kezdő Csomag \r[\dElhasználva\r]");
	else format(String,charsmax(String),"Kezdő Csomag \r[\yElérhető\r]");
	menu_additem(menu,String,"5");

	if(Elhasznal[4][id] == 1) format(String,charsmax(String),"Ajándék Csomag \r[\dElhasználva\r]");
	else format(String,charsmax(String),"Ajándék Csomag \r[\yElérhető\r]");
	menu_additem(menu,String,"10");
	
	 if(masodpercek[id] > 36000 && Elhasznal[1][id] == 1) 
		format(String,charsmax(String),"Gyakornok Csomag \r[\dElhasználva\r]");
	else if(masodpercek[id] > 36000)
		format(String,charsmax(String),"Gyakornok Csomag \r[\yElérhető\r]");
	else
		format(String,charsmax(String),"Gyakornok Csomag \r[\d10 Óra Játékidő\r]");
	menu_additem(menu,String,"6");
	
	if(masodpercek[id] > 172800 && Elhasznal[2][id] == 1) 
		format(String,charsmax(String),"Profi Csomag \r[\dElhasználva\r]");
	else if(masodpercek[id] > 172800)
		format(String,charsmax(String),"Profi Csomag \r[\yElérhető\r]");
	else
		format(String,charsmax(String),"Profi Csomag \r[\d2 Nap Játékidő\r]");
	menu_additem(menu,String,"7");
	
	if(masodpercek[id] > 432000 && Elhasznal[3][id] == 1) 
		format(String,charsmax(String),"Veterán Csomag \r[\dElhasználva\r]");
	else if(masodpercek[id] > 432000)
		format(String,charsmax(String),"Veterán Csomag \r[\yElérhető\r]");
	else
		format(String,charsmax(String),"Veterán Csomag \r[\d5 Nap Játékidő\r]");
	menu_additem(menu,String,"8"); */
	
	if(g_Admin_Level[id] == 2)
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
			
			formatex(Query, charsmax(Query), "UPDATE `Profiles` SET `Elhasznalva5` = 1 WHERE `User_Id` = %d;", g_Id[id]);
			SQL_ThreadQuery(g_SqlTuple, "QuerySetData", Query, Data, 1);
			client_print_color(id, print_team_default, "^4%s^3 Sikeresen ^1megkaptad az ^4Ajándék Csomagot^1! ^3(^4 Random dolog^3 )", PREFIX);

			switch(random_num(1, 2))
			{	
				case 1:
				{
					new Float:dollaresely = random_float(2.00, 10.00);
					g_dollar[id] += dollaresely;
					client_print_color(id, print_team_default, "^4%s^1 Az ajándékcsomag ezt tartalmazta: ^4%3.2f^1 dollár.", PREFIX, dollaresely);
				}
				case 2:
				{
					new dollaresely = random_num(50, 100);
					Darkpont[id] += dollaresely;
					client_print_color(id, print_team_default, "^4%s^1 Az ajándékcsomag ezt tartalmazta: ^4%i^1 Darkpont.", PREFIX, dollaresely);
				}
			}
		}
		else{
			client_print_color(id, print_team_default, "^4%s^3 Sajnálom, ^1de te már elhasználtad ezt a ^3csomagot!", PREFIX);
		}
	}
	public StarterPack(id)
	{
		if(Elhasznal[0][id] == 0)
		{
			Darkpont[id] += 50;
			g_dollar[id] += 20.00;
			Elhasznal[0][id] = 1;
			new Data[1];
			static Query[10048];
			Data[0] = id;

			
			formatex(Query, charsmax(Query), "UPDATE `Profiles` SET `Elhasznalva1` = 1 WHERE `User_Id` = %d;", g_Id[id]);
			SQL_ThreadQuery(g_SqlTuple, "QuerySetData", Query, Data, 1);
			client_print_color(id, print_team_default, "^4%s^3 Sikeresen ^1megkaptad a ^4Kezdő Csomagot^1! ^3(^4 20.00^1$ ^3és^4 50^1 PerFecT Pont^3 )", PREFIX);
		}
		else{
			client_print_color(id, print_team_default, "^4%s^3 Sajnálom, ^1de te már elhasználtad ezt a ^3csomagot!", PREFIX);
		}
	}
	public GyakornokPack(id)
	{
		if(Elhasznal[1][id] == 0 && masodpercek[id] > 36000)
		{
			new Data[1];
			static Query[10048];
			Data[0] = id;
			
			formatex(Query, charsmax(Query), "UPDATE `Profiles` SET `Elhasznalva2` = 1 WHERE `User_Id` = %d;", g_Id[id]);
			SQL_ThreadQuery(g_SqlTuple, "QuerySetData", Query, Data, 1);
			Darkpont[id] += 200;
			g_dollar[id] += 50.00;
			//Lada[0][id] += 5;
			//LadaK[0][id] += 5;
			Elhasznal[1][id] = 1;
			client_print_color(id, print_team_default, "^4%s^3 Sikeresen ^1megkaptad a ^4Gyakornok Csomagot^1! ^3(^4 50.00^1$ ^3és^4 200^1 PerFecT Pont ^3)", PREFIX);
		}
		else if(masodpercek[id] > 36000)
		{
			client_print_color(id, print_team_default, "^4%s^3 Sajnálom, ^1de te már elhasználtad ezt a ^3csomagot!", PREFIX);
		}
		else{
			client_print_color(id, print_team_default, "Sajnálom, ^1de neked nincs^3 10 óra^1 játszott időd hogy elhasználhasd ezt a ^3csomagot!", PREFIX);
		}
	}
	public ProfiPack(id)
	{
		if(Elhasznal[2][id] == 0 && masodpercek[id] > 172800)
		{
			new Data[1];
			static Query[10048];
			Data[0] = id;
			
			formatex(Query, charsmax(Query), "UPDATE `Profiles` SET `Elhasznalva3` = 1 WHERE `User_Id` = %d;", g_Id[id]);
			SQL_ThreadQuery(g_SqlTuple, "QuerySetData", Query, Data, 1);
			Darkpont[id] += 500;
			g_dollar[id] += 100.00;
			Lada[3][id] += 15;
			//LadaK[3][id] += 15;
			Elhasznal[2][id] = 1;
			client_print_color(id, print_team_default, "^4%s^3 Sikeresen ^1megkaptad a ^4Profi Csomagot^1! ^3(^4 100.00^1$ ^3és^4 500^1 PerFecT Pont^3)", PREFIX);
		}
		else if(masodpercek[id] > 172800)
		{
			client_print_color(id, print_team_default, "^4%s^3 Sajnálom, ^1de te már elhasználtad ezt a ^3csomagot!", PREFIX);
		}
		else{
			client_print_color(id, print_team_default, "Sajnálom, ^1de neked nincs^3 2 nap^1 játszott időd hogy elhasználhasd ezt a ^3csomagot!", PREFIX);
		}
	}
	public VeteranPack(id)
	{
		if(Elhasznal[3][id] == 0 && masodpercek[id] > 432000)
		{
			new Data[1];
			static Query[10048];
			Data[0] = id;
			
			formatex(Query, charsmax(Query), "UPDATE `Profiles` SET `Elhasznalva4` = 1 WHERE `User_Id` = %d;", g_Id[id]);
			SQL_ThreadQuery(g_SqlTuple, "QuerySetData", Query, Data, 1);
			Darkpont[id] += 1500;
			g_dollar[id] += 300.00;
			Lada[4][id] += 15;
			//LadaK[4][id] += 15;
			Elhasznal[3][id] = 1;
			client_print_color(id, print_team_default, "^4%s^3 Sikeresen ^1megkaptad a ^4Veterán Csomagot^1! ^3(^4 300^1$ ^3és^4 1500^1 PerFecT Pont ^3)", PREFIX);
		}
		else if(masodpercek[id] > 432000)
		{
			client_print_color(id, print_team_default, "^4%s^3 Sajnálom, ^1de te már elhasználtad ezt a ^3csomagot!", PREFIX);
		}
		else{
			client_print_color(id, print_team_default, "^4%s^3 Sajnálom, ^1de neked nincs^3 5 nap^1 játszott időd hogy elhasználhasd ezt a ^3csomagot!", PREFIX);
		}
	}
	public TulajPack(id)
	{	
		g_Tools[0][id] += 100;
		g_Tools[1][id] += 100;
		g_dollar[id] += 100.00;
		for(new i;i < FEGYO; i++)
		g_Weapons[i][id] += 1;
		for(new i;i < LADASZAM; i++)
		Lada[i][id] += 100;
		
		client_print_color(id, print_team_default, "^4%s^3 Sikeresen ^1megkaptad a ^4Tulaj Csomagot^1! ^3(^4MINDEN CUCC^3)", PREFIX);
	}
public openSeller(id) {
	new szMenu[121]
	formatex(szMenu, charsmax(szMenu), "%s^n \wPiac | Eladás^nDollár: \d%3.2f$", MENUPREFIX, g_dollar[id])
	new menu = menu_create(szMenu, "hEladas");
	
	if(g_Erteke[id] != 0.0 && g_Kirakva[id] == 1) menu_additem(menu,"\dTárgy visszavonása a Piacról!", "0",0)
	if(g_Kirakva[id] == 0){
		if(g_Kicucc[id] <= 135) {
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
	
		if(FegyverInfo[g_Kicucc[id]][PiacraHelyezheto] == 1 && g_Erteke[id] > 0) 
		menu_additem(menu,"\dKirakás a Piacra!","5",0)
		else
		menu_additem(menu,"\rEz az item nem helyezhető ki!","-1",0)
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
					if(strlen(g_GunNames[g_Kicucc[id]][id]) < 1 && g_NameTagBeKi[id]) client_print_color(0, print_team_default, "^4%s ^3%s ^1kirakott egy ^3%s%s ^1fegyvert a Piacra ^4%3.2f$^1-ért!", PREFIX, iName, g_StatTrakBeKi[id] ? "StatTrak* ":"", g_GunNames[g_Kicucc[id]][id], g_Erteke[id])
					else if(strlen(g_GunNames[g_Kicucc[id]][id]) > 0 && !g_NameTagBeKi[id]) client_print_color(0, print_team_default, "^4%s ^3%s ^1kirakott egy ^3%s%s ^1fegyvert a Piacra ^4%3.2f$^1-ért!", PREFIX, iName, g_StatTrakBeKi[id] ? "StatTrak* ":"", FegyverInfo[g_Kicucc[id]][GunName], g_Erteke[id])
					else if(strlen(g_GunNames[g_Kicucc[id]][id]) > 0 && g_NameTagBeKi[id]) client_print_color(0, print_team_default, "^4%s ^3%s ^1kirakott egy ^3%s%s ^1fegyvert a Piacra ^4%3.2f$^1-ért!", PREFIX, iName, g_StatTrakBeKi[id] ? "StatTrak* ":"", g_GunNames[g_Kicucc[id]][id], g_Erteke[id])
					else if(strlen(g_GunNames[g_Kicucc[id]][id]) < 1 && !g_NameTagBeKi[id]) client_print_color(0, print_team_default, "^4%s ^3%s ^1kirakott egy ^3%s%s ^1fegyvert a Piacra ^4%3.2f$^1-ért!", PREFIX, iName, g_StatTrakBeKi[id] ? "StatTrak* ":"", FegyverInfo[g_Kicucc[id]][GunName], g_Erteke[id])
					g_Kirakva[id] = 1
					OsszesKirakott[0]++
				}
				else if(g_StatTrakBeKi[id] && g_StatTrak[g_Kicucc[id]][id] == 0) {
					g_StatTrakBeKi[id] = false
					openSeller(id)
					client_print_color(id, print_team_default, "^4%s ^1Ehhez a fegyverhez nincs ^3StatTrak* Tool^1-od!", PREFIX)
				}
			}
			else {
				client_print_color(0, print_team_default, "^4%s ^3%s ^1kirakott egy ^3%s ^1tárgyat a Piacra ^4%3.2f$^1-ért!", PREFIX, iName, FegyverInfo[g_Kicucc[id]][GunName], g_Erteke[id])
				format_time(sztime, charsmax(sztime), "%Y.%m.%d - %H:%M:%S", get_systime())
				format_time(sztime1, charsmax(sztime1), "%Y.%m.%d", get_systime())
				log_to_file("eladas.txt", "%s kirakott egy %s tárgyat a Piacra %3.2f$-ért!", iName, FegyverInfo[g_Kicucc[id]][GunName], g_Erteke[id])
				g_Kirakva[id] = 1
				if(g_Kicucc[id] >= 136 && g_Kicucc[id] <= 147) OsszesKirakott[1]++
				else if(g_Kicucc[id] >= 148 && g_Kicucc[id] <= 159) OsszesKirakott[2]++
				else if(g_Kicucc[id] >= 160) OsszesKirakott[3]++
			}
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
		client_print_color(id, print_team_default, "^4%s ^1Nem tudsz eladni^3 100000.00$ ^1felett!", PREFIX)
		client_cmd(id, "messagemode DOLLAR_AR")
	}
	else if(iErtek < 0.01) {
		client_print_color(id, print_team_default, "^4%s ^1Nem tudsz eladni^3 0.01$ ^1alatt!", PREFIX)
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
	formatex(szMenu, charsmax(szMenu), "%s^nVálassz egy Tárgyat", MENUPREFIX)
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
		
	formatex(szMenu, charsmax(szMenu), "%s^n \wPiac | Fegyver Vásárlás^nDollár: \d%3.2f", MENUPREFIX, g_dollar[id])
	new menu = menu_create(szMenu, "hBuyItems1");
	
	for(new i; i < pnum; i++)
	{	
	if(g_Kirakva[players[i]] == 1 && g_Erteke[players[i]] > 0.00 && g_Kicucc[players[i]] <= 135)
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
		if(!g_NameTagBeKi[player]) client_print_color(0, print_team_default, "^4%s ^3%s ^1vett egy ^4%s%s ^1fegyvert ^3%s^1-tól ^4%3.2f$^1-ért!", PREFIX, name, g_StatTrakBeKi[player] ? "StatTrak* ":"", FegyverInfo[g_Kicucc[player]][GunName], name2, g_Erteke[player])
		else client_print_color(0, print_team_default, "^4%s ^3%s ^1vett egy ^4%s%s ^1fegyvert ^3%s^1-tól ^4%3.2f$^1-ért!", PREFIX, name, g_StatTrakBeKi[player] ? "StatTrak* ":"", g_GunNames[g_Kicucc[player]][player], name2, g_Erteke[player])
			
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
		client_print_color(id, print_team_default, "^4%s ^1Nincs elég dollárod!", PREFIX)
		openBuyer1(id)
	}
	menu_destroy(menu)
	return PLUGIN_HANDLED
}
public openSending(id){
	new szMenu[191]
	formatex(szMenu, charsmax(szMenu), "\d\y%s^n \wMit szeretnél küldeni?", MENUPREFIX)
	new menu = menu_create(szMenu, "hSending");
	
	menu_additem(menu, "\yItem \wKüldés", "0", 0);
	//menu_additem(menu, "\yLáda \wKüldés", "1", 0);
	//menu_additem(menu, "\yKulcs \wKüldés", "2", 0);
	menu_additem(menu, "\ySkin \wKüldés", "1", 0);

	
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
	}
	
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public openPlayerChooser(id) {
	new szMenu[121], players[32], pnum, iName[32], szTempid[10]
	get_players(players, pnum)
 
	formatex(szMenu, charsmax(szMenu), "\r%s \wVálassz ki egy játékost!", MENUPREFIX)
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
		client_print_color(id, print_team_default, "^4%s ^1Nem küldhetsz semmit amíg valamelyik tárgyad a Piacon van vagy kivan választva!", PREFIX)
		menu_destroy(menu);
		return PLUGIN_HANDLED
	}
	
	if(id == g_kUserID[id]) {
		client_print_color(id, print_team_default, "^4%s ^1Magadnak nem küldhetsz semmit!", PREFIX)
		menu_destroy(menu);
		return PLUGIN_HANDLED
	}
	
	if(id == g_kUserID[id]) {
		client_print_color(id, print_team_default,  "^4%s ^1Magadnak nem küldhetsz semmit!", PREFIX)
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
 
	formatex(szMenu, charsmax(szMenu), "\r%s \wVálassz ki egy játékost!", MENUPREFIX)
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

	client_print_color(id, print_team_default, "^3[^4.:*[^3Dark^4*.*^3Angel'^1S^4]*:.^3]^1 Te most %s %s.", g_Mute[id][key] ? "^3némítottad^4": "^4hallod^3", Player[key][f_PlayerNames])
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
		client_print_color(id, print_team_default,  "^4%s ^1Maximum^3 100000.00$^1-t küldhetsz!", PREFIX)
		client_cmd(id, "messagemode DOLLAR_KULDES");
		return PLUGIN_HANDLED;
	}
	else if(iErtek < 0.01) {
		client_print_color(id, print_team_default,  "^4%s ^1Minimum^3 0.01$^1-t küldhetsz!", PREFIX)
		client_cmd(id, "messagemode DOLLAR_KULDES");
		return PLUGIN_HANDLED;
	}
	if(g_dollar[id] >= iErtek) {
		g_dollar[g_kUserID[id]] += iErtek + 0.009
		g_dollar[id] -= iErtek + 0.009
		client_print_color(0, print_team_default,  "^4%s ^3%s ^1küldött ^3%s^1-nak ^4%3.2f$^1-t!", PREFIX, iName, tName, iErtek + 0.009)
	}
	else client_print_color(id, print_team_default,  "^4%s ^1Nincs elég dollárod!", PREFIX)
	return PLUGIN_HANDLED;
}
public openSendSkinMenu(id) {
	new szMenu[121]
	formatex(szMenu, charsmax(szMenu), "\d\y%s^n \wSkin Küldés", MENUPREFIX)
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
				client_print_color(id, print_team_default,  "^4%s ^1Ehhez a fegyverhez nincs ^3StatTrak* Tool^1-od!", PREFIX)
			}
		}
	}
	menu_destroy(menu)
	return PLUGIN_HANDLED
}
public openSendSelItem(id)
{
	new szMenu[121], String[6]
	formatex(szMenu, charsmax(szMenu), "\d\y%s^n\wVálassz egy Fegyvert", MENUPREFIX)
	new menu = menu_create(szMenu, "hSendSelItem");
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
public SendMenu(id) 
{
	new String[121], menu;
	menu = menu_create("\dKüldés:", "SendHandler");
	
	format(String, charsmax(String), "Dollár \d[\r%3.2f \d$]", g_dollar[id]);
	menu_additem(menu, String, "0", 0);
	format(String, charsmax(String), "Kulcs \d[\r0 \dDB]" );
	menu_additem(menu, String, "1", 0);
	format(String, charsmax(String), "PerFecT Pont \d[\r0 \dPont]");
	menu_additem(menu, String, "2", 0);
	format(String, charsmax(String), "1 Napos VIPKupon \d[\r0]");
	menu_additem(menu, String, "3", 0);
	format(String, charsmax(String), "3 Napos VIPKupon \d[\r0]");
	menu_additem(menu, String, "4", 0);
	format(String, charsmax(String), "7 Napos VIPKupon \d[\r0]");
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
	format(String, charsmax(String), "%s \d[\r%d \dDB]", LadaKNevek[0][0], LadaK[0][id]);
	menu_additem(menu, String, "12", 0);
	format(String, charsmax(String), "%s \d[\r%d \dDB]", LadaKNevek[1][0], LadaK[1][id]);
	menu_additem(menu, String, "13", 0);
	format(String, charsmax(String), "%s \d[\r%d \dDB]", LadaKNevek[2][0], LadaK[2][id]);
	menu_additem(menu, String, "14", 0);
	format(String, charsmax(String), "%s \d[\r%d \dDB]", LadaKNevek[3][0], LadaK[3][id]);
	menu_additem(menu, String, "15", 0);
	format(String, charsmax(String), "%s \d[\r%d \dDB]", LadaKNevek[4][0], LadaK[4][id]);
	menu_additem(menu, String, "16", 0);
	format(String, charsmax(String), "%s \d[\r%d \dDB]", LadaKNevek[5][0], LadaK[5][id]);
	menu_additem(menu, String, "17", 0);
	format(String, charsmax(String), "%s \d[\r%d \dDB]", LadaNevek[6][0], Lada[6][id]);
	menu_additem(menu, String, "18", 0);
	format(String, charsmax(String), "%s \d[\r%d \dDB]", LadaKNevek[5][0], LadaK[6][id]);
	menu_additem(menu, String, "19", 0);
	//format(String, charsmax(String), "%s \d[\r%d \dDB]", LadaNevek[5][0], Lada[5][id]);
	//menu_additem(menu, String, "11", 0);
	
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
	
	Send[id] = Key+1;
	
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

	if(Send[id] == 1 && g_dollar[id] >= str_to_num(Data))
	{
		g_dollar[TempID] += str_to_num(Data);
		g_dollar[id] -= str_to_num(Data);
		log_to_file("kuldes.txt", " %s Küldött %d Dollár-t %s-nak",SendName, str_to_num(Data), TempName)
		client_print_color(0, print_team_default, "%s^3%s ^1Küldött ^4%d Dollár^1-t ^3%s^1-nak", PREFIX, SendName, str_to_num(Data), TempName);
		targykuldes[id] = 0;
	}
	if(Send[id] == 2 && g_ASD[id] > 1 >= str_to_num(Data))
	{
		//Kulcs[TempID] += str_to_num(Data);
		//Kulcs[id] -= str_to_num(Data);
		log_to_file("kuldes.txt", "%s Küldött %d Dollár-t %s-nak",SendName, TempName, str_to_num(Data))
		client_print_color(0, print_team_default, "%s ^3%s ^1Küldött ^3%s^1-nak ^4%d db Kulcs^1-t", PREFIX, SendName, TempName, str_to_num(Data));
		targykuldes[id] = 0;
	}
	/*
	if(Send[id] == 3 && Darkpont[id] >= str_to_num(Data))
	{
		Darkpont[TempID] += str_to_num(Data);
		Darkpont[id] -= str_to_num(Data);
		ColorChat(0, GREEN, "%s^3%s ^1Küldött ^4%d PerFecT Pontot^1-t ^3%s^1-nak", PREFIX, SendName, str_to_num(Data), TempName);
	}
	if(Send[id] == 4 && g_VipKupon[0][id] >= str_to_num(Data))
	{
		g_VipKupon[0][TempID] += str_to_num(Data);
		g_VipKupon[0][id] -= str_to_num(Data);
		ColorChat(0, GREEN, "%s^3%s ^1Küldött ^4%d 1 Napos VIP Kupon^1-t ^3%s^1-nak", PREFIX, SendName, str_to_num(Data), TempName);
	}
	if(Send[id] == 5 && g_VipKupon[1][id] >= str_to_num(Data))
	{
		g_VipKupon[1][TempID] += str_to_num(Data);
		g_VipKupon[1][id] -= str_to_num(Data);
		ColorChat(0, GREEN, "%s^3%s ^1Küldött ^4%d 3 Napos VIP Kupon^1-t ^3%s^1-nak", PREFIX, SendName, str_to_num(Data), TempName);
	}
	if(Send[id] == 6 && g_VipKupon[2][id] >= str_to_num(Data))
	{
		g_VipKupon[2][TempID] += str_to_num(Data);
		g_VipKupon[2][id] -= str_to_num(Data);
		ColorChat(0, GREEN, "%s^3%s ^1Küldött ^4%d 7 Napos VIP Kupon^1-t ^3%s^1-nak", PREFIX, SendName, str_to_num(Data), TempName);
	}
	*/
	if(Send[id] == 7 && Lada[0][id] >= str_to_num(Data))
	{
		Lada[0][TempID] += str_to_num(Data);
		Lada[0][id] -= str_to_num(Data);
		log_to_file("kuldes.txt", "%s Küldött %d %s-t %s-nak",  SendName, str_to_num(Data), LadaNevek[0][0], TempName)
		client_print_color(0, print_team_default, "%s^3%s ^1Küldött ^4%d %s^1-t ^3%s^1-nak", PREFIX, SendName, str_to_num(Data), LadaNevek[0][0], TempName);
	}
	if(Send[id] == 8 && Lada[1][id] >= str_to_num(Data))
	{
		Lada[1][TempID] += str_to_num(Data);
		Lada[1][id] -= str_to_num(Data);
		log_to_file("kuldes.txt", "%s Küldött %d %s-t %s-nak",  SendName, str_to_num(Data), LadaNevek[1][0], TempName)
		client_print_color(0, print_team_default, "%s^3%s ^1Küldött ^4%d %s^1-t ^3%s^1-nak", PREFIX, SendName, str_to_num(Data), LadaNevek[1][0], TempName);
	}
	if(Send[id] == 9 && Lada[2][id] >= str_to_num(Data))
	{
		Lada[2][TempID] += str_to_num(Data);
		Lada[2][id] -= str_to_num(Data);
		log_to_file("kuldes.txt", "%s Küldött %d %s-t %s-nak",  SendName, str_to_num(Data), LadaNevek[2][0], TempName)
		client_print_color(0, print_team_default, "%s^3%s ^1Küldött ^4%d %s^1-t ^3%s^1-nak", PREFIX, SendName, str_to_num(Data), LadaNevek[2][0], TempName);
	}
	if(Send[id] == 10 && Lada[3][id] >= str_to_num(Data))
	{
		Lada[3][TempID] += str_to_num(Data);
		Lada[3][id] -= str_to_num(Data);
		log_to_file("kuldes.txt", "%s Küldött %d %s-t %s-nak",  SendName, str_to_num(Data), LadaNevek[3][0], TempName)
		client_print_color(0, print_team_default, "%s^3%s ^1Küldött ^4%d %s^1-t ^3%s^1-nak", PREFIX, SendName, str_to_num(Data), LadaNevek[3][0], TempName);
	}
	if(Send[id] == 11 && Lada[4][id] >= str_to_num(Data))
	{
		Lada[4][TempID] += str_to_num(Data);
		Lada[4][id] -= str_to_num(Data);
		log_to_file("kuldes.txt", "%s Küldött %d %s-t %s-nak",  SendName, str_to_num(Data), LadaNevek[4][0], TempName)
		client_print_color(0, print_team_default, "%s^3%s ^1Küldött ^4%d %s^1-t ^3%s^1-nak", PREFIX, SendName, str_to_num(Data), LadaNevek[4][0], TempName);
	}
	
	if(Send[id] == 12 && Lada[5][id] >= str_to_num(Data))
	{
		Lada[5][TempID] += str_to_num(Data);
		Lada[5][id] -= str_to_num(Data);
		log_to_file("kuldes.txt", "%s Küldött %d %s-t %s-nak",  SendName, str_to_num(Data), LadaNevek[5][0], TempName)
		client_print_color(0, print_team_default, "%s^3%s ^1Küldött ^4%d %s^1-t ^3%s^1-nak", PREFIX, SendName, str_to_num(Data), LadaNevek[5][0], TempName);
	}
	if(Send[id] == 13 && LadaK[0][id] >= str_to_num(Data))
	{
		LadaK[0][TempID] += str_to_num(Data);
		LadaK[0][id] -= str_to_num(Data);
		log_to_file("kuldes.txt", "%s Küldött %d %s-t %s-nak",  SendName, str_to_num(Data), LadaKNevek[0][0], TempName)
		client_print_color(0, print_team_default, "%s^3%s ^1Küldött ^4%d %s^1-t ^3%s^1-nak", PREFIX, SendName, str_to_num(Data), LadaKNevek[0][0], TempName);
	}
	if(Send[id] == 14 && LadaK[1][id] >= str_to_num(Data))
	{
		LadaK[1][TempID] += str_to_num(Data);
		LadaK[1][id] -= str_to_num(Data);
		log_to_file("kuldes.txt", "%s Küldött %d %s-t %s-nak",  SendName, str_to_num(Data), LadaKNevek[1][0], TempName)
		client_print_color(0, print_team_default, "%s^3%s ^1Küldött ^4%d %s^1-t ^3%s^1-nak", PREFIX, SendName, str_to_num(Data), LadaKNevek[1][0], TempName);
	}
	if(Send[id] == 15 && LadaK[2][id] >= str_to_num(Data))
	{
		LadaK[2][TempID] += str_to_num(Data);
		LadaK[2][id] -= str_to_num(Data);
		log_to_file("kuldes.txt", "%s Küldött %d %s-t %s-nak",  SendName, str_to_num(Data), LadaKNevek[2][0], TempName)
		client_print_color(0, print_team_default, "%s^3%s ^1Küldött ^4%d %s^1-t ^3%s^1-nak", PREFIX, SendName, str_to_num(Data), LadaKNevek[2][0], TempName);
	}
	if(Send[id] == 16 && LadaK[3][id] >= str_to_num(Data))
	{
		LadaK[3][TempID] += str_to_num(Data);
		LadaK[3][id] -= str_to_num(Data);
		log_to_file("kuldes.txt", "%s Küldött %d %s-t %s-nak",  SendName, str_to_num(Data), LadaKNevek[3][0], TempName)
		client_print_color(0, print_team_default, "%s^3%s ^1Küldött ^4%d %s^1-t ^3%s^1-nak", PREFIX, SendName, str_to_num(Data), LadaKNevek[3][0], TempName);
	}
	if(Send[id] == 17 && LadaK[4][id] >= str_to_num(Data))
	{
		LadaK[4][TempID] += str_to_num(Data);
		LadaK[4][id] -= str_to_num(Data);
		log_to_file("kuldes.txt", "%s Küldött %d %s-t %s-nak",  SendName, str_to_num(Data), LadaKNevek[4][0], TempName)
		client_print_color(0, print_team_default, "%s^3%s ^1Küldött ^4%d %s^1-t ^3%s^1-nak", PREFIX, SendName, str_to_num(Data), LadaKNevek[4][0], TempName);
	}
	if(Send[id] == 18 && LadaK[5][id] >= str_to_num(Data))
	{
		LadaK[5][TempID] += str_to_num(Data);
		LadaK[5][id] -= str_to_num(Data);
		log_to_file("kuldes.txt", "%s Küldött %d %s-t %s-nak",  SendName, str_to_num(Data), LadaKNevek[5][0], TempName)
		client_print_color(0, print_team_default, "%s^3%s ^1Küldött ^4%d %s^1-t ^3%s^1-nak", PREFIX, SendName, str_to_num(Data), LadaKNevek[5][0], TempName);
	}
	if(Send[id] == 19 && Lada[6][id] >= str_to_num(Data))
	{
		Lada[6][TempID] += str_to_num(Data);
		Lada[6][id] -= str_to_num(Data);
		log_to_file("kuldes.txt", "%s Küldött %d %s-t %s-nak",  SendName, str_to_num(Data), LadaNevek[6][0], TempName)
		client_print_color(0, print_team_default, "%s^3%s ^1Küldött ^4%d %s^1-t ^3%s^1-nak", PREFIX, SendName, str_to_num(Data), LadaNevek[6][0], TempName);
	}
	if(Send[id] == 20 && LadaK[6][id] >= str_to_num(Data))
	{
		LadaK[6][TempID] += str_to_num(Data);
		LadaK[6][id] -= str_to_num(Data);
		log_to_file("kuldes.txt", "%s Küldött %d %s-t %s-nak",  SendName, str_to_num(Data), LadaKNevek[6][0], TempName)
		client_print_color(0, print_team_default, "%s^3%s ^1Küldött ^4%d %s^1-t ^3%s^1-nak", PREFIX, SendName, str_to_num(Data), LadaKNevek[6][0], TempName);
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
		client_print_color(id, print_team_default,  "^4%s ^1Minimum csak 1 darab skint küldhetsz!", PREFIX)
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
				client_print_color(id, print_team_default,  "^4%s ^1Ehhez a fegyverhez nincs elég ^3StatTrak Tool^1-od!", PREFIX)
				return PLUGIN_HANDLED
			}
			if(g_NameTagBeKiSend[id] && strlen(g_GunNames[g_ChooseThings[2][id]][id]) > 0){
				g_GunNames[g_ChooseThings[2][id]][g_kUserID[id]] = g_GunNames[g_ChooseThings[2][id]][id]
				g_GunNames[g_ChooseThings[2][id]][id][0] = EOS
			}
			else if(g_NameTagBeKiSend[id] && strlen(g_GunNames[g_ChooseThings[2][id]][id]) <= 0){
				g_NameTagBeKiSend[id] = false
				client_print_color(id, print_team_default,  "^4%s ^1Ez a fegyver nincs elnevezve!", PREFIX)
				return PLUGIN_HANDLED
			}
			if(!g_NameTagBeKiSend[id]) client_print_color(0, print_team_default,  "^4%s ^3%s ^1küldött ^3%s^1-nak ^3%i ^1DB ^4%s%s ^1fegyvert!", PREFIX, iName, tName, iErtek, g_StatTrakBeKiSend[id] ? "StatTrak* ":"", FegyverInfo[g_ChooseThings[2][id]][GunName])
			else
			{
				client_print_color(0, print_team_default,  "^4%s ^3%s ^1küldött ^3%s^1-nak ^3%i ^1DB ^4%s%s ^1fegyvert!", PREFIX, iName, tName, iErtek, g_StatTrakBeKiSend[id] ? "StatTrak* ":"", g_GunNames[g_ChooseThings[2][id]][g_kUserID[id]])
			} 
			new sztime[40];	
			new sztime1[40];	
			format_time(sztime, charsmax(sztime), "%Y.%m.%d - %H:%M:%S", get_systime())
			format_time(sztime1, charsmax(sztime1), "%Y.%m.%d", get_systime())
			log_to_file("skinkuldes.txt", "%s küldött %s-nak %i DB %s fegyvert!",iName, tName, iErtek, g_GunNames[g_ChooseThings[2][id]][g_kUserID[id]])
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
		else client_print_color(id, print_team_default,  "^4%s ^1Nincs elég Fegyvered!", PREFIX)
	}
	return PLUGIN_HANDLED;
}
	public Hook_Say(id){
		
		new Message[512], Status[16], Num[5], nev[32];
		get_user_name(id, nev, charsmax(nev));
		
		read_args(Message, charsmax(Message));
		remove_quotes(Message);
		new Message_Size = strlen(Message);

		//get_players(players, inum, "ch");
		
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
		
		/* if((Num[0] >= 3 && Num[1] >= 1 && Num[2] >= 8) || (Num[3] >= 3) || Num[4]){

			for (new bool:is_sender_admin = is_user_admin(id) != 0, i = 0; i < inum; ++i)
			{
				if (pl == id || get_user_flags(pl) & ADMIN_BAN)
				{
					client_print_color(pl, print_team_default, "^4[^3CHATSZŰRÉS^4] ^1Játékos:^4 %s ^3|^1 Üzenet: ^4%s", nev, Message);
				}
				else if(is_sender_admin)
					client_print_color(0, print_team_default, "^4[^3CHATSZŰRÉS^4] ^1Admin:^4 %s ^3|^1 Üzenet: ^4%s", nev, Message);

			}
			return PLUGIN_HANDLED;
		} */
		
		if(Message[0] == '@' || equal (Message, "") || Message[0] == '/')
			return PLUGIN_HANDLED;
		
		if(!is_user_alive(id))
			Status = "*Halott* ";
		
		new len;
		
		len += formatex(String[len], charsmax(String)-len, "^1%s", Status);
		
		if(g_Vip[id] == 1)
    	len += formatex(String[len], charsmax(String)-len, "^1[^4VIP^1]");
		if(Vip[id][isPremium] == 1)
		len += formatex(String[len], charsmax(String)-len, "^3[^4Prémium ^1VIP^3]");
		if(g_Admin_Level[id] > 0)// && InkAdmin[id] == 0)
			len += formatex(String[len], charsmax(String)-len, "^4[%s]", Admin_Permissions[g_Admin_Level[id]][0]);
		if(g_ASD[id] == 1)
			len += formatex(String[len], charsmax(String)-len, "^4[%s]", Rangok[Rang[id]][RangName]);
		
		
		
		if(g_Admin_Level[id] > 0 || g_Vip[id] == 1) //&& InkAdmin[id] == 0 ||  )
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
		
		if(Buy[id]){
			client_print_color(id, print_team_default, "^4%s ^1Ebben a körben már választottál fegyvert!", PREFIX);
			return;
		}
		
		new menu = menu_create("\r[.:*[Dark*.*Angel'S]*:.] Fegyvermenü", "handler");

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
		menu_additem(menu, "\r[\w*~\yMAC 10\w~*\r]", "12", 0);
		menu_additem(menu, "\r[\w*~\yTMP\w~*\r]", "13", 0);
		menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
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
			client_print_color(id, print_team_default, "^4%s^1 Kaptál egy ^3M4A1^1 fegyvert!", PREFIX);
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
			client_print_color(id, print_team_default, "^4%s^1 Kaptál egy ^3AK47^1 fegyvert!", PREFIX);
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
							client_print_color(id, print_team_default, "^4%s^1 Kaptál egy ^3AWP^1 fegyvert!", PREFIX);
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
							client_print_color(id, print_team_default, "^4%s^1 Kaptál egy ^3AWP^1 fegyvert!", PREFIX);
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
				client_print_color(id, print_team_default, "^4%s^1 Kaptál egy ^3MachineGun^1 fegyvert!", PREFIX);
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
				client_print_color(id, print_team_default, "^4%s^1 Kaptál egy ^3AUG^1 fegyvert!", PREFIX);
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
				client_print_color(id, print_team_default, "^4%s^1 Kaptál egy ^3Famas^1 fegyvert!", PREFIX);
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
				client_print_color(id, print_team_default, "^4%s^1 Kaptál egy ^3Galil^1 fegyvert!", PREFIX);
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
				client_print_color(id, print_team_default, "^4%s^1 Kaptál egy ^3SMG^1 fegyvert!", PREFIX);
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
				client_print_color(id, print_team_default, "^4%s^1 Kaptál egy ^3AutoShotgun^1 fegyvert!", PREFIX);
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
				client_print_color(id, print_team_default, "^4%s^1 Kaptál egy ^3Shotgun^1 fegyvert!", PREFIX);
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
				client_print_color(id, print_team_default, "^4%s^1 Kaptál egy ^3Scout^1 fegyvert!", PREFIX);
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
				client_print_color(id, print_team_default, "^4%s^1 Kaptál egy ^3Pityókahámozó^1 fegyvert!", PREFIX);
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
				client_print_color(id, print_team_default, "^4%s^1 Kaptál egy ^3Pityókahámozó^1 fegyvert!", PREFIX);
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
		give_item(index, "weapon_deagle");
		Buy[index] = index;
		cs_set_user_bpammo(index,CSW_DEAGLE,50);
		/*
		if(g_Vip[index] == 1)
		{
			give_item(index, "weapon_smokegrenade");
			client_print_color(index, print_team_default, "^4%s^1 Kaptál egy ^3SMOKE^1 gránátot, mert ^3VIP^1 tagsággal rendelkezel!", PREFIX);
		}*/
	}
	public Pisztolyok(id)
	{
		
		formatex(String, charsmax(String), "\r[.:*[Dark*.*Angel'S]*:.] Fegyvermenü", MENUPREFIX);
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
		client_print_color(0, print_team_default, "^4%s^1 Játékos: ^4%s^1 kirúgva, mert ^3érvénytelen^4 SteamID-t^1 használt.", PREFIX, Player[id][f_PlayerNames]);
		server_cmd("kick #%d ^"Ez a kliens nem kompatiliblis a szerverrel! Tölts le egy másikat innen: www.cskozosseg.hu!^"", get_user_userid(id));
	}
	Player_Stats[id][Kills] = 0;
	Player_Stats[id][HSs] = 0;
	Player_Stats[id][Deaths] = 0;
	Player_Stats[id][AllHitCount] = 0;
	Player_Stats[id][AllShotCount] = 0;
	PlayedCount[id] = 0;
	g_Vip[id] = 0
	g_VipTime[id] = 0;
	battlepass_szint[id] = 0;
	BattlePassPurchased[id] = 0;
	rXP[id] = 0.0;
	rELO[id] = 0;
	eloELO[id] = 0;
	eloXP[id] = 0.0;
	Wins[id] = 0;
	Rang[id] = 0;
	g_Id[id] = 0;
	oles[id] = 0;
	Equipmented_Erem[id] = 0;
	hl[id] = 0;
	hs[id] = 0;
	Player[id][SSzint] = 0;
	FragRacers[id][FragerKills] = 0;
	mvpr_have_selectedkit[id] = 0;
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
	masodpercek[id] = 0;
	g_Tools[1][id] = 0;
	g_Kirakva[id] = 0;
	g_Admin_Level[id] = 0;
	g_Quest[id] = 0;
	g_QuestWeapon[id] = 0;
	g_QuestMVP[id] = 0;
	g_QuestHead[id] = 0;

	Player_Vip[id][v_keydrop] = 1;
	Player_Vip[id][v_casedrop] = 1;
	Player_Vip[id][v_moneydrop] = 1;
	Player_Vip[id][v_time] = 0;
	premiumpont[id] = 0;
	VanPrefix[id] = 0;
	NyeremenyOles[id] = 0;
	Ajandekcsomag[id] = 0;
	TopFrag_1[id] = 0;
	TopFrag_2[id] = 0;
	TopFrag_3[id] = 0;
	
	for(new i;i < Music; i++)
		mvpr_kit[i][id] = 0;
	for(new i;i < FEGYO; i++)
		g_Weapons[i][id] = 0;
	for(new i;i < FEGYO; i++)
		g_StatTrak[i][id] = 0;
	for(new i;i < FEGYO; i++)
		g_StatTrakKills[i][id] = 0;
	for(new i;i < FEGYO; i++)
		g_GunNames[i][id] = "";
	for(new i;i < LADASZAM; i++)
		Lada[i][id] = 0;
	for(new i;i < LADASZAM; i++)
		LadaK[i][id] = 0;
		
	for(new i;i < EREM; i++)
		Erem[i][id] = 0;

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
	Load_User_Data(id);

	for(new i = 0; i <= g_Maxplayers; ++i)
    g_Mute[id][i] = 0
}
public LoadFragers()
{
  static Query[512]
  new sDate[11];
  get_time("%Y/%m/%d", sDate, 11);
  new Data[1];
  formatex(Query, charsmax(Query), "SELECT * FROM `frag_counters` WHERE Date = ^"%s^";", sDate)
  SQL_ThreadQuery(g_SqlTuple, "QuerySelectFragers", Query, Data, 1);
}
public QuerySelectFragers(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime)
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
		Frags = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Frags"));
    }
	else
		SaveFragers();
  }
}
public SaveFragers()
{
new text[512];
new sDate[11];
get_time("%Y/%m/%d", sDate, 11);
formatex(text, charsmax(text), "INSERT INTO `frag_counters` (`Date`, `Frags`) VALUES (^"%s^", ^"%i^");", sDate, Frags);

SQL_ThreadQuery(g_SqlTuple, "QuerySetData", text);
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
			client_print_color(0, print_team_default, "^3%s^1 Játékos: ^3%s ^1(#^3%d^1) | VIP Tagságot kapott ^3%d^1 napra! ^3%s^1(#^3%d^1) által!", PREFIX, Player[Is_Online][f_PlayerNames], Arg_Int[0], Arg_Int[1], szName, g_Id[id]);
			client_print_color(Is_Online, print_team_default, "^3%s^1 Kaptál^4 %d Napra^1 szóló‚ ^3VIPet^1. ^3Lejár ekkor: ^4%s", PREFIX, Arg_Int[1], sztime);	
		}
		else 
		{
			client_print_color(0, print_team_default, "%s Játékos: ^3%s ^1(#^3%d^1) | VIP Tagság megvonva! ^3%s^1(#^3%d^1) által!", PREFIX, Player[Is_Online][f_PlayerNames], Arg_Int[0], szName, g_Id[id]);	
			g_VipTime[Is_Online] = 0;
		}
	}
	else
		client_print(id, print_console, "A jatekos nincs fent!");
	
	
	return PLUGIN_HANDLED;
}
public cmdTopByKills()
	{
		SQL_ThreadQuery(g_SqlTuple, "top3ThreadaK","SELECT * FROM `Profiles` ORDER BY NyOles3 DESC LIMIT 15");
		
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
public client_beallitas(id)
{
	Selectedgun[AK47][id] = SelectedStatTrak[0][id] 
	Selectedgun[M4A1][id] = SelectedStatTrak[1][id] 
	Selectedgun[AWP][id] = SelectedStatTrak[2][id] 
	Selectedgun[DEAGLE][id] = SelectedStatTrak[3][id] 
	Selectedgun[KNIFE][id] = SelectedStatTrak[4][id] 
}
public client_connect(id) {
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
  formatex(String, charsmax(String), "\r%s \y» \wLádák",MENUPREFIX)
  new menu = menu_create(String, "Cases_Menu_h");

  for(new i;i < LADASZAM;i++)
  {
    formatex(String, charsmax(String), "\w%s [\r%i\w]", LadaNevek[i], Lada[id][i]);

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
	formatex(String, charsmax(String), "\r%s \y» \w%s Információ",MENUPREFIX, LadaNevek[Player[id][CaseSelectedSlot]]);
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
            client_print_color(id, print_team_default, "^4%s ^1Nincs kulcsod!",PREFIX);
          }
        }
        else
        {
          client_print_color(id, print_team_default, "^4%s ^1Nincs ilyen ládád!",PREFIX);
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
	format(iras, charsmax(iras), "\y%s^nKuka", MENUPREFIX);
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
		client_print_color(id, print_team_default, "^4%s ^1Nem dobhatsz ki semmit amíg valamelyik tárgyad a Piacon van!", PREFIX)
		menu_destroy(menu);
		return PLUGIN_HANDLED
	}

	new data[9], szName[64]
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
	new key = str_to_num(data);
	new Float:randomdolcsi = random_float(0.01, 0.05);

	if(g_StatTrak[key][id] == 1 || g_Weapons[key][id] == 1) g_GunNames[key][id][0] = EOS
	g_Weapons[key][id]--
	if(g_StatTrak[key][id] == g_Weapons[key][id]+1) g_StatTrak[key][id]--
	g_dollar[id] += randomdolcsi
	client_print_color(id, print_team_default, "^3%s^1 Törölted a ^3%s^1 nevű skined, ezért kaptál ^3%3.2f^1 dollárt.", PREFIX, FegyverInfo[key][GunName], randomdolcsi)
	
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

public Load_All(id)
{
  static Query[10048];
  new Data[1];
  Data[0] = id;
  for (new i=1; i < 12; i++)
  {
    switch(i)
    {
      case 1:
      {
        formatex(Query, charsmax(Query), "SELECT * FROM `Profiles` WHERE User_Id = ^"%i^";", g_Id[id])
        SQL_ThreadQuery(g_SqlTuple, "QuerySelectProfile", Query, Data, 1);
      }
      case 2:
      {
        formatex(Query, charsmax(Query), "SELECT * FROM `Weapon` WHERE User_Id = ^"%i^";", g_Id[id])
        SQL_ThreadQuery(g_SqlTuple, "QuerySelectWeapon", Query, Data, 1);
      }
	  case 3:
      {
        formatex(Query, charsmax(Query), "SELECT * FROM `Nevcedula` WHERE User_Id = ^"%i^";", g_Id[id])
        SQL_ThreadQuery(g_SqlTuple, "QuerySelectNevcedula", Query, Data, 1);
      }
	  case 4:
      {
        formatex(Query, charsmax(Query), "SELECT * FROM `Stattrak` WHERE User_Id = ^"%i^";", g_Id[id])
        SQL_ThreadQuery(g_SqlTuple, "QuerySelectStattrak", Query, Data, 1);
      }
	  case 5:
      {
        formatex(Query, charsmax(Query), "SELECT * FROM `StattrakKills` WHERE User_Id = ^"%i^";", g_Id[id])
        SQL_ThreadQuery(g_SqlTuple, "QuerySelectStKills", Query, Data, 1);
      }
	  case 6:
      {
        formatex(Query, charsmax(Query), "SELECT * FROM `Skins` WHERE User_Id = ^"%i^";", g_Id[id])
        SQL_ThreadQuery(g_SqlTuple, "QuerySelectSkin", Query, Data, 1);
	  }
      case 7:
      {
        formatex(Query, charsmax(Query), "SELECT * FROM `shedi_testers` WHERE User_Id = ^"%i^";", g_Id[id])
        SQL_ThreadQuery(g_SqlTuple, "QuerySelectTester", Query, Data, 1);
      }
	  case 8:
      {
        formatex(Query, charsmax(Query), "SELECT * FROM `MusicKits` WHERE User_Id = ^"%i^";", g_Id[id])
        SQL_ThreadQuery(g_SqlTuple, "QuerySelectMusic", Query, Data, 1);
      }//TablaAdatValasztas_PlayerStats
	  case 9:
      {
        formatex(Query, charsmax(Query), "SELECT * FROM `PlayerStats` WHERE User_Id = ^"%i^";", g_Id[id])
        SQL_ThreadQuery(g_SqlTuple, "TablaAdatValasztas_PlayerStats", Query, Data, 1);
      }//TablaAdatValasztas_PlayerStats
	  case 10:
      {
        formatex(Query, charsmax(Query), "SELECT * FROM `ErdemErmek` WHERE User_Id = ^"%i^";", g_Id[id])
        SQL_ThreadQuery(g_SqlTuple, "QuerySelectErdemErmek", Query, Data, 1);
      }//TablaAdatValasztas_PlayerStats
	  case 11:
      {
        formatex(Query, charsmax(Query), "SELECT * FROM `shedi_kuldik` WHERE User_Id = ^"%i^";", g_Id[id])
        SQL_ThreadQuery(g_SqlTuple, "QuerySelectKuldik", Query, Data, 1);
      }//TablaAdatValasztas_PlayerStats
    }
  }
}
public Load_User_Data(id)
{
	static Query[20048];
	new Data[1];
	Data[0] = id;
	console_print(id, "fasza")
	formatex(Query, charsmax(Query), "SELECT * FROM `Players` WHERE steamid = ^"%s^";", Player[id][steamid])
	SQL_ThreadQuery(g_SqlTuple, "QuerySelectData", Query, Data, 1);

}
public QuerySelectData(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime)
{
  if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED)
  {
    log_amx("%s", Error);
    return;
  }
  else
  {
    new id = Data[0];
    new wId;
	

    if(SQL_NumRows(Query) > 0)
    {
		g_Id[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "id"));
		wId = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "id"));

		new sTime[9], sDate[11], sDateAndTime[32];
		get_time("%H:%M:%S", sTime, 8 );
		get_time("%Y/%m/%d", sDate, 11);
		formatex(sDateAndTime, 31, "%s %s", sDate, sTime);
		
		console_print(id, "-----------------------------")
		console_print(id, "id: %i | Account Id: %i", id, g_Id[id])
		console_print(id, "hashid: %i", get_user_userid(id))
		console_print(id, "Nev: %s | SteamId: %s", Player[id][f_PlayerNames], Player[id][steamid])
		console_print(id, "Betoltott Account Id: %i", wId)
		console_print(id, "Pontos ido: %s", sDateAndTime)
		console_print(id, "-----------------------------")

		//server_cmd("kick #%d ^"Hibás fiókbetöltés! További információk a konzolban!^"", get_user_userid(id));

		Load_All(id);
    }
    else
    {
    	Save(id);
    }
  }
}
public Save(id){
	static Query[10048];
	new Data[1];
	
	Data[0] = id;

	formatex(Query, charsmax(Query), "INSERT INTO `Players` (`steamid`) VALUES (^"%s^");", Player[id][steamid]);
	SQL_ThreadQuery(g_SqlTuple, "QuerySetDataProfile", Query, Data, 1);
}

public QuerySetDataProfile(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime){
	if( FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED ){
		log_amx("%s", Error);
		return;
	}
	else{
		new id = Data[0];

	
		load_accid(id);
	}
}
public load_accid(id)
{
	static Query[20048];
	new Data[1];
	Data[0] = id;
	formatex(Query, charsmax(Query), "SELECT * FROM `Players` WHERE `steamid` = ^"%s^"", Player[id][steamid]);
	SQL_ThreadQuery(g_SqlTuple, "QuerySelectData1", Query, Data, 1);
}
public QuerySelectData1(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime) {
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) {
		log_amx("%s", Error);
		return;
	}
	else {
		new id = Data[0];
		new wId
		
		if(SQL_NumRows(Query) > 0) {
		g_Id[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "id"));
		wId = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "id"));

		new sTime[9], sDate[11], sDateAndTime[32];

		get_time("%H:%M:%S", sTime, 8 );
		get_time("%Y/%m/%d", sDate, 11);
		formatex(sDateAndTime, 31, "%s %s", sDate, sTime);

		// console_print(0, "-----------------------------")
		// console_print(0, "id: %i | Account Id: %i", id, g_Id[id])
		// console_print(0, "hashid: %i", get_user_userid(id))
		// console_print(0, "Név: %s | SteamId: %s", Player[id][f_PlayerNames], Player[id][steamid])
		// console_print(0, "Betöltött Account Id: %i", wId)
		// console_print(0, "Pontos idő: %s", sDateAndTime)
		// console_print(0, "-----------------------------")

		// log_to_file("Acc0id.txt", "Jatekosok: %i, sqlid: %i, hashid: %i, Nev: %s S: %s, Hibas Acccount id: %i Pontos ido: %s", p_playernum, id, get_user_userid(id), Player[id][f_PlayerNames], Player[id][steamid], wId, sDateAndTime)

		console_print(id, "-----------------------------")
		console_print(id, "id: %i | Account Id: %i", id, g_Id[id])
		console_print(id, "hashid: %i", get_user_userid(id))
		console_print(id, "Nev: %s | SteamId: %s", Player[id][f_PlayerNames], Player[id][steamid])
		console_print(id, "Betoltott Account Id: %i", wId)
		console_print(id, "Pontos ido: %s", sDateAndTime)
		console_print(id, "-----------------------------")

		//server_cmd("kick #%d ^"Hibás fiókbetöltés! További információk a konzolban!^"", get_user_userid(id));

		Load_All(id);
		}
	}
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
		SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Exp"), EXPT[id]);
		SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "rXP"), rXP[id]);
		rELO[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "rELO"));
		Wins[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Wins"));
		Rang[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Rang"));
		//Player[id][EXP] = float(SQL_ReadResult(Query, 8))/100
		g_Tools[0][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "STTool"));
		Equipmented_Erem[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "EQEREM"));
		mvpr_have_selectedkit[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "selectedkit"));
		masodpercek[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "jatszottido"));
		g_SkinBeKi[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "SkinBeKi"));
		battlepass_szint[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "BTSZ"));
		BattlePassPurchased[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "BTPURCH"));
		NyeremenyOles[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "NyOles3"));
		Player[id][FragWins] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "FragWins"));
		TopFrag_1[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "TopFrag1"));
		TopFrag_2[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "TopFrag2"));
		TopFrag_3[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "TopFrag3"));
		HudOff[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "HudBeKi"));
		g_Tools[1][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Nevcedula"));
		premiumpont[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "premiumpont"));
		g_VipTime[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "viptime"));
		Vip[id][PremiumTime] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "PremiumTime"));
		g_Admin_Level[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Admin_Szint"));
		Player[id][SSzint] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "KSzint"));
		hs[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "fejloves"));
		oles[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "oles"));

		for(new i;i < LADASZAM; i++)
		{
			new String[64];
			formatex(String, charsmax(String), "Case%d", i);
			Lada[i][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, String));
		}
		
		for(new i;i < LADASZAM; i++)
		{
			new String[64];
			formatex(String, charsmax(String), "Keys%d", i);
			LadaK[i][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, String));
		}
		
		Set_Permissions(id)
		}
		else
		{
		sql_create_profiles_row(id);
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
		g_Quest[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "QuestH1"));
		g_QuestMVP[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "QuestMVP1"));
		g_QuestKills[0][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "QuestNeed1"));
		g_QuestKills[1][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "QuestHave1"));
		g_QuestWeapon[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "QuestWeap1"));
		g_QuestHead[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "QuestHead1"));
		g_Jutalom[0][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "JutLada1"));
		g_Jutalom[1][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "JutKulcs1"));
		g_Jutalom[3][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "JutDoll1"));
		SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "DollarJutalom"), g_dollarjutalom[id]);
		}
		else
		{
		sql_create_kuldik_row(id);
		}
		
	}
}
public QuerySelectTester(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime) {
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) {
		log_amx("%s", Error);
		return;
	}
	else {
		new id = Data[0];
		
		if(SQL_NumRows(Query) > 0) {
		//SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Name"), Player[id][f_PlayerNames], 32);
		erdem[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "van"));
		erdem2[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "van2"));
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

		for(new i;i < FEGYO; i++)
			{
				new String[64];
				formatex(String, charsmax(String), "F_%d", i);
				g_Weapons[i][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, String));
			}
		}
		else
		{
		sql_create_weapon_row(id);
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

		for(new i;i < FEGYO; i++)
			{
				new String[64];
				formatex(String, charsmax(String), "N_%d", i);
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, String), g_GunNames[i][id], charsmax(g_GunNames[]));
			}
		}
		else
		{
		sql_create_nametag_row(id);
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

		for(new i;i < FEGYO; i++)
			{
				new String[64];
				formatex(String, charsmax(String), "st_%d", i);
				g_StatTrak[i][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, String));
			}
		}
		else
		{
		sql_create_st_row(id)
		}
		
	}
}
public QuerySelectErdemErmek(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime) {
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) {
		log_amx("%s", Error);
		return;
	}
	else {
		new id = Data[0];
		
		if(SQL_NumRows(Query) > 0) {

		for(new i;i < EREM; i++)
			{
				new String[64];
				formatex(String, charsmax(String), "rm_%d", i);
				Erem[i][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, String));
			}
		}
		else
		{
		sql_create_rm_row(id)
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

		for(new i;i < FEGYO; i++)
			{
				new String[64];
				formatex(String, charsmax(String), "stk_%d", i);
				g_StatTrakKills[i][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, String));
			}
		}
		else
		{
		sql_create_stk_row(id);
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

		}
		else
		{
		sql_create_skin_row(id);
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
		
		if(SQL_NumRows(Query) > 0) {

		for(new i;i < Music; i++)
			{
				new String[64];
				formatex(String, charsmax(String), "Kit%d", i);
				mvpr_kit[i][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, String));
			}
			}
		else
		{
		sql_create_music_row(id);
		}
		
	}
}
public client_disconnected(id)
{
	Update_Regi(id);
	Update(id);
	Update_Fegyver(id);
	Update_Stattrak(id);
	Update_StattrakKills(id);
	Update_Nametag(id);
	Update_Skin(id);
	Update_Testers(id);
	Update_Music(id);
	Update_Player_Stats(id);
	Update_Erdem(id);
	Update_kuldik(id);
}
public Update_fragers(){
	static Query[10048];
	new Len;
	new sDate[11];
	get_time("%Y/%m/%d", sDate, 11);

	Len += formatex(Query[Len], charsmax(Query), "UPDATE `frag_counters` SET ");
		
	Len += formatex(Query[Len], charsmax(Query)-Len, "Frags = ^"%i^", ", Frags);

	Len += formatex(Query[Len], charsmax(Query)-Len, "Frags = ^"%i^" WHERE `Date` =  ^"%s^"", Frags, sDate);
	
	SQL_ThreadQuery(g_SqlTuple, "QuerySetData", Query);
}
public Update_Regi(id){
	static Query[10048];
	new Len;
	
	Len += formatex(Query[Len], charsmax(Query), "UPDATE `Players` SET ");
	Len += formatex(Query[Len], charsmax(Query)-Len, "gametime = ^"%i^", ", masodpercek[id]+get_user_time(id));
	
	Len += formatex(Query[Len], charsmax(Query)-Len, "gametime = ^"%i^" WHERE `id` =  %d;", masodpercek[id], g_Id[id]);
	
	SQL_ThreadQuery(g_SqlTuple, "QuerySetData", Query);
}
public Update(id){
	static Query[10048];
	new Len;
	
	Len += formatex(Query[Len], charsmax(Query), "UPDATE `Profiles` SET ");
	Len += formatex(Query[Len], charsmax(Query)-Len, "Dollars = ^"%.2f^", ", g_dollar[id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "rXP = ^"%.2f^", ", rXP[id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "rELO = ^"%i^", ", rELO[id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "Wins = ^"%i^", ", Wins[id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "Rang = ^"%i^", ", Rang[id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "gamename = ^"%s^", ", Player[id][f_PlayerNames]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "halal = ^"%i^", ", hl[id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "EQEREM = ^"%i^", ", Equipmented_Erem[id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "selectedkit = ^"%i^", ", mvpr_have_selectedkit[id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "FragWins = ^"%i^", ", Player[id][FragWins]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "TopFrag1 = ^"%i^", ", TopFrag_1[id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "TopFrag2 = ^"%i^", ", TopFrag_2[id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "BTPURCH = ^"%i^", ", BattlePassPurchased[id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "BTSZ = ^"%i^", ", battlepass_szint[id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "TopFrag3 = ^"%i^", ", TopFrag_3[id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "NyOles3 = ^"%i^", ", NyeremenyOles[id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "PremiumTime = ^"%i^", ", Vip[id][PremiumTime]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "oles = ^"%i^", ", oles[id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "SkinBeKi = ^"%i^", ", g_SkinBeKi[id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "HudBeKi = ^"%i^", ", HudOff[id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "vanprefix = ^"%i^", ", VanPrefix[id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "jatszottido = ^"%i^", ", masodpercek[id]+get_user_time(id));
	Len += formatex(Query[Len], charsmax(Query)-Len, "viptime = ^"%i^", ", g_VipTime[id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "premiumpont = ^"%i^", ", premiumpont[id])
	Len += formatex(Query[Len], charsmax(Query)-Len, "Nevcedula = ^"%i^", ", g_Tools[1][id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "STTool = ^"%i^", ", g_Tools[0][id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "Admin_Szint = ^"%i^", ", g_Admin_Level[id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "KSzint = '%i', ", Player[id][SSzint]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "Exp = ^"%.2f^", ", EXPT[id]);	
	for(new i;i < LADASZAM; i++)
		Len += formatex(Query[Len], charsmax(Query)-Len, "Case%d = ^"%i^", ", i, Lada[i][id]);
		
	for(new i;i < LADASZAM; i++)
		Len += formatex(Query[Len], charsmax(Query)-Len, "Keys%d = ^"%i^", ", i, LadaK[i][id]);

	Len += formatex(Query[Len], charsmax(Query)-Len, "oles = ^"%i^" WHERE `User_Id` =  %d;", oles[id], g_Id[id]);
	
	SQL_ThreadQuery(g_SqlTuple, "QuerySetData", Query);
}
public Update_kuldik(id){
	static Query[10048];
	new Len;
	
	Len += formatex(Query[Len], charsmax(Query), "UPDATE `shedi_kuldik` SET ");
	Len += formatex(Query[Len], charsmax(Query)-Len, "QuestH1 = '%i', ", g_Quest[id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "QuestMVP1 = '%i', ", g_QuestMVP[id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "QuestNeed1 = '%i', ", g_QuestKills[0][id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "QuestHave1 = '%i', ", g_QuestKills[1][id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "QuestWeap1 = '%i', ", g_QuestWeapon[id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "QuestHead1 = '%i', ", g_QuestHead[id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "JutLada1 = '%i', ", g_Jutalom[0][id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "JutKulcs1 = '%i', ", g_Jutalom[1][id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "JutDoll1 = '%i', ", g_Jutalom[3][id]); 
	Len += formatex(Query[Len], charsmax(Query)-Len, "DollarJutalom = ^"%.2f^", ", g_dollarjutalom[id]);

	Len += formatex(Query[Len], charsmax(Query)-Len, "JutDoll1 = ^"%i^" WHERE `User_Id` =  %d;", g_Jutalom[3][id], g_Id[id]);
	
	SQL_ThreadQuery(g_SqlTuple, "QuerySetData", Query);
}
public Update_Skin(id){
	static Query[10048];
	new Len;
	
	Len += formatex(Query[Len], charsmax(Query), "UPDATE `Skins` SET ");
		
	Len += formatex(Query[Len], charsmax(Query)-Len, "Skin0 = ^"%i^", ", Selectedgun[AK47][id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "Skin1 = ^"%i^", ", Selectedgun[M4A1][id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "Skin2 = ^"%i^", ", Selectedgun[AWP][id]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "Skin3 = ^"%i^", ", Selectedgun[DEAGLE][id]);

	Len += formatex(Query[Len], charsmax(Query)-Len, "Skin4 = ^"%i^" WHERE `User_Id` =  %d;", Selectedgun[KNIFE][id], g_Id[id]);
	
	SQL_ThreadQuery(g_SqlTuple, "QuerySetData", Query);
}
public Update_Music(id){
	static Query[10048];
	new Len;
	
	Len += formatex(Query[Len], charsmax(Query), "UPDATE `MusicKits` SET ");
		
	for(new i;i < Music; i++)
	Len += formatex(Query[Len], charsmax(Query)-Len, "Kit%d = ^"%i^", ", i, mvpr_kit[i][id]);


	Len += formatex(Query[Len], charsmax(Query)-Len, "Parameter = '0' WHERE `User_Id` =  %d;", g_Id[id]);
	
	SQL_ThreadQuery(g_SqlTuple, "QuerySetData", Query);
}
public Update_Stattrak(id)
{
	static Query[10048];
	new Len;
	
	Len += formatex(Query[Len], charsmax(Query), "UPDATE `Stattrak` SET ");
	
	for(new i;i < FEGYO; i++)
		Len += formatex(Query[Len], charsmax(Query)-Len, "st_%d = ^"%i^", ", i, g_StatTrak[i][id]);


	Len += format(Query[Len], charsmax(Query)-Len,"Parameter = '0' ")
	Len += formatex(Query[Len], charsmax(Query)-Len, "WHERE `User_Id` =  %d;", g_Id[id]);
	SQL_ThreadQuery(g_SqlTuple, "QuerySetData", Query);
}
public Update_StattrakKills(id)
{
	static Query[10048];
	new Len;
	
	Len += formatex(Query[Len], charsmax(Query), "UPDATE `StattrakKills` SET ");
	
	for(new i;i < FEGYO; i++)
		Len += formatex(Query[Len], charsmax(Query)-Len, "stk_%d = ^"%i^", ", i, g_StatTrakKills[i][id]);


	Len += format(Query[Len], charsmax(Query)-Len,"Parameter = '0' ")
	Len += formatex(Query[Len], charsmax(Query)-Len, "WHERE `User_Id` =  %d;", g_Id[id]);
	SQL_ThreadQuery(g_SqlTuple, "QuerySetData", Query);
}
public Update_Fegyver(id)
{
	static Query[10048];
	new Len;
	
	Len += formatex(Query[Len], charsmax(Query), "UPDATE `Weapon` SET ");
	
	for(new i;i < FEGYO; i++)
		Len += formatex(Query[Len], charsmax(Query)-Len, "F_%d = ^"%i^", ", i, g_Weapons[i][id]);

	Len += format(Query[Len], charsmax(Query)-Len,"Parameter = '0' ")
	Len += formatex(Query[Len], charsmax(Query)-Len, "WHERE `User_Id` =  %d;", g_Id[id]);
	SQL_ThreadQuery(g_SqlTuple, "QuerySetData", Query);
}
public Update_Erdem(id)
{
	static Query[10048];
	new Len;
	
	Len += formatex(Query[Len], charsmax(Query), "UPDATE `ErdemErmek` SET ");

	
	for(new i;i < EREM; i++)
	{
		Len += formatex(Query[Len], charsmax(Query)-Len, "rm_%d = ^"%i^", ", i, Erem[i][id]);
	}
		

	Len += format(Query[Len], charsmax(Query)-Len,"Parameter = '0' ")
	Len += formatex(Query[Len], charsmax(Query)-Len, "WHERE `User_Id` =  %d;", g_Id[id]);
	SQL_ThreadQuery(g_SqlTuple, "QuerySetData", Query);
}
public Update_Nametag(id)
{
	static Query[10048];
	new Len;
	
	Len += formatex(Query[Len], charsmax(Query), "UPDATE `Nevcedula` SET ");
	
	for(new i;i < FEGYO; i++)
		Len += formatex(Query[Len], charsmax(Query)-Len, "N_%d = ^"%s^", ", i, g_GunNames[i][id]);

	Len += format(Query[Len], charsmax(Query)-Len,"Parameter = '0' ")
	Len += formatex(Query[Len], charsmax(Query)-Len, "WHERE `User_Id` =  %d;", g_Id[id]);
	SQL_ThreadQuery(g_SqlTuple, "QuerySetData", Query);
}
public Update_Testers(id)
{
	static Query[10048];
	new Len;
	
	Len += formatex(Query[Len], charsmax(Query), "UPDATE `shedi_testers` SET ");
	
	Len += formatex(Query[Len], charsmax(Query)-Len, "Name = ^"%s^", ", Player[id][f_PlayerNames]);

	Len += format(Query[Len], charsmax(Query)-Len,"Parameter = '0' ")
	Len += formatex(Query[Len], charsmax(Query)-Len, "WHERE `User_Id` =  %d;", g_Id[id]);
	SQL_ThreadQuery(g_SqlTuple, "QuerySetData", Query);
	//sql_update_account1(id);
}
public sql_create_rm_row(id){
	static Query[10048];
	formatex(Query, charsmax(Query), "INSERT INTO `ErdemErmek` (`User_Id`) VALUES (%d);", g_Id[id]);
	SQL_ThreadQuery(g_SqlTuple, "QuerySetData", Query);
}
public sql_create_Players_row(id){
	static Query[10048];
	formatex(Query, charsmax(Query), "INSERT INTO `Players` (`steamid`) VALUES (^"%s^");", Player[id][steamid]);
	SQL_ThreadQuery(g_SqlTuple, "QuerySetData", Query);
}	
public sql_create_profiles_row(id){
	static Query[10048];
	formatex(Query, charsmax(Query), "INSERT INTO `Profiles` (`User_Id`) VALUES (%d);", g_Id[id]);
	SQL_ThreadQuery(g_SqlTuple, "QuerySetData", Query);
}	
public sql_create_skin_row(id){
	static Query[10048];
	formatex(Query, charsmax(Query), "INSERT INTO `Skins` (`User_Id`) VALUES (%d);", g_Id[id]);
	SQL_ThreadQuery(g_SqlTuple, "QuerySetData", Query);
}	
public sql_create_nametag_row(id){
	static Query[10048];
	formatex(Query, charsmax(Query), "INSERT INTO `Nevcedula` (`User_Id`) VALUES (%d);", g_Id[id]);
	SQL_ThreadQuery(g_SqlTuple, "QuerySetData", Query);
}	
public sql_create_weapon_row(id){
	static Query[10048];
	formatex(Query, charsmax(Query), "INSERT INTO `Weapon` (`User_Id`) VALUES (%d);", g_Id[id]);
	SQL_ThreadQuery(g_SqlTuple, "QuerySetData", Query);
}	
public sql_create_testers_row(id){
	static Query[10048];
	formatex(Query, charsmax(Query), "INSERT INTO `shedi_testers` (`User_Id`,`Name`) VALUES (%d, ^"%s^");", g_Id[id], Player[id][f_PlayerNames]);
	SQL_ThreadQuery(g_SqlTuple, "QuerySetData", Query);
}
public sql_create_st_row(id){
	static Query[10048];
	formatex(Query, charsmax(Query), "INSERT INTO `Stattrak` (`User_Id`) VALUES (%d);", g_Id[id]);
	SQL_ThreadQuery(g_SqlTuple, "QuerySetData", Query);
}	
public sql_create_stk_row(id){
	static Query[10048];
	formatex(Query, charsmax(Query), "INSERT INTO `StattrakKills` (`User_Id`) VALUES (%d);", g_Id[id]);
	SQL_ThreadQuery(g_SqlTuple, "QuerySetData", Query);
}	
public sql_create_music_row(id){
	static Query[10048];
	formatex(Query, charsmax(Query), "INSERT INTO `MusicKits` (`User_Id`) VALUES (%d);", g_Id[id]);
	SQL_ThreadQuery(g_SqlTuple, "QuerySetData", Query);
}
public sql_create_kuldik_row(id){
	static Query[10048];
	formatex(Query, charsmax(Query), "INSERT INTO `shedi_kuldik` (`User_Id`) VALUES (%d);", g_Id[id]);
	SQL_ThreadQuery(g_SqlTuple, "QuerySetData", Query);
}
public Load_This(id, Table_Name[], ForwardMetod[])
{
  new Data[1];
  Data[0] = id;
  static Query[10048];
  formatex(Query, charsmax(Query), "SELECT * FROM `%s` ORDER BY ( Kills + ( HSs / 10 ) - Deaths ) * ( AllHitCount / ( AllShotCount / 100 ) ) DESC;",Table_Name);
  SQL_ThreadQuery(g_SqlTuple, ForwardMetod, Query, Data, 1);
}

public Load_Data_15(Table_Name[], ForwardMetod[])
{
  new Data[1];
  static Query[10048];
  formatex(Query, charsmax(Query), "SELECT * FROM `%s` ORDER BY ( Kills + ( HSs / 10 ) - Deaths ) * ( AllHitCount / ( AllShotCount / 100 ) ) DESC;",Table_Name);
  SQL_ThreadQuery(g_SqlTuple, ForwardMetod, Query, Data, 1);
}
public sort_bestthree(id1, id2)
{
	if(FragRacers[id1][FragerKills] > FragRacers[id2][FragerKills]) return -1
	else if(FragRacers[id1][FragerKills] < FragRacers[id2][FragerKills]) return 1
 
	return 0
}
public CmdTop15(id)
{
  client_print_color(id, print_team_default, "^4%s ^1A top15 minden kör elején automatikusan frissül!",PREFIX);

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
    len += formatex(StringMotd[len], charsmax(StringMotd) - len, "<tr><td>%i. %s</td>", i+1, Top15_list[i][Name]);
    len += formatex(StringMotd[len], charsmax(StringMotd) - len, "<td>%i</td>", Top15_list[i][Kills]);
    len += formatex(StringMotd[len], charsmax(StringMotd) - len, "<td>%i</td>", Top15_list[i][Deaths]);
    len += formatex(StringMotd[len], charsmax(StringMotd) - len, "<td>%i</td>", Top15_list[i][HSs]);
    len += formatex(StringMotd[len], charsmax(StringMotd) - len, "<td>%.2f</td></tr>", ( Top15_list[i][AllHitCount]/(Top15_list[i][AllShotCount]/100.0) ));
  }
  len = formatex(StringMotd[len], charsmax(StringMotd) - len, "</table></center>");

  show_motd(id, StringMotd, "Top15");
}
public Update_Player_Stats(id)
{
  new Len;
  static Query[10048];
  Len += formatex(Query[Len], charsmax(Query), "UPDATE `PlayerStats` SET ");
  Len += formatex(Query[Len], charsmax(Query)-Len, "Name = ^"%s^", ", Player[id][f_PlayerNames]);
  Len += formatex(Query[Len], charsmax(Query)-Len, "Kills = ^"%i^", ", Player_Stats[id][Kills]);
  Len += formatex(Query[Len], charsmax(Query)-Len, "HSs = ^"%i^", ", Player_Stats[id][HSs]);
  Len += formatex(Query[Len], charsmax(Query)-Len, "Deaths = ^"%i^", ", Player_Stats[id][Deaths]);
  Len += formatex(Query[Len], charsmax(Query)-Len, "AllHitCount = ^"%i^", ", Player_Stats[id][AllHitCount]);
  
  Len += formatex(Query[Len], charsmax(Query)-Len, "AllShotCount = ^"%i^" WHERE `User_Id` =  %d;", Player_Stats[id][AllShotCount], g_Id[id]);
  
  SQL_ThreadQuery(g_SqlTuple, "QuerySetData", Query);
}
public CmdRank(id)
{
  Update_Player_Stats(id);
  Load_This(id, "PlayerStats", "TablaAdatValasztasOsszes_PlayerStats");
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
        if(SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "User_Id")) == g_Id[id])
        {
          Player[id][NowRank] = x;
          if(0 == SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "AllHitCount")) || 0 == SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "AllShotCount")))
            CanNOTRanked = 1;
        }
        SQL_NextRow(Query);
      }
      AllRegistedRank = x;
      if(CanNOTRanked)
      {
		client_print_color(id, print_team_default, "^4%s ^4Rangod: ^3NotRanked^1/^3%i ^1| ^4Ölések: ^3%i ^1|^4 Halálok: ^3%i ^1| ^4Fejesek: ^3%i ^1|^4 Hatékonyság: ^3%.3f", PREFIX, AllRegistedRank, Player_Stats[id][Kills], Player_Stats[id][Deaths], Player_Stats[id][HSs], ( Player_Stats[id][AllHitCount]/(Player_Stats[id][AllShotCount]/100.0) ));
		client_print_color(id, print_team_default, "^4%s ^1Nincs elég adatunk hogy betudjuk sorolni megfelelően!",PREFIX);
      }
      else
        client_print_color(id, print_team_default, "^4%s ^4Rangod: ^3%i^1/^3%i ^1| ^4Ölések: ^3%i ^1|^4 Halálok: ^3%i ^1| ^4Fejesek: ^3%i ^1|^4 Hatékonyság: ^3%.3f", PREFIX, Player[id][NowRank], AllRegistedRank, Player_Stats[id][Kills], Player_Stats[id][Deaths], Player_Stats[id][HSs], ( Player_Stats[id][AllHitCount]/(Player_Stats[id][AllShotCount]/100.0) ));
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
         formatex(text, charsmax(text), "INSERT INTO `PlayerStats` (`User_Id`) VALUES (%i);", g_Id[id]);
         SQL_ThreadQuery(g_SqlTuple, "QuerySetData", text);
       }
  }
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
	
	client_print_color(0, print_team_default, "^3[DEBUG]^1 A Fragverseny első helyezettje: %s | Jutalma: %s", TopName1, JutalmakFrag1[FragJutalmak1])
	client_print_color(0, print_team_default, "^3[DEBUG]^1 A Fragverseny második helyezettje: %s | Jutalma: %s", TopName2, JutalmakFrag2[FragJutalmak2])
	client_print_color(0, print_team_default, "^3[DEBUG]^1 A Fragverseny harmadik helyezettje: %s | Jutalma: %s", TopName3, JutalmakFrag3[FragJutalmak3])
	
	Player[Top1][FragWins]++;
	Player[Top2][FragWins]++;
	Player[Top3][FragWins]++;
	
	if(TopFrag_1[Top1] == 5)
		AddErem(Top1, 9, 0)
	else if(TopFrag_2[Top2] == 5)
		AddErem(Top2, 10, 0)
	else if(TopFrag_3[Top3] == 5)
		AddErem(Top3, 11, 0)

	switch(FragJutalmak1)
	{
	case 0:
	{
	    LadaK[5][Top1] += 15;
	    Lada[5][Top1] += 15;
	}
	case 1:
	{
	    LadaK[4][Top1] += 15;
	    Lada[4][Top1] += 15;
	}
	case 2:
	{
	    g_dollar[Top1] += 30.00;
	    if(g_Vip[Top1] == 1)
	    {
		new lada = random_num(3, 5)
		LadaK[lada][Top1] += 5;
		Lada[lada][Top1] += 5;
		client_print_color(Top1, print_team_default, "^3[DEBUG]^1 Mivel már ^3VIP^1 vagy ezért kaptál^3 5 random ládát + kulcsot^1 helyette.")
	    }
	    else g_VipTime[Top1] = get_systime()+86400*7
	}
	case 3:
	{
	    g_dollar[Top1] += 60.00;
	    Darkpont[Top1] += 100;
	}
	case 4:
	{
	    g_dollar[Top1] += 40.00;
	    Darkpont[Top1] += 50;
	}
	case 5:
	{
	    if(g_Vip[Top1] == 1)
	    {
		new lada = random_num(3, 5)
		LadaK[lada][Top1] += 5;
		Lada[lada][Top1] += 5;
		client_print_color(Top1, print_team_default, "^3[DEBUG]^1 Mivel már ^3VIP^1 vagy ezért kaptál^3 5 random ládát + kulcsot^1 helyette.")
	    }
	    else g_VipTime[Top1] = get_systime()+86400*7
	}
	case 6:
	{
	    LadaK[5][Top1] += 10;
	    Lada[5][Top1] += 10;
	}
	case 7:
	{
	    LadaK[4][Top1] += 15;
	    Lada[4][Top1] += 15;  
	}
	case 8:
	{
	   g_dollar[Top1] += 30.00;
	   if(g_Vip[Top1] == 1)
	    {
		new lada = random_num(3, 5)
		LadaK[lada][Top1] += 5;
		Lada[lada][Top1] += 5;
		client_print_color(Top1, print_team_default, "^3[DEBUG]^1 Mivel már ^3VIP^1 vagy ezért kaptál^3 5 random ládát + kulcsot^1 helyette.")
	    }
	    else g_VipTime[Top1] = get_systime()+86400*7
	}
	case 9:
	{
	    g_dollar[Top1] += 60.00;
	    Darkpont[Top1] += 100;
	}
	case 10:
	{
	    g_dollar[Top1] += 40.00;
	    Darkpont[Top1] += 50;
	}
	case 11:
	{
	   if(g_Vip[Top1] == 1)
	    {
		new lada = random_num(3, 5)
		LadaK[lada][Top1] += 5;
		Lada[lada][Top1] += 5;
		client_print_color(Top1, print_team_default, "^3[DEBUG]^1 Mivel már ^3VIP^1 vagy ezért kaptál^3 5 random ládát + kulcsot^1 helyette.")
	    }
	    else g_VipTime[Top1] = get_systime()+86400*7
	}
	case 12: 
	{
	    new kes = random_num (51, 73);
	    g_Weapons[kes][Top1]++;
	}
	}
	switch(FragJutalmak2)
	{
	case 0:
	{
	    LadaK[4][Top2] += 10;
	    Lada[4][Top2] += 10;
	}
	case 1:
	{
	    LadaK[3][Top2] += 10;
	    Lada[3][Top2] += 10;
	}
	case 2:
	{
	    g_dollar[Top2] += 30.00;
	    if(g_Vip[Top2] == 1)
	    {
		new lada = random_num(3, 5)
		LadaK[lada][Top2] += 5;
		Lada[lada][Top2] += 5;
		client_print_color(Top2, print_team_default, "^3[DEBUG]^1 Mivel már ^3VIP^1 vagy ezért kaptál^3 5 random ládát + kulcsot^1 helyette.")
	    }
	    else g_VipTime[Top2] = get_systime()+86400*3
	}
	case 3:
	{
	    g_dollar[Top2] += 30.00;
	    Darkpont[Top2] += 50;
	}
	case 4:
	{
	    g_dollar[Top2] += 20.00;
	    Darkpont[Top2] += 50;
	}
	case 5:
	{
	    if(g_Vip[Top2] == 1)
	    {
		new lada = random_num(3, 5)
		LadaK[lada][Top2] += 5;
		Lada[lada][Top2] += 5;
		client_print_color(Top2, print_team_default, "^3[DEBUG]^1 Mivel már ^3VIP^1 vagy ezért kaptál^3 5 random ládát + kulcsot^1 helyette.")
	    }
	    else g_VipTime[Top2] = get_systime()+86400*5
	}
	case 6:
	{
	    LadaK[4][Top2] += 10;
	    Lada[4][Top2] += 10;
	}
	case 7:
	{
	   if(g_Vip[Top2] == 1)
	    {
		new lada = random_num(3, 5)
		LadaK[lada][Top2] += 5;
		Lada[lada][Top2] += 5;
		client_print_color(Top2, print_team_default, "^3[DEBUG]^1 Mivel már ^3VIP^1 vagy ezért kaptál^3 5 random ládát + kulcsot^1 helyette.")
	    }
	    else g_VipTime[Top2] = get_systime()+86400*3
	}
	case 8:
	{
	   g_dollar[Top2] += 40.00;
	}
	case 9:
	{
	    g_dollar[Top2] += 30.00;
	    Darkpont[Top2] += 50;
	}
	}
	switch(FragJutalmak3)
	{
	case 0:
	{
	    LadaK[3][Top3] += 5;
	    Lada[3][Top3] += 5;
	}
	case 1:
	{
	    g_dollar[Top3] += 10.00;
	    if(g_Vip[Top3] == 1)
	    {
		new lada = random_num(2, 4)
		LadaK[lada][Top3] += 5;
		Lada[lada][Top3] += 5;
		client_print_color(Top3, print_team_default, "^3[DEBUG]^1 Mivel már ^3VIP^1 vagy ezért kaptál^3 5 random ládát + kulcsot^1 helyette.")
	    }
	    else g_VipTime[Top3] = get_systime()+86400
	}
	case 2:
	{
	    g_dollar[Top3] += 20.00;
	}
	case 3:
	{
	    g_dollar[Top3] += 10.00;
	}
	case 4:
	{
	    if(g_Vip[Top3] == 1)
	    {
		new lada = random_num(2, 4)
		LadaK[lada][Top3] += 5;
		Lada[lada][Top3] += 5;
		client_print_color(Top3, print_team_default, "^3[DEBUG]^1 Mivel már ^3VIP^1 vagy ezért kaptál^3 5 random ládát + kulcsot^1 helyette.")
	    }
	    else g_VipTime[Top3] = get_systime()+86400*3
	}
	case 5:
	{
	   if(g_Vip[Top3] == 1)
	    {
		new lada = random_num(3, 5)
		LadaK[lada][Top3] += 5;
		Lada[lada][Top3] += 5;
		client_print_color(Top3, print_team_default, "^3[DEBUG]^1 Mivel már ^3VIP^1 vagy ezért kaptál^3 5 random ládát + kulcsot^1 helyette.")
	    }
	    else g_VipTime[Top3] = get_systime()+86400
	}
	case 6:
	{
	   g_dollar[Top3] += 20.00;
	}
	case 7:
	{
	    g_dollar[Top3] += 10.00;
	    Darkpont[Top3] += 50;
	}
	}
}
public RoundEnds()
{
	new players[32], num
	get_players(players, num);
	SortCustom1D(players, num, "SortMVPToPlayer")
	TopMvp = players[0]
	new mvpName[32]
	get_user_name(TopMvp, mvpName, charsmax(mvpName))
	
	
	if(mvpr_have_selectedkit[TopMvp] > 0)
	{
		client_print_color(0, print_team_default, "^3%s^1 A legjobb játékos ebben a körben ^4%s^1 volt, ezért egy ^4%s^1 zenekészlet szól.", PREFIX, mvpName, MusicKitInfos[mvpr_have_selectedkit[TopMvp]][MusicKitName]);
		client_cmd(0,"mp3 play %s", MusicKitInfos[mvpr_have_selectedkit[TopMvp]][MusicLocation]);
	}
	else
		client_print_color(0, print_team_default, "^3%s^1 A legjobb játékos ebben a körben ^4%s^1 volt, de mivel nincs felszerelt zenekészletje, ezért nem szól semmi.", PREFIX, mvpName);
	
	for(new i; i < g_Maxplayers; i++)
		g_MVPoints[i] = 0;

	eloELO[TopMvp] += 15;
	eloXP[TopMvp] += 5.00;
}
public SortMVPToPlayer(id1, id2){
	if(g_MVPoints[id1] > g_MVPoints[id2]) return -1;
	else if(g_MVPoints[id1] < g_MVPoints[id2]) return 1;
 
	return 0;
}
public bomb_planted(id) {
	g_MVPoints[id] += 3
	eloELO[id] += 10;
	eloXP[TopMvp] += 5.00;
}
public bomb_defused(id) {
	g_MVPoints[id] += 5
	eloELO[id] += 10;
	eloXP[TopMvp] += 5.00;
}
public CheckErem(id)
{
	if(isRuined == 0)
	{
		if(masodpercek[id] > 2592000 && Erem[13][id] == 0)
			AddErem(id, 13, 0)
		if(g_Id[id] < 1000 && Erem[2][id] == 0)
			AddErem(id, 2, 3)
		if(1001 < g_Id[id] < 2000 && Erem[3][id] == 0)
			AddErem(id, 3, 3)
		if(2001 < g_Id[id] < 3000 && Erem[4][id] == 0)
			AddErem(id, 4, 3)
		if(3001 < g_Id[id] < 4000 && Erem[5][id] == 0)
			AddErem(id, 5, 3)
		if(4001 < g_Id[id] <  5000 && Erem[6][id] == 0)
			AddErem(id, 6, 3)
		if(4001 < g_Id[id] <  5000 && Erem[6][id] == 0)
			AddErem(id, 6, 3)
		if(TopFrag_1[id] == 5 && Erem[9][id] == 0)
			AddErem(id, 9, 3)
		if(TopFrag_2[id] == 5 && Erem[9][id] == 0)
			AddErem(id, 10, 3)
		if(TopFrag_2[id] == 5 && Erem[9][id] == 0)
			AddErem(id, 11, 3)
		if(erdem[id] == 1 && Erem[1][id] == 0)
			AddErem(id, 1, 4)
		if(erdem2[id] == 1 && Erem[19][id] == 0)
			AddErem(id, 19, 4)
		if(Wins[id] > 50 && Erem[20][id] == 0)
			AddErem(id, 20, 2)

		isRuined = 1;
	}
}
public AddErem(id, eremid, type)
{
	new sTime[9], sDate[11], sDateAndTime[32];

	get_time("%H:%M:%S", sTime, 8 );
	get_time("%Y/%m/%d", sDate, 11);
	formatex(sDateAndTime, 31, "%s %s", sDate, sTime);

	Erem[eremid][id]++;
	client_print_color(0, print_team_default, "^3%s^1 Játékos: ^4%s^1 megszerezte a ^4%s^1 érdemérmet.", PREFIX, Player[id][f_PlayerNames], g_Ermek[eremid][erem_name])
}
public BattlePassMenu(id)
{
  if(BattlePassPurchased[id] == 0)
	return;

  new iString[512]
  new menu = menu_create("\r[\y.:*[Dark*.*Angel'S]*:.\r] \wv4.5.5  ~  BattlePass", "b_BattlePass")

  format(iString, charsmax(iString), "\rBattlePass szint:\y %i", battlepass_szint[id])
  menu_addtext2(menu, iString)
  format(iString, charsmax(iString), "\rJutalmad:\y %s", BattlePass[battlepass_szint[id]][Names])
  menu_addtext2(menu, iString)
  format(iString, charsmax(iString), "\rKövetkező Jutalmad:\y %s", BattlePass[battlepass_szint[id]+1][Names])
  menu_addtext2(menu, iString)
  format(iString, charsmax(iString), "\rKövetkező utáni:\y %s", BattlePass[battlepass_szint[id]+2][Names])
  menu_addtext2(menu, iString)

  menu_display(id, menu, 0)
}
public b_BattlePass(id, menu, key)
{
  if(key == MENU_EXIT)
  {
    menu_destroy(menu);
    return;
  }
  new data[9], szName[64];
  new access, callback;
  menu_item_getinfo(menu, key, access, data,charsmax(data), szName,charsmax(szName), callback);
}
