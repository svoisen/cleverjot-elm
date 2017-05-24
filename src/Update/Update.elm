module Update.Update exposing (update)

import Model.Model exposing (Model, Msg(..))
-- import Model.Note exposing (addNote)
import Debug exposing (log)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        OnFetchNotes response ->
            ({ model | notes = response }, Cmd.none)
            
        OnQueryChanged query ->
            log query ({ model | query = Just query}, Cmd.none)
            
        OnSearchEnterPressed ->
            (model, Cmd.none)
            
        RunCurrentQuery ->
            (model, Cmd.none)