###################################################################
#  GTChat 0.95 Alpha Plugin                                       #
#  Written for release 20021225                                   #
#  Author: Wladimir Palant                                        #
#                                                                 #
#  This plugin provides the chat commands /quit, /room, /color,   #
#  /nick and /alive. The last onle is sent automatically  by      #
#  JavaScript to show that the user is still there.               #
###################################################################

package GTChat::Plugins::MiscCommands::095_02;
use strict;

return bless({
	command_handlers => {
		'quit' => \&quit_handler,
		'alive' => \&alive_handler,
		'room' => \&room_handler,
		'color' => \&color_handler,
		'nick' => \&nick_handler,
	},
});

sub quit_handler
{
	my($self,$main,$command,$text) = @_;

	$main->kickUser($main->{current_user});
	return undef;
}

sub alive_handler
{
	my($self,$main,$command,$text) = @_;
	
	if ($main->{current_user}{pull})
	{
		return undef;
	}
	else
	{
		return [$main->createOutput({template => 'alive'})->restrictToCurrentUser];
	}
}

sub room_handler
{
	my($self,$main,$command,$text) = @_;

	my $roomname = (split(/\s+/,$text))[0];
	if ($roomname eq '')
	{
		return [$main->createInfoOutput('room',{roomname => $main->{current_user}{room}})];
	}
	
	my $room = $main->loadRoom($roomname);
	if (!defined($room) || !$main->isRoomPermitted($room))
	{
		return [$main->createErrorOutput('unknownroom',{roomname => $roomname})];
	}

	if ($room->{name_lc} ne $main->{current_user}{room})
	{
		my $oldroom = $main->{current_user}{room};
		$main->{current_user}{room} = $room->{name_lc};

		my $output1 = $main->createOutput(
					{
						template => 'room_leaved',
						name => $main->{current_user}{name},
						nick => $main->{current_user}{nick},
						fromroom => $oldroom,
						toroom => $main->{current_user}{room},
					});
		$output1->restrictToRoom($oldroom);

		my $output2 = $main->createOutput(
					{
						template => 'room_entered',
						name => $main->{current_user}{name},
						nick => $main->{current_user}{nick},
						fromroom => $oldroom,
						toroom => $main->{current_user}{room},
					});
		$output2->restrictToRoom($main->{current_user}{room});
		
		my $output3 = $main->createOutput(
					{
						template => 'room_greeting',
						name => $main->{current_user}{name},
						nick => $main->{current_user}{nick},
						fromroom => $oldroom,
						toroom => $main->{current_user}{room},
					});
		$output3->restrictToUser($main->{current_user}{name});
		$output3->setChangedAttributes('room');
		
		return [$output1, $output2, $output3];
	}

	return undef;
}

sub color_handler
{
	my($self,$main,$command,$text) = @_;

	my $color = (split(/\s+/,$text))[0];
	if ($color eq '')
	{
		return [$main->createInfoOutput('currentcolor!',{color => "<font color=\"$main->{current_user}{color}\">$main->{current_user}{color}</font>"})];
	}
	
	if (my $newcolor = $main->toColor($color))
	{
		my %olduser=map {$_ => $main->{current_user}{$_}} keys %{$main->{current_user}};

		$main->{current_user}{color} = $newcolor;
		
		$main->invokeModulesList($main->{settings}{custom_profile_checker},'checkProfile',$main->{current_user},\%olduser);
		
		$main->saveUser($main->{current_user});

		my $output = $main->createOutput(
					{
						template => 'color_changed',
						color => $newcolor,
					});
		$output->restrictToCurrentUser->setChangedAttributes('color');
		return [$output];
	}
	else
	{
		return [$main->createErrorOutput('unknowncolor',{color => $color})];
	}
}

sub nick_handler
{
	my($self,$main,$command,$text) = @_;

	my $nick = (split(/\s+/,$text))[0];
	
	return [$main->createInfoOutput('nickname',{nick => $main->{current_user}{nick}})] if ($nick eq '');

	return [$main->createErrorOutput('samenickname')] if ($nick eq $main->{current_user}{nick});

	my $tmpname = $main->getUsername($nick);
	return [$main->createErrorOutput('nicknameexists',{nick => $nick})] if (defined($tmpname) && $tmpname ne $main->{current_user}{name});

	my %olduser=map {$_ => $main->{current_user}{$_}} keys %{$main->{current_user}};

	$main->{current_user}{nick} = $nick;
	
	$main->invokeModulesList($main->{settings}{custom_profile_checker},'checkProfile',$main->{current_user},\%olduser);

	$main->saveUser($main->{current_user},$olduser{nick});
	
	my $output = $main->createOutput(
				{
					template => 'nick_changed',
					name => $main->{current_user}{name},
					nick => $main->{current_user}{nick},
					oldnick => $olduser{nick},
				});
	$output->restrictToCurrentRoom;
	
	return [$output->setChangedAttributes('nick')];
}
