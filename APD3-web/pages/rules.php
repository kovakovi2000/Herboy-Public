<?php
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/Config.php");
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/includes/Utils.php");
global $lang;
?>
<?php
function func_mainpage()
{   global $lang;
    ?>
        <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
    </head>
    <body>
    <div class="d-flex justify-content-center" style="width: 100%;">

    <div class="modern-card card-modify">
        <div class="modern-card-header">
            <h3><span style="color: #ff0000;"><center><?php echo $lang['server_rules']; ?></center></strong></h3>
        </div>
        <div class="modern-card-body">
		</div>
<h4><?php echo $lang['rule_hack_tools']; ?></h4>
<h4><?php echo $lang['rule_red_scan']; ?></h4>
<h4><?php echo $lang['rule_scan_refusal']; ?></h4>
<h4><?php echo $lang['rule_server_abuse']; ?></h4>
<h4><?php echo $lang['rule_admin_abuse']; ?></h4>
<h4><?php echo $lang['rule_parent_abuse']; ?></h4>
<h4><?php echo $lang['rule_excessive_cursing']; ?></h4>
<h4><?php echo $lang['rule_disruptive_activity']; ?></h4>
<h4><?php echo $lang['rule_mic_under_16']; ?></h4>
<h4><?php echo $lang['rule_racism']; ?></h4>
<h4><?php echo $lang['rule_ct_camp']; ?></h4>
<h4><?php echo $lang['rule_terrorist_delay']; ?></h4>
<h4><?php echo $lang['rule_exploitation']; ?></h4>
<h4><?php echo $lang['rule_advertising']; ?></h4>
<h4><?php echo $lang['rule_post_death_hints']; ?></h4>
<h4><?php echo $lang['rule_bullying']; ?></h4>
<h4><?php echo $lang['rule_community_disruption']; ?></h4>
<h4><?php echo $lang['rule_theft_fraud']; ?></h4>
<h4><?php echo $lang['rule_external_trades']; ?></h4>
<h4><?php echo $lang['rule_discord_misuse']; ?></h4>
<h4><?php echo $lang['rule_spray']; ?></h4>
<h4><?php echo $lang['rule_spray1']; ?></h4>
<br>
 
        </div>
    </div>
</div>
</body>
<?php
}


function func_addstyle()
{
    ?>
        <script type="text/javascript" src="//cdn.jsdelivr.net/npm/slick-carousel@1.8.1/slick/slick.min.js"></script>
        <link rel="stylesheet" type="text/css" href="//cdn.jsdelivr.net/npm/slick-carousel@1.8.1/slick/slick.css"/>
        <link rel="stylesheet" type="text/css" href="//cdn.jsdelivr.net/npm/slick-carousel@1.8.1/slick/slick-theme.css"/>

    <?php
}

Utils::header($lang['menu_rules'], "func_addstyle");
Utils::body("func_mainpage");
Utils::footer();
?>
