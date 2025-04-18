<?php global $lang; ?>
<body id="top">
        <?php if(!isset($_COOKIE[Config::$cookie_AgreeCookie_name])): ?>
            <div id="cookie-box" style="color: yellow !important;font-size: 10px !important;position: fixed; float:left; margin: 30px; z-index: 99; width: 300px; height: 100px; border-radius: 25px; background-color: rgb(0, 0, 0, 0.5); padding: 10px;">
                <p style="margin-bottom: 10px; color: yellow !important;">Ez a weboldal sütiket használ. Az Uniós törvények értelmében kérem, engedélyezze a sütik használatát, vagy zárja be az oldalt.</p>
                <snap style="font-size: 15px !important; cursor: pointer;margin-left: 40px; float:left" onclick="agreeCookie()">Elfogadás</snap>
                <snap style="font-size: 15px !important; cursor: pointer;margin-right: 40px; float:right" onclick="gotourl(this)" data-href="TermsOfUse.php">Továbbiak</snap>
            </div>
            <script>
                function agreeCookie()
                {
                    var xmlHttp = new XMLHttpRequest();
                    xmlHttp.withCredentials = true;
                    xmlHttp.open("GET", "<?php echo Utils::get_url("api/AgreeCookies"); ?>", false);
                    xmlHttp.send(null);
                    $("#cookie-box").fadeOut( 1000, function() {
                        $( this ).remove();
                    });
                }
            </script>
        <?php endif; ?>
        <header class="s-header" style="width: 0px;">
            <nav class="header-nav">
                <div class="header-nav__content">
                    <?php
                        if(Account::isLogined())
                        {
                            Account::$UserProfile->ProfilePic(95);
                            echo "<h5 class='wellcome_message'>".$lang['logged_in'].",</br>".Account::$UserProfile->LastLoginName."</h5>";
                        }
                    ?>
                    <a href="#0" class="header-nav__close" title="Bezár"><span>Bezár</span></a>

                    <h3><?php echo $lang['menu']; ?></h3>
<label for="language-select" style="color: white; margin-bottom: 10px;"><?php echo $lang['choose_lang']; ?></label>
<div id="language-select" style="margin-bottom: 15px; display: flex; gap: 10px;">
    <a href="" style="text-decoration: none;">
        <img src="/images/CCI/hu.png" alt="hu" style="width: 32px; height: 20px; border: <?php echo (isset($_COOKIE['language']) && $_COOKIE['language'] == 'hu') ? '2px solid yellow' : 'none'; ?>">
    </a>
    <a href="" style="text-decoration: none;">
        <img src="/images/CCI/us.png" alt="en" style="width: 32px; height: 20px; border: <?php echo (isset($_COOKIE['language']) && $_COOKIE['language'] == 'en') ? '2px solid yellow' : 'none'; ?>">
    </a>
