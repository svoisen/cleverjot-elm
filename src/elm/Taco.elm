module Taco exposing (Taco)


import Data.User exposing (User)


type alias Taco =
    { user : User
    , menuVisible : Boolean
    }