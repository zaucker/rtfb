package RtFb::Controller::Feedback;

=head1 NAME

RtFb::Controller::Feedback - Feedback service

=head1 SYNOPSIS

=cut

use Mojo::Base 'Mojolicious::Controller';
use Mojo::Util qw(dumper);

sub getForm {
    my $c = shift;
    $c->openapi->valid_input or return;

    my $ticketId = $c->param('ticket');
    my $feedback = $c->param('feedback');
    my $md5      = $c->param('md5');
    my $check    = $c->app->md5Hash($ticketId);
    $c->app->log->debug("getForm(): ticketId=$ticketId, md5=$md5, fd=$feedback");

    if ($md5 eq $check) {
        my $ticket = RT::Ticket->new(RT->SystemUser);
        $ticket->Load($ticketId);
        my $subject = $ticket->Subject;
        
        my $comment = $ticket->CustomFieldValues('Feedback Kommentar')->Next;
        $comment = $comment->Content if defined $comment;
        my $userLang = $c->_getUserLang($ticket);
        $c->stash('ticketId'     => $ticketId);
        $c->stash('subject'      => $subject);
        $c->stash('comment'      => ($comment // ''));
        $c->stash('feedback'     => $feedback);
        $c->stash('lang'         => $userLang);
        $c->stash('md5'          => $md5);
        $c->stash('feedbackUrl'  => $c->app->feedbackUrl);
        $c->stash('templateText' => $c->app->feedbackForm);
        $c->render('feedback');
    }
    else {
        $c->app->log->debug("ticketId=$ticketId, md5=$md5, check=$check, secret=" . $c->app->md5secret);
        $c->render(text => '<h1>Unauthorized</h1>', status => 403);
    }
}

sub save {
    my $c = shift;
    $c->openapi->valid_input or return;

    my $feedback = $c->param('feedback');
    my $comment  = $c->param('comment');
    my $secret   = $c->param('secret');
    my $ticketId = $c->param('ticketId');
    my $check    = "xyz" . $c->app->md5Hash($ticketId);
    my $authorized = $check eq $secret;

    if ($authorized) {
        my $ticket = RT::Ticket->new(RT->SystemUser);
        $ticket->Load($ticketId);
        my $subject = $ticket->Subject;

        my ($ret, $msg);
        # set CFs on original ticket
        ($ret, $msg) = $ticket->AddCustomFieldValue(Field => 'Feedback', Value => $feedback);
        $c->app->log->error("Set feedback($ticketId)=$msg") unless $ret;
        ($ret, $msg) = $ticket->AddCustomFieldValue(Field => 'Feedback Kommentar', Value => $comment);
        $c->app->log->error("Set feedback($ticketId)=$msg") unless $ret;

        # create feedback ticket and set CFs
        my $feedbackTicket = RT::Ticket->new(RT->SystemUser);
        ($ret, $msg) = $feedbackTicket->Create(
            Queue => "Feedback",
            Subject => "Feedback for ticket $ticketId",
            Status  => "Resolved",
            Parents => $ticketId,
        );
        $c->app->log->error("ret(feedbackTicket->Create)=$msg") unless $ret;
        ($ret, $msg) = $feedbackTicket->AddCustomFieldValue(Field => 'Feedback', Value => $feedback);
        $c->app->log->error("Set feedback($ticketId)=$msg") unless $ret;
        ($ret, $msg) = $feedbackTicket->AddCustomFieldValue(Field => 'Feedback Kommentar', Value => $comment);
        $c->app->log->error("Set feedbackComment($ticketId)=$msg") unless $ret;

        my $userLang = $c->_getUserLang($ticket);
        $c->stash('ticketId'     => $ticketId);
        $c->stash('subject'      => $subject);
        $c->stash('templateText' => $c->app->responseText);
        $c->stash('lang'         => $userLang);
        $c->render('response');
    }
    else {
        $c->app->log->debug("ticketId=$ticketId, check=$check, secret=$secret");
        $c->render(text => '<h1>Unauthorized</h1>', status => 403);
    }
}


sub _getUserLang {
    my $c          = shift;
    my $ticket     = shift;

    my $langHeader = $c->req->headers->accept_language;
    
    my @acceptedLanguages = split(',', $langHeader);
    my @languages;
    my $requestor = $ticket->Requestors->UserMembersObj->First;
    my $userLang;
    $userLang = $requestor->Lang if $requestor;
    push @languages, $userLang if $userLang;
    my %lhash;
    for my $l (@acceptedLanguages) {
        $l =~ s/;q=.*//;
        $l =~ s/-.*//;
        next unless $l;
        push @languages, $l unless $lhash{$l};
        $lhash{$l} = 1;
    }
    for my $lang (@languages) {
        my ($l, $s) = split('-', lc($lang));
        next unless $l eq 'en' or $l eq 'de' or $l eq 'fr' or $l eq 'it';
        $userLang = $l;
        last;
    }
    $userLang //= 'de';
    return $userLang;
}


1;

=head1 COPYRIGHT

Copyright (c) 2018 by OETIKER+PARTNER AG. All rights reserved.

=head1 AUTHOR

S<Fritz Zaucker E<lt>fritz.zaucker@oetiker.chE<gt>>

=cut

