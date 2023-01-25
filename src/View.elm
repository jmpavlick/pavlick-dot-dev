module View exposing (view)

import Context exposing (Context, Msg)
import Element.WithContext as Element
import Element.WithContext.Font as Font
import Theme exposing (Theme(..))


type alias Element msg =
    Element.Element Context msg


type alias Attribute msg =
    Element.Attribute Context msg


type alias Attr decorative msg =
    Element.Attr Context decorative msg


view : Element msg
view =
    Element.el
        [ Element.withAttribute (\{ theme } -> theme) (\(Theme _ style) -> Font.color style.textBase)
        , Element.width Element.fill
        , Element.height Element.fill
        ]
    <|
        navbar


navbar : Element msg
navbar =
    Element.row
        [ Element.width Element.fill
        , Element.padding 20
        , Element.spaceEvenly
        ]
        [ Element.el [] <|
            Element.paragraph [ Font.letterSpacing 4 ]
                [ Element.el [] <| Element.text "pavlick"
                , Element.el
                    [ Element.withAttribute (\{ theme } -> theme) (\(Theme _ style) -> Font.color style.textAccent)
                    ]
                  <|
                    Element.text "dot"
                , Element.el [] <| Element.text "dev"
                ]
        , Element.el [] <| Element.text "(moon glyph)"
        ]
