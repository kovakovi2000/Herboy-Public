<?php
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/includes/ErrorManager.php");
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/Config.php");
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/includes/Utils.php");
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/includes/EzSql.php");

class AbuseIPDB {
    public static function getCountryCodeForIP() {
        global $sql;
        $ip = Security::getRealIP();
        // Query the database for the country code of the given IP
        $currdb = $sql->get_database();
        $sql->set_database(2);
        $result = $sql->select_row("abuseipdb_logs", null, " ip = '{$ip}'");
        $sql->set_database(0);

        if (!empty($result) && isset($result['country_code'])) {
            return $result['country_code'];
        }

        return null; // Return null if no country code is found
    }

    private static function isBlocked($ip) {
        global $sql;
        $result = $sql->select_row("blocked_ips", null, " ip = '{$ip}' AND block_date >= NOW() - INTERVAL 90 DAY");
        return !empty($result);
    }

    private static function isChecked($ip) {
        global $sql;
        $result = $sql->select_row("abuseipdb_logs", null, " ip = '{$ip}' AND created_at >= NOW() - INTERVAL 1 DAY");
        return !empty($result);
    }

    private static function insertAbuseIPDBData($data) {
        global $sql;
        // Extract data fields
        $ip = $data['data']['ipAddress'];
        $abuse_confidence_score = $data['data']['abuseConfidenceScore'];
        $country_code = $data['data']['countryCode'] ?? null;
        $is_whitelisted = $data['data']['isWhitelisted'] ?? false;
        $last_reported_at = $data['data']['lastReportedAt'] ?? null;
        $total_reports = $data['data']['totalReports'] ?? 0;
        $usage_type = $data['data']['usageType'] ?? null;
        $isp = $data['data']['isp'] ?? null;
        $domain = $data['data']['domain'] ?? null;

        // Insert into database
        $stmt = $sql->mysqli->prepare("
            INSERT INTO abuseipdb_logs (
                ip, abuse_confidence_score, country_code, is_whitelisted,
                last_reported_at, total_reports, usage_type, isp, domain
            ) VALUES (
                ?, ?, ?, ?, ?, ?, ?, ?, ?
            )
        ");
        
        // Bind the parameters in the correct order and types
        $stmt->bind_param(
            "sisisiiss",
            $ip,
            $abuse_confidence_score,
            $country_code,
            $is_whitelisted,
            $last_reported_at,
            $total_reports,
            $usage_type,
            $isp,
            $domain
        );

        $stmt->execute();
        $stmt->close();
    }

    private static function isAbuser($ip) {
        global $sql;
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, "https://api.abuseipdb.com/api/v2/check?ipAddress=$ip");
        curl_setopt($ch, CURLOPT_HTTPHEADER, [
            "Key: " . Config::$apikey_abuseipdb,
            "Accept: application/json"
        ]);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        $response = curl_exec($ch);

        if ($response === false) {
            ErrorManager::Add(E_USER_WARNING, "Failed to connect to AbuseIPDB.", __FILE__, __LINE__);
            return false;
        }

        $data = json_decode($response, true);
        curl_close($ch);

        if (!isset($data['data']['abuseConfidenceScore'])) {
            ErrorManager::Add(E_USER_WARNING, "Invalid response from AbuseIPDB.", __FILE__, __LINE__);
            return false;
        }
        
        //ErrorManager::Add(E_USER_WARNING, "banchmark.", __FILE__, __LINE__);
        self::insertAbuseIPDBData($data);
        if (
            $data['data']['abuseConfidenceScore'] >= 50 || 
            (isset($data['data']['isp']) && $data['data']['isp'] == "CloudFlare Inc.") || 
            (isset($data['data']['domain']) && $data['data']['domain'] == "cloudflare.com")
            ) {
            $sql->query("INSERT INTO blocked_ips (ip, block_date) VALUES ('$ip', NOW()) ON DUPLICATE KEY UPDATE block_date = NOW()");
            return true;
        }
        else
            return false;
    }

    private static function generateHash($ip) {
        $salt = Config::$secret_security_salt;
        $date = date('Y.m.d');
        return hash('sha256', "{$salt}_{$date}_{$ip}");
    }

    private static function setAccessCookie($ip) {
        setcookie(Config::$cookie_SecurityPass_name, self::generateHash($ip), time() + 86400, "/"); //1 days
    }

    private static function checkAccessCookie($ip) {
        if (isset($_COOKIE[Config::$cookie_SecurityPass_name])) {
            $expectedHash = self::generateHash($ip);
            return $_COOKIE[Config::$cookie_SecurityPass_name] === $expectedHash;
        }
        return false;
    }

