###################################################################
#  GTChat 0.95 Alpha Plugin                                       #
#  Written for release 20021101                                   #
#  Author: Wladimir Palant                                        #
#                                                                 #
#  This plugin generates a guest account "on the fly" if the      #
#  user didn't enter a password on login                          #
###################################################################

package GTChat::Plugins::GuestLogin::095_02;
use strict;

return bless({});

sub generateUser
{
	my ($self,$main,$user) = @_;

	return undef if ($user->{password} ne "");

	# Take default values for the user's account
	foreach (keys %{$main->{settings}{default}})
	{
		$user->{$_} = $main->{settings}{default}{$_} unless exists($user->{$_});
	}
	
	srand;
	while ($user->{name} eq "" || $main->existsUser($user->{name}) || $main->getUsername($user->{name}))
	{
		$user->{name}=$main->{current_language}{group_names}[1] . int(rand(1000));
	}
	$user->{nick}=$user->{name};
	$user->{password}="";
	$user->{group}=-1;
	$user->{registration}=$main->{runtime}{now};

	$main->invokeModulesList($main->{settings}{custom_profile_checker},'checkProfile',$user);

	$main->addUser($user);
	
	return $main->loadUser($user->{name},$user);
}

sub cleanUp
{
	my ($self,$main,$user) = @_;
	
	$main->removeUser($user);
}
