<?php
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/Config.php");
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/includes/Utils.php");
?>
<?php
function func_mainpage()
{
    ?>
            <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
    </head>
    <body>
<div class="d-flex justify-content-center">
    <div class="modern-card card-modify">
        <div class="modern-card-header">
            <h1>Weboldalt készítette Kova (Kovács Bence)</h1>
        </div>
        <div class="card-body">
            <p style="display: flex; justify-content: space-between;">
                <h4>
                    A weboldalt összességében főként <b>Zyx</b> fejezte be <b>Shedi</b> segítségével, és jelenleg is fejleszti. Én, Kova, a weboldal alapjait fektettem le, és a teljes egyedi keretrendszert én írtam meg, melyre később a többiek ráépítkeztek.
                </h4>
            </p>
            <h2>Külön köszönet:</h4>
            <p style="display: flex; justify-content: space-between;">
                <h2> - Zyx (Hamar Patrik)</h2>
                <h2> - Shedi (Csom Adrián)</h2>
                <h4> - Transcend v1.0 (colorlib.com)</h4>
                <h4> - Normalizer (github.com/necolas/normalize.css)</h4>
                <h4> - Metropolis Font (https://www.fontsquirrel.com/fonts/metropolis)</h4>
                <h4> - Domine Font (https://fonts.google.com/specimen/Domine)</h4>
                <h4> - Font Awesome (fontawesome.com)</h4>
                <h4> - Micons Free Icons (themeui.net/micons-231-icons)</h4>
                <h4> - Webfont (icomoon.io)</h4>
                <h4> - SteamAuthentication (github.com/SmItH197/SteamAuthentication)</h4>
                <h4> - SteamIDConverter (github.com/b3none/steam-id-converter)</h4>
                <h4> - Zászló képek (flagpedia.net)</h4>
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

