###################################################################
#  GTChat GTChat 0.95 Alpha Build 20040120 core file              #
#  Copyright 2001-2006 by Wladimir Palant (http://www.gtchat.de)  #
#  Copyright 2006 by Sascha Heldt (https://www.gt-chat.de)        #
###################################################################

package GT_Chat::Register;
use strict;

bless({
	action_handlers => {
		'register' => \&register_handler,
	},
});

sub register_handler
{
	my($self,$main) = @_;

	$main->{template_vars}{backaddr} = 'javascript:history.back()';

	my %environment;

	if (exists($main->{input}{name}))
	{
		$environment{is_username} = 1;
		$environment{name} = $main->{input}{name};
	}
	elsif (exists($main->{input}{nick}))
	{
		$environment{is_username} = 0;
		$environment{name} = $main->{input}{nick};
	}

	my %user = %{$main->{input}};
	$main->{modules}{'sourcedir::environment_loader.pm'}->loadEnvironment($main,\%environment);

	if ($environment{has_uncrypted_password})
	{

		if ($environment{is_username})
		{
			$user{name}=$environment{name};
		}
		else
		{
			$user{nick}=$environment{name};
		}
	}

	if ($user{name} ne "" && $user{nick} eq "")
	{
		$user{nick}=$user{name};
	}
	elsif ($user{nick} ne "" && $user{name} eq "" && !$main->{settings}{default}{is_username})
	{
		srand;
		for (my $i=0;$i<100;$i++)
		{
			$user{name}=substr($main->crypt(rand(),$main->{settings}{pwseed}),2,8);
			last if (!$main->existsUser($user{name}));
		}
	}

	if ($environment{has_uncrypted_password})
	{
		$user{password} = $main->crypt($environment{has_uncrypted_password}->getPassword($main),$main->{settings}{pwseed});
	}
	else
	{
		$user{password} =~ s/^\s*(.*?)\s*$/$1/;
		$user{password2} =~ s/^\s*(.*?)\s*$/$1/;

		$main->fatal_error('passwordsnotequal') if ($user{password} ne $user{password2});
		$main->fatal_error('nopasswordgiven') if ($user{password} eq "");

		$user{password} = $main->crypt($user{password},$main->{settings}{pwseed});
	}
	delete($user{password2});

	$user{group}=0;

	$user{email} =~ s/[\s"&#|<>]//g;

	$user{color}=$main->toColor($user{color});
	$user{registration}=$main->{runtime}{now};

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

	delete($user{lastlogin});

	delete($user{permissions});

	$main->invokeModulesList($main->{settings}{custom_profile_checker},'checkProfile',\%user);

	$main->fatal_error('usernameexists',{name => $user{name}}) if ($main->existsUser($user{name}));
	$main->fatal_error('nicknameexists',{nick => $user{nick}}) if ($main->getUsername($user{nick}));

	$main->addUser(\%user);

	my $name = ($main->{settings}{default}{is_username} ? $user{name} : $user{nick});
	$name =~ s/\W/"%".unpack("H2",$&)/eg;
	$name = ($main->{settings}{default}{is_username} ? 'username=' : 'nickname=') . $name;

	$main->redirect($main->{runtime}{completeurl} . '&template=register_success&' . $name);
}
