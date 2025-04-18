#include <amxmodx>
#include <reapi>

#define PLUGIN  "ReloadSound Fix"
#define AUTHOR  "Karaulov"
#define VERSION "1.1"

new g_iReloadSound = 0;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	RegisterHookChain(RG_CBasePlayerWeapon_DefaultReload, "DefaultReload_Pre", false);
	RegisterHookChain(RG_CBasePlayerWeapon_DefaultReload, "DefaultReload_Post", true);
	
	g_iReloadSound = get_user_msgid("ReloadSound");
	set_msg_block(g_iReloadSound, BLOCK_SET);
}

public DefaultReload_Pre(const item, iClipSize, iAnim, Float:fDelay)
{
	set_msg_block(g_iReloadSound, BLOCK_SET);
	return HC_CONTINUE;
}

public DefaultReload_Post(const item, iClipSize, iAnim, Float:fDelay)
{
	if (GetHookChainReturn(ATYPE_INTEGER))
	{
		new wid = get_member(item, m_iId);
		new pid = get_member(item, m_pPlayer);
		
		for(new iListener = 1; iListener <= MaxClients; iListener++)
		{
			if (is_user_connected(iListener))
			{
				if (iListener != pid)
				{
					if (wid == CSW_M3 || wid == CSW_XM1014)
					{
						rh_emit_sound2(pid, iListener, CHAN_STREAM, "weapons/generic_shot_reload.wav", 1.0, 1.8, 0, 94 + random(16))
					}
					else
					{
						rh_emit_sound2(pid, iListener, CHAN_STREAM, "weapons/generic_reload.wav", 1.0, 1.8, 0, 94 + random(16))
					}
				}
			}
		}
	}
	return HC_CONTINUE;
}