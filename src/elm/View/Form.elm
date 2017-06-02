module View.Form exposing (input, password)


import Html exposing (fieldset, ul, li, Html, Attribute, text)
import Html.Attributes exposing (class, type_)


password : List (Attribute msg) -> List (Html msg) -> Html msg
password attrs =
    Html.input ([ type_ "password", class "form-control" ] ++ attrs)


input : List (Attribute msg) -> List (Html msg) -> Html msg
input attrs =
    Html.input ([ type_ "text", class "form-control" ] ++ attrs)
    
    
control :
    (List (Attribute msg) -> List (Html msg) -> Html msg)
    -> List (Attribute msg)
    -> List (Html msg)
    -> Html msg
control element attributes children =
    fieldset [ class "form-group" ]
        [ element (class "form-control" :: attributes) children ]