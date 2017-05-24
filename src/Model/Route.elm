module Model.Route exposing (..)

import Model.Note exposing (NoteId)

type Route =
    NotesRoute
    | NoteRoute NoteId