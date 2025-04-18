<?php
date_default_timezone_set("Europe/Budapest");
class Utils {
    static function html_error($code)
    {
        http_response_code($code);
        $_GET = array();
        $_GET[$code] = "";
        include_once($_SERVER['DOCUMENT_ROOT'] . "/error.php");
        die();
    }

    static function php_error($class, $error)
    {
        throw new Exception("[APD3 - ".(empty($class) ?  "NONE" : get_class($class))."] $error", 2);
    }

    static function debug($data, $dump = false)
    {
        print "<pre>";
        if($dump == true)
            var_dump($data);
        else
            print_r($data);
        print "</pre>";
    }

    static function isHTTPS() {
        return (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') || $_SERVER['SERVER_PORT'] == 443;
    }

    static function get_url($href = null) {
        return (self::isHTTPS() ? "https" : "http") . "://" . $_SERVER['SERVER_NAME'] . (isset($href) ? "/" . $href : "" );
    }

    static function redirect($url, $external = false)
    {
        if($external)
            header("location: $url");
        else
            header("location: ".self::get_url($url));
        exit(1);
    }

    static function header($title = "Oldal", $post_header_func = null, $pre_header_func = null) {
        return include_once($_SERVER['DOCUMENT_ROOT'] . "/theme/header.php");
    }

    static function body($content_func = null) {
        return include_once($_SERVER['DOCUMENT_ROOT'] . "/theme/body.php");
    }

    static function card($title = "Kártya cím", $cont_func = null, $first = false) {
        return include_once($_SERVER['DOCUMENT_ROOT'] . "/theme/card.php");
    }

    static function dialog($dialog, $url = "index", $time = 2) {
        return include_once($_SERVER['DOCUMENT_ROOT'] . "/theme/dialog.php");
    }

    static function footer($post_footer_func = null, $pre_footer_func = null) {
        return include_once($_SERVER['DOCUMENT_ROOT'] . "/theme/footer.php");
    }

    static function session_status($session_id = null){
        if(!extension_loaded('session') || !session_valid_id($session_id)){
            return 0;
        }elseif(!file_exists(session_save_path().'/sess_'.( isset($session_id) ? $session_id : session_id() ))){
            return 1;
        }else{
            return 2;
        }
    }

    static function session_valid_id($session_id)
    {
        return preg_match('/^[-,a-zA-Z0-9]{1,128}$/', $session_id) > 0;
    }

    static function getIP() {
        // if (isset($_SERVER["HTTP_CLIENT_IP"])) {
        //     $ip = $_SERVER["HTTP_CLIENT_IP"];
        // } elseif (isset($_SERVER["HTTP_X_FORWARDED_FOR"])) {
        //     $ip = $_SERVER["HTTP_X_FORWARDED_FOR"];
        // } elseif (isset($_SERVER["HTTP_X_FORWARDED"])) {
        //     $ip = $_SERVER["HTTP_X_FORWARDED"];
        // } elseif (isset($_SERVER["HTTP_FORWARDED_FOR"])) {
        //     $ip = $_SERVER["HTTP_FORWARDED_FOR"];
        // } elseif (isset($_SERVER["HTTP_FORWARDED"])) {
        //     $ip = $_SERVER["HTTP_FORWARDED"];
        // } else {
        //     $ip = $_SERVER["REMOTE_ADDR"];
        // }

        if (isset($_SERVER["HTTP_CF_CONNECTING_IP"])) {
            // Cloudflare client IP
            $ip = $_SERVER["HTTP_CF_CONNECTING_IP"];
        } elseif (isset($_SERVER["HTTP_CLIENT_IP"])) {
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

        // Strip any secondary IP, etc., from the IP address
        if (strpos($ip, ',') !== false) {
            $ip = substr($ip, 0, strpos($ip, ','));
        }
        return $ip;
    }
    
    static function uuid_str()
    {
        $randomBytes = openssl_random_pseudo_bytes(20);
        $num = hexdec(bin2hex($randomBytes));
        $index = '1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
        $base = strlen($index);
        $out = '';
        for ($t = floor(log10($num) / log10($base)); $t >= 0; $t--) {
            $a = floor($num / pow($base, $t));
            $out .= substr($index, $a, 1);
            $num -= $a * pow($base, $t);
        }
        return $out;
    }

    static function getCookie($name)
    {
        if(isset($_COOKIE[$name]))
            return strip_tags(filter_input(INPUT_COOKIE, $name, FILTER_SANITIZE_FULL_SPECIAL_CHARS));
        else
            return null;
    }
    
    static function setCookie($name, $value, $time = null) //Default 10 year
    {
        return setcookie($name, $value, ($time == null ? time()+Config::$cookie_expire_default : time()+$time), "/"); //10 év
    }

    static function reqCookie(&$varible, $name)
    {
        if(!isset($_COOKIE[$name]))
            return false;
        else
        {
            $varible = self::getCookie($name);
            return true;
        }
    }

    static function remCookie($name)
    {
        if (isset($_COOKIE[$name])) {
            // Unset the cookie in the user's browser by setting its expiration date in the past
            setcookie($name, '', time() - 3600, '/');
            // Optionally unset the $_COOKIE superglobal to prevent further use in the script
            unset($_COOKIE[$name]);
        }
    }

    static function validateSteamID32($steamid32)
    {
        if($steamid32 == "STEAM_ID_LAN" || $steamid32 == "HLTV")
            return false;
        try {
            $parts = explode(':', $steamid32);
            if (preg_match('#(\d+)$#', $parts[0], $matches)) {
                if((int)$matches[1] > 1)
                    return false;
            }
            if (preg_match('#(\d+)$#', $parts[1], $matches)) {
                if((int)$matches[1] > 1)
                    return false;
            }
        } catch (Exception $e) {
            return false;
        }
        return true;
    }

    static function ConvertSteamID32to64($steamid32)
    {
        try {
            $parts = explode(':', $steamid32);
            $text = "".bcadd(bcadd(bcmul($parts[2], '2'), '76561197960265728'), $parts[1]);
            return explode('.', $text)[0];
        } catch (Exception $e) {
            return null;
        }
    }

    static function ConvertSteamID64to32($steamid64)
    {
        try {
            $idNumber = '0';

            if (bcmod($steamid64, '2') == 0) {
                $temp =	bcsub($steamid64, 76561197960265728);
            } else {
                $idNumber = '1';
                $temp =	bcsub($steamid64, bcadd(76561197960265728, '1'));
            }

            $accountNumber = bcdiv($temp, '2') ?? 0;
            $accountNumber = number_format($accountNumber, 0, '', '');
            return "STEAM_0:{$idNumber}:{$accountNumber}";
        } catch (Exception $e) {
            return null;
        }
    }

    static function SecToClock($seconds, $noseconds=false) {
        $t = round($seconds);
        if($noseconds)
            return sprintf('%02d Óra %02d perc', ($t/3600),($t/60%60));
        else
            return sprintf('%02d Óra %02d perc %02d mp', ($t/3600),($t/60%60), $t%60);
    }

    static function CensorPart($part)
    {
        switch(strlen($part))
        {
            case 1:
                return $part;
                break;
            case 2:
                $part[0] = "*";
                return $part;
                break;
            case 3:
                $part[1] = "*";
                return $part;
                break;
        }
        return $part;
    }

    static function CensorIP($ip)
    {
        $pieces = explode(".", $ip);
        return 
        self::CensorPart($pieces[0]) . "." .
        self::CensorPart($pieces[1]) . "." .
        self::CensorPart($pieces[2]) . "." .
        self::CensorPart($pieces[3]);
    }
}

if(class_exists("Config"))
{
    Config::$apikey_SteamAuth_vars['domainname'] = $_SERVER['SERVER_NAME'];
    Config::$apikey_SteamAuth_vars['logoutpage'] = Utils::get_url("login?steam");
    Config::$apikey_SteamAuth_vars['loginpage'] = Utils::get_url("login?steam");
}