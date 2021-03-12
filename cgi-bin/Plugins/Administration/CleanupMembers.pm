###################################################################
#  GT-Chat 0.95 Alpha Plugin                                       #
#  Written for release 20021225                                   #
#  Author: Wladimir Palant                                        #
#                                                                 #
#  This plugin enables you to delete user accounts that have not  #
#  been used for a long time.                                     #
###################################################################

package GT_Chat::Plugins::Administration::CleanupMembers::095_01;
use strict;

return bless({
	action_handlers => {
		'admin_changemembercleanuplimit' => \&limit_handler,
		'admin_cleanupwarnmembers' => \&warn_handler,
		'admin_cleanupdeletemembers' => \&delete_handler,
		'admin_cleanupprocessmembers' => \&process_handler,
	},
	template_var_handlers => {
		'admin_inactiveaccounts' => \&list_handler,
	},
});

sub list_handler
{
	my($self,$main,$var) = @_;
	
	my $limit = ($main->{settings}{membercleanup_limit} > 0 ? $main->{settings}{membercleanup_limit} : 200);
	$limit = $main->{runtime}{now} - $limit * 24 * 60 * 60;

	my $users = $main->getAllUsers();
	my @ret = ();
	for (my $i = 0; $i <= $#$users; $i++)
	{
		my ($nickname, $username) = split(/\|/, $users->[$i]);
		my $user = $main->loadUser($username);
		if ($user->{group} < $main->{current_user}{tempgroup} && $user->{lastlogin} < $limit)
		{
			$user->{inactive_secondssum} = $main->{runtime}{now} - $user->{lastlogin};
			$user->{inactive_seconds} = $user->{inactive_secondssum} % 60;
			$user->{inactive_minutes} = $user->{inactive_secondssum} / 60 % 60;
			$user->{inactive_hours} = $user->{inactive_secondssum} / (60 * 60) % 24;
			$user->{inactive_days} = int($user->{inactive_secondssum} / (24 * 60 * 60));
			$user->{name_hex} = unpack('H*', $user->{name});
			push(@ret, $user);
		}
	}

	@ret = sort {$b->{inactive_secondssum} <=> $a->{inactive_secondssum}} @ret;

	$main->{template_vars}{admin_inactiveaccounts} = \@ret;
}

sub limit_handler
{
	my($self,$main) = @_;
	
	$main->{template_vars}{backaddr} = 'javascript:history.back()';
 
	$main->fatal_error('nopermission') unless $main->hasPermission('admin_cleanupmembers');

	my $newvalue = int($main->{input}{cleanuplimit});
	if ($newvalue > 0 && $newvalue != $main->{settings}{membercleanup_limit})
	{
		my $settings = $main->{modules}{'Settings.dat'};
		$settings->{membercleanup_limit} = $newvalue;
	
		$main->saveSettings($settings);
	}

	$main->printTemplate('admin/cleanupmembers');
}

sub getList
{
	my $main = shift;

	my @ret = ();
	foreach my $key (keys %{$main->{input}})
	{
		if ($key =~ /^user_([a-fA-F0-9]+)$/ && $main->{input}{$key})
		{
			push @ret, pack('H*', $1) . "\n";
		}
	}
	return \@ret;
}

sub warn_handler
{
	my($self,$main) = @_;

	$main->{template_vars}{backaddr} = 'javascript:history.back()';
 
	$main->fatal_error('nopermission') unless $main->hasPermission('admin_cleanupmembers');

	my $list = getList($main);
	if ($#$list >= 0)
	{
		$main->open(local* FILE, '>'.$main->translateName('tmpdir::cleanup_queue')) || $main->fatal_error('couldnotcreate', {file => $main->translateName('tmpdir::cleanup_queue')});
		print FILE @$list;
		$main->close(*FILE);

		$main->{template_vars}{count} = $#$list + 1;
		$main->{template_vars}{processed} = 0;
		$main->{template_vars}{type} = 'warn';
		$main->printTemplate('admin/cleanupmembers_processing');
	}
	else
	{
		$main->printTemplate('admin/cleanupmembers');
	}
}

sub delete_handler
{
	my($self,$main) = @_;

	$main->{template_vars}{backaddr} = 'javascript:history.back()';
 
	$main->fatal_error('nopermission') unless $main->hasPermission('admin_cleanupmembers');

	my $list = getList($main);
	if ($#$list >= 0)
	{
		$main->open(local* FILE, '>'.$main->translateName('tmpdir::cleanup_queue'));
		print FILE @$list;
		$main->close(*FILE);

		$main->{template_vars}{count} = $#$list + 1;
		$main->{template_vars}{processed} = 0;
		$main->{template_vars}{type} = 'delete';
		$main->{template_vars}{mailondelete} = $main->{input}{mailondelete} ? 1 : 0;
		$main->printTemplate('admin/cleanupmembers_processing');
	}
	else
	{
		$main->printTemplate('admin/cleanupmembers');
	}
}

sub process_handler
{
	my($self,$main) = @_;

	$main->{template_vars}{backaddr} = 'javascript:history.back()';
 
	$main->fatal_error('nopermission') unless $main->hasPermission('admin_cleanupmembers');

	$main->open(local* FILE, $main->translateName('tmpdir::cleanup_queue')) || $main->fatal_error('couldnotopen', {file => $main->translateName('tmpdir::cleanup_queue')});
	my @list = <FILE>;
	$main->close(*FILE);

	my $mails = ($main->{input}{type} eq 'warn' || $main->{input}{mailondelete});
	my $count = 0;
	my $maxcount = ($mails ? 10 : 30);
	foreach my $name (@list)
	{
		$name =~ s/[\r\n]//g;
 
		my $user = $main->loadUser($name);
		if ($main->{input}{type} eq 'warn')
		{
			if ($user->{email} && $user->{email} ne '')
			{
				$main->{template_vars}{user} = $user;
				$main->sendMailTemplate('mails/membercleanup_warning');
			}
		}
		else
		{
			if ($main->{input}{mailondelete} && $user->{email} && $user->{email} ne '')
			{
				$main->{template_vars}{user} = $user;
				$main->sendMailTemplate('mails/membercleanup_deleted');
			}
			$main->removeUser($user);
		}

		$count++;
		last unless $count < $maxcount;
	}
	
	if ($#list < $maxcount)
	{
		unlink($main->translateName('tmpdir::cleanup_queue'));
		$main->printTemplate('admin/cleanupmembers');
	}
	else
	{
		sleep(5) if $mails;     # have to make a pause, otherwise sendmail could be overloaded

		splice(@list, 0, $maxcount);
		$main->open(local* FILE, '>'.$main->translateName('tmpdir::cleanup_queue')) || $main->fatal_error('couldnotcreate', {file => $main->translateName('tmpdir::cleanup_queue')});
		print FILE @list;
		$main->close(*FILE);

		$main->{template_vars}{count} = $main->{input}{count};
		$main->{template_vars}{processed} = $main->{input}{count} - $#list - 1;
		$main->{template_vars}{type} = $main->{input}{type};
		$main->{template_vars}{mailondelete} = $main->{input}{mailondelete};
		$main->printTemplate('admin/cleanupmembers_processing');
	}
}
