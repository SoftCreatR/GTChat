###################################################################
#  GT-Chat 0.96 Alpha Plugin                                       #
#  Written for release whatever                                   #
#  Author: Wladimir Palant                                        #
#                                                                 #
#  This plugin provides the template block {DOFILTER}...{ENDDO}   #
#  to filter the text with custom filters (see the                #
#  custom_output_filter variable in Settings.dat).                #
###################################################################

package GT_Chat::Plugins::FilterTags::096_01;
use strict;

return bless({
	template_block_handlers => {
		DOFILTER => \&handler,
	},
	block_end_tags => {
		DOFILTER => 'ENDDO',
	},
});

sub handler
{
	my($self,$main,$params,$content,$content2,$output) = @_;

	my $text = "";
	$content->process($main,\$text);
	
	my ($tag,@filters) = @$params;
	$main->filterText(\$text, @filters);

	$$output .= $text;
}

sub filterText
{
	my($main,$text,@filters) = @_;

	foreach my $filter (@filters)
	{
		if (exists($main->{settings}{custom_text_filters}{$filter}))
		{
			my $modulename = $main->{settings}{custom_text_filters}{$filter};
			my $module = $main->{modules}{$modulename};
			if (exists($module->{text_filters}{$filter}) && ref($module->{text_filters}{$filter}))
			{
				$module->{text_filters}{$filter}->($module, $main, $text);
			}
		}
	}
}
