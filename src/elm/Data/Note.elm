module Data.Note exposing 
    ( NoteCollection
    , Note
    , NoteId
    , addNote
    , newNote
    , encodeNote
    )


import Json.Encode as Encode exposing (Value, string)
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
            
            
encodeNote : Note -> Value
encodeNote note =
    let encodedUid =
        case note.id of
            Nothing ->
                Encode.null
                
            Just id ->
                Encode.string id
    in
        Encode.object
            [ ("uid", encodedUid)
            , ("text", Encode.string note.text)
            ]