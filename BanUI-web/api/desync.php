<?php
if (session_status() === PHP_SESSION_NONE)
    session_start();

if($_SESSION['user'] != "kova")
{
    http_response_code(401);
    exit();
}

include_once("../utils.php");
include_once("../error_manager.php");
include_once("../sql.php");
include_once("../validate_token.php");

// Ensure the request is a POST request
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405); // Method Not Allowed
    exit('Invalid request method.');
}

// Retrieve the UUID from the POST request
$uuid = filter_input(INPUT_POST, 'uuid', FILTER_SANITIZE_FULL_SPECIAL_CHARS);

if (!$uuid) {
    http_response_code(400); // Bad Request
    exit('Invalid or missing UUID.');
}

try {
    // Fetch the current data for the UUID
    $query = "SELECT data FROM amx_cookie_v2 WHERE UUID = :uuid";
    $stmt = $pdo->prepare($query);
    $stmt->bindParam(':uuid', $uuid);
    $stmt->execute();
    
    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($result) {
        // Decode the JSON data
        $data = json_decode($result['data'], true);

        // Remove the full PAIRs list content
        $data['PAIRs'] = [];

        // Filter STEAMIDs, keeping only those with is_sync = false
        if (isset($data['STEAMIDs']) && is_array($data['STEAMIDs'])) {
            $data['STEAMIDs'] = array_values(array_filter($data['STEAMIDs'], function ($steamid) {
                return !$steamid['is_sync']; // Remove if is_sync is true
            }));
        }

        // Filter IPs, keeping only those with is_sync = false
        if (isset($data['IPs']) && is_array($data['IPs'])) {
            $data['IPs'] = array_values(array_filter($data['IPs'], function ($ip) {
                return !$ip['is_sync']; // Remove if is_sync is true
            }));
        }

        // Ensure other fields that should be arrays remain arrays
        $data['ACCOUNTs'] = array_values((array) $data['ACCOUNTs']);
        $data['USERAGENTs'] = array_values((array) $data['USERAGENTs']);
        $data['PUNISHLOGs'] = array_values((array) $data['PUNISHLOGs']);
        $data['OLDUKEY'] = array_values((array) $data['OLDUKEY']);

        // Re-encode the modified data to JSON
        $updatedData = json_encode($data);

        // Update the database with the modified data
        $updateQuery = "UPDATE amx_cookie_v2 SET data = :updatedData WHERE UUID = :uuid";
        $updateStmt = $pdo->prepare($updateQuery);
        $updateStmt->bindParam(':updatedData', $updatedData);
        $updateStmt->bindParam(':uuid', $uuid);
        $updateStmt->execute();

        http_response_code(200); // Success
    } else {
        http_response_code(404); // Not Found
    }
} catch (PDOException $e) {
    http_response_code(500); // Internal Server Error
    exit('Database query error: ' . $e->getMessage());
}
