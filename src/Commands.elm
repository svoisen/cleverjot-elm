
module Commands exposing (fetchNotes)

import Http exposing (get)
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required)
import Messages exposing (Msg)
import Models exposing (Note)
import RemoteData exposing (..)

fetchNotes : Cmd Msg
fetchNotes =
    Http.get fetchNotesUrl notesDecoder
        |> RemoteData.sendRequest
        |> Cmd.map Messages.OnFetchNotes

fetchNotesUrl : String
fetchNotesUrl =
    "http://localhost:4000/notes"

notesDecoder : Decode.Decoder (List Note)
notesDecoder =
    Decode.list noteDecoder

noteDecoder : Decode.Decoder Note
noteDecoder =
    decode Note
        |> required "id" Decode.int
        |> required "text" Decode.string