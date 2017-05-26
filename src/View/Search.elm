module View.Search exposing (view)


import Html exposing (..)
import Html.Attributes exposing (placeholder)


view : Maybe String -> List (Html Msg) -> Html Msg
view query attrs =
    div [ class "search-view" ]
        [ input ([ placeholder "Search" ] ++ attrs) [ text (Maybe.withDefault "" query) ]
        ]