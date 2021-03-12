###################################################################
#  GT-Chat 0.95 Alpha Plugin                                       #
#  Written for release 20021225                                   #
#  Author: Wladimir Palant                                        #
#                                                                 #
#  This plugin receives the changed chat news.                    #
###################################################################

package GT_Chat::Plugins::Administration::News::095_01;
use strict;

return bless({
	action_handlers => {
		'admin_news' => \&handler,
	},
});

sub handler
{
	my($self,$main) = @_;
	
	$main->fatal_error('nopermission') unless $main->hasPermission('admin_news');

	my @news = ();
	for (my $i=0;exists($main->{input}{"message$i"});$i++)
	{
		my $author = $main->{input}{"author$i"};
		$author = $main->{current_user}{nick} unless defined($author) && $author ne "";
		$author =~ s/[\n\r\|]//g;

		my $date = $main->{input}{"date$i"} || $main->{runtime}{now};
		$date = int($date);

		my $message = $main->toHTML($main->{input}{"message$i"});
		$message =~ s/\r//g;
		push @news, join('|', $message, $author, $date) . "\n";
	}
	
	if ($main->open(local* FILE, '>'.$main->translateName('vardir::news.txt')))
	{
		print FILE @news;
		$main->close(*FILE);
	}
	
	$main->printTemplate('admin/menu_back');
}
