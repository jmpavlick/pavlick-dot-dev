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


values : List (Maybe a) -> List a
values =
    List.filterMap identity


heading :
    { level : Block.HeadingLevel
    , rawText : String
    , children : List (Element msg)
    }
    -> Element msg
heading { level, children } =
    let
        ( size, decoration ) =
            case level of
                Block.H1 ->
                    ( 24, Nothing )

                Block.H2 ->
                    ( 20, Just Font.underline )

                Block.H3 ->
                    ( 18, Nothing )

                _ ->
                    ( 16, Nothing )

        attrs : List (Attribute msg)
        attrs =
            decoration
                :: List.map Just
                    [ Font.size size
                    , Font.bold
                    , Region.heading <| Block.headingLevelToInt level
                    ]
                |> values
    in
    Element.paragraph attrs children


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


unorderedListItem : Block.ListItem (Element msg) -> Element msg
unorderedListItem (Block.ListItem task children) =
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
    Element.row []
        [ Element.el
            [ Element.paddingEach
                { top = 0
                , bottom = 0
                , left = 0
                , right = 8
                }
            , Element.alignTop
            ]
            bullet
        , Element.column [ Element.width Element.fill ]
            [ Element.column
                [ Element.paddingXY 0 4
                ]
                children
            ]
        ]


unorderedList : List (Block.ListItem (Element msg)) -> Element msg
unorderedList items =
    List.map unorderedListItem items
        |> Element.column []


orderedList : Int -> List (List (Element msg)) -> Element msg
orderedList startingIndex items =
    Element.column [] <|
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
