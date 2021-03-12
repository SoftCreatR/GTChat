###################################################################
#  GTChat 0.95 Alpha Plugin                                       #
#  Written for release 20021101                                   #
#  Author: Wladimir Palant                                        #
#                                                                 #
#  This plugin takes the username from authentication at the      #
#  server. Usually the server's authentication rules are          #
#  described in the file .htaccess                                #
###################################################################

package GTChat::Plugins::BasicAuth::095_01;
use strict;

return bless({});

sub getEnvironment
{
	my($self,$main,$environment) = @_;
	
	if (defined($main->{runtime}{remote_user}) && $main->{runtime}{remote_user} ne '')
	{
		$environment->{name} = $main->{runtime}{remote_user};
		$environment->{is_username} = 1;
		$environment->{has_password} = $self;
		$environment->{has_uncrypted_password} = $self;
	}
}

sub checkPassword
{
	return 1;
}

sub getPassword
{
	return "";
}
