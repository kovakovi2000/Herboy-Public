<?php
$mysql_host = '127.0.0.1';
$mysql_user = 'webserver';
$mysql_pass = 'XHgSVR3tWDkmcnqJhfpAbu';

$pdo = new PDO("mysql:host=$mysql_host;dbname=bansys", $mysql_user, $mysql_pass);
$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

$pdoreg = new PDO("mysql:host=$mysql_host;dbname=s2_herboy", $mysql_user, $mysql_pass);
$pdoreg->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

$pdoban = new PDO("mysql:host=$mysql_host;dbname=s2_herboy", $mysql_user, $mysql_pass);
$pdoban->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
?>