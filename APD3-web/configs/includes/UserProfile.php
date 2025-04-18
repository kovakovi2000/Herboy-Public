<?php
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/includes/PermissionLevel.php");
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/includes/EzSql.php");
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/Config.php");
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/Perms.php");
include_once($_SERVER['DOCUMENT_ROOT'] . "/apis/SteamAuth/SteamProfileInfo.php");

class UserProfile {
    public $id;
    public $Username;
    public $Password;
    public $Email;
    public $LastLoginID;
    public $LastLoginIP;
    public $LastLoginName;
    public $RegisterName;
    public $RegisterIP;
    public $RegisterID;
    public $RegisterDate;
    public $Active;
    public $PremiumPoint;
    public $LastLoginDate;
    public $AutoLogin;
    public $PlayTime;
    public $LastLoggedOn;
    public $PermLvl;
    public $SessionID;
    public $Steam;

    function __construct($auth = null, $keys = array(), $sql_user_row = null, $lightversion = false)
    {
        if ($auth == "SERVER_ID" || $auth == "0") {
            $this->id = 0;
            $this->LastLoginID = "SERVER_ID";
            $this->LastLoginName = "AntiCheat";
            $this->PlayTime = 0;
            $this->PermLvl = new PermissionLevel(true);
            return;
        }

        global $sql;
        $this->PermLvl = new PermissionLevel();
        
        if ($auth != null) {
            $sql_user_row = $sql->select_row(Config::$t_regsystem_name, $keys, 
            "id='".$auth."' OR LastLoginID='".$auth."' ORDER BY `LastLoginDate` DESC");
        }

        if ($sql_user_row == null) {
            $this->id = null;
            return false;
        }

        $arraykeys = array_keys($sql_user_row);
        for ($i = 1; $i < sizeof($arraykeys); $i += 2) {
            if (isset($arraykeys[$i]) && array_key_exists($arraykeys[$i], $sql_user_row)) {
                $this->update_value($arraykeys[$i], $sql_user_row[$arraykeys[$i]]);
            }
        }

        if (!isset($this->id)) return false;

        if (!$lightversion) {
            $this->Steam = new SteamProfileInfo(null, $this->LastLoginID);
        }
    }

    function SuccessInit()
    {
        return isset($this->id);
    }

    function IsSteam()
    {
        if(isset($this->Steam))
            return $this->Steam->SuccessInit();
        else
            return false;
    }

    function setOnline($session_id)
    {
        $sql::update(Config::$t_regsystem_name, array("SessionToken = '$session_id'"), array($this->id));
        $this->update_value("SessionToken", $session_id);
    }

    function isOnline()
    {
        $session_id = $sql->select_row(Config::$t_regsystem_name, array("SessionToken"), array($this->id))["SessionToken"];
        $this->update_value("SessionToken", $session_id);
        return Utils::session_status($session_id);
    }

    function request_update($keys = array())
    {
        global $sql;
    
        if (empty($keys)) {
            $sql_user_row = $sql::select_row_q("SELECT * FROM `".Config::$t_regsystem_name."` WHERE `id` = {$this->id} LIMIT 1;");
            $arraykeys = array_keys($sql_user_row);
    
            for ($i = 1; $i < sizeof($arraykeys); $i += 2) {
                if (isset($arraykeys[$i]) && array_key_exists($arraykeys[$i], $sql_user_row)) {
                    $this->update_value($arraykeys[$i], $sql_user_row[$arraykeys[$i]]);
                }
            }
        } else {
            $formated_keys = implode(", ", $keys);
            $sql_user_row = $sql::select_row_q("SELECT {$formated_keys} FROM `".Config::$t_regsystem_name."` WHERE `id` = {$this->id} LIMIT 1;");
    
            foreach ($keys as $key) {
                if (array_key_exists($key, $sql_user_row)) {
                    $this->update_value($key, $sql_user_row[$key]);
                }
            }
        }
    }
    function isBanable(UserProfile $victim, $serverid)
{
    if (!isset($this->PermLvl->AdminLvl[$serverid])) {
        return false;
    }
    
    if($this->PermLvl->AdminLvl[$serverid] == 0)
    {
        if (!isset($this->PermLvl->VipLvl[$serverid]) || $this->PermLvl->VipLvl[$serverid] == 0 || 
            (isset($victim->PermLvl->AdminLvl[$serverid]) && $victim->PermLvl->AdminLvl[$serverid] > 0))
            return false;
        elseif (!in_array($this->PermLvl->VipLvl[$serverid], array(3, 4)))
            return false;
        elseif ((!isset($victim->PermLvl->VipLvl[$serverid]) || $victim->PermLvl->VipLvl[$serverid] == 0) && $this->PermLvl->VipLvl[$serverid] > 0)
            return true;
        elseif (isset($victim->PermLvl->VipLvl[$serverid]) && $victim->PermLvl->VipLvl[$serverid] > 0 && 
                $victim->PermLvl->VipLvl[$serverid] > $this->PermLvl->VipLvl[$serverid])
            return true;
    }
    elseif ((!isset($victim->PermLvl->AdminLvl[$serverid]) || $victim->PermLvl->AdminLvl[$serverid] == 0) && $this->PermLvl->AdminLvl[$serverid] > 0)
        return true;
    elseif (isset($victim->PermLvl->AdminLvl[$serverid]) && $victim->PermLvl->AdminLvl[$serverid] > 0 && 
            $victim->PermLvl->AdminLvl[$serverid] > $this->PermLvl->AdminLvl[$serverid])
        return true;

    return false;
}

