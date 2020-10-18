module Main where

import Prelude (Unit, bind, unit, discard)

import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Aff.Class (class MonadAff)
import Halogen as H
import Halogen.Aff as HA
import Halogen.HTML as HH
import Halogen.VDom.Driver (runUI)
import Web.HTML (window)
import Web.HTML.Window (alert)
import Control.Applicative (pure)

import Types
import Reducer (reducer)
import Render (render, alertText)
import Chess (getMove)
import File (saveFile, openFileDialog)

import Effect.Class.Console (log)

main :: Effect Unit
main = HA.runHalogenAff do
  body <- HA.awaitBody
  runUI component unit body

component :: forall q i o m. MonadAff m => H.Component HH.HTML q i o m
component =
  H.mkComponent
    { 
      initialState, 
      render, 
      eval: H.mkEval H.defaultEval { handleAction = handleAction }
    }

initialState :: forall i. i -> State
initialState _ = { puzzles: [], reviewStack: [], view: LoadingFile, alert: Nothing }

-- Implementing IO/async logic here but delegating pure logic to the reducer
handleAction :: forall o m. MonadAff m => Action -> H.HalogenM State Action () o m Unit
handleAction action = do

  -- First we apply the action and get the new state
  H.modify_ \state -> reducer state action
  stateAfterAction <- H.get

  -- For testability reasons we want the alert to be represented in the state
  -- If a "Just alert" is found, the alert is removed from the state and rendered
  case stateAfterAction.alert of
    Just alertInState -> do
      w <- H.liftEffect window
      H.liftEffect (alert (alertText alertInState) w)
      H.modify_ \stateWithAlert -> stateWithAlert { alert = Nothing }
    Nothing ->
      pure unit

  -- Firing off the rest of the Effects and Affs
  case action of
    CreatePuzzle -> do
      move <- H.liftAff (getMove (boardFEN stateAfterAction) "")
      H.modify_ \newPuzzleState -> reducer newPuzzleState (AddMoveToNewPuzzle move)
    SaveFile -> do
      H.liftEffect (saveFile "testFileName.txt" "test file content.")
      pure unit
    LoadFile -> do
      textInFile <- H.liftAff (openFileDialog 0)
      log "<<<"
      log textInFile
      log ">>>"
    _ ->
      pure unit

boardFEN :: State -> FEN
boardFEN state = case state.view of
  CreatingPuzzle _ fen _ -> fen
  _ -> ""