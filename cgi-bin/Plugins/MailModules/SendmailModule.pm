###################################################################
#  GTChat 0.95 Alpha Plugin                                       #
#  Written for release 20021120                                   #
#  Author: Wladimir Palant                                        #
#                                                                 #
#  This is a mailing module, that uses the sendmail program.      #
###################################################################

package GTChat::Plugins::SendmailModule::095_02;
use strict;

return bless({});

sub sendMail
{
	my($main,$to,$subject,$body) = @_;
	
	$to = join(', ', map {"<$_>"} split(/,/,$to));

	my $charset = $main->{current_language}{charset};
	$charset=(defined($charset) ? "; charset=$charset" : "");
	
	open(local *MAIL, "|$main->{settings}{mailprog} -t") || $main->fatal_error('mailprogramerror');
	print MAIL <<"EOT";
To: $to
From: $main->{settings}{webmaster_email}
Subject: $subject
Content-Type: text/plain$charset

$body
EOT
	close(MAIL);
}
