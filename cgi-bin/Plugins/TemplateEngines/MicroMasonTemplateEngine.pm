###################################################################
#  GTChat 0.95 Alpha Plugin                                       #
#  Written for release 20021120                                   #
#  Author: Wladimir Palant                                        #
#                                                                 #
#  This template engine plugin uses the Perl module               #
#  Text::MicroMason                                               #
###################################################################

package GTChat::Plugins::MicroMasonTemplateEngine::095_01;
use strict;

use Text::MicroMason ();

return bless({});

sub process
{
	my($data, $main, $output) = @_;

	$$output .= $data->(main => $main);
}

sub parseTemplate
{
	my($self, $main, $file) = @_;

	local $/;

	my $input = '<%perl>my $main = $ARGS{main};</%perl>'.<$file>;

	my $sub;
	eval
	{
		$sub = bless(Text::MicroMason::compile($input));
	};
	if ($@)
	{
		die $main->toHTML($@);
	}
	return $sub;
}
