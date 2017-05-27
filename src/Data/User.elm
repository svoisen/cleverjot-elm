module Data.User exposing (Credentials, makeCredentials)


type alias Credentials = 
    { email : String
    , password : String
    }
    
    
makeCredentials : String -> String -> Credentials
makeCredentials email password =
    { email = email
    , password = password
    }