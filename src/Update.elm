
module Update exposing (..)

import Messages exposing (Msg(..))
import Models exposing (..)
import RemoteData exposing (..)

update : Msg -> AppModel -> (AppModel, Cmd Msg)
update msg model =
    case msg of
        OnFetchNotes response ->
            let mapStatus response =
                if isSuccess response then Models.Success
                else if isFailure response then Models.Failure
                else Models.Pending
            in 
                ({ model | notes = (mapStatus response, toMaybe response) }, Cmd.none)

        -- OnSearchKeyDown query ->
        --     ({ model | query = query }, Cmd.none)
        
        OnAddNote note ->
            ({ model | notes = addNote note model.notes }, Cmd.none)
