$(document).ready(function () {
    // Create an array with nodes
    var nodes = new vis.DataSet();
    var edges = new vis.DataSet();

    // Create a network
    var container = document.getElementById('network');
    // Provide the data in the vis format
    var data = {
        nodes: nodes,
        edges: edges,
    };

    var options = {
        nodes: {
            font: { color: '#ffffff' },
        },
        edges: {
            color: '#ffffff',
            width: 2,
        },
        physics: {
            stabilization: false,
        },
        interaction: {
            hover: true,
            zoomView: true,
        },
    };

    var network = new vis.Network(container, data, options);
    var respond_time_display = $('#respond_time_display');
    var respond_display = $('#respond_display');
    var __DIR__ = window.location.protocol + "//" + window.location.host + window.location.pathname;
    var fixedHorizontally = $('#fixHorizontalCheck').is(':checked');

    // Draw the horizontal lines
    drawAllHorizontalLine();

    // To keep track of already fetched UUIDs
    var fetchedUUIDs = new Set();

    var task_procing = 0;
    var task_proced = 0;
    // Hook the Apply button click
    $('#applyButton').click(async function () {
        // Clear the current nodes and edges
        fixedHorizontally = $('#fixHorizontalCheck').is(':checked');
        clearNodes();
    
        var searchIndicator = $('#indicator_search').val();
        var indicatorType = $('#indicator_type').val();
        var ajaxTime = new Date().getTime();
        
        await $.post('api/indicator.php', {
            indicator_search: searchIndicator,
            indicator_type: indicatorType,
            manual: 1,
        }, async function (response) {
            // Decode the JSON response
            var decodedResponse = JSON.parse(response);
    
            if (typeof decodedResponse.status !== 'undefined') {
                respond_display.html(decodedResponse.message);
            } else {
                respond_display.html("");
    
                // Check if decodedResponse size is over 100
                if (decodedResponse.length > 100) {
                    var continueProcess = confirm("The result size is over 100. This may take time to process. Do you want to continue?");
                    
                    // If user cancels, return and stop further processing
                    if (!continueProcess) {
                        return;
                    }
                }
    
                // Process the response and add nodes based on the result
                await decodedResponse.forEach(async function (result) {
                    await processResult(result);
                });

                await waitForTasks();
            }
    
            var totalTime = new Date().getTime() - ajaxTime;
            respond_time_display.html(totalTime);
        });
    });

    let mostRecentSteamID = null;  // Store the most recent SteamID
    let mostRecentIP = null;       // Store the most recent IP
    
    function sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }
    
    async function waitForTasks() {
        while (task_proced !== task_procing) {
            await sleep(10); // Wait 10ms before checking again
        }
        // Do something when the tasks are equal
        updateMostRecent();
    }

    async function updateMostRecent()
    {
        // Apply custom style to the most recent SteamID and IP after processing
        if (mostRecentSteamID) {
            let currentEdge = edges.get({
                filter: function (edge) {
                    return edge.from === mostRecentSteamID.uuid && edge.to === mostRecentSteamID.indicator;
                }
            })[0]; // Fetch the edge
        
            if (currentEdge) {
                edges.update({
                    id: currentEdge.id, // Keep the current edge ID
                    ...currentEdge,     // Spread current edge properties
                    shadow: {
                        enabled: true,
                        color: 'rgba(255,255,255,1.9)',
                        size: 10,
                        x: 1,
                        y: 1
                    }
                });
            }
        }
        
        if (mostRecentIP) {
            let currentEdge = edges.get({
                filter: function (edge) {
                    return edge.from === mostRecentIP.uuid && edge.to === mostRecentIP.indicator;
                }
            })[0]; // Fetch the edge
        
            if (currentEdge) {
                edges.update({
                    id: currentEdge.id, // Keep the current edge ID
                    ...currentEdge,     // Spread current edge properties
                    shadow: {
                        enabled: true,
                        color: 'rgba(255,255,255,1.9)',
                        size: 10,
                        x: 1,
                        y: 1
                    }
                });
            }
        }
    }

    // Function to clear nodes
    function clearNodes() {
        nodes.clear(); // Clears all nodes
        edges.clear(); // Clears all edges
        fetchedUUIDs.clear(); // Clears fetched UUIDs

        // Draw the horizontal lines
        drawAllHorizontalLine();
    }

    function drawAllHorizontalLine()
    {
        if(fixedHorizontally)
        {
            drawHorizontalLine(-500);
            drawHorizontalLine(0);
            drawHorizontalLine(1000);
            drawHorizontalLine(1200);
        }
        else
        {
            drawVerticalLine(0);
            drawHorizontalLine(0);
        }
    }

    // Function to draw a horizontal line at x:0
    function drawHorizontalLine(at_y) {
        nodes.add([
            { id: 'left_'+at_y, label: '', x: Number.MAX_SAFE_INTEGER*-1, y: at_y, fixed: true, physics: false, color: { border: '#ffffff', background: '#ffffff' } },
            { id: 'right_'+at_y, label: '', x: Number.MAX_SAFE_INTEGER, y: at_y, fixed: true, physics: false, color: { border: '#ffffff', background: '#ffffff' } }
        ]);
        edges.add({
            from: 'left_'+at_y,
            to: 'right_'+at_y,
            color: '#ffffff',
            smooth: { type: 'horizontal' }
        });
    }

    function drawVerticalLine(at_x) {
        nodes.add([
            { id: 'bot_'+at_x, label: '', y: Number.MAX_SAFE_INTEGER*-1, x: at_x, fixed: true, physics: false, color: { border: '#ffffff', background: '#ffffff' } },
            { id: 'top_'+at_x, label: '', y: Number.MAX_SAFE_INTEGER, x: at_x, fixed: true, physics: false, color: { border: '#ffffff', background: '#ffffff' } }
        ]);
        edges.add({
            from: 'bot_'+at_x,
            to: 'top_'+at_x,
            color: '#ffffff',
            smooth: { type: 'horizontal' }
        });
    }

    function nodeExists(nodeId) {
        return nodes.get(nodeId); // Return true if the node exists, false otherwise
    }

    // Function to process result data and fetch related UUIDs recursively
    // Modify the processResult function to save the most recent SteamID and IP
    async function processResult(result, gAccount_id = -1) {
        task_procing++;

        var uuid = result.UUID;
        var firstseen = result.firstseen;
        var lastseen = result.lastseen;
        var data = JSON.parse(result.data);
        var steamids = data.STEAMIDs;
        var ips = data.IPs;
        var accounts = data.ACCOUNTs;
        var pairs = data.PAIRs || [];
        var syncChains = [];

        // Collect UUIDs from sync_chain in IPs or SteamIDs if present
        ips.forEach(function (ip) {
            if (ip.is_sync && ip.sync_chain) {
                ip.sync_chain.forEach(function (sync) {
                    syncChains.push(sync.uuid);
                });
            }
        });

        steamids.forEach(function (steamid) {
            if (steamid.is_sync && steamid.sync_chain) {
                steamid.sync_chain.forEach(function (sync) {
                    syncChains.push(sync.uuid);
                });
            }
        });

        // Add UUID node
        if (!nodes.get(uuid)) {
            addNode(uuid, 'UUID', uuid, uuid, { firstseen: firstseen, lastseen: lastseen }); // UUID above the x-axis
        }

        // Add SteamID nodes and connect them
        steamids.forEach(function (steamid) {
            if (!nodeExists(steamid.indicator))
                addNode(steamid.indicator, 'SteamID', steamid.indicator, uuid, steamid);
            var connectionType = getConnectionType(steamid.is_sync, steamid.lastseen);
            connectNodes(connectionType, uuid, steamid.indicator);

            // Check if the current SteamID is more recent
            if (!mostRecentSteamID || new Date(steamid.lastseen) > new Date(mostRecentSteamID.lastseen)) {
                mostRecentSteamID = steamid;
                mostRecentSteamID.uuid = uuid;
            }
        });

        // Add IP nodes and connect them
        ips.forEach(function (ip) {
            if (!nodeExists(ip.indicator))
                addNode(ip.indicator, 'IP', ip.indicator, uuid, ip);
            var connectionType = getConnectionType(ip.is_sync, ip.lastseen);
            connectNodes(connectionType, uuid, ip.indicator);

            // Check if the current IP is more recent
            if (!mostRecentIP || new Date(ip.lastseen) > new Date(mostRecentIP.lastseen)) {
                mostRecentIP = ip;
                mostRecentIP.uuid = uuid;
            }
        });

        await accounts.forEach(async function (account_id) {
            aid = account_id;
            account_id = "#" + account_id;
            if (!nodeExists(account_id)) {
                addNode(account_id, 'Account', account_id, uuid); // IP below the x-axis
                connectNodes("local", uuid, account_id);
                await fetch_AccountID_UUIDData(aid);
            }
            else
                connectNodes("synced", uuid, account_id);
        });

        // Connect UUIDs from PAIRs or sync_chain, recursively fetching new ones
        await pairs.concat(syncChains).forEach(async function (relatedUUID) {
            if (!nodes.get(relatedUUID)) {
                // If we haven't fetched this UUID yet, fetch it recursively
                if (!fetchedUUIDs.has(relatedUUID)) {
                    fetchedUUIDs.add(relatedUUID);
                    await fetchUUIDData(relatedUUID);
                }
            }
            connectNodes('link', uuid, relatedUUID);
        });

        if (gAccount_id > 0)
            connectNodes("current", uuid, "#" + gAccount_id);

        task_proced++;
    }


    function addNode(id, type, label, groupid, details, value = 1, yPos = 0) {
        // Create a title for the node using details (if available)
        let titleHTML = "";
        if (details) {
            if (details.firstseen) titleHTML += `<strong>First Seen:</strong> ${details.firstseen}<br>`;
            if (details.lastseen) titleHTML += `<strong>Last Seen:</strong> ${details.lastseen}<br>`;
            if (details.is_proxy !== undefined) titleHTML += `<strong>Is Proxy:</strong> ${details.is_proxy}<br>`;
            if (details.is_vpn !== undefined) titleHTML += `<strong>Is VPN:</strong> ${details.is_vpn}<br>`;
            if (details.is_datacenter !== undefined) titleHTML += `<strong>Is Datacenter:</strong> ${details.is_datacenter}<br>`;
            if (details.asn_asn) titleHTML += `<strong>ASN:</strong> ${details.asn_asn}<br>`;
            if (details.asn_route) titleHTML += `<strong>ASN Route:</strong> ${details.asn_route}<br>`;
            if (details.asn_org) titleHTML += `<strong>ASN Org:</strong> ${details.asn_org}<br>`;
            if (details.location_country_code) titleHTML += `<strong>Country Code:</strong> ${details.location_country_code}<br>`;
            if (details.is_nonsteam !== undefined) titleHTML += `<strong>Is Steam:</strong> ${!details.is_nonsteam}<br>`;
        }

        if (nodeExists(id)) {
            let existingNode = nodes.get(id);
            
            // Parse the existing lastseen and new lastseen for comparison
            let existingLastSeen = new Date(existingNode.details.lastseen);
            let newLastSeen = new Date(details.lastseen);

            // Only update if the new lastseen is more recent
            if (newLastSeen > existingLastSeen) {
                nodes.update({
                    id: id,
                    title: titleHTML, // Update the title with new details
                    label: label, // Update label if necessary
                    group: groupid, // Update group if necessary
                    value: value, // Update value if necessary
                    details: details // Store the new details with updated lastseen
                });
            }
            return;
        }
    
        var shape = "image";
        var image = "";
        var mass = 1;
        var size = 20;
    
        // Set shape, value, and y-position based on node type
        switch (type) {
            case 'UUID':
                image = "Hardware-My-Computer-3-icon.png";
                size = 30;
                mass = 7;
                break;
            case 'SteamID':
                mass = 2;
                yPos = 1000;
                image = details.is_nonsteam ? "Counter-Strike-icon.png" : "steam-icon-256x256-r6dygp6h.png";
                break;
            case 'IP':
                mass = 2;
                yPos = 1200;
                image = (details.is_datacenter || details.is_vpn || details.is_proxy) ? "Network Connections.png" : "Network Setup.png";
                break;
            case 'Account':
                yPos = -500;
                mass = 5;
                size = 50;
                image = "User-Administrator-Blue-icon.png";
                break;
            case 'Bid':
                image = "System-Firewall-2-icon.png";
                break;
            case 'Blacklist_cur':
                image = "Network-Pipe-icon.png";
                break;
            case 'Blacklist_loc':
                image = "Hardware-My-Computer-3-icon.png";
                break;
            case 'Blacklist_sync':
                image = "System-Globe-icon.png";
                break;
        }
    
        // Add the node to the network
        nodes.add({
            id: id,
            label: label,
            type: type,
            shape: shape,
            group: groupid,
            image: image ? __DIR__ + "/img/" + image : undefined,
            mass: mass,
            size: size,
            y: yPos,
            fixed: { y: fixedHorizontally },
            font: { 
                color: '#ffffff', 
                background: '#000000', 
                size: 16,
            },
            labelHighlightBold: false, // Remove bold labels
            title: titleHTML, // Set the HTML title with firstseen and lastseen info
            details: details
        });
    }
    

    // Function to connect two nodes
    function connectNodes(type, node1, node2) {
        var style = {};
    
        // Define edge styles based on the type
        switch (type) {
            case 'current':
                style = { width: 10, smooth: false, physics: !fixedHorizontally, length: 300 };
                break;
            case 'local':
                style = { width: 2, smooth: false, physics: !fixedHorizontally, length: 300 };
                break;
            case 'synced':
                style = {
                    dashes: [10, 10],       // Dashed line for "synced"
                    width: 2,               // Line width
                    smooth: false,          // No smoothing effect
                    physics: false,         // Disable physics for this edge (won't pull nodes)
                };
                break;
            case 'exclude':
                style = { arrows: { to: { enabled: true } }, color: { color: 'red' }, width: 2, smooth: { type: 'curvedCCW', roundness: 0.5 }, physics: !fixedHorizontally, length: 500 };
                break;
            case 'link':
                style = { dashes: [3, 20], width: 5, smooth: { type: 'diagonalCross', roundness: 0.5 }, physics: false, length: 700 };
                break;
        }
    
        // Check if an edge already exists between node1 and node2
        var existingEdges = edges.get({
            filter: function (edge) {
                return (edge.from === node1 && edge.to === node2) || (edge.from === node2 && edge.to === node1);
            }
        });
    
        // If there are any existing edges between these nodes, remove them
        if (existingEdges.length > 0) {
            edges.remove(existingEdges.map(edge => edge.id));
        }
    
        // Add the new edge with the defined style
        edges.add({
            from: node1,
            to: node2,
            ...style
        });
    }

    // Function to determine the connection type based on sync and lastseen status
    function getConnectionType(is_sync, lastseen) {
        var currentTime = new Date().getTime();
        var lastSeenTime = new Date(lastseen).getTime();
        var timeDifference = currentTime - lastSeenTime;

        // If it's the most recent (last seen) SteamID/IP, use 'current'
        if (timeDifference <= 86400000 && !is_sync) { // 24 hours
            return 'current';
        }

        // Otherwise, use 'synced' or 'local' based on the is_sync value
        return is_sync ? 'synced' : 'local';
    }

    // Function to fetch UUID data from indicator.php and add to the graph
    async function fetchUUIDData(uuid) {
        task_procing++;

        $.post('api/indicator.php', {
            indicator_search: uuid,
            indicator_type: 'UUID', // We know it's a UUID
        }, function (response) {
            // Decode the JSON response
            var decodedResponse = JSON.parse(response);

            // Add the UUID node and related connections
            decodedResponse.forEach(async function (result) {
                await processResult(result);
            });
            task_proced++;
        });
    }

    async function fetch_AccountID_UUIDData(account_id) {
        task_procing++;

        $.post('api/indicator.php', {
            indicator_search: account_id,
            indicator_type: 'account_uuid', // We know it's a UUID
        }, function (response) {
            // Decode the JSON response
            var decodedResponse = JSON.parse(response);

            // Add the UUID node and related connections
            decodedResponse.forEach(async function (result) {
                await processResult(result, account_id);
            });
            task_proced++;
        });
    }

    // Add event listeners for select and deselect events
    network.on("selectNode", function (params) {
        var nodeId = params.nodes[0]; // The selected node ID
        highlightConnectedNodesAndEdges(nodeId);
    });

    network.on("deselectNode", function (params) {
        resetHighlight();
    });

    // Function to highlight only the connected nodes and edges
    function highlightConnectedNodesAndEdges(nodeId) {
        var connectedEdges = network.getConnectedEdges(nodeId); // Get edges connected to the selected node
        var connectedNodes = network.getConnectedNodes(nodeId); // Get nodes connected to the selected node
        
        // Get a list of all node and edge IDs
        var allNodes = nodes.getIds();
        var allEdges = edges.getIds();

        // Reduce opacity of all nodes and dim their labels
        allNodes.forEach(function (node) {
            if (node !== nodeId && !connectedNodes.includes(node)) {
                nodes.update({
                    id: node, 
                    opacity: 0.1,
                    font: { color: '#aaaaaa', size: 0 },  // Dimming the label
                    labelHighlightBold: false // Remove bold label for unconnected nodes
                });
            }
        });

        // Reduce opacity of all unconnected edges
        allEdges.forEach(function (edgeId) {
            if (!connectedEdges.includes(edgeId)) {
                edges.update({
                    id: edgeId,
                    color: {
                        opacity: 0.1 // Set edge opacity to 10%
                    }
                });
            }
        });

        // Set full opacity and highlight the selected node, its connected nodes, and edges
        nodes.update({ 
            id: nodeId, 
            opacity: 1, 
            font: { background: '#FFD700', color: '#000000', size: 16 }, // Highlight the selected node label with colored background
            labelHighlightBold: true // Make the label bold for the selected node
        });

        connectedNodes.forEach(function (connectedNodeId) {
            nodes.update({
                id: connectedNodeId, 
                opacity: 1,
                font: { color: '#ffffff', size: 16 }, // Restore connected nodes' labels to full visibility
                labelHighlightBold: true // Make labels bold for connected nodes
            });
        });

        connectedEdges.forEach(function (edgeId) {
            edges.update({
                id: edgeId,
                color: {
                    opacity: 1 // Set edge opacity to full
                }
            });
        });
    }

    // Function to reset all nodes and edges to full visibility again
    function resetHighlight() {
        // Show all nodes and edges at full opacity and restore labels
        var allNodes = nodes.getIds();
        var allEdges = edges.getIds();

        allNodes.forEach(function (node) {
            nodes.update({
                id: node, 
                opacity: 1, 
                font: { color: '#ffffff', background: "#000000", size: 14 },  // Reset the label color and background
                labelHighlightBold: false // Remove bold labels
            });
        });

        allEdges.forEach(function (edgeId) {
            edges.update({
                id: edgeId,
                color: {
                    opacity: 1 // Reset edge opacity to full
                }
            });
        });
    }

    // Function to handle double-click on a node
    function handleNodeDoubleClick(node) {
        // Copy the node ID to the clipboard
        copyToClipboard(node.id);

        // Get the mouse cursor position
        const cursorX = event.clientX;
        const cursorY = event.clientY;

        // Create a floating text element
        createFloatingText(cursorX, cursorY, "Copied: " + node.id);
    }

    // Function to copy text to the clipboard
    function copyToClipboard(text) {
        // Create a temporary input element
        var tempInput = document.createElement("input");
        document.body.appendChild(tempInput);
        tempInput.value = text;

        // Select the text in the input element and copy it
        tempInput.select();
        tempInput.setSelectionRange(0, 99999); // For mobile devices
        document.execCommand("copy");

        // Remove the temporary input element
        document.body.removeChild(tempInput);
    }

    // Function to create floating text at the cursor position
    function createFloatingText(x, y, text) {
        // Create a new text element
        var textElement = document.createElement("div");
        textElement.innerText = text;
        textElement.style.position = "absolute";
        textElement.style.left = x + "px";
        textElement.style.top = y + "px";
        textElement.style.fontSize = "12px";
        textElement.style.color = "#00ff00"; // Green text color
        textElement.style.pointerEvents = "none"; // Ignore pointer events

        // Add the text element to the document
        document.body.appendChild(textElement);

        // Animate the text to move upward and fade out
        animateFloatingText(textElement);
    }

    // Function to animate the floating text
    function animateFloatingText(element) {
        let opacity = 1; // Initial opacity
        let posY = parseInt(element.style.top); // Initial Y position
        const interval = setInterval(function () {
            if (opacity <= 0) {
                clearInterval(interval);
                element.remove(); // Remove the element after fading out
            } else {
                posY -= 1; // Move the text upward
                opacity -= 0.02; // Reduce the opacity
                element.style.top = posY + "px";
                element.style.opacity = opacity;
            }
        }, 30); // Set the animation speed
    }

    // Hook the double-click event listener
    network.on("doubleClick", function (params) {
        // Check if a node was double-clicked
        if (params.nodes.length > 0) {
            var nodeId = params.nodes[0];
            var node = nodes.get(nodeId);
            if (node) {
                handleNodeDoubleClick(node);
            }
        }
    });

    // Define desync_users within the ready function
    window.desync_users = function() {
        let results = [];
        let totalRequests = 0;
        let completedRequests = 0;
    
        // Create a results overlay
        let resultsOverlay = `
            <div id="resultsOverlay" style="position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0, 0, 0, 0.8); z-index: 1000; display: flex; flex-direction: column; align-items: center; justify-content: center; color: white;">
                <div style="background: white; padding: 20px; border-radius: 8px; width: 50%; max-width: 600px; position: relative; color: black;">
                    <h3>Desync Results</h3>
                    <ul id="resultsList" style="list-style: none; padding-left: 0;max-height: 500px;overflow-y: scroll;"></ul>
                    <button id="closeResults" style="position: absolute; top: 10px; right: 10px; border: none; background: transparent; font-size: 20px;">&times;</button>
                </div>
            </div>
        `;
    
        // Append the results overlay to the body
        $('body').append(resultsOverlay);
    
        // Handle the close button for the results overlay
        $('#closeResults').click(function() {
            $('#resultsOverlay').remove(); // Remove the overlay when closed
        });
    
        // Iterate over all the currently displayed UUIDs (from nodes)
        nodes.forEach(function(node) {
            if (node.type === 'UUID') {
                totalRequests++; // Increment total requests counter
    
                // Make an AJAX request to desync.php with the UUID
                $.post('api/desync.php', { uuid: node.id })
                    .done(function() {
                        // Add success message to the results
                        results.push(`UUID: ${node.id} - Success`);
                    })
                    .fail(function(jqXHR) {
                        // Handle failure cases (404 Not Found, 500 Internal Error)
                        if (jqXHR.status === 404) {
                            results.push(`UUID: ${node.id} - Not Found`);
                        } else {
                            results.push(`UUID: ${node.id} - Error`);
                        }
                    })
                    .always(function() {
                        completedRequests++; // Increment completed requests counter
    
                        // Check if all requests are finished
                        if (completedRequests === totalRequests) {
                            // Append the results to the results list
                            results.forEach(function(result) {
                                $('#resultsList').append(`<li>${result}</li>`);
                            });
                        }
                    });
            }
        });
    
        if (totalRequests === 0) {
            // If there were no UUIDs to desync, notify and remove the overlay
            $('#resultsList').append('<li>No UUIDs to desync.</li>');
        }
    };    
    
});