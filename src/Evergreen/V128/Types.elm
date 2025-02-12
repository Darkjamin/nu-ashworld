module Evergreen.V128.Types exposing (..)

import BiDict
import Browser
import Browser.Navigation
import Dict
import Evergreen.V128.Data.Auth
import Evergreen.V128.Data.Barter
import Evergreen.V128.Data.Fight
import Evergreen.V128.Data.FightStrategy
import Evergreen.V128.Data.Item
import Evergreen.V128.Data.Item.Kind
import Evergreen.V128.Data.Map
import Evergreen.V128.Data.Message
import Evergreen.V128.Data.NewChar
import Evergreen.V128.Data.Perk
import Evergreen.V128.Data.Player
import Evergreen.V128.Data.Player.PlayerName
import Evergreen.V128.Data.Quest
import Evergreen.V128.Data.Skill
import Evergreen.V128.Data.Special
import Evergreen.V128.Data.Trait
import Evergreen.V128.Data.Vendor.Shop
import Evergreen.V128.Data.World
import Evergreen.V128.Data.WorldData
import Evergreen.V128.Data.WorldInfo
import Evergreen.V128.Frontend.HoveredItem
import Evergreen.V128.Frontend.Route
import File
import Lamdera
import Queue
import Random
import SeqSet
import Set
import Time
import Url


type AdminToBackend
    = ExportJson
    | ImportJson String
    | CreateNewWorld String Bool
    | ChangeWorldSpeed
        { world : Evergreen.V128.Data.World.Name
        , fast : Bool
        }


type ToBackend
    = LogMeIn (Evergreen.V128.Data.Auth.Auth Evergreen.V128.Data.Auth.Hashed)
    | SignMeUp (Evergreen.V128.Data.Auth.Auth Evergreen.V128.Data.Auth.Hashed)
    | CreateNewChar Evergreen.V128.Data.NewChar.NewChar
    | LogMeOut
    | Fight Evergreen.V128.Data.Player.PlayerName.PlayerName
    | HealMe
    | UseItem Evergreen.V128.Data.Item.Id
    | Wander
    | EquipArmor Evergreen.V128.Data.Item.Id
    | EquipWeapon Evergreen.V128.Data.Item.Id
    | PreferAmmo Evergreen.V128.Data.Item.Kind.Kind
    | SetFightStrategy ( Evergreen.V128.Data.FightStrategy.FightStrategy, String )
    | UnequipArmor
    | UnequipWeapon
    | ClearPreferredAmmo
    | RefreshPlease
    | WorldsPlease
    | TagSkill Evergreen.V128.Data.Skill.Skill
    | UseSkillPoints Evergreen.V128.Data.Skill.Skill
    | ChoosePerk Evergreen.V128.Data.Perk.Perk
    | MoveTo Evergreen.V128.Data.Map.TileCoords (Set.Set Evergreen.V128.Data.Map.TileCoords)
    | MessageWasRead Evergreen.V128.Data.Message.Id
    | RemoveMessage Evergreen.V128.Data.Message.Id
    | RemoveFightMessages
    | RemoveAllMessages
    | Barter Evergreen.V128.Data.Barter.State Evergreen.V128.Data.Vendor.Shop.Shop
    | AdminToBackend AdminToBackend
    | StopProgressing Evergreen.V128.Data.Quest.Name
    | StartProgressing Evergreen.V128.Data.Quest.Name
    | RefuelCar Evergreen.V128.Data.Item.Kind.Kind


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , route : Evergreen.V128.Frontend.Route.Route
    , time : Time.Posix
    , zone : Time.Zone
    , loginForm : Evergreen.V128.Data.Auth.Auth Evergreen.V128.Data.Auth.Plaintext
    , worlds : Maybe (List Evergreen.V128.Data.WorldInfo.WorldInfo)
    , worldData : Evergreen.V128.Data.WorldData.WorldData
    , alertMessage : Maybe String
    , newChar : Evergreen.V128.Data.NewChar.NewChar
    , mapMouseCoords :
        Maybe
            { coords : Evergreen.V128.Data.Map.TileCoords
            , path : Set.Set Evergreen.V128.Data.Map.TileCoords
            }
    , hoveredItem : Maybe Evergreen.V128.Frontend.HoveredItem.HoveredItem
    , fightInfo : Maybe Evergreen.V128.Data.Fight.Info
    , barter : Evergreen.V128.Data.Barter.State
    , fightStrategyText : String
    , expandedQuests : SeqSet.SeqSet Evergreen.V128.Data.Quest.Name
    , userWantsToShowAreaDanger : Bool
    , lastGuideTocSectionClick : Int
    , hoveredGuideNavLink : Bool
    , lastTenToBackendMsgs : List ( Evergreen.V128.Data.Player.PlayerName.PlayerName, Evergreen.V128.Data.World.Name, ToBackend )
    , adminNewWorldName : String
    , adminNewWorldFast : Bool
    }


