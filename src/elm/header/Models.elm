module Header.Models exposing (..)

import Http exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

import Components.HtmlHelpers exposing (divT, divL, iconFor, toggleIf, aBlank)
import Components.Videos as Videos exposing (youTube)
import Notify exposing (..)

-- Model
type alias Model = 
  { showSlack: Bool
  , slackEmail: String
  , openMenu: Bool
  }

type alias Email = String

type alias SlackResponse = 
  { ok: Bool
  , error: Maybe String
  }

emptyModel =
  { showSlack = False
  , slackEmail = ""
  , openMenu = False
  }



