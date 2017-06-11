module Page.Notes exposing 
    ( Model
    , PublicMsg(..)
    , Msg(..)
    , view
    , initialModel
    , update
    )


import Debug exposing (log)
import Data.Note exposing (Note, newNote, select, deselect, markDirty, markClean, invalidNoteId)
import Data.User exposing (User)
import Dict exposing (Dict)
import ElmTextSearch as Search
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
    | OnSearchInputMsg String
    | OnNoteAddedMsg Note
    | OnNoteSelectedMsg Note
    | OnNoteChangedMsg Note 
    | OnMenuClickMsg
    | SaveDirtyNotesMsg
    
    
type alias Model =
    { notes : Dict String Note
    , filteredNotes : List Note
    , selectedNoteId : String
    , searchIndex : Search.Index Note
    , query : Maybe String
    }
    
    
update : Msg -> Model -> ((Model, Cmd Msg), PublicMsg)
update msg model =
    case msg of
        OnMenuClickMsg ->
            model => Cmd.none => NoOpMsg
            
        OnSearchInputMsg query ->
            if query == "" then
                clearSearch model => Cmd.none => NoOpMsg
            else
                runSearch query model => Cmd.none => NoOpMsg
        
        OnSearchEnterMsg query ->
            { model | query = Nothing } => Cmd.none => AddNoteMsg (newNote query)
                
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
            { model | notes = Dict.update note.uid (\_ -> Just (markDirty note)) model.notes } => Cmd.none => NotesDirtiedMsg
                    
        SaveDirtyNotesMsg ->
            model => Cmd.none => NoOpMsg
            
            
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
                

initialModel : Model
initialModel =
    { notes = Dict.empty 
    , filteredNotes = []
    , selectedNoteId = invalidNoteId
    , searchIndex = createSearchIndex
    , query = Nothing
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
    