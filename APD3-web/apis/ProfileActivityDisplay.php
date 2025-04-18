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
$returnData['interval'] = array();
$returnData['tabledata'] = array();
$counter = 31;
$last31DayQuery = $sql->query(
"SELECT 
    FROM_UNIXTIME(UNIX_TIMESTAMP(`time`), '%d') AS Days,
    count(`steamid`) AS ActiveMinutes
FROM `amx_activity`
WHERE `steamid` = '".$currentUser->LastLoginID."' AND `time` BETWEEN (NOW() - INTERVAL ".$counter." DAY) AND (NOW() - INTERVAL 0 DAY)
GROUP BY DAY(`time`) ORDER BY `time` ASC;");


$didDisplay = true;
$row = "";
while($counter > -1)
{
    if($didDisplay)
        $row = mysqli_fetch_array($last31DayQuery);
    $inspected = date('d',strtotime("-".$counter." days"));
    if(isset($row['Days']) && $inspected == $row['Days'])
    {
        $returnData['interval'][] = $row['Days'];
        $returnData['tabledata'][] = $row['ActiveMinutes'];
        $didDisplay = true;
    }
    else
    {
        $returnData['interval'][] = $inspected;
        $returnData['tabledata'][] = "0";
        $didDisplay = false;
    }
    $counter--;
}

echo json_encode($returnData);
?>