#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <colorchat>
#include <hamsandwich>
#include <engine>
#include <fun>
#include <sqlx>
#include <fakemeta>

new PLUGIN[28] = "Avatar";
new VERSION[16] = "1.0";
new AUTHOR[4];
new Prefix[52] = "^3|^4Avatár^3|";
new C_Prefix[52] = "^3|^4Avatár^3|";
new Chat_Prefix1[44] = "^3[^4Event^3]";
new s_HOSZT[68] = "db.synhosting.eu";
new s_FELHASZNALO[40] = "viktor123";
new s_ADATBAZIS[40] = "viktor123";
new s_JELSZO[44] = "viktor1234";
new AccountId[33];
new g_frozen[33];
new bool:g_Bejelentkezve[33];
new filename[128];
new Keres[33];
new Kereskedik[33];
new KerID[33];
new KerDB[33];
new Float:KerDollar[33];
new JelolID[33];
new Fogad[33];
new Targy[33];
new KivLada[33];
new addolasikulcs;
new g_iVipNum[33];
new accountpause;
new AutoLogin = 1;
new s_addvariable[33];
new viptorol;
new vip_porgetes;
new Top[3][15];
new TopNev[3][15][32];
new TopRang[15];
new caseid;
new g_Jutalom[4][33];
new g_QuestHead[33];
new g_Quest[33];
new g_QuestKills[2][33];
new g_QuestWeapon[33];
new g_QuestMVP[33];
new g_snapshot[33];
new ajandekcsomag[33];
new vipkupon[33];
new havazas;
new l_Nevek[7][0] =
{
    {
        66////, ...
    },
    {
        83////, ...
    },
    {
        70////, ...
    },
    {
        79////, ...
    },
    {
        80////, ...
    },
    {
        72////, ...
    },
    {
        195////, ...
    }
};
new Berakepiros[33];
new Berakezold[33];
new Berakeszurke[33];
new BerakeTER[33];
new BerakeCT[33];
new betett[33];
new g_iTime[33];
new g_iVipTime[33];
new h_lada[33];
new Lada[7][33];
new Kulcs[33];
new Float:Dollar[33];
new Rang[33];
new Oles[33];
new Gun[12][33];
new biztonsagikerdes[33];
new Hud[33];
new D_Oles[33];
new name[33][33];
new Masodpercek[33];
new SMS[33];
new Vip[33];
new Float:Erteke[33];
new kicucc[33];
new kirakva[33];
new kicucc2[33];
new pido;
new Event[33];
new Ct_Prefix[32][33];
new VanPrefix[33];
new g_Erem[33];
new g_Premium[33];
new g_Felhasznalonev[33][100];
new g_Jelszo[33][100];
new g_JelszoUj[33][100];
new g_JelszoRegi[33][100];
new s_biztonsagikerdes[33][100];
new s_valasz[33][100];
new s_valaszirt[33][100];
new s_temporarypass[33][100];
new g_FHVIP[33][100];
new g_Indok[33][100];
new adminname[33][100];
new g_trickban[33][100];
new g_RegisztracioVagyBejelentkezes[33];
new g_Id[33];
new g_Email[33][100];
new g_Aktivitas[33];
new g_Folyamatban[33];
new Send[33];
new TempID;
new Handle:g_SqlTuple;
new Temp[192];
new color[10];
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
new kivalasztott[33][WPNS];
enum _:Adatok {
    Type[8],
    Nev[64],
    Model[64],
    Float:BoltiAr[8]
}
new FegyverAdatok[][Adatok] =
{
    {0, "AK47 | Aquamarine(45$)", "models/2k22newskins/ak47/1.mdl", 45.0},
    {0, "AK47 | Asiimov(20$)", "models/2k22newskins/ak47/2.mdl", 20.0},
    {0, "AK47 | Beast Prime(25$)", "models/2k22newskins/ak47/3.mdl", 25.0},
    {0, "AK47 | Blue Star(5$)", "models/2k22newskins/ak47/4.mdl", 5.0},
    {0, "AK47 | Edzett(56$)", "models/2k22newskins/ak47/5.mdl", 56.0},
    {0, "AK47 | Fire Serpent(20$)", "models/2k22newskins/ak47/6.mdl", 20.0},
    {0, "AK47 | Frontside(40$)", "models/2k22newskins/ak47/7.mdl", 40.0},
    {0, "AK47 | Fuel injector(60$)", "models/2k22newskins/ak47/8.mdl", 60.0},
    {0, "AK47 | Hydroponic(110$)", "models/2k22newskins/ak47/9.mdl", 110.0},
    {0, "AK47 | Jaguár(150$)", "models/2k22newskins/ak47/10.mdl", 150.0},
    {0, "AK47 | Neon(200$)", "models/2k22newskins/ak47/11.mdl", 200.0},
    {0, "AK47 | Örök(95$)", "models/2k22newskins/ak47/12.mdl", 95.0},
    {0, "AK47 | Phantom(35$)", "models/2k22newskins/ak47/13.mdl", 35.0},
    {0, "AK47 | Redline(100$)", "models/2k22newskins/ak47/14.mdl", 100.0},
    {0, "AK47 | Rendezetlenség(150$)", "models/2k22newskins/ak47/15.mdl", 150.0},
    {0, "AK47 | Sticker(98$)", "models/2k22newskins/ak47/16.mdl", 98.0},
    {0, "AK47 | Leet Museo(66$)", "models/2k22newskins/ak47/17.mdl", 66.0},
    {0, "AK47 | Vulcan(100$)", "models/2k22newskins/ak47/18.mdl", 100.0},
    {0, "AK47 | Wasteland(300$)", "models/2k22newskins/ak47/19.mdl", 300.0},
    {0, "M4A1 | Kék köd (6,18$)", "models/2k22newskins/m4a1/1.mdl", 6.18},
    {0, "M4A1 | Megvalósulás (94$)", "models/2k22newskins/m4a1/2.mdl", 94.0},
    {0, "M4A1 | Golden With Mascot (45$)", "models/2k22newskins/m4a1/2.mdl", 45.0},
    {0, "M4A1 | Piros kavalkád (98,89$)", "models/2k22newskins/m4a1/4.mdl", 98.89},
    {0, "M4A1 | Bumblebee (13,32$)", "models/2k22newskins/m4a1/5.mdl", 13.32},
    {0, "M4A1 | Chanticos Fire (20$)", "models/2k22newskins/m4a1/6.mdl", 20.0},
    {0, "M4A1 | Condor (20$)", "models/2k22newskins/m4a1/7.mdl", 20.0},
    {0, "M4A1 | Desolate Space (8$)", "models/2k22newskins/m4a1/8.mdl", 8.0},
    {0, "M4A1 | Galaxy (60$)", "models/2k22newskins/m4a1/9.mdl", 60.0},
    {0, "M4A1 | Golden Coil (5$)", "models/2k22newskins/m4a1/10.mdl", 5.0},
    {0, "M4A1 | Hellfire (5,12$)", "models/2k22newskins/m4a1/11.mdl", 5.12},
    {0, "M4A1 | Howl (15$)", "models/2k22newskins/m4a1/12.mdl", 15.0},
    {0, "M4A1 | Hyper Beast (13,17$)", "models/2k22newskins/m4a1/13.mdl", 13.17},
    {0, "M4A1 | Iving Color (66$)", "models/2k22newskins/m4a1/14.mdl", 66.0},
    {0, "M4A1 | Master (10$)", "models/2k22newskins/m4a1/15.mdl", 10.0},
    {0, "M4A1 | Musica (5$)", "models/2k22newskins/m4a1/16.mdl", 5.0},
    {0, "M4A4 | Pop Star (34$)", "models/2k22newskins/m4a1/17.mdl", 34.0},
    {0, "M4A1 | Poseidon (42,65$)", "models/2k22newskins/m4a1/18.mdl", 42.65},
    {0, "M4A1 | Sticker (8,13$)", "models/2k22newskins/m4a1/19.mdl", 8.13},
    {0, "M4A1 | Toxic (55$)", "models/2k22newskins/m4a1/20.mdl", 55.0},
    {0, "AWP | Desert Hydra. (50$)", "models/2k22newskins/awp/1.mdl", 50.0},
    {0, "AWP | Galaxy (5$)", "models/2k22newskins/awp/2.mdl", 5.0},
    {0, "AWP | Phoenix (120$)", "models/2k22newskins/awp/3.mdl", 120.0},
    {0, "AWP | Dragon Lore (30,75$)", "models/2k22newskins/awp/4.mdl", 30.75},
    {0, "AWP | Gungnir (16,21$)", "models/2k22newskins/awp/5.mdl", 16.21},
    {0, "AWP | Pop (12$)", "models/2k22newskins/awp/6.mdl", 12.0},
    {0, "AWP | Artistic (80$)", "models/2k22newskins/awp/7.mdl", 80.0},
    {0, "AWP | Malaysia(50$)", "models/2k22newskins/awp/8.mdl", 50.0},
    {0, "AWP | Assimov(70$)", "models/2k22newskins/awp/9.mdl", 70.0},
    {0, "AWP | Deadly Bbirds(60$)", "models/2k22newskins/awp/10.mdl", 60.0},
    {0, "AWP | Virus(85$)", "models/2k22newskins/awp/11.mdl", 85.0},
    {0, "AWP | Neural(30,15$)", "models/2k22newskins/awp/12.mdl", 30.15},
    {0, "AWP | Lightning Strike(75$)", "models/2k22newskins/awp/13.mdl", 75.0},
    {0, "AWP | Boom(20$)", "models/2k22newskins/awp/14.mdl", 20.0},
    {0, "AWP | Fever Dream(23$)", "models/2k22newskins/awp/15.mdl", 23.0},
    {0, "FAMAS | Hound (10$)", "models/2k22newskins/famas/1.mdl", 10.0},
    {0, "FAMAS | Neon mist (10$)", "models/2k22newskins/famas/2.mdl", 10.0},
    {0, "FAMAS | Pulse (4$)", "models/2k22newskins/famas/3.mdl", 4.0},
    {0, "FAMAS | Psycho [HD] (9$)", "models/2k22newskins/famas/4.mdl", 9.0},
    {0, "FAMAS | Spectron (15$)", "models/2k22newskins/famas/5.mdl", 15.0},
    {0, "FAMAS | Old(3$)", "models/2k22newskins/famas/6.mdl", 3.0},
    {0, "MP5 | Horn of War (2$)", "models/2k22newskins/mp5/1.mdl", 2.0},
    {0, "MP5 | FBI [HD]  (15$)", "models/2k22newskins/mp5/2.mdl", 15.0},
    {0, "MP5 | Nemesis (5$)", "models/2k22newskins/mp5/3.mdl", 5.0},
    {0, "MP5 | Blood Sport [HD] (10$)", "models/2k22newskins/mp5/4.mdl", 10.0},
    {0, "MP5 | Asiimov (8$)", "models/2k22newskins/mp5/5.mdl", 8.0},
    {0, "MP5 | Pink Camo (3$)", "models/2k22newskins/mp5/6.mdl", 3.0},
    {0, "MP5 | Red Parts (2$)", "models/2k22newskins/mp5/7.mdl", 2.0},
    {0, "GALIL | chromatic (10$)", "models/2k22newskins/galil/1.mdl", 10.0},
    {0, "GALIL | Orange [HD](15$)", "models/2k22newskins/galil/2.mdl", 15.0},
    {0, "GALIL | Sirius v1 [HD] (25$)", "models/2k22newskins/galil/3.mdl", 25.0},
    {0, "GALIL | Biomech [HD](20$)", "models/2k22newskins/galil/4.mdl", 20.0},
    {0, "SCOUT | Death Strike (17$)", "models/2k22newskins/scout/1.mdl", 17.0},
    {0, "SCOUT | Dragonfire (10$)", "models/2k22newskins/scout/2.mdl", 10.0},
    {0, "SCOUT | Turbo Peek (5$)", "models/2k22newskins/scout/3.mdl", 5.0},
    {0, "DEAGLE | Ghost. (5$)", "models/2k22newskins/deagle/1.mdl", 5.0},
    {0, "DEAGLE | Fennec Fox (7$)", "models/2k22newskins/deagle/2.mdl", 7.0},
    {0, "DEAGLE | Ocean Drive (4$)", "models/2k22newskins/deagle/3.mdl", 4.0},
    {0, "DEAGLE | Discipline (4$)", "models/2k22newskins/deagle/4.mdl", 4.0},
    {0, "DEAGLE | Galaxy (6$)", "models/2k22newskins/deagle/5.mdl", 6.0},
    {0, "DEAGLE | Jungle (5$)", "models/2k22newskins/deagle/6.mdl", 5.0},
    {0, "DEAGLE | LSD (2$)", "models/2k22newskins/deagle/7.mdl", 2.0},
    {0, "DEAGLE | Sticker (7$)", "models/2k22newskins/deagle/8.mdl", 7.0},
    {0, "DEAGLE | Tales of The Hunter (10$)", "models/2k22newskins/deagle/9.mdl", 10.0},
    {0, "DEAGLE | Toxicator (30,80$)", "models/2k22newskins/deagle/10.mdl", 30.80},
    {0, "USP-S | Neoir (15,76$)", "models/2k22newskins/usp/1.mdl", 15.76},
    {0, "USP-S | Cyrex (18$)", "models/2k22newskins/usp/2.mdl", 18.0},
    {0, "USP-S | Fade (20$)", "models/2k22newskins/usp/3.mdl", 20.0},
    {0, "USP-S | Monster Mashup [HD](50$)", "models/2k22newskins/usp/4.mdl", 50.0},
    {0, "USP-S | Swirl (5,34$)", "models/2k22newskins/usp/5.mdl", 5.34},
    {0, "USP-S | Aimbot [HD] (80$)", "models/2k22newskins/usp/6.mdl", 80.0},
    {0, "USP-S | Red Destiny (8,95$)", "models/2k22newskins/usp/7.mdl", 8.95},
    {0, "USP-S | Fat Cap [HD] (70,92$)", "models/2k22newskins/usp/8.mdl", 70.92},
    {0, "USP-S | Green Dragon (20$)", "models/2k22newskins/usp/9.mdl", 20.0},
    {0, "GLOCK | Hyper Beast (1,55$)", "models/2k22newskins/glock/1.mdl", 1.55},
    {0, "GLOCK | Lucy (10,6$)", "models/2k22newskins/glock/2.mdl", 10.6},
    {0, "GLOCK | Snack Attac (8,34$)", "models/2k22newskins/glock/3.mdl", 8.34},
    {0, "GLOCK | Water Elemental (2,75$)", "models/2k22newskins/glock/4.mdl", 2.75},
    {0, "KNIFE | Bowie [Doppler] (100$)", "models/2k22newskins/knife/1.mdl", 100.0},
    {0, "KNIFE | Bowie [Fade] (395,60$)", "models/2k22newskins/knife/2.mdl", 395.60},
    {0, "KNIFE | Butterfly [Blue] (400,18$)", "models/2k22newskins/knife/3.mdl", 400.18},
    {0, "KNIFE | Butterfly [Lore] (1500$)", "models/2k22newskins/knife/4.mdl", 1500.0},
    {0, "KNIFE | Classic [fade] (620,2$)", "models/2k22newskins/knife/5.mdl", 620.2},
    {0, "KNIFE | Default [Marble Fade] (2500$)", "models/2k22newskins/knife/6.mdl", 2500.0},
    {0, "KNIFE | Falchion [Doppler Blue] (480,16$)", "models/2k22newskins/knife/7.mdl", 480.16},
    {0, "KNIFE | Falchion [Dragon Lore] (150,5$)", "models/2k22newskins/knife/8.mdl", 150.5},
    {0, "KNIFE | Flip [Autotronic] (400,56$)", "models/2k22newskins/knife/9.mdl", 400.56},
    {0, "KNIFE | Flip [Marble Fade] (600,39$)", "models/2k22newskins/knife/10.mdl", 600.39},
    {0, "KNIFE | Gut [Marble Fade] (380,14$)", "models/2k22newskins/knife/11.mdl", 380.14},
    {0, "KNIFE | Huntsman [Crimson Web] (920$)", "models/2k22newskins/knife/12.mdl", 920.0},
    {0, "KNIFE | Huntsman [Hyper Beast] (225,35$)", "models/2k22newskins/knife/13.mdl", 225.35},
    {0, "KNIFE | Karambit [Fade] (25,76$)", "models/2k22newskins/knife/14.mdl", 25.76},
    {0, "KNIFE | Karambit [Gamma Doppler] (40$)", "models/2k22newskins/knife/15.mdl", 40.0},
    {0, "KNIFE | M9 Bayonet [Galaxy] (70$)", "models/2k22newskins/knife/16.mdl", 70.0},
    {0, "KNIFE | M9 Bayonet [Splinter] (71$)", "models/2k22newskins/knife/17.mdl", 71.0},
    {0, "KNIFE | Navaja [Case Hardened] (50$)", "models/2k22newskins/knife/18.mdl", 50.0},
    {0, "KNIFE | Shadow Daggers [Gamma Doppler] (54$)", "models/2k22newskins/knife/19.mdl", 54.0},
    {0, "KNIFE | Shadow Daggers [Neon Rider] (80$)", "models/2k22newskins/knife/20.mdl", 80.0},
    {0, "KNIFE | Skeleton [Fade] (36$)", "models/2k22newskins/knife/21.mdl", 36.0},
    {0, "KNIFE | Skeleton [Night] (88$)", "models/2k22newskins/knife/22.mdl", 88.0},
    {0, "KNIFE | Talon [Doppler Sapphire] (54$)", "models/2k22newskins/knife/23.mdl", 54.0},
    {0, "KNIFE | Ursus (23$)", "models/2k22newskins/knife/24.mdl", 23.0},
    {0, "ALAP | AK-47", "models/v_ak47.mdl", 0.0},
    {0, "ALAP | M4A1", "models/v_m4a1.mdl", 0.0},
    {0, "ALAP | AWP", "models/v_awp.mdl", 0.0},
    {0, "ALAP | FAMAS", "models/v_famas.mdl", 0.0},
    {0, "ALAP | MP5", "models/v_mp5.mdl", 0.0},
    {0, "ALAP | GALIL", "models/v_galil.mdl", 0.0},
    {0, "ALAP | SCOUT", "models/v_scout.mdl", 0.0},
    {0, "ALAP | DEAGLE", "models/v_deagle.mdl", 0.0},
    {0, "ALAP | GLOCK18", "models/v_glock18.mdl", 0.0},
    {0, "ALAP | USP", "models/v_usp.mdl", 0.0},
    {0, "ALAP | K�S", "models/v_knife.mdl", 0.0},
    {0, "FragBajnok KES", "models/2k22newskins/50.mdl", 0.0},
    {0, "VIP KES", "models/2k22newskins/vip.mdl", 0.0},
};
new PiacTargy[129][0] =
{
    {
        65//, ...
    },
    {
        65//, ...
    },
    {
        65//, ...
    },
    {
        65//, ...
    },
    {
        65//, ...
    },
    {
        65//, ...
    },
    {
        65//, ...
    },
    {
        65//, ...
    },
    {
        65//, ...
    },
    {
        65//, ...
    },
    {
        65//, ...
    },
    {
        65//, ...
    },
    {
        65//, ...
    },
    {
        65//, ...
    },
    {
        65//, ...
    },
    {
        65//, ...
    },
    {
        65//, ...
    },
    {
        65//, ...
    },
    {
        65//, ...
    },
    {
        77//, ...
    },
    {
        77//, ...
    },
    {
        77//, ...
    },
    {
        77//, ...
    },
    {
        77//, ...
    },
    {
        77//, ...
    },
    {
        77//, ...
    },
    {
        77//, ...
    },
    {
        77//, ...
    },
    {
        77//, ...
    },
    {
        77//, ...
    },
    {
        77//, ...
    },
    {
        77//, ...
    },
    {
        77//, ...
    },
    {
        77//, ...
    },
    {
        77//, ...
    },
    {
        77//, ...
    },
    {
        77//, ...
    },
    {
        77//, ...
    },
    {
        77//, ...
    },
    {
        65//, ...
    },
    {
        65//, ...
    },
    {
        65//, ...
    },
    {
        65//, ...
    },
    {
        65//, ...
    },
    {
        65//, ...
    },
    {
        65//, ...
    },
    {
        65//, ...
    },
    {
        65//, ...
    },
    {
        65//, ...
    },
    {
        65//, ...
    },
    {
        65//, ...
    },
    {
        65//, ...
    },
    {
        65//, ...
    },
    {
        65//, ...
    },
    {
        70//, ...
    },
    {
        70//, ...
    },
    {
        70//, ...
    },
    {
        70//, ...
    },
    {
        70//, ...
    },
    {
        70//, ...
    },
    {
        77//, ...
    },
    {
        77//, ...
    },
    {
        77//, ...
    },
    {
        77//, ...
    },
    {
        77//, ...
    },
    {
        77//, ...
    },
    {
        77//, ...
    },
    {
        71//, ...
    },
    {
        71//, ...
    },
    {
        71//, ...
    },
    {
        71//, ...
    },
    {
        83//, ...
    },
    {
        83//, ...
    },
    {
        83//, ...
    },
    {
        68//, ...
    },
    {
        68//, ...
    },
    {
        68//, ...
    },
    {
        68//, ...
    },
    {
        68//, ...
    },
    {
        68//, ...
    },
    {
        68//, ...
    },
    {
        68//, ...
    },
    {
        68//, ...
    },
    {
        68//, ...
    },
    {
        85//, ...
    },
    {
        85//, ...
    },
    {
        85//, ...
    },
    {
        85//, ...
    },
    {
        85//, ...
    },
    {
        85//, ...
    },
    {
        85//, ...
    },
    {
        85//, ...
    },
    {
        85//, ...
    },
    {
        71//, ...
    },
    {
        71//, ...
    },
    {
        71//, ...
    },
    {
        71//, ...
    },
    {
        75//, ...
    },
    {
        75//, ...
    },
    {
        75//, ...
    },
    {
        75//, ...
    },
    {
        75//, ...
    },
    {
        75//, ...
    },
    {
        75//, ...
    },
    {
        75//, ...
    },
    {
        75//, ...
    },
    {
        75//, ...
    },
    {
        75//, ...
    },
    {
        75//, ...
    },
    {
        75//, ...
    },
    {
        75//, ...
    },
    {
        75//, ...
    },
    {
        75//, ...
    },
    {
        75//, ...
    },
    {
        75//, ...
    },
    {
        75//, ...
    },
    {
        75//, ...
    },
    {
        75//, ...
    },
    {
        75//, ...
    },
    {
        75//, ...
    },
    {
        75//, ...
    },
    {
        92//, ...
    },
    {
        92//, ...
    },
    {
        92//, ...
    },
    {
        92//, ...
    },
    {
        92//, ...
    },
    {
        92//, ...
    },
    {
        92//, ...
    },
    {
        92//, ...
    }
};
enum _:Rangs { Szint[32], Xp[8] };
new const Rangok[][Rangs] =
{
	{ "Szia Lajos", 25 },
	{ "Udvaribolond", 100 },
	{ "d", 250 },
	{ "Talpnyaló", 500 },
	{ "Szaros gatyás", 700 },
	{ "Kezdek belejönni", 850 },
	{ "Gilisztaképű", 1000 },
	{ "Recskamester", 3000 },
	{ "Kissebségi rántotthús", 4500 },
	{ "Tibeti bukfencgalamb", 6500 },
	{ "Szőkecigány", 8500 },
	{ "Pörköltképű", 9999 },
	{ "nyó kapitány", 10500 },
	{ "baszógép", 12000 },
	{ "hitaló", 14000 },
	{ "Geciputtony", 16000 },
	{ "Szerver gyilkólógépe", 18000 },
	{ "de jó vagyok", 20000 },
	{ "HackMester", 1000000 },
	{ "Miniszterelnök", 2000000 },
};
new ErdemErmek[19][40] =
{
    {
        78, 105, 110, 99, 115, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0
    },
    {
        90, 195, 182, 108, 100, 115, 97, 112, 107, 195, 161, 115, 226, 128, 152, 32, 49, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 0, 0, 0, 0, 0, 0, 0
    },
    {
        90, 195, 182, 108, 100, 115, 97, 112, 107, 195, 161, 115, 226, 128, 152, 32, 50, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 15, 0, 0, 0, 0, 0, 0, 0
    },
    {
        90, 195, 182, 108, 100, 115, 97, 112, 107, 195, 161, 115, 226, 128, 152, 32, 51, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 25, 0, 0, 0, 0, 0, 0, 0
    },
    {
        79, 110, 100, 195, 179, 103, 121, 117, 114, 109, 97, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 35, 0, 0, 0, 0, 0, 0, 0
    },
    {
        83, 122, 111, 112, 195, 179, 102, 97, 110, 116, 111, 109, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 40, 0, 0, 0, 0, 0, 0, 0
    },
    {
        66, 195, 161, 110, 97, 116, 32, 97, 114, 99, 195, 186, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 50, 0, 0, 0, 0, 0, 0, 0
    },
    {
        91, 90, 111, 107, 110, 105, 115, 93, 32, 72, 111, 107, 105, 109, 101, 115, 116, 101, 114, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 60, 0, 0, 0, 0, 0, 0, 0
    },
    {
        71, 117, 109, 105, 110, 197, 145, 116, 32, 107, 105, 114, 195, 161, 103, 195, 179, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 0, 0, 0, 0, 0, 0, 0
    },
    {
        77, 111, 110, 105, 116, 111, 114, 116, 32, 115, 122, 195, 169, 116, 116, 97, 107, 110, 121, 111, 108, 195, 179, 0, 0, 0, 0, 0, 0, 0, 0, 0, 120, 0, 0, 0, 0, 0, 0, 0
    },
    {
        79, 110, 100, 195, 179, 107, 111, 99, 115, 102, 97, 108, 101, 107, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 140, 0, 0, 0, 0, 0, 0, 0
    },
    {
        91, 76, 105, 115, 122, 107, 97, 105, 93, 32, 112, 117, 108, 116, 195, 179, 110, 98, 97, 115, 122, 195, 179, 0, 0, 0, 0, 0, 0, 0, 0, 0, 170, 0, 0, 0, 0, 0, 0, 0
    },
    {
        78, 195, 161, 99, 105, 122, 111, 109, 98, 105, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 200, 0, 0, 0, 0, 0, 0, 0
    },
    {
        83, 122, 111, 118, 106, 101, 116, 32, 112, 97, 116, 107, 195, 161, 110, 121, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 240, 0, 0, 0, 0, 0, 0, 0
    },
    {
        91, 77, 111, 99, 115, 107, 111, 115, 93, 32, 72, 105, 116, 108, 101, 114, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 300, 0, 0, 0, 0, 0, 0, 0
    },
    {
        91, 67, 105, 103, 195, 161, 110, 121, 93, 32, 76, 101, 110, 105, 110, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 500, 0, 0, 0, 0, 0, 0, 0
    },
    {
        91, 75, 111, 108, 111, 109, 112, 195, 161, 114, 93, 32, 68, 122, 115, 101, 107, 105, 99, 115, 101, 110, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 700, 0, 0, 0, 0, 0, 0, 0
    },
    {
        91, 76, 97, 107, 97, 116, 111, 115, 93, 32, 75, 105, 115, 68, 122, 115, 97, 110, 103, 195, 179, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1100, 0, 0, 0, 0, 0, 0, 0
    },
    {
        91, 76, 101, 103, 101, 110, 100, 195, 161, 115, 93, 32, 86, 97, 107, 112, 195, 173, 107, 195, 179, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 11000, 0, 0, 0, 0, 0, 0, 0
    }
};
new LadaDrop0[17] =
{
    70, 65, 66, 67, 68, 69, 60, 61, 62, 63, 64, 75, 76, 72, 73, 74, 98
};
new LadaDrop1[22] =
{
    0, 2, 27, 59, 70, 96, 79, 42, 4, 36, 12, 49, 51, 52, 95, 71, 31, 69, 97, 106, 110, 112
};
new LadaDrop2[20] =
{
    45, 57, 44, 48, 47, 46, 33, 93, 86, 34, 28, 21, 9, 5, 40, 3, 98, 107, 113, 119
};
new LadaDrop3[20] =
{
    55, 54, 57, 13, 50, 86, 22, 19, 91, 84, 78, 7, 24, 94, 43, 37, 99, 105, 115, 118
};
new LadaDrop4[20] =
{
    39, 35, 10, 89, 92, 80, 29, 11, 17, 14, 18, 85, 30, 26, 6, 53, 103, 111, 116, 120
};
new LadaDrop5[14] =
{
    56, 93, 90, 88, 84, 23, 38, 32, 1, 16, 102, 109, 114, 117
};
new LadaDrop6[14] =
{
    76, 58, 82, 86, 87, 77, 20, 15, 41, 25, 100, 101, 104, 108
};
new meglevoek[134][33];
new berakott[33];

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR);

    sql_tuple_create();
    register_impulse(201, "Fomenu");
    register_clcmd("DOLLAR", "lekeres");
    register_clcmd("DOLLAR2", "kDollar");
    register_clcmd("DARAB", "Darab");
    register_clcmd("say", "sayhook");
    register_clcmd("say /reg", "HookSayRegMenuCommand");
    register_clcmd("say /sadd", "helperjovair");
    register_clcmd("say /sremove", "helpertorol");
    register_clcmd("say /skick", "helperkick");
    register_clcmd("say /sinfo", "cmdsinfok");
    register_clcmd("say /kills", "TopOles");
    register_concmd("coord", "get_coordinates", ADMIN_RCON, "");
    register_clcmd("say /dollars", "TopDollar");
    register_clcmd("say /playedtimes", "TopIdo");
    register_clcmd("say /kuldetes", "Kuldetes");
    register_clcmd("USERNAME", "cmdFelhasznalonev");
    register_clcmd("UPASSWORD", "cmdJelszo");
    register_clcmd("E-Mail", "cmdEmail");
    register_clcmd("NEWPASSWORD", "cmdJelszoUj");
    register_clcmd("CURRENTPASSWORD", "cmdJelszoRegi");
    register_clcmd("SKICK_INDOK", "cmdskickIndok");

    register_clcmd("Ct_Prefix", "Chat_Prefix_Hozzaad");
    register_clcmd("say /add20180814", "g_Addolas", ADMIN_RCON, "");

    register_clcmd("KMENNYISEG", "ObjectSend");
    register_clcmd("ADDMENNYISEG", "AddSend");
    register_clcmd("MEGVONMENNYISEG", "AddSend2");

    register_clcmd("BETS", "coinfliplekeres");
    register_clcmd("BETS1", "coinfliplekeres1");
    register_clcmd("BET", "rulilekeres");
    register_clcmd("BET1", "rulilekeres1");
    register_clcmd("BET2", "rulilekeres2");

    register_event("CurWeapon", "FegyverValtas", "be", "1=1");
    register_event("DeathMsg", "Halal","a");
    register_menu("Reg-Log Menu", MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_0, "menu_reglog");
    set_task(60.0, "autoSave",_,_,_, "b");
    set_task(1.0, "AutoCheck",_,_,_, "b");
    register_impulse(100, "WeaponView");
    register_clcmd("BIZTONSAGIKERDES", "biztonsagikerdes_mess");
    register_clcmd("USERNAME2", "cmdFelhasznalonev2");
    register_clcmd("USERNAME3", "cmdFelhasznalonev3");
    register_clcmd("FUGGESZTESI_INDOK", "cmdPauseAccount");
    register_clcmd("VALASZ_A_KERDESRE", "valasz_megadas");
    register_clcmd("VALASZ", "valasz2");

    RegisterHam(Ham_Spawn, "player", "VipEllenorzes", 1);
    register_event("HLTV", "IdoEllenorzes", "a", "1=0", "2=0");
    get_localinfo("amxx_datadir", filename, charsmax(filename));
    format(filename, charsmax(filename), "%s/autologins.ini", filename);
    register_forward(FM_SetModel,"fw_setmodel");
    TopEllenorzes();
    register_forward(FM_CmdStart, "fw_Start");
    register_impulse(100, "FlashLight");
}

