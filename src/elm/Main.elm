module Main exposing (..)


import Debug exposing (log)
import Data.User exposing (User)
import Firebase.Auth as Auth
import Firebase.Database as Database
import Html exposing (..)
import Json.Decode exposing (Value)
import Navigation exposing (Location, programWithFlags)
import Page.Home as Home 
import Page.Login as Login
import Page.Notes as Notes
import Route exposing (..)
import Time
import Util.Helpers exposing ((=>), delay)


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
    | AuthMsg Auth.Msg
    | DatabaseMsg Database.Msg
    

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
                        { model | currentPage = LoginPage newPageModel } => Auth.signIn credentials
                        
        (NotesMsg pageMsg, NotesPage pageModel) ->
            let
                ((newPageModel, cmd), msgFromPage) 
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
                                newModel => Cmd.none
                                
                    Notes.NotesDirtiedMsg ->
                        newModel => (delay (Time.second * 2) (NotesMsg Notes.SaveDirtyNotesMsg))
            
        (_, _) ->
            model => Cmd.none
            
            
updateAuth : Auth.Msg -> Model -> (Model, Cmd Msg)
updateAuth msg model =
    case msg of
        Auth.OnUserSignInMsg user ->
            ({ model | currentUser = Just user }, Route.modifyUrl NotesRoute)
            
        Auth.NoOpMsg ->
            model => Cmd.none
            
            
updateDatabase : Database.Msg -> Model -> (Model, Cmd Msg)
updateDatabase msg model =
    case msg of
        Database.OnValuePushedMsg path key data ->
            log ("Pushed " ++ path) model => Cmd.none
                    
        Database.NoOpMsg ->
            model => Cmd.none


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
        AuthMsg authMsg ->
            updateAuth authMsg model
            
        DatabaseMsg databaseMsg ->
            updateDatabase databaseMsg model
            
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
    Sub.batch 
        [ Auth.authRead (Auth.processIncoming >> AuthMsg)
        , Database.databaseRead (Database.processIncoming >> DatabaseMsg)
        ]

 
main : Program Value Model Msg
main = 
    Navigation.programWithFlags (Route.fromLocation >> SetRouteMsg)
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }