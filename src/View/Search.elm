module View.Search exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events.Extra exposing (onEnter)
import Html.Events exposing (onInput)
import Model.Model exposing (Model, Msg(..))

view : Maybe String -> Html Msg
view query =
    div [ class "search-view" ]
        [ input [ placeholder "Search", onEnter OnSearchEnterPressed, onInput OnQueryChanged ] [ text (Maybe.withDefault "" query) ]
        ]