public plugin_natives()
{
    register_native("get_user_accountid", "native_get_user_accountid", 1);
    register_native("get_user_lada6", "native_get_user_lada6", 1);
    register_native("set_user_lada6", "native_set_user_lada6", 1);
    register_native("get_user_lada5", "native_get_user_lada5", 1);
    register_native("set_user_lada5", "native_set_user_lada5", 1);
    register_native("get_user_fragkes", "native_get_user_fragkes", 1);
    register_native("set_user_fragkes", "native_set_user_fragkes", 1);
    register_native("get_user_kulcs", "native_get_user_kulcs", 1);
    register_native("set_user_kulcs", "native_set_user_kulcs", 1);
    register_native("get_user_ajandekcsomag", "native_get_user_ajandekcsomag", 1);
    register_native("set_user_ajandekcsomag", "native_set_user_ajandekcsomag", 1);
    return 0;
}

public g_Addolas(id)
{
    new i;
    while (i < 7)
    {
        Lada[i][id] += 500;
        i++;
    }
    Kulcs[id] += 500;
    SMS[id] += 4000;
    ColorChat(id, Color:2, "%s Sikeresen addoltál", C_Prefix);
}

public bomb_planted(id)
{
    new name[32];
    get_user_name(id, name, 31);
    Dollar[id] += random_float(0.1, 1.0);
    Kulcs[id] += random(1);
    ColorChat(0, Color:2, "%s %s ^3Lerakta a bombát (^4ezért dollár + kulcs járhat^3).", C_Prefix, name);
}

public bomb_defused(id)
{
    new name[32];
    get_user_name(id, name, 31);
    Dollar[id] += random_float(0.1, 1.0);
    Kulcs[id] += random(1);
    ColorChat(0, Color:2, "%s %s ^3hatástalanította a bombát ^1(^4ezért dollár + kulcs járhat^1).", C_Prefix, name);
}

public IdoEllenorzes(id)
{
    new hour;
    new minute;
    new second;
    time(hour, minute, second);
    if (0 <= hour && 10 > hour)
    {
        Event[id] = 1;
        ColorChat(id, Color:2, "%s^1Jelenleg ^4drop event van ^3(Minden nap 0 Órától - 10 Óráig).", Chat_Prefix1);
        //set_dhudmessage(random(256), random(256), random(256), -1.0, 0.2, 0, 6.0, 6.0, 0.1, 1.5, false);
        //show_dhudmessage(id, "Esemény: Drop Event");
    }
    else if (11 <= hour && 12 > hour)
    {
        Event[id] = 4;
        ColorChat(id, BLUE, "%s^1Jelenleg ^4Huntsman láda event van ^3(Minden nap 10 Órától - 12 Óráig).", Chat_Prefix1);
        //set_dhudmessage(random(256), random(256), random(256), -1.0, 0.2, 0, 6.0, 6.0, 0.1, 1.5, false);
        //show_dhudmessage(id, "Esemény: Huntsman láda Event");
    }
    else if (13 <= hour && 14 > hour)
    {
        Event[id] = 5;
        Dollar[id] += random_float(0.1, 1.0);
        ColorChat(id, Color:2, "%s^1Jelenleg ^4Dollár event van ^3(13 Órától - 14 Óráig).", Chat_Prefix1);
        //set_dhudmessage(random(256), random(256), random(256), -1.0, 0.2, 0, 6.0, 6.0, 0.1, 1.5, false);
        //show_dhudmessage(id, "Esemény: Dollár Event");
    }
    else if (15 <= hour && 16 > hour)
    {
        Event[id] = 6;
        Kulcs[id] += random(1);
        ColorChat(id, Color:2, "%s^1Jelenleg ^4Kulcs event van ^3(15 Órától - 16 Óráig).", Chat_Prefix1);
        //set_dhudmessage(random(256), random(256), random(256), -1.0, 0.2, 0, 6.0, 6.0, 0.1, 1.5, false);
        //show_dhudmessage(id, "Esemény: Kulcs Event");
    }
    else if (17 <= hour && 18 > hour)
    {
        Event[id] = 7;
        SMS[id] += random(1);
        ColorChat(id, Color:2, "%s^1Jelenleg ^4SMS Pont event van ^3(17 Órától - 18 Óráig).", Chat_Prefix1);
        //set_dhudmessage(random(256), random(256), random(256), -1.0, 0.2, 0, 6.0, 6.0, 0.1, 1.5, false);
        //show_dhudmessage(id, "Esemény: SMS Pont Event");
    }
    else if (19 <= hour && 20 > hour)
    {
        Event[id] = 3;
        ColorChat(id, GREY, "%s^1Jelenleg ^4Falcion láda event van ^3(Minden nap 20 Órától - 21 Óráig).", Chat_Prefix1);
        //set_dhudmessage(random(256), random(256), random(256), -1.0, 0.2, 0, 6.0, 6.0, 0.1, 1.5, false);
        //show_dhudmessage(id, "Esemény: Falcion Láda Event");
    }
    else if (21 <= hour && 22 > hour)
    {
        Event[id] = 2;
        ColorChat(id, BLUE, "%s^1Jelenleg ^4Árnyék láda event van ^3(Minden nap 22 Órától - 23 Óráig).", Chat_Prefix1);
        //set_dhudmessage(random(256), random(256), random(256), -1.0, 0.2, 0, 6.0, 6.0, 0.1, 1.5, false);
        //show_dhudmessage(id, "Esemény: Árnyék Láda Event");
    }
    return 1;
}

public native_get_user_accountid(index)
{
    if (g_Bejelentkezve[index])
    {
        AccountId[index] = g_Id[index];
    }
    return AccountId[index];
}

public native_get_user_lada6(index)
{
    return Lada[6][index];
}

public native_set_user_lada6(index, amount)
{
    Lada[6][index] = amount;
    return 0;
}

public native_get_user_lada5(index)
{
    return Lada[5][index];
}

public native_set_user_lada5(index, amount)
{
    Lada[5][index] = amount;
    return 0;
}

public native_get_user_fragkes(index)
{
    return meglevoek[132][index];
}

public native_set_user_fragkes(index, amount)
{
    meglevoek[132][index] = amount;
    return 0;
}

public native_get_user_kulcs(index)
{
    return Kulcs[index];
}

public native_set_user_kulcs(index, amount)
{
    Kulcs[index] = amount;
    return 0;
}

public native_get_user_ajandekcsomag(index)
{
    return ajandekcsomag[index];
}

public native_set_user_ajandekcsomag(index, amount)
{
    ajandekcsomag[index] = amount;
    return 0;
}

