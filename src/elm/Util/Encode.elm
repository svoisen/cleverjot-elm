module Util.Encode exposing (maybeString)


import Json.Encode as Encode exposing (Value)


maybeString : Maybe String -> Value
maybeString maybeString =
    case maybeString of
        Nothing ->
            Encode.null
            
        Just str ->
            Encode.string str