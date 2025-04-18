<?php include_once $_SERVER['DOCUMENT_ROOT'] . '/configs/lang/switch.php';
global $lang; ?>
<?php if(isset($pre_footer_func)) call_user_func($pre_footer_func); ?>
<script src="<?php echo Utils::get_url("js/jquery-3.2.1.min.js");?>"></script>
<script src="<?php echo Utils::get_url("js/plugins.js");?>"></script>
<script src="<?php echo Utils::get_url("js/main.js");?>"></script>
<script type='text/javascript'>
    function gotourl($element)
    {
        location.href = $element.getAttribute('data-href');
    } 
    
    $(document).ready(function() {
        $(".div_hideOnLoad").css("display", "block");
        $(".div_hideOnLoad").slideToggle(0);
    });
    var docelement = document.getElementById("hLoading");
    if(docelement)
    {
        const interval = setInterval(function() {
            docelement.innerHTML = docelement.innerHTML + ".";
        }, 500);
        //clearInterval(interval);
    }
    $goto = 0;
    function gotourl($element)
    {
        location.href = $element.getAttribute('data-href');
        $goto = 1;
    }
    function show_tr(ID, element){ 
        if($goto == 1)
            return;
        if ($('#c' + ID).is(":hidden")) { 
            if(element.classList.contains("tr_normal"))
                element.classList.add("tr_selected");
            else
                element.classList.add("tr_banned_selected");
            //document.getElementById(ID).style.display = 'slidedUp' 
            //event.preventDefault()
        } else { 
            if(element.classList.contains("tr_normal"))
                element.classList.remove("tr_selected");
            else
            element.classList.remove("tr_banned_selected");
            //document.getElementById(ID).style.display = 'slidedDown';
            //event.preventDefault();
        }    
        $('#c' + ID).slideToggle(500, "swing");
    }

    function show_table()
    {
        $(this).slideToggle(500, 'swing');
    }
    
</script>
<?php
$currentMonth = date('n');
$isWinterMonth = ($currentMonth == 12 || $currentMonth == 1 || $currentMonth == 2);
?>
<?php if ($isWinterMonth): ?>
    <script type="text/javascript">
        function updateBackgroundWinter() {
            var parallaxSlider = document.getElementsByClassName("bg-image-container")[0];
            if (parallaxSlider && !parallaxSlider.style.backgroundImage.includes("steamstatic.com")) {
                if (!parallaxSlider.style.backgroundImage.includes("hero-bg-cold.jpg")) {
                    parallaxSlider.style.backgroundImage = 'url("/images/hero-bg-cold.jpg")';
                }
            } else {
                setTimeout(updateBackgroundWinter, 15);
            }
        }

        updateBackgroundWinter();
    </script>
    <link rel="stylesheet" href="<?php echo Utils::get_url("css/winter.css"); ?>">
    <div class="snowflakes" aria-hidden="true">
        <div class="snowflake">❅</div>
        <div class="snowflake">❅</div>
        <div class="snowflake">❆</div>
        <div class="snowflake">❄</div>
        <div class="snowflake">❅</div>
        <div class="snowflake">❆</div>
        <div class="snowflake">❄</div>
        <div class="snowflake">❅</div>
        <div class="snowflake">❆</div>
        <div class="snowflake">❄</div>
    </div>
<?php endif; ?>

<?php if (isset($post_footer_func)) call_user_func($post_footer_func); ?>

<!-- Footer elrejtése telefonon. Főoldalon látható marad. -->
<!-- Weboldal tartalma -->
<link rel="stylesheet" type="text/css" href="<?php echo Utils::get_url("css/footer.css?ver=090");?>"/>

<div class="footer-bar"></div>

    <div class="footer-links">
        <span>
            <span style="color: gray;">
            <?php 
                $privacyLink = ($_COOKIE['language'] == 'en') ? 'docs/privacy.pdf' : 'docs/adatvedelmi.pdf';
                $termsLink = ($_COOKIE['language'] == 'en') ? 'docs/Terms.pdf' : 'docs/ÁSZF_HerBoy2.pdf'; 
            ?>
            <a href="<?php echo Utils::get_url($privacyLink); ?>" style="color: gray;"><?php echo $lang['footer_privacy']; ?></a>
            <a href="<?php echo Utils::get_url($termsLink); ?>" style="color: gray;"><?php echo $lang['footer_aszf']; ?></a>
            <a href="<?php echo Utils::get_url("TermsOfUse"); ?>" style="color: gray;"><?php echo $lang['footer_terms']; ?></a>
            </span>
            <a href="<?php echo Utils::get_url("by"); ?>">Copyright © 2018-<?php echo date("Y"); ?> by Herboy Team</a>
        </span>
    </div>

    <script type="text/javascript">
        document.addEventListener("DOMContentLoaded", function() {
            // Ellenőrizzük az URL-t
            var currentUrl = window.location.pathname;
            
            // Ha az URL tartalmazza a '/profile/'
            if (currentUrl.includes('/profile/')) {
                document.body.classList.add('profile');
            }
        });
    </script>

    <script>
    // Function to create and show a notification with customizable color
    function showNotification(message, color) {
        const notification = document.createElement('div');
        notification.textContent = message;
        notification.style.position = 'fixed';
        notification.style.top = '15%'; // Center vertically
        notification.style.left = '50%'; // Center horizontally
        notification.style.transform = 'translate(-50%, -50%)'; // Offset for exact centering
        notification.style.padding = '20px'; // Increased padding
        notification.style.backgroundColor = color; // Dynamic color
        notification.style.color = 'white';
        notification.style.borderRadius = '10px'; // Larger border radius
        notification.style.zIndex = '1000'; // Ensure it appears above other elements
        notification.style.boxShadow = '0 4px 8px rgba(0, 0, 0, 0.2)';
        notification.style.fontSize = '18px'; // Larger font size
        notification.style.fontWeight = 'bold'; // Bold text
        notification.style.textAlign = 'center'; // Center text
        notification.style.opacity = '1';
        notification.style.transition = 'opacity 1s';
        document.body.appendChild(notification);

        setTimeout(() => {
            notification.style.opacity = '0';
            setTimeout(() => {
                document.body.removeChild(notification);
            }, 1000); // Remove after fade-out
        }, 3000); // Show for 3 seconds
    }
    </script>
<?php if(isset($post_footer_func)) call_user_func($post_footer_func); ?>