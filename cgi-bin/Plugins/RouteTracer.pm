###################################################################
#  GT-Chat 0.96 Alpha Plugin                                       #
#  Written for release whatever                                   #
#  Author: Wladimir Palant                                        #
#                                                                 #
#  This plugin provides the template variables $traceroute and    #
#  $traceroute_finished. It traces the IP address given by the    #
#  ip query string parameter.                                     #
###################################################################

package GT_Chat::Plugins::RouteTracer::096_01;
use strict;

bless({
	action_handlers => {
		'traceroute' => \&handler,
	},
});

sub handler
{
	my($self,$main) = @_;
	
	$main->fatal_error('nopermission') unless $main->hasPermission('profile_traceroute');

	$main->{template_vars}{backaddr} = 'javascript:history.back()';

	my $user = $main->loadUser($main->{input}{name});
	$main->fatal_error('usernotfound', {name => $main->{input}{name}}) unless defined($user);

	$main->{template_vars}{user} = $user;
	$main->printTemplate('traceroute_top');

	my $ip = $user->{ip};
	$ip =~ s/[^\w\-\.]//g;

	if (open(local *TRACEROUTE, "$main->{settings}{tracerouteprog} $ip |"))
	{
		while (sysread(TRACEROUTE, my $input, 1024))
		{
			print $main->toHTML($input);
		}
		close(TRACEROUTE);
	}

	my $output = "\n";
	$main->parseTemplate('traceroute_bottom')->process($main,\$output);
	print $output;
}
