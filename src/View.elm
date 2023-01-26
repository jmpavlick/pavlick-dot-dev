module View exposing (view)

import Context exposing (Context)
import Element.WithContext as Element
import Element.WithContext.Border as Border
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
        , Input.button
            [ Element.focused []
            ]
            { onPress = Just Context.ClickedToggleTheme
            , label =
                Context.ask
                    (\iconColor ->
                        Element.toRgb iconColor
                            |> Icon.moonOutline 40
                            |> Element.html
                    )
                    .textAccent
            }
        ]


title : Element msg
title =
    Element.column [ Element.centerX ]
        [ Element.el [ Element.width <| Element.px 128, Element.height <| Element.px 128, Element.centerX, Border.rounded 64, Element.clip ] <| Element.image [ Element.width <| Element.px 128, Element.height <| Element.px 128 ] { src = "./john.png", description = "john pavlick" }
        , Element.el [ Element.centerX ] <| Element.text "john pavlick"
        , Element.el [ Element.centerX ] <| Element.text "consultant | senior engineer | tech lead"
        ]
