<?php
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/Config.php");
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/includes/Utils.php");
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/includes/PunishmentStruck.php");

global $sql;
global $currentUser;
$currentUser = new UserProfile($pagelink[2], array(
    'id',
    'LastLoginID',
    'LastLoginIP',
    'LastLoginName',
    'RegisterName',
    'RegisterIP',
    'RegisterID',
    'RegisterDate',
    'Active',
    'PremiumPoint',
    'LastLoginDate',
    'PlayTime',
    'AdminLvL1'
));

$query = $sql->query("SELECT * FROM `".Config::$t_AmxMute_name."` WHERE 
`player_id` LIKE '{$currentUser->LastLoginID}' OR
`player_ip` LIKE '{$currentUser->LastLoginIP}' OR
`player_id` LIKE '{$currentUser->RegisterID}' OR
`player_ip` LIKE '{$currentUser->RegisterIP}'
ORDER BY `amx_mutes`.`bid` DESC");
$c_query = mysqli_num_rows($query);
if(!$currentUser->PermLvl->isAdmin() || $c_query > 0 || ($c_query == 0 && Account::IsLogined() && Account::$UserProfile->isBanableSomewhere($currentUser))) {
?>
<table class="table zebra-stripes" style="background-color: rgba(0,0,0,0.7) !important; margin: 0px;">
    <tr>
        <th class="tg-0lax">ID</th>
        <th class="tg-0lax"><?php echo $lang['admin_name2']; ?></th>
        <th class="tg-0lax"><?php echo $lang['reason']; ?></th>
        <th class="tg-0lax"><?php echo $lang['status']; ?></th>
    </tr>
    <?php 
    while($row = mysqli_fetch_array($query)) {
        $ban = new MuteData($row);
        $ban->display_line(array("bid", "admin", "reason", "status"));
    }
    ?>
</table>
<?php
}