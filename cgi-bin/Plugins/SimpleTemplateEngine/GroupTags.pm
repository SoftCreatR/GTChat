###################################################################
#  GTChat 0.95 Alpha Plugin                                       #
#  Written for release 20021101                                   #
#  Author: Wladimir Palant                                        #
#                                                                 #
#  This plugin provides the template commands for handling with   #
#  group tags and names.                                          #
###################################################################

package GTChat::Plugins::GroupTags::095_01;
use strict;

return bless({
	template_block_handlers => {
		IF_HAS_GROUPTAG => \&block_handler,
		IF_HAS_GROUPNAME => \&block_handler,
	},
	block_switch_tags => {
		IF_HAS_GROUPTAG => 'ELSE',
		IF_HAS_GROUPNAME => 'ELSE',
	},
	block_end_tags => {
		IF_HAS_GROUPTAG => 'ENDIF',
		IF_HAS_GROUPNAME => 'ENDIF',
	},
	template_command_handlers => {
		GROUPTAG => \&command_handler,
		GROUPNAME => \&command_handler,
	},
});

sub command_handler
{
	my($self,$main,$params,$output) = @_;
	
	my($tag,$var) = @$params;
	$main->fatal_error('tag_notenoughparameters',{template => $main->{template_vars}{template_name}, line => $main->{template_vars}{template_line}, tag => ${$params}[0]}) if (!defined($var));
	$var = $main->getEx($1) if ($var =~ /^\$(.+)/);

	if ($tag eq 'GROUPTAG')
	{
		$var = $main->{current_language}{group_tags}[$var+2];
	}
	else
	{
		$var = $main->{current_language}{group_names}[$var+2];
	}

	$$output .= $var if defined($var);
}

sub block_handler
{
	my($self,$main,$params,$content,$content2,$output) = @_;

	my($tag,$var) = @$params;
	$main->fatal_error('tag_notenoughparameters',{template => $main->{template_vars}{template_name}, line => $main->{template_vars}{template_line}, tag => ${$params}[0]}) if (!defined($var));

	$var = $main->getEx($1) if ($var =~ /^\$(.+)/);
	if ($tag eq 'IF_HAS_GROUPTAG')
	{
		$var = $main->{current_language}{group_tags}[$var+2];
	}
	else
	{
		$var = $main->{current_language}{group_names}[$var+2];
	}
	
	if (defined($var) && $var ne '')
	{
		$content->process($main,$output);
	}
	elsif (defined($content2))
	{
		$content2->process($main,$output);
	}
}
