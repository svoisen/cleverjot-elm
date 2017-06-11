module View.App exposing (header)


import Data.User exposing (User)
import Html exposing (..)
import Html.Attributes exposing (..)
import Util.Helpers exposing ((?))
import Util.Html exposing (onEnter)

        
header : Maybe User -> Maybe String -> msg -> (String -> msg) -> Html msg
header maybeUser maybeQuery menuClick searchEnter =
    section [ class "header" ] 
    [ menuButton menuClick
    , searchInput maybeQuery searchEnter
    ]
    
    
menuButton : msg -> Html msg
menuButton menuClick = 
    button [ class "hamburger" onClick menuClick ] 
    [ span [ class "fa fa-bars" ] [ ]
    ]
    
    
searchInput : Maybe String -> (String -> msg) -> Html msg
searchInput maybeQuery searchEnter =
    div [ class "search" ]
    [ span [ class "loupe fa fa-search" ] [ ]
    , input [ class "search-input", placeholder "Search or create note ...", value (maybeQuery ? ""), onEnter searchEnter ] [ ]
    ]
