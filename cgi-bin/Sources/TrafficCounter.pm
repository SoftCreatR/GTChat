###################################################################
#  GTChat GTChat 0.96 Alpha Build 20060923 core file              #
#  Copyright 2001-2006 by Wladimir Palant (http://www.gtchat.de)  #
#  Copyright 2006 by Sascha Heldt (https://www.softcreatr.de)     #
###################################################################

package GT_Chat::TrafficCounter;

bless({});

sub init
{
	open(local *ORIG, '>-');
	my $oldhandle = select(ORIG);
	$| = 1;
	select($oldhandle);
	tie *$oldhandle, __PACKAGE__, *ORIG;
}

sub TIEHANDLE
{
	my($class,$handle) = @_;
	return bless({count => 0, handle => $handle});
}

sub BINMODE
{
	my $self = shift;
	my $handle = $self->{handle};
	binmode($handle);
}

sub PRINT
{
	my $self = shift;
	foreach (@_)
	{
		$self->{count} += length;
	}
	my $handle = $self->{handle};
	print $handle @_;
}

sub PRINTF
{
	my $self = shift;
	my $format = shift;
	$self->PRINT(sprintf $format,@_);
}

sub CLOSE
{
	my $self = shift;
	my $handle = $self->{handle};
	close($handle);
}
