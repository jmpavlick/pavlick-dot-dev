module Markdown.Extensions exposing (..)

import Element exposing (Element)
import Markdown.Parser as Parser
import Markdown.Renderer as Renderer


markdownView : String -> Result String (List (Element msg))
markdownView markdown =
    Parser.parse markdown
        |> Result.mapError
            (\error ->
                List.map Parser.deadEndToString error
                    |> String.join "\n"
            )
        |> Result.andThen (Renderer.render renderer)
        -- this can be removed when the renderer is returning the correct type
        |> Result.map (List.map Element.html)


renderer =
    Renderer.defaultHtmlRenderer
