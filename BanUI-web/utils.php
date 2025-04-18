<?php

function getRealIP()
{
    if (isset($_SERVER["HTTP_CLIENT_IP"])) {
        $ip = $_SERVER["HTTP_CLIENT_IP"];
    } elseif (isset($_SERVER["HTTP_X_FORWARDED_FOR"])) {
        $ip = $_SERVER["HTTP_X_FORWARDED_FOR"];
    } elseif (isset($_SERVER["HTTP_X_FORWARDED"])) {
        $ip = $_SERVER["HTTP_X_FORWARDED"];
    } elseif (isset($_SERVER["HTTP_FORWARDED_FOR"])) {
        $ip = $_SERVER["HTTP_FORWARDED_FOR"];
    } elseif (isset($_SERVER["HTTP_FORWARDED"])) {
        $ip = $_SERVER["HTTP_FORWARDED"];
    } else {
        $ip = $_SERVER["REMOTE_ADDR"];
    }

    if (strpos($ip, ',') > 0) {
        $ip = substr($ip, 0, strpos($ip, ','));
    }
    return $ip;
}
$localIp = getRealIP();

function regex_validate($string, $charmax = 32) {
    // Use preg_match to validate the string against the given regular expression
    return preg_match('/^[A-Za-z0-9<>=_.:!\?\*\[\]+,()\-]{3,'.$charmax.'}+$/', $string) === 1;
}

function uuidv4()
{
    $data = random_bytes(16);
    $data[6] = chr(ord($data[6]) & 0x0f | 0x40); 
    $data[8] = chr(ord($data[8]) & 0x3f | 0x80); 
    return vsprintf('%s%s-%s-%s-%s-%s%s%s', str_split(bin2hex($data), 4));
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST')
    include_once("footer.php");