<?php
class BanData {

    public static $NeededColumList = array(
        'id',
        'LastLoginName',
        'AdminLvL1'
    );

    public $bid;

    public $player_ip;
    public $player_id;
    public $player_nick;
    public $player;

    public $admin_ip;
    public $admin_id;
    public $admin_nick;
    public $admin;
    
    public $reason;
    public $created;
    public $length;
    public $kicked_count;
    public $expired;
    public $UID;
    public $UName;
    public $modified;
    public $isNew;
    public $ForbiddenUnban;
    public $unban_uuid;
    public $uuid_created;
    public $uuid_used;

    public $BannedByAdminPerm;


    function __construct($input) //query row or bid
    {
        if(is_numeric($input))
        {
            global $sql;
            $input = $sql->select_row(Config::$t_AmxBan_name, null, "`bid`=".$bid);
        }

        if(!is_array($input))
        {
            Utils::php_error($this, "Invalid var type:\"".gettype($input)."\"");
            return;
        }


        $this->bid = $input["bid"];
        $this->BannedByAdminPerm = $input["BannedByAdminPerm"];

        $this->player_ip = $input["player_ip"];
        $this->player_id = $input["player_id"];
        $this->player_nick = $input["player_nick"];
        $this->player = new UserProfile($this->player_id, self::$NeededColumList);
        if($this->player->SuccessInit() === true)
        {
            //$this->player->id = -1;
            $this->player->PermLvl->AdminLvl[] = 0;
            $this->player->LastLoginName = $this->player_nick;
        }

        $this->admin_ip = $input["admin_ip"];
        $this->admin_id = $input["admin_id"];
        $this->admin_nick = $input["admin_nick"];
        $this->admin = new UserProfile($this->admin_id, self::$NeededColumList);
        if($this->admin->SuccessInit() === false)
        {
            //$this->player->id = -1;
            $this->player->PermLvl->AdminLvl[] = 0;
            $this->player->LastLoginName = $this->player_nick;
        }

        $this->reason = $input["ban_reason"];
        $this->created = $input["ban_created"];
        $this->length = $input["ban_length"];
        $this->kicked_count = $input["ban_kicks"];
        $this->expired = $input["expired"];
        $this->UID = $input["UID"];
        $this->UName = $input["UName"];
        $this->modified = $input["modified"];
        $this->isNew = $input["isNew"];
        $this->ForbiddenUnban = $input["ForbiddenUnban"];
        $this->unban_uuid = $input["unban_uuid"];
        $this->uuid_created = $input["uuid_created"];
        $this->uuid_used = $input["uuid_used"];
    }

    function Status()
    {
        $ret = "<span class='label ".Config::$statuses[$this->expired]->style."' style='float: left; margin-right: 5px;'>".Config::$statuses[$this->expired]->name."</span>";
        if($this->modified > 0)
            $ret .= "<span class='label label-warning' style='float: left; margin-right: 5px;'>Módosított</span>";
        
        $ret .= ($this->expired == 2 ? ("<div style='float: left;'> ".htmlspecialchars($this->UName ?? '', ENT_QUOTES)."</div>") : "");
        return $ret;
    }

