module Page.Notes exposing (Model, view, initialModel)


import Html exposing (..)
import Data.Note exposing (NoteCollection, Note)
-- import View.Notes exposing (view)
import RemoteData exposing (WebData)


type Msg
    = AddNote
    
    
type alias Model =
    { notes : NoteCollection
    }
    

initialModel : Model
initialModel =
    { notes = RemoteData.NotAsked 
    }


view : Model -> Html msg
view model =
    p [] [ text "Notes" ] 