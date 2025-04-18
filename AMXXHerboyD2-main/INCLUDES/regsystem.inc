#if defined _regsystem_included
  #endinput
#endif

#define _regsystem_included

native sk_get_pp(id);
native sk_set_pp(id, amount);
native sk_get_RegisterDate(id, regdate[], len);
native sk_get_accountid(id);
native sk_get_logged(id);
native sk_set_autologin(id, set);
native sk_get_autologin(id);
native sk_get_playtime(id);
native get_user_adminlvl(id);

native sk_get_kills(id);
native sk_get_hs(id);
native sk_get_deaths(id);

native sk_set_kills(id, kills);
native sk_gset_hs(id, hss);
native sk_set_deaths(id, deaths);

forward Load_User_Data(id);
forward LoggedSuccesfully(id);

native set_user_lang(id, lang[]);
native user_next_lang(id);

native get_user_by_accountid(accountid);