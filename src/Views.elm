module Views exposing (..)

import Json.Decode as Json
import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import HtmlExtensions exposing (..)
import Models exposing (..)
import Messages exposing (..)
import RemoteData exposing (WebData)

-- Display the root application view.
view : AppModel -> Html Msg
view model =
    div []
        [ h1 [] [ text "Mantra" ] 
        , searchView model.query
        , maybeListNotes model.notes
        ]

-- Display the search view.
searchView : Maybe String -> Html Msg
searchView query =
    div [ class "search-view" ]
        [ input [ placeholder "Search", onEnterPressed OnSearchEnter ] [ text (Maybe.withDefault "" query) ]
        ]
        
-- Helper for key down handling
onKeyDown : (Int -> msg) -> Attribute msg
onKeyDown tagger =
    on "keydown" (Json.map tagger keyCode)

-- List notes received from the server, if there are any to be listed.
-- If not, then show an appropriate message.
maybeListNotes : NoteList -> Html Msg
maybeListNotes notes =
    case Tuple.first notes of
        Success ->
            listNotes (Tuple.second notes)
            
        Pending ->
            text "Loading"

        Failure ->
            text "Error"

-- Given a list of notes, display them in a list.
listNotes : Maybe (List Note) -> Html Msg
listNotes maybeNotes =
    if maybeNotes == Nothing then
        p [] [ text "No notes" ]
    else
        let notes = 
            Maybe.withDefault [] maybeNotes
        in
            ul [ class "notes-list" ] (List.map noteView notes)

noteView : Note -> Html Msg
noteView note =
    div [ class "note" ] [ text note.text ]