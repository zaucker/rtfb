 # Add status "feedback" for feedback handling; 2018-09-11, fritz.zaucker@oetiker.ch
#
# Christian  Schlatter <christian.schlatter@switchplus.com>
#
# Zur Bewertungsfunktionalität:
# Der zusätzliche Status ist "Bewertung"
# Verhalten von diesem Status ist identisch wie beim Status "Erledigt",
# einfach das bei "Bewertung" das Bewertungsmail versendet wird.
#
# Die Idee ist, dass wenn ein Agent einen Kundenkontakt als abgeschlossen
# ansieht, wählt er den Status "Bewertung".  Wenn sich nun der Kunde
# bedankt, hat der Kunde die Möglichkeit mit dem Status "Erledigt" das
# Ticket zu schliessen, ohne eine erneute Bewertung auszulösen.

Set(%Lifecycles,
    default => {
        initial         => [qw(new)], # loc_qw
        active          => [qw(open stalled)], # loc_qw
        inactive        => [qw(feedback resolved rejected deleted)], # loc_qw

        defaults => {
            on_create => 'new',
            approved  => 'open',
            denied    => 'rejected',
            reminder_on_open     => 'open',
            reminder_on_resolve  => 'resolved',
        },

        transitions => {
            ""       => [qw(new open resolved)],

            # from   => [ to list ],
            new      => [qw(    open stalled feedback resolved rejected deleted)],
            open     => [qw(new      stalled feedback resolved rejected deleted)],
            stalled  => [qw(new open         feedback resolved rejected deleted)],
            feedback => [qw(new open stalled          resolved rejected deleted)],
            resolved => [qw(new open stalled          rejected deleted         )],
            rejected => [qw(new open stalled feedback resolved          deleted)],
            deleted  => [qw(new open stalled feedback resolved rejected        )],
        },
        rights => {
            '* -> deleted'  => 'DeleteTicket',
            '* -> *'        => 'ModifyTicket',
        },
        actions => [
            'new -> open'      => { label  => 'Open It',  update => 'Respond' }, # loc{label}
            'new -> feedback'  => { label  => 'Feedback', update => 'Comment' }, # loc{label}
            'new -> resolved'  => { label  => 'Resolve',  update => 'Comment' }, # loc{label}
            'new -> rejected'  => { label  => 'Reject',   update => 'Respond' }, # loc{label}
            'new -> deleted'   => { label  => 'Delete',                       }, # loc{label}
            'open -> stalled'  => { label  => 'Stall',    update => 'Comment' }, # loc{label}
            'open -> feedback' => { label  => 'Feedback', update => 'Comment' }, # loc{label}
            'open -> resolved' => { label  => 'Resolve',  update => 'Comment' }, # loc{label}
            'open -> rejected' => { label  => 'Reject',   update => 'Respond' }, # loc{label}
            'stalled -> open'  => { label  => 'Open It',                      }, # loc{label}
            'feedback -> open' => { label  => 'Re-open',  update => 'Comment' }, # loc{label}
            'resolved -> open' => { label  => 'Re-open',  update => 'Comment' }, # loc{label}
            'rejected -> open' => { label  => 'Re-open',  update => 'Comment' }, # loc{label}
            'deleted -> open'  => { label  => 'Undelete',                     }, # loc{label}
        ],
    },
    assets => {
        type     => "asset",
        initial  => [ 
            'new' # loc
        ],
        active   => [ 
            'allocated', # loc
            'in-use' # loc
        ],
        inactive => [ 
            'recycled', # loc
            'stolen', # loc
            'deleted' # loc
        ],

        defaults => {
            on_create => 'new',
        },

        transitions => {
            ''        => [qw(new allocated in-use)],
            new       => [qw(allocated in-use stolen deleted)],
            allocated => [qw(in-use recycled stolen deleted)],
            "in-use"  => [qw(allocated recycled stolen deleted)],
            recycled  => [qw(allocated)],
            stolen    => [qw(allocated)],
            deleted   => [qw(allocated)],
        },
        rights => {
            '* -> *'        => 'ModifyAsset',
        },
        actions => {
            '* -> allocated' => { 
                label => "Allocate" # loc
            },
            '* -> in-use'    => { 
                label => "Now in-use" # loc
            },
            '* -> recycled'  => { 
                label => "Recycle" # loc
            },
            '* -> stolen'    => { 
                label => "Report stolen" # loc
            },
        },
    },
# don't change lifecyle of the approvals, they are not capable to deal with
# custom statuses
    approvals => {
        initial         => [ 'new' ],
        active          => [ 'open', 'stalled' ],
        inactive        => [ 'resolved', 'rejected', 'deleted' ],

        defaults => {
            on_create => 'new',
            reminder_on_open     => 'open',
            reminder_on_resolve  => 'resolved',
        },

        transitions => {
            ''       => [qw(new open resolved)],

            # from   => [ to list ],
            new      => [qw(open stalled resolved rejected deleted)],
            open     => [qw(new stalled resolved rejected deleted)],
            stalled  => [qw(new open rejected resolved deleted)],
            resolved => [qw(new open stalled rejected deleted)],
            rejected => [qw(new open stalled resolved deleted)],
            deleted  => [qw(new open stalled rejected resolved)],
        },
        rights => {
            '* -> deleted'  => 'DeleteTicket',
            '* -> rejected' => 'ModifyTicket',
            '* -> *'        => 'ModifyTicket',
        },
        actions => [
            'new -> open'      => { label  => 'Open It', update => 'Respond' }, # loc{label}
            'new -> resolved'  => { label  => 'Resolve', update => 'Comment' }, # loc{label}
            'new -> rejected'  => { label  => 'Reject',  update => 'Respond' }, # loc{label}
            'new -> deleted'   => { label  => 'Delete',                      }, # loc{label}
            'open -> stalled'  => { label  => 'Stall',   update => 'Comment' }, # loc{label}
            'open -> resolved' => { label  => 'Resolve', update => 'Comment' }, # loc{label}
            'open -> rejected' => { label  => 'Reject',  update => 'Respond' }, # loc{label}
            'stalled -> open'  => { label  => 'Open It',                     }, # loc{label}
            'resolved -> open' => { label  => 'Re-open', update => 'Comment' }, # loc{label}
            'rejected -> open' => { label  => 'Re-open', update => 'Comment' }, # loc{label}
            'deleted -> open'  => { label  => 'Undelete',                    }, # loc{label}
        ],
    },
);
