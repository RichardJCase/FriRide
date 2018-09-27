import System.IO
import Qry

main :: IO ()
main = do
  hSetBuffering stdin  NoBuffering
  hSetBuffering stdout NoBuffering
  putStr "Enter username to ban: "
  uname <- getLine
  userInfo <- selectMatrix $ concat ["SELECT uname, email, address FROM users WHERE uname='", uname, "'"]
  let [_, email, address] = head userInfo
  runQry $ concat ["INSERT INTO blacklist VALUES ('",
                   uname, "', '",
                   email, "', '",
                   address, "')"]
  runQry $ concat ["DELETE FROM users where uname='", uname, "'"]
