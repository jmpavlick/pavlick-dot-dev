module Main exposing (main)

import Browser
import Browser.Events as Bvents
import Element exposing (Attribute, Element)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Icon
import Markdown.Html as Mhtml
import Theme exposing (Theme)


main : Program Flags Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type Msg
    = ResizedWindow Int Int
    | ClickedToggleTheme
    | ClickedResumeViewButton ResumeView


type alias Model =
    { device : Element.Device
    , theme : Theme
    , resumeView : ResumeView
    }


type ResumeView
    = Essay
    | Bullets


init : Flags -> ( Model, Cmd Msg )
init { initialWidth, initialHeight } =
    ( { device = Element.classifyDevice { width = initialWidth, height = initialHeight }
      , theme = Theme.init
      , resumeView = Essay
      }
    , Cmd.none
    )


type alias Flags =
    { initialWidth : Int
    , initialHeight : Int
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ResizedWindow windowWidth windowHeight ->
            ( { model | device = Element.classifyDevice { width = windowWidth, height = windowHeight } }
            , Cmd.none
            )

        ClickedToggleTheme ->
            ( { model | theme = Theme.toggle model.theme }
            , Cmd.none
            )

        ClickedResumeViewButton resumeView ->
            ( { model | resumeView = resumeView }
            , Cmd.none
            )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Bvents.onResize (\w h -> ResizedWindow w h)



-- VIEW


view : Model -> Browser.Document Msg
view { device, theme, resumeView } =
    let
        style : Theme.Style
        style =
            Theme.unwrapStyle theme
    in
    { title = "pavlick dot dev"
    , body =
        [ Element.layout
            [ Background.color style.background
            , Font.color style.textBase
            ]
          <|
            page style resumeView
        ]
    }


textLink : Theme.Style -> { url : String, label : String } -> Element msg
textLink style { url, label } =
    Element.newTabLink [ Font.color style.textAccent, Font.underline ] { url = url, label = Element.text label }


page : Theme.Style -> ResumeView -> Element Msg
page style resumeView =
    Element.column
        [ Element.width Element.fill
        , Element.padding 20
        , Element.spacingXY 0 40
        , Element.width <| Element.maximum 800 Element.fill
        , Element.centerX
        ]
        [ navbar style
        , title
        , description (textLink style)
        , switcher style resumeView
        ]


navbar : Theme.Style -> Element Msg
navbar style =
    Element.row
        [ Element.width Element.fill
        , Element.spaceEvenly
        , Element.alignTop
        ]
        [ Element.el [] <|
            Element.paragraph [ Font.letterSpacing 4 ]
                [ Element.el [] <| Element.text "pavlick"
                , Element.el [ Font.color style.textAccent ] <| Element.text "dot"
                , Element.el [] <| Element.text "dev"
                ]
        , Input.button
            [ Element.focused []
            ]
            { onPress = Just ClickedToggleTheme
            , label = Theme.mapSchemeIcon style
            }
        ]


title : Element msg
title =
    Element.column [ Element.centerX ]
        [ Element.el
            [ Element.width <| Element.px 128
            , Element.height <| Element.px 128
            , Element.centerX
            , Border.rounded 64
            , Element.clip
            ]
          <|
            Element.image [ Element.width <| Element.px 128, Element.height <| Element.px 128 ] { src = "./john.png", description = "john pavlick" }
        , Element.el [ Element.centerX ] <| Element.text "john pavlick"
        , Element.el [ Element.centerX ] <| Element.text "consultant | senior engineer | tech lead"
        ]


description : ({ url : String, label : String } -> Element msg) -> Element msg
description link =
    Element.paragraph []
        [ Element.text "I'm a leadership-track senior engineer by day, and a consultant by night. I'm creating interesting applications and services for the Olympic sport of bicycle motocross with some of my friends at "
        , link { url = "https://gatesnaplabs.com", label = "Gatesnap Labs" }
        , Element.text ". I enjoy functional programming in Elm, Haskell, and F#; but I'm also comfortable with C# and Ruby, and I've probably written more SQL than you have. Sometimes I write essays about the interesting parts of software engineering at "
        , link { url = "https://dev.to/jmpavlick", label = "dev.to/jmpavlick" }
        , Element.text "."
        ]


switcherButton : Theme.Style -> Bool -> ResumeView -> String -> (Element.Color -> Element Msg) -> Element Msg
switcherButton style active resumeView labelText icon =
    let
        borderColor : Attribute Msg
        borderColor =
            Border.color <|
                if active then
                    style.textBase

                else
                    style.background
    in
    Input.button
        [ Element.focused
            [ Border.color style.textBase
            ]
        , Border.rounded 16
        ]
        { onPress = ClickedResumeViewButton resumeView |> Just
        , label =
            Element.row
                (borderColor
                    :: [ Border.width 2
                       , Border.rounded 6
                       , Element.paddingEach { top = 0, bottom = 0, left = 0, right = 8 }
                       ]
                )
                [ icon style.textAccent
                , Element.text labelText
                ]
        }


switcher : Theme.Style -> ResumeView -> Element Msg
switcher style activeResumeView =
    let
        button : Bool -> ResumeView -> String -> (Element.Color -> Element Msg) -> Element Msg
        button =
            switcherButton style
    in
    Element.row [ Element.spacingXY 8 0, Element.centerX ]
        [ button (activeResumeView == Essay) Essay "Essay" Icon.essay
        , button (activeResumeView == Bullets) Bullets "Bullets" Icon.bullets
        ]


resumeContent : Theme.Style -> ResumeView -> Element Msg
resumeContent style activeResumeView =
    Element.text "yooo i'm good at work and jobs etc"
