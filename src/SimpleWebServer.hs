import Network (listenOn, withSocketsDo, accept, PortID(..))
import System.IO (hSetBuffering, hGetLine, hPutStrLn, BufferMode(..), Handle, hClose)
import Control.Concurrent (forkFinally)
import Text.Printf
import Control.Monad
import Data.List.Split (splitOn)


readHTTPHeaders :: Handle -> IO String
readHTTPHeaders h = do
  requestLine <- hGetLine h
  let requestList = splitOn " " requestLine
  return (requestList !! 1)

writeHTTPHeaders :: Handle -> IO ()
writeHTTPHeaders h = do
  hPutStrLn h ("HTTP/1.1 200 OK")
  hPutStrLn h ("Server: 178.62.248.243")
  hPutStrLn h ("Content-Type: text/html; charset=utf-8")
  hPutStrLn h ("")

write404HTTPHeaders :: Handle -> IO ()
write404HTTPHeaders h = do
  hPutStrLn h ("HTTP/1.1 404 Not Found")
  hPutStrLn h ("Server: 178.62.248.243")
  hPutStrLn h ("Content-Type: text/html; charset=utf-8")
  hPutStrLn h ("")

links :: String
links = "<ul>"
      ++ "<li><a href=\"/about\">About server</a></li>"
      ++ "<li><a href=\"https://github.com/dummer/SimpleWebServer.hs\">Source code</a></li>"
      ++ "</ul>"

showPage :: String -> Handle -> IO()
showPage "/" h = do
  writeHTTPHeaders h
  hPutStrLn h ("<html><body><h4>" ++
                   "Thank you for using the " ++
                   "Haskell simple web service." ++
                   "</h4>" ++
                   links ++
                   "</body></html>")
showPage "/about" h = do
  writeHTTPHeaders h
  hPutStrLn h ("<html><body><h4>" ++
                   "Thank you for using the " ++
                   "Haskell simple web service." ++
                   "</h4>" ++
                   links ++
                   "</body></html>")

showPage _ h = do -- For all another pages
  write404HTTPHeaders h
  hPutStrLn h ("<html><body><h4>" ++
                   "Thank you for using the " ++
                   "Haskell simple web service. But.." ++
                   "</h4><h2>404 Page not found. :(</h2></body></html>")


talk :: Handle -> String -> IO ()
talk h hostport = do
  hSetBuffering h LineBuffering
  loop
  where
    loop = do
      requestUrl <- readHTTPHeaders h
      showPage requestUrl h

main = withSocketsDo $ do
  sock <- listenOn (PortNumber (fromIntegral port))
  printf "Listening on port %d\n" port
  forever $ do
    (handle, host, port) <- accept sock
    --printf "Accepted connection from %s: %s\n" host (show port)
    forkFinally (talk handle (host ++ ":" ++ (show port))) (\_ -> hClose handle)

port :: Int
port = 80
