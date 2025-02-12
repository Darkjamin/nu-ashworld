module Data.Special exposing
    ( Special
    , Type(..)
    , all
    , canDecrement
    , canIncrement
    , codec
    , decrement
    , decrementNewChar
    , description
    , fromList
    , get
    , increment
    , init
    , isInRange
    , isValueInRange
    , label
    , mapWithoutClamp
    , set
    , sum
    , toList
    )

import Codec exposing (Codec)


type alias Special =
    { strength : Int
    , perception : Int
    , endurance : Int
    , charisma : Int
    , intelligence : Int
    , agility : Int
    , luck : Int
    }


type Type
    = Strength
    | Perception
    | Endurance
    | Charisma
    | Intelligence
    | Agility
    | Luck


label : Type -> String
label type_ =
    case type_ of
        Strength ->
            "Strength"

        Perception ->
            "Perception"

        Endurance ->
            "Endurance"

        Charisma ->
            "Charisma"

        Intelligence ->
            "Intelligence"

        Agility ->
            "Agility"

        Luck ->
            "Luck"


all : List Type
all =
    [ Strength
    , Perception
    , Endurance
    , Charisma
    , Intelligence
    , Agility
    , Luck
    ]


get : Type -> (Special -> Int)
get type_ =
    case type_ of
        Strength ->
            .strength

        Perception ->
            .perception

        Endurance ->
            .endurance

        Charisma ->
            .charisma

        Intelligence ->
            .intelligence

        Agility ->
            .agility

        Luck ->
            .luck


canIncrement : Int -> Type -> Special -> Bool
canIncrement availablePoints type_ special =
    availablePoints > 0 && get type_ special < 10


canDecrement : Type -> Special -> Bool
canDecrement type_ special =
    get type_ special > 1


increment : Type -> Special -> Special
increment =
    map (\x -> x + 1)


decrement : Type -> Special -> Special
decrement =
    map (\x -> x - 1)


{-| NewChar Special can go below 0.
Imagine this sequence:

  - Select traits Bruiser and Gifted (= +3 Strength)
  - decrement Strength so that after traits it's 1
  - it's "real" value is -2

-}
decrementNewChar : Type -> Special -> Special
decrementNewChar =
    mapWithoutClamp (\x -> x - 1)


set : Type -> Int -> Special -> Special
set type_ value special =
    map (always value) type_ special


mapWithoutClamp : (Int -> Int) -> Type -> Special -> Special
mapWithoutClamp =
    map_ { shouldClamp = False }


map : (Int -> Int) -> Type -> Special -> Special
map =
    map_ { shouldClamp = True }


map_ : { shouldClamp : Bool } -> (Int -> Int) -> Type -> Special -> Special
map_ { shouldClamp } fn type_ special =
    let
        clampedFn : Int -> Int
        clampedFn =
            if shouldClamp then
                clamp 1 10 << fn

            else
                fn
    in
    case type_ of
        Strength ->
            { special | strength = clampedFn special.strength }

        Perception ->
            { special | perception = clampedFn special.perception }

        Endurance ->
            { special | endurance = clampedFn special.endurance }

        Charisma ->
            { special | charisma = clampedFn special.charisma }

        Intelligence ->
            { special | intelligence = clampedFn special.intelligence }

        Agility ->
            { special | agility = clampedFn special.agility }

        Luck ->
            { special | luck = clampedFn special.luck }


init : Special
init =
    Special 5 5 5 5 5 5 5


isInRange : Special -> Bool
isInRange special =
    let
        isTypeInRange : Type -> Bool
        isTypeInRange type_ =
            let
                value : Int
                value =
                    get type_ special
            in
            isValueInRange value
    in
    List.all isTypeInRange all


isValueInRange : Int -> Bool
isValueInRange value =
    value >= 1 && value <= 10


sum : Special -> Int
sum special =
    List.sum <| List.map (\t -> get t special) all


description : Type -> String
description type_ =
    case type_ of
        Strength ->
            """Raw physical strength. A high Strength is good for physical characters.

Affects:

- max HP
- Unarmed, Melee Weapons skill %
- unarmed and melee damage
- required to handle weapons effectively
"""

        Perception ->
            """The ability to see, hear, taste and notice unusual things. A high Perception is important for a sharpshooter.

Affects:

- perception level (fights/ladder/map awareness and effective movement)
- ranged distance penalty
- ranged chance to hit
- sequence
- First Aid, Doctor, Lockpick, Traps skill %
"""

        Endurance ->
            """Stamina and physical toughness. A character with a high Endurance will survive where others may not.

Affects:

- max HP
- tick heal percentage
- mitigation of critical attacks
- Outdoorsman skill %
"""

        Charisma ->
            """A combination of appearance and charm. A high Charisma is important for characters that want to influence people with words.

Affects:

- Speech, Barter skill %
"""

        Intelligence ->
            """Knowledge, wisdom and the ability to think quickly. A high Intelligence is important for any character.

Affects:

- skill points gained per level
- book use tick cost
- First Aid, Doctor, Science, Repair, Outdoorsman skill %
"""

        Agility ->
            """Coordination and the ability to move well. A high Agility is important for any active character.

Affects:

- armor class
- unarmed damage
- mitigation of critical attacks
- Small Guns, Big Guns, Energy Weapons, Unarmed, Melee Weapons, Throwing, Sneak, Lockpick, Steal, Traps skill %
"""

        Luck ->
            """Fate. Karma. An extremely high or low Luck will affect the character - somehow. Events and situations will be changed by how lucky (or unlucky) your character is.

Affects:

- critical chance
- mitigation of critical attacks
- Gambling skill % (currently unused)
"""


toList : Special -> List Int
toList special =
    [ special.strength
    , special.perception
    , special.endurance
    , special.charisma
    , special.intelligence
    , special.agility
    , special.luck
    ]


fromList : List Int -> Maybe Special
fromList list =
    case list of
        [ strength, perception, endurance, charisma, intelligence, agility, luck ] ->
            Just
                { strength = strength
                , perception = perception
                , endurance = endurance
                , charisma = charisma
                , intelligence = intelligence
                , agility = agility
                , luck = luck
                }

        _ ->
            Nothing


codec : Codec Special
codec =
    Codec.object Special
        |> Codec.field "strength" .strength Codec.int
        |> Codec.field "perception" .perception Codec.int
        |> Codec.field "endurance" .endurance Codec.int
        |> Codec.field "charisma" .charisma Codec.int
        |> Codec.field "intelligence" .intelligence Codec.int
        |> Codec.field "agility" .agility Codec.int
        |> Codec.field "luck" .luck Codec.int
        |> Codec.buildObject
