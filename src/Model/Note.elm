module Model.Note exposing (NoteCollection, Note, NoteId, addNote)

import RemoteData exposing (WebData, map)

type alias NoteId = Maybe String

type alias Note =
    { id : NoteId
    , text : String
    }
    
type alias NoteCollection =
    WebData (List Note)
    
addNote : NoteCollection -> Note -> NoteCollection
addNote notes note =
    map (\n -> note :: n) notes