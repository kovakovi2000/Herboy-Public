<?php
ErrorManager::$force_no_display = true;
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/Config.php");
include_once $_SERVER['DOCUMENT_ROOT'] . '/configs/lang/switch.php';


global $sql;
if (isset($_SESSION['account'])) {
    $userProfile = @unserialize($_SESSION['account']);
    
    if ($userProfile && is_object($userProfile) && isset($userProfile->id)) {
        $userId = $userProfile->id;
    } else {
        session_destroy();
        header("Location: /login");
        exit();
    }
} else {
    header("Location: /index");
    exit();
}

function func_mainpage() {
    global $lang;
    global $sql, $userId;

    $queryPremiumPoints = "SELECT comment, amount, created, paymethodid FROM `" . Config::$t_PurchaseLog2_name . "` WHERE comment = ? ORDER BY created DESC";
    $stmtPremium = $sql->prepare($queryPremiumPoints);
    $stmtPremium->bind_param("s", $userId);
    $stmtPremium->execute();
    $resultPremium = $stmtPremium->get_result();

    $paymentMethods = [
        1 => $lang['transfer'],
        2 => $lang['refund'],
        5 => $lang['paypal'],
        10 => $lang['failed'],
    ];
    ?>

<body>
<div class="modern-card-container">
    <div class="modern-card" style="width: 1200px">
        <div class="modern-card-body">
            <d class="page-header col-md-12" id="banner" style="border: none !important;">
            <h1 ALIGN=center><b><h2 style="color: #d1d1d1;"><?php echo $lang['pp_credit']; ?></h2></b></h1>
            <br>
            <div class="scrollable-table" style="max-height: 200px; overflow-y: auto;">
                <table class="table zebra-stripes">
                    <thead>
                        <tr>
                            <th style="text-align: left;"><?php echo $lang['date']; ?></th>
                            <th style="text-align: center;"><?php echo $lang['amount']; ?></th>
                            <th style="text-align: right;"><?php echo $lang['payment_method']; ?></th>
                        </tr>
                    </thead>
                    <tbody>
                    <?php
while ($row = $resultPremium->fetch_assoc()) {
    $purchaseDate = $row['created'];
    $premiumPoints = $row['amount'] . " " . $lang['pp_point'];
    $paymethodid = $row['paymethodid'];
    $paymentMethod = $paymentMethods[$paymethodid] ?? "Ismeretlen mód";

    $labelClass = "";
    if ($paymentMethod === $lang['transfer'] || $paymentMethod === $lang['paypal']) {
        $labelClass = "badge badge-success";
    } elseif ($paymentMethod === $lang['refund']) {
        $labelClass = "badge badge-orange";
    } elseif ($paymentMethod === $lang['failed']) {
        $labelClass = "badge badge-danger";
    }


    echo "<tr>";
    echo "<td style='text-align: left;'>" . htmlspecialchars($purchaseDate) . "</td>";
    echo "<td style='text-align: center;'>" . htmlspecialchars($premiumPoints) . "</td>";
    echo "<td style='text-align: right;'><span class='" . $labelClass . "'>" . htmlspecialchars($paymentMethod) . "</span></td>";
    echo "</tr>";
                    }
                    $stmtPremium->close();
                    ?>
                    </tbody>
                </table>

            </div>
            <h1 ALIGN=center><b><h2 style="color: #d1d1d1; margin-top: 20px;"><?php echo $lang['pp_items']; ?></h2></b></h1>

            <br>
            <div class="scrollable-table" style="max-height: 200px; overflow-y: auto;">
                <table class="table zebra-stripes" id="itemsTable">
                    <thead>
                        <tr>
                            <th style="text-align: left;"><?php echo $lang['date']; ?></th>
                            <th style="text-align: center;"><?php echo $lang['pp_item']; ?></th>
                            <th style="text-align: right;"><?php echo $lang['amount']; ?></th>
                        </tr>
                    </thead>
                    <tbody>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<script>
let offset = 0;
const limit = 25;
let loading = false;
let hasMoreItems = true;

async function loadItems() {
    if (loading || !hasMoreItems) return;

    loading = true;
    try {
        const response = await fetch(`?action=loadItems&offset=${offset}&limit=${limit}`);
        if (response.ok) {
            const items = await response.json();

            if (items.length > 0) {
                const tableBody = document.querySelector('#itemsTable tbody');
                items.forEach(item => {
                    const row = document.createElement('tr');
                    row.innerHTML = `
                        <td style='text-align: left;'>${item.buytime}</td>
                        <td style='text-align: center;'>${item.buyname}</td>
                        <td style='text-align: right;'><span class='badge badge-danger'>${item.buycost} <?php echo $lang['pp_point'] ?></span></td>
                    `;
                    tableBody.appendChild(row);
                });
                offset += items.length;
            } else {
                hasMoreItems = false;
            }
        } else {
            console.error('Failed to load items:', response.statusText);
        }
    } catch (error) {
        console.error("Error loading items:", error);
    } finally {
        loading = false;
    }
}
const scrollableTables = document.querySelectorAll('.scrollable-table');
scrollableTables.forEach(table => {
    table.addEventListener('mouseenter', function() {
        document.body.classList.add('no-scroll');
    });

    table.addEventListener('mouseleave', function() {
        document.body.classList.remove('no-scroll');
    });

    table.addEventListener('scroll', function() {
        if (this.scrollTop + this.clientHeight >= this.scrollHeight - 10) {
            loadItems();
        }
    });
});

loadItems();
</script>

<style>
.scrollable-table {
    max-height: 200px;
    overflow-y: auto;
}

.no-scroll {
    overflow: hidden;
}
::-webkit-scrollbar {
  width: 12px;
}

::-webkit-scrollbar-track {
  background: #f1f1f1;
}

::-webkit-scrollbar-thumb {
  background-color: #888;
  border-radius: 10px;
  border: 3px solid #f1f1f1;
}

::-webkit-scrollbar-thumb:hover {
  background-color: #555;
}

html {
  scrollbar-color: #888 #000000;
  scrollbar-width: thin;
}
.badge-orange {
    background-color: #fd7e14;
    color: black;
}
.badge-success {
    color: black;
}
.badge-danger {
    color: black;
}
@media (max-width: 768px) {
    .modern-card {
        width: 90%; /* Set a percentage width for smaller screens */
        max-width: 400px; /* Optional: Set a maximum width */
        margin: 0 auto; /* Center the card */
    }
}
</style>
</body>
<?php
}

