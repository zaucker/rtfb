use lib qw(); # PERL5LIB
use FindBin;use lib "$FindBin::RealBin/../lib";use lib "$FindBin::RealBin/../thirdparty/lib/perl5"; # LIBDIR

use File::Find;
use Test::NoTabs;

sub wanted { /\.js|\.po$/ && notabs_ok($_, "No tabs in $File::Find::name") }

all_perl_files_ok( qw(bin t xt lib) );


find(
    \&wanted,
    'frontend/source/class/req',
    'frontend/source/translation',
);

done_testing;
