
/*************************************************************************************
******* PRAGMA ***********************************************************************
*************************************************************************************/

///
/// WHETHER OR NOT TO FORCE ';' AFTER EACH LINE
///
#pragma semicolon 1

///
/// WHETHER OR NOT TO INCREASE THE MEMORY FOR THIS SCRIPT [[[ DEFAULT 2^22 ( 4194304 ) ]]]
///
#pragma dynamic 4194304 /// B [[[ INCREASE THIS IF YOU ARE GETTING JUNKY ERROR LOGS ]]]

///
/// WHETHER OR NOT TO USE THE '\' AS A CONTROL CHARACTER
///
/// INSTEAD OF THE DEFAULT ONE, WHICH IS '^'
///
#pragma ctrlchar '\'

///
/// SETS THE TAB SIZE ( '\t' AND ' ' ) TO 0
///
/// GLOBALLY
///
#pragma tabsize 0

///
/// REQUIRES THE XSTATS MODULE IF AVAILABLE [ client_death ( ) ]
///
#pragma reqclass xstats

///
/// XSTATS DEFAULTS [ FOUR MODS SUPPORTED BY NOW ]
///
#pragma defclasslib xstats csx
#pragma defclasslib xstats dodx
#pragma defclasslib xstats tfcx
#pragma defclasslib xstats tsx

/*************************************************************************************
******* INCLUDE **********************************************************************
*************************************************************************************/

///
/// AMX MOD X HEADER FILE
///
#include < amxmodx> /// plugin_init ( ) +

///
/// AMX MOD X CUSTOM HEADER FILE
///
#include < amxmisc > /// get_configsdir ( ) +

///
/// SQL HEADER FILE
///
#include < sqlx > /// SQL_ThreadQuery ( ) +

///
/// FAKE META HEADER FILE
///
#include < fakemeta > /// FM_MessageBegin +

///
/// HAM SANDWICH HEADER FILE [[[ FOR GAMES WITHOUT THE "client_death ( )" FORWARD ( XSTATS MODULE ) AND WITHOUT "DeathMsg" ]]]
///
#include < hamsandwich > /// Ham_Killed +

/*************************************************************************************
******* NATIVE ***********************************************************************
*************************************************************************************/

///
/// OLDER AMXX EDITIONS DON'T HAVE THIS [[[ 'SQL_SetCharset ( )' ]]]
///

#if !defined SQL_SetCharset

native bool: SQL_SetCharset(Handle: pSqlDbOrSqlTuple, const szCharSet[]);

#endif

static bool: g_bSQL_SetCharset_Unavail = false;

///
/// OLDER AMXX EDITIONS DON'T HAVE THIS [[[ 'strtok2 ( )' ]]]
///

#if !defined strtok2

#define strtok2(%0,%1,%2,%3,%4,%5,%6) strtok(%0, %1, %2, %3, %4, %5, 0 /** AUTO TRIMMING IS BUGGY IN 'strtok ( )' */)

#endif

///
/// OLDER AMXX EDITIONS DON'T HAVE THIS [[[ 'ByteCountToCells ( )' ]]]
///

#if !defined ByteCountToCells

#define ByteCountToCells(%0) abs(%0) /** 'abs ( )' SHOULD WORK JUST FINE */

#endif

/*************************************************************************************
******* DEFINE ***********************************************************************
*************************************************************************************/

///
/// THE PLUGIN'S VERSION
///
#define QS_PLUGIN_VERSION ( "7.5" ) /// "7.5"

///
/// ###################################################################################################
///

///
/// THE CONFIG FILE NAME
///
#define QS_CFG_FILE_NAME ( "AQS.ini" ) /// "AQS.ini"

///
/// THE LOG FILE NAME
///
#define QS_LOG_FILE_NAME ( "AQS.log" ) /// "AQS.log"

///
/// ###################################################################################################
///

///
/// ON BY DEFAULT TO PLAYERS WHEN THEY JOIN THE GAME SERVER
///
#define QS_ON_BY_DEFAULT ( 1 ) /// 1

///
/// ###################################################################################################
///

///
/// CSTRIKE AND CZERO 'TE' TEAM NUMBER
///
#define QS_CSCZ_TEAM_TE ( 1 ) /// 1

///
/// CSTRIKE AND CZERO 'CT' TEAM NUMBER
///
#define QS_CSCZ_TEAM_CT ( 2 ) /// 2

///
/// ###################################################################################################
///

///
/// TEAM KILL
///
#define QS_TEAM_KILL_YES ( 1 ) /// 1

///
/// NO TEAM KILL
///
#define QS_TEAM_KILL_NO ( 0 ) /// 0

///
/// ###################################################################################################
///

///
/// SECONDS DELAY TO SHOW THE INFORMATION MESSAGE REGARDING '/SOUNDS' COMMAND
///
/// AFTER THE PLAYER JOINS THE GAME SERVER
///
#define QS_PLUGIN_INFO_DELAY ( 6.000000 ) /// 6

///
/// ###################################################################################################
///

///
/// THE HATTRICK FEATURE :: ROUND END TRIGGER DELAY
///
#define QS_HATTRICK_ROUND_END_DELAY ( 2.800000 ) /// 2.8

///
/// THE HATTRICK FEATURE :: ROUND END TRIGGER DELAY /// # DAY OF DEFEAT # ///
///
#define QS_HATTRICK_ROUND_END_DELAY_DOD ( 0.000001 ) /// .000001 [[[ DAY OF DEFEAT ]]]

///
/// ###################################################################################################
///

///
/// THE FLAWLESS VICTORY FEATURE :: ROUND END TRIGGER DELAY
///
#define QS_FLAWLESS_ROUND_END_DELAY ( 1.200000 ) /// 1.2

///
/// MINIMUM TOTAL PLAYERS IN A TEAM IN ORDER TO ALLOW THE FLAWLESS FEATURE TO BE TRIGGERED FOR THAT TEAM
///
#define QS_FLAWLESS_MIN_PLAYERS_IN_TEAM ( 2 ) /// 2

///
/// ###################################################################################################
///

///
/// THE LAST MAN STANDING FEATURE :: TRIGGER DELAY
///
#define QS_STANDING_TRIGGER_DELAY ( 1.000000 ) /// 1

///
/// ###################################################################################################
///

///
/// THE DOUBLE KILL FEATURE :: TRIGGER TIME FRAME
///
/// THE KILLER MUST KILL TWO VICTIMS WITHIN THIS TIME FRAME TO TRIGGER THE DOUBLE KILL EVENT
///
#define QS_DOUBLE_KILL_DELAY ( 0.100000 ) /// .1

///
/// ###################################################################################################
///

///
/// THE ROUND START FEATURE :: DAY OF DEFEAT MINIMUM DELAY SECONDS
///
#define QS_ROUND_START_MIN_DOD_DELAY ( 1.300000 ) /// 1.3

///
/// ###################################################################################################
///

///
/// IF THE STEAM SERVERS ARE DOWN OR IF THE MYSQL SERVER IS DOWN
///
/// WAIT A FEW SECONDS BEFORE PERFORMING VALIDITY CHECKS AGAIN
///
#define QS_CONNECTION_DELAY ( 2.000000 ) /// 2

///
/// ###################################################################################################
///

///
/// INVALID REQUIRED KILLS [[[ A TRULY HUGE NUMBER ]]]
///
#define QS_INVALID_REQ_KILLS ( 0x0FFFFFFF ) /// 268435455 [[[ 0x0FFFFFFF ]]]

///
/// INVALID TEAM ID
///
#define QS_INVALID_TEAM ( 0x000000FF ) /// 255 [[[ 0x000000FF ]]]

///
/// INVALID PLAYER ID
///
#define QS_INVALID_PLAYER ( 0 ) /// 0

///
/// INVALID PLAYER USER ID
///
#define QS_INVALID_USER_ID ( -1 ) /// -1

///
/// INVALID USER MESSAGE ID
///
#define QS_INVALID_MSG ( 0 ) /// 0

///
/// INVALID WEAPON ID
///
#define QS_INVALID_WEAPON ( 0 ) /// 0

///
/// INVALID HIT PLACE ID
///
#define QS_INVALID_PLACE ( 0 ) /// 0

///
/// INVALID HUD MSG SYNC OBJECT
///
#define QS_INVALID_HUD_MSG_SYNC_OBJECT ( -1 ) /// -1

///
/// ###################################################################################################
///

///
/// MINIMUM PLAYER USER ID
///
#define QS_MIN_USER_ID ( 0 ) /// 0

///
/// MINIMUM PLAYER ID
///
#define QS_MIN_PLAYER ( 1 ) /// 1

///
/// ###################################################################################################
///

///
/// MAXIMUM PLAYERS THE GAME SERVER CAN HANDLE
///
#define QS_MAX_PLAYERS ( 32 ) /// 32

///
/// ###################################################################################################
///

///
/// MAXIMUM PLAYER NAME LENGTH
///
#define QS_NAME_MAX_LEN ( 32 ) /// 32

///
/// MAXIMUM PLAYER STEAM LENGTH
///
#define QS_STEAM_MAX_LEN ( 32 ) /// 32

///
/// GAME MOD NAME MAXIMUM LENGTH
///
#define QS_MOD_MAX_LEN ( 64 ) /// 64

///
/// SOUND FILE PATH MAXIMUM LENGTH
///
#define QS_SND_MAX_LEN ( 256 ) /// 256

///
/// WORD MAXIMUM LENGTH [ "GUY", "MAN STANDING", "ONE", "COUNTER-TERRORIST", ... ]
///
#define QS_WORD_MAX_LEN ( 64 ) /// 64

///
/// HUD MESSAGE'S MAXIMUM LENGTH
///
#define QS_HUD_MSG_MAX_LEN ( 384 ) /// 384

///
/// ###################################################################################################
///

///
/// EVERYONE ( ALL PLAYERS )
///
#define QS_EVERYONE ( 0 ) /// 0

///
/// ###################################################################################################
///

///
/// THE WORLDSPAWN
///
#define QS_WORLDSPAWN ( 0 ) /// 0

///
/// ###################################################################################################
///

///
/// THE WORLDSPAWN'S NAME
///
#define QS_WORLDSPAWN_NAME ( "WORLDSPAWN" ) /// "WORLDSPAWN"

///
/// ###################################################################################################
///

///
/// THE DEFAULT WORD FOR THE 'THE LAST MAN STANDING' EVENT
///
#define QS_TLMSTANDING_WORD ( "MAN STANDING" ) /// "MAN STANDING"

///
/// ###################################################################################################
///

///
/// THE DEFAULT WORD FOR THE 'GRENADE' WEAPON
///
#define QS_DEF_GRENADE_NAME ( "NADE" ) /// "NADE"

///
/// THE DEFAULT WORD FOR THE 'KNIFE' WEAPON
///
#define QS_DEF_KNIFE_NAME ( "KNIF" ) /// "KNIF"

///
/// ###################################################################################################
///

///
/// MINIMUM UNSIGNED BYTE
///
#define QS_MIN_BYTE ( 0x00000000 ) /// 0 [[[ 0x00000000 ]]]

///
/// MAXIMUM UNSIGNED BYTE
///
#define QS_MAX_BYTE ( 0x000000FF ) /// 255 [[[ 0x000000FF ]]]

///
/// ###################################################################################################
///

///
/// CENTERED HUD MESSAGE'S "X" POSITION
///
#define QS_HUD_MSG_X_POS ( -1.000000 ) /// -1

///
/// ###################################################################################################
///

///
/// HUD MESSAGE'S HOLD TIME ( SECONDS TO BE DISPLAYED )
///
#define QS_HUD_MSG_HOLD_TIME ( 5.000000 ) /// 5

///
/// ###################################################################################################
///

///
/// HUD MESSAGE'S EFFECTS
///
#define QS_HUD_MSG_EFFECTS ( 0 ) /// 0

///
/// ###################################################################################################
///

///
/// HUD MESSAGE'S EFFECTS TIME
///
#define QS_HUD_MSG_EFFECTS_TIME ( 0.000001 ) /// .000001

///
/// ###################################################################################################
///

///
/// HUD MESSAGE'S FADE IN TIME
///
#define QS_HUD_MSG_FADE_IN_TIME ( 0.000001 ) /// .000001

///
/// ###################################################################################################
///

///
/// HUD MESSAGE'S FADE OUT TIME
///
#define QS_HUD_MSG_FADE_OUT_TIME ( 0.000001 ) /// .000001

///
/// ###################################################################################################
///

///
/// HUD MESSAGE'S ALPHA AMOUNT ( 255 = MAX & 0 = MIN )
///
#define QS_HUD_MSG_ALPHA_AMOUNT ( 255 ) /// 255

///
/// ###################################################################################################
///

///
/// [ MONSTER KILL, MULTI KILL, UNSTOPPABLE, .. ] HUD MESSAGE'S "Y" ( VERTICAL ) POSITION
///
#define QS_STREAK_Y_POS ( 0.180000 ) /// .18

///
/// [ MONSTER KILL, MULTI KILL, UNSTOPPABLE, .. ] HUD MESSAGE'S "Y" ( VERTICAL ) POSITION <<<--- DAY OF DEFEAT --->>>
///
#define QS_STREAK_Y_POS_DOD ( 0.160000 ) /// .16

/// @@@@
/// ### "imessage.amxx" ( 0.200000 ) /// .2
/// @@@@

///
/// [ SUICIDE, KNIFE, GRENADE, .. ] HUD MESSAGE'S "Y" ( VERTICAL ) POSITION
///
#define QS_EVENT_Y_POS ( 0.220000 ) /// .22

///
/// [ SUICIDE, KNIFE, GRENADE, .. ] HUD MESSAGE'S "Y" ( VERTICAL ) POSITION <<<--- DAY OF DEFEAT --->>>
///
#define QS_EVENT_Y_POS_DOD ( 0.240000 ) /// .24

///
/// [ REVENGE ] HUD MESSAGE'S "Y" ( VERTICAL ) POSITION
///
#define QS_REVENGE_Y_POS ( 0.240000 ) /// .24

///
/// [ REVENGE ] HUD MESSAGE'S "Y" ( VERTICAL ) POSITION <<<--- DAY OF DEFEAT --->>>
///
#define QS_REVENGE_Y_POS_DOD ( 0.280000 ) /// .28

///
/// [ THE LAST MAN STANDING ] CSTRIKE AND CZERO HUD MESSAGE'S "Y" ( VERTICAL ) POSITION
///
#define QS_STANDING_Y_POS ( 0.260000 ) /// .26

///
/// [ FLAWLESS VICTORY EVENT ] HUD MESSAGE'S "Y" ( VERTICAL ) POSITION
///
#define QS_FLAWLESS_Y_POS ( 0.280000 ) /// .28

///
/// [ HATTRICK ( THE LEADER OF THE ROUND ) ] HUD MESSAGE'S "Y" ( VERTICAL ) POSITION
///
#define QS_HATTRICK_Y_POS ( 0.300000 ) /// .3

///
/// [ HATTRICK ( THE LEADER OF THE ROUND ) ] HUD MESSAGE'S "Y" ( VERTICAL ) POSITION <<<--- DAY OF DEFEAT --->>>
///
#define QS_HATTRICK_Y_POS_DOD ( 0.320000 ) /// .32

///
/// [ PREPARE TO FIGHT, .. ] HUD MESSAGE'S "Y" ( VERTICAL ) POSITION
///
#define QS_ROUND_Y_POS ( 0.320000 ) /// .32

///
/// [ PREPARE TO FIGHT, .. ] HUD MESSAGE'S "Y" ( VERTICAL ) POSITION <<<--- DAY OF DEFEAT --->>>
///
#define QS_ROUND_Y_POS_DOD ( 0.320000 ) /// .32

///
/// ###################################################################################################
///

///
/// DEATHMSG USER MESSAGE'S 'BYTE' STATUSES
///
enum /** DEATHMSG USER MESSAGE'S 'BYTE' STATUS */
{
    QS_DEATHMSG_NONE = 0, QS_DEATHMSG_KILLER = 1, QS_DEATHMSG_VICTIM = 2, QS_DEATHMSG_MAX = 3,
};

///
/// ###################################################################################################
///

///
/// HUD MESSAGE PURPOSES
///
enum /** HUD MESSAGE PURPOSE */
{
    QS_HUD_STREAK = 0, QS_HUD_EVENT = 1, QS_HUD_REVENGE = 2, QS_HUD_STANDING = 3, QS_HUD_FLAWLESS = 4, QS_HUD_HATTRICK = 5, QS_HUD_ROUND = 6, QS_HUD_MAX = 7,
};

///
/// ###################################################################################################
///

///
/// CUSTOM COLORED CHAT SAY TEXT COLORS
///
enum /** CUSTOM COLORED CHAT SAY TEXT COLOR */
{
    QS_CC_ST_X03_MIN = 33, QS_CC_ST_X03_GREY = QS_CC_ST_X03_MIN, QS_CC_ST_X03_RED = 34, QS_CC_ST_X03_BLUE = 35, QS_CC_ST_X03_MAX = QS_CC_ST_X03_BLUE,
};

/*************************************************************************************
******* GLOBAL VARIABLES *************************************************************
*************************************************************************************/

///
/// THE PLUGIN ON/ OFF
///
static bool: g_bEnabled = false;

///
/// CHAT '/SOUNDS' COMMAND ON/ OFF
///
static bool: g_bChatCmd = false;

///
/// '/SOUNDS' CHAT INFO AFTER THE PLAYER JOINS THE GAME SERVER ON/ OFF
///
static bool: g_bChatInfo = false;

///
/// WHEN TRUE, DO NOT SHOW THE CHAT '/SOUNDS' INFORMATION ANYMORE IF IT HAS ALREADY BEEN SHOWN TO THAT STEAM
///
static bool: g_bSkipExisting = false;

///
/// WHEN TRUE, DO NOT SHOW THAT THE USER HAS TYPED '/sounds' INTO THE CHAT AREA
///
static bool: g_bHideCmd = true;

/**
 * HEAD SHOT
 */

///
/// HEAD SHOT ON/ OFF
///
static bool: g_bHShot = false;

///
/// HEAD SHOT IF TEAM KILL
///
static bool: g_bHShotIfTeamKill = false;

///
/// HEAD SHOT MESSAGE ON/ OFF
///
static bool: g_bHShotMsg = false;

///
/// HEAD SHOT MESSAGE
///
static g_szHShotMsg[QS_HUD_MSG_MAX_LEN] = { EOS, ... };

///
/// HEAD SHOT SOUNDS COUNT
///
static g_nHShotSize = 0;

///
/// HEAD SHOT ONLY FOR KILLER
///
static bool: g_bHShotOnlyKiller = false;

///
/// HEAD SHOT SOUNDS CONTAINER
///
static Array: g_pHShot = Invalid_Array;

/**
 * REVENGE
 */

///
/// REVENGE ON/ OFF
///
static bool: g_bRevenge = false;

///
/// REVENGE IF TEAM KILL
///
static bool: g_bRevengeIfTeamKill = false;

///
/// REVENGE MESSAGE FOR KILLER ON/ OFF
///
static bool: g_bRevengeMsgKiller = false;

///
/// REVENGE MESSAGE FOR VICTIM ON/ OFF
///
static bool: g_bRevengeMsgVictim = false;

///
/// REVENGE MESSAGE FOR KILLER ( IF ENABLED )
///
static g_szRevengeMsgKiller[QS_HUD_MSG_MAX_LEN] = { EOS, ... };

///
/// REVENGE MESSAGE FOR VICTIM ( IF ENABLED )
///
static g_szRevengeMsgVictim[QS_HUD_MSG_MAX_LEN] = { EOS, ... };

///
/// REVENGE SOUNDS COUNT
///
static g_nRevengeSize = 0;

///
/// REVENGE ONLY FOR KILER
///
static bool: g_bRevengeOnlyKiller = false;

///
/// REVENGE SOUNDS CONTAINER
///
static Array: g_pRevenge = Invalid_Array;

/**
 * HATTRICK
 *
 * THE LEADER OF THE CURRENT ROUND
 *
 * CSTRIKE AND CZERO ONLY
 */

///
/// HATTRICK ON/ OFF
///
static bool: g_bHattrick = false;

///
/// HATTRICK MESSAGE ON/ OFF
///
static bool: g_bHattrickMsg = false;

///
/// HATTRICK CHAT ( TALK ) MESSAGE ON/ OFF
///
static bool: g_bHattrickMsgTalk = false;

///
/// HATTRICK IGNORE THE TEAM KILL FRAG
///
static bool: g_bHattrickIgnoreTeamKillFrag = false;

///
/// HATTRICK MESSAGE
///
static g_szHattrickMsg[QS_HUD_MSG_MAX_LEN] = { EOS, ... };

///
/// HATTRICK SOUNDS COUNT
///
static g_nHattrickSize = 0;

///
/// MINIMUM KILLS REQUIRED FOR HATTRICK
///
static g_nMinKillsForHattrick = 0;

///
/// DECREASE FRAG IF SUICIDE BY 'KILL' COMMAND
///
static bool: g_bHattrickDecrease = false;

///
/// HATTRICK SOUNDS CONTAINER
///
static Array: g_pHattrick = Invalid_Array;

///
/// HATTRICK ALL PLAYERS ON THE SERVER
///
static bool: g_bHattrickToAll = false;

/**
 * THE LAST MAN STANDING
 *
 * CSTRIKE AND CZERO ONLY
 */

///
/// THE LAST MAN STANDING ON/ OFF
///
static bool: g_bTLMStanding = false;

///
/// THE LAST MAN STANDING TEAM MESSAGE ON/ OFF
///
static bool: g_bTLMStandingTeamMsg = false;

///
/// THE LAST MAN STANDING SELF MESSAGE ON/ OFF
///
static bool: g_bTLMStandingSelfMsg = false;

///
/// THE LAST MAN STANDING TEAM MESSAGE
///
static g_szTLMStandingTeamMsg[QS_HUD_MSG_MAX_LEN] = { EOS, ... };

///
/// THE LAST MAN STANDING SELF MESSAGE
///
static g_szTLMStandingSelfMsg[QS_HUD_MSG_MAX_LEN] = { EOS, ... };

///
/// THE LAST MAN STANDING SOUNDS COUNT
///
static g_nTLMStandingSize = 0;

///
/// THE LAST MAN STANDING SOUNDS CONTAINER
///
static Array: g_pTLMStanding = Invalid_Array;

///
/// THE LAST MAN STANDING WORDS CONTAINER
///
static Array: g_pTLMStandingWords = Invalid_Array;

///
/// THE LAST MAN STANDING WORDS COUNT
///
static g_nTLMStandingWordsSize = 0;

///
/// THE LAST MAN STANDING PLAYED THIS ROUND [ TE ]
///
static bool: g_bTLMStandingDone_TE = false;

///
/// THE LAST MAN STANDING PLAYED THIS ROUND [ CT ]
///
static bool: g_bTLMStandingDone_CT = false;

/**
 * SUICIDE
 */

///
/// SUICIDE ON/ OFF
///
static bool: g_bSuicide = false;

///
/// SUICIDE MESSAGE ON/ OFF
///
static bool: g_bSuicideMsg = false;

///
/// SUICIDE MESSAGE
///
static g_szSuicideMsg[QS_HUD_MSG_MAX_LEN] = { EOS, ... };

///
/// SUICIDE SOUNDS COUNT
///
static g_nSuicideSize = 0;

///
/// SUICIDE SOUNDS CONTAINER
///
static Array: g_pSuicide = Invalid_Array;

/**
 * GRENADE
 */

///
/// GRENADE ON/ OFF
///
static bool: g_bGrenade = false;

///
/// GRENADE MESSAGE ON/ OFF
///
static bool: g_bGrenadeMsg = false;

///
/// GRENADE IF TEAM KILL
///
static bool: g_bGrenadeIfTeamKill = false;

///
/// GRENADE KILL MESSAGE
///
static g_szGrenadeMsg[QS_HUD_MSG_MAX_LEN] = { EOS, ... };

///
/// GRENADE WEAPON NAMES
///
static Array: g_pGrenadeNames = Invalid_Array;

///
/// TOTAL GRENADE WEAPON NAMES
///
static g_nGrenadeNames = 0;

///
/// GRENADE SOUNDS COUNT
///
static g_nGrenadeSize = 0;

///
/// GRENADE SOUNDS CONTAINER
///
static Array: g_pGrenade = Invalid_Array;

/**
 * TEAM KILL
 *
 * DOD, CSTRIKE AND CZERO ONLY
 */

///
/// TEAM KILL ON/ OFF
///
static bool: g_bTKill = false;

///
/// TEAM KILL MESSAGE ON/ OFF
///
static bool: g_bTKillMsg = false;

///
/// TEAM KILL MESSAGE
///
static g_szTKillMsg[QS_HUD_MSG_MAX_LEN] = { EOS, ... };

///
/// TEAM KILL SOUNDS COUNT
///
static g_nTKillSize = 0;

///
/// TEAM KILL SOUNDS CONTAINER
///
static Array: g_pTKill = Invalid_Array;

/**
 * KNIFE
 */

///
/// KNIFE ON/ OFF
///
static bool: g_bKnife = false;

///
/// KNIFE IF TEAM KILL
///
static bool: g_bKnifeIfTeamKill = false;

///
/// KNIFE MESSAGE ON/ OFF
///
static bool: g_bKnifeMsg = false;

///
/// KNIFE KILL MESSAGE
///
static g_szKnifeMsg[QS_HUD_MSG_MAX_LEN] = { EOS, ... };

///
/// KNIFE WEAPON NAMES
///
static Array: g_pKnifeNames = Invalid_Array;

///
/// TOTAL KNIFE WEAPON NAMES
///
static g_nKnifeNames = 0;

///
/// KNIFE KILL SOUNDS COUNT
///
static g_nKnifeSize = 0;

///
/// KNIFE SOUNDS CONTAINER
///
static Array: g_pKnife = Invalid_Array;

/**
 * FIRST BLOOD
 */

///
/// FIRST BLOOD ON/ OFF
///
static bool: g_bFBlood = false;

///
/// FIRST BLOOD IF DIED BY KILL CONSOLE COMMAND OR SWITCH TEAM
///
static bool: g_bFBloodAllowKillCmd = false;

///
/// FIRST BLOOD IF DIED BY WORLD DAMAGE
///
static bool: g_bFBloodAllowWorldDmg = false;

///
/// FIRST BLOOD IF TEAM KILL TRIGGERED
///
static bool: g_bFBloodAllowTeamKill = false;

///
/// FIRST BLOOD MESSAGE ON/ OFF
///
static bool: g_bFBloodMsg = false;

///
/// FIRST BLOOD WHEN NO KILLER MESSAGE ON/ OFF
///
static bool: g_bFBloodMsgNoKiller = false;

///
/// FIRST BLOOD MESSAGE
///
static g_szFBloodMsg[QS_HUD_MSG_MAX_LEN] = { EOS, ... };

///
/// FIRST BLOOD MESSAGE KILLER DISCONNECTED
///
static g_szFBloodMsgNoKiller[QS_HUD_MSG_MAX_LEN] = { EOS, ... };

///
/// FIRST BLOOD SOUNDS COUNT
///
static g_nFBloodSize = 0;

///
/// FIRST BLOOD VARIABLE
///
static g_nFBlood = 0;

///
/// FIRST BLOOD SOUNDS CONTAINER
///
static Array: g_pFBlood = Invalid_Array;

/**
 * K. STREAK
 */

///
/// K. STREAK ON/ OFF
///
static bool: g_bKStreak = false;

///
/// K. STREAK SOUNDS IGNORED ON TEAM KILL
///
static bool: g_bKStreakIgnoreOnTeamKill = false;

///
/// K. STREAK SOUNDS COUNT
///
static g_nKStreakSize = 0;

///
/// K. STREAK REQUIRED KILLS COUNT
///
static g_nKStreakRKillsSize = 0;

///
/// K. STREAK MESSAGES COUNT
///
static g_nKStreakMsgSize = 0;

///
/// K. STREAK SOUNDS CONTAINER
///
static Array: g_pKStreakSnds = Invalid_Array;

///
/// K. STREAK MESSAGES CONTAINER
///
static Array: g_pKStreakMsgs = Invalid_Array;

///
/// K. STREAK REQUIRED KILLS CONTAINER
///
static Array: g_pKStreakReqKills = Invalid_Array;

/**
 * ROUND START
 *
 * DOD, CSTRIKE AND CZERO ONLY
 */

///
/// ROUND START ON/ OFF
///
static bool: g_bRStart = false;

///
/// ROUND START MESSAGE ON/ OFF
///
static bool: g_bRStartMsg = false;

///
/// ROUND START MESSAGE
///
static g_szRStartMsg[QS_HUD_MSG_MAX_LEN] = { EOS, ... };

///
/// ROUND START SOUNDS COUNT
///
static g_nRStartSize = 0;

///
/// ROUND START SOUNDS CONTAINER
///
static Array: g_pRStart = Invalid_Array;

///
/// ROUND START DELAY
///
static Float: g_fRStartDelay = 0.000000;

/**
 * DOUBLE KILL
 */

