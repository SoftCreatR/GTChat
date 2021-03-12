###################################################################
#  GTChat 0.95 Alpha Plugin                                       #
#  Written for release 20021101                                   #
#  Author: Wladimir Palant                                        #
#                                                                 #
#  This plugin provides the {INCLUDE} template command to include #
#  another template into the current one.                         #
###################################################################

package GTChat::Plugins::IncludeTags::095_01;
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
