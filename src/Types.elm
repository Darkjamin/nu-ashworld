module Types exposing (..)

import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Data.Auth exposing (Auth, Hashed)
import Data.Fight exposing (FightInfo)
import Data.Map exposing (TileCoords)
import Data.NewChar exposing (NewChar)
import Data.Player
    exposing
        ( Player
        , PlayerName
        , SPlayer
        )
import Data.Special exposing (SpecialType)
import Data.World
    exposing
        ( AdminData
        , World
        , WorldLoggedInData
        , WorldLoggedOutData
        )
import Dict exposing (Dict)
import Frontend.Route exposing (Route)
import Json.Encode as JE
import Lamdera exposing (ClientId, SessionId)
import Set exposing (Set)
import Time exposing (Posix)
import Url exposing (Url)


type alias FrontendModel =
    { key : Key
    , time : Time.Posix
    , zone : Time.Zone
    , route : Route
    , world : World
    , newChar : NewChar
    , authError : Maybe String
    , mapMouseCoords : Maybe ( TileCoords, Set TileCoords )
    }


type alias BackendModel =
    { players : Dict PlayerName (Player SPlayer)
    , loggedInPlayers : Dict ClientId PlayerName
    , nextWantedTick : Maybe Posix
    , adminLoggedIn : Maybe ( ClientId, SessionId )
    }


type FrontendMsg
    = UrlClicked UrlRequest
    | UrlChanged Url
    | GoToRoute Route
    | Logout
    | Login
    | Register
    | GotZone Time.Zone
    | GotTime Time.Posix
    | AskToFight PlayerName
    | AskToHeal
    | AskForExport
    | Refresh
    | AskToIncSpecial SpecialType
    | SetAuthName String
    | SetAuthPassword String
    | CreateChar
    | NewCharIncSpecial SpecialType
    | NewCharDecSpecial SpecialType
    | MapMouseAtCoords TileCoords
    | MapMouseOut
    | MapMouseClick


type ToBackend
    = LogMeIn (Auth Hashed)
    | RegisterMe (Auth Hashed)
    | CreateNewChar NewChar
    | LogMeOut
    | Fight PlayerName
    | HealMe
    | RefreshPlease
    | IncSpecial SpecialType
    | MoveTo TileCoords (Set TileCoords)
    | AdminToBackend AdminToBackend


type AdminToBackend
    = --| ImportJson JE.Value
      ExportJson


type BackendMsg
    = Connected SessionId ClientId
    | Disconnected SessionId ClientId
    | GeneratedFight ClientId SPlayer FightInfo
    | Tick Posix


type ToFrontend
    = YourCurrentWorld WorldLoggedInData
    | CurrentWorld WorldLoggedOutData
    | CurrentAdminData AdminData
    | YourFightResult ( FightInfo, WorldLoggedInData )
    | YoureLoggedIn WorldLoggedInData
    | YoureRegistered WorldLoggedInData
    | YouHaveCreatedChar WorldLoggedInData
    | YoureLoggedOut WorldLoggedOutData
    | AuthError String
    | YoureLoggedInAsAdmin AdminData
    | JsonExportDone String
