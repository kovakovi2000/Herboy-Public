<div class="d-flex justify-content-center h-100">
    <div class="card">
        <div style="position: absolute;left: 50%; top: 50%; -webkit-transform: translate(-50%, -50%); transform: translate(-50%, -50%); text-align: center;">
            <?php if(Account::IsSteam()) echo "<img src='".Account::$UserProfile->Steam->avatarfull."'>"; ?>
            <h1 id="hLoading" style="font-size: 30px;"><?php echo $dialog;?></h1>
            <meta http-equiv='refresh' content='<?php echo $time;?>;url=<?php echo $url;?>'>
        </div>
    </div>
</div>