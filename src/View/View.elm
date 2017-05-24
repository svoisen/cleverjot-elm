module View.View exposing (view)

import Html exposing (..)
import Model.Model exposing (Model, Msg(..))
import View.Search as Search exposing (view)

view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Mantra" ]
        , Search.view model.query
        ]