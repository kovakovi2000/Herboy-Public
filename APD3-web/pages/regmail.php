<?php
ErrorManager::$force_no_display = true;
require_once($_SERVER['DOCUMENT_ROOT'] . "/configs/Config.php");
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/includes/Utils.php");
require_once($_SERVER['DOCUMENT_ROOT'] . "/configs/includes/email.php");

global $sql;
header('Content-Type: text/html; charset=utf-8');
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

$allowed_ips = ['127.0.0.1', 'localhost', '194.180.16.153','193.39.15.51' ];

$client_ip = getRealIP();


if (!ipInRange($client_ip, '172.18.0.0/24') && !in_array($client_ip, $allowed_ips)) {
    Utils::html_error(401);
    exit();
}

function obfuscate_email($email) {
    $em = explode("@", $email);
    $name = implode('@', array_slice($em, 0, count($em)-1));
    $len = floor(strlen($name) / 2);
    return substr($name, 0, $len) . str_repeat('*', $len) . "@" . end($em);   
}

if (!isset($_GET['id']) || empty($_GET['id'])) {
    http_response_code(400);
    die(json_encode(['error' => 'User ID not provided.']));
}

$user_id = intval($_GET['id']);

try {
    $stmt = $sql->prepare("SELECT LastLoginName, Email, Username FROM herboy_regsystem WHERE id = ?");
    $stmt->bind_param("i", $user_id);
    $stmt->execute();
    $result = $stmt->get_result();
    $user = $result->fetch_assoc();

    if (!$user) {
        http_response_code(404);
        die(json_encode(['error' => 'User not found.']));
    }

    $pwcng_token = bin2hex(random_bytes(16));

    Mailing::Mail_NewReg($user['Email'], $user['Username'], $user_id, $user['LastLoginName']);

    echo json_encode(['success' => 'Email sent successfully.']);
} catch (Exception $e) {
    http_response_code(500);
    die(json_encode(['error' => 'An error occurred while processing the request.', 'details' => $e->getMessage()]));
}
?>