    function display_line($varibles = array())
    {
        global $lang;
        if (isset($_SESSION['account'])) {
            $userProfile = unserialize($_SESSION['account']);
            $userId = $userProfile->id ?? 'Ismeretlen ID';
        } else {
            $userProfile = null;
        }
        global $sql;
        if (isset($userProfile)) {
            $queryLoggedInUser = "
                SELECT `AdminLvL1`
                FROM `herboy_regsystem`
                WHERE `id` = $userId
                LIMIT 1";
            
            $resultLoggedInUser = $sql->query($queryLoggedInUser);
            if ($resultLoggedInUser) {
                $loggedInUserData = mysqli_fetch_assoc($resultLoggedInUser);
                $loggedInAdminLvL = intval($loggedInUserData['AdminLvL1']);
            }
        }
    
        $isAdmin = isset($userProfile->PermLvl) && $userProfile->PermLvl->isAdmin();
        $date = date('Y/m/d H:i:s', $this->created);
        
        // Determine the ban expiration date
        $bandate = $this->length == 0 ? $lang['never'] : date('Y/m/d H:i:s', $this->created + $this->length * 60);
        $displayID = $this->player_id == "Unknown" ? self::CensorIP($this->player_ip) : $this->player_id;
    
        // Calculate the three months ago timestamp
        $threeMonthsAgo = strtotime('-3 months');
        $isOldBan = ($this->created < $threeMonthsAgo) && ($this->expired > 0);
    
        // Determine the row class
        $rowClass = "tr_all " . ($isOldBan ? "tr_old" : ($this->expired == 0 ? "tr_banned" : "tr_normal"));
        
        // Output the table row with the calculated class
        echo "<tr class='$rowClass' onclick=\"show_tr('".$this->bid."', this)\">";
    
        if (empty($varibles)) {
            echo "<td>#".$this->bid."</td>";
            echo "<td>".$this->player->NameCard("float: left;")."</td>";
            echo "<td>".$displayID."</td>";
            echo "<td>".$date."</td>";
            echo "<td>".$bandate."</td>";
            echo "<td>".$this->reason."</td>";
            echo "<td>".$this->admin->NameCard("float: left;")."</td>";
            echo "<td>".$this->Status()."</td>";
        } else {
            for ($i = 0; $i < sizeof($varibles); $i++) { 
                switch ($varibles[$i]) {
                    case 'bid':
                        echo "<td>#".$this->bid."</td>";
                        break;
                    case 'player':
                        echo "<td>".$this->player->NameCard("float: left;")."</td>";
                        break;
                    case 'identy':
                        echo "<td>".$displayID."</td>";
                        break;
                    case 'createdate':
                        echo "<td>".$date."</td>";
                        break;
                    case 'expiredate':
                        echo "<td>".$bandate."</td>";
                        break;
                    case 'reason':
                        echo "<td>".$this->reason."</td>";
                        break;
                    case 'admin':
                        echo "<td>".$this->admin->NameCard("float: left;")."</td>";
                        break;
                    case 'status':
                        echo "<td>".$this->Status()."</td>";
                        break;
                    default:
                        Utils::php_error($this, "Unknown variable in variables[$i]: \"".$varibles[$i]."\"");
                        break;
                }
            }
        }

        

        echo "</tr>";
        echo "<tr id='".$this->bid."'>";
        echo "<td align='center' colspan='8' style='width: fit-content; margin: 0px;padding: 0px;'>";
            echo "<div id='c".$this->bid."' class='div_hideOnLoad' style='width: 100%; overflow: hidden; display: none'>";
                echo "<div style='width: 100%; float: left; padding-top: 10px;'>";
                    echo "<table border='0' cellspacing='0' cellpadding='0'>";
                    if($this->expired > 0) {
                        echo "<tr style='background-color: rgba(0,255,36,0.1);'>";
                    } else {
                        echo "<tr style='background-color: rgb(255 2 2 / 23%);'>";
                    }
                    echo "<td style='padding: 5px;' width='150'>" . $lang['ban_details'] . "</td>";
                            echo "<td align='right' style='padding: 5px;'>";

                            if ($isAdmin) {
                                if ($this->expired == 0) {
                                    // Admin buttons logic
                                    if (
                                        in_array($loggedInAdminLvL, [1, 2]) 
                                        || ($loggedInAdminLvL == 3 && in_array($this->BannedByAdminPerm, [3, 4])) 
                                        || ($loggedInAdminLvL == 4 && $this->BannedByAdminPerm == 4)
                                    ) {                             

                                // If the ban is not expired, show all three buttons
                                // Feloldás button
                                echo "<button class='btn btn-xs btn-danger' 
                                style='pointer-events: auto; color: black; border-radius: 2px; float: right; margin-left: 10px; margin-bottom: 0px; padding: 0px 10px;' 
                                onclick='handleUnbanButtonClick(".$this->bid.")'>
                                <i class='bi bi-check-square' style='margin-right: 3px;'></i> Feloldás 
                                <i class='bi bi-check-square' style='margin-left: 3px;'></i>
                            </button>";
                            
                                // Módosítás button
                                echo "<button class='btn btn-xs btn-warning change-ban-btn' 
                                          style='pointer-events: auto; color: black; border-radius: 2px; float: right; margin-left: 10px; margin-bottom: 0px; padding: 0px 10px;' 
                                          data-ban-id='".htmlspecialchars($this->bid, ENT_QUOTES, 'UTF-8')."' 
                                          data-player-nick='".htmlspecialchars(isset($this->player->LastLoginName) ? $this->player->LastLoginName : '', ENT_QUOTES, 'UTF-8')."' 
                                          data-steamid='".htmlspecialchars($this->player_id, ENT_QUOTES, 'UTF-8')."' 
                                          data-ban-created='".htmlspecialchars(date('Y/m/d H:i:s', $this->created), ENT_QUOTES, 'UTF-8')."' 
                                          data-ban-length='".htmlspecialchars($this->length, ENT_QUOTES, 'UTF-8')."' 
                                          data-ban-expiry='".htmlspecialchars($bandate, ENT_QUOTES, 'UTF-8')."' 
                                          data-ban-reason='".htmlspecialchars($this->reason, ENT_QUOTES, 'UTF-8')."' 
                                          data-admin-name-card='".htmlspecialchars($this->admin->NameCard("float: left;"), ENT_QUOTES, 'UTF-8')."' 
                                          onclick='handleChangeBanButtonClick(this)'>
                                          <i class='bi bi-card-text' style='margin-right: 3px;'></i> Módosítás 
                                          <i class='bi bi-card-text' style='margin-left: 3px;'></i>
                                      </button>";


                            }
                        }
                    }  
                                                        // Továbbiak button
                                                        echo "<button class='btn btn-xs btn-success about-ban-btn' 
                                                        style='pointer-events: auto; color: black; border-radius: 2px; float: right; margin-left: 10px; margin-bottom: 0px; padding: 0px 10px;' 
                                                        data-ban-id='".$this->bid."'>
                                                        <i class='bi bi-info-square' style='margin-right: 3px;'></i> Továbbiak 
                                                        <i class='bi bi-info-square' style='margin-left: 3px;'></i>
                                                    </button>";
                            
                
                                echo "<tr>";
                                    echo "<td class='content_td' style='padding: 5px;border-right: 1px solid rgba(0,255,36,.1);'>".$lang['banID']."</td>";
                                    echo "<td class='content_td' style='padding: 5px;'>#".$this->bid."</td>";
                                echo "</tr>";
                                echo "<tr>";
                                    echo "<td class='content_td' style='padding: 5px;border-right: 1px solid rgba(0,255,36,.1);'>".$lang['name']."</td>";
                                    echo "<td class='content_td' style='padding: 5px;'>".$this->player->NameCard("float: left;")."</td>";
                                echo "</tr>";
                                    echo "<td class='content_td' style='padding: 5px;border-right: 1px solid rgba(0,255,36,.1);'>".$lang['steamID']."</td>";
                                    echo "<td class='content_td' style='padding: 5px;'>".$displayID."</td>";
                                echo "<tr>";
                                    echo "<td class='content_td' style='padding: 5px;border-right: 1px solid rgba(0,255,36,.1);'>".$lang['timestamp']."</td>";
                                    echo "<td class='content_td' style='padding: 5px;'>".$date."</td>";
                                echo "</tr>";
                                echo "<tr>";
                                    echo "<td class='content_td' style='padding: 5px;border-right: 1px solid rgba(0,255,36,.1);'>".$lang['expired']."</td>";
                                    echo "<td class='content_td' style='padding: 5px;'>".$bandate."</td>";
                                echo "</tr>";
                                echo "<tr>";
                                    echo "<td class='content_td' style='padding: 5px;border-right: 1px solid rgba(0,255,36,.1);'>".$lang['kicks_since_ban']."</td>";
                                    echo "<td class='content_td' style='padding: 5px;'>".$this->kicked_count."</td>";
                                echo "</tr>";
                                echo "<tr>";
                                    echo "<td class='content_td' style='padding: 5px;border-right: 1px solid rgba(0,255,36,.1);'>".$lang['reason']."</td>";
                                    echo "<td class='content_td' style='padding: 5px;'>".$this->reason."</td>";
                                echo "</tr>";
                                echo "<tr>";
                                    echo "<td class='content_td' style='padding: 5px;border-right: 1px solid rgba(0,255,36,.1);'>".$lang['admin_name2']."</td>";
                                    echo "<td class='content_td' style='padding: 5px;'>".$this->admin->NameCard("float: left;")."</td>";
                                echo "</tr>";
                            echo "</td>";
                        echo "</tr>";
                    echo "</table>";
                echo "</div>";
            echo "</div>";
        echo "</td>";
    }
}


class BanByData {

    public static $NeededColumList = array(
        'id',
        'LastLoginName',
        'AdminLvL1'
    );

    public $bid;

    public $player_ip;
    public $player_id;
    public $player_nick;
    public $player;

    public $admin_ip;
    public $admin_id;
    public $admin_nick;
    public $admin;
    
    public $reason;
    public $created;
    public $length;
    public $kicked_count;
    public $expired;
    public $UID;
    public $UName;
    public $modified;
    public $isNew;
    public $ForbiddenUnban;
    public $unban_uuid;
    public $uuid_created;
    public $uuid_used;

    public $BannedByAdminPerm;

    function __construct($input) //query row or bid
    {
        if(is_numeric($input))
        {
            global $sql;
            $input = $sql->select_row(Config::$t_AmxBan_name, null, "`bid`=".$bid);
        }

        if(!is_array($input))
        {
            Utils::php_error($this, "Invalid var type:\"".gettype($input)."\"");
            return;
        }

        
        $this->bid = $input["bid"];
        $this->BannedByAdminPerm = $input["BannedByAdminPerm"];

        $this->player_ip = $input["player_ip"];
        $this->player_id = $input["player_id"];
        $this->player_nick = $input["player_nick"];
        $this->player = new UserProfile($this->player_id, self::$NeededColumList);
        if($this->player->SuccessInit() === true)
        {
            //$this->player->id = -1;
            $this->player->PermLvl->AdminLvl[] = 0;
            $this->player->LastLoginName = $this->player_nick;
        }
    

        $this->admin_ip = $input["admin_ip"];
        $this->admin_id = $input["admin_id"];
        $this->admin_nick = $input["admin_nick"];
        $this->admin = new UserProfile($this->admin_id, self::$NeededColumList);
        if($this->admin->SuccessInit() === false)
        {
            $this->player->id = -1;
            $this->player->PermLvl->AdminLvl[] = 0;
            $this->player->LastLoginName = $this->player_nick;
        }

        $this->reason = $input["ban_reason"];
        $this->created = $input["ban_created"];
        $this->length = $input["ban_length"];
        $this->kicked_count = $input["ban_kicks"];
        $this->expired = $input["expired"];
        $this->UID = $input["UID"];
        $this->UName = $input["UName"];
        $this->modified = $input["modified"];
        $this->isNew = $input["isNew"];
        $this->ForbiddenUnban = $input["ForbiddenUnban"];
        $this->unban_uuid = $input["unban_uuid"];
        $this->uuid_created = $input["uuid_created"];
        $this->uuid_used = $input["uuid_used"];

    }

