var chatbox = document.getElementById("chatbox");
var chatholder = document.getElementsByClassName("modern-card-body")[0]; // Updated class name
var offset = 0;
var remover = false;
refreshchat(true);
var remover = true;
chatholder.scrollTop = chatholder.scrollHeight;
setInterval(refreshchat, 3000);

function refreshchat(first = false) {
  if (!first && chatholder.scrollTop == 0) {
    var xmlHttp = new XMLHttpRequest();
    var topelement = chatbox.children[1];
    offset = parseInt(topelement.id.replace(/[^\d.]/g, "")) - 32;
    console.log("api/gMessage?offset=" + offset + "&size=30");
    xmlHttp.open("GET", "api/gMessage?offset=" + offset + "&size=30", false);
    xmlHttp.send(null);
    var data = JSON.parse(xmlHttp.responseText);
    offset = data.nextoffset;
    if (data.length > 0) data.messages.reverse().forEach(displaylinetop);

    topelement.scrollIntoView();
    chatholder.scrollTop -= 40;
  } else {
    var xmlHttp = new XMLHttpRequest();
    console.log("api/gMessage?offset=" + offset);
    xmlHttp.open("GET", "api/gMessage?offset=" + offset, false);
    xmlHttp.send(null);
    var data = JSON.parse(xmlHttp.responseText);
    offset = data.nextoffset;
    console.log("Offset_post: " + offset);
    if (data.length > 0) data.messages.forEach(displayline);
  }
}

function displaylinetop(value, index, array) {
  var tr = document.createElement("tr");
  tr.id = "cb" + value.cid;

  var td0 = document.createElement("td");
  td0.innerHTML = value.time;
  tr.appendChild(td0);

  var td1 = document.createElement("td");
  // Make username clickable
  td1.innerHTML =
    "<div class='profile-clickable' onclick=\"gotourl(this)\" data-href='/profile/" +
    value.id +
    "'>" +
    value.pdis +
    "</div>";
  tr.appendChild(td1);

  var td3 = document.createElement("td");
  td3.innerHTML = value.tsay == 1 ? "(TEAM)" : "";
  tr.appendChild(td3);

  var td2 = document.createElement("td");
  td2.innerHTML = value.mess;
  if (value.alvl > 0 || value.vlvl > 0) td2.style.color = "#00cc00";
  tr.appendChild(td2);

  chatbox.insertBefore(tr, chatbox.children[1]);

  // Ensure the element exists before applying styles
  if (tr.children[1] && tr.children[1].children[0]) {
    // Apply team color with "!important"
    tr.children[1].children[0].style.setProperty(
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
  // Make username clickable
  td1.innerHTML =
    "<div class='profile-clickable' onclick=\"gotourl(this)\" data-href='/profile/" +
    value.uid +
    "'>" +
    value.pdis +
    "</div>";
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

  if (tr.children[1] && tr.children[1].children[0]) {
    // Apply team color with "!important"
    tr.children[1].children[0].style.setProperty(
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
    // Check if the stylesheet href contains the cssFile
    if (stylesheets[i].href.indexOf(cssFile) !== -1) {
      stylesheets[i].parentNode.removeChild(stylesheets[i]);
    }
  }
}

// Remove base.css on chat.php
if (window.location.pathname === "/chat") {
  removeCSS("css/base.css"); // This part only needs 'css/base.css', not the full path
}
