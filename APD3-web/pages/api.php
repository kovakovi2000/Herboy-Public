<?php

global $apiname;
$apiname = strip_tags($pagelink[1]);
//echo "trying to request api: '$apiname'</br>";
switch ($apiname) {
    case 'SV':
        include_once($_SERVER['DOCUMENT_ROOT'] . "/apis/skinvote.php");
        break;
    case 'AgreeCookies':
        include_once($_SERVER['DOCUMENT_ROOT'] . "/apis/AgreeCookiesBlank.php");
        break;
    case 'PBD':
        include_once($_SERVER['DOCUMENT_ROOT'] . "/apis/ProfileBanDisplay.php");
        break;
    case 'PMD':
        include_once($_SERVER['DOCUMENT_ROOT'] . "/apis/ProfileMuteDisplay.php");
        break;
    case 'PAD':
        include_once($_SERVER['DOCUMENT_ROOT'] . "/apis/ProfileActivityDisplay.php");
        break;
    case 'PT':
        header('X-Robots-Tag: noindex, nofollow');
        include_once($_SERVER['DOCUMENT_ROOT'] . "/apis/ProfileTouchBan.php");
        break;
    case 'PTM':
        header('X-Robots-Tag: noindex, nofollow');
        include_once($_SERVER['DOCUMENT_ROOT'] . "/apis/ProfileTouchMute.php");
        break;
    case 'PMBD':
        include_once($_SERVER['DOCUMENT_ROOT'] . "/apis/ProfileMuteByDisplay.php");
        break;
    case 'PKD':
        include_once($_SERVER['DOCUMENT_ROOT'] . "/apis/ProfileKickDisplay.php");
        break;
    case 'PBBD':
        include_once($_SERVER['DOCUMENT_ROOT'] . "/apis/ProfileBanByDisplay.php");
        break;
    case 'PCD':
        include_once($_SERVER['DOCUMENT_ROOT'] . "/apis/ProfileScanDisplay.php");
        break;
    case 'BLDD':
        include_once($_SERVER['DOCUMENT_ROOT'] . "/apis/BanlistDataDisplay.php");
        break;
    case 'BLUB':
        header('X-Robots-Tag: noindex, nofollow');
        include_once($_SERVER['DOCUMENT_ROOT'] . "/apis/BanlistUnban.php");
        break;
    case 'BLCB':
        header('X-Robots-Tag: noindex, nofollow');
        include_once($_SERVER['DOCUMENT_ROOT'] . "/apis/BanlistChangeban.php");
         break;
    case 'MLDD':
        include_once($_SERVER['DOCUMENT_ROOT'] . "/apis/MutelistDataDisplay.php");
        break;
    case 'MLUM':
        header('X-Robots-Tag: noindex, nofollow');
        include_once($_SERVER['DOCUMENT_ROOT'] . "/apis/MutelistUnmute.php");
        break;
    case 'MLCM':
        header('X-Robots-Tag: noindex, nofollow');
        include_once($_SERVER['DOCUMENT_ROOT'] . "/apis/MutelistChangemute.php");
        break;
    case 'UDD':
        include_once($_SERVER['DOCUMENT_ROOT'] . "/apis/UserlistDataDisplay.php");
        break;
    case 'CHCS':
        include_once($_SERVER['DOCUMENT_ROOT'] . "/apis/CheckoutCountries.php");
        break;
    case 'AB':
        include_once($_SERVER['DOCUMENT_ROOT'] . "/apis/AliasBox.php");
        break;
    case 'sBan':
        header('X-Robots-Tag: noindex, nofollow');
        include_once($_SERVER['DOCUMENT_ROOT'] . "/apis/setBan.php");
        break;
    case 'sMute':
        header('X-Robots-Tag: noindex, nofollow');
        include_once($_SERVER['DOCUMENT_ROOT'] . "/apis/setMute.php");
        break;
    case 'gMessage':
        header('X-Robots-Tag: noindex, nofollow');
        include_once($_SERVER['DOCUMENT_ROOT'] . "/apis/ChatSystemRequest.php");
        break;
    case 'PWEL':
        header('X-Robots-Tag: noindex, nofollow');
        include_once($_SERVER['DOCUMENT_ROOT'] . "/apis/email.php");
        break;
    case 'UPCD':
        header('X-Robots-Tag: noindex, nofollow');
        include_once($_SERVER['DOCUMENT_ROOT'] . "/apis/logouttest.php");
        break;
    case 'UPCM':
        header('X-Robots-Tag: noindex, nofollow');
        include_once($_SERVER['DOCUMENT_ROOT'] . "/apis/upmail.php");
        break;
    case 'UPCP':
        header('X-Robots-Tag: noindex, nofollow');
        include_once($_SERVER['DOCUMENT_ROOT'] . "/apis/uppass.php");
        break;
    default:
        echo "FAILED</br>";
        Utils::html_error(400);
        break;
}