module View.Notes exposing 
    ( notesView
    , noteEditor
    )


import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Data.Note exposing (Note)


{-| Given a list of notes, display them in a list. -}
notesView : List Note -> (Note -> msg) -> Html msg
notesView notes onNoteClickFn =
    div [ class "notes-view" ] 
    [ ul [ class "notes-list" ] (List.map (\note -> notesListItem note onNoteClickFn) notes)
    ]
            

notesListItem : Note -> (Note -> msg) -> Html msg
notesListItem note onClickFn =
    li 
        [ classList 
            [ ("notes-list-item", True)
            , ("selected", note.selected)
            ]
        , onClick (onClickFn note) 
        ] 
        [ p [ ] [ text note.text ]
        ]
    
    
noteEditor : Maybe Note -> (Note -> msg) -> Html msg
noteEditor maybeNote onInputFn =
    let contents =
        case maybeNote of
            Nothing ->
                [ Html.text "" ]
                
            Just note ->
                [ textarea [ class "note-editor", onInput (\str -> onInputFn { note | text = str }) ] [ text note.text ]
                ]
    in
        div [ class "note-view" ] contents