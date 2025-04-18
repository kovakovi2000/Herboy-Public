<?php
global $lang;
if(empty($pagelink[1]) && $pagelink[1] != 0 && Account::IsLogined()) $pagelink[1] = Account::$UserProfile->id;

if(!is_numeric($pagelink[1]))
    Utils::html_error(404);
global $currentUser;
$NeededColumList = array(
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
    'AdminLvL1',
);
$currentUser = new UserProfile($pagelink[1], $NeededColumList);
if(!$currentUser->SuccessInit())
    Utils::html_error(404);

include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/includes/PunishmentStruck.php");
global $sql;
$is_banned = mysqli_fetch_array($sql->query("SELECT count(`bid`) as 'TotalCount' FROM `".Config::$t_AmxBan_name."` WHERE (`player_id` LIKE '{$currentUser->LastLoginID}' OR `player_ip` LIKE '{$currentUser->LastLoginIP}') AND `expired` = 0 LIMIT 1;"))['TotalCount'];
$is_muted = mysqli_fetch_array($sql->query("SELECT count(`bid`) as 'TotalCount' FROM `".Config::$t_AmxMute_name."` WHERE (`player_id` LIKE '{$currentUser->LastLoginID}' OR `player_ip` LIKE '{$currentUser->LastLoginIP}') AND `expired` = 0 LIMIT 1;"))['TotalCount'];

function func_profile()
{   global $lang;
    global $is_banned;
    global $currentUser;
    global $sql;

    if (isset($_SESSION['account'])) {
        $userProfile = unserialize($_SESSION['account']);
        $userId = $userProfile->id ?? 'Ismeretlen ID';
    } else {
        $userProfile = null;
    }


    ?>
    <div class="modern-card-container">
        <div class="modern-card">
            <div style="height: 100%; width: 100%;">
                <div class="modern-card-body">
                    <div class="profile-details">
                    <?php include($_SERVER['DOCUMENT_ROOT'] . "/apis/ProfileSZButton.php"); ?>
                        <?php $currentUser->ProfilePic(150, 2, $is_banned); ?>
                        <p class="profile-name" >
                            <?php 
                                $lastLoginName = $currentUser->LastLoginName ?? '';
                                $registerName = $currentUser->RegisterName ?? '';
                                $displayName = !empty($lastLoginName) ? $lastLoginName : $registerName;
                                print htmlspecialchars($displayName, ENT_QUOTES);
                                aliasbox();
                            ?>
                        </p>
                        <?php
                            echo $currentUser->NameCard("font-size: 90%;", false, $is_banned, 1, true);
                            echo "</br>";
                            if($currentUser->IsSteam())
                            {
                                $currentUser->Steam->request_Bans();
                                if(isset($currentUser->Steam->DaySinceLastBan))
                                {
                                    ?>
                                        <p style="color: #a94847;">
                                        <?php if($currentUser->Steam->Vac > 0): ?>
    <?php echo ($currentUser->Steam->Vac > 2 ? $lang['multiple'] : $currentUser->Steam->Vac) . " " . $lang['vac_bans'] . "</br>"; ?>
<?php endif; ?>
<?php if($currentUser->Steam->GameBan > 0): ?>
    <?php echo "{$currentUser->Steam->GameBan} " . $lang['game_bans'] . "</br>"; ?>
<?php endif; ?>
<?php if($currentUser->Steam->Vac > 0 || $currentUser->Steam->GameBan > 0) echo $currentUser->Steam->DaySinceLastBan . " " . $lang['steam_bans']; ?>

                                        </p>
                                    <?php
                                }
                                ?><p><?php echo $lang['steam_playedtime']; ?></br><?php
                                $currentUser->Steam->request_Playtime();
                                if($currentUser->Steam->PlayMinute > 0) 
                                    echo Utils::SecToClock($currentUser->Steam->PlayMinute*60, true);
                                else
                                    echo $lang['private_info'];
                                echo "</p>";
                            }
                        ?>
                        <!-- PLACEHORDER FOR RANK ICONS -->
                        </br>
                        <p><?php echo $lang['pp_point']; ?></br><span style="color: #ff00ff;"><?php echo $currentUser->PremiumPoint; ?></span></p>
                        <p><?php echo $lang['playedtime']; ?></br><?php echo Utils::SecToClock($currentUser->PlayTime); ?></p>
                        <p><?php echo $lang['lastlogin']; ?></br><?php echo $currentUser->LastLoginDate; ?></p>
                        <p><?php echo $lang['registered']; ?></br><?php echo $currentUser->RegisterDate; ?></p>

                        <?php include($_SERVER['DOCUMENT_ROOT'] . "/apis/ProfileMButton.php"); ?>
                    </div>
                    
                    <div class="profile-separator"></div>
                    <div class="profile-panel">
                        <?php
                            panel_banned();
                            panel_bannedby();
                            panel_kicked();
                            panel_scanned();
                            panel_muted();
                            panel_mutedby();
if (isset($userProfile->PermLvl) && $userProfile->PermLvl->isAdmin() && $loggedInAdminLvL < 4) {
                            panel_activity();
                            }
                        ?> 
                    </div>
                </div>
            </div>
        </div>
    </div>

    <?php
}

