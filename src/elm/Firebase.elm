port module Firebase exposing (Msg(..), process, login, addNote, firebaseIncoming)


import Data.User as User exposing (Credentials, User, encodeCredentials, encodeUser, userDecoder)
import Data.Note as Note exposing (Note, encodeNote)
import Json.Encode as Encode exposing (encode, string, object)
import Json.Decode as Decode exposing (Value)
import Json.Decode.Pipeline as Pipeline


type Msg
    = NoOpMsg
    | OnUserLoginMsg User
    
    
type PortMsgType
    = UserLoginRequest
    | UserDidLogin
    | AddNote
    | NoMsg


port firebaseOutgoing : String -> Cmd msg
port firebaseIncoming : (Value -> msg) -> Sub msg


process : Value -> Msg
process value =
    let 
        decoder = (Decode.field "type" Decode.string)
        messageType = Decode.decodeValue decoder value
    in
        case messageType of
            Err _ ->
                NoOpMsg
                
            Ok "userDidLogin" ->
                let decodedUser =
                    Decode.decodeValue userDecoder value
                in
                    case decodedUser of
                        Err _ ->
                            NoOpMsg
                            
                        Ok user ->
                            OnUserLoginMsg user
                
            Ok _ ->
                NoOpMsg


login : Credentials -> Cmd msg
login credentials =
    let message =
        ("type", Encode.string (toString UserLoginRequest)) :: (encodeCredentials credentials)
            |> Encode.object
    in
        encode 0 message |> firebaseOutgoing
        
        
addNote : Note -> User -> Cmd msg
addNote note user =
    let message =
        Encode.object
            [ ("type", Encode.string (toString AddNote))
            , ("note", encodeNote note) 
            , ("user", encodeUser user)
            ]
    in
        encode 0 message |> firebaseOutgoing
        
        
toString : PortMsgType -> String
toString msg =
    case msg of
        UserLoginRequest ->
            "userLogin"
            
        UserDidLogin ->
            "userDidLogin"
            
        AddNote ->
            "addNote"
            
        NoMsg ->
            ""
            
            
fromString : String -> PortMsgType
fromString str =
    case str of
        "userLogin" ->
            UserLoginRequest
            
        "userDidLogin" ->
            UserDidLogin
            
        "addNote" ->
            AddNote
            
        _ ->
            NoMsg