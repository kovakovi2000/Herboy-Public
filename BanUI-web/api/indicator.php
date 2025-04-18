<?php
if (session_status() === PHP_SESSION_NONE)
    session_start();
include_once("../utils.php");
include_once("../error_manager.php");
include_once("../sql.php");
include_once("../validate_token.php");

// Check if the request is a POST request
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    exit();
}

// Retrieve the posted values
$indicator_search = filter_input(INPUT_POST, 'indicator_search', FILTER_SANITIZE_FULL_SPECIAL_CHARS);
$indicator_type = filter_input(INPUT_POST, 'indicator_type', FILTER_SANITIZE_FULL_SPECIAL_CHARS);
$manual = filter_input(INPUT_POST, 'manual', FILTER_VALIDATE_INT);

// Ensure the input values are valid
if (!$indicator_search || !$indicator_type) {
    http_response_code(400); // Bad Request
    exit('Invalid input.');
}

function getAccountDetails($pdo, $accountId) {
    $query = "SELECT * 
              FROM herboy_regsystem 
              WHERE id = :account_id";
    
    $params = [
        ':account_id' => $accountId
    ];

    try {
        // Prepare and execute the query
        $stmt = $pdo->prepare($query);
        $stmt->execute($params);
        $accountDetails = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($accountDetails) {
            return $accountDetails;
        } else {
            return null; // No account found
        }

    } catch (PDOException $e) {
        http_response_code(500); // Internal Server Error
        exit('Database query error: ' . $e->getMessage());
    }
}

function insert_search_history($pdo, $username, $indicator, $type, $manual = 0) {
    try {
        // Prepare the SQL query for inserting the search history
        $stmt = $pdo->prepare("
            INSERT INTO search_history (username, indicator, type, manual) 
            VALUES (:username, :indicator, :type, :manual)
        ");

        // Bind the parameters to the SQL query
        $stmt->bindParam(':username', $username);
        $stmt->bindParam(':indicator', $indicator);
        $stmt->bindParam(':type', $type);
        $stmt->bindParam(':manual', $manual);

        // Execute the query
        $stmt->execute();

        return true; // Return true if the insert was successful
    } catch (PDOException $e) {
        // Handle any errors during the query execution
        echo "Error inserting search history: " . $e->getMessage();
        return false;
    }
}

// Prepare SQL query and conditions based on $indicator_type
$query = '';
$params = [];

switch ($indicator_type) {
    case 'any':
        $query = "SELECT * FROM amx_cookie_v2 WHERE UUID LIKE :indicator OR data LIKE :indicator";
        $params[':indicator'] = '%' . $indicator_search . '%';
        break;

    case 'UUID':
        $query = "SELECT * FROM amx_cookie_v2 WHERE UUID = :indicator";
        $params[':indicator'] = $indicator_search;
        break;

    case 'steamid':
        $query = "SELECT * FROM amx_cookie_v2 WHERE steamid_indicators LIKE :indicator";
        $params[':indicator'] = '%' . $indicator_search . '%';
        break;

    case 'ip':
        $query = "SELECT * FROM amx_cookie_v2 WHERE ip_indicators LIKE :indicator";
        $params[':indicator'] = '%' . $indicator_search . '%';
        break;

    case 'oldkey':
        $query = "SELECT * FROM amx_cookie_v2 
                    WHERE JSON_CONTAINS(data->'$.OLDUKEY[*].ukey', :indicator, '$')";
        $params[':indicator'] = json_encode($indicator_search);
        break;
    case 'account':
        // Ensure the column data is valid JSON, and use proper syntax for MariaDB
        $query = "SELECT * FROM amx_cookie_v2 
                    WHERE JSON_CONTAINS(data, :indicator, '$.ACCOUNTs')";
        $params[':indicator'] = json_encode($indicator_search); // If the indicator is a number or string
        break;
    case 'account_uuid':
        $accountDetails = getAccountDetails($pdoreg, $indicator_search);
    
        if (!$accountDetails) {
            echo json_encode(['message' => 'No account found with the given ID.']);
            break;
        }
        $query = "SELECT * FROM amx_cookie_v2 WHERE UUID = :indicator";
        $params[':indicator'] = $accountDetails['LoginKey'];
        break;
    case 'account_info':
        // Get account details from herboy_regsystem
        $accountDetails = getAccountDetails($pdoreg, $indicator_search);
    
        if (!$accountDetails) {
            echo json_encode(['message' => 'No account found with the given ID.']);
            break;
        }
    
        // Extract the relevant details from the account
        $lastLoginID = $accountDetails['LastLoginID'];
        $lastLoginIP = $accountDetails['LastLoginIP'];
        $registerID = $accountDetails['RegisterID'];
        $lastLoginDate = $accountDetails['LastLoginDate'];
    
        // Set up the query and params for amx_cookie_v2
        $query = "SELECT * FROM amx_cookie_v2 
                    WHERE steamid_indicators LIKE :lastLoginID 
                    OR steamid_indicators LIKE :registerID";
    
        $params = [
            ':lastLoginID' => '%' . $lastLoginID . '%',
            ':registerID' => '%' . $registerID . '%',
        ];
    
        // Check if LastLoginDate is within 30 days and include LastLoginIP in the query
        if (strtotime($lastLoginDate) >= strtotime('-30 days')) {
            $query .= " OR ip_indicators LIKE :lastLoginIP";
            $params[':lastLoginIP'] = '%' . $lastLoginIP . '%';
        }
    
        break;

    case 'regex':
        $query = "SELECT * FROM amx_cookie_v2 WHERE data REGEXP :indicator";
        $params[':indicator'] = $indicator_search;
        break;

    default:
        http_response_code(400); // Bad Request
        exit('Invalid indicator type.');
}

// Execute the SQL query
try {
    if (session_status() === PHP_SESSION_NONE)
        session_start();
    insert_search_history($pdo, $_SESSION['user'], $indicator_search, $indicator_type, ($manual == null ? 0:$manual));
    $query .= " ORDER BY lastseen DESC";
    $stmt = $pdo->prepare($query);
    $stmt->execute($params);
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if ($result) {
        echo json_encode($result); // Output the result as JSON
    } else {
        echo json_encode(['message' => 'No results found.', 'status' => 404]);
    }

} catch (PDOException $e) {
    http_response_code(500); // Internal Server Error
    exit('Database query error: ' . $e->getMessage());
}

http_response_code(200);