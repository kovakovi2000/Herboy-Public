<?php
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/includes/UserProfile.php");
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/Config.php");
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/includes/Utils.php");
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/includes/EzSql.php");
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/includes/ErrorManager.php");

class Account {
    private static $AgreeToken;
    private static $LoginToken;
    public static $IP;
    public static $UserProfile;
    static function init() {
        global $sql;
        self::$IP = Utils::GetIP();
        if (!isset($_SESSION['account'])) {
            self::TryCookieLogin();
        } else {
            self::$UserProfile = unserialize($_SESSION['account']);
        }
    }
    static function CanBan()
    {
        if(self::IsLogined())
            return self::$UserProfile->PermLvl->isAdmin() || in_array(max(self::$UserProfile->PermLvl->VipLvl), array(3, 4));
        else
            return false;
    }

    static function CanMute()
    {
        if(self::IsLogined())
            return self::$UserProfile->PermLvl->isAdmin() || max(self::$UserProfile->PermLvl->VipLvl) > 1;
        else
            return false;
    }

    static function Devs()
{
    if (self::IsLogined()) {
        return in_array(self::$UserProfile->PermLvl->isAdmin(), array(1, 2, 3));
    } else {
        return false;
    }
}

    static function IsLogined()
    {
        if(isset(self::$UserProfile))
            return self::$UserProfile->SuccessInit();
        else
            return false;
    }

    static function IsSteam()
    {
        if(isset(self::$UserProfile))
        {
            if(isset(self::$UserProfile->Steam))
                return self::$UserProfile->Steam->SuccessInit();
            else
                return false;
        }
        else
            return false;
    }

    static function Logout()
    {
        global $sql;
        Utils::reqCookie(self::$LoginToken, Config::$cookie_LoginToken_name);
        Utils::remCookie(Config::$cookie_LoginToken_name);
        
        $sql->update(
            Config::$t_LoginToken_name,
            array("Logout" => 1),
            "`Token` = '" . mysqli_real_escape_string($sql->mysqli, self::$LoginToken) . "'"
        );
    
        unset($_SESSION['account']);
        session_unset();
        session_destroy();
        
    }

    static function RedirectSteamLogin()
    {
        unset($_SESSION['steamid64']);
        include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/includes/LightOpenID.php");
        try {
            $openid = new LightOpenID(Config::$apikey_SteamAuth_vars['domainname']);
            
            if(!$openid->mode) {
                $openid->identity = 'https://steamcommunity.com/openid';
                header('Location: ' . $openid->authUrl());
            } elseif ($openid->mode != 'cancel') {
                if($openid->validate()) { 
                    $id = $openid->identity;
                    $ptn = "/^https?:\/\/steamcommunity\.com\/openid\/id\/(7[0-9]{15,25}+)$/";
                    preg_match($ptn, $id, $matches);
                    
                    $_SESSION['steamid64'] = $matches[1];
                    if (!headers_sent()) {
                        header('Location: '.Config::$apikey_SteamAuth_vars['loginpage']);
                        exit;
                    } else {
                        ?>
                        <script type="text/javascript">
                            window.location.href="<?=Config::$apikey_SteamAuth_vars['loginpage']?>";
                        </script>
                        <noscript>
                            <meta http-equiv="refresh" content="0;url=<?=Config::$apikey_SteamAuth_vars['loginpage']?>" />
                        </noscript>
                        <?php
                        exit;
                    }
                }
            }
        } catch(ErrorException $e) { }
    }

    static function TryCookieLogin()
    {
        if (!Utils::reqCookie(self::$LoginToken, Config::$cookie_LoginToken_name) ||
            !Utils::reqCookie(self::$AgreeToken, Config::$cookie_Agreed_name)) {
                
            return;
        }
        
        global $sql;
        
        if ($sql === null) {
        //    error_log("Database connection not established.");
            return;
        }
        
        $expireTime = time();
        
        $escapedToken = $sql->escape(self::$LoginToken);
        $query = "SELECT UserId, steamid64 FROM " . Config::$t_LoginToken_name . 
                 " WHERE Token = '$escapedToken' AND Expire > $expireTime";
        
        $result = $sql->query($query);
        
        if ($result && $result->num_rows > 0) {
            $tokenrow = $result->fetch_assoc();
        } else {
            $tokenrow = null;
        }
        
        if ($tokenrow === null || $result->num_rows != 1) {
            return;
        }
        
        $account = new UserProfile((int)$tokenrow['UserId']);
        if (!$account->SuccessInit()) {
            return;
        }

        $_SESSION['account'] = serialize($account);
        self::$UserProfile = $account;
        self::setAgree();
        self::setLogin();
        $sql->insert(
            Config::$t_LoginLog_name,
            array("UserId", "LoginToken", "AgreeToken", "IP"),
            array($account->id, self::$LoginToken, self::$AgreeToken, self::$IP)
        );
    }
    
    
    
