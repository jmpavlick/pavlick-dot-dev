module Main exposing (main)

import Browser
import Browser.Events as Bvents
import Context exposing (Context)
import Element.WithContext as Element
import Element.WithContext.Background as Background
import Html exposing (Html)
import View


main : Program Flags Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type Msg
    = GotContextMsg Context.Msg


type alias Model =
    { context : Context }


init : Flags -> ( Model, Cmd Msg )
init { initialWidth, initialHeight } =
    ( { context = Context.init { windowWidth = initialWidth, windowHeight = initialHeight }
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
        GotContextMsg ctxMsg ->
            ( { model | context = Context.update ctxMsg model.context }
            , Cmd.none
            )


view : Model -> Browser.Document Msg
view model =
    { title = "pavlick dot dev"
    , body =
        [ Element.map GotContextMsg View.view
            |> Element.layout model.context
                [ Context.askAttr
                    Background.color
                    .background
                ]
        ]
    }


subscriptions : Model -> Sub Msg
subscriptions _ =
    Bvents.onResize (\w h -> GotContextMsg (Context.ResizedWindow w h))
