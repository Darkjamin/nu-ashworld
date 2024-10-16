module Data.Fight.GeneratorTest exposing (suite)

import Data.Fight as Fight exposing (Opponent)
import Data.Fight.AttackStyle as AttackStyle
import Data.Fight.Generator as FightGen exposing (Fight)
import Data.Fight.OpponentType as OpponentType
import Data.FightStrategy exposing (..)
import Data.Item.Kind as ItemKind
import Data.Special as Special
import Dict
import Expect
import Fuzz exposing (Fuzzer)
import Random
import SeqDict
import SeqSet
import Test exposing (Test)
import TestHelpers exposing (..)


suite : Test
suite =
    Test.describe "Data.Fight.Generator"
        [ Test.describe "generator"
            [ damageNeverNegative
            ]
        , Test.describe "attack_"
            [ meleeAttackSucceedsAtDistance2WithRange2
            , meleeAttackFailsAtDistance2WithRange1
            , rangedAttackFailsWithoutAmmoAndOutOfRange
            , rangedAttackSucceedsAtDistance15WithRange30
            , rangedAttackSucceedsWithWrongPreferredAmmo
            , rangedAttackUsesPreferredAmmo
            , rangedAttackUsesOnlyOnePieceOfAmmo
            , rangedAttackFailsAtDistance30WithRange7
            , unarmedAttackUsedWhenNoAmmoAndInRange
            , thrownAttackUsesUpWeapon
            ]
        ]


baseOpponent : Opponent
baseOpponent =
    { type_ = OpponentType.Player { name = "Opponent", xp = 0 }
    , hp = 100
    , maxHp = 100
    , maxAp = 10
    , sequence = 5
    , traits = SeqSet.empty
    , perks = SeqDict.empty
    , caps = 50
    , items = Dict.empty
    , drops = []
    , level = 1
    , equippedArmor = Nothing
    , equippedWeapon = Nothing
    , preferredAmmo = Nothing
    , naturalArmorClass = 5
    , addedSkillPercentages = SeqDict.empty
    , unarmedDamageBonus = 0
    , special = Special.init
    , fightStrategy = Command DoWhatever
    }


baseOngoingFight : Opponent -> FightGen.OngoingFight
baseOngoingFight opponent =
    { distanceHexes = 1
    , attacker = opponent
    , attackerAp = 10
    , attackerItemsUsed = SeqDict.empty
    , target = opponent
    , targetAp = 10
    , targetItemsUsed = SeqDict.empty
    , reverseLog = []
    , actionsTaken = 0
    }


damageNeverNegative : Test
damageNeverNegative =
    Test.fuzz randomFightFuzzer "Damage in fight should never be negative" <|
        \fight ->
            fight.fightInfo.log
                |> List.map (Tuple.second >> Fight.attackDamage)
                |> List.filter (\damage -> damage < 0)
                |> List.isEmpty
                |> Expect.equal True
                |> Expect.onFail "Expected the list of negative damage actions in a fight to be empty"


meleeAttackSucceedsAtDistance2WithRange2 : Test
meleeAttackSucceedsAtDistance2WithRange2 =
    Test.test "Melee combat at distance 2 with weapon with range 2 should work" <|
        \() ->
            let
                opponent =
                    { baseOpponent | equippedWeapon = Just ItemKind.SuperSledge }

                baseOngoingFight_ =
                    baseOngoingFight opponent

                ongoingFight =
                    { baseOngoingFight_ | distanceHexes = 2 }

                result =
                    Random.step
                        (FightGen.attack_
                            Fight.Attacker
                            ongoingFight
                            AttackStyle.MeleeUnaimed
                            4
                        )
                        (Random.initialSeed 3)
                        |> Tuple.first
            in
            result.ranCommandSuccessfully
                |> Expect.equal True
                |> Expect.onFail "Expected the attack to succeed"


meleeAttackFailsAtDistance2WithRange1 : Test
meleeAttackFailsAtDistance2WithRange1 =
    Test.test "Melee combat at distance 2 with weapon with range 1 shouldn't work" <|
        \() ->
            let
                opponent =
                    { baseOpponent | equippedWeapon = Just ItemKind.Wakizashi }

                baseOngoingFight_ =
                    baseOngoingFight opponent

                ongoingFight =
                    { baseOngoingFight_ | distanceHexes = 2 }

                result =
                    Random.step
                        (FightGen.attack_
                            Fight.Attacker
                            ongoingFight
                            AttackStyle.MeleeUnaimed
                            4
                        )
                        (Random.initialSeed 3)
                        |> Tuple.first
            in
            result.ranCommandSuccessfully
                |> Expect.equal False
                |> Expect.onFail "Expected the attack to fail"


rangedAttackFailsWithoutAmmoAndOutOfRange : Test
rangedAttackFailsWithoutAmmoAndOutOfRange =
    Test.test "Ranged attack fails without ammo and out of range" <|
        \() ->
            let
                opponent =
                    { baseOpponent
                        | equippedWeapon = Just ItemKind.RedRyderLEBBGun
                        , preferredAmmo = Nothing
                        , items = Dict.empty
                    }

                baseOngoingFight_ =
                    baseOngoingFight opponent

                ongoingFight =
                    { baseOngoingFight_ | distanceHexes = 15 }

                result =
                    Random.step
                        (FightGen.attack_
                            Fight.Attacker
                            ongoingFight
                            AttackStyle.ShootSingleUnaimed
                            4
                        )
                        (Random.initialSeed 3)
                        |> Tuple.first
            in
            result.ranCommandSuccessfully
                |> Expect.equal False
                |> Expect.onFail "Expected the attack to fail"


rangedAttackSucceedsAtDistance15WithRange30 : Test
rangedAttackSucceedsAtDistance15WithRange30 =
    Test.test "Ranged attack succeeds at distance 15 with range 30" <|
        \() ->
            let
                opponent =
                    { baseOpponent
                        | equippedWeapon = Just ItemKind.RedRyderLEBBGun
                        , preferredAmmo = Nothing
                        , items = Dict.singleton 1 { id = 1, kind = ItemKind.BBAmmo, count = 1 }
                    }

                baseOngoingFight_ =
                    baseOngoingFight opponent

                ongoingFight =
                    { baseOngoingFight_ | distanceHexes = 15 }

                result =
                    Random.step
                        (FightGen.attack_
                            Fight.Attacker
                            ongoingFight
                            AttackStyle.ShootSingleUnaimed
                            4
                        )
                        (Random.initialSeed 3)
                        |> Tuple.first
            in
            result.ranCommandSuccessfully
                |> Expect.equal True
                |> Expect.onFail "Expected the attack to succeed"


rangedAttackFailsAtDistance30WithRange7 : Test
rangedAttackFailsAtDistance30WithRange7 =
    Test.test "Ranged attack fails at distance 30 with range 7" <|
        \() ->
            let
                opponent =
                    { baseOpponent
                        | equippedWeapon = Just ItemKind.SawedOffShotgun
                        , preferredAmmo = Nothing
                        , items = Dict.singleton 1 { id = 1, kind = ItemKind.ShotgunShell, count = 1 }
                    }

                baseOngoingFight_ =
                    baseOngoingFight opponent

                ongoingFight =
                    { baseOngoingFight_ | distanceHexes = 30 }

                result =
                    Random.step
                        (FightGen.attack_
                            Fight.Attacker
                            ongoingFight
                            AttackStyle.ShootSingleUnaimed
                            4
                        )
                        (Random.initialSeed 3)
                        |> Tuple.first
            in
            result.ranCommandSuccessfully
                |> Expect.equal False
                |> Expect.onFail "Expected the attack to fail"


