###################################################################
#  GTChat GTChat 0.96 Alpha Build 20060923 core file              #
#  Copyright 2001-2006 by Wladimir Palant (http://www.gtchat.de)  #
#  Copyright 2006 by Sascha Heldt (https://www.softcreatr.de)     #
###################################################################

package GT_Chat::Login;
use strict;

bless({
	action_handlers => {
		'login' => \&login_handler,
	},
});

sub login_handler
{
	my($self,$main) = @_;

	$main->{template_vars}{backaddr} = 'javascript:history.back()';

	my %environment;

	my %user = %{$main->{input}};
	delete($user{generator});
	my $password = $user{password};

	eval
	{
		$main->{modules}{'sourcedir::environment_loader.pm'}->loadEnvironment($main,\%user);

		if (!$user{is_username})
		{
			my $name = $main->getUsername($user{name});
			$user{nick}=$user{name};
			if (defined($name))
			{
				$user{name}=$name;
			}
		}

		delete($user{is_username});

		if ($main->loadUser($user{name},\%user))
		{
			if ($user{has_password})
			{
				$main->fatal_error('wrongpassword') if (!$user{has_password}->checkPassword($main,$user{password}));
			}
			else
			{
				if ($user{code} ne "")
				{
					if ($password ne $user{code})
					{
						$main->fatal_error('useauthenticationcode') if ($user{lastlogin} eq "");
						$main->fatal_error('wrongpassword') if ($user{password} ne $main->crypt($password,$user{password}));
					}
				}
				else
				{
					$main->fatal_error('wrongpassword') if ($user{password} ne $main->crypt($password,$user{password}));
				}
			}
		}
		else
		{
			my $generator;

			if (exists($main->{settings}{custom_user_generators}))
			{
				foreach my $module (@{$main->{settings}{custom_user_generators}})
				{
					if ($main->{modules}{$module}->generateUser($main,\%user))
					{
						$generator=$module;
						last;
					}
				}
			}

			if (defined($generator))
			{
				$user{generator}=$generator;
			}
			else
			{
				$main->fatal_error('usernotfound',{name => $user{name}});
			}
		}

		delete($user{has_password});
		delete($user{has_uncrypted_password});

		$user{tempgroup} = $user{group};

		$main->fatal_error('maintenance') if ($main->{settings}{maintenance} && !$main->hasPermission('ignore_maintenance',\%user));

		if (exists($main->{r}))
		{
			$user{browser} = $main->{r}->header_in("User-Agent");
			$user{ip} = $main->{r}->connection->remote_ip;
			$user{forwardedfor} = $main->{r}->header_in("X-Forwarded-For") || $main->{r}->header_in("Client-IP");
		}
		else
		{
			$user{browser} = $ENV{HTTP_USER_AGENT};
			$user{ip} = $ENV{REMOTE_ADDR};
			$user{forwardedfor} = $ENV{HTTP_X_FORWARDED_FOR} || $ENV{HTTP_CLIENT_IP} || $ENV{CLIENT_IP};
		}
		$user{host} = gethostbyaddr(pack("C4",split(/\./,$user{ip})),2);

		$user{browser} = $main->toHTML($user{browser});
		$user{host} = $main->toHTML($user{host});
		$user{ip} = $main->toHTML($user{ip});
		$user{forwardedfor} = $main->toHTML($user{forwardedfor});

		$user{lastlogin} = $main->{runtime}{now};
		$user{code} = "";

		$user{color} = $main->toColor($user{color});
		$user{color} = $main->{settings}{default}{color} if (!defined($user{color}));

		my $room = $main->loadRoom($user{room});
		$room = $main->loadRoom($main->{settings}{default}{room}) if (!defined($room) || !$main->isRoomPermitted($room,\%user));
		$user{room} = $room->{name_lc};

		if (defined($main->{cookie}{cookieid}) && $main->{cookie}{cookieid} ne '')
		{
			my $old_name = $main->getUsernameFromID($main->{cookie}{cookieid});
			if (defined($old_name))
			{
				my $old_user = $main->loadOnlineInfo($old_name);
				if ($old_user)
				{
					$main->kickUser($old_user,{error_name => 'error_second_login'});
					sleep(2);       # sleep some seconds to let the other instance disconnect and remove the cookie
				}
			}
		}

		my $old_user = $main->loadOnlineInfo($user{name});
		$main->kickUser($old_user,{error_name => 'error_second_login'}) if $old_user;

		my $filename = unpack("H*",$user{name});
		if ($user{pull})
		{
			$main->open(local *QUEUE,'>'.$main->translateName("tmpdir::$filename.queue")) || $main->fatal_error('couldnotcreate',{file => $main->translateName("tmpdir::$filename.queue")});
			$main->close(*QUEUE);
		}

		$main->invokeModulesList($main->{settings}{custom_login_listener},'beforeLogin',\%user,$room);

		$main->saveUser(\%user);
		$main->addOnlineInfo(\%user);

		$main->invokeModulesList($main->{settings}{custom_login_listener},'afterLogin',\%user,$room);
	};
	if ($@)
	{
		my $error = $@;
		$main->invokeModulesList($main->{settings}{custom_login_listener},'onLoginError',\%user,$error);

		if (exists($user{generator}) && $user{generator} ne "")
		{
			$main->{modules}{$user{generator}}->cleanUp($main,\%user);
		}

		die $error;
	}

	$main->setCookie("cookieid=$user{id}; expires=Mon, 31-Jan-3000 12:00:00 GMT;");
	$main->redirect("$main->{runtime}{completeurl};id=$user{id};template=chatentrance");
}