    public static function cleanupOldBlocks() {
        global $sql;
        $sql->query("DELETE FROM blocked_ips WHERE block_date < NOW() - INTERVAL 90 DAY");
    }

    public static function CheckRequest() {
        $clientIp = Security::getRealIP();

        //Security::enforceHttpsAndDomain(Config::$domain);

        if(Security::IsRequestLocal($clientIp))
            return;

        // Bypass checks if valid access token cookie exists
        if (self::checkAccessCookie($clientIp)) {
            return;
        }

        if(str_starts_with($_SERVER['REQUEST_URI'], "/api/"))
        {
            Security::forbid($clientIp);
            return;
        }

        elseif($_SERVER['REQUEST_URI'] == "/favicon.ico")
            return;

        if(!Challenges::isHTTPCompleted())
        {
            if(Challenges::HasHTTP())
            {
                if(!Challenges::CheckHTTP())
                    Security::restartSession($clientIp);
            }
            else
            {
                Security::storeRequestPage();
                Challenges::HTTP();
            }
        }

        if(!Challenges::isJSCompleted())
        {
            if(Challenges::HasJS())
                if(Challenges::CheckJS())
                    Security::redirectToOriginalPage();
                else
                    Security::restartSession($clientIp);
            else
                Security::HTMLPAGE(Challenges::JS());
        }

        // If the IP is blocked, store it and deny access
        if (self::isBlocked($clientIp))
            Security::forbid($clientIp);
        elseif(!self::isChecked($clientIp))
        {
            if(self::isAbuser($clientIp))
                Security::forbid($clientIp);
        }

        self::setAccessCookie($clientIp);
    }
}

class Challenges {

    private static function redirect(string $url)
    {
        http_response_code(302);
        header("Location: $url");
        exit();
    }

    static function HTTP()
    {
        $_SESSION['Challenge_http'] = bin2hex(random_bytes(32).microtime().random_bytes(11));
        self::redirect(Utils::get_url("token?".$_SESSION['Challenge_http']));
    }

    static function HasHTTP()
    {
        return isset($_SESSION['Challenge_http']) && ! isset($_SESSION['Challenge_httpCompleted']);
    }

    static function isHTTPCompleted()
    {
        return isset($_SESSION['Challenge_httpCompleted']);
    }

    static function CheckHTTP()
    {
        if(!isset($_GET['pagelink']))
            return false;
        
        if($_SERVER['REQUEST_URI'] == "/token?".$_SESSION['Challenge_http'])
        {
            unset($_SESSION['Challenge_http']);
            $_SESSION['Challenge_httpCompleted'] = 1;
            return true;
        }
    }

    private static function rndChar(): string {
        $upperAlphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        $lowerAlphabet = 'abcdefghijklmnopqrstuvwxyz';
        $alphabet = random_int(0, 1) ? $upperAlphabet : $lowerAlphabet;
        return $alphabet[random_int(0, 25)];
    }

    private static function findLetterIndexes(string $search, string $target): array|bool {
        // Remove duplicate letters from the search string
        $uniqueSearch = count_chars($search, 3); // Keeps unique characters in order of appearance
        $indexes = [];
        
        // Get each unique letter’s indices in the target string
        $charPositionsMap = [];
        foreach (str_split($uniqueSearch) as $char) {
            $positions = [];
            $position = strpos($target, $char);
    
            // Check if the character is present in the target string
            if ($position === false) {
                // Return false if any letter from search is not found in target
                return false;
            }
    
            // Collect all occurrences of this character in the target string
            while ($position !== false) {
                $positions[] = $position;
                $position = strpos($target, $char, $position + 1);
            }
    
            $charPositionsMap[$char] = $positions;
        }
    
        // Assign a random index from target to each letter in the original search string
        $result = [];
        foreach (str_split($search) as $char) {
            if (isset($charPositionsMap[$char])) {
                // Choose a random position for this specific instance of the character
                $result[] = $charPositionsMap[$char][array_rand($charPositionsMap[$char])];
            }
        }
    
        return $result;
    }

    private static function replaceRandomChar(string $inputString, string $replacementChar): string {
        $length = strlen($inputString);
    
        // Return the original string if it’s empty or the replacement character is not a single char
        if ($length === 0 || strlen($replacementChar) !== 1) {
            return $inputString;
        }
    
        // Get a random position in the string
        $randomIndex = random_int(0, $length - 1);
    
        // Replace the character at the random position
        return substr_replace($inputString, $replacementChar, $randomIndex, 1);
    }

