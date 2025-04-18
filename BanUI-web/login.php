<?php
// Generate CSRF token if it doesn't exist
if (!isset($_SESSION['csrf_token'])) {
    $_SESSION['csrf_token'] = bin2hex(random_bytes(32)); // 32 bytes = 64 characters
}
$csrf_token = $_SESSION['csrf_token'];

function startsWith($string, $word) {
    return strpos($string, $word) === 0;
}

$register_token = $_SERVER['QUERY_STRING'];
if(!regex_validate($register_token, 100) || !startsWith($register_token, "bf7a92f86f4df6ee144c32b47d419e5b"))
    $register_token = null;

?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - BanSys_v2</title>
    <link href="css/login.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-icons/1.9.1/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;700&display=swap" rel="stylesheet">
    <link href="css/login.css" rel="stylesheet">
</head>
<body>

    <canvas id="matrix"></canvas>

    <div class="login-container">
        <div class="login-box">
            <div class="loading-overlay">
                <i class="bi bi-arrow-repeat"></i>
            </div>
            <?php if(empty($register_token)): ?>
                <h2 class="glow-text">Login to BanSys_v2 WebUI</h2>
                <form id="loginForm">
                    <!-- CSRF Token -->
                    <input type="hidden" name="csrf_token" value="<?php echo $csrf_token; ?>">

                    <!-- Updated Username Input -->
                    <div class="form__group field">
                        <input type="input" class="form__field" id="username" name="username" placeholder="Username" required />
                        <label for="username" class="form__label">Username</label>
                    </div>

                    <!-- Updated Password Input -->
                    <div class="form__group field">
                        <input type="password" class="form__field" id="password" name="password" placeholder="Password" required />
                        <label for="password" class="form__label">Password</label>
                    </div>

                    <button type="submit" class="btn btn-login">Login</button>
                </form>
                <script src="js/login.js"></script>
            <?php else: ?>
                <h2 class="glow-text">Register</h2>
                <div id="respond_display" style="color: red; margin-bottom: 15px;"></div>
                <form id="loginForm">
                    <!-- CSRF Token -->
                    <input type="hidden" name="csrf_token" value="<?php echo $csrf_token; ?>">
                    <input type="hidden" name="register_token" value="<?php echo $register_token; ?>">

                    <!-- Updated Username Input -->
                    <div class="form__group field">
                        <input type="input" class="form__field" id="username" name="username" placeholder="Username" required />
                        <label for="username" class="form__label">Username</label>
                    </div>

                    <!-- Updated Password Input -->
                    <div class="form__group field">
                        <input type="password" class="form__field" id="password" name="password" placeholder="Password" required />
                        <label for="password" class="form__label">Password</label>
                    </div>

                    <button type="submit" class="btn btn-login">Register</button>
                </form>
                <script src="js/register.js"></script>
            <?php endif; ?>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.11.6/dist/umd/popper.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.min.js"></script>
    <script src="js/matrix.js"></script>
</body>
</html>