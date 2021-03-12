###################################################################
#  GTChat GTChat 0.96 Alpha Build 20060923 core file              #
#  Copyright 2001-2006 by Wladimir Palant (http://www.gtchat.de)  #
#  Copyright 2006 by Sascha Heldt (https://www.softcreatr.de)     #
###################################################################

package GT_Chat::Send;
use strict;

bless({
	action_handlers => {
		'send' => \&send_handler,
	},
});

sub send_handler
{
	my($self,$main) = @_;

	$main->fatal_error('nopermission') if (!$main->hasPermission('user'));

	$main->{input}{textid} =~ s/\D//g;
	if ($main->{input}{textid} ne $main->{current_user}{lasttextid})
	{
		my $talked=0;
		my $oldroom=$main->{current_user}{room};

		my @todo=();

OUTER:
		foreach my $text (split(/\x01/,$main->{input}{text}))
		{
			$text =~ s/^\s+|\s+$//g;
			$text =~ s/\s+/ /g;

			eval
			{
				$main->invokeModulesList($main->{settings}{custom_send_listener},'beforeTextProcessing',\$text);
			};
			if ($@)
			{
				my $error = errorToOutput($main, $@);
				push @todo, $error if defined($error);
				next;
			}

			next if $text eq '';

			my $command='';
			if ($text =~ /^\/([^\s]+)(.*)$/)
			{
				$command=$1;
				$text=$2;
				$text =~ s/^\s+//g;
			}

			$talked=1 if ($command ne "alive");
			if ($main->{settings}{custom_command_handlers} && $main->{settings}{custom_command_handlers}{$command})
			{
				unless ($main->hasPermission("command.$command"))
				{
					push @todo,[$main->{current_user}{name},
								undef,
								$main->toOutputString(
									{
										template => 'message',
										message => 'error_command_nopermission',
									}
								),
							];
				}
				else
				{
					my $ret;
					eval
					{
						my $handler = $main->{modules}{$main->{settings}{custom_command_handlers}{$command}};

						$main->fatal_error('commandhandler_notfound',{command => "/$command", file => $handler->{filename}}) unless (exists($handler->{command_handlers}{$command}));

						$ret=$handler->{command_handlers}{$command}->($handler,$main,$command,$text);
					};
					if ($@)
					{
						my $error = errorToOutput($main, $@);
						push @todo, $error if defined($error);
					}
					else
					{
						if (ref($ret) eq 'ARRAY')
						{
							push @todo, @$ret;
						}
						elsif (ref($ret) && $ret->isa('ARRAY'))
						{
							push @todo, $ret;
						}
					}
					last unless exists($main->{current_user}{id});
				}
			}
			else
			{
				push @todo,[$main->{current_user}{name},
							undef,
							$main->toOutputString({template => 'message',
												message => 'error_unknowncommand',
												'*' => ['command=/'.$main->toHTML($command)],
												})
						];
			}
		}

		$main->{current_user}{lasttextid} = $main->{input}{textid};
		delete $main->{input}{textid};
		$main->{current_user}{lastalive} = $main->{runtime}{now};
		$main->{current_user}{lasttalk} = $main->{runtime}{now} if $talked;

		eval
		{
			$main->saveOnlineInfo($main->{current_user}) if ($main->{current_user}{id});
		};
		if ($@)
		{
			my $error = errorToOutput($main, $@);
			push @todo, $error if defined($error);
		}

		sendOutputStrings($main,@todo) if ($#todo>=0);
	}

	my $template = $main->{input}{template};
	$template = 'send_output' unless defined($template);
	$template =~ s/[^\w\d_.]//g;
	$template =~ s/\./\//g;

	$main->printTemplate($template);
}

sub errorToOutput
{
	my($main,$error) = @_;

	$error = {error_name => 'error_custom', error => "Fatal error occured: $error"} unless ref($error);

	$error = {error_name => 'error_custom!', error => $error->{error_message}} if $error->{error_message} && !$error->{error_name};

	if ($error->{error_name})
	{
		my $name = $error->{error_name};
		delete $error->{error_name};

		my @params = ();
		foreach (keys %$error)
		{
			my $param = "$_=$error->{$_}";
			$param =~ s/[\n\r|]//g;
			push @params,$param;
		}

		return [$main->{current_user}{name},
					undef,
					$main->toOutputString({template => 'message',
										message => $name,
										'*' => \@params,
										}),
				];
	}
	return undef;
}

sub sendOutputStrings
{
	my ($main,@commands)=@_;

	eval
	{
		$main->invokeModulesList($main->{settings}{custom_send_listener},'beforeSend',\@commands);
	};

	return if $#commands < 0;

	my $users = $main->getOnlineUsers(1);

	foreach my $user (@$users)
	{
		my @toSend=();

		foreach (@commands)
		{
			my ($toUser,$toRoom,$command)=@$_;

			if (($toUser && $toUser eq $user->{name}) || ($toRoom && $toRoom eq $user->{room}) || (!$toUser && !$toRoom))
			{
				my $template = (split(/\|/,$command))[0];
				push @toSend,$command unless $main->{settings}{ignore_messages}{$template} && defined($user->{ignored}) && $main->{current_user} && grep {$_ eq $main->{current_user}{name}} split(/\s/,$user->{ignored});
			}
		}

		if ($#toSend>=0)
		{
			my $filename = unpack("H*",$user->{name});
			my $handle;
			if ($user->{pull})
			{
				$handle = local *OUTPUT;
				$main->open($handle,'>>'.$main->translateName("tmpdir::$filename.queue")) || next;
			}
			else
			{
				$handle = $main->openPipe($filename) || next;
			}

			foreach (@toSend)
			{
				print $handle "$_\n";
			}

			$main->close($handle);
		}
	}

	eval
	{
		$main->invokeModulesList($main->{settings}{custom_send_listener},'afterSend',\@commands);
	};
}

sub toOutputString
{
	my ($main,$params)=@_;

	my $ret=$params->{template};

	if (exists($main->{settings}{custom_output_params}) && exists($main->{settings}{custom_output_params}{$params->{template}}))
	{
		foreach (@{$main->{settings}{custom_output_params}{$params->{template}}})
		{
			$ret .= '|'.(exists($params->{$_})?$params->{$_}:'');
		}
	}

	if (exists($params->{'*'}))
	{
		foreach (@{$params->{'*'}})
		{
			$ret .= '|'.$_;
		}
	}
	return $ret;
}
