###################################################################
#  GT-Chat 0.96 Alpha Plugin                                       #
#  Written for release whatever                                   #
#  Author: Wladimir Palant                                        #
#                                                                 #
#  This template engine plugin uses the Perl module HTML::Embperl #
###################################################################

package GT_Chat::Plugins::EmbperlTemplateEngine::096_01;
use strict;

BEGIN
{
   $ENV{EMBPERL_SESSION_CLASSES} = "";
}

use HTML::Embperl;

return bless({});

sub process
{
	my($data, $main, $output) = @_;

	my $optRawInput = 16;
	my $optDisableChdir = 128;
	my $optDisableFormData = 256;
	my $optAllowZeroFilesize = 131072;
	my $optDisableHtmlScan = 512;

	HTML::Embperl::Execute({
		inputfile => $main->{template_vars}{template_name},
		input => $data->[0],
		escmode => 0,
		mtime => $data->[1],
		output => $output,
		param => [$main],
		options => $optRawInput | $optDisableChdir | $optDisableFormData | $optAllowZeroFilesize | $optDisableHtmlScan,
	});
}

sub parseTemplate
{
	my($self, $main, $file) = @_;

	local $/;

	my $input = '[! $main = $param[0] !]'.<$file>;

	return bless([\$input,time]);
}
