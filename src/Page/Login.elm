module Page.Login exposing (Model, PublicMsg(..), Msg(..), view, initialModel, update)


import Debug exposing (log)
import Data.User exposing (Credentials, makeCredentials)
import Html exposing (..)
import Html.Attributes exposing (class, placeholder)
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
    div [ class "login-page page pure-g" ]
    [ div [ class "pure-u-1-3" ] []
    , loginForm
    , div [ class "pure-u-1-3" ] []
    ]
    
    
loginForm : Html Msg
loginForm =
    div [ class "pure-u-1-3" ] 
    [ Html.form [ class "pure-form pure-form-stacked login-form", onSubmit SubmitFormMsg ] 
        [ h2 [] [ text "Sign in" ]
        , Form.input [ placeholder "Email", onInput SetEmailMsg ] []
        , Form.password [ placeholder "Password", onInput SetPasswordMsg ] []
        , button [ class "pure-button pure-button-primary" ] [ text "Sign in" ]
        ]
    ]
