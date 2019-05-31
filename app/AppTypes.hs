module AppTypes where

import Web.Spock
import Web.Spock.Config
import Database.Persist.Sqlite

import Types ( UserId )

type MudSession = Maybe UserId
type MudApi = SpockM SqlBackend MudSession () ()
type MudAction a = SpockAction SqlBackend MudSession () a
type MudConfig = SpockCfg SqlBackend MudSession ()
