###################################################################
#  GTChat 0.95 Alpha Plugin                                       #
#  Written for release 20020911                                   #
#  Author: Wladimir Palant                                        #
#                                                                 #
#       !!! This plugin will be replaced by a better one !!!      #
#                                                                 #
#  This plugin provides a simple functionality for blocking       #
#  IP addresses and domains. The list of blocked addresses is     #
#  taken from Variables/banlist.txt.                              #
###################################################################

package GTChat::Plugins::BanList::095_01;
use strict;

return bless({});

sub checkLogin
{
	my($self,$main,$user,$room) = @_;

	$main->fatal_error('usernamebanned') if ($user->{group} < -1);

	$main->open(local *FILE,$main->translateName('vardir::banlist.txt'));

	my @banned = <FILE>;

	close(FILE);

	foreach my $entry (@banned)
	{
		$entry =~ s/[\n\r]//g;
		my($domain,$ip,$forwardedfor,$time,$comment) = split(/\|/,$entry);
		if ($domain ne "" || $ip ne "" || $forwardedfor ne "")
		{
			if (($domain eq "" || $user->{host} =~ /\Q$domain\E$/) &&
				($ip eq "" || $user->{ip} =~ /^\Q$ip\E/) &&
				($forwardedfor eq "" || $user->{forwardedfor} =~ /\Q$forwardedfor\E/))
			{
				$main->fatal_error('ipbanned');
			}
		}
	}
}
