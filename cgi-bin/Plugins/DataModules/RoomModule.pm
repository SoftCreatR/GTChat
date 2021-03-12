###################################################################
#  GT-Chat 0.96 Alpha Plugin                                       #
#  Written for release whatever                                   #
#  Author: Wladimir Palant                                        #
#                                                                 #
#  This plugin manages the rooms information in the text files    #
#  in the Rooms directory. There are some mandatory fields,       #
#  custom fields can be added to the custom_room_fields variable  #
#  in Settings.dat.                                               #
###################################################################

package GT_Chat::Plugins::RoomModule::096_01;

use strict;

my @room_fields = ('name','owner','closed','permanent','invited');

*addRoom = *saveRoom;   # make addRoom an alias for saveRoom for compatibility reasons

my %rooms = ();

return bless({});

sub convertName
{
	my($main,$name) = @_;
	
	$name =~ s/^\s+|\s+$//g;
	$name =~ s/[\s=;<>:@|'"&#\n\r$main->{settings}{custom_forbidden_chars}]/_/g;
	
	return $main->lowercase($name);
}

sub getAllRooms
{
	my($main) = @_;

	$main->open(local *FILE,$main->translateName('roomdir::roomlist.txt')) || return [];
	my @rooms=<FILE>;
	$main->close(*FILE);
	
	foreach (@rooms)
	{
		$_ =~ s/[\n\r]//g;
	}
	
	return \@rooms;
}

sub existsRoom
{
	my($main,$roomname) = @_;

	my $filename = unpack("H*",convertName($main,$roomname));
	return -e($main->translateName("roomdir::$filename.dat"));
}

sub saveRoom
{
	my($main,$room) = @_;

	$room->{name} =~ s/^\s+|\s+$//g;
	$room->{name} =~ s/[\s=;<>:@|'"&#\n\r$main->{settings}{custom_forbidden_chars}]/_/g;
	$room->{name_lc} = convertName($main,$room->{name});

	$main->fatal_error('illegalroomname') if $room->{name_lc} eq "";

	my $oldroom = $rooms{$room->{name_lc}};

	$main->invokeModulesList($main->{settings}{custom_room_listener},'beforeRoomSave',$room,$oldroom);

	my $filename = unpack("H*",$room->{name_lc});

	$main->open(local *FILE,'>'.$main->translateName("roomdir::$filename.dat")) || $main->fatal_error('couldnotcreate',{file => $main->translateName("roomdir::$filename.dat")});
	
	# Save predefined fields
	for (my $i=0;$i<20;$i++)
	{
		if ($i <= $#room_fields && defined($room->{$room_fields[$i]}))
		{
			my $field = $room->{$room_fields[$i]};
			$field =~ s/[\r\n]//g;
			print FILE "$field\n";
		}
		else
		{
			print FILE "\n";
		}
	}
	
	# Save custom fields
	foreach (@{$main->{settings}{custom_room_fields}})
	{
		if (defined($room->{$_}))
		{
			$room->{$_} =~ s/[\r\n]//g;
			print FILE "$_\n";
			print FILE "$room->{$_}\n";
		}
	}
	
	$main->close(*FILE);

	if (!defined($oldroom))
	{
		$main->open(local *FILE,'+>>'.$main->translateName('roomdir::roomlist.txt')) || $main->fatal_error('couldnotopen',{file => $main->translateName('roomdir::roomlist.txt')});
		seek(FILE,0,0);
	
		my @rooms=<FILE>;
		
		my $min = 0;
		my $max = $#rooms;
		
		# Find the insertion point for the new room in the rooms list
		while ($min <= $max)
		{
			my $curindex = int(($min+$max)/2);
			my $result = convertName($main,$rooms[$curindex]) cmp $room->{name_lc};
	
			if ($result == 0)
			{
				last;
			}
			elsif ($result < 0)
			{
				$min = $curindex + 1;
			}
			else
			{
				$max = $curindex - 1;
			}
		}
		
		if ($min > $max)  # room name not found
		{
			# Insert the new room into the rooms list
			splice(@rooms,$min,0,"$room->{name}\n");
		
			seek(FILE,0,0);
			truncate(FILE,0);
			print FILE @rooms;
		}
	
		$main->close(*FILE);
	}

	$main->invokeModulesList($main->{settings}{custom_room_listener},'afterRoomSave',$room,$oldroom);
	$rooms{$room->{name}} = $room;
}

sub loadRoom
{
	my($main,$roomname,$room) = @_;

	$roomname = convertName($main,$roomname);
	my $filename = unpack("H*",$roomname);

	$main->open(local *FILE,$main->translateName("roomdir::$filename.dat")) || return undef;
	
	my %oldroom = ();
	$oldroom{name_lc} = $roomname;
	
	my $i=0;
	my $is_key=1;
	my $key;
	while (<FILE>)
	{
		my $entry=$_;
		$entry =~ s/[\n\r]//g;
		if ($i<20)   # Load predefined fields
		{
			$oldroom{$room_fields[$i]} = $entry if ($i <= $#room_fields);
			$i++;
		}
		else         # Load custom fields
		{
			if ($is_key)
			{
				$key=$entry;
			}
			else
			{
				$oldroom{$key} = $entry;
			}
			$is_key=!$is_key;
		}
	}

	$main->close(*FILE);

	$room = {} if (!defined($room));
	$room->{$_} = $oldroom{$_} foreach keys %oldroom;

	$rooms{$oldroom{name_lc}} = \%oldroom;

	return $room;
}

sub removeRoom
{
	my($main,$name) = @_;

	$main->invokeModulesList($main->{settings}{custom_room_listener},'beforeRoomDelete',$rooms{$name});

	$main->open(local *FILE,'+>>'.$main->translateName('roomdir::roomlist.txt')) || $main->fatal_error('couldnotopen',{file => $main->translateName('roomdir::roomlist.txt')});
	seek(FILE,0,0);

	my @rooms=<FILE>;
	
	my $min = 0;
	my $max = $#rooms;
	
	# Remove the room from the rooms list
	$name = convertName($main,$name);
	while ($min <= $max)
	{
		my $curindex = int(($min+$max)/2);
		my $result = convertName($main,$rooms[$curindex]) cmp $name;

		if ($result == 0)
		{
			splice(@rooms,$curindex,1);
			last;
		}
		elsif ($result < 0)
		{
			$min = $curindex + 1;
		}
		else
		{
			$max = $curindex - 1;
		}
	}
	
	seek(FILE,0,0);
	truncate(FILE,0);
	print FILE @rooms;

	$main->close(*FILE);

	#Remove the room's file
	my $filename = unpack("H*",$name);
	unlink($main->translateName("roomdir::$filename.dat"));

	$main->invokeModulesList($main->{settings}{custom_room_listener},'afterRoomDelete',$rooms{$name});
	delete($rooms{$name});
}

sub isRoomPermitted
{
	my ($main,$room,$user) = @_;
	
	return 0 unless defined($room);

	$user = $main->{current_user} if (!defined($user));

	return 1 if (!$room->{closed} || $main->hasPermission('privaterooms',$user));

	if (defined($user))
	{
		return 1 if $user->{name} eq $room->{owner};
		foreach my $entry (split(/\s/,$room->{invited}))
		{
			return 1 if ($entry eq $user->{name});
		}
	}
	return 0;
}

sub getRoomFieldsList
{
	my($main) = @_;

	my @ret = @room_fields;
	push @ret, @{$main->{settings}{custom_room_fields}} if exists($main->{settings}{custom_room_fields});
	
	return \@ret;
}
