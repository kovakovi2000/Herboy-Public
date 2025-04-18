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
#include <easytime>

/*
 - Adatok kikérdezése
 - Migrálás elkezdése
 - Ha van egyező fiók, megtörténik az egybeolvasztás egy új AccountID-ra (előnyben az utoljára bejelentkezett)
 - Ha több az egyező fiók, akkor azoknak az adatait (jidő, skin, st az utoljára bejelentkezettre)
 - Migrálás befejeztével egy új jelszóbeállítási lehetőség az usernek. (felhasználónév, és regsteamid egyezés alapján, vagy a régi jelszó alapján)
 - Nem létező egyezésnél (felhasználónév), az adatokat szimplán beilleszti a táblákba egy új AccountID-re.
 - Vendégfiók kivétel.
*/
new interv = 1, currstate, masodperc, menuid, g_screenfade;
enum _:StorageDatas
{
  started,
  ending,
  endrow,
  succes,
  error,
  vendegskip,
}
new Storage[StorageDatas]

enum _:MigrateDatas
{
  Username[33],
  Password[128],
  RegID[33],
  RegIP[33],
  LastID[33],
  LastIP[33],
  LastName[33],
  Email[33],
  Regname[33],
  Regdate[33],
  MigrateFromId,
  MigrateToId,
  playtime,
  premiumpont
}
new Migrate[MigrateDatas];

new Handle:g_SqlMigrateFrom
new Handle:g_SqlMigrateTo

new const States[][] =
{
  {"\dVárakozás"},
  {"\yAdatok kigyűtése"}, //0,5 == 4,5
  {"\yAdatok egyeztetése"},
  {"\yAdatok kiemelése"},
  {"\yBeillesztés az Avatár adatbázisba"},
  {"\yÖsszeolvasztás az Avatár regisztrációval"},
  {"\yEllenőrzés"},
  {"\rBefejezés"},
  {"\rFélegyező adatok, kihagyás."},
  {"\rVendégfiók, kihagyás."},
  {"\rTörölt fiók, kihagyás."},
}

#define LastInsertID 2839

