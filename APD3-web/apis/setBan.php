<?php
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/Config.php");
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/includes/_socket.php");
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/includes/Utils.php");

$userProfile = null;
if (isset($_SESSION['account'])) {
    $userProfile = unserialize($_SESSION['account']);
    if(!$userProfile || !$userProfile->PermLvl->isAdmin())
    {
        Utils::html_error(401);
        exit();
    }
}
else
{
    Utils::html_error(401);
    exit();
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $steamID = $_POST['steamID'] ?? null;
    $reason = $_POST['reason'] ?? null;
    $banLength = $_POST['banLength'] ?? null;
    $AdminID = $_POST['AdminID'] ?? null;
    $AdminLvL = $_POST['AdminLvL'] ?? null;

    $NeededColumList = array(
        'id',
        'LastLoginID',
        'LastLoginIP',
        'LastLoginName',
        'LastLoginDate',
        'LastLoggedOn'
    );
    $player = new UserProfile($steamID, $NeededColumList);
    if ($player->SuccessInit() === false) {
        echo "Hibás steamid $steamID | Profil nem található!";
        return;
    }
    $admin = new UserProfile($AdminID, $NeededColumList);
    if ($admin->SuccessInit() === false) {
        echo "Hibás steamid $AdminID | Profil nem található!";
        return;
    }

    global $sql;

    // Escape any special characters in player and admin data to prevent SQL injection or errors
    $playerLastLoginIP = $sql->mysqli->real_escape_string($player->LastLoginIP ?? '');
    $playerLastLoginID = $sql->mysqli->real_escape_string($player->LastLoginID ?? '');
    $playerLastLoginName = $sql->mysqli->real_escape_string($player->LastLoginName ?? '');
    
    $adminLastLoginIP = $sql->mysqli->real_escape_string($admin->LastLoginIP ?? '');
    $adminLastLoginID = $sql->mysqli->real_escape_string($admin->LastLoginID ?? '');
    $adminLastLoginName = $sql->mysqli->real_escape_string($admin->LastLoginName ?? '');    
    
    $escapedReason = $sql->mysqli->real_escape_string(htmlspecialchars($reason));

    $query = $sql->query("SELECT * FROM `" . Config::$t_AmxBan_name . "`  
                          WHERE (`player_ip` LIKE '%$playerLastLoginIP%' OR `player_id` LIKE '%$playerLastLoginID%') 
                          AND `expired` = 0;");
    $c_query = mysqli_num_rows($query);
    $row = mysqli_fetch_array($query);

    if ($c_query > 0) {
        echo "alreadybanned [" . $row['bid'] . "]";
        return;
    } else {
        $query = $sql->query("INSERT INTO `amx_bans`
        (
            `player_ip`,
            `player_id`,
            `player_nick`,
            `admin_ip`,
            `admin_id`,
            `admin_nick`,
            `ban_reason`,
            `ban_created`,
            `ban_length`,
            `expired`,
            `isNew`,
            `BannedByPlayerId`,
            `BannedPlayerId`,
            `BannedByAdminPerm`
        ) VALUES (
            '$playerLastLoginIP', 
            '$playerLastLoginID', 
            '$playerLastLoginName', 
            '$adminLastLoginIP', 
            '$adminLastLoginID', 
            CONCAT('$adminLastLoginName', ' (WebAdmin)'),  
            '$escapedReason', 
            '" . time() . "', 
            '$banLength', 
            '0',
            '1',
            '{$admin->id}',
            '{$player->id}',  
            '$AdminLvL');
        ");
        $passargs = array("i", mysqli_insert_id($sql->mysqli), "i", "1", "i", "1");
        sck_CallPawnFunc("BanSystemv4.amxx", "LoadWebadmin", $passargs);
        echo 'success';
        //TODO SOCKET
    }
}
?>
