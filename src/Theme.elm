module Theme exposing (Style, Theme, decoder, encoder, init, mapSchemeIcon, toggle, unwrapStyle)

import Element as Element exposing (Element)
import Icon
import Json.Decode as Decode exposing (Decoder)
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


decoder : Decoder Theme
decoder =
    Decode.string
        |> Decode.andThen
            (\str ->
                case str of
                    "Light" ->
                        Decode.succeed light

                    "Dark" ->
                        Decode.succeed dark

                    _ ->
                        "Expected 'Light' or 'Dark', got " ++ str |> Decode.fail
            )


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
    , shadow : Element.Color
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
    , shadow = brown
    }


darkStyle : Style
darkStyle =
    { textBase = lightGray
    , textAccent = gold
    , background = charcoal
    , schemeIcon = Sun
    , shadow = darkGray
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
    Element.rgba255 0xFF 0xF4 0xE3 0.3


brown : Element.Color
brown =
    Element.rgb255 0x3E 0x31 0x21


charcoal : Element.Color
charcoal =
    Element.rgb255 0x42 0x42 0x42


lightGray : Element.Color
lightGray =
    Element.rgb255 0xAF 0xAF 0xAF


darkGray : Element.Color
darkGray =
    Element.rgb255 0x55 0x55 0x55


gray : Element.Color
gray =
    Element.rgb255 136 136 136


gold : Element.Color
gold =
    Element.rgb255 0xFF 0xD7 0x00
