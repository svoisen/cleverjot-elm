module Util.Html exposing (onEnter)


import Html exposing (Attribute)
import Html.Events exposing (on, keyCode, targetValue)
import Json.Decode as Decode


{-| An enter key event handler for input fields, where the value of the value 
of the field is provided as part of the message. This allows one to listen for
enter key presses on an input field and get the value of the field only at the
time of the key press.
-}
onEnter : (String -> msg) -> Attribute msg
onEnter tagger =
    let
        isEnter code = 
            if code == 13 then
                Decode.succeed ""
            else
                Decode.fail ""
                
        decodeEnter =
            Decode.andThen isEnter keyCode
    in
        on "keydown" <| Decode.map2 (\key value -> tagger value) decodeEnter targetValue