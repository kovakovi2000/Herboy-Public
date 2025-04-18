<?php
function func_mainpage() {
    include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/Config.php");
    include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/includes/Utils.php");

    $row = null;
    $unknown = 0;
    if (!isset($_SESSION['account'])) {
        echo '<meta http-equiv="refresh" content="0;url=/" />';
        exit();
    }
    $userProfile = unserialize($_SESSION['account']);
    ?>

<div class="modern-card-container">
    <div class="modern-card" style="height: fit-content;">
        <div class="card-header">
            <h3 style="text-align: center;">Chat</h3>
        </div>
        <div class="modern-card-body" style="overflow-y: scroll; height: 600px;">
            <table class="table zebra-stripes" style="background-color: rgba(0,0,0,0.7) !important; margin: 0px; padding: 0px;">
                <colgroup>
                    <col style="width: 50px;">
                    <col>
                    <col style="width: 30px;">
                    <col>
                </colgroup>
                <tbody id="chatbox">
                    <tr>
                        <td colspan="4" style="text-align: center;">
                            <img src="images/chat_loading_icon.jpg" style="height: 20px; width: 20px;"/>
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>
</div>
<script src="<?php echo Utils::get_url('js/chat.js?ver=124'); ?>"></script>

    <?php
}

function func_addstyle()
{
    ?>
    <script type="text/javascript" src="//cdn.jsdelivr.net/npm/slick-carousel@1.8.1/slick/slick.min.js"></script>

    <link rel="stylesheet" type="text/css" href="//cdn.jsdelivr.net/npm/slick-carousel@1.8.1/slick/slick.css"/>
    <link rel="stylesheet" type="text/css" href="//cdn.jsdelivr.net/npm/slick-carousel@1.8.1/slick/slick-theme.css"/>
    <link rel="stylesheet" type="text/css" href="<?php echo Utils::get_url('css/chat.css?ver=a123');?>">
    <?php
}

Utils::header("Szerver Chat", "func_addstyle");
Utils::body("func_mainpage");
Utils::footer();