type alias BackendModel =
    { worlds : Dict.Dict Evergreen.V128.Data.World.Name Evergreen.V128.Data.World.World
    , time : Time.Posix
    , loggedInPlayers : BiDict.BiDict Lamdera.ClientId ( Evergreen.V128.Data.World.Name, Evergreen.V128.Data.Player.PlayerName.PlayerName )
    , adminLoggedIn : Maybe ( Lamdera.ClientId, Lamdera.SessionId )
    , lastTenToBackendMsgs : Queue.Queue ( Evergreen.V128.Data.Player.PlayerName.PlayerName, Evergreen.V128.Data.World.Name, ToBackend )
    , randomSeed : Random.Seed
    , playerDataCache : Dict.Dict Lamdera.ClientId Int
    }


type BarterMsg
    = AddPlayerItem Evergreen.V128.Data.Item.Id Int
    | AddVendorItem Evergreen.V128.Data.Item.Id Int
    | AddPlayerCaps Int
    | AddVendorCaps Int
    | RemovePlayerItem Evergreen.V128.Data.Item.Id Int
    | RemoveVendorItem Evergreen.V128.Data.Item.Id Int
    | RemovePlayerCaps Int
    | RemoveVendorCaps Int
    | ResetBarter
    | ConfirmBarter Evergreen.V128.Data.Vendor.Shop.Shop
    | SetTransferNInput Evergreen.V128.Data.Barter.TransferNPosition String
    | SetTransferNActive Evergreen.V128.Data.Barter.TransferNPosition
    | UnsetTransferNActive


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GoToRoute Evergreen.V128.Frontend.Route.Route
    | GoToTownStore Evergreen.V128.Data.Vendor.Shop.Shop
    | Logout
    | Login
    | SignUp
    | GotZone Time.Zone
    | GotTime Time.Posix
    | AskToFight Evergreen.V128.Data.Player.PlayerName.PlayerName
    | AskToHeal
    | AskToUseItem Evergreen.V128.Data.Item.Id
    | AskToWander
    | AskToChoosePerk Evergreen.V128.Data.Perk.Perk
    | AskToEquipArmor Evergreen.V128.Data.Item.Id
    | AskToEquipWeapon Evergreen.V128.Data.Item.Id
    | AskToPreferAmmo Evergreen.V128.Data.Item.Kind.Kind
    | AskToUnequipArmor
    | AskToUnequipWeapon
    | AskToClearPreferredAmmo
    | AskToSetFightStrategy ( Evergreen.V128.Data.FightStrategy.FightStrategy, String )
    | AskForExport
    | ImportButtonClicked
    | ImportFileSelected File.File
    | AskToImport String
    | Refresh
    | AskForWorldsAndGoToWorldsRoute
    | AskToTagSkill Evergreen.V128.Data.Skill.Skill
    | AskToUseSkillPoints Evergreen.V128.Data.Skill.Skill
    | SetAuthName String
    | SetAuthPassword String
    | SetAuthWorld String
    | CreateChar
    | NewCharIncSpecial Evergreen.V128.Data.Special.Type
    | NewCharDecSpecial Evergreen.V128.Data.Special.Type
    | NewCharToggleTaggedSkill Evergreen.V128.Data.Skill.Skill
    | NewCharToggleTrait Evergreen.V128.Data.Trait.Trait
    | MapMouseAtCoords Evergreen.V128.Data.Map.TileCoords
    | MapMouseOut
    | MapMouseClick
    | SetShowAreaDanger Bool
    | OpenMessage Evergreen.V128.Data.Message.Id
    | AskToRemoveMessage Evergreen.V128.Data.Message.Id
    | AskToRemoveFightMessages
    | AskToRemoveAllMessages
    | BarterMsg BarterMsg
    | HoverItem Evergreen.V128.Frontend.HoveredItem.HoveredItem
    | StopHoveringItem
    | SetFightStrategyText String
    | SetAdminNewWorldName String
    | SetAdminNewWorldFast Bool
    | AskToCreateNewWorld
    | ExpandQuestItem Evergreen.V128.Data.Quest.Name
    | CollapseQuestItem Evergreen.V128.Data.Quest.Name
    | AskToStopProgressing Evergreen.V128.Data.Quest.Name
    | AskToStartProgressing Evergreen.V128.Data.Quest.Name
    | ScrolledToGuideSection String
    | ClickedGuideSection Int
    | HoveredGuideNavLink
    | AskToRefuelCar Evergreen.V128.Data.Item.Kind.Kind
    | AskToChangeWorldSpeed
        { world : Evergreen.V128.Data.World.Name
        , fast : Bool
        }


