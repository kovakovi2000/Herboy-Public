<?php
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/Config.php");
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/includes/Utils.php");

date_default_timezone_set('Europe/Budapest');

$userProfile = null;
if (isset($_SESSION['account'])) {
    $userProfile = unserialize($_SESSION['account']);
    if(!$userProfile || !$userProfile->PermLvl->isAdmin())
    {
        Utils::html_error(401);
        exit();
    }

    if ($userProfile) {
        $userId = $userProfile->id ?? 0;
    } else {
        exit;
    }
} else
{
    Utils::html_error(401);
    exit();
}

function randomColor() {
    // Ensure red, green, and blue values are within the range for brighter colors
    $r = mt_rand(100, 255); // Red between 100-255 (avoid too dark)
    $g = mt_rand(100, 255); // Green between 100-255 (avoid too dark)
    $b = mt_rand(100, 255); // Blue between 100-255 (avoid too dark)
    
    // Return the color in hex format
    return sprintf("#%02X%02X%02X", $r, $g, $b);
}

function func_mainpage()
{
    global $sql;

    $admins_result = $sql->select('herboy_regsystem', ['LastLoginName', 'LastLoginID'], 'AdminLvL1 = 4');
    $admins = [];

    if ($admins_result) {
        while ($row = mysqli_fetch_assoc($admins_result)) {
            $admins[$row['LastLoginID']] = [
                'LastLoginName' => $row['LastLoginName'],
                'active_minutes' => array_fill(0, 31, 0)
            ];
        }
    }

    $activity_result = $sql->query("
        SELECT steamid, DATE(time) as activity_date, COUNT(*) as active_minutes
        FROM amx_activity
        WHERE time >= NOW() - INTERVAL 31 DAY
        GROUP BY steamid, activity_date
        ORDER BY activity_date ASC
    ");

    // Get the current date in the same timezone
    $current_date = new DateTime('now', new DateTimeZone('Europe/Budapest'));

    if ($activity_result) {
        while ($row = mysqli_fetch_assoc($activity_result)) {
            $steamid = $row['steamid'];
            $activity_date = $row['activity_date'];
            $active_minutes = (int)$row['active_minutes'];

            // Calculate the correct day index
            $activity_date_time = new DateTime($activity_date, new DateTimeZone('Europe/Budapest'));
            $day_index = (int)($current_date->diff($activity_date_time)->format('%a')); // Difference in days

            if (isset($admins[$steamid]) && $day_index >= 0 && $day_index < 31) {
                $admins[$steamid]['active_minutes'][30 - $day_index] = $active_minutes; // Adjust the index accordingly
            }
        }
    }

    $admin_names = [];
    $chart_data = [];
    $chart_colors = [];

    foreach ($admins as $steamid => $admin_data) {
        $admin_names[] = '"' . $admin_data['LastLoginName'] . '"';
        $chart_data[] = json_encode($admin_data['active_minutes']);
        $chart_colors[] = randomColor();
    }
    ?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Active Minutes (Last 31 Days)</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js@3.8.0/dist/chart.min.js"></script>
    <style>
        body {
            background-color: #f4f4f4; /* Light background for the page */
            display: flex;
            justify-content: flex-start; /* Align everything to the left */
            min-height: 100vh; /* Ensure it covers the whole viewport */
            margin: 0;
            padding: 20px;
        }

        canvas {
            background-color: rgba(0, 0, 0, 0.7); /* Light background for the chart */
        }

        .toggle-buttons {
            display: flex;
            flex-direction: column; /* Arrange buttons vertically */
            position: fixed; /* Fix the buttons in place */
            /* left: 20px; Distance from the left edge of the screen */
            top: 1%; /* Center vertically */
            /* transform: translateY(-50%); Offset to center */
            z-index: 1; /* Ensure the buttons are on top */
        }

        .toggle-buttons button {
            margin: 5px 0; /* Vertical margin for buttons */
            padding: 10px 15px;
            background-color: rgba(0, 0, 0, 0.7); /* Button background color */
            color: white; /* White text */
            border: none;
            border-radius: 5px; /* Rounded corners */
            cursor: pointer; /* Pointer cursor on hover */
        }

        .toggle-buttons button:hover {
            background-color: #0056b3; /* Darker blue on hover */
        }
        #totalActivityTime {
    display: none; /* Initially hidden on page load */
    text-align: center;
    margin-top: 20px;
    font-size: 18px;
    font-weight: bold;
    z-index: 2; /* Ensure it's positioned correctly */
    max-height: 200px; /* Set a fixed height */
    overflow-y: auto; /* Allow scrolling for overflow content */
    padding: 10px;
    border: 1px solid #ccc; /* Optional: Add a border for clarity */
    background-color: rgba(0, 0, 0, 0.7); /* Optional: Background color */
    color: white; /* Ensure text is visible */
}

        .chart-container {
            width: 100%;
            max-width: 1200px;
            margin: 0; /* Remove margin to make it flush with the button container */
            z-index: 0; /* Place chart behind other elements */
        }
        @media (max-width: 768px) { /* Adjust this breakpoint as needed */
            .chart-container {
                display: none; /* Hide the chart container */
            }

            .mobile-message {
                display: block; /* Show the mobile message */
                text-align: center; /* Center text */
                color: white; /* Text color */
                font-size: 18px; /* Font size for mobile message */
                margin-top: 20px; /* Margin above message */
            }
        }

        /* Show chart on larger screens */
        @media (min-width: 769px) {
            .mobile-message {
                display: none; /* Hide the mobile message */
            }
        }
    </style>
</head>
<body>
    <div class="toggle-buttons">
    <?php
// Assuming $admin_names contains the names of the admins
$sortedAdminNames = $admin_names;
sort($sortedAdminNames, SORT_STRING | SORT_FLAG_CASE); // Sort the admin names

// Print the Összes Admin button first
echo '<button onclick="toggleAll()">Összes Admin</button>'; // Összes Admin button

// Then print the sorted admin buttons
// foreach ($sortedAdminNames as $index => $name) {
    // echo '<button onclick="toggleDataset(' . array_search($name, $admin_names) . ')">' . trim($name, '"') . '</button>';
// }
?>
    </div>
    <div id="totalActivityTime"></div>
    <div class="chart-container">
    <!-- <div style="width: 75%; margin: auto;"> -->
        <canvas id="adminActivityChart"></canvas>
    </div>

    <div class="mobile-message">
    A grafikon nem átlátható telefonon. A jobb élmény érdekében, kérlek használj 'Asztali Módot'! Az "Összes Admin" gombbal megtekintheted az adminok aktivitását a grafikon nélkül is.
    </div>

    <script>
var ctx = document.getElementById('adminActivityChart').getContext('2d');

// Function to generate the last 31 days from today
function getLast31DaysLabels() {
    var labels = [];
    var today = new Date();
    
    for (var i = 0; i < 31; i++) {
        var pastDate = new Date();
        pastDate.setDate(today.getDate() - i);
        var day = pastDate.getDate().toString().padStart(2, '0');
        var month = (pastDate.getMonth() + 1).toString().padStart(2, '0');
        var year = pastDate.getFullYear();
        labels.unshift(`${year}-${month}-${day}`);
    }

    return labels;
}

var labels = getLast31DaysLabels();

var datasets = [
    <?php
    foreach ($chart_data as $index => $data) {
        echo '{
            label: ' . $admin_names[$index] . ',
            data: ' . $data . ',
            backgroundColor: "' . $chart_colors[$index] . '",
            borderColor: "' . $chart_colors[$index] . '",
            borderWidth: 2,
            fill: false,
            hidden: true // Initially show all datasets
        },';
    }
    ?>
];

