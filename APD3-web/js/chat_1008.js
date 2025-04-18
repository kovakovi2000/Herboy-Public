var chatbox = document.getElementById("chatbox");
var chatholder = document.getElementsByClassName("modern-card-body")[0];
var offset = 0; // Set initial offset to 0
var remover = false;
var firstLoad = true; // Flag to track the first load
var isLoading = false; // Flag to prevent loading while already fetching
var loadingIcon = document.createElement("img"); // Create loading icon element
loadingIcon.src = "images/chat_loading_icon.jpg"; // Set the source for the loading icon
loadingIcon.style.height = "20px";
loadingIcon.style.width = "20px";
loadingIcon.style.display = "none"; // Initially hidden
var loadingContainer = document.createElement("div"); // Create a container for the loading icon
loadingContainer.style.textAlign = "center";
loadingContainer.appendChild(loadingIcon);
chatbox.insertBefore(loadingContainer, chatbox.firstChild); // Add loading icon at the top

// Trigger initial chat load when the DOM is ready
document.addEventListener("DOMContentLoaded", function () {
  refreshchat(true); // Load chat immediately
});

// Set to true to keep removing old chat entries
var remover = false;
chatholder.scrollTop = chatholder.scrollHeight;

// Refresh the chat every 3 seconds
setInterval(refreshchat, 3000);

chatholder.addEventListener("scroll", function () {
  if (chatholder.scrollTop === 0 && chatbox.children.length > 1 && !isLoading) {
    // Delay the fetch to avoid immediate loading
    isLoading = true; // Set loading flag
    loadingIcon.style.display = "inline"; // Show loading icon

    setTimeout(function () {
      refreshchat(); // Fetch older messages after a delay
      loadingIcon.style.display = "none"; // Hide loading icon after fetching
      isLoading = false; // Reset loading flag
    }, 500); // Adjust delay as needed
  }
});

function refreshchat(first = false) {
  var xmlHttp = new XMLHttpRequest();

  // Check if we are loading older messages (scrolled to top)
  if (!first && chatholder.scrollTop === 0 && chatbox.children.length > 1) {
    var topelement = chatbox.children[1];

    if (topelement && topelement.id) {
      offset = parseInt(topelement.id.replace(/[^\d.]/g, "")) - 32; // Calculate new offset for older messages
      console.log("Fetching older messages. Offset: " + offset);
    } else {
      console.warn("Top element or ID is undefined.");
      return; // Exit if the element doesn't exist
    }

    xmlHttp.open(
      "GET",
      "ChatSystem/request.php?offset=" + offset + "&size=30",
      true
    );
  } else {
    // Load the latest messages
    console.log("Fetching latest messages. Offset: " + offset);
    xmlHttp.open("GET", "ChatSystem/request.php?offset=" + offset, true);
  }

  xmlHttp.onreadystatechange = function () {
    if (xmlHttp.readyState == 4 && xmlHttp.status == 200) {
      try {
        var data = JSON.parse(xmlHttp.responseText);

        // Log the entire server response for debugging
        console.log("Server response: ", xmlHttp.responseText);

        // Check if messages and nextoffset are present
        if (!data || !data.messages || typeof data.nextoffset === "undefined") {
          console.error("Invalid data format received:", data);
          return;
        }

        // Update the offset
        offset = data.nextoffset;
        console.log("Updated Offset_post: " + offset);

        // Check if messages were received
        if (data.messages.length > 0) {
          console.log("Fetched messages: ", data.messages); // Log fetched messages

          // Reverse if loading older messages, keep normal for new ones
          if (first || chatholder.scrollTop === 0) {
            data.messages.reverse().forEach(displaylinetop);
            if (chatbox.children[1]) {
              chatbox.children[1].scrollIntoView();
            }
            chatholder.scrollTop -= 40;
          } else {
            data.messages.forEach(displayline);
          }

          // Scroll to the bottom after first load
          if (firstLoad) {
            chatholder.scrollTop = chatholder.scrollHeight;
            firstLoad = false; // Set flag to false after the first load
          }
        } else {
          console.log("No new messages received.");
        }
      } catch (err) {
        console.error("Error parsing response or handling data:", err);
      }
    }
  };

  xmlHttp.send(null);
}

