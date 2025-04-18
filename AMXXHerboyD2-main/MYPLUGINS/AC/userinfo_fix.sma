#pragma semicolon 1

#include <amxmodx>
#include <reapi>

#define PLUGIN_NAME     "Safe Userinfo"
#define PLUGIN_VERSION  "1.0.4"
#define PLUGIN_AUTHOR   "the_hunter"

public plugin_init()
{
    register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);
    RegisterHookChain(RH_SV_CheckUserInfo, "OnCheckUserInfo");
    RegisterHookChain(RG_CSGameRules_ClientUserInfoChanged, "OnClientUserInfoChanged");
}

public OnCheckUserInfo(address, buffer)
{
    if ((!IsValidUtf8InfoBuffer(buffer))) {
        SetHookChainReturn(ATYPE_INTEGER, false);
        return HC_BREAK;
    }

    return HC_CONTINUE;
}

public OnClientUserInfoChanged(player, info[])
{
    if ((!IsValidUtf8InfoString(info))) {
        KickForInvalidUserInfo(player);
        return HC_BREAK;
    }

    return HC_CONTINUE;
}

KickForInvalidUserInfo(player)
{
    new bool:isPlayerConnected = (rh_get_client_connect_time(player) != 0);

    if (isPlayerConnected) {
        rh_drop_client(player, "Invalid userinfo");
    }
}

bool:IsValidUtf8InfoBuffer(buffer)
{
    const MAX_INFO_STRING = 256;

    new info[MAX_INFO_STRING];
    get_key_value_buffer(buffer, info, charsmax(info));

    return IsValidUtf8InfoString(info);
}

bool:IsValidUtf8InfoString(const info[])
{
    new i = 0;
    new bytes, codepoint;

    while (info[i] != EOS) {
        bytes = Utf8Codepoint(info, i, codepoint);

        if (bytes < 1) {
            return false;
        }

        // Reject control characters in the ranges U+0000–U+001F and U+007F–U+009F
        if (((codepoint >= 0x0000) && (codepoint <= 0x001F)) ||
            ((codepoint >= 0x007F) && (codepoint <= 0x009F))) {
            return false;
        }

        // Reject bidirectional text control characters
        if ((codepoint >= 0x202A) && (codepoint <= 0x202E)) {
            return false;
        }

        // Reject deprecated control characters
        if ((codepoint >= 0x206A) && (codepoint <= 0x206F)) {
            return false;
        }

        // Reject Line Separator and Paragraph Separator
        if ((0x2028 == codepoint) || (0x2029 == codepoint)) {
            return false;
        }

        i += bytes;
    }

    return true;
}

stock Utf8Codepoint(const string[], index, &codepoint)
{
    new curByte = string[index];

    if (EOS == curByte) {
        return 0;
    }

    // 4-byte UTF-8 codepoint
    if (0xF0 == (0xF8 & curByte)) {
        if ((EOS == string[(index + 1)]) || (EOS == string[(index + 2)]) || (EOS == string[(index + 3)])) {
            return 0; // Incomplete sequence
        }

        if ((0x80 != (0xC0 & string[(index + 1)])) ||
            (0x80 != (0xC0 & string[(index + 2)])) ||
            (0x80 != (0xC0 & string[(index + 3)]))) {
            return 0; // Invalid continuation byte
        }

        codepoint = (((0x07 & curByte) << 18) | ((0x3F & string[(index + 1)]) << 12) |
                    ((0x3F & string[(index + 2)]) << 6) | (0x3F & string[(index + 3)]));

        if ((codepoint < 0x010000) || (codepoint > 0x10FFFF)) {
            return 0; // Out of valid Unicode range
        }

        return 4;
    }

    // 3-byte UTF-8 codepoint
    if (0xE0 == (0xF0 & curByte)) {
        if ((EOS == string[(index + 1)]) || (EOS == string[(index + 2)])) {
            return 0; // Incomplete sequence
        }

        if ((0x80 != (0xC0 & string[(index + 1)])) || (0x80 != (0xC0 & string[(index + 2)]))) {
            return 0; // Invalid continuation byte
        }

        codepoint = (((0x0F & curByte) << 12) | ((0x3F & string[(index + 1)]) << 6) | (0x3F & string[(index + 2)]));

        if ((codepoint >= 0xD800) && (codepoint <= 0xDFFF)) {
            return 0; // Surrogate pairs are not allowed
        }

        if ((codepoint < 0x0800) || (codepoint > 0xFFFF)) {
            return 0; // Out of valid Unicode range
        }

        return 3;
    }

    // 2-byte UTF-8 codepoint
    if (0xC0 == (0xE0 & curByte)) {
        if (EOS == string[(index + 1)]) {
            return 0; // Incomplete sequence
        }

        if (0x80 != (0xC0 & string[(index + 1)])) {
            return 0; // Invalid continuation byte
        }

        codepoint = (((0x1F & curByte) << 6) | (0x3F & string[(index + 1)]));

        if ((codepoint < 0x0080) || (codepoint > 0x07FF)) {
            return 0; // Out of valid Unicode range
        }

        return 2;
    }

    // 1-byte UTF-8 codepoint
    if ((curByte > 0) && (curByte <= 0x007F)) {
        codepoint = curByte;
        return 1;
    }

    return 0; // Invalid start byte
}
