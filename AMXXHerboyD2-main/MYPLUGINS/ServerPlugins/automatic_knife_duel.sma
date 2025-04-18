#define PLUGINNAME	"Automatic knife duel"
#define VERSION		"0.3"
#define AUTHOR		"JGHG"
/*
Copyleft 2005
Plugin topic: http://www.amxmodx.org/forums/viewtopic.php?p=91239


AUTOMATIC KNIFE DUEL
====================
Where I come from, if you cut the wall repeteadly with your knife it means you're challenging your last opponent to a knife duel. ;-)

I decided to automate this process.

If only you and another person on the opposite team remain in the round, you can hit a wall (or another object) with your knife, THREE TIMES in fast succession.
By this action you challenge your opponent to a knife duel. The person you challenge gets a menu where he can accept/decline your
challenge. The challenged person has 10 seconds to decide his mind, else the challenge is automatically declined, and the menu should be closed automatically.

Should a knife duel start, it works out pretty much like a round of Knife Arena: you can only use the knife (and the C4!).
As soon as the round ends the Knife Arena mode is turned off.

/JGHG


VERSIONS
========
050421	0.3 You must now slash with your knife three times in fast succession to challenge someone.
050208	0.2	Fixed seconds display.
			Bots should now respond correctly and a little human like. They will mostly accept challenges. ;-)
			Small fixes here and there. :-)
050208	0.1	First version - largely untested
*/

#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <engine>
#include <fun>
#include <hamsandwich>
#include <fakemeta>
#include <xs>
#include <fakemeta_util>
#include <sk_utils>

#define DEBUG
new const availableWeapons[][] = { "p228", "scout", "hegrenade", "xm1014", "mac10",
		"aug", "smokegrenade", "elite", "fiveseven", "ump45", "sg550", "galil",
		"famas", "usp", "glock18", "awp", "mp5navy", "m249", "m3", "m4a1",
		"tmp", "g3sg1", "flashbang", "deagle", "sg552", "ak47", "p90" };

#if defined DEBUG
#include <amxmisc>
#endif // defined DEBUG

#define MENUSELECT1				0
#define MENUSELECT2				1
#define TASKID_CHALLENGING		2348923
#define TASKID_BOTTHINK			3242321
#define DECIDESECONDS			20
#define ALLOWED_WEAPONS			2
#define KNIFESLASHES			3 // the nr of slashes within a short amount of time until a challenge starts...
// Globals below
new g_allowedWeapons[ALLOWED_WEAPONS] = {CSW_KNIFE, CSW_C4}
new g_MAXPLAYERS
new bool:g_challenging = false
new bool:g_knifeArena = false
new bool:g_noChallengingForAWhile = false
new g_challengemenu
new g_challenger
new g_challenged
new g_challenges[33]
// Globals above
public LoadUtils()
{
	}
public plugin_modules()
{
	require_module("fakemeta")
	require_module("fun")
}

public forward_emitsound(const PIRATE, const Onceuponatimetherewasaverysmall, noise[], const Float:turtlewhoateabiggerturtleand, const Float:afterthatthesmallturtlegot, const veryveryverybig, const theend) {
	if (g_noChallengingForAWhile || g_knifeArena || g_challenging || PIRATE < 1 || PIRATE > g_MAXPLAYERS || !is_user_alive(PIRATE) || !equal(noise, "weapons/knife_hitwall1.wav"))
		return FMRES_IGNORED

	new team = get_user_team(PIRATE), otherteam = 0, matchingOpponent = 0
	// Make sure exactly one person on each team is alive.
	for (new i = 1; i <= g_MAXPLAYERS; i++) {
		if (!is_user_connected(i) || !is_user_alive(i) || PIRATE == i)
			continue
		if (get_user_team(i) == team) {
			// No fun.
			return FMRES_IGNORED
		}
		else {
			if (++otherteam > 1) {
				// No fun.
				return FMRES_IGNORED
			}
			matchingOpponent = i
		}
	}

	if (matchingOpponent == 0)
		return FMRES_IGNORED

	if (++g_challenges[PIRATE] >= KNIFESLASHES) {
		Challenge(PIRATE, matchingOpponent)
		new challenger_name[32], challenged_name[32]
		get_user_name(PIRATE, challenger_name, 31)
		get_user_name(matchingOpponent, challenged_name, 31)
		sk_chat(0, "^4%s^1 kihívta ^4%s^1-t egy késpárbajra!", challenger_name, challenged_name)
		if (is_user_bot(matchingOpponent)) {
			new Float:val = float(DECIDESECONDS)
			if (val < 2.0)
				val = 2.0
			remove_task(TASKID_BOTTHINK)
			set_task(random_float(1.0, float(DECIDESECONDS) - 1.0), "BotDecides", TASKID_BOTTHINK)
		}
		g_challenges[PIRATE] = 0
	}
	else
		set_task(1.0, "decreaseChallenges", PIRATE)

	//client_print(PIRATE, print_chat, "Your challenges: %d", g_challenges[PIRATE])

	return FMRES_IGNORED
}

