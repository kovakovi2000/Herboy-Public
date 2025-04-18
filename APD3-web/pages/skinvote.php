<?php

// CREATE TABLE web_skinvotes (
//     id INT AUTO_INCREMENT PRIMARY KEY,
//     user_id INT NOT NULL,
//     image_id INT NOT NULL,
//     vote_score INT CHECK (vote_score BETWEEN 1 AND 10),
//     voted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
//     UNIQUE KEY unique_vote (user_id, image_id)
// );

function func_mainpage() {
    include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/Config.php");
    include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/includes/Utils.php");

    $row = null;
    $unknown = 0;
    if ($_SESSION['account'] !== 3) {
        echo '<meta http-equiv="refresh" content="0;url=/index" />';
        exit();
    }
    $userProfile = unserialize($_SESSION['account']);
    ?>

<div class="modern-card-container">
    <div class="modern-card">
        <div class="card-header">
            <h3 class="text-center">Skin szavazás</h3>
        </div>
        <div class="modern-card-body">
            <?php if (Utils::getCookie("skinvote")) : ?>
            <div class="vote-container text-center">
                <h3 id="skin-name"></h3>
                <h4 id="vote-count"></h4>
                <div class="image-container">
                    <img id="skin-image" src="" class="img-fluid" alt="Skin Image">
                    <div id="progress-bar" class="progress-bar" role="progressbar"></div>
                </div>
                <div class="vote-buttons mt-3">
                    <?php for ($i = 1; $i <= 10; $i++) : 
                        $red = 255 - (($i - 1) * 25);
                        $green = ($i - 1) * 25;
                        $color = "rgb($red, $green, 0)";
                    ?>
                        <button class="btn vote-button" style="background-color: <?php echo $color; ?>;" onclick="vote(<?php echo $i; ?>)" disabled><?php echo $i; ?></button>
                    <?php endfor; ?>
                </div>
            </div>
            <?php else : ?>
            <div class="text-center" style="height: fit-content;">
                <h3>Figyelmesen olvasd el!</h3>
                <p style="width: 95%; max-width: 700px; margin: auto; font-size: 9px; text-align: justify;">A szavazás feltételie a következők:
                    A szavazási folyamat teljes időtartama hozzávetőlegesen két órát vesz igénybe, azonban annak megszakítása és későbbi folytatása bármikor biztosított anélkül, hogy az addig elért előrehaladás elveszne, így nem szükséges azt egyetlen alkalommal, folyamatosan befejezni. A szavazási mechanizmus kizárólag az adott felületen elérhető skinek értékelésére vonatkozik, amelynek keretében a felhasználók egy egyértelmű, 1-től 10-ig terjedő numerikus skálán rangsorolhatják azokat, kifejezve egyéni preferenciájukat. A felhasználók tetszőleges számú skinre leadhatnak szavazatot, azonban minden egyes skin esetében csupán egy alkalommal rögzíthető szavazat, így ugyanazon skin ismételt értékelése nem engedélyezett. A szavazásban való részvételért Prémium Pontok (PP) kerülnek jóváírásra, amelynek mértéke skinenként öt PP, így minden érvényesen leadott szavazat növeli a felhasználó egyenlegét. A Prémium Pontok kizárólag akkor kerülnek véglegesen jóváírásra, ha a felhasználó a teljes szavazási folyamatot hiánytalanul végrehajtotta, vagyis valamennyi elérhető skinre leadta szavazatát és az értékelési eljárást lezárta. A jóváírási folyamat nem azonnali, hanem a felhasználó következő Prémium Pont (PP) vásárlásakor történik. A jóváírás időpontja a felhasználó egyéni feltöltési aktivitásától függően eltérhet, és a rendszer az ebből fakadó késedelmekért felelősséget nem vállal. A szavazási eljárás során kizárólag az érvényes szavazatok kerülnek figyelembevételre, tehát a véletlenszerű, logikátlan vagy manipulált szavazatok kizárásra kerülnek, és azok nem befolyásolják a végső eredményt. Az ilyen szavazatok észlelése esetén az illetékes adminisztratív szervek jogosultak intézkedéseket tenni, ideértve a szavazási jogosultság részleges vagy teljes felfüggesztését, valamint a Prémium Pontok visszavonását, ha azok tisztességtelen módon kerültek megszerzésre. A szavazási mechanizmus megbízhatóságának és átláthatóságának biztosítása érdekében a rendszer folyamatosan figyelemmel kíséri a szavazási tevékenységet, és szükség esetén fenntartja a jogot ellenőrzési és szankcionálási eljárások végrehajtására. A felhasználók kötelesek a szavazási szabályokat és vonatkozó etikai normákat betartani, a rendszer kijátszása, valamint az eredmények manipulálására irányuló cselekmények súlyos jogsértésnek minősülnek, amelyek adminisztratív vagy egyéb következményekkel járhatnak. A szavazási folyamat lezárását követően az eredmények összesítése és kiértékelése automatikusan megtörténik, majd véglegesítés után további módosításra nincs lehetőség, kivéve, ha technikai hiba vagy egyéb, a szavazás integritását sértő körülmény indokolttá teszi a megfelelő korrekciót. Az eredményeket a megfelelő csatornákon közzétesszük, és azok minden érintett számára elérhetővé válnak a meghatározott időkereten belül.                </p>
                <button class="btn btn-primary" style="scale: 1.5;margin-top: 40px;" onclick="Accept_terms()">Megértettem és Elfogadom</button>
            </div>
            <?php endif; ?>

            <script>
            function Accept_terms()
            {
                //SET cookie skinvote to 1 for 10 year
                document.cookie = "skinvote=1; expires=Fri, 31 Dec 9999 23:59:59 GMT";
                location.reload();
            }

            $(document).ready(function() {
                getimage();
            });

            function loadImage() {
                var progressBar = $("#progress-bar");
                var width = 0;
                progressBar.css("width", width + "%");
                var interval = setInterval(function() {
                    width += <?php echo(($userProfile->id == 1) ? 10.0 : 2.75); ?>;
                    progressBar.css("width", width + "%");
                    if (width >= 100) {
                        progressBar.css("width", 100 + "%");
                        clearInterval(interval);
                        $('.vote-button').removeAttr('disabled');
                    }
                }, 100);
            }

            function vote(score) {
                $.post('/api/SV', { vote: score }, function(response) {
                    let data = JSON.parse(response);
                    if (data.status === 'success') {
                        $('.vote-button').attr('disabled', 'disabled');
                        getimage();
                    } else {
                        alert('Voting failed!');
                    }
                });
            }

            function getimage() {
                //GET request /api/SV with image=GET
                $.get('/api/SV', { image: '' }, function(response) {
                    let data = JSON.parse(response);
                    if (data.status === 'success') {
                        $('#skin-image').attr('src', data.imagePath);
                        $('#skin-name').text(data.name);
                        $('#vote-count').text(data.votedcount + '/' + data.totalcount);
                        loadImage();
                    }
                    else if (data.status === 'error') {
                        $('#skin-image').remove();
                        $('#skin-name').text(data.message);
                        $('#vote-count').text(data.votedcount + '/' + data.totalcount);
                        $('.vote-button').remove();
                    }
                    else {
                        alert('Failed to get image!');
                    }
                });
            }
            </script>
        </div>
    </div>
</div>
    <?php
}

function func_addstyle()
{
    ?>
    <style>
        .modern-card {
            height: fit-content;
        }
        .modern-card-body {
            height: 600px;
        }
        .text-center {
            text-align: center;
        }
        .image-container {
            max-height: 503px;
            height: auto;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            position: relative;
            max-width: 661px;
            margin: 0 auto;
        }
        #skin-image {
            max-width: 100%;
            max-height: 500px;
            height: auto;
            border: 2px solid #ddd;
            object-fit: contain;
        }
        #progress-bar {
            height: 3px;
            width: 0%;
            background-color: purple;
            position: absolute;
            bottom: 0;
            left: 0;
        }
        .vote-button {
            color: white;
            border: none;
            width: 40px;
            font-size: large;
        }
    </style>
    <?php
}

Utils::header("Szerver Chat", "func_addstyle");
Utils::body("func_mainpage");
Utils::footer();
