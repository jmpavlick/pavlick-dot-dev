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
    }


type Theme
    = Theme Scheme Style


type Scheme
    = Light
    | Dark


light : Style
light =
    { textBase = charcoal
    , textAccent = lightGray
    }


dark : Style
dark =
    { textBase = lightGray
    , textAccent = charcoal
    }



-- colors


charcoal : Element.Color
charcoal =
    Element.rgb255 0x42 0x42 0x42


lightGray : Element.Color
lightGray =
    Element.rgb255 0xA9 0xA9 0xA9