function panel_activity()
{
    global $lang;
    global $sql;
    global $currentUser;
    $query = $sql->query("SELECT * FROM `".Config::$t_AmxBan_name."` WHERE 
    `player_id` LIKE '{$currentUser->LastLoginID}' OR
    `player_ip` LIKE '{$currentUser->LastLoginIP}' OR
    `player_id` LIKE '{$currentUser->RegisterID}' OR
    `player_ip` LIKE '{$currentUser->RegisterIP}'
    ORDER BY `amx_bans`.`bid` DESC");
    $c_query = mysqli_num_rows($query);
    if(!$currentUser->PermLvl->isAdmin() || $c_query > 0 || ($c_query == 0 && Account::IsLogined() && Account::$UserProfile->isBanable($currentUser, 1))) {
    ?>
    <div class="profile-table-container c_activity">
        <div onclick="$('#ActivitySlider, .c_banned, .c_bannedby, .c_muted, .c_mutedby, .c_kicked, .c_scanned').slideToggle(500, 'swing')" class="profile-control-table-header" style="background-color: rgba(100, 0, 0, 0.4)";>
        <p style="padding-left: 5px; font-size: 28px; position: relative; float: left; text-align: left; padding-left: 10px;"><?php echo $lang['profile_activity']; ?></p>
        <img id="act_loading" src="/images/prof_loading_icon.gif" alt="Loading" style="width: 45px; height: 45px; margin-top: 3px; float: left">
        </div>
        <div id="ActivitySlider" class="table-slider div_hideOnLoad">
        <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.5.0/Chart.min.js"></script>
        </br>
        <div style="width:100%;margin: auto; text-align:center;"><h3><?php echo $lang['last_31days']; ?></h3></div>
        <canvas id="Last31day" style="width:100%;"></canvas>
            <script>
            $(document).ready(function () {
                    setTimeout(async function () {
                        const url = "/api/PAD/<?php echo $currentUser->id; ?>";
                        try {
                            const response = await fetch(url);
                            if (!response.ok) throw new Error('Network response was not ok');
                            const json_data = await response.json(); 

                            new Chart("Last31day", {
                                type: "line",
                                data: {
                                    labels: json_data['interval'],  // X-axis labels
                                    datasets: [{
                                        label: "<?php echo $lang['active_minutes']; ?>",
                                        data: json_data['tabledata'],  // Parsed JSON data for Y-axis
                                        borderColor: "red",  // Line color
                                        lineTension: 0,  // No curve smoothing
                                        fill: true  // Fill the area below the line
                                    }]
                                },
                                options: {
                                    responsive: true,
                                    scales: {
                                        yAxes: [{
                                            ticks: {
                                                max: 1400,  // Max value for Y-axis
                                                min: 0,     // Min value for Y-axis
                                                beginAtZero: true
                                            }
                                        }]
                                    }
                                }
                            });
                            document.getElementById("act_loading").remove();
                            document.getElementById("ActivitySlider").parentElement.children[0].style = "";
                        } catch (error) {
                            console.error('Error fetching the content:', error);
                        }
                    }, 1000);  // Set timeout to delay by 1 second
                });
            </script>
       </div>
    </div>
    <?php }
}

function panel_scanned() {
    global $lang;
    global $sql;
    global $currentUser;

    // Prepare the SQL query with placeholders for parameters
    $query = "SELECT * FROM `" . Config::$t_AmxScan_name . "` WHERE 
        `player_id` = ? OR
        `admin_id` = ? OR
        `player_name` = ? OR
        `admin_name` = ?
        ORDER BY `amx_scans`.`id` DESC";
    
    // Prepare the statement and check for errors
    $stmt = $sql->prepare($query);
    if (!$stmt) {
        Utils::php_error(__FILE__, "Prepare failed: " . htmlspecialchars($sql->mysqli->error));
        return;
    }

    $playerID = $currentUser->LastLoginID;
    $adminID = $currentUser->RegisterID;
    $playerName = $currentUser->LastLoginName;
    $adminName = $currentUser->RegisterName;

    // Bind parameters to the statement
    $stmt->bind_param('ssss', $playerID, $adminID, $playerName, $adminName);
    
    // Execute the statement and check for errors
    $stmt->execute();
    $result = $stmt->get_result();
    $c_query = $result->num_rows;

    if (!$currentUser->PermLvl->isAdmin() || $c_query > 0 || ($c_query == 0 && Account::IsLogined())) {
        ?>
        <div class="profile-table-container c_scanned">
            <div onclick="$('#ScanSlider, .c_banned, .c_bannedby, .c_muted, .c_mutedby, .c_kicked, .c_activity').slideToggle(500, 'swing')" class="profile-control-table-header" style="background-color: rgba(100, 0, 0, 0.4);">
                <p id="scan_count_title" style="padding-left: 5px; font-size: 28px; position: relative; float: left; text-align: left; padding-left: 10px;"><?php echo $lang['scans']; ?></p>
                <img id="scan_loading" src="/images/prof_loading_icon.gif" alt="Loading" style="width: 45px; height: 45px; margin-top: 3px; float: left">
            </div>
            <div id="ScanSlider" class="table-slider div_hideOnLoad" style="max-height: 400px; display: block; overflow-y: auto;">
                <script>
                    $(document).ready(function() {
                        (async function() {
                            const url = "/api/PCD/<?php echo $currentUser->id; ?>";
                            try {
                                const response = await fetch(url);
                                if (!response.ok) throw new Error('Network response was not ok');
                                const content = await response.text();
                                document.getElementById("ScanSlider").innerHTML = content;
                                document.getElementById("scan_count_title").innerText += " (" + <?php echo $c_query; ?> + ")";
                                document.getElementById("scan_loading").remove();
                                document.getElementById("scan_count_title").parentElement.style = "";
                            } catch (error) {
                                console.error('Error fetching the content:', error);
                            }
                        })();
                    });
                </script>
            </div>
        </div>
        <?php 
    }
    $stmt->close();
}


function panel_banned()
{
    global $lang;
    global $is_banned;
    global $sql;
    global $currentUser;
    $query = $sql->query("SELECT * FROM `".Config::$t_AmxBan_name."` WHERE 
    `player_id` LIKE '{$currentUser->LastLoginID}' OR
    `player_ip` LIKE '{$currentUser->LastLoginIP}' OR
    `player_id` LIKE '{$currentUser->RegisterID}' OR
    `player_ip` LIKE '{$currentUser->RegisterIP}'
    ORDER BY `amx_bans`.`bid` DESC");
    $c_query = mysqli_num_rows($query);
    if(!$currentUser->PermLvl->isAdmin() || $c_query > 0 || (isset($currentUser->id) && isset(Account::$UserProfile->id) && $currentUser->id == Account::$UserProfile->id) || ($c_query == 0 && Account::IsLogined() && Account::$UserProfile->isBanable($currentUser, 1))) {
    ?>
    <div class="profile-table-container c_banned" >
        <div onclick="$('#BanSlider, .c_activity, .c_bannedby, .c_muted, .c_mutedby, .c_kicked, .c_scanned').slideToggle(500, 'swing')" class="profile-control-table-header" style=" background-color: rgba(100, 0, 0, 0.4);">
            <p id= "ban_count_title" style="pointer-events: block; padding-left: 5px; font-size: 28px; position: relative; float: left; text-align: left; padding-left: 10px;"><?php echo $lang['profile_bans']; ?></p>
            <img id="ban_loading" src="/images/prof_loading_icon.gif" alt="Loading" style="width: 45px; height: 45px; margin-top: 3px; float: left">
            <?php 
            if((Account::IsLogined() && Account::$UserProfile->isBanable($currentUser, 1) && !$is_banned) || (isset($currentUser->id) && isset(Account::$UserProfile->id) && $currentUser->id == Account::$UserProfile->id))
                echo "<form id='Ban' style='float: right; height: 0px;'>
                <input type='button' value='Kitiltás' class='btn btn-xs btn-danger' style='pointer-events: auto; color: black; margin-right: 10px; margin-top: 12px; padding: 0px 10px 0px 10px; font-size:15px;' onclick='handleBanButtonClick()'>
            </form>";
            ?>
        </div>
        <div id="AddBanSlider" class="table-slider div_hideOnLoad" style="max-height: 400px;display: block; overflow-y: auto;">
            <script>
                let isLocked = false;  // Nyomon követjük, hogy a Kitiltás gomb aktiválva van-e.
                async function fetchContentForAddBanSlider() {
                    const url = `/api/PT/<?php echo $currentUser->id; ?>`;

                    try {
                        const response = await fetch(url);
                        if (!response.ok) throw new Error('Network response was not ok');
                        
                        const content = await response.text();
                        // A kapott tartalom elhelyezése az AddBanSlider div-be
                        document.getElementById('AddBanSlider').innerHTML = content;
                        $('#AddBanSlider script').each(function() {
                            eval($(this).text());  // Be cautious with eval in production environments
                        });
                    } catch (error) {
                        console.error('Error fetching the content:', error);
                    }
                }
                function handleBanButtonClick(value) {
                    const parentElement = $('.profile-control-table-header');
                    const banButton = $('form#Ban input[type="button"]'); // Gomb kiválasztása

                    if (isLocked) {
                        setTimeout(function() {
                            $('#BanSlider').slideUp(500, 'swing');
                        }, 0010);

                        // Visszaállítjuk a gomb szövegét "Kitiltás"-ra
                        banButton.val('Kitiltás');

                        // Ha a gomb aktív volt, visszaállítjuk az állapotot
                        parentElement.css('pointer-events', 'auto');  // Szülő elem újra kattintható
                        $('#AddBanSlider').slideToggle(500, 'swing');  // Az AddBanSlider bezár
                        isLocked = false;  // Az állapot visszaállítása
                    } else {
                        fetchContentForAddBanSlider();
                        // Ha nem volt aktív, letiltjuk a szülő elem kattinthatóságát és csak az AddBanSlider-t nyitjuk meg
                        parentElement.css('pointer-events', 'none');  // Szülő elem kattinthatósága letiltva

                        // Gomb szövegének módosítása "Vissza"-ra
                        banButton.val('↩️ Vissza');

                        // Csak az AddBanSlider-t nyitjuk meg, a többi elem állapotát nem változtatjuk
                        if (!$('#AddBanSlider').is(':visible')) {
                            $('#AddBanSlider').slideToggle(500, 'swing');  // Csak az AddBanSlider-t nyitjuk meg
                        }

                        // Ellenőrizzük, hogy a szülő elemek rejtve vannak-e, és csak akkor hagyjuk őket rejtve, ha már rejtve voltak
                        setTimeout(function() {
                            const visibleParents = $('#BanSlider:visible, .c_activity:visible, .c_bannedby:visible, .c_muted:visible, .c_mutedby:visible, .c_kicked:visible');

                            if (visibleParents.length === 0) {
                            } else {
                                // Ha vannak nyitott szülő elemek, bezárjuk őket
                                visibleParents.each(function() {
                                    $(this).slideUp(500, 'swing');  // Bezárja az adott nyitott elemet 500ms-os animációval
                                });
                            }
                        }, 0010);
                        isLocked = true;  // Az állapot beállítása
                    }
                }
                // Aszinkron API hívás és a tartalom elhelyezése az AddBanSlider-be

            </script>
        </div>
        <div id="BanSlider" class="table-slider div_hideOnLoad" style="max-height: 400px;display: block; overflow-y: auto;">
            <script>
                $(document).ready(function() {
                    (async function() {
                        // Add your async code here
                        const url = "/api/PBD/<?php echo $currentUser->id; ?>";
                        try {
                            const response = await fetch(url);
                            if (!response.ok) throw new Error('Network response was not ok');
                            const content = await response.text();
                            document.getElementById("BanSlider").innerHTML = content;
                            document.getElementById("ban_count_title").innerText += " ("+<?php echo $c_query; ?>+")";
                            document.getElementById("ban_loading").remove();
                            document.getElementById("ban_count_title").parentElement.style = "";
                        } catch (error) {
                            console.error('Error fetching the content:', error);
                        }
                    })();
                });
            </script>
        </div>
    </div>
    <?php }
}
function panel_bannedby()
{
    global $lang;
    global $sql;
    global $currentUser;
    $query = $sql->query("SELECT * FROM `".Config::$t_AmxBan_name."` WHERE 
    `admin_id` LIKE '{$currentUser->LastLoginID}' OR
    `admin_ip` LIKE '{$currentUser->LastLoginIP}' OR
    `admin_id` LIKE '{$currentUser->RegisterID}' OR
    `admin_ip` LIKE '{$currentUser->RegisterIP}'
    ORDER BY `amx_bans`.`bid` DESC");
    $c_query = mysqli_num_rows($query);
    if(!$currentUser->PermLvl->isAdmin() || $c_query > 0 || ($c_query == 0 && Account::IsLogined() && Account::$UserProfile->isBanableSomewhere($currentUser))) {
    ?>
    <div class="profile-table-container c_bannedby">
        <div onclick="$('#BanBySlider, .c_banned, .c_activity, .c_muted, .c_mutedby, .c_kicked, .c_scanned').slideToggle(500, 'swing')" class="profile-control-table-header" style="background-color: rgba(100, 0, 0, 0.4);">
        <p id= "bannedby_count_title" style="padding-left: 5px; font-size: 28px; position: relative; float: left; text-align: left; padding-left: 10px;"><?php echo $lang['profile_bannedby']; ?></p>
        <img id="bannedby_loading" src="/images/prof_loading_icon.gif" alt="Loading" style="width: 45px; height: 45px; margin-top: 3px; float: left">
        </div>
        <div id="BanBySlider" class="table-slider div_hideOnLoad" style="max-height: 400px;display: block; overflow-y: auto;">
            <script>
                $(document).ready(function() {
                    (async function() {
                        // Add your async code here
                        const url = "/api/PBBD/<?php echo $currentUser->id; ?>";
                        try {
                            const response = await fetch(url);
                            if (!response.ok) throw new Error('Network response was not ok');
                            const content = await response.text();
                            document.getElementById("BanBySlider").innerHTML = content;
                            document.getElementById("bannedby_count_title").innerText += " ("+<?php echo $c_query; ?>+")";
                            document.getElementById("bannedby_loading").remove();
                            document.getElementById("bannedby_count_title").parentElement.style = "";
                        } catch (error) {
                            console.error('Error fetching the content:', error);
                        }
                    })();
                });
            </script>
        </div>
    </div>
    <?php }
}

function panel_kicked()
{
    global $lang;
    global $sql;
    global $currentUser;
    $query = $sql->query("SELECT * FROM `".Config::$t_AmxKick_name."` WHERE 
    `player_id` LIKE '{$currentUser->LastLoginID}' OR
    `player_ip` LIKE '{$currentUser->LastLoginIP}' OR
    `player_id` LIKE '{$currentUser->RegisterID}' OR
    `player_ip` LIKE '{$currentUser->RegisterIP}'
    ORDER BY `amx_kick`.`kid` DESC");
    $c_query = mysqli_num_rows($query);
    if(!$currentUser->PermLvl->isAdmin() || $c_query > 0 || ($c_query == 0 && Account::IsLogined() )) {
    ?>
    <div class="profile-table-container c_kicked">
        <div onclick="$('#KickSlider, .c_banned, .c_bannedby, .c_muted, .c_mutedby, .c_activity, .c_scanned').slideToggle(500, 'swing')" class="profile-control-table-header" style="background-color: rgba(100, 0, 0, 0.4);">
        <p id= "kick_count_title" style="padding-left: 5px; font-size: 28px; position: relative; float: left; text-align: left; padding-left: 10px;"><?php echo $lang['profile_kicks']; ?></p>
        <img id="kick_loading" src="/images/prof_loading_icon.gif" alt="Loading" style="width: 45px; height: 45px; margin-top: 3px; float: left">
        </div>
        <div id="KickSlider" class="table-slider div_hideOnLoad" style="max-height: 400px;display: block; overflow-y: auto;">
            <script>
                $(document).ready(function() {
                    (async function() {
                        // Add your async code here
                        const url = "/api/PKD/<?php echo $currentUser->id; ?>";
                        try {
                            const response = await fetch(url);
                            if (!response.ok) throw new Error('Network response was not ok');
                            const content = await response.text();
                            document.getElementById("KickSlider").innerHTML = content;
                            document.getElementById("kick_count_title").innerText += " ("+<?php echo $c_query; ?>+")";
                            document.getElementById("kick_loading").remove();
                            document.getElementById("kick_count_title").parentElement.style = "";
                        } catch (error) {
                            console.error('Error fetching the content:', error);
                        }
                    })();
                });
            </script>
        </div>
    </div>
    <?php }
}

function panel_muted()
{
    global $lang;
    global $is_muted;
    global $sql;
    global $currentUser;
    $query = $sql->query("SELECT * FROM `".Config::$t_AmxMute_name."` WHERE 
    `player_id` LIKE '{$currentUser->LastLoginID}' OR
    `player_ip` LIKE '{$currentUser->LastLoginIP}' OR
    `player_id` LIKE '{$currentUser->RegisterID}' OR
    `player_ip` LIKE '{$currentUser->RegisterIP}'
    ORDER BY `amx_mutes`.`bid` DESC");
    $c_query = mysqli_num_rows($query);
    if(!$currentUser->PermLvl->isAdmin() || $c_query > 0 || ($c_query == 0 && Account::IsLogined())) { // Ez nem végleges
    ?>
    <div class="profile-table-container c_muted">
        <div onclick="$('#MuteSlider, .c_banned, .c_bannedby, .c_activity, .c_mutedby, .c_kicked, .c_scanned').slideToggle(500, 'swing')" class="profile-control-table-header" style="background-color: rgba(100, 0, 0, 0.4);">
            <p id= "muted_count_title" style="padding-left: 5px; font-size: 28px; position: relative; float: left; text-align: left; padding-left: 10px;"><?php echo $lang['profile_mutes']; ?></p>
            <img id="mute_loading" src="/images/prof_loading_icon.gif" alt="Loading" style="width: 45px; height: 45px; margin-top: 3px; float: left">
            <?php
            if(Account::IsLogined() && Account::$UserProfile->isMuteable($currentUser, 1) && !$is_muted)
            echo "<form id='Mute' style='float: right; height: 0px;'>
            <input type='button' value='Némítás' class='btn btn-xs btn-danger' style='pointer-events: auto; color: black; margin-right: 10px; margin-top: 12px; padding: 0px 10px 0px 10px; font-size:15px;' onclick='handleMuteButtonClick()'>
        </form>";
        ?>
        </div>
        <div id="AddMuteSlider" class="table-slider div_hideOnLoad" style="max-height: 400px;display: block; overflow-y: auto;">
            <script>
                let m_isLocked = false;  // Nyomon követjük, hogy a Kitiltás gomb aktiválva van-e.
                async function fetchContentForAddMuteSlider() {
                    const url = `/api/PTM/<?php echo $currentUser->id; ?>`;

                    try {
                        const response = await fetch(url);
                        if (!response.ok) throw new Error('Network response was not ok');
                        
                        const content = await response.text();
                        // A kapott tartalom elhelyezése az AddBanSlider div-be
                        document.getElementById('AddMuteSlider').innerHTML = content;
                        $('#AddMuteSlider script').each(function() {
                            eval($(this).text());  // Be cautious with eval in production environments
                        });
                    } catch (error) {
                        console.error('Error fetching the content:', error);
                    }
                }
                function handleMuteButtonClick() {
                    const parentElement = $('.profile-control-table-header');
                    const banButton = $('form#Mute input[type="button"]'); // Gomb kiválasztása

                    if (m_isLocked) {
                        setTimeout(function() {
                            $('#MuteSlider').slideUp(500, 'swing');
                        }, 0010);

                        // Visszaállítjuk a gomb szövegét "Kitiltás"-ra
                        banButton.val('Némítás');

                        // Ha a gomb aktív volt, visszaállítjuk az állapotot
                        parentElement.css('pointer-events', 'auto');  // Szülő elem újra kattintható
                        $('#AddMuteSlider').slideToggle(500, 'swing');  // Az AddBanSlider bezár
                        m_isLocked = false;  // Az állapot visszaállítása
                    } else {
                        fetchContentForAddMuteSlider();
                        // Ha nem volt aktív, letiltjuk a szülő elem kattinthatóságát és csak az AddBanSlider-t nyitjuk meg
                        parentElement.css('pointer-events', 'none');  // Szülő elem kattinthatósága letiltva

                        // Gomb szövegének módosítása "Vissza"-ra
                        banButton.val('↩️ Vissza');

                        // Csak az AddBanSlider-t nyitjuk meg, a többi elem állapotát nem változtatjuk
                        if (!$('#AddMuteSlider').is(':visible')) {
                            $('#AddMuteSlider').slideToggle(500, 'swing');  // Csak az AddBanSlider-t nyitjuk meg
                        }

                        // Ellenőrizzük, hogy a szülő elemek rejtve vannak-e, és csak akkor hagyjuk őket rejtve, ha már rejtve voltak
                        setTimeout(function() {
                            const visibleParents = $('#MuteSlider:visible, .c_activity:visible, .c_bannedby:visible, .c_banned:visible, .c_mutedby:visible, .c_kicked:visible');

                            if (visibleParents.length === 0) {
                            } else {
                                // Ha vannak nyitott szülő elemek, bezárjuk őket
                                visibleParents.each(function() {
                                    $(this).slideUp(500, 'swing');  // Bezárja az adott nyitott elemet 500ms-os animációval
                                });
                            }
                        }, 0010);
                        m_isLocked = true;  // Az állapot beállítása
                    }
                }
                // Aszinkron API hívás és a tartalom elhelyezése az AddBanSlider-be

            </script>
        </div>
        <div id="MuteSlider" class="table-slider div_hideOnLoad" style="max-height: 400px;display: block; overflow-y: auto;">
            <script>
                $(document).ready(function() {
                    (async function() {
                        // Add your async code here
                        const url = "/api/PMD/<?php echo $currentUser->id; ?>";
                        try {
                            const response = await fetch(url);
                            if (!response.ok) throw new Error('Network response was not ok');
                            const content = await response.text();
                            document.getElementById("MuteSlider").innerHTML = content;
                            document.getElementById("muted_count_title").innerText += " ("+<?php echo $c_query; ?>+")";
                            document.getElementById("mute_loading").remove();
                            document.getElementById("muted_count_title").parentElement.style = "";
                        } catch (error) {
                            console.error('Error fetching the content:', error);
                        }
                    })();
                });
            </script>
        </div>
    </div>
    <?php }
}
function panel_mutedby()
{
    global $lang;
    global $sql;
    global $currentUser;
    $query = $sql->query("SELECT * FROM `".Config::$t_AmxMute_name."` WHERE 
    `admin_id` LIKE '{$currentUser->LastLoginID}' OR
    `admin_ip` LIKE '{$currentUser->LastLoginIP}' OR
    `admin_id` LIKE '{$currentUser->RegisterID}' OR
    `admin_ip` LIKE '{$currentUser->RegisterIP}'
    ORDER BY `amx_mutes`.`bid` DESC");
    $c_query = mysqli_num_rows($query);
    if(!$currentUser->PermLvl->isAdmin() || $c_query > 0 || ($c_query == 0 && Account::IsLogined())) { // Ez nem végleges
    ?>
    <div class="profile-table-container c_mutedby">
        <div onclick="$('#MuteBySlider, .c_banned, .c_bannedby, .c_muted, .c_activity, .c_kicked, .c_scanned').slideToggle(500, 'swing')" class="profile-control-table-header" style="background-color: rgba(100, 0, 0, 0.4);">
            <p id= "mutedby_count_title" style="padding-left: 5px; font-size: 28px; position: relative; float: left; text-align: left; padding-left: 10px;"><?php echo $lang['profile_mutedby']; ?></p>
            <img id="mutedby_loading" src="/images/prof_loading_icon.gif" alt="Loading" style="width: 45px; height: 45px; margin-top: 3px; float: left">
        </div>
        <div id="MuteBySlider" class="table-slider div_hideOnLoad" style="max-height: 400px;display: block; overflow-y: auto;">
            <script>
                $(document).ready(function() {
                    (async function() {
                        // Add your async code here
                        const url = "/api/PMBD/<?php echo $currentUser->id; ?>";
                        try {
                            const response = await fetch(url);
                            if (!response.ok) throw new Error('Network response was not ok');
                            const content = await response.text();
                            document.getElementById("MuteBySlider").innerHTML = content;
                            document.getElementById("mutedby_count_title").innerText += " ("+<?php echo $c_query; ?>+")";
                            document.getElementById("mutedby_loading").remove();
                            document.getElementById("mutedby_count_title").parentElement.style = "";
                        } catch (error) {
                            console.error('Error fetching the content:', error);
                        }
                    })();
                });
            </script>
        </div>
    </div>
    <?php }
}

function aliasbox()
{
    global $currentUser;
    ?>
    <img id="alias_button" style="margin-left: 5px; cursor: pointer;" src="<?php echo Utils::get_url("images/downarrow.png"); ?>" width="9" height="5"/>
    <div id="alias_box" class = "div_hideOnLoad" style="border: 2px solid rgb(204, 20, 127); border-radius: 25px; padding: 10px; margin-top: 225px; margin-left: 2px; min-width: 250px; z-index: 10; position: absolute; background-color: rgb(0, 0, 0);">
    <script>
        $(document).ready(function() {
            (async function() {
                // Add your async code here
                const url = "/api/AB/<?php echo $currentUser->id; ?>";
                try {
                    const response = await fetch(url);
                    if (!response.ok) throw new Error('Network response was not ok');
                    const content = await response.text();
                    document.getElementById("alias_box").innerHTML = content;
                } catch (error) {
                    console.error('Error fetching the content:', error);
                }
            })();
        });
        </script>
    </div>
    <script>
        
        $("#alias_box").fadeOut(0);
        $("#alias_button").click(function() {
            $("#alias_box").fadeToggle();
        });
    </script>
    <?php
}
function func_addstyle()
{
    ?>
        <script src="<?php echo Utils::get_url('js/profb.js?ver=25'); ?>"></script> 
        <script src="<?php echo Utils::get_url('js/profm.js?v=25'); ?>"></script> 
        <link rel="stylesheet" type="text/css" href="<?php echo Utils::get_url("css/profile.css?ver=a123");?>"/>
        <link rel="stylesheet" type="text/css" href="<?php echo Utils::get_url("css/profb.css?ver=a123");?>"/>
    <?php

}

Utils::header("Profil | [#{$currentUser->id}] {$currentUser->LastLoginName}", "func_addstyle");
Utils::body("func_profile");
Utils::footer();