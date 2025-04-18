<?php
$start_time = microtime(true);

ini_set('display_errors', '1');
ini_set('display_startup_errors', '1');
error_reporting(E_ALL);
$Errors = array();
$checked_uuids = array();
set_error_handler("ErrorManager_Handler");

define('MAX_IP_AGE_DAYS', 30);
define('IP_API_RECHECK_DAYS', 7);

function getRealIP()
{
    return mt_rand(1, 255) . '.' . mt_rand(0, 255) . '.' . mt_rand(0, 255) . '.' . mt_rand(0, 255);

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
    if (strpos($errstr, "Implicit conversion from float") !== false) {
        return;
    }

    $errfile = str_replace("\\", "/", $errfile);
    preg_match('/\$[0-9a-zA-Z:_-]*/', $errstr, $varible);

    $error_message = sprintf(
        "Error No: %d | Message: %s | File: %s | Line: %d | Variable: %s",
        $errno,
        str_replace($_SERVER['DOCUMENT_ROOT']."/", "", $errstr),
        str_replace($_SERVER['DOCUMENT_ROOT']."/", "", $errfile),
        $errline,
        empty($varible[0]) ? 'None' : implode(", ", $varible)
    );

    log_try_error($error_message);
}

$localIp = getRealIP();
$g_steam = filter_input(INPUT_GET, 'st', FILTER_SANITIZE_FULL_SPECIAL_CHARS);
$g_ipv4 = filter_input(INPUT_GET, 'i', FILTER_SANITIZE_FULL_SPECIAL_CHARS);
$g_validator = filter_input(INPUT_GET, 'v', FILTER_VALIDATE_INT);
$g_server = filter_input(INPUT_GET, 'se', FILTER_VALIDATE_INT);
$local = "AmxxBanSystemUUID;{$g_steam};{$g_ipv4};{$g_validator}";
$currtime = date('Y-m-d H:i:s');

function log_try_error($log)
{
    global $g_steam, $localIp;

    file_put_contents(
        "ERROR_".date('Y-m-d').".log",
        date('Y/m/d H:i:s'). " | " . $g_steam . " | " . $localIp . " | " . $log . "\n",
        FILE_APPEND
    );
    print "<pre>";
    echo($log);
    print "</pre>";
}

// function finished()
// {
//     header("Location: http://87.229.115.72/ban_api/motd_herboy.html?ver122254123");
//     exit();
// }

switch ($g_server) {
    case 1:
            require_once("config_avatar.php"); break;
    case 2:
            require_once("config_dev.php"); break;
    case 3:
            require_once("config_herboy.php"); break;
    case 4:
            require_once("config_sdev.php"); break;
    default:
        finished();
}

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
    curl_setopt($ch, CURLOPT_TIMEOUT, 30);

    $response = curl_exec($ch);

    if ($response === false) {
        throw new Exception('cURL Error: ' . curl_error($ch));
    }

    curl_close($ch);
    return $response;
}

