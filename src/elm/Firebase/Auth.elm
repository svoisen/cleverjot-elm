port module Firebase.Auth exposing 
    ( Msg(..)
    , authRead
    , processIncoming
    , signIn
    , signOut
    )


import Data.User exposing (Credentials, User, encodeCredentials, userDecoder)
import Json.Decode as Decode exposing (Value)
import Json.Encode as Encode exposing (encode)
import Firebase.Util exposing (getMsgType)


port authWrite : String -> Cmd msg
port authRead : (Value -> msg) -> Sub msg


type Msg
    = OnUserSignInMsg User
    | NoOpMsg


type PortMsgType
    = InvalidMsg
    | EmailPasswordSignInMsg
    | SignOutMsg
    | SignInSuccessMsg
    | ErrorMsg String


signIn : Credentials -> Cmd msg
signIn credentials =
    let message =
        ("type", toString EmailPasswordSignInMsg |> Encode.string) :: (encodeCredentials credentials)
            |> Encode.object
    in
        encode 0 message |> authWrite
        
        
signOut : Cmd msg
signOut =
    let message =
        Encode.object [
            ("type", toString SignOutMsg |> Encode.string)
        ]
    in
        encode 0 message |> authWrite
        
        
processIncoming : Value -> Msg
processIncoming value =
    let 
        messageType = msgFromString <| getMsgType value
    in
        case messageType of
            SignInSuccessMsg ->
                let decodedUser =
                    Decode.decodeValue (Decode.field "user" userDecoder) value
                in
                    case decodedUser of
                        Err _ ->
                            NoOpMsg
                            
                        Ok user ->
                            OnUserSignInMsg user
                            
            _ ->
                NoOpMsg
        
        
msgToString : PortMsgType -> String
msgToString msg =
    case msg of
        EmailPasswordSignInMsg ->
            "emailPasswordSignIn"
            
        SignOutMsg ->
            "signOut"
            
        SignInSuccessMsg ->
            "signedIn"
            
        _ ->
            ""


msgFromString : String -> PortMsgType
msgFromString str =
    case str of
        "emailPasswordSignIn" ->
            EmailPasswordSignInMsg
            
        "signedIn" ->
            SignInSuccessMsg
            
        "signOut" ->
            SignOutMsg
            
        _ ->
            InvalidMsg