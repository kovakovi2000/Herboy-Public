<?php
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/includes/Utils.php");
header('X-Robots-Tag: noindex, nofollow');
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
		<title>Karbantartás alatt</title>
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
                    echo "<img style='height: 250px;' src='".Utils::get_url("/images/gifs/mashine.gif")."'/>
                    <h3 style='position: relative; font-family: sans-serif; color: white;'>A weboldal jelenleg karbantartás alatt van.</h3>";
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
