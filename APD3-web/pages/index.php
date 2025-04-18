<?php
require_once(__DIR__ . '/../GameQ/Autoloader.php');
include_once $_SERVER['DOCUMENT_ROOT'] . '/configs/lang/switch.php';

$gameservers = [
    [
        'id'      => '1',
        'type'    => 'cs16',
        'host'    => '37.221.212.11:27222',
        'servername' => '[~|HerBoy|~] - OnlyDust2 [NEW]',
    ],
	// [
    //     'id'      => '2',
    //     'type'    => 'cs16',
    //     'host'    => '37.221.209.130:27350',
    //     'servername' => '[Avatár] Magyar FUN szerver',
    // ],
    //[
        //'id'      => '3',
        //'type'    => 'teamspeak3',
        //'host'    => '194.180.16.153:9987',
        //'servername' => 'HERBOY - AVATÁR TEAMSPEAK @ herboyd2.hu',
        //'options' => [
            //'query_port' => 10011,
        //],
    //],
    // [
    //     'id'      => '4',
    //     'type'    => 'cs16',
    //     'host'    => '37.221.209.130:27295',
    //     'servername' => '[~|HerBoy|~] - [ #2 ] Dust2 [HU] ~ [v4]',
    // ]

];


$GameQ = new \GameQ\GameQ(); // or $GameQ = \GameQ\GameQ::factory();
$GameQ->addServers($gameservers);
$GameQ->setOption('timeout', 1); // seconds
$results = $GameQ->process(); 

function func_mainpage()
{   
    global $lang;
    global $servers;
    global $sql;
    ?>
<div class="modern-card-container">
    <div class="modern-card" style="margin: 20px; overflow-y: auto;">
        <div style="height: 100%; width: 100%;">
            <div class="modern-card-header">
            <h1><center><?php echo $lang['our_servers']; ?></center></h1>
            </div>
            <div class="modern-card-body">
                <table class="table zebra-stripes" style="position: relative;">
                    <thead>
                    <tr>
                            <th><?php echo $lang['server_id']; ?></th>
                            <th><?php echo $lang['name']; ?></th>
                            <th><?php echo $lang['ip_address']; ?></th>
                            <th><?php echo $lang['players']; ?></th>
                            <th><?php echo $lang['map']; ?></th>
                            <th><?php echo $lang['status']; ?></th>
                        </tr>
                    </thead>
                    <?php
                    global $gameservers;
                    global $results;
                    
                    $totalPlayers = 0;   // Összes játékos
                    $totalMaxPlayers = 0; // Összes férőhely
                    
                    for ($i = 0; $i < sizeof($gameservers); $i++) {
                        $serverId = $gameservers[$i]['id']; // A szerver ID alapján dolgozunk
                        
                        echo "<td>#".$serverId."</td>";
                        
                        // Szervernév
                        if ($results[$serverId]["gq_online"] == 1) {
                            echo "<td>".$results[$serverId]["gq_hostname"]."</td>";
                        } else {
                            echo "<td>".$gameservers[$i]["servername"]."</td>";
                        }
                        
                        // Host
                        if ($serverId >= 4) {
                            echo "<td>cs.herboyd2.hu</td>";
                        }
                        else {
                            echo "<td>".$gameservers[$i]["host"]."</td>";
                        }
                        
                        // Játékosok száma és férőhelyek (CS 1.6 vagy TeamSpeak 3 szerverek esetén)
                        if ($results[$serverId]["gq_type"] == "cs16" || $results[$serverId]["gq_type"] == "teamspeak3") {
                            if ($results[$serverId]["gq_maxplayers"] != 0) {
                                echo "<td>";
                                
                                
                                // Összes játékos és férőhelyek növelése
                                if ($serverId >= 4) {
                                    echo "N/A";
                                    $totalPlayers += 0;
                                    $totalMaxPlayers += 0;
                                } else {
                                    echo $results[$serverId]["gq_numplayers"] . "/" . $results[$serverId]["gq_maxplayers"];
                                    $totalPlayers += $results[$serverId]["gq_numplayers"];
                                    $totalMaxPlayers += $results[$serverId]["gq_maxplayers"];
                                }
                                
                                // Jelszavas szerver ellenőrzése
                                if ($results[$serverId]["gq_password"] == 1) {
                                    echo " <i class='fa fa-lock' aria-hidden='true' style='color: #ffd700;'></i>";
                                }
                                echo "</td>";
                            } else {
                                echo "<td>N/A</td>";
                            }
                            
                            // Map neve CS 1.6 esetén
                            if ($results[$serverId]["gq_online"]  != 0 && $results[$serverId]["gq_type"] == "cs16") {
                                echo "<td>".$results[$serverId]["gq_mapname"]."</td>";
                            } 
                            // TeamSpeak 3 esetén csak "TeamSpeak" jelenik meg
                            else if ($results[$serverId]["gq_type"] == "teamspeak3") {
                                echo "<td>TeamSpeak</td>";
                            } else {
                                echo "<td>N/A</td>";
                            }
                        }
                    
                        // Online / Offline státusz
                        if ($results[$serverId]["gq_online"] == 1) {
                            echo "<td><span class='label label-success' style='float: left; margin-right: 5px;'>Online</span></td>";
                        } else {
                            echo "<td><span class='label label-danger' style='float: left; margin-right: 5px;'>Offline</span></td>";
                        }
                    
                        echo "<tr></tr>";
                    }
                                     
                    ?>
                </table>
                <div style="text-align: center; margin-top: 20px; font-size: 15px; font-weight: bold;">
                <?php echo $lang['total_slot'] . ": " . $totalPlayers . "/" . $totalMaxPlayers; ?>
                </div>
            </div>
        </div>
    </div>
</div>
    <div class="modern-card-container">
        <div class="modern-card" style="margin-bottom: 50px;">
            <div style="height: 100%; width: 100%;">
                <div class="modern-card-header">
                    <h1><center><?php echo $lang['player_statistics']; ?></center></h1>
                </div>
                <div class="modern-card-body">
                    <div class="slider-for">
                        <?php for($i = 0; $i < sizeof($servers); $i++)
                        {
                            if($servers[$i]['online'] === true)
                            {
                                print "<div>";
                                create_staticstic($i);
                                print "</div>";
                            }
                        } ?>
                    </div>
                    <div class="slider-nav" style="width: 25%; margin: auto;">
                        <?php for($i = 0; $i < sizeof($servers); $i++):?>
                            <?php if($servers[$i]['online'] === true): ?>
                                <div style="display: flex; flex-direction: column; align-content: center; align-items: center;">
                                    <h1><?php echo $servers[$i]['type']; ?></h1>
                                    <h5><?php echo $servers[$i]['ip'].":".$servers[$i]['port']; ?></h5>
                                </div>
                            <?php endif; ?>
                        <?php endfor;?>
                    </div>
                </div>
            </div>
        </div>
    <style>
    .admin-card-item {
        transition: transform 0.3s ease; /* Animáció a kiemelkedéshez */
    }

    .admin-card-item:hover {
        transform: translateY(-10px); /* Kiemelkedés a dobozból */
    }

    </style>
    </div>
    <?php
}

