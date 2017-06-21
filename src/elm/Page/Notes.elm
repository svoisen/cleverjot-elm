module Page.Notes exposing 
    ( Model
    , PublicMsg(..)
    , Msg(..)
    , view
    , initialModel
    , update
    )


import Command.Notes exposing (addNote, updateNote)
import Debug exposing (log)
import Debounce exposing (Debounce)
import Data.Note as Note exposing (Note, newNote, invalidNoteId)
import Data.NoteCollection as NoteCollection exposing (NoteCollection)
import Data.User exposing (User)
import ElmTextSearch as Search
import Html exposing (Html, div, section)
import Html.Attributes exposing (class)
import Set exposing (Set)
import Time exposing (second)
import Util.Helpers exposing ((=>), (?))
import View.App as App exposing (header)
import View.Notes exposing (notesView, noteEditor)


{-| Messages intended for handling outside of this module. -}
type PublicMsg
    = NoOpMsg


{-| Messages intended for handling within this module. -}
type Msg
    = OnSearchEnterMsg String
    | OnSearchInputMsg String
    | OnNoteAddedMsg Note
    | OnNoteSelectedMsg Note
    | OnNoteChangedMsg Note 
    | OnMenuClickMsg
    | SaveDebounceMsg Debounce.Msg
    
    
type alias Model =
    { notes : NoteCollection
    , searchIndex : Search.Index Note
    , query : Maybe String
    , saveDebounce : Debounce String
    }
    
    
update : Msg -> Model -> Maybe User -> ((Model, Cmd Msg), PublicMsg)
update msg model maybeUser =
    case msg of
        OnMenuClickMsg ->
            model => Cmd.none => NoOpMsg
            
        OnSearchInputMsg query ->
            if query == "" then
                clearSearch model => Cmd.none => NoOpMsg
            else
                runSearch query model => Cmd.none => NoOpMsg
        
        OnSearchEnterMsg query ->
            let
                cmd =  
                    case maybeUser of
                        Nothing -> Cmd.none
                        Just user -> addNote (newNote query) user
            in 
                { model | 
                    query = Nothing,
                    notes = NoteCollection.clearFilter model.notes
                } => cmd => NoOpMsg
                
        OnNoteSelectedMsg note ->
            { model | notes = NoteCollection.select note.uid model.notes } => Cmd.none => NoOpMsg
                
        OnNoteAddedMsg note ->
            let
                newIndexResult = Search.add note model.searchIndex
                newNotes = NoteCollection.insert note model.notes |> NoteCollection.select note.uid
                
            in
                case newIndexResult of
                    Err errMsg ->
                        -- TODO: Determine how to handle error in inserting to search index
                        log errMsg ({ model | notes = newNotes } => Cmd.none => NoOpMsg)
                    
                    Ok newIndex ->
                        let
                            newModel = { model | searchIndex = newIndex, notes = newNotes }
                            
                        in
                            case model.query of
                                Nothing ->
                                    newModel => Cmd.none => NoOpMsg
                                    
                                Just query ->
                                    runSearch query newModel => Cmd.none => NoOpMsg
            
        OnNoteChangedMsg note ->
            let
                -- Only save the note after enough idle time delay to avoid excessive database
                -- operations.
                (debounce, cmd) = Debounce.push saveDebounceConfig note.uid model.saveDebounce 
                
            in
                { model | 
                    notes = NoteCollection.update note model.notes |> NoteCollection.markDirty note.uid,
                    saveDebounce = debounce 
                } => cmd => NoOpMsg
                    
        SaveDebounceMsg msg ->
            let
                cmd = 
                    case maybeUser of
                        Nothing ->
                            Cmd.batch [ Cmd.none ]
                            
                        Just user ->
                            NoteCollection.dirtied model.notes
                            |> List.map (\note -> updateNote note user)
                            |> Cmd.batch
                            
            in
                { model | notes = NoteCollection.markAllClean model.notes } => cmd => NoOpMsg
            
            
clearSearch : Model -> Model
clearSearch model =
    { model |
        query = Nothing,
        notes = NoteCollection.clearFilter model.notes
    }
            
            
runSearch : String -> Model -> Model 
runSearch query model =
    let
        searchResults = Search.search query model.searchIndex
        
    in
        case searchResults of
            Err err ->
                { model | query = Just query }
                
            Ok (newIndex, weightedNoteIds) ->
                { model |
                    query = Just query,
                    notes = NoteCollection.filter (List.map Tuple.first weightedNoteIds |> Set.fromList) model.notes
                }
            
            
createSearchIndex : Search.Index Note
createSearchIndex = 
    Search.new
        { ref = .uid
        , fields = 
            [ (.text, 1.0)
            ]
        , listFields = []
        }
        
        
saveDebounceConfig : Debounce.Config Msg
saveDebounceConfig = 
    { strategy = Debounce.later (5 * second)
    , transform = SaveDebounceMsg
    }
                

initialModel : Model
initialModel =
    { notes = NoteCollection.empty 
    , searchIndex = createSearchIndex
    , query = Nothing
    , saveDebounce = Debounce.init
    }


view : Model -> Maybe User -> Html Msg
view model maybeUser =
    div [ class "notes-page page" ] 
    [ header maybeUser model.query OnMenuClickMsg OnSearchEnterMsg OnSearchInputMsg
    , section [ class "page-body" ]
        [ notesView (NoteCollection.filtered model.notes) OnNoteSelectedMsg
        , noteEditor (NoteCollection.selected model.notes) OnNoteChangedMsg
        ]
    ]
    