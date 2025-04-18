<?php


// Permission class definition
class Permission {
    public $name;
    public $style;

    public function __construct($name, $style)
    {
        $this->name = $name;
        $this->style = $style;
    }
}

// Initialize permissions using $lang after it has been loaded

// Default player permission
Config::$perms[0] = new Permission($lang['player'], "sty_none");

// Admin permissions
Config::$perms['admin'] = array();
Config::$perms['admin'][0] = new Permission($lang['admin'][0], "sty_ac");
Config::$perms['admin'][1] = new Permission($lang['admin'][1], "sty_dev");
Config::$perms['admin'][2] = new Permission($lang['admin'][2], "sty_owner");
Config::$perms['admin'][3] = new Permission($lang['admin'][3], "sty_headadmin");
Config::$perms['admin'][4] = new Permission($lang['admin'][4], "sty_admin");

// Drazilla - Veteran
Config::$perms['admin'][5] = new Permission($lang['player'], "sty_none");

// VIP permissions
Config::$perms['vip'] = array();
Config::$perms['vip'][1] = new Permission($lang['vip'][1], "sty_vip");
Config::$perms['vip'][2] = new Permission($lang['vip'][2], "sty_premiumvip");
Config::$perms['vip'][3] = new Permission($lang['vip'][3], "sty_premiumvipplus");
Config::$perms['vip'][4] = new Permission($lang['vip'][4], "sty_premiumvipplus");

// Statuses
Config::$statuses[0] = new Permission($lang['statuses'][0], "label-danger");
Config::$statuses[1] = new Permission($lang['statuses'][1], "label-success");
Config::$statuses[2] = new Permission($lang['statuses'][2], "label-success");
Config::$statuses[3] = new Permission($lang['statuses'][3], "label-success");

