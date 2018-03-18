package RtFb::Feedback;

use Mojo::Base 'Mojolicious::Controller';
#use Mojo::SQLite;
#use Mojo::JSON qw(encode_json);
#use Encode qw/encode decode/;
use Mojo::Util qw/md5_sum/;
use Mojo::Exception;

=head1 NAME

RtFb::Feedback - Controller Class

=head1 SYNOPSIS

 $c->checkForm($data)

=cut


has log => sub {
    shift->app->log;
};

has data => sub {
    shift->req->json;
};

has cfg => sub {
    shift->app->config->cfgHash;
};

sub store {
    my $c = shift;
    my $id = shift;
    my $meta = shift;
    my $cfg = $c->cfg;
    $c->stash('d',$c->data);
    $c->stash('login',$c->session('login'));
}

1;

=head1 COPYRIGHT

Copyright (c) 2018 by OETIKER+PARTNER AG. All rights reserved.

=head1 AUTHOR

S<Fritz Zaucker E<lt>fritz.zaucker@oetiker.chE<gt>>

=cut
