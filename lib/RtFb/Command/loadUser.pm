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
use RT::User;

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

    my $valid = 0;
    my $lines = 0;
    my $lang = 0;
    my $failed = 0;
    my $unknownUsers = 0;
    my $user = RT::User->new(RT->SystemUser);
    while (<$fh>) {
        $lines++;
        next if /^\?\?\?/;
        chomp;
        my ($custId, $language, $eMail) = split ';', lc($_);
        next unless $eMail and $language;
        $valid++;

        my ($ret, $msg) = $user->LoadByEmail($eMail);
        if ($ret) { # user found
            my $userLang = $user->Lang if $ret;
            if (not $userLang or $language ne $userLang) { # set language
                my ($ret, $msg) = $user->SetLang($language);
                if ($ret) {
                    $lang++;
#                    say "Language set for $custId: $language";
                }
                else {
                    say STDERR "Failed to set lang=$language on email=$eMail: $msg";
                    $failed++;
                }
            }
        }
        else {
            say STDERR "User not found: $eMail: $msg";
            $unknownUsers++;
        }
        print '.' unless $lines and $lines % 10;
        print " $lines\n" unless $lines and $lines % 500;
    }
    say "\nRead $lines lines ($valid valid), $unknownUsers unknown users, $lang languages set, $failed failed.";
    close $fh;
}

1;

=head1 COPYRIGHT

Copyright (c) 2018 by OETIKER+PARTNER AG. All rights reserved.

=head1 AUTHOR

S<Fritz Zaucker E<lt>fritz.zaucker@oetiker.chE<gt>>

=cut
