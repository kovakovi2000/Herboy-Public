#if defined _bansys_included
  #endinput
#endif

#define _bansys_included

/**
 * Itt azt az időt tudod megadni, hogy mennyi időnként kérje le SQL-ből a bannok, és muteok lejáratát
 */
#define BAN_MUTECHECKINTERVAL 30.0 

/**
 * Ezzel tudod leelenörizni, hogy egy játékos már lelett-e ellenörízve vagy sem.
 *
 * @note	Ameddig ez nem ment végbe addig a nincs a felhasználonak UniqueKey32-je.
 *
 * @param	id  A felhasználó entity indexe
 *
 * @return      1 ha felhasználó már ellenörizve lett, amúgy pedig 0
 * @error       Ha helytelen felhasználó indexet adsz át a hiba el lesz dobva és a
 *              fügvény 0 ad vissza.

 */
native skbs_is_Validated(id);

/**
 * Vissza adja egy 36 karakter hosszú azonosítot mely a felhasználohoz tartozik.
 *
 * @note	Fontos hogy ez nem 100%-ig egyedi, lehetséges hogy megváltozik ezért fontos
 *          hogy az ebből adodó hibák le legyenek kezelve!
 *
 * @param	id    A felhasználó entity indexe
 * @param	ukey  A kulcs string formátumban
 * @param	len   a cél string hossza
 *
 * @return      36 hosszú string számokból és betükből
 * @error       Ha helytelen felhasználó indexet adsz át a hiba el lesz dobva és a
 *              fügvény 0 ad vissza.

 */
native skbs_get_UniqueKey32(id, ukey[], len);

//----------------------------------------------------------------------------------
//----------------------------------------------------------------------------------

/**
 * Amikor egy felhasználó feljön, putinserver-nél hivodik meg. Ekkor a felhasználó
 * még nem tud kommunikálni senkivel sem a szerveren és nincs UniqueKey32-je.
 *
 * @note	Ha ez alatt az időszak alatt probál meg kommunikálni akkor meghívodik
 *          a skbs_user_communicate_validating fügvény melyben figyelmeztethejük
 *          a felhasználót hogy még nem lett jováhagyva a csatlakozása.
 *
 * @param	id  A felhasználó entity indexe
 */
forward skbs_user_started_validating(id);

/**
 * Amikor egy felhasználónak magas a pingje akkor esetenként hamis-pozítiv lehet
 * az ellenörzés ezért itt kijuk neki hogy kicsit tovább tart a pingje miatt.
 *
 * @note	Nem garantálja hogy nagyon magas ping esetén feltétlen nem lesz
 *          hamis-pozítiv az eredmény, de jelentösen csökkenti az esélyét.
 *
 * @param	id  A felhasználó entity indexe
 */
forward skbs_user_extendedping_validating(id);

/**
 * Ha egy felhasználónak megpróbál kommunikálni ellenörzés során akkor ez hívodik
 * meg és tudjuk figyelmeztetni hogy még ellenörzés alatt van.
 *
 * @param	id  A felhasználó entity indexe
 */
forward skbs_user_communicate_validating(id);

/**
 * A felhasználó sikeresen le lett ellenörízve, mostmár szabadon kommunikálhat
 *
 * @note	Itt a felhasználó már rendelkezik a UniqueKey32-el!
 *
 * @param	id  A felhasználó entity indexe
 */
forward skbs_user_validated_success(id);

/**
 * A felhasználó valamilyen oknál fogva nem tudta ellenörizni a plugin
 *
 * @note	Nem feltétlen jelenti hogy a felhasználó hibájából kifolyólag történt.
 *
 * @param	id  A felhasználó entity indexe
 */
forward skbs_user_validated_falied(id);


//----------------------------------------------------------------------------------
//----------------------------------------------------------------------------------

/**
 * Ennek meghívsával lehet egy sql log-olt kickelést elvégezni
 *
 * @note	Ezt meghívja már alapból a banredszer amikor valaki bannalatt visszajön
 *          avagy ha steamid changerrel próbálkozik valaki
 *
 * @param	victim  A játékos aki ki lesz kickelve
 * @param	admin   Aki által ki lesz kickelve a felhasználó, 0 ha a szerver az
 * @param	reason  Az indok amivel ki lett kickelve
 *
 * @return      1 ha felhasználó sikeresen lett kickelve, máskülönben 0
 * @error       Ha helytelen felhasználó indexet adsz át a hiba el lesz dobva és a
 *              fügvény 0 ad vissza.
 */
