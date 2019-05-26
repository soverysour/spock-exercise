{-# LANGUAGE OverloadedStrings #-}

module Actions ( getAllNotes
               , getNote
               , postNote
               , putNote
               , deleteNote
               ) where

import Web.Spock
import Web.Spock.Action ( setStatus )

import qualified Database.Persist.Sqlite as Sql
import qualified Database.Persist        as P
import Data.Aeson (object, (.=), Value(String))
import qualified Network.HTTP.Types.Status as HTTP

import AppTypes
import Types
import Sql ( runSql )

getAllNotes :: MudAction a
getAllNotes = do
  result <- runSql $ P.selectList [] [Sql.Asc NoteId]
  json $ result

postNote :: MudAction a
postNote = do
  maybeNote <- jsonBody :: MudAction (Maybe Note)
  case maybeNote of
    Nothing -> do
      setStatus $ HTTP.mkStatus 400 "Bad note data given."
      json $ object []
    Just theNote -> do
      newId <- runSql $ P.insert theNote
      setStatus $ HTTP.mkStatus 201 "Note created."
      json $ object ["result" .= String "success", "id" .= newId]

getNote :: Key Note -> MudAction a
getNote noteId = do
  maybeNote <- runSql $ P.get noteId :: MudAction (Maybe Note)
  case maybeNote of
    Nothing -> do
      setStatus $ HTTP.mkStatus 404 "Note not found."
      json $ object []
    Just theNote ->
      json theNote

deleteNote :: Key Note -> MudAction a
deleteNote noteId = do
  runSql $ P.delete noteId :: MudAction ()
  json $ object [ "result" .= String "success", "id" .= noteId]

putNote :: Key Note -> MudAction a
putNote noteId = do
  maybeNote <- jsonBody :: MudAction (Maybe Note)
  case maybeNote of
    Nothing -> do
      setStatus $ HTTP.mkStatus 400 "Bad note data given."
      json $ object []
    Just theNote -> do
      newId <- runSql $ P.replace noteId theNote :: MudAction ()
      setStatus $ HTTP.mkStatus 201 "Note updated."
      json $ object ["result" .= String "success", "id" .= newId]
