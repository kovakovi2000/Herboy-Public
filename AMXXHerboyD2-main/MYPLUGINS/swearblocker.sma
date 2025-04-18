#include <amxmodx>
#include <amxmisc>
#include <regex>
#include <sk_utils>

#define PLUGIN "Swearing block"
#define VERSION "1.0"
#define AUTHOR "Kova"

#define REGEX_COUNT 4
new regex_pattern[REGEX_COUNT][] = {
    "((?:(?<![hH])[aAáÁ@4]+([\d\W\s_\.,]{0,3})[nN]+([\d\W\s_\.,]{0,3})[yYzZ]+([\d\W\s_\.,]{0,3})([jJiI]+)?([aAáÁ@4uUúÚüÜ]+|([uUúÚüÜ]?+[cC]+([\d\W\s_\.,]{0,3})[iI!]+([\d\W\s_\.,]{0,3})))([\d\W\s_kK]{0,3})(?<!:)[dD]+)|(?:(?<![hH])[aAáÁ@4]+([\d\W\s_\.,]{0,3})[nN]+([\d\W\s_\.,]{0,3})[yYzZ]+([\d\W\s_\.,]{0,3})([jJ]+)([\d\W\s_\.,]{0,3})[aAáÁ@4uUúÚüÜ]+))",
    "(?:(?<![a-zA-Z])[aAáÁ@4]+([\d\W\s_\.,]{0,3})[pPqQ]+([\d\W\s_\.,]{0,3})+[aAáÁ@4uUúÚüÜ]+((?<!:)[dD]+(?![Ii][Nn]|[lL]|avan|AVAN|[0oOóÓ])|[kK]+([\d\W\s_\.,]{0,3})[aAáÁ@4uUúÚüÜ]+([\d\W\s_\.,]{0,3})(?<!:d)[dD]+))",
    "(?:[cCzZ]+([\d\W\s_\.,]{0,3})[iI!yY]+([\d\W\s_\.,]{0,3})[gG]+([\d\W\s_\.,]{0,3})([aAáÁ@4]+([\d\W\s_\.,]{0,3})[nN]+([\d\W\s_\.,]{0,3})[yYzZ]+([\d\W\s_\.,]{0,3})|[0oOóÓ]+(?![rR]))(?![tT]))",
    "(?<![sS])(?:[zZ]+([\d\W\s_\.,]{0,3})[sS]+([\d\W\s_\.,]{0,3})[iI!]+([\d\W\s_\.,]{0,3})[dD]+([\d\W\s_\.,]{0,3})[0oOóÓ]+([\d\W\s_\.,]{0,3}))"
};
new regex_original[REGEX_COUNT][] = {
    "anyáz",
    "apáz",
    "cigányoz",
    "zsidóz"
};
new Regex:regex_handle[REGEX_COUNT];

new badpoint[33];

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR);

    register_clcmd("say", "say_hook");
    register_clcmd("say_team", "say_hook");

    for(new i = 0; i < REGEX_COUNT; i++)
        regex_handle[i] = regex_compile(regex_pattern[i]);
}

public client_putinserver(id)
{
    badpoint[id] = 0;
}

public say_hook(id)
{
    new Message[512];
    read_args(Message, charsmax(Message));
    remove_quotes(Message);

    for(new i = 0; i < REGEX_COUNT; i++)
        if(regex_match_c(Message, regex_handle[i]) > 0)
        {
            new au_name[33], au_steamid[33];
            get_user_name(id, au_name, charsmax(au_name));
            get_user_authid(id, au_steamid, charsmax(au_steamid));
            sk_log("swearlog", fmt("%s | %s | %s | %s", au_steamid, au_name, regex_original[i], Message));
            did_swear(id, i);
            return PLUGIN_HANDLED;
        }
    return PLUGIN_CONTINUE;
}

did_swear(id, index)
{
    sk_chat(id, "Nem szabad %sni!", regex_original[index]);
    switch(random(30))
    {
    case 0: client_cmd(id, "say Nem kaptam elég figyelmet, ezért itt próbálkozom.");
    case 1: client_cmd(id, "say Kicsinek bántottak ezért most itt élem ki magam.");
    case 2: client_cmd(id, "say Nem én vagyok az osztály menője, de itt az lehetek.");
    case 3: client_cmd(id, "say Ha a valós életben nem figyelnek rám, itt megpróbálok nagyot mondani.");
    case 4: client_cmd(id, "say Anyukám nem adott puszit lefekvés előtt, ezért most itt panaszkodom.");
    case 5: client_cmd(id, "say Anya nem adott csokit, és most itt vagyok mérges.");
    case 6: client_cmd(id, "say A házi feladatom nehéz, és most itt vezetem le a stresszt.");
    case 7: client_cmd(id, "say Ha már otthon nem hallgatnak rám, itt legalább figyelek rám valaki.");
    case 8: client_cmd(id, "say A kistestvérem megint helyedtem írkálta, hogy kicsi a kukim.");
    case 9: client_cmd(id, "say A kedvenc játékom a Minecraft, de sajnos kibannoltak onnan is.");
    case 10: client_cmd(id, "say Anyukám szólt, hogy mára már sok lesz a játék.");
    case 11: client_cmd(id, "say Apa nem értékelte, hogy a nappaliban építettem egy homokvárat.");
    case 12: client_cmd(id, "say Mindenki azt mondta, nyugodjak meg, de én nem!");
    case 13: client_cmd(id, "say A suliban sem figyeltek rám, úgyhogy most itt próbálom.");
    case 14: client_cmd(id, "say Az osztályban senki sem vett komolyan, de itt majd fog!");
    case 15: client_cmd(id, "say Túl sokszor falnak futottam gyerekkoromban, most meg itt eszetlenkedek.");
    case 16: client_cmd(id, "say Nem kaptam fagylaltot, és most mindenki szenved velem együtt.");
    case 17: client_cmd(id, "say Még mindig nem kaptam meg a Legó várat, amit 8 évesen kértem.");
    case 18: client_cmd(id, "say Jó, hogy csak a neten tudom eljátszani a kemény csávót, igaz?");
    case 19: client_cmd(id, "say Ez a harag valójában a suliban kapott rossz jegyek miatt van.");
    case 20: client_cmd(id, "say Az osztálytársaim kinevettek, és most itt próbálok kompenzálni.");
    case 21: client_cmd(id, "say Az apukám szerint nem tudok rendesen viselkedni.");
    case 22: client_cmd(id, "say A kedvenc mesémet elkapcsolták a tévében, most itt morcoskodom.");
    case 23: client_cmd(id, "say A kakaóm kihűlt, és ez nem tetszik!");
    case 24: client_cmd(id, "say A nagyfiúk mindig elvették a homokozóban a lapátom.");
    case 25: client_cmd(id, "say A kedvenc játékom összetört, most megpróbálom kiélni a bánatom.");
    case 26: client_cmd(id, "say Anyuék nem vették meg a boltban az a játékot amit szerettem volna.");
    case 27: client_cmd(id, "say A testvérem elvitte a kedvenc plüssöm, valaki segítsen.");
    case 28: client_cmd(id, "say Kicsit fáj, hogy a függönyöm is szebb, mint a személyiségem.");
    case 29: client_cmd(id, "say Mióta a kedvenc fagyizóm bezárt, nem találom a békét, ezért káromkodom.");
    }
}

public LoadUtils() {}
