import Control.Concurrent (forkFinally)
import Control.Monad
import Control.Monad.Error
import Data.ConfigFile (readfile, emptyCP, get)
import Data.Either.Utils
import Data.List.Split (splitOn)
import Network (listenOn, withSocketsDo, accept, PortID(..))
import System.IO (hSetBuffering, hGetLine, hPutStrLn, BufferMode(..), Handle, hClose)
import System.IO.Error
import Text.Printf

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

showPage :: String -> Handle -> IO()
showPage "/" h = showPage "/index.html" h

showPage "/404" h = do 
  write404HTTPHeaders h
  hPutStrLn h ("<html><body><h4>" ++
                   "Thank you for using the " ++
                   "Haskell simple web service. But.." ++
                   "</h4><h2>404 Page not found. :(</h2></body></html>")

showPage (s:url) h =  do -- For all another pages
                        page <- tryIOError $ readFile url
                        case page of
                          Left _ -> showPage "/404" h
                          Right content -> writeHTTPHeaders h >> hPutStrLn h content


talk :: Handle -> String -> IO ()
talk h hostport = do
  hSetBuffering h LineBuffering
  loop
  where
    loop = do
      requestUrl <- readHTTPHeaders h
      showPage requestUrl h

main = withSocketsDo $ do
  {-rv <- runErrorT $ do
    cp <- join $ liftIO $ readfile emptyCP "config.cfg"
    serverport <- liftIO $ read $ get cp "DEFAULT" "port"-}
  let serverport = 8080 :: Int

  sock <- listenOn (PortNumber (fromIntegral serverport))
  printf "Listening on port %d\n" serverport
  forever $ do
    (handle, host, port) <- accept sock
    --printf "Accepted connection from %s: %s\n" host (show port)
    forkFinally (talk handle (host ++ ":" ++ (show port))) (\_ -> hClose handle)
