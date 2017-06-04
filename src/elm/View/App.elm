module View.App exposing (header)


import Data.User exposing (User)
import Html exposing (..)
import Html.Attributes exposing (..)

        
header : Maybe User -> Maybe String -> List (Attribute msg) -> Html msg
header maybeUser maybeQuery searchInputAttributes =
    div [ class "header" ] 
    [ hamburgerMenu
    , searchInput maybeQuery searchInputAttributes
    ]
    
    
hamburgerMenu : Html msg
hamburgerMenu = 
    button [ class "hamburger" ] 
    [ span [ class "fa fa-bars" ] []
    ]
    
    
searchInput : Maybe String -> List (Attribute msg) -> Html msg
searchInput maybeQuery inputAttributes =
    div [ class "search" ]
    [ span [ class "loupe fa fa-search" ] [ ]
    , input ([ class "search-input", placeholder "Search or create note ...", Maybe.withDefault "" maybeQuery |> value ] ++ inputAttributes) [ ]
    ]