function create_staticstic($db_index)
{
    ?>
    <div class="slider" style="width: 92%; margin: auto; ">
        <?php 
            global $sql;
            $localsql = $sql->mysqli;
        ?>
        <div>
            <?php func_display_24hours_status($localsql, $db_index); ?>
        </div>
        <div>
            <?php func_display_31days_status($localsql, $db_index); ?>
        </div>
        <div>
            <?php func_display_12months_status($localsql, $db_index); ?>
        </div>
    </div>
    <?php
}

function func_display_24hours_status($localsql, $db_index)
{
    global $lang;
    $intervals = "";
    $last24Data = array();
    $last24Data['Avg'] = "";
    $last24Data['Max'] = "";
    $last24Data['Min'] = "";

    $last24Query = $localsql->query(
    "SELECT 
        FROM_UNIXTIME(UNIX_TIMESTAMP(`time`), '%H:00') AS Hours,
        AVG(`playercount`) AS AvgPlayer,
        MAX(`playercount`) AS MaxPlayer,
        MIN(`playercount`) AS MinPlayer
    FROM `webplayercount`
    WHERE `time` BETWEEN (NOW() - INTERVAL 1 DAY) AND (NOW() - INTERVAL 1 HOUR)
    GROUP BY HOUR(`time`) ORDER BY `time` ASC;");

    $stop_date = new DateTime();
    $stop_date->modify('-1 day');
    $placed = true;
    for ($i=0; $i < 24; $i++) {
        $found = false;
        if(!$placed && $row['Hours'] == $stop_date->format('H:00'))
        {
            $intervals = $intervals . '"' . $row['Hours'] . '",';
            $last24Data['Avg'] = $last24Data['Avg'] . '"' . $row['AvgPlayer'] . '",';
            $last24Data['Max'] = $last24Data['Max'] . '"' . $row['MaxPlayer'] . '",';
            $last24Data['Min'] = $last24Data['Min'] . '"' . $row['MinPlayer'] . '",';
            $found = true;
            $placed = true;
        }
        else if($placed && $row = mysqli_fetch_array($last24Query))
        {
            $placed = false;
            if($row['Hours'] == $stop_date->format('H:00'))
            {
                $intervals = $intervals . '"' . $row['Hours'] . '",';
                $last24Data['Avg'] = $last24Data['Avg'] . '"' . $row['AvgPlayer'] . '",';
                $last24Data['Max'] = $last24Data['Max'] . '"' . $row['MaxPlayer'] . '",';
                $last24Data['Min'] = $last24Data['Min'] . '"' . $row['MinPlayer'] . '",';
                $found = true;
                $placed = true;
            }
        }
        if(!$found)
        {
            $intervals = $intervals . '"' . $stop_date->format('H:00') . '",';
            $last24Data['Avg'] = $last24Data['Avg'] . '"' . "0" . '",';
            $last24Data['Max'] = $last24Data['Max'] . '"' . "0" . '",';
            $last24Data['Min'] = $last24Data['Min'] . '"' . "0" . '",';
        }

        $stop_date->modify('+1 hour');
    }
    while($row = mysqli_fetch_array($last24Query))
    {
        $intervals = $intervals . '"' . $row['Hours'] . "|" . $stop_date->format('H:00') . '",';
        $last24Data['Avg'] = $last24Data['Avg'] . '"' . $row['AvgPlayer'] . '",';
        $last24Data['Max'] = $last24Data['Max'] . '"' . $row['MaxPlayer'] . '",';
        $last24Data['Min'] = $last24Data['Min'] . '"' . $row['MinPlayer'] . '",';
        $stop_date->modify('+1 hour');
    }

    $intervals = trim($intervals, ",");
    $last24Data['Avg'] = trim($last24Data['Avg'], ",");
    $last24Data['Max'] = trim($last24Data['Max'], ",");
    $last24Data['Min'] = trim($last24Data['Min'], ",");
    ?>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.5.0/Chart.min.js"></script>
    <div style="width:100%;margin: auto; text-align:center;"><h3><?php echo $lang['last_24h']; ?></h3></div>
    <canvas id="Last24_<?php print($db_index) ?>" style="width:99%; max-width: 99%;"></canvas>
    <script>
        var xValues = [<?php echo $intervals; ?>];
        new Chart("Last24_<?php print($db_index) ?>", {
            type: "line",
            data: {
                labels: xValues,
                datasets: [{ 
                    label: '<?php echo $lang['maximum_players']; ?>',
                    data: [<?php echo $last24Data['Max']; ?>],
                    borderColor: "red",
                    lineTension: 0,
                    fill: false
                },{ 
                    label: '<?php echo $lang['average_players']; ?>',
                    data: [<?php echo $last24Data['Avg']; ?>],
                    borderColor: "green",
                    fill: false
                },{ 
                    label: '<?php echo $lang['minimum_players']; ?>',
                    data: [<?php echo $last24Data['Min']; ?>],
                    borderColor: "blue",
                    lineTension: 0,
                    fill: false
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: {
                        position: 'top',
                    }
                },
                scales: {
                    x: {
                        grid: {
                        display: true,
                        color: '#FF0000',
                        }
                    },
                    y: {
                        grid: {
                        display: true,
                        color: '#FF0000',
                        },
                    }
                }
            }
        });
    </script>
    <?php
}

function func_display_31days_status($localsql, $db_index)
{
    global $lang;
    $intervals = "";
    $last24Data = array();
    $last24Data['Avg'] = "";
    $last24Data['Max'] = "";
    $last24Data['Min'] = "";

    $hours_today = (int)date('H');
    $last24Query = $localsql->query(
    "SELECT 
        FROM_UNIXTIME(UNIX_TIMESTAMP(`time`), '%m.%d') AS Days,
        (SUM(`playercount`)/1440) AS AvgPlayer,
        MAX(`playercount`) AS MaxPlayer,
        MIN(`playercount`) AS MinPlayer
    FROM `webplayercount`
    WHERE `time` BETWEEN (NOW() - INTERVAL 31 DAY) AND (NOW() - INTERVAL $hours_today HOUR)
    GROUP BY DAY(`time`), MONTH(`time`) ORDER BY `time` ASC;");

    $stop_date = new DateTime();
    $stop_date->modify('-31 day');
    $placed = true;
    for ($i=0; $i < 31; $i++) {
        $found = false;
        if(!$placed && $row['Days'] == $stop_date->format('m.d'))
        {
            $intervals = $intervals . '"' . $row['Days'] . '",';
            $last24Data['Avg'] = $last24Data['Avg'] . '"' . $row['AvgPlayer'] . '",';
            $last24Data['Max'] = $last24Data['Max'] . '"' . $row['MaxPlayer'] . '",';
            $last24Data['Min'] = $last24Data['Min'] . '"' . $row['MinPlayer'] . '",';
            $found = true;
            $placed = true;
        }
        else if($placed && $row = mysqli_fetch_array($last24Query))
        {
            $placed = false;
            if($row['Days'] == $stop_date->format('m.d'))
            {
                $intervals = $intervals . '"' . $row['Days'] . '",';
                $last24Data['Avg'] = $last24Data['Avg'] . '"' . $row['AvgPlayer'] . '",';
                $last24Data['Max'] = $last24Data['Max'] . '"' . $row['MaxPlayer'] . '",';
                $last24Data['Min'] = $last24Data['Min'] . '"' . $row['MinPlayer'] . '",';
                $found = true;
                $placed = true;
            }
        }
        if(!$found)
        {
            $intervals = $intervals . '"' . $stop_date->format('m.d') . '",';
            $last24Data['Avg'] = $last24Data['Avg'] . '"' . "0" . '",';
            $last24Data['Max'] = $last24Data['Max'] . '"' . "0" . '",';
            $last24Data['Min'] = $last24Data['Min'] . '"' . "0" . '",';
        }

        $stop_date->modify('+1 day');
    }

    $intervals = trim($intervals, ",");
    $last24Data['Avg'] = trim($last24Data['Avg'], ",");
    $last24Data['Max'] = trim($last24Data['Max'], ",");
    $last24Data['Min'] = trim($last24Data['Min'], ",");
    ?>
    <div style="width:100%;margin: auto; text-align:center;"><h3><?php echo $lang['last_31days']; ?></h3></div>
    <canvas id="Last31Day_<?php print($db_index) ?>" style="width:99%; max-width: 99%;"></canvas>
    <script>
        var xValues = [<?php echo $intervals; ?>];
        new Chart("Last31Day_<?php print($db_index) ?>", {
            type: "line",
            data: {
                labels: xValues,
                datasets: [{ 
                    label: '<?php echo $lang['maximum_players']; ?>',
                    data: [<?php echo $last24Data['Max']; ?>],
                    borderColor: "red",
                    lineTension: 0,
                    fill: false
                },{ 
                    label: '<?php echo $lang['average_players']; ?>',
                    data: [<?php echo $last24Data['Avg']; ?>],
                    borderColor: "green",
                    fill: false
                },{ 
                    label: '<?php echo $lang['minimum_players']; ?>',
                    data: [<?php echo $last24Data['Min']; ?>],
                    borderColor: "blue",
                    lineTension: 0,
                    fill: false
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: {
                        position: 'top',
                    }
                },
                scales: {
                    x: {
                        grid: {
                        display: true,
                        color: '#FF0000',
                        }
                    },
                    y: {
                        grid: {
                        display: true,
                        color: '#FF0000',
                        },
                    }
                }
            }
        });
    </script>
<?php
}

function func_display_12months_status($localsql, $db_index)
{
    global $lang;
    $intervals = "";
    $last24Data = array();
    $last24Data['Avg'] = "";
    $last24Data['Max'] = "";
    $last24Data['Min'] = "";

    $days_in_month = (int)date('d') + 1;

    $last24Query = $localsql->query(
    "SELECT 
        FROM_UNIXTIME(UNIX_TIMESTAMP(`time`), '%y.%m') AS Months,
        AVG(`playercount`) AS AvgPlayer,
        MAX(`playercount`) AS MaxPlayer,
        MIN(`playercount`) AS MinPlayer
    FROM `webplayercount`
    WHERE `time` BETWEEN (NOW() - INTERVAL 12 MONTH) AND (NOW() - INTERVAL $days_in_month DAY)
    GROUP BY MONTH(`time`) ORDER BY `time` ASC;");

    $stop_date = new DateTime();
    $stop_date->modify('-12 month');
    $placed = true;
    for ($i=0; $i < 12; $i++) {
        $found = false;
        if(!$placed && $row['Months'] == $stop_date->format('y.m'))
        {
            $intervals = $intervals . '"' . $row['Months'] . '",';
            $last24Data['Avg'] = $last24Data['Avg'] . '"' . $row['AvgPlayer'] . '",';
            $last24Data['Max'] = $last24Data['Max'] . '"' . $row['MaxPlayer'] . '",';
            $last24Data['Min'] = $last24Data['Min'] . '"' . $row['MinPlayer'] . '",';
            $found = true;
            $placed = true;
        }
        else if($placed && $row = mysqli_fetch_array($last24Query))
        {
            $placed = false;
            if($row['Months'] == $stop_date->format('y.m'))
            {
                $intervals = $intervals . '"' . $row['Months'] . '",';
                $last24Data['Avg'] = $last24Data['Avg'] . '"' . $row['AvgPlayer'] . '",';
                $last24Data['Max'] = $last24Data['Max'] . '"' . $row['MaxPlayer'] . '",';
                $last24Data['Min'] = $last24Data['Min'] . '"' . $row['MinPlayer'] . '",';
                $found = true;
                $placed = true;
            }
        }
        if(!$found)
        {
            $intervals = $intervals . '"' . $stop_date->format('y.m') . '",';
            $last24Data['Avg'] = $last24Data['Avg'] . '"' . "0" . '",';
            $last24Data['Max'] = $last24Data['Max'] . '"' . "0" . '",';
            $last24Data['Min'] = $last24Data['Min'] . '"' . "0" . '",';
        }

        $stop_date->modify('+1 month');
    }

    $intervals = trim($intervals, ",");
    $last24Data['Avg'] = trim($last24Data['Avg'], ",");
    $last24Data['Max'] = trim($last24Data['Max'], ",");
    $last24Data['Min'] = trim($last24Data['Min'], ",");
    ?>
    <div style="width:100%;margin: auto; text-align:center;"><h3><?php echo $lang['past_year']; ?></h3></div>
    <canvas id="Last12month_<?php print($db_index) ?>" style="width:99%; max-width: 99%;"></canvas>
    <script>
        var xValues = [<?php echo $intervals; ?>];
        new Chart("Last12month_<?php print($db_index) ?>", {
            type: "line",
            data: {
                labels: xValues,
                datasets: [{ 
                    label: '<?php echo $lang['maximum_players']; ?>',
                    data: [<?php echo $last24Data['Max']; ?>],
                    borderColor: "red",
                    lineTension: 0,
                    fill: false
                },{ 
                    label: '<?php echo $lang['average_players']; ?>',
                    data: [<?php echo $last24Data['Avg']; ?>],
                    borderColor: "green",
                    fill: false
                },{ 
                    label: '<?php echo $lang['minimum_players']; ?>',
                    data: [<?php echo $last24Data['Min']; ?>],
                    borderColor: "blue",
                    lineTension: 0,
                    fill: false
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: {
                        position: 'top',
                    }
                },
                scales: {
                    x: {
                        grid: {
                        display: true,
                        color: '#FF0000',
                        }
                    },
                    y: {
                        grid: {
                        display: true,
                        color: '#FF0000',
                        },
                    }
                }
            }
        });
    </script>
<?php
}

function func_addstyle()
{
    ?>
        <script type="text/javascript" src="//cdn.jsdelivr.net/npm/slick-carousel@1.8.1/slick/slick.min.js"></script>
        <link rel="stylesheet" type="text/css" href="//cdn.jsdelivr.net/npm/slick-carousel@1.8.1/slick/slick.css"/>
        <link rel="stylesheet" type="text/css" href="//cdn.jsdelivr.net/npm/slick-carousel@1.8.1/slick/slick-theme.css"/>
    <?php
}

function func_slider_script()
{
    ?>
    <script>
        $(".slider").slick({
            infinite: false,
            arrows: true
        });
        $('.slider-for').slick({
            infinite: false,
            touchMove: false,
            draggable: false,
            accessibility: false,
            slidesToShow: 1,
            slidesToScroll: 1,
            arrows: false,
            fade: true,
            asNavFor: '.slider-nav'
        });
        $('.slider-nav').slick({
            infinite: false,
            slidesToShow: 1,
            slidesToScroll: 1,
            asNavFor: '.slider-for',
            dots: true,
            centerMode: false,
            focusOnSelect: false,
        });

        $('.admins-slider').slick({
            slidesToShow: 1,
            slidesToScroll: 1,
            dots: false,
            centerMode: false,
            focusOnSelect: false,
            infinite: true,
            autoplay: true,
            autoplaySpeed: 3000,
            pauseOnFocus: true,
            pauseOnHover: true
        });
    </script>
    <?php
}

Utils::header("Főoldal", "func_addstyle");
Utils::body("func_mainpage");
Utils::footer("func_slider_script");