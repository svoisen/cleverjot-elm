
module Main exposing (..)

import Commands exposing (fetchNotes)
import Html exposing (program)
import Messages exposing (Msg)
import Models exposing (AppModel, initialAppModel)
import Update exposing (update)
import Views exposing (view)

main : Program Never AppModel Msg
main = 
    program
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }

init : (AppModel, Cmd Msg)
init =
    let 
        model = initialAppModel
        cmd = fetchNotes
    in
        (model, cmd)