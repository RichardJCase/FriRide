{-# LANGUAGE OverloadedStrings #-}
module Home where

import System.Directory
import Control.Monad.IO.Class
import Data.Text.Lazy as L
import Data.List
import Data.List.Split as S
import Web.Scotty

nocache :: ActionM()
nocache = do
  setHeader "Cache-Control" "no-cache, no-store, must-revalidate"
  setHeader "Pragma" "no-cache"
  setHeader "Expires" "0"

serveHTMLFile :: String -> ActionM()
serveHTMLFile fileName = do
  setHeader "Content-Type" "text/html"
  file fileName
  
serveHTML :: ActionM()
serveHTML = do
  path <- param "0"
  let fpath = Prelude.tail $ L.unpack path
  exists <- liftIO $ doesFileExist fpath
  if exists then 
    serveHTMLFile fpath
    else Home.notFound
  
serveText :: ActionM()
serveText = do
  path <- param "0"
  let fpath = Prelude.tail $ L.unpack path
  exists <- liftIO $ doesFileExist fpath
  if exists then 
    file fpath
    else Home.notFound

home :: ActionM()
home = do
  nocache
  ch <- header "Cookie"
  cookie <- getCookie "ID" ch
  case cookie of
    Nothing -> serveHTMLFile "index.html"
    Just s -> do
      if s == "deleted" then serveHTMLFile "index.html"
        else serveHTMLFile "home.html"

err :: ActionM()
err = serveHTMLFile "error.html"

notFound :: ActionM()
notFound =
  serveHTMLFile "notfound.html"

safeNth :: [a] -> Int -> Maybe a
safeNth lst n =
  if (n >= (Prelude.length lst) || n < 0) then
    Nothing
    else return $ lst!!n

cookieSearch :: String -> String -> Maybe String
cookieSearch cookie name =
  case namevalPos of
    Nothing -> Nothing
    Just n -> safeNth mappings (n+1)
  where mappings = S.splitOn "=" cookie
        namevalPos = elemIndex name mappings

getCookie :: String -> Maybe L.Text -> ActionM (Maybe String)
getCookie name cookieHeader = do
  case cookieHeader of
    Nothing -> return Nothing
    Just s -> return $ cookieSearch (L.unpack s) name

requireSession :: (String -> ActionM()) -> ActionM()
requireSession f = do  
  ch <- header "Cookie"
  cookie <- getCookie "ID" ch
  case cookie of
    Nothing -> err
    Just s -> f s
