
<!DOCTYPE html>

<html lang="hu">
<head>
    <meta charset="utf-8">
	  <title>Herboy</title>
		<style type="text/css">body {margin: 0px;}</style>
</head>
<body>
	<?php

	ini_set('display_errors', '1');
	ini_set('display_startup_errors', '1');
	error_reporting(E_ALL);

	//echo "Good API.";
	//remove cookie
	// echo "DATA CLEARED";
	// unset($_COOKIE[$cookiename]);
	// setcookie('$cookiename', null, -1, '/');

	function base64url_encode($data) {
		return rtrim(strtr(base64_encode($data), '+/', '-_'), '=');
	}
	
	function base64url_decode($data) {
		return base64_decode(str_pad(strtr($data, '-_', '+/'), strlen($data) % 4, '=', STR_PAD_RIGHT));
	}

	function getRealIP()
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

	$localIp = getRealIP();

	$g_steam = filter_input(INPUT_GET, 'st', FILTER_SANITIZE_FULL_SPECIAL_CHARS);
	$g_ipv4 = filter_input(INPUT_GET, 'i', FILTER_SANITIZE_FULL_SPECIAL_CHARS);
	$g_validator = filter_input(INPUT_GET, 'v', FILTER_VALIDATE_INT);
    $g_server = filter_input(INPUT_GET, 'se', FILTER_VALIDATE_INT);

	$local = "AmxxBanSystemUUID;{$g_steam};{$g_ipv4};{$g_validator}";

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
				die("THIS SERVER IS UNKOWNON"); break;
	}

	// if($g_steam == "STEAM_0:1:848054044")
	// {
	// 	if(isset($_COOKIE[$cookiename]))
	// 	{
	// 		echo "DATA CLEARED";
	// 		unset($_COOKIE[$cookiename]);
	// 		setcookie($cookiename, null, -1, '/');
	// 	}
	// 	else
	// 	{
	// 		echo "ALREADY DATA CLEARED";
	// 	}
	// 	return;
	// }

	if(md5($local) == $_GET['h'])
	{
		

		$cookiecontent = array("steamid", "ipv4", "ipv6");
		$cookiecontent["steamid"] = array();
		$cookiecontent["ipv4"] = array();
		$cookiecontent["ipv6"] = array();

		if(isset($_COOKIE[$cookiename]))
		{
			$cookiecontent = unserialize(base64url_decode($_COOKIE[$cookiename]));
			$uniquemd5 = md5("AmxxBanSystemUUID;{$g_steam};{$g_ipv4}");
			$cookiedata = json_encode($cookiecontent);
			if(!isset($cookiecontent['UKey']))
				$cookiecontent['UKey'] = md5(random_int(0, 9999999).microtime(true).random_int(0, 9999999));
			@mysqli_query($sql, "INSERT INTO `amx_cookie` (`hash`, `Steamid`, `ip`, `cookie`) VALUES ('{$uniquemd5}', '{$g_steam}', '{$g_ipv4}', '{$cookiedata}') ON DUPLICATE KEY UPDATE cookie = '$cookiedata';");

			if(in_array($g_steam, $cookiecontent["steamid"]))
			{
				@mysqli_query($sql, "INSERT INTO `amx_validator` (steamid, validator, UKey) VALUES (\"{$g_steam}\", \"{$g_validator}\", \"{$cookiecontent['UKey']}\") ON DUPLICATE KEY UPDATE validator = \"$g_validator\", `amx_validator`.`SteamIdChanged` = 0, UKey = \"{$cookiecontent['UKey']}\";");
				if(strlen($localIp) > 16)
					@mysqli_query($sql, "UPDATE `amx_validator` SET `amx_validator`.`ipv6` = '{$localIp}' WHERE `amx_validator`.`steamid` = '{$g_steam}';");
				else
					@mysqli_query($sql, "UPDATE `amx_validator` SET `amx_validator`.`ipv4` = '{$localIp}' WHERE `amx_validator`.`steamid` = '{$g_steam}';");
			}
			else
			{
				if($g_steam != "STEAM_ID_LAN" && $g_steam != "HLTV" && count($cookiecontent['steamid']) <= 3)
				{
					$parts = explode(':', $g_steam);
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

					if($isNonsteam == "1")
						@mysqli_query($sql, "INSERT INTO `amx_validator` (steamid, validator, SteamIdChanged) VALUES (\"{$g_steam}\", \"{$g_validator}\", 1) ON DUPLICATE KEY UPDATE validator = \"$g_validator\";");
					else
					{
						array_push($cookiecontent['steamid'], $g_steam);
						@mysqli_query($sql, "INSERT INTO `amx_validator` (steamid, validator, UKey) VALUES (\"{$g_steam}\", \"{$g_validator}\", \"{$cookiecontent['UKey']}\") ON DUPLICATE KEY UPDATE validator = \"$g_validator\", `amx_validator`.`SteamIdChanged` = 0, UKey = \"{$cookiecontent['UKey']}\";");
					}
				}
				else
					mysqli_query($sql, "INSERT INTO `amx_validator` (steamid, validator, SteamIdChanged) VALUES (\"{$g_steam}\", \"{$g_validator}\", 1) ON DUPLICATE KEY UPDATE validator = \"$g_validator\";");
			}

			//array_push($cookiecontent['steamid'], $g_steam);
			
			if(!in_array($g_ipv4, $cookiecontent["ipv4"]))
				array_push($cookiecontent['ipv4'], $g_ipv4);

			if(strlen($localIp) > 16 && !in_array($localIp, $cookiecontent["ipv6"]))
				array_push($cookiecontent['ipv6'], $localIp);
		}
		else
		{
			if(!isset($cookiecontent['UKey']))
				$cookiecontent['UKey'] = md5(random_int(0, 9999999).microtime(true).random_int(0, 9999999));
			@mysqli_query($sql, "INSERT INTO `amx_validator` (steamid, validator, UKey) VALUES (\"{$g_steam}\", \"{$g_validator}\", \"{$cookiecontent['UKey']}\") ON DUPLICATE KEY UPDATE validator = \"$g_validator\", UKey = \"{$cookiecontent['UKey']}\";");
			if(strlen($localIp) > 16)
				@mysqli_query($sql, "UPDATE `amx_validator` SET `amx_validator`.`ipv6` = '{$localIp}' WHERE `amx_validator`.`steamid` = '{$g_steam}';");
			else
				@mysqli_query($sql, "UPDATE `amx_validator` SET `amx_validator`.`ipv4` = '{$localIp}' WHERE `amx_validator`.`steamid` = '{$g_steam}';");
			array_push($cookiecontent['steamid'], $g_steam);
			array_push($cookiecontent['ipv4'], $g_ipv4);
			if(strlen($localIp) > 16)
				array_push($cookiecontent['ipv6'], $localIp);
		}

		setcookie(($cookiename), base64url_encode(serialize($cookiecontent)), time()+60*60*24*365*10 ); //10 éve
		$foundbid = false;
		foreach ($cookiecontent['steamid'] as &$value) {
			if($foundbid)
				break;
			$ban = @mysqli_query($sql, "SELECT `amx_bans`.`bid` FROM `amx_bans` WHERE `amx_bans`.`player_id` = '{$value}' AND `expired` = 0 LIMIT 1;");
			if(mysqli_num_rows($ban) == 0)
				continue;
			$row = mysqli_fetch_array($ban);
			if($row['bid'] > 0)
			{
				$foundbid = true;
				@mysqli_query($sql, "UPDATE `amx_validator` SET `amx_validator`.`bid` = {$row['bid']} WHERE `amx_validator`.`steamid` = '{$g_steam}';");
			}
		}

		foreach ($cookiecontent['ipv4'] as &$value) {
			if($foundbid)
				break;
			$ban = @mysqli_query($sql, "SELECT `amx_bans`.`bid` FROM `amx_bans` WHERE `amx_bans`.`player_ip` = '{$value}' AND `expired` = 0 LIMIT 1;");
			if(mysqli_num_rows($ban) == 0)
				continue;
			$row = mysqli_fetch_array($ban);
			if($row['bid'] > 0)
			{
				$foundbid = true;
				@mysqli_query($sql, "UPDATE `amx_validator` SET `amx_validator`.`bid` = {$row['bid']} WHERE `amx_validator`.`steamid` = '{$g_steam}';");
			}
		}

		foreach ($cookiecontent['ipv6'] as &$value) {
			if($foundbid)
				break;
			$ban = @mysqli_query($sql, "SELECT `amx_bans`.`bid` FROM `amx_bans` WHERE `amx_bans`.`ipv6` = '{$value}' AND `expired` = 0 LIMIT 1;");
			if(mysqli_num_rows($ban) == 0)
				continue;
			$row = mysqli_fetch_array($ban);
			if($row['bid'] > 0)
			{
				$foundbid = true;
				@mysqli_query($sql, "UPDATE `amx_validator` SET `amx_validator`.`bid` = {$row['bid']} WHERE `amx_validator`.`steamid` = '{$g_steam}';");
			}
		}

		if(!$foundbid)
			@mysqli_query($sql, "UPDATE `amx_validator` SET `amx_validator`.`bid` = 0 WHERE `amx_validator`.`steamid` = '{$g_steam}';");
		
			$cracher = @mysqli_query($sql, "SELECT `webcrasher`.`steamid` FROM `webcrasher` WHERE `webcrasher`.`steamid` = '{$g_steam}' LIMIT 1;");
			if(mysqli_num_rows($cracher) == 0)
				header("Location: http://87.229.115.72/ban_api/motd_herboy.html?ver122254123");
			else
			{
				file_put_contents(
					"/var/www/html/herboyd2.hu/public/_CRASHLOG/CRASH_".date('Y-m-d').".log",
					date('Y/m/d H:i:s'). " | " . $g_steam . " | " . $localIp . " | \" UUID: ". (isset($cookiecontent['UKey']) ? $cookiecontent['UKey'] : "NULL") ."\"\n",
					FILE_APPEND);
				header("Location: http://87.229.115.72/ban_api/crasher.html");
			}
		
		die();
		return;
	}
?>
</body>
</html>