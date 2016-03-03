module Views (..) where

import Html exposing (..)
import Html.Attributes exposing (..)
import Signal exposing (Signal, Address)

import Actions exposing (..)
import Models exposing (..)

view : Address Action -> Model -> Html
view address model = 
  div [class "container"]
    [ header [] [socialMedia, bannerMenu]
    , section [class "next-event"] [text "Next event goes here"] 
    , section [class "past-events"] [text "View all past events"]
    , div [class "subscribe-list"] [text "subscribe & twitter stream"]
    , section [class "sponsors"] [text "sponsors go heere"]
    , section [class "contact-us"] [text "Amir, David & Roy"]
    , footer [] [text "here goes the footer"]
    ]

bannerMenu =
  div [] [text "Winnipeg Dot Net User Group ponnies and rainbows"]

socialMedia =
  let 
    icon id = i [class <| "fa fa-" ++ id] []
    linkTo link i t = a [href link, target "_blank"] [icon i, text t]
    twitter  = "https://twitter.com/wpgnetug" 
    facebook = "https://www.facebook.com/winnipegdotnet"
    youTube  = "https://www.youtube.com/channel/UC6OzdI6-htXE_97zamJRaaA"
    gitHub   = "https://github.com/WpgDotNetUG/UserGroupWebsite"
  in 
  div [class "social-media"]
    [ linkTo twitter  "twitter"      "Follow"
    , linkTo facebook "facebook"     "Like"
    , linkTo youTube  "youtube-play" "Subscribe"
    , linkTo gitHub   "github"       "Fork"
    ]
