/*************************************************************************************************************

  Plugin: AMX Ejaculate
  Version: 0.2
  Author: KRoT@L

  0.1  Release
  0.2  Improved the code
       Renamed cvar amx_maxejaculations into "amx_ejaculate_max"
       Renamed cvar amx_ejaculate_admin into "amx_ejaculate_admins"
       Added cvars amx_ejaculate_active and amx_ejaculate_range
       Removed #define NO_CS_CZ (you can now ejaculate anywhere if "amx_ejaculate_range" is lower than 30)
       Added #define PRINT_TYPE to be able to change the type of information message (print_console or print_chat)


  Commands:

    ejaculate - ejaculates on a dead body or anywhere
    say /ejaculate_help - displays ejaculate help

    To ejaculate on a dead body or anywhere you have to bind a key to "ejaculate".
    Open your console and type: bind "key" "ejaculate"
    Example: bind "x" "ejaculate"
    Then stand still above a dead player, press your key and you'll ejaculate on him!
    You can control the direction of the semen with your mouse!

    Players can write "/ejaculate_help" in the chat to get some help.


  Cvars:

    amx_ejaculate_active <0|1> - disable/enable the plugin (default: 1)

    amx_ejaculate_admins <0|1> - disable/enable the usage of the plugin only for admins (default: 0)

    amx_ejaculate_max "3" - maximum number of times a player is allowed to ejaculate per each spawning

    amx_ejaculate_range "80" - maximum range between a dead body and a player who wants ejaculate (must be between 30 and 300)
    Note: Set to a value lower than 30 (MIN_RANGE) to be able to ejaculate anywhere you want.


  Requirement:

    AMX Mod 2010.1 or higher.


*************************************************************************************************************/

/******************************************************************************/
// If you change one of the following settings, do not forget to recompile
// the plugin and to install the new .amx file on your server.
// You can find the list of admin flags in the amx/examples/include/amxconst.inc file.

#define FLAG_EJACULATE      ADMIN_ALL
#define FLAG_EJACULATE_HELP ADMIN_ALL

// Mode of print for ejaculate info messages from the "ejaculate" command.
// Values are either "print_console", "print_chat" or "print_center".
#define PRINT_TYPE print_chat

// Edit here the minimal & maximal range value in units.
// Notes: This is used to check the distance between a player who wants ejaculate on a dead body.
// If the cvar "amx_ejaculate_range" is lower than MIN_RANGE, players can ejaculate anywhere.
#define MIN_RANGE 30
#define MAX_RANGE 300

/******************************************************************************/

#include <amxmodx>
#include <amxmisc>
#include <engine_stocks>
#include <sk_utils>

new g_iPlayerCounter[33]
new g_iPlayerEjaculationsNum[33]
new g_iPlayerOrigins[33][3]



#define MAX_COUNTER 10
#define TASKID_make_ejaculate 37931975

public plugin_precache() {

  new const szSoundFile[] = "sound/ejaculate/ejaculate.wav"
  if(file_exists(szSoundFile)) {
    precache_sound(szSoundFile[6])
  }
  else {
    log_amx("AMX Ejaculate: WARNING! Sound file ^"%s^" doesn't exist on the server.", szSoundFile)
  }
}
new g_cvarAmxEjaculateActive
new g_cvarAmxEjaculateAdmins
new g_cvarAmxEjaculateMax
new g_cvarAmxEjaculateRange
public plugin_init() {
  register_plugin("AMX Ejaculate","0.2","KRoT@L")
  register_clcmd("ejaculate", "ejaculate_on_player", FLAG_EJACULATE, "- ejaculates on a dead body or anywhere")
  register_clcmd("kivereshelp", "ejaculate_help", FLAG_EJACULATE_HELP, "- displays ejaculate help")
  g_cvarAmxEjaculateMax = register_cvar("amx_ejaculate_max", "3")
  g_cvarAmxEjaculateRange = register_cvar("amx_ejaculate_range", "80")
  register_event("ResetHUD", "reset_hud", "be")
  register_event("DeathMsg", "death_event", "a")
}

public client_putinserver(id) {
  g_iPlayerCounter[id] = 0
  g_iPlayerEjaculationsNum[id] = 0
}

public client_disconnected(id) {
  if(g_iPlayerCounter[id]) {
    reset_ejaculate(id)
  }
}

