module Theme exposing (Style, Theme(..), init, toggle)

import Element.WithContext as Element


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
    }


dark : Style
dark =
    { textBase = lightGray
    , textAccent = lightBlue
    , background = charcoal
    }



-- colors


straw : Element.Color
straw =
    Element.rgb255 0xFA 0xF0 0xD8


brown : Element.Color
brown =
    Element.rgb255 0x5F 0x4B 0x32


white : Element.Color
white =
    Element.rgb255 0xFF 0xFF 0xFF


charcoal : Element.Color
charcoal =
    Element.rgb255 0x42 0x42 0x42


lightGray : Element.Color
lightGray =
    Element.rgb255 0xA9 0xA9 0xA9


lightBlue : Element.Color
lightBlue =
    Element.rgb255 0x75 0xF4 0xF6
