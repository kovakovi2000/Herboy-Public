<?php
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/includes/EzSql.php");
error_reporting(E_ALL);
ini_set('display_errors', 'On');
class Config {

    public static $domain = "herboyd2.hu";

    //API keys/Secrets
    public static $apikey_SteamAuth = "";
    public static $apikey_SteamAuth_vars = array();
    public static $apikey_discord_error_webhook = "";
    public static $apikey_abuseipdb = "";
    public static $secret_security_salt = "";
    public static $secret_password_salt = "{{6&#9Ii<hL&6{aO&tV@&#eE>5100<&eP}{&xU>#<xS><##{iS}{lleY2069}}";

    public static $secret_email_user = "";
    public static $secret_email_pass = "";

    //Cookies
    public static $cookie_expire_default = 315360000;
    public static $cookie_expire_loginNormal = 604800;
    public static $cookie_expire_loginSteam = 2678400;
    public static $cookie_LoginToken_name = "LoginToken";
    public static $cookie_Agreed_name = "AgreedToken";
    public static $cookie_AgreeCookie_name = "AgreeCookie";
    public static $cookie_SecurityPass_name = "BenignToken";

    //Sql
    public static $sql;
    public static $sql_address = "127.0.0.1";
    public static $sql_username = "webserver";
    public static $sql_password = "XHgSVR3tWDkmcnqJhfpAbu";
    public static $sql_database = array("s2_herboy","bansys", "abuseipdb");

    //sql tables
    public static $t_AmxBan_name = "amx_bans";
    public static $t_AmxKick_name = "amx_kick";
    public static $t_AmxMute_name = "amx_mutes";
    public static $t_AmxAlias_name = "amx_alias";
    public static $t_AmxScan_name = "amx_scans";
    public static $t_Comments_name = "profile_comments";
    public static $t_regsystem_name = "herboy_regsystem";
    public static $t_Agreed_name = "webcookieagreedlog";
    public static $t_LoginToken_name = "weblogintoken";
    public static $t_LoginByTokenLog_name = "weblogincookielog";
    public static $t_LoginFailed_name = "webloginfailed";
    public static $t_LoginLog_name = "webloginlog";
    public static $t_PurchaseLog_name = "paypal_payments";
    public static $t_PurchaseLog2_name = "__syn_payments";

    //varibles
    public static $menupages = array();
    public static $perms = array();
    public static $statuses = array();
}

//include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/ServerList.php");

global $sql;
global $sql_banapi;
global $servers;
$sql = new EzSql(Config::$sql_address, Config::$sql_username, Config::$sql_password, Config::$sql_database);
$LOADED["config"] = true;