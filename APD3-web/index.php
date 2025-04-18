<?php
ini_set('display_errors', '1');
ini_set('display_startup_errors', '1');
error_reporting(E_ALL);

if (session_status() === PHP_SESSION_NONE)
    session_start();

include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/includes/ErrorManager.php");
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/Config.php");
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/includes/Utils.php");
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/includes/Security.php");
include_once($_SERVER['DOCUMENT_ROOT'] . '/configs/lang/switch.php');
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/Perms.php");
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/Pages.php");
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/includes/UserProfile.php");
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/includes/Account.php");

ErrorManager::LogURL();

//FULLDEV
// if(!ErrorManager::isDevelpor()) {
//     include_once($_SERVER['DOCUMENT_ROOT'] . "/dev.php");
//     exit();
// }

global $pagelink;
if(isset($_GET['pagelink']))
{
    $query = strip_tags(filter_input(INPUT_GET, 'pagelink', FILTER_SANITIZE_FULL_SPECIAL_CHARS));
    if (strpos($query, '?') !== false) {
        $pathParts = explode('?', $query, 2);
        $query = $pathParts[0];
    }
    
    $path = explode("/", $query);
    $pagelink = isset($path) ? $path : array("index");
}
else
    $pagelink = array("index");

//$pagelink = isset($_GET['pagelink']) ? explode("/", strip_tags(filter_input(INPUT_GET, 'pagelink', FILTER_SANITIZE_FULL_SPECIAL_CHARS))) : array("index");

$showfile = $pagelink[0];
if(empty($showfile)) $showfile = "index";
if(file_exists($_SERVER['DOCUMENT_ROOT'] . "/pages/". $showfile . ".php"))
    include_once($_SERVER['DOCUMENT_ROOT'] . "/pages/". $showfile . ".php");
else
    Utils::html_error(404);

define('PROGRAM_EXECUTION_SUCCESSFUL', true);
