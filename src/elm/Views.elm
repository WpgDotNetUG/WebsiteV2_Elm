module Views exposing (..) 

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Date
import Array
import Date.Format exposing (format)
import Random
import String

import Messages exposing (..)
import Models exposing (..)

iconFor icn = i [class <| "fa fa-" ++ icn] []
aBlank xs = a <| target "_blank"::xs
anchor s = a [id s] []
single tag t = tag [] [text t]
simple tag c t = tag [class c] [text t]
simple' tag c = tag [class c]
icon c fa = div [class c] [iconFor fa]
image c url = div [class c] [img [src url] []]
divT = simple div
divL = simple' div

loading = divL "loading" [ i [class "fa fa-spin fa-spinner fa-5x"] [] ]

view : Model -> Html Msg
view model = 
  let ctnrClass = "container" ++ if model.openMenu then " drawer-open" else ""
  in div [class ctnrClass]
    [ header [] [navSocial, logoMenu]
    , nextEvent model.next
    , pastEvents model.pastEvents
    , featuredVideos model.videos
    , listRegistration
    , sponsorsView model.sponsors
    , contactView model.board
    , footer [class "main-footer"] 
        [ divL "menu" menuOptions
        , divT "copyright" "© Winnipeg Dot Net User Group 2015"
        , divT "version" "v0.1 aabbcc"
        ]
    , div [class "backdrop"] []
    ]

img_asset s = "/assets/images/" ++ s

contactView members =
  let
    mailTo = (++) "mailto:winnipegdotnet@gmail.com?subject=ATTN: "
    mkContact mbr = div [class "member", title mbr.name]
      [ div [class "avatar"] [img [src mbr.image] []]
      , divT "name" mbr.name
      , divT "role" mbr.role
      , divL "contact" [a [class "button -outline -small", href <| mailTo mbr.contact] [text mbr.contact]]
      ] 
    contactMap = case members of
      [] -> [text "No contact information available at the moment"]
      xs -> xs |> List.map mkContact

  in section [class "contact-us section"] 
      [ anchor "contact-us"
      , header  [] [text "Contact Us"]
      , article [] 
          [ divT "message" "Looking to reach out directly to the Winnipeg .NET User Group board? Click on the board member to ask your query."
          , divL "members" contactMap
          ]
      ]

sponsorsView sponsors  =
  let
    sponsorImage sponsor = 
      div [class "sponsor", title sponsor.name] 
        [aBlank [href sponsor.url] [img [src sponsor.image] []] ]
    sponsorMap = case sponsors of
      [] -> [text "No sponsors information available at the moment"]
      xs -> xs |> List.map sponsorImage

  in section [class "sponsors section"] 
      [ anchor "sponsors"
      , header  [] [text "Sponsors"]
      , article [] sponsorMap
      ]


featuredVideos videos =
  let
    featured = videos |> List.take 3

    mkFeature v = div [class "video"]
      [ header [] [aBlank [href v.link] [img [src v.thumbnail] []]]
      -- , div [class "title"] [text v.title]
      , div [class "descr"] [text v.description]
      ]

  in section [class "featured-videos section"]
    [ anchor "watch-us"
    , header [] 
        [span [class "title"] [text "Winnipeg .NET User Group"],
         aBlank [href youTube]
          [iconFor "youtube-play", span [] [text "Subscribe"]]]
    , article [] (featured |> List.map mkFeature)
    ]

listRegistration =
  div [class "list-n-twitter"]
    [ article [class "subscribe"]
        [ anchor "subscribe"
        , header [] [text "Want to make sure you don't miss a meeting?"]
        , divT "signup"   "Then take a minute and sign up for the Winnipeg .NET user group mailing list!"
        , divT "schedule" "You can be on top of our event schedule, and all you need to do is check you email. Sign up now and don't miss another meeting." 
        , footer [] [aBlank [class "button -outline -large", href "http://eepurl.com/clTOr"] [text "Add me to the list"]]
        ]
    , article [class "twitter-stream"]
        [aBlank [class "twitter-timeline", href "https://twitter.com/wpgnetug", 
          attribute "data-widget-id" "709094677924818945", attribute "data-tweet-limit" "3"]
          [text "twitter stream. NEED a stream!"]
        ]
    ]

