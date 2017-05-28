module Main exposing (..)


import Html exposing (..)
import Json.Decode exposing (Value)
import Navigation exposing (Location, programWithFlags)
import Firebase
import Route exposing (..)
import Page.Home as Home 
import Page.Login as Login
import Page.Notes as Notes
import View.Frame exposing (frame)


{- Data type used in the model to represent the current page. This is not to be
confused with the Page modules for each of these corresponding pages. -}
type Page
    = BlankPage
    | NotFoundPage
    | HomePage Home.Model
    | LoginPage Login.Model
    | NotesPage Notes.Model
    | LogoutPage
    
    
type Msg
    = SetRouteMsg (Maybe Route)
    | LoginMsg Login.Msg
    

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
            
        Just LoginRoute ->
            ({ model | currentPage = LoginPage Login.initialModel }, Cmd.none)
        
        Just LogoutRoute ->
            (model, Cmd.none)
            
        Just HomeRoute ->
            ({ model | currentPage = HomePage Home.initialModel }, Cmd.none)
            
        Just NotesRoute ->
            ({ model | currentPage = NotesPage Notes.initialModel }, Cmd.none) 
        
    
updatePage : Page -> Msg -> Model -> (Model, Cmd Msg)
updatePage page msg model =
    case (msg, page) of
        (SetRouteMsg route, _) ->
            setRoute route model
            
        (LoginMsg pageMsg, LoginPage pageModel) ->
            let 
                ((newPageModel, _), msgFromPage) = Login.update pageMsg pageModel
                
            in
                case msgFromPage of
                    Login.NoOpMsg ->
                        ({ model | currentPage = LoginPage newPageModel }, Cmd.none)
                        
                    Login.LoginUserMsg credentials ->
                        ({ model | currentPage = LoginPage newPageModel }, Firebase.login credentials)
            
        (_, _) ->
            (model, Cmd.none)


initialPage : Page
initialPage = 
    BlankPage
    
    
viewPage : Page -> Html Msg
viewPage page =
    case page of
        NotFoundPage ->
            Html.text ""
            
        BlankPage ->
            Html.text ""
            
        HomePage homeModel ->
            Home.view homeModel 
                |> frame
            
        NotesPage notesModel ->
            Notes.view notesModel 
                |> frame
            
        LoginPage loginModel ->
            Login.view loginModel 
                |> frame
                |> Html.map LoginMsg
            
        LogoutPage ->
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
    Navigation.programWithFlags (Route.fromLocation >> SetRouteMsg)
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }