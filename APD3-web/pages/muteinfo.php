<?php
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/Config.php");
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/includes/Utils.php");
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/includes/PunishmentStruck.php");

global $sql;

function getMuteDetailsById($muteId) {
    global $sql;
    $muteId = $sql->escape($muteId);
    $query = "SELECT * FROM amx_mutes WHERE bid = '$muteId' LIMIT 1";
    $result = $sql->query($query);
    if ($result && mysqli_num_rows($result) > 0) {
        return mysqli_fetch_assoc($result);
    }
    return false;
}
function getModificationsByMuteId($banId) {
    global $sql;
    $banId = $sql->escape($banId);
    $query = "SELECT * FROM amx_mutes_modified WHERE bid = '$banId' ORDER BY ModifiedAt DESC";
    $result = $sql->query($query);
    $modifications = [];
    if ($result && mysqli_num_rows($result) > 0) {
        while ($row = mysqli_fetch_assoc($result)) {
            $modifications[] = $row;
        }
    }
    return $modifications;
}
function PrintStatus($expired, $modified, $username) {
    $class = 'label label-danger';
    $text = "Aktív"; 
    
    if ($expired == 1) {
        $class = 'label label-success';
        $text = "Lejárt";
    } elseif ($expired == 2) {
        $class = 'label label-success';
        $text = "Deaktiválva";
    }

    $ret = "<span class='".$class."' style='float: left; margin-right: 5px;'>".$text."</span>";
    if ($modified > 0) {
        $ret .= "<span class='label label-warning' style='float: left; margin-right: 5px;'>Módosított</span>";
    }

    return $ret . ($expired == 2 || $expired == 3 ? ("<div style='float: left;'> ".htmlspecialchars($username ?? '', ENT_QUOTES)."</div>") : "");
}

if (isset($pagelink[1])) {
    $muteId = $pagelink[1];
    $muteDetails = getMuteDetailsById($muteId);
    $modifications = getModificationsByMuteId($muteId);
    if ($muteDetails) {
        $playerNick = $muteDetails['player_nick'];
        $steamId = $muteDetails['player_id'];
        $muteLength = $muteDetails['mute_length'];
        $muteType = $muteDetails['mute_type'];
        $displayMuteType = $muteType == 3 ? "Voice + Chat" : ($muteType == 2 ? "Voice" : "Chat");
        $muteStart = date("Y-m-d H:i:s", $muteDetails['mute_created']);
        $muteLengthInMinutes = $muteDetails['mute_length'];
        if ($muteLengthInMinutes > 0) {
            $muteExpiryTime = $muteDetails['mute_created'] + ($muteLengthInMinutes * 60);
            $muteExpiry = date("Y-m-d H:i:s", $muteExpiryTime);
        } else {
            $muteExpiry = 'Soha';
        }
        $muteReason = $muteDetails['mute_reason'];
        $adminName = $muteDetails['UName'];
        $expired = $muteDetails['expired'];
        $modifiedby = $muteDetails['modifiedby'];
        $NeededColumList = array(
            'id',
            'LastLoginID',
            'LastLoginName',
            'LastLoginDate',
            'LastLoggedOn',
            'AdminLvL1'
        );
        $player = new UserProfile($muteDetails['player_id'], $NeededColumList);
       // if ($player->SuccessInit() === false) {
         //   $player->id = -1;
            $player->PermLvl->AdminLvl[] = 0;
            $player->LastLoginName = $playerNick;
        
        $admin = new UserProfile($muteDetails['admin_id'], $NeededColumList);
        if ($admin->SuccessInit() === false) {
           // $admin->id = -1;
           // $admin->PermLvl->AdminLvl[] = 0;
            $admin->LastLoginName = $adminName;
        }
    } else {
        exit;
    }
} else {
    exit;
}

