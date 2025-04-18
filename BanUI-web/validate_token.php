<?php

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

function validate_token_and_restore_session($pdo, $cookie_token) {
    // Get the current user agent
    $current_useragent = $_SERVER['HTTP_USER_AGENT'];

    // Prepare a statement to check if the token exists in the account table and the useragent matches
    $stmt = $pdo->prepare("SELECT username, token, useragent FROM account WHERE token = :token AND useragent = :useragent");
    $stmt->bindParam(':token', $cookie_token);
    $stmt->bindParam(':useragent', $current_useragent);
    $stmt->execute();
    
    // If we find a match, restore the session
    if ($stmt->rowCount() > 0) {
        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        if (session_status() === PHP_SESSION_NONE)
            session_start();
        // Restore the session
        $_SESSION['user'] = $result['username'];
        $_SESSION['bansysv2_token'] = $cookie_token;

        // Log the session restoration into loginlog
        insert_loginlog($pdo, $result['username'], $cookie_token, 'token', 1);

        return true;
    }

    // No match found, return false
    return false;
}



if(isset($_COOKIE['bansysv2_token']) && !isset($_SESSION['bansysv2_token']))
{
    if(validate_token_and_restore_session($pdo, $_COOKIE['bansysv2_token']))
    {
        header("Refresh:0");
        exit();
    }
    elseif ($_SERVER['REQUEST_METHOD'] !== 'POST')
    {
        include_once("login.php");
        exit();
    }
}
elseif (!isset($_COOKIE['bansysv2_token']) || !isset($_SESSION['bansysv2_token']) || ($_COOKIE['bansysv2_token'] != $_SESSION['bansysv2_token'])) {
    if ($_SERVER['REQUEST_METHOD'] !== 'POST')
        include_once("login.php");
    exit();
}