require('firebase/database');

const PUSH_DATA_MSG = 'pushData',
      DATA_PUSHED_MSG = 'dataPushed',
      SET_DATA_MSG = 'setData',
      DATA_SET_MSG = 'dataSet',
      LISTEN_CHILD_ADDED_MSG = 'listenChildAdded',
      CHILD_ADDED_MSG = 'childAdded',
      LISTEN_CHILD_CHANGED_MSG = 'listenChildChanged',
      CHILD_CHANGED_MSG = 'childChanged';

function initialize(firebase, elmApp) {
    elmApp.ports.databaseWrite.subscribe((message) => {
        let parsedMessage = JSON.parse(message) ;
        
        switch (parsedMessage.type) {
            case PUSH_DATA_MSG:
                handlePushData(firebase, elmApp, parsedMessage.path, parsedMessage.data);
                break;
                
            case SET_DATA_MSG:
                handleSetData(firebase, elmApp, parsedMessage.path, parsedMessage.data);
                break;
                
            case LISTEN_CHILD_ADDED_MSG:
                handleListenChildAdded(firebase, elmApp, parsedMessage.path);
                break;
            
            default:
                break;
        }
    });
}

function handleSetData(firebase, elmApp, path, data) {
    var ref = firebase.database().ref(path);
    ref.set(data);
    
    console.log('Set data at path ' + path + ' with key ' + ref.key);
    
    let message = {
        'type': DATA_SET_MSG,
        'path': path,
        'key': ref.key,
        'data': data
    };
    elmApp.ports.databaseRead.send(message);
}

function handlePushData(firebase, elmApp, path, data) {
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