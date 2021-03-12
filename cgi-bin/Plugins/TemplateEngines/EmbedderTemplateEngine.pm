###################################################################
#  GTChat 0.95 Alpha Plugin                                       #
#  Written for release 20021120                                   #
#  Author: Wladimir Palant                                        #
#                                                                 #
#  This plugin is an alternative template engine, based on        #
#  Embedder.pm by Dmitrij Koterov (http://www.dklab.ru).          #
###################################################################

package GTChat::Plugins::EmbedderTemplateEngine::095_01;
use strict;

return bless({});

sub process
{
	my($data, $main, $output) = @_;

	eval
	{
		$data->($main, $output);
	};
	die "Failed to process template $main->{template_vars}{template_name}: ".$main->toHTML($@)."\n" if $@;
}

sub escape
{
	my $string = shift;
	$string =~ s/[\\']/\\$&/g;
	return $string;
}

sub parseTemplate
{
	my($self, $main, $file) = @_;

	local $/;
	my $input = <$file>;

	$input = "sub {my(\$main,\$output) = \@_;\n-]$input\[-}";
	$input =~ s/\[\+(.*?)\+\]/[-\$\$output .= $1;-]/g;
	$input =~ s/\-\](\n?)(.*?)\[\-/";$1\$\$output .= '".escape($2)."';"/sge;
	$input =~ s/\$\$output .= '';//sg;

	my $sub = eval($input);
	die "Failed to fetch template $main->{template_vars}{template_name}: ".$main->toHTML($@)."\n" if $@;
	return bless($sub);
}
