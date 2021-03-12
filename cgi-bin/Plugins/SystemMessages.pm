###################################################################
#  GT-Chat 0.96 Alpha Plugin                                       #
#  Written for release whatever                                   #
#  Author: Wladimir Palant                                        #
#                                                                 #
#  This plugin crosschecks the integrity of the users and rooms   #
#  databases and generates the necessary messages on changes.     #
###################################################################

package GT_Chat::Plugins::SystemMessages::096_01;
use strict;

return bless({});

sub afterOnlineSave
{
	my ($self,$main,$user,$olduser) = @_;

	my @toDo = ();

	if (defined($olduser))
	{
		if ($user->{nick} ne $olduser->{nick})
		{
			push @toDo, $main->createOutput(
				{
					template => 'nick_changed',
					name => $user->{name},
					nick => $user->{nick},
					oldnick => $olduser->{nick},
				})->restrictToRoom($user->{room});
		}
	
		my $awaychanged = 0;
		if ($user->{away} ne $olduser->{away})
		{
			if ($user->{away})
			{
				if ($user->{away} eq '1')
				{
					my $output = $main->createInfoOutput('awayon',{nick => $user->{nick}});
					push @toDo, $output->restrictToUser()->restrictToRoom($user->{room});
				}
				else
				{
					my $output = $main->createInfoOutput('awayon_reason!',{nick => $user->{nick}, reason => $user->{away}});
					push @toDo, $output->restrictToUser()->restrictToRoom($user->{room});
				}

				$awaychanged = 1 unless $olduser->{away};
			}
			elsif ($olduser->{away})
			{
				my $output = $main->createInfoOutput('awayoff',{nick => $user->{nick}});
				push @toDo, $output->restrictToUser()->restrictToRoom($user->{room});
				$awaychanged = 1;
			}
		}

		if ($user->{room} ne $olduser->{room})
		{
			push @toDo, $main->createOutput(
				{
					template => 'room_changed',
					name => $user->{name},
					nick => $user->{nick},
					fromroom => $olduser->{room},
					toroom => $user->{room},
				});

			my $room = $main->loadRoom($olduser->{room});
			if (!$room->{permanent})
			{
				my $users = $main->getOnlineUsers(1);
				my $found = 0;
				foreach my $user (@$users)
				{
					if ($user->{room} eq $olduser->{room})
					{
						$found = 1;
						last;
					}
				}
				$main->removeRoom($olduser->{room}) unless $found;
			}
		}
		elsif ($user->{nick} ne $olduser->{nick} || $user->{tempgroup} ne $olduser->{tempgroup} || $awaychanged)
		{
			push @toDo, $main->createOutput(
				{
					template => 'changed',
					userlist => 1,
					menu => ($user->{tempgroup} ne $olduser->{tempgroup}),
				})->restrictToRoom($user->{room});
		}
	}
	else
	{
		push @toDo, $main->createOutput(
			{
				template => 'entered',
				name => $user->{name},
				nick => $user->{nick},
				room => $user->{room},
			});
	}

	$main->sendOutputStrings(@toDo) if $#toDo >= 0;
}

sub afterOnlineDelete
{
	my ($self,$main,$user,$reason) = @_;

	my $room = $main->loadRoom($user->{room});
	if (!$room->{permanent})
	{
		my $users = $main->getOnlineUsers(1);
		my $found = 0;
		foreach my $user2 (@$users)
		{
			if ($user->{room} eq $user2->{room})
			{
				$found = 1;
				last;
			}
		}
		$main->removeRoom($user->{room}) unless $found;
	}

	$main->sendOutputStrings($main->createOutput(
		{
			template => 'leaved',
			name => $user->{name},
			nick => $user->{nick},
			room => $user->{room},
			logoutmsg => (!$reason || !$reason->{nologoutmsg}),
		}));
}

sub afterUserSave
{
	my ($self,$main,$user,$olduser) = @_;

	my @toDo = ();
	if (defined($olduser) && $main->isOnline($user->{name}))
	{
		my $output = $main->createOutput(
			{
				template => 'changed',
				user => 1,
				style => ($user->{style} ne $olduser->{style}),
			});
		push @toDo, $output->restrictToUser($user->{name});

		if ($user->{color} ne $olduser->{color})
		{
			my $output = $main->createOutput(
						{
							template => 'color_changed',
							color => $user->{color},
						});
			push @toDo, $output->restrictToUser($user->{name});
		}
		
		if ($user->{nosmileys} ne $olduser->{nosmileys})
		{
			push @toDo, $main->createInfoOutput('smileyssuccessful_' . ($user->{nosmileys} ? 'off' : 'on'));
		}

		if ($user->{show_time} ne $olduser->{show_time})
		{
			push @toDo, $main->createInfoOutput('timesuccessful_' . ($user->{show_time} ? 'on' : 'off'));
		}
	}

	$main->sendOutputStrings(@toDo) if $#toDo >= 0;
}

sub afterUserDelete
{
	my ($self,$main,$user) = @_;

	if ($main->isOnline($user->{name}))
	{
		$main->loadOnlineInfo($user->{name},$user);
		$main->kickUser($user,{error_name => 'error_deleted'});
	}
}

sub afterRoomSave
{
	my ($self,$main,$room,$oldroom) = @_;

	if (defined($oldroom))
	{
		if ($room->{owner} ne $oldroom->{owner} || $room->{vips} ne $oldroom->{vips})
		{
			my $output = $main->createOutput(
				{
					template => 'changed',
					userlist => 1,
				});
			$main->sendOutputStrings($output->restrictToRoom($room->{name_lc}));
		}
	}
	else        # new room created
	{
		my $output = $main->createOutput(
			{
				template => 'changed',
				roomlist => 1,
			});
		$main->sendOutputStrings($output);
	}
}

sub beforeRoomDelete
{
	my ($self,$main,$room) = @_;

	my $users = $main->getOnlineUsers();
	foreach my $user (@$users)
	{
		if ($user->{room} eq $room->{name_lc})
		{
			$user->{room} = $main->lowercase($main->{settings}{default}{room});
			$main->saveOnlineInfo($user);
		}
	}
}

sub afterRoomDelete
{
	my ($self,$main,$room) = @_;

	my $output = $main->createOutput(
		{
			template => 'changed',
			roomlist => 1,
		});
	$main->sendOutputStrings($output);
}
