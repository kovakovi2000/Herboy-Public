var c = document.getElementById("matrix");
var ctx = c.getContext("2d");

// Set canvas full screen
c.height = window.innerHeight;
c.width = window.innerWidth;

// Characters
var letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ123456789@#$%^&*()*&^%";
letters = letters.split("");

var fontSize = 10;
var columns = c.width / fontSize;

// Array of drops, one for each column
var drops = [];
var specialColumns = {}; // Keep track of columns showing custom text and their current character index
var customLines = []; // Store lines from matrix.junk

for (var x = 0; x < columns; x++) {
    drops[x] = 1;
}

// Load matrix.junk and store lines
$.get('matrix.junk', function(data) {
    // Split the text by newline and trim each line
    customLines = data.split('\n').map(function(line) {
        return line.trim();
    }).filter(Boolean); // Filter out empty lines
});

function draw() {
    // Black background with opacity for fade effect
    ctx.fillStyle = "rgba(0, 0, 0, 0.05)";
    ctx.fillRect(0, 0, c.width, c.height);

    // Set font style
    ctx.font = fontSize + "px arial";

    // Looping over drops
    for (var i = 0; i < drops.length; i++) {
        // Check if this column should display the custom text
        if (specialColumns[i] !== undefined && customLines.length > 0) {
            //ctx.fillStyle = "#FFFFFF"; // White for custom text

            // Get the current character index for this column
            var charIndex = specialColumns[i].charIndex;

            // Display the current character from the custom string
            var text = specialColumns[i].text[charIndex];
            ctx.fillText(text, i * fontSize, drops[i] * fontSize);

            // Move to the next character in the string
            specialColumns[i].charIndex++;

            // If the entire string has been displayed, reset this column to random characters
            if (specialColumns[i].charIndex >= specialColumns[i].text.length) {
                delete specialColumns[i]; // Remove this column from the special tracking
            }
        } else {
            // Regular random characters
            ctx.fillStyle = "#00FFFF"; // Cyan text for regular matrix letters
            var text = letters[Math.floor(Math.random() * letters.length)];
            ctx.fillText(text, i * fontSize, drops[i] * fontSize);

            // Randomly start showing a custom string in this column
            if (Math.random() < 0.1 && customLines.length > 0) {
                var randomLine = customLines[Math.floor(Math.random() * customLines.length)];
                specialColumns[i] = { text: " "+randomLine+" ", charIndex: 0 }; // Set the custom text and start at the first character
            }
        }

        // Randomly resetting drop back to top
        if (drops[i] * fontSize > c.height && Math.random() > 0.975) {
            drops[i] = 0;
        }

        // Incrementing Y-coordinate for next drawing
        drops[i]++;
    }
}

// Drawing the characters at 33ms interval
setInterval(draw, 33);