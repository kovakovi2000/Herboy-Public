<?php
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/Config.php");
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/includes/Utils.php");
?>
<?php
function func_mainpage()
{
    global $lang;
    ?>
    <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
    </head>
    <body>
    <div class="d-flex justify-content-center">
        <div class="modern-card card-modify">
            <div class="modern-card-header">
                <h3><?php echo $lang['website_name']; ?></br><?php echo $lang['terms_of_service']; ?></h3>
            </div>
            <div class="card-body">
            <h4><?php echo $lang['cookies_usage']; ?></h4>
            <p style="display: flex; justify-content: space-between;">
                <?php echo $lang['privacy_statement']; ?>
                <br>
                <?php echo $lang['cookie_info_part1']; ?>
                <br>
                <?php echo $lang['cookie_info_part2']; ?>
                <br>
                <?php echo $lang['cookie_info_part3']; ?>
                <br>
                <?php echo $lang['cookie_info_part4']; ?>
                <br>
                <?php echo $lang['cookie_info_part5']; ?>
                <br>
                <?php echo $lang['cookie_info_part6']; ?>
            </p>
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

Utils::header("Felhasználói feltételek", "func_addstyle");
Utils::body("func_mainpage");
Utils::footer();
?>