    function isBanableSomewhere(UserProfile $victim)
    {
        global $servers;
        for ($i=0; $i < sizeof($servers); $i++) {
            if($this->isBanable($victim, $i))
                return true;
        }
        return false;
    }
    function isMuteable(UserProfile $victim, $serverid)
    {
        if (!isset($this->PermLvl->AdminLvl[$serverid])) {
            return false;
        }
        
        if($this->PermLvl->AdminLvl[$serverid] == 0)
        {
            if (!isset($this->PermLvl->VipLvl[$serverid]) || $this->PermLvl->VipLvl[$serverid] == 0 || 
                (isset($victim->PermLvl->AdminLvl[$serverid]) && $victim->PermLvl->AdminLvl[$serverid] > 0))
                return false;
            elseif ((!isset($victim->PermLvl->VipLvl[$serverid]) || $victim->PermLvl->VipLvl[$serverid] == 0) && $this->PermLvl->VipLvl[$serverid] > 1)
                return true;
            elseif (isset($victim->PermLvl->VipLvl[$serverid]) && $victim->PermLvl->VipLvl[$serverid] > 1 && 
                    $victim->PermLvl->VipLvl[$serverid] > $this->PermLvl->VipLvl[$serverid])
                return true;
        }
        elseif ((!isset($victim->PermLvl->AdminLvl[$serverid]) || $victim->PermLvl->AdminLvl[$serverid] == 0) && $this->PermLvl->AdminLvl[$serverid] > 0)
            return true;
        elseif (isset($victim->PermLvl->AdminLvl[$serverid]) && $victim->PermLvl->AdminLvl[$serverid] > 0 && 
                $victim->PermLvl->AdminLvl[$serverid] > $this->PermLvl->AdminLvl[$serverid])
            return true;
    
        return false;
    }

    function isMuteableSomewhere(UserProfile $victim)
    {
        global $servers;
        for ($i=0; $i < sizeof($servers); $i++) {
            if($this->isMuteable($victim, $i))
                return true;
        }
        return false;
    }

