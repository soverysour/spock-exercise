{-# LANGUAGE OverloadedStrings #-}

module App ( MudApi
           , MudAction
           , app
           ) where

import Web.Spock
import qualified Network.HTTP.Types.Status as HTTP

import AppTypes
import Actions ( getUser
               , getAllUsers
               , updateUser
               , registerUser
               , loginUser
               , logoutUser )

authHook :: MudAction ()
authHook = do
  sess <- readSession
  case sess of
    Just _ -> return ()
    Nothing -> do
      setStatus $ HTTP.mkStatus 400 "You must be authenticated to perform this action."
      text "You must be authenticated to perform this action."

nonAuthHook :: MudAction ()
nonAuthHook = do
  sess <- readSession
  case sess of
    Nothing -> return ()
    Just _ -> do
      setStatus $ HTTP.mkStatus 400 "You must not be authenticated to perform this action."
      text "You must not be authenticated to perform this action."

app :: MudApi
app = do
  prehook nonAuthHook $ do
    post "auth/register" registerUser
    post "auth/login" loginUser
  prehook authHook $ do
    post "auth/logout" logoutUser

  prehook authHook $ do
    get ("user" <//> var) getUser
    get "users" getAllUsers
    put ("user" <//> var) updateUser
