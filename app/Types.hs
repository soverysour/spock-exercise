{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE EmptyDataDecls #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies #-}

module Types where

import Data.Text
import Data.Time.Clock

import Database.Persist
import Database.Persist.Sqlite
import Database.Persist.TH

share [mkPersist sqlSettings, mkMigrate "migrateAll"] [persistLowerCase|
User json
  username  Text
  email Text
  password Text

  UniqueUsername username
  UniqueEmail email
  deriving Show

Conference json
  website Text
  information Text
  name Text
  startDate UTCTime
  abstractDate UTCTime
  submissionDate UTCTime
  presentationDate UTCTime
  endDate UTCTime

  mainChair (Key User)

  UniqueName name
  UniqueWebsite website
  deriving Show
|]
