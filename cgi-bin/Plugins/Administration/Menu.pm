###################################################################
#  GTChat 0.95 Alpha Plugin                                       #
#  Written for release 20021225                                   #
#  Author: Wladimir Palant                                        #
#                                                                 #
#  This plugin provides the data for the admin menu.              #
###################################################################

package GTChat::Plugins::Administration::Menu::095_01;
use strict;

return bless({
	template_var_handlers => {
		'admin_menu' => \&handler,
	},
});

sub handler
{
	my($self,$main,$var) = @_;
	
	$main->fatal_error('nopermission') unless $main->hasPermission('admin');

	my $language = $main->{runtime}{language};
	my $menu = $main->{modules}{"$language.admin"};
	
	my %ret = ();
	foreach my $submenu (keys %$menu)
	{
		if (ref($menu->{$submenu}))
		{
			my @entries = ();
			foreach my $entry (@{$menu->{$submenu}})
			{
				if (!exists($entry->{permission}) || $main->hasPermission($entry->{permission}))
				{
					push @entries, $entry;
				}
			}
			$ret{$submenu} = \@entries if $#entries >= 0;
		}
	}
	
	$main->{template_vars}{admin_menu} = \%ret;
}
