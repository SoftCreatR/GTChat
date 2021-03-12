###################################################################
#  GT-Chat 0.96 Alpha Plugin                                       #
#  Written for release whatever                                   #
#  Author: Wladimir Palant                                        #
#                                                                 #
#  This plugin provides the chat commands /quit, /room, /color,   #
#  /nick, /refresh and /alive. The last one is sent automatically #
#  by the JavaScript code in order to show that the user is still #
#  there.                                                         #
###################################################################

package GT_Chat::Plugins::MiscCommands::096_01;
use strict;

return bless({
	command_handlers => {
		'quit' => \&quit_handler,
		'alive' => \&alive_handler,
		'room' => \&room_handler,
		'color' => \&color_handler,
		'nick' => \&nick_handler,
		'refresh' => \&refresh_handler,
		'smileys' => \&smileys_handler,
		'time' => \&time_handler,
		'menuminimized' => \&minimize_handler,
		'roomsminimized' => \&minimize_handler,
		'usersminimized' => \&minimize_handler,
	},
});

sub quit_handler
{
	my($self,$main,$command,$text) = @_;

	$main->kickUser($main->{current_user});
	return;
}

sub alive_handler
{
	my($self,$main,$command,$text) = @_;
	
	if ($main->{current_user}{pull})
	{
		return;
	}
	else
	{
		return $main->createOutput({template => 'alive'})->restrictToCurrentUser;
	}
}

sub room_handler
{
	my($self,$main,$command,$text) = @_;

	my $roomname = (split(/\s+/,$text))[0];
	if ($roomname eq '')
	{
		return $main->createInfoOutput('room',{roomname => $main->{current_user}{room}});
	}
	
	my $room = $main->loadRoom($roomname);
	if (!defined($room) && $main->hasPermission('rooms_create'))
	{
		$main->saveRoom({
			name => $roomname,
			owner => $main->{current_user}{name},
			closed => !$main->hasPermission('rooms_createpublic'),
			permanent => 0,
		});
		$room = $main->loadRoom($roomname);
	}

	if (!defined($room) || !$main->isRoomPermitted($room))
	{
		return $main->createErrorOutput('unknownroom',{roomname => $roomname});
	}

	$main->{current_user}{room} = $room->{name_lc};

	return;
}

sub color_handler
{
	my($self,$main,$command,$text) = @_;

	my $color = (split(/\s+/,$text))[0];
	if ($color eq '')
	{
		return $main->createInfoOutput('currentcolor!',{color => "<font color=\"$main->{current_user}{color}\">$main->{current_user}{color}</font>"});
	}
	
	if (my $newcolor = $main->toColor($color))
	{
		$main->{current_user}{color} = $newcolor;

		$main->saveUser($main->{current_user});

		return;
	}
	else
	{
		return $main->createErrorOutput('unknowncolor',{color => $color});
	}
}

sub nick_handler
{
	my($self,$main,$command,$text) = @_;

	my $nick = (split(/\s+/,$text))[0];
	
	return $main->createInfoOutput('nickname',{nick => $main->{current_user}{nick}}) if ($nick eq '');
	return $main->createErrorOutput('samenickname') if ($nick eq $main->{current_user}{nick});

	my $oldnick = $main->{current_user}{nick};
	$main->{current_user}{nick} = $nick;

	eval
	{
		$main->saveUser($main->{current_user});
	};
	if ($@)     # if saving not permitted
	{
		$main->{current_user}{nick} = $oldnick;
		die $@;
	}

	return;
}

sub refresh_handler
{
	my($self,$main,$command,$text) = @_;

	my $output = $main->createOutput(
			{
				template => 'changed',
				user => 1,
				style => 1,
				online => 1,
				room => 1,
				roomlist => 1,
				userlist => 1,
				menu => 1,
			});
	return $output->restrictToCurrentUser();
}

sub smileys_handler
{
	my($self,$main,$command,$text) = @_;

	$text =~ s/^\s+//;
	$text =~ s/\s.*//;
	$text = lc($text);
	if ($text eq 'on' || $text eq 'yes')
	{
		if ($main->{current_user}{nosmileys})
		{
			$main->{current_user}{nosmileys} = 0;
			$main->saveUser($main->{current_user});
		}
	}
	elsif ($text eq 'off' || $text eq 'no')
	{
		if (!$main->{current_user}{nosmileys})
		{
			$main->{current_user}{nosmileys} = 1;
			$main->saveUser($main->{current_user});
		}
	}
	else
	{
		return $main->createInfoOutput('smileys' . ($main->{current_user}{nosmileys} ? 'off' : 'on'));
	}

	return;
}

sub time_handler
{
	my($self,$main,$command,$text) = @_;

	$text =~ s/^\s+//;
	$text =~ s/\s.*//;
	$text = lc($text);
	if ($text eq 'on' || $text eq 'yes')
	{
		if (!$main->{current_user}{show_time})
		{
			$main->{current_user}{show_time} = 1;
			$main->saveUser($main->{current_user});
		}
	}
	elsif ($text eq 'off' || $text eq 'no')
	{
		if ($main->{current_user}{show_time})
		{
			$main->{current_user}{show_time} = 0;
			$main->saveUser($main->{current_user});
		}
	}
	else
	{
		return $main->createInfoOutput('time' . ($main->{current_user}{show_time} ? 'on' : 'off'));
	}

	return;
}

sub minimize_handler
{
	my($self,$main,$command,$text) = @_;

	my $field = $command;
	$field =~ s/minimized$//i;
	$field = 'minimize'.$field;

	my $value = $text ? '1' : '0';

	if ($main->{current_user}{$field} != $value)
	{
		$main->{current_user}{$field} = $value;
		$main->saveUser($main->{current_user});
	}

	return;
}
