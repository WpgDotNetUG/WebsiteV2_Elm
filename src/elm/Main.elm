module Main where

import StartApp
import Task exposing (Task)
import Signal exposing (Signal, Address)
import Effects exposing (Effects, Never)
import Html exposing (Html)
import Date
import Http
import Random

import Views exposing (..)
import Models exposing (..)
import Actions exposing (..)

--
-- StartApp boilerplate
--
app = StartApp.start { init = init, view = view, update = update, inputs = [] }

main : Signal Html
main = app.html

port tasks : Signal (Task Never ())
port tasks = app.tasks

port randomSeed : Int

--
-- My functions
--
init : (Model, Effects Action)
init =
  (emptyModel, Effects.batch [getSponsors, getBoard, getEvents, getVideos])

update : Action -> Model -> (Model, Effects Action)
update action model = 
  case action of
    LoadSponsors (Just loaded)  -> ({model | sponsors= loaded }, Effects.none)
    LoadBoard    (Just members) -> ({model | board   = members}, Effects.none)
    LoadVideos   (Just videos)  -> ({model | videos  = videos, seed = randomSeed |> Random.initialSeed }, Effects.none)
    LoadEvents   (Just events)  -> (assignEvents events model, Effects.none)
    ToggleMenu                  -> ({model | openMenu=not model.openMenu}, Effects.none)
    _ -> (model, Effects.none)

assignEvents events model =
  let
    completed = events |> List.filter (\e -> e.status == Completed)
    maybeNext = events |> List.filter (\e -> e.status == Live) |> List.head
  in {model | next=maybeNext, pastEvents=completed}

-- Api queries

apiUrl = "http://api.winnipegdotnet.org/api/"
-- apiUrl = "http://localhost:8083/api/"

getResource resource decoder loader =
  apiUrl ++ resource
  |> Http.get decoder
  |> Task.toMaybe
  |> Task.map loader
  |> Effects.task

getEvents = getResource "events" eventDecoder LoadEvents

getBoard = getResource "board" boardDecoder LoadBoard

getSponsors = getResource "sponsors" sponsorDecoder LoadSponsors

getVideos = getResource "videos" videoDecoder LoadVideos

