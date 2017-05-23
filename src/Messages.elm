
module Messages exposing (..)

import Models exposing (Note)
import RemoteData exposing (WebData)

type Msg =
    OnFetchNotes (WebData (List Note))
    -- | OnSearchKeyDown (Maybe String)
    | OnAddNote Note