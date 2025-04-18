<?php
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/Config.php");
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/includes/_socket.php");
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/includes/Utils.php");

$userProfile = null;
if (isset($_SESSION['account'])) {
    $userProfile = unserialize($_SESSION['account']);
    if(!$userProfile)
    {
        Utils::redirect("login.php");
        exit();
    }
}
else
{
    Utils::redirect("login.php");
    exit();
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    global $sql;

    if (!isset($_POST['vote']))
        Utils::html_error(400);
    if (!isset($_SESSION['voteIndex']))
    {
        echo json_encode(array("status" => "error", "message" => "Hibás szavazat, tölsd újra az oldalt!"));
        exit();
    }

    $vote_score = intval($_POST['vote']);
    $user_id = $userProfile->id;
    $image_id = $_SESSION['voteIndex'];

    if ($stmt = $sql->prepare(
        "INSERT INTO web_skinvotes (user_id, image_id, vote_score) 
        VALUES (?, ?, ?) 
        ON DUPLICATE KEY UPDATE vote_score = ?")) {

        $stmt->bind_param("iiii", $user_id, $image_id, $vote_score, $vote_score);
        $stmt->execute();
        $stmt->close();

        $_SESSION['voteIndex']++;
        echo json_encode(array("status" => "success"));
    }
}
elseif($_SERVER['REQUEST_METHOD'] === 'GET')
{
    if (!isset($_GET['image']))
        Utils::html_error(400);

    //sql request of the user all voted image ids
    $stmt = $sql->prepare("SELECT image_id FROM web_skinvotes WHERE user_id = ?");
    $stmt->bind_param('i', $userProfile->id);
    $stmt->execute();
    $stmt->bind_result($image_ids);
    $stmt->store_result();
    $voted_images = array();
    while ($stmt->fetch()) {
        $voted_images[] = $image_ids;
    }
    $stmt->close();

    //get the namelist of the images to get the size of it
    $namesFile = 'images/voteimages/_names.json';
    $namesData = json_decode(file_get_contents($namesFile), true);
    $names = $namesData['names'];
    $totalcount = count($names);
    $default_skins_amount = 15;

    if(count($voted_images) >= $totalcount - $default_skins_amount)
    {
        echo json_encode(array("status" => "error", "message" => "Nincs több szavazható skin!", "votedcount" => count($voted_images), "totalcount" => $totalcount-$default_skins_amount));
        exit();
    }
    
    //get a random number that is higher then 15 and lower then the size of the namelist and not in the voted images
    while(true)
    {
        $image_id = rand($default_skins_amount, $totalcount-1);
        if(!in_array($image_id, $voted_images))
            break;
    }

    $_SESSION['voteIndex'] = $image_id;

    $imagePath = "/images/voteimages/skin".str_pad($image_id, 4, '0', STR_PAD_LEFT).".jpg";
    $name = $names[$image_id] ?? 'Unknown Skin';
    echo json_encode(array("status" => "success", "imagePath" => $imagePath, "name" => $name, "votedcount" => count($voted_images)+1, "totalcount" => $totalcount-$default_skins_amount));
}
?>
