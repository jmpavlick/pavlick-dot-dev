module Icon exposing (bullets, essay, moon, sun)

import Element exposing (Element)
import Html exposing (Html)
import Ionicon.Ios as Icon


map : (Int -> { red : Float, green : Float, blue : Float, alpha : Float } -> Html msg) -> (Element.Color -> Element msg)
map icon =
    \color ->
        Element.toRgb color
            |> icon 40
            |> Element.html


moon : Element.Color -> Element msg
moon =
    map Icon.moonOutline


sun : Element.Color -> Element msg
sun =
    map Icon.sunnyOutline


essay : Element.Color -> Element msg
essay =
    map Icon.bookOutline


bullets : Element.Color -> Element msg
bullets =
    map Icon.listOutline
