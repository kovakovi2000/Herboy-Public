<?php
class ErrorManager {
    static $Errors;
    static $ThrowError = false;
    static $devkey;
    static $rt_start;
    static $runtime;
    static $force_no_display = false;
    
    static function isDevelpor()
    {
        return isset($_COOKIE['DevKey']) ? (self::$devkey == $_COOKIE['DevKey']) : false;
    }

    static function track($depth = 1)
    {
        $bt = debug_backtrace();
        Utils::debug($bt, true);
        self::handler(0, "tracker depth: ".$depth, $bt[$depth]['file'], $bt[$depth]['line']);
    }

    static function setDeveloper()
    {
        if(isset($_GET[self::$devkey])) setcookie('DevKey', self::$devkey, time()+60*60*24*365);
    }

    static function init()
    {
        self::$devkey = "3eaf34a2bdde61bbde796365f0cbf0a9";
        self::$Errors = array();
        self::$runtime = array();
        self::$rt_start = microtime(true);
        set_error_handler("ErrorManager::handler");
    }

    private static function isHTTPS() {
        return (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') || $_SERVER['SERVER_PORT'] == 443;
    }

    private static function get_url($href = null) {
        return (self::isHTTPS() ? "https" : "http") . "://" . $_SERVER['SERVER_NAME'] . (isset($href) ? "/" . $href : "" );
    }

    static function running_time($functionname, $subtask)
    {
        $current_time = microtime(true);
        $elapsed_time = $current_time - self::$rt_start;

        self::$runtime[] = [
            'functionname' => $functionname,
            'subtask' => $subtask,
            'time' => $elapsed_time
        ];

        // Reset start time for the next measurement
        self::$rt_start = $current_time;
    }

    // example //ErrorManager::Add(E_USER_WARNING,'FORCE REPORT', __FILE__, __LINE__);
    static function Add($errno, $errstr, $errfile = __FILE__, $errline = __LINE__)
    {
        self::handler($errno, "[CUSTOM] ".$errstr, $errfile, $errline);
    }

    static function handler($errno, $errstr, $errfile, $errline)
    {
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

        self::running_time(str_replace($_SERVER['DOCUMENT_ROOT'] . "/", "", $errfile), "Line: ".$errline);

        self::$ThrowError = true;
        self::$Errors[] = $error_message;
    }

    private static function uuidv4()
    {
        $data = random_bytes(16);
        $data[6] = chr(ord($data[6]) & 0x0f | 0x40); 
        $data[8] = chr(ord($data[8]) & 0x3f | 0x80); 
        return vsprintf('%s%s-%s-%s-%s-%s%s%s', str_split(bin2hex($data), 4));
    }

    static function create_report()
    {
        $runtime_time = array_sum(array_column(self::$runtime, 'time'));
        $connection_status = connection_status();

        if ($runtime_time > 5 || $connection_status !== CONNECTION_NORMAL || !empty(self::$Errors)) {
            // Generate a new UUID for the report file
            $report_uuid = self::uuidv4();
            $report_filename = date('Y-m-d_H-i-s')."__{$report_uuid}.rep";
            $report_directory = $_SERVER['DOCUMENT_ROOT']. "/logs/page_report/";
    
            // Check if the directory exists, if not, create it
            if (!is_dir($report_directory)) {
                mkdir($report_directory, 0755, true);
            }
            $shutdown_reason = "";
    
            if($connection_status === CONNECTION_NORMAL && connection_aborted())
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
            $report_content = "*************** ".date('Y-m-d H:i:s')." ***************\n";
            $report_content .= "EXECUTION EXCEEDED LIMIT: " . number_format($runtime_time, 6) . " seconds\n";
            $report_content .= "SHUTDOWN REASON: ".$shutdown_reason."\n";
            $report_content .= "WAS THERE ERROR?: ".(!empty(self::$Errors) ? "TRUE" : "FALSE")."\n";
            $report_content .= "**************************************************\n\n";

            if (!empty(self::$Errors)) {
                $report_content .= "Errors:\n";
                foreach (self::$Errors as $error_message) {
                    $report_content .= $error_message."\n";
                }
                $report_content .= "\n";
            }
            $report_content .= "\n";

            if (isset($_SESSION['account']))
            {
                $report_content .= "********** SESSION ACCOUNT **********\n";
                $report_content .= json_encode(unserialize($_SESSION['account']), JSON_PRETTY_PRINT) . "\n\n";
            }
            else
            {
                $report_content .= "********** NOT LOGGED IN ACCOUNT **********\n";
            }
    
            $report_content .= "********** FULL REQUEST VARIBLES **********\n";
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
            
            // Append runtime breakdown in ASCII table format
            $report_content .= "********** Runtime Breakdown **********\n";
            $report_content .= "+------------------------------------------+-------------------------+------------------+\n";
            $report_content .= "| Function                                 | Subtask                 | Time (sec)       |\n";
            $report_content .= "+------------------------------------------+-------------------------+------------------+\n";
            foreach (self::$runtime as $entry) {
                $report_content .= sprintf("| %-40s | %-23s | %-16.6f |\n", $entry['functionname'], $entry['subtask'], $entry['time']);
            }
            $report_content .= "+------------------------------------------+-------------------------+------------------+\n\n";

            // Write the report content to the file
            file_put_contents($report_directory . $report_filename, $report_content);
    
            // Send Discord alert with the report filename included
            self::sendDiscordAlert($runtime_time, $report_filename, $connection_status, $shutdown_reason);
        }
    }

    private static function sendDiscordAlert($executionTime, $report_filename, $connection_status, $shutdown_reason)
    {
        // Base URL for the report link
        $reportBaseUrl = "https://".Config::$domain."/report_view?report=";
        $report_id = pathinfo($report_filename, PATHINFO_FILENAME);
        $reportLink = $reportBaseUrl . urlencode($report_id);
    
        // Build the description for the embed
        $desc = (!empty(self::$Errors) ? "There was an error during execution." : ($connection_status === CONNECTION_NORMAL ? 'Execution time exceeded 10 seconds.' : $shutdown_reason));
    
        // If there are errors, format them into a list as a code block
        $error_list = '';
        if (!empty(self::$Errors)) {
            $error_list .= "<@425001439660605442> <@408327130460717058> Errors:\n```ml\n";
            foreach (self::$Errors as $index => $error_message) {
                $error_list .= sprintf("%d. %s\n", $index + 1, $error_message);
            }
            $error_list .= "```";
        } else {
            $error_list = "No errors occurred.";
        }
    
        $id = "N/A";
        if(isset($_SESSION['account']))
        {
            $acc = unserialize($_SESSION['account']);
            if(isset($acc->id))
            {
                $id = $acc->id;
            }
        }
        // Prepare the embed for the report details
        $embed = [
            'title' => 'Execution Time Alert',
            'description' => $desc,
            'color' => 15158332,  // Red color
            'fields' => [
                [
                    'name' => 'Execution Time',
                    'value' => sprintf('%.2f seconds', $executionTime),
                    'inline' => true
                ],
                [
                    'name' => 'CurrUserId',
                    'value' => $id,
                    'inline' => true
                ],
                [
                    'name' => 'Report Link',
                    'value' => "[View Report]($reportLink)"
                ]
            ],
            'footer' => [
                'text' => 'BanSys_v2 Alert System',
            ],
            'timestamp' => date('c')
        ];
    
        // Prepare the data for the Discord webhook
        $data = json_encode([
            'content' => $error_list,  // Errors are placed here outside of the embed
            'embeds' => [$embed],
            'allowed_mentions' => [
                'users' => ['425001439660605442', '408327130460717058']
            ]
        ]);
    
        // Send the message to the Discord webhook
        $ch = curl_init(Config::$apikey_discord_error_webhook);
        curl_setopt($ch, CURLOPT_POST, 1);
        curl_setopt($ch, CURLOPT_POSTFIELDS, $data);
        curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_TIMEOUT, 5);
    
        $response = curl_exec($ch);
        if (curl_errno($ch)) {
            self::Add(E_USER_WARNING,'sendDiscordAlert curl_error: '.curl_error($ch), __FILE__, __LINE__);
        }
        curl_close($ch);
    
        return $response;
    }

