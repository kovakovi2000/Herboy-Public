$(".noti-list").fadeOut(0);
var notiContainer = document.getElementsByClassName('header-menu-noti')[0];
var notiList = document.getElementsByClassName('noti-list')[0];
document.body.addEventListener('click', function (event) {
    if (notiContainer.contains(event.target) && !notiList.contains(event.target)) {
        $(".noti-list").fadeToggle(500, function () {
            if(!$(".noti-list").is(":visible"))
                $(".note:not([class*='seen'])").addClass("seen");
        });
        if($(".noti-list").is(":visible"))
        {
            seen();
            refreshNoti();
        }
    }
});

const audio = new Audio("NotiAPI/noti.mp3");

var lastNotiID = 0;
var OpenedSeen = 0;
var notelist = document.getElementsByClassName("noti-list")[0];
var number = document.getElementsByClassName("num")[0];
var first = true;

function seen()
{
    var xmlHttp = new XMLHttpRequest();
    xmlHttp.open("GET", "NotiAPI/request.php?seen", false);
    xmlHttp.send(null);
}

function refreshNoti()
{
    var xmlHttp = new XMLHttpRequest();
    xmlHttp.open("GET", "NotiAPI/request.php?lastNotiID="+lastNotiID, false);
    xmlHttp.send(null);
    var data = JSON.parse(xmlHttp.responseText);
    lastNotiID = data.lastNotiID;
    if(data.length > 0)
    {
        if(first)
        {
            data.notifications.reverse().forEach(AddNoti);
            OpenedSeen = data.UnSeenCount;
        }
        else
            data.notifications.forEach(AddNoti);
    }
    if(OpenedSeen != data.UnSeenCount)
    {
        if(data.UnSeenCount != 0)
            audio.play();
        
        OpenedSeen = data.UnSeenCount;
    }
    number.innerHTML = data.UnSeenCount;
    if(data.UnSeenCount == 0)
        number.style.display = "none";
    else
        number.style.display = "";
        

    first = false;
}

function AddNoti(value, index, array)
{
    divNote = createNoti(value.seen, value.picon, value.icon, value.icon_color, value.title, value.note, value.link, value.time);
    notelist.insertBefore(divNote, notelist.children[1]);
}

function createNoti(isSeen, picon, icon, icon_color, title, note, link, time)
{
    var dNote = document.createElement('div');
    if(link != "none")
    {
        dNote.setAttribute('onclick', "gotourl(this)");
        dNote.setAttribute('data-href', link);
    }
    dNote.classList.add("note");
    if(isSeen) dNote.classList.add("seen");

    var iIcon = document.createElement('i');
    iIcon.classList.add(picon);
    iIcon.classList.add(icon);
    iIcon.style.backgroundColor = icon_color;
    var hTitle = document.createElement('h4');
    hTitle.innerHTML = title;
    var pNote = document.createElement('p');
    pNote.innerHTML = note;
    var sTime = document.createElement('snap');
    sTime.innerHTML = time;

    dNote.appendChild(iIcon);
    dNote.appendChild(hTitle);
    dNote.appendChild(pNote);
    dNote.appendChild(sTime);

    return dNote;
}

refreshNoti();
setInterval(refreshNoti, 3000);