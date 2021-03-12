###################################################################
#  GTChat 0.95 Alpha Plugin                                       #
#  Written for release 20021101                                   #
#  Author: Wladimir Palant                                        #
#                                                                 #
#  This plugin provides the chat commands /kick, /gag and /push   #
###################################################################

package GTChat::Plugins::AdminCommands::095_01;
use strict;

return bless({
	command_handlers => {
		'kick' => \&kick_handler,
		'gag' => \&gag_handler,
		'ungag' => \&gag_handler,
		'push' => \&push_handler,
	},
});

sub kick_handler
{
	my($self,$main,$command,$text) = @_;

	my ($nick) = split(/\s+/,$text);
	
	return [$main->createErrorOutput('kick_namenotgiven')] unless defined($nick);
	
	my $candidates = $main->getPossibleOnlineUsers($nick);
	
	return [$main->createErrorOutput('notonline',{nick => $nick})] if ($#$candidates < 0);
	return [$main->createErrorOutput('ambiguousname',{nick => $nick})] if ($#$candidates > 0);

	my $user = $candidates->[0];

	return [$main->createErrorOutput('kick_nopermission',{nick => $user->{nick}})] if ($main->{current_user}{tempgroup} <= $user->{tempgroup});
	return [$main->createErrorOutput('kick_admin',{nick => $user->{nick}})] if ($user->{tempgroup} > 0);

	$main->kickUser($user,{error_name => 'error_kicked',nologoutmsg => 1});

	my $info = $main->createInfoOutput('kicked',
					{
						admin => $main->{current_user}{nick},
						nick => $user->{nick},
					});
	$info->restrictToRoom($user->{room});
	
	return [$info];
}

sub gag_handler
{
	my($self,$main,$command,$text) = @_;

	my ($nick,$time) = split(/\s+/,$text);
	
	return [$main->createErrorOutput($command.'_namenotgiven')] unless defined($nick);
	
	my $candidates = $main->getPossibleOnlineUsers($nick);
	
	return [$main->createErrorOutput('notonline',{nick => $nick})] if ($#$candidates < 0);
	return [$main->createErrorOutput('ambiguousname',{nick => $nick})] if ($#$candidates > 0);

	my $user = $candidates->[0];

	return [$main->createErrorOutput($command.'_nopermission',{nick => $user->{nick}})] if ($main->{current_user}{tempgroup} <= $user->{tempgroup});
	return [$main->createErrorOutput($command.'_admin',{nick => $user->{nick}})] if ($user->{tempgroup} > 0);

	$time = 5 if $time<=0 || $time>1440;
	$time = int($time);
	
	my $info;

	$main->loadUser($user->{name},$user);
	if ($command eq 'gag')
	{
		$user->{gagtime} = $main->{runtime}{now}+$time*60;
		$info = $main->createInfoOutput('gagged',
					{
						admin => $main->{current_user}{nick},
						nick => $user->{nick},
						minutes => $time,
					});
	}
	else
	{
		return [$main->createErrorOutput('notgagged',{nick => $user->{nick}})] unless exists($user->{gagtime}) && $user->{gagtime}>$main->{runtime}{now};
		delete $user->{gagtime};
		$info = $main->createInfoOutput('ungagged',
					{
						admin => $main->{current_user}{nick},
						nick => $user->{nick},
					});
	}
	
	$main->saveUser($user);

	$info->restrictToRoom($user->{room});
	
	return [$info];
}

sub push_handler
{
	my($self,$main,$command,$text) = @_;

	my ($nick,$roomname) = split(/\s+/,$text);
	
	return [$main->createErrorOutput('push_namenotgiven')] unless defined($nick);
	
	my $candidates = $main->getPossibleOnlineUsers($nick);
	
	return [$main->createErrorOutput('notonline',{nick => $nick})] if ($#$candidates < 0);
	return [$main->createErrorOutput('ambiguousname',{nick => $nick})] if ($#$candidates > 0);

	my $user = $candidates->[0];

	return [$main->createErrorOutput('push_nopermission',{nick => $user->{nick}})] if ($main->{current_user}{tempgroup} <= $user->{tempgroup});
	return [$main->createErrorOutput('push_admin',{nick => $user->{nick}})] if ($user->{tempgroup} > 0);

	$roomname = $main->{settings}{default}{room} unless defined($roomname);

	my $room = $main->loadRoom($roomname);
	return [$main->createErrorOutput('unknownroom',{roomname => $roomname})] unless defined($room);
	return [$main->createErrorOutput('push_alreadythere')] if $room->{name_lc} eq $user->{room};
	
	my $oldroom = $user->{room};
	$user->{room} = $room->{name_lc};
	$main->saveOnlineInfo($user);

	my $info1 = $main->createInfoOutput('pushed',
					{
						admin => $main->{current_user}{nick},
						nick => $user->{nick},
						roomname => $room->{name},
					});

	$info1->restrictToUser() if ($main->{current_user}{room} eq $room->{name_lc});
	$info1->restrictToRoom($oldroom);
	
	my $info2 = $main->createInfoOutput('pushed',
					{
						admin => $main->{current_user}{nick},
						nick => $user->{nick},
						roomname => $room->{name},
					});
	$info2->restrictToUser();
	$info2->restrictToRoom($room->{name_lc});

	my $changed = $main->createOutput(
					{
						template => 'changed',
						name => $user->{name},
						room => $user->{room},
						oldroom => $oldroom,
						'*' => ['room'],
					});
					
	return [$info1,$info2,$changed];
}
