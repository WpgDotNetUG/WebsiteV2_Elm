module Components.HtmlHelpers exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Date
import Date.Format exposing (format)
import Random
import String


iconFor icn = i [class <| "fa fa-" ++ icn] []
aBlank xs = a <| target "_blank"::xs
anchor s = a [id s] []
single tag t = tag [] [text t]
simple tag c t = tag [class c] [text t]
simpleClass tag c = tag [class c]
icon c fa = div [class c] [iconFor fa]
image c url = div [class c] [img [src url] []]
divT = simple div
divL = simpleClass div
spanSimple c t = simple span c t

toggleIf val addition css = css ++ (if val then " " ++ addition else "")
loading = divL "loading" [ i [class "fa fa-spin fa-spinner fa-5x"] [] ]