pastEvents events =
  let
    mkWidget e = 
      div [class "past-event"]
        [ image "image" e.logo
        , div [class "info"]
            [ divT "title" e.title
            , divT "date"  (e.date |> format "%b %e, %Y")
            , divL "view" [aBlank [class "button -outline", href e.link] [text "View"]]
            ]
        ]

    ofEmpty l = if List.isEmpty l then Nothing else Just l

    eventBrite = "http://www.eventbrite.ca/o/winnipeg-dot-net-user-group-1699161450"
    mkArticle content =
      [ article [] content
      , footer [] [aBlank [class "button -large", href eventBrite] [text "View All"]]
      ]

    content =
      events 
      |> List.take 4 
      |> List.map mkWidget
      |> ofEmpty
      |> Maybe.map mkArticle
      |> Maybe.withDefault [loading]

  in
    section [class "past-events section"]
      ([ anchor "past-events"
      , header  [] [text "Past Events"] 
      ] ++ content)


nextEvent =
  let 
    mkParagraphs txt = txt |> String.split "\n" |> List.map (single p)
    showEvent e =
      section [class "next-event section"]
        [ anchor "next-event"
        , simple header "header" "Next Event"
        , article []
            [ image "event-img" e.logo
            , div [class "event-info"]
                [ simple div "title" e.title
                , mkParagraphs e.description |> simple' div "description"
                ]
            , div [class "presenter"] []
            , div [class "details"]
                [ div [class "date"]
                  [ icon "icon" "calendar"
                  , text <| format "%A, %B %e, %Y" e.date
                  ]
                , div [class "venue"]
                  [ icon "icon" "map-marker"
                  , divT "name"    e.venue.name
                  , divT "address" e.venue.address
                  ]
                ]
            , footer [] [aBlank [class "button -large", href e.link] [text "Count me in!"]]
            ]
        ]

    noEvent =
      section [class "next-event section -empty"]
        [
          header  [] [text "Next Event"]
        , article [] 
            [ img [src "/assets/images/placeholder.png"] []
            , span [class "placeholder"] [
              text "We are working on it"]
            ]
        ]
        
    loadingEvents =
      section [class "next-event section"]
        [ simple header "header" "Next Event"
        , loading
        ]

  in Maybe.map showEvent >> Maybe.withDefault loadingEvents

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

navSocial = div [class "nav-social"] [navMenu, slackForm, socialIcons, navClose]

  
navMenu =
  let
    toLi (lnk, t) = li [] [a [href <| "#" ++ lnk] [text t]]
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

slackForm =
  div [class "slack-form"]
    [ Html.form
        [title "Chat with us on Slack", action "https://wpgdotnet.slack.com"]
        [ div
            [ class "form-group"]
            [ iconFor "slack"
            , input [type' "email", id "email", class "form-control", placeholder "you@domain.com"] []
            , label [for "email"] [text "slack"]
            ]
        ]
    ]

youTube  = "https://www.youtube.com/channel/UC6OzdI6-htXE_97zamJRaaA"

socialIcons =
  let 
    icon id =
      span
        [class "fa-stack fa-2x"]
        [ i [class "fa fa-circle fa-stack-2x"] []
        , i [class <| "fa fa-stack-1x fa-" ++ id] []
        ]
      
    linkTo link i t hint = a [title hint, class "sm-link", href link, target "_blank"] [icon i, text t]
    twitter  = "https://twitter.com/wpgnetug" 
    facebook = "https://www.facebook.com/winnipegdotnet"
    gitHub   = "https://github.com/WpgDotNetUG/WebsiteV2_Elm"
  in 
  div [class "social-icons"]
    [ linkTo twitter  "twitter"  "Follow" "Follow us on Twitter."
    , linkTo facebook "facebook" "Like" "Like us on Facebook"
    , linkTo youTube  "youtube-play" "Subscribe" "Subscribe to our YouTube channel to get notifications"
    , linkTo gitHub   "github"   "Fork" "Fork us on GitHub and collaborate"
    ]
