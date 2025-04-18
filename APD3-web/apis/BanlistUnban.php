<?php
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/Config.php");
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/includes/Utils.php");
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/includes/_socket.php");

global $sql;

$ban_id = isset($_POST['ban_id']) ? intval($_POST['ban_id']) : 0;

$userProfile = null;
if (isset($_SESSION['account'])) {
    $userProfile = unserialize($_SESSION['account']);
    if(!$userProfile || !$userProfile->PermLvl->isAdmin())
    {
        Utils::html_error(401);
        exit();
    }
    if ($userProfile) {
        $lastLoginName = $userProfile->LastLoginName ?? 'UnknownAdmin';
        $userId = $userProfile->id ?? 0;
        $userIP = $userProfile->LastLoginIP ?? $_SERVER['REMOTE_ADDR'];
    } else {
        exit();
    }
} else
{
    Utils::html_error(401);
    exit();
}

if ($ban_id > 0) {
    $query = "
        UPDATE `" . Config::$t_AmxBan_name . "` 
        SET `expired` = 2, 
            `UName` = ?, 
            `UID` = ?, 
            `UIP` = ? 
        WHERE `bid` = ?
    ";

    if ($stmt = $sql->prepare($query)) {
        $UName = "$lastLoginName (WebAdmin)";
        $stmt->bind_param('sisi', $UName, $userId, $userIP, $ban_id);
        $stmt->execute();
        $stmt->close();
    }
    $passargs = array("i", $ban_id, "i", "3", "i", "1");
    sck_CallPawnFunc("BanSystemv4.amxx", "LoadWebadmin", $passargs);
}

$sql->close();
?>
