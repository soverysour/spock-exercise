{-# LANGUAGE DeriveGeneric #-}

module TransferObjects ( Credentials(..)
                       ) where

import GHC.Generics
import Data.Text
import Data.Aeson

data Credentials = Credentials { credEmail :: Text
                               , credPassword :: Text
                               } deriving ( Generic, Show )

instance FromJSON Credentials
