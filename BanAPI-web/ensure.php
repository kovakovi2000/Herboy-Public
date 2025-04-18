<?php 
ignore_user_abort(true);
$final_url = filter_input(INPUT_GET, 'f', FILTER_SANITIZE_FULL_SPECIAL_CHARS);
function finished()
{
    global $final_url;
    header("Location: ".(empty($final_url) ? "http://87.229.115.72/ban_api/motd_herboy.html?ver122254123" : $final_url) );
    exit();
}
register_shutdown_function('finished');

$g_steam = filter_input(INPUT_GET, 'st', FILTER_SANITIZE_FULL_SPECIAL_CHARS);
$g_ipv4 = filter_input(INPUT_GET, 'i', FILTER_SANITIZE_FULL_SPECIAL_CHARS);
$g_validator = filter_input(INPUT_GET, 'v', FILTER_VALIDATE_INT);
$g_server = filter_input(INPUT_GET, 'se', FILTER_VALIDATE_INT);
$gid = filter_input(INPUT_GET, 'gi', FILTER_VALIDATE_INT);
$local = "AmxxBanSystemUUID;{$g_steam};{$g_ipv4};{$g_validator};{$gid}";

switch ($g_server) {
    case 1:
        require_once("config_avatar.php"); 
        break;
    case 2:
        require_once("config_dev.php"); 
        break;
    case 3:
        require_once("config_herboy.php"); 
        break;
    case 4:
        require_once("config_sdev.php"); 
        break;
    default:
        finished();
}
require_once('_socket.php');
sck_set_server($skt_host,0);

if(md5($local) == $_GET['h'])
    finished();

if(!isset($_COOKIE[$cookiename]))
{
    $passargs = array("i", $gid, "i", $g_validator, "i", 2);
    $skres = sck_CallPawnFunc("BanSystemv4.amxx", "validationfailed", $passargs);
}

?>