#include <amxmodx>
#include <sk_utils>
#include <regsystem>
#include <mod>

#define PLUGIN "Coinflip"
#define VERSION "1.0"
#define AUTHOR "Kova"

new const MENUPREFIX[] = "\y[\r~|\wHerBoy\r|~\y] \w~";

new Float:StoredInFlip[33];
new CurrFlipArrayId[33];
new Array:aFlips;
enum _:FlipsStruct {
    FlipById,
    FlipByName[33],
    Float:FlipAmount,
    bool:FlipStatus,
}

public LoadUtils() {}

public plugin_init() {
    register_plugin(PLUGIN, VERSION, AUTHOR);

    register_clcmd("say /coinflip", "cmd_coinflip");
    register_clcmd("say /ermedobas", "cmd_coinflip");
    register_clcmd("SET_COINFLIP", "messagemode_coinflip");

    aFlips = ArrayCreate(FlipsStruct);
}

public plugin_precache()
{
    //countdown sounds
    precache_generic("sound/Herboynew/cp_win.wav");
    precache_generic("sound/Herboynew/cp_fail.wav");
    precache_generic("sound/Herboynew/big_lose_vu.wav");
    precache_generic("sound/Herboynew/jackpot.wav");
}

public cmd_coinflip(id)
{
    if(!sk_get_logged(id))
    {
        sk_chat(id, "^1Csak regisztrált és bejeletkezett játékosok tudják ezt használni.");
        return;
    }
    new Float:currDollar = get_user_dollar(id);
    new numString[8];
    new menu = menu_create(fmt("%s \yÉrmefeldobás^n\rDollarod:\w%3.2f$", MENUPREFIX, currDollar), "coinflip_handler");
    
    if(StoredInFlip[id] > 0)
        menu_additem(menu, fmt("\wÁltalad helyzett tét: \y[\w%3.2f$\y] \r(LEVÉTEL)", StoredInFlip[id]), "-1");
    else
        menu_additem(menu, fmt("\rTét kihelyezése \d(minimum 0.50$)"), "-2");
    
    new sizeofarray = ArraySize(aFlips);
    new flip[FlipsStruct];
    
    for(new i = 0; i < sizeofarray; i++)
    {
        ArrayGetArray(aFlips, i, flip);
        if(!flip[FlipStatus])
            continue;

        if(flip[FlipById] == id)
            continue;
        
        if(currDollar >= flip[FlipAmount])
        {
            num_to_str(i, numString, charsmax(numString));
            menu_additem(menu, fmt("\y[\w%3.2f$\y] \r- \w%s", flip[FlipAmount], flip[FlipByName]), numString);
        }
        else
        {
            menu_additem(menu, fmt("\d[\d%3.2f$\d] \d- \d%s", flip[FlipAmount], flip[FlipByName]), "-3");
        }
    }
    menu_display(id, menu);
}

