{-# LANGUAGE OverloadedStrings #-}

module App ( MudApi
           , MudAction
           , app
           ) where

import Web.Spock

import AppTypes
import Actions ( getNote
               , getAllNotes
               , postNote )

app :: MudApi
app = do
  post "notes" $ postNote
  get "notes" $ getAllNotes
  get ("note" <//> var) $ getNote