unarmedAttackUsedWhenNoAmmoAndInRange : Test
unarmedAttackUsedWhenNoAmmoAndInRange =
    Test.test "Unarmed attack used when no ammo and in range" <|
        \() ->
            let
                opponent =
                    { baseOpponent
                        | equippedWeapon = Just ItemKind.SawedOffShotgun
                        , preferredAmmo = Nothing
                        , items = Dict.empty
                    }

                baseOngoingFight_ =
                    baseOngoingFight opponent

                ongoingFight =
                    { baseOngoingFight_ | distanceHexes = 1 }

                result =
                    Random.step
                        (FightGen.attack_
                            Fight.Attacker
                            ongoingFight
                            AttackStyle.ShootSingleUnaimed
                            4
                        )
                        (Random.initialSeed 3)
                        |> Tuple.first
            in
            result.ranCommandSuccessfully
                |> Expect.equal True
                |> Expect.onFail "Expected the attack to succeed"


thrownAttackUsesUpWeapon : Test
thrownAttackUsesUpWeapon =
    Test.test "Thrown attack uses up weapon" <|
        \() ->
            let
                opponent =
                    { baseOpponent
                        | equippedWeapon = Just ItemKind.FragGrenade
                        , preferredAmmo = Nothing
                        , items =
                            Dict.fromList
                                [ ( 1, { id = 1, kind = ItemKind.FragGrenade, count = 1 } )
                                ]
                    }

                baseOngoingFight_ =
                    baseOngoingFight opponent

                ongoingFight =
                    { baseOngoingFight_ | distanceHexes = 10 }

                result =
                    Random.step
                        (FightGen.attack_
                            Fight.Attacker
                            ongoingFight
                            AttackStyle.Throw
                            4
                        )
                        (Random.initialSeed 3)
                        |> Tuple.first
            in
            result
                |> Expect.all
                    [ \r ->
                        r.ranCommandSuccessfully
                            |> Expect.equal True
                            |> Expect.onFail "Expected the attack to succeed"
                    , \r ->
                        r.nextOngoing.attackerItemsUsed
                            |> SeqDict.member ItemKind.FragGrenade
                            |> Expect.equal True
                            |> Expect.onFail "Expected the attack to add the thrown weapon to attackerItemsUsed"
                    , \r ->
                        r.nextOngoing.attacker.items
                            |> Dict.filter (\_ { kind } -> kind == ItemKind.FragGrenade)
                            |> Dict.isEmpty
                            |> Expect.equal True
                            |> Expect.onFail "Expected the attack to result in FragGrenade not being in attacker's inventory"
                    ]


rangedAttackSucceedsWithWrongPreferredAmmo : Test
rangedAttackSucceedsWithWrongPreferredAmmo =
    Test.test "Ranged attack succeeds with wrong preferred ammo" <|
        \() ->
            let
                opponent =
                    { baseOpponent
                        | equippedWeapon = Just ItemKind.RedRyderLEBBGun
                        , preferredAmmo = Just ItemKind.Ap10mm -- This shouldn't ever happen in game but let's test it anyway
                        , items =
                            Dict.fromList
                                [ ( 1, { id = 1, kind = ItemKind.BBAmmo, count = 1 } )
                                , ( 2, { id = 2, kind = ItemKind.Ap10mm, count = 1 } )
                                ]
                    }

                baseOngoingFight_ =
                    baseOngoingFight opponent

                ongoingFight =
                    { baseOngoingFight_ | distanceHexes = 15 }

                result =
                    Random.step
                        (FightGen.attack_
                            Fight.Attacker
                            ongoingFight
                            AttackStyle.ShootSingleUnaimed
                            4
                        )
                        (Random.initialSeed 3)
                        |> Tuple.first
            in
            result.ranCommandSuccessfully
                |> Expect.equal True
                |> Expect.onFail "Expected the attack to succeed"


