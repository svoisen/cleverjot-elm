module Page.Login exposing (Model, view, initialModel)


import Html exposing (..)
import Html.Attributes exposing (class)


type Msg
    = SubmitForm
    | SetEmail String
    | SetPassword String
    
    
type alias Model =
    { email : String
    , password : String
    }
    
    
initialModel : Model
initialModel =
    { email = ""
    , password = ""
    }


view : Model -> Html msg
view model =
    div [ class "login-page page" ]
    [ h1 [] [ text "Sign in" ]
    ]