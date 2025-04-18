<?php
include_once $_SERVER['DOCUMENT_ROOT'] . '/configs/lang/switch.php';
function func_mainpage()
{   global $lang;
    $total_mutes = 0;
    ?>
    <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
    </head>

    <body>
        <div class="modern-card-container">
            <div class="modern-card">
                <div class="modern-card-body">
                    <div class="page-header col-md-12" id="banner" style="border: none !important;">
                    <h1 ALIGN=center><b><h2 style="color: #d1d1d1;"><?php echo $lang['page_mutelist']; ?></h2></b></h1>
                        <table class="tg">
                        <style type="text/css">
                            .tg {
                                    border-collapse: collapse;
                                    margin: 20px auto;
                                    width: 100%;
                                    max-width: 800px;
                                    background-color: transparent;
                                    border-radius: 10px;
                                    box-shadow: 0px 0px 10px rgba(0, 0, 0, 0.1);
                                }
                                .tg td, .tg th {
                                    border: 1px solid #ddd;
                                    padding: 1px 15px;
                                    text-align: center;
                                }
                                /* tg-0lax osztály celláinak teljes eltüntetése */
                                .tg .tg-0lax {
                                    font-weight: bold;
                                    border: none; /* Nincs keret */
                                    background-color: transparent; /* Átlátszó háttér */
                                    font-size: initial;
                                    color: #d1d1d1; /* Csak a szöveg színe marad */
                                    padding: 1px;
                                }
                                select {
    color: #333; /* Change text color */
    background-color: #f9f9f9; /* Light background color */
 
}

/* Change the appearance when hovered or focused */
select:hover,
select:focus {
    border-color: #007BFF; /* Change border color on hover/focus */
    outline: none; /* Remove default focus outline */
}

                            </style>
                            <thead>
                                <tr>
                                <th id="mute_allnum" class="tg-0lax"><?php echo $lang['total_mutes']; ?>:</th>
                                <td id="mute_activenum" class="tg-0lax"><?php echo $lang['active_mutes']; ?>:</td>
                                <td id="mute_ubnum" class="tg-0lax"><?php echo $lang['unmuted']; ?>:</td>
                                </tr>
                            </thead>
                            <tbody>
                            </tbody>
                        </table>

                    <!-- Görgethető táblázat konténer -->
                    <div class="scrollable-table">
                        <table class="table zebra-stripes">
                            <thead>
                                <tr>
                                <th><?php echo $lang['mute_id']; ?></th>
                                <th><?php echo $lang['name']; ?></th>
                                <th><?php echo $lang['steamID']; ?></th>
                                <th><?php echo $lang['reason']; ?></th>
                                <th><?php echo $lang['timestamp']; ?></th>
                                <th><?php echo $lang['expiry']; ?></th>
                                <th><?php echo $lang['admin_name']; ?></th>
                                <th><?php echo $lang['status']; ?></th>
                                </tr>
                            </thead>
                            <tbody id="MuteTable">
                                <!-- Kitiltás lista -->
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

        <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
        <script src="<?php echo Utils::get_url('js/mutelist.js?v=2'); ?>"></script> 
    </body>
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

Utils::header("Némítás lista", "func_addstyle");
Utils::body("func_mainpage");
Utils::footer();
?>
