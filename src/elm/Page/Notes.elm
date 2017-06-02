module Page.Notes exposing (Model, view, initialModel)


import Html exposing (..)
import Html.Attributes exposing (class)
import Data.Note exposing (NoteCollection, Note)
import Data.User exposing (User)
-- import View.Notes exposing (view)
import RemoteData exposing (WebData)
import View.App as App exposing (header)
import View.Site as Site exposing (footer)


type Msg
    = AddNote
    
    
type alias Model =
    { notes : NoteCollection
    , query : Maybe String
    }
    

initialModel : Model
initialModel =
    { notes = RemoteData.NotAsked 
    , query = Nothing
    }


view : Model -> Maybe User -> Html msg
view model maybeUser =
    div [ class "notes-page page" ] [
    App.header maybeUser model.query []
    ]