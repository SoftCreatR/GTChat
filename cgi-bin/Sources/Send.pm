###################################################################
#  GTChat GTChat 0.95 Alpha Build 20040120 core file              #
#  Copyright 2001-2006 by Wladimir Palant (http://www.gtchat.de)  #
#  Copyright 2006 by Sascha Heldt (https://www.gt-chat.de)        #
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
		my %changed=();
		my $oldroom=$main->{current_user}{room};

		my @todo=();

OUTER:
		foreach my $text (split(/\x01/,$main->{input}{text}))
		{
			$text =~ s/^\s+|\s+$//g;
			$text =~ s/\s+/ /g;

			$main->invokeModulesList($main->{settings}{custom_send_checker},'checkText',\$text);

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
						my $error = $@;

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

							push @todo,[$main->{current_user}{name},
										undef,
										$main->toOutputString({template => 'message',
															message => $name,
															'*' => \@params,
															}),
									];
						}
					}
					else
					{
						my $stop = 0;
						foreach (@$ret)
						{
							if ($_->[3])
							{
								foreach my $flag (@{$_->[3]})
								{
									$changed{$flag}=1;
								}
							}

							if (!exists($main->{current_user}{id}))
							{
								$stop = 1;
								last;
							}
							else
							{
								push @todo,$_;
							}
						}
						last if $stop;
					}
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

		if (keys %changed > 0)
		{
			push @todo,[undef,
						undef,
						$main->toOutputString({template => 'changed',
											name => $main->{current_user}{name},
											room => $main->{current_user}{room},
											oldroom => $oldroom,
											'*' => [keys %changed],
											})
					];
		}

		$main->{current_user}{lasttextid} = $main->{input}{textid};
		delete $main->{input}{textid};
		$main->{current_user}{lasttalk} = $main->{runtime}{now} if $talked;
		$main->saveOnlineInfo($main->{current_user}) if ($main->{current_user}{id});

		if (exists($changed{room}))
		{
			my $room = $main->loadRoom($oldroom);
			if (!$room->{permanent})
			{
				my $users = $main->getOnlineUsers();
				my $found = 0;
				foreach my $user (@$users)
				{
					if ($main->translateOnlineString($user)->{room} eq $oldroom)
					{
						$found = 1;
						last;
					}
				}
				$main->removeRoom($oldroom) if (!$found)
			}
		}

		sendOutputStrings($main,@todo) if ($#todo>=0);
	}

	my $template = $main->{input}{template};
	$template = 'send_output' unless defined($template);
	$template =~ s/[^\w\d_.]//g;
	$template =~ s/\./\//g;

	$main->printTemplate($template);
}

sub sendOutputStrings
{
	my ($main,@commands)=@_;

	$main->invokeModulesList($main->{settings}{custom_messages_filter},'filterOutputStrings',\@commands);

	return if $#commands < 0;

	my $users = $main->getOnlineUsers(1);
#    my $quotedname = quotemeta($main->{current_user}{name});

	for (my $i=0;$i<=$#$users;$i++)
	{
		my $user=$main->translateOnlineString($users->[$i]);
		my @toSend=();

		foreach (@commands)
		{
			my ($toUser,$toRoom,$command)=@$_;

			if (($toUser && $toUser eq $user->{name}) || ($toRoom && $toRoom eq $user->{room}) || (!$toUser && !$toRoom))
			{
				my $template = (split(/\|/,$command))[0];
				push @toSend,$command unless $main->{settings}{ignore_messages}{$template} && defined($user->{ignored}) && $main->{current_user} && grep {$_ eq $main->{current_user}{name}} split(/\s/,$user->{ignored});
#                push @toSend,$command unless $main->{settings}{ignore_messages}{$template} && defined($user->{ignored}) && $main->{current_user} && " $user->{ignored} " =~ /\s$quotedname\s/;
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

	$main->invokeModulesList($main->{settings}{custom_messages_logger},'logOutputStrings',\@commands);
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
