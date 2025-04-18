<?php
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/Config.php");
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/includes/Utils.php");

function func_mainpage()
{   global $lang;
    ?>
    <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
    </head>
    <body>
    </body>
<?php
}

function func_addstyle()
{
    ?>
        <meta http-equiv="refresh" content="0; url=https://www.nextclient.ru/" />
    <?php
}

Utils::header($lang['menu_downloadcs'], "func_addstyle");
Utils::body("func_mainpage");
Utils::footer();