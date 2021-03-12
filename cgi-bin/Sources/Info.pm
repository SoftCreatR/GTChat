###################################################################
#  GTChat GTChat 0.96 Alpha Build 20060923 core file              #
#  Copyright 2001-2006 by Wladimir Palant (http://www.gtchat.de)  #
#  Copyright 2006 by Sascha Heldt (https://www.softcreatr.de)     #
###################################################################

package GT_Chat::Info;
use strict;

bless({
	action_handlers => {
		'info' => \&info_handler,
	},
});

sub info_handler
{
	my($self,$main) = @_;

	$main->{template_vars}{backaddr} = $main->{input}{backaddr} if exists($main->{input}{backaddr});

	my $template = $main->{input}{template};
	$template = 'login' if (!defined($template));
	$template =~ s/[^\w\d_.]//g;
	$template =~ s/\./\//g;

	$main->printTemplate($template);
}
