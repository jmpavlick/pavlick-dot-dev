module Theme exposing (ApplyStyle, Style, Theme, init, mapSchemeIcon, style, toggle)

import Element as Element exposing (Element)
import Icon


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


type alias ApplyStyle a b =
    (a -> b) -> (Style -> a) -> b


style : Theme -> ApplyStyle a b
style (Theme _ s) func accessor =
    accessor s |> func


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


mapSchemeIcon : Style -> Element msg
mapSchemeIcon s =
    (case s.schemeIcon of
        Sun ->
            Icon.sun

        Moon ->
            Icon.moon
    )
        s.textAccent



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
    Element.rgb255 0xAA 0xAA 0xAA