    static function display()
    {
        global $apiname;
        self::running_time("FINISH", '');
        if(!defined("PROGRAM_EXECUTION_SUCCESSFUL"))
        {
            $error = error_get_last();

            if($error !== NULL) {
                self::handler($error['type'], $error['message'], $error['file'], $error['line']);
            }
        }

        self::create_report();

        if(!empty($apiname)) return;
        if(!self::isDevelpor()) return;
        if(self::$force_no_display) return;
        ?>
        <link rel="stylesheet" type="text/css" href="<?php echo self::get_url("css/error_box.css");?>">
        <div id="error_box">
            <div id="error_boxheader" <?php if(sizeof(self::$Errors) == 0) echo "style='background-color: grey'";?>>
                <?php echo "ErrorManager found: ". sizeof(self::$Errors)." ERROR" ?>
                <snap class="error_button" onclick="close_error_box()">X</snap>
                <snap class="error_button" onclick="slide_error_box()">▼</snap>
            </div>
            <?php if(sizeof(self::$Errors) > 0): ?>
                <div id="error_list">
                    <?php foreach (self::$Errors as $error): ?>
                        <p>
                            <?php echo "File: ". $error; ?></br>
                        </p>
                    <?php endforeach; ?>
                </div>
            <?php endif; ?>
        </div>
        <script type="text/javascript" src="<?php echo self::get_url("js/error_box.js");?>"></script>
        <?php
    }

    static function getIP()
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

    static function getRequestedUrl() {
        // Determine if the request is secure (HTTPS)
        $protocol = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') ? "https://" : "http://";
    
        // Get the host name
        $host = $_SERVER['HTTP_HOST'] ?? $_SERVER['SERVER_NAME'];
    
        // Get the URI (path and query string)
        $uri = $_SERVER['REQUEST_URI'];
    
        // Combine all parts to form the full URL
        $fullUrl = $protocol . $host . $uri;
    
        return $fullUrl;
    }

    static function LogURL()
    {
        $directory = $_SERVER['DOCUMENT_ROOT'] . "/logs/REQUESTS/";
        
        if (!is_dir($directory)) {
            mkdir($directory, 0755, true);
        }

        $filePath = $directory . date('Y-m-d') . "_requests.txt";
        file_put_contents(
            $filePath,
            date('Y-m-d H:i:s') . " | " . self::getIP() . " | ".(isset(Account::$UserProfile->id) ? Account::$UserProfile->id : "N/A")." | " . self::getRequestedUrl() . PHP_EOL,
            FILE_APPEND
        );
    }
}

ErrorManager::init();
ErrorManager::setDeveloper();
register_shutdown_function('ErrorManager::display');
    
    