public decreaseChallenges(id) {
	if (--g_challenges[id] < 0)
		g_challenges[id] = 0
}

public BotDecides() {
	if (!g_challenging)
		return

	if (random_num(0,9) > 0)
		Accept()
	else {
		DeclineMsg()
	}
	g_challenging = false
	remove_task(TASKID_CHALLENGING)
}

Challenge(challenger, challenged) {
	g_challenger = challenger
	g_challenged = challenged
	g_challenging = true
	new challenger_name[32], challenged_name[32]
	get_user_name(challenger, challenger_name, 31)
	get_user_name(challenged, challenged_name, 31)

	sk_chat(challenger, "Megakarsz küzdeni ^4%s^1-val egy késpárbajban? Várj a válaszra ^4%i^1 másodpercet.", challenged_name, DECIDESECONDS)

	new menu = menu_create(fmt("\y[\r~|\wAvatár\r|~\y] ^n\wKéspárbaj kihívás!"), "parbaj_h");
	menu_addtext2(menu, fmt("Kihívott fél késpárbajra: \r%s", challenged_name))
	menu_addtext2(menu, fmt("Kihívott téged: \r%s", challenger_name))
	menu_addblank2(menu);
	menu_additem(menu, "\yElfogadom", "1")
	menu_additem(menu, "\rElutasítom", "2")
	menu_display(challenged, menu, 0, DECIDESECONDS);
	set_task(float(DECIDESECONDS), "timed_toolate", TASKID_CHALLENGING)
}
public parbaj_h(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		DeclineMsg();
		return PLUGIN_HANDLED;
	}

	new data[9], szName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
	new key = str_to_num(data);

	switch(key)
	{
		case 1: Accept()
		case 2: DeclineMsg()
	}
	g_challenging = false
	remove_task(TASKID_CHALLENGING)

	return PLUGIN_HANDLED;
}
public timed_toolate() {
	if (g_challenging) {
		new challenger_name[32], challenged_name[32]
		get_user_name(g_challenger, challenger_name, 31)
		get_user_name(g_challenged, challenged_name, 31)
		sk_chat(0, "^4%s^1 nem válaszolt ^4%s^1 késpárbaj kihívására.", challenged_name, challenger_name)
		CancelAll()
	}
}

public client_putinserver(id) {
	set_task(25.0, "Announcement", id)

	return PLUGIN_CONTINUE
}

public Announcement(id) {
	sk_chat(id, "Amikor már csak ^3te^1 és egy ^3ellenséged^1 maradt, kitudod őt hívni egy késpárbajra, csak verd a késed a falhoz!")
}

DeclineMsg() {
	new challenger_name[32], challenged_name[32]
	get_user_name(g_challenger, challenger_name, 31)
	get_user_name(g_challenged, challenged_name, 31)
	sk_chat(0, "^4%s^1 nem fogadta el ^4%s^1 késpárbaj kihívását.", challenged_name, challenger_name)
}

