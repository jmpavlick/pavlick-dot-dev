module Icon exposing (bullets, essay, moon, sun)

import Element as Element exposing (Element)
import Html exposing (Html)
import Ionicon.Ios as Icon


map : (Int -> { red : Float, green : Float, blue : Float, alpha : Float } -> Html msg) -> (Element.DeviceClass -> Element.Color -> Element msg)
map icon =
    \deviceClass color ->
        Element.toRgb color
            |> icon
                (case deviceClass of
                    Element.Phone ->
                        70

                    Element.Tablet ->
                        40

                    Element.BigDesktop ->
                        40

                    Element.Desktop ->
                        40
                )
            |> Element.html


moon : Element.DeviceClass -> Element.Color -> Element msg
moon =
    map Icon.moonOutline


sun : Element.DeviceClass -> Element.Color -> Element msg
sun =
    map Icon.sunnyOutline


essay : Element.DeviceClass -> Element.Color -> Element msg
essay =
    map Icon.bookOutline


bullets : Element.DeviceClass -> Element.Color -> Element msg
bullets =
    map Icon.listOutline
