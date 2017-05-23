
module Models exposing (..)

type Route =
    NotesRoute
    | NoteRoute NoteId

type alias NoteId = Int

type RemoteStatus =
    Success
    | Failure
    | Pending

type alias NoteList = 
    (RemoteStatus, Maybe (List Note))

type alias Note =
    { id : NoteId 
    , text : String
    }

type alias AppModel =
    { query : Maybe String 
    , route : Route
    , notes : NoteList
    }

initialAppModel : AppModel
initialAppModel =
    { query = Nothing
    , route = NotesRoute
    , notes = (Pending, Nothing)
    }

addNote : Note -> NoteList -> NoteList
addNote note notes =
    let justNotes =
        Just (note :: (Maybe.withDefault [] (Tuple.second notes)))
    in
        (Pending, justNotes)
