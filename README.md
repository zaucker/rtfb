RtFb
===
Version: 0.1.0
Date: 2018-06-19

Request Tracker feedback form handler

RT Setup
--------

  * Create Ticket Customfield 'Feedback Kommentar'

  * Install etc/RT-Feedback-Template.dist as resolve scrip
    ( fix "use lib" statement at the beginning )

  * Create a RtFb_FeedbackSecret config variable in your RT_SiteConfig.pm
    (optionally, defaults to value in lib/RtFb.pm)

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

* Set RTHOME environment variable to your RT install directory

* Run rtfb like this:

     bin/rtfb.pl daemon --listen 'http://*:8520'

  To run behind a reverse proxy, add the --proxy option

     bin/rtfb.pl daemon --proxy --mode=production --listen 'http://*:8520'

Enjoy!

Fritz Zaucker <fritz.zaucker@oetiker.ch>
