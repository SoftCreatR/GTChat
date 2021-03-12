###################################################################
#  GT-Chat 0.96 Alpha Plugin                                       #
#  Written for release whatever                                   #
#  Author: Wladimir Palant                                        #
#                                                                 #
#  This template engine plugin uses the Perl module Template      #
#  (part of the Template Toolkit)                                 #
###################################################################

package GT_Chat::Plugins::ToolkitTemplateEngine::096_01;
use strict;

use Template::Context ();

return bless({
	context => new Template::Context({
			EVAL_PERL => 1,
	}),
});

sub process
{
	my($data, $main, $output) = @_;

	eval
	{
		$$output .= $data->[0]->process($data->[1], {main => $main});
	};
	if ($@)
	{
		die "Failed to process template $main->{template_vars}{template_name}: ".$main->toHTML(ref($@) ? $@->as_string : $@)."\n";
	}    
}

sub parseTemplate
{
	my($self, $main, $file) = @_;

	local $/;
	my $input = <$file>;

	my $template;
	eval
	{
		$template = $self->{context}->template(\$input);
	};
	if ($@)
	{
		die "Failed to fetch template $main->{template_vars}{template_name}: ".$main->toHTML($@);
	}
	
	return bless([$self->{context},$template]);
}
