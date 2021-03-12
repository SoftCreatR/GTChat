###################################################################
#  GTChat GTChat 0.95 Alpha Build 20040120 core file              #
#  Copyright 2001-2006 by Wladimir Palant (http://www.gtchat.de)  #
#  Copyright 2006 by Sascha Heldt (https://www.gt-chat.de)        #
###################################################################

package GT_Chat::ModifyRoom;
use strict;

bless({
	action_handlers => {
		'modifyroom' => \&modify_handler,
		'deleteroom' => \&delete_handler,
	},
});

sub modify_handler
{
	my($self,$main) = @_;

	$main->{template_vars}{backaddr} = 'javascript:history.back()';

	my $modify = $main->{input}{modify};
	delete $main->{input}{modify};

	my $room = $main->loadRoom($main->{input}{name});
	my $oldowner;
	if ($modify)
	{
		$main->fatal_error('unknownroom',{roomname => $main->{input}{name}}) unless defined($room);

		$oldowner = $main->loadUser($room->{owner}) if (exists($room->{owner}) && $room->{owner} ne "");
		$main->fatal_error('roomlist_nopermission') if ((!$oldowner || $oldowner->{name} ne $main->{current_user}{name}) && (!$main->hasPermission('rooms_modify') || ($oldowner && $main->{current_user}{tempgroup}<=$oldowner->{group})));
	}
	else
	{
		$main->fatal_error('nopermission') unless $main->hasPermission('rooms_create');
		$main->fatal_error('noroomnamegiven') unless $main->{input}{name} =~ /\S/;
		$main->fatal_error('roomnameexists',{name => $main->{input}{name}}) if $room;
		$room = {};
	}

	my $oldroom;
	if ($modify)
	{
		$oldroom = {};
		foreach (keys %$room)
		{
			$oldroom->{$_} = $room->{$_};
		}
	}

	foreach (keys %{$main->{input}})
	{
		$room->{$_} = $main->{input}{$_};
	}

	$room->{name}=$oldroom->{name} if $modify;
	if ($main->hasPermission('rooms_changeowner'))
	{
		if (exists($room->{owner}) && $room->{owner} ne "")
		{
			my $candidates = $main->getPossibleUsernames($room->{owner});
			$main->fatal_error('unknownowner',{nick => $room->{owner}}) if $#$candidates < 0;
			$main->fatal_error('ambiguousowner') if $#$candidates > 1;
			$room->{owner}=$candidates->[0];
		}
	}
	else
	{
		$room->{owner} = $modify ? $oldroom->{owner} : $main->{current_user}{name};
	}

	if ($main->lowercase($room->{name}) eq $main->lowercase($main->{settings}{default}{room}))
	{
		$room->{closed} = 0;
		$room->{permanent} = 1;
	}
	else
	{
		$room->{closed} = $modify ? $oldroom->{closed} : 1 unless $main->hasPermission('rooms_createpublic');
		$room->{closed} = $modify ? $oldroom->{closed} : 0 unless $main->hasPermission('rooms_createprivate');
		$room->{permanent} = $modify ? $oldroom->{permanent} : 0 unless $main->hasPermission('rooms_createpermanent');
	}

	$main->invokeModulesList($main->{settings}{custom_room_checker},'checkRoom',$room,$oldroom);

	if ($modify)
	{
		$main->saveRoom($room);
	}
	else
	{
		$main->addRoom($room);
	}

	my %changed = ();
	if ($oldroom)
	{
		foreach (@{$main->getRoomFieldsList})
		{
			$changed{"rooms.$_"}=1 if ($oldroom->{$_} ne $room->{$_});
		}
	}
	else
	{
		$changed{'rooms.created'}=1;
	}

	my @toDo = ();

	if (keys %changed > 0)
	{
		push @toDo,[undef,undef,$main->toOutputString(
			{
				template => 'changed',
				name => $main->{current_user}{name},
				room => $room->{name},
				oldroom => $oldroom->{name},
				'*' => [keys %changed],
			}
		)];
	}

	if (!$room->{permanent} && $main->{current_user}{room} ne $room->{name_lc})
	{
		my $oldroom = $main->{current_user}{room};
		$main->{current_user}{room} = $room->{name_lc};

		$main->saveOnlineInfo($main->{current_user});

		push @toDo,[undef,$oldroom,$main->toOutputString({template => 'room_leaved',
						name => $main->{current_user}{name},
						nick => $main->{current_user}{nick},
						fromroom => $oldroom,
						toroom => $room->{name_lc},
					})],
				   [undef,$room->{name_lc},$main->toOutputString({template => 'room_entered',
						name => $main->{current_user}{name},
						nick => $main->{current_user}{nick},
						fromroom => $oldroom,
						toroom => $room->{name_lc},
					})],
					[$main->{current_user}{name},undef,$main->toOutputString({template => 'room_greeting',
						name => $main->{current_user}{name},
						nick => $main->{current_user}{nick},
						fromroom => $oldroom,
						toroom => $room->{name_lc},
					})],
					[undef,undef,$main->toOutputString({template => 'changed',
										   name => $main->{current_user}{name},
										   room => $main->{current_user}{room},
										   oldroom => $oldroom,
										   '*' => ['room'],
										  })
				   ];

		my $old = $main->loadRoom($oldroom);
		$main->removeRoom($oldroom) if ($old && !$old->{permanent} && !grep {$main->translateOnlineString($_)->{room} eq $oldroom} @{$main->getOnlineUsers()});
	}

	$main->sendOutputStrings(@toDo) if $#toDo>=0;

	$main->printTemplate('roomlist');
}

