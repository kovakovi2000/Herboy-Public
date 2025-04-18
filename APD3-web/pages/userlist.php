<?php
ErrorManager::$force_no_display = true;
include_once $_SERVER['DOCUMENT_ROOT'] . '/configs/lang/switch.php';

function func_mainpage()
{?>

<?php
global $lang;

global $sql;
$totalUsersQuery = $sql->query("SELECT COUNT(*) as total_users FROM `" . Config::$t_regsystem_name . "`");
$totalUsersData = mysqli_fetch_assoc($totalUsersQuery);
$totalUsers = $totalUsersData['total_users'];

?>

<div class="modern-card-container">
    <div class="modern-card">
        <div style="height: 100%; width: 100%;">
            <div class="modern-card-body">
                <div class="page-header col-md-12" id="banner" style="border: none !important;">
                    <h1 ALIGN=center><b><h2 style="color: white;"><?php echo $lang['page_userlist']; ?></h2></b></h1>
                    <div style="text-align: center;">
                    <?php printf("<h4 style='color: white'>%s: %d</h4>", $lang['userlist_total'], $totalUsers); ?>

                        <!-- Modern keresőmező -->
                        <div class="search-container">
                            <div class="search-box" style="color: #000000;">
                                <input type="text" id="searchInput" placeholder="<?php echo $lang['userlist_search']; ?>">
                                <i class="search-icon">🔍</i>
                            </div>
                        </div>
                    </div>
                </div>


                <!-- Görgethető táblázat -->
                <div class="scrollable-table">
                    <table class="table zebra-stripes" style="position: relative; z-index: 2;">
                        <thead>
                        <tr>
                        <th><?php echo $lang['user_id']; ?></th>
                        <th><?php echo $lang['name']; ?></th>
                        <th><?php echo $lang['last_online']; ?></óth>
                        <th><?php echo $lang['server']; ?></th>
                        </tr>
                        </thead>
                        <tbody id="userTable">
                            <!-- Dinamikusan betöltött adatok -->
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script>
   var lang = <?php echo json_encode($lang); ?>;
</script>
<script>
    $(document).ready(function() {
        (async function() {
            const baseUrl = "/api/UDD";
            let page = 1;
            let loading = false;
            let noMoreData = false;
            let debounceTimeout;

            async function loadUsers(searchQuery = '') {
                if (loading || noMoreData) return;
                loading = true;

                try {
                    const url = `${baseUrl}?page=${page}&search=${encodeURIComponent(searchQuery)}`;
                    const response = await fetch(url);
                    if (!response.ok) throw new Error('Network response was not ok');
                    
                    const content = await response.text();
                    const parser = new DOMParser();
                    const doc = parser.parseFromString(content, 'text/html');

                    // Ensure the tbody exists before trying to access its innerHTML
                    const tbody = doc.querySelector('tbody');
                    if (!tbody) {
                        console.error('No tbody found in the response.');
                        noMoreData = true; // Assume no more data if the structure is not as expected
                        return;
                    }

                    if (page === 1) {
                        document.getElementById("userTable").innerHTML = tbody.innerHTML;
                    } else {
                        document.getElementById("userTable").insertAdjacentHTML('beforeend', tbody.innerHTML);
                    }

                    // Check for the no more data condition
                    if (tbody.innerHTML.trim() === "<tr><td colspan='4' style='text-align: center;'>" + lang['no_more_results'] + "</td></tr>") {
                    noMoreData = true;
                    } else {
                     page++;
                    }


                    loading = false;
                } catch (error) {
                    console.error('Error fetching the content:', error);
                    loading = false;
                }
            }
            loadUsers();

            $('.scrollable-table').on('scroll', function() {
                const scrollTop = $(this).scrollTop();
                const innerHeight = $(this).innerHeight();
                const scrollHeight = $(this)[0].scrollHeight;

                if (scrollTop + innerHeight >= scrollHeight - 10 && !loading) {
                    const searchQuery = $('#searchInput').val();
                    loadUsers(searchQuery);
                }
            });

            $('#searchInput').on('input', function() {
                clearTimeout(debounceTimeout);
                const searchQuery = $(this).val();
                debounceTimeout = setTimeout(function() {
                    noMoreData = false;
                    page = 1; // Reset page count for new search
                    loadUsers(searchQuery);
                }, 300); // 300 ms debounce time
            });
        })();
    });
</script>

<?php
}

function func_addstyle()
{
    ?>
        <script type="text/javascript" src="//cdn.jsdelivr.net/npm/slick-carousel@1.8.1/slick/slick.min.js"></script>
        <link rel="stylesheet" type="text/css" href="//cdn.jsdelivr.net/npm/slick-carousel@1.8.1/slick/slick.css"/>
        <link rel="stylesheet" type="text/css" href="//cdn.jsdelivr.net/npm/slick-carousel@1.8.1/slick/slick-theme.css"/>
        <link rel="stylesheet" type="text/css" href="<?php echo Utils::get_url("css/table.css?ver=a123");?>"/>
    <?php
}
Utils::header("Felhasználó lista", "func_addstyle");
Utils::body("func_mainpage");
Utils::footer();
