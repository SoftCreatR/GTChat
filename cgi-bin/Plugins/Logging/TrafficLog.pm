###################################################################
#  GT-Chat 0.96 Alpha Plugin                                       #
#  Written for release whatever                                   #
#  Author: Wladimir Palant                                        #
#                                                                 #
#  This plugin writes traffic statistics to the file              #
#  Variables/traffic.log. The variable traffic_statistics_days    #
#  restricts the number of days to be kept in this log.           #
###################################################################

package GT_Chat::Plugins::TraficLogger::096_01;
use strict;

return bless({});

sub logTraffic
{
	my($self,$main,$bytes) = @_;
	
	my ($sec,$min,$hour)=(localtime($main->{runtime}{now}))[0..2];
	my $date = $main->{runtime}{now}-$hour*3600-$min*60-$sec;

	my $found = 0;

	$main->open(local *FILE, '+>>'.$main->translateName('vardir::traffic.log'));
	seek(FILE,0,0);
	my @entries = <FILE>;
	seek(FILE,0,0);
	truncate(FILE,0);
	foreach my $entry (@entries)
	{
		$entry =~ s/[\n\r]//g;
		my($mdate,$traffic) = split(/\|/,$entry);
		if ($date == $mdate)
		{
			$found = 1;
			$traffic += $bytes;
		}
		if (!$main->{settings}{traffic_statistics_days} || $mdate >= $main->{runtime}{now}-$main->{settings}{traffic_statistics_days}*24*3600)
		{
			print FILE "$mdate|$traffic\n";
		}
	}
	
	if (!$found)
	{
		print FILE "$date|$bytes\n";
	}

	truncate(FILE, tell(FILE));
	$main->close(*FILE);
}
