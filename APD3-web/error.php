<?php
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/includes/Utils.php");
$pageTitle = "ERROR";
$error_image = Utils::get_url();
header('X-Robots-Tag: noindex, nofollow');
if(isset($_GET['400']))
{
    $error_num = "400"; //HTTP_BAD_REQUEST
    $error_image .= "/images/gifs/free_candy.gif";
    $error_message = "Hibás kérelem... Cukorkát?";
}
elseif(isset($_GET['401']))
{
    $error_num = "401"; //HTTP_UNAUTHORIZED
    $error_image .= "/images/gifs/drinking.gif";
    $error_message = "Nincs megfelelő azonosításod!";
}
elseif(isset($_GET['403']))
{
    $error_num = "403"; //HTTP_FORBIDDEN
    $error_image .= "/images/gifs/board.gif";
    $error_message = "Ehhez nincs hozzáférésed!";
}
elseif(isset($_GET['404']))
{
    $error_num = "404"; //HTTP_NOT_FOUND
    $error_image .= "/images/gifs/crying.gif";
    $error_message = "Amit keresel nincs itt!";
}
elseif(isset($_GET['405']))
{
    $error_num = "405"; //HTTP_METHOD_NOT_ALLOWED
    $error_image .= "/images/gifs/terror.gif";
    $error_message = "Így nem szabad... A fekete mágia tiltott!";
}
elseif(isset($_GET['408']))
{
    $error_num = "408"; //HTTP_REQUEST_TIME_OUT
    $error_image .= "/images/gifs/study.gif";
    $error_message = "Túúúúl sok ideig nem válaszolt...";
}
elseif(isset($_GET['410']))
{
    $error_num = "410"; //HTTP_GONE
    $error_image .= "/images/gifs/chill.gif";
    $error_message = "Volt, nincs.";
}
elseif(isset($_GET['411']))
{
    $error_num = "411"; //HTTP_LENGTH_REQUIRED
    $error_image .= "/images/gifs/running.gif";
    $error_message = "Nincs hossz, nincs válasz!";
}
elseif(isset($_GET['412']))
{
    $error_num = "412"; //HTTP_PRECONDITION_FAILED
    $error_image .= "/images/gifs/stareye.gif";
    $error_message = "Nem feleltél meg mindennek...</br>De kellene mi?";
}
elseif(isset($_GET['413']))
{
    $error_num = "413"; //HTTP_REQUEST_ENTITY_TOO_LARGE
    $error_image .= "/images/gifs/toohot.gif";
    $error_message = "Túl nagy csomag, ezt már nem bírom...";
}
elseif(isset($_GET['414']))
{
    $error_num = "414"; //HTTP_REQUEST_URI_TOO_LARGE
    $error_image .= "/images/gifs/frickyou.gif";
    $error_message = "Ez már túl hosszú url, nyem kell.";
}
elseif(isset($_GET['415']))
{
    $error_num = "415"; //HTTP_UNSUPPORTED_MEDIA_TYPE
    $error_image .= "/images/gifs/dusty.gif";
    $error_message = "Pff.. Ez se passzol ide!";
}
elseif(isset($_GET['500']))
{
    $error_num = "500"; //HTTP_INTERNAL_SERVER_ERROR
    $error_image .= "/images/gifs/connecting.gif";
    $error_message = "Szerver belső hiba...</br>Hol a hiba?!";
}
elseif(isset($_GET['501']))
{
    $error_num = "501"; //HTTP_NOT_IMPLEMENTED
    $error_image .= "/images/gifs/fanfun.gif";
    $error_message = "Hát erre nem számított senki...";
}
elseif(isset($_GET['502']))
{
    $error_num = "502"; //HTTP_BAD_GATEWAY
    $error_image .= "/images/gifs/angard.gif";
    $error_message = "\"Rossz bejárat\", te se gondoltad komolyan...";
}
elseif(isset($_GET['503']))
{
    $error_num = "503"; //HTTP_SERVICE_UNAVAILABLE
    $error_image .= "/images/gifs/hungry.gif";
    $error_message = "Épp mással foglalkozik a szerver...</br>Várd ki a sorod.";
}
elseif(isset($_GET['506']))
{
    $error_num = "506"; //HTTP_VARIANT_ALSO_VARIES
    $error_image .= "/images/gifs/sleeping.gif";
    $error_message = "Túl sok változó, majd máskor...";
}
else
{
    $error_num = "400"; //HTTP_BAD_REQUEST
    $error_image .= "/images/gifs/free_candy.gif";
    $error_message = "Hibás kérelem... Cukorkát?";
}
$pageTitle = $error_num . " ERROR";
$error_message .= "</br>".Utils::get_url() . strip_tags((isset($pagelink) ? ("/" . implode("/", $pagelink)) : $_SERVER['REQUEST_URI']));
chdir("../");
?>
<!DOCTYPE html>
<html class="no-js" lang="hu">
	<head>
		<meta charset="utf-8">
		<meta name="viewport" content="width=device-width, initial-scale=1">
		<meta http-equiv="content-type" content="text/html; charset=utf-8" />
		<script async src="https://www.googletagmanager.com/gtag/js?id=UA-212004821-1"></script>
		<script>
			window.dataLayer = window.dataLayer || [];
			function gtag(){dataLayer.push(arguments);}
			gtag('js', new Date());

			gtag('config', 'UA-212004821-1');
		</script>
		<meta name="viewport" content="width=device-width, initial-scale=1">
		<link rel="shortcut icon" href="favicon.ico" type="image/x-icon">
		<link rel="icon" href="favicon.ico" type="image/x-icon">
		<title><?php echo $pageTitle; ?></title>
        <style>
            .error_footer {
                color: white !important;
            }
            .error_footer a:link {
                color: white !important;
            }

            .error_footer a:visited {
                color: gray !important;
            }

            .error_footer a:hover {
                color: white !important;
            }

            .error_footer a:active {
                color: white !important;
            }
        </style>
	</head>
	<body style="background-color: black;">
		<div style="position: absolute; left: 50%; top: 50%; -webkit-transform: translate(-50%, -50%);transform: translate(-50%, -50%);">
			<div style="height: 370px;margin-top: auto;margin-bottom: auto;width: 400px;background-color: rgb(50,50,50); !important;border-radius: 50px;text-align: center;margin: auto;padding-top: 1px;">
                <?php
                    echo "<h1 style='margin-top: 10px; margin-bottom: 0px; position: relative; font-family: sans-serif; color: white; font-weight: bold; font-size: 30px;'>$error_num ERROR</h1>
                    <img style='height: 250px;' src='$error_image'/>
                    <h3 style='position: relative; font-family: sans-serif; color: white;'>$error_message</h3>"
                ?>
                <script>
                    gifimage = document.getElementsByTagName("img")[0];
                    function reloadimage() { gifimage.src = gifimage.src; }
                    setInterval(reloadimage, 1900);
                </script>
			</div>
		</div>
	</body>
</html>