native skbs_kick_user(victim, admin, reason[]);

/**
 * Ennek meghívsával lehet kitiltani valakit
 *
 * @note	ha baninfót, kép infórmációt, vagy egyéb adatot szeretnél megjeleniteni
 *          akkor az még NE EZZELŐTT tedd meg, minden ilyet írj a skbs_user_baning_*-ba
 *
 * @param	victim  A játékos aki ki lesz bannolva
 * @param	admin   Aki által ki lesz bannolva a felhasználó, 0 ha a szerver az
 * @param	time    Az idő percben megadva
 * @param	reason  A kitiltás indoka
 *
 * @return      1 ha felhasználó sikeresen lett bannolva, máskülönben 0
 * @error       Ha helytelen felhasználó indexet adsz át a hiba el lesz dobva és a
 *              fügvény 0 ad vissza.
 */
native skbs_ban_user(victim, admin, time, reason[]);

/**
 * Ennek meghívsával lehet némítani valakit
 *
 * @note	ha szeretnél bármilyen infórmációt megjelenítani ezzel kapcsolatban akkor
 *          azt megteheted ez elött és után is bármikor
 *
 * @param	victim  A játékos aki le lesz némítva
 * @param	admin   Aki által le lesz némítva a felhasználó, 0 ha a szerver az
 * @param	reason  Az indok amivel le lesz némítva
 * @param	time    Az idő percben
 * @param	type    Chat - 1, Voice - 2, Mindkettő - 3
 *
 * @return      1 ha felhasználó sikeresen le lett némítva, máskülönben 0
 * @error       Ha helytelen felhasználó indexet adsz át a hiba el lesz dobva és a
 *              fügvény 0 ad vissza.
 */
native skbs_mute_user(victim, admin, reason[], time, type);

//----------------------------------------------------------------------------------
//----------------------------------------------------------------------------------

/**
 * skbs_ban_user után hívodik meg az első kép elkészülése ELTÖTT
 *
 * @param	id  A felhasználó entity indexe
 */
forward skbs_user_baning_screenshot1(id);

/**
 * skbs_ban_user után hívodik meg az második kép elkészülése ELTÖTT
 *
 * @param	id  A felhasználó entity indexe
 */
forward skbs_user_baning_screenshot2(id);

/**
 * skbs_ban_user után hívodik meg az harmadik kép elkészülése ELTÖTT
 *
 * @param	id  A felhasználó entity indexe
 */
forward skbs_user_baning_screenshot3(id);

/**
 * skbs_ban_user avagy skbs_user_banned_join UTÁN hívodik meg, itt írd ki
 * a felhasználónak a console-jába a bannal kapcsolatos infókat!
 *
 * @param	admin_id      Az admin entity indexe
 * @param	banned_id     Az kitilott entity indexe
 * @param	bannednick    A kitiltott neve
 * @param	bannedid_ip   A kitiltott IP címe
 * @param	BanTime       A kitiltás hossza
 * @param	Lejarat       A kitiltás lejáratának ideje
 * @param	Letrehozva    A kitiltás létrejöttének ideje
 * @param	AdminName     A kitiltó admin neve
 * @param	banreason     A kitiltás indoka
 */
forward skbs_user_baning_baninfo(admin_id, banned_id, bannednick[], bannedid_ip[], BanTime[], Lejarat[], Letrehozva[], AdminName[], banreason[], uuid[]);
//----------------------------------------------------------------------------------
//----------------------------------------------------------------------------------

/**
 * Ha egy olyan játékos lép fel a szerverre aki már bannolva van valamiért akkor
 * hívodik meg ez a fügvény (tiltás alatt).
 *
 * @note	Itt még nem lett lekick-elve a felhasználó, így lekérdezhetsz 
 *          róla adatokat nyugodtan
 *
 * @param	id      A játékos aki tiltás alatt van
 * @param	reason  A kitiltás idoka
 */
forward skbs_user_banned_join(bannedid, reason[]);

/**
 * Ha egy olyan játékos próbál meg kommunikálni aki némítás alatt van akkor
 * hívodik meg ez a fügvény.
 *
 * @note	Semmilyen plugin ez alatt nem érzékeli a sayhook-ban ezután a némítást
 *
 * @param	id            A játékos aki némítás alatt van
 * @param	mute_reason   A némítás indoka
 * @param	adminname     A némító admin
 * @param	mute_length   A némítás hossza
 * @param	MuteType      A némítás tipusa
 */
forward skbs_user_communicate_muted(id, mute_reason[], adminname[], mute_length[], MuteType[]);

//----------------------------------------------------------------------------------
//----------------------------------------------------------------------------------

/**
 * Ha egy felhasználó ki lett kickelve a skbs_kick_user-el
 *
 * @note	itt a felhasználó még fent van a szerveren így kérhetsz le adatokat róla
 *
 * @param	victim  A játékos aki ki lett kickelve
 * @param	admin   az admin aki kickelte, 0 ha a szerver ez
 * @param	reason  Az indok amivel kickelve lett
 */
forward skbs_user_kicked(victim, admin, reason[]);

/**
 * Ha egy felhasználó ki lett kickelve a a plugin által steamidchanger miatt
 *
 * @note	itt a felhasználó még fent van a szerveren így kérhetsz le adatokat róla
 *
 * @param	victim  A játékos aki ki lett kickelve
 */
forward skbs_user_kicked_steamidchanger(victim);

//----------------------------------------------------------------------------------
//----------------------------------s------------------------------------------------

/**
 * Ha valakinek lejár a banja akkor ez meghívodik
 * 
 * @param	victim_name     A volt kitiltott játékos neve
 * @param	reason          Az indok amivel ki volt tiltva a felhasználó
 */
forward skbs_user_ban_expired(victim_name[], reason[]);

/**
 * Ha valakinek lejár a banja akkor ez meghívodik
 * 
 * @param	victim_name     A volt kitiltott játékos neve
 * @param	admin_name      A kitoltó admin neve
 * @param	time_length     A kitiltás hossza percben
 * @param	reason          Az indok amivel ki volt tiltva a felhasználó
 */
forward skbs_user_unbanned(admin_id, admin_name[], victim_name[], reason[]);

/**
 * Ha valakinek lejár a banja akkor ez meghívodik
 * 
 * @param	victim_name     A volt kitiltott játékos neve
 * @param	admin_name      A kitoltó admin neve
 * @param	time_length     A kitiltás hossza percben
 * @param	reason          Az indok amivel ki volt tiltva a felhasználó
 */
forward skbs_user_unmuted(admin_id, admin_name[], victim_name[], reason[]);

/**
 * Ha valakinek lejár a némítása akkor ez meghívodik
 * 
 * @param	victim_name     A volt némított játékos neve
 * @param	reason          Az indok amivel le lett némítva a felhasználó
 */
forward skbs_user_mute_expired(victim_name[], reason[]);

/**
 * Ez akkor hívódik meg, amikor a játékos ki lett tiltva, de még nem lett kirúgva, és kép sem készült.
 * Itt tudod megadni, hogy mi látszódjon neki chaten.
 *
 * @param	bannedid    A felhasználó entity indexe
 * @param	admin_id    Az admin entity indexe
 * @param	bantime     A kitiltás hossza
 * @param	banreason   A kitiltás indoka
 */
forward skbs_user_ban_chatinfo(bannedid, admin_id, bantime[], banreason[]);

/**
 * Itt tudod megadni, hogy mi látszódjon chaten a némítás pillanatában.
 *
 * @param	muteid      A felhasználó entity indexe
 * @param	admin_id    Az admin entity indexe
 * @param	mutetime    A némítás hossza
 * @param	mutereason  A némítás indoka
 * @param	mutetype    A némítás tipusa
 */
forward skbs_user_mute_chatinfo(muteid, admin_id, mutetime[], mutereason[], mutetype[]);

native is_anyone_scanning();