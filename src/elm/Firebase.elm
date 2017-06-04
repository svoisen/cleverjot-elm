port module Firebase exposing 
    ( Msg(..)
    , process
    , login
    , addNote
    , firebaseIncoming
    )


import Data.User as User exposing (Credentials, User, encodeCredentials, encodeUser, userDecoder)
import Data.Note as Note exposing (Note, encodeNote, noteDecoder)
import Json.Encode as Encode exposing (encode, string, object)
import Json.Decode as Decode exposing (Value)


type Msg
    = NoOpMsg
    | OnUserLoginMsg User
    | OnNoteAddedMsg Note
    
    
{-| Type for JSON messages coming from and going to the port. These messages are
only used internally for this module. This is primarily used to ensure stronger
message type checking than what would otherwise be possible using raw Strings. -}
type PortMsgType
    = EmptyMsg
    | UserLoginRequestMsg
    | UserDidLoginMsg
    | AddNoteMsg
    | NoteAddedMsg


port firebaseOutgoing : String -> Cmd msg
port firebaseIncoming : (Value -> msg) -> Sub msg


{-| Given a JSON message from the port, determine the message type and decode
from string to PortMsgType. -}
getMsgType : Value -> PortMsgType
getMsgType value =
    let 
        decoder = (Decode.field "type" Decode.string)
        messageType = Decode.decodeValue decoder value
    in
        case messageType of
            Err _ ->
                EmptyMsg
                
            Ok str ->
                fromString str


process : Value -> Msg
process value =
    let 
        messageType = getMsgType value
    in
        case messageType of
            UserDidLoginMsg ->
                let decodedUser =
                    Decode.decodeValue (Decode.field "user" userDecoder) value
                in
                    case decodedUser of
                        Err _ ->
                            NoOpMsg
                            
                        Ok user ->
                            OnUserLoginMsg user
                            
            NoteAddedMsg ->
                let decodedNote =
                    Decode.decodeValue (Decode.field "note" noteDecoder) value
                in
                    case decodedNote of
                        Err _ ->
                            NoOpMsg
                            
                        Ok note ->
                            OnNoteAddedMsg note
                            
            _ ->
                NoOpMsg


login : Credentials -> Cmd msg
login credentials =
    let message =
        ("type", Encode.string (toString UserLoginRequestMsg)) :: (encodeCredentials credentials)
            |> Encode.object
    in
        encode 0 message |> firebaseOutgoing
        
        
addNote : Note -> User -> Cmd msg
addNote note user =
    let message =
        Encode.object
            [ ("type", Encode.string (toString AddNoteMsg))
            , ("note", encodeNote note) 
            , ("user", encodeUser user)
            ]
    in
        encode 0 message |> firebaseOutgoing
        
        
toString : PortMsgType -> String
toString msg =
    case msg of
        UserLoginRequestMsg ->
            "userLogin"
            
        UserDidLoginMsg ->
            "userDidLogin"
            
        AddNoteMsg ->
            "addNote"
            
        NoteAddedMsg ->
            "noteAdded"
            
        EmptyMsg ->
            ""
            
            
fromString : String -> PortMsgType
fromString str =
    case str of
        "userLogin" ->
            UserLoginRequestMsg
            
        "userDidLogin" ->
            UserDidLoginMsg
            
        "addNote" ->
            AddNoteMsg
            
        "noteAdded" ->
            NoteAddedMsg
            
        _ ->
            EmptyMsg