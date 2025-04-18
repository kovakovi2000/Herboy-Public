#if defined _scan_included
  #endinput
#endif

#define _scan_included

native get_user_scan(index);
native get_user_scannering(index);
native get_user_scanner(indexid);
native get_user_scanby(index);
native get_user_scannerselected(index);
native reset_user_scannering(index);
native set_user_scan_judget(index, jud);
native push_scan(index);