    function Status()
    {
        $ret = "<span class='label ".Config::$statuses[$this->expired]->style."' style='float: left; margin-right: 5px;'>".Config::$statuses[$this->expired]->name."</span>";
        if($this->modified > 0)
            $ret .= "<span class='label label-warning' style='float: left; margin-right: 5px;'>Módosított</span>";
        
        $ret .= ($this->expired == 2 ? ("<div style='float: left;'> ".htmlspecialchars($this->UName ?? '', ENT_QUOTES)."</div>") : "");
        return $ret;
    }

    function display_line($varibles = array())
    {   
        global $lang; 
        if (isset($_SESSION['account'])) {
            $userProfile = unserialize($_SESSION['account']);
            $userId = $userProfile->id ?? 'Ismeretlen ID';
        } else {
            $userProfile = null;
        }
        global $sql;
        if (isset($userProfile)) {
            $queryLoggedInUser = "
                SELECT `AdminLvL1`
                FROM `herboy_regsystem`
                WHERE `id` = $userId
                LIMIT 1";
            
            $resultLoggedInUser = $sql->query($queryLoggedInUser);
            if ($resultLoggedInUser) {
                $loggedInUserData = mysqli_fetch_assoc($resultLoggedInUser);
                $loggedInAdminLvL = intval($loggedInUserData['AdminLvL1']);
            }
        }
    
        $isAdmin = isset($userProfile->PermLvl) && $userProfile->PermLvl->isAdmin();
        $date = date('Y/m/d H:i:s', $this->created);
    
        // Determine the ban expiration date
        $bandate = $this->length == 0 ? $lang['never'] : date('Y/m/d H:i:s', $this->created + $this->length * 60);
        $displayID = $this->player_id == "Unknown" ? self::CensorIP($this->player_ip) : $this->player_id;
    
        // Calculate the three months ago timestamp
        $threeMonthsAgo = strtotime('-3 months');
        $isOldBan = ($this->created < $threeMonthsAgo) && ($this->expired > 0);
    
        // Determine the row class
        $rowClass = "tr_all " . ($isOldBan ? "tr_old" : ($this->expired == 0 ? "tr_banned" : "tr_normal"));
        
        // Output the table row with the calculated class
        echo "<tr class='$rowClass' onclick=\"show_tr('".$this->bid."', this)\">";
    
        if (empty($varibles)) {
            echo "<td>#".$this->bid."</td>";
            echo "<td>".$this->player->NameCard("float: left;")."</td>";
            echo "<td>".$displayID."</td>";
            echo "<td>".$date."</td>";
            echo "<td>".$bandate."</td>";
            echo "<td>".$this->reason."</td>";
            echo "<td>".$this->admin->NameCard("float: left;")."</td>";
            echo "<td>".$this->Status()."</td>";
        } else {
            for ($i = 0; $i < sizeof($varibles); $i++) { 
                switch ($varibles[$i]) {
                    case 'bid':
                        echo "<td>#".$this->bid."</td>";
                        break;
                    case 'player':
                        echo "<td>".$this->player->NameCard("float: left;")."</td>";
                        break;
                    case 'identy':
                        echo "<td>".$displayID."</td>";
                        break;
                    case 'createdate':
                        echo "<td>".$date."</td>";
                        break;
                    case 'expiredate':
                        echo "<td>".$bandate."</td>";
                        break;
                    case 'reason':
                        echo "<td>".$this->reason."</td>";
                        break;
                    case 'admin':
                        echo "<td>".$this->admin->NameCard("float: left;")."</td>";
                        break;
                    case 'status':
                        echo "<td>".$this->Status()."</td>";
                        break;
                    default:
                        Utils::php_error($this, "Unknown variable in variables[$i]: \"".$varibles[$i]."\"");
                        break;
                }
            }
        }
echo "</tr>";
echo "<tr id='".$this->bid."'>";
echo "<td align='center' colspan='8' style='width: fit-content; margin: 0px;padding: 0px;'>";
    echo "<div id='c".$this->bid."' class='div_hideOnLoad' style='width: 100%; overflow: hidden; display: none'>";
        echo "<div style='width: 100%; float: left; padding-top: 10px;'>";
            echo "<table border='0' cellspacing='0' cellpadding='0'>";

            // Set row color based on expiration status
            if($this->expired > 0) {
                echo "<tr style='background-color: rgba(0,255,36,0.1);'>";
            } else {
                echo "<tr style='background-color: rgb(255 2 2 / 23%);'>";
            }

            // Header text for the details section
            echo "<td style='padding: 5px;' width='150'>".$lang['ban_details']."</td>";
            echo "<td align='right' style='padding: 5px;'>";

            // If the user is an admin, show "Feloldás" and "Módosítás" buttons if the ban is not expired
            if ($isAdmin) {
                if ($this->expired == 0) {
                    // Admin buttons logic
                    if (
                        in_array($loggedInAdminLvL, [1, 2]) 
                        || ($loggedInAdminLvL == 3 && in_array($this->BannedByAdminPerm, [3, 4])) 
                        || ($loggedInAdminLvL == 4 && $this->BannedByAdminPerm == 4)
                    ) { 
                    // Show "Feloldás" button
                    echo "<button class='btn btn-xs btn-danger' 
                              style='pointer-events: auto; color: black; border-radius: 2px; float: right; margin-left: 10px; margin-bottom: 0px; padding: 0px 10px;' 
                              onclick='handleUnbanButtonClick(".$this->bid.")'>
                              <i class='bi bi-check-square' style='margin-right: 3px;'></i> Feloldás 
                              <i class='bi bi-check-square' style='margin-left: 3px;'></i>
                          </button>";

                    // Show "Módosítás" button
                    echo "<button class='btn btn-xs btn-warning change-ban-btn' 
                              style='pointer-events: auto; color: black; border-radius: 2px; float: right; margin-left: 10px; margin-bottom: 0px; padding: 0px 10px;' 
                              data-ban-id='".htmlspecialchars($this->bid, ENT_QUOTES, 'UTF-8')."' 
                              data-player-nick='".htmlspecialchars($this->player->LastLoginName ?? '', ENT_QUOTES, 'UTF-8')."'
                              data-steamid='".htmlspecialchars($this->player_id, ENT_QUOTES, 'UTF-8')."' 
                              data-ban-created='".htmlspecialchars(date('Y/m/d H:i:s', $this->created), ENT_QUOTES, 'UTF-8')."' 
                              data-ban-length='".htmlspecialchars($this->length, ENT_QUOTES, 'UTF-8')."' 
                              data-ban-expiry='".htmlspecialchars($bandate, ENT_QUOTES, 'UTF-8')."' 
                              data-ban-reason='".htmlspecialchars($this->reason, ENT_QUOTES, 'UTF-8')."' 
                              data-admin-name-card='".htmlspecialchars($this->admin->NameCard("float: left;"), ENT_QUOTES, 'UTF-8')."' 
                              onclick='handleChangeBanButtonClick(this)'>
                              <i class='bi bi-card-text' style='margin-right: 3px;'></i> Módosítás 
                              <i class='bi bi-card-text' style='margin-left: 3px;'></i>
                          </button>";
                }
            }
        }  
            // Always show "Továbbiak" button regardless of admin status
            echo "<button class='btn btn-xs btn-success about-ban-btn' 
                      style='pointer-events: auto; color: black; border-radius: 2px; float: right; margin-left: 10px; margin-bottom: 0px; padding: 0px 10px;' 
                      data-ban-id='".$this->bid."'>
                      <i class='bi bi-info-square' style='margin-right: 3px;'></i> Továbbiak 
                      <i class='bi bi-info-square' style='margin-left: 3px;'></i>
                  </button>";
            echo "</td>";
            echo "</tr>";

            // Table rows for ban details
            echo "<tr>";
            echo "<td class='content_td' style='padding: 5px;border-right: 1px solid rgba(0,255,36,.1);'>" . $lang['banID'] ."</td>";
            echo "<td class='content_td' style='padding: 5px;'>#".$this->bid."</td>";
        echo "</tr>";
        echo "<tr>";
            echo "<td class='content_td' style='padding: 5px;border-right: 1px solid rgba(0,255,36,.1);'>".$lang['name']."</td>";
            echo "<td class='content_td' style='padding: 5px;'>".$this->player->NameCard("float: left;")."</td>";
        echo "</tr>";
            echo "<td class='content_td' style='padding: 5px;border-right: 1px solid rgba(0,255,36,.1);'>".$lang['steamID']."</td>";
            echo "<td class='content_td' style='padding: 5px;'>".$displayID."</td>";
        echo "<tr>";
            echo "<td class='content_td' style='padding: 5px;border-right: 1px solid rgba(0,255,36,.1);'>".$lang['timestamp']."</td>";
            echo "<td class='content_td' style='padding: 5px;'>".$date."</td>";
        echo "</tr>";
        echo "<tr>";
            echo "<td class='content_td' style='padding: 5px;border-right: 1px solid rgba(0,255,36,.1);'>".$lang['expired']."</td>";
            echo "<td class='content_td' style='padding: 5px;'>".$bandate."</td>";
        echo "</tr>";
        echo "<tr>";
            echo "<td class='content_td' style='padding: 5px;border-right: 1px solid rgba(0,255,36,.1);'>".$lang['kicks_since_ban']."</td>";
            echo "<td class='content_td' style='padding: 5px;'>".$this->kicked_count."</td>";
        echo "</tr>";
        echo "<tr>";
            echo "<td class='content_td' style='padding: 5px;border-right: 1px solid rgba(0,255,36,.1);'>".$lang['reason']."</td>";
            echo "<td class='content_td' style='padding: 5px;'>".$this->reason."</td>";
        echo "</tr>";
        echo "<tr>";
            echo "<td class='content_td' style='padding: 5px;border-right: 1px solid rgba(0,255,36,.1);'>".$lang['admin_name2']."</td>";
            echo "<td class='content_td' style='padding: 5px;'>".$this->admin->NameCard("float: left;")."</td>";
            echo "</tr>";

            echo "</td>";
        echo "</tr>";
    echo "</table>";
    echo "</div>";
echo "</div>";
echo "</td>";
        }
    }


    class ScanData {
        public static $NeededColumList = array(
            'id',
            'LastLoginName',
            'AdminLvL1'

        );
    
        public $id;            // Scan ID
        public $player_id;     // ID of the player scanned
        public $player_name;   // Name of the player scanned
        public $admin_id;      // ID of the admin who performed the scan
        public $admin_name;    // Name of the admin who performed the scan
        public $time;          // Time of the scan
        public $judgetid;      // Assuming this exists in your database
    
        public $player;        // UserProfile object for the player
        public $admin;         // UserProfile object for the admin
    
        function __construct($input) // query row or ID
        {
            global $sql;
    
            if (is_numeric($input)) {
                // Use prepared statement to prevent SQL injection
                $query = "SELECT * FROM `" . Config::$t_AmxScan_name . "` WHERE `id` = ?";
                $stmt = $sql->prepare($query);
                if ($stmt) {
                    $stmt->bind_param('i', $input); // Bind the input as an integer
                    $stmt->execute();
                    $result = $stmt->get_result();
                    $input = $result->fetch_assoc();
                    $stmt->close();
                } else {
                    Utils::php_error($this, "Error preparing statement: " . htmlspecialchars($sql->mysqli->error));
                    return;
                }
            }
    
            if (!is_array($input)) {
                Utils::php_error($this, "Invalid var type:\"" . gettype($input) . "\"");
                return;
            }
    
            $this->id = $input["id"];
            $this->player_id = $input["player_id"];
            $this->player_name = $input["player_name"];
            $this->admin_id = $input["admin_id"];
            $this->admin_name = $input["admin_name"];
            $this->time = $input["time"]; // Assuming this is a timestamp
            $this->judgetid = $input["judgetid"];
    
            // Initialize player UserProfile
            $this->player = new UserProfile($this->player_id, self::$NeededColumList);
            if ($this->player->SuccessInit() === true) {
                //$this->player->id = -1;
                $this->player->PermLvl->AdminLvl[] = 0; // Default to no permission level
                $this->player->LastLoginName = $this->player_name; // Set name for unknown users
            }
    
            // Initialize admin UserProfile
            $this->admin = new UserProfile($this->admin_id, self::$NeededColumList);
            if ($this->admin->SuccessInit() === false) {
                $this->admin->id = -1;
                $this->admin->PermLvl->AdminLvl[] = 0; // Default to no permission level
                $this->admin->LastLoginName = $this->admin_name; // Set name for unknown admins
            }
        }
    
        function Status()
        {
            global $lang;
            switch ($this->judgetid) {
                case 1:
                    return "<span class='label label-success' style='float: left; margin-right: 5px;'>".$lang['scan_clear']."</span>";
                case 2:
                    return "<span class='label label-warning' style='float: left; margin-right: 5px;'>".$lang['scan_red_model']."</span>";
                case 3:
                    return "<span class='label label-danger' style='float: left; margin-right: 5px;'>".$lang['scan_left']."</span>";
                case 5:
                    return "<span class='label label-danger' style='float: left; margin-right: 5px;'>".$lang['scan_refused']."</span>";
                case 6:
                    return "<span class='label label-danger' style='float: left; margin-right: 5px;'>.".$lang['scan_cheated']."</span>";
                default:
                    return "<span class='label label-default' style='float: left; margin-right: 5px;'>Unknown Status</span>"; // Handle unexpected values
            }
        }
    

        function display_line($variables = array())
        {
            $date = date('Y/m/d H:i:s', $this->time);
    
            if (empty($variables)) {
                echo "<td>#".$this->id."</td>";
                echo "<td>".$this->player->NameCard("float: left;")."</td>";
                echo "<td>".$this->admin->NameCard("float: left;")."</td>";
                echo "<td>".$time."</td>";
            } else {
                for ($i = 0; $i < sizeof($variables); $i++) {
                    switch ($variables[$i]) {
                        case 'id': {
                            echo "<td>#".$this->id."</td>";
                            break;
                        }
                        case 'player': {
                            echo "<td>".$this->player->NameCard("float: left;")."</td>";
                            break;
                        }
                        case 'admin': {
                            echo "<td>".$this->admin->NameCard("float: left;")."</td>";
                            break;
                        }
                        case 'createdate': {
                            echo "<td>".$date."</td>";
                            break;
                        }
                        case 'status':{
                            echo "<td>".$this->Status()."</td>";
                            break;
                        }
                        default: {
                            Utils::php_error($this, "Unknown variable in variables[$i]: \"".$variables[$i]."\"");
                            break;
                        }
                    }
                }
            }
            echo "</tr>";
        }
    }
    
    

