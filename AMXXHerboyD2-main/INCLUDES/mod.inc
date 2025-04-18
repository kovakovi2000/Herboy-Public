#if defined _mod_included
  #endinput
#endif

#define _mod_included

native Float:get_user_dollar(id);
native Float:set_user_dollar(id, Float:amount);
native Float:add_user_dollar(id, Float:amount);
native sm_get_submodel(id, cswap);
native round_counts(rounds[]);
native hud_disabled_all(bool:disable);
native open_weapon_menu(id);
native sm_get_skindisabled(id);
native sm_get_recoilcontrol(id);
native sm_get_speclist(id);
native sm_get_revivesprite(id);
native sm_get_quakesounds(id);
native add_user_dollar_offline(id, Float:amount);
