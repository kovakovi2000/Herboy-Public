-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Gép: localhost
-- Létrehozás ideje: 2025. Ápr 17. 23:14
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
-- Adatbázis: `bansys`
--

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `account`
--

CREATE TABLE `account` (
  `id` int(11) NOT NULL,
  `username` varchar(32) NOT NULL,
  `password` char(64) NOT NULL,
  `token` char(64) NOT NULL,
  `useragent` text DEFAULT NULL,
  `register_time` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `amx_cookie`
--

CREATE TABLE `amx_cookie` (
  `hash` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `Steamid` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `ip` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `cookie` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `LastUpdate` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `amx_cookie_pair`
--

CREATE TABLE `amx_cookie_pair` (
  `id` char(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `UUID1` varchar(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `UUID2` varchar(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `pair_time` datetime NOT NULL,
  `matched_value` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `amx_cookie_v2`
--

CREATE TABLE `amx_cookie_v2` (
  `UUID` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `firstseen` datetime NOT NULL,
  `lastseen` datetime NOT NULL,
  `data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `steamid_indicators` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `ip_indicators` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Eseményindítók `amx_cookie_v2`
--
DELIMITER $$
CREATE TRIGGER `before_amx_cookie_v2_insert` BEFORE INSERT ON `amx_cookie_v2` FOR EACH ROW BEGIN
    DECLARE steamid_json TEXT;
    DECLARE ip_json TEXT;
    DECLARE steamid_element TEXT;
    DECLARE ip_element TEXT;
    DECLARE steamid_count INT DEFAULT 0;
    DECLARE ip_count INT DEFAULT 0;
    DECLARE idx INT DEFAULT 0;

    SET steamid_json = JSON_EXTRACT(NEW.data, '$.STEAMIDs');
    SET ip_json = JSON_EXTRACT(NEW.data, '$.IPs');

    SET steamid_count = JSON_LENGTH(steamid_json);
    SET ip_count = JSON_LENGTH(ip_json);

    SET NEW.steamid_indicators = '';
    SET NEW.ip_indicators = '';

    WHILE idx < steamid_count DO
        SET steamid_element = JSON_UNQUOTE(JSON_EXTRACT(steamid_json, CONCAT('$[', idx, '].indicator')));
        IF idx > 0 THEN
            SET NEW.steamid_indicators = CONCAT(NEW.steamid_indicators, ',', steamid_element);
        ELSE
            SET NEW.steamid_indicators = steamid_element;
        END IF;
        SET idx = idx + 1;
    END WHILE;

    SET idx = 0;

    WHILE idx < ip_count DO
        SET ip_element = JSON_UNQUOTE(JSON_EXTRACT(ip_json, CONCAT('$[', idx, '].indicator')));
        IF idx > 0 THEN
            SET NEW.ip_indicators = CONCAT(NEW.ip_indicators, ',', ip_element);
        ELSE
            SET NEW.ip_indicators = ip_element;
        END IF;
        SET idx = idx + 1;
    END WHILE;

END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_amx_cookie_v2_update` BEFORE UPDATE ON `amx_cookie_v2` FOR EACH ROW BEGIN
    DECLARE steamid_json TEXT;
    DECLARE ip_json TEXT;
    DECLARE steamid_element TEXT;
    DECLARE ip_element TEXT;
    DECLARE steamid_count INT DEFAULT 0;
    DECLARE ip_count INT DEFAULT 0;
    DECLARE idx INT DEFAULT 0;

    SET steamid_json = JSON_EXTRACT(NEW.data, '$.STEAMIDs');
    SET ip_json = JSON_EXTRACT(NEW.data, '$.IPs');

    SET steamid_count = JSON_LENGTH(steamid_json);
    SET ip_count = JSON_LENGTH(ip_json);

    SET NEW.steamid_indicators = '';
    SET NEW.ip_indicators = '';

    WHILE idx < steamid_count DO
        SET steamid_element = JSON_UNQUOTE(JSON_EXTRACT(steamid_json, CONCAT('$[', idx, '].indicator')));
        IF idx > 0 THEN
            SET NEW.steamid_indicators = CONCAT(NEW.steamid_indicators, ',', steamid_element);
        ELSE
            SET NEW.steamid_indicators = steamid_element;
        END IF;
        SET idx = idx + 1;
    END WHILE;

    SET idx = 0;

    WHILE idx < ip_count DO
        SET ip_element = JSON_UNQUOTE(JSON_EXTRACT(ip_json, CONCAT('$[', idx, '].indicator')));
        IF idx > 0 THEN
            SET NEW.ip_indicators = CONCAT(NEW.ip_indicators, ',', ip_element);
        ELSE
            SET NEW.ip_indicators = ip_element;
        END IF;
        SET idx = idx + 1;
    END WHILE;

END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `amx_whitelist_blacklist`
--

CREATE TABLE `amx_whitelist_blacklist` (
  `id` int(11) NOT NULL COMMENT 'asd',
  `indicator_type` enum('ip','steamid','ip_interval','asn','UUID','regex') CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `indicator_value` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `is_whitelist` tinyint(1) DEFAULT NULL,
  `excludes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `note` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `steam_bypass` tinyint(1) DEFAULT 0,
  `priority` int(11) DEFAULT NULL,
  `scope` enum('current','local','synced') CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT 'current',
  `start_time` datetime DEFAULT current_timestamp(),
  `expire_time` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `ip_data`
--

CREATE TABLE `ip_data` (
  `ip` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `check_date` datetime NOT NULL DEFAULT current_timestamp(),
  `is_proxy` tinyint(1) DEFAULT NULL,
  `is_vpn` tinyint(1) DEFAULT NULL,
  `is_datacenter` tinyint(1) DEFAULT NULL,
  `asn_asn` int(10) UNSIGNED DEFAULT NULL,
  `asn_route` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `asn_org` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `location_country_code` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `full_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`full_json`))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `loginlog`
--

CREATE TABLE `loginlog` (
  `id` int(11) NOT NULL,
  `username` varchar(32) NOT NULL,
  `token` char(64) DEFAULT NULL,
  `login_time` timestamp NOT NULL DEFAULT current_timestamp(),
  `login_type` enum('token','password') NOT NULL,
  `useragent` text DEFAULT NULL,
  `successful` tinyint(1) NOT NULL,
  `ip` varchar(45) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `regtoken`
--

CREATE TABLE `regtoken` (
  `token` char(100) NOT NULL,
  `username` varchar(32) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `search_history`
--

CREATE TABLE `search_history` (
  `id` int(11) NOT NULL,
  `username` varchar(32) NOT NULL,
  `indicator` varchar(255) NOT NULL,
  `type` varchar(255) NOT NULL,
  `manual` tinyint(1) NOT NULL DEFAULT 0,
  `search_time` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `version_restrict`
--

CREATE TABLE `version_restrict` (
  `steamid` varchar(32) NOT NULL,
  `type` enum('lower','equal','higher') NOT NULL,
  `version_build` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Indexek a kiírt táblákhoz
--

--
-- A tábla indexei `account`
--
ALTER TABLE `account`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`);

--
-- A tábla indexei `amx_cookie`
--
ALTER TABLE `amx_cookie`
  ADD PRIMARY KEY (`hash`);

--
-- A tábla indexei `amx_cookie_pair`
--
ALTER TABLE `amx_cookie_pair`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_uuid1` (`UUID1`),
  ADD KEY `idx_uuid2` (`UUID2`);

--
-- A tábla indexei `amx_cookie_v2`
--
ALTER TABLE `amx_cookie_v2`
  ADD PRIMARY KEY (`UUID`);

--
-- A tábla indexei `amx_whitelist_blacklist`
--
ALTER TABLE `amx_whitelist_blacklist`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_indicator` (`indicator_type`,`indicator_value`);

--
-- A tábla indexei `ip_data`
--
ALTER TABLE `ip_data`
  ADD PRIMARY KEY (`ip`);

--
-- A tábla indexei `loginlog`
--
ALTER TABLE `loginlog`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_successful` (`successful`),
  ADD KEY `idx_username` (`username`),
  ADD KEY `idx_ip` (`ip`);

--
-- A tábla indexei `regtoken`
--
ALTER TABLE `regtoken`
  ADD PRIMARY KEY (`token`);

--
-- A tábla indexei `search_history`
--
ALTER TABLE `search_history`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `version_restrict`
--
ALTER TABLE `version_restrict`
  ADD PRIMARY KEY (`steamid`);

--
-- A kiírt táblák AUTO_INCREMENT értéke
--

--
-- AUTO_INCREMENT a táblához `account`
--
ALTER TABLE `account`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `amx_whitelist_blacklist`
--
ALTER TABLE `amx_whitelist_blacklist`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'asd';

--
-- AUTO_INCREMENT a táblához `loginlog`
--
ALTER TABLE `loginlog`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `search_history`
--
ALTER TABLE `search_history`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
