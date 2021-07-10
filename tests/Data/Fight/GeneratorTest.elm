module Data.Fight.GeneratorTest exposing (damageNeverNegative)

import Data.Fight as Fight
import Data.Fight.Generator
import Expect
import Fuzz
import Random
import Test exposing (Test)
import TestHelpers exposing (..)


damageNeverNegative : Test
damageNeverNegative =
    Test.fuzz3
        opponentFuzzer
        opponentFuzzer
        (Fuzz.map2 Tuple.pair
            posixFuzzer
            randomSeedFuzzer
        )
        "Damage in fight should never be negative"
    <|
        \attacker target ( currentTime, seed ) ->
            let
                _ =
                    Debug.log "attacker strat" attacker.fightStrategy

                ( fight, _ ) =
                    Random.step
                        (Data.Fight.Generator.generator
                            { attacker = attacker
                            , target = target
                            , currentTime = currentTime
                            }
                        )
                        seed
            in
            fight.fightInfo.log
                |> List.map (Tuple.second >> Fight.attackDamage)
                |> List.filter (\damage -> damage < 0)
                |> List.isEmpty
                |> Expect.true "Expected the list of negative damage actions in a fight to be empty"



-- TODO items in inventory decrease after finished fight where they were used