Accept() {
	new challenger_name[32], challenged_name[32]
	get_user_name(g_challenger, challenger_name, 31)
	get_user_name(g_challenged, challenged_name, 31)

	sk_chat(0, "^4%s^1 elfogadta ^4%s^1 késpárbaj kihívását.", challenged_name, challenger_name)
	g_knifeArena = true
	strip_user_weapons(g_challenger);
	strip_user_weapons(g_challenged);
	give_item(g_challenger, "weapon_knife")
	give_item(g_challenged, "weapon_knife")
	engclient_cmd(g_challenger, "weapon_knife")
	engclient_cmd(g_challenged, "weapon_knife")
	set_user_health(g_challenger, 100)
	set_user_health(g_challenged, 100)
}
public StripWeap(id)
{
	strip_user_weapons(id-3191831);
}
public event_holdwpn(id) {
	if (!g_knifeArena || !is_user_alive(id))
		return PLUGIN_CONTINUE

	new weaponType = read_data(2)

	for (new i = 0; i < ALLOWED_WEAPONS; i++) {
		if (weaponType == g_allowedWeapons[i])
			return PLUGIN_CONTINUE
	}

	engclient_cmd(id, "weapon_knife")

	return PLUGIN_CONTINUE
}

public event_roundend() {
	if (g_challenging || g_knifeArena)
		CancelAll()
	g_noChallengingForAWhile = true
	set_task(4.0, "NoChallengingForAWhileToFalse")

	return PLUGIN_CONTINUE
}

public NoChallengingForAWhileToFalse() {
	g_noChallengingForAWhile = false
}

CancelAll() {
	if (g_challenging) {
		g_challenging = false
		// Close menu of challenged
		if (is_user_connected(g_challenged)) {
			new usermenu, userkeys
			get_user_menu(g_challenged, usermenu, userkeys) // get user menu

			// Hmm this ain't working :-/
			if (usermenu == g_challengemenu) // Close it!
				show_menu(g_challenged, 0, "blabla") // show empty menu
		}
	}
	if (g_knifeArena) {
		g_knifeArena = false
	}
	remove_task(TASKID_BOTTHINK)
	remove_task(TASKID_CHALLENGING)
}

public event_death() {
	if (g_challenging || g_knifeArena)
		CancelAll()

	return PLUGIN_CONTINUE
}

#if defined DEBUG
public challengefn(id, level, cid) {
	if (!cmd_access(id, level, cid, 3))
		return PLUGIN_HANDLED

	new challenger[64], challenged[64]
	read_argv(1, challenger, 63)
	read_argv(2, challenged, 63)

	console_print(id, "challenger: %s, challenged: %s", challenger, challenged)

	new r = str_to_num(challenger)
	new d = str_to_num(challenged)
	Challenge(r, d)
	if (is_user_bot(d))
		Accept()

	return PLUGIN_HANDLED
}
#endif // defined DEBUG

public plugin_init() {
	register_plugin(PLUGINNAME, VERSION, AUTHOR)
	register_forward(FM_EmitSound, "forward_emitsound")
	g_MAXPLAYERS = get_maxplayers()

	g_challengemenu = register_menuid("JGHG's automatic knife duel"/*"You are challenged"*/)

	register_event("DeathMsg", "event_death", "a")
	register_event("SendAudio", "event_roundend", "a", "2&%!MRAD_terwin")
	register_event("SendAudio", "event_roundend", "a", "2&%!MRAD_ctwin")
	register_event("SendAudio", "event_roundend", "a", "2&%!MRAD_rounddraw")
	RegisterHam( Ham_Touch, "armoury_entity", "FwdHamPlayerPickup" );
  RegisterHam( Ham_Touch, "weaponbox", "FwdHamPlayerPickup" );

	#if defined DEBUGs
	register_clcmd("0challenge", "challengefn", ADMIN_CFG, "<challenger> <challenged> - start knife duel challenge")
	#endif // defined DEBUG

	new Float:maptime = get_cvar_float("mp_timelimit")
	if (maptime == 0.0)
		maptime = 15.0

	new Float:anntime = 60.0 * 5.0 // 5 minutes
	if (maptime < 5.0)
		anntime = maptime / 3.0

	set_task(anntime, "Announcement", 0, "", 0, "b")
}
public FwdHamPlayerPickup( iEntity, id )
{
	if(g_knifeArena == true)
		return HAM_SUPERCEDE;
	return HAM_IGNORED;
}
    
