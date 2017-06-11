module Page.Notes exposing 
    ( Model
    , PublicMsg(..)
    , Msg(..)
    , view
    , initialModel
    , update
    )


import Debug exposing (log)
import Data.Note exposing (Note, newNote, select, deselect, markDirty, markClean)
import Data.User exposing (User)
import Dict exposing (Dict)
import Html exposing (Html, div, section)
import Html.Attributes exposing (class)
import Util.Helpers exposing ((=>), (?))
import View.App as App exposing (header)
import View.Notes exposing (notesView, noteEditor)


{-| Messages for handling outside of this module. -}
type PublicMsg
    = NoOpMsg
    | AddNoteMsg Note
    | NotesDirtiedMsg


{-| Messages for handling within this module. -}
type Msg
    = OnSearchEnterMsg String
    | OnNoteAddedMsg Note
    | OnNoteSelectedMsg Note
    | OnNoteChangedMsg Note 
    | SaveDirtyNotesMsg
    
    
type alias Model =
    { notes : Dict String Note
    , selectedNoteId : Maybe String
    , query : Maybe String
    }
    
    
update : Msg -> Model -> ((Model, Cmd Msg), PublicMsg)
update msg model =
    case msg of
        OnSearchEnterMsg query ->
            { model | query = Nothing } => Cmd.none => AddNoteMsg (newNote query)
                
        OnNoteSelectedMsg note ->
            selectNote note.uid model => Cmd.none => NoOpMsg
            -- model => Cmd.none => NoOpMsg
                
        OnNoteAddedMsg note ->
            case note.uid of
                Nothing ->
                    model => Cmd.none => NoOpMsg
                    
                Just uid ->
                    log uid ({ model | notes = Dict.insert uid note model.notes } => Cmd.none => NoOpMsg)
            
        OnNoteChangedMsg note ->
            case note.uid of
                Nothing ->
                    model => Cmd.none => NoOpMsg
            
                Just uid ->
                    { model | notes = Dict.update uid (\_ -> Just (markDirty note)) model.notes } => Cmd.none => NotesDirtiedMsg
                    
        SaveDirtyNotesMsg ->
            log "SAVE" (model => Cmd.none => NoOpMsg)
            
            
selectNote : Maybe String -> Model -> Model
selectNote maybeUid model =
    case maybeUid of
        Nothing ->
            { model | 
                notes = Dict.map (\_ -> deselect) model.notes,
                selectedNoteId = Nothing
            }
        
        Just uid ->
            { model |
                notes = Dict.map (\k -> if k == uid then select else deselect) model.notes,
                selectedNoteId = maybeUid
            }
                

initialModel : Model
initialModel =
    { notes = Dict.empty 
    , selectedNoteId = Nothing
    , query = Nothing
    }


view : Model -> Maybe User -> Html Msg
view model maybeUser =
    div [ class "notes-page page" ] 
    [ header maybeUser model.query OnSearchEnterMsg
    , section [ class "page-body" ]
        [ notesView (Dict.values model.notes) OnNoteSelectedMsg
        , noteEditor (Dict.get (model.selectedNoteId ? "") model.notes) OnNoteChangedMsg
        ]
    ]
    