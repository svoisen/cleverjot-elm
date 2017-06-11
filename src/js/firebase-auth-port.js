require('firebase/auth');

const SIGN_OUT_MSG = 'signOut',
      SIGNED_OUT_MSG = 'signedOut',
      SIGN_IN_SUCCESS_MSG = 'signedIn',
      EMAIL_PASSWORD_SIGNIN_MSG = 'emailPasswordSignIn';

function initialize(firebase, elmApp) {
    elmApp.ports.authWrite.subscribe((message) => {
        let parsedMessage = JSON.parse(message);
        
        switch (parsedMessage.type) {
            case EMAIL_PASSWORD_SIGNIN_MSG:
                handleEmailPasswordSignIn(firebase, elmApp, parsedMessage.credentials);
                break;
        }
    });
    
    firebase.auth().onAuthStateChanged((user) => {
        if (user) {
            let message = {
                'type': SIGN_IN_SUCCESS_MSG,
                'user': user
            };
            elmApp.ports.authRead.send(message);
        } else {
            let message = {
                'type': SIGNED_OUT_MSG
            };
            elmApp.ports.authRead.send(message);
        }
    })
}

function handleEmailPasswordSignIn(firebase, elmApp, credentials) {
    console.log(credentials);
    if (firebase.auth().currentUser)  {
        firebase.auth().signOut();
    }
    
    firebase.auth().signInWithEmailAndPassword(credentials.email, credentials.password).catch(function (error) {
        const errorCode = error.code,
              errorMsg = error.message;
            
        console.log(errorMsg);
        
        writeErrorMessage(elmApp, errorMsg, errorCode);
    });
}

function writeErrorMessage(elmApp, errorMsg, code) {
    let message = {
        'type': 'error',
        'message': errorMsg,
        'code': code
    };
    
    elmApp.ports.authRead.send(message);
}

module.exports = {
    initialize: initialize
};