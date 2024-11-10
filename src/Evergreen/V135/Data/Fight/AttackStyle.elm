module Evergreen.V135.Data.Fight.AttackStyle exposing (..)

import Evergreen.V135.Data.Fight.AimedShot


type AttackStyle
    = UnarmedUnaimed
    | UnarmedAimed Evergreen.V135.Data.Fight.AimedShot.AimedShot
    | MeleeUnaimed
    | MeleeAimed Evergreen.V135.Data.Fight.AimedShot.AimedShot
    | Throw
    | ShootSingleUnaimed
    | ShootSingleAimed Evergreen.V135.Data.Fight.AimedShot.AimedShot
    | ShootBurst