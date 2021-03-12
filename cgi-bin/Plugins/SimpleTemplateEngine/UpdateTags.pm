###################################################################
#  GTChat 0.95 Alpha Plugin                                       #
#  Written for release 20021101                                   #
#  Author: Wladimir Palant                                        #
#                                                                 #
#  This plugin provides the possibility to reload the template    #
#  variable $current_user.                                        #
###################################################################

package GTChat::Plugins::UpdateTags::095_01;
use strict;

return bless({
	template_command_handlers => {
		UPDATE_ONLINEINFO => \&update_handler,
		UPDATE_MEMBERINFO => \&update_handler,
	},
});

sub update_handler
{
	my($self,$main,$params,$output) = @_;
	
	if (!$main->{current_user}{pull})
	{
		my($tag) = @$params;

		if ($tag eq "UPDATE_ONLINEINFO")
		{
			$main->loadOnlineInfo($main->{current_user}{name},$main->{current_user});
		}
		else
		{
			$main->loadUser($main->{current_user}{name},$main->{current_user});
			if ($main->{current_user}{style})
			{
				$main->{runtime}{style} = $main->{current_user}{style};
			}
			else
			{
				$main->{runtime}{style} = $main->{settings}{default}{style};
			}
		}
	}
}
