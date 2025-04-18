<?php 
ErrorManager::$force_no_display = true;
$pageTitle = "Jelszó helyreállítása";
$loginpage = "yes";
$dialogmessage = "&nbsp;";
$dialog = false;

require_once($_SERVER['DOCUMENT_ROOT'] . "/configs/Config.php");
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/includes/Utils.php");
require_once($_SERVER['DOCUMENT_ROOT'] . "/configs/includes/email.php");

function getRealIP() {
    return !empty($_SERVER['HTTP_CLIENT_IP']) ? $_SERVER['HTTP_CLIENT_IP'] : (!empty($_SERVER['HTTP_X_FORWARDED_FOR']) ? $_SERVER['HTTP_X_FORWARDED_FOR'] : $_SERVER['REMOTE_ADDR']);
}

function obfuscate_email($email) {
    $em = explode("@", $email);
    $name = implode('@', array_slice($em, 0, count($em)-1));
    $len = floor(strlen($name) / 2);
    return substr($name, 0, $len) . str_repeat('*', $len) . "@" . end($em);   
}

if (isset($_GET['option']) && ($_GET['option'] === 'username' || $_GET['option'] === 'email') && (isset($_GET['mail']) || isset($_GET['usr']))) {
    
    $email = strip_tags(filter_input(INPUT_GET, 'mail', FILTER_SANITIZE_FULL_SPECIAL_CHARS) ?? '');
    $username = strip_tags(filter_input(INPUT_GET, 'usr', FILTER_SANITIZE_FULL_SPECIAL_CHARS) ?? '');
    $response = [];

    if (empty($username) && empty($email)) {
        $response = ['status' => 'error', 'message' => "Helytelen bevitel."];
        echo json_encode($response);
        return;
    }

    $query = empty($username) ? "SELECT LastLoginName, Username FROM `herboy_regsystem` WHERE Email = '{$email}' LIMIT 1;" : "SELECT LastLoginName, Email FROM `herboy_regsystem` WHERE Username = '{$username}' LIMIT 1;";
    $result = mysqli_fetch_array($sql->query($query));

    if ($result) {
        $lastloginname = $result['LastLoginName'];
        $username = $result['Username'] ?? $username;
        $email = $result['Email'] ?? $email;

        $uuid = md5(uniqid($username.$email.$lastloginname, true));
        $sql->query("INSERT INTO `webpwrst` (`username`, `email`, `token`, `ip_crated`) VALUES ('{$username}', '{$email}', '{$uuid}', '".getRealIP()."');");

        Mailing::Mail_ForgetPassword($email, $lastloginname, $username, $uuid);

        $response = ['status' => 'success', 'message' => "Email kiküldve a következő címre: " . obfuscate_email($email) . " (Nézd meg a spam mappát is!)"];
    } else {
        $response = ['status' => 'error', 'message' => "Nincs email rendelve a felhasználóhoz!"];
    }

    echo json_encode($response);
    return;
}

// Handle password reset form submission
if (isset($_POST['token']) && isset($_POST['newpassword']) && isset($_POST['newpasswordagain'])) {
    $token = strip_tags(filter_input(INPUT_POST, 'token', FILTER_SANITIZE_FULL_SPECIAL_CHARS));
    $newPassword = $_POST['newpassword'];
    $newPasswordAgain = $_POST['newpasswordagain'];
    $response = [];

    if ($newPassword !== $newPasswordAgain) {
        $response = ['status' => 'error', 'message' => "A két jelszó nem egyezik!"];
        echo json_encode($response);
        return;
    } elseif (!preg_match("/^[a-zA-Z0-9]{4,32}+$/", $newPassword)) {
        $response = ['status' => 'error', 'message' => "A jelszó, angol ABC betűit és számokat tartalmazhatja, maximum 32 karakter."];
        echo json_encode($response);
        return;
    } else {
        $query = "SELECT * FROM `webpwrst` WHERE token = '{$token}' AND used = 0 AND CURRENT_DATE() < DATE_ADD(`crated_time`, INTERVAL 1 DAY) LIMIT 1;";
        $result = mysqli_fetch_array($sql->query($query));

        if ($result) {
            $sql->query("UPDATE `webpwrst` SET `used` = 1 WHERE token = '{$token}';");

            $salt = Config::$secret_password_salt;
            $hashedPassword = hash('sha3-512', hash('sha3-512', $newPassword . $salt));

            $sql->query("UPDATE `herboy_regsystem` SET `Password` = '{$hashedPassword}' WHERE Username = '{$result['username']}';");

            $response = ['status' => 'success', 'message' => "Jelszó sikeresen megváltoztatva!"];
        } else {
            $response = ['status' => 'error', 'message' => "Hibás vagy lejárt token."];
        }
    }

    echo json_encode($response);
    return;
}


