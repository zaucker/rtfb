RtFb
===
Version: 0.1.0
Date: 2018-06-19

Request Tracker feedback form handler

RT Setup
--------

  * Add config variables from etc/RT_SiteConfig.pm.dist to
    $RTHOME/etc/RT_SiteConfig.pm and adapt to local requirements

    Create a RtFb_FeedbackSecret config variable in your
    RT_SiteConfig.pm (optionally, defaults to value in lib/RtFb.pm)

  * Create Ticket Customfields:

    - 'Feedback' (select one from list with values from
                  $RtFb_FeedbackForm->{selection}[]{value})

    - 'Feedback Kommentar' (enter one)

  * Install etc/RT-Feedback-Template.dist as resolve scrip
    ( fix "use lib" statement at the beginning )


SETUP
-----

  * Copy etc/rft.cfg.dist to etc/rtfb.cfg and adapt file to your
    environment.

  * Install

  ./configure --prefix=/opt/rtfb
  make
  make install

RUNNING
-------

* Run rtfb like this:

     RTHOME=/opt/rt441 bin/rtfb.pl daemon --listen 'http://*:8520'

  To run behind a reverse proxy, add the --proxy option

     RTHOME=/opt/rt441 bin/rtfb.pl daemon --proxy --mode=production --listen 'http://*:8520'

  In a start script the RTHOME environment variable can instead be set to RT install directory.

* Adapt etc/rtfb.service.dist and install to /etc/systemd/service

Enjoy!

Fritz Zaucker <fritz.zaucker@oetiker.ch>
