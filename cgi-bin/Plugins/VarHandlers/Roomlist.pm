###################################################################
#  GT-Chat 0.96 Alpha Plugin                                       #
#  Written for release whatever                                   #
#  Author: Wladimir Palant                                        #
#                                                                 #
#  This plugin provides the template variables that are necessary #
#  to show the rooms, online users or both.                       #
###################################################################

package GT_Chat::Plugins::Roomlist::096_01;
use strict;

@GT_Chat::Plugins::Rooms_enum::096_01::ISA = ('GT_Chat::Enum');
@GT_Chat::Plugins::Onlineusers_enum::096_01::ISA = ('GT_Chat::Enum');
@GT_Chat::Plugins::Rooms_Onlineusers_enum::096_01::ISA = ('GT_Chat::Enum');

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
	
		$main->{template_vars}{roomlist} = GT_Chat::Plugins::Rooms_enum::096_01::new($main,$rooms);
		$main->{template_vars}{roomlist_count} = $#$rooms+1;
	}

	if ($var =~ /onlineusers/)
	{
		my @users = sort {
			$main->lowercase($a->{room}) cmp $main->lowercase($b->{room}) or $main->lowercase($a->{nick}) cmp $main->lowercase($b->{nick});
		} @{$main->getOnlineUsers || []};
		
		$main->{template_vars}{onlineusers} = GT_Chat::Plugins::Onlineusers_enum::096_01::new($main,\@users);
		$main->{template_vars}{onlineusers_count} = $#users+1;
	}

	if ($var =~ /onlineusers/ && $var =~ /roomlist/)
	{
		$main->{template_vars}{'roomlist&onlineusers'} = GT_Chat::Plugins::Rooms_Onlineusers_enum::096_01::new($main);
	}
}

package GT_Chat::Plugins::Rooms_enum::096_01;

sub new
{
	my($main,$list) = @_;

	my $enum=$main->{modules}{'sourcedir::Enum.pm'};

	return bless({
		list => $list,
		opened => 0,
		main => $main,
		index => -1,
		default_room => $main->lowercase($main->{settings}{default}{room}),
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
			$room->{default} = ($room->{name_lc} eq $self->{default_room});
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
			$room->{default} = ($room->{name_lc} eq $self->{default_room});
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

package GT_Chat::Plugins::Onlineusers_enum::096_01;

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
	my $ret = $self->{list}[$self->{index}];
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

		while ($self->{index}<$#{$self->{list}} && ($self->{list}[$self->{index}+1]->{room} cmp $room) < 0)
		{
			$self->{index}++;
		}
		
		$self->{stopindex} = $self->{index};
		while ($self->{stopindex}<$#{$self->{list}} && $self->{list}[$self->{stopindex}+1]->{room} eq $room)
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

package GT_Chat::Plugins::Rooms_Onlineusers_enum::096_01;
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
