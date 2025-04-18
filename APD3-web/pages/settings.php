<?php
//ErrorManager::$force_no_display = true;
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);
require_once($_SERVER['DOCUMENT_ROOT'] . "/configs/Config.php");

global $lang;
$salt = Config::$secret_password_salt;

function func_mainpage() {
    global $lang;
    global $sql;

    if (isset($_SESSION['account'])) {
        $userProfile = unserialize($_SESSION['account']);
        if ($userProfile) {
            $userName = $userProfile->Username ?? 'Unknown Name';
            $userId = $userProfile->id ?? 'Unknown ID';
            $currentEmail = $userProfile->Email ?? 'Unknown Email';
            $steamID = $userProfile->LastLoginID ?? 'Unknown SteamID';
        } else {
            exit();
        }
    } else {
        echo "<meta http-equiv='refresh' content='0;url=/login'>";
        exit();
    }

$_SESSION['csrf_token'] = bin2hex(random_bytes(32));
$csrf_token = $_SESSION['csrf_token'];

$websiteLoginType = $lang['website_login'];
$ingameLoginType = $lang['ingame_login'];
$failedLoginType = $lang['failed_web_login'];


$combinedLogins = [];

$stmt = $sql->prepare("SELECT IP AS ipaddress, Created AS datetime, ? AS type FROM webloginlog WHERE UserId = ?");
$stmt->bind_param("si", $websiteLoginType, $userId);
$stmt->execute();
$result = $stmt->get_result();
while ($row = $result->fetch_assoc()) {
    $combinedLogins[] = $row;
}
$stmt->close();


$stmt = $sql->prepare("SELECT name, steamid, ipaddress, datetime, ? AS type FROM herboy_reglogin_log WHERE userid = ?");
$stmt->bind_param("si", $ingameLoginType, $userId);
$stmt->execute();
$result = $stmt->get_result();
while ($row = $result->fetch_assoc()) {
    $combinedLogins[] = $row;
}
$stmt->close();

$stmt = $sql->prepare("SELECT IP AS ipaddress, FROM_UNIXTIME(time) AS datetime, ? AS failed_login FROM webloginfailed WHERE username = ?");
$stmt->bind_param("ss", $failedLoginType, $userName);
$stmt->execute();
$result = $stmt->get_result();
while ($row = $result->fetch_assoc()) {
    $combinedLogins[] = $row;
}
$stmt->close();

usort($combinedLogins, function($a, $b) {
    return strtotime($b['datetime']) - strtotime($a['datetime']);
});
    ?>

<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="csrf-token" content="<?php echo $_SESSION['csrf_token']; ?>">

    <style>
        body {
  font-family: Arial, sans-serif;
  background-color: #f4f4f4;
  margin: 0;
  padding: 0;
}

.button-container {
  display: flex !important;
  gap: 20px !important;
  margin-bottom: 20px !important;
  justify-content: center !important;
  flex-wrap: wrap !important;
  padding: 0 10px !important;
}

.collapsible {
  background-color: rgba(0, 0, 0, 0.3) !important;
  color: white !important;
  cursor: pointer !important;
  padding: 10px 15px !important;
  text-align: center !important;
  border: none !important;
  border-radius: 5px !important;
  font-size: 16px !important;
  transition: background-color 0.3s ease, transform 0.3s ease !important;
}

.collapsible:hover {
  background-color: rgba(0, 0, 0, 0.1);
  transform: scale(1.02);
  color: white;
}

.content {
  display: none;
  overflow: hidden;
  padding: 20px;
  border-radius: 5px;
  margin-top: 10px;
  animation: slideDown 0.5s ease forwards;
}

.content.closing {
  animation: slideUp 0.5s ease forwards;
}

@keyframes slideDown {
  from {
    max-height: 0;
    opacity: 0;
  }
  to {
    max-height: 500px;
    opacity: 1;
  }
}

@keyframes slideUp {
  from {
    max-height: 500px;
    opacity: 1;
  }
  to {
    max-height: 0;
    opacity: 0;
  }
}
.element {
  animation-duration: 1s;
  animation-timing-function: ease-in-out;
}

.update-form {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.form-row {
  display: flex;
  gap: 20px;
}

.form-group {
  flex: 1;
  display: flex;
  flex-direction: column;
}

label {
  color: white;
  margin-bottom: 5px;
  font-weight: bold;
}

input {
  padding: 10px;
  border-radius: 5px;
  border: 1px solid #ccc;
  font-size: 14px;
  background-color: rgba(0, 0, 0, 0.3);
  color: white;
}
input[type="email"]:focus,
input[type="number"]:focus,
input[type="text"]:focus,
input[type="password"]:focus,
textarea:focus,
select:focus {
  color: white;
}

input[readonly] {
  background-color: rgba(0, 0, 0, 0.3);
  cursor: not-allowed;
}

.update-btn {
  background-color: rgba(0, 0, 0, 0.3);
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 5px;
  cursor: pointer;
  font-size: 16px;
  transition: background-color 0.3s ease, transform 0.3s ease;
}

.update-btn:hover {
  background-color: rgba(0, 0, 0, 0.1);
  transform: scale(1.02);
  color: white;
}

.hidden {
  display: none;
}
#current-email {
  padding: 10px;
  border-radius: 5px;
  border: 1px solid #ccc;
  font-size: 14px;
  background-color: rgba(0, 0, 0, 0.3);
  color: white;
  cursor: not-allowed;
}
thead th {
  text-align: center !important;
}
tbody td {
  text-align: center !important;
  padding: 10px !important;
}

.info-icon {
  font-size: 18px;
  color: white;
  background-color: rgba(0, 0, 0, 0.5);
  border-radius: 50%;
  width: 30px;
  height: 30px;
  display: inline-flex;
  justify-content: center;
  align-items: center;
  cursor: pointer;
  margin-left: 10px;
  font-weight: bold;
  text-align: center;
}

.info-icon:hover::after {
  content: "<?php echo addslashes($lang['sec_tooltip']); ?>";
  display: block;
  position: absolute;
  background-color: rgba(0, 0, 0, 0.2);
  color: #fff;
  padding: 5px 10px;
  border-radius: 5px;
  top: -100%;
  left: 100%;
  transform: translateX(-50%);
  font-size: 14px;
  margin-top: 5px;
  z-index: 10;
  width: 350px;
  text-align: center;
  word-wrap: break-word;
}
@media (max-width: 767px) {
    .info-icon {
        display: none;
    }
}

h1 {
  position: relative;
  display: inline-block;
}
</style>

<script>

document.addEventListener("DOMContentLoaded", function () {
    const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content');
    const emailButton = document.querySelector('#emailButton');
    const emailContent = document.querySelector('#emailContent');
    const passwordButton = document.querySelector('#passwordButton');
    const passwordContent = document.querySelector('#passwordContent');
    const pageContent = document.getElementById('pageContent');
    const logoutButton = document.querySelector('#logoutButton');

    emailButton.addEventListener('click', function () {
        const isOpen = emailContent.style.display === 'block';

        if (isOpen) {
            emailContent.classList.add('closing');
            setTimeout(() => {
                emailContent.style.display = 'none';
                emailContent.classList.remove('closing');
                pageContent.classList.remove('hidden');
                passwordButton.style.display = 'inline-block';
                logoutButton.style.display = 'inline-block';
            }, 500);
        } else {
            emailContent.style.display = 'block';
            passwordContent.style.display = 'none';
            passwordButton.style.display = 'none';
            logoutButton.style.display = 'none';
            pageContent.classList.add('hidden');
        }
    });

    passwordButton.addEventListener('click', function () {
        const isOpen = passwordContent.style.display === 'block';

        if (isOpen) {
            passwordContent.classList.add('closing');
            setTimeout(() => {
                passwordContent.style.display = 'none';
                passwordContent.classList.remove('closing');
                pageContent.classList.remove('hidden');
                emailButton.style.display = 'inline-block';
                logoutButton.style.display = 'inline-block';
            }, 500);
        } else {
            passwordContent.style.display = 'block';
            emailContent.style.display = 'none';
            emailButton.style.display = 'none';
            logoutButton.style.display = 'none';
            pageContent.classList.add('hidden');
        }
    });

    document.getElementById("update-email-btn").addEventListener("click", function () {
    const newEmail = document.getElementById("new-email").value;

    fetch('/api/UPCM', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'X-CSRF-TOKEN': csrfToken,
        },
        body: JSON.stringify({ new_email: newEmail }),
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            showNotification("<?php echo $lang['sec_mailchange_success']; ?>", "#4caf50");

            // Dynamically update the current email field
            const currentEmailElement = document.getElementById("current-email");
if (currentEmailElement) {
    currentEmailElement.textContent = newEmail; // Update the span text dynamically
}

            // Clear the email form
            document.getElementById("email-form").reset();
        } else {
            showNotification("<?php echo $lang['sec_mailchange_error']; ?>", "#f44336");
        }
    })
    .catch(error => {
        console.error('Error:', error);
        alert('An unexpected error occurred');
    });
});

    // Password Update
    document.getElementById("update-password-btn").addEventListener("click", function () {
        const newPassword = document.getElementById("new-password").value;
        const confirmPassword = document.getElementById("confirm-password").value;

        if (newPassword !== confirmPassword) {
            showNotification("<?php echo $lang['sec_passchange_nomatch']; ?>", "#f44336");
            return;
        }

        fetch('/api/UPCP', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-TOKEN': csrfToken,
            },
            body: JSON.stringify({ new_password: newPassword }),
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                showNotification("<?php echo $lang['sec_passchange_success']; ?>", "#4caf50");

                setTimeout(() => {
                    window.location.href = "/logout";
                }, 3000);
            } else {
                showNotification("<?php echo $lang['sec_passchange_error']; ?>", "#f44336");
            }
        })
        .catch(error => {
            console.error('Error:', error);
            alert('An unexpected error occurred');
        });
    });

    logoutButton.addEventListener('click', function () {
        const confirmModal = document.createElement('div');
        confirmModal.style.position = 'fixed';
        confirmModal.style.top = '50%';
        confirmModal.style.left = '50%';
        confirmModal.style.transform = 'translate(-50%, -50%)';
        confirmModal.style.width = '300px';
        confirmModal.style.padding = '20px';
        confirmModal.style.backgroundColor = 'rgba(0, 0, 0, 0.9)';
        confirmModal.style.boxShadow = '0 4px 8px rgba(0, 0, 0, 0.2)';
        confirmModal.style.borderRadius = '10px';
        confirmModal.style.zIndex = '1000';
        confirmModal.style.textAlign = 'center';

        const message = document.createElement('p');
        message.textContent = "<?php echo $lang['sec_logout_message']; ?>";
        message.style.marginBottom = '20px';
        confirmModal.appendChild(message);

        const buttonContainer = document.createElement('div');
        buttonContainer.style.display = 'flex';
        buttonContainer.style.justifyContent = 'space-between';

        const cancelButton = document.createElement('button');
        cancelButton.textContent = "<?php echo $lang['sec_logout_cancel']; ?>";
        cancelButton.style.backgroundColor = 'red';
        cancelButton.style.border = 'none';
        cancelButton.style.borderRadius = '5px';
        cancelButton.style.padding = '10px';
        cancelButton.style.cursor = 'pointer';
        cancelButton.style.flex = '1';
        cancelButton.style.marginRight = '10px';
        cancelButton.style.fontSize = '16px';
        cancelButton.addEventListener('click', () => {
            document.body.removeChild(confirmModal);
        });

        const confirmButton = document.createElement('button');
        confirmButton.textContent = "<?php echo $lang['sec_logout_logout']; ?>";
        confirmButton.style.backgroundColor = 'green';
        confirmButton.style.color = 'white';
        confirmButton.style.border = 'none';
        confirmButton.style.borderRadius = '5px';
        confirmButton.style.padding = '10px';
        confirmButton.style.cursor = 'pointer';
        confirmButton.style.flex = '1';
        confirmButton.style.fontSize = '16px';
        confirmButton.addEventListener('click', () => {
        document.body.removeChild(confirmModal);

        const userId = <?php echo $userId; ?>;

        fetch('/api/UPCD', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-TOKEN': csrfToken 
            },
            body: JSON.stringify({ userId: userId })
        })
        .then(response => response.json())
        .then(jsonData => {
            if (jsonData.success) {
                showNotification("<?php echo $lang['sec_logout_success']; ?>", "#4caf50");
            } else {
                if (jsonData.message === "<?php echo $lang['sec_logout_already']; ?>") {
                    showNotification("<?php echo $lang['sec_logout_already']; ?>", "#f44336");
                } else {
                    showNotification("<?php echo $lang['sec_logout_error']; ?>", "#f44336");
                }
            }
        })
        .catch(error => {
            console.error('Error during logout fetch:', error);
            showNotification("<?php echo $lang['sec_logout_error']; ?>", "#f44336");
        });
    });


        buttonContainer.appendChild(cancelButton);
        buttonContainer.appendChild(confirmButton);
        confirmModal.appendChild(buttonContainer);
        document.body.appendChild(confirmModal);
    });
});

