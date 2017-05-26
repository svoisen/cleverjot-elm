module Page.Home exposing (Model, view, initialModel)


import Html exposing (..)


type alias Model = {}


initialModel : Model
initialModel = {}


view : Model -> Html msg
view model =
    h1 [] [ text "Mantra" ]