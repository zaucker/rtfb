package RtFb::Command::loadUser;

=head1 NAME

RtFb::Command::loadUser - command for loading user info into RT

=head1 SYNOPSIS

 rtfb.pl run loadUser filename

=head1 DESCRIPTION

Read CSV file and set user data (language only at the moment)

=cut

use Mojo::Base 'Mojolicious::Command';
use RT -init;

has description => 'Load user language from CSV file';
has usage       => << "USAGE";
Usage: $0 loadUser filename
USAGE

sub run {
    my ($self, @argv) = @_;

    die "ERROR: Missing filename.\n"          . $self->usage unless scalar @argv;
    die "ERROR: Wrong number of arguments.\n" . $self->usage if scalar(@argv) != 1;

    my $filename = $argv[0];

    open(my $fh, '<', $filename) or 
        die "Couldn't open $filename: $!";

    my $n = 0;
    my $lang = 0;
    my $failed = 0;
    my $user = RT::User->new(RT->SystemUser);
    while (<$fh>) {
        chomp;
        next if /^\?\?\?/;
        my ($custId, $eMail, $lang) = split ';', lc($_);
        next unless $eMail and $lang;

        my ($ret, $msg) = $user->LoadByEmail($eMail);
        if ($ret and $lang ne $user->Lang) { # user found
            my ($ret, $msg) = $user->SetLang($lang);
            if ($ret) {
                $lang++;
                say "Language set for $custId: $lang";
            }
            else {
                say STDERR "Failed to set lang=$lang on email=$eMail: $msg";
                $failed++;
            }
        }
        print '.' unless $n%1000;
        $n++;
    }
    say "\nRead valid $n lines, $lang languages set, $failed failed.";
    close $fh;
}

1;

=head1 COPYRIGHT

Copyright (c) 2018 by OETIKER+PARTNER AG. All rights reserved.

=head1 AUTHOR

S<Fritz Zaucker E<lt>fritz.zaucker@oetiker.chE<gt>>

=cut