// Functions to display chat lines
function displaylinetop(value) {
  var tr = document.createElement("tr");
  tr.id = "cb" + value.cid; // Set the ID for the chat entry
  var td0 = document.createElement("td");
  td0.innerHTML = value.time; // Display the message time
  tr.appendChild(td0);

  var td1 = document.createElement("td");
  td1.innerHTML =
    "<div class='profile-clickable' onclick=\"gotourl(this)\" data-href='/profile/" +
    value.uid +
    "'>" +
    value.pdis +
    "</div>"; // Display the user's profile link
  tr.appendChild(td1);

  var td3 = document.createElement("td");
  td3.innerHTML = value.tsay == 1 ? "(TEAM)" : ""; // Indicate if it's a team message
  tr.appendChild(td3);

  var td2 = document.createElement("td");
  td2.innerHTML = value.mess; // Display the message content
  if (value.alvl > 0 || value.vlvl > 0) td2.style.color = "#00cc00"; // Color based on levels
  tr.appendChild(td2);

  chatbox.insertBefore(tr, chatbox.children[1]); // Insert the message at the top
  if (tr.children[1] && tr.children[1].children[0]) {
    tr.children[1].children[0].style.setProperty(
      "color",
      GetTeamColor(value.team),
      "important" // Set color for team members
    );
  }
}

function displayline(value) {
  var doscroll = false;
  if (chatholder.scrollTop >= chatholder.scrollHeight - 650) doscroll = true; // Check if we should scroll to the bottom

  var tr = document.createElement("tr");
  tr.id = "cb" + value.cid; // Set the ID for the chat entry
  var td0 = document.createElement("td");
  td0.innerHTML = value.time; // Display the message time
  tr.appendChild(td0);

  var td1 = document.createElement("td");
  td1.innerHTML =
    "<div class='profile-clickable' onclick=\"gotourl(this)\" data-href='/profile/" +
    value.uid +
    "'>" +
    value.pdis +
    "</div>"; // Display the user's profile link
  tr.appendChild(td1);

  var td3 = document.createElement("td");
  td3.innerHTML = value.tsay == 1 ? "(TEAM)" : ""; // Indicate if it's a team message
  tr.appendChild(td3);

  var td2 = document.createElement("td");
  td2.innerHTML = value.mess; // Display the message content
  if (value.alvl > 0 || value.vlvl > 0) td2.style.color = "#00cc00"; // Color based on levels
  tr.appendChild(td2);

  chatbox.appendChild(tr); // Append the message to the chat
  if (remover) chatbox.children[1].remove(); // Remove the oldest message if needed

  if (tr.children[1] && tr.children[1].children[0]) {
    tr.children[1].children[0].style.setProperty(
      "color",
      GetTeamColor(value.team),
      "important" // Set color for team members
    );
  }

  if (doscroll) chatholder.scrollTop = chatholder.scrollHeight; // Scroll to the bottom if needed
}

function GetTeamColor(team) {
  if (team == 3) return "#cccccc";
  if (team == 2) return "#99ccff";
  if (team == 1) return "#ff3f3f";
  return "#ffffff";
}

function removeCSS(cssFile) {
  var stylesheets = document.querySelectorAll('link[rel="stylesheet"]');
  for (var i = 0; i < stylesheets.length; i++) {
    if (stylesheets[i].href.indexOf(cssFile) !== -1) {
      stylesheets[i].parentNode.removeChild(stylesheets[i]);
    }
  }
}
if (window.location.pathname === "/chat") {
  removeCSS("css/base.css");
}
