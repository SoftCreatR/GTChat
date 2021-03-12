###################################################################
#  GTChat 0.95 Alpha Plugin                                       #
#  Written for release 20021225                                   #
#  Author: Wladimir Palant                                        #
#                                                                 #
#  This plugin provides the chat commands /invite and /uninvite   #
###################################################################

package GTChat::Plugins::Invitations::095_02;
use strict;

return bless({
	command_handlers => {
		'invite' => \&invite_handler,
		'uninvite' => \&uninvite_handler,
	},
});

sub invite_handler
{
	my($self,$main,$command,$text) = @_;

	my $room = $main->loadRoom($main->{current_user}{room});

	return [$main->createErrorOutput('invite_publicroom')] unless $room->{closed};
	return [$main->createErrorOutput('invite_nopermission')] unless ($main->hasPermission('invite') || $room->{owner} eq $main->{current_user}{name});
	
	$text =~ s/^\s+|\s+$//g;
	my @users = split(/\s+/,$text);
	if ($#users < 0)
	{
		foreach (split(/\s/,$room->{invited}))
		{
			my $user = $main->loadUser($_);
			push @users, $user->{nick} if $user;
		}

		if ($#users < 0)
		{
			return [$main->createInfoOutput('invite_none')];
		}
		else
		{
			return [$main->createInfoOutput('invite',{list => join(', ',@users)})];
		}
	}
	
	my @toDo = ();
	my @invited = split(/\s/,$room->{invited});
	my $changed = 0;
	foreach (@users)
	{
		my $candidates = $main->getPossibleUsernames($_);
		if ($#$candidates < 0)
		{
			push @toDo,$main->createErrorOutput('unknownname',{nick => $_});
		}
		elsif ($#$candidates > 1)
		{
			push @toDo,$main->createErrorOutput('ambiguousname',{nick => $_});
		}
		else
		{
			my $found = 0;
			foreach my $username (@invited)
			{
				if ($username eq $candidates->[0])
				{
					$found = 1;
					last;
				}
			}

			if ($found)
			{
				push @toDo,$main->createErrorOutput('alreadyinvited',{nick => $candidates->[1]});
			}
			else
			{
				$changed = 1;
				push @invited,$candidates->[0];
				$room->{invited} = join(' ',@invited);

				push @toDo,$main->createInfoOutput('invitesuccess',{nick => $candidates->[1]});
				
				my $output = $main->createInfoOutput('invited',{nick => $main->{current_user}{nick}, roomname => $room->{name}});
				push @toDo,$output->restrictToUser($candidates->[0]);
				
				$output = $main->createOutput(
						{
							template => 'changed',
							name => $main->{current_user}{name},
							room => $room->{name_lc},
							oldroom => $room->{name_lc},
							'*' => ['rooms.invited'],
						});
				push @toDo,$output->restrictToUser($candidates->[0]);
			}
		}
	}
	
	$main->saveRoom($room) if ($changed);

	return \@toDo;
}

sub uninvite_handler
{
	my($self,$main,$command,$text) = @_;

	my $room = $main->loadRoom($main->{current_user}{room});

	return [$main->createErrorOutput('invite_publicroom')] unless $room->{closed};
	return [$main->createErrorOutput('invite_nopermission')] unless ($main->hasPermission('invite') || $room->{owner} eq $main->{current_user}{name});

	$text =~ s/^\s+|\s+$//g;
	my @users = split(/\s+/,$text);

	return [$main->createErrorOutput('uninvite_namenotgiven')] if ($#users < 0);
	
	my @toDo = ();
	my @invited = split(/\s/,$room->{invited});
	my $changed = 0;
	foreach (@users)
	{
		my $candidates = $main->getPossibleUsernames($_);
		if ($#$candidates < 0)
		{
			push @toDo,$main->createErrorOutput('unknownname',{nick => $_});
		}
		elsif ($#$candidates > 1)
		{
			push @toDo,$main->createErrorOutput('ambiguousname',{nick => $_});
		}
		else
		{
			my $found = 0;
			for (my $i=0;$i<=$#invited;$i++)
			{
				if ($invited[$i] eq $candidates->[0])
				{
					splice(@invited,$i,1);
					$found = 1;
					last;
				}
			}

			if (!$found)
			{
				push @toDo,$main->createErrorOutput('notinvited',{nick => $candidates->[1]});
			}
			else
			{
				$changed = 1;
				$room->{invited} = join(' ',@invited);

				push @toDo,$main->createInfoOutput('uninvitesuccess',{nick => $candidates->[1]});
				
				my $output = $main->createInfoOutput('uninvited',{nick => $main->{current_user}{nick}, roomname => $room->{name}});
				push @toDo,$output->restrictToUser($candidates->[0]);
				
				$output = $main->createOutput(
						{
							template => 'changed',
							name => $main->{current_user}{name},
							room => $room->{name_lc},
							oldroom => $room->{name_lc},
							'*' => ['rooms.invited'],
						});
				push @toDo,$output->restrictToUser($candidates->[0]);
					
				my $user = $main->loadOnlineInfo($candidates->[0]);
				if ($user && $user->{room} eq $room->{name_lc} && !$main->isRoomPermitted($room,$user))
				{
					$user->{room} = $main->lowercase($main->{settings}{default}{room});
					$main->saveOnlineInfo($user) if ($user->{name} ne $main->{current_user}{name});

					my $output1 = $main->createOutput(
							{
								template => 'room_leaved',
								name => $user->{name},
								nick => $user->{nick},
								fromroom => $room->{name_lc},
								toroom => $user->{room},
							});
					$output1->restrictToRoom($room->{name_lc});
					$output1->setChangedAttributes('room');
					my $output2 = $main->createOutput(
							{
								template => 'room_entered',
								name => $user->{name},
								nick => $user->{nick},
								fromroom => $room->{name_lc},
								toroom => $user->{room},
							});
					$output2->restrictToRoom($user->{room});
					my $output3 = $main->createOutput(
							{
								template => 'room_greeting',
								name => $user->{name},
								nick => $user->{nick},
								fromroom => $room->{name_lc},
								toroom => $user->{room},
							});
					$output3->restrictToUser($user->{name});
					push @toDo, $output1, $output2, $output3;
				}
			}
		}
	}
	
	$main->saveRoom($room) if ($changed);

	return \@toDo;
}
