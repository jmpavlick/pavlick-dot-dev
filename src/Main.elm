module Main exposing (main)

import Browser
import Browser.Events as Bevents
import Element as El
import Html exposing (Html)


main : Program Flags Model Msg
main =
    Browser.document
        { init = \{ initialWidth, initialHeight } -> ( Model initialWidth initialHeight, Cmd.none )
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type Msg
    = UserResizedWindow Int Int


type alias Model =
    { width : Int
    , height : Int
    }


type alias Flags =
    { initialWidth : Int
    , initialHeight : Int
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UserResizedWindow width height ->
            ( { model | width = width, height = height }
            , Cmd.none
            )


view : Model -> Browser.Document msg
view model =
    { title = "test"
    , body =
        [ Html.text (Debug.toString <| El.classifyDevice model)
        ]
    }


subscriptions : Model -> Sub Msg
subscriptions _ =
    Bevents.onResize UserResizedWindow