    static function SteamLogin()
    {
        if(empty($_SESSION['steamid64']))
            return "SteamCancelled";
        
        global $sql;
        $steamid32 = Utils::ConvertSteamID64to32($_SESSION['steamid64']);
        $UserData = $sql->select_row(Config::$t_regsystem_name, null, "RegisterID='$steamid32'");
        $account = new UserProfile(null, null, $UserData);
        if(!$account->SuccessInit())
            return "FatalError";

        unset($_SESSION['steamid64']);
        $_SESSION['account'] = serialize($account);
        self::$UserProfile = $account;
        self::setAgree();
        self::setLogin();
        $sql->insert(
            Config::$t_LoginLog_name,
            array("UserId", "LoginToken", "AgreeToken", "IP"),
            array($account->id, self::$LoginToken, self::$AgreeToken, self::$IP)
        );
        return "Logined";
    }

    static function Login($username, $password)
    {
        // $username = strip_tags(filter_input(INPUT_POST, 'username', FILTER_SANITIZE_FULL_SPECIAL_CHARS));
		// $password = $_POST['password'];

        if(empty($username))
            return "MissingUsername";
        else if(!preg_match('/^[a-zA-Z0-9]{4,16}+$/iD', $username))
            return "BadFormatUsername";
        else if(empty($password))
            return "MissingPassword";
        else if(!preg_match('/^[a-zA-Z0-9]{4,32}+$/iD', $password))
            return "BadFormatPassword";
        
        $pass = hash('sha3-512', hash('sha3-512', $password.Config::$secret_password_salt));
        
        global $sql;
        $FailedCount = 0;
        $canloginquery = $sql->select_row(
            Config::$t_LoginFailed_name, 
            array("COUNT(`id`) as TotalCount"), 
            "(`username`='$username' OR `ip`='".self::$IP."') AND `time` > ".(time() - 60*60),
            5)['TotalCount'];
        
        if ($canloginquery < 5) {
            $UserProfile = $sql->select_row(
                Config::$t_regsystem_name,
                array(),
                "`Username`='$username' AND `Password`='$pass'"
            );
            if (isset($UserProfile['id'])){

                $account = new UserProfile(null, null, $UserProfile);
                if(!$account->SuccessInit())
                    return "FatalError";

                $_SESSION['account'] = serialize($account);
                self::$UserProfile = $account;
                self::setAgree();
                self::setLogin();
                $sql->insert(
                    Config::$t_LoginLog_name,
                    array("UserId", "LoginToken", "AgreeToken", "IP"),
                    array($account->id, self::$LoginToken, self::$AgreeToken, self::$IP)
                );
                
                return "Logined";
            }
            else
            {
                $sql->insert(
                    Config::$t_LoginFailed_name,
                    array("ip", "username", "time"),
                    array(self::$IP, $username, time())
                );
                return "InvalidInput";
            }
        }
        else
            return "TooManyTry";
    }

    private static function setAgree()
    {
        global $sql;
        if(!Utils::reqCookie(self::$AgreeToken, Config::$cookie_Agreed_name))
        {
            self::$AgreeToken = Utils::uuid_str();
            Utils::setCookie(Config::$cookie_Agreed_name, self::$AgreeToken);
            $sql->insert(
                Config::$t_Agreed_name, 
                array("AgreeToken", "UserId", "IP"), 
                array(self::$AgreeToken, self::$UserProfile->id, self::$IP)
            );
        }
    }

    private static function setLogin()
    {
        global $sql;
    
        if (Utils::reqCookie(self::$LoginToken, Config::$cookie_LoginToken_name)) {
            $escapedToken = $sql->escape(self::$LoginToken);

            $tokenRow = $sql->select_row(
                Config::$t_LoginToken_name,
                array("UserId"),
                "Token = '$escapedToken'"
            );
            
    
            if ($tokenRow && (int)$tokenRow['UserId'] === self::$UserProfile->id) {
                return;
            } else {
                $sql->delete(
                    Config::$t_LoginToken_name,
                    "Token = '" . $sql->escape(self::$LoginToken) . "'"
                );
            }            
        }
    
        self::$LoginToken = Utils::uuid_str();
        self::$AgreeToken = Utils::uuid_str();
    
        Utils::setCookie(
            Config::$cookie_Agreed_name,
            self::$AgreeToken,
            self::$UserProfile->Steam->SuccessInit() ? Config::$cookie_expire_loginSteam : Config::$cookie_expire_loginNormal
        );
    
        $sql->insert(
            Config::$t_LoginToken_name,
            array(
                "Token",
                "UserId",
                "steamid64",
                "Expire"
            ),
            array(
                self::$LoginToken,
                self::$UserProfile->id,
                self::$UserProfile->Steam->SuccessInit() ? self::$UserProfile->Steam->steamid64 : "",
                time() + (self::$UserProfile->Steam->SuccessInit() ? Config::$cookie_expire_loginSteam : Config::$cookie_expire_loginNormal)
            )
        );
    
        $createdTime = date('Y-m-d H:i:s', time());
        
    $sql->insert(
        Config::$t_LoginByTokenLog_name,
        array("LoginToken", "UserId", "IP", "Created"),
        array(self::$LoginToken, self::$UserProfile->id, self::$IP, $createdTime)
    );
    
        Utils::setCookie(
            Config::$cookie_LoginToken_name,
            self::$LoginToken,
            self::$UserProfile->Steam->SuccessInit() ? Config::$cookie_expire_loginSteam : Config::$cookie_expire_loginNormal
        );
    }
    
}

Account::init();
