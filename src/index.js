'use strict'

var Elm = require('./Main.elm'),
    firebase = require('firebase/app');
    
require('firebase/auth');
require('firebase/database');
require('./index.html');

var firebaseConfig = {
        apiKey: "AIzaSyC3T9vEg7oHWpO1BRt4uSLRe9yuQ87pn_E",
        authDomain: "mantra-8c5c7.firebaseapp.com",
        databaseURL: "https://mantra-8c5c7.firebaseio.com",
        projectId: "mantra-8c5c7",
        storageBucket: "mantra-8c5c7.appspot.com",
        messagingSenderId: "815268911169"
    },
    firebaseApp = firebase.initializeApp(firebaseConfig),
    mountNode = document.getElementById('main'),
    app = Elm.Main.embed(mountNode);
    
firebase.auth().onAuthStateChanged(function (user) {
    if (user) {
        console.log("Signed in");
        console.log(user);
    } else {
        console.log("Signed out");
    }
});

app.ports.login.subscribe(function (credentials) {
    if (firebase.auth().currentUser) {
        firebase.auth().signOut();
    }
    
    firebase.auth().signInWithEmailAndPassword(credentials.email, credentials.password).catch(function (error) {
        var errorCode = error.code,
            errorMsg = error.message;
            
        if (errorCode === 'auth/wrong-password') {
            console.log('Wrong password');
        } else {
            console.log(errorMsg);
        }
    });
});