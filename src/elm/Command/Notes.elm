module Command.Notes exposing 
    ( addNote
    , updateNote
    , listenNoteAdded
    )
    

import Data.Note exposing (Note, encodeNote)
import Data.User exposing (User)
import Firebase.Database as FBDatabase exposing (Path)


userNotesRoot : String
userNotesRoot = "user-notes/"


addNote : Note -> User -> Cmd msg
addNote note user =
    FBDatabase.pushData (encodeNote note) (userNotesPath user)
    
    
updateNote : Note -> User -> Cmd msg
updateNote note user =
    FBDatabase.setData (encodeNote note) (notePath user note)
    
    
listenNoteAdded : User -> Cmd msg
listenNoteAdded user =
    FBDatabase.listenChildAdded <| userNotesPath user


userNotesPath : User -> Path
userNotesPath user =
    userNotesRoot ++ user.uid
    

notePath : User -> Note -> Path
notePath user note =
    userNotesRoot ++ user.uid ++ "/" ++ note.uid