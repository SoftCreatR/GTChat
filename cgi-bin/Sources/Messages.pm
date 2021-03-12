###################################################################
#  GTChat GTChat 0.96 Alpha Build 20060923 core file              #
#  Copyright 2001-2006 by Wladimir Palant (http://www.gtchat.de)  #
#  Copyright 2006 by Sascha Heldt (https://www.softcreatr.de)     #
###################################################################

package GT_Chat::Messages;
use strict;

bless({
	action_handlers => {
		messages => \&messages_handler,
	},
	template_var_handlers => {
		messages => \&messages_var,
	},
});

sub messages_handler
{
	my($self,$main) = @_;

	if ($main->{current_user}{pull})
	{
		$main->printTemplate('messages_top');

		my $output;
		$main->parseTemplate('messages_bottom')->process($main,\$output);
		print $output;
	}
	else
	{
		my $oldpipe = $main->openPipe(unpack("H*",$main->{current_user}{name}));
		if ($oldpipe)
		{
			print $oldpipe "quit\n";
			$main->close($oldpipe);
			sleep(1);
		}

		my $pipe = $main->createPipe(unpack("H*",$main->{current_user}{name})) || $main->fatal_error('couldnotcreatepipe');

		$main->printTemplate('messages_top');

		print "\n";

		$self->{quit} = 0;
		eval
		{
			while (!$self->{quit})
			{
				my $output=$self->getNextOutput($main,$pipe);
				print "$$output\n" if defined($output);
			}
		};

		my $error = $@;

		$main->close($pipe);
		$main->removePipe(unpack("H*",$main->{current_user}{name}));

		die $error if $error;

		my $output = "\n";
		$main->parseTemplate('messages_bottom')->process($main,\$output);
		print $output;
	}
}

sub fromOutputString
{
	my ($main,$string)=@_;

	return undef if !defined($string);

	my @parts=split(/\|/,$string);
	my %params=(template => shift(@parts));

	if (exists($main->{settings}{custom_output_params}) && exists($main->{settings}{custom_output_params}{$params{template}}))
	{
		foreach (@{$main->{settings}{custom_output_params}{$params{template}}})
		{
			$params{$_}=shift(@parts);
		}
	}

	$params{'*'}=\@parts if ($#parts >= 0);

	return \%params;
}

sub getNextOutput
{
	my ($self,$main,$handle,$output)=@_;

	my $string;

	$string = <$handle>;
	return undef if (!defined($string) || $string eq '');

	$string =~ s/[\n\r]//g;

	my $params=fromOutputString($main,$string);
	$params->{time} = $main->{runtime}{now};

	if (!defined($output))
	{
		my $tmp='';
		$output=\$tmp;
	}

	$main->{template_vars}{params}=$params;

	eval
	{
		$main->parseTemplate('messages/'.$params->{template})->process($main,$output);
	};
	if ($@)
	{
		my $error = $@;

		$error = {error_name => 'error_custom', error => "Fatal error occured: $error"} unless ref($error);

		$error = {error_name => 'error_custom!', error => $error->{error_message}} if $error->{error_message} && !$error->{error_name};

		if ($error->{error_name})
		{
			$params->{template} = 'message';
			$params->{message} = $error->{error_name};
			delete $error->{error_name};

			my @params = ();
			foreach (keys %$error)
			{
				my $param = "$_=$error->{$_}";
				push @params,$param;
			}
			$params->{'*'} = \@params;

			eval
			{
				$main->parseTemplate('messages/'.$params->{template})->process($main,$output);
			};
		}
	}

	$self->{quit}=1 if ($params->{template} eq 'quit');

	return $output;
}

sub messages_var
{
	my ($self,$main,$var)=@_;

	return if (!$main->{current_user}{pull});

	my $output = '';
	my $filename = unpack("H*",$main->{current_user}{name});
	my $writemode = (exists($main->{input}{textid}) ? '+>>' : '+>');
	if ($main->open(local *QUEUE,'+<'.$main->translateName("tmpdir::$filename.queue")) && $main->open(local *OLDQUEUE,$writemode.$main->translateName("tmpdir::$filename.oldqueue")))
	{
		while (<QUEUE>)
		{
			print OLDQUEUE $_;
		}
		seek(QUEUE,0,0);
		truncate(QUEUE,0);
		$main->close(*QUEUE);

		seek(OLDQUEUE,0,0);
		while ($self->getNextOutput($main,*OLDQUEUE,\$output))
		{
			$output .= "\n";
		}
		$main->close(*OLDQUEUE);
	}
	else
	{
		$main->close(*QUEUE);
		$main->parseTemplate('messages/quit')->process($main,\$output);
	}

	$main->{template_vars}{messages}=$output;
}