public ejaculate_on_player(id, iLevel) {
  if(g_iPlayerCounter[id]) {
    sk_chat(id, "Épp kivered valakire.")
    return PLUGIN_HANDLED
  }

  if(!is_user_alive(id)) {
    sk_chat(id, "Nem tudsz elélvezni ha halott vagy.")
    return PLUGIN_HANDLED
  }

  new iEjaculateMax = get_pcvar_num(g_cvarAmxEjaculateMax)
  if(g_iPlayerEjaculationsNum[id] >= iEjaculateMax) {
    sk_chat(id, "Nem tudsz többször elélvezni mint ^3%i^1", iEjaculateMax)
    return PLUGIN_HANDLED
  }

  new iEjaculateRange = get_pcvar_num(g_cvarAmxEjaculateRange)
  if(iEjaculateRange >= MIN_RANGE) {
    new iOrigin[3], iPlayers[32], iPlayersNum, iPlayer
    new iCurrentDistance, iDeadBody, iMinDistance = clamp(iEjaculateRange, MIN_RANGE, MAX_RANGE)

    if(iEjaculateRange > MAX_RANGE) {
      set_cvar_num("amx_ejaculate_range", MAX_RANGE)
    }

    get_user_origin(id, iOrigin)
    get_players(iPlayers, iPlayersNum, "bh")

    for(--iPlayersNum; iPlayersNum >= 0; iPlayersNum--) {
      iPlayer = iPlayers[iPlayersNum]
      iCurrentDistance = get_distance(iOrigin, g_iPlayerOrigins[iPlayer])
      if(iCurrentDistance < iMinDistance) {
        iMinDistance = iCurrentDistance
        iDeadBody = iPlayer
      }
    }

    if(iDeadBody > 0) {
      new szPlayerName[32]
      get_user_name(iDeadBody, szPlayerName, charsmax(szPlayerName))

      new szName[32]
      get_user_name(id, szName, charsmax(szName))
      sk_chat(0, "^4%s^1 épp kiveri húsos lőcsét ^4%s^1 halott testére! MuHaHaHaHa!!", szName, szPlayerName)
    }
    else {
      sk_chat(id, "Nincs halott test a közeledben akire kiverheted :(.")
      return PLUGIN_HANDLED
    }
  }
  else 
  {
    new szName[32]
    get_user_name(id, szName, charsmax(szName))
    sk_chat(0, "^4%s^1 épp kiveri húsos lőcsét! MuHaHaHaHa!!", szName)
  }

  g_iPlayerCounter[id] = 1
  g_iPlayerEjaculationsNum[id]++

  emit_sound(id, CHAN_VOICE, "ejaculate/ejaculate.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
  set_task(1.0, "make_ejaculate", id + TASKID_make_ejaculate, _, _, "a", MAX_COUNTER - 1)

  return PLUGIN_HANDLED
}

public ejaculate_help(id, iLevel) {
  new szArgs[24]
  new iArgsLen = read_args(szArgs, charsmax(szArgs))
  new iPrintType = (szArgs[0] == '"' && szArgs[iArgsLen - 1] == '"') ? print_chat : print_console

  client_print(id, iPrintType, "Ha szeretnéd kiverni valakire a közeledben akkor ^"ejaculate^".")
  client_print(id, iPrintType, "Nyisd meg a konzolod és: bind ^"BETŰ^" ^"ejaculate^"")
  client_print(id, iPrintType, "Példa: bind ^"x^" ^"ejaculate^"")

  return PLUGIN_HANDLED
}

public make_ejaculate(id) {
  id -= TASKID_make_ejaculate

  new iOrigin[3], iVelocity[3], Float:fVelocity[3]
  get_user_origin(id, iOrigin)
  VelocityByAim(id, 3, fVelocity)
  FVecIVec(fVelocity, iVelocity)

  message_begin(MSG_PVS, SVC_TEMPENTITY, iOrigin)
  write_byte(TE_BLOODSTREAM)
  write_coord(iOrigin[0])
  write_coord(iOrigin[1])
  write_coord(iOrigin[2])
  write_coord(iVelocity[0])
  write_coord(iVelocity[1])
  write_coord(iVelocity[2])
  write_byte(6) // color
  write_byte(165) // speed
  message_end()

  if(++g_iPlayerCounter[id] == MAX_COUNTER + 1) {
    g_iPlayerCounter[id] = 0
  }
}

public reset_hud(id) {
  if(g_iPlayerCounter[id]) {
    reset_ejaculate(id)
  }

  g_iPlayerEjaculationsNum[id] = 0
}

public death_event() {
  new victim = read_data(2)
  get_user_origin(victim, g_iPlayerOrigins[victim], 0)

  if(g_iPlayerCounter[victim]) {
    reset_ejaculate(victim)
  }
}

reset_ejaculate(id) {
  g_iPlayerCounter[id] = 0
  remove_task(id + TASKID_make_ejaculate)
  emit_sound(id, CHAN_VOICE, "ejaculate/ejaculate.wav", 0.0, ATTN_NORM, 0, PITCH_NORM)
}
