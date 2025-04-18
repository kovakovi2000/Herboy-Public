<?php
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/Config.php");
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/includes/Utils.php");

class SteamProfileInfo {
    public $steamid32;
    public $steamid64;
    public $personaname;
    public $profileurl;
    public $avatar;
    public $avatarmedium;
    public $avatarfull;
    public $personastate;
    public $realname;
    public $uptodate;
    public $Vac;
    public $GameBan;
    public $DaySinceLastBan;
    public $PlayMinute = 0;
    public $bgurl;
    public $bgIsAnimated = false;

    private function IsSteam()
    {
        $parts = explode(':', $this->steamid32);
        $matches = array();
        $steamdata['isNonsteam'] = "";
        if (preg_match('#(\d+)$#', $parts[0], $matches)) {
            $steamdata['isNonsteam'] = $matches[1];
            if((int)$steamdata['isNonsteam'] > 1)
                $steamdata['isNonsteam'] = "1";
        }
        if (preg_match('#(\d+)$#', $parts[1], $matches)) {
            if((int)$matches[1] > 1)
                $steamdata['isNonsteam'] = "1";
        }

        return $steamdata['isNonsteam'] != "1";
    }

    function __construct($steamid64, $steamid32 = null)
    {
        if($steamid64 == null)
        {
            if($steamid32 == null)
                return;
                
            $this->steamid32 = $steamid32;
            $steamid64 = Utils::ConvertSteamID32to64($steamid32);
        }
        else
            $this->steamid32 = Utils::ConvertSteamID64to32($steamid64);

        if($steamid64 == null || $this->steamid32 == null)
            return;

        if(!$this->IsSteam())
            return;
        
        try {
            $content = json_decode($this->curlRequest("https://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=".Config::$apikey_SteamAuth."&steamids=".$steamid64), true);
            if(empty($content['response']['players'][0]['steamid'])) return;
            $this->steamid64 = $content['response']['players'][0]['steamid'];
            $this->profileurl = $content['response']['players'][0]['profileurl'];
            $this->personaname = $content['response']['players'][0]['personaname'];
            $this->avatar = $content['response']['players'][0]['avatar'];
            $this->avatarmedium = $content['response']['players'][0]['avatarmedium'];
            $this->avatarfull = $content['response']['players'][0]['avatarfull'];
            $this->personastate = $content['response']['players'][0]['personastate'];
            if (isset($content['response']['players'][0]['realname'])) { 
                $this->realname = $content['response']['players'][0]['realname'];
            } else {
                $this->realname = "Real name not given";
            }
            $this->uptodate = time();
        } catch (Exception $e) { }
    }

    function SuccessInit()
    {
        return isset($this->steamid64);
    }

    function request_Bans()
    {
        try {
            $content = json_decode($this->curlRequest("http://api.steampowered.com/ISteamUser/GetPlayerBans/v1/?key=".Config::$apikey_SteamAuth."&steamids=".$this->steamid64), true);

            $this->Vac = (int)$content['players'][0]['NumberOfVACBans'];
            $this->GameBan = (int)$content['players'][0]['NumberOfGameBans'];
            $this->DaySinceLastBan = (int)$content['players'][0]['DaysSinceLastBan'];
        } catch (Exception $e) { return false; }
        return true;
    }

    function request_Playtime()
    {
        try {
            $content = json_decode($this->curlRequest("http://api.steampowered.com/IPlayerService/GetOwnedGames/v0001/?key=".Config::$apikey_SteamAuth."&steamid=".$this->steamid64), true);
            $this->PlayMinute = 0;
            if(isset($content['response']['games']))
            {
                foreach ($content['response']['games'] as &$game) {
                    if((int)$game['appid'] == 10)
                    {
                        $this->PlayMinute = (int)$game['playtime_forever'];
                        break;
                    }
                }
            }
        } catch (Exception $e) { return false; }
        return true;
    }

    function request_Background()
    {
        try {
            $url = $this->curlRequest("https://steamcommunity.com/profiles/".$this->steamid64);
            if(strpos($url, "has_profile_background") !== false)
            {
                if(strpos($url, "profile_animated_background") !== false)
                {
                    $pieces = explode('<div class="profile_animated_background">', $url);
                    $insert = explode('playsinline', explode('</div>', $pieces[1])[0]);
                    $this->bgurl = $insert[0].' id="bg_animated" class="bg-video-container" playsinline'.$insert[1];
                    $this->bgIsAnimated = true;
                }
                else
                {
                    $pieces = explode("background-image: url( '", $url);
                    $this->bgurl = explode('\' );">', $pieces[1])[0];
                }
            }
        } catch (Exception $e) { return false; }
        return true;
    }

    private function curlRequest($url)
    {
        $ch = curl_init();

        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_TIMEOUT, 3); 
        curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true); 
        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
        curl_setopt($ch, CURLOPT_DNS_CACHE_TIMEOUT, 3600);

        $result = curl_exec($ch);

        if (curl_errno($ch)) {
            return false;
        }

        curl_close($ch);

        return $result;
    }
}

