<?php
$userProfile = null;
$isAdmin = false;

if (isset($_SESSION['account'])) {
    $userProfile = unserialize($_SESSION['account']);
    
    if ($userProfile && isset($userProfile->PermLvl) && $userProfile->PermLvl->isAdmin()) {
        $isAdmin = true;
        $lastLoginName = $userProfile->LastLoginName ?? 'UnknownAdmin';
        $userId = $userProfile->id ?? 0;
        $userIP = $userProfile->LastLoginIP ?? $_SERVER['REMOTE_ADDR'];
    }
}


if ($isAdmin) {

$currentURL = $_SERVER['REQUEST_URI'];
$urlParts = explode('/', $currentURL);
$userIdToView = isset($urlParts[2]) ? filter_var($urlParts[2], FILTER_VALIDATE_INT) : null;

$viewedUserId = null;
$viewedUserSteam = "";
$viewedUserPP = "";
$viewedUserEmail = "A felhasználó nem adott meg email címet.";
$adminLvL = 0;
$loggedInAdminLvL = 0;

global $sql;

if ($userIdToView) {
    $stmt = $sql->prepare("
        SELECT `id`, `LastLoginID`, `RegisterID`, `PremiumPoint`, `AdminLvL1`, `Email`
        FROM `herboy_regsystem`
        WHERE `id` = ?
        LIMIT 1
    ");
    $stmt->bind_param("i", $userIdToView);
    $stmt->execute();
    $result = $stmt->get_result();
    $userData = $result->fetch_assoc();
    $stmt->close();

    if ($userData) {
        $viewedUserId = htmlspecialchars($userData['id'], ENT_QUOTES);
        $viewedUserSteam = htmlspecialchars(!empty($userData['LastLoginID']) ? $userData['LastLoginID'] : $userData['RegisterID'], ENT_QUOTES);
        $viewedUserPP = htmlspecialchars($userData['PremiumPoint'], ENT_QUOTES);
        $viewedUserEmail = htmlspecialchars($userData['Email'] ?? '', ENT_QUOTES);
        $adminLvL = intval($userData['AdminLvL1']);
    } else {
        $viewedUserId = "Nem található UserID.";
        $viewedUserEmail = "A felhasználó nem adott meg email címet.";
    }
}

if (isset($userProfile)) {
    $stmt = $sql->prepare("
        SELECT `AdminLvL1`
        FROM `herboy_regsystem`
        WHERE `id` = ?
        LIMIT 1
    ");
    $stmt->bind_param("i", $userId);
    $stmt->execute();
    $resultLoggedInUser = $stmt->get_result();
    if ($resultLoggedInUser) {
        $loggedInUserData = $resultLoggedInUser->fetch_assoc();
        $loggedInAdminLvL = intval($loggedInUserData['AdminLvL1']);
    }
    $stmt->close();
}

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['updatePremiumPoint'])) {
    $updatedUserId = filter_var($_POST['userID'], FILTER_VALIDATE_INT);
    $updatedPremiumPoint = filter_var($_POST['PP'], FILTER_VALIDATE_INT);
    $updatedEmail = filter_var(trim($_POST['Email']), FILTER_SANITIZE_EMAIL);
    $newPassword = isset($_POST['newPassword']) ? trim($_POST['newPassword']) : '';
    $updatedAdminLvL1 = filter_var($_POST['adminLvL1'], FILTER_VALIDATE_INT);

    $updateFields = [];
    $updateParams = [];

    $updateFields[] = "`PremiumPoint` = ?";
    $updateParams[] = $updatedPremiumPoint;

// Check if the email is provided
if ($updatedEmail !== '') {
    $updateFields[] = "`Email` = ?";
    $updateParams[] = $updatedEmail;
} else {
    // Set email to NULL if the user has not provided an email
    $updateFields[] = "`Email` = NULL";
}

    $updateFields[] = "`AdminLvL1` = ?";
    $updateParams[] = $updatedAdminLvL1;

    if (!empty($newPassword)) {
        $salt = Config::$secret_password_salt;
        $hashedPassword = hash('sha3-512', hash('sha3-512', $newPassword . $salt));
        $updateFields[] = "`Password` = ?";
        $updateParams[] = $hashedPassword;
    }

    $whereClause = "WHERE `id` = ? LIMIT 1";
    $updateParams[] = $updatedUserId;

    $updateQuery = "
        UPDATE `herboy_regsystem`
        SET " . implode(", ", $updateFields) . " " . $whereClause
    ;

    $stmt = $sql->prepare($updateQuery);
    $stmt->bind_param(str_repeat("s", count($updateParams)), ...$updateParams);
    $updateResult = $stmt->execute();
    $stmt->close();

    if ($updateResult) {
        $_SESSION['notification'] = ['message' => 'Sikeres változtatás, kérlek várj!', 'color' => 'green'];
    } else {
        $_SESSION['notification'] = ['message' => 'Hiba történt! Keresd fel zyX-et.', 'color' => 'red'];
    }

// Logging part
$logFile = $_SERVER['DOCUMENT_ROOT'] . '/logs/szerk/szerk.log';
$logEntry = "==========================\n";
$logEntry .= "🕒 " . date("Y-m-d H:i:s") . "\n";
$logEntry .= "📌 Felhasználó Módosítás\n";
$logEntry .= "🔄 User ID: #$updatedUserId módosítva #$userId által.\n";
$logEntry .= "--------------------------\n";

// PrémiumPont
if ($updatedPremiumPoint !== intval($viewedUserPP)) {
    $logEntry .= "💎 Módosított PrémiumPont: $updatedPremiumPoint\n";
} else {
    $logEntry .= "💎 PrémiumPont: Nem történt módosítás.\n";
}

// Email
if ($updatedEmail !== $viewedUserEmail) {
    $logEntry .= "📧 Módosított Email: $updatedEmail\n";
} else {
    $logEntry .= "📧 Email: Nem történt módosítás.\n";
}

// AdminLvL
if ($updatedAdminLvL1 !== intval($adminLvL)) {
    $logEntry .= "🔒 Jogosultság módosítva: $updatedAdminLvL1. szintre.\n";
} else {
    $logEntry .= "🔒 Jogosultság: Nem történt módosítás.\n";
}

// Password
if (!empty($newPassword)) {
    $logEntry .= "🔑 Módosított jelszó: Módosítva.\n";
} else {
    $logEntry .= "🔑 Jelszó: Nem történt módosítás.\n";
}

$logEntry .= "==========================\n\n";

// Append the log entry to the log file
file_put_contents($logFile, $logEntry, FILE_APPEND);
}

if (isset($_SESSION['notification'])) {
    $message = htmlspecialchars($_SESSION['notification']['message'], ENT_QUOTES);
    $color = htmlspecialchars($_SESSION['notification']['color'], ENT_QUOTES);

    echo '<script>
        window.addEventListener("DOMContentLoaded", function() {
            showNotification("' . $message . '", "' . $color . '");
            setTimeout(function() {
                window.location.href = "' . htmlspecialchars($_SERVER['REQUEST_URI'], ENT_QUOTES) . '";
            }, 3000);
        });
    </script>';

    unset($_SESSION['notification']);
}

if (isset($userProfile->PermLvl) && $userProfile->PermLvl->isAdmin() && $loggedInAdminLvL < 4) {
?>
    <input id="profile-edit-btn" type="button" value="&#128272; <?php echo $lang['profile_edit']; ?> &#128272;" class="btn btn-xs btn-primary" onclick="showEditModal();">

    <div id="edit-modal" class="modal">
        <div class="modal-content">
            <span class="close" onclick="closeEditModal()">&times;</span>
            <h2>Felhasználó Szerkesztése</h2>

            <form method="POST" action="">
                <div class="modal-row">
                    <label for="userID">UserID:</label>
                    <input type="text" id="userID" name="userID" value="<?php echo $viewedUserId; ?>" readonly>
                </div>
                <div class="modal-row">
                    <label for="SteamID">SteamID:</label>
                    <input type="text" id="SteamID" name="SteamID" value="<?php echo $viewedUserSteam; ?>" readonly>
                </div>
                <div class="modal-row">
                    <label for="Email">Email:</label>
                    <input type="email" id="Email" name="Email" value="<?php echo $viewedUserEmail; ?>">
                </div>
                <div class="modal-row">
                    <label for="newPassword">Új Jelszó:</label>
                    <input type="password" id="newPassword" name="newPassword" placeholder="Új jelszó (ha változtatni szeretnél)">
                </div>
                <div class="modal-row">
                    <label for="PP">PrémiumPont:</label>
                    <input type="number" id="PP" name="PP" value="<?php echo $viewedUserPP; ?>" required>
                </div>
                <div class="modal-row">
                    <label for="adminLvL1">Jogosultságok:</label>
                    <select id="adminLvL1" name="adminLvL1">
                        <option value="2" <?php echo $adminLvL == 2 ? 'selected' : ''; ?>>Tulajdonos</option>
                        <option value="1" <?php echo $adminLvL == 1 ? 'selected' : ''; ?>>Fejlesztő</option>
                        <option value="3" <?php echo $adminLvL == 3 ? 'selected' : ''; ?>>FőAdmin</option>
                        <option value="4" <?php echo $adminLvL == 4 ? 'selected' : ''; ?>>Admin</option>
                        <option value="0" <?php echo $adminLvL == 0 ? 'selected' : ''; ?>>Játékos</option>
                    </select>
                </div>

                <div class="modal-buttons">
                    <button type="submit" name="updatePremiumPoint" class="modal-button">Szerkesztés</button>
                    <button type="button" class="modal-button-cancel" onclick="closeEditModal()">Bezárás</button>
                </div>
            </form>
        </div>
    </div>
<?php
}}
?>
