#include <amxmodx>
#include <fakemeta>
#include <reapi>

new LastTracedPlayer = 0;

public plugin_init() {
    register_plugin("Flash Bug Fix", "1.0.0", "F@nt0M")
    RegisterHookChain(RG_RadiusFlash_TraceLine, "RadiusFlash_TraceLine_Post", true);
}

public RadiusFlash_TraceLine_Post(const player, const inflictor, const attacker, const Float:vecSrc[3], const Float:vecSpot[3], const tracehandle) {
    if (player != LastTracedPlayer) {
        LastTracedPlayer = player;
        return;
    }

    new Float:holdTime = Float:get_member(player, m_blindHoldTime);
    new Float:fadeTime = Float:get_member(player, m_blindFadeTime);
    if (holdTime == 0.0 || fadeTime == 0.0) {
        return;
    }

    new Float:fraction;
    get_tr2(tracehandle, TR_flFraction, fraction);
    if (fraction < 1.0) {
        return;
    }

    new Float:gameTime = get_gametime();
    new Float:startTime = Float:get_member(player, m_blindStartTime);
    new Float:endTime = startTime + holdTime + fadeTime;
    if (endTime <= gameTime) {
        return;
    }

    if ((holdTime + startTime - gameTime) > 0) {
        return;
    }

    new Float:ratio = (endTime - gameTime) / fadeTime;
    set_member(player, m_blindAlpha, Float:get_member(player, m_blindAlpha) * ratio);
    set_member(player, m_blindHoldTime, 0.0);
    set_member(player, m_blindFadeTime, fadeTime * ratio);
}