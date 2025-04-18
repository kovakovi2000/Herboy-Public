<?php
ErrorManager::$force_no_display = true;
ob_clean();
header('Content-Type: application/json');
require_once($_SERVER['DOCUMENT_ROOT'] . "/configs/Config.php");
global $sql;

// Start session to access CSRF token and user ID
session_start();

// Get the user ID from the session using the account object
if (isset($_SESSION['account'])) {
    $userProfile = unserialize($_SESSION['account']);
    if ($userProfile) {
        $sessionUserId = $userProfile->id ?? 'Unknown ID'; // Using the 'id' from the unserialized object
    } else {
        echo json_encode(['success' => false, 'message' => 'Invalid user profile']);
        exit(); // If the profile is not found, exit
    }
} else {
    echo json_encode(['success' => false, 'message' => 'User not logged in']);
    exit(); // If no account is found, return an error
}

// Get the CSRF token from the request
$csrfToken = isset($_SERVER['HTTP_X_CSRF_TOKEN']) ? $_SERVER['HTTP_X_CSRF_TOKEN'] : null;

// Verify if the CSRF token exists and matches the one stored in the session
if (!$csrfToken || $csrfToken !== $_SESSION['csrf_token']) {
    echo json_encode(['success' => false, 'message' => 'Invalid or missing CSRF token']);
    exit; // Stop execution if CSRF token is invalid
}

// Get the user ID from the request body
$requestData = json_decode(file_get_contents('php://input'), true);
$requestUserId = isset($requestData['userId']) ? $requestData['userId'] : null;

// Ensure the user can only log themselves out
if ($requestUserId != $sessionUserId) {
    echo json_encode(['success' => false, 'message' => 'You can only log yourself out']);
    exit;
}

// Assuming you have a $sql object for database connection
$logoutStatus = 'LOGGEDOUT';

// First, check the current value of LoginKey to avoid the duplicate error
$stmtCheck = $sql->prepare("SELECT LoginKey FROM herboy_regsystem WHERE id = ?");
$stmtCheck->bind_param("i", $sessionUserId);
$stmtCheck->execute();
$stmtCheck->store_result();

if ($stmtCheck->num_rows > 0) {
    $stmtCheck->bind_result($currentLoginKey);
    $stmtCheck->fetch();

    // If the current LoginKey is already 'LOGGEDOUT', skip updating
    if ($currentLoginKey === $logoutStatus) {
        echo json_encode(['success' => false, 'message' => 'Already logged out', 'userId' => $sessionUserId, 'csrf_token' => $_SESSION['csrf_token']]);
        return;
    }
}

// Update the LoginKey in herboy_regsystem table
$stmt1 = $sql->prepare("UPDATE herboy_regsystem SET LoginKey = ? WHERE id = ?");
$stmt1->bind_param("si", $logoutStatus, $sessionUserId);
$stmt1->execute();

// Check if updates were successful
if ($stmt1->affected_rows > 0) {
    echo json_encode(['success' => true, 'userId' => $sessionUserId, 'csrf_token' => $_SESSION['csrf_token']]); // Return userId and CSRF token in the response
} else {
    echo json_encode(['success' => false, 'userId' => $sessionUserId, 'csrf_token' => $_SESSION['csrf_token']]); // Return userId and CSRF token in case of failure
}

// Close the prepared statements
$stmt1->close();
$stmtCheck->close();
?>
