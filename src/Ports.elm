port module Ports exposing (login)


import Data.User exposing (Credentials)


port login : Credentials -> Cmd msg