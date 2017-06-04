module View.Notes exposing 
    ( notesView
    , noteEditor
    )


import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Data.Note exposing (Note)
import Util.Helpers exposing ((?))


{-| Given a list of notes, display them in a list. -}
notesView : List Note -> (Note -> msg) -> Html msg
notesView notes noteClick =
    div [ class "notes-view" ] 
    [ ul [ class "notes-list" ] (List.map (\note -> noteView note noteClick) notes)
    ]
            

noteView : Note -> (Note -> msg) -> Html msg
noteView note noteClick =
    li [ class "notes-list-item", onClick (noteClick note) ] [ text note.text ]
    
    
noteEditor : Maybe Note -> Html msg
noteEditor maybeNote =
    case maybeNote of
        Nothing ->
            Html.text ""
            
        Just note ->
            textarea [ class "note-editor" ] [ text note.text ]