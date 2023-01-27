module Context exposing (Context, Msg(..), ResumeView(..), ask, askAttr, askDecoration, init, update)

import Element.WithContext as Element exposing (Attribute, Decoration, Element)
import Theme exposing (Theme(..))


type alias Context =
    { device : Element.Device
    , theme : Theme
    , resumeView : ResumeView
    }


init : { windowWidth : Int, windowHeight : Int } -> Context
init { windowWidth, windowHeight } =
    { device = Element.classifyDevice { width = windowWidth, height = windowHeight }
    , theme = Theme.init
    , resumeView = Essay
    }


type Msg
    = ResizedWindow Int Int
    | ClickedToggleTheme
    | ClickedResumeViewButton ResumeView


type ResumeView
    = Essay
    | Bullets


update : Msg -> Context -> Context
update msg context =
    case msg of
        ResizedWindow windowWidth windowHeight ->
            { context | device = Element.classifyDevice { width = windowWidth, height = windowHeight } }

        ClickedToggleTheme ->
            { context | theme = Theme.toggle context.theme }

        ClickedResumeViewButton resumeView ->
            { context | resumeView = resumeView }


askAttr : (a -> Attribute Context msg) -> (Theme.Style -> a) -> Attribute Context msg
askAttr func accessor =
    Element.withAttribute .theme (\(Theme _ style) -> func (accessor style))


ask : (a -> Element Context msg) -> (Theme.Style -> a) -> Element Context msg
ask func accessor =
    Element.with .theme (\(Theme _ style) -> func (accessor style))


askDecoration : (a -> Decoration Context) -> (Theme.Style -> a) -> Decoration Context
askDecoration func accessor =
    Element.withDecoration .theme (\(Theme _ style) -> func (accessor style))