public HookSayRegMenuCommand(id)
{
    if (!g_Bejelentkezve[id])
    {
        showMenu_Main(id);
    }
    else
    {
        showMenu_Options(id);
    }
    return 1;
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
    if (1 <= Vip[id])
    {
        if (!meglevoek[133][id])
        {
            meglevoek[133][id]++;
        }
    }
    return 0;
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
    if (FailState == -2)
    {
        set_fail_state("[ *HIBA* ] NEM LEHET KAPCSOLODNI AZ ADATBAZISHOZ!");
        return 1;
    }
    if (FailState == -1)
    {
        set_fail_state("[ *HIBA* ] A LEKERDEZES MEGSZAKADT!");
        return 1;
    }
    if (Errcode)
    {
        log_amx("[ *HIBA* ] PROBLEMA A LEKERDEZESNEL! ( %s )", Error);
        return 1;
    }
    new count;
    while (SQL_MoreResults(Query))
    {
        Top[1][count] = SQL_ReadResult(Query, 13) / 100;
        SQL_ReadResult(Query, 6, TopNev[1][count], 31);
        count++;
        SQL_NextRow(Query);
    }
    return 1;
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

public top10kuldi(FailState, Handle:Query, Error[], Errcode, szData[], DataSize)
{
    if (FailState == -2)
    {
        set_fail_state("[ *HIBA* ] NEM LEHET KAPCSOLODNI AZ ADATBAZISHOZ!");
        return 1;
    }
    if (FailState == -1)
    {
        set_fail_state("[ *HIBA* ] A LEKERDEZES MEGSZAKADT!");
        return 1;
    }
    if (Errcode)
    {
        log_amx("[ *HIBA* ] PROBLEMA A LEKERDEZESNEL! ( %s )", Error);
        return 1;
    }
    new count;
    while (SQL_MoreResults(Query))
    {
        Top[1][count] = SQL_ReadResult(Query, 26);
        SQL_ReadResult(Query, 6, TopNev[1][count], 31);
        count++;
        SQL_NextRow(Query);
    }
    return 1;
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
		len += formatex(menu[len], charsmax(menu) - len, "<td>%d (%s)</td></tr>", Top[2][i], Rangok[TopRang[i]][Szint]);
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

public Kuldetes(id)
{
    static menu[3000];
    new len = formatex(menu[len], 2999 - len, "<head>") + len;
    len = formatex(menu[len], 2999 - len, "<meta charset=^"utf8^">") + len;
    len = formatex(menu[len], 2999 - len, "<meta lang=^"hu^">") + len;
    len = formatex(menu[len], 2999 - len, "</head>") + len;
    len = formatex(menu[len], 2999 - len, "<center><table border=^"1^">") + len;
    len = formatex(menu[len], 2999 - len, "<body bgcolor=#000000><table style=^"color: #00FFFF^">") + len;
    len = formatex(menu[len], 2999 - len, "<td>%s</td>", "Játékosnév") + len;
    len = formatex(menu[len], 2999 - len, "<td>%s</td>", "Küldetés") + len;
    new i;
    while (i < 15)
    {
        len = formatex(menu[len], 2999 - len, "<tr><td>%02d.  %s</td>", i + 1, TopNev[1][i]) + len;
        len = formatex(menu[len], 2999 - len, "<td>%d</td></tr>", Top[1][i]) + len;
        i++;
    }
    len = formatex(menu[len], 2999 - len, "</table></center>");
    show_motd(id, menu, "*Avatar#  TOP Küldetés");
    return 0;
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

public WeaponView(id) 
{
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

public autoSave()
{
	new players[32], pnum, id;
	get_players(players, pnum);
	
	for(new i; i<pnum; i++)
	{
		id = players[i];
		g_Aktivitas[id] = 1;
		
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

public cmdKuldi()
{
    SQL_ThreadQuery(g_SqlTuple, "top10kuldi", "SELECT * FROM rwt_sql_register_new_s5 ORDER BY QuestMVP DESC LIMIT 15");
    return PLUGIN_HANDLED;
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

public InfoHud(id)
{
    new Target = pev(id, pev_iuser1) == 4 ? pev(id, pev_iuser2) : id;

    if (is_user_alive(id))
    {
        if (g_Bejelentkezve[id])
        {
            new iMasodperc;
            new iPerc;
            new iOra;
            new nev[32];
            get_user_name(id, nev, 31);
            iMasodperc = Masodpercek[id] + get_user_time(id);
            iPerc = iMasodperc / 60;
            iOra = iPerc / 60;
            iMasodperc -= iPerc * 60;
            iPerc -= iOra * 60;
            set_hudmessage(random(255), random(255), random(255), 0.01, 0.15, 0, 6.0, 1.1, 0.0, 0.0, -1);
            show_hudmessage(id, "*Üdv %s!^n*Azonosító: %d^n*Dollár: %3.2f$^nÉrdemérem: %s^n*Játszott idő: %d óra %d perc %d mp^n*Küldetés MVP: %d^n|Következő Rangod: %s | [%d | %d]", nev, g_Id[id], Dollar[id], ErdemErmek[g_Erem[id]], iOra, iPerc, iMasodperc, g_QuestMVP[id], Rangok[Rang[id]][Szint], Oles[id], Rangok[Rang[id]][Xp]);
        }
        else
        {
            set_hudmessage(random(255), random(255), random(255), 0.01, 0.15, 0, 6.0, 1.1, 0.0, 0.0, -1);
            show_hudmessage(id, "Nyomj T betüt a bejelentkezéshez/regisztrációhoz!");
        }
    }
    else
    {
        if (g_Bejelentkezve[Target])
        {
            new iMasodperc;
            new iPerc;
            new iOra;
            iMasodperc = Masodpercek[Target] + get_user_time(Target);
            iPerc = iMasodperc / 60;
            iOra = iPerc / 60;
            iMasodperc -= iPerc * 60;
            iPerc -= iOra * 60;
            set_hudmessage(random(255), random(255), random(255), 0.01, 0.15, 0, 6.0, 1.1, 0.0, 0.0, -1);
            show_hudmessage(id, "Nézett játékos adatai: ^nDollár: %3.2f$^nSMS Pontok: %d^nJátszott idő: %d óra %d perc %d mp^nKüldetés MVP: %d^nÉrdemérem: %s", Dollar[Target], SMS[Target], iOra, iPerc, iMasodperc, g_QuestMVP[Target], ErdemErmek[g_Erem[Target]]);
        }
        set_hudmessage(random(255), random(255), random(255), 0.01, 0.15, 0, 6.0, 1.1, 0.0, 0.0, -1);
        show_hudmessage(id, "A nézett játékos nincs bejelentkezve!");
    }
    return 1;
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
    set_pev(id, pev_viewmodel2, "models/v_flashbang.mdl");
    }
    if(fgy == CSW_HEGRENADE && Gun[0][id] == 1)
    {
    set_pev(id, pev_viewmodel2, "models/v_hegrenade.mdl");
    }
    if(fgy == CSW_C4 && Gun[0][id] == 1)
    {
    set_pev(id, pev_viewmodel2, "models/v_c4.mdl");
    set_pev(id, pev_weaponmodel2, "models/p_c4.mdl");
    }
}

public Halal()
{
    new Gyilkos = read_data(1);
    new Aldozat = read_data(2);
    new Headshot = read_data(3);
    if (g_Quest[Gyilkos] == 1)
        Quest(Gyilkos);
    
    if(Gyilkos == Aldozat)
        return PLUGIN_HANDLED;
	
    Oles[Gyilkos]++;
    D_Oles[Gyilkos]++;
    while (Rangok[Rang[Gyilkos]][32] <= Oles[Gyilkos])
    {
        Rang[Gyilkos]++;
    }
    new Float:DollartKap = 0.0;
    if (Headshot)
    {
        if (Vip[Gyilkos] == 1)
        {
            DollartKap = random_float(0.09, 0.35);
        }
        else
        {
            DollartKap = random_float(0.01, 0.25);
        }
    }
    else
    {
        if (Vip[Gyilkos] == 1)
        {
            DollartKap = random_float(0.09, 0.17);
        }
        DollartKap = random_float(0.05, 0.13);
    }
    Dollar[Gyilkos] += DollartKap;
    set_dhudmessage(random(256), random(256), random(256), -1.0, 0.2, 0, 6.0, 3.0, 0.1, 1.5);
    show_dhudmessage(Gyilkos, "+ %3.2f $", DollartKap);
    if (25 < get_user_health(Gyilkos))
    {
        ColorChat(Aldozat, GREY, "^1»^4A gyilkosodnak maradt^3 %d ^4HP-ja!", get_user_health(Gyilkos));
    }
    else
    {
        ColorChat(Aldozat, BLUE, "^1»^4A gyilkosodnak maradt^3 %d ^4HP-ja!", get_user_health(Gyilkos));
    }
    LadaDropEllenor(Gyilkos);
    return 1;
}

public Quest(id)
{
    new HeadShot = read_data(3);
    new randomCaseAll = random_num(0,4);
    new name[32]; get_user_name(id, name, charsmax(name));

    if (g_QuestHead[id] == 3)
    {
        if (g_QuestWeapon[id] == 9)
        {
            g_QuestKills[1][id]++;
        }
        if (g_QuestWeapon[id] == 3 && get_user_weapon(id) == 26)
        {
            g_QuestKills[1][id]++;
        }
        if (g_QuestWeapon[id] == 2 && get_user_weapon(id) == 18)
        {
            g_QuestKills[1][id]++;
        }
        if (g_QuestWeapon[id] == 1 && get_user_weapon(id) == 22)
        {
            g_QuestKills[1][id]++;
        }
        if (g_QuestWeapon[id] && get_user_weapon(id) == 28)
        {
            g_QuestKills[1][id]++;
        }
        if (g_QuestWeapon[id] == 5 && get_user_weapon(id) == 17)
        {
            g_QuestKills[1][id]++;
        }
        if (g_QuestWeapon[id] == 6 && get_user_weapon(id) == 15)
        {
            g_QuestKills[1][id]++;
        }
        if (g_QuestWeapon[id] == 7 && get_user_weapon(id) == 3)
        {
            g_QuestKills[1][id]++;
        }
        if (g_QuestWeapon[id] == 8 && get_user_weapon(id) == 29)
        {
            g_QuestKills[1][id]++;
        }
        if (g_QuestWeapon[id] == 9 && get_user_weapon(id) == 16)
        {
            g_QuestKills[1][id]++;
        }
        if (g_QuestWeapon[id] == 10 && get_user_weapon(id) == 14)
        {
            g_QuestKills[1][id]++;
        }
    }
    if (g_QuestHead[id] == 2)
    {
        if (g_QuestWeapon[id] == 9)
        {
            g_QuestKills[1][id]++;
        }
        if (g_QuestWeapon[id] == 3 && get_user_weapon(id) == 26)
        {
            g_QuestKills[1][id]++;
        }
        if (g_QuestWeapon[id] == 2 && get_user_weapon(id) == 18)
        {
            g_QuestKills[1][id]++;
        }
        if (g_QuestWeapon[id] == 1 && get_user_weapon(id) == 22)
        {
            g_QuestKills[1][id]++;
        }
        if (g_QuestWeapon[id] && get_user_weapon(id) == 28)
        {
            g_QuestKills[1][id]++;
        }
        if (g_QuestWeapon[id] == 5 && get_user_weapon(id) == 17)
        {
            g_QuestKills[1][id]++;
        }
        if (g_QuestWeapon[id] == 6 && get_user_weapon(id) == 15)
        {
            g_QuestKills[1][id]++;
        }
        if (g_QuestWeapon[id] == 7 && get_user_weapon(id) == 3)
        {
            g_QuestKills[1][id]++;
        }
        if (g_QuestWeapon[id] == 8 && get_user_weapon(id) == 29)
        {
            g_QuestKills[1][id]++;
        }
        if (g_QuestWeapon[id] == 9 && get_user_weapon(id) == 16)
        {
            g_QuestKills[1][id]++;
        }
        if (g_QuestWeapon[id] == 10 && get_user_weapon(id) == 14)
        {
            g_QuestKills[1][id]++;
        }
    }
    if (g_QuestHead[id] == 1 && HeadShot)
    {
        if (g_QuestWeapon[id] == 9)
        {
            g_QuestKills[1][id]++;
        }
        if (g_QuestWeapon[id] == 3 && get_user_weapon(id) == 26)
        {
            g_QuestKills[1][id]++;
        }
        if (g_QuestWeapon[id] == 2 && get_user_weapon(id) == 18)
        {
            g_QuestKills[1][id]++;
        }
        if (g_QuestWeapon[id] == 1 && get_user_weapon(id) == 22)
        {
            g_QuestKills[1][id]++;
        }
        if (g_QuestWeapon[id] && get_user_weapon(id) == 28)
        {
            g_QuestKills[1][id]++;
        }
        if (g_QuestWeapon[id] == 5 && get_user_weapon(id) == 17)
        {
            g_QuestKills[1][id]++;
        }
        if (g_QuestWeapon[id] == 6 && get_user_weapon(id) == 15)
        {
            g_QuestKills[1][id]++;
        }
        if (g_QuestWeapon[id] == 7 && get_user_weapon(id) == 3)
        {
            g_QuestKills[1][id]++;
        }
        if (g_QuestWeapon[id] == 8 && get_user_weapon(id) == 29)
        {
            g_QuestKills[1][id]++;
        }
        if (g_QuestWeapon[id] == 9 && get_user_weapon(id) == 16)
        {
            g_QuestKills[1][id]++;
        }
        if (g_QuestWeapon[id] == 10 && get_user_weapon(id) == 14)
        {
            g_QuestKills[1][id]++;
        }
    }
    if (!g_QuestHead[id])
    {
        if (g_QuestWeapon[id] == 9)
        {
            g_QuestKills[1][id]++;
        }
        if (g_QuestWeapon[id] == 3 && get_user_weapon(id) == 26)
        {
            g_QuestKills[1][id]++;
        }
        if (g_QuestWeapon[id] == 2 && get_user_weapon(id) == 18)
        {
            g_QuestKills[1][id]++;
        }
        if (g_QuestWeapon[id] == 1 && get_user_weapon(id) == 22)
        {
            g_QuestKills[1][id]++;
        }
        if (g_QuestWeapon[id] && get_user_weapon(id) == 28)
        {
            g_QuestKills[1][id]++;
        }
        if (g_QuestWeapon[id] == 5 && get_user_weapon(id) == 17)
        {
            g_QuestKills[1][id]++;
        }
        if (g_QuestWeapon[id] == 6 && get_user_weapon(id) == 15)
        {
            g_QuestKills[1][id]++;
        }
        if (g_QuestWeapon[id] == 7 && get_user_weapon(id) == 3)
        {
            g_QuestKills[1][id]++;
        }
        if (g_QuestWeapon[id] == 8 && get_user_weapon(id) == 29)
        {
            g_QuestKills[1][id]++;
        }
        if (g_QuestWeapon[id] == 9 && get_user_weapon(id) == 16)
        {
            g_QuestKills[1][id]++;
        }
        if (g_QuestWeapon[id] == 10 && get_user_weapon(id) == 14)
        {
            g_QuestKills[1][id]++;
        }
    }
    if (g_QuestKills[1][id] >= g_QuestKills[0][id])
    {
        Dollar[id] += float(g_Jutalom[0][id]);
        Lada[randomCaseAll][id] += g_Jutalom[1][id];
        Kulcs[id] += g_Jutalom[2][id];
        Lada[randomCaseAll][id] += g_Jutalom[3][id];
        g_QuestMVP[id]++;
        g_QuestKills[1][id] = 0;
        g_QuestWeapon[id] = 0;
        g_Quest[id] = 0;
        ColorChat(id, Color:2, "%s ^1A küldetésre kapott jutalmakat megkaptad.", C_Prefix);
        ColorChat(0, Color:2, "%s  ^3%s^1 ^4Befejezte a kiszabott küldetést,^1a ^3jutalmakat megkapta.", C_Prefix, name);
    }
    if (ErdemErmek[g_Erem[id]][32] <= g_QuestMVP[id])
    {
        g_Erem[id]++;
    }
    return 0;
}

public LadaDropEllenor(id)
{
    new Float:RandomSzam = random_float(0.01, 100.000);

    if (RandomSzam <= 15.5 && RandomSzam > 13.5)
    {
        Lada[0][id]++;
        ColorChat(id, GREY, "%s ^3Találtál egy %s nevü ládát.", C_Prefix, l_Nevek[0]);
    }
    else
    {
        if (RandomSzam <= 12.5 && RandomSzam > 11.82)
        {
            Lada[1][id]++;
            ColorChat(id, GREY, "%s ^3Kaptál egy ^1%s^3itemet.", C_Prefix, l_Nevek[1]);
        }
        if (RandomSzam <= 10.3 && RandomSzam > 9.8)
        {
            Lada[2][id]++;
            D_Oles[id] = 0;
            ColorChat(id, GREY, "%s ^3Kaptál egy ^1%s^3itemet.", C_Prefix, l_Nevek[2]);
        }
        if (RandomSzam <= 9.5 && RandomSzam > 9.5)
        {
            Lada[3][id]++;
            D_Oles[id] = 0;
            ColorChat(id, GREY, "%s ^3Kaptál egy ^1%s ^3itemet.", C_Prefix, l_Nevek[3]);
        }
        if (RandomSzam <= 8.5 && RandomSzam > 5.6)
        {
            Lada[4][id]++;
            D_Oles[id] = 0;
            ColorChat(id, GREY, "%s ^3Kaptál egy ^1%s ^3itemet.", C_Prefix, l_Nevek[4]);
        }
        if (RandomSzam <= 3.6 && RandomSzam > 2.5)
        {
            Lada[5][id]++;
            D_Oles[id] = 0;
            ColorChat(id, Color:2, "%s ^4Kaptál egy ^1%s ^3itemet.", C_Prefix, l_Nevek[5]);
        }
        if (RandomSzam <= 0.7)
        {
            Lada[6][id]++;
            D_Oles[id] = 0;
            ColorChat(id, BLUE, "%s ^4Kaptál egy ^1%s ^3itemet.", C_Prefix, l_Nevek[6]);
        }
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
    new len = formatex(menu[len], 254 - len, "\y[*Avatar#] \rMagyar Fun Reg rendszer^n") + len;
    len = formatex(menu[len], 254 - len, "\r1. \wFelhasználónév:\y %s^n", g_Felhasznalonev[id]) + len;
    len = formatex(menu[len], 254 - len, "\r2. \wJelszó:\y %s^n^n", g_Jelszo[id]) + len;
    if (g_RegisztracioVagyBejelentkezes[id] == 1)
    {
        len = formatex(menu[len], 254 - len, "\r3. \yRegisztráció^n^n^n^n^n^n^n^n") + len;
    }
    else
    {
        len = formatex(menu[len], 254 - len, "\r3. \yBejelentkezés^n^n^n^n^n^n^n^n") + len;
    }
    len = formatex(menu[len], 254 - len, "\r0. \wVissza a RegMenübe") + len;
    
    set_pdata_int(id, 205, 0);
    show_menu(id, MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_0, menu, -1, "Reg-Log Menu");
    return 0;
}

public menu_reglog(id, key)
{
    if (!is_user_connected(id) || g_Bejelentkezve[id])
    {
        return 1;
    }
    switch (key)
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
        case 2:
        {
            cmdRegisztracioBejelentkezes(id);
        }
        case 9:
        {
            showMenu_Main(id);
        }
        default:
        {
        }
    }
    return 1;
}

public showMenu_Main(id)
{
    new Text[1337];
    formatex(Text, 125, "\r[*Avatar#] \wMagyar Fun Reg rendszer\y -/\wKijelentkezve");
    new menuLoginCreate = menu_create(Text, "createMenu_Main");
    
    formatex(Text, 125, "\yRegisztráció");
    menu_additem(menuLoginCreate, Text, "1");
    formatex(Text, 125, "\yBejelentkezés");
    menu_additem(menuLoginCreate, Text, "2");
    formatex(Text, 125, "\rElfelejtettem a jelszavam!");
    menu_additem(menuLoginCreate, Text, "3");

    formatex(Text, 1336, "BACK");
    menu_setprop(menuLoginCreate, MPROP_BACKNAME, Text);
    formatex(Text, 1336, "NEXT");
    menu_setprop(menuLoginCreate, MPROP_NEXTNAME, Text);
    formatex(Text, 1336, "EXIT");
    menu_setprop(menuLoginCreate, MPROP_EXITNAME, Text);

    menu_setprop(menuLoginCreate, MPROP_EXIT, MEXIT_ALL);
    menu_display(id, menuLoginCreate, 0);
}

public showMenu_Options(id)
{
    new Text[255];
    formatex(Text, 255, "\y[*Avatar#] \rMagyar Fun\y -/\wBejelentkezve");
    new menuLoginCreate = menu_create(Text, "createMenu_Options");

    formatex(Text, 255, "\wE-Mail:\y %s^n", g_Email[id]);
    menu_additem(menuLoginCreate, Text, "1");

    if (biztonsagikerdes[id] == 1)
    {
        menu_additem(menuLoginCreate, "\wBiztonsági kérdés:\y Van", "2");
    }
    else if (!biztonsagikerdes[id])
    {
        menu_additem(menuLoginCreate, "\wBiztonsági kérdés:\r Nincs", "2");
    }

    formatex(Text, 255, "\wÚj jelszó:\y %s", g_JelszoUj[id]);
    menu_additem(menuLoginCreate, Text, "3");
    formatex(Text, 255, "\wJelenlegi jelszó:\y %s", g_JelszoRegi[id]);
    menu_additem(menuLoginCreate, Text, "4");
    formatex(Text, 255, "\wJelszó váltás^n");
    menu_additem(menuLoginCreate, Text, "5");

    menu_setprop(menuLoginCreate, MPROP_EXIT, MEXIT_ALL);
    menu_setprop(menuLoginCreate, MPROP_BACKNAME, "BACK");
    menu_setprop(menuLoginCreate, MPROP_NEXTNAME, "NEXT");
    menu_setprop(menuLoginCreate, MPROP_EXITNAME, "EXIT");
    menu_setprop(menuLoginCreate, MPROP_PERPAGE, 7);
    menu_display(id, menuLoginCreate, 0);
}

public sql_update_account(id)
{
    static Query[10048];
    new len;

    new b[191];
    new c[191];
    new client_name[33];
    new steamid[32];
    new player_ip[23];
    get_user_ip(id, player_ip, 22, 1);
    get_user_authid(id, steamid, 31);
    get_user_name(id, client_name, 32);

    format(b, 190, "%s", g_Jelszo[id]);
    format(c, 190, "%s", client_name);
    
    replace_all(b, 190, "\", "\\");
    replace_all(b, 190, "'", "\'");
    replace_all(c, 190, "\", "\\");
    replace_all(c, 190, "'", "\'"); 

    len = format(Query[len], 10048, "UPDATE rwt_sql_register_new_s5 SET ") + len;
    len = format(Query[len], 10048 - len, "Jelszo = '%s', ", b) + len;
    len = format(Query[len], 10048 - len, "Jatekosnev = '%s', ", c) + len;
    len = format(Query[len], 10048 - len, "Email = '%s', ", g_Email[id]) + len;
    len = format(Query[len], 10048 - len, "BiztKerdes = '%s', ", s_biztonsagikerdes[id]) + len;
    len = format(Query[len], 10048 - len, "BiztValasz = '%s', ", s_valasz[id]) + len;
    len = format(Query[len], 10048 - len, "Kulcs = '%d', ", Kulcs[id]) + len;
    len = format(Query[len], 10048 - len, "Szint = '%d', ", Rang[id]) + len;
    len = format(Query[len], 10048 - len, "AutoLogin = '%d', ", AutoLogin) + len;
    len = format(Query[len], 10048 - len,"Dollars = '%d', ", floatround(Dollar[id]*100)) + len;
    len = format(Query[len], 10048 - len, "SMS = '%d', ", SMS[id]) + len;
    len = format(Query[len], 10048 - len, "Hud = '%d', ", Hud[id]) + len;
    len = format(Query[len], 10048 - len, "Vip = '%d', ", Vip[id]) + len;
    len = format(Query[len], 10048 - len, "Masodpercek = '%d', ", Masodpercek[id] + get_user_time(id)) + len;
    len = format(Query[len], 10048 - len, "DropOles = '%d', ", D_Oles[id]) + len;
    len = format(Query[len], 10048 - len, "Oles = '%d', ", Oles[id]) + len;
    len = format(Query[len], 10048 - len, "biztonsagikerdes = '%d', ", biztonsagikerdes[id]) + len;
    len = format(Query[len], 10048 - len, "QuestH = '%d', ", g_Quest[id]) + len;
    len = format(Query[len], 10048 - len, "QuestNeed = '%d', ", g_QuestKills[0][id]) + len;
    len = format(Query[len], 10048 - len, "QuestHave = '%d', ", g_QuestKills[1][id]) + len;
    len = format(Query[len], 10048 - len, "QuestWeap = '%d', ", g_QuestWeapon[id]) + len;
    len = format(Query[len], 10048 - len, "QuestHead = '%d', ", g_QuestHead[id]) + len;
    len = format(Query[len], 10048 - len, "QuestMVP = '%d', ", g_QuestMVP[id]) + len;
    len = format(Query[len], 10048 - len, "Jut1 = '%d', ", g_Jutalom[0][id]) + len;
    len = format(Query[len], 10048 - len, "Jut2 = '%d', ", g_Jutalom[1][id]) + len;
    len = format(Query[len], 10048 - len, "Jut3 = '%d', ", g_Jutalom[2][id]) + len;
    len = format(Query[len], 10048 - len, "kivak = '%d', ", kivalasztott[id]) + len;
    len = format(Query[len], 10048 - len, "kivm4 = '%d', ", kivalasztott[id][1]) + len;
    len = format(Query[len], 10048 - len, "kivawp = '%d', ", kivalasztott[id][2]) + len;
    len = format(Query[len], 10048 - len, "kivfamas = '%d', ", kivalasztott[id][3]) + len;
    len = format(Query[len], 10048 - len, "kivmp5 = '%d', ", kivalasztott[id][4]) + len;
    len = format(Query[len], 10048 - len, "kivgalil = '%d', ", kivalasztott[id][5]) + len;
    len = format(Query[len], 10048 - len, "kivscout = '%d', ", kivalasztott[id][6]) + len;
    len = format(Query[len], 10048 - len, "kivdeagle = '%d', ", kivalasztott[id][7]) + len;
    len = format(Query[len], 10048 - len, "kivusp = '%d', ", kivalasztott[id][8]) + len;
    len = format(Query[len], 10048 - len, "kivglock = '%d', ", kivalasztott[id][9]) + len;
    len = format(Query[len], 10048 - len, "kivknife = '%d', ", kivalasztott[id][10]) + len;
    len = format(Query[len], 10048 - len, "s_addvariable = '%d', ", s_addvariable[id]) + len;
    len = format(Query[len], 10048 - len, "porgetesido = '%d', ", g_iTime[id]) + len;
    len = format(Query[len], 10048 - len, "viptime = '%d', ", g_iVipTime[id]) + len;
    len = format(Query[len], 10048 - len, "ErdemErem = '%i', ", g_Erem[id]) + len;
    len = format(Query[len], 10048 - len, "Premium = '%i', ", g_Premium[id]) + len;
    len = format(Query[len], 10048 - len, "vanprefix = ^"%i^", ", VanPrefix[id]) + len;
    len = format(Query[len], 10048 - len, "prefixneve = ^"%s^", ", Ct_Prefix[id]) + len;
    if (Vip[id] == 1)
    {
        len = format(Query[len], 10048 - len, "voltvip = '%d', ", g_iVipNum[id]) + len;
    }
    len = format(Query[len], 10048 - len, "steamid = '%s', ", steamid) + len;
    len = format(Query[len], 10048 - len, "ipcim = '%s', ", player_ip) + len;
    len = format(Query[len], 10048 - len, "h_lada = '%d', ", h_lada[id]) + len;
    len = format(Query[len], 10048 - len, "ajandekcsomag = '%d', ", ajandekcsomag[id]) + len;
    len = format(Query[len], 10048 - len, "vipkupon = '%d', ", vipkupon[id]) + len;
    len = format(Query[len], 10048 - len, "havazas = '%d', ", havazas) + len;
	
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

    for(new i=0; i < 7; i++)
    {
        len += formatex(Query[len], charsmax(Query)-len, "L%d = ^"%i^", ", i, Lada[i][id]);
    }


    len += format(Query[len], 10048-len,"Aktivitas = '%d' ", g_Aktivitas[id]);
    len += format(Query[len], 10048-len,"WHERE Id = '%d'", g_Id[id]);

    SQL_ThreadQuery(g_SqlTuple,"sql_update_account_thread", Query);
}

public createMenu_Options(id, menuLoginCreate, item)
{
    new data[6];
    new iName[64];
    new access;
    new callback;
    menu_item_getinfo(menuLoginCreate, item, access, data, 5, iName, 63, callback);
    new key = str_to_num(data);
    if (!g_Bejelentkezve[id])
    {
        return 1;
    }
    switch (key)
    {
        case 1:
        {
            client_cmd(id, "messagemode E-mail");
            showMenu_Options(id);
        }
        case 2:
        {
            if (biztonsagikerdes[id] == 1)
            {
                ColorChat(id, GREY, "%s ^3Neked van biztonsági kérdésed!", C_Prefix);
            }
            else
            {
                if (!biztonsagikerdes[id])
                {
                    client_cmd(id, "messagemode BIZTONSAGIKERDES");
                }
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
            if (g_JelszoRegi[id][0])
            {
                if (equal(g_JelszoRegi[id], g_Jelszo[id]))
                {
                    if (g_JelszoUj[id][0])
                    {
                        if (16 < strlen(g_JelszoUj[id]))
                        {
                            ColorChat(id, GREY, "^1 Az új jelszó nem lehet hosszabb, mint 16 karakter.");
                            g_JelszoUj[id][0] = 0;
                            showMenu_Options(id);
                            return 1;
                        }
                        if (4 > strlen(g_JelszoUj[id]))
                        {
                            ColorChat(id, GREY, "^1 Az új Jelszó nem lehet rovidebb, mint 4 karakter.");
                            g_JelszoUj[id][0] = 0;
                            showMenu_Options(id);
                            return 1;
                        }
                        new b[191];
                        format(b, 190, "%s", g_Jelszo[id]);
                        replace_all(b, charsmax(b), "\", "\\");
                        replace_all(b, charsmax(b), "'", "\'");
                        
                        ColorChat(id, GREY, "^1 Sikeres jelszó váltás! Új Jelszavad:^3 %s", g_Jelszo[id]);
                        sql_update_account(id);
                        g_JelszoUj[id][0] = 0;
                        g_JelszoRegi[id][0] = 0;
                    }
                    else
                    {
                        ColorChat(id, GREY, "^1 Nem adtál meg új jelszót.");
                        showMenu_Options(id);
                    }
                }
                else
                {
                    ColorChat(id, GREY, "Hibás jelenlegi jelszó.");
                    showMenu_Options(id);
                }
            }
            else
            {
                ColorChat(id, GREY, "^1 Nem adtad meg a jelenlegi jelszót");
                showMenu_Options(id);
            }
        }
        default:
        {
        }
    }
    return 1;
}

public createMenu_Main(id, menuLoginCreate, item)
{
    new data[6];
    new iName[64];
    new access;
    new callback;
    menu_item_getinfo(menuLoginCreate, item, access, data, 5, iName, 63, callback);
    new key = str_to_num(data);
    switch (key)
    {
        case 1:
        {
            if (!g_Bejelentkezve[id])
            {
                g_RegisztracioVagyBejelentkezes[id] = 1;
                showMenu_RegLog(id);
            }
            else
            {
                ColorChat(id, GREY, "Már be vagy jelentkezve.");
                showMenu_Main(id);
            }
        }
        case 2:
        {
            if (!g_Bejelentkezve[id])
            {
                g_RegisztracioVagyBejelentkezes[id] = 2;
                showMenu_RegLog(id);
            }
            else
            {
                ColorChat(id, GREY, "Már be vagy jelentkezve.");
                showMenu_Main(id);
            }
        }
        case 3:
        {
            ColorChat(id, GREY, "%s ^3Add meg a felhasználóneved!", C_Prefix);
            client_cmd(id, "messagemode USERNAME2");
        }
        default:
        {
        }
    }
    return 1;
}

public cmdFelhasznalonev(id)
{
    if (g_Bejelentkezve[id])
    {
        return 1;
    }
    g_Felhasznalonev[id][0] = 0;
    read_args(g_Felhasznalonev[id], 99);
    remove_quotes(g_Felhasznalonev[id]);
    showMenu_RegLog(id);
    return 1;
}

public cmdFelhasznalonev2(id)
{
    if (g_Bejelentkezve[id])
    {
        return 1;
    }
    g_Felhasznalonev[id][0] = 0;
    read_args(g_Felhasznalonev[id], 99);
    remove_quotes(g_Felhasznalonev[id]);
    usernamecheckforquestion(id);
    return 1;
}

public cmdFelhasznalonev3(id)
{
    if (!g_Bejelentkezve[id])
    {
        return 1;
    }
    g_FHVIP[id][0] = 0;
    read_args(g_FHVIP[id], 99);
    remove_quotes(g_FHVIP[id]);
    if (viptorol == 1)
    {
        sql_delete_vip(id);
    }
    else
    {
        sql_update_vip(id);
    }
    return 1;
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
        ColorChat(id, BLUE, "%s ^3Számodra ez a funkció nem elérhető!", C_Prefix);
    }
    return 0;
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
        ColorChat(id, BLUE, "%s ^3Számodra ez a funkció nem elérhető!", C_Prefix);
    }
    return 0;
}

public helperkick(id)
{
    if(get_user_flags(id) & ADMIN_CHAT)
    {
        addolasikulcs = 912;
        PlayerChoose2(id);
    }
    return 0;
}

public cmdsinfok(id)
{
    if(get_user_flags(id) & ADMIN_CHAT)
    {
        show_motd(id, "addons/amxmodx/configs/sinfok.txt", "Szabályzat");
    }
    return 0;
}

public cmdPauseAccount(id)
{
    if (!g_Bejelentkezve[id])
    {
        return 1;
    }
    g_Indok[id][0] = 0;
    read_args(g_Indok[id], 99);
    remove_quotes(g_Indok[id]);
    sqlfelfuggesztfiok(id);
    return 1;
}

public usernamecheckforquestion(id)
{
    new szQuery[2048];
    new len;
    new a[191];
    format(a, 190, "%s", g_Felhasznalonev[id]);

    replace_all(a, 190, "\", "\\");
    replace_all(a, 190, "'", "\'");

    len = format(szQuery[len], 2048, "SELECT * FROM rwt_sql_register_new_s5 ") + len;
    len = format(szQuery[len], 2048 - len, "WHERE Felhasznalonev = '%s'", a) + len;
    new szData[2];
    szData[0] = id;
    szData[1] = get_user_userid(id);
    SQL_ThreadQuery(g_SqlTuple, "sql_biztonsagikerdes_check", szQuery, szData, 2);
    return 0;
}

public sql_biztonsagikerdes_check(FailState, Handle:Query, Error[], Errcode, szData[], DataSize)
{
    if (FailState == -2)
    {
        set_fail_state("[ *HIBA* ] NEM LEHET KAPCSOLODNI AZ ADATBAZISHOZ!");
        return 0;
    }
    if (FailState == -1)
    {
        set_fail_state("[ *HIBA* ] A LEKERDEZES MEGSZAKADT!");
        return 0;
    }
    if (Errcode)
    {
        log_amx("[ *HIBA* ] PROBLEMA A LEKERDEZESNEL! ( %s )", Error);
        return 0;
    }
    new id = szData[0];
    if (get_user_userid(id) != szData[1])
    {
        return 0;
    }
    sql_account_loadonlyquestion(id);
    return 0;
}

public sql_account_loadonlyquestion(id)
{
    static Query[10048];
    new len;
    new a[191];
    format(a, 190, "%s", g_Felhasznalonev[id]);

    replace_all(a, 190, "\", "\\");
    replace_all(a, 190, "'", "\'");

    len = format(Query[len], 10048, "SELECT * FROM rwt_sql_register_new_s5 ") + len;
    len = format(Query[len], 10048 - len, "WHERE Felhasznalonev = '%s'", a) + len;
    new szData[2];
    szData[0] = id;
    szData[1] = get_user_userid(id);
    SQL_ThreadQuery(g_SqlTuple, "sql_account_load_onlyquestion", Query, szData, 2);
    return 0;
}

public sql_account_load_onlyquestion(FailState, Handle:Query, Error[], Errcode, szData[], DataSize)
{
    if (FailState == -2 || FailState == -1)
    {
        log_amx("%s", Error);
        return 0;
    }

    new id = szData[0];
    if (get_user_userid(id) != szData[1])
    {
        return 0;
    }

    SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "BiztKerdes"), s_biztonsagikerdes[id], 99);
    SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "BiztValasz"), s_valasz[id], 99);
    SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Jelszo"), s_temporarypass[id], 99);
    ColorChat(id, GREY, "%s ^3%s", C_Prefix, s_biztonsagikerdes[id]);
    ColorChat(id, GREY, "%s ^3%s", C_Prefix, s_biztonsagikerdes[id]);
    ColorChat(id, GREY, "%s ^3Írd be! A radarnál látod mit írsz!", C_Prefix);
    client_cmd(id, "messagemode VALASZ");
    return 0;
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
    if (!g_Bejelentkezve[id])
    {
        return 1;
    }
    g_JelszoUj[id][0] = 0;
    read_args(g_JelszoUj[id], 99);
    remove_quotes(g_JelszoUj[id]);
    showMenu_Options(id);
    return 1;
}

public cmdskickIndok(id)
{
    if(get_user_flags(id) & ADMIN_CHAT)
    {
        g_Indok[id][0] = 0;
        read_args(g_Indok[id], 99);
        remove_quotes(g_Indok[id]);
        new uID = get_user_userid(TempID);
        new sz_sname[33];
        new sz_victimname[33];
        get_user_name(id, sz_sname, 32);
        get_user_name(TempID, sz_victimname, 32);
        server_cmd("banid 1 #%d", uID);
        client_cmd(TempID, "echo ^"[*Avatar#] Ki lettél rúgva! Indok: %s Segítő: %s^"; disconnect", g_Indok[id], sz_sname);
        ColorChat(0, BLUE, "%s %s ^1Ki lett rúgva!^3 ||^1Indok:^4 %s ^3||^1Segítő:^4 %s", C_Prefix, sz_victimname, g_Indok[id], sz_sname);
    }
    return 1;
}

public cmdJelszoRegi(id)
{
    if (!g_Bejelentkezve[id])
    {
        return 1;
    }
    g_JelszoRegi[id][0] = 0;
    read_args(g_JelszoRegi[id], 99);
    remove_quotes(g_JelszoRegi[id]);
    showMenu_Options(id);
    return 1;
}

public cmdJelszo(id)
{
    if (g_Bejelentkezve[id] == true)
    {
        return 1;
    }
    g_Jelszo[id][0] = 0;
    read_args(g_Jelszo[id], 99);
    remove_quotes(g_Jelszo[id]);
    showMenu_RegLog(id);
    return 1;
}

public biztonsagikerdes_mess(id)
{
    if (!g_Bejelentkezve[id])
    {
        return 1;
    }
    s_biztonsagikerdes[id][0] = 0;
    read_args(s_biztonsagikerdes[id], 99);
    remove_quotes(s_biztonsagikerdes[id]);
    client_cmd(id, "messagemode VALASZ_A_KERDESRE");
    ColorChat(id, GREY, "%s ^3Írd meg rá a választ!", C_Prefix);
    return 1;
}

public valasz_megadas(id)
{
    if (!g_Bejelentkezve[id])
    {
        return 1;
    }
    s_valasz[id][0] = 0;
    read_args(s_valasz[id], 99);
    remove_quotes(s_valasz[id]);
    ColorChat(id, GREY, "%s ^3Sikeres művelet!", C_Prefix);
    biztonsagikerdes[id] = 1;
    return 1;
}

public cmdRegisztracioBejelentkezes(id)
{
    if (g_Bejelentkezve[id] == true)
    {
        return 1;
    }
    if (16 < strlen(g_Jelszo[id]))
    {
        ColorChat(id, GREY, "^1 A Jelszó nem lehet hosszabb, mint 16 karakter.");
        g_Jelszo[id][0] = 0;
        showMenu_RegLog(id);
        return 1;
    }
    if (4 > strlen(g_Jelszo[id]))
    {
        ColorChat(id, GREY, "A Jelszó nem lehet rovidebb, mint 4 karakter.");
        g_Jelszo[id][0] = 0;
        showMenu_RegLog(id);
        return 1;
    }
    switch (g_RegisztracioVagyBejelentkezes[id])
    {
        case 1:
        {
            if (g_Folyamatban[id])
            {
                showMenu_RegLog(id);
            }
            else
            {
                ColorChat(id, GREY, "^1 Regisztráció folyamatban...");
                sql_account_check(id);
                showMenu_RegLog(id);
                g_Folyamatban[id] = 1;
            }
        }
        case 2:
        {
            if (g_Folyamatban[id])
            {
                showMenu_RegLog(id);
            }
            else
            {
                ColorChat(id, GREY, "^1 Bejelentkezés folyamatban...");
                sql_account_check(id);
                showMenu_RegLog(id);
                g_Folyamatban[id] = 1;
            }
        }
        default:
        {
        }
    }
    return 0;
}

public sql_tuple_create()
{
    g_SqlTuple = SQL_MakeDbTuple(s_HOSZT, s_FELHASZNALO, s_JELSZO, s_ADATBAZIS);
    sql_active_check();
}

public sql_table_create_thread(FailState, Handle:Query, Error[], Errcode, Data[], DataSize)
{
    if (FailState == -2)
    {
        return set_fail_state("[ *HIBA* ] NEM LEHET KAPCSOLODNI AZ ADATBAZISHOZ!");
    }
    if (FailState == -1)
    {
        return set_fail_state("[ *HIBA* ] A LEKERDEZES MEGSZAKADT!");
    }
    if (Errcode)
    {
        return log_amx("[ *HIBA* ] PROBLEMA A LEKERDEZESNEL! ( %s )", Error);
    }
    return 0;
}

public sql_active_check()
{
	SQL_ThreadQuery(g_SqlTuple,"sql_active_check_thread", "UPDATE rwt_sql_register_new_s5 SET Aktivitas = '0' WHERE Aktivitas = '1'");
}

public sql_active_check_thread(FailState, Handle:Query, Error[], Errcode, Data[], DataSize)
{
    if (FailState == -2)
    {
        return set_fail_state("[ *HIBA* ] NEM LEHET KAPCSOLODNI AZ ADATBAZISHOZ!");
    }
    if (FailState == -1)
    {
        return set_fail_state("[ *HIBA* ] A LEKERDEZES MEGSZAKADT!");
    }
    if (Errcode)
    {
        return log_amx("[ *HIBA* ] PROBLEMA A LEKERDEZESNEL! ( %s )", Error);
    }
    return 0;
}

public sql_account_check(id)
{
    new szQuery[2048];
    new len;
    new a[191];
    format(a, 190, "%s", g_Felhasznalonev[id]);
    replace_all(a, 190, "\", "\\");
    replace_all(a, 190, "'", "\'");
    len = format(szQuery[len], 2048 - len, "SELECT * FROM rwt_sql_register_new_s5 WHERE Felhasznalonev = '%s'", a) + len;
    new szData[2];
    szData[0] = id;
    szData[1] = get_user_userid(id);
    SQL_ThreadQuery(g_SqlTuple, "sql_account_check_thread", szQuery, szData, 2);
    return 0;
}

public sql_account_check_thread(FailState, Handle:Query, Error[], Errcode, szData[], DataSize)
{
    if (FailState == -2)
    {
        set_fail_state("[ *HIBA* ] NEM LEHET KAPCSOLODNI AZ ADATBAZISHOZ!");
        return 0;
    }
    if (FailState == -1)
    {
        set_fail_state("[ *HIBA* ] A LEKERDEZES MEGSZAKADT!");
        return 0;
    }
    if (Errcode)
    {
        log_amx("[ *HIBA* ] PROBLEMA A LEKERDEZESNEL! ( %s )", Error);
        return 0;
    }
    new id = szData[0];
    if (get_user_userid(id) != szData[1])
    {
        return 0;
    }
    new iRowsFound = SQL_NumResults(Query);
    if (g_RegisztracioVagyBejelentkezes[id] == 1)
    {
        if (0 < iRowsFound)
        {
            ColorChat(id, GREY, "^1 Ez a Felhasználónév már Regisztrálva van.");
            g_Folyamatban[id] = 0;
            showMenu_RegLog(id);
        }
        else
        {
            sql_account_create(id);
        }
    }
    else
    {
        if (g_RegisztracioVagyBejelentkezes[id] == 2)
        {
            if (iRowsFound)
            {
                sql_account_checkpause(id);
            }
            ColorChat(id, GREY, "^1 Hibás felhasználónév vagy jelszó!");
            g_Folyamatban[id] = 0;
            showMenu_RegLog(id);
        }
    }
    return 0;
}

public sql_account_checkpause(id)
{
    new szQuery[2048];
    new len;
    new a[191];
    format(a, 190, "%s", g_Felhasznalonev[id]);
    replace_all(a, 190, "\", "\\");
    replace_all(a, 190, "'", "\'");
    len = format(szQuery[len], 2048 - len, "SELECT AccountPauseReason,AccountPauseAdmin FROM rwt_sql_register_new_s5 WHERE Felhasznalonev = '%s' AND AccountPause = '1'", a) + len;
    new szData[2];
    szData[0] = id;
    szData[1] = get_user_userid(id);
    SQL_ThreadQuery(g_SqlTuple, "sql_account_checkpause_thread", szQuery, szData, 2);
    return 0;
}

public sql_account_checkpause_thread(FailState, Handle:Query, Error[], Errcode, szData[], DataSize)
{
    if (FailState == -2)
    {
        set_fail_state("[ *HIBA* ] NEM LEHET KAPCSOLODNI AZ ADATBAZISHOZ!");
        return 0;
    }
    if (FailState == -1)
    {
        set_fail_state("[ *HIBA* ] A LEKERDEZES MEGSZAKADT!");
        return 0;
    }
    if (Errcode)
    {
        log_amx("[ *HIBA* ] PROBLEMA A LEKERDEZESNEL! ( %s )", Error);
        return 0;
    }
    new id = szData[0];
    if (get_user_userid(id) != szData[1])
    {
        return 0;
    }
    new iRowsFound = SQL_NumResults(Query);
    if (0 < iRowsFound)
    {
        SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "AccountPauseReason"), g_Indok[id], 99);
        SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "AccountPauseAdmin"), adminname[id], 99);
        ColorChat(id, BLUE, "%s ^3Ez a fiók fel lett függesztve!^1 ||^3Indok:^4 %s ^1||^3Admin:^4 %s", C_Prefix, g_Indok[id], adminname[id]);
    }
    else
    {
        sql_account_load(id);
    }
    return 0;
}

public sql_account_create(id)
{
    new szQuery[2048];
    new len;
    new a[191];
    new b[191];
    format(a, 190, "%s", g_Felhasznalonev[id]);
    format(b, 190, "%s", g_Jelszo[id]);
    replace_all(a, 190, "\", "\\");
    replace_all(a, 190, "'", "\'");
    replace_all(b, 190, "\", "\\");
    replace_all(b, 190, "'", "\'");
    len = format(szQuery[len], 2048, "INSERT INTO rwt_sql_register_new_s5 ") + len;
    len = format(szQuery[len], 2048 - len, "(Felhasznalonev,Jelszo,kivak,kivm4,kivawp,kivfamas,kivmp5,kivgalil,kivscout,kivdeagle,kivusp,kivglock,kivknife,Gun0,Gun1,Gun2,Gun3,Gun4,Gun5,Gun6,Gun7,Gun8,Gun9,Gun10,Gun11,Hud,ult_hang,havazas) VALUES('%s','%s','121','122','123','124','125','126','127','128','129','130','131','1','1','1','1','1','1','1','1','1','1','1','1','1','1','0')", a, b) + len;
    new szData[2];
    szData[0] = id;
    szData[1] = get_user_userid(id);
    SQL_ThreadQuery(g_SqlTuple, "sql_account_create_thread", szQuery, szData, 2);
    return 0;
}

public sql_account_create_thread(FailState, Handle:Query, Error[], Errcode, szData[], DataSize)
{
    if (FailState == -2)
    {
        set_fail_state("[ *HIBA* ] NEM LEHET KAPCSOLODNI AZ ADATBAZISHOZ!");
        return 0;
    }
    if (FailState == -1)
    {
        set_fail_state("[ *HIBA* ] A LEKERDEZES MEGSZAKADT!");
        return 0;
    }
    if (Errcode)
    {
        log_amx("[ *HIBA* ] PROBLEMA A LEKERDEZESNEL! ( %s )", Error);
        return 0;
    }
    new id = szData[0];
    if (get_user_userid(id) != szData[1])
    {
        return 0;
    }
    ColorChat(id, GREY, "^1 Sikeres regisztráció, lépj be!");
    ColorChat(id, GREY, "^1 Felhasználóneved:^3 %s^1 | Jelszavad:^3 %s", g_Felhasznalonev[id], g_Jelszo[id]);
    g_Folyamatban[id] = 0;
    g_RegisztracioVagyBejelentkezes[id] = 2;
    showMenu_RegLog(id);
    return 0;
}

public sql_account_load(id)
{
    static Query[10048];
    new len;
    new a[191];
    format(a, 190, "%s", g_Felhasznalonev[id]);
    replace_all(a, 190, "\", "\\");
    replace_all(a, 190, "'", "\'");
    len = format(Query[len], 10048, "SELECT * FROM rwt_sql_register_new_s5 ") + len;
    len = format(Query[len], 10048 - len, "WHERE Felhasznalonev = '%s'", a) + len;
    new szData[2];
    szData[0] = id;
    szData[1] = get_user_userid(id);
    SQL_ThreadQuery(g_SqlTuple, "sql_account_load_thread", Query, szData, 2);
    return 0;
}

public sql_account_load_thread(FailState, Handle:Query, Error[], Errcode, szData[], DataSize)
{
    if (FailState == -2 || FailState == -1)
    {
        log_amx("%s", Error);
        return 0;
    }
    new id = szData[0];
    if (get_user_userid(id) != szData[1])
    {
        return 0;
    }
    new szSqlPassword[100];
    SQL_ReadResult(Query, 2, szSqlPassword, 99);
    if (equal(g_Jelszo[id], szSqlPassword))
    {
        g_Aktivitas[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Aktivitas"));
        if (0 < g_Aktivitas[id])
        {
            ColorChat(id, GREY, "^1 Ezzel a Felhasználónével már valaki bejelentkezett!");
            showMenu_RegLog(id);
            return 0;
        }
        SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "prefixneve"), Ct_Prefix[id], 32);
        SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Email"), g_Email[id], 99);
        SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "BiztKerdes"), s_biztonsagikerdes[id], 99);
        SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "BiztValasz"), s_valasz[id], 99);
        Rang[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Szint"));
        Dollar[id] = float(SQL_ReadResult(Query, 13)) / 100;
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
        havazas = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "havazas"));
        VanPrefix[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "vanprefix"));
        g_Erem[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "ErdemErem"));
        g_Premium[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Premium"));
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
        for(new i;i < 7; i++)
        {
            new String[64];
            formatex(String, charsmax(String), "L%d", i);
            Lada[i][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, String));
        }
        g_Quest[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "QuestH"));
        g_QuestKills[0][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "QuestNeed"));
        g_QuestKills[1][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "QuestHave"));
        g_QuestWeapon[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "QuestWeap"));
        g_QuestHead[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "QuestHead"));
        g_QuestMVP[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "QuestMVP"));
        g_Jutalom[0][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Jut1"));
        g_Jutalom[1][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Jut2"));
        g_Jutalom[2][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Jut3"));
        kivalasztott[id][0] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "kivak"));
        kivalasztott[id][1] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "kivm4"));
        kivalasztott[id][2] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "kivawp"));
        kivalasztott[id][3] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "kivfamas"));
        kivalasztott[id][4] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "kivmp5"));
        kivalasztott[id][5] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "kivgalil"));
        kivalasztott[id][6] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "kivscout"));
        kivalasztott[id][7] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "kivdeagle"));
        kivalasztott[id][8] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "kivusp"));
        kivalasztott[id][9] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "kivglock"));
        kivalasztott[id][10] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "kivknife"));
        new fast_cache[33];
        fast_cache[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "ult_hang"));
        g_Aktivitas[id] = 1;
        s_addvariable[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "s_addvariable"));
        if (1 <= s_addvariable[id])
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
        ColorChat(id, GREY, "^1 Üdv^3 %s^1, Sikeresen Bejelentkeztél.", g_Felhasznalonev[id]);
        g_Folyamatban[id] = 0;
        g_Bejelentkezve[id] = true;
        native_get_user_accountid(id);
        Fomenu(id);
    }
    else
    {
        ColorChat(id, GREY, "Hibás Felhasználónév vagy Jelszó.");
        g_Folyamatban[id] = 0;
        showMenu_RegLog(id);
    }
    return 0;
}

