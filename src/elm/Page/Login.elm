module Page.Login exposing (Model, PublicMsg(..), Msg(..), view, initialModel, update)


import Data.User exposing (Credentials, makeCredentials)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onSubmit, onInput)
import View.Form as Form exposing (input, password)
import Util.Helpers exposing ((=>))
import Validate exposing (..)


type PublicMsg
    = NoOpMsg
    | LoginUserMsg Credentials


type Msg
    = SubmitFormMsg
    | SetEmailMsg String
    | SetPasswordMsg String
    
        
type alias Model =
    { email : String
    , password : String
    , errors : List Error
    }
    
    
type Field
    = Form
    | Email
    | Password
    
    
type alias Error = (Field, String)
    
    
initialModel : Model
initialModel =
    { email = ""
    , password = ""
    , errors = []
    }
    
    
update : Msg -> Model -> ((Model, Cmd Msg), PublicMsg)
update msg model =
    case msg of
        SetEmailMsg value ->
            { model | email = value } => Cmd.none => NoOpMsg
        
        SetPasswordMsg value ->
            { model | password = value } => Cmd.none => NoOpMsg
        
        SubmitFormMsg ->
            let 
                validated = validate model
                credentials = makeCredentials model.email model.password
            in
                if List.isEmpty validated then
                    model => Cmd.none => LoginUserMsg credentials
                else
                    { model | errors = validated } => Cmd.none => NoOpMsg
                
                
validate : Model -> List Error
validate =
    Validate.all
        [ .email >> ifBlank (Email => "Please enter an e-mail address.")
        , .email >> ifInvalidEmail (Email => "Please enter a valid e-mail address.")
        , .password >> ifBlank (Password => "Please enter a password.")
        ] 
        

view : Model -> Html Msg
view model =
    div [ class "login-page page" ] 
    [ loginForm model
    ]
    
    
loginForm : Model -> Html Msg
loginForm model =
    Html.form [ class "pure-form pure-form-stacked login-form", onSubmit SubmitFormMsg ] 
        [ h1 [ class "title" ] [ text "Sign in to CleverJot" ]
        , viewFormErrors Email model.errors
        , label [ class "form-label", for "email" ] [ text "Email" ]
        , Form.input [ id "email", onInput SetEmailMsg ] []
        , viewFormErrors Password model.errors
        , label [ class "form-label", for "password" ] [ text "Password" ]
        , Form.password [ id "password", onInput SetPasswordMsg ] []
        , button [ class "pure-button pure-button-primary action-button" ] [ text "Sign in" ]
        ]


viewFormErrors : Field -> List Error -> Html msg
viewFormErrors field errors =
    let
        filteredErrors = List.filter (\e -> Tuple.first e == field) errors
        errorMessages = List.map Tuple.second filteredErrors
    in
        if List.isEmpty errorMessages then 
            text ""
        else
            div [ class "form-error" ]
            [ text (String.join " " errorMessages)
            ]