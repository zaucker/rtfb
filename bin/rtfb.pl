#!/usr/bin/env perl

BEGIN {
#   die "ERROR: Must define env variable RTHOME" unless $ENV{RTHOME};
    $ENV{RTHOME} //= '/opt/rt442';
}

use lib qw(); # PERL5LIB
use FindBin;use lib "$FindBin::RealBin/../lib";use lib "$FindBin::RealBin/../thirdparty/lib/perl5"; # LIBDIR
use Mojo::Base -base;

# having a non-C locale for number will wreck all sorts of havoc
# when things get converted to string and back
use POSIX qw(locale_h);
setlocale(LC_NUMERIC, "C");use strict;
use Mojolicious::Commands;
use lib "$ENV{RTHOME}/lib";
use lib "$ENV{RTHOME}/lib/perl5";
use lib "$ENV{RTHOME}/local/lib";

Mojolicious::Commands->start_app('RtFb');

__END__
