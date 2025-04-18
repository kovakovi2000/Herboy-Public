new const PLUGIN_VERSION[] = "1.0"

// Létrehozza a cvar config-ot az 'amxmodx/configs/plugins' könyvtárban.
#define AUTO_CFG

// Rejtse el az autorespondert kiváltó üzeneteket
#define BLOCK_TRIGGER_MSG

// Lehetővé teszi a játékosok számára az üzenetek letiltását.
#define CMD_NAME "hirdeto_kibe"

// Az autoresponder letiltása, ha a játékos személyesen tiltja le az üzeneteket.
#define CMD_BLOCK_AUTORESPOND

// Napokban megadott nvault mentések törlése.
#define OBSOLETE_DAYS 30

// Chat prefix
//new const CHAT_PREFIX[] = "" // nincs prefix
//new const CHAT_PREFIX[] = "^4[^1~^3|^4HerBoy^3|^1~^4] !3» ^1"
new const CHAT_PREFIX[] = "^4[AVATÁR] ^3» ^1" 

// Prefix használata hirdetésekhez.
#define SHOW_PREFIX_WITH_ADS

// Véletlenszerű indulás.
// Ne felejtsd el beállítani a '2' vagy '3' típust azokhoz az üzenetekhez, amelyeket nem akarsz elindítani.
#define RANDOM_START

// Config fájl neve ('amxmodx/configs')
new const ADS_FILE_NAME[] = "hirdeto.ini"

// Lang fájl neve ('amxmodx/data/lang')
new const LANG_NAME[] = "hirdeto.txt"

// Vault név ('amxmodx/data/vault')
stock const VAULT_NAME[] = "hirdeto"

// Hang használata
#define USE_SOUND

// Hangok
stock const g_szSounds[][] = {
/* 0 */ "buttons/blip1.wav",
/* 1 */ "buttons/blip2.wav",
/* 2 */ "events/tutor_msg.wav",
/* 3 */ "buttons/button2.wav",
/* 4 */ "buttons/bell1.wav",
/* 5 */ "buttons/button3.wav",
/* 6 */ "buttons/button7.wav",
/* 7 */ "buttons/button9.wav",
/* 8 */ "plats/elevbell1.wav",
/* 9 */ "plats/train_use1.wav",
/* 10 */ "x/x_shoot1.wav"
}

#include <amxmodx>
#include <amxmisc>
#include <time>

#if defined CMD_NAME
	#include <nvault>
#endif

#define chx charsmax
#define chx_len(%0) charsmax(%0) - iLen

#define CheckPatternBit(%0) (g_eMsgData[MSG_PATTERN_BITSUM] & (1<<%0))
#define SetPatternBit(%0) (g_eMsgData[MSG_PATTERN_BITSUM] |= (1<<%0))

#define MODE_AUTO false
#define MODE_MANUAL true

#define MSG_LEN 191
#define TEMPLATE_LEN 191

new const PLUGIN_PREFIX[] = "Hirdeto"

new const SOUND__BLIP1[] = "sound/buttons/blip1.wav"

const TASKID_TIMER = 1337

enum _:CVAR_ENUM {
	Float:CVAR__FREQ_MIN,
	Float:CVAR__FREQ_MAX,
	CVAR__FOR_ALL,
	CVAR__MODE,
	CVAR__SOUND_FOR_ALL
}

enum _:MSG_STRUCT {
	MSG_BODY[MSG_LEN],
	MSG_COLOR_ID,
	bool:IS_MULTI_MSG,
	MSG_SOUND_ID,
	bool:NOT_FOR_START,
	MSG_MODE,
	bool:AUTORESPOND_ONLY,
	bool:MSG_IS_LANG_KEY,
	MSG_PATTERN_BITSUM
}

enum _:AR_STRUCT {
	AR_MODE,
	POINTER,
	TEMPLATE[TEMPLATE_LEN]
}

enum {
	AR_MODE__EX_INSENS,
	AR_MODE__EX_SENS,
	AR_MODE__MATCH_INSENS,
	AR_MODE__MATCH_SENS
}

enum _:PATTERNS_ENUM {
	PATTERN__HOSTNAME,
	PATTERN__MAXPLAYERS,
	PATTERN__NUMPLAYERS,
	PATTERN__SERVER_IP,
	PATTERN__MAPNAME,
	PATTERN__SV_CONTACT,
	PATTERN__TIMELEFT,
	PATTERN__PLAYER_NAME,
	PATTERN__PLAYER_STEAMID,
	PATTERN__PLAYER_IP
}

new const PATTERNS[PATTERNS_ENUM][] = {
	"#hostname#",
	"#maxplayers#",
	"#numplayers#",
	"#server_ip#",
	"#mapname#",
	"#contact#",
	"#timeleft#",
	"#name#",
	"#steamid#",
	"#ip#"
}

new g_eCvar[CVAR_ENUM]
new Array:g_aMsgArray
new Array:g_aAuReArray
new g_eMsgData[MSG_STRUCT]
new g_AuReData[AR_STRUCT]
new g_iTotalMsgCount
new g_iAuReCount
new	g_iCurPos
new g_iFirstSkipPos
new g_szFilePath[PLATFORM_MAX_PATH]
new g_szBuffer[MAX_AUTHID_LENGTH] // ne csökkentsd a méretét!
new g_szMsg[MSG_LEN]
new g_iAutoMsgCount

stock g_bDisabled[MAX_PLAYERS + 1]
stock g_hVault = INVALID_HANDLE
stock g_iMsgIdSendAudio

/* -------------------- */

public plugin_precache() {
	register_plugin("Hirdeto", PLUGIN_VERSION, "Ek1`")

	register_clcmd("say", "hook_Say")
	register_clcmd("say_team", "hook_Say")

#if defined CMD_NAME
	register_clcmd(CMD_NAME, "clcmd_ToggleState")
#endif

#if defined USE_SOUND
	for(new i; i < sizeof(g_szSounds); i++) {
		precache_sound(g_szSounds[i])
	}
#endif
}

/* -------------------- */

public plugin_init() {
	register_dictionary(LANG_NAME)

	/* --- */

	func_RegCvars()

	/* --- */

#if defined USE_SOUND
	g_iMsgIdSendAudio = get_user_msgid("SendAudio")
#endif
}

/* -------------------- */

public plugin_cfg() {
	g_aAuReArray = ArrayCreate(AR_STRUCT, 1)
	g_aMsgArray = ArrayCreate(MSG_STRUCT)

	/* --- */

	func_LoadMessages(MODE_AUTO)

	/* --- */

	// Állapot: Összes üzenet száma, aktuális pozíció
	register_srvcmd("hirdeto_status", "srvcmd_CmdShowStatus")
	// Megadott üzenet nyomtatása (példa: hirdeto_show 5)
	register_srvcmd("hirdeto_show", "srvcmd_CmdShowCustomMessage")
	// Üzenetek config újratöltése
	register_srvcmd("hirdeto_reload", "srvcmd_CmdReloadFile")

	/* --- */

#if defined CMD_NAME
	g_hVault = nvault_open(VAULT_NAME)

	#if defined OBSOLETE_DAYS
	if(g_hVault != INVALID_HANDLE) {
		nvault_prune(g_hVault, 0, get_systime() - (OBSOLETE_DAYS * SECONDS_IN_DAY))
	}
	#endif
#endif
}

/* -------------------- */