</div>


                    <ul class="header-nav__list">
                        <?php
                            foreach (Config::$menupages as $value) {
                                if($value->CanAccess())
                                    echo "<li><a href='".Utils::get_url($value->link)."'>$value->name</a></li>";
                            }
                        ?>
                        
                    </ul>
                    <!-- <ul class="header-nav__social">
                        <li>
                            <a href="https://www.facebook.com/groups/522374791586223/" target="_blank"><i class="fab fa-facebook"></i></a>
                        </li>
                    </ul> -->
                </div>
            </nav>
            
            <a class="header-menu-toggle" href="#0">
                <span class="header-menu-icon"></span>
            </a>
            <?php if(isset($userid)): ?>
                <a class="header-menu-noti">
                    <svg xmlns="http://www.w3.org/2000/svg" width="28" height="28" fill="currentColor" class="bi bi-bell" viewBox="0 0 16 16">
                        <path class="header-not-icon" d="M8 16a2 2 0 0 0 2-2H6a2 2 0 0 0 2 2zM8 1.918l-.797.161A4.002 4.002 0 0 0 4 6c0 .628-.134 2.197-.459 3.742-.16.767-.376 1.566-.663 2.258h10.244c-.287-.692-.502-1.49-.663-2.258C12.134 8.197 12 6.628 12 6a4.002 4.002 0 0 0-3.203-3.92L8 1.917zM14.22 12c.223.447.481.801.78 1H1c.299-.199.557-.553.78-1C2.68 10.2 3 6.88 3 6c0-2.42 1.72-4.44 4.005-4.901a1 1 0 1 1 1.99 0A5.002 5.002 0 0 1 13 6c0 .88.32 4.2 1.22 6z"/>
                    </svg>
                    <span class="num"></span>
                    <div class="noti-list">
                        <h3 class="note-list-title">Értesítések:</h3>
                    </div>
                </a>
                <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
            <?php endif;?>
        </header>
        <script>
            document.getElementById('language-select').addEventListener('click', function (event) {
                // Check if the clicked element is one of the language buttons
                if (event.target.tagName === 'IMG') {
                    // Get the language code from the image's alt attribute
                    var selectedLanguage = event.target.alt.toLowerCase();

                    // Validate that selectedLanguage is one of the supported language codes
                    var supportedLanguages = ['hu', 'en']; // List of supported languages
                    if (supportedLanguages.includes(selectedLanguage)) {
                        // Set the selected language in a cookie for 1 year
                        document.cookie = "language=" + selectedLanguage + "; path=/; max-age=" + 60 * 60 * 24 * 365;

                        // Reload the page to apply the new language
                        window.location.reload();
                    } else {
                        // If invalid language, log an error message
                        console.error("Invalid language selected:", selectedLanguage);
                    }
                }
            });
        </script>

    <!-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ -->
    <?php
    global $currentUser;
    $isProfilePage = strpos($_SERVER['REQUEST_URI'], '/profile/') !== false;

    if ($isProfilePage) {
        if ($currentUser->IsSteam()) {
            $currentUser->Steam->request_Background();
            $backgroundUrl = $currentUser->Steam->bgurl;
            $isAnimated = $currentUser->Steam->bgIsAnimated;
            $hasBackground = !empty($backgroundUrl);
            if(empty($backgroundUrl))
                $backgroundUrl = Utils::get_url("images/hero-bg.webp");
            //$opacity = $hasBackground ? ($isAnimated ? '0' : '0') : '0.65';
        } else {
            $backgroundUrl = Utils::get_url("images/hero-bg.webp");
            $isAnimated = false;
            //$opacity = '0.65'; 
        }
    } else {
        $backgroundUrl = Utils::get_url("images/hero-bg.webp");
        $isAnimated = false;
        //$opacity = '0.65';
    }
    ?>

    <section id="home" class="s-home target-section">
        <?php if ($isAnimated): ?>
            <video id="bg_animated" class="bg-video-container" autoplay muted loop playsinline>
                <source src="<?php echo $backgroundUrl; ?>">
            </video>
        <?php else: ?>
            <div class="bg-image-container" style="background-image: url('<?php echo $backgroundUrl; ?>');"></div>
        <?php endif; ?>
        
    <div class="modern-card-container">
        <?php
        if (is_array($content_func)) {
            for ($i = 0; $i < sizeof($content_func); $i += 2) 
                Utils::Card($content_func[$i], $content_func[$i + 1], $i == 0);
        } else if (isset($content_func)) {
            call_user_func($content_func);
        }
        ?>
    </div>
        
        <style>
            .s-home::before {
                /* opacity: <?php // echo $opacity; ?>; */
                opacity: 0.65;
            }
            .s-home {
                position: relative;
                overflow: hidden;
                height: 100vh;
            }

            .bg-video-container {
                position: absolute;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                object-fit: cover;
                z-index: -1;
            }

            .bg-image-container {
                position: absolute;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                background-size: cover; 
                background-position: center;
                z-index: -1;
            }
        </style>
    </section>