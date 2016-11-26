module Components.Events exposing (..)

import String exposing (split)
import Date exposing (Date)
import Date.Format exposing (format)
import Html exposing (..)
import Html.Attributes exposing (..)
import Components.HtmlHelpers exposing (..) -- (aBlank, anchor, divT, divL, simple, icon, simpleClass, image)
import Resource exposing (..)

-- Model
type Season = Summer | Winter | InBetween | Ready Event

type alias Model =
  { next : Maybe (Resource Season)
  , pastEvents : Maybe (List Event)
  }

type alias Venue = 
  { name : String
  , address : String 
  }

type Status 
  = Live 
  | Completed 
  | Unknown

type alias Event = 
  { title : String
  , date : Date
  , description : String
  , logo : String
  , venue : Venue
  , link : String
  , status: Status
  }

withStatus st e = e.status == st

emptyModel =
  { next = Just Loading
  , pastEvents = Just [] 
  }

-- Update
type Msg
  = Load (Season, List Event)
  | Error

update msg model =
  case msg of
    Load (season, past) -> { model | pastEvents = Just past, next = Just (Resource.Loaded season) } ! []

    Error -> { model | pastEvents = Nothing, next = Nothing } ! []

-- View
renderPast model = 
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
    
    errorLoading = 
      [ div [class "error"]
          [ h1 [] [text ";("]
          , div [] [text "Could not load past events"]
          ]]

    ofEmpty l = if List.isEmpty l then Nothing else Just l

    eventBrite = "http://www.eventbrite.ca/o/winnipeg-dot-net-user-group-1699161450"
    mkArticle content =
      [ article [] content
      , footer [] [aBlank [class "button -large", href eventBrite] [text "View All"]]
      ]

    content =
      case model.pastEvents of
        Nothing -> errorLoading
        Just pastEvents ->
          pastEvents 
          |> List.take 4 
          |> List.map mkWidget
          |> ofEmpty
          |> Maybe.map mkArticle
          |> Maybe.withDefault [loading]

  in
    section [class "past-events section"]
      ([anchor "past-events", header [] [text "Past Events"]] ++ content)


renderNext model =
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
                , mkParagraphs e.description |> simpleClass div "description"
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
    errorLoading =
      section [class "next-event section"]
        [ anchor "next-event"
        , simple header "header" "Next Event"
        , article []
            [ div [class "error"]
              [ h1 [] [text ";("]
              , div [] [text "Could not load next event"]
              ]
            ]
        ]

    workingOnIt =
      section [class "next-event section -empty"]
        [ anchor "next-event"
        , header  [] [text "Next Event"]
        , article [] 
            [ img [src "/assets/images/placeholder.png"] []
            , span [class "placeholder"] [
              text "We are working on it"]
            ]
        ]
        
    loadingEvents =
      section [class "next-event section"]
        [ anchor "next-event"
        , simple header "header" "Next Event"
        , loading
        ]

    summer =
      section [class "next-event section summer"]
        [ anchor "next-event"
        , header  [] [text "Next Event"]
        , article []
            [ div [class "text"] 
                [ div [class "back-in"] [text "We will be back in Sep"]
                , div [class "message"] [text "Happy Summer!"]
                , div [class "signature"] [text "C#, F# & VB.NET"]
                ]
            ]
        ]

    winter = 
      section [class "next-event section winter"]
        [ anchor "next-event"
        , header  [] [text "Next Event"]
        , article []
            [ div [class "text"] 
                [ div [class "back-in"] [text "We will be back in Jan"]
                , div [class "message"] [text "Happy Holidays!"]
                , div [class "signature"] [text "C#, F# & VB.NET"]
                ]
            ]
        ]

  in 
    case model.next of
      Nothing -> errorLoading
      Just Loading -> loadingEvents
      Just (Loaded Summer) -> summer
      Just (Loaded Winter) -> winter
      Just (Loaded InBetween)     -> workingOnIt
      Just (Loaded (Ready event)) -> showEvent event


