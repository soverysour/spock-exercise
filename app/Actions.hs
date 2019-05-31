{-# LANGUAGE OverloadedStrings #-}

module Actions ( getAllUsers
               , getUser
               , updateUser
               , registerUser
               , loginUser
               , logoutUser
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
import TransferObjects ( Credentials(..) )

getAllUsers :: MudAction a
getAllUsers = do
  result <- runSql $ P.selectList [] [Sql.Asc UserId]
  json $ result

getUser :: Key User -> MudAction a
getUser noteId = do
  maybeUser <- runSql $ P.get noteId :: MudAction (Maybe User)
  case maybeUser of
    Nothing -> do
      setStatus $ HTTP.mkStatus 404 "User not found."
      text ""
    Just theUser ->
      json theUser

updateUser :: Key User -> MudAction a
updateUser noteId = do
  maybeUser <- jsonBody :: MudAction (Maybe User)
  case maybeUser of
    Nothing -> do
      setStatus $ HTTP.mkStatus 400 "Bad note data given."
      text ""
    Just theUser -> do
      newId <- runSql $ P.replace noteId theUser :: MudAction ()
      setStatus $ HTTP.mkStatus 201 "User updated."
      json $ object ["result" .= String "success", "id" .= newId]

registerUser :: MudAction a
registerUser = do
  maybeUser <- jsonBody :: MudAction (Maybe User)
  case maybeUser of
    Nothing -> do
      setStatus $ HTTP.mkStatus 400 "Bad note data given."
      text ""
    Just theUser -> do
      newId <- runSql $ P.insert theUser
      setStatus $ HTTP.mkStatus 201 "User registered."
      redirect "/"

loginUser :: MudAction ()
loginUser = do
  maybeCreds <- jsonBody :: MudAction (Maybe Credentials)
  case maybeCreds of
    Nothing -> do
      setStatus $ HTTP.mkStatus 400 "Improper credentials format given."
      text ""
    Just creds -> do
      maybeUser <- runSql . P.getBy $ UniqueEmail (credEmail creds)
      case maybeUser of
        Nothing -> do
          setStatus $ HTTP.mkStatus 400 "No such user exists."
          text ""
        Just (P.Entity userId user) -> do
          if userPassword user /= credPassword creds
            then do
              setStatus $ HTTP.mkStatus 400 "Bad password."
              text ""
            else do
              modifySession ( \_ -> Just userId )
              setStatus $ HTTP.mkStatus 201 "User logged in."
              redirect "/"

logoutUser :: MudAction ()
logoutUser = do
  modifySession ( \_ -> Nothing )
  redirect "/"
