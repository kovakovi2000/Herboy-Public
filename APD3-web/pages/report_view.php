<?php
ErrorManager::$force_no_display = true;

function getIP()
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

    // Strip any secondary IP etc from the IP address
    if (strpos($ip, ',') > 0) {
        $ip = substr($ip, 0, strpos($ip, ','));
    }
    return $ip;
}

function html_error($code)
{
    http_response_code($code);
    $_GET = array();
    $_GET[$code] = "";
    include_once($_SERVER['DOCUMENT_ROOT'] . "/error.php");
    die();
}

// Only allow requests from IP address 193.39.15.51
$allowed_ip = '193.39.15.51';
if (getIP() !== $allowed_ip) {
    html_error(403);
}

// Check if the 'report' parameter is provided in the query string
if (isset($_GET['report'])) {
    // Sanitize the report ID to avoid directory traversal attacks
    $report_id = preg_replace('/[^a-zA-Z0-9_\-]/', '', $_GET['report']);

    // Map the report ID to the correct file path
    $report_file = $_SERVER['DOCUMENT_ROOT']. "/logs/page_report/" . $report_id . ".rep";

    // Check if the file exists and is readable
    if (file_exists($report_file) && is_readable($report_file)) {
        // Display the content of the report file as plain text
        header('Content-Type: text/plain');
        readfile($report_file);
    } else {
        // File not found or not accessible
        header('HTTP/1.0 404 Not Found');
        echo 'Report not found.';
    }
} else {
    // If no 'report' parameter is provided, show an error
    echo 'Please specify a report ID.';
}
?>
