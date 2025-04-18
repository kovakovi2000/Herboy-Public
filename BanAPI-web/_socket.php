<?php


$filename = 'port_'.$g_server.'.txt';
$port = 0;
$cacheFile;
$cachedIp = "unknown";
$cache_checked = false;
// Check if the file exists
if (file_exists($filename)) {
    $port = file_get_contents($filename);
}
else {
    if(isset($Errors))
        triggerCustomError(E_USER_WARNING, "The file $filename does not exist.", __FILE__, __LINE__);
}

function queryDns($domain, $dnsServer)
{
    global $cacheFile, $cachedIp, $cache_checked;

    if (filter_var($domain, FILTER_VALIDATE_IP)) {
        return $domain; // Return the IP address directly
    }
    
    // Define cache file path
    $cacheFile = "dns_" . $domain . ".cache";

    // Check if the cache file exists and read the IP from cache
    if (file_exists($cacheFile) && !$cache_checked) {
        $cache_checked = true;
        $cachedIp = file_get_contents($cacheFile);
        if ($cachedIp) {
            return $cachedIp;
        }
    }

    // Perform DNS query packet for the domain
    $header = "\xAA\xAA\x01\x00\x00\x01\x00\x00\x00\x00\x00\x00"; // Standard DNS header
    $question = '';
    foreach (explode('.', $domain) as $part) {
        $question .= chr(strlen($part)) . $part;
    }
    $question .= "\x00"; // End of the domain name
    $question .= "\x00\x01"; // Query type A (host address)
    $question .= "\x00\x01"; // Query class IN (internet)

    $packet = $header . $question;

    // Create UDP socket
    $socket = socket_create(AF_INET, SOCK_DGRAM, SOL_UDP);
    socket_connect($socket, $dnsServer, 53);
    socket_send($socket, $packet, strlen($packet), 0);

    // Receive response
    $response = '';
    if (socket_recv($socket, $response, 512, MSG_WAITALL) === false) {
        triggerCustomError(E_USER_WARNING, "No response received, attempting to resolve again.", __FILE__, __LINE__);
        socket_close($socket);
        return $cachedIp;
    }
    socket_close($socket);

    // Parse the DNS response to find the IP address
    $header = substr($response, 0, 12);
    $answers = substr($response, 12 + strlen($question));

    $ip = null;
    while (strlen($answers) > 0) {
        $type = unpack('n', substr($answers, 2, 2))[1];
        $data_length = unpack('n', substr($answers, 10, 2))[1];
        $data = substr($answers, 12, $data_length);

        // IPv4 A record
        if ($type == 1 && $data_length == 4) {
            $ip = sprintf('%d.%d.%d.%d', ord($data[0]), ord($data[1]), ord($data[2]), ord($data[3]));
            break;
        }

        // Move to the next answer record
        $answers = substr($answers, 12 + $data_length);
    }

    // Cache the IP address if obtained
    if ($ip && $ip != $cachedIp) {
        file_put_contents($cacheFile, $ip);
        triggerCustomError(E_USER_WARNING, "Server domain IP has change from ".$cachedIp." to ".$ip, __FILE__, __LINE__);
    } else {
        $ip = $cachedIp;
        triggerCustomError(E_USER_WARNING, "Failed to resolve IP for {$domain} using cached IP: ".$cachedIp, __FILE__, __LINE__);
    }
    

    return $ip;
}

function LogSocket($log)
{
    $logDirectory = $_SERVER['DOCUMENT_ROOT']. "/logs/_SOCKETLOG/";
    $logFile = "SOCKET_" . date('Y-m-d') . ".log";
    $logPath = $logDirectory . $logFile;

    // Ensure the log directory is writable
    if (!is_writable($logDirectory)) {
        error_log("Log directory is not writable: " . $logDirectory);
        return;
    }

    file_put_contents(
        $logPath,
        date('Y/m/d H:i:s'). " | " . $log . "\n",
        FILE_APPEND
    );
}

function sck_set_server($_host,$_port) {
    global $port;
    $GLOBALS['sck_host'] = $_host; $GLOBALS['sck_port'] = $port;
}


function sck_CallPawnFunc($amxxfile, $funcname, $args)
{
    global $cache_checked;
    $cache_checked = false;

    $temp = $funcname.";".$amxxfile.";";
    for ($i=0; $i < sizeof($args); $i++) { 
        $temp .= $args[$i] . ";";
    }

    $hash = md5($temp."_SALTYHerBoY_53GKAKRjQhTyFpdwWsCDV8rQ3q39kXPN");
    $data = pack("C", 0x22);
    $data .= $temp.$hash;
    return sck_send(0x22, $data);
}

