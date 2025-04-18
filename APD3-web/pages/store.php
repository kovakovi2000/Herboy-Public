<?php
if(!ErrorManager::isDevelpor()) {
    include_once($_SERVER['DOCUMENT_ROOT'] . "/dev.php");
    exit();
}
include_once $_SERVER['DOCUMENT_ROOT'] . '/configs/lang/switch.php';
function func_mainpage()
{   global $lang;
    global $sql;
    ?>

<div class="modern-card">
        <div class="modern-card-header text-center">
            <h1><?php echo $lang['page_store']; ?></h1>
        </div>
        <div class="modern-card-body">
            <div class="row justify-content-center mt-4 custom-margin">
                <!-- Item 1 -->
                <div class="col-lg-4 col-md-6 mb-4 d-flex justify-content-center">
                    <div class="custom-card">
                    <h5 class="custom-card-title">
                        <span id="animated-price-1">1500</span> <?php echo $lang['pp_point']; ?>
                        <span class="bonus-notification">+20% <?php echo $lang['pp_bonus']; ?>!</span>
                    </h5>
                        <img src="/images/paypal/pp2.webp" alt="Payment Image" class="img-fluid mb-3" style="width: 75px; height: auto;">
                        <p class="custom-card-text"><?php echo $lang['pp_price']; ?>: 1000 Ft</p>
                        <button class="btn btn-primary btn-transparent" onclick="purchaseItem(1)"><?php echo $lang['pp_buybutton']; ?></button>
                    </div>
                </div>

                <!-- Item 2 -->
                <div class="col-lg-4 col-md-6 mb-4 d-flex justify-content-center">
                    <div class="custom-card">
                    <h5 class="custom-card-title">
                        <span id="animated-price-2">2600</span> <?php echo $lang['pp_point']; ?>
                        <span class="bonus-notification">+20% <?php echo $lang['pp_bonus']; ?>!</span>
                    </h5>
                        <img src="/images/paypal/pp3.webp" alt="Payment Image" class="img-fluid mb-3" style="width: 75px; height: auto;">
                        <p class="custom-card-text"><?php echo $lang['pp_price']; ?>: 2000 Ft</p>
                        <button class="btn btn-primary btn-transparent" onclick="purchaseItem(2)"><?php echo $lang['pp_buybutton']; ?></button>
                    </div>
                </div>

                <!-- Item 3 -->
                <div class="col-lg-4 col-md-6 mb-4 d-flex justify-content-center">
                    <div class="custom-card">
                        <h5 class="custom-card-title">
                        <span id="animated-price-3">4000</span> <?php echo $lang['pp_point']; ?>
                        <span class="bonus-notification">+20% <?php echo $lang['pp_bonus']; ?>!</span>
                    </h5>
                        <img src="/images/paypal/pp4.webp" alt="Payment Image" class="img-fluid mb-3" style="width: 75px; height: auto;">
                        <p class="custom-card-text"><?php echo $lang['pp_price']; ?>: 3000 Ft</p>
                        <button class="btn btn-primary btn-transparent" onclick="purchaseItem(3)"><?php echo $lang['pp_buybutton']; ?></button>
                    </div>
                </div>

                <!-- Item 4 -->
                <div class="col-lg-4 col-md-6 mb-4 d-flex justify-content-center">
                    <div class="custom-card">
                    <h5 class="custom-card-title">
                        <span id="animated-price-4">8000</span> <?php echo $lang['pp_point']; ?>
                        <span class="bonus-notification">+20% <?php echo $lang['pp_bonus']; ?>!</span>
                    </h5>
                        <img src="/images/paypal/pp5.webp" alt="Payment Image" class="img-fluid mb-3" style="width: 75px; height: auto;">
                        <p class="custom-card-text"><?php echo $lang['pp_price']; ?>: 5000 Ft</p>
                        <button class="btn btn-primary btn-transparent" onclick="purchaseItem(4)"><?php echo $lang['pp_buybutton']; ?></button>
                    </div>
                </div>

                <!-- Item 5 -->
                <div class="col-lg-4 col-md-6 mb-4 d-flex justify-content-center">
                    <div class="custom-card">
                    <h5 class="custom-card-title">
                        <span id="animated-price-5">13000</span> <?php echo $lang['pp_point']; ?>
                        <span class="bonus-notification">+20% <?php echo $lang['pp_bonus']; ?>!</span>
                    </h5>
                        <img src="/images/paypal/pp6.webp" alt="Payment Image" class="img-fluid mb-3" style="width: 75px; height: auto;">
                        <p class="custom-card-text"><?php echo $lang['pp_price']; ?>: 10.000 Ft</p>
                        <button class="btn btn-primary btn-transparent" onclick="purchaseItem(5)"><?php echo $lang['pp_buybutton']; ?></button>
                    </div>
                </div>

                <!-- Item 6 -->
                <div class="col-lg-4 col-md-6 mb-4 d-flex justify-content-center">
                    <div class="custom-card">
                    <h5 class="custom-card-title">
                        <span id="animated-price-6">20000</span> <?php echo $lang['pp_point']; ?>
                        <span class="bonus-notification">+20% <?php echo $lang['pp_bonus']; ?>!</span>
                    </h5>
                        <img src="/images/paypal/pp7.webp" alt="Payment Image" class="img-fluid mb-3" style="width: 75px; height: auto;">
                        <p class="custom-card-text"><?php echo $lang['pp_price']; ?>: 15.000 Ft</p>
                        <button class="btn btn-primary btn-transparent" onclick="purchaseItem(6)"><?php echo $lang['pp_buybutton']; ?></button>
                    </div>
                </div>
            </div> <!-- End row -->
        </div>
    </div>
    <script>
    function animatePrice(elementId, start, end, duration) {
        const element = document.getElementById(elementId);
        let current = start;
        const increment = (end - start) / (duration / 10);  // Calculate the increment
        const interval = setInterval(() => {
            current += increment;
            element.textContent = Math.floor(current);
            if (current >= end) {
                element.textContent = end;  // Ensure it reaches the end value
                clearInterval(interval);
                element.style.color = "rgba(255, 215, 0, 0.8)";  // Change color at the end
            }
        }, 10);  // Updates every 10ms
    }

    document.addEventListener("DOMContentLoaded", () => {
        // Animate each price with unique IDs
        animatePrice("animated-price-1", 1500, 1800, 2000);  // Item 1
        animatePrice("animated-price-2", 2600, 3120, 2000);  // Item 2
        animatePrice("animated-price-3", 4000, 4800, 2000);  // Item 3
        animatePrice("animated-price-4", 8000, 9600, 2000);  // Item 4
        animatePrice("animated-price-5", 13000, 15600, 2000);  // Item 5
        animatePrice("animated-price-6", 20000, 24000, 2000);  // Item 6
    });
</script>

    <script>
        function purchaseItem(itemNumber) {
            // Redirect to purchase page with item number
            window.location.href = 'checkout?pp=' + itemNumber;
        }
    </script>

    <?php
}

