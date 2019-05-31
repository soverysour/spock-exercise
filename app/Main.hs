{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE TypeFamilies #-}

module Main where

import Web.Spock ( runSpock
                 , spock )

import Configuration.Dotenv ( loadFile )
import Configuration.Dotenv.Types ( defaultConfig )

import App ( app )
import AppConfig ( appConfig
                 , appPort )

main :: IO ()
main = do
  _ <- loadFile defaultConfig
  (appEnv, spockCfg) <- appConfig
  runSpock (appPort appEnv) (spock spockCfg app)
