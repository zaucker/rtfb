#!/usr/bin/env perl

use strict;
use warnings;
use v5.10;

use FindBin;
use lib $FindBin::Bin.'/../thirdparty/lib/perl5';
use lib $FindBin::Bin.'/../lib';

use lib qw(); # PERL5LIB
use FindBin;use lib "$FindBin::RealBin/../lib";use lib "$FindBin::RealBin/../thirdparty/lib/perl5"; # LIBDIR

use Test::NoTabs;

all_perl_files_ok( qw(bin t xt lib) );
