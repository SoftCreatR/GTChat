###################################################################
#  GTChat 0.95 Alpha Plugin                                       #
#  Written for release 20021120                                   #
#  Author: Wladimir Palant                                        #
#                                                                 #
#  This template engine plugin uses the Perl module HTML::Embperl #
###################################################################

package GTChat::Plugins::EmbperlTemplateEngine::095_01;
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
