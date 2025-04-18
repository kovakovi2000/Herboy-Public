<?php
ErrorManager::$force_no_display = true;
ob_clean();
header('Content-Type: application/json');
require_once($_SERVER['DOCUMENT_ROOT'] . "/configs/Config.php");
global $sql;

// Rate limiting configuration
define('RATE_LIMIT_REQUESTS', 5); // max requests
define('RATE_LIMIT_WINDOW', 60); // time window in seconds

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
function logAttempt($status, $userId, $email, $reason = null) {
    $logDir = $_SERVER['DOCUMENT_ROOT'] . '/logs/WEB_SEC/PASS';
    $dateFolder = date('Y-m-d');
    $currentTime = date('H:i:s');
    $ip = getClientIP();

    // Retrieve additional headers for more context
    $userAgent = isset($_SERVER['HTTP_USER_AGENT']) ? $_SERVER['HTTP_USER_AGENT'] : 'N/A';
    $referer = isset($_SERVER['HTTP_REFERER']) ? $_SERVER['HTTP_REFERER'] : 'N/A';
    $acceptLanguage = isset($_SERVER['HTTP_ACCEPT_LANGUAGE']) ? $_SERVER['HTTP_ACCEPT_LANGUAGE'] : 'N/A';

    // Create the date folder if it doesn't exist
    $path = "$logDir/$dateFolder/$status";
    if (!is_dir($path)) {
        mkdir($path, 0755, true);
    }

    // Log file path
    $logFile = "$path/PASS_$dateFolder.log";

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

if (!$sessionUserId) {
    $reason = 'Invalid session';
    logAttempt('FAILED', 'UNKNOWN', 'N/A', $reason);
    echo json_encode(['success' => false, 'message' => $reason]);
    exit();
}

// Check CSRF token
$csrfToken = $_SERVER['HTTP_X_CSRF_TOKEN'] ?? null;
if (!$csrfToken || $csrfToken !== $_SESSION['csrf_token']) {
    $reason = 'Invalid CSRF token';
    logAttempt('FAILED', $sessionUserId, 'N/A', $reason);
    echo json_encode(['success' => false, 'message' => $reason]);
    exit();
}

// Get the new password from the request
$data = json_decode(file_get_contents('php://input'), true);
$newPassword = $data['new_password'] ?? null;

// Validate password using regex
if (!preg_match('/^[a-zA-Z0-9]{4,32}+$/', $newPassword)) {
    $reason = 'Password must be 4-32 alphanumeric characters';
    logAttempt('FAILED', $sessionUserId, 'N/A', $reason);
    echo json_encode(['success' => false, 'message' => $reason]);
    exit();
}

// Hash the new password
$salt = Config::$secret_password_salt;
$hashedPassword = hash('sha3-512', hash('sha3-512', $newPassword . $salt));

// Attempt to update the password in the database
$stmt = $sql->prepare("UPDATE herboy_regsystem SET Password = ? WHERE id = ?");
$stmt->bind_param("si", $hashedPassword, $sessionUserId);

if ($stmt->execute()) {
    logAttempt('SUCCESSFUL', $sessionUserId, 'N/A');
    echo json_encode(['success' => true]);
} else {
    $reason = 'Failed to update password';
    logAttempt('FAILED', $sessionUserId, 'N/A', $reason);
    echo json_encode(['success' => false, 'message' => $reason]);
}

$stmt->close();
?>
