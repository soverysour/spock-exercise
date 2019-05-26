{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE TypeFamilies #-}

module Main where

import System.Environment ( getEnv )
import Control.Monad ( when )

import Web.Spock
import Web.Spock.Config

import qualified Data.Text                  as T
import qualified Configuration.Dotenv       as Env
import qualified Configuration.Dotenv.Types as EnvT

import qualified Control.Monad.Logger    as L
import qualified Database.Persist.Sqlite as Sql

import App ( app )
import Types ( migrateAll )

data Environment = Environment { appPort :: Int
                               , dbName :: T.Text
                               , dbPool :: Int
                               , csrfProtection :: Bool
                               , runMigration :: Bool
                               }

appEnvironment :: IO Environment
appEnvironment = do
  port <- getEnv "appPort"
  name <- getEnv "dbName"
  pool <- getEnv "dbPool"
  csrf <- getEnv "csrfProtection"
  migration <- getEnv "runMigration"
  let port' = read port :: Int
      pool' = read pool :: Int
      name' = T.pack name
      csrf' = csrf == "true"
      migration' = migration == "true"
  return $ Environment { appPort = port'
                       , dbName = name'
                       , dbPool = pool'
                       , csrfProtection = csrf'
                       , runMigration = migration'
                       }

spockCfg :: IO (Environment, SpockCfg Sql.SqlBackend () ())
spockCfg = do
  appEnv <- appEnvironment
  pool <- L.runStdoutLoggingT $ Sql.createSqlitePool (dbName appEnv) (dbPool appEnv)
  when (runMigration appEnv) (L.runStdoutLoggingT $ Sql.runSqlPool (Sql.runMigration migrateAll) pool)
  spockCfg' <- defaultSpockCfg () (PCPool pool) ()
  return $ ( appEnv
           , spockCfg' { spc_csrfProtection = (csrfProtection appEnv) })

main :: IO ()
main = do
  _ <- Env.loadFile EnvT.defaultConfig
  (appEnv, spockConf) <- spockCfg
  runSpock (appPort appEnv) (spock spockConf app)
