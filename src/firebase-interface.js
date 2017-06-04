const firebase = require('firebase/app');
require('firebase/auth');
require('firebase/database');

const LOGIN_REQUEST_MSG = 'userLogin';
const USER_DID_LOGIN_MSG = 'userDidLogin';
const ADD_NOTE_MSG = 'addNote';
const NOTE_ADDED_MSG = 'noteAdded';

var notesRef, ports;

function initialize(firebaseConfig, elmApp) {
    ports = elmApp.ports;
    
    ports.firebaseOutgoing.subscribe((message) => {
        let parsedMessage = JSON.parse(message);
        switch (parsedMessage.type) {
            case LOGIN_REQUEST_MSG:
                handleLoginRequest(parsedMessage);
                break;
                
            case ADD_NOTE_MSG:
                handleAddNoteRequest(parsedMessage.note, parsedMessage.user);
                break;
            
            default:
                console.log('Unexpected message type ' + message.type);
        }
    });
    
    firebase.initializeApp(firebaseConfig);
    
    firebase.auth().onAuthStateChanged((user) => {
        if (user) {
            initializeDatabaseObservers(user);
            
            let message = {
                'type': USER_DID_LOGIN_MSG,
                'user': {
                    'email': user.email,
                    'displayName': user.displayName,
                    'uid': user.uid
                }
            };
            ports.firebaseIncoming.send(message)
        } else {
            clearDatabaseObservers();
        }
    });
}

function initializeDatabaseObservers(user) {
    notesRef = firebase.database().ref('notes/' + user.uid);
    notesRef.on('child_added', (data) => {
        let message = {
            'type': NOTE_ADDED_MSG,
            'note': {
                'uid': data.key,
                'text': data.val().text
            }
        };
        ports.firebaseIncoming.send(message);
    });
}

function clearDatabaseObservers() {
    notesRef.off('child_added');
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

function handleAddNoteRequest(note, user) {
    if (!notesRef) {
        return;
    }
    
    let noteRef = notesRef.push();
    noteRef.set({
        text: note.text  
    });
}

module.exports = {
    initialize: initialize
};