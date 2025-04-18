<?php
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/Config.php");
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/includes/Utils.php");

header('Access-Control-Allow-Credentials: true');

if(!isset($_COOKIE[Config::$cookie_AgreeCookie_name]))
    Utils::remCookie(Config::$cookie_AgreeCookie_name);
    Utils::setCookie(Config::$cookie_AgreeCookie_name, Utils::uuid_str());