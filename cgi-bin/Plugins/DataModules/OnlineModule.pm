###################################################################
#  GTChat 0.95 Alpha Plugin                                       #
#  Written for release 20021120                                   #
#  Author: Wladimir Palant                                        #
#                                                                 #
#  This plugin manages the list of users online. The information  #
#  is stored in text files in the Online directory.               #
###################################################################

package GTChat::Plugins::OnlineModule::095_03;
use strict;

my @online_fields = ('id','name','nick','room','tempgroup','pull','away','lastalive','lasttalk','generator','ignored','lasttextid');

return bless({});

sub convertName
{
	my($main,$name) = @_;
	
	$name =~ s/^\s+|[=;<>:@|'"&#\n\r]|\s+$//g;
	$name =~ s/\s/_/g;
	
	return $main->lowercase($name);
}

sub getUsernameFromID
{
	my ($main,$id) = @_;
	
	$main->open(local *FILE, $main->translateName("onlinedir::$id.id")) || return undef;
	my $name=<FILE>;
	$main->close(*FILE);
	
	return $name;
}

# Light version of getOnlineUsers - returns only the number of users and does not perform kick test
sub getOnlineUsersCount
{
	my ($main) = @_;

	my $testrooms = {};

	my $dir = $main->translateName('onlinedir::');
	opendir(local *ONLINE,$dir) || return undef;

	my $ret = grep {/\.user$/} readdir(ONLINE);

	closedir(ONLINE);
	
	return $ret;
}

sub getOnlineUsers
{
	my ($main,$donotkick) = @_;

	my $testrooms = {};

	my $dir = $main->translateName('onlinedir::');
	opendir(local *ONLINE,$dir) || return undef;

	my @ret = grep {/\.user$/ && ($_ = getOnlineString($main,"$dir$_",$donotkick,$testrooms))} readdir(ONLINE);

	closedir(ONLINE);
	
	testTemporaryRooms($main,$testrooms) unless $donotkick;

	return \@ret;
}

sub getPossibleOnlineUsers
{
	my($main,$nick,$room) = @_;

	$nick = convertName($main,$nick);

	my $testrooms = {};

	my $dir = $main->translateName('onlinedir::');
	opendir(local *ONLINE,$dir) || return undef;

	my @ret=();
	foreach (readdir(ONLINE))
	{
		if (/\.user$/ && (my $string=getOnlineString($main,"$dir$_",undef,$testrooms)))
		{
			my $user=translateOnlineString($main,$string);

			if (!defined($room) || $user->{room} eq $room)
			{
				my $curnick = convertName($main,$user->{nick});
				if ($curnick eq $nick)
				{
					@ret = ($user);
					last;
				}
				
				push @ret,$user if (length($curnick) >= length($nick) && substr($curnick,0,length($nick)) eq $nick);
			}
		}
	}

	closedir(ONLINE);
	
	testTemporaryRooms($main,$testrooms);

	return \@ret;
}

sub getOnlineString
{
	my($main,$file,$donotkick,$testrooms) = @_;
	
	$main->open(local *USER,$file) || return undef;
	my $ret=<USER>;
	$main->close(*USER);

	if (!$donotkick && (my $reason = kick_test($main,$ret)))
	{
		my $user = translateOnlineString($main,$ret);
		kickUser($main,$user,$reason,$testrooms);
		return undef;
	}
	
	return $ret;
}

sub isOnline
{
	my ($main,$name) = @_;
	my $filename = $main->translateName('onlinedir::'.unpack("H*",convertName($main,$name)).'.user');

	return -e $filename;
}

sub loadOnlineInfo
{
	my ($main,$name,$user) = @_;
	my $filename = $main->translateName('onlinedir::'.unpack("H*",convertName($main,$name)).'.user');
	$user = {} if (!defined($user));

	return translateOnlineString($main,getOnlineString($main,$filename),$user);
}

sub saveOnlineInfo
{
	my ($main,$user) = @_;

	my $filename = $main->translateName('onlinedir::'.unpack("H*",convertName($main,$user->{name})).'.user');

	my $info = join('|', @$user{ @online_fields });

	$main->open(local *FILE,'>'.$filename) || $main->fatal_error('couldnotcreate',{file => $filename});
	print FILE $info;
	$main->close(*FILE);
}

sub addOnlineInfo
{
	my ($main,$user) = @_;
	
	$user->{lastalive}=$main->{runtime}{now} if (!defined($user->{lastalive}));
	$user->{lasttalk}=$main->{runtime}{now} if (!defined($user->{lasttalk}));

	my $dir = $main->translateName('onlinedir::');
	if (!defined($user->{id}) || $user->{id} eq "")
	{
		srand;
		do
		{
			$user->{id} = $user->{ip};
			$user->{id} =~ s/\D//g;
			$user->{id} = substr($user->{id}, length($user->{id})-9) if length($user->{id})>9;
			$user->{id} += 0;

			my $rand = rand;
			$rand =~ s/\D//g;
			$rand = substr($rand, length($rand)-9) if length($rand)>9;
			$user->{id} ^= $rand+0;

			my $time = $main->{runtime}{now};
			$time = substr($time, length($time)-9) if length($time)>9;
			$user->{id} ^= $main->{runtime}{now}+0;
		} while -e("$dir$user->{id}.id");
	}

	saveOnlineInfo($main,$user);

	$main->open(local *FILE,">$dir$user->{id}.id") || $main->fatal_error('couldnotcreate',{file => "$dir$user->{id}.id"});
	print FILE convertName($main,$user->{name});
	$main->close(*FILE);
}

sub translateOnlineString
{
	my($main,$string,$user) = @_;
	
	return undef if (!defined($string));

	$user = {} unless defined($user);
	@$user{ @online_fields } = split(/\|/,$string);
	return $user;
}

sub getOnlineFieldsList
{
	my($main) = @_;
	
	my @ret = @online_fields;
	
	return \@ret;
}

sub kick_test
{
	my($main,$string) = @_;

	my ($room,$pull,$lastalive,$lasttalk) = (split(/\|/,$string))[3,5,7,8];

	return {error_name => 'error_nonexistent_room'} unless $main->existsRoom($room);
	return {error_name => 'error_timeout'} if (($pull && $main->{runtime}{now} > $lastalive + $main->{settings}{alive_test_rate_pull}) ||
		   (!$pull && $main->{runtime}{now} > $lastalive + $main->{settings}{alive_test_rate_push}));
	return {error_name => 'error_autokick'} if ($main->{settings}{autokick_test_rate} && $main->{runtime}{now} > $lasttalk + $main->{settings}{autokick_test_rate});
}

sub kickUser
{ 
	my ($main,$user,$reason,$testrooms) = @_;

	return if (!defined($user) || !exists($user->{id}) || !exists($user->{name}));

	my $filename = unpack("H*",$user->{name});

	unless (-e $main->translateName("onlinedir::$user->{id}.id"))
	{
		unlink($main->translateName("onlinedir::$filename.user"));
		return;
	}

	$main->loadUser($user->{name},$user) unless defined($user->{group});

	if (defined($reason))
	{
		$main->open(local *FILE,'+>>'.$main->translateName('onlinedir::logout.reasons')) || $main->fatal_error('couldnotopen',{file => $main->translateName('onlinedir::logout.reasons')});
		seek(FILE,0,0);
		my @entries = <FILE>;
		seek(FILE,0,0);
		truncate(FILE,0);

		foreach (@entries)
		{
			$_ =~ s/[\n\r]//g;
			my @parts = split(/\|/,$_);
			if ($parts[0] != $user->{id} && $main->{runtime}{now}-$parts[1] <= $main->{settings}{logoutreason_keeping_time})
			{
				print FILE "$_\n";
			}
		}
		print FILE "$user->{id}|$main->{runtime}{now}|".join('|',%$reason)."\n";

		$main->close(*FILE);
	}

	unlink($main->translateName("onlinedir::$user->{id}.id"));

	$main->sendOutputStrings($main->createOutput({template => 'quit'})->restrictToUser($user->{name}));

	unlink($main->translateName("onlinedir::$filename.user"));
	unlink($main->translateName("tmpdir::$filename.queue"));
	unlink($main->translateName("tmpdir::$filename.oldqueue"));
	unlink($main->translateName("tmpdir::$filename.pipe"));

	if (exists($user->{generator}) && $user->{generator} ne '')
	{
		$main->{modules}{$user->{generator}}->cleanUp($main,$user);
	}

	if ($testrooms)
	{
		$testrooms->{$user->{room}}=1;
	}
	else
	{
		testTemporaryRooms($main,{$user->{room} => 1});
	}

	my @toDo = ();
	if (!$reason || !$reason->{nologoutmsg})
	{
		my $output1 = $main->createOutput(
					{
						template => 'leaved',
						name => $user->{name},
						nick => $user->{nick},
						room => $user->{room},
					});
		$output1->restrictToRoom($user->{room});
		push @toDo, $output1;
	}
	my $output2 = $main->createOutput(
			{
				template => 'changed',
				name => $main->{current_user}{name},
				room => $main->{current_user}{room},
				oldroom => $main->{current_user}{room},
				'*' => ['online'],
			});
	push @toDo, $output2;
	$main->sendOutputStrings(@toDo);

	$main->invokeModulesList($main->{settings}{custom_logout_logger},'logoutPerformed',$user);

	delete($user->{id});
}

sub testTemporaryRooms
{
	my ($main,$rooms) = @_;
	
	my %rooms = ();
	foreach my $roomname (keys %$rooms)
	{
		my $room = $main->loadRoom($roomname);
		$rooms{$roomname}=1 if ($room && !$room->{permanent});
	}
	
	if (keys %rooms > 0)
	{
		my $users = $main->getOnlineUsers();
		foreach (@$users)
		{
			delete $rooms{(split(/\|/))[3]};
		}
	
		$main->removeRoom($_) foreach (keys %rooms);
	}
}
