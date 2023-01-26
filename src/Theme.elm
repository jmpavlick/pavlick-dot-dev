module Theme exposing (Style, Theme(..), init, mapSchemeIcon, toggle)

import Element.WithContext as Element exposing (Element)
import Html exposing (Html)
import Ionicon.Ios as Icon


init : Theme
init =
    Theme Light light


toggle : Theme -> Theme
toggle (Theme scheme _) =
    case scheme of
        Light ->
            Theme Dark dark

        Dark ->
            Theme Light light


type alias Style =
    { textBase : Element.Color
    , textAccent : Element.Color
    , background : Element.Color
    , schemeIcon : SchemeIcon
    }


type Theme
    = Theme Scheme Style


type Scheme
    = Light
    | Dark


light : Style
light =
    { textBase = brown
    , textAccent = lightGray
    , background = straw
    , schemeIcon = Moon
    }


dark : Style
dark =
    { textBase = lightGray
    , textAccent = yellow
    , background = charcoal
    , schemeIcon = Sun
    }


type SchemeIcon
    = Sun
    | Moon


mapSchemeIcon : Style -> Element context msg
mapSchemeIcon style =
    let
        icon : Int -> { red : Float, green : Float, blue : Float, alpha : Float } -> Html msg
        icon =
            case style.schemeIcon of
                Sun ->
                    Icon.sunnyOutline

                Moon ->
                    Icon.moonOutline
    in
    Element.toRgb style.textAccent
        |> icon 40
        |> Element.html



-- colors


straw : Element.Color
straw =
    Element.rgb255 0xFA 0xF0 0xD8


brown : Element.Color
brown =
    Element.rgb255 0x5F 0x4B 0x32


yellow : Element.Color
yellow =
    Element.rgb255 0xEC 0xFF 0x00


charcoal : Element.Color
charcoal =
    Element.rgb255 0x42 0x42 0x42


lightGray : Element.Color
lightGray =
    Element.rgb255 0xA9 0xA9 0xA9
