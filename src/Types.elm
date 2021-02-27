module Types exposing (..)

import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Dict exposing (Dict)
import Frontend.Route exposing (Route)
import Lamdera exposing (ClientId, SessionId)
import Set exposing (Set)
import Time
import Types.Fight exposing (FightInfo)
import Types.Player exposing (PlayerName, SPlayer)
import Types.World
    exposing
        ( World
        , WorldLoggedInData
        , WorldLoggedOutData
        )
import Url exposing (Url)


type alias FrontendModel =
    { key : Key
    , zone : Time.Zone
    , route : Route
    , world : World
    }


type alias BackendModel =
    -- TODO PlayerName should be the key; names always unique
    { players : Dict SessionId SPlayer
    }


type FrontendMsg
    = UrlClicked UrlRequest
    | UrlChanged Url
    | GoToRoute Route
    | Logout
    | Login
    | NoOp
    | GetZone Time.Zone


type ToBackend
    = LogMeIn
    | Fight PlayerName


type BackendMsg
    = Connected SessionId ClientId
    | GeneratedPlayerLogHimIn SessionId ClientId SPlayer
    | GeneratedFight SessionId ClientId FightInfo


type ToFrontend
    = YourCurrentWorld WorldLoggedInData
    | CurrentWorld WorldLoggedOutData
    | YourFightResult FightInfo
