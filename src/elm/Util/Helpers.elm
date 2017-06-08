module Util.Helpers exposing 
    ( (=>)
    , (?) 
    , delay
    )
    
    
import Process exposing (sleep)
import Task exposing (perform, succeed, andThen)
import Time exposing (Time)


{-| Helper operator to reduce the number of parentheses when creating tuples or
nested tuples. -}
(=>) : a -> b -> (a, b)
(=>) =
    (,)
    
infixl 0 =>


{-| Simpler, easier-to-ready Maybe.withDefault syntax. -}
(?) : Maybe a -> a -> a
(?) maybe default =
    Maybe.withDefault default maybe
    
infixl 0 ?


delay : Time -> msg -> Cmd msg
delay time msg =
  Process.sleep time
  |> Task.andThen (always <| Task.succeed msg)
  |> Task.perform identity