rangedAttackUsesPreferredAmmo : Test
rangedAttackUsesPreferredAmmo =
    Test.test "Ranged attack uses the preferred ammo" <|
        \() ->
            let
                opponent =
                    { baseOpponent
                        | equippedWeapon = Just ItemKind.Smg10mm
                        , preferredAmmo = Just ItemKind.Ap10mm
                        , items =
                            Dict.fromList
                                [ ( 1, { id = 1, kind = ItemKind.Jhp10mm, count = 1 } )
                                , ( 2, { id = 2, kind = ItemKind.Ap10mm, count = 1 } )
                                ]
                    }

                baseOngoingFight_ =
                    baseOngoingFight opponent

                ongoingFight =
                    { baseOngoingFight_ | distanceHexes = 15 }

                result =
                    Random.step
                        (FightGen.attack_
                            Fight.Attacker
                            ongoingFight
                            AttackStyle.ShootSingleUnaimed
                            4
                        )
                        (Random.initialSeed 3)
                        |> Tuple.first
            in
            result
                |> Expect.all
                    [ \r ->
                        r.nextOngoing.attackerItemsUsed
                            |> SeqDict.member ItemKind.Ap10mm
                            |> Expect.equal True
                            |> Expect.onFail "Expected the attack to add the preferred ammo to attackerItemsUsed"
                    , \r ->
                        r.nextOngoing.attacker.items
                            |> Dict.filter (\_ { kind } -> kind == ItemKind.Ap10mm)
                            |> Dict.isEmpty
                            |> Expect.equal True
                            |> Expect.onFail "Expected the attack to result in Ap10mm not being in attacker's inventory"
                    , \r ->
                        r.nextOngoing.attacker.preferredAmmo
                            |> Expect.equal Nothing
                            |> Expect.onFail "Expected the preferred ammo to be unset after it's used up"
                    ]


rangedAttackUsesOnlyOnePieceOfAmmo : Test
rangedAttackUsesOnlyOnePieceOfAmmo =
    Test.test "Ranged attack uses only one piece of ammo" <|
        \() ->
            let
                opponent =
                    { baseOpponent
                        | equippedWeapon = Just ItemKind.Smg10mm
                        , preferredAmmo = Just ItemKind.Jhp10mm
                        , items =
                            Dict.fromList
                                [ ( 1, { id = 1, kind = ItemKind.Jhp10mm, count = 5 } )
                                ]
                    }

                baseOngoingFight_ =
                    baseOngoingFight opponent

                ongoingFight =
                    { baseOngoingFight_ | distanceHexes = 15 }

                result =
                    Random.step
                        (FightGen.attack_
                            Fight.Attacker
                            ongoingFight
                            AttackStyle.ShootSingleUnaimed
                            4
                        )
                        (Random.initialSeed 3)
                        |> Tuple.first
            in
            result
                |> Expect.all
                    [ \r ->
                        r.nextOngoing.attackerItemsUsed
                            |> SeqDict.member ItemKind.Jhp10mm
                            |> Expect.equal True
                            |> Expect.onFail "Expected the attack to add the preferred ammo to attackerItemsUsed"
                    , \r ->
                        r.nextOngoing.attacker.items
                            |> Dict.filter (\_ { kind } -> kind == ItemKind.Jhp10mm)
                            |> Dict.values
                            |> Expect.equal [ { id = 1, kind = ItemKind.Jhp10mm, count = 4 } ]
                            |> Expect.onFail "Expected the attack to result in Jhp10mm still being in attacker's inventory, just one less"
                    , \r ->
                        r.nextOngoing.attacker.preferredAmmo
                            |> Expect.equal (Just ItemKind.Jhp10mm)
                            |> Expect.onFail "Expected the preferred ammo still be set if we still have some in the inventory"
                    ]


fightFuzzer :
    { attacker : Fuzzer Opponent
    , target : Fuzzer Opponent
    }
    -> Fuzzer Fight
fightFuzzer r =
    Fuzz.constant
        (\a t currentTime seed ->
            Random.step
                (FightGen.generator
                    { attacker = a
                    , target = t
                    , currentTime = currentTime
                    }
                )
                seed
        )
        |> Fuzz.andMap r.attacker
        |> Fuzz.andMap r.target
        |> Fuzz.andMap posixFuzzer
        |> Fuzz.andMap randomSeedFuzzer
        |> Fuzz.map Tuple.first


randomFightFuzzer : Fuzzer Fight
randomFightFuzzer =
    fightFuzzer
        { attacker = opponentFuzzer
        , target = opponentFuzzer
        }
