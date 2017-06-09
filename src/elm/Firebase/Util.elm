module Firebase.Util exposing (getMsgType)


import Json.Decode as Decode exposing (Value)


getMsgType : Value -> String
getMsgType value =
    Decode.decodeValue (Decode.field "type" Decode.string) value
        |> Result.withDefault ""
