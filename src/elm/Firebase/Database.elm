port module Firebase.Database exposing 
    ( Msg(..)
    , databaseRead
    , processIncoming
    , pushValue
    )


import Firebase.Util exposing (getMsgType)
import Json.Decode as Decode exposing (Value)
import Json.Encode as Encode exposing (encode)


port databaseWrite : String -> Cmd msg
port databaseRead : (Value -> msg) -> Sub msg


type Msg
    = OnValuePushedMsg String String Value
    | NoOpMsg


type PortMsgType
    = InvalidMsg
    | PushValueMsg
    | ValuePushedMsg


type alias Path = String


pushValue : Value -> Path -> Cmd msg
pushValue value path =
    writeValueMsg value path PushValueMsg
    
    
processIncoming : Value -> Msg
processIncoming value =
    let 
        messageType = msgFromString <| getMsgType value
    in
        case messageType of
            ValuePushedMsg ->
                let
                    key = value |> Decode.decodeValue (Decode.field "key" Decode.string)
                    path = value |> Decode.decodeValue (Decode.field "path" Decode.string)
                    data = value |> Decode.decodeValue (Decode.field "data" Decode.value)
                in
                    case (path, key, data) of
                        (Ok p, Ok k, Ok d) ->
                            OnValuePushedMsg p k d                
                            
                        (_, _, _) ->
                            NoOpMsg
                            
            _ ->
                NoOpMsg
        
        
writeValueMsg : Value -> Path -> PortMsgType -> Cmd msg
writeValueMsg value path portMsg =
    let message =
        Encode.object
            [ ("type", Encode.string <| msgToString portMsg)
            , ("path", Encode.string path) 
            , ("value", value)
            ]
    in
        encode 0 message |> databaseWrite
    
    
msgToString : PortMsgType -> String
msgToString msg =
    case msg of
        InvalidMsg ->
            ""
            
        PushValueMsg ->
            "pushValue"
            
        ValuePushedMsg ->
            "valuePushed"
            

msgFromString : String -> PortMsgType
msgFromString str =
    case str of
        "pushValue" ->
            PushValueMsg
            
        "valuePushed" ->
            ValuePushedMsg
            
        _ ->
            InvalidMsg