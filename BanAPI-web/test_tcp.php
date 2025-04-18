<?php
$g_server = 2;
switch ($g_server) {
    case 1:
        require_once("config_avatar.php"); 
        break;
    case 2:
        require_once("config_dev.php"); 
        break;
    case 3:
        require_once("config_herboy.php"); 
        break;
    case 4:
        require_once("config_sdev.php"); 
        break;
    default:
        print "dafack".$g_server;
}
require_once('_socket.php');
sck_set_server($skt_host,$skt_port);

$passargs = array("i", 1234, "s", "test_integrity");
$skres = sck_CallPawnFunc("EzSck.amxx", "testfunc", $passargs);
print $skres;
