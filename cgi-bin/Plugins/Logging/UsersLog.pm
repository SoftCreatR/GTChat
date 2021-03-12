###################################################################
#  GTChat 0.95 Alpha Plugin                                       #
#  Written for release 20021101                                   #
#  Author: Wladimir Palant                                        #
#                                                                 #
#  This plugin saves account creation and removement events to    #
#  the file Variables/users.log and creates backup copies of it.  #
###################################################################

package GTChat::Plugins::UsersLog::095_01;
use strict;

return bless({});

sub addToLog
{
	my ($main,$action,$user) = @_;
	
	my $current = ($main->{current_user} ? "|$main->{current_user}{name}|$main->{current_user}{nick}" : "");
	
	$main->open(local *LOG, '>>'.$main->translateName('vardir::users.log'));
	print LOG "$main->{runtime}{now}|$action|$user->{name}|$user->{nick}|$user->{group}|$user->{ip}|$user->{forwardedfor}|$user->{host}|$user->{browser}$current\n";
	
	if ($main->{settings}{max_userslog_size}>0 && $main->{settings}{userslog_backups_count}>0 && tell(LOG)>$main->{settings}{max_userslog_size})
	{               # rotate log now
		unlink($main->translateName("vardir::users.$main->{settings}{userslog_backups_count}.log"));
		for (my $i=$main->{settings}{userslog_backups_count}-1;$i>=0;$i--)
		{
			my $j=$i+1;
			rename($main->translateName("vardir::users.$i.log"),$main->translateName("vardir::users.$j.log"));
		}
		$main->close(*LOG);
		rename($main->translateName("vardir::users.log"),$main->translateName("vardir::users.1.log"));
	}
	else
	{
		$main->close(*LOG);
	}
}

sub userRegistered
{
	my($self,$main,$user) = @_;

	addToLog($main,'registered',$user);
}

sub userDeleted
{
	my($self,$main,$user) = @_;

	addToLog($main,'deleted',$user);
}
