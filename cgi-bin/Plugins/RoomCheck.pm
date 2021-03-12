###################################################################
#  GT-Chat 0.96 Alpha Plugin                                       #
#  Written for release whatever                                   #
#  Author: Wladimir Palant                                        #
#                                                                 #
#  This plugin checks a room when changed or when a new room is   #
#  created.                                                       #
###################################################################

package GT_Chat::Plugins::RoomCheck::096_01;
use strict;

return bless({});

sub beforeRoomSave
{
	my ($self,$main,$room,$oldroom) = @_;

	if (exists($main->{settings}{check_room_fields_range}))
	{
		foreach (keys %{$main->{settings}{check_room_fields_range}})
		{
			$room->{$_} = int($room->{$_});
			$room->{$_} = $main->{settings}{check_room_fields_range}{$_}[0] if ($room->{$_} < $main->{settings}{check_room_fields_range}{$_}[0]);
			$room->{$_} = $main->{settings}{check_room_fields_range}{$_}[1] if ($room->{$_} > $main->{settings}{check_room_fields_range}{$_}[1]);
		}
	}

	$room->{topic} = $main->toHTML($room->{topic});
	$room->{moderated} = $oldroom ? $oldroom->{moderated} : 0 unless $main->hasPermission('rooms_createmoderated');

	if (exists($main->{settings}{check_room_fields_length}))
	{
		foreach (keys %{$main->{settings}{check_room_fields_length}})
		{
			$main->fatal_error($main->{settings}{check_room_fields_length}{$_}[1]) if (length($room->{$_}) > $main->{settings}{check_room_fields_length}{$_}[0]);
		}
	}
}
