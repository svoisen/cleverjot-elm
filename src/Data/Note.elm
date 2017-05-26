module Data.Note exposing (NoteCollection, Note, NoteId, addNote, newNote)


import RemoteData exposing (WebData)


type alias NoteId = Maybe String


type alias Note =
    { id : NoteId
    , text : String
    }
    
    
type alias NoteCollection 
    = WebData (List Note)
    
    
newNote : String -> Note
newNote text =
    { id = Nothing
    , text = text
    }
    
    
addNote : NoteCollection -> Note -> NoteCollection
addNote notes note =
    case notes of
        RemoteData.Success a ->
            RemoteData.map (\n -> note :: n) notes
        
        _ ->
            RemoteData.Success [note]