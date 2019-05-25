module AppTypes where

import Web.Spock
import Database.Persist.Sqlite

type MudApi = SpockM SqlBackend () () ()
type MudAction a = SpockAction SqlBackend () () a
