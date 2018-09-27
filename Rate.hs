{-# LANGUAGE OverloadedStrings #-}
module Rate where

import Control.Monad.IO.Class
import Data.Text.Lazy
import Web.Scotty
import Home
import Sec
import Ride
import Qry

rate :: String -> ActionM()
rate title = do
  user <- param "user"
  email <- liftIO $ getUserEmail user 
  liftIO $ sendEmail email title "Visit https://friride.ddns.net to view the status of your rides."
  requireSession (rate' user)

rate' :: String -> String -> ActionM()
rate' user sid = do
  name <- liftIO $ getUser $ sanitize sid
  rating <- param "rating"
  let irating = read rating :: Int
  let rate = if irating > 2 || irating < -2 then "0" else show irating
  rd <- liftIO $ hasQry $ Prelude.concat ["SELECT * FROM rides where rider='",
                                          sanitize name,
                                          "' AND driver='",
                                          sanitize user, "' or rider='",
                                          sanitize user, "' AND driver='",
                                          sanitize name, "'"]
  if not rd then err 
    else do
    liftIO $ runQry $ Prelude.concat ["UPDATE users SET rep = rep + ",
                                      sanitize rate, " where uname='", sanitize user, "'"]
      
    rider <- liftIO $ hasQry $ Prelude.concat ["SELECT * FROM rides where rider='",
                                               sanitize name,
                                               "' AND driver='",
                                               sanitize user, "'"]
    liftIO $ updateRideStatus user name rider
    home

--to be used by android app primarily
toRate :: ActionM()
toRate = do
  nocache
  requireSession toRate'

toRate' :: String -> ActionM()
toRate' sid = do
  name <- liftIO $ getUser $ sanitize sid
  let rideqry = Prelude.concat ["SELECT *, '0' AS isdriver FROM rides WHERE rider='", sanitize name, "' AND status=1 OR status=3"]
  let driveqry = Prelude.concat ["SELECT *, '1' AS isdriver FROM rides WHERE driver='", sanitize name, "' AND status=1 OR status=2"]
  let headers = ["rides", "ID", "rider", "driver", "dest", "from", "status", "comment", "created", "loc", "isdriver"]

  rider <- liftIO $ hasQry rideqry
  if rider then do
    res <- liftIO $ jsonQry rideqry headers
    text $ pack $ res
    else do
    res <- liftIO $ jsonQry driveqry headers
    text $ pack $ res

cancelRide :: ActionM()
cancelRide = rate "Ride Cancelled"
