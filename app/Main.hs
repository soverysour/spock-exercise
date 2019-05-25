{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE TypeFamilies #-}

module Main where

import Web.Spock
import Web.Spock.Config

import qualified Control.Monad.Logger    as L
import qualified Database.Persist.Sqlite as Sql

import App ( app )
import Types ( migrateAll )

spockCfg :: IO (SpockCfg Sql.SqlBackend () ())
spockCfg = do
  pool <- L.runStdoutLoggingT $ Sql.createSqlitePool "db/api.db" 5
  L.runStdoutLoggingT $ Sql.runSqlPool (Sql.runMigration migrateAll) pool
  spockCfg' <- defaultSpockCfg () (PCPool pool) ()
  return $ spockCfg' { spc_csrfProtection = True }

main :: IO ()
main = do
  configuration <- spockCfg
  runSpock 8080 (spock configuration app)
