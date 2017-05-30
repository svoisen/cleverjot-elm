module View.Frame exposing (frame)


import Data.User exposing (User)
import Html exposing (..)
import Html.Attributes exposing (..)


{-| Wrap a page's HTML in the standard header and footer. -}
frame : Html msg -> Maybe User -> Html msg
frame content maybeUser =
    div [ class "frame" ]
        [ header maybeUser 
        , content
        , footer
        ]
        
        
header : Maybe User -> Html msg
header maybeUser =
    let headerContent =
        case maybeUser of
            Nothing ->
                normalHeader
                
            Just user ->
                appHeader user
                
    in
        div [ class "header pure-g" ] headerContent
    
    
normalHeader : List (Html msg)
normalHeader =
    [ div [ class "pure-u-1-1" ] 
        [ h1 [ class "app-title" ] [ text "Mantra" ]
        ]
    ]
        
        
appHeader : User -> List (Html msg)
appHeader user =
    [ div [ class "search pure-u-3-4" ] 
        [ div [ class "home-logo" ] 
            [ span [ class "fa fa-bars" ] []
        ]
        , span [ class "search-icon fa fa-search" ] [ ]
        , input [ placeholder "Search or create new note ..." ] [ ]
        ]
    , div [ class "user pure-u-1-4" ] [ text user.email ]
    ]
    

footer : Html msg
footer =
    div [ class "footer pure-g" ] [
        div [ class "pure-u-1-1" ] [ text "Copyright © 2017 Sean Voisen." ]
    ]