    private static function generateRandomString(int $length): string {
        // Define characters to use in the random string, including numbers
        $characters = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
        $charactersLength = strlen($characters);
        $randomString = '';
    
        for ($i = 0; $i < $length; $i++) {
            // Pick a random character from the available characters
            $randomString .= $characters[random_int(0, $charactersLength - 1)];
        }
    
        return $randomString;
    }

    static function HasJS()
    {
        return isset($_SESSION['Challenge_js']) && ! isset($_SESSION['Challenge_jsCompleted']);
    }
    
    static function isJSCompleted()
    {
        return isset($_SESSION['Challenge_jsCompleted']);
    }

    static function CheckJS()
    {
        if(!isset($_GET['pagelink']))
            return false;
        
        if($_SERVER['REQUEST_URI'] == "/token?".$_SESSION['Challenge_js'])
        {
            unset($_SESSION['Challenge_js']);
            $_SESSION['Challenge_jsCompleted'] = 1;
            return true;
        }
    }

    static function JS()
    {
        $var1 = null; $var2 = null; $var3 = null; $var4 = null; $var5 = null; $var6 = null; $var7 = null; $var8 = null; $var9 = null; $var10 = null; $var11 = null; $var12 = null; $var13 = null; $var14 = null; $var15 = null; $var17 = null; $var18 = null; $output = null; $indexes = null;
        do {
            $var7 = random_int(-2352643,43643643);
            $var8 = random_int(-2352643,43643643);
            $var9 = [random_int(6432,24324), random_int(6432,24324), random_int(6432,24324)];
            
            $var11 = self::replaceRandomChar(self::rndChar().self::generateRandomString(64), '.');
            $var15 = random_int(0,2);
            $var17 = random_int(1434,2345);
            $var18 = random_int(121444,421444);
            $output = $var11;
            for($i = $var9[$var15]+$var18; $i > $var9[$var15]; $i-=$var17)
            {
                $loc = $i % strlen($output);
                $output .= substr($output, $loc, 1);
            }
            
            $indexes = self::findLetterIndexes("window.location.replace", $output);
            
        } while ($indexes === false);

        $_SESSION['Challenge_js'] = $output;
        $var1 = self::rndChar().bin2hex(random_bytes(32));
        $var2 = self::rndChar().bin2hex(random_bytes(32));
        $var3 = self::rndChar().bin2hex(random_bytes(32));
        $var4 = self::rndChar().bin2hex(random_bytes(32));
        $var5 = self::rndChar().bin2hex(random_bytes(32));
        $var6 = self::rndChar().bin2hex(random_bytes(32));
        $var10 = self::rndChar().bin2hex(random_bytes(32));
        $var12 = self::rndChar().bin2hex(random_bytes(32));
        $var13 = self::rndChar().bin2hex(random_bytes(32));
        $var14 = self::rndChar().bin2hex(random_bytes(32));

        echo "<script>";
        echo "window.onload = setTimeout(function(){ try {";
            echo "const dynamicImportTest = import(\"data:text/javascript, export default 'YSBmYXN6b21hdCBrdXRhdGdhdHN6IGl0dCBtaT8gSmVs9mxqIGJlIGRpc2NvcmRvbiAoa292YWtvdmkyMDAwKSDpcyDtcmQgYXp0LCBob2d5ICJNZWd0YWzhbHRhbSBhIGtpbmNzZXQsIGLhciBuaW5jcyBpcyBraW5jcyIuIFJlbelsanVrIG5lbSBmZWxlanRlbSBlbCB4ZA=='\");";
            echo "let ".$var1." = {}?.".$var2.";";
            echo "let ".$var3." = null ?? '".$var4."';";
            echo "let ".$var5." = new WeakRef({});";
            echo "if(Array.from(".$var3.").map(char => char.charCodeAt(0))[".random_int(0,100)."] !== (".$var3." &&= '".$var6."'))";
            echo "{";
                echo "".$var5." += (!!~".$var7.")+[NaN];";
                echo "".$var1." = new Function(\"";
                    echo "const ".$var13." = [".$var9[0].", ".$var9[1].", ".$var9[2]."];";
                    echo "return (typeof ".$var13.".at === \\\"function\\\") ? ".$var13."[".$var15."] : '".$var14."';";
                echo "\");";
            echo "}";
            echo "else";
                echo " ".$var5." *= Array.isArray([])+[~".$var8."];";
            echo "let ".$var10." = '".$var11."';";
            echo "for(let i = ".$var9[$var15]+$var18."; i > ".$var1."(); i-=".$var17.")";
                echo "".$var10." += ".$var10.".charAt(i % ".$var10.".length);";
            echo "new Function(";
            foreach ($indexes as $char => $index)
                echo($var10 . "[" . $index . "]+");
        echo "\"('/token?\"+".$var10."+\"')\")();} catch (e) {}}, 3000);document.currentScript.remove();</script>";
    }
}

