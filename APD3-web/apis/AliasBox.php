<?php
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/Config.php");
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/includes/Utils.php");

global $sql;
global $currentUser;
$currentUser = new UserProfile($pagelink[2], array(
    'id',
    'LastLoginID'
));

$query = $sql->query("SELECT * FROM `".Config::$t_AmxAlias_name."` WHERE `Steamid` = '{$currentUser->LastLoginID}' ORDER BY `LastUsed` DESC");
?>
<h5><?php echo $lang['alias']; ?></h5>
<div style="max-height: 300px; overflow-y: auto; overflow-x: hidden;">
<?php
if(mysqli_num_rows($query) > 0)
    while($row = mysqli_fetch_array($query)){
        echo "<p style='margin: 0' title='".(strtotime($row['LastUsed']) > 1642445764 ? $row['LastUsed'] : "N/A")."'>&#8226;&#x20;".htmlspecialchars($row['Name'], ENT_QUOTES)."</p>";
    }
?>
</div>