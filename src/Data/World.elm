module Data.World exposing (Info, Name, World, decoder, encode)

import AssocList as Dict_
import Data.Message as Message
import Data.Player as Player
    exposing
        ( Player
        , SPlayer
        )
import Data.Player.PlayerName exposing (PlayerName)
import Data.Tick as Tick exposing (TickPerIntervalCurve(..))
import Data.Vendor as Vendor exposing (Vendor)
import Dict exposing (Dict)
import Iso8601
import Json.Decode as JD exposing (Decoder)
import Json.Encode as JE
import Json.Encode.Extra as JEE
import Lamdera exposing (ClientId, SessionId)
import List.ExtraExtra as List
import Time exposing (Posix)
import Time.Extra as Time
import Time.ExtraExtra as Time


type alias Name =
    String


type alias Info =
    { name : String
    , description : String
    , playersCount : Int
    , startedAt : Posix
    }


type alias World =
    { players : Dict PlayerName (Player SPlayer)
    , nextWantedTick : Maybe Posix
    , vendors : Dict_.Dict Vendor.Name Vendor
    , lastItemId : Int
    , description : String
    , startedAt : Posix
    , tickFrequency : Time.Interval
    , tickPerIntervalCurve : TickPerIntervalCurve
    , vendorRestockFrequency : Time.Interval
    }


encode : World -> JE.Value
encode world =
    JE.object
        [ ( "players"
          , world.players
                |> Dict.values
                |> JE.list (Player.encode Player.encodeSPlayer)
          )
        , ( "nextWantedTick", JEE.maybe Iso8601.encode world.nextWantedTick )
        , ( "vendors", Vendor.encodeVendors world.vendors )
        , ( "description", JE.string world.description )
        , ( "startedAt", Iso8601.encode world.startedAt )
        , ( "tickFrequency", Time.encodeInterval world.tickFrequency )
        , ( "tickPerIntervalCurve", Tick.encodeCurve world.tickPerIntervalCurve )
        , ( "vendorRestockFrequency", Time.encodeInterval world.vendorRestockFrequency )
        ]


lastItemId : Dict PlayerName (Player SPlayer) -> Dict_.Dict Vendor.Name Vendor -> Int
lastItemId players vendors =
    let
        lastPlayersItemId : Int
        lastPlayersItemId =
            players
                |> Dict.values
                |> List.filterMap Player.getPlayerData
                |> List.fastConcatMap (.items >> Dict.keys)
                |> List.maximum
                |> Maybe.withDefault 0

        lastVendorsItemId : Int
        lastVendorsItemId =
            vendors
                |> Dict_.values
                |> List.fastConcatMap (.items >> Dict.keys)
                |> List.maximum
                |> Maybe.withDefault 0
    in
    max lastPlayersItemId lastVendorsItemId


decoder : Decoder World
decoder =
    JD.oneOf
        [ decoderV3
        , decoderV2
        , decoderV1
        ]


{-| init version
-}
decoderV1 : Decoder World
decoderV1 =
    JD.map2
        (\players nextWantedTick ->
            let
                vendors =
                    Vendor.emptyVendors
            in
            { players = players
            , nextWantedTick = nextWantedTick
            , vendors = vendors
            , lastItemId = lastItemId players vendors
            , description = ""
            , startedAt = Time.millisToPosix 0
            , tickFrequency = Time.Hour
            , tickPerIntervalCurve = QuarterAndRest { quarter = 4, rest = 2 }
            , vendorRestockFrequency = Time.Hour
            }
        )
        (JD.field "players"
            (JD.list
                (Player.decoder Player.sPlayerDecoder
                    |> JD.map (\player -> ( Player.getAuth player |> .name, player ))
                )
                |> JD.map Dict.fromList
            )
        )
        (JD.field "nextWantedTick" (JD.maybe Iso8601.decoder))


{-| adds "vendors" field
-}
decoderV2 : Decoder World
decoderV2 =
    JD.map3
        (\players nextWantedTick vendors ->
            { players = players
            , nextWantedTick = nextWantedTick
            , vendors = vendors
            , lastItemId = lastItemId players vendors
            , description = ""
            , startedAt = Time.millisToPosix 0
            , tickFrequency = Time.Hour
            , tickPerIntervalCurve = QuarterAndRest { quarter = 4, rest = 2 }
            , vendorRestockFrequency = Time.Hour
            }
        )
        (JD.field "players"
            (JD.list
                (Player.decoder Player.sPlayerDecoder
                    |> JD.map (\player -> ( Player.getAuth player |> .name, player ))
                )
                |> JD.map Dict.fromList
            )
        )
        (JD.field "nextWantedTick" (JD.maybe Iso8601.decoder))
        (JD.field "vendors" Vendor.vendorsDecoder)


{-| adds "description", "startedAt", "tickFrequency", "tickPerIntervalCurve", "vendorRestockFrequency" fields
-}
decoderV3 : Decoder World
decoderV3 =
    JD.map8
        (\players nextWantedTick vendors description startedAt tickFrequency tickPerIntervalCurve vendorRestockFrequency ->
            { players = players
            , nextWantedTick = nextWantedTick
            , vendors = vendors
            , lastItemId = lastItemId players vendors
            , description = description
            , startedAt = startedAt
            , tickFrequency = tickFrequency
            , tickPerIntervalCurve = tickPerIntervalCurve
            , vendorRestockFrequency = vendorRestockFrequency
            }
        )
        (JD.field "players"
            (JD.list
                (Player.decoder Player.sPlayerDecoder
                    |> JD.map (\player -> ( Player.getAuth player |> .name, player ))
                )
                |> JD.map Dict.fromList
            )
        )
        (JD.field "nextWantedTick" (JD.maybe Iso8601.decoder))
        (JD.field "vendors" Vendor.vendorsDecoder)
        (JD.field "description" JD.string)
        (JD.field "startedAt" Iso8601.decoder)
        (JD.field "tickFrequency" Time.intervalDecoder)
        (JD.field "tickPerIntervalCurve" Tick.curveDecoder)
        (JD.field "vendorRestockFrequency" Time.intervalDecoder)
