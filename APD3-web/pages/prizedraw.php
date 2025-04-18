<?php
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/Config.php");
require_once 'HunterObfuscator.php';

function func_mainpage() {
    global $sql;
    global $lang;

    if (isset($_SESSION['account'])) {
        $userProfile = unserialize($_SESSION['account']);
        $userid = $userProfile->id ?? 'Ismeretlen ID';
    } else {
        $userProfile = null;
    }
    $time_need = 1440;

    function formatMinutes($totalMinutes) {
      global $lang;
      $hours = floor($totalMinutes / 60);
      $minutes = $totalMinutes % 60;
  
      $formattedTime = '';
      if ($hours > 0) {
          $formattedTime .= $hours . ' ' . $lang['hours'];
      }
      if ($hours > 0 && $minutes > 0) {
          $formattedTime .= ' ';
      }
      if ($minutes > 0) {
          $formattedTime .= $minutes . ' ' . $lang['minutes'];
      }
  
      return $formattedTime;
  }

?>

<div class="modern-card-container">
    <div class="modern-card card-modify" style="height: fit-content; margin-bottom: 20px;">
        <div style="flex: 1; margin-right: 20px;">
            <div class="modern-card-header">
            <h1 ALIGN=center><b><h2 style="color: #d1d1d1;"><?php echo $lang['giveaway']; ?></h2></b></h1>
            </div>
            <div class="modern-card-body" style="display: flex; justify-content: space-between; align-items: flex-start;">
            <div style="flex: 1; margin-right: 20px;">
    <p style="display: flex; justify-content: space-between; flex-direction: column;">
        <b><h4><?php echo $lang['important_info']; ?></h4>
        <h6><?php echo $lang['start_date']; ?>: GMT+0100 | 2024.11.20 (00:00:01)</h6>
        <h6><?php echo $lang['end_date']; ?>: GMT+0100 | 2024.12.20 (23:59:59)</h6>
        <h6><?php echo $lang['christmas_draw']; ?></h6>
        <h6><?php echo $lang['grand_prize']; ?></h6></b>
        <h6><?php echo $lang['time_counted']; ?></h6>
        <h6><?php echo $lang['ban_policy']; ?></h6>
        <h8><?php echo $lang['ban_policy_note']; ?></h8>

        <b><h4><?php echo $lang['how_to_participate']; ?></h4>
        <h6><?php echo $lang['just_play']; ?></h6>
        <h6><?php echo $lang['active_participation']; ?></h6>
        <h6><?php echo $lang['transparent_draw']; ?></h6>
    </p>
    <br />
</div>

                <div class="modern-card-body" style="display: flex; justify-content: flex-end; align-items: center; flex-direction: column; text-align: right;">
    <h1><b><h2 style="color: #d1d1d1;">ASUS TUF Gaming VG279Q1R</h2></b></h1>
    <img src="/images/monitor/monitor.png" alt="Monitor" style="height: 200px; cursor: pointer;" id="thumbnailImage">
</div>
<div id="imageModal" class="image-modal">
    <span class="close" id="closeModal">&times;</span>
    <div class="modal-content">
        <div class="modal-images">
            <img id="modalImage" src="/images/monitor/monitor.png" class="modal-image" style="max-width: 100%; height: auto;">
        </div>
        <div class="modal-nav">
            <button id="prevButton" class="nav-button">←</button>
            <button id="nextButton" class="nav-button">→</button>
        </div>
    </div>
</div>
            </div>
        </div>
        
    <?php 
    //     $WinCount = mysqli_fetch_array($sql->query("
    //     SELECT count(*) as 'TotalCount' 
    //     FROM (
    //         SELECT `steamid`
    //         FROM `amx_drawprizetime`
    //         ORDER BY `PlayTime` DESC
    //         LIMIT 100
    //     ) AS top_users
    // ") )['TotalCount'];
    
        $num = 0;
        $YellowBorder = 0;
        $WinCount = 50;
    ?>
            <div style="width:100%;height:2px;background: white;margin-top: 20px;margin-bottom: 20px;"></div>
            <h1><span style="color: #FFFF00;"><?php echo $lang['above_gold_line']; ?></span></h1>
            <div style="overflow-y: auto; max-height: 400px; width: 100%;">
            <table  class="table zebra-stripes" style="position: relative;z-index: 2;">
				<thead>
        <tr>
        <th><?php echo "Rank"; ?></th>
        <th><?php echo $lang['table_userid']; ?></th>
        <th><?php echo $lang['table_name']; ?></th>
        <th><?php echo $lang['table_prize_time']; ?></th>
    </tr>
				</thead>
				<tbody>
					<?php
                        $query = $sql->query("
                        SELECT 
                            ad.*, 
                            hr.*, 
                            ad.PlayTime AS ad_PlayTime, 
                            hr.PlayTime AS hr_PlayTime,
                            hr.LastLoginName
                        FROM amx_drawprizetime ad
                        JOIN herboy_regsystem hr ON ad.skId = hr.id
                        WHERE ad.PlayTime > 1 AND (hr.AdminLvL1 = 0 OR hr.AdminLvL1 = 5)
                        ORDER BY ad.PlayTime DESC
                        LIMIT 110;
                    ");
                    
                        while($row = mysqli_fetch_array($query)){
                            
                            $u_id = $row['id'];
                            $u_nick = $row['LastLoginName'];
                            $u_steamid = $row['LastLoginID'];
                            $u_ip = $row['LastLoginIP'];
                            $u_registered = $row['LastLoginDate'];
                            $Active = $row['Active'];
                            $PlayTime = $row['ad_PlayTime'];


                            $is_banned = mysqli_num_rows($sql->query("SELECT * FROM `amx_bans` WHERE (`player_id` LIKE '{$u_steamid}' OR `player_ip` LIKE '{$u_ip}') AND `expired` = 0"));
                            if($is_banned || $num >= 100)
                              continue;

                            $num++;
                            echo "<tr ".($num == $WinCount ? "style=\"border-bottom: 3px solid yellow;\"" : "")." class='tr_all".($Active > 0 ? " tr_online" : "").($is_banned > 0 ? " tr_banned" : "")." tr_normal' onclick=\"gotourl(this)\" data-href='profile/{$u_id}'>";
                            echo "<td>".$num."</td>";
                            echo "<td>#".$u_id."</td>";
                            echo "<td>" . htmlspecialchars($u_nick) . "</td>";
                            echo "<td>".formatMinutes($PlayTime)."</td>";
							echo "<td>";
						}
        			?>
        		</tbody>
			</table>
    </div>
</div>

<script>
const images=["/images/monitor/monitor.png","/images/monitor/monitor2.png","/images/monitor/monitor3.png","/images/monitor/monitor4.png","/images/monitor/monitor5.png"];let currentImageIndex=0;const thumbnailImage=document.getElementById("thumbnailImage"),modal=document.getElementById("imageModal"),modalContent=document.querySelector(".modal-content"),modalImage=document.getElementById("modalImage"),prevButton=document.getElementById("prevButton"),nextButton=document.getElementById("nextButton");thumbnailImage.addEventListener("click",()=>{modal.style.display="flex",modalImage.src=images[currentImageIndex]}),modal.addEventListener("click",e=>{modalContent.contains(e.target)||(modal.style.display="none")}),prevButton.addEventListener("click",e=>{e.stopPropagation(),currentImageIndex=(currentImageIndex-1+images.length)%images.length,modalImage.src=images[currentImageIndex]}),nextButton.addEventListener("click",e=>{e.stopPropagation(),currentImageIndex=(currentImageIndex+1)%images.length,modalImage.src=images[currentImageIndex]});
</script>
<style>
    .image-modal {
  display: none;
  position: fixed;
  z-index: 9999;
  left: 0;
  top: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(0, 0, 0, 0.9);
  justify-content: center;
  align-items: center;
  text-align: center;
}

.modal-content {
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
}

.modal-images img {
  max-width: 95%;
  max-height: 85%;
  border-radius: 10px;
  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.5);
}

.modal-nav {
  margin-top: 20px;
  display: flex;
  justify-content: center;
  gap: 30px;
}

.nav-button {
  background-color: black; /* Sleek black background */
  color: white; /* High contrast for the text */
  font-size: 28px; /* Text size */
  width: 60px; /* Ensures a perfect circle */
  height: 60px; /* Ensures a perfect circle */
  border: none; /* Removes default borders */
  border-radius: 50%; /* Makes the button a full circle */
  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.6); /* Subtle black glow effect */
  cursor: pointer; /* Pointer cursor on hover */
  transition: background-color 0.3s ease, box-shadow 0.3s ease, transform 0.2s ease; /* Smooth interactions */
}


