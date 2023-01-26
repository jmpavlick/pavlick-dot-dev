module View exposing (view)

import Context exposing (Context, Msg)
import Element exposing (Element)
import Element.WithContext as Element
import Element.WithContext.Border as Border
import Element.WithContext.Font as Font
import Element.WithContext.Input as Input
import Icon
import Theme exposing (Theme(..))


view : Element Context.Msg
view =
    Element.column
        [ Context.askAttr Font.color .textBase
        , Element.width Element.fill
        , Element.padding 20
        , Element.spacingXY 0 40
        ]
        [ navbar
        , title
        , description
        , switcher
        ]


navbar : Element Context.Msg
navbar =
    Element.row
        [ Element.width Element.fill
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
            , label = Context.ask Theme.mapSchemeIcon identity
            }
        ]


textLink : { url : String, label : String } -> Element msg
textLink { url, label } =
    Element.newTabLink [ Context.askAttr Font.color .textAccent, Font.underline ] { url = url, label = Element.text label }


title : Element msg
title =
    Element.column [ Element.centerX ]
        [ Element.el [ Element.width <| Element.px 128, Element.height <| Element.px 128, Element.centerX, Border.rounded 64, Element.clip ] <| Element.image [ Element.width <| Element.px 128, Element.height <| Element.px 128 ] { src = "./john.png", description = "john pavlick" }
        , Element.el [ Element.centerX ] <| Element.text "john pavlick"
        , Element.el [ Element.centerX ] <| Element.text "consultant | senior engineer | tech lead"
        ]


description : Element msg
description =
    Element.paragraph []
        [ Element.text "I'm a leadership-track senior engineer by day, and a consultant by night. I'm creating interesting applications and services for the Olympic sport of bicycle motocross with some of my friends at "
        , textLink { url = "https://gatesnaplabs.com", label = "Gatesnap Labs" }
        , Element.text ". I enjoy functional programming in Elm, Haskell, and F#; but I'm also comfortable with C# and Ruby, and I've probably written more SQL than you have. Sometimes I write essays about the interesting parts of software engineering at "
        , textLink { url = "https://dev.to/jmpavlick", label = "dev.to/jmpavlick" }
        , Element.text "."
        ]


switcherButton : Maybe Context.Msg -> String -> (Element.Color -> Element Context.Msg) -> Element Context.Msg
switcherButton msg labelText icon =
    Input.button []
        { onPress = msg
        , label =
            Element.row [ Element.spacingXY 10 0 ]
                [ Context.ask icon .textAccent
                , Element.text labelText
                ]
        }


switcher : Element Context.Msg
switcher =
    Element.row [ Element.spacingXY 16 0, Element.centerX ]
        [ switcherButton Nothing "Essay" Icon.essay
        , switcherButton Nothing "Bullets" Icon.bullets
        ]
