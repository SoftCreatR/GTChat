###################################################################
#  GTChat GTChat 0.96 Alpha Build 20060923 core file              #
#  Copyright 2001-2006 by Wladimir Palant (http://www.gtchat.de)  #
#  Copyright 2006 by Sascha Heldt (https://www.softcreatr.de)     #
###################################################################

package GT_Chat::ModifyRoom;
use strict;

bless({
	action_handlers => {
		'modifyroom' => \&modify_handler,
		'deleteroom' => \&delete_handler,
	},
});

sub modify_handler
{
	my($self,$main) = @_;

	$main->{template_vars}{backaddr} = 'javascript:history.back()';

	my $modify = $main->{input}{modify};
	delete $main->{input}{modify};

	my $room = $main->loadRoom($main->{input}{name});
	my $oldowner;
	if ($modify)
	{
		$main->fatal_error('unknownroom',{roomname => $main->{input}{name}}) unless defined($room);

		$oldowner = $main->loadUser($room->{owner}) if (exists($room->{owner}) && $room->{owner} ne "");
		$main->fatal_error('roomlist_nopermission') if ((!$oldowner || $oldowner->{name} ne $main->{current_user}{name}) && (!$main->hasPermission('rooms_modify') || ($oldowner && $main->{current_user}{tempgroup}<=$oldowner->{group})));
	}
	else
	{
		$main->fatal_error('nopermission') unless $main->hasPermission('rooms_create');
		$main->fatal_error('noroomnamegiven') unless $main->{input}{name} =~ /\S/;
		$main->fatal_error('roomnameexists',{name => $main->{input}{name}}) if $room;
		$room = {};
	}

	my $oldroom;
	if ($modify)
	{
		$oldroom = {};
		foreach (keys %$room)
		{
			$oldroom->{$_} = $room->{$_};
		}
	}

	foreach (keys %{$main->{input}})
	{
		$room->{$_} = $main->{input}{$_};
	}

	$room->{name}=$oldroom->{name} if $modify;
	if ($main->hasPermission('rooms_changeowner'))
	{
		if (exists($room->{owner}) && $room->{owner} ne "")
		{
			my $candidates = $main->getPossibleUsernames($room->{owner});
			$main->fatal_error('unknownowner',{nick => $room->{owner}}) if $#$candidates < 0;
			$main->fatal_error('ambiguousowner') if $#$candidates > 1;
			$room->{owner}=$candidates->[0];
		}
	}
	else
	{
		$room->{owner} = $modify ? $oldroom->{owner} : $main->{current_user}{name};
	}

	if ($main->lowercase($room->{name}) eq $main->lowercase($main->{settings}{default}{room}))
	{
		$room->{closed} = 0;
		$room->{permanent} = 1;
	}
	else
	{
		$room->{closed} = $modify ? $oldroom->{closed} : 1 unless $main->hasPermission('rooms_createpublic');
		$room->{closed} = $modify ? $oldroom->{closed} : 0 unless $main->hasPermission('rooms_createprivate');
		$room->{permanent} = $modify ? $oldroom->{permanent} : 0 unless $main->hasPermission('rooms_createpermanent');
	}

	$main->saveRoom($room);

	my @toDo = ();

	if (!$room->{permanent} && $main->{current_user}{room} ne $room->{name_lc})
	{
		$main->{current_user}{room} = $room->{name_lc};
		$main->saveOnlineInfo($main->{current_user});
	}

	$main->sendOutputStrings(@toDo) if $#toDo>=0;

	$main->printTemplate('roomlist');
}

sub delete_handler
{
	my($self,$main) = @_;

	$main->{template_vars}{backaddr} = 'javascript:history.back()';

	my $room = $main->loadRoom($main->{input}{name});
	$main->fatal_error('unknownroom',{roomname => $main->{input}{name}}) unless defined($room);
	$main->fatal_error('deleteroom_default') if $main->lowercase($main->{settings}{default}{room}) eq $room->{name_lc};

	my $oldowner = $main->loadUser($room->{owner}) if (exists($room->{owner}) && $room->{owner} ne "");
	$main->fatal_error('roomlist_nopermission') if ((!$oldowner || $oldowner->{name} ne $main->{current_user}{name}) && (!$main->hasPermission('rooms_modify') || ($oldowner && $main->{current_user}{tempgroup}<=$oldowner->{group})));

	$main->removeRoom($room->{name});

	$main->printTemplate('roomlist');
}
