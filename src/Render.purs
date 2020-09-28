module Render where

import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Data.Maybe (Maybe(..), isJust)

import Types (Action(..), State, View(..))
  
render :: forall m. State -> H.ComponentHTML Action () m
render state =

  let 

    contentDiv :: H.ComponentHTML Action () m
    contentDiv = 
      case state.view of
        LoadingFile -> 
          HH.div_
            [ 
              HH.button [ HE.onClick \_ -> Just NewFile ] [ HH.text "New" ],
              HH.button [ HE.onClick \_ -> Just LoadFile ] [ HH.text "Load" ]
            ]
        MainMenu _ _ -> 
          HH.div_
            [ 
              HH.button [ HE.onClick \_ -> Just SaveFile ] [ HH.text "Save" ],
              HH.br_,
              HH.button [ HE.onClick \_ -> Just Review ] [ HH.text "Review" ],
              HH.br_,
              HH.input [ HE.onValueChange \val -> Just (UpdatePuzzleName val) ],
              HH.input [ HE.onValueChange \val -> Just (UpdateFEN val) ],
              HH.button [ HE.onClick \_ -> Just CreatePuzzle ] [ HH.text "Create" ]
            ]
        CreatingPuzzle _ _ _ ->
          HH.div_
            [ 
              HH.button [ HE.onClick \_ -> Just BackToMain ] [ HH.text "Back" ],
              HH.button [ HE.onClick \_ -> Just SavePuzzle ] [ HH.text "Save" ]
            ]

    alertDiv :: H.ComponentHTML Action () m
    alertDiv = 
      if isJust state.alert 
      then HH.div_ [ HH.button [ HE.onClick \_ -> Just CloseAlert ] [ HH.text "Close" ] ] 
      else HH.div_ []

  in 
  
    HH.div_ [contentDiv, alertDiv]