module Main exposing (..)

import Task exposing (Task)
import Html as Html
import Date
import Http exposing (..)
import Random
import Json.Decode as Json exposing (..)
import Json.Encode as JsonEnc

import Views exposing (..)
import Models exposing (..)
import Messages exposing (..)
import Api
import Notify exposing (..)

import Components.Sponsors as Sponsors
import Components.Videos as Videos
import Components.Board as Board
import Header.Update as Social
import Components.Events as Events
import Components.Tweets as Tweets
import Resource exposing (Resource)

main = 
  Html.programWithFlags
    { init = init, view = view, update = update, subscriptions = (\_ -> Sub.none) }

--
-- My functions
--
init : {version:String} -> (Model, Cmd Msg)
init {version} =
  ({emptyModel | version = version}, Cmd.batch Api.resources)

mapFst f (a, b) = (f a, b)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = 
  let
    updateEvents ev = { model | events = ev } 
    updateSocial sc = { model | social = sc }
    updateTweets tw = { model | tweets = tw }
  in
    case msg of
      SponsorsMsg msg1 -> Sponsors.update msg1 model
      VideosMsg   msg1 -> Videos.update   msg1 model
      BoardMsg    msg1 -> Board.update    msg1 model
      EventsMsg   msg1 -> Events.update   msg1 model.events |> mapFst updateEvents
      SocialMsg   msg1 -> Social.update   msg1 model.social |> mapFst updateSocial
      TweetsMsg   msg1 -> Tweets.update   msg1 model.tweets |> mapFst updateTweets
      ApiFail Events e -> Events.update Events.Error model.events |> mapFst updateEvents
      ApiFail Tweets e -> Tweets.update Tweets.Error model.tweets |> mapFst updateTweets
      ApiFail NotifyUser error -> model ! [notifyUser Error <| errorMsg error]
      _ -> model ! []


errorMsg e =
  case e of
    Http.Timeout        -> "Sorry, the call timeout"
    Http.NetworkError   -> "Sorry, network error"
    Http.BadUrl _       -> "Sorry, that's a bad URL"
    Http.BadStatus _    -> "This was not the status we were looking for"
    Http.BadPayload _ _ -> "Sorry, we received a bad payload from the server"

