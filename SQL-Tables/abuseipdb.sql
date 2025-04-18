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
-- Adatbázis: `abuseipdb`
--

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `abuseipdb_logs`
--

CREATE TABLE `abuseipdb_logs` (
  `id` int(11) NOT NULL,
  `ip` varchar(45) NOT NULL,
  `abuse_confidence_score` int(11) NOT NULL,
  `country_code` varchar(2) DEFAULT NULL,
  `is_whitelisted` tinyint(1) DEFAULT NULL,
  `last_reported_at` datetime DEFAULT NULL,
  `total_reports` int(11) DEFAULT NULL,
  `usage_type` varchar(50) DEFAULT NULL,
  `isp` varchar(100) DEFAULT NULL,
  `domain` varchar(100) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `blocked_ips`
--

CREATE TABLE `blocked_ips` (
  `id` int(11) NOT NULL,
  `ip` varchar(45) NOT NULL,
  `block_date` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Indexek a kiírt táblákhoz
--

--
-- A tábla indexei `abuseipdb_logs`
--
ALTER TABLE `abuseipdb_logs`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `blocked_ips`
--
ALTER TABLE `blocked_ips`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `ip` (`ip`),
  ADD KEY `idx_block_date` (`block_date`);

--
-- A kiírt táblák AUTO_INCREMENT értéke
--

--
-- AUTO_INCREMENT a táblához `abuseipdb_logs`
--
ALTER TABLE `abuseipdb_logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `blocked_ips`
--
ALTER TABLE `blocked_ips`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
