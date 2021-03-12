###################################################################
#  GT-Chat 0.96 Alpha Plugin                                       #
#  Written for release whatever                                   #
#  Author: Wladimir Palant                                        #
#                                                                 #
#  This plugin turns *text* and _text_ in the chat to formatted   #
#  text.                                                          #
###################################################################

package GT_Chat::Plugins::TextFilters::Formatting::096_01;
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
	$$text =~ s/\*([^\*]+)\*/<em>$1<\/em>/g;

	$$text =~ s/__/&#mark1;/g;
	$$text =~ s/_([^_]+)_/<strong>$1<\/strong>/g;

	$$text =~ s/&#mark(\d+);/$links[$1]/g;       # put the links back
}

sub derefer
{
	my ($main,$link) = @_;

	$link =~ s/\W/"%".unpack("H2",$&)/eg;
	
	return "$main->{settings}{urls}{chaturl}?template=dereferer;language=$main->{runtime}{language};url=$link";
}

sub links_handler
{
	my($self,$main,$text) = @_;
	
	$$text =~ s/(^|\s)((?:https?|ftp):\/\/[^<>\*\s\n\"\]\[\(\)]+[^<>\*\s\n\"\]\[\(\),.?!:-])/"$1<a href=\"".derefer($main,$2)."\" target=\"_blank\">$2<\/a>"/ige;
	$$text =~ s/(^|\s)(www\.[^<>\*\s\n\]\[\(\)]+[^<>\*\s\n\"\]\[\(\),.?!:-])/"$1<a href=\"".derefer($main,"http:\/\/$2")."\" target=\"_blank\">$2<\/a>"/ige;
	$$text =~ s/(^|\s)([\w\-_.]+@[\w\-_.]+\.[a-z]{2,})/$1<a href=\"mailto:$2\"\>$2<\/a>/ig;
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
		
					my $title = $main->toHTML($smiley->[1]);
					$image = $main->getImageText($image, "title=\"$title\"");
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