if (isset($_GET['action']) && $_GET['action'] === 'loadItems') {
    $offset = intval($_GET['offset']);
    $limit = intval($_GET['limit']);
    $queryItems = "SELECT buyname, buytime, buycost FROM buy_datas WHERE aid = ? ORDER BY buytime DESC LIMIT ?, ?";
    $stmtItems = $sql->prepare($queryItems);
    $stmtItems->bind_param("sii", $userId, $offset, $limit);
    $stmtItems->execute();
    $resultItems = $stmtItems->get_result();

    $items = [];
    while ($row = $resultItems->fetch_assoc()) {
        $items[] = $row;
    }

    header('Content-Type: application/json');
    echo json_encode($items);
    $stmtItems->close();
    exit();
}

function func_addstyle() {
    ?>
    <script type="text/javascript" src="//cdn.jsdelivr.net/npm/slick-carousel@1.8.1/slick/slick.min.js"></script>
    <link rel="stylesheet" type="text/css" href="//cdn.jsdelivr.net/npm/slick-carousel@1.8.1/slick/slick.css"/>
    <link rel="stylesheet" type="text/css" href="//cdn.jsdelivr.net/npm/slick-carousel@1.8.1/slick/slick-theme.css"/>
    <?php
}

Utils::header("Vásárlásaim", "func_addstyle");
Utils::body("func_mainpage");
Utils::footer();
?>