///
/// DOUBLE KILL ON/ OFF
///
static bool: g_bDKill = false;

///
/// DOUBLE KILL IF TEAM KILL ON/ OFF
///
static bool: g_bDKillOnTeamKill = false;

///
/// DOUBLE KILL MESSAGE ON/ OFF
///
static bool: g_bDKillMsg = false;

///
/// DOUBLE KILL MESSAGE
///
static g_szDKillMsg[QS_HUD_MSG_MAX_LEN] = { EOS, ... };

///
/// DOUBLE KILL SOUNDS COUNT
///
static g_nDKillSize = 0;

///
/// DOUBLE KILL SOUNDS CONTAINER
///
static Array: g_pDKill = Invalid_Array;

/**
 * FLAWLESS
 *
 * IF A TEAM KILLS THE OTHER ONE W/ O GETTING ANY CASUALTIES
 *
 * CSTRIKE AND CZERO ONLY
 */

///
/// FLAWLESS ON/ OFF
///
static bool: g_bFlawless = false;

///
/// FLAWLESS MESSAGE ON/ OFF
///
static bool: g_bFlawlessMsg = false;

///
/// FLAWLESS MESSAGE
///
static g_szFlawlessMsg[QS_HUD_MSG_MAX_LEN] = { EOS, ... };

///
/// FLAWLESS TEAM NAME FOR TEAM [ TE ]
///
static g_szFlawlessTeamName_TE[QS_WORD_MAX_LEN] = { EOS, ... };

///
/// FLAWLESS TEAM NAME FOR TEAM [ CT ]
///
static g_szFlawlessTeamName_CT[QS_WORD_MAX_LEN] = { EOS, ... };

///
/// FLAWLESS SOUNDS COUNT
///
static g_nFlawlessSize = 0;

///
/// FLAWLESS SOUNDS CONTAINER
///
static Array: g_pFlawless = Invalid_Array;

/**
 * HUD MESSAGE [ TE_TEXTMESSAGE ]
 */

///
/// CHANNEL HANDLES
///
static g_pnHudMsgObj[QS_HUD_MAX] = { QS_INVALID_HUD_MSG_SYNC_OBJECT, ... };

///
/// RED
///
static g_nRed = QS_MIN_BYTE;

///
/// RANDOM RED
///
static bool: g_bRandomRed = false;

///
/// GREEN
///
static g_nGreen = QS_MIN_BYTE;

///
/// RANDOM GREEN
///
static bool: g_bRandomGreen = false;

///
/// BLUE
///
static g_nBlue = QS_MIN_BYTE;

///
/// RANDOM BLUE
///
static bool: g_bRandomBlue = false;

/**
* GAME RELATED
*/

///
/// CS/ CZ RUNNING
///
static bool: g_bCSCZ = false;

///
/// DOD RUNNING
///
static bool: g_bDOD = false;

///
/// KILLS THIS ROUND
///
static g_nKillsThisRound = 0;

///
/// RESETS ALL THE ROUND STATS
///
static bool: g_bResetAllTheRoundStats = false;

///
/// MOD NAME
///
static g_szMod[QS_MOD_MAX_LEN] = { EOS, ... };

///
/// MAXIMUM PLAYERS THE GAME SERVER CAN HANDLE
///
static g_nMaxPlayers = QS_MAX_PLAYERS;

///
/// THE "DeathMsg" USER MESSAGE'S ID
///
static g_nDeathMsg = QS_INVALID_MSG;

///
/// THE "SayText" USER MESSAGE'S ID
///
static g_nSayText = QS_INVALID_MSG;

///
/// CHAT COLORS ON/ OFF [ ON = CS/ CZ ONLY ]
///
static bool: g_bColors = false;

///
/// ON DEATHMSG YES/ NO
///
static bool: g_bOnDeathMsg = false;

///
/// DEATHMSG'S BYTE STATUS
///
static g_nDeathMsgByteStatus = QS_DEATHMSG_NONE;

///
/// DEATHMSG ONLY AVAILABLE [[[ NO XSTATS MODULE " client_death ( ) " FORWARD ]]]
///
static bool: g_bDeathMsgOnly = false;

///
/// ARRAYS CREATED YES/ NO
///
static bool: g_bArraysCreated = false;

///
/// CACHED KILLER ID
///
static g_nKiller = QS_INVALID_PLAYER;

///
/// CACHED VICTIM ID
///
static g_nVictim = QS_INVALID_PLAYER;

///
/// CACHED WEAPON ID
///
static g_nWeapon = QS_INVALID_WEAPON;

///
/// CACHED HIT PLACE ID
///
static g_nPlace = QS_INVALID_PLACE;

///
/// CACHED TEAM KILL BOOLEAN
///
static g_nTeamKill = QS_TEAM_KILL_NO;

/**
* SQL STORAGE STUFF
*/

///
/// SQL STORAGE ON/ OFF
///
static bool: g_bSql = false;

///
/// SQL STORAGE LOCAL/ REMOTE
///
static bool: g_bSqlLocal = false;

///
/// SQL DATABASE HANDLE
///
static Handle: g_pSqlDb = Empty_Handle;

///
/// SQL FULL OR FAST STEAM STORAGE
///
static bool: g_bSqlFullSteam = false;

///
/// SQL ADDRESS
///
static g_szSqlAddr[128] = { EOS, ... };

///
/// SQL DATABASE USER NAME
///
static g_szSqlUser[64] = { EOS, ... };

///
/// SQL DATABASE PASSWORD
///
static g_szSqlPassword[64] = { EOS, ... };

///
/// SQL EXTENSION TO USE
///
static g_szSqlExtension[64] = { EOS, ... };

///
/// SQL DATABASE NAME
///
static g_szSqlDatabase[64] = { EOS, ... };

///
/// SQL PRIMARY ( MAIN ) CHARSET
///
static g_szSqlChars[64] = { EOS, ... };

///
/// SQL SECONDARY CHARSET
///
static g_szSqlSecChars[64] = { EOS, ... };

///
/// SQL TIMEOUT SECONDS [ 0 = AMX MOD X'S DEFAULT ( SEE THE "CORE.INI" FILE ) ]
///
static g_nSqlMaxSecondsError = 0;

///
/// SQL TOTAL TABLES TO CREATE
///
static g_nSqlTablesToCreate = 0;

/**
* PLAYERS RELATED
*/

///
/// TOTAL KILLS PER PLAYER PER LIFE
///
/// RESETS ON PLAYER DEATH
///
static g_pnKills[QS_MAX_PLAYERS + 1] = { 0, ... };

///
/// TOTAL KILLS PER PLAYER PER ROUND
///
/// RESETS NEXT ROUND
///
static g_pnKillsThisRound[QS_MAX_PLAYERS + 1] = { 0, ... };

///
/// HLTV
///
static bool: g_pbHLTV[QS_MAX_PLAYERS + 1] = { false, ... };

///
/// BOT
///
static bool: g_pbBOT[QS_MAX_PLAYERS + 1] = { false, ... };

///
/// IN GAME
///
static bool: g_pbInGame[QS_MAX_PLAYERS + 1] = { false, ... };

///
/// VALID STEAM AND AUTHORIZED
///
static bool: g_pbValidSteam[QS_MAX_PLAYERS + 1] = { false, ... };

///
/// NAME
///
static g_pszName[QS_MAX_PLAYERS + 1][QS_NAME_MAX_LEN];

///
/// STEAM
///
static g_pszSteam[QS_MAX_PLAYERS + 1][QS_STEAM_MAX_LEN];

///
/// PLAYER PREFERENCES LOADED
///
static bool: g_pbLoaded[QS_MAX_PLAYERS + 1] = { false, ... };

///
/// PLAYER PREFERENCES EXISTING INTO THE DATABASE
///
static bool: g_pbExisting[QS_MAX_PLAYERS + 1] = { false, ... };

///
/// PLAYER PREFERENCES ACCESS
///
static bool: g_pbAccess[QS_MAX_PLAYERS + 1] = { false, ... };

///
/// REVENGE KILL NAME STAMP
///
static g_pszRevengeStamp[QS_MAX_PLAYERS + 1][QS_NAME_MAX_LEN];

///
/// REVENGE KILL USER ID STAMP
///
static g_pnRevengeStamp[QS_MAX_PLAYERS + 1] = { QS_INVALID_USER_ID, ... };

#if defined QS_ON_BY_DEFAULT

#if QS_ON_BY_DEFAULT == 1

///
/// SOUNDS DISABLED PER PLAYER
///
static bool: g_pbDisabled[QS_MAX_PLAYERS + 1] = { false, ... };

#else

///
/// SOUNDS DISABLED PER PLAYER
///
static bool: g_pbDisabled[QS_MAX_PLAYERS + 1] = { true, ... };

#endif

#else

///
/// SOUNDS DISABLED PER PLAYER
///
static bool: g_pbDisabled[QS_MAX_PLAYERS + 1] = { false, ... };

#endif

///
/// CACHED PLAYER'S USER ID
///
static g_pnUserId[QS_MAX_PLAYERS + 1] = { QS_INVALID_USER_ID, ... };

///
/// LAST KILL TIME STAMP ( GAME TIME )
///
static Float: g_pfLastKillTimeStamp[QS_MAX_PLAYERS + 1] = { 0.000000, ... };

///
/// XSTATS [ client_death ( ) ] HIT PLACE ID STAMP FOR EVERY VICTIM
///
static g_pnPlace[QS_MAX_PLAYERS + 1] = { QS_INVALID_PLACE, ... };

///
/// XSTATS [ client_death ( ) ] WEAPON ID STAMP FOR EVERY VICTIM
///
static g_pnWeapon[QS_MAX_PLAYERS + 1] = { QS_INVALID_WEAPON, ... };

///
/// XSTATS [ client_death ( ) ] TEAM KILL BOOLEAN STAMP FOR EVERY VICTIM
///
static g_pnTeamKill[QS_MAX_PLAYERS + 1] = { QS_TEAM_KILL_NO, ... };

///
/// XSTATS [ client_death ( ) ] EXECUTION TIME STAMP FOR EVERY VICTIM
///
static Float: g_pfXStatsTimeStamp[QS_MAX_PLAYERS + 1] = { 0.000000, ... };

/*************************************************************************************
******* FORWARDS *********************************************************************
*************************************************************************************/

///
/// plugin_natives ( )
///
/// THE PLUGIN'S NATIVES
///
public plugin_natives()
{
    ///
    /// SETS THE MODULE FILTER
    ///
    set_module_filter("QS_ModuleFilter");

    ///
    /// SETS THE NATIVE FILTER
    ///
    set_native_filter("QS_NativeFilter");

    return PLUGIN_CONTINUE;
}

///
/// PERFORMS THE FILTERING OF MODULE
///
public QS_ModuleFilter(szModule[])
{
    ///
    /// XSTATS
    ///
    if (equali(szModule, "XStats"))
    {
        ///
        /// LOAD
        ///
        return PLUGIN_HANDLED;
    }

    ///
    /// OK
    ///
    return PLUGIN_CONTINUE;
}

///
/// PERFORMS THE FILTERING OF NATIVE
///
public QS_NativeFilter(szNative[], nNative, bool: bFound)
{
    if (!bFound)
    {
        if (strcmp(szNative, "SQL_SetCharset", true) == 0)
        {
            g_bSQL_SetCharset_Unavail = true;
            {
                return PLUGIN_HANDLED; /** I UNDERSTAND THAT FOR SOME REASON THIS NATIVE DOES NOT EXIST ON THE GAME SERVER SO DON'T THROW ANY ERROR TO THE LOGGING SYSTEM */
            }
        }
    }

    return PLUGIN_CONTINUE;
}

///
/// plugin_precache ( )
///
/// THE RIGHT MOMENT FOR INI FILES
/// AND PRECACHING DATA
///
public plugin_precache()
{
    ///
    /// DEFINES ITERATOR FOR FURTHER USE
    ///
    new nIter = 0;

    ///
    /// ZERO SOME PLAYER MULTI ARRAY SZ GLOBAL VARIABLES
    ///
    for (nIter = 0; nIter <= QS_MAX_PLAYERS; nIter++)
    {
        QS_ClearString(g_pszName[nIter]);
    }

    for (nIter = 0; nIter <= QS_MAX_PLAYERS; nIter++)
    {
        QS_ClearString(g_pszSteam[nIter]);
    }

    for (nIter = 0; nIter <= QS_MAX_PLAYERS; nIter++)
    {
        QS_ClearString(g_pszRevengeStamp[nIter]);
    }

    ///
    /// GETS THE MOD NAME
    ///
    QS_CheckMod();

    ///
    /// CREATES THE ARRAYS FIRST
    ///
    g_pHShot = ArrayCreate(ByteCountToCells(QS_SND_MAX_LEN));
    g_pSuicide = ArrayCreate(ByteCountToCells(QS_SND_MAX_LEN));

    g_pGrenade = ArrayCreate(ByteCountToCells(QS_SND_MAX_LEN));
    {
        g_pGrenadeNames = ArrayCreate(ByteCountToCells(QS_WORD_MAX_LEN));
    }

    g_pTKill = ArrayCreate(ByteCountToCells(QS_SND_MAX_LEN));

    g_pKnife = ArrayCreate(ByteCountToCells(QS_SND_MAX_LEN));
    {
        g_pKnifeNames = ArrayCreate(ByteCountToCells(QS_WORD_MAX_LEN));
    }

    g_pFBlood = ArrayCreate(ByteCountToCells(QS_SND_MAX_LEN));
    g_pRStart = ArrayCreate(ByteCountToCells(QS_SND_MAX_LEN));
    g_pDKill = ArrayCreate(ByteCountToCells(QS_SND_MAX_LEN));
    g_pHattrick = ArrayCreate(ByteCountToCells(QS_SND_MAX_LEN));

    g_pTLMStanding = ArrayCreate(ByteCountToCells(QS_SND_MAX_LEN));
    {
        g_pTLMStandingWords = ArrayCreate(ByteCountToCells(QS_WORD_MAX_LEN));
    }

    g_pFlawless = ArrayCreate(ByteCountToCells(QS_SND_MAX_LEN));
    g_pRevenge = ArrayCreate(ByteCountToCells(QS_SND_MAX_LEN));

    g_pKStreakSnds = ArrayCreate(ByteCountToCells(QS_SND_MAX_LEN));
    {
        g_pKStreakMsgs = ArrayCreate(ByteCountToCells(QS_HUD_MSG_MAX_LEN));
        {
            g_pKStreakReqKills = ArrayCreate(ByteCountToCells(QS_WORD_MAX_LEN));
        }
    }

    ///
    /// ARRAYS ARE CREATED NOW
    ///
    g_bArraysCreated = true;

    ///
    /// READS THE CONFIGURATION FILE
    ///
    QS_LoadSettings();

    ///
    /// PRECACHES NOTHING
    ///
    /// IF THE PLUGIN IS OFF
    ///
    if (!g_bEnabled)
    {
        ArrayDestroy(g_pHShot);
        ArrayDestroy(g_pSuicide);
        ArrayDestroy(g_pGrenade);
        ArrayDestroy(g_pGrenadeNames);
        ArrayDestroy(g_pTKill);
        ArrayDestroy(g_pKnife);
        ArrayDestroy(g_pKnifeNames);
        ArrayDestroy(g_pFBlood);
        ArrayDestroy(g_pRStart);
        ArrayDestroy(g_pDKill);
        ArrayDestroy(g_pHattrick);
        ArrayDestroy(g_pTLMStanding);
        ArrayDestroy(g_pTLMStandingWords);
        ArrayDestroy(g_pFlawless);
        ArrayDestroy(g_pRevenge);
        ArrayDestroy(g_pKStreakSnds);
        ArrayDestroy(g_pKStreakMsgs);
        ArrayDestroy(g_pKStreakReqKills);
        {
            g_bArraysCreated = false;
        }

        return PLUGIN_CONTINUE;
    }

    ///
    /// RETRIEVES SOUNDS COUNT
    ///
    g_nHShotSize = ArraySize(g_pHShot);
    g_nSuicideSize = ArraySize(g_pSuicide);
    g_nGrenadeSize = ArraySize(g_pGrenade);
    g_nTKillSize = ArraySize(g_pTKill);
    g_nKnifeSize = ArraySize(g_pKnife);
    g_nFBloodSize = ArraySize(g_pFBlood);
    g_nRStartSize = ArraySize(g_pRStart);
    g_nDKillSize = ArraySize(g_pDKill);
    g_nHattrickSize = ArraySize(g_pHattrick);
    g_nTLMStandingSize = ArraySize(g_pTLMStanding);
    g_nFlawlessSize = ArraySize(g_pFlawless);
    g_nRevengeSize = ArraySize(g_pRevenge);

    ///
    /// RETRIEVES EVENT WORDS COUNT
    ///
    g_nGrenadeNames = ArraySize(g_pGrenadeNames);
    g_nKnifeNames = ArraySize(g_pKnifeNames);
    g_nTLMStandingWordsSize = ArraySize(g_pTLMStandingWords);

    ///
    /// RETRIEVES K. STREAK SOUNDS & MESSAGES COUNT
    ///
    g_nKStreakSize = ArraySize(g_pKStreakSnds);
    g_nKStreakRKillsSize = ArraySize(g_pKStreakReqKills);
    g_nKStreakMsgSize = ArraySize(g_pKStreakMsgs);

    ///
    /// SANITY CHECK
    ///
    if (g_nKStreakSize > g_nKStreakMsgSize || g_nKStreakSize < g_nKStreakMsgSize || g_nKStreakSize > g_nKStreakRKillsSize || g_nKStreakSize < g_nKStreakRKillsSize ||
        g_nKStreakMsgSize > g_nKStreakSize || g_nKStreakMsgSize < g_nKStreakSize || g_nKStreakMsgSize > g_nKStreakRKillsSize || g_nKStreakMsgSize < g_nKStreakRKillsSize ||
        g_nKStreakRKillsSize > g_nKStreakSize || g_nKStreakRKillsSize < g_nKStreakSize || g_nKStreakRKillsSize > g_nKStreakMsgSize || g_nKStreakRKillsSize < g_nKStreakMsgSize)
    {
        log_to_file(QS_LOG_FILE_NAME, "****************************************************************************************************************");
        log_to_file(QS_LOG_FILE_NAME, "K. Streak Items (Multi Kill, Triple Kill, Rampage, ..) Will Be Disabled.");
        log_to_file(QS_LOG_FILE_NAME, "Inside The Configuration File, You Should Have Same 'REQUIREDKILLS' And 'MESSAGE @'.");
        log_to_file(QS_LOG_FILE_NAME, "For Example, If You Have 8 Pieces Of 'REQUIREDKILLS', You Should Have 8 Pieces Of 'MESSAGE @' As Well.");

        g_bKStreak = false;
    }

    ///
    /// DEFINES SOUND FOR FURTHER USE
    ///
    new szSnd[QS_SND_MAX_LEN] = { EOS, ... };

    ///
    /// PRECACHES ALL THE SOUNDS
    ///
    if (g_bHShot)
    {
        for (nIter = 0; nIter < g_nHShotSize; nIter++)
        {
            if (ArrayGetString(g_pHShot, nIter, szSnd, charsmax(szSnd)) > 0 || !QS_EmptyString(szSnd))
            {
                precache_sound(szSnd);
            }
        }
    }

    if (g_bSuicide)
    {
        for (nIter = 0; nIter < g_nSuicideSize; nIter++)
        {
            if (ArrayGetString(g_pSuicide, nIter, szSnd, charsmax(szSnd)) > 0 || !QS_EmptyString(szSnd))
            {
                precache_sound(szSnd);
            }
        }
    }

    if (g_bGrenade)
    {
        for (nIter = 0; nIter < g_nGrenadeSize; nIter++)
        {
            if (ArrayGetString(g_pGrenade, nIter, szSnd, charsmax(szSnd)) > 0 || !QS_EmptyString(szSnd))
            {
                precache_sound(szSnd);
            }
        }
    }

    if (g_bTKill)
    {
        for (nIter = 0; nIter < g_nTKillSize; nIter++)
        {
            if (ArrayGetString(g_pTKill, nIter, szSnd, charsmax(szSnd)) > 0 || !QS_EmptyString(szSnd))
            {
                precache_sound(szSnd);
            }
        }
    }

    if (g_bKnife)
    {
        for (nIter = 0; nIter < g_nKnifeSize; nIter++)
        {
            if (ArrayGetString(g_pKnife, nIter, szSnd, charsmax(szSnd)) > 0 || !QS_EmptyString(szSnd))
            {
                precache_sound(szSnd);
            }
        }
    }

    if (g_bFBlood)
    {
        for (nIter = 0; nIter < g_nFBloodSize; nIter++)
        {
            if (ArrayGetString(g_pFBlood, nIter, szSnd, charsmax(szSnd)) > 0 || !QS_EmptyString(szSnd))
            {
                precache_sound(szSnd);
            }
        }
    }

    if (g_bRStart)
    {
        for (nIter = 0; nIter < g_nRStartSize; nIter++)
        {
            if (ArrayGetString(g_pRStart, nIter, szSnd, charsmax(szSnd)) > 0 || !QS_EmptyString(szSnd))
            {
                precache_sound(szSnd);
            }
        }
    }

    if (g_bDKill)
    {
        for (nIter = 0; nIter < g_nDKillSize; nIter++)
        {
            if (ArrayGetString(g_pDKill, nIter, szSnd, charsmax(szSnd)) > 0 || !QS_EmptyString(szSnd))
            {
                precache_sound(szSnd);
            }
        }
    }

    if (g_bHattrick)
    {
        for (nIter = 0; nIter < g_nHattrickSize; nIter++)
        {
            if (ArrayGetString(g_pHattrick, nIter, szSnd, charsmax(szSnd)) > 0 || !QS_EmptyString(szSnd))
            {
                precache_sound(szSnd);
            }
        }
    }

    if (g_bTLMStanding)
    {
        for (nIter = 0; nIter < g_nTLMStandingSize; nIter++)
        {
            if (ArrayGetString(g_pTLMStanding, nIter, szSnd, charsmax(szSnd)) > 0 || !QS_EmptyString(szSnd))
            {
                precache_sound(szSnd);
            }
        }
    }

    if (g_bFlawless)
    {
        for (nIter = 0; nIter < g_nFlawlessSize; nIter++)
        {
            if (ArrayGetString(g_pFlawless, nIter, szSnd, charsmax(szSnd)) > 0 || !QS_EmptyString(szSnd))
            {
                precache_sound(szSnd);
            }
        }
    }

    if (g_bRevenge)
    {
        for (nIter = 0; nIter < g_nRevengeSize; nIter++)
        {
            if (ArrayGetString(g_pRevenge, nIter, szSnd, charsmax(szSnd)) > 0 || !QS_EmptyString(szSnd))
            {
                precache_sound(szSnd);
            }
        }
    }

    if (g_bKStreak)
    {
        for (nIter = 0; nIter < g_nKStreakSize; nIter++)
        {
            if (ArrayGetString(g_pKStreakSnds, nIter, szSnd, charsmax(szSnd)) > 0 || !QS_EmptyString(szSnd))
            {
                precache_sound(szSnd);
            }
        }
    }

    ///
    /// WORLDSPAWN PREPARATION
    ///
    copy(g_pszName[QS_WORLDSPAWN], charsmax(g_pszName[]), QS_WORLDSPAWN_NAME);

    return PLUGIN_CONTINUE;
}

///
/// plugin_end ( )
///
/// THE PLUGIN ENDS
///
public plugin_end()
{
    ///
    /// SANITY CHECK
    ///
    if (!g_bEnabled)
    {
        return PLUGIN_CONTINUE;
    }

    ///
    /// DESTROYS ARRAYS
    ///
    if (g_bArraysCreated) /** ARRAYS ARE CREATED */
    {
        ArrayDestroy(g_pHShot);
        ArrayDestroy(g_pSuicide);
        ArrayDestroy(g_pGrenade);
        ArrayDestroy(g_pGrenadeNames);
        ArrayDestroy(g_pTKill);
        ArrayDestroy(g_pKnife);
        ArrayDestroy(g_pKnifeNames);
        ArrayDestroy(g_pFBlood);
        ArrayDestroy(g_pRStart);
        ArrayDestroy(g_pDKill);
        ArrayDestroy(g_pHattrick);
        ArrayDestroy(g_pTLMStanding);
        ArrayDestroy(g_pTLMStandingWords);
        ArrayDestroy(g_pFlawless);
        ArrayDestroy(g_pRevenge);
        ArrayDestroy(g_pKStreakSnds);
        ArrayDestroy(g_pKStreakMsgs);
        ArrayDestroy(g_pKStreakReqKills);
        {
            g_bArraysCreated = false;
        }
    }

    ///
    /// SQL STORAGE STUFF
    ///
    if (g_bSql)
    {
        if (Empty_Handle != g_pSqlDb)
        {
            SQL_FreeHandle(g_pSqlDb);
            {
                g_pSqlDb = Empty_Handle;
            }
        }

        g_bSql = false;
    }

    ///
    /// AMXX OLDER EDITIONS COMPATIBILITY
    ///
    for (new nPlayer = QS_MIN_PLAYER; nPlayer <= g_nMaxPlayers; nPlayer++)
    {
        if (g_pbInGame[nPlayer])
        {
            client_disconnected(nPlayer, true, "", 0);
        }
    }

    return PLUGIN_CONTINUE;
}

