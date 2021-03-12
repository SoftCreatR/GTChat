###################################################################
#  GT-Chat 0.96 Alpha Plugin                                       #
#  Written for release whatever                                   #
#  Author: Wladimir Palant                                        #
#                                                                 #
#  This plugin provides the chat commands /ignore and /unignore   #
###################################################################

package GT_Chat::Plugins::Ignoring::096_01;
use strict;

return bless({
	command_handlers => {
		'ignore' => \&ignore_handler,
		'unignore' => \&unignore_handler,
	},
});

sub ignore_handler
{
	my($self,$main,$command,$text) = @_;

	$text =~ s/^\s+|\s+$//g;
	my @users = split(/\s+/,$text);
	if ($#users < 0)
	{
		if (defined($main->{current_user}{ignored}))
		{
			foreach (split(/\s/,$main->{current_user}{ignored}))
			{
				my $user = $main->loadUser($_);
				push @users, $user->{nick} if $user;
			}
		}

		if ($#users < 0)
		{
			return $main->createInfoOutput('ignore_none');
		}
		else
		{
			return $main->createInfoOutput('ignore',{list => join(', ',@users)});
		}
	}
	
	my @toDo = ();

	my @ignored = defined($main->{current_user}{ignored}) ? split(/\s/,$main->{current_user}{ignored}) : ();
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
			foreach my $username (@ignored)
			{
				if ($username eq $candidates->[0])
				{
					$found = 1;
					last;
				}
			}

			if ($found)
			{
				push @toDo,$main->createErrorOutput('alreadyignored',{nick => $candidates->[1]});
			}
			elsif ($candidates->[0] eq $main->{current_user}{name})
			{
				push @toDo,$main->createErrorOutput('ignoreoneself');
			}
			else
			{
				push @ignored,$candidates->[0];
				$main->{current_user}{ignored} = join(' ',@ignored);

				my $output = $main->createInfoOutput('ignoresuccess',{nick => $candidates->[1]});
				push @toDo,$output;
				
				$output = $main->createInfoOutput('ignored',{nick => $main->{current_user}{nick}});
				push @toDo,$output->restrictToUser($candidates->[0]);
			}
		}
	}
	
	return \@toDo;
}

sub unignore_handler
{
	my($self,$main,$command,$text) = @_;

	$text =~ s/^\s+|\s+$//g;
	my @users = split(/\s+/,$text);

	return $main->createErrorOutput('unignore_namenotgiven') if ($#users < 0);

	my @toDo = ();
	my @ignored = defined($main->{current_user}{ignored}) ? split(/\s/,$main->{current_user}{ignored}) : ();
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
			for (my $i=0;$i<=$#ignored;$i++)
			{
				if ($ignored[$i] eq $candidates->[0])
				{
					splice(@ignored,$i,1);
					$found = 1;
					last;
				}
			}

			if (!$found)
			{
				push @toDo,$main->createErrorOutput('notignored',{nick => $candidates->[1]});
			}
			else
			{
				$main->{current_user}{ignored} = join(' ',@ignored);

				my $output = $main->createInfoOutput('unignoresuccess',{nick => $candidates->[1]});
				push @toDo,$output;
				
				$output = $main->createInfoOutput('unignored',{nick => $main->{current_user}{nick}});
				push @toDo,$output->restrictToUser($candidates->[0]);
			}
		}
	}
	
	return \@toDo;
}
