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

    if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['submitComment'])) {

    $author = trim($_POST['author']);
    $aboutUser = trim($_POST['aboutUser']);
    $userid = filter_input(INPUT_POST, 'userid', FILTER_VALIDATE_INT);
    $comment = htmlspecialchars(trim($_POST['comment']), ENT_QUOTES);
    $date = date('Y-m-d H:i:s');

    if ($userid && !empty($author) && !empty($aboutUser) && !empty($comment)) {

        $stmt = $sql->prepare("
            INSERT INTO `profile_comments` (`author`, `aboutUser`, `userid`, `comment`, `date`)
            VALUES (?, ?, ?, ?, ?)
        ");
        
        if ($stmt) {
            $stmt->bind_param("ssiss", $author, $aboutUser, $userid, $comment, $date);
            $insertResult = $stmt->execute();

            if ($insertResult) {
                $_SESSION['notification'] = ['message' => 'Megjegyzés sikeresen hozzáadva!', 'color' => 'green'];
            } else {
                $_SESSION['notification'] = ['message' => 'Hiba történt! Keresd fel zyX-et.', 'color' => 'red'];
            }
            $stmt->close();
        } else {
            $_SESSION['notification'] = ['message' => 'Hiba történt a kérés feldolgozásakor.', 'color' => 'red'];
        }
    } else {
        $_SESSION['notification'] = ['message' => 'Kérlek, töltsd ki az összes mezőt!', 'color' => 'red'];
    }
}

if (isset($viewedUserId) && $viewedUserId > 0) {
    $commentsQuery = "SELECT `author`, `comment`, `date` FROM `profile_comments` WHERE `userid` = ? ORDER BY `date` DESC";
    $stmt = $sql->prepare($commentsQuery);

    if ($stmt) {
        $stmt->bind_param("i", $viewedUserId);
        $stmt->execute();
        $commentsResult = $stmt->get_result();

        $comments = [];
        while ($row = $commentsResult->fetch_assoc()) {
            $comments[] = $row;
        }
        $stmt->close();
    }
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
?>



<?php if (isset($viewedUserId) && $viewedUserId > 0) { ?>
    <script>
        function showEditModal() {
            document.getElementById("edit-modal").style.display = "block";
        }

        function closeEditModal() {
            document.getElementById("edit-modal").style.display = "none";
        }

        function showCommentModal() {
            document.getElementById("comment-modal").style.display = "block";
        }

        function closeCommentModal() {
            document.getElementById("comment-modal").style.display = "none";
        }
        
        function openTab(event, tabId) {
            const tabContents = document.getElementsByClassName("tab-content");
            for (let i = 0; i < tabContents.length; i++) {
                tabContents[i].style.display = "none";
            }
            const tabButtons = document.getElementsByClassName("tab-button");
            for (let i = 0; i < tabButtons.length; i++) {
                tabButtons[i].classList.remove("active");
            }
            document.getElementById(tabId).style.display = "block";
            if (event) {
                event.currentTarget.classList.add("active");
            }
        }

        document.addEventListener("DOMContentLoaded", function () {
            openTab(null, 'existing-comments');
            const defaultButton = document.querySelector(".tab-button");
            if (defaultButton) {
                defaultButton.classList.add("active");
            }
        });

        function updateCharacterCount() {
    const commentTextarea = document.getElementById('comment');
    const charCountDisplay = document.getElementById('charCount');
    const maxLength = commentTextarea.getAttribute('maxlength');
    const currentLength = commentTextarea.value.length;
    
    const remainingCharacters = maxLength - currentLength;
    charCountDisplay.textContent = `${remainingCharacters} karakter van hátra`;

    // Optional: Change color based on remaining characters
    if (remainingCharacters < 20) {
        charCountDisplay.style.color = 'red'; // Change to red when less than 20 characters are left
    } else {
        charCountDisplay.style.color = 'white'; // Default color
    }
}

// Initialize the character count on page load
document.addEventListener("DOMContentLoaded", updateCharacterCount);

    </script>

    <?php
    if (isset($userProfile->PermLvl) && $userProfile->PermLvl->isAdmin() && $loggedInAdminLvL < 4) {
        $commentCheckQuery = "SELECT COUNT(*) AS comment_count FROM `profile_comments` WHERE `userid` = ?";
        $stmt = $sql->prepare($commentCheckQuery);
        
        if ($stmt) {
            $stmt->bind_param("i", $viewedUserId);
            $stmt->execute();
            $commentCheckResult = $stmt->get_result();
            $commentCount = $commentCheckResult ? $commentCheckResult->fetch_assoc()['comment_count'] : 0;
            $stmt->close();
            $buttonStyle = ($commentCount > 0) ? '' : 'style="background-color: rgba(80, 80, 80, 0.4); filter: grayscale(100%) !important;"';
    ?>
        <input id="comment-btn" type="button" value="📝 <?php echo $lang['profile_comment']; ?> 📝" class="btn btn-xs btn-primary" onclick="showCommentModal();" <?php echo $buttonStyle; ?>>
    <?php
    }
    ?>

    <div id="comment-modal" class="modal">
        <div class="modal-content comment-modal-content">
            <span class="close" onclick="closeCommentModal()">&times;</span>
            <h2><?php echo $currentUser->LastLoginName; ?> megjegyzései</h2>

            <div class="tab-container">
                <button class="tab-button active" onclick="openTab(event, 'existing-comments')">Megjegyzések</button>
                <button class="tab-button" onclick="openTab(event, 'new-comment')">Új Megjegyzés Írása</button>
            </div>

            <div id="existing-comments" class="tab-content active">
    <?php
    if (isset($viewedUserId) && $viewedUserId > 0) {
        $commentQuery = "
            SELECT `author`, `comment`, `date`
            FROM `profile_comments`
            WHERE `userid` = ?
            ORDER BY `date` DESC
        ";
        $stmt = $sql->prepare($commentQuery);
        
        if ($stmt) {
            $stmt->bind_param("i", $viewedUserId);
            $stmt->execute();
            $commentResult = $stmt->get_result();
            if ($commentResult && $commentResult->num_rows > 0) {
                echo '<div class="scrollable-table">';
                echo '<table>';
                echo '<thead>';
                echo '<tr><th>Időpont</th><th>Név</th><th>Megjegyzés</th></tr>';
                echo '</thead>';
                echo '<tbody>';
                while ($commentRow = $commentResult->fetch_assoc()) {
                    echo '<tr>';
                    echo '<td class="comment-date">' . htmlspecialchars($commentRow['date'], ENT_QUOTES) . '</td>';
                    echo '<td>' . htmlspecialchars($commentRow['author'], ENT_QUOTES) . '</td>';
                    echo '<td>' . htmlspecialchars($commentRow['comment'], ENT_QUOTES) . '</td>';
                    echo '</tr>';
                }
                echo '</tbody>';
                echo '</table>';
                echo '</div>';
            } else {
                echo '<p>Nincsenek megjegyzések.</p>';
            }
            $stmt->close();
        }
    }
    ?>
</div>

<div id="new-comment" class="tab-content">
    <form id="comment-form" method="POST">
        <input type="hidden" id="userid" name="userid" value="<?php echo htmlspecialchars($viewedUserId, ENT_QUOTES); ?>" readonly>
        
		<div class="modal-row">
			<label for="author">Író:</label>
			<input type="text" id="author" name="author" 
				value="<?php echo htmlspecialchars(!empty($userProfile->LastLoginName) ? $userProfile->LastLoginName : $userProfile->RegisterName, ENT_QUOTES); ?>" readonly>
		</div>

		<div class="modal-row">
			<label for="aboutUser">Róla:</label>
			<input type="text" id="aboutUser" name="aboutUser" 
				value="<?php echo htmlspecialchars(!empty($currentUser->LastLoginName) ? $currentUser->LastLoginName : $currentUser->RegisterName, ENT_QUOTES); ?>" readonly>
		</div>
				
        <div class="modal-row">
            <label for="comment">Megjegyzés:</label>            <div id="charCount">250 karakter van hátra</div>
            <textarea id="comment" name="comment" rows="4" placeholder="Ide írhatod a megjegyzésed..." required maxlength="250" oninput="updateCharacterCount()"></textarea>
        </div>
        
        <div class="modal-buttons comment-buttons">
            <button type="submit" name="submitComment" class="modal-button comment-button">Megjegyzés Küldése</button>
            <button type="button" class="modal-button-cancel cancel-comment" onclick="closeCommentModal()">Bezárás</button>
        </div>
    </form>
</div>
</div>
</div>
<?php } ?>


<style>
   .modal-row {
    margin-bottom: 15px; /* Space between fields */
}

.modal-row label {
    display: block; /* Labels are block elements for better layout */
    margin-bottom: 5px; /* Space between label and input */
    font-weight: bold; /* Make label text bold */
}

.modal-row input[type="text"],
.modal-row textarea {
    box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1); /* Subtle shadow for depth */
    transition: border-color 0.3s ease; /* Smooth border color transition */
}

.modal-row input[type="text"]:focus,
.modal-row textarea:focus {
    border-color: #007BFF; /* Highlight border on focus */
    outline: none; /* Remove outline */
}

.comment-buttons {
    display: flex; /* Flexbox for button alignment */
    justify-content: space-between; /* Space between buttons */
}

.comment-button {
    padding: 10px 20px; /* Padding for buttons */
    background-color: #007BFF; /* Button background color */
    color: white; /* Button text color */
    border: none; /* No border */
    border-radius: 5px; /* Rounded corners */
    cursor: pointer; /* Pointer cursor on hover */
    transition: background-color 0.3s ease; /* Smooth background color transition */
}

.comment-button:hover {
    background-color: #0056b3; /* Darker blue on hover */
}

.cancel-comment {
    background-color: #f44336; /* Red background for cancel button */
}

.cancel-comment:hover {
    background-color: #c62828; /* Darker red on hover */
}
    textarea {
        resize: none;
        width: calc(100% - 130px);
        color: black;
    }
    select {
        color: #333;
        background-color: #f9f9f9;
    }

    select:hover,
    select:focus {
        border-color: #007BFF;
        outline: none;
    }
    .comment-modal-content {
        position: relative;
        padding: 20px;
        width: 100%;
        max-width: 1000px;
    }

    .tab-container {
        display: flex;
        margin-bottom: 10px;
    }

    .tab-button {
        flex: 1;
        padding: 10px;
        cursor: pointer;
        background-color: #333;
        border: none;
        outline: none;
    }

    .tab-button.active {
        background-color: #007BFF;
        color: white;
    }

    .tab-content {
        display: none;
    }

    .tab-content.active {
        display: block;
    }

    .comment-row {
        margin-bottom: 15px;
    }

    .comment {
        padding: 10px;
        border: 1px solid #ccc;
        border-radius: 5px;
    }

    .comment p {
        margin: 0;
    }
    .comment-date {
    white-space: nowrap; /* Prevent the date from breaking onto a new line */
    overflow: hidden; /* Hide overflow if necessary */
    text-overflow: ellipsis; /* Optional: add ellipsis if the text is too long */
}
    .scrollable-table {
        max-height: 300px; /* Set a maximum height */
        overflow-y: auto;  /* Enable vertical scrolling */
        border: 1px solid #ccc; /* Optional border for better visualization */
        border-radius: 5px; /* Optional rounded corners */
    }

    .scrollable-table table {
        width: 100%; /* Full width */
        border-collapse: collapse; /* Remove space between cells */
    }

    .scrollable-table th, .scrollable-table td {
        padding: 10px; /* Cell padding */
        text-align: left; /* Align text to the left */
        border-bottom: 1px solid #ddd; /* Bottom border for cells */
        max-width: 300px; /* Set a maximum width for table cells */
    overflow-wrap: break-word; /* Break long words */
    }

    .scrollable-table th {

        color: white; /* Header text color */
    }

    .scrollable-table tr:hover {
        background-color:  #007BFF; /* Highlight row on hover */
    }
</style>
<?php
}}
?>