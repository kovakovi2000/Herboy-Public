<?php

global $lang;
if(!Account::isLogined())
    Utils::redirect("index");

Account::Logout();

function func_addstyle()
{
    ?>
    <link rel="stylesheet" type="text/css" href="css/login.css">
    <?php
}

function func_dialog()
{global $lang;
    Utils::dialog($lang['Logout']);
}

Utils::header($lang['menu_logout'], "func_addstyle");
Utils::body("func_dialog", false);
Utils::footer();