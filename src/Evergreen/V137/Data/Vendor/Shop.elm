module Evergreen.V137.Data.Vendor.Shop exposing (..)

import Evergreen.V137.Data.Item
import Evergreen.V137.Random.FloatExtra
import SeqDict


type Shop
    = ArroyoHakunin
    | KlamathMaida
    | KlamathVic
    | DenFlick
    | ModocJo
    | VaultCityRandal
    | VaultCityHappyHarry
    | GeckoSurvivalGearPercy
    | ReddingAscorti
    | BrokenHillsGeneralStoreLiz
    | BrokenHillsChemistJacob
    | NewRenoArmsEldridge
    | NewRenoRenescoPharmacy
    | NCRBuster
    | NCRDuppo
    | SanFranciscoFlyingDragon8LaoChou
    | SanFranciscoRed888GunsMaiDaChiang
    | SanFranciscoPunksCal
    | SanFranciscoPunksJenna


type alias ShopSpec =
    { caps : Evergreen.V137.Random.FloatExtra.NormalIntSpec
    , stock :
        SeqDict.SeqDict
            Evergreen.V137.Data.Item.UniqueKey
            { maxCount : Int
            }
    }