public sql_update_account_thread(FailState, Handle:Query, Error[], Errcode, Data[], DataSize)
{
    if (FailState == -2)
    {
        return set_fail_state("[ *HIBA* ] NEM LEHET KAPCSOLODNI AZ ADATBAZISHOZ!");
    }
    if (FailState == -1)
    {
        return set_fail_state("[ *HIBA* ] A LEKERDEZES MEGSZAKADT!");
    }
    if (Errcode)
    {
        return log_amx("[ *HIBA* ] PROBLEMA A LEKERDEZESNEL! ( %s )", Error);
    }
    return 0;
}

public Fomenu(id)
{
    if (g_Bejelentkezve[id])
    {
        new String[121];
        format(String, 120, "^n\dDollár: \r%3.2f $ \d| SMS Pont: \r%d^n", Dollar[id], SMS[id]);
        new menu = menu_create(String, "Fomenu_h");
        menu_additem(menu, "\d|\r=\w=\y>\r{\wRaktár\r}\y<\w=\r=\d|", "1", 0);
        menu_additem(menu, "\d|\r=\w=\y>\r{\wZenekészlet\r}\y<\w=\r=\d|", "20", 0);
        menu_additem(menu, "\d|\r=\w=\y>\r{\wLádaNyitás\r}\y<\w=\r=\d|", "2", 0);
        menu_additem(menu, "\d|\r=\w=\y>\r{\wPiac\r}\y<\w=\r=\d|", "3", 0);
        menu_additem(menu, "\d|\r=\w=\y>\r{\wBolt\r}\y<\w=\r=\d|", "4", 0);
        menu_additem(menu, "\d|\r=\w=\y>\r{\wSzerencséjáték\r}\y<\w=\r=\d|", "51", 0);
        if (g_Quest[id])
        {
            format(String, 120, "\d|\r=\w=\y>\r{\yKüldetések\r} \y[\wFolyamatban\y]\y<\w=\r=\d|");
        }
        else
        {
            format(String, 120, "\d|\r=\w=\y>\r{\yKüldetések\r}\y<\w=\r=\d|");
        }
        menu_additem(menu, String, "9", 0);
        if (Rang[id] == 18)
        {
            format(String, 120, "|\r=\w=\y>\r{\wBeállítások\r}\y<\w=\r=\d|");
        }
        else
        {
            format(String, 120, "|\r=\w=\y>\r{\wBeállítások\r}\y<\w=\r=\d|");
        }
        menu_additem(menu, String, "7", 01);
        menu_additem(menu, "\d|\r=\w=\y>\r{\wFelhasználói felület\r}\y<\w=\r=\d|", "8", 0);
        menu_additem(menu, "\d|\r=\w=\y>\r{\wSzerver Szabályzat\r}\y<\w=\r=\d|", "6", 0);
        menu_additem(menu, "\d|\r=\w=\y>\r{\wChat Hangok\r}\y<\w=\r=\d|", "22", 0);
        menu_additem(menu, "\d|\r=\w=\y>\r{\wPrémium VIP menü\r}\y<\w=\r=\d|", "50", 0);
        menu_additem(menu, "\d|\r=\w=\y>\r{\wSkin \yGambling\r}\y<\w=\r=\d|", "5", 0);
        //menu_additem(menu, "\d|\r=\w=\y>\r{\wInformációk\r}\y<\w=\r=\d|", "52", 0);
        menu_display(id, menu);
    }
    else
    {
        showMenu_Main(id);
    }
}

public Fomenu_h(id, menu, item)
{
    if (item == -3)
    {
        menu_destroy(menu);
        return 0;
    }
    new data[9];
    new szName[64];
    new access;
    new callback;
    menu_item_getinfo(menu, item, access, data, 8, szName, 63, callback);
    new key = str_to_num(data);
    new randomKills = random(30);
    new randomWeapon = random(10);
    new randomHead = random(1);
    new randomLada = random(4);
    new randomKulcs = random(4);
    new randomPremium = random_num(10, 20);
    new randomDollar = random_num(3, 10);
    switch (key)
    {
        case 1: Raktar(id);
        case 2: LadaNyitas(id);
        case 3: Piac(id);
        case 4: Shop(id);
        case 5: Kuka(id);
        case 6: show_motd(id, "addons/amxmodx/configs/szabalyzat.txt", "Szabályzat");
        case 7: Beallitasok(id);
        case 8: felhaszmenu(id);
        case 9:
        {
            if (g_Quest[id])
            {
                openQuestMenu(id);
            }
            else
            {
                g_QuestKills[0][id] = randomKills;
                g_QuestWeapon[id] = randomWeapon;
                g_QuestHead[id] = randomHead;
                g_Jutalom[0][id] = randomDollar;
                g_Jutalom[1][id] = randomLada;
                g_Jutalom[2][id] = randomKulcs;
                g_Jutalom[3][id] = randomPremium;
                g_Quest[id] = 1;
                openQuestMenu(id);
            }
        }
        case 20: client_cmd(id, "say /mvp");
        case 22: client_cmd(id, "say /chathanglista");
        case 50: client_cmd(id, "say /vip");
        case 51: gambling(id);
        //case 52: Informacio(id);
        default: {}
    }
    return 0;
}

public openQuestMenu(id)
{
    new String[121];
    formatex(String, 120, "\w^n^nBefejezett kuldeteseid:\r %d", g_QuestMVP[id]);
    new menu = menu_create(String, "h_openQuestMenu");
    new const QuestWeapons[][] = { "AK47", "M4A1", "AWP", "DEAGLE", "FAMAS", "GALIL", "SCOUT", "DEAGLE", "DEAGLE", "TMP", "Nincs" };
    new const QuestHeadKill[][] = { "Nincs", "Csak fejlövés" };

    formatex(String, charsmax(String), "\wFeladat: \yÖlj meg %d játékost \d[\yMég %d ölés\d]", g_QuestKills[0][id], g_QuestKills[0][id]-g_QuestKills[1][id]);
    menu_addtext2(menu, String);
    formatex(String, charsmax(String), "\wÖlés Korlát: \y%s", QuestHeadKill[g_QuestHead[id]]);
    menu_addtext2(menu, String);
    formatex(String, charsmax(String), "\wFegyver Korlát: \y%s \d[\rCsak ezzel a fegyverrel ölhetsz\d]^n", QuestWeapons[g_QuestWeapon[id]]);
    menu_addtext2(menu, String);
    formatex(String, 120, "\wJutalom:^n\y- Dollár [%d]^n- Láda [%d DB]^n- Kulcs [%d DB]^n- Küldetés Pont [+1]^n-Prémium pont \d[\r%d\d]", g_qReward[id][qReward_Money], g_Jutalom[1][id], g_Jutalom[2][id], g_Jutalom[3][id]);
    menu_addtext2(menu, String);
    formatex(String, charsmax(String), "\wKüldetés kihagyása \d[\r150$\d]");
    menu_additem(menu, String, "1",0);

    menu_display(id, menu, 0);
    }

