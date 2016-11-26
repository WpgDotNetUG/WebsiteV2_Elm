module Components.Tweets exposing (..)

import Date exposing (Date)
import Html exposing (..)
import Html.Attributes exposing (..)
import Components.HtmlHelpers exposing (aBlank, anchor, divT, divL, spanSimple, loading)
import Resource exposing (Resource)

-- Model
type alias Model = Maybe (Resource (List Tweet))

type alias TweeterUser =
  { id: String
  , handle: String
  , name: String
  , url: String
  , image: String 
  }

type alias Tweet =
  { text  : String
  , date  : Date
  , user  : TweeterUser
  }


emptyModel = Just []

-- Update
type Msg
  = Load Model
  | Error

update msg model = 
  case msg of
    Load tw -> tw ! []
    Error   -> Nothing ! []

-- View
view resource =
  let
    mkTweet t =
      div [class "tweet"]
        [ div [class "user-image"] [img [src t.user.image] []]
        , div [class "content"]
            [ div [class "user"] 
                [ span [class "handle"] [text t.user.handle]
                , span [class "name"] [text t.user.name]
                ]
            , div [class "content"] [text t.text]
            ]
        ]
    
    errorLoading =
      [ div [class "error"] 
          [ h1 [] [text ";("]
          , div [] [text "We can't hear any tweets at the moment"]
          ]
      ]

    tweetStream =
      case resource of
        Nothing                 -> errorLoading
        Just (Resource.Loading) -> [loading]
        Just (Resource.Loaded tweets) -> tweets |> List.take 5 |> List.map mkTweet
  in
    div [class "list-n-twitter"]
      [ article [class "subscribe"]
          [ anchor "subscribe"
          , header [] [text "Want to make sure you don't miss a meeting?"]
          , divT "signup"   "Then take a minute and sign up for the Winnipeg .NET user group mailing list!"
          , divT "schedule" "You can be on top of our event schedule, and all you need to do is check you email. Sign up now and don't miss another meeting." 
          , footer [] [aBlank [class "button -outline -large", href "http://eepurl.com/clTOr"] [text "Add me to the list"]]
          ]
      , article [class "twitter-stream"]
          [ header [] 
              [ spanSimple "tweets" "Tweets "
              , spanSimple "by" "by " 
              , a [href "https://twitter.com/wpgnetug"] [text "@wpgnetug"]
              ]
          , article [class "tweet-list"] tweetStream
          ]  
      ]
