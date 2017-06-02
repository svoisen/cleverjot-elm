module Page.Login exposing (Model, PublicMsg(..), Msg(..), view, initialModel, update)


import Debug exposing (log)
import Data.User exposing (Credentials, makeCredentials)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onSubmit, onInput)
import View.Form as Form exposing (input, password)


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
    }
    
    
initialModel : Model
initialModel =
    { email = ""
    , password = ""
    }
    
    
update : Msg -> Model -> ((Model, Cmd Msg), PublicMsg)
update msg model =
    case msg of
        SetEmailMsg value ->
            log value (({ model | email = value }, Cmd.none), NoOpMsg)
        
        SetPasswordMsg value ->
            log value (({ model | password = value }, Cmd.none), NoOpMsg)
        
        SubmitFormMsg ->
            let credentials = 
                makeCredentials model.email model.password
            in
                ((model, Cmd.none), LoginUserMsg credentials)
        

view : Model -> Html Msg
view model =
    div [ class "login-page page" ] 
    [ loginForm
    ]
    
    
loginForm : Html Msg
loginForm =
    Html.form [ class "pure-form pure-form-stacked login-form", onSubmit SubmitFormMsg ] 
        [ h1 [ class "title" ] [ text "Sign in" ]
        , label [ class "form-label", for "email" ] [ text "Email" ]
        , Form.input [ id "email", onInput SetEmailMsg ] []
        , label [ class "form-label", for "password" ] [ text "Password" ]
        , Form.password [ id "password", onInput SetPasswordMsg ] []
        , button [ class "pure-button pure-button-primary action-button" ] [ text "Sign in" ]
        ]