///
/// plugin_init ( )
///
/// THE PLUGIN STARTS
/// THE RIGHT MOMENT TO REGISTER STUFF
///
public plugin_init()
{
    ///
    /// GETS THE MOD NAME
    ///
    QS_CheckMod();

    ///
    /// REGISTERS THE PLUGIN'S CONSOLE VARIABLE
    ///
    new pConVar = register_cvar("advanced_quake_sounds", QS_PLUGIN_VERSION, FCVAR_SERVER | FCVAR_SPONLY);

    ///
    /// SETS THE CONSOLE VARIABLE STRING
    ///
    if (pConVar)
    {
        set_pcvar_string(pConVar, QS_PLUGIN_VERSION);
    }

    ///
    /// STOPS HERE IF THE PLUGIN IS DISABLED
    ///
    if (!g_bEnabled)
    {
        ///
        /// REGISTERS THE PLUGIN
        ///
        register_plugin("ADV. QUAKE SOUNDS (DISABLED)", QS_PLUGIN_VERSION, "HATTRICK (HTTRCKCLDHKS)");

        return PLUGIN_CONTINUE;
    }

    ///
    /// REGISTERS THE PLUGIN
    ///
    register_plugin("ADV. QUAKE SOUNDS (ENABLED)", QS_PLUGIN_VERSION, "HATTRICK (HTTRCKCLDHKS)");

    ///
    /// GETS THE MAXIMUM PLAYERS
    ///
    g_nMaxPlayers = get_maxplayers();

    ///
    /// CHECKS WHETHER XSTATS MODULE IS LOADED [ client_death ( ) ]
    ///
    g_bDeathMsgOnly = !QS_XStatsAvail();

    ///
    /// CSTRIKE OR CZERO
    ///
    g_bCSCZ = QS_CSCZRunning();

    ///
    /// DAY OF DEFEAT [[[ DOD ]]]
    ///
    g_bDOD = QS_DODRunning();

    ///
    /// CSTRIKE OR CZERO
    ///
    if (g_bCSCZ)
    {
        ///
        /// ROUND RESTART
        ///
        register_event("TextMsg", "QS_OnRoundRefresh", "a", "2&#Game_C", "2&#Game_w");

        ///
        /// ROUND LAUNCH
        ///
        register_event("HLTV", "QS_OnRoundLaunch", "a", "1=0", "2=0");

        ///
        /// ROUND START
        ///
        register_logevent("QS_OnRoundBegin", 2, "1=Round_Start");

        ///
        /// ROUND END
        ///
        register_logevent("QS_OnRoundEnd", 2, "1=Round_End");
    }

    ///
    /// DAY OF DEFEAT
    ///
    else if (g_bDOD)
    {
        ///
        /// ROUND LAUNCH
        ///
        register_event("HLTV", "QS_OnRoundLaunch", "a", "1=0", "2=0");

        ///
        /// ROUND START
        ///
        register_event("RoundState", "QS_OnRoundBegin", "a", "1=1");

        ///
        /// ROUND END
        ///
        register_event("RoundState", "QS_OnRoundEnd", "a", "1=3", "1=4");

        ///
        /// DISABLES THE FLAWLESS VICTORY FEATURE
        ///
        g_bFlawless = false;

        ///
        /// DISABLES THE LAST MAN STANDING FEATURE
        ///
        g_bTLMStanding = false;
    }

    ///
    /// NO CS/ CZ OR DOD
    ///
    else
    {
        ///
        /// DISABLES THE FLAWLESS VICTORY FEATURE
        ///
        g_bFlawless = false;

        ///
        /// DISABLES THE LAST MAN STANDING FEATURE
        ///
        g_bTLMStanding = false;

        ///
        /// DISABLES THE HATTRICK FEATURE
        ///
        g_bHattrick = false;

        ///
        /// DISABLES THE TEAM KILL FEATURE
        ///
        g_bTKill = false;

        ///
        /// DISABLES THE ROUND START FEATURE
        ///
        g_bRStart = false;
    }

    ///
    /// HUD MESSAGE [ TE_TEXTMESSAGE ] CHANNEL HANDLES
    ///
    for (new nIter = 0; nIter < QS_HUD_MAX; nIter++)
    {
        g_pnHudMsgObj[nIter] = CreateHudSyncObj();
    }

    ///
    /// SQL STORAGE STUFF
    ///
    if (g_bSql)
    {
        new szAffinity[64] = { EOS, ... }, bool: bError = false;

        ///
        /// READ THE ACTUAL SQL DRIVER
        ///
        SQL_GetAffinity(szAffinity, charsmax(szAffinity));

        if (!equali(szAffinity, g_szSqlExtension))
        {
            ///
            /// SQL DRIVER TO USE
            ///
            bError = !(bool: SQL_SetAffinity(g_szSqlExtension));
        }

        else
        {
            bError = false;
        }

        ///
        /// UNKNOWN SQL DRIVER
        ///
        if (bError)
        {
            g_bSql = false;
            {
                g_pSqlDb = Empty_Handle;
            }

            log_to_file(QS_LOG_FILE_NAME, "****************************************************************************************************************");
            log_to_file(QS_LOG_FILE_NAME, "Sql Database Connection Failed.");
            log_to_file(QS_LOG_FILE_NAME, "The Following Call Failed [ SQL_SetAffinity ( '%s' ) ].", !QS_EmptyString(g_szSqlExtension) ? g_szSqlExtension : "N/ A");
            log_to_file(QS_LOG_FILE_NAME, "Per Steam Player Preferences Will Not Be Stored In Any Database.");

            return PLUGIN_CONTINUE;
        }

        ///
        /// ESTABLISH THE SQL CONNECTION
        ///
        g_pSqlDb = SQL_MakeDbTuple(g_szSqlAddr, g_szSqlUser, g_szSqlPassword, g_szSqlDatabase, g_nSqlMaxSecondsError);

        ///
        /// SUCCESS
        ///
        if (g_pSqlDb != Empty_Handle)
        {
            new szBuffer[128] = { EOS, ... };

            ///
            /// SQL PRIMARY ( MAIN ) CHARSET
            ///
            if (!QS_EmptyString(g_szSqlChars) && !g_bSqlLocal && !g_bSQL_SetCharset_Unavail && !SQL_SetCharset(g_pSqlDb, g_szSqlChars))
            {
                log_to_file(QS_LOG_FILE_NAME, "****************************************************************************************************************");
                log_to_file(QS_LOG_FILE_NAME, "Sql Primary Character Set Update Failed.");
                log_to_file(QS_LOG_FILE_NAME, "The Following Call Failed [ SQL_SetCharset ( '%s' ) ].", !QS_EmptyString(g_szSqlChars) ? g_szSqlChars : "N/ A");
                log_to_file(QS_LOG_FILE_NAME, "Per Steam Player Preferences Will Still Be Stored Into The Database. This Is Just A Warning, Not An Error.");

                ///
                /// SQL SECONDARY CHARSET IF THE PRIMARY CHARSET FAILED
                ///
                if (!QS_EmptyString(g_szSqlSecChars) && !g_bSqlLocal && !g_bSQL_SetCharset_Unavail && !SQL_SetCharset(g_pSqlDb, g_szSqlSecChars))
                {
                    log_to_file(QS_LOG_FILE_NAME, "****************************************************************************************************************");
                    log_to_file(QS_LOG_FILE_NAME, "Sql Secondary Character Set Update Failed.");
                    log_to_file(QS_LOG_FILE_NAME, "The Following Call Failed [ SQL_SetCharset ( '%s' ) ].", !QS_EmptyString(g_szSqlSecChars) ? g_szSqlSecChars : "N/ A");
                    log_to_file(QS_LOG_FILE_NAME, "Per Steam Player Preferences Will Still Be Stored Into The Database. This Is Just A Warning, Not An Error.");
                }
            }

            ///
            /// SPAWN THE SQL TABLES
            ///
            if (!g_bSqlLocal)
            {
                if (!g_bSqlFullSteam)
                {
                    copy(szBuffer, charsmax(szBuffer), "aqs_enabled_fast (aqs_steam, aqs_option)");

                    SQL_ThreadQuery(g_pSqlDb, "QS_CreateThreadedQueryHandler",
                        "CREATE TABLE IF NOT EXISTS aqs_enabled_fast (aqs_steam VARCHAR (32) COLLATE utf8mb4_unicode_520_ci NOT NULL UNIQUE, aqs_option INT (4) NOT NULL DEFAULT 1, PRIMARY KEY (aqs_steam)) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_520_ci;",
                        szBuffer, charsmax(szBuffer));

                    SQL_ThreadQuery(g_pSqlDb, "QS_CreateThreadedQueryHandler",
                        "CREATE TABLE IF NOT EXISTS aqs_enabled_fast (aqs_steam VARCHAR (32) COLLATE utf8mb4_unicode_ci NOT NULL UNIQUE, aqs_option INT (4) NOT NULL DEFAULT 1, PRIMARY KEY (aqs_steam)) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;",
                        szBuffer, charsmax(szBuffer));

                    SQL_ThreadQuery(g_pSqlDb, "QS_CreateThreadedQueryHandler",
                        "CREATE TABLE IF NOT EXISTS aqs_enabled_fast (aqs_steam VARCHAR (32) COLLATE utf8_unicode_ci NOT NULL UNIQUE, aqs_option INT (4) NOT NULL DEFAULT 1, PRIMARY KEY (aqs_steam)) ENGINE = InnoDB DEFAULT CHARSET = utf8 COLLATE = utf8_unicode_ci;",
                        szBuffer, charsmax(szBuffer));

                    g_nSqlTablesToCreate = 3;
                }

                else
                {
                    copy(szBuffer, charsmax(szBuffer), "aqs_enabled_full (aqs_steam, aqs_option)");

                    SQL_ThreadQuery(g_pSqlDb, "QS_CreateThreadedQueryHandler",
                        "CREATE TABLE IF NOT EXISTS aqs_enabled_full (aqs_steam VARCHAR (32) COLLATE utf8mb4_unicode_520_ci NOT NULL UNIQUE, aqs_option INT (4) NOT NULL DEFAULT 1, PRIMARY KEY (aqs_steam)) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_520_ci;",
                        szBuffer, charsmax(szBuffer));

                    SQL_ThreadQuery(g_pSqlDb, "QS_CreateThreadedQueryHandler",
                        "CREATE TABLE IF NOT EXISTS aqs_enabled_full (aqs_steam VARCHAR (32) COLLATE utf8mb4_unicode_ci NOT NULL UNIQUE, aqs_option INT (4) NOT NULL DEFAULT 1, PRIMARY KEY (aqs_steam)) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;",
                        szBuffer, charsmax(szBuffer));

                    SQL_ThreadQuery(g_pSqlDb, "QS_CreateThreadedQueryHandler",
                        "CREATE TABLE IF NOT EXISTS aqs_enabled_full (aqs_steam VARCHAR (32) COLLATE utf8_unicode_ci NOT NULL UNIQUE, aqs_option INT (4) NOT NULL DEFAULT 1, PRIMARY KEY (aqs_steam)) ENGINE = InnoDB DEFAULT CHARSET = utf8 COLLATE = utf8_unicode_ci;",
                        szBuffer, charsmax(szBuffer));

                    g_nSqlTablesToCreate = 3;
                }
            }

            else
            {
                if (!g_bSqlFullSteam)
                {
                    copy(szBuffer, charsmax(szBuffer), "aqs_enabled_fast (aqs_steam, aqs_option)");

                    SQL_ThreadQuery(g_pSqlDb, "QS_CreateThreadedQueryHandler",
                        "CREATE TABLE IF NOT EXISTS aqs_enabled_fast (aqs_steam VARCHAR (32) NOT NULL UNIQUE COLLATE NOCASE, aqs_option INT (4) NOT NULL DEFAULT 1, PRIMARY KEY (aqs_steam), UNIQUE (aqs_steam));", szBuffer, charsmax(szBuffer));

                    SQL_ThreadQuery(g_pSqlDb, "QS_CreateThreadedQueryHandler",
                        "CREATE TABLE IF NOT EXISTS aqs_enabled_fast (aqs_steam VARCHAR (32) NOT NULL UNIQUE, aqs_option INT (4) NOT NULL DEFAULT 1, PRIMARY KEY (aqs_steam), UNIQUE (aqs_steam));", szBuffer, charsmax(szBuffer));

                    g_nSqlTablesToCreate = 2;
                }

                else
                {
                    copy(szBuffer, charsmax(szBuffer), "aqs_enabled_full (aqs_steam, aqs_option)");

                    SQL_ThreadQuery(g_pSqlDb, "QS_CreateThreadedQueryHandler",
                        "CREATE TABLE IF NOT EXISTS aqs_enabled_full (aqs_steam VARCHAR (32) NOT NULL UNIQUE COLLATE NOCASE, aqs_option INT (4) NOT NULL DEFAULT 1, PRIMARY KEY (aqs_steam), UNIQUE (aqs_steam));", szBuffer, charsmax(szBuffer));

                    SQL_ThreadQuery(g_pSqlDb, "QS_CreateThreadedQueryHandler",
                        "CREATE TABLE IF NOT EXISTS aqs_enabled_full (aqs_steam VARCHAR (32) NOT NULL UNIQUE, aqs_option INT (4) NOT NULL DEFAULT 1, PRIMARY KEY (aqs_steam), UNIQUE (aqs_steam));", szBuffer, charsmax(szBuffer));

                    g_nSqlTablesToCreate = 2;
                }
            }
        }

        ///
        /// ERROR
        ///
        else
        {
            g_bSql = false;

            log_to_file(QS_LOG_FILE_NAME, "****************************************************************************************************************");
            log_to_file(QS_LOG_FILE_NAME, "Sql Database Connection Failed.");
            log_to_file(QS_LOG_FILE_NAME, "The Following Call Failed [ SQL_MakeDbTuple ( '%s', '%s', '%s', '%s', %d ) ].", !QS_EmptyString(g_szSqlAddr) ? g_szSqlAddr : "N/ A",
                !QS_EmptyString(g_szSqlUser) ? g_szSqlUser : "N/ A", !QS_EmptyString(g_szSqlPassword) ? g_szSqlPassword : "N/ A", !QS_EmptyString(g_szSqlDatabase) ? g_szSqlDatabase : "N/ A", g_nSqlMaxSecondsError);
            log_to_file(QS_LOG_FILE_NAME, "Per Steam Player Preferences Will Not Be Stored In Any Database.");
        }
    }

    return PLUGIN_CONTINUE;
}

///
/// GAMES WITHOUT "client_death ( )" ( XSTATS MODULE ) AND WITHOUT "DeathMsg"
///
public QS_HAM_On_Player_Killed(nVictim)
{
    static nWeapon = QS_INVALID_WEAPON, pnInfo[8] = { QS_INVALID_PLAYER, ... }, Float: fGameTime = 0.000000, Float: fGameTimeStamp = 0.000000, nVictimStamp = QS_INVALID_PLAYER;

    ///
    /// SANITY CHECK
    ///
    if (!QS_IsPlayer(nVictim) || !g_pbInGame[nVictim])
    {
        return PLUGIN_CONTINUE;
    }

    fGameTime = get_gametime();

    ///
    /// PREVENTS DUAL EXECUTION
    ///
    if ((fGameTimeStamp == fGameTime) && (nVictim == nVictimStamp))
    {
        return PLUGIN_CONTINUE;
    }

    ///
    /// UPDATES THE CALL DETAILS ( STAMPS )
    ///
    fGameTimeStamp = fGameTime;
    {
        nVictimStamp = nVictim;
    }

    g_nWeapon = QS_INVALID_WEAPON;
    g_nPlace = QS_INVALID_PLACE;
    g_nTeamKill = QS_TEAM_KILL_NO;
    {
        g_nKiller = get_user_attacker(nVictim, g_nWeapon, g_nPlace);
        {
            g_nVictim = nVictim;
        }
    }

    ///
    /// ONLY IF AVAILABLE KILLER FOR THE "QS_HAM_On_Player_Killed ( )" FORWARD
    ///
    if (QS_IsPlayer(g_nKiller) && g_pbInGame[g_nKiller])
    {
        if (!QS_ValidWeapon(g_nWeapon))
        {
            nWeapon = get_user_weapon(g_nKiller);
            {
                if (QS_ValidWeapon(nWeapon))
                {
                    g_nWeapon = nWeapon;
                }

                else
                {
                    g_nWeapon = QS_INVALID_WEAPON;
                }
            }
        }

        g_nTeamKill = (get_user_team(g_nKiller) == get_user_team(g_nVictim)) ? QS_TEAM_KILL_YES : QS_TEAM_KILL_NO;

        pnInfo[0] = g_nKiller;
        pnInfo[1] = g_nVictim;
        pnInfo[2] = g_nWeapon;
        pnInfo[3] = g_nPlace;
        pnInfo[4] = g_nTeamKill;
        {
            set_task(0.000000, "QS_ProcessDeathHook", get_systime(0), pnInfo, charsmax(pnInfo), "", 0);
        }
    }

    return PLUGIN_CONTINUE;
}

///
/// plugin_cfg ( )
///
/// THE PLUGIN EXECUTES THE CONFIGURATION FILES
/// THE RIGHT MOMENT TO RELOAD THE SETTINGS
///
public plugin_cfg()
{
    ///
    /// SANITY CHECK
    ///
    if (!g_bEnabled)
    {
        return PLUGIN_CONTINUE;
    }

    ///
    /// MESSAGES ON/ OFF
    ///
    g_bHShotMsg = !QS_EmptyString(g_szHShotMsg);
    g_bSuicideMsg = !QS_EmptyString(g_szSuicideMsg);
    g_bGrenadeMsg = !QS_EmptyString(g_szGrenadeMsg);
    g_bTKillMsg = !QS_EmptyString(g_szTKillMsg);
    g_bKnifeMsg = !QS_EmptyString(g_szKnifeMsg);
    g_bFBloodMsg = !QS_EmptyString(g_szFBloodMsg);
    g_bFBloodMsgNoKiller = !QS_EmptyString(g_szFBloodMsgNoKiller);
    g_bRStartMsg = !QS_EmptyString(g_szRStartMsg);
    g_bDKillMsg = !QS_EmptyString(g_szDKillMsg);
    g_bHattrickMsg = !QS_EmptyString(g_szHattrickMsg);
    g_bTLMStandingTeamMsg = !QS_EmptyString(g_szTLMStandingTeamMsg);
    g_bTLMStandingSelfMsg = !QS_EmptyString(g_szTLMStandingSelfMsg);
    g_bFlawlessMsg = !QS_EmptyString(g_szFlawlessMsg);
    g_bRevengeMsgVictim = !QS_EmptyString(g_szRevengeMsgVictim);
    g_bRevengeMsgKiller = !QS_EmptyString(g_szRevengeMsgKiller);

    ///
    /// BETTER TO READ THESE MESSAGES DURING THE "plugin_cfg ( )" FORWARD
    ///
    g_nDeathMsg = get_user_msgid("DeathMsg");
    {
        if (!QS_ValidMsg(g_nDeathMsg))
        {
            ///
            /// GAMES WITHOUT THE "client_death ( )" FORWARD ( XSTATS MODULE ) AND WITHOUT "DeathMsg"
            ///
            if (g_bDeathMsgOnly)
            {

#if defined AMXX_VERSION_NUM

#if AMXX_VERSION_NUM > 183

                RegisterHam(Ham_Killed, "player", "QS_HAM_On_Player_Killed", 0 /** PRE = 0 */, true /** IF TRUE THEN IT WILL PROVIDE SOME KIND OF SUPPORT FOR SPECIAL BOTS WITHOUT "player" CLASS NAME */); /// LATEST

#else /// AMXX_VERSION_NUM > 183

                RegisterHam(Ham_Killed, "player", "QS_HAM_On_Player_Killed", 0 /** PRE = 0 */); /// OLDER

#endif

#else /// defined AMXX_VERSION_NUM

                RegisterHam(Ham_Killed, "player", "QS_HAM_On_Player_Killed", 0 /** PRE = 0 */); /// OLDER

#endif

            }
        }

        else
        {
            ///
            /// REGISTERS THE FAKE META FORWARDS
            ///
            register_forward(FM_MessageBegin, "QS_FM_OnMsgBegin", 1 /** POST = 1 */);
            register_forward(FM_WriteByte, "QS_FM_OnWriteByte", 1 /** POST = 1 */);
            register_forward(FM_MessageEnd, "QS_FM_OnMsgEnd", 1 /** POST = 1 */);
        }
    }

    ///
    /// ENSURE THE AQS WORKS ON OLDER AMXX VERSIONS AS WELL
    ///
    register_forward(FM_ClientDisconnect, "QS_FM_OnClientDisconnect", 1 /** POST = 1 */);
    register_forward(FM_ClientDisconnect, "QS_FM_OnClientDisconnect", 0 /** PRE = 0 */);

    if (g_bCSCZ)
    {
        ///
        /// BETTER TO READ THESE MESSAGES DURING THE "plugin_cfg ( )" FORWARD
        ///
        g_nSayText = get_user_msgid("SayText");
        {
            if (QS_ValidMsg(g_nSayText))
            {
                ///
                /// COLORED CHAT FOR CS/ CZ
                ///
                g_bColors = true;
            }
        }
    }

    return PLUGIN_CONTINUE;
}

///
/// client_infochanged ( nPlayer )
///
/// EXECUTES WHEN THE CLIENT CHANGES INFORMATION
///
public client_infochanged(nPlayer)
{
    ///
    /// DATA
    ///
    static szName[QS_NAME_MAX_LEN] = { EOS, ... };

    ///
    /// SANITY CHECK
    ///
    if (!g_bEnabled)
    {
        return PLUGIN_CONTINUE;
    }

    ///
    /// PLAYER IS IN GAME AND IT'S NOT A HLTV
    ///
    if (g_pbInGame[nPlayer] && !g_pbHLTV[nPlayer])
    {
        ///
        /// RETRIEVES NEW NAME ( IF ANY )
        ///
        get_user_info(nPlayer, "name", szName, charsmax(szName));

        ///
        /// UPDATES IF NEEDED
        ///
        g_pszName[nPlayer] = szName;
    }

    return PLUGIN_CONTINUE;
}

///
/// CALLED WHEN A CLIENT DISCONNECTS
///
/// DEPRECATED NOW BUT STILL NEEDED FOR OLDER AMXX EDITIONS
///
public QS_FM_OnClientDisconnect(nPlayer)
{
    ///
    /// REDIRECT THE CALL
    ///
    return client_disconnected(nPlayer, true, "", 0);
}

///
/// client_disconnected ( nPlayer, bool: bDrop, szMsg [ ], nMsgMaxLen )
///
/// EXECUTES AFTER THE CLIENT DISCONNECTS
///
public client_disconnected(nPlayer, bool: bDrop, szMsg[], nMsgMaxLen)
{
    ///
    /// SANITY CHECK
    ///
    if (!g_bEnabled)
    {
        return PLUGIN_CONTINUE;
    }

    ///
    /// NO MORE KILLS
    ///
    if (g_bKStreak)
    {
        g_pnKills[nPlayer] = 0;
    }

    ///
    /// NO MORE HATTRICK KILLS
    ///
    if (g_bHattrick)
    {
        g_pnKillsThisRound[nPlayer] = 0;
    }

    ///
    /// NO MORE STAMPS
    ///
    if (g_bRevenge)
    {
        g_pnRevengeStamp[nPlayer] = QS_INVALID_USER_ID;
    }

    g_pnUserId[nPlayer] = QS_INVALID_USER_ID;

    ///
    /// NO MORE TRUE DATA
    ///
    g_pbHLTV[nPlayer] = false;
    g_pbBOT[nPlayer] = false;

#if defined QS_ON_BY_DEFAULT

#if QS_ON_BY_DEFAULT == 1

    g_pbDisabled[nPlayer] = false;

#else

    g_pbDisabled[nPlayer] = true;

#endif

#else

    g_pbDisabled[nPlayer] = false;

#endif

    g_pbInGame[nPlayer] = false;
    g_pbAccess[nPlayer] = false;
    g_pbLoaded[nPlayer] = false;
    g_pbExisting[nPlayer] = false;
    g_pbValidSteam[nPlayer] = false;

    ///
    /// NO MORE VALID STRINGS
    ///
    QS_ClearString(g_pszName[nPlayer]);
    QS_ClearString(g_pszSteam[nPlayer]);

    if (g_bRevenge)
    {
        QS_ClearString(g_pszRevengeStamp[nPlayer]);
    }

    ///
    /// ZERO FLOATS
    ///
    if (g_bDKill)
    {
        g_pfLastKillTimeStamp[nPlayer] = 0.000000;
    }

    return PLUGIN_CONTINUE;
}

///
/// client_command ( nPlayer )
///
/// EXECUTES WHEN THE CLIENT TYPES
///
public client_command(nPlayer)
{
    ///
    /// DATA
    ///
    static szArg[16] = { EOS, ... }, szQuery[128] = { EOS, ... }, szUserId[16] = { EOS, ... };

    ///
    /// SANITY CHECK
    ///
    if (!g_bEnabled || !g_bChatCmd)
    {
        return PLUGIN_CONTINUE;
    }

    ///
    /// IN GAME, NOT BOT AND NOT HLTV
    ///
    if (g_pbInGame[nPlayer] && !g_pbBOT[nPlayer] && !g_pbHLTV[nPlayer])
    {
        ///
        /// RETRIEVES THE ARGUMENT
        ///
        read_argv(1, szArg, charsmax(szArg));

        ///
        /// CHECKS ARGUMENT
        ///
        if (equali(szArg, ".Sounds", 7) || equali(szArg, "/Sounds", 7) || equali(szArg, "Sounds", 6))
        {
            ///
            /// ENABLES/ DISABLES SOUNDS PER CLIENT
            ///
            if (g_pbAccess[nPlayer])
            {
                if (!g_bSql || Empty_Handle == g_pSqlDb || !g_pbValidSteam[nPlayer] || g_pbLoaded[nPlayer])
                {
                    if (!g_bColors)
                    {
 //                       client_print(nPlayer, print_chat, ">> QUAKE SOUNDS %s.", g_pbDisabled[nPlayer] ? "ENABLED" : "DISABLED");
                    }

                    else
                    {
 //                       QS_CSCZColored(nPlayer, QS_CC_ST_X03_RED, "\x01>> QUAKE SOUNDS %c%s\x01.", g_pbDisabled[nPlayer] ? 4 : 3, g_pbDisabled[nPlayer] ? "ENABLED" : "DISABLED");
                    }

                    g_pbDisabled[nPlayer] = !g_pbDisabled[nPlayer];
                }

                else
                {
                    ///
                    /// THE USER MUST WAIT BEFORE TYPING '/SOUNDS' BECAUSE THE STEAM SERVERS ARE DOWN OR THE MYSQL SERVER ENCOUNTERS ISSUES/ DELAY
                    ///
                    if (!g_bColors)
                    {
                        client_print(nPlayer, print_chat, ">> WAIT.");
                    }

                    else
                    {
                        QS_CSCZColored(nPlayer, QS_CC_ST_X03_GREY, "\x01>> \x03WAIT\x01.");
                    }
                }

                if (g_bSql)
                {
                    if (Empty_Handle != g_pSqlDb)
                    {
                        ///
                        /// THEIR STEAM ID IS ACTUALLY INTO THE DATABASE
                        ///
                        if (g_pbLoaded[nPlayer])
                        {
                            ///
                            /// VALID STEAM ID
                            ///
                            if (g_pbValidSteam[nPlayer])
                            {
                                if (g_bSqlLocal)
                                {
                                    if (!g_bSqlFullSteam)
                                    {
                                        formatex(szQuery, charsmax(szQuery), "UPDATE aqs_enabled_fast SET aqs_option = %d WHERE aqs_steam = '%s';", g_pbDisabled[nPlayer] ? 0 : 1, g_pszSteam[nPlayer]);
                                    }

                                    else
                                    {
                                        formatex(szQuery, charsmax(szQuery), "UPDATE aqs_enabled_full SET aqs_option = %d WHERE aqs_steam = '%s';", g_pbDisabled[nPlayer] ? 0 : 1, g_pszSteam[nPlayer]);
                                    }
                                }

                                else
                                {
                                    if (!g_bSqlFullSteam)
                                    {
                                        formatex(szQuery, charsmax(szQuery), "UPDATE aqs_enabled_fast SET aqs_option = %d WHERE aqs_steam = '%s' LIMIT 1;", g_pbDisabled[nPlayer] ? 0 : 1, g_pszSteam[nPlayer]);
                                    }

                                    else
                                    {
                                        formatex(szQuery, charsmax(szQuery), "UPDATE aqs_enabled_full SET aqs_option = %d WHERE aqs_steam = '%s' LIMIT 1;", g_pbDisabled[nPlayer] ? 0 : 1, g_pszSteam[nPlayer]);
                                    }
                                }

                                num_to_str(g_pnUserId[nPlayer], szUserId, charsmax(szUserId));
                                {
                                    SQL_ThreadQuery(g_pSqlDb, "QS_StoreThreadedQueryHandler", szQuery, szUserId, charsmax(szUserId)); /** UPDATES THEIR PREFERENCE */
                                }

                                ///
                                /// MAKE THEM WAIT A BIT WHILE THE SQL DRIVER ( IF ENABLED ) UPDATES THEIR PREFERENCE
                                ///
                                g_pbAccess[nPlayer] = false;
                            }
                        }
                    }
                }
            }

            ///
            /// WHILE THE SQL DRIVER ( IF ENABLED ) UPDATES THEIR PREFERENCE THEY MUST WAIT A BIT
            ///
            else
            {
                if (!g_bColors)
                {
                    client_print(nPlayer, print_chat, ">> WAIT.");
                }

                else
                {
                    QS_CSCZColored(nPlayer, QS_CC_ST_X03_GREY, "\x01>> \x03WAIT\x01.");
                }
            }

            ///
            /// HIDE THAT THEY TYPED '/sounds'
            ///
            if (g_bHideCmd)
            {
                return PLUGIN_HANDLED;
            }
        }
    }

    return PLUGIN_CONTINUE;
}

///
/// client_authorized ( nPlayer ) FOR THE OLDER AMXX EDITIONS
///
/// client_authorized ( nPlayer, const szSteam [ ] ) FOR THE LATEST AMXX EDITIONS
///
/// EXECUTES WHEN CLIENT TELLS THEIR STEAM ID
///

#if defined AMXX_VERSION_NUM

#if AMXX_VERSION_NUM > 183

public client_authorized(nPlayer, const szSteam[]) /// LATEST

#else /// AMXX_VERSION_NUM > 183

public client_authorized(nPlayer) /// OLDER

#endif

#else /// defined AMXX_VERSION_NUM

public client_authorized(nPlayer) /// OLDER

#endif

{
    ///
    /// DATA
    ///

#if defined AMXX_VERSION_NUM

#if AMXX_VERSION_NUM > 183

    static szQuery[128] = { EOS, ... }, szUserId[16] = { EOS, ... }, nLen = 0; /// LATEST

#else /// AMXX_VERSION_NUM > 183

    static szQuery[128] = { EOS, ... }, szUserId[16] = { EOS, ... }, nLen = 0, szSteam[QS_STEAM_MAX_LEN] = { EOS, ... }; /// OLDER

#endif

#else /// defined AMXX_VERSION_NUM

    static szQuery[128] = { EOS, ... }, szUserId[16] = { EOS, ... }, nLen = 0, szSteam[QS_STEAM_MAX_LEN] = { EOS, ... }; /// OLDER

#endif

    ///
    /// SANITY CHECK
    ///
    if (!g_bEnabled)
    {
        return PLUGIN_CONTINUE;
    }

    ///
    /// SANITY SQL STORAGE CHECK
    ///
    if (!g_bSql)
    {
        g_pbValidSteam[nPlayer] = false;

        return PLUGIN_CONTINUE;
    }

    ///
    /// SANITY SQL STORAGE DATABASE CHECK
    ///
    if (Empty_Handle == g_pSqlDb)
    {
        g_pbValidSteam[nPlayer] = false;

        return PLUGIN_CONTINUE;
    }

    ///
    /// RETRIEVES PLAYER STEAM
    ///
    if (!QS_EmptyString(szSteam))
    {
        copy(g_pszSteam[nPlayer], charsmax(g_pszSteam[]), szSteam);
    }

    else
    {
        get_user_authid(nPlayer, g_pszSteam[nPlayer], charsmax(g_pszSteam[]));
    }

    ///
    /// SHRINK THE STEAM
    ///
    if (!g_bSqlFullSteam)
    {
        QS_ShrinkSteam(g_pszSteam[nPlayer]);
    }

    ///
    /// USER ID
    ///
    g_pnUserId[nPlayer] = get_user_userid(nPlayer); /// MIGHT EXECUTE client_authorized BEFORE client_putinserver OR AFTER AS WELL

    ///
    /// HLTV
    ///
    g_pbHLTV[nPlayer] = bool: is_user_hltv(nPlayer); /// MIGHT EXECUTE client_authorized BEFORE client_putinserver OR AFTER AS WELL

    ///
    /// BOT
    ///
    g_pbBOT[nPlayer] = bool: is_user_bot(nPlayer); /// MIGHT EXECUTE client_authorized BEFORE client_putinserver OR AFTER AS WELL

    ///
    /// STEAM VALID
    ///
    g_pbValidSteam[nPlayer] = ((((nLen = strlen(g_pszSteam[nPlayer])) > 0) && isdigit(g_pszSteam[nPlayer][0])) || ((nLen > 10) && isdigit(g_pszSteam[nPlayer][10])));

    ///
    /// SQL STORAGE SELECT QUERY
    ///
    if (!g_pbBOT[nPlayer] && !g_pbHLTV[nPlayer])
    {
        ///
        /// VALID STEAM ID ONLY
        ///
        if (g_pbValidSteam[nPlayer])
        {
            if (!g_bSqlFullSteam)
            {
                formatex(szQuery, charsmax(szQuery), "SELECT aqs_option FROM aqs_enabled_fast WHERE aqs_steam = '%s' LIMIT 1;", g_pszSteam[nPlayer]);
            }

            else
            {
                formatex(szQuery, charsmax(szQuery), "SELECT aqs_option FROM aqs_enabled_full WHERE aqs_steam = '%s' LIMIT 1;", g_pszSteam[nPlayer]);
            }

            num_to_str(g_pnUserId[nPlayer], szUserId, charsmax(szUserId));
            {
                SQL_ThreadQuery(g_pSqlDb, "QS_PickThreadedQueryHandler", szQuery, szUserId, charsmax(szUserId)); /** PICKS UP THEIR PREFERENCE */
            }
        }
    }

    return PLUGIN_CONTINUE;
}

///
/// client_putinserver ( nPlayer )
///
/// EXECUTES WHEN CLIENT JOINS
///
public client_putinserver(nPlayer)
{
    static szParam[16] = { EOS, ... }, nSysTime = 0;

    ///
    /// SANITY CHECK
    ///
    if (!g_bEnabled)
    {
        return PLUGIN_CONTINUE;
    }

    ///
    /// RETRIEVES PLAYER NAME
    ///
    get_user_name(nPlayer, g_pszName[nPlayer], charsmax(g_pszName[]));

    ///
    /// HLTV
    ///
    g_pbHLTV[nPlayer] = bool: is_user_hltv(nPlayer);

    ///
    /// BOT
    ///
    g_pbBOT[nPlayer] = bool: is_user_bot(nPlayer);

    ///
    /// NO KILLS
    ///
    if (g_bKStreak)
    {
        g_pnKills[nPlayer] = 0;
    }

    ///
    /// NO HATTRICK KILLS
    ///
    if (g_bHattrick)
    {
        g_pnKillsThisRound[nPlayer] = 0;
    }

    ///
    /// IN GAME
    ///
    g_pbInGame[nPlayer] = true;

    ///
    /// PLAYER PREFERENCES ACCESS
    ///
    g_pbAccess[nPlayer] = true;

    ///
    /// USER ID
    ///
    g_pnUserId[nPlayer] = get_user_userid(nPlayer);

    ///
    /// NO REVENGE STAMP YET
    ///
    if (g_bRevenge)
    {
        QS_ClearString(g_pszRevengeStamp[nPlayer]);
        {
            g_pnRevengeStamp[nPlayer] = QS_INVALID_USER_ID;
        }
    }

    ///
    /// ZERO FLOATS
    ///
    if (g_bDKill)
    {
        g_pfLastKillTimeStamp[nPlayer] = 0.000000;
    }

    ///
    /// PRINTS INFORMATION FOR VALID PLAYERS ONLY
    ///
    if (!g_pbBOT[nPlayer] && !g_pbHLTV[nPlayer])
    {
        if (g_bChatInfo)
        {
            num_to_str((nSysTime = get_systime(0)), szParam, charsmax(szParam));
            {
                set_task(QS_PLUGIN_INFO_DELAY, "QS_DisplayPlayerInfo", g_pnUserId[nPlayer] + nSysTime, szParam, charsmax(szParam), "", 0);
            }
        }
    }

    return PLUGIN_CONTINUE;
}

///
/// PRINTS INFORMATION TO PLAYER
///
public QS_DisplayPlayerInfo(szParam[], nTaskId)
{
    static nPlayer = QS_INVALID_PLAYER, nUserId = QS_INVALID_USER_ID;

    ///
    /// ESTABLISH THE USER ID
    ///
    nUserId = (nTaskId - str_to_num(szParam));

    ///
    /// INVALID USER ID
    ///
    if (!QS_ValidUserId(nUserId))
    {
        return PLUGIN_CONTINUE;
    }

    ///
    /// PLAYER ENTITY INDEX BY PLAYER USER ID
    ///
    nPlayer = QS_PlayerIdByPlayerUserId(nUserId);

    ///
    /// INVALID PLAYER
    ///
    if (!QS_IsPlayer(nPlayer))
    {
        return PLUGIN_CONTINUE;
    }

    ///
    /// ONLY IF IN GAME
    ///
    if (g_pbInGame[nPlayer])
    {
        if (g_bSql)
        {
            if (g_pSqlDb != Empty_Handle)
            {
                if (g_bSkipExisting)
                {
                    if (g_pbLoaded[nPlayer])
                    {
                        if (g_pbExisting[nPlayer])
                        {
                            if (g_pbValidSteam[nPlayer])
                            {
                                return PLUGIN_CONTINUE; /** SKIP DISPLAYING ANY INFORMATION */
                            }
                        }
                    }
                }
            }
        }

        ///
        /// NOTICE THE USER
        ///
    }

    return PLUGIN_CONTINUE;
}

///
/// EXECUTED ON PLAYER DEATH
///
/// THIS IS ONLY REQUIRED FOR CS/ CZ, DOD, TS AND TFC
/// THIS IS EXECUTED BEFORE THE DEATH MESSAGE EVENT
///
public client_death(nKiller, nVictim, nWeapon, nPlace, nTeamKill)
{
    ///
    /// SANITY CHECK
    ///
    if (!g_bEnabled)
    {
        return PLUGIN_CONTINUE;
    }

    ///
    /// CACHES THE WEAPON ID
    ///
    g_pnWeapon[nVictim] = nWeapon;

    ///
    /// CACHES THE HIT PLACE ID
    ///
    g_pnPlace[nVictim] = nPlace;

    ///
    /// CACHES THE TEAM KILL BOOLEAN
    ///
    g_pnTeamKill[nVictim] = nTeamKill;

    ///
    /// CACHES THE EXECUTION TIME STAMP
    ///
    g_pfXStatsTimeStamp[nVictim] = get_gametime();

    ///
    /// THE LAST MAN STANDING PREPARATION
    ///
    if (g_bTLMStanding)
    {
        set_task(QS_STANDING_TRIGGER_DELAY, "QS_PrepareManStanding", get_systime(0), "", 0, "", 0);
    }

    return PLUGIN_CONTINUE;
}

///
/// PREPARES THE LAST MAN STANDING
///
public QS_PrepareManStanding(nTaskId)
{
    if (QS_GetTeamTotalAlive(QS_CSCZ_TEAM_TE) == 1 || QS_GetTeamTotalAlive(QS_CSCZ_TEAM_CT) == 1)
    {
        set_task(0.000000, "QS_PerformManStanding", get_systime(0), "", 0, "", 0);
    }

    return PLUGIN_CONTINUE;
}

///
/// PERFORMS THE LAST MAN STANDING
///
public QS_PerformManStanding(nTaskId)
{
    static nPlayer = QS_INVALID_PLAYER, nTEGuy = QS_INVALID_PLAYER, nTEs = 0, nCTGuy = QS_INVALID_PLAYER, nCTs = 0, pnColor[4] = { QS_MIN_BYTE, ... };

    nTEs = QS_GetTeamTotalAlive(QS_CSCZ_TEAM_TE, nTEGuy);
    nCTs = QS_GetTeamTotalAlive(QS_CSCZ_TEAM_CT, nCTGuy);

    if (g_bTLMStandingDone_TE == false && nTEs == 1 && nCTs > 0)
    {
        g_bTLMStandingDone_TE = true;

        QS_ClientCmd(nTEGuy, "SPK \"%a\"", ArrayGetStringHandle(g_pTLMStanding, random_num(0, g_nTLMStandingSize - 1)));

        QS_HudMsgColor();
        {
            QS_MakeRGBA(pnColor);
            {
                QS_SetHudMsg(g_nRed, g_nGreen, g_nBlue, QS_HUD_MSG_X_POS, QS_STANDING_Y_POS, QS_HUD_MSG_EFFECTS, QS_HUD_MSG_EFFECTS_TIME, QS_HUD_MSG_HOLD_TIME, QS_HUD_MSG_FADE_IN_TIME, QS_HUD_MSG_FADE_OUT_TIME, -1, QS_HUD_MSG_ALPHA_AMOUNT, pnColor);
            }
        }

        for (nPlayer = QS_MIN_PLAYER; nPlayer <= g_nMaxPlayers; nPlayer++)
        {
            if (!g_pbInGame[nPlayer] || g_pbBOT[nPlayer] || g_pbHLTV[nPlayer] || get_user_team(nPlayer) != QS_CSCZ_TEAM_TE)
            {
                continue;
            }

            if (nPlayer == nTEGuy)
            {
                if (g_bTLMStandingSelfMsg)
                {
                    QS_ShowHudMsg(nTEGuy, g_pnHudMsgObj[QS_HUD_STANDING], g_szTLMStandingSelfMsg, ArrayGetStringHandle(g_pTLMStandingWords, random_num(0, g_nTLMStandingWordsSize - 1)));
                }
            }

            else
            {
                if (g_bTLMStandingTeamMsg)
                {
                    QS_ShowHudMsg(nPlayer, g_pnHudMsgObj[QS_HUD_STANDING], g_szTLMStandingTeamMsg, g_pszName[nTEGuy], ArrayGetStringHandle(g_pTLMStandingWords, random_num(0, g_nTLMStandingWordsSize - 1)));
                }
            }
        }
    }

    else if (g_bTLMStandingDone_CT == false && nCTs == 1 && nTEs > 0)
    {
        g_bTLMStandingDone_CT = true;

        QS_ClientCmd(nCTGuy, "SPK \"%a\"", ArrayGetStringHandle(g_pTLMStanding, random_num(0, g_nTLMStandingSize - 1)));

        QS_HudMsgColor();
        {
            QS_MakeRGBA(pnColor);
            {
                QS_SetHudMsg(g_nRed, g_nGreen, g_nBlue, QS_HUD_MSG_X_POS, QS_STANDING_Y_POS, QS_HUD_MSG_EFFECTS, QS_HUD_MSG_EFFECTS_TIME, QS_HUD_MSG_HOLD_TIME, QS_HUD_MSG_FADE_IN_TIME, QS_HUD_MSG_FADE_OUT_TIME, -1, QS_HUD_MSG_ALPHA_AMOUNT, pnColor);
            }
        }

        for (nPlayer = QS_MIN_PLAYER; nPlayer <= g_nMaxPlayers; nPlayer++)
        {
            if (!g_pbInGame[nPlayer] || g_pbBOT[nPlayer] || g_pbHLTV[nPlayer] || get_user_team(nPlayer) != QS_CSCZ_TEAM_CT)
            {
                continue;
            }

            if (nPlayer == nCTGuy)
            {
                if (g_bTLMStandingSelfMsg)
                {
                    QS_ShowHudMsg(nCTGuy, g_pnHudMsgObj[QS_HUD_STANDING], g_szTLMStandingSelfMsg, ArrayGetStringHandle(g_pTLMStandingWords, random_num(0, g_nTLMStandingWordsSize - 1)));
                }
            }

            else
            {
                if (g_bTLMStandingTeamMsg)
                {
                    QS_ShowHudMsg(nPlayer, g_pnHudMsgObj[QS_HUD_STANDING], g_szTLMStandingTeamMsg, g_pszName[nCTGuy], ArrayGetStringHandle(g_pTLMStandingWords, random_num(0, g_nTLMStandingWordsSize - 1)));
                }
            }
        }
    }

    return PLUGIN_CONTINUE;
}

///
/// WHEN THE ROUND RESTARTS
///
public QS_OnRoundRefresh()
{
    ///
    /// RESETS ALL THE ROUND STATS DURING THE BEGINNING OF THE NEXT ROUND ( IF ANY )
    ///
    g_bResetAllTheRoundStats = true;

    return PLUGIN_CONTINUE;
}

///
/// WHEN THE ROUND LAUNCHES
///
public QS_OnRoundLaunch()
{
    static nPlayer = QS_INVALID_PLAYER;

    ///
    /// RESETS FIRST BLOOD
    ///
    if (g_bFBlood)
    {
        g_nFBlood = 0;
    }

    ///
    /// RESETS KILLS THIS ROUND
    ///
    if (g_bFlawless || g_bHattrick)
    {
        g_nKillsThisRound = 0;
    }

    ///
    /// RESETS THE LAST MAN STANDING
    ///
    if (g_bTLMStanding)
    {
        g_bTLMStandingDone_TE = false;
        g_bTLMStandingDone_CT = false;
    }

    ///
    /// RESETS ROUND DEPENDENT HATTRICK FEATURE DATA
    ///
    if (g_bHattrick)
    {
        for (nPlayer = QS_MIN_PLAYER; nPlayer <= g_nMaxPlayers; nPlayer++)
        {
            g_pnKillsThisRound[nPlayer] = 0;
        }
    }

    ///
    /// RESETS ALL THE ROUND DATA IF NEEDED
    ///
    if (g_bResetAllTheRoundStats && (g_bRevenge || g_bKStreak))
    {
        for (nPlayer = QS_MIN_PLAYER, g_bResetAllTheRoundStats = false; nPlayer <= g_nMaxPlayers; nPlayer++)
        {
            ///
            /// CLEARS PLAYER K. STREAK DATA
            ///
            if (g_bKStreak)
            {
                g_pnKills[nPlayer] = 0;
            }

            ///
            /// CLEARS PLAYER REVENGE DATA
            ///
            if (g_bRevenge)
            {
                QS_ClearString(g_pszRevengeStamp[nPlayer]);
                {
                    g_pnRevengeStamp[nPlayer] = QS_INVALID_USER_ID;
                }
            }
        }
    }

    else
    {
        g_bResetAllTheRoundStats = false;
    }

    ///
    /// PREPARES THE ROUND START EVENT
    ///
    if (g_bRStart)
    {
        set_task(g_fRStartDelay, "QS_RoundStart", get_systime(0), "", 0, "", 0);
    }

    return PLUGIN_CONTINUE;
}

///
/// WHEN THE ROUND STARTS
///
public QS_OnRoundBegin()
{
    static nPlayer = QS_INVALID_PLAYER;

    ///
    /// RESETS THE FIRST BLOOD FEATURE
    ///
    if (g_bFBlood)
    {
        g_nFBlood = 0;
    }

    ///
    /// RESETS KILLS THIS ROUND
    ///
    if (g_bFlawless || g_bHattrick)
    {
        g_nKillsThisRound = 0;
    }

    ///
    /// RESETS THE LAST MAN STANDING
    ///
    if (g_bTLMStanding)
    {
        g_bTLMStandingDone_TE = false;
        g_bTLMStandingDone_CT = false;
    }

    ///
    /// RESETS THE HATTRICK FEATURE ROUND RELATED DATA
    ///
    if (g_bHattrick)
    {
        for (nPlayer = QS_MIN_PLAYER; nPlayer <= g_nMaxPlayers; nPlayer++)
        {
            g_pnKillsThisRound[nPlayer] = 0;
        }
    }

    ///
    /// RESETS ALL THE ROUND DATA IF NEEDED
    ///
    if (g_bResetAllTheRoundStats && (g_bRevenge || g_bKStreak))
    {
        for (nPlayer = QS_MIN_PLAYER, g_bResetAllTheRoundStats = false; nPlayer <= g_nMaxPlayers; nPlayer++)
        {
            ///
            /// CLEARS PLAYER K. STREAK DATA
            ///
            if (g_bKStreak)
            {
                g_pnKills[nPlayer] = 0;
            }

            ///
            /// CLEARS PLAYER REVENGE DATA
            ///
            if (g_bRevenge)
            {
                QS_ClearString(g_pszRevengeStamp[nPlayer]);
                {
                    g_pnRevengeStamp[nPlayer] = QS_INVALID_USER_ID;
                }
            }
        }
    }

    else
    {
        g_bResetAllTheRoundStats = false;
    }

    return PLUGIN_CONTINUE;
}

///
/// WHEN THE ROUND ENDS
///
public QS_OnRoundEnd()
{
    ///
    /// GETS HATTRICK READY
    ///
    if (g_bHattrick)
    {
        if (g_nKillsThisRound)
        {
            if (g_bDOD)
            {
                set_task(QS_HATTRICK_ROUND_END_DELAY_DOD, "QS_Hattrick", get_systime(0), "", 0, "", 0);
            }

            else
            {
                set_task(QS_HATTRICK_ROUND_END_DELAY, "QS_Hattrick", get_systime(0), "", 0, "", 0);
            }
        }
    }

    ///
    /// GETS FLAWLESS READY
    ///
    if (g_bFlawless)
    {
        if (g_nKillsThisRound)
        {
            set_task(QS_FLAWLESS_ROUND_END_DELAY, "QS_Flawless", get_systime(0), "", 0, "", 0);
        }
    }

    return PLUGIN_CONTINUE;
}

///
/// PREPARES THE ROUND START EVENT
///
public QS_RoundStart(nTaskId)
{
    ///
    /// DATA
    ///
    static pnColor[4] = { QS_MIN_BYTE, ... };

    ///
    /// SANITY CHECK
    ///
    if (!QS_IsThereAnyAlivePlayer())
    {
        return PLUGIN_CONTINUE;
    }

    ///
    /// PREPARES ROUND START EVENT
    ///
    if (g_bRStart)
    {
        if (g_bRStartMsg)
        {
            QS_HudMsgColor();
            {
                QS_MakeRGBA(pnColor);
                {
                    QS_SetHudMsg(g_nRed, g_nGreen, g_nBlue, QS_HUD_MSG_X_POS, g_bDOD ? QS_ROUND_Y_POS_DOD : QS_ROUND_Y_POS, QS_HUD_MSG_EFFECTS, QS_HUD_MSG_EFFECTS_TIME, QS_HUD_MSG_HOLD_TIME, QS_HUD_MSG_FADE_IN_TIME, QS_HUD_MSG_FADE_OUT_TIME, -1, QS_HUD_MSG_ALPHA_AMOUNT, pnColor);
                    {
                        QS_ShowHudMsg(QS_EVERYONE, g_pnHudMsgObj[QS_HUD_ROUND], g_szRStartMsg);
                    }
                }
            }
        }

        QS_ClientCmd(QS_EVERYONE, "SPK \"%a\"", ArrayGetStringHandle(g_pRStart, random_num(0, g_nRStartSize - 1)));
    }

    return PLUGIN_CONTINUE;
}

