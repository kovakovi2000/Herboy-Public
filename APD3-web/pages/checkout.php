<?php
if(!ErrorManager::isDevelpor()) {
    include_once($_SERVER['DOCUMENT_ROOT'] . "/dev.php");
    exit();
}
ErrorManager::$force_no_display = true;
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/Config.php");
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/includes/Utils.php");

$items = [
    1 => ['title' => '1500', 'price' => '1000'],
    2 => ['title' => '2600', 'price' => '2000'],
    3 => ['title' => '4000', 'price' => '3000'],
    4 => ['title' => '8000', 'price' => '5000'],
    5 => ['title' => '13000', 'price' => '10000'],
    6 => ['title' => '20000', 'price' => '15000'],
];

$pp = isset($_GET['pp']) ? (int)$_GET['pp'] : 0;
$item = $items[$pp] ?? null;

function func_addstyle()
{
    ?>
    <script type="text/javascript" src="//cdn.jsdelivr.net/npm/slick-carousel@1.8.1/slick/slick.min.js"></script> 
    <script src="https://www.paypal.com/sdk/js?client-id=AZNFTrpKE63EyYz9HbPvb0rObBWSJF-iXIIogAgKcMkS-cp1ZaSder2KdERANj2whPSyWYi9ljtIGQT7&currency=HUF&components=buttons,funding-eligibility&enable-funding=paypal,card"></script>
    <link rel="stylesheet" type="text/css" href="//cdn.jsdelivr.net/npm/slick-carousel@1.8.1/slick/slick.css"/>
    <link rel="stylesheet" type="text/css" href="//cdn.jsdelivr.net/npm/slick-carousel@1.8.1/slick/slick-theme.css"/>
    <link rel="stylesheet" type="text/css" href="<?php echo Utils::get_url('css/chcs.css');?>">

    <?php
}

function func_mainpage()
{
    global $item;
    global $sql;
    if (isset($_SESSION['account'])) {
        $userProfile = unserialize($_SESSION['account']);
        
        if ($userProfile) {
            $lastLoginName = $userProfile->LastLoginName ?? 'Ismeretlen Profil';
            $userId = $userProfile->id ?? 'Ismeretlen ID';
            $userIP = $userProfile->LastLoginIP;
        } else {
            exit();
        }
    } else {
        echo "<meta http-equiv='refresh' content='0;url=/store'>";
        exit();
    }
    function generateCsrfToken() {
        if (empty($_SESSION['csrf_token'])) {
            $_SESSION['csrf_token'] = bin2hex(random_bytes(32)); // Generate a secure token
        }
        return $_SESSION['csrf_token'];
    }
    $csrf_token = generateCsrfToken();

    $apiKey = '1647a02a4a83ef';
    $ipinfoUrl = "https://ipinfo.io/{$userIP}/json?token={$apiKey}";

    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $ipinfoUrl);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
    $locationData = curl_exec($ch);
    curl_close($ch);

    $locationData = json_decode($locationData, true);
    $userCountryCode = strtoupper($locationData['country'] ?? ''); // Ensure uppercase for comparison
    $userCountryName = '';
    

    ?>

    <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <script type="text/javascript">
    const userCountryCode = "<?php echo htmlspecialchars($userCountryCode); ?>"; // Pass PHP variable to JS
</script>
        <script type="text/javascript" src="<?php echo Utils::get_url('js/chcs.js'); ?>"></script>
    </head>
    <body>
        <div class="container mt-5">
            <div class="modern-card">
                <div class="modern-card-header text-center">
                    <h1>Prémium Pont Vásárlás</h1>
                </div>
                <div class="modern-card-body">
                    <?php if ($item): ?>
                        <form id="payment-form" class="mt-4" method="POST">
                            <input type="hidden" name="csrf_token" value="<?php echo htmlspecialchars($csrf_token, ENT_QUOTES, 'UTF-8'); ?>" />
                            <div class="form-group">
                                <label for="name">Név:</label>
                                <input type="text" id="name" name="name" value="<?php echo htmlspecialchars($lastLoginName, ENT_QUOTES, 'UTF-8'); ?>" class="form-control" readonly>
                            </div>
                            <div class="form-group">
                                <label for="userid">UserID:</label>
                                <input type="text" id="userid" name="userid" value="#<?php echo htmlspecialchars($userId, ENT_QUOTES, 'UTF-8'); ?>" class="form-control" readonly>
                            </div>
                            <div class="form-group">
                                <label for="premium_points">PrémiumPont: (Bónusz nélkül feltűntetett összeg)</label>
                                <input type="text" id="premium_points" name="premium_points" value="<?php echo htmlspecialchars($item['title'], ENT_QUOTES, 'UTF-8'); ?>" class="form-control" readonly>
                            </div>
                            <div class="form-group">
                                <label for="price">Ára:</label>
                                <input type="text" id="price" name="price" value="<?php echo htmlspecialchars($item['price'], ENT_QUOTES, 'UTF-8'); ?>" class="form-control" readonly>
                            </div>

                            <!-- New fields -->
                            <div class="form-group">
    <label for="address">Utca, házszám:</label>
    <input type="text" id="address" name="address" class="form-control" required pattern="[a-zA-Z0-9\s\/áéíóöőúüűÁÉÍÓÖŐÚÜŰ\.\-]+" title="Kérjük, csak alfanumerikus karaktereket használjon.">
</div>

                            <div class="form-group">
                                <label for="city">Település:</label>
                                <input type="text" id="city" name="city" class="form-control" required pattern="[a-zA-Z\sáéíóöőúüűÁÉÍÓÖŐÚÜŰ]+" title="Kérjük, csak betűket használjon.">
                            </div>

                            <div class="form-group">
                                <label for="postal_code">Irányítószám:</label>
                                <input type="text" id="postal_code" name="postal_code" class="form-control" required pattern="\d{4,5}" title="Kérjük, adjon meg egy 4 vagy 5 jegyű irányítószámot.">
                            </div>
                            <div class="form-group">
                                <label for="country">Ország:</label>
                                <input type="text" id="country" name="country" value="<?php echo htmlspecialchars($userCountryName); ?>" class="form-control" readonly>
                            </div>

                            <div id="paypal-button-container"></div>
                        </form>

                    <?php else: ?>
                        <p>Invalid item selected.</p>
                    <?php endif; ?>
                    <a href="store">Vissza az Áruházba</a>
                </div>
            </div>
        </div>

        
        <script type="text/javascript">
            var phpData = {
                lastLoginName: "<?php echo htmlspecialchars($lastLoginName); ?>",
                userId: "<?php echo htmlspecialchars($userId); ?>",
                itemTitle: "<?php echo htmlspecialchars($item['title']); ?>",
                itemPrice: "<?php echo (int)str_replace(["Ft", ".", " "], ["", "", ""], $item["price"]); ?>",
                country: "<?php echo htmlspecialchars($userCountryCode); ?>"

            };

        </script>
        <script type="text/javascript" src="<?php echo Utils::get_url('js/paypal.js?ver=9808102'); ?>"></script>
    </body>
    <?php
}


if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (!isset($_POST['csrf_token']) || $_POST['csrf_token'] !== $_SESSION['csrf_token']) {

        die("Invalid CSRF token.");
    }
    unset($_SESSION['csrf_token']);
}
Utils::header("Fizetés", "func_addstyle");
Utils::body("func_mainpage");
Utils::footer();
?>
