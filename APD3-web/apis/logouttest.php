<?php
ErrorManager::$force_no_display = true;
ob_clean();
header('Content-Type: application/json');
require_once($_SERVER['DOCUMENT_ROOT'] . "/configs/Config.php");
global $sql;

// Rate limiting configuration
define('RATE_LIMIT_REQUESTS', 5); // Maximum requests allowed
define('RATE_LIMIT_WINDOW', 60); // Time window in seconds

// Helper function to get client IP
function getClientIP() {
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

// Helper function for logging
// Helper function for logging
function logAttempt($status, $userId, $email, $reason = null) {
    $logDir = $_SERVER['DOCUMENT_ROOT'] . '/logs/WEB_SEC/LOGOUT';
    $dateFolder = date('Y-m-d');
    $currentTime = date('H:i:s');
    $ip = getClientIP();

    // Get the user-agent and additional headers for context
    $userAgent = $_SERVER['HTTP_USER_AGENT'] ?? 'Unknown User-Agent';
    $referer = $_SERVER['HTTP_REFERER'] ?? 'Unknown Referer';
    $acceptLanguage = $_SERVER['HTTP_ACCEPT_LANGUAGE'] ?? 'Unknown Language';

    // Create the date folder if it doesn't exist
    $path = "$logDir/$dateFolder/$status";
    if (!is_dir($path)) {
        mkdir($path, 0755, true);
    }

    // Log file path
    $logFile = "$path/LOGOUT_$dateFolder.log";

    // Log entry
    $logEntry = "$currentTime | IP: $ip | UserID: $userId | User-Agent: $userAgent | Referer: $referer | Accept-Language: $acceptLanguage";
    if ($status === 'FAILED' && $reason) {
        $logEntry .= " | Reason: $reason";
    }
    $logEntry .= PHP_EOL;

    // Append log
    file_put_contents($logFile, $logEntry, FILE_APPEND);
}


// Rate limiting
if (!isset($_SESSION['rate_limit'])) {
    $_SESSION['rate_limit'] = [];
}

// Clean old requests from session
$currentTime = time();
if (isset($_SESSION['rate_limit']['timestamps'])) {
    $_SESSION['rate_limit']['timestamps'] = array_filter(
        $_SESSION['rate_limit']['timestamps'],
        fn($timestamp) => ($currentTime - $timestamp) <= RATE_LIMIT_WINDOW
    );
} else {
    $_SESSION['rate_limit']['timestamps'] = [];
}

// Enforce rate limit
if (count($_SESSION['rate_limit']['timestamps']) >= RATE_LIMIT_REQUESTS) {
    $reason = 'Rate limit exceeded';
    logAttempt('FAILED', 'UNKNOWN', 'N/A', $reason);
    echo json_encode(['success' => false, 'message' => $reason]);
    exit();
}

// Add current timestamp to request log
$_SESSION['rate_limit']['timestamps'][] = $currentTime;

// Check for logged-in user
if (isset($_SESSION['account'])) {
    $userProfile = unserialize($_SESSION['account']);
    if ($userProfile) {
        $sessionUserId = $userProfile->id ?? 'Unknown ID';
    } else {
        $reason = 'Invalid user profile';
        logAttempt('FAILED', 'UNKNOWN', 'N/A', $reason);
        echo json_encode(['success' => false, 'message' => $reason]);
        exit();
    }
} else {
    $reason = 'User not logged in';
    logAttempt('FAILED', 'UNKNOWN', 'N/A', $reason);
    echo json_encode(['success' => false, 'message' => $reason]);
    exit();
}

// CSRF token validation
$csrfToken = isset($_SERVER['HTTP_X_CSRF_TOKEN']) ? $_SERVER['HTTP_X_CSRF_TOKEN'] : null;
if (!$csrfToken || $csrfToken !== $_SESSION['csrf_token']) {
    $reason = 'Invalid or missing CSRF token';
    logAttempt('FAILED', $sessionUserId, 'N/A', $reason);
    echo json_encode(['success' => false, 'message' => $reason]);
    exit();
}

// Decode request payload
$requestData = json_decode(file_get_contents('php://input'), true);
$requestUserId = isset($requestData['userId']) ? $requestData['userId'] : null;

// Check if user is trying to log themselves out
if ($requestUserId != $sessionUserId) {
    $reason = 'User attempted to log out another user';
    logAttempt('FAILED', $sessionUserId, 'N/A', $reason);
    echo json_encode(['success' => false, 'message' => 'You can only log yourself out']);
    exit();
}

// Logout process
$logoutStatus = 'LOGGEDOUT';
$stmtCheck = $sql->prepare("SELECT LoginKey FROM herboy_regsystem WHERE id = ?");
$stmtCheck->bind_param("i", $sessionUserId);
$stmtCheck->execute();
$stmtCheck->store_result();

if ($stmtCheck->num_rows > 0) {
    $stmtCheck->bind_result($currentLoginKey);
    $stmtCheck->fetch();

    if ($currentLoginKey === $logoutStatus) {
        logAttempt('FAILED', $sessionUserId, 'N/A', 'User already logged out');
        echo json_encode(['success' => false, 'message' => 'You are already logged out']);
        return;
    }
}

$stmt1 = $sql->prepare("UPDATE herboy_regsystem SET LoginKey = ? WHERE id = ?");
$stmt1->bind_param("si", $logoutStatus, $sessionUserId);
$stmt1->execute();

// Check if updates were successful
if ($stmt1->affected_rows > 0) {
    logAttempt('SUCCESSFUL', $sessionUserId, 'N/A', 'Logout successful');
    echo json_encode(['success' => true, 'userId' => $sessionUserId]);
} else {
    $reason = 'Failed to update logout status';
    logAttempt('FAILED', $sessionUserId, 'N/A', $reason);
    echo json_encode(['success' => false, 'message' => $reason]);
}

$stmt1->close();
$stmtCheck->close();
?>
