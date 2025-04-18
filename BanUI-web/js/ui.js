// Update explanation text based on selected indicator type
$('#indicator_type').on('change', function() {
    var selectedType = $(this).val();
    var description = '';

    switch (selectedType) {
        case 'UUID':
            description = 'Search by a universally unique identifier (UUID) for each game instance.';
            break;
        case 'steamid':
            description = 'Search by a SteamID, the unique identifier for Steam accounts.';
            break;
        case 'ip':
            description = 'Search by an IP address.';
            break;
        case 'oldkey':
            description = 'Search by an OldKey, a legacy identifier from previous bansys.';
            break;
        case 'account':
            description = 'Search by on server account #id.';
            break;
        case 'account_uuid':
            description = 'Search by on server account #id and it\'s last UUID.';
            break;
        case 'account_info':
            description = 'Search the server account #id and it\'s last login info and register info (SteamID, IP).';
            break;
        default:
            description = 'Search any type of indicator.';
            break;
    }

    $('#indicator_description').text(description);
});

// Toggle dropdown when the arrow is clicked
var dropdownVisible = false;

$('#dropdownArrow').click(function() {
    if (dropdownVisible) {
        $('#dropdownMenu').css('top', '-100px'); // Hide dropdown
        $('#dropdownArrow').html('<i class="bi bi-chevron-double-down"></i>'); // Change arrow direction
    } else {
        $('#dropdownMenu').css('top', '0'); // Show dropdown
        $('#dropdownArrow').html('<i class="bi bi-chevron-double-up"></i>'); // Change arrow direction
    }
    dropdownVisible = !dropdownVisible;
});


// Event handler for the "Desync Cluster" button
$('#desyncClusterButton').click(function() {
    // Create a confirmation modal overlay
    let modal = `
        <div id="desyncModal" style="position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0, 0, 0, 0.8); display: flex; align-items: center; justify-content: center; z-index: 1000;">
            <div style="background: white; padding: 20px; border-radius: 8px; text-align: center; width: 300px;">
                <h3>Are you sure?</h3>
                <p>This action will desync the current cluster and might cause data inconsistency. All UUID that is currently loaded will lose it sync. Only use this option if you know what you are doing and proceed with caution!</p>
                <button id="confirmDesync" class="btn btn-danger">Yes, proceed</button>
                <button id="cancelDesync" class="btn btn-secondary">Cancel</button>
            </div>
        </div>
    `;

    // Append modal to the body
    $('body').append(modal);

    // Event handler for confirmation button
    $('#confirmDesync').click(function() {
        // Call desync_users function from network.js
        desync_users();
        $('#desyncModal').remove();  // Remove the modal after action
    });

    // Event handler for cancel button
    $('#cancelDesync').click(function() {
        $('#desyncModal').remove();  // Close the modal without action
    });
});