-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Gép: localhost
-- Létrehozás ideje: 2025. Ápr 17. 23:13
-- Kiszolgáló verziója: 10.3.39-MariaDB-0ubuntu0.20.04.2
-- PHP verzió: 8.3.17

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Adatbázis: `s2_herboy`
--

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `amx_activity`
--

CREATE TABLE `amx_activity` (
  `id` int(11) NOT NULL,
  `steamid` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `time` timestamp NOT NULL DEFAULT current_timestamp(),
  `serverid` int(11) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `amx_alias`
--

CREATE TABLE `amx_alias` (
  `hash` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `Steamid` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `Name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `LastUsed` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `Active` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `amx_bans`
--

CREATE TABLE `amx_bans` (
  `bid` int(11) NOT NULL,
  `player_ip` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT 'Unknown',
  `player_id` varchar(35) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT 'Unknown',
  `player_nick` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT 'Unknown',
  `admin_ip` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `admin_id` varchar(35) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT 'Unknown',
  `admin_nick` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT 'Unknown',
  `ban_reason` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `ban_created` int(11) DEFAULT NULL,
  `ban_length` int(11) DEFAULT NULL,
  `ban_kicks` int(11) NOT NULL DEFAULT 0,
  `expired` int(11) NOT NULL DEFAULT 0,
  `UID` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `UIP` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `UName` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `modified` int(11) NOT NULL DEFAULT 0,
  `isNew` int(11) NOT NULL,
  `ForbiddenUnban` int(11) NOT NULL DEFAULT 0,
  `unban_uuid` varchar(37) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `uuid_created` int(11) NOT NULL,
  `uuid_used` int(11) NOT NULL DEFAULT 0,
  `BannedPlayerId` int(11) NOT NULL,
  `BannedByPlayerId` int(11) NOT NULL,
  `BannedByAdminPerm` int(11) NOT NULL,
  `modifiedby` varchar(33) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `amx_bans_modified`
--

CREATE TABLE `amx_bans_modified` (
  `bid` int(11) NOT NULL,
  `UserId` int(11) NOT NULL,
  `ban_reason` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `ModifiedAt` int(11) NOT NULL,
  `id` int(11) NOT NULL,
  `ban_length` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `amx_drawprizetime`
--

CREATE TABLE `amx_drawprizetime` (
  `steamid` varchar(33) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `PlayTime` int(11) NOT NULL,
  `skId` int(11) NOT NULL,
  `FriendSent` tinyint(1) NOT NULL DEFAULT 0,
  `claimed` tinyint(1) NOT NULL DEFAULT 0,
  `SteamURL` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `amx_kick`
--

CREATE TABLE `amx_kick` (
  `kid` int(11) NOT NULL,
  `player_ip` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT 'Unknown',
  `player_id` varchar(35) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT 'Unknown',
  `player_nick` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT 'Unknown',
  `admin_ip` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `admin_id` varchar(35) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT 'Unknown',
  `admin_nick` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT 'Unknown',
  `kick_reason` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `kick_created` int(11) DEFAULT NULL,
  `ban_length` int(11) DEFAULT NULL,
  `ban_kicks` int(11) NOT NULL DEFAULT 0
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `amx_messages`
--

CREATE TABLE `amx_messages` (
  `Steamid` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `Name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `Teamsay` int(11) NOT NULL,
  `Team` int(11) NOT NULL,
  `Message` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `Time` int(11) NOT NULL,
  `id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `amx_mutes`
--

CREATE TABLE `amx_mutes` (
  `bid` int(11) NOT NULL,
  `player_ip` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT 'Unknown',
  `player_id` varchar(35) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT 'Unknown',
  `player_nick` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT 'Unknown',
  `admin_ip` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `admin_id` varchar(35) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT 'Unknown',
  `admin_nick` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT 'Unknown',
  `mute_reason` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `mute_created` int(11) DEFAULT NULL,
  `mute_length` int(11) DEFAULT NULL,
  `mute_type` int(11) NOT NULL DEFAULT 0,
  `expired` int(11) NOT NULL DEFAULT 0,
  `UID` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `UIP` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `UName` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `modified` int(11) NOT NULL DEFAULT 0,
  `isNew` int(11) NOT NULL,
  `MutedByAdminPerm` int(11) NOT NULL,
  `MutedPlayerId` int(11) NOT NULL,
  `MutedByPlayerId` int(11) NOT NULL,
  `modifiedby` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `amx_mutes_modified`
--

CREATE TABLE `amx_mutes_modified` (
  `bid` int(11) NOT NULL,
  `UserId` int(11) NOT NULL,
  `mute_reason` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `ModifiedAt` int(11) NOT NULL,
  `id` int(11) NOT NULL,
  `mute_length` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `amx_scans`
--

CREATE TABLE `amx_scans` (
  `player_id` varchar(33) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `admin_id` varchar(33) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `admin_name` varchar(33) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `player_name` varchar(33) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `time` int(11) NOT NULL,
  `id` int(11) NOT NULL,
  `judgetid` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `amx_shadowban`
--

CREATE TABLE `amx_shadowban` (
  `id` int(11) NOT NULL,
  `Steamid` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `WeakHitPresent` float NOT NULL,
  `LagPresent` float NOT NULL,
  `LagSpike` float NOT NULL,
  `BulletPlierPresent` float NOT NULL,
  `doPunish` tinyint(1) NOT NULL,
  `isBigHitbox` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `buy_datas`
--

CREATE TABLE `buy_datas` (
  `buyname` varchar(33) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `buycost` int(11) NOT NULL,
  `buytime` timestamp NOT NULL DEFAULT current_timestamp(),
  `aid` int(11) NOT NULL,
  `id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `case_datas`
--

CREATE TABLE `case_datas` (
  `aid` int(11) NOT NULL,
  `Case0` int(11) NOT NULL,
  `Case1` int(11) NOT NULL,
  `Case2` int(11) NOT NULL,
  `Case3` int(11) NOT NULL,
  `Case4` int(11) NOT NULL,
  `Case5` int(11) NOT NULL,
  `Case6` int(11) NOT NULL,
  `Case7` int(11) NOT NULL,
  `Key0` int(11) NOT NULL,
  `Key1` int(11) NOT NULL,
  `Key2` int(11) NOT NULL,
  `Key3` int(11) NOT NULL,
  `Key4` int(11) NOT NULL,
  `Key5` int(11) NOT NULL,
  `Key6` int(11) NOT NULL,
  `Key7` int(11) NOT NULL,
  `id` int(11) NOT NULL,
  `Param` int(11) NOT NULL,
  `Case8` int(11) NOT NULL,
  `Case9` int(11) NOT NULL,
  `Case10` int(11) NOT NULL,
  `Case11` int(11) NOT NULL,
  `Case12` int(11) NOT NULL,
  `Case13` int(11) NOT NULL,
  `Case14` int(11) NOT NULL,
  `Case15` int(11) NOT NULL,
  `Case16` int(11) NOT NULL,
  `Case17` int(11) NOT NULL,
  `Case18` int(11) NOT NULL,
  `Case19` int(11) NOT NULL,
  `Case20` int(11) NOT NULL,
  `Case21` int(11) NOT NULL,
  `Case22` int(11) NOT NULL,
  `Case23` int(11) NOT NULL,
  `Case24` int(11) NOT NULL,
  `Case25` int(11) NOT NULL,
  `Case26` int(11) NOT NULL,
  `Case27` int(11) NOT NULL,
  `Key8` int(11) NOT NULL,
  `Key9` int(11) NOT NULL,
  `Key10` int(11) NOT NULL,
  `Key11` int(11) NOT NULL,
  `Key12` int(11) NOT NULL,
  `Key13` int(11) NOT NULL,
  `Key14` int(11) NOT NULL,
  `Key15` int(11) NOT NULL,
  `Key16` int(11) NOT NULL,
  `Key17` int(11) NOT NULL,
  `Key18` int(11) NOT NULL,
  `Key19` int(11) NOT NULL,
  `Key20` int(11) NOT NULL,
  `Key21` int(11) NOT NULL,
  `Key22` int(11) NOT NULL,
  `Key23` int(11) NOT NULL,
  `Key24` int(11) NOT NULL,
  `Key25` int(11) NOT NULL,
  `Key26` int(11) NOT NULL,
  `Key27` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `dalily_jackpot`
--

CREATE TABLE `dalily_jackpot` (
  `id` int(11) NOT NULL,
  `accountid` int(11) NOT NULL,
  `name` varchar(33) NOT NULL,
  `time` int(11) NOT NULL,
  `number` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `dalily_jackpot_winners`
--

CREATE TABLE `dalily_jackpot_winners` (
  `id` int(11) NOT NULL,
  `accountid` int(11) NOT NULL,
  `name` varchar(33) NOT NULL,
  `number` int(11) NOT NULL,
  `prize` float NOT NULL,
  `time` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `daliy_draws`
--

CREATE TABLE `daliy_draws` (
  `id` int(11) NOT NULL,
  `accountid` int(11) NOT NULL,
  `name` varchar(33) NOT NULL,
  `time` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `daliy_draws_winners`
--

CREATE TABLE `daliy_draws_winners` (
  `id` int(11) NOT NULL,
  `accountid` int(11) NOT NULL,
  `name` varchar(33) NOT NULL,
  `prize` float NOT NULL,
  `time` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `datas`
--

CREATE TABLE `datas` (
  `aid` int(11) NOT NULL,
  `Dollar` double NOT NULL,
  `GepeszKesztyu` int(11) NOT NULL,
  `NametagTool` int(11) NOT NULL,
  `StatTrakTool` int(11) NOT NULL,
  `ScreenEffect` int(11) NOT NULL,
  `Ajandekcsomag` int(11) NOT NULL,
  `Toredek` int(11) NOT NULL,
  `Skins` int(13) NOT NULL DEFAULT 1,
  `FirstJoin` int(11) NOT NULL DEFAULT 1,
  `Hud` int(11) NOT NULL,
  `OldStyleWeaponMenu` int(11) NOT NULL,
  `ReviveSprite` int(11) NOT NULL,
  `RecoilControl` int(11) NOT NULL,
  `WeaponHud` int(11) NOT NULL,
  `QuakeS` int(11) NOT NULL,
  `SpecL` int(11) NOT NULL,
  `Tolvajkesztyu` int(11) NOT NULL,
  `TolvajkesztyuEndTime` int(11) NOT NULL,
  `DisplayAdmin` int(11) NOT NULL DEFAULT 1,
  `ChatPrefixRemove` int(11) NOT NULL,
  `ChatPrefixAdded` int(11) NOT NULL,
  `ChatPrefix` varchar(33) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `thKeszlet` int(11) NOT NULL,
  `VipTime` int(11) NOT NULL DEFAULT 0,
  `Kills` int(11) NOT NULL,
  `Death` int(11) NOT NULL,
  `HS` int(11) NOT NULL,
  `Rang` int(11) NOT NULL,
  `SpinTime` int(11) NOT NULL,
  `AdminSpinTime` int(11) NOT NULL,
  `p_1` int(11) NOT NULL,
  `p_2` int(11) NOT NULL,
  `p_3` int(11) NOT NULL,
  `p_4` int(11) NOT NULL,
  `p_5` int(11) NOT NULL,
  `p_tus` int(11) NOT NULL,
  `p_markolat` int(11) NOT NULL,
  `p_tar` int(11) NOT NULL,
  `id` int(11) NOT NULL,
  `EXP` double NOT NULL,
  `ELO` int(11) NOT NULL,
  `WinnedRound` int(11) NOT NULL,
  `PrivateRank` int(11) NOT NULL,
  `BattlePassPurch` int(11) NOT NULL,
  `BattlePassLevel` int(11) NOT NULL,
  `SelectedMedal` int(11) NOT NULL,
  `Inventory_Size` int(11) NOT NULL DEFAULT 36,
  `iRew0` int(11) NOT NULL,
  `iRew1` int(11) NOT NULL,
  `iRew2` int(11) NOT NULL,
  `iRew3` int(11) NOT NULL,
  `iRew4` int(11) NOT NULL,
  `iRew5` int(11) NOT NULL,
  `iRew6` int(11) NOT NULL,
  `iRew7` int(11) NOT NULL,
  `iRew8` int(11) NOT NULL,
  `iRew9` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `datas_beta`
--

CREATE TABLE `datas_beta` (
  `aid` int(11) NOT NULL,
  `Dollar` double NOT NULL,
  `GepeszKesztyu` int(11) NOT NULL,
  `NametagTool` int(11) NOT NULL,
  `StatTrakTool` int(11) NOT NULL,
  `ScreenEffect` int(11) NOT NULL,
  `Ajandekcsomag` int(11) NOT NULL,
  `Toredek` int(11) NOT NULL,
  `Skins` int(13) NOT NULL DEFAULT 1,
  `FirstJoin` int(11) NOT NULL DEFAULT 1,
  `Hud` int(11) NOT NULL,
  `OldStyleWeaponMenu` int(11) NOT NULL,
  `ReviveSprite` int(11) NOT NULL,
  `RecoilControl` int(11) NOT NULL,
  `WeaponHud` int(11) NOT NULL,
  `QuakeS` int(11) NOT NULL,
  `SpecL` int(11) NOT NULL,
  `Tolvajkesztyu` int(11) NOT NULL,
  `TolvajkesztyuEndTime` int(11) NOT NULL,
  `DisplayAdmin` int(11) NOT NULL DEFAULT 1,
  `ChatPrefixRemove` int(11) NOT NULL,
  `ChatPrefixAdded` int(11) NOT NULL,
  `ChatPrefix` varchar(33) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `thKeszlet` int(11) NOT NULL,
  `VipTime` int(11) NOT NULL DEFAULT 0,
  `Kills` int(11) NOT NULL,
  `Death` int(11) NOT NULL,
  `HS` int(11) NOT NULL,
  `Rang` int(11) NOT NULL,
  `SpinTime` int(11) NOT NULL,
  `AdminSpinTime` int(11) NOT NULL,
  `p_1` int(11) NOT NULL,
  `p_2` int(11) NOT NULL,
  `p_3` int(11) NOT NULL,
  `p_4` int(11) NOT NULL,
  `p_5` int(11) NOT NULL,
  `p_tus` int(11) NOT NULL,
  `p_markolat` int(11) NOT NULL,
  `p_tar` int(11) NOT NULL,
  `id` int(11) NOT NULL,
  `EXP` double NOT NULL,
  `ELO` int(11) NOT NULL,
  `WinnedRound` int(11) NOT NULL,
  `PrivateRank` int(11) NOT NULL,
  `BattlePassPurch` int(11) NOT NULL,
  `BattlePassLevel` int(11) NOT NULL,
  `SelectedMedal` int(11) NOT NULL,
  `Inventory_Size` int(11) NOT NULL DEFAULT 25,
  `iRew0` int(11) NOT NULL,
  `iRew1` int(11) NOT NULL,
  `iRew2` int(11) NOT NULL,
  `iRew3` int(11) NOT NULL,
  `iRew4` int(11) NOT NULL,
  `iRew5` int(11) NOT NULL,
  `iRew6` int(11) NOT NULL,
  `iRew7` int(11) NOT NULL,
  `iRew8` int(11) NOT NULL,
  `iRew9` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `devmedals`
--

CREATE TABLE `devmedals` (
  `accountid` int(11) NOT NULL,
  `connecttime` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `herboy_reglogin_log`
--

CREATE TABLE `herboy_reglogin_log` (
  `id` int(11) NOT NULL,
  `userid` int(11) NOT NULL,
  `name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `steamid` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `ipaddress` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `datetime` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `AutoLogined` int(11) NOT NULL,
  `username` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `LoginKey` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `LoggedServer` int(11) NOT NULL DEFAULT 3,
  `failed` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `herboy_regsystem`
--

CREATE TABLE `herboy_regsystem` (
  `id` int(11) NOT NULL,
  `Username` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `Password` varchar(513) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `Email` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `LastLoginID` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `LastLoginIP` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `LoginKey` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `LastLoginName` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `RegisterName` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `RegisterIP` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `RegisterID` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `RegisterDate` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `plang` tinyint(4) NOT NULL DEFAULT 0,
  `Active` int(11) DEFAULT 0,
  `PremiumPoint` int(11) NOT NULL DEFAULT 0,
  `LastLoginDate` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `PlayTime` int(11) DEFAULT 0,
  `AdminLvL1` int(11) DEFAULT 0 COMMENT 'HERBOY WEB',
  `AdminLvL2` int(11) NOT NULL DEFAULT 0,
  `LastLoggedOn` int(11) NOT NULL,
  `uac_banned` int(11) DEFAULT 0,
  `uac_bannedby` varchar(33) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `uac_elapse` varchar(33) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `uac_started` varchar(33) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `uac_reason` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Eseményindítók `herboy_regsystem`
--
DELIMITER $$
CREATE TRIGGER `T` BEFORE INSERT ON `herboy_regsystem` FOR EACH ROW set GLOBAL sql_mode='NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION'
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `inventory`
--

CREATE TABLE `inventory` (
  `sqlid` int(11) NOT NULL,
  `w_id` int(11) NOT NULL,
  `w_userid` int(11) NOT NULL,
  `IsStatTraked` int(11) NOT NULL,
  `StatTrakKills` int(11) NOT NULL,
  `IsNameTaged` int(11) NOT NULL,
  `Nametag` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `Allapot` int(11) NOT NULL,
  `tradable` int(11) NOT NULL,
  `Equiped` int(11) NOT NULL,
  `opened` int(11) NOT NULL,
  `openedfrom` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `openedBy` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `openedById` int(11) NOT NULL,
  `firecount` int(11) NOT NULL,
  `is_new` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `kuldetes_new`
--

CREATE TABLE `kuldetes_new` (
  `aid` int(11) NOT NULL,
  `PlayerName` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `is_Questing` int(11) NOT NULL,
  `Rare` int(11) NOT NULL,
  `Kills` int(11) NOT NULL,
  `ReqKill` int(11) NOT NULL,
  `is_head` int(11) NOT NULL,
  `Weapon` int(11) NOT NULL,
  `DollarReward` double NOT NULL,
  `SkipDollar` double NOT NULL,
  `NametagReward` int(11) NOT NULL,
  `StatTrakReward` int(11) NOT NULL,
  `LadaTipus` int(11) NOT NULL,
  `KulcsTipus` int(11) NOT NULL,
  `KulcsDarab` int(11) NOT NULL,
  `LadaDarab` int(11) NOT NULL,
  `id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `market`
--

CREATE TABLE `market` (
  `m_sqlid` int(11) NOT NULL,
  `m_SellerName` varchar(33) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `m_Case` int(11) NOT NULL,
  `m_Key` int(11) NOT NULL,
  `m_wid` int(11) NOT NULL,
  `m_userid` int(11) NOT NULL,
  `m_isStatTraked` int(11) NOT NULL,
  `m_StatTrakKills` int(11) NOT NULL,
  `m_isNameTaged` int(11) NOT NULL,
  `m_Nametag` varchar(33) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `m_Allapot` int(11) NOT NULL,
  `m_opened` int(11) NOT NULL,
  `m_expire` int(11) NOT NULL,
  `m_cost` int(11) NOT NULL,
  `m_Type` int(11) NOT NULL,
  `m_oldsqlid` int(11) NOT NULL,
  `openedfrom` varchar(33) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `openedBy` varchar(33) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `openedById` int(11) NOT NULL,
  `firecount` int(11) NOT NULL,
  `m_darab` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `paypal_payments`
--

CREATE TABLE `paypal_payments` (
  `id` int(11) NOT NULL,
  `buyerName` varchar(255) DEFAULT NULL,
  `userId` int(11) NOT NULL,
  `points` int(11) DEFAULT NULL,
  `price` decimal(10,2) DEFAULT NULL,
  `orderDate` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `private_messages`
--

CREATE TABLE `private_messages` (
  `id` int(11) NOT NULL,
  `sender_name` varchar(32) DEFAULT 'N/A',
  `sender_steamid` varchar(24) DEFAULT 'N/A',
  `sender_ip` varchar(22) DEFAULT 'N/A',
  `receiver_name` varchar(32) DEFAULT 'N/A',
  `receiver_steamid` varchar(24) DEFAULT 'N/A',
  `receiver_ip` varchar(22) DEFAULT 'N/A',
  `message` varchar(140) DEFAULT 'N/A',
  `date` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `profile_comments`
--

CREATE TABLE `profile_comments` (
  `id` int(11) NOT NULL,
  `author` varchar(255) NOT NULL,
  `aboutUser` varchar(255) NOT NULL,
  `userid` int(11) NOT NULL,
  `comment` text NOT NULL,
  `date` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `smod_wss`
--

CREATE TABLE `smod_wss` (
  `aid` int(11) NOT NULL,
  `iKills` int(11) NOT NULL,
  `iDeaths` int(11) NOT NULL,
  `iHS` int(11) NOT NULL,
  `iSkins` int(11) NOT NULL DEFAULT 1,
  `iPoints` int(11) NOT NULL,
  `iKredits` int(11) NOT NULL,
  `iSelectedPack` int(11) NOT NULL,
  `isScreenEffect` int(11) NOT NULL DEFAULT 1,
  `iHud` int(11) NOT NULL DEFAULT 1,
  `iRoundSound` int(11) NOT NULL DEFAULT 1,
  `isInkognitoed` int(11) NOT NULL DEFAULT 1,
  `id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `webaccountdata`
--

CREATE TABLE `webaccountdata` (
  `Userid` int(11) NOT NULL,
  `AvatarLink` text NOT NULL,
  `Avatar64` text NOT NULL,
  `Background` text NOT NULL,
  `IsBGAnimated` int(1) NOT NULL,
  `SteamPlaytime` int(32) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `webcookieagreedlog`
--

CREATE TABLE `webcookieagreedlog` (
  `AgreeToken` varchar(60) NOT NULL,
  `UserId` int(11) NOT NULL,
  `IP` varchar(32) NOT NULL,
  `id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `webcrasher`
--

CREATE TABLE `webcrasher` (
  `id` int(11) NOT NULL,
  `steamid` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `weblogincookielog`
--

CREATE TABLE `weblogincookielog` (
  `wlc_id` int(11) NOT NULL,
  `LoginToken` varchar(32) NOT NULL,
  `UserId` int(11) NOT NULL,
  `IP` varchar(64) NOT NULL,
  `Created` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `webloginfailed`
--

CREATE TABLE `webloginfailed` (
  `id` int(11) NOT NULL,
  `ip` varchar(64) NOT NULL,
  `username` varchar(32) NOT NULL,
  `time` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `webloginlog`
--

CREATE TABLE `webloginlog` (
  `wl_id` int(11) NOT NULL,
  `UserId` int(11) NOT NULL,
  `LoginToken` varchar(32) NOT NULL,
  `AgreeToken` varchar(32) NOT NULL,
  `IP` varchar(64) NOT NULL,
  `Created` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `weblogintoken`
--

CREATE TABLE `weblogintoken` (
  `id` int(11) NOT NULL,
  `Token` varchar(33) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `UserId` int(11) NOT NULL DEFAULT 0,
  `steamid64` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '0',
  `Created` timestamp NOT NULL DEFAULT current_timestamp(),
  `Expire` int(11) NOT NULL DEFAULT 0,
  `Logout` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `webplayercount`
--

CREATE TABLE `webplayercount` (
  `id` int(11) NOT NULL,
  `playercount` int(11) NOT NULL,
  `time` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `webpwrst`
--

CREATE TABLE `webpwrst` (
  `id` int(11) NOT NULL,
  `username` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `email` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `token` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `used` tinyint(1) NOT NULL DEFAULT 0,
  `used_time` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `crated_time` timestamp NOT NULL DEFAULT current_timestamp(),
  `ip_crated` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `ip_used` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `webscanscrap`
--

CREATE TABLE `webscanscrap` (
  `id` int(11) NOT NULL,
  `sn` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `nick` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `ip` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `report` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `timestamp` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `detection_before` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `unique_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `render` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `cs_opened_at` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `wcd_timestamp` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `system_timestamp` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `server_timestamp` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `last_server_ip` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `operating_system` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `scraped` tinyint(1) DEFAULT 0,
  `printed` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `web_skinvotes`
--

CREATE TABLE `web_skinvotes` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `image_id` int(11) NOT NULL,
  `vote_score` int(11) DEFAULT NULL CHECK (`vote_score` between 1 and 10),
  `voted_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `y_smv6_itemlog`
--

CREATE TABLE `y_smv6_itemlog` (
  `AccountID` int(11) NOT NULL,
  `SendToAccountID` int(11) NOT NULL,
  `ActionText` varchar(500) NOT NULL,
  `Cost` varchar(30) NOT NULL,
  `Action` varchar(500) NOT NULL,
  `id` int(11) NOT NULL,
  `InsertTime` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `_recoil_vote`
--

CREATE TABLE `_recoil_vote` (
  `steamid` varchar(32) NOT NULL,
  `recoil_enabled` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `__syn_payments`
--

CREATE TABLE `__syn_payments` (
  `id` int(10) UNSIGNED NOT NULL COMMENT 'Sorszám (elsődleges kulcs)',
  `paymethodid` int(11) DEFAULT NULL COMMENT 'Fizetési mód (0: Pont egyenleg, 1: Pénztári befizetés, 2: Átutalás, 3: Emelt díjas SMS, 7: Emelt díjas hívás (IVR), 4: Rózsaszín csekk, 5: PayPal/Bankkártya, 10: Sikertelen)',
  `amount` int(11) DEFAULT NULL COMMENT 'Jóváírt összeg (pont)',
  `comment` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `smsid` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT 'SMS fizetés ID-je',
  `smssendernum` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT 'SMS fizetés küldő telefonszáma',
  `created` timestamp NOT NULL DEFAULT current_timestamp() COMMENT 'Létrehozás időpontja',
  `Active` int(11) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Indexek a kiírt táblákhoz
--

--
-- A tábla indexei `amx_activity`
--
ALTER TABLE `amx_activity`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_steam_id` (`steamid`),
  ADD KEY `idx_time` (`time`),
  ADD KEY `idx_steam_time` (`steamid`,`time`);

--
-- A tábla indexei `amx_alias`
--
ALTER TABLE `amx_alias`
  ADD UNIQUE KEY `hash` (`hash`);

--
-- A tábla indexei `amx_bans`
--
ALTER TABLE `amx_bans`
  ADD PRIMARY KEY (`bid`),
  ADD KEY `idx_player_ip` (`player_ip`),
  ADD KEY `idx_player_id` (`player_id`),
  ADD KEY `idx_admin_id` (`admin_id`),
  ADD KEY `idx_ban_created` (`ban_created`),
  ADD KEY `idx_unban_uuid` (`unban_uuid`),
  ADD KEY `idx_player_ban` (`player_id`,`ban_created`),
  ADD KEY `idx_admin_ip` (`admin_ip`);

--
-- A tábla indexei `amx_bans_modified`
--
ALTER TABLE `amx_bans_modified`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `amx_drawprizetime`
--
ALTER TABLE `amx_drawprizetime`
  ADD PRIMARY KEY (`steamid`);

--
-- A tábla indexei `amx_kick`
--
ALTER TABLE `amx_kick`
  ADD PRIMARY KEY (`kid`),
  ADD KEY `player_id` (`player_id`),
  ADD KEY `idx_player_ip` (`player_ip`),
  ADD KEY `idx_admin_id` (`admin_id`),
  ADD KEY `idx_kick_created` (`kick_created`),
  ADD KEY `idx_player_kick` (`player_id`,`kick_created`);

--
-- A tábla indexei `amx_messages`
--
ALTER TABLE `amx_messages`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `amx_mutes`
--
ALTER TABLE `amx_mutes`
  ADD PRIMARY KEY (`bid`),
  ADD KEY `idx_player_ip` (`player_ip`),
  ADD KEY `idx_player_id` (`player_id`),
  ADD KEY `idx_admin_id` (`admin_id`),
  ADD KEY `idx_admin_ip` (`admin_ip`),
  ADD KEY `idx_mute_created` (`mute_created`),
  ADD KEY `idx_player_mute` (`player_id`,`mute_created`);

--
-- A tábla indexei `amx_mutes_modified`
--
ALTER TABLE `amx_mutes_modified`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `amx_scans`
--
ALTER TABLE `amx_scans`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_player_id` (`player_id`),
  ADD KEY `idx_admin_id` (`admin_id`),
  ADD KEY `idx_player_name` (`player_name`),
  ADD KEY `idx_admin_name` (`admin_name`);

--
-- A tábla indexei `amx_shadowban`
--
ALTER TABLE `amx_shadowban`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `buy_datas`
--
ALTER TABLE `buy_datas`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `case_datas`
--
ALTER TABLE `case_datas`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `dalily_jackpot`
--
ALTER TABLE `dalily_jackpot`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `dalily_jackpot_winners`
--
ALTER TABLE `dalily_jackpot_winners`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `daliy_draws`
--
ALTER TABLE `daliy_draws`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `daliy_draws_winners`
--
ALTER TABLE `daliy_draws_winners`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `datas`
--
ALTER TABLE `datas`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `datas_beta`
--
ALTER TABLE `datas_beta`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `devmedals`
--
ALTER TABLE `devmedals`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `herboy_reglogin_log`
--
ALTER TABLE `herboy_reglogin_log`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `herboy_regsystem`
--
ALTER TABLE `herboy_regsystem`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_lastloginid_uac` (`LastLoginID`,`uac_banned`),
  ADD KEY `idx_last_login_id` (`LastLoginID`),
  ADD KEY `idx_admin_level` (`AdminLvL1`),
  ADD KEY `idx_admin_level_last_login` (`AdminLvL1`,`LastLoginID`);

--
-- A tábla indexei `inventory`
--
ALTER TABLE `inventory`
  ADD PRIMARY KEY (`sqlid`);

--
-- A tábla indexei `kuldetes_new`
--
ALTER TABLE `kuldetes_new`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `market`
--
ALTER TABLE `market`
  ADD PRIMARY KEY (`m_sqlid`);

--
-- A tábla indexei `paypal_payments`
--
ALTER TABLE `paypal_payments`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `private_messages`
--
ALTER TABLE `private_messages`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `profile_comments`
--
ALTER TABLE `profile_comments`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `smod_wss`
--
ALTER TABLE `smod_wss`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `webaccountdata`
--
ALTER TABLE `webaccountdata`
  ADD UNIQUE KEY `Userid` (`Userid`);

--
-- A tábla indexei `webcookieagreedlog`
--
ALTER TABLE `webcookieagreedlog`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `webcrasher`
--
ALTER TABLE `webcrasher`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `weblogincookielog`
--
ALTER TABLE `weblogincookielog`
  ADD PRIMARY KEY (`wlc_id`);

--
-- A tábla indexei `webloginfailed`
--
ALTER TABLE `webloginfailed`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `webloginlog`
--
ALTER TABLE `webloginlog`
  ADD PRIMARY KEY (`wl_id`);

--
-- A tábla indexei `weblogintoken`
--
ALTER TABLE `weblogintoken`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `LoginToken` (`Token`);

--
-- A tábla indexei `webplayercount`
--
ALTER TABLE `webplayercount`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `webpwrst`
--
ALTER TABLE `webpwrst`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `webscanscrap`
--
ALTER TABLE `webscanscrap`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `web_skinvotes`
--
ALTER TABLE `web_skinvotes`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_vote` (`user_id`,`image_id`);

--
-- A tábla indexei `y_smv6_itemlog`
--
ALTER TABLE `y_smv6_itemlog`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `_recoil_vote`
--
ALTER TABLE `_recoil_vote`
  ADD PRIMARY KEY (`steamid`),
  ADD UNIQUE KEY `steamid` (`steamid`);

--
-- A tábla indexei `__syn_payments`
--
ALTER TABLE `__syn_payments`
  ADD PRIMARY KEY (`id`);

--
-- A kiírt táblák AUTO_INCREMENT értéke
--

--
-- AUTO_INCREMENT a táblához `amx_activity`
--
ALTER TABLE `amx_activity`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `amx_bans`
--
ALTER TABLE `amx_bans`
  MODIFY `bid` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `amx_bans_modified`
--
ALTER TABLE `amx_bans_modified`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `amx_kick`
--
ALTER TABLE `amx_kick`
  MODIFY `kid` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `amx_messages`
--
ALTER TABLE `amx_messages`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `amx_mutes`
--
ALTER TABLE `amx_mutes`
  MODIFY `bid` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `amx_mutes_modified`
--
ALTER TABLE `amx_mutes_modified`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `amx_scans`
--
ALTER TABLE `amx_scans`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `amx_shadowban`
--
ALTER TABLE `amx_shadowban`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `buy_datas`
--
ALTER TABLE `buy_datas`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `case_datas`
--
ALTER TABLE `case_datas`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `dalily_jackpot`
--
ALTER TABLE `dalily_jackpot`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `dalily_jackpot_winners`
--
ALTER TABLE `dalily_jackpot_winners`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `daliy_draws`
--
ALTER TABLE `daliy_draws`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `daliy_draws_winners`
--
ALTER TABLE `daliy_draws_winners`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `datas`
--
ALTER TABLE `datas`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `datas_beta`
--
ALTER TABLE `datas_beta`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `devmedals`
--
ALTER TABLE `devmedals`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `herboy_reglogin_log`
--
ALTER TABLE `herboy_reglogin_log`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `herboy_regsystem`
--
ALTER TABLE `herboy_regsystem`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `inventory`
--
ALTER TABLE `inventory`
  MODIFY `sqlid` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `kuldetes_new`
--
ALTER TABLE `kuldetes_new`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `market`
--
ALTER TABLE `market`
  MODIFY `m_sqlid` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `paypal_payments`
--
ALTER TABLE `paypal_payments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `private_messages`
--
ALTER TABLE `private_messages`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `profile_comments`
--
ALTER TABLE `profile_comments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `smod_wss`
--
ALTER TABLE `smod_wss`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `webcookieagreedlog`
--
ALTER TABLE `webcookieagreedlog`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `webcrasher`
--
ALTER TABLE `webcrasher`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `weblogincookielog`
--
ALTER TABLE `weblogincookielog`
  MODIFY `wlc_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `webloginfailed`
--
ALTER TABLE `webloginfailed`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `webloginlog`
--
ALTER TABLE `webloginlog`
  MODIFY `wl_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `weblogintoken`
--
ALTER TABLE `weblogintoken`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `webplayercount`
--
ALTER TABLE `webplayercount`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `webpwrst`
--
ALTER TABLE `webpwrst`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `web_skinvotes`
--
ALTER TABLE `web_skinvotes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `y_smv6_itemlog`
--
ALTER TABLE `y_smv6_itemlog`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `__syn_payments`
--
ALTER TABLE `__syn_payments`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Sorszám (elsődleges kulcs)';
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
