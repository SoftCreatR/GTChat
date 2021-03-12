###################################################################
#  GTChat 0.95 Alpha Plugin                                       #
#  Written for release 20021101                                   #
#  Author: Wladimir Palant                                        #
#                                                                 #
#  This plugin loads provides the template variables to access    #
#  the complete users list.                                       #
###################################################################

package GTChat::Plugins::AllUsers::095_01;
use strict;
use vars qw(@ISA);

@ISA = ('GTChat::Enum');

bless({
	template_var_handlers => {
		'allusers' => \&handler,
		'allusers_count' => \&handler,
	},
	opened => 0,
	index => -1,
});

sub handler
{
	my($self,$main,$var) = @_;
	
	my $enum=$main->{modules}{'sourcedir::Enum.pm'};

	$self->{main} = $main;
	$self->{list} = $main->getAllUsers();

	$main->{template_vars}{allusers} = $self;
	$main->{template_vars}{allusers_count} = $#{$self->{list}}+1;
}

sub open
{
	my $self=shift;
	
	$self->close if $self->{opened};
	
	$self->{index} = -1;
	$self->{opened} = 1;
}

sub hasNext
{
	my $self=shift;
	return ($self->{opened} && $self->{index}<$#{$self->{list}});
}

sub next
{
	my $self=shift;
	
	return undef if (!$self->{opened} || $self->{index}>=$#{$self->{list}});
	
	$self->{index}++;

	$self->{list}[$self->{index}] =~ s/[\n\r]//g;

	my %ret = ();
	($ret{nickname}, $ret{username}) = split(/\|/,$self->{list}[$self->{index}]);

	return \%ret;
}

sub close
{
	my $self=shift;
	
	$self->{opened}=0;
}
