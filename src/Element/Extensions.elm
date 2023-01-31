module Element.Extensions exposing (..)

import Element exposing (Attribute, Element)
import Element.Font as Font


base : Element.DeviceClass -> Int
base deviceClass =
    case deviceClass of
        Element.Phone ->
            50

        Element.Tablet ->
            20

        Element.Desktop ->
            20

        Element.BigDesktop ->
            20


baseFontSize : Element.DeviceClass -> Attribute msg
baseFontSize =
    base >> Font.size


headlineFontSize : Element.DeviceClass -> Attribute msg
headlineFontSize =
    base >> (+) 8 >> Font.size


h1FontSize : Element.DeviceClass -> Attribute msg
h1FontSize =
    base >> (+) 16 >> Font.size


h2FontSize : Element.DeviceClass -> Attribute msg
h2FontSize =
    base >> (+) 8 >> Font.size


h3FontSize : Element.DeviceClass -> Attribute msg
h3FontSize =
    base >> (+) 4 >> Font.size


classifyDeviceWithRatio : { width : Int, height : Int, devicePixelRatio : Int } -> Element.Device
classifyDeviceWithRatio { width, height, devicePixelRatio } =
    Element.classifyDevice { width = width // devicePixelRatio, height = height // devicePixelRatio }