class Security {

    public static function getRealIP() {
        if (isset($_SERVER["HTTP_CF_CONNECTING_IP"])) {
            return $_SERVER["HTTP_CF_CONNECTING_IP"];
        } else {
            return $_SERVER["REMOTE_ADDR"];
        }
    }
    
    private static $allowed_ips = ['127.0.0.1', 'localhost', '194.180.16.153', '85.92.66.148', '193.39.15.51', '37.221.209.130'];

    private static function ipInRange($ip, $range) {
        if (strpos($range, ':') !== false) { // Check for IPv6
            list($subnet, $maskBits) = explode('/', $range);
            $ipBinary = inet_pton($ip);
            $subnetBinary = inet_pton($subnet);

            $mask = str_repeat("f", $maskBits / 4) . str_repeat("0", (128 - $maskBits) / 4);
            $maskBinary = pack("H*", $mask);

            return ($ipBinary & $maskBinary) === ($subnetBinary & $maskBinary);
        } else { // IPv4 fallback
            list($subnet, $maskBits) = explode('/', $range);
            $ipDecimal = ip2long($ip);
            $subnetDecimal = ip2long($subnet);
            $mask = -1 << (32 - $maskBits);
            $subnetDecimal &= $mask; // Apply the mask to the subnet

            return ($ipDecimal & $mask) === $subnetDecimal;
        }
    }

    static function IsRequestLocal($ip) {
        if (self::ipInRange($ip, '172.18.0.0/24'))
            return true;

        if (in_array($ip, self::$allowed_ips))
            return true;

        if (self::ipInRange($ip, '66.249.64.0/19'))
            return true;

        if (self::ipInRange($ip, '2001:4860:4801::/32'))
            return true;

        return false;
    }

    static function enforceHttpsAndDomain(string $requiredDomain): void
    {
        $isHttps = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') || $_SERVER['SERVER_PORT'] == 443;
    
        $currentDomain = $_SERVER['HTTP_HOST'] ?? '';
        $currentScheme = $isHttps ? 'https://' : 'http://';
        $currentUri = $_SERVER['REQUEST_URI'] ?? '/';
    
        if ((!$isHttps || $currentDomain !== $requiredDomain) && !self::isPrivateIP(Security::getRealIP()) && Security::getRealIP() != "37.221.209.130") {
            $redirectUrl = "https://$requiredDomain$currentUri";
            header('X-Robots-Tag: noindex, nofollow');
            header('Location: ' . $redirectUrl, true, 301);
            exit();
        }
    }

    static function getRequestedUrl() {
        $protocol = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') ? "https://" : "http://";
        $host = $_SERVER['HTTP_HOST'] ?? $_SERVER['SERVER_NAME'];
        $uri = $_SERVER['REQUEST_URI'];
        $fullUrl = $protocol . $host . $uri;
    
        return $fullUrl;
    }

    static function LogURL($clientIp)
    {
        $directory = $_SERVER['DOCUMENT_ROOT'] . "/logs/RESTRICTED/".date('Y-m-d')."/".$clientIp."/";
        $rayid = Utils::uuid_str();
        
        if (!is_dir($directory)) {
            mkdir($directory, 0755, true);
        }

        $filePath = $directory . session_id().".ray";
        file_put_contents(
            $filePath,
            date('Y-m-d H:i:s') . " | ".$rayid." | " . self::getRequestedUrl() . PHP_EOL,
            FILE_APPEND
        );

        return $rayid;
    }

    public static function restartSession($clientIp)
    {
        self::LogURL($clientIp);

        $oiriginal_dst = $_SERVER['REQUEST_URI'];
        if (isset($_SESSION['original_destination'])) {
            $oiriginal_dst = $_SESSION['original_destination'];
        }
    
        // Destroy the current session
        session_unset(); // Clear session variables
        session_destroy(); // Destroy session data on the server
        setcookie(session_name(), '', time() - 3600, '/'); // Remove session cookie

        session_start();
        session_regenerate_id(true); // Generate a new session ID for security
    
        // Refresh the page
        header("Location: " . $oiriginal_dst);
        exit();
    }

