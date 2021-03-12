package GT_Chat::Plugins::LanguageIndependentTemplateEngine::095_01;
use strict;

return bless({});

sub parseTemplate
{
	my($self, $main, $file) = @_;

	my $template = $main->{template_vars}{template_name};
	$template =~ s/\.\w+$//;
	my $texts = $main->{modules}{"$main->{runtime}{language}.texts"}->{$template};

	local $/;
	my $input = <$file>;
	$input =~ s/\r//g;
	$input =~ s/\{TEXT\|(\w+)\}/$texts->{$1}/g; 

	tie local *FILE, __PACKAGE__, \$input;

	return $main->{modules}{'sourcedir::SimpleTemplateEngine.pm'}->parseTemplate($main, \*FILE);
}

sub TIEHANDLE
{
	my ($package, $input) = @_;

	return bless($input);
}

sub READLINE
{
	my $input = shift;

	return $$input;
}
