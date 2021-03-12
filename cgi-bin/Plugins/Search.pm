###################################################################
#  GT-Chat 0.96 Alpha Plugin                                       #
#  Written for release whatever                                   #
#  Author: Wladimir Palant                                        #
#                                                                 #
#  This plugin manages the user search.                           #
###################################################################

package GT_Chat::Plugins::Search::096_01;
use strict;
use vars qw(@ISA);

@ISA = ('GT_Chat::Enum');

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
	
	my $replace = "\"<strong>$mask</strong>\"";
	for (my $i=1;$replace =~ s/[?*]+/<\/strong>\$$i<strong>/;$i++) {}

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
	$main->{template_vars}{search_results} = new($main,\@found);
	$main->{template_vars}{search_results_count} = $#found+1;

	$main->printTemplate('search_results');
}

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