class MuteData {

    public static $NeededColumList = array(
        'id',
        'LastLoginName',
        'AdminLvL1'
    );

    public $bid;

    public $player_ip;
    public $player_id;
    public $player_nick;
    public $player;

    public $admin_ip;
    public $admin_id;
    public $admin_nick;
    public $admin;
    
    public $reason;
    public $created;
    public $mute_type;
    public $length;
    public $kicked_count;
    public $expired;
    public $UID;
    public $UName;
    public $modified;
    public $isNew;

    public $MutedByAdminPerm;

    function __construct($input) //query row or bid
    {
        if(is_numeric($input))
        {
            global $sql;
            $input = $sql->select_row(Config::$t_AmxMute_name, null, "`bid`=".$bid);
        }

        if(!is_array($input))
        {
            Utils::php_error($this, "Invalid var type:\"".gettype($input)."\"");
            return;
        }


        $this->bid = $input["bid"];

        $this->player_ip = $input["player_ip"];
        $this->player_id = $input["player_id"];
        $this->player_nick = $input["player_nick"];
        $this->player = new UserProfile($this->player_id, self::$NeededColumList);
        if($this->player->SuccessInit() === false)
        {
            $this->player->id = -1;
            $this->player->PermLvl->AdminLvl[] = 0;
            $this->player->LastLoginName = $this->player_nick;
        }

        $this->admin_ip = $input["admin_ip"];
        $this->admin_id = $input["admin_id"];
        $this->admin_nick = $input["admin_nick"];
        $this->admin = new UserProfile($this->admin_id, self::$NeededColumList);
        if($this->admin->SuccessInit() === false)
        {
            $this->player->id = -1;
            $this->player->PermLvl->AdminLvl[] = 0;
            $this->player->LastLoginName = $this->player_nick;
        }

        $this->reason = $input["mute_reason"];
        $this->created = $input["mute_created"];
        $this->length = $input["mute_length"];
        $this->mute_type = $input["mute_type"];
        $this->expired = $input["expired"];
        $this->UID = $input["UID"];
        $this->UName = $input["UName"];
        $this->modified = $input["modified"];
        $this->isNew = $input["isNew"];

        $this->MutedByAdminPerm = $input["MutedByAdminPerm"];
    }

