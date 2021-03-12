###################################################################
#  GTChat GTChat 0.95 Alpha Build 20040120 core file              #
#  Copyright 2001-2006 by Wladimir Palant (http://www.gtchat.de)  #
#  Copyright 2006 by Sascha Heldt (https://www.gt-chat.de)        #
###################################################################

package GT_Chat::ModifyProfile;
use strict;

bless({
	action_handlers => {
		'modifyprofile' => \&modify_handler,
		'deleteuser' => \&delete_handler,
	},
});

sub modify_handler
{
	my($self,$main) = @_;

	$main->{template_vars}{backaddr} = 'javascript:history.back()';

	my $user = $main->loadUser($main->{input}{name});
	$main->fatal_error('unknownusername',{name => $main->{input}{name}}) if (!defined($user));
	$main->fatal_error('profile_nopermission') if ($user->{name} ne $main->{current_user}{name} && (!$main->hasPermission('profile_modify') || $main->{current_user}{tempgroup}<=$user->{group}));

	my $olduser = {};
	foreach (keys %$user)
	{
		$olduser->{$_} = $user->{$_};
	}

	foreach (keys %{$main->{input}})
	{
		$user->{$_} = $main->{input}{$_};
	}

	my %environment;

	if ($user->{name} eq $main->{current_user}{name})
	{
		$environment{is_username} = 1;
		$environment{name} = $main->{input}{name};

		$main->{modules}{'sourcedir::environment_loader.pm'}->loadEnvironment($main,\%environment);

		if ($environment{has_uncrypted_password} && !$environment{is_username})
		{
			$user->{nick}=$environment{name};
		}
	}

	if ($user->{nick} eq "")
	{
		$user->{nick}=$user->{name};
	}

	if ($environment{has_uncrypted_password})
	{
		$user->{password} = $main->crypt($environment{has_uncrypted_password}->getPassword($main),$main->{settings}{pwseed});
	}
	elsif (exists($main->{input}{password}))
	{
		$user->{password} =~ s/^\s*(.*?)\s*$/$1/;
		$user->{password2} =~ s/^\s*(.*?)\s*$/$1/;

		$main->fatal_error('passwordsnotequal') if ($user->{password} ne $user->{password2});
		if ($user->{password} eq "")
		{
			$user->{password} = $olduser->{password};
		}
		else
		{
			$user->{password} = $main->crypt($user->{password},$main->{settings}{pwseed});
		}
	}
	delete($user->{password2});

	$user->{group}=$olduser->{group} if ($user->{name} eq $main->{current_user}{name} || $main->{current_user}{group}<=$user->{group});
	$user->{tempgroup}=$user->{group} if (exists($user->{tempgroup}) && $user->{tempgroup} < $user->{group});

	$user->{email} =~ s/[\s"&#|<>]//g;

	if ($user->{name} ne $main->{current_user}{name} && $main->hasPermission('profile_modify_permissions'))
	{
		foreach (keys %$user)
		{
			if (/^permissions\.([\w\.]+)$/)
			{
				my($key,$value) = ($1,$user->{"permissions.$1"});
				delete($user->{"permissions.$key"});

				$value = int($value);
				$value = 1 if $value>0;
				$value = -1 if $value<0;

				if ($main->hasPermission($key,undef,$key =~ /^command\./))
				{
					if ($value)
					{
						$user->{permissions}{$key} = $value;
					}
					else
					{
						delete($user->{permissions}{$key});
					}
				}
			}
		}
	}
	else
	{
		$user->{permissions} = $olduser->{permissions};
	}

	$user->{color}=$main->toColor(my $color = $user->{color});
	$main->fatal_error('unknowncolor',{color => $color}) unless defined($user->{color});
	$user->{registration}=$olduser->{registration};
	$user->{browser}=$olduser->{browser};
	$user->{ip}=$olduser->{ip};
	$user->{forwardedfor}=$olduser->{forwardedfor};
	$user->{host}=$olduser->{host};
	$user->{lastlogin}=$olduser->{lastlogin};

	$main->invokeModulesList($main->{settings}{custom_profile_checker},'checkProfile',$user,$olduser);

	my $tmpname = $main->getUsername($user->{nick});
	$main->fatal_error('nicknameexists',{nick => $user->{nick}}) if (defined($tmpname) && $tmpname ne $user->{name});

	$main->saveUser($user,$olduser->{nick});

	my $online = $main->loadOnlineInfo($user->{name});
	if (defined($online))
	{
		$user->{tempgroup}=$online->{tempgroup} if ($user->{name} eq $main->{current_user}{name} || !defined($user->{tempgroup}) || $main->{current_user}{group}<=$user->{tempgroup} || !$main->hasPermission('profile_settempgroup'));

		my %changed = ();
		my @toDo = ();
		foreach (@{$main->getProfileFieldsList})
		{
			$changed{$_}=1 if ($olduser->{$_} ne $user->{$_});
		}
		$changed{tempgroup}=1 if ($online->{tempgroup}!=$user->{tempgroup});

		if (exists($changed{nick}) || exists($changed{tempgroup}))
		{
			$online->{nick} = $user->{nick};
			$online->{tempgroup} = $user->{tempgroup};
			$main->saveOnlineInfo($online);
		}

		if (exists($changed{nick}))
		{
			push @toDo, [undef,$online->{room},$main->toOutputString(
				{
					template => 'nick_changed',
					name => $user->{name},
					nick => $user->{nick},
					oldnick => $olduser->{nick},
				}
			)];
		}

		if (keys %changed > 0)
		{
			push @toDo, [undef,undef,$main->toOutputString(
				{
					template => 'changed',
					name => $user->{name},
					room => $online->{room},
					oldroom => $online->{room},
					'*' => [keys %changed],
				}
			)];

			$main->sendOutputStrings(@toDo);
		}
	}

	$main->{input}{username} = $user->{name};

	my $template = $main->{input}{template};
	$template = 'profile' unless defined($template);
	$template =~ s/[^\w\d_.]//g;
	$template =~ s/\./\//g;

	$main->printTemplate($template);
}

sub delete_handler
{
	my($self,$main) = @_;

	$main->{template_vars}{backaddr} = 'javascript:history.back()';

	my $user = $main->loadUser($main->{input}{username});
	$main->fatal_error('unknownusername',{name => $main->{input}{username}}) if (!defined($user));
	$main->fatal_error('deleteuser_nopermission') if ($user->{name} ne $main->{current_user}{name} && (!$main->hasPermission('profile_modify') || $main->{current_user}{tempgroup}<=$user->{group}));
	$main->fatal_error('deleteuser_chatmaster') if ($user->{group}>=10);

	if ($main->isOnline($user->{name}))
	{
		$main->loadOnlineInfo($user->{name},$user);
		$main->kickUser($user,{error_name => 'error_deleted'});
		sleep(1);
	}

	$main->removeUser($user);

	$main->printTemplate('deleted');
}
