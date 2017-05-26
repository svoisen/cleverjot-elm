'use strict'

var Elm = require('./Main.elm'),
    firebase = require('firebase/app');
    
require('firebase/auth');
require('firebase/database');
require('ace-css/css/ace.css');
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

// app.ports.login.subscribe(function (credentials) {
//     console.log(credentials);
// });