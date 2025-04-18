var chatbox = document.getElementById("chatbox");
var chatholder = document.getElementsByClassName("modern-card-body")[0];
var offset = 0;
var remover = false;
refreshchat(true);
var remover = true;
chatholder.scrollTop = chatholder.scrollHeight;
setInterval(refreshchat, 3000);

function refreshchat(first = false) {
  if (!first && chatholder.scrollTop == 0) {
    fetchOlderMessages();
  } else {
    fetchNewMessages();
  }
}

function fetchOlderMessages() {
  var xmlHttp = new XMLHttpRequest();
  var topelement = chatbox.children[1];
  var oldestMessageId = parseInt(topelement.id.replace(/[^\d.]/g, ""));
  var fetchOffset = oldestMessageId - 32;

  xmlHttp.open("GET", "api/gMessage?offset=" + fetchOffset + "&size=30", false);
  xmlHttp.send(null);

  var data = JSON.parse(xmlHttp.responseText);

  if (data.messages && data.messages.length > 0) {
    data.messages.reverse().forEach(function (message) {
      if (!document.getElementById("cb" + message.cid)) {
        displaylinetop(message);
      }
    });

    topelement.scrollIntoView();
    chatholder.scrollTop -= 40;
  }
}

function fetchNewMessages() {
  var xmlHttp = new XMLHttpRequest();

  xmlHttp.open("GET", "api/gMessage?offset=" + offset, false);
  xmlHttp.send(null);

  var data = JSON.parse(xmlHttp.responseText);

  if (data.messages && data.messages.length > 0) {
    data.messages.forEach(function (message) {
      if (!document.getElementById("cb" + message.cid)) {
        displayline(message);
      }
    });

    offset = data.nextoffset;
  }
}

function displaylinetop(value, index, array) {
  var tr = document.createElement("tr");
  tr.id = "cb" + value.cid;

  var td0 = document.createElement("td");
  td0.innerHTML = value.time;
  tr.appendChild(td0);

  var td1 = document.createElement("td");

  if (value.uid) {
    td1.innerHTML =
      "<div class='profile-clickable' onclick=\"gotourl(this)\" data-href='/profile/" +
      value.uid +
      "'>" +
      value.pdis +
      "</div>";
  } else {
    console.error("User ID is missing for this message:", value);
    td1.innerHTML = "<div class='profile-clickable'>Unknown User</div>";
  }
  tr.appendChild(td1);

  var td3 = document.createElement("td");
  td3.innerHTML = value.tsay == 1 ? "(TEAM)" : "";
  tr.appendChild(td3);

  var td2 = document.createElement("td");
  td2.innerHTML = value.mess;
  if (value.alvl > 0 || value.vlvl > 0) td2.style.color = "#00cc00";
  tr.appendChild(td2);

  chatbox.insertBefore(tr, chatbox.children[1]);

  if (tr.children[1] && tr.children[1].children[0].children[0]) {
    tr.children[1].children[0].children[0].style.setProperty(
      "color",
      GetTeamColor(value.team),
      "important"
    );
  }
}

function displayline(value, index, array) {
  var doscroll = false;

  if (chatholder.scrollTop >= chatholder.scrollHeight - 650) doscroll = true;

  var tr = document.createElement("tr");
  tr.id = "cb" + value.cid;

  var td0 = document.createElement("td");
  td0.innerHTML = value.time;
  tr.appendChild(td0);

  var td1 = document.createElement("td");

  if (value.uid) {
    td1.innerHTML =
      "<div onclick=\"gotourl(this)\" data-href='/profile/" +
      value.uid +
      "'>" +
      value.pdis +
      "</div>";
  } else {
    console.error("User ID is missing for this message:", value);
    td1.innerHTML = "<div>Unknown User</div>";
  }
  tr.appendChild(td1);

  var td3 = document.createElement("td");
  td3.innerHTML = value.tsay == 1 ? "(TEAM)" : "";
  tr.appendChild(td3);

  var td2 = document.createElement("td");
  td2.innerHTML = value.mess;
  if (value.alvl > 0 || value.vlvl > 0) td2.style.color = "#00cc00";
  tr.appendChild(td2);

  chatbox.appendChild(tr);
  if (remover) chatbox.children[1].remove();

  if (tr.children[1] && tr.children[1].children[0].children[0]) {
    tr.children[1].children[0].children[0].style.setProperty(
      "color",
      GetTeamColor(value.team),
      "important"
    );
  }

  if (doscroll == true) chatholder.scrollTop = chatholder.scrollHeight;
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
