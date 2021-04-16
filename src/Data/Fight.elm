module Data.Fight exposing
    ( FightAction(..)
    , FightInfo
    , FightResult(..)
    , Who(..)
    , encodeFightInfo
    , fightInfoDecoder
    , theOther
    )

import Data.Fight.ShotType as ShotType exposing (ShotType)
import Data.Player.PlayerName exposing (PlayerName)
import Json.Decode as JD exposing (Decoder)
import Json.Decode.Extra as JD
import Json.Encode as JE


type alias FightInfo =
    { attackerName : PlayerName
    , targetName : PlayerName
    , log : List ( Who, FightAction )
    , result : FightResult
    }


type FightResult
    = AttackerWon { xpGained : Int, capsGained : Int }
    | TargetWon { xpGained : Int, capsGained : Int }
    | TargetAlreadyDead
    | BothDead
    | NobodyDead


type Who
    = Attacker
    | Target


type FightAction
    = -- TODO later Reload, Heal, WalkAway, uncousciousness and other debuffs...
      Start { distanceHexes : Int }
    | ComeCloser
        { hexes : Int
        , remainingDistanceHexes : Int
        }
    | Attack
        { damage : Int
        , shotType : ShotType
        , remainingHp : Int
        }
    | Miss { shotType : ShotType }


theOther : Who -> Who
theOther who =
    case who of
        Attacker ->
            Target

        Target ->
            Attacker


fightInfoDecoder : Decoder FightInfo
fightInfoDecoder =
    let
        logItemDecoder : Decoder ( Who, FightAction )
        logItemDecoder =
            JD.map2 Tuple.pair
                (JD.field "who" whoDecoder)
                (JD.field "action" fightActionDecoder)
    in
    JD.succeed FightInfo
        |> JD.andMap (JD.field "attackerName" JD.string)
        |> JD.andMap (JD.field "targetName" JD.string)
        |> JD.andMap (JD.field "log" (JD.list logItemDecoder))
        |> JD.andMap (JD.field "result" fightResultDecoder)


encodeFightInfo : FightInfo -> JE.Value
encodeFightInfo info =
    let
        encodeLogItem : ( Who, FightAction ) -> JE.Value
        encodeLogItem ( who, action ) =
            JE.object
                [ ( "who", encodeWho who )
                , ( "action", encodeFightAction action )
                ]
    in
    JE.object
        [ ( "attackerName", JE.string info.attackerName )
        , ( "targetName", JE.string info.targetName )
        , ( "log", JE.list encodeLogItem info.log )
        , ( "result", encodeFightResult info.result )
        ]


encodeFightResult : FightResult -> JE.Value
encodeFightResult result =
    case result of
        AttackerWon r ->
            JE.object
                [ ( "type", JE.string "AttackerWon" )
                , ( "xpGained", JE.int r.xpGained )
                , ( "capsGained", JE.int r.capsGained )
                ]

        TargetWon r ->
            JE.object
                [ ( "type", JE.string "TargetWon" )
                , ( "xpGained", JE.int r.xpGained )
                , ( "capsGained", JE.int r.capsGained )
                ]

        TargetAlreadyDead ->
            JE.object [ ( "type", JE.string "TargetAlreadyDead" ) ]

        BothDead ->
            JE.object [ ( "type", JE.string "BothDead" ) ]

        NobodyDead ->
            JE.object [ ( "type", JE.string "NobodyDead" ) ]


fightResultDecoder : Decoder FightResult
fightResultDecoder =
    JD.field "type" JD.string
        |> JD.andThen
            (\type_ ->
                case type_ of
                    "AttackerWon" ->
                        JD.map2
                            (\xp caps ->
                                AttackerWon
                                    { xpGained = xp
                                    , capsGained = caps
                                    }
                            )
                            (JD.field "xpGained" JD.int)
                            (JD.field "capsGained" JD.int)

                    "TargetWon" ->
                        JD.map2
                            (\xp caps ->
                                TargetWon
                                    { xpGained = xp
                                    , capsGained = caps
                                    }
                            )
                            (JD.field "xpGained" JD.int)
                            (JD.field "capsGained" JD.int)

                    "TargetAlreadyDead" ->
                        JD.succeed TargetAlreadyDead

                    "BothDead" ->
                        JD.succeed BothDead

                    "NobodyDead" ->
                        JD.succeed NobodyDead

                    _ ->
                        JD.fail <| "Unknown FightResult: '" ++ type_ ++ "'"
            )


encodeWho : Who -> JE.Value
encodeWho who =
    case who of
        Attacker ->
            JE.string "attacker"

        Target ->
            JE.string "target"


whoDecoder : Decoder Who
whoDecoder =
    JD.string
        |> JD.andThen
            (\type_ ->
                case type_ of
                    "attacker" ->
                        JD.succeed Attacker

                    "target" ->
                        JD.succeed Target

                    _ ->
                        JD.fail <| "Unknown Who: '" ++ type_ ++ "'"
            )


encodeFightAction : FightAction -> JE.Value
encodeFightAction action =
    case action of
        Start r ->
            JE.object
                [ ( "type", JE.string "Start" )
                , ( "distanceHexes", JE.int r.distanceHexes )
                ]

        ComeCloser r ->
            JE.object
                [ ( "type", JE.string "ComeCloser" )
                , ( "hexes", JE.int r.hexes )
                , ( "remainingDistanceHexes", JE.int r.remainingDistanceHexes )
                ]

        Attack r ->
            JE.object
                [ ( "type", JE.string "Attack" )
                , ( "damage", JE.int r.damage )
                , ( "shotType", ShotType.encode r.shotType )
                , ( "remainingHp", JE.int r.remainingHp )
                ]

        Miss r ->
            JE.object
                [ ( "type", JE.string "Miss" )
                , ( "shotType", ShotType.encode r.shotType )
                ]


fightActionDecoder : Decoder FightAction
fightActionDecoder =
    JD.field "type" JD.string
        |> JD.andThen
            (\type_ ->
                case type_ of
                    "Start" ->
                        JD.field "distanceHexes" JD.int
                            |> JD.map (\distance -> Start { distanceHexes = distance })

                    "ComeCloser" ->
                        JD.map2
                            (\hexes remaining ->
                                ComeCloser
                                    { hexes = hexes
                                    , remainingDistanceHexes = remaining
                                    }
                            )
                            (JD.field "hexes" JD.int)
                            (JD.field "remainingDistanceHexes" JD.int)

                    "Attack" ->
                        JD.map3
                            (\damage shotType remainingHp ->
                                Attack
                                    { damage = damage
                                    , shotType = shotType
                                    , remainingHp = remainingHp
                                    }
                            )
                            (JD.field "damage" JD.int)
                            (JD.field "shotType" ShotType.decoder)
                            (JD.field "remainingHp" JD.int)

                    "Miss" ->
                        JD.field "shotType" ShotType.decoder
                            |> JD.map (\shotType -> Miss { shotType = shotType })

                    _ ->
                        JD.fail <| "Unknown FightAction: '" ++ type_ ++ "'"
            )
