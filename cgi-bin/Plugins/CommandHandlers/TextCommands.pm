###################################################################
#  GTChat 0.95 Alpha Plugin                                       #
#  Written for release 20021101                                   #
#  Author: Wladimir Palant                                        #
#                                                                 #
#  This plugin provides the chat commands /me, /broadcast, /img,  #
#  /away and the default command (plain text).                    #
###################################################################

package GTChat::Plugins::TextCommands::095_01;
use strict;

return bless({
	command_handlers => {
		'' => \&text_handler,
		'admin' => \&text_handler,
		'me' => \&custom_handler,
		'broadcast' => \&custom_handler,
		'callop' => \&custom_handler,
		'img' => \&custom_handler,
		'away' => \&away_handler,
	},
});

sub check_gagged
{
	my $main = shift;

	if (exists($main->{current_user}{gagtime}) && $main->{runtime}{now} < $main->{current_user}{gagtime})
	{
		return [$main->createErrorOutput('gagged',{seconds => $main->{current_user}{gagtime}-$main->{runtime}{now}})];
	}
	return undef;
}

sub text_handler
{
	my($self,$main,$command,$text) = @_;
	
	my @ret=();

	if (my $error=check_gagged($main))
	{
		return $error;
	}
	
	if ($main->{current_user}{away})
	{
		$main->{current_user}{away} = 0;
		
		my $output = $main->createInfoOutput('awayoff',{nick => $main->{current_user}{nick}});
		push @ret, $output->restrictToUser->restrictToCurrentRoom->setChangedAttributes('away');
	}

	my @to=();

	my @words = split(/\s/,$text);
	my $changed = 0;
	my $i=$#words;
	while ($i>=0 && $words[$i] =~ /^\@[^@]+$/)
	{
		$i--;
	}
	unshift(@words,splice(@words,$i+1));

	while ($words[0] =~ /^[^:]+:$/ || $words[0] =~ /^\@[^@]+$/)
	{
		$words[0] =~ s/\:$//;
		$words[0] =~ s/^\@//;

		my $candidates = $main->getPossibleOnlineUsers($words[0],$main->{current_user}{room});
		if ($#$candidates<0)
		{
			push @ret,$main->createErrorOutput('notinroom',{nick => $words[0]});
		}
		elsif ($#$candidates>0)
		{
			push @ret,$main->createErrorOutput('ambiguousname',{nick => $words[0]});
		}
		else
		{
			push @to, $candidates->[0]{nick};
			$changed = 1;
		}
		shift(@words);
	}
	$text=join(' ',@words) if ($changed);

	if ($text ne "")
	{
		my $output = $main->createOutput(
				{
					template => $command eq ''?'text':'admin',
					name => $main->{current_user}{name},
					nick => $main->{current_user}{nick},
					color => $main->{current_user}{color},
					text => $main->toHTML($text),
					'*' => \@to,
				});
		push @ret,$output->restrictToCurrentRoom;
	}
	
	return \@ret;
}

sub away_handler
{
	my($self,$main,$command,$text) = @_;

	my @ret=();

	if (my $error=check_gagged($main))
	{
		return $error;
	}
	elsif ($text eq "")
	{
		$main->{current_user}{away}=1;
		
		my $output = $main->createInfoOutput('awayon',{nick => $main->{current_user}{nick}});
		push @ret, $output->restrictToUser->restrictToCurrentRoom->setChangedAttributes('away');
	}
	else
	{
		$text = $main->toHTML($text);
		$main->{current_user}{away}=$text;

		my $output = $main->createInfoOutput('awayon_reason!',{nick => $main->{current_user}{nick}, reason => $text});
		push @ret, $output->restrictToUser->restrictToCurrentRoom->setChangedAttributes('away');
	}

	return \@ret;
}

sub custom_handler
{
	my($self,$main,$command,$text) = @_;
	
	my @ret=();

	if (my $error=check_gagged($main))
	{
		return $error;
	}
	
	if ($main->{current_user}{away})
	{
		$main->{current_user}{away} = 0;
		
		my $output = $main->createInfoOutput('awayoff',{nick => $main->{current_user}{nick}});
		push @ret, $output->restrictToUser->restrictToCurrentRoom->setChangedAttributes('away');
	}

	if ($text ne '')
	{
		my $output = $main->createOutput(
				{
					template => $command,
					name => $main->{current_user}{name},
					nick => $main->{current_user}{nick},
					color => $main->{current_user}{color},
					text => $main->toHTML($text),
				});
		$output->restrictToCurrentRoom if $command ne 'broadcast' && $command ne 'callop';
		push @ret,$output;
	}
	
	return \@ret;
}
