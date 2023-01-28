module Markdown.Extensions exposing (render)

import Element exposing (Attribute, Element)
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Element.Region as Region
import Html exposing (Html)
import Html.Attributes as Attr
import Markdown.Block as Block exposing (Block)
import Markdown.Html as MHtml
import Markdown.Parser as Parser
import Markdown.Renderer as Renderer exposing (Renderer)


render : String -> Result String (List (Element msg))
render markdown =
    Parser.parse markdown
        |> Result.mapError
            (\error ->
                List.map Parser.deadEndToString error
                    |> String.join "\n"
            )
        |> Result.andThen (Renderer.render renderer)


renderer : Renderer (Element msg)
renderer =
    { heading = heading
    , paragraph = Element.paragraph [ Font.justify ]
    , thematicBreak = Element.none
    , text = Element.text
    , strong = Element.row [ Font.semiBold ]
    , emphasis = Element.row [ Font.italic ]
    , strikethrough = Element.row [ Font.strike ]
    , codeSpan = codeSpan
    , link = link
    , hardLineBreak = Element.html <| Html.br [] []
    , image = \img -> Element.image [ Element.width Element.fill ] { src = img.src, description = img.alt }
    , blockQuote = blockQuote
    , unorderedList = unorderedList
    , orderedList = orderedList
    , codeBlock = codeBlock
    , html = MHtml.oneOf []
    , table = Element.column []
    , tableHeader = Element.column []
    , tableBody = Element.column []
    , tableRow = Element.row []
    , tableHeaderCell = \_ children -> Element.paragraph [] children
    , tableCell = \_ children -> Element.paragraph [] children
    }


heading :
    { level : Block.HeadingLevel
    , rawText : String
    , children : List (Element msg)
    }
    -> Element msg
heading { level, rawText, children } =
    Element.paragraph
        [ Font.size
            (case level of
                Block.H1 ->
                    24

                Block.H2 ->
                    20

                _ ->
                    16
            )
        , Font.bold
        , Region.heading <| Block.headingLevelToInt level
        ]
        children


codeSpan : String -> Element msg
codeSpan rawText =
    Element.el [ Font.family [ Font.monospace ] ] <| Element.text rawText


link :
    { title : Maybe String
    , destination : String
    }
    -> List (Element msg)
    -> Element msg
link { title, destination } body =
    Element.newTabLink
        [ Element.htmlAttribute <| Attr.style "display" "inline-flex"
        ]
        { url = destination, label = Element.paragraph [ Font.underline ] body }


blockQuote : List (Element msg) -> Element msg
blockQuote =
    Element.column
        [ Element.padding 10
        , Border.widthEach { top = 0, bottom = 0, right = 0, left = 10 }
        ]


taskToBullet : Block.Task -> Element msg
taskToBullet task =
    let
        bullet : Element msg
        bullet =
            case task of
                Block.IncompleteTask ->
                    Input.defaultCheckbox False

                Block.CompletedTask ->
                    Input.defaultCheckbox True

                Block.NoTask ->
                    Element.text "•"
    in
    Element.el
        [ Element.paddingEach
            { top = 0
            , bottom = 0
            , left = 0
            , right = 4
            }
        ]
        bullet


unorderedListItem : Block.ListItem (Element msg) -> Element msg
unorderedListItem (Block.ListItem task children) =
    Element.column
        [ Element.paddingEach { top = 0, bottom = 0, left = 16, right = 0 }

        --, Element.explain Debug.todo
        ]
        [ List.map
            (\c ->
                Element.row [] [ c ]
            )
            children
            |> Element.column []
        ]


unorderedList : List (Block.ListItem (Element msg)) -> Element msg
unorderedList items =
    List.map unorderedListItem items
        |> Element.column [ Element.spacing 0 ]


orderedList : Int -> List (List (Element msg)) -> Element msg
orderedList startingIndex items =
    Element.column [ Element.spacing 15 ] <|
        List.indexedMap
            (\index itemBlocks ->
                Element.row [ Element.spacing 5 ]
                    [ Element.row [ Element.alignTop ] <|
                        Element.text
                            (String.fromInt (index + startingIndex) ++ " ")
                            :: itemBlocks
                    ]
            )
            items


codeBlock : { body : String, language : Maybe String } -> Element msg
codeBlock { body } =
    Html.pre [] [ Html.text body ] |> Element.html


accursedUnutterable : Element msg -> Html msg
accursedUnutterable =
    Element.layoutWith { options = [ Element.noStaticStyleSheet ] } []


ul : List (Element msg) -> Element msg
ul =
    List.map accursedUnutterable
        >> Html.ul []
        >> Element.html


li : Element msg -> Element msg
li =
    accursedUnutterable >> List.singleton >> Html.li [] >> Element.html
