<?php
include_once $_SERVER['DOCUMENT_ROOT'] . '/configs/lang/switch.php';
global $lang;

if(Account::isLogined() && !isset($_SESSION['steamid64']))
    Utils::redirect("index");
global $respondMessage; $respondMessage = "";
$dialog = false;

if(isset($_GET['steam']))
{
    if(!isset($_SESSION['steamid64']))
        Account::RedirectSteamLogin();
    else
    {
        switch (Account::SteamLogin()) {
            case 'SteamCancelled':
                $respondMessage = $lang['SteamCancelled'];
                break;
            
            case 'FatalError':
                $respondMessage = $lang['FatalError3'];
                break;

            case 'Logined':
                $respondMessage = $lang['Logined'];
                $dialog = true;
                break;
            
            default:
            $respondMessage = $lang['default'];
                break;
        }
    }
}

elseif($_SERVER['REQUEST_METHOD'] === 'POST')
{
$username = strip_tags(filter_input(INPUT_POST, 'username', FILTER_SANITIZE_FULL_SPECIAL_CHARS) ?? '');
$password = $_POST['password'] ?? '';

    switch (Account::Login($username, $password)) {
        case 'MissingUsername': {
            $respondMessage = $lang['MissingUsername'];
            break;
        }

        case 'BadFormatUsername': {
            $respondMessage = $lang['BadFormatUsername'];
            break;
        }

        case 'MissingPassword': {
            $respondMessage = $lang['MissingPassword'];
            break;
        }

        case 'BadFormatPassword': {
            $respondMessage = $lang['BadFormatPassword'];
            break;
        }

        case 'FatalError': {
            $respondMessage = $lang['FatalError1'];
            break;
        }

        case 'Logined': {
            $respondMessage = $lang['Logined2'];
            $dialog = true;
            break;
        }

        case 'InvalidInput': {
            $respondMessage = $lang['InvalidInput'];
            break;
        }

        case 'TooManyTry': {
            $respondMessage = $lang['TooManyTry'];
            break;
        }
        
        default:
            $respondMessage = $lang['FatalError2'];
            break;
    }
}

function func_loginpanel()
{   global $lang;
    global $respondMessage;
    ?>
    <div class="d-flex justify-content-center h-100">
        <div class="card">
            <div class="card-header">
                <h3><?php echo $lang['Login']; ?></h3>
                <!-- <div class="d-flex justify-content-end social_icon">
                    <a href="steam://connect/37.221.209.130:27280"><span><div id="cslogo"></div></span></a>
                    <a href="https://www.facebook.com/groups/522374791586223/" target="_blank"><span><i class="fab fa-facebook-square"></i></span></a>
                    <a href="https://www.gametracker.com/server_info/37.221.209.130:27280/" target="_blank"><span><div id="gtlogo"></div></span></a>
                </div> -->
            </div>
            <div class="card-body">
                <form id="loginForm" method='POST'>
                <span class="error_message"><?php echo $respondMessage;?></span>
                    <div class="input-group form-group">
                        <div class="input-group-prepend">
                            <span class="input-group-text"><i class="fas btn-lg fa-user"></i></span>
                        </div>
                        <input type="text" class="form-control" placeholder="<?php echo $lang['Username']; ?>" name='username' pattern="/^[a-zA-Z0-9]{4,16}+$/iD">
                    </div>
                    <div class="input-group form-group">
                        <div class="input-group-prepend">
                            <span class="input-group-text"><i class="fas btn-lg fa-key"></i></span>
                        </div>
                        <input type="password" class="form-control" placeholder="<?php echo $lang['Password']; ?>" name='password' pattern="/^[a-zA-Z0-9]{4,32}+$/iD">
                    </div>
                    <div class="align-items-center remember" style="margin-bottom: 0px;">
    <input type="checkbox" id="agree">
    <?php echo $lang['accept_privacy_policy']; ?>&nbsp; 
    <a href="/docs/adatvedelmi.pdf"><?php echo $lang['privacy_policy']; ?></a>&nbsp;<?php echo $lang['and']; ?>&nbsp;
    <a href="/docs/ÁSZF_HerBoy2.pdf"><?php echo $lang['terms_conditions']; ?></a>
</div>
<div class="align-items-center remember" style="margin-bottom: 0px;">
    <span>
        <i class="fas fa-key" style="margin-right: 5px;"></i>
        <?php echo $lang['forgot_password']; ?>&nbsp; 
        <a href="/forgetpassword"><?php echo $lang['click_here']; ?></a>.
    </span>
</div>
                    <div class="form-group">
                        <a id="steamLogin" onclick="sendSteamSubmit()"><img src='images/loginsteamlarge.png'></a>
                        <input id="normalLogin" type="button" onclick="sendNormalSubmit()" value="<?php echo $lang['Login']; ?>" class="btn float-right login_btn">
                    </div>
                </form>
            </div>
        </div>
    </div>
    <script>
    function sendNormalSubmit() {
        if (document.getElementById("agree").checked) {
            const hiddenField = document.createElement('input');
            hiddenField.type = 'hidden';
            hiddenField.name = "loginbtn";
            hiddenField.value = "submit";
            document.getElementById("loginForm").appendChild(hiddenField);
            document.getElementById("loginForm").submit();
        } else {
            alert("<?php echo $lang['accept_terms_alert']; ?>");
        }
    }

    function sendSteamSubmit() {
        if (document.getElementById("agree").checked) {
            location.href = '?steam';
        } else {
            alert("<?php echo $lang['accept_terms_alert']; ?>");
        }
    }
</script>

    <?php
}

function func_addstyle()
{
    ?>
    <link rel="stylesheet" type="text/css" href="css/login.css">
    <?php
}

function func_dialog()
{
    global $respondMessage;
    Utils::dialog($respondMessage);
}



Utils::header($lang['Login'], "func_addstyle");
Utils::body($dialog ? "func_dialog" : "func_loginpanel", false);
Utils::footer();