public hook_Say(id) {
#if defined CMD_BLOCK_AUTORESPOND
	if(!g_iAuReCount || g_bDisabled[id]) {
#else
	if(!g_iAuReCount) {
#endif
		return PLUGIN_CONTINUE
	}

	new szMessage[MSG_LEN]

	read_args(szMessage, chx(szMessage))
	remove_quotes(szMessage)
	trim(szMessage)

	for(new i; i < g_iAuReCount; i++) {
		ArrayGetArray(g_aAuReArray, i, g_AuReData)

		switch(g_AuReData[AR_MODE]) {
			case AR_MODE__EX_INSENS: {
				if(containi(szMessage, g_AuReData[TEMPLATE]) == -1) {
					continue
				}
			}
			case AR_MODE__EX_SENS: {
				if(contain(szMessage, g_AuReData[TEMPLATE]) == -1) {
					continue
				}
			}
			case AR_MODE__MATCH_INSENS: {
				new iPos = containi(szMessage, g_AuReData[TEMPLATE])

				if(iPos == -1) {
					continue
				}

				if(iPos && szMessage[iPos - 1] != ' ') {
					continue
				}

				iPos = strlen(g_AuReData[TEMPLATE]) + iPos // a minta végpontjának kiszámítása

				if(szMessage[iPos] && szMessage[iPos] != ' ') {
					continue
				}
			}
			case AR_MODE__MATCH_SENS: {
				new iPos = contain(szMessage, g_AuReData[TEMPLATE])

				if(iPos == -1) {
					continue
				}

				if(iPos && szMessage[iPos - 1] != ' ') {
					continue
				}

				iPos = strlen(g_AuReData[TEMPLATE]) + iPos // pozíció kalkulálás

				if(szMessage[iPos] && szMessage[iPos] != ' ') {
					continue
				}
			}
		}

		ArrayGetArray(g_aMsgArray, g_AuReData[POINTER], g_eMsgData)

		if(g_eMsgData[MSG_MODE] && g_eCvar[CVAR__MODE] != g_eMsgData[MSG_MODE]) {
			return PLUGIN_CONTINUE
		}

		func_ShowToSingle(id)

		while(g_eMsgData[IS_MULTI_MSG] && ++g_AuReData[POINTER] < g_iTotalMsgCount) {
			ArrayGetArray(g_aMsgArray, g_AuReData[POINTER], g_eMsgData)
			func_ShowToSingle(id)
		}

	#if defined BLOCK_TRIGGER_MSG
		return PLUGIN_HANDLED
	#else
		return PLUGIN_CONTINUE
	#endif
	}

	return PLUGIN_CONTINUE
}

/* -------------------- */

stock func_ShowToSingle(pPlayer) {
	if(g_eMsgData[MSG_IS_LANG_KEY]) {
		func_ReplaceML(pPlayer)
		func_ReplacePatterns(pPlayer)
	}
	else {
		copy(g_szMsg, chx(g_szMsg), g_eMsgData[MSG_BODY])

		if(g_eMsgData[MSG_PATTERN_BITSUM]) {
			func_ReplacePatterns(pPlayer)
		}
	}

#if defined SHOW_PREFIX_WITH_ADS
	client_print_color(pPlayer, g_eMsgData[MSG_COLOR_ID], "%s^1%s", CHAT_PREFIX, g_szMsg)
#else
	client_print_color(pPlayer, g_eMsgData[MSG_COLOR_ID], "^1%s", g_szMsg)
#endif

#if defined USE_SOUND
	if(g_eMsgData[MSG_SOUND_ID] != -1) {
		func_SendAudio(pPlayer, g_szSounds[ g_eMsgData[MSG_SOUND_ID] ])
	}
#endif
}

/* -------------------- */

#if defined CMD_NAME
	public clcmd_ToggleState(pPlayer) {
		g_bDisabled[pPlayer] = !g_bDisabled[pPlayer]
	#if defined USE_SOUND
		func_SendAudio(pPlayer, SOUND__BLIP1)
	#endif

		if(g_hVault == INVALID_HANDLE) {
			return PLUGIN_HANDLED
		}

		get_user_authid(pPlayer, g_szBuffer, chx(g_szBuffer))

		if(g_bDisabled[pPlayer]) {
			nvault_set(g_hVault, g_szBuffer, "1")
		}
		else {
			nvault_remove(g_hVault, g_szBuffer)
		}

		return PLUGIN_HANDLED
	}
#endif

/* -------------------- */

public func_LoadMessages(bool:bMode) {
	if(bMode == MODE_AUTO) {
		new iLen = get_localinfo("amxx_configsdir", g_szFilePath, chx(g_szFilePath))
		formatex(g_szFilePath[iLen], chx_len(g_szFilePath), "/%s", ADS_FILE_NAME)
	}

	if(!file_exists(g_szFilePath)) {
		set_fail_state("Hiba, nem talalom '%s'", ADS_FILE_NAME)
	}

	new hFile = fopen(g_szFilePath, "r")

	if(!hFile) {
		set_fail_state("Nem olvashato '%s'", ADS_FILE_NAME)
	}

	new szString[MSG_LEN * 2], szMode[3], szType[3], szSound[3],
		szColor[2], szAuRe[2], szAuReMode[2], szTemplate[TEMPLATE_LEN];

	while(!feof(hFile))	{
		fgets(hFile, szString, chx(szString))

		if(!isdigit(szString[0])) {
			continue
		}

		g_AuReData[TEMPLATE][0] = EOS

		parse( szString, szMode, chx(szMode), szType, chx(szType), szSound, chx(szSound), szColor, chx(szColor),
			szAuRe, chx(szAuRe), szAuReMode, chx(szAuReMode), g_AuReData[TEMPLATE], TEMPLATE_LEN - 1, g_eMsgData[MSG_BODY], MSG_LEN - 1 );

		if(g_AuReData[TEMPLATE][0]) {
			g_AuReData[AR_MODE] = str_to_num(szAuReMode)
			g_AuReData[POINTER] = g_iTotalMsgCount

			if(contain(g_AuReData[TEMPLATE], "|") != -1) {
				copy(szTemplate, chx(szTemplate), g_AuReData[TEMPLATE])

				while(strtok2(szTemplate, g_AuReData[TEMPLATE], TEMPLATE_LEN - 1, szTemplate, chx(szTemplate), .token = '|', .trim = 0) != -1) {
					ArrayPushArray(g_aAuReArray, g_AuReData)
					g_iAuReCount++
				}

				ArrayPushArray(g_aAuReArray, g_AuReData)
				g_iAuReCount++
			}
			else {
				ArrayPushArray(g_aAuReArray, g_AuReData)
				g_iAuReCount++
			}
		}

		if(equal(g_eMsgData[MSG_BODY], "HIRDETO_KEY", 11)) {
			g_eMsgData[MSG_IS_LANG_KEY] = true
			g_eMsgData[MSG_PATTERN_BITSUM] = -1 // (1<<0) .. (1<<31)
		}
		else {
			g_eMsgData[MSG_IS_LANG_KEY] = false

			replace_string(g_eMsgData[MSG_BODY], MSG_LEN - 1, "!n", "^1")
			replace_string(g_eMsgData[MSG_BODY], MSG_LEN - 1, "!t", "^3")
			replace_string(g_eMsgData[MSG_BODY], MSG_LEN - 1, "!g", "^4")

			g_eMsgData[MSG_PATTERN_BITSUM] = 0
			func_FindPatterns()
		}

		g_eMsgData[MSG_MODE] = str_to_num(szMode)

	#if defined RANDOM_START
		switch(szType[0]) {
			case '0': {
				g_eMsgData[IS_MULTI_MSG] = false
				g_eMsgData[NOT_FOR_START] = false
			}
			case '1': {
				g_eMsgData[IS_MULTI_MSG] = true
				g_eMsgData[NOT_FOR_START] = false
			}
			case '2': {
				g_eMsgData[IS_MULTI_MSG] = true
				g_eMsgData[NOT_FOR_START] = true
			}
			case '3': {
				g_eMsgData[IS_MULTI_MSG] = false
				g_eMsgData[NOT_FOR_START] = true
			}
		}
	#else
		g_eMsgData[IS_MULTI_MSG] = (szType[0] == '1' || szType[0] == '2') ? true : false
	#endif

		g_eMsgData[MSG_SOUND_ID] = str_to_num(szSound) - 1

		switch(szColor[0]) {
			case 'W': g_eMsgData[MSG_COLOR_ID] = print_team_grey
			case 'R': g_eMsgData[MSG_COLOR_ID] = print_team_red
			case 'B': g_eMsgData[MSG_COLOR_ID] = print_team_blue
			default: g_eMsgData[MSG_COLOR_ID] = print_team_default
		}

		g_eMsgData[AUTORESPOND_ONLY] = (szAuRe[0] == '0') ? false : true

		if(!g_eMsgData[AUTORESPOND_ONLY]) {
			g_iAutoMsgCount++
		}

		ArrayPushArray(g_aMsgArray, g_eMsgData)
		g_iTotalMsgCount++
	}

	fclose(hFile)

	if(g_iAutoMsgCount) {
	#if defined RANDOM_START
		new iTryCount

		while(g_iTotalMsgCount) {
			if(++iTryCount == g_iTotalMsgCount) { // rossz config
				g_iCurPos = 0
				break
			}

			g_iCurPos = random_num(0, g_iTotalMsgCount - 1)
			ArrayGetArray(g_aMsgArray, g_iCurPos, g_eMsgData)

			if(g_eMsgData[NOT_FOR_START]) {
				continue
			}

			break
		}
	#endif
		func_SetTask()
	}

	if(bMode == MODE_AUTO) {
		server_print("%s %i uzenetek megjelenitese", PLUGIN_PREFIX, g_iTotalMsgCount)
	}
}

/* -------------------- */

public func_PrintMessage(iTaskID) {
	if(g_iCurPos == g_iTotalMsgCount) {
		g_iCurPos = 0
	}

	ArrayGetArray(g_aMsgArray, g_iCurPos++, g_eMsgData)

	if(g_eMsgData[AUTORESPOND_ONLY] && iTaskID) {
		func_PrintMessage(iTaskID)
		return
	}

	// Protection against infinite recursion
	if(g_eCvar[CVAR__MODE] && g_eMsgData[MSG_MODE] && g_eMsgData[MSG_MODE] != g_eCvar[CVAR__MODE] && iTaskID) {
		if(!g_iFirstSkipPos) {
			g_iFirstSkipPos = g_iCurPos
		}
		else if(g_iFirstSkipPos == g_iCurPos) {
			g_iFirstSkipPos = 0
			func_SetTask()
			return
		}

		func_PrintMessage(iTaskID)
		return
	}

	g_iFirstSkipPos = 0

	new pPlayers[MAX_PLAYERS], iPlCount, pPlayer

	get_players_ex( pPlayers, iPlCount, g_eCvar[CVAR__FOR_ALL] ?
		GetPlayers_ExcludeBots|GetPlayers_ExcludeHLTV
			:
		GetPlayers_ExcludeBots|GetPlayers_ExcludeHLTV|GetPlayers_ExcludeAlive
	);

	if(!g_eMsgData[MSG_IS_LANG_KEY] && !g_eMsgData[MSG_PATTERN_BITSUM]) {
		copy(g_szMsg, chx(g_szMsg), g_eMsgData[MSG_BODY])
	}

	for(new i; i < iPlCount; i++) {
		pPlayer = pPlayers[i]

	#if defined CMD_NAME
		if(g_bDisabled[pPlayer]) {
			continue
		}
	#endif

	if(g_eMsgData[MSG_IS_LANG_KEY]) {
		func_ReplaceML(pPlayer)
		func_ReplacePatterns(pPlayer)
	}
	else if(g_eMsgData[MSG_PATTERN_BITSUM]) {
		copy(g_szMsg, chx(g_szMsg), g_eMsgData[MSG_BODY])
		func_ReplacePatterns(pPlayer)
	}

	#if defined SHOW_PREFIX_WITH_ADS
		client_print_color(pPlayer, g_eMsgData[MSG_COLOR_ID], "%s^1%s", CHAT_PREFIX, g_szMsg)
	#else
		client_print_color(pPlayer, g_eMsgData[MSG_COLOR_ID], "^1%s", g_szMsg)
	#endif

	#if defined USE_SOUND
		if(g_eMsgData[MSG_SOUND_ID] != -1) {
			if(!g_eCvar[CVAR__SOUND_FOR_ALL] && is_user_alive(pPlayer)) {
				continue
			}

			func_SendAudio(pPlayer, g_szSounds[ g_eMsgData[MSG_SOUND_ID] ])
		}
	#endif
	}

	if(g_eMsgData[IS_MULTI_MSG] && g_iCurPos < g_iTotalMsgCount) {
		func_PrintMessage(iTaskID)
		return
	}

	func_SetTask()
}

/* -------------------- */

func_SetTask() {
	if(g_iAutoMsgCount) {
		set_task(random_float(g_eCvar[CVAR__FREQ_MIN], g_eCvar[CVAR__FREQ_MAX]), "func_PrintMessage", TASKID_TIMER)
	}
}

/* -------------------- */

public srvcmd_CmdShowStatus() {
	server_print("%s Osszes uzenet: %i | Utoljara irt: #%i", PLUGIN_PREFIX, g_iTotalMsgCount, g_iCurPos)
	return PLUGIN_HANDLED
}

/* -------------------- */

public srvcmd_CmdShowCustomMessage() {
	new iMsgID = read_argv_int(1)

	if(!(g_iTotalMsgCount + 1 > iMsgID > 0)) { /* if(1 > iMsgID || iMsgID > g_iTotalMsgCount) */
		server_print("%s Hiba! Rossz uzenet ID #%i (Osszes: %i)", PLUGIN_PREFIX, iMsgID, g_iTotalMsgCount)
	}
	else {
		remove_task(TASKID_TIMER)
		g_iCurPos = iMsgID - 1
		func_PrintMessage(0)
		server_print("%s Uzenet: #%i (Osszesen: %i) irt!", PLUGIN_PREFIX, iMsgID, g_iTotalMsgCount)
	}

	return PLUGIN_HANDLED
}

/* -------------------- */

public srvcmd_CmdReloadFile() {
	remove_task(TASKID_TIMER)
	ArrayClear(g_aMsgArray)
	ArrayClear(g_aAuReArray)
	g_iAuReCount = 0
	new iOldTotalMsgCount = g_iTotalMsgCount
	g_iTotalMsgCount = 0
	g_iAutoMsgCount = 0
	g_iCurPos = 0
	g_iFirstSkipPos = 0
	func_LoadMessages(MODE_MANUAL)
	server_print("%s Uzenetek szama olvasas elott/utan: %i/%i", PLUGIN_PREFIX, iOldTotalMsgCount, g_iTotalMsgCount)

	return PLUGIN_HANDLED
}

/* -------------------- */

stock func_ReplacePatterns(pPlayer) {
	if(CheckPatternBit(PATTERN__HOSTNAME)) {
		get_user_name(0, g_szBuffer, chx(g_szBuffer))
		replace_stringex(g_szMsg, chx(g_szMsg), PATTERNS[PATTERN__HOSTNAME], g_szBuffer)
	}

	if(CheckPatternBit(PATTERN__MAXPLAYERS)) {
		replace_stringex(g_szMsg, chx(g_szMsg), PATTERNS[PATTERN__MAXPLAYERS], fmt("%i", MaxClients))
	}

	if(CheckPatternBit(PATTERN__NUMPLAYERS)) {
		replace_stringex(g_szMsg, chx(g_szMsg), PATTERNS[PATTERN__NUMPLAYERS], fmt("%i", get_playersnum()))
	}

	if(CheckPatternBit(PATTERN__SERVER_IP)) {
		get_user_ip(0, g_szBuffer, chx(g_szBuffer), .without_port = 0)
		replace_stringex(g_szMsg, chx(g_szMsg), PATTERNS[PATTERN__SERVER_IP], g_szBuffer)
	}

	if(CheckPatternBit(PATTERN__MAPNAME)) {
		get_mapname(g_szBuffer, chx(g_szBuffer))
		replace_stringex(g_szMsg, chx(g_szMsg), PATTERNS[PATTERN__MAPNAME], g_szBuffer)
	}

	if(CheckPatternBit(PATTERN__SV_CONTACT)) {
		get_cvar_string("sv_contact", g_szBuffer, chx(g_szBuffer))
		replace_stringex(g_szMsg, chx(g_szMsg), PATTERNS[PATTERN__SV_CONTACT], g_szBuffer)
	}

	if(CheckPatternBit(PATTERN__TIMELEFT)) {
		new iTimeleft = get_timeleft()

		replace_stringex( g_szMsg, chx(g_szMsg), PATTERNS[PATTERN__TIMELEFT],
			fmt("%02d:%02d", iTimeleft / SECONDS_IN_MINUTE, iTimeleft % SECONDS_IN_MINUTE) );
	}

	if(CheckPatternBit(PATTERN__PLAYER_NAME)) {
		get_user_name(pPlayer, g_szBuffer, chx(g_szBuffer))
		replace_stringex(g_szMsg, chx(g_szMsg), PATTERNS[PATTERN__PLAYER_NAME], g_szBuffer)
	}

	if(CheckPatternBit(PATTERN__PLAYER_STEAMID)) {
		get_user_authid(pPlayer, g_szBuffer, chx(g_szBuffer))
		replace_stringex(g_szMsg, chx(g_szMsg), PATTERNS[PATTERN__PLAYER_STEAMID], g_szBuffer)
	}

	if(CheckPatternBit(PATTERN__PLAYER_IP)) {
		get_user_ip(pPlayer, g_szBuffer, chx(g_szBuffer), .without_port = 1)
		replace_stringex(g_szMsg, chx(g_szMsg), PATTERNS[PATTERN__PLAYER_IP], g_szBuffer)
	}
}

/* -------------------- */

stock func_FindPatterns() {
	for(new i; i < PATTERNS_ENUM; i++) {
		if(contain(g_eMsgData[MSG_BODY], PATTERNS[i]) != -1) {
			SetPatternBit(i)
		}
	}
}

/* -------------------- */

stock func_ReplaceML(pPlayer) {
	formatex(g_szMsg, chx(g_szMsg), "%L", pPlayer, g_eMsgData[MSG_BODY])
}

/* -------------------- */

public plugin_end() {
	if(g_aMsgArray) {
		ArrayDestroy(g_aMsgArray)
	}

	if(g_aAuReArray) {
		ArrayDestroy(g_aAuReArray)
	}

#if defined CMD_NAME
	if(g_hVault != INVALID_HANDLE) {
		nvault_close(g_hVault)
	}
#endif
}

/* -------------------- */

#if defined CMD_NAME
	public client_authorized(pPlayer, const szAuthID[]) {
		if(g_hVault == INVALID_HANDLE) {
			g_bDisabled[pPlayer] = false
			return
		}

		g_bDisabled[pPlayer] = bool:nvault_get(g_hVault, szAuthID)

	#if defined OBSOLETE_DAYS
		if(g_bDisabled[pPlayer]) {
			nvault_touch(g_hVault, szAuthID)
		}
	#endif
	}
#endif

/* -------------------- */

func_RegCvars() {
	bind_pcvar_float( create_cvar( "hirdeto_freq_min", "60",
		.description = "Minimális időköz az automatikus üzenetek között" ),
		g_eCvar[CVAR__FREQ_MIN]	);

	bind_pcvar_float( create_cvar( "hirdeto_freq_max", "60",
		.description = "Maximális időköz az automatikus üzenetek között" ),
		g_eCvar[CVAR__FREQ_MAX] );

	bind_pcvar_num( create_cvar( "hirdeto_for_all", "1",
		.description = "Ha 0, az élő játékosok nem látják az automatikus üzeneteket." ),
		g_eCvar[CVAR__FOR_ALL] );

	bind_pcvar_num( create_cvar( "hirdeto_mode", "0",
		.description = "Megjelenítési mód:^n\
		0 - Összes üzenet megjelenítése^n\
		1 - Csak azok, amelyek '0' üzemmódúak, vagy amelyek megfelelnek a cvar aktuális értékének." ),
		g_eCvar[CVAR__MODE] );

	bind_pcvar_num( create_cvar( "hirdeto_sound_for_all", "0",
		.description = "Hang mód:^n\
		0 - Csak a halott játékos hallja a hangokat^n\
		1 - Hangok lejátszása minden játékos számára" ),
		g_eCvar[CVAR__SOUND_FOR_ALL] );

#if defined AUTO_CFG
	AutoExecConfig()
#endif
}

/* -------------------- */

stock func_SendAudio(pPlayer, const szSample[]) {
	message_begin(MSG_ONE_UNRELIABLE, g_iMsgIdSendAudio, .player = pPlayer)
	write_byte(pPlayer)
	write_string(szSample)
	write_short(PITCH_NORM)
	message_end()
}