{-# LANGUAGE OverloadedStrings #-}

import Control.Monad.IO.Class
import Web.Scotty
import Web.Scotty.TLS
import Home
import Rate
import Ride
import Sec
import Profile
import Qry

main :: IO ()
main = do
  liftIO $ putStrLn "Server started"
  handleRequests

handleRequests :: IO ()
handleRequests = scottyTLS 443 "server.key" "server.crt" $ do
  get "/" home
  get "/index.html" home
  post "/login" login
  post "/newaccount" createPotentialAccount
  get "/newaccount" createAccount
  get "/logout" endSession
  get "/profile" profile
  get "/username" username

  get "/ride" selectRides
  post "/ride" requestRide
  post "/modride" modifyRide --using get/post for simpler html/js
  put "/modride" modifyRide
  put "/ride" modifyRide
  post "/cancel" cancelRide

  get "/myrides" (myRides "rider")
  get "/mydrives" (myRides "driver")

  post "/rate" (rate "Rating Recieved")
  get "/torate" toRate
  
  post "/picedit" picedit
  put "/picedit" picedit
  post "/bioedit" bioedit
  put "/bioedit" bioedit
  post "/changepassword" changePassword
  put "/changepassword" changePassword
  put "/password" changePassword
  post "/forgotpassword" forgotPassword
  
  post "/deleteAccount" deleteAccount
  delete "/deleteAccount" deleteAccount
  delete "/profile" deleteAccount
  delete "/ride" cancelRide

  get (regex ".*\\.\\..*") Home.notFound --protect against dir traversal attacks
  get (regex ".*hs.*") Home.notFound --in case leaving source in same directory for live-ish dev
  get (regex ".*\\.html.+") serveHTML
  get (regex ".*\\..+") serveText
  
  Web.Scotty.notFound Home.notFound
  
