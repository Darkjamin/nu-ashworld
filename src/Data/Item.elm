module Data.Item exposing
    ( Id
    , Item
    , Kind(..)
    , basePrice
    , create
    , decoder
    , encode
    , encodeKind
    , kindDecoder
    , name
    )

import AssocList as Dict_
import AssocList.Extra as Dict_
import Json.Decode as JD exposing (Decoder)
import Json.Decode.Extra as JD
import Json.Encode as JE



-- TODO weight : Kind -> Int


type alias Item =
    { id : Id
    , kind : Kind
    , count : Int
    }


type alias Id =
    Int


type Kind
    = Stimpak


basePrice : Kind -> Int
basePrice kind =
    case kind of
        Stimpak ->
            -- TODO change this back to 175
            1


encode : Item -> JE.Value
encode item =
    JE.object
        [ ( "id", JE.int item.id )
        , ( "kind", encodeKind item.kind )
        , ( "count", JE.int item.count )
        ]


decoder : Decoder Item
decoder =
    JD.succeed Item
        |> JD.andMap (JD.field "id" JD.int)
        |> JD.andMap (JD.field "kind" kindDecoder)
        |> JD.andMap (JD.field "count" JD.int)


encodeKind : Kind -> JE.Value
encodeKind kind =
    case kind of
        Stimpak ->
            JE.string "stimpak"


kindDecoder : Decoder Kind
kindDecoder =
    JD.string
        |> JD.andThen
            (\kind ->
                case kind of
                    "stimpak" ->
                        JD.succeed Stimpak

                    _ ->
                        JD.fail <| "Unknown item kind: '" ++ kind ++ "'"
            )


name : Kind -> String
name kind =
    case kind of
        Stimpak ->
            "Stimpak"


create :
    { lastId : Int
    , kind : Kind
    , count : Int
    }
    -> ( Item, Int )
create { lastId, kind, count } =
    let
        newLastId : Int
        newLastId =
            lastId + 1

        item : Item
        item =
            { id = newLastId
            , kind = kind
            , count = count
            }
    in
    ( item, newLastId )
