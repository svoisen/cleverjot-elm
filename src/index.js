'use strict'

require('./index.html');

var firebaseConfig = {
        apiKey: "AIzaSyC3T9vEg7oHWpO1BRt4uSLRe9yuQ87pn_E",
        authDomain: "mantra-8c5c7.firebaseapp.com",
        databaseURL: "https://mantra-8c5c7.firebaseio.com",
        projectId: "mantra-8c5c7",
        storageBucket: "mantra-8c5c7.appspot.com",
        messagingSenderId: "815268911169"
    },
    Elm = require('./Main.elm'),
    firebase = require('./firebase-interface.js'),
    mountNode = document.getElementById('main'),
    app = Elm.Main.embed(mountNode);
    
firebase.initialize(firebaseConfig, app);