    function Status()
    {
        $ret = "<span class='label ".Config::$statuses[$this->expired]->style."' style='float: left; margin-right: 5px;'>".Config::$statuses[$this->expired]->name."</span>";
        if($this->modified > 0)
            $ret .= "<span class='label label-warning' style='float: left; margin-right: 5px;'>Módosított</span>";
        
            $ret .= ($this->expired == 2 ? ("<div style='float: left;'> ".htmlspecialchars($this->UName ?? '', ENT_QUOTES)."</div>") : "");
        return $ret;
    }

    function display_line($varibles = array())
    {
       
           $userProfile = null; 
        if (isset($_SESSION['account'])) {
            $userProfile = unserialize($_SESSION['account']);
            $userId = $userProfile->id ?? 'Ismeretlen ID';
        } else {
            $userProfile = null;
        }
        global $lang;
        global $sql;
        if (isset($userProfile)) {
            $queryLoggedInUser = "
                SELECT `AdminLvL1`
                FROM `herboy_regsystem`
                WHERE `id` = $userId
                LIMIT 1";
            
            $resultLoggedInUser = $sql->query($queryLoggedInUser);
            if ($resultLoggedInUser) {
                $loggedInUserData = mysqli_fetch_assoc($resultLoggedInUser);
                $loggedInAdminLvL = intval($loggedInUserData['AdminLvL1']);
            }
        }
    
        $isAdmin = isset($userProfile->PermLvl) && $userProfile->PermLvl->isAdmin();
        $date = date('Y/m/d H:i:s', $this->created);
        
        // Determine the muted expiration date
        $mutedate = $this->length == 0 ? $lang['never'] : date('Y/m/d H:i:s', $this->created + $this->length * 60);
        $displayID = $this->player_id == "Unknown" ? self::CensorIP($this->player_ip) : $this->player_id;
    
        // Display mute type
        $displayMuteType = "";
        if ($this->mute_type == 3) {
            $displayMuteType = "Voice + Chat";
        } else if ($this->mute_type == 2) {
            $displayMuteType = "Voice";
        } else {
            $displayMuteType = "Chat";
        }
    
        // Calculate the three months ago timestamp
        $threeMonthsAgo = strtotime('-3 months');
        $isOldMute = ($this->created < $threeMonthsAgo) && ($this->expired > 0);
    
        // Determine the row class
        $rowClass = "tr_all " . ($isOldMute ? "tr_old" : ($this->expired == 0 ? "tr_banned" : "tr_normal"));
        
        // Output the table row with the calculated class
        echo "<tr class='$rowClass' onclick=\"show_tr('".$this->bid."', this)\">";
        
        if (empty($varibles)) {
            echo "<td>#".$this->bid."</td>";
            echo "<td>".$this->player->NameCard("float: left;")."</td>";
            echo "<td>".$displayID."</td>";
            echo "<td>".$date."</td>";
            echo "<td>".$mutedate."</td>";
            echo "<td>".$this->reason."</td>";
            echo "<td>".$this->admin->NameCard("float: left;")."</td>";
            echo "<td>".$this->Status()."</td>";
        } else {
            for ($i = 0; $i < sizeof($varibles); $i++) { 
                switch ($varibles[$i]) {
                    case 'bid':
                        echo "<td>#".$this->bid."</td>";
                        break;
                    case 'player':
                        echo "<td>".$this->player->NameCard("float: left;")."</td>";
                        break;
                    case 'identy':
                        echo "<td>".$displayID."</td>";
                        break;
                    case 'createdate':
                        echo "<td>".$date."</td>";
                        break;
                    case 'expiredate':
                        echo "<td>".$mutedate."</td>";
                        break;
                    case 'reason':
                        echo "<td>".$this->reason."</td>";
                        break;
                    case 'admin':
                        echo "<td>".$this->admin->NameCard("float: left;")."</td>";
                        break;
                    case 'status':
                        echo "<td>".$this->Status()."</td>";
                        break;
                    default:
                        Utils::php_error($this, "Unknown variable in variables[$i]: \"".$varibles[$i]."\"");
                        break;
                }
            }
        }
        echo "</tr>";
        echo "<tr id='".$this->bid."'>";
        echo "<td align='center' colspan='8' style='width: fit-content; margin: 0px;padding: 0px;'>";
            echo "<div id='c".$this->bid."' class='div_hideOnLoad' style='width: 100%; overflow: hidden; display: none'>";
                echo "<div style='width: 100%; float: left; padding-top: 10px;'>";
                    echo "<table border='0' cellspacing='0' cellpadding='0'>";
                    if($this->expired > 0) {
                        echo "<tr style='background-color: rgba(0,255,36,0.1);'>";
                     } else {
                        echo "<tr style='background-color: rgb(255 2 2 / 23%);'>";
                     }
                            echo "<td style='padding: 5px;' width='150'>".$lang['mute_details']."</td>";
                            echo "<td align='right' style='padding: 5px;'>";
                            if ($isAdmin) {
                                if ($this->expired == 0) {
                                    // Admin buttons logic
                                    if (
                                        in_array($loggedInAdminLvL, [1, 2]) 
                                        || ($loggedInAdminLvL == 3 && in_array($this->MutedByAdminPerm, [3, 4])) 
                                        || ($loggedInAdminLvL == 4 && $this->MutedByAdminPerm == 4)
                                    ) { 
                          echo "<button class='btn btn-xs btn-danger' 
                           style='pointer-events: auto; color: black; border-radius: 2px; float: right; margin-left: 10px; margin-bottom: 0px; padding: 0px 10px;' 
                           onclick='handleUnMuteButtonClick(".$this->bid.")'>
                          <i class='bi bi-check-square' style='margin-right: 3px;'></i> Feloldás 
                          <i class='bi bi-check-square' style='margin-left: 3px;'></i>
                          </button>";                                
                          echo "<button class='btn btn-xs btn-warning change-mute-btn' 
                          style='pointer-events: auto; color: black; border-radius: 2px; float: right; margin-left: 10px; margin-bottom: 0px; padding: 0px 10px;' 
                          data-mute-id='".htmlspecialchars($this->bid, ENT_QUOTES, 'UTF-8')."' 
                          data-player-nick='".htmlspecialchars(isset($this->player->LastLoginName) ? $this->player->LastLoginName : '', ENT_QUOTES, 'UTF-8')."' 
                          data-steamid='".htmlspecialchars($this->player_id, ENT_QUOTES, 'UTF-8')."' 
                          data-mute-created='".htmlspecialchars(date('Y/m/d H:i:s', $this->created), ENT_QUOTES, 'UTF-8')."' 
                          data-mute-length='".htmlspecialchars($this->length, ENT_QUOTES, 'UTF-8')."' 
                          data-mute-expiry='".htmlspecialchars($mutedate, ENT_QUOTES, 'UTF-8')."' 
                          data-mute-reason='".htmlspecialchars($this->reason, ENT_QUOTES, 'UTF-8')."' 
                          data-admin-name-card='".htmlspecialchars($this->admin->NameCard("float: left;"), ENT_QUOTES, 'UTF-8')."' 
                          onclick='handleChangeMuteButtonClick(this)'>
                          <i class='bi bi-card-text' style='margin-right: 3px;'></i> Módosítás 
                          <i class='bi bi-card-text' style='margin-left: 3px;'></i>
                      </button>";                     
                            }
                        }
                    }
                        echo "<button class='btn btn-xs btn-success about-mute-btn' 
                        style='pointer-events: auto; color: black; border-radius: 2px; float: right; margin-left: 10px; margin-bottom: 0px; padding: 0px 10px;' 
                        data-mute-id='".$this->bid."'>
                        <i class='bi bi-info-square' style='margin-right: 3px;'></i> Továbbiak 
                        <i class='bi bi-info-square' style='margin-left: 3px;'></i>
                      </button>";
                      echo "</td>";
                      echo "</tr>";
                                echo "<tr>";
                                echo "<td class='content_td' style='padding: 5px;border-right: 1px solid rgba(0,255,36,.1);'>".$lang['mute_id']."</td>";
                                echo "<td class='content_td' style='padding: 5px;'>#".$this->bid."</td>";
                            echo "</tr>";
                            echo "<tr>";
                                echo "<td class='content_td' style='padding: 5px;border-right: 1px solid rgba(0,255,36,.1);'>".$lang['name']."</td>";
                                echo "<td class='content_td' style='padding: 5px;'>".$this->player->NameCard("float: left;")."</td>";
                            echo "</tr>";
                                echo "<td class='content_td' style='padding: 5px;border-right: 1px solid rgba(0,255,36,.1);'>".$lang['steamID']."</td>";
                                echo "<td class='content_td' style='padding: 5px;'>".$displayID."</td>";
                            echo "<tr>";
                                echo "<td class='content_td' style='padding: 5px;border-right: 1px solid rgba(0,255,36,.1);'>".$lang['timestamp']."</td>";
                                echo "<td class='content_td' style='padding: 5px;'>".$date."</td>";
                            echo "</tr>";
                            echo "<tr>";
                                echo "<td class='content_td' style='padding: 5px;border-right: 1px solid rgba(0,255,36,.1);'>".$lang['expired']."</td>";
                                echo "<td class='content_td' style='padding: 5px;'>".$mutedate."</td>";
                            echo "</tr>";
                            echo "<tr>";
                                echo "<td class='content_td' style='padding: 5px;border-right: 1px solid rgba(0,255,36,.1);'>".$lang['type']."</td>";
                                echo "<td class='content_td' style='padding: 5px;'>".$displayMuteType."</td>";
                            echo "</tr>";
                            echo "<tr>";
                                echo "<td class='content_td' style='padding: 5px;border-right: 1px solid rgba(0,255,36,.1);'>".$lang['reason']."</td>";
                                echo "<td class='content_td' style='padding: 5px;'>".$this->reason."</td>";
                            echo "</tr>";
                            echo "<tr>";
                                echo "<td class='content_td' style='padding: 5px;border-right: 1px solid rgba(0,255,36,.1);'>".$lang['admin_name2']."</td>";
                                echo "<td class='content_td' style='padding: 5px;'>".$this->admin->NameCard("float: left;")."</td>";
                                echo "</tr>";
                            echo "</td>";
                        echo "</tr>";
                    echo "</table>";
                echo "</div>";
            echo "</div>";
        echo "</td>";
    }

}


