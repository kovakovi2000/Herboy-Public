
#include <amxmodx>
#include <sqlx>
#include <cstrike>
#include <fakemeta>
#include <sk_utils>


public plugin_init()
{
  register_plugin("CountDown", "v1", "shedi")

  set_task(1.0, "CheckTimes", _,_,_, "b")
}
new visszaszamlalo = 25;
public CheckTimes()
{
  new minutes, hours, seconds
  time(hours, minutes, seconds)

  if(hours == 23 && minutes == 00 && seconds == 00)
  {
    sk_chat(0, "^3[FELHÍVÁS]^1 A karbantartás^3 30 PERC^1 múlva ^4ELKEZDŐDIK!")
    sk_chat(0, "^3[FELHÍVÁS]^1 A karbantartás^3 30 PERC^1 múlva ^4ELKEZDŐDIK!")
    sk_chat(0, "^3[FELHÍVÁS]^1 A karbantartás^3 30 PERC^1 múlva ^4ELKEZDŐDIK!")
    sk_chat(0, "^3[FELHÍVÁS]^1 A karbantartás^3 30 PERC^1 múlva ^4ELKEZDŐDIK!")
  }
  if(hours == 23 && minutes == 20 && seconds == 00)
  {
    sk_chat(0, "^3[FELHÍVÁS]^1 A karbantartás^3 10 PERC^1 múlva ^4ELKEZDŐDIK!")
    sk_chat(0, "^3[FELHÍVÁS]^1 A karbantartás^3 10 PERC^1 múlva ^4ELKEZDŐDIK!")
    sk_chat(0, "^3[FELHÍVÁS]^1 A karbantartás^3 10 PERC^1 múlva ^4ELKEZDŐDIK!")
    sk_chat(0, "^3[FELHÍVÁS]^1 A karbantartás^3 10 PERC^1 múlva ^4ELKEZDŐDIK!")
  }
  if(hours == 23 && minutes == 25 && seconds == 00)
  {
    sk_chat(0, "^3[FELHÍVÁS]^1 A karbantartás^3 5 PERC^1 múlva ^4ELKEZDŐDIK!")
    sk_chat(0, "^3[FELHÍVÁS]^1 A karbantartás^3 5 PERC^1 múlva ^4ELKEZDŐDIK!")
    sk_chat(0, "^3[FELHÍVÁS]^1 A karbantartás^3 5 PERC^1 múlva ^4ELKEZDŐDIK!")
    sk_chat(0, "^3[FELHÍVÁS]^1 A karbantartás^3 5 PERC^1 múlva ^4ELKEZDŐDIK!")
  }
  if(hours == 23 && minutes == 30 && seconds == 30)
  {
    startvisszaszamlalas()
  }
}
public startvisszaszamlalas()
{
  sk_chat(0, "^3[FELHÍVÁS]^1 A szerver^3 %i^4 másodperc^1 múlva leáll!", visszaszamlalo)

  if(visszaszamlalo == 1)
    server_cmd("changelevel de_dust2")

  visszaszamlalo--;
  set_task(1.0, "startvisszaszamlalas")
}
public LoadUtils()
{}
