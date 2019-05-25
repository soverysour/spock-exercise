{-# LANGUAGE OverloadedStrings #-}

module Actions ( getAllNotes
               , getNote
               , postNote
               ) where

import Web.Spock

import qualified Database.Persist.Sqlite as Sql
import qualified Database.Persist        as P
import Data.Aeson (object, (.=), Value(String))

import AppTypes
import Types
import Sql ( runSql )
import Responding ( errorResponse )

getAllNotes :: MudAction a
getAllNotes = do
  result <- runSql $ P.selectList [] [Sql.Asc NoteId]
  json $ result

postNote :: MudAction a
postNote = do
  maybeNote <- jsonBody :: MudAction (Maybe Note)
  case maybeNote of
    Nothing ->
      json $ errorResponse 1 "Failed to parse request body as Note"
    Just theNote -> do
      newId <- runSql $ P.insert theNote
      json $ object ["result" .= String "success", "id" .= newId]

getNote :: Key Note -> MudAction a
getNote noteId = do
  maybeNote <- runSql $ P.get noteId :: MudAction (Maybe Note)
  case maybeNote of
    Nothing ->
      json $ errorResponse 2 "Could not find a note with matching id"
    Just theNote ->
      json theNote
