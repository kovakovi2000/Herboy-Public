<?php
require 'SteamConfig.php';

if (empty($_SESSION['steam_uptodate']) or empty($_SESSION['steam_personaname'])) {
    $apiUrl = "https://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=" . $steamauth['apikey'] . "&steamids=" . $_SESSION['steamid'];
    $ch = curl_init();

    curl_setopt($ch, CURLOPT_URL, $apiUrl);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_TIMEOUT, 15); 
    curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true); 
    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
    curl_setopt($ch, CURLOPT_DNS_CACHE_TIMEOUT, 3600);

    $response = curl_exec($ch);

    if (curl_errno($ch)) {
        return "FatalError";
    }
    curl_close($ch);

    $content = json_decode($response, true);

    $_SESSION['steam_steamid'] = $content['response']['players'][0]['steamid'];
    //$_SESSION['steam_communityvisibilitystate'] = $content['response']['players'][0]['communityvisibilitystate'];
    //$_SESSION['steam_profilestate'] = $content['response']['players'][0]['profilestate'];
    $_SESSION['steam_personaname'] = $content['response']['players'][0]['personaname'];
    //$_SESSION['steam_lastlogoff'] = $content['response']['players'][0]['lastlogoff'];
    $_SESSION['steam_profileurl'] = $content['response']['players'][0]['profileurl'];
    $_SESSION['steam_avatar'] = $content['response']['players'][0]['avatar'];
    $_SESSION['steam_avatarmedium'] = $content['response']['players'][0]['avatarmedium'];
    $_SESSION['steam_avatarfull'] = $content['response']['players'][0]['avatarfull'];
    $_SESSION['steam_personastate'] = $content['response']['players'][0]['personastate'];
    if (isset($content['response']['players'][0]['realname'])) { 
        $_SESSION['steam_realname'] = $content['response']['players'][0]['realname'];
    } else {
        $_SESSION['steam_realname'] = "Real name not given";
    }
    $_SESSION['steam_primaryclanid'] = $content['response']['players'][0]['primaryclanid'];
    $_SESSION['steam_timecreated'] = $content['response']['players'][0]['timecreated'];
    $_SESSION['steam_uptodate'] = time();
}

$id = $_SESSION['steamid'];
$idNumber = '0';

if (bcmod($id, '2') == 0) {
    $temp = bcsub($id, 76561197960265728);
} else {
    $idNumber = '1';
    $temp = bcsub($id, bcadd(76561197960265728, '1'));
}

$accountNumber = bcdiv($temp, '2') ?? 0;
$accountNumber = number_format($accountNumber, 0, '', '');
$steamprofile['steamidLegacy'] = "STEAM_0:{$idNumber}:{$accountNumber}";

$steamprofile['steamid'] = $_SESSION['steam_steamid'];
//$steamprofile['communityvisibilitystate'] = $_SESSION['steam_communityvisibilitystate'];
//$steamprofile['profilestate'] = $_SESSION['steam_profilestate'];
$steamprofile['personaname'] = $_SESSION['steam_personaname'];
//$steamprofile['lastlogoff'] = $_SESSION['steam_lastlogoff'];
$steamprofile['profileurl'] = $_SESSION['steam_profileurl'];
$steamprofile['avatar'] = $_SESSION['steam_avatar'];
$steamprofile['avatarmedium'] = $_SESSION['steam_avatarmedium'];
$steamprofile['avatarfull'] = $_SESSION['steam_avatarfull'];
$steamprofile['personastate'] = $_SESSION['steam_personastate'];
$steamprofile['realname'] = $_SESSION['steam_realname'];
//$steamprofile['primaryclanid'] = $_SESSION['steam_primaryclanid'];
//$steamprofile['timecreated'] = $_SESSION['steam_timecreated'];
$steamprofile['uptodate'] = $_SESSION['steam_uptodate'];
?>
