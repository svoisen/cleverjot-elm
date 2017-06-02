module Command.Note exposing (fetchNotes)

import Json.Decode as Decode exposing (..)
import Json.Decode.Pipeline exposing (decode, required)
import Http exposing (get)
import Messages exposing (Msg(..))
import RemoteData exposing (WebData, map, sendRequest)


fetchNotes : Cmd Msg
fetchNotes =
    Http.get fetchNotesUrl notesDecoder
        |> RemoteData.sendRequest
        |> Cmd.map OnFetchNotes
        
        
fetchNotesUrl : String
fetchNotesUrl =
    "http://localhost:4000/notes"
    

notesDecoder : Decoder (List Note)
notesDecoder =
    list noteDecoder
    

noteDecoder : Decoder Note
noteDecoder =
    decode Note
        |> required "id" (nullable string)
        |> required "text" string