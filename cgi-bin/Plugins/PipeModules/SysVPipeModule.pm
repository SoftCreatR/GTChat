###################################################################
#  GTChat 0.95 Alpha Plugin                                       #
#  Written for release 20021120                                   #
#  Author: Wladimir Palant                                        #
#                                                                 #
#  This pipe module (needed for the server push mode) uses SysV   #
#  IPC and should work on the most Unix systems                   #
###################################################################

package GTChat::Plugins::SysVPipeModule::095_02;
use strict;
use IO::Handle;

return bless({});

sub createPipe
{ 
	my($main,$name) = @_;
	
	my $file = $main->translateName("tmpdir::$name.pipe");
	unlink($file);

	my @creationSubs = (
		sub {               # try to create a pipe with internal methods
			eval
			{
				syscall($main->{settings}{SYS_mknod},$file,$main->{settings}{S_IFIFO}|0600,0);
			};
		},
		sub {               # try to create a pipe with internal methods and default parameters
			eval
			{
				syscall(14,$file,010000|0600,0);
			} if ($main->{settings}{SYS_mknod} != 14 || $main->{settings}{S_IFIFO} != 010000);
		},
		sub {               # try to create a pipe with the external mknod program
			`$main->{settings}{mknodprog} $file p` if ($main->{settings}{mknodprog});
		},
		sub {               # try to create a pipe with the external mkfifo program
			`$main->{settings}{mkfifoprog} $file` if ($main->{settings}{mkfifoprog});
		},
		sub {               # return undef if everything fails
			return undef;
		},
	);

	foreach (@creationSubs)
	{
		$_->();
		last if -p $file;
	}
	
	my $handle = new IO::Handle;
	open($handle,'+<'.$file) || return undef;

	return $handle;
}

sub openPipe
{
	my($main,$name) = @_;

	my $file = $main->translateName("tmpdir::$name.pipe");
	my $handle = new IO::Handle;
	$main->open($handle,'+<'.$file) || return undef;
	
	return $handle;
}

sub removePipe
{
	my($main,$name) = @_;
	
	unlink($main->translateName("tmpdir::$name.pipe"));
}
