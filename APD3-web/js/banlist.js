$(document).ready(function () {
  (async function () {
    const baseUrl = "/api/BLDD";
    let page = 1;
    let loading = false;
    let noMoreData = false;

    async function loadUsers() {
      if (loading || noMoreData) return;
      loading = true;

      try {
        const response = await fetch(`${baseUrl}?page=${page}`);
        if (!response.ok) throw new Error("Network response was not ok");

        const content = await response.text();
        const parser = new DOMParser();
        const doc = parser.parseFromString(content, "text/html");

        document
          .getElementById("BanTable")
          .insertAdjacentHTML(
            "beforeend",
            doc.querySelector("tbody").innerHTML
          );

        var counter_total_bans = doc.getElementById("totalBans");
        var totalBanDiv = document.getElementById("ban_allnum");

        if (!totalBanDiv.classList.contains("updated")) {
          var counter_total_AcBan = doc.getElementById("totalAcBan");
          var counter_total_ABan = doc.getElementById("totalABan");
          var counter_total_UBan = doc.getElementById("totalUBan");
          var counter_total_ActBan = doc.getElementById("totalActBan");
          document.getElementById("ban_acnum").innerText +=
            " " + counter_total_AcBan.innerText + "";
          document.getElementById("ban_adnum").innerText +=
            " " + counter_total_ABan.innerText + "";
          document.getElementById("ban_activenum").innerText +=
            " " + counter_total_ActBan.innerText + "";
          document.getElementById("ban_ubnum").innerText +=
            " " + counter_total_UBan.innerText + "";
          totalBanDiv.innerText += " " + counter_total_bans.innerText;
          totalBanDiv.classList.add("updated");
          counter_total_AcBan.remove();
          counter_total_ActBan.remove();
          counter_total_AcBan.remove();
          counter_total_UBan.remove();
        }

        counter_total_bans.remove();

        if (
          doc.querySelector("tbody").innerHTML.trim() ===
          "<tr><td colspan='8'>Nem található kitiltás az adatbázisban.</td></tr>"
        ) {
          noMoreData = true;
        } else {
          page++;
        }
        loading = false;
      } catch (error) {
        console.error("Error fetching the content:", error);
        loading = false;
      }
    }

    loadUsers();

    document
      .querySelector(".scrollable-table")
      .addEventListener("scroll", function () {
        const container = this;
        const scrollTop = container.scrollTop;
        const innerHeight = container.clientHeight;
        const scrollHeight = container.scrollHeight;

        if (scrollTop + innerHeight >= scrollHeight - 10 && !loading) {
          loadUsers();
        }
      });
  })();
});

document.addEventListener("DOMContentLoaded", function () {
  document.body.addEventListener("click", function (event) {
    if (event.target.classList.contains("unban-btn")) {
      event.stopPropagation();
      const banId = event.target.getAttribute("data-ban-id");
      handleUnbanButtonClick(banId);
    }

    if (event.target.classList.contains("change-ban-btn")) {
      event.stopPropagation();
      const banId = event.target.getAttribute("data-ban-id");
      closeExistingModal();
      handleChangeBanButtonClick(event.target);
    }

    if (event.target.classList.contains("about-ban-btn")) {
      event.stopPropagation();
      const banId = event.target.getAttribute("data-ban-id");
      handleAboutBanButtonClick(banId);
    }
  });
});

function handleUnbanButtonClick(banId) {
  const modalHtml = `
              <div id="custom-modal" class="modal">
                  <div class="modal-content">
                      <h3>Biztosan fel akarod oldani ezt a kitiltást?</h3>
                      <div class="modal-buttons">
                          <button id="confirm-unban" class="modal-button">Igen</button>
                          <button id="cancel-unban" class="modal-button-cancel">Nem</button>
                      </div>
                  </div>
              </div>
          `;
  document.body.insertAdjacentHTML("beforeend", modalHtml);

  document.getElementById("custom-modal").style.display = "block";

  document
    .getElementById("confirm-unban")
    .addEventListener("click", function () {
      sendUnbanRequest(banId);
    });

  document
    .getElementById("cancel-unban")
    .addEventListener("click", function () {
      closeModal();
    });
}

function sendUnbanRequest(banId) {
  var xhr = new XMLHttpRequest();
  xhr.open("POST", "/api/BLUB/", true);
  xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
  xhr.onreadystatechange = function () {
    if (xhr.readyState === XMLHttpRequest.DONE) {
      if (xhr.status === 200) {
        showNotification("Sikeresen feloldottad a kitiltást!", "#4CAF50");
        closeModal();
        setTimeout(function () {
          location.reload();
        }, 1000);
      } else {
        showNotification("Hiba történt: " + xhr.statusText, "#f44336");
        closeModal();
      }
    }
  };
  xhr.send("ban_id=" + encodeURIComponent(banId));
}

function closeModal() {
  var modal = document.getElementById("custom-modal");
  if (modal) {
    modal.remove();
  }
}

