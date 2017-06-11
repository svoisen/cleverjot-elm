require('firebase/database');

const PUSH_DATA_MSG = 'pushData',
      DATA_PUSHED_MSG = 'dataPushed',
      LISTEN_CHILD_ADDED_MSG = 'listenChildAdded',
      CHILD_ADDED_MSG = 'childAdded';

function initialize(firebase, elmApp) {
    elmApp.ports.databaseWrite.subscribe((message) => {
        let parsedMessage = JSON.parse(message) ;
        
        switch (parsedMessage.type) {
            case PUSH_DATA_MSG:
                handlePush(firebase, elmApp, parsedMessage.path, parsedMessage.data);
                break;
                
            case LISTEN_CHILD_ADDED_MSG:
                handleListenChildAdded(firebase, elmApp, parsedMessage.path);
                break;
            
            default:
                break;
        }
    });
}

function handlePush(firebase, elmApp, path, data) {
    var ref = firebase.database().ref(path).push();
    ref.set(data);
    
    console.log('Added data to path ' + path + ' with key ' + ref.key);
    
    let message = {
        'type': DATA_PUSHED_MSG,
        'path': path,
        'key': ref.key,
        'data': data
    };
    elmApp.ports.databaseRead.send(message);
}

function handleListenChildAdded(firebase, elmApp, path) {
    var ref = firebase.database().ref(path);
    ref.on('child_added', (data) => {
        let message = {
            'type': CHILD_ADDED_MSG,
            'path': path,
            'key': data.key,
            'data': data.val()
        };
        console.log(message);
        elmApp.ports.databaseRead.send(message);
    });
}

module.exports = {
    initialize: initialize 
};