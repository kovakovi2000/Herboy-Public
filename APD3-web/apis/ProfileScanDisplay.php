<?php
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/Config.php");
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/includes/Utils.php");
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/includes/PunishmentStruck.php");

global $sql;
global $currentUser;

$currentUser = new UserProfile($pagelink[2], array(
    'id',
    'LastLoginID',
    'LastLoginIP',
    'LastLoginName',
    'RegisterName',
    'RegisterIP',
    'RegisterID',
    'RegisterDate',
    'Active',
    'PremiumPoint',
    'LastLoginDate',
    'PlayTime',
    'AdminLvL1'
));

// Prepare the SQL query
$query = "SELECT * FROM `" . Config::$t_AmxScan_name . "` WHERE 
    `player_id` = ? OR
    `admin_id` = ? OR
    `player_name` = ? OR
    `admin_name` = ?
    ORDER BY `amx_scans`.`id` DESC";

// Prepare the statement
$stmt = $sql->prepare($query);
if (!$stmt) {
    Utils::php_error($this, "Prepare failed: " . htmlspecialchars($sql->mysqli->error));
    return;
}

// Bind parameters
$stmt->bind_param('ssss', $currentUser->LastLoginID, $currentUser->RegisterID, $currentUser->LastLoginName, $currentUser->RegisterName);

// Execute the statement
$stmt->execute();

// Get the result
$query = $stmt->get_result();
$c_query = $query->num_rows;

if (!$currentUser->PermLvl->isAdmin() || $c_query > 0 || ($c_query == 0 && Account::IsLogined() && Account::$UserProfile->isBanableSomewhere($currentUser))) {
?>
<table class="table zebra-stripes" style="background-color: rgba(0,0,0,0.7) !important; margin: 0px;">
    <tr>
        <th class="tg-0lax"><?php echo $lang['player']; ?></th>
        <th class="tg-0lax"><?php echo $lang['admin_name2']; ?></th>
        <th class="tg-0lax"><?php echo $lang['status']; ?></th>
        <th class="tg-0lax"><?php echo $lang['timestamp']; ?></th>
    </tr>
    <?php 
    while ($row = $query->fetch_assoc()) {
        $scan = new ScanData($row);
        $scan->display_line(array("player", "admin", "status", "createdate"));
    }
    ?>
</table>
<?php
}

