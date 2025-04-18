<?php
$cookiename = 'ddPbQyKsbmMdKNcZ';
$mysql_host = '127.0.0.1';
$mysql_user = 'webserver';
$mysql_pass = 'XHgSVR3tWDkmcnqJhfpAbu';
$mysql_dbdb = 'dev';
$skt_host = "37.221.209.129";

$auto_remove_install = true;
$log_cookie_check = true;

$sql = new mysqli($mysql_host, $mysql_user, $mysql_pass);
$sql->select_db($mysql_dbdb);
$connect = $sql;