module Data.User exposing (Credentials, User, makeCredentials, encodeCredentials)


import Json.Encode as Encode exposing (Value, object, string)


type alias Credentials = 
    { email : String
    , password : String
    }
    
    
type alias User =
    {
    }
    
    
encodeCredentials : Credentials -> Value
encodeCredentials credentials =
    object 
        [ ("email", string credentials.email)
        , ("password", string credentials.password)
        ]
    
    
makeCredentials : String -> String -> Credentials
makeCredentials email password =
    { email = email
    , password = password
    }