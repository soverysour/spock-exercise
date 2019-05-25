{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE GADTs #-}

module Sql ( runSql ) where

import Web.Spock

import qualified Database.Persist.Sqlite as Sql
import qualified Control.Monad.Logger    as L

runSql :: (HasSpock m, SpockConn m ~ Sql.SqlBackend) => Sql.SqlPersistT (L.LoggingT IO) a -> m a
runSql action = runQuery $ \conn -> L.runStdoutLoggingT $ Sql.runSqlConn action conn
