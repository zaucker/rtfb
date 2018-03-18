RtFb
===
Version: 0.1.0
Date: 2018-03-18

Request Tracker feedback form handler

SETUP
-----

  * Copy etc/rft.cfg.dist to etc/rtfb.cfg and adapt file to your
    environment.

  * Install

  ./configure
  make
  make install

RUNNING
-------


Run rtfb like this:

   bin/rtfb.pl daemon --listen 'http://rtfb:3834'

To run behind a reverse proxy, add the --proxy option

   bin/rtfb.pl daemon --proxy --mode=production --listen 'http://rtfb:3834'

Enjoy!

Fritz Zaucker <fritz.zaucker@oetiker.ch>
