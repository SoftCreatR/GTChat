###################################################################
#  GTChat 0.95 Alpha Plugin                                       #
#  Written for release 20021225                                   #
#  Author: Wladimir Palant                                        #
#                                                                 #
#  This plugin provides the auxiliary moderation commands         #
###################################################################

package GTChat::Plugins::ModerationCommands::095_01;
use strict;

return bless({
	command_handlers => {
		'addvip' => \&addvip_handler,
		'removevip' => \&removevip_handler,
		'enablemoderation' => \&enable_handler,
		'disablemoderation' => \&enable_handler,
	},
});

sub addvip_handler
{
	my($self,$main,$command,$text) = @_;

	my $room = $main->loadRoom($main->{current_user}{room});

	return [$main->createErrorOutput('vip_nonmoderatedroom')] unless $room->{moderated};
	return [$main->createErrorOutput('command_nopermission')] unless $room->{owner} eq $main->{current_user}{name} || $main->hasPermission('rooms_moderate');

	$text =~ s/^\s+|\s+$//g;
	my @users = split(/\s+/,$text);
	if ($#users < 0)
	{
		foreach (split(/\s/,$room->{vips}))
		{
			my $user = $main->loadUser($_);
			push @users, $user->{nick} if $user;
		}

		if ($#users < 0)
		{
			return [$main->createInfoOutput('vip_none')];
		}
		else
		{
			return [$main->createInfoOutput('vip',{list => join(', ',@users)})];
		}
	}
	
	my @toDo = ();
	my @vips = split(/\s/,$room->{vips});
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
			foreach my $username (@vips)
			{
				if ($username eq $candidates->[0])
				{
					$found = 1;
					last;
				}
			}

			if ($found)
			{
				push @toDo,$main->createErrorOutput('alreadyvip',{nick => $candidates->[1]});
			}
			else
			{
				$changed = 1;
				push @vips,$candidates->[0];
				$room->{vips} = join(' ',@vips);

				push @toDo,$main->createInfoOutput('addvipsuccess',{nick => $candidates->[1]});
				
				my $output = $main->createInfoOutput('vipadded',{nick => $main->{current_user}{nick}, roomname => $room->{name}});
				push @toDo,$output->restrictToUser($candidates->[0]);
			}
		}
	}
	
	if (changed)
	{
		$main->saveRoom($room);

		my $output = $main->createOutput(
			{
				template => 'changed',
				name => $main->{current_user}{name},
				room => $room->{name_lc},
				oldroom => $room->{name_lc},
				'*' => ['rooms.vips'],
			});
		push @toDo,$output;
	}

	return \@toDo;
}

sub removevip_handler
{
	my($self,$main,$command,$text) = @_;

	my $room = $main->loadRoom($main->{current_user}{room});

	return [$main->createErrorOutput('vip_nonmoderatedroom')] unless $room->{moderated};
	return [$main->createErrorOutput('command_nopermission')] unless $room->{owner} eq $main->{current_user}{name} || $main->hasPermission('rooms_moderate');

	$text =~ s/^\s+|\s+$//g;
	my @users = split(/\s+/,$text);

	return [$main->createErrorOutput('removevip_namenotgiven')] if ($#users < 0);
	
	my @toDo = ();
	my @vips = split(/\s/,$room->{vips});
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
			for (my $i=0;$i<=$#vips;$i++)
			{
				if ($vips[$i] eq $candidates->[0])
				{
					splice(@vips,$i,1);
					$found = 1;
					last;
				}
			}

			if (!$found)
			{
				push @toDo,$main->createErrorOutput('notvip',{nick => $candidates->[1]});
			}
			else
			{
				$changed = 1;
				$room->{vips} = join(' ',@vips);

				push @toDo,$main->createInfoOutput('removevipsuccess',{nick => $candidates->[1]});
				
				my $output = $main->createInfoOutput('vipremoved',{nick => $main->{current_user}{nick}, roomname => $room->{name}});
				push @toDo,$output->restrictToUser($candidates->[0]);
			}
		}
	}
	
	if ($changed)
	{
		$main->saveRoom($room);

		my $output = $main->createOutput(
				{
					template => 'changed',
					name => $main->{current_user}{name},
					room => $room->{name_lc},
					oldroom => $room->{name_lc},
					'*' => ['rooms.vips'],
				});
		push @toDo,$output;
	}

	return \@toDo;
}

sub enable_handler
{
	my($self,$main,$command,$text) = @_;

	my $output1 = $main->createOutput(
			{
				template => 'moderation_disable',
				disable => ($command eq 'enablemoderation' ? 0 : 1),
			});
	$output1->restrictToCurrentUser();
	my $output2 = $main->createInfoOutput("$command\_success");

	return [$output1, $output2];
}
