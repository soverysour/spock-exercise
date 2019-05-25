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

import qualified Data.Text           as T
import qualified Database.Persist.TH as Th

Th.share [Th.mkPersist Th.sqlSettings, Th.mkMigrate "migrateAll"] [Th.persistLowerCase|
Note json
  author T.Text
  content T.Text
  deriving Show
|]