public h_openQuestMenu(id, menu, item)
{
    if (item == -3)
    {
        menu_destroy(menu);
        return 0;
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
            openQuestMenu(id);
        }
        case 1:
        {
            if (0 <= SMS[id])
            {
                g_QuestKills[1][id] = 0;
                g_QuestWeapon[id] = 0;
                g_Quest[id] = 0;
                Dollar[id] -= 0;
                ColorChat(id, Color:2, "%s ^1Kihagytad ezt a küldetést", C_Prefix);
            }
            else
            {
                ColorChat(id, Color:2, "%s ^1Nincs elég^3 dolcsid", C_Prefix);
            }
        }
        default:
        {
        }
    }
    return 0;
}

public Shop(id)
{
    new String[256];
    static iTime;
    iTime = g_iVipTime[id] - get_systime();
    if (Vip[id] == 1)
    {
        format(String, 255, "^nSMS Pont:\r %d^nPrémium pont %d ^n\yVip lejárati idő:\y [\r%d nap\y]", SMS[id], g_Premium[id], iTime / 86400);
    }
    else
    {
        format(String, 255, "\yBolt^nSMS Pont:\r %d^nPrémium pont %d ^n", SMS[id], g_Premium[id]);
    }
    new menu = menu_create(String, "shop_h");
    if (!Vip[id])
    {
        if (g_iVipNum[id] == 1)
        {
            menu_additem(menu, "\w»\rVip hosszabbítás\y [8000 SMS pont/30Nap]", "1", 0);
        }
        menu_additem(menu, "\w»\rVip vásárlás\y [10000 SMS pont/30Nap]", "1", 01);
    }
    menu_additem(menu, "Prefix \rVásárlás\r[\y100$/DB\w]", "20", 0);
    menu_additem(menu, "\w»\yHE Gránát\r(200 Pont)", "2", 0);
    menu_additem(menu, "\w»\yVakítóGránát\r(200 Pont)", "3", 0);
    menu_additem(menu, "\w»\y+20 HP & +20 AP\r(200 pont)", "4", 0);
    menu_display(id, menu);
    return 0;
}

public shop_h(id, menu, item)
{
    if (item == -3)
    {
        menu_destroy(menu);
        return 0;
    }
    new data[9];
    new szName[64];
    new access;
    new callback;
    menu_item_getinfo(menu, item, access, data, 8, szName, 63, callback);
    new key = str_to_num(data);
    switch (key)
    {
        case 1:
        {
            if (Vip[id])
            {
            }
            else
            {
                if (g_iVipNum[id] == 1)
                {
                    if (8000 <= SMS[id])
                    {
                        Vip[id] = 1;
                        SMS[id] -= 8000;
                        ColorChat(id, BLUE, "%s ^1A vip jogod hosszabbítva lett!^3 -8000 SMS pont, +30Nap", C_Prefix);
                        g_iVipTime[id] = get_systime() + 2678400;
                        sql_update_account(id);
                    }
                    else
                    {
                        ColorChat(id, BLUE, "%s ^3Nincs elég SMS pontod!", C_Prefix);
                    }
                }
                if (10000 <= SMS[id])
                {
                    Vip[id] = 1;
                    SMS[id] -= 10000;
                    ColorChat(id, BLUE, "%s ^1A vip jogod aktiválva lett!^3 -10000 SMS", C_Prefix);
                    g_iVipTime[id] = get_systime() + 2678400;
                    sql_update_account(id);
                }
                ColorChat(id, BLUE, "%s ^3Nincs elég SMS pontod!", C_Prefix);
            }
        }
        case 2:
        {
            if (200 <= SMS[id])
            {
                give_item(id, "weapon_hegrenade");
                SMS[id] -= 200;
            }
            else
            {
                ColorChat(id, BLUE, "%s ^3Nincs elég SMS pontod!", C_Prefix);
            }
        }
        case 3:
        {
            if (200 <= SMS[id])
            {
                give_item(id, "weapon_flashbang");
                SMS[id] -= 200;
            }
            else
            {
                ColorChat(id, BLUE, "%s ^3Nincs elég SMS pontod!", C_Prefix);
            }
        }
        case 4:
        {
            if (200 <= SMS[id])
            {
                if (80 >= get_user_health(id))
                {
                    set_user_health(id, get_user_health(id) + 20);
                    give_item(id, "item_assaultsuit");
                    set_user_armor(id, get_user_armor(id) + 20);
                    SMS[id] -= 200;
                }
                else
                {
                    ColorChat(id, BLUE, "^3Sajnálom elérted a maximális HPt!");
                }
            }
            else
            {
                ColorChat(id, BLUE, "%s ^3Nincs elég SMS pontod!", C_Prefix);
            }
        }
        case 6:
        {
            if (cs_get_user_team(id) == CS_TEAM_T)
            {
                if (200 <= SMS[id])
                {
                    give_item(id, "weapon_c4");
                    cs_set_user_plant(id, 1, 1);
                    SMS[id] -= 200;
                }
                else
                {
                    ColorChat(id, BLUE, "%s ^3Nincs elég SMS pontod!", C_Prefix);
                }
            }
            else
            {
                ColorChat(id, BLUE, "%s ^3Te nem vagy a^4 Terrorista ^3csapatban!", C_Prefix);
            }
        }
        case 20:
        {
            egyediprefixmenu(id);
        }
        case 22:
        {
            if (508 <= g_Premium[id])
            {
                new kesdrop = random_num(16, 19);
                meglevoek[LadaDrop2[kesdrop]][id]++;
                client_cmd(id, "spk sound/avatar01/2.wav");
                ColorChat(id, Color:2, "%s ^1A te random kés droppod egy ^4%s", C_Prefix, FegyverAdatok[LadaDrop2[kesdrop]][8]);
                g_Premium[id] -= 508;
            }
            else
            {
                ColorChat(id, Color:2, "%s ^1Nincs elég prémium pontod", C_Prefix);
            }
        }
        default:
        {
        }
    }
    return 0;
}

// public Informacio(id)
// {
//     new String[121];
//     format(String, 120, "\r~[Avatár]~ \w[\yInformációk\w]");
//     new menu = menu_create(String, "Informaciok_h");
//     menu_additem(menu, "\w[\yTs3 Szerverünk\r!\w]", 540968);
//     menu_additem(menu, "\w[\yDiscord Szerverünk\r!\w]", 541100);
//     menu_additem(menu, "\w[\yTulajok\r!\w]", 541184);
//     menu_additem(menu, "\w[\yFacebook csoport\r!\w]", 541304);
//     menu_display(id, menu);
//     return 0;
// }

// public Informaciok_h(id, menu, item)
// {
//     if (item == -3)
//     {
//         menu_destroy(menu);
//         return 0;
//     }
//     new data[9];
//     new szName[64];
//     new access;
//     new callback;
//     menu_item_getinfo(menu, item, access, data, 8, szName, 63, callback);
//     new key = str_to_num(data);
//     switch (key)
//     {
//         case 1:
//         {
//             ColorChat(id, Color:2, "^1Ts3 Szerverünk: ^3avatar.craft.run");
//         }
//         case 2:
//         {
//             ColorChat(id, Color:2, "^1Discord Szerverünk: ^3https://discord.gg/RYGvVWaf");
//         }
//         case 3:
//         {
//             ColorChat(id, Color:2, "^4Misa ^1és ^3Gesu");
//         }
//         case 4:
//         {
//             ColorChat(id, Color:2, "^3https://www.facebook.com/groups/avatarteam2018.08.14");
//         }
//         default:
//         {
//         }
//     }
//     return 0;
// }

public egyediprefixmenu(id)
{
    new String[121];
    if (1 <= VanPrefix[id])
    {
        format(String, 120, "[%s]^n\wHasználatban lévő Prefixed: \r%s", Prefix, Ct_Prefix[id]);
    }
    else
    {
        format(String, 120, "[%s]^n\wHasználatban lévő Prefixed: \rNincs", Prefix);
    }
    new menu = menu_create(String, "h_Prefix");
    formatex(String, 120, "Prefix Hozzáadása \w[\y100$/DB\w]^n^nHozzáadási lehetőségek: \r%d/%d", VanPrefix[id], 12000);
    menu_additem(menu, String, "1");
    menu_display(id, menu);
    return 0;
}

public h_Prefix(id, menu, item)
{
    if (item == -3)
    {
        menu_destroy(menu);
        return;
    }
    if (Dollar[id] >= 100.0)
    {
        client_cmd(id, "messagemode Ct_Prefix");
        Dollar[id] -= 100.0;
        ColorChat(id, Color:2, "Nem megengedett a szóköz használata,a karakteres betüstílusok!");
    }
    else
    {
        ColorChat(id, Color:2, "%s^1Nincs elég dollárod", C_Prefix);
    }
}

public Chat_Prefix_Hozzaad(id)
{
    new Data[32];
    read_args(Data, 31);
    remove_quotes(Data);
    new hosszusag = strlen(Data);
    if (hosszusag <= 10 && hosszusag > 0)
    {
        VanPrefix[id]++;
        ColorChat(id, Color:2, "%s Vettél egy prefixet! Semmi csúnya, és adminhoz tartozó, dolgot ne írj!", C_Prefix);
    }
    else
    {
        ColorChat(id, Color:2, "%s A Prefixed maximum^3 10^1 karakterből állhat!", C_Prefix);
        egyediprefixmenu(id);
    }
    return 0;
}

public gambling(id)
{
    new focim[121];
    formatex(focim, 120, "\w[\dSzerencsejáték\w]^n^n\w[\yDollárod: \r%3.2f\w]", Dollar[id]);
    new menu = menu_create(focim, "gambling_menu");
    menu_additem(menu, "\w[\rRoulette\w]", "0");
    menu_additem(menu, "\w[\dCoinFlip\w]", "1");
    menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
    menu_setprop(menu, 4, "\w[\yKilépés\w]");
    menu_display(id, menu);
    return 1;
}

public gambling_menu(id, menu, item)
{
    if (item == -3)
    {
        menu_destroy(menu);
        return 0;
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
            rulimenu(id);
        }
        case 1:
        {
            coinflipmenu(id);
        }
        default:
        {
        }
    }
    return 0;
}

public rulimenu(id)
{
    new focim[121];
    formatex(focim, 120, "\w[\y Dollárod: \r%3.2f\w]", Dollar[id]);
    new menu = menu_create(focim, "roul_menu");
    format(focim, 120, "\yPiros 2x^n\r1-7-ig | \yTéted: \r%d^n", Berakepiros[id]);
    menu_additem(menu, focim, "0");
    format(focim, 120, "\ySzürke 2x^n\r8-14-ig | \yTéted: \r%d^n", Berakeszurke[id]);
    menu_additem(menu, focim, "1");
    format(focim, 120, "\yZöld 14x^nCsak \r0 | \yTéted: \r%d^n^n", Berakezold[id]);
    menu_additem(menu, focim, "2");
    if (0 < berakott[id])
    {
        format(focim, 120, "\w[\yPörgetés\w]");
        menu_additem(menu, focim, "3");
    }
    menu_setprop(menu, 6, 1);
    menu_setprop(menu, 4, "\w[\yKilépés\w]");
    menu_display(id, menu);
    return 1;
}

public rulilekeres(id)
{
    new Berakertekpiros;
    new adatok[32];
    read_args(adatok, 31);
    remove_quotes(adatok);
    Berakertekpiros = str_to_num(adatok);
    if (1 > str_to_num(adatok))
    {
        return 1;
    }

    if (Dollar[id] >= str_to_num(adatok) && berakott[id] <= 2)
    {
        Berakepiros[id] = Berakertekpiros;
        Dollar[id] -= Berakertekpiros;
        berakott[id]++;
        rulimenu(id);
    }
    else
    {
        if (6 > Berakepiros[id])
        {
            ColorChat(id, Color:2, "%s Minimum bet: 5", Prefix);
            rulimenu(id);
        }
    }
    return 1;
}

public rulilekeres1(id)
{
    new Berakertekszurke;
    new adatok[32];
    read_args(adatok, 31);
    remove_quotes(adatok);
    Berakertekszurke = str_to_num(adatok);
    if (1 > str_to_num(adatok))
    {
        return 1;
    }
    if (Dollar[id] >= str_to_num(adatok) && berakott[id] <= 2)
    {
        Berakeszurke[id] = Berakertekszurke;
        Dollar[id] -= Berakertekszurke;
        berakott[id]++;
        rulimenu(id);
    }
    else
    {
        if (6 > Berakeszurke[id])
        {
            ColorChat(id, Color:2, "%s Minimum bet: 5", Prefix);
            rulimenu(id);
        }
    }
    return 1;
}

public rulilekeres2(id)
{
    new Berakertekzold;
    new adatok[32];
    read_args(adatok, 31);
    remove_quotes(adatok);
    Berakertekzold = str_to_num(adatok);
    if (1 > str_to_num(adatok))
    {
        return 1;
    }
    if (Dollar[id] >= str_to_num(adatok) && berakott[id] <= 2)
    {
        Berakezold[id] = Berakertekzold;
        Dollar[id] -= Berakertekzold;
        berakott[id]++;
        rulimenu(id);
    }
    else
    {
        if (6 > Berakezold[id])
        {
            ColorChat(id, Color:2, "%s Minimum bet: 5", Prefix);
            rulimenu(id);
        }
    }
    return 1;
}

public roul_menu(id, menu, item)
{
    if (item == -3)
    {
        menu_destroy(menu);
        return 0;
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
            if (2 >= berakott[id])
            {
                client_cmd(id, "messagemode BET");
                Dollar[id] -= Berakepiros[id];
                rulimenu(id);
            }
            else
            {
                ColorChat(id, Color:2, "^3COINFLIP: ^1Csak egy választási lehetőséged van!");
            }
        }
        case 1:
        {
            if (2 >= berakott[id])
            {
                client_cmd(id, "messagemode BET1");
                Dollar[id] -= Berakeszurke[id];
                rulimenu(id);
            }
            else
            {
                ColorChat(id, Color:2, "^3COINFLIP: ^1Csak egy választási lehetőséged van!");
            }
        }
        case 2:
        {
            if (2 >= berakott[id])
            {
                client_cmd(id, "messagemode BET2");
                Dollar[id] -= Berakezold[id];
                rulimenu(id);
            }
            else
            {
                ColorChat(id, Color:2, "^3COINFLIP: ^1Csak egy választási lehetőséged van!");
            }
        }
        case 3:
        {
            new coinsorsolas = random(14);
            if (coinsorsolas >= 1 && coinsorsolas <= 7 && berakott[id] <= 2)
                Dollar[id] += float(Berakepiros[id] * 2);
            else
            {
                if (coinsorsolas && berakott[id] <= 2)
                    Dollar[id] += float(Berakezold[id] * 14);
                if (coinsorsolas >= 8 && coinsorsolas <= 14 && berakott[id] <= 2)
                    Dollar[id] += float(Berakeszurke[id] * 2);
            }
            ColorChat(id, Color:2, "^3ROULETTE: ^1A Nyerőszám: ^3%d", coinsorsolas);
            Berakeszurke[id] = 0;
            Berakepiros[id] = 0;
            Berakezold[id] = 0;
            berakott[id] = 0;
        }
        default:
        {
        }
    }
    return 0;
}

public coinflipmenu(id)
{
    new focim[121];
    formatex(focim, 120, "\w[\y Dollárod: \r%3.2f\w]", Dollar[id]);
    new menu = menu_create(focim, "coin_menu");
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
    return 1;
}

