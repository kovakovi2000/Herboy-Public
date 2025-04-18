<?php
$rt_start = microtime(true);
$runtime = array();
function running_time($functionname, $subtask)
{
    global $runtime, $rt_start;
    $current_time = microtime(true);
    $elapsed_time = $current_time - $rt_start;

    $runtime[] = [
        'functionname' => $functionname,
        'subtask' => $subtask,
        'time' => $elapsed_time
    ];

    // Reset start time for the next measurement
    $rt_start = $current_time;
}

running_time('Script', 'Initialization');

include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/Config.php");
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/includes/Utils.php");
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/includes/PunishmentStruck.php");

running_time('Script', 'Includes Loaded');

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
running_time('Script', 'User Profile Check');

$limit = 25;
$page = isset($_GET['page']) ? intval($_GET['page']) : 1;
$start = ($page - 1) * $limit;
$i_AntiCheatBan = mysqli_fetch_array($sql->query("SELECT count(`bid`) as 'TotalCount' FROM `".Config::$t_AmxBan_name."` WHERE `admin_id` = 'SERVER_ID';"))['TotalCount'];
running_time('Database', 'AntiCheatBan Count');
$i_AdminBan = mysqli_fetch_array($sql->query("SELECT count(`bid`) as 'TotalCount' FROM `".Config::$t_AmxBan_name."` WHERE `admin_id` != 'SERVER_ID';"))['TotalCount'];
running_time('Database', 'AdminBan Count');
$i_UnBanned = mysqli_fetch_array($sql->query("SELECT count(`bid`) as 'TotalCount' FROM `".Config::$t_AmxBan_name."` WHERE `expired` > 0;"))['TotalCount'];
running_time('Database', 'Unbanned Count');
$i_ActiveBan = mysqli_fetch_array($sql->query("SELECT count(`bid`) as 'TotalCount' FROM `".Config::$t_AmxBan_name."` WHERE `expired` = 0;"))['TotalCount'];
running_time('Database', 'ActiveBan Count');

$total_query = $sql->query("SELECT COUNT(*) AS total FROM `".Config::$t_AmxBan_name."`");
$total_count = 0;

if ($total_query && $row = mysqli_fetch_assoc($total_query)) {
    $total_count = $row['total'];
    
}
running_time('Database', 'Total Count Query');

