###################################################################
#  GTChat 0.95 Alpha Plugin                                       #
#  Written for release 20021101                                   #
#  Author: Wladimir Palant                                        #
#                                                                 #
#  This plugin checks for a proxy that does not allow server      #
#  push and activates the secure mode checkbox in the login       #
#  page accordingly.                                              #
###################################################################

package GTChat::Plugins::ProxyCheck::095_01;
use strict;

return bless({
	action_handlers => {
		'proxycheck' => \&handler,
	},
	template_command_handlers => {
		'PROXYCHECK' => \&redirector,
	},
});

sub handler
{
	my($self,$main) = @_;
	
	$main->printTemplate('proxycheck_top');
	sleep(1);

	my $output = '';
	$main->parseTemplate('proxycheck_bottom')->process($main,\$output);
	print $output;
}

sub getEnvironment
{
	my($self,$main,$environment) = @_;
	
	$environment->{pull} = 1 if $main->{input}{proxy};
}

sub redirector
{
	my($self,$main,$params,$output) = @_;

	proxyCheck($main);    
}

sub proxyCheck
{
	my $main = shift;

	if (!exists($main->{input}{proxy}))
	{
		$main->redirect($main->{runtime}{completeurl}.'&action=proxycheck');
		$main->exit;
	}
}
