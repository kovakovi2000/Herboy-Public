<?php
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/Config.php");
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/includes/Utils.php");
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/includes/PunishmentStruck.php");

global $sql;

if (isset($_SESSION['account'])) {
    $userProfile = unserialize($_SESSION['account']);
    $userId = $userProfile->id ?? 'Ismeretlen ID';
} else {
    $userProfile = null;
}

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

$limit = 25;
$page = isset($_GET['page']) ? intval($_GET['page']) : 1;
$start = ($page - 1) * $limit;

$i_UnMuted = $sql->query("SELECT COUNT(`bid`) as 'TotalCount' FROM `".Config::$t_AmxMute_name."` WHERE `expired` > 0")->fetch_assoc()['TotalCount'];
$i_ActiveMute = $sql->query("SELECT COUNT(`bid`) as 'TotalCount' FROM `".Config::$t_AmxMute_name."` WHERE `expired` = 0")->fetch_assoc()['TotalCount'];

$total_count = $sql->query("SELECT COUNT(*) AS total FROM `".Config::$t_AmxMute_name."`")->fetch_assoc()['total'];

$query = $sql->query("
    SELECT `bid`, `player_nick`, `player_id`, `mute_created`, `mute_length`, `mute_type`, `mute_reason`, `admin_nick`, `admin_id`, `expired`, `modified`, `UName`, `MutedByAdminPerm`
    FROM `" . Config::$t_AmxMute_name . "`
    ORDER BY `bid` DESC
    LIMIT $start, $limit
");

$data = '';
if ($query && mysqli_num_rows($query) > 0) {
    while ($row = mysqli_fetch_array($query)) {
        $NeededColumList = array(
            'id',
            'LastLoginID',
            'LastLoginName',
            'LastLoginDate',
            'LastLoggedOn',
            'AdminLvL1'
        );

        $player = new UserProfile($row['player_id'], $NeededColumList, null, true);
        //if ($player->SuccessInit() === true) {
           // $player->id = -1;
            $player->PermLvl->AdminLvl[] = 0;
            $player->LastLoginName = $row['player_nick'];
        
        $admin = new UserProfile($row['admin_id'], $NeededColumList, null, true);
        if ($player->SuccessInit() === true) {
            //$admin->id = -1;
            //$admin->PermLvl->AdminLvl[] = 0;
            $admin->LastLoginName = $row['admin_nick'];
        }

        $mute_created = date('Y-m-d H:i:s', intval($row['mute_created']));
        $mute_length_display = intval($row['mute_length']) === 0 ? $lang['never'] : date('Y-m-d H:i:s', intval($row['mute_created']) + (intval($row['mute_length']) * 60));

        $displayMuteType = $row['mute_type'] == 3 ? "Voice + Chat" : ($row['mute_type'] == 2 ? "Voice" : "Chat");
        //$isWebadmin = strpos($row['admin_nick'], '(WebAdmin)') !== false;

        $data .= "<tr class='tr_all ".($row['expired'] == 0 ? "tr_banned" : "tr_normal")."' onclick=\"show_tr('".$row['bid']."', this)\">";
        $data .= "<td>#".htmlspecialchars($row['bid'])."</td>";
        $data .= "<td>".$player->NameCard("float: left;")."</td>";
        $data .= "<td>".htmlspecialchars($row['player_id'])."</td>";
        $data .= "<td>".htmlspecialchars($row['mute_reason'])."</td>";
        $data .= "<td>".htmlspecialchars($mute_created)."</td>";
        $data .= "<td>".htmlspecialchars($mute_length_display)."</td>";
        $data .= "<td><span style='display: inline;'>" .$admin->NameCard("float: left;");
//if ($isWebadmin) {
//    $data .= " (WebAdmin)";
//}
        $data .= "<td>".PrintStatus($row['expired'], $row['modified'], $row['UName'])."</td>";
        $data .= "</tr>";

        $data .= "<tr id='".$row['bid']."'>";
        $data .= "<td align='center' colspan='8' style='width: fit-content; margin: 0px;padding: 0px;'>";
        $data .= "<div id='c".$row['bid']."' class='div_hideOnLoad' style='width: 100%; overflow: hidden; display: none'>";
        $data .= "<div style='width: 50%; float: left; padding-top: 10px;'>";
        $data .= "<table border='0' cellspacing='0' cellpadding='0'>";
        $data .= "<tr style='background-color: ".($row['expired'] > 0 ? "rgba(0,255,36,0.1)" : "rgb(255 2 2 / 23%)").";'>";
        $data .= "<td style='padding: 5px; width: 150px;'>" . $lang['mute_details'] . "</td>";
        $data .= "<td align='right' style='padding: 5px;'>";

        if (
            $isAdmin
            && $row['expired'] == 0
            && (
                in_array($loggedInAdminLvL, [1, 2]) 
                || ($loggedInAdminLvL == 3 && in_array($row['MutedByAdminPerm'], [3, 4])) 
                || ($loggedInAdminLvL == 4 && $row['MutedByAdminPerm'] == 4)
            )
        ) {
            $data .= "<button class='btn btn-xs btn-danger' 
                      style='pointer-events: auto; color: black; border-radius: 2px; float: right; margin-left: 10px; margin-bottom: 0px; padding: 0px 10px;' 
                      onclick='handleUnMuteButtonClick(".$row['bid'].")'>
                      <i class='bi bi-check-square' style='margin-right: 3px;'></i> " . $lang['unmute'] . " <i class='bi bi-check-square' style='margin-left: 3px;'></i>
                      </button>";
                      $data .= "<button class='btn btn-xs btn-warning change-mute-btn' 
                      style='pointer-events: auto; color: black; border-radius: 2px; float: right; margin-left: 10px; margin-bottom: 0px; padding: 0px 10px;' 
                      data-mute-id='".htmlspecialchars($row['bid'], ENT_QUOTES)."' 
                      data-player-nick='".htmlspecialchars($player->LastLoginName, ENT_QUOTES)."' 
                      data-steamid='".htmlspecialchars($row['player_id'], ENT_QUOTES)."' 
                      data-mute-created='".htmlspecialchars($mute_created, ENT_QUOTES)."' 
                      data-mute-length='".htmlspecialchars($row['mute_length'], ENT_QUOTES)."' 
                      data-mute-type='".htmlspecialchars($displayMuteType, ENT_QUOTES)."' 
                      data-mute-expiry='".htmlspecialchars($mute_length_display, ENT_QUOTES)."' 
                      data-mute-reason='".htmlspecialchars($row['mute_reason'], ENT_QUOTES)."' 
                      data-admin-name-card='".htmlspecialchars($admin->NameCard("float: left;"), ENT_QUOTES, 'UTF-8')."' 
                      onclick='handleChangeMuteButtonClick(this)'>
                      <i class='bi bi-card-text' style='margin-right: 3px;'></i> " . $lang['modify'] . " <i class='bi bi-card-text' style='margin-left: 3px;'></i>
                      </button>";
        }
        $data .= "<button class='btn btn-xs btn-success about-mute-btn' 
        style='pointer-events: auto; color: black; border-radius: 2px; float: right; margin-left: 10px; margin-bottom: 0px; padding: 0px 10px;' 
        data-mute-id='".$row['bid']."'>
<i class='bi bi-info-square' style='margin-right: 3px;'></i> " . $lang['more_info'] . " <i class='bi bi-info-square' style='margin-left: 3px;'></i>
        </button>";
        $data .= "</td></tr>";
        $data .= "<tr><td class='content_td' style='padding: 5px;border-right: 1px solid rgba(0,255,36,.1);'>".$lang['mute_id']."</td><td class='content_td' style='padding: 5px;'>#".htmlspecialchars($row['bid'])."</td></tr>";
        $data .= "<tr><td class='content_td' style='padding: 5px;border-right: 1px solid rgba(0,255,36,.1);'>".$lang['name']."</td><td class='content_td' style='padding: 5px;'>".$player->NameCard("float: left;")."</td></tr>";
        $data .= "<tr><td class='content_td' style='padding: 5px;border-right: 1px solid rgba(0,255,36,.1);'>".$lang['steamID']." / IP</td><td class='content_td' style='padding: 5px;'>".htmlspecialchars($row['player_id'])."</td></tr>";
        $data .= "<tr><td class='content_td' style='padding: 5px;border-right: 1px solid rgba(0,255,36,.1);'>".$lang['timestamp']."</td><td class='content_td' style='padding: 5px;'>".htmlspecialchars($mute_created)."</td></tr>";
        $data .= "<tr><td class='content_td' style='padding: 5px;border-right: 1px solid rgba(0,255,36,.1);'>".$lang['expiry']."</td><td class='content_td' style='padding: 5px;'>".htmlspecialchars($mute_length_display)."</td></tr>";
        $data .= "<tr><td class='content_td' style='padding: 5px;border-right: 1px solid rgba(0,255,36,.1);'>".$lang['type']."</td><td class='content_td' style='padding: 5px;'>".$displayMuteType."</td></tr>";
        $data .= "<tr><td class='content_td' style='padding: 5px;border-right: 1px solid rgba(0,255,36,.1);'>".$lang['reason']."</td><td class='content_td' style='padding: 5px;'>".htmlspecialchars($row['mute_reason'])."</td></tr>";
        $data .= "<tr><td class='content_td' style='padding: 5px;border-right: 1px solid rgba(0,255,36,.1);'>".$lang['admin_name2']."</td><td class='content_td' style='padding: 5px;'>".$admin->NameCard("float: left;")."</td></tr>";
        $data .= "</table></div></div></td></tr>";
    }
} else {
    $data = "<tr><td colspan='8'>Nem található némítás az adatbázisban.</td></tr>";
}

function PrintStatus($expired, $modified, $username)
{   global $lang;
    $class = 'label label-danger';
    $text = $lang['active'];  // 'Aktív' translated
    
    if ($expired == 1) {
        $class = 'label label-success';
        $text = $lang['expired'];  // 'Lejárt' translated
    } elseif ($expired == 2) {
        $class = 'label label-success';
        $text = $lang['deactivated'];  // 'Deaktiválva' translated
    }

    $ret = "<span class='".$class."' style='float: left; margin-right: 5px;'>".$text."</span>";
    
    if ($modified > 0) {
        $ret .= "<span class='label label-warning' style='float: left; margin-right: 5px;'>".$lang['modified']."</span>";  // 'Módosított' translated
    }
    
    return $ret . ($expired == 2 ? ("<div style='float: left;'> " . htmlspecialchars($username ?? '', ENT_QUOTES) . "</div>") : "");
}


echo "<div id='totalMutes'>".htmlspecialchars($total_count)."</div>";
echo "<div id='totalUMutes'>".htmlspecialchars($i_UnMuted)."</div>";
echo "<div id='totalActMutes'>".htmlspecialchars($i_ActiveMute)."</div>";
echo "<table class='table zebra-stripes'><thead><tr><th>MuteID</th><th>Név</th><th>SteamID</th><th>Indok</th><th>Időpont</th><th>Lejárat</th><th>Admin neve</th><th>Állapot</th></tr></thead><tbody>";
echo $data;
echo "</tbody></table>";
?>
