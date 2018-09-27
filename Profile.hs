{-# LANGUAGE OverloadedStrings #-}
module Profile where

import Control.Monad.IO.Class
import Data.ByteString as BP
import Data.ByteString.Lazy as BS
import Data.Text.Lazy as L
import Language.Haskell.TH.Ppr
import System.FilePath.Posix
import Web.Scotty
import Network.Wai.Parse
import Home
import Sec
import Qry

username :: ActionM()
username = do
  nocache
  ch <- header "Cookie"
  cookie <- getCookie "ID" ch
  case cookie of
    Nothing -> text "{\"name\": \"\"}"
    Just s -> username' s

username' :: String -> ActionM()
username' sid = do
  res <- liftIO $ jsonQry (Prelude.concat ["SELECT uname FROM sessions WHERE rid='", sanitize sid, "'"]) ["name", "uname"]
  setHeader "Content-Type" "application/json"
  text $ L.pack $ res

createPotentialAccount :: ActionM()
createPotentialAccount = do
  uname <- param "username"
  pass <- param "password"
  email <- param "email"
  if Prelude.any (\x -> x == "") [uname, pass, email] then
    serveHTMLFile "newaccount.html"
    else do
    key <- liftIO $ enterPotential uname pass email
    if key == "" then
      serveHTMLFile "accountexists.html"
      else do
      liftIO $ emailPotential email key 
      home

createAccount :: ActionM()
createAccount = do
  key <- param "key"
  valid <- liftIO $ validActivationKey key
  if valid then do
    liftIO $ enterAccount key
    home
    else
    serveHTMLFile "invalidkey.html"

profile :: ActionM()
profile = do
  nocache
  user <- param "user"
  ch <- header "Cookie"
  cookie <- getCookie "ID" ch
  case cookie of
    Nothing -> text "{}"
    Just s -> profile' user s

profile' :: String -> String -> ActionM()
profile' user sid = do
  res <- liftIO $ jsonQry (Prelude.concat ["SELECT image, rep, bio, sessions.uname=users.uname AS same FROM users, sessions WHERE users.uname='", sanitize user, "' AND sessions.rid='", sid, "'"]) ["user", "image", "rep", "bio", "same"]
  setHeader "Content-Type" "application/json"
  text $ L.pack $ res

picedit :: ActionM()
picedit = 
  verifySame picedit'

picedit' :: ActionM()
picedit' = do
  fs <- files
  user <- param "user"
  let (feildName, fdat) = fs!!0
  let fname = bytesToString $ BP.unpack $ fileName fdat
  let ext = takeExtension fname
  let npath = Prelude.concat ["profilepics/", user, ext]
  liftIO $ BS.writeFile npath (fileContent fdat)
  liftIO $ runQry $ Prelude.concat ["UPDATE users SET image='", sanitize npath, "'",
                                    " WHERE uname='", sanitize user, "'"]
  home
  
bioedit :: ActionM()
bioedit =  
  verifySame bioedit'

bioedit' :: ActionM()
bioedit' = do
  newbio <- param "bio"
  user <- param "user"
  liftIO $ runQry $ Prelude.concat ["UPDATE users SET bio='", sanitize newbio,
                                    "' WHERE uname='", sanitize user,
                                    "'"]
  home
