RtFb
===
Version: 0.1.0
Date: 2018-06-19

Request Tracker feedback form handler

RT Setup
--------

  * Create Queues "Feedback" and "UpdateUserLanguage"

    Make sure that there are no scrips doing funny things to tickets
    in these queues. Specifically (SwitchPlus), add this code at the
    beginning of the action preparation code of scrips "QueueMover"
    and "Merge Tickets of same Requestor":

    my $IGNORED_A = {
        Feedback => 1,
        UpdateUserLanguage => 1,
    };
    return 0 if exists $IGNORED_A->{$queueName};

  * Adapt config variables in RT_SiteConfig_d_Feedback.pm.dist to your local
    requirements and copy this file to $RTHOME/etc/RT_SiteConfig.d/Feedback.pm

    Create a RtFb_FeedbackSecret config variable in Feedback.pm
    (optionally, defaults to value in lib/RtFb.pm)

    Restart the rt service after changing the above config file.

  * Create Ticket Customfields:

    - 'Feedback' (select one from list with values from
                  $RtFb_FeedbackForm->{selection}[]{value})

    - 'Feedback Kommentar' (enter one)

  * Create Scrip FeedbackOnResolve:

    - Condition: On Resolve
    - Action: Notify Requestors
    - Template: copy from etc/RT/FeedbackOnResolve.tmpl
                (fix "use lib" statement at the beginning)

  * Create Scrip UpdateUserLanguage:

    - Condition: On Create
    - Action: User Defined
    - Template: Blank

    User custom action code from etc/RT-UpdateUserLanguage.scrip

  * Multilingual Autoresponse scrips:

    - create templates from etc/RT/Autoreply_multilingual.tmpl
      and etc/RT/Autoreply_multilingual_busy.tmpl
      and configure the autoreply scrip to use one of them

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
