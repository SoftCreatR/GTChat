###################################################################
#  GT-Chat 0.96 Alpha Plugin                                       #
#  Written for release whatever                                   #
#  Author: Wladimir Palant                                        #
#                                                                 #
#  This plugin restricts the maximum number of users in the       #
#  chat by the variable max_users in Settings.dat                 #
###################################################################

package GT_Chat::Plugins::MaxUsers::096_01;
use strict;

return bless({});

sub beforeOnlineSave
{
	my($self,$main,$user,$olduser) = @_;

	return if defined($olduser) && $user->{room} eq $olduser->{room};   # room not changed
	return if $main->hasPermission('ignore_max_users',$user);           # has permission to change room

	my $users;
	if (!defined($olduser) && $main->{settings}{max_users} > 0)
	{
		$users = $main->getOnlineUsers();
		$main->fatal_error('max_chat_users',{maxcount => $main->{settings}{max_users}}) if $main->{settings}{max_users} <= $#$users + 1;
	}

	my $room = $main->loadRoom($user->{room});
	if ($room->{max_users} > 0)
	{
		$users = $main->getOnlineUsers() unless defined($users);

		my $count = 0;
		foreach (@$users)
		{
			$count++ if ($room->{name_lc} eq $_->{room});
		}
		$main->fatal_error('max_room_users',{maxcount => $room->{max_users}}) if $count >= $room->{max_users};
	}
}
