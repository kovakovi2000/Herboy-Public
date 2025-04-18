<?php
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/includes/Utils.php");

$errstr = "Undefined variable \$unkown";
preg_match('/\$[0-9a-zA-Z:_-]*/', $errstr, $varible);

Utils::debug($varible);
?>