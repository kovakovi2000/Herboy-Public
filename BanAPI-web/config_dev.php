<?php
$cookiename = 'ddPbQyKsbmMdKNcZ';
$mysql_host = '127.0.0.1';
$mysql_user = 'webserver';
$mysql_pass = 'XHgSVR3tWDkmcnqJhfpAbu';
$mysql_dbdb = 'dev';
$mysql_dbreg = 's2_herboy';
$mysql_dbban = 'bansys';
$skt_host = "127.0.0.1";

$auto_remove_install = true;
$log_cookie_check = true;

$sql = new mysqli($mysql_host, $mysql_user, $mysql_pass);
$sql->select_db($mysql_dbdb);
$connect = $sql;