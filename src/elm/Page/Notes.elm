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
import Data.Note exposing (Note, newNote, emptyNote, select, deselect, markDirty, markClean, invalidNoteId)
import Data.User exposing (User)
import Dict exposing (Dict)
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
    { notes : Dict String Note
    , filteredNotes : List Note
    , selectedNoteId : String
    , searchIndex : Search.Index Note
    , query : Maybe String
    , saveDebounce : Debounce String
    , dirtyNoteIds : Set String
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
                { model | query = Nothing } => cmd => NoOpMsg
                
        OnNoteSelectedMsg note ->
            selectNote note.uid model => Cmd.none => NoOpMsg
                
        OnNoteAddedMsg note ->
            let
                newIndexResult = Search.add note model.searchIndex
                newNotes = Dict.insert note.uid note model.notes
                
            in
                case newIndexResult of
                    Err errMsg ->
                        log errMsg ({ model | notes = newNotes } => Cmd.none => NoOpMsg)
                    
                    Ok newIndex ->
                        let
                            newModel = { model | searchIndex = newIndex, notes = newNotes, filteredNotes = Dict.values newNotes }
                            
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
                    notes = Dict.update note.uid (\_ -> Just (markDirty note)) model.notes,
                    dirtyNoteIds = Set.insert note.uid model.dirtyNoteIds,
                    saveDebounce = debounce 
                } => cmd => NoOpMsg
                    
        SaveDebounceMsg msg ->
            let
                cmd = 
                    case maybeUser of
                        Nothing ->
                            Cmd.batch [ Cmd.none ]
                            
                        Just user ->
                            Set.toList model.dirtyNoteIds
                            |> List.map (\uid -> Dict.get uid model.notes ? emptyNote)
                            |> List.filter (\note -> note.uid /= invalidNoteId)
                            |> List.map (\note -> updateNote note user)
                            |> Cmd.batch
                            
            in
                { model | dirtyNoteIds = Set.empty } => cmd => NoOpMsg
            
            
clearSearch : Model -> Model
clearSearch model =
    { model |
        query = Nothing,
        filteredNotes = Dict.values model.notes
    }
            
            
runSearch : String -> Model -> Model 
runSearch query model =
    let
        searchResults = Search.search query model.searchIndex
        
    in
        case searchResults of
            Err err ->
                -- log err { model | query = Nothing, filteredNotes = Dict.values model.notes }
                { model | query = Just query }
                
            Ok (newIndex, weightedNoteIds) ->
                let 
                    newFilteredNotes = filterNotes weightedNoteIds model.notes
                    keepSelected = List.member model.selectedNoteId (List.map Tuple.first weightedNoteIds)
                    
                in
                    { model |
                        query = Just query,
                        filteredNotes = newFilteredNotes,
                        selectedNoteId = if keepSelected then model.selectedNoteId else invalidNoteId
                    }
            
            
filterNotes : List (String, Float) -> Dict String Note -> List Note
filterNotes weightedNoteIds notes =
    let
        noteIds = List.map Tuple.first weightedNoteIds
        
    in
        Dict.filter (\key _ -> List.member key noteIds) notes |> Dict.values
            
            
selectNote : String -> Model -> Model
selectNote uid model =
    { model |
        notes = Dict.map (\k -> if k == uid then select else deselect) model.notes,
        filteredNotes = List.map (\n -> if uid == n.uid then select n else deselect n) model.filteredNotes,
        selectedNoteId = uid
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
    { strategy = Debounce.later (2 * second)
    , transform = SaveDebounceMsg
    }
                

initialModel : Model
initialModel =
    { notes = Dict.empty 
    , filteredNotes = []
    , selectedNoteId = invalidNoteId
    , searchIndex = createSearchIndex
    , query = Nothing
    , saveDebounce = Debounce.init
    , dirtyNoteIds = Set.empty
    }


view : Model -> Maybe User -> Html Msg
view model maybeUser =
    div [ class "notes-page page" ] 
    [ header maybeUser model.query OnMenuClickMsg OnSearchEnterMsg OnSearchInputMsg
    , section [ class "page-body" ]
        [ notesView model.filteredNotes OnNoteSelectedMsg
        , noteEditor (Dict.get model.selectedNoteId model.notes) OnNoteChangedMsg
        ]
    ]
    