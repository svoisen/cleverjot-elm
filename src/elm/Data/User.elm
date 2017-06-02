module Data.User exposing (..)


import Json.Encode as Encode exposing (Value)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipeline exposing (decode, required, optional)


type alias Credentials = 
    { email : String
    , password : String
    }
    
    
type alias User =
    { email : String
    , displayName : Maybe String
    }
    
    
userDecoder : Decoder User
userDecoder =
    decode User
        |> required "email" Decode.string
        |> optional "displayName" (Decode.nullable Decode.string) Nothing
    
    
encodeCredentials : Credentials -> Value
encodeCredentials credentials =
    Encode.object 
        [ ("email", Encode.string credentials.email)
        , ("password", Encode.string credentials.password)
        ]
    
    
makeCredentials : String -> String -> Credentials
makeCredentials email password =
    { email = email
    , password = password
    }