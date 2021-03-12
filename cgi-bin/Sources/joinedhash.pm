###################################################################
#  GTChat GTChat 0.95 Alpha Build 20040120 core file              #
#  Copyright 2001-2006 by Wladimir Palant (http://www.gtchat.de)  #
#  Copyright 2006 by Sascha Heldt (https://www.gt-chat.de)        #
###################################################################

package GT_Chat::joinedhash;
use strict;

bless({});

sub new
{
	my($self,$hash1,$hash2) = @_;

	my %ret;
	tie %ret, __PACKAGE__, $hash1, $hash2;
	return \%ret;
}

sub TIEHASH
{
	my($class,$hash1,$hash2) = @_;

	return bless([$hash1, $hash2]);
}

sub EXISTS
{
	my($self,$key) = @_;

	return exists($self->[0]{$key}) || exists($self->[1]{$key});
}

sub FETCH
{
	my($self,$key) = @_;

	my $ret=$self->[0]{$key};
	if (defined($ret))
	{
		if (UNIVERSAL::isa($ret,'HASH'))
		{
			my $ret2=$self->[1]{$key};
			$ret = new($self,$ret,$ret2) if (UNIVERSAL::isa($ret2,'HASH'))
		}
		return $ret;
	}
	else
	{
		return $self->[1]{$key};
	}
}

sub FIRSTKEY
{
	my $self = shift;

	foreach (keys %{$self->[0]})
	{
		return $_;
	}

	foreach (keys %{$self->[1]})
	{
		return $_;
	}

	return undef;
}

sub NEXTKEY
{
	my($self,$lastkey) = @_;

	my $start = 0;

	foreach my $key (keys %{$self->[0]})
	{
		return $key if $start;
		$start = 1 if $key eq $lastkey;
	}

	foreach my $key (keys %{$self->[1]})
	{
		return $key if $start && !exists($self->[0]{$key});
		$start = 1 if $key eq $lastkey;
	}

	return undef;
}

sub STORE
{
}
