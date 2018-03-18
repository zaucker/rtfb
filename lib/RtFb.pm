package RtFb;

use Mojo::Base 'Mojolicious';
use RtFb::Config;
use Mojo::SQLite;
use Mojo::JSON qw(encode_json);
use RtFb::Feedback;
use Mojo::Util qw(sha1_sum b64_encode md5_sum);
# use RT;

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
        require PicIt::Simple;
        require PicIt::DataModel;
        require RT::PICIT::AppDirect::TicketCreation;
        require RT::PICIT::AppDirect::AssetCustomFieldSnapshot;
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

sub md5Hash {
    my $c        = shift;
    my $ticketId = shift;
    return md5_sum($ticketId . $c->app->config->cfgHash->{GENERAL}{secret});
}

sub startup {
    my $app = shift;
    my $cfg = $app->config->cfgHash;
    $app->commands->message("Usage:\n\n".$app->commands->extract_usage."\nCommands:\n\n");
    $app->secrets([$cfg->{GENERAL}{secret}]);
    $app->sessions->cookie_name('rtfb');
#    $app->plugin(
#        StripePayment => {
#            secret => $cfg->{GENERAL}{stripeSecretKey},
#        }
#    );

    my $r = $app->routes->under( sub {
        my $c = shift;

        my $shopmode = $c->session('shopmode');
        my $login = $c->session('login');
        $c->stash('shopmode' => $shopmode);
        $c->stash('login' => $login);

        return 1 if !$shopmode or $login;

        my ($user,$pass) = split /:/, ($c->req->url->to_abs->userinfo // ''), 2;
        if ($pass and $user and sha1_sum($pass) eq ($cfg->{USERS}{$user} // '')){
            $c->session('login' => $user);
            return 1;
        };
        $c->res->headers->www_authenticate("Basic realm=rtfb");
        $c->res->code(401);
        $c->rendered;
        return undef;
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

    $r->get('/about');
    
#    $r->get('/login' => sub {
#        my $c = shift;
#        $c->session('shopmode' => 1);
#        $c->session('login' => '');
#        $c->redirect_to('.')
#    });

    $r->get('/:ticket/:feedback/:md5' => sub {
                my $c = shift;
                my $ticketId = $c->param('ticket');
                my $feedback = $c->param('feedback');
                my $md5      = $c->param('md5');
                my $check    = $c->app->md5Hash($ticketId);
                
                if ($md5 eq $check) {
                    $c->stash('ticketId' => $ticketId);
                    $c->stash('feedback' => $feedback);
                    $c->render('feedback');
                }
                else {
                    $c->render(text => '<h1>Unauthorized</h1>', status => 403);
                }
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
