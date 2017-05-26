module Main exposing (..)


import Html exposing (..)
import Json.Decode exposing (Value)
import Navigation exposing (Location, programWithFlags)
-- import Ports
import Route exposing (Route, fromLocation)
import Page.Home exposing (Model, initialModel)
import Page.Login exposing (Model, initialModel)
import Page.Notes exposing (Model, initialModel)
import Messages exposing (..)
import View.Frame exposing (frame)


{- Data type used in the model to represent the current page. This is not to be
confused with the Page modules for each of these corresponding pages. -}
type Page
    = Blank
    | NotFound
    | Home Page.Home.Model
    | Login Page.Login.Model
    | Notes Page.Notes.Model
    | Logout
    

{- The main data model. Each page has its own sub-model for representing state
on that particular page. -}
type alias Model =
    { currentPage : Page
    }
    
   
setRoute : Maybe Route -> Model -> (Model, Cmd Msg)
setRoute maybeRoute model =
    case maybeRoute of
        Nothing ->
            (model, Cmd.none)
            
        Just Route.Login ->
            ({ model | currentPage = Login Page.Login.initialModel }, Cmd.none)
        
        Just Route.Logout ->
            (model, Cmd.none)
            
        Just Route.Home ->
            ({ model | currentPage = Home Page.Home.initialModel }, Cmd.none)
            
        Just Route.Notes ->
            ({ model | currentPage = Notes Page.Notes.initialModel }, Cmd.none) 
        
    
updatePage : Page -> Msg -> Model -> (Model, Cmd Msg)
updatePage page msg model =
    case (msg, page) of
        (SetRoute route, _) ->
            setRoute route model
            
        (_, _) ->
            (model, Cmd.none)


        
initialPage : Page
initialPage = 
    Blank
    
    
viewPage : Page -> Html Msg
viewPage page =
    case page of
        NotFound ->
            Html.text ""
            
        Blank ->
            Html.text ""
            
        Home pageModel ->
            Page.Home.view pageModel |> frame
            
        Notes pageModel ->
            Page.Notes.view pageModel |> frame
            
        Login pageModel ->
            Page.Login.view pageModel |> frame
            
        Logout ->
            Html.text ""
    

view : Model -> Html Msg
view model =
    viewPage model.currentPage


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    updatePage model.currentPage msg model
            
            
init : Value -> Location -> (Model, Cmd Msg)
init val location =
    setRoute (fromLocation location)
        { currentPage = initialPage 
        }

 
main : Program Value Model Msg
main = 
    Navigation.programWithFlags (Route.fromLocation >> SetRoute)
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }