###################################################################
#  GT-Chat 0.96 Alpha Plugin                                       #
#  Written for release whatever                                   #
#  Author: Wladimir Palant                                        #
#                                                                 #
#  This plugin provides the template variables to deal with date  #
#  and time. The output format is set in the language file.       #
#  {GETSTDDATE} and {READSTDDATE} use a textual date format, the  #
#  other tags need the standard Unix date/time format (seconds    #
#  since January 1, 1970).                                        #
###################################################################

package GT_Chat::Plugins::TimeTags::096_01;
use strict;

return bless({
	template_command_handlers => {
		GETTIME => \&time_handler,
		GETDATE => \&time_handler,
		GETDATETIME => \&time_handler,
		READDATE => \&read_handler,
		GETSTDDATE => \&time_handler,
		READSTDDATE => \&read_handler,
	},
});

sub time_handler
{
	my($self,$main,$params,$output) = @_;
	
	my($tag,$var) = @$params;
	$var = time if (!defined($var));
	$var = $main->getEx($1) if ($var =~ /^\$(.+)/);
	$var += $main->{current_user}{timeoffset}*3600 if (defined($main->{current_user}) && $tag ne "GETSTDDATE");

	my($type) = ($tag =~ /^GET(?:STD)?(.*)/);
	$$output .= getTimeText($main, lc($type), $var);
}

sub read_handler
{
	my($self,$main,$params,$output) = @_;
	
	my($tag,$var1,$var2) = @$params;

	$var1 =~ s/^\$//;

	$var2 = time if (!defined($var2));
	$var2 = $main->getEx($1) if ($var2 =~ /^\$(.+)/);
	return if (!defined($var2));
	$var2 += $main->{current_user}{timeoffset}*3600 if (defined($main->{current_user}) && $tag ne "READSTDDATE");

	my %ret;
	if ($var2 =~ /\./)
	{
		($ret{day},$ret{month},$ret{year}) = split(/\./,$var2);
	}
	else
	{
		($ret{sec},$ret{min},$ret{hour},$ret{day},$ret{month},$ret{year},$ret{wday},$ret{yday}) = localtime($var2);
		$ret{month}++;
		$ret{year}+=1900;
	}
	$main->set($var1,\%ret);
}

sub getTimeText
{
	my($main,$type,$time) = @_;
	
	my @time;
	if ($time =~ /\./)
	{
		@time = (0,0,0,split(/\./,$time));
	}
	else
	{
		@time = localtime($time);
		$time[4]++;
		$time[5]+=1900;
	}

	my $mask = $main->{current_language}{$type.'format'};
	my $values = $main->{current_language}{$type.'values'};

	return sprintf($mask,@time[@$values]);
}
