module Main exposing (..)


import Data.User exposing (User)
import Html exposing (..)
import Json.Decode exposing (Value)
import Navigation exposing (Location, programWithFlags)
import Firebase
import Route exposing (..)
import Page.Home as Home 
import Page.Login as Login
import Page.Notes as Notes
import Util.Helpers exposing ((=>))


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
    | NotesMsg Notes.Msg
    | FirebaseMsg Firebase.Msg
    

{- The main data model. Each page has its own sub-model for representing state
on that particular page. -}
type alias Model =
    { currentPage : Page
    , currentUser : Maybe User
    }
    
   
setRoute : Maybe Route -> Model -> (Model, Cmd Msg)
setRoute maybeRoute model =
    case maybeRoute of
        Nothing ->
            (model, Cmd.none)
            
        Just LoginRoute ->
            { model | currentPage = LoginPage Login.initialModel } => Cmd.none
        
        Just LogoutRoute ->
            (model, Cmd.none)
            
        Just HomeRoute ->
            { model | currentPage = HomePage Home.initialModel } => Cmd.none
            
        Just NotesRoute ->
            { model | currentPage = NotesPage Notes.initialModel } => Cmd.none 
        
    
updatePage : Page -> Msg -> Model -> (Model, Cmd Msg)
updatePage page msg model =
    case (msg, page) of
        (SetRouteMsg route, _) ->
            setRoute route model
            
        (LoginMsg pageMsg, LoginPage pageModel) ->
            let 
                ((newPageModel, _), msgFromPage) 
                    = Login.update pageMsg pageModel
            in
                case msgFromPage of
                    Login.NoOpMsg ->
                        { model | currentPage = LoginPage newPageModel } => Cmd.none
                        
                    Login.LoginUserMsg credentials ->
                        { model | currentPage = LoginPage newPageModel } => Firebase.login credentials
                        
        (NotesMsg pageMsg, NotesPage pageModel) ->
            let
                ((newPageModel, _), msgFromPage) 
                    = Notes.update pageMsg pageModel
                newModel 
                    = { model | currentPage = NotesPage newPageModel }
            in
                case msgFromPage of
                    Notes.NoOpMsg ->
                        newModel => Cmd.none
                    
                    Notes.AddNoteMsg note ->
                        case model.currentUser of
                            Nothing ->
                                newModel => Cmd.none
                                
                            Just user ->
                                newModel => Firebase.addNote note user
            
        (_, _) ->
            model => Cmd.none
            
            
{-| Called in response to incoming port messages from the Firebase module in
order to handle incoming data from Firebase. -}
updateFirebase : Firebase.Msg -> Model -> (Model, Cmd Msg)
updateFirebase firebaseMsg model =
    case firebaseMsg of
        Firebase.OnUserLoginMsg user ->
            ({ model | currentUser = Just user }, Route.modifyUrl NotesRoute)
            
        Firebase.OnNoteAddedMsg note ->
            case model.currentPage of
                NotesPage pageModel ->
                    let
                        ((newPageModel, _), msgFromPage) = Notes.update (Notes.OnNoteAddedMsg note) pageModel
                    in
                        ({ model | currentPage = NotesPage newPageModel }, Cmd.none)
                        
                _ ->
                    (model, Cmd.none)
                
            
        Firebase.NoOpMsg ->
            (model, Cmd.none)


initialPage : Page
initialPage = 
    BlankPage
    
    
viewPage : Page -> Maybe User -> Html Msg
viewPage page maybeUser =
    case page of
        NotFoundPage ->
            Html.text ""
            
        BlankPage ->
            Html.text ""
            
        HomePage homeModel ->
            Home.view homeModel
            
        NotesPage notesModel ->
            Notes.view notesModel maybeUser
                |> Html.map NotesMsg
            
        LoginPage loginModel ->
            Login.view loginModel 
                |> Html.map LoginMsg
            
        LogoutPage ->
            Html.text ""
    

view : Model -> Html Msg
view model =
    viewPage model.currentPage model.currentUser


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        FirebaseMsg firebaseMsg ->
            updateFirebase firebaseMsg model
            
        -- Assuming all other messages are for page updates, so route to the
        -- page updater.
        _ ->
            updatePage model.currentPage msg model
            
            
init : Value -> Location -> (Model, Cmd Msg)
init val location =
    setRoute (fromLocation location)
        { currentPage = initialPage 
        , currentUser = Nothing
        }
        
        
subscriptions : Model -> Sub Msg
subscriptions model =
    Firebase.firebaseIncoming (Firebase.process >> FirebaseMsg)

 
main : Program Value Model Msg
main = 
    Navigation.programWithFlags (Route.fromLocation >> SetRouteMsg)
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }