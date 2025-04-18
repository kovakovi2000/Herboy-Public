<?php
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/Config.php");
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/includes/Utils.php");
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/includes/_socket.php");

global $sql;

$ban_id = isset($_POST['ban_id']) ? intval($_POST['ban_id']) : 0;
$new_ban_length = isset($_POST['new_ban_length']) ? intval($_POST['new_ban_length']) : 0;
$new_reason = isset($_POST['new_reason']) ? trim($_POST['new_reason']) : '';

$lastLoginName = '';
$adminUserId = 0; // Initialize admin's account ID (UserId)

$userProfile = null;
if (isset($_SESSION['account'])) {
    $userProfile = unserialize($_SESSION['account']);
    if(!$userProfile || !$userProfile->PermLvl->isAdmin())
    {
        Utils::html_error(401);
        exit();
    }
    if ($userProfile && isset($userProfile->LastLoginName)) {
        $lastLoginName = $userProfile->LastLoginName;
        $userId = $userProfile->id ?? 0;
    }
}
else
{
    Utils::html_error(401);
    exit();
}

if ($ban_id > 0 && !empty($new_reason)) {
    $current_time = time();


    $query = "
        UPDATE `" . Config::$t_AmxBan_name . "` 
        SET `ban_reason` = ?, 
            `ban_length` = ?, 
            `ban_created` = ?, 
            `modified` = 1, 
            `modifiedby` = ?
        WHERE `bid` = ?
    ";

    if ($stmt = $sql->prepare($query)) {
        $ban_length = $new_ban_length > 0 ? $new_ban_length : 0;
        $stmt->bind_param('siisi', $new_reason, $ban_length, $current_time, $lastLoginName, $ban_id);
        $stmt->execute();
        $stmt->close();
    }


    $log_query = "
        INSERT INTO `amx_bans_modified` (`bid`, `UserId`, `ban_reason`, `ModifiedAt`, `ban_length`)
        VALUES (?, ?, ?, ?, ?)
    ";

    if ($log_stmt = $sql->prepare($log_query)) {
        $log_stmt->bind_param('iissi', $ban_id, $userId, $new_reason, $current_time, $new_ban_length);
        $log_stmt->execute();
        $log_stmt->close();
    }
    $passargs = array("i", $ban_id, "i", "2", "i", "1");
    sck_CallPawnFunc("BanSystemv4.amxx", "LoadWebadmin", $passargs);
}

$sql->close();
?>
