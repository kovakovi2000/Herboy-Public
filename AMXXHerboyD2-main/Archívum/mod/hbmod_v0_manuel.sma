#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <sqlx>
#include <fakemeta>
#include <fun>
#include <cstrike>
#include <hamsandwich>
#include <xs>
#include <regex> 
#include <sheditime>

#define PLUGIN "GlobalOffensiveMod"
#define VERSION "1.0"
#define AUTHOR "|AK26|manuell - egy kutya"

#define JATEKOSOK 33

#pragma semicolon 1

new Prefix[80] = "!g[!n~!g|!tGlobalOffensive!g|!n~!g]", MenuPrefix[40] = "[~|GlobalOffensive|~]", Hiba[JATEKOSOK][1000], Jelszo[JATEKOSOK][50], Jelszo2[JATEKOSOK][50], JelszoSQL[JATEKOSOK][50], Bekelllepni[JATEKOSOK], Handle:SQLTuple, Olesek[JATEKOSOK], Float:Penz[JATEKOSOK], STEAMID[JATEKOSOK][40], NEV[JATEKOSOK][100], Belepett[JATEKOSOK], Adminvagy[JATEKOSOK], AdminElrejt[JATEKOSOK], JatekosPrefix[JATEKOSOK][40];
new KillFade[JATEKOSOK], Kinezetek[JATEKOSOK], Ejtoernyo[JATEKOSOK], HUD[JATEKOSOK], Sebzeskijelzo[JATEKOSOK], Duplaugras[JATEKOSOK], SebzesTart[JATEKOSOK], Jogok[JATEKOSOK][100], ModJogok[JATEKOSOK][100], IP[JATEKOSOK][100];
new JelenlegiFegyo[JATEKOSOK][35], JatekosFegyverOsszes[JATEKOSOK][31], SzerverMapok[100][31], SzerverMapokSzama, JatekosFegyo[JATEKOSOK][400], Betoltott[JATEKOSOK];
new KivalasztottMap[JATEKOSOK], KivalasztottKorok[JATEKOSOK], Masodpercek[JATEKOSOK], Vip[JATEKOSOK], Felhasznalonev[33][32];
new AdminMap, AdminMapKor = -1, AdminMapNeve[100], Korok_szama = 0, Resi = 48, Terfel = 24;
new AdminIP[100], SzuperAdmin[JATEKOSOK], NemitasLejar[JATEKOSOK][2], JatekosID[JATEKOSOK], Felcsatlakozasido[JATEKOSOK], Nemito[JATEKOSOK][2][100], NemitasIndok[JATEKOSOK][2][130], Ugras[JATEKOSOK], bool:UgrasMost[JATEKOSOK];
new Offset[JATEKOSOK], TablaNev[60], MaxIP, regelnikell[33], adminmutetype[33];
new Fegyok[31][400], FegyokSzama[31], Sorred[31];
new KivalasztottEredmeny[JATEKOSOK][16][300];
new KivalasztottAdminEredmenyUJ[JATEKOSOK][7][120];
new Indok[JATEKOSOK][120], Ido[JATEKOSOK], IdoForma[JATEKOSOK], KivalasztottTipus[JATEKOSOK], KivalasztottNev[JATEKOSOK][40];
new Celzas[JATEKOSOK], PiacJatekos[JATEKOSOK][3], Float:PiacJatekosPenz[JATEKOSOK];
new EjtoernyoEntity[JATEKOSOK], EjtoernyoJelnleg[JATEKOSOK], RangNevek[400][20], RangOlesek[400], JatekosRang[JATEKOSOK], RangokSzama, JELENLEGIID = 15458;
new const AUG_SCOPE[] = "HoloSight.mdl";
new CsapatvaltasJ[JATEKOSOK], VipAdas[JATEKOSOK][3], SayDead[JATEKOSOK];

new Float:TOP1MIN, Float:TOP1MAX, Float:TOP2MIN, Float:TOP2MAX, Float:TOP3MIN, Float:TOP3MAX, FragVan, FragLesz;

new Array:FragJatekosok, Trie:FragJatekosokAdatok; 

new Trie:PiacCuccok, Trie:PiacCuccokID, Array:PiacCuccokSteamID;

enum _:FragAdatok{
	F_Nev[32],
	F_Oles
};

enum _:PiacAdatok{
	P_Tipus,
	P_Ido,
	P_Targy,
	P_Mennyiseg,
	P_Ar[30],
	P_Nev[50],
	P_ID
};

new Hirdetesek[300][1024], HirdetesekSzam, HirdetesTart = 1;
new Cserekereskedem[JATEKOSOK][7], Float:CserekereskedemPenz[JATEKOSOK], CserekereskedemFolyamat[JATEKOSOK], HalalUF[JATEKOSOK];

new Kulcsaim[JATEKOSOK][33], JatekosLadak[JATEKOSOK][33], LadakCuccokSzama[33], LadakCuccok[33][400], LadakSzama = 0;
new SzerverKulcs[100], Float:SzerverKulcsAra, SzerverLadakNevei[33][100], SzerverLadakIni[33][100], Float:SzerverLadakArai[33], Float:SzerverLadakEselyek[33], Float:SzerverLadakKulcsEselyek[33];

new ModelMappa[300], JatekosMappa[300] = "models/player/", ModelEleresiUt[400][300], ModelFegyverTipus[400], ModelNev[400][100];
new SQL_Cim[127], SQL_Felhasznalonev[127], SQL_Jelszo[127], SQL_Adatbazis[127];
//new const JatekosSkinek[9][50];
new SkinFegyoNev[31][15];

new const Float:koordinatak[][] = {{0.30, 0.55}, {0.35, 0.52}, {0.40, 0.48}, {0.45, 0.45}, {0.50, 0.42}, {0.55, 0.45}, {0.60, 0.49}, {0.65, 0.54}};

new const Szinek[][] = {{255, 0, 0}, {0, 255, 0}, {0, 0, 255}, {255, 255, 0}, {0, 255, 255}, {255, 0, 255},{255, 255, 255}, {0, 255, 0}};

new Sync[13], PenzTart[JATEKOSOK] = 8;

new Float:PottyiPont[JATEKOSOK];

new Float:GyorsKes = 330.0;
new Float:GyorsKesVip = 10.0;
new bool:KesAKezben[JATEKOSOK] = false;
new SebessegDetect[JATEKOSOK];
new SebessegReset[JATEKOSOK];
new SebessegStat[JATEKOSOK];
new SebessegBlock[JATEKOSOK];

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	//Task
	
	set_task(1.0, "HUD_INFO", 65658, "", 0, "b");
	//set_task(0.3, "SebessegEllenor", 6900, "", 0, "b" );
	set_task(300.0, "PottyiPontMYSQL", 6901, "", 0, "b" );
	
	//Impulse
	
	register_impulse(201, "FoMenu");

	//SRVCMD
	
	register_srvcmd("nemitasid", "NemitasIDSzerver", -1, "^"SteamID^" ^"Idő^" ^"Indok^"");
	register_srvcmd("kitiltasip", "KitiltasIPSzerver", -1, "^"Ipcím^" ^"Idő^" ^"Indok^"");
	
	//Sync
	
	Sync[0] = CreateHudSyncObj();
	Sync[1] = CreateHudSyncObj();
	Sync[2] = CreateHudSyncObj();
	Sync[3] = CreateHudSyncObj();
	Sync[4] = CreateHudSyncObj();
	Sync[5] = CreateHudSyncObj();
	Sync[6] = CreateHudSyncObj();
	Sync[7] = CreateHudSyncObj();
	Sync[8] = CreateHudSyncObj();
	Sync[9] = CreateHudSyncObj();
	Sync[10] = CreateHudSyncObj();
	Sync[11] = CreateHudSyncObj();
	Sync[12] = CreateHudSyncObj();
	
	//ClCMD
	
	register_clcmd("say /menu", "FoMenu");
	register_clcmd("say /5lkjnksd791z23976alnasdhjaz63", "RemoveRegelniKell");
	register_clcmd("chooseteam", "Belepni");
	register_clcmd("joinclass", "Belepni");
	register_clcmd("jointeam", "Belepni");
	register_clcmd("say", "Uzenetek", 1);
	register_clcmd("say_team", "Uzenetek", 2);
	register_clcmd("Jelszo", "JelszoInput");
	register_clcmd("Jelszo2", "Jelszo2Input");
	register_clcmd("Jelszo3", "Jelszo3Input");
	register_clcmd("JatekosKivalasztasa", "JatekosKivalasztasaInput");
	register_clcmd("IdoMegadasaN", "IdoMegadasaNInput");
	register_clcmd("KorokMegadasa", "KorokMegadasaInput");
	register_clcmd("IndokMegadasaN", "IndokMegadasaNInput");
	register_clcmd("IndokMegadasaK", "IndokMegadasaKInput");
	register_clcmd("IndokMegadasaKS", "IndokMegadasaKSInput");
	register_clcmd("IdoMegadasaK", "IdoMegadasaKInput");
	register_clcmd("SzerverJogok", "SzerverJogok");
	register_clcmd("AdminPrefix", "AdminPrefix");
	register_clcmd("CsereKulcs", "CsereKulcs");
	register_clcmd("CsereSkin", "CsereSkin");
	register_clcmd("CsereLada", "CsereLada");
	register_clcmd("CserePenz", "CserePenz");
	register_clcmd("PiacPenz", "PiacPenz");
	register_clcmd("PiacSkin", "PiacSkin");
	register_clcmd("PiacLada", "PiacLada");
	register_clcmd("PiacKulcs", "PiacKulcs");
	register_clcmd("VipIdo", "VipIdo");
	
	//ConCMD
	
	register_concmd("adminsteamid", "AdminSteamID", 0, "<SteamID>");
	register_concmd("steamid", "SteamID", 0, "<SteamID>");
	register_concmd("ipcim", "IpCim", 0, "<IpCím>");
	register_concmd("nev", "JatekosNev", 0, "<Játékos neve>");
	register_concmd("jatekosmenu", "KonzolJatekosMenu", 0, "");
	register_concmd("modmenu", "ModMenu", 0, "");
	
	//LogEvent
	
	register_logevent("Ujrainditas", 2, "0=World triggered", "1&Restart_Round_");
	register_logevent("KorVege", 2, "0=World triggered", "1=Round_End");
	
	//Foward
	
	register_forward(FM_Voice_SetClientListening, "BeszedNemitas");
	register_forward(FM_ClientUserInfoChanged, "ClientUserInfoChanged"); 
	
	//Ham
	
	RegisterHam(Ham_Weapon_SecondaryAttack, "weapon_aug", "FW_CmdStart" );
	RegisterHam(Ham_Weapon_Reload, "weapon_aug", "fw_Weapon_Reload_Post", 1);
	RegisterHam(Ham_Spawn, "player", "Spawn", 1);
	
	//Event
	register_event("DeathMsg", "Halal", "a");
	register_event("Damage", "Sebzes", "b", "2>0", "3=0");
	register_event("ResetHUD", "KorIndul", "b");
	register_event("CurWeapon", "FegyoValtas", "be","1=1");
	
	
	//Cvar
	
	set_cvar_num("mp_timelimit", 0);

	//MOD
	
	SkinFegyoNev[1] = "P228";
	SkinFegyoNev[3] = "SCOUT";
	SkinFegyoNev[5] = "XM1014";
	SkinFegyoNev[7] = "MAC10";
	SkinFegyoNev[8] = "AUG";
	SkinFegyoNev[10] = "ELITE";
	SkinFegyoNev[11] = "FIVESEVEN";
	SkinFegyoNev[12] = "UMP45";
	SkinFegyoNev[13] = "SG550";
	SkinFegyoNev[14] = "GALIL";
	SkinFegyoNev[15] = "FAMAS";
	SkinFegyoNev[16] = "USP";
	SkinFegyoNev[17] = "GLOCK18";
	SkinFegyoNev[18] = "AWP";
	SkinFegyoNev[19] = "MP5NAVY";
	SkinFegyoNev[20] = "M249";
	SkinFegyoNev[21] = "M3";
	SkinFegyoNev[22] = "M4A1";
	SkinFegyoNev[23] = "TMP";
	SkinFegyoNev[24] = "G3SG1";
	SkinFegyoNev[26] = "DEAGLE";
	SkinFegyoNev[27] = "SG552";
	SkinFegyoNev[28] = "AK47";
	SkinFegyoNev[29] = "KÉS";
	SkinFegyoNev[30] = "P90";
	
	PiacCuccok = TrieCreate();
	PiacCuccokID = TrieCreate();
	PiacCuccokSteamID = ArrayCreate(50);
	FragJatekosok = ArrayCreate(50);
	FragJatekosokAdatok = TrieCreate();
	
}

public PottyiPontMYSQL(){
	new query[1024];
	format(query, charsmax(query), "SELECT * FROM `__syn_payments` WHERE comment != ^"^" AND Megkapta = 0;");
	SQL_ThreadQuery(SQLTuple,"Payments", query);
}
public Payments(FailState, Handle:Query, Error[], Errcode) {
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) {
		log_amx("%s", Error);
		return;
	}else {
		if(SQL_NumRows(Query) > 0){
			while (SQL_MoreResults(Query)){
				new Data[3];
				new ID[100];
				Data[0] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "amount"));
				Data[2] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "id"));
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "comment"), ID, charsmax(ID));
				Data[1] = str_to_num(ID);
				PottyiPontIDCheckMYSQL(Data);
				SQL_NextRow(Query);
			}
		}
	} 
}

public PottyiPontIDCheckMYSQL(Data[]){
	new query[1024];
	format(query, charsmax(query), "SELECT `STEAMID` FROM `%s` WHERE ID = %d;", TablaNev, Data[1]);
	SQL_ThreadQuery(SQLTuple,"PottyiPontIDCheckMYSQLq", query, Data, 3);
}

public PottyiPontIDCheckMYSQLq(FailState, Handle:Query, Error[], Errcode, Data[], DataSize) {
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) {
		log_amx("%s", Error);
		return;
	}else {
		if(SQL_NumRows(Query) > 0){
			new SteamID[40];
			SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "STEAMID"), SteamID, charsmax(SteamID));
			new idd = find_player("c", SteamID);
			if(idd != 0){
				if(Bekelllepni[idd] == 0 ? true : Belepett[idd] != 0){
					PottyiPont[idd] += Data[0];
					PottyiPontUpdatepaymentsMYSQL(Data);
				}
			}
			PottyiPontUpdateMYSQL(Data);
			PottyiPontUpdatepaymentsMYSQL(Data);
		}
	} 
}

public PottyiPontUpdateMYSQL(Data[]){
	new query[1024];
	format(query, charsmax(query), "UPDATE `%s` SET `PottyiPont` = PottyiPont+%d WHERE ID = %d;s", TablaNev, Data[0], Data[1]);
	Data[0] = 0;
	SQL_ThreadQuery(SQLTuple,"QuerySetData", query, Data, 3);
}

public PottyiPontUpdatepaymentsMYSQL(Data[]){
	new query[1024];
	format(query, charsmax(query), "UPDATE `__syn_payments` SET `Megkapta` = 1 WHERE id = %d;", Data[2]);
	Data[0] = 0;
	SQL_ThreadQuery(SQLTuple,"QuerySetData", query, Data, 3);
}

public SpecLista()
{
	static szHud[1102];
	static Lista[34];
 
	for(new i = 1; i < JATEKOSOK; i++){
		new bool:Nezo[33];
		new bool:Tovabb = false;
 
		if(!is_user_alive(i)){
			continue;
		}
 
		get_user_name(i, Lista, 32);
		format(szHud, 45, "%s nézői:^n", Lista);
 
		for( new i3 = 1; i3 <= JATEKOSOK; i3++ ){
			if( is_user_connected(i3) ){
				if( is_user_alive(i3) || is_user_bot(i3) ){
					continue;
				}
 
				if( pev(i3, pev_iuser2) == i ){
					if(!Adminvagy[i3]){
						get_user_name(i3, Lista, 32);
						add(Lista, 33, "^n", 0);
						add(szHud, 1101, Lista, 0);
						Tovabb = true;
					}
					Nezo[i3] = true;
				}
			}
		}
		if(Tovabb == true){
			for(new i2 = 1; i2 < JATEKOSOK; i2++){
				if( Nezo[i2] == true){
					set_hudmessage(random_num(64, 128), random_num(64, 128), random_num(64, 128), 0.75, 0.12, 0, 0.0, 1.1, 0.0, 0.0, 1);
					ShowSyncHudMsg(i2, Sync[12], "%s", szHud);
				}
			}
		}
	}
	return;
}

public BeszedNemitas(Fogado, Beszelo, bool:Figyeles){
	if(Fogado == Beszelo || !is_user_connected(Fogado) || !is_user_connected(Beszelo)){
		return FMRES_IGNORED;
	}
	
	if((NemitasLejar[Beszelo][0] != 0 || NemitasLejar[Beszelo][1] != 0) || (!is_user_alive(Fogado) && is_user_alive(Beszelo))){
		engfunc(EngFunc_SetClientListening, Fogado, Beszelo, 0);
		return FMRES_SUPERCEDE;
	}
	
	return FMRES_IGNORED;
}

public HUD_INFO(){
	SpecLista();
	for(new i = 1; i < JATEKOSOK; i++){
		if(is_user_connected(i)){
			if(HUD[i] != 0 || is_user_bot(i)){
				continue;
			}
			if(is_user_alive(i)){
				new Jatszott = Masodpercek[i] + (get_systime() - Felcsatlakozasido[i]), ido[32], datum[32], PENZ[100], OLESEK[100], Forma[300];
				get_time("%H:%M:%S", ido, 31);
				get_time("%Y.%m.%d", datum, 31);
				if(Olesek[i] != 0){
					format(OLESEK, charsmax(OLESEK), "Ölések: %d", Olesek[i]);
				}
				if(Penz[i] != 0){
					format(PENZ, charsmax(PENZ), "Pénz: %.2f", Penz[i]);
				}
				new LejarSzoveg[128];
				shedi_time_length(Jatszott, timeunit_seconds, LejarSzoveg, charsmax(LejarSzoveg));
				format(Forma, charsmax(Forma), "Játszott idő: %s^n", LejarSzoveg);

				format(Forma, charsmax(Forma), "%sIdő: %s Dátum: %s^n", Forma, ido, datum);
				if(!equal(OLESEK, "")){
					format(Forma, charsmax(Forma), "%s%s^n", Forma, OLESEK);
				}
				if(!equal(PENZ, "")){
					format(Forma, charsmax(Forma), "%s%s", Forma, PENZ);
				}
				set_hudmessage(0, 255, 0, 0.01, 0.13, 0, 6.0, 1.0);
				ShowSyncHudMsg(i, Sync[10], "%s", Forma);
			}else{
				new Jatekos = pev(i, pev_iuser1) == 4 ? pev(i, pev_iuser2) : i;
				if(Jatekos != 0 && is_user_connected(Jatekos) && is_user_alive(Jatekos) && Jatekos != i){
					new Jatszott = Masodpercek[Jatekos] + (get_systime() - Felcsatlakozasido[Jatekos]), ido[32], datum[32], PENZ[100], OLESEK[100], Forma[300];
					get_time("%H:%M:%S", ido, 31);
					get_time("%Y.%m.%d", datum, 31);
					if(Olesek[Jatekos] != 0){
						format(OLESEK, charsmax(OLESEK), "Ölések: %d", Olesek[Jatekos]);
					}
					if(Penz[Jatekos] != 0){
						format(PENZ, charsmax(PENZ), "Pénz: %.2f", Penz[Jatekos]);
					}
					new LejarSzoveg[128];
					shedi_time_length(Jatszott, timeunit_seconds, LejarSzoveg, charsmax(LejarSzoveg));
					format(Forma, charsmax(Forma), "Játszott idő: %s^n", LejarSzoveg);

					format(Forma, charsmax(Forma), "%sIdő: %s Dátum: %s^n", Forma, ido, datum);
					if(!equal(OLESEK, "")){
						format(Forma, charsmax(Forma), "%s%s^n", Forma, OLESEK);
					}
					if(!equal(PENZ, "")){
						format(Forma, charsmax(Forma), "%s%s^n^n", Forma, PENZ);
					}
					new fegyo = get_user_weapon(Jatekos);
					if(JelenlegiFegyo[Jatekos][fegyo] != 0){
						format(Forma, charsmax(Forma), "%sSkin neve: %s %s", Forma, ModelNev[JelenlegiFegyo[Jatekos][fegyo]], SkinFegyoNev[fegyo]);
					}
					set_hudmessage(0, 255, 0, 0.01, 0.13, 0, 6.0, 1.0);
					ShowSyncHudMsg(i, Sync[10], "%s", Forma);
				}
			}
		}
	}
}

public NemitasIDSzerver(){
	if(read_argc() != 4){
		server_print("Használat: nemitasid ^"SteamID^" ^"Idő^" ^"Indok^"");
		return PLUGIN_HANDLED;
	}
	
	static Temp[120];
	
	new ID[50];
	read_argv(1, ID, sizeof(ID) - 1);
	
	read_argv(2, Temp, sizeof(Temp) - 1);
	new Ido = str_to_num(Temp);
	
	new Indok[50];
	read_argv(3, Indok, sizeof(Indok) - 1);
	
	new id = find_player("c", ID);
	NemitasMegad(0, 1, ID, Ido, Indok, NEV[id]);
	
	return PLUGIN_HANDLED;
} 

public KitiltasIPSzerver(){
	if(read_argc() != 4){
		server_print("Használat: kitiltasip ^"IP^" ^"Idő^" ^"Indok^"");
		return PLUGIN_HANDLED;
	}
	
	static Temp[120];
	
	new IP[50];
	read_argv(1, IP, sizeof(IP) - 1);
	
	read_argv(2, Temp, sizeof(Temp) - 1);
	new Ido = str_to_num(Temp);
	
	new Indok[50];
	read_argv(3, Indok, sizeof(Indok) - 1);
	
	new id = find_player("d", IP);
	KitiltasMegad(0, 0, IP, Ido, Indok, NEV[id]);
	
	return PLUGIN_HANDLED; 
}

public client_infochanged(id){
	if(!is_user_connected(id)){
		return PLUGIN_CONTINUE;
	}
	static Nev[32];
	get_user_info(id, "name", Nev, charsmax(Nev));

	if(equal(Nev, NEV[id])){
		return PLUGIN_CONTINUE;
	}	
	set_user_info(id, "name", NEV[id]);
	chat(0, id, 0, "Nevet váltani csak úgy tudsz, hogyha !glecsatlakozol!n, és !gátírod!n a !tneved!n, majd !gújra csatlakozol!n!");
	return PLUGIN_HANDLED;
}

public SteamID(id, level, cid){
	if((Bekelllepni[id] == 1 || Adminvagy[id] == 1 || SzuperAdmin[id] == 1) && Belepett[id] == 0){
		chat(0, id, 0, "!nElőbb be kell jelentkezned!");
		LogSave(id);
		return PLUGIN_HANDLED;
	}
	if(Adminvagy[id] == 0 && SzuperAdmin[id] == 0){
		return PLUGIN_HANDLED;
	}
	if(!cmd_access(id, level, cid, 2)) return PLUGIN_HANDLED;
	
	if(SzuperAdmin[id] == 0 && containi(ModJogok[id], "a") == -1 && containi(ModJogok[id], "b") == -1 && containi(ModJogok[id], "c") == -1){
		console_print(id, "************************************************");
		console_print(id, "Neked nincs jogosutságod a menü megnyitásához!");
		console_print(id, "************************************************");
		chat(0, id, 0, "Neked nincs jogosutságod a menü megnyitásához!");
		AdminMenu(id);
		return PLUGIN_HANDLED;
	}
	
	new SteamID[40];
	
	read_args(SteamID, charsmax(SteamID));
	remove_quotes(SteamID);
	if(containi(SteamID, "steam_") != 0){
		console_print(id, "************************************************");
		console_print(id, "Érvénytelen SteamID!");
		console_print(id, "************************************************");
		chat(0, id, 0, "!tHiba! !nÉrvénytelen SteamID!");
		return PLUGIN_HANDLED;
	}
	new ID = find_player("c", SteamID);
	if(ID != 0){
		if((equal(IP[ID], AdminIP) || equal(IP[ID], IP[id]) || (SzuperAdmin[id] == 0 && (Adminvagy[ID] != 0 || SzuperAdmin[ID] != 0)))){
			console_print(id, "************************************************");
			console_print(id, "Nem választhatsz ki egy másik admint!");
			console_print(id, "************************************************");
			chat(0, id, 0, "!tHiba! !nNem választhatsz ki egy másik admint!");
			return PLUGIN_HANDLED;
		}
		if(equali(KivalasztottEredmeny[id][0], SteamID)){
			console_print(id, "************************************************");
			console_print(id, "Már ki van választva ez a játékos!");
			console_print(id, "************************************************");
			chat(0, id, 0, "!tHiba! !nMár ki van választva ez a játékos!");
			return PLUGIN_HANDLED;
		}
		format(KivalasztottEredmeny[id][0], 100, "%s", STEAMID[ID]);
		format(KivalasztottEredmeny[id][1], 100, "%s", NEV[ID]);
		format(KivalasztottEredmeny[id][2], 100, "%s", IP[ID]);
		
		if(NemitasLejar[ID][0] > 0 && NemitasLejar[ID][1] > 0){
			format(KivalasztottEredmeny[id][3], 100, "3");
		}else if(NemitasLejar[id][0] > 0){
			format(KivalasztottEredmeny[id][3], 100, "1");
		}else if(NemitasLejar[id][1] > 0){
			format(KivalasztottEredmeny[id][3], 100, "2");
		}else{
			format(KivalasztottEredmeny[id][3], 100, "0");
		}
		format(KivalasztottEredmeny[id][4], 100, "0");
		JatekosMenu(id);
		return PLUGIN_HANDLED;
	}else{
		JatekosokLekeres(id, SteamID, 1, 0);
		return PLUGIN_HANDLED;
	}
}

public AdminSteamID(id, level, cid){
	if(Bekelllepni[id] == 1 && Belepett[id] == 0){
		chat(0, id, 0, "!nElőbb be kell jelentkezned!");
		LogSave(id);
		return PLUGIN_HANDLED;
	}
	if(SzuperAdmin[id] == 0 && containi(ModJogok[id], "e") == -1){
		return PLUGIN_HANDLED;
	}
	if(!cmd_access(id, level, cid, 2)) return PLUGIN_HANDLED;
	
	new SteamID[40];
	
	read_args(SteamID, charsmax(SteamID));
	remove_quotes(SteamID);
	if(containi(SteamID, "steam_") != 0){
		console_print(id, "************************************************");
		console_print(id, "Érvénytelen SteamID!");
		console_print(id, "************************************************");
		chat(0, id, 0, "!tHiba! !nÉrvénytelen SteamID!");
		return PLUGIN_HANDLED;
	}
	new ID = find_player("c", SteamID);
	if(ID != 0){
		if(equali(IP[ID], AdminIP)){
			console_print(id, "************************************************");
			console_print(id, "Ezt a játékost nem választhatod ki!");
			console_print(id, "************************************************");
			chat(0, id, 0, "!tHiba! !nEzt a játékost nem választhatod ki!");
			return PLUGIN_HANDLED;
		}
		format(KivalasztottAdminEredmenyUJ[id][0], 120, "%s", STEAMID[ID]);
		format(KivalasztottAdminEredmenyUJ[id][1], 120, "%s", NEV[ID]);
		format(KivalasztottAdminEredmenyUJ[id][2], 120, "%s", ModJogok[ID]);
		format(KivalasztottAdminEredmenyUJ[id][3], 120, "%s", Jogok[ID]);
		format(KivalasztottAdminEredmenyUJ[id][4], 120, "%d", SzuperAdmin[ID]);
		format(KivalasztottAdminEredmenyUJ[id][5], 120, "%s", JatekosPrefix[ID]);
		format(KivalasztottAdminEredmenyUJ[id][6], 120, "%d", Adminvagy[ID]);
		AdminJogok(id);
	}else{
		AdminLekeres(id, SteamID);
	}
	return PLUGIN_HANDLED;
}

public ModMenu(id, level, cid){
	if(Bekelllepni[id] == 1 && Belepett[id] == 0){
		chat(0, id, 0, "!nElőbb be kell jelentkezned!");
		LogSave(id);
		return PLUGIN_HANDLED;
	}
	if(Adminvagy[id] == 0 && SzuperAdmin[id] == 0){
		return PLUGIN_HANDLED;
	}
	if(Adminvagy[id] == 0 && SzuperAdmin[id] == 0){
		return PLUGIN_HANDLED;
	}
	if(SzuperAdmin[id] == 0 && containi(ModJogok[id], "a") == -1 && containi(ModJogok[id], "b") == -1 && containi(ModJogok[id], "c") == -1 && containi(ModJogok[id], "d") == -1 && containi(ModJogok[id], "e") == -1){
		return PLUGIN_HANDLED;
	}
	AdminMenu(id);
	return PLUGIN_HANDLED;
}

public KonzolJatekosMenu(id, level, cid){
	if(Bekelllepni[id] == 1 && Belepett[id] == 0){
		chat(0, id, 0, "!nElőbb be kell jelentkezned!");
		LogSave(id);
		return PLUGIN_HANDLED;
	}
	if(Adminvagy[id] == 0 && SzuperAdmin[id] == 0){
		return PLUGIN_HANDLED;
	}
	if(SzuperAdmin[id] == 0 && containi(ModJogok[id], "a") == -1 && containi(ModJogok[id], "b") == -1 && containi(ModJogok[id], "c") == -1){
		return PLUGIN_HANDLED;
	}
	JatekosMenu(id);
	return PLUGIN_HANDLED;
}

public IpCim(id, level, cid){
	if((Bekelllepni[id] == 1 || Adminvagy[id] == 1 || SzuperAdmin[id] == 1) && Belepett[id] == 0){
		chat(0, id, 0, "!nElőbb be kell jelentkezned!");
		LogSave(id);
		return PLUGIN_HANDLED;
	}
	if(Adminvagy[id] == 0 && SzuperAdmin[id] == 0){
		return PLUGIN_HANDLED;
	}
	if(!cmd_access(id, level, cid, 2)) return PLUGIN_HANDLED;
	
	if(SzuperAdmin[id] == 0 && containi(ModJogok[id], "a") == -1 && containi(ModJogok[id], "b") == -1 && containi(ModJogok[id], "c") == -1){
		console_print(id, "************************************************");
		console_print(id, "Neked nincs jogosutságod a menü megnyitásához!");
		console_print(id, "************************************************");
		chat(0, id,0,"Neked nincs jogosutságod a menü megnyitásához!");
		AdminMenu(id);
		return PLUGIN_HANDLED;
	}
	
	new IpCim[40];
	
	read_args(IpCim, charsmax(IpCim));
	remove_quotes(IpCim);
	if(containi(IpCim, ".") == -1){
		console_print(id, "************************************************");
		console_print(id, "Érvénytelen IpCim!");
		console_print(id, "************************************************");
		chat(0, id, 0, "!tHiba! !nNézd meg a !gkonzolod!");
		return PLUGIN_HANDLED;
	}
	JatekosokLekeres(id, IpCim, 2, 0);
	return PLUGIN_HANDLED;
}

public JatekosNev(id, level, cid){
	if((Bekelllepni[id] == 1 || Adminvagy[id] == 1 || SzuperAdmin[id] == 1) && Belepett[id] == 0){
		chat(0, id, 0, "!nElőbb be kell jelentkezned!");
		LogSave(id);
		return PLUGIN_HANDLED;
	}
	if(Adminvagy[id] == 0 && SzuperAdmin[id] == 0){
		return PLUGIN_HANDLED;
	}
	if(!cmd_access(id, level, cid, 2)) return PLUGIN_HANDLED;
	
	if(SzuperAdmin[id] == 0 && containi(ModJogok[id], "a") == -1 && containi(ModJogok[id], "b") == -1 && containi(ModJogok[id], "c") == -1){
		console_print(id, "************************************************");
		console_print(id, "Neked nincs jogosutságod a menü megnyitásához!");
		console_print(id, "************************************************");
		chat(0, id,0,"Neked nincs jogosutságod a menü megnyitásához!");
		AdminMenu(id);
		return PLUGIN_HANDLED;
	}
	
	new JatekosNev[40];	
	read_args(JatekosNev, charsmax(JatekosNev));
	remove_quotes(JatekosNev);
	new ID = find_player("a", JatekosNev);
	if(ID != 0){
		if((equal(IP[ID], AdminIP) || equal(IP[ID], IP[id]) || (SzuperAdmin[id] == 0 && (Adminvagy[ID] != 0 || SzuperAdmin[ID] != 0)))){
			console_print(id, "************************************************");
			console_print(id, "Nem választhatsz ki egy másik admint!");
			console_print(id, "************************************************");
			chat(0, id, 0, "!tHiba! !nNézd meg a !gkonzolod!");
			return PLUGIN_HANDLED;
		}
		if(equali(KivalasztottEredmeny[id][0], JatekosNev)){
			console_print(id, "************************************************");
			console_print(id, "Már ki van választva ez a játékos!");
			console_print(id, "************************************************");
			chat(0, id, 0, "!tHiba! !nNézd meg a !gkonzolod!");
			return PLUGIN_HANDLED;
		}
		format(KivalasztottEredmeny[id][0], 100, "%s", STEAMID[ID]);
		format(KivalasztottEredmeny[id][1], 100, "%s", NEV[ID]);
		format(KivalasztottEredmeny[id][2], 100, "%s", IP[ID]);
		
		if(NemitasLejar[ID][0] > 0 && NemitasLejar[ID][1] > 0){
			format(KivalasztottEredmeny[id][3], 100, "3");
		}else if(NemitasLejar[id][0] > 0){
			format(KivalasztottEredmeny[id][3], 100, "1");
		}else if(NemitasLejar[id][1] > 0){
			format(KivalasztottEredmeny[id][3], 100, "2");
		}else{
			format(KivalasztottEredmeny[id][3], 100, "0");
		}
		format(KivalasztottEredmeny[id][4], 100, "0");
		JatekosMenu(id);
	}else{
		JatekosokLekeres(id, JatekosNev, 3, 0);
	}
	return PLUGIN_HANDLED;
}

public MapvaltasMost(id){
	if(AdminMap != 0){
		server_cmd("changelevel %s", SzerverMapok[AdminMap]);
	}else{
		server_cmd("restart");
	}
}

public kor(id){
	if(FragVan == 0){
		chat(0, id, 0, "!nKör: !g%d!n/!t%d !g| !nJatekosok: !g%d!n/!t%d", Korok_szama, Resi, get_playersnum(1), get_maxplayers());
		if(AdminMapKor != -1){
			if(AdminMapKor == 0){
				chat(0, id, 0, "!tEz !na kör után mapváltás: !t%s!n, általa: !g%s!n!", AdminMapKor, SzerverMapok[AdminMap], AdminMapNeve);
			}else{
				chat(0, id, 0, "!t%d !nkör után mapváltás: !t%s!n, általa: !g%s!n!", AdminMapKor, SzerverMapok[AdminMap], AdminMapNeve);
			}
		}
	}else{
		chat(0, id, 0, "A szerveren !gjelenleg !tfragverseny !nzajlik, sok !gsikert!n!");
		chat(0, id, 0, "!nKör: !g%d!n/!t%d !g| !nJatekosok: !g%d!n/!t%d", Korok_szama, Resi, get_playersnum(1), get_maxplayers());
	}
}

public Ujrainditas(){
	Korok_szama = 1;
}
new Top1Nyeremeny1, Top1Nyeremeny2, Float:Top1Nyeremeny3, Top2Nyeremeny1, Float:Top2Nyeremeny2, Float:Top3Nyeremeny;
 
public TopNyeremeny(Helyezes, SteamID[]){
	if(Helyezes == 0){
		new maxwp;
		for(new a = 1;a < JATEKOSOK;a++){
			maxwp += FegyokSzama[a];
		}
		
		Top1Nyeremeny1 = random_num(1, maxwp);
		Top1Nyeremeny2 = random_num(6, LadakSzama);
		Top1Nyeremeny3 = random_float(TOP1MIN, TOP1MAX);
		new id = find_player("c", SteamID);
		if(id == 0){
			new Data[1];
			Data[0] = 0;
			new query[1024];
			format(query, charsmax(query), "UPDATE `%s` SET M%d = M%d+1, Lada%d = Lada%d+1, Penz = Penz+%f WHERE `STEAMID` = ^"%s^";", TablaNev, Top1Nyeremeny1, Top1Nyeremeny1, Top1Nyeremeny2, Top1Nyeremeny2, Top1Nyeremeny3, SteamID);
			SQL_ThreadQuery(SQLTuple,"QuerySetData", query, Data, 1);
		}else{
			JatekosFegyo[id][Top1Nyeremeny1]++;
			JatekosFegyverOsszes[id][ModelFegyverTipus[Top1Nyeremeny1]]++;
			JatekosLadak[id][Top1Nyeremeny2]++;
			Penz[id] += Top1Nyeremeny3;
		}
	}else if(Helyezes == 1){
		Top2Nyeremeny1 = random_num(6, LadakSzama);
		Top2Nyeremeny2 = random_float(TOP2MIN, TOP2MAX);
		new id = find_player("c", SteamID);
		if(id == 0){
			new Data[1];
			Data[0] = 0;
			new query[1024];
			format(query, charsmax(query), "UPDATE `%s` SET Lada%d = Lada%d+1, Penz = Penz+%f WHERE `STEAMID` = ^"%s^";", TablaNev, Top2Nyeremeny1, Top2Nyeremeny1, Top2Nyeremeny2, SteamID);
			SQL_ThreadQuery(SQLTuple,"QuerySetData", query, Data, 1);
		}else{
			JatekosLadak[id][Top2Nyeremeny1]++;
			Penz[id] += Top2Nyeremeny2;
		}
	}else if(Helyezes == 2){
		Top3Nyeremeny = random_float(TOP3MIN, TOP3MAX);
		new id = find_player("c", SteamID);
		if(id == 0){
			new Data[1];
			Data[0] = 0;
			new query[1024];
			format(query, charsmax(query), "UPDATE `%s` SET Penz = Penz+%f WHERE `STEAMID` = ^"%s^";", TablaNev, Top3Nyeremeny, SteamID);
			SQL_ThreadQuery(SQLTuple,"QuerySetData", query, Data, 1);
		}else{
			Penz[id] += Top3Nyeremeny;
		}
	}
}

public TOPNyert(Data[]){
	new Helyezes = Data[0];
	if(Helyezes == -1){	
		message_begin(MSG_ALL, SVC_INTERMISSION);
		message_end();
		set_task(4.0, "MapvaltasMost", 544888);
		return;
	}else{
		new SteamID[50], Adat[FragAdatok];
		
		ArrayGetString(FragJatekosok, Helyezes, SteamID, charsmax(SteamID));
		
		TrieGetArray(FragJatekosokAdatok, SteamID, Adat, sizeof Adat);
		if(Helyezes == 2){
			if(Adat[F_Oles] > 0){
				TopNyeremeny(Helyezes, SteamID);
				set_dhudmessage(random_num(0, 50), random_num(0, 150), random_num(0, 100), -1.0, 0.05, 0, 0.0, 10.0); 
				show_dhudmessage(0, "---------------------TOP3---------------------");	
				set_dhudmessage(random_num(0, 50), random_num(0, 150), random_num(0, 100), -1.0, 0.1, 0, 0.0, 10.0);
				show_dhudmessage(0, "Játékosnév: %s Ölései: %d", Adat[F_Nev], Adat[F_Oles]);
				set_dhudmessage(random_num(0, 50), random_num(0, 150), random_num(0, 100), -1.0, 0.15, 0, 0.0, 10.0);
				show_dhudmessage(0, "Nyeremények");
				set_dhudmessage(random_num(0, 50), random_num(0, 150), random_num(0, 100), -1.0, 0.2, 0, 0.0, 10.0);
				show_dhudmessage(0, "%.2f Pénz", Top3Nyeremeny+0.000001);
				set_dhudmessage(random_num(0, 50), random_num(0, 150), random_num(0, 100), -1.0, 0.25, 0, 0.0, 10.0);
				show_dhudmessage(0, "-----------------Gratulálunk------------------");
			}else{			
				set_dhudmessage(random_num(0, 50), random_num(0, 150), random_num(0, 100), -1.0, 0.25, 0, 0.0, 10.0);
				show_dhudmessage(0, "A TOP3. játékosnak nincs 1 ölése sem, ezért nem kap semmit!");
			}
			new Adatok[1];
			Adatok[0] = 1;
			set_task(12.0, "TOPNyert", 7154, Adatok, 1);
		}else if(Helyezes == 1){
			if(Adat[F_Oles] > 0){
				TopNyeremeny(Helyezes, SteamID);
				set_dhudmessage(random_num(0, 50), random_num(0, 150), random_num(0, 100), -1.0, 0.05, 0, 0.0, 10.0);
				show_dhudmessage(0, "---------------------TOP2---------------------");	
				set_dhudmessage(random_num(0, 50), random_num(0, 150), random_num(0, 100), -1.0, 0.1, 0, 0.0, 10.0);
				show_dhudmessage(0, "Játékosnév: %s Ölései: %d", Adat[F_Nev], Adat[F_Oles]);
				set_dhudmessage(random_num(0, 50), random_num(0, 150), random_num(0, 100), -1.0, 0.15, 0, 0.0, 10.0);
				show_dhudmessage(0, "Nyeremények");
				set_dhudmessage(random_num(0, 50), random_num(0, 150), random_num(0, 100), -1.0, 0.2, 0, 0.0, 10.0);
				show_dhudmessage(0, "%s Láda", SzerverLadakNevei[Top2Nyeremeny1]);
				set_dhudmessage(random_num(0, 50), random_num(0, 150), random_num(0, 100), -1.0, 0.25, 0, 0.0, 10.0);
				show_dhudmessage(0, "%.2f Pénz", Top2Nyeremeny2+0.000001);
				set_dhudmessage(random_num(0, 50), random_num(0, 150), random_num(0, 100), -1.0, 0.3, 0, 0.0, 10.0);
				show_dhudmessage(0, "-----------------Gratulálunk------------------");
			}else{			
				set_dhudmessage(random_num(0, 50), random_num(0, 150), random_num(0, 100), -1.0, 0.25, 0, 0.0, 10.0);
				show_dhudmessage(0, "A TOP2. játékosnak nincs 1 ölése sem, ezért nem kap semmit!");
			}
			new Adatok[1];
			Adatok[0] = 0;
			set_task(12.0, "TOPNyert", 7154, Adatok, 1);
		}else if(Helyezes == 0){
			if(Adat[F_Oles] > 0){
				TopNyeremeny(Helyezes, SteamID);
				set_dhudmessage(random_num(0, 50), random_num(0, 150), random_num(0, 100), -1.0, 0.05, 0, 0.0, 10.0);
				show_dhudmessage(0, "---------------------TOP1---------------------");	
				set_dhudmessage(random_num(0, 50), random_num(0, 150), random_num(0, 100), -1.0, 0.1, 0, 0.0, 10.0);
				show_dhudmessage(0, "Játékosnév: %s Ölései: %d", Adat[F_Nev], Adat[F_Oles]);
				set_dhudmessage(random_num(0, 50), random_num(0, 150), random_num(0, 100), -1.0, 0.15, 0, 0.0, 10.0);
				show_dhudmessage(0, "Nyeremények");
				set_dhudmessage(random_num(0, 50), random_num(0, 150), random_num(0, 100), -1.0, 0.2, 0, 0.0, 10.0);
				show_dhudmessage(0, "%s %s Skin", ModelNev[Top1Nyeremeny1], SkinFegyoNev[ModelFegyverTipus[Top1Nyeremeny1]]);
				set_dhudmessage(random_num(0, 50), random_num(0, 150), random_num(0, 100), -1.0, 0.25, 0, 0.0, 10.0);
				show_dhudmessage(0, "%s Láda", SzerverLadakNevei[Top1Nyeremeny2]);
				set_dhudmessage(random_num(0, 50), random_num(0, 150), random_num(0, 100), -1.0, 0.3, 0, 0.0, 10.0);
				show_dhudmessage(0, "%.2f Pénz", Top1Nyeremeny3+0.000001);
				set_dhudmessage(random_num(0, 50), random_num(0, 150), random_num(0, 100), -1.0, 0.35, 0, 0.0, 10.0);
				show_dhudmessage(0, "-----------------Gratulálunk------------------");
			}else{			
				set_dhudmessage(random_num(0, 50), random_num(0, 150), random_num(0, 100), -1.0, 0.25, 0, 0.0, 10.0);
				show_dhudmessage(0, "A TOP1. játékosnak nincs 1 ölése sem, ezért nem kap semmit!");
			}
			new Adatok[1];
			Adatok[0] = -1;
			set_task(15.0, "TOPNyert", 7154, Adatok, 1);
		}
	}
}
public KorVege(){
	if(AdminMapKor == 0 || Korok_szama == Resi){
		if(FragVan == 0){
			message_begin(MSG_ALL, SVC_INTERMISSION);
			message_end();
			set_task(4.0, "MapvaltasMost", 544888);
			return;
		}else if(FragVan == 1){
			FragVan = 2;
			new Adatok[1];
			Adatok[0] = 2;
			TOPNyert(Adatok);
		}
	}else if(Korok_szama == Terfel){
		for(new i = 0;i < JATEKOSOK;i++){
			if(is_user_connected(i)){
				new Csapat[20];
				if(cs_get_user_team(i) == CS_TEAM_CT){
					cs_set_user_team(i, CS_TEAM_T);
					format(Csapat, 20, "Terrorista");
				}else if(cs_get_user_team(i) == CS_TEAM_T){
					cs_set_user_team(i, CS_TEAM_CT);
					format(Csapat, 20, "Terrorelhárító");
				}
				chat(0, i, 0, "!nA térfélváltás megtörtént, az új csapatod: !t%s!n!", Csapat);
			}
		}
	}
	Korok_szama++;
	if(AdminMapKor != -1){
		AdminMapKor--;
	}
}

public client_PreThink(id){
	if(!is_user_alive(id)){ 
		return PLUGIN_CONTINUE;
	}
	new Uj = get_user_button(id);
	new Regi = get_user_oldbutton(id);
	if(Ejtoernyo[id] == 0){
		new Float:frame;
		new flags = get_entity_flags(id);
		new Tovabb;
		if (EjtoernyoEntity[id] > 0 && (flags & FL_ONGROUND)) {
			remove_entity(EjtoernyoEntity[id]);
			EjtoernyoEntity[id] = 0;
			set_user_gravity(id, 1.0);
			Tovabb++;
		}

		if (Tovabb == 0 && Uj & IN_USE) {

			new Float:velocity[3];
			entity_get_vector(id, EV_VEC_velocity, velocity);
			if (velocity[2] < 0.0) {

				if(EjtoernyoEntity[id] <= 0) {
					EjtoernyoEntity[id] = create_entity("info_target");
					if(EjtoernyoEntity[id] > 0) {
						entity_set_string(EjtoernyoEntity[id],EV_SZ_classname,"parachute");
						entity_set_edict(EjtoernyoEntity[id], EV_ENT_aiment, id);
						entity_set_edict(EjtoernyoEntity[id], EV_ENT_owner, id);
						entity_set_int(EjtoernyoEntity[id], EV_INT_movetype, MOVETYPE_FOLLOW);
						entity_set_int(EjtoernyoEntity[id], EV_INT_sequence, 0);
						entity_set_int(EjtoernyoEntity[id], EV_INT_gaitsequence, 1);
						entity_set_float(EjtoernyoEntity[id], EV_FL_frame, 0.0);
						entity_set_float(EjtoernyoEntity[id], EV_FL_fuser1, 0.0);
					}
				}

				if (EjtoernyoEntity[id] > 0) {

					entity_set_int(id, EV_INT_sequence, 3);
					entity_set_int(id, EV_INT_gaitsequence, 1);
					entity_set_float(id, EV_FL_frame, 1.0);
					entity_set_float(id, EV_FL_framerate, 1.0);
					set_user_gravity(id, 0.1);
					
					velocity[2] = (velocity[2] + 40.0 < -100.0) ? velocity[2] + 40.0 : -100.0;
					entity_set_vector(id, EV_VEC_velocity, velocity);

					if (entity_get_int(EjtoernyoEntity[id],EV_INT_sequence) == 0) {

						frame = entity_get_float(EjtoernyoEntity[id],EV_FL_fuser1) + 1.0;
						entity_set_float(EjtoernyoEntity[id],EV_FL_fuser1,frame);
						entity_set_float(EjtoernyoEntity[id],EV_FL_frame,frame);

						if (frame > 100.0) {
							entity_set_float(EjtoernyoEntity[id], EV_FL_animtime, 0.0);
							entity_set_float(EjtoernyoEntity[id], EV_FL_framerate, 0.4);
							entity_set_int(EjtoernyoEntity[id], EV_INT_sequence, 1);
							entity_set_int(EjtoernyoEntity[id], EV_INT_gaitsequence, 1);
							entity_set_float(EjtoernyoEntity[id], EV_FL_frame, 0.0);
							entity_set_float(EjtoernyoEntity[id], EV_FL_fuser1, 0.0);
						}
					}
				}
			}else if (EjtoernyoEntity[id] > 0) {
				remove_entity(EjtoernyoEntity[id]);
				set_user_gravity(id, 1.0);
				EjtoernyoEntity[id] = 0;
			}
		}else if (Tovabb == 0 && (Regi & IN_USE) && EjtoernyoEntity[id] > 0 ) {
			remove_entity(EjtoernyoEntity[id]);
			set_user_gravity(id, 1.0);
			EjtoernyoEntity[id] = 0;
		}
	}
	
	return PLUGIN_CONTINUE;
}

public client_PostThink(id){
	if(!is_user_alive(id)){
		return PLUGIN_CONTINUE;
	}
	if(UgrasMost[id] == true){
		new Float:Vektor[3];	
		entity_get_vector(id,EV_VEC_velocity,Vektor);
		Vektor[2] = random_float(265.0,285.0);
		entity_set_vector(id,EV_VEC_velocity,Vektor);
		UgrasMost[id] = false;
	}return PLUGIN_CONTINUE;
}	

public FegyoValtas(id){
	new fegyo = read_data(2);
	if(SebessegBlock[id] == 1){
		set_user_maxspeed(id, 1.0);
	}else{
		if(fegyo == CSW_KNIFE) {
			KesAKezben[id] = true;
			if(Vip[id] != 0){
				set_user_maxspeed(id, GyorsKes+GyorsKesVip);
			}else{
				set_user_maxspeed(id, GyorsKes);
			}
		}else{
			KesAKezben[id] = false;
		} 
	}

	if(JelenlegiFegyo[id][fegyo] != 0 && Kinezetek[id] == 0){
		if(get_user_weapon(id) == CSW_AUG && equal(ModelEleresiUt[JelenlegiFegyo[id][CSW_AUG]], "AUG/Modern.mdl") && Celzas[id] != 0){
			return PLUGIN_CONTINUE;
		}
		new Model[300];
		format(Model, charsmax(Model), "%s%s", ModelMappa, ModelEleresiUt[JelenlegiFegyo[id][fegyo]]);
		entity_set_string(id, EV_SZ_viewmodel, Model);
	}
	return PLUGIN_CONTINUE;
}

public SebessegEllenor(){
	for(new id = 1; id < 33; id++){
		SebessegReset[id]++;
		if(is_user_connected(id) && is_user_alive(id)){
			new Float:skorlat = 385.0;
			
			if(KesAKezben[id]){
				if(Vip[id] != 0){
					skorlat = 425.0;
				}else{
					skorlat = 385.0;
				}
				if(Adminvagy[id] != 0){
					skorlat = 445.0;
				}
			}
			if(get_speed(id) > skorlat){
				SebessegDetect[id]++;
			}
		}
		if(SebessegReset[id] == 4){
			if(SebessegDetect[id] >= 4){
				set_user_maxspeed(id, 1.0);
				drop_to_floor(id);
				SebessegBlock[id] = 1;
				new Adatok[1];
				Adatok[0] = id;
				set_task(1.16, "removespeedblock", 4789, Adatok, 1);
				chat(0, 0, 0, "!g%s !tHőőőőő.. Lassits egy kicsit, túl gyorsan mentél!", NEV[id]);
			}
			SebessegReset[id] = 0;
			SebessegDetect[id] = 0;
		}
	}
} 

public removespeedblock(Adatok[]){
	new id = Adatok[0];
	if(get_user_weapon(id) == CSW_KNIFE){	
		if(Vip[id] != 0){
			set_user_maxspeed(id, GyorsKes+GyorsKesVip);
		}else{
			set_user_maxspeed(id, GyorsKes);
		}
	}{
	new Float:maxSpeed;
	set_user_gravity(id, 1.0);
	switch ( get_user_weapon(id) ){
		case CSW_P228, CSW_HEGRENADE, CSW_C4, CSW_MAC10, CSW_SMOKEGRENADE, CSW_FLASHBANG, CSW_ELITE, CSW_FIVESEVEN, CSW_UMP45, CSW_USP, CSW_GLOCK18, CSW_MP5NAVY, CSW_TMP, CSW_DEAGLE, CSW_SG552, CSW_KNIFE: maxSpeed = 250.0;
		case CSW_M249 : maxSpeed = 220.0;
		case CSW_AK47 : maxSpeed = 220.0;
		case CSW_M3, CSW_M4A1 : maxSpeed = 225.0;
		case CSW_XM1014, CSW_AUG, CSW_GALIL, CSW_FAMAS : maxSpeed = 240.0;
		case CSW_P90 : maxSpeed = 245.0;
		case CSW_SCOUT : maxSpeed = 260.0;
		case CSW_AWP, CSW_SG550, CSW_G3SG1: maxSpeed = 210.0;
		default : maxSpeed = 250.0;
	}
	set_user_maxspeed(id, maxSpeed);
	}
	SebessegBlock[id] = 0;
}

public Spawn(id){
	if(!is_user_connected(id)){
		return;
	}
	if(Vip[id] != 0){
		set_user_health(id, 100);
		new CsArmorType:tipus;
		cs_get_user_armor(id, tipus);
		cs_set_user_armor(id, 120, tipus);
	}
	if(cs_get_user_team(id) == CS_TEAM_T)
	{
		if(Vip[id] != 0)
		{
			cs_set_user_model(id, "Herboy_Vip_T");
		}
	}
	if(cs_get_user_team(id) == CS_TEAM_CT)
	{
		if(Vip[id] != 0)
		{
			cs_set_user_model(id, "Herboy_Vip_CT");
		}
	}
	if(cs_get_user_team(id) == CS_TEAM_T){
		if(Adminvagy[id] != 0 && AdminElrejt[id] == 0){
			cs_set_user_model(id, "HerBoy_Admin_T");
		}/*else{
			cs_set_user_model(id, "HerBoy_T08");
		}*/
	}else if(cs_get_user_team(id) == CS_TEAM_CT){
		if(Adminvagy[id] != 0 && AdminElrejt[id] == 0){
			cs_set_user_model(id, "HerB0y_Admin_CT");
		}/*else{
			cs_set_user_model(id, "HerBoy_CT08");
		}*/
	}
	/*
	new Model[100];
	cs_get_user_model(id, Model, 100);
	
	if(containi(JatekosSkinek[1], Model) != -1){
		cs_set_user_model(id, JatekosSkinek[1]);
	}else if(containi(JatekosSkinek[2], Model) != -1){
		cs_set_user_model(id, JatekosSkinek[2]);
	}else if(containi(JatekosSkinek[3], Model) != -1){
		cs_set_user_model(id, JatekosSkinek[3]);
	}else if(containi(JatekosSkinek[4], Model) != -1){
		cs_set_user_model(id, JatekosSkinek[4]);
	}else if(containi(JatekosSkinek[5], Model) != -1){
		cs_set_user_model(id, JatekosSkinek[5]);
	}else if(containi(JatekosSkinek[6], Model) != -1){
		cs_set_user_model(id, JatekosSkinek[6]);
	}else if(containi(JatekosSkinek[7], Model) != -1){
		cs_set_user_model(id, JatekosSkinek[7]);
	}else if(containi(JatekosSkinek[8], Model) != -1){
		cs_set_user_model(id, JatekosSkinek[8]);
	}*/
}


public Sebzes(Aldozat){
	if(!is_user_connected(Aldozat)){
		return;
	}
	new Tamado = get_user_attacker(Aldozat);
	if(!is_user_connected(Tamado) || Aldozat == Tamado || Sebzeskijelzo[Tamado] == 1){
		return;
	}
	if(SebzesTart[Tamado] > 7){ 
		SebzesTart[Tamado] = 0;
	}
	set_hudmessage(Szinek[SebzesTart[Tamado]][0], Szinek[SebzesTart[Tamado]][1], Szinek[SebzesTart[Tamado]][2], koordinatak[SebzesTart[Tamado]][0], koordinatak[SebzesTart[Tamado]][1], 0, 6.0, 1.0);
	ShowSyncHudMsg(Tamado, Sync[SebzesTart[Tamado]], "|-%d HP|", read_data(2));
	SebzesTart[Tamado]++;
}

public JelszoInput(id){
	new Adat[32], Hossz;
	read_args(Adat, 31);
	remove_quotes(Adat);
	
	Hossz = strlen(Adat);

	if(containi(Adat, " ") != -1){	
		format(Hiba[id], 1000, "^nA jelszó nem tartalmazhat szóközt!");
	}
	if(Hossz < 5){
		format(Hiba[id], 1000, "%s^nA jelszó túl rövid! (Min. 5 karakter)", Hiba[id]);
	}
	if(equali(NEV[id], Adat)){
		format(Hiba[id], 1000, "%s^nNem lehet ugyanaz a neved, és a jelszó!", Hiba[id]);
	}
	if(equali(STEAMID[id], Adat)){
		format(Hiba[id], 1000, "%s^nNem lehet ugyanaz a steamid, és a jelszó!", Hiba[id]);
	}
	if(!equal(Jelszo2[id], "") && !equal(Jelszo2[id], Adat)){
		format(Hiba[id], 1000, "%s^nNem egyezik a két jelszó!", Hiba[id]);
	}
	if(Hossz > 19){
		format(Hiba[id], 1000, "%s^nA jelszó túl hosszú! (Max. 19 karakter)", Hiba[id]);
	}else{
		copy(Jelszo[id], charsmax(Jelszo), Adat);
	}
	LogSave(id);
	return PLUGIN_HANDLED;
}

public Jelszo2Input(id){
	new Adat[32], Hossz;
	read_args(Adat, 31);
	remove_quotes(Adat);
	
	Hossz = strlen(Adat);

	if(containi(Adat, " ") != -1){	
		format(Hiba[id], 1000, "^nA jelszó nem tartalmazhat szóközt!");
	}
	if(Hossz < 5){
		format(Hiba[id], 1000, "%s^nA jelszó túl rövid! (Min. 5 karakter)", Hiba[id]);
	}
	if(equali(NEV[id], Adat)){
		format(Hiba[id], 1000, "%s^nNem lehet ugyanaz a neved, és a jelszó!", Hiba[id]);
	}
	if(equali(STEAMID[id], Adat)){
		format(Hiba[id], 1000, "%s^nNem lehet ugyanaz a steamid, és a jelszó!", Hiba[id]);
	}
	if(!equal(Jelszo[id], Adat)){
		format(Hiba[id], 1000, "%s^nNem egyezik a két jelszó!", Hiba[id]);
	}
	if(Hossz > 19){
		format(Hiba[id], 1000, "%s^nA jelszó túl hosszú! (Max. 19 karakter)", Hiba[id]);
	}else{
		copy(Jelszo2[id], charsmax(Jelszo2), Adat);
	}
	LogSave(id);
	return PLUGIN_HANDLED;
}

public Jelszo3Input(id){
	new Adat[32];
	read_args(Adat, 31);
	remove_quotes(Adat);

	if(!equal(JelszoSQL[id], Adat)){
		chat(0, id, 0, "!tHelytelen jelszó!");
	}else{
		chat(0, id, 0, "!tSikeresen eltávolitottad a jelszót!");
		JelszoSQL[id] = "";
		Jelszo[id] = "";
		Jelszo2[id] = "";
		Bekelllepni[id] = 0;
		Belepett[id] = 0;
	}
	Beallitasok(id);
	return PLUGIN_HANDLED;
}
public IndokMegadasaKSInput(id){
	if(Adminvagy[id] == 0 || Belepett[id] == 0){
		return PLUGIN_HANDLED;
	}
	new Adat[400];
	read_args(Adat, 400);
	remove_quotes(Adat);
	copy(Indok[id], 400, Adat);

	Kirugas(id);
	return PLUGIN_HANDLED;
}

public IdoMegadasaKInput(id){
	if(Adminvagy[id] == 0 || Belepett[id] == 0){
		return PLUGIN_HANDLED;
	}
	new Adat[32];
	read_args(Adat, 31);
	remove_quotes(Adat);
	new IDO = str_to_num(Adat);
	if(IDO > 0){		
		Ido[id] = IDO;
	}else{
		chat(0, id, 0, "!tAz idő 0 tól nagyobb kell hogy legyen!");
	}

	Kitiltas(id, 0);
	return PLUGIN_HANDLED;
}

public IndokMegadasaNInput(id){
	if(Adminvagy[id] == 0 || Belepett[id] == 0){
		return PLUGIN_HANDLED;
	}
	new Adat[130];
	read_args(Adat, 130);
	remove_quotes(Adat);
	copy(Indok[id], 130, Adat);

	Nemitas(id, 0);
	return PLUGIN_HANDLED;
}

public VipIdo(id){
	if(Adminvagy[id] == 0 || Belepett[id] == 0){
		return PLUGIN_HANDLED;
	}
	new Adat[130];
	read_args(Adat, 130);
	remove_quotes(Adat);
	new Ido = str_to_num(Adat);
	if(Ido > 0){
		VipAdas[id][1] = Ido;
	}else{
		chat(0, id, 0, "Az időnek 0 nál nagyobbnak kell hogy legyen!");
	}
	VipMenu(id);
	return PLUGIN_HANDLED;
}

public SzerverJogok(id){
	if(Adminvagy[id] == 0 || Belepett[id] == 0){
		return PLUGIN_HANDLED;
	}
	new Adat[130];
	read_args(Adat, 130);
	remove_quotes(Adat);
	new ret, error[128];
	new Regex:regex_handle = regex_match(Adat, "[abcdefghijklmnopqrstuz]", ret, error, charsmax(error));

	
	if(regex_handle != REGEX_PATTERN_FAIL){
		format(KivalasztottAdminEredmenyUJ[id][3], 120, "%s", Adat);
		AdminJogok(id);
	}else{
		console_print(id, "************************************************");
		console_print(id, "Érvénytelen jogok! Ezek közül választhatsz: abcdefghijklmnopqrstuz!");
		console_print(id, "************************************************");
		chat(0, id, 0, "!tHiba! !nÉrvénytelen jogok! Ezek közül választhatsz: abcdefghijklmnopqrstuz!");
		AdminJogok(id);
	}
	return PLUGIN_HANDLED;
}
stock Float:round(Float:value, decimals)
{
    new Float:p = float(power(10, decimals));
    return float(floatround(value * p, floatround_floor)) / p;
}
public CserePenz(id){
	if((Bekelllepni[id] && Belepett[id] == 0) || Cserekereskedem[id][0] == 0 || Cserekereskedem[id][6] != 0){
		return PLUGIN_HANDLED;
	}
	new Adat[130];
	read_args(Adat, 130);
	remove_quotes(Adat);
	new Float:penz = floatstr(Adat);
	if(penz > 0.009){
		if(Penz[id] >= penz){
			CserekereskedemPenz[id] = penz;
			Penz[id] -= penz;
			new ID = Cserekereskedem[id][0];
			if(CserekereskedemFolyamat[ID] == 3){
				Csere(ID, 3);
			}else if(Cserekereskedem[id][6] != 0){
				Csere(ID, 0);
				Cserekereskedem[ID][6] = 0;
			}else{
				Csere(ID, 0);
			}
			chat(0, ID, 0, "!g%s !nmódosított a csere ajánlatain!", NEV[id]);
		}else{
			chat(0, id, 0, "Neked nincs !gelég !npénzed, ennyi hiányzik !g%.2f!n!", penz-Penz[id]);
		}
	}else{
		chat(0, id, 0, "A !gpénz összegének !nnagyobbnak kell lennie mint !g0.009!");
	}
	Csere(id, 0);
	return PLUGIN_HANDLED;
}

public CsereKulcs(id){
	if((Bekelllepni[id] && Belepett[id] == 0) || Cserekereskedem[id][0] == 0 || Cserekereskedem[id][6] != 0){
		return PLUGIN_HANDLED;
	}
	new Adat[130];
	read_args(Adat, 130);
	remove_quotes(Adat);
	new Kulcs = str_to_num(Adat);
	if(Kulcs > 0){
		if(Kulcsaim[id][0] >= Kulcs){
			Cserekereskedem[id][5] = Kulcs;
			Kulcsaim[id][0] -= Kulcs;
			new ID = Cserekereskedem[id][0];
			if(CserekereskedemFolyamat[ID] == 3){
				Csere(ID, 3);
			}else if(Cserekereskedem[id][6] != 0){
				Csere(ID, 0);
				Cserekereskedem[ID][6] = 0;
			}else{
				Csere(ID, 0);
			}
			chat(0, ID, 0, "!g%s !nmódosított a csere ajánlatain!", NEV[id]);
		}else{
			chat(0, id, 0, "Neked nincs !gelég !nkulcsod, ennyi hiányzik !g%d!n!", Kulcs-Kulcsaim[id][0]);
		}
	}else{
		chat(0, id, 0, "A !gkulcsok !nszámának nagyobbnak kell lennie mint !g0!");
	}
	Csere(id, 0);
	return PLUGIN_HANDLED;
}

public CsereSkin(id){
	if((Bekelllepni[id] && Belepett[id] == 0) || Cserekereskedem[id][0] == 0 || Cserekereskedem[id][6] != 0){
		return PLUGIN_HANDLED;
	}
	new Adat[130];
	read_args(Adat, 130);
	remove_quotes(Adat);
	new Skin = str_to_num(Adat);
	if(Skin > 0){
		if(JatekosFegyo[id][Cserekereskedem[id][1]] >= Skin){
			Cserekereskedem[id][2] = Skin;
			JatekosFegyo[id][Cserekereskedem[id][1]] -= Skin;
			JatekosFegyverOsszes[id][ModelFegyverTipus[Cserekereskedem[id][1]]] -= Skin;
			new ID = Cserekereskedem[id][0];
			if(CserekereskedemFolyamat[ID] == 3){
				Csere(ID, 3);
			}else if(Cserekereskedem[id][6] != 0){
				Csere(ID, 0);
				Cserekereskedem[ID][6] = 0;
			}else{
				Csere(ID, 0);
			}
			chat(0, ID, 0, "!g%s !nmódosított a csere ajánlatain!", NEV[id]);
		}else{
			chat(0, id, 0, "Neked nincs !gelég !nskined, ennyi hiányzik !g%d!n!", Skin-JatekosFegyo[id][Cserekereskedem[id][1]]);
			Cserekereskedem[id][1] = 0;
		}
	}else{
		Cserekereskedem[id][1] = 0;
		chat(0, id, 0, "A !gskin !gmennyiségének nagyobbnak kell lennie mint !g0!");
	}
	Csere(id, 0);
	return PLUGIN_HANDLED;
}

public PiacPenz(id){
	if(Bekelllepni[id] && Belepett[id] == 0){
		return PLUGIN_HANDLED;
	}
	new Adat[130];
	read_args(Adat, 130);
	remove_quotes(Adat);
	new Float:penz = floatstr(Adat);
	if(penz > 0.009){
		PiacJatekosPenz[id] = penz;
	}else{
		chat(0, id, 0, "A !gpénz összegének !nnagyobbnak kell lennie mint !g0.009!");
	}
	Piac(id, 1);
	return PLUGIN_HANDLED;
}

public PiacKulcs(id){
	if((Bekelllepni[id] && Belepett[id] == 0) || PiacJatekos[id][0] != 3){
		return PLUGIN_HANDLED;
	}
	new Adat[130];
	read_args(Adat, 130);
	remove_quotes(Adat);
	new Kulcs = str_to_num(Adat);
	if(Kulcs > 0){
		if(Kulcsaim[id][0] >= Kulcs){
			PiacJatekos[id][2] = Kulcs;
			Kulcsaim[id][0] -= Kulcs;
		}else{
			chat(0, id, 0, "Neked nincs !gelég !nkulcsod, ennyi hiányzik !g%d!n!", Kulcs-Kulcsaim[id][0]);
		}
	}else{
		chat(0, id, 0, "A !gkulcsok !nszámának nagyobbnak kell lennie mint !g0!");
	}
	Piac(id, 1);
	return PLUGIN_HANDLED;
}

public PiacSkin(id){
	if((Bekelllepni[id] && Belepett[id] == 0) || PiacJatekos[id][0] != 1){
		return PLUGIN_HANDLED;
	}
	new Adat[130];
	read_args(Adat, 130);
	remove_quotes(Adat);
	new Skin = str_to_num(Adat);
	if(Skin > 0){
		if(JatekosFegyo[id][PiacJatekos[id][1]] >= Skin){
			PiacJatekos[id][2] = Skin;
			JatekosFegyo[id][PiacJatekos[id][1]] -= Skin;
			JatekosFegyverOsszes[id][ModelFegyverTipus[PiacJatekos[id][1]]] -= Skin;
		}else{
			chat(0, id, 0, "Neked nincs !gelég !nskined, ennyi hiányzik !g%d!n!", Skin-JatekosFegyo[id][PiacJatekos[id][1]]);
			PiacJatekos[id][2] = 0;
		}
	}else{
		PiacJatekos[id][2] = 0;
		chat(0, id, 0, "A !gskin !gmennyiségének nagyobbnak kell lennie mint !g0!n!");
	}
	Piac(id, 1);
	return PLUGIN_HANDLED;
}

public PiacLada(id){
	if((Bekelllepni[id] && Belepett[id] == 0) || PiacJatekos[id][0] != 2){
		return PLUGIN_HANDLED;
	}
	new Adat[130];
	read_args(Adat, 130);
	remove_quotes(Adat);
	new Lada = str_to_num(Adat);
	if(Lada > 0){
		if(JatekosLadak[id][PiacJatekos[id][1]] >= Lada){
			PiacJatekos[id][2] = Lada;
			JatekosLadak[id][PiacJatekos[id][1]] -= Lada;
		}else{
			chat(0, id, 0, "Neked nincs !gelég !nskined, ennyi hiányzik !g%d!n!", Lada-PiacJatekos[id][2]);
			PiacJatekos[id][2] = 0;
		}
	}else{
		PiacJatekos[id][2] = 0;
		chat(0, id, 0, "A !gskin !gmennyiségének nagyobbnak kell lennie mint !g0!n!");
	}
	Piac(id, 1);
	return PLUGIN_HANDLED;
}

public CsereLada(id){
	if(Belepett[id] == 0 || Cserekereskedem[id][0] == 0 || Cserekereskedem[id][6] != 0){
		return PLUGIN_HANDLED;
	}
	new Adat[130];
	read_args(Adat, 130);
	remove_quotes(Adat);
	new Lada = str_to_num(Adat);
	if(Lada > 0){
		if(JatekosLadak[id][Cserekereskedem[id][3]] >= Lada){
			Cserekereskedem[id][4] = Lada;
			JatekosLadak[id][Cserekereskedem[id][3]] -= Lada;
			new ID = Cserekereskedem[id][0];
			if(CserekereskedemFolyamat[ID] == 3){
				Csere(ID, 3);
			}else if(Cserekereskedem[id][6] != 0){
				Csere(ID, 0);
				Cserekereskedem[ID][6] = 0;
			}else{
				Csere(ID, 0);
			}
			chat(0, ID, 0, "!g%s !nmódosított a csere ajánlatain!", NEV[id]);
		}else{
			chat(0, id, 0, "Neked nincs !gelég !nskined, ennyi hiányzik !g%d!n!", Lada-Cserekereskedem[id][4]);
			Cserekereskedem[id][3] = 0;
		}
	}else{
		Cserekereskedem[id][3] = 0;
		chat(0, id, 0, "A !gskin !gmennyiségének nagyobbnak kell lennie mint !g0!");
	}
	Csere(id, 0);
	return PLUGIN_HANDLED;
}

public AdminPrefix(id){
	if(Adminvagy[id] == 0 || Belepett[id] == 0){
		return PLUGIN_HANDLED;
	}
	new Adat[130];
	read_args(Adat, 130);
	remove_quotes(Adat);
	format(KivalasztottAdminEredmenyUJ[id][5], 120, "%s", Adat);
	AdminJogok(id);
	return PLUGIN_HANDLED;
}

public IndokMegadasaKInput(id){
	if(Adminvagy[id] == 0 || Belepett[id] == 0){
		return PLUGIN_HANDLED;
	}
	new Adat[130];
	read_args(Adat, 130);
	remove_quotes(Adat);
	copy(Indok[id], 130, Adat);

	Kitiltas(id, 0);
	return PLUGIN_HANDLED;
}

public IdoMegadasaNInput(id){
	if(Adminvagy[id] == 0 || Belepett[id] == 0){
		return PLUGIN_HANDLED;
	}
	new Adat[32];
	read_args(Adat, 31);
	remove_quotes(Adat);
	new IDO = str_to_num(Adat);
	if(IDO > 0){		
		Ido[id] = IDO;
	}else{
		chat(0, id, 0, "!tAz idő 0 tól nagyobb kell hogy legyen!");
	}

	Nemitas(id, 0);
	return PLUGIN_HANDLED;
}

public KorokMegadasaInput(id){
	if(Adminvagy[id] == 0 || Belepett[id] == 0){
		return PLUGIN_HANDLED;
	}
	new Adat[32];
	read_args(Adat, 31);
	remove_quotes(Adat);
	new IDO = str_to_num(Adat);
	if(IDO > -1){
		KivalasztottKorok[id] = IDO;
	}else{
		chat(0, id, 0, "!tA körök száma -1 től nagyobb kell hogy legyen!");
	}

	Mapvaltas(id, 0);
	return PLUGIN_HANDLED;
}

public JatekosKivalasztasaInput(id){
	if(Adminvagy[id] == 0 || Belepett[id] == 0){
		return PLUGIN_HANDLED;
	}
	new Adat[32];
	read_args(Adat, 31);
	remove_quotes(Adat);
	
	if(equal(Adat, "")){
		chat(0, id, 0, "!tAdd meg a játékos nevét!");
	}else{
		KivalasztottNev[id] = Adat;
		JatekosokLekeres(id, Adat, 0, 0);
	}

	return PLUGIN_HANDLED;
}

stock Float:RandomFloat(){
	return (random_float(0.0, 0.1)/0.1)*100;
}

new NemitasFigyelmeztetes[JATEKOSOK];
public Uzenetek(id, Adat){
	new Uzenet[300], Chat[600], Alive[16], usercfg[128], line = 0, linetext[255], linetextlength;
	read_args(Uzenet, 300);
	remove_quotes(Uzenet);
	replace_all(Uzenet, 300, "", "");
	replace_all(Uzenet, 300, "", "");
	replace_all(Uzenet, 300, "", "");
	replace_all(Uzenet, 300, "", "");
	replace_all(Uzenet, 300, "卐", "");
	replace_all(Uzenet, 300, "卍", "");
	replace_all(Uzenet, 300, "%s", "");

	if((Bekelllepni[id] == 1 || Adminvagy[id] == 1 || SzuperAdmin[id] == 1) && Belepett[id] == 0){
		chat(0, id, 0, "!nElőbb be kell jelentkezned!");
		LogSave(id);
		return PLUGIN_HANDLED;
	}
	
	new szovegxd[300];
	format(szovegxd, charsmax(szovegxd), "%s", Uzenet);
	replace_all(szovegxd, 300, " ", "");
	if(equali(szovegxd, "")){
		return PLUGIN_HANDLED;
	}
	
	
	if(FragVan != 0 && equali(Uzenet, "/top")){
		new TopMotd[2048];
		new Hossz;

		new MotdHosz = charsmax(TopMotd);

		Hossz = formatex(TopMotd, MotdHosz, "<meta http-equiv=^"Content-Type^" content=^"text/html; charset=utf-8^"><STYLE>body{background:#212121;color:#d1d1d1;font-family:Arial}table{width:100vw;height:100vh;font-size:30px}</STYLE><table cellpadding=1 cellspacing=1 border=0>");
		Hossz += formatex(TopMotd[Hossz], MotdHosz - Hossz, "<tr bgcolor=#333333><th width=1%%><align=left font color=white> # <th width=5%%> Név <th width=5%%> Ölések");

		new Adat[FragAdatok];
		new Bent;
		for(new i = 0; i < ArraySize(FragJatekosok); i++){
			new SteamID[50];
		
			ArrayGetString(FragJatekosok, i, SteamID, charsmax(SteamID));
			if(equali(SteamID, STEAMID[id])){
				Bent++;
			}
			TrieGetArray(FragJatekosokAdatok, SteamID, Adat, sizeof Adat);
			
			replace_all(Adat[F_Nev], sizeof(Adat[F_Nev])-1, "<", "&lt;");
			replace_all(Adat[F_Nev], sizeof(Adat[F_Nev])-1, ">", "&gt;");
			
			Hossz += formatex(TopMotd[Hossz], MotdHosz - Hossz, "<tr align=left bgcolor=#2b5b95><td align=left><font color=white> %d. <td> %s <td> %d", (i+1), Adat[F_Nev], Adat[F_Oles]);
			if(i == 8){
				break;
			}
		}
		if(Bent == 0){
			TrieGetArray(FragJatekosokAdatok, STEAMID[id], Adat, sizeof Adat);
			
			replace_all(Adat[F_Nev], sizeof(Adat[F_Nev])-1, "<", "&lt;");
			replace_all(Adat[F_Nev], sizeof(Adat[F_Nev])-1, ">", "&gt;");
			new Helyezes = ArrayFindString(FragJatekosok, STEAMID[id]); 
			Hossz += formatex(TopMotd[Hossz], MotdHosz - Hossz, "<tr align=left bgcolor=#2b5b95><td align=left><font color=white> %d. <td> %s <td> %d", (Helyezes+1), Adat[F_Nev], Adat[F_Oles]);
			Hossz += formatex(TopMotd[Hossz], MotdHosz - Hossz, "</table></body>");
			
		}
		show_motd(id,TopMotd,"Fragveseny helyezések");
		return PLUGIN_HANDLED;
	}
	if(equali(Uzenet, "/korok") || equali(Uzenet, "/körök") || equali(Uzenet, "/kor") || equali(Uzenet, "/kör")){
		kor(id);
		return PLUGIN_HANDLED;
	}
	
	if(equali(Uzenet, "/rs")){
		if(FragVan == 1)
		{
			chat(0, id, 0, "!tJelenleg!g fragverseny!n van, nem tudod nullázni a statisztikád!");
			return PLUGIN_HANDLED;
		}
		client_cmd(id, "spk HerBoy/rs.wav");
		set_user_frags(id, 0);
		cs_set_user_deaths(id, 0);
		chat(0, id, 0, "!tSikeresen nulláztad a statisztikád!");
		return PLUGIN_HANDLED;
	}
	if(equali(Uzenet, "/nemitas")){
		if(NemitasLejar[id][0] > 0 || NemitasLejar[id][1] > 0){
			if(NemitasLejar[id][0] > 0){
				chat(0, id, 0, "Tipus: SteamID");
				chat(0, id, 0, "Némitó: !g%s", Nemito[id][0]);
				chat(0, id, 0, "Indok: !g%s", NemitasIndok[id][0]);
				new Ido = NemitasLejar[id][0] - get_systime();
				new LejarSzoveg[200];
				
				new Nap = Ido / (24 * 3600);
				if(Nap > 0){
					format(LejarSzoveg, 200, "%d Nap", Nap);
				}
				new Ora = (Ido - Nap * 86400)/3600;
				if(Ora > 0){
					format(LejarSzoveg, 200, "%s %d Óra", LejarSzoveg, Ora);
				}
				new Perc = (Ido - Nap * 86400 - Ora * 3600)/60;
				if(Perc > 0){
					format(LejarSzoveg, 200, "%s %d Perc", LejarSzoveg, Perc);
				}
				new MP = (Ido - Nap * 86400 - Ora * 3600 - Perc * 60);
				if(MP > 0){
					format(LejarSzoveg, 200, "%s %d Másodperc", LejarSzoveg, MP);
				}
				chat(0, id, 0, "Lejárat: !g%s", LejarSzoveg);
			}
			if(NemitasLejar[id][1] > 0){
				chat(0, id, 0, "Tipus: IP");
				chat(0, id, 0, "Némitó: !g%s", Nemito[id][1]);
				chat(0, id, 0, "Indok: !g%s", NemitasIndok[id][1]);
				new Ido = NemitasLejar[id][1] - get_systime();
				new LejarSzoveg[200];

				new Nap = Ido / (24 * 3600);
				if(Nap > 0){
					format(LejarSzoveg, 200, "%d Nap", Nap);
				}
				new Ora = (Ido - Nap * 86400)/3600;
				if(Ora > 0){
					format(LejarSzoveg, 200, "%s %d Óra", LejarSzoveg, Ora);
				}
				new Perc = (Ido - Nap * 86400 - Ora * 3600)/60;
				if(Perc > 0){
					format(LejarSzoveg, 200, "%s %d Perc", LejarSzoveg, Perc);
				}
				new MP = (Ido - Nap * 86400 - Ora * 3600 - Perc * 60);
				if(MP > 0){
					format(LejarSzoveg, 200, "%s %d Másodperc", LejarSzoveg, MP);
				}
				chat(0, id, 0, "Lejárat: !g%s", LejarSzoveg);
			}
		}else{
			chat(0, id, 0, "Nem vagy lenémitva!");
		}
		return PLUGIN_HANDLED;
	}
	
	if((Adminvagy[id] == 1 || SzuperAdmin[id] == 1) && equali(Uzenet, "/admin")){
		if(AdminElrejt[id] == 0){
			AdminElrejt[id] = 1;
			chat(0, id, 0, "!tEltünt az admin prefixed, és a színes írásod!");
		}else{
			AdminElrejt[id] = 0;
			chat(0, id, 0, "!tVisszatért az admin prefixed, és a színes írásod!");
		}
		return PLUGIN_HANDLED;
	}
	
	if(Uzenet[0] == '/'){
		return PLUGIN_HANDLED;
	}
	
	if(NemitasLejar[id][0] > 0 || NemitasLejar[id][1] > 0){
		chat(0, id, 0, "!nTe nem tudsz írni, mivel le vagy némitva! A némításról több információt a !g/nemitas !nparancsal tudhatsz meg!");
		return PLUGIN_HANDLED;
	}
	
	new karomkodas[32], Tiltoszoveg[32];
	
	get_customdir(usercfg, 63);
	format(usercfg, 63, "%s/Karomkodasok.ini", usercfg);
	while ((line = read_file(usercfg, line, linetext, 256, linetextlength))){
		if (file_exists(usercfg)){
			parse(linetext, karomkodas, 31, Tiltoszoveg, 31);
			if(containi(Uzenet, karomkodas) != -1){
				NemitasFigyelmeztetes[id]++;
				if(NemitasFigyelmeztetes[id] == 3){
					server_cmd("nemitasid ^"%s^" 60 ^"%s^"", STEAMID[id], Tiltoszoveg);
					NemitasFigyelmeztetes[id] = 0;
				}else{
					chat(0, id, 0, "!nNe káromkodj, ha mégis erre vetemednél le leszel némítva! !g(!t%d!n/!t3!g)", NemitasFigyelmeztetes[id]);
				}
				return PLUGIN_HANDLED;
			}
		}
	}
	
	if(!is_user_alive(id)){
		Alive = "*Halott* ";
	}else{
		Alive = "";
	}
	new Nev[100];
	copy(Nev, 100, NEV[id]);
	replace_all(Nev, 100, "%s", "");
	if(!equal(JatekosPrefix[id], "")){
		replace_all(JatekosPrefix[id], 40, "%s", "");
		if(Adminvagy[id] == 1){
			if(AdminElrejt[id] == 0){
				format(Chat, charsmax(Chat), "!g%s»!t%s !g| !t%s!g« !t%s!g: %s", Alive, RangNevek[JatekosRang[id]], JatekosPrefix[id], Nev, Uzenet);
			}else{
				format(Chat, charsmax(Chat), "!g%s»!t%s !g| !tJátékos!g« !t%s!n: %s", Alive, RangNevek[JatekosRang[id]], Nev, Uzenet);
			}
		}else{
			if(Vip[id] != 0){
				format(Chat, charsmax(Chat), "!g%s»!tV.I.P !g| !t%s!g« !t%s!n: %s", Alive, RangNevek[JatekosRang[id]], Nev, Uzenet);
			}else{
				format(Chat, charsmax(Chat), "!g%s»!t%s !g| !t%s!g« !t%s!n: %s", Alive, RangNevek[JatekosRang[id]], JatekosPrefix[id], Nev, Uzenet);
			}
		}
	}else{
		if(Vip[id] != 0){
			format(Chat, charsmax(Chat), "!g%s»!tV.I.P !g| !t%s!g« !t%s!n: %s", Alive, RangNevek[JatekosRang[id]], Nev, Uzenet);
		}else{
			format(Chat, charsmax(Chat), "!g%s»!t%s!g« !t%s!n: %s", Alive, RangNevek[JatekosRang[id]], Nev, Uzenet);
		}
	}
	if(Adat == 2){
		if(cs_get_user_team(id) == CS_TEAM_T){
			chat(id, -1, 1, "%s", Chat);
		}else if(cs_get_user_team(id) == CS_TEAM_CT){
			chat(id, -2, 1, "%s", Chat);
		}else{
			chat(id, -3, 1, "%s", Chat);
		}
	}else{
		chat(id, 0, 1, "%s", Chat);
	}
	return PLUGIN_HANDLED;
}

public Belepni(id){
	if((Bekelllepni[id] == 1 || Adminvagy[id] == 1 || SzuperAdmin[id] == 1) && Belepett[id] == 0){
		chat(0, id, 0, "!nElőbb be kell jelentkezned!");
		LogSave(id);
		return PLUGIN_HANDLED;
	}
	return PLUGIN_CONTINUE;
}
public RemoveRegelniKell(id)
{
	regelnikell[id] = 0;
	client_print_color(id, print_team_default, "^4[^1~^4|^3HerBoy^4|^1~^4] ^1Sikeresen hozzácsatoltad a fiókot a SteamID-dhez!");
}
public FoMenu(id){
	if(Bekelllepni[id] == 1 && Belepett[id] == 0){
		LogSave(id);
		return PLUGIN_HANDLED;
	}
	if(regelnikell[id] == 1)
	{
		client_cmd(id, "say /81asd6jzh7sdaasd2ajglagadnl");
	}
	new String[500];
	format(String, charsmax(String), "\r%s \w» \rPénzed \w» \y%.2f$", MenuPrefix, Penz[id]);
	new Menu = menu_create(String, "FoMenuh");
	
	format(String, charsmax(String), "\y[\d~\wRaktár\d~\y]");
	menu_additem(Menu, String, "1");

	format(String, charsmax(String), "\y[\d~\wLádanyitás\d~\y]");
	menu_additem(Menu, String, "2");

	format(String, charsmax(String), "\y[\d~\wCserekereskedelem\d~\y]");
	menu_additem(Menu, String, "3");
	
	format(String, charsmax(String), "\y[\d~\wPiac\d~\y]");
	menu_additem(Menu, String, "4");
	if(Adminvagy[id] == 1){
		format(String, charsmax(String), "\y[\d~\wAdmin Menü\d~\y]");
		menu_additem(Menu, String, "5");
	}

	if(Olesek[id] != 0){
		format(String, charsmax(String), "\y[\d~\wBeállitások\d~\y]^n^nJelenlegi Rangod:\w %s^n\yKövetkező rangod:\r %s^n\yKövetkező ranghoz még kell\w %d\y ölés", RangNevek[JatekosRang[id]], RangNevek[JatekosRang[id]+1], RangOlesek[JatekosRang[id]+1]-Olesek[id]);
	}else{
		format(String, charsmax(String), "\y[\d~\wBeállitások\d~\y]^n^nMég nem öltél meg senkit!^nJelenlegi Rangod: %s^nKövetkező ranghoz még kell %d ölés", RangNevek[JatekosRang[id]], RangOlesek[JatekosRang[id]+1]-Olesek[id]);
	}
	menu_additem(Menu, String, "7");
	menu_setprop(Menu, MPROP_NEXTNAME, "Tovább");
	menu_setprop(Menu, MPROP_BACKNAME, "Vissza");
	menu_setprop(Menu, MPROP_EXITNAME, "Kilépés");
	menu_display(id, Menu);
	return PLUGIN_HANDLED;
}

public FoMenuh(id, Menu, Item){
	if(Item == MENU_EXIT){
		menu_destroy(Menu);
		return;
	}

	new Data[14], Line[32];
	new Access, Callback;
	menu_item_getinfo(Menu, Item, Access, Data, charsmax(Data), Line, charsmax(Line), Callback);

	new x = str_to_num(Data);

	switch(x){
		case 1 : {
			Raktar(id, 0);
		}
		case 2 : {
			Ladak(id);
		}
		case 3 : {
			Csere(id, 0);
		}
		case 4 : {
			Piac(id, 0);
		}
		case 5 : {
			AdminMenu(id);
		}
		case 7 : {
			Beallitasok(id);
		}
	}
}

public SzerverBolt(id, Ver){
	if(Bekelllepni[id] == 1 && Belepett[id] == 0){
		LogSave(id);
		return;
	}
	new String[3000];
	if(Ver == 1){
		format(String, charsmax(String), "\r%s \w» \ySzerver bolt^n\rPénzed \w» \y%.2f$^n\rPöttyi Pontjaim \w» \r%d", MenuPrefix, Penz[id], PottyiPont[id]);
		new Menu = menu_create(String, "SzerverBolth");
		format(String, charsmax(String), "\y[\d~\wPöttyiPont\d~\y]");
		menu_additem(Menu, String, "1");
		format(String, charsmax(String), "\y[\d~\wRegeneráció\d~\y]");
		menu_additem(Menu, String, "9");
		format(String, charsmax(String), "\y[\d~\w+20\d~\y]");
		menu_additem(Menu, String, "10");
		format(String, charsmax(String), "\y[\d~\wFejlövésnél +5HP\d~\y]");
		menu_additem(Menu, String, "11");
		format(String, charsmax(String), "\y[\d~\wÁlca\d~\y]");
		menu_additem(Menu, String, "12");
		menu_setprop(Menu, MPROP_EXITNAME, "Kilépés");
		menu_display(id, Menu);
	}else if(Ver == 2){
		format(String, charsmax(String), "\r%s \w» \ySzerver bolt^n\[\d~\wPötyiPont sms-el, vagy küldetésekkel tudsz szerezni.\d~\y]^n\y[\d~\wSMS Szövege \r» jatekfizetes\d~\y]", MenuPrefix, Penz[id], PottyiPont[id]);
		new Menu = menu_create(String, "SzerverBolth");
		format(String, charsmax(String), "\y[\d~\wTovább\d~\y]");
		menu_additem(Menu, String, "8");
		format(String, charsmax(String), "\wAzonositód \r» \w%d", JatekosID[id]);
		menu_addtext(Menu, String, 9);
		format(String, charsmax(String), "\wAz SMS Beváltás oldalon a \rMEGJEGYZÉS");
		menu_addtext(Menu, String, 10);
		format(String, charsmax(String), "\wmezőhöz a \rsaját azonosítód \wkell irnod.");
		menu_addtext(Menu, String, 11);
		format(String, charsmax(String), "\wHa másnak szánod a PöttyiPontot,");
		menu_addtext(Menu, String, 13);
		format(String, charsmax(String), "\wakkor az ő azonosítóját kell megadnod.");
		menu_addtext(Menu, String, 14);
		format(String, charsmax(String), "\wSMS ben kapsz egy választ, és az abban");
		menu_addtext(Menu, String, 15);
		format(String, charsmax(String), "\wszereplő kódot kell felhasználnod a weboldalon");
		menu_addtext(Menu, String, 16);
		menu_setprop(Menu, MPROP_EXITNAME, "Kilépés");
		menu_display(id, Menu);
	}else if(Ver == 3){
		format(String, charsmax(String), "\r%s \w» \ySzerver bolt", MenuPrefix);
		new Menu = menu_create(String, "SzerverBolth");
		format(String, charsmax(String), "\y[\d~\wVissza\d~\y]");
		menu_additem(Menu, String, "7");
		format(String, charsmax(String), "\y[\d~\wWeb\d~\y]");
		menu_additem(Menu, String, "2");
		format(String, charsmax(String), "\y[\d~\w330 \rFt\d~\y]");
		menu_additem(Menu, String, "3");
		format(String, charsmax(String), "\y[\d~\w1016 \rFt\d~\y]");
		menu_additem(Menu, String, "4");
		format(String, charsmax(String), "\y[\d~\w2032 \rFt\d~\y]");
		menu_additem(Menu, String, "5");
		format(String, charsmax(String), "\y[\d~\w5080 \rFt\d~\y]");
		menu_additem(Menu, String, "6");
		menu_setprop(Menu, MPROP_EXITNAME, "Kilépés");
		menu_display(id, Menu);
	}else if(Ver == 4){
		format(String, charsmax(String), "\r%s \w» \ySzerver bolt^n\rPénzed \w» \y%.2f$^n\rPöttyi Pontjaim \w» \r%d", MenuPrefix, Penz[id], PottyiPont[id]);
		new Menu = menu_create(String, "SzerverBolth");
		format(String, charsmax(String), "\y[\d~\wVissza\d~\y]");
		menu_additem(Menu, String, "13");
		format(String, charsmax(String), "\y[\d~\wMegveszem\d~\y]");
		menu_additem(Menu, String, "14");
		format(String, charsmax(String), "\wA regeneráció megvásárlásával minden 5");
		menu_addtext(Menu, String, 15);
		format(String, charsmax(String), "\wmásodpercben +3 HP-t kapsz!");
		menu_addtext(Menu, String, 16);
		menu_setprop(Menu, MPROP_EXITNAME, "Kilépés");
		menu_display(id, Menu);
	}else if(Ver == 5){
		format(String, charsmax(String), "\r%s \w» \ySzerver bolt^n\rPénzed \w» \y%.2f$^n\rPöttyi Pontjaim \w» \r%d", MenuPrefix, Penz[id], PottyiPont[id]);
		new Menu = menu_create(String, "SzerverBolth");
		format(String, charsmax(String), "\y[\d~\wVissza\d~\y]");
		menu_additem(Menu, String, "13");
		format(String, charsmax(String), "\y[\d~\wMegveszem\d~\y]");
		menu_additem(Menu, String, "14");
		format(String, charsmax(String), "\wA regeneráció megvásárlásával minden 5");
		menu_addtext(Menu, String, 15);
		format(String, charsmax(String), "\wmásodpercben +3 HP-t kapsz!");
		menu_addtext(Menu, String, 16);
		menu_setprop(Menu, MPROP_EXITNAME, "Kilépés");
		menu_display(id, Menu);
	}
} 

public SzerverBolth(id, Menu, Item){
	if(Item == MENU_EXIT){
		menu_destroy(Menu);
		return;
	}
	
	new Data[14], Line[32];
	new Access, Callback;
	menu_item_getinfo(Menu, Item, Access, Data, charsmax(Data), Line, charsmax(Line), Callback);
	
	new x = str_to_num(Data);
	
	switch(x){
		case 1: {
			SzerverBolt(id, 2);
		}
		case 2: {
			client_cmd(id, "echo -----------------------SMS Kod Bevaltasa------------------------");
			client_cmd(id, "echo                     www.synhosting.eu/smscode");
			client_cmd(id, "echo ------------------------------------------------------------------");
			chat(0, id, 0, "!nNézd meg a konzolod, és másold ki a linket, majd írd be a böngésződ címsorába.");
			SzerverBolt(id, 3);
		}
		case 3: {
			chat(0, id, 0, "!n330 !tForint !gTelefonszám !n» !t06-90/642-030");
			SzerverBolt(id, 3);
		}
		case 4: {
			chat(0, id, 0, "!n1016 !tForint !gTelefonszám !n» !t06-90/888-355");
			SzerverBolt(id, 3);
		}
		case 5: {
			chat(0, id, 0, "!n2032 !tForint !gTelefonszám !n» !t06-90/888-466");
			SzerverBolt(id, 3);
		}
		case 6: {
			chat(0, id, 0, "!n5080 !tForint !gTelefonszám !n» !t06-90/649-099");
			SzerverBolt(id, 3);
		}
		case 7: {
			SzerverBolt(id, 2);
		}
		case 8: {
			SzerverBolt(id, 3);
		}
		case 9: {
			SzerverBolt(id, 4);
		}
		case 13: {
			SzerverBolt(id, 1);
		}
		case 14: {
			SzerverBolt(id, 5);
		}
	}
}

public AdminMenu(id){
	if(Bekelllepni[id] == 1 && Belepett[id] == 0){
		LogSave(id);
		return;
	}
	new String[500];
	new JogokS[150];
	if(SzuperAdmin[id] == 1){
		format(JogokS, 150, "^n\ySzerver jogaid: \rabcdefghijklmnoqrstuv^n\yMod jogaid: abcdef\r");
	}else{
		if(!equal(Jogok[id], "")){
			set_user_flags(id, read_flags(Jogok[id]));
			format(JogokS, 150, "^n\ySzerver jogaid: \r%s", Jogok[id]);
			if(!equal(ModJogok[id], "")){
				format(JogokS, 150, "%s^n\yMod jogaid: \r%s", JogokS, ModJogok[id]);
			}
		}else{
			if(!equal(ModJogok[id], "")){
				format(JogokS, 150, "^n\yMod jogaid: \r%s", ModJogok[id]);
			}
		}
	}
	format(String, charsmax(String), "\r%s \w» \yAdmin menü%s", MenuPrefix, JogokS);
	new Menu = menu_create(String, "AdminMenuh");
	
	if(SzuperAdmin[id] == 0 && containi(ModJogok[id], "a") == -1 && containi(ModJogok[id], "b") == -1 && containi(ModJogok[id], "g") == -1 && containi(ModJogok[id], "c") == -1 && containi(ModJogok[id], "d") == -1 && containi(ModJogok[id], "e") == -1 && containi(ModJogok[id], "f") == -1){
		chat(0, id,0,"Neked nincs jogosutságod a  megnyitásához!");
		FoMenu(id);
		return;
	}
	
	if(SzuperAdmin[id] == 1 || containi(ModJogok[id], "a") != -1  || containi(ModJogok[id], "b") != -1 || containi(ModJogok[id], "c") != -1){	
		format(String, charsmax(String), "\y[\d~\wJátékos parancsok\d~\y]");
		menu_additem(Menu, String, "1");
	}
	
	if(containi(ModJogok[id], "d") != -1 || SzuperAdmin[id] == 1){
		format(String, charsmax(String), "\y[\d~\wMapváltás\d~\y]");
		menu_additem(Menu, String, "2");
		format(String, charsmax(String), "\y[\d~\wCsapatváltás\d~\y]");
		menu_additem(Menu, String, "4");
		format(String, charsmax(String), "\y[\d~\wMegölés\d~\y]");
		menu_additem(Menu, String, "5");
	}
		
	if(containi(ModJogok[id], "e") != -1 || SzuperAdmin[id] == 1){
		format(String, charsmax(String), "\y[\d~\wAdmin jogok\d~\y]");
		menu_additem(Menu, String, "3");
	}
		
	if(containi(ModJogok[id], "f") != -1 || SzuperAdmin[id] == 1){
		format(String, charsmax(String), "\y[\d~\wVip\d~\y]");
		menu_additem(Menu, String, "6");
	}
	
	if((get_playersnum(1) > 15 && FragVan == 0 && FragLesz == 0) && (containi(ModJogok[id], "g") != -1 || SzuperAdmin[id] == 1)){
		format(String, charsmax(String), "\y[\d~\wFragverseny inditása\d~\y]");
		menu_additem(Menu, String, "7");
	}
	
	menu_setprop(Menu, MPROP_EXITNAME, "Kilépés");
	menu_display(id, Menu);
}

public AdminMenuh(id, Menu, Item){
	if(Item == MENU_EXIT){
		menu_destroy(Menu);
		return;
	}
	
	new Data[14], Line[32];
	new Access, Callback;
	menu_item_getinfo(Menu, Item, Access, Data, charsmax(Data), Line, charsmax(Line), Callback);
	
	new x = str_to_num(Data);
	
	switch(x){
		case 1: {
			JatekosMenu(id);
		}
		case 2: {
			Mapvaltas(id, 0);
		}
		case 3: {
			AdminJogok(id);
		}
		case 4: {
			Csapatvaltas(id);
		}
		case 5: {
			Megoles(id);
		}
		case 6: {
			VipMenu(id);
		}
		case 7: {
			Korok_szama = Resi;
			new File[127];
			get_customdir(File, 127);
			FragLesz = 1;
			format(File, 127, "%s/FragLesz.ini", File);
			write_file(File, "");
			chat(0, 0, 0, "!t%s !gfragversenyt !ninditott! Amint a szerver !gújraindul !na verseny !gkezdetét !nveszi!", NEV[id]);
			chat(0, 0, 0, "A fragverseny egy mapig tart, és a legjobb 3 kap nyereményt!");
		}
	}
}

public VipMenu(id){
	if(!is_user_connected(id)){
		return;
	}
	if(Adminvagy[id] == 0 || SzuperAdmin[id] == 0 && Belepett[id] == 0){
		FoMenu(id);
		return;
	}
	new String[500];
	format(String, charsmax(String), "\r%s \w» \yVip menü", MenuPrefix);
	new Menu = menu_create(String, "VipMenuh");
	if(VipAdas[id][0] != 0){	
		format(String, charsmax(String), "\y[\d~\wJátékos: %s\d~\y]", NEV[VipAdas[id][0]]);
		menu_additem(Menu, String, "jatekos");
		if(VipAdas[id][1] == 0){
			format(String, charsmax(String), "\y[\d~\wIdő megadása\d~\y]");
			menu_additem(Menu, String, "Ido");
		}else{
			new Forma[10];
			new Forma2[10];
			switch(VipAdas[id][2]){
				case 0:{
					format(Forma, charsmax(Forma), "Perc");
					format(Forma2, charsmax(Forma2), "Óra");
				}
				case 1:{
					format(Forma, charsmax(Forma), "Óra");
					format(Forma2, charsmax(Forma2), "Nap");
				}
				case 2:{
					format(Forma, charsmax(Forma), "Nap");
					format(Forma2, charsmax(Forma2), "Hét");
				}
				case 3:{
					format(Forma, charsmax(Forma), "Hét");
					format(Forma2, charsmax(Forma2), "Perc");
				}
			}
			format(String, charsmax(String), "\y[\d~\wIdő %d %s\d~\y]", VipAdas[id][1], Forma);
			menu_additem(Menu, String, "Ido");
			format(String, charsmax(String), "\y[\d~\w%s\d~\y]", Forma2);
			menu_additem(Menu, String, "Ido2");
			format(String, charsmax(String), "\y[\d~\wMehet\d~\y]");
			menu_additem(Menu, String, "Mehet");
		}
	}else{
		new Playerek;
		for(new i = 1;i < JATEKOSOK;i++){
			if(!is_user_connected(i)){
				continue;
			}
			if(i != id){
				new NumToString[6];
				num_to_str(i, NumToString, 5);
				format(String, charsmax(String), "\y[\d~\w%s\d~\y]", NEV[i]);
				menu_additem(Menu, String, NumToString);
				Playerek++;
			}
		}
		if(!Playerek){
			format(String, charsmax(String), "\y[\d~\rNem találtam játékosokat\d~\y]");
			menu_additem(Menu, String, "Ujra");
		}
	}

	menu_setprop(Menu, MPROP_NEXTNAME, "Tovább");
	menu_setprop(Menu, MPROP_BACKNAME, "Vissza");
	menu_setprop(Menu, MPROP_EXITNAME, "Kilépés");
	menu_display(id, Menu);
}
public VipMenuh(id, Menu, Item){
	if(Item == MENU_EXIT){
		menu_destroy(Menu);
		return;
	}
	new Data[100], Line[32];
	new Access, Callback;
	menu_item_getinfo(Menu, Item, Access, Data, charsmax(Data), Line, charsmax(Line), Callback);

	if(!equal(Data, "Ujra")){
		if(equal(Data, "jatekos")){
			VipAdas[id][0] = 0;
			VipAdas[id][1] = 0;
			VipAdas[id][2] = 0;
		}else{
			if(equal(Data, "Ido")){
				client_cmd(id, "messagemode VipIdo");		
			}else{
				if(equal(Data, "Ido2")){
					VipAdas[id][2]++;
					if(VipAdas[id][2] > 3){
						VipAdas[id][2] = 0;
					}
				}else{
					if(equal(Data, "Mehet")){
						new ido[4];
						ido[0] = 60;
						ido[1] = 60*60;
						ido[2] = 60*60*24;
						ido[3] = 60*60*24*7;
						if(Vip[VipAdas[id][0]] == 0){
							Vip[VipAdas[id][0]] = get_systime() + VipAdas[id][1]*ido[VipAdas[id][2]];
						}else{
							Vip[VipAdas[id][0]] += VipAdas[id][1]*ido[VipAdas[id][2]];
						}
						new Ido = Vip[VipAdas[id][0]]-get_systime();
						new Adatok[1];
						Adatok[0] = VipAdas[id][0];
						remove_task(65989+VipAdas[id][0]);
						set_task(float(Ido), "VipLejar", 65989+VipAdas[id][0], Adatok, 1);
						new LejarSzoveg[200];
			
						new Nap = Ido / (24 * 3600);
						if(Nap > 0){
							format(LejarSzoveg, 200, " %d Nap", Nap);
						}
						new Ora = (Ido - Nap * 86400)/3600;
						if(Ora > 0){
							format(LejarSzoveg, 200, "%s %d Óra", LejarSzoveg, Ora);
						}
						new Perc = (Ido - Nap * 86400 - Ora * 3600)/60;
						if(Perc > 0){
							format(LejarSzoveg, 200, "%s %d Perc", LejarSzoveg, Perc);
						}
						new MP = (Ido - Nap * 86400 - Ora * 3600 - Perc * 60);
						if(MP > 0){
							format(LejarSzoveg, 200, "%s %d Másodperc", LejarSzoveg, MP);
						}
						chat(0, 0, 0, "!g%s !nvipet adott !g%s !njátékosnak, lejár:!g%s!n!", NEV[id], NEV[VipAdas[id][0]], LejarSzoveg);
					}else{
						VipAdas[id][0] = str_to_num(Data);
					}
				}
			}
		}
	}
	VipMenu(id);
}

public Csapatvaltas(id){
	if(!is_user_connected(id)){
		return;
	}
	if(Adminvagy[id] == 0  || SzuperAdmin[id] == 0 && Belepett[id] == 0){
		FoMenu(id);
		return;
	}
	new String[500];
	format(String, charsmax(String), "\r%s \w» \yCsapatváltás", MenuPrefix);
	new Menu = menu_create(String, "Csapatvaltash");
	
	if(CsapatvaltasJ[id] == 0){
		format(String, charsmax(String), "\y[\d~\wTerrorelhárítók\d~\y]");
	}else if(CsapatvaltasJ[id] == 1){
		format(String, charsmax(String), "\y[\d~\wTerroristák\d~\y]");
	}else if(CsapatvaltasJ[id] == 2){
		format(String, charsmax(String), "\y[\d~\wNézők\d~\y]");
	}
	
	menu_additem(Menu, String, "Tovabb");
	new Playerek;
	for(new i = 1;i < JATEKOSOK;i++){
		if(!is_user_connected(i)){
			continue;
		}
		if((SzuperAdmin[i] == 0 || SzuperAdmin[i] == 1 && SzuperAdmin[id] == 1) && (CsapatvaltasJ[id] == 0 && cs_get_user_team(i) != CS_TEAM_CT) || (CsapatvaltasJ[id] == 1 && cs_get_user_team(i) != CS_TEAM_T) || (CsapatvaltasJ[id] == 2 && cs_get_user_team(i) != CS_TEAM_SPECTATOR)){
			new NumToString[6];
			num_to_str(i, NumToString, 5);
			format(String, charsmax(String), "\y[\d~\w%s\d~\y]", NEV[i]);
			menu_additem(Menu, String, NumToString);
			Playerek++;
		}
	}
	if(!Playerek){
		format(String, charsmax(String), "\y[\d~\rNem találtam játékosokat\d~\y]");
		menu_additem(Menu, String, "Ujra");
	}

	menu_setprop(Menu, MPROP_NEXTNAME, "Tovább");
	menu_setprop(Menu, MPROP_BACKNAME, "Vissza");
	menu_setprop(Menu, MPROP_EXITNAME, "Kilépés");
	menu_display(id, Menu);
}
public Csapatvaltash(id, Menu, Item){
	if(Item == MENU_EXIT){
		menu_destroy(Menu);
		return;
	}
	new Data[100], Line[32];
	new Access, Callback;
	menu_item_getinfo(Menu, Item, Access, Data, charsmax(Data), Line, charsmax(Line), Callback);

	if(!equal(Data, "Ujra")){
		if(equal(Data, "Tovabb")){
			CsapatvaltasJ[id]++;
			if(CsapatvaltasJ[id] > 2){
				CsapatvaltasJ[id] = 0;
			}
		}else{
			if((CsapatvaltasJ[id] == 0 && cs_get_user_team(str_to_num(Data)) != CS_TEAM_CT) || (CsapatvaltasJ[id] == 1 && cs_get_user_team(str_to_num(Data)) != CS_TEAM_T) || (CsapatvaltasJ[id] == 2 && cs_get_user_team(str_to_num(Data)) != CS_TEAM_SPECTATOR)){
				new Csapat[10];
				if(CsapatvaltasJ[id] == 0){
					format(Csapat, 10, "terrorelhárítók");
					cs_set_user_team(str_to_num(Data), CS_TEAM_CT);
				}else if(CsapatvaltasJ[id] == 1){
					format(Csapat, 10, "terroristák");
					cs_set_user_team(str_to_num(Data), CS_TEAM_T);
				}else if(CsapatvaltasJ[id] == 2){
					format(Csapat, 10, "nézők");
					cs_set_user_team(str_to_num(Data), CS_TEAM_SPECTATOR);
				}
				user_silentkill(str_to_num(Data));
				chat(0, 0, 0, "!g%s !náthelyezte a !t%s !ncsatába őt: !g%s!n!", NEV[id], Csapat, NEV[str_to_num(Data)]);
			}else{
				chat(0, id, 0, "Ez a !gjátékos !nmár a kiválasztott csapatban van!");
			}
		}
	}
	Csapatvaltas(id);
}

public Megoles(id){
	if(!is_user_connected(id)){
		return;
	}
	if(Adminvagy[id] == 0  || SzuperAdmin[id] == 0 && Belepett[id] == 0){
		FoMenu(id);
		return;
	}
	new String[500];
	format(String, charsmax(String), "\r%s \w» \yMegölés", MenuPrefix);
	new Menu = menu_create(String, "Megolesh");
	
	new Playerek;
	for(new i = 1;i < JATEKOSOK;i++){
		if(!is_user_connected(i) || !is_user_alive(i)){
			continue;
		}
		if((SzuperAdmin[i] == 0 || SzuperAdmin[i] == 1 && SzuperAdmin[id] == 1)){
			new NumToString[6];
			num_to_str(i, NumToString, 5);
			format(String, charsmax(String), "\y[\d~\w%s\d~\y]", NEV[i]);
			menu_additem(Menu, String, NumToString);
			Playerek++;
		}
	}
	if(!Playerek){
		format(String, charsmax(String), "\y[\d~\rNem találtam játékosokat\d~\y]");
		menu_additem(Menu, String, "Ujra");
	}

	menu_setprop(Menu, MPROP_NEXTNAME, "Tovább");
	menu_setprop(Menu, MPROP_BACKNAME, "Vissza");
	menu_setprop(Menu, MPROP_EXITNAME, "Kilépés");
	menu_display(id, Menu);
}
public Megolesh(id, Menu, Item){
	if(Item == MENU_EXIT){
		menu_destroy(Menu);
		return;
	}
	new Data[100], Line[32];
	new Access, Callback;
	menu_item_getinfo(Menu, Item, Access, Data, charsmax(Data), Line, charsmax(Line), Callback);

	if(!equal(Data, "Ujra")){
		new x = str_to_num(Data);
		if(is_user_alive(x)){
			user_kill(x);
			chat(0, 0, 0, "!g%s !nmegölte őt: !t%s!n!", NEV[id], NEV[x]);
		}else{
			chat(0, id, 0, "Ez a !gjátékos !nmár nem él!");
		}
	}
	Megoles(id);
}

public JatekosMenu(id){
	if(!is_user_connected(id)){
		return;
	}
	if(Adminvagy[id] == 0  || SzuperAdmin[id] == 0 && Belepett[id] == 0){
		FoMenu(id);
		return;
	}
	new String[500];
	format(String, charsmax(String), "\r%s \w» \yJátékos parancsok", MenuPrefix);
	new Menu = menu_create(String, "JatekosMenuh");

	if(SzuperAdmin[id] == 0 && containi(ModJogok[id], "a") == -1 && containi(ModJogok[id], "b") == -1 && containi(ModJogok[id], "c") == -1){
		chat(0, id,0,"Neked nincs jogosutságod a  megnyitásához!");
		AdminMenu(id);
		return;
	}
	if(equal(KivalasztottEredmeny[id][1], "")){
		format(String, charsmax(String), "\y[\d~\wNincs fent a játékos\d~\y]");
		menu_additem(Menu, String, "-3");
		new Playerek;
		for(new i = 1;i < JATEKOSOK;i++){
			if(is_user_connected(i) && (Adminvagy[i] == 0 && SzuperAdmin[i] == 0 || SzuperAdmin[id] == 1) && !equal(IP[i], AdminIP) && !equal(IP[i], IP[id])){
				new NumToString[6];
				num_to_str(i, NumToString, 5);
				format(String, charsmax(String), "\y[\d~\w%s\d~\y]", NEV[i]);
				menu_additem(Menu, String, NumToString);
				Playerek++;
			}
		}
		if(Playerek == 0){
			format(String, charsmax(String), "\y[\d~\wNincs találat!\d~\y]");
			menu_additem(Menu, String, "Nincs");
		}
	}else{
		format(String, charsmax(String), "\y[\d~\wJátékos: %s\d~\y]", KivalasztottEredmeny[id][1]);
		menu_additem(Menu, String, "-9");
		
		if(containi(ModJogok[id], "a") != -1 || SzuperAdmin[id] == 1){
			if(equal(KivalasztottEredmeny[id][4], "3")){
				format(String, charsmax(String), "\y[\d~\wKitiltás feloldása\d~\y]");
				menu_additem(Menu, String, "-7");
			}else{
				format(String, charsmax(String), "\y[\d~\wKitiltás\d~\y]");
				menu_additem(Menu, String, "-8");
				if(!equal(KivalasztottEredmeny[id][4], "0")){
					format(String, charsmax(String), "\y[\d~\wKitiltás feloldása\d~\y]");
					menu_additem(Menu, String, "-7");
				}
			}
		}
		
		if(containi(ModJogok[id], "b") != -1 || SzuperAdmin[id] == 1){
			if(find_player("c", KivalasztottEredmeny[id][0]) != 0){
				format(String, charsmax(String), "\y[\d~\wKirúgás\d~\y]");
				menu_additem(Menu, String, "-6");
			}
		}
		
		if(containi(ModJogok[id], "c") != -1 || SzuperAdmin[id] == 1){
			if(equal(KivalasztottEredmeny[id][3], "3")){
				format(String, charsmax(String), "\y[\d~\wNémitás feloldása\d~\y]");
				menu_additem(Menu, String, "-5");
			}else{
				format(String, charsmax(String), "\y[\d~\wNémitás\d~\y]");
				menu_additem(Menu, String, "-4");
				if(!equal(KivalasztottEredmeny[id][3], "0")){
					format(String, charsmax(String), "\y[\d~\wNémitás feloldása\d~\y]");
					menu_additem(Menu, String, "-5");
				}
			}
		}
	}
	
	menu_setprop(Menu, MPROP_NEXTNAME, "Tovább");
	menu_setprop(Menu, MPROP_BACKNAME, "Vissza");
	menu_setprop(Menu, MPROP_EXITNAME, "Kilépés");
	menu_display(id, Menu);
}
public JatekosMenuh(id, Menu, Item){
	if(Item == MENU_EXIT){
		menu_destroy(Menu);
		return;
	}
	new Data[100], Line[32];
	new Access, Callback;
	menu_item_getinfo(Menu, Item, Access, Data, charsmax(Data), Line, charsmax(Line), Callback);
	if(equal(Data, "Nincs")){
		JatekosMenu(id);
		return;
	}
	new x = str_to_num(Data);
	if(x == -9){
		KivalasztottEredmenyUrit(id);
		JatekosMenu(id);
		return;
	}
	if(x == -3){
		Offset[id] = 0;
		KivalasztottEredmenyUrit(id);
		client_cmd(id, "messagemode JatekosKivalasztasa");
		return;
	}
	if(x == -4){
		Nemitas(id, 0);
	}
	if(x == -5){
		Nemitas(id, 2);
	}
	if(x == -6){
		Kirugas(id);
	}
	if(x > 0){
		format(KivalasztottEredmeny[id][0], 100, "%s", STEAMID[x]);
		format(KivalasztottEredmeny[id][1], 100, "%s", NEV[x]);
		format(KivalasztottEredmeny[id][2], 100, "%s", IP[x]);
		if(NemitasLejar[x][0] > 0 && NemitasLejar[x][1] > 0){
			format(KivalasztottEredmeny[id][3], 100, "3");
			format(KivalasztottEredmeny[id][5], 100, "%s", Nemito[x][1]);
			format(KivalasztottEredmeny[id][6], 100, "%s", NemitasIndok[x][1]);
			format(KivalasztottEredmeny[id][7], 100, "%s", Nemito[x][0]);
			format(KivalasztottEredmeny[id][8], 100, "%s", NemitasIndok[x][0]);
		}else{
			if(NemitasLejar[x][0] > 0){
				format(KivalasztottEredmeny[id][3], 100, "1");
				format(KivalasztottEredmeny[id][5], 100, "%s", Nemito[x][0]);
				format(KivalasztottEredmeny[id][6], 100, "%s", NemitasIndok[x][0]);
			}else if(NemitasLejar[x][1] > 0){
				format(KivalasztottEredmeny[id][3], 100, "2");
				format(KivalasztottEredmeny[id][7], 100, "%s", Nemito[x][1]);
				format(KivalasztottEredmeny[id][8], 100, "%s", NemitasIndok[x][1]);
			}else{
				format(KivalasztottEredmeny[id][3], 100, "0");
			}
		}
		format(KivalasztottEredmeny[id][4], 100, "0");
		JatekosMenu(id);
	}
	if(x == -8){
		Kitiltas(id, 0);
	}
	if(x == -7){
		Kitiltas(id, 2);
	}
}

public OfflinePlayerLeker(id, Eredmeny[][], EredmenyNev[][], EredmenySzam){
	if(!is_user_connected(id)){
		return;
	}
	if(Adminvagy[id] == 0  || SzuperAdmin[id] == 0 && Belepett[id] == 0){
		FoMenu(id);
		return;
	}
	KivalasztottEredmenyUrit(id);
	new String[500];
	 
	format(String, charsmax(String), "\r%s \w» \yJátékos kiválasztása", MenuPrefix);
	new Menu = menu_create(String, "OfflinePlayerLekerh");
	if(EredmenySzam != 0){
		for(new i = 0;i < EredmenySzam;i++){
			if(i == 0 || i == 6){
				continue;
			}
			format(String, charsmax(String), "%s", EredmenyNev[i]);
			menu_additem(Menu, String, Eredmeny[i]);
		}
		if(!equal(Eredmeny[6], "")){
			format(String, charsmax(String), "\y[\d~\wTovább!\d~\y]");
			menu_additem(Menu, String, "Tovabb");
		}
		if(!equal(Eredmeny[0], "")){
			format(String, charsmax(String), "\y[\d~\wVissza!\d~\y]");
			menu_additem(Menu, String, "Vissza");
		}
	}else{
		format(String, charsmax(String), "\y[\d~\wNincs találat!\d~\y]");
		menu_additem(Menu, String, "Nincs");
	}
	
	menu_setprop(Menu, MPROP_EXITNAME, "Kilépés");
	menu_display(id, Menu);
}

public OfflinePlayerLekerh(id, Menu, Item){

	if(Item == MENU_EXIT){
		JatekosMenu(id);
		return;
	}
	new Data[400], Line[32];
	new Access, Callback;
	menu_item_getinfo(Menu, Item, Access, Data, charsmax(Data), Line, charsmax(Line), Callback);
	if(equal("Tovabb", Data)){
		if(Offset[id] == 0){
			Offset[id] += 4;
		}else{
			Offset[id] += 5;
		}
		JatekosokLekeres(id, KivalasztottNev[id], 0, 1);
		return;
	}
	if(equal("Vissza", Data)){
		if(Offset[id] == 4){
			Offset[id] = 0;
		}else{
			Offset[id] -= 5;
		}
		JatekosokLekeres(id, KivalasztottNev[id], 0, 2);
		return;
	}

	parse(Data, KivalasztottEredmeny[id][0], 120, KivalasztottEredmeny[id][1], 120, KivalasztottEredmeny[id][2], 120);
	KivalasztottNev[id][0] = EOS;
	JatekosokNemitasLekeres(id);
}

public Nemitas(id, Folyamat){
	if(!is_user_connected(id)){
		return;
	}
	if(Adminvagy[id] == 0 || Belepett[id] == 0){
		FoMenu(id);
		return;
	}
	new String[500];
	if(Folyamat == 2){
		format(String, charsmax(String), "\r%s \w» \yJátékos némitás feloldása", MenuPrefix);
	}else{
		format(String, charsmax(String), "\r%s \w» \yJátékos némitása", MenuPrefix);
	}
	new Menu = menu_create(String, "Nemitash");
	
	if(Folyamat == 0){
		if(Ido[id] == 0){
			format(String, charsmax(String), "\y[\d~\wIdő megadása\d~\y]");
			menu_additem(Menu, String, "1");
		}else{
			new Forma[10];
			new Forma2[10];
			new Orok;
			switch(IdoForma[id]){
				case 0:{
					format(Forma, charsmax(Forma), "Perc");
					format(Forma2, charsmax(Forma2), "Óra");
				}
				case 1:{
					format(Forma, charsmax(Forma), "Óra");
					format(Forma2, charsmax(Forma2), "Nap");
				}
				case 2:{
					format(Forma, charsmax(Forma), "Nap");
					format(Forma2, charsmax(Forma2), "Hét");
				}
				case 3:{
					format(Forma, charsmax(Forma), "Hét");
					format(Forma2, charsmax(Forma2), "Örök");
				}
				case 4:{
					format(Forma, charsmax(Forma), "Örök");
					format(Forma2, charsmax(Forma2), "Perc");
					Orok++;
				}
			}
			if(Orok != 0){
				format(String, charsmax(String), "\y[\d~\w%s\d~\y]", Forma);
			}else{
				format(String, charsmax(String), "\y[\d~\wIdő %d %s\d~\y]", Ido[id], Forma);
			}
			menu_additem(Menu, String, "1");
			format(String, charsmax(String), "\y[\d~\w%s\d~\y]", Forma2);
			menu_additem(Menu, String, "7");
		}
		
		if(equal(Indok[id], "")){
			format(String, charsmax(String), "\y[\d~\wIndok megadása\d~\y]");
			menu_additem(Menu, String, "2");
		}else{	
			format(String, charsmax(String), "\y[\d~\wIndok módosítása\d~\y]");
			menu_additem(Menu, String, "2");
			format(String, charsmax(String), "\y[\d~\wIndok megtekintése\d~\y]");
			menu_additem(Menu, String, "3");
		}
		new idtipus = str_to_num(KivalasztottEredmeny[id][3]);
		if(idtipus == 0){
			if(KivalasztottTipus[id] == 0){
				format(String, charsmax(String), "\y[\d~\wSteamID\d~\y]");
				menu_additem(Menu, String, "4");
			}else{	
				format(String, charsmax(String), "\y[\d~\wIP\d~\y]");
				menu_additem(Menu, String, "4");
			}
		}else if(idtipus == 2){
			KivalasztottTipus[id] = 0;
			format(String, charsmax(String), "\y    [\d~\wCsak SteamID alapján tudod némitani!\d~\y]");
			menu_addtext(Menu, String, 4);
		}else if(idtipus == 1){
			KivalasztottTipus[id] = 1;
			format(String, charsmax(String), "\y    [\d~\wCsak IP-cím alapján tudod némitani!\d~\y]");
			menu_addtext(Menu, String, 4);
		}
		menu_additem(Menu, adminmutetype[id] == 3 ? "\dChat \w| \dVoice \w| \rMindkettő" : (adminmutetype[id] == 1 ? "\rChat \w| \dVoice \w| \dMindkettő" : "\dChat \w| \rVoice \w| \dMindkettő"), "-21",0);//"

		format(String, charsmax(String), "\y[\d~\wNémitás\d~\y]");
		menu_additem(Menu, String, "5");
	}
	if(Folyamat == 2){
		new idtipus = str_to_num(KivalasztottEredmeny[id][3]);
		if(idtipus == 3){
			if(KivalasztottTipus[id] == 0){
				format(String, charsmax(String), "\y[\d~\wSteamID\d~\y]");
				menu_additem(Menu, String, "9");
				format(String, charsmax(String), "\y    [\d~\wNémitó: %s\d~\y]", KivalasztottEredmeny[id][7]);
				menu_addtext(Menu, String, 2);
				new LejarSzoveg[200];
				
				new Ido = str_to_num(KivalasztottEredmeny[id][15])-get_systime();
			
				new Nap = Ido / (24 * 3600);
				if(Nap > 0){
					format(LejarSzoveg, 200, "%d Nap", Nap);
				}
				new Ora = (Ido - Nap * 86400)/3600;
				if(Ora > 0){
					format(LejarSzoveg, 200, "%s %d Óra", LejarSzoveg, Ora);
				}
				new Perc = (Ido - Nap * 86400 - Ora * 3600)/60;
				if(Perc > 0){
					format(LejarSzoveg, 200, "%s %d Perc", LejarSzoveg, Perc);
				}
				new MP = (Ido - Nap * 86400 - Ora * 3600 - Perc * 60);
				if(MP > 0){
					format(LejarSzoveg, 200, "%s %d Másodperc", LejarSzoveg, MP);
				}
				format(String, charsmax(String), "\y    [\d~\wLejárat: %s\d~\y]", LejarSzoveg);
				menu_addtext(Menu, String, 3);
				format(String, charsmax(String), "\y[\d~\wIndok megtekintése\d~\y]");
				menu_additem(Menu, String, "10");
			}else{
				format(String, charsmax(String), "\y[\d~\wIP\d~\y]");
				menu_additem(Menu, String, "9");
				format(String, charsmax(String), "\y    [\d~\wNémitó: %s\d~\y]", KivalasztottEredmeny[id][5]);
				menu_addtext(Menu, String, 2);
				new LejarSzoveg[200];
				
				new Ido = str_to_num(KivalasztottEredmeny[id][14])-get_systime();
				
				new Nap = Ido / (24 * 3600);
				if(Nap > 0){
					format(LejarSzoveg, 200, "%d Nap", Nap);
				}
				new Ora = (Ido - Nap * 86400)/3600;
				if(Ora > 0){
					format(LejarSzoveg, 200, "%s %d Óra", LejarSzoveg, Ora);
				}
				new Perc = (Ido - Nap * 86400 - Ora * 3600)/60;
				if(Perc > 0){
					format(LejarSzoveg, 200, "%s %d Perc", LejarSzoveg, Perc);
				}
				new MP = (Ido - Nap * 86400 - Ora * 3600 - Perc * 60);
				if(MP > 0){
					format(LejarSzoveg, 200, "%s %d Másodperc", LejarSzoveg, MP);
				}
				format(String, charsmax(String), "\y    [\d~\wLejárat: %s\d~\y]", LejarSzoveg);
				menu_addtext(Menu, String, 3);
				format(String, charsmax(String), "\y[\d~\wIndok megtekintése\d~\y]");
				menu_additem(Menu, String, "10");
			}
		}else if(idtipus == 2){
			KivalasztottTipus[id] = 1;
			format(String, charsmax(String), "\y[\d~\wIndok megtekintése\d~\y]");
			menu_additem(Menu, String, "10");
			format(String, charsmax(String), "\y    [\d~\wCsak IP-cím alapján tudod feloldani a némitást!\d~\y]");
			menu_addtext(Menu, String, 2);	
			new LejarSzoveg[200];
				
			new Ido = str_to_num(KivalasztottEredmeny[id][14])-get_systime();
			
			new Nap = Ido / (24 * 3600);
			if(Nap > 0){
				format(LejarSzoveg, 200, "%d Nap", Nap);
			}
			new Ora = (Ido - Nap * 86400)/3600;
			if(Ora > 0){
				format(LejarSzoveg, 200, "%s %d Óra", LejarSzoveg, Ora);
			}
			new Perc = (Ido - Nap * 86400 - Ora * 3600)/60;
			if(Perc > 0){
				format(LejarSzoveg, 200, "%s %d Perc", LejarSzoveg, Perc);
			}
			new MP = (Ido - Nap * 86400 - Ora * 3600 - Perc * 60);
			if(MP > 0){
				format(LejarSzoveg, 200, "%s %d Másodperc", LejarSzoveg, MP);
			}
			format(String, charsmax(String), "\y    [\d~\wLejárat: %s\d~\y]", LejarSzoveg);
			menu_addtext(Menu, String, 3);
			format(String, charsmax(String), "\y    [\d~\wNémitó: %s\d~\y]", KivalasztottEredmeny[id][5]);
			menu_addtext(Menu, String, 4);
		}else if(idtipus == 1){
			KivalasztottTipus[id] = 0;
			format(String, charsmax(String), "\y[\d~\wIndok megtekintése\d~\y]");
			menu_additem(Menu, String, "10");
			format(String, charsmax(String), "\y    [\d~\wCsak SteamID alapján tudod feloldani a némitást!\d~\y]");
			menu_addtext(Menu, String, 2);
			new LejarSzoveg[200];
			new Ido = str_to_num(KivalasztottEredmeny[id][15])-get_systime();
			
			new Nap = Ido / (24 * 3600);
			if(Nap > 0){
				format(LejarSzoveg, 200, "%d Nap", Nap);
			}
			new Ora = (Ido - Nap * 86400)/3600;
			if(Ora > 0){
				format(LejarSzoveg, 200, "%s %d Óra", LejarSzoveg, Ora);
			}
			new Perc = (Ido - Nap * 86400 - Ora * 3600)/60;
			if(Perc > 0){
				format(LejarSzoveg, 200, "%s %d Perc", LejarSzoveg, Perc);
			}
			new MP = (Ido - Nap * 86400 - Ora * 3600 - Perc * 60);
			if(MP > 0){
				format(LejarSzoveg, 200, "%s %d Másodperc", LejarSzoveg, MP);
			}
			format(String, charsmax(String), "\y    [\d~\wLejárat: %s\d~\y]", LejarSzoveg);
			menu_addtext(Menu, String, 3);
			format(String, charsmax(String), "\y    [\d~\wNémitó: %s\d~\y]", KivalasztottEredmeny[id][7]);
			menu_addtext(Menu, String, 4);
		}
		
		format(String, charsmax(String), "\y[\d~\wNémitás feloldása\d~\y]");
		menu_additem(Menu, String, "11");
	}
	menu_setprop(Menu, MPROP_EXITNAME, "Kilépés");
	menu_display(id, Menu);
}

public Nemitash(id, Menu, Item){
	if(Item == MENU_EXIT){
		menu_destroy(Menu);
		return;
	}
	
	new Data[14], Line[32];
	new Access, Callback;
	menu_item_getinfo(Menu, Item, Access, Data, charsmax(Data), Line, charsmax(Line), Callback);
	
	new x = str_to_num(Data);
	
	if(x == -21)
	{
		if(adminmutetype[id] == 3)
			adminmutetype[id] = 1;
		else
			adminmutetype[id]++;
			Nemitas(id, 0);
	}
	if(x == 1){
		client_cmd(id, "messagemode IdoMegadasaN");
		return;
	}
	if(x == 2){
		client_cmd(id, "messagemode IndokMegadasaN");
		return;
	}
	if(x == 3){
		chat(0, id, 0, "!n%s", Indok[id]);
		Nemitas(id, 0);
		return;
	}
	if(x == 4){
		if(KivalasztottTipus[id] == 0){
			KivalasztottTipus[id] = 1;
		}else{
			KivalasztottTipus[id] = 0;
		}
		Nemitas(id, 0);
		return;
	}
	if(x == 5){
		if(Ido[id] != 0 && !equal(Indok[id], "")){
			new IDO = Ido[id]*60;
			if(IdoForma[id] == 1){
				IDO = Ido[id]*60*60;
			}
			if(IdoForma[id] == 2){
				IDO = Ido[id]*60*60*24;
			}
			if(IdoForma[id] == 3){
				IDO = Ido[id]*60*60*24*7;
			}
			if(IdoForma[id] == 4){
				chat(0, id, 0, "!nÖrökre nem némithatsz!");
				return;
			}
			if(KivalasztottTipus[id] == 1){
				NemitasMegad(id, 0, KivalasztottEredmeny[id][2], IDO, Indok[id], KivalasztottEredmeny[id][1]);
			}else{
				NemitasMegad(id, 1, KivalasztottEredmeny[id][0], IDO, Indok[id], KivalasztottEredmeny[id][1]);
			}
			Ido[id] = 0;
			IdoForma[id] = 0;
			KivalasztottEredmenyUrit(id);
		}else{
			chat(0, id, 0, "!nTölts ki mindent!");
		}
		return;
	}
	if(x == 7){
		if(IdoForma[id] == 3){
			IdoForma[id] = 0;
		}else{
			IdoForma[id]++;
		}
		Nemitas(id, 0);
		return;
	}
	if(x == 9){
		if(KivalasztottTipus[id] == 0){
			KivalasztottTipus[id] = 1;
		}else{
			KivalasztottTipus[id] = 0;
		}
		Nemitas(id, 2);
		return;
	}
	if(x == 10){
		if(KivalasztottTipus[id] == 1){
			chat(0, id, 0, "%s", KivalasztottEredmeny[id][6]);
		}else{
			chat(0, id, 0, "%s", KivalasztottEredmeny[id][8]);
		}
		Nemitas(id, 2);
	}
	if(x == 11){
		if(KivalasztottTipus[id] == 1){
			NemitasFeloldas(id, 1, KivalasztottEredmeny[id][2], KivalasztottEredmeny[id][1], KivalasztottEredmeny[id][6]);
		}else{
			NemitasFeloldas(id, 0, KivalasztottEredmeny[id][0], KivalasztottEredmeny[id][1], KivalasztottEredmeny[id][8]);
		}
		KivalasztottEredmenyUrit(id);
		JatekosMenu(id);
		return;
	}
}
public Kitiltas(id, Folyamat){
	if(!is_user_connected(id)){
		return;
	}
	if(Adminvagy[id] == 0 || Belepett[id] == 0){
		FoMenu(id);
		return;
	}
	new String[500];
	if(Folyamat == 2){
		format(String, charsmax(String), "\r%s \w» \yJátékos kitiltás feloldása", MenuPrefix);
	}else{
		format(String, charsmax(String), "\r%s \w» \yJátékos kitiltás", MenuPrefix);
	}
	new Menu = menu_create(String, "Kitiltash");
	
	if(Folyamat == 0){
		if(Ido[id] == 0){
			format(String, charsmax(String), "\y[\d~\wIdő megadása\d~\y]");
			menu_additem(Menu, String, "1");
		}else{
			new Forma[10];
			new Forma2[10];
			new Orok;
			switch(IdoForma[id]){
				case 0:{
					format(Forma, charsmax(Forma), "Perc");
					format(Forma2, charsmax(Forma2), "Óra");
				}
				case 1:{
					format(Forma, charsmax(Forma), "Óra");
					format(Forma2, charsmax(Forma2), "Nap");
				}
				case 2:{
					format(Forma, charsmax(Forma), "Nap");
					format(Forma2, charsmax(Forma2), "Hét");
				}
				case 3:{
					format(Forma, charsmax(Forma), "Hét");
					format(Forma2, charsmax(Forma2), "Örök");
				}
				case 4:{
					format(Forma, charsmax(Forma), "Örök");
					format(Forma2, charsmax(Forma2), "Perc");
					Orok++;
				}
			}
			if(Orok != 0){
				format(String, charsmax(String), "\y[\d~\w%s\d~\y]", Forma);
				menu_additem(Menu, String, "1");
			}else{
				format(String, charsmax(String), "\y[\d~\wIdő %d %s\d~\y]", Ido[id], Forma);
				menu_additem(Menu, String, "1");
				format(String, charsmax(String), "\y[\d~\w%s\d~\y]", Forma2);
				menu_additem(Menu, String, "7");
			}
		}
		
		if(equal(Indok[id], "")){
			format(String, charsmax(String), "\y[\d~\wIndok megadása\d~\y]");
			menu_additem(Menu, String, "2");
		}else{	
			format(String, charsmax(String), "\y[\d~\wIndok módosítása\d~\y]");
			menu_additem(Menu, String, "2");
			format(String, charsmax(String), "\y[\d~\wIndok megtekintése\d~\y]");
			menu_additem(Menu, String, "3");
		}
		new idtipus = str_to_num(KivalasztottEredmeny[id][4]);
		if(idtipus == 0){
			if(KivalasztottTipus[id] == 0){
				format(String, charsmax(String), "\y[\d~\wSteamID\d~\y]");
				menu_additem(Menu, String, "4");
			}else{	
				format(String, charsmax(String), "\y[\d~\wIP\d~\y]");
				menu_additem(Menu, String, "4");
			}
		}else if(idtipus == 2){
			KivalasztottTipus[id] = 0;
			format(String, charsmax(String), "\y	[\d~\wCsak SteamID alapján tudod kitiltani!\d~\y]");
			menu_addtext(Menu, String, 4);
		}else if(idtipus == 1){
			KivalasztottTipus[id] = 1;
			format(String, charsmax(String), "\y	[\d~\wCsak IP-cím alapján tudod kitiltani!\d~\y]");
			menu_addtext(Menu, String, 4);
		}
		
		format(String, charsmax(String), "\y[\d~\wKitiltás\d~\y]");
		menu_additem(Menu, String, "5");
	}
	if(Folyamat == 2){
		new idtipus = str_to_num(KivalasztottEredmeny[id][4]);
		if(idtipus == 3){
			if(KivalasztottTipus[id] == 0){
				format(String, charsmax(String), "\y[\d~\wSteamID\d~\y]");
				menu_additem(Menu, String, "9");
				format(String, charsmax(String), "\y	[\d~\wKitiltó: %s\d~\y]", KivalasztottEredmeny[id][9]);
				menu_addtext(Menu, String, 2);
				format(String, charsmax(String), "\y[\d~\wIndok megtekintése\d~\y]");
				menu_additem(Menu, String, "10");
			}else{
				format(String, charsmax(String), "\y[\d~\wIP\d~\y]");
				menu_additem(Menu, String, "9");
				format(String, charsmax(String), "\y	[\d~\wKitiltó: %s\d~\y]", KivalasztottEredmeny[id][11]);
				menu_addtext(Menu, String, 2);
				format(String, charsmax(String), "\y[\d~\wIndok megtekintése\d~\y]");
				menu_additem(Menu, String, "10");
			}
		}else if(idtipus == 2){
			KivalasztottTipus[id] = 1;
			format(String, charsmax(String), "\y[\d~\wIndok megtekintése\d~\y]");
			menu_additem(Menu, String, "10");
			format(String, charsmax(String), "\y	[\d~\wKitiltó: %s\d~\y]", KivalasztottEredmeny[id][9]);
			menu_addtext(Menu, String, 2);			
			format(String, charsmax(String), "\y	[\d~\wCsak IP-cím alapján tudod feloldani a kitiltást!\d~\y]");
			menu_addtext(Menu, String, 3);
		}else if(idtipus == 1){
			KivalasztottTipus[id] = 0;
			format(String, charsmax(String), "\y[\d~\wIndok megtekintése\d~\y]");
			menu_additem(Menu, String, "10");
			format(String, charsmax(String), "\y	[\d~\wKitiltó: %s\d~\y]", KivalasztottEredmeny[id][11]);
			menu_addtext(Menu, String, 2);
			format(String, charsmax(String), "\y	[\d~\wCsak SteamID alapján tudod feloldani a kitiltást!\d~\y]");
			menu_addtext(Menu, String, 3);
		}
		
		format(String, charsmax(String), "\y[\d~\wKitiltás feloldása\d~\y]");
		menu_additem(Menu, String, "11");
	}
	menu_setprop(Menu, MPROP_EXITNAME, "Kilépés");
	menu_display(id, Menu);
}

public Kitiltash(id, Menu, Item){
	if(Item == MENU_EXIT){
		menu_destroy(Menu);
		return;
	}
	
	new Data[14], Line[32];
	new Access, Callback;
	menu_item_getinfo(Menu, Item, Access, Data, charsmax(Data), Line, charsmax(Line), Callback);
	
	new x = str_to_num(Data);
	
	if(x == 1){
		client_cmd(id, "messagemode IdoMegadasaK");
		return;
	}
	if(x == 2){
		client_cmd(id, "messagemode IndokMegadasaK");
		return;
	}
	if(x == 3){
		chat(0, id, 0, "!n%s", Indok[id]);
		Kitiltas(id, 0);
		return;
	}
	if(x == 4){
		if(KivalasztottTipus[id] == 0){
			KivalasztottTipus[id] = 1;
		}else{
			KivalasztottTipus[id] = 0;
		}
		Kitiltas(id, 0);
		return;
	}
	if(x == 5){
		if(Ido[id] != 0 && !equal(Indok[id], "")){
			new IDO = Ido[id]*60;
			if(IdoForma[id] == 1){
				IDO = Ido[id]*60*60;
			}
			if(IdoForma[id] == 2){
				IDO = Ido[id]*60*60*24;
			}
			if(IdoForma[id] == 3){
				IDO = Ido[id]*60*60*24*7;
			}
			if(IdoForma[id] == 4){
				IDO = -1;
			}
			if(KivalasztottTipus[id] == 1){
				KitiltasMegad(id, 0, KivalasztottEredmeny[id][2], IDO, Indok[id], KivalasztottEredmeny[id][1]);
			}else{
				KitiltasMegad(id, 1, KivalasztottEredmeny[id][0], IDO, Indok[id], KivalasztottEredmeny[id][1]);
			}
			Ido[id] = 0;
			IdoForma[id] = 0;
			KivalasztottEredmenyUrit(id);
		}else{
			chat(0, id, 0, "!nTölts ki mindent!");
		}
		return;
	}
	if(x == 7){
		if(IdoForma[id] == 4){
			IdoForma[id] = 0;
		}else{
			IdoForma[id]++;
		}
		Kitiltas(id, 0);
		return;
	}
	if(x == 9){
		if(KivalasztottTipus[id] == 0){
			KivalasztottTipus[id] = 1;
		}else{
			KivalasztottTipus[id] = 0;
		}
		Kitiltas(id, 2);
		return;
	}
	if(x == 10){
		if(KivalasztottTipus[id] == 1){
			chat(0, id, 0, "%s", KivalasztottEredmeny[id][10]);
		}else{
			chat(0, id, 0, "%s", KivalasztottEredmeny[id][12]);
		}
		Kitiltas(id, 2);
	}
	if(x == 11){
		if(KivalasztottTipus[id] == 1){
			KitiltasFeloldas(id, 1, KivalasztottEredmeny[id][2], KivalasztottEredmeny[id][1], KivalasztottEredmeny[id][10]);
		}else{
			KitiltasFeloldas(id, 0, KivalasztottEredmeny[id][0], KivalasztottEredmeny[id][1], KivalasztottEredmeny[id][12]);
		}
		KivalasztottEredmenyUrit(id);
		JatekosMenu(id);
		return;
	}
}

public AdminJogok(id2){
	new id;
	if(id2 >= 100){
		id = id2-100;
	}else{
		id = id2;
	}
		
	if(!is_user_connected(id)){
		return;
	}
	if((SzuperAdmin[id] == 0 && containi(ModJogok[id], "e") == -1) || Belepett[id] == 0){
		FoMenu(id);
		return;
	}
	new String[500];
	format(String, charsmax(String), "\r%s \w» \yAdmin Jogok", MenuPrefix);
	new Menu = menu_create(String, "AdminJogokh");
	if(id2 >= 100){
		if(containi(KivalasztottAdminEredmenyUJ[id][2], "a") == -1){
			format(String, charsmax(String), "\y[\d~\wKitiltás: \dNincs\d~\y]");
		}else{
			format(String, charsmax(String), "\y[\d~\wKitiltás: \yVan\d~\y]");
		}
		menu_additem(Menu, String, "8");

		if(containi(KivalasztottAdminEredmenyUJ[id][2], "b") == -1){
			format(String, charsmax(String), "\y[\d~\wKirúgás: \dNincs\d~\y]");
		}else{
			format(String, charsmax(String), "\y[\d~\wKirúgás: \yVan\d~\y]");
		}
		menu_additem(Menu, String, "9");

		if(containi(KivalasztottAdminEredmenyUJ[id][2], "c") == -1){
			format(String, charsmax(String), "\y[\d~\wNémitás: \dNincs\d~\y]");
		}else{
			format(String, charsmax(String), "\y[\d~\wNémitás: \yVan\d~\y]");
		}
		menu_additem(Menu, String, "10");

		if(containi(KivalasztottAdminEredmenyUJ[id][2], "d") == -1){
			format(String, charsmax(String), "\y[\d~\wMapváltás/Csapatvaltas/Megölés: \dNincs\d~\y]");
		}else{
			format(String, charsmax(String), "\y[\d~\wMapváltás/Csapatvaltas/Megölés: \yVan\d~\y]");
		}
		menu_additem(Menu, String, "11");

		if(containi(KivalasztottAdminEredmenyUJ[id][2], "e") == -1){
			format(String, charsmax(String), "\y[\d~\wAdmin Jogok: \dNincs\d~\y]");
		}else{
			format(String, charsmax(String), "\y[\d~\wAdmin Jogok: \yVan\d~\y]");
		}
		menu_additem(Menu, String, "12");
		
		if(containi(KivalasztottAdminEredmenyUJ[id][2], "f") == -1){
			format(String, charsmax(String), "\y[\d~\wVip: \dNincs\d~\y]");
		}else{
			format(String, charsmax(String), "\y[\d~\wVip: \yVan\d~\y]");
		}
		menu_additem(Menu, String, "13");
		format(String, charsmax(String), "\y[\d~\wKész\d~\y]");
		menu_additem(Menu, String, "15");
		
		if(containi(KivalasztottAdminEredmenyUJ[id][2], "g") == -1){
			format(String, charsmax(String), "\y[\d~\wFragverseny: \dNincs\d~\y]");
		}else{
			format(String, charsmax(String), "\y[\d~\wFragverseny: \yVan\d~\y]");
		}
		menu_additem(Menu, String, "14");
		
		format(String, charsmax(String), "\y[\d~\wKész\d~\y]");
		menu_additem(Menu, String, "15");
	}else{
		if(equal(KivalasztottAdminEredmenyUJ[id][1], "")){
			new Playerek;
			for(new i = 1;i < JATEKOSOK;i++){
				if(is_user_connected(i) && !is_user_bot(i) && (equali(IP[id], AdminIP) || !equali(IP[i], AdminIP))){
					format(String, charsmax(String), "\y[\d~\w%s\d~\y]", NEV[i]);
					menu_additem(Menu, String, NEV[i]);
					Playerek++;
				}
			}
			if(Playerek == 0){
				format(String, charsmax(String), "\y[\d~\wNincs találat!\d~\y]");
				menu_additem(Menu, String, "Nincs");
			}
		}else{
			format(String, charsmax(String), "\y[\d~\wJátékos: %s\d~\y]", KivalasztottAdminEredmenyUJ[id][1]);
			menu_additem(Menu, String, "1");
			if(equal(KivalasztottAdminEredmenyUJ[id][3], "")){
				format(String, charsmax(String), "\y[\d~\wSzerver jogok\d~\y]");	
			}else{
				format(String, charsmax(String), "\y[\d~\wSzerver jogok: %s\d~\y]", KivalasztottAdminEredmenyUJ[id][3]);	
			}
			menu_additem(Menu, String, "2");
			if(equal(KivalasztottAdminEredmenyUJ[id][2], "")){
				format(String, charsmax(String), "\y[\d~\wMod jogok\d~\y]");	
			}else{
				format(String, charsmax(String), "\y[\d~\wMod jogok: %s\d~\y]", KivalasztottAdminEredmenyUJ[id][2]);	
			}
			menu_additem(Menu, String, "3");
			
			if(equal(KivalasztottAdminEredmenyUJ[id][5], "")){
				format(String, charsmax(String), "\y[\d~\wPrefix\d~\y]");
			}else{
				format(String, charsmax(String), "\y[\d~\wPrefix: %s\d~\y]", KivalasztottAdminEredmenyUJ[id][5]);
			}
			menu_additem(Menu, String, "4");
			if(equal(KivalasztottAdminEredmenyUJ[id][4], "0")){
				format(String, charsmax(String), "\y[\d~\wSzuperAdmin: \dNincs\d~\y]");
			}else{
				format(String, charsmax(String), "\y[\d~\wSzuperAdmin: \yVan\d~\y]");
			}
			menu_additem(Menu, String, "5");
			if(equal(KivalasztottAdminEredmenyUJ[id][6], "0")){
				format(String, charsmax(String), "\y[\d~\wAdmin: \dNincs\d~\y]");
			}else{
				format(String, charsmax(String), "\y[\d~\wAdmin: \yVan\d~\y]");
			}
			menu_additem(Menu, String, "6");
			format(String, charsmax(String), "\y[\d~\wMentés\d~\y]");
			menu_additem(Menu, String, "7");
		}
	}
	menu_setprop(Menu, MPROP_NEXTNAME, "Tovább");
	menu_setprop(Menu, MPROP_BACKNAME, "Vissza");
	menu_setprop(Menu, MPROP_EXITNAME, "Kilépés");
	menu_display(id, Menu);
}

public AdminJogokh(id, Menu, Item){
	if(Item == MENU_EXIT){
		menu_destroy(Menu);
		return;
	}
	
	new Data[50], Line[32];
	new Access, Callback;
	menu_item_getinfo(Menu, Item, Access, Data, charsmax(Data), Line, charsmax(Line), Callback);
	if(equal(Data, "Nincs")){
		chat(0, id, 0, "Jelenleg nincs fent egy játékos sem akit ki tudnál jelölni!");
		AdminMenu(id);
		return;
	}
	new x = str_to_num(Data);
	if(x == 1){
		KivalasztottAdminEredmenyUJUrit(id);
	}else if(x == 2){
		client_cmd(id, "messagemode SzerverJogok");
		return;
	}else if(x == 3){
		id += 100;
	}else if(x == 4){
		client_cmd(id, "messagemode AdminPrefix");
	}else if(x == 5){
		if(equal(KivalasztottAdminEredmenyUJ[id][4], "0")){
			KivalasztottAdminEredmenyUJ[id][4] = "1";
			KivalasztottAdminEredmenyUJ[id][6] = "1";
		}else{
			KivalasztottAdminEredmenyUJ[id][4] = "0";
		}
	}else if(x == 6){
		if(equal(KivalasztottAdminEredmenyUJ[id][6], "0")){
			KivalasztottAdminEredmenyUJ[id][6] = "1";
		}else{
			KivalasztottAdminEredmenyUJ[id][6] = "0";
		}
	}else if(x == 7){
		AdminJogMentes(id);
	}else if(x == 8){
		if(containi(KivalasztottAdminEredmenyUJ[id][2], "a") == -1){
			format(KivalasztottAdminEredmenyUJ[id][2], 120, "%sa", KivalasztottAdminEredmenyUJ[id][2]);
		}else{
			replace_all(KivalasztottAdminEredmenyUJ[id][2], 120, "a", "");
		}
		id += 100;
	}else if(x == 9){
		if(containi(KivalasztottAdminEredmenyUJ[id][2], "b") == -1){
			format(KivalasztottAdminEredmenyUJ[id][2], 120, "%sb", KivalasztottAdminEredmenyUJ[id][2]);
		}else{
			replace_all(KivalasztottAdminEredmenyUJ[id][2], 120, "b", "");
		}
		id += 100;
	}else if(x == 10){
		if(containi(KivalasztottAdminEredmenyUJ[id][2], "c") == -1){
			format(KivalasztottAdminEredmenyUJ[id][2], 120, "%sc", KivalasztottAdminEredmenyUJ[id][2]);
		}else{
			replace_all(KivalasztottAdminEredmenyUJ[id][2], 120, "c", "");
		}
		id += 100;
	}else if(x == 11){
		if(containi(KivalasztottAdminEredmenyUJ[id][2], "d") == -1){
			format(KivalasztottAdminEredmenyUJ[id][2], 120, "%sd", KivalasztottAdminEredmenyUJ[id][2]);
		}else{
			replace_all(KivalasztottAdminEredmenyUJ[id][2], 120, "d", "");
		}
		id += 100;
	}else if(x == 12){
		if(containi(KivalasztottAdminEredmenyUJ[id][2], "e") == -1){
			format(KivalasztottAdminEredmenyUJ[id][2], 120, "%se", KivalasztottAdminEredmenyUJ[id][2]);
		}else{
			replace_all(KivalasztottAdminEredmenyUJ[id][2], 120, "e", "");
		}
		id += 100;
	}else if(x == 13){
		if(containi(KivalasztottAdminEredmenyUJ[id][2], "f") == -1){
			format(KivalasztottAdminEredmenyUJ[id][2], 120, "%sf", KivalasztottAdminEredmenyUJ[id][2]);
		}else{
			replace_all(KivalasztottAdminEredmenyUJ[id][2], 120, "f", "");
		}
		id += 100;
	}else if(x == 14){
		if(containi(KivalasztottAdminEredmenyUJ[id][2], "g") == -1){
			format(KivalasztottAdminEredmenyUJ[id][2], 120, "%sg", KivalasztottAdminEredmenyUJ[id][2]);
		}else{
			replace_all(KivalasztottAdminEredmenyUJ[id][2], 120, "g", "");
		}
		id += 100;
	}else{
		new ID = find_player("a", Data);
		if(ID != 0){
			format(KivalasztottAdminEredmenyUJ[id][0], 100, "%s", STEAMID[ID]);
			format(KivalasztottAdminEredmenyUJ[id][1], 100, "%s", NEV[ID]);
			format(KivalasztottAdminEredmenyUJ[id][2], 100, "%s", ModJogok[ID]);
			format(KivalasztottAdminEredmenyUJ[id][3], 100, "%s", Jogok[ID]);
			format(KivalasztottAdminEredmenyUJ[id][4], 100, "%d", SzuperAdmin[ID]);
			format(KivalasztottAdminEredmenyUJ[id][5], 100, "%s", JatekosPrefix[ID]);
			format(KivalasztottAdminEredmenyUJ[id][6], 100, "%d", Adminvagy[ID]);
		}
	}
	AdminJogok(id);
}

public Kirugas(id){
	if(!is_user_connected(id)){
		return;
	}
	if(Adminvagy[id] == 0 || Belepett[id] == 0){
		FoMenu(id);
		return;
	}
	new String[500];
	format(String, charsmax(String), "\r%s \w» \yJátékos kirúgása", MenuPrefix);
	new Menu = menu_create(String, "Kirugash");
	
	if(equal(Indok[id], "")){
		format(String, charsmax(String), "\y[\d~\wIndok megadása\d~\y]");
		menu_additem(Menu, String, "1");
	}else{
		format(String, charsmax(String), "\y[\d~\wIndok módosítása\d~\y]");
		menu_additem(Menu, String, "1");
		format(String, charsmax(String), "\y[\d~\wIndok megtekintése\d~\y]");
		menu_additem(Menu, String, "2");
	}
	
	format(String, charsmax(String), "\y[\d~\wKirúgás\d~\y]");
	menu_additem(Menu, String, "3");
	menu_setprop(Menu, MPROP_EXITNAME, "Kilépés");
	menu_display(id, Menu);
}

public Kirugash(id, Menu, Item){
	if(Item == MENU_EXIT){
		menu_destroy(Menu);
		return;
	}
	
	new Data[14], Line[32];
	new Access, Callback;
	menu_item_getinfo(Menu, Item, Access, Data, charsmax(Data), Line, charsmax(Line), Callback);
	
	new x = str_to_num(Data);

	if(x == 1){
		client_cmd(id, "messagemode IndokMegadasaKS");
		return;
	}
	if(x == 2){
		chat(0, id, 0, "!n%s", Indok[id]);
		Kirugas(id);
		return;
	}
	if(x == 3){
		if(!equal(Indok[id], "")){
			new Jatekos = find_player("c", KivalasztottEredmeny[id][0]);
			console_print(Jatekos, "------ Ki lettél rúgva a szerverről! ( kick ) ----------");
			console_print(Jatekos, "Név: %s", KivalasztottEredmeny[id][1]);
			console_print(Jatekos, "SteamID: %s", KivalasztottEredmeny[id][0]);
			console_print(Jatekos, "Kirúgó: %s", NEV[id]);
			console_print(Jatekos, "Indok: %s", Indok[id]);
			console_print(Jatekos, "--------------------------------------------------------");
			server_cmd("kick #%d Ki lettél rúgva! Nézd meg a konzolod!", get_user_userid(Jatekos)); 
			chat(0, 0, 0, "!t%s !nKi lett rúgva, általa: !g%s!n! !nIndok: !g%s", KivalasztottEredmeny[id][1], NEV[id], Indok[id]);
		}else{
			chat(0, id, 0, "!nAdd meg az indokot!");
		}
		return;
	}
}

public Mapvaltas(id, Folyamat){
	if(!is_user_connected(id)){
		return;
	}
	if(Adminvagy[id] == 0 || Belepett[id] == 0){
		FoMenu(id);
		return;
	}
	new String[500];
	format(String, charsmax(String), "\r%s \w» \yMapváltás", MenuPrefix);
	new Menu = menu_create(String, "Mapvaltash");
	
	if(Folyamat == 0){
		if(KivalasztottMap[id] == 0){
			format(String, charsmax(String), "\y[\d~\wMap Kiválasztása\d~\y]");
		}else{
			format(String, charsmax(String), "\y[\d~\wMap: %s\d~\y]", SzerverMapok[KivalasztottMap[id]]);
		}
		menu_additem(Menu, String, "1");
		
		if(KivalasztottKorok[id] == -1){
			format(String, charsmax(String), "\y[\d~\wHány kör után legyen\d~\y]");
		}else{
			if(KivalasztottKorok[id] == 0){
				format(String, charsmax(String), "\y[\d~\wEz a kör után\d~\y]", KivalasztottKorok[id]);
			}else{
				format(String, charsmax(String), "\y[\d~\w%d kör után\d~\y]", KivalasztottKorok[id]);
			}
		}
		menu_additem(Menu, String, "2");
		if(AdminMapKor != -1){
			format(String, charsmax(String), "\y[\d~\wTörlés\d~\y]");
			menu_additem(Menu, String, "3");
		}
		
		format(String, charsmax(String), "\y[\d~\wInditás\d~\y]");
		menu_additem(Menu, String, "4");
	}
	if(Folyamat == 1){
		for(new i = 1;i <= SzerverMapokSzama;i++){
			new NumToString[6];
			num_to_str(i+4, NumToString, 5);
			format(String, charsmax(String), "\y[\d~\w%s\d~\y]", SzerverMapok[i]);
			menu_additem(Menu, String, NumToString);
		}
	}
	
	menu_setprop(Menu, MPROP_NEXTNAME, "Tovább");
	menu_setprop(Menu, MPROP_BACKNAME, "Vissza");
	menu_setprop(Menu, MPROP_EXITNAME, "Kilépés");
	menu_display(id, Menu);
}

public Mapvaltash(id, Menu, Item){
	if(Item == MENU_EXIT){
		menu_destroy(Menu);
		return;
	}
	
	new Data[14], Line[32];
	new Access, Callback;
	menu_item_getinfo(Menu, Item, Access, Data, charsmax(Data), Line, charsmax(Line), Callback);
	
	new x = str_to_num(Data);
	
	if(x == 1){
		Mapvaltas(id, 1);
		return;
	}
	if(x == 2){
		client_cmd(id, "messagemode KorokMegadasa");
		return;
	}
	if(x == 3){
		AdminMapKor = -1;
		AdminMap = 0;		
		chat(0, 0, 0, "!t%s !nMegszakította a mapváltást!", NEV[id]);
		return;
	}
	if(x == 4){
		if(KivalasztottKorok[id] != -1 && KivalasztottMap[id] != 0){
			AdminMap = KivalasztottMap[id];
			AdminMapKor = KivalasztottKorok[id];
			get_user_name(id, AdminMapNeve, 100);
			if(AdminMapKor == 0){
				chat(0, 0, 0, "!tEz !na kör után mapváltás: !t%s!n, általa: !g%s!n!", SzerverMapok[AdminMap], AdminMapNeve);
			}else{
				chat(0, 0, 0, "!t%d !nkör után mapváltás: !t%s!n, általa: !g%s!n!", AdminMapKor, SzerverMapok[AdminMap], AdminMapNeve);
			}
			KivalasztottKorok[id] = 0;
			KivalasztottMap[id] = 0;
		}else{
			chat(0, id, 0, "!nTölts ki mindent!");
		}
		return;
	}
	if(x > 4 && x < 35){
		KivalasztottMap[id] = x-4;
		Mapvaltas(id, 0);
		return;
	}
}

public LogSave(id){
	if(!is_user_connected(id)){
		return;
	}
	new String[500];
	format(String, charsmax(String), "\r%s \y» \rKaraktervédelem", MenuPrefix);
	new Menu = menu_create(String, "LogSaveh");
	if(!equal(JelszoSQL[id], "") && Bekelllepni[id] == 1 && Belepett[id] == 0){
		if(equali(Hiba[id], "")){
			if(!equal(Jelszo[id], "") && !equal(JelszoSQL[id], Jelszo[id])){
				format(String, charsmax(String), "\y[\d~\wJelszó: \y%s\d~\y]\r^n^nHibás jelszót adtál meg!", Jelszo[id]);
			}else if(!equal(Jelszo[id], "") && equal(Jelszo[id], Jelszo[id])){
				PlayerBetoltes(id);
				Belepett[id] = 1;
				if(Adminvagy[id] == 1){
					Admin(id);
				}
				client_cmd(id, "jointeam");
				menu_destroy(Menu);
				chat(0, id, 0, "!tSikeresen bejelentkeztél, üdvözlünk a szerveren!");
				return;
			}else{
				format(String, charsmax(String), "\y[\d~\wJelszó\d~\y]");
			}		
		}else{
			format(String, charsmax(String), "\y[\d~\wJelszó\d~\y]\r^n%s", Hiba[id]);
		}
		menu_additem(Menu, String, "1");	
	}else{
		if(equali(Jelszo[id], "")){
			if(!equali(Hiba[id], "")){
				format(String, charsmax(String), "\y[\d~\wJelszó\d~\y]\r^n%s", Hiba[id]);
				menu_additem(Menu, String, "1");
			}else{
				format(String, charsmax(String), "\y[\d~\wJelszó\d~\y]");
				menu_additem(Menu, String, "1");
			}
		}else{
			if(!equali(Hiba[id], "")){
				format(String, charsmax(String), "\y[\d~\wJelszó: \y%s\d~\y]", Jelszo[id]);
				menu_additem(Menu, String, "1");
				if(equali(Jelszo2[id], "")){
					format(String, charsmax(String), "\y[\d~\wJelszó\d~\y]\r^n%s", Hiba[id]);
					menu_additem(Menu, String, "2");
				}else{
					format(String, charsmax(String), "\y[\d~\wJelszó: \y%s\d~\y]\r^n%s", Jelszo2[id], Hiba[id]);
					menu_additem(Menu, String, "2");
				}
			}else{
				format(String, charsmax(String), "\y[\d~\wJelszó: \y%s\d~\y]", Jelszo[id]);
				menu_additem(Menu, String, "1");
				if(equali(Jelszo2[id], "")){
					format(String, charsmax(String), "\y[\d~\wJelszó\d~\y]");
					menu_additem(Menu, String, "2");
				}else{
					format(String, charsmax(String), "\y[\d~\wJelszó: \y%s\d~\y]", Jelszo2[id]);
					menu_additem(Menu, String, "2");
				}
				if(!equali(Jelszo[id], "") && equal(Jelszo[id], Jelszo2[id])){
					format(String, charsmax(String), "\y[\d~\wMentés\d~\y]");
					menu_additem(Menu, String, "3");
				}
			}
		}
	}
	Hiba[id] = "";
	menu_setprop(Menu, MPROP_EXITNAME, "Kilépés");
	menu_display(id, Menu);
}

public LogSaveh(id, Menu, Item){
	if(Item == MENU_EXIT){
		menu_destroy(Menu);
		return;
	}
	
	new Data[14], Line[32];
	new Access, Callback;
	menu_item_getinfo(Menu, Item, Access, Data, charsmax(Data), Line, charsmax(Line), Callback);
	
	
	if(!equal(JelszoSQL[id], "") && Belepett[id] == 0){
		new x = str_to_num(Data);
		if(x == 1){
			client_cmd(id, "messagemode Jelszo");
			return;
		}
	}else{
		new x = str_to_num(Data);
		if(x == 1){
			client_cmd(id, "messagemode Jelszo");
			return;
		}		
		if(x == 2){
			client_cmd(id, "messagemode Jelszo2");
			return;
		}		
		if(x == 3){
			JelszoMentesSQL(id);
			chat(0, id, 0, "!nSikeresen mentetted a jelszavad!");
			return;
		}		
	}
}

public Beallitasok(id){
	if(!is_user_connected(id)){
		return;
	}
	new String[500];
	format(String, charsmax(String), "\r%s \wBeállitások", MenuPrefix);
	new Menu = menu_create(String, "Beallitasokh");
	if(Adminvagy[id] == 0){
		if(Bekelllepni[id] == 1){
			format(String, charsmax(String), "\y[\d~\wJelszó eltávolitása\d~\y]");
			menu_additem(Menu, String, "1");
		}else{
			format(String, charsmax(String), "\y[\d~\wJelszó beállitása\d~\y]");
			menu_additem(Menu, String, "1");
		}
		if(KillFade[id] == 0){
			format(String, charsmax(String), "\y[\d~\wKillFade \dkikapcsolása\d~\y]");
			menu_additem(Menu, String, "2");
		}else{
			format(String, charsmax(String), "\y[\d~\wKillFade \dbekapcsolás\d~\y]");
			menu_additem(Menu, String, "2");
		}
		if(Kinezetek[id] == 0){
			format(String, charsmax(String), "\y[\d~\wKinezetek \dkikapcsolása\d~\y]");
			menu_additem(Menu, String, "3");
		}else{
			format(String, charsmax(String), "\y[\d~\wKinezetek \dbekapcsolás\d~\y]");
			menu_additem(Menu, String, "3");
		}
		if(Ejtoernyo[id] == 0){
			format(String, charsmax(String), "\y[\d~\wEjtőernyő \dkikapcsolása\d~\y]");
			menu_additem(Menu, String, "4");
		}else{
			format(String, charsmax(String), "\y[\d~\wEjtőernyő \dbekapcsolás\d~\y]");
			menu_additem(Menu, String, "4");
		}
		if(Sebzeskijelzo[id] == 0){
			format(String, charsmax(String), "\y[\d~\wSebzéskijelző \dkikapcsolása\d~\y]");
			menu_additem(Menu, String, "5");
		}else{
			format(String, charsmax(String), "\y[\d~\wSebzés kijelző \dbekapcsolás\d~\y]");
			menu_additem(Menu, String, "5");
		}
		if(Duplaugras[id] == 0){
			format(String, charsmax(String), "\y[\d~\wDupla ugrás \dkikapcsolása\d~\y]");
			menu_additem(Menu, String, "6");
		}else{
			format(String, charsmax(String), "\y[\d~\wDupla ugrás \dbekapcsolás\d~\y]");
			menu_additem(Menu, String, "6");
		}
		if(HUD[id] == 0){
			format(String, charsmax(String), "\y[\d~\wHUD \dkikapcsolása\d~\y]");
			menu_additem(Menu, String, "7");
		}else{
			format(String, charsmax(String), "\y[\d~\wHUD \dbekapcsolás\d~\y]");
			menu_additem(Menu, String, "7");
		}
	}else{
		if(KillFade[id] == 0){
			format(String, charsmax(String), "\y[\d~\wKillFade \dkikapcsolása\d~\y]");
			menu_additem(Menu, String, "1");
		}else{
			format(String, charsmax(String), "\y[\d~\wKillFade \dbekapcsolás\d~\y]");
			menu_additem(Menu, String, "1");
		}
		if(Kinezetek[id] == 0){
			format(String, charsmax(String), "\y[\d~\wKinezetek \dkikapcsolása\d~\y]");
			menu_additem(Menu, String, "2");
		}else{
			format(String, charsmax(String), "\y[\d~\wKinezetek \dbekapcsolás\d~\y]");
			menu_additem(Menu, String, "2");
		}
		if(Ejtoernyo[id] == 0){
			format(String, charsmax(String), "\y[\d~\wEjtőernyő \dkikapcsolása\d~\y]");
			menu_additem(Menu, String, "3");
		}else{
			format(String, charsmax(String), "\y[\d~\wEjtőernyő \dbekapcsolás\d~\y]");
			menu_additem(Menu, String, "3");
		}
		if(Sebzeskijelzo[id] == 0){
			format(String, charsmax(String), "\y[\d~\wSebzéskijelző \dkikapcsolása\d~\y]");
			menu_additem(Menu, String, "4");
		}else{
			format(String, charsmax(String), "\y[\d~\wSebzés kijelző \dbekapcsolás\d~\y]");
			menu_additem(Menu, String, "4");
		}
		if(Duplaugras[id] == 0){
			format(String, charsmax(String), "\y[\d~\wDupla ugrás \dkikapcsolása\d~\y]");
			menu_additem(Menu, String, "5");
		}else{
			format(String, charsmax(String), "\y[\d~\wDupla ugrás \dbekapcsolás\d~\y]");
			menu_additem(Menu, String, "5");
		}
		if(HUD[id] == 0){
			format(String, charsmax(String), "\y[\d~\wHUD \dkikapcsolása\d~\y]");
			menu_additem(Menu, String, "6");
		}else{
			format(String, charsmax(String), "\y[\d~\wHUD \dbekapcsolás\d~\y]");
			menu_additem(Menu, String, "6");
		}
		if(HalalUF[id] == 0){
			format(String, charsmax(String), "\y[\d~\wHalál utáni fecsegés \dkikapcsolása~\y]");
			menu_additem(Menu, String, "7");
		}else{
			format(String, charsmax(String), "\y[\d~\wHalál utáni fecsegés \dbekapcsolása~\y]");
			menu_additem(Menu, String, "7");
		}
	}
	
	menu_setprop(Menu, MPROP_EXITNAME, "Kilépés");
	menu_display(id, Menu);
}

public Beallitasokh(id, Menu, Item){
	if(Item == MENU_EXIT){
		menu_destroy(Menu);
		return;
	}
	
	new Data[14], Line[32];
	new Access, Callback;
	menu_item_getinfo(Menu, Item, Access, Data, charsmax(Data), Line, charsmax(Line), Callback);
	
	new x = str_to_num(Data);
	
	if(Adminvagy[id] == 0){
		if(x == 1){
			if(Bekelllepni[id] == 1){
				client_cmd(id, "messagemode Jelszo3");
			}else{
				LogSave(id);
				return;
			}
		}
		if(x == 2){
			if(KillFade[id] == 0){
				KillFade[id] = 1;
				chat(0, id, 0, "!nKikapcsoltad a KillFade-et!");
			}else{
				KillFade[id] = 0;
				chat(0, id, 0, "!nBekapcsoltad a KillFade-et!");
			}
		}
		if(x == 3){
			if(Kinezetek[id] == 0){
				Kinezetek[id] = 1;
				chat(0, id, 0, "!nKikapcsoltad a kinezeteket!");
			}else{
				Kinezetek[id] = 0;
				chat(0, id, 0, "!nBekapcsoltad a kinezeteket!");
			}
		}
		if(x == 4){
			if(Ejtoernyo[id] == 0){
				if(EjtoernyoEntity[id] > 0) {
					remove_entity(EjtoernyoEntity[id]);
					EjtoernyoEntity[id] = 0;
					set_user_gravity(id, 1.0);
				}
				Ejtoernyo[id] = 1;
				chat(0, id, 0, "!nKikapcsoltad a ejtőernyőt!");
			}else{
				Ejtoernyo[id] = 0;
				chat(0, id, 0, "!nBekapcsoltad a ejtőernyőt!");
			}
		}
		if(x == 5){
			if(Sebzeskijelzo[id] == 0){
				Sebzeskijelzo[id] = 1;
				chat(0, id, 0, "!nKikapcsoltad a sebzés kijelzőt!");
			}else{
				Sebzeskijelzo[id] = 0;
				chat(0, id, 0, "!nBekapcsoltad a sebzés kijelzőt!");
			}
		}
		if(x == 6){
			if(Duplaugras[id] == 0){
				Duplaugras[id] = 1;
				chat(0, id, 0, "!nKikapcsoltad a dupla ugrást!");
			}else{
				Duplaugras[id] = 0;
				chat(0, id, 0, "!nBekapcsoltad a dupla ugrást!");
			}
		}
		if(x == 7){
			if(HUD[id] == 0){
				HUD[id] = 1;
				chat(0, id, 0, "!nKikapcsoltad a HUD-ot!");
			}else{
				HUD[id] = 0;
				chat(0, id, 0, "!nBekapcsoltad a HUD-ot!");
			}
		}
	}else{
		if(x == 1){
			if(KillFade[id] == 0){
				KillFade[id] = 1;
				chat(0, id, 0, "!nKikapcsoltad a KillFade-et!");
			}else{
				KillFade[id] = 0;
				chat(0, id, 0, "!nBekapcsoltad a KillFade-et!");
			}
		}
		if(x == 2){
			if(Kinezetek[id] == 0){
				Kinezetek[id] = 1;
				chat(0, id, 0, "!nKikapcsoltad a kinezeteket!");
			}else{
				Kinezetek[id] = 0;
				chat(0, id, 0, "!nBekapcsoltad a kinezeteket!");
			}
		}
		if(x == 3){
			if(Ejtoernyo[id] == 0){
				if(EjtoernyoEntity[id] > 0) {
					remove_entity(EjtoernyoEntity[id]);
					EjtoernyoEntity[id] = 0;
					set_user_gravity(id, 1.0);
				}
				Ejtoernyo[id] = 1;
				chat(0, id, 0, "!nKikapcsoltad a ejtőernyőt!");
			}else{
				Ejtoernyo[id] = 0;
				chat(0, id, 0, "!nBekapcsoltad a ejtőernyőt!");
			}
		}
		if(x == 4){
			if(Sebzeskijelzo[id] == 0){
				Sebzeskijelzo[id] = 1;
				chat(0, id, 0, "!nKikapcsoltad a sebzés kijelzőt!");
			}else{
				Sebzeskijelzo[id] = 0;
				chat(0, id, 0, "!nBekapcsoltad a sebzés kijelzőt!");
			}
		}
		if(x == 5){
			if(Duplaugras[id] == 0){
				Duplaugras[id] = 1;
				chat(0, id, 0, "!nKikapcsoltad a dupla ugrást!");
			}else{
				Duplaugras[id] = 0;
				chat(0, id, 0, "!nBekapcsoltad a dupla ugrást!");
			}
		}
		if(x == 6){
			if(HUD[id] == 0){
				HUD[id] = 1;
				chat(0, id, 0, "!nKikapcsoltad a HUD-ot!");
			}else{
				HUD[id] = 0;
				chat(0, id, 0, "!nBekapcsoltad a HUD-ot!");
			}
		}
		if(x == 7){
			if(HalalUF[id] == 0){
				HalalUF[id] = 1;
				chat(0, id, 0, "!nInnentől hallani fogod a már meghalt játékosokat!");
			}else{
				HalalUF[id] = 0;
				chat(0, id, 0, "!nInnentől nem fogod hallani a már meghalt játékosokat!");
			}
		}
	}
	Beallitasok(id);
}

public Csere(id, Folyamat){
	new String[1024];
	format(String, charsmax(String), "\r%s \wCserekereskedelem", MenuPrefix);
	new Menu = menu_create(String, "Csereh");
	if(Folyamat == 0){
		CserekereskedemFolyamat[id] = 0;
		new ID = Cserekereskedem[id][0];
		if(ID == 0){
			format(String, charsmax(String), "\y[\d~\wJátékos kiválasztása\d~\y]");
			menu_additem(Menu, String, "1");
			format(String, charsmax(String), "\y[\d~\wFelkérések elfogadása\d~\y]");
			menu_additem(Menu, String, "2");
		}else{
			if(Cserekereskedem[ID][0] != id){			
				format(String, charsmax(String), "\y[\d~\wFelkérés törlése\d~\y]");
				menu_additem(Menu, String, "3");
			}else{
				if(Cserekereskedem[id][6] == 0){
					if(Cserekereskedem[id][2] == 0){
						format(String, charsmax(String), "\y[\d~\wSkin kiválasztása\d~\y]");
					}else{
						format(String, charsmax(String), "\y[\d~\wSkin: %s %s %d darab\d~\y]", ModelNev[Cserekereskedem[id][1]], SkinFegyoNev[ModelFegyverTipus[Cserekereskedem[id][1]]], Cserekereskedem[id][2]);
					}
					
					menu_additem(Menu, String, "4");
					
					if(Cserekereskedem[id][4] == 0){
						format(String, charsmax(String), "\y[\d~\wLáda kiválasztása\d~\y]");
					}else{
						format(String, charsmax(String), "\y[\d~\w%s láda %d darab\d~\y]", SzerverLadakNevei[Cserekereskedem[id][3]], Cserekereskedem[id][4]);
					}
					
					menu_additem(Menu, String, "5");
					
					if(Cserekereskedem[id][5] == 0){
						format(String, charsmax(String), "\y[\d~\wKulcs megadása\d~\y]");
					}else{
						format(String, charsmax(String), "\y[\d~\w%d darab kulcs\d~\y]", Cserekereskedem[id][5]);
					}
					
					menu_additem(Menu, String, "6");
					
					if(CserekereskedemPenz[id] == 0.0){
						format(String, charsmax(String), "\y[\d~\wPénz megadása\d~\y]");
					}else{
						format(String, charsmax(String), "\y[\d~\wPénz: %.2f$\d~\y]", CserekereskedemPenz[id]+0.000001);
					}
					
					menu_additem(Menu, String, "7");
					format(String, charsmax(String), "\y[\d~\r%s \wCsere ajánlata megtekintése\d~\y]", NEV[ID]);
					menu_additem(Menu, String, "10");
					menu_additem(Menu, "\y[\d~\wMegerősítés\d~\y]", "8");
					menu_additem(Menu, "\y[\d~\wMegszakít\d~\y]", "9");
				}else{
					menu_additem(Menu, "\y[\d~\wMegerősítés visszavonás\d~\y]", "8");
					menu_additem(Menu, "\y[\d~\wMegszakít\d~\y]", "9");
				}
			}
		}
	}else if(Folyamat == 1){
		CserekereskedemFolyamat[id] = 1;
		new Talalat;
		for(new i = 1; i < JATEKOSOK; i++){
			if(Bekelllepni[i] != 0 && Belepett[i] == 0 || i == id || is_user_bot(i) || !is_user_connected(i)){
				continue;
			}
			new str[9];
			if(Cserekereskedem[i][0] == id){
				format(str, charsmax(str), "b%d", i);
			}else{
				format(str, charsmax(str), "a%d", i);
			}
			format(String, charsmax(String), "\y[\d~\w%s\d~\y]", NEV[i]);
			menu_additem(Menu, String, str);
			Talalat++;
		}
		if(!Talalat){
			format(String, charsmax(String), "\y[\d~\wNem találtam másik játékost!\d~\y]");
			menu_additem(Menu, String, "NINCS");
		}
	}else if(Folyamat == 2){
		CserekereskedemFolyamat[id] = 2;
		new Talalat;
		for(new i = 1; i < JATEKOSOK; i++){
			if(is_user_connected(i) && !is_user_bot(i) && Cserekereskedem[i][0] == id){
				new str[9];
				format(str, charsmax(str), "b%d", i);
				format(String, charsmax(String), "\y[\d~\w%s\d~\y]", NEV[i]);
				menu_additem(Menu, String, str);
				Talalat++;
			}
		}
		if(!Talalat){
			format(String, charsmax(String), "\y[\d~\wMég nincs felkérésed!\d~\y]");
			menu_additem(Menu, String, "NINCS");
		}
	}else if(Folyamat == 3){
		CserekereskedemFolyamat[id] = 3;
		format(String, charsmax(String), "\y[\d~\wVissza\d~\y]");
		menu_additem(Menu, String, "Vissza");
		new ID = Cserekereskedem[id][0];
		format(String, charsmax(String), "\y    [\d~\r%s \wCsere ajánlatai:\d~\y]", NEV[ID]);
		menu_addtext(Menu, String, 5);
		if(Cserekereskedem[ID][2] == 0){
			format(String, charsmax(String), "\y    [\d~\wMég nem választott ki skin\d~\y]");
		}else{
			format(String, charsmax(String), "\y    [\d~\wSkin: %s %s %d darab\d~\y]", ModelNev[Cserekereskedem[ID][1]], SkinFegyoNev[ModelFegyverTipus[Cserekereskedem[ID][1]]], Cserekereskedem[ID][2]);
		}
		
		menu_addtext(Menu, String, 6);
		
		if(Cserekereskedem[ID][4] == 0){
			format(String, charsmax(String), "\y    [\d~\wMég nem választott ki láda\d~\y]");
		}else{
			format(String, charsmax(String), "\y    [\d~\w%s láda %d darab\d~\y]", SzerverLadakNevei[Cserekereskedem[ID][3]], Cserekereskedem[ID][4]);
		}
		
		menu_addtext(Menu, String, 7);
		
		if(Cserekereskedem[ID][5] == 0){
			format(String, charsmax(String), "\y    [\d~\wMég nem adott meg egy kulcsot sem\d~\y]");
		}else{
			format(String, charsmax(String), "\y    [\d~\w%d darab kulcs\d~\y]", Cserekereskedem[ID][5]);
		}
		
		menu_addtext(Menu, String, 8);
		
		if(CserekereskedemPenz[ID] == 0.0){
			format(String, charsmax(String), "\y    [\d~\wMég nem adott meg pénzt\d~\y]");
		}else{
			format(String, charsmax(String), "\y    [\d~\wPénz: %.2f$\d~\y]", CserekereskedemPenz[ID]+0.000001);
		}
		
		menu_addtext(Menu, String, 9);
	}
	
	menu_setprop(Menu, MPROP_NEXTNAME, "Tovább");
	menu_setprop(Menu, MPROP_BACKNAME, "Vissza");
	menu_setprop(Menu, MPROP_EXITNAME, "Kilépés");
	menu_display(id, Menu);
}

public Csereh(id, Menu, Item){
	if(Item == MENU_EXIT){
		menu_destroy(Menu);
		return;
	}
	
	new Data[14], Line[32];
	new Access, Callback;
	menu_item_getinfo(Menu, Item, Access, Data, charsmax(Data), Line, charsmax(Line), Callback);
	
	
	if(equal(Data, "Vissza")){
		Csere(id, 0);
		return;
	}

	if(containi(Data, "a") != -1){
		replace_all(Data, 13, "a", "");
		new ID = str_to_num(Data);
		chat(0, id, 0, "A csere felkérés elküldve !g%s !nszámára!", NEV[ID]);
		chat(0, ID, 0, "Csere felkérés érkezett tőlle: !g%s!n!", NEV[id]);
		Cserekereskedem[id][0] = ID;
		Csere(id, 0);
		return;
	}
	
	if(containi(Data, "b") != -1){
		replace_all(Data, 13, "b", "");
		new ID = str_to_num(Data);
		chat(0, id, 0, "Elfogadtad !g%s !ncsere felkérését!", NEV[ID]);
		chat(0, ID, 0, "!g%s !nelfogadta a csere felkérésed!", NEV[id]);
		Cserekereskedem[id][0] = ID;
		Csere(ID, 0);
		Csere(id, 0);
		return;
	}
	if(equal(Data, "NINCS")){
		Csere(id, 0);
		return;
	}
	
	new x = str_to_num(Data);
	
	if(x == 1){
		Csere(id, 1);
		return;
	}
	if(x == 2){
		Csere(id, 2);
		return;
	}
	if(x == 3){
		new ID = Cserekereskedem[id][0];
		if(Cserekereskedem[ID][0] != id){
			Cserekereskedem[id][0] = 0;
		}else{
			Csere(id, 0);
			return;
		}
	}
	if(x == 4){
		Raktar(id, 1);
		return;
	}
	if(x == 5){
		LadaNyitas(id, 1, 0);
		return;
	}
	if(x == 6){
		if(Cserekereskedem[id][5] > 0){
			Penz[id] += Cserekereskedem[id][5];
			Cserekereskedem[id][5] = 0;
			new ID = Cserekereskedem[id][0];
			if(CserekereskedemFolyamat[ID] == 3){
				Csere(ID, 3);
			}else if(Cserekereskedem[id][6] != 0){
				Csere(ID, 0);
				Cserekereskedem[ID][6] = 0;
			}else{
				Csere(ID, 0);
			}
			chat(0, ID, 0, "!g%s !nmódosított a csere ajánlatain!", NEV[id]);
		}
		client_cmd(id, "messagemode CsereKulcs");
		return;
	}
	if(x == 7){
		if(CserekereskedemPenz[id] > 0.00){
			Penz[id] += CserekereskedemPenz[id];
			CserekereskedemPenz[id] = 0.0;
			new ID = Cserekereskedem[id][0];
			if(CserekereskedemFolyamat[ID] == 3){
				Csere(ID, 3);
			}else if(Cserekereskedem[id][6] != 0){
				Csere(ID, 0);
				Cserekereskedem[ID][6] = 0;
			}else{
				Csere(ID, 0);
			}
			chat(0, ID, 0, "!g%s !nmódosított a csere ajánlatain!", NEV[id]);
		}
		client_cmd(id, "messagemode CserePenz");
		return;
	}
	if(x == 8){
		if(Cserekereskedem[id][6] == 1){
			Cserekereskedem[id][6] = 0;
		}else{
			Cserekereskedem[id][6] = 1;
		}
		new ID = Cserekereskedem[id][0];
		if(Cserekereskedem[ID][6] == 1 && Cserekereskedem[id][6] == 1){
			CserekereskedemSiker(id);
			return;
		}
		Csere(id, 0);
		return;
	}
	if(x == 9){
		CsereTorles(id);
	}
	if(x == 10){
		Csere(id, 3);
		return;
	}
	Csere(id, 0);
}

public Piac(id, Folyamat){
	new String[1024];
	format(String, charsmax(String), "\r%s \wKözösségi piac", MenuPrefix);
	new Menu = menu_create(String, "Piach");
	if(Folyamat == 0){
		if(!TrieKeyExists(PiacCuccokID, STEAMID[id])){
			format(String, charsmax(String), "\y[\d~\wTárgy kirakása a piacra\d~\y]");
			menu_additem(Menu, String, "-1");
		}
		
		for(new i = 0; i < ArraySize(PiacCuccokSteamID); i++){
			new SteamID[50];
			
			ArrayGetString(PiacCuccokSteamID, i, SteamID, charsmax(SteamID));
			new Adat[PiacAdatok];
			
			TrieGetArray(PiacCuccok, SteamID, Adat, sizeof Adat);
	/*		
			new LejarSzoveg[200];
			
			new Ido = Adat[P_Ido]-get_systime();
			new Nap = Ido / (24 * 3600);
			if(Nap > 0){
				format(LejarSzoveg, 200, " %d Nap", Nap);
			}
			new Ora = (Ido - Nap * 86400)/3600;
			if(Ora > 0){
				format(LejarSzoveg, 200, "%s %d", LejarSzoveg, Ora);
			}else{
				format(LejarSzoveg, 200, "%s 00", LejarSzoveg);
			}
			new Perc = (Ido - Nap * 86400 - Ora * 3600)/60;
			if(Perc > 0){
				format(LejarSzoveg, 200, "%s:%d", LejarSzoveg, Perc);
			}else{
				format(LejarSzoveg, 200, "%s:00", LejarSzoveg);
			}
			new MP = (Ido - Nap * 86400 - Ora * 3600 - Perc * 60);
			if(MP > 0){
				format(LejarSzoveg, 200, "%s:%d", LejarSzoveg, MP);
			}else{
				format(LejarSzoveg, 200, "%s:00", LejarSzoveg);
			}
	*/
			new Nev[50];
			new ID = find_player("c", SteamID);
			if(ID != 0){
				format(Nev, charsmax(Nev), "%s", NEV[ID]);
			}else{
				format(Nev, charsmax(Nev), "%s", Adat[P_Nev]);
			}
			if(Adat[P_Tipus] == 1){
				format(String, charsmax(String), "\y%s \r%s \wSkin \s%d \wDarab \yÁra: \r%.2f$ \wEladó:\y%s", SkinFegyoNev[ModelFegyverTipus[Adat[P_Targy]]], ModelNev[Adat[P_Targy]], Adat[P_Mennyiseg], str_to_float(Adat[P_Ar])+0.000001, Nev);
				new S[35];
				format(S, charsmax(S), "%s", SteamID);
				menu_additem(Menu, String, S);
			}else if(Adat[P_Tipus] == 2){
				format(String, charsmax(String), "\y%s \r%s \wLáda \s%d \wDarab \yÁra: \r%.2f$ \wEladó:\y%s", SkinFegyoNev[ModelFegyverTipus[Adat[P_Targy]]], ModelNev[Adat[P_Targy]], Adat[P_Mennyiseg], str_to_float(Adat[P_Ar])+0.000001, Nev);
				new S[35];
				format(S, charsmax(S), "%s", SteamID);
				menu_additem(Menu, String, S);
			}else if(Adat[P_Tipus] == 3){
				format(String, charsmax(String), "\y%s \r%s \wKulcs \s%d \wDarab \yÁra: \r%.2f$ \wEladó:\y%s", SkinFegyoNev[ModelFegyverTipus[Adat[P_Targy]]], ModelNev[Adat[P_Targy]], Adat[P_Mennyiseg], str_to_float(Adat[P_Ar])+0.000001, Nev);
				new S[35];
				format(S, charsmax(S), "%s", SteamID);
				menu_additem(Menu, String, S);
			}
		}
		menu_setprop(Menu, MPROP_PERPAGE, 4);
	}else{
		new Mehet;
		if(PiacJatekos[id][2] == 0){
			format(String, charsmax(String), "\y[\d~\wSkin kiválasztása\d~\y]");
			menu_additem(Menu, String, "-2");
			format(String, charsmax(String), "\y[\d~\wLáda kiválasztása\d~\y]");
			menu_additem(Menu, String, "-3");
			format(String, charsmax(String), "\y[\d~\wKulcs mennyiségének megadása\d~\y]");
			menu_additem(Menu, String, "-4");
		}else{
			Mehet++;
			if(PiacJatekos[id][0] == 1){
				format(String, charsmax(String), "\y[\d~\w%s %s Skin \r%d\d~\y]", ModelNev[PiacJatekos[id][1]], SkinFegyoNev[ModelFegyverTipus[PiacJatekos[id][1]]], PiacJatekos[id][2]);
				menu_additem(Menu, String, "-5");
			}else if(PiacJatekos[id][0] == 2){
				format(String, charsmax(String), "\y[\d~\w%s Láda \r%d\d~\y]", SzerverLadakNevei[PiacJatekos[id][1]], PiacJatekos[id][2]);
				menu_additem(Menu, String, "-5");
			}else if(PiacJatekos[id][0] == 3){
				format(String, charsmax(String), "\y[\d~\r%d \wKulcs \d~\y]", PiacJatekos[id][2]);
				menu_additem(Menu, String, "-5");
			}
		}
		if(PiacJatekosPenz[id] == 0.00){
			format(String, charsmax(String), "\y[\d~\r\wÁr megadása\d~\y]", PiacJatekos[id][2]);
			menu_additem(Menu, String, "-6");
		}else{
			Mehet++;
			format(String, charsmax(String), "\y[\d~\r\wÁr: %.2f\d~\y]", PiacJatekosPenz[id]+0.000001);
			menu_additem(Menu, String, "-6");
		}
		if(Mehet == 2){
			format(String, charsmax(String), "\y[\d~\rMehet a piacra\d~\y]", PiacJatekosPenz[id]+0.000001);
			menu_additem(Menu, String, "-7");
		}
	}
	menu_setprop(Menu, MPROP_NEXTNAME, "Tovább");
	menu_setprop(Menu, MPROP_BACKNAME, "Vissza");
	menu_setprop(Menu, MPROP_EXITNAME, "Kilépés");
	menu_display(id, Menu);
}

public Piach(id, Menu, Item){
	if(Item == MENU_EXIT){
		menu_destroy(Menu);
		return;
	}
	
	new Data[50], Line[32];
	new Access, Callback;
	menu_item_getinfo(Menu, Item, Access, Data, charsmax(Data), Line, charsmax(Line), Callback);
	
	new x = str_to_num(Data);
	
	if(x == -1){
		Piac(id, 1);
		return;
	}else if(x == -2){
		Raktar(id, 2);
		return;
	}else if(x == -3){
		LadaNyitas(id, 2, 0);
		return;
	}else if(x == -4){
		PiacJatekos[id][0] = 3;
		client_cmd(id, "messagemode PiacKulcs");
		Piac(id, 1);
		return;
	}else if(x == -5){
		if(PiacJatekos[id][2] != 0){
			switch(PiacJatekos[id][0]){
				case 1:{
					JatekosFegyo[id][PiacJatekos[id][1]] += PiacJatekos[id][2];
					JatekosFegyverOsszes[id][ModelFegyverTipus[PiacJatekos[id][1]]] += PiacJatekos[id][2];
				}
				case 2:{
					JatekosLadak[id][PiacJatekos[id][1]] += PiacJatekos[id][2];
				}
				case 3:{
					Kulcsaim[id][0] += PiacJatekos[id][2];
				}
			}
		}
		PiacJatekos[id][0] = 0;
		PiacJatekos[id][1] = 0;
		PiacJatekos[id][2] = 0;
		Piac(id, 1);
		return;
	}else if(x == -6){
		client_cmd(id, "messagemode PiacPenz");
		Piac(id, 1);
		return;
	}else if(x == -7){
		static Adat[PiacAdatok];
		new SteamID[60];
		
		format(SteamID, charsmax(SteamID), "%d%s", get_systime(), STEAMID[id]);
		
		Adat[P_Tipus] = PiacJatekos[id][0];
		Adat[P_Targy] = PiacJatekos[id][1];
		Adat[P_Mennyiseg] = PiacJatekos[id][2];
		Adat[P_Ido] = get_systime()+60*60*6;
		Adat[P_ID] = JELENLEGIID;
		format(Adat[P_Nev], 50, "%s", NEV[id]);
		
		format(Adat[P_Ar], sizeof(Adat[P_Ar])-1, "%f", PiacJatekosPenz[id]);
		
		ArrayPushString(PiacCuccokSteamID, SteamID);
		set_task(float(Adat[P_Ido]-get_systime()), "PiacLejar", JELENLEGIID, SteamID, charsmax(SteamID));
		
		JELENLEGIID++;
		
		TrieSetCell(PiacCuccokID, SteamID[containi(SteamID, "steam_")], 0);
		TrieSetArray(PiacCuccok, SteamID, Adat, sizeof Adat);
		
		new Data[1];
		Data[0] = 0;
		new query[1024];
		format(query, charsmax(query), "INSERT INTO `%sPiac` (SteamID, Nev, Tipus, Targy, Mennyiseg, Ar, Lejarat) VALUES (^"%s^", ^"%s^", ^"%d^", ^"%d^", ^"%d^", ^"%f^", ^"%d^")", TablaNev, SteamID[containi(SteamID, "steam_")], Adat[P_Nev], Adat[P_Tipus], Adat[P_Targy], Adat[P_Mennyiseg], floatstr(Adat[P_Ar]), Adat[P_Ido]);
		SQL_ThreadQuery(SQLTuple,"QuerySetData", query, Data, 1);
		if(Adat[P_Tipus] == 1){
			chat(0, 0, 0, "!t%s !nkirakott a piacra !g%d !ndarab !t%s !g%s !nskint a piacra! !gára!n: !t%.2f!g$!n!", NEV[id], Adat[P_Mennyiseg], ModelNev[Adat[P_Targy]], SkinFegyoNev[ModelFegyverTipus[Adat[P_Targy]]], floatstr(Adat[P_Ar])+0.000001);
		}else if(Adat[P_Tipus] == 2){
			chat(0, 0, 0, "!t%s !nkirakott a piacra !g%d !ndarab !t%s !nládát a piacra! !gára!n: !t%.2f!t$!n!", NEV[id], Adat[P_Mennyiseg], SzerverLadakNevei[Adat[P_Targy]], floatstr(Adat[P_Ar])+0.000001);
		}else if(Adat[P_Tipus] == 3){
			chat(0, 0, 0, "!t%s !nkirakott a piacra !g%d !ndarab !gkulcsot !na piacra! !gára!n: !t%.2f!g$!n!", NEV[id], Adat[P_Mennyiseg], floatstr(Adat[P_Ar])+0.000001);
		}
		
		PiacJatekos[id][0] = 0;
		PiacJatekos[id][1] = 0;
		PiacJatekos[id][2] = 0;
		PiacJatekosPenz[id] = 0.0;
		Piac(id, 0);
		return;
	}else{
		new SteamID[35];
		format(SteamID, charsmax(SteamID), "%s", Data[containi(Data, "steam_")]);
		if(equali(STEAMID[id], SteamID)){
			if(TrieKeyExists(PiacCuccok, Data)){
				new Adat[PiacAdatok];
				new LejarSzoveg[200];
				TrieGetArray(PiacCuccok, Data, Adat, sizeof Adat);
				new Ido = Adat[P_Ido]-get_systime();
				new Nap = Ido / (24 * 3600);
				if(Nap > 0){
					format(LejarSzoveg, 200, "!g%d !nNap", Nap);
				}
				new Ora = (Ido - Nap * 86400)/3600;
				if(Ora > 0){
					format(LejarSzoveg, 200, "%s !g%d !nÓra", LejarSzoveg, Ora);
				}
				new Perc = (Ido - Nap * 86400 - Ora * 3600)/60;
				if(Perc > 0){
					format(LejarSzoveg, 200, "%s !g%d !nPerc", LejarSzoveg, Perc);
				}
				new MP = (Ido - Nap * 86400 - Ora * 3600 - Perc * 60);
				if(MP > 0){
					format(LejarSzoveg, 200, "%s !g%d !nMásodperc", LejarSzoveg, MP);
				}
				chat(0, id, 0, "Ennyi idő múlva kapod vissza a tárgyad:%s!", LejarSzoveg);
			}else{
				chat(0, id, 0, "Már megvették, vagy lejárt az idő, és visszakaptad a tágyat amit kiraktál a piacra!");
			}
		}else{
			if(TrieKeyExists(PiacCuccok, Data)){
				new Adat[PiacAdatok];
				TrieGetArray(PiacCuccok, Data, Adat, sizeof Adat);
				new Float:Ar = str_to_float(Adat[P_Ar]);
				if(Ar > Penz[id]){
					chat(0, id, 0, "Neked nincs elég !gpénzed !nhogy meg tud venni ezt a tárgyat!");
				}else{	
					new Nev[50];
					new SQLData[1];
					SQLData[0] = 0;
					new query[1024];
					if(Adat[P_Tipus] == 1){
						new ID = find_player("c", SteamID);
						if(ID != 0){
							Penz[ID] += Ar;
							Penz[id] -= Ar;
							JatekosFegyo[id][Adat[P_Targy]] += Adat[P_Mennyiseg];
							JatekosFegyverOsszes[id][ModelFegyverTipus[Adat[P_Targy]]] += Adat[P_Mennyiseg];
							format(Nev, charsmax(Nev), "%s", NEV[ID]);
						}else{
							PiacVasarlas(SteamID, Ar);
							Penz[id] -= Ar;
							JatekosFegyo[id][Adat[P_Targy]] += Adat[P_Mennyiseg];
							JatekosFegyverOsszes[id][ModelFegyverTipus[Adat[P_Targy]]] += Adat[P_Mennyiseg];
							format(Nev, charsmax(Nev), "%s", Adat[P_Nev]);
						}
						remove_task(Adat[P_ID]);
						TrieDeleteKey(PiacCuccok, Data);
						TrieDeleteKey(PiacCuccokID, SteamID);
						new c = ArrayFindString(PiacCuccokSteamID, Data);
						ArrayDeleteItem(PiacCuccokSteamID, c);
						format(query, charsmax(query), "DELETE FROM `%sPiac` WHERE SteamID = ^"%s^";", TablaNev, SteamID[containi(SteamID, "steam_")]);
						SQL_ThreadQuery(SQLTuple,"QuerySetData", query, SQLData, 1);
						chat(0, 0, 0, "!t%s !nvett !g%d !ndarab !t%s !g%s !nskint a piacról! !gEladó!n: !t%s !gÁra!n: !t%.2f!g$!n!", NEV[id], Adat[P_Mennyiseg], ModelNev[Adat[P_Targy]], SkinFegyoNev[ModelFegyverTipus[Adat[P_Targy]]], Nev, Ar+0.000001);
					}else if(Adat[P_Tipus] == 2){
						new ID = find_player("c", SteamID);
						if(ID != 0){
							Penz[ID] += Ar;
							Penz[id] -= Ar;
							JatekosLadak[id][Adat[P_Targy]] += Adat[P_Mennyiseg];
							format(Nev, charsmax(Nev), "%s", NEV[ID]);
						}else{
							PiacVasarlas(SteamID, Ar);
							Penz[id] -= Ar;
							JatekosLadak[id][Adat[P_Targy]] += Adat[P_Mennyiseg];
							format(Nev, charsmax(Nev), "%s", Adat[P_Nev]);
						}
						remove_task(Adat[P_ID]);
						TrieDeleteKey(PiacCuccok, Data);
						TrieDeleteKey(PiacCuccokID, SteamID);
						new c = ArrayFindString(PiacCuccokSteamID, Data);
						ArrayDeleteItem(PiacCuccokSteamID, c);
						format(query, charsmax(query), "DELETE FROM `%sPiac` WHERE SteamID = ^"%s^";", TablaNev, SteamID[containi(SteamID, "steam_")]);
						SQL_ThreadQuery(SQLTuple,"QuerySetData", query, Data, 1);
						chat(0, 0, 0, "!t%s !nvett !g%d !ndarab !t%s !nládát a piacról! !gEladó!n: !t%s !gÁra!n: !t%.2f!t$!n!", NEV[id], Adat[P_Mennyiseg], SzerverLadakNevei[Adat[P_Targy]], Nev, Ar);
					}else if(Adat[P_Tipus] == 3){
						new ID = find_player("c", SteamID);
						if(ID != 0){
							Penz[ID] += Ar;
							Penz[id] -= Ar;
							Kulcsaim[id][0] += Adat[P_Mennyiseg];
							format(Nev, charsmax(Nev), "%s", NEV[ID]);
						}else{
							PiacVasarlas(SteamID, Ar);
							Penz[id] -= Ar;
							Kulcsaim[id][0] += Adat[P_Mennyiseg];
							format(Nev, charsmax(Nev), "%s", Adat[P_Nev]);
						}
						remove_task(Adat[P_ID]);
						TrieDeleteKey(PiacCuccok, Data);
						TrieDeleteKey(PiacCuccokID, SteamID);
						new c = ArrayFindString(PiacCuccokSteamID, Data);
						ArrayDeleteItem(PiacCuccokSteamID, c);
						format(query, charsmax(query), "DELETE FROM `%sPiac` WHERE SteamID = ^"%s^";", TablaNev, SteamID[containi(SteamID, "steam_")]);
						SQL_ThreadQuery(SQLTuple,"QuerySetData", query, Data, 1);
						chat(0, 0, 0, "!t%s !nvett !g%d !ndarab !gkulcsot !na piacról! !gEladó!n: !t%s !gÁra!n: !t%.2f!g$!n!", NEV[id], Adat[P_Mennyiseg], Nev, Ar);
					}
				}
			}else{
				chat(0, id, 0, "!gLassú !nvoltál, már !tmegvették!n, vagy !tlejárt !naz idő!");
			}
		}
	}
	Piac(id, 0);
}


public CsereTorles(id){
	new ID = Cserekereskedem[id][0];
	if(ID != 0){
		CserekereskedemVisszaad(id);
		CserekereskedemTorles(id);
		if(is_user_connected(id)){
			chat(0, id, 0, "Sikeresen megszakítottad a cserét!");
			Csere(id, 0);
		}
		CserekereskedemVisszaad(ID);
		CserekereskedemTorles(ID);
		chat(0, ID, 0, "%s megszakította a cserét!", NEV[id]);
		Csere(ID, 0);
	}
}

public CserekereskedemVisszaad(id){
	if(Cserekereskedem[id][2] != 0){
		JatekosFegyo[id][Cserekereskedem[id][1]] += Cserekereskedem[id][2];
		JatekosFegyverOsszes[id][ModelFegyverTipus[Cserekereskedem[id][1]]] += Cserekereskedem[id][2];
	}
	if(Cserekereskedem[id][4] != 0){
		JatekosLadak[id][Cserekereskedem[id][3]] += Cserekereskedem[id][4];
	}
	if(Cserekereskedem[id][5] > 0){
		Kulcsaim[id][0] += Cserekereskedem[id][5];
	}
	if(CserekereskedemPenz[id] > 0.00){
		Penz[id] += CserekereskedemPenz[id];
	}
}

public CserekereskedemSiker(id){
	new ID = Cserekereskedem[id][0];
	if(Cserekereskedem[ID][2] != 0){
		JatekosFegyo[id][Cserekereskedem[ID][1]] += Cserekereskedem[ID][2];
		JatekosFegyverOsszes[id][ModelFegyverTipus[Cserekereskedem[ID][1]]] += Cserekereskedem[ID][2];
		if(JelenlegiFegyo[ID][ModelFegyverTipus[Cserekereskedem[ID][1]]] == Cserekereskedem[ID][1] && JatekosFegyverOsszes[ID][ModelFegyverTipus[Cserekereskedem[ID][1]]] == 0){
			JelenlegiFegyo[ID][ModelFegyverTipus[Cserekereskedem[ID][1]]] = 0;
		}
	}
	if(Cserekereskedem[ID][4] != 0){
		JatekosLadak[id][Cserekereskedem[ID][3]] += Cserekereskedem[ID][4];
	}
	if(Cserekereskedem[ID][5] > 0){
		Kulcsaim[id][0] += Cserekereskedem[ID][5];
	}
	if(CserekereskedemPenz[ID] > 0.00){
		Penz[id] += CserekereskedemPenz[ID];
	}
	
	if(Cserekereskedem[id][2] != 0){
		JatekosFegyo[ID][Cserekereskedem[id][1]] += Cserekereskedem[id][2];
		JatekosFegyverOsszes[ID][ModelFegyverTipus[Cserekereskedem[id][1]]] += Cserekereskedem[id][2];
		if(JelenlegiFegyo[id][ModelFegyverTipus[Cserekereskedem[id][1]]] == Cserekereskedem[id][1] && JatekosFegyverOsszes[id][ModelFegyverTipus[Cserekereskedem[id][1]]] == 0){
			JelenlegiFegyo[id][ModelFegyverTipus[Cserekereskedem[id][1]]] = 0;
		}
	}
	if(Cserekereskedem[id][4] != 0){
		JatekosLadak[ID][Cserekereskedem[id][3]] += Cserekereskedem[id][4];
	}
	if(Cserekereskedem[id][5] > 0){
		Kulcsaim[ID][0] += Cserekereskedem[id][5];
	}
	if(CserekereskedemPenz[id] > 0.00){
		Penz[ID] += CserekereskedemPenz[id];
	}
	CserekereskedemTorles(id);
	CserekereskedemTorles(ID);
	chat(0, id, 0, "A csere sikeresen megtörtént!");
	chat(0, ID, 0, "A csere sikeresen megtörtént!");
	Csere(id, 0);
	Csere(ID, 0);
}

public CserekereskedemTorles(id){
	Cserekereskedem[id][0] = 0;
	Cserekereskedem[id][1] = 0;
	Cserekereskedem[id][2] = 0;
	Cserekereskedem[id][3] = 0;
	Cserekereskedem[id][4] = 0;
	Cserekereskedem[id][5] = 0;
	Cserekereskedem[id][6] = 0;
	CserekereskedemPenz[id] = 0.0;
}

public Raktar(id, Folyamat){
	new String[500], Nincs = 0;
	format(String, charsmax(String), "\r%s \wRaktár", MenuPrefix);
	new Menu = menu_create(String, "Raktarh");
	if(Folyamat == 0){
		for(new a = 1;a < JATEKOSOK;a++){
			if(Sorred[a] == 0){
				break;
			}
			if(JatekosFegyverOsszes[id][Sorred[a]] > 0){
				new NumToString[6];
				num_to_str(Sorred[a], NumToString, 5);
				format(String, charsmax(String), "\y[\d~\y%s \wkinézetek: \r%d \wdarab\d~\y]", SkinFegyoNev[Sorred[a]], JatekosFegyverOsszes[id][Sorred[a]]);
				menu_additem(Menu, String, NumToString);
				Nincs = 1;
			}
		}
		if(Nincs == 0){
			menu_additem(Menu, "\dJelenleg nincs egy darab kinézeted sem!", "NINCS1");
		}
	}else if(Folyamat == 1){
		if(Cserekereskedem[id][1] != 0){
			format(String, charsmax(String), "\y[\d~\wKinézet eltávolitása\d~\y]");
			menu_additem(Menu, String, "TORLES");
		}
		for(new a = 1;a < JATEKOSOK;a++){
			if(Sorred[a] == 0){
				break;
			}
			if(JatekosFegyverOsszes[id][Sorred[a]] > 0){
				new NumToString[6];
				format(NumToString, charsmax(NumToString), "a%d", Sorred[a]);
				format(String, charsmax(String), "\y[\d~\y%s \wkinézetek: \r%d \wdarab\d~\y]", SkinFegyoNev[Sorred[a]], JatekosFegyverOsszes[id][Sorred[a]]);
				menu_additem(Menu, String, NumToString);
				Nincs = 1;			
			}
		}
		if(Nincs == 0){
			menu_additem(Menu, "\dJelenleg nincs egy darab kinézeted sem!", "NINCS2");
		}
	}else if(Folyamat == 2){
		for(new a = 1;a < JATEKOSOK;a++){
			if(Sorred[a] == 0){
				break;
			}
			if(JatekosFegyverOsszes[id][Sorred[a]] > 0){
				new NumToString[6];
				format(NumToString, charsmax(NumToString), "b%d", Sorred[a]);
				format(String, charsmax(String), "\y[\d~\y%s \wkinézetek: \r%d \wdarab\d~\y]", SkinFegyoNev[Sorred[a]], JatekosFegyverOsszes[id][Sorred[a]]);
				menu_additem(Menu, String, NumToString);
				Nincs = 1;
			}
		}
		if(Nincs == 0){
			menu_additem(Menu, "\dJelenleg nincs egy darab kinézeted sem!", "NINCS3");
		}
	}
	
	menu_setprop(Menu, MPROP_NEXTNAME, "Tovább");
	menu_setprop(Menu, MPROP_BACKNAME, "Vissza");
	menu_setprop(Menu, MPROP_EXITNAME, "Kilépés");
	menu_display(id, Menu);
}

public Raktarh(id, Menu, Item){
	if(Item == MENU_EXIT){
		menu_destroy(Menu);
		return;
	}
	
	new Data[14], Line[32];
	new Access, Callback;
	menu_item_getinfo(Menu, Item, Access, Data, charsmax(Data), Line, charsmax(Line), Callback);
	
	if(equal(Data, "NINCS1")){
		FoMenu(id);
		return;
	}
	
	if(equal(Data, "NINCS2")){
		Csere(id, 0);
		return;
	}
	
	if(equal(Data, "NINCS3")){
		Piac(id, 1);
		return;
	}
	
	if(equal(Data, "TORLES")){
		JatekosFegyo[id][Cserekereskedem[id][1]] += Cserekereskedem[id][2];
		JatekosFegyverOsszes[id][ModelFegyverTipus[Cserekereskedem[id][1]]] += Cserekereskedem[id][2];
		Cserekereskedem[id][1] = 0;
		Cserekereskedem[id][2] = 0;
		Cserekereskedem[id][6] = 0;
		Csere(id, 0);
		new ID = Cserekereskedem[id][0];
		if(CserekereskedemFolyamat[ID] == 3){
			Csere(ID, 3);
		}else if(Cserekereskedem[id][6] != 0){
			Csere(ID, 0);
			Cserekereskedem[ID][6] = 0;
		}else{
			Csere(ID, 0);
		}
		chat(0, ID, 0, "!g%s !nmódosított a csere ajánlatain!", NEV[id]);
		return;
	}
	
	if(containi(Data, "b") != -1){
		replace_all(Data, 13, "b", "");
		new x = str_to_num(Data);
		RaktarFegyver(id, 2, x, 0);
	}else if(containi(Data, "a") != -1){
		replace_all(Data, 13, "a", "");
		new x = str_to_num(Data);
		RaktarFegyver(id, 1, x, 0);
	}else{
		new x = str_to_num(Data);
		RaktarFegyver(id, 0, x, 0);
	}
	
}

public RaktarFegyver(id, folyamat, fegyo, Oldal){
	new String[500];
	format(String, charsmax(String), "\r%s \w%s \ykinézetek", MenuPrefix, SkinFegyoNev[fegyo]);
	new Menu = menu_create(String, "RaktarFegyverh");
	if(folyamat == 1){
		for(new b = 1;b < FegyokSzama[fegyo];b++){
			if(JatekosFegyo[id][Fegyok[fegyo][b]] != 0){
				new NumToString[6];
				format(NumToString, charsmax(NumToString), "a%d", Fegyok[fegyo][b]);
				format(String, charsmax(String), "\y[\d~\w%s \r%s \y%d \wdarab\d~\y]", ModelNev[Fegyok[fegyo][b]], SkinFegyoNev[fegyo], JatekosFegyo[id][Fegyok[fegyo][b]]);
				menu_additem(Menu, String, NumToString);
			}
		}
	}else if(folyamat == 0){
		if(JelenlegiFegyo[id][fegyo] != 0){
			new NumToString[20];
			format(NumToString, charsmax(NumToString), "fegyo%d", fegyo);
			format(String, charsmax(String), "\y[\d~\wAlap kinézet\d~\y]");
			menu_additem(Menu, String, NumToString);
		}
		for(new b = 1;b < FegyokSzama[fegyo];b++){
			if(JatekosFegyo[id][Fegyok[fegyo][b]] != 0){
				new NumToString[6];
				num_to_str(Fegyok[fegyo][b], NumToString, 5);
				format(String, charsmax(String), "\y[\d~\w%s \r%s \y%d \wdarab\d~\y]", ModelNev[Fegyok[fegyo][b]], SkinFegyoNev[fegyo], JatekosFegyo[id][Fegyok[fegyo][b]]);
				menu_additem(Menu, String, NumToString);
			}
		}
	}else if(folyamat == 2){
		for(new b = 1;b < FegyokSzama[fegyo];b++){
			if(JatekosFegyo[id][Fegyok[fegyo][b]] != 0){
				new NumToString[6];
				format(NumToString, charsmax(NumToString), "b%d", Fegyok[fegyo][b]);
				format(String, charsmax(String), "\y[\d~\w%s \r%s \y%d \wdarab\d~\y]", ModelNev[Fegyok[fegyo][b]], SkinFegyoNev[fegyo], JatekosFegyo[id][Fegyok[fegyo][b]]);
				menu_additem(Menu, String, NumToString);
			}
		}
	}
	
	menu_setprop(Menu, MPROP_NEXTNAME, "Tovább");
	menu_setprop(Menu, MPROP_BACKNAME, "Vissza");
	menu_setprop(Menu, MPROP_EXITNAME, "Kilépés");
	menu_display(id, Menu, Oldal);
}

public RaktarFegyverh(id, Menu, Item){
	if(Item == MENU_EXIT){
		menu_destroy(Menu);
		return;
	}
	
	new Data[20], Line[32];
	new Access, Callback;
	menu_item_getinfo(Menu, Item, Access, Data, charsmax(Data), Line, charsmax(Line), Callback);
	
	new Oldal = Item/7;
	if(containi(Data, "b") != -1){
		replace_all(Data, 20, "b", "");
		new x = str_to_num(Data);
		PiacJatekos[id][0] = 1;
		PiacJatekos[id][1] = x;
		PiacJatekos[id][2] = 0;
		chat(0, id, 0, "!tÍrd be hogy hány darab skint akarsz eladni!");
		client_cmd(id, "messagemode PiacSkin");
		return;
	}else if(containi(Data, "a") != -1){
		replace_all(Data, 20, "a", "");
		new x = str_to_num(Data);
		Cserekereskedem[id][1] = x;
		Cserekereskedem[id][2] = 0;
		chat(0, id, 0, "!tÍrd be hogy hány darab skint akarsz cserélni!");
		client_cmd(id, "messagemode CsereSkin");
		return;
	}else if(containi(Data, "fegyo") != -1){
		replace_all(Data, 20, "fegyo", "");
		new x = str_to_num(Data);
		
		JelenlegiFegyo[id][x] = 0;
		RaktarFegyver(id, 0, ModelFegyverTipus[x], Oldal);
	}else{
		new x = str_to_num(Data);
		
		if(JelenlegiFegyo[id][ModelFegyverTipus[x]] != x){
			JelenlegiFegyo[id][ModelFegyverTipus[x]] = x;
			chat(0, id, 0, "!nBeállitottad a(z) !t%s !nfegyeverre a következő kinézetet: !g%s!n!", SkinFegyoNev[ModelFegyverTipus[x]], ModelNev[x]);
		}else{
			chat(0, id, 0, "!nEz a kinézet jelenleg is használatban van!");
		}
		RaktarFegyver(id, 0, ModelFegyverTipus[x], Oldal);
	}
	
}

public Ladak(id){
	new String[500];
	format(String, charsmax(String), "\r%s \wLádák", MenuPrefix);
	new Menu = menu_create(String, "Ladakh");
	
	format(String, charsmax(String), "\y[\d~\yLádáim\d~\y]^n");		
	menu_additem(Menu, String, "1");
	format(String, charsmax(String), "\y[\d~\yKulcsaim\d~\y]^n");		
	menu_additem(Menu, String, "2");
	format(String, charsmax(String), "\y[\d~\yVásárlás\d~\y]");		
	menu_additem(Menu, String, "3");
	
	menu_setprop(Menu, MPROP_EXITNAME, "Kilépés");
	menu_display(id, Menu);
}

public Ladakh(id, Menu, Item){
	if(Item == MENU_EXIT){
		menu_destroy(Menu);
		return;
	}
	
	new Data[14], Line[32];
	new Access, Callback;
	menu_item_getinfo(Menu, Item, Access, Data, charsmax(Data), Line, charsmax(Line), Callback);
	
	new x = str_to_num(Data);
	
	switch(x){
		case 1: LadaNyitas(id, 0, 0);
		case 2: KulcsaimMenu(id, 0, 0);
		case 3: LadaVasarlas(id, 0);
	}
}


public KulcsaimMenu(id, folyamat, Oldal){
	new String[500];
	format(String, charsmax(String), "\r%s \wKulcsaim", MenuPrefix);
	new Menu = menu_create(String, "KulcsaimMenuh");
	new Van = 0;
	if(folyamat == 0){
		if(Kulcsaim[id][0] > 0){
			format(String, charsmax(String), "\y[\d~\wUniverzális Kulcs: \y%d \wdarab.\d~\y]", Kulcsaim[id][0]);		
			menu_additem(Menu, String, "-1");
			Van = 1;
		}
		for(new i = 1;i <= LadakSzama;i++){
			if(Kulcsaim[id][i] > 0){
				new NumToString[6];
				num_to_str(i, NumToString, 5);
				format(String, charsmax(String), "\y[\d~\w%s Kulcs: \y%d \wdarab.\d~\y]", SzerverLadakNevei[i], Kulcsaim[id][i]);		
				menu_additem(Menu, String, NumToString);
				Van = 1;
			}
		}
		if(Van == 0){
			format(String, charsmax(String), "\rJelenleg nincs egy darab kulcsod sem!", 0);		
			menu_additem(Menu, String, "100");
		}
	}else if(folyamat == 1){
		for(new i = 1;i <= LadakSzama;i++){
			if(JatekosLadak[id][i] > 0){
				new NumToString[10];
				format(NumToString, charsmax(NumToString), "%d", i);		
				format(String, charsmax(String), "\y[\d~\w%s Láda: \y%d \wdarab.\d~\y]", SzerverLadakNevei[i], JatekosLadak[id][i]);		
				menu_additem(Menu, String, NumToString);
				Van = 1;
			}
		}
		if(Van == 0){
			format(String, charsmax(String), "\rJelenleg nincs egy darab ládád sem!", 0);		
			menu_additem(Menu, String, "101");
		}
	}else if(folyamat == 2){
	}
	
	menu_setprop(Menu, MPROP_PERPAGE, 5);
	menu_setprop(Menu, MPROP_NEXTNAME, "Tovább");
	menu_setprop(Menu, MPROP_BACKNAME, "Vissza");
	menu_setprop(Menu, MPROP_EXITNAME, "Kilépés");
	
	menu_setprop(Menu, MPROP_EXITNAME, "Kilépés");
	menu_display(id, Menu);
}

public KulcsaimMenuh(id, Menu, Item){
	if(Item == MENU_EXIT){
		menu_destroy(Menu);
		return;
	}
	
	new Data[20], Line[32];
	new Access, Callback;
	menu_item_getinfo(Menu, Item, Access, Data, charsmax(Data), Line, charsmax(Line), Callback);
	
	new x = str_to_num(Data);
	
	if(x == -1){
		KulcsaimMenu(id, 1, Item/6);
		return;
	}
	
	if(x == 100){
		chat(0, id, 0, "!nNincs egy kulcsod sem!");
		FoMenu(id);
		return;
	}
	if(x == 101){
		chat(0, id, 0, "!nNincs egy ládád sem!");
		FoMenu(id);
		return;
	}
	if(x != 0){
		if(JatekosLadak[id][x] != 0){
			LadaNyitas2(id, x, 0);
		}else{
			chat(0, id, 0, "!nNincs elég ládád ahhoz hogy használd ezt a kulcsot!");
		}
	}
	
	if(containi(Data, "a") != -1){
		replace_all(Data, 20, "a", "");
		LadaNyitas2(id, str_to_num(Data), 1);
		KulcsaimMenu(id, 1, Item/6);
		return;
	}
	KulcsaimMenu(id, 0, Item/6);
}

public LadaNyitas(id, folyamat, Oldal){
	new String[500];
	format(String, charsmax(String), "\r%s \wLádák", MenuPrefix);
	new Menu = menu_create(String, "LadaNyitash");
	new Van = 0;
	if(folyamat == 0){
		for(new i = 1;i <= LadakSzama;i++){
			if(JatekosLadak[id][i] > 0){
				new NumToString[6];
				num_to_str(i, NumToString, 5);
				format(String, charsmax(String), "\y[\d~\w%s Láda: \y%d \wdarab.\d~\y]", SzerverLadakNevei[i], JatekosLadak[id][i]);		
				menu_additem(Menu, String, NumToString);
				Van = 1;
			}
		}
		if(Van == 0){
			format(String, charsmax(String), "\rJelenleg nincs egy darab ládád sem!", 0);		
			menu_additem(Menu, String, "100");
		}
	}else if(folyamat == 1){
		for(new i = 1;i <= LadakSzama;i++){
			if(JatekosLadak[id][i] > 0){
				new NumToString[10];
				format(NumToString, charsmax(NumToString), "a%d", i);		
				format(String, charsmax(String), "\y[\d~\w%s Láda: \y%d \wdarab.\d~\y]", SzerverLadakNevei[i], JatekosLadak[id][i]);		
				menu_additem(Menu, String, NumToString);
				Van = 1;
			}
		}
		if(Van == 0){
			format(String, charsmax(String), "\rJelenleg nincs egy darab ládád sem!", 0);		
			menu_additem(Menu, String, "101");
		}
	}else if(folyamat == 2){
		for(new i = 1;i <= LadakSzama;i++){
			if(JatekosLadak[id][i] > 0){
				new NumToString[10];
				format(NumToString, charsmax(NumToString), "b%d", i);		
				format(String, charsmax(String), "\y[\d~\w%s Láda: \y%d \wdarab.\d~\y]", SzerverLadakNevei[i], JatekosLadak[id][i]);		
				menu_additem(Menu, String, NumToString);
				Van = 1;
			}
		}
		if(Van == 0){
			format(String, charsmax(String), "\rJelenleg nincs egy darab ládád sem!", 0);		
			menu_additem(Menu, String, "102");
		}
	}
	
	menu_setprop(Menu, MPROP_PERPAGE, 5);
	menu_setprop(Menu, MPROP_NEXTNAME, "Tovább");
	menu_setprop(Menu, MPROP_BACKNAME, "Vissza");
	menu_setprop(Menu, MPROP_EXITNAME, "Kilépés");
	menu_display(id, Menu, Oldal);
}

public LadaNyitash(id, Menu, Item){
	if(Item == MENU_EXIT){
		menu_destroy(Menu);
		return;
	}
	
	new Data[14], Line[32];
	new Access, Callback;
	menu_item_getinfo(Menu, Item, Access, Data, charsmax(Data), Line, charsmax(Line), Callback);
	
	new x = str_to_num(Data);
	if(x == 101){
		chat(0, id, 0, "!nNincs egy ládád sem!");
		Csere(id, 0);
		return;
	}
	if(x == 102){
		chat(0, id, 0, "!nNincs egy ládád sem!");
		Piac(id, 1);
		return;
	}
	if(x == 100){
		chat(0, id, 0, "!nNincs egy ládád sem!");
		FoMenu(id);
		return;
	}
	if(containi(Data, "b") != -1){
		replace_all(Data, 20, "b", "");
		new x = str_to_num(Data);
		PiacJatekos[id][0] = 2;
		PiacJatekos[id][1] = x;
		PiacJatekos[id][2] = 0;
		client_cmd(id, "messagemode PiacLada");
		return;
	}else if(containi(Data, "a") != -1){
		replace_all(Data, 20, "a", "");
		new x = str_to_num(Data);
		Cserekereskedem[id][3] = x;
		Cserekereskedem[id][4] = 0;
		client_cmd(id, "messagemode CsereLada");
		return;
	}else if(x != 0){
		if(Kulcsaim[id][x] != 0 || Kulcsaim[id][0]){
			LadaNyitas2(id, x, 0);
		}else{
			chat(0, id, 0, "!nNincs elég kulcsod ahhoz hogy kinyisd ezt a ládát!");
		}
	}
	LadaNyitas(id, 0, Item/7);
}

public LadaVasarlas(id, Oldal){
	new String[500];
	format(String, charsmax(String), "\r%s \wVásárlás!", MenuPrefix);
	new Menu = menu_create(String, "LadaVasarlash");
	new Van = 0;
	if(!equal(SzerverKulcs, "")){
		format(String, charsmax(String), "\y[\d~\w1 darab %s \yÁra: \r%.2f \w$. \r(\y%.2f%\r)\d~\y]", SzerverKulcs, SzerverKulcsAra+0.000001, SzerverLadakKulcsEselyek[0]);		
		menu_additem(Menu, String, "Kulcs");
		for(new i = 1;i <= LadakSzama;i++){
			if(SzerverLadakArai[i] > 0.0){			
				new NumToString[6];
				num_to_str(i, NumToString, 5);
				format(String, charsmax(String), "\y[\d~\w1 darab %s Láda \yÁra: \r%.2f \w$. \r(\y%.2f%\r)\d~\y]", SzerverLadakNevei[i], SzerverLadakArai[i]+0.000001, SzerverLadakEselyek[i]);		
				menu_additem(Menu, String, NumToString);
				Van++;
			}
		}
	}
	if(Van == 0){
		format(String, charsmax(String), "\rJelenleg nincs egy darab ládád sem!", 0);		
		menu_additem(Menu, String, "100");
	}
	
	menu_setprop(Menu, MPROP_PERPAGE, 5);
	menu_setprop(Menu, MPROP_NEXTNAME, "Tovább");
	menu_setprop(Menu, MPROP_BACKNAME, "Vissza");
	menu_setprop(Menu, MPROP_EXITNAME, "Kilépés");
	menu_display(id, Menu, Oldal);
}

public LadaVasarlash(id, Menu, Item){
	if(Item == MENU_EXIT){
		menu_destroy(Menu);
		return;
	}
	
	new Data[14], Line[32];
	new Access, Callback;
	menu_item_getinfo(Menu, Item, Access, Data, charsmax(Data), Line, charsmax(Line), Callback);
	if(equal(Data, "Kulcs")){
		if(Penz[id] >= SzerverKulcsAra){
			Penz[id] -= SzerverKulcsAra;
			Kulcsaim[id][0]++;
			chat(0, 0, 0, "!t%s !nVett egy !t%s !na boltból! !gÁra: !t%.2f!n!", NEV[id], SzerverKulcs, SzerverKulcsAra);
		}else{
			chat(0, id, 0, "Nincs elég pénzed hogy vegyél egy !g%s!n!", SzerverKulcs);
		}
	}else{
		new x = str_to_num(Data);
		if(x != 0){
			if(Penz[id] >= SzerverLadakArai[x]){
				Penz[id] -= SzerverLadakArai[x];
				JatekosLadak[id][x]++;
				chat(0, 0, 0, "!t%s !nVett egy !t%s !nládát a boltból! !gÁra: !t%.2f!n!", NEV[id], SzerverLadakNevei[x], SzerverLadakArai[x]);
			}else{
				chat(0, id, 0, "Nincs elég pénzed hogy vegyél egy !g%s !nládát!", SzerverLadakNevei[x]);
			}
		}
	}
	
	LadaVasarlas(id, Item/7);
}

public LadaNyitas2(id, Lada, Unviresal){
	new Skin = LadakCuccok[Lada][random_num(1, LadakCuccokSzama[Lada])];
	JatekosFegyverOsszes[id][ModelFegyverTipus[Skin]]++;
	JatekosFegyo[id][Skin]++;
	JatekosLadak[id][Lada]--;
	if(Unviresal == 1){
		Kulcsaim[id][0]--;
	}else{
		if(Kulcsaim[id][Lada] != 0){
			Kulcsaim[id][Lada]--;
		}else{
			Kulcsaim[id][0]--;
		}
	}
	new Nev[100];
	copy(Nev, 100, NEV[id]);
	replace_all(Nev, 100, "%s", "");
	if(equal("", ModelNev[Skin])){
		chat(0, 0, 0, "!t%s !nHiba a következő skinel %d, a(z) !t%s !nládából!", Nev, Skin, SzerverLadakNevei[Lada]);
	}else{
		chat(0, 0, 0, "!t%s !nnyitott egy !t%s !nskint !t%s !nfegyverre, a(z) !t%s !nládából!", Nev, ModelNev[Skin], SkinFegyoNev[ModelFegyverTipus[Skin]], SzerverLadakNevei[Lada]);
	}
}
public plugin_precache(){
 
	new File[127];
	new linetext[255], linetextlength;
	new line = 0;
	new Model[300];
	new tart = 1;
	
	get_customdir(File, 127);
	format(File, 127, "%s/ModBeallitasok.ini", File);

	if (file_exists(File)){
		read_file(File, 1, linetext, 256, linetextlength);
		if(linetext[0] != ';'){
			new Adat[80], Adat2[10], Adat3[10], Adat4[10];
			parse(linetext, Adat, 39, SQL_Cim, 127, SQL_Felhasznalonev, 127, SQL_Jelszo, 127, SQL_Adatbazis, 127, ModelMappa, 256, AdminIP, 100, TablaNev, 60,  Adat2, 10, Adat3, 10, Adat4, 10);
			copy(Prefix, 80, Adat);
			replace_all(Adat, 40, "!g", "");
			replace_all(Adat, 40, "!n", "");
			replace_all(Adat, 40, "!t", "");
			MaxIP = str_to_num(Adat2);
			Resi = str_to_num(Adat3);
			Terfel = str_to_num(Adat4);
			
			copy(MenuPrefix, 40, Adat);
		}		
	}
	/*
	get_customdir(File, 127);
	format(File, 127, "%s/JatekosSkinek.ini", File);
	if (file_exists(File)){
		while ((line = read_file(File, line, linetext, 256, linetextlength))){
			if(linetext[0] != ';'){			
				parse(linetext, JatekosSkinek[tart], 300);
				format(Model, 100, "%s%s/%s.mdl", JatekosMappa, JatekosSkinek[tart], JatekosSkinek[tart]);
				precache_model(Model);
				tart++;
			}
		}
	}*/
	line = 0;
	tart = 0;
	
	get_customdir(File, 127);
	format(File, 127, "%s/Ladak.ini", File);
	if (file_exists(File)){
		while ((line = read_file(File, line, linetext, 256, linetextlength))){
			if(linetext[0] != ';'){			
				if(tart == 0){
					new Adat[300], Adat2[300];
					parse(linetext, SzerverKulcs, 300, Adat, 300, Adat2, 300);
					SzerverLadakKulcsEselyek[0] = str_to_float(Adat);
					SzerverKulcsAra = str_to_float(Adat2);
				}else{
					LadakSzama++;
					new Adat[300], Adat2[300], Adat3[300];
					parse(linetext, SzerverLadakNevei[LadakSzama], 300, SzerverLadakIni[LadakSzama], 300, Adat, 300, Adat2, 300, Adat3, 300);
					new Float:Esely = str_to_float(Adat);
					if(Esely <= 0.0){
						Esely = 0.0;
						server_print("A %s láda esélye kisebb vagy egyenlő 0 val!", SzerverLadakNevei[LadakSzama]);
					}
					new Float:KulcsEsely = str_to_float(Adat3);
					if(KulcsEsely <= 0.0){
						Esely = 0.0;
						server_print("A %s láda kulcsának az esélye kisebb vagy egyenlő 0 val!", SzerverLadakNevei[LadakSzama]);
					}
					SzerverLadakKulcsEselyek[LadakSzama] = KulcsEsely;
					SzerverLadakEselyek[LadakSzama] = Esely;
					if(equali(Adat2, "vip")){						
						SzerverLadakArai[LadakSzama] = -1.0;
					}else{
						SzerverLadakArai[LadakSzama] = str_to_float(Adat2);
					}
				}
				tart++;
			}
		}
		line = 0;
		tart = 1;
	}
	
	line = 0;
	tart = 0;
	
	get_customdir(File, 127);
	format(File, 127, "%s/Rangok.ini", File);
	if (file_exists(File)){
		while ((line = read_file(File, line, linetext, 256, linetextlength))){
			if(linetext[0] != ';'){		
				new Adat[300], Adat2[300];
				parse(linetext, Adat, 300, Adat2, 300);
				new Szam[10];
				format(Szam, 10, "%d", RangokSzama+1);
				replace_all(Adat, 300, "%%Sorszám%%", Szam);
				format(RangNevek[tart], 23, "%s", Adat);
				RangOlesek[tart] = str_to_num(Adat2);
				RangokSzama++;
				tart++;
			}
		}
		line = 0;
		tart = 1;
	}
	
	line = 0;
	tart = 1;
	
	get_customdir(File, 127);
	format(File, 127, "%s/Mapok.ini", File);
	if (file_exists(File)){
		while ((line = read_file(File, line, linetext, 256, linetextlength))){
			if(linetext[0] != ';'){	
				parse(linetext, SzerverMapok[tart], 31);
				SzerverMapokSzama++;
				tart++;
			}
		}
	}
	for(new i = 1;i <= LadakSzama;i++){
		line = 0;
		tart = 1;
		get_customdir(File, 127);
		format(File, 127, "%s/%s.ini", File, SzerverLadakIni[i]);
		if (file_exists(File)){
			while ((line = read_file(File, line, linetext, 256, linetextlength))){
				if(linetext[0] != ';'){			
					new Adat[300];
					parse(linetext, Adat, 300);
					LadakCuccok[i][tart] = str_to_num(Adat);
					LadakCuccokSzama[i]++;
					tart++;
				}
			}		
		}
	}
	
	tart = 1;
	line = 0;

	get_customdir(File, 127);
	format(File, 127, "%s/FegyverSkinek.ini", File);
	if (file_exists(File)){
		new SorrendSzam = 1, SorrendTemp[32];
		while ((line = read_file(File, line, linetext, 256, linetextlength))){
			if(linetext[0] != ';'){			
				new Adat1[300], Adat2[300], Adat3[300];
				parse(linetext, Adat3, 300, Adat1, 300, Adat2, 300);
				replace_all(Adat3, 300, "%s", Adat1);
				format(ModelEleresiUt[tart], 100, "%s", Adat3);
				format(Model, 300, "%s%s", ModelMappa, ModelEleresiUt[tart]);
				precache_model(Model);
				replace_all(Adat1, 300, "__", "'");
				replace_all(Adat1, 300, "_", " ");
				format(ModelNev[tart], 100, "%s", Adat1);
				ModelFegyverTipus[tart] = str_to_num(Adat2);
				FegyokSzama[ModelFegyverTipus[tart]]++;
				Fegyok[ModelFegyverTipus[tart]][FegyokSzama[ModelFegyverTipus[tart]]] = tart;
				if(Sorred[SorrendSzam] == 0 && SorrendTemp[str_to_num(Adat2)] == 0){
					SorrendTemp[str_to_num(Adat2)] = 1;
					Sorred[SorrendSzam] = str_to_num(Adat2);
					SorrendSzam++;
				}
				tart++;
			}
		}
	}
	
	tart = 0;
	line = 0;
	
	get_customdir(File, 127);
	format(File, 127, "%s/Hirdetesek.ini", File);
	if (file_exists(File)){
		new Float:Ido = 0.0;
		while ((line = read_file(File, line, linetext, 256, linetextlength))){
			if(linetext[0] != ';'){		
				if(tart == 0){
					new Adat[300];
					parse(linetext, Adat, 300);
					Ido = str_to_float(Adat);
					tart++;
				}else{
					HirdetesekSzam++;
					parse(linetext, Hirdetesek[HirdetesekSzam], 1024);
				}
			}
		}
		set_task(Ido, "HirdetesekKiiras", 32412, "", 0, "b");
	}
	
	tart = 0;
	line = 0;

	get_customdir(File, 127);
	format(File, 127, "%s/Fragverseny.ini", File);
	if (file_exists(File)){
		while ((line = read_file(File, line, linetext, 256, linetextlength))){
			if(linetext[0] != ';'){		
				new top1min[30], top1max[30], top2min[30], top2max[30], top3min[30], top3max[30];
				parse(linetext, top1min, 30, top1max, 30, top2min, 30, top2max, 30, top3min, 30, top3max, 30);
				TOP1MIN = str_to_float(top1min);
				TOP1MAX = str_to_float(top1max);
				TOP2MIN = str_to_float(top2min);
				TOP2MAX = str_to_float(top2max);
				TOP3MIN = str_to_float(top3min);
				TOP3MAX = str_to_float(top3max);
			}
		}
	}
	
	format(File, 127, "%s%s", ModelMappa, AUG_SCOPE);
	if (file_exists(File)){
		format(Model, 100, "%s%s", ModelMappa, AUG_SCOPE);
		precache_model(Model);
	}
	/*
	format(Model, 100, "%sHerBoy_T08/HerBoy_T08.mdl", JatekosMappa);
	precache_model(Model);
	*/
	format(Model, 100, "%sHerBoy_Admin_T/HerBoy_Admin_T.mdl", JatekosMappa);
	precache_model(Model);
	/*
	format(Model, 100, "%sHerBoy_CT08/HerBoy_CT08.mdl", JatekosMappa);
	precache_model(Model);
	*/
	format(Model, 100, "%sHerB0y_Admin_CT/HerB0y_Admin_CT.mdl", JatekosMappa);
	precache_model(Model);

	format(Model, 100, "%sHerboy_Vip_CT/HerBoy_Vip_CT.mdl", JatekosMappa);
	precache_model(Model);

	format(Model, 100, "%sHerboy_Vip_T/HerBoy_Vip_T.mdl", JatekosMappa);
	precache_model(Model);
	
	format(Model, 100, "HerBoy/rs.wav");
	precache_sound(Model);
}

public HirdetesekKiiras(){
	chat(0, 0, 0, "%s", Hirdetesek[HirdetesTart]);
	HirdetesTart++;
	if(HirdetesTart > HirdetesekSzam){
		HirdetesTart = 1;
	}
}

public plugin_cfg(){
	    SQL_SetAffinity("mysql");
SQLTuple = SQL_MakeDbTuple(SQL_Cim, SQL_Felhasznalonev, SQL_Jelszo, SQL_Adatbazis);
    SQL_SetCharset(SQLTuple, "utf8");
	

	static String[20106];
	new Len;
	
	Len += format(String[Len], charsmax(String), "CREATE TABLE IF NOT EXISTS %s (ID int(20) AUTO_INCREMENT, STEAMID VARCHAR(32), IP VARCHAR(32), Nev VARCHAR(50), Jelszo VARCHAR(40), Prefix VARCHAR(32), ModJogok VARCHAR(32), Jogok VARCHAR(32), Penz float(20) NOT NULL, Bekelllepni int(1) NOT NULL", TablaNev);
	Len += format(String[Len], charsmax(String)-Len, ", Masodpercek int(11) NOT NULL, Vip int(1) NOT NULL, Ejtoernyo int(1) NOT NULL, KillFade int(1) NOT NULL, HUD int(1) NOT NULL, Rang int(10) NOT NULL, Sebzeskijelzo int(1) NOT NULL");
	Len += format(String[Len], charsmax(String)-Len, ", FegyverSkin1 int(4) NOT NULL, FegyverSkin2 int(4) NOT NULL, FegyverSkin3 int(4) NOT NULL, FegyverSkin4 int(4) NOT NULL, FegyverSkin5 int(4) NOT NULL, FegyverSkin6 int(4) NOT NULL, FegyverSkin7 int(4) NOT NULL");
	Len += format(String[Len], charsmax(String)-Len, ", FegyverSkin8 int(4) NOT NULL, FegyverSkin9 int(4) NOT NULL, FegyverSkin10 int(4) NOT NULL, FegyverSkin11 int(4) NOT NULL, FegyverSkin12 int(4) NOT NULL, FegyverSkin13 int(4) NOT NULL, FegyverSkin14 int(4) NOT NULL");
	Len += format(String[Len], charsmax(String)-Len, ", LadaKulcs int(10) NOT NULL, Kinezetek int(1) NOT NULL, Duplaugras int(1) NOT NULL, Olesek int(20) NOT NULL, Admin int(1) NOT NULL, SzuperAdmin int(1) NOT NULL, AdminElrejt int(1) NOT NULL, PottyiPont int(20) NOT NULL, HalalUF int(1) NOT NULL");
	for(new i = 1;i <= LadakSzama;i++){
		Len += format(String[Len], charsmax(String)-Len, ", Lada%d int(10) NOT NULL", i);	
		Len += format(String[Len], charsmax(String)-Len, ", Lada%dKulcs int(10) NOT NULL", i);	
	}
	for(new a = 1;a < 31;a++){
		for(new b = 1;b <= FegyokSzama[a];b++){
			Len += format(String[Len], charsmax(String)-Len, ", M%d int(10) NOT NULL", Fegyok[a][b]);
		}
	}
	Len += format(String[Len], charsmax(String)-Len, ", PRIMARY KEY (ID), INDEX (STEAMID, IP, Nev)) AUTO_INCREMENT=1 CHARACTER SET utf8 COLLATE utf8_general_ci;");
	
	Len += format(String[Len], charsmax(String)-Len, "CREATE TABLE IF NOT EXISTS %sNemitas (ID int(20) AUTO_INCREMENT, STEAMID VARCHAR(32), IP VARCHAR(32), Nemito VARCHAR(32), Indok VARCHAR(120), Lejarat int(20) NOT NULL", TablaNev);
	Len += format(String[Len], charsmax(String)-Len, ", PRIMARY KEY (ID), INDEX (SteamID, IP)) AUTO_INCREMENT=1 CHARACTER SET utf8 COLLATE utf8_general_ci;");
	
	Len += format(String[Len], charsmax(String)-Len, "CREATE TABLE IF NOT EXISTS %sKitiltas (ID int(20) AUTO_INCREMENT, STEAMID VARCHAR(32), IP VARCHAR(32), Tilto VARCHAR(32), Indok VARCHAR(120), Lejarat int(20) NOT NULL", TablaNev);
	Len += format(String[Len], charsmax(String)-Len, ", PRIMARY KEY (ID), INDEX (SteamID, IP)) AUTO_INCREMENT=1 CHARACTER SET utf8 COLLATE utf8_general_ci;");
	
	Len += format(String[Len], charsmax(String)-Len, "CREATE TABLE IF NOT EXISTS %sPiac (ID int(20) AUTO_INCREMENT, SteamID VARCHAR(32), Nev VARCHAR(32), Tipus int(1) NOT NULL, Targy int(3) NOT NULL, Mennyiseg int(20), Ar float(20), Lejarat int(20) NOT NULL", TablaNev);
	Len += format(String[Len], charsmax(String)-Len, ", PRIMARY KEY (ID), INDEX (SteamID)) AUTO_INCREMENT=1 CHARACTER SET utf8 COLLATE utf8_general_ci;");
	
	new Data[2];
	Data[0] = 0;
	
	SQL_ThreadQuery(SQLTuple, "QuerySetData", String, Data, 2);
	
	PiacBetoltes(0);
	
	new File[127];
	get_customdir(File, 127);
	format(File, 127, "%s/FragLesz.ini", File);
	
	if(file_exists(File)){
		FragVan = 1;
		delete_file(File);	
	}
	
	return PLUGIN_CONTINUE;
}

public plugin_end(){
	SQL_FreeHandle(SQLTuple);
}

public PlayerCsatlakozas(id){
	new Data[1];
	Data[0] = id;
	new query[1024];
	format(query, charsmax(query), "SELECT `STEAMID` FROM `%s` WHERE `Nev` = ^"%s^"", TablaNev, NEV[id]);
	SQL_ThreadQuery(SQLTuple,"PlayerCsatlakozasq", query, Data, 1);
}

public PlayerCsatlakozasq(FailState, Handle:Query, Error[], Errcode, Data[], DataSize) {
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) {
		log_amx("%s", Error);
		return;
	}else {
		new id = Data[0];
		
		if(SQL_NumRows(Query) > 0){
			new SteamID[40];
			SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "STEAMID"), SteamID, charsmax(SteamID));
			if(!equali(STEAMID[id], SteamID)){
				server_cmd("kick #%d ^"Ez a név már használatban van, válts nevet!^"", get_user_userid(id));
				return;
			}
		}
		PlayerCsatlakozas2(id);
	} 
}
public PiacLejar(SteamID[]){
	new Adat[PiacAdatok];
	TrieGetArray(PiacCuccok, SteamID, Adat, sizeof Adat);
	
	TrieDeleteKey(PiacCuccok, SteamID);
	TrieDeleteKey(PiacCuccokID, SteamID[containi(SteamID, "steam_")]);
	new c = ArrayFindString(PiacCuccokSteamID, SteamID);
	ArrayDeleteItem(PiacCuccokSteamID, c);
	new Data[1];
	Data[0] = 0;
	new query[1024];
	new id = find_player("c", SteamID[containi(SteamID, "steam_")]);
	new Nev[50];
	if(Adat[P_Tipus] == 1){
		if(id != 0){
			JatekosFegyo[id][Adat[P_Targy]] += Adat[P_Mennyiseg];
			JatekosFegyverOsszes[id][ModelFegyverTipus[Adat[P_Targy]]] += Adat[P_Mennyiseg];
			format(Nev, charsmax(Nev), "%s", NEV[id]);
			format(query, charsmax(query), "DELETE FROM `%sPiac` WHERE SteamID = ^"%s^";", TablaNev, SteamID[containi(SteamID, "steam_")]);
		}else{
			format(Nev, charsmax(Nev), "%s", Adat[P_Nev]);
			format(query, charsmax(query), "UPDATE `%s` SET M%d = M%d+%d WHERE `STEAMID` = ^"%s^";DELETE FROM `%sPiac` WHERE SteamID = ^"%s^";", TablaNev, Adat[P_Targy], Adat[P_Targy], Adat[P_Mennyiseg], SteamID[containi(SteamID, "steam_")], TablaNev, SteamID[containi(SteamID, "steam_")]);
		}
		chat(0, 0, 0, "!g%s !nvisszakapott !t%d !ndarab !t%s !g%s !nládát a piacból, mivel lejárt az idő!", Nev, Adat[P_Mennyiseg], ModelNev[Adat[P_Targy]], SkinFegyoNev[ModelFegyverTipus[Adat[P_Targy]]]);
	}else if(Adat[P_Tipus] == 2){
		if(id != 0){			
			JatekosLadak[id][Adat[P_Targy]] += Adat[P_Mennyiseg];
			format(Nev, charsmax(Nev), "%s", NEV[id]);
			format(query, charsmax(query), "DELETE FROM `%sPiac` WHERE SteamID = ^"%s^";", TablaNev, SteamID[containi(SteamID, "steam_")]);
		}else{
			format(Nev, charsmax(Nev), "%s", Adat[P_Nev]);
			format(query, charsmax(query), "UPDATE `%s` SET Lada%d = Lada%d+%d WHERE `STEAMID` = ^"%s^";DELETE FROM `%sPiac` WHERE SteamID = ^"%s^";", TablaNev, Adat[P_Targy], Adat[P_Targy], Adat[P_Mennyiseg], SteamID[containi(SteamID, "steam_")], TablaNev, SteamID[containi(SteamID, "steam_")]);
		}
		chat(0, 0, 0, "!g%s !nvisszakapott !t%d !ndarab !t%s !nládát a piacból, mivel lejárt az idő!", Nev, Adat[P_Mennyiseg], SzerverLadakNevei[Adat[P_Targy]]);
	}else if(Adat[P_Tipus] == 3){
		if(id != 0){			
			Kulcsaim[id][0] += Adat[P_Mennyiseg];
			format(Nev, charsmax(Nev), "%s", NEV[id]);
			format(query, charsmax(query), "DELETE FROM `%sPiac` WHERE SteamID = ^"%s^";", TablaNev, SteamID[containi(SteamID, "steam_")]);
		}else{
			format(Nev, charsmax(Nev), "%s", Adat[P_Nev]);
			format(query, charsmax(query), "UPDATE `%s` SET LadaKulcs = LadaKulcs+%d WHERE `STEAMID` = ^"%s^";DELETE FROM `%sPiac` WHERE SteamID = ^"%s^";", TablaNev, Adat[P_Mennyiseg], SteamID[containi(SteamID, "steam_")], TablaNev, SteamID[containi(SteamID, "steam_")]);
		}
		chat(0, 0, 0, "!g%s !nvisszakapott !t%d !ndarab !gkulcsot !na piacból, mivel lejárt az idő!", Nev, Adat[P_Mennyiseg]);
	}
	SQL_ThreadQuery(SQLTuple,"QuerySetData", query, Data, 1);
}

public PiacVasarlas(SteamID[], Float:Ar){
	new Data[1];
	Data[0] = 0;
	new query[1024];
	format(query, charsmax(query), "UPDATE `%s` SET Penz = Penz+%f WHERE `STEAMID` = ^"%s^";DELETE FROM `%sPiac` WHERE SteamID = ^"%s^";", TablaNev, Ar, SteamID, TablaNev, SteamID);
	SQL_ThreadQuery(SQLTuple,"QuerySetData", query, Data, 1);
}

public PiacBetoltes(Offset){
	new Data[1];
	Data[0] = Offset+100;
	new query[1024];
	format(query, charsmax(query), "SELECT * FROM `%sPiac` LIMIT 100 OFFSET %d", TablaNev, Offset);
	SQL_ThreadQuery(SQLTuple,"PiacBetoltesq", query, Data, 1);
}

public PiacBetoltesq(FailState, Handle:Query, Error[], Errcode, Data[], DataSize) {
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) {
		log_amx("%s", Error);
		return;
	}else {
		new off = Data[0];
		
		if(SQL_NumRows(Query) > 0){
			while (SQL_MoreResults(Query)){
				new Tipus, Lejarat, Targy, SteamID[60], Ar[30], Mennyiseg;
				static Adat[PiacAdatok];
				
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "SteamID"), SteamID, charsmax(SteamID));
				format(SteamID, charsmax(SteamID), "%d%s", get_systime(), SteamID);
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Ar"), Ar, charsmax(Ar));
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Nev"), Adat[P_Nev], sizeof(Adat[P_Nev])-1);
				Mennyiseg = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Mennyiseg"));
				Tipus = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Tipus"));
				Lejarat = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Lejarat"));
				Targy = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Targy"));
				
				Adat[P_Tipus] = Tipus;
				Adat[P_Targy] = Targy;
				Adat[P_Mennyiseg] = Mennyiseg;
				Adat[P_Ido] = Lejarat;
				Adat[P_ID] = JELENLEGIID;
				copy(Adat[P_Ar], sizeof(Adat[P_Ar])-1, Ar);
				
				ArrayPushString(PiacCuccokSteamID, SteamID);
				new Float:Ido = float(Lejarat-get_systime());
				
				if(Ido < 0){
					Ido = 2.0;
				}
				set_task(Ido, "PiacLejar", JELENLEGIID, SteamID, charsmax(SteamID));
				
				JELENLEGIID++;
				
				TrieSetCell(PiacCuccokID, SteamID[containi(SteamID, "steam_")], 0);
				TrieSetArray(PiacCuccok, SteamID, Adat, sizeof Adat);
				SQL_NextRow(Query);
			}
			PiacBetoltes(off);
		}
	} 
}

public PlayerCsatlakozas2(id){
	new Data[1];
	Data[0] = id;
	new query[1024];
	format(query, charsmax(query), "SELECT `STEAMID` FROM `%s` WHERE `IP` = ^"%s^"", TablaNev, IP[id]);
	SQL_ThreadQuery(SQLTuple,"PlayerCsatlakozas2q", query, Data, 1);
}

public PlayerCsatlakozas2q(FailState, Handle:Query, Error[], Errcode, Data[], DataSize) {
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) {
		log_amx("%s", Error);
		return;
	}else {
		new id = Data[0];
		
		new IpSzam, SteamID;
		if(SQL_NumRows(Query) > 0){
			while (SQL_MoreResults(Query)){
				new ID[40];
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "STEAMID"), ID, charsmax(ID));
				if(equal(ID, STEAMID[id])){
					SteamID++;
				}
				IpSzam++;
				SQL_NextRow(Query);
			}
			if(SteamID == 0 && IpSzam > MaxIP){
				server_cmd("kick #%d ^"A szerverre egy ipcímről maximum %d karakterrel jöhetsz fel!^"", get_user_userid(id), MaxIP);
				return;
			}
		}
		PlayerEllenorzes(id);
	} 
}

public PlayerEllenorzes(id){
	new Data[1];
	Data[0] = id;
	new query[300];
	format(query, charsmax(query), "SELECT `Admin`, `SzuperAdmin`, `ModJogok`, `Bekelllepni`, `Jelszo`, `AdminElrejt`, `Jogok` FROM `%s` WHERE `STEAMID` = ^"%s^"", TablaNev, STEAMID[id]);
	SQL_ThreadQuery(SQLTuple,"PlayerEllenorzesq", query, Data, 1);
}

public PlayerEllenorzesq(FailState, Handle:Query, Error[], Errcode, Data[], DataSize) {
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) {
		log_amx("%s", Error);
		return;
	}else {
		new id = Data[0];
																																 
		if(SQL_NumRows(Query) > 0){
			if(equal(AdminIP, IP[id])){
				Adminvagy[id] = 1;
				Bekelllepni[id] = 1;
				SzuperAdmin[id] = 1;
			}else{
				Adminvagy[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Admin"));
				Bekelllepni[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Bekelllepni"));
				SzuperAdmin[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "SzuperAdmin"));
			}
			if(Adminvagy[id] == 1 || SzuperAdmin[id] == 1){
				if(Bekelllepni[id] == 0){				 
					Bekelllepni[id] = 1;
				}
				if(Adminvagy[id] == 0){				 
					Adminvagy[id] = 1;
				}
				AdminElrejt[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "AdminElrejt"));
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "ModJogok"), ModJogok[id], 100);
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Jogok"), Jogok[id], 100);
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Jelszo"), JelszoSQL[id], charsmax(JelszoSQL));
			}else if(Bekelllepni[id] == 1){
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Jelszo"), JelszoSQL[id], charsmax(JelszoSQL));	
			}else{
				PlayerBetoltes(id);
			}
		}else{
			new SQL[1024];
			if(equal(AdminIP, IP[id])){
				format(SQL, charsmax(SQL), "INSERT INTO `%s` (`STEAMID`, `Jelszo`, `Prefix`, `Jogok`, `ModJogok`, `Admin`, `Bekelllepni`, `Nev`, `IP`, `SzuperAdmin`) VALUES (^"%s^", ^"^", ^"Tulajdonos^", ^"^", ^"^", 1, 1, ^"%s^", ^"%s^", ^"1^");", TablaNev, STEAMID[id], NEV[id], IP[id]);
				Adminvagy[id] = 1;
				SzuperAdmin[id] = 1;
				Bekelllepni[id] = 1;
			}else{
				format(SQL, charsmax(SQL), "INSERT INTO `%s` (`STEAMID`, `Jelszo`, `Prefix`, `Jogok`, `ModJogok`, `Nev`, `IP`) VALUES (^"%s^", ^"^", ^"Játékos^", ^"^", ^"^", ^"%s^", ^"%s^");", TablaNev, STEAMID[id], NEV[id], IP[id]);
			}
			Felcsatlakozasido[id] = get_systime();
			new Data[2];
			Data[0] = id;
			Data[1] = 1;
			SQL_ThreadQuery(SQLTuple, "QuerySetData", SQL, Data,2 );
		}
	} 
}

public PlayerKitiltasEllenorzes(id){
	new Data[1];
	Data[0] = id;
	new query[300];
	format(query, charsmax(query), "SELECT * FROM `%sKitiltas` WHERE `STEAMID` = ^"%s^" OR `IP` = ^"%s^"", TablaNev, STEAMID[id], IP[id]);
	SQL_ThreadQuery(SQLTuple,"PlayerKitiltasEllenorzesq", query, Data, 1);
}

public PlayerKitiltasEllenorzesq(FailState, Handle:Query, Error[], Errcode, Data[], DataSize) {
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) {
		log_amx("%s", Error);
		return;
	}else {
		new id = Data[0], Tovabb;				
		if(SQL_NumRows(Query) > 0){
			new SteamID[40], Ip[40], Indok1[120], Indok2[120], Tilto1[100], Tilto2[100], Lejar1, Lejar2;
			while (SQL_MoreResults(Query)){
				new SteamID2[100], Ip2[100];
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "STEAMID"), SteamID2, 100);
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "IP"), Ip2, 100);
				if(equal(SteamID2, "")){
					format(Ip, 40, "%s", Ip2);
					Lejar2 = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Lejarat"));
					SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Tilto"), Tilto2, 100);
					SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Indok"), Indok2, 120);
				}else{
					format(SteamID, 40, "%s", SteamID2);
					Lejar1 = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Lejarat"));
					SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Tilto"), Tilto1, 100);
					SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Indok"), Indok1, 120);
				}
				SQL_NextRow(Query);
			}
			new IpFeloldas, IDFeloldas;
			if(!equal(Ip, "")){
				if(Lejar2 < 1){
					client_cmd(id, "echo ------- Ki lettél tiltva a szerverről! ( ban ) --------");
					client_cmd(id, "echo Név: %s", NEV[id]);
					client_cmd(id, "echo IpCím: %s", Ip);
					client_cmd(id, "echo Kitiltó: %s", Tilto2);
					client_cmd(id, "echo Indok: %s", Indok2);
					client_cmd(id, "echo Lejárat: Soha");
					client_cmd(id, "echo Unbankérelemért rakd ki a ban infót, és a demódat a facebook csoportunkba!");
					client_cmd(id, "echo https://www.facebook.com/groups/196538444338821/");
					client_cmd(id, "echo --------------------------------------------------------");
					new Adatok[1];
					Adatok[0] = id;
					set_task(0.6, "KitiltasKirugas2", 66248, Adatok, 1);
					Tovabb++;
				}else{
					Lejar2 = Lejar2-get_systime();
					if(Lejar2 > 0){
						new LejarSzoveg[200];
						new Nap = Lejar2 / (24 * 3600);
						if(Nap > 0){
							format(LejarSzoveg, 200, "%d Nap", Nap);
						}
						new Ora = (Lejar2 - Nap * 86400)/3600;
						if(Ora > 0){
							format(LejarSzoveg, 200, "%s %d Óra", LejarSzoveg, Ora);
						}
						new Perc = (Lejar2 - Nap * 86400 - Ora * 3600)/60;
						if(Perc > 0){
							format(LejarSzoveg, 200, "%s %d Perc", LejarSzoveg, Perc);
						}
						new MP = (Lejar2 - Nap * 86400 - Ora * 3600 - Perc * 60);
						if(MP > 0){
							format(LejarSzoveg, 200, "%s %d Másodperc", LejarSzoveg, MP);
						}
						
						client_cmd(id, "echo ------- Ki lettél tiltva a szerverről! ( ban ) --------");
						client_cmd(id, "echo Név: %s", NEV[id]);
						client_cmd(id, "echo IpCím: %s", Ip);
						client_cmd(id, "echo Kitiltó: %s", Tilto2);
						client_cmd(id, "echo Indok: %s", Indok2);
						client_cmd(id, "echo Lejárat: %s", LejarSzoveg);
						client_cmd(id, "echo Unbankérelemért rakd ki a ban infót, és a demódat a facebook csoportunkba!");
						client_cmd(id, "echo https://www.facebook.com/groups/196538444338821/");
						client_cmd(id, "echo --------------------------------------------------------");
						new Adatok[1];
						Adatok[0] = id;
						set_task(0.6, "KitiltasKirugas2", 66248, Adatok, 1);
						Tovabb++;
					}else{
						IpFeloldas = 1;
					}
				}
			}
			if(!equal(SteamID, "")){
				if(Lejar1 < 1){
					client_cmd(id, "echo ------- Ki lettél tiltva a szerverről! ( ban ) --------");
					client_cmd(id, "echo Név: %s", NEV[id]);
					client_cmd(id, "echo SteamID: %s", SteamID);
					client_cmd(id, "echo Kitiltó: %s", Tilto1);
					client_cmd(id, "echo Indok: %s", Indok1);
					client_cmd(id, "echo Lejárat: Soha");
					client_cmd(id, "echo --------------------------------------------------------");
					new Adatok[1];
					Adatok[0] = id;
					set_task(0.6, "KitiltasKirugas2", 66248, Adatok, 1);
					Tovabb++;
				}else{					
					Lejar1 = Lejar1-get_systime();
					if(Lejar1 > 0){
						new LejarSzoveg[200];
						new Nap = Lejar1 / (24 * 3600);
						if(Nap > 0){
							format(LejarSzoveg, 200, "%d Nap", Nap);
						}
						new Ora = (Lejar1 - Nap * 86400)/3600;
						if(Ora > 0){
							format(LejarSzoveg, 200, "%s %d Óra", LejarSzoveg, Ora);
						}
						new Perc = (Lejar1 - Nap * 86400 - Ora * 3600)/60;
						if(Perc > 0){
							format(LejarSzoveg, 200, "%s %d Perc", LejarSzoveg, Perc);
						}
						new MP = (Lejar1 - Nap * 86400 - Ora * 3600 - Perc * 60);
						if(MP > 0){
							format(LejarSzoveg, 200, "%s %d Másodperc", LejarSzoveg, MP);
						}
						
						client_cmd(id, "echo ------- Ki lettél tiltva a szerverről! ( ban ) --------");
						client_cmd(id, "echo Név: %s", NEV[id]);
						client_cmd(id, "echo SteamID: %s", SteamID);
						client_cmd(id, "echo Kitiltó: %s", Tilto1);
						client_cmd(id, "echo Indok: %s", Indok1);
						client_cmd(id, "echo Lejárat: %s", LejarSzoveg);
						client_cmd(id, "echo --------------------------------------------------------");
						new Adatok[1];
						Adatok[0] = id;
						set_task(0.6, "KitiltasKirugas2", 66248, Adatok, 1);
						Tovabb++;
					}else{
						IDFeloldas = 1;
					}
				}
			}
			if(IDFeloldas == 1 && IpFeloldas == 1){
				JatekosKitiltasFeloldas(1, SteamID, Ip, NEV[id], Tilto1, Tilto2, Indok1, Indok2);
			}else if(IDFeloldas == 1){
				JatekosKitiltasFeloldas(2, SteamID, Ip, NEV[id], Tilto1, Tilto2, Indok1, Indok2);
			}else if(IpFeloldas == 1){
				JatekosKitiltasFeloldas(3, SteamID, Ip, NEV[id], Tilto1, Tilto2, Indok1, Indok2);
			}
			if(Tovabb == 0){
				PlayerEllenorzes(id);
			}
		}else{
			PlayerEllenorzes(id);
		}
	} 
}

public AdminLekeres(id, Azonosito[]){
	new ID = find_player("c", Azonosito);
	if(ID != 0){
		format(KivalasztottAdminEredmenyUJ[id][0], 120, "%s", STEAMID[ID]);
		format(KivalasztottAdminEredmenyUJ[id][1], 120, "%s", NEV[ID]);
		format(KivalasztottAdminEredmenyUJ[id][2], 120, "%s", ModJogok[ID]);
		format(KivalasztottAdminEredmenyUJ[id][3], 120, "%s", Jogok[ID]);
		format(KivalasztottAdminEredmenyUJ[id][4], 120, "%d", SzuperAdmin[ID]);
		format(KivalasztottAdminEredmenyUJ[id][5], 120, "%s", JatekosPrefix[ID]);
		format(KivalasztottAdminEredmenyUJ[id][6], 120, "%d", Adminvagy[ID]);
	}else{
		new Data[1];
		Data[0] = id; 
		new query[300];
		format(query, charsmax(query), "SELECT `STEAMID`, `Nev`, `ModJogok`, `Jogok`, `SzuperAdmin`, `Prefix`, `Admin` FROM `%s` WHERE `STEAMID` = ^"%s^" AND `IP`!= ^"%s^";", TablaNev, Azonosito, AdminIP);
		SQL_ThreadQuery(SQLTuple,"AdminLekeresq", query, Data, 2);
	}
}

public AdminLekeresq(FailState, Handle:Query, Error[], Errcode, Data[], DataSize) {
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) {
		log_amx("%s", Error);
		return; 
	}else {
		new id = Data[0];		
		if(SQL_NumRows(Query) > 0){
			SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "STEAMID"), KivalasztottAdminEredmenyUJ[id][0], 120);
			SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Nev"), KivalasztottAdminEredmenyUJ[id][1], 120);
			SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "ModJogok"), KivalasztottAdminEredmenyUJ[id][2], 120);
			SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Jogok"), KivalasztottAdminEredmenyUJ[id][3], 120);
			SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "SzuperAdmin"), KivalasztottAdminEredmenyUJ[id][4], 120);
			SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Prefix"), KivalasztottAdminEredmenyUJ[id][5], 120);
			SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Admin"), KivalasztottAdminEredmenyUJ[id][6], 120);
		}
		AdminJogok(id);
	} 
}

public JatekosokLekeres(id, Azonosito[], Tipus, Tipus2){
	new Data[3];
	Data[0] = id; 
	Data[1] = Tipus;
	new query[2000];
	if(Tipus == 0){
		new Limit;
		if(Tipus2 == 0 || Offset[id] == 0){
			Data[2] = 1;
			Limit = 6;
		}else if(Tipus2 == 1){
			Limit = 7;
		}else if(Tipus2 == 2){
			Limit = 7;
		}
		if(SzuperAdmin[id] == 0){
			format(query, charsmax(query), "SELECT `STEAMID`, `Nev`, `IP` FROM `%s` WHERE `Nev` LIKE '%%%s%%' AND `Admin` = 0 AND `SzuperAdmin` = 0 AND `IP` != ^"%s^" AND `IP` != ^"%s^" LIMIT %d OFFSET %d;", TablaNev, Azonosito, AdminIP, IP[id], Limit, Offset[id]);
		}else{
			format(query, charsmax(query), "SELECT `STEAMID`, `Nev`, `IP` FROM `%s` WHERE `Nev` LIKE '%%%s%%' AND `IP` != ^"%s^" AND `IP` != ^"%s^" LIMIT %d OFFSET %d;", TablaNev, Azonosito, AdminIP, IP[id], Limit, Offset[id]);
		}
	}else if(Tipus == 1){
		if(SzuperAdmin[id] == 0){
			format(query, charsmax(query), "SELECT `STEAMID`, `Nev`, `IP` FROM `%s` WHERE `STEAMID` = '%s' AND `Admin` = 0 AND `SzuperAdmin` = 0 AND `IP` != ^"%s^" AND `IP` != ^"%s^";", TablaNev, Azonosito, AdminIP, IP[id]);
		}else{
			format(query, charsmax(query), "SELECT `STEAMID`, `Nev`, `IP` FROM `%s` WHERE `STEAMID` = '%s' AND `IP` != ^"%s^" AND `IP` != ^"%s^";", TablaNev, Azonosito, AdminIP, IP[id]);
		}
	}else if(Tipus == 2){	
		new Limit;
		if(Tipus2 == 0 || Offset[id] == 0){
			Data[2] = 1;
			Limit = 6;
		}else if(Tipus2 == 1){
			Limit = 7;
		}else if(Tipus2 == 2){
			Limit = 7;
		}
		if(SzuperAdmin[id] == 0){
			format(query, charsmax(query), "SELECT `STEAMID`, `Nev`, `IP` FROM `%s` WHERE `IP` = ^"%s^" AND `Admin` = 0 AND `SzuperAdmin` = 0 AND `IP` != ^"%s^" LIMIT %d OFFSET %d;", TablaNev, Azonosito, Limit, Offset[id], AdminIP);
		}else{
			format(query, charsmax(query), "SELECT `STEAMID`, `Nev`, `IP` FROM `%s` WHERE `IP` = ^"%s^" AND `IP` != ^"%s^" AND `IP` != ^"%s^" LIMIT %d OFFSET %d;", TablaNev, Azonosito, AdminIP, IP[id], Limit, Offset[id]);
		}
	}else if(Tipus == 3){
		if(SzuperAdmin[id] == 0){
			format(query, charsmax(query), "SELECT `STEAMID`, `Nev`, `IP` FROM `%s` WHERE `Nev` = '%s' AND `Admin` = 0 AND `SzuperAdmin` = 0 AND `IP` != ^"%s^" AND `IP` != ^"%s^";", TablaNev, Azonosito, AdminIP, IP[id]);
		}else{
			format(query, charsmax(query), "SELECT `STEAMID`, `Nev`, `IP` FROM `%s` WHERE `Nev` = '%s' AND `IP` != ^"%s^" AND `IP` != ^"%s^";", TablaNev, Azonosito, AdminIP, IP[id]);
		}
	}
	SQL_ThreadQuery(SQLTuple,"JatekosokLekeresq", query, Data, 3);
}

public JatekosokLekeresq(FailState, Handle:Query, Error[], Errcode, Data[], DataSize) {
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) {
		log_amx("%s", Error);
		return; 
	}else {
		new id = Data[0];		
		new Tipus = Data[1];
		
		new Eredmeny[7][400], EredmenyNev[7][40], EredmenySzam, ErintettSorok = SQL_NumRows(Query);
		if(ErintettSorok > 0){
			if(Tipus == 0 || Tipus == 2){
				new Irany = Data[2];
				while (SQL_MoreResults(Query)){
					if(Irany == 1 && EredmenySzam == 0){
						Eredmeny[0] = "";
						EredmenySzam++;
					}
					new String[400];
					SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "STEAMID"), String, 400);
					format(Eredmeny[EredmenySzam], 400, "%s ^"%s^"", Eredmeny[EredmenySzam], String);
					SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Nev"), String, 400);
					format(Eredmeny[EredmenySzam], 400, "%s ^"%s^"", Eredmeny[EredmenySzam], String);
					format(EredmenyNev[EredmenySzam], 40, "%s", String);
					SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "IP"), String, 400);
					format(Eredmeny[EredmenySzam], 400, "%s ^"%s^"", Eredmeny[EredmenySzam], String);
					EredmenySzam++;
					SQL_NextRow(Query);
				}
			}else if(Tipus == 1){
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "STEAMID"), KivalasztottEredmeny[id][0], 100);
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Nev"), KivalasztottEredmeny[id][1], 100);
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "IP"), KivalasztottEredmeny[id][2], 100);
				JatekosokNemitasLekeres(id);
				return;
			}else if(Tipus == 3){
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "STEAMID"), KivalasztottEredmeny[id][0], 100);
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Nev"), KivalasztottEredmeny[id][1], 100);
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "IP"), KivalasztottEredmeny[id][2], 100);
				JatekosokNemitasLekeres(id);
				return;
			}
		}
		OfflinePlayerLeker(id, Eredmeny, EredmenyNev, EredmenySzam);
	} 
}
public JatekosokNemitasLekeres(id){
	new Data[1];
	Data[0] = id;
	new query[300];
	format(query, charsmax(query), "SELECT * FROM `%sNemitas` WHERE STEAMID = ^"%s^" OR IP = ^"%s^"", TablaNev, KivalasztottEredmeny[id][0], KivalasztottEredmeny[id][2]);
	SQL_ThreadQuery(SQLTuple,"JatekosokNemitasLekeresq", query, Data, 1);
}

public JatekosokNemitasLekeresq(FailState, Handle:Query, Error[], Errcode, Data[], DataSize) {
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) {
		log_amx("%s", Error);
	}else {
		new id = Data[0];		
		new Eredmeny[11];
		if(SQL_NumRows(Query) > 0){			
			while (SQL_MoreResults(Query)){
				new SteamID[100], Ip[100];
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "STEAMID"), SteamID, 100);
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "IP"), Ip, 100);
				if(equal(SteamID, "")){
					SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Nemito"), KivalasztottEredmeny[id][5], 100);
					SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Indok"), KivalasztottEredmeny[id][6], 100);
					SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Lejarat"), KivalasztottEredmeny[id][14], 200);
				}else{
					format(Eredmeny, 11, "%sb", Eredmeny);
					SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Nemito"), KivalasztottEredmeny[id][7], 100);
					SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Indok"), KivalasztottEredmeny[id][8], 100);
					SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Lejarat"), KivalasztottEredmeny[id][15], 200);
				}
				SQL_NextRow(Query);
			}
			if(containi(Eredmeny, "a") != -1 && containi(Eredmeny, "b") != -1){
				format(KivalasztottEredmeny[id][3], 100, "3");
			}else if(containi(Eredmeny, "a") != -1){
				format(KivalasztottEredmeny[id][3], 100, "2");
			}else if(containi(Eredmeny, "b") != -1){
				format(KivalasztottEredmeny[id][3], 100, "1");
			}
		}else{
			format(KivalasztottEredmeny[id][3], 100, "0");
		}
		JatekosokBanLekeres(id);
	}
}

stock bool:is_user_steam(id)
{
	static dp_pointer;
 
	if (dp_pointer || (dp_pointer = get_cvar_pointer("dp_r_id_provider")))
	{
		server_cmd("dp_clientinfo %d", id);
		server_exec();
		return (get_pcvar_num(dp_pointer) == 2) ? true : false;
	}
 
	return false;
}

public JatekosokBanLekeres(id){
	new Data[1];
	Data[0] = id;
	new query[300];
	format(query, charsmax(query), "SELECT * FROM `%sKitiltas` WHERE STEAMID = ^"%s^" OR IP = ^"%s^"", TablaNev, KivalasztottEredmeny[id][0], KivalasztottEredmeny[id][2]);
	SQL_ThreadQuery(SQLTuple,"JatekosokBanLekeresq", query, Data, 1);
}

public JatekosokBanLekeresq(FailState, Handle:Query, Error[], Errcode, Data[], DataSize) {
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) {
		log_amx("%s", Error);
	}else {
		new id = Data[0];		
		new Eredmeny[11];
		if(SQL_NumRows(Query) > 0){
			while (SQL_MoreResults(Query)){
				new SteamID[100], Ip[100];
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "STEAMID"), SteamID, 100);
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "IP"), Ip, 100);
				if(equal(SteamID, "")){
					SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Tilto"), KivalasztottEredmeny[id][9], 100);
					SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Indok"), KivalasztottEredmeny[id][10], 100);
					format(Eredmeny, 11, "%sa", Eredmeny);
				}else{
					format(Eredmeny, 11, "%sb", Eredmeny);
					SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Tilto"), KivalasztottEredmeny[id][11], 100);
					SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Indok"), KivalasztottEredmeny[id][12], 100);
				}
				SQL_NextRow(Query);
			}
			if(containi(Eredmeny, "a") != -1 && containi(Eredmeny, "b") != -1){
				format(KivalasztottEredmeny[id][4], 100, "3");
			}else if(containi(Eredmeny, "a") != -1){
				format(KivalasztottEredmeny[id][4], 100, "2");
			}else if(containi(Eredmeny, "b") != -1){
				format(KivalasztottEredmeny[id][4], 100, "1");
			}
		}else{
			format(KivalasztottEredmeny[id][4], 100, "0");
		}
		JatekosMenu(id);
	}
}

public NemitasMegad(id, Tipus, Azonosito[], Ido, Indok[], Nev[]){

	if(!Ido == 0)
		Ido = Ido/60;

	new banntarget = cmd_target(id, Azonosito);
	if(is_user_connected(banntarget))
		client_cmd(id, "amx_mute ^"%s^" %i ^"%s^" %i", Azonosito, Ido, Indok, adminmutetype[id]);
	else
		client_cmd(id, "* Némítás hozzáadás nem elérhető, kérlek használd a www.herboy.hu-t!");
}

public NemitasFeloldas(id, Tipus, Azonosito[], Nev[], Indok[]){

	chat(0, 0, 0, "!t%s (%s) !nNémitását feloldotta: !g%s !nIndok: !g%s", Nev, Tipus ? "IP" : "SteamID", NEV[id], Indok);

	if(Tipus == 1){
		new IPSzam;
		for(new i = 1;i < JATEKOSOK;i++){
			if(is_user_connected(i)){
				if(equali(Azonosito, IP[i])){
					NemitasLejar[i][1] = 0;
					Nemito[i][1][0] = EOS;
					NemitasIndok[i][1][0] = EOS;
					IPSzam++;
					remove_task(15458+i);
				}
			}
			if(IPSzam == MaxIP){
				break;
			}
		}
		PlayerNemitasFeloldas(Azonosito, 1);
	}else{
		new ID = find_player("c", Azonosito);
		if(ID != 0){
			NemitasLejar[ID][0] = 0;
			Nemito[ID][0][0] = EOS;
			NemitasIndok[ID][0][0] = EOS;
			remove_task(14458+ID);
		}
		PlayerNemitasFeloldas(Azonosito, 0);		
	}
}

public KitiltasMegad(id, Tipus, Azonosito[], Ido, Indok[], Nev[]){
	if(!Ido == 0)
		Ido = Ido/60;

	new banntarget = cmd_target(id, Azonosito);
	if(is_user_connected(banntarget))
		client_cmd(id, "amx_ban ^"%s^" %i ^"%s^"", Azonosito, Ido, Indok);
	else
		client_cmd(id, "amx_addban ^"%s^" %i ^"%s^"", Azonosito, Ido, Indok);
}

public KitiltasFeloldas(id, Tipus, Azonosito[], Nev[], Indok[]){

	chat(0, 0, 0, "!t%s !n(!g%s!n) !nKitiltását feloldotta: !g%s !nIndok: !g%s", Nev, Tipus ? "IP" : "SteamID", NEV[id], Indok);
	
	if(Tipus == 1){
		JatekosKitiltasFeloldas(5, "", Azonosito, "", "", "", "", "");
	}else{
		JatekosKitiltasFeloldas(4, Azonosito, "", "", "", "", "", "");
	}
}

public KitiltasKirugas1(Adatok[]){
	new id = Adatok[0];
	client_cmd(id, "snapshot");
	set_task(0.9, "KitiltasKirugas2", 66248, Adatok, 1);
}
public KitiltasKirugas2(Adatok[]){
	new id = Adatok[0];
	client_cmd(id, "snapshot");
	set_task(0.1, "KitiltasKirugas3", 66228, Adatok, 1);
}
public KitiltasKirugas3(Adatok[]){
	new id = Adatok[0];
	server_cmd("kick #%d Ki lettél tiltva! Nézd meg a konzolod!", get_user_userid(id));
}

public PlayerBetoltes(id){
	new Data[1];
	Data[0] = id;
	new query[1024];
	format(query, charsmax(query), "SELECT * FROM `%s` WHERE `STEAMID` = ^"%s^"", TablaNev, STEAMID[id]);
	SQL_ThreadQuery(SQLTuple,"PlayerBetoltesq", query, Data, 1);
}

public PlayerBetoltesq(FailState, Handle:Query, Error[], Errcode, Data[], DataSize) {
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) {
		log_amx("%s", Error);
		return;
	}else{
		new id = Data[0];
		new Nev[50];
		SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Nev"), Nev, 50);	
		new ipcim[40];
		SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "IP"), ipcim, 40);	
		SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Felhasznalonev"), Felhasznalonev[id], 32);	
		new keres[300];
		if(!equal(NEV[id], Nev)){
			format(keres, charsmax(keres), "UPDATE `%s` SET Nev = ^"%s^" WHERE STEAMID = ^"%s^";", TablaNev, NEV[id], STEAMID[id]);
			new Data[2];
			Data[0] = 0;
		}
		if(!equal(IP[id], ipcim)){
			format(keres, charsmax(keres), "UPDATE `%s` SET IP = ^"%s^" WHERE STEAMID = ^"%s^";", TablaNev, IP[id], STEAMID[id]);
			new Data[2];
			Data[0] = 0;
		}
		if(!equal(keres, "")){
			SQL_ThreadQuery(SQLTuple, "QuerySetData", keres, Data, 2);
		}
		if(equal(Felhasznalonev[id], "")){
			regelnikell[id] = 1;
		}
		JatekosID[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "ID"));
		Masodpercek[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Masodpercek"));
		
		Vip[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Vip"));
		if(Vip[id] != 0){
			new viplejar = Vip[id]-get_systime();
			new Adatok[1];
			Adatok[0] = id;
			if(viplejar <= 0){
				Vip[id] = 0;
				set_task(1.0, "VipLejar", 65989+id, Adatok, 1);
			}else{
				set_task(float(viplejar), "VipLejar", 65989+id, Adatok, 1);
			}
		}
		
		Olesek[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Olesek"));
		JatekosRang[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Rang"));
		Penz[id] = 0.00;
		SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Penz"), Penz[id]);
		HUD[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "HUD"));
		KillFade[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "KillFade"));
		Ejtoernyo[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Ejtoernyo"));
		Sebzeskijelzo[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Sebzeskijelzo"));
		Duplaugras[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Duplaugras"));
		Kinezetek[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Kinezetek"));
		HalalUF[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "HalalUF"));
		JelenlegiFegyo[id][28] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "FegyverSkin1"));	
		JelenlegiFegyo[id][22] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "FegyverSkin2"));	
		JelenlegiFegyo[id][5] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "FegyverSkin3"));	
		JelenlegiFegyo[id][19] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "FegyverSkin4"));	
		JelenlegiFegyo[id][3] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "FegyverSkin5"));	
		JelenlegiFegyo[id][21] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "FegyverSkin6"));	
		JelenlegiFegyo[id][8] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "FegyverSkin7"));	
		JelenlegiFegyo[id][14] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "FegyverSkin8"));	
		JelenlegiFegyo[id][15] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "FegyverSkin9"));	
		JelenlegiFegyo[id][17] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "FegyverSkin10"));	
		JelenlegiFegyo[id][16] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "FegyverSkin11"));	
		JelenlegiFegyo[id][29] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "FegyverSkin12"));
		JelenlegiFegyo[id][18] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "FegyverSkin13"));
		JelenlegiFegyo[id][26] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "FegyverSkin14"));
		Kulcsaim[id][0] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "LadaKulcs"));
		new Leker[100];
		
		for(new i = 1;i <= LadakSzama;i++){	
			format(Leker, 100, "Lada%d", i);
			JatekosLadak[id][i] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, Leker));
			format(Leker, 100, "Lada%dKulcs", i);
			Kulcsaim[id][i] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, Leker));
		}
		for(new a = 1;a < 31;a++){
			for(new b = 1;b <= FegyokSzama[a];b++){
				format(Leker, 100, "M%d", Fegyok[a][b]);
				JatekosFegyo[id][Fegyok[a][b]] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, Leker));
				JatekosFegyverOsszes[id][a] += JatekosFegyo[id][Fegyok[a][b]];
			}
		}
		Felcsatlakozasido[id] = get_systime();
		SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Prefix"), JatekosPrefix[id], 40);	
		Betoltott[id] = 1;
	}
}

public PlayerNemitasBetoltes(id){
	new Data[1];
	Data[0] = id;
	new query[1024];
	format(query, charsmax(query), "SELECT * FROM `%sNemitas` WHERE `STEAMID` = ^"%s^" OR `IP` = ^"%s^"", TablaNev, STEAMID[id], IP[id]);
	SQL_ThreadQuery(SQLTuple,"PlayerNemitasBetoltesq", query, Data, 1);
}

public PlayerNemitasBetoltesq(FailState, Handle:Query, Error[], Errcode, Data[], DataSize) {
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) {
		log_amx("%s", Error);
		return;
	}else{
		new id = Data[0];
		new ip[30];
		new steamid[30];
		if(SQL_NumRows(Query) > 0){
			while (SQL_MoreResults(Query)){
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "IP"), ip, 30);
				SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "STEAMID"), steamid, 30);
				if(!equal(steamid, "")){
					SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Nemito"), Nemito[id][0], 100);
					SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Indok"), NemitasIndok[id][0], 130);
					NemitasLejar[id][0] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Lejarat"));
					new Adatok[2];
					Adatok[0] = id;
					Adatok[1] = 0;
					Lejar(Adatok);
				}
				if(!equal(ip, "")){
					for(new i = 1;i < JATEKOSOK;i++){
						if(i != id && is_user_connected(i)){
							if(equal(IP[i], IP[id])){
								NemitasLejar[id][1] = NemitasLejar[i][1];
								NemitasIndok[id][1] = NemitasIndok[i][1];
								Nemito[id][1] = Nemito[i][1];
								return;
							}
						}
					}
					
					SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Nemito"), Nemito[id][1], 100);
					SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Indok"), NemitasIndok[id][1], 130);
					NemitasLejar[id][1] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Lejarat"));
					new Adatok[2];
					Adatok[0] = id;
					Adatok[1] = 1;
					Lejar(Adatok);
				}
				SQL_NextRow(Query);
			}
		}
	}
}

public PlayerNemitasFeloldas(Azonosito[], Adat){
	new Data[1];
	Data[0] = 0;
	new query[1024];
	if(Adat == 1){
		format(query, charsmax(query), "DELETE FROM `%sNemitas` WHERE `IP` = ^"%s^"", TablaNev, Azonosito);
	}else{
		format(query, charsmax(query), "DELETE FROM `%sNemitas` WHERE `STEAMID` = ^"%s^"", TablaNev, Azonosito);
	}
	SQL_ThreadQuery(SQLTuple,"QuerySetData", query, Data, 1);
}

public JatekosKitiltasFeloldas(Adat, SteamID[], Ip[], Nev[], Tilto1[], Tilto2[], Indok1[], Indok2[]){
	new Data[1];
	Data[0] = 0;
	new query[1024];
	if(Adat == 1){
		format(query, charsmax(query), "DELETE FROM `%sKitiltas` WHERE `IP` = ^"%s^" OR `STEAMID` = ^"%s^"", TablaNev, Ip, SteamID);
		chat(0, 0, 0, "!t%s (SteamID) !nKitiltása lejárt! Tiltó: %s !nIndok: !g%s", Nev, Tilto1, Indok1);
		chat(0, 0, 0, "!t%s (IP) !nKitiltása lejárt! Tiltó: %s !nIndok: !g%s", Nev, Tilto2, Indok2);
	}else if(Adat == 2 || Adat == 4){
		format(query, charsmax(query), "DELETE FROM `%sKitiltas` WHERE `STEAMID` = ^"%s^"", TablaNev, SteamID);
		if(Adat == 2){
			chat(0, 0, 0, "!t%s (SteamID) !nKitiltása lejárt! Tiltó: %s !nIndok: !g%s", Nev, Tilto1, Indok1);
		}
	}else if(Adat == 3 || Adat == 5){
		format(query, charsmax(query), "DELETE FROM `%sKitiltas` WHERE `IP` = ^"%s^"", TablaNev, Ip);
		if(Adat == 3){
			chat(0, 0, 0, "!t%s (IP) !nKitiltása lejárt! Tiltó: %s !nIndok: !g%s", Nev, Tilto2, Indok2);
		}
	}
	SQL_ThreadQuery(SQLTuple,"QuerySetData", query, Data, 1);
}

public AdminJogMentes(id){
	new Data[2];
	Data[0] = -1;
	Data[1] = id;
	new query[2024];
	new ID = find_player("c", KivalasztottAdminEredmenyUJ[id][0]);
	if(ID != 0){
		format(ModJogok[ID], 100, "%s", KivalasztottAdminEredmenyUJ[id][2]);
		format(Jogok[ID], 100, "%s", KivalasztottAdminEredmenyUJ[id][3]);
		SzuperAdmin[ID] = str_to_num(KivalasztottAdminEredmenyUJ[id][4]);
		format(JatekosPrefix[ID], 40, "%s", KivalasztottAdminEredmenyUJ[id][5]);
		Adminvagy[ID] = str_to_num(KivalasztottAdminEredmenyUJ[id][6]);
		chat(0, id, 0, "A mentés sikeresen lezárult!");
	}else{
		format(query, charsmax(query), "UPDATE `%s` SET Prefix = ^"%s^", Admin = ^"%d^", SzuperAdmin = ^"%d^", Jogok = ^"%s^", ModJogok = ^"%s^" WHERE STEAMID = ^"%s^"", TablaNev, KivalasztottAdminEredmenyUJ[id][5], str_to_num(KivalasztottAdminEredmenyUJ[id][6]), str_to_num(KivalasztottAdminEredmenyUJ[id][4]), KivalasztottAdminEredmenyUJ[id][3], KivalasztottAdminEredmenyUJ[id][2], KivalasztottAdminEredmenyUJ[id][0]);
		SQL_ThreadQuery(SQLTuple,"QuerySetData", query, Data, 2);
	}
	KivalasztottAdminEredmenyUJUrit(id);
}

public VipLejar(Adatok[]){
	new id = Adatok[0];
	Vip[id] = 0;
	chat(0, 0, 0, "!t%s !gV.I.P !njoga lejárt!", NEV[id]);
}

public Lejar(Adatok[]){
	new Lejarat = NemitasLejar[Adatok[0]][Adatok[1]];
	if(Lejarat == -1){
		return;
	}
	Lejarat -= get_systime();
	if(Lejarat <= 0){
		new bool:ip;
		if(Adatok[1] == 0){
			ip = false;
		}else{
			ip = true;
		}
		if(ip == true){
			chat(0, 0, 0, "!t%s !n(!t%s!n) némitása lejárt! !gIndok!n: !t%s", NEV[Adatok[0]], IP[Adatok[0]], NemitasIndok[Adatok[0]][Adatok[1]]);
			PlayerNemitasFeloldas(IP[Adatok[0]], 1);
			new IPSzam;
			for(new i = 0;i < JATEKOSOK;i++){
				if(is_user_connected(i)){
					if(equal(IP[i], IP[Adatok[0]])){
						NemitasLejar[i][1] = 0;
						NemitasIndok[i][1][0] = EOS;
						Nemito[i][1][0] = EOS;
						IPSzam++;
					}
					if(IPSzam == MaxIP){
						break;
					}
				}
			}
			remove_task(15458+Adatok[0]);
		}else{		
			chat(0, 0, 0, "!t%s !n(!t%s!n) némitása lejárt! !gIndok!n: !t%s", NEV[Adatok[0]], STEAMID[Adatok[0]], NemitasIndok[Adatok[0]][Adatok[1]]);
			NemitasLejar[Adatok[0]][0] = 0;
			NemitasIndok[Adatok[0]][0][0] = EOS;
			Nemito[Adatok[0]][0][0] = EOS;
			PlayerNemitasFeloldas(STEAMID[Adatok[0]], 0);
			remove_task(14458+Adatok[0]);
		}
	}else{
		if(Adatok[1] == 0){
			set_task(float(Lejarat), "Lejar", 14458+Adatok[0], Adatok, 2);
		}else{ 
			set_task(float(Lejarat), "Lejar", 15458+Adatok[0], Adatok, 2);
		}
	}
}

public Admin(id){
	if(id != 0){
		if(SzuperAdmin[id] == 1){
			set_user_flags(id, read_flags("abcdefghijklmnopqrstuv"));
			chat(0, id, 0, "!tMegkaptad a jogaid!(Szerver: abcdefghijklmnopqrstuv | Mod: abcdef)");
		}else{
			new JogokS[150];
			if(!equal(Jogok[id], "")){
				set_user_flags(id, read_flags(Jogok[id]));
				format(JogokS, 150, "Szerver: %s", Jogok[id]);
				if(!equal(ModJogok[id], "")){
					format(JogokS, 150, "%s | Mod: %s", JogokS, ModJogok[id]);
				}
			}else{
				if(!equal(ModJogok[id], "")){
					format(JogokS, 150, "Mod: %s", ModJogok[id]);
				}
			}
			if(!equal(JogokS, "")){
				chat(0, id, 0, "!tMegkaptad a jogaid!(Szerver: %s | Mod: %s)", Jogok[id], ModJogok[id]);
			}
		}
	}
}

public JelszoMentesSQL(id) {
	if(Betoltott[id] == 0){
		PlayerBetoltes(id);
	}
	
	if(Adminvagy[id] == 1){
		Admin(id);
		if(cs_get_user_team(id) == CS_TEAM_UNASSIGNED){
			client_cmd(id, "jointeam");
		}
	}else if(Bekelllepni[id] == 1){
		if(cs_get_user_team(id) == CS_TEAM_UNASSIGNED){
			client_cmd(id, "jointeam");
		}
	}
	Bekelllepni[id] = 1;
	Belepett[id] = 1;
	copy(JelszoSQL[id], 100, Jelszo[id]);
}

public Frissites(id) {
	
	if((Bekelllepni[id] == 1 || Adminvagy[id] == 1 || SzuperAdmin[id] == 1) && Belepett[id] != 1){
		return;
	}
	static query[20106];
	new Len;
	
	Len += format(query[Len], charsmax(query), "UPDATE `%s` SET `Jelszo` = ^"%s^", `Admin` = ^"%d^", `Bekelllepni` = ^"%d^", `ModJogok` = ^"%s^",`Jogok` = ^"%s^", `Prefix` = ^"%s^"", TablaNev, JelszoSQL[id], Adminvagy[id], Bekelllepni[id], ModJogok[id], Jogok[id], JatekosPrefix[id]);
	
	new Ido = get_systime() - Felcsatlakozasido[id];
	if(Ido > 0 && Felcsatlakozasido[id] != 0){
		Len += format(query[Len], charsmax(query)-Len, ", `Masodpercek` = Masodpercek+%d", Ido);		
	}
	Len += format(query[Len], charsmax(query)-Len, ", `LadaKulcs` = ^"%d^"", Kulcsaim[id][0]);
	
	for(new i = 1;i <= LadakSzama;i++){
		Len += format(query[Len], charsmax(query)-Len, ", `Lada%dKulcs` = ^"%d^"", i, Kulcsaim[id][i]);
		Len += format(query[Len], charsmax(query)-Len, ", `Lada%d` = ^"%d^"", i, JatekosLadak[id][i]);
	}
	
	Len += format(query[Len], charsmax(query)-Len, ", Olesek = ^"%d^", Penz = ^"%f^", Vip = ^"%d^", HUD = ^"%d^", KillFade = ^"%d^", Kinezetek = ^"%d^", Ejtoernyo = ^"%d^", Sebzeskijelzo = ^"%d^", Duplaugras = ^"%d^"", Olesek[id], Penz[id], Vip[id], HUD[id], KillFade[id], Kinezetek[id], Ejtoernyo[id], Sebzeskijelzo[id], Duplaugras[id]);
	Len += format(query[Len], charsmax(query)-Len, ", FegyverSkin1 = ^"%d^", FegyverSkin2 = ^"%d^", FegyverSkin3 = ^"%d^", FegyverSkin4 = ^"%d^", FegyverSkin5 = ^"%d^"", JelenlegiFegyo[id][28], JelenlegiFegyo[id][22], JelenlegiFegyo[id][5], JelenlegiFegyo[id][19], JelenlegiFegyo[id][3]);
	Len += format(query[Len], charsmax(query)-Len, ", FegyverSkin6 = ^"%d^", FegyverSkin7 = ^"%d^", FegyverSkin8 = ^"%d^", FegyverSkin9 = ^"%d^", FegyverSkin10 = ^"%d^"", JelenlegiFegyo[id][21], JelenlegiFegyo[id][8], JelenlegiFegyo[id][14], JelenlegiFegyo[id][15], JelenlegiFegyo[id][17]);
	Len += format(query[Len], charsmax(query)-Len, ", FegyverSkin11 = ^"%d^", FegyverSkin12 = ^"%d^", FegyverSkin13 = ^"%d^", FegyverSkin14 = ^"%d^"", JelenlegiFegyo[id][16], JelenlegiFegyo[id][29], JelenlegiFegyo[id][18], JelenlegiFegyo[id][26]);
	Len += format(query[Len], charsmax(query)-Len, ", SzuperAdmin = ^"%d^", Rang = ^"%d^", AdminElrejt = ^"%d^", PottyiPont = ^"%d^", HalalUF = ^"%d^"", SzuperAdmin[id], JatekosRang[id], AdminElrejt[id], PottyiPont[id], HalalUF[id]);
	
	for(new a = 1;a < 31;a++){
		for(new b = 1;b <= FegyokSzama[a];b++){
			Len += format(query[Len], charsmax(query)-Len, ", M%d = ^"%d^"", Fegyok[a][b], JatekosFegyo[id][Fegyok[a][b]]);
		}
	}
	Len += format(query[Len], charsmax(query)-Len, " WHERE STEAMID = ^"%s^"", STEAMID[id]);
	
	new Data[2];
	Data[0] = 0;
	Data[1] = 0;
	SQL_ThreadQuery(SQLTuple, "QuerySetData", query, Data, 2);
}

public QuerySetData(FailState, Handle:Query, error[],errcode, Data[], DataSize){
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED){
		if(Data[0] > 0){
			log_amx("1: %s", error);
		}else{
			log_amx("2: %s", error);
		}
	}else{
		if(Data[0] > 0){
			if(Data[1] == 1){
				PlayerBetoltes(Data[0]);
			}else{
				for(new i = 0;i < JATEKOSOK;i++){
					if(is_user_connected(i)){
						if(equal(IP[i], IP[Data[0]])){		
							return;
						}
					}
				}
			}
		}
	}
	
}

public ClientUserInfoChanged(id){ 
	static Regi[32], Uj[32]; 
	pev(id, pev_netname, Regi, charsmax(Regi)); 
	if( Regi[0] ){ 
		get_user_info(id, "name", Uj, charsmax(Uj)); 
		if( !equal(Regi, Uj) ){ 
			set_user_info(id, "name", Regi); 
			return FMRES_HANDLED; 
		} 
	} 
	return FMRES_IGNORED; 
}  
public Demo(id){
	client_cmd(id, "record HerBoy");
}

public client_putinserver(id)
{
	client_cmd(id, "stop");
	set_task(10.0, "Demo", id);
}

public client_connect(id){
	get_user_name(id, NEV[id], charsmax(NEV));
	if(containi(NEV[id], "^"") != -1){
		server_cmd("kick #%d ^"A neved nem tartalmazhatja ezt a kraktereket: ^"! ^"", get_user_userid(id));
		return;	
	}
	if(containi(NEV[id], "") != -1 || containi(NEV[id], "") != -1 || containi(NEV[id], "") != -1 || containi(NEV[id], "") != -1 || containi(NEV[id], "卐") != -1 || containi(NEV[id], "卍") != -1 || containi(NEV[id], "ↈ") != -1 || containi(NEV[id], "ﷻ") != -1) {
		server_cmd("kick #%d ^"A neved nem tartalmazhatja ezeket a kraktereket! (SOH, STX, ETX, EOT, vagy 卐, 卍)^"", get_user_userid(id));
	}
	if(containi(NEV[id], "anyad") != -1 || containi(NEV[id], "kurva") != -1 || containi(NEV[id], "anyád") != -1 || containi(NEV[id], "csicska") != -1 || containi(NEV[id], "geci") != -1){
		server_cmd("kick #%d ^"A neved nem tartalmazhat trágár szavakat!^"", get_user_userid(id));
	}
	if(containi(NEV[id], "DROP TABLE") != -1 || containi(NEV[id], "TRUNCATE TABLE") != -1 || containi(NEV[id], "; --") != -1 || containi(NEV[id], "INSTERT INTO") != -1){
		server_cmd("kick #%d ^"A neved nem tartalmazhat SQL Injectionos kéréseket.^"", get_user_userid(id));
	}
	if(is_user_hltv(id)){
		server_cmd("kick #%d ^"A szerveren nem engedélyezett a HLTV^"", get_user_userid(id));
		return;
	}	
	SebessegDetect[id] = 0;
	adminmutetype[id] = 3;
	SebessegReset[id] = 0;
	SebessegStat[id] = 0;
	SebessegBlock[id] = 0;
	regelnikell[id] = 0;
	Felhasznalonev[id] = "";
	KesAKezben[id] = false;
	NemitasFigyelmeztetes[id] = 0;
	Jelszo[id] = "";
	Jelszo2[id] = "";
	JelszoSQL[id] = "";
	KivalasztottNev[id][0] = EOS;
	Adminvagy[id] = 0;
	new nemitaslejar[2];
	NemitasLejar[id] = nemitaslejar;
	new nemito[2][100];
	Nemito[id] = nemito;
	new nemitasindok[2][130];
	NemitasIndok[id] = nemitasindok;
	new NULLA[31];
	JatekosFegyverOsszes[id] = NULLA;
	KivalasztottMap[id] = 0;
	KivalasztottKorok[id] = -1;
	KivalasztottEredmenyUrit(id);
	KivalasztottAdminEredmenyUJUrit(id);
	Ido[id] = 0;
	IdoForma[id] = 0;
	Indok[id][0] = EOS;
	Duplaugras[id] = 0;
	ModJogok[id][0] = EOS;
	Jogok[id][0] = EOS;
	KillFade[id] = 0;
	SayDead[id] = 0;
	HalalUF[id] = 0;
	Kinezetek[id] = 0;
	Ejtoernyo[id] = 0;
	Sebzeskijelzo[id] = 0;
	AdminElrejt[id] = 0;
	Bekelllepni[id] = 0;
	SzuperAdmin[id] = 0;
	Olesek[id] = 0;
	Penz[id] = 0.0;
	get_user_ip(id, IP[id], 100, 1);
	get_user_authid(id, STEAMID[id], charsmax(STEAMID));
	if(equali(STEAMID[id], "BOT")){
		format(STEAMID[id], 50, "BOT%d", id);
	}
	Belepett[id] = 0;
	
	if(FragVan != 0){
		new Adat[FragAdatok];
		if(TrieKeyExists(FragJatekosokAdatok, STEAMID[id])){
			TrieGetArray(FragJatekosokAdatok, STEAMID[id], Adat, sizeof Adat);
			if(!equal(Adat[F_Nev], NEV[id])){
				copy(Adat[F_Nev], sizeof(Adat[F_Nev])-1, NEV[id]);
				TrieSetArray(FragJatekosokAdatok, STEAMID[id], Adat, sizeof Adat);
			}
		}else{
			copy(Adat[F_Nev], sizeof(Adat[F_Nev])-1, NEV[id]);
			TrieSetArray(FragJatekosokAdatok, STEAMID[id], Adat, sizeof Adat);
			ArrayPushString(FragJatekosok, STEAMID[id]);
		}	
	}
	if(!is_user_bot(id)){
		PlayerCsatlakozas(id);
	}
}	

stock chat(id2, id, chat, const input[], any:...){
	new count = 1, players[32];
	static msg[191];
	vformat(msg, charsmax(msg), input, 5);
	new Team;
	new Csapat1[30];
	
	if(id > 0){
		players[0] = id;
		count = 1;
	}else if(id == -1){
		count = 0;
		format(msg, charsmax(msg), "!g(!tT!g) !n%s", msg);
		for(new i = 0;i < 33;i++) {
			if(is_user_connected(i)){
				if((Adminvagy[i] != 0 || SzuperAdmin[i] != 0) && cs_get_user_team(i) == CS_TEAM_SPECTATOR){
					players[count] = i;
					count++;
				}else if(cs_get_user_team(i) == CS_TEAM_T){
					if(is_user_alive(id2)){
						if(is_user_alive(i)){
							players[count] = i;
							count++;					
						}
					}else{ 
						if(SayDead[id2] >= get_systime()){
							players[count] = i;
							count++;		
						}else{
							if(!is_user_alive(i)){								
								players[count] = i;
								count++;	
							}
						}
					}
				}
			}
		}
	}else if(id == -2){
		count = 0;
		format(msg, charsmax(msg), "!g(!tCT!g) !n%s", msg);
		for(new i = 0;i < 33;i++) {
			if(is_user_connected(i)){
				if((Adminvagy[i] != 0 || SzuperAdmin[i] != 0) && cs_get_user_team(i) == CS_TEAM_SPECTATOR){
					players[count] = i;
					count++;
				}else if(cs_get_user_team(i) == CS_TEAM_CT){
					if(is_user_alive(id2)){
						if(is_user_alive(i)){
							players[count] = i;
							count++;					
						}
					}else{ 
						if(SayDead[id2] >= get_systime()){
							players[count] = i;
							count++;		
						}else{
							if(!is_user_alive(i)){								
								players[count] = i;
								count++;	
							}
						}
					}
				}
			}
		}
	}else if(id == -3){
		count = 0;
		format(msg, charsmax(msg), "!g(!tS!g) !n%s", msg);
		for(new i = 0;i < 33;i++) {
			if(is_user_connected(i) && !is_user_bot(i) && cs_get_user_team(i) == CS_TEAM_SPECTATOR){
				players[count] = i;
				count++;
			}
		}
	}else{
		get_players(players , count , "ch");
		if(is_user_connected(id2)){
			Team++;
			if(cs_get_user_team(id2) == CS_TEAM_T){
				Csapat1 = "TERRORIST";
			}else if(cs_get_user_team(id2) == CS_TEAM_CT){
				Csapat1 = "CT";
			}else{
				Csapat1 = "SPECTATOR";
			}
		}
	}
	
	if(chat == 0){
		format(msg, charsmax(msg), "%s !n%s", Prefix, msg);
	}

	replace_all( msg, charsmax(msg), "!g", "^4" );
	replace_all( msg, charsmax(msg), "!n", "^1" );
	replace_all( msg, charsmax(msg), "!t", "^3" );
	
	for(new i = 0;i < count;i++) {
		if(is_user_connected(players[i])){
			if(Team != 0){
				new Csapat2[30];
				if(cs_get_user_team(players[i]) == CS_TEAM_T){
					Csapat2 = "TERRORIST";
				}else if(cs_get_user_team(players[i]) == CS_TEAM_CT){
					Csapat2 = "CT";
				}else if(cs_get_user_team(players[i]) == CS_TEAM_SPECTATOR){
					Csapat2 = "SPECTATOR";
				}else{
					Csapat2 = "UNASSIGNED";
				}
				if(equali(Csapat2, Csapat1)){
					message_begin(MSG_ONE, get_user_msgid("SayText"),_, players[i]);
					write_byte(players[i]);
					write_string(msg);
					message_end();
				}else{
					message_begin(MSG_ONE, get_user_msgid("TeamInfo"), _, players[i]);
					write_byte(players[i]);
					write_string(Csapat1);
					message_end();
					
					message_begin(MSG_ONE, get_user_msgid("SayText"),_, players[i]);
					write_byte(players[i]);
					write_string(msg);
					message_end();
					
					message_begin(MSG_ONE, get_user_msgid("TeamInfo"), _, players[i]);
					write_byte(players[i]);
					write_string(Csapat2);
					message_end();
				}
			}else{
				message_begin(MSG_ONE, get_user_msgid("SayText"),_, players[i]);
				write_byte(players[i]);
				write_string(msg);
				message_end();
			}
		}
	}
}

public Halal(){
	new gyilkos = read_data(1);
	new aldozat = read_data(2);
	new talalat = read_data(3);
	if(aldozat == gyilkos || !gyilkos || gyilkos > 32 || !aldozat || aldozat > 32 || !is_user_connected(aldozat) || !is_user_connected(gyilkos)){
		return PLUGIN_HANDLED;
	}
	
	SayDead[aldozat] = get_systime()+5;
	
	if(EjtoernyoEntity[aldozat] > 0) {
		if (is_valid_ent(EjtoernyoEntity[aldozat])) {
			remove_entity(EjtoernyoEntity[aldozat]);
			EjtoernyoEntity[aldozat] = 0;
		}
	}
	EjtoernyoJelnleg[aldozat] = 0;
	
	if(!KillFade[gyilkos]){
		message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("ScreenFade"), {0,0,0}, gyilkos);
		write_short(12000);
		write_short(0);
		write_short(0);
		write_byte(0);
		write_byte(0);
		write_byte(200);
		write_byte(120);
		message_end();
	}
	new Float:RandomPenz = random_float(0.20,0.50); //0.20,0.50
	new Fegyo = get_user_weapon(gyilkos);
	
	if(Fegyo == CSW_KNIFE){
		RandomPenz = RandomPenz + 0.20;
		if(talalat == HIT_HEAD){
			RandomPenz = RandomPenz + 0.10;
		}
	}else{
		if(talalat == HIT_HEAD){
			RandomPenz = RandomPenz + 0.20; //0.20
		}
	}
	
	PenzTart[gyilkos]++;
	if(PenzTart[gyilkos] > 9){
		PenzTart[gyilkos] = 8;
	}
	if(PenzTart[gyilkos] == 8){
		set_hudmessage(42, 255, 0, -1.0, 0.40, 0, 1.0, 1.0);
	}else{
		set_hudmessage(42, 255, 0, -1.0, 0.50, 0, 1.0, 1.0);
	}
	ShowSyncHudMsg(gyilkos, Sync[PenzTart[gyilkos]], "|+ %.2f$|", RandomPenz);
	Penz[gyilkos] += RandomPenz;
	
	Olesek[gyilkos]++;
	
	if(JatekosRang[gyilkos] != RangokSzama && Olesek[gyilkos] >= RangOlesek[JatekosRang[gyilkos]+1]){
		JatekosRang[gyilkos]++;
		//chat(0, 0, 0, "!g%s !nRangot lépet! Az új rangja: !t%s", NEV[gyilkos], RangNevek[JatekosRang[gyilkos]]);
	}
	if(RandomFloat() > 20.0){
		KulcsDrop(gyilkos, RandomFloat());
	}else if(RandomFloat() > 23.0){
		LadaDrop(gyilkos, RandomFloat());
	}
	if(FragVan == 1){
		FragOles(gyilkos, 1);
	}
	if(talalat == HIT_HEAD){
		set_user_frags(gyilkos, get_user_frags(gyilkos)+1);
		chat(0, gyilkos, 0,"!gFejlövés! !nEzt dupla frag-el jutalmazzuk!");
	}
	return PLUGIN_HANDLED;
}

public FragOles(id, Oles){
	new Helyezes = ArrayFindString(FragJatekosok, STEAMID[id]);
	
	new Adat[FragAdatok];
	
	TrieGetArray(FragJatekosokAdatok, STEAMID[id], Adat, sizeof Adat);
	
	if(Oles == 1){
		Adat[F_Oles]++;
		
		TrieSetArray(FragJatekosokAdatok, STEAMID[id], Adat, sizeof Adat);
	}
	
	if(Helyezes != 0){
		new Adat2[FragAdatok], SteamID[50];
		
		ArrayGetString(FragJatekosok, Helyezes-1, SteamID, charsmax(SteamID));
		
		TrieGetArray(FragJatekosokAdatok, SteamID, Adat2, sizeof Adat2);
		if(Adat2[F_Oles] <= Adat[F_Oles]){
			ArrayDeleteItem(FragJatekosok, Helyezes);
			ArrayInsertStringBefore(FragJatekosok, Helyezes-1, STEAMID[id]);
			FragOles(id, 0);
		}else{
			chat(0, id, 0, "Feljebb jutottál a versenyben! !tAz új helyezésed: !g%d!n!", Helyezes+1);
		}
	}
}

public KulcsDrop(id, Float:Esely){
	new Kulcsok[32];
	new Tovabb;
	for(new i = 0;i <= LadakSzama;i++){	
		if(i == 0){
			if(Esely <= SzerverLadakKulcsEselyek[i]){
				Kulcsok[i]++;
				Tovabb++;
			}
		}else{
			if(SzerverLadakArai[i] == -1.0 ? Vip[id] != 0 : true){
				if(Esely <= SzerverLadakKulcsEselyek[i]){
					Kulcsok[i]++;
					Tovabb++;
				}
			}
		}
	}
	if(Tovabb == 0){
		return;
	}
	new Kulcs, Float:Legkisebb = -1.0;
	for(new i = 0;i <= LadakSzama;i++){
		if(Kulcsok[i] != 0){
			if(i != 0 && SzerverLadakArai[i] == -1.0){
				new Float:Esely2 = RandomFloat();
				Kulcs = i;
				if(Esely2 <= 50.0){
					break;
				}
			}else{
				if(Legkisebb == -1.0){
					Kulcs = i;
					Legkisebb = SzerverLadakKulcsEselyek[i];
				}else{
					if(Legkisebb > SzerverLadakKulcsEselyek[i]){
						Kulcs = i;
						Legkisebb = SzerverLadakKulcsEselyek[i];
					}
				}
			}
		}
	}
	chat(0, 0, 0, "!t%s!n talált egy !g%s !nláda kulcsot! !tEsély: !g%.2f", NEV[id], SzerverLadakNevei[Kulcs], Esely);
	Kulcsaim[id][Kulcs]++;
}

public LadaDrop(id, Float:Esely){
	new Ladak[32];
	new Tovabb;
	for(new i = 1;i <= LadakSzama;i++){	
		if(Vip[id] != 0 || SzerverLadakArai[i] > 0.0){
			if(Esely <= SzerverLadakEselyek[i]){
				Ladak[i]++;
				Tovabb++;
			}
		}
	}
	if(Tovabb == 0){
		return;
	}
	new Lada, Float:Legkisebb = -1.0;
	for(new i = 1;i <= LadakSzama;i++){
		if(Ladak[i] != 0){
			if(SzerverLadakArai[i] == -1.0){
				new Float:Esely2 = RandomFloat();
				Lada = i; 
				if(Esely2 <= 50.0){
					break;
				}
			}else{
				if(Legkisebb == -1){
					Lada = i;
					Legkisebb = SzerverLadakEselyek[i];
				}else{
					if(Legkisebb > SzerverLadakEselyek[i]){
						Lada = i;
						Legkisebb = SzerverLadakEselyek[i];
					}
				}
			}
		}
	}
	
	chat(0, 0, 0, "!t%s!n talált egy !g%s !nládát! !tEsély: !g%.2f", NEV[id], SzerverLadakNevei[Lada], Esely);
	JatekosLadak[id][Lada]++;
}


public KorIndul(id){
	kor(id);
	if(EjtoernyoEntity[id] > 0) {
		remove_entity(EjtoernyoEntity[id]);
		EjtoernyoEntity[id] = 0;
		set_user_gravity(id, 1.0);
	}
	if(get_user_weapon(id) == CSW_AUG && equal(ModelEleresiUt[JelenlegiFegyo[id][CSW_AUG]], "AUG/Modern.mdl")){
		UnScope(id);
	}
}

public FW_CmdStart(ent){
	new id = pev(ent, pev_owner);
	if(get_user_weapon(id) == CSW_AUG && equal(ModelEleresiUt[JelenlegiFegyo[id][CSW_AUG]], "AUG/Modern.mdl")){
		if(Celzas[id]){
			UnScope(id);
		}else if (!Celzas[id]){
			Scope(id);
		}
	}
	return HAM_HANDLED;
}

public fw_Weapon_Reload_Post(ent){
	static id;
	id = pev(ent, pev_owner);
	new zoom = cs_get_user_zoom(id);
	
	if(get_user_weapon(id) == CSW_AUG && equal(ModelEleresiUt[JelenlegiFegyo[id][CSW_AUG]], "AUG/Modern.mdl")){
		if(zoom == 1){
			UnScope(id);
		}
	}
	return HAM_HANDLED;
}
public client_disconnect(id){
	Frissites(id);
	remove_task(14458+id);
	remove_task(75697+id);
	remove_task(15458+id);
	remove_task(65989+id);
	CsereTorles(id);
	for(new i = 1; i < JATEKOSOK;i++){
		if(is_user_connected(i)){
			if(Cserekereskedem[i][0] == id){
				Cserekereskedem[i][0] = 0;
				chat(0, i, 0, "!g%s !nLecsatlakozott, emiatt a felkérésed automatikusan törölve lett!");
				Csere(i, 0);
			}
		}
	}
	if(PiacJatekos[id][2] != 0){
		switch(PiacJatekos[id][0]){
			case 1:{
				JatekosFegyo[id][PiacJatekos[id][1]] += PiacJatekos[id][2];
				JatekosFegyverOsszes[id][ModelFegyverTipus[PiacJatekos[id][1]]] += PiacJatekos[id][2];
			}
			case 2:{
				JatekosLadak[id][PiacJatekos[id][1]] += PiacJatekos[id][2];
			}
			case 3:{
				Kulcsaim[id][0] += PiacJatekos[id][2];
			}
		}
	}
	PiacJatekos[id][0] = 0;
	PiacJatekos[id][1] = 0;
	PiacJatekos[id][2] = 0;
	if(EjtoernyoEntity[id] > 0) {
		if (is_valid_ent(EjtoernyoEntity[id])) {
			remove_entity(EjtoernyoEntity[id]);
			EjtoernyoEntity[id] = 0;
		}
	}
	EjtoernyoJelnleg[id] = 0;
	UnScope(id);
}
stock Scope(id){
	Celzas[id] = 1;
	
	if(get_user_weapon(id) == CSW_AUG && equal(ModelEleresiUt[JelenlegiFegyo[id][CSW_AUG]], "AUG/Modern.mdl")){
		new Model[100];
		format(Model, 100, "%s%s", ModelMappa, AUG_SCOPE);
		entity_set_string(id, EV_SZ_viewmodel, Model);
	}
}

stock UnScope(id){	
	Celzas[id] = 0;
	if(get_user_weapon(id) == CSW_AUG && equal(ModelEleresiUt[JelenlegiFegyo[id][CSW_AUG]], "AUG/Modern.mdl")){
		new Model[100];
		format(Model, 100, "%s%s", ModelMappa, ModelEleresiUt[JelenlegiFegyo[id][CSW_AUG]]);
		entity_set_string(id, EV_SZ_viewmodel, Model);
	}
}

public KivalasztottEredmenyUrit(id){
	for(new i = 0; i < 15; i++){
		KivalasztottEredmeny[id][i] = "";
	}
}

public KivalasztottAdminEredmenyUJUrit(id){
	for(new i = 0; i < 7; i++){
		KivalasztottAdminEredmenyUJ[id][i] = "";
	}
}
