#!/usr/bin/perl -w

###################################################################
#  GTChat GTChat 0.96 Alpha Build 20060923 core file              #
#  Copyright 2001-2006 by Wladimir Palant (http://www.gtchat.de)  #
#  Copyright 2006 by Sascha Heldt (https://www.softcreatr.de)     #
###################################################################

use strict;

eval
{
	if (defined($ENV{SERVER_SOFTWARE}) && $ENV{SERVER_SOFTWARE} =~ /IIS/)
	{
		close(STDERR);
		open(STDERR,"NUL");
	}

	eval
	{
		require 5.005;
	};
	if ($@)
	{
		die {error_message => "Perl 5.005 or higher required for this program!", error_name => "error_wrongversion"};
	}

	use strict;
	use vars qw($main $settings $modules $r);

	$r = ($ENV{MOD_PERL} ? shift : undef);
	$main::request = $r;    #DEBUG
	$main::request = $r;    #DEBUG

	$modules = $main::modules if $main::modules;
	unless (defined($modules))
	{
		my %modules;
		tie %modules, "GT_Chat::module_loader";
		$modules = \%modules;
	}
	$modules->{checktime} = defined($r);

	$settings = $modules->{'Settings.dat'};

	$modules->{directories} = $settings->{directories};
	$modules->{checktime} = (defined($r) && $settings->{check_module_modification});

	$main = $modules->{'sourcedir::Subs.pm'};

	$main->{r} = $r if (defined($r));
	$main->{settings} = $settings;

	$main->{http_host} = lc(($settings->{urls}{chaturl} =~ /^\w+:\/\/(w{3}\.)?([^\/]+)/g)[1]);

	$main->{runtime} = {
		action => 'info',
		basedir => $modules->{'__basedir'},
		language => $settings->{default}{language},
		now => time,
		id => "",
	};
	$main->{modules} = $modules;
	$main->{VERSION} = '0.96 RC 1';
	$main->loadDefinitions;

	if ($ENV{MOD_PERL} && !defined($r))
	{
		if (exists($settings->{preload_modules}))
		{
			foreach my $module (@{$settings->{preload_modules}})
			{
				my $filename = $main->translateName($module);
				if (-d $filename)
				{
					preload_modules_dir($module, $filename);
				}
				else
				{
					eval
					{
						my $result = $modules->{$module};
					};
				}
			}
		}
		if (exists($settings->{preload_templates}))
		{
			foreach my $template (@{$settings->{preload_templates}})
			{
				my $filename = $main->translateName($template);
				if (-d $filename)
				{
					preload_templates_dir($template, $filename);
				}
				else
				{
					eval
					{
						$main->parseTemplate($filename,1);
					};
				}
			}
		}
		return 1;
	}

	$main->init;

	my $language = $main->{runtime}{language};
  if(!grep(/^$language$/,@{$settings->{languages}}))
  {
	       $language = $settings->{default}{language};
  }
	my $hashfactory = $modules->{'sourcedir::joinedhash.pm'};
	$settings = $hashfactory->new($settings->{language_dependent}{$language},$settings);
	$main->{settings} = $settings;
	$main->{jumptable} = $hashfactory->new($main->{definitions}{subs},$settings->{custom_subs});
	$main->{runtime}{style} = $main->{runtime}{css} || $settings->{default}{style};

	if (!defined($r) && exists($main->{settings}{custom_traffic_logger}) && $#{$main->{settings}{custom_traffic_logger}}>=0)
	{
		$modules->{'sourcedir::TrafficCounter.pm'}->init;
	}
	else
	{
		$| = 1;
	}

	my $ownurl = "$settings->{urls}{chaturl}?id=";
	$ownurl .= $main->{runtime}{id} unless $main->{runtime}{cookieid};

	my @forwarded = ('language');
	push @forwarded, @{$settings->{forward_params}} if (exists($settings->{forward_params}));

	foreach (@forwarded)
	{
		my ($key,$value) = ($_,$main->{input}{$_});

		$key="" unless defined($key);
		$value="" unless defined($value);

		$key =~ s/\W/"%".unpack("H2",$&)/eg;
		$value =~ s/\W/"%".unpack("H2",$&)/eg;

		$ownurl .= ";$key=$value";
	}
	$main->{runtime}{completeurl} = $ownurl;
	$main->{runtime}{chaturl} = $settings->{urls}{chaturl};

	$main->{language_data}{$language} = $modules->{"$language.lng"};
	$main->{current_language} = $main->{language_data}{$language};

	$main->{template_vars} = {
		settings => $settings,
		language_data => $main->{language_data},
		current_language => $main->{current_language},
		runtime => $main->{runtime},
		input => $main->{input},
		cookie => $main->{cookie},
	};

	if ($main->{runtime}{id} ne "")
	{
		my $username = $main->getUsernameFromID($main->{runtime}{id});
		my $user;
		if (defined($username))
		{
			$user = $main->loadOnlineInfo($username);
			$user = $main->loadUser($user->{name},$user) if (defined($user))
		}

		if (defined($user))
		{
			$main->{current_user} = $user;
			$main->{template_vars}{current_user} = $user;
			$main->{runtime}{style} = $user->{style} if defined($user->{style}) && $user->{style} ne '';
		}
		else
		{
			delete($main->{current_user});
			$modules->{'sourcedir::Logout.pm'}->logout($main);
			$main->exit;
		}
	}

	if (!$main->{current_user} && $main->{settings}{maintenance} && $main->{runtime}{action} ne 'login')
	{
		$main->{runtime}{action} = 'info';
		$main->{input}{template} = 'maintenance';
	}

	my $handlers = $hashfactory->new($main->{definitions}{action_handlers}, $settings->{custom_action_handlers});

	my $action = $main->{runtime}{action};
	if (exists($handlers->{$action}))
	{
		my $handler = $modules->{$handlers->{$action}};
		$main->fatal_error('actionhandler_notfound',{action => $action, file => $handler->{filename}}) unless (defined($handler->{action_handlers}{$action}));
		&{$handler->{action_handlers}{$action}}($handler, $main);
		$main->exit;
	}
	else
	{
		$main->fatal_error('action_unknown',{action => $action});
	}
};
if ($@)
{
	$@ = {error_message => "Fatal error occured: $@"} if (ref($@) eq "");
	fatal_error2($@);
}
1;

sub preload_modules_dir
{
	my ($module, $filename) = @_;

	opendir(local *DIR, $filename);
	foreach my $file (readdir(DIR))
	{
		if ($file !~ /^\./)
		{
			if (-d "$filename$file")
			{
				preload_modules_dir("$module$file/","$filename$file/");
			}
			elsif ($file =~ /\.pm$/)
			{
				eval
				{
					my $result = $modules->{"$module$file"};
				};
			}
		}
	}
}

sub preload_templates_dir
{
	my ($template, $filename) = @_;

	opendir(local *DIR, $filename);
	foreach my $file (readdir(DIR))
	{
		if ($file !~ /^\./)
		{
			if (-d "$filename$file")
			{
				preload_templates_dir("$template$file/","$filename$file/");
			}
			elsif ($file =~ /\.(html|mail)$/)
			{
				eval
				{
					$main->parseTemplate("$filename$file",1);
				};
			}
		}
	}
}

sub error_message
{
	my $message = shift;

	if (defined($r))
	{
		$r->send_http_header('text/html');
	}
	else
	{
		print "Content-Type: text/html\n\n";
	}

	print "<html><head><title>Fatal error</title></head><body bgcolor=#C0C0C0><center><h2>$message</h2></center></body></html>\n";
}

sub fatal_error2
{
	my $error = shift;
	my $message;

	if (defined($error->{error_name}))
	{
		if (defined($main) && defined($main->{current_language}) && defined($main->{current_language}{messages}{$error->{error_name}}))
		{
			$message = $main->getMessage($error->{error_name},$error);
		}
		elsif (defined($error->{error_message}))
		{
			$message = $error->{error_message};
		}
		else
		{
			$message = "Fatal error occured, error '$error->{error_name}', no further description available.";
		}
	}
	else
	{
		$message = $error->{error_message};
	}

	if (defined($message))
	{
		warn 'GT-Chat error: '.$message;
		if (defined($main))
		{
			eval
			{
				$main->{template_vars}{error} = $message;
				$main->printTemplate("error");
			};
			if ($@)
			{
				error_message($message . "<br><br>Furthermore could not print template error.html.");
			}
		}
		else
		{
			error_message($message);
		}
	}
}

package GT_Chat::module_loader;

sub TIEHASH
{
	my ($class,$checktime) = @_;

	my $basedir = (caller)[1];
	$basedir =~ s/\/?[^\/]*$//;
	$basedir = '.' if $basedir eq '';

	return bless({
		__basedir => $basedir,
		__checktime => $checktime,
	});
}

sub FETCH
{
	my ($self,$key) = @_;

	return $self->{__basedir} if $key eq '__basedir';

	my @parts = split(/::/,$key);
	my $module = ($#parts>0 ? "$self->{__basedir}/$self->{__directories}{$parts[0]}/$parts[1]" : "$self->{__basedir}/$parts[0]");

	my $lastchange = ($self->{__checktime} ? (stat($module))[9] : 0);

	die {error_message => "Could not determine the modification time of $module, seems that this module doesn't exist. Please contact the webmaster."} if (!defined($lastchange));

	if (!exists($self->{$key}) || $self->{$key}{lastchange} != $lastchange)
	{
		my $result = do $module;

		if ($@)
		{
			die {error_message => "Failed to load the file $module. Possible reasons:<ul><li>The file doesn't exist<li>The file is incomplete<li>The program is not permitted to read the file</ul>Please contact the webmaster.<br><br>Perl error message:<br>$@"};
		}

		if (!ref($result))
		{
			die {error_message => "$module did not return a true value, maybe it is missing or defect. Please contact the webmaster."} if (!$result);
			$result = {};
		}

		$result->{lastchange} = $lastchange;
		$result->{filename} = $module;
		$self->{$key} = $result;
		return $result;
	}
	else
	{
		return $self->{$key};
	}
}

sub STORE
{
	my ($self,$key,$value) = @_;
	if ($key eq 'directories')
	{
		$self->{__directories} = $value;
	}
	elsif ($key eq 'checktime')
	{
		$self->{__checktime} = $value;
	}
}