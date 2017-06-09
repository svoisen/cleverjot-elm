require('firebase/database');

const PUSH_DATA_MSG = 'pushData',
      DATA_PUSHED_MSG = 'dataPushed';

function initialize(firebase, elmApp) {
    elmApp.ports.databaseWrite.subscribe((message) => {
        let parsedMessage = JSON.parse(message) ;
        
        switch (parsedMessage.type) {
            case PUSH_DATA_MSG:
                handlePush(firebase, elmApp, parsedMessage.path, parsedMessage.data);
                break;
            
            default:
                // code
        }
    });
}

function handlePush(firebase, elmApp, path, data) {
    var ref = firebase.database().ref(path),
        key = ref.push();
        
    ref.set(data);
    
    let message = {
        'type': DATA_PUSHED_MSG,
        'path': path,
        'key': ref.key,
        'data': ref.val()
    };
    elmApp.ports.databaseRead.send(message);
}

module.exports = {
    initialize: initialize 
};