</script>


</head>

<body>
    <div class="modern-card-container">
        <div class="modern-card">
        <h1 style="text-align: center; margin-bottom: 20px;"><?php echo $lang['sec_title']; ?>
        <span class="info-icon">i</span>
        </h1>
            <div class="button-container">
                <button id="emailButton" class="collapsible"><?php echo $lang['sec_email']; ?></button>
                <button id="passwordButton" class="collapsible"><?php echo $lang['sec_password']; ?></button>
                <button id="logoutButton" class="collapsible"><?php echo $lang['sec_logout']; ?></button>
            </div>

            <div id="emailContent" class="content">
    <form id="email-form" class="update-form">
        <div class="form-row">
        <div class="form-group">
   <label for="current-email"><?php echo $lang['sec_curr_email']; ?></label>
   <span id="current-email"><?php echo htmlspecialchars($currentEmail); ?></span>
</div>
            <div class="form-group">
                <label for="new-email"><?php echo $lang['sec_new_email']; ?></label>
                <input type="email" id="new-email" name="new_email" placeholder="<?php echo $lang['sec_email_placeholder']; ?>" required>
            </div>
        </div>
        <button type="button" class="update-btn" id="update-email-btn"><?php echo $lang['sec_save']; ?></button>
    </form>
</div>

