<?php

ini_set('display_errors', '1');
ini_set('display_startup_errors', '1');
error_reporting(E_ALL);

function getRealIP()
{
    //return mt_rand(1, 255) . '.' . mt_rand(0, 255) . '.' . mt_rand(0, 255) . '.' . mt_rand(0, 255);

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

function ipInRange($ip, $range) {
    list($subnet, $maskBits) = explode('/', $range);
    $ipDecimal = ip2long($ip);
    $subnetDecimal = ip2long($subnet);
    $mask = -1 << (32 - $maskBits);
    $subnetDecimal &= $mask; // Apply the mask to the subnet

    return ($ipDecimal & $mask) === $subnetDecimal;
}

//$RealIP = getRealIP();
//if (!ipInRange($RealIP, '127.0.0.1/24') || $RealIP != '37.221.210.130') {
    //html_error(403);
//}

// Get and validate the 'n' (port) parameter as an integer
$port = filter_input(INPUT_GET, 'n', FILTER_VALIDATE_INT);

// Get and validate the 's' (server) parameter as an integer
$server = filter_input(INPUT_GET, 's', FILTER_VALIDATE_INT);

if ($port !== false && $server !== false) {
    // Both 'n' (port) and 's' (server) are valid integers
    
    // Specify the file to write to, using the server value
    $filename = 'port_' . $server . '.txt';

    // Write the value of 'n' (port) to the file
    file_put_contents($filename, $port);
    file_put_contents("/var/www/html_dev/ban_api/".$filename, $port);

    // Optionally, you can return a response
} elseif($port !== false && $server === false) {
    $filename = 'port.txt';

    // Write the value of 'n' to the file
    file_put_contents($filename, $port);
    file_put_contents("/var/www/html_dev/ban_api/".$filename, $port);
} else {
    // Invalid input
}
?>