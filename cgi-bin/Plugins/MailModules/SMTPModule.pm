###################################################################
#  GTChat 0.95 Alpha Plugin                                       #
#  Written for release 20021120                                   #
#  Author: Wladimir Palant                                        #
#                                                                 #
#  This is a mailing module, that uses the STMP protocol to       #
#  connect to a mail server.                                      #
###################################################################

package GTChat::Plugins::SMTPModule::095_02;
use strict;
use Socket;

return bless({});

sub sendMail
{
	my($main,$to,$subject,$body) = @_;
	
	$to = join(', ', map {"<$_>"} split(/,/,$to));

	my $proto = getprotobyname('tcp') || 6;
	my $port = getservbyname('smtp', 'tcp') || 25;
	
	my $server_addr = inet_aton($main->{settings}{smtp_server});
	$main->fatal_error('smtp_couldnotfind') if (!defined($server_addr));
	
	socket(local *MAIL, AF_INET, SOCK_STREAM, $proto) || $main->fatal_error('smtp_couldnotsend');
	connect(MAIL, sockaddr_in($port, $server_addr))  || $main->fatal_error('smtp_couldnotsend');

	select(MAIL);
	$| = 1;
	select(STDOUT);

	check_answer($main,*MAIL);

	print MAIL "HELO localhost\r\n";
	check_answer($main,*MAIL);

	print MAIL "MAIL FROM: <$main->{settings}{webmaster_email}>\r\n";
	check_answer($main,*MAIL);

	foreach (split(/, /, $to))
	{
		print MAIL "RCPT TO: $_\r\n";
		check_answer($main,*MAIL);
	}

	print MAIL "DATA\r\n";
	check_answer($main,*MAIL);

	my $charset = $main->{current_language}{charset};
	$charset=(defined($charset) ? "; charset=$charset" : "");

	my $mail = <<"EOT";
To: $to
From: $main->{settings}{webmaster_email}
Subject: $subject
Content-Type: text/plain$charset

$body
.
EOT
	$mail =~ s/\r?\n/\r\n/g;

	print MAIL $mail;
	check_answer($main,*MAIL);

	print MAIL "QUIT\r\n";
	check_answer($main,*MAIL);
	
	close MAIL;
}

sub check_answer
{
	my ($main,$handle) = @_;
	
	$_ = <$handle>;
	if (/^[45]/) {
		close(MAIL);
		$main->fatal_error('smtp_couldnotsend');
	}
}
