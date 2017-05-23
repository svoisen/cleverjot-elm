module Views exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Models exposing (AppModel, Note)
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
searchView : String -> Html Msg
searchView query =
    div [ class "search-view" ]
        [ input [ placeholder "Search", onInput OnSearchKeyDown ] [ text query ]
        ]

-- List notes received from the server, if there are any to be listed.
-- If not, then show an appropriate message.
maybeListNotes : WebData (List Note) -> Html Msg
maybeListNotes response =
    case response of
        RemoteData.NotAsked ->
            text ""

        RemoteData.Loading ->
            text "Loading"

        RemoteData.Success notes ->
            listNotes notes

        RemoteData.Failure error ->
            text (toString error)

-- Given a list of notes, display them in a list.
listNotes : List Note -> Html Msg
listNotes notes =
    ul [ class "notes-list" ] (List.map noteView notes)

noteView : Note -> Html Msg
noteView note =
    div [ class "note" ] [ text note.text ]