class MuteByData {

    public static $NeededColumList = array(
        'id',
        'LastLoginName',
        'AdminLvL1'
    );

    public $bid;

    public $player_ip;
    public $player_id;
    public $player_nick;
    public $player;

    public $admin_ip;
    public $admin_id;
    public $admin_nick;
    public $admin;
    
    public $reason;
    public $created;
    public $length;
    public $mute_type;
    public $kicked_count;
    public $expired;
    public $UID;
    public $UName;
    public $modified;
    public $isNew;

    public $MutedByAdminPerm;

    function __construct($input) //query row or bid
    {
        if(is_numeric($input))
        {
            global $sql;
            $input = $sql->select_row(Config::$t_AmxBan_name, null, "`bid`=".$bid);
        }

        if(!is_array($input))
        {
            Utils::php_error($this, "Invalid var type:\"".gettype($input)."\"");
            return;
        }


        $this->bid = $input["bid"];

        $this->player_ip = $input["player_ip"];
        $this->player_id = $input["player_id"];
        $this->player_nick = $input["player_nick"];
        $this->player = new UserProfile($this->player_id, self::$NeededColumList);
        if($this->player->SuccessInit() === true)
        {
            //$this->player->id = -1;
            $this->player->PermLvl->AdminLvl[] = 0;
            $this->player->LastLoginName = $this->player_nick;
        }

        $this->admin_ip = $input["admin_ip"];
        $this->admin_id = $input["admin_id"];
        $this->admin_nick = $input["admin_nick"];
        $this->admin = new UserProfile($this->admin_id, self::$NeededColumList);
        if($this->admin->SuccessInit() === false)
        {
            $this->player->id = -1;
            $this->player->PermLvl->AdminLvl[] = 0;
            $this->player->LastLoginName = $this->player_nick;
        }

        $this->reason = $input["mute_reason"];
        $this->created = $input["mute_created"];
        $this->length = $input["mute_length"];
        $this->mute_type = $input["mute_type"];
        $this->expired = $input["expired"];
        $this->UID = $input["UID"];
        $this->UName = $input["UName"];
        $this->modified = $input["modified"];
        $this->isNew = $input["isNew"];

        $this->MutedByAdminPerm = $input["MutedByAdminPerm"];
    }

