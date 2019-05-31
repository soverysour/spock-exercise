module AppConfig ( appConfig
                 , Environment(..)
                 ) where

import qualified Control.Monad.Logger    as L
import qualified Database.Persist.Sqlite as Sql
import qualified Data.Text               as T

import System.Environment ( getEnv )
import Control.Monad ( when )

import Web.Spock.Config

import Types ( migrateAll )
import AppTypes

data Environment = Environment { appPort :: !Int
                               , dbName :: !T.Text
                               , dbPool :: !Int
                               , csrfProtection :: !Bool
                               , runMigration :: !Bool
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

appConfig :: IO (Environment, MudConfig)
appConfig = do
  appEnv <- appEnvironment
  pool <- L.runStdoutLoggingT $ Sql.createSqlitePool (dbName appEnv) (dbPool appEnv)
  when (runMigration appEnv) (L.runStdoutLoggingT $ Sql.runSqlPool (Sql.runMigration migrateAll) pool)
  spockCfg' <- defaultSpockCfg Nothing (PCPool pool) ()
  return $ ( appEnv
           , spockCfg' { spc_csrfProtection = (csrfProtection appEnv) })

