module Context exposing (Context, Msg(..), ask, askAttr, init, update)

import Element.WithContext as Element exposing (Attribute, Element)
import Theme exposing (Theme(..))


type alias Context =
    { device : Element.Device
    , theme : Theme
    }


init : { windowWidth : Int, windowHeight : Int } -> Context
init { windowWidth, windowHeight } =
    { device = Element.classifyDevice { width = windowWidth, height = windowHeight }
    , theme = Theme.init
    }


type Msg
    = ResizedWindow Int Int
    | ClickedToggleTheme


update : Msg -> Context -> Context
update msg context =
    case msg of
        ResizedWindow windowWidth windowHeight ->
            { context | device = Element.classifyDevice { width = windowWidth, height = windowHeight } }

        ClickedToggleTheme ->
            { context | theme = Theme.toggle context.theme }


askAttr : (a -> Attribute Context msg) -> (Theme.Style -> a) -> Attribute Context msg
askAttr func accessor =
    Element.withAttribute .theme (\(Theme _ style) -> func (accessor style))


ask : (a -> Element Context msg) -> (Theme.Style -> a) -> Element Context msg
ask func accessor =
    Element.with .theme (\(Theme _ style) -> func (accessor style))
