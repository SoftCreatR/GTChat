###################################################################
#  GT-Chat 0.96 Alpha Plugin                                       #
#  Written for release whatever                                   #
#  Author: Wladimir Palant                                        #
#                                                                 #
#  This is a mailing module, that uses the sendmail program.      #
###################################################################

package GT_Chat::Plugins::SendmailModule::096_01;
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