// Check if the reset form should be loaded
$loadchangepw = false;
if (isset($_GET['t'])) {
    $token = strip_tags(filter_input(INPUT_GET, 't', FILTER_SANITIZE_FULL_SPECIAL_CHARS));
    $tres = $sql->query("SELECT * FROM `webpwrst` WHERE token = '{$token}' AND used = 0 AND CURRENT_DATE() < DATE_ADD(`crated_time`, INTERVAL 1 DAY) LIMIT 1;");
    if ($tres !== false && 0 < mysqli_num_rows($tres)) {
        $loadchangepw = true;
    }
}

// Render the main page
function func_mainpage() {
    global $dialog, $dialogmessage, $loadchangepw;
    ?>

<style>
        /* Add custom styles for centering */
        .full-height {
            min-height: 100vh; /* Ensures full viewport height */
        }
        .modern-card {
            border-radius: 10px; /* Rounded corners */
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1); /* Subtle shadow */
        }
        .modern-card-header {
            background-color: #cc147f; /* Card header background color */
            border-top-left-radius: 10px; /* Rounded corners on the top left */
            border-top-right-radius: 10px; /* Rounded corners on the top right */
        }
        /* Additional styling for body text */

    </style>
<div class="d-flex justify-content-center">
    <div class="modern-card" style="height: fit-content;">
        <div class="modern-card-header">
            <h3>Jelszó helyreállítása</h3>
        </div>
        <div class="modern-card-body">
            <?php if (!$loadchangepw): ?>
                <!-- Username/Email Selection Form -->
                <form id="forgetpassword" method="get">
                    <span style="color:white; font-size: 1.5rem;">Válaszd ki, hogy a felhasználónevedre vagy az emailcímedre emlékszel-e és tölsd ki.</span>
                    <div class="input-group" style="margin-top: 10px;">
                        <!-- Username Option -->
                        <div class="input-group mb-2">
                            <div class="input-group-text" style="background-color: #cc147f; border-color: #3f0727;">
                                <input type="radio" id="username" name="option" value="username" onclick="enableFields('username')">
                            </div>
                            <input id="username_input" type="text" class="form-control" placeholder="Felhasználónév" name="usr" aria-label="Username">
                        </div>

                        <!-- Email Option -->
                        <div class="input-group mb-2">
                            <div class="input-group-text" style="background-color: #cc147f; border-color: #3f0727;">
                                <input type="radio" id="email" name="option" value="email" onclick="enableFields('email')">
                            </div>
                            <input id="email_input" type="email" class="form-control" placeholder="Email" name="mail" aria-label="Email">
                        </div>
                    </div>

                    <!-- Email Küldése Button -->
                    <button type="button" class="btn btn-primary btn-block" id="continue_button" style="background-color: #cc147f; border-color: #3f0727;" onclick="validateForm()">Email Küldése</button>
                </form>
            <?php elseif ($loadchangepw): ?>
                <!-- Password Reset Form -->
                <form id="changepassword" method="post">
                    <input type="hidden" name="token" value="<?php echo htmlspecialchars($_GET['t']); ?>">
                    <div class="input-group form-group">
                        <input type="password" class="form-control" placeholder="Új jelszó" name="newpassword" required>
                    </div>
                    <div class="input-group form-group">
                        <input type="password" class="form-control" placeholder="Új jelszó megerősítése" name="newpasswordagain" required>
                    </div>
                    <button type="submit" class="btn btn-primary btn-block" style="background-color: #cc147f; border-color: #3f0727;">Jelszó megváltoztatása</button>
                </form>
            <?php else: ?>
                <h2 style="color: white;"><?php echo htmlspecialchars($dialogmessage); ?></h2>
            <?php endif; ?>
        </div>
    </div>
