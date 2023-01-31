port module Main exposing (main)

import Browser
import Element exposing (Attribute, Element)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Icon
import Json.Decode as Decode exposing (Decoder)
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
    = ClickedToggleTheme
    | ClickedResumeViewButton ResumeView


type alias Model =
    { theme : Theme
    , resumeView : ResumeView
    , resumes : Resumes
    }


type ResumeView
    = Essay
    | Bullets


resumeViewDecoder : Decoder ResumeView
resumeViewDecoder =
    Decode.string
        |> Decode.andThen
            (\str ->
                case str of
                    "Essay" ->
                        Decode.succeed Essay

                    "Bullets" ->
                        Decode.succeed Bullets

                    _ ->
                        "Expected 'Essay' or 'Bullets', got " ++ str |> Decode.fail
            )


init : Flags -> ( Model, Cmd Msg )
init { essay, bullets, preferences } =
    let
        maybePrefs : Maybe { theme : Theme, resumeView : ResumeView }
        maybePrefs =
            Decode.decodeValue
                (Decode.map2 (\t rv -> { theme = t, resumeView = rv })
                    (Decode.field "theme" Theme.decoder)
                    (Decode.field "resumeView" resumeViewDecoder)
                )
                preferences
                |> Result.toMaybe
    in
    ( { theme = Maybe.map .theme maybePrefs |> Maybe.withDefault Theme.init
      , resumeView = Maybe.map .resumeView maybePrefs |> Maybe.withDefault Essay
      , resumes = { essay = essay, bullets = bullets }
      }
    , Cmd.none
    )


port store : Encode.Value -> Cmd msg


savePreferences : { model | theme : Theme, resumeView : ResumeView } -> Cmd msg
savePreferences { theme, resumeView } =
    Encode.object
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
        |> store


type alias Resumes =
    { essay : String, bullets : String }


type alias Flags =
    { essay : String
    , bullets : String
    , preferences : Encode.Value
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
        ClickedToggleTheme ->
            step { model | theme = Theme.toggle model.theme }

        ClickedResumeViewButton resumeView ->
            step { model | resumeView = resumeView }


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Browser.Document Msg
view { theme, resumeView, resumes } =
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
                [ Font.external
                    { name = "Cormorant Garamond"
                    , url = "https://fonts.googleapis.com/css?family=Cormorant+Garamond"
                    }
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
        [ header style
        , title style
        , description (textLink style)
        , switcher style resumeView
        , resumeContent style resumeView resumes
        , footer style
        ]


header : Theme.Style -> Element Msg
header style =
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


title : Theme.Style -> Element msg
title style =
    let
        imageSize : Int
        imageSize =
            192
    in
    Element.column
        [ Element.centerX
        ]
        [ Element.el
            [ Element.width <| Element.px imageSize
            , Element.height <| Element.px imageSize
            , Element.centerX
            , Border.rounded (imageSize // 2)
            , Element.clip
            , Border.shadow { offset = ( 3, 3 ), size = 2, blur = 5, color = style.shadow }
            ]
          <|
            Element.image
                [ Element.width <| Element.px imageSize
                , Element.height <| Element.px imageSize
                ]
                { src = "./john.png", description = "john pavlick" }
        , Element.el
            [ Element.centerX
            , Font.size 30
            , Font.bold
            , Element.paddingXY 0 8
            ]
          <|
            Element.text "john pavlick"
        , Element.el
            [ Element.centerX
            ]
          <|
            Element.text "consultant <> senior engineer <> tech lead"
        ]


description : ({ url : String, label : String } -> Element msg) -> Element msg
description link =
    Element.paragraph [ Font.justify ]
        [ Element.text "I'm a leadership-track senior engineer and consultant. I spend my free time creating interesting applications and services for the Olympic sport of bicycle motocross at "
        , link { url = "https://gatesnaplabs.com", label = "Gatesnap Labs" }
        , Element.text ". I enjoy functional programming in Elm, Haskell, and F#; but I'm also comfortable with C# and Ruby, and spent years as a data engineer. Sometimes I write essays about the interesting parts of software engineering at "
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
                [ Border.width 2
                , borderColor
                , Border.rounded 6
                , Element.paddingEach { top = 0, bottom = 0, left = 0, right = 8 }
                ]
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


footer : Theme.Style -> Element Msg
footer style =
    Element.row
        [ Element.width <| Element.px 300
        , Element.centerX
        , Element.alignBottom
        , Element.spaceEvenly
        ]
        [ textLink style { url = "https://github.com/jmpavlick/pavlick-dot-dev", label = "Github" }
        , Element.text "<>"
        , textLink style { url = "https://gatesnaplabs.com", label = "Gatesnap Labs" }
        , Element.text "<>"
        , textLink style { url = "https://dev.to/jmpavlick", label = "Essays" }
        ]