public coin_menu(id, menu, item)
{
    if (item == -3)
    {
        menu_destroy(menu);
        return 0;
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
                Dollar[id] -= BerakeTER[id];
                coinflipmenu(id);
            }
            else
            {
                ColorChat(id, Color:2, "^3COINFLIP: ^1Csak egy választási lehetőséged van!");
            }
        }
        case 1:
        {
            if (1 >= betett[id])
            {
                client_cmd(id, "messagemode BETS1");
                Dollar[id] -= BerakeCT[id];
                coinflipmenu(id);
            }
            else
            {
                ColorChat(id, Color:2, "^3COINFLIP: ^1Csak egy választási lehetőséged van!");
            }
        }
        case 3:
        {
            new coinsorsolas = random_num(1, 2);
            if (coinsorsolas == 1 && betett[id] <= 1)
            {
                Dollar[id] += float(BerakeTER[id] * 2);
                ColorChat(id, Color:2, "^3COINFLIP: ^1A Nyertes Oldal: ^3T", coinsorsolas);
            }
            if (coinsorsolas == 2 && betett[id] <= 1)
            {
                Dollar[id] += float(BerakeCT[id] * 2);
                ColorChat(id, Color:2, "^3COINFLIP: ^1A Nyertes Oldal: ^3CT", coinsorsolas);
            }
            BerakeCT[id] = 0;
            BerakeTER[id] = 0;
            betett[id] = 0;
        }
        default:
        {
        }
    }
    return 0;
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
    if (Dollar[id] >= str_to_num(adatok) && betett[id] <= 1)
    {
        BerakeTER[id] = BerakertekTER;
        Dollar[id] -= BerakertekTER;
        betett[id]++;
        coinflipmenu(id);
    }
    else
    {
        if (6 > BerakeTER[id])
        {
            ColorChat(id, Color:2, "%s Minimum bet: 5", Prefix);
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

    if (Dollar[id] >= str_to_num(adatok) && berakott[id] <= 1)
    {
        BerakeCT[id] = BerakertekCT;
        Dollar[id] -= BerakertekCT;
        betett[id]++;
        coinflipmenu(id);
    }
    else
    {
        if (6 > BerakeCT[id])
        {
            ColorChat(id, Color:2, "%s Minimum bet: 5", Prefix);
            coinflipmenu(id);
        }
    }
    return 1;
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

public felhasz_h(id, menu, item)
{
    if (item == -3)
    {
        menu_destroy(menu);
        return 0;
    }
    new data[9];
    new szName[64];
    new access;
    new callback;
    menu_item_getinfo(menu, item, access, data, 8, szName, 63, callback);
    new key = str_to_num(data);
    switch (key)
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
        default:
        {
        }
    }
    return 0;
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

public megkerd_h(id, menu, item)
{
    if (item == -3)
    {
        menu_destroy(menu);
        return 0;
    }
    new data[9];
    new szName[64];
    new access;
    new callback;
    menu_item_getinfo(menu, item, access, data, 8, szName, 63, callback);
    new key = str_to_num(data);
    switch (key)
    {
        case 1:
        {
            PlayerChoose3(id);
        }
        case 2:
        {
            viptorol = 1;
            ColorChat(id, GREY, "%s ^3Írd be a felhasználónevét!", C_Prefix);
            client_cmd(id, "messagemode USERNAME3");
        }
        default:
        {
        }
    }
    return 0;
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

public staffadd_h(id, menu, item)
{
    if (item == -3)
    {
        menu_destroy(menu);
        return 0;
    }
    new data[9];
    new szName[64];
    new access;
    new callback;
    menu_item_getinfo(menu, item, access, data, 8, szName, 63, callback);
    new key = str_to_num(data);
    addolasikulcs = key;
    if (key == 129)
    {
        addvip(id);
    }
    else
    {
        PlayerChoose2(id);
    }
    return 0;
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
    if (item == -3)
    {
        menu_destroy(Menu);
        return 1;
    }
    new Data[6];
    new szName[64];
    new access;
    new callback;
    menu_item_getinfo(Menu, item, access, Data, 5, szName, 63, callback);
    TempID = str_to_num(Data);
    if (addolasikulcs == 130)
    {
        meglevoek[132][TempID] += str_to_num(Data);
        ColorChat(TempID, BLUE, "3%s ^1Jóváirtak egy^4 FragBajnok KÉS-t!", C_Prefix);
    }
    else
    {
        if (addolasikulcs == 9950)
        {
            client_cmd(TempID, "snapshot");
            g_snapshot[TempID]++;
            ColorChat(id, GREY, "%s ^3A személyről kép lett készítve! Összes:^4 %d", C_Prefix, g_snapshot[TempID]);
        }
        if (addolasikulcs == 999)
        {
            Vip[TempID] = 1;
            new p_name[33];
            get_user_name(id, p_name, 32);
            ColorChat(TempID, GREY, "%s ^4%s ^3Jóváírt neked egy^4 Vip ^3tagot!", C_Prefix, p_name);
            ColorChat(id, GREY, "%s Sikeres jóváírás!", C_Prefix);
            sql_update_account(id);
        }
        if (addolasikulcs == 911)
        {
            s_addvariable[TempID] = 1;
            new s_name[33];
            new performer_name[33];
            get_user_name(TempID, s_name, 32);
            get_user_name(id, performer_name, 32);
            ColorChat(0, GREY, "%s %s ^3Növelte^4 %s ^3jogát^4 segítői ^3szintre!", C_Prefix, performer_name, s_name);
            ColorChat(TempID, GREY, "%s ^3További infókért írd be:^4 /sinfo", C_Prefix);
            set_user_flags(TempID, get_user_flags(TempID) | ADMIN_CHAT);
        }
        if (addolasikulcs == 912)
        {
            client_cmd(id, "messagemode SKICK_INDOK");
        }
        if (addolasikulcs == 913)
        {
            s_addvariable[TempID] = 0;
            new s_name[33];
            new performer_name[33];
            get_user_name(TempID, s_name, 32);
            get_user_name(id, performer_name, 32);
            ColorChat(0, GREY, "%s %s ^3Csökkentette^4 %s ^3jogát^4 felhasználói ^3szintre!", C_Prefix, performer_name, s_name);
            remove_user_flags(TempID, get_user_flags(TempID) | ADMIN_CHAT);
        }
        if (addolasikulcs == 129)
        {
            addvip(id);
        }
        client_cmd(id, "messagemode ADDMENNYISEG");
    }
    menu_destroy(Menu);
    return 1;
}

public AddSend(id)
{
    new Data[121];
    new SendName[32];
    read_args(Data, 120);
    remove_quotes(Data);
    get_user_name(id, SendName, 31);
    if (1 > str_to_num(Data))
    {
        return 1;
    }
    if (addolasikulcs <= 120)
    {
        meglevoek[addolasikulcs][TempID] += str_to_num(Data);
        ColorChat(TempID, GREY, "%s^3%s ^1Jóváírt neked^4 %d DB^4 %s ^1nevü skint!", C_Prefix, SendName, str_to_num(Data), FegyverAdatok[addolasikulcs][8]);
    }
    else
    {
        if (addolasikulcs >= 121 && addolasikulcs != 128 && addolasikulcs != 129)
        {
            addolasikulcs -= 121;
            Lada[addolasikulcs][TempID] += str_to_num(Data);
            ColorChat(TempID, GREY, "%s^3%s ^1Jóváírt neked^4 %d DB^4 %s nevü itemet!", C_Prefix, SendName, str_to_num(Data), l_Nevek[addolasikulcs]);
        }
        if (addolasikulcs == 128)
        {
            Kulcs[TempID] += str_to_num(Data);
            ColorChat(TempID, GREY, "%s^3%s ^1Jóváírt neked^4 %d DB^4 Kulcs^1-ot", C_Prefix, SendName, str_to_num(Data));
        }
    }
    return 1;
}

public addvip(id)
{
    new String[256];
    format(String, 255, "%s \r- \yVálassz az opciók közül!^n\d", Prefix);
    new menu = menu_create(String, "addvip_h");
    formatex(String, charsmax(String), "\y»Fentlévő játékosnak");
    menu_additem(menu, String, "1");
    formatex(String, charsmax(String), "\y»Felhasználónév alapján^n\rMegjegyzés: Akkor válaszd ezt az opciót ha offline a játékos!");
    menu_additem(menu, String, "2");
}

public addvip_h(id, menu, item)
{
    if (item == -3)
    {
        menu_destroy(menu);
        return 0;
    }
    new data[9];
    new szName[64];
    new access;
    new callback;
    menu_item_getinfo(menu, item, access, data, 8, szName, 63, callback);
    new key = str_to_num(data);
    switch (key)
    {
        case 1:
        {
            addolasikulcs = 999;
            PlayerChoose2(id);
        }
        case 2:
        {
            client_cmd(id, "messagemode USERNAME3");
            ColorChat(id, GREY, "%s ^3Írd be a felhasználónevét!", C_Prefix);
        }
        default:
        {
        }
    }
    return 0;
}

public sql_delete_vip(id)
{
    static Query[256];
    new a[191];
    format(a, 190, "%s", g_FHVIP[id]);
    replace_all(a, 190, "\", "\\");
    replace_all(a, 190, "'", "\'");

    formatex(Query, 255, "UPDATE rwt_sql_register_new_s5 SET Vip = '0' WHERE Felhasznalonev = '%s'", a);
    new Data[2];
    Data[0] = id;
    Data[1] = get_user_userid(id);
    SQL_ThreadQuery(g_SqlTuple, "sql_delete_vip_thread", Query, Data, 2);
    return 0;
}

public sql_delete_vip_thread(FailState, Handle:Query, Error[], Errcode, Data[], DataSize)
{
    if (FailState == -2)
    {
        return set_fail_state("[ *HIBA* ] NEM LEHET KAPCSOLODNI AZ ADATBAZISHOZ!");
    }
    if (FailState == -1)
    {
        return set_fail_state("[ *HIBA* ] A LEKERDEZES MEGSZAKADT!");
    }
    if (Errcode)
    {
        return log_amx("[ *HIBA* ] PROBLEMA A LEKERDEZESNEL! ( %s )", Error);
    }
    new id = Data[0];
    if (get_user_userid(id) != Data[1])
    {
        return 1;
    }
    ColorChat(id, GREY, "%s ^3A VIP törlése megtörtént a következő felhasználónévre:^4 %s", C_Prefix, g_FHVIP[id]);
    viptorol = 0;
    return 0;
}

public sql_update_vip(id)
{
    static Query[256];
    new a[191];
    format(a, 190, "%s", g_FHVIP[id]);
    replace_all(a, 190, "\", "\\");
    replace_all(a, 190, "'", "\'");
    formatex(Query, 255, "UPDATE rwt_sql_register_new_s5 SET Vip = '1' WHERE Felhasznalonev = '%s'", a);
    new Data[2];
    Data[0] = id;
    Data[1] = get_user_userid(id);
    SQL_ThreadQuery(g_SqlTuple, "sql_update_vip_thread", Query, Data, 2);
    return 0;
}

public sql_update_vip_thread(FailState, Handle:Query, Error[], Errcode, Data[], DataSize)
{
    if (FailState == -2)
    {
        return set_fail_state("[ *HIBA* ] NEM LEHET KAPCSOLODNI AZ ADATBAZISHOZ!");
    }
    if (FailState == -1)
    {
        return set_fail_state("[ *HIBA* ] A LEKERDEZES MEGSZAKADT!");
    }
    if (Errcode)
    {
        return log_amx("[ *HIBA* ] PROBLEMA A LEKERDEZESNEL! ( %s )", Error);
    }
    new id = Data[0];
    if (get_user_userid(id) != Data[1])
    {
        return 1;
    }
    ColorChat(id, GREY, "%s ^3A VIP adása megtörtént a következő felhasználónévre:^4 %s", C_Prefix, g_FHVIP[id]);
    return 0;
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

public staffmegv_h(id, menu, item)
{
    if (item == -3)
    {
        menu_destroy(menu);
        return 0;
    }
    new data[9];
    new szName[64];
    new p_name[33];
    new access;
    new callback;
    get_user_name(id, p_name, 32);
    menu_item_getinfo(menu, item, access, data, 8, szName, 63, callback);
    new key = str_to_num(data);
    addolasikulcs = key;
    if (key == 131)
    {
        Vip[TempID] = 0;
        if (get_user_health(TempID) == 120)
        {
            set_user_health(TempID, 100);
            meglevoek[133][id] = 0;
            kivalasztott[id][10] = 131;
            set_pev(id,pev_viewmodel2,FegyverAdatok[131][Model]);
        }
        ColorChat(TempID, BLUE, "%s^1%s ^3Megvont a^4 VIPPED^3-től!", C_Prefix, p_name);
        sql_update_account(id);
    }
    else
    {
        client_cmd(id, "messagemode MEGVONMENNYISEG");
    }
    return 0;
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
    if (item == -3)
    {
        menu_destroy(Menu);
        return 1;
    }
    new Data[6];
    new szName[64];
    new access;
    new callback;
    menu_item_getinfo(Menu, item, access, Data, 5, szName, 63, callback);
    TempID = str_to_num(Data);
    staffmegvonas(id);
    menu_destroy(Menu);
    return 1;
}

public AddSend2(id)
{
    new Data[121];
    new SendName[32];
    read_args(Data, 120);
    remove_quotes(Data);
    get_user_name(id, SendName, 31);
    if (1 > str_to_num(Data))
    {
        return 1;
    }
    if (addolasikulcs <= 120)
    {
        meglevoek[addolasikulcs][TempID] -= str_to_num(Data);
        ColorChat(TempID, BLUE, "%s^3%s ^1Elvett tőled^4 %d DB^4 %s ^1nevü skint!", C_Prefix, SendName, str_to_num(Data), FegyverAdatok[addolasikulcs][8]);
        if (FegyverAdatok[addolasikulcs][0])
        {
            if (FegyverAdatok[addolasikulcs][0] == 1)
            {
                kivalasztott[TempID][1] = 122;
            }
            if (FegyverAdatok[addolasikulcs][0] == 2)
            {
                kivalasztott[TempID][2] = 123;
            }
            if (FegyverAdatok[addolasikulcs][0] == 3)
            {
                kivalasztott[TempID][3] = 124;
            }
            if (FegyverAdatok[addolasikulcs][0] == 4)
            {
                kivalasztott[TempID][4] = 125;
            }
            if (FegyverAdatok[addolasikulcs][0] == 5)
            {
                kivalasztott[TempID][5] = 126;
            }
            if (FegyverAdatok[addolasikulcs][0] == 6)
            {
                kivalasztott[TempID][6] = 127;
            }
            if (FegyverAdatok[addolasikulcs][0] == 7)
            {
                kivalasztott[TempID][7] = 128;
            }
            if (FegyverAdatok[addolasikulcs][0] == 8)
            {
                kivalasztott[TempID][8] = 129;
            }
            if (FegyverAdatok[addolasikulcs][0] == 9)
            {
                kivalasztott[TempID][9] = 130;
            }
            if (FegyverAdatok[addolasikulcs][0] == 10)
            {
                kivalasztott[TempID][10] = 131;
            }
        }
        else
        {
            kivalasztott[TempID][0] = 121;
        }
    }
    else
    {
        if (addolasikulcs >= 121 && addolasikulcs != 128 && addolasikulcs != 129)
        {
            addolasikulcs = addolasikulcs + -121;
            Lada[addolasikulcs][TempID] -= str_to_num(Data);
            ColorChat(TempID, BLUE, "%s^3%s ^1Elvett tőled^4 %d DB^4 %s ^1nevü itemet!", C_Prefix, SendName, str_to_num(Data), l_Nevek[addolasikulcs]);
        }
        if (addolasikulcs == 128)
        {
            meglevoek[132][TempID] -= str_to_num(Data);
            ColorChat(TempID, BLUE, "%s^3%s ^1Elvett tőled egy^4 FragBajnok KÉS ^1nevü skint!", C_Prefix, SendName);
            if (FegyverAdatok[132][Type] == 10)
            {
                kivalasztott[TempID][KNIFE] = 131;
            }
        }
        if (addolasikulcs == 129)
        {
            meglevoek[133][TempID] -= str_to_num(Data);
            ColorChat(TempID, BLUE, "%s^3%s ^1Elvett tőled egy^4 VIP KÉS ^1nevü skint!", C_Prefix, SendName);
            if (FegyverAdatok[133][Type] == 10)
            {
                kivalasztott[TempID][KNIFE] = 131;
            }
        }
        if (addolasikulcs == 130)
        {
            Kulcs[TempID] -= str_to_num(Data);
            ColorChat(TempID, BLUE, "%s^3%s ^1Elvett tőled^4 %d DB^4 Kulcs^1-ot", C_Prefix, SendName, str_to_num(Data));
        }
    }
    return 1;
}

public Beallitasok(id)
{
    new String[121];
    format(String, charsmax(String), "%s \r- \dBeállítások", Prefix);
    new menu = menu_create(String, "Beallitasok_h");

    if(Gun[0][id] == 1)
    {
        menu_additem(menu, "Skinek: \yBekapcsolva \d(testreszabható)", "1");
    }
    else
    {
        menu_additem(menu, "Skinek: \dKikapcsolva", "1");
    }
    if (Hud[id] == 1)
    {
        menu_additem(menu, "HUD: \yBekapcsolva", "2");
    }
    else
    {
        menu_additem(menu, "HUD: \dKikapcsolva", "2");
    }

    formatex(String, charsmax(String), "\yHavazás:\r [\y%s\r]", havazas == 1 ? "\yBekapcsolva" : "\dKikapcsolva");
    menu_additem(menu, String, "6", 0);

    menu_display(id, menu);
    return 0;
}

public Beallitasok_h(id, menu, item)
{
    if (item == -3)
    {
        menu_destroy(menu);
        return 0;
    }
    new data[9];
    new szName[64];
    new access;
    new callback;
    menu_item_getinfo(menu, item, access, data, 8, szName, 63, callback);
    new key = str_to_num(data);
    switch (key)
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
            if (Hud[id] == 1)
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
            client_cmd(id, "sebzesmenu");
        }
        case 6:
        {
            if (havazas == 1)
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
        default:
        {
        }
    }
    return 0;
}

public skintestreszab(id)
{
    new String[256];
    format(String, 255, "\r- \dSkinek\r/\dTestreszabás");
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

public testreszab_h(id, menu, item)
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
    switch(key) 
    {
        case 1: Gun[0][id] = 0;
        case 2:
        {
            if(Gun[1][id] == 1)
                Gun[1][id] = 0;
            else
            Gun[1][id] = 1;
        }
        case 3:
        {
            if(Gun[2][id] == 1)
                Gun[2][id] = 0;
            else
                Gun[2][id] = 1;
        }
        case 4:
        {
            if(Gun[3][id] == 1)
                Gun[3][id] = 0;
            else
                Gun[3][id] = 1;
        }
        case 5:
        {
        if(Gun[4][id] == 1)
            Gun[4][id] = 0;
        else
            Gun[4][id] = 1;
        }
        case 6:
        {
            if(Gun[5][id] == 1)
                Gun[5][id] = 0;
            else
                Gun[5][id] = 1;
        }
        case 7:
        {
            if(Gun[6][id] == 1)
                Gun[6][id] = 0;
            else
                Gun[6][id] = 1;
        }
        case 8:
        {
            if(Gun[7][id] == 1)
                Gun[7][id] = 0;
            else
                Gun[7][id] = 1;
        }
        case 9:
        {
            if(Gun[8][id] == 1)
                Gun[8][id] = 0;
            else
                Gun[8][id] = 1;
        }
        case 10:
        {
            if(Gun[9][id] == 1)
                Gun[9][id] = 0;
            else
                Gun[9][id] = 1;
        }
        case 11:
        {
            if(Gun[10][id] == 1)
                Gun[10][id] = 0;
            else
                Gun[10][id] = 1;
        }
        case 12:
        {
            if(Gun[11][id] == 1)
                Gun[11][id] = 0;
            else
                Gun[11][id] = 1;
        }
    }
    if(Gun[0][id] != 0)
        skintestreszab(id);
}

public LadaNyitas(id)
{
    new String[151];
    formatex(String, 150, "Kulcs: \d[\r%d DB\d]", Kulcs[id]);
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

public Lada_h(id, menu, item)
{
    if (item == -3)
    {
        menu_destroy(menu);
        return 0;
    }
    new data[9];
    new szName[64];
    new access;
    new callback;
    menu_item_getinfo(menu, item, access, data, 8, szName, 63, callback);
    new key = str_to_num(data);
    switch (key)
    {
        case 0, 1, 2:
        {
            caseopen_q(id);
            caseid = key;
        }
        case 3, 4, 5:
        {
            caseopen_q(id);
            caseid = key;
        }
        case 6:
        {
            caseopen_q(id);
            caseid = key;
        }
        default:
        {
        }
    }
    return 0;
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

public caseopen_q_h(id, menu, item)
{
    if (item == -3)
    {
        menu_destroy(menu);
        return 0;
    }
    new data[9];
    new szName[64];
    new access;
    new callback;
    menu_item_getinfo(menu, item, access, data, 8, szName, 63, callback);
    new key = str_to_num(data);
    switch (key)
    {
        case 1:
        {
            if (Lada[caseid][id] >= 1 && Kulcs[id] >= 1)
            {
                Lada[caseid][id]--;
                Kulcs[id]--;
                KivLada[id] = caseid;
                new hangrandom = random_num(0,2);
                if (hangrandom)
                {
                    if (hangrandom == 1)
                    {
                        client_cmd(id, "spk sound/LadaO2.wav");
                    }
                    if (hangrandom == 2)
                    {
                        client_cmd(id, "spk sound/LadaO3.wav");
                    }
                }
                else
                {
                    client_cmd(id, "spk sound/LadaO1.wav");
                }
                Talal(id);
            }
            else
            {
                LadaNyitas(id);
                ColorChat(id, Color:2, "%s ^1Nincs ládád vagy kulcsod", C_Prefix);
            }
        }
        case 2:
        {
            if (caseid)
            {
                if (caseid == 1)
                {
                    show_motd(id, "addons/amxmodx/configs/ladak/1.txt", "Ládák Tartalma");
                }
                if (caseid == 2)
                {
                    show_motd(id, "addons/amxmodx/configs/ladak/2.txt", "Ládák Tartalma");
                }
                if (caseid == 3)
                {
                    show_motd(id, "addons/amxmodx/configs/ladak/3.txt", "Ládák Tartalma");
                }
                if (caseid == 4)
                {
                    show_motd(id, "addons/amxmodx/configs/ladak/4.txt", "Ládák Tartalma");
                }
                if (caseid == 5)
                {
                    show_motd(id, "addons/amxmodx/configs/ladak/5.txt", "Ládák Tartalma");
                }
                if (caseid == 6)
                {
                    show_motd(id, "addons/amxmodx/configs/ladak/6.txt", "Ládák Tartalma");
                }
            }
            else
            {
                show_motd(id, "addons/amxmodx/configs/ladak/0.txt", "Ládák Tartalma");
            }
        }
        default:
        {
        }
    }
    return 0;
}

public Talal(id)
{
    new nev[32];
    get_user_name(id, nev, 31);
    new Float:Szam = random_float(0.01,100.00);
    new FegyverID0 = random_num(0, 10);
    new FegyverID1 = random_num(0, 13);
    new FegyverID2 = random_num(0, 5);
    new FegyverID3 = random_num(0, 4);
    new FegyverID4 = random_num(0, 1);
    if (KivLada[id])
    {
        if (KivLada[id] == 1)
        {
            if (Szam >= 60.0 && Szam <= 100.0)
            {
                meglevoek[LadaDrop1[FegyverID1]][id]++;
                ColorChat(id, GREY, "%s ^3Nyitottál egy %s skint", C_Prefix, FegyverAdatok[LadaDrop1[FegyverID1]][8]);
            }
            else
            {
                if (Szam > 9.5 && Szam < 60.0)
                {
                    new liladrop = random_num(14, 16);
                    meglevoek[LadaDrop1[liladrop]][id]++;
                    ColorChat(id, Color:2, "%s ^4Nyitottál egy %s skint", C_Prefix, FegyverAdatok[LadaDrop1[liladrop]][8]);
                }
                if (Szam > 2.0 && Szam < 9.5)
                {
                    meglevoek[LadaDrop1[17]][id]++;
                    client_cmd(id, "spk sound/avatar01/1.wav");
                    ColorChat(id, BLUE, "%s ^3Nyitottál egy %s skint", C_Prefix, FegyverAdatok[LadaDrop1[17]][8]);
                    set_dhudmessage(random(256), random(256), random(256), -1.0, 0.2, 0, 6.0, 3.0, 0.1, 1.5);
                    show_dhudmessage(0, "%s^nNyitott egy:^n%s-t", nev, FegyverAdatok[LadaDrop1[17]][8]);
                }
                if (Szam >= 0.5 && Szam <= 2.0)
                {
                    new kesdrop = random_num(18, 21);
                    meglevoek[LadaDrop1[kesdrop]][id]++;
                    client_cmd(id, "spk sound/avatar01/1.wav");
                    ColorChat(id, Color:2, "%s ^1Nyitottál egy %s skint", C_Prefix, FegyverAdatok[LadaDrop1[kesdrop]][8]);
                    set_dhudmessage(random(256), random(256), random(256), -1.0, 0.2, 0, 6.0, 3.0, 0.1, 1.5);
                    show_dhudmessage(0, "%s^nNyitott egy:^n%s-t", nev, FegyverAdatok[LadaDrop1[kesdrop]][8]);
                }
            }
        }
        if (KivLada[id] == 2)
        {
            if (Szam >= 60.0 && Szam <= 100.0)
            {
                meglevoek[LadaDrop2[FegyverID2]][id]++;
                ColorChat(id, GREY, "%s ^3Nyitottál egy %s skint", C_Prefix, FegyverAdatok[LadaDrop2[FegyverID2]][8]);
            }
            else
            {
                if (Szam > 9.5 && Szam < 60.0)
                {
                    new liladrop = random_num(6, 13);
                    meglevoek[LadaDrop2[liladrop]][id]++;
                    ColorChat(id, Color:2, "%s ^4Nyitottál egy %s skint", C_Prefix, FegyverAdatok[LadaDrop2[liladrop]][8]);
                }
                if (Szam > 2.0 && Szam < 9.5)
                {
                    new pirosdrop = random_num(14, 15);
                    meglevoek[LadaDrop2[pirosdrop]][id]++;
                    client_cmd(id, "spk sound/avatar01/1.wav");
                    ColorChat(id, BLUE, "%s ^3Nyitottál egy %s skint", C_Prefix, FegyverAdatok[LadaDrop2[pirosdrop]][8]);
                    set_dhudmessage(random(256), random(256), random(256), -1.0, 0.2, 0, 6.0, 3.0, 0.1, 1.5);
                    show_dhudmessage(0, "%s^nNyitott egy:^n%s-t", nev, FegyverAdatok[LadaDrop2[pirosdrop]][8]);
                }
                if (Szam >= 0.5 && Szam <= 2.0)
                {
                    new kesdrop = random_num(16, 19);
                    meglevoek[LadaDrop2[kesdrop]][id]++;
                    client_cmd(id, "spk sound/avatar01/2.wav");
                    ColorChat(0, Color:2, "%s ^1Nyitottál egy %s skint", C_Prefix, FegyverAdatok[LadaDrop2[kesdrop]][8]);
                    set_dhudmessage(random(256), random(256), random(256), -1.0, 0.2, 0, 6.0, 3.0, 0.1, 1.5);
                    show_dhudmessage(0, "%s^nNyitott egy:^n%s-t", nev, FegyverAdatok[LadaDrop2[kesdrop]][8]);
                }
            }
        }
        if (KivLada[id] == 3)
        {
            if (Szam >= 60.0 && Szam <= 100.0)
            {
                meglevoek[LadaDrop3[FegyverID3]][id]++;
                ColorChat(id, GREY, "%s ^3Nyitottál egy %s skint", C_Prefix, FegyverAdatok[LadaDrop3[FegyverID3]][8]);
            }
            else
            {
                if (Szam > 9.5 && Szam < 60.0)
                {
                    new liladrop = random_num(5, 14);
                    meglevoek[LadaDrop3[liladrop]][id]++;
                    ColorChat(id, Color:2, "%s ^4Nyitottál egy %s skint", C_Prefix, FegyverAdatok[LadaDrop3[liladrop]][8]);
                }
                if (Szam > 2.0 && Szam < 9.5)
                {
                    meglevoek[LadaDrop3[15]][id]++;
                    client_cmd(id, "spk sound/avatar01/2.wav");
                    ColorChat(id, BLUE, "%s ^3Nyitottál egy %s skint", C_Prefix, FegyverAdatok[LadaDrop3[15]][8]);
                    set_dhudmessage(random(256), random(256), random(256), -1.0, 0.2, 0, 6.0, 3.0, 0.1, 1.5);
                    show_dhudmessage(0, "%s^nNyitott egy:^n%s-t", nev, FegyverAdatok[LadaDrop3[15]][8]);
                }
                if (Szam >= 0.5 && Szam <= 2.0)
                {
                    new kesdrop = random_num(16, 19);
                    meglevoek[LadaDrop3[kesdrop]][id]++;
                    client_cmd(id, "spk sound/avatar01/1.wav");
                    ColorChat(id, Color:2, "%s ^1Nyitottál egy %s skint", C_Prefix, FegyverAdatok[LadaDrop3[kesdrop]][8]);
                    set_dhudmessage(random(256), random(256), random(256), -1.0, 0.2, 0, 6.0, 3.0, 0.1, 1.5);
                    show_dhudmessage(0, "%s^nNyitott egy:^n%s-t", nev, FegyverAdatok[LadaDrop3[kesdrop]][8]);
                }
            }
        }
        if (KivLada[id] == 4)
        {
            if (Szam >= 60.0 && Szam <= 100.0)
            {
                meglevoek[LadaDrop4[FegyverID4]][id]++;
                ColorChat(id, GREY, "%s ^3Nyitottál egy %s skint", C_Prefix, FegyverAdatok[LadaDrop4[FegyverID4]][8]);
            }
            else
            {
                if (Szam > 9.5 && Szam < 60.0)
                {
                    new liladrop = random_num(2, 9);
                    meglevoek[LadaDrop4[liladrop]][id]++;
                    ColorChat(id, Color:2, "%s ^4Nyitottál egy %s skint", C_Prefix, FegyverAdatok[LadaDrop4[liladrop]][8]);
                }
                if (Szam > 2.0 && Szam < 9.5)
                {
                    new pirosdrop = random_num(10, 15);
                    meglevoek[LadaDrop4[pirosdrop]][id]++;
                    client_cmd(id, "spk sound/avatar01/2.wav");
                    ColorChat(id, BLUE, "%s ^3Nyitottál egy %s skint", C_Prefix, FegyverAdatok[LadaDrop4[pirosdrop]][8]);
                    set_dhudmessage(random(256), random(256), random(256), -1.0, 0.2, 0, 6.0, 3.0, 0.1, 1.5);
                    show_dhudmessage(0, "%s^nNyitott egy:^n%s-t", nev, FegyverAdatok[LadaDrop4[pirosdrop]][8]);
                }
                if (Szam >= 0.5 && Szam <= 2.0)
                {
                    new kesdrop = random_num(16, 19);
                    meglevoek[LadaDrop4[kesdrop]][id]++;
                    client_cmd(id, "spk sound/avatar01/1.wav");
                    ColorChat(id, Color:2, "%s ^1Nyitottál egy %s skint", C_Prefix, FegyverAdatok[LadaDrop4[kesdrop]][8]);
                    set_dhudmessage(random(256), random(256), random(256), -1.0, 0.2, 0, 6.0, 3.0, 0.1, 1.5);
                    show_dhudmessage(0, "%s^nNyitott egy:^n%s-t", nev, FegyverAdatok[LadaDrop4[kesdrop]][8]);
                }
            }
        }
        if (KivLada[id] == 5)
        {
            if (Szam >= 60.0 && Szam <= 100.0)
            {
                meglevoek[LadaDrop5[0]][id]++;
                ColorChat(id, GREY, "%s ^3Nyitottál egy %s skint", C_Prefix, FegyverAdatok[LadaDrop5[0]][8]);
            }
            else
            {
                if (Szam > 9.5 && Szam < 60.0)
                {
                    new liladrop = random_num(1, 5);
                    meglevoek[LadaDrop5[liladrop]][id]++;
                    ColorChat(id, Color:2, "%s ^4Nyitottál egy %s skint", C_Prefix, FegyverAdatok[LadaDrop5[liladrop]][8]);
                }
                if (Szam > 2.0 && Szam < 9.5)
                {
                    new pirosdrop = random_num(6, 9);
                    meglevoek[LadaDrop5[pirosdrop]][id]++;
                    client_cmd(id, "spk sound/avatar01/2.wav");
                    ColorChat(id, BLUE, "%s ^3Nyitottál egy %s skint", C_Prefix, FegyverAdatok[LadaDrop5[pirosdrop]][8]);
                    set_dhudmessage(random(256), random(256), random(256), -1.0, 0.2, 0, 6.0, 3.0, 0.1, 1.5);
                    show_dhudmessage(0, "%s^nNyitott egy:^n%s-t", nev, FegyverAdatok[LadaDrop5[pirosdrop]][8]);
                }
                if (Szam >= 0.5 && Szam <= 2.0)
                {
                    new kesdrop = random_num(10, 13);
                    meglevoek[LadaDrop5[kesdrop]][id]++;
                    client_cmd(id, "spk sound/avatar01/1.wav");
                    ColorChat(id, Color:2, "%s ^1Nyitottál egy %s skint", C_Prefix, FegyverAdatok[LadaDrop5[kesdrop]][8]);
                    set_dhudmessage(random(256), random(256), random(256), -1.0, 0.2, 0, 6.0, 3.0, 0.1, 1.5);
                    show_dhudmessage(0, "%s^nNyitott egy:^n%s-t", nev, FegyverAdatok[LadaDrop5[kesdrop]][8]);
                }
            }
        }
        if (KivLada[id] == 6)
        {
            if (Szam >= 40.0 && Szam <= 100.0)
            {
                new liladrop = random_num(id, 4);
                meglevoek[LadaDrop6[liladrop]][id]++;
                ColorChat(id, GREY, "%s ^3Nyitottál egy %s skint", C_Prefix, FegyverAdatok[LadaDrop6[liladrop]][8]);
            }
            if (Szam >= 9.5 && Szam < 40.0)
            {
                new pirosdrop = random_num(5, 8);
                meglevoek[LadaDrop6[pirosdrop]][id]++;
                client_cmd(id, "spk sound/avatar01/2.wav");
                ColorChat(id, BLUE, "%s ^3Nyitottál egy %s skint", C_Prefix, FegyverAdatok[LadaDrop6[pirosdrop]][8]);
                set_dhudmessage(random(256), random(256), random(256), -1.0, 0.2, 0, 6.0, 3.0, 0.1, 1.5);
                show_dhudmessage(0, "%s^nNyitott egy:^n%s-t", nev, FegyverAdatok[LadaDrop6[pirosdrop]][8]);
            }
            if (Szam >= 4.0 && Szam < 9.5)
            {
                new kesdrop = random_num(10, 13);
                meglevoek[LadaDrop6[kesdrop]][id]++;
                client_cmd(id, "spk sound/avatar01/1.wav");
                ColorChat(id, Color:2, "%s ^1Nyitottál egy %s skint", C_Prefix, FegyverAdatok[LadaDrop6[kesdrop]][8]);
                set_dhudmessage(random(256), random(256), random(256), -1.0, 0.2, 0, 6.0, 3.0, 0.1, 1.5);
                show_dhudmessage(0, "%s^nNyitott egy:^n%s-t", nev, FegyverAdatok[LadaDrop6[kesdrop]][8]);
            }
            if (Szam >= 3.97 && Szam < 4.0)
            {
                meglevoek[LadaDrop6[9]][id]++;
                client_cmd(id, "spk sound/avatar01/1.wav");
                ColorChat(id, GREY, "%s ^3Nyitottál egy %s skint", C_Prefix, FegyverAdatok[LadaDrop6[9]][8]);
                set_dhudmessage(random(256), random(256), random(256), -1.0, 0.2, 0, 6.0, 3.0, 0.1, 1.5);
                show_dhudmessage(0, "%s^nNyitott egy:^n%s-t", nev, FegyverAdatok[LadaDrop6[9]][8]);
            }
        }
    }
    else
    {
        if (Szam >= 60.0 && Szam <= 100.0)
        {
            meglevoek[LadaDrop0[FegyverID0]][id]++;
            ColorChat(id, GREY, "%s ^3Nyitottál egy %s skint", C_Prefix, FegyverAdatok[LadaDrop0[FegyverID0]][8]);
        }
        else
        {
            if (Szam <= 60.0)
            {
                new liladrop = random_num(0, 16);
                meglevoek[LadaDrop0[liladrop]][id]++;
                ColorChat(id, Color:2, "%s ^4Nyitottál egy %s skint", C_Prefix, FegyverAdatok[LadaDrop0[liladrop]][8]);
            }
        }
    }
    LadaNyitas(id);
    return 0;
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

public Raktar_h(id, menu, item)
{
    if (item == -3)
    {
        menu_destroy(menu);
        return 0;
    }
    new data[9];
    new szName[64];
    new access;
    new callback;
    menu_item_getinfo(menu, item, access, data, 8, szName, 63, callback);
    new key = str_to_num(data);
    if (key != 134)
    {
        if (FegyverAdatok[key][0])
        {
            if (FegyverAdatok[key][0] == 1)
            {
                kivalasztott[id][1] = key;
            }
            if (FegyverAdatok[key][0] == 2)
            {
                kivalasztott[id][2] = key;
            }
            if (FegyverAdatok[key][0] == 3)
            {
                kivalasztott[id][3] = key;
            }
            if (FegyverAdatok[key][0] == 4)
            {
                kivalasztott[id][4] = key;
            }
            if (FegyverAdatok[key][0] == 5)
            {
                kivalasztott[id][5] = key;
            }
            if (FegyverAdatok[key][0] == 6)
            {
                kivalasztott[id][6] = key;
            }
            if (FegyverAdatok[key][0] == 7)
            {
                kivalasztott[id][7] = key;
            }
            if (FegyverAdatok[key][0] == 8)
            {
                kivalasztott[id][8] = key;
            }
            if (FegyverAdatok[key][0] == 9)
            {
                kivalasztott[id][9] = key;
            }
            if (FegyverAdatok[key][0] == 10)
            {
                kivalasztott[id][10] = key;
            }
        }
        else
        {
            kivalasztott[id][0] = key;
        }
    }
    else
    {
        vipkupon[id]--;
        Vip[id] = 1;
        ColorChat(id, BLUE, "%s ^1A vip kupon felhasználva lett!^3 -1 VIP kupon, +15Nap", C_Prefix);
        g_iVipTime[id] = get_systime() + 1296000;
        sql_update_account(id);
    }
    return 0;
}

public Kuka(id)
{
    new String[121];
    formatex(String, 120, "%s \r- \dSkin Gambling", Prefix);
    new menu = menu_create(String, "Kuka_h");
    new i;
    while (i <= 120)
    {
        if (0 < meglevoek[i][id])
        {
            new Sor[6];
            num_to_str(i, Sor, 5);
            formatex(String, 120, "%s \d[\r%d DB\d]", FegyverAdatok[i][8], meglevoek[i][id]);
            menu_additem(menu, String, Sor);
        }
        i++;
    }
    menu_display(id, menu);
    return 0;
}

public Kuka_h(id, menu, item)
{
    if (item == -3)
    {
        menu_destroy(menu);
        return 0;
    }
    new name[32];
    get_user_name(id, name, 31);
    new data[9];
    new szName[64];
    new access;
    new callback;
    menu_item_getinfo(menu, item, access, data, 8, szName, 63, callback);
    new key = str_to_num(data);
    meglevoek[key][id]--;
    if (FegyverAdatok[key][0])
    {
        if (FegyverAdatok[key][0] == 1)
        {
            kivalasztott[id][1] = 122;
        }
        if (FegyverAdatok[key][0] == 2)
        {
            kivalasztott[id][2] = 123;
        }
        if (FegyverAdatok[key][0] == 3)
        {
            kivalasztott[id][3] = 124;
        }
        if (FegyverAdatok[key][0] == 4)
        {
            kivalasztott[id][4] = 125;
        }
        if (FegyverAdatok[key][0] == 5)
        {
            kivalasztott[id][5] = 126;
        }
        if (FegyverAdatok[key][0] == 6)
        {
            kivalasztott[id][6] = 127;
        }
        if (FegyverAdatok[key][0] == 7)
        {
            kivalasztott[id][7] = 128;
        }
        if (FegyverAdatok[key][0] == 8)
        {
            kivalasztott[id][8] = 129;
        }
        if (FegyverAdatok[key][0] == 9)
        {
            kivalasztott[id][9] = 130;
        }
        if (FegyverAdatok[key][0] == 10)
        {
            kivalasztott[id][10] = 131;
        }
    }
    else
    {
        kivalasztott[id][0] = 121;
    }
    Dollar[id] += random_float(0.1, 1.0);
    Kulcs[id] += random(1);
    SMS[id] += random(1);
    ColorChat(id, BLUE, "%s ^1%s ^4Elgamblingeltel 1 ^3%s ^4skint,^1(^4a jutalmakat megkaptad.^1)", C_Prefix, name, FegyverAdatok[key][8]);
    Kuka(id);
    return 0;
}

public Piac(id)
{
    new String[121];
    new String2[121];
    static iTime;
    iTime = g_iTime[id] - get_systime();
    format(String, 120, "%s \r- \dPiac^n\dDollár: \r%3.2f $", Prefix, Dollar[id]);
    new menu = menu_create(String, "Piac_h");
    if (0 >= iTime)
    {
        if (Vip[id] == 1)
            formatex(String2, 120, "\r» \yNapi pörgetés\r [2DB]\y*VIP");
        else
            formatex(String2, 120, "\r» \yNapi pörgetés\r [1DB]");
    }
    else
    {
        formatex(String2, 120, "\r» \yNapi pörgetés\r [\w%d \yó\r|\w%02d \yp Még\r]", iTime / 3600, iTime / 60 % 60);
        
    }
    menu_additem(menu, String2, "1", 0);
    menu_additem(menu, "\r» \yFegyver Eladás", "2", 0);
    menu_additem(menu, "\r» \yFegyver Vásárlás", "3", 0);
    menu_additem(menu, "\r» \yTárgyak Küldése", "4", 0);
    menu_additem(menu, "\r» \yTárgyak Vásárlása", "5", 0);
    //nem volt benne valamiért
    //menu_additem(menu, "\r» \yKereskedés", "6", 0);
    menu_display(id, menu);
    return 0;
}

public Piac_h(id, menu, item)
{
    if (item == -3)
    {
        menu_destroy(menu);
        return 0;
    }
    new data[9];
    new szName[64];
    new access;
    new callback;
    static iTime;
    iTime = g_iTime[id] - get_systime();
    menu_item_getinfo(menu, item, access, data, 8, szName, 63, callback);
    new key = str_to_num(data);
    switch (key)
    {
        case 1:
        {
            if (0 >= iTime)
            {
                sorsolas(id);
            }
            else
            {
                ColorChat(id, BLUE, "%s ^3Te elérted a pörgetési limitet!", C_Prefix);
            }
        }
        case 2:
        {
            kicucc[id] = -1;
            Eladas(id);
        }
        case 3:
        {
            Vasarlas(id);
        }
        case 4:
        {
            SendMenu(id);
        }
        case 5:
        {
            ItemShop(id);
        }
        case 6:
        {
            KereskedesMenu(id);
        }
        default:
        {
        }
    }
    return 0;
}

public sorsolas(id)
{
    switch (random_num(1, 5))
    {
        case 1:
        {
            ColorChat(id, GREY, "Gratulálok!^4 5 DB kulcs ^3ütötte a markodat!");
            Kulcs[id] += 5;
        }
        case 2:
        {
            ColorChat(id, BLUE, "Ez nem a te napod! :[");
        }
        case 3:
        {
            ColorChat(id, GREY, "Gratulálok!^4 + 5 dolcsi^3ütötte a markodat!");
            Dollar[id] += 5.0;
        }
        case 4:
        {
            ColorChat(id, BLUE, "Ez nem a te napod! :[");
        }
        case 5:
        {
            ColorChat(id, GREY, "Gratulálok!^4 + 40 sms ^3ütötte a markodat!");
            SMS[id] += 40;
        }
        case 6:
        {
            new randomszam = random_num(0, 5);
            Lada[randomszam][id]++;
            ColorChat(id, GREY, "Gratulálok!^4 1DB %s ^3ütötte a markodat!", l_Nevek[randomszam]);
        }
        default:
        {
        }
    }
    vip_porgetes += 1;
    if (Vip[id] == 1 && vip_porgetes <= 1)
        Piac(id);
    else
        g_iTime[id] = get_systime() + 86400;
    sql_update_account(id);
}

public ItemShop(id)
{
    new String[256];
    format(String, 255, "\yTárgyak vásárlása");
    new menu = menu_create(String, "itemshop_h");
    menu_additem(menu, "\w»\y1DB Kulcs\r(\y2,45$\r)", "1", 0);
    menu_additem(menu, "\w»\yBronz Láda\r(\y0,90$\r)", "2", 0);
    menu_additem(menu, "\w»\ySzínözön Láda\r(\y1,65$\r)", "3", 0);
    menu_additem(menu, "\w»\yFalchion Láda\r(\y2,45$\r)", "4", 0);
    menu_additem(menu, "\w»\yOperation Breakout Láda\r(\y2,90$\r)", "5", 0);
    menu_additem(menu, "\w»\yPhoenix Láda\r(\y3,25$\r)", "6", 0);
    menu_additem(menu, "\w»\yHuntsman Láda\r(\y4,15$\r)", "7", 0);
    menu_additem(menu, "\w»\yÁrnyék Láda\r(\y5,00$\r)", "8", 0);
    menu_additem(menu, "\w»\ySms pont váltó\r(\y100sms\w->>\r10$)", "9", 0);
    menu_display(id, menu);
}

public itemshop_h(id, menu, item)
{
    if (item == -3)
    {
        menu_destroy(menu);
        return 0;
    }
    new data[9];
    new szName[64];
    new access;
    new callback;
    menu_item_getinfo(menu, item, access, data, 8, szName, 63, callback);
    new key = str_to_num(data);
    switch (key)
    {
        case 1:
        {
            if (Dollar[id] >= 2.45)
            {
                Dollar[id] -= 1.45;
                Kulcs[id]++;
                ColorChat(id, GREY, "%s ^3Sikeresen vettél^4 1 Kulcs^3-ot!", C_Prefix);
            }
            else
            {
                ColorChat(id, BLUE, "%s ^3Nincs elég dollárod!", C_Prefix);
            }
        }
        case 2:
        {
            if (Dollar[id] >= 0.9)
            {
                Lada[0][id]++;
                Dollar[id] -= 0.9;
                ColorChat(id, GREY, "%s ^3Sikeresen vettél^4 1 Bronz Ládát^3!", C_Prefix);
            }
            else
            {
                ColorChat(id, BLUE, "%s ^3Nincs elég dollárod!", C_Prefix);
            }
        }
        case 3:
        {
            if (Dollar[id] >= 1.65)
            {
                Lada[1][id]++;
                Dollar[id] -= 1.65;
                ColorChat(id, GREY, "%s ^3Sikeresen vettél^4 1 Színözön Ládát^3!", C_Prefix);
            }
            else
            {
                ColorChat(id, BLUE, "%s ^3Nincs elég dollárod!", C_Prefix);
            }
        }
        case 4:
        {
            if (Dollar[id] >= 2.45)
            {
                Lada[2][id]++;
                Dollar[id] -= 2.45;
                ColorChat(id, GREY, "%s ^3Sikeresen vettél^4 1 Falchion Ládát^3!", C_Prefix);
            }
            else
            {
                ColorChat(id, BLUE, "%s ^3Nincs elég dollárod!", C_Prefix);
            }
        }
        case 5:
        {
            if (Dollar[id] >= 2.9)
            {
                Lada[3][id]++;
                Dollar[id] -= 2.9;
                ColorChat(id, GREY, "%s ^3Sikeresen vettél^4 1 Operation Breakout Ládát^3!", C_Prefix);
            }
            else
            {
                ColorChat(id, BLUE, "%s ^3Nincs elég dollárod!", C_Prefix);
            }
        }
        case 6:
        {
            if (Dollar[id] >= 3.25)
            {
                Lada[4][id]++;
                Dollar[id] -= 3.25;
                ColorChat(id, GREY, "%s ^3Sikeresen vettél^4 1 Phoenix Ládát^3!", C_Prefix);
            }
            else
            {
                ColorChat(id, BLUE, "%s ^3Nincs elég dollárod!", C_Prefix);
            }
        }
        case 7:
        {
            if (Dollar[id] >= 4.15)
            {
                Lada[5][id]++;
                Dollar[id] -= 4.15;
                ColorChat(id, GREY, "%s ^3Sikeresen vettél^4 1 Huntsman Ládát^3!", C_Prefix);
            }
            else
            {
                ColorChat(id, BLUE, "%s ^3Nincs elég dollárod!", C_Prefix);
            }
        }
        case 8:
        {
            if (Dollar[id] >= 5.0)
            {
                Lada[6][id]++;
                Dollar[id] -= 5.0;
                ColorChat(id, GREY, "%s ^3Sikeresen vettél^4 1 Árnyék Ládát^3!", C_Prefix);
            }
            else
            {
                ColorChat(id, BLUE, "%s ^3Nincs elég dollárod!", C_Prefix);
            }
        }
        case 9:
        {
            if (Dollar[id] >= 100.0)
            {
                SMS[id] -= 100;
                Dollar[id] -= 100.0;
                ColorChat(id, GREY, "%s ^3Sikeresen müvelet", C_Prefix);
            }
            else
            {
                ColorChat(id, BLUE, "%s ^3Nincs elég dollárod!", C_Prefix);
            }
        }
        default:
        {
        }
    }
    ItemShop(id);
    return 0;
}

public Eladas(id)
{
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
    if(Erteke[id] != 0.0 && kirakva[id] == 0)
    {
        menu_additem(menu,"Mehet a piacra!","2",0);
    }
    if(Erteke[id] != 0.0 && kirakva[id] == 1)
        menu_additem(menu,"\wVisszavonás","-2",0);

    menu_setprop(menu, MPROP_EXITNAME, "Kilépés");
    menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
    menu_display(id, menu, 0);
}

public eladas_h(id, menu, item)
{
    if (item == -3)
    {
        menu_destroy(menu);
        return 1;
    }
    new data[9];
    new szName[64];
    new name[32];
    get_user_name(id, name, 31);
    new access;
    new callback;
    menu_item_getinfo(menu, item, access, data, 8, szName, 63, callback);
    new key = str_to_num(data);
    switch (key)
    {
        case -2:
        {
            kirakva[id] = 0;
            kicucc[id] = 0;
            Erteke[id] = 0.0;
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
            new i;
            while (i <= 120)
            {
                if (i == kicucc[id])
                {
                    ColorChat(0, Color:2, "%s ^3%s ^1Kirakott egy ^4%s^1 nevü itemet^4 %3.2f ^1dollárért", C_Prefix, name, PiacTargy[i], Erteke[id]);
                    kirakva[id] = 1;
                }
                i++;
            }
        }
        default:
        {
        }
    }
    return 1;
}


stock get_player_name(id){
    static name[32];
    get_user_name(id,name,31);
    return name;
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
					formatex(mpont, 256, "\y%s \w%s\d[Ára: \r%3.2f $\d]", PiacTargy[a], get_player_name(players[i]), Erteke[players[i]]);
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

public vasarlas_h(id, menu, item)
{
    if (item == -3)
    {
        menu_destroy(menu);
        return 0;
    }
    if (pido)
    {
        Vasarlas(id);
        return 0;
    }
    new data[6];
    new szName[64];
    new access;
    new callback;
    new name[32];
    new name2[32];
    get_user_name(id, name, 31);
    menu_item_getinfo(menu, item, access, data, 5, szName, 63, callback);
    new player = str_to_num(data);
    get_user_name(player, name2, 31);
    pido = 2;
    set_task(2.0, "vido");
    new i;
    while (i <= 120)
    {
        if (Dollar[id] >= Erteke[player] && i == kicucc[player] && kirakva[player] == 1)
        {
            kirakva[player] = 0;
            ColorChat(0, Color:2, "%s ^3%s ^1vett egy ^4%s^1-t ^3%s^1-tól ^4%3.2f ^1Dollárért!", C_Prefix, name, PiacTargy[i], name2, Erteke[player]);
            Dollar[player] += Erteke[player];
            Dollar[id] -= Erteke[player];
            meglevoek[i][id] ++;
            meglevoek[i][player] --;
            kicucc[player] = 0;
            Erteke[player] = 0.0;
            if (FegyverAdatok[kicucc[id]][0])
            {
                if (FegyverAdatok[kicucc[id]][0] == 1)
                {
                    kivalasztott[id][1] = 122;
                }
                if (FegyverAdatok[kicucc[id]][0] == 2)
                {
                    kivalasztott[id][2] = 123;
                }
                if (FegyverAdatok[kicucc[id]][0] == 3)
                {
                    kivalasztott[id][3] = 124;
                }
                if (FegyverAdatok[kicucc[id]][0] == 4)
                {
                    kivalasztott[id][4] = 125;
                }
                if (FegyverAdatok[kicucc[id]][0] == 5)
                {
                    kivalasztott[id][5] = 126;
                }
                if (FegyverAdatok[kicucc[id]][0] == 6)
                {
                    kivalasztott[id][6] = 127;
                }
                if (FegyverAdatok[kicucc[id]][0] == 7)
                {
                    kivalasztott[id][7] = 128;
                }
                if (FegyverAdatok[kicucc[id]][0] == 8)
                {
                    kivalasztott[id][8] = 129;
                }
                if (FegyverAdatok[kicucc[id]][0] == 9)
                {
                    kivalasztott[id][9] = 130;
                }
                if (FegyverAdatok[kicucc[id]][0] == 10)
                {
                    kivalasztott[id][10] = 131;
                }
            }
            kivalasztott[id][0] = 121;
        }
        i++;
    }
    return 0;
}

public fvalaszt(id)
{
    new szMenuTitle[121];
    new cim[121];
    format(szMenuTitle, 120, "\dVálassz Fegyvert");
    new menu = menu_create(szMenuTitle, "fvalaszt_h");
    new i;
    while (i <= 120)
    {
        if (0 < meglevoek[i][id])
        {
            new Num[6];
            num_to_str(i, Num, 5);
            formatex(cim, 120, "%s \d[\r%d DB\d]", PiacTargy[i], meglevoek[i][id]);
            menu_additem(menu, cim, Num);
        }
        i++;
    }
    menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
    menu_display(id, menu);
    return 0;
}

public fvalaszt_h(id, menu, item)
{
    if (item == -3)
    {
        menu_destroy(menu);
        return 0;
    }
    new data[9];
    new szName[64];
    new access;
    new callback;
    menu_item_getinfo(menu, item, access, data, 8, szName, 63, callback);
    new key = str_to_num(data);
    kicucc[id] = key;
    Eladas(id);
    return 0;
}

public SendMenu(id)
{
    new String[121];
    format(String, 120, "\dTárgyak Küldése");
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
}

public SendHandler(id, Menu, item)
{
    if (item == -3)
    {
        menu_destroy(Menu);
        return 1;
    }
    new Data[9];
    new szName[64];
    new access;
    new callback;
    menu_item_getinfo(Menu, item, access, Data, 8, szName, 63, callback);
    new Key = str_to_num(Data);
    Send[id] = Key + 1;
    PlayerChoose(id);
    return 1;
}

public PlayerChoose(id)
{
    new String[121];
    format(String, 120, "\dVálassz Játékost");
    new Menu = menu_create(String, "PlayerHandler");
    new players[32], pnum, tempid;
    new szName[32], szTempid[10];
    get_players(players, pnum);
    new i;
    while (i < pnum)
    {
        tempid = players[i];
        get_user_name(tempid, szName, 31);
        num_to_str(tempid, szTempid, 9);
        menu_additem(Menu, szName, szTempid);
        i++;
    }
    menu_display(id, Menu);
}

public PlayerHandler(id, Menu, item)
{
    if (item == -3)
    {
        menu_destroy(Menu);
        return 1;
    }
    new Data[6];
    new szName[64];
    new access;
    new callback;
    menu_item_getinfo(Menu, item, access, Data, 5, szName, 63, callback);
    TempID = str_to_num(Data);
    if (addolasikulcs == 1000)
    {
        if (accountpause == 1)
        {
            client_cmd(id, "messagemode FUGGESZTESI_INDOK");
        }
        else
        {
            if (!accountpause)
            {
                sqltorolfelfuggesztfiok(id);
            }
        }
    }
    else
    {
        client_cmd(id, "messagemode KMENNYISEG");
    }
    menu_destroy(Menu);
    return 1;
}

public sqltorolfelfuggesztfiok(id)
{
    static Query[256];
    new a[191];
    format(a, 190, "%s", g_Felhasznalonev[TempID]);
    replace_all(a, 190, "\", "\\");
    replace_all(a, 190, "'", "\'");
    formatex(Query, 255, "UPDATE rwt_sql_register_new_s5 SET AccountPause = '0', AccountPauseReason = ' ', AccountPauseAdmin = ' ' WHERE Felhasznalonev = '%s'", a);
    new Data[2];
    Data[0] = id;
    Data[1] = get_user_userid(id);
    SQL_ThreadQuery(g_SqlTuple, "sqltorolfelfuggesztfiok_thread", Query, Data, 2);
    return 0;
}

public sqltorolfelfuggesztfiok_thread(FailState, Handle:Query, Error[], Errcode, Data[], DataSize)
{
    if (FailState == -2)
    {
        return set_fail_state("[ *HIBA* ] NEM LEHET KAPCSOLODNI AZ ADATBAZISHOZ!");
    }
    if (FailState == -1)
    {
        return set_fail_state("[ *HIBA* ] A LEKERDEZES MEGSZAKADT!");
    }
    if (Errcode)
    {
        return log_amx("[ *HIBA* ] PROBLEMA A LEKERDEZESNEL! ( %s )", Error);
    }
    new id = Data[0];
    if (get_user_userid(id) != Data[1])
    {
        return 1;
    }
    ColorChat(id, GREY, "%s^4 %s ^1Címzetü fiók fel lett^3 oldva^1!", C_Prefix, g_Felhasznalonev[TempID]);
    return 0;
}

public sqlfelfuggesztfiok(id)
{
    static Query[256];
    new a[191];
    new b[191];
    new adminnev[33];
    get_user_name(id, adminnev, 32);
    format(a, 190, "%s", g_Felhasznalonev[TempID]);
    format(b, 190, "%s", g_Indok[id]);
    replace_all(a, 190, "\", "\\");
    replace_all(a, 190, "'", "\'");
    replace_all(b, 190, "\", "\\");
    replace_all(b, 190, "'", "\'");
    formatex(Query, 255, "UPDATE rwt_sql_register_new_s5 SET AccountPause = '1', AccountPauseReason = '%s', AccountPauseAdmin = '%s' WHERE Felhasznalonev = '%s'", b, adminnev, a);
    new Data[2];
    Data[0] = id;
    Data[1] = get_user_userid(id);
    SQL_ThreadQuery(g_SqlTuple, "sql_account_pause_thread", Query, Data, 2);
    return 0;
}

public sql_account_pause_thread(FailState, Handle:Query, Error[], Errcode, Data[], DataSize)
{
    if (FailState == -2)
    {
        return set_fail_state("[ *HIBA* ] NEM LEHET KAPCSOLODNI AZ ADATBAZISHOZ!");
    }
    if (FailState == -1)
    {
        return set_fail_state("[ *HIBA* ] A LEKERDEZES MEGSZAKADT!");
    }
    if (Errcode)
    {
        return log_amx("[ *HIBA* ] PROBLEMA A LEKERDEZESNEL! ( %s )", Error);
    }
    new id = Data[0];
    if (get_user_userid(id) != Data[1])
    {
        return 1;
    }
    g_Bejelentkezve[TempID] = false;
    new adminnev[33];
    get_user_name(id, adminnev, 32);
    ColorChat(id, BLUE, "%s^4 %s ^1Címzetü fiók fel lett függesztve!^3 ||^1Indok:^4 %s", C_Prefix, g_Felhasznalonev[TempID], g_Indok[id]);
    ColorChat(TempID, BLUE, "%s ^3Fiókod fel lett függesztve!^1 ||^3Indok:^4 %s ^1||^3Admin:^4 %s", C_Prefix, g_Indok[id], adminnev);
    return 0;
}

public KereskedesMenu(id)
{
    if (!KerDB[id])
    {
        Targy[id] = -1;
    }
    new String[96];
    new kid;
    new menu;
    new kNev[32];
    if (0 < JelolID[id])
    {
        kid = JelolID[id];
    }
    else
    {
        kid = KerID[id];
    }
    get_user_name(kid, kNev, 31);
    if (Keres[id] == 1)
    {
        format(String, 95, "\r%s\y szeretne veled kereskedni!", kNev);
    }
    else
    {
        if (Kereskedik[id] == 1 && Kereskedik[kid] == 1)
        {
            format(String, 95, "\d- \y%s \rtárgyai \d-", kNev);
        }
        format(String, 95, "\wKereskedés \rDollár:\d %3.2f$", Dollar[id]);
    }
    menu = menu_create(String, "KereskedesMenuh");
    if (Keres[id] == 1)
    {
        format(String, 95, "\yElfogad");
        menu_additem(menu, String, "-3");
        format(String, 95, "\yElutasít");
        menu_additem(menu, String, "-2");
    }
    else
    {
        if (Kereskedik[id] == 1 && Kereskedik[kid] == 1)
        {
            if (Targy[kid] == -1)
            {
                format(String, 95, "\dSemmi");
            }
            else
            {
                if (0 <= Targy[kid])
                {
                    format(String, 95, "\y%s \r(\d%d\r darab)", PiacTargy[Targy[kid]], KerDB[kid]);
                }
            }
            menu_additem(menu, String, "0");
            format(String, 95, "\rDollár: \d%3.2f$^n^n", KerDollar[kid]);
            menu_additem(menu, String, "0");
            if (Targy[id] == -1)
            {
                format(String, 95, "\dSemmi");
            }
            else
            {
                if (0 <= Targy[id])
                {
                    format(String, 95, "\y%s \r(\d%d\r darab)", PiacTargy[Targy[id]], KerDB[id]);
                }
            }
            menu_additem(menu, String, "-4");
            format(String, 95, "\rDollár: \d%3.2f$^n", KerDollar[id]);
            menu_additem(menu, String, "-5");
            format(String, 95, "\yElfogad");
            menu_additem(menu, String, "-6");
            format(String, 95, "\rElutasít");
            menu_additem(menu, String, "-7");
        }
        new i;
        while (i < 33)
        {
            new namefasz[32];
            new NumToStr[6];
            if (is_user_connected(i))
            {
                if (!(id == i))
                {
                    if (Keres[i] && Kereskedik[i])
                    {
                        get_user_name(i, namefasz, 32);
                        num_to_str(i, NumToStr, 5);
                        format(String, 95, "%s", namefasz);
                        menu_additem(menu, String, NumToStr);
                    }
                }
                i++;
            }
            i++;
        }
    }
    menu_display(id, menu);
    return 0;
}

public KereskedesMenuh(id, menu, item)
{
    if (item == -3)
    {
        menu_destroy(menu);
        return 1;
    }
    new data[9];
    new szName[64];
    new access;
    new callback;
    menu_item_getinfo(menu, item, access, data, 8, szName, 63, callback);
    new key = str_to_num(data);
    if (0 >= key)
    {
        switch (key)
        {
            case -7:
            {
                new kid;
                if (0 < JelolID[id])
                {
                    kid = JelolID[id];
                }
                else
                {
                    kid = KerID[id];
                }
                Kereskedik[id] = 0;
                JelolID[id] = 0;
                Keres[id] = 0;
                KerID[id] = 0;
                Kereskedik[kid] = 0;
                JelolID[kid] = 0;
                Keres[kid] = 0;
                KerID[kid] = 0;
            }
            case -6:
            {
                new kid;
                if (0 < JelolID[id])
                {
                    kid = JelolID[id];
                }
                else
                {
                    kid = KerID[id];
                }
                Fogad[id] = 1;
                if (Fogad[id] == 1 && Fogad[kid] == 1)
                {
                    Csere(id, kid);
                }
                else
                {
                    KereskedesMenu(id);
                }
            }
            case -5:
            {
                new Cmd[32];
                format(Cmd, 31, "messagemode DOLLAR2");
                client_cmd(id, Cmd);
            }
            case -4:
            {
                KerFegyverek(id);
            }
            case -3:
            {
                Keres[id] = 0;
                Kereskedik[id] = 1;
                new kid;
                if (0 < JelolID[id])
                {
                    kid = JelolID[id];
                }
                else
                {
                    kid = KerID[id];
                }
                Kereskedik[kid] = 1;
                ColorChat(kid, GREY, "%s ^3A másik fél elfogadta a kereskedést!", C_Prefix);
                KerDB[id] = 0;
                KerDB[kid] = 1;
                kirakva[id] = 0;
                kirakva[kid] = 0;
                KereskedesMenu(id);
                KereskedesMenu(kid);
            }
            case -2:
            {
                new kid;
                if (0 < JelolID[id])
                {
                    kid = JelolID[id];
                }
                else
                {
                    kid = KerID[id];
                }
                ColorChat(kid, BLUE, "%s ^3A másik fél elutasította a kereskedést!", C_Prefix);
                Kereskedik[id] = 0;
                JelolID[id] = 0;
                Keres[id] = 0;
                Kereskedik[kid] = 0;
                KerID[kid] = 0;
            }
            case 0:
            {
                KereskedesMenu(id);
            }
            default:{}
        }
    }
    else
    {
        new String[128];
        new namefasz[32];
        get_user_name(id, namefasz, 31);
        KerID[id] = key;
        message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, KerID[id]);
        write_byte(KerID[id]);
        format(String, 127, "4[*Avatar#]^3 %s^1 szeretne veled kereskedni!", namefasz);
        write_string(String);
        message_end();
        ColorChat(id, GREY, "^4[*Avatar#]^3 Várakozás a másik fél választására...");
        KereskedesMenu(id);
        Keres[key] = 1;
        Keres[id] = 0;
        Kereskedik[id] = 0;
        JelolID[key] = id;
        set_task(30.0, "KerNulla", KerID[id]);
    }
    return 1;
}

public KerNulla(id)
{
    if (is_user_connected(id))
    {
        if (!Kereskedik[id])
        {
            Kereskedik[id] = 0;
            JelolID[id] = 0;
            Keres[id] = 0;
        }
    }
    return 0;
}

public Csere(x, y)
{
    if ((is_user_connected(x) && is_user_connected(y)) || (Kereskedik[x] == 1 && Kereskedik[y] == 1) || (Fogad[x] == 1 && Fogad[y] == 1))
    {
        if (Targy[x] >= 0 && Targy[x] <= 120)
        {
            meglevoek[Targy[x]][x] -= KerDB[x];
            meglevoek[Targy[x]][y] += KerDB[x];
            if (FegyverAdatok[Targy[x]][0])
            {
                if (FegyverAdatok[Targy[x]][0] == 1)
                {
                    kivalasztott[x][1] = 122;
                }
                if (FegyverAdatok[Targy[x]][0] == 2)
                {
                    kivalasztott[x][2] = 123;
                }
                if (FegyverAdatok[Targy[x]][0] == 3)
                {
                    kivalasztott[x][3] = 124;
                }
                if (FegyverAdatok[Targy[x]][0] == 4)
                {
                    kivalasztott[x][4] = 125;
                }
                if (FegyverAdatok[Targy[x]][0] == 5)
                {
                    kivalasztott[x][5] = 126;
                }
                if (FegyverAdatok[Targy[x]][0] == 6)
                {
                    kivalasztott[x][6] = 127;
                }
                if (FegyverAdatok[Targy[x]][0] == 7)
                {
                    kivalasztott[x][7] = 128;
                }
                if (FegyverAdatok[Targy[x]][0] == 8)
                    {
                        kivalasztott[x][8] = 129;
                    }
                if (FegyverAdatok[Targy[x]][0] == 9)
                {
                    kivalasztott[x][9] = 130;
                }
                if (FegyverAdatok[Targy[x]][0] == 10)
                {
                    kivalasztott[x][10] = 131;
                }
            }
            else
            {
                kivalasztott[x][0] = 121;
            }
        }
        else
        {
            if (Targy[x] > 120 && Targy[x] != 128)
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
            if (Targy[x] == 128)
            {
                Kulcs[x] -= KerDB[x];
                Kulcs[y] += KerDB[x];
            }
        }
        if (Targy[y] >= 0 && Targy[y] <= 120)
        {
            meglevoek[Targy[y]][x] += KerDB[y];
            meglevoek[Targy[y]][y] -= KerDB[y];
            if (FegyverAdatok[Targy[y]][0])
            {
                if (FegyverAdatok[Targy[y]][0] == 1)
                {
                    kivalasztott[y][1] = 122;
                }
                if (FegyverAdatok[Targy[y]][0] == 2)
                {
                    kivalasztott[y][2] = 123;
                }
                if (FegyverAdatok[Targy[y]][0] == 3)
                {
                    kivalasztott[y][3] = 124;
                }
                if (FegyverAdatok[Targy[y]][0] == 4)
                {
                    kivalasztott[y][4] = 125;
                }
                if (FegyverAdatok[Targy[y]][0] == 5)
                {
                    kivalasztott[y][5] = 126;
                }
                if (FegyverAdatok[Targy[y]][0] == 6)
                {
                    kivalasztott[y][6] = 127;
                }
                if (FegyverAdatok[Targy[y]][0] == 7)
                {
                    kivalasztott[y][7] = 128;
                }
                if (FegyverAdatok[Targy[y]][0] == 8)
                {
                    kivalasztott[y][8] = 129;
                }
                if (FegyverAdatok[Targy[y]][0] == 9)
                {
                    kivalasztott[y][9] = 130;
                }
                if (FegyverAdatok[Targy[y]][0] == 10)
                {
                    kivalasztott[y][10] = 131;
                }
            }
            else
            {
                kivalasztott[y][0] = 121;
            }
        }
        else
        {
            if (Targy[y] > 120 && Targy[y] != 128)
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
            if (Targy[y] == 128)
            {
                Kulcs[x] += KerDB[y];
                Kulcs[y] -= KerDB[y];
            }
        }
        
        Dollar[x] += KerDollar[y];// + 0.009
        Dollar[y] += KerDollar[x];// + 0.009
        Dollar[x] -= KerDollar[x];// + 0.009
        Dollar[y] -= KerDollar[y];// + 0.009

        log_to_file("csere.txt", "%d (%d), %3.2f, %s - %d (%d), %3.2f, %s", Targy[x], KerDB[x], KerDollar[x], g_Felhasznalonev[x], Targy[y], KerDB[y], KerDollar[y], g_Felhasznalonev[y]);
        new String[96];
        message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, x);
        write_byte(x);
        format(String, 95, "^4[*Avatar#]^1 A kereskedés sikeres volt!");
        write_string(String);
        message_end();
        message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, y);
        write_byte(y);
        format(String, 95, "^4[*Avatar#]^1 A kereskedés sikeres volt!");
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
    return 0;
}

public KerFegyverek(id)
{
    new String[96];
    format(String, 95, "Válasz egy tárgyat!", Dollar[id]);
    new menu = menu_create(String, "KerFegyverekh");
    new i;
    while (i <= 120)
    {
        if (1 < meglevoek[i][id])
        {
            if (!(i == kicucc[id]))
            {
                new NumToString[6];
                num_to_str(i, NumToString, 5);
                format(String, 95, "%s \r(%d)", FegyverAdatok[i][8], meglevoek[i][id]);
                menu_additem(menu, String, NumToString);
            }
            i++;
        }
        i++;
    }
    if (0 < Kulcs[id])
    {
        if (kicucc2[id] == 9)
        {
            return 0;
        }
        format(String, 95, "Kulcs \r(%d)", Kulcs[id]);
        menu_additem(menu, String, "128");
    }
    menu_display(id, menu);
    return 1;
}

public KerFegyverekh(id, menu, item)
{
    if (item == -3)
    {
        menu_destroy(menu);
        return 1;
    }
    new data[9];
    new szName[64];
    new access;
    new callback;
    menu_item_getinfo(menu, item, access, data, 8, szName, 63, callback);
    new key = str_to_num(data);
    if (key == 128)
    {
        Targy[id] = key;
        new Cmd[32];
        format(Cmd, 31, "messagemode DARAB");
        client_cmd(id, Cmd);
    }
    else
    {
        if (key <= 120)
        {
            if (1 < meglevoek[key][id])
            {
                Targy[id] = key;
                new Cmd[32];
                format(Cmd, 31, "messagemode DARAB");
                client_cmd(id, Cmd);
            }
        }
        if (key < 128)
        {
            if (1 < Lada[key + -121][id])
            {
                Targy[id] = key;
                new Cmd[32];
                format(Cmd, 31, "messagemode DARAB");
                client_cmd(id, Cmd);
            }
        }
    }
    return 1;
}

public kDollar(id)
{
    if (Kereskedik[id])
    {
        new Float:Ertek = 0.0;
        new Adat[32];
        new kid;
        read_args(Adat, 31);
        remove_quotes(Adat);
        Ertek = str_to_float(Adat);
        if (0 < JelolID[id])
        {
            kid = JelolID[id];
        }
        else
        {
            kid = KerID[id];
        }
        if (Ertek <= 0.0)
        {
            new Cmd[32];
            format(Cmd, 31, "messagemode DOLLAR2");
            client_cmd(id, Cmd);
        }
        else
        {
            if (Dollar[id] >= Ertek)
            {
                KerDollar[id] = Ertek + 0.009;
                KereskedesMenu(id);
                KereskedesMenu(kid);
                Fogad[id] = 0;
                Fogad[kid] = 0;
            }
            KerDollar[id] = Dollar[id] + 0.009;
            KereskedesMenu(id);
            KereskedesMenu(kid);
            Fogad[id] = 0;
            Fogad[kid] = 0;
        }
        return 1;
    }
    return 1;
}

public lekeres(id)
{
    new Float:ertek = 0.0;
    new adatok[32];
    read_args(adatok, 31);
    remove_quotes(adatok);
    ertek = str_to_float(adatok);
    new hossz = strlen(adatok);
    if (hossz > 7)
    {
        client_cmd(id, "messagemode DOLLAR");
    }
    else
    {
        if (ertek < 5.0)
        {
            ColorChat(id, BLUE, "%s ^1Nem tudsz eladni fegyvert^3 5 Dollár ^1alatt.", C_Prefix);
            Eladas(id);
        }
        Erteke[id] = ertek + 0.009;
        Eladas(id);
    }
    return 0;
}

public vido()
{
    pido = 0;
    return 0;
}

public client_disconnected(id)
{
    client_cmd(id, "echo ^"Azonosító: %d^"", g_Id[id]);
    client_cmd(id, "echo ^"/_/_/_/_/_/_/_/_/_/_/_/_/_/^"");
    g_Aktivitas[id] = 0;
    g_Folyamatban[id] = 0;
    if (g_Bejelentkezve[id])
    {
        sql_update_account(id);
    }
    g_Bejelentkezve[id] = false;
    g_Felhasznalonev[id][0] = 0;
    g_Jelszo[id][0] = 0;
    g_Email[id][0] = 0;
    g_JelszoRegi[id][0] = 0;
    g_JelszoUj[id][0] = 0;
    g_Id[id] = 0;
    Dollar[id] = 0.0;
    Rang[id] = 0;
    Oles[id] = 0;
    Vip[id] = 0;
    Kulcs[id] = 0;
    g_Erem[id] = 0;
    SMS[id] = 0;
    g_Quest[id] = 0;
    g_QuestWeapon[id] = 0;
    g_QuestHead[id] = 0;
    g_QuestMVP[id] = 0;
    Masodpercek[id] = 0;
    new kid;
    if (0 < JelolID[id])
    {
        kid = JelolID[id];
    }
    else
    {
        if (0 < KerID[id])
        {
            kid = KerID[id];
        }
    }
    Kereskedik[id] = 0;
    KerDollar[id] = 0.0;
    Keres[id] = 0;
    JelolID[id] = 0;
    Targy[id] = -1;
    KerID[id] = 0;
    if (0 < kid)
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

    for(new i=0;i < 7; i++)
        Lada[i][id] = 0;
    copy(name[id], charsmax(name[]), "");
}

public f_save(id)
{
    new szData[128];
    new steamid[32];
    get_user_authid(id, steamid, 31);
    if (contain(steamid, "_ID_LAN") != -1)
    {
        get_user_ip(id, steamid, 31, 1);
    }
    formatex(szData, 127, "%s %s", g_Felhasznalonev[id], g_Jelszo[id]);
    set_data(steamid, szData);
    return 0;
}

public client_putinserver(id)
{
    g_Bejelentkezve[id] = false;
    Gun[0][id] = 1;
    Hud[id] = 1;
    Vip[id] = 0;
    kivalasztott[id][0] = 121;
    kivalasztott[id][1] = 122;
    kivalasztott[id][2] = 123;
    kivalasztott[id][3] = 124;
    kivalasztott[id][4] = 125;
    kivalasztott[id][5] = 126;
    kivalasztott[id][6] = 127;
    kivalasztott[id][7] = 128;
    kivalasztott[id][8] = 129;
    kivalasztott[id][9] = 130;
    kivalasztott[id][10] = 131;
}

public client_connect(id)
{
    VanPrefix[id] = 0;
    get_user_info(id, "fovs", g_trickban[id], 99);
    if (equal(g_trickban[id], "yes"))
    {
        new uID = get_user_userid(id);
        server_cmd("kick #%d ^"Bannolva lettel!Tovabbi infok a konzolban!^"", uID);
    }
    return 0;
}

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
    new message[300];
    new Name[32];
    new chat[300];
    new sid[32];
    read_args(message, 191);
    remove_quotes(message);
    if (message[0] == 64 || message[0] == 47 || message[0] == 35 || message[0] == 33 || equal(message, ""))
        return 1;
    
    get_user_team(id, color, 9);
    get_user_authid(id, sid, 31);
    if (get_user_flags(id) & 262144 && g_Bejelentkezve[id] == true)
    {
        formatex(chat, 191, "^1*Halott*^4[Tulajdonos][%s]-[%s]^3 %s^1: ^3%s", Ct_Prefix[id], Rangok[Rang[id]], Name, message);
    }
    if (get_user_flags(id) & 131072 && g_Bejelentkezve[id] == true)
    {
        formatex(chat, 191, "^1*Halott*^4[Prémium V.I.P.][%s][%s]^3 %s^4: %s", Ct_Prefix[id], Rangok[Rang[id]], Name, message);
    }
    if (get_user_flags(id) & 65536 && Vip[id] >= 1 && g_Bejelentkezve[id] == true)
    {
        formatex(chat, 191, "^1*Halott*^4[Admin][Vip][%s][%s]^3 %s^4: %s", Ct_Prefix[id], Rangok[Rang[id]], Name, message);
    }
    if (get_user_flags(id) & 65536 && g_Bejelentkezve[id] == true)
    {
        formatex(chat, 191, "^4[Admin][%s][%s]^3%s^4: %s", Ct_Prefix[id], Rangok[Rang[id]], Name, message);
    }
    if (Vip[id] >= 1 && s_addvariable[id] == 1 && g_Bejelentkezve[id] == true)
    {
        formatex(chat, 191, "^1*Halott*^4[VIP][Segítő][%s][%s]^3%s^4: %s", Ct_Prefix[id], Rangok[Rang[id]], Name, message);
    }
    if (Vip[id] >= 1 && g_Bejelentkezve[id] == true)
    {
        formatex(chat, 191, "^1*Halott*^4[VIP][%s][%s]^3%s^4: %s", Ct_Prefix[id], Rangok[Rang[id]], Name, message);
    }
    if (s_addvariable[id] >= 1 && g_Bejelentkezve[id] == true)
    {
        formatex(chat, 191, "^1*Halott*^4[Segítő][%s][%s]^3%s^1: %s", Ct_Prefix[id], Rangok[Rang[id]], Name, message);
    }
    if (g_Bejelentkezve[id] == true)
    {
        formatex(chat, 191, "^1*Halott*^4[%s]-[%s]^3 %s^1: %s", Ct_Prefix[id], Rangok[Rang[id]], Name, message);
    }
    if (!g_Bejelentkezve[id])
    {
        formatex(chat, 191, "^1*Halott*^4[Kijelentkezve]^3 %s^1: %s", Name, message);
    }
    switch (cs_get_user_team(id))
    {
        case 1:
        {
            ColorChat(0, BLUE, chat);
        }
        case 2:
        {
            ColorChat(0, GREY, chat);
        }
        default:
        {
        }
    }
    if (cs_get_user_team(id) == CS_TEAM_SPECTATOR)
    {
        ColorChat(0, GREY, chat);
    }
    return 1;
}

public sendmessage(color[])
{
    new teamName[10];
    new player = 1;
    while (get_maxplayers() > player)
    {
        get_user_team(player, teamName, 9);
        teamf(player, color);
        elkuldes(player, Temp);
        teamf(player, teamName);
        player++;
    }
    return 0;
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

public plugin_end()
{
    SQL_FreeHandle(g_SqlTuple);
}
