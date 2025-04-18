/*
*	Thanks to voed and F@nt0M
*/

#include <amxmodx>
#include <reapi>

new const g_szSoundSelect[] = "common/wpn_select.wav";
new const g_szSoundDenySelect[] = "common/wpn_denyselect.wav";

new HookChain:g_iHookChainImpulseCommandsPost, HookChain:g_iHookChainStartSoundPre;

public plugin_init()
{
	register_plugin("Block WpnSelect Sound", "1.1", "w0w & F@nt0M");

	RegisterHookChain(RG_CBasePlayer_ImpulseCommands, "refwd_PlayerImpulseCommands_Pre", false);
	DisableHookChain(g_iHookChainImpulseCommandsPost = RegisterHookChain(RG_CBasePlayer_ImpulseCommands, "refwd_PlayerImpulseCommands_Post", true));
	DisableHookChain(g_iHookChainStartSoundPre = RegisterHookChain(RH_SV_StartSound, "refwd_SV_StartSound_Pre", false));
}

public refwd_PlayerImpulseCommands_Pre(id)
{
	if(get_member(id, m_afButtonPressed) & IN_USE)
	{
		EnableHookChain(g_iHookChainImpulseCommandsPost);
		EnableHookChain(g_iHookChainStartSoundPre);
	}
}

public refwd_PlayerImpulseCommands_Post(id)
{
	DisableHookChain(g_iHookChainImpulseCommandsPost);
	DisableHookChain(g_iHookChainStartSoundPre);
}

public refwd_SV_StartSound_Pre(const iRecipients, const iEntity, const iChannel, const szSample[], const flVolume, Float:flAttenuation, const fFlags, const iPitch)
{
	return strcmp(szSample, g_szSoundSelect) == 0 || strcmp(szSample, g_szSoundDenySelect) == 0 ? HC_SUPERCEDE : HC_CONTINUE;
}