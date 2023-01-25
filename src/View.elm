module View exposing (view)

import Context exposing (Context)
import Element.WithContext as Element
import Element.WithContext.Background as Background
import Element.WithContext.Font as Font
import Element.WithContext.Input as Input
import Theme exposing (Theme(..))


type alias Element msg =
    Element.Element Context msg


view : Element Context.Msg
view =
    Element.row
        [ Element.withAttribute (\{ theme } -> theme) (\(Theme _ style) -> Font.color style.textBase)
        , Element.width Element.fill
        , Element.height Element.fill
        , Element.withAttribute (\{ theme } -> theme) (\(Theme _ style) -> Background.color style.background)
        ]
        [ navbar ]


navbar : Element Context.Msg
navbar =
    Element.row
        [ Element.width Element.fill
        , Element.padding 20
        , Element.spaceEvenly
        , Element.alignTop
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
        , Input.button [] { onPress = Just Context.ClickedToggleTheme, label = Element.text "(moon glyph)" }
        ]
