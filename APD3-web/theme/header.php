<?php 
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/Config.php");
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/includes/Utils.php");
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/includes/Account.php");

?>
<!DOCTYPE html>
<html class="no-js" lang="hu">
    <head>
        <?php if(isset($pre_header_func)) call_user_func($pre_header_func); ?>
        <meta charset="utf-8">
        <meta http-equiv="content-type" content="text/html; charset=utf-8" />
        <meta name="author" content="">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">

        <!-- <link href="//maxcdn.bootstrapcdn.com/bootstrap/4.1.1/css/bootstrap.min.css" rel="stylesheet" id="bootstrap-css"> -->
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.8.1/font/bootstrap-icons.css">
        <script type="text/javascript" src="https://code.jquery.com/jquery.js"></script>
        <script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.1.1/js/bootstrap.min.js"></script>
        

       
        <link rel="stylesheet" type="text/css" href="https://maxcdn.bootstrapcdn.com/bootswatch/3.3.2/yeti/bootstrap.min.css"/>
        <!-- <script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0-alpha.6/css/bootstrap.min.css"></script> -->
        <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/3.3.2/js/bootstrap.js"></script>  

        <!-- Global site tag (gtag.js) - Google Analytics -->
        <!-- Google tag (gtag.js) -->
        <script async src="https://www.googletagmanager.com/gtag/js?id=AW-11103831498"></script>
        <script>
        window.dataLayer = window.dataLayer || [];
        function gtag(){dataLayer.push(arguments);}
        gtag('js', new Date());
        gtag('config', 'AW-11103831498');
        </script>

        <!-- Event snippet for Oldalmegtekintés conversion page -->
        <script>
        gtag('event', 'conversion', {
            'send_to': 'AW-11103831498/P2ryCNqr1foZEMqL3K4p',
            'value': 1.0,
            'currency': 'HUF'
        });
        </script>

        <title><?php echo $title; ?></title>
        <meta name="description" content="HerBoy - Hivatalos weboldal">
        <meta name="author" content="Kova">
        <link rel="stylesheet" href="<?php echo Utils::get_url("css/base.css?ver=a123");?>">
        <link rel="stylesheet" href="<?php echo Utils::get_url("css/vendor.css?ver=a123");?>">
        <link rel="stylesheet" href="<?php echo Utils::get_url("css/main.css?ver=a123");?>">
        <script src="<?php echo Utils::get_url("js/modernizr.js");?>"></script>
        <script src="<?php echo Utils::get_url("js/pace.min.js");?>"></script>
        <link rel="shortcut icon" href="<?php echo Utils::get_url("/images/favicon.ico");?>" type="image/x-icon">
        <link rel="icon" href="<?php echo Utils::get_url("/images/favicon.ico");?>" type="image/x-icon">

        <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/css/bootstrap.min.css" integrity="sha384-MCw98/SFnGE8fJT3GXwEOngsV7Zt27NXFoaoApmYm81iuXoPkFOJwJ8ERdknLPMO" crossorigin="anonymous">
        <link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.3.1/css/all.css" integrity="sha384-mzrmE5qonljUremFsqc01SB46JvROS7bZs3IO2EmfFsd15uHvIt+Y8vEf7N7fWAU" crossorigin="anonymous">
        <link rel="stylesheet" type="text/css" href="<?php echo Utils::get_url("css/noti.css?ver=a123");?>">
        <link rel="stylesheet" type="text/css" href="<?php echo Utils::get_url("css/style.css?ver=a123");?>">
        <link rel="stylesheet" type="text/css" href="<?php echo Utils::get_url("css/avatar.css?ver=a123");?>">
        <link rel="stylesheet" type="text/css" href="<?php echo Utils::get_url("css/permission.css?ver=a123");?>">
        <link rel="stylesheet" type="text/css" href="<?php echo Utils::get_url("css/card.css?ver=a123");?>">
        <link rel="stylesheet" type="text/css" href="<?php echo Utils::get_url("css/new_label.css?ver=a123");?>">

        <meta property="og:title" content="herboyd2.hu - Herboy hivatalos weboldal counter-strike 1.6 szerverhez! <?php echo $title; ?>"/>
        <meta property="og:description" content="HerBoy - Hivatalos weboldal"/>
        <meta property="og:image" content="https://scontent.fbud5-1.fna.fbcdn.net/v/t1.6435-9/144117286_2806922606225011_6128028498424755430_n.jpg?_nc_cat=106&ccb=1-5&_nc_sid=8631f5&_nc_ohc=2GlLIU4p0SEAX9SC3l1&_nc_ht=scontent.fbud5-1.fna&oh=7e204b803f914d4994c51a8153faefd4&oe=61B7E1C8"/>
        <?php if(isset($post_header_func)) call_user_func($post_header_func); ?>
    </head>