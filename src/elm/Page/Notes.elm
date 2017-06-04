module Page.Notes exposing 
    (Model
    , PublicMsg(..)
    , Msg(..)
    , view
    , initialModel
    , update
    )


import Debug exposing (log)
import Html exposing (..)
import Html.Attributes exposing (class)
import Data.Note exposing (Note, newNote)
import Data.User exposing (User)
import Firebase
import View.App as App exposing (header)
import View.Notes exposing (notesList)
import Util.Html exposing (onEnter)


type PublicMsg
    = NoOpMsg
    | AddNoteMsg Note


type Msg
    = OnSearchEnterMsg String
    | OnNoteAddedMsg Note
    
    
type alias Model =
    { notes : List Note
    , query : Maybe String
    }
    
    
update : Msg -> Model -> ((Model, Cmd Msg), PublicMsg)
update msg model =
    case msg of
        OnSearchEnterMsg query ->
            let 
                -- maybeQuery = if query == "" then Nothing else Just query
                note = newNote query
            in
                log query (({ model | query = Nothing }, Cmd.none), AddNoteMsg note)
                
        OnNoteAddedMsg note ->
            (({ model | notes = note :: model.notes }, Cmd.none), NoOpMsg)
                

initialModel : Model
initialModel =
    { notes = []
    , query = Nothing
    }


view : Model -> Maybe User -> Html Msg
view model maybeUser =
    div [ class "notes-page page" ] 
    [ App.header maybeUser model.query [ onEnter OnSearchEnterMsg ]
    , div [ class "pure-g app-page-body" ]
        [ notesList model.notes
        , div [ class "pure-u-2-3" ] []
        ]
    ]