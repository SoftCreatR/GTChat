###################################################################
#  GTChat 0.95 Alpha Plugin                                       #
#  Written for release 20021120                                   #
#  Author: Wladimir Palant                                        #
#                                                                 #
#  This class should help creating chat outputs.                  #
###################################################################

package GTChat::Plugins::Output::095_02;
use strict;

bless({});

sub createOutput
{
	my($main,$params) = @_;
	
	return bless([undef,undef,$main->toOutputString($params),undef,$main]);
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
	
	$self->[0] = $self->[4]{current_user}{name};
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
	
	$self->[1] = $self->[4]{current_user}{room};
	return $self;
}

sub setChangedAttributes
{
	my $self = shift;
	
	$self->[3] = [@_];
	return $self;
}
