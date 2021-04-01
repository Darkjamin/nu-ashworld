module Evergreen.V49.Frontend.Route exposing (..)

import Evergreen.V49.Data.Fight


type AdminRoute
    = Players
    | LoggedIn


type Route
    = Character
    | Map
    | Ladder
    | Town
    | Settings
    | FAQ
    | About
    | News
    | Fight Evergreen.V49.Data.Fight.FightInfo
    | CharCreation
    | Admin AdminRoute