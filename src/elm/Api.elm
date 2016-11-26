module Api exposing (..)

import Json.Decode as Json exposing (..)
import Json.Decode.Extra as JsonX
import Task exposing (Task)
import Http exposing (..)

import Models exposing (..)
import Messages exposing (..)
import Components.Videos as Videos
import Components.Sponsors as Sponsors
import Components.Board as Board
import Header.Models as Social
import Components.Tweets as Tweets
import Components.Events as Events exposing (withStatus, Status, Venue)
import Resource exposing (Resource)

-----------------
-- Api queries --
-----------------
urlFor =
  -- (++) "http://localhost:8083/api/"
  (++) "http://api.winnipegdotnet.org/api/"

resources = [getEvents, getBoard, getVideos, getTweets, getSponsors]

handleSlackResponse fail success result =
  case result of
    (Ok data) -> SocialMsg (success data)
    (Err msg) -> ApiFail fail msg 

postToSlack email fail success =
  let body = stringBody "application/x-www-form-urlencoded" <| ("email=" ++ (encodeUri email))
  in
     Http.post (urlFor "slack") body slackDecoder
     |> Http.send (handleSlackResponse fail success)

handleResourceResponse fail msg result =
  case result of
    (Ok data) -> msg data
    (Err m)   -> fail m

getResource resource decoder fail msg =
  Http.get (urlFor resource) decoder
  |> Http.send (handleResourceResponse (ApiFail fail) msg)
--resource
--  |> urlFor
--  |> Http.get decoder
--  |> Task.perform (ApiFail fail) msg

getEvents   = getResource "events"   eventsDecoder  Messages.Events (Events.Load   >> EventsMsg)
getBoard    = getResource "board"    boardDecoder   Messages.NotifyUser (Board.Load    >> BoardMsg)
getSponsors = getResource "sponsors" sponsorDecoder Messages.NotifyUser (Sponsors.Load >> SponsorsMsg)
getVideos   = getResource "videos"   videoDecoder   Messages.NotifyUser (Videos.Load   >> VideosMsg)
getTweets   = getResource "tweets"   tweetDecoder   Messages.Tweets (Resource.Loaded >> Just >> Tweets.Load >> TweetsMsg)


----------------
--- Decoders ---
----------------

slackDecoder =
  Json.map2 
    Social.SlackResponse
    (field "ok"    Json.bool)
    (Json.maybe <| field "error" Json.string)

venueDecoder = 
  Json.map2
    Venue
    (field "name" Json.string)
    (field "address" Json.string)

eventsDecoder  =
  let 
    toStatus s = 
      case s of
        "live"      -> Events.Live
        "completed" -> Events.Completed
        _           -> Events.Unknown


    seasonDecoder (cfg, events) =
      let
        past = events |> List.filter (withStatus Events.Completed)
        season =
          case cfg of
            (True, _) -> Events.Summer
            (_, True) -> Events.Winter
            _         -> 
              events 
              |> List.filter (withStatus Events.Live) 
              |> List.head
              |> Maybe.map Events.Ready 
              |> Maybe.withDefault Events.InBetween
      in
        (season, past)

    cfgDecoder =
      Json.map2
        (,)
        (field "isSummer" Json.bool)
        (field "isWinter" Json.bool)

    eventsDecoder = 
      Json.list 
      <| Json.map7
          Events.Event
          (field "title"       Json.string)
          (field "date"        JsonX.date)
          (field "description" Json.string)
          (field "logo"        Json.string)
          (field "venue"       venueDecoder)
          (field "link"        Json.string)
          (field "status"      (Json.map toStatus Json.string))
  
  in 
    Json.map2
      (,)
      (field "config" cfgDecoder)
      (field "events" eventsDecoder)
    |> Json.map seasonDecoder

boardDecoder =
  Json.at ["board"]
  <| Json.list 
  <| Json.map4
      Board.BoardMember
      (field "name"    Json.string)
      (field "imgUrl"  Json.string)
      (field "role"    Json.string)
      (field "contact" Json.string)

sponsorDecoder =
  Json.at ["sponsors"]
  <| Json.list 
  <| Json.map3
      Sponsors.Sponsor
      (field "name"   Json.string)
      (field "url"    Json.string)
      (field "imgUrl" Json.string)

videoDecoder =
  Json.at ["videos"]
  <| Json.list
  <| Json.map5
      Videos.Video
        (field "title"       Json.string)
        (field "link"        Json.string)
        (field "description" Json.string)
        (field "date"        JsonX.date)
        (field "thumbnail"   Json.string)


tweetDecoder =
  let
    userDecoder =
      Json.map5
        Tweets.TweeterUser
        (field "id"   Json.string)
        (field "screen_name" Json.string)
        (field "name" Json.string)
        (field "url"  Json.string)
        (field "profile_image_url" Json.string)

  in
    Json.at ["tweets"]
    <| Json.list
    <| Json.map3
        Tweets.Tweet
        (field "text" Json.string)
        (field "created_at" JsonX.date)
        (field "user" userDecoder)

