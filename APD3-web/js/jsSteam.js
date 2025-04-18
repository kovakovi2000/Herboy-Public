// Basic usage example, with API key
const api = require('../steam-js-api')

// I recommend using environment variables for security. This is what I do.
// More info here: https://www.twilio.com/blog/working-with-environment-variables-in-node-js-html
api.setKey('{B8F75DD798E24C47D60F460115D1DD38}')

steamID = '76561198099490962' // My Steam ID, feel free to use it for testing :)
appID = 730 // We only want to check for one game
moreInfo = true // Provide more info (name, links)


// Synchronous result
let result
try {
    result = await api.getOwnedGames(steamID, appID, moreInfo)
    console.log(result.data.games[0])
} catch (e) {
    console.error(e)
}


// With a callback
api.getOwnedGames(steamID, appID, moreInfo, (result) => {
    if (result.error)
        console.error(result)
    else
        console.log(result.data.games[0])
})


// Alternatively, use a Promise
api.getOwnedGames(steamID, appID, moreInfo).then(result => {
    console.log(result.data.games[0])
}).catch(console.error)