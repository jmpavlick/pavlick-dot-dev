module Icon exposing (..)

import Element.WithContext as Element exposing (Element)
import Html exposing (Html)
import Ionicon.Ios as Icon


map : (Int -> { red : Float, green : Float, blue : Float, alpha : Float } -> Html msg) -> (Element.Color -> Element context msg)
map icon =
    \color ->
        Element.toRgb color
            |> icon 40
            |> Element.html


moon : Element.Color -> Element context msg
moon =
    map Icon.moonOutline


sun : Element.Color -> Element context msg
sun =
    map Icon.sunnyOutline


essay : Element.Color -> Element context msg
essay =
    map Icon.bookOutline


bullets : Element.Color -> Element context msg
bullets =
    map Icon.listOutline
