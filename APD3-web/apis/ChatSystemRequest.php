<?php
ErrorManager::$force_no_display = true;
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/Config.php");
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/includes/Utils.php");

$sql;

$userProfile = null;
if (isset($_SESSION['account'])) {
    $userProfile = unserialize($_SESSION['account']);
    if (!$userProfile || !$userProfile->PermLvl->isAdmin()) {
        Utils::html_error(401);
        exit();
    }
} else {
    Utils::html_error(401);
    exit();
}

$NeededColumList = array(
    'id',
    'LastLoginID',
    'LastLoginIP',
    'LastLoginName',
    'LastLoginDate',
    'LastLoggedOn',
    'AdminLvL1'
);

$data = array();
$data['offset'] = 0;
$chatShowNum = 50;

if (isset($_GET['size']) && $_GET['size'] <= $chatShowNum) {
    $chatShowNum = filter_input(INPUT_GET, 'size', FILTER_VALIDATE_INT);
}
if (isset($_GET['offset'])) {
    $data['offset'] = filter_input(INPUT_GET, 'offset', FILTER_VALIDATE_INT);
}

$nextOffsetRow = $sql->select_row_q("SHOW TABLE STATUS LIKE 'amx_messages';");
$data['nextoffset'] = $nextOffsetRow['Auto_increment'] - 1;

if ($data['offset'] == 0 && $data['nextoffset'] > 30) {
    $data['offset'] = $data['nextoffset'] - 30;
}

$stmt = $sql->prepare("SELECT * FROM amx_messages LIMIT ?, ?");
$stmt->bind_param('ii', $data['offset'], $chatShowNum);
$stmt->execute();
$query = $stmt->get_result();

if (!$query) {
    printf("</br></br>Error message: %s\n", mysqli_error($sql->mysqli));
    exit();
}

$i = mysqli_num_rows($query);
$data['length'] = $i;
$data['messages'] = array();

if ($i > 0) {
    while ($row = mysqli_fetch_array($query)) {
        $message = array();

        if ((int)$row['id'] > $data['nextoffset']) {
            $data['nextoffset'] = (int)$row['id'];
        }

        $user = $sql->select_row("herboy_regsystem", array('AdminLvL1', 'LastLoginName','id'), "LastLoginID = '{$row['Steamid']}'");

        if (!$user) {
            continue;
        }

        $player = new UserProfile($user['id'], $NeededColumList, null, true);
        if ($player->SuccessInit() === false) {
            $player->PermLvl->AdminLvl[] = 0;
            $player->LastLoginName = $row['Name'];
            $player->PermLvl->AdminLvl[] = (int)$user['AdminLvL1'];
        }

        $message['uid'] = $user['id'];
        $message['alvl'] = $user['AdminLvL1'];
        //NameCard($style="", $print=false, $banned=0, $is_noprofile=0, $country=false)
        $message['pdis'] = "<td>" . $player->NameCard("float: left;", false, 0, 0, true) . "</td>";

        $message['cid'] = $row['id'];
        $message['sid'] = $row['Steamid'];
        $message['name'] = $row['Name'];
        $message['tsay'] = $row['Teamsay'];
        $message['team'] = $row['Team'];

        $row['Message'] = trim($row['Message'], '"');
        if ($row['Message'] == "") {
            continue;
        }

        $message['mess'] = htmlspecialchars($row['Message'], ENT_QUOTES);
        $message['time'] = date('Y/m/d H:i:s', $row['Time']);

        array_push($data['messages'], $message);
        $i--;
    }
}

echo json_encode($data, JSON_HEX_AMP);
?>
