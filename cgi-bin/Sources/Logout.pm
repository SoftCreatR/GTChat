###################################################################
#  GTChat GTChat 0.96 Alpha Build 20060923 core file              #
#  Copyright 2001-2006 by Wladimir Palant (http://www.gtchat.de)  #
#  Copyright 2006 by Sascha Heldt (https://www.softcreatr.de)     #
###################################################################

package GT_Chat::Logout;
use strict;

bless({});

sub logout
{
	my($self,$main) = @_;

	my $reason="";
	if ($main->open(local *FILE,$main->translateName('onlinedir::logout.reasons')))
	{
		while (<FILE>)
		{
			s/[\n\r]//g;

			my @parts = split(/\|/);
			if (shift(@parts) == $main->{runtime}{id})
			{
				my $time = shift(@parts);
				my %params = @parts;
				$reason = $main->getMessage($params{error_name},\%params);
				last;
			}
		}
		$main->close(*FILE);
	}

	$main->setCookie("cookieid=; expires=Mon, 31-Jan-3000 12:00:00 GMT;");
	$main->{runtime}{completeurl} .= ";id=";
	$main->{template_vars}{logout_reason}=$reason;

	$main->printTemplate('logout');
}
