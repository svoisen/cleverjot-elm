module Page.Notes exposing 
    ( Model
    , PublicMsg(..)
    , Msg(..)
    , view
    , initialModel
    , update
    )


import Html exposing (..)
import Html.Attributes exposing (class)
import Data.Note exposing (Note, newNote)
import Data.User exposing (User)
import View.App as App exposing (header)
import View.Notes exposing (notesView, noteEditor)
import Util.Html exposing (onEnter)
import Util.Helpers exposing ((=>))


type PublicMsg
    = NoOpMsg
    | AddNoteMsg Note


{-| Messages that are internal-only to this module -}
type Msg
    = OnSearchEnterMsg String
    | OnNoteAddedMsg Note
    | OnNoteSelectedMsg Note
    
    
type alias Model =
    { notes : List Note
    , selectedNote : Maybe Note
    , query : Maybe String
    }
    
    
update : Msg -> Model -> ((Model, Cmd Msg), PublicMsg)
update msg model =
    case msg of
        OnSearchEnterMsg query ->
            { model | query = Nothing } => Cmd.none => AddNoteMsg (newNote query)
                
        OnNoteSelectedMsg note ->
            { model | selectedNote = Just note } => Cmd.none => NoOpMsg
                
        OnNoteAddedMsg note ->
            { model | notes = note :: model.notes } => Cmd.none => NoOpMsg
                

initialModel : Model
initialModel =
    { notes = []
    , selectedNote = Nothing
    , query = Nothing
    }


view : Model -> Maybe User -> Html Msg
view model maybeUser =
    div [ class "notes-page page" ] 
    [ App.header maybeUser model.query [ onEnter OnSearchEnterMsg ]
    , section [ class "page-body" ]
        [ notesView model.notes OnNoteSelectedMsg
        , noteEditor model.selectedNote
        ]
    ]
    