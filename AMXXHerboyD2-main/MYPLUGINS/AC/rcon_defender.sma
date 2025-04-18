#include <amxmodx>
#include <cstrike>
#include <fakemeta>
#include <hamsandwich>
#include <engine>

public plugin_init()
{
  register_plugin("[SMOD] RCON DEFENDER", "1.0", "shedi")
  set_task(4.0, "RconDefender",_,_,_,"b")
}
public RconDefender()
{
  new rconnewpassword[50]
  format(rconnewpassword, 50, "[%04x]%04x%03x[%04x]", random(0x7fffffff), random(0xffff), random(0xfff), (random(0x3fff) | 0x8000));
  server_cmd("rcon_password ^"%s^"", rconnewpassword)
}
