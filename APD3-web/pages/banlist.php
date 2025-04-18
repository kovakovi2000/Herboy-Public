<?php

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);
include_once $_SERVER['DOCUMENT_ROOT'] . '/configs/lang/switch.php';


function func_mainpage() {
    $total_bans = 0;
    global $lang;
    ?>
    <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
    </head>

    <body>
        <div class="modern-card-container">
            <div class="modern-card">
                <div class="modern-card-body">
                    <div class="page-header col-md-12" id="banner" style="border: none !important;">
                        <h1 ALIGN=center><b><h2 style="color: #d1d1d1;"><?php echo $lang['page_banlist']; ?></h2></b></h1>
                        <table class="tg">
                            <thead>
                                <tr>
                                    <th id ="ban_acnum" class="tg-0lax"><?php echo $lang['anticheat_ban']; ?></th>
                                    <th id ="ban_adnum" class="tg-0lax"><?php echo $lang['admin_ban']; ?></th>
                                    <th id ="ban_allnum" class="tg-0lax"><?php echo $lang['total_bans']; ?></th>
                                    <td id ="ban_activenum" class="tg-0lax"><?php echo $lang['active_bans']; ?></td>
                                    <td id ="ban_ubnum" class="tg-0lax"><?php echo $lang['unbanned']; ?></td>
                                </tr>
                            </thead>
                        </table>
                        <div class="scrollable-table">
                            <table class="table zebra-stripes">
                                <thead>
                                    <tr>
                                        <th><?php echo $lang['banID']; ?></th>
                                        <th><?php echo $lang['name']; ?></th>
                                        <th><?php echo $lang['steamID']; ?></th>
                                        <th><?php echo $lang['reason']; ?></th>
                                        <th><?php echo $lang['timestamp']; ?></th>
                                        <th><?php echo $lang['expiry']; ?></th>
                                        <th><?php echo $lang['admin_name']; ?></th>
                                        <th><?php echo $lang['status']; ?></th>
                                    </tr>
                                </thead>
                                <tbody id="BanTable">
                                    <!-- Kitiltás lista -->
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </body>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="<?php echo Utils::get_url('js/banlist.js?ver=11'); ?>"></script> 
    <?php
}



function func_addstyle()
{
    ?>
        <script type="text/javascript" src="//cdn.jsdelivr.net/npm/slick-carousel@1.8.1/slick/slick.min.js"></script>
        <link rel="stylesheet" type="text/css" href="//cdn.jsdelivr.net/npm/slick-carousel@1.8.1/slick/slick.css"/>
        <link rel="stylesheet" type="text/css" href="//cdn.jsdelivr.net/npm/slick-carousel@1.8.1/slick/slick-theme.css"/>
        <link rel="stylesheet" type="text/css" href="<?php echo Utils::get_url("css/table.css?ver=a123");?>"/>
        <link rel="stylesheet" type="text/css" href="<?php echo Utils::get_url('css/banlist.css?ver=a123');?>">
    <?php
}

Utils::header("Banlista", "func_addstyle");
Utils::body("func_mainpage");
Utils::footer();
?>