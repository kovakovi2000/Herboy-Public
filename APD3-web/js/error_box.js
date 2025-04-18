dragElement(document.getElementById("error_box"));

function setElementVisibled(elmnt, temp_x, temp_y)
{
    if(temp_x < 0)
        elmnt.style.top = 0;
    else if(temp_x > window.innerHeight)
        elmnt.style.top = window.innerHeight;
    else
        elmnt.style.top = temp_x + "px";

    if(temp_y < 0)
        elmnt.style.left = 0;
    else if(temp_y > window.innerWidth)
        elmnt.style.top = window.innerWidth;
    else
        elmnt.style.left = temp_y + "px";
}

function dragElement(elmnt) {
    var pos1 = 0, pos2 = 0, pos3 = 0, pos4 = 0;
    var temp_x = getCookie("error_box_x");
    var temp_y = getCookie("error_box_y");
    setElementVisibled(elmnt, temp_x, temp_y);
    
    if (getCookie("error_box_toggle") == 1)
        $("#error_list").slideDown(0);
    else
        $("#error_list").slideUp(0);
    
    if (document.getElementById(elmnt.id + "header"))
        document.getElementById(elmnt.id + "header").onmousedown = dragMouseDown;
    else
        elmnt.onmousedown = dragMouseDown;

    function dragMouseDown(e) {
        e = e || window.event;
        e.preventDefault();
        // get the mouse cursor position at startup:
        pos3 = e.clientX;
        pos4 = e.clientY;
        document.onmouseup = closeDragElement;
        // call a function whenever the cursor moves:
        document.onmousemove = elementDrag;
    }

    function elementDrag(e) {
        e = e || window.event;
        e.preventDefault();
        // calculate the new cursor position:
        pos1 = pos3 - e.clientX;
        pos2 = pos4 - e.clientY;
        pos3 = e.clientX;
        pos4 = e.clientY;
        setCookie("error_box_x", elmnt.offsetTop - pos2, 365);
        setCookie("error_box_y", elmnt.offsetLeft - pos1, 365);
        // set the element's new position:
        setElementVisibled(elmnt, elmnt.offsetTop - pos2, elmnt.offsetLeft - pos1);
    }

    function closeDragElement() {
        /* stop moving when mouse button is released:*/
        document.onmouseup = null;
        document.onmousemove = null;
    }
}

function setCookie(cname, cvalue, exdays) {
    const d = new Date();
    d.setTime(d.getTime() + (exdays*24*60*60*1000));
    let expires = "expires="+ d.toUTCString();
    document.cookie = cname + "=" + cvalue + ";" + expires + ";path=/";
}

function getCookie(cname) {
    let name = cname + "=";
    let decodedCookie = decodeURIComponent(document.cookie);
    let ca = decodedCookie.split(';');
    for(let i = 0; i <ca.length; i++) {
        let c = ca[i];
        while (c.charAt(0) == ' ')
            c = c.substring(1);
        if (c.indexOf(name) == 0)
            return c.substring(name.length, c.length);
    }
    return "";
  }

function close_error_box()
{
    $("#error_box").fadeOut( 1000, function() {
        $( this ).remove();
    });
}
function slide_error_box()
{
    $('#error_list').slideToggle(300, setCookie("error_box_toggle", $("#error_list").is(":hidden") == true ? "1" : "0", 365));
}

