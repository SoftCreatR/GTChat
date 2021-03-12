###################################################################
#  GTChat 0.95 Alpha Plugin                                       #
#  Written for release 20020911                                   #
#  Author: Wladimir Palant                                        #
#                                                                 #
#  This plugin restricts the maximum number of users in the       #
#  chat by the variable max_users in Settings.dat                 #
###################################################################

package GTChat::Plugins::MaxUsers::095_01;
use strict;

return bless({});

sub checkLogin
{
	my($self,$main,$user,$room) = @_;

	return 1 if $main->hasPermission('ignore_max_users',$user);
	
	my $users = $main->getOnlineUsers();

	$main->fatal_error('max_chat_users',{maxcount => $main->{settings}{max_users}}) if ($main->{settings}{max_users} && $#$users+1 >= $main->{settings}{max_users});
	
	if ($room->{max_users})
	{
		my $count = 0;
		foreach (@$users)
		{
			$count++ if ($room->{name_lc} eq (split(/\|/))[3]);
		}
		$main->fatal_error('max_room_users',{maxcount => $room->{max_users}}) if ($count >= $room->{max_users})
	}
}
