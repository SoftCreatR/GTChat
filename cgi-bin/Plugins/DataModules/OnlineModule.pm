###################################################################
#  GT-Chat 0.96 Alpha Plugin                                       #
#  Written for release whatever                                   #
#  Author: Wladimir Palant                                        #
#                                                                 #
#  This plugin manages the list of users online. The information  #
#  is stored in text files in the Online directory.               #
###################################################################

package GT_Chat::Plugins::OnlineModule::096_01;
use strict;

my @online_fields = ('id','name','nick','room','tempgroup','pull','lastalive','lasttalk','generator','ignored','lasttextid');

*addOnlineInfo = *saveOnlineInfo;   # make addOnlineInfo an alias for saveOnlineInfo for compatibility reasons

my %users = ();

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

	my $dir = $main->translateName('onlinedir::');
	opendir(local *ONLINE,$dir) || return undef;

	my $ret = grep {/\.user$/} readdir(ONLINE);

	closedir(ONLINE);
	
	return $ret;
}

sub getOnlineUsers
{
	my ($main,$donotkick) = @_;

	my $dir = $main->translateName('onlinedir::');
	opendir(local *ONLINE,$dir) || return undef;

	my @ret = grep {/\.user$/ && ($_ = readUserFile($main,"$dir$_",{},$donotkick))} readdir(ONLINE);

	closedir(ONLINE);
	
	return \@ret;
}

sub getPossibleOnlineUsers
{
	my($main,$nick,$room) = @_;

	$nick = convertName($main,$nick);

	my $dir = $main->translateName('onlinedir::');
	opendir(local *ONLINE,$dir) || return undef;

	my @ret=();
	foreach (readdir(ONLINE))
	{
		if (/\.user$/ && (my $user=readUserFile($main,"$dir$_",{})))
		{
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
	
	return \@ret;
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
	$user = {} unless defined($user);

	return readUserFile($main,$filename,$user);
}

sub saveOnlineInfo
{
	my ($main,$user) = @_;

	my $olduser = $users{$user->{name}};

	if (!defined($olduser))
	{
		$user->{lastalive}=$main->{runtime}{now} if (!defined($user->{lastalive}));
		$user->{lasttalk}=$main->{runtime}{now} if (!defined($user->{lasttalk}));

		if (!defined($user->{id}) || $user->{id} eq "")
		{
			my $dir = $main->translateName('onlinedir::');
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
	}

	$main->invokeModulesList($main->{settings}{custom_online_listener},'beforeOnlineSave',$user,$olduser);

	my $filename = $main->translateName('onlinedir::'.unpack("H*",convertName($main,$user->{name})).'.user');

	my $info = join('|', @$user{ @online_fields, @{$main->{settings}{custom_online_fields}} });

	$main->open(local *FILE,'>'.$filename) || $main->fatal_error('couldnotcreate',{file => $filename});
	print FILE $info;
	$main->close(*FILE);

	$filename = $main->translateName("onlinedir::$user->{id}.id");
	unless (-e $filename)
	{
		$main->open(local *FILE, '>'.$filename) || $main->fatal_error('couldnotcreate',{file => $filename});
		print FILE convertName($main,$user->{name});
		$main->close(*FILE);
	}

	$main->invokeModulesList($main->{settings}{custom_online_listener},'afterOnlineSave',$user,$olduser);
	$users{$user->{name}} = $user;
}

sub getOnlineFieldsList
{
	my($main) = @_;
	
	my @ret = @online_fields;
	push @ret, @{$main->{settings}{custom_online_fields}} if exists($main->{settings}{custom_online_fields});
	
	return \@ret;
}

sub kickUser
{ 
	my ($main,$user,$reason) = @_;

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

	$main->invokeModulesList($main->{settings}{custom_online_listener},'afterOnlineDelete',$users{$user->{name}},$reason);
	delete($users{$user->{name}});

	delete($user->{id});
}

sub kick_test
{
	my($main,$user) = @_;

	if ($user->{pull})
	{
		return {error_name => 'error_timeout'} if $main->{runtime}{now} > $user->{lastalive} + $main->{settings}{alive_test_rate_pull};
	}
	else
	{
		return {error_name => 'error_timeout'} if $main->{runtime}{now} > $user->{lastalive} + $main->{settings}{alive_test_rate_push};
	}
	return {error_name => 'error_autokick'} if ($main->{settings}{autokick_test_rate} > 0 && $main->{runtime}{now} > $user->{lasttalk} + $main->{settings}{autokick_test_rate});
	return {error_name => 'error_nonexistent_room'} unless $main->existsRoom($user->{room});

	return;
}

sub readUserFile
{
	my($main,$file,$user,$donotkick) = @_;
	
	$main->open(local *USER,$file) || return undef;
	my $string=<USER>;
	$main->close(*USER);

	my %olduser = ();
	@olduser{@online_fields, @{$main->{settings}{custom_online_fields}}} = split(/\|/, $string);

	$user->{$_} = $olduser{$_} foreach keys %olduser;

	$users{$olduser{name}} = \%olduser;

	if (!$donotkick && defined(my $reason = kick_test($main,$user)))
	{
		kickUser($main,$user,$reason);
		return undef;
	}
	
	return $user;
}