<div id="passwordContent" class="content">
    <form id="password-form" class="update-form">
        <div class="form-row">
            <div class="form-group">
                <label for="new-password"><?php echo $lang['sec_newpassword']; ?></label>
                <input type="password" id="new-password" name="new_password" placeholder="<?php echo $lang['sec_password_placeholder']; ?>" required>
            </div>
            <div class="form-group">
                <label for="confirm-password"><?php echo $lang['sec_newpassword2']; ?></label>
                <input type="password" id="confirm-password" name="confirm_password" placeholder="<?php echo $lang['sec_password_placeholder2']; ?>" required>
            </div>
        </div>
        <button type="button" class="update-btn" id="update-password-btn"><?php echo $lang['sec_save']; ?></button>
    </form>
</div>
            <div id="pageContent">
                <h3 style="text-align: center; margin-bottom: 20px;"><?php echo $lang['sec_logins']; ?></h3>
                <div class="scrollable-table">
                    <table class="table zebra-stripes">
                        <thead>
                            <tr>
                                <th><?php echo $lang['name']; ?></th>
                                <th><?php echo $lang['ip']; ?></th>
                                <th><?php echo $lang['steamID']; ?></th>
                                <th><?php echo $lang['timestamp']; ?></th>
                                <th><?php echo $lang['type']; ?></th>
                                <th><?php echo $lang['status']; ?></th>
                            </tr>
                        </thead>
                        <tbody>
                        <?php foreach ($combinedLogins as $log): ?>
    <tr>
        <td>
            <?php 
            // Display $userName if the type is Website; otherwise, use the log's name
            echo htmlspecialchars(
                (isset($log['type']) && $log['type'] === $websiteLoginType) || 
                (isset($log['failed_login']) && $log['failed_login'] === $failedLoginType) 
                ? $userName 
                : ($userName ?? '-')
            ); 
            ?>
        </td>
        <td><?php echo htmlspecialchars($log['ipaddress']); ?></td>
        <td><?php echo htmlspecialchars($log['steamid'] ?? '-'); ?></td>
        <td><?php echo htmlspecialchars($log['datetime']); ?></td>
        <td>
            <?php 
            // Display Website login type if it's explicitly a Website login or a failed login
            echo htmlspecialchars(
                (isset($log['type']) && $log['type'] === $websiteLoginType) || 
                (isset($log['failed_login']) && $log['failed_login'] === $failedLoginType) 
                ? $websiteLoginType 
                : $log['type']
            ); 
            ?>
        </td>
        <td>
            <?php if (isset($log['failed_login']) && $log['failed_login'] === $failedLoginType): ?>
                <span class="badge badge-danger"><?php echo htmlspecialchars($failedLoginType); ?></span>
            <?php else: ?>
                <span class="badge badge-success"><?php echo $lang['success_web_login']; ?></span>
            <?php endif; ?>
        </td>
    </tr>
<?php endforeach; ?>

                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</body>

<?php
}


function func_addstyle() {
    ?>
        <script type="text/javascript" src="//cdn.jsdelivr.net/npm/slick-carousel@1.8.1/slick/slick.min.js"></script>
        <link rel="stylesheet" type="text/css" href="//cdn.jsdelivr.net/npm/slick-carousel@1.8.1/slick/slick.css"/>
        <link rel="stylesheet" type="text/css" href="//cdn.jsdelivr.net/npm/slick-carousel@1.8.1/slick/slick-theme.css"/>
        <link rel="stylesheet" type="text/css" href="<?php echo Utils::get_url("css/table.css?ver=13122");?>"/>
        <link rel="stylesheet" type="text/css" href="<?php echo Utils::get_url('css/banlist.css?ver=42');?>">
    <?php
}

Utils::header($lang['page_sec'], "func_addstyle");
Utils::body("func_mainpage");
Utils::footer();
?>