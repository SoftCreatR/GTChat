###################################################################
#  GT-Chat 0.96 Alpha Plugin                                       #
#  Written for release whatever                                   #
#  Author: Wladimir Palant                                        #
#                                                                 #
#  This plugin provides the {INCLUDE} template command to include #
#  another template into the current one.                         #
###################################################################

package GT_Chat::Plugins::IncludeTags::096_01;
use strict;

return bless({
	template_command_handlers => {
		INCLUDE => \&include_handler,
	},
});

sub include_handler
{
	my($self,$main,$params,$output) = @_;
	
	my($tag,$template) = @$params;
	$template = $main->getEx($1) if ($template =~ /^\$(.+)/);

	$main->parseTemplate($template)->process($main,$output);
}
