module Command.Notes exposing (addNote, listenNoteAdded)


import Data.Note exposing (Note, encodeNote)
import Data.User exposing (User)
import Firebase.Database as Database exposing (Path)


addNote : Note -> User -> Cmd msg
addNote note user =
    Database.pushData (encodeNote note) (userNotesPath user)
    
    
listenNoteAdded : User -> Cmd msg
listenNoteAdded user =
    Database.listenChildAdded <| userNotesPath user


userNotesPath : User -> Path
userNotesPath user =
    "notes/" ++ user.uid