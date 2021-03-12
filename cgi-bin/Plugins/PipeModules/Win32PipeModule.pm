###################################################################
#  GTChat 0.95 Alpha Plugin                                       #
#  Written for release 20021120                                   #
#  Author: Wladimir Palant                                        #
#                                                                 #
#  This pipe module (needed for the server push mode) uses the    #
#  module Win32::Pipe (at least version 20020325 required!) for   #
#  Windows-style pipes on Windows NT/2000/XP.                     #
###################################################################

package GTChat::Plugins::Win32PipeModule::095_02;
use strict;
use IO::Handle;

use Win32::Pipe 20020325 qw(ERROR_NO_DATA);

return bless({});

sub createPipe
{ 
	my($main,$name) = @_;
	
	my $file = $main->translateName("tmpdir::$name.pipe");
	$file =~ s/\///g;
	$file = substr($file,length($file)-245) if length($file)>245;

	my $pipe = new Win32::Pipe($file);
	return undef if (!defined($pipe));
	
	tie local(*PIPE),__PACKAGE__,$pipe;

	return \*PIPE;
}

sub openPipe
{
	my($main,$name) = @_;

	my $file = $main->translateName("tmpdir::$name.pipe");
	$file =~ s/\///g;
	$file = substr($file,length($file)-245) if length($file)>245;

	my $handle = new IO::Handle;
	$main->open($handle,"+<\\\\.\\pipe\\$file") || return undef;

	return $handle;
}

sub removePipe
{
}

sub TIEHANDLE
{
	my ($class,$pipe)=@_;

	return bless({pipe => $pipe, buffered => ''});
}

sub READLINE
{
	my $self = shift;
	
	return undef if $self->{closed};
	
	if ($self->{buffered} eq '')
	{
		$self->{pipe}->Connect;

		while (1)
		{
			my $line = $self->{pipe}->Read;
			last if (!defined($line) || $line eq '');
			$self->{buffered} .= $line;
		}
		
		$self->{pipe}->Disconnect;
		print "\n";
	}

	$self->{buffered} =~ s/^(.*?(?:\n|$))//s;
	return $1;
}

sub CLOSE
{
	my $self = shift;
	
	$self->{pipe}->Close() if defined($self->{pipe});
	$self->{closed}=1;
}

sub DESTROY
{
	my $self = shift;
	
	$self->CLOSE if (!$self->{closed});
}
