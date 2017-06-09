const firebase = require('firebase/app'),
      database = require('./firebase-db-port'),
      auth = require('./firebase-auth-port');

function initialize(firebaseConfig, elmApp) {
    firebase.initializeApp(firebaseConfig);
    
    auth.initialize(firebase, elmApp);
    database.initialize(firebase, elmApp);
    
    return firebase;
}

module.exports = {
    initialize: initialize
};