<?php

if (isset($_SERVER["HTTP_CF_CONNECTING_IP"])) {
    $clientIp = $_SERVER["HTTP_CF_CONNECTING_IP"];
} else {
    $clientIp = $_SERVER["REMOTE_ADDR"];
}

if($clientIp != "10.0.0.1")
{
    header('HTTP/1.1 403 Forbidden');
    exit();
}


    if (session_status() === PHP_SESSION_NONE)
        session_start();
    include_once("utils.php");
    include_once("error_manager.php");
    include_once("sql.php");
    include_once("validate_token.php");
?>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Node Graph with Dropdown - Dark Mode</title>
        
        <!-- Include Bootstrap 5 CSS -->
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">

        <!-- Include jQuery -->
        <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

        <!-- Include Bootstrap Icons -->
        <link href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-icons/1.9.1/font/bootstrap-icons.min.css" rel="stylesheet">

        <!-- Include Vis.js -->
        <script src="https://cdnjs.cloudflare.com/ajax/libs/vis/4.21.0/vis.min.js"></script>
        <link href="https://cdnjs.cloudflare.com/ajax/libs/vis/4.21.0/vis.min.css" rel="stylesheet" type="text/css" />
        
        <link href="css/main.css?ver=2" rel="stylesheet" type="text/css"/>
        <link href="css/network.css?ver=352352" rel="stylesheet" type="text/css"/>
    </head>
    <body>

        <!-- Dropdown Menu (Initially Hidden) -->
        <div id="dropdownMenu">
            <div style="display: flex; align-content: center !important; align-items: center !important; justify-content: flex-start;">
                <!-- Input box for indicator search -->
                <input type="text" id="indicator_search" class="form-control me-2 p-0" 
                    style="font-size: 0.60rem; padding: 0.25rem; border-radius: 0.2rem; width: 300px;" 
                    placeholder="Enter indicator" />

                <!-- Dropdown box for selecting indicator type -->
                <select id="indicator_type" class="form-select w-auto p-0" 
                        style="font-size: 0.60rem; padding: 0.25rem; border-radius: 0.2rem; width: 90px;">
                    <option value="any" selected>Any</option>
                    <option value="UUID">UUID</option>
                    <option value="steamid">SteamID</option>
                    <option value="ip">IP</option>
                    <option value="oldkey">OldKey</option>
                    <option value="account">Account</option>
                    <option value="account_uuid">Account UUID</option>
                    <option value="account_info">Account Info</option>
                    <option value="regex">Regex</option>
                </select>

                <div class="form-check" style="transform: scale(0.7);">
                    <input class="form-check-input" type="checkbox" value="" id="fixHorizontalCheck" checked>
                    <label class="form-check-label" for="fixHorizontalCheck">
                        Fix nodes horizontally
                    </label>
                </div>
            </div>

            <!-- Explanation text that updates dynamically -->
            <p id="indicator_description" class="mt-0">Search any type of indicator.</p>

            <!-- Dropdown Arrow Button -->
            <div id="dropdownArrow"><i class="bi bi-chevron-double-down"></i></div>

            

            <button id="applyButton" class="btn btn-primary">Apply</button>
            <div id="respond_display"></div>
            <button id="desyncClusterButton" class="btn btn-danger">Desync Cluster</button>
        </div>

        <script src="js/ui.js?ver=5" type="text/javascript"></script>

        <!-- Network Visualization -->
        <div id="network"></div>

        <!-- Bootstrap and jQuery Scripts -->
        <script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.11.6/dist/umd/popper.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.min.js"></script>
        
        <script src="js/network.js?ver=<?php echo microtime(true); ?>" type="text/javascript"></script>
    </body>
</html>
