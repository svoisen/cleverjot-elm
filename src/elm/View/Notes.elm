module View.Notes exposing (view)


import Html exposing (..)
import Html.Attributes exposing (..)
import Data.Note exposing (NoteCollection, Note)
import RemoteData exposing (WebData)


-- Given a collection of notes, display them in a list.
view : NoteCollection -> Html msg
view collection =
    case collection of
        RemoteData.NotAsked ->
            p [] [ text "Initializing ..." ]
            
        RemoteData.Failure err ->
            p [] [ text "Error" ]
            
        RemoteData.Loading ->
            p [] [ text "Loading" ]
            
        RemoteData.Success notes ->
            ul [ class "notes-list" ] (List.map noteView notes)
            

noteView : Note -> Html msg
noteView note =
    div [ class "note" ] [ text note.text ]