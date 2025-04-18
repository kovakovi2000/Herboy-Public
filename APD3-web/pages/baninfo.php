<?php
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/Config.php");
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/includes/Utils.php");
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/includes/PunishmentStruck.php");

global $sql;

function getBanDetailsById($banId) {
    global $sql;
    $banId = $sql->escape($banId);
    $query = "SELECT * FROM amx_bans WHERE bid = '$banId' LIMIT 1";
    $result = $sql->query($query);
    if ($result && mysqli_num_rows($result) > 0) {
        return mysqli_fetch_assoc($result);
    }
    return false;
}

function getModificationsByBanId($banId) {
    global $sql;
    $banId = $sql->escape($banId);
    $query = "SELECT * FROM amx_bans_modified WHERE bid = '$banId' ORDER BY ModifiedAt DESC";
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
    } elseif ($expired == 3) {
        $class = 'label label-success';
        $text = "Global UnBan";
    }

    $ret = "<span class='".$class."' style='float: left; margin-right: 5px;'>".$text."</span>";
    if ($modified > 0) {
        $ret .= "<span class='label label-warning' style='float: left; margin-right: 5px;'>Módosított</span>";
    }

    return $ret . ($expired == 2 || $expired == 3 ? ("<div style='float: left;'> ".htmlspecialchars($username ?? '', ENT_QUOTES)."</div>") : "");
}

if (isset($pagelink[1])) {
    $banId = $pagelink[1];
    $banDetails = getBanDetailsById($banId);
    $modifications = getModificationsByBanId($banId);
    if ($banDetails) {
        $playerNick = $banDetails['player_nick'];
        $steamId = $banDetails['player_id'];
        $banLength = $banDetails['ban_length'];
        $banStart = date("Y-m-d H:i:s", $banDetails['ban_created']);
        $banLengthInMinutes = $banDetails['ban_length'];
        if ($banLengthInMinutes > 0) {
            $banExpiryTime = $banDetails['ban_created'] + ($banLengthInMinutes * 60);
            $banExpiry = date("Y-m-d H:i:s", $banExpiryTime);
        } else {
            $banExpiry = 'Soha';
        }
        $banReason = $banDetails['ban_reason'];
        $adminName = $banDetails['UName'];
        $expired = $banDetails['expired'];
        $modifiedby = $banDetails['modifiedby'];

        $NeededColumList = array(
            'id',
            'LastLoginID',
            'LastLoginName',
            'LastLoginDate',
            'LastLoggedOn',
            'AdminLvL1'
        );

        $player = new UserProfile($banDetails['player_id'], $NeededColumList);
        //if ($player->SuccessInit() === false) {
          //  $player->id = -1;
            $player->PermLvl->AdminLvl[] = 0;
            $player->LastLoginName = $playerNick;
        

        $admin = new UserProfile($banDetails['admin_id'], $NeededColumList);
        if ($admin->SuccessInit() === false) {
            $admin->id = -1;
            $admin->PermLvl->AdminLvl[] = 0;
            $admin->LastLoginName = $adminName;
        }
    } else {
        exit;
    }
} else {
    exit;
}

function func_mainpage() {
    global $banId, $player, $steamId, $banStart, $banExpiry, $banReason, $adminName, $banLength, $expired, $admin, $modifiedby, $modifications;
    ?>
    <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
    </head>
    <body>
        <div class="modern-card-container">
            <div class="modern-card">
                <div class="modern-card-body">
                    <div class="page-header col-md-12" id="banner" style="border: none !important;">
                        <h1 ALIGN=center><b><h2 style="color: #d1d1d1;">Információk a kitiltásról</h2></b></h1>
                        <table class="table zebra-stripes">
                            <tbody>
                                <tr>
                                    <th>BanID</th>
                                    <td>#<?php echo htmlspecialchars($banId); ?></td>
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
                                    <td><?php echo htmlspecialchars($banStart); ?></td>
                                </tr>
                                <tr>
                                    <th>Lejárat</th>
                                    <td>
                                        <?php echo htmlspecialchars($banExpiry); ?>
                                    </td>
                                </tr>
                                <tr>
                                    <th>Hossza</th>
                                    <td><?php echo htmlspecialchars($banLength) . " perc"; ?></td>
                                </tr>
                                <tr>
                                    <th>Indok</th>
                                    <td><?php echo htmlspecialchars($banReason); ?></td>
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

            $reason = htmlspecialchars($modification['ban_reason']);
            $length = htmlspecialchars($modification['ban_length']) . " perc";
            $modifiedAt = date("Y-m-d H:i:s", $modification['ModifiedAt']);
            $profileUrl = "/profile/" . htmlspecialchars($modifier->id);

            echo "<tr>";
            echo "<td><a href='" . $profileUrl . "' style='color: inherit; text-decoration: none;'>" . $modifier->NameCard("float: left;", false) . "</a></td>";
            echo "<td class='reason-column'>$reason</td>";
            echo "<td>$length</td>";
            echo "<td>$modifiedAt</td>";
            echo "</tr>";
        }

        echo "</tbody>";
        echo "</table>";
    }
?>
                            </tbody>
                        </table>
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
    <link rel="stylesheet" type="text/css" href="<?php echo Utils::get_url('css/info.css?ver=a123');?>">
    <?php
}

Utils::header("Kitiltás Információ", "func_addstyle");
Utils::body("func_mainpage");
Utils::footer();
?>
