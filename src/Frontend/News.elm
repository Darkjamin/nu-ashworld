module Frontend.News exposing (Item, formatDate, formatText, items)

import DateFormat
import Html as H exposing (Html)
import Html.Attributes as HA
import Html.Attributes.Extra as HAE
import Markdown.Block
import Markdown.Parser
import Markdown.Renderer exposing (defaultHtmlRenderer)
import Tailwind as TW
import Time
import UI


type alias Item =
    { date : Int -- UNIX: date +%s
    , title : String
    , text : String
    }


items : List Item
items =
    [ { date = 1614377234
      , title = "TODOs before release"
      , text =
            """
- more "normal" unarmed+melee weapons, and make them part of shops
- Fast Shot trait -> can't use aimed shots

EQUIPPED AMMO
- show it in the inventory
- show which types are usable for the current weapon
- don't allow equipping incompatible ammo
- when unequipping weapon unequip the ammo too
- when it runs out during the fight, do we want to default to another compatible ammo? So should it be only preferredAmmo?

- FightStrategy: walk away

- regain conciousness in fight (cost 1/2 of max AP)

~janiczek
"""
      }
    ]


formatText : String -> String -> Html a
formatText class markdown =
    markdown
        |> Markdown.Parser.parse
        |> Result.mapError (\_ -> "")
        |> Result.andThen (Markdown.Renderer.render renderer)
        |> Result.withDefault [ H.text "Failed to parse Markdown" ]
        |> H.div [ HA.class ("flex flex-col gap-4 mt-4 " ++ class) ]


renderer : Markdown.Renderer.Renderer (Html a)
renderer =
    { defaultHtmlRenderer
        | paragraph =
            \children ->
                H.span [] children
        , link =
            \{ title, destination } children ->
                H.a
                    [ HA.class "text-yellow relative no-underline"
                    , TW.mod "after" "absolute content-[''] bg-yellow-transparent inset-x-[-3px] bottom-[-2px] h-1 transition-all duration-[250ms]"
                    , TW.mod "hover:after" "bottom-0 h-full"
                    , HA.href destination
                    , HAE.attributeMaybe HA.title title
                    ]
                    children
        , unorderedList =
            \list ->
                list
                    |> List.map
                        (\(Markdown.Block.ListItem _ children) ->
                            H.li [] (UI.liBullet :: children)
                        )
                    |> H.ul [ HA.class "flex flex-col" ]
    }


formatDate : Time.Zone -> Int -> String
formatDate zone time =
    (time * 1000)
        |> Time.millisToPosix
        |> DateFormat.format dateFormat zone


dateFormat : List DateFormat.Token
dateFormat =
    [ DateFormat.yearNumber
    , DateFormat.text "-"
    , DateFormat.monthFixed
    , DateFormat.text "-"
    , DateFormat.dayOfMonthFixed
    , DateFormat.text ", "
    , DateFormat.hourMilitaryFixed
    , DateFormat.text ":"
    , DateFormat.minuteFixed
    ]
