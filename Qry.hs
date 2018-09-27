module Qry where
import Data.List
import Database.HDBC
import Database.HDBC.MySQL

sanitize :: String -> String
sanitize qry =
  if bads \\ qry == bads then qry else ""
  where bads = ['\'', '"', '\\', '\b', '\0', '\n', '\r', '\t', '%', '_',
               '<', '>', '&']

runQry :: String -> IO ()
runQry qry = do
  conn <- connectMySQL defaultMySQLConnectInfo { {- sanitized -} }
  run conn qry []
  commit conn
  return ()

hasQry :: String -> IO Bool
hasQry qry = do
  conn <- connectMySQL defaultMySQLConnectInfo { {- sanitized -} }
  rows <- quickQuery' conn qry []
  return ((length rows) > 0)

selectQry :: String -> IO [[SqlValue]] 
selectQry qry = do
  conn <- connectMySQL defaultMySQLConnectInfo { {- sanitized -} }
  quickQuery' conn qry []

selectMatrix :: String -> IO [[String]]
selectMatrix qry = do
  dat <- selectQry qry
  return $ map (\row -> map (\n -> fromSql n) row) dat

getUser :: String -> IO String
getUser id = do
  dat <- selectMatrix $ Prelude.concat ["SELECT uname FROM sessions WHERE rid='",
                                        sanitize id, "'"]
  dat2 <- selectMatrix $ Prelude.concat ["SELECT uname FROM apikeys WHERE code='",
                                        sanitize id, "'"]

  let dz = (length dat) /= 0
  let dz2 = (length dat2) /= 0
  let dzs = (dz, dz2)
  case dzs of 
    (True, False) -> return $ dat!!0!!0 
    (False, True) -> return $ dat2!!0!!0
    _ -> return ""

getUserByEmail :: String -> IO String
getUserByEmail email = do
  dat <- selectMatrix $ Prelude.concat ["SELECT uname FROM users WHERE email='",
                                         sanitize email, "'"]
  if length dat == 0
    then return ""
    else return $ dat!!0!!0

getUserEmail :: String -> IO String
getUserEmail uname = do
  dat <- selectMatrix $ Prelude.concat ["SELECT email FROM users WHERE uname='",
                                         sanitize uname, "'"]
  if length dat == 0
    then return ""
    else return $ dat!!0!!0

tuplesToJson :: [[(String, String)]] -> String -> String
tuplesToJson [] ret = ret
tuplesToJson tups ret =
  tuplesToJson (tail tups) nret
  where nret = ret ++ "{" ++ added ++ "},"
        added = intercalate "," $ map (\(a,b) -> "\"" ++ a ++ "\":\"" ++ b ++ "\"") (head tups)

jsonQry :: String -> [String] -> IO String
{- Runs the query, and produces a JSON string result.
The first header is an array object, that holds objects with properties
of the given headers and resulting values from the query. 
-}
jsonQry qry headers = do
  dat <- selectMatrix qry
  let tups = map (\n -> zip props n) dat
  let json = tuplesToJson tups ""
  if (length json) == 0 then
    return "{}"
    else do
    let mid = init json
    return $ outpre ++ mid ++ "]}"
      where name = head headers
            props = tail headers
            outpre = "{\"" ++ name ++ "\":["

queryRides :: String -> String -> IO String
queryRides rd name =
  jsonQry qry ["rides", "ID", "rider", "driver", "from", "dest", "loc", "status"]
  where
    qry = concat ["SELECT * FROM rides WHERE ", rd, "='", name, "' AND status !=", nstat]
    nstat = if rd == "rider" then "2" else "3"
