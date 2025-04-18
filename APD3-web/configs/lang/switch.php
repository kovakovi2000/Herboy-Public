<?php
// if (isset($_GET["lang"]) && $_GET["lang"] != $_COOKIE["language"]) {
//     setcookie("language", $_GET["lang"], time() + 365 * 24 * 60 * 60, "/");
//     $_COOKIE["language"] = $_GET["lang"];
//     header("Location: " . $_SERVER["REQUEST_URI"]);
//     exit();
// }

function set_language_cookie_based_on_country()
{
    
    if (!isset($_COOKIE["language"])) {
        $lang = AbuseIPDB::getCountryCodeForIP();
        if(isset($lang) && strtolower($lang) == "hu")
        {
            setcookie("language", "hu", time() + 365 * 24 * 60 * 60, "/");
            $_COOKIE["language"] = "hu";
        }
        else
        {
            setcookie("language", "en", time() + 365 * 24 * 60 * 60, "/");
            $_COOKIE["language"] = "en";
            if(!isset($_SESSION['lang_noti']) && isset($lang) && strtolower($lang) != "en")
            {
                $_SESSION['lang_noti'] = 1;
                echo '
                <div id="language-warning-modal" style="
                    position: fixed;
                    top: 0;
                    left: 0;
                    width: 100%;
                    height: 100%;
                    background: rgba(0, 0, 0, 0.5);
                    backdrop-filter: blur(8px);
                    display: flex;
                    justify-content: center;
                    align-items: center;
                    z-index: 1000;
                    visibility: visible;
                    opacity: 1;
                    transition: visibility 0s, opacity 0.3s ease-in-out;">
                    <div style="
                        background: white;
                        padding: 20px;
                        border-radius: 8px;
                        max-width: 500px;
                        width: 90%;
                        box-shadow: 0 4px 10px rgba(0, 0, 0, 0.2);
                        text-align: center;">
                        <h2 style="margin-bottom: 10px;">Language Unavailable</h2>
                        <p style="margin-bottom: 20px; color: #333;">
                            We detected that your IP address originates from a country 
                            (<span>' . htmlspecialchars(strtoupper($lang)) . '</span>), 
                            but unfortunately, we don\'t support your language. 
                            The site has defaulted to English. You can change the language in the settings if needed.
                        </p>
                        <button id="close-modal" style="
                            padding: 10px 20px;
                            background: #3498db;
                            color: white;
                            border: none;
                            border-radius: 4px;
                            cursor: pointer;
                            font-size: 16px;">Close</button>
                    </div>
                </div>
                <script>
                    document.getElementById("close-modal").addEventListener("click", function () {
                        const modal = document.getElementById("language-warning-modal");
                        modal.style.visibility = "hidden";
                        modal.style.opacity = "0";
                    });
                </script>';
            }
        }
    }
}

function load_language($default = "en")
{
    // Call the function to set the cookie based on the country
    set_language_cookie_based_on_country();

    // Retrieve the language value
    $lang = $_COOKIE["language"] ?? $default;

    // Load the language file
    $langFilePath = $_SERVER["DOCUMENT_ROOT"] . "/configs/lang/" . $lang . ".php";
    if (!file_exists($langFilePath)) {
        die("Language file for '$lang' could not be found at '$langFilePath'.");
    }

    $languageArray = include_once $langFilePath;
    if (!isset($languageArray) || !is_array($languageArray)) {
        die("Language file for '$lang' could not be loaded correctly.");
    }
    return $languageArray;
}

$lang = load_language();
if (!is_array($lang)) {
    // Handle the error case where the language file was not loaded properly
    die("Language file could not be loaded.");
}
?>
