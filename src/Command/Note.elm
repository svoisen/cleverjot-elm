module Command.Note exposing (fetch)

import Http exposing (get)
import Json.Decode exposing (Decoder, list, nullable, int, string)
import Json.Decode.Pipeline exposing (decode, required)
import Model.Model exposing (Msg(..))
import Model.Note exposing (Note, NoteId)
import RemoteData exposing (sendRequest)

fetch : Cmd Msg
fetch =
    get fetchNotesUrl notesDecoder
        |> sendRequest
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