// Create the chart
var adminActivityChart = new Chart(ctx, {
    type: 'line',
    data: {
        labels: labels,
        datasets: datasets
    },
    options: {
        responsive: true,
        scales: {
            y: {
                beginAtZero: true,
                title: {
                    display: true,
                    text: 'Aktív perc',
                    color: 'white',
                },
                ticks: {
                    color: 'white',
                }
            },
            x: {
                title: {
                    display: true,
                    text: 'Aktivitás (Utolsó 31 nap)',
                    color: 'white',
                },
                ticks: {
                    color: 'white',
                }
            }
        },
        plugins: {
            tooltip: {
                callbacks: {
                    label: function(tooltipItem) {
                        var datasetLabel = tooltipItem.dataset.label || '';
                        var dataPoint = tooltipItem.raw; // This is the value at the point
                        return datasetLabel + ': ' + dataPoint + ' perc'; // Customize tooltip display
                    }
                },
                // Enable tooltips
                enabled: true,
            },
            legend: {
                labels: {
                    color: 'white'
                },
                onClick: function(event, legendItem) {
                    var datasetIndex = legendItem.datasetIndex; // Get the index of the dataset
                    toggleDataset(datasetIndex); // Toggle the dataset visibility
                }
            }
        }
    }
});

// Add click event listener
ctx.canvas.addEventListener('click', function(event) {
    var activePoints = adminActivityChart.getElementsAtEventForMode(event, 'nearest', { intersect: true }, true);
    if (activePoints.length) {
        var firstPoint = activePoints[0]; // Get the first active point
        var datasetIndex = firstPoint.datasetIndex; // Get dataset index
        var dayIndex = firstPoint.index; // Get index of the day (0-30)
        
        // Get the corresponding value from the dataset
        var activeMinutes = adminActivityChart.data.datasets[datasetIndex].data[dayIndex];


    }
});