public coinflip_handler(id, menu, item)
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
        case -2:
        {
            client_cmd(id, "messagemode SET_COINFLIP");
        }
        case -1:
        {
            new flip[FlipsStruct];
            ArrayGetArray(aFlips, CurrFlipArrayId[id], flip);
            if(flip[FlipStatus])
            {
                add_user_dollar(id, StoredInFlip[id]);
                new blank_flip[FlipsStruct];
                ArraySetArray(aFlips, CurrFlipArrayId[id], blank_flip);
                CurrFlipArrayId[id] = 0;
                StoredInFlip[id] = 0.0;
                sk_chat(id, "^1Sikersen leszedted a tétedet.");
            }
            else
            {
                sk_chat(id, "^1Ez már nincs kint.");
            }
        }
        default:
        {
            new flip[FlipsStruct];
            ArrayGetArray(aFlips, key, flip);

            if(!flip[FlipStatus])
            {
                sk_chat(id, "^1A kiválaszott tét már nem elérhető.");
                return PLUGIN_HANDLED;
            }
            if(get_user_dollar(id) < flip[FlipAmount])
            {
                sk_chat(id, "^1Nincs elég pénzed, hogy megjátszd ezt a tétet.");
                return PLUGIN_HANDLED;
            }

            new displayname[33];
            get_user_name(id, displayname, charsmax(displayname));

            //the accual amount: flip[FlipAmount]*2.0
            add_user_dollar(id, -flip[FlipAmount]);
            if(random(2) == 1)
            {
                //the one who put out the flip wins
                add_user_dollar(flip[FlipById], flip[FlipAmount]*2.0);
                sk_chat(0, "^4%s^1 megnyert ^4[^1^3%3.2f$^4] ^1értékben tétet ^4%s ^1ellen.", flip[FlipByName], flip[FlipAmount]*2.0, displayname);
                sk_log("coinflip", fmt("^4%s^1 megnyert ^4[^1^3%3.2f$^4] ^1értékben tétet ^4%s ^1ellen.", flip[FlipByName], flip[FlipAmount]*2.0, displayname));
                playsound(flip[FlipById], id, flip[FlipAmount]);
            }
            else
            {
                //the one who entered the flip wins
                add_user_dollar(id, flip[FlipAmount]*2.0);
                sk_chat(0, "^4%s^1 megnyert ^4[^1^3%3.2f$^4] ^1értékben tétet ^4%s ^1ellen.", displayname, flip[FlipAmount]*2.0, flip[FlipByName]);
                sk_log("coinflip", fmt("^4%s^1 megnyert ^4[^1^3%3.2f$^4] ^1értékben tétet ^4%s ^1ellen.", displayname, flip[FlipAmount]*2.0, flip[FlipByName]));
                playsound(id, flip[FlipById], flip[FlipAmount]);
            }


            
            flip[FlipStatus] = false;
            ArraySetArray(aFlips, key, flip);
            CurrFlipArrayId[flip[FlipById]] = 0;
            StoredInFlip[flip[FlipById]] = 0.0;
        }
    }

    return PLUGIN_CONTINUE;
}

public messagemode_coinflip(id)
{
    if(StoredInFlip[id] > 0)
        return PLUGIN_HANDLED;
    
    if(!sk_get_logged(id))
        return PLUGIN_HANDLED;

    new Float:fAmount, sInput[32];
    read_args(sInput, charsmax(sInput));
    remove_quotes(sInput);

    fAmount = str_to_float(sInput);
    if(fAmount < 0.50)
    {
        sk_chat(id, "^1A minimum tét érmefeldobáshoz^4 0.50$.");
        return PLUGIN_HANDLED;
    }
    else if(fAmount > get_user_dollar(id))
    {
        sk_chat(id, "^1Nincs annyi pénzed mit amennyit megadtál.");
        return PLUGIN_HANDLED;
    }

    add_user_dollar(id, -fAmount);
    StoredInFlip[id] = fAmount;
    new displayname[33];
    get_user_name(id, displayname, charsmax(displayname));

    new flip[FlipsStruct];
    flip[FlipById] = id;
    copy(flip[FlipByName], charsmax(flip[FlipByName]), displayname);
    flip[FlipAmount] = fAmount;
    flip[FlipStatus] = true;
    CurrFlipArrayId[id] = ArrayPushArray(aFlips, flip);

    sk_chat(id, "^1Sikeresen kihelyeztél egy érmefeldobást ^4%3.2f$^1-ért", fAmount);
    sk_chat(0,  "^4%s^1 érme feldobást hozott létre ezzel a téttel: ^4[^1^3%3.2f$^4] ^1(^4/coinflip^1)", displayname, fAmount);
    return PLUGIN_CONTINUE;
}

public playsound(winner, loser, Float:amount)
{
    if(amount > 1000.0)
    {
        client_cmd(winner,"spk Herboynew/jackpot.wav");
        client_cmd(loser, "spk Herboynew/big_lose_vu.wav");
    }
    else
    {
        
        client_cmd(winner,"spk Herboynew/cp_win.wav");
        client_cmd(loser,"spk Herboynew/cp_fail.wav");
    }
}

public client_putinserver(id)
{
    CurrFlipArrayId[id] = 0;
    StoredInFlip[id] = 0.0;
}

public client_disconnected(id)
{
    if(StoredInFlip[id] == 0)
        return;
    add_user_dollar(id, StoredInFlip[id]);
    new blank_flip[FlipsStruct];
    ArraySetArray(aFlips, CurrFlipArrayId[id], blank_flip);
    CurrFlipArrayId[id] = 0;
    StoredInFlip[id] = 0.0;
}

public plugin_end()
{
    ArrayDestroy(aFlips);
}