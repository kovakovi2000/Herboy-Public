<?php
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/Config.php");
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/includes/Utils.php");
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/includes/_socket.php");

global $sql;

$mute_id = isset($_POST['mute_id']) ? intval($_POST['mute_id']) : 0;
$new_mute_length = isset($_POST['new_mute_length']) ? intval($_POST['new_mute_length']) : 0;
$new_reason = isset($_POST['new_reason']) ? trim($_POST['new_reason']) : '';
$new_mute_type = isset($_POST['new_mute_type']) ? trim($_POST['new_mute_type']) : '';

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

if ($mute_id > 0 && !empty($new_reason)) {
    $current_time = time();


    $query = "
        UPDATE `" . Config::$t_AmxMute_name . "` 
        SET `mute_reason` = ?, 
            `mute_length` = ?, 
            `mute_created` = ?, 
            `modified` = 1, 
            `modifiedby` = ?,
            `mute_type` = ?
        WHERE `bid` = ?
    ";

    if ($stmt = $sql->prepare($query)) {
        $mute_length = $new_mute_length > 0 ? $new_mute_length : 0;
        $stmt->bind_param('siissi', $new_reason, $mute_length, $current_time, $lastLoginName, $new_mute_type, $mute_id);
        $stmt->execute();
        $stmt->close();
    }

    
    $log_query = "
        INSERT INTO `amx_mutes_modified` (`bid`, `UserId`, `mute_reason`, `ModifiedAt`, `mute_length`)
        VALUES (?, ?, ?, ?, ?)
    ";

    if ($log_stmt = $sql->prepare($log_query)) {
        $log_stmt->bind_param('iissi', $mute_id, $userId, $new_reason, $current_time, $new_mute_length);
        $log_stmt->execute();
        $log_stmt->close();
    }
    $passargs = array("i", $mute_id, "i", "2", "i", "2");
    sck_CallPawnFunc("BanSystemv4.amxx", "LoadWebadmin", $passargs);
}

$sql->close();
?>
