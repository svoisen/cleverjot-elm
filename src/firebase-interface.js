const firebase = require('firebase/app');
require('firebase/auth');
require('firebase/database');

function initialize(firebaseConfig, elmApp) {
    let ports = elmApp.ports;
    ports.firebaseOutgoing.subscribe((message) => {
        let parsedMessage = JSON.parse(message);
        switch (parsedMessage.type) {
            case 'login':
                handleLoginRequest(parsedMessage.payload);
                break;
            
            default:
                console.log('Unexpected message type ' + message.type);
        }
    });
    
    firebase.initializeApp(firebaseConfig);
    
    firebase.auth().onAuthStateChanged((user) => {
        if (user) {
            console.log("Signed in");
        } else {
            console.log("Signed out");
        }
    });
}

function handleLoginRequest(credentials) {
    if (firebase.auth().currentUser) {
        firebase.auth().signOut();
    }
    
    firebase.auth().signInWithEmailAndPassword(credentials.email, credentials.password).catch(function (error) {
        const errorCode = error.code,
              errorMsg = error.message;
            
        if (errorCode === 'auth/wrong-password') {
            console.log('Wrong password');
        } else {
            console.log(errorMsg);
        }
    });
}

module.exports = {
    initialize: initialize
};