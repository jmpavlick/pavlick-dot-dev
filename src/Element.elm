module Element exposing (Attribute, Element)

import Context exposing (Context)
import Element.WithContext as Element


type alias Element msg =
    Element.Element Context msg


type alias Attribute msg =
    Element.Attribute Context msg
