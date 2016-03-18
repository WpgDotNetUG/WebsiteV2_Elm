module Actions (..) where

import Models exposing (Sponsor, BoardMember, Event, Video)

type Action
  = LoadSponsors (Maybe (List Sponsor))
  | LoadBoard    (Maybe (List BoardMember))
  | LoadEvents   (Maybe (List Event))
  | LoadVideos   (Maybe (List Video))
  | ToggleMenu
  | NoOp


