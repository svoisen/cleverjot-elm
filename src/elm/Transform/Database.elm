module Transform.Database exposing 
    ( Msg(..) 
    , transform
    )


import Data.Note exposing (Note, noteDecoder)
import Firebase.Database as FBDatabase exposing (Path)
import Json.Decode as Decode
import Util.Helpers exposing ((=>), (?))


type Msg
    = OnNoteAddedMsg Note
    | InvalidDataMsg
    | NoOpMsg
    
    
type PathType
    = UserNotesPath
    | UnknownPath


transform : FBDatabase.Msg -> Msg
transform msg =
    case msg of
        FBDatabase.OnChildAddedMsg path key data ->
            case (getPathRoot path) of
                UserNotesPath ->
                    let
                        noteResult = data
                            |> Decode.decodeValue noteDecoder
                            |> Result.map (\note -> { note | uid = Just key })
                    in
                        case noteResult of 
                            Ok note ->
                                OnNoteAddedMsg note
                                
                            Err _ ->
                                InvalidDataMsg
                        
                UnknownPath ->
                    InvalidDataMsg 
                        
        _ ->
            NoOpMsg 
            
            
getPathRoot : Path -> PathType
getPathRoot path =
    let
        root = (String.split "/" path |> List.head) ? ""
    in
        case root of
            "notes" ->
                UserNotesPath
                
            _ ->
                UnknownPath
    