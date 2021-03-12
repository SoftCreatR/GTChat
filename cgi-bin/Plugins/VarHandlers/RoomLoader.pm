###################################################################
#  GT-Chat 0.96 Alpha Plugin                                       #
#  Written for release whatever                                   #
#  Author: Wladimir Palant                                        #
#                                                                 #
#  This plugin provides the template variables $room_information  #
#  (roomname is taken from the roomname query string parameter)   #
#  and $current_room (the room of the current user).              #
###################################################################

package GT_Chat::Plugins::RoomLoader::096_01;
use strict;

bless({
	template_var_handlers => {
		'room_information' => \&handler,
		'current_room' => \&handler,
	},
});

sub handler
{
	my($self,$main,$var) = @_;
	
	my $roomname;
	$roomname = $main->{current_user}{room};
	$roomname = $main->{input}{roomname} if ($var eq 'room_information' && exists($main->{input}{roomname}) && $main->{input}{roomname} ne "");
	if (defined($roomname))
	{
		my $room = $main->loadRoom($roomname);

		$main->fatal_error('unknownroom',{roomname => $roomname}) unless (defined($room) && $main->isRoomPermitted($room));

		$room->{default} = ($room->{name_lc} eq $main->lowercase($main->{settings}{default}{room}));
		$room->{owner} = $main->loadUser($room->{owner}) if (exists($room->{owner}) && $room->{owner} ne "");

		$main->{template_vars}{$var} = $room;
	}
}