</div>
    
    <script>
        // Enable fields and show the Tovább button if either field is filled
        function enableFields(type) {
            if (type === 'username') {
                document.getElementById('email_input').value = '';
            } else {
                document.getElementById('username_input').value = '';
            }

            document.getElementById('continue_button').style.display = 'block';
        }

        function submitForm(data) {
    const xhr = new XMLHttpRequest();
    xhr.open('GET', `/forgetpassword?${data}`, true);
    
    xhr.onload = function () {
        if (xhr.status === 200) {
            const response = JSON.parse(xhr.responseText);

            if (response.status === 'success') {
                showNotification(response.message, 'green');
            } else {
                showNotification(response.message, 'red');
            }
        } else {
            showNotification('Hiba történt. Kérjük, próbáld újra később.', 'red');
        }
    };

    xhr.send();
}

function validateForm() {
    const usernameInput = document.getElementById('username_input').value;
    const emailInput = document.getElementById('email_input').value;
    const usernameRadio = document.getElementById('username').checked;
    const emailRadio = document.getElementById('email').checked;

    if (!usernameRadio && !emailRadio) {
        showNotification("Kérlek, válaszd ki, hogy a felhasználónevedet vagy az emailcímedet szeretnéd használni!", 'red');
        return;
    }

    if (usernameRadio && usernameInput.trim() === "") {
        showNotification("Kérlek, írd be a felhasználónevedet!", 'red');
        return;
    }

    if (emailRadio && emailInput.trim() === "") {
        showNotification("Kérlek, írd be az emailcímedet!", 'red');
        return;
    }

    let data = '';
    if (usernameRadio) {
        data = `option=username&usr=${encodeURIComponent(usernameInput)}`;
    } else if (emailRadio) {
        data = `option=email&mail=${encodeURIComponent(emailInput)}`;
    }

    submitForm(data);
}

// Function to handle password reset form submission
function submitPasswordResetForm(event) {
    event.preventDefault(); // Prevent the form from submitting normally

    const form = document.getElementById('changepassword');
    const formData = new FormData(form);

    const xhr = new XMLHttpRequest();
    xhr.open('POST', '/forgetpassword', true);

    xhr.onload = function () {
        if (xhr.status === 200) {
            const response = JSON.parse(xhr.responseText);

            if (response.status === 'success') {
                showNotification(response.message, 'green');
            } else {
                showNotification(response.message, 'red');
            }
        } else {
            showNotification('Hiba történt. Kérjük, próbáld újra később.', 'red');
        }
    };

    xhr.send(formData);
}

// Add event listener for the password reset form submission
document.getElementById('changepassword').addEventListener('submit', submitPasswordResetForm);

function createHiddenInput(name, value) {
    const input = document.createElement('input');
    input.type = 'hidden';
    input.name = name;
    input.value = value;
    return input;
}

    </script>
    <?php
}

function func_addstyle() {
    ?>
    <link rel="stylesheet" type="text/css" href="//cdn.jsdelivr.net/npm/slick-carousel@1.8.1/slick/slick.css"/>
    <link rel="stylesheet" type="text/css" href="//cdn.jsdelivr.net/npm/slick-carousel@1.8.1/slick/slick-theme.css"/>
    <?php
}

// Render the page
Utils::header("Elfelejtett Jelszó", "func_addstyle");
Utils::body("func_mainpage");
Utils::footer();
?>
