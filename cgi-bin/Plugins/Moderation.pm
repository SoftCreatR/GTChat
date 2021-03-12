###################################################################
#  GT-Chat 0.96 Alpha Plugin                                       #
#  Written for release whatever                                   #
#  Author: Wladimir Palant                                        #
#                                                                 #
#  This plugin provides the moderation functions.                 #
###################################################################

package GT_Chat::Plugins::Moderation::096_01;
use strict;

srand;

return bless({
	command_handlers => {
		'moderated_text' => \&text_handler,
	},
});

sub beforeSend
{
	my($self,$main,$commands) = @_;
	
	return if $main->hasPermission('rooms_moderate');
	
	my $rnd = rand;
	my %rooms=();
	for (my $i=$#$commands;$i>=0;$i--)
	{
		my ($toUser,$toRoom,$command)=@{$commands->[$i]};
		my $room;
		my $error;

		if (defined($toRoom) && $toRoom ne '')
		{
			$rooms{$toRoom} = $main->loadRoom($toRoom) unless $rooms{$toRoom};
			$room = $rooms{$toRoom};
			$error = 'moderated_nopermission';
		}
		elsif (defined($toUser) && $toUser ne '' && defined($main->{current_user}{name}) && $toUser ne $main->{current_user}{name})
		{
			my $user = $main->loadOnlineInfo($toUser);
			if ($user)
			{
				$rooms{$user->{room}} = $main->loadRoom($user->{room}) unless $rooms{$user->{room}};
				$room = $rooms{$user->{room}};
				$error = 'moderated_msg_nopermission';
			}
		}

		if ($room && $room->{moderated} && $main->{current_user}{name} ne $room->{owner})
		{
			my $message = (split(/\|/,$command))[0];
			
			if (!$main->{settings}{moderation_ignore_messages}{$message} && !grep {$_ eq $main->{current_user}{name}} split(/\s/,$room->{vips}))
			{
				if ($message eq 'text')
				{
					$commands->[$i][2] =~ s/^text/moderated_text|$main->{runtime}{now}-$rnd-$i/;
					splice(@$commands,$i,0,$main->createInfoOutput('moderated'));
				}
				elsif ($main->{settings}{moderation_error_messages}{$message})
				{
					$commands->[$i] = $main->createErrorOutput($error);
				}
				else
				{
					splice(@$commands,$i,1);
				}
			}
		}
	}
}

sub text_handler
{
	my($self,$main,$command,$text) = @_;
	
	$main->fatal_error('command_nopermission') unless $main->hasPermission('rooms_moderate') || $main->loadRoom($main->{current_user}{room})->{owner} eq $main->{current_user}{name};

	my $ret = [];

	my ($old_name, $old_nick, $old_color) = ($main->{current_user}{name}, $main->{current_user}{nick}, $main->{current_user}{color});
	$text =~ s/^(\S+) (\S+) (\S+) (\S+) //;

	# Call the normal text command handlers with faked user parameters
	(my $id, $main->{current_user}{name}, $main->{current_user}{nick}, $main->{current_user}{color}) = ($1,$2,$3,$4);
	eval
	{
		my $modulename = $main->{settings}{custom_command_handlers}{''};
		my $module = $main->{modules}{$modulename};
		$ret = $module->{command_handlers}{''}->($module,$main,'',$text);
		push @$ret, $main->createOutput(
				{
					template => 'moderated_sent',
					id => $id,
				});
	};
	my $error = $@;
	
	($main->{current_user}{name}, $main->{current_user}{nick}, $main->{current_user}{color}) = ($old_name, $old_nick, $old_color);
	die $error if $error;
	
	return $ret;
}
