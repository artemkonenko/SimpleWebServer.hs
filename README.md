SimpleWebServer.hs
==================

Multithreaded simple web server. With hardcoded pages and ip in response http header, yet.

[![Build Status](https://travis-ci.org/dummer/SimpleWebServer.hs.svg?branch=master)](https://travis-ci.org/dummer/SimpleWebServer.hs)

Building and running
====================

Run `cabal install` to install dependences and build server. Then run `sudo cabal run` to launch the server. `Sudo` require because server trying occupy port `80`. If set `port` > 1024 then becomes possible to run server without root privilege.
