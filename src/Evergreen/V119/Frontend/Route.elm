module Evergreen.V119.Frontend.Route exposing (..)

import Evergreen.V119.Data.Message
import Evergreen.V119.Data.Vendor.Shop
import Evergreen.V119.Data.World
import Url


type PlayerRoute
    = AboutWorld
    | Character
    | Inventory
    | Ladder
    | TownMainSquare
    | TownStore Evergreen.V119.Data.Vendor.Shop.Shop
    | Fight
    | Messages
    | Message Evergreen.V119.Data.Message.Id
    | CharCreation
    | SettingsFightStrategy
    | SettingsFightStrategySyntaxHelp


type AdminRoute
    = AdminWorldsList
    | AdminWorldActivity Evergreen.V119.Data.World.Name
    | AdminWorldHiscores Evergreen.V119.Data.World.Name


type Route
    = About
    | Guide (Maybe String)
    | News
    | Map
    | WorldsList
    | NotFound Url.Url
    | PlayerRoute PlayerRoute
    | AdminRoute AdminRoute