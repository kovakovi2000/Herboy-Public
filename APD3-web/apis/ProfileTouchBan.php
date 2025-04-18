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
                <tr style="background-color: #dc3545;">
                    <th style="padding-left: 5px; font-size: 15px; text-align:center;" colspan="2">Játékos kitiltása</th>
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
                    <td style="padding: 5px;">Kitiltás kezdete:</td>
                    <td style="padding: 5px;"><span id="ban_start_date"><?php echo $currDate ?></span></td>
                </tr>
                <tr>
                    <td style="padding: 5px;">Kitiltás hossza:</td>
                    <td style="padding: 5px;"><input type="number" style="width: 50%; color: white; background-color: black;" value="" name='ban_length' id='ban_length'></td>
                </tr>
                <tr>
                    <td style="padding: 5px;">Kitiltás lejárata:</td>
                    <td style="padding: 5px;"><span id="ban_expiry_date"></span></td>
                </tr>
                <tr>
                    <td style="padding: 5px;">Indok:</td>
                    <td style="padding: 5px;">
                        <select style="width: 50%; color: white; background-color: black;" name='ban_reason' id='ban_reason'>
                            <option value="">Válassz indokot</option>
                            <option value="Csalás">Csalás</option>
                            <option value="Közösségtisztítás">Közösségtisztítás</option>
                            <option value="CT kezdőn kemp">CT kezdőn kemp</option>
                            <option value="T kezdőn 1:30 után">T kezdőn 1:30 után</option>
                            <option value="Demó + képek csoportba">Demó + képek csoportba</option>
                            <option value="Egyéb">Egyéb</option>
                        </select>
                        <input type="text" id="custom_reason" name="custom_reason" style="width: 50%; color: white; background-color: black; display: none; margin-top: 5px;" placeholder="Kérlek írd be az indokot...">
                    </td>
                </tr>
                <tr>
                    <td style="padding: 5px;">Admin neve:</td>
                    <td style="padding: 5px;"><?php echo Account::$UserProfile->NameCard("float: left;")?></td>
                </tr>
            </tbody>
        </table>
        <input type="submit" id="ban_submit_button" name="save_edit" value="Kitiltás" class="btn btn-block btn-lg btn-secondary" disabled>
    </div>
</form>

<script>
$(function() {
    $('#ban_expiry_date').text('Nincs megadva');

    // Initialize reason selection
    $('#ban_reason').on('change', function() {
        if ($(this).val() === "Egyéb") {
            $('#custom_reason').show(); // Show custom reason input
        } else {
            $('#custom_reason').hide(); // Hide custom reason input
            $('#custom_reason').val(''); // Clear the custom input
        }
        checkFormCompletion(); // Check form completion when reason changes
    });

    $('#ban_length').on('input', function() {
        const banLength = parseInt($(this).val(), 10);
        const currentDate = new Date();

        $('#ban_start_date').text(currentDate.toLocaleString());

        if (isNaN(banLength) || banLength < 0) {
            $('#ban_expiry_date').text('Érvénytelen időtartam');
        } else if (banLength === 0) {
            $('#ban_expiry_date').text('Soha');
        } else {
            const expiryDate = new Date(currentDate.getTime() + banLength * 60000);
            $('#ban_expiry_date').text(expiryDate.toLocaleString());
        }

        checkFormCompletion();
    });

    function checkFormCompletion() {
        const reason = $('#ban_reason').val().trim();
        const banLength = $('#ban_length').val().trim();

        // Include custom reason if "Egyéb" is selected
        let isValidReason = reason !== "" || (reason === "Egyéb" && $('#custom_reason').val().trim() !== "");
        
        if (isValidReason && banLength !== "" && parseInt(banLength, 10) >= 0) {
            $('#ban_submit_button').prop('disabled', false);
            $('#ban_submit_button').removeClass('btn-secondary').addClass('btn-danger');
        } else {
            $('#ban_submit_button').prop('disabled', true);
            $('#ban_submit_button').removeClass('btn-danger').addClass('btn-secondary');
        }
    }

    $('#ban_reason').on('input', checkFormCompletion); // Check completion when reason is changed

    $('#edit_form').on('submit', function(e) {
        e.preventDefault(); // Prevent default form submission

        const banLength = $('#ban_length').val().trim(); // Ban length
        const reason = $('#ban_reason').val().trim(); // Selected reason

        // Check for custom reason
        let finalReason = reason;
        if (reason === "Egyéb") {
            finalReason = $('#custom_reason').val().trim(); // Use custom reason if "Egyéb" is selected
        }

        const formData = new URLSearchParams();
        formData.append('steamID', '<?php echo $currentUser->LastLoginID ?>');
        formData.append('banLength', banLength);
        formData.append('reason', finalReason);
        formData.append('AdminID', <?php echo json_encode(Account::$UserProfile->LastLoginID); ?>);
        formData.append('AdminLvL', <?php echo json_encode(Account::$UserProfile->PermLvl->isAdmin()); ?>);

        fetch('/api/sBan', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded'
            },
            body: formData.toString()
        })
        .then(response => response.text())
        .then(data => {
            if (data.includes('success')) {
                showNotification('Sikeresen kitiltottad a játékost!', '#28a745'); // Green color for success
                setTimeout(() => {
                    location.reload();
                }, 3000); // Reload after notification disappears
            } 
            else if (data.includes('alreadybanned')) {
                const match = data.match(/alreadybanned.*?(\d+)/);
                if (match && match[1]) {
                    const variableNumber = match[1];
                    showNotification(`Már van egy aktív kitiltása: ${variableNumber}`, '#dc3545'); // Red color for error

                    setTimeout(() => {
                        location.reload();
                    }, 3000);
                }
            } else {
                location.reload();
                alert('Hiba történt: ' + data);
            }
        })
        .catch(error => {
            console.error('Fetch error:', error);
        });
    });
});
</script>
