module Data.Note exposing 
    ( Note
    , select
    , deselect
    , markDirty
    , markClean
    , newNote
    , encodeNote
    , noteDecoder
    )


import Json.Encode as Encode exposing (Value, string)
import Json.Decode as Decode exposing (Decoder, nullable, string)
import Json.Decode.Pipeline as Pipeline exposing (decode, optional, required)
import Util.Encode as EncodeUtil exposing (maybeString)


type alias Note =
    { uid : Maybe String
    , title : Maybe String
    , text : String
    , selected : Bool
    , dirty : Bool
    }
    
    
newNote : String -> Note
newNote text =
    { uid = Nothing
    , title = Nothing
    , text = text
    , selected = False
    , dirty = False
    }
    
    
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
        [ ("uid", EncodeUtil.maybeString note.uid)
        , ("title", EncodeUtil.maybeString note.title)
        , ("text", Encode.string note.text)
        ]
            

noteDecoder : Decoder Note
noteDecoder =
    Pipeline.decode Note
        |> optional "uid" (Decode.nullable Decode.string) Nothing
        |> optional "title" (Decode.nullable Decode.string) Nothing
        |> required "text" Decode.string
        |> optional "selected" Decode.bool False
        |> optional "dirty" Decode.bool False