function UnhandledError($return_value)
{
    global $g_server;
    $counterFile = "UHE_r" . $return_value . "_s" . $g_server . ".txt";

    // Read the current value from the file
    $counter = 0;
    if (file_exists($counterFile)) {
        $counter = (int)file_get_contents($counterFile);
    }

    // Update the counter based on the return value
    if ($return_value === 0) {
        $counter += 1; // Increment the counter by 1 if return_value is 0
    } elseif ($return_value >= 1) {
        $counter -= 1; // Decrement the counter by 1 if return_value is >= 1
    }

    // Ensure the counter doesn't go below zero
    if ($counter < 0) {
        $counter = 0;
    }

    if($return_value == 1) return $return_value;
    if($counter > 32) {
        if (isset($Errors)) triggerCustomError(E_USER_WARNING, 'Socket error ret "'.$return_value.'" count higher then 32', __FILE__, __LINE__);
        $counter = 32;
    }

    // Save the updated counter back to the file
    file_put_contents($counterFile, $counter);

    // Return the same value that was passed to the function
    return $return_value;
}

function sck_send($cmd, $data)
{
    global $Errors, $cacheFile;
    $rec = bin2hex(pack("C", $cmd));
    $buf = "";
    $retry = 0;

    do
    {
        try {
            if ($retry > 5)
            {
                return UnhandledError(2); // timeout
            }
            
            $retry++;
            

            $sock = null;
            if (!($sock = socket_create(AF_INET, SOCK_STREAM, SOL_TCP))) 
            {
                triggerCustomError(E_USER_WARNING, "Failed to create socket.", __FILE__, __LINE__);
                continue;
            }

            LogSocket("initing to: {$GLOBALS['sck_host']}:{$GLOBALS['sck_port']}");
            if (socket_connect($sock, queryDns($GLOBALS['sck_host'], '127.0.0.1'), $GLOBALS['sck_port']) === false) {
                triggerCustomError(E_USER_WARNING, "Failed to connection socket.", __FILE__, __LINE__);
                continue;
            }
            socket_set_option($sock, SOL_SOCKET, SO_RCVTIMEO, array('sec'=>2*($retry > 0 ? $retry : 1), 'usec'=>0));
            socket_set_option($sock, SOL_SOCKET, SO_SNDTIMEO, array('sec'=>2*($retry > 0 ? $retry : 1), 'usec'=>0));
            
            LogSocket("connected to: {$GLOBALS['sck_host']}:{$GLOBALS['sck_port']}");

            // Attempt to send all data in one go
            if (socket_write($sock, $data, strlen($data)) === false) {
                socket_close($sock);
                triggerCustomError(E_USER_WARNING, "Failed write to the socket.", __FILE__, __LINE__);
                continue; // Retry the whole process if sending fails
            }
            LogSocket("sent:".bin2hex($data)."</br>");

            // Attempt to receive all data in one go
            $buf = '';
            $bytesReceived = socket_recv($sock, $buf, 1024, MSG_WAITALL);
            if ($bytesReceived === false) {
                socket_close($sock);
                triggerCustomError(E_USER_WARNING, "Failed read from the socket.", __FILE__, __LINE__);
                continue; // Retry if receiving fails
            }

            $answer_hex = bin2hex($buf);
            LogSocket("recv:".$answer_hex."</br>");
            
            // Check for specific response codes
            if ($answer_hex === $rec."a103")
            {
                socket_close($sock);
                return UnhandledError(3); // variable overflow
            }
            if ($answer_hex === $rec."a104")
            {
                socket_close($sock);
                return UnhandledError(4); // variable overflow
            }
            if ($answer_hex === $rec."a105")
            {
                socket_close($sock);
                return UnhandledError(5); // user not online
            }
            if ($answer_hex === $rec."a101")
            {
                socket_close($sock);
                return UnhandledError(1); // success
            }
            socket_close($sock);
            return UnhandledError(0);
                
        } catch (PDOException $e) {
            if (isset($Errors)) triggerCustomError(E_USER_WARNING, 'Socket error in sck_send: ' . $e->getMessage(), $e->getFile(), $e->getLine());
            continue;
        }
    } while (true);

    return UnhandledError(-1);
}

function send_to_all_server($amxxfile, $funcname, $args)
{
    LogSocket("---------------- send_to_all_server('$amxxfile', '$funcname' (...)) ----------------");
    global $servers;
    $approved = false;
    for ($i=1; $i < sizeof($servers); $i++) {
        if($servers[$i]['online'] == false)
            continue;

        sck_set_server($servers[$i]['ip'], $servers[$i]['sck_port']);
        $ret = sck_CallPawnFunc($amxxfile, $funcname, $args);
        if($ret == 1)
            $approved = true;
    }
    LogSocket("---------------- send_to_all_server() FINISHED ----------------");
    return $approved;
}

function send_to_server($serverid, $amxxfile, $funcname, $args)
{
    global $servers;
    LogSocket("---------------- send_to_server($serverid, '$amxxfile', '$funcname' (...)) ----------------");
    sck_set_server($servers[$serverid]['ip'], $servers[$serverid]['sck_port']);
    return (1 == sck_CallPawnFunc($amxxfile, $funcname, $args));
    LogSocket("---------------- send_to_server() FINISHED ----------------");
}

// $passargs = array("i", "3", "s", "Kova", "i", "1337", "i", "0");
// echo (send_to_all_server("regbackup.amxx", "ex_bought_pp", $passargs) ? "true" : "false");
?>