.nav-button:active {
  background-color: black; /* Ensures the background stays black */
  box-shadow: 0 3px 8px rgba(0, 0, 0, 0.5); /* Slightly reduced glow on click */
  transform: scale(0.95); /* Button depress effect */
}

.close {
  position: absolute;
  top: 20px;
  right: 30px;
  font-size: 50px;
  font-weight: bold;
  cursor: pointer;
  transition: color 0.3s ease;
}
button:focus {
    transition: outline 0.2s ease-in-out; /* Smooth appearance */
    background-color: rgba(0, 0, 0, 0.5);
    color: white;
}


.close:hover,
.close:focus {
  color: #bbb;
  text-decoration: none;
}

body.modal-open {
  overflow: hidden;
}

#closeModal {
  display: none;
}

@media screen and (max-width: 768px) {
  .modern-card-body {
    flex-direction: column;
    align-items: center;
    text-align: center;
  }

  .image-content {
    text-align: center;
    align-items: center;
    margin-top: 20px;
    width: 100%;
    height: 100%;
  }

  .image-content img {
    max-width: 100%;
    height: 100%;
    margin: 0 auto;
  }

  .text-content {
    margin-right: 0;
  }

  h2 {
    text-align: center;
    margin: 10px 44px;
  }
}

</style>

<?php }


function func_addstyle()
{
    ?>
        <script type="text/javascript" src="//cdn.jsdelivr.net/npm/slick-carousel@1.8.1/slick/slick.min.js"></script>
        <link rel="stylesheet" type="text/css" href="//cdn.jsdelivr.net/npm/slick-carousel@1.8.1/slick/slick.css"/>
        <link rel="stylesheet" type="text/css" href="//cdn.jsdelivr.net/npm/slick-carousel@1.8.1/slick/slick-theme.css"/>
        <link rel="stylesheet" type="text/css" href="<?php echo Utils::get_url("css/table.css?ver=13122");?>"/>
        <link rel="stylesheet" type="text/css" href="<?php echo Utils::get_url('css/banlist.css?ver=24');?>">
    <?php
}

Utils::header($lang['menu_prizedraw'], "func_addstyle");
Utils::body("func_mainpage");
Utils::footer();?>
