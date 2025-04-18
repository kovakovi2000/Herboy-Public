// Show loading overlay and disable form inputs during the process with fade-in effect
function showLoadingOverlay() {
    $('.loading-overlay').css({
        'display': 'flex',
        'opacity': '0'
    }).animate({ opacity: 1 }, 500); // Animate opacity to 1 for fade-in over 0.5 seconds
    $('input, button').prop('disabled', true); // Disable form inputs and buttons
}

// Hide loading overlay and re-enable form inputs with fade-out effect
function hideLoadingOverlay(shake = true) {
    $('.loading-overlay').animate({ opacity: 0 }, 500, function() {
        $(this).css('display', 'none'); // Set display to none after fade-out completes
    });
    $('input, button').prop('disabled', false); // Re-enable form inputs and buttons
    if(shake) shakeLoginPanel();
}

// Handle form submission
// Handle form submission
$('form').on('submit', function(e) {
    e.preventDefault();
    showLoadingOverlay(); // Show the loading overlay when login is submitted

    // Get the CSRF token
    var csrfToken = $('input[name="csrf_token"]').val();
    var register_token = $('input[name="register_token"]').val();
    var respond_display = $('#respond_display');
    
    // Simulate a 3-second delay even after response is received
    setTimeout(function() {
        $.ajax({
            url: 'api/process_login.php', // Replace with your actual login endpoint
            method: 'POST',
            data: {
                username: $('#username').val(),
                password: $('#password').val(),
                csrf_token: csrfToken, // Include CSRF token explicitly
                register_token: register_token
            },
            success: function(response) {
                respond_display.html(response);
                hideLoadingOverlay(true);
            },
            statusCode: {
                202: function() {
                    respond_display.css('color', 'green');
                    hideLoadingOverlay(false);
                    setTimeout(function() {
                        var urlWithoutQueryString = window.location.protocol + "//" + window.location.host + window.location.pathname;
                        window.location.href = urlWithoutQueryString;
                    }, 3000);
                }
            }
        });
    }, 3000);
});


// Function to shake the login panel on login failure
function shakeLoginPanel() {
    $('.login-box').addClass('shake');
    setTimeout(function() {
        $('.login-box').removeClass('shake');
    }, 1000); // Keep the shake effect for 1 second
}
