$(document).ready(function () {
  (async function () {
    const baseUrl = "/api/MLDD";
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
          .getElementById("MuteTable")
          .insertAdjacentHTML(
            "beforeend",
            doc.querySelector("tbody").innerHTML
          );

        var counter_total_mutes = doc.getElementById("totalMutes");
        var totalMuteDiv = document.getElementById("mute_allnum");

        if (!totalMuteDiv.classList.contains("updated")) {
          var counter_total_UMutes = doc.getElementById("totalUMutes");
          var counter_total_ActMutes = doc.getElementById("totalActMutes");
          document.getElementById("mute_activenum").innerText +=
            " " + counter_total_ActMutes.innerText + "";
          document.getElementById("mute_ubnum").innerText +=
            " " + counter_total_UMutes.innerText + "";
          totalMuteDiv.innerText += " " + counter_total_mutes.innerText;
          totalMuteDiv.classList.add("updated");
          counter_total_ActMutes.remove();
          counter_total_UMutes.remove();
        }

        counter_total_mutes.remove();

        if (
          doc.querySelector("tbody").innerHTML.trim() ===
          "<tr><td colspan='8'>Nem található némítás az adatbázismute.</td></tr>"
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
    if (event.target.classList.contains("unmute-btn")) {
      event.stopPropagation();
      const muteId = event.target.getAttribute("data-mute-id");
      handleUnMuteButtonClick(muteId);
    }

    if (event.target.classList.contains("change-mute-btn")) {
      event.stopPropagation();
      const muteId = event.target.getAttribute("data-mute-id");
      closeModal(); // Close any existing modal before opening a new one
      handleChangeMuteButtonClick(event.target);
    }

    if (event.target.classList.contains("about-mute-btn")) {
      event.stopPropagation();
      const muteId = event.target.getAttribute("data-mute-id");
      handleAboutMuteButtonClick(muteId);
    }
  });
});

function handleUnMuteButtonClick(muteId) {
  const modalHtml = `
              <div id="custom-modal" class="modal">
                  <div class="modal-content">
                      <h3>Biztosan fel akarod oldani ezt a némítást?</h3>
                      <div class="modal-buttons">
                          <button id="confirm-unmute" class="modal-button">Igen</button>
                          <button id="cancel-unmute" class="modal-button-cancel">Nem</button>
                      </div>
                  </div>
              </div>
          `;
  document.body.insertAdjacentHTML("beforeend", modalHtml);

  document.getElementById("custom-modal").style.display = "block";

  document
    .getElementById("confirm-unmute")
    .addEventListener("click", function () {
      sendUnmuteRequest(muteId);
    });

  document
    .getElementById("cancel-unmute")
    .addEventListener("click", function () {
      closeModal();
    });
}

function sendUnmuteRequest(muteId) {
  var xhr = new XMLHttpRequest();
  xhr.open("POST", "/api/MLUM/", true);
  xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
  xhr.onreadystatechange = function () {
    if (xhr.readyState === XMLHttpRequest.DONE) {
      if (xhr.status === 200) {
        showNotification("Sikeresen feloldottad a némítást!", "#4CAF50");
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
  xhr.send("mute_id=" + encodeURIComponent(muteId));
}

function closeModal() {
  var modal = document.getElementById("custom-modal");
  if (modal) {
    modal.remove();
  }
}

function handleAboutMuteButtonClick(muteId) {
  // Redirect to testpage.php with the BanID as a query parameter
  window.location.href = `muteinfo/${muteId}`;
}

function handleChangeMuteButtonClick(button) {
  const muteId = button.getAttribute("data-mute-id");
  const playerNick = button.getAttribute("data-player-nick");
  const steamId = button.getAttribute("data-steamid");
  const muteCreated = new Date(button.getAttribute("data-mute-created"));
  const muteExpiry = new Date(button.getAttribute("data-mute-expiry"));
  const muteLength = button.getAttribute("data-mute-length");
  const muteReason = button.getAttribute("data-mute-reason");
  const muteTypeDisplay = button.getAttribute("data-mute-type");
  const adminNameCard = button.getAttribute("data-admin-name-card");

  // Define mute types
  const muteTypes = [
    { value: "1", text: "Chat" },
    { value: "2", text: "Voice" },
    { value: "3", text: "Voice + Chat" },
  ];

  // Create options for the select dropdown with the correct option selected
  const muteTypeOptions = muteTypes
    .map(
      (type) =>
        `<option value="${type.value}" ${
          type.text === muteTypeDisplay ? "selected" : ""
        }>${type.text}</option>`
    )
    .join("");

  const currentTime = new Date();

  const modalHtml = `
      <div id="custom-modal" class="modal">
        <div class="modal-content">
          <div class="scrollable-content">
            <h3>Némítás Módosítása - ID: ${muteId}</h3>
            <table>
              <tr>
                <td><b>Név:</b></td>
                <td>${playerNick}</td>
                <td><input type="text" value="${playerNick}" disabled></td>
              </tr>
              <tr>
                <td><b>SteamID:</b></td>
                <td>${steamId}</td>
                <td><input type="text" value="${steamId}" disabled></td>
              </tr>
              <tr>
                <td><b>Kezdete:</b></td>
                <td>${formatDate(muteCreated)}</td>
                <td><input type="text" id="mute-start" value="${formatDate(
                  currentTime
                )}" disabled></td>
              </tr>
              <tr>
                <td><b>Némítás hossza:</b></td>
                <td>${muteLength}</td>
                <td><input type="number" id="mute-length" value="${muteLength}" placeholder="Némítás hossza (perc)"></td>
              </tr>
              <tr>
                <td><b>Lejárat:</b></td>
                <td>${formatDate(muteExpiry)}</td>
                <td><input type="text" id="mute-expiry" value="${formatDate(
                  calculateExpiry(currentTime, muteLength)
                )}" disabled></td>
              </tr>
              <tr>
                <td><b>Típus:</b></td>
                <td>${muteTypeDisplay}</td>
                <td>
                  <select id="mute-type">
                    ${muteTypeOptions}
                  </select>
                </td>
              </tr>
              <tr>
                <td><b>Indok:</b></td>
                <td>${muteReason}</td>
                <td><input type="text" id="mute-reason" value="${muteReason}" placeholder="Új Indok"></td>
              </tr>
              <tr>
                <td><b>Admin:</b></td>
                <td id="admin-name-card">${adminNameCard}</td>
                <td id="admin-name-input">${adminNameCard}</td>
              </tr>
            </table>
            <div class="modal-buttons">
              <button id="save-mute-changes" class="modal-button">Módosítás</button>
              <button id="close-modal" class="modal-button modal-button-cancel">Bezárás</button>
            </div>
          </div>
        </div>
      </div>
    `;

  document.body.insertAdjacentHTML("beforeend", modalHtml);
  document.getElementById("custom-modal").style.display = "block";

  // Close modal event listener
  document.getElementById("close-modal").addEventListener("click", closeModal);

  // Update expiry date on input change
  document.getElementById("mute-length").addEventListener("input", function () {
    const newMuteLength = parseInt(this.value, 10) || 0;
    updateExpiryDate(currentTime, newMuteLength);
  });

  // Save mute changes event listener
  document
    .getElementById("save-mute-changes")
    .addEventListener("click", function () {
      savemuteChanges(muteId);
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

function updateExpiryDate(currentTime, muteLength) {
  let expiryDate;

  if (muteLength <= 0) {
    expiryDate = "Soha"; // Permanent mute
  } else {
    const muteExpiry = new Date(currentTime.getTime() + muteLength * 60000);
    expiryDate = formatDate(muteExpiry);
  }

  document.getElementById("mute-expiry").value = expiryDate;
}

function calculateExpiry(currentTime, muteLength) {
  return new Date(currentTime.getTime() + muteLength * 60000);
}

function savemuteChanges(muteId) {
  const newMuteLength = document.getElementById("mute-length").value;
  const newReason = document.getElementById("mute-reason").value; // Accessing the mute reason input correctly
  const newMuteType = document.getElementById("mute-type").value;

  const xhr = new XMLHttpRequest();
  xhr.open("POST", "/api/MLCM/", true);
  xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");

  xhr.onreadystatechange = function () {
    if (xhr.readyState === 4) {
      console.log("Server Response:", xhr.responseText);
      if (xhr.status === 200) {
        showNotification("Sikeresen módosítottad a némítást!", "#4CAF50");
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
    `mute_id=${muteId}&new_mute_length=${encodeURIComponent(
      newMuteLength
    )}&new_reason=${encodeURIComponent(
      newReason
    )}&new_mute_type=${encodeURIComponent(newMuteType)}`
  );
}

function closeModal() {
  var modal = document.getElementById("custom-modal");
  if (modal) {
    modal.remove();
  }
}
