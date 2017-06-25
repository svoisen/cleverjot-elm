module Data.NoteCollection exposing 
    ( NoteCollection
    , insert
    , update
    , remove
    , get
    , empty
    , markDirty
    , markAllClean
    , select
    , selected
    , deselectAll
    , filter
    , clearFilter
    , filtered
    , dirtied
    )
    
    
import Dict exposing (Dict)
import Data.Note as Note exposing (Note, NoteId, invalidNoteId)
import Set exposing (Set)
    
    
type alias NoteCollection = 
    { allNotes: Dict NoteId Note
    , filteredNoteIds : Set NoteId
    , selectedNoteId : NoteId
    , dirtyNoteIds : Set NoteId
    }
    
    
empty : NoteCollection
empty =
    { allNotes = Dict.empty
    , filteredNoteIds = Set.empty
    , selectedNoteId = invalidNoteId
    , dirtyNoteIds = Set.empty
    }
    
    
insert : Note -> NoteCollection -> NoteCollection
insert note noteCollection =
    { noteCollection | allNotes = Dict.insert note.uid note noteCollection.allNotes }
    

update : Note -> NoteCollection -> NoteCollection    
update note noteCollection =
    { noteCollection | allNotes = Dict.update note.uid (always note |> Maybe.map) noteCollection.allNotes }
    
    
remove : NoteId -> NoteCollection -> NoteCollection
remove noteId noteCollection =
    { noteCollection | 
        allNotes = Dict.remove noteId noteCollection.allNotes,
        selectedNoteId = if noteCollection.selectedNoteId == noteId then invalidNoteId else noteCollection.selectedNoteId,
        dirtyNoteIds = Set.remove noteId noteCollection.dirtyNoteIds,
        filteredNoteIds = Set.remove noteId noteCollection.filteredNoteIds
    }
    
    
get : NoteId -> NoteCollection -> Maybe Note
get noteId noteCollection =
    Dict.get noteId noteCollection.allNotes
    
    
select : NoteId -> NoteCollection -> NoteCollection
select noteId noteCollection =
    { noteCollection |
        allNotes = Dict.map (\k -> if k == noteId then Note.select else Note.deselect) noteCollection.allNotes,
        selectedNoteId = noteId
    }
    
    
selected : NoteCollection -> Maybe Note
selected noteCollection =
    Dict.get noteCollection.selectedNoteId noteCollection.allNotes
    
    
deselectAll : NoteId -> NoteCollection -> NoteCollection
deselectAll noteId noteCollection =
    { noteCollection | 
        allNotes = Dict.map (\_ note -> Note.deselect note) noteCollection.allNotes,
        selectedNoteId = invalidNoteId
    }
        
        
filter : Set NoteId -> NoteCollection -> NoteCollection
filter noteIds noteCollection =
    { noteCollection | filteredNoteIds = noteIds }
    
    
markDirty : NoteId -> NoteCollection -> NoteCollection
markDirty noteId noteCollection =
    { noteCollection |
        allNotes = Dict.update noteId (Maybe.map Note.markDirty) noteCollection.allNotes,
        dirtyNoteIds = Set.insert noteId noteCollection.dirtyNoteIds
    }
        
        
markAllClean : NoteCollection -> NoteCollection
markAllClean noteCollection =
    { noteCollection |
        allNotes = Dict.map (\_ note -> Note.markClean note) noteCollection.allNotes,
        dirtyNoteIds = Set.empty
    }
    
    
clearFilter : NoteCollection -> NoteCollection
clearFilter noteCollection =
    { noteCollection | filteredNoteIds = Set.empty }


{-| Get a list of all the notes that match the list of IDs in the filtered notes
ID list. -}
filtered : NoteCollection -> List Note
filtered noteCollection =
    if Set.isEmpty noteCollection.filteredNoteIds then
        Dict.values noteCollection.allNotes
        
    else
        Dict.filter (\key _ -> Set.member key noteCollection.filteredNoteIds) noteCollection.allNotes |> Dict.values
            

dirtied : NoteCollection -> List Note
dirtied noteCollection =
    Dict.filter (\key _ -> Set.member key noteCollection.dirtyNoteIds) noteCollection.allNotes |> Dict.values
    