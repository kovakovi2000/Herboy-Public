<?php
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/Config.php");
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/includes/Utils.php");
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/includes/PunishmentStruck.php");

$userProfile = null;
if (isset($_SESSION['account'])) {
    $userProfile = unserialize($_SESSION['account']);
    if(!$userProfile || !$userProfile->PermLvl->isAdmin())
    {
        Utils::html_error(401);
        exit();
    }
}
else
{
    Utils::html_error(401);
    exit();
}

global $sql;
global $currentUser;
$currentUser = new UserProfile($pagelink[2], array(
    'id',
    'LastLoginID',
    'LastLoginIP',
    'LastLoginName',
    'RegisterName',
    'RegisterIP',
    'RegisterID',
    'RegisterDate',
    'Active',
    'PremiumPoint',
    'LastLoginDate',
    'PlayTime',
    'AdminLvL1'
));
$currDate = date('Y/m/d H:i:s', time());
?>
<form id="edit_form" onsubmit="event.preventDefault();">
    <div style="position: relative;padding: 10px;">
        <table style="undefined;table-layout: fixed;">
            <colgroup>
                <col style="width: 100px;">
                <col>
            </colgroup>
            <thead>
                <tr style="background-color: #d39e00;">
                    <th style="padding-left: 5px; font-size: 15px; text-align:center;color: black;" colspan="2">Játékos némítása</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td style="padding: 5px;">Név:</td>
                    <td style="padding: 5px;"><?php echo $currentUser->NameCard("float: left;")?></td>
                </tr>
                <tr>
                    <td style="padding: 5px;">SteamID:</td>
                    <td style="padding: 5px;"><?php echo $currentUser->LastLoginID ?></td>
                </tr>
                <tr>
                    <td style="padding: 5px;">Kezdete:</td>
                    <td style="padding: 5px;"><span id="mute_start_date"><?php echo $currDate ?></span></td>
                </tr>
                <tr>
                    <td style="padding: 5px;">Hossza:</td>
                    <td style="padding: 5px;"><input type="number" style="width: 50%; color: white; background-color: black;" value="" name='mute_length' id='mute_length' min="0"></td>
                </tr>
                <tr>
                    <td style="padding: 5px;">Lejárata:</td>
                    <td style="padding: 5px;"><span id="mute_expiry_date"></span></td>
                </tr>
                <tr>
                    <td style="padding: 5px;">Típus</td>
                    <td style="padding: 5px;">
                        <select style="width: 50%; color: white; background-color: black;height: 21px;" name='mute_type' id='mute_type'>
                            <option value="3">Voice+Chat</option>
                            <option value="2">Voice</option>
                            <option value="1">Chat</option>
                        </select>
                    </td>
                </tr>
                <tr>
                    <td style="padding: 5px;">Indok:</td>
                    <td style="padding: 5px;">
                        <select style="width: 50%; color: white; background-color: black;" name='mute_reason' id='mute_reason'></select>
                        <input type="text" id="custom_reason" name="custom_reason" style="width: 50%; color: white; background-color: black; display: none; margin-top: 5px;" placeholder="Kérlek írd be az indokot...">
                    </td>
                </tr>
                <script>
                // Define "Indok" options based on "Típus" selections
                const indokOptions = {
                    "3": [
                        { value: "Súgás", text: "Súgás" },
                        { value: "Apázás", text: "Apázás" },
                        { value: "Anyázás", text: "Anyázás" },
                        { value: "Hirdetés", text: "Hirdetés" },
                        { value: "Rasszizmus", text: "Rasszizmus" },
                        { value: "Szerverszidás", text: "Szerverszidás" },
                        { value: "Közzöségrombolás", text: "Közzöségrombolás" },
                        { value: "Zavaró tevékenység", text: "Zavaró tevékenység" },
                        { value: "Töménytelen káromkodás", text: "Töménytelen káromkodás" },
                        { value: "Egyéb", text: "Egyéb" } // Added "Egyéb" option
                    ],
                    "2": [
                        { value: "Zavaró tevékenység", text: "Zavaró tevékenység" },
                        { value: "16 alatt mikrofonhasználat", text: "16 alatt mikrofonhasználat" },
                        { value: "Egyéb", text: "Egyéb" } // Added "Egyéb" option
                    ],
                    "1": null // Will point to the same array as "Típus" 3
                };

                // Assign options for "Típus" 1 (Chat) to use the same as "Típus" 3 (Voice+Chat)
                indokOptions["1"] = indokOptions["3"];

                // Function to update "Indok" options based on selected "Típus"
                function updateIndokOptions() {
                    const muteType = $('#mute_type').val(); // Get selected Típus value
                    const indokSelect = $('#mute_reason'); // Get the Indok select element

                    // Clear existing options
                    indokSelect.empty();

                    // Add a placeholder option
                    indokSelect.append(new Option("Válassz indokot", ""));

                    // Add appropriate options for the selected Típus
                    indokOptions[muteType].forEach(option => {
                        indokSelect.append(new Option(option.text, option.value));
                    });

                    // Hide custom reason input when options are updated
                    $('#custom_reason').hide().val(''); // Hide and clear custom reason input
                }

                // Attach event listener to "Típus" dropdown
                $('#mute_type').on('change', updateIndokOptions);

                // Initialize options on page load
                $(document).ready(updateIndokOptions);

                // Show/hide custom reason input based on selected Indok
                $('#mute_reason').on('change', function() {
                    if ($(this).val() === "Egyéb") {
                        $('#custom_reason').show(); // Show custom reason input
                    } else {
                        $('#custom_reason').hide(); // Hide custom reason input
                        $('#custom_reason').val(''); // Clear the custom input
                    }
                });
                </script>
                <tr>
                    <td style="padding: 5px;">Admin neve:</td>
                    <td style="padding: 5px;"><?php echo Account::$UserProfile->NameCard("float: left;")?></td>
                </tr>
            </tbody>
        </table>
            <input type="submit" id="mute_submit_button" name="save_edit" value="Némítás" class="btn btn-block btn-lg btn-secondary" disabled>
    </div>
