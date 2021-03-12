###################################################################
#  GT-Chat 0.96 Alpha Plugin                                       #
#  Written for release whatever                                   #
#  Author: Wladimir Palant                                        #
#                                                                 #
#  This is a helper class for creating chat output.               #
###################################################################

package GT_Chat::Plugins::Output::096_01;
use strict;

bless({});

sub createOutput
{
	my($main,$params) = @_;
	
	return bless([undef,undef,$main->toOutputString($params),$main]);
}

sub createErrorOutput
{
	my($main,$errorname,$params) = @_;
	
	my @params = ();
	if ($params)
	{
		foreach (keys %$params)
		{
			push @params,"$_=$params->{$_}";
		}
	}
	
	return $main->createOutput(
			{
				template => 'message',
				message => "error_$errorname",
				'*' => [@params],
			})->restrictToCurrentUser;
}

sub createInfoOutput
{
	my($main,$infoname,$params) = @_;
	
	my @params = ();
	if ($params)
	{
		foreach (keys %$params)
		{
			push @params,"$_=$params->{$_}";
		}
	}
	
	return $main->createOutput(
			{
				template => 'message',
				message => "info_$infoname",
				'*' => [@params],
			})->restrictToCurrentUser;
}

sub restrictToUser
{
	my($self,$username) = @_;
	
	$self->[0] = $username;
	return $self;
}

sub restrictToCurrentUser
{
	my $self = shift;
	
	$self->[0] = $self->[3]{current_user}{name};
	return $self;
}

sub restrictToRoom
{
	my($self,$roomname) = @_;
	
	$self->[1] = $roomname;
	return $self;
}

sub restrictToCurrentRoom
{
	my $self = shift;
	
	$self->[1] = $self->[3]{current_user}{room};
	return $self;
}
