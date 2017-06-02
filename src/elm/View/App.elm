module View.App exposing (header)


import Data.User exposing (User)
import Html exposing (..)
import Html.Attributes exposing (..)

        
header : Maybe User -> Maybe String -> List (Attribute msg) -> Html msg
header maybeUser maybeQuery searchInputAttributes =
    div [ class "header" ] 
    [ button [ class "hamburger" ] 
        [ span [ class "fa fa-bars" ] []
        ]
    , searchInput maybeQuery searchInputAttributes
    ]
    
    
searchInput : Maybe String -> List (Attribute msg) -> Html msg
searchInput maybeQuery inputAttributes =
    div [ class "search" ]
    [ span [ class "fa fa-search" ] [ ]
    , input ([ class "search-input", placeholder "Search or create note ..."] ++ inputAttributes) [ Maybe.withDefault "" maybeQuery |> text ]
    ]
        