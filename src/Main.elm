
module Main exposing (..)

import Command.Note as NoteCommands exposing (fetch)
import Html exposing (program)
import Model.Model exposing (Model, Msg, initialModel)
import Update.Update exposing (update)
import View.View exposing (view)

main : Program Never Model Msg
main = 
    program
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }

init : (Model, Cmd Msg)
init =
    (initialModel, NoteCommands.fetch)
