port module Main exposing (main)

import Browser
import Browser.Events as Bvents
import Element exposing (Attribute, Element)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Icon
import Json.Decode as Decode
import Json.Encode as Encode
import Markdown.Extensions as MarkdownE
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
    , resumes : Resumes
    }


type ResumeView
    = Essay
    | Bullets


init : Flags -> ( Model, Cmd Msg )
init { initialWidth, initialHeight, essay, bullets } =
    ( { device = Element.classifyDevice { width = initialWidth, height = initialHeight }
      , theme = Theme.init
      , resumeView = Bullets
      , resumes = { essay = essay, bullets = bullets }
      }
    , Cmd.none
    )


port store : Encode.Value -> Cmd msg


savePreferences : { model | theme : Theme, resumeView : ResumeView } -> Cmd msg
savePreferences { theme, resumeView } =
    Encode.object
        [ ( "key", Encode.string "preferences" )
        , ( "value"
          , Encode.object
                [ ( "theme", Theme.encoder theme )
                , ( "resumeView"
                  , Encode.string <|
                        case resumeView of
                            Essay ->
                                "Essay"

                            Bullets ->
                                "Bullets"
                  )
                ]
          )
        ]
        |> store


type alias Resumes =
    { essay : String, bullets : String }


type alias Flags =
    { initialWidth : Int
    , initialHeight : Int
    , essay : String
    , bullets : String
    }


applyBoth : ( a -> b, a -> c ) -> a -> ( b, c )
applyBoth ( func, gunc ) val =
    ( func val, gunc val )


step : Model -> ( Model, Cmd Msg )
step =
    applyBoth ( identity, savePreferences )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ResizedWindow windowWidth windowHeight ->
            ( { model | device = Element.classifyDevice { width = windowWidth, height = windowHeight } }
            , Cmd.none
            )

        ClickedToggleTheme ->
            step { model | theme = Theme.toggle model.theme }

        ClickedResumeViewButton resumeView ->
            step { model | resumeView = resumeView }


subscriptions : Model -> Sub Msg
subscriptions _ =
    Bvents.onResize (\w h -> ResizedWindow w h)



-- VIEW


view : Model -> Browser.Document Msg
view { device, theme, resumeView, resumes } =
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
            , Font.family
                [ Font.serif
                ]
            ]
          <|
            page style resumeView resumes
        ]
    }


textLink : Theme.Style -> { url : String, label : String } -> Element msg
textLink style { url, label } =
    Element.newTabLink [ Font.color style.textAccent, Font.underline ] { url = url, label = Element.text label }


page : Theme.Style -> ResumeView -> Resumes -> Element Msg
page style resumeView resumes =
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
        , resumeContent style resumeView resumes
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
    let
        imageSize : Int
        imageSize =
            192
    in
    Element.column [ Element.centerX ]
        [ Element.el
            [ Element.width <| Element.px imageSize
            , Element.height <| Element.px imageSize
            , Element.centerX
            , Border.rounded (imageSize // 2)
            , Element.clip
            ]
          <|
            Element.image [ Element.width <| Element.px imageSize, Element.height <| Element.px imageSize ] { src = "./john.png", description = "john pavlick" }
        , Element.el [ Element.centerX, Font.size 24 ] <| Element.text "john pavlick"
        , Element.el [ Element.centerX ] <| Element.text "consultant <> senior engineer <> tech lead"
        ]


description : ({ url : String, label : String } -> Element msg) -> Element msg
description link =
    Element.paragraph [ Font.justify ]
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


resumeContent : Theme.Style -> ResumeView -> Resumes -> Element Msg
resumeContent style activeResumeView { essay, bullets } =
    let
        content : String
        content =
            case activeResumeView of
                Essay ->
                    essay

                Bullets ->
                    bullets
    in
    case MarkdownE.render content of
        Ok elems ->
            Element.column [ Element.spacingXY 16 24 ] elems

        Err error ->
            Element.text error
