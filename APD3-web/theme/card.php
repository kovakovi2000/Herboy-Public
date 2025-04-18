
<div class="modern-card" style="margin: 20px; margin-bottom: 20<?php if($first) echo "0";?>px">
    <div style="height: 100%; width: 100%;">
        <div class="modern-card-header">
            <h1><?php echo $title; ?></h1>
        </div>
        <div class="modern-card-body">
            <?php call_user_func($cont_func); ?>
        </div>
    </div>
</div>