///
/// PREPARES HATTRICK
///
public QS_Hattrick(nTaskId)
{
    ///
    /// DATA
    ///
    static nLeader = QS_INVALID_PLAYER, nTeam = QS_INVALID_TEAM, pnPlayers[QS_MAX_PLAYERS] = { QS_INVALID_PLAYER, ... }, nTotal = 0, nPlayer = QS_INVALID_PLAYER, nIter = 0, pnColor[4] = { QS_MIN_BYTE, ... };

    ///
    /// SANITY CHECK
    ///
    if (!g_nKillsThisRound)
    {
        return PLUGIN_CONTINUE;
    }

    ///
    /// RETRIEVES THE LEADER'S ID
    ///
    nLeader = QS_Leader();

    ///
    /// IF ANY
    ///
    if (QS_IsPlayer(nLeader))
    {
        if (g_pnKillsThisRound[nLeader] >= g_nMinKillsForHattrick)
        {
            if (g_bHattrickMsg)
            {
                QS_HudMsgColor();
                {
                    QS_MakeRGBA(pnColor);
                    {
                        QS_SetHudMsg(g_nRed, g_nGreen, g_nBlue, QS_HUD_MSG_X_POS, g_bDOD ? QS_HATTRICK_Y_POS_DOD : QS_HATTRICK_Y_POS, QS_HUD_MSG_EFFECTS, QS_HUD_MSG_EFFECTS_TIME, QS_HUD_MSG_HOLD_TIME, QS_HUD_MSG_FADE_IN_TIME, QS_HUD_MSG_FADE_OUT_TIME, -1, QS_HUD_MSG_ALPHA_AMOUNT, pnColor);
                    }
                }

                if (g_bHattrickToAll)
                {
                    QS_ShowHudMsgAll(QS_EVERYONE, g_pnHudMsgObj[QS_HUD_HATTRICK], g_szHattrickMsg, g_pszName[nLeader]);
                }

                else
                {
                    QS_ShowHudMsg(QS_EVERYONE, g_pnHudMsgObj[QS_HUD_HATTRICK], g_szHattrickMsg, g_pszName[nLeader]);
                }
            }

            if (g_bHattrickToAll)
            {
                QS_ClientCmdAll(QS_EVERYONE, "SPK \"%a\"", ArrayGetStringHandle(g_pHattrick, random_num(0, g_nHattrickSize - 1)));

                if (g_bHattrickMsgTalk)
                {
                    switch (g_bColors)
                    {
                        case true:
                        {
                            nTeam = get_user_team(nLeader);
                            {
                                switch (nTeam)
                                {
                                    case QS_CSCZ_TEAM_CT:
                                    {
                                        QS_CSCZColored(QS_EVERYONE, QS_CC_ST_X03_BLUE, "\x01>> QUAKE SOUNDS \x03%s \x01HAD \x04%d VICTIM%s\x01.", g_pszName[nLeader], g_pnKillsThisRound[nLeader], g_pnKillsThisRound[nLeader] == 1 ? "" : "S");
                                    }

                                    case QS_CSCZ_TEAM_TE:
                                    {
                                        QS_CSCZColored(QS_EVERYONE, QS_CC_ST_X03_RED, "\x01>> QUAKE SOUNDS \x03%s \x01HAD \x04%d VICTIM%s\x01.", g_pszName[nLeader], g_pnKillsThisRound[nLeader], g_pnKillsThisRound[nLeader] == 1 ? "" : "S");
                                    }

                                    default:
                                    {
                                        QS_CSCZColored(QS_EVERYONE, QS_CC_ST_X03_GREY, "\x01>> QUAKE SOUNDS \x03%s \x01HAD \x04%d VICTIM%s\x01.", g_pszName[nLeader], g_pnKillsThisRound[nLeader], g_pnKillsThisRound[nLeader] == 1 ? "" : "S");
                                    }
                                }
                            }
                        }

                        default:
                        {
 //                           client_print(QS_EVERYONE, print_chat, ">> QUAKE SOUNDS %s HAD %d VICTIM%s.", g_pszName[nLeader], g_pnKillsThisRound[nLeader], g_pnKillsThisRound[nLeader] == 1 ? "" : "S");
                        }
                    }
                }
            }

            else
            {
                QS_ClientCmd(QS_EVERYONE, "SPK \"%a\"", ArrayGetStringHandle(g_pHattrick, random_num(0, g_nHattrickSize - 1)));

                if (g_bHattrickMsgTalk)
                {
                    switch (g_bColors)
                    {
                        case true:
                        {
                            nTeam = get_user_team(nLeader);
                            {
                                switch (nTeam)
                                {
                                    case QS_CSCZ_TEAM_CT:
                                    {
                                        QS_CSCZColoredFiltered(QS_EVERYONE, QS_CC_ST_X03_BLUE, "\x01>> QUAKE SOUNDS \x03%s \x01HAD \x04%d VICTIM%s\x01.", g_pszName[nLeader], g_pnKillsThisRound[nLeader], g_pnKillsThisRound[nLeader] == 1 ? "" : "S");
                                    }

                                    case QS_CSCZ_TEAM_TE:
                                    {
                                        QS_CSCZColoredFiltered(QS_EVERYONE, QS_CC_ST_X03_RED, "\x01>> QUAKE SOUNDS \x03%s \x01HAD \x04%d VICTIM%s\x01.", g_pszName[nLeader], g_pnKillsThisRound[nLeader], g_pnKillsThisRound[nLeader] == 1 ? "" : "S");
                                    }

                                    default:
                                    {
                                        QS_CSCZColoredFiltered(QS_EVERYONE, QS_CC_ST_X03_GREY, "\x01>> QUAKE SOUNDS \x03%s \x01HAD \x04%d VICTIM%s\x01.", g_pszName[nLeader], g_pnKillsThisRound[nLeader], g_pnKillsThisRound[nLeader] == 1 ? "" : "S");
                                    }
                                }
                            }
                        }

                        default:
                        {
                            get_players(pnPlayers, nTotal, "ch", ""); /// NO BOTS & HLTV PROXIES
                            {
                                if (nTotal > 0)
                                {
                                    for (nIter = 0; nIter < nTotal; nIter++)
                                    {
                                        nPlayer = pnPlayers[nIter];
                                        {
                                            if (g_pbInGame[nPlayer])
                                            {
                                                if (!g_pbDisabled[nPlayer])
                                                {
  //                                                  client_print(QS_EVERYONE, print_chat, ">> QUAKE SOUNDS %s HAD %d VICTIM%s.", g_pszName[nLeader], g_pnKillsThisRound[nLeader], g_pnKillsThisRound[nLeader] == 1 ? "" : "S");
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    return PLUGIN_CONTINUE;
}

///
/// PREPARES FLAWLESS
///
public QS_Flawless(nTaskId)
{
    static nAliveTeam_TE = 0, nAliveTeam_CT = 0, nAllTeam_TE = 0, nAllTeam_CT = 0, pnColor[4] = { QS_MIN_BYTE, ... };

    ///
    /// SANITY CHECK
    ///
    if (!g_nKillsThisRound)
    {
        return PLUGIN_CONTINUE;
    }

    nAliveTeam_TE = QS_ActivePlayersNum(true /** true = ALIVE PLAYERS */, QS_CSCZ_TEAM_TE);
    nAliveTeam_CT = QS_ActivePlayersNum(true /** true = ALIVE PLAYERS */, QS_CSCZ_TEAM_CT);

    nAllTeam_TE = nAliveTeam_TE + QS_ActivePlayersNum(false /** false = DEAD PLAYERS */, QS_CSCZ_TEAM_TE);
    nAllTeam_CT = nAliveTeam_CT + QS_ActivePlayersNum(false /** false = DEAD PLAYERS */, QS_CSCZ_TEAM_CT);

    QS_HudMsgColor();
    {
        QS_MakeRGBA(pnColor);
        {
            QS_SetHudMsg(g_nRed, g_nGreen, g_nBlue, QS_HUD_MSG_X_POS, QS_FLAWLESS_Y_POS, QS_HUD_MSG_EFFECTS, QS_HUD_MSG_EFFECTS_TIME, QS_HUD_MSG_HOLD_TIME, QS_HUD_MSG_FADE_IN_TIME, QS_HUD_MSG_FADE_OUT_TIME, -1, QS_HUD_MSG_ALPHA_AMOUNT, pnColor);
        }
    }

    if (nAllTeam_TE >= QS_FLAWLESS_MIN_PLAYERS_IN_TEAM && (nAllTeam_TE == nAliveTeam_TE) && nAllTeam_CT)
    {
        if (g_bFlawlessMsg)
        {
            QS_ShowHudMsg(QS_EVERYONE, g_pnHudMsgObj[QS_HUD_FLAWLESS], g_szFlawlessMsg, g_szFlawlessTeamName_TE);
        }

        QS_ClientCmd(QS_EVERYONE, "SPK \"%a\"", ArrayGetStringHandle(g_pFlawless, random_num(0, g_nFlawlessSize - 1)));
    }

    else if (nAllTeam_CT >= QS_FLAWLESS_MIN_PLAYERS_IN_TEAM && (nAllTeam_CT == nAliveTeam_CT) && nAllTeam_TE)
    {
        if (g_bFlawlessMsg)
        {
            QS_ShowHudMsg(QS_EVERYONE, g_pnHudMsgObj[QS_HUD_FLAWLESS], g_szFlawlessMsg, g_szFlawlessTeamName_CT);
        }

        QS_ClientCmd(QS_EVERYONE, "SPK \"%a\"", ArrayGetStringHandle(g_pFlawless, random_num(0, g_nFlawlessSize - 1)));
    }

    return PLUGIN_CONTINUE;
}

///
/// pfnMessageBegin ( )
///
/// FIRED WHEN A MESSAGE BEGINS
///
public QS_FM_OnMsgBegin(nDestination, nType)
{
    ///
    /// IF GLOBALLY SENT
    ///
    if ((nType == g_nDeathMsg) && ((nDestination == MSG_ALL) || (nDestination == MSG_BROADCAST)))
    {
        g_bOnDeathMsg = true;
        {
            g_nDeathMsgByteStatus = QS_DEATHMSG_NONE;
        }
    }

    return PLUGIN_CONTINUE;
}

///
/// pfnWriteByte ( )
///
/// FIRED WHEN A BYTE IS BEING WRITTEN
///
public QS_FM_OnWriteByte(nByte)
{
    ///
    /// OUR DEATHMSG
    ///
    if (g_bOnDeathMsg)
    {
        ///
        /// GETS DATA
        ///
        switch (++g_nDeathMsgByteStatus)
        {
            case QS_DEATHMSG_KILLER: /// KILLER ID
            {
                g_nKiller = nByte;
            }

            case QS_DEATHMSG_VICTIM: /// VICTIM ID
            {
                g_nVictim = nByte;
            }
        }
    }

    return PLUGIN_CONTINUE;
}

///
/// pfnMessageEnd ( )
///
/// FIRED WHEN A MESSAGE ENDS ( USED IN GAMES WITH "DeathMsg" )
///
public QS_FM_OnMsgEnd()
{
    static Float: fGameTime = 0.000000, Float: fGameTimeStamp = 0.000000, nVictimStamp = QS_INVALID_PLAYER, nKillerStamp = QS_INVALID_PLAYER, pnInfo[8] = { QS_INVALID_PLAYER, ... }, nWeapon = QS_INVALID_WEAPON;

    ///
    /// OUR DEATHMSG
    ///
    if (g_bOnDeathMsg)
    {
        ///
        /// GAME TIME
        ///
        fGameTime = get_gametime();

        g_bOnDeathMsg = false;
        {
            g_nDeathMsgByteStatus = QS_DEATHMSG_NONE;
        }

        ///
        /// FIRES
        ///
        switch ((nVictimStamp == g_nVictim) && (nKillerStamp == g_nKiller))
        {
            case false:
            {
                pnInfo[0] = g_nKiller;
                pnInfo[1] = g_nVictim;

                if (QS_IsPlayer(g_nVictim) && g_pbInGame[g_nVictim])
                {
                    g_nWeapon = QS_INVALID_WEAPON;
                    g_nPlace = QS_INVALID_PLACE;
                    g_nTeamKill = QS_TEAM_KILL_NO;

                    get_user_attacker(g_nVictim, g_nWeapon, g_nPlace);

                    if (QS_IsPlayer(g_nKiller) && g_pbInGame[g_nKiller])
                    {
                        g_nTeamKill = (get_user_team(g_nKiller) == get_user_team(g_nVictim)) ? QS_TEAM_KILL_YES : QS_TEAM_KILL_NO;

                        if (!QS_ValidWeapon(g_nWeapon))
                        {
                            nWeapon = get_user_weapon(g_nKiller);
                            {
                                if (QS_ValidWeapon(nWeapon))
                                {
                                    g_nWeapon = nWeapon;
                                }
                            }
                        }
                    }

                    pnInfo[2] = g_nWeapon;
                    pnInfo[3] = g_nPlace;
                    pnInfo[4] = g_nTeamKill;
                }

                else
                {
                    pnInfo[2] = QS_INVALID_WEAPON;
                    pnInfo[3] = QS_INVALID_PLACE;
                    pnInfo[4] = QS_TEAM_KILL_NO;
                }

                set_task(0.000000, "QS_ProcessDeathMsg", get_systime(0), pnInfo, charsmax(pnInfo), "", 0);
            }

            default:
            {
                ///
                /// PREVENTS DUAL EXECUTION OF THE SAME EVENT
                ///
                if (fGameTimeStamp != fGameTime)
                {
                    pnInfo[0] = g_nKiller;
                    pnInfo[1] = g_nVictim;

                    if (QS_IsPlayer(g_nVictim) && g_pbInGame[g_nVictim])
                    {
                        g_nWeapon = QS_INVALID_WEAPON;
                        g_nPlace = QS_INVALID_PLACE;
                        g_nTeamKill = QS_TEAM_KILL_NO;

                        get_user_attacker(g_nVictim, g_nWeapon, g_nPlace);

                        if (QS_IsPlayer(g_nKiller) && g_pbInGame[g_nKiller])
                        {
                            g_nTeamKill = (get_user_team(g_nKiller) == get_user_team(g_nVictim)) ? QS_TEAM_KILL_YES : QS_TEAM_KILL_NO;

                            if (!QS_ValidWeapon(g_nWeapon))
                            {
                                nWeapon = get_user_weapon(g_nKiller);
                                {
                                    if (QS_ValidWeapon(nWeapon))
                                    {
                                        g_nWeapon = nWeapon;
                                    }
                                }
                            }
                        }

                        pnInfo[2] = g_nWeapon;
                        pnInfo[3] = g_nPlace;
                        pnInfo[4] = g_nTeamKill;
                    }

                    else
                    {
                        pnInfo[2] = QS_INVALID_WEAPON;
                        pnInfo[3] = QS_INVALID_PLACE;
                        pnInfo[4] = QS_TEAM_KILL_NO;
                    }

                    set_task(0.000000, "QS_ProcessDeathMsg", get_systime(0), pnInfo, charsmax(pnInfo), "", 0);
                }
            }
        }

        fGameTimeStamp = fGameTime;
        {
            nVictimStamp = g_nVictim;
            nKillerStamp = g_nKiller;
        }
    }

    return PLUGIN_CONTINUE;
}

///
/// ADD TO THE DATABASE
///
public QS_AddThreadedQueryHandler(nFailState, Handle: pQuery, szError[], nErrorCode, szCustomUserData[], nCustomUserDataSize /** != LENGTH */, Float: fQueueTimeSeconds)
{
    ///
    /// DATA
    ///
    static nUserId = QS_INVALID_USER_ID, nPlayer = QS_INVALID_PLAYER, szParam[16] = { EOS, ... }, nSysTime = 0, Float: fErrorStamp = 0.000000, Float: fGameTime = 0.000000;

    ///
    /// EXCEPTION
    ///
    if (!g_bSql || Empty_Handle == g_pSqlDb)
    {
        return PLUGIN_CONTINUE;
    }

    ///
    /// SUCCESS
    ///
    if (!nFailState && QS_EmptyString(szError) && !nErrorCode)
    {
        nUserId = str_to_num(szCustomUserData);
        {
            if (QS_ValidUserId(nUserId))
            {
                nPlayer = QS_PlayerIdByPlayerUserId(nUserId);
                {
                    if (QS_IsPlayer(nPlayer))
                    {
                        if (pQuery != Empty_Handle) /** SUCCESS */
                        {
                            ///
                            /// INSERTED A ROW INTO THE SQL TABLE
                            ///
                            if (SQL_AffectedRows(pQuery) > 0)
                            {
                                ///
                                /// INSERTION OF PLAYER STEAM ID INTO THE DATABASE SUCCEEDED
                                ///
                                g_pbLoaded[nPlayer] = true; /** CAN NOW SAVE THEIR PREFERENCE IF THEY TYPE '/SOUNDS' */
                            }

                            ///
                            /// ERROR
                            ///
                            else
                            {
                                fGameTime = get_gametime();

                                if ((0.000000 == fErrorStamp) || ((fGameTime - fErrorStamp) > 120.000000))
                                {
                                    fErrorStamp = fGameTime;

                                    log_to_file(QS_LOG_FILE_NAME, "****************************************************************************************************************");
                                    log_to_file(QS_LOG_FILE_NAME, "Sql Threaded Query Failed [ SQL_ThreadQuery ].");
                                    log_to_file(QS_LOG_FILE_NAME, "Error Code [ %d ].", nErrorCode);
                                    log_to_file(QS_LOG_FILE_NAME, "Error Description [ %s ].", !QS_EmptyString(szError) ? szError : "N/ A");
                                    log_to_file(QS_LOG_FILE_NAME, "Fail State [ %s ].", nFailState < TQUERY_QUERY_FAILED ? "SQL SERVER CONNECTION ERROR" : "SQL DATABASE QUERY ERROR");
                                    log_to_file(QS_LOG_FILE_NAME, "Function [ QS_AddThreadedQueryHandler ]. This Error Can Be Ignored If It Happens Rarely.");
                                }

                                ///
                                /// RETRY THE ACTION
                                ///
                                num_to_str((nSysTime = get_systime(0)), szParam, charsmax(szParam));
                                {
                                    set_task(QS_CONNECTION_DELAY, "QS_RetryPick", nUserId + nSysTime, szParam, charsmax(szParam), "", 0);
                                }
                            }
                        }

                        ///
                        /// ERROR
                        ///
                        else
                        {
                            fGameTime = get_gametime();

                            if ((0.000000 == fErrorStamp) || ((fGameTime - fErrorStamp) > 120.000000))
                            {
                                fErrorStamp = fGameTime;

                                log_to_file(QS_LOG_FILE_NAME, "****************************************************************************************************************");
                                log_to_file(QS_LOG_FILE_NAME, "Sql Threaded Query Failed [ SQL_ThreadQuery ].");
                                log_to_file(QS_LOG_FILE_NAME, "Error Code [ %d ].", nErrorCode);
                                log_to_file(QS_LOG_FILE_NAME, "Error Description [ %s ].", !QS_EmptyString(szError) ? szError : "N/ A");
                                log_to_file(QS_LOG_FILE_NAME, "Fail State [ %s ].", nFailState < TQUERY_QUERY_FAILED ? "SQL SERVER CONNECTION ERROR" : "SQL DATABASE QUERY ERROR");
                                log_to_file(QS_LOG_FILE_NAME, "Function [ QS_AddThreadedQueryHandler ]. This Error Can Be Ignored If It Happens Rarely.");
                            }

                            ///
                            /// RETRY THE ACTION
                            ///
                            num_to_str((nSysTime = get_systime(0)), szParam, charsmax(szParam));
                            {
                                set_task(QS_CONNECTION_DELAY, "QS_RetryPick", nUserId + nSysTime, szParam, charsmax(szParam), "", 0);
                            }
                        }
                    }
                }
            }
        }
    }

    ///
    /// ERROR
    ///
    else
    {
        fGameTime = get_gametime();

        if ((0.000000 == fErrorStamp) || ((fGameTime - fErrorStamp) > 120.000000))
        {
            fErrorStamp = fGameTime;

            log_to_file(QS_LOG_FILE_NAME, "****************************************************************************************************************");
            log_to_file(QS_LOG_FILE_NAME, "Sql Threaded Query Failed [ SQL_ThreadQuery ].");
            log_to_file(QS_LOG_FILE_NAME, "Error Code [ %d ].", nErrorCode);
            log_to_file(QS_LOG_FILE_NAME, "Error Description [ %s ].", !QS_EmptyString(szError) ? szError : "N/ A");
            log_to_file(QS_LOG_FILE_NAME, "Fail State [ %s ].", nFailState < TQUERY_QUERY_FAILED ? "SQL SERVER CONNECTION ERROR" : "SQL DATABASE QUERY ERROR");
            log_to_file(QS_LOG_FILE_NAME, "Function [ QS_AddThreadedQueryHandler ]. This Error Can Be Ignored If It Happens Rarely.");
        }

        nUserId = str_to_num(szCustomUserData);
        {
            if (QS_ValidUserId(nUserId))
            {
                nPlayer = QS_PlayerIdByPlayerUserId(nUserId);
                {
                    if (QS_IsPlayer(nPlayer))
                    {
                        ///
                        /// RETRY THE ACTION
                        ///
                        num_to_str((nSysTime = get_systime(0)), szParam, charsmax(szParam));
                        {
                            set_task(QS_CONNECTION_DELAY, "QS_RetryPick", nUserId + nSysTime, szParam, charsmax(szParam), "", 0);
                        }
                    }
                }
            }
        }
    }

    return PLUGIN_CONTINUE;
}

///
/// STORE TO THE DATABASE
///
public QS_StoreThreadedQueryHandler(nFailState, Handle: pQuery, szError[], nErrorCode, szCustomUserData[], nCustomUserDataSize /** != LENGTH */, Float: fQueueTimeSeconds)
{
    ///
    /// DATA
    ///
    static nUserId = QS_INVALID_USER_ID, nPlayer = QS_INVALID_PLAYER, szParam[16] = { EOS, ... }, nSysTime = 0, Float: fErrorStamp = 0.000000, Float: fGameTime = 0.000000;

    ///
    /// EXCEPTION
    ///
    if (!g_bSql || Empty_Handle == g_pSqlDb)
    {
        return PLUGIN_CONTINUE;
    }

    ///
    /// SUCCESS
    ///
    if (!nFailState && QS_EmptyString(szError) && !nErrorCode)
    {
        nUserId = str_to_num(szCustomUserData);
        {
            if (QS_ValidUserId(nUserId))
            {
                nPlayer = QS_PlayerIdByPlayerUserId(nUserId);
                {
                    if (QS_IsPlayer(nPlayer))
                    {
                        if (pQuery != Empty_Handle)
                        {
                            ///
                            /// THE ROW HAS BEEN UPDATED
                            ///
                            if (SQL_AffectedRows(pQuery) > 0)
                            {
                                ///
                                /// ALLOW ACCESS TO TYPE '/SOUNDS' AGAIN
                                ///
                                g_pbAccess[nPlayer] = true;
                            }

                            ///
                            /// ERROR
                            ///
                            else
                            {
                                fGameTime = get_gametime();

                                if ((0.000000 == fErrorStamp) || ((fGameTime - fErrorStamp) > 120.000000))
                                {
                                    fErrorStamp = fGameTime;

                                    log_to_file(QS_LOG_FILE_NAME, "****************************************************************************************************************");
                                    log_to_file(QS_LOG_FILE_NAME, "Sql Threaded Query Failed [ SQL_ThreadQuery ].");
                                    log_to_file(QS_LOG_FILE_NAME, "Error Code [ %d ].", nErrorCode);
                                    log_to_file(QS_LOG_FILE_NAME, "Error Description [ %s ].", !QS_EmptyString(szError) ? szError : "N/ A");
                                    log_to_file(QS_LOG_FILE_NAME, "Fail State [ %s ].", nFailState < TQUERY_QUERY_FAILED ? "SQL SERVER CONNECTION ERROR" : "SQL DATABASE QUERY ERROR");
                                    log_to_file(QS_LOG_FILE_NAME, "Function [ QS_StoreThreadedQueryHandler ]. This Error Can Be Ignored If It Happens Rarely.");
                                }

                                ///
                                /// RETRY THE ACTION
                                ///
                                num_to_str((nSysTime = get_systime(0)), szParam, charsmax(szParam));
                                {
                                    set_task(QS_CONNECTION_DELAY, "QS_RetryStore", nUserId + nSysTime, szParam, charsmax(szParam), "", 0);
                                }
                            }
                        }

                        ///
                        /// ERROR
                        ///
                        else
                        {
                            fGameTime = get_gametime();

                            if ((0.000000 == fErrorStamp) || ((fGameTime - fErrorStamp) > 120.000000))
                            {
                                fErrorStamp = fGameTime;

                                log_to_file(QS_LOG_FILE_NAME, "****************************************************************************************************************");
                                log_to_file(QS_LOG_FILE_NAME, "Sql Threaded Query Failed [ SQL_ThreadQuery ].");
                                log_to_file(QS_LOG_FILE_NAME, "Error Code [ %d ].", nErrorCode);
                                log_to_file(QS_LOG_FILE_NAME, "Error Description [ %s ].", !QS_EmptyString(szError) ? szError : "N/ A");
                                log_to_file(QS_LOG_FILE_NAME, "Fail State [ %s ].", nFailState < TQUERY_QUERY_FAILED ? "SQL SERVER CONNECTION ERROR" : "SQL DATABASE QUERY ERROR");
                                log_to_file(QS_LOG_FILE_NAME, "Function [ QS_StoreThreadedQueryHandler ]. This Error Can Be Ignored If It Happens Rarely.");
                            }

                            ///
                            /// RETRY THE ACTION
                            ///
                            num_to_str((nSysTime = get_systime(0)), szParam, charsmax(szParam));
                            {
                                set_task(QS_CONNECTION_DELAY, "QS_RetryStore", nUserId + nSysTime, szParam, charsmax(szParam), "", 0);
                            }
                        }
                    }
                }
            }
        }
    }

    ///
    /// ERROR
    ///
    else
    {
        fGameTime = get_gametime();

        if ((0.000000 == fErrorStamp) || ((fGameTime - fErrorStamp) > 120.000000))
        {
            fErrorStamp = fGameTime;

            log_to_file(QS_LOG_FILE_NAME, "****************************************************************************************************************");
            log_to_file(QS_LOG_FILE_NAME, "Sql Threaded Query Failed [ SQL_ThreadQuery ].");
            log_to_file(QS_LOG_FILE_NAME, "Error Code [ %d ].", nErrorCode);
            log_to_file(QS_LOG_FILE_NAME, "Error Description [ %s ].", !QS_EmptyString(szError) ? szError : "N/ A");
            log_to_file(QS_LOG_FILE_NAME, "Fail State [ %s ].", nFailState < TQUERY_QUERY_FAILED ? "SQL SERVER CONNECTION ERROR" : "SQL DATABASE QUERY ERROR");
            log_to_file(QS_LOG_FILE_NAME, "Function [ QS_StoreThreadedQueryHandler ]. This Error Can Be Ignored If It Happens Rarely.");
        }

        ///
        /// ALLOW ACCESS TO TYPE '/SOUNDS' AGAIN
        ///
        /// BUT THE SQL CONNECTION MUST BE ESTABLISHED
        ///
        nUserId = str_to_num(szCustomUserData);
        {
            if (QS_ValidUserId(nUserId))
            {
                nPlayer = QS_PlayerIdByPlayerUserId(nUserId);
                {
                    if (QS_IsPlayer(nPlayer))
                    {
                        ///
                        /// RETRY THE ACTION
                        ///
                        num_to_str((nSysTime = get_systime(0)), szParam, charsmax(szParam));
                        {
                            set_task(QS_CONNECTION_DELAY, "QS_RetryStore", nUserId + nSysTime, szParam, charsmax(szParam), "", 0);
                        }
                    }
                }
            }
        }
    }

    return PLUGIN_CONTINUE;
}

///
/// PICK FROM THE DATABASE
///
public QS_PickThreadedQueryHandler(nFailState, Handle: pQuery, szError[], nErrorCode, szCustomUserData[], nCustomUserDataSize /** != LENGTH */, Float: fQueueTimeSeconds)
{
    ///
    /// DATA
    ///
    static nUserId = QS_INVALID_USER_ID, nPlayer = QS_INVALID_PLAYER, szQuery[128] = { EOS, ... }, bWasDisabled = false, nSysTime = 0, szParam[16] = { EOS, ... }, Float: fErrorStamp = 0.000000, Float: fGameTime = 0.000000;

    ///
    /// EXCEPTION
    ///
    if (!g_bSql || Empty_Handle == g_pSqlDb)
    {
        return PLUGIN_CONTINUE;
    }

    ///
    /// SUCCESS
    ///
    if (!nFailState && QS_EmptyString(szError) && !nErrorCode)
    {
        nUserId = str_to_num(szCustomUserData);
        {
            if (QS_ValidUserId(nUserId))
            {
                nPlayer = QS_PlayerIdByPlayerUserId(nUserId);
                {
                    if (QS_IsPlayer(nPlayer))
                    {
                        if (pQuery != Empty_Handle)
                        {
                            ///
                            /// SELECTED THE SETTING ( STEAM ID EXISTING ALREADY )
                            ///
                            if (SQL_NumResults(pQuery) > 0)
                            {
                                if (g_pbDisabled[nPlayer])
                                {
                                    bWasDisabled = true;
                                }

                                else
                                {
                                    bWasDisabled = false;
                                }

                                g_pbDisabled[nPlayer] = !(bool: SQL_ReadResult(pQuery, 0 /** COLUMN #0 */)); /** USER PREFERENCE ON/ OFF */
                                {
                                    g_pbLoaded[nPlayer] = true; /** CAN NOW SAVE THEIR PREFERENCE IF THEY TYPE '/SOUNDS' */
                                    {
                                        g_pbExisting[nPlayer] = true; /** ALREADY EXISTING INTO THE DATABASE ( NO DATABASE STEAM ID INSERTION NEEDED ) */
                                    }
                                }

#if defined QS_ON_BY_DEFAULT

#if QS_ON_BY_DEFAULT == 1

                                if (bWasDisabled)
                                {
                                    if (!g_pbDisabled[nPlayer])
                                    {
                                        if (!g_bColors)
                                        {
  //                                          client_print(nPlayer, print_chat, ">> QUAKE SOUNDS ENABLED. TYPE 'sounds' TO DISABLE."); /// THEIR PREFERENCE LOADED MAYBE AFTER 1 MINUTE SINCE THEY'VE JOINED THE GAME SERVER
                                        }

                                        else
                                        {
 //                                           QS_CSCZColored(nPlayer, QS_CC_ST_X03_RED, "\x01>> QUAKE SOUNDS \x04ENABLED\x01. TYPE '\x03sounds\x01' TO \x03DISABLE\x01."); /// THEIR PREFERENCE LOADED MAYBE AFTER 1 MINUTE SINCE THEY'VE JOINED THE GAME SERVER
                                        }
                                    }
                                }

#else

                                if (!bWasDisabled)
                                {
                                    if (g_pbDisabled[nPlayer])
                                    {
                                        if (!g_bColors)
                                        {
  //                                          client_print(nPlayer, print_chat, ">> QUAKE SOUNDS DISABLED. TYPE 'sounds' TO ENABLE."); /// THEIR PREFERENCE LOADED MAYBE AFTER 1 MINUTE SINCE THEY'VE JOINED THE GAME SERVER
                                        }

                                        else
                                        {
                                            QS_CSCZColored(nPlayer, QS_CC_ST_X03_RED, "\x01>> QUAKE SOUNDS \x03DISABLED\x01. TYPE '\x04sounds\x01' TO \x04ENABLE\x01."); /// THEIR PREFERENCE LOADED MAYBE AFTER 1 MINUTE SINCE THEY'VE JOINED THE GAME SERVER
 //                                       }
                                    }
                                }

#endif

#else

                                if (bWasDisabled)
                                {
                                    if (!g_pbDisabled[nPlayer])
                                    {
                                        if (!g_bColors)
                                        {
  //                                          client_print(nPlayer, print_chat, ">> QUAKE SOUNDS ENABLED. TYPE 'sounds' TO DISABLE."); /// THEIR PREFERENCE LOADED MAYBE AFTER 1 MINUTE SINCE THEY'VE JOINED THE GAME SERVER
                                        }

                                        else
                                        {
   //                                         QS_CSCZColored(nPlayer, QS_CC_ST_X03_RED, "\x01>> QUAKE SOUNDS \x04ENABLED\x01. TYPE '\x03sounds\x01' TO \x03DISABLE\x01."); /// THEIR PREFERENCE LOADED MAYBE AFTER 1 MINUTE SINCE THEY'VE JOINED THE GAME SERVER
                                        }
                                    }
                                }

#endif

                            }

                            ///
                            /// STEAM ID NOT FOUND INTO THE DATABASE ( DATABASE INSERTION OF STEAM ID NEEDED )
                            ///
                            else
                            {
                                if (!g_bSqlLocal)
                                {
                                    if (!g_bSqlFullSteam)
                                    {
                                        formatex(szQuery, charsmax(szQuery), "INSERT IGNORE INTO aqs_enabled_fast (aqs_steam, aqs_option) VALUES ('%s', %d) LIMIT 1;", g_pszSteam[nPlayer], g_pbDisabled[nPlayer] ? 0 : 1);
                                    }

                                    else
                                    {
                                        formatex(szQuery, charsmax(szQuery), "INSERT IGNORE INTO aqs_enabled_full (aqs_steam, aqs_option) VALUES ('%s', %d) LIMIT 1;", g_pszSteam[nPlayer], g_pbDisabled[nPlayer] ? 0 : 1);
                                    }
                                }

                                else
                                {
                                    if (!g_bSqlFullSteam)
                                    {
                                        formatex(szQuery, charsmax(szQuery), "INSERT INTO aqs_enabled_fast (aqs_steam, aqs_option) VALUES ('%s', %d);", g_pszSteam[nPlayer], g_pbDisabled[nPlayer] ? 0 : 1);
                                    }

                                    else
                                    {
                                        formatex(szQuery, charsmax(szQuery), "INSERT INTO aqs_enabled_full (aqs_steam, aqs_option) VALUES ('%s', %d);", g_pszSteam[nPlayer], g_pbDisabled[nPlayer] ? 0 : 1);
                                    }
                                }

                                SQL_ThreadQuery(g_pSqlDb, "QS_AddThreadedQueryHandler", szQuery, szCustomUserData, nCustomUserDataSize);
                            }
                        }

                        ///
                        /// ERROR
                        ///
                        else
                        {
                            fGameTime = get_gametime();

                            if ((0.000000 == fErrorStamp) || ((fGameTime - fErrorStamp) > 120.000000))
                            {
                                fErrorStamp = fGameTime;

                                log_to_file(QS_LOG_FILE_NAME, "****************************************************************************************************************");
                                log_to_file(QS_LOG_FILE_NAME, "Sql Threaded Query Failed [ SQL_ThreadQuery ].");
                                log_to_file(QS_LOG_FILE_NAME, "Error Code [ %d ].", nErrorCode);
                                log_to_file(QS_LOG_FILE_NAME, "Error Description [ %s ].", !QS_EmptyString(szError) ? szError : "N/ A");
                                log_to_file(QS_LOG_FILE_NAME, "Fail State [ %s ].", nFailState < TQUERY_QUERY_FAILED ? "SQL SERVER CONNECTION ERROR" : "SQL DATABASE QUERY ERROR");
                                log_to_file(QS_LOG_FILE_NAME, "Function [ QS_PickThreadedQueryHandler ]. This Error Can Be Ignored If It Happens Rarely.");
                            }

                            ///
                            /// RETRY THE ACTION
                            ///
                            num_to_str((nSysTime = get_systime(0)), szParam, charsmax(szParam));
                            {
                                set_task(QS_CONNECTION_DELAY, "QS_RetryPick", nUserId + nSysTime, szParam, charsmax(szParam), "", 0);
                            }
                        }
                    }
                }
            }
        }
    }

    ///
    /// ERROR
    ///
    else
    {
        fGameTime = get_gametime();

        if ((0.000000 == fErrorStamp) || ((fGameTime - fErrorStamp) > 120.000000))
        {
            fErrorStamp = fGameTime;

            log_to_file(QS_LOG_FILE_NAME, "****************************************************************************************************************");
            log_to_file(QS_LOG_FILE_NAME, "Sql Threaded Query Failed [ SQL_ThreadQuery ].");
            log_to_file(QS_LOG_FILE_NAME, "Error Code [ %d ].", nErrorCode);
            log_to_file(QS_LOG_FILE_NAME, "Error Description [ %s ].", !QS_EmptyString(szError) ? szError : "N/ A");
            log_to_file(QS_LOG_FILE_NAME, "Fail State [ %s ].", nFailState < TQUERY_QUERY_FAILED ? "SQL SERVER CONNECTION ERROR" : "SQL DATABASE QUERY ERROR");
            log_to_file(QS_LOG_FILE_NAME, "Function [ QS_PickThreadedQueryHandler ]. This Error Can Be Ignored If It Happens Rarely.");
        }

        nUserId = str_to_num(szCustomUserData);
        {
            if (QS_ValidUserId(nUserId))
            {
                nPlayer = QS_PlayerIdByPlayerUserId(nUserId);
                {
                    if (QS_IsPlayer(nPlayer))
                    {
                        ///
                        /// RETRY THE ACTION
                        ///
                        num_to_str((nSysTime = get_systime(0)), szParam, charsmax(szParam));
                        {
                            set_task(QS_CONNECTION_DELAY, "QS_RetryPick", nUserId + nSysTime, szParam, charsmax(szParam), "", 0);
                        }
                    }
                }
            }
        }
    }

    return PLUGIN_CONTINUE;
}

///
/// CREATE TABLE INTO THE DATABASE
///
public QS_CreateThreadedQueryHandler(nFailState, Handle: pQuery, szError[], nErrorCode, szCustomUserData[], nCustomUserDataSize /** != LENGTH */, Float: fQueueTimeSeconds)
{
    ///
    /// DATA
    ///
    static nFails = 0, Float: fGameTime = 0.000000, Float: fErrorStamp = 0.000000;

    ///
    /// EXCEPTION
    ///
    if (!g_bSql || Empty_Handle == g_pSqlDb)
    {
        return PLUGIN_CONTINUE;
    }

    ///
    /// SUCCESS
    ///
    if (!nFailState && QS_EmptyString(szError) && !nErrorCode)
    {
        ///
        /// DATABASE TABLE SUCCESSFULLY CREATED
        ///
        if (pQuery != Empty_Handle)
        {
            ///
            /// ?
            ///
        }

        ///
        /// ERROR
        ///
        else
        {
            fGameTime = get_gametime();

            if ((0.000000 == fErrorStamp) || ((fGameTime - fErrorStamp) > 120.000000))
            {
                fErrorStamp = fGameTime;

                log_to_file(QS_LOG_FILE_NAME, "****************************************************************************************************************");
                log_to_file(QS_LOG_FILE_NAME, "Sql Threaded Query Failed [ SQL_ThreadQuery ].");
                log_to_file(QS_LOG_FILE_NAME, "Error Code [ %d ].", nErrorCode);
                log_to_file(QS_LOG_FILE_NAME, "Error Description [ %s ].", !QS_EmptyString(szError) ? szError : "N/ A");
                log_to_file(QS_LOG_FILE_NAME, "Fail State [ %s ].", nFailState < TQUERY_QUERY_FAILED ? "SQL SERVER CONNECTION ERROR" : "SQL DATABASE QUERY ERROR");
                log_to_file(QS_LOG_FILE_NAME, "Parameter [ %s ].", !QS_EmptyString(szCustomUserData) ? szCustomUserData : "N/ A");
                log_to_file(QS_LOG_FILE_NAME, "Function [ QS_CreateThreadedQueryHandler ]. This Error Can Be Ignored If It Happens Rarely.");
            }

            ///
            /// TRIED TO CREATE AT LEAST ONE SQL TABLE BUT FAILED
            ///
            if (g_nSqlTablesToCreate == ++nFails)
            {
                log_to_file(QS_LOG_FILE_NAME, "****************************************************************************************************************");
                log_to_file(QS_LOG_FILE_NAME, "Failed To Create At Least One Sql Table. The Sql Storage Is Disabled For Now.");

                set_task(0.100000, "QS_DisableSql", get_systime(0), "", 0, "", 0);
            }
        }
    }

    ///
    /// ERROR
    ///
    else
    {
        fGameTime = get_gametime();

        if ((0.000000 == fErrorStamp) || ((fGameTime - fErrorStamp) > 120.000000))
        {
            fErrorStamp = fGameTime;

            log_to_file(QS_LOG_FILE_NAME, "****************************************************************************************************************");
            log_to_file(QS_LOG_FILE_NAME, "Sql Threaded Query Failed [ SQL_ThreadQuery ].");
            log_to_file(QS_LOG_FILE_NAME, "Error Code [ %d ].", nErrorCode);
            log_to_file(QS_LOG_FILE_NAME, "Error Description [ %s ].", !QS_EmptyString(szError) ? szError : "N/ A");
            log_to_file(QS_LOG_FILE_NAME, "Fail State [ %s ].", nFailState < TQUERY_QUERY_FAILED ? "SQL SERVER CONNECTION ERROR" : "SQL DATABASE QUERY ERROR");
            log_to_file(QS_LOG_FILE_NAME, "Parameter [ %s ].", !QS_EmptyString(szCustomUserData) ? szCustomUserData : "N/ A");
            log_to_file(QS_LOG_FILE_NAME, "Function [ QS_CreateThreadedQueryHandler ]. This Error Can Be Ignored If It Happens Rarely.");
        }

        ///
        /// TRIED TO CREATE AT LEAST ONE SQL TABLE BUT FAILED
        ///
        if (g_nSqlTablesToCreate == ++nFails)
        {
            log_to_file(QS_LOG_FILE_NAME, "****************************************************************************************************************");
            log_to_file(QS_LOG_FILE_NAME, "Failed To Create At Least One Sql Table. The Sql Storage Is Disabled For Now.");

            set_task(0.100000, "QS_DisableSql", get_systime(0), "", 0, "", 0);
        }
    }

    return PLUGIN_CONTINUE;
}

///
/// DISABLE THE SQL CONNECTION
///
public QS_DisableSql(nTaskId)
{
    if (g_bSql)
    {
        if (Empty_Handle != g_pSqlDb)
        {
            SQL_FreeHandle(g_pSqlDb);
            {
                g_pSqlDb = Empty_Handle;
            }
        }

        g_bSql = false;
    }

    return PLUGIN_CONTINUE;
}

///
/// RETRY PICKING THE STEAM ID '/SOUNDS' SETTING AFTER A DATABASE ERROR
///
public QS_RetryPick(szParam[], nTaskId)
{
    static nPlayer = QS_INVALID_PLAYER, nUserId = QS_INVALID_USER_ID, szQuery[128] = { EOS, ... }, szUserId[16] = { EOS, ... };

    ///
    /// EXCEPTION
    ///
    if (!g_bSql || Empty_Handle == g_pSqlDb)
    {
        return PLUGIN_CONTINUE;
    }

    ///
    /// ESTABLISH THE USER ID
    ///
    nUserId = (nTaskId - str_to_num(szParam));

    ///
    /// INVALID USER ID
    ///
    if (!QS_ValidUserId(nUserId))
    {
        return PLUGIN_CONTINUE;
    }

    ///
    /// PLAYER ENTITY INDEX BY PLAYER USER ID
    ///
    nPlayer = QS_PlayerIdByPlayerUserId(nUserId);

    ///
    /// INVALID PLAYER
    ///
    if (!QS_IsPlayer(nPlayer))
    {
        return PLUGIN_CONTINUE;
    }

    ///
    /// ONLY IF IN GAME
    ///
    if (g_pbInGame[nPlayer])
    {
        if (!g_bSqlFullSteam)
        {
            formatex(szQuery, charsmax(szQuery), "SELECT aqs_option FROM aqs_enabled_fast WHERE aqs_steam = '%s' LIMIT 1;", g_pszSteam[nPlayer]);
        }

        else
        {
            formatex(szQuery, charsmax(szQuery), "SELECT aqs_option FROM aqs_enabled_full WHERE aqs_steam = '%s' LIMIT 1;", g_pszSteam[nPlayer]);
        }

        num_to_str(nUserId, szUserId, charsmax(szUserId));
        {
            SQL_ThreadQuery(g_pSqlDb, "QS_PickThreadedQueryHandler", szQuery, szUserId, charsmax(szUserId));
        }
    }

    return PLUGIN_CONTINUE;
}

///
/// RETRY SAVING THE STEAM ID '/SOUNDS' SETTING AFTER A DATABASE ERROR
///
public QS_RetryStore(szParam[], nTaskId)
{
    static nPlayer = QS_INVALID_PLAYER, nUserId = QS_INVALID_USER_ID, szQuery[128] = { EOS, ... }, szUserId[16] = { EOS, ... };

    ///
    /// EXCEPTION
    ///
    if (!g_bSql || Empty_Handle == g_pSqlDb)
    {
        return PLUGIN_CONTINUE;
    }

    ///
    /// ESTABLISH THE USER ID
    ///
    nUserId = (nTaskId - str_to_num(szParam));

    ///
    /// INVALID USER ID
    ///
    if (!QS_ValidUserId(nUserId))
    {
        return PLUGIN_CONTINUE;
    }

    ///
    /// PLAYER ENTITY INDEX BY PLAYER USER ID
    ///
    nPlayer = QS_PlayerIdByPlayerUserId(nUserId);

    ///
    /// INVALID PLAYER
    ///
    if (!QS_IsPlayer(nPlayer))
    {
        return PLUGIN_CONTINUE;
    }

    ///
    /// ONLY IF IN GAME
    ///
    if (g_pbInGame[nPlayer])
    {
        if (g_bSqlLocal)
        {
            if (!g_bSqlFullSteam)
            {
                formatex(szQuery, charsmax(szQuery), "UPDATE aqs_enabled_fast SET aqs_option = %d WHERE aqs_steam = '%s';", g_pbDisabled[nPlayer] ? 0 : 1, g_pszSteam[nPlayer]);
            }

            else
            {
                formatex(szQuery, charsmax(szQuery), "UPDATE aqs_enabled_full SET aqs_option = %d WHERE aqs_steam = '%s';", g_pbDisabled[nPlayer] ? 0 : 1, g_pszSteam[nPlayer]);
            }
        }

        else
        {
            if (!g_bSqlFullSteam)
            {
                formatex(szQuery, charsmax(szQuery), "UPDATE aqs_enabled_fast SET aqs_option = %d WHERE aqs_steam = '%s' LIMIT 1;", g_pbDisabled[nPlayer] ? 0 : 1, g_pszSteam[nPlayer]);
            }

            else
            {
                formatex(szQuery, charsmax(szQuery), "UPDATE aqs_enabled_full SET aqs_option = %d WHERE aqs_steam = '%s' LIMIT 1;", g_pbDisabled[nPlayer] ? 0 : 1, g_pszSteam[nPlayer]);
            }
        }

        num_to_str(nUserId, szUserId, charsmax(szUserId));
        {
            SQL_ThreadQuery(g_pSqlDb, "QS_StoreThreadedQueryHandler", szQuery, szUserId, charsmax(szUserId));
        }
    }

    return PLUGIN_CONTINUE;
}

///
/// WHEN A PLAYER DIES ( GAMES WITH "DeathMsg" ONLY )
///
/// THIS IS EXECUTED AFTER THE XSTATS MODULE'S "client_death ( )" FORWARD
///
public QS_ProcessDeathMsg(pnInfo[], nTaskId)
{
    ///
    /// DECLARES THE HIT PLACE ID AND THE WEAPON ID
    ///
    static nPlace = QS_INVALID_PLACE, nWeapon = QS_INVALID_WEAPON, nKiller = QS_INVALID_PLAYER, nVictim = QS_INVALID_PLAYER, Float: fGameTime = 0.000000,
        bool: bReExec = false, nOrigWeapon = QS_INVALID_WEAPON, nOrigPlace = QS_INVALID_PLACE, nOrigTeamKill = QS_TEAM_KILL_NO;

    ///
    /// THE LAST MAN STANDING PREPARATION
    ///
    if (g_bTLMStanding)
    {
        if (g_bDeathMsgOnly) /// IF NO XSTATS MODULE "client_death ( )" FORWARD AVAILABLE
        {
            set_task(QS_STANDING_TRIGGER_DELAY, "QS_PrepareManStanding", get_systime(0), "", 0, "", 0);
        } /** XSTATS MODULE'S "client_death ( )" FORWARD SETS THIS TASK OTHERWISE */
    }

    ///
    /// PLAYER INFO
    ///
    nKiller = pnInfo[0];
    nVictim = pnInfo[1];

    ///
    /// SANITY CHECK
    ///
    if (!QS_IsPlayer(nVictim) || !g_pbInGame[nVictim] || !QS_IsPlayerOrWorld(nKiller))
    {
        return PLUGIN_CONTINUE;
    }

    ///
    /// ORIGINAL DEATH INFO FROM THE "DeathMsg" EXECUTION
    ///
    nOrigWeapon = pnInfo[2];
    nOrigPlace = pnInfo[3];
    nOrigTeamKill = pnInfo[4];

    ///
    /// SETS THE DECLARED VARIABLES TO ZERO IN ORDER TO PROPERLY UPDATE THEM AGAIN
    ///
    nPlace = QS_INVALID_PLACE;
    nWeapon = QS_INVALID_WEAPON;

    ///
    /// PREPARES THE ACTUAL WEAPON ID AND THE ACTUAL HIT PLACE ID
    ///
    get_user_attacker(nVictim, nWeapon, nPlace);

    ///
    /// GAME TIME
    ///
    fGameTime = get_gametime();

    ///
    /// LET'S SAY XSTATS MODULE'S "client_death ( )" FORWARD PROPERLY EXECUTED
    ///
    bReExec = false;

    ///
    /// XSTATS MODULE "client_death ( )" FORWARD EXECUTED
    ///
    if (g_pfXStatsTimeStamp[nVictim] > 0.000000)
    {
        ///
        /// XSTATS "client_death ( )" EXECUTED TOO LONG AGO YES ( > ) OR NO ( <= )
        ///
        if ((fGameTime - g_pfXStatsTimeStamp[nVictim]) > 0.250000)
        {
            /** EXECUTED TOO LONG AGO */
            g_pnWeapon[nVictim] = QS_INVALID_WEAPON;
            g_pnPlace[nVictim] = QS_INVALID_PLACE;
            g_pnTeamKill[nVictim] = QS_TEAM_KILL_NO;
            {
                bReExec = true; /// XSTATS "client_death ( )" FAILED
            }
        } /** OTHERWISE, "client_death ( )" PROPERLY EXECUTED SO VARIABLES LIKE g_pnWeapon[nVictim] ARE UP TO DATE & SET UP */
    }

    ///
    /// XSTATS "client_death ( )" DID NOT EXECUTE
    ///
    else
    {
        g_pnWeapon[nVictim] = QS_INVALID_WEAPON;
        g_pnPlace[nVictim] = QS_INVALID_PLACE;
        g_pnTeamKill[nVictim] = QS_TEAM_KILL_NO;
        {
            bReExec = true; /// XSTATS "client_death ( )" FAILED
        }
    }

    ///
    /// POSSIBLE WEAPON ID FIX
    ///
    if (g_bDeathMsgOnly || bReExec || !QS_ValidWeapon(g_pnWeapon[nVictim]))
    {
        if (!QS_ValidWeapon(nOrigWeapon))
        {
            if (!QS_ValidWeapon(nWeapon))
            {
                if (g_pbInGame[nKiller])
                {
                    nWeapon = get_user_weapon(nKiller);
                    {
                        if (QS_ValidWeapon(nWeapon))
                        {
                            g_pnWeapon[nVictim] = nWeapon;
                        }

                        else
                        {
                            g_pnWeapon[nVictim] = QS_INVALID_WEAPON;
                        }
                    }
                }

                else
                {
                    g_pnWeapon[nVictim] = QS_INVALID_WEAPON;
                }
            }

            else
            {
                g_pnWeapon[nVictim] = nWeapon;
            }
        }

        else
        {
            g_pnWeapon[nVictim] = nOrigWeapon;
        }
    }

    ///
    /// POSSIBLE HIT PLACE ID FIX
    ///
    if (g_bDeathMsgOnly || bReExec || !QS_ValidPlace(g_pnPlace[nVictim]))
    {
        if (!QS_ValidPlace(nOrigPlace))
        {
            if (QS_ValidPlace(nPlace))
            {
                g_pnPlace[nVictim] = nPlace;
            }

            else
            {
                g_pnPlace[nVictim] = QS_INVALID_PLACE;
            }
        }

        else
        {
            g_pnPlace[nVictim] = nOrigPlace;
        }
    }

    ///
    /// PREPARES THE TEAM KILL BOOLEAN IF NEEDED
    ///
    if (g_bDeathMsgOnly || bReExec) /// OTHERWISE, THIS ( g_pnTeamKill[nVictim] ) IS PREPARED WITHIN THE XSTATS MODULE'S "client_death ( )" FORWARD
    {
        g_pnTeamKill[nVictim] = nOrigTeamKill;
    }

    ///
    /// PROCESSES DEATH
    ///
    QS_ProcessPlayerDeath(nKiller, nVictim, g_pnWeapon[nVictim], g_pnPlace[nVictim], g_pnTeamKill[nVictim]);

    return PLUGIN_CONTINUE;
}

///
/// WHEN A PLAYER DIES ( CUSTOM TASK )
///
/// FOR GAMES WITHOUT THE XSTATS MODULE [ client_death ( ) ] FORWARD AND WITHOUT "DeathMsg"
///
/// TASK SET BY A HAM SANDWITCH FORWARD ( Ham_Killed )
///
public QS_ProcessDeathHook(pnInfo[], nTaskId)
{
    ///
    /// DECLARES THE HIT PLACE, THE WEAPON ID & THE TEAM KILL BOOLEAN
    ///
    static nPlace = QS_INVALID_PLACE, nWeapon = QS_INVALID_WEAPON, nKiller = QS_INVALID_PLAYER, nVictim = QS_INVALID_PLAYER,
        nOrigPlace = QS_INVALID_PLACE, nOrigWeapon = QS_INVALID_WEAPON, nOrigTeamKill = QS_TEAM_KILL_NO;

    ///
    /// PLAYER INFO
    ///
    nKiller = pnInfo[0];
    nVictim = pnInfo[1];

    ///
    /// SANITY CHECK
    ///
    if (!g_pbInGame[nVictim] || !g_pbInGame[nKiller])
    {
        return PLUGIN_CONTINUE;
    }

    ///
    /// ORIGINAL DEATH INFO
    ///
    nOrigWeapon = pnInfo[2];
    nOrigPlace = pnInfo[3];
    nOrigTeamKill = pnInfo[4];

    ///
    /// PREPARES THE ACTUAL WEAPON ID AND THE ACTUAL HIT PLACE ID
    ///
    get_user_attacker(nVictim, nWeapon, nPlace);

    ///
    /// POSSIBLE WEAPON ID FIX
    ///
    if (!QS_ValidWeapon(nOrigWeapon))
    {
        if (!QS_ValidWeapon(nWeapon))
        {
            nWeapon = get_user_weapon(nKiller);
            {
                if (QS_ValidWeapon(nWeapon))
                {
                    nOrigWeapon = nWeapon;
                }

                else
                {
                    nOrigWeapon = QS_INVALID_WEAPON;
                }
            }
        }

        else
        {
            nOrigWeapon = nWeapon;
        }
    }

    ///
    /// POSSIBLE HIT PLACE ID FIX
    ///
    if (!QS_ValidPlace(nOrigPlace))
    {
        if (QS_ValidPlace(nPlace))
        {
            nOrigPlace = nPlace;
        }

        else
        {
            nOrigPlace = QS_INVALID_PLACE;
        }
    }

    ///
    /// PROCESSES DEATH
    ///
    QS_ProcessPlayerDeath(nKiller, nVictim, nOrigWeapon, nOrigPlace, nOrigTeamKill);

    return PLUGIN_CONTINUE;
}

/*************************************************************************************
******* FUNCTIONS ********************************************************************
*************************************************************************************/

///
/// PROCESSES THE CLIENT DEATH STUFF FOR ALL MODS
///
static bool: QS_ProcessPlayerDeath(nKiller, &nVictim, &nWeapon, &nPlace, &nTeamKill)
{
    ///
    /// VARIABLES
    ///
    static nIter = 0, Float: fGameTime = 0.000000, szWeapon[QS_WORD_MAX_LEN] = { EOS, ... }, szSnd[QS_SND_MAX_LEN] = { EOS, ... }, szMsg[QS_HUD_MSG_MAX_LEN] = { EOS, ... },
        bool: bExecutedTeamKill = false, bool: bDiedByWorldDmg = false /** OR BY THE 'KILL' COMMAND */, pnColor[4] = { QS_MIN_BYTE, ... }, szWord[QS_WORD_MAX_LEN] = { EOS, ... };

    ///
    /// RESETS THE SUICIDE TYPE STAMP [ WORLD DAMAGE/ 'KILL' COMMAND ]
    ///
    bDiedByWorldDmg = false;

    ///
    /// RESETS THE TEAM KILL STAMP
    ///
    bExecutedTeamKill = false;

    ///
    /// RESETS THE KILLS FOR VICTIM
    ///
    if (g_bKStreak)
    {
        g_pnKills[nVictim] = 0;
    }

    ///
    /// INVALID KILLER ( WORLD, DISCONNECTED MOMENTS AGO, ... )
    ///
    if (!g_pbInGame[nKiller]) /** THE KILLER IS ALWAYS IN GAME WHEN THE QS_ProcessPlayerDeath ( ) IS TRIGGERED BY THE QS_HAM_On_Player_Killed ( ) */
    {
        if (!QS_IsPlayer(nKiller)) /** WORLDSPAWN */
        {
            nKiller = nVictim; /** SELF SUICIDE BY WORLD DAMAGE */
            {
                bDiedByWorldDmg = true; /** NOT BY THE KILL COMMAND */
            }
        }

        ///
        /// THE KILLER WAS A VALID PLAYER WHICH JUST LEFT THE GAME SERVER
        ///
        else
        {
            ///
            /// KILLS THIS ROUND ++
            ///
            if (g_bFlawless || g_bHattrick)
            {
                g_nKillsThisRound++;
            }

            ///
            /// FIRST BLOOD
            ///
            if (g_bFBlood && ++g_nFBlood == 1)
            {
                if (g_bFBloodMsgNoKiller)
                {
                    ///
                    /// PREPARES THE FIRST BLOOD HUD MESSAGE COLOR
                    ///
                    QS_HudMsgColor();

                    ///
                    /// PREPARES THE FIRST BLOOD HUD MESSAGE RGBA ARRAY
                    ///
                    QS_MakeRGBA(pnColor);

                    ///
                    /// PREPARES THE FIRST BLOOD HUD MESSAGE @ QS_EVENT_Y_POS
                    ///
                    QS_SetHudMsg(g_nRed, g_nGreen, g_nBlue, QS_HUD_MSG_X_POS, g_bDOD ? QS_EVENT_Y_POS_DOD : QS_EVENT_Y_POS, QS_HUD_MSG_EFFECTS, QS_HUD_MSG_EFFECTS_TIME, QS_HUD_MSG_HOLD_TIME, QS_HUD_MSG_FADE_IN_TIME, QS_HUD_MSG_FADE_OUT_TIME, -1, QS_HUD_MSG_ALPHA_AMOUNT, pnColor);

                    ///
                    /// SHOWS THE FIRST BLOOD HUD MESSAGE
                    ///
                    QS_ShowHudMsg(QS_EVERYONE, g_pnHudMsgObj[QS_HUD_EVENT], g_szFBloodMsgNoKiller, g_pszName[nVictim]);
                }

                QS_ClientCmd(QS_EVERYONE, "SPK \"%a\"", ArrayGetStringHandle(g_pFBlood, random_num(0, g_nFBloodSize - 1)));
            }

            ///
            /// THE KILLER WAS A VALID PLAYER WHICH JUST LEFT THE GAME SERVER
            ///
            return true;
        }
    }

    ///
    /// PREPARES THE HUD MESSAGE COLOR
    ///
    QS_HudMsgColor();

    ///
    /// PREPARES THE RGBA ARRAY
    ///
    QS_MakeRGBA(pnColor);

    ///
    /// PREPARES THE HUD MESSAGE @ QS_EVENT_Y_POS
    ///
    QS_SetHudMsg(g_nRed, g_nGreen, g_nBlue, QS_HUD_MSG_X_POS, g_bDOD ? QS_EVENT_Y_POS_DOD : QS_EVENT_Y_POS, QS_HUD_MSG_EFFECTS, QS_HUD_MSG_EFFECTS_TIME, QS_HUD_MSG_HOLD_TIME, QS_HUD_MSG_FADE_IN_TIME, QS_HUD_MSG_FADE_OUT_TIME, -1, QS_HUD_MSG_ALPHA_AMOUNT, pnColor);

    ///
    /// SUICIDE
    ///
    if (nVictim == nKiller)
    {
        ///
        /// SUICIDE EVENT
        ///
        if (g_bSuicide)
        {
            if (g_bSuicideMsg)
            {
                QS_ShowHudMsg(QS_EVERYONE, g_pnHudMsgObj[QS_HUD_EVENT], g_szSuicideMsg, g_pszName[nVictim]);
            }

            QS_ClientCmd(QS_EVERYONE, "SPK \"%a\"", ArrayGetStringHandle(g_pSuicide, random_num(0, g_nSuicideSize - 1)));
        }

        ///
        /// FIRST BLOOD
        ///
        if (g_bFBlood)
        {
            switch (bDiedByWorldDmg)
            {
                case true:
                {
                    if (g_bFBloodAllowWorldDmg && ++g_nFBlood == 1)
                    {
                        if (g_bFBloodMsgNoKiller)
                        {
                            QS_ShowHudMsg(QS_EVERYONE, g_pnHudMsgObj[QS_HUD_EVENT], g_szFBloodMsgNoKiller, g_pszName[nVictim]);
                        }

                        QS_ClientCmd(QS_EVERYONE, "SPK \"%a\"", ArrayGetStringHandle(g_pFBlood, random_num(0, g_nFBloodSize - 1)));
                    }
                }

                default:
                {
                    if (g_bFBloodAllowKillCmd && ++g_nFBlood == 1)
                    {
                        if (g_bFBloodMsgNoKiller)
                        {
                            QS_ShowHudMsg(QS_EVERYONE, g_pnHudMsgObj[QS_HUD_EVENT], g_szFBloodMsgNoKiller, g_pszName[nVictim]);
                        }

                        QS_ClientCmd(QS_EVERYONE, "SPK \"%a\"", ArrayGetStringHandle(g_pFBlood, random_num(0, g_nFBloodSize - 1)));
                    }
                }
            }
        }

        ///
        /// KILLS THIS ROUND ++
        ///
        if (g_bFlawless || g_bHattrick)
        {
            g_nKillsThisRound++;
        }

        if (g_bHattrick)
        {
            if (!bDiedByWorldDmg)
            {
                if (g_bHattrickDecrease)
                {
                    g_pnKillsThisRound[nVictim]--;
                }
            }
        }
    } /** SUICIDE */

    ///
    /// NORMAL DEATH
    ///
    else
    {
        ///
        /// KILLS ++
        ///
        if (g_bKStreak)
        {
            g_pnKills[nKiller]++;
        }

        if (g_bHattrick)
        {
            g_pnKillsThisRound[nKiller]++;
        }

        ///
        /// KILLS THIS ROUND ++
        ///
        if (g_bFlawless || g_bHattrick)
        {
            g_nKillsThisRound++;
        }

        ///
        /// EXECUTED TEAM KILL YES/ NO
        ///
        bExecutedTeamKill = QS_IsTeamKill(nTeamKill);

        ///
        /// REVENGE KILLER STAMP
        ///
        if (g_bRevenge && (!bExecutedTeamKill || g_bRevengeIfTeamKill))
        {
            g_pszRevengeStamp[nVictim] = g_pszName[nKiller];
            {
                g_pnRevengeStamp[nVictim] = g_pnUserId[nKiller];
            }
        }

        ///
        /// WEAPON NAME
        ///
        if (QS_ValidWeapon(nWeapon))
        {
            get_weaponname(nWeapon, szWeapon, charsmax(szWeapon));
        }

        ///
        /// NO WEAPON
        ///
        else
        {
            QS_ClearString(szWeapon);
        }

        if (g_bRevenge && (!bExecutedTeamKill || g_bRevengeIfTeamKill) && g_pnUserId[nVictim] == g_pnRevengeStamp[nKiller] && equali(g_pszName[nVictim], g_pszRevengeStamp[nKiller]))
        {
            ///
            /// CLEARS THE REVENGE STAMP
            ///
            g_pnRevengeStamp[nKiller] = QS_INVALID_USER_ID;
            {
                QS_ClearString(g_pszRevengeStamp[nKiller]);
            }

            ///
            /// PREPARES THE REVENGE HUD MESSAGE COLOR
            ///
            QS_HudMsgColor();

            ///
            /// PREPARES THE REVENGE HUD MESSAGE RGBA ARRAY
            ///
            QS_MakeRGBA(pnColor);

            ///
            /// PREPARES THE REVENGE ( QS_HUD_REVENGE ) HUD MESSAGE @ QS_REVENGE_Y_POS
            ///
            QS_SetHudMsg(g_nRed, g_nGreen, g_nBlue, QS_HUD_MSG_X_POS, g_bDOD ? QS_REVENGE_Y_POS_DOD : QS_REVENGE_Y_POS, QS_HUD_MSG_EFFECTS, QS_HUD_MSG_EFFECTS_TIME, QS_HUD_MSG_HOLD_TIME, QS_HUD_MSG_FADE_IN_TIME, QS_HUD_MSG_FADE_OUT_TIME, -1, QS_HUD_MSG_ALPHA_AMOUNT, pnColor);

            if (g_bRevengeMsgKiller)
            {
                QS_ShowHudMsg(nKiller, g_pnHudMsgObj[QS_HUD_REVENGE], g_szRevengeMsgKiller, g_pszName[nVictim]);
            }

            if (g_bRevengeMsgVictim && !g_bRevengeOnlyKiller)
            {
                QS_ShowHudMsg(nVictim, g_pnHudMsgObj[QS_HUD_REVENGE], g_szRevengeMsgVictim, g_pszName[nKiller]);
            }

            QS_ClientCmd(nKiller, "SPK \"%a\"", ArrayGetStringHandle(g_pRevenge, random_num(0, g_nRevengeSize - 1)));

            if (!g_bRevengeOnlyKiller)
            {
                QS_ClientCmd(nVictim, "SPK \"%a\"", ArrayGetStringHandle(g_pRevenge, random_num(0, g_nRevengeSize - 1)));
            }

            ///
            /// PREPARES THE HUD MESSAGE COLOR
            ///
            QS_HudMsgColor();

            ///
            /// PREPARES THE RGBA ARRAY
            ///
            QS_MakeRGBA(pnColor);

            ///
            /// PREPARES THE MINOR EVENTS ( QS_HUD_EVENT ) HUD MESSAGE @ QS_EVENT_Y_POS
            ///
            QS_SetHudMsg(g_nRed, g_nGreen, g_nBlue, QS_HUD_MSG_X_POS, g_bDOD ? QS_EVENT_Y_POS_DOD : QS_EVENT_Y_POS, QS_HUD_MSG_EFFECTS, QS_HUD_MSG_EFFECTS_TIME, QS_HUD_MSG_HOLD_TIME, QS_HUD_MSG_FADE_IN_TIME, QS_HUD_MSG_FADE_OUT_TIME, -1, QS_HUD_MSG_ALPHA_AMOUNT, pnColor);
        }

        if (g_bHShot && (!bExecutedTeamKill || g_bHShotIfTeamKill) && nPlace == HIT_HEAD)
        {
            if (g_bHShotMsg)
            {
                QS_ShowHudMsg(QS_EVERYONE, g_pnHudMsgObj[QS_HUD_EVENT], g_szHShotMsg, g_pszName[nKiller], g_pszName[nVictim]);
            }

            QS_ClientCmd(g_bHShotOnlyKiller ? nKiller : QS_EVERYONE, "SPK \"%a\"", ArrayGetStringHandle(g_pHShot, random_num(0, g_nHShotSize - 1)));
        }

        if (g_bFBlood && (!bExecutedTeamKill || g_bFBloodAllowTeamKill) && ++g_nFBlood == 1)
        {
            if (g_bFBloodMsg)
            {
                QS_ShowHudMsg(QS_EVERYONE, g_pnHudMsgObj[QS_HUD_EVENT], g_szFBloodMsg, g_pszName[nKiller]);
            }

            QS_ClientCmd(QS_EVERYONE, "SPK \"%a\"", ArrayGetStringHandle(g_pFBlood, random_num(0, g_nFBloodSize - 1)));
        }

        if (bExecutedTeamKill)
        {
            if (g_bTKill)
            {
                if (g_bTKillMsg)
                {
                    QS_ShowHudMsg(QS_EVERYONE, g_pnHudMsgObj[QS_HUD_EVENT], g_szTKillMsg, g_pszName[nKiller]);
                }

                QS_ClientCmd(QS_EVERYONE, "SPK \"%a\"", ArrayGetStringHandle(g_pTKill, random_num(0, g_nTKillSize - 1)));
            }

            if (g_bHattrick)
            {
                if (g_bHattrickIgnoreTeamKillFrag)
                {
                    g_pnKillsThisRound[nKiller]--;
                }
            }
        }

        if (g_bGrenade && (!bExecutedTeamKill || g_bGrenadeIfTeamKill) && g_nGrenadeNames > 0)
        {
            for (nIter = 0; nIter < g_nGrenadeNames; nIter++)
            {
                if (ArrayGetString(g_pGrenadeNames, nIter, szWord, charsmax(szWord)) > 0 || !QS_EmptyString(szWord))
                {
                    if (containi(szWeapon, szWord) > -1)
                    {
                        if (g_bGrenadeMsg)
                        {
                            QS_ShowHudMsg(QS_EVERYONE, g_pnHudMsgObj[QS_HUD_EVENT], g_szGrenadeMsg, g_pszName[nKiller], g_pszName[nVictim]);
                        }

                        QS_ClientCmd(QS_EVERYONE, "SPK \"%a\"", ArrayGetStringHandle(g_pGrenade, random_num(0, g_nGrenadeSize - 1)));

                        break;
                    }
                }
            }
        }

        if (g_bKnife && (!bExecutedTeamKill || g_bKnifeIfTeamKill) && g_nKnifeNames > 0)
        {
            for (nIter = 0; nIter < g_nKnifeNames; nIter++)
            {
                if (ArrayGetString(g_pKnifeNames, nIter, szWord, charsmax(szWord)) > 0 || !QS_EmptyString(szWord))
                {
                    if (containi(szWeapon, szWord) > -1)
                    {
                        if (g_bKnifeMsg)
                        {
                            QS_ShowHudMsg(QS_EVERYONE, g_pnHudMsgObj[QS_HUD_EVENT], g_szKnifeMsg, g_pszName[nKiller], g_pszName[nVictim]);
                        }

                        QS_ClientCmd(QS_EVERYONE, "SPK \"%a\"", ArrayGetStringHandle(g_pKnife, random_num(0, g_nKnifeSize - 1)));

                        break;
                    }
                }
            }
        }

        if (g_bDKill)
        {
            if (!bExecutedTeamKill || g_bDKillOnTeamKill)
            {
                ///
                /// GAME TIME
                ///
                fGameTime = get_gametime();

                if (g_pfLastKillTimeStamp[nKiller] > fGameTime)
                {
                    if (g_bDKillMsg)
                    {
                        QS_ShowHudMsg(QS_EVERYONE, g_pnHudMsgObj[QS_HUD_EVENT], g_szDKillMsg, g_pszName[nKiller]);
                    }

                    QS_ClientCmd(QS_EVERYONE, "SPK \"%a\"", ArrayGetStringHandle(g_pDKill, random_num(0, g_nDKillSize - 1)));
                }

                g_pfLastKillTimeStamp[nKiller] = fGameTime + QS_DOUBLE_KILL_DELAY;
            }
        }

        if (g_bKStreak)
        {
            if (bExecutedTeamKill && g_bKStreakIgnoreOnTeamKill)
            {
                g_pnKills[nKiller]--;
                {
                    return true;
                }
            }

            for (nIter = 0; nIter < g_nKStreakSize; nIter++)
            {
                if (g_pnKills[nKiller] == ArrayGetCell(g_pKStreakReqKills, nIter))
                {
                    ArrayGetString(g_pKStreakMsgs, nIter, szMsg, charsmax(szMsg));
                    ArrayGetString(g_pKStreakSnds, nIter, szSnd, charsmax(szSnd));

                    QS_DisplayKStreak(nKiller, szMsg, szSnd);

                    return true;
                }
            }
        }
    } /** NORMAL DEATH */

    return true;
}

///
/// LOADS THE CONFIGURATION FILE
///
static bool: QS_LoadSettings()
{
    ///
    /// PREPARES THE CONFIGURATION FILES DIRECTORY
    ///
    new szFile[QS_SND_MAX_LEN] = { EOS, ... };

    ///
    /// READS THE CONFIGURATION FILES DIRECTORY
    ///
    new nLen = get_configsdir(szFile, charsmax(szFile));

    ///
    /// ADDS "/" AT THE END OF THE PATH IF NEEDED
    ///
    if (!QS_EmptyString(szFile))
    {
        new nEndPos = nLen - 1;

        if (szFile[nEndPos] != '/' && szFile[nEndPos] != '\\')
        {
            add(szFile, charsmax(szFile), "/");
        }
    }

    ///
    /// APPENDS THE CONFIGURATION FILE'S NAME
    ///
    add(szFile, charsmax(szFile), QS_CFG_FILE_NAME);

    ///
    /// OPENS THE FILE
    ///
    new nFile = fopen(szFile, "r");

    ///
    /// NO FILE
    ///
    if (nFile == 0)
    {
        return false;
    }

    ///
    /// PREPARES THE FILE LINES
    ///
    new szLine[2048] = { EOS, ... }, szKey[2048] = { EOS, ... }, szVal[2048] = { EOS, ... }, szType[QS_WORD_MAX_LEN] = { EOS, ... }, szSnd[QS_SND_MAX_LEN] = { EOS, ... },
        szReqKills[QS_WORD_MAX_LEN] = { EOS, ... }, szDummy[QS_WORD_MAX_LEN] = { EOS, ... }, szMsg[QS_HUD_MSG_MAX_LEN] = { EOS, ... }, nVal = 0;

    ///
    /// READS THE FILE
    ///
    while (!feof(nFile))
    {
        ///
        /// PREPARE
        ///
        QS_ClearString(szLine);

        ///
        /// GETS LINE
        ///
        if (fgets(nFile, szLine, charsmax(szLine)) < 1)
        {
            continue;
        }

        ///
        /// TRIMS LINE OFF
        ///
        trim(szLine);

        ///
        /// CHECKS FOR VALIDITY
        ///
        if (QS_EmptyString(szLine) || szLine[0] == ';' || szLine[0] == '#' || (szLine[0] == '/' && szLine[1] == '/'))
        {
            continue;
        }

        ///
        /// PREPARE
        ///
        QS_ClearString(szKey);
        QS_ClearString(szVal);

        ///
        /// SPLITS STRING IN TOKENS
        ///
        if (strtok2(szLine, szKey, charsmax(szKey), szVal, charsmax(szVal), '=', 1) < 0)
        {
            continue;
        }

        ///
        /// TRIMS KEY
        ///
        trim(szKey);

        ///
        /// TRIMS VALUE
        ///
        trim(szVal);

        ///
        /// BASIC SETTINGS
        ///
        if (equali(szKey, "ENABLE/DISABLE PLUGIN") || equali(szKey, "ENABLE/ DISABLE PLUGIN")) /** COMPATIBILITY */
        {
            g_bEnabled = bool: str_to_num(szVal);
        }

        else if (equali(szKey, "ENABLE/DISABLE CHAT") || equali(szKey, "ENABLE/ DISABLE CHAT")) /** COMPATIBILITY */
        {
            g_bChatCmd = bool: str_to_num(szVal);
        }

        else if (equali(szKey, "ENABLE/DISABLE JOIN") || equali(szKey, "ENABLE/ DISABLE JOIN")) /** COMPATIBILITY */
        {
            g_bChatInfo = bool: str_to_num(szVal);
        }

        else if (equali(szKey, "SKIP EXISTING INFO") || equali(szKey, "SKIP EXISTING INFORMATION")) /** COMPATIBILITY */
        {
            g_bSkipExisting = bool: str_to_num(szVal);
        }

        else if (equali(szKey, "HIDE CMD") || equali(szKey, "HIDE COMMAND") || equali(szKey, "HIDE CHAT CMD") || equali(szKey, "HIDE CHAT COMMAND")) /** COMPATIBILITY */
        {
            g_bHideCmd = bool: str_to_num(szVal);
        }

        ///
        /// EVENT SETTINGS
        ///
        else if (equali(szKey, "HEADSHOT ONLY KILLER") || equali(szKey, "HEAD SHOT ONLY KILLER")) /** COMPATIBILITY */
        {
            g_bHShotOnlyKiller = bool: str_to_num(szVal);
        }

        else if (equali(szKey, "HATTRICK TO ALL"))
        {
            g_bHattrickToAll = bool: str_to_num(szVal);
        }

        else if (equali(szKey, "ROUNDSTART DELAY SECONDS") || equali(szKey, "ROUNDSTART SECONDS DELAY")) /** COMPATIBILITY */
        {
            if (QS_DODRunning() /** USE THIS CALL DURING QS_LoadSettings ( ) @ plugin_precache ( ) */)
            {
                g_fRStartDelay = floatmax(floatabs(str_to_float(szVal)), QS_ROUND_START_MIN_DOD_DELAY);
            }

            else
            {
                g_fRStartDelay = floatabs(str_to_float(szVal));
            }
        }

        else if (equali(szKey, "MIN FRAGS FOR HATTRICK") || equali(szKey, "MINIMUM FRAGS FOR HATTRICK")) /** COMPATIBILITY */
        {
            g_nMinKillsForHattrick = clamp(abs(str_to_num(szVal)), 1, QS_INVALID_REQ_KILLS);
        }

        else if (equali(szKey, "DECREASE FRAG IN CASE OF 'KILL' COMMAND SUICIDE"))
        {
            g_bHattrickDecrease = bool: str_to_num(szVal);
        }

        else if (equali(szKey, "REVENGE ONLY FOR KILLER"))
        {
            g_bRevengeOnlyKiller = bool: str_to_num(szVal);
        }

        else if (equali(szKey, "HATTRICK CHAT"))
        {
            g_bHattrickMsgTalk = bool: str_to_num(szVal);
        }

        else if (equali(szKey, "DKILL IF TEAM KILL") || equali(szKey, "DKILL ON TEAM KILL")) /** COMPATIBILITY */
        {
            g_bDKillOnTeamKill = bool: str_to_num(szVal);
        }

        else if (equali(szKey, "REVENGE IF TEAM KILL") || equali(szKey, "REVENGE ON TEAM KILL")) /** COMPATIBILITY */
        {
            g_bRevengeIfTeamKill = bool: str_to_num(szVal);
        }

        else if (equali(szKey, "HEADSHOT IF TEAM KILL") || equali(szKey, "HEADSHOT ON TEAM KILL")) /** COMPATIBILITY */
        {
            g_bHShotIfTeamKill = bool: str_to_num(szVal);
        }

        else if (equali(szKey, "KNIFE IF TEAM KILL") || equali(szKey, "KNIFE ON TEAM KILL")) /** COMPATIBILITY */
        {
            g_bKnifeIfTeamKill = bool: str_to_num(szVal);
        }

        else if (equali(szKey, "NADE IF TEAM KILL") || equali(szKey, "NADE ON TEAM KILL")) /** COMPATIBILITY */
        {
            g_bGrenadeIfTeamKill = bool: str_to_num(szVal);
        }

        else if (equali(szKey, "FIRSTBLOOD IF KILL CMD SUICIDE") || equali(szKey, "FIRSTBLOOD ON KILL CMD SUICIDE")) /** COMPATIBILITY */
        {
            g_bFBloodAllowKillCmd = bool: str_to_num(szVal);
        }

        else if (equali(szKey, "FIRSTBLOOD IF WORLD DMG SUICIDE") || equali(szKey, "FIRSTBLOOD ON WORLD DMG SUICIDE")) /** COMPATIBILITY */
        {
            g_bFBloodAllowWorldDmg = bool: str_to_num(szVal);
        }

        else if (equali(szKey, "FIRSTBLOOD IF TEAM KILL") || equali(szKey, "FIRSTBLOOD ON TEAM KILL")) /** COMPATIBILITY */
        {
            g_bFBloodAllowTeamKill = bool: str_to_num(szVal);
        }

        else if (equali(szKey, "KSTREAK FRAG IGNORED IF TEAM KILL") || equali(szKey, "KSTREAK FRAG IGNORED ON TEAM KILL")) /** COMPATIBILITY */
        {
            g_bKStreakIgnoreOnTeamKill = bool: str_to_num(szVal);
        }

        else if (equali(szKey, "HATTRICK FRAG IGNORED IF TEAM KILL") || equali(szKey, "HATTRICK FRAG IGNORED ON TEAM KILL")) /** COMPATIBILITY */
        {
            g_bHattrickIgnoreTeamKillFrag = bool: str_to_num(szVal);
        }

        ///
        /// SQL SETTINGS
        ///
        else if (equali(szKey, "SQL ON/ OFF") || equali(szKey, "SQL ON/OFF")) /** COMPATIBILITY */
        {
            g_bSql = bool: str_to_num(szVal);
        }

        else if (equali(szKey, "SQL FULL STEAM STORAGE") || equali(szKey, "SQL FULL STEAM ID STORAGE") || equali(szKey, "SQL FULL STEAMID STORAGE")) /** COMPATIBILITY */
        {
            g_bSqlFullSteam = bool: str_to_num(szVal);
        }

        else if (equali(szKey, "SQL USER") || equali(szKey, "SQL USERNAME") || equali(szKey, "SQL USER NAME")) /** COMPATIBILITY */
        {
            copy(g_szSqlUser, charsmax(g_szSqlUser), szVal);
        }

        else if (equali(szKey, "SQL ADDRESS") || equali(szKey, "SQL HOST")) /** COMPATIBILITY */
        {
            copy(g_szSqlAddr, charsmax(g_szSqlAddr), szVal);
        }

        else if (equali(szKey, "SQL PASSWORD") || equali(szKey, "SQL USER PASSWORD")) /** COMPATIBILITY */
        {
            copy(g_szSqlPassword, charsmax(g_szSqlPassword), szVal);
        }

        else if (equali(szKey, "SQL CHARSET") || equali(szKey, "SQL PRIMARY CHARSET") || equali(szKey, "SQL MAIN CHARSET")) /** COMPATIBILITY */
        {
            copy(g_szSqlChars, charsmax(g_szSqlChars), szVal);
        }

        else if (equali(szKey, "SQL SECONDARY CHARSET") || equali(szKey, "SQL SECOND CHARSET")) /** COMPATIBILITY */
        {
            copy(g_szSqlSecChars, charsmax(g_szSqlSecChars), szVal);
        }

        else if (equali(szKey, "SQL DATABASE") || equali(szKey, "SQL DATA BASE") || equali(szKey, "SQL DB")) /** COMPATIBILITY */
        {
            copy(g_szSqlDatabase, charsmax(g_szSqlDatabase), szVal);
        }

        else if (equali(szKey, "SQL EXTENSION") || equali(szKey, "SQL MODULE") || equali(szKey, "SQL DRIVER")) /** COMPATIBILITY */
        {
            copy(g_szSqlExtension, charsmax(g_szSqlExtension), szVal);
            {
                g_bSqlLocal = bool: equali(g_szSqlExtension, "SQLITE");
            }
        }

        else if (equali(szKey, "SQL TIME OUT") || equali(szKey, "SQL TIMEOUT")) /** COMPATIBILITY */
        {
            g_nSqlMaxSecondsError = str_to_num(szVal);
        }

        ///
        /// HUD MESSAGES
        ///
        else if (equali(szKey, "HUDMSG RED"))
        {
            if (equal(szVal, "_"))
            {
                g_bRandomRed = true;
            }

            else
            {
                g_nRed = clamp(abs(str_to_num(szVal)), QS_MIN_BYTE, QS_MAX_BYTE);
            }
        }

        else if (equali(szKey, "HUDMSG GREEN"))
        {
            if (equal(szVal, "_"))
            {
                g_bRandomGreen = true;
            }

            else
            {
                g_nGreen = clamp(abs(str_to_num(szVal)), QS_MIN_BYTE, QS_MAX_BYTE);
            }
        }

        else if (equali(szKey, "HUDMSG BLUE"))
        {
            if (equal(szVal, "_"))
            {
                g_bRandomBlue = true;
            }

            else
            {
                g_nBlue = clamp(abs(str_to_num(szVal)), QS_MIN_BYTE, QS_MAX_BYTE);
            }
        }

        ///
        /// K. STREAK SOUNDS
        ///
        else if (equali(szKey, "SOUND"))
        {
            ///
            /// PREPARE
            ///
            QS_ClearString(szType);
            {
                if (parse(szVal, szDummy, charsmax(szDummy), szType, charsmax(szType)) > 1 || !QS_EmptyString(szType))
                {
                    trim(szType);
                    {
                        if (equali(szType, "REQUIREDKILLS"))
                        {
                            ///
                            /// PREPARE
                            ///
                            QS_ClearString(szReqKills);
                            QS_ClearString(szSnd);

                            parse(szVal, szDummy, charsmax(szDummy), szDummy, charsmax(szDummy), szReqKills, charsmax(szReqKills), szDummy, charsmax(szDummy), szSnd, charsmax(szSnd));
                            {
                                trim(szReqKills);
                                trim(szSnd);
                            }

                            if (!QS_EmptyString(szReqKills) && (nVal = abs(str_to_num(szReqKills))) > 0)
                            {
                                ArrayPushCell(g_pKStreakReqKills, nVal);
                            }

                            else
                            {
                                ArrayPushCell(g_pKStreakReqKills, QS_INVALID_REQ_KILLS);

                                log_to_file(QS_LOG_FILE_NAME, "****************************************************************************************************************");
                                log_to_file(QS_LOG_FILE_NAME, "Bad Required Kills ('REQUIREDKILLS') [ %s ] Inside Line [ %s ].", szReqKills, szLine);
                                log_to_file(QS_LOG_FILE_NAME, "This Sound Will Be Ignored. It Will Be Precached, If Set, So The Players Will Download It.");
                                log_to_file(QS_LOG_FILE_NAME, "It Will Never Play.");
                            }

                            ArrayPushString(g_pKStreakSnds, szSnd);
                        }

                        else if (equali(szType, "MESSAGE"))
                        {
                            ///
                            /// PREPARE
                            ///
                            QS_ClearString(szMsg);
                            {
                                strtok2(szVal, szDummy, charsmax(szDummy), szMsg, charsmax(szMsg), '@', 1);
                                {
                                    trim(szMsg);
                                    {
                                        ArrayPushString(g_pKStreakMsgs, szMsg);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        ///
        /// EVENTS ON/ OFF
        ///
        else if (equali(szKey, "KILLSTREAK EVENT") || equali(szKey, "KILLSSTREAK EVENT")) /** COMPATIBILITY */
        {
            g_bKStreak = bool: str_to_num(szVal);
        }

        else if (equali(szKey, "REVENGE EVENT"))
        {
            g_bRevenge = bool: str_to_num(szVal);
        }

        else if (equali(szKey, "HEADSHOT EVENT"))
        {
            g_bHShot = bool: str_to_num(szVal);
        }

        else if (equali(szKey, "SUICIDE EVENT"))
        {
            g_bSuicide = bool: str_to_num(szVal);
        }

        else if (equali(szKey, "NADE EVENT"))
        {
            g_bGrenade = bool: str_to_num(szVal);
        }

        else if (equali(szKey, "TEAMKILL EVENT"))
        {
            g_bTKill = bool: str_to_num(szVal);
        }

        else if (equali(szKey, "KNIFE EVENT"))
        {
            g_bKnife = bool: str_to_num(szVal);
        }

        else if (equali(szKey, "FIRSTBLOOD EVENT"))
        {
            g_bFBlood = bool: str_to_num(szVal);
        }

        else if (equali(szKey, "ROUNDSTART EVENT"))
        {
            g_bRStart = bool: str_to_num(szVal);
        }

        else if (equali(szKey, "DOUBLEKILL EVENT"))
        {
            g_bDKill = bool: str_to_num(szVal);
        }

        else if (equali(szKey, "HATTRICK EVENT"))
        {
            g_bHattrick = bool: str_to_num(szVal);
        }

        else if (equali(szKey, "TLMSTANDING EVENT"))
        {
            g_bTLMStanding = bool: str_to_num(szVal);
        }

        else if (equali(szKey, "FLAWLESS VICTORY"))
        {
            g_bFlawless = bool: str_to_num(szVal);
        }

        ///
        /// EVENT SOUNDS
        ///
        else if (equali(szKey, "HEADSHOT SOUNDS"))
        {
            if (QS_EmptyString(szVal) && 0 == ArraySize(g_pHShot))
            {
                ArrayPushString(g_pHShot, szVal);
            }

            while (!QS_EmptyString(szVal) && strtok2(szVal, szKey, charsmax(szKey), szVal, charsmax(szVal), ',', 1) >= -1)
            {
                trim(szKey);
                trim(szVal);

                if (!QS_EmptyString(szKey))
                {
                    ArrayPushString(g_pHShot, szKey);
                }
            }
        }

        else if (equali(szKey, "REVENGE SOUNDS"))
        {
            if (QS_EmptyString(szVal) && 0 == ArraySize(g_pRevenge))
            {
                ArrayPushString(g_pRevenge, szVal);
            }

            while (!QS_EmptyString(szVal) && strtok2(szVal, szKey, charsmax(szKey), szVal, charsmax(szVal), ',', 1) >= -1)
            {
                trim(szKey);
                trim(szVal);

                if (!QS_EmptyString(szKey))
                {
                    ArrayPushString(g_pRevenge, szKey);
                }
            }
        }

        else if (equali(szKey, "SUICIDE SOUNDS"))
        {
            if (QS_EmptyString(szVal) && 0 == ArraySize(g_pSuicide))
            {
                ArrayPushString(g_pSuicide, szVal);
            }

            while (!QS_EmptyString(szVal) && strtok2(szVal, szKey, charsmax(szKey), szVal, charsmax(szVal), ',', 1) >= -1)
            {
                trim(szKey);
                trim(szVal);

                if (!QS_EmptyString(szKey))
                {
                    ArrayPushString(g_pSuicide, szKey);
                }
            }
        }

        else if (equali(szKey, "NADE SOUNDS"))
        {
            if (QS_EmptyString(szVal) && 0 == ArraySize(g_pGrenade))
            {
                ArrayPushString(g_pGrenade, szVal);
            }

            while (!QS_EmptyString(szVal) && strtok2(szVal, szKey, charsmax(szKey), szVal, charsmax(szVal), ',', 1) >= -1)
            {
                trim(szKey);
                trim(szVal);

                if (!QS_EmptyString(szKey))
                {
                    ArrayPushString(g_pGrenade, szKey);
                }
            }
        }

        else if (equali(szKey, "TEAMKILL SOUNDS"))
        {
            if (QS_EmptyString(szVal) && 0 == ArraySize(g_pTKill))
            {
                ArrayPushString(g_pTKill, szVal);
            }

            while (!QS_EmptyString(szVal) && strtok2(szVal, szKey, charsmax(szKey), szVal, charsmax(szVal), ',', 1) >= -1)
            {
                trim(szKey);
                trim(szVal);

                if (!QS_EmptyString(szKey))
                {
                    ArrayPushString(g_pTKill, szKey);
                }
            }
        }

        else if (equali(szKey, "KNIFE SOUNDS"))
        {
            if (QS_EmptyString(szVal) && 0 == ArraySize(g_pKnife))
            {
                ArrayPushString(g_pKnife, szVal);
            }

            while (!QS_EmptyString(szVal) && strtok2(szVal, szKey, charsmax(szKey), szVal, charsmax(szVal), ',', 1) >= -1)
            {
                trim(szKey);
                trim(szVal);

                if (!QS_EmptyString(szKey))
                {
                    ArrayPushString(g_pKnife, szKey);
                }
            }
        }

        else if (equali(szKey, "FIRSTBLOOD SOUNDS"))
        {
            if (QS_EmptyString(szVal) && 0 == ArraySize(g_pFBlood))
            {
                ArrayPushString(g_pFBlood, szVal);
            }

            while (!QS_EmptyString(szVal) && strtok2(szVal, szKey, charsmax(szKey), szVal, charsmax(szVal), ',', 1) >= -1)
            {
                trim(szKey);
                trim(szVal);

                if (!QS_EmptyString(szKey))
                {
                    ArrayPushString(g_pFBlood, szKey);
                }
            }
        }

        else if (equali(szKey, "ROUNDSTART SOUNDS"))
        {
            if (QS_EmptyString(szVal) && 0 == ArraySize(g_pRStart))
            {
                ArrayPushString(g_pRStart, szVal);
            }

            while (!QS_EmptyString(szVal) && strtok2(szVal, szKey, charsmax(szKey), szVal, charsmax(szVal), ',', 1) >= -1)
            {
                trim(szKey);
                trim(szVal);

                if (!QS_EmptyString(szKey))
                {
                    ArrayPushString(g_pRStart, szKey);
                }
            }
        }

        else if (equali(szKey, "DOUBLEKILL SOUNDS"))
        {
            if (QS_EmptyString(szVal) && 0 == ArraySize(g_pDKill))
            {
                ArrayPushString(g_pDKill, szVal);
            }

            while (!QS_EmptyString(szVal) && strtok2(szVal, szKey, charsmax(szKey), szVal, charsmax(szVal), ',', 1) >= -1)
            {
                trim(szKey);
                trim(szVal);

                if (!QS_EmptyString(szKey))
                {
                    ArrayPushString(g_pDKill, szKey);
                }
            }
        }

        else if (equali(szKey, "HATTRICK SOUNDS"))
        {
            if (QS_EmptyString(szVal) && 0 == ArraySize(g_pHattrick))
            {
                ArrayPushString(g_pHattrick, szVal);
            }

            while (!QS_EmptyString(szVal) && strtok2(szVal, szKey, charsmax(szKey), szVal, charsmax(szVal), ',', 1) >= -1)
            {
                trim(szKey);
                trim(szVal);

                if (!QS_EmptyString(szKey))
                {
                    ArrayPushString(g_pHattrick, szKey);
                }
            }
        }

        else if (equali(szKey, "TLMSTANDING SOUNDS"))
        {
            if (QS_EmptyString(szVal) && 0 == ArraySize(g_pTLMStanding))
            {
                ArrayPushString(g_pTLMStanding, szVal);
            }

            while (!QS_EmptyString(szVal) && strtok2(szVal, szKey, charsmax(szKey), szVal, charsmax(szVal), ',', 1) >= -1)
            {
                trim(szKey);
                trim(szVal);

                if (!QS_EmptyString(szKey))
                {
                    ArrayPushString(g_pTLMStanding, szKey);
                }
            }
        }

        else if (equali(szKey, "FLAWLESS SOUNDS"))
        {
            if (QS_EmptyString(szVal) && 0 == ArraySize(g_pFlawless))
            {
                ArrayPushString(g_pFlawless, szVal);
            }

            while (!QS_EmptyString(szVal) && strtok2(szVal, szKey, charsmax(szKey), szVal, charsmax(szVal), ',', 1) >= -1)
            {
                trim(szKey);
                trim(szVal);

                if (!QS_EmptyString(szKey))
                {
                    ArrayPushString(g_pFlawless, szKey);
                }
            }
        }

        ///
        /// EVENT WORDS
        ///
        else if (equali(szKey, "TLMSTANDING WORDS"))
        {
            if (QS_EmptyString(szVal) && 0 == ArraySize(g_pTLMStandingWords))
            {
                ArrayPushString(g_pTLMStandingWords, QS_TLMSTANDING_WORD); /// .........
            }

            while (!QS_EmptyString(szVal) && strtok2(szVal, szKey, charsmax(szKey), szVal, charsmax(szVal), ',', 1) >= -1)
            {
                trim(szKey);
                trim(szVal);

                if (!QS_EmptyString(szKey))
                {
                    ArrayPushString(g_pTLMStandingWords, szKey);
                }
            }
        }

        else if (equali(szKey, "NADE NADES"))
        {
            if (QS_EmptyString(szVal) && 0 == ArraySize(g_pGrenadeNames))
            {
                ArrayPushString(g_pGrenadeNames, QS_DEF_GRENADE_NAME); /// .........
            }

            while (!QS_EmptyString(szVal) && strtok2(szVal, szKey, charsmax(szKey), szVal, charsmax(szVal), ',', 1) >= -1)
            {
                trim(szKey);
                trim(szVal);

                if (!QS_EmptyString(szKey))
                {
                    ArrayPushString(g_pGrenadeNames, szKey);
                }
            }
        }

        else if (equali(szKey, "KNIFE KNIVES"))
        {
            if (QS_EmptyString(szVal) && 0 == ArraySize(g_pKnifeNames))
            {
                ArrayPushString(g_pKnifeNames, QS_DEF_KNIFE_NAME); /// .........
            }

            while (!QS_EmptyString(szVal) && strtok2(szVal, szKey, charsmax(szKey), szVal, charsmax(szVal), ',', 1) >= -1)
            {
                trim(szKey);
                trim(szVal);

                if (!QS_EmptyString(szKey))
                {
                    ArrayPushString(g_pKnifeNames, szKey);
                }
            }
        }

        ///
        /// MESSAGE STRINGS
        ///
        else if (equali(szKey, "HEADSHOT HUDMSG"))
        {
            copy(g_szHShotMsg, charsmax(g_szHShotMsg), szVal);
        }

        else if (equali(szKey, "SUICIDE HUDMSG"))
        {
            copy(g_szSuicideMsg, charsmax(g_szSuicideMsg), szVal);
        }

        else if (equali(szKey, "NADE HUDMSG"))
        {
            copy(g_szGrenadeMsg, charsmax(g_szGrenadeMsg), szVal);
        }

        else if (equali(szKey, "TEAMKILL HUDMSG"))
        {
            copy(g_szTKillMsg, charsmax(g_szTKillMsg), szVal);
        }

        else if (equali(szKey, "KNIFE HUDMSG"))
        {
            copy(g_szKnifeMsg, charsmax(g_szKnifeMsg), szVal);
        }

        else if (equali(szKey, "FIRSTBLOOD HUDMSG"))
        {
            copy(g_szFBloodMsg, charsmax(g_szFBloodMsg), szVal);
        }

        else if (equali(szKey, "FIRSTBLOOD HUDMSG KILLER DISCONNECTED") || equali(szKey, "FIRSTBLOOD HUDMSG DISCONNECTED KILLER")) /** COMPATIBILITY */
        {
            copy(g_szFBloodMsgNoKiller, charsmax(g_szFBloodMsgNoKiller), szVal);
        }

        else if (equali(szKey, "ROUNDSTART HUDMSG"))
        {
            copy(g_szRStartMsg, charsmax(g_szRStartMsg), szVal);
        }

        else if (equali(szKey, "DOUBLEKILL HUDMSG"))
        {
            copy(g_szDKillMsg, charsmax(g_szDKillMsg), szVal);
        }

        else if (equali(szKey, "HATTRICK HUDMSG"))
        {
            copy(g_szHattrickMsg, charsmax(g_szHattrickMsg), szVal);
        }

        else if (equali(szKey, "TLMSTANDING TEAM HUDMSG"))
        {
            copy(g_szTLMStandingTeamMsg, charsmax(g_szTLMStandingTeamMsg), szVal);
        }

        else if (equali(szKey, "TLMSTANDING SELF HUDMSG"))
        {
            copy(g_szTLMStandingSelfMsg, charsmax(g_szTLMStandingSelfMsg), szVal);
        }

        else if (equali(szKey, "FLAWLESS VICTORY HUDMSG"))
        {
            copy(g_szFlawlessMsg, charsmax(g_szFlawlessMsg), szVal);
        }

        else if (equali(szKey, "REVENGE KILLER MESSAGE"))
        {
            copy(g_szRevengeMsgKiller, charsmax(g_szRevengeMsgKiller), szVal);
        }

        else if (equali(szKey, "REVENGE VICTIM MESSAGE"))
        {
            copy(g_szRevengeMsgVictim, charsmax(g_szRevengeMsgVictim), szVal);
        }

        else if (equali(szKey, "TERRO TEAM NAME") || equali(szKey, "TE TEAM NAME") || equali(szKey, "T TEAM NAME")) /** COMPATIBILITY */
        {
            copy(g_szFlawlessTeamName_TE, charsmax(g_szFlawlessTeamName_TE), szVal);
        }

        else if (equali(szKey, "CT TEAM NAME"))
        {
            copy(g_szFlawlessTeamName_CT, charsmax(g_szFlawlessTeamName_CT), szVal);
        }
    }

    ///
    /// CLOSES
    ///
    fclose(nFile);

    return true;
}

///
/// DISPLAYS K. STREAK GLOBALLY
///
static bool: QS_DisplayKStreak(&nKiller, szMsg[], szSnd[])
{
    static pnColor[4] = { QS_MIN_BYTE, ... };

    if (!QS_EmptyString(szMsg))
    {
        QS_HudMsgColor();
        {
            QS_MakeRGBA(pnColor);
            {
                QS_SetHudMsg(g_nRed, g_nGreen, g_nBlue, QS_HUD_MSG_X_POS, g_bDOD ? QS_STREAK_Y_POS_DOD : QS_STREAK_Y_POS, QS_HUD_MSG_EFFECTS, QS_HUD_MSG_EFFECTS_TIME, QS_HUD_MSG_HOLD_TIME, QS_HUD_MSG_FADE_IN_TIME, QS_HUD_MSG_FADE_OUT_TIME, -1, QS_HUD_MSG_ALPHA_AMOUNT, pnColor);
                {
                    QS_ShowHudMsg(QS_EVERYONE, g_pnHudMsgObj[QS_HUD_STREAK], szMsg, g_pszName[nKiller]);
                }
            }
        }
    }

    if (!QS_EmptyString(szSnd))
    {
        QS_ClientCmd(QS_EVERYONE, "SPK \"%s\"", szSnd);
    }

    return true;
}

///
/// RETRIEVES ACTIVE PLAYERS COUNT
///
/// bAlive [ TRUE/ FALSE ]
/// nTeam [ QS_INVALID_TEAM/ 0/ 1/ 2/ 3 ]
///
static QS_ActivePlayersNum(bool: bAlive, nTeam = QS_INVALID_TEAM)
{
    ///
    /// PLAYERS COUNT
    ///
    static nTotal = 0, nPlayer = QS_INVALID_PLAYER;

    ///
    /// ITERATES BETWEEN PLAYERS
    ///
    for (nTotal = 0, nPlayer = QS_MIN_PLAYER; nPlayer <= g_nMaxPlayers; nPlayer++)
    {
        ///
        /// IN GAME, NOT HLTV, IN SPECIFIED TEAM AND ALIVE/ DEAD
        ///
        if ((g_pbInGame[nPlayer]) && (!(g_pbHLTV[nPlayer])) && ((nTeam == QS_INVALID_TEAM) || (get_user_team(nPlayer) == nTeam)) && (bAlive == bool: is_user_alive(nPlayer)))
        {
            ///
            /// TOTAL = TOTAL + 1
            ///
            nTotal++;
        }
    }

    ///
    /// GETS THE TOTAL
    ///
    return nTotal;
}

///
/// RETRIEVES THE LEADER OF THIS ROUND
///
/// RETURNS 'QS_INVALID_PLAYER' IF THERE IS NO LEADER
///
static QS_Leader()
{
    ///
    /// DECLARES VARIABLES
    ///
    static nLeader = QS_INVALID_PLAYER, nKills = 0, nPlayer = QS_INVALID_PLAYER;

    ///
    /// ITERATES BETWEEN CLIENTS
    ///
    for (nPlayer = QS_MIN_PLAYER, nLeader = QS_INVALID_PLAYER, nKills = 0; nPlayer <= g_nMaxPlayers; nPlayer++)
    {
        ///
        /// IN GAME AND NOT HLTV
        ///
        if (g_pbInGame[nPlayer] && !g_pbHLTV[nPlayer])
        {
            ///
            /// HAS MANY KILLS THAN THE ONE PREVIOUSLY CHECKED
            ///
            if (g_pnKillsThisRound[nPlayer] > nKills)
            {
                ///
                /// THIS IS THE NEW LEADER
                ///
                nKills = g_pnKillsThisRound[nPlayer];
                {
                    nLeader = nPlayer;
                }
            }
        }
    }

    ///
    /// GETS THE LEADER ID
    ///
    return nLeader;
}

///
/// PROCESSES HUD MESSAGE
///
static bool: QS_ShowHudMsg(nTo, &nObj, szRules[], any: ...)
{
    ///
    /// ARGUMENT FORMAT
    ///
    static szBuffer[QS_HUD_MSG_MAX_LEN] = { EOS, ... }, nPlayer = QS_INVALID_PLAYER, bool: bIsPlayer = false;

    ///
    /// SANITY CHECK
    ///
    if (QS_EmptyString(szRules) || vformat(szBuffer, charsmax(szBuffer), szRules, 4) < 1)
    {
        return false;
    }

    bIsPlayer = QS_IsPlayer(nTo);

    ///
    /// SPECIFIED CLIENT
    ///
    if (bIsPlayer && g_pbInGame[nTo] && !g_pbBOT[nTo] && !g_pbHLTV[nTo] && !g_pbDisabled[nTo])
    {
        ShowSyncHudMsg(nTo, nObj, szBuffer);
    }

    ///
    /// NO TARGET
    ///
    else if (!bIsPlayer)
    {
        for (nPlayer = QS_MIN_PLAYER; nPlayer <= g_nMaxPlayers; nPlayer++)
        {
            if (g_pbInGame[nPlayer] && !g_pbBOT[nPlayer] && !g_pbHLTV[nPlayer] && !g_pbDisabled[nPlayer])
            {
                ShowSyncHudMsg(nPlayer, nObj, szBuffer);
            }
        }
    }

    return true;
}

///
/// PROCESSES HUD MESSAGE ( ALL PLAYERS ON THE GAME SERVER NO MATTER WHAT )
///
static bool: QS_ShowHudMsgAll(nTo, &nObj, szRules[], any: ...)
{
    ///
    /// ARGUMENT FORMAT
    ///
    static szBuffer[QS_HUD_MSG_MAX_LEN] = { EOS, ... }, nPlayer = QS_INVALID_PLAYER, bool: bIsPlayer = false;

    ///
    /// SANITY CHECK
    ///
    if (QS_EmptyString(szRules) || vformat(szBuffer, charsmax(szBuffer), szRules, 4) < 1)
    {
        return false;
    }

    bIsPlayer = QS_IsPlayer(nTo);

    ///
    /// SPECIFIED CLIENT
    ///
    if (bIsPlayer && g_pbInGame[nTo] && !g_pbBOT[nTo] && !g_pbHLTV[nTo])
    {
        ShowSyncHudMsg(nTo, nObj, szBuffer);
    }

    ///
    /// NO TARGET
    ///
    else if (!bIsPlayer)
    {
        for (nPlayer = QS_MIN_PLAYER; nPlayer <= g_nMaxPlayers; nPlayer++)
        {
            if (g_pbInGame[nPlayer] && !g_pbBOT[nPlayer] && !g_pbHLTV[nPlayer])
            {
                ShowSyncHudMsg(nPlayer, nObj, szBuffer);
            }
        }
    }

    return true;
}

///
/// PROCESSES CLIENT COMMAND
///
static bool: QS_ClientCmd(nTo, szRules[], any: ...)
{
    ///
    /// ARGUMENT FORMAT
    ///
    static szBuffer[QS_SND_MAX_LEN] = { EOS, ... }, nPlayer = QS_INVALID_PLAYER, bool: bIsPlayer = false;

    ///
    /// SANITY CHECK
    ///
    if (QS_EmptyString(szRules) || vformat(szBuffer, charsmax(szBuffer), szRules, 3) < 1 || equali(szBuffer, "SPK \"\""))
    {
        return false;
    }

    bIsPlayer = QS_IsPlayer(nTo);

    ///
    /// SPECIFIED CLIENT
    ///
    if (bIsPlayer && g_pbInGame[nTo] && !g_pbBOT[nTo] && !g_pbHLTV[nTo] && !g_pbDisabled[nTo])
    {
        client_cmd(nTo, szBuffer);
    }

    ///
    /// NO TARGET
    ///
    else if (!bIsPlayer)
    {
        for (nPlayer = QS_MIN_PLAYER; nPlayer <= g_nMaxPlayers; nPlayer++)
        {
            if (g_pbInGame[nPlayer] && !g_pbBOT[nPlayer] && !g_pbHLTV[nPlayer] && !g_pbDisabled[nPlayer])
            {
                client_cmd(nPlayer, szBuffer);
            }
        }
    }

    return true;
}

///
/// PROCESSES CLIENT COMMAND ( ALL PLAYERS ON THE GAME SERVER NO MATTER WHAT )
///
static bool: QS_ClientCmdAll(nTo, szRules[], any: ...)
{
    ///
    /// ARGUMENT FORMAT
    ///
    static szBuffer[QS_SND_MAX_LEN] = { EOS, ... }, nPlayer = QS_INVALID_PLAYER, bool: bIsPlayer = false;

    ///
    /// SANITY CHECK
    ///
    if (QS_EmptyString(szRules) || vformat(szBuffer, charsmax(szBuffer), szRules, 3) < 1 || equali(szBuffer, "SPK \"\""))
    {
        return false;
    }

    bIsPlayer = QS_IsPlayer(nTo);

    ///
    /// SPECIFIED CLIENT
    ///
    if (bIsPlayer && g_pbInGame[nTo] && !g_pbBOT[nTo] && !g_pbHLTV[nTo])
    {
        client_cmd(nTo, szBuffer);
    }

    ///
    /// NO TARGET
    ///
    else if (!bIsPlayer)
    {
        for (nPlayer = QS_MIN_PLAYER; nPlayer <= g_nMaxPlayers; nPlayer++)
        {
            if (g_pbInGame[nPlayer] && !g_pbBOT[nPlayer] && !g_pbHLTV[nPlayer])
            {
                client_cmd(nPlayer, szBuffer);
            }
        }
    }

    return true;
}

///
/// CLEARS STRING
///
static bool: QS_ClearString(szString[])
{
    szString[0] = EOS;

    return true;
}

///
/// EMPTY STRING
///
static bool: QS_EmptyString(const szString[])
{
    return (szString[0] == EOS);
}

///
/// CHECKS THE MOD NAME
///
static bool: QS_CheckMod()
{
    if (QS_EmptyString(g_szMod))
    {
        get_modname(g_szMod, charsmax(g_szMod));
    }

    return !QS_EmptyString(g_szMod);
}

///
/// CSTRIKE OR CZERO RUNNING
///
static bool: QS_CSCZRunning()
{
    QS_CheckMod();

    return equali(g_szMod, "CS", 2) || equali(g_szMod, "CZ", 2);
}

///
/// DAY OF DEFEAT RUNNING
///
static bool: QS_DODRunning()
{
    QS_CheckMod();

    return bool: equali(g_szMod, "DOD", 3);
}

///
/// XSTATS AVAILABLE
///
static bool: QS_XStatsAvail()
{
    static bool: bChecked = false, bool: bAvail = false;

    if (!bChecked)
    {
        bChecked = true;
        {
            bAvail = bool: module_exists("xstats");
        }
    }

    return bAvail;
}

///
/// GET THE TEAM TOTAL ALIVE, AND IF ONLY ONE PLAYER IS ALIVE IN THAT TEAM, THEIR ID
///
static QS_GetTeamTotalAlive(nTeam, &nPlayer = QS_INVALID_PLAYER) /// CSTRIKE AND CZERO ONLY
{
    static pnPlayers[QS_MAX_PLAYERS] = { QS_INVALID_PLAYER, ... }, nTotal = 0;

    get_players(pnPlayers, nTotal, "aeh", ((nTeam == QS_CSCZ_TEAM_TE) ? ("TERRORIST") : ("CT"))); /// aeh = EXCLUDE DEAD [a], EXCLUDE HLTV PROXIES [h] & MATCH WITH TEAM NAME [e]

    if (nTotal == 1)
    {
        nPlayer = pnPlayers[0];
    }

    else
    {
        nPlayer = QS_INVALID_PLAYER;
    }

    return nTotal;
}

///
/// UPDATES THE HUD MESSAGE'S COLOR
///
static bool: QS_HudMsgColor()
{
    if (g_bRandomRed)
    {
        g_nRed = random_num(QS_MIN_BYTE, QS_MAX_BYTE);
    }

    if (g_bRandomGreen)
    {
        g_nGreen = random_num(QS_MIN_BYTE, QS_MAX_BYTE);
    }

    if (g_bRandomBlue)
    {
        g_nBlue = random_num(QS_MIN_BYTE, QS_MAX_BYTE);
    }

    return true;
}

///
/// VALID PLAYERS ARE FROM QS_MIN_PLAYER TO g_nMaxPlayers
///
static bool: QS_IsPlayer(&nId)
{
    return (nId < QS_MIN_PLAYER || nId > g_nMaxPlayers) ? false : true;
}

///
/// VALID PLAYERS ARE FROM QS_MIN_PLAYER TO g_nMaxPlayers
///
/// THE WORLDSPAWN IS 0
///
static bool: QS_IsPlayerOrWorld(&nId)
{
    return (nId < QS_WORLDSPAWN || nId > g_nMaxPlayers) ? false : true;
}

///
/// VALID 'get_user_msgid ( )'
///
static bool: QS_ValidMsg(&nMsg)
{
    return nMsg > QS_INVALID_MSG;
}

///
/// VALID WEAPON
///
static bool: QS_ValidWeapon(&nWpn)
{
    return nWpn > QS_INVALID_WEAPON;
}

///
/// VALID HIT PLACE
///
static bool: QS_ValidPlace(&nPlace)
{
    return nPlace > QS_INVALID_PLACE;
}

///
/// VALID USER ID
///
static bool: QS_ValidUserId(&nUserId)
{
    return nUserId > QS_INVALID_USER_ID;
}

///
/// STEAM ID SHRINKING
///
static bool: QS_ShrinkSteam(szSteam[QS_STEAM_MAX_LEN])
{
    static szBuffer[QS_STEAM_MAX_LEN] = { EOS, ... };

    if (strlen(szSteam) > 10)
    {
        if (isdigit(szSteam[10]))
        {
            copy(szBuffer, charsmax(szBuffer), szSteam[10]);
            {
                szSteam = szBuffer;
                {
                    return true;
                }
            }
        }
    }

    return false;
}

///
/// COLORED MESSAGE IN CS/ CZ
///
/// '\x01' -> DEFAULT
/// '\x04' -> GREEN
///
/// ------
/// nIndex
/// ------
///
/// IF nIndex = 'QS_CC_ST_X03_GREY -> [ 33 ]' THEN ('\x03' IS GREY)
/// IF nIndex = 'QS_CC_ST_X03_RED -> [ 34 ]' THEN ('\x03' IS RED)
/// IF nIndex = 'QS_CC_ST_X03_BLUE -> [ 35 ]' THEN ('\x03' IS BLUE)
///
/// IF nIndex = ANYTHING ELSE THEN ('\x03' IS THEIR TEAM COLOR)
///
static bool: QS_CSCZColored(nPlayer, nIndex, szIn[], any: ...)
{
    static szMsg[256] = { EOS, ... }, pnPlayers[QS_MAX_PLAYERS] = { QS_INVALID_PLAYER, ... }, nTotal = 0, nIter = 0, nOther = QS_INVALID_PLAYER, bool: bSuccess = false;

    if (g_bColors)
    {
        if (!QS_EmptyString(szIn))
        {
            if (QS_ValidMsg(g_nSayText))
            {
                if (vformat(szMsg, charsmax(szMsg), szIn, 4) > 0)
                {
                    if (QS_IsPlayer(nPlayer))
                    {
                        if (g_pbInGame[nPlayer])
                        {
                            if (!g_pbBOT[nPlayer] && !g_pbHLTV[nPlayer])
                            {
                                message_begin(MSG_ONE_UNRELIABLE, g_nSayText, { 0, 0, 0 } /** MESSAGE ORIGIN */, nPlayer);
                                {
                                    write_byte((((nIndex >= QS_CC_ST_X03_MIN) && (nIndex <= QS_CC_ST_X03_MAX)) ? (nIndex) : (nPlayer)));
                                    {
                                        write_string(szMsg);
                                        {
                                            message_end();
                                            {
                                                return true;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    else
                    {
                        get_players(pnPlayers, nTotal, "ch", ""); /// NO BOTS & HLTV PROXIES
                        {
                            if (nTotal > 0)
                            {
                                for (bSuccess = false, nIter = 0; nIter < nTotal; nIter++)
                                {
                                    nOther = pnPlayers[nIter];
                                    {
                                        if (g_pbInGame[nOther])
                                        {
                                            message_begin(MSG_ONE_UNRELIABLE, g_nSayText, { 0, 0, 0 } /** MESSAGE ORIGIN */, nOther);
                                            {
                                                write_byte((((nIndex >= QS_CC_ST_X03_MIN) && (nIndex <= QS_CC_ST_X03_MAX)) ? (nIndex) : (nOther)));
                                                {
                                                    write_string(szMsg);
                                                    {
                                                        message_end();
                                                        {
                                                            bSuccess = true;
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }

                                return bSuccess;
                            }
                        }
                    }
                }
            }
        }
    }

    return false;
}

///
/// COLORED MESSAGE IN CS/ CZ ( FILTERED )
///
/// '\x01' -> DEFAULT
/// '\x04' -> GREEN
///
/// ------
/// nIndex
/// ------
///
/// IF nIndex = 'QS_CC_ST_X03_GREY -> [ 33 ]' THEN ('\x03' IS GREY)
/// IF nIndex = 'QS_CC_ST_X03_RED -> [ 34 ]' THEN ('\x03' IS RED)
/// IF nIndex = 'QS_CC_ST_X03_BLUE -> [ 35 ]' THEN ('\x03' IS BLUE)
///
/// IF nIndex = ANYTHING ELSE THEN ('\x03' IS THEIR TEAM COLOR)
///
static bool: QS_CSCZColoredFiltered(nPlayer, nIndex, szIn[], any: ...)
{
    static szMsg[256] = { EOS, ... }, pnPlayers[QS_MAX_PLAYERS] = { QS_INVALID_PLAYER, ... }, nTotal = 0, nIter = 0, nOther = QS_INVALID_PLAYER, bool: bSuccess = false;

    if (g_bColors)
    {
        if (!QS_EmptyString(szIn))
        {
            if (QS_ValidMsg(g_nSayText))
            {
                if (vformat(szMsg, charsmax(szMsg), szIn, 4) > 0)
                {
                    if (QS_IsPlayer(nPlayer))
                    {
                        if (g_pbInGame[nPlayer])
                        {
                            if (!g_pbBOT[nPlayer] && !g_pbHLTV[nPlayer])
                            {
                                if (!g_pbDisabled[nPlayer])
                                {
                                    message_begin(MSG_ONE_UNRELIABLE, g_nSayText, { 0, 0, 0 } /** MESSAGE ORIGIN */, nPlayer);
                                    {
                                        write_byte((((nIndex >= QS_CC_ST_X03_MIN) && (nIndex <= QS_CC_ST_X03_MAX)) ? (nIndex) : (nPlayer)));
                                        {
                                            write_string(szMsg);
                                            {
                                                message_end();
                                                {
                                                    return true;
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    else
                    {
                        get_players(pnPlayers, nTotal, "ch", ""); /// NO BOTS & HLTV PROXIES
                        {
                            if (nTotal > 0)
                            {
                                for (bSuccess = false, nIter = 0; nIter < nTotal; nIter++)
                                {
                                    nOther = pnPlayers[nIter];
                                    {
                                        if (g_pbInGame[nOther])
                                        {
                                            if (!g_pbDisabled[nOther])
                                            {
                                                message_begin(MSG_ONE_UNRELIABLE, g_nSayText, { 0, 0, 0 } /** MESSAGE ORIGIN */, nOther);
                                                {
                                                    write_byte((((nIndex >= QS_CC_ST_X03_MIN) && (nIndex <= QS_CC_ST_X03_MAX)) ? (nIndex) : (nOther)));
                                                    {
                                                        write_string(szMsg);
                                                        {
                                                            message_end();
                                                            {
                                                                bSuccess = true;
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }

                                return bSuccess;
                            }
                        }
                    }
                }
            }
        }
    }

    return false;
}

///
/// MAKE RGBA ARRAY
///
static bool: QS_MakeRGBA(pnColor[4])
{
    pnColor[0] = g_nRed;
    pnColor[1] = g_nGreen;
    pnColor[2] = g_nBlue;

    pnColor[3] = QS_HUD_MSG_ALPHA_AMOUNT;

    return true;
}

///
/// SETS A HUD MESSAGE
///
static bool: QS_SetHudMsg(nRed = 200, nGreen = 100, nBlue = 0, Float: fX = -1.000000, Float: fY = 0.350000, nEffects = 0, Float: fEffectsTime = 6.000000,
    Float: fHoldTime = 12.000000, Float: fFadeInTime = 0.100000, Float: fFadeOutTime = 0.200000, nChannel = -1, nAlpha = 0, pnColor[4] = { 255, 255, 250, 0 })
{

#if defined AMXX_VERSION_LOCAL_REV_NUM

#if AMXX_VERSION_LOCAL_REV_NUM > 5281

#if defined AMXX_VERSION_NUM

#if AMXX_VERSION_NUM > 189

    set_hudmessage(nRed, nGreen, nBlue, fX, fY, nEffects, fEffectsTime, fHoldTime, fFadeInTime, fFadeOutTime, nChannel, nAlpha, pnColor); /// LATEST

#else /// AMXX_VERSION_NUM > 189

    nAlpha = 0;
    {
        pnColor[0] = 0;
        pnColor[1] = 0;
        pnColor[2] = 0;
        pnColor[3] = 0;
        {
            pnColor[3] += nAlpha; /// SUPPRESS A COMPILER WARNING
            {
                set_hudmessage(nRed, nGreen, nBlue, fX, fY, nEffects, fEffectsTime, fHoldTime, fFadeInTime, fFadeOutTime, nChannel); /// COMPATIBILITY
            }
        }
    }

#endif

#else /// defined AMXX_VERSION_NUM

    nAlpha = 0;
    {
        pnColor[0] = 0;
        pnColor[1] = 0;
        pnColor[2] = 0;
        pnColor[3] = 0;
        {
            pnColor[3] += nAlpha; /// SUPPRESS A COMPILER WARNING
            {
                set_hudmessage(nRed, nGreen, nBlue, fX, fY, nEffects, fEffectsTime, fHoldTime, fFadeInTime, fFadeOutTime, nChannel); /// COMPATIBILITY
            }
        }
    }

#endif

#else /// AMXX_VERSION_LOCAL_REV_NUM > 5281

    nAlpha = 0;
    {
        pnColor[0] = 0;
        pnColor[1] = 0;
        pnColor[2] = 0;
        pnColor[3] = 0;
        {
            pnColor[3] += nAlpha; /// SUPPRESS A COMPILER WARNING
            {
                set_hudmessage(nRed, nGreen, nBlue, fX, fY, nEffects, fEffectsTime, fHoldTime, fFadeInTime, fFadeOutTime, nChannel); /// COMPATIBILITY
            }
        }
    }

#endif

#else /// defined AMXX_VERSION_LOCAL_REV_NUM

    nAlpha = 0;
    {
        pnColor[0] = 0;
        pnColor[1] = 0;
        pnColor[2] = 0;
        pnColor[3] = 0;
        {
            pnColor[3] += nAlpha; /// SUPPRESS A COMPILER WARNING
            {
                set_hudmessage(nRed, nGreen, nBlue, fX, fY, nEffects, fEffectsTime, fHoldTime, fFadeInTime, fFadeOutTime, nChannel); /// COMPATIBILITY
            }
        }
    }

#endif

    return true;
}

///
/// PLAYER ID BY PLAYER USER ID
///
static QS_PlayerIdByPlayerUserId(&nUserId)
{
    static nPlayer = QS_INVALID_PLAYER;

    if (QS_ValidUserId(nUserId))
    {
        for (nPlayer = QS_MIN_PLAYER; nPlayer <= g_nMaxPlayers; nPlayer++)
        {
            if (nUserId == get_user_userid(nPlayer))
            {
                return nPlayer;
            }
        }
    }

    return QS_INVALID_PLAYER;
}

///
/// IS THERE ANY ALIVE PLAYER
///
static bool: QS_IsThereAnyAlivePlayer()
{
    static nPlayer = QS_INVALID_PLAYER;

    for (nPlayer = QS_MIN_PLAYER; nPlayer <= g_nMaxPlayers; nPlayer++)
    {
        if (is_user_alive(nPlayer))
        {
            return true;
        }
    }

    return false;
}

///
/// IS TEAM KILL
///
static bool: QS_IsTeamKill(&nTeamKill)
{
    return (nTeamKill > QS_TEAM_KILL_NO);
}
