<?php
if (session_status() === PHP_SESSION_NONE)
    session_start();
include_once("../utils.php");
include_once("../error_manager.php");
include_once("../sql.php");

define('SALT', '0191cf86-cd65-7934-9758-5997e870b5d3'); // Define your salt here

// Function to verify the CSRF token
function verify_csrf_token($token) {
    return isset($_SESSION['csrf_token']) && hash_equals($_SESSION['csrf_token'], $token);
}

function insert_loginlog($pdo, $username, $token, $login_type, $successful) {
    global $localIp;
    $ip = $localIp;
    $useragent = $_SERVER['HTTP_USER_AGENT'];
    
    $stmt = $pdo->prepare("
        INSERT INTO loginlog (username, token, login_time, login_type, useragent, successful, ip)
        VALUES (:username, :token, NOW(), :login_type, :useragent, :successful, :ip)
    ");
    $stmt->bindParam(':username', $username);
    $stmt->bindParam(':token', $token);
    $stmt->bindParam(':login_type', $login_type);
    $stmt->bindParam(':useragent', $useragent);
    $stmt->bindParam(':successful', $successful, PDO::PARAM_BOOL);
    $stmt->bindParam(':ip', $ip);
    $stmt->execute();
}

function check_failed_logins($pdo, $username) {
    global $localIp;
    $ip = $localIp;
    // Check for failed logins by IP in the last hour
    $ip_check_stmt = $pdo->prepare("
        SELECT COUNT(*) as failed_attempts 
        FROM loginlog 
        WHERE ip = :ip 
        AND successful = 0 
        AND login_time >= NOW() - INTERVAL 1 HOUR
    ");
    $ip_check_stmt->bindParam(':ip', $ip);
    $ip_check_stmt->execute();
    $failed_ip_attempts = $ip_check_stmt->fetchColumn();

    // Check for failed logins by username in the last hour
    $username_check_stmt = $pdo->prepare("
        SELECT COUNT(*) as failed_attempts 
        FROM loginlog 
        WHERE username = :username 
        AND successful = 0 
        AND login_time >= NOW() - INTERVAL 1 HOUR
    ");
    $username_check_stmt->bindParam(':username', $username);
    $username_check_stmt->execute();
    $failed_username_attempts = $username_check_stmt->fetchColumn();

    // If more than 4 failed login attempts for IP or more than 10 for username, return false
    if ($failed_ip_attempts >= 4 || $failed_username_attempts >= 10) {
        return false;
    }

    return true;
}

function update_account_login_info($pdo, $username, $login_token) {
    $useragent = $_SERVER['HTTP_USER_AGENT']; // Get the user agent

    $stmt = $pdo->prepare("
        UPDATE account 
        SET token = :login_token, useragent = :useragent
        WHERE username = :username
    ");
    $stmt->bindParam(':login_token', $login_token);
    $stmt->bindParam(':useragent', $useragent);
    $stmt->bindParam(':username', $username);
    $stmt->execute();
}

// Check if the request is a POST request
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Retrieve the posted values
    $username = filter_input(INPUT_POST, 'username', FILTER_SANITIZE_FULL_SPECIAL_CHARS);
    $password = filter_input(INPUT_POST, 'password', FILTER_SANITIZE_FULL_SPECIAL_CHARS);
    $csrf_token = filter_input(INPUT_POST, 'csrf_token', FILTER_SANITIZE_FULL_SPECIAL_CHARS);
    $register_token = filter_input(INPUT_POST, 'register_token', FILTER_SANITIZE_FULL_SPECIAL_CHARS);

    if(empty($register_token))
    {
        // Check CSRF token validity
        if (!verify_csrf_token($csrf_token)) {
            http_response_code(403);
            exit();
        }

        // Regex check on the username and password
        if (!regex_validate($username) || !regex_validate($password)) {
            insert_loginlog($pdo, $username, '', 'password', 0); // Log the failed attempt
            http_response_code(422); // Unprocessable entity
            exit();
        }

        // Check for too many failed login attempts
        if (!check_failed_logins($pdo, $username)) {
            http_response_code(429); // Too many requests
            exit();
        }

        // Prepare the hashed password using SHA256 with salt
        $hashed_password = hash('sha256', SALT . $password);

        // Check if the user exists in the database
        $stmt = $pdo->prepare("SELECT * FROM account WHERE username = :username AND password = :password");
        $stmt->bindParam(':username', $username);
        $stmt->bindParam(':password', $hashed_password);
        $stmt->execute();

        if ($stmt->rowCount() > 0) {
            // Login successful
            $_SESSION['user'] = $username;

            // Create a secure session token
            $login_token = bin2hex(random_bytes(32));
            setcookie('bansysv2_token', $login_token, time() + (30 * 24 * 60 * 60), '/', '', true, true);
            $_SESSION['bansysv2_token'] = $login_token;

            // Insert into loginlog
            insert_loginlog($pdo, $username, $login_token, 'password', 1); // Log the successful login
            // Update the account table with login_token and useragent
            update_account_login_info($pdo, $username, $login_token);
            
            http_response_code(200);
        } else {
            // Invalid credentials
            insert_loginlog($pdo, $username, '', 'password', 0); // Log the failed attempt
            http_response_code(401); // Unauthorized
        }
    }
    else
    {
        if (!verify_csrf_token($csrf_token)) {
            echo "csrf token error, reload the page please";
            exit();
        }

        // Check if the credentials are valid
        if (!regex_validate($username) || !regex_validate($password) || !regex_validate($register_token, 100)) {
            echo "The username and password can only contains [ a-z A-Z 0-9 +-<>()[]=_.,:!?* ]";
            // Return a failed response
        } else {
            // Prepare the hashed password using SHA256 with salt
            $hashed_password = hash('sha256', SALT . $password);

            // Check if the register token exists and is unassigned
            $stmt = $pdo->prepare("SELECT * FROM regtoken WHERE token = :register_token AND username IS NULL");
            $stmt->bindParam(':register_token', $register_token);
            $stmt->execute();

            if ($stmt->rowCount() > 0) {
                // Check if the username is already taken
                $username_check_stmt = $pdo->prepare("SELECT * FROM account WHERE username = :username");
                $username_check_stmt->bindParam(':username', $username);
                $username_check_stmt->execute();

                if ($username_check_stmt->rowCount() > 0) {
                    // Username is already taken
                    echo "Username is already taken.";
                    http_response_code(200); // Conflict response
                    exit();
                }

                // Update the regtoken with the current username
                $update_stmt = $pdo->prepare("UPDATE regtoken SET username = :username WHERE token = :register_token");
                $update_stmt->bindParam(':username', $username);
                $update_stmt->bindParam(':register_token', $register_token);
                $update_stmt->execute();

                // Insert a new account, leaving token empty initially
                $insert_stmt = $pdo->prepare("
                    INSERT INTO account (username, password, token, register_time) 
                    VALUES (:username, :password, '', NOW())
                ");
                $insert_stmt->bindParam(':username', $username);
                $insert_stmt->bindParam(':password', $hashed_password);
                $insert_stmt->execute();

                // Return success response
                echo "Account successfully created!";
                http_response_code(202);
                exit();
            } else {
                // Token does not exist or is already used
                echo "Invalid or already used registration token.";
            }
        }
        http_response_code(200);
    }
} else {
    // Reject non-POST requests
    http_response_code(405);
}