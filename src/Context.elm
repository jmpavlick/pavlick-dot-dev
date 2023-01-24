module Context exposing (Context, Msg(..), init, update)

import Element.WithContext as Element


type alias Context =
    { device : Element.Device }


init : { windowWidth : Int, windowHeight : Int } -> Context
init { windowWidth, windowHeight } =
    { device = Element.classifyDevice { width = windowWidth, height = windowHeight } }


type Msg
    = UserResizedWindow Int Int


update : Msg -> Context -> Context
update (UserResizedWindow windowWidth windowHeight) context =
    { context | device = Element.classifyDevice { width = windowWidth, height = windowHeight } }
