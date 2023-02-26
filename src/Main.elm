port module Main exposing (main)

import AppUrl
import Browser
import Browser.Navigation as Nav
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
import Url exposing (Url)


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , onUrlChange = OnUrlChange
        , onUrlRequest = ClickedLink
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }


type Msg
    = ClickedToggleTheme
    | ClickedResumeViewButton ResumeView
    | ClickedLink Browser.UrlRequest
    | OnUrlChange Url


type alias Model =
    { theme : Theme
    , resumeView : ResumeView
    , resumes : Resumes
    , key : Nav.Key
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


init : Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init { essay, bullets, preferences } url key =
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
    ( routeUrl url
        { theme = Maybe.map .theme maybePrefs |> Maybe.withDefault Theme.init
        , resumeView = Maybe.map .resumeView maybePrefs |> Maybe.withDefault Essay
        , resumes = { essay = essay, bullets = bullets }
        , key = key
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


routeUrl : Url -> Model -> Model
routeUrl url model =
    case (AppUrl.fromUrl >> .path) url of
        [ "print" ] ->
            { model | theme = Theme.print, resumeView = Bullets }

        _ ->
            model


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ClickedToggleTheme ->
            step { model | theme = Theme.toggle model.theme }

        ClickedResumeViewButton resumeView ->
            step { model | resumeView = resumeView }

        ClickedLink urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( routeUrl url model
                    , Cmd.none
                    )

                Browser.External url ->
                    ( model
                    , Nav.load url
                    )

        OnUrlChange url ->
            ( model
            , Url.toString url |> Nav.pushUrl model.key
            )



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
            page theme resumeView resumes
        ]
    }


textLink : Theme.Style -> { url : String, label : String } -> Element msg
textLink style { url, label } =
    Element.newTabLink [ Font.color style.textAccent, Font.underline ] { url = url, label = Element.text label }


page : Theme -> ResumeView -> Resumes -> Element Msg
page theme resumeView resumes =
    let
        style : Theme.Style
        style =
            Theme.unwrapStyle theme
    in
    Element.column
        [ Element.width Element.fill
        , Element.padding 20
        , Element.spacingXY 0 40
        , Element.width <| Element.maximum 800 Element.fill
        , Element.centerX
        ]
        [ Theme.printHide theme <| header style
        , title theme
        , description theme (textLink style)
        , Theme.printHide theme <| switcher style resumeView
        , resumeContent resumeView resumes
        , Theme.printHide theme <| footer style
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


title : Theme -> Element msg
title theme =
    let
        style : Theme.Style
        style =
            Theme.unwrapStyle theme

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
        , Theme.printHide theme <|
            Element.el
                [ Element.centerX
                , Element.paddingEach { top = 10, left = 0, right = 0, bottom = 0 }
                , Font.size 16
                ]
            <|
                Element.text """"pavlick.dev" :: [] |> ((|>) "john" (::)) |> String.join "@"
                """
        , Theme.printShow theme <|
            Element.el
                [ Element.centerX
                , Element.paddingEach { top = 10, left = 0, right = 0, bottom = 0 }
                ]
            <|
                Element.text "john@pavlick.dev"
        ]


description : Theme -> ({ url : String, label : String } -> Element msg) -> Element msg
description theme link =
    Element.paragraph [ Font.justify ]
        [ Element.text "I'm a leadership-track senior engineer and consultant. I spend my free time creating interesting applications and services for the Olympic sport of bicycle motocross at "
        , Theme.printHide theme <| link { url = "https://gatesnaplabs.com", label = "Gatesnap Labs" }
        , Theme.printShow theme <| link { url = "https://gatesnaplabs.com", label = "https://gatesnaplabs.com" }
        , Element.text ". I enjoy functional programming in Elm, Haskell, and F#; but I'm also comfortable with C#, Python, and Ruby, and spent years as a data engineer. Sometimes I write essays about the interesting parts of software engineering at "
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


resumeContent : ResumeView -> Resumes -> Element Msg
resumeContent activeResumeView { essay, bullets } =
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
