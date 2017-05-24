module Model.Model exposing (Model, Msg(..), initialModel)

import Model.Note exposing (NoteCollection, Note)
import Model.Route exposing (Route(..))
import RemoteData exposing (WebData)

type Msg =
    OnFetchNotes NoteCollection
    | OnSearchEnterPressed 
    | OnQueryChanged String
    | RunCurrentQuery

type alias Model =
    { query : Maybe String 
    , notes : NoteCollection
    , route : Route
    }
    
initialModel : Model
initialModel =
    { query = Nothing
    , notes = RemoteData.NotAsked
    , route = NotesRoute
    }