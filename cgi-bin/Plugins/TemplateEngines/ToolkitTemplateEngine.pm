###################################################################
#  GTChat 0.95 Alpha Plugin                                       #
#  Written for release 20021120                                   #
#  Author: Wladimir Palant                                        #
#                                                                 #
#  This template engine plugin uses the Perl module Template      #
#  (part of the Template Toolkit)                                 #
###################################################################

package GTChat::Plugins::ToolkitTemplateEngine::095_01;
use strict;

use Template::Context ();

return bless({});

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

	my $context = new Template::Context({
			EVAL_PERL => 1,
		});
		
	local $/;
	my $input = <$file>;

	my $template;
	eval
	{
		$template = $context->template(\$input);
	};
	if ($@)
	{
		die "Failed to fetch template $main->{template_vars}{template_name}: ".$main->toHTML($@);
	}
	
	return bless([$context,$template]);
}