function get_ip_data($checkip) {
    global $pdo;

    try {
        $stmt = $pdo->prepare("SELECT * FROM ip_data WHERE ip = :ip");
        $stmt->bindParam(':ip', $checkip);
        $stmt->execute();
        $result = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($result) {
            $check_date = new DateTime($result['check_date']);
            $current_date = new DateTime();
            $interval = $check_date->diff($current_date)->days;

            if ($interval < IP_API_RECHECK_DAYS) {
                // Cast values to boolean
                $result['is_proxy'] = (bool)$result['is_proxy'];
                $result['is_vpn'] = (bool)$result['is_vpn'];
                $result['is_datacenter'] = (bool)$result['is_datacenter'];
                
                return $result;
            } else {
                $url = 'https://api.ipapi.is?q=' . $checkip;
                try {
                    $content = get_via_proxy($url);
                } catch (Exception $e) {
                    log_try_error('(proxy)get_ip_data('.$checkip.'): ' . $e->getMessage());
                    try {
                        $content = file_get_contents($url);
                    } catch (Exception $e) {
                        log_try_error('(local)get_ip_data('.$checkip.'): ' . $e->getMessage());
                        return $result;
                    }
                }

                $data = json_decode($content, true);

                $ip_data = [
                    'ip' => $result['ip'],
                    'is_proxy' => (bool)$result['is_proxy'],
                    'is_vpn' => (bool)$result['is_vpn'],
                    'is_datacenter' => (bool)$result['is_datacenter'],
                    'asn_asn' => $result['asn_asn'],
                    'asn_route' => $result['asn_route'],
                    'asn_org' => $result['asn_org'],
                    'location_country_code' => $result['location_country_code'],
                    'full_json' => $result['full_json'],
                    'check_date' => $result['check_date']
                ];

                $stmt = $pdo->prepare("
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

                return $ip_data;
            }
        } else {
            $url = 'https://api.ipapi.is?q=' . $checkip;
            try {
                $content = get_via_proxy($url);
            } catch (Exception $e) {
                log_try_error('(proxy)get_ip_data('.$checkip.'): ' . $e->getMessage());
                try {
                    $content = file_get_contents($url);
                } catch (Exception $e) {
                    log_try_error('(local)get_ip_data('.$checkip.'): ' . $e->getMessage());
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

            $stmt = $pdo->prepare("
                INSERT INTO ip_data (
                    ip, is_proxy, is_vpn, is_datacenter, 
                    asn_asn, asn_route, asn_org, 
                    location_country_code, full_json, check_date
                ) VALUES (
                    :ip, :is_proxy, :is_vpn, :is_datacenter, 
                    :asn_asn, :asn_route, :asn_org, 
                    :location_country_code, :full_json, :check_date
                )
            ");
            $stmt->execute($ip_data);

            return $ip_data;
        }
    } catch (PDOException $e) {
        log_try_error('Database error in get_ip_data('.$checkip.'): ' . $e->getMessage());
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
    $key = hash('sha256', 'AmxxBanSystemUUID__0191861d-564e-791f-b20f-047a8b7504c9', true);
    $iv = openssl_random_pseudo_bytes(openssl_cipher_iv_length('aes-256-cbc'));
    
    $encryptedString = openssl_encrypt($string, 'aes-256-cbc', $key, 0, $iv);
    
    $result = base64_encode($iv . $encryptedString);
    
    return $result;
}

function decrypt_string($encryptedString) {
    $key = hash('sha256', 'AmxxBanSystemUUID__0191861d-564e-791f-b20f-047a8b7504c9', true);
    
    $data = base64_decode($encryptedString);
    $iv_length = openssl_cipher_iv_length('aes-256-cbc');
    $iv = substr($data, 0, $iv_length);
    $encryptedString = substr($data, $iv_length);
    
    $decryptedString = openssl_decrypt($encryptedString, 'aes-256-cbc', $key, 0, $iv);
    
    return $decryptedString;
}

function add_steamid(&$array, $steamid, $old = false)
{
    global $currtime;

    $found = false;
    foreach ($array['STEAMIDs'] as &$steamid_data) { 
        if (isset($steamid_data['indicator']) && $steamid_data['indicator'] === $steamid) {
            $steamid_data['lastseen'] = $currtime;
            $steamid_data['old'] = $steamid_data['old'] ? $old : false;
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
            'old' => $old,
            'is_sync' => false,
        );

        $array['STEAMIDs'][] = $aIndicator;
    }
}

function add_ip(&$array, $ip)
{
    global $currtime;

    $ip_data = get_ip_data($ip);

    if ($ip_data === null) {
        $ip_data = [
            'ip' => $ip,
            'firstseen' => $currtime,
            'lastseen' => $currtime
        ];
    }

    $found = false;
    foreach ($array['IPs'] as &$ip_entry) {
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
            'indicator' => $ip_data['ip'],
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

        $array['IPs'][] = $new_ip_entry;
    }
}

function sync_steamid(&$player_cluster, $steamid_data, $source_uuid, $sync_match)
{
    global $currtime;

    // Initialize sync_chain if not already set
    if (!isset($steamid_data['sync_chain'])) {
        $steamid_data['sync_chain'] = [];
    }

    $found = false;

    foreach ($player_cluster['STEAMIDs'] as &$steamid_entry) {
        // Initialize sync_chain if not already set
        if (!isset($steamid_entry['sync_chain'])) {
            $steamid_entry['sync_chain'] = [];
        }

        if ($steamid_entry['indicator'] === $steamid_data['indicator']) {
            if ($steamid_entry['is_sync']) {
                $steamid_entry['lastsync'] = $currtime;
                $steamid_entry['sync_from'] = $source_uuid;

                // Merge the sync_chain arrays and remove duplicates based on chain_hash
                $merged_chain = array_merge($steamid_entry['sync_chain'], $steamid_data['sync_chain']);
                $unique_chain = [];
                foreach ($merged_chain as $chain) {
                    $unique_chain[$chain['chain_hash']] = $chain;
                }
                $steamid_entry['sync_chain'] = array_values($unique_chain);

                // Flatten the chain values into a single array
                $existing_values = [];
                foreach ($steamid_entry['sync_chain'] as $chain) {
                    // Ensure the chain_value is always an indexed array
                    $existing_values = array_merge($existing_values, array_values((array) $chain['chain_value']));
                }

                // Filter out already existing chain values
                $sync_match = array_filter($sync_match, function($value) use ($existing_values) {
                    return !in_array($value, $existing_values);
                });

                // If sync_match is empty after filtering, return early
                if (empty($sync_match)) {
                    return;
                }

                // Calculate chain_hash after filtering
                $chain_hash = md5($source_uuid . implode(',', $sync_match));

                $hash_exists = false;
                foreach ($steamid_entry['sync_chain'] as $chain) {
                    if ($chain['chain_hash'] === $chain_hash) {
                        $hash_exists = true;
                        break;
                    }
                }

                if (!$hash_exists) {
                    $steamid_entry['sync_chain'][] = [
                        'chain_hash' => $chain_hash,
                        'chain_time' => $currtime,
                        'chain_source' => $source_uuid,
                        'chain_value' => array_values($sync_match)  // Ensure it's an indexed array
                    ];
                }
            }
            $found = true;
            break;
        }
    }

    if (!$found) {
        $steamid_data['is_sync'] = true;
        $steamid_data['firstsync'] = $currtime;
        $steamid_data['lastsync'] = $currtime;
        $steamid_data['sync_from'] = $source_uuid;
        
        // Calculate chain_hash after filtering
        $chain_hash = md5($source_uuid . implode(',', $sync_match));
        
        $steamid_data['sync_chain'] = [
            [
                'chain_hash' => $chain_hash,
                'chain_time' => $currtime,
                'chain_source' => $source_uuid,
                'chain_value' => array_values($sync_match)  // Ensure it's an indexed array
            ]
        ];
        $player_cluster['STEAMIDs'][] = $steamid_data;
    }
}

function sync_ip(&$player_cluster, $ip_data, $source_uuid, $sync_match)
{
    global $currtime;

    // Initialize sync_chain if not already set
    if (!isset($ip_data['sync_chain'])) {
        $ip_data['sync_chain'] = [];
    }

    $found = false;

    foreach ($player_cluster['IPs'] as &$ip_entry) {
        // Initialize sync_chain if not already set
        if (!isset($ip_entry['sync_chain'])) {
            $ip_entry['sync_chain'] = [];
        }

        if ($ip_entry['indicator'] === $ip_data['indicator']) {
            if ($ip_entry['is_sync']) {
                $ip_entry['lastsync'] = $currtime;
                $ip_entry['sync_from'] = $source_uuid;

                // Merge the sync_chain arrays and remove duplicates based on chain_hash
                $merged_chain = array_merge($ip_entry['sync_chain'], $ip_data['sync_chain']);
                $unique_chain = [];
                foreach ($merged_chain as $chain) {
                    $unique_chain[$chain['chain_hash']] = $chain;
                }
                $ip_entry['sync_chain'] = array_values($unique_chain);

                // Flatten the chain values into a single array
                $existing_values = [];
                foreach ($ip_entry['sync_chain'] as $chain) {
                    // Ensure the chain_value is always an indexed array
                    $existing_values = array_merge($existing_values, array_values((array) $chain['chain_value']));
                }

                // Filter out already existing chain values
                $sync_match = array_filter($sync_match, function($value) use ($existing_values) {
                    return !in_array($value, $existing_values);
                });

                // If sync_match is empty after filtering, return early
                if (empty($sync_match)) {
                    return;
                }

                // Calculate chain_hash after filtering
                $chain_hash = md5($source_uuid . implode(',', $sync_match));

                $hash_exists = false;
                foreach ($ip_entry['sync_chain'] as $chain) {
                    if ($chain['chain_hash'] === $chain_hash) {
                        $hash_exists = true;
                        break;
                    }
                }

                if (!$hash_exists) {
                    $ip_entry['sync_chain'][] = [
                        'chain_hash' => $chain_hash,
                        'chain_time' => $currtime,
                        'chain_source' => $source_uuid,
                        'chain_value' => array_values($sync_match)  // Ensure it's an indexed array
                    ];
                }
            }
            $found = true;
            break;
        }
    }

    if (!$found) {
        $ip_data['is_sync'] = true;
        $ip_data['firstsync'] = $currtime;
        $ip_data['lastsync'] = $currtime;
        $ip_data['sync_from'] = $source_uuid;
        
        // Calculate chain_hash after filtering
        $chain_hash = md5($source_uuid . implode(',', $sync_match));
        
        $ip_data['sync_chain'] = [
            [
                'chain_hash' => $chain_hash,
                'chain_time' => $currtime,
                'chain_source' => $source_uuid,
                'chain_value' => array_values($sync_match)  // Ensure it's an indexed array
            ]
        ];
        $player_cluster['IPs'][] = $ip_data;
    }
}

function store_player_cluster($player_cluster)
{
    global $pdo;

    $data_json = json_encode([
        'STEAMIDs' => $player_cluster['STEAMIDs'],
        'IPs' => $player_cluster['IPs'],
        'ACCOUNTs' => $player_cluster['ACCOUNTs'],
        'OLDUKEYs' => $player_cluster['OLDUKEYs']
    ]);

    $stmt = $pdo->prepare("
        INSERT INTO amx_cookie_v2 (UUID, firstseen, lastseen, data)
        VALUES (:uuid, :firstseen, :lastseen, :data)
        ON DUPLICATE KEY UPDATE
            lastseen = :lastseen,
            data = :data
    ");

    $stmt->execute([
        ':uuid' => $player_cluster['UUID'],
        ':firstseen' => $player_cluster['firstseen'],
        ':lastseen' => $player_cluster['lastseen'],
        ':data' => $data_json
    ]);
}

function get_player_cluster($uuid, &$player_cluster)
{
    global $pdo;

    $stmt = $pdo->prepare("SELECT * FROM amx_cookie_v2 WHERE UUID = :uuid");
    $stmt->execute([':uuid' => $uuid]);

    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($result) {
        $data = json_decode($result['data'], true);
    
        $player_cluster = [
            'UUID' => $result['UUID'],
            'firstseen' => $result['firstseen'],
            'lastseen' => $result['lastseen'],
            'STEAMIDs' => $data['STEAMIDs'],
            'IPs' => $data['IPs'],
            'ACCOUNTs' => $data['ACCOUNTs'],
            'OLDUKEYs' => $data['OLDUKEYs']
        ];
    } else {
        log_try_error('UUID not found: ' . $uuid);
        finished();
    }
}

function delete_cookie_by_ukey($ukey)
{
    global $pdo;

    try {
        $stmt = $pdo->prepare("
            DELETE FROM amx_cookie
            WHERE JSON_UNQUOTE(JSON_EXTRACT(cookie, '$.UKey')) = :ukey
        ");
        $stmt->bindParam(':ukey', $ukey, PDO::PARAM_STR);
        $stmt->execute();

        if ($stmt->rowCount() > 0) {
            log_try_error("UKey {$ukey} deleted from amx_cookie table.");
            return true;
        } else {
            log_try_error("UKey {$ukey} not found in amx_cookie table.");
            return false;
        }
    } catch (PDOException $e) {
        log_try_error('Database error in delete_cookie_by_ukey: ' . $e->getMessage());
        return false;
    }
}

function store_uuid_pair($uuid1, $uuid2, $pair_time, $matched_value)
{
    global $pdo;

    try {
        if (strcmp($uuid1, $uuid2) > 0) {
            list($uuid1, $uuid2) = [$uuid2, $uuid1];
        }

        $id = md5($uuid1 . $uuid2);

        $stmt = $pdo->prepare("
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
    } catch (PDOException $e) {
        log_try_error('Database error in store_uuid_pair: ' . $e->getMessage());
    }
}

function check_connections_by_steamid(&$player_cluster)
{
    global $pdo, $currtime, $checked_uuids;
    $matched_clusters = [];
    $new_indicators = false;

    if (!isset($player_cluster['UUIDPAIRS'])) {
        $player_cluster['UUIDPAIRS'] = [];
    }

    $steamids = array_column($player_cluster['STEAMIDs'], 'indicator');

    if (empty($steamids)) {
        return $matched_clusters;
    }

    try {
        $query = "
        SELECT UUID, data
        FROM amx_cookie_v2
        WHERE (" . implode(' OR ', array_map(function ($steamid) {
            return "JSON_SEARCH(data, 'one', '$steamid', NULL, '$.STEAMIDs[*].indicator') IS NOT NULL";
        }, $steamids)) . ")";
    
        if (!empty($checked_uuids)) {
            $query .= " AND UUID NOT IN (" . implode(',', array_map(function($uuid) { return "'$uuid'"; }, $checked_uuids)) . ")";
        }

        $stmt = $pdo->query($query);
        $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

        foreach ($results as $result) {
            $uuid_dst = $result['UUID'];
            $checked_uuids[] = $uuid_dst;

            $data = json_decode($result['data'], true);

            // Skip if IP is flagged as VPN, proxy, or datacenter
            foreach ($data['IPs'] as $ip_entry) {
                if ($ip_entry['is_vpn'] || $ip_entry['is_proxy'] || $ip_entry['is_datacenter']) {
                    continue 2; // Skip to the next result
                }
            }

            $exists = array_filter($player_cluster['UUIDPAIRS'], function ($pair) use ($uuid_dst) {
                return $pair['uuid_dst'] === $uuid_dst;
            });

            $matched_clusters[] = [
                'UUID' => $uuid_dst,
                'data' => $data
            ];

            if (empty($exists) && !in_array($uuid_dst, array_column($player_cluster['UUIDPAIRS'], 'uuid_dst'))) {
                $pair_time = date('Y-m-d H:i:s');

                $matched_values = [];
                foreach ($player_cluster['STEAMIDs'] as $steamid_entry) {
                    foreach ($data['STEAMIDs'] as $data_steamid_entry) {
                        if ($steamid_entry['indicator'] === $data_steamid_entry['indicator']) {
                            $matched_values[] = $steamid_entry['indicator'];
                        }
                    }
                }
                foreach ($player_cluster['IPs'] as $ip_entry) {
                    foreach ($data['IPs'] as $data_ip_entry) {
                        if ($ip_entry['indicator'] === $data_ip_entry['indicator'] && !$ip_entry['is_sync']) {
                            $matched_values[] = $ip_entry['indicator'];
                        }
                    }
                }
                $matched_values_str = implode(', ', $matched_values);

                // Determine uuid_src based on is_sync
                $uuid_src = $steamid_entry['is_sync'] ? $steamid_entry['sync_from'] : $player_cluster['UUID'];

                if (strcmp($uuid_src, $uuid_dst) > 0) {
                    list($uuid_src, $uuid_dst) = [$uuid_dst, $uuid_src];
                }

                $player_cluster['UUIDPAIRS'][] = [
                    'uuid_src' => $uuid_src,
                    'uuid_dst' => $uuid_dst,
                    'pair_time' => $pair_time,
                    'matched_value' => $matched_values_str
                ];

                foreach ($data['STEAMIDs'] as $steamid_entry) {
                    sync_steamid($player_cluster, $steamid_entry, $uuid_dst, $matched_values);
                    $new_indicators = true;
                }

                foreach ($data['IPs'] as $ip_entry) {
                    sync_ip($player_cluster, $ip_entry, $uuid_dst, $matched_values);
                    $new_indicators = true;
                }

                store_uuid_pair($uuid_src, $uuid_dst, $pair_time, $matched_values_str);
            }
        }
    } catch (PDOException $e) {
        log_try_error('Database error in check_connections_by_steamid: ' . $e->getMessage());
        return [];
    }

    return $new_indicators;
}

function check_connections_by_ip(&$player_cluster)
{
    global $pdo, $currtime, $checked_uuids;
    $matched_clusters = [];
    $new_indicators = false;

    if (!isset($player_cluster['UUIDPAIRS'])) {
        $player_cluster['UUIDPAIRS'] = [];
    }

    $ips = array_column($player_cluster['IPs'], 'indicator');

    if (empty($ips)) {
        return $matched_clusters;
    }

    try {
        $query = "
        SELECT UUID, data
        FROM amx_cookie_v2
        WHERE (" . implode(' OR ', array_map(function ($ip) {
            return "JSON_SEARCH(data, 'one', '$ip', NULL, '$.IPs[*].indicator') IS NOT NULL";
        }, $ips)) . ")
        AND lastseen >= DATE_SUB(NOW(), INTERVAL " . MAX_IP_AGE_DAYS . " DAY)";
    
        if (!empty($checked_uuids)) {
            $query .= " AND UUID NOT IN (" . implode(',', array_map(function($uuid) { return "'$uuid'"; }, $checked_uuids)) . ")";
        }

        $stmt = $pdo->query($query);
        $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

        foreach ($results as $result) {
            $uuid_dst = $result['UUID'];
            $checked_uuids[] = $uuid_dst;

            $data = json_decode($result['data'], true);

            // Skip if IP is flagged as VPN, proxy, or datacenter
            foreach ($data['IPs'] as $ip_entry) {
                if ($ip_entry['is_vpn'] || $ip_entry['is_proxy'] || $ip_entry['is_datacenter']) {
                    continue 2; // Skip to the next result
                }
            }

            $exists = array_filter($player_cluster['UUIDPAIRS'], function ($pair) use ($uuid_dst) {
                return $pair['uuid_dst'] === $uuid_dst;
            });

            $matched_clusters[] = [
                'UUID' => $uuid_dst,
                'data' => $data
            ];

            if (empty($exists) && !in_array($uuid_dst, array_column($player_cluster['UUIDPAIRS'], 'uuid_dst'))) {
                $pair_time = date('Y-m-d H:i:s');

                $matched_values = [];
                foreach ($player_cluster['IPs'] as $ip_entry) {
                    foreach ($data['IPs'] as $data_ip_entry) {
                        if ($ip_entry['indicator'] === $data_ip_entry['indicator']) {
                            $matched_values[] = $ip_entry['indicator'];
                        }
                    }
                }
                foreach ($player_cluster['STEAMIDs'] as $steamid_entry) {
                    foreach ($data['STEAMIDs'] as $data_steamid_entry) {
                        if ($steamid_entry['indicator'] === $data_steamid_entry['indicator'] && !$steamid_entry['is_sync']) {
                            $matched_values[] = $steamid_entry['indicator'];
                        }
                    }
                }
                $matched_values_str = implode(', ', $matched_values);

                // Determine uuid_src based on is_sync
                $uuid_src = $ip_entry['is_sync'] ? $ip_entry['sync_from'] : $player_cluster['UUID'];

                if (strcmp($uuid_src, $uuid_dst) > 0) {
                    list($uuid_src, $uuid_dst) = [$uuid_dst, $uuid_src];
                }

                $player_cluster['UUIDPAIRS'][] = [
                    'uuid_src' => $uuid_src,
                    'uuid_dst' => $uuid_dst,
                    'pair_time' => $pair_time,
                    'matched_value' => $matched_values_str
                ];

                foreach ($data['STEAMIDs'] as $steamid_entry) {
                    sync_steamid($player_cluster, $steamid_entry, $uuid_dst, $matched_values);
                    $new_indicators = true;
                }

                foreach ($data['IPs'] as $ip_entry) {
                    sync_ip($player_cluster, $ip_entry, $uuid_dst, $matched_values);
                    $new_indicators = true;
                }

                store_uuid_pair($uuid_src, $uuid_dst, $pair_time, $matched_values_str);
            }
        }
    } catch (PDOException $e) {
        log_try_error('Database error in check_connections_by_ip: ' . $e->getMessage());
        return [];
    }

    return $new_indicators;
}

function check_uuids_confirm(&$player_cluster)
{
    global $pdo, $currtime, $checked_uuids;
    $new_indicators = false;

    // Collect all relevant UUIDs to check
    $uuids_to_check = [];

    // Collect UUIDs from UUIDPAIRS
    foreach ($player_cluster['UUIDPAIRS'] as $uuid_pair) {
        if (!in_array($uuid_pair['uuid_dst'], $checked_uuids)) {
            $uuids_to_check[] = $uuid_pair['uuid_dst'];
        }
        if (!in_array($uuid_pair['uuid_src'], $checked_uuids)) {
            $uuids_to_check[] = $uuid_pair['uuid_src'];
        }
    }

    // Collect UUIDs from chain_source in sync_chain
    foreach (['STEAMIDs', 'IPs'] as $type) {
        foreach ($player_cluster[$type] as $entry) {
            if (isset($entry['sync_chain'])) {
                foreach ($entry['sync_chain'] as $chain) {
                    if (!in_array($chain['chain_source'], $checked_uuids)) {
                        $uuids_to_check[] = $chain['chain_source'];
                    }
                }
            }
        }
    }

    // Remove duplicates and skip checked UUIDs
    $uuids_to_check = array_unique($uuids_to_check);
    $uuids_to_check = array_diff($uuids_to_check, $checked_uuids);

    if (empty($uuids_to_check)) {
        return $new_indicators;
    }

    // Fetch data for all UUIDs to be checked
    $placeholders = implode(',', array_fill(0, count($uuids_to_check), '?'));
    $stmt = $pdo->prepare("SELECT UUID, data FROM amx_cookie_v2 WHERE UUID IN ($placeholders)");

    // Bind the UUIDs to the placeholders
    foreach (array_values($uuids_to_check) as $index => $uuid) {
        $stmt->bindValue($index + 1, $uuid, PDO::PARAM_STR);
    }

    $stmt->execute();
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($results as $result) {
        $uuid_dst = $result['UUID'];
        $checked_uuids[] = $uuid_dst;

        $data = json_decode($result['data'], true);

        foreach ($data['STEAMIDs'] as $steamid_entry) {
            $found = false;
            foreach ($player_cluster['STEAMIDs'] as &$local_steamid_entry) {
                if ($local_steamid_entry['indicator'] === $steamid_entry['indicator']) {
                    // Sync any unsynced values
                    sync_steamid($player_cluster, $steamid_entry, $uuid_dst, [$steamid_entry['indicator']]);
                    $found = true;
                    break;
                }
            }
            if (!$found) {
                // Add the new steamid if not found
                sync_steamid($player_cluster, $steamid_entry, $uuid_dst, [$steamid_entry['indicator']]);
            }
        }

        foreach ($data['IPs'] as $ip_entry) {
            $found = false;
            foreach ($player_cluster['IPs'] as &$local_ip_entry) {
                if ($local_ip_entry['indicator'] === $ip_entry['indicator']) {
                    // Sync any unsynced values
                    sync_ip($player_cluster, $ip_entry, $uuid_dst, [$ip_entry['indicator']]);
                    $found = true;
                    break;
                }
            }
            if (!$found) {
                // Add the new IP if not found
                sync_ip($player_cluster, $ip_entry, $uuid_dst, [$ip_entry['indicator']]);
            }
        }
    }

    return $new_indicators;
}


function get_longest_ban_bid($indicators) {
    global $pdo;

    if (empty($indicators)) {
        return 0;
    }

    $placeholders = implode(',', array_fill(0, count($indicators), '?'));

    try {
        $stmt = $pdo->prepare("
            SELECT
                bid
            FROM
                amx_bans
            WHERE
                (player_id IN ($placeholders) OR player_ip IN ($placeholders)) AND 
                expired = 0 AND 
                (ban_length = 0 OR 
                (ban_length > 0 AND (ban_created + (ban_length * 60)) > UNIX_TIMESTAMP(DATE_SUB(NOW(), INTERVAL ? DAY))))
            ORDER BY
                ban_length DESC, ban_created DESC
            LIMIT 1;
        ");

        foreach ($indicators as $index => $indicator) {
            $stmt->bindValue($index + 1, $indicator, PDO::PARAM_STR);
            $stmt->bindValue(count($indicators) + $index + 1, $indicator, PDO::PARAM_STR);
        }
        $stmt->bindValue(count($indicators) * 2 + 1, MAX_IP_AGE_DAYS, PDO::PARAM_INT);

        $stmt->execute();
        $result = $stmt->fetch(PDO::FETCH_ASSOC);

        return $result ? $result['bid'] : 0;

    } catch (PDOException $e) {
        log_try_error('Database error in get_longest_ban_bid: ' . $e->getMessage());
        return 0;
    }
}

function fetch_clusters_from_uuidpairs($uuidpairs) {
    global $pdo;
    $clusters = [];

    if (empty($uuidpairs)) {
        return $clusters;
    }

    $uuids = array_map(function($pair) {
        return $pair['uuid'];
    }, $uuidpairs);

    $placeholders = implode(',', array_fill(0, count($uuids), '?'));

    $stmt = $pdo->prepare("
        SELECT * FROM amx_cookie_v2 WHERE UUID IN ($placeholders)
    ");
    $stmt->execute($uuids);

    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($results as $result) {
        $data = json_decode($result['data'], true);
        $clusters[] = $data;
    }

    return $clusters;
}

function get_indicators_from_cluster($cluster) {
    $indicators = [];

    foreach ($cluster['STEAMIDs'] as $steamid_entry) {
        $indicators[] = $steamid_entry['indicator'];
    }

    foreach ($cluster['IPs'] as $ip_entry) {
        $indicators[] = $ip_entry['indicator'];
    }

    return $indicators;
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
        if (!$steamid_entry['old']) {
            if ($steamid_entry['is_nonsteam'] && $steamid_entry['firstseen'] < $oldest_firstseen_nonsteamid) {
                $oldest_firstseen_nonsteamid = $steamid_entry['firstseen'];
            }

            if ($steamid_entry['indicator'] === $g_steamid) {
                $g_steamid_firstseen = $steamid_entry['firstseen'];
            }
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

//******************************************************
//******************************************************
// STAGE 0 - INIT SQL
//******************************************************
//******************************************************

try {
    $pdo = new PDO("mysql:host=$mysql_host;dbname=$mysql_dbdb", $mysql_user, $mysql_pass);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    log_try_error('Connection failed: ' . $e->getMessage());
    exit;
}

//******************************************************
//******************************************************
// STAGE 1 - PREPARE DATA
//******************************************************
//******************************************************

$player_cluster = array();
if(!isset($_COOKIE[$cookiename]))
{
    $player_cluster = array(
        'UUID' => uuidv4(),
        'firstseen' => $currtime,
        'lastseen' => $currtime,
        'STEAMIDs' => array(),
        'IPs' => array(),
        'ACCOUNTs' => array(),
        'OLDUKEYs' => array()
    );

    add_steamid($player_cluster, $g_steam);
    add_ip($player_cluster, $g_ipv4);

    if($g_ipv4 != $localIp)
        add_ip($player_cluster, $localIp);


    $encrypted_uuid = encrypt_string($player_cluster['UUID']);
    $cookie_content = [
        "UUID" => $encrypted_uuid,
        "HASHCHECK" => hash('sha256', "AmxxBanSystemUUID__01918626-25ff-7cfb-b1ca-35fac8668745;" . $encrypted_uuid)
    ];

    setcookie(($cookiename), base64url_encode(serialize($cookie_content)), time()+60*60*24*365*10 );
}
else
{
    $cookie_content = unserialize(base64url_decode($_COOKIE[$cookiename]));
    if (!isset($cookie_content["HASHCHECK"])) 
    {
        $player_cluster = array(
            'UUID' => uuidv4(),
            'firstseen' => $currtime,
            'lastseen' => $currtime,
            'STEAMIDs' => array(),
            'IPs' => array(),
            'ACCOUNTs' => array(),
            'OLDUKEYs' => array()
        );

        add_steamid($player_cluster, $g_steam);
        add_ip($player_cluster, $g_ipv4);

        if ($g_ipv4 != $localIp)
            add_ip($player_cluster, $localIp);

        if (isset($cookie_content['steamid']) && is_array($cookie_content['steamid'])) {
            foreach ($cookie_content['steamid'] as $old_steamid) {
                add_steamid($player_cluster, $old_steamid, true);
            }
        }

        if (isset($cookie_content['UKey'])) {
            $player_cluster['OLDUKEYs'][] = [
                'ukey' => $cookie_content['UKey'],
                'collecttime' => $currtime
            ];
            delete_cookie_by_ukey($cookie_content['UKey']);
        }

        $encrypted_uuid = encrypt_string($player_cluster['UUID']);
        $new_cookie_content = [
            "UUID" => $encrypted_uuid,
            "HASHCHECK" => hash('sha256', "AmxxBanSystemUUID__01918626-25ff-7cfb-b1ca-35fac8668745;" . $encrypted_uuid)
        ];
        setcookie($cookiename, base64url_encode(serialize($new_cookie_content)), time() + 60 * 60 * 24 * 365 * 10);
    }
    else
    {
        $uuid = decrypt_string($cookie_content['UUID']);
        get_player_cluster($uuid, $player_cluster);

        add_steamid($player_cluster, $g_steam);
        add_ip($player_cluster, $g_ipv4);

        if($g_ipv4 != $localIp)
            add_ip($player_cluster, $localIp);
    }
}

//******************************************************
//******************************************************
// STAGE 2 - CHECK DATA
//******************************************************
//******************************************************

$checked_uuids[] = $player_cluster['UUID'];
$has_new_indicators = true;

while ($has_new_indicators) {
    $has_new_indicators = false;

    $checked_uuids_copy = $checked_uuids;

    $has_new_indicators = check_connections_by_steamid($player_cluster) || $has_new_indicators;
    $checked_uuids_steamids = $checked_uuids;

    $checked_uuids = $checked_uuids_copy;
    $has_new_indicators = check_connections_by_ip($player_cluster) || $has_new_indicators;
    $checked_uuids_ips = $checked_uuids;

    $checked_uuids = $checked_uuids_copy;
    $has_new_indicators = check_uuids_confirm($player_cluster) || $has_new_indicators;
    $checked_uuids_confirm = $checked_uuids;

    $checked_uuids = array_unique(array_merge($checked_uuids_steamids, $checked_uuids_ips, $checked_uuids_confirm));
}

$indicators = get_indicators_from_cluster($player_cluster);

$bid = get_longest_ban_bid($indicators);

//******************************************************
//******************************************************
// STAGE 3 - STORE DATA
//******************************************************
//******************************************************

store_player_cluster($player_cluster);

//******************************************************
//******************************************************
// STAGE 4 - NOTIFY SERVER
//******************************************************
//******************************************************

$steamidchanger = check_for_steamid_changer($player_cluster, $g_steam);
$vpn_or_proxy = check_vpn_or_proxy($player_cluster, $localIp, $g_ipv4);

$end_time = microtime(true);
$execution_time = $end_time - $start_time;
echo "Execution time: " . $execution_time . " seconds";
print "<pre>";
echo(json_encode($player_cluster));
print "</pre>";

?>
