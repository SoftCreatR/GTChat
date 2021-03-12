###################################################################
#  GTChat 0.95 Alpha Plugin                                       #
#  Written for release 20020911                                   #
#  Author: Wladimir Palant                                        #
#                                                                 #
#  This plugin provides the template variable $user_information   #
#  with a user's profile. The username is taken from the query    #
#  string (username parameter), if not given the current user is  #
#  taken.                                                         #
###################################################################

package GTChat::Plugins::ProfileLoader::095_01;
use strict;

bless({
	template_var_handlers => {
		'user_information' => \&handler,
	},
});

sub handler
{
	my($self,$main,$var) = @_;
	
	my $user;
	if (exists($main->{input}{nickname}) && $main->{input}{nickname} ne "")
	{
		my $candidates = $main->getPossibleUsernames($main->{input}{nickname});
		
		$main->fatal_error('ambiguousname',{nick => $main->{input}{nickname}}) if ($#$candidates>1);
		$main->fatal_error('unknownname',{nick => $main->{input}{nickname}}) if ($#$candidates<0);
		
		$main->{input}{username} = $candidates->[0];
	}

	if (exists($main->{input}{username}) && $main->{input}{username} ne "")
	{
		$user = $main->loadUser($main->{input}{username});
		$main->fatal_error('unknownusername',{name => $main->{input}{username}}) if (!defined($user));
		
		$user->{online} = ($main->loadOnlineInfo($user->{name},$user) ? 1 : 0);
	}
	else
	{
		$user = $main->{current_user};
		$user->{online} = 1;
	}
	
	$main->{template_vars}{user_information} = $user;
}
