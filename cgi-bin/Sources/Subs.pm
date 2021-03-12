###################################################################
#  GTChat GTChat 0.96 Alpha Build 20060923 core file              #
#  Copyright 2001-2006 by Wladimir Palant (http://www.gtchat.de)  #
#  Copyright 2006 by Sascha Heldt (https://www.softcreatr.de)     #
###################################################################

package GT_Chat::Subs;

use strict;

use vars qw($AUTOLOAD %templates);

bless({});

sub AUTOLOAD
{
	my $main = shift;

	my $method = (split(/::/,$AUTOLOAD))[-1];
	my $modulename = $main->{jumptable}{$method};

	$main->fatal_error('unknownmethodcall',{method => $method}) unless $modulename;

	my $module = $main->{modules}{$modulename};

	{       #DEBUG
		no strict "refs";       #DEBUG
		*$method = *{ref($module).'::'.$method};
	}       #DEBUG

	$main->fatal_error('unknownmethodcall',{method => $method}) unless $main->can($method);

	$main->$method(@_);
}

sub DESTROY{}

sub loadDefinitions
{
	my $main = shift;
	die {error_name => 'error_staticcall', method => 'loadDefinitions'} unless (ref($main) && $main->isa(__PACKAGE__));  #DEBUG

	$main->{definitions} = $main->{modules}{'sourcedir::Definitions.pm'};
}

sub init
{
	my $main = shift;
	die {error_name => 'error_staticcall', method => 'init'} unless (ref($main) && $main->isa(__PACKAGE__));  #DEBUG

	if (exists($main->{r}))
	{
		# Apache::Request->user for mod_perl 2.0, Apache::Connection->user for 1.xx
		$main->{runtime}{remote_user} = $main->{r}->can('user') ? $main->{r}->user : $main->{r}->connection->user;
	}
	else
	{
		$main->{runtime}{remote_user} = $ENV{REMOTE_USER};
	}
	$main->readCookie;
	$main->readInput;

	$main->{runtime}{id} = $main->{cookie}{cookieid} if $main->{runtime}{id} eq "" && exists($main->{cookie}{cookieid}) && $main->{cookie}{cookieid} ne "";
	$main->{runtime}{cookieid} = 1 if $main->{runtime}{id} eq $main->{cookie}{cookieid};
}

