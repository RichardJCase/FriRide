{-# LANGUAGE OverloadedStrings #-}
module Sec where

import Control.Monad.IO.Class
import Control.Exception
import Data.Char
import Data.ByteString.Char8 as C8
import Data.Text as T
import Data.Text.Lazy as Lazy
import Data.List as L
import Data.Time.Calendar
import Data.Time.Clock
import Crypto.Random.API
import Web.Scotty
import Network.Mail.Mime
import Network.Mail.Client.Gmail
import Qry
import Home
import System.IO

login :: ActionM()
login = do
  uname <- param "username"
  pass <- param "password"
  valid <- liftIO $ validLogin uname pass
  if valid then do
    liftIO $ deleteSessions uname
    beginSession uname
    else serveHTMLFile "denied.html"

beginSession :: String -> ActionM()
beginSession uname = do
  rID <- liftIO $ genID uname
  setHeader "Set-Cookie" (Lazy.pack $ Prelude.concat ["ID=", show rID, "; Expires=Fri, 01 Feb 2030 06:00:00 GMT; HttpOnly"])
  serveHTMLFile "home.html"

endSession :: ActionM()
endSession = do
  nocache
  ch <- header "Cookie"
  cookie <- getCookie "ID" ch
  case cookie of
    Nothing -> serveHTMLFile "index.html"
    Just s -> endSession' s

endSession' :: String -> ActionM()
endSession' sid = do
  liftIO $ runQry $ Prelude.concat ["DELETE FROM sessions WHERE rid='", sanitize sid, "'"]
  setHeader "Set-Cookie" "ID=deleted"
  serveHTMLFile "index.html"

dateString :: IO String
dateString = do
  ct <- getCurrentTime
  let ds = show $ utctDay ct
  return $ Prelude.filter (\x -> x /= '-') ds

randNumber :: IO Int
randNumber = {- sanitized -}

genID :: String -> IO Int
genID uname = do
  rid <- randNumber
  hasID <- hasQry $ "SELECT rid FROM sessions where rid='" ++ (show rid) ++ "'"
  ds <- dateString
  if hasID then
    genID uname
    else do
    runQry $ Prelude.concat ["INSERT INTO sessions (rid, uname, lastUsed) VALUES ('",
                     show rid, "','", sanitize uname, "', '", ds,"')"]
    return rid

validLogin :: String -> String -> IO Bool
validLogin uname pass = do
  hasQry qry
  where qry = Prelude.concat ["SELECT * FROM users WHERE uname='",
                              sanitize uname, "' AND password=AES_ENCRYPT('", sanitize pass, "', UNHEX(SHA2({- sanitized -}, 512)))"]

validActivationKey :: String -> IO Bool
validActivationKey key = hasQry $ Prelude.concat ["SELECT * FROM potential WHERE ukey='",
                                                  sanitize key, "'"]

enterPotential :: String -> String -> String -> IO String
enterPotential uname pass email = do
  inPotential <- qrytbl "potential"
  inBlacklist <- qrytbl "blacklist"
  inUsers <- qrytbl "users"
  let s = Prelude.drop (Prelude.length email - 10) email
  let notGmail = s /= "@gmail.com"
  if (inPotential || inUsers || inBlacklist || notGmail) then return ""
    else do
    rid <- randNumber --don't care about very slim chance of verifying multiple users
    
    runQry $ Prelude.concat ["INSERT INTO potential VALUES ('", show rid,
                     "', '", sanitize uname,
                     "', AES_ENCRYPT('", sanitize pass,
                     "', UNHEX(SHA2({- sanitized -}, 512))), '", sanitize email,
                     "', 'profilepics/default.png')"]
    return $ show rid
  where qrytbl tbl = hasQry $ Prelude.concat ["SELECT * FROM ", sanitize tbl,
                                              " WHERE email='", sanitize email,
                                              "' OR uname='", sanitize uname, "'"]


sendEmail :: String -> String -> String -> IO ()
sendEmail email title body =
  catch (sendGmail "fririderideshare" {- sanitized -} (Address (Just "fririderideshare") {- sanitized -}) to [] [] subject ebody [] timeout) (\e -> sendEmail' e email title body 2)
  where to = [Address (Nothing) (T.pack email)]
        subject = T.pack title
        ebody = Lazy.pack $ body ++ "\n\n"
        timeout = 10000000

sendEmail' :: GmailException -> String -> String -> String -> Int -> IO ()
sendEmail' Timeout email title body 0 = System.IO.putStrLn "Too many gmail timeouts."
sendEmail' Timeout email title body count =
  catch (sendGmail "fririderideshare" {- sanitized -} (Address (Just "fririderideshare") {- sanitized -}) to [] [] subject ebody [] timeout) (\e -> sendEmail' e email title body (count-1))
  where to = [Address (Nothing) (T.pack email)]
        subject = T.pack title
        ebody = Lazy.pack $ body ++ "\n\n"
        timeout = 10000000

sendEmail' _ email title body count = System.IO.putStrLn "Gmail exception"


emailPotential :: String -> String -> IO ()
emailPotential email key =
  sendEmail email subject ebody
  where subject = "FriRide Registration"
        ebody = "Your registraction is almost complete,\n\nClick the following link to finish your registration: " ++ url ++ "\n\n"
        url = "https://friride.ddns.net/newaccount?key=" ++ key
 
enterAccount :: String -> IO ()
enterAccount key = do
  runQry $ Prelude.concat ["INSERT INTO users ",
                  "(SELECT uname, password, email, image, 0, '' FROM ",
                  "potential WHERE ukey='", sanitize key, "')"]
  runQry $ "DELETE FROM potential WHERE ukey='" ++ sanitize key ++ "'"
  
verifySame :: ActionM() -> ActionM()
verifySame func = do
  requireSession (verifySame' func)

verifySame' :: ActionM() -> String -> ActionM()
verifySame' func sid = do
  user <- param "user"
  same <- liftIO $ hasQry $ Prelude.concat ["SELECT rid FROM sessions INNER JOIN users ON",
                                            " sessions.uname=users.uname WHERE rid='",
                                            sanitize sid, "' AND users.uname='", sanitize user, "'"]
  if same then func else err

setPassword :: String -> String -> IO()
setPassword uname newpass = do
  liftIO $ runQry $ Prelude.concat ["UPDATE users SET password=AES_ENCRYPT('",
                                    sanitize newpass, "', UNHEX(SHA2({- sanitized -}, 512))) WHERE uname='", sanitize uname, "'"]

changePassword :: ActionM()
changePassword = do
  oldpass <- param "oldpass"
  newpass <- param "newpass"
  user <- param "user"

  userdata <- liftIO $ selectMatrix $ Prelude.concat ["SELECT * FROM users where uname='",
                                                      sanitize user, "' AND password=AES_ENCRYPT('", sanitize oldpass, "', UNHEX(SHA2({- sanitized -}, 512)))"]
  if L.length userdata /= 0 then do
    verifySame (changePassword' user newpass)
    else err

changePassword' :: String -> String -> ActionM()
changePassword' user newpass = do
  liftIO $ setPassword user newpass
  home

forgotPassword :: ActionM()
forgotPassword = do
  email <- param "email"
  rn <- liftIO $ randNumber
  user <- liftIO $ getUserByEmail $ sanitize email
  let newpass = "temp" ++ show rn
  liftIO $ sendEmail email "FriRide - Password Change" ("Please change your password as soon as you log-in.\n\nYour temporary password is " ++ newpass) 
  liftIO $ setPassword user newpass
  home

deleteSessions :: String -> IO ()
deleteSessions uname = 
  runQry $ Prelude.concat ["DELETE FROM sessions WHERE uname='", sanitize uname, "'"]

deleteAccount :: ActionM()
deleteAccount = verifySame deleteAccount'

deleteAccount' :: ActionM()
deleteAccount' = do
  uname <- param "user"
  let sname = sanitize uname
  liftIO $ deleteSessions uname
  liftIO $ runQry $ Prelude.concat ["DELETE FROM rides WHERE rider='", sname, "' OR driver='", sname, "'"]
  liftIO $ runQry $ Prelude.concat ["DELETE FROM users WHERE uname='", sname, "'"]
  serveHTMLFile "index.html"
  
