{-# LANGUAGE OverloadedStrings #-}

module Responding (errorResponse) where

import Data.Text
import Data.Aeson

errorResponse :: Int -> Text -> Value
errorResponse code message =
  object
  [ "result" .= String "failure"
  , "error" .= object ["code" .= code, "message" .= message]
  ]
