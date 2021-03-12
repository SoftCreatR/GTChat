###################################################################
#  GTChat GTChat 0.96 Alpha Build 20060923 core file              #
#  Copyright 2001-2006 by Wladimir Palant (http://www.gtchat.de)  #
#  Copyright 2006 by Sascha Heldt (https://www.softcreatr.de)     #
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

	$user->{online} = 1 if $main->loadOnlineInfo($user->{name}, $user);

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

	if (exists($user->{tempgroup}) && $user->{tempgroup} < $user->{group})
	{
		$user->{tempgroup} = $user->{group};
	}
	$user->{tempgroup}=$olduser->{tempgroup} if ($user->{online} && ($user->{name} eq $main->{current_user}{name} || !defined($user->{tempgroup}) || $main->{current_user}{group}<=$user->{tempgroup} || !$main->hasPermission('profile_settempgroup')));

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

	$main->saveUser($user,$olduser->{nick});

	if ($user->{online} && ($olduser->{nick} ne $user->{nick} || $olduser->{tempgroup} ne $user->{tempgroup}))
	{
		$main->saveOnlineInfo($user);
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
	$main->fatal_error('unknownusername',{name => $main->{input}{username}}) unless defined($user);
	$main->fatal_error('deleteuser_nopermission') if ($user->{name} ne $main->{current_user}{name} && (!$main->hasPermission('profile_modify') || $main->{current_user}{tempgroup}<=$user->{group}));
	$main->fatal_error('deleteuser_chatmaster') if $user->{group}>=10;

	$main->removeUser($user);

	$main->printTemplate('deleted');
}
