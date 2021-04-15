module Data.Barter exposing
    ( ArrowsDirection(..)
    , Problem(..)
    , State
    , TransferNPosition(..)
    , addPlayerCaps
    , addPlayerItem
    , addVendorCaps
    , addVendorItem
    , arrowsDirection
    , defaultTransferN
    , dismissProblem
    , doubleArrow
    , empty
    , problemText
    , removePlayerCaps
    , removePlayerItem
    , removeVendorCaps
    , removeVendorItem
    , setProblem
    , setTransferNHover
    , setTransferNInput
    , singleArrow
    , unsetTransferNHover
    )

import AssocList as Dict_
import Data.Item as Item
import Dict exposing (Dict)


type Problem
    = BarterIsEmpty
    | PlayerOfferNotValuableEnough


type TransferNPosition
    = PlayerKeptItem Item.Id
    | VendorKeptItem Item.Id
    | PlayerTradedItem Item.Id
    | VendorTradedItem Item.Id
    | PlayerKeptCaps
    | VendorKeptCaps
    | PlayerTradedCaps
    | VendorTradedCaps


type alias State =
    { playerItems : Dict Item.Id Int
    , vendorItems : Dict Item.Id Int
    , playerCaps : Int
    , vendorCaps : Int
    , lastProblem : Maybe Problem
    , transferNInputs : Dict_.Dict TransferNPosition String
    , transferNHover : Maybe TransferNPosition
    }


empty : State
empty =
    { playerItems = Dict.empty
    , vendorItems = Dict.empty
    , playerCaps = 0
    , vendorCaps = 0
    , lastProblem = Nothing
    , transferNInputs = Dict_.empty
    , transferNHover = Nothing
    }


addVendorItem : Item.Id -> Int -> State -> State
addVendorItem id count state =
    { state
        | vendorItems =
            state.vendorItems
                |> Dict.update id
                    (\maybeExistingCount ->
                        case maybeExistingCount of
                            Nothing ->
                                Just count

                            Just existingCount ->
                                Just <| existingCount + count
                    )
    }


addPlayerItem : Item.Id -> Int -> State -> State
addPlayerItem id count state =
    { state
        | playerItems =
            state.playerItems
                |> Dict.update id
                    (\maybeExistingCount ->
                        case maybeExistingCount of
                            Nothing ->
                                Just count

                            Just existingCount ->
                                Just <| existingCount + count
                    )
    }


removePlayerItem : Item.Id -> Int -> State -> State
removePlayerItem id count state =
    { state
        | playerItems =
            state.playerItems
                |> Dict.update id
                    (\maybeExistingCount ->
                        case maybeExistingCount of
                            Nothing ->
                                Nothing

                            Just existingCount ->
                                let
                                    newCount =
                                        existingCount - count
                                in
                                if newCount <= 0 then
                                    Nothing

                                else
                                    Just newCount
                    )
    }


removeVendorItem : Item.Id -> Int -> State -> State
removeVendorItem id count state =
    { state
        | vendorItems =
            state.vendorItems
                |> Dict.update id
                    (\maybeExistingCount ->
                        case maybeExistingCount of
                            Nothing ->
                                Nothing

                            Just existingCount ->
                                let
                                    newCount =
                                        existingCount - count
                                in
                                if newCount <= 0 then
                                    Nothing

                                else
                                    Just newCount
                    )
    }


addPlayerCaps : Int -> State -> State
addPlayerCaps amount state =
    { state | playerCaps = state.playerCaps + amount }


removePlayerCaps : Int -> State -> State
removePlayerCaps amount state =
    { state | playerCaps = state.playerCaps - amount }


addVendorCaps : Int -> State -> State
addVendorCaps amount state =
    { state | vendorCaps = state.vendorCaps + amount }


removeVendorCaps : Int -> State -> State
removeVendorCaps amount state =
    { state | vendorCaps = state.vendorCaps - amount }


setProblem : Problem -> State -> State
setProblem problem state =
    { state | lastProblem = Just problem }


dismissProblem : State -> State
dismissProblem state =
    { state | lastProblem = Nothing }


problemText : Problem -> String
problemText problem =
    case problem of
        BarterIsEmpty ->
            "You didn't yet say what you want to trade."

        PlayerOfferNotValuableEnough ->
            "You didn't offer enough value for what you request."


defaultTransferN : String
defaultTransferN =
    "10"


type ArrowsDirection
    = ArrowLeft
    | ArrowRight


arrowsDirection : TransferNPosition -> ArrowsDirection
arrowsDirection position =
    case position of
        PlayerKeptItem _ ->
            ArrowRight

        VendorKeptItem _ ->
            ArrowLeft

        PlayerTradedItem _ ->
            ArrowLeft

        VendorTradedItem _ ->
            ArrowRight

        PlayerKeptCaps ->
            ArrowRight

        VendorKeptCaps ->
            ArrowLeft

        PlayerTradedCaps ->
            ArrowLeft

        VendorTradedCaps ->
            ArrowRight


singleArrow : ArrowsDirection -> String
singleArrow direction =
    case direction of
        ArrowLeft ->
            "‹"

        ArrowRight ->
            "›"


doubleArrow : ArrowsDirection -> String
doubleArrow direction =
    case direction of
        ArrowLeft ->
            "«"

        ArrowRight ->
            "»"


setTransferNInput : TransferNPosition -> String -> State -> State
setTransferNInput position string state =
    { state | transferNInputs = Dict_.insert position string state.transferNInputs }


setTransferNHover : TransferNPosition -> State -> State
setTransferNHover position state =
    { state | transferNHover = Just position }


unsetTransferNHover : State -> State
unsetTransferNHover state =
    { state | transferNHover = Nothing }