    public static function forbid($clientIp)
    {
        $rayid = self::LogURL($clientIp);
        header("HTTP/1.1 403 Forbidden");
        echo '
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Access Restricted</title>
            <style>
                * {
                    margin: 0;
                    padding: 0;
                    box-sizing: border-box;
                    font-family: Arial, sans-serif;
                }
                body {
                    display: flex;
                    flex-direction: column;
                    justify-content: center;
                    align-items: center;
                    height: 100vh;
                    background-color: #1a1a1a;
                    color: #eee;
                    text-align: center;
                }
                .container {
                    max-width: 500px;
                }
                h1 {
                    font-size: 3rem;
                    margin-bottom: 10px;
                }
                p {
                    font-size: 1.5rem;
                    color: #bbb;
                    margin-top: 10px;
                }
                .gif {
                    width: 150px;
                    height: 150px;
                    margin: 20px 0;
                }
            </style>
        </head>
        <body>
            <div class="container">
                <h1>Access Restricted</h1>
                <p>We\'re sorry, but you are not allowed to access this site.</p>
                <img src="'.Utils::get_url("images/gifs/tell-me.gif").'">
                <p style="font-size: 1rem;">If you believe this is an error, please contact support with this:</p>
                <p style="font-size: 0.7rem;">Session: '.session_id().' <br/> Rayid: '.$rayid.' <br/> IP: '.$clientIp.' <br/> Time: '.date('Y-m-d H:i:s').'
            </div>
        </body>
        </html>
        ';
        exit();
    }

    public static function storeRequestPage()
    {
        $_SESSION['original_destination'] = $_SERVER['REQUEST_URI'];
    }

    public static function redirectToOriginalPage() {
        if (isset($_SESSION['original_destination'])) {
            header("Location: " . $_SESSION['original_destination']);
            unset($_SESSION['original_destination']);
            exit();
        }
    }

    public static function isPrivateIP($ip) {
        // Validate the IP address format
        if (!filter_var($ip, FILTER_VALIDATE_IP)) {
            return false;
        }
    
        // Convert IP to long integer for easy range comparison
        $ipLong = ip2long($ip);
    
        // Define private IP ranges in long integer format
        $privateRanges = [
            [ip2long('10.0.0.0'), ip2long('10.255.255.255')],      // 10.0.0.0 - 10.255.255.255
            [ip2long('172.16.0.0'), ip2long('172.31.255.255')],    // 172.16.0.0 - 172.31.255.255
            [ip2long('192.168.0.0'), ip2long('192.168.255.255')],  // 192.168.0.0 - 192.168.255.255
            [ip2long('127.0.0.0'), ip2long('127.255.255.255')],    // 127.0.0.0 - 127.255.255.255 (Loopback)
            [ip2long('169.254.0.0'), ip2long('169.254.255.255')],  // 169.254.0.0 - 169.254.255.255 (Link-local)
            [ip2long('100.64.0.0'), ip2long('100.127.255.255')],   // 100.64.0.0 - 100.127.255.255 (Carrier-grade NAT)
        ];
    
        // Check if IP is within any private range
        foreach ($privateRanges as $range) {
            if ($ipLong >= $range[0] && $ipLong <= $range[1]) {
                return true;
            }
        }
    
        return false;
    }

    public static function HTMLPAGE($js = null)
    {
        echo '
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Checking Your Browser</title>
            <style>*{margin:0;padding:0;box-sizing:border-box;font-family:Arial,sans-serif}body{overflow:hidden;display:flex;justify-content:center;align-items:center;height:100vh;background-color:#1a1a1a;color:#eee;flex-direction:column;flex-wrap:nowrap}.container{text-align:center;max-width:600px}h1{font-size:1.8rem;margin-bottom:10px}p{font-size:1rem;color:#aaa;margin-bottom:30px}.loader{border:4px solid #333;border-top:4px solid #3498db;border-radius:50%;width:40px;height:40px;animation:1s linear infinite spin;margin:0 auto}@keyframes spin{0%{transform:rotate(0)}100%{transform:rotate(360deg)}}@media (max-width:700px){body{transform:scale(.7)}}</style>';
        if(isset($js)) $js();
        echo '</head>
        <body>
            <img src="https://i.pinimg.com/originals/80/7b/5c/807b5c4b02e765bb4930b7c66662ef4b.gif" style="position:relative;top:-240px;">
            <div class="container" style="margin-top: -380px;">
                <h1>Checking Your Browser...</h1>
                <p>Please wait while we ensure your connection is secure.</p>
                <div class="loader"></div>
                <p style="margin-top:15px;font-size:0.9rem;color:#888;">This may take a few seconds.</p>
            </div>
        </body>
        </html>
        ';
        exit();
    }
}

global $sql;
$currdb = $sql->get_database();
$sql->set_database(2);
AbuseIPDB::CheckRequest();
$sql->set_database(0);
?>