sub exit
{
	my($main,$error) = @_;
	die {error_name => 'error_staticcall', method => 'exit'} unless (ref($main) && $main->isa(__PACKAGE__));  #DEBUG

	if (!exists($main->{r}) && exists($main->{settings}{custom_traffic_logger}) && $#{$main->{settings}{custom_traffic_logger}}>=0)
	{
		my $bytes = exists($main->{r}) ? $main->{r}->bytes_sent : tied(*STDOUT)->{count};
		$main->invokeModulesList($main->{settings}{custom_traffic_logger},'logTraffic',$bytes);

		untie(*STDOUT);
	}

	die (defined($error) ? $error : {});
}

sub readCookie
{
	my $main = shift;
	die {error_name => 'error_staticcall', method => 'readCookie'} unless (ref($main) && $main->isa(__PACKAGE__));  #DEBUG

	my %cookie;
	my $cookie_string = (exists($main->{r}) ? $main->{r}->header_in("Cookie") : $ENV{HTTP_COOKIE});
	if (defined($cookie_string))
	{
		foreach my $pair (split(/; /,$cookie_string))
		{
			my($name, $value) = split(/=/,$pair);
			$cookie{$name} = $value;
		}
	}
	$main->{cookie} = \%cookie;

	foreach ('language','css')
	{
		$main->{runtime}{$_} = $cookie{$_} if exists($cookie{$_}) && $cookie{$_} ne "";
	}
}

sub readInput
{
	my $main = shift;
	die {error_name => 'error_staticcall', method => 'readInput'} unless (ref($main) && $main->isa(__PACKAGE__));  #DEBUG

	my %input = ();
	my $input;

	if (exists($main->{r}))
	{
		$input{method} = $main->{r}->method;
		if ($input{method} eq 'POST')
		{
			$input = $main->{r}->content;
		}
		else
		{
			%input = $main->{r}->Apache::args;
		}
	}
	else
	{
		$input{method} = $ENV{REQUEST_METHOD};
		if ($input{method} eq 'POST')
		{
			read(STDIN, $input, $ENV{CONTENT_LENGTH});
		}
		else
		{
			$input = $ENV{QUERY_STRING};
		}
	}

	if (defined($input))
	{
		my @pairs = $input{method} eq 'POST' || $input =~ /&/ ? split(/&/, $input) : split(/;/, $input);
		foreach my $pair (@pairs)
		{
			my($name, $value) = split(/=/, $pair);
			$name =~ tr/+/ /;
			$name =~ s/%([a-fA-F0-9][a-fA-F0-9])/chr(hex($1))/eg;
			$value =~ tr/+/ /;
			$value =~ s/%([a-fA-F0-9][a-fA-F0-9])/chr(hex($1))/eg;
			$input{$name} = $value;
		}
	}

	$main->{input} = \%input;

	foreach ('language','action','id','css')
	{
		$main->{runtime}{$_} = $input{$_} if exists($input{$_}) && $input{$_} ne "";
	}
}

sub setCookie
{
	my($main,$cookie) = @_;
	die {error_name => 'error_staticcall', method => 'setCookie'} unless (ref($main) && $main->isa(__PACKAGE__));  #DEBUG

	if (exists($main->{r}))
	{
		$main->{r}->headers_out->add("Set-Cookie",$cookie);
		$main->{r}->err_headers_out->add("Set-Cookie",$cookie);
	}
	else
	{
		print "Set-Cookie: $cookie\n";
	}
}

sub redirect
{
	my($main,$url) = @_;

	if (exists($main->{r}))
	{
		$main->{r}->header_out('Location',$url);
		$main->{r}->status(302);
	}
	else
	{
		print "Location: $url\n\n";
	}
}

sub sendMailTemplate
{
	my($main, $template) = @_;

	my $output = '';
	$main->parseTemplate($main->translateName("templatedir::$template.mail"), 1)->process($main,\$output);

	$main->sendMail($main->{template_vars}{to},$main->{template_vars}{subject},$output);
}

sub parseTemplate
{
	my($main, $template, $donttranslate) = @_;

	$main->{template_vars}{template_name} = $template . ($donttranslate ? '' : '.html');

	$template = $main->translateName("templatedir::$template.html") unless $donttranslate;

	my $lastchange = ($main->{settings}{check_template_modification} ? (stat($template))[9] : 0);
	if (exists($templates{$template}))
	{
		my ($time, $ret) = @{$templates{$template}};
		return $ret if $time == $lastchange;
	}
	$main->open(local *FILE, $template) || $main->fatal_error('couldnotopen', {file => $template});

	my $first = <FILE>;
	my $module = exists($main->{r}) ? 'sourcedir::SimpleTemplateEnginePerl.pm' : 'sourcedir::SimpleTemplateEngine.pm';
	if ($first =~ /^\s*<!---\s*(\S+)\s*--->\s*$/)
	{
		$module = $1;
	}
	else
	{
		seek(FILE,0,0);
		$. = 0;
	}

	my $data;
	eval
	{
		$data = $main->{modules}{$module}->parseTemplate($main, *FILE);
	};
	my $error = $@;

	$main->close(*FILE);

	die $error if $error;

	$templates{$template} = [$lastchange, $data];
	return $data;
}

sub printTemplate
{
	my ($main, $template) = @_;

	my %types = ('text/html' => 1, 'text/xhtml' => 1, 'text/xml' => 1, 'application/xml' => 1, 'application/xhtml+xml' => 1);

	$main->{template_vars}{mime_type} = 'text/html';

	my $output = "";
	parseTemplate($main, $template)->process($main,\$output);

	$output .= "\n<!-- Generated by GT-Chat ".$main->{VERSION}.' (c) 2006 by Sascha Heldt -->';

	if ($main->{settings}{compress_output})
	{
		$output =~ s/(?<=\n)[\t ]*\n//sg;
		$output =~ s/[\t ]+/ /sg;
	}

	if (substr($output, 0, 6) eq '<?xml ' && $main->{template_vars}{mime_type} eq 'text/html' && $main->{settings}{xhtml_output})
	{
		my $accept = exists($main->{r}) ? $main->{r}->header_in("Accept") : $ENV{HTTP_ACCEPT};
		if ($accept =~ /application\/xhtml\+xml/)
		{
			$main->{template_vars}{mime_type} = 'application/xhtml+xml';
		}
	}

	my $charset = $main->{current_language}{charset};
	$charset=(defined($charset) ? "; charset=$charset" : "");
	if (exists($main->{r}))
	{
		$main->{r}->no_cache(1);
		if (defined($main->{template_vars}{file_name}) && $main->{template_vars}{file_name} ne '')
		{
			$main->{r}->header_out('Content-Disposition',"attachment; filename=$main->{template_vars}{file_name}");
		}
		$main->{r}->header_out('X-Powered-By',"GT-Chat $main->{VERSION}");
		$main->{r}->send_http_header($main->{template_vars}{mime_type}.$charset);
	}
	else
	{
		print "Expires: Mon, 7 Jan 1980 00:00:00 GMT\n";
		print "Cache-Control: no-store, no-cache, must-revalidate, post-check=0, pre-check=0, max-age=0\n";
		print "Pragma: no-cache\n";
		if (defined($main->{template_vars}{file_name}) && $main->{template_vars}{file_name} ne '')
		{
			print "Content-Disposition: attachment; filename=$main->{template_vars}{file_name}\n";
		}
		print "X-Powered-By: GT-Chat $main->{VERSION}\n";
		print "Content-Type: $main->{template_vars}{mime_type}$charset\n\n";
	}

	binmode(STDOUT) if ($main->{template_vars}{mime_type} eq 'application/octet-stream');
	print $output;
}

sub translateName
{
	my ($main, $file) = @_;

	my $basedir = $main->{runtime}{basedir};
	my @parts = ($file =~ /(.*)::$/ ? ($1,'') : split('::', $file));
	my $dir = ($#parts>0 ? $main->{settings}{directories}{shift(@parts)} . '/' : '');
	return "$basedir/$dir$parts[0]";
}

sub open
{
	my ($main, $fh, $file) = @_;
	die {error_name => 'error_staticcall', method => 'open'} unless (ref($main) && $main->isa(__PACKAGE__));  #DEBUG

	if ($main->{settings}{lock_type} == 2)
	{
		my $filename = $file;
		$filename =~ s/^[+<>\s]+//;
		$filename =~ s/\\/\//g;

		require Win32::Semaphore;
		my $semaphore = Win32::Semaphore->open($filename) || Win32::Semaphore->new(1,1,$filename);
		$semaphore->wait;

		$main->{runtime}{locked}{$filename} = $semaphore;
		$main->{runtime}{locked_handles}{$fh} = $filename;
	}

	my $ret = CORE::open($fh, $file);

	if ($ret && $main->{settings}{lock_type} == 1)
	{
		flock($fh, $file =~ /^[+>]/ ? 2 : 1);
	}

	return $ret;
}

sub close
{
	my ($main, $fh) = @_;
	die {error_name => 'error_staticcall', method => 'close'} unless (ref($main) && $main->isa(__PACKAGE__));  #DEBUG

	if ($main->{settings}{lock_type} == 1)
	{
		flock($_[1], 8);
	}

	my $ret = close($_[1]);

	if ($main->{settings}{lock_type} == 2)
	{
		my $filename = $main->{runtime}{locked_handles}{$fh};
		if ($filename)
		{
			my $semaphore = $main->{runtime}{locked}{$filename};
			$semaphore->release if ($semaphore);
		}
	}

	return $ret;
}

sub crypt
{
	my ($main, $string, $salt) = @_;
	if ($main->{settings}{use_internal_crypt})
	{
		my $crypter=$main->{modules}{'sourcedir::Crypt.pm'};
		return Crypt::crypt($string, $salt);
	}
	else
	{
		return crypt($string, $salt);
	}
}

sub getMessage
{
	my ($main, $name, $params) = @_;
	die {error_name => 'error_staticcall', method => 'getMessage'} unless (ref($main) && $main->isa(__PACKAGE__));  #DEBUG

	my $allowhtml=0;
	if ($name =~ /\!$/)
	{
		$name =~ s/\!$//;
		$allowhtml=1;
	}

	my @messages=split(/\n/,$main->{current_language}{messages}{$name});
	my $msg=$messages[$#messages>0 ? rand @messages : 0];
	if ($allowhtml)
	{
		$msg = $main->toHTML($msg);
		$msg =~ s/%%([^%]+)%%/$params->{$1}/g;
	}
	else
	{
		$msg =~ s/%%([^%]+)%%/$params->{$1}/g;
		$msg = $main->toHTML($msg);
	}
	return $msg;
}

sub toHTML
{
	die {error_name => 'error_staticcall', method => 'toHTML'} unless (ref($_[0]) && $_[0]->isa(__PACKAGE__));  #DEBUG

	my ($main, $str) = @_;

	my %html_replace = (
		'&' => '&amp;',
		'#' => '&#35;',
		';' => '&#59;',
		'|' => '&#124;',
		'"' => '&quot;',
		'<' => '&lt;',
		'>' => '&gt;',
		"\t" => ' &nbsp; &nbsp; &nbsp;',
		"\n" => '<br/>',
		'  ' => ' &nbsp;',
	);

	$str =~ s/([&#;|"<>\t\n]|  )/$html_replace{$1}/ge;

	return $str;
}

sub toColor
{
	my ($main, $color) = @_;
	die {error_name => 'error_staticcall', method => 'toColor'} unless (ref($main) && $main->isa(__PACKAGE__));  #DEBUG

	$color = $main->lowercase($color);
	$color = $main->lowercase($main->{settings}{colors}{$color}) if (exists($main->{settings}{colors}{$color}));

	$color =~ s/^#//;

	if ($color =~ /^[0-9a-f]{6}$/)
	{
		return "#$color";
	}
	else
	{
		return undef;
	}
}

sub fatal_error
{
	my ($main, $error, $params) = @_;
	die {error_name => 'error_staticcall', method => 'fatal_error'} unless (ref($main) && $main->isa(__PACKAGE__));  #DEBUG

	$params->{error_name} = "error_$error";
	$main->exit($params);
}

sub hasPermission
{
	my($main, $name, $user) = @_;
	die {error_name => 'error_staticcall', method => 'hasPermission'} unless (ref($main) && $main->isa(__PACKAGE__));  #DEBUG

	$user = $main->{current_user} if (!defined($user));

	return 0 unless defined($user);

	if (defined($user->{permissions}) && $user->{permissions}{$name})
	{
		return ($user->{permissions}{$name}==1);
	}

	if (exists($main->{settings}{permissions}{$name}))
	{
		return $user->{tempgroup} >= $main->{settings}{permissions}{$name};
	}
	else
	{
		return $name =~ /\./;
	}
}

sub lowercase
{
	my($main,$ret)=@_;
	die {error_name => 'error_staticcall', method => 'lowercase'} unless (ref($main) && $main->isa(__PACKAGE__));  #DEBUG

	$ret = lc($ret);

	$ret =~ tr/À-ß/à-ÿ/;

	return $ret;
}

sub invokeModulesList
{
	my($main,$list,$proc)=splice(@_,0,3);
	die {error_name => 'error_staticcall', method => 'invokeModulesList'} unless (ref($main) && $main->isa(__PACKAGE__));  #DEBUG

	return if !defined($list);

	$list = [$list] if !ref($list) && $list;

	if (UNIVERSAL::isa($list,'ARRAY'))
	{
		foreach my $module (@$list)
		{
			$main->{modules}{$module}->$proc($main,@_) if $main->{modules}{$module}->can($proc);
		}
	}
}