    function Status()
    {
        $ret = "<span class='label ".Config::$statuses[$this->expired]->style."' style='float: left; margin-right: 5px;'>".Config::$statuses[$this->expired]->name."</span>";
        if($this->modified > 0)
            $ret .= "<span class='label label-warning' style='float: left; margin-right: 5px;'>Módosított</span>";
        
        $ret .= ($this->expired == 2 ? ("<div style='float: left;'> ".htmlspecialchars($this->UName ?? '', ENT_QUOTES)."</div>") : "");
        return $ret;
    }

    function display_line($varibles = array())
    {    
        if (isset($_SESSION['account'])) {
            $userProfile = unserialize($_SESSION['account']);
            $userId = $userProfile->id ?? 'Ismeretlen ID';
        } else {
            $userProfile = null;
        }
        global $lang;
        global $sql;
        if (isset($userProfile)) {
            $queryLoggedInUser = "
                SELECT `AdminLvL1`
                FROM `herboy_regsystem`
                WHERE `id` = $userId
                LIMIT 1";
            
            $resultLoggedInUser = $sql->query($queryLoggedInUser);
            if ($resultLoggedInUser) {
                $loggedInUserData = mysqli_fetch_assoc($resultLoggedInUser);
                $loggedInAdminLvL = intval($loggedInUserData['AdminLvL1']);
            }
        }
        $isAdmin = isset($userProfile->PermLvl) && $userProfile->PermLvl->isAdmin();
        $date = date('Y/m/d H:i:s', $this->created);
        
        if ($this->length == 0) {
            $mutedate = $lang['never'];
        } else {
            $mutedate = date('Y/m/d H:i:s', $this->created + $this->length * 60);
        }
        
        $displayID = $this->player_id == "Unknown" ? self::CensorIP($this->player_ip) : $this->player_id;
    
        $displayMuteType = "";
        if ($this->mute_type == 3) {
            $displayMuteType = "Voice + Chat";
        } else if ($this->mute_type == 2) {
            $displayMuteType = "Voice";
        } else {
            $displayMuteType = "Chat";
        }
    
        // Check if the mute is older than 3 months and expired is 0
        $threeMonthsAgo = strtotime('-3 months');
        $isOld = ($this->created < $threeMonthsAgo) && ($this->expired > 0);
        
        // Add 'tr_old' class if the mute is old
        $rowClass = $isOld ? "tr_old" : ($this->expired == 0 ? "tr_banned" : "tr_normal");
        
        echo "<tr class='tr_all $rowClass' onclick=\"show_tr('".$this->bid."', this)\">";
        if (empty($varibles)) {
            echo "<td>#".$this->bid."</td>";
            echo "<td>".$this->player->NameCard("float: left;")."</td>";
            echo "<td>".$displayID."</td>";
            echo "<td>".$date."</td>";
            echo "<td>".$mutedate."</td>";
            echo "<td>".$this->reason."</td>";
            echo "<td>".$this->admin->NameCard("float: left;")."</td>";
            echo "<td>".$this->Status()."</td>";
        } else {
            for ($i = 0; $i < sizeof($varibles); $i++) { 
                switch ($varibles[$i]) {
                    case 'bid':
                        echo "<td>#".$this->bid."</td>";
                        break;
                    case 'player':
                        echo "<td>".$this->player->NameCard("float: left;")."</td>";
                        break;
                    case 'identy':
                        echo "<td>".$displayID."</td>";
                        break;
                    case 'createdate':
                        echo "<td>".$date."</td>";
                        break;
                    case 'expiredate':
                        echo "<td>".$mutedate."</td>";
                        break;
                    case 'reason':
                        echo "<td>".$this->reason."</td>";
                        break;
                    case 'admin':
                        echo "<td>".$this->admin->NameCard("float: left;")."</td>";
                        break;
                    case 'status':
                        echo "<td>".$this->Status()."</td>";
                        break;
                    default:
                        Utils::php_error($this, "Unknown varible in varibles[$i]: \"".$varibles[$i]."\"");
                        break;
                }
            }
        }
    
        echo "</tr>";
        echo "<tr id='".$this->bid."'>";
        echo "<td align='center' colspan='8' style='width: fit-content; margin: 0px;padding: 0px;'>";
            echo "<div id='c".$this->bid."' class='div_hideOnLoad' style='width: 100%; overflow: hidden; display: none'>";
                echo "<div style='width: 100%; float: left; padding-top: 10px;'>";
                    echo "<table border='0' cellspacing='0' cellpadding='0'>";
                    if($this->expired > 0) {
                    echo "<tr style='background-color: rgba(0,255,36,0.1);'>";
                    } else {
                    echo "<tr style='background-color: rgb(255 2 2 / 23%);'>";
                    }
                        echo "<td style='padding: 5px;' width='150'>".$lang['mute_details']."</td>";
                        echo "<td align='right' style='padding: 5px;'>";
                        if ($isAdmin) {
                            if ($this->expired == 0) {
                                // Admin buttons logic
                                if (
                                    in_array($loggedInAdminLvL, [1, 2]) 
                                    || ($loggedInAdminLvL == 3 && in_array($this->MutedByAdminPerm, [3, 4])) 
                                    || ($loggedInAdminLvL == 4 && $this->MutedByAdminPerm == 4)
                                ) { 
                      echo "<button class='btn btn-xs btn-danger' 
                       style='pointer-events: auto; color: black; border-radius: 2px; float: right; margin-left: 10px; margin-bottom: 0px; padding: 0px 10px;' 
                       onclick='handleUnMuteButtonClick(".$this->bid.")'>
                      <i class='bi bi-check-square' style='margin-right: 3px;'></i> Feloldás 
                      <i class='bi bi-check-square' style='margin-left: 3px;'></i>
                      </button>";                                
                      echo "<button class='btn btn-xs btn-warning change-mute-btn' 
                      style='pointer-events: auto; color: black; border-radius: 2px; float: right; margin-left: 10px; margin-bottom: 0px; padding: 0px 10px;' 
                      data-mute-id='".htmlspecialchars($this->bid, ENT_QUOTES, 'UTF-8')."' 
                      data-player-nick='".htmlspecialchars(isset($this->player->LastLoginName) ? $this->player->LastLoginName : '', ENT_QUOTES, 'UTF-8')."' 
                      data-steamid='".htmlspecialchars($this->player_id, ENT_QUOTES, 'UTF-8')."' 
                      data-mute-created='".htmlspecialchars(date('Y/m/d H:i:s', $this->created), ENT_QUOTES, 'UTF-8')."' 
                      data-mute-length='".htmlspecialchars($this->length, ENT_QUOTES, 'UTF-8')."' 
                      data-mute-expiry='".htmlspecialchars($mutedate, ENT_QUOTES, 'UTF-8')."' 
                      data-mute-reason='".htmlspecialchars($this->reason, ENT_QUOTES, 'UTF-8')."' 
                      data-admin-name-card='".htmlspecialchars($this->admin->NameCard("float: left;"), ENT_QUOTES, 'UTF-8')."' 
                      onclick='handleChangeMuteButtonClick(this)'>
                      <i class='bi bi-card-text' style='margin-right: 3px;'></i> Módosítás 
                      <i class='bi bi-card-text' style='margin-left: 3px;'></i>
                  </button>";                    
                        }
                    }
                }
                    echo "<button class='btn btn-xs btn-success about-mute-btn' 
                    style='pointer-events: auto; color: black; border-radius: 2px; float: right; margin-left: 10px; margin-bottom: 0px; padding: 0px 10px;' 
                    data-mute-id='".$this->bid."'>
                    <i class='bi bi-info-square' style='margin-right: 3px;'></i> Továbbiak 
                    <i class='bi bi-info-square' style='margin-left: 3px;'></i>
                  </button>";
                  echo "</td>";
                  echo "</tr>";
                                echo "<tr>";
                                    echo "<td class='content_td' style='padding: 5px;border-right: 1px solid rgba(0,255,36,.1);'>".$lang['mute_id']."</td>";
                                    echo "<td class='content_td' style='padding: 5px;'>#".$this->bid."</td>";
                                echo "</tr>";
                                echo "<tr>";
                                    echo "<td class='content_td' style='padding: 5px;border-right: 1px solid rgba(0,255,36,.1);'>".$lang['name']."</td>";
                                    echo "<td class='content_td' style='padding: 5px;'>".$this->player->NameCard("float: left;")."</td>";
                                echo "</tr>";
                                    echo "<td class='content_td' style='padding: 5px;border-right: 1px solid rgba(0,255,36,.1);'>".$lang['steamID']."</td>";
                                    echo "<td class='content_td' style='padding: 5px;'>".$displayID."</td>";
                                echo "<tr>";
                                    echo "<td class='content_td' style='padding: 5px;border-right: 1px solid rgba(0,255,36,.1);'>".$lang['timestamp']."</td>";
                                    echo "<td class='content_td' style='padding: 5px;'>".$date."</td>";
                                echo "</tr>";
                                echo "<tr>";
                                    echo "<td class='content_td' style='padding: 5px;border-right: 1px solid rgba(0,255,36,.1);'>".$lang['expired']."</td>";
                                    echo "<td class='content_td' style='padding: 5px;'>".$mutedate."</td>";
                                echo "</tr>";
                                echo "<tr>";
                                    echo "<td class='content_td' style='padding: 5px;border-right: 1px solid rgba(0,255,36,.1);'>".$lang['type']."</td>";
                                    echo "<td class='content_td' style='padding: 5px;'>".$displayMuteType."</td>";
                                echo "</tr>";
                                echo "<tr>";
                                    echo "<td class='content_td' style='padding: 5px;border-right: 1px solid rgba(0,255,36,.1);'>".$lang['reason']."</td>";
                                    echo "<td class='content_td' style='padding: 5px;'>".$this->reason."</td>";
                                echo "</tr>";
                                echo "<tr>";
                                    echo "<td class='content_td' style='padding: 5px;border-right: 1px solid rgba(0,255,36,.1);'>".$lang['admin_name2']."</td>";
                                    echo "<td class='content_td' style='padding: 5px;'>".$this->admin->NameCard("float: left;")."</td>";
                                echo "</tr>";
                            echo "</td>";
                        echo "</tr>";
                    echo "</table>";
                echo "</div>";
            echo "</div>";
        echo "</td>";
    }
}


