###################################################################
#  GT-Chat 0.96 Alpha Plugin                                       #
#  Written for release whatever                                   #
#  Author: Wladimir Palant                                        #
#                                                                 #
#  This template engine plugin uses the Perl module HTML::Mason   #
###################################################################

package GT_Chat::Plugins::MasonTemplateEngine::096_01;
use strict;

use HTML::Mason::Interp ();
use Cwd ();

return bless({});

sub process
{
	my($data, $main, $output) = @_;

	$data->[0]->out_method($output);
	$data->[0]->exec($data->[1], main => $main);
}

sub parseTemplate
{
	my($self, $main, $file) = @_;

	$self->{m} = new HTML::Mason::Interp(
			data_dir => Cwd::abs_path($main->translateName('tmpdir::')),
			comp_root => Cwd::abs_path($main->translateName('templatedir::')),
		) unless exists($self->{m});

	local $/;

	my $input = '<%args>$main</%args>'.<$file>;

	my $comp = $self->{m}->make_component(script => $input, script_name => $main->{template_vars}{template_name});
	die $main->toHTML($@)." in template $main->{template_vars}{template_name}.\n" if $@;
	return bless([$self->{m}, $comp]);
}
