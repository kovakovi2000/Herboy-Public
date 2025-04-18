<?php


if(!ErrorManager::isDevelpor()) {
    include_once($_SERVER['DOCUMENT_ROOT'] . "/dev.php");
    exit();
}

include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/includes/Security.php");

