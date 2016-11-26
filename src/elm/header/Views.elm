module Header.Views exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Components.HtmlHelpers exposing (..)
import Json.Decode as Json

import Header.Messages exposing (..)
import Components.Videos as Videos

view model =
  header [] [navSocial model, logoMenu]

navSocial model = 
  let 
    classes = "nav-social" |> toggleIf model.showSlack "slack-signup"
  in 
    divL classes
      [ navMenu
      , slackForm model
      , socialIcons
      , navClose
      ]

  
navMenu =
  let
    toLi (lnk, t) = li [] [a [href <| "#" ++ lnk, onClick ToggleMenu] [text t]]
    items = [
       ("next-event", "Next Event")
      ,("past-events", "Past Events")
      ,("subscribe", "Subscribe")
      ,("sponsors", "Sponsors")
      ,("contact-us", "Contact Us")
      ]
  in ul [class "nav-menu"] (items |> List.map toLi)

navClose =
  a [class "button-close", href "javascript:void(0)", onClick ToggleMenu] [iconFor "close"]

onEnter : msg -> msg -> Attribute msg
onEnter fail success =
  let
    tagger code = if code == 13 then success else fail
  in
    on "keyup" (Json.map tagger keyCode)

slackForm model =
  div [class "slack-form"]
    [ a [class "sm-link", href "http://slack.winnipegdotnet.org", target "_blank"] 
      [ iconFor "slack", text "slack" ]
      , div
        [ class "form-group"]
        [ iconFor "slack"
        , input 
            [type_ "email"
            , id "email"
            , class "form-control"
            , value model.slackEmail
            , placeholder "you@domain.com"
            , onInput UpdateEmail
            , onEnter NoOp PostToSlack
            ] []
        , label [for "email", onClick ToggleSlack] [text "slack"]
        ]
    ]


socialIcons =
  let 
    twitter  = "https://twitter.com/wpgnetug" 
    facebook = "https://www.facebook.com/winnipegdotnet"
    gitHub   = "https://github.com/WpgDotNetUG/WebsiteV2_Elm"
    icon id =
      span
        [class "fa-stack fa-2x"]
        [ i [class "fa fa-circle fa-stack-2x"] []
        , i [class <| "fa fa-stack-1x fa-" ++ id] []
        ]
      
    linkTo link i t hint = 
      a 
        [title hint
        , class "sm-link"
        , href link
        , onClick ToggleMenu
        , target "_blank"] 
        [icon i, text t]
  in 
  div [class "social-icons"]
    [ linkTo twitter  "twitter"  "Follow" "Follow us on Twitter."
    , linkTo facebook "facebook" "Like" "Like us on Facebook"
    , linkTo Videos.youTube  "youtube-play" "Subscribe" "Subscribe to our YouTube channel to get notifications"
    , linkTo gitHub   "github"   "Fork" "Fork us on GitHub and collaborate"
    ]

menuOptions =
  [ aBlank [title "Open Event Brite page", href "http://www.eventbrite.com/org/1699161450"] [text "Events"]
  , a [title "Watch past presentations", href "#watch-us"] [text "Videos"]
  , a [title "Contact us", href "#contact-us"] [text "Contact"]
  ]

logoMenu =
  div [class "logo-menu"]
    [ img [src "/assets/images/logo.png"] []
    , section [class "motto"]
        [ header [] [text "Winnipeg Dot Net User Group"]
        , divT "description" "A user group full of lambdas, folds, MVC, ponnies and rainbows!"
        ]
    , div [class "main-menu"] menuOptions
    , a [class "button-open", href "javascript:void(0)", onClick ToggleMenu] [iconFor "bars"]
    ]

