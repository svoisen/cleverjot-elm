module Route exposing (Route(..), fromLocation, modifyUrl)


import Navigation exposing (Location)
import UrlParser as Url exposing (Parser, parseHash, oneOf, (</>), s, map)


{- Routes for the entire application. -}
type Route
    = HomeRoute
    | LoginRoute
    | LogoutRoute
    | NotesRoute
    
    
{-| Convert string routes to the Route type for easier internal handling. -}
route : Parser (Route -> a) a
route =
    Url.oneOf
        [ Url.map HomeRoute (s "")
        , Url.map LoginRoute (s "login")
        , Url.map LogoutRoute (s "logout")
        , Url.map NotesRoute (s "notes")
        ]
        
        
routeToString : Route -> String
routeToString route =
    let components =
        case route of
            HomeRoute ->
                []
            
            LoginRoute ->
                [ "login" ]
            
            LogoutRoute ->
                [ "logout" ]
            
            NotesRoute ->
                [ "notes" ] 
                
    in
        "#/" ++ (String.join "/" components)
        
        
modifyUrl : Route -> Cmd msg
modifyUrl =
    routeToString >> Navigation.modifyUrl
    
    
{-| Given a location, convert it to a route. -}
fromLocation : Location -> Maybe Route
fromLocation location =
    if String.isEmpty location.hash then
        -- TODO: This should be HomeRoute when ready to server home page
        Just LoginRoute
    else
        parseHash route location