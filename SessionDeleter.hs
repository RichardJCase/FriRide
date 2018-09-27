import Qry
import Sec

{-
Auto deletes old rides and sessions.
-}

main :: IO ()
main = do
  ds <- dateString
  let nds = (take 6 ds) ++ "00"
  runQry $ concat ["DELETE FROM sessions WHERE lastUsed < '",
                   nds, "'"]
  runQry "DELETE FROM rides WHERE DATEDIFF(CURDATE(), created) >= 5"
