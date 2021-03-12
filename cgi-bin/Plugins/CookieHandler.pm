###################################################################
#  GTChat 0.95 Alpha Plugin                                       #
#  Written for release 20020911                                   #
#  Author: Wladimir Palant                                        #
#                                                                 #
#  This plugin gives the user the option to save his username     #
#  password in a cookie and restore them at the next login.       #
###################################################################

package GTChat::Plugins::CookieHandler::095_02;
use strict;

return bless({
	action_handlers => {
		removecookie => \&removeCookie,
	},
});

sub getEnvironment
{
	my($self,$main,$environment) = @_;
	
	if (exists($main->{cookie}{$main->{settings}{cookie_name}}) && $main->{cookie}{$main->{settings}{cookie_name}} ne "")
	{
		my ($name,$password,$pull,$room) = split(/\|/,$main->{cookie}{$main->{settings}{cookie_name}},4);

		if (!exists($environment->{has_uncrypted_password}))
		{
			$environment->{name} = $name;
			$environment->{is_username} = 0;
			$environment->{has_password} = $self;
		}

		$environment->{pull} = $pull if ($pull ne "" && $main->{runtime}{action} ne 'login');
		$environment->{room} = $room if ($room ne "" && $main->{runtime}{action} ne 'login');
		$environment->{has_cookie} = 1;
	}
}

sub checkPassword
{
	my($self,$main,$pass) = @_;
	my $ret = 0;
	
	if (exists($main->{cookie}{$main->{settings}{cookie_name}}) && $main->{cookie}{$main->{settings}{cookie_name}} ne "")
	{
		my ($name,$password,$pull,$room) = split(/\|/,$main->{cookie}{$main->{settings}{cookie_name}});
		$ret = 1 if $pass eq $password;
	}
	
	return $ret;
}

sub loginPerformed
{
	my($self,$main,$user,$room) = @_;
	if ($main->{input}{cookie} && $user->{group}>=0)
	{
		$main->setCookie("$main->{settings}{cookie_name}=$user->{nick}|$user->{password}|$user->{pull}|$user->{room}; expires=Mon, 31-Jan-3000 12:00:00 GMT;");
	}
	elsif (exists($main->{cookie}{$main->{settings}{cookie_name}}) && $main->{cookie}{$main->{settings}{cookie_name}} ne "")
	{
		$main->setCookie("$main->{settings}{cookie_name}=; expires=Mon, 31-Jan-3000 12:00:00 GMT;");
	}
}

sub loginAborted
{
	my($self,$main,$user,$error) = @_;

	if (exists($main->{cookie}{$main->{settings}{cookie_name}}) && $main->{cookie}{$main->{settings}{cookie_name}} ne "")
	{
		$main->setCookie("$main->{settings}{cookie_name}=; expires=Mon, 31-Jan-3000 12:00:00 GMT;");
	}
}

sub removeCookie
{
	my($self,$main) = @_;

	if (exists($main->{cookie}{$main->{settings}{cookie_name}}) && $main->{cookie}{$main->{settings}{cookie_name}} ne "")
	{
		$main->setCookie("$main->{settings}{cookie_name}=; expires=Mon, 31-Jan-3000 12:00:00 GMT;");
	}
	
	$main->redirect($main->{runtime}{completeurl});
}