</form>

<script>
$(function() {
    // Hozzáadjuk az eseménykezelőt a formhoz
    $('#edit_form').on('submit', function(e) {
        e.preventDefault(); // Megakadályozza az alapértelmezett form elküldést

        const muteLength = $('#mute_length').val().trim(); // Kitiltás hossza
        const muteType = $('#mute_type').val().trim(); // Indok
        let reason = $('#mute_reason').val().trim(); // Indok

        // Check for custom reason
        if (reason === "Egyéb") {
            reason = $('#custom_reason').val().trim(); // If "Egyéb" is selected, use the custom reason
        }

        const formData = new URLSearchParams();
        formData.append('steamID', '<?php echo $currentUser->LastLoginID ?>');
        formData.append('muteLength', muteLength); // Kitiltás hossza
        formData.append('muteType', muteType); // Kitiltás hossza
        formData.append('reason', reason);
        formData.append('AdminID', <?php echo json_encode(Account::$UserProfile->LastLoginID); ?>); // Ensure this outputs a valid JS value
        formData.append('AdminLvL', <?php echo json_encode(Account::$UserProfile->PermLvl->isAdmin()); ?>); // Ensure this outputs a valid JS value

        fetch('/api/sMute', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded'
            },
            body: formData.toString() // Adatok URL-encoded formátumban
        })
        .then(response => response.text()) // Válasz szövegként történő olvasása
        .then(data => {
            if (data.includes('success')) {
                console.log(data);
                showNotification('Sikeresen némítottad a játékost!', '#28a745');
                setTimeout(() => {
                    location.reload();
                }, 3000);
            } 
            else if (data.includes('alreadymuted')) {
                // Reguláris kifejezés a szám keresésére
                const match = data.match(/alreadymuted.*?(\d+)/);
                
                if (match && match[1]) {
                    const variableNumber = match[1];
                    showNotification(`Már van egy aktív némítása: ${variableNumber}`, '#dc3545');
                    setTimeout(() => {
                        location.reload();
                    }, 3000);
                } 
            }   
            else {
                alert('Hiba történt: ' + data);
            }
        })
        .catch(error => {
            console.error('Fetch error:', error);
        });
    });

    // Initialize expiration date text
    $('#mute_expiry_date').text('Nincs megadva');

    // Eseményfigyelő a mute_length mező változásaira
    $('#mute_length').on('input', function() {
        const banLength = parseInt($(this).val(), 10); // A beírt érték, percekben
        const currentDate = new Date(); // Jelenlegi dátum

        // Frissítsük a "Kitiltás kezdete" mezőt a jelenlegi időre
        $('#mute_start_date').text(currentDate.toLocaleString());

        if (isNaN(banLength) || banLength < 0) {
            $('#mute_expiry_date').text("Érvénytelen időtartam");
        } else if (banLength === 0) {
            $('#mute_expiry_date').text("Soha");
        } else {
            const expiryDate = new Date(currentDate.getTime() + banLength * 60000); // Hozzáadott percek (banLength * 60 * 1000 ms)
            $('#mute_expiry_date').text(expiryDate.toLocaleString()); // Formázott dátum
        }

        checkFormCompletion(); // Ellenőrizzük a mezők kitöltöttségét
    });

    // Funkció a form kitöltöttségének ellenőrzésére
    function checkFormCompletion() {
        const reason = $('#mute_reason').val().trim(); // Indok mező
        const banLength = $('#mute_length').val().trim(); // Kitiltás hossza

        // Ellenőrizzük, hogy mindkét mező ki van-e töltve
        if (reason !== "" && banLength !== "" && parseInt(banLength, 10) >= 0) {
            // Ha mindkét mező kitöltött, a gomb kattinthatóvá és pirossá válik
            $('#mute_submit_button').prop('disabled', false);
            $('#mute_submit_button').removeClass('btn-secondary').addClass('btn-warning');
        } else {
            // Ha valamelyik mező üres vagy érvénytelen, a gomb szürke és nem kattintható lesz
            $('#mute_submit_button').prop('disabled', true);
            $('#mute_submit_button').removeClass('btn-warning').addClass('btn-secondary');
        }
    }

    // Eseményfigyelő az "Indok" mezőhöz is
    $('#mute_reason').on('input', function() {
        checkFormCompletion(); // Ellenőrizzük a mezők kitöltöttségét
    });
});
</script>
