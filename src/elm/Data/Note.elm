module Data.Note exposing 
    ( Note
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
    }
    
    
newNote : String -> Note
newNote text =
    { uid = Nothing
    , title = Nothing
    , text = text
    }
    
    
encodeNote : Note -> Value
encodeNote note =
    Encode.object
        [ ("uid", EncodeUtil.maybeString note.uid)
        , ("text", Encode.string note.text)
        ]
            

noteDecoder : Decoder Note
noteDecoder =
    Pipeline.decode Note
        |> optional "uid" (Decode.nullable Decode.string) Nothing
        |> optional "title" (Decode.nullable Decode.string) Nothing
        |> required "text" Decode.string