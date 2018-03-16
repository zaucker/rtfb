RtFb
======
Version: 0.1.0
Date: 2016-10-05

The shop software used to sell the Oltner-Kalender.

SETUP
-----

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

Tobias Oetiker <tobi@oetiker.ch>