sub delete_handler
{
	my($self,$main) = @_;

	$main->{template_vars}{backaddr} = 'javascript:history.back()';

	my $room = $main->loadRoom($main->{input}{name});
	$main->fatal_error('unknownroom',{roomname => $main->{input}{name}}) unless defined($room);
	$main->fatal_error('deleteroom_default') if $main->lowercase($main->{settings}{default}{room}) eq $room->{name_lc};

	my $oldowner = $main->loadUser($room->{owner}) if (exists($room->{owner}) && $room->{owner} ne "");
	$main->fatal_error('roomlist_nopermission') if ((!$oldowner || $oldowner->{name} ne $main->{current_user}{name}) && (!$main->hasPermission('rooms_modify') || ($oldowner && $main->{current_user}{tempgroup}<=$oldowner->{group})));

	my @toDo = ();
	my $users = $main->getOnlineUsers();
	foreach (@$users)
	{
		my $user = $main->translateOnlineString($_);
		if ($user->{room} eq $room->{name_lc})
		{
			$user->{room} = $main->lowercase($main->{settings}{default}{room});
			$main->saveOnlineInfo($user);
			push @toDo,[undef,$user->{room},$main->toOutputString({template => 'room_entered',
						name => $user->{name},
						nick => $user->{nick},
						fromroom => $room->{name_lc},
						toroom => $user->{room},
					})],
					[$user->{name},undef,$main->toOutputString({template => 'room_greeting',
						name => $user->{name},
						nick => $user->{nick},
						fromroom => $room->{name_lc},
						toroom => $user->{room},
					})],
					[undef,undef,$main->toOutputString({template => 'changed',
										   name => $user->{name},
										   room => $user->{room},
										   oldroom => $room->{name_lc},
										   '*' => ['room'],
										  })
				   ];
		}
	}

	$main->removeRoom($room->{name});

	$main->sendOutputStrings(@toDo,[undef,undef,$main->toOutputString(
		{
			template => 'changed',
			name => $main->{current_user}{name},
			room => $room->{name},
			oldroom => $room->{name},
			'*' => ['rooms.deleted'],
		}
	)]);

	$main->printTemplate('roomlist');
}
