<?php
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/Config.php");
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/includes/Utils.php");
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/includes/_socket.php");

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
    $muteLength = $_POST['muteLength'] ?? null;
    $muteType = $_POST['muteType'] ?? null;
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

    // Escape special characters in player and admin data
    $playerLastLoginIP = $sql->mysqli->real_escape_string($player->LastLoginIP);
    $playerLastLoginID = $sql->mysqli->real_escape_string($player->LastLoginID);
    $playerLastLoginName = $sql->mysqli->real_escape_string($player->LastLoginName);
    
    $adminLastLoginIP = $sql->mysqli->real_escape_string($admin->LastLoginIP);
    $adminLastLoginID = $sql->mysqli->real_escape_string($admin->LastLoginID);
    $adminLastLoginName = $sql->mysqli->real_escape_string($admin->LastLoginName);
    
    $escapedReason = $sql->mysqli->real_escape_string(htmlspecialchars($reason));

    $query = $sql->query("SELECT * FROM `" . Config::$t_AmxMute_name . "`  
                          WHERE (`player_ip` LIKE '%$playerLastLoginIP%' OR `player_id` LIKE '%$playerLastLoginID%') 
                          AND `expired` = 0;");
    $c_query = mysqli_num_rows($query);
    $row = mysqli_fetch_array($query);

    if ($c_query > 0) {
        echo "alreadymuted [" . $row['bid'] . "]";
        return;
    } else {
        $query = $sql->query("INSERT INTO `".Config::$t_AmxMute_name."`
        (
            `player_ip`,
            `player_id`,
            `player_nick`,
            `admin_ip`,
            `admin_id`,
            `admin_nick`,
            `mute_reason`,
            `mute_created`,
            `mute_length`,
            `mute_type`,
            `expired`,
            `isNew`,
            `MutedByPlayerId`,
            `MutedPlayerId`,
            `MutedByAdminPerm`
        ) VALUES (
            '$playerLastLoginIP', 
            '$playerLastLoginID', 
            '$playerLastLoginName', 
            '$adminLastLoginIP', 
            '$adminLastLoginID', 
            CONCAT('$adminLastLoginName', ' (WebAdmin)'),
            '$escapedReason', 
            '" . time() . "', 
            '$muteLength', 
            '$muteType', 
            '0',
            '1',
            '{$admin->id}',
            '{$player->id}',  
            '$AdminLvL');
        ");
        $passargs = array("i", mysqli_insert_id($sql->mysqli), "i", "1", "i", "2");
        sck_CallPawnFunc("BanSystemv4.amxx", "LoadWebadmin", $passargs);
        echo 'success';
        //TODO SOCKET
    }
}
?>