$query = $sql->query("
    SELECT `bid`, `player_nick`, `player_id`, `ban_created`, `ban_length`, `ban_reason`, `admin_nick`, `admin_id`, `expired`, `modified`, `ban_kicks`, `UName`, `BannedByAdminPerm`
    FROM `" . Config::$t_AmxBan_name . "`
    ORDER BY `bid` DESC
    LIMIT $start, $limit
");
running_time('Database', 'Main Query Execution');

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
        running_time('UserProfile', 'Player Profile Initialization');
        //if ($player->SuccessInit() === true) {
           // $player->id = -1;
            $player->PermLvl->AdminLvl[] = 0;
            $player->LastLoginName = $row['player_nick'];
        
        $admin = new UserProfile($row['admin_id'], $NeededColumList, null, true);
        running_time('UserProfile', 'Admin Profile Initialization');
        if ($player->SuccessInit() === true) {
            //$admin->id = -1;
            //$admin->PermLvl->AdminLvl[] = 0;
            $admin->LastLoginName = $row['admin_nick'];
        }
        $ban_created = date('Y-m-d H:i:s', intval($row['ban_created']));

        $ban_length = intval($row['ban_length']);
if ($ban_length == 0) {
    $ban_length_display = $lang['never'];  // Use the lang array for "never"
} else {
    $ban_expiry_time = intval($row['ban_created']) + ($ban_length * 60);
    $ban_length_display = date('Y-m-d H:i:s', $ban_expiry_time);
}

      //  $isWebadmin = strpos($row['admin_nick'], '(WebAdmin)') !== false;
        //$adminRank = isset($lang['admin'][$admin->rank]) ? $lang['admin'][$admin->rank] : $admin->rank;
        $data .= "<tr class='tr_all ".($row['expired'] == 0 ? "tr_banned" : "tr_normal")."' onclick=\"show_tr('".$row['bid']."', this)\">";
        $data .= "<td>#".htmlspecialchars($row['bid'])."</td>";
        $data .= "<td>" .$player->NameCard("float: left;"). "</td>";
        $data .= "<td>" . htmlspecialchars($row['player_id']) . "</td>";
        $data .= "<td>" . htmlspecialchars($row['ban_reason']) . "</td>";
        $data .= "<td>" . htmlspecialchars($ban_created) . "</td>";
        $data .= "<td>" . htmlspecialchars($ban_length_display) . "</td>";
        $data .= "<td><span style='display: inline;'>" . $admin->NameCard("float: left;") . /* " " . $adminRank . */ "</span></td>";
//if ($isWebadmin) {
//    $data .= " (WebAdmin)";
//}
$data .= "</span></td>";
        $data .= "<td>" .PrintStatus($row['expired'], $row['modified'], $row['UName'])."</td>";
        $data .= "</tr>";

        $data .= "<tr id='".$row['bid']."'>";
        $data .= "<td align='center' colspan='8' style='width: fit-content; margin: 0px;padding: 0px;'>";
        $data .= "<div id='c".$row['bid']."' class='div_hideOnLoad' style='width: 100%; overflow: hidden; display: none'>";
            $data .= "<div style='width: 50%; float: left; padding-top: 10px;'>";
                $data .= "<table border='0' cellspacing='0' cellpadding='0'>";
                    if($row['expired'] > 0)
                        $data .= "<tr style='background-color: rgba(0,255,36,0.1);'>";
                    else
                        $data .= "<tr style='background-color: rgb(255 2 2 / 23%);'>";
                        $data .= "<td style='padding: 5px; width: 150px;'>" . $lang['ban_details'] . "</td>";
                $data .= "<td style='padding: 5px; text-align: right;'>";
                if (
                    $isAdmin
                    && $row['expired'] == 0
                    && (
                        in_array($loggedInAdminLvL, [1, 2]) 
                        || ($loggedInAdminLvL == 3 && in_array($row['BannedByAdminPerm'], [3, 4])) 
                        || ($loggedInAdminLvL == 4 && $row['BannedByAdminPerm'] == 4)
                    )
                ) {

                    $data .= "<button class='btn btn-xs btn-danger' 
                    style='pointer-events: auto; color: black; border-radius: 2px; float: right; margin-left: 10px; margin-bottom: 0px; padding: 0px 10px;' 
                    onclick='handleUnbanButtonClick(".$row['bid'].")'>
                    <i class='bi bi-check-square' style='margin-right: 3px;'></i> " . $lang['unban'] . " <i class='bi bi-check-square' style='margin-left: 3px;'></i>
                    </button>";

$data .= "<button class='btn btn-xs btn-warning change-ban-btn' 
                    style='pointer-events: auto; color: black; border-radius: 2px; float: right; margin-left: 10px; margin-bottom: 0px; padding: 0px 10px;' 
                    data-ban-id='".htmlspecialchars($row['bid'], ENT_QUOTES, 'UTF-8')."' 
                    data-player-nick='".htmlspecialchars($player->LastLoginName, ENT_QUOTES, 'UTF-8')."' 
                    data-steamid='".htmlspecialchars($row['player_id'], ENT_QUOTES, 'UTF-8')."' 
                    data-ban-created='".htmlspecialchars($ban_created, ENT_QUOTES, 'UTF-8')."' 
                    data-ban-length='".htmlspecialchars($row['ban_length'], ENT_QUOTES, 'UTF-8')."' 
                    data-ban-expiry='".htmlspecialchars($ban_length_display, ENT_QUOTES, 'UTF-8')."' 
                    data-ban-reason='".htmlspecialchars($row['ban_reason'], ENT_QUOTES, 'UTF-8')."' 
                    data-admin-name-card='".htmlspecialchars($admin->NameCard("float: left;"), ENT_QUOTES, 'UTF-8')."' 
                    onclick='handleChangeBanButtonClick(this)'>
                    <i class='bi bi-card-text' style='margin-right: 3px;'></i> " . $lang['modify'] . " <i class='bi bi-card-text' style='margin-left: 3px;'></i>
                    </button>";
                }
$data .= "<button class='btn btn-xs btn-success about-ban-btn' 
                    style='pointer-events: auto; color: black; border-radius: 2px; float: right; margin-left: 10px; margin-bottom: 0px; padding: 0px 10px;' 
                    data-ban-id='".$row['bid']."'>
                    <i class='bi bi-info-square' style='margin-right: 3px;'></i> " . $lang['more_info'] . " <i class='bi bi-info-square' style='margin-left: 3px;'></i>
                    </button>";

                $data .= "</td>";
                $data .= "<tr>";
                            $data .= "<td class='content_td' style='padding: 5px;border-right: 1px solid rgba(0,255,36,.1);'>BanID</td>";
                            $data .= "<td class='content_td' style='padding: 5px;'>#".htmlspecialchars($row['bid'])."</td>";
                        $data .= "</tr>";
                        $data .= "<tr>";
                        $data .= "<td class='content_td' style='padding: 5px;border-right: 1px solid rgba(0,255,36,.1);'>" . $lang['name'] . "</td>";
                        $data .= "<td class='content_td' style='padding: 5px;'>" . $player->NameCard("float: left;") . "</td>";
                        $data .= "</tr>";
                        
                        $data .= "<td class='content_td' style='padding: 5px;border-right: 1px solid rgba(0,255,36,.1);'>" . $lang['steamID'] . " / IP</td>";
                        $data .= "<td class='content_td' style='padding: 5px;'>" . htmlspecialchars($row['player_id']) . "</td>";
                        $data .= "<tr>";
                        
                        $data .= "<td class='content_td' style='padding: 5px;border-right: 1px solid rgba(0,255,36,.1);'>" . $lang['timestamp'] . "</td>";
                        $data .= "<td class='content_td' style='padding: 5px;'>" . htmlspecialchars($ban_created) . "</td>";
                        $data .= "</tr>";
                        
                        $data .= "<tr>";
                        $data .= "<td class='content_td' style='padding: 5px;border-right: 1px solid rgba(0,255,36,.1);'>" . $lang['expiry'] . "</td>";
                        $data .= "<td class='content_td' style='padding: 5px;'>" . htmlspecialchars($ban_length_display) . "</td>";
                        $data .= "</tr>";
                        
                        $data .= "<tr>";
                        $data .= "<td class='content_td' style='padding: 5px;border-right: 1px solid rgba(0,255,36,.1);'>" . $lang['kicks_since_ban'] . "</td>";
                        $data .= "<td class='content_td' style='padding: 5px;'>" . htmlspecialchars($row['ban_kicks']) . "</td>";
                        $data .= "</tr>";
                        
                        $data .= "<tr>";
                        $data .= "<td class='content_td' style='padding: 5px;border-right: 1px solid rgba(0,255,36,.1);'>" . $lang['reason'] . "</td>";
                        $data .= "<td class='content_td' style='padding: 5px;'>" . htmlspecialchars($row['ban_reason']) . "</td>";
                        $data .= "</tr>";
                        
                        $data .= "<tr>";
                        $data .= "<td class='content_td' style='padding: 5px;border-right: 1px solid rgba(0,255,36,.1);'>" . $lang['admin_name2'] . "</td>";
                        $data .= "<td class='content_td' style='padding: 5px;'>" . $admin->NameCard("float: left;") . "</td>";
                        
                        $data .= "</tr>";
                    $data .= "</td>";
                $data .= "</tr>";
            $data .= "</table>";
        $data .= "</div>";
    $data .= "</div>";
$data .= "</td>";
running_time('Script', 'Data Processing and Rendering');
    }
} else {
    $data = "<tr><td colspan='8'>Nem található kitiltás az adatbázisban.</td></tr>";
}

