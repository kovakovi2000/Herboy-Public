#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <engine>
#include <fun>
#include <hamsandwich>
#include <fakemeta>
#include <xs>
#include <fakemeta_util>

public plugin_init()
{
  register_plugin("Specific Map Disable", "v1", "shedi")
  set_task(5.0, "CheckMap",_,_,_, "c")
}
public CheckMap()
{
  new MapName[33];
  get_mapname(MapName, 33)

  unpause("c", "sebzesuj.amxx")
  unpause("c", "MultiJumpWithoutBGS.amxx")

  if(equali(MapName, "cs_estate"))
  {
    pause("c", "sebzesuj.amxx")
    client_print_color(0, print_team_default, "^4|^3Avatár^4| ^1Ezen a pályán a ^3sebzésjelző^1 kikapcsolásra került!")
  }
  else if(equali(MapName, "cs_deagle5"))
  {
    pause("c", "MultiJumpWithoutBGS.amxx")
    client_print_color(0, print_team_default, "^4|^3Avatár^4| ^1Ezen a pályán a ^3duplaugrás^1 kikapcsolásra került!")
  }
  else if(equali(MapName, "cs_assault") || equali(MapName, "cs_alpin"))
  {
    pause("c", "sebzesuj.amxx")
    client_print_color(0, print_team_default, "^4|^3Avatár^4| ^1Ezen a pályán a ^3sebzésjelző^1 kikapcsolásra került!")
  }
}
