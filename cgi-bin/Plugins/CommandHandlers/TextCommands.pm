###################################################################
#  GT-Chat 0.96 Alpha Plugin                                       #
#  Written for release whatever                                   #
#  Author: Wladimir Palant                                        #
#                                                                 #
#  This plugin provides the chat commands /me, /broadcast, /img,  #
#  /away and the default command (plain text).                    #
###################################################################

package GT_Chat::Plugins::TextCommands::096_01;
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

sub text_handler
{
	my($self,$main,$command,$text) = @_;
	
	my @ret=();

	$main->{current_user}{away} = "" if $main->{current_user}{away};

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

	$main->{current_user}{away} = ($text eq '' ? '1' : $main->toHTML($text));

	return \@ret;
}

sub custom_handler
{
	my($self,$main,$command,$text) = @_;
	
	my @ret=();

	$main->{current_user}{away} = '' if $main->{current_user}{away};

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