function toggleDataset(index) {
    adminActivityChart.data.datasets[index].hidden = !adminActivityChart.data.datasets[index].hidden;
    adminActivityChart.update();
    displayTotalActivityTime(); // Update the total activity time
}

function toggleAll() {
    var allHidden = adminActivityChart.data.datasets.every(dataset => dataset.hidden);
    adminActivityChart.data.datasets.forEach(dataset => dataset.hidden = !allHidden);
    adminActivityChart.update();
    displayTotalActivityTime(); // Update the total activity time
}

function displayTotalActivityTime() {
    var activeDatasets = adminActivityChart.data.datasets.filter(dataset => !dataset.hidden);
    var totalActivityElement = document.getElementById('totalActivityTime');
    
    totalActivityElement.innerHTML = ''; // Clear previous content

    if (activeDatasets.length === 1) {
        var activeMinutesArray = activeDatasets[0].data;
        var totalActiveMinutes = activeMinutesArray.reduce((a, b) => a + b, 0);
        var hours = Math.floor(totalActiveMinutes / 60); // Calculate hours
        var minutes = totalActiveMinutes % 60; // Calculate remaining minutes
        totalActivityElement.innerHTML = `${activeDatasets[0].label} aktivitása az utolsó 31 napban: ${hours} óra ${minutes} perc.`;
    } else if (activeDatasets.length > 1) {
        let totalActivityString = '';

        activeDatasets.forEach(dataset => {
            var activeMinutesArray = dataset.data;
            var totalActiveMinutes = activeMinutesArray.reduce((a, b) => a + b, 0);
            var hours = Math.floor(totalActiveMinutes / 60); // Calculate hours
            var minutes = totalActiveMinutes % 60; // Calculate remaining minutes
            totalActivityString += `${dataset.label} aktivitása az utolsó 31 napban: ${hours} óra ${minutes} perc.<br>`;
        });

        totalActivityElement.innerHTML = totalActivityString;
        fadeIn(totalActivityElement);
    }

    if (activeDatasets.length > 0) {
        totalActivityElement.style.display = 'block'; // Show if there are active datasets
    } else {
        totalActivityElement.style.display = 'none'; // Hide if no datasets are active
    }
}

// Function to fade in the content smoothly
function fadeIn(element) {
    element.style.opacity = 0; // Start hidden
    let last = +new Date();
    let opacity = 0;
    
    element.style.display = "block"; // Make it visible to start animation
    
    function tick() {
        opacity += (new Date() - last) / 400; // Adjust duration here
        element.style.opacity = opacity;
        last = +new Date();

        if (opacity < 1) {
            requestAnimationFrame(tick); // Continue until fully visible
        }
    }
    requestAnimationFrame(tick);
}
</script>


</body>
</html>

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

Utils::header("Admin Aktivitás", "func_addstyle");
Utils::body("func_mainpage");
Utils::footer();
?>