public plugin_init()
{
  register_plugin("MigrateDatas", "v0.1", "shedi")
  register_clcmd("startmigrate", "getid")

  g_screenfade = get_user_msgid("ScreenFade")
}
public LoadUtils()
{
  g_SqlMigrateFrom = SQL_MakeDbTuple("87.229.115.72", "web_bansys", "osI3Jdma.Cr-MaU", "herboy", 10);
  g_SqlMigrateTo = SQL_MakeDbTuple("87.229.115.72", "web_bansys", "osI3Jdma.Cr-MaU", "avatar", 10);
  
	SQL_SetAffinity("mysql");
	SQL_SetCharset(g_SqlMigrateFrom, "utf8");
	SQL_SetCharset(g_SqlMigrateTo, "utf8");
}
public openMigrateMenu(id)
{
  if(id == 0)
    return PLUGIN_HANDLED;

  new String[121];
  format(String, charsmax(String), "\rHB-AV\d | \yMigráció");
  new menu = menu_create(String, "migrate_h");
  new startstime[40]
  format_time(startstime, charsmax(startstime), "%H:%M:%S", Storage[started])
  new endtime[40]
  format_time(endtime, charsmax(endtime), "%m.%d %H:%M:%S", Storage[ending])

  menu_addtext2(menu, fmt("Elkezdve: \r%s \d| \wVárható Befejezés: \r%s", startstime, endtime))
  menu_addtext2(menu, fmt("\wStátusz: \r%i\d/\y%i", interv, LastInsertID))
  menu_addtext2(menu, fmt("\wFolyamat: %s", States[currstate]))

  if(currstate > 1)
  {
    menu_addblank2(menu)
    menu_addtext2(menu, fmt("\wFiók: \r%s\d(#%i)", Migrate[Username], Migrate[MigrateFromId]))
  }
  else
  {
    menu_addblank2(menu)
    menu_addblank2(menu)
  }

  menu_addblank2(menu)
  menu_addtext2(menu, fmt("\wVendég: \r%i \d\w Hibás fiók: \r%i \d| \wMigrált: \r%i", Storage[vendegskip], Storage[error], Storage[succes]))

  menu_display(id, menu, 0);
  return PLUGIN_HANDLED;
}
public migrate_h(id, menu, item) {

	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return;
	}
	
  
	new data[9], szName[64]
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName, charsmax(szName), callback);
	
	openMigrateMenu(id)
	return;
}
public getid(id)
{
  menuid = id;
  start_migration()
}
public start_migration()
{
  server_cmd("mp_roundtime 9999;mp_buytime 0;mp_give_player_c4 0;sv_restart 2")
  sk_chat(0, "A migráció alatt, az érintett szervereket le kell állítani!")
  sk_chat(0, "A migráció alatt, nem szabad megszakítani a kapcsolatot a szerverrel, különben kezdődik előről.")
  sk_chat(0, "Migráció elkezdődik 10 másodperc múlva.")

  Storage[started] = get_systime()

  Storage[ending] = Storage[started]+(LastInsertID*5)
  currstate = 0;
  openMigrateMenu(menuid);
  set_task(10.0, "get_datas")
  szamlalo()
}
public szamlalo()
{
  masodperc++;
  set_task(1.0, "szamlalo")
}
public get_datas()
{
  if(interv >= LastInsertID+1)
  {
    new MinuteString[80]
		easy_time_length(masodperc, timeunit_seconds, MinuteString, charsmax(MinuteString));
    sk_chat(0, "A migráció befejeződött. [Migrált fiókok száma: %i | Hibás fiókok száma: %i]", Storage[succes], Storage[error])
    sk_chat(0, "Migráció további adatai: [Vendég fiókok: %i | Migráció hossza: %s]", Storage[vendegskip], MinuteString)
  }
  static Query[20048];
  new Data[1];

  currstate = 1;
  openMigrateMenu(menuid)
  Data[0] = 0

  formatex(Query, charsmax(Query), "SELECT * FROM `herboy_regsystem` WHERE `id` = ^"%i^"", interv);
  SQL_ThreadQuery(g_SqlMigrateFrom, "queryget_datas", Query, Data, 2);
}
public queryget_datas(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime){
  if( FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED ){
    log_amx("%s", Error);
    sk_chat(0, "%s", Error);
    return;
  }
  new id = Data[0], tempaccount, found = SQL_NumRows(Query);

  if(found == 1)
  {
    tempaccount = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "is_tempaccount"));
    if(tempaccount != 1)
    {
      SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Username"), Migrate[Username], 33);
      SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "RegisterID"), Migrate[RegID], 33);
      SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "RegisterIP"), Migrate[RegIP], 33);
      SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "RegisterName"), Migrate[Regname], 33);
      SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "RegisterDate"), Migrate[Regdate], 33);
      SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Password"), Migrate[Password], 33);
      SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Email"), Migrate[Email], 33);
      SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "LastLoginIP"), Migrate[LastIP], 33);
      SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "LastLoginID"), Migrate[LastID], 33);
      SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "LastLoginName"), Migrate[LastName], 33);
      Migrate[playtime] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "PlayTime"));
      Migrate[premiumpont] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "PremiumPoint")); 
    }
    else SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "LastLoginName"), Migrate[Username], 33);

    Migrate[MigrateFromId] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "id"));

    if(tempaccount != 1)
      set_task(0.1, "SearchAccount")
    else
    {
      DelProf(Migrate[MigrateFromId])
      Storage[vendegskip]++;
      Storage[ending]-=4;
      currstate = 9;
      openMigrateMenu(menuid)
      sk_chat(0, "Fiók: %s(#%i) átlépve mivel vendégfiók.", Migrate[Username], Migrate[MigrateFromId])
      
      goToNext()
    }
  }
  else
  {
    Storage[error]++;
    Storage[ending]-=4;
    currstate = 9;
    openMigrateMenu(menuid)
    sk_chat(0, "Fiók: (#%i) átlépve mivel nem létezik.", interv)
    
    goToNext()
  }
}
public SearchAccount()
{
  static Query[20048];
  new Data[1];
  currstate = 2;
  openMigrateMenu(menuid)
  Data[0] = 0

  formatex(Query, charsmax(Query), "SELECT * FROM `herboy_regsystem` WHERE `Username` = ^"%s^"", Migrate[Username]);
  SQL_ThreadQuery(g_SqlMigrateTo, "SearchAccountquery", Query, Data, 2);
}
public SearchAccountquery(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime){
  if( FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED ){
    log_amx("%s", Error);
    sk_chat(0, "%s", Error);
    return;
  }
  new id = Data[0], tempsteamid[33], temppass[33], found = SQL_NumRows(Query);

  if(found == 1)
  {
    Migrate[MigrateToId] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "id"));
    SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "LastLoginID"), tempsteamid, 33);
    SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Password"), temppass, 33);

    if(equal(tempsteamid, Migrate[LastID]) || equal(temppass, Migrate[Password]))
      set_task(0.1, "UpdateOldToNew")
    else
    {
      Storage[error]++;
      Storage[ending]-=3;
      sk_log("deletedaccounts", fmt("Fsz: %s(#%i) | Jsz: %s | LID: %s | LIP: %s | PP: %i | PT: %i",Migrate[Username], Migrate[MigrateFromId], Migrate[Password], Migrate[LastID], Migrate[LastIP], Migrate[premiumpont], Migrate[playtime]))
      sk_chat(0, "^3%s^1(#%i) egyező felhasználónév, de nem egyező RegID miatt átlépve.", Migrate[Username], Migrate[MigrateFromId])
      currstate = 8;
      openMigrateMenu(menuid)
      goToNext()
    }
  }
  else
    InsertAccountWithOldDatas()
}
public UpdateOldToNew(){
  new sTime[64];
  formatCurrentDateAndTime(sTime, charsmax(sTime));
	static Query[10048];
	new Len;
	
	Len += formatex(Query[Len], charsmax(Query), "UPDATE `herboy_regsystem` SET ");
	Len += formatex(Query[Len], charsmax(Query)-Len, "Email = ^"%s^", ", Migrate[Email]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "PremiumPoint = PremiumPoint + ^"%i^", ", Migrate[premiumpont]);
	Len += formatex(Query[Len], charsmax(Query)-Len, "LastLoginName = ^"%s^", ", Migrate[LastName])
  Len += formatex(Query[Len], charsmax(Query)-Len, "PlayTime = PlayTime + ^"%i^", ", Migrate[playtime])
  Len += formatex(Query[Len], charsmax(Query)-Len, "LoginKey = ^"0^", ")
  Len += formatex(Query[Len], charsmax(Query)-Len, "NeedPassChange = ^"1^", ")
  Len += formatex(Query[Len], charsmax(Query)-Len, "MigratedOrInserted = ^"MigHB%s^", ", sTime)
	Len += formatex(Query[Len], charsmax(Query)-Len, "OldAccId = ^"%i^" WHERE `id` =  %d;", Migrate[MigrateFromId], Migrate[MigrateToId]);
	
	SQL_ThreadQuery(g_SqlMigrateTo, "queryupdate", Query);
}
public queryupdate(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime){
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) {
		log_amx("%s", Error);
    sk_chat(0, "%s", Error);
		return;
	}
  else
  {
    Storage[succes]++;
    DelProf(Migrate[MigrateFromId])
    sk_chat(0, "^3%s^1(#%i) fiók sikeresen átmigrálva.", Migrate[Username], Migrate[MigrateFromId])
    currstate = 7;
    Migrate[MigrateToId] = 0;
    openMigrateMenu(menuid)
    Migrate[Username] = EOS;
    set_task(0.1, "goToNext")
  }
}
public InsertAccountWithOldDatas()
{
  new sTime[64];
  formatCurrentDateAndTime(sTime, charsmax(sTime));
  currstate = 3;
  openMigrateMenu(menuid)

  static Query[3072]
  formatex(Query, charsmax(Query), "INSERT INTO `herboy_regsystem` (`Username`, `Password`, `Email`, `LoginKey`, `RegisterName`, `RegisterIP`, `RegisterID`, `RegisterDate`, `LastLoginName`, `LastLoginID`, `LastLoginIP`, `PlayTime`, `PremiumPoint`, `NeedPassChange`, `MigratedOrInserted`, `OldAccId`) VALUES (^"%s^", ^"%s^",^"%s^",^"0^",^"%s^",^"%s^",^"%s^",^"%s^",^"%s^",^"%s^",^"%s^",^"%i^",^"%i^",^"1^",^"%s^",^"%i^")", 
  Migrate[Username], Migrate[Password], Migrate[Email], Migrate[Regname], Migrate[RegIP], Migrate[RegID], Migrate[Regdate], Migrate[LastName], Migrate[LastID], Migrate[LastIP], Migrate[playtime], Migrate[premiumpont], fmt("InsHB%s", sTime), Migrate[MigrateFromId])
  SQL_ThreadQuery(g_SqlMigrateTo, "QueryInsertOldData", Query);
}
public QueryInsertOldData(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime){
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) {
		log_amx("%s", Error);
    sk_chat(0, "%s", Error);
		return;
	}
  else
  {
    new getsqlid = SQL_GetInsertId(Query);
    DelProf(Migrate[MigrateFromId])
    sk_chat(0, "^3%s^1(#%i) fiók sikeresen beimportálva a ^3#%i id-ra.", Migrate[Username], Migrate[MigrateFromId], getsqlid)
    Storage[succes]++;
    Migrate[MigrateToId] = 0;
    currstate = 7;
    Migrate[Username] = EOS;
    set_task(0.1, "goToNext")
  }
}
public goToNext()
{
  interv++;
  currstate = 0;
  Migrate[MigrateToId] = 0;
  openMigrateMenu(menuid)
  set_task(0.1, "get_datas")
}
public DelProf(pid)
{
  static Query[3072]
  formatex(Query, charsmax(Query), "DELETE FROM `herboy_regsystem` WHERE `id` = %i;", pid);		
	SQL_ThreadQuery(g_SqlMigrateFrom, "q_set_data", Query);
}
public q_set_data(FailState, Handle:Query, Error[], Errcode, Data[], DataSize, Float:Queuetime)
{
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED) 
	{
		log_amx("%s", Error);
		return;
	}
}
