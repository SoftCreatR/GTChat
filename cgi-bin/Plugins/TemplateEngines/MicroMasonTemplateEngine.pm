###################################################################
#  GT-Chat 0.96 Alpha Plugin                                       #
#  Written for release whatever                                   #
#  Author: Wladimir Palant                                        #
#                                                                 #
#  This template engine plugin uses the Perl module               #
#  Text::MicroMason                                               #
###################################################################

package GT_Chat::Plugins::MicroMasonTemplateEngine::096_01;
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
