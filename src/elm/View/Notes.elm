module View.Notes exposing 
    ( notesView
    , noteEditor
    )


import Debug exposing (log)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Data.Note exposing (Note)
import Util.Helpers exposing ((?))


{-| Given a list of notes, display them in a list. -}
notesView : List Note -> Maybe String -> (Note -> msg) -> Html msg
notesView notes query onNoteClickFn =
    div [ class "notes-view" ] 
    [ ul [ class "notes-list" ] (List.map (\note -> notesListItem note query onNoteClickFn) notes)
    ]
            

notesListItem : Note -> Maybe String -> (Note -> msg) -> Html msg
notesListItem note query onClickFn =
    li 
        [ classList 
            [ ("notes-list-item", True)
            , ("selected", note.selected)
            ]
        , onClick (onClickFn note) 
        ] 
        [ notePreview note query
        ]
        
        
notePreview : Note -> Maybe String -> Html msg
notePreview note maybeQuery =
    case maybeQuery of
        Nothing ->
            div [ ] [ text note.text ]
            
        Just query ->
            let
                indices = String.indices (String.toLower query) (String.toLower note.text) 
                highlighted = highlightText note.text indices (String.length query) [ ]
                
            in
                log (toString indices) (div [ ] highlighted)
                    
                    
highlightText : String -> List Int -> Int -> List (Html msg) -> List (Html msg)
highlightText text indices length elements =
    if List.isEmpty indices then
        if String.isEmpty text then
            elements
        else
            elements ++ [ span [ ] [ Html.text text ] ]
    else
        let
            startIdx = List.head indices ? 0
            endIdx = startIdx + length
            preEl = span [ ] [ Html.text <| String.left startIdx text ]
            highlightedEl = span [ class "highlight" ] [ Html.text <| String.slice startIdx endIdx text ]
            appendElements = if startIdx == 0 then [ highlightedEl ] else [ preEl, highlightedEl ]
            nextIndices = List.tail indices ? [ ] |> List.map (\i -> i - endIdx)
        in
            highlightText (String.dropLeft endIdx text) nextIndices length (elements ++ appendElements)
            
    
noteEditor : Maybe Note -> (Note -> msg) -> Html msg
noteEditor maybeNote onInputFn =
    let contents =
        case maybeNote of
            Nothing ->
                [ text "" ]
                
            Just note ->
                [ textarea [ class "note-editor", onInput (\str -> onInputFn { note | text = str }), value note.text ] [ ]
                ]
                
    in
        div [ class "note-view" ] contents