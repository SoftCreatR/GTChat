###################################################################
#  GTChat 0.95 Alpha Plugin                                       #
#  Written for release 20021225                                   #
#  Author: Wladimir Palant                                        #
#                                                                 #
#  This plugin writes a messages log to Variables/messages.log    #
#  and creates backup copies for it. The hash log_messages in     #
#  Settings.dat determines, which messages have to be logged.     #
###################################################################

package GTChat::Plugins::MessagesLog::095_02;
use strict;

return bless({});

sub logOutputStrings
{
	my($self,$main,$commands) = @_;

	my @commands = grep {$main->{settings}{log_messages}{(split(/\|/,$_->[2]))[0]}} @$commands;
	return if $#commands<0;

	$main->open(local *LOG, '>>'.$main->translateName('vardir::messages.log'));
	foreach (@commands)
	{
		my $user = defined($_->[0])?$_->[0]:'';
		my $room = defined($_->[1])?$_->[1]:'';
		print LOG "$main->{runtime}{now}|$user|$room|$_->[2]\n";
	}

	if ($main->{settings}{max_messageslog_size}>0 && $main->{settings}{messageslog_backups_count}>0 && tell(LOG)>$main->{settings}{max_messageslog_size})
	{               # rotate log now
		unlink($main->translateName("vardir::messages.$main->{settings}{messageslog_backups_count}.log"));
		for (my $i=$main->{settings}{messageslog_backups_count}-1;$i>=0;$i--)
		{
			my $j=$i+1;
			rename($main->translateName("vardir::messages.$i.log"),$main->translateName("vardir::messages.$j.log"));
		}
		$main->close(*LOG);
		rename($main->translateName("vardir::messages.log"),$main->translateName("vardir::messages.1.log"));
	}
	else
	{
		$main->close(*LOG);
	}
}
