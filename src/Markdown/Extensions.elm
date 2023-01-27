module Markdown.Extensions exposing (render)

import Element exposing (Element)
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Element.Region as Region
import Html
import Html.Attributes as Attr
import Markdown.Block as Block
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
    , paragraph = Element.paragraph [ Element.spacing 15 ]
    , thematicBreak = Element.none
    , text = Element.text
    , strong = Element.row [ Font.bold ]
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
                    36

                Block.H2 ->
                    24

                _ ->
                    20
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


unorderedList : List (Block.ListItem (Element msg)) -> Element msg
unorderedList items =
    Element.column [ Element.spacing 15 ]
        (items
            |> List.map
                (\(Block.ListItem task children) ->
                    Element.row [ Element.spacing 5 ]
                        [ Element.row
                            [ Element.alignTop ]
                            ((case task of
                                Block.IncompleteTask ->
                                    Input.defaultCheckbox False

                                Block.CompletedTask ->
                                    Input.defaultCheckbox True

                                Block.NoTask ->
                                    Element.text "•"
                             )
                                :: Element.text " "
                                :: children
                            )
                        ]
                )
        )


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
