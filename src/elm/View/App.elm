module View.App exposing (header)


import Data.User exposing (User)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Util.Helpers exposing ((?))
import Util.Html exposing (onEnter)

        
header : Maybe User -> Maybe String -> msg -> (String -> msg) -> (String -> msg) -> Html msg
header maybeUser maybeQuery menuClick searchEnter searchInput =
    section [ class "header" ] 
    [ menuButton menuClick
    , searchInputView maybeQuery searchEnter searchInput
    ]
    
    
menuButton : msg -> Html msg
menuButton menuClick = 
    button [ class "hamburger", onClick menuClick ] 
    [ span [ class "fa fa-bars" ] [ ]
    ]
    
    
searchInputView : Maybe String -> (String -> msg) -> (String -> msg) -> Html msg
searchInputView maybeQuery searchEnter searchInput =
    div [ class "search" ]
    [ span [ class "loupe fa fa-search" ] [ ]
    , input [ class "search-input", placeholder "Search or create new note ...", value (maybeQuery ? ""), onEnter searchEnter, onInput searchInput ] [ ]
    ]
