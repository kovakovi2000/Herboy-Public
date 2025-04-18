<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

$currtime = date('Y-m-d H:i:s');
$Errors = array();
$ThrowError = false;

function finished()
{
    global $Errors, $ThrowError, $final_url;

    $ThrowError = true;
    checkExecution();

    // Log all errors before finishing
    if (!empty($Errors)) {
        foreach ($Errors as $error_message) {
            log_error_to_file($error_message);
        }
    }
    
    exit();
}
register_shutdown_function('finished');

function checkExecution()
{
    global $Errors, $currtime, $runtime;

    // Ensure $runtime is an array or default to an empty array
    if (!isset($runtime) || !is_array($runtime)) {
        $runtime = []; // Initialize as an empty array if not set
    }

    // Calculate the total runtime
    $runtime_time = array_sum(array_column($runtime, 'time'));
    $connection_status = connection_status();

    if ($runtime_time > 10 || $connection_status !== CONNECTION_NORMAL || !empty($Errors)) {
        // Generate a new UUID for the report file
        $report_uuid = uuidv4();
        $report_filename = "240831__{$report_uuid}.rep";
        $report_directory = __DIR__."/reps/";

        // Check if the directory exists, if not, create it
        if (!is_dir($report_directory)) {
            mkdir($report_directory, 0755, true);
        }
        $shutdown_reason = "";

        if ($connection_status === CONNECTION_NORMAL && connection_aborted())
            $connection_status = CONNECTION_ABORTED;

        if ($connection_status === CONNECTION_NORMAL) {
            $shutdown_reason = "Script completed normally.";
        } elseif ($connection_status & CONNECTION_ABORTED) {
            $shutdown_reason = "Script was interrupted by the user.";
        } elseif ($connection_status & CONNECTION_TIMEOUT) {
            $shutdown_reason = "Script was interrupted due to a timeout.";
        } else {
            $shutdown_reason = "Script was interrupted for an unknown reason.";
        }

        // Prepare the report content
        $report_content = "*************** ".$currtime." ***************\n";
        $report_content .= "SHUTDOWN REASON: ".$shutdown_reason."\n";
        $report_content .= "WAS THERE ERROR?: ".(!empty($Errors) ? "TRUE" : "FALSE")."\n";
        $report_content .= "**************************************************\n";

        // Append $_COOKIE, $_ENV, $_FILES, $_GET, $_POST, $_REQUEST, $_SERVER, $_SESSION in JSON format
        $report_content .= json_encode([
            'COOKIE' => $_COOKIE,
            'ENV' => $_ENV,
            'FILES' => $_FILES,
            'GET' => $_GET,
            'POST' => $_POST,
            'REQUEST' => $_REQUEST,
            'SERVER' => $_SERVER,
            'SESSION' => $_SESSION ?? []
        ], JSON_PRETTY_PRINT) . "\n\n";

        if (!empty($Errors)) {
            $report_content .= "Errors:\n";
            foreach ($Errors as $error_message) {
                $report_content .= $error_message."\n";
            }
            $report_content .= "\n";
        }

        // Write the report content to the file
        file_put_contents($report_directory . $report_filename, $report_content);
    }
}


function log_error_to_file($log)
{
    global $localIp;

    $logDirectory = __DIR__."/logs/";
    $logFile = "ERROR_" . date('Y-m-d') . ".log";
    $logPath = $logDirectory . $logFile;

    // Ensure the log directory is writable
    if (!is_writable($logDirectory)) {
        error_log("Log directory is not writable: " . $logDirectory);
        return;
    }

    file_put_contents(
        $logPath,
        date('Y/m/d H:i:s'). " | " . $localIp . " | " . $log . "\n",
        FILE_APPEND
    );
}

function ErrorManager_Handler($errno, $errstr, $errfile, $errline)
{
    global $Errors, $ThrowError;

    // Error number to string mapping
    $error_types = [
        E_ERROR             => 'E_ERROR',
        E_WARNING           => 'E_WARNING',
        E_PARSE             => 'E_PARSE',
        E_NOTICE            => 'E_NOTICE',
        E_CORE_ERROR        => 'E_CORE_ERROR',
        E_CORE_WARNING      => 'E_CORE_WARNING',
        E_COMPILE_ERROR     => 'E_COMPILE_ERROR',
        E_COMPILE_WARNING   => 'E_COMPILE_WARNING',
        E_USER_ERROR        => 'E_USER_ERROR',
        E_USER_WARNING      => 'E_USER_WARNING',
        E_USER_NOTICE       => 'E_USER_NOTICE',
        E_STRICT            => 'E_STRICT',
        E_RECOVERABLE_ERROR => 'E_RECOVERABLE_ERROR',
        E_DEPRECATED        => 'E_DEPRECATED',
        E_USER_DEPRECATED   => 'E_USER_DEPRECATED',
        E_ALL               => 'E_ALL',
    ];

    if (strpos($errstr, "Implicit conversion from float") !== false) {
        return;
    }

    // Convert the error number to its string representation
    $errno_str = isset($error_types[$errno]) ? $error_types[$errno] : 'UNKNOWN_ERROR';

    $errfile = str_replace("\\", "/", $errfile);
    preg_match('/\$[0-9a-zA-Z:_-]*/', $errstr, $variable);

    $error_message = sprintf(
        "Error No: [%d] %s | Message: %s | File: %s | Line: %d | Variable: %s",
        $errno,
        $errno_str,
        str_replace($_SERVER['DOCUMENT_ROOT'] . "/", "", $errstr),
        str_replace($_SERVER['DOCUMENT_ROOT'] . "/", "", $errfile),
        $errline,
        empty($variable[0]) ? 'None' : implode(", ", $variable)
    );

    if(!$ThrowError)
        $Errors[] = $error_message;
}
set_error_handler("ErrorManager_Handler");

function triggerCustomError($errno, $errstr, $errfile = __FILE__, $errline = __LINE__)
{
    // Use the ErrorManager_Handler to log the error
    ErrorManager_Handler($errno, "[CUSTOM] ".$errstr, $errfile, $errline);
}

//triggerCustomError(E_USER_WARNING,'FORCE REPORT', __FILE__, __LINE__);
?>