function PrintStatus($expired, $modified, $username)
{
    global $lang; // Access the global $lang array

    if ($expired == 1) {
        $class = 'label label-success';
        $text = $lang['expired'];  // Use translation from $lang array
    } elseif ($expired == 2) {
        $class = 'label label-success';
        $text = $lang['deactivated'];  // Use translation from $lang array
    } elseif ($expired == 3) {
        $class = 'label label-success';
        $text = $lang['global_unban'];  // Use translation from $lang array
    } else {
        $class = 'label label-danger';
        $text = $lang['active'];  // Use translation from $lang array
    }

    // Build the label with the status
    $ret = "<span class='" . $class . "' style='float: left; margin-right: 5px;'>" . $text . "</span>";

    // If modified, append the "modified" label
    if ($modified > 0) {
        $ret .= "<span class='label label-warning' style='float: left; margin-right: 5px;'>" . $lang['modified'] . "</span>";
    }

    // If expired, show the username
    $ret .= ($expired == 2 ? ("<div style='float: left;'> " . htmlspecialchars($username, ENT_QUOTES) . "</div>") : "");

    return $ret;
}
echo "<div id='totalBans'>".htmlspecialchars($total_count)."</div>";
echo "<div id='totalAcBan'>".htmlspecialchars($i_AntiCheatBan)."</div>";
echo "<div id='totalABan'>".htmlspecialchars($i_AdminBan)."</div>";
echo "<div id='totalUBan'>".htmlspecialchars($i_UnBanned)."</div>";
echo "<div id='totalActBan'>".htmlspecialchars($i_ActiveBan)."</div>";
echo "<table class='table zebra-stripes'><thead><tr><th>banID</th><th>Név</th><th>SteamID</th><th>Indok</th><th>Időpont</th><th>Lejárat</th><th>Admin neve</th><th>Állapot</th></tr></thead><tbody>";
echo $data;
echo "</tbody></table>";

running_time('Script', 'Finished');
$runtime_time = array_sum(array_column($runtime, 'time'));
$report_content = "Runtime Breakdown (".$runtime_time." sec):\n";
$report_content .= "+-------------------------+-------------------------------------------+------------------+\n";
$report_content .= "| Function                | Subtask                                   | Time (sec)       |\n";
$report_content .= "+-------------------------+-------------------------------------------+------------------+\n";
foreach ($runtime as $entry) {
    $report_content .= sprintf("| %-23s | %-41s | %-16.6f |\n", $entry['functionname'], $entry['subtask'], $entry['time']);
}
$report_content .= "+-------------------------+-------------------------------------------+------------------+\n\n";
echo "<pre>".$report_content."</pre>";
?>
