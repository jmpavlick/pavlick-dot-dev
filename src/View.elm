module View exposing (view)

import Context exposing (Context)
import Element.WithContext as Element
import Element.WithContext.Font as Font
import Element.WithContext.Input as Input
import Ionicon.Ios as Icon
import Theme exposing (Theme(..))


type alias Element msg =
    Element.Element Context msg


view : Element Context.Msg
view =
    Element.column
        [ Context.askAttr Font.color .textBase
        , Element.width Element.fill
        ]
        [ navbar
        , title
        ]


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
                    [ Context.askAttr Font.color .textAccent
                    ]
                  <|
                    Element.text "dot"
                , Element.el [] <| Element.text "dev"
                ]
        , Input.button [] { onPress = Just Context.ClickedToggleTheme, label = Element.html <| Icon.moonOutline 40 { red = 1, green = 0, blue = 0, alpha = 1 } }
        ]


title : Element msg
title =
    Element.column [ Element.centerX ]
        [ Element.el [ Element.centerX ] <| Element.text "john pavlick"
        , Element.el [ Element.centerX ] <| Element.text "consultant | senior engineer | tech lead"
        ]