    function ProfilePic($size = 200, $link = 0, $banned = 0)
    {
        $permclass = $this->PermLvl->GetPerm();

        if($permclass === 5)
            $this->$permclass = 0;
        $issteam = $this->IsSteam();
        switch ($link) {
            case 1:
                $link = Utils::get_url("profile/".$this->id);
                break;
            case 2:
                $link = $issteam ? ("https://steamcommunity.com/profiles/".$this->Steam->steamid64) : "";
                break;
            default:
                $link = "";
                break;
        }
        ?>
        <div class='avatar-container' style='<?php echo "width: {$size}px; height: {$size}px;"; ?>'>
            <?php if(!empty($link)) echo "<a href='$link' target='_blank'>"; ?>
                <div class='avatar-fake_border <?php echo $permclass; ?>'>
                    <?php if(max($this->PermLvl->VipLvl) == 4) echo "<snap class='avatar_sparkle avatar-img'></snap>"; ?>
                    <div class='state_icon <?php echo $permclass; ?>'>
                        <div class='dot <?php echo $this->Active > 0 ? "green_icon" : "red_icon";?>'></div>
                    </div>
                    
                    <?php if ($this->id == 0): ?>
                        <img class='avatar-img' src='/images/av_ac.png'>
                    <?php else: ?>
                        <img class='avatar-img' src='<?php echo $issteam ? $this->Steam->avatarfull : "/images/av_placeholder.jpg"; ?>' loading="lazy">
                    <?php endif; ?>

                    <?php if ($banned): ?>
                        <div class="avatar_banned_overlay"></div> <!-- Piros árnyalat -->
                        <img class="avatar_banned" src="/images/av_banned.png"> <!-- Banned kép keresztbe -->
                    <?php endif; ?>
                </div>
            <?php if(!empty($link)) echo "</a>"; ?>
        </div>
        <?php
    }

function NameCard($style="", $print=false, $banned=0, $is_noprofile=0, $country=false)
{
    global $sql;
    global $serverindex;
    // Replace <div> with <span> to keep inline structure
    if($is_noprofile == 0)
        $return = "<a class='profile-clickable' ".($this->id != -1 ? ("href='".Utils::get_url("profile/".$this->id)."'") : "").">";
    else
        $return = "<a>";

    if($banned > 0)
    {
        $return .= "<span class='label sty_banned' style='margin-right: 5px; border:0px;".$style."'><span class='glyphicon glyphicon-remove'></span>BANNED<span class='glyphicon glyphicon-remove'></span></span>";
        $return .= "</a>"; // Close span instead of div
        if($print)
            echo $return;
        return $return;
    }

    $adminlvl = $this->PermLvl->isAdmin();

   // if($this->id == -1)
   //     $return .= "<span class='label sty_notfound' style='margin-right: 5px; margin-top: 2px; border:0px;".$style."'>N/A</span>";
   $adminlvl = $this->PermLvl->isAdmin();
   if($adminlvl > 0 && $adminlvl != 5)
       $return .= "<span class='label ".Config::$perms["admin"][$adminlvl]->style."' style='margin-right: 5px; border:0px;".$style."'>".Config::$perms["admin"][$adminlvl]->name."</span>";
   elseif($adminlvl == -1 && $adminlvl != 5)
       $return .= "<span class='label ".Config::$perms["admin"][0]->style."' style='margin-right: 5px; border:0px;".$style."'>".Config::$perms["admin"][0]->name."</span>";
   else
       $return .= "<span class='label sty_player' style='margin-right: 5px; border:0px;".$style."'>".Config::$perms[0]->name."</span>";

    $viplvl = $this->PermLvl->isVip();
    if($viplvl > 0)
        $return .= "<span class='label ".Config::$perms["vip"][$viplvl]->style."' style='margin-right: 5px; border:0px;".$style."'>".Config::$perms["vip"][$viplvl]->name."</span>";
    
    if($is_noprofile == 0)
    $return .= htmlspecialchars($this->LastLoginName ?? '', ENT_QUOTES); // Close span instead of div

    if($country)
    {
        $currdb = $sql->get_database();
        $sql->set_database(1);
        $ipdata = mysqli_fetch_array($sql->query("SELECT * FROM `ip_data` WHERE `ip` LIKE '{$this->LastLoginIP}' LIMIT 1;"));
        $sql->set_database($currdb);
        $country = isset($ipdata["location_country_code"]) ? strtolower($ipdata["location_country_code"]) : '';
        $return .= '<img src="'.Utils::get_url("images/CCI/".$country.".png").'" width="16" height="12" style="margin-left: 3px;" alt="'.$country.'">';
    }

    $return .= "</a>";
    if($print)
        echo $return;
    return $return;
}

    private function update_value($key, $value)
    {
        switch ($key) {
            case 'id': {
                $this->id = $value;
                break;
            }
            case 'Username': {
                $this->Username = $value;
                break;
            }
            case 'Password': {
                $this->Password = $value;
                break;
            }
            case 'Email': {
                $this->Email = $value;
                break;
            }
            case 'LastLoginID': {
                $this->LastLoginID = $value;
                break;
            }
            case 'LastLoginIP': {
                $this->LastLoginIP = $value;
                break;
            }
            case 'LastLoginName': {
                $this->LastLoginName = $value;
                break;
            }
            case 'RegisterName': {
                $this->RegisterName = $value;
                break;
            }
            case 'RegisterIP': {
                $this->RegisterIP = $value;
                break;
            }
            case 'RegisterID': {
                $this->RegisterID = $value;
                break;
            }
            case 'RegisterDate': {
                $this->RegisterDate = $value;
                break;
            }
            case 'Active': {
                $this->Active = $value;
                break;
            }
            case 'PremiumPoint': {
                $this->PremiumPoint = $value;
                break;
            }
            case 'LastLoginDate': {
                $this->LastLoginDate = $value;
                break;
            }
            case 'AutoLogin': {
                $this->AutoLogin = $value;
                break;
            }
            case 'PlayTime': {
                $this->PlayTime = $value;
                break;
            }
            case 'SessionToken': {
                $this->SessionID = $value;
                break;
            }
            case 'LoginKey';
            case 'LastLoggedOn': {
                $this->LastLoggedOn = $value;
                break;
            }
            case 'uac_banned';
            case 'uac_bannedby';
            case 'uac_elapse';
            case 'uac_started';
			case 'AdminLvL2';
            case 'uac_reason';
            case 'plang';
                break; //IGNORE
            default:
                if($this->PermLvl->update_value($key, $value) === false)
                    Utils::php_error($this, "Unknown column name:\"$key\"");
                break;
        }
        return true;
    }
}