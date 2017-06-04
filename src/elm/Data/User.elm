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
    , uid : String
    , displayName : Maybe String
    }
    
    
userDecoder : Decoder User
userDecoder =
    Pipeline.decode User
        |> required "email" Decode.string
        |> required "uid" Decode.string
        |> optional "displayName" (Decode.nullable Decode.string) Nothing
    
    
encodeCredentials : Credentials -> List (String, Value)
encodeCredentials credentials =
    [ ("email", Encode.string credentials.email)
    , ("password", Encode.string credentials.password)
    ]
    
    
encodeUser : User -> Value
encodeUser user =
    Encode.object
        [ ("email", Encode.string user.email)
        , ("uid", Encode.string user.uid)
        ]
    
    
makeCredentials : String -> String -> Credentials
makeCredentials email password =
    { email = email
    , password = password
    }