function handleAboutBanButtonClick(banId) {
  window.location.href = `baninfo/${banId}`;
}

function handleChangeBanButtonClick(button) {
  const banId = button.getAttribute("data-ban-id");
  const playerNick = button.getAttribute("data-player-nick");
  const steamId = button.getAttribute("data-steamid");
  const banCreated = new Date(button.getAttribute("data-ban-created"));
  const banExpiry = new Date(button.getAttribute("data-ban-expiry"));
  const banLength = button.getAttribute("data-ban-length");
  const banReason = button.getAttribute("data-ban-reason");
  const adminNameCard = button.getAttribute("data-admin-name-card");

  const currentTime = new Date();

  const modalHtml = `
      <div id="custom-modal" class="modal">
        <div class="modal-content">
         <div class="scrollable-content">
          <h3>Kitiltás Módosítása - ID: ${banId}</h3>
          <table>
            <tr>
              <td><b>Név:</b></td>
              <td id="player-nick">${playerNick}</td> <!-- Display player name directly -->
              <td><input type="text" id="player-nick-input" value="${playerNick}" disabled></td>
            </tr>
            <tr>
              <td><b>SteamID:</b></td>
              <td id="steam-id">${steamId}</td>
              <td><input type="text" id="steam-id-input" value="${steamId}" disabled></td>
            </tr>
            <tr>
              <td><b>Kezdete:</b></td>
              <td>${formatDate(banCreated)}</td>
              <td><input type="text" id="ban-start" value="${formatDate(
                currentTime
              )}" disabled></td>
            </tr>
            <tr>
              <td><b>Kitiltás hossza:</b></td>
              <td>${banLength}</td>
              <td><input type="number" id="ban-length" value="${banLength}" placeholder="Kitiltás hossza (perc)"></td>
            </tr>
            <tr>
              <td><b>Lejárat:</b></td>
              <td>${formatDate(banExpiry)}</td>
              <td><input type="text" id="ban-expiry" value="${formatDate(
                calculateExpiry(currentTime, banLength)
              )}" disabled></td>
            </tr>
            <tr>
              <td><b>Indok:</b></td>
              <td id="ban-reason">${banReason}</td>
              <td><input type="text" id="ban-reason-input" value="${banReason}" placeholder="Új Indok"></td>
            </tr>
            <tr>
              <td><b>Admin:</b></td>
              <td id="admin-name-card">${adminNameCard}</td> <!-- Inject NameCard HTML here -->
              <td id="admin-name-input">${adminNameCard}</td>
            </tr>
          </table>
          <div class="modal-buttons">
            <button id="save-ban-changes" class="modal-button">Módosítás</button>
            <button id="close-modal" class="modal-button modal-button-cancel">Bezárás</button>
          </div>
        </div>
      </div>
    `;

  document.body.insertAdjacentHTML("beforeend", modalHtml);
  document.getElementById("custom-modal").style.display = "table";

  document.getElementById("close-modal").addEventListener("click", closeModal);

  document.getElementById("ban-length").addEventListener("input", function () {
    const newBanLength = parseInt(this.value, 10) || 0;
    updateExpiryDate(currentTime, newBanLength);
  });

  document
    .getElementById("save-ban-changes")
    .addEventListener("click", function () {
      savebanChanges(banId);
    });
}

function formatDate(date) {
  if (isNaN(date.getTime())) {
    return "Soha";
  }
  return date.toLocaleString("hu-HU", {
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
    hour: "2-digit",
    minute: "2-digit",
  });
}

function updateExpiryDate(currentTime, banLength) {
  let expiryDate;

  if (banLength <= 0) {
    expiryDate = "Soha";
  } else {
    const banExpiry = new Date(currentTime.getTime() + banLength * 60000);
    expiryDate = formatDate(banExpiry);
  }

  document.getElementById("ban-expiry").value = expiryDate;
}

function calculateExpiry(currentTime, banLength) {
  return new Date(currentTime.getTime() + banLength * 60000);
}

function savebanChanges(banId) {
  const newbanLength = document.getElementById("ban-length").value;
  const newReason = document.getElementById("ban-reason-input").value;

  const xhr = new XMLHttpRequest();
  xhr.open("POST", "/api/BLCB/", true);
  xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");

  xhr.onreadystatechange = function () {
    if (xhr.readyState === 4) {
      console.log("Server Response:", xhr.responseText);
      if (xhr.status === 200) {
        showNotification("Sikeresen módosítottad a kitiltást!", "#4CAF50");
        closeModal();
        setTimeout(function () {
          location.reload();
        }, 1000);
      } else {
        showNotification("Hiba történt: " + xhr.statusText, "#f44336");
      }
    }
  };

  xhr.send(
    `ban_id=${banId}&new_ban_length=${encodeURIComponent(
      newbanLength
    )}&new_reason=${encodeURIComponent(newReason)}`
  );
}

function closeModal() {
  var modal = document.getElementById("custom-modal");
  if (modal) {
    modal.remove();
  }
}
