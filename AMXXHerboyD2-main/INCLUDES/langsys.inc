#if defined _langsys_included
#endinput
#endif

#define _langsys_included

enum _:lang_types
{
    lang_none = 0,
    lang_en = 1,
    lang_hu = 2,
    lang_ro = 3,
    lang_sk = 4,
    lang_sr = 5,
    lang_de = 6,
    lang_ua = 7
}


public get_lang_by_enum(langtype, slang[])
{
    switch(langtype)
    {
        case lang_en:
            copy(slang, 3, "en");
        case lang_hu:
            copy(slang, 3, "hu");
        case lang_ro:
            copy(slang, 3, "ro");
        case lang_sk:
            copy(slang, 3, "sk");
        case lang_sr:
            copy(slang, 3, "sr");
        case lang_de:
            copy(slang, 3, "de");
        case lang_ua:
            copy(slang, 3, "ua");
        default:
            copy(slang, 3, "en");
    }
}

public lang_types:get_enum_by_str(lang[])
{
    strtolower(lang);
    if (equal(lang, "en"))
        return lang_types:lang_en;
    else if (equal(lang, "hu"))
        return lang_types:lang_hu;
    else if (equal(lang, "ro"))
        return lang_types:lang_ro;
    else if (equal(lang, "sk"))
        return lang_types:lang_sk;
    else if (equal(lang, "sr"))
        return lang_types:lang_sr;
    else if (equal(lang, "de"))
        return lang_types:lang_de;
    else if (equal(lang, "ua"))
        return lang_types:lang_ua;
    else
        return lang_types:lang_en; // default to English if language code is not recognized
}