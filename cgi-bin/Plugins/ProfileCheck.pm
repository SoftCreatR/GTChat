###################################################################
#  GTChat 0.95 Alpha Plugin                                       #
#  Written for release 20021120                                   #
#  Author: Wladimir Palant                                        #
#                                                                 #
#  This plugin checks the user's profile when changed or when     #
#  a new user is registered.                                      #
###################################################################

package GTChat::Plugins::ProfileCheck::095_03;
use strict;

return bless({});

sub checkProfile
{
	my ($self,$main,$user,$olduser) = @_;

	$main->fatal_error('nickchange_nopermission') if (defined($olduser) && $user->{nick} ne $olduser->{nick} && !$main->hasPermission('profile_change_nick'));

	if (exists($main->{settings}{check_profile_fields_range}))
	{
		foreach (keys %{$main->{settings}{check_profile_fields_range}})
		{
			$user->{$_} = int($user->{$_});
			$user->{$_} = $main->{settings}{check_profile_fields_range}{$_}[0] if ($user->{$_} < $main->{settings}{check_profile_fields_range}{$_}[0]);
			$user->{$_} = $main->{settings}{check_profile_fields_range}{$_}[1] if ($user->{$_} > $main->{settings}{check_profile_fields_range}{$_}[1]);
		}
	}

	if (exists($user->{birth_day}) && exists($user->{birth_month}) && exists($user->{birth_year}))
	{
		$user->{birth_day}=int($user->{birth_day});
		$user->{birth_month}=int($user->{birth_month});
		$user->{birth_year}=int($user->{birth_year});
		if ($user->{birth_day} || $user->{birth_month} || $user->{birth_year})
		{
			$main->fatal_error('illegalbirthdate') if ($user->{birth_day} < 1 || $user->{birth_day} > 31 ||
													$user->{birth_month} < 1 || $user->{birth_month} > 12 ||
													$user->{birth_year} < 1900 || $user->{birth_year} > 2100);
	
			$user->{birth_date} = "$user->{birth_day}.$user->{birth_month}.$user->{birth_year}";
		}
		else
		{
			delete($user->{birth_date});
		}
	}

	if ($user->{homepage} eq '' || $user->{homepage} eq 'http://')
	{
		delete($user->{homepage});
		delete($user->{homepagetitle});
	}
	else
	{
		if ($user->{homepage} !~ /^\w*\:\/\//)
		{
			$user->{homepage} = 'http://'.$user->{homepage};
		}

		$user->{homepage} = $main->toHTML($user->{homepage});
		$user->{homepagetitle} = $main->toHTML($user->{homepagetitle});
	}

	if ($olduser && $olduser->{nick} ne $user->{nick})
	{
		$main->fatal_error('nickalreadychanged',{interval => $main->{settings}{min_nickchange_interval}}) if defined($olduser->{lastnickchange}) && $main->{runtime}{now}-$olduser->{lastnickchange} < $main->{settings}{min_nickchange_interval}*60 && !$main->hasPermission('ignore_nickchange_interval');
		$user->{lastnickchange} = $main->{runtime}{now};
	}

	if ($user->{style})
	{
		my $stylefound = 0;
		if (exists($main->{settings}{styles}))
		{
			foreach (@{$main->{settings}{styles}})
			{
				$stylefound = 1 if ($_->[0] eq $user->{style});
			}
		}
		
		$user->{style} = $olduser->{style} unless $stylefound;
	}

	$main->fatal_error('noemailgiven') if ($user->{group}>=0 && $user->{email} eq "");
	$main->fatal_error('illegalemail') if($user->{email} ne "" && $user->{email} !~ /^([\w\-_.]+@[\w\-_.]+\.[a-z]{2,})$/);
	
	if (exists($main->{settings}{check_profile_fields_length}))
	{
		foreach (keys %{$main->{settings}{check_profile_fields_length}})
		{
			$main->fatal_error($main->{settings}{check_profile_fields_length}{$_}[1]) if (length($user->{$_}) > $main->{settings}{check_profile_fields_length}{$_}[0]);
		}
	}
}
