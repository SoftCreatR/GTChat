###################################################################
#  GTChat 0.95 Alpha Plugin                                       #
#  Written for release 20021225                                   #
#  Author: Wladimir Palant                                        #
#                                                                 #
#  This plugin provides the template variables that are necessary #
#  to show the rooms, online users or both.                       #
###################################################################

package GTChat::Plugins::Roomlist::095_02;
use strict;

@GTChat::Plugins::Rooms_enum::095_01::ISA = ('GTChat::Enum');
@GTChat::Plugins::Onlineusers_enum::095_01::ISA = ('GTChat::Enum');
@GTChat::Plugins::Rooms_Onlineusers_enum::095_01::ISA = ('GTChat::Enum');

bless({
	template_var_handlers => {
		'roomlist' => \&handler,
		'roomlist_count' => \&handler,
		'onlineusers' => \&handler,
		'onlineusers_count' => \&handler,
		'roomlist&onlineusers' => \&handler,
	},
});

sub handler
{
	my($self,$main,$var) = @_;
	
	if ($var =~ /roomlist/)
	{
		my $rooms = $main->getAllRooms || [];
	
		$main->{template_vars}{roomlist} = GTChat::Plugins::Rooms_enum::095_01::new($main,$rooms);
		$main->{template_vars}{roomlist_count} = $#$rooms+1;
	}

	if ($var =~ /onlineusers/)
	{
		my @users = sort {
			my @a1 = split(/\|/,$a);
			my @a2 = split(/\|/,$b);
			$main->lowercase($a1[3]) cmp $main->lowercase($a2[3]) or $main->lowercase($a1[2]) cmp $main->lowercase($a2[2]);
		} @{$main->getOnlineUsers || []};
		
		$main->{template_vars}{onlineusers} = GTChat::Plugins::Onlineusers_enum::095_01::new($main,\@users);
		$main->{template_vars}{onlineusers_count} = $#users+1;
	}

	if ($var =~ /onlineusers/ && $var =~ /roomlist/)
	{
		$main->{template_vars}{'roomlist&onlineusers'} = GTChat::Plugins::Rooms_Onlineusers_enum::095_01::new($main);
	}
}

package GTChat::Plugins::Rooms_enum::095_01;

sub new
{
	my($main,$list) = @_;

	my $enum=$main->{modules}{'sourcedir::Enum.pm'};

	return bless({
		list => $list,
		opened => 0,
		main => $main,
		index => -1,
	});
}

sub open
{
	my $self=shift;
	
	$self->close if $self->{opened};
	
	$self->{index} = -1;
	$self->{room} = undef;
	while ($self->{index} < $#{$self->{list}})
	{
		$self->{index}++;
		my $room = $self->{main}->loadRoom($self->{list}[$self->{index}]);
		if ($self->{main}->isRoomPermitted($room))
		{
			$self->{room} = $room;
			last;
		}
	}
	
	$self->{opened} = 1;
}

sub hasNext
{
	my $self=shift;
	return $self->{opened} && defined($self->{room});
}

sub next
{
	my $self=shift;
	
	return undef unless $self->{opened};

	my $ret = $self->{room};
	$self->{room} = undef;
	while ($self->{index} < $#{$self->{list}})
	{
		$self->{index}++;
		my $room = $self->{main}->loadRoom($self->{list}[$self->{index}]);
		if ($self->{main}->isRoomPermitted($room))
		{
			$self->{room} = $room;
			last;
		}
	}

	return $ret;
}

sub close
{
	my $self=shift;
	
	$self->{opened}=0;
}

package GTChat::Plugins::Onlineusers_enum::095_01;

sub new
{
	my($main,$list) = @_;

	my $enum=$main->{modules}{'sourcedir::Enum.pm'};

	return bless({
		list => $list,
		opened => 0,
		main => $main,
		index => -1,
	});
}

sub open
{
	my $self=shift;
	
	$self->close if $self->{opened};
	
	$self->{index} = -1 unless exists($self->{stopindex});
	$self->{opened} = 1;
}

sub hasNext
{
	my $self=shift;
	return ($self->{opened} && $self->{index} < $#{$self->{list}} && (!exists($self->{stopindex}) || $self->{index} < $self->{stopindex}));
}

sub next
{
	my $self=shift;
	
	return undef unless $self->{opened};

	$self->{index}++;
	my $ret = $self->{main}->translateOnlineString($self->{list}[$self->{index}]);
	$ret->{vip} = 1 if defined($self->{vips}) && grep {$_ eq $ret->{name}} split(/\s/,$self->{vips});
	return $ret;
}

sub close
{
	my $self=shift;
	
	$self->{opened}=0;
}

sub setRoom
{
	my($self,$room,$vips) = @_;
	
	if (defined($room))
	{
		$self->{vips} = $vips;

		while ($self->{index}<$#{$self->{list}} && ((split(/\|/,$self->{list}[$self->{index}+1]))[3] cmp $room) < 0)
		{
			$self->{index}++;
		}
		
		$self->{stopindex} = $self->{index};
		while ($self->{stopindex}<$#{$self->{list}} && (split(/\|/,$self->{list}[$self->{stopindex}+1]))[3] eq $room)
		{
			$self->{stopindex}++;
		}
		return ($self->{stopindex}-$self->{index});
	}
	else
	{
		delete $self->{stopindex};
		delete $self->{vips};
		$self->{index}=-1;
	}
}

package GTChat::Plugins::Rooms_Onlineusers_enum::095_01;
use strict;
use vars qw(@ISA);

sub new
{
	my($main) = @_;

	my $enum=$main->{modules}{'sourcedir::Enum.pm'};

	my $rooms = $main->{template_vars}{roomlist};
	my $users = $main->{template_vars}{onlineusers};
	return undef if (!defined($rooms) || !defined($users));
	
	return bless({
		rooms => $rooms,
		users => $users,
		opened => 0,
	});
}

sub open
{
	my $self=shift;
	
	$self->close if $self->{opened};
	
	$self->{rooms}->open;
	$self->{opened}=1;
}

sub hasNext
{
	my $self=shift;
	if ($self->{opened} && $self->{rooms}->hasNext)
	{
		return 1;
	}
	else
	{
		$self->{users}->setRoom;
		return 0;
	}
}

sub next
{
	my $self=shift;
	
	my $ret = $self->{rooms}->next;
	if (defined($ret))
	{
		$ret->{onlineusers} = $self->{users};
		$ret->{onlineusers_count} = $self->{users}->setRoom($ret->{name_lc}, $ret->{moderated} ? $ret->{vips} : undef);
	}
	return $ret;
}

sub close
{
	my $self=shift;
	
	$self->{users}->setRoom;
	$self->{rooms}->close;
	$self->{opened}=0;
}
