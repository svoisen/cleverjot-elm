port module Firebase.Database exposing 
    ( Msg(..)
    , Path
    , databaseRead
    , processIncoming
    , pushData
    , setData
    , listenChildAdded
    )


import Debug exposing (log)
import Firebase.Util exposing (getMsgType)
import Json.Decode as Decode exposing (Value)
import Json.Encode as Encode exposing (encode)


port databaseWrite : String -> Cmd msg
port databaseRead : (Value -> msg) -> Sub msg


type Msg
    = OnDataPushedMsg String String Value
    | OnChildAddedMsg String String Value
    | NoOpMsg


type PortMsgType
    = InvalidMsg
    | PushDataMsg
    | DataPushedMsg
    | SetDataMsg
    | DataSetMsg
    | ListenChildAddedMsg
    | ChildAddedMsg


type alias Path = String


pushData : Value -> Path -> Cmd msg
pushData data path =
    writeDataMsg data path PushDataMsg
    
    
setData : Value -> Path -> Cmd msg
setData data path =
    writeDataMsg data path SetDataMsg
    
    
listenChildAdded : Path -> Cmd msg
listenChildAdded path =
    writeMsg path ListenChildAddedMsg 
    
    
processIncoming : Value -> Msg
processIncoming value =
    let 
        messageType = getMsgType value |> msgFromString
        key = value |> Decode.decodeValue (Decode.field "key" Decode.string)
        path = value |> Decode.decodeValue (Decode.field "path" Decode.string)
        data = value |> Decode.decodeValue (Decode.field "data" Decode.value)
    in
        case (path, key, data) of
            (Ok p, Ok k, Ok d) ->
                case messageType of
                    DataPushedMsg ->
                        OnDataPushedMsg p k d                
                        
                    ChildAddedMsg ->
                        OnChildAddedMsg p k d
                        
                    _ ->
                        NoOpMsg
                
            (_, _, _) ->
                NoOpMsg
        
        
writeDataMsg : Value -> Path -> PortMsgType -> Cmd msg
writeDataMsg data path portMsg =
    let message =
        Encode.object
            [ ("type", Encode.string <| msgToString portMsg)
            , ("path", Encode.string path) 
            , ("data", data)
            ]
    in
        encode 0 message |> databaseWrite
        
        
writeMsg : Path -> PortMsgType -> Cmd msg
writeMsg path portMsg =
    let message =
        Encode.object
            [ ("type", Encode.string <| msgToString portMsg)
            , ("path", Encode.string path)
            ]
    in
        encode 0 message |> databaseWrite
    
    
msgToString : PortMsgType -> String
msgToString msg =
    case msg of
        InvalidMsg ->
            ""
            
        PushDataMsg ->
            "pushData"
            
        DataPushedMsg ->
            "dataPushed"
            
        SetDataMsg ->
            "setData"
            
        DataSetMsg ->
            "dataSet"
            
        ListenChildAddedMsg ->
            "listenChildAdded"
            
        ChildAddedMsg ->
            "childAdded"
            

msgFromString : String -> PortMsgType
msgFromString str =
    case str of
        "pushData" ->
            PushDataMsg
            
        "dataPushed" ->
            DataPushedMsg
            
        "setData" ->
            SetDataMsg
            
        "dataSet" ->
            DataSetMsg
            
        "listenChildAdded" ->
            ListenChildAddedMsg
            
        "childAdded" ->
            ChildAddedMsg
            
        _ ->
            InvalidMsg