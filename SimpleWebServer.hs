import Network (listenOn, withSocketsDo, accept, PortID(..))
import System.IO (hSetBuffering, hGetLine, hPutStrLn, BufferMode(..), Handle, hClose)
import Control.Concurrent (forkFinally)
import Text.Printf
import Control.Monad

talk :: Handle -> IO ()
talk h = do
  hSetBuffering h LineBuffering
  loop
  where
    loop = do
      line <- hGetLine h
      hPutStrLn h ("<html><body><h4>" ++
                   "Thank you for using the " ++
                   "Haskell simple web service." ++
                   "</h4></body></html>")

main = withSocketsDo $ do
  sock <- listenOn (PortNumber (fromIntegral port))
  printf "Listening on port %d\n" port
  forever $ do
    (handle, host, port) <- accept sock
    printf "Accepted connection from %s: %s\n" host (show port)
    forkFinally (talk handle) (\_ -> hClose handle)

port :: Int
port = 80
