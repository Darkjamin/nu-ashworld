module Evergreen.V135.Data.Tick exposing (..)


type TickPerIntervalCurve
    = QuarterAndRest
        { quarter : Int
        , rest : Int
        }
    | Linear Int
