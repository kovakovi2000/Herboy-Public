<?php
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/includes/Account.php");

global $lang;

class Page {
    public $name;
    public $link;
    private $access;

    function __construct($name, $link, $access = null)
    {
        $this->name = $name;
        $this->link = $link;
        $this->access = $access;
    }

    function CanAccess()
    {
        if(isset($this->access)) return call_user_func($this->access);
        return true;
    }
}

//array_push(Config::$menupages, new Page($lang['menu_prizedraw'], "prizedraw"));
//array_push(Config::$menupages, new Page("!SKIN SZAVAZÁS!", "skinvote"));

array_push(
    Config::$menupages,
    Account::IsLogined() ?
        (new Page($lang['menu_profile'], "profile/" . Account::$UserProfile->id . "/")) :
        (new Page($lang['menu_login'], "login"))
);

array_push(Config::$menupages, new Page($lang['menu_home'], "#"));
//array_push(Config::$menupages, new Page($lang['menu_store'], "store"));
//array_push(Config::$menupages, new Page($lang['menu_purchases'], "purchases", "Account::IsLogined"));
array_push(Config::$menupages, new Page($lang['menu_rules'], "rules"));
array_push(Config::$menupages, new Page($lang['menu_banlist'], "banlist"));
array_push(Config::$menupages, new Page($lang['menu_mutelist'], "mutelist"));
array_push(Config::$menupages, new Page($lang['menu_userlist'], "userlist"));
array_push(Config::$menupages, new Page($lang['menu_downloadcs'], "csdownload"));
//array_push(Config::$menupages, new Page($lang['menu_settings'], "settings", "Account::IsLogined"));
array_push(Config::$menupages, new Page($lang['menu_serverchat'], "chat", "Account::CanMute"));
array_push(Config::$menupages, new Page($lang['menu_activity'], "act", "Account::Devs"));
array_push(Config::$menupages, new Page($lang['menu_logout'], "logout", "Account::IsLogined"));