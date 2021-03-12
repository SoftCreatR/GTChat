###################################################################
#  GTChat GTChat 0.96 Alpha Build 20060923 core file              #
#  Copyright 2001-2006 by Wladimir Palant (http://www.gtchat.de)  #
#  Copyright 2006 by Sascha Heldt (https://www.softcreatr.de)     #
###################################################################

package GT_Chat::environment_loader;
use strict;

bless({
	template_var_handlers => {
		environment => \&handler,
	},
});

sub handler
{
	my($self,$main,$var) = @_;

	my %environment = %{$main->{settings}{default}};
	$environment{pull}=$main->{input}{pullmode} if exists($main->{input}{pullmode});
	$environment{pull} = $environment{pull}?1:0;
	$environment{room} = $main->{input}{room} if exists($main->{input}{room});
	$environment{room} = $main->lowercase($environment{room});

	if (exists($main->{input}{username}))
	{
		$environment{is_username} = 1;
		$environment{name} = $main->{input}{username};
	}
	elsif (exists($main->{input}{nickname}))
	{
		$environment{is_username} = 0;
		$environment{name} = $main->{input}{nickname};
	}

	$self->loadEnvironment($main,\%environment);

	$main->{template_vars}{environment} = \%environment;
}

sub loadEnvironment
{
	my($self,$main,$environment) = @_;

	if (exists($main->{settings}{custom_environment_handlers}))
	{
		for (my $i=$#{$main->{settings}{custom_environment_handlers}};$i>=0;$i--)
		{
			my $handler = $main->{modules}{$main->{settings}{custom_environment_handlers}[$i]};
			$handler->getEnvironment($main,$environment);
		}
	}
}
