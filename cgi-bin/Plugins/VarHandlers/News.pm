###################################################################
#  GT-Chat 0.96 Alpha Plugin                                       #
#  Written for release whatever                                   #
#  Author: Wladimir Palant                                        #
#                                                                 #
#  This plugin provides the template variables that are necessary #
#  for the chat news. The information is taken from the file      #
#  Variables/news.txt.                                            #
###################################################################

package GT_Chat::Plugins::News::096_01;
use strict;
use vars qw(@ISA);

@ISA = ('GT_Chat::Enum');

return bless({
	template_var_handlers => {
		'news.messagenum' => \&handler,
		'news.message' => \&handler,
		'news.author' => \&handler,
		'news.date' => \&handler,

		'news.messages' => \&handler,
		'news.messagecount' => \&handler,
	},
});

sub handler
{
	my($self,$main,$var) = @_;

	$main->open(local *NEWS, $main->translateName('vardir::news.txt')) || return;
	my @messages = <NEWS>;
	$main->close(*NEWS);

	return if ($#messages < 0);

	my $num = int(rand($#messages+1));
	$messages[$num] =~ s/[\n\r]//g;
	my ($message,$author,$date) = split(/\|/,$messages[$num]);
	
	my %ret = (
		messagenum => $num,
		message => $message,
		author => $author,
		date => $date,
		messagecount => $#messages+1,
	);

	if ($var eq 'news.messages')
	{
		my $enum = $main->{modules}{'sourcedir::Enum.pm'};
		$ret{messages} = new($main,\@messages);
	}

	$main->{template_vars}{news} = \%ret;
}

sub new
{
	my($main,$list) = @_;

	return bless({
		main => $main,
		list => $list,
		index => -1,
		opened => 0,
	});
}

sub open
{
	my $self=shift;

	$self->close() if $self->{opened};

	$self->{index} = -1;
	$self->{opened} = 1;
}

sub hasNext
{
	my $self=shift;
	return ($self->{opened} && $self->{index} < $#{$self->{list}});
}

sub next
{
	my $self=shift;
	
	return undef unless $self->{opened} && $self->{index} < $#{$self->{list}};

	$self->{index}++;
	$self->{list}[$self->{index}] =~ s/[\n\r]//g;
	
	my %ret = ();
	@ret{'message', 'author', 'date'} = split(/\|/,$self->{list}[$self->{index}]);
	return \%ret;
}

sub close
{
	my $self=shift;
	
	$self->{opened} = 0;
}
