package RtFb;

use Mojo::Base 'Mojolicious';
use RtFb::Config;
use Mojo::SQLite;
use Mojo::JSON qw(encode_json);
use RtFb::Feedback;
use Mojo::Util qw(md5_sum dumper);
use RT;
use Digest::MD5 qw(md5_hex);

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

has md5secret => sub {
    RT->Config->Get("RtFb_FeedbackSecret");
};

sub md5Hash {
    my $c        = shift;
    my $ticketId = shift;
    return md5_hex($ticketId . $c->md5secret);
}

sub startup {
    my $app = shift;
    my $cfg = $app->config->cfgHash;
    say "md5(1)=", $app->md5Hash(1);
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

    $r->get('/:ticket/:md5/:feedback' => sub {
                my $c = shift;
                my $ticketId = $c->param('ticket');
                my $feedback = $c->param('feedback');
                my $check    = $c->app->md5Hash($ticketId);
                $md5         = $c->param('md5');

                if ($md5 eq $check) {
                    my $ticket = RT::Ticket->new(RT->SystemUser);
                    $ticket->Load($ticketId);
                    my $subject = $ticket->Subject;

                    my $comment = $ticket->CustomFieldValues('Feedback Kommentar')->Next;
                    $comment = $comment->Content if defined $comment;
#                    warn "comment = ", dumper $comment // 'UNDEFINED';
                    $c->stash('ticketId' => $ticketId);
                    $c->stash('subject'  => $subject);
                    $c->stash('comment'  => ($comment // ''));
                    $c->stash('feedback' => $feedback);
                    $c->render('feedback');
                }
                else {
                    $c->render(text => '<h1>Unauthorized</h1>', status => 403);
                }
    });
    $r->post('/saveFeedback' => sub {
        my $c = shift;

        my $feedback = $c->param('feedback');
        my $comment  = $c->param('comment');
        my $secret   = $c->param('secret');
        my $ticketId = $c->param('ticketId');
        my $check    = "xyz" . $c->app->md5Hash($ticketId);
        my $authorized = $check eq $secret;
        my $response = "feedback=$feedback, comment=$comment, secret=$secret, check=$check, ticketId=$ticketId, authorized=$authorized";

        if ($authorized) {
            my $ticket = RT::Ticket->new(RT->SystemUser);
            $ticket->Load($ticketId);

            my @ret = $ticket->AddCustomFieldValue(Field => 'Feedback Kommentar', Value => $comment);
            warn "ret=", dumper \@ret;
        }
        $c->render(text => $response);
    });

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
