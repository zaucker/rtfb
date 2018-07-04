package RtFb;

use Mojo::Base 'Mojolicious';
use Mojo::JSON qw(encode_json);
use Mojo::Util qw(dumper);

use Digest::MD5 qw(md5_hex);
use RtFb::Command::loadUser;
use RtFb::Config;
use RtFb::Feedback;
use RT;

our $VERSION = "0.2.0";

=head1 NAME

RtFb - Application Class

=head1 SYNOPSIS

 rtfb.pl COMMAND

=head1 DESCRIPTION

Configure the mojolicious engine to run our application logic

=cut

=head1 ATTRIBUTES

RtFb has all the attributes of L<Mojolicious> plus:

=cut
# initialize rt via $c->app->rtInit while processing
# the request to make sure running RT db connections do not get
# forked since mojolicious shares ALL filehandels between forks
# which leads to confusion for the RT db connection.

sub rtInit {
    my $app = shift;
    state $init;
    if (not $init){
        $app->log->debug('starting RT connection');
        RT->LoadConfig();
        RT->Init();

        $app->log->debug('initialized');
        $app->log->debug('RT ready');
        $init = 1;
    }
}

=head2 config

use our own plugin directory and our own configuration file:

=cut

has config => sub {
    my $app = shift;
    RtFb::Config->new(
        app => $app,
        file => $ENV{RTFB_CFG} || $app->home->rel_file('etc/rtfb.cfg' )
    );
};

has feedbackForm => sub {
    RT->Config->Get('RtFb_FeedbackForm');
};

has responseText => sub {
    RT->Config->Get('RtFb_FeedbackResponse');
};

has md5secret => sub {
    RT->Config->Get('RtFb_FeedbackSecret') // '42dsf2354';
};

sub md5Hash {
    my $c        = shift;
    my $ticketId = shift;
    return md5_hex($ticketId . $c->md5secret);
}


sub startup {
    my $app = shift;
    $app->plugin("OpenAPI" => {
        spec => $app->home->rel_file('share/openapi.yaml'),
    });

    push @{$app->commands->namespaces}, 'RtFb::Command';

    my $cfg = $app->config->cfgHash;
    $app->commands->message("Usage:\n\n".$app->commands->extract_usage."\nCommands:\n\n");
    $app->secrets([$cfg->{GENERAL}{secret}]);
    $app->sessions->cookie_name('rtfb');


    my $r = $app->routes->under( sub {
        my $c = shift;

        $c->app->rtInit();
        return 1;
    });

    $app->hook(around_dispatch => sub {
        my ($next, $c) = @_;
        eval {
            $next->()
        };
        if ($@){
            if (ref $@ eq 'ARRAY') {
                $c->render(json=>{
                    error=> {
                        msg => $@->[0],
                        $@->[1] ? (fieldId => $@->[1]) : ()
                    }
                });
                if ($@->[0] =~ /<pre>/){
                    $app->log->error($@->[0]);
                }
            }
            else {
                $c->render(json=>{
                    error=> {
                        msg => "<pre>$@</pre>",
                    }
                });
                $app->log->error($@);
            }
        }
    });

    my $md5;
    $r->get('/REST/apidoc' => 'apidoc');

    # # with default secret:
    # # https://feedback.switchplus.ch/21/cea91424e32b0878ad72d3c2fcda9128/partiallyHappy

    $app->SUPER::startup();
}



1;

=head1 COPYRIGHT

Copyright (c) 2018 by OETIKER+PARTNER AG. All rights reserved.

=head1 AUTHOR

S<Fritz Zaucker E<lt>fritz.zaucker@oetiker.chE<gt>>

=cut

__DATA__

@@ setup.sql

-- 1 up

CREATE TABLE ord (
    ord_id    INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    ord_product TEXT NOT NULL,
    ord_count TEXT NOT NULL,
    ord_first_name TEXT NOT NULL,
    ord_last_name TEXT NOT NULL,
    ord_street TEXT NOT NULL,
    ord_zip TEXT NOT NULL,
    ord_country TEXT NOT NULL,
    ord_company TEXT,
    ord_town TEXT NOT NULL,
    ord_email TEXT NOT NULL,
    ord_delivery TEXT NOT NULL,
    ord_timestamp DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ord_amount DECIMAL(10,2) NOT NULL,
    ord_orgs TEXT NOT NULL,
    ord_meta TEXT NOT NULL,
    ord_seller TEXT NOT NULL
);

-- 1 down

DROP TABLE ord;
