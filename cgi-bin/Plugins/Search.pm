###################################################################
#  GTChat 0.95 Alpha Plugin                                       #
#  Written for release 20020911                                   #
#  Author: Wladimir Palant                                        #
#                                                                 #
#  This plugin manages the user search.                           #
###################################################################

package GTChat::Plugins::Search::095_01;
use strict;

@GTChat::Plugins::Search::Results_enum::095_01::ISA = ('GTChat::Enum');

return bless({
	action_handlers => {
		'search' => \&search_handler,
	},
	replace_by => {
		'*' => '.*',
		'?' => '.',
	},
});

sub search_handler
{
	my($self,$main) = @_;
	
	$main->{template_vars}{backaddr} = 'javascript:history.back()';

	my $mask = $main->{input}{mask};
	$mask =~ s/^\s+|\s+$//g;
	$mask =~ tr/ /_/;
	$mask =~ s/[^\w?*]/\\$&/g;
	$mask =~ s/\*+/*/g;

	$main->fatal_error('search_nothingtodo') if $mask eq '' || $mask eq '*' || $mask eq '?*' || $mask eq '*?';

	my $search = "^$mask\$";
	$search =~ s/[?*]/($self->{replace_by}{$&})/g;
	$search =~ s/\)\(//g;
	
	my $replace = "\"<b>$mask</b>\"";
	for (my $i=1;$replace =~ s/[?*]+/<\/b>\$$i<b>/;$i++) {}

	my @found = grep {
		my ($nick,$name) = split(/\|/);
		if ($nick =~ /$search/i)
		{
			my $result=$nick;
			$result =~ s/$search/$replace/giee;
			$_ .= '|'.$result;
			1;
		}
		else
		{
			0;
		}
	} @{$main->getAllUsers};
	
	$mask =~ s/\\(.)/$1/g;
	$main->{template_vars}{search_mask} = $main->toHTML($mask);
	$main->{template_vars}{search_results} = GTChat::Plugins::Search::Results_enum::095_01::new($main,\@found);
	$main->{template_vars}{search_results_count} = $#found+1;

	$main->printTemplate('search_results');
}

package GTChat::Plugins::Search::Results_enum::095_01;

sub new
{
	my ($main,$list) = @_;

	my $enum=$main->{modules}{'sourcedir::Enum.pm'};

	return bless({
		list => $list,
		opened => 0,
		index => -1,
	});
}

sub open
{
	my $self = shift;
	
	$self->close if $self->{opened};

	$self->{index} = -1;
	$self->{opened} = 1;
}

sub hasNext
{
	my $self=shift;
	return ($self->{opened} && $self->{index} < $#{$self->{list}});
}

sub next
{
	my $self=shift;
	
	return undef unless $self->{opened};

	$self->{index}++;

	my %ret;
	($ret{nick},$ret{name},$ret{result}) = split(/\|/,$self->{list}[$self->{index}]);
	return \%ret;
}

sub close
{
	my $self=shift;
	
	$self->{opened}=0;
}
