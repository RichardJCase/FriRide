import System.IO
import Qry

main :: IO ()
main = do
  hSetBuffering stdin NoBuffering
  hSetBuffering stdout NoBuffering
  putStr "Enter username to provide key: "
  uname <- getLine
  runQry $ concat ["INSERT INTO apikeys VALUES ('",
                    uname, "', SHA2(CONCAT(NOW(), 100000 * RAND()), ''), 0)"]
