module View.Frame exposing (frame)


import Html exposing (..)
import Html.Attributes exposing (class)


{-| Wrap a page's HTML in the standard header and footer. -}
frame : Html msg -> Html msg
frame content =
    div [ class "frame" ]
        [ header 
        , content
        , footer
        ]
        
        
header : Html msg
header =
    div [ class "header" ] []
    

footer : Html msg
footer =
    div [ class "footer" ] []