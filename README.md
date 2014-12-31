SimpleWebServer.hs
==================

Multithreaded simple web server. With hardcoded pages, yet.

Building and running
====================

Run `build.sh` to build. Then run `sudo ./SimpleWebServer` to launch the server. `Sudo` require because server trying occupy port `80`. If set `port` > 1024 then becomes possible to run server without root privilege.
