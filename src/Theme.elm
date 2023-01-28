module Theme exposing (Style, Theme, encoder, init, mapSchemeIcon, toggle, unwrapStyle)

import Element as Element exposing (Element)
import Icon
import Json.Encode as Encode


light : Theme
light =
    Theme Light lightStyle


dark : Theme
dark =
    Theme Dark darkStyle


init : Theme
init =
    light


encoder : Theme -> Encode.Value
encoder (Theme scheme _) =
    case scheme of
        Light ->
            Encode.string "Light"

        Dark ->
            Encode.string "Dark"


toggle : Theme -> Theme
toggle (Theme scheme _) =
    case scheme of
        Light ->
            dark

        Dark ->
            light


type alias Style =
    { textBase : Element.Color
    , textAccent : Element.Color
    , background : Element.Color
    , schemeIcon : SchemeIcon
    }


type Theme
    = Theme Scheme Style


unwrapStyle : Theme -> Style
unwrapStyle (Theme _ s) =
    s


type Scheme
    = Light
    | Dark


lightStyle : Style
lightStyle =
    { textBase = brown
    , textAccent = gray
    , background = straw
    , schemeIcon = Moon
    }


darkStyle : Style
darkStyle =
    { textBase = lightGray
    , textAccent = gold
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
    Element.rgb255 0xAF 0xAF 0xAF


gray : Element.Color
gray =
    Element.rgb255 136 136 136


gold : Element.Color
gold =
    Element.rgb255 0xFF 0xD7 0x00


goldenrod : Element.Color
goldenrod =
    Element.rgb255 0xB8 0x86 0x0B
