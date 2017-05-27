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
    div [ class "header pure-g" ] 
    [ div [ class "pure-u-1-1" ] 
        [ h1 [] [ text "Mantra" ]
        ]
    ]
    

footer : Html msg
footer =
    div [ class "footer pure-g" ] []