class KickData {

    public static $NeededColumList = array(
        'id',
        'LastLoginName',
        'AdminLvL1'
    );

    public $kid;

    public $player_ip;
    public $player_id;
    public $player_nick;
    public $player;

    public $admin_ip;
    public $admin_id;
    public $admin_nick;
    public $admin;
    
    public $reason;
    public $created;

    function __construct($input) //query row or bid
    {
        if(is_numeric($input))
        {
            global $sql;
            $input = $sql->select_row(Config::$t_AmxBan_name, null, "`kid`=".$kid);
        }

        if(!is_array($input))
        {
            Utils::php_error($this, "Invalid var type:\"".gettype($input)."\"");
            return;
        }


        $this->kid = $input["kid"];

        $this->player_ip = $input["player_ip"];
        $this->player_id = $input["player_id"];
        $this->player_nick = $input["player_nick"];
        
        $this->player = new UserProfile($this->player_id, self::$NeededColumList);
        if($this->player->SuccessInit() === true)
        {
            //$this->player->id = -1;
            $this->player->PermLvl->AdminLvl[] = 0;
            $this->player->LastLoginName = $this->player_nick;
        }

        $this->admin_ip = $input["admin_ip"];
        $this->admin_id = $input["admin_id"];
        $this->admin_nick = $input["admin_nick"];
        $this->admin = new UserProfile($this->admin_id, self::$NeededColumList);
        if($this->admin->SuccessInit() === false)
        {
            $this->admin->id = -1;
            $this->admin->PermLvl->AdminLvl[] = 0;
            $this->admin->LastLoginName = $this->player_nick;
        }

        $this->reason = $input["kick_reason"];
        $this->created = $input["kick_created"];
    }

    function display_line($varibles = array())
    {
        $date = date('Y/m/d H:i:s', $this->created);
        $displayID = $this->player_id == "Unknown" ? self::CensorIP($this->player_ip) : $this->player_id;

        if(empty($varibles))
        {
            echo "<td>#".$this->kid."</td>";
            echo "<td>".$this->player->NameCard("float: left;")."</td>";
            echo "<td>".$displayID."</td>";
            echo "<td>".$date."</td>";
            echo "<td>".$this->reason."</td>";
            echo "<td>".$this->admin->NameCard("float: left;")."</td>";
        }
        else
        {
            for ($i=0; $i < sizeof($varibles); $i++) { 
                switch ($varibles[$i]) {
                    case 'kid':{
                        echo "<td>#".$this->kid."</td>";
                        break;
                    }
                    case 'player':{
                        echo "<td>".$this->player->NameCard("float: left;")."</td>";
                        break;
                    }
                    case 'identy':{
                        echo "<td>".$displayID."</td>";
                        break;
                    }
                    case 'createdate':{
                        echo "<td>".$date."</td>";
                        break;
                    }
                    case 'reason':{
                        echo "<td>".$this->reason."</td>";
                        break;
                    }
                    case 'admin':{
                        echo "<td>".$this->admin->NameCard("float: left;")."</td>";
                        break;
                    }
                    default:{
                        Utils::php_error($this, "Unknown varible in varibles[$i]: \"".$varibles[$i]."\"");
                        break;
                    }
                }
            }
        }
        echo "</tr>";
    }
}