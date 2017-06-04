module View.Notes exposing (notesList)


import Html exposing (..)
import Html.Attributes exposing (..)
import Data.Note exposing (NoteCollection, Note)
import RemoteData exposing (WebData)


-- Given a collection of notes, display them in a list.
notesList : NoteCollection -> Html msg
notesList collection =
    let contents = 
        case collection of
            RemoteData.NotAsked ->
                p [] [ text "Initializing ..." ]
                
            RemoteData.Failure err ->
                p [] [ text "Error" ]
                
            RemoteData.Loading ->
                p [] [ text "Loading" ]
                
            RemoteData.Success notes ->
                ul [] (List.map noteView notes)
                
    in
        div [ class "notes-list pure-u-1-3" ] [ contents ]
            

noteView : Note -> Html msg
noteView note =
    li [ class "notes-list-item" ] [ text note.text ]