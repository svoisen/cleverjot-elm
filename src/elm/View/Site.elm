module View.Site exposing (footer)


import Html exposing (..)
import Html.Attributes exposing (class)


footer : Html msg
footer =
    div [ class "footer" ] [ text "Copyright © 2017 Sean Voisen." ]