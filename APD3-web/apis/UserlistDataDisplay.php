<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/Config.php");
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/includes/Utils.php");
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/includes/PunishmentStruck.php");

global $sql;
$limit = 25;
$s_search = "";
$i_page = isset($_GET['page']) ? strip_tags(filter_input(INPUT_GET, 'page', FILTER_SANITIZE_NUMBER_INT)) : 1;
$start = ($i_page - 1) * $limit;

// Handle search input
if (isset($_GET['search'])) {
    $s_search = strip_tags(filter_input(INPUT_GET, 'search', FILTER_SANITIZE_FULL_SPECIAL_CHARS));
}

$is_SteamSearch = strpos($s_search, 'STEAM_') !== false;

// Build query based on search
if ($is_SteamSearch) {
    $query = $sql->query("
        SELECT DISTINCT `LastLoginID` 
        FROM `" . Config::$t_regsystem_name . "` 
        WHERE (`LastLoginID` LIKE '%{$s_search}%' OR `RegisterID` LIKE '%{$s_search}%') 
        ORDER BY `Active` DESC, `LastLoginDate` DESC, `id` ASC 
        LIMIT $start, $limit
    ");
} else {
    $query = $sql->query("
        SELECT DISTINCT `LastLoginID` 
        FROM `" . Config::$t_regsystem_name . "` 
        WHERE (`LastLoginName` LIKE '%{$s_search}%') 
        ORDER BY `Active` DESC, `LastLoginDate` DESC, `id` ASC 
        LIMIT $start, $limit
    ");
}

$c_query = mysqli_num_rows($query);
// Output HTML with proper structure
header('Content-Type: text/html; charset=utf-8');
echo "<table><tbody>";

if ($c_query == 0 && isset($_GET['search'])) {
    echo "<tr><td colspan='4' style='text-align: center;'>" . $lang['no_results_found_for_search'] . " '" . $s_search . "'</td></tr>";
} else if ($c_query == 0) {
    //echo "<tr><td colspan='4' style='text-align: center;'>" . $lang['no_more_results'] . "</td></tr>";
} else {
    while ($row = mysqli_fetch_array($query)) {
        if (empty($row['LastLoginID'])) {
            continue;
        }
        
        $NeededColumList = array(
            'id',
            'LastLoginID',
            'LastLoginIP',
            'LastLoginName',
            'LastLoginDate',
            'LastLoggedOn',
            'Active',
            'AdminLvL1'
        );

        $player = new UserProfile($row['LastLoginID'], $NeededColumList, null, true);
        if ($player->SuccessInit() === false) {
            continue;
        }

        echo "<tr class='tr_all".($player->Active > 0 ? " tr_online" : "")." tr_normal' onclick=\"gotourl(this)\" data-href='/profile/{$player->id}'>";

        echo "<td>#".$player->id."</td>";
        echo "<td>".$player->NameCard("float: left;", false, 0, 0, true)."</td>";
        echo "<td>".$player->LastLoginDate."</td>";
        
        switch ($player->LastLoggedOn) {
            case 1:
                echo "<td>FUN</td>";
                break;
            case 2:
                echo "<td>DEVELOPER</td>";
                break;
            case 3:
                echo "<td>ONLYDUST2</td>";
                break;
            case 4:
                echo "<td>S-DEV #2</td>";
                break;
            default:
                echo "<td>N/A</td>";
                break;
        }
        echo "</tr>";
    }
    
    if ($c_query != 0 && $c_query <= 24) {
        echo "<tr><td colspan='4' style='text-align: center;'>" . $lang['no_more_results'] . "</td></tr>";
    }
}

echo "</tbody></table>";
?>
