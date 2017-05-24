module Helper.Html exposing (onEnter)

import Html exposing (..)
import Html.Attributes exposing (..)
import Json.Decode as Json

onEnter : msg -> Attribute msg
onEnter msg =
    let
        isEnter codeValuePair =
            if Tuple.first codeValuePair == 13 then Ok Tuple.second codeValuePair else Err ""
        decodeEnterKeyCode = 
            Json.customDecoder (keyCode, targetValue) isEnter
    in
        on "keydown" <| Json.map (\_ -> msg) decodeEnterKeyCode