function func_mainpage() {
    global $muteId, $player, $steamId, $muteStart, $muteExpiry, $muteReason, $adminName, $muteLength, $displayMuteType, $expired, $admin, $modifiedby, $modifications;
    ?>
    <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
    </head>

<body>
<div class="modern-card-container">
    <div class="modern-card">
        <div class="modern-card-body">
            <div class="page-header col-md-12" id="banner" style="border: none !important;">
                <h1 ALIGN=center><b><h2 style="color: #d1d1d1;">Információk a némításról</h2></b></h1>
                <table class="table zebra-stripes">
                    <tbody>
                        <tr>
                            <th>MuteID</th>
                            <td>#<?php echo htmlspecialchars($muteId); ?></td>
                        </tr>
                        <tr>
                            <th>Név</th>
                            <td><?php echo $player->NameCard("float: left;"); ?></td>
                        </tr>
                        <tr>
                            <th>SteamID</th>
                            <td><?php echo htmlspecialchars($steamId); ?></td>
                        </tr>
                        <tr>
                            <th>Kezdete</th>
                            <td><?php echo htmlspecialchars($muteStart); ?></td>
                        </tr>
                        <tr>
                            <th>Lejárat</th>
                            <td>
                            <?php echo htmlspecialchars($muteExpiry); ?>
                            </td>
                        </tr>
                        <tr>
                            <th>Hossza</th>
                            <td><?php echo htmlspecialchars($muteLength) . " perc"; ?></td>
                        </tr>
                        <tr>
                            <th>Típusa</th>
                            <td><?php echo htmlspecialchars($displayMuteType); ?></td>
                        </tr>
                        <tr>
                            <th>Indok</th>
                            <td><?php echo htmlspecialchars($muteReason); ?></td>
                        </tr>
                        <tr>
                            <th>Admin</th>
                            <td><?php echo $admin->NameCard("float: left;"); ?></td>
                        </tr>
                        <tr>
                                    <th>Státusz</th>
                                    <td>
                                    <?php
        echo PrintStatus($expired, $modifiedby, $adminName);
        ?>      
                                </td>
                                </tr>
                    </tbody>
                </table>
                <br>
                <?php
    // Only display the modifications section if there are any modifications
        if (!empty($modifications)) 
        {
            echo "<h1 ALIGN=left><b><h2 style='color: #d1d1d1;'>Eddigi módosítás(ok):</h2></b></h1>";
            echo "<table class='table zebra-stripes'>";
            echo "<thead>";
            echo "<tr>";
            echo "<th>Módosító</th>";
            echo "<th>Indok</th>";
            echo "<th>Hossza</th>";
            echo "<th>Módosítás ideje</th>";
            echo "</tr>";
            echo "</thead>";
            echo "<tbody>";

            foreach ($modifications as $modification) {
                $modifier = new UserProfile($modification['UserId'], array('LastLoginName', 'id', 'AdminLvL1'));
                if (!$modifier->SuccessInit()) {
                    $modifier->LastLoginName = 'Ismeretlen';
                    $modifier->id = -1;
                    $modifier->PermLvl->AdminLvl[] = 0;
                }

                $reason = htmlspecialchars($modification['mute_reason']);
                $length = htmlspecialchars($modification['mute_length']) . " perc";
                $modifiedAt = date("Y-m-d H:i:s", $modification['ModifiedAt']);
                $profileUrl = "/profile/" . htmlspecialchars($modifier->id);

                echo "<tr>";
                // NameCard with profile link
                echo "<td><a href='" . $profileUrl . "' style='color: inherit; text-decoration: none;'>" . $modifier->NameCard("float: left;", false) . "</a></td>";
                // Reason column with custom class for better spacing
                echo "<td class='reason-column'>$reason</td>";
                echo "<td>$length</td>";
                echo "<td>$modifiedAt</td>";
                echo "</tr>";
            }

            echo "</tbody>";
            echo "</table>";
        }
    ?>
            </div>
        </div>
    </div>
</div>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
</body>
<?php
}

function func_addstyle() {
    ?>
    <script type="text/javascript" src="//cdn.jsdelivr.net/npm/slick-carousel@1.8.1/slick/slick.min.js"></script>
    <link rel="stylesheet" type="text/css" href="//cdn.jsdelivr.net/npm/slick-carousel@1.8.1/slick/slick.css"/>
    <link rel="stylesheet" type="text/css" href="//cdn.jsdelivr.net/npm/slick-carousel@1.8.1/slick/slick-theme.css"/>
    <link rel="stylesheet" type="text/css" href="<?php echo Utils::get_url('css/info.css?ver=2');?>">
    <?php
}

Utils::header("Némítás Információ", "func_addstyle");
Utils::body("func_mainpage");
Utils::footer();
?>
