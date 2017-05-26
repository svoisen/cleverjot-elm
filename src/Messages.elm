module Messages exposing (Msg(..))


import Data.Note exposing (NoteCollection)
import Route exposing (Route)


type Msg =
    OnFetchNotes NoteCollection
    | SetRoute (Maybe Route)