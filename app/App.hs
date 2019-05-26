{-# LANGUAGE OverloadedStrings #-}

module App ( MudApi
           , MudAction
           , app
           ) where

import Web.Spock

import AppTypes
import Actions ( getNote
               , getAllNotes
               , postNote
               , putNote
               , deleteNote )

app :: MudApi
app = do
  get ("note" <//> var) $ getNote
  get "notes" $ getAllNotes
  post "notes" $ postNote
  put ("note" <//> var) $ putNote
  delete ("note" <//> var) $ deleteNote
