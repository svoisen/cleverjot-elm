module Data.Note exposing 
    ( Note
    , select
    , deselect
    , invalidNoteId
    , markDirty
    , markClean
    , newNote
    , emptyNote
    , encodeNote
    , noteDecoder
    )


import Json.Encode as Encode exposing (Value, string)
import Json.Decode as Decode exposing (Decoder, nullable, string)
import Json.Decode.Pipeline as Pipeline exposing (decode, optional, required)
import Util.Encode as EncodeUtil exposing (maybeString)


type alias Note =
    { uid : String
    , title : Maybe String
    , text : String
    , selected : Bool
    , dirty : Bool
    }
    
    
invalidNoteId : String
invalidNoteId = ""
    
    
newNote : String -> Note
newNote text =
    { uid = ""
    , title = Nothing
    , text = text
    , selected = False
    , dirty = False
    }
    
    
emptyNote : Note
emptyNote =
    newNote ""
    
    
select : Note -> Note
select note =
    { note | selected = True }
    
    
deselect : Note -> Note
deselect note =
    { note | selected = False }
    
    
markDirty : Note -> Note
markDirty note =
    { note | dirty = True }
    
    
markClean : Note -> Note
markClean note =
    { note | dirty = False }
    
    
encodeNote : Note -> Value
encodeNote note =
    Encode.object
        [ ("uid", if note.uid == invalidNoteId then Encode.null else Encode.string note.uid)
        , ("title", EncodeUtil.maybeString note.title)
        , ("text", Encode.string note.text)
        ]
            

noteDecoder : String -> Decoder Note
noteDecoder uid =
    Pipeline.decode Note
        |> optional "uid" Decode.string uid
        |> optional "title" (Decode.nullable Decode.string) Nothing
        |> required "text" Decode.string
        |> optional "selected" Decode.bool False
        |> optional "dirty" Decode.bool False