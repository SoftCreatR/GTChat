###################################################################
#  GT-Chat 0.96 Alpha Plugin                                       #
#  Written for release whatever                                   #
#  Author: Wladimir Palant                                        #
#                                                                 #
#  This plugin manages the users information in the text files    #
#  in the Members directory. There are several mandatory fields,  #
#  custom fields can be added to the custom_profile_fields        #
#  variable in Settings.dat.                                      #
###################################################################

package GT_Chat::Plugins::UserModule::096_01;
use strict;

# Profile fields:
# deleted: room, away,
#          smileys, gagtime, birthdate, www, wwwtitle => custom
# moved: privateemail(emailpublic)
# added: registration, timeoffset, code

my @profile_fields = ('password','nick','group','email','privateemail','color','ip','forwardedfor','host','browser','registration','lastlogin','','timeoffset','code','permissions');

*addUser = *saveUser;   # make addUser an alias for saveUser for compatibility reasons

my %users = ();

return bless({});

sub convertName
{
	my($main,$name) = @_;
	
	$name =~ s/^\s+|\s+$//g;
	$name =~ s/[\s=;<>:@|'"&#$main->{settings}{custom_forbidden_chars}]/_/g;
	
	return $main->lowercase($name);
}

sub getUsername
{ 
	my($main,$nick) = @_;

	$main->open(local *FILE,$main->translateName('memberdir::memberlist.txt')) || return undef;
	my @users=<FILE>;
	$main->close(*FILE);

	$nick = convertName($main,$nick);

	my $min = 0;
	my $max = $#users;
	
	while ($min <= $max)
	{
		my $curindex = int(($min+$max)/2);
		my ($curnick,$curname) = split(/\|/,$users[$curindex]);
		my $result = convertName($main,$curnick) cmp $nick;
		
		if ($result == 0)
		{
			$curname =~ s/[\n\r]//g;
			return $curname;
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

	return undef;
}

sub getPossibleUsernames
{
	my($main,$nick) = @_;

	$main->open(local *FILE,$main->translateName('memberdir::memberlist.txt')) || return [];
	my @users=<FILE>;
	$main->close(*FILE);

	$nick = convertName($main,$nick);

	my $min = 0;
	my $max = $#users;
	
	# Find the first nickname beginning with the given string
	while ($min <= $max)
	{
		my $curindex = int(($min+$max)/2);
		my ($curnick,$curname) = split(/\|/,$users[$curindex]);
		my $result = convertName($main,$curnick) cmp $nick;
		
		if ($result == 0)
		{
			$curname =~ s/[\n\r]//g;
			return [$curname,$curnick];  # return if found an exact matching
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
	
	# Find all following strings with the same beginning
	my @ret;
	while ($min <= $#users)
	{
		$users[$min] =~ s/[\n\r]//g;
		my ($curnick,$curname) = split(/\|/,$users[$min]);
		if (length($curnick) >= length($nick) && $main->lowercase(substr($curnick,0,length($nick))) eq $nick)
		{
			push @ret,$curname,$curnick;
		}

		$min++;
	}

	return \@ret;
}

sub getAllUsers
{
	my($main) = @_;

	$main->open(local *FILE,$main->translateName('memberdir::memberlist.txt')) || return [];
	my @users=<FILE>;
	$main->close(*FILE);

	foreach (@users)
	{
		$_ =~ s/[\n\r]//g;
	}
	
	return \@users;
}

sub existsUser
{
	my($main,$username) = @_;

	my $filename = unpack("H*",convertName($main,$username));
	return -e($main->translateName("memberdir::$filename.dat"));
}

sub saveUser
{
	my($main,$user) = @_;
	
	$user->{name} = convertName($main, $user->{name});
	$user->{nick} =~ s/^\s+|\s+$//g;
	$user->{nick} =~ s/[\s=;<>:@|'"&#$main->{settings}{custom_forbidden_chars}]/_/g;
	
	$main->fatal_error('illegalname') if $user->{name} eq "" || $user->{nick} eq "";

	my $olduser = $users{$user->{name}};
	$main->invokeModulesList($main->{settings}{custom_user_listener},'beforeUserSave',$user,$olduser);

	my $permissions = (defined($user->{permissions}) ? join('|',%{$user->{permissions}}) : "");
	my $filename = unpack("H*", $user->{name});

	$main->open(local *FILE,'>'.$main->translateName("memberdir::$filename.dat")) || $main->fatal_error('couldnotcreate',{file => $main->translateName("memberdir::$filename.dat")});
	
	# Save predefined fields
	for (my $i=0;$i<20;$i++)
	{
		if ($i <= $#profile_fields && defined($user->{$profile_fields[$i]}))
		{
			my $field = $profile_fields[$i] eq 'permissions' ? $permissions : $user->{$profile_fields[$i]};
			$field =~ s/[\r\n]//g;
			print FILE "$field\n";
		}
		else
		{
			print FILE "\n";
		}
	}
	
	# Save custom fields
	foreach (@{$main->{settings}{custom_profile_fields}})
	{
		if (defined($user->{$_}))
		{
			$user->{$_} =~ s/[\r\n]//;
			print FILE "$_\n";
			print FILE "$user->{$_}\n";
		}
	}
	
	$main->close(*FILE);

	if (!defined($olduser) || $olduser->{nick} ne $user->{nick})
	{
		$main->open(local *FILE,'+>>'.$main->translateName('memberdir::memberlist.txt')) || $main->fatal_error('couldnotopen',{file => $main->translateName('memberdir::memberlist.txt')});
		seek(FILE,0,0);
	
		my @users=<FILE>;
		
		if (defined($olduser))
		{
			# Remove the old nick from the list
			my $oldnick = convertName($main,$olduser->{nick});
			my $min = 0;
			my $max = $#users;
			while ($min <= $max)
			{
				my $curindex = int(($min+$max)/2);
				my ($curnick,$curname) = split(/\|/,$users[$curindex]);
				my $result = convertName($main,$curnick) cmp $oldnick;
	
				if ($result == 0)
				{
					splice(@users,$curindex,1);
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
		}
		
		# Find the insertion point for the new nick
		my $nick = convertName($main,$user->{nick});
		my $min = 0;
		my $max = $#users;
		while ($min <= $max)
		{
			my $curindex = int(($min+$max)/2);
			my ($curnick,$curname) = split(/\|/,$users[$curindex]);
			my $result = convertName($main,$curnick) cmp $nick;
			
			if ($result == 0)
			{
				$users[$curindex] = "$user->{nick}|$user->{name}\n";
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
		
		# Insert new nick
		if ($min>$max)
		{
			splice(@users,$min,0,"$user->{nick}|$user->{name}\n");
		}
		
		seek(FILE,0,0);
		truncate(FILE,0);
		print FILE @users;

		$main->close(*FILE);
	}

	$main->invokeModulesList($main->{settings}{custom_user_listener},'afterUserSave',$user,$olduser);
	$users{$user->{name}} = $user;
}

sub loadUser
{
	my($main,$username,$user) = @_;

	$username = convertName($main,$username);

	return undef if ($username eq "");
	
	my $filename = unpack("H*",$username);

	$main->open(local *FILE,$main->translateName("memberdir::$filename.dat")) || return undef;
	
	my %olduser = ();
	$olduser{name} = $username;
	
	my $i=0;
	my $is_key=1;
	my $key;
	while (<FILE>)
	{
		my $entry=$_;
		$entry =~ s/[\n\r]//g;

		if ($i<20)   # Load predefined fields
		{
			$olduser{$profile_fields[$i]} = $entry if ($i <= $#profile_fields);
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
				$olduser{$key} = $entry;
			}
			$is_key=!$is_key;
		}
	}
	
	$main->close(*FILE);

	$user = {} if (!defined($user));
	$user->{$_} = $olduser{$_} foreach keys %olduser;

	if (defined($olduser{permissions}))
	{
		my %permissions = split(/\|/,$olduser{permissions});
		my %permissions2 = %permissions;
		$olduser{permissions} = \%permissions;
		$user->{permissions} = \%permissions2;
	}
	$users{$olduser{name}} = \%olduser;

	return $user;
}

sub removeUser
{
	my($main,$user) = @_;

	$main->invokeModulesList($main->{settings}{custom_user_listener},'beforeUserDelete',$users{$user->{name}});

	if (!defined($user->{nick}) && exists($users{$user->{name}}))
	{
		$user->{nick} = $users{$user->{name}}->{nick};
	}

	my $nick = convertName($main,$user->{nick});

	$main->open(local *FILE,'+>>'.$main->translateName('memberdir::memberlist.txt')) || $main->fatal_error('couldnotopen',{file => $main->translateName('memberdir::memberlist.txt')});
	seek(FILE,0,0);

	my @users=<FILE>;
	
	my $min = 0;
	my $max = $#users;
	
	# Remove the user from the member list
	while ($min <= $max)
	{
		my $curindex = int(($min+$max)/2);
		my ($curnick,$curname) = split(/\|/,$users[$curindex]);
		my $result = convertName($main,$curnick) cmp $nick;

		if ($result == 0)
		{
			splice(@users,$curindex,1);
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

	if ($min > $max)   # user not found
	{
		$main->close(*FILE);
		return;
	}
	
	seek(FILE,0,0);
	truncate(FILE,0);
	print FILE foreach @users;

	$main->close(*FILE);

	#Remove the user's member file
	my $filename = unpack("H*",convertName($main,$user->{name}));
	unlink($main->translateName("memberdir::$filename.dat"));
	unlink($main->translateName("memberdir::$filename.msg"));

	$main->invokeModulesList($main->{settings}{custom_user_listener},'afterUserDelete',$users{$user->{name}});
	delete($users{$user->{name}});
}

sub getProfileFieldsList
{
	my($main) = @_;
	
	my @ret = @profile_fields;
	push @ret, @{$main->{settings}{custom_profile_fields}} if exists($main->{settings}{custom_profile_fields});
	
	return \@ret;
}
