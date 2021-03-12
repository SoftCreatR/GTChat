###################################################################
#  GTChat 0.95 Alpha Plugin                                       #
#  Written for release 20020911                                   #
#  Author: Wladimir Palant                                        #
#                                                                 #
#  This plugin turns *text* and _text_ in the chat to formatted   #
#  text.                                                          #
###################################################################

package GTChat::Plugins::TextFilters::Formatting::095_02;
use strict;

return bless({
	text_filters => {
		formatting => \&formatting_handler,
		links => \&links_handler,
		smileys => \&smileys_handler,
	},
});

sub removeLinks
{
	my ($links,$text) = @_;
	
	push @$links,$text;
	return "&#mark$#$links;";
}

sub formatting_handler
{
	my($self,$main,$text) = @_;
	
	my @links = ('*','_');
	$$text =~ s/(<a [^>]+>[^<]*<\/a>)/removeLinks(\@links,$1)/ige;  # save all links and remove them
	
	$$text =~ s/\*\*/&#mark0;/g;
	$$text =~ s/\*([^\*]+)\*/<i>$1<\/i>/g;

	$$text =~ s/__/&#mark1;/g;
	$$text =~ s/_([^_]+)_/<b>$1<\/b>/g;

	$$text =~ s/&#mark(\d+);/$links[$1]/g;       # put the links back
}

sub derefer
{
	my ($main,$link) = @_;

	$link =~ s/\W/"%".unpack("H2",$&)/eg;
	
	return "$main->{settings}{urls}{chaturl}?template=dereferer&language=$main->{runtime}{language}&url=$link";
}

sub links_handler
{
	my($self,$main,$text) = @_;
	
	$$text =~ s/(^|\s)((?:https?|ftp):\/\/[^<>\*\s\n\"\]\[\(\)]+[^<>\*\s\n\"\]\[\(\),.?!:-])/"$1<a href=\"".derefer($main,$2)."\" target=\"_blank\" class=\"stdlink\" onfocus=\"if (window.resetFocus) resetFocus()\">$2<\/a>"/ige;
	$$text =~ s/(^|\s)(www\.[^<>\*\s\n\]\[\(\)]+[^<>\*\s\n\"\]\[\(\),.?!:-])/"$1<a href=\"".derefer($main,"http:\/\/$2")."\" target=\"_blank\" class=\"stdlink\" onfocus=\"if (window.resetFocus) resetFocus()\">$2<\/a>"/ige;
	$$text =~ s/(^|\s)([\w\-_.]+@[\w\-_.]+\.[a-z]{2,})/$1<a href=\"mailto:$2\" class=\"stdlink\" onfocus=\"if (window.resetFocus) resetFocus()\"\>$2<\/a>/ig;
}

sub smileys_handler
{
	my($self,$main,$text) = @_;
	
	return if $main->{current_user}{nosmileys};
	
	if (!exists($self->{smileys}))
	{
		$self->{smileys} = {};
		foreach my $smiley (@{$main->{settings}{smileys}})
		{
			my $image = undef;
			foreach (@$smiley)
			{
				if (!defined($image))
				{
					$image = $_;
		
					my ($width,$height);
					($width,$height) = @{$main->{settings}{images}{$image}} if defined($main->{settings}{images}{$image});
					$width = (defined($width) ? " width=$width": "");
					$height = (defined($height) ? " height=$height": "");
		
					my $alt = $main->toHTML($smiley->[1]);
					$image = "<img src=\"$main->{settings}{urls}{imagesurl}$image.gif\" border=0$width$height alt=\"$alt\">";
				}
				elsif ($_ ne '/hidden/')
				{
					$self->{smileys}{$main->toHTML($_)} = $image;
				}
			}
		}
	}
	
	$$text =~ s/([^\s<>]+)/($self->{smileys}{$1}||$1)/ge;
}
