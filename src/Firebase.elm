port module Firebase exposing (Msg(..), process, login, firebaseIncoming)


import Data.User exposing (Credentials, User, encodeCredentials)
import Json.Encode as Encode exposing (encode, string, object)
import Json.Decode as Decode exposing (Value)
import Json.Decode.Pipeline as Pipeline


type Msg
    = NoOpMsg
    | OnUserLoginMsg User


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
                
            Ok "userLogin" ->
                OnUserLoginMsg {}
                
            Ok _ ->
                NoOpMsg


login : Credentials -> Cmd msg
login credentials =
    let message =
        object
            [ ("type", string "login")
            , ("payload", encodeCredentials credentials)
            ]
    in
        encode 0 message |> firebaseOutgoing