function func_addstyle()
{
    ?>
    <script type="text/javascript" src="//cdn.jsdelivr.net/npm/slick-carousel@1.8.1/slick/slick.min.js"></script>
    <link rel="stylesheet" type="text/css" href="//cdn.jsdelivr.net/npm/slick-carousel@1.8.1/slick/slick.css"/>
    <link rel="stylesheet" type="text/css" href="//cdn.jsdelivr.net/npm/slick-carousel@1.8.1/slick/slick-theme.css"/>
    <style>
    /* Custom CSS for the cards */
    .custom-card {
        background-color: rgba(0, 0, 0, 0.8); /* White with 80% opacity */
        color: purple; /* Text color */
        border-radius: 10px;
        box-shadow: 0px 4px 8px rgba(0, 0, 0, 0.1);
        padding: 20px;
        text-align: center;
        transition: transform 0.3s ease;
    }

    .custom-card:hover {
        transform: translateY(-5px);
    }

    .custom-card-title {
        font-size: 18px;
        font-weight: bold;
        margin-bottom: 10px;
    }

    .custom-card-text {
        font-size: 16px;
        margin-bottom: 15px;
        color: lightblue;
    }

    .bonus-notification {
    background-color: rgba(255, 215, 0, 0.8); /* Gold background */
    color: #333; /* Dark text */
    padding: 5px 10px;
    border-radius: 5px;
    font-weight: bold;
    font-size: 14px;
    display: inline-block;
    animation: glowPulse 2.5s ease-in-out infinite; /* Animation effect */
    transition: opacity 0.5s ease-in-out;
}

/* Pulsing Glow and Fade-in/out Animation */
@keyframes glowPulse {
    0%, 100% {
        opacity: 0.8;
        box-shadow: 0 0 10px rgba(255, 215, 0, 0.8), 0 0 20px rgba(255, 215, 0, 0.6), 0 0 30px rgba(255, 215, 0, 0.4);
    }
    50% {
        opacity: 1;
        box-shadow: 0 0 15px rgba(255, 215, 0, 0.8), 0 0 25px rgba(255, 215, 0, 0.5), 0 0 35px rgba(255, 215, 0, 0.3);
    }
}
    .custom-margin {
    margin-left: 5%; /* Adjust this value as needed */
}

.btn-transparent {
        background-color: rgba(0, 123, 255, 0.5); /* Blue with 50% opacity */
        color: white; /* Text color */
        border: none; /* Optional: remove border */
    }

    .btn-transparent:hover {
        background-color: rgba(0, 123, 255, 0.7); /* Darken on hover */
    }

</style>
    <?php
}

Utils::header("Áruház", "func_addstyle");
Utils::body("func_mainpage");
Utils::footer();
