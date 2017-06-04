module Util.Helpers exposing (..)


(=>) : a -> b -> (a, b)
(=>) =
    (,)
    
infixl 0 =>


(?) : Maybe a -> a -> a
(?) maybe default =
    Maybe.withDefault default maybe
    
infixl 0 ?