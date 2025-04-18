#if defined _ammoclip_included
  #endinput
#endif

#define _ammoclip_included

/**
 * Ezzel tudod lekérdezni, hogy mennyi ammo lett ellőve a tárból.
 *
 * @note	Csak akkor fog értéket vissza adni ha az adott körben már volt meghivva a callculate_user_ammo (manual vagy automatikusan)
 *
 * @param	index   A felhasználó entity indexe
 * @param	iwpn    A fegyver CSW_* defineja
 *
 * @return      Kilött golyók száma
 * @error       nincs hibalehetőség ha valid indexet adtál meg
 */
native get_user_shot_ammo(const index, const iwpn);

/**
 * Ezzel tudod kiszámoltatni, hogy mennyi ammot lött ki egy felhasználó
 *
 * @note	Ez a függvény nem ad vissza értéket csak elvégez egy számolást az összes fegyveren.
 *          Automatikus lefut ha a felhasználó eldob egy fegyvert, meghal vagy vége a körnek.
 *
 * @param	index   A felhasználó entity indexe
 * @param	iwpn    A fegyver CSW_* defineja
 *
 * @return      none
 * @error       A függvény nem ellenőrzi, hogy a játékos csatlakozva van és él-e, ez a te dolgod!
 */
native callculate_user_ammo(const index);

/**
 * Ezzel tudod kinullázni az ellőt töltények számát ha új skint szeretél fel a fegyverre.
 *
 * @note	Kinullázza a kilött töltények számát a körben és felkészül a további számolásra.
 *          Ez automatikusan lefut minden játékos spawnolásánál azt összes fegyverre.
 *
 * @param	index   A felhasználó entity indexe
 * @param	iwpn    A fegyver CSW_* defineja
 *
 * @return      none
 * @error       A függvény nem ellenőrzi, hogy a játékos csatlakozva van és él-e, ez a te dolgod!
 */
native restart_user_shot_ammo(const index, const iwpn);

