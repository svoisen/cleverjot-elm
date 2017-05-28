port module Firebase exposing (login)


import Data.User exposing (Credentials, encodeCredentials)
import Json.Encode as Encode exposing (encode, string, object)


port firebaseOutgoing : String -> Cmd msg
port firebaseIncoming : (List String -> msg) -> Sub msg


login : Credentials -> Cmd msg
login credentials =
    let message =
        object
            [ ("type", string "login")
            , ("payload", encodeCredentials credentials)
            ]
    in
        encode 0 message |> firebaseOutgoing