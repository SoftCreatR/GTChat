###################################################################
#  GTChat 0.95 Alpha Plugin                                       #
#  Written for release 20021101                                   #
#  Author: Wladimir Palant                                        #
#                                                                 #
#  This plugin provides the text filters escape_js, escape_html   #
#  and urlencode                                                  #
###################################################################

package GTChat::Plugins::TextFilters::Converters::095_02;
use strict;

return bless({
	text_filters => {
		escape_js => \&js_handler,
		escape_html => \&html_handler,
		urlencode => \&encode_handler,
	},
});

sub js_handler
{
	my($self,$main,$text) = @_;

	$$text =~ s/\r//g;
	$$text =~ s/[\\']/\\$&/g;
	$$text =~ s/\n/\\n/g;
	$$text =~ s/\t/\\t/g;
	$$text =~ s/<\/script/<\/'+'script/g;
}

sub html_handler
{
	my($self,$main,$text) = @_;

	$$text =~ $main->toHTML($$text);    
}

sub encode_handler
{
	my($self,$main,$text) = @_;

	$$text =~ s/\W/"%".unpack("H2",$&)/eg;
}
