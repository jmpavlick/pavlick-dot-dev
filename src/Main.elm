module Main exposing (main)

import Browser
import Browser.Events as Bvents
import Element exposing (Element)
import Element.Background as Background
import Element.Font as Font
import Element.Input as Input
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
        , description
        , switcher
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
    Element.none


description : Element msg
description =
    Element.none


switcher : Element msg
switcher =
    Element.none
