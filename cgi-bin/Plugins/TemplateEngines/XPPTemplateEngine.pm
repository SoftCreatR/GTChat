###################################################################
#  GT-Chat 0.96 Alpha Plugin                                       #
#  Written for release whatever                                   #
#  Author: Wladimir Palant                                        #
#                                                                 #
#  This template engine plugin uses the Perl module Apache::XPP   #
#  (mod_perl only)                                                #
###################################################################

package GT_Chat::Plugins::XPPTemplateEngine::096_01;
use strict;

use Apache::XPP ();

return bless({});

sub  process
{
	my($data, $main, $output) = @_;

	my $content = $data->[0]->returnrun($main);
	$$output .= (ref($content) ? $$content : $content);
}

sub parseTemplate
{
	my($self, $main, $file) = @_;

	local $/;
	my $input = "<?xpp my \$main = shift; ?>\n".<$file>;

	my $template = new Apache::XPP({source => $input});
	eval
	{
		$template->parse;
	};
	die $main->toHTML($@)."\n" if $@;
	
	return bless([$template]);
}
