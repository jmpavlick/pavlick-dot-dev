module Main exposing (main)

import Browser
import Browser.Events as Bvents
import Element exposing (Element)
import Element.Background as Background
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
        style : Theme.ApplyStyle a b
        style =
            Theme.style theme
    in
    { title = "pavlick dot dev"
    , body =
        [ Element.layout
            [ style Background.color .background
            ]
          <|
            page style resumeView
        ]
    }


page : Theme.ApplyStyle a b -> ResumeView -> Element Msg
page style resumeView =
    Element.text "yooo"
