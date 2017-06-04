module View.Notes exposing (notesList)


import Html exposing (..)
import Html.Attributes exposing (..)
import Data.Note exposing (Note)


-- Given a collection of notes, display them in a list.
notesList : List Note -> Html msg
notesList notes =
    div [ class "notes-list pure-u-1-3" ] 
    [ ul [] (List.map noteView notes)
    ]
            

noteView : Note -> Html msg
noteView note =
    li [ class "notes-list-item" ] [ text note.text ]