type BackendMsg
    = Connected Lamdera.SessionId Lamdera.ClientId
    | Disconnected Lamdera.SessionId Lamdera.ClientId
    | FirstTick Time.Posix
    | Tick Time.Posix
    | CreateNewCharWithTime Lamdera.ClientId Evergreen.V128.Data.NewChar.NewChar Time.Posix
    | LoggedToBackendMsg


type ToFrontend
    = CurrentPlayer Evergreen.V128.Data.WorldData.PlayerData
    | CurrentOtherPlayers (List Evergreen.V128.Data.Player.COtherPlayer)
    | CurrentWorlds (List Evergreen.V128.Data.WorldInfo.WorldInfo)
    | CurrentAdmin Evergreen.V128.Data.WorldData.AdminData
    | CurrentAdminLoggedInPlayers (Dict.Dict Evergreen.V128.Data.World.Name (List Evergreen.V128.Data.Player.PlayerName.PlayerName))
    | CurrentAdminLastTenToBackendMsgs (List ( Evergreen.V128.Data.Player.PlayerName.PlayerName, Evergreen.V128.Data.World.Name, ToBackend ))
    | YoureLoggedOut (List Evergreen.V128.Data.WorldInfo.WorldInfo)
    | YourFightResult ( Evergreen.V128.Data.Fight.Info, Evergreen.V128.Data.WorldData.PlayerData )
    | YoureLoggedInSigningUp
    | YoureLoggedIn Evergreen.V128.Data.WorldData.PlayerData
    | YoureSignedUp
    | CharCreationError Evergreen.V128.Data.NewChar.CreationError
    | YouHaveCreatedChar Evergreen.V128.Data.Player.CPlayer Evergreen.V128.Data.WorldData.PlayerData
    | AlertMessage String
    | YoureLoggedInAsAdmin Evergreen.V128.Data.WorldData.AdminData
    | JsonExportDone String
    | BarterDone ( Evergreen.V128.Data.WorldData.PlayerData, Maybe Evergreen.V128.Data.Barter.Message )
    | BarterMessage Evergreen.V128.Data.Barter.Message
    | YourMessages (Dict.Dict Evergreen.V128.Data.Message.Id Evergreen.V128.Data.Message.Message)
