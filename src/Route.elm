module Route exposing (Route(..), fromLocation)


import Navigation exposing (Location)
import UrlParser as Url exposing (Parser, parseHash, oneOf, (</>), s, map)


type Route
    = Home
    | Login
    | Logout
    | Notes
    
    
{-| Convert string routes to the Route type for easier internal handling. -}
route : Parser (Route -> a) a
route =
    Url.oneOf
        [ Url.map Home (s "")
        , Url.map Login (s "login")
        , Url.map Logout (s "logout")
        , Url.map Notes (s "notes")
        ]
    
    
{-| Given a location, convert it to a route. -}
fromLocation : Location -> Maybe Route
fromLocation location =
    if String.isEmpty location.hash then
        Just Home
    else
        parseHash route location