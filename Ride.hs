{-# LANGUAGE OverloadedStrings #-}
module Ride where

import Control.Monad.IO.Class
import Data.Text.Lazy
import Data.List.Split as S
import Web.Scotty
import Home
import Qry
import Sec

selectRides :: ActionM()
selectRides = do
  nocache
  requireSession selectRides'

selectRides' :: String -> ActionM()
selectRides' cookie = do
  user <- liftIO $ getUser cookie
  loc <- param "loc"
  let coords = S.splitOn " " loc 
  let lat = read (coords!!0) :: Float
  let lon = read (coords!!1) :: Float

  let suser = sanitize user 
  let headers = ["available_rides", "ID", "rider", "driver", "dest", "from", "status", "comment", "created", "loc", "payment"]
  let qry = Prelude.concat ["SELECT rides.* FROM rides INNER JOIN users ON uname=rider WHERE ",
                            "SUBSTRING_INDEX(loc, ' ', 1) <=", show (lat + 0.25), " AND ",
                            "SUBSTRING_INDEX(loc, ' ', 1) >=", show (lat - 0.25), " AND ",
                            "SUBSTRING_INDEX(loc, ' ', -1) <=", show (lon + 0.25), " AND ",
                            "SUBSTRING_INDEX(loc, ' ', -1) >=", show (lon - 0.25), " AND ",
                            "rider!='", suser, "'"] 

  res <- liftIO $ jsonQry qry headers
  setHeader "Content-Type" "application/json"
  text $ pack $ res

requestRide :: ActionM()
requestRide = requireSession requestRide'

requestRide' :: String -> ActionM()
requestRide' cookie = do
  rider <- liftIO $ getUser $ sanitize cookie
  hasRequest <- liftIO $ hasQry $ Prelude.concat ["SELECT * FROM rides WHERE rider='", sanitize rider, "'"]
  if hasRequest then err else do
    dest <- param "to"
    from <- param "from"
    loc <- param "loc"
    comment <- param "comment"
    payment <- param "payment"

    let coords = Prelude.map read (S.splitOn " " loc) :: [Float]
    let slocs = Prelude.map show coords
    let sloc = Prelude.concat [slocs!!0, " ", slocs!!1]
    let qry = Prelude.concat ["INSERT INTO rides (rider, driver, dest, `from`, loc, status, comment, payment) VALUES (",
                               "'", sanitize rider, "',",
                               "'',",
                               "'", sanitize dest, "',",
                               "'", sanitize from, "',",
                               "'", sloc, "',",
                               "0, '", sanitize comment, "',",
                               "'", sanitize payment, "')"]
    if Prelude.length coords /= 2 then err
      else do
      liftIO $ runQry qry
      home

modifyRide :: ActionM()
modifyRide = do
  status <- param "status"
  requireSession (modifyRide' status)

modifyRide' :: String -> String -> ActionM()
modifyRide' status sid = do
  user <- liftIO $ getUser $ sanitize sid
  let suser = sanitize user
  rideID <- param "ID"
  mat <- liftIO $ selectMatrix $ Prelude.concat ["SELECT * FROM rides WHERE driver='", suser, "'"] 
  if (Prelude.length mat) >= 3 || status /= "1" then err
    else do
    rideMatrix <- liftIO $ selectMatrix $ Prelude.concat ["SELECT rider FROM rides WHERE ID=", sanitize rideID]
    let rider = rideMatrix!!0!!0
    userEmail <- liftIO $ getUserEmail rider
    liftIO $ sendEmail userEmail "Ride Status Update" "Another user is on their way to provide your ride."
    liftIO $ runQry $ Prelude.concat ["UPDATE rides SET status=",
                                      sanitize status, ", driver='", suser, "' ",
                                      "WHERE ID=", sanitize rideID, " AND rider!='",
                                      suser, "'"]
    home


updateRideStatus :: String -> String -> Bool -> IO ()
updateRideStatus user name True = do
  stat <- selectMatrix $ Prelude.concat ["SELECT status FROM rides where rider='",
                                          sanitize name,
                                          "' AND driver='",
                                          sanitize user, "'"]
  if (read (stat!!0!!0) :: Int) > 1 then updateRideStatus' name user 0
    else updateRideStatus' name user 2
  
updateRideStatus user name False = do
  stat <- selectMatrix $ Prelude.concat ["SELECT status FROM rides where rider='",
                                         sanitize user,
                                          "' AND driver='",
                                          sanitize name, "'"]
  if (read (stat!!0!!0) :: Int) > 1 then updateRideStatus' user name 0
    else updateRideStatus' user name 3

updateRideStatus' :: String -> String -> Int -> IO ()
updateRideStatus' rider driver nstat = do
  mat <- selectMatrix $ Prelude.concat ["SELECT TIMEDIFF(created, NOW()) FROM rides WHERE rider='", sanitize rider,
                                             "' AND driver='", sanitize driver, "'"]
  let tm = mat!!0!!0
  let hours = Prelude.take 2 $ Prelude.drop 1 tm
  let mins = read $ Prelude.take 2 $ Prelude.drop 4 tm :: Int
  if hours == "00" && mins < 10 then return () else do
    if nstat == 0 then
      runQry $ Prelude.concat ["DELETE FROM rides WHERE rider='", sanitize rider,
                               "' AND driver='", sanitize driver, "'"]
      else runQry $ Prelude.concat ["UPDATE rides SET status=", show nstat,
                                     " WHERE rider='", sanitize rider,
                                     "' AND driver='", sanitize driver, "'"]

myRides :: String -> ActionM()
myRides rd = do
  nocache
  requireSession (myRides' rd)

myRides' :: String -> String -> ActionM()
myRides' rd sid = do
  name <- liftIO $ getUser $ sanitize sid
  res <- liftIO $ queryRides rd name
  text $ pack $ res
