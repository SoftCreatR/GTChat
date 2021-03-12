###################################################################
#  GTChat 0.95 Alpha Plugin                                       #
#  Written for release 20021225                                   #
#  Author: Wladimir Palant                                        #
#                                                                 #
#  This plugin provides messages log analysis.                    #
###################################################################

package GTChat::Plugins::Administration::Log::095_01;
use strict;

return bless({
	action_handlers => {
		'admin_log' => \&log_handler,
	},
	template_var_handlers => {
		'admin_messageslogs' => \&logs_loader,
	},
});

sub log_handler
{
	my($self,$main) = @_;
	
	$main->{template_vars}{backaddr} = 'javascript:history.back()';
 
	$main->fatal_error('nopermission') unless $main->hasPermission('admin_log');
	
	my $lognum = int($main->{input}{log});
	my $filename = $main->translateName('vardir::messages.' . ($lognum ? "$lognum." : '') . 'log');

	$main->open(local *LOG,$filename) || $main->fatal_error('couldnotopen',{file => $filename});
	my @entries = <LOG>;
	$main->close(*LOG);
	
	$main->{template_vars}{log_filename}=$filename;
	$main->printTemplate('admin/log_top');

	my %rooms = map {$_ => 1} split(/\s+/,$main->{input}{rooms});
	foreach (@entries)
	{
		s/[\n\r]//g;
		my ($time,$user,$room,$message) = split(/\|/,$_,4);
		if (($user eq '' && $room eq '' && $main->{input}{show_global})
		 || ($user ne '' && $main->{input}{show_private})
		 || ($room ne '' && !$rooms{$room} && $main->{input}{show_nonexistent})
		 || ($room ne '' && $main->{input}{"show_room.$room"}))
		{
			$message = $main->fromOutputString($message);
			if ($main->{input}{"show_template.$message->{template}"})
			{
				$message->{time} = $time;
				$message->{_user} = $user;
				$message->{_room} = $room;
				
				$main->{template_vars}{params}=$message;

				my $output = '';
				$main->parseTemplate('log/'.$message->{template})->process($main,\$output);
				print $output;
			}
		}
	}

	my $output = "\n";
	$main->parseTemplate('admin/log_bottom')->process($main,\$output);
	print $output; 
}

sub logs_loader
{
	my($self,$main,$var) = @_;

	my @ret = ();
	my $to = 0;

	foreach my $lognum (0..$main->{settings}{messageslog_backups_count})
	{
		my $filename = $main->translateName('vardir::messages.' . ($lognum ? "$lognum." : '') . 'log');
		$main->open(local *LOG,$filename) || next;
		my $line = <LOG>;
		$main->close(*LOG);
		
		$line = (split(/\|/,$line))[0];
		if ($line > 0)
		{
			push @ret,{num => $lognum, from => int($line), to => $to};
			$to = $line;
		}
	}
	$main->{template_vars}{admin_messageslogs} = \@ret;
}
