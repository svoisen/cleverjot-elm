module View.Notes exposing 
    ( notesView
    , noteEditor
    )


import Data.Note exposing (Note)
-- import Debug exposing (log)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import List.Extra exposing (last)
import String exposing (toLower)
import String.Extra exposing (softEllipsis)
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
    let
        maxLength = 128
        truncatedText = softEllipsis maxLength note.text
        
    in
        case maybeQuery of
            Nothing ->
                div [ ] [ text truncatedText ]
                
            Just query ->
                let
                    indices = String.indices (toLower query) (toLower note.text) 
                    truncatedIndices = List.filter (\idx -> idx < maxLength) indices
                    highlightEllipsis = List.length truncatedIndices < List.length indices
                    highlighted = highlightText truncatedText (List.reverse truncatedIndices) (String.length query) [ ] highlightEllipsis
                    
                in
                    div [ ] highlighted
                    
                    
{-| Given some text, the length of a substring to highlight in the text, and all
of the indices in which the substring appears (in reverse order), return a list
of <span> highlighting the substrings in the text. The substring indices should
be reversed because this function works on the original string in reverse. -}
highlightText : String -> List Int -> Int -> List (Html msg) -> Bool -> List (Html msg)
highlightText text indices highlightLen elements highlightEllipsis =
    if highlightEllipsis then
        highlightText (String.dropRight 3 text) indices highlightLen [ span [ class "highlight" ] [ Html.text "..." ] ] False
        
    else 
        if List.isEmpty indices then
            (Html.text text) :: elements
            
        else
            let
                textLen = String.length text
                startIdx = List.head indices ? 0
                endIdx = startIdx + highlightLen
                unhighlightedEl = String.right (textLen - endIdx) text |> Html.text
                highlightedEl = [ String.slice startIdx endIdx text |> Html.text ] |> span [ class "highlight" ]
                newElements = highlightedEl :: unhighlightedEl :: elements
                newText = String.dropRight (textLen - startIdx) text
                
            in
                highlightText newText (List.tail indices ? [ ]) highlightLen newElements highlightEllipsis
            
    
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