### Adapt and add to $RTHOME/etc/RT_SiteConfig.pm

Set($RtFb_FeedbackSecret, 'dsf78osdf');
#Set($RtFb_FeedbackURL,    'https://localhost:8520');
Set($RtFb_FeedbackURL,    'https://rt-test.switchplus.ch:8520');
Set($RtFb_FeedbackMail,   'support@oetiker.ch');
Set($RtFb_FeedbackPhone,  '062 775 9907');
Set($RtFb_MailIntro,      {
        de => 'Mail intro text (de)',
        en => 'Mail intro text (en)',
    }
);

Set($RtFb_MailFooter, {
  de => 'Mail footer (de)',
  en => 'Mail footer (en)',
}
);

Set($RtFb_FeedbackForm, {
     ticket => {
         de => 'Ticket',
         en => 'Ticket',
     },
     question => {
         de => q{Waren Sie zufrieden mit der Beantwortung Ihrer Anfrage?},
         en => q{Where you satisfied with the answer to your request?},
     },
     selection => [
         {
             text => {
                 de => 'Zufrieden',
                 en => 'Satisfied'
             },
             value => 'happy',
         },
         {
             text => {
                 de => 'Bedingt zufrieden',
                 en => 'Partially satisfied'
             },
             value => 'partiallyHappy',
         },
         {
             text => {
                 de => 'Teilweise unzufrieden',
                 en => 'Partially unsatisfied'
             },
             value => 'partiallyUnhappy',
         },
         {
             text => {
                 de => 'Unzufrieden',
                 en => 'Unhappy',
             },
             value => 'unhappy',
         },
     ],
     details => {
         de => 'Weitere Rückmeldungen (optional)',
         en => 'Further feedback (optionally)'
     },
     submit => {
         de => 'Abschicken',
         en => 'Submit',
     },
     mail => {
        en => 'Mail',
        de => 'Mail',
        fr => 'Mail',
        it => 'Mail',
     },
     phone => {
         en => 'Phone',
         de => 'Tel',
         fr => 'Tel',
         it => 'Tel',
     },     
    }
);

Set($RtFb_FeedbackResponse, {
     ticket => {
         de => 'Ticket',
         en => 'Ticket',
     },
     response => {
         de => q{Danke für Ihre Rückmeldung.},
         en => q{Thank you for your feedback.},
     },
#     submit => {
#         de => 'Abschicken',